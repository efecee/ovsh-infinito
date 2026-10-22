//===========================================================================
// COMBINACION DE OBJETOS: MANTO DE MAIEV (armadura, AGILIDAD)
//===========================================================================
// Armadura Lunar +5 (I00R) + Armadura Lunar Mejorada +10 (I00S) + Piel
// Reforzada +15 (I00K) -> Manto de Maiev +30 (I01N), al recoger cualquier objeto.
//
// TEXTO PERSONALIZADO (antes era GUI). En el editor: seleccionar el detonador
// "Manto de Maiev", Editar > Convertir en texto personalizado, y reemplazar todo
// por este archivo. El nombre del detonador NO debe cambiar.
// Conversion 1:1 del GUI que tenia el mapa el 2026-10-20: mismo comportamiento.
// UNICO CAMBIO respecto del GUI: en Modo Rapido no se fusiona (ninguna
// armadura se fusiona, ver Core_Menu_Modo.j). En modo Normal, igual que siempre.
//===========================================================================
function Trig_Manto_de_Maiev_Conditions takes nothing returns boolean
    if ( ModoPartida_EsRapido() ) then
        return false    // Modo Rapido: ninguna armadura se fusiona
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00R')) == 'I00R' ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00S')) == 'I00S' ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00K')) == 'I00K' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Manto_de_Maiev_Actions takes nothing returns nothing
    // Cuando una unidad aqdquiera un objeto revisas si tiene lo necesario para armar esta receta, en caso que lo tenga eliminas los items necesarios y le das el objeto armado al heroe
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00R'))
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00S'))
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00K'))
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call UnitAddItemByIdSwapped('I01N', GetTriggerUnit())
endfunction

//===========================================================================
function InitTrig_Manto_de_Maiev takes nothing returns nothing
    set gg_trg_Manto_de_Maiev=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Manto_de_Maiev, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    call TriggerAddCondition(gg_trg_Manto_de_Maiev, Condition(function Trig_Manto_de_Maiev_Conditions))
    call TriggerAddAction(gg_trg_Manto_de_Maiev, function Trig_Manto_de_Maiev_Actions)
endfunction
