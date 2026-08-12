
// Trigger: Core_Menu_Click
//
// Al hacer click en la primera pantalla
// verifica en que opcion fue
// guarda en la variable "Config_Cantidad_Oro" el numero de oro correspondiente
// ejecuta el trigger "Core_Menu_Heroes"

function Trig_Core_Menu_Click_Func001Func001C takes nothing returns boolean
    if ( not ( GetClickedButtonBJ() == udg_UI_Boton_OroRapido ) ) then
        return false
    endif
    return true
endfunction

function Trig_Core_Menu_Click_Func001C takes nothing returns boolean
    if ( not ( GetClickedButtonBJ() == udg_UI_Boton_OroNormal ) ) then
        return false
    endif
    return true
endfunction

function Trig_Core_Menu_Click_Actions takes nothing returns nothing
    // Detener el temporizador AFK ya que el Master respondió
    call CoreMasterAFK_Stop()
    
    if ( Trig_Core_Menu_Click_Func001C() ) then
        set udg_Config_Cantidad_Oro=6
        call DisplayTimedTextToForce(GetPlayersAll(), 12.00, "TRIGSTR_3790")
    else
        if ( Trig_Core_Menu_Click_Func001Func001C() ) then
            set udg_Config_Cantidad_Oro=12
            call DisplayTimedTextToForce(GetPlayersAll(), 12.00, "TRIGSTR_3791")
        else
            set udg_Config_Cantidad_Oro=18
            call DisplayTimedTextToForce(GetPlayersAll(), 12.00, "TRIGSTR_3792")
        endif
    endif
    call TriggerExecute(gg_trg_Core_Menu_Heroes)
endfunction

//===========================================================================
function InitTrig_Core_Menu_Click takes nothing returns nothing
    set gg_trg_Core_Menu_Click=CreateTrigger()
    call TriggerRegisterDialogEventBJ(gg_trg_Core_Menu_Click, udg_UI_Ventana_General)
    call TriggerAddAction(gg_trg_Core_Menu_Click, function Trig_Core_Menu_Click_Actions)
endfunction
