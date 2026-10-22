//===========================================================================
// COMBINACION DE OBJETOS: POWER TREADS
//===========================================================================
// Boots of Quel'Thalas (belv) + Guantes de Presteza (gcel) + Robe of the Magi
// (ciri) -> Power Treads [Inteligencia] (I017), al recoger cualquier objeto.
// El cambio de atributo al usarlas esta en Fuerza a Inteligencia,
// Inteligencia a Agilidad y Agilidad a Fuerza.
//
// TEXTO PERSONALIZADO (antes era GUI). En el editor: seleccionar el detonador
// "Power Treads", Editar > Convertir en texto personalizado, y reemplazar todo
// por este archivo. El nombre del detonador NO debe cambiar.
// Conversion 1:1 del GUI que tenia el mapa el 2026-10-20: mismo comportamiento.
//===========================================================================
function Trig_Power_Treads_Func001C takes nothing returns boolean
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'belv')) == 'belv' ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'gcel')) == 'gcel' ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'ciri')) == 'ciri' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Power_Treads_Actions takes nothing returns nothing
    if ( Trig_Power_Treads_Func001C() ) then
        call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'belv'))
        call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'gcel'))
        call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'ciri'))
        call CreateItemLoc('I017', GetRectCenter(GetPlayableMapRect()))
        call UnitAddItemSwapped(GetLastCreatedItem(), GetTriggerUnit())
        call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Items\\AIem\\AIemTarget.mdl")
        call DestroyEffectBJ(GetLastCreatedEffectBJ())
    else
    endif
endfunction

//===========================================================================
function InitTrig_Power_Treads takes nothing returns nothing
    set gg_trg_Power_Treads=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Power_Treads, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    call TriggerAddAction(gg_trg_Power_Treads, function Trig_Power_Treads_Actions)
endfunction
