//===========================================================================
// COMANDO: -merito (REPORTE FINANCIERO)
// Muestra el oro generado activamente por el jugador.
//===========================================================================
function Trig_Cmd_Merito_Actions takes nothing returns nothing
    local player p = GetTriggerPlayer()
    local integer id = GetPlayerId(p)
    local integer totalGold = LoadInteger(udg_MB_Hash, id, 3)
    local string color = "|cffFFFF00" // Amarillo Oro
    
    // Mostrar mensaje solo al jugador que preguntó
    call DisplayTimedTextToPlayer(p, 0, 0, 7.0, "Has generado " + color + I2S(totalGold) + "|r de oro por merito propio.")
    
    set p = null
endfunction

//===========================================================================
function InitTrig_Comando_Merito takes nothing returns nothing
    local integer i = 0
    set gg_trg_Comando_Merito = CreateTrigger()
    
    loop
        exitwhen i > 9
        // Comando "-merito"
        call TriggerRegisterPlayerChatEvent(gg_trg_Comando_Merito, Player(i), "-merito", true)
        set i = i + 1
    endloop
    
    call TriggerAddAction(gg_trg_Comando_Merito, function Trig_Cmd_Merito_Actions)
endfunction