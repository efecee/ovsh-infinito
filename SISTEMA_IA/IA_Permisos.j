
// Trigger: IA_Permisos
// Detecta a los bots y  permite que los jugadores seleccionen los héroes por los bots durante el primer minuto.

function Trig_IA_Permisos_Func007Func001Func001Func002A takes nothing returns nothing
    call SetPlayerAllianceBJ(udg_IA_Bot_Actual, ALLIANCE_SHARED_CONTROL, true, GetEnumPlayer())
endfunction

function Trig_IA_Permisos_Func007Func001Func001C takes nothing returns boolean
    if ( not ( IsPlayerInForce(GetEnumPlayer(), udg_Grupo_Humanos) == true ) ) then
        return false
    endif
    if ( not ( udg_Config_Modo_Humanos == 1 ) ) then
        return false
    endif
    return true
endfunction

function Trig_IA_Permisos_Func007Func001Func002Func002A takes nothing returns nothing
    call SetPlayerAllianceBJ(udg_IA_Bot_Actual, ALLIANCE_SHARED_CONTROL, true, GetEnumPlayer())
endfunction

function Trig_IA_Permisos_Func007Func001Func002C takes nothing returns boolean
    if ( not ( IsPlayerInForce(GetEnumPlayer(), udg_Grupo_Orcos) == true ) ) then
        return false
    endif
    if ( not ( udg_Config_Modo_Orcos == 1 ) ) then
        return false
    endif
    return true
endfunction

function Trig_IA_Permisos_Func007Func001C takes nothing returns boolean
    if ( not ( GetPlayerController(GetEnumPlayer()) == MAP_CONTROL_COMPUTER ) ) then
        return false
    endif
    return true
endfunction

function Trig_IA_Permisos_Func007A takes nothing returns nothing
    if ( Trig_IA_Permisos_Func007Func001C() ) then
        if ( Trig_IA_Permisos_Func007Func001Func001C() ) then
            set udg_IA_Bot_Actual=GetEnumPlayer()
            call ForForce(GetPlayersAllies(udg_IA_Bot_Actual), function Trig_IA_Permisos_Func007Func001Func001Func002A)
        else
        endif
        if ( Trig_IA_Permisos_Func007Func001Func002C() ) then
            set udg_IA_Bot_Actual=GetEnumPlayer()
            call ForForce(GetPlayersAllies(udg_IA_Bot_Actual), function Trig_IA_Permisos_Func007Func001Func002Func002A)
        else
        endif
    else
    endif
endfunction

function Trig_IA_Permisos_Actions takes nothing returns nothing
    call StartTimerBJ(udg_IA_Temporizador, false, 60.00)
    call CreateTimerDialogBJ(udg_IA_Temporizador, "TRIGSTR_3711")
    set udg_IA_Ventana_Tiempo=GetLastCreatedTimerDialogBJ()
    call TimerDialogDisplayBJ(true, udg_IA_Ventana_Tiempo)
    call DisplayTextToForce(GetPlayersAll(), "TRIGSTR_3712")
    call DisplayTimedTextToForce(GetPlayersAll(), 45.00, "TRIGSTR_3783")
    call ForForce(GetPlayersAll(), function Trig_IA_Permisos_Func007A)
endfunction

//===========================================================================
function InitTrig_IA_Permisos takes nothing returns nothing
    set gg_trg_IA_Permisos=CreateTrigger()
    call TriggerAddAction(gg_trg_IA_Permisos, function Trig_IA_Permisos_Actions)
endfunction
