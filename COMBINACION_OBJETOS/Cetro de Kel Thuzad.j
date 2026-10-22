//===========================================================================
// COMBINACION DE OBJETOS: CETRO DE KEL THUZAD (daño, INTELIGENCIA)
//===========================================================================
// Varita Oscura de ataque +25 (I00G) + Libro Oscuro de ataque +50 (I00H) +
// Baculo de ataque +75 (I00I) -> Cetro de Kel'Thuzad +150 (I01M), al recoger
// cualquier objeto. En Modo Rapido se fusiona igual (solo las armaduras no).
//
// TEXTO PERSONALIZADO (antes era GUI). En el editor: seleccionar el detonador
// "Cetro de Kel Thuzad", Editar > Convertir en texto personalizado, y reemplazar todo
// por este archivo. El nombre del detonador NO debe cambiar.
// Conversion 1:1 del GUI que tenia el mapa el 2026-10-20: mismo comportamiento.
//===========================================================================
function Trig_Cetro_de_Kel_Thuzad_Conditions takes nothing returns boolean
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00G')) == 'I00G' ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00H')) == 'I00H' ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00I')) == 'I00I' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Cetro_de_Kel_Thuzad_Actions takes nothing returns nothing
    // Cuando una unidad aqdquiera un objeto revisas si tiene lo necesario para armar esta receta, en caso que lo tenga eliminas los items necesarios y le das el objeto armado al heroe
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00G'))
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00H'))
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00I'))
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call UnitAddItemByIdSwapped('I01M', GetTriggerUnit())
endfunction

//===========================================================================
function InitTrig_Cetro_de_Kel_Thuzad takes nothing returns nothing
    set gg_trg_Cetro_de_Kel_Thuzad=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Cetro_de_Kel_Thuzad, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    call TriggerAddCondition(gg_trg_Cetro_de_Kel_Thuzad, Condition(function Trig_Cetro_de_Kel_Thuzad_Conditions))
    call TriggerAddAction(gg_trg_Cetro_de_Kel_Thuzad, function Trig_Cetro_de_Kel_Thuzad_Actions)
endfunction
