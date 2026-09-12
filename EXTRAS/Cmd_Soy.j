//===========================================================================
// COMANDO -soy  |  Anuncio del Master
// Solo el jugador con el nick definido en GetMasterNick() puede activarlo.
//===========================================================================

// >>> CAMBIA TU NICK AQUÍ (respetando mayúsculas/minúsculas) <<<
function GetMasterNick takes nothing returns string
    return "MateriaViva"
endfunction

//===========================================================================
function Trig_Soy_Actions takes nothing returns nothing
    local player p  = GetTriggerPlayer()
    local string nombre = GetPlayerName(p)

    if (nombre == GetMasterNick()) then
        call Replay_DisplayTimedTextToAll(10.0, " ")
        call Replay_DisplayTimedTextToAll(10.0, "|cffFFCC00════════════════════════════════════════════|r")
        call Replay_DisplayTimedTextToAll(10.0, " ")
        call Replay_DisplayTimedTextToAll(10.0, "         |cff00FF00Orcos vs Humanos Infinito 2.0|r")
        call Replay_DisplayTimedTextToAll(10.0, " ")
        call Replay_DisplayTimedTextToAll(10.0, "   |cffAAAAAAEl editor de esta version esta en la sala.|r")
        call Replay_DisplayTimedTextToAll(10.0, " ")
        call Replay_DisplayTimedTextToAll(10.0, "|cffFFCC00════════════════════════════════════════════|r")
    endif

    set p = null
endfunction

//===========================================================================
function InitTrig_Cmd_Soy takes nothing returns nothing
    local trigger trg = CreateTrigger()
    local integer i   = 0

    loop
        exitwhen i > 9
        call TriggerRegisterPlayerChatEvent(trg, Player(i), "-soy", true)
        set i = i + 1
    endloop

    call TriggerAddAction(trg, function Trig_Soy_Actions)
endfunction
