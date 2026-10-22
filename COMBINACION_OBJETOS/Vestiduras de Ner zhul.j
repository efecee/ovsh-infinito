//===========================================================================
// COMBINACION DE OBJETOS: VESTIDURAS DE NER ZHUL (armadura, INTELIGENCIA)
//===========================================================================
// Armadura Infame +5 (I00N) + Armadura de Cuero Mejorada +10 (I00O) + Armadura
// de Cuero Reforzada +15 (I00P) -> Vestiduras de Ner'zhul +30 (I01O), al
// recoger cualquier objeto.
//
// TEXTO PERSONALIZADO (antes era GUI). En el editor: seleccionar el detonador
// "Vestiduras de Ner zhul", Editar > Convertir en texto personalizado, y reemplazar todo
// por este archivo. El nombre del detonador NO debe cambiar.
// Conversion 1:1 del GUI que tenia el mapa el 2026-10-20: mismo comportamiento.
// UNICO CAMBIO respecto del GUI: en Modo Rapido no se fusiona (ninguna
// armadura se fusiona, ver Core_Menu_Modo.j). En modo Normal, igual que siempre.
//===========================================================================
function Trig_Vestiduras_de_Ner_zhul_Conditions takes nothing returns boolean
    if ( ModoPartida_EsRapido() ) then
        return false    // Modo Rapido: ninguna armadura se fusiona
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00N')) == 'I00N' ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00O')) == 'I00O' ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00P')) == 'I00P' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Vestiduras_de_Ner_zhul_Actions takes nothing returns nothing
    // Cuando una unidad aqdquiera un objeto revisas si tiene lo necesario para armar esta receta, en caso que lo tenga eliminas los items necesarios y le das el objeto armado al heroe
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00N'))
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00O'))
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00P'))
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call UnitAddItemByIdSwapped('I01O', GetTriggerUnit())
endfunction

//===========================================================================
function InitTrig_Vestiduras_de_Ner_zhul takes nothing returns nothing
    set gg_trg_Vestiduras_de_Ner_zhul=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Vestiduras_de_Ner_zhul, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    call TriggerAddCondition(gg_trg_Vestiduras_de_Ner_zhul, Condition(function Trig_Vestiduras_de_Ner_zhul_Conditions))
    call TriggerAddAction(gg_trg_Vestiduras_de_Ner_zhul, function Trig_Vestiduras_de_Ner_zhul_Actions)
endfunction
