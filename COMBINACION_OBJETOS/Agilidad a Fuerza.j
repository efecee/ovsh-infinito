//===========================================================================
// COMBINACION DE OBJETOS: POWER TREADS, AGILIDAD A FUERZA
//===========================================================================
// Al usar las Power Treads [Agilidad] (I019) se cambian por las de
// Fuerza (I018).
//
// TEXTO PERSONALIZADO (antes era GUI). En el editor: seleccionar el detonador
// "Agilidad a Fuerza", Editar > Convertir en texto personalizado, y reemplazar todo
// por este archivo. El nombre del detonador NO debe cambiar.
// Conversion 1:1 del GUI que tenia el mapa el 2026-10-20: mismo comportamiento.
//===========================================================================
function Trig_Agilidad_a_Fuerza_Conditions takes nothing returns boolean
    if ( not ( GetItemTypeId(GetManipulatedItem()) == 'I019' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Agilidad_a_Fuerza_Actions takes nothing returns nothing
    call RemoveItem(GetManipulatedItem())
    call UnitAddItemByIdSwapped('I018', GetTriggerUnit())
endfunction

//===========================================================================
function InitTrig_Agilidad_a_Fuerza takes nothing returns nothing
    set gg_trg_Agilidad_a_Fuerza=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Agilidad_a_Fuerza, EVENT_PLAYER_UNIT_USE_ITEM)
    call TriggerAddCondition(gg_trg_Agilidad_a_Fuerza, Condition(function Trig_Agilidad_a_Fuerza_Conditions))
    call TriggerAddAction(gg_trg_Agilidad_a_Fuerza, function Trig_Agilidad_a_Fuerza_Actions)
endfunction
