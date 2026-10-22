scope Fissure initializer Init

    //===========================================================================
    // SISTEMA: FISURA (FISSURE) - v3.0 (Switch AoE / Target)
    // IDs: Habilidad A02V | Visual h00I | Dummy Stun h00J
    //      Stun AoE: A05O (War Stomp)  |  Stun Target: A02W (Storm Bolt)
    //===========================================================================
    //
    // DESCRIPCIÓN:
    //   El héroe crea una línea de grietas en el suelo desde su posición
    //   hacia el punto objetivo. Cada segmento de la fisura detecta enemigos
    //   cercanos y les aplica stun + daño mediante un dummy.
    //   Cada enemigo solo es golpeado UNA vez por fisura (sin importar
    //   cuántos segmentos lo toquen).
    //
    // SWITCH DE MODO (FISSURE_USE_TARGET_STUN):
    //   true  → Storm Bolt (A02W): stun dirigido → SÍ bloqueado por Antimagia
    //   false → War Stomp  (A05O): stun en área  → NO bloqueado por Antimagia
    //
    // CAMBIOS vs. CÓDIGO ORIGINAL:
    //   - Eliminados todos los Location (ahora usa X/Y puro).
    //   - Eliminado TriggerSleepAction (prohibido por arquitectura).
    //   - Eliminado código muerto (destructables que nunca se creaban).
    //   - Eliminadas variables globales udg_* (ahora usa locales).
    //   - Reemplazadas funciones BJ por natives directos.
    //   - Todos los valores son configurables por nivel.
    //   - v3.0: Switch para alternar entre stun AoE y stun por objetivo.
    //
    //===========================================================================

    // ==========================================
    // ===  SWITCH: MODO DE STUN (AoE/Target) ===
    // ==========================================
    // Cambia este valor para alternar el comportamiento del stun de Fisura:
    //   true  = Storm Bolt (TARGET)  → SÍ bloqueado por Antimagia (Spell Shield)
    //   false = War Stomp  (ÁREA)    → NO bloqueado por Antimagia
    globals
        private constant boolean FISSURE_USE_TARGET_STUN = true
    endglobals

    // ==========================================
    // ===        IDs DE REFERENCIA           ===
    // ==========================================

    function Fissure_GetAbilityId takes nothing returns integer
        return 'A02V' // Habilidad del Héroe (Fisura)
    endfunction

    function Fissure_GetVisualDummyId takes nothing returns integer
        return 'h00I' // Unidad visual de la fisura (grieta en el suelo)
    endfunction

    function Fissure_GetStunDummyId takes nothing returns integer
        return 'h00J' // Dummy invisible que ejecuta el stun
    endfunction

    function Fissure_GetStunAbilityId takes nothing returns integer
        if (FISSURE_USE_TARGET_STUN) then
            return 'A02W' // Storm Bolt (single-target) → SÍ bloqueado por Antimagia
        endif
        return 'A05O' // War Stomp (AoE) → NO bloqueado por Antimagia
    endfunction

    // --- STUN Y DAÑO ---
    // El stun y el daño NO se configuran en este archivo.
    // Se configuran en el EDITOR DE OBJETOS, en la habilidad correspondiente:
    //   - Modo Target (true):  habilidad A02W (Storm Bolt)  → 10 niveles
    //   - Modo AoE    (false): habilidad A05O (War Stomp)   → 10 niveles
    // El código sincroniza automáticamente el nivel de la fisura con la habilidad:
    //   SetUnitAbilityLevel(dummy, stunId, level)
    // Así que si la fisura es nivel 9, el stun y daño serán los del nivel 9.

    // ==========================================
    // ===    CONFIGURACIÓN PERSONALIZABLE    ===
    // === (Modifica estos valores a tu gusto) ==
    // ==========================================

    // --- CANTIDAD DE SEGMENTOS POR NIVEL (control manual, 10 niveles) ---
    // Cuántos "trozos" de grieta se crean en línea recta desde el héroe.
    // Más segmentos = fisura más larga.
    // Alcance total de la fisura ˜ Segmentos × Espaciado.
    function Fissure_GetSegments takes integer level returns integer
        if (level == 1) then
            return 15
        elseif (level == 2) then
            return 15
        elseif (level == 3) then
            return 15
        elseif (level == 4) then
            return 15
        elseif (level == 5) then
            return 15
        elseif (level == 6) then
            return 15
        elseif (level == 7) then
            return 15
        elseif (level == 8) then
            return 15
        elseif (level == 9) then
            return 15
        elseif (level == 10) then
            return 15
        endif
        return 15
    endfunction

    // --- ESPACIADO ENTRE SEGMENTOS POR NIVEL (control manual, 10 niveles) ---
    // Distancia (unidades de mapa) entre cada segmento de la fisura.
    // Mayor valor = segmentos más separados = fisura más larga pero con huecos.
    function Fissure_GetSpacing takes integer level returns real
        if (level == 1) then
            return 55.0
        elseif (level == 2) then
            return 55.0
        elseif (level == 3) then
            return 55.0
        elseif (level == 4) then
            return 55.0
        elseif (level == 5) then
            return 55.0
        elseif (level == 6) then
            return 55.0
        elseif (level == 7) then
            return 55.0
        elseif (level == 8) then
            return 55.0
        elseif (level == 9) then
            return 55.0
        elseif (level == 10) then
            return 55.0
        endif
        return 55.0
    endfunction

    // --- RADIO DE IMPACTO POR SEGMENTO Y NIVEL (control manual, 10 niveles) ---
    // Radio (unidades de mapa) alrededor de cada segmento dentro del cual se
    // detectan y golpean enemigos. Mayor radio = más fácil de impactar.
    function Fissure_GetHitRadius takes integer level returns real
        if (level == 1) then
            return 200.0
        elseif (level == 2) then
            return 200.0
        elseif (level == 3) then
            return 200.0
        elseif (level == 4) then
            return 200.0
        elseif (level == 5) then
            return 200.0
        elseif (level == 6) then
            return 200.0
        elseif (level == 7) then
            return 200.0
        elseif (level == 8) then
            return 200.0
        elseif (level == 9) then
            return 200.0
        elseif (level == 10) then
            return 200.0
        endif
        return 200.0
    endfunction

    // --- DURACIÓN VISUAL DE LOS SEGMENTOS POR NIVEL (control manual, 10 niveles) ---
    // Cuánto tiempo (segundos) permanece visible cada trozo de la fisura en el suelo.
    // Solo es COSMÉTICO. No afecta la duración del stun ni el daño.
    function Fissure_GetVisualDuration takes integer level returns real
        if (level == 1) then
            return 0.50
        elseif (level == 2) then
            return 0.50
        elseif (level == 3) then
            return 0.50
        elseif (level == 4) then
            return 0.50
        elseif (level == 5) then
            return 0.50
        elseif (level == 6) then
            return 0.50
        elseif (level == 7) then
            return 0.50
        elseif (level == 8) then
            return 0.50
        elseif (level == 9) then
            return 0.50
        elseif (level == 10) then
            return 0.50
        endif
        return 0.50
    endfunction


    // ==========================================
    // ===       LÓGICA PRINCIPAL             ===
    // ==========================================
    // Crea la línea de grietas y aplica stun+daño a enemigos en rango.
    // Todo ocurre de forma instantánea (sin TriggerSleepAction).
    // Usa coordenadas X/Y puras (sin Location).

    private function Actions takes nothing returns nothing
        local unit caster = GetTriggerUnit()
        local player owner = GetOwningPlayer(caster)
        local real cx = GetUnitX(caster)
        local real cy = GetUnitY(caster)
        local real tx = GetSpellTargetX()
        local real ty = GetSpellTargetY()
        local integer level = GetUnitAbilityLevel(caster, Fissure_GetAbilityId())
        local real angle = Atan2(ty - cy, tx - cx)
        local real angleDeg = angle * bj_RADTODEG
        local real cosA = Cos(angle) // Pre-computado: el ángulo nunca cambia
        local real sinA = Sin(angle) // Pre-computado: evita recalcular en cada iteración
        local integer segments = Fissure_GetSegments(level)
        local real spacing = Fissure_GetSpacing(level)
        local real hitRadius = Fissure_GetHitRadius(level)
        local real visualDur = Fissure_GetVisualDuration(level)
        local real dist = 0.0
        local real sx
        local real sy
        local unit vis
        local unit dummy
        local group g = CreateGroup()
        local group hit = CreateGroup()  // Rastrea enemigos ya golpeados (evita stun duplicado)
        local unit u
        local integer i = 1

        // Rotar al caster hacia el objetivo
        call SetUnitFacing(caster, angleDeg)

        // Crear segmentos de fisura en línea recta
        loop
            exitwhen i > segments
            set dist = dist + spacing
            set sx = cx + dist * cosA
            set sy = cy + dist * sinA

            // 1. CREAR SEGMENTO VISUAL (la grieta en el suelo)
            set vis = CreateUnit(owner, Fissure_GetVisualDummyId(), sx, sy, angleDeg)
            call UnitApplyTimedLife(vis, 'BTLF', visualDur)
        
            // Efecto extra de terremoto (puramente cosmético, no afecta daño ni stun)
            call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Orc\\EarthQuake\\EarthQuakeTarget.mdl", sx, sy))

            // 2. DETECTAR ENEMIGOS EN RANGO DEL SEGMENTO
            call GroupEnumUnitsInRange(g, sx, sy, hitRadius, null)
            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                call GroupRemoveUnit(g, u)

                // Solo golpear enemigos vivos, no estructuras, no inmunes a magia,
                // y que NO hayan sido golpeados ya por esta misma fisura.
                // (Si deseas que la fisura SÍ afecte estructuras o inmunes, quita esos filtros)
                if (IsUnitEnemy(u, owner) and (GetWidgetLife(u) > 0.405) and (not IsUnitInGroup(u, hit)) and (not IsUnitType(u, UNIT_TYPE_STRUCTURE)) and (not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE))) then
                    // Marcar como golpeado (evita stun duplicado por solapamiento de segmentos)
                    call GroupAddUnit(hit, u)

                    // Registrar asistencia (vía Control, key 600+i).
                    // El daño lo aplica un dummy (no el héroe), así que MB_OnDamage
                    // nunca lo detecta. Registramos manualmente para que el stun cuente.
                    // (Lógica inlineada de MB_RegisterControlTimestamp — evita error de orden de compilación)
                    if (IsUnitType(u, UNIT_TYPE_HERO)) then
                        call SaveReal(udg_MB_Hash, GetPlayerId(GetOwningPlayer(u)), 600 + GetPlayerId(GetOwningPlayer(caster)), TimerGetElapsed(MB_Timer))
                        if (MB_DEBUG_ASIST) then
                            call DisplayTimedTextToPlayer(GetOwningPlayer(caster), 0, 0, 15.0, "|cffFFCC00[Asist]|r Control+Bloqueo (Fisura) -> " + GetUnitName(u))
                        endif
                    endif

                    // Crear dummy con stun en la posición EXACTA del enemigo
                    set dummy = CreateUnit(owner, Fissure_GetStunDummyId(), GetUnitX(u), GetUnitY(u), angleDeg)
                    call UnitAddAbility(dummy, Fissure_GetStunAbilityId())
                    call SetUnitAbilityLevel(dummy, Fissure_GetStunAbilityId(), level)
                    // Switch: Target (thunderbolt → Antimagia SÍ bloquea) vs AoE (stomp → NO bloquea)
                    if (FISSURE_USE_TARGET_STUN) then
                        call IssueTargetOrder(dummy, "thunderbolt", u)
                    else
                        call IssueImmediateOrder(dummy, "stomp")
                    endif
                    call UnitApplyTimedLife(dummy, 'BTLF', 1.0)
                endif
            endloop

            set i = i + 1
        endloop

        // --- LIMPIEZA COMPLETA (sin memory leaks) ---
        call DestroyGroup(g)
        call GroupClear(hit)   // Precaución: vaciar antes de destruir (código defensivo)
        call DestroyGroup(hit)
        set g = null
        set hit = null
        set caster = null
        set owner = null
        set vis = null
        set dummy = null
        set u = null
    endfunction


    // ==========================================
    // ===       INICIALIZACIÓN               ===
    // ==========================================

    private function Conditions takes nothing returns boolean
        return GetSpellAbilityId() == Fissure_GetAbilityId()
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        call TriggerAddCondition(t, Condition(function Conditions))
        call TriggerAddAction(t, function Actions)
        set t = null
    endfunction

endscope