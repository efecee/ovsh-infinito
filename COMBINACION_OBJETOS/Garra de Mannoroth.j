//===========================================================================
// COMBINACION DE OBJETOS: GARRA DE MANNOROTH (daño, FUERZA)
//===========================================================================
// Hacha de Ataque +25 (I008) + Garras +50 (I009) + Hacha Infernal +75 (I00A)
// -> Garra de Mannoroth +150 (I01K), al recoger cualquier objeto. En Modo
// Rapido se fusiona igual (solo las armaduras no).
//
// TEXTO PERSONALIZADO (antes era GUI). En el editor: seleccionar el detonador
// "Garra de Mannoroth", Editar > Convertir en texto personalizado, y reemplazar todo
// por este archivo. El nombre del detonador NO debe cambiar.
// Conversion 1:1 del GUI que tenia el mapa el 2026-10-20: mismo comportamiento.
//===========================================================================
function Trig_Garra_de_Mannoroth_Conditions takes nothing returns boolean
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I008')) == 'I008' ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I009')) == 'I009' ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00A')) == 'I00A' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Garra_de_Mannoroth_Actions takes nothing returns nothing
    // Cuando una unidad aqdquiera un objeto revisas si tiene lo necesario para armar esta receta, en caso que lo tenga eliminas los items necesarios y le das el objeto armado al heroe
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I008'))
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I009'))
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00A'))
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call UnitAddItemByIdSwapped('I01K', GetTriggerUnit())
endfunction

//===========================================================================
function InitTrig_Garra_de_Mannoroth takes nothing returns nothing
    set gg_trg_Garra_de_Mannoroth=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Garra_de_Mannoroth, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    call TriggerAddCondition(gg_trg_Garra_de_Mannoroth, Condition(function Trig_Garra_de_Mannoroth_Conditions))
    call TriggerAddAction(gg_trg_Garra_de_Mannoroth, function Trig_Garra_de_Mannoroth_Actions)
endfunction
