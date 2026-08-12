scope ZonaSeleccion initializer Init

    // ============================================================================
    // 1. FUNCIÓN PURIFICADORA (Transforma héroes en Hologramas perfectos)
    // ============================================================================
    private function PrepararDisplayHeroes takes rect r returns nothing
        local group g = CreateGroup()
        local unit u
        local integer unitId // Nueva variable para almacenar el "DNI" de la unidad
    
        call GroupEnumUnitsInRect(g, r, null)
    
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
        
            set unitId = GetUnitTypeId(u) // Obtenemos el ID de la unidad actual

            // === EL FILTRO DE EXCLUSIÓN ===
            // Si el ID NO es 'ewsp' Y el ID NO es 'e006', entonces procedemos.
            if (unitId != 'ewsp' and unitId != 'e006') then
            
                // 1. Quitar invisibilidad nocturna
                call UnitRemoveAbility(u, 'Asha')
            
                // 2. Hacerlos invulnerables
                call UnitAddAbility(u, 'Avul')
            
                // 3. Quitar colisión física (Para que no estorben al Wisp)
                call SetUnitPathing(u, false)
            
                // 4. NOTA: NO usar truco Aloc (add/remove Locust). Aunque hace
                //    al maniquí in-seleccionable, también impide que los triggers
                //    de selección lo detecten con GroupEnumUnitsInRect, dejándolo
                //    visible permanentemente como si el héroe siguiera disponible.
                //    La invulnerabilidad (Avul) + pausa ya es suficiente protección.
            
                // 5. PAUSAR UNIDAD (Ahorro de CPU/RAM total)
                call PauseUnit(u, true)
            
            else
                // Wisp / Alma Corrupta del JUGADOR (la unidad que controla para
                // elegir su héroe). La hacemos INVULNERABLE para que un aliado
                // troll con Botas TP no pueda teletransportarse a ella, entrar a
                // la zona de selección y matarla — lo que dejaría al jugador AFK
                // sin nada que controlar (no podría jugar) al volver.
                //
                // La selección NO se rompe: el pick por héroe elimina al Wisp con
                // RemoveUnit y el modo All Random con KillUnit (ExplodeUnitBJ).
                // AMBOS ignoran por completo la invulnerabilidad (solo el DAÑO se
                // bloquea), así que el Wisp se sigue eliminando al elegir héroe.
                call SetUnitInvulnerable(u, true)
            endif

            call GroupRemoveUnit(g, u)
        endloop
    
        call DestroyGroup(g)
        set u = null
    endfunction

    // ============================================================================
    // 2. EJECUCIÓN (Debe ir arriba del Init para que el compilador la lea primero)
    // ============================================================================
    private function Ejecutar takes nothing returns nothing
        call PrepararDisplayHeroes(gg_rct_ZonaHumanos)
        call PrepararDisplayHeroes(gg_rct_ZonaOrcos)
    endfunction

    // ============================================================================
    // 2.5 PROTECCIÓN ANTI-HECHIZO (Wisp / Alma Corrupta = objetivo prohibido)
    // ----------------------------------------------------------------------------
    //   El Wisp ('ewsp', Humanos) y el Alma Corrupta ('e006', Orcos) son las
    //   unidades que el jugador controla SOLO para elegir héroe. Ya las hicimos
    //   invulnerables (no reciben daño), pero un aliado troll con Botas TP podía
    //   teletransportarse SOBRE ellas y colarse a la zona de selección. Aquí
    //   cancelamos CUALQUIER hechizo cuyo OBJETIVO sea una de estas dos unidades
    //   (incluido el TP), justo cuando arranca el casteo.
    //
    //   Aplica EXCLUSIVAMENTE a 'ewsp' y 'e006'. Ningún otro objetivo se toca.
    // ============================================================================
    private function EsUnidadSeleccion takes unit u returns boolean
        local integer id = GetUnitTypeId(u) // null -> 0, no coincide con ninguno
        return id == 'ewsp' or id == 'e006'
    endfunction

    private function BloquearHechizo takes nothing returns nothing
        // Solo intervenimos si el hechizo apunta a un Wisp / Alma Corrupta.
        if EsUnidadSeleccion(GetSpellTargetUnit()) then
            // SPELL_CHANNEL dispara al ARRANCAR el cast (antes del efecto): el
            // "stop" interrumpe la canalización del TP antes de teletransportar.
            call IssueImmediateOrder(GetTriggerUnit(), "stop")
            call DisplayTextToPlayer(GetOwningPlayer(GetTriggerUnit()), 0, 0, /*
            */ "|cffff5555Imposible hacer TP sobre wisps / almas corruptas.|r")
        endif
    endfunction

    // ============================================================================
    // 3. INICIALIZACIÓN (El compilador llega aquí al final, sabiendo todo lo anterior)
    // ============================================================================
    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterTimerEventSingle(t, 0.1)
        call TriggerAddAction(t, function Ejecutar) // ¡Ahora sí sabe qué es Ejecutar!

        // Detonador permanente: bloquea hechizos sobre Wisps / Almas Corruptas.
        set t = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_CHANNEL)
        call TriggerAddAction(t, function BloquearHechizo)

        set t = null
    endfunction

endscope