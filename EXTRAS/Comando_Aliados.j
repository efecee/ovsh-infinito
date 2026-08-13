//===========================================================================
// COMANDO: -aliados
// Muestra el oro actual de cada aliado activo del jugador que usa el comando.
// El reporte es privado: solo se envia al jugador que lo solicito.
//===========================================================================
scope ComandoAliados initializer Init

    private function IsActiveAlly takes player candidate, player requester returns boolean
        local integer id = GetPlayerId(candidate)

        if candidate == requester or not IsPlayerAlly(requester, candidate) then
            return false
        endif

        // Incluye humanos, computadoras y bots que reemplazaron a un jugador
        // tras la encuesta de abandono (flag 102 de udg_MB_Hash).
        if LoadBoolean(udg_MB_Hash, id, 102) then
            return true
        endif

        return GetPlayerSlotState(candidate) == PLAYER_SLOT_STATE_PLAYING and (GetPlayerController(candidate) == MAP_CONTROL_USER or GetPlayerController(candidate) == MAP_CONTROL_COMPUTER)
    endfunction

    private function Actions takes nothing returns nothing
        local player requester = GetTriggerPlayer()
        local player candidate
        local integer i = 0
        local integer allyCount = 0

        call DisplayTimedTextToPlayer(requester, 0, 0, 10.0, "|cffFFCC00=========== ORO DE ALIADOS ===========|r")

        // Los jugadores reales del mapa ocupan los slots 1-10 (indices 0-9),
        // igual que el comando -ma del init.
        loop
            exitwhen i > 9
            set candidate = Player(i)

            if IsActiveAlly(candidate, requester) then
                call DisplayTimedTextToPlayer(requester, 0, 0, 10.0, udg_strings01[i + 1] + GetPlayerName(candidate) + "|r: |cffFFCC00" + I2S(GetPlayerState(candidate, PLAYER_STATE_RESOURCE_GOLD)) + "|r")
                set allyCount = allyCount + 1
            endif

            set i = i + 1
        endloop

        if allyCount == 0 then
            call DisplayTimedTextToPlayer(requester, 0, 0, 10.0, "|cff888888No hay aliados activos.|r")
        endif

        call DisplayTimedTextToPlayer(requester, 0, 0, 10.0, "|cffFFCC00========================================|r")

        set requester = null
        set candidate = null
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer i = 0

        loop
            exitwhen i > 9
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-aliados", true)
            set i = i + 1
        endloop

        call TriggerAddAction(t, function Actions)
        set t = null
    endfunction

endscope
