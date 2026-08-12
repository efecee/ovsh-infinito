
// Trigger: Core_Menu_Heroes
//
// muestra la segunda pantalla
// solo a MASTER

function Trig_Core_Menu_Heroes_Actions takes nothing returns nothing
    call DialogClearBJ(udg_UI_Ventana_Heroes)
    call DialogSetMessageBJ(udg_UI_Ventana_Heroes, "TRIGSTR_3721")
    call DialogAddButtonBJ(udg_UI_Ventana_Heroes, "TRIGSTR_3722")
    set udg_UI_Boton_TodosPick=GetLastCreatedButtonBJ()
    call DialogAddButtonBJ(udg_UI_Ventana_Heroes, "TRIGSTR_3723")
    set udg_UI_Boton_TodosRandom=GetLastCreatedButtonBJ()
    call DialogAddButtonBJ(udg_UI_Ventana_Heroes, "TRIGSTR_3724")
    set udg_UI_Boton_HumPick_OrcRnd=GetLastCreatedButtonBJ()
    call DialogAddButtonBJ(udg_UI_Ventana_Heroes, "TRIGSTR_3725")
    set udg_UI_Boton_HumRnd_OrcPick=GetLastCreatedButtonBJ()
    call DialogDisplayBJ(true, udg_UI_Ventana_Heroes, udg_Core_JugadorMaestro)
endfunction

//===========================================================================
function InitTrig_Core_Menu_Heroes takes nothing returns nothing
    set gg_trg_Core_Menu_Heroes=CreateTrigger()
    call TriggerAddAction(gg_trg_Core_Menu_Heroes, function Trig_Core_Menu_Heroes_Actions)
endfunction
