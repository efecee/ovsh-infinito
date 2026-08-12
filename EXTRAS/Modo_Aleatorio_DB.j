// ==========================================================================
// Modo_Aleatorio_DB.j — Catálogo de Habilidades para el Modo Aleatorio
// ==========================================================================
//
// PROPÓSITO:
//   Registrar TODAS las habilidades de héroe del mapa, organizadas por
//   su posición de columna en la barra de comandos (slot 0-3).
//   El sistema de Modo Aleatorio usa estos pools para sortear habilidades
//   respetando la regla: "cada habilidad solo se intercambia con otra
//   de la MISMA columna".
//
// SEPARACIÓN DE RESPONSABILIDADES:
//   - Este archivo:       ¿DÓNDE va la habilidad? (slot/columna)
//   - IA_Data_Buffs.j:    ¿CUÁNTO modifica? (datos numéricos)
//   Ambos pueden registrar la misma habilidad. Sin acoplamiento.
//
// CONVENCIÓN DE SLOTS:
//   Los slots usan el número del editor de WC3 (0-3), pero las constantes
//   se nombran por la tecla del jugador para legibilidad:
//
//   | Editor | Tecla | Constante | Descripción                    |
//   |--------|-------|-----------|--------------------------------|
//   |   0    |  Q    | SLOT_Q    | Habilidad normal (10 niveles)  |
//   |   1    |  W    | SLOT_W    | Habilidad normal (10 niveles)  |
//   |   2    |  E    | SLOT_E    | Habilidad normal (10 niveles)  |
//   |   3    |  R    | SLOT_R    | Ultimate (6 niveles)           |
//
//   Regla: Una habilidad con SLOT_Q solo puede ser reemplazada por
//   otra habilidad con SLOT_Q. Las ultis solo se intercambian con ultis.
//
// CÓMO AGREGAR UNA HABILIDAD:
//   1. Identifica su rawcode ('AHfa', 'AEsf', etc.)
//   2. Abre el editor de WC3 → Habilidad → mira la columna del botón
//      en la ÚLTIMA fila de la tarjeta de comando (Ubtn/Button Position Y=2).
//   3. Llama a RegisterAbil con el rawcode y la constante SLOT_X.
//   4. Listo. No necesitas tocar IA_Data_Buffs.j ni IA_Utils.j.
//
// ==========================================================================

