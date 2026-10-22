//===========================================================================
// CORE: MENU DE HEROES (Pantalla 3 del Master; Pantalla 2 si hay bots)
//===========================================================================
// Muestra al Master el menu "Selecciona el Modo de Héroes". El clic lo procesa
// Core_Menu_Heroes_Click.j (fija Config_Modo_Humanos/Orcos y abre la pantalla
// de habilidades). Lo abre Core_Menu_Click.j con
// TriggerExecute(gg_trg_Core_Menu_Heroes): no tiene eventos.
//
// TEXTO PERSONALIZADO (antes era GUI). En el editor: seleccionar el detonador
// "Core_Menu_Heroes", Editar > Convertir en texto personalizado, y reemplazar
// todo por este archivo. El nombre del detonador NO debe cambiar.
// Conversion del GUI que tenia el mapa el 2026-10-20, escrita con las funciones
// directas del juego en vez de las del GUI (DialogClear en vez de DialogClearBJ,
// etc.): mismo comportamiento. Los textos ahora estan escritos aqui (antes eran
// TRIGSTR_3721 a 3725 del archivo de textos del mapa).
//
// Variables del gestor de variables (udg_) que usa:
//   UI_Ventana_Heroes (dialogo), UI_Boton_TodosPick / TodosRandom /
//   HumPick_OrcRnd / HumRnd_OrcPick (botones, los compara
//   Core_Menu_Heroes_Click.j), Core_JugadorMaestro (jugador).
//
// SALA DE SOLO BOTS (el Master es un observador, Core_Observadores.j): esta
// pantalla no se muestra. Nadie puede elegir heroe por los bots, asi que va
// directo a All Random, igual que si el Master hubiera hecho clic ahi.
//===========================================================================

function Trig_Core_Menu_Heroes_Actions takes nothing returns nothing
    if (not Observadores_HayJugadores()) then
        set udg_Config_Modo_Humanos = 2
        set udg_Config_Modo_Orcos = 2
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10.0, "|cFFFFCC00Modo Heroes:|r All Random (solo bots)")
        call MenuHabilidades_MostrarPantalla()
        return
    endif
    call DialogClear(udg_UI_Ventana_Heroes)
    call DialogSetMessage(udg_UI_Ventana_Heroes, "Selecciona el Modo de Héroes")
    set udg_UI_Boton_TodosPick      = DialogAddButton(udg_UI_Ventana_Heroes, "Todos Eligen (All Pick)", 0)
    set udg_UI_Boton_TodosRandom    = DialogAddButton(udg_UI_Ventana_Heroes, "Todos Aleatorio (All Random)", 0)
    set udg_UI_Boton_HumPick_OrcRnd = DialogAddButton(udg_UI_Ventana_Heroes, "Humanos: Pick / Orcos: Random", 0)
    set udg_UI_Boton_HumRnd_OrcPick = DialogAddButton(udg_UI_Ventana_Heroes, "Humanos: Random / Orcos: Pick", 0)
    call DialogDisplay(udg_Core_JugadorMaestro, udg_UI_Ventana_Heroes, true)
endfunction

//===========================================================================
function InitTrig_Core_Menu_Heroes takes nothing returns nothing
    set gg_trg_Core_Menu_Heroes = CreateTrigger()
    call TriggerAddAction(gg_trg_Core_Menu_Heroes, function Trig_Core_Menu_Heroes_Actions)
endfunction
