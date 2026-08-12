// ============================================================================
//  SISTEMA DE FUSIONES  (recetas A + A -> B)
// ----------------------------------------------------------------------------
//  UN solo trigger para las 7 fusiones. La logica de fusion existe UNA vez;
//  cada receta es solo un par de rawcodes (ingrediente -> resultado) en la
//  tabla Fusion_Resultado(). Para agregar una receta nueva: una sola linea.
//
//  Deteccion por CONTEO, independiente del orden de slots del inventario:
//  cuenta los ingredientes iguales en los 6 slots; si hay >= 2, remueve 2
//  (escaneando todo el inventario) y entrega el resultado. Funciona con el
//  inventario lleno o vacio, y con los items en cualquier fila/columna/orden.
//
//  NOTA: todas las recetas usan los mismos 2 efectos visuales. Si alguna
//  fusion usa efectos distintos, avisar para moverlos a la tabla por receta.
// ============================================================================

// --- Tabla de recetas: ingrediente -> resultado. Retorna 0 si no aplica. ---
function Fusion_Resultado takes integer ing returns integer
    if     ing == 'I00U' then
        return 'I01B'   // Super Armadura Lunar +40    (AGI)
    elseif ing == 'I00M' then
        return 'I01A'   // Super Coraza de Infame +40  (STR)
    elseif ing == 'I00Q' then
        return 'I01C'   // Super Escamas de Dragon +40 (INT)
    elseif ing == 'I007' then
        return 'I01E'   // Hacha Suprema +200          (STR)
    elseif ing == 'I00B' then
        return 'I01D'   // Super Impacto Oscuro +200   (AGI)
    elseif ing == 'I00F' then
        return 'I01F'   // Supremo Libro Maestro +200  (INT)
    elseif ing == 'I006' then
        return 'I013'   // Finger nivel 2
    endif
    return 0            // no es ingrediente de ninguna receta
endfunction

function Trig_Fusiones_Conditions takes nothing returns boolean
    local integer ing = GetItemTypeId(GetManipulatedItem())
    local unit u
    local integer slot = 0
    local integer count = 0
    // ¿El item recien recogido es ingrediente de alguna receta?
    if ( Fusion_Resultado(ing) == 0 ) then
        return false
    endif
    set u = GetManipulatingUnit()
    // Conteo independiente del slot: ¿hay 2 o mas ingredientes iguales?
    loop
        exitwhen slot > 5
        if ( GetItemTypeId(UnitItemInSlot(u, slot)) == ing ) then
            set count = count + 1
        endif
        set slot = slot + 1
    endloop
    set u = null
    return count >= 2
endfunction

function Trig_Fusiones_Actions takes nothing returns nothing
    local unit u = GetTriggerUnit()
    local integer ing = GetItemTypeId(GetManipulatedItem())
    local integer result = Fusion_Resultado(ing)
    local real x = GetUnitX(u)
    local real y = GetUnitY(u)
    local integer slot = 0
    local integer removed = 0
    local item it
    // Remover exactamente 2 ingredientes, escaneando todo el inventario.
    // RemoveItem deja el slot vacio sin reordenar el resto, asi que una sola
    // pasada por los slots es segura.
    loop
        exitwhen slot > 5 or removed >= 2
        set it = UnitItemInSlot(u, slot)
        if ( GetItemTypeId(it) == ing ) then
            call RemoveItem(it)
            set removed = removed + 1
        endif
        set slot = slot + 1
    endloop
    // Efectos visuales (coordenadas X/Y, sin Location para no generar fugas).
    call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdl", x, y))
    call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl", x, y))
    // Entregar el resultado. Hay slots libres (removimos 2, agregamos 1).
    call UnitAddItemById(u, result)
    set u = null
    set it = null
endfunction

//===========================================================================
function InitTrig_Fusiones_Clasicas takes nothing returns nothing
    local trigger t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_PICKUP_ITEM )
    call TriggerAddCondition( t, Condition( function Trig_Fusiones_Conditions ) )
    call TriggerAddAction( t, function Trig_Fusiones_Actions )
    set t = null
endfunction
