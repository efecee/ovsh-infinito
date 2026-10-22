//===========================================================================
// IA: ARRANCAR (fin del minuto para elegir heroe a los bots)
//===========================================================================
// Al vencer udg_IA_Temporizador (el minuto que abre IA_Permisos.j): borra la
// ventana del reloj, suena el aviso, anuncia que los bots atacan y enciende la
// IA (IACore_InitializeBots).
//
// TEXTO PERSONALIZADO (antes era GUI). En el editor: seleccionar el detonador
// "IA_Arrancar", Editar > Convertir en texto personalizado, y reemplazar todo
// por este archivo. El nombre del detonador NO debe cambiar.
// Conversion 1:1 del GUI que tenia el mapa el 2026-10-20: mismo comportamiento.
// El texto ahora esta escrito aqui (antes era TRIGSTR_3796).
//===========================================================================
function Trig_IA_Arrancar_Actions takes nothing returns nothing
    call DestroyTimerDialogBJ(udg_IA_Ventana_Tiempo)
    call PlaySoundBJ(gg_snd_ClanInvitation)
    call DisplayTimedTextToForce(GetPlayersAll(), 5.00, "Fase de selección |cffFFCC00terminada!|r Los bots atacan.")
    call IACore_InitializeBots()
endfunction

//===========================================================================
function InitTrig_IA_Arrancar takes nothing returns nothing
    set gg_trg_IA_Arrancar=CreateTrigger()
    call TriggerRegisterTimerExpireEventBJ(gg_trg_IA_Arrancar, udg_IA_Temporizador)
    call TriggerAddAction(gg_trg_IA_Arrancar, function Trig_IA_Arrancar_Actions)
endfunction
