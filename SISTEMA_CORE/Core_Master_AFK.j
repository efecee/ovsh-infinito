// Sistema: CoreMasterAFK
// Monitorea si el Master está AFK o abandona durante los menús de configuración.
// - 1 jugador:  PauseGame directo, sin timer. Espera infinita.
// - 2+ jugadores: Congela solo Wisps/Almas + timer 15s para rotar.
//
// INTEGRACIÓN CON SISTEMA VOTO:
// Sistema_Voto DIFIERE toda votación hasta que la configuración termina
// (SistemaVoto_OnMenusFinished al final de EjecutarPostSeleccion), así que
// durante la fase de menús NUNCA hay encuesta activa. Por eso, si el master
// sale durante los menús, rotamos DE INMEDIATO y re-ejecutamos Core_Menu_Modo
// (esperar al fin del voto sería un deadlock: los menús huérfanos jamás
// terminarían y la votación diferida jamás se abriría).
//
// PRIMERA PANTALLA: Core_Menu_Modo (modo de partida). Con bots esa pantalla
// no se muestra y la primera visible es la de oro; Core_Menu_Modo lo resuelve
// solo, así que aquí siempre se re-ejecuta Core_Menu_Modo.
// PendingRotation/PostVoteCheck quedan como legado no-op (ver abajo).
//
// OBSERVADORES: quien puede ser Master lo decide Observadores_PuedeSerMaster
// (Core_Observadores.j). Con al menos un humano jugando en los slots 1-10,
// solo ellos, como siempre. En una sala de solo bots, los observadores: con
// dos, el rol rota entre ellos cada 15 s igual que entre jugadores.

