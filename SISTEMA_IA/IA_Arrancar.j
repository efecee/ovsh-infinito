
// Trigger: IA_Arrancar
// Este trigger quita el control compartido,  manda a los héroes a las líneas y activa su cerebro

function Trig_IA_Arrancar_Func004Func001Func002A takes nothing returns nothing
    call SetPlayerAllianceBJ(udg_IA_Bot_Actual, ALLIANCE_SHARED_CONTROL, false, GetEnumPlayer())
endfunction

function Trig_IA_Arrancar_Func004Func001C takes nothing returns boolean
    if ( not ( GetPlayerController(GetEnumPlayer()) == MAP_CONTROL_COMPUTER ) ) then
        return false
    endif
    return true
endfunction

function Trig_IA_Arrancar_Func004A takes nothing returns nothing
    if ( Trig_IA_Arrancar_Func004Func001C() ) then
        set udg_IA_Bot_Actual=GetEnumPlayer()
        call ForForce(GetPlayersAllies(udg_IA_Bot_Actual), function Trig_IA_Arrancar_Func004Func001Func002A)
    else
    endif
endfunction

function Trig_IA_Arrancar_Actions takes nothing returns nothing
    call DestroyTimerDialogBJ(udg_IA_Ventana_Tiempo)
    call PlaySoundBJ(gg_snd_ClanInvitation)
    call DisplayTimedTextToForce(GetPlayersAll(), 5.00, "TRIGSTR_3796")
    call ForForce(GetPlayersAll(), function Trig_IA_Arrancar_Func004A)
    call IACore_InitializeBots()
endfunction

//===========================================================================
function InitTrig_IA_Arrancar takes nothing returns nothing
    set gg_trg_IA_Arrancar=CreateTrigger()
    call TriggerRegisterTimerExpireEventBJ(gg_trg_IA_Arrancar, udg_IA_Temporizador)
    call TriggerAddAction(gg_trg_IA_Arrancar, function Trig_IA_Arrancar_Actions)
endfunction
