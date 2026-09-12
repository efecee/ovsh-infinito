//===========================================================================
// SISTEMA DE KICK PROFESIONAL (ESTABLE + ANTI-SPAM)
//===========================================================================

// --- FUNCIÓN DE BÚSQUEDA (Sin cambios, funciona bien) ---
function Kick_GetPlayer takes string s returns player
    local string input = StringCase(s, false)
    local player p
    local integer i = 0

    // 0. INPUT VACÍO (p.ej. "-kick " sin nada, o doble espacio): sin esta guarda,
    //    el match de nombres parciales con prefijo de longitud 0 devolvía al PRIMER
    //    jugador PLAYING del loop (el rojo) y lo expulsaba por accidente.
    if (input == "") then
        return null
    endif

    // 1. NÚMEROS DE JUGADOR (1 al 10) -> Player(0..9)
    //    Misma convención que la guía F9 y el comando -oro (slot = id + 1).
    if (input == "1") then
        return Player(0)
    elseif (input == "2") then
        return Player(1)
    elseif (input == "3") then
        return Player(2)
    elseif (input == "4") then
        return Player(3)
    elseif (input == "5") then
        return Player(4)
    elseif (input == "6") then
        return Player(5)
    elseif (input == "7") then
        return Player(6)
    elseif (input == "8") then
        return Player(7)
    elseif (input == "9") then
        return Player(8)
    elseif (input == "10") then
        return Player(9)
    endif

    // 2. COLORES
    if (input == "rojo" or input == "red") then
        return Player(0)
    elseif (input == "azul" or input == "blue") then
        return Player(1)
    elseif (input == "teal" or input == "cian") then 
        return Player(2)
    elseif (input == "morado" or input == "purple") then
        return Player(3)
    elseif (input == "amarillo" or input == "yellow") then
        return Player(4)
    elseif (input == "naranja" or input == "orange") then
        return Player(5)
    elseif (input == "verde" or input == "green") then
        return Player(6)
    elseif (input == "rosa" or input == "pink") then
        return Player(7)
    elseif (input == "gris" or input == "grey" or input == "gray") then
        return Player(8)
    elseif (input == "light" or input == "celeste") then
        return Player(9)
    endif

    // 3. NOMBRES PARCIALES
    loop
        exitwhen i > 9
        set p = Player(i)
        if (GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING) then
            if (SubString(StringCase(GetPlayerName(p), false), 0, StringLength(input)) == input) then
                return p
            endif
        endif
        set i = i + 1
    endloop

    return null
endfunction

// --- HELPER: COLOR DE JUGADOR (Copia segura para evitar errores de compilación) ---
function Kick_GetColor takes player p returns string
    local integer id = GetPlayerId(p)
    if (id == 0) then
        return "|cffd02222" // Rojo (claro)
    elseif (id == 1) then
        return "|cff2254dd" // Azul (claro)
    elseif (id == 2) then
        return "|cff1CE6B9" // Teal
    elseif (id == 3) then
        return "|cff7134c2" // Morado (lavanda)
    elseif (id == 4) then
        return "|cffFFFC00" // Amarillo
    elseif (id == 5) then
        return "|cffFE8A0E" // Naranja
    elseif (id == 6) then
        return "|cff20C000" // Verde
    elseif (id == 7) then
        return "|cffE55BB0" // Rosa
    elseif (id == 8) then
        return "|cff959697" // Gris
    elseif (id == 9) then
        return "|cff7EBFF1" // Celeste
    endif
    return "|cffFFFFFF"
endfunction

