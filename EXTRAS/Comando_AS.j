// ==========================================================================
// COMANDO DE JUGADOR: -as (Attack Speed)
// Muestra el desglose matemático completo de la velocidad de ataque
// del héroe, separado por cada fuente (Categorías A-F).
// Usa las mismas funciones que la IA para validar su precisión.
// ==========================================================================
scope CommandAS initializer Init

    // Función auxiliar: Busca el primer héroe vivo del jugador
    private function GetPlayerHero takes player p returns unit
        local group g = CreateGroup()
        local unit u
        local unit hero = null
        
        call GroupEnumUnitsOfPlayer(g, p, null)
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            call GroupRemoveUnit(g, u)
            if IsUnitType(u, UNIT_TYPE_HERO) and hero == null then
                set hero = u
            endif
        endloop
        
        call DestroyGroup(g)
        set g = null
        set u = null
        return hero
    endfunction

    // Helper: Formatea un real como porcentaje con signo y color
    private function FmtPct takes real val returns string
        local integer pct = R2I(val * 100.0)
        if pct > 0 then
            return "|cff00FF00+" + I2S(pct) + "%|r"
        elseif pct < 0 then
            return "|cffFF0000" + I2S(pct) + "%|r"
        endif
        return "|cff888888+0%|r"
    endfunction

    // Acción principal cuando escriben "-as"
    private function Actions takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local unit hero = GetPlayerHero(p)
        local real baseCd
        local real asMod
        local real realCd
        local real catA = 0.0
        local real catB = 0.0
        local real catC = 0.0
        local real catD = 0.0
        local real catE = 0.0
        local real catF = 0.0
        local integer i
        local integer lvl
        local integer aid
        local integer bid
        local item it
        // --- BOae: Conflicto Janggo vs AOae ---
        local boolean bOaeHasItem  = false
        // Valor del ítem leído desde buffDb (fuente única de verdad: IA_Data_Buffs.j)
        // Si cambias el +18% del Janggo en IA_Data_Buffs.j, se propaga aquí solo.
        local real    bOaeItemVal  = IADataBuffs_GetBuffASMod('BOae')
        local real    bOaeOwnerVal = 0.0
        local real    bOaeAllyVal  = 0.0
        local real    bOaeMax      = 0.0
        local integer j                     // Iterador interno para scan de inventarios aliados (Candidato 4)

        if hero == null then
            call DisplayTimedTextToPlayer(p, 0, 0, 5.0, "|cffFF0000[Sistema]|r No se encontró un héroe activo.")
            set p = null
            return
        endif

        // --- Desglose por categoría (misma lógica que GetAttackSpeedMod) ---

        // A. Agilidad
        set catA = GetHeroAgi(hero, true) * 0.02

        // B. Inventario
        set i = 0
        loop
            exitwhen i > 5
            set it = UnitItemInSlot(hero, i)
            if it != null then
                set catB = catB + IADataItems_GetAttackSpeed(GetItemTypeId(it))
                // [BOae] Detectar Janggo en inventario
                if GetItemTypeId(it) == 'ajen' then
                    set bOaeHasItem = true
                endif
            endif
            set i = i + 1
        endloop

        // C. Auras propias (dueño)
        set i = 0
        loop
            exitwhen i >= IADataBuffs_GetASAuraCount()
            set aid = IADataBuffs_GetASAuraAbilId(i)
            set lvl = GetUnitAbilityLevel(hero, aid)
            if lvl > 0 then
                // [BOae] Diferir AOae
                if aid == 'AOae' then
                    set bOaeOwnerVal = IADataBuffs_GetAbilityASByLevel(aid, lvl)
                else
                    set catC = catC + IADataBuffs_GetAbilityASByLevel(aid, lvl)
                endif
            endif
            set i = i + 1
        endloop

        // D. Self-buffs
        set i = 0
        loop
            exitwhen i >= IADataBuffs_GetASSelfCount()
            set aid = IADataBuffs_GetASSelfAbilId(i)
            set bid = IADataBuffs_GetASSelfBuffId(i)
            set lvl = GetUnitAbilityLevel(hero, aid)
            if lvl > 0 and GetUnitAbilityLevel(hero, bid) > 0 then
                set catD = catD + IADataBuffs_GetAbilityASByLevel(aid, lvl)
            endif
            set i = i + 1
        endloop

        // E. Buffs simples
        set i = 0
        loop
            exitwhen i >= IADataBuffs_GetASBuffCount()
            set bid = IADataBuffs_GetASBuffId(i)
            if GetUnitAbilityLevel(hero, bid) > 0 then
                // [BOae] Skip: se resuelve post-Cat F
                if bid != 'BOae' then
                    set catE = catE + IADataBuffs_GetBuffASMod(bid)
                endif
            endif
            set i = i + 1
        endloop

        // F. Efectos escalados (Cat. 4 — debuffs Y buffs con nivel exacto)
        set i = 0
        loop
            exitwhen i >= IADataBuffs_GetSDCount()
            if IADataBuffs_GetSDField(i) == IADataBuffs_ABIL_AS_LVL_BASE then
                set lvl = IAUtils_GetScaledEffectLevel(hero, i)
                if lvl > 0 then
                    set aid = IADataBuffs_GetSDAbilId(i)
                    // [BOae] Diferir AOae aliada
                    if aid == 'AOae' then
                        set bOaeAllyVal = IADataBuffs_GetAbilityASByLevel(aid, lvl)
                    else
                        set catF = catF + IADataBuffs_GetAbilityASByLevel(aid, lvl)
                    endif
                endif
            endif
            set i = i + 1
        endloop

        // --- RESOLUCIÓN BOae: Atribuir MAX a la categoría ganadora ---
        // bOaeItemVal se lee de buffDb → si cambias el valor del Janggo
        // en IA_Data_Buffs.j, se propaga automáticamente aquí.
        if bOaeHasItem or bOaeOwnerVal > 0.0 or bOaeAllyVal > 0.0 or GetUnitAbilityLevel(hero, 'BOae') > 0 then
            set bOaeMax = 0.0
            // Candidato 1: Janggo en MI inventario (Cat E)
            if bOaeHasItem then
                set bOaeMax = bOaeItemVal
            endif
            // Candidato 2: Mi propia aura AOae (Cat C)
            if bOaeOwnerVal > bOaeMax then
                set bOaeMax = bOaeOwnerVal
            endif
            // Candidato 3: Aura aliada AOae (Cat F)
            if bOaeAllyVal > bOaeMax then
                set bOaeMax = bOaeAllyVal
            endif
            // Candidato 4: Janggo de ALIADO (escaneo directo de inventarios)
            // NO podemos usar presencia de buff BOae para deducir Janggo aliado,
            // porque la propia aura AOae del héroe también genera BOae.
            // Solución: escanear inventarios de héroes aliados buscando 'ajen'.
            // Complejidad: O(n*6), n ≤ 20 héroes. Solo ejecuta si yo no tengo Janggo.
            if not bOaeHasItem then
                set i = 0
                loop
                    exitwhen i >= IACore_AllHeroCount
                    if IACore_AllHeroes[i] != hero and IsUnitAlly(IACore_AllHeroes[i], GetOwningPlayer(hero)) and not IsUnitType(IACore_AllHeroes[i], UNIT_TYPE_DEAD) then
                        set j = 0
                        loop
                            exitwhen j > 5
                            set it = UnitItemInSlot(IACore_AllHeroes[i], j)
                            if it != null and GetItemTypeId(it) == 'ajen' then
                                // Encontrado: comparar valor del Janggo contra MAX actual
                                if bOaeItemVal > bOaeMax then
                                    set bOaeMax = bOaeItemVal
                                endif
                                // Romper ambos loops (ya encontramos el Janggo)
                                set j = 6
                                set i = IACore_AllHeroCount - 1
                            endif
                            set j = j + 1
                        endloop
                    endif
                    set i = i + 1
                endloop
            endif
            // Atribuir a la categoría ganadora
            if bOaeMax == bOaeOwnerVal and bOaeOwnerVal > 0.0 then
                set catC = catC + bOaeMax
            elseif bOaeMax == bOaeAllyVal and bOaeAllyVal > 0.0 then
                set catF = catF + bOaeMax
            else
                set catE = catE + bOaeMax
            endif
        endif

        // --- Resultados totales (vía IA, para validación cruzada) ---
        set asMod = IAUtils_GetAttackSpeedMod(hero)
        set baseCd = IAData_GetHeroBaseCooldown(hero)
        set realCd = IAUtils_GetUnitAttackCooldown(hero)

        // --- Imprimir reporte (Interfaz Limpia en 3 Secciones) ---
        call DisplayTimedTextToPlayer(p, 0, 0, 20.0, "|cffFFCC00======= VELOCIDAD DE ATAQUE =======|r")
        
        // SECCIÓN 1: Identificación y Base
        call DisplayTimedTextToPlayer(p, 0, 0, 20.0, "Héroe: |cff00FFFF" + GetUnitName(hero) + "|r")
        call DisplayTimedTextToPlayer(p, 0, 0, 20.0, "Velocidad Base: " + R2SW(baseCd, 1, 2) + " seg/golpe")
        call DisplayTimedTextToPlayer(p, 0, 0, 20.0, " ")
        
        // SECCIÓN 2: Desglose de Modificadores (1 por línea, sin prefijos)
        call DisplayTimedTextToPlayer(p, 0, 0, 20.0, "|cffAAAAAA[A]|r Mi Agilidad (" + I2S(GetHeroAgi(hero, true)) + " pts): " + FmtPct(catA))
        call DisplayTimedTextToPlayer(p, 0, 0, 20.0, "|cffAAAAAA[B]|r Mis Items (% Directo):     " + FmtPct(catB))
        call DisplayTimedTextToPlayer(p, 0, 0, 20.0, "|cffAAAAAA[C]|r Mis Skills (Auras):    " + FmtPct(catC))
        call DisplayTimedTextToPlayer(p, 0, 0, 20.0, "|cffAAAAAA[D]|r Mis Skills (Hechizos):      " + FmtPct(catD))
        call DisplayTimedTextToPlayer(p, 0, 0, 20.0, "|cffAAAAAA[E]|r Items mios/de otros (Efecto de Estado): " + FmtPct(catE))
        call DisplayTimedTextToPlayer(p, 0, 0, 20.0, "|cffAAAAAA[F]|r Skills de otros (Aura/Hechizos):   " + FmtPct(catF))
        call DisplayTimedTextToPlayer(p, 0, 0, 20.0, " ")
        
        // SECCIÓN 3: El Resultado Final (A prueba de tontos)
        call DisplayTimedTextToPlayer(p, 0, 0, 20.0, "Modificador Total: " + FmtPct(asMod))
        call DisplayTimedTextToPlayer(p, 0, 0, 20.0, "Tiempo Real de Ataque: |cffFFFF00" + R2SW(realCd, 1, 2) + " seg/golpe|r")
        call DisplayTimedTextToPlayer(p, 0, 0, 20.0, "|cffFFCC00=======================================|r")
        
        set p = null
        set hero = null
        set it = null
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer i = 0
        
        // Solo los 10 jugadores: los observadores (slots 10-11) solo tienen -z.
        loop
            exitwhen i > 9
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-as", true)
            set i = i + 1
        endloop
        
        call TriggerAddAction(t, function Actions)
    endfunction

endscope