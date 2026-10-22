//===========================================================================
// CORE: LOGICA RANDOM (heroes aleatorios)
//===========================================================================
// Crea el heroe al azar de cada jugador cuyo equipo esta en Random
// (Config_Modo_Humanos/Orcos == 2), sin repetir heroe dentro del equipo, y
// borra su wisp ('ewsp') o su alma ('e006'). Si la sala tiene bots y los DOS
// equipos son Random, avisa y enciende la IA a los 25 s.
// Lo ejecuta Core_Menu_Habilidades.j (TriggerExecute) al terminar los menus si
// algun equipo es Random. No tiene eventos.
//
// TEXTO PERSONALIZADO (antes era GUI). En el editor: seleccionar el detonador
// "Core_Logica_Random", Editar > Convertir en texto personalizado, y reemplazar todo
// por este archivo. El nombre del detonador NO debe cambiar.
// Conversion 1:1 del GUI que tenia el mapa el 2026-10-20: mismo comportamiento.
// Los textos ahora estan escritos aqui (antes eran TRIGSTR_3777/3784/3795 del
// archivo de textos del mapa). La espera de 25 s (TriggerSleepAction) viene del
// GUI y se dejo igual: funciona porque corre como accion de detonador.
//===========================================================================
function Trig_Core_Logica_Random_Func001Func002Func005Func012002 takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Core_Logica_Random_Func001Func002Func005C takes nothing returns boolean
    if ( not ( GetConvertedPlayerId(udg_TempPlayer) <= 5 ) ) then
        return false
    endif
    if ( not ( udg_Config_Modo_Humanos == 2 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Core_Logica_Random_Func001Func002Func006Func012002 takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Core_Logica_Random_Func001Func002Func006C takes nothing returns boolean
    if ( not ( GetConvertedPlayerId(udg_TempPlayer) >= 6 ) ) then
        return false
    endif
    if ( not ( udg_Config_Modo_Orcos == 2 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Core_Logica_Random_Func001Func002C takes nothing returns boolean
    if ( not ( GetConvertedPlayerId(udg_TempPlayer) <= 10 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Core_Logica_Random_Func001A takes nothing returns nothing
    set udg_TempPlayer=GetEnumPlayer()
    if ( Trig_Core_Logica_Random_Func001Func002C() ) then
        if GetPlayerSlotState(udg_TempPlayer) != PLAYER_SLOT_STATE_PLAYING and not LoadBoolean(udg_MB_Hash, GetPlayerId(udg_TempPlayer), 102) then
        return
        endif
        if ( Trig_Core_Logica_Random_Func001Func002Func005C() ) then
            set udg_Temp_Int_Random=GetRandomInt(1, udg_Config_Total_Heroes[1])
            call CreateNUnitsAtLoc(1, udg_Array_Heroes_Humanos[udg_Temp_Int_Random], udg_TempPlayer, GetPlayerStartLocationLoc(udg_TempPlayer), bj_UNIT_FACING)
            call AddSpecialEffectTargetUnitBJ("origin", GetLastCreatedUnit(), "Abilities\\Spells\\Human\\MassTeleport\\MassTeleportTarget.mdl")
            call DestroyEffectBJ(GetLastCreatedEffectBJ())
            call SelectUnitForPlayerSingle(GetLastCreatedUnit(), udg_TempPlayer)
            call IACore_RegisterGlobalHero(bj_lastCreatedUnit)
            if GetPlayerController(udg_TempPlayer) == MAP_CONTROL_COMPUTER or LoadBoolean(udg_MB_Hash, GetPlayerId(udg_TempPlayer), 102) then
            call IACore_RegisterHero(bj_lastCreatedUnit)
            endif
            set udg_Array_Heroes_Humanos[udg_Temp_Int_Random]=udg_Array_Heroes_Humanos[udg_Config_Total_Heroes[1]]
            set udg_Config_Total_Heroes[1]=( udg_Config_Total_Heroes[1] - 1 )
            call ForGroupBJ(GetUnitsOfPlayerAndTypeId(udg_TempPlayer, 'ewsp'), function Trig_Core_Logica_Random_Func001Func002Func005Func012002)
        else
        endif
        if ( Trig_Core_Logica_Random_Func001Func002Func006C() ) then
            set udg_Temp_Int_Random=GetRandomInt(1, udg_Config_Total_Heroes[2])
            call CreateNUnitsAtLoc(1, udg_Array_Heroes_Orcos[udg_Temp_Int_Random], udg_TempPlayer, GetPlayerStartLocationLoc(udg_TempPlayer), bj_UNIT_FACING)
            call AddSpecialEffectTargetUnitBJ("origin", GetLastCreatedUnit(), "Abilities\\Spells\\Human\\MassTeleport\\MassTeleportTarget.mdl")
            call DestroyEffectBJ(GetLastCreatedEffectBJ())
            call SelectUnitForPlayerSingle(GetLastCreatedUnit(), udg_TempPlayer)
            call IACore_RegisterGlobalHero(bj_lastCreatedUnit)
            if GetPlayerController(udg_TempPlayer) == MAP_CONTROL_COMPUTER or LoadBoolean(udg_MB_Hash, GetPlayerId(udg_TempPlayer), 102) then
            call IACore_RegisterHero(bj_lastCreatedUnit)
            endif
            set udg_Array_Heroes_Orcos[udg_Temp_Int_Random]=udg_Array_Heroes_Orcos[udg_Config_Total_Heroes[2]]
            set udg_Config_Total_Heroes[2]=( udg_Config_Total_Heroes[2] - 1 )
            call ForGroupBJ(GetUnitsOfPlayerAndTypeId(udg_TempPlayer, 'e006'), function Trig_Core_Logica_Random_Func001Func002Func006Func012002)
        else
        endif
    else
    endif
endfunction

function Trig_Core_Logica_Random_Func002Func001C takes nothing returns boolean
    if ( not ( udg_Config_Modo_Humanos == 2 ) ) then
        return false
    endif
    if ( not ( udg_Config_Modo_Orcos == 2 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Core_Logica_Random_Func002C takes nothing returns boolean
    if ( not ( udg_Core_HayBots == true ) ) then
        return false
    endif
    return true
endfunction

function Trig_Core_Logica_Random_Actions takes nothing returns nothing
    call ForForce(GetPlayersAll(), function Trig_Core_Logica_Random_Func001A)
    if ( Trig_Core_Logica_Random_Func002C() ) then
        if ( Trig_Core_Logica_Random_Func002Func001C() ) then
            call DisplayTextToForce(GetPlayersAll(), " ")
            call DisplayTimedTextToForce(GetPlayersAll(), 20.00, "Los bots se activaran |cffFFCC00en breve...|r")
            call TriggerSleepAction(25.00)
            call PlaySoundBJ(gg_snd_ClanInvitation)
            call DisplayTimedTextToForce(GetPlayersAll(), 5.00, "Bots |cffFFCC00activados!|r")
            call IACore_InitializeBots()
        else
        endif
    else
    endif
endfunction

//===========================================================================
function InitTrig_Core_Logica_Random takes nothing returns nothing
    set gg_trg_Core_Logica_Random=CreateTrigger()
    call TriggerAddAction(gg_trg_Core_Logica_Random, function Trig_Core_Logica_Random_Actions)
endfunction