// --- ACCIÓN PRINCIPAL (EJECUCIÓN MANUAL GLOBAL) ---
function Trig_Sistema_Kick_Actions takes nothing returns nothing
    local string chat = GetEventPlayerChatString()
    local player master = udg_Core_JugadorMaestro
    local player kicker = GetTriggerPlayer()
    local player target = null
    local string param = ""
    local integer id = 0
    
    // Variables para ejecución manual
    local integer row = 0
    local multiboarditem mb_item
    
    // Variables para Drop Manual
    local group g
    local unit u
    local item it
    local integer slot
    local integer locationID
    local real baseX
    local real baseY
    
    // 1. SEGURIDAD
    if (kicker != master) then
        return
    endif
    
    // 2. OBTENER OBJETIVO
    set param = SubString(chat, 6, StringLength(chat))
    set target = Kick_GetPlayer(param)
    
    // 3. EJECUCIÓN
    if (target != null) then
        set id = GetPlayerId(target)
        
        if (target == kicker) then
            call DisplayTimedTextToPlayer(kicker, 0, 0, 5.0, "|cffFF0000[ERROR]|r No te puedes auto-expulsar bro.")
        
            // CHECK: ¿Ya procesado? (Usamos hash 101 para "Ya Limpiado")
        elseif (LoadBoolean(udg_MB_Hash, id, 101) == true) then

            // ¿Es un bot post-encuesta? (flag 102 = IA reemplazó al jugador)
            // Caso especial: DROP directo sin encuesta.
            // La IA se auto-desactiva porque RemoveUnit hace GetUnitTypeId() = 0.
            if (LoadBoolean(udg_MB_Hash, id, 102) == true) then

                // Aviso
                call Replay_DisplayTimedTextToAll(5.0, Kick_GetColor(target) + GetPlayerName(target) + "|r ha sido expulsado.")

                // Soltar items en base + eliminar unidades
                set locationID = GetPlayerStartLocation(target)
                set baseX = GetStartLocationX(locationID)
                set baseY = GetStartLocationY(locationID)
                set g = CreateGroup()
                call GroupEnumUnitsOfPlayer(g, target, null)
                loop
                    set u = FirstOfGroup(g)
                    exitwhen u == null
                    call GroupRemoveUnit(g, u)
                    if (IsUnitType(u, UNIT_TYPE_HERO)) then
                        call PauseUnit(u, true)
                        set slot = 0
                        loop
                            exitwhen slot > 5
                            set it = UnitItemInSlot(u, slot)
                            if (it != null) then
                                call UnitRemoveItem(u, it)
                                call SetItemPosition(it, baseX, baseY)
                            endif
                            set slot = slot + 1
                        endloop
                    endif
                    call RemoveUnit(u)
                endloop
                call DestroyGroup(g)

                // Atenuar fila (DROP definitivo)
                set row = LoadInteger(udg_MB_Hash, id, 0)
                if (row > 0) then
                    // Columna 0 es el icono y se conserva sin atenuar.
                    set mb_item = MultiboardGetItem(udg_MB_Tabla, row - 1, 1)
                    call MultiboardSetItemValue(mb_item, "|cff222222" + LoadStr(udg_MB_Hash, id, 5) + "|r")
                    call MultiboardSetItemStyle(mb_item, true, false)
                    call MultiboardReleaseItem(mb_item)
                    set mb_item = MultiboardGetItem(udg_MB_Tabla, row - 1, 2)
                    call MultiboardSetItemValue(mb_item, "|cff222222" + I2S(LoadInteger(udg_MB_Hash, id, 1)) + "|r")
                    call MultiboardSetItemStyle(mb_item, true, false)
                    call MultiboardReleaseItem(mb_item)
                    set mb_item = MultiboardGetItem(udg_MB_Tabla, row - 1, 3)
                    call MultiboardSetItemValue(mb_item, "|cff222222" + I2S(LoadInteger(udg_MB_Hash, id, 2)) + "|r")
                    call MultiboardSetItemStyle(mb_item, true, false)
                    call MultiboardReleaseItem(mb_item)
                    set mb_item = MultiboardGetItem(udg_MB_Tabla, row - 1, 4)
                    call MultiboardSetItemValue(mb_item, "|cff222222" + I2S(LoadInteger(udg_MB_Hash, id, 4)) + "|r")
                    call MultiboardSetItemStyle(mb_item, true, false)
                    call MultiboardReleaseItem(mb_item)
                endif

                // Limpiar flag de bot post-encuesta
                call SaveBoolean(udg_MB_Hash, id, 102, false)
                // El slot vuelve a quedar vacío: re-atenuar para que MB_UpdateRow
                // (asistencia póstuma del bot) mantenga el gris.
                call SaveBoolean(udg_MB_Hash, id, 103, true)

                // Sonido
                call StartSound(MB_Snd_Leave)

            else
                call DisplayTimedTextToPlayer(kicker, 0, 0, 5.0, "|cffFF0000[ERROR]|r Jugador ya expulsado.")
            endif
            
        else
            // --- PASO A: MARCAR COMO PROCESADO ---
            // Esto evita que el trigger 'tabla' lo vuelva a hacer si el evento llega tarde.
            call SaveBoolean(udg_MB_Hash, id, 100, true) // Marca: Fue Kick
            call SaveBoolean(udg_MB_Hash, id, 101, true) // Marca: Ya Limpiamos
            call SaveBoolean(udg_MB_Hash, id, 103, true) // Marca: Fila atenuada
            
            // --- [RESTITUIDO] AVISO DE TEXTO AL PÚBLICO ---
            call Replay_DisplayTimedTextToAll(5.0, Kick_GetColor(target) + GetPlayerName(target) + "|r ha sido expulsado de la partida.")
            
            // --- PASO B: ATENUAR FILA EN LA TABLA (Nombre + K/D/A en gris) ---
            // (Inlineado aquí porque Sistema_Kick compila antes que tabla.j)
            set row = LoadInteger(udg_MB_Hash, id, 0)
            if (row > 0) then
                // Nombre atenuado. Columna 0 es el icono y no se oscurece.
                set mb_item = MultiboardGetItem(udg_MB_Tabla, row - 1, 1)
                call MultiboardSetItemValue(mb_item, "|cff222222" + LoadStr(udg_MB_Hash, id, 5) + "|r")
                call MultiboardSetItemStyle(mb_item, true, false)
                call MultiboardReleaseItem(mb_item)
                // Kills atenuado
                set mb_item = MultiboardGetItem(udg_MB_Tabla, row - 1, 2)
                call MultiboardSetItemValue(mb_item, "|cff222222" + I2S(LoadInteger(udg_MB_Hash, id, 1)) + "|r")
                call MultiboardSetItemStyle(mb_item, true, false)
                call MultiboardReleaseItem(mb_item)
                // Deaths atenuado
                set mb_item = MultiboardGetItem(udg_MB_Tabla, row - 1, 3)
                call MultiboardSetItemValue(mb_item, "|cff222222" + I2S(LoadInteger(udg_MB_Hash, id, 2)) + "|r")
                call MultiboardSetItemStyle(mb_item, true, false)
                call MultiboardReleaseItem(mb_item)
                // Assists atenuado
                set mb_item = MultiboardGetItem(udg_MB_Tabla, row - 1, 4)
                call MultiboardSetItemValue(mb_item, "|cff222222" + I2S(LoadInteger(udg_MB_Hash, id, 4)) + "|r")
                call MultiboardSetItemStyle(mb_item, true, false)
                call MultiboardReleaseItem(mb_item)
            endif
            
            // --- PASO C: INICIAR VOTACIÓN ---
            // El sistema de voto decide qué hacer con el héroe (BOT/DROP/RMK)
            call SistemaVoto_OnPlayerLeave(target)
            
            // --- PASO D: SONIDO MANUAL ---
            call StartSound(MB_Snd_Leave)

            // --- PASO E: EXPULSAR AL JUGADOR ---
            // CustomDefeatBJ es la ÚNICA forma de sacar a un jugador en WC3.
            // Sin esto, el kickeado sigue dentro viendo todo.
            // El héroe SOBREVIVE al defeat (no destruye unidades).
            // El flag (id,101)=true ya está puesto arriba, así que tabla.j
            // no re-procesa cuando EVENT_PLAYER_DEFEAT dispare.
            call CustomDefeatBJ(target, "Has sido expulsado.")
        endif
    else
        call DisplayTimedTextToPlayer(kicker, 0, 0, 5.0, "|cffFF0000[ERROR]|r Jugador no encontrado: " + param)
    endif
    
    set master = null
    set kicker = null
    set target = null
    set g = null
    set u = null
    set it = null
    set mb_item = null
endfunction

//===========================================================================
function InitTrig_Sistema_Kick takes nothing returns nothing
    local integer i = 0
    set gg_trg_Sistema_Kick = CreateTrigger()
    
    loop
        exitwhen i > 9
        call TriggerRegisterPlayerChatEvent(gg_trg_Sistema_Kick, Player(i), "-kick ", false)
        set i = i + 1
    endloop
    
    call TriggerAddAction(gg_trg_Sistema_Kick, function Trig_Sistema_Kick_Actions)
endfunction
