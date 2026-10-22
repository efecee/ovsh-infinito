//===========================================================================
// CORE: MENU DE ORO (Pantalla 2 del Master; Pantalla 1 si hay bots)
//===========================================================================
// Muestra al Master el menu "Oro por Segundo". Las opciones dependen del modo
// de partida elegido en la Pantalla 1 (Core_Menu_Modo.j):
//   Normal: 6 / 9 / 12 Oro/seg   (por defecto, en blanco: 12)
//   Rapido: 12 / 15 / 18 Oro/seg (por defecto, en blanco: 18)
// El clic lo procesa Core_Menu_Click.j (fija Config_Cantidad_Oro y abre la
// pantalla de heroes, Core_Menu_Heroes).
//
// QUIEN LO ABRE: Core_Menu_Modo.j, con TriggerExecute(gg_trg_Core_Menu_Oro):
// tras el clic en la Pantalla 1, o directo si la sala tiene bots (sin bots no
// hay Modo Rapido). Este detonador ya NO tiene evento propio: antes se abria
// solo a 1 s de partida, y eso ahora lo hace Core_Menu_Modo. El nombre del
// detonador NO debe cambiar: Core_Menu_Modo.j lo ejecuta por su nombre.
//
// TEXTO PERSONALIZADO (antes era GUI). En el editor: seleccionar el detonador
// "Core_Menu_Oro", Editar > Convertir en texto personalizado, y reemplazar todo
// por este archivo.
//
// PAUSA / AFK: este menu no toca la pausa. Si es la primera pantalla (sala con
// bots), Core_Menu_Modo.j llama CoreMasterAFK_Start despues de mostrarlo. Si es
// la segunda, el juego ya esta congelado desde el clic en la Pantalla 1.
//
// COLORES DE LOS BOTONES: el juego pinta SIEMPRE de blanco la primera opcion
// del dialogo. Para que el "camino por defecto" en blanco sea la TERCERA, se
// fuerza la primera al dorado normal de los botones y la tercera a blanco.
//
// Variables del gestor de variables (udg_) que usa:
//   UI_Ventana_General (dialogo), UI_Boton_OroBajo/Normal/Rapido (botones, en
//   ese orden: 1a, 2a y 3a opcion), Core_JugadorMaestro (jugador).
//   (UI_Boton_OroInsano era la 4a opcion, 15 Oro/seg; ya no se usa.)
//===========================================================================

function CoreMenuOro_Mostrar takes nothing returns nothing
    call DialogClear(udg_UI_Ventana_General)
    call DialogSetMessage(udg_UI_Ventana_General, "Oro por Segundo")
    if (ModoPartida_EsRapido()) then
        set udg_UI_Boton_OroBajo   = DialogAddButton(udg_UI_Ventana_General, "|cFFFFCC0012 Oro/seg|r", 0)
        set udg_UI_Boton_OroNormal = DialogAddButton(udg_UI_Ventana_General, "15 Oro/seg", 0)
        set udg_UI_Boton_OroRapido = DialogAddButton(udg_UI_Ventana_General, "|cFFFFFFFF18 Oro/seg|r", 0)
    else
        set udg_UI_Boton_OroBajo   = DialogAddButton(udg_UI_Ventana_General, "|cFFFFCC006 Oro/seg|r", 0)
        set udg_UI_Boton_OroNormal = DialogAddButton(udg_UI_Ventana_General, "9 Oro/seg", 0)
        set udg_UI_Boton_OroRapido = DialogAddButton(udg_UI_Ventana_General, "|cFFFFFFFF12 Oro/seg|r", 0)
    endif
    call DialogDisplay(udg_Core_JugadorMaestro, udg_UI_Ventana_General, true)
endfunction

//===========================================================================
function InitTrig_Core_Menu_Oro takes nothing returns nothing
    set gg_trg_Core_Menu_Oro = CreateTrigger()
    call TriggerAddAction(gg_trg_Core_Menu_Oro, function CoreMenuOro_Mostrar)
endfunction
