library IAUtils requires IAData, IADataItems, IADataBuffs
    // ===================================================
    // LIBRERÍA DE UTILIDADES MATEMÁTICAS PARA IA
    // ===================================================

    globals
        // Constante para conversiones rápidas
        public constant real DEGTORAD = 0.017453292
        public constant real RADTODEG = 57.29577951
        
        // Reloj Global de IA
        private real GlobalGameTime = 0.0

        // Grupo reutilizable para enumeraciones en triggers de escritura.
        // Cero handle leaks: se crea 1 vez, se limpia con GroupClear antes de usar.
        private group ENUM_GROUP = null
    endglobals

    // 1. Obtener Distancia entre dos unidades
    public function GetDistanceUnits takes unit u1, unit u2 returns real
        local real dx = GetUnitX(u2) - GetUnitX(u1)
        local real dy = GetUnitY(u2) - GetUnitY(u1)
        return SquareRoot(dx * dx + dy * dy)
    endfunction

    // 2. Obtener Distancia entre unidad y punto (XY)
    public function GetDistanceUnitXY takes unit u, real x, real y returns real
        local real dx = x - GetUnitX(u)
        local real dy = y - GetUnitY(u)
        return SquareRoot(dx * dx + dy * dy)
    endfunction

    // 3. Obtener Ángulo entre dos unidades (en grados)
    public function GetAngleBetweenUnits takes unit u1, unit u2 returns real
        return Atan2(GetUnitY(u2) - GetUnitY(u1), GetUnitX(u2) - GetUnitX(u1)) * RADTODEG
    endfunction
    
    // 4. Proyección de Puntos (Moverse "dist" distancia hacia un ángulo)
    // Retorna X
    public function ProjectX takes real x, real dist, real angle returns real
        return x + dist * Cos(angle * DEGTORAD)
    endfunction
    
    // Retorna Y
    public function ProjectY takes real y, real dist, real angle returns real
        return y + dist * Sin(angle * DEGTORAD)
    endfunction

    // ===================================================
    // CALCULADORA DE FÍSICA Y VELOCIDAD
    // ===================================================

    // 5. Reloj Global
    public function UpdateGameTime takes real delta returns nothing
        set GlobalGameTime = GlobalGameTime + delta
    endfunction

    public function GetGameTime takes nothing returns real
        return GlobalGameTime
    endfunction

    // Reloj de MAPA (absoluto): segundos transcurridos desde que el Master
    // despausa la partida (fin de la config), NO desde que arrancó el motor de
    // IA. Reusa MB_Timer (global plano de EXTRAS/tabla.j, arrancado en
    // InitTrig_tabla), el MISMO reloj que ya gobierna F9/kills/asistencias y que
    // el jugador ve en la tabla. Se congela con PauseGame EXACTAMENTE igual que
    // el contador de stock de las tiendas de WC3 => comparten el mismo cero.
    //
    // POR QUÉ existe, aparte de GetGameTime: GlobalGameTime solo avanza dentro
    // de MainLoop (desde StartEngine). En una partida que arranca SIN bots el
    // motor está apagado y GlobalGameTime queda en 0; si luego entra un bot por
    // takeover de voto, el reloj cuenta desde CERO en ese instante, desfasado
    // del reloj real del mapa. Eso hacía que el bot creyera que el retraso
    // inicial de un ítem (p.ej. armadura, 240s) aún no se cumplía aunque ya
    // estuviera en venta hace rato (síntoma: "NoShop Delay t=116 < 240s").
    //
    // REGLA: usar GetMapTime SOLO al comparar contra un tiempo ABSOLUTO del
    // mapa (retraso inicial de stock). Para deltas (cooldowns, ventanas,
    // throttles) seguir usando GetGameTime: son inmunes a dónde esté el cero.
    public function GetMapTime takes nothing returns real
        return TimerGetElapsed(MB_Timer)
    endfunction

    // ===================================================
    // 6a. API GENÉRICA: NIVEL DE EFECTO ESCALADO
    // ===================================================
    // Retorna el nivel efectivo de un efecto escalado sobre la unidad.
    // Cubre TANTO debuffs enemigos COMO buffs aliados.
    // Mecanismo A/B (TARGET/AOE): Lee de IA_Target_Memory (escrito por trigger).
    // Mecanismo C (AURA): Scan sobre AllHeroes[] con distancia matemática.
    //                     Toma el MAX nivel (auras no apilan, predomina mayor).
    //
    // Consumidor: GetAttackSpeedMod (Cat F), y en el futuro
    //             GetHeroEstimatedArmor, GetHeroWhiteDamage, etc.
    public function GetScaledEffectLevel takes unit victim, integer index returns integer
        local integer buffId = IADataBuffs_GetSDBuffId(index)
        local integer abilId = IADataBuffs_GetSDAbilId(index)
        local integer dtype  = IADataBuffs_GetSDType(index)
        local integer side   = IADataBuffs_GetSDSide(index)
        local integer storedLvl
        local integer maxLvl
        local integer lvl
        local integer i
        local unit hero
        local real auraRange

        // ¿La unidad tiene el buff/debuff activo?
        if GetUnitAbilityLevel(victim, buffId) == 0 then
            return 0 // Sin buff = sin efecto. Memoria inerte.
        endif

        if dtype == IADataBuffs_DEBUFF_TYPE_TARGET or dtype == IADataBuffs_DEBUFF_TYPE_AOE then
            // -----------------------------------------------
            // MECH A/B: Leer nivel desde IA_Target_Memory
            // (escrito por OnSpellEffect al momento del casteo)
            // -----------------------------------------------
            set storedLvl = LoadInteger(IA_Target_Memory, GetHandleId(victim), buffId)
            if storedLvl > 0 then
                return storedLvl
            endif
            // Fallback para AUTO-CAST (orb effects como Flechas de Hielo):
            // WC3 1.27b NO dispara EVENT_PLAYER_UNIT_SPELL_EFFECT cuando
            // la habilidad se usa en modo auto-cast. El Interceptor nunca
            // guarda el nivel, pero el buff SÍ aparece en la víctima.
            //
            // PRIORIDAD 1: Revisar último atacante (slot 4 de OnAttacked).
            // Si el último atacante tiene la habilidad, usar SU nivel exacto.
            // Esto resuelve el caso de múltiples héroes con la misma habilidad
            // a diferentes niveles (ej: Lich lvl 1 vs Sylvanas lvl 5).
            set hero = LoadUnitHandle(IA_Target_Memory, GetHandleId(victim), 4)
            if hero != null and not IsUnitType(hero, UNIT_TYPE_DEAD) then
                set lvl = GetUnitAbilityLevel(hero, abilId)
                if lvl > 0 then
                    return lvl
                endif
            endif
            // PRIORIDAD 2: Si el último atacante no tiene la habilidad,
            // escanear todos los héroes del bando correspondiente (max nivel).
            set maxLvl = 0
            set i = 0
            loop
                exitwhen i >= IACore_AllHeroCount
                set hero = IACore_AllHeroes[i]
                if not IsUnitType(hero, UNIT_TYPE_DEAD) then
                    if (side == IADataBuffs_EFFECT_SIDE_ENEMY and IsUnitEnemy(hero, GetOwningPlayer(victim))) or (side == IADataBuffs_EFFECT_SIDE_ALLY and IsUnitAlly(hero, GetOwningPlayer(victim))) then
                        set lvl = GetUnitAbilityLevel(hero, abilId)
                        if lvl > maxLvl then
                            set maxLvl = lvl
                        endif
                    endif
                endif
                set i = i + 1
            endloop
            if maxLvl > 0 then
                return maxLvl
            endif
            return 1 // Último recurso: ningún héroe vivo con la habilidad

        elseif dtype == IADataBuffs_DEBUFF_TYPE_AURA then
            // -----------------------------------------------
            // MECH C: Scan AllHeroes[] + Cache Híbrido
            // O(n), n ≤ 20. Predomina el mayor nivel.
            //
            // ANTI-DOBLE CONTEO: Si es aura ALIADA y la víctima
            // ES el emisor (tiene la habilidad), retornar 0.
            // El dueño se contabiliza en Cat C (RegisterASAura).
            //
            // MARGEN DE COLISIÓN: WC3 aplica auras considerando
            // Collision Size (~16-48 unidades). Añadimos +45
            // para evitar falsos negativos en el borde.
            //
            // CACHE RESIDUAL: Si la víctima sale del rango pero
            // el buff persiste (duración residual), leemos el
            // último nivel cacheado en IA_Target_Memory.
            // Limpieza: OnUnitDeath limpia keys de combate (0-4) selectivamente.
            // -----------------------------------------------
            if side == IADataBuffs_EFFECT_SIDE_ALLY and GetUnitAbilityLevel(victim, abilId) > 0 then
                return 0 // Dueño del aura: Cat C lo maneja.
            endif
            set maxLvl = 0
            set i = 0
            loop
                exitwhen i >= IACore_AllHeroCount
                set hero = IACore_AllHeroes[i]
                if not IsUnitType(hero, UNIT_TYPE_DEAD) then
                    if (side == IADataBuffs_EFFECT_SIDE_ENEMY and IsUnitEnemy(hero, GetOwningPlayer(victim))) or (side == IADataBuffs_EFFECT_SIDE_ALLY and IsUnitAlly(hero, GetOwningPlayer(victim))) then
                        set lvl = GetUnitAbilityLevel(hero, abilId)
                        if lvl > 0 and lvl > maxLvl then
                            set auraRange = IADataBuffs_GetAbilityAoEByLevel(abilId, lvl)
                            if GetDistanceUnits(victim, hero) <= auraRange + 45.0 then
                                set maxLvl = lvl
                            endif
                        endif
                    endif
                endif
                set i = i + 1
            endloop
            if maxLvl > 0 then
                // En rango: cachear nivel para uso residual
                call SaveInteger(IA_Target_Memory, GetHandleId(victim), buffId, maxLvl)
                return maxLvl
            endif
            // Fuera de rango: leer último nivel cacheado (buff residual)
            set storedLvl = LoadInteger(IA_Target_Memory, GetHandleId(victim), buffId)
            if storedLvl > 0 then
                return storedLvl
            endif
            return 0 // Sin fuente verificada: buff puede provenir de ítem aura
        endif

        return 0
    endfunction

    // 6b. Calculadora de Velocidad de Ataque Dinámica (Refactorizada)
    // Fuentes: Agilidad + Ítems(O(1)) + Habilidades(O(1)) + Buffs(O(1))
    public function GetAttackSpeedMod takes unit u returns real
        local real bonus = 0.0
        local integer i
        local item it
        local integer lvl
        local integer aid
        local integer bid
        // --- Conflicto BOae: Janggo ('ajen') y Aura de Resistencia ('AOae') ---
        // Comparten buff 'BOae'. El motor WC3 no los apila (toma el mayor).
        // Diferimos los 3 candidatos y sumamos solo el MAX al final.
        local boolean bOaeHasItem  = false  // ¿Janggo en mi inventario?
        local real    bOaeOwnerVal = 0.0    // Valor de Cat C (mi aura AOae)
        local real    bOaeAllyVal  = 0.0    // Valor de Cat F (aura aliada AOae)
        local integer bOaeAllyLvl  = 0      // Nivel detectado en Cat F
        local real    bOaeMax      = 0.0    // MAX final del conflicto BOae
        // Valor del ítem leído desde buffDb (fuente única de verdad: IA_Data_Buffs.j)
        // Si cambias el +18% del Janggo en IA_Data_Buffs.j, se propaga aquí solo.
        local real    bOaeItemVal  = IADataBuffs_GetBuffASMod('BOae')
        local integer j                     // Iterador interno para scan de inventarios aliados (Candidato 4)
        
        // ====================================================
        // A. ATRIBUTOS BASE: Agilidad Total * 0.02
        // ====================================================
        if IsUnitType(u, UNIT_TYPE_HERO) then
            set bonus = bonus + (GetHeroAgi(u, true) * 0.02)
        endif
        
        // ====================================================
        // B. INVENTARIO — Consulta O(1) via IADataItems
        // Nota: Ítems que aplican AS vía AURA/BUFF (ej. Janggo)
        // se contabilizan en la sección D para evitar doble conteo.
        // ====================================================
        set i = 0
        loop
            exitwhen i > 5
            set it = UnitItemInSlot(u, i)
            if it != null then
                set bonus = bonus + IADataItems_GetAttackSpeed(GetItemTypeId(it))
                // [BOae] Detectar Janggo en inventario
                if GetItemTypeId(it) == 'ajen' then
                    set bOaeHasItem = true
                endif
            endif
            set i = i + 1
        endloop
        
        // ====================================================
        // C. AURAS PROPIAS — Loop dinámico (Categoría 2)
        // Solo aplica si la unidad TIENE la habilidad de aura.
        // Los beneficiarios (aliados sin la habilidad) se manejan
        // en Cat F via GetScaledEffectLevel (nivel exacto).
        // ====================================================
        set i = 0
        loop
            exitwhen i >= IADataBuffs_GetASAuraCount()
            set aid = IADataBuffs_GetASAuraAbilId(i)
            set lvl = GetUnitAbilityLevel(u, aid)
            if lvl > 0 then
                // [BOae] Diferir AOae, sumar el resto normalmente
                if aid == 'AOae' then
                    set bOaeOwnerVal = IADataBuffs_GetAbilityASByLevel(aid, lvl)
                else
                    set bonus = bonus + IADataBuffs_GetAbilityASByLevel(aid, lvl)
                endif
            endif
            set i = i + 1
        endloop
        
        // ====================================================
        // D. SELF-BUFFS — Loop dinámico (Categoría 3)
        // Solo aplica si tiene la habilidad Y el buff activo.
        // ====================================================
        set i = 0
        loop
            exitwhen i >= IADataBuffs_GetASSelfCount()
            set aid = IADataBuffs_GetASSelfAbilId(i)
            set bid = IADataBuffs_GetASSelfBuffId(i)
            set lvl = GetUnitAbilityLevel(u, aid)
            if lvl > 0 and GetUnitAbilityLevel(u, bid) > 0 then
                set bonus = bonus + IADataBuffs_GetAbilityASByLevel(aid, lvl)
            endif
            set i = i + 1
        endloop
        
        // ====================================================
        // E. BUFFS SIMPLES — Loop dinámico (Categoría 1)
        // Chequea todos los buffs registrados con AS_MOD.
        // ====================================================
        set i = 0
        loop
            exitwhen i >= IADataBuffs_GetASBuffCount()
            set bid = IADataBuffs_GetASBuffId(i)
            if GetUnitAbilityLevel(u, bid) > 0 then
                // [BOae] Skip: se resuelve en el bloque de conflicto post-Cat F
                if bid != 'BOae' then
                    set bonus = bonus + IADataBuffs_GetBuffASMod(bid)
                endif
            endif
            set i = i + 1
        endloop
        
        // ====================================================
        // F. DEBUFFS ESCALADOS — Loop dinámico (Categoría 4)
        // Usa GetScaledDebuffLevel para leer el nivel exacto.
        // Solo procesa entradas cuyo campo sea ABIL_AS_LVL_BASE.
        // ====================================================
        set i = 0
        loop
            exitwhen i >= IADataBuffs_GetSDCount()
            if IADataBuffs_GetSDField(i) == IADataBuffs_ABIL_AS_LVL_BASE then
                set lvl = GetScaledEffectLevel(u, i)
                if lvl > 0 then
                    set aid = IADataBuffs_GetSDAbilId(i)
                    // [BOae] Diferir AOae aliada, sumar el resto normalmente
                    if aid == 'AOae' then
                        set bOaeAllyLvl = lvl
                        set bOaeAllyVal = IADataBuffs_GetAbilityASByLevel(aid, lvl)
                    else
                        set bonus = bonus + IADataBuffs_GetAbilityASByLevel(aid, lvl)
                    endif
                endif
            endif
            set i = i + 1
        endloop
        
        // ====================================================
        // F2. RESOLUCIÓN DE CONFLICTO BOae (Janggo vs AOae)
        // Mismo buff 'BOae' de 2 fuentes. Motor WC3 toma MAX.
        // Candidatos: ítem (bOaeItemVal), mi aura (nivel), aura aliada.
        // bOaeItemVal se lee de buffDb → si cambias el valor del Janggo
        // en IA_Data_Buffs.j, se propaga automáticamente aquí.
        // ====================================================
        if bOaeHasItem or bOaeOwnerVal > 0.0 or bOaeAllyVal > 0.0 or GetUnitAbilityLevel(u, 'BOae') > 0 then
            set bOaeMax = 0.0
            // Candidato 1: Janggo en MI inventario
            if bOaeHasItem then
                set bOaeMax = bOaeItemVal
            endif
            // Candidato 2: Mi propia aura AOae
            if bOaeOwnerVal > bOaeMax then
                set bOaeMax = bOaeOwnerVal
            endif
            // Candidato 3: Aura aliada AOae
            if bOaeAllyVal > bOaeMax then
                set bOaeMax = bOaeAllyVal
            endif
            // Candidato 4: Janggo de ALIADO (escaneo directo de inventarios)
            // NO podemos usar presencia de buff BOae para deducir Janggo aliado,
            // porque la propia aura AOae del héroe también genera BOae.
            // Solución: escanear inventarios de héroes aliados buscando 'ajen'.
            // Complejidad: O(n*6), n ≤ 20 héroes. Solo ejecuta si yo no tengo Janggo.
            if not bOaeHasItem then
                set i = 0
                loop
                    exitwhen i >= IACore_AllHeroCount
                    if IACore_AllHeroes[i] != u and IsUnitAlly(IACore_AllHeroes[i], GetOwningPlayer(u)) and not IsUnitType(IACore_AllHeroes[i], UNIT_TYPE_DEAD) then
                        set j = 0
                        loop
                            exitwhen j > 5
                            set it = UnitItemInSlot(IACore_AllHeroes[i], j)
                            if it != null and GetItemTypeId(it) == 'ajen' then
                                // Encontrado: comparar valor del Janggo contra MAX actual
                                if bOaeItemVal > bOaeMax then
                                    set bOaeMax = bOaeItemVal
                                endif
                                // Romper ambos loops (ya encontramos el Janggo)
                                set j = 6
                                set i = IACore_AllHeroCount - 1
                            endif
                            set j = j + 1
                        endloop
                    endif
                    set i = i + 1
                endloop
            endif
            set bonus = bonus + bOaeMax
        endif
        
        // ====================================================
        // G. CLAMP DEL MOTOR WC3: AS bonus entre -80% y +400%
        // Si bonus > 4.0, el motor ignora el excedente.
        // Si bonus < -0.80, la unidad no puede bajar de 20% AS.
        // ====================================================
        if bonus > 4.0 then
            return 4.0
        elseif bonus < -0.80 then
            return -0.80
        endif
        return bonus
    endfunction

    // 7. Cooldown Dinámico
    // Nota: GetAttackSpeedMod ya retorna clamped [-0.80, 4.0],
    // por lo que el divisor mínimo es 1 + (-0.80) = 0.20 automáticamente.
    public function GetUnitAttackCooldown takes unit u returns real
        local real baseCd = IAData_GetHeroBaseCooldown(u)
        local real mod = 1.0 + GetAttackSpeedMod(u)
        return baseCd / mod
    endfunction

    // 8. Damage Point Dinámico
    public function GetUnitDamagePoint takes unit u returns real
        local real dmgPt = IAData_GetHeroDamagePoint(u)
        local real mod = 1.0 + GetAttackSpeedMod(u)
        return dmgPt / mod
    endfunction



    // 9. Tiempo de Viaje de Proyectil
    public function GetProjectileTravelTime takes unit source, unit target returns real
        local real speed = IAData_GetHeroProjectileSpeed(source)
        if speed <= 0.0 then
            return 0.0 // Instantáneo o Melee
        endif
        return GetDistanceUnits(source, target) / speed
    endfunction

    // ===================================================
    // [DEBUG_IA] SISTEMA DE MENSAJES POR BOT (Texttags apilados)
    // ===================================================
    // Cada bot tiene una "columna" de hasta IA_DEBUG_MAX text tags
    // FLOTANDO sobre su cabeza. Slot 0 = el más nuevo, arriba.
    // Slot N-1 = el más viejo, abajo. Los tags SIGUEN al héroe cada
    // tick (no se quedan flotando en el aire donde nacieron).
    //
    // Reglas:
    //   1) Máximo IA_DEBUG_MAX mensajes simultáneos. Si llega el N+1,
    //      el más viejo (último de la columna) se destruye y los demás
    //      bajan una posición.
    //   2) TTL IA_DEBUG_TTL segundos por mensaje: al cumplirse, su tag
    //      se destruye y la columna se compacta.
    //
    // NO usamos multiboard: WC3 1.27 sólo muestra UNA multiboard activa
    // a la vez y el slot ya lo ocupa la tabla de kills/muertes/asists.
    //
    // Buffer (hashtable IA_Debug_Memory, key = handleId del bot):
    //   key  0          : integer count (0..MAX)
    //   keys 100..114   : string  msg (texto BASE, sin el contador)
    //   keys 200..214   : real    expireTime (GlobalGameTime + TTL)
    //   keys 300..314   : texttag handle
    //   keys 400..414   : integer repeticiones (>=1; se muestra como "xN")
    //
    // COALESCENCIA (anti-spam): si el mensaje entrante es idéntico al
    // más nuevo (slot 0), NO se crea línea nueva: se incrementa su
    // contador "xN" y se refresca su TTL. Así un mensaje que se repite
    // 10 veces ocupa 1 sola línea ("x10 ...") en vez de 10. Solo
    // coalesce contra el slot 0: si entre medio aparece otro mensaje
    // distinto, la siguiente repetición arranca una línea nueva.
    //
    // Grupo IA_DebugActiveBots: bots con al menos 1 tag vivo. Iterado
    // cada 0.10s para reposicionar y expirar.

    globals
        public constant integer IA_DEBUG_MAX = 15
        public constant real    IA_DEBUG_TTL = 10.0
        public hashtable IA_Debug_Memory = InitHashtable()

        // Layout visual (ajustar a gusto)
        private constant real IA_DEBUG_OFFSET_X = 0.0    // 0 = sobre la cabeza; +X = derecha, -X = izquierda
        private constant real IA_DEBUG_BASE_Z   = 280.0  // altura del tag más nuevo (slot 0)
        private constant real IA_DEBUG_ROW_Z    = 28.0   // separación vertical entre filas
        private constant real IA_DEBUG_TEXT_SZ  = 0.015  // bajado de 0.020: WC3 1.27 parte (wrap) el texttag largo en 2 renglones (el 2º pierde el "xN" y se solapa con el slot de abajo). Texto más chico = más caracteres por renglón = no se parte. Tunear in-game si hace falta.

        private group IA_DebugActiveBots = null
    endglobals

    // Antepone el contador de repeticiones "xN " al mensaje base.
    // SIEMPRE se muestra (incluso N=1: "x1 ..."). El contador va
    // coloreado a la izquierda; el mensaje conserva el color del tag.
    private function DebugFormat takes string msg, integer n returns string
        return "|cff7CFC00x" + I2S(n) + "|r " + msg
    endfunction

    // Coloca/recoloca un tag a su posición lógica (encima del héroe,
    // desplazado por su índice de fila).
    private function DebugPlaceTag takes texttag t, real hx, real hy, integer slot returns nothing
        if t == null then
            return
        endif
        call SetTextTagPos(t, hx + IA_DEBUG_OFFSET_X, hy, IA_DEBUG_BASE_Z - slot * IA_DEBUG_ROW_Z)
    endfunction

    // Inserta msg en slot 0. Si la columna está llena, destruye el slot
    // más viejo. Recoloca todo después del shift.
    private function DebugBufferPush takes unit u, string msg returns nothing
        local integer hId = GetHandleId(u)
        local integer count = LoadInteger(IA_Debug_Memory, hId, 0)
        local integer i
        local integer n
        local texttag oldest
        local texttag t
        local real hx = GetUnitX(u)
        local real hy = GetUnitY(u)

        // COALESCENCIA: ¿el mensaje es idéntico al más nuevo (slot 0)?
        // → solo subimos su contador "xN" y refrescamos su TTL. NO se
        //   crea línea nueva ni se desplaza nada.
        if count > 0 and LoadStr(IA_Debug_Memory, hId, 100) == msg then
            set n = LoadInteger(IA_Debug_Memory, hId, 400) + 1
            call SaveInteger(IA_Debug_Memory, hId, 400, n)
            call SaveReal(IA_Debug_Memory, hId, 200, GlobalGameTime + IA_DEBUG_TTL)
            set t = LoadTextTagHandle(IA_Debug_Memory, hId, 300)
            if t != null then
                call SetTextTagText(t, DebugFormat(msg, n), IA_DEBUG_TEXT_SZ)
            endif
            set t = null
            return
        endif

        // Buffer lleno → matar el más viejo (slot count-1) y bajar count
        if count >= IA_DEBUG_MAX then
            set oldest = LoadTextTagHandle(IA_Debug_Memory, hId, 300 + IA_DEBUG_MAX - 1)
            if oldest != null then
                call DestroyTextTag(oldest)
            endif
            set count = IA_DEBUG_MAX - 1
            set oldest = null
        endif

        // Shift slot i → slot i+1 (de count-1 hacia 0)
        set i = count - 1
        loop
            exitwhen i < 0
            call SaveStr(IA_Debug_Memory, hId, 100 + i + 1, LoadStr(IA_Debug_Memory, hId, 100 + i))
            call SaveReal(IA_Debug_Memory, hId, 200 + i + 1, LoadReal(IA_Debug_Memory, hId, 200 + i))
            call SaveTextTagHandle(IA_Debug_Memory, hId, 300 + i + 1, LoadTextTagHandle(IA_Debug_Memory, hId, 300 + i))
            call SaveInteger(IA_Debug_Memory, hId, 400 + i + 1, LoadInteger(IA_Debug_Memory, hId, 400 + i))
            set i = i - 1
        endloop

        // Crear tag nuevo en slot 0 (contador en 1 → "x1 ...")
        set t = CreateTextTag()
        call SetTextTagText(t, DebugFormat(msg, 1), IA_DEBUG_TEXT_SZ)
        call SetTextTagColor(t, 255, 220, 60, 255)
        call SetTextTagVisibility(t, true)
        call SetTextTagPermanent(t, true) // controlamos nosotros la vida
        call DebugPlaceTag(t, hx, hy, 0)

        call SaveStr(IA_Debug_Memory, hId, 100, msg) // texto BASE (sin "xN")
        call SaveReal(IA_Debug_Memory, hId, 200, GlobalGameTime + IA_DEBUG_TTL)
        call SaveTextTagHandle(IA_Debug_Memory, hId, 300, t)
        call SaveInteger(IA_Debug_Memory, hId, 400, 1)
        call SaveInteger(IA_Debug_Memory, hId, 0, count + 1)

        // Recolocar los desplazados (slot 1..count) sobre el héroe
        set i = 1
        loop
            exitwhen i > count
            call DebugPlaceTag(LoadTextTagHandle(IA_Debug_Memory, hId, 300 + i), hx, hy, i)
            set i = i + 1
        endloop

        // Marcar bot como activo (set: GroupAddUnit no duplica si ya está)
        call GroupAddUnit(IA_DebugActiveBots, u)
        set t = null
    endfunction

    // Destruye todos los tags y limpia el buffer de la unidad.
    private function DebugClearAll takes unit u returns nothing
        local integer hId = GetHandleId(u)
        local integer count = LoadInteger(IA_Debug_Memory, hId, 0)
        local integer i = 0
        local texttag t
        loop
            exitwhen i >= count
            set t = LoadTextTagHandle(IA_Debug_Memory, hId, 300 + i)
            if t != null then
                call DestroyTextTag(t)
            endif
            set i = i + 1
        endloop
        call FlushChildHashtable(IA_Debug_Memory, hId)
        set t = null
    endfunction

    // Tick por bot activo: expira los vencidos, compacta huecos,
    // y reposiciona los supervivientes sobre la cabeza del héroe.
    private function DebugUpdateUnit takes unit u returns nothing
        local integer hId
        local integer count
        local integer i
        local integer kept = 0
        local real now = GlobalGameTime
        local real hx
        local real hy
        local texttag t

        if GetUnitTypeId(u) == 0 then
            // Unidad inválida → limpieza defensiva y sale del grupo
            call GroupRemoveUnit(IA_DebugActiveBots, u)
            return
        endif

        set hId = GetHandleId(u)
        set count = LoadInteger(IA_Debug_Memory, hId, 0)
        if count <= 0 then
            call GroupRemoveUnit(IA_DebugActiveBots, u)
            return
        endif

        set hx = GetUnitX(u)
        set hy = GetUnitY(u)

        // Recorre slot 0..count-1; supervivientes se compactan al
        // principio. (Los más nuevos están en slot 0, así que el orden
        // por antigüedad se conserva al compactar de izq a der.)
        set i = 0
        loop
            exitwhen i >= count
            if LoadReal(IA_Debug_Memory, hId, 200 + i) <= now then
                set t = LoadTextTagHandle(IA_Debug_Memory, hId, 300 + i)
                if t != null then
                    call DestroyTextTag(t)
                endif
            else
                if i != kept then
                    call SaveStr(IA_Debug_Memory, hId, 100 + kept, LoadStr(IA_Debug_Memory, hId, 100 + i))
                    call SaveReal(IA_Debug_Memory, hId, 200 + kept, LoadReal(IA_Debug_Memory, hId, 200 + i))
                    call SaveTextTagHandle(IA_Debug_Memory, hId, 300 + kept, LoadTextTagHandle(IA_Debug_Memory, hId, 300 + i))
                    call SaveInteger(IA_Debug_Memory, hId, 400 + kept, LoadInteger(IA_Debug_Memory, hId, 400 + i))
                endif
                set kept = kept + 1
            endif
            set i = i + 1
        endloop

        // Limpiar slots residuales (kept..count-1)
        set i = kept
        loop
            exitwhen i >= count
            call RemoveSavedString(IA_Debug_Memory, hId, 100 + i)
            call RemoveSavedReal(IA_Debug_Memory, hId, 200 + i)
            call RemoveSavedHandle(IA_Debug_Memory, hId, 300 + i)
            call RemoveSavedInteger(IA_Debug_Memory, hId, 400 + i)
            set i = i + 1
        endloop
        call SaveInteger(IA_Debug_Memory, hId, 0, kept)

        // Reposicionar supervivientes
        set i = 0
        loop
            exitwhen i >= kept
            call DebugPlaceTag(LoadTextTagHandle(IA_Debug_Memory, hId, 300 + i), hx, hy, i)
            set i = i + 1
        endloop

        if kept == 0 then
            call GroupRemoveUnit(IA_DebugActiveBots, u)
        endif

        set t = null
    endfunction

    private function DebugTickEnum takes nothing returns nothing
        call DebugUpdateUnit(GetEnumUnit())
    endfunction

    // Timer 0.10s: barrido de bots con tags activos.
    private function DebugTick takes nothing returns nothing
        call ForGroup(IA_DebugActiveBots, function DebugTickEnum)
    endfunction

    // --- API pública (drop-in: los 47 call sites no cambian) ---
    public function DebugMsg takes unit u, string msg returns nothing
        if u == null or GetUnitTypeId(u) == 0 then
            return
        endif
        call DebugBufferPush(u, msg)
    endfunction

    // ===================================================
    // [DEBUG_IA] MENSAJE DE TOLERANCIA PERMANENTE
    // ===================================================
    public function UpdateToleranceTag takes unit u, string msg returns nothing
        // Obtenemos el text tag de la unidad usando el índice 2 de la memoria de targets
        local texttag tt = LoadTextTagHandle(IA_Target_Memory, GetHandleId(u), 2)
        
        if tt == null then
            set tt = CreateTextTag()
            call SaveTextTagHandle(IA_Target_Memory, GetHandleId(u), 2, tt)
            call SetTextTagColor(tt, 150, 255, 150, 255) // Verde Claro
            call SetTextTagVisibility(tt, true)
            call SetTextTagPermanent(tt, true) // No desaparece
        endif
        
        call SetTextTagText(tt, msg, 0.018)
        // Posicionarlo exactamente al centro del héroe (Z = 80 para la cabeza)
        call SetTextTagPos(tt, GetUnitX(u), GetUnitY(u), 80.0)
        set tt = null
    endfunction

    // ===================================================
    // SISTEMA DE RASTREO DE AGGRO (CERTEZA ABSOLUTA)
    // ===================================================
    globals
        hashtable IA_Target_Memory = InitHashtable()
    endglobals

    // Función que nos dice a quién tiene INTENCIÓN de atacar (Orden)
    public function GetUnitTarget takes unit attacker returns unit
        return LoadUnitHandle(IA_Target_Memory, GetHandleId(attacker), 0)
    endfunction

    // Función que nos dice a quién YA ESTÁ ATACANDO FÍSICAMENTE (Inició animación)
    public function GetUnitPhysicalTarget takes unit attacker returns unit
        return LoadUnitHandle(IA_Target_Memory, GetHandleId(attacker), 1)
    endfunction

    private function OnTargetOrder takes nothing returns nothing
        // Guarda en la RAM el objetivo de cualquier "attack" o "smart" (Click derecho)
        call SaveUnitHandle(IA_Target_Memory, GetHandleId(GetTriggerUnit()), 0, GetOrderTargetUnit())
    endfunction

    private function OnPointOrder takes nothing returns nothing
        // Si hace un movimiento normal (o un a-move libre), pierde su objetivo y certeza física
        call RemoveSavedHandle(IA_Target_Memory, GetHandleId(GetTriggerUnit()), 0)
        call RemoveSavedHandle(IA_Target_Memory, GetHandleId(GetTriggerUnit()), 1)
    endfunction

    private function OnNoTargetOrder takes nothing returns nothing
        // Si aprieta "Stop" (851972) u otro, también pierde su focus absoluto
        call RemoveSavedHandle(IA_Target_Memory, GetHandleId(GetTriggerUnit()), 0)
        call RemoveSavedHandle(IA_Target_Memory, GetHandleId(GetTriggerUnit()), 1)
    endfunction

    private function OnAttacked takes nothing returns nothing
        // Cuando un creep ataca o le pega a alguien accidentalmente por aggro de proximidad (auto-acquire), 
        // ¡Registra el target al instante! (Esta es la pieza clave para la certeza absoluta física)
        call SaveUnitHandle(IA_Target_Memory, GetHandleId(GetAttacker()), 0, GetTriggerUnit()) // También guardamos la intención por si no hubo click explícito
        call SaveUnitHandle(IA_Target_Memory, GetHandleId(GetAttacker()), 1, GetTriggerUnit()) // Certeza física (Índice 1)
        // Relación inversa: víctima → último atacante (Índice 4)
        // Usado por GetScaledEffectLevel como fallback para auto-cast.
        // Permite saber QUIÉN atacó a la víctima y leer SU nivel exacto.
        call SaveUnitHandle(IA_Target_Memory, GetHandleId(GetTriggerUnit()), 4, GetAttacker())
    endfunction

    // --- Limpiador de Memoria (SELECTIVO) ---
    // IMPORTANTE: NO usar FlushChildHashtable sobre IA_Target_Memory aquí.
    // Borraría las keys de Shopping (100-119) y los héroes reviven
    // necesitando conservar su cola de compras intacta.
    // En IA_Target_Memory limpiamos solo: Aggro Tracker (0-4) y TextTag (2).
    // En IA_Debug_Memory sí podemos flushear: hashtable dedicado al debug,
    // no contiene Shopping. DebugClearAll destruye también los texttag handles.
    private function OnUnitDeath takes nothing returns nothing
        local unit dying = GetTriggerUnit()
        local integer hId = GetHandleId(dying)
        local texttag tt = LoadTextTagHandle(IA_Target_Memory, hId, 2)
        if tt != null then
            call DestroyTextTag(tt)
        endif
        call RemoveSavedHandle(IA_Target_Memory, hId, 0)  // Target intención
        call RemoveSavedHandle(IA_Target_Memory, hId, 1)  // Target físico
        call RemoveSavedHandle(IA_Target_Memory, hId, 2)  // TextTag handle (tolerancia)
        call RemoveSavedHandle(IA_Target_Memory, hId, 4)  // Último atacante
        // Keys 100-119 (Shopping) se PRESERVAN intencionalmente.

        // Debug: destruye todos los texttags apilados y vacía el buffer.
        call DebugClearAll(dying)
        call GroupRemoveUnit(IA_DebugActiveBots, dying)

        set tt = null
        set dying = null
    endfunction

    // ===================================================
    // INTERCEPTOR DE HECHIZOS (Mech A + B)
    // ===================================================
    // Dispara con EVENT_PLAYER_UNIT_SPELL_EFFECT.
    // Guarda el nivel de la habilidad del caster en la memoria
    // de cada víctima afectada. Solo procesa habilidades
    // registradas en sdRegistry.
    private function OnSpellEffect takes nothing returns nothing
        local unit caster = GetTriggerUnit()
        local integer abilId = GetSpellAbilityId()
        local unit target = GetSpellTargetUnit()
        local integer i = 0
        local integer sdIdx = -1
        local integer buffId
        local integer dtype
        local integer lvl
        local real aoe
        local real cx
        local real cy
        local unit enumUnit

        // Buscar la habilidad en el registro de efectos escalados
        loop
            exitwhen i >= IADataBuffs_GetSDCount()
            if IADataBuffs_GetSDAbilId(i) == abilId then
                set dtype = IADataBuffs_GetSDType(i)
                if dtype == IADataBuffs_DEBUFF_TYPE_TARGET or dtype == IADataBuffs_DEBUFF_TYPE_AOE then
                    set sdIdx = i
                    exitwhen true
                endif
            endif
            set i = i + 1
        endloop

        // Si no encontramos la habilidad en el registro, salir
        if sdIdx < 0 then
            set caster = null
            set target = null
            return
        endif

        set buffId = IADataBuffs_GetSDBuffId(sdIdx)
        set lvl = GetUnitAbilityLevel(caster, abilId)
        set dtype = IADataBuffs_GetSDType(sdIdx)

        if dtype == IADataBuffs_DEBUFF_TYPE_TARGET and target != null then
            // -----------------------------------------------
            // MECH A: Target directo — 1 SaveInteger
            // -----------------------------------------------
            call SaveInteger(IA_Target_Memory, GetHandleId(target), buffId, lvl)

        elseif dtype == IADataBuffs_DEBUFF_TYPE_AOE then
            // -----------------------------------------------
            // MECH B: AoE — GroupEnum en trigger (PERMITIDO)
            // Atrapa todo: héroes, creeps, invocaciones.
            // -----------------------------------------------
            set aoe = IADataBuffs_GetAbilityAoEByLevel(abilId, lvl)
            if target != null then
                // Algunos AoE se lanzan "sobre" una unidad
                set cx = GetUnitX(target)
                set cy = GetUnitY(target)
            else
                // Point-target o self-cast
                set cx = GetSpellTargetX()
                set cy = GetSpellTargetY()
                // Self-cast safety: si X/Y son 0, usar posición del caster
                if cx == 0.0 and cy == 0.0 then
                    set cx = GetUnitX(caster)
                    set cy = GetUnitY(caster)
                endif
            endif

            call GroupClear(ENUM_GROUP)
            call GroupEnumUnitsInRange(ENUM_GROUP, cx, cy, aoe, null)
            loop
                set enumUnit = FirstOfGroup(ENUM_GROUP)
                exitwhen enumUnit == null
                call GroupRemoveUnit(ENUM_GROUP, enumUnit)
                // Filtrar por bando: ENEMY → enemigos del caster, ALLY → aliados del caster
                if not IsUnitType(enumUnit, UNIT_TYPE_DEAD) then
                    if (IADataBuffs_GetSDSide(sdIdx) == IADataBuffs_EFFECT_SIDE_ENEMY and IsUnitEnemy(enumUnit, GetOwningPlayer(caster))) or (IADataBuffs_GetSDSide(sdIdx) == IADataBuffs_EFFECT_SIDE_ALLY and IsUnitAlly(enumUnit, GetOwningPlayer(caster))) then
                        call SaveInteger(IA_Target_Memory, GetHandleId(enumUnit), buffId, lvl)
                    endif
                endif
            endloop
        endif



        set caster = null
        set target = null
        set enumUnit = null
    endfunction

    public function InitTargetTracker takes nothing returns nothing
        local trigger tTarget = CreateTrigger()
        local trigger tPoint = CreateTrigger()
        local trigger tNoTarget = CreateTrigger()
        local trigger tAtk = CreateTrigger()
        local trigger tDeath = CreateTrigger()
        local trigger tSpell = CreateTrigger()
        local integer i = 0

        // Inicializar grupo reutilizable global
        set ENUM_GROUP = CreateGroup()
        // Grupo de bots con texttags de debug activos
        set IA_DebugActiveBots = CreateGroup()

        // Registramos eventos para todos los 16 jugadores (incluyendo Neutrales Hostiles)
        loop
            exitwhen i > 15
            call TriggerRegisterPlayerUnitEvent(tTarget, Player(i), EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, null)
            call TriggerRegisterPlayerUnitEvent(tPoint, Player(i), EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, null)
            call TriggerRegisterPlayerUnitEvent(tNoTarget, Player(i), EVENT_PLAYER_UNIT_ISSUED_ORDER, null)
            call TriggerRegisterPlayerUnitEvent(tAtk, Player(i), EVENT_PLAYER_UNIT_ATTACKED, null)
            call TriggerRegisterPlayerUnitEvent(tDeath, Player(i), EVENT_PLAYER_UNIT_DEATH, null)
            call TriggerRegisterPlayerUnitEvent(tSpell, Player(i), EVENT_PLAYER_UNIT_SPELL_EFFECT, null)
            set i = i + 1
        endloop

        call TriggerAddAction(tTarget, function OnTargetOrder)
        call TriggerAddAction(tPoint, function OnPointOrder)
        call TriggerAddAction(tNoTarget, function OnNoTargetOrder)
        call TriggerAddAction(tAtk, function OnAttacked)
        call TriggerAddAction(tDeath, function OnUnitDeath)
        call TriggerAddAction(tSpell, function OnSpellEffect)

        // Tick de debug (reposiciona tags + expira los vencidos)
        call TimerStart(CreateTimer(), 0.10, true, function DebugTick)
    endfunction

endlibrary