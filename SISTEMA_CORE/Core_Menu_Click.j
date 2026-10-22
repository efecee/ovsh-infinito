//===========================================================================
// CORE: CLIC EN EL MENU DE ORO
//===========================================================================
// Al hacer clic en el menu de Core_Menu_Oro.j: congela el juego (fin de la
// espera del Master), guarda en Config_Cantidad_Oro la renta elegida, la anuncia
// a todos y abre la pantalla de heroes (detonador Core_Menu_Heroes).
//
// La renta de cada boton depende del modo de partida (Core_Menu_Modo.j):
//   Boton        Normal   Rapido
//   1a opcion       6       12     (UI_Boton_OroBajo)
//   2a opcion       9       15     (UI_Boton_OroNormal)
//   3a opcion      12       18     (UI_Boton_OroRapido)
//
// TEXTO PERSONALIZADO (antes era GUI). En el editor: seleccionar el detonador
// "Core_Menu_Click", Editar > Convertir en texto personalizado, y reemplazar
// todo por este archivo.
//
// Variables del gestor de variables (udg_) que usa:
//   UI_Ventana_General, UI_Boton_OroNormal/Rapido, Config_Cantidad_Oro.
//   (El boton UI_Boton_OroBajo no se compara: es el caso "si no", igual que en
//   el GUI; cualquier otro clic deja la 1a opcion.)
//   Si cambian estos valores, Sistema_Victoria.j (SV_GoldPoints) se adapta
//   solo: escala el oro por punto con la renta, tomando 12 como referencia.
//===========================================================================

function CoreMenuClick_OnClick takes nothing returns nothing
    local button clicked = GetClickedButton()
    local integer renta1 = 6
    local integer renta2 = 9
    local integer renta3 = 12

    // Detener el temporizador AFK y congelar el juego: el Master respondio.
    // (Si la sala no tiene bots, el juego ya estaba congelado desde el clic en
    // la pantalla de modo; repetirlo no cambia nada.)
    call CoreMasterAFK_Stop()

    if (ModoPartida_EsRapido()) then
        set renta1 = 12
        set renta2 = 15
        set renta3 = 18
    endif

    if (clicked == udg_UI_Boton_OroNormal) then
        set udg_Config_Cantidad_Oro = renta2
    elseif (clicked == udg_UI_Boton_OroRapido) then
        set udg_Config_Cantidad_Oro = renta3
    else
        set udg_Config_Cantidad_Oro = renta1
    endif
    call DisplayTimedTextToForce(GetPlayersAll(), 10.00, "|cFFFFCC00Modo:|r " + I2S(udg_Config_Cantidad_Oro) + " Oro/seg activado.")

    // Pantalla de heroes (ignorando condiciones, como en el GUI).
    call TriggerExecute(gg_trg_Core_Menu_Heroes)

    set clicked = null
endfunction

//===========================================================================
function InitTrig_Core_Menu_Click takes nothing returns nothing
    set gg_trg_Core_Menu_Click = CreateTrigger()
    // udg_UI_Ventana_General ya existe aqui: el editor lo crea (DialogCreate)
    // al inicializar las variables, antes de cualquier InitTrig_.
    call TriggerRegisterDialogEvent(gg_trg_Core_Menu_Click, udg_UI_Ventana_General)
    call TriggerAddAction(gg_trg_Core_Menu_Click, function CoreMenuClick_OnClick)
endfunction
