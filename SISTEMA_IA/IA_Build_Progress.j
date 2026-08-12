library IABuildProgress

    // ==========================================================================
    // IA_Build_Progress.j — Lector central de progreso de build (denominador común)
    // ==========================================================================
    // ÚNICA FUENTE DE VERDAD para consultar, EN RUNTIME, el estado de la build de
    // un bot leyendo su inventario real. Antes el progreso se calculaba una sola
    // vez en BuildQueue (IA_State_Shopping) y se descartaba; aquí queda consultable
    // cada frame por cualquier sistema.
    //
    // CONSUMIDORES:
    //   - IA_State_Shopping  → CountFreeSlots: si no hay slots libres (típico en
    //                          TAKEOVER con ítems ajenos), PAUSA la cola de build
    //                          y compra tomos; al liberarse un slot, la retoma.
    //   - IA_State_Shopping  → HasFirstArmor / HasSuperArmor: anclas de los hitos
    //                          del RUSH DE AGI (tandas de tomos 'tdex' intercaladas
    //                          en la lista de compras de las builds AGI).
    //   - IA_State_Laning    → HasFirstArmor (FUTURO): el melee pasivo se levanta
    //                          al conseguir su 1ª armadura (armorConsumed >= 1).
    //
    // ORDEN DE COMPILACIÓN: esta library NO depende de nada, pero DEBE compilar
    // ANTES que IAStateLaning e IAStateShopping (ambas la declaran en su 'requires').
    // Por eso vive como utilidad base, sin 'requires' propios.
    //
    // RAWCODES DE ARMADURA CARA (base + súper) POR ATRIBUTO:
    //   STR: 'I00M' / 'I01A'    AGI: 'I00U' / 'I01B'    INT: 'I00Q' / 'I01C'
    // (Reconocer las 6 es seguro y agnóstico de atributo: un bot solo porta
    //  armaduras de su propia build, nunca de otro atributo.)
    // ==========================================================================

    // Cuenta los slots de inventario LIBRES del héroe (0..6).
    //   6 = inventario vacío   ·   0 = inventario lleno.
    // Barato (6 lecturas). Llamable cada frame sin coste relevante.
    public function CountFreeSlots takes unit hero returns integer
        local integer slot = 0
        local integer free = 0
        loop
            exitwhen slot > 5
            if UnitItemInSlot(hero, slot) == null then
                set free = free + 1
            endif
            set slot = slot + 1
        endloop
        return free
    endfunction

    // ¿El héroe ya tiene su 1ª armadura de la build? (base O súper, cualquier
    // atributo). Equivale al gatillo armorConsumed >= 1 del build, pero leído del
    // inventario real (robusto a fusiones: una armadura base que ya se fusionó en
    // súper sigue contando). Consumidor FUTURO: el melee pasivo en IA_State_Laning,
    // que deja de ser pasivo al conseguir su primera armadura.
    public function HasFirstArmor takes unit hero returns boolean
        local integer slot = 0
        local integer id
        local item it
        loop
            exitwhen slot > 5
            set it = UnitItemInSlot(hero, slot)
            if it != null then
                set id = GetItemTypeId(it)
                if id == 'I00M' or id == 'I01A' or id == 'I00U' or id == 'I01B' or id == 'I00Q' or id == 'I01C' then
                    set it = null
                    return true
                endif
            endif
            set slot = slot + 1
        endloop
        set it = null
        return false
    endfunction

    // ¿El héroe ya tiene su SÚPER armadura (fusión de 2 armaduras base)? Cualquier
    // atributo: 'I01A' (STR) / 'I01B' (AGI) / 'I01C' (INT). Marca la MITAD de la
    // build CARA (faltan: daño 1, armadura 3, daño 2, armadura 4).
    // Consumidor: IA_State_Shopping → GetAgiRushFloor (desbloquea el hito 150 del
    // RUSH DE AGI). Mismo patrón barato que HasFirstArmor (6 lecturas de slot).
    public function HasSuperArmor takes unit hero returns boolean
        local integer slot = 0
        local integer id
        local item it
        loop
            exitwhen slot > 5
            set it = UnitItemInSlot(hero, slot)
            if it != null then
                set id = GetItemTypeId(it)
                if id == 'I01A' or id == 'I01B' or id == 'I01C' then
                    set it = null
                    return true
                endif
            endif
            set slot = slot + 1
        endloop
        set it = null
        return false
    endfunction

endlibrary