library CoreMasterAFK initializer Init requires Observadores
    globals
        private timer   AFK_Timer        = CreateTimer()
        private boolean MasterHasResponded = false
        private boolean MenuPhaseActive  = false
        private integer HumanPlayerCount = 0
        private boolean PendingRotation  = false
    endglobals

    // ==========================================================
    // CONGELAR/DESCONGELAR SELECTORES (Wisps y Almas Corruptas)
    // Solo estas unidades se congelan para evitar que los jugadores
    // seleccionen héroes prematuramente durante la espera del Master.
    // NO congelamos creeps de spawners (causa pérdida de órdenes).
    // ==========================================================
    private function LockSelectors takes nothing returns nothing
        // Humanos: Wisps
        call PauseUnit(udg_unit14, true)
        call PauseUnit(udg_unit15, true)
        call PauseUnit(udg_unit16, true)
        call PauseUnit(udg_unit17, true)
        call PauseUnit(udg_unit18, true)
        // Orcos: Almas Corruptas
        call PauseUnit(udg_unit39, true)
        call PauseUnit(udg_unit40, true)
        call PauseUnit(udg_unit41, true)
        call PauseUnit(udg_unit42, true)
        call PauseUnit(udg_unit43, true)
    endfunction
    
    public function UnlockSelectors takes nothing returns nothing
        call PauseUnit(udg_unit14, false)
        call PauseUnit(udg_unit15, false)
        call PauseUnit(udg_unit16, false)
        call PauseUnit(udg_unit17, false)
        call PauseUnit(udg_unit18, false)
        call PauseUnit(udg_unit39, false)
        call PauseUnit(udg_unit40, false)
        call PauseUnit(udg_unit41, false)
        call PauseUnit(udg_unit42, false)
        call PauseUnit(udg_unit43, false)
    endfunction

    // ==========================================================
    // CONTAR CANDIDATOS A MASTER (humanos 0-9, u observadores si no hay)
    // ==========================================================
    private function CountHumanPlayers takes nothing returns integer
        local integer i = 0
        local integer count = 0
        loop
            exitwhen i >= 12
            if Observadores_PuedeSerMaster(Player(i)) then
                set count = count + 1
            endif
            set i = i + 1
        endloop
        return count
    endfunction

    // ==========================================================
    // BUSCAR SIGUIENTE MASTER (slots 0-11: los observadores son 10-11)
    // Retorna true si encontró uno (o el actual sigue válido).
    // ==========================================================
    private function FindNextMaster takes nothing returns boolean
        local integer currentId = GetPlayerId(udg_Core_JugadorMaestro)
        local integer i = currentId + 1
        local player p

        // Buscar hacia abajo
        loop
            exitwhen i >= 12
            set p = Player(i)
            if Observadores_PuedeSerMaster(p) then
                set udg_Core_JugadorMaestro = p
                return true
            endif
            set i = i + 1
        endloop

        // Dar la vuelta desde arriba
        set i = 0
        loop
            exitwhen i >= currentId
            set p = Player(i)
            if Observadores_PuedeSerMaster(p) then
                set udg_Core_JugadorMaestro = p
                return true
            endif
            set i = i + 1
        endloop

        // Verificar si el master actual sigue válido (único jugador)
        return Observadores_PuedeSerMaster(udg_Core_JugadorMaestro)
    endfunction

    // ==========================================================
    // ROTACIÓN DE MASTER (llamada por el timer de 15s)
    // ==========================================================
    private function RotarMaster takes nothing returns nothing
        local integer oldId = GetPlayerId(udg_Core_JugadorMaestro)
        
        if not FindNextMaster() then
            return
        endif
        
        // Mensaje solo si cambió de master
        if GetPlayerId(udg_Core_JugadorMaestro) != oldId then
            call DisplayTimedTextToForce(GetPlayersAll(), 10.00, "Master AFK, perdió el rol.")
            call DisplayTimedTextToForce(GetPlayersAll(), 10.00, "El nuevo Master es: |cffFFCC00" + GetPlayerName(udg_Core_JugadorMaestro) + "|r")
            if GetPlayerSlotState(Player(oldId)) == PLAYER_SLOT_STATE_PLAYING then
                call DialogDisplay(Player(oldId), udg_UI_Ventana_General, false)
            endif
        endif
        
        // Re-ejecutar Core_Menu_Modo: vuelve a la primera pantalla, oculta su
        // ventana al master anterior, la muestra al actual y llama Start(),
        // que maneja timer/lock según cantidad de jugadores.
        call TriggerExecute(gg_trg_Core_Menu_Modo)
    endfunction
    
    // ==========================================================
    // API PÚBLICA
    // ==========================================================

    // Valida que el Master actual siga conectado y sea humano; si no, rota
    // al siguiente. Lo llama Core_Menu_Modo ANTES de mostrar el primer menú:
    // cubre al Master que cerró durante la pantalla de carga o en el primer
    // segundo (Core_DetectarHost corre a 0.05s; el menú recién a 1.00s).
    // Sin esto, el menú se muestra a un fantasma y nadie puede configurar.
    public function EnsureMasterValid takes nothing returns nothing
        local integer oldId = GetPlayerId(udg_Core_JugadorMaestro)
        if Observadores_PuedeSerMaster(udg_Core_JugadorMaestro) then
            return
        endif
        if FindNextMaster() and GetPlayerId(udg_Core_JugadorMaestro) != oldId then
            call DisplayTimedTextToForce(GetPlayersAll(), 10.00, "El nuevo Master es: |cffFFCC00" + GetPlayerName(udg_Core_JugadorMaestro) + "|r")
        endif
    endfunction

    public function Start takes nothing returns nothing
        set MasterHasResponded = false
        set MenuPhaseActive = true
        set PendingRotation = false
        
        set HumanPlayerCount = CountHumanPlayers()
        
        if HumanPlayerCount >= 2 then
            // 2+ jugadores: juego despausado, selectores congelados, timer 15s.
            call PauseGame(false)
            call LockSelectors()
            // Restaurar multiboard (WC3 lo oculta al mostrar Dialog + PauseGame(false))
            call MultiboardDisplay(udg_MB_Tabla, true)
            call MultiboardMinimize(udg_MB_Tabla, false)
            call TimerStart(AFK_Timer, 15.0, false, function RotarMaster)
        else
            // 1 jugador: PauseGame directo. Sin timer. Espera infinita.
            call PauseGame(true)
        endif
    endfunction
    
    public function Stop takes nothing returns nothing
        // Idempotente: sin bots, el clic en la pantalla de oro vuelve a llamar
        // Stop con el juego ya congelado por el clic en la de modo. No repetir
        // PauseGame (Sistema_Voto.j advierte que tiene límite de usos online).
        // Start() vuelve a poner MasterHasResponded en false.
        if MasterHasResponded then
            return
        endif
        set MasterHasResponded = true
        call PauseTimer(AFK_Timer)
        // Recongelar el juego ahora que el Master respondió
        call PauseGame(true)
    endfunction
    
    // Señala que la fase de menús terminó. Llamar tras el último menú.
    // Restaura el multiboard que WC3 oculta al mostrar Dialogs.
    public function Finish takes nothing returns nothing
        set MenuPhaseActive = false
        // WC3 oculta el multiboard cuando se muestra un Dialog.
        // Forzar su visibilidad ahora que los menús terminaron.
        call MultiboardDisplay(udg_MB_Tabla, true)
        call MultiboardMinimize(udg_MB_Tabla, false)
    endfunction
    
    // ==========================================================
    // HOOK POST-VOTO: Sistema Voto llama esto al terminar la encuesta.
    // LEGADO (voto diferido): PendingRotation ya no se setea nunca — la
    // rotación por abandono del master ahora es inmediata en OnPlayerLeave —
    // así que esto siempre retorna sin hacer nada. Se conserva solo porque
    // Voto_Resolver aún lo llama. Candidato a limpieza futura.
    // ==========================================================
    public function PostVoteCheck takes nothing returns nothing
        if not PendingRotation or not MenuPhaseActive then
            return
        endif
        set PendingRotation = false
        
        // Buscar al siguiente master humano
        if not FindNextMaster() then
            return
        endif
        
        // Re-ejecutar Core_Menu_Modo (primera pantalla; llama Start)
        call TriggerExecute(gg_trg_Core_Menu_Modo)
    endfunction
    
    // ==========================================================
    // EVENTO: Un jugador abandona durante la fase de menús
    // ==========================================================
    private function OnPlayerLeave takes nothing returns nothing
        local player p = GetTriggerPlayer()
        if p == udg_Core_JugadorMaestro and MenuPhaseActive then
            // Rotar DE INMEDIATO. El voto está DIFERIDO durante los menús
            // (Sistema_Voto), así que aquí nunca hay encuesta activa que un
            // nuevo menú pueda pisar. Esperar a PostVoteCheck (lógica vieja)
            // sería deadlock: sin master no terminan los menús, y sin menús
            // terminados el voto diferido jamás se abre.
            call PauseTimer(AFK_Timer)
            call RotarMaster()
        endif
    endfunction

    // ==========================================================
    // INICIALIZACIÓN
    // ==========================================================
    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer i = 0
        // Hasta 11: un observador tambien puede ser Master (sala de solo bots).
        loop
            exitwhen i >= 12
            call TriggerRegisterPlayerEvent(t, Player(i), EVENT_PLAYER_LEAVE)
            set i = i + 1
        endloop
        call TriggerAddAction(t, function OnPlayerLeave)
        set t = null
    endfunction
endlibrary
