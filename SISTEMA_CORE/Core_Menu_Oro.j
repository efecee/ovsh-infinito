
// Trigger: Core_Menu_Oro
//
// Al pasar 1 segundo 
// congela el juego,
// muestra la primera pantalla (ORO)
//  y solo se la muestra al MASTER

function Trig_Core_Menu_Oro_Actions takes nothing returns nothing
    // Si el Master cerró durante la pantalla de carga (o en el primer
    // segundo), rotar ANTES de mostrar el menú: si no, el Dialog se muestra
    // a un fantasma y nadie puede configurar la partida (deadlock).
    call CoreMasterAFK_EnsureMasterValid()
    call PauseGameOn()
    call DialogClearBJ(udg_UI_Ventana_General)
    call DialogSetMessageBJ(udg_UI_Ventana_General, "TRIGSTR_3715")
    call DialogAddButtonBJ(udg_UI_Ventana_General, "TRIGSTR_3716")
    set udg_UI_Boton_OroNormal=GetLastCreatedButtonBJ()
    call DialogAddButtonBJ(udg_UI_Ventana_General, "TRIGSTR_3717")
    set udg_UI_Boton_OroRapido=GetLastCreatedButtonBJ()
    call DialogAddButtonBJ(udg_UI_Ventana_General, "TRIGSTR_3736")
    set udg_UI_Boton_OroInsano=GetLastCreatedButtonBJ()
    call DialogDisplayBJ(true, udg_UI_Ventana_General, udg_Core_JugadorMaestro)
    // Iniciar temporizador AFK para el Master
    call CoreMasterAFK_Start()
endfunction

//===========================================================================
function InitTrig_Core_Menu_Oro takes nothing returns nothing
    set gg_trg_Core_Menu_Oro=CreateTrigger()
    call TriggerRegisterTimerEventSingle(gg_trg_Core_Menu_Oro, 1.00)
    call TriggerAddAction(gg_trg_Core_Menu_Oro, function Trig_Core_Menu_Oro_Actions)
endfunction
