//===========================================================================
// CORE: CLICK EN MENU DE HEROES + CAMARA INTELIGENTE + ULTRA SHORT TEXT
//===========================================================================
function Trig_Core_Menu_Heroes_Click_Actions takes nothing returns nothing
    
    // --- 1. CONFIGURAR MODOS SEGUN EL BOTON ---
    if (GetClickedButton() == udg_UI_Boton_TodosPick) then
        set udg_Config_Modo_Humanos = 1
        set udg_Config_Modo_Orcos = 1
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10.0, "|cFFFFCC00Modo Heroes:|r All Pick Seleccionado")
        
    elseif (GetClickedButton() == udg_UI_Boton_TodosRandom) then
        set udg_Config_Modo_Humanos = 2
        set udg_Config_Modo_Orcos = 2
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10.0, "|cFFFFCC00Modo Heroes:|r All Random Seleccionado")
        
    elseif (GetClickedButton() == udg_UI_Boton_HumPick_OrcRnd) then
        set udg_Config_Modo_Humanos = 1
        set udg_Config_Modo_Orcos = 2
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10.0, "|cFFFFCC00Modo Heroes:|r Humanos Eligen / Orcos Random")
        
    else // (Boton HumRnd_OrcPick)
        set udg_Config_Modo_Humanos = 2
        set udg_Config_Modo_Orcos = 1
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10.0, "|cFFFFCC00Modo Heroes:|r Humanos Random / Orcos Eligen")
    endif

    // --- 2. MOSTRAR PANTALLA 3: MODO DE HABILIDADES ---
    // La lógica de cámara, descongelar, random, shuffle e IA
    // ahora vive en Core_Menu_Habilidades.j (MenuHabilidades library).
    call MenuHabilidades_MostrarPantalla()

endfunction

//===========================================================================
function InitTrig_Core_Menu_Heroes_Click takes nothing returns nothing
    set gg_trg_Core_Menu_Heroes_Click = CreateTrigger()
    call TriggerRegisterDialogEvent(gg_trg_Core_Menu_Heroes_Click, udg_UI_Ventana_Heroes)
    call TriggerAddAction(gg_trg_Core_Menu_Heroes_Click, function Trig_Core_Menu_Heroes_Click_Actions)
endfunction