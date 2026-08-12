library IAStateShopping requires IAUtils, IAData, IADataItems, IABrainMacro, IAStateSurvival, IABuildProgress

    // ==========================================================================
    // IA_State_Shopping.j — Sistema de Compras Físico (Bots caminan a tienda)
    // ==========================================================================
    //
    // DISEÑO:
    //   - Build único CARA: Botas → Bracer → Armaduras → Auras → Daños.
    //   - Los ítems se eligen según el atributo principal del héroe (STR/AGI/INT).
    //   - El atributo se fija al nacer (heroId original) para evitar problemas
    //     con transformaciones que cambian el TypeId.
    //   - Auras (ajen/lgdh): solo 1 por equipo. Se verifica inventario de aliados
    //     en runtime antes de comprar.
    //   - RUSH DE AGI: las builds de AGILIDAD (AGI natural, INT redirigido a AGI,
    //     o takeover que heredó ítems AGI) intercalan TANDAS DE TOMOS 'tdex' en la
    //     lista para topar su velocidad de ataque ANTES del late game:
    //       hito 100 AGI total desde la 1ª armadura · hito 150 desde la súper
    //       armadura (mitad de lista) · tope 200/+400% en el modo tomo final.
    //     Ver GetAgiRushFloor. Las auras comprables pasan SIEMPRE primero.
    //
    // SEGURIDAD:
    //   - NO compra si hay héroe enemigo en radio 1200.
    //   - NO compra si está siendo atacado por un HEROE enemigo.
    //   - Si la compra falla (sin stock), regresa a laning con cooldown de 30s.
    //   - Si HP baja del 40%, Survival interrumpe Shopping automáticamente.
    //
    // DEPENDENCIAS:
    //   - IADataItems_GetGoldCost, GetShopType, GetInitialStockDelay
    //   - IAData_GetPrimaryAttr (recibe heroTypeId, no unit)
    //   - IAUtils_GetGameTime, GetDistanceUnitXY
    //   - IA_Target_Memory (hashtable global de IAUtils)
    // ==========================================================================

    globals
        // --- COLAS DE COMPRA ---
        // Las colas se construyen dinámicamente según el atributo del héroe.
        // Aquí definimos el tamaño máximo y las constantes de build.
        private constant integer BUILD_CARA  = 1

        // --- TIENDAS CACHEADAS POR BANDO ---
        // Índice: shopTypeId → unit handle
        // Se pueblan en InitShopping escaneando PLAYER_NEUTRAL_PASSIVE.
        private constant integer MAX_SHOP_TYPES = 8
        private integer array ShopTypeIds
        private unit array ShopsHum     // Tiendas del bando Humano (X < 0)
        private unit array ShopsOrc     // Tiendas del bando Orco (X > 0)
        private unit ShopCenter         // Tienda central única (ngt2)
        private integer ShopTypeCount = 0

        // --- HASHTABLE KEYS (en IA_Target_Memory) ---
        // Usamos keys altas (100+) para no chocar con las del Aggro Tracker (0-4).
        private constant integer KEY_BUY_INDEX     = 100 // integer: posición actual en la cola
        private constant integer KEY_BUILD_TYPE    = 101 // integer: siempre BUILD_CARA
        private constant integer KEY_LAST_ATTEMPT  = 102 // real: timestamp del último intento fallido
        private constant integer KEY_PRIMARY_ATTR  = 103 // integer: atributo principal fijado al nacer
        private constant integer KEY_QUEUE_SIZE    = 104 // integer: tamaño de la cola de este bot
        private constant integer KEY_SHOP_WAIT_START = 105 // real: timestamp de llegada física a la tienda
        private constant integer KEY_HAS_AURA         = 107 // integer: 1 si el bot ya compró un aura
        private constant integer KEY_INT_TOME_SWITCH  = 109 // integer (0/1): 1 = héroe NATURAL-INT cuya build quedó en AGI (bot fresco redirigido O takeover que heredó ítems AGI). Activa el switch de tomos AGI→INT al topar el AS. Si la build quedó STR/INT, o el natural no es INT, vale 0.
        // Keys 110..119: IDs de los ítems en la cola (máx 10 ítems)
        private constant integer KEY_QUEUE_BASE    = 110
        private constant integer KEY_LAST_FREE_SLOTS = 120 // integer: slots libres vistos la última vez. Si la build YA estaba completa y aparecen MÁS libres, un aliado quitó un ítem de la lista → reconstruir cola y recomprar (objetivo: lista siempre completa).

        // --- CONSTANTES DE COMPORTAMIENTO ---
        private constant real SHOP_RANGE       = 350.0  // Distancia para poder comprar
        private constant real RETRY_COOLDOWN   = 30.0   // Segundos entre reintentos tras fallo
        private constant real SAFETY_RADIUS    = 1200.0 // Radio para detectar héroes enemigos
        private constant real MAX_SHOP_WAIT    = 3.0    // Segundos máximos de espera activa en la tienda
        private constant integer TOME_GOLD_THRESHOLD = 2000 // Oro mínimo para ir a comprar tomos

        // --- RUSH DE AGI (tomos 'tdex' intercalados en la lista) ---
        // Hitos de AGILIDAD TOTAL (GetHeroAgi con bonus: base + niveles + ítems +
        // tomos ya comidos). Se comparan contra la lectura EN VIVO, así el sistema
        // se auto-corrige solo (sube de nivel, pierde/recibe ítems) sin guardar
        // ningún estado nuevo. El tope final (200 AGI / +400% AS) NO es un hito:
        // lo cubre el modo tomo de fin de lista ya existente (GetTomeForBot).
        private constant integer AGI_RUSH_FLOOR_1 = 100 // hito desde la 1ª armadura
        private constant integer AGI_RUSH_FLOOR_2 = 150 // hito desde la súper armadura (mitad de lista)
    endglobals

    // Devuelve el rawcode del tomo correspondiente al atributo principal del bot.
    private function GetTomeForAttr takes integer attr returns integer
        if attr == IAData_ATTR_STR then
            return 'tstr'
        elseif attr == IAData_ATTR_AGI then
            return 'tdex'
        else
            return 'tint'
        endif
    endfunction

    // Devuelve el rawcode del tomo que ESTE bot debe comprar en modo-tomo.
    // Caso especial — SOLO bots con la bandera KEY_INT_TOME_SWITCH=1, es decir un héroe
    // cuyo atributo NATURAL es INT y cuya build quedó en AGI (sea bot fresco redirigido,
    // o takeover que heredó ítems de AGILIDAD del humano):
    //   - Compra tomos de AGILIDAD ('tdex') MIENTRAS su velocidad de ataque NO esté al
    //     tope. Al alcanzar el +400% de AS (motor) — equivalente a 200 de AGI total —
    //     más agilidad ya no le sube el AS, así que VUELVE a su INT natural ('tint').
    //   - Condición DINÁMICA: se reevalúa en cada decisión de tomo. Si un aliado le
    //     quita un ítem AGI y su AS cae del tope, vuelve a 'tdex' solo.
    //   - El tope se mide con DOS señales: GetHeroAgi total >= 200 (exacto, sin ruido de
    //     float) y GetAttackSpeedMod >= 4.0 (incluye AS de ítems/auras, no solo agilidad;
    //     misma función que el comando -as, ya clampada a 4.0).
    // Resto de héroes (STR/AGI naturales, y takeover con build STR/INT): tomo de su build.
    private function GetTomeForBot takes unit hero, integer botHandle returns integer
        local integer buildAttr = LoadInteger(IA_Target_Memory, botHandle, KEY_PRIMARY_ATTR)
        if LoadInteger(IA_Target_Memory, botHandle, KEY_INT_TOME_SWITCH) == 1 then
            // NOTA: JASS no hace short-circuit en 'or'; por eso van if/elseif anidados
            // (así, con AGI ya >= 200 NO se paga el escaneo de GetAttackSpeedMod).
            if GetHeroAgi(hero, true) >= 200 then
                return 'tint'                              // 200 AGI total → AS al tope
            elseif IAUtils_GetAttackSpeedMod(hero) >= 4.0 then
                return 'tint'                              // +400% AS por otras fuentes
            endif
            return 'tdex'                                  // aún no al tope: tomos de AGI
        endif
        return GetTomeForAttr(buildAttr)
    endfunction

    // --- RUSH DE AGI: hito de agilidad activo para este bot (0 = inactivo) ---
    // Problema que ataca: la build AGI completa solo aporta ~72 AGI en ítems; el
    // resto hasta el tope de AS (+400% = 200 AGI total) salía de tomos que recién
    // se compraban al AGOTAR la lista (late game). Estos hitos intercalan tandas
    // de tomos 'tdex' DENTRO de la lista, anclados al INVENTARIO (no a buyIndex,
    // que en takeover apunta a ítems distintos porque la cola omite lo heredado):
    //   - hito 100: desde la 1ª armadura  (HasFirstArmor)
    //   - hito 150: desde la súper armadura (HasSuperArmor ≈ mitad de lista)
    // Aplica a TODA build AGI (KEY_PRIMARY_ATTR == AGI): héroe AGI natural, INT
    // redirigido a AGI, y takeover que heredó ítems de agilidad.
    //
    // NO incluye el chequeo de AS >= 4.0 (GetAttackSpeedMod escanea inventarios
    // aliados, caro para cada tick): cada llamador lo hace DESPUÉS de sus propios
    // chequeos baratos (en ShouldStartShopping, recién con el oro juntado).
    // Todo derivado en vivo: cero estado persistente nuevo.
    private function GetAgiRushFloor takes unit hero, integer botHandle returns integer
        local integer target
        if LoadInteger(IA_Target_Memory, botHandle, KEY_PRIMARY_ATTR) != IAData_ATTR_AGI then
            return 0
        endif
        if IABuildProgress_HasSuperArmor(hero) then
            set target = AGI_RUSH_FLOOR_2
        elseif IABuildProgress_HasFirstArmor(hero) then
            set target = AGI_RUSH_FLOOR_1
        else
            return 0 // sin armadura aún: la lista (botas/brac/armadura 1) va primero
        endif
        if GetHeroAgi(hero, true) >= target then
            return 0 // hito ya cumplido: seguir la lista normal
        endif
        return target
    endfunction

    // ==========================================================================
    // UTILIDADES INTERNAS
    // ==========================================================================

    // Busca la tienda cacheada por shopTypeId para el bando del héroe.
    private function GetShopForHero takes integer shopTypeId, player owner returns unit
        local integer i = 0

        // La tienda central (ngt2) es única, no tiene duplicado por bando
        if shopTypeId == 'ngt2' then
            return ShopCenter
        endif

        // Buscar en el cache de tiendas por bando
        loop
            exitwhen i >= ShopTypeCount
            if ShopTypeIds[i] == shopTypeId then
                if IsPlayerAlly(owner, Player(0)) then
                    return ShopsHum[i]
                else
                    return ShopsOrc[i]
                endif
            endif
            set i = i + 1
        endloop

        return null
    endfunction


    // Verifica si algún héroe aliado (NO el propio) tiene el ítem en su inventario.
    // Usa IACore_AllHeroes[] que incluye bots + humanos.
    // Consumidor: ShouldStartShopping (skip de auras UNIQUE_TEAM).
    private function AllyHasItem takes integer itemRawId, unit selfHero, player owner returns boolean
        local integer i = 0
        local unit h
        local integer slot
        local item it
        loop
            exitwhen i >= IACore_AllHeroCount
            set h = IACore_AllHeroes[i]
            if h != null and h != selfHero and IsUnitAlly(h, owner) and GetOwningPlayer(h) != owner then
                set slot = 0
                loop
                    exitwhen slot > 5
                    set it = UnitItemInSlot(h, slot)
                    if it != null and GetItemTypeId(it) == itemRawId then
                        set it = null
                        set h = null
                        return true
                    endif
                    set slot = slot + 1
                endloop
            endif
            set i = i + 1
        endloop
        set it = null
        set h = null
        return false
    endfunction

    // Verifica si este héroe ya tiene algún ítem aura (ajen o lgdh) en su inventario.
    // Regla: máximo 1 aura por héroe.
    private function SelfHasAnyAura takes unit hero returns boolean
        local integer slot = 0
        local item it
        local integer itemId
        loop
            exitwhen slot > 5
            set it = UnitItemInSlot(hero, slot)
            if it != null then
                set itemId = GetItemTypeId(it)
                if itemId == 'ajen' or itemId == 'lgdh' then
                    set it = null
                    return true
                endif
            endif
            set slot = slot + 1
        endloop
        set it = null
        return false
    endfunction

    // Avanza buyIndex saltando ítems de aura (UNIQUE_TEAM) que violan las reglas.
    //   Regla 1: máx 1 aura por héroe   → flag KEY_HAS_AURA o inventario (SelfHasAnyAura).
    //   Regla 2: máx 1 de cada aura por equipo → un aliado ya la tiene (AllyHasItem).
    // Se detiene en el primer ítem comprable (aura permitida o ítem normal).
    // Persiste el nuevo buyIndex en KEY_BUY_INDEX y lo devuelve.
    //
    // CRÍTICO: Se invoca TANTO en ShouldStartShopping (decisión) COMO en
    // ExecuteShopping (justo antes de comprar). La doble verificación cierra la
    // condición de carrera: como MainLoop itera los bots en serie y las compras
    // son síncronas, si un aliado compró el aura mientras este bot caminaba a la
    // tienda, la re-validación en ExecuteShopping lo detecta y evita el duplicado.
    private function SkipBlockedAuras takes unit hero, player owner, integer botHandle, integer buyIndex, integer queueSize returns integer
        local integer itemId
        loop
            exitwhen buyIndex >= queueSize
            set itemId = LoadInteger(IA_Target_Memory, botHandle, KEY_QUEUE_BASE + buyIndex)
            if IADataItems_HasTag(itemId, ITEM_TAG_UNIQUE_TEAM) then
                // Regla 1: ¿Ya tengo UN aura? (flag hashtable O inventario)
                if LoadInteger(IA_Target_Memory, botHandle, KEY_HAS_AURA) == 1 or SelfHasAnyAura(hero) then
                    set buyIndex = buyIndex + 1
                    call SaveInteger(IA_Target_Memory, botHandle, KEY_BUY_INDEX, buyIndex)
                // Regla 2: ¿Un aliado tiene ESTA aura? (máx 1 por equipo)
                elseif AllyHasItem(itemId, hero, owner) then
                    set buyIndex = buyIndex + 1
                    call SaveInteger(IA_Target_Memory, botHandle, KEY_BUY_INDEX, buyIndex)
                else
                    // Aura permitida: comprable. Detener el salto.
                    exitwhen true
                endif
            else
                // Ítem normal: comprable. Detener el salto.
                exitwhen true
            endif
        endloop
        return buyIndex
    endfunction

    // Construye la cola de compras para un bot según su atributo (solo CARA).
    // Omite ítems que ya posee en su inventario.
    // Orden fijo: bspd > brac > ARMOR > ajen > lgdh > ARMOR > DAMAGE > ARMOR > DAMAGE > ARMOR
    // Las auras (ajen/lgdh) se agregan si el bot no las tiene; el chequeo de aliados se hace en runtime.
    // Escribe directamente en IA_Target_Memory[botHandle, KEY_QUEUE_BASE+N].
    private function BuildQueue takes unit hero, integer botHandle, integer attr returns nothing
        local integer idx = 0
        local integer slot = 0
        local item it
        local integer itemId
        
        // Contadores de inventario
        local integer countBspd = 0
        local integer countBrac = 0
        local integer countTPBoots = 0
        local integer countBaseArmor = 0
        local integer countSuperArmor = 0
        local integer countBaseDamage = 0
        local integer countSuperDamage = 0
        local integer countAjen = 0
        local integer countLgdh = 0
        
        // IDs según atributo (solo CARA)
        local integer baseArmor = 0
        local integer superArmor = 0
        local integer baseDamage = 0
        local integer superDamage = 0
        
        // Slots consumidos (cada fusión cuenta x2)
        local integer armorConsumed = 0
        local integer damageConsumed = 0
        
        // --- 1. Asignar IDs de ítems según atributo ---
        if attr == IAData_ATTR_STR then
            set baseArmor = 'I00M'
            set superArmor = 'I01A'
            set baseDamage = 'I007'
            set superDamage = 'I01E'
        elseif attr == IAData_ATTR_AGI then
            set baseArmor = 'I00U'
            set superArmor = 'I01B'
            set baseDamage = 'I00B'
            set superDamage = 'I01D'
        else
            set baseArmor = 'I00Q'
            set superArmor = 'I01C'
            set baseDamage = 'I00F'
            set superDamage = 'I01F'
        endif
        
        // --- 2. Escanear inventario actual ---
        set slot = 0
        loop
            exitwhen slot > 5
            set it = UnitItemInSlot(hero, slot)
            if it != null then
                set itemId = GetItemTypeId(it)
                if itemId == 'bspd' then
                    set countBspd = countBspd + 1
                elseif itemId == 'brac' then
                    set countBrac = countBrac + 1
                elseif itemId == 'I00W' then
                    set countTPBoots = countTPBoots + 1
                elseif itemId == baseArmor then
                    set countBaseArmor = countBaseArmor + 1
                elseif itemId == superArmor then
                    set countSuperArmor = countSuperArmor + 1
                elseif itemId == baseDamage then
                    set countBaseDamage = countBaseDamage + 1
                elseif itemId == superDamage then
                    set countSuperDamage = countSuperDamage + 1
                elseif itemId == 'ajen' then
                    set countAjen = countAjen + 1
                elseif itemId == 'lgdh' then
                    set countLgdh = countLgdh + 1
                endif
            endif
            set slot = slot + 1
        endloop
        set it = null
        
        // --- 3. Calcular slots consumidos ---
        // Cada superArmor fusionada cuenta como 2 baseArmors compradas.
        set armorConsumed = countBaseArmor + countSuperArmor * 2
        set damageConsumed = countBaseDamage + countSuperDamage * 2
        
        // --- 4. Construir cola en orden fijo ---
        
        // FASE 1: Botas + Bracer (componentes de TP Boots)
        if countTPBoots <= 0 then
            if countBspd <= 0 then
                call SaveInteger(IA_Target_Memory, botHandle, KEY_QUEUE_BASE + idx, 'bspd')
                set idx = idx + 1
            endif
            if countBrac <= 0 then
                call SaveInteger(IA_Target_Memory, botHandle, KEY_QUEUE_BASE + idx, 'brac')
                set idx = idx + 1
            endif
        endif
        
        // FASE 2: Build CARA — ARMOR > AURA1 > AURA2 > ARMOR > DAMAGE > ARMOR > DAMAGE > ARMOR
        
        // Armadura 1 (1 de 4)
        if armorConsumed < 1 then
            call SaveInteger(IA_Target_Memory, botHandle, KEY_QUEUE_BASE + idx, baseArmor)
            set idx = idx + 1
        endif
        
        // Ancestro Janggo (ajen) — chequeo de aliados se hace en runtime
        if countAjen <= 0 then
            call SaveInteger(IA_Target_Memory, botHandle, KEY_QUEUE_BASE + idx, 'ajen')
            set idx = idx + 1
        endif
        
        // Legión (lgdh) — chequeo de aliados se hace en runtime
        if countLgdh <= 0 then
            call SaveInteger(IA_Target_Memory, botHandle, KEY_QUEUE_BASE + idx, 'lgdh')
            set idx = idx + 1
        endif
        
        // Armadura 2 (2 de 4) — con la armadura 1, forman la primera fusión
        if armorConsumed < 2 then
            call SaveInteger(IA_Target_Memory, botHandle, KEY_QUEUE_BASE + idx, baseArmor)
            set idx = idx + 1
        endif
        
        // Daño 1 (1 de 2)
        if damageConsumed < 1 then
            call SaveInteger(IA_Target_Memory, botHandle, KEY_QUEUE_BASE + idx, baseDamage)
            set idx = idx + 1
        endif
        
        // Armadura 3 (3 de 4)
        if armorConsumed < 3 then
            call SaveInteger(IA_Target_Memory, botHandle, KEY_QUEUE_BASE + idx, baseArmor)
            set idx = idx + 1
        endif
        
        // Daño 2 (2 de 2) — con el daño 1, forman la fusión de daño
        if damageConsumed < 2 then
            call SaveInteger(IA_Target_Memory, botHandle, KEY_QUEUE_BASE + idx, baseDamage)
            set idx = idx + 1
        endif
        
        // Armadura 4 (4 de 4) — con la armadura 3, forman la segunda fusión de armadura
        if armorConsumed < 4 then
            call SaveInteger(IA_Target_Memory, botHandle, KEY_QUEUE_BASE + idx, baseArmor)
            set idx = idx + 1
        endif
        
        // Guardar tamaño real de la cola
        call SaveInteger(IA_Target_Memory, botHandle, KEY_QUEUE_SIZE, idx)
    endfunction

    // ==========================================================================
    // API PÚBLICA
    // ==========================================================================

    // Inicializa el sistema de tiendas. Cachea las unidades de todas las tiendas.
    // Llamado 1 vez desde IA_Core.StartEngine().
    public function InitShopping takes nothing returns nothing
        local group g = CreateGroup()
        local unit u
        local integer typeId
        local real ux
        local integer i

        // Registrar los TypeIds de las tiendas que nos interesan
        set ShopTypeIds[0] = 'ngme'
        set ShopTypeIds[1] = 'n00O'
        set ShopTypeIds[2] = 'n00M'
        set ShopTypeIds[3] = 'n00N'
        set ShopTypeIds[4] = 'n000'
        set ShopTypeIds[5] = 'nfh1'
        set ShopTypeIds[6] = 'n001'
        set ShopTypeCount = 7

        // Inicializar a null
        set i = 0
        loop
            exitwhen i >= ShopTypeCount
            set ShopsHum[i] = null
            set ShopsOrc[i] = null
            set i = i + 1
        endloop
        set ShopCenter = null

        // Escanear todas las unidades de PLAYER_NEUTRAL_PASSIVE para encontrar tiendas
        call GroupEnumUnitsOfPlayer(g, Player(PLAYER_NEUTRAL_PASSIVE), null)
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            call GroupRemoveUnit(g, u)

            set typeId = GetUnitTypeId(u)
            set ux = GetUnitX(u)

            // Tienda central única
            if typeId == 'ngt2' then
                set ShopCenter = u
            else
                // Buscar si es una de nuestras tiendas registradas
                set i = 0
                loop
                    exitwhen i >= ShopTypeCount
                    if ShopTypeIds[i] == typeId then
                        // Separar por bando según coordenada X
                        if ux < 0.0 then
                            // Solo cachear la primera de cada tipo (evitar sobreescribir)
                            if ShopsHum[i] == null then
                                set ShopsHum[i] = u
                            endif
                        else
                            if ShopsOrc[i] == null then
                                set ShopsOrc[i] = u
                            endif
                        endif
                    endif
                    set i = i + 1
                endloop
            endif
        endloop

        call DestroyGroup(g)
        set g = null
        set u = null
    endfunction


    // Asigna la build CARA al bot y construye su cola de compras.
    // Detecta ítems existentes en inventario (Takeover) para adoptar el atributo correcto.
    // Llamado 1 vez desde IA_Core.Bot.create().
    // IMPORTANTE: Recibe heroTypeId ORIGINAL para fijar el atributo principal
    // sin importar si el héroe se transforma después.
    public function AssignBuild takes unit hero, integer originalHeroTypeId returns nothing
        local integer botHandle = GetHandleId(hero)
        local integer slot = 0
        local item it
        local integer itemId
        
        // Contadores para detección de atributo existente (Takeover)
        local integer caraStr = 0
        local integer caraAgi = 0
        local integer caraInt = 0
        local integer attr = 0
        local integer naturalAttr = 0
        local boolean intTomeSwitch = false
        local boolean foundBuild = false
        
        // --- 1. Detección de ítems CARA en el inventario actual (Takeover) ---
        set slot = 0
        loop
            exitwhen slot > 5
            set it = UnitItemInSlot(hero, slot)
            if it != null then
                set itemId = GetItemTypeId(it)
                // CARA STR
                if itemId == 'I00M' or itemId == 'I01A' or itemId == 'I007' or itemId == 'I01E' then
                    set caraStr = caraStr + 1
                    // CARA AGI
                elseif itemId == 'I00U' or itemId == 'I01B' or itemId == 'I00B' or itemId == 'I01D' then
                    set caraAgi = caraAgi + 1
                    // CARA INT
                elseif itemId == 'I00Q' or itemId == 'I01C' or itemId == 'I00F' or itemId == 'I01F' then
                    set caraInt = caraInt + 1
                endif
            endif
            set slot = slot + 1
        endloop
        set it = null
        
        // --- 2. Decidir Atributo de BUILD ---
        set naturalAttr = IAData_GetPrimaryAttr(originalHeroTypeId)
        if caraStr + caraAgi + caraInt > 0 then
            // === TAKEOVER (heredó ítems de la lista): seguir el camino del humano ===
            // Se adopta el atributo que el jugador real ya estaba armando, para NO
            // desperdiciar ítems ya comprados. Desempate: AGI > STR > INT (antes STR>AGI>INT).
            // La build NO se redirige: se continúa el atributo heredado tal cual.
            set foundBuild = true
            if caraAgi >= caraStr and caraAgi >= caraInt then
                set attr = IAData_ATTR_AGI
            elseif caraStr >= caraAgi and caraStr >= caraInt then
                set attr = IAData_ATTR_STR
            else
                set attr = IAData_ATTR_INT
            endif
        else
            // === SIN ÍTEMS (bot fresco al inicio, O takeover de un héroe que no tenía
            //     ningún ítem de la lista): LÓGICA BASE = atributo principal natural ===
            set attr = naturalAttr
            // POLÍTICA INT→AGI (solo la BUILD): los bots NO castean (modo skills aleatorias
            // off con bots), así que el +INT de la build es maná muerto; el +AGI da vel.
            // ataque + armadura con la MISMA armadura/HP/daño plano. Un héroe INT-natural
            // SIN ítems heredados construye con ítems de AGILIDAD.
            if naturalAttr == IAData_ATTR_INT then
                set attr = IAData_ATTR_AGI
            endif
        endif

        // --- 2b. SWITCH DE TOMOS (AGI→INT al topar el AS) ---
        // Condición ÚNICA y derivada: atributo NATURAL == INT  Y  build resultante == AGI.
        // Cubre por igual los DOS caminos que dejan a un héroe INT armando AGI:
        //   (a) bot fresco INT redirigido a AGI (rama sin-ítems de arriba), y
        //   (b) takeover de un héroe INT que heredó ítems de AGILIDAD del humano.
        // En ambos, los tomos serán de AGI hasta topar el AS (200 AGI / +400%) y RECIÉN
        // AHÍ se vuelve a su INT natural. Si la build quedó STR o INT (takeover STR/INT),
        // NO hay switch (compra tomos de su build). En STR/AGI-naturales tampoco se activa.
        set intTomeSwitch = (naturalAttr == IAData_ATTR_INT and attr == IAData_ATTR_AGI)
        
        // Guardar datos persistentes del bot
        call SaveInteger(IA_Target_Memory, botHandle, KEY_BUILD_TYPE, BUILD_CARA)
        call SaveInteger(IA_Target_Memory, botHandle, KEY_BUY_INDEX, 0)
        call SaveReal(IA_Target_Memory, botHandle, KEY_LAST_ATTEMPT, -999.0)
        call SaveReal(IA_Target_Memory, botHandle, KEY_SHOP_WAIT_START, 0.0)
        call SaveInteger(IA_Target_Memory, botHandle, KEY_PRIMARY_ATTR, attr)          // atributo de BUILD (INT-natural fresco → AGI)
        if intTomeSwitch then
            call SaveInteger(IA_Target_Memory, botHandle, KEY_INT_TOME_SWITCH, 1)       // hará el switch de tomos AGI→INT al topar el AS
        else
            call SaveInteger(IA_Target_Memory, botHandle, KEY_INT_TOME_SWITCH, 0)
        endif

        // Si el héroe ya tiene un aura (takeover), marcar flag
        if SelfHasAnyAura(hero) then
            call SaveInteger(IA_Target_Memory, botHandle, KEY_HAS_AURA, 1)
        else
            call SaveInteger(IA_Target_Memory, botHandle, KEY_HAS_AURA, 0)
        endif
        
        // --- 3. Construir la cola de compras ---
        call BuildQueue(hero, botHandle, attr)

        // Línea base de slots libres para detectar futuras pérdidas de ítems de la lista
        // (RefreshQueueIfItemLost). Se inicializa al valor real para no disparar un
        // refresco espurio en un takeover que ya nace con la build completa.
        call SaveInteger(IA_Target_Memory, botHandle, KEY_LAST_FREE_SLOTS, IABuildProgress_CountFreeSlots(hero))
    endfunction


    // Mantiene la cola de build VIVA tras completarse. El objetivo del bot es SIEMPRE
    // tener su lista completa en el inventario. Si la build ya estaba completa
    // (buyIndex>=queueSize) y de pronto hay MÁS slots libres que la última vez, significa
    // que un aliado le quitó (o se consumió) un ítem de la lista. Como SÍ hay hueco para
    // comprar, se RECONSTRUYE la cola desde el inventario real (BuildQueue solo encola lo
    // que falta y respeta el atributo de build) y se reinicia buyIndex: el bot deja los
    // tomos y vuelve a comprar el ítem faltante. Al completarla otra vez, vuelve a tomos.
    //
    //   - Inventario LLENO (freeSlots no aumentó) → no refresca: sigue en pausa/tomos.
    //   - Hueco "normal" por un aura saltada (aliado la tiene) → NO dispara: ese hueco ya
    //     estaba contado en lastFree al completarse la build, así que no hay aumento.
    //   - Robusto con ítems ajenos (takeover): si quitan un ítem ajeno, BuildQueue ve la
    //     build propia completa, reconstruye una cola vacía/solo-auras y vuelve a tomos.
    //
    // Idempotente y barato: solo reconstruye en el frame del aumento; lastFree se
    // actualiza siempre, así que no hay reconstrucción repetida (sin churn).
    private function RefreshQueueIfItemLost takes unit hero, integer botHandle returns nothing
        local integer buyIndex    = LoadInteger(IA_Target_Memory, botHandle, KEY_BUY_INDEX)
        local integer queueSize   = LoadInteger(IA_Target_Memory, botHandle, KEY_QUEUE_SIZE)
        local integer lastFree    = LoadInteger(IA_Target_Memory, botHandle, KEY_LAST_FREE_SLOTS)
        local integer currentFree = IABuildProgress_CountFreeSlots(hero)
        if buyIndex >= queueSize and currentFree > lastFree then
            call BuildQueue(hero, botHandle, LoadInteger(IA_Target_Memory, botHandle, KEY_PRIMARY_ATTR))
            call SaveInteger(IA_Target_Memory, botHandle, KEY_BUY_INDEX, 0)
        endif
        call SaveInteger(IA_Target_Memory, botHandle, KEY_LAST_FREE_SLOTS, currentFree)
    endfunction

    // ¿Debería este bot ir a comprar ahora?
    // Verifica: hay ítem pendiente, tiene oro, stock disponible, zona segura.
    // Llamado cada tick desde IA_Core.Bot.update().
    public function ShouldStartShopping takes unit hero, player owner returns boolean
        local integer botHandle = GetHandleId(hero)
        local integer buyIndex
        local integer queueSize
        local integer nextItemId
        local integer goldCost
        local real stockDelay
        local real lastAttempt
        local real gameTime
        // Reloj de MAPA (absoluto, desde el unpause del Master). SOLO para el
        // chequeo de stock inicial (paso 5): el retraso de stock de la tienda es
        // un tiempo ABSOLUTO del mapa, no un delta. gameTime (reloj del motor)
        // arranca en 0 al encender la IA, así que en un takeover de voto sin bots
        // previos daba falsos "NoShop Delay". Ver IAUtils_GetMapTime.
        local real mapTime
        local group g
        local unit enumUnit
        local boolean enemyHeroNearby
        // [POLÍTICA INV. LLENO] slots libres + modo tomo EFECTIVO. Si el bot no
        // tiene slots libres (típico en TAKEOVER con ítems ajenos), PAUSA su lista
        // de build y compra tomos; al liberarse un slot (p.ej. un humano le saca un
        // ítem) freeSlots>0 y la cola se RETOMA donde quedó (buyIndex intacto).
        local integer freeSlots
        local boolean tomeMode
        // [RUSH AGI] hito de agilidad activo para tomos intercalados (0 = inactivo).
        // Derivado en vivo en cada decisión; no se persiste.
        local integer agiRushTarget = 0

        // Obtener tiempo de juego
        set gameTime = IAUtils_GetGameTime()
        set mapTime = IAUtils_GetMapTime()

        // REFRESCO DE BUILD: si un aliado quitó un ítem de la lista YA completa y hay
        // hueco para recomprarlo, reconstruye la cola y reinicia buyIndex (deja los tomos).
        call RefreshQueueIfItemLost(hero, botHandle)

        // 1. ¿Hay ítem pendiente en la cola?
        set buyIndex = LoadInteger(IA_Target_Memory, botHandle, KEY_BUY_INDEX)
        set queueSize = LoadInteger(IA_Target_Memory, botHandle, KEY_QUEUE_SIZE)

        // MODO TOMO EFECTIVO: cola completa (buyIndex>=queueSize) O inventario
        // lleno con build pendiente (build EN PAUSA hasta que se libere un slot).
        set freeSlots = IABuildProgress_CountFreeSlots(hero)
        set tomeMode = (buyIndex >= queueSize) or (freeSlots <= 0)

        if tomeMode then
            // MODO TOMO: Cola completada O build en pausa (inv. lleno). Comprar tomos.
            if GetPlayerState(owner, PLAYER_STATE_RESOURCE_GOLD) < TOME_GOLD_THRESHOLD then
                return false
            endif
            // Tiene >=1000g. Las demás condiciones (enemigos, cooldown) se verifican abajo.
            // Asignar nextItemId para que los chequeos posteriores de oro y delay funcionen.
            set nextItemId = GetTomeForBot(hero, botHandle)
            set goldCost = 100
            set stockDelay = 0.0
            // Saltar directamente al chequeo de cooldown (paso 2)
        else

            // 1b. PRE-CHECK: Saltar ítems UNIQUE_TEAM (auras) bloqueados por reglas.
            // (Lógica compartida con ExecuteShopping vía SkipBlockedAuras.)
            set buyIndex = SkipBlockedAuras(hero, owner, botHandle, buyIndex, queueSize)
            set nextItemId = LoadInteger(IA_Target_Memory, botHandle, KEY_QUEUE_BASE + buyIndex)
            if buyIndex >= queueSize then
                return false
            endif

            // 1c. RUSH DE AGI: ¿toca una tanda de tomos 'tdex' ANTES de este ítem?
            // Excepción: si el siguiente ítem es un AURA comprable (UNIQUE_TEAM,
            // SkipBlockedAuras ya se detuvo en ella), el aura pasa primero: es
            // barata (800) y beneficia al equipo entero.
            if not IADataItems_HasTag(nextItemId, ITEM_TAG_UNIQUE_TEAM) then
                set agiRushTarget = GetAgiRushFloor(hero, botHandle)
            endif
            if agiRushTarget > 0 then
                // Umbral de oro ADAPTATIVO: junta hasta TOME_GOLD_THRESHOLD para
                // que el viaje valga la pena, pero si faltan pocos tomos (100 de
                // oro cada uno) no espera de más.
                set goldCost = (agiRushTarget - GetHeroAgi(hero, true)) * 100
                if goldCost > TOME_GOLD_THRESHOLD then
                    set goldCost = TOME_GOLD_THRESHOLD
                endif
                if GetPlayerState(owner, PLAYER_STATE_RESOURCE_GOLD) < goldCost then
                    return false
                endif
                // Con el oro listo, recién AQUÍ el chequeo CARO (scan de AS). Si el
                // AS ya está al tope por auras/ítems, el rush no aporta nada y se
                // sigue con la lista normal este mismo tick.
                if IAUtils_GetAttackSpeedMod(hero) >= 4.0 then
                    set agiRushTarget = 0
                else
                    set nextItemId = 'tdex'
                    set stockDelay = 0.0 // tomos: sin retraso de stock (confirmado en el mapa)
                endif
            endif

        endif // Cierra if tomeMode (modo tomo) / else (compra de build)

        // 2. ¿Pasó el cooldown de reintento?
        set lastAttempt = LoadReal(IA_Target_Memory, botHandle, KEY_LAST_ATTEMPT)
        if gameTime - lastAttempt < RETRY_COOLDOWN then
            return false
        endif

        if tomeMode then
            // (Modo tomo: goldCost y stockDelay ya asignados arriba)
        elseif agiRushTarget > 0 then
            // (Rush AGI: goldCost = tanda de tomos y stockDelay ya asignados en 1c)
        else
            // 3. Obtener el ítem actual de la cola
            set nextItemId = LoadInteger(IA_Target_Memory, botHandle, KEY_QUEUE_BASE + buyIndex)

            // 4. ¿Tiene oro suficiente?
            set goldCost = IADataItems_GetGoldCost(nextItemId)
        endif

        if GetPlayerState(owner, PLAYER_STATE_RESOURCE_GOLD) < goldCost then
            return false
        endif

        // 5. ¿Pasó el delay de stock inicial?
        if not tomeMode and agiRushTarget <= 0 then
            set stockDelay = IADataItems_GetInitialStockDelay(nextItemId)
        endif
        // (En modo tomo y en rush AGI, stockDelay ya es 0.0)
        // mapTime (no gameTime): el retraso de stock es absoluto del mapa.
        if mapTime < stockDelay then
            return false
        endif

        // 6. ¿La zona está segura? (No hay héroe enemigo cerca)
        set enemyHeroNearby = false
        set g = CreateGroup()
        call GroupEnumUnitsInRange(g, GetUnitX(hero), GetUnitY(hero), SAFETY_RADIUS, null)
        loop
            set enumUnit = FirstOfGroup(g)
            exitwhen enumUnit == null
            call GroupRemoveUnit(g, enumUnit)
            if not IsUnitType(enumUnit, UNIT_TYPE_DEAD) and IsUnitType(enumUnit, UNIT_TYPE_HERO) and IsUnitEnemy(enumUnit, owner) then
                set enemyHeroNearby = true
                // No salir del loop: debemos vaciar el grupo para destruirlo
            endif
        endloop
        call DestroyGroup(g)
        set g = null
        set enumUnit = null

        if enemyHeroNearby then
            return false
        endif

        // 7. ¿No estoy siendo atacado por un HÉROE enemigo?
        // Solo bloqueamos shopping si quien nos ataca es un HEROE vivo y cercano.
        // Creeps y torres NO deben bloquear las compras.
        if LoadUnitHandle(IA_Target_Memory, botHandle, 4) != null then
            set enumUnit = LoadUnitHandle(IA_Target_Memory, botHandle, 4)
            if not IsUnitType(enumUnit, UNIT_TYPE_DEAD) and IsUnitType(enumUnit, UNIT_TYPE_HERO) and IsUnitEnemy(enumUnit, owner) and IAUtils_GetDistanceUnits(hero, enumUnit) < SAFETY_RADIUS then
                set enumUnit = null
                return false
            endif
            set enumUnit = null
        endif

        // TODOS LOS FILTROS PASADOS → IR A COMPRAR
        return true
    endfunction

    // Decide a qué estado SALIR cuando Shopping termina y tocaría volver al carril.
    // Antes de regresar a laning aprovechamos que el bot está en la base: si quedó
    // con poca vida (no "sano" según el MISMO umbral del 95% que usa Survival para
    // salir de la huida — IAStateSurvival_IsHealthy, única fuente de verdad), lo
    // derivamos a Survival (estado 3) para que vaya a la fuente a curarse. El motor
    // (Bot.update) lo mantendrá curándose y, vía la transición IsHealthy ya existente,
    // lo devolverá solo a laning al superar el 95%. Si está sano, vuelve a laning (1)
    // como siempre. Así enlazamos el fin de la compra con el sistema de emergencia
    // SIN duplicar la lógica de huida/curación.
    private function ShopExitState takes unit hero returns integer
        local real hpPercent = GetUnitState(hero, UNIT_STATE_LIFE) / GetUnitState(hero, UNIT_STATE_MAX_LIFE)
        if not IAStateSurvival_IsHealthy(hpPercent) then
            return 3 // Survival: ir a fuente a curarse antes de regresar al carril
        endif
        return 1 // Sano: volver a laning normalmente
    endfunction

    // Ejecuta el estado Shopping: caminar a tienda y comprar.
    // Llamado desde IA_Core.Bot.update() cuando state == 4.
    // Retorna el nuevo estado del bot (4 = sigue comprando, 1 = volver a laning).
    //
    // FLUJO (según diagrama):
    //   1. Validar que hay ítem pendiente en la cola.
    //   2. Caminar a la tienda si está lejos.
    //   3. Al llegar: activar Hold Position, iniciar timer de 3s.
    //   4. Cada tick (0.1s): intentar comprar con IssueNeutralImmediateOrderById.
    //   5. Si compra exitosa: DETENER COMPRAS Y HOLD, volver al TOP del flujo.
    //      ShouldStartShopping re-evalúa ORO + DELAY + ENEMIGOS para siguiente ítem.
    //   6. Si 3s expiran sin comprar: activar cooldown 30s, volver al farm.
    //
    public function ExecuteShopping takes unit hero, player owner, integer lane returns integer
        local integer botHandle = GetHandleId(hero)
        local integer buyIndex
        local integer queueSize
        local integer nextItemId
        local integer shopTypeId
        local unit shop
        local real shopX
        local real shopY
        local real dist
        local integer goldBefore
        local integer goldAfter
        local integer currentOrder
        local real currentTime = IAUtils_GetGameTime()
        local real shopWaitStart
        // [POLÍTICA INV. LLENO] mismo criterio que ShouldStartShopping: si no hay
        // slots libres, la build queda EN PAUSA y compramos tomos sin tocar buyIndex.
        local integer freeSlots
        local boolean tomeMode
        // [RUSH AGI] hito de agilidad activo (0 = inactivo). Se RE-DERIVA cada tick
        // (espejo de ShouldStartShopping): si el hito se cumple durante la caminata
        // (p.ej. subió de nivel), vuelve solo al ítem de la cola.
        local integer agiRushTarget = 0

        // REFRESCO DE BUILD (mismo criterio que ShouldStartShopping): si nos quitaron un
        // ítem de la lista YA completa y hay hueco, reconstruye la cola y reinicia buyIndex.
        // Se llama ANTES de leer buyIndex/queueSize para que reflejen la cola refrescada.
        call RefreshQueueIfItemLost(hero, botHandle)
        set buyIndex = LoadInteger(IA_Target_Memory, botHandle, KEY_BUY_INDEX)
        set queueSize = LoadInteger(IA_Target_Memory, botHandle, KEY_QUEUE_SIZE)

        // --- MODO TOMO EFECTIVO + RE-VALIDACIÓN DE AURAS ---
        // tomeMode = cola completa (buyIndex>=queueSize) O inventario lleno (build
        // EN PAUSA por ítems ajenos en takeover). En modo tomo NO tocamos buyIndex
        // ni auras: así, al liberarse un slot, freeSlots>0 y la cola se RETOMA donde
        // quedó.
        set freeSlots = IABuildProgress_CountFreeSlots(hero)
        set tomeMode = (buyIndex >= queueSize) or (freeSlots <= 0)

        // RE-VALIDACIÓN DE AURAS (anti-duplicado), SOLO si vamos a comprar build:
        // el bot decidió este ítem en ShouldStartShopping y caminó a la tienda;
        // durante el trayecto un ALIADO pudo comprar el aura. Re-evaluamos las
        // reglas UNIQUE_TEAM AQUÍ, justo antes de comprar, para no duplicarla.
        if not tomeMode then
            set buyIndex = SkipBlockedAuras(hero, owner, botHandle, buyIndex, queueSize)
            // SkipBlockedAuras pudo agotar la cola → pasar a modo tomo real.
            if buyIndex >= queueSize then
                set tomeMode = true
            endif
        endif

        // --- GUARDIA: ¿Modo tomo? → comprar tomo; si no, el ítem de la cola ---
        if tomeMode then
            // En modo tomo: determinar el tomo a comprar
            set nextItemId = GetTomeForBot(hero, botHandle)
        else
            set nextItemId = LoadInteger(IA_Target_Memory, botHandle, KEY_QUEUE_BASE + buyIndex)
            // RUSH DE AGI (espejo de ShouldStartShopping): tanda de tomos 'tdex'
            // ANTES del siguiente ítem de la cola, salvo que ese ítem sea un aura
            // comprable (las auras pasan primero). NO toca buyIndex: al cumplir el
            // hito, la cola se retoma exactamente donde quedó.
            if not IADataItems_HasTag(nextItemId, ITEM_TAG_UNIQUE_TEAM) then
                set agiRushTarget = GetAgiRushFloor(hero, botHandle)
            endif
            if agiRushTarget > 0 then
                if IAUtils_GetAttackSpeedMod(hero) >= 4.0 then
                    set agiRushTarget = 0 // AS ya al tope por auras/ítems: ítem normal
                else
                    set nextItemId = 'tdex'
                endif
            endif
        endif
        
        set shopTypeId = IADataItems_GetShopType(nextItemId)
        set shop = GetShopForHero(shopTypeId, owner)

        // Seguridad: si la tienda no se encontró, volver a laning
        if shop == null then
            set shop = null
            return ShopExitState(hero)
        endif

        set shopX = GetUnitX(shop)
        set shopY = GetUnitY(shop)
        set dist = IAUtils_GetDistanceUnitXY(hero, shopX, shopY)

        if dist > SHOP_RANGE then
            // --- CAMINANDO A LA TIENDA ---
            // Limpiar espera de tienda por si nos empujaron o salimos de rango
            call SaveReal(IA_Target_Memory, botHandle, KEY_SHOP_WAIT_START, 0.0)
            
            // Filtro anti-temblor: no repetir orden de move si ya la tiene
            set currentOrder = GetUnitCurrentOrder(hero)
            if currentOrder != OrderId("move") then
                call IssuePointOrder(hero, "move", shopX, shopY)
            endif
            set shop = null
            return 4 // Seguir en estado Shopping
        else
            // ===========================================================
            // LLEGÓ A LA TIENDA: VALIDAR ORO + HOLD POSITION + REINTENTOS
            // ===========================================================

            // RE-VALIDAR ORO al llegar. Si durante el camino a la tienda
            // el bot perdió oro (por otro sistema del mapa), abortar
            // inmediatamente sin desperdiciar 3 segundos intentando.
            if GetPlayerState(owner, PLAYER_STATE_RESOURCE_GOLD) < IADataItems_GetGoldCost(nextItemId) then
                call SaveReal(IA_Target_Memory, botHandle, KEY_SHOP_WAIT_START, 0.0)
                // HANDOFF LIMPIO A LANING: NO ordenar a GetLaneTarget (= base de
                // curación ENEMIGA = la fuente). Eso mandaba al bot recto a la fuente y,
                // al quedar la orden "attack" fija, suprimía el re-ruteo por fases de
                // ExecuteLaning. Con "stop", laning recalcula el objetivo correcto.
                call IssueImmediateOrder(hero, "stop")
                set shop = null
                return ShopExitState(hero)
            endif

            set shopWaitStart = LoadReal(IA_Target_Memory, botHandle, KEY_SHOP_WAIT_START)
            
            // Primer frame en rango: registrar timestamp de llegada
            if shopWaitStart < 0.01 then
                set shopWaitStart = currentTime
                call SaveReal(IA_Target_Memory, botHandle, KEY_SHOP_WAIT_START, shopWaitStart)
            endif
            
            // MANTENER HOLD POSITION en cada frame mientras esperamos.
            // Esto evita que el bot "gire" o se desplace durante la espera.
            set currentOrder = GetUnitCurrentOrder(hero)
            if currentOrder != OrderId("holdposition") then
                call IssueImmediateOrder(hero, "holdposition")
            endif
            
            // Intentar comprar en este tick
            set goldBefore = GetPlayerState(owner, PLAYER_STATE_RESOURCE_GOLD)
            call IssueNeutralImmediateOrderById(owner, shop, nextItemId)
            set goldAfter = GetPlayerState(owner, PLAYER_STATE_RESOURCE_GOLD)

            if goldAfter < goldBefore then
                // =======================================================
                // ¡COMPRA EXITOSA! (DETENER COMPRAS Y HOLD)
                // =======================================================
                // Según el diagrama de flujo: tras comprar, detener hold y
                // volver al TOP del flujo (state 1). ShouldStartShopping
                // re-evaluará ORO + DELAY + ENEMIGOS para el siguiente ítem.
                // NO emitir attack-move: evita temblores por órdenes conflictivas
                // si ShouldStartShopping activa shopping de nuevo en 0.1s.
                // Si el ítem comprado es un aura, activar flag INMEDIATAMENTE
                // para que ShouldStartShopping lo detecte en el siguiente tick.
                if IADataItems_HasTag(nextItemId, ITEM_TAG_UNIQUE_TEAM) then
                    call SaveInteger(IA_Target_Memory, botHandle, KEY_HAS_AURA, 1)
                endif
                call SaveReal(IA_Target_Memory, botHandle, KEY_SHOP_WAIT_START, 0.0)
                if not tomeMode and agiRushTarget <= 0 then
                    // Cola normal: avanzar al siguiente ítem
                    set buyIndex = buyIndex + 1
                    call SaveInteger(IA_Target_Memory, botHandle, KEY_BUY_INDEX, buyIndex)
                else
                    // =====================================================
                    // MODO TOMO / RUSH AGI: Compra masiva en un solo loop
                    // (modo tomo gasta todo el oro; el rush PARA en el hito)
                    // =====================================================
                    // El primer tomo ya se compró arriba. Ahora compramos
                    // todos los que podamos en un solo loop sin salir.
                    loop
                        set goldAfter = GetPlayerState(owner, PLAYER_STATE_RESOURCE_GOLD)
                        exitwhen goldAfter < 100
                        if agiRushTarget > 0 then
                            // RUSH AGI: parar EXACTO en el hito. Cada 'tdex' se consume
                            // al instante, así que GetHeroAgi ya refleja el tomo anterior.
                            // El oro restante queda para el siguiente ítem de la cola
                            // (buyIndex NO se tocó: la lista se retoma donde quedó).
                            exitwhen GetHeroAgi(hero, true) >= agiRushTarget
                            set nextItemId = 'tdex'
                        else
                            // Reevaluar el tomo en CADA compra: un bot INT-natural pasa de
                            // 'tdex' a 'tint' en cuanto su AS llega al tope (cada tomo de AGI
                            // se consume al instante y sube su agilidad), sin sobrepasarlo
                            // aunque tenga mucho oro. Ambos tomos los vende la MISMA tienda
                            // ('n000'), así que 'shop' sigue siendo válida.
                            set nextItemId = GetTomeForBot(hero, botHandle)
                        endif
                        call IssueNeutralImmediateOrderById(owner, shop, nextItemId)
                        if GetPlayerState(owner, PLAYER_STATE_RESOURCE_GOLD) >= goldAfter then
                            // No bajó el oro → el shop se quedó sin stock.
                            exitwhen true
                        endif
                    endloop
                    set goldAfter = GetPlayerState(owner, PLAYER_STATE_RESOURCE_GOLD)
                endif

                set shop = null
                return ShopExitState(hero)
            else
                // =======================================================
                // INTENTO FALLIDO — ¿Ya expiraron los 3 segundos?
                // =======================================================
                if currentTime - shopWaitStart >= MAX_SHOP_WAIT then
                    // SÍ expiró: alguien más tomó el ítem. Cooldown 30s y volver al farm.
                    call SaveReal(IA_Target_Memory, botHandle, KEY_LAST_ATTEMPT, currentTime)
                    call SaveReal(IA_Target_Memory, botHandle, KEY_SHOP_WAIT_START, 0.0)

                    // HANDOFF LIMPIO A LANING (ver nota arriba): "stop" en vez de
                    // attack-move a la fuente, para que ExecuteLaning re-rute por fases.
                    call IssueImmediateOrder(hero, "stop")
                    set shop = null
                    return ShopExitState(hero)
                else
                    // NO ha expirado: seguir en Hold Position esperando en la tienda.
                    set shop = null
                    return 4
                endif
            endif
        endif
    endfunction

endlibrary
