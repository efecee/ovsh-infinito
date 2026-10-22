//===========================================================================
// IA: PERMISOS (minuto para elegir heroe a los bots)
//===========================================================================
// Con bots y algun equipo en Pick: abre un reloj de 60 s ("Los bots se
// activaran en") y da control compartido de cada bot a los humanos de su
// equipo que estan en Pick, para que le elijan heroe. Al vencer el reloj,
// IA_Arrancar.j enciende la IA.
// Lo ejecuta Core_Menu_Habilidades.j (TriggerExecute). No tiene eventos.
//
// TEXTO PERSONALIZADO (antes era GUI). En el editor: seleccionar el detonador
// "IA_Permisos", Editar > Convertir en texto personalizado, y reemplazar todo
// por este archivo. El nombre del detonador NO debe cambiar.
// Conversion 1:1 del GUI que tenia el mapa el 2026-10-20: mismo comportamiento.
// Los textos ahora estan escritos aqui (antes eran TRIGSTR_3711/3712/3783).
//===========================================================================
function Trig_IA_Permisos_Func007Func001Func001Func002Func001C takes nothing returns boolean
    if ( not ( GetPlayerController(GetEnumPlayer()) == MAP_CONTROL_USER ) ) then
        return false
    endif
    if ( not ( GetPlayerSlotState(GetEnumPlayer()) == PLAYER_SLOT_STATE_PLAYING ) ) then
        return false
    endif
    return true
endfunction

function Trig_IA_Permisos_Func007Func001Func001Func002A takes nothing returns nothing
    if ( Trig_IA_Permisos_Func007Func001Func001Func002Func001C() ) then
        call SetPlayerAllianceBJ(udg_IA_Bot_Actual, ALLIANCE_SHARED_CONTROL, true, GetEnumPlayer())
    else
    endif
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

function Trig_IA_Permisos_Func007Func001Func002Func002Func001C takes nothing returns boolean
    if ( not ( GetPlayerController(GetEnumPlayer()) == MAP_CONTROL_USER ) ) then
        return false
    endif
    if ( not ( GetPlayerSlotState(GetEnumPlayer()) == PLAYER_SLOT_STATE_PLAYING ) ) then
        return false
    endif
    return true
endfunction

function Trig_IA_Permisos_Func007Func001Func002Func002A takes nothing returns nothing
    if ( Trig_IA_Permisos_Func007Func001Func002Func002Func001C() ) then
        call SetPlayerAllianceBJ(udg_IA_Bot_Actual, ALLIANCE_SHARED_CONTROL, true, GetEnumPlayer())
    else
    endif
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
    call CreateTimerDialogBJ(udg_IA_Temporizador, "Los bots se activaran en")
    set udg_IA_Ventana_Tiempo=GetLastCreatedTimerDialogBJ()
    call TimerDialogDisplayBJ(true, udg_IA_Ventana_Tiempo)
    call DisplayTextToForce(GetPlayersAll(), " ")
    call DisplayTimedTextToForce(GetPlayersAll(), 45.00, "Tienen |cffFFCC001 minuto|r para elegir los héroes de sus Bots aliados.")
    call ForForce(GetPlayersAll(), function Trig_IA_Permisos_Func007A)
endfunction

//===========================================================================
function InitTrig_IA_Permisos takes nothing returns nothing
    set gg_trg_IA_Permisos=CreateTrigger()
    call TriggerAddAction(gg_trg_IA_Permisos, function Trig_IA_Permisos_Actions)
endfunction
