//===========================================================================
// COMBINACION DE OBJETOS: POWER TREADS, FUERZA A INTELIGENCIA
//===========================================================================
// Al usar las Power Treads [Fuerza] (I018) se cambian por las de
// Inteligencia (I017).
//
// TEXTO PERSONALIZADO (antes era GUI). En el editor: seleccionar el detonador
// "Fuerza a Inteligencia", Editar > Convertir en texto personalizado, y reemplazar todo
// por este archivo. El nombre del detonador NO debe cambiar.
// Conversion 1:1 del GUI que tenia el mapa el 2026-10-20: mismo comportamiento.
//===========================================================================
function Trig_Fuerza_a_Inteligencia_Conditions takes nothing returns boolean
    if ( not ( GetItemTypeId(GetManipulatedItem()) == 'I018' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Fuerza_a_Inteligencia_Actions takes nothing returns nothing
    call RemoveItem(GetManipulatedItem())
    call UnitAddItemByIdSwapped('I017', GetTriggerUnit())
endfunction

//===========================================================================
function InitTrig_Fuerza_a_Inteligencia takes nothing returns nothing
    set gg_trg_Fuerza_a_Inteligencia=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Fuerza_a_Inteligencia, EVENT_PLAYER_UNIT_USE_ITEM)
    call TriggerAddCondition(gg_trg_Fuerza_a_Inteligencia, Condition(function Trig_Fuerza_a_Inteligencia_Conditions))
    call TriggerAddAction(gg_trg_Fuerza_a_Inteligencia, function Trig_Fuerza_a_Inteligencia_Actions)
endfunction
