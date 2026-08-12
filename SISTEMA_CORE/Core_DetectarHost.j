
// Trigger: Core_DetectarHost
//
// Función: Escanea los 10 slots de jugadores al iniciar el mapa para configurar la partida automáticamente.
// - Asignación de Equipos:
//  (Slots 1-5 -> Grupo Humanos)
//  y (Slots 6-10 -> Grupo Orcos)
// - Detección de IA: Verifica si hay Bots presentes para activar la lógica artificial (Core_HayBots).
// - Designación del Host (Master): Identifica al primer jugador humano real y le entrega el control de los menús de configuración
// - Configuración Global: Aplica el handicap de experiencia (Modo Ultra Short) a todos los jugadores activos.

function Trig_Core_DetectarHost_Func004Func002Func001C takes nothing returns boolean
    if ( not ( GetForLoopIndexA() <= 5 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Core_DetectarHost_Func004Func002Func002C takes nothing returns boolean
    if ( not ( GetPlayerController(udg_TempPlayer) == MAP_CONTROL_COMPUTER ) ) then
        return false
    endif
    return true
endfunction

function Trig_Core_DetectarHost_Func004Func002Func003C takes nothing returns boolean
    if ( not ( GetPlayerController(udg_TempPlayer) == MAP_CONTROL_USER ) ) then
        return false
    endif
    if ( not ( udg_Temp_MasterEncontrado == false ) ) then
        return false
    endif
    return true
endfunction

function Trig_Core_DetectarHost_Func004Func002C takes nothing returns boolean
    if ( not ( GetPlayerSlotState(udg_TempPlayer) == PLAYER_SLOT_STATE_PLAYING ) ) then
        return false
    endif
    return true
endfunction

function Trig_Core_DetectarHost_Func005C takes nothing returns boolean
    if ( not ( udg_Core_HayBots == true ) ) then
        return false
    endif
    return true
endfunction

function Trig_Core_DetectarHost_Actions takes nothing returns nothing
    set udg_Core_HayBots=false
    set udg_Temp_MasterEncontrado=false
    set udg_Core_JugadorMaestro=Player(0)
    set bj_forLoopAIndex=1
    set bj_forLoopAIndexEnd=10
    loop
        exitwhen bj_forLoopAIndex > bj_forLoopAIndexEnd
        set udg_TempPlayer=ConvertedPlayer(GetForLoopIndexA())
        if ( Trig_Core_DetectarHost_Func004Func002C() ) then
            if ( Trig_Core_DetectarHost_Func004Func002Func001C() ) then
                call ForceAddPlayerSimple(udg_TempPlayer, udg_Grupo_Humanos)
            else
                call ForceAddPlayerSimple(udg_TempPlayer, udg_Grupo_Orcos)
            endif
            if ( Trig_Core_DetectarHost_Func004Func002Func002C() ) then
                set udg_Core_HayBots=true
            else
            endif
            if ( Trig_Core_DetectarHost_Func004Func002Func003C() ) then
                set udg_Core_JugadorMaestro=udg_TempPlayer
                set udg_Temp_MasterEncontrado=true
                call DisplayTimedTextToForce(GetPlayersAll(), 5.00, ( ( "|cffFFCC00" + GetPlayerName(udg_Core_JugadorMaestro) ) + "|r es el MASTER de la partida." ))
            else
            endif
            call SetPlayerHandicapXP(udg_TempPlayer, 2.00)
        else
        endif
        set bj_forLoopAIndex=bj_forLoopAIndex + 1
    endloop
    if ( Trig_Core_DetectarHost_Func005C() ) then
        call DisplayTimedTextToForce(GetPlayersAll(), 5.00, "TRIGSTR_3804")
    else
        call DisplayTimedTextToForce(GetPlayersAll(), 5.00, "TRIGSTR_3805")
    endif
endfunction

//===========================================================================
function InitTrig_Core_DetectarHost takes nothing returns nothing
    set gg_trg_Core_DetectarHost=CreateTrigger()
    call TriggerRegisterTimerEventSingle(gg_trg_Core_DetectarHost, 0.05)
    call TriggerAddAction(gg_trg_Core_DetectarHost, function Trig_Core_DetectarHost_Actions)
endfunction
