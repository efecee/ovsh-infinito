//===========================================================================
// COMBINACION DE OBJETOS: BALUARTE DE LOTHAR (armadura, FUERZA)
//===========================================================================
// Coraza de Hierro +5 (I00J) + Coraza de Acero +10 (I00L) + Coraza de Honor
// +15 (I00T) -> Baluarte de Lothar +30 (I01P), al recoger cualquier objeto.
//
// TEXTO PERSONALIZADO (antes era GUI). En el editor: seleccionar el detonador
// "Baluarte de Lothar", Editar > Convertir en texto personalizado, y reemplazar todo
// por este archivo. El nombre del detonador NO debe cambiar.
// Conversion 1:1 del GUI que tenia el mapa el 2026-10-20: mismo comportamiento.
// UNICO CAMBIO respecto del GUI: en Modo Rapido no se fusiona (ninguna
// armadura se fusiona, ver Core_Menu_Modo.j). En modo Normal, igual que siempre.
//===========================================================================
function Trig_Baluarte_de_Lothar_Conditions takes nothing returns boolean
    if ( ModoPartida_EsRapido() ) then
        return false    // Modo Rapido: ninguna armadura se fusiona
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00J')) == 'I00J' ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00L')) == 'I00L' ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00T')) == 'I00T' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Baluarte_de_Lothar_Actions takes nothing returns nothing
    // Cuando una unidad aqdquiera un objeto revisas si tiene lo necesario para armar esta receta, en caso que lo tenga eliminas los items necesarios y le das el objeto armado al heroe
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00J'))
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00L'))
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00T'))
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call UnitAddItemByIdSwapped('I01P', GetTriggerUnit())
endfunction

//===========================================================================
function InitTrig_Baluarte_de_Lothar takes nothing returns nothing
    set gg_trg_Baluarte_de_Lothar=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Baluarte_de_Lothar, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    call TriggerAddCondition(gg_trg_Baluarte_de_Lothar, Condition(function Trig_Baluarte_de_Lothar_Conditions))
    call TriggerAddAction(gg_trg_Baluarte_de_Lothar, function Trig_Baluarte_de_Lothar_Actions)
endfunction
