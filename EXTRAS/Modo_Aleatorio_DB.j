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
//   2. Abre el editor de WC3 ? Habilidad ? mira la columna del botón
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
        private hashtable heroDb = null        // heroId ? slot ? abilId asignado
        //                                      // abilId, 99 ? boolean (tomada globalmente)
        //                                      // abilId, 100 ? integer (faccion: 1=humano, 2=orco)
        //                                      // abilId, 101 ? boolean (solo rango)
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
        private constant integer KEY_R_PITY       = 5   // heroId ? fallos seguidos sin subir la R
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
                // Q, W, E y FIJA llenos ? forzar R (5ta compra)
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
                    // No hay habilidad válida ? devolver madera
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

            // -- PITY DE LA ULTIMATE (R) -----------------------------
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
                    // Todas al máximo ? devolver madera
                    call SetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER, GetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER) + 1)
                    call DisplayTimedTextToPlayer(p, 0, 0, 3.0, "Todas al maximo.")
                    set p = null
                    return
                endif
            endloop

            call IncUnitAbilityLevel(hero, abilId)

            // Contador de pity de la R: salió natural ? reset;
            // si no y la R aún puede subir ? +1 (si ya está al máximo, se congela).
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
    // ----------------------------------------------------------
    //   FORMATO:
    //   call RegisterAbil('XXXX', SLOT_X) // Nombre — Héroe
    // ----------------------------------------------------------
    //
    // ----------------------------------------------------------
    //   FICHA DE CADA HABILIDAD (comentario encima de su RegisterAbil)
    // ----------------------------------------------------------
    //   Sirve para decidir si una habilidad aplica a un sistema (IA,
    //   asistencias, counters...). Solo llevan ficha las habilidades con
    //   datos CONFIRMADOS; las que no tienen ficha están pendientes.
    //
    //   Línea 1 ? Objetivo · Vara · Canalizada · Antimagia · Corta canal
    //   Líneas siguientes ? para qué sirve.
    //
    //   Objetivo:
    //     Unitario (enemigo | aliado | aliado o enemigo)
    //     Unitario + salpicadura / + rebotes   ej. Nova de Hielo / Cadena de Relámpagos
    //     Área elegible          círculo en un punto del mapa, ej. Llamarada, Silencio
    //     Área alrededor del héroe   centrada en quien la lanza, ej. Abanico de Cuchillas, Trueno
    //     Área en el suelo       línea o cono desde el héroe hacia un punto, ej. Empalar, Fisura
    //     Propio héroe | Pasiva | Aura | Autolanzable | Invocación
    //     Activable              estado que se enciende y apaga a gusto, sin enfriamiento, y solo
    //                            beneficia al portador (Inmolación, Defensa Mágica, Escudo de Maná)
    //   Vara        ¿La Varita de Negación ('wneg') quita el efecto? Las auras cuentan
    //               como NO: si la varita borra el buff, el aura lo vuelve a poner.
    //               En invocaciones (y copias/ilusiones), SÍ = la varita les hace
    //               1000 de daño. Algunas son inmunes (Tormenta, Tierra y Fuego; el
    //               Guardián del Apocalipsis de Perdición).
    //   Canalizada  ¿Se pierde si interrumpen al que la lanza (stun, sapo, red...)?
    //   Antimagia   ¿El Amuleto Antimagia ('I003', 1 hechizo cada 40 s) la anula?
    //               Regla del mapa: los stun de ÁREA no los bloquea, salvo Empalar
    //               y Fisura; los stun a UN objetivo normalmente sí (Martillo).
    //               Los stun nunca se quitan con vara.
    //   Corta canal ¿Interrumpe la canalización de la víctima?
    //   —           No aplica (p. ej. Antimagia en algo que no se lanza a enemigos).
    //   ¿?          Dato pendiente de confirmar.
    // ----------------------------------------------------------
    private function OnInit takes nothing returns nothing
        // Inicializar hashtable del sistema de tomes
        set heroDb = InitHashtable()

        // ==========================================================
        //  SLOT Q (Columna 0) — Habilidades Normales
        // ==========================================================

        // Área elegible · Vara: NO · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Revela una zona del mapa unos segundos, incluidas las unidades invisibles. Sirve para espiar
        // la base o el carril enemigo y para descubrir héroes invisibles (counter de Andar del Viento).
        call RegisterAbil('AOfs', SLOT_Q)  // Vista Lejana — Sniper

        // Unitario (enemigo) · Vara: NO · Canalizada: NO · Antimagia: SÍ · Corta canal: SÍ
        // Aturde (stun) al enemigo: no puede moverse, atacar ni lanzar habilidades (sí lo pueden
        // atacar y hechizar). Sirve para cortar canalizaciones, frenar una huida o asegurar un remate.
        call RegisterAbil('AHtb', SLOT_Q)  // Martillo de Tormenta — Bandido/Rey de la Montaña

        // Área elegible · Vara: NO · Canalizada: SÍ · Antimagia: NO · Corta canal: NO
        // Daño por segundo, durante poco tiempo, a los enemigos dentro del área. Solo hace daño.
        // Si aturden o interrumpen al lanzador, el efecto se pierde.
        call RegisterAbil('AHfs', SLOT_Q)  // Llamarada — Mago Sanguinario

        // Aura (enemigos cercanos) · Vara: NO · Canalizada: NO · Antimagia: NO (aura) · Corta canal: NO
        // Pasiva: reduce la velocidad de movimiento de los enemigos alrededor del héroe.
        // Sirve para perseguir y para que no escapen.
        call RegisterAbil('A00H', SLOT_Q)  // Dominio Divino — Lord Garithos

        // Invocación voladora · Vara: SÍ (1000 de daño) · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Invoca un ave que ve enemigos invisibles en un radio generoso a su alrededor (solo donde
        // está ella: no revela el otro carril). Se usa para descubrir invisibles.
        call RegisterAbil('AEst', SLOT_Q)  // Explorador — Sacerdotisa de la Luna

        // Unitario (aliado o enemigo) · Vara: NO · Canalizada: NO · Antimagia: SÍ (sobre enemigo) · Corta canal: NO
        // Cura a un aliado. Sobre un enemigo no-muerto le hace daño (la mitad de lo que cura).
        call RegisterAbil('AHhb', SLOT_Q)  // Luz Sagrada — Paladín
        call TagFaction('AHhb', 1)          // SOLO HUMANOS

        // Unitario (enemigo) · Vara: SÍ · Canalizada: NO · Antimagia: SÍ · Corta canal: SÍ
        // Enraíza al enemigo varios segundos (no puede moverse) y le hace daño por segundo mientras
        // dura. Sirve para cortar canalizaciones y atrapar a quien huye. La varita lo libera.
        call RegisterAbil('AEer', SLOT_Q)  // Raíces Enredaderas — Guardián del Bosque

        // Unitario (enemigo) · Vara: NO · Canalizada: NO · Antimagia: SÍ · Corta canal: NO
        // Quema maná del enemigo y le hace daño igual a lo quemado. Deja sin maná a los lanzadores.
        call RegisterAbil('AEmb', SLOT_Q)  // Quemar Maná — Cazador de Demonios

        // Área alrededor del héroe · Vara: NO · Canalizada: NO · Antimagia: NO · Corta canal: NO
        // Instantánea: el héroe lanza cuchillas a su alrededor y daña a todos los enemigos cercanos.
        // Solo hace daño. Limpia oleadas y castiga a varios héroes juntos.
        call RegisterAbil('AEfk', SLOT_Q)  // Abanico de Cuchillas — Guardiana

        // Área elegible · Vara: NO · Canalizada: SÍ · Antimagia: NO · Corta canal: NO
        // Lluvia de hielo que daña por segundo a los enemigos dentro del área durante varios segundos.
        // Si aturden o interrumpen al lanzador, se corta.
        call RegisterAbil('AHbz', SLOT_Q)  // Ventisca — Archimago

        // Área elegible (aliados) · Vara: NO · Canalizada: SÍ · Antimagia: — · Corta canal: NO
        // Cura por oleadas a los aliados dentro del área durante unos segundos. Si interrumpen al
        // lanzador (martillo, sapo...), no completa la curación.
        call RegisterAbil('ANhs', SLOT_Q)  // Pulverizador Curativo — Alquimista

        // Invocación (en un punto) · Vara: ¿? · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Crea una fábrica que produce sin parar pequeñas unidades que atacan (vida de un creep normal).
        // Si destruyen la fábrica, deja de producir. Sirve para empujar el carril.
        call RegisterAbil('ANsy', SLOT_Q)  // Fábrica de Bolsillo — Hojalatero

        // Área en el suelo (cono hacia un punto) · Vara: NO · Canalizada: NO · Antimagia: NO · Corta canal: NO
        // Instantánea: lanza fuego en forma de cono y daña a los enemigos alcanzados. Solo hace daño.
        call RegisterAbil('ANbf', SLOT_Q)  // Aliento de Fuego — Alquimista Pandaren

        // Área elegible · Vara: SÍ · Canalizada: NO · Antimagia: NO · Corta canal: SÍ
        // Los enemigos dentro del área no pueden lanzar habilidades durante unos segundos.
        // También corta las canalizaciones que estén haciendo.
        call RegisterAbil('ANsi', SLOT_Q)  // Silencio — Sylvanas Humano/Sylvanas Orco

        // Unitario (enemigo) · Vara: NO · Canalizada: NO · Antimagia: NO · Corta canal: SÍ
        // Lanza una red que deja al enemigo atrapado, sin poder moverse. Sirve para cortar
        // canalizaciones y atrapar a quien huye.
        call RegisterAbil('A00A', SLOT_Q)  // Atrapar — Asesina/Naga Royal

        // Área elegible (barril en un punto) · Vara: NO · Canalizada: NO · Antimagia: NO · Corta canal: SÍ
        // Coloca un barril que explota a los 3 s: daña y aturde (stun corto, más largo a mayor nivel)
        // a su alrededor. Daño por código + stun de área (War Stomp) ? el amuleto no lo para.
        // Ver CUSTOM_SKILLS/Habilidad_Techies_Barril.j.
        call RegisterAbil('A042', SLOT_Q)  // Barril Explosivo — Goblin Techies

        // Área en el suelo (línea hacia un punto) · Vara: NO · Canalizada: NO · Antimagia: SÍ · Corta canal: SÍ
        // Abre una línea de grietas desde el héroe: cada enemigo tocado recibe daño + stun (una vez por
        // fisura). Con antimagia lo ignora todo (ni daño ni stun): el golpe sale de un Martillo por
        // objetivo (FISSURE_USE_TARGET_STUN = true). Ver CUSTOM_SKILLS/Fisure.j.
        call RegisterAbil('A02V', SLOT_Q)  // Fisura — Magnadefender

        // Unitario (aliado) · Vara: SÍ · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Aumenta el daño y la armadura de un aliado durante un tiempo.
        call RegisterAbil('Ainf', SLOT_Q)  // Fuego Interior — Darth'Remar

        // Propio héroe · Vara: NO · Canalizada: NO · Antimagia: — · Corta canal: NO
        // El héroe se vuelve invisible y más rápido; el primer golpe al salir de la invisibilidad
        // hace daño extra. Escapar, emboscar o reposicionarse. Counter: Vista Lejana.
        call RegisterAbil('AOwk', SLOT_Q)  // Andar del Viento — Maestro de las Espadas/Grom Hellscream

        // Unitario (enemigo) + rebotes · Vara: NO · Canalizada: NO · Antimagia: SÍ · Corta canal: NO
        // Instantánea: daña al objetivo y el rayo rebota al siguiente enemigo más cercano (más rebotes
        // a mayor nivel). Solo hace daño.
        call RegisterAbil('AOcl', SLOT_Q)  // Cadena de Relámpagos — Vidente

        // Área en el suelo (cono hacia un punto) · Vara: NO · Canalizada: NO · Antimagia: NO · Corta canal: NO
        // Instantánea: lanza una onda en forma de cono que daña a los enemigos que alcanza.
        call RegisterAbil('AOsh', SLOT_Q)  // Onda Expansiva — Jefe Tauren/Troll Berserker

        // Unitario (aliado) + rebotes · Vara: NO · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Instantánea: cura a un aliado y rebota curando a los aliados cercanos (más rebotes a mayor
        // nivel). Solo cura.
        call RegisterAbil('AOhw', SLOT_Q)  // Ola Curativa — Cazador de Sombras

        // Unitario (aliado o enemigo) · Vara: NO · Canalizada: NO · Antimagia: SÍ (sobre enemigo) · Corta canal: NO
        // Instantánea: cura a un aliado; a un enemigo le hace daño (la mitad de lo que cura).
        call RegisterAbil('AUdc', SLOT_Q)  // Espiral de Muerte — Caballero de la Muerte
        call TagFaction('AUdc', 2)          // SOLO ORCOS

        // Unitario (enemigo) + salpicadura · Vara: NO · Canalizada: NO · Antimagia: ¿? · Corta canal: NO
        // Instantánea: daña al objetivo y a los que están a su alrededor, y les reduce la velocidad
        // de movimiento unos segundos. Si el amuleto la bloquea, solo protege al objetivo: la
        // salpicadura sí afecta a los de alrededor.
        call RegisterAbil('AUfn', SLOT_Q)  // Nova de Hielo — Lich

        // Área en el suelo (cono hacia un punto) · Vara: NO · Canalizada: NO · Antimagia: NO · Corta canal: NO
        // Prácticamente igual a Onda Expansiva: daño instantáneo en cono a los enemigos alcanzados.
        call RegisterAbil('AUcs', SLOT_Q)  // Enjambre Carroñero — Señor del Terror

        // Área en el suelo (línea hacia un punto) · Vara: NO · Canalizada: NO · Antimagia: SÍ · Corta canal: SÍ
        // Púas en línea recta: cada enemigo alcanzado recibe un golpe de daño y queda aturdido
        // (el stun dura más a mayor nivel). Iniciar peleas / atrapar a varios a la vez.
        call RegisterAbil('AUim', SLOT_Q)  // Empalar — Señor de la Cripta

        // Unitario (enemigo) ? daño en cono · Vara: NO · Canalizada: NO · Antimagia: SÍ · Corta canal: NO
        // Se lanza sobre un enemigo y daña en forma de cono a los que quedan dentro. Solo hace daño.
        // Si el objetivo tiene antimagia, la habilidad no sale (igual que el Rayo Cónico del Vidente).
        call RegisterAbil('A05T', SLOT_Q)  // Rayo Cónico — Bruja de Mar Naga

        // Unitario (enemigo) · Vara: SÍ · Canalizada: NO · Antimagia: SÍ · Corta canal: NO
        // Daño por segundo + silencio: el enemigo no puede lanzar habilidades mientras dura.
        call RegisterAbil('ANso', SLOT_Q)  // Quemar Almas — Señor del Fuego

        // Área elegible · Vara: NO · Canalizada: SÍ · Antimagia: NO · Corta canal: NO
        // Lluvia de fuego del cielo que daña en área (como Ventisca). Si interrumpen al lanzador, se corta.
        // La quemadura no es un buff: cada oleada daña a quien esté dentro; al salir del área deja de dañar.
        call RegisterAbil('ANrf', SLOT_Q)  // Lluvia de Fuego — Señor del Foso

        // Invocación (de cadáveres) · Vara: SÍ (1000 de daño) · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Levanta esqueletos a partir de los cadáveres cercanos. Los esqueletos no tienen habilidades.
        call RegisterAbil('A009', SLOT_Q)  // Alzar a los Muertos — Nigromante

        // Área en el suelo (línea) · Vara: NO · Canalizada: NO · Antimagia: NO (la ignora) · Corta canal: SÍ
        // Lanza un gancho en línea recta que arrastra hasta el héroe a la primera unidad que toca,
        // enemiga o aliada; a los enemigos les hace daño. Atrapar enemigos o rescatar aliados.
        // Ver CUSTOM_SKILLS/Gancho_de_Carnicero.j.
        call RegisterAbil('A03L', SLOT_Q)  // Gancho de Carnicero — Butcher Abomination

        // Unitario (enemigo) · Vara: NO · Canalizada: NO · Antimagia: SÍ · Corta canal: SÍ
        // Eleva al enemigo por los aires unos segundos: queda invulnerable y bloqueado (no ataca, no
        // lanza hechizos y no lo pueden atacar). Saca a un enemigo de la pelea o corta su canalización.
        call RegisterAbil('A02H', SLOT_Q)  // Ciclón — Invocador del Trueno

        // ==========================================================
        //  SLOT W (Columna 1) — Habilidades Normales
        // ==========================================================

        // Unitario (enemigo) · Vara: SÍ · Canalizada: NO · Antimagia: SÍ · Corta canal: NO
        // Reduce la velocidad de movimiento y de ataque del enemigo durante varios segundos.
        call RegisterAbil('A03S', SLOT_W)  // Ralentización — Sniper

        // Unitario (aliado) · Vara: SÍ · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Cura a un aliado poco a poco durante varios segundos. Una varita enemiga corta la curación.
        call RegisterAbil('A03Q', SLOT_W)  // Rejuvenecimiento — Bandido

        // Unitario (aliado o enemigo) · Vara: SÍ · Canalizada: NO · Antimagia: SÍ (sobre enemigo) · Corta canal: NO
        // Vuelve etérea a la unidad (se pone verde): puede moverse y lanzar habilidades, pero no ataca
        // ni recibe daño físico; los hechizos sí le afectan. Protege a un aliado de los golpes o deja
        // a un enemigo sin poder pegar.
        call RegisterAbil('AHbn', SLOT_W)  // Banish — Mago Sanguinario

        // Aura (enemigos cercanos) · Vara: NO · Canalizada: NO · Antimagia: NO (aura) · Corta canal: NO
        // Pasiva: reduce la armadura de los enemigos alrededor del héroe.
        call RegisterAbil('A02C', SLOT_W)  // Maledictis — Lord Garithos

        // Área alrededor del héroe · Vara: NO · Canalizada: NO · Antimagia: NO · Corta canal: NO
        // Golpe al suelo que reduce la velocidad de movimiento y de ataque de los enemigos cercanos.
        call RegisterAbil('AHtc', SLOT_W)  // Trueno — Rey de la Montaña/Butcher Abomination

        // Autolanzable (en cada ataque) · Vara: NO · Canalizada: NO · Antimagia: NO (es un ataque) · Corta canal: NO
        // Cada ataque del héroe hace daño extra.
        call RegisterAbil('AHfa', SLOT_W)  // Flechas de Fuego — Sacerdotisa de la Luna
        call TagRanged('AHfa')              // SOLO RANGO

        // Propio héroe · Vara: NO · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Vuelve invulnerable al héroe unos segundos: no le afectan ataques, daño ni habilidades.
        // Para sobrevivir a un focus o escapar.
        call RegisterAbil('AHds', SLOT_W)  // Escudo Divino — Paladín

        // Invocación · Vara: ¿? · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Trae al mapa pequeñas invocaciones que se pueden controlar (muy parecida a Alzar a los Muertos).
        call RegisterAbil('A002', SLOT_W)  // Fuerza de la Naturaleza — Guardián del Bosque

        // Activable (propio héroe) · Vara: NO · Canalizada: NO · Antimagia: NO · Corta canal: NO
        // Encendida, una capa de fuego rodea al héroe y daña por segundo a los enemigos cercanos,
        // gastando maná por segundo. Se apaga a mano o sola cuando se queda sin maná.
        call RegisterAbil('AEim', SLOT_W)  // Inmolación — Cazador de Demonios

        // Propio héroe (salta a un punto) · Vara: NO · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Teletransporta al héroe al instante a un punto cercano. Para escapar o entrar a la pelea.
        call RegisterAbil('AEbl', SLOT_W)  // Teletransporte — Guardiana

        // Invocación · Vara: ¿? · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Invoca elementales de agua: cada ataque suyo reduce la velocidad de movimiento de la víctima.
        // Los elementales tienen además la habilidad Ola Expansiva.
        call RegisterAbil('AHwe', SLOT_W)  // Invocar Elemental del Agua — Archimago

        //call RegisterAbil('ANcr', SLOT_W)  // Furia Química — Alquimista [DESACTIVADA: transformación]

        // Área elegible · Vara: NO · Canalizada: SÍ (muy corta) · Antimagia: NO · Corta canal: SÍ
        // Lanza cohetes al área elegida y aturde (stun) a los enemigos que estén dentro. Tarda 1-2 s
        // en salir: si el héroe se mueve o lo aturden en ese momento, el stun no se aplica.
        call RegisterAbil('ANcs', SLOT_W)  // Cohetes de Dispersión — Hojalatero

        // Unitario (enemigo) + salpicadura · Vara: SÍ · Canalizada: NO · Antimagia: SÍ · Corta canal: NO
        // Al objetivo y a los enemigos de alrededor les reduce la velocidad de movimiento y les da
        // probabilidad de fallar sus ataques.
        call RegisterAbil('ANdh', SLOT_W)  // Aturdimiento por Alcohol — Alquimista Pandaren

        // Autolanzable (en cada ataque) · Vara: NO · Canalizada: NO · Antimagia: NO (es un ataque) · Corta canal: NO
        // Encendida, cada ataque del héroe es de hielo: reduce la velocidad de movimiento y de ataque
        // de la víctima. La varita no quita esa lentitud.
        call RegisterAbil('ANfa', SLOT_W)  // Flechas de Hielo — Sylvanas Humano/Bruja de Mar Naga
        call TagRanged('ANfa')              // SOLO RANGO

        // Área alrededor del héroe (aliados) · Vara: SÍ · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Un grito que aumenta el daño y la armadura de los aliados alrededor del héroe.
        call RegisterAbil('A00F', SLOT_W)  // Grito de Guerra — Asesina/Grom Hellscream

        // Invocación (en un punto) · Vara: SÍ (1000 de daño a la trampa) · Canalizada: NO · Antimagia: NO · Corta canal: SÍ
        // Coloca una trampa que dura unos 5 s; si detecta enemigos cerca, explota y los aturde (stun).
        // Una vez aplicado, el stun no se quita con vara ni lo para el amuleto. Counter: tirarle una
        // varita a la trampa para destruirla, rápido (suele explotar a los 1-2 s de ponerla).
        call RegisterAbil('Asta', SLOT_W)  // Trampa Eléctrica — Goblin Techies

        // Aura (aliados) · Vara: NO · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Pasiva: más velocidad de movimiento y de ataque para los aliados cercanos.
        call RegisterAbil('A02Z', SLOT_W)  // Aura de Comando — Magnadefender

        // Área elegible · Vara: NO · Canalizada: NO · Antimagia: NO · Corta canal: NO
        // Absorbe la magia del área: quita todos los buffs y debuffs de las unidades que estén dentro
        // (aliadas y enemigas) y los convierte en vida para el héroe. Sirve para limpiar debuffs de
        // aliados o quitar buffs a enemigos, curándose de paso.
        call RegisterAbil('A02N', SLOT_W)  // Sed de Magia — Darth'Remar

        // Propio héroe · Vara: SÍ (1000 de daño a la copia) · Canalizada: NO · Antimagia: — · Corta canal: NO
        // El héroe saca al instante una copia de sí mismo, más débil que el original (menos vida y
        // menos daño). Sirve para confundir al enemigo y repartir golpes.
        call RegisterAbil('AOmi', SLOT_W)  // Imagen del Espejo — Maestro de las Espadas

        // Unitario (enemigo) ? daño en cono · Vara: NO · Canalizada: NO · Antimagia: SÍ · Corta canal: NO
        // Se lanza sobre un enemigo, que marca la dirección del cono, y daña a todos los que quedan
        // dentro. Solo hace daño. Si el objetivo tiene antimagia, la habilidad no sale.
        call RegisterAbil('A02M', SLOT_W)  // Rayo Cónico — Vidente

        // Área alrededor del héroe · Vara: NO · Canalizada: NO · Antimagia: NO · Corta canal: SÍ
        // Golpe al suelo que aturde (stun) a los enemigos cercanos. Iniciar peleas o cortar
        // canalizaciones. (Que el stun de área no lo para el amuleto está documentado en Fisure.j.)
        call RegisterAbil('AOws', SLOT_W)  // Pisotón — Jefe Tauren

        // Unitario (enemigo) · Vara: SÍ · Canalizada: NO · Antimagia: SÍ · Corta canal: SÍ
        // Hex: convierte al enemigo en un animal indefenso varios segundos. No ataca ni lanza
        // habilidades, y se mueve muy lento.
        call RegisterAbil('AOhx', SLOT_W)  // Transformación — Cazador de Sombras

        // Unitario (unidad aliada, no héroe) · Vara: NO · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Sacrifica una unidad aliada que no sea héroe y convierte parte de su vida en curación
        // para el héroe.
        call RegisterAbil('AUdp', SLOT_W)  // Pacto Mortal — Caballero de la Muerte/Nigromante
        call TagFaction('AUdp', 2)          // SOLO ORCOS

        // Unitario (aliado) · Vara: SÍ · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Más armadura temporal para un aliado; quien lo golpee cuerpo a cuerpo queda ralentizado.
        // La varita quita la armadura, pero NO la lentitud de los atacantes.
        call RegisterAbil('AUfu', SLOT_W)  // Armadura de Hielo — Lich

        // Unitario (enemigo) · Vara: SÍ · Canalizada: NO · Antimagia: SÍ · Corta canal: SÍ
        // Duerme al enemigo: no puede hacer nada mientras dura (en WC3 despierta si lo golpean).
        // Un aliado de la víctima puede despertarla al instante con una varita.
        call RegisterAbil('AUsl', SLOT_W)  // Dormir — Señor del Terror

        // Pasiva · Vara: NO · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Más armadura, y quien golpea al héroe cuerpo a cuerpo recibe de vuelta parte del daño.
        call RegisterAbil('AUts', SLOT_W)  // Caparazón con Púas — Señor de la Cripta

        // Invocación · Vara: ¿? · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Invoca crías de lava que pelean por el héroe (parecida a Alzar a los Muertos).
        call RegisterAbil('ANlm', SLOT_W)  // Invocar Cría de Lava — Señor del Fuego

        // Área alrededor del héroe · Vara: SÍ · Canalizada: NO · Antimagia: NO · Corta canal: NO
        // Un grito que reduce en un porcentaje el daño de ataque normal (daño blanco) de los
        // enemigos cercanos.
        call RegisterAbil('ANht', SLOT_W)  // Aullido de Terror — Señor del Foso

        // Autolanzable (en cada ataque) · Vara: NO · Canalizada: NO · Antimagia: NO (es un ataque) · Corta canal: NO
        // Encendida, cada ataque hace daño extra (no deja debuff en la víctima) y cada unidad que mata
        // el héroe invoca un esqueleto que ataca muy rápido.
        call RegisterAbil('ANba', SLOT_W)  // Flecha Negra — Sylvanas Orco

        // Aura (enemigos cercanos) · Vara: NO · Canalizada: NO · Antimagia: NO (aura) · Corta canal: NO
        // Pasiva: reduce en un porcentaje el daño de ataque normal (daño blanco) de los enemigos
        // cercanos que atacan a distancia.
        call RegisterAbil('A05V', SLOT_W)  // Aura de Inexactitud — Sylvanas Orco

        // Área en el suelo (línea hacia un punto) · Vara: NO · Canalizada: NO · Antimagia: NO · Corta canal: NO
        // Lanza una ola en la dirección elegida que daña a todos los enemigos a su paso. Solo hace daño.
        call RegisterAbil('A04M', SLOT_W)  // Ola Expansiva — Naga Royal

        // Área alrededor del héroe (aliados) · Vara: SÍ · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Aumenta temporalmente la armadura de los aliados alrededor del héroe.
        call RegisterAbil('A03C', SLOT_W)  // Bendición de Zeus — Invocador del Trueno
        //call RegisterAbil('A05Q', SLOT_W)  // Soy Huskar — Troll Berserker [DESACTIVADA: transformación]

        // ==========================================================
        //  SLOT E (Columna 2) — Habilidades Normales
        // ==========================================================

        // Pasiva · Vara: NO · Canalizada: NO · Antimagia: NO (es un ataque) · Corta canal: NO
        // Probabilidad de que un ataque sea crítico (daño multiplicado).
        call RegisterAbil('AOcr', SLOT_E)  // Golpe Crítico — Sniper/Sylvanas Humano/Maestro de las Espadas/Grom Hellscream

        // Pasiva · Vara: NO · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Probabilidad de esquivar los ataques que recibe el héroe.
        call RegisterAbil('AEev', SLOT_E)  // Evasión — Bandido/Cazador de Demonios

        // Unitario (aliado o enemigo) · Vara: NO · Canalizada: SÍ · Antimagia: SÍ (sobre enemigo) · Corta canal: NO
        // A un enemigo le roba maná; a un aliado le pasa maná. Se corta si interrumpen al lanzador.
        call RegisterAbil('AHdr', SLOT_E)  // Sifon de Mana — Mago Sanguinario

        // Aura (aliados) · Vara: NO · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Pasiva: más velocidad de ataque para héroes y creeps aliados cercanos (área 900).
        // Valores por nivel en IA_Data_Buffs.j.
        call RegisterAbil('A01Y', SLOT_E)  // Bendición Divina — Lord Garithos

        // Pasiva · Vara: NO · Canalizada: NO · Antimagia: NO (es un ataque) · Corta canal: SÍ (al aturdir)
        // Probabilidad de que un ataque haga daño extra y aturda (stun) al objetivo.
        call RegisterAbil('AHbh', SLOT_E)  // Bash — Rey de la Montaña

        // Aura (aliados) · Vara: NO · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Pasiva: más daño para los ataques a distancia de los aliados cercanos.
        call RegisterAbil('AEar', SLOT_E)  // Aura de Efectividad — Sacerdotisa de la Luna

        // Aura (aliados) · Vara: NO · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Pasiva: más armadura para los aliados cercanos.
        call RegisterAbil('AHad', SLOT_E)  // Aura de Devoción — Paladín

        // Aura (aliados) · Vara: NO · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Pasiva: quien golpea cuerpo a cuerpo a un aliado cercano recibe de vuelta parte del daño.
        call RegisterAbil('AEah', SLOT_E)  // Aura de Espinos — Guardián del Bosque

        // Unitario (enemigo) · Vara: NO · Canalizada: NO · Antimagia: SÍ · Corta canal: NO
        // Daño inicial + daño por segundo + lentitud. La lentitud empieza muy fuerte y se pasa rápido,
        // pero el daño por segundo sigue. OJO: es de los pocos debuffs que la varita NO quita.
        call RegisterAbil('AEsh', SLOT_E)  // Golpe de Sombras — Guardiana

        // Aura (aliados) · Vara: NO · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Pasiva: más regeneración de maná para los aliados cercanos.
        call RegisterAbil('AHab', SLOT_E)  // Aura de Brillantez — Archimago/Nigromante

        // Unitario (enemigo) + salpicadura · Vara: ¿? · Canalizada: NO · Antimagia: SÍ · Corta canal: NO
        // Al objetivo y a los de alrededor les reduce la armadura y les hace daño por segundo.
        call RegisterAbil('ANab', SLOT_E)  // Bomba Ácida — Alquimista

        // Pasiva · Vara: NO · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Más daño y velocidad de movimiento para el héroe; además mejora Fábrica de Bolsillo,
        // Cohetes de Dispersión y Robo Goblin si el héroe las tiene.
        call RegisterAbil('ANeg', SLOT_E)  // Actualización de Ingeniería — Hojalatero

        // Pasiva · Vara: NO · Canalizada: NO · Antimagia: NO (es un ataque) · Corta canal: NO
        // Probabilidad de esquivar ataques y de dar golpes críticos.
        call RegisterAbil('ANdb', SLOT_E)  // Camorrista Borracho — Alquimista Pandaren

        // Propio héroe (salta hacia un punto) · Vara: NO · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Teletransporta al héroe al instante. A más nivel, más distancia (y más enfriamiento). Si el
        // punto está fuera de su alcance, salta en esa dirección todo lo que puede.
        call RegisterAbil('A02I', SLOT_E)  // Teletransporte — Asesina

        // Área elegible · Vara: NO · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Exactamente igual a la Vista Lejana clásica ('AOfs'): revela una zona, incluidos los invisibles.
        call RegisterAbil('A046', SLOT_E)  // Vista Lejana — Goblin Techies

        // Pasiva (solo el propio héroe) · Vara: NO · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Más velocidad de ataque para el héroe (no afecta a aliados). Valores en IA_Data_Buffs.j.
        call RegisterAbil('A05P', SLOT_E)  // Speed Bonus — Magnadefender

        // Activable (propio héroe) · Vara: NO · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Encendida, el héroe se mueve más lento pero recibe menos daño de ciertos tipos de ataque
        // (p. ej. las torres y estructuras no le hacen daño).
        call RegisterAbil('A038', SLOT_E)  // Defensa Mágica — Darth'Remar

        //call RegisterAbil('AOsf', SLOT_E)  // Espíritu Salvaje — Vidente [DESACTIVADA: reemplazada por Tanque Salvaje]

        // Invocación · Vara: SÍ (1000 de daño) · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Invoca un tanque grande con mucha vida y casi nada de daño, con habilidades pasivas y activas.
        // Sirve para absorber golpes.
        call RegisterAbil('A02U', SLOT_E)  // Tanque Salvaje — Vidente

        // Aura (aliados) · Vara: NO · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Pasiva: más velocidad de ataque y de movimiento para los aliados cercanos.
        call RegisterAbil('AOae', SLOT_E)  // Aura de Resistencia — Jefe Tauren

        // Invocación (en un punto) · Vara: NO · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Coloca tótems-serpiente inmóviles que atacan a los enemigos cercanos. La varita no les afecta.
        call RegisterAbil('AOsw', SLOT_E)  // Totem Serpiente — Cazador de Sombras

        // Aura (aliados) · Vara: NO · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Pasiva: más velocidad de movimiento y regeneración de vida para los aliados cercanos.
        call RegisterAbil('AUau', SLOT_E)  // Aura Impía — Caballero de la Muerte

        // Unitario (unidad aliada, no héroe) · Vara: NO · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Sacrifica una unidad aliada que no sea héroe y convierte parte de su vida en maná para el héroe.
        call RegisterAbil('AUdr', SLOT_E)  // Ritual Oscuro — Lich
        call TagFaction('AUdr', 2)          // SOLO ORCOS

        // Aura (aliados) · Vara: NO · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Pasiva: los aliados cuerpo a cuerpo cercanos recuperan vida con cada golpe.
        call RegisterAbil('AUav', SLOT_E)  // Aura Vampírica — Señor del Terror

        // Invocación (de cadáveres) · Vara: SÍ (1000 de daño) · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Invoca escarabajos a partir de cadáveres para que peleen por el héroe (parecida a Alzar a los Muertos).
        call RegisterAbil('AUcb', SLOT_E)  // Escarabajos Carroñeros — Señor de la Cripta

        // Activable (propio héroe) · Vara: NO · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Encendido, el daño que recibe el héroe le quita maná en vez de vida: el maná funciona como
        // vida extra.
        call RegisterAbil('ANms', SLOT_E)  // Escudo de Maná — Bruja de Mar Naga

        // Autolanzable · Vara: NO · Canalizada: NO · Antimagia: NO · Corta canal: NO
        // Encendida, da probabilidad de que el enemigo que mata el héroe explote y dañe a los enemigos
        // de su alrededor.
        call RegisterAbil('ANia', SLOT_E)  // Incinerar — Señor del Fuego

        // Pasiva · Vara: NO · Canalizada: NO · Antimagia: NO (es un ataque) · Corta canal: NO
        // Parte del daño de cada golpe salpica a los enemigos alrededor del objetivo.
        call RegisterAbil('ANca', SLOT_E)  // Ataque Arrollador — Señor del Foso/Naga Royal

        // Unitario (aliado o enemigo) · Vara: NO · Canalizada: SÍ · Antimagia: SÍ (sobre enemigo) · Corta canal: NO
        // Como Sifón de Maná pero con vida: a un aliado le pasa vida por segundo; a un enemigo se la
        // roba. Se corta si interrumpen al lanzador.
        call RegisterAbil('A02R', SLOT_E)  // Transferencia (antes Robo de Vida) — Sylvanas Orco

        // Activable (propio héroe) · Vara: NO · Canalizada: NO · Antimagia: NO · Corta canal: NO
        // Igual a la Inmolación clásica ('AEim'): capa de fuego que daña por segundo a los enemigos
        // cercanos, gastando maná por segundo.
        call RegisterAbil('A03O', SLOT_E)  // Inmolación — Butcher Abomination

        // Unitario (aliado o enemigo) · Vara: ¿? · Canalizada: NO · Antimagia: ¿? · Corta canal: NO
        // Pone un escudo de rayos a una unidad. No le da armadura: daña por segundo a todas las unidades
        // (aliadas o enemigas) que estén a su alrededor.
        call RegisterAbil('A036', SLOT_E)  // Escudo de Rayo — Invocador del Trueno

        // Unitario (aliado) · Vara: SÍ · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Exactamente igual al Rejuvenecimiento del Bandido ('A03Q'): cura a un aliado poco a poco.
        call RegisterAbil('A045', SLOT_E)  // Rejuvenecimiento — Troll Berserker

        // ==========================================================
        //  SLOT R (Columna 3) — Ultimates
        // ==========================================================

        // Unitario (enemigo) · Vara: NO · Canalizada: SÍ · Antimagia: ¿? · Corta canal: SÍ
        // Disparo de largo alcance: el héroe "recarga" 2-3 s apuntando a un enemigo y luego dispara:
        // daño grande + stun de unos segundos. Si lo interrumpen mientras recarga, no dispara.
        call RegisterAbil('A03T', SLOT_R)  // Tiro — Sniper

        // Propio héroe · Vara: ¿? · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Igual que Imagen del Espejo ('AOmi'), pero la copia es igual de resistente y hace el mismo
        // daño que el original.
        call RegisterAbil('A03R', SLOT_R)  // Division del Bandido — Bandido

        // Invocación aérea · Vara: ¿? · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Invoca un fénix que pierde vida solo por existir. Al morir se convierte en huevo: si nadie
        // destruye el huevo, el fénix renace (prácticamente nunca muere).
        call RegisterAbil('AHpx', SLOT_R)  // Fenix — Mago Sanguinario

        // Área elegible · Vara: SÍ · Canalizada: NO · Antimagia: NO · Corta canal: NO
        // Las unidades del área que atacan a distancia (estructuras como torres incluidas) no pueden
        // atacar mientras dura.
        call RegisterAbil('A020', SLOT_R)  // Veredicto Divino — Lord Garithos

        // Propio héroe (transformación) · Vara: NO · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Transformación temporal: inmune a hechizos, con más vida y más armadura. Aun así le afectan
        // el stun de Carne de Carnicero y el de Infernal / Mago Infernal.
        call RegisterAbil('AHav', SLOT_R)  // Gran Avatar — Rey de la Montaña

        // Área alrededor del héroe · Vara: NO · Canalizada: SÍ · Antimagia: NO · Corta canal: NO
        // Lluvia de estrellas alrededor del héroe que dura mucho y daña a unidades (héroes y creeps) y
        // estructuras. Si interrumpen al héroe, se corta.
        call RegisterAbil('AEsf', SLOT_R)  // Estrella Fugaz — Sacerdotisa de la Luna/Sylvanas Orco

        // Área alrededor del héroe (aliados muertos) · Vara: NO · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Revive a las unidades aliadas muertas cercanas (no a héroes).
        call RegisterAbil('AHre', SLOT_R)  // Resurrección — Paladín

        // Área alrededor del héroe (aliados) · Vara: NO · Canalizada: SÍ · Antimagia: — · Corta canal: NO
        // Cura a los aliados alrededor del héroe mientras canaliza. Si lo interrumpen, deja de curar.
        call RegisterAbil('AEtq', SLOT_R)  // Tranquilidad — Guardián del Bosque

        //call RegisterAbil('AEme', SLOT_R)  // Metamorfosis — Cazador de Demonios [DESACTIVADA: transformación]

        // Invocación · Vara: ¿? · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Invoca una unidad principal que va soltando pequeños espíritus invulnerables de poco daño.
        // La única forma de pararlos es matar a la invocación principal.
        call RegisterAbil('AEsv', SLOT_R)  // Venganza — Guardiana

        // Invocación (en un punto) · Vara: ¿? · Canalizada: SÍ · Antimagia: ¿? · Corta canal: ¿?
        // Invoca un tornado que el héroe controla mientras canaliza (dura varios segundos). Daña a las
        // estructuras y ralentiza a los enemigos cercanos a él. Si se pone encima de un enemigo, lo
        // levanta por los aires unos segundos: no se mueve, no ataca ni lanza hechizos, y no lo pueden
        // atacar ni hechizar. Si cortan la canalización del héroe, el tornado desaparece.
        call RegisterAbil('ANto', SLOT_R)  // Tornado — Archimago/Bruja de Mar Naga

        // Unitario (enemigo no héroe) · Vara: NO · Canalizada: NO · Antimagia: — · Corta canal: —
        // Convierte a un creep enemigo en oro: lo mata al instante y da oro. No afecta a héroes.
        // Ver EXTRAS/Sistema_Transmutar.j.
        call RegisterAbil('ANtm', SLOT_R)  // Transmutar — Alquimista

        //call RegisterAbil('ANrg', SLOT_R)  // Robo Goblin — Hojalatero [DESACTIVADA: transformación]

        // Propio héroe ? 3 invocaciones · Vara: NO (son inmunes) · Canalizada: NO · Antimagia: — · Corta canal: NO
        // El héroe se divide en tres invocaciones distintas durante unos 60 s (no puede volver antes).
        // Solo muere si matan a las tres; si queda una viva, el héroe sobrevive.
        call RegisterAbil('ANef', SLOT_R)  // Tormenta, Tierra y Fuego — Alquimista Pandaren

        // Unitario (enemigo) · Vara: NO · Canalizada: NO · Antimagia: ¿? · Corta canal: NO
        // Daño directo e instantáneo a un enemigo.
        call RegisterAbil('A01U', SLOT_R)  // Dedo de la Muerte — Sylvanas Humano

        // Pasiva · Vara: NO · Canalizada: NO · Antimagia: NO (es un ataque) · Corta canal: NO
        // Igual al Ataque Arrollador clásico ('ANca'): parte del daño de cada golpe salpica a los
        // enemigos alrededor del objetivo.
        call RegisterAbil('A01T', SLOT_R)  // Ataque Arrollador — Asesina

        // Unitario (enemigo) + salpicadura · Vara: NO · Canalizada: NO · Antimagia: ¿? · Corta canal: NO
        // Lanza una bomba a un enemigo que explota a su alrededor: daño instantáneo muy grande a todos
        // los que estén en el área.
        call RegisterAbil('A044', SLOT_R)  // Bomba Nuclear — Goblin Techies

        // Pasiva (propio héroe) · Vara: NO · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Probabilidad de absorber parte del daño que recibe el héroe.
        call RegisterAbil('A02Y', SLOT_R)  // Defensa Magna — Magnadefender

        // Unitario (enemigo) · Vara: NO · Canalizada: SÍ · Antimagia: ¿? · Corta canal: SÍ
        // Lazo mágico de buen alcance que retiene a un enemigo varios segundos. Si aturden al
        // lanzador, el lazo se corta.
        call RegisterAbil('A02O', SLOT_R)  // Correa Mágica — Darth'Remar

        // Área alrededor del héroe (lo sigue) · Vara: NO · Canalizada: NO · Antimagia: NO · Corta canal: NO
        // El héroe gira unos segundos invulnerable (no lo pueden atacar) y daña por segundo a unidades
        // y estructuras cercanas mientras se mueve con normalidad. Funcionaría como canalizada, pero al
        // ser invulnerable nadie la detiene. Escape: activarla y usar el ítem de teletransporte a la base.
        call RegisterAbil('AOww', SLOT_R)  // Torbellino de Cuchillas — Maestro de las Espadas

        // Área elegible · Vara: NO · Canalizada: SÍ · Antimagia: NO · Corta canal: NO
        // Ralentiza muchísimo a las unidades del área (sin hacerles daño) y hace mucho daño a las
        // estructuras: sirve para tirar torres. Si interrumpen al héroe, se corta.
        call RegisterAbil('AOeq', SLOT_R)  // Terremoto — Vidente

        // Pasiva · Vara: NO · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Al morir, el héroe revive en el mismo sitio a los pocos segundos (con enfriamiento largo).
        call RegisterAbil('AOre', SLOT_R)  // Reencarnación — Jefe Tauren

        // Área alrededor del héroe (aliados) · Vara: NO · Canalizada: SÍ · Antimagia: — · Corta canal: NO
        // El héroe baila y vuelve invulnerables a los aliados de alrededor; él sigue siendo vulnerable.
        // Counter: aturdirlo o cortarle la canalización (p. ej. con Martillo).
        call RegisterAbil('AOvd', SLOT_R)  // Gran Vudú Malvado — Cazador de Sombras

        // Invocación (de cadáveres) · Vara: ¿? · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Levanta a los muertos cercanos para que peleen por el héroe (muy parecida a Alzar a los Muertos).
        call RegisterAbil('AUan', SLOT_R)  // Animar a los Muertos — Caballero de la Muerte

        // Área elegible · Vara: NO · Canalizada: SÍ · Antimagia: NO · Corta canal: NO
        // Quita cada segundo un porcentaje de la vida de las unidades enemigas del área (¿también a
        // aliados? pendiente). Si interrumpen al héroe, se corta.
        call RegisterAbil('AUdd', SLOT_R)  // Muerte y Putrefacción — Lich

        // Área elegible · Vara: NO · Canalizada: NO · Antimagia: NO · Corta canal: SÍ
        // Cae un infernal del cielo: daña y aturde (stun) a los enemigos del área y luego queda como
        // invocación controlable. Su stun afecta incluso a héroes con Gran Avatar.
        call RegisterAbil('AUin', SLOT_R)  // Infernal — Señor del Terror

        // Área alrededor del héroe (lo sigue) · Vara: NO · Canalizada: NO · Antimagia: NO · Corta canal: NO
        // Salen langostas que acompañan al héroe durante un tiempo, dañan a los enemigos cercanos y
        // convierten ese daño en vida para él. Sigue activa aunque aturdan al héroe.
        call RegisterAbil('AUls', SLOT_R)  // Enjambre de Langostas — Señor de la Cripta

        // Área elegible · Vara: NO · Canalizada: SÍ · Antimagia: NO · Corta canal: SÍ
        // Crea un volcán que cada segundo lanza piedras que aturden a TODAS las unidades del área,
        // aliadas o enemigas. Para librarse: salir del área o cortar la canalización del lanzador.
        call RegisterAbil('ANvc', SLOT_R)  // Volcán — Señor del Fuego

        // Unitario (unidad aliada, no héroe) · Vara: NO · Canalizada: NO · Antimagia: — · Corta canal: NO
        // Mata a una unidad aliada (no héroe) y de ella sale un Guardián del Apocalipsis controlable,
        // con un pisotón (stun de área más pequeño y corto que el del Jefe Tauren) y Lisiar (reduce
        // la velocidad de movimiento y de ataque de un enemigo). La varita no afecta al Guardián.
        call RegisterAbil('ANdo', SLOT_R)  // Perdición — Señor del Foso

        // Área elegible · Vara: NO · Canalizada: NO · Antimagia: NO · Corta canal: SÍ
        // Exactamente igual al Infernal clásico ('AUin'): cae del cielo, daña y aturde a los enemigos
        // del área (también a héroes con Gran Avatar) y queda como invocación controlable.
        call RegisterAbil('A00B', SLOT_R)  // Mago Infernal — Nigromante

        //call RegisterAbil('A00I', SLOT_R)  // Sed de Sangre — Grom Hellscream [DESACTIVADA: transformación]

        // Área en el suelo (línea muy corta) · Vara: NO · Canalizada: NO · Antimagia: ¿? · Corta canal: SÍ
        // Como Empalar pero de recorrido muy corto: casi siempre alcanza a una sola unidad y hay que
        // estar pegado a la víctima. Daña y aturde; su stun afecta incluso a héroes con Gran Avatar.
        call RegisterAbil('A03N', SLOT_R)  // Carne de Carnicero — Butcher Abomination

        // Área alrededor del héroe · Vara: NO · Canalizada: NO · Antimagia: NO · Corta canal: NO
        // Como Trueno pero con más área y mucho más daño: daño instantáneo a todos los enemigos de
        // alrededor. Según IA_Data_Buffs.j (buff 'B011') también les reduce la velocidad de ataque;
        // la varita no quita esa reducción.
        call RegisterAbil('A04L', SLOT_R)  // Aplauso de Mirmidón — Naga Royal

        // Unitario (enemigo) · Vara: NO · Canalizada: SÍ · Antimagia: ¿? · Corta canal: SÍ
        // Exactamente igual a Tiro ('A03T'): apunta 2-3 s y luego golpea con daño grande + stun.
        call RegisterAbil('A03B', SLOT_R)  // Golpe de Trueno — Invocador del Trueno

        // Unitario (aliado o enemigo) · Vara: NO · Canalizada: NO · Antimagia: NO (daño) / ¿? (lentitud) · Corta canal: NO
        // Salta hasta la unidad. Sobre un aliado solo sirve para desplazarse. Sobre un enemigo le quita
        // un % de su vida ACTUAL, el héroe pierde el mismo % de la suya, y la víctima queda ralentizada
        // (35 s). La lentitud la lanza un dummy con Slow ('A03Z'). Ver CUSTOM_SKILLS/Quebrantavidas.j.
        call RegisterAbil('A040', SLOT_R)  // Quebrantavidas — Troll Berserker
        
    endfunction

endlibrary
