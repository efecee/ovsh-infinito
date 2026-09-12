//===========================================================================
// SISTEMA: RASTREO DE ORO (-merito)
// Héroes: 500 | Barracas: 450 | Torres: 150 | Tanques: 40 | Creeps: 20
//===========================================================================
function Trig_Merito_Track_Actions takes nothing returns nothing
    local unit victim = GetDyingUnit()
    local unit killer = GetKillingUnit()
    local player p = GetOwningPlayer(killer)
    local integer id = GetPlayerId(p)
    local integer uType = GetUnitTypeId(victim) // El DNI de la unidad
    local integer goldGained = 0
    local integer currentTotal = 0

    // 1. VALIDACIÓN: Solo contamos si el asesino es un jugador (0-9) y es enemigo.
    //    Excluimos ilusiones: matar una ilusión no debe dar oro de mérito.
    if (killer != null and id <= 9 and IsUnitEnemy(victim, p) and not IsUnitIllusion(victim)) then
        
        // --- A) HÉROES (500 Oro) ---
        if (IsUnitType(victim, UNIT_TYPE_HERO)) then
            set goldGained = 500
            
        // --- B) ESTRUCTURAS ---
        elseif (IsUnitType(victim, UNIT_TYPE_STRUCTURE)) then
            // Verificamos si es una de las 8 "Barracas" que generan creeps
            // IDs extraídos de tu mapa: hbar, edob, eaom, hbla (Humanos) | obar, uslh, usep, otto (Orcos)
            if (uType == 'hbar' or uType == 'edob' or uType == 'eaom' or uType == 'hbla' or uType == 'obar' or uType == 'uslh' or uType == 'usep' or uType == 'otto') then
                // Barracas Generadoras: 450 Oro
                set goldGained = 450
            else
                // Torres y otros edificios: 150 Oro
                set goldGained = 150
            endif
            
        // --- C) INVOCACIONES (0 Oro) ---
        // Evitamos que farmear lobos o esqueletos cuente para el tracker de merito
        elseif (IsUnitType(victim, UNIT_TYPE_SUMMONED)) then
            set goldGained = 0
            
        // --- D) UNIDADES DE LÍNEA ---
        else
            // Detectamos los "Tanques" (Gigantes y Taurens)
            if (uType == 'h009' or uType == 'o002' or uType == 'o008') then
                set goldGained = 40
            else
                // Cualquier otra unidad (Melee/Rango): 20 Oro
                set goldGained = 20
            endif
        endif

        // 3. GUARDAR EN LA BASE DE DATOS (Si hubo ganancia)
        if (goldGained > 0) then
            set currentTotal = LoadInteger(udg_MB_Hash, id, 3)
            call SaveInteger(udg_MB_Hash, id, 3, currentTotal + goldGained)
            // Sync de la base del detector de oro F11 (Comandos_Economia.j).
            // El bounty NATIVO de matar es FIJO e IGUAL a estos montos (héroe 500,
            // barraca 450, torre 150, tanque 40, creep 20), así que SUMA exactamente
            // goldGained al asesino. Avanzar la base lo vuelve invisible al sondeo: si
            // el asesino justo recibe (o envía) un regalo F11 en el mismo tick, su
            // par −X/+X no se descuadra. (id ya está validado 0-9 arriba.)
            // INVARIANTE: si cambias un bounty en el Object Editor, ajusta el monto
            // aquí también, o quedará un residuo que descuadra la detección.
            set Eco_GoldBaseline[id] = Eco_GoldBaseline[id] + goldGained
        endif
    endif

    set victim = null
    set killer = null
    set p = null
endfunction

//===========================================================================
function InitTrig_Sistema_Merito_Track takes nothing returns nothing
    set gg_trg_Sistema_Merito_Track = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Sistema_Merito_Track, EVENT_PLAYER_UNIT_DEATH)
    call TriggerAddAction(gg_trg_Sistema_Merito_Track, function Trig_Merito_Track_Actions)
endfunction