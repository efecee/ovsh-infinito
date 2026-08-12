// ============================================================================
//  FUSIÓN DE VARITAS DE NEGACIÓN
// ----------------------------------------------------------------------------
//  Cadena de fusión (conserva cargas restantes, no regala usos extra):
//    wneg (3 cargas) + wneg (3 cargas)  →  I012 (6 cargas)
//    I012 (6 cargas)  + wneg (3 cargas)  →  I01S (9 cargas)  ← TOPE
//
//  Un solo trigger detecta PICKUP de cualquier 'wneg'. Al recoger una varita:
//    1. Si ya tiene una 'I012' en inventario → fusiona a I01S (9 cargas).
//    2. Si tiene otra 'wneg' en inventario  → fusiona a I012 (6 cargas).
//    3. Si no aplica ninguna               → no hace nada (Conditions filtra).
//
//  PRIORIDAD: I012+wneg se evalúa ANTES que wneg+wneg. Así, si el héroe
//  tiene [I012, wneg_nueva], la nueva varita se fusiona con la de 6 cargas
//  (resultado: 9 cargas) en vez de intentar buscar otra wneg que no existe.
//
//  PATRÓN: Misma arquitectura que Fusiones.j:
//    - Conditions: conteo por slots 0-5, retorna false si no hay fusión.
//    - Actions: escaneo de remoción + efectos + entrega.
//
//  NOTAS TÉCNICAS:
//  - Sin Location, sin TriggerSleepAction, sin PolledWait.
//  - Todos los punteros (item, unit) se nullifican al final.
//  - DestroyEffect inmediato: sin fugas de efectos.
//  - No usa udg_integer46 ni ninguna variable global compartida.
//    El conteo es 100% local, sin colisiones entre jugadores.
//
//  REEMPLAZA: Trigger legacy "Wand of Negation Combination"
//  (udg_trigger118 en init.j, ahora comentado).
//
//  INSTALACIÓN EN EL EDITOR:
//   1. Crear UN trigger de "Texto Personalizado" llamado EXACTAMENTE:
//      Fusion_Varitas
//      (el nombre debe coincidir con InitTrig_Fusion_Varitas).
//   2. Pegar este archivo como su contenido.
//   3. Desactivar el trigger viejo "Wand of Negation Combination"
//      (udg_trigger118) para evitar doble reacción.
// ============================================================================

// --- Conditions: filtra y cuenta. Actions NUNCA corre si no hay fusión. ---
// Misma filosofía que Trig_Fusiones_Conditions: conteo por slots 0-5.
function Trig_Fusion_Varitas_Conditions takes nothing returns boolean
    local integer ing = GetItemTypeId(GetManipulatedItem())
    local unit u
    local integer slot = 0
    local integer wnegCount = 0
    local boolean hasI012 = false

    // Solo reacciona al recoger una 'wneg' base
    if ing != 'wneg' then
        return false
    endif

    set u = GetManipulatingUnit()

    // Escanear inventario: contar 'wneg' y buscar 'I012'
    loop
        exitwhen slot > 5
        if GetItemTypeId(UnitItemInSlot(u, slot)) == 'wneg' then
            set wnegCount = wnegCount + 1
        elseif GetItemTypeId(UnitItemInSlot(u, slot)) == 'I012' then
            set hasI012 = true
        endif
        set slot = slot + 1
    endloop

    set u = null

    // ¿Fusión posible?
    //   Caso A: I012 + al menos 1 wneg (la recién recogida) → I01S
    //   Caso B: 2+ wneg (incluyendo la recién recogida)     → I012
    return hasI012 or wnegCount >= 2
endfunction

// --- Actions: remoción + efectos + entrega. Solo corre si Conditions pasó. ---
// Misma filosofía que Trig_Fusiones_Actions: escaneo por slots 0-5,
// RemoveItem directo, coordenadas X/Y, DestroyEffect inmediato.
function Trig_Fusion_Varitas_Actions takes nothing returns nothing
    local unit u = GetTriggerUnit()
    local real x = GetUnitX(u)
    local real y = GetUnitY(u)
    local integer slot = 0
    local integer removed = 0
    local item it
    local item newItem
    local boolean hasI012 = false
    local integer i012Slot = -1
    local integer totalCharges = 0

    // ====================================================================
    // PASO 1: Detectar qué fusión aplica (re-escaneo rápido)
    // ====================================================================
    loop
        exitwhen slot > 5
        set it = UnitItemInSlot(u, slot)
        if GetItemTypeId(it) == 'I012' then
            set hasI012 = true
            set i012Slot = slot
            exitwhen true
        endif
        set slot = slot + 1
    endloop

    // ====================================================================
    // PASO 2: Ejecutar fusión
    // ====================================================================

    if hasI012 then
        // --- Caso A: I012 + wneg → I01S (cargas = suma real) ---
        // Leer cargas de la I012 antes de destruirla
        set it = UnitItemInSlot(u, i012Slot)
        set totalCharges = GetItemCharges(it)
        call RemoveItem(it)

        // Remover exactamente 1 wneg, sumando sus cargas
        set slot = 0
        loop
            exitwhen slot > 5
            set it = UnitItemInSlot(u, slot)
            if GetItemTypeId(it) == 'wneg' then
                set totalCharges = totalCharges + GetItemCharges(it)
                call RemoveItem(it)
                exitwhen true
            endif
            set slot = slot + 1
        endloop

        // Efectos visuales + entregar resultado con cargas reales
        call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\DispelMagic\\DispelMagicTarget.mdl", x, y))
        set newItem = UnitAddItemById(u, 'I01S')
        call SetItemCharges(newItem, totalCharges)

    else
        // --- Caso B: wneg + wneg → I012 (cargas = suma real) ---
        // Remover exactamente 2 wneg, sumando sus cargas
        set slot = 0
        loop
            exitwhen slot > 5 or removed >= 2
            set it = UnitItemInSlot(u, slot)
            if GetItemTypeId(it) == 'wneg' then
                set totalCharges = totalCharges + GetItemCharges(it)
                call RemoveItem(it)
                set removed = removed + 1
            endif
            set slot = slot + 1
        endloop

        // Efectos visuales + entregar resultado con cargas reales
        call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\DispelMagic\\DispelMagicTarget.mdl", x, y))
        set newItem = UnitAddItemById(u, 'I012')
        call SetItemCharges(newItem, totalCharges)

    endif

    // ====================================================================
    // LIMPIEZA DE PUNTEROS
    // ====================================================================
    set u = null
    set it = null
    set newItem = null
endfunction

//===========================================================================
function InitTrig_Fusion_Varitas takes nothing returns nothing
    local trigger t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    call TriggerAddCondition(t, Condition(function Trig_Fusion_Varitas_Conditions))
    call TriggerAddAction(t, function Trig_Fusion_Varitas_Actions)
    set t = null
endfunction
