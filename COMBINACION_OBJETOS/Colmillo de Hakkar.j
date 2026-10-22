//===========================================================================
// COMBINACION DE OBJETOS: COLMILLO DE HAKKAR (daño, AGILIDAD)
//===========================================================================
// Daga de ataque +25 (I00C) + Puñal de ataque +50 (I00D) + Impacto Blanco de
// ataque +75 (I00E) -> Colmillo de Hakkar +150 (I01L), al recoger cualquier
// objeto. En Modo Rapido se fusiona igual (solo las armaduras no).
//
// TEXTO PERSONALIZADO (antes era GUI). En el editor: seleccionar el detonador
// "Colmillo de Hakkar", Editar > Convertir en texto personalizado, y reemplazar todo
// por este archivo. El nombre del detonador NO debe cambiar.
// Conversion 1:1 del GUI que tenia el mapa el 2026-10-20: mismo comportamiento.
//===========================================================================
function Trig_Colmillo_de_Hakkar_Conditions takes nothing returns boolean
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00C')) == 'I00C' ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00D')) == 'I00D' ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00E')) == 'I00E' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Colmillo_de_Hakkar_Actions takes nothing returns nothing
    // Cuando una unidad aqdquiera un objeto revisas si tiene lo necesario para armar esta receta, en caso que lo tenga eliminas los items necesarios y le das el objeto armado al heroe
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00C'))
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00D'))
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00E'))
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call UnitAddItemByIdSwapped('I01L', GetTriggerUnit())
endfunction

//===========================================================================
function InitTrig_Colmillo_de_Hakkar takes nothing returns nothing
    set gg_trg_Colmillo_de_Hakkar=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Colmillo_de_Hakkar, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    call TriggerAddCondition(gg_trg_Colmillo_de_Hakkar, Condition(function Trig_Colmillo_de_Hakkar_Conditions))
    call TriggerAddAction(gg_trg_Colmillo_de_Hakkar, function Trig_Colmillo_de_Hakkar_Actions)
endfunction
