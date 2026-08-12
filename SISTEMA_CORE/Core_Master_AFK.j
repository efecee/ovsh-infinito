// Sistema: CoreMasterAFK
// Monitorea si el Master está AFK o abandona durante los menús de configuración.
// - 1 jugador:  PauseGame directo, sin timer. Espera infinita.
// - 2+ jugadores: Congela solo Wisps/Almas + timer 15s para rotar.
//
// INTEGRACIÓN CON SISTEMA VOTO:
// Sistema_Voto DIFIERE toda votación hasta que la configuración termina
// (SistemaVoto_OnMenusFinished al final de EjecutarPostSeleccion), así que
// durante la fase de menús NUNCA hay encuesta activa. Por eso, si el master
// sale durante los menús, rotamos DE INMEDIATO y re-ejecutamos Core_Menu_Oro
// (esperar al fin del voto sería un deadlock: los menús huérfanos jamás
// terminarían y la votación diferida jamás se abriría).
// PendingRotation/PostVoteCheck quedan como legado no-op (ver abajo).

library CoreMasterAFK initializer Init
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
    // CONTAR JUGADORES HUMANOS ACTIVOS
    // ==========================================================
    private function CountHumanPlayers takes nothing returns integer
        local integer i = 0
        local integer count = 0
        loop
            exitwhen i >= 10
            if GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                set count = count + 1
            endif
            set i = i + 1
        endloop
        return count
    endfunction

    // ==========================================================
    // BUSCAR SIGUIENTE MASTER HUMANO
    // Retorna true si encontró uno (o el actual sigue válido).
    // ==========================================================
    private function FindNextMaster takes nothing returns boolean
        local integer currentId = GetPlayerId(udg_Core_JugadorMaestro)
        local integer i = currentId + 1
        local player p
        
        // Buscar hacia abajo
        loop
            exitwhen i >= 10
            set p = Player(i)
            if GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(p) == MAP_CONTROL_USER then
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
            if GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(p) == MAP_CONTROL_USER then
                set udg_Core_JugadorMaestro = p
                return true
            endif
            set i = i + 1
        endloop
        
        // Verificar si el master actual sigue válido (único jugador)
        return GetPlayerSlotState(udg_Core_JugadorMaestro) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(udg_Core_JugadorMaestro) == MAP_CONTROL_USER
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
        
        // Re-ejecutar Core_Menu_Oro: reconstruye el diálogo completo
        // (con TODOS los botones + título), lo muestra al master actual,
        // y llama Start() que maneja timer/lock según cantidad de jugadores.
        call TriggerExecute(gg_trg_Core_Menu_Oro)
    endfunction
    
    // ==========================================================
    // API PÚBLICA
    // ==========================================================

    // Valida que el Master actual siga conectado y sea humano; si no, rota
    // al siguiente. Lo llama Core_Menu_Oro ANTES de mostrar el primer menú:
    // cubre al Master que cerró durante la pantalla de carga o en el primer
    // segundo (Core_DetectarHost corre a 0.05s; el menú recién a 1.00s).
    // Sin esto, el menú se muestra a un fantasma y nadie puede configurar.
    public function EnsureMasterValid takes nothing returns nothing
        local integer oldId = GetPlayerId(udg_Core_JugadorMaestro)
        if GetPlayerSlotState(udg_Core_JugadorMaestro) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(udg_Core_JugadorMaestro) == MAP_CONTROL_USER then
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
        
        // Re-ejecutar Core_Menu_Oro (reconstruye diálogo y llama Start)
        call TriggerExecute(gg_trg_Core_Menu_Oro)
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
        loop
            exitwhen i >= 10
            call TriggerRegisterPlayerEvent(t, Player(i), EVENT_PLAYER_LEAVE)
            set i = i + 1
        endloop
        call TriggerAddAction(t, function OnPlayerLeave)
        set t = null
    endfunction
endlibrary
