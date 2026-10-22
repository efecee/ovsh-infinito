//===========================================================================
// COMBINACION DE OBJETOS: POWER TREADS, INTELIGENCIA A AGILIDAD
//===========================================================================
// Al usar las Power Treads [Inteligencia] (I017) se cambian por las de
// Agilidad (I019).
//
// TEXTO PERSONALIZADO (antes era GUI). En el editor: seleccionar el detonador
// "Inteligencia a Agilidad", Editar > Convertir en texto personalizado, y reemplazar todo
// por este archivo. El nombre del detonador NO debe cambiar.
// Conversion 1:1 del GUI que tenia el mapa el 2026-10-20: mismo comportamiento.
//===========================================================================
function Trig_Inteligencia_a_Agilidad_Conditions takes nothing returns boolean
    if ( not ( GetItemTypeId(GetManipulatedItem()) == 'I017' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Inteligencia_a_Agilidad_Actions takes nothing returns nothing
    call RemoveItem(GetManipulatedItem())
    call UnitAddItemByIdSwapped('I019', GetTriggerUnit())
endfunction

//===========================================================================
function InitTrig_Inteligencia_a_Agilidad takes nothing returns nothing
    set gg_trg_Inteligencia_a_Agilidad=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Inteligencia_a_Agilidad, EVENT_PLAYER_UNIT_USE_ITEM)
    call TriggerAddCondition(gg_trg_Inteligencia_a_Agilidad, Condition(function Trig_Inteligencia_a_Agilidad_Conditions))
    call TriggerAddAction(gg_trg_Inteligencia_a_Agilidad, function Trig_Inteligencia_a_Agilidad_Actions)
endfunction