library ModoAleatorio initializer OnInit

    globals
        // ==============================
        // CONSTANTES DE SLOT (posición de columna)
        // El valor numérico coincide con el del editor de WC3.
        // ==============================
        constant integer SLOT_Q = 0   // Columna 0 — Tecla Q
        constant integer SLOT_W = 1   // Columna 1 — Tecla W
        constant integer SLOT_E = 2   // Columna 2 — Tecla E
        constant integer SLOT_R = 3   // Columna 3 — Tecla R (Ultimate)

        // ==============================
        // POOLS DE HABILIDADES (1 array por slot)
        // Cada pool es un array de rawcodes de habilidad.
        // El sorteo elige aleatoriamente de cada pool.
        // ==============================
        integer array AbilPool_Q        // Habilidades de columna Q
        integer       AbilPool_Q_Count = 0

        integer array AbilPool_W        // Habilidades de columna W
        integer       AbilPool_W_Count = 0

        integer array AbilPool_E        // Habilidades de columna E
        integer       AbilPool_E_Count = 0

        integer array AbilPool_R        // Habilidades de columna R (Ultis)
        integer       AbilPool_R_Count = 0

        // ==============================
        // TOME SYSTEM — Estado Global
        // ==============================
        private hashtable heroDb = null        // heroId → slot → abilId asignado
        //                                      // abilId, 99 → boolean (tomada globalmente)
        //                                      // abilId, 100 → integer (faccion: 1=humano, 2=orco)
        //                                      // abilId, 101 → boolean (solo rango)
        boolean   ModoAl_Activo = false        // ¿Modo aleatorio activado?
        private constant integer SLOT_FIJA   = 4
        private constant integer ABIL_FIJA   = 'A023'
        private constant integer MAX_LVL_QWE = 10
        private constant integer MAX_LVL_R   = 6
        private constant integer MAX_LVL_FIJA = 10
        private constant integer ITEM_TOME   = 'I001'
        private constant integer TAG_FACTION  = 100
        private constant integer TAG_RANGED   = 101
        private constant integer TAG_TAKEN    = 99
        // PITY DE LA ULTIMATE (R): contador por héroe de mejoras seguidas
        // que NO subieron la R. Al llegar al umbral, el siguiente tiro la fuerza.
        private constant integer KEY_R_PITY       = 5   // heroId → fallos seguidos sin subir la R
        private constant integer R_PITY_THRESHOLD = 10  // fallos antes de forzar la R (11º tiro = R asegurada)
    endglobals

    // ==============================
    // REGISTRO (función única para todos los slots)
    // ==============================
    // Ejemplo: call RegisterAbil('AHfa', SLOT_Q)
    //          call RegisterAbil('AEsf', SLOT_R)
    public function RegisterAbil takes integer abilId, integer slot returns nothing
        if slot == SLOT_Q then
            set AbilPool_Q[AbilPool_Q_Count] = abilId
            set AbilPool_Q_Count = AbilPool_Q_Count + 1
        elseif slot == SLOT_W then
            set AbilPool_W[AbilPool_W_Count] = abilId
            set AbilPool_W_Count = AbilPool_W_Count + 1
        elseif slot == SLOT_E then
            set AbilPool_E[AbilPool_E_Count] = abilId
            set AbilPool_E_Count = AbilPool_E_Count + 1
        elseif slot == SLOT_R then
            set AbilPool_R[AbilPool_R_Count] = abilId
            set AbilPool_R_Count = AbilPool_R_Count + 1
        endif
    endfunction

    // Marcar habilidad como exclusiva de facción (1 = humanos, 2 = orcos)
    private function TagFaction takes integer abilId, integer faction returns nothing
        call SaveInteger(heroDb, abilId, TAG_FACTION, faction)
    endfunction

    // Marcar habilidad como exclusiva de héroes de rango
    private function TagRanged takes integer abilId returns nothing
        call SaveBoolean(heroDb, abilId, TAG_RANGED, true)
    endfunction

    // Validar si una habilidad puede ser asignada a un héroe:
    //   - No tomada globalmente (unicidad)
    //   - Facción correcta (humanos 0-4, orcos 5-9)
    //   - Rango correcto (si es solo rango)
    //   - El héroe no la tiene ya
    private function IsAbilValid takes integer abilId, unit hero returns boolean
        local integer pid = GetPlayerId(GetOwningPlayer(hero))
        local integer faction
        // Ya tomada por otro héroe?
        if LoadBoolean(heroDb, abilId, TAG_TAKEN) then
            return false
        endif
        // Ya la tiene este héroe?
        if GetUnitAbilityLevel(hero, abilId) > 0 then
            return false
        endif
        // Restricción de facción?
        if HaveSavedInteger(heroDb, abilId, TAG_FACTION) then
            set faction = LoadInteger(heroDb, abilId, TAG_FACTION)
            if faction == 1 and pid > 4 then
                return false
            endif
            if faction == 2 and pid < 5 then
                return false
            endif
        endif
        // Restricción de rango?
        if LoadBoolean(heroDb, abilId, TAG_RANGED) then
            if not IsUnitType(hero, UNIT_TYPE_RANGED_ATTACKER) then
                return false
            endif
        endif
        return true
    endfunction

    // ==============================
    // API DE CONSULTA
    // ==============================
    public function GetPoolCount takes integer slot returns integer
        if slot == SLOT_Q then
            return AbilPool_Q_Count
        elseif slot == SLOT_W then
            return AbilPool_W_Count
        elseif slot == SLOT_E then
            return AbilPool_E_Count
        elseif slot == SLOT_R then
            return AbilPool_R_Count
        endif
        return 0
    endfunction

    public function GetAbilId takes integer slot, integer index returns integer
        if slot == SLOT_Q then
            return AbilPool_Q[index]
        elseif slot == SLOT_W then
            return AbilPool_W[index]
        elseif slot == SLOT_E then
            return AbilPool_E[index]
        elseif slot == SLOT_R then
            return AbilPool_R[index]
        endif
        return 0
    endfunction

    // ==============================
    // TOME SYSTEM — Funciones
    // ==============================

    // Remueve TODAS las habilidades de un pool del héroe (escopeta)
    public function RemoveHeroSlotAbility takes unit hero, integer slot returns integer
        local integer count = GetPoolCount(slot)
        local integer i = 0
        local integer abilId
        loop
            exitwhen i >= count
            set abilId = GetAbilId(slot, i)
            call UnitRemoveAbility(hero, abilId)
            set i = i + 1
        endloop
        return 0
    endfunction

    // Oculta TODAS las habilidades de todos los pools + A023 para un jugador
    public function HideAllAbilities takes player p returns nothing
        local integer i
        local integer count
        set i = 0
        set count = AbilPool_Q_Count
        loop
            exitwhen i >= count
            call SetPlayerAbilityAvailable(p, AbilPool_Q[i], false)
            set i = i + 1
        endloop
        set i = 0
        set count = AbilPool_W_Count
        loop
            exitwhen i >= count
            call SetPlayerAbilityAvailable(p, AbilPool_W[i], false)
            set i = i + 1
        endloop
        set i = 0
        set count = AbilPool_E_Count
        loop
            exitwhen i >= count
            call SetPlayerAbilityAvailable(p, AbilPool_E[i], false)
            set i = i + 1
        endloop
        set i = 0
        set count = AbilPool_R_Count
        loop
            exitwhen i >= count
            call SetPlayerAbilityAvailable(p, AbilPool_R[i], false)
            set i = i + 1
        endloop
    endfunction

    // ¿El héroe ya tiene habilidad asignada en este slot?
    public function HeroHasSlot takes unit hero, integer slot returns boolean
        return HaveSavedInteger(heroDb, GetHandleId(hero), slot)
    endfunction

    // Cuenta cuántos slots tiene llenos (0 a 5)
    public function GetFilledCount takes unit hero returns integer
        local integer c = 0
        local integer hId = GetHandleId(hero)
        if HaveSavedInteger(heroDb, hId, SLOT_Q) then
            set c = c + 1
        endif
        if HaveSavedInteger(heroDb, hId, SLOT_W) then
            set c = c + 1
        endif
        if HaveSavedInteger(heroDb, hId, SLOT_E) then
            set c = c + 1
        endif
        if HaveSavedInteger(heroDb, hId, SLOT_R) then
            set c = c + 1
        endif
        if HaveSavedInteger(heroDb, hId, SLOT_FIJA) then
            set c = c + 1
        endif
        return c
    endfunction

    // Inicializa un héroe para modo aleatorio:
    //   - Remueve originales Q/W/E/R
    //   - Oculta todo (incluyendo A023)
    //   - Quita skill point inicial
    //   - Da 1 madera
    public function InitHeroForRandomMode takes unit hero returns nothing
        local player p = GetOwningPlayer(hero)
        call RemoveHeroSlotAbility(hero, SLOT_Q)
        call RemoveHeroSlotAbility(hero, SLOT_W)
        call RemoveHeroSlotAbility(hero, SLOT_E)
        call RemoveHeroSlotAbility(hero, SLOT_R)
        call UnitRemoveAbility(hero, ABIL_FIJA)
        call UnitModifySkillPoints(hero, -1)
        call SetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER, GetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER) + 1)
        set p = null
    endfunction

    // ==============================
    // ALGORITMO PRINCIPAL: Llamado al comprar I001
    // ==============================
    // FASE 1 (slots < 5): Llena Q, W, E, A023 al azar. R siempre es la última (5ta compra).
    // FASE 2 (slots == 5): Mejora ponderada con fuerza bruta.
    public function OnTomeAcquired takes unit hero returns nothing
        local integer filled = GetFilledCount(hero)
        local integer hId = GetHandleId(hero)
        local integer slot
        local integer roll
        local integer abilId
        local integer attempts
        local integer emptyCount
        local integer rAbil
        local player  p = GetOwningPlayer(hero)

        // ===== FASE 1: LLENAR SLOTS VACÍOS =====
        if filled < 5 then

            // Contar slots vacíos excluyendo R (Q, W, E, FIJA)
            set emptyCount = 0
            if not HaveSavedInteger(heroDb, hId, SLOT_Q) then
                set emptyCount = emptyCount + 1
            endif
            if not HaveSavedInteger(heroDb, hId, SLOT_W) then
                set emptyCount = emptyCount + 1
            endif
            if not HaveSavedInteger(heroDb, hId, SLOT_E) then
                set emptyCount = emptyCount + 1
            endif
            if not HaveSavedInteger(heroDb, hId, SLOT_FIJA) then
                set emptyCount = emptyCount + 1
            endif

            if emptyCount == 0 then
                // Q, W, E y FIJA llenos → forzar R (5ta compra)
                set slot = SLOT_R
            else
                // Elegir el N-ésimo slot vacío (determinístico, sin retry)
                set roll = GetRandomInt(1, emptyCount)
                set slot = -1
                if not HaveSavedInteger(heroDb, hId, SLOT_Q) then
                    set roll = roll - 1
                    if roll == 0 and slot == -1 then
                        set slot = SLOT_Q
                    endif
                endif
                if not HaveSavedInteger(heroDb, hId, SLOT_W) then
                    set roll = roll - 1
                    if roll == 0 and slot == -1 then
                        set slot = SLOT_W
                    endif
                endif
                if not HaveSavedInteger(heroDb, hId, SLOT_E) then
                    set roll = roll - 1
                    if roll == 0 and slot == -1 then
                        set slot = SLOT_E
                    endif
                endif
                if slot == -1 then
                    set slot = SLOT_FIJA
                endif
            endif

            // Dar habilidad para el slot elegido
            if slot == SLOT_FIJA then
                // A023: remover y re-agregar para que quede nivel 1 activa.
                // NO llamar SetPlayerAbilityAvailable para evitar que
                // reaparezca la cruz roja del learn menu.
                call UnitRemoveAbility(hero, ABIL_FIJA)
                call UnitAddAbility(hero, ABIL_FIJA)
                call SaveInteger(heroDb, hId, SLOT_FIJA, ABIL_FIJA)
                call DisplayTimedTextToPlayer(p, 0, 0, 3.0, "Habilidad Fija desbloqueada (Nv 1).")
            else
                // Elegir habilidad aleatoria del pool (fuerza bruta + validación)
                set attempts = 0
                loop
                    set roll = GetRandomInt(0, GetPoolCount(slot) - 1)
                    set abilId = GetAbilId(slot, roll)
                    set attempts = attempts + 1
                    exitwhen attempts > 500
                    exitwhen IsAbilValid(abilId, hero)
                endloop
                if attempts > 500 then
                    // No hay habilidad válida → devolver madera
                    call SetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER, GetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER) + 1)
                    call DisplayTimedTextToPlayer(p, 0, 0, 3.0, "No hay habilidades disponibles. Madera devuelta.")
                    set p = null
                    return
                endif
                call UnitAddAbility(hero, abilId)
                call SaveInteger(heroDb, hId, slot, abilId)
                call SaveBoolean(heroDb, abilId, TAG_TAKEN, true)
                call DisplayTimedTextToPlayer(p, 0, 0, 3.0, "Nueva habilidad adquirida (Nv 1).")
            endif

            // ===== FASE 2: MEJORAR HABILIDADES =====
        else
            set rAbil = LoadInteger(heroDb, hId, SLOT_R)

            // ── PITY DE LA ULTIMATE (R) ─────────────────────────────
            // Cada mejora que NO sube la R suma 1 a KEY_R_PITY. Al acumular
            // R_PITY_THRESHOLD (10) fallos seguidos, este tiro FUERZA la R
            // —siempre que la R aún pueda subir—. Acota la peor racha: nunca
            // se tarda más de 11 tiros en subir la ulti, sin tocar el reparto
            // normal de Q/W/E/Fija.
            if LoadInteger(heroDb, hId, KEY_R_PITY) >= R_PITY_THRESHOLD and GetUnitAbilityLevel(hero, rAbil) < MAX_LVL_R then
                call IncUnitAbilityLevel(hero, rAbil)
                call SaveInteger(heroDb, hId, KEY_R_PITY, 0)
                call DisplayTimedTextToPlayer(p, 0, 0, 3.0, "|cffffcc00Ultimate asegurada|r mejorada a Nv " + I2S(GetUnitAbilityLevel(hero, rAbil)) + ".")
                set p = null
                return
            endif

            set attempts = 0
            loop
                set roll = GetRandomInt(1, 100)
                if roll <= 22 then
                    set slot = SLOT_Q
                elseif roll <= 45 then
                    set slot = SLOT_W
                elseif roll <= 67 then
                    set slot = SLOT_E
                elseif roll <= 77 then
                    set slot = SLOT_R
                else
                    set slot = SLOT_FIJA
                endif

                set abilId = LoadInteger(heroDb, hId, slot)

                // Verificar si ya está al máximo
                if slot == SLOT_R then
                    if GetUnitAbilityLevel(hero, abilId) < MAX_LVL_R then
                        exitwhen true
                    endif
                elseif slot == SLOT_FIJA then
                    if GetUnitAbilityLevel(hero, abilId) < MAX_LVL_FIJA then
                        exitwhen true
                    endif
                else
                    if GetUnitAbilityLevel(hero, abilId) < MAX_LVL_QWE then
                        exitwhen true
                    endif
                endif

                set attempts = attempts + 1
                if attempts > 500 then
                    // Todas al máximo → devolver madera
                    call SetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER, GetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER) + 1)
                    call DisplayTimedTextToPlayer(p, 0, 0, 3.0, "Todas al maximo.")
                    set p = null
                    return
                endif
            endloop

            call IncUnitAbilityLevel(hero, abilId)

            // Contador de pity de la R: salió natural → reset;
            // si no y la R aún puede subir → +1 (si ya está al máximo, se congela).
            if slot == SLOT_R then
                call SaveInteger(heroDb, hId, KEY_R_PITY, 0)
            elseif GetUnitAbilityLevel(hero, rAbil) < MAX_LVL_R then
                call SaveInteger(heroDb, hId, KEY_R_PITY, LoadInteger(heroDb, hId, KEY_R_PITY) + 1)
            endif

            call DisplayTimedTextToPlayer(p, 0, 0, 3.0, "Habilidad mejorada a Nv " + I2S(GetUnitAbilityLevel(hero, abilId)) + ".")
        endif

        set p = null
    endfunction

    // ==============================
    // REGISTRO DE HABILIDADES (OnInit)
    // ==============================
    //
    // Instrucciones para rellenar:
    //   1. Agrupar por SLOT (Q, W, E, R) para facilitar la lectura.
    //   2. Un comentario breve con: Nombre — Héroe original.
    //   3. Verificar en el editor que el Button Position X coincide.
    //
    // NOTA: Que una habilidad esté aquí NO significa que tenga
    // datos en IA_Data_Buffs.j. Muchas habilidades del catálogo
    // (ej. un simple stun) no modifican AS/DPS/EHP y por lo tanto
    // NO aparecen en la calculadora. Eso es correcto y esperado.
    // Todos los heroes deben llevar obligatoriamente esta habilidad: 'A023' — Entrenamiento (no va en Q,W,E,R)
    //
    // ══════════════════════════════════════════════════════════
    //   FORMATO:
    //   call RegisterAbil('XXXX', SLOT_X) // Nombre — Héroe
    // ══════════════════════════════════════════════════════════
    private function OnInit takes nothing returns nothing
        // Inicializar hashtable del sistema de tomes
        set heroDb = InitHashtable()

        // ==========================================================
        //  SLOT Q (Columna 0) — Habilidades Normales
        // ==========================================================
        call RegisterAbil('AOfs', SLOT_Q)  // Vista Lejana — Sniper
        call RegisterAbil('AHtb', SLOT_Q)  // Martillo de Tormenta — Bandido/Rey de la Montaña
        call RegisterAbil('AHfs', SLOT_Q)  // Llamarada — Mago Sanguinario
        call RegisterAbil('A00H', SLOT_Q)  // Dominio Divino — Lord Garithos
        call RegisterAbil('AEst', SLOT_Q)  // Explorador — Sacerdotisa de la Luna
        call RegisterAbil('AHhb', SLOT_Q)  // Luz Sagrada — Paladín
        call TagFaction('AHhb', 1)          // SOLO HUMANOS
        call RegisterAbil('AEer', SLOT_Q)  // Raíces Enredaderas — Guardián del Bosque
        call RegisterAbil('AEmb', SLOT_Q)  // Quemar Maná — Cazador de Demonios
        call RegisterAbil('AEfk', SLOT_Q)  // Abanico de Cuchillas — Guardiana
        call RegisterAbil('AHbz', SLOT_Q)  // Ventisca — Archimago
        call RegisterAbil('ANhs', SLOT_Q)  // Pulverizador Curativo — Alquimista
        call RegisterAbil('ANsy', SLOT_Q)  // Fábrica de Bolsillo — Hojalatero
        call RegisterAbil('ANbf', SLOT_Q)  // Aliento de Fuego — Alquimista Pandaren
        call RegisterAbil('ANsi', SLOT_Q)  // Silencio — Sylvanas Humano/Sylvanas Orco
        call RegisterAbil('A00A', SLOT_Q)  // Atrapar — Asesina/Naga Royal
        call RegisterAbil('A042', SLOT_Q)  // Barril Explosivo — Goblin Techies
        call RegisterAbil('A02V', SLOT_Q)  // Fisura — Magnadefender
        call RegisterAbil('Ainf', SLOT_Q)  // Fuego Interior — Darth'Remar
        call RegisterAbil('AOwk', SLOT_Q)  // Andar del Viento — Maestro de las Espadas/Grom Hellscream
        call RegisterAbil('AOcl', SLOT_Q)  // Cadena de Relámpagos — Vidente
        call RegisterAbil('AOsh', SLOT_Q)  // Onda Expansiva — Jefe Tauren/Troll Berserker
        call RegisterAbil('AOhw', SLOT_Q)  // Ola Curativa — Cazador de Sombras
        call RegisterAbil('AUdc', SLOT_Q)  // Espiral de Muerte — Caballero de la Muerte
        call TagFaction('AUdc', 2)          // SOLO ORCOS
        call RegisterAbil('AUfn', SLOT_Q)  // Nova de Hielo — Lich
        call RegisterAbil('AUcs', SLOT_Q)  // Enjambre Carroñero — Señor del Terror
        call RegisterAbil('AUim', SLOT_Q)  // Empalar — Señor de la Cripta
        call RegisterAbil('A05T', SLOT_Q)  // Rayo Cónico — Bruja de Mar Naga
        call RegisterAbil('ANso', SLOT_Q)  // Quemar Almas — Señor del Fuego
        call RegisterAbil('ANrf', SLOT_Q)  // Lluvia de Fuego — Señor del Foso
        call RegisterAbil('A009', SLOT_Q)  // Alzar a los Muertos — Nigromante
        call RegisterAbil('A03L', SLOT_Q)  // Gancho de Carnicero — Butcher Abomination
        call RegisterAbil('A02H', SLOT_Q)  // Ciclón — Invocador del Trueno

        // ==========================================================
        //  SLOT W (Columna 1) — Habilidades Normales
        // ==========================================================
        call RegisterAbil('A03S', SLOT_W)  // Ralentización — Sniper
        call RegisterAbil('A03Q', SLOT_W)  // Rejuvenecimiento — Bandido
        call RegisterAbil('AHbn', SLOT_W)  // Banish — Mago Sanguinario
        call RegisterAbil('A02C', SLOT_W)  // Maledictis — Lord Garithos
        call RegisterAbil('AHtc', SLOT_W)  // Trueno — Rey de la Montaña/Butcher Abomination
        call RegisterAbil('AHfa', SLOT_W)  // Flechas de Fuego — Sacerdotisa de la Luna
        call TagRanged('AHfa')              // SOLO RANGO
        call RegisterAbil('AHds', SLOT_W)  // Escudo Divino — Paladín
        call RegisterAbil('A002', SLOT_W)  // Fuerza de la Naturaleza — Guardián del Bosque
        call RegisterAbil('AEim', SLOT_W)  // Inmolación — Cazador de Demonios
        call RegisterAbil('AEbl', SLOT_W)  // Teletransporte — Guardiana
        call RegisterAbil('AHwe', SLOT_W)  // Invocar Elemental del Agua — Archimago
        //call RegisterAbil('ANcr', SLOT_W)  // Furia Química — Alquimista [DESACTIVADA: transformación]
        call RegisterAbil('ANcs', SLOT_W)  // Cohetes de Dispersión — Hojalatero
        call RegisterAbil('ANdh', SLOT_W)  // Aturdimiento por Alcohol — Alquimista Pandaren
        call RegisterAbil('ANfa', SLOT_W)  // Flechas de Hielo — Sylvanas Humano/Bruja de Mar Naga
        call TagRanged('ANfa')              // SOLO RANGO
        call RegisterAbil('A00F', SLOT_W)  // Grito de Guerra — Asesina/Grom Hellscream
        call RegisterAbil('Asta', SLOT_W)  // Trampa Eléctrica — Goblin Techies
        call RegisterAbil('A02Z', SLOT_W)  // Aura de Comando — Magnadefender
        call RegisterAbil('A02N', SLOT_W)  // Sed de Magia — Darth'Remar
        call RegisterAbil('AOmi', SLOT_W)  // Imagen del Espejo — Maestro de las Espadas
        call RegisterAbil('A02M', SLOT_W)  // Rayo Cónico — Vidente
        call RegisterAbil('AOws', SLOT_W)  // Pisotón — Jefe Tauren
        call RegisterAbil('AOhx', SLOT_W)  // Transformación — Cazador de Sombras
        call RegisterAbil('AUdp', SLOT_W)  // Pacto Mortal — Caballero de la Muerte/Nigromante
        call TagFaction('AUdp', 2)          // SOLO ORCOS
        call RegisterAbil('AUfu', SLOT_W)  // Armadura de Hielo — Lich
        call RegisterAbil('AUsl', SLOT_W)  // Dormir — Señor del Terror
        call RegisterAbil('AUts', SLOT_W)  // Caparazón con Púas — Señor de la Cripta
        call RegisterAbil('ANlm', SLOT_W)  // Invocar Cría de Lava — Señor del Fuego
        call RegisterAbil('ANht', SLOT_W)  // Aullido de Terror — Señor del Foso
        call RegisterAbil('ANba', SLOT_W)  // Flecha Negra — Sylvanas Orco
        call RegisterAbil('A05V', SLOT_W)  // Aura de Inexactitud — Sylvanas Orco
        call RegisterAbil('A04M', SLOT_W)  // Ola Expansiva — Naga Royal
        call RegisterAbil('A03C', SLOT_W)  // Bendición de Zeus — Invocador del Trueno
        //call RegisterAbil('A05Q', SLOT_W)  // Soy Huskar — Troll Berserker [DESACTIVADA: transformación]

        // ==========================================================
        //  SLOT E (Columna 2) — Habilidades Normales
        // ==========================================================
        call RegisterAbil('AOcr', SLOT_E)  // Golpe Crítico — Sniper/Sylvanas Humano/Maestro de las Espadas/Grom Hellscream
        call RegisterAbil('AEev', SLOT_E)  // Evasión — Bandido/Cazador de Demonios
        call RegisterAbil('AHdr', SLOT_E)  // Sifon de Mana — Mago Sanguinario
        call RegisterAbil('A01Y', SLOT_E)  // Bendición Divina — Lord Garithos
        call RegisterAbil('AHbh', SLOT_E)  // Bash — Rey de la Montaña
        call RegisterAbil('AEar', SLOT_E)  // Aura de Efectividad — Sacerdotisa de la Luna
        call RegisterAbil('AHad', SLOT_E)  // Aura de Devoción — Paladín
        call RegisterAbil('AEah', SLOT_E)  // Aura de Espinos — Guardián del Bosque
        call RegisterAbil('AEsh', SLOT_E)  // Golpe de Sombras — Guardiana
        call RegisterAbil('AHab', SLOT_E)  // Aura de Brillantez — Archimago/Nigromante
        call RegisterAbil('ANab', SLOT_E)  // Bomba Ácida — Alquimista
        call RegisterAbil('ANeg', SLOT_E)  // Actualización de Ingeniería — Hojalatero
        call RegisterAbil('ANdb', SLOT_E)  // Camorrista Borracho — Alquimista Pandaren
        call RegisterAbil('A02I', SLOT_E)  // Teletransporte — Asesina
        call RegisterAbil('A046', SLOT_E)  // Vista Lejana — Goblin Techies
        call RegisterAbil('A05P', SLOT_E)  // Speed Bonus — Magnadefender
        call RegisterAbil('A038', SLOT_E)  // Defensa Mágica — Darth'Remar
        call RegisterAbil('AOsf', SLOT_E)  // Espíritu Salvaje — Vidente
        call RegisterAbil('AOae', SLOT_E)  // Aura de Resistencia — Jefe Tauren
        call RegisterAbil('AOsw', SLOT_E)  // Totem Serpiente — Cazador de Sombras
        call RegisterAbil('AUau', SLOT_E)  // Aura Impía — Caballero de la Muerte
        call RegisterAbil('AUdr', SLOT_E)  // Ritual Oscuro — Lich
        call TagFaction('AUdr', 2)          // SOLO ORCOS
        call RegisterAbil('AUav', SLOT_E)  // Aura Vampírica — Señor del Terror
        call RegisterAbil('AUcb', SLOT_E)  // Escarabajos Carroñeros — Señor de la Cripta
        call RegisterAbil('ANms', SLOT_E)  // Escudo de Maná — Bruja de Mar Naga
        call RegisterAbil('ANia', SLOT_E)  // Incinerar — Señor del Fuego
        call RegisterAbil('ANca', SLOT_E)  // Ataque Arrollador — Señor del Foso/Naga Royal
        call RegisterAbil('A02R', SLOT_E)  // Robo de Vida — Sylvanas Orco
        call RegisterAbil('A03O', SLOT_E)  // Inmolación — Butcher Abomination
        call RegisterAbil('A036', SLOT_E)  // Escudo de Rayo — Invocador del Trueno
        call RegisterAbil('A045', SLOT_E)  // Rejuvenecimiento — Troll Berserker

        // ==========================================================
        //  SLOT R (Columna 3) — Ultimates
        // ==========================================================
        call RegisterAbil('A03T', SLOT_R)  // Tiro — Sniper
        call RegisterAbil('A03R', SLOT_R)  // Division del Bandido — Bandido
        call RegisterAbil('AHpx', SLOT_R)  // Fenix — Mago Sanguinario
        call RegisterAbil('A020', SLOT_R)  // Veredicto Divino — Lord Garithos
        call RegisterAbil('AHav', SLOT_R)  // Gran Avatar — Rey de la Montaña
        call RegisterAbil('AEsf', SLOT_R)  // Estrella Fugaz — Sacerdotisa de la Luna/Sylvanas Orco
        call RegisterAbil('AHre', SLOT_R)  // Resurrección — Paladín
        call RegisterAbil('AEtq', SLOT_R)  // Tranquilidad — Guardián del Bosque
        //call RegisterAbil('AEme', SLOT_R)  // Metamorfosis — Cazador de Demonios [DESACTIVADA: transformación]
        call RegisterAbil('AEsv', SLOT_R)  // Venganza — Guardiana
        call RegisterAbil('ANto', SLOT_R)  // Tornado — Archimago/Bruja de Mar Naga
        call RegisterAbil('ANtm', SLOT_R)  // Transmutar — Alquimista
        //call RegisterAbil('ANrg', SLOT_R)  // Robo Goblin — Hojalatero [DESACTIVADA: transformación]
        call RegisterAbil('ANef', SLOT_R)  // Tormenta, Tierra y Fuego — Alquimista Pandaren
        call RegisterAbil('A01U', SLOT_R)  // Dedo de la Muerte — Sylvanas Humano
        call RegisterAbil('A01T', SLOT_R)  // Ataque Arrollador — Asesina
        call RegisterAbil('A044', SLOT_R)  // Bomba Nuclear — Goblin Techies
        call RegisterAbil('A02Y', SLOT_R)  // Defensa Magna — Magnadefender
        call RegisterAbil('A02O', SLOT_R)  // Correa Mágica — Darth'Remar
        call RegisterAbil('AOww', SLOT_R)  // Torbellino de Cuchillas — Maestro de las Espadas
        call RegisterAbil('AOeq', SLOT_R)  // Terremoto — Vidente
        call RegisterAbil('AOre', SLOT_R)  // Reencarnación — Jefe Tauren
        call RegisterAbil('AOvd', SLOT_R)  // Gran Vudú Malvado — Cazador de Sombras
        call RegisterAbil('AUan', SLOT_R)  // Animar a los Muertos — Caballero de la Muerte
        call RegisterAbil('AUdd', SLOT_R)  // Muerte y Putrefacción — Lich
        call RegisterAbil('AUin', SLOT_R)  // Infernal — Señor del Terror
        call RegisterAbil('AUls', SLOT_R)  // Enjambre de Langostas — Señor de la Cripta
        call RegisterAbil('ANvc', SLOT_R)  // Volcán — Señor del Fuego
        call RegisterAbil('ANdo', SLOT_R)  // Perdición — Señor del Foso
        call RegisterAbil('A00B', SLOT_R)  // Mago Infernal — Nigromante
        //call RegisterAbil('A00I', SLOT_R)  // Sed de Sangre — Grom Hellscream [DESACTIVADA: transformación]
        call RegisterAbil('A03N', SLOT_R)  // Carne de Carnicero — Butcher Abomination
        call RegisterAbil('A04L', SLOT_R)  // Aplauso de Mirmidón — Naga Royal
        call RegisterAbil('A03B', SLOT_R)  // Golpe de Trueno — Invocador del Trueno
        call RegisterAbil('A040', SLOT_R)  // Quebrantavidas — Troll Berserker
        
    endfunction

endlibrary
