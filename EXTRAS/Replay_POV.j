//===========================================================================
// SISTEMA: DETECCION DEL POV ACTUAL EN REPETICIONES
//===========================================================================
// Basado en GameStatus v1.0.0 (TriggerHappy) y Replay POV Detection v1.0.0
// (InsanityAI / sotzaii_shuen).
//
// GetReplayPlayer() / GetReplayPlayerCached():
//   - En una partida normal devuelve GetLocalPlayer() inmediatamente.
//   - En una repeticion devuelve el jugador cuyo POV esta seleccionado.
//   - Si no puede detectarlo, vuelve de forma segura a GetLocalPlayer().
//   - La variante Cached evita sondear leaderboards en cada frame de interfaz.
//
// Replay_DisplayTextToAll() / Replay_DisplayTimedTextToAll():
//   - Envia avisos publicos directamente a cada slot para que tambien sean
//     visibles desde cualquier POV de una repeticion.
//
// IMPORTANTE: el resultado puede ser distinto en cada cliente. Debe usarse
// unicamente para operaciones locales de interfaz/camara, nunca para cambiar
// unidades, recursos, votos ni cualquier otro estado sincronizado.
//===========================================================================

library GameStatus initializer GameStatus_Init

    globals
        constant integer GAME_STATUS_OFFLINE = 0
        constant integer GAME_STATUS_ONLINE  = 1
        constant integer GAME_STATUS_REPLAY  = 2

        private constant integer GAME_STATUS_DUMMY_ID = 'hfoo'
        private integer GameStatus_Value = GAME_STATUS_OFFLINE
    endglobals

    function GetGameStatus takes nothing returns integer
        return GameStatus_Value
    endfunction

    private function GameStatus_Init takes nothing returns nothing
        local player firstPlayer = Player(0)
        local unit dummy
        local boolean selected

        // Todo mapa jugable tiene al menos un slot humano activo. Se usa solo
        // durante la inicializacion y el dummy se elimina inmediatamente.
        loop
            exitwhen GetPlayerController(firstPlayer) == MAP_CONTROL_USER and GetPlayerSlotState(firstPlayer) == PLAYER_SLOT_STATE_PLAYING
            set firstPlayer = Player(GetPlayerId(firstPlayer) + 1)
        endloop

        set dummy = CreateUnit(firstPlayer, GAME_STATUS_DUMMY_ID, 0.0, 0.0, 0.0)
        call SelectUnit(dummy, true)
        set selected = IsUnitSelected(dummy, firstPlayer)
        call RemoveUnit(dummy)

        if selected then
            if ReloadGameCachesFromDisk() then
                set GameStatus_Value = GAME_STATUS_OFFLINE
            else
                set GameStatus_Value = GAME_STATUS_REPLAY
            endif
        else
            set GameStatus_Value = GAME_STATUS_ONLINE
        endif

        set dummy = null
        set firstPlayer = null
    endfunction

endlibrary

library ReplayPOVDetection initializer ReplayPOV_Init requires GameStatus

    globals
        private leaderboard ReplayPOV_Board = null
        private player ReplayPOV_CachedPlayer = null
    endglobals

    // Avisos publicos compatibles con el POV de las repeticiones. En partida
    // normal cada cliente recibe una sola copia: la destinada a su propio slot.
    function Replay_DisplayTimedTextToAll takes real duration, string message returns nothing
        local integer i = 0
        loop
            exitwhen i > 9
            call DisplayTimedTextToPlayer(Player(i), 0, 0, duration, message)
            set i = i + 1
        endloop
    endfunction

    function Replay_DisplayTextToAll takes string message returns nothing
        local integer i = 0
        loop
            exitwhen i > 9
            call DisplayTextToPlayer(Player(i), 0, 0, message)
            set i = i + 1
        endloop
    endfunction

    function GetReplayPlayer takes nothing returns player
        local leaderboard previousBoard = null
        local player povPlayer = null
        local integer i = 0
        local boolean wasDisplayed = false
        local boolean found = false

        // Esta salida temprana es la proteccion principal del juego normal:
        // no asigna, muestra ni oculta leaderboards durante una partida.
        if GetGameStatus() != GAME_STATUS_REPLAY then
            return GetLocalPlayer()
        endif

        loop
            set povPlayer = Player(i)

            // Guardar y restaurar cualquier leaderboard previo del slot.
            set previousBoard = PlayerGetLeaderboard(povPlayer)
            if previousBoard != null then
                set wasDisplayed = IsLeaderboardDisplayed(previousBoard)
            else
                set wasDisplayed = false
            endif

            // PlayerSetLeaderboard lo muestra solamente para la UI cuyo POV
            // esta renderizando ese jugador. Esa propiedad revela el POV.
            call PlayerSetLeaderboard(povPlayer, ReplayPOV_Board)
            if IsLeaderboardDisplayed(ReplayPOV_Board) then
                set found = true
            endif

            if previousBoard != null then
                call PlayerSetLeaderboard(povPlayer, previousBoard)
                call LeaderboardDisplay(previousBoard, wasDisplayed)
            else
                call PlayerSetLeaderboard(povPlayer, null)
            endif

            if found then
                set i = bj_MAX_PLAYER_SLOTS
            else
                set i = i + 1
            endif
            exitwhen i >= bj_MAX_PLAYER_SLOTS
        endloop

        call LeaderboardDisplay(ReplayPOV_Board, false)

        if not found then
            set povPlayer = GetLocalPlayer()
        endif

        set previousBoard = null
        return povPlayer
    endfunction

    // El panel de -fondo se mueve a 33 FPS; hacer la deteccion completa en
    // cada frame seria innecesario. El HUD refresca este valor desde su timer
    // ya existente, evitando crear handles adicionales solo en repeticiones.
    function GetReplayPlayerCached takes nothing returns player
        if GetGameStatus() != GAME_STATUS_REPLAY then
            return GetLocalPlayer()
        endif
        if ReplayPOV_CachedPlayer == null then
            return GetReplayPlayer()
        endif
        return ReplayPOV_CachedPlayer
    endfunction

    function ReplayPOV_RefreshCache takes nothing returns nothing
        set ReplayPOV_CachedPlayer = GetReplayPlayer()
    endfunction

    private function ReplayPOV_Init takes nothing returns nothing
        set ReplayPOV_Board = CreateLeaderboard()
        call LeaderboardDisplay(ReplayPOV_Board, false)
        set ReplayPOV_CachedPlayer = GetLocalPlayer()
    endfunction

endlibrary
