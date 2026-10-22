//===========================================================================
// CORE: DETECTAR HOST (arranque de la partida)
//===========================================================================
// A los 0.05 s recorre los 10 slots de jugadores y configura la partida:
//   - Equipos: slots 1-5 -> udg_Grupo_Humanos, slots 6-10 -> udg_Grupo_Orcos.
//   - Bots: si algun slot lo controla la computadora, udg_Core_HayBots = true
//     (con bots no hay Modo Rapido ni Modo Aleatorio de Habilidades).
//   - Master: el primer jugador humano, de arriba hacia abajo, recibe los
//     menus de configuracion (udg_Core_JugadorMaestro). Si ningun humano
//     juega en los slots 1-10 (sala de solo bots), el Master es el primer
//     observador (Core_Observadores.j).
//   - Experiencia: handicap de XP 200% para todos (Modo Ultra Short).
//
// TEXTO PERSONALIZADO (antes era GUI). En el editor: seleccionar el detonador
// "Core_DetectarHost", Editar > Convertir en texto personalizado, y reemplazar
// todo por este archivo. El nombre del detonador NO debe cambiar.
// Conversion del GUI que tenia el mapa el 2026-10-20, escrita con un bucle
// directo (Player(0..9)) en vez del bucle del GUI (ConvertedPlayer(1..10)):
// mismo comportamiento y mismos textos y duraciones. UNICO CAMBIO: sin bots
// dice "No hay bots." (antes "No hay bots, iniciando partida clásica...", que
// confundia ahora que el Master puede elegir el Modo Rapido).
//===========================================================================

function Trig_Core_DetectarHost_Actions takes nothing returns nothing
    local integer i = 0
    set udg_Core_HayBots = false
    set udg_Temp_MasterEncontrado = false
    set udg_Core_JugadorMaestro = Player(0)
    loop
        exitwhen i > 9
        set udg_TempPlayer = Player(i)
        if (GetPlayerSlotState(udg_TempPlayer) == PLAYER_SLOT_STATE_PLAYING) then
            if (i <= 4) then
                call ForceAddPlayer(udg_Grupo_Humanos, udg_TempPlayer)
            else
                call ForceAddPlayer(udg_Grupo_Orcos, udg_TempPlayer)
            endif
            if (GetPlayerController(udg_TempPlayer) == MAP_CONTROL_COMPUTER) then
                set udg_Core_HayBots = true
            endif
            if (GetPlayerController(udg_TempPlayer) == MAP_CONTROL_USER and not udg_Temp_MasterEncontrado) then
                set udg_Core_JugadorMaestro = udg_TempPlayer
                set udg_Temp_MasterEncontrado = true
                call DisplayTimedTextToForce(GetPlayersAll(), 10.00, "|cffFFCC00" + GetPlayerName(udg_Core_JugadorMaestro) + "|r es el MASTER de la partida.")
            endif
            call SetPlayerHandicapXP(udg_TempPlayer, 2.00)
        endif
        set i = i + 1
    endloop
    // Sala de solo bots: configura un observador.
    set i = 0
    loop
        exitwhen i > 11 or udg_Temp_MasterEncontrado
        if (Observadores_PuedeSerMaster(Player(i))) then
            set udg_Core_JugadorMaestro = Player(i)
            set udg_Temp_MasterEncontrado = true
            call DisplayTimedTextToForce(GetPlayersAll(), 10.00, "|cffFFCC00" + GetPlayerName(udg_Core_JugadorMaestro) + "|r (observador) es el MASTER de la partida.")
        endif
        set i = i + 1
    endloop
    if (udg_Core_HayBots) then
        call DisplayTimedTextToForce(GetPlayersAll(), 2.00, "Bots detectados.")
    else
        call DisplayTimedTextToForce(GetPlayersAll(), 2.00, "No hay bots.")
    endif
endfunction

//===========================================================================
function InitTrig_Core_DetectarHost takes nothing returns nothing
    set gg_trg_Core_DetectarHost = CreateTrigger()
    call TriggerRegisterTimerEventSingle(gg_trg_Core_DetectarHost, 0.05)
    call TriggerAddAction(gg_trg_Core_DetectarHost, function Trig_Core_DetectarHost_Actions)
endfunction
