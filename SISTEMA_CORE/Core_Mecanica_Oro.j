
// Trigger: Core_Mecanica_Oro
//
// Asigna cada segundo la cantidad de oro guardada en "Config_Cantidad_Oro"

function Trig_Core_Mecanica_Oro_Func001A takes nothing returns nothing
    call AdjustPlayerStateBJ(udg_Config_Cantidad_Oro, GetEnumPlayer(), PLAYER_STATE_RESOURCE_GOLD)
    // === Custom script (GUI), DENTRO del "Pick every player", después del Add ===
    // Sync de la línea base del detector de oro F11 (Comandos_Economia.j): la renta
    // SUMA oro a todos; si el sondeo la viera como delta, descuadraría un par −X/+X
    // real (regalo F11 perdido) al coincidir en el mismo tick. Avanzar la base por
    // la renta la vuelve invisible al sondeo. (Escribir índices 10-15 es inocuo: el
    // array es grande y la detección solo lee 0-9.)
    set Eco_GoldBaseline[GetPlayerId(GetEnumPlayer())] = Eco_GoldBaseline[GetPlayerId(GetEnumPlayer())] + udg_Config_Cantidad_Oro
endfunction

function Trig_Core_Mecanica_Oro_Actions takes nothing returns nothing
    call ForForce(GetPlayersAll(), function Trig_Core_Mecanica_Oro_Func001A)
endfunction

//===========================================================================
function InitTrig_Core_Mecanica_Oro takes nothing returns nothing
    set gg_trg_Core_Mecanica_Oro=CreateTrigger()
    call TriggerRegisterTimerEventPeriodic(gg_trg_Core_Mecanica_Oro, 1.00)
    call TriggerAddAction(gg_trg_Core_Mecanica_Oro, function Trig_Core_Mecanica_Oro_Actions)
endfunction
