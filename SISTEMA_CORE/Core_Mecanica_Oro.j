//===========================================================================
// CORE: RENTA DE ORO POR SEGUNDO
//===========================================================================
// Cada segundo de juego suma Config_Cantidad_Oro al oro de cada jugador
// (slots 0-9). Los observadores (Player(10) y Player(11), Core_Observadores.j)
// y los neutrales no cobran.
//
// TEXTO PERSONALIZADO (antes era GUI). En el editor: seleccionar el detonador
// "Core_Mecanica_Oro", Editar > Convertir en texto personalizado, y reemplazar
// todo por este archivo.
//
// Config_Cantidad_Oro es una variable del gestor de variables (udg_). Alli su
// valor inicial es 1, pero InitTrig_Core_Mecanica_Oro la pone en 0: con 2+
// humanos el tiempo corre mientras el Master decide, y nadie debe cobrar renta
// antes de que elija. Core_Menu_Click.j la REEMPLAZA (no suma) por 6/9/12
// (Normal) o 12/15/18 (Rapido). Si el Master rota, CoreMenuModo_Mostrar
// (Core_Menu_Modo.j) la vuelve a 0 hasta que el nuevo elija.
//
// TODOS cobran, hayan elegido heroe o no (igual que en la 2.1). Antes de que
// el Master elija el oro la renta vale 0, y despues el juego sigue congelado
// hasta que termina de configurar: en la practica, todos empiezan a cobrar
// al terminar la configuracion.
//===========================================================================

// Paga la renta a p. Las dos lineas van JUNTAS: el oro y la linea base del
// detector F11.
function CoreRenta_PagarJugador takes player p returns nothing
    // AdjustPlayerStateBJ (no SetPlayerState): ademas del oro actual suma el
    // "oro recolectado" de la pantalla de puntuaciones, como hacia el GUI.
    call AdjustPlayerStateBJ(udg_Config_Cantidad_Oro, p, PLAYER_STATE_RESOURCE_GOLD)
    // NO BORRAR. Sync de la linea base del detector de oro F11
    // (Comandos_Economia.j). El detector fotografia el oro de cada jugador
    // cada 0.10s y reconoce un regalo F11 como un par EXACTO entre aliados:
    // emisor -X / receptor +X. La renta suma oro a todos; si no se avisara a
    // la base, en el tick en que coincide con un regalo (p.ej. 500 con renta
    // 12) se veria -488 / +512: el par no cuadra y el regalo se pierde (no
    // cuenta para Donador). Avanzar la base por la renta la vuelve invisible
    // al sondeo.
    set Eco_GoldBaseline[GetPlayerId(p)] = Eco_GoldBaseline[GetPlayerId(p)] + udg_Config_Cantidad_Oro
endfunction

function CoreRenta_Tick takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i > 9
        call CoreRenta_PagarJugador(Player(i))
        set i = i + 1
    endloop
endfunction

//===========================================================================
function InitTrig_Core_Mecanica_Oro takes nothing returns nothing
    // Renta 0 hasta que el Master elija la cantidad (pisa el 1 del gestor de
    // variables; los InitTrig_ corren despues de inicializar las variables).
    set udg_Config_Cantidad_Oro = 0
    set gg_trg_Core_Mecanica_Oro = CreateTrigger()
    call TriggerRegisterTimerEvent(gg_trg_Core_Mecanica_Oro, 1.00, true)
    call TriggerAddAction(gg_trg_Core_Mecanica_Oro, function CoreRenta_Tick)
endfunction
