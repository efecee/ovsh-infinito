//===========================================================================
// COMBINACION DE OBJETOS: BOTAS DE TP
//===========================================================================
// Botas de Velocidad (bspd) + Baculo de Teletransporte (brac) -> Baculo de
// Velocidad y Teletransporte (I00W), al recoger cualquier objeto.
//
// TEXTO PERSONALIZADO (antes era GUI). En el editor: seleccionar el detonador
// "Botas de TP", Editar > Convertir en texto personalizado, y reemplazar todo
// por este archivo. El nombre del detonador NO debe cambiar.
// Conversion 1:1 del GUI que tenia el mapa el 2026-10-20: mismo comportamiento.
//===========================================================================
function Trig_Botas_de_TP_Func001C takes nothing returns boolean
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'bspd')) == 'bspd' ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'brac')) == 'brac' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Botas_de_TP_Actions takes nothing returns nothing
    if ( Trig_Botas_de_TP_Func001C() ) then
        call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'bspd'))
        call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'brac'))
        call CreateItemLoc('I00W', GetRectCenter(GetPlayableMapRect()))
        call UnitAddItemSwapped(GetLastCreatedItem(), GetTriggerUnit())
        call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Items\\AIem\\AIemTarget.mdl")
        call DestroyEffectBJ(GetLastCreatedEffectBJ())
    else
    endif
endfunction

//===========================================================================
function InitTrig_Botas_de_TP takes nothing returns nothing
    set gg_trg_Botas_de_TP=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Botas_de_TP, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    call TriggerAddAction(gg_trg_Botas_de_TP, function Trig_Botas_de_TP_Actions)
endfunction
