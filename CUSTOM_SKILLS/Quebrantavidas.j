//===========================================================================
// SISTEMA: QUEBRANTAVIDAS (LIFE BREAK) - v2.0
// IDs: Habilidad A040 | Dummy Caster h00J | Slow A03Z
//===========================================================================
//
// DESCRIPCIÓN:
//   El héroe salta hacia una unidad enemiga, infligiendo daño porcentual
//   basado en la vida actual del objetivo Y auto-infligiéndose el mismo
//   porcentaje sobre su propia vida. Al aterrizar, aplica una
//   ralentización mediante Dummy Caster.
//
//   MECÁNICA:
//     1. Al castear, el héroe desactiva su pathing y vuela hacia el
//        objetivo con animación de ataque y efecto visual de vuelo.
//     2. En cada tick persigue la posición VIVA del target (si se mueve,
//        lo sigue).
//     3. Al llegar (distancia <= radio de impacto):
//        - Daño porcentual al enemigo (% de SU vida actual).
//        - REGLA DEL PACTO: si el golpe conecta (el enemigo perdió vida),
//          el caster paga SIEMPRE su % de vida actual, aunque esté
//          protegido (Gran Vudú, Banish...). Si no conecta (Banish,
//          Escudo Divino, Ciclón en la víctima), no paga nadie.
//        - Efecto visual de impacto (War Stomp + sangre): SOLO si conectó.
//        - Dummy Caster aplica Slow (A03Z) al nivel correspondiente: SOLO
//          si conectó (si no, no gasta el Amuleto Antimagia de la víctima).
//        - Auto-ataque inmediato al enemigo.
//     4. Se interrumpe si el caster o el target mueren, o si el caster
//        recibe orden Stop.
//
//   Esta es una habilidad ULTIMATE con 6 niveles.
//   Es 100% portátil: funciona con cualquier héroe que tenga A040.
//
//===========================================================================
//
// ╔══════════════════════════════════════════════════════════════════════╗
// ║   GUÍA: ¿DÓNDE CAMBIAR CADA COSA?                                  ║
// ╠══════════════════════════════════════════════════════════════════════╣
// ║                                                                    ║
// ║  ► DAÑO PORCENTUAL (% de vida actual, por nivel):                  ║
// ║    → Aquí, función LB_GetDamagePercent.                            ║
// ║    → Se aplica UNA vez al impactar. Tanto al enemigo como al       ║
// ║      caster (auto-daño), o a ninguno si el golpe no conecta.       ║
// ║                                                                    ║
// ║  ► VELOCIDAD DE VUELO (por nivel):                                 ║
// ║    → Aquí, función LB_GetFlightSpeed.                              ║
// ║    → Unidades de mapa por tick (0.03s). 35 ≈ ~1167 uds/seg.        ║
// ║                                                                    ║
// ║  ► RADIO DE IMPACTO (distancia para considerar "llegó"):           ║
// ║    → Aquí, función LB_GetImpactRadius.                             ║
// ║    → 120 es generoso. Reduce para más precisión.                   ║
// ║                                                                    ║
// ║  ► EFECTO DE VUELO (modelo visual mientras vuela):                 ║
// ║    → Aquí, función LB_GetFlightSfxPath.                            ║
// ║    → Se adjunta al "chest" del caster durante el vuelo.            ║
// ║                                                                    ║
// ║  ► EFECTO DE IMPACTO (modelo visual al aterrizar):                 ║
// ║    → Aquí, función LB_GetImpactSfxPath.                            ║
// ║    → Aparece en el suelo al llegar al objetivo.                    ║
// ║                                                                    ║
// ║  ► EFECTO DE SANGRE (modelo visual de daño):                       ║
// ║    → Aquí, función LB_GetBloodSfxPath.                             ║
// ║    → Se adjunta al "chest" del target al recibir daño.             ║
// ║                                                                    ║
// ║  ► COOLDOWN Y MANÁ:                                                ║
// ║    → En el EDITOR DE OBJETOS, habilidad A040.                      ║
// ║                                                                    ║
// ║  ► RALENTIZACIÓN (duración, porcentaje de slow):                   ║
// ║    → En el EDITOR DE OBJETOS, habilidad A03Z (Slow del Dummy).     ║
// ║    → La duración y el % de MS reduction se configuran ahí.         ║
// ║                                                                    ║
// ╚══════════════════════════════════════════════════════════════════════╝
//
//===========================================================================

scope LifeBreak initializer Init




    // ==========================================
    // ===    CONFIGURACIÓN POR NIVEL         ===
    // ===    (MODIFICA A TU ANTOJO)          ===
    // ==========================================

    // --- DAÑO PORCENTUAL (por nivel, 6 niveles) ---
    // Porcentaje de la vida ACTUAL que se inflige como daño.
    // Se aplica tanto al enemigo (% de su vida) como al caster (% de su vida).
    // Ejemplo: 0.15 = 15% de la vida actual.
    private function LB_GetDamagePercent takes integer level returns real
        if (level == 1) then
            return 0.15
        elseif (level == 2) then
            return 0.21
        elseif (level == 3) then
            return 0.27
        elseif (level == 4) then
            return 0.33
        elseif (level == 5) then
            return 0.39
        elseif (level == 6) then
            return 0.45
        endif
        return 0.15
    endfunction

    // --- VELOCIDAD DE VUELO (por nivel, 6 niveles) ---
    // Unidades de mapa que avanza el caster por tick (cada 0.03s).
    // Valor 35 ≈ 1167 unidades/segundo. Más alto = más rápido.
    private function LB_GetFlightSpeed takes integer level returns real
        if (level == 1) then
            return 35.00
        elseif (level == 2) then
            return 35.00
        elseif (level == 3) then
            return 35.00
        elseif (level == 4) then
            return 35.00
        elseif (level == 5) then
            return 35.00
        elseif (level == 6) then
            return 35.00
        endif
        return 35.00
    endfunction


    // ==========================================
    // ===    CONSTANTES INTERNAS             ===
    // ==========================================

    // Período del timer (0.03s ≈ 33 FPS de la persecución).
    private function LB_GetTick takes nothing returns real
        return 0.03
    endfunction

    // Radio de impacto: distancia mínima para considerar que el caster
    // llegó al target. 120 es generoso para que el aterrizaje se sienta
    // inmediato. Reduce si quieres que el héroe llegue más cerca.
    private function LB_GetImpactRadius takes nothing returns real
        return 120.00
    endfunction

    // Ruta del modelo visual de vuelo (se adjunta al "chest" del caster).
    private function LB_GetFlightSfxPath takes nothing returns string
        return "Abilities\\Spells\\Orc\\Bloodlust\\BloodlustTarget.mdl"
    endfunction

    // Ruta del modelo visual de impacto en el suelo (War Stomp).
    private function LB_GetImpactSfxPath takes nothing returns string
        return "Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl"
    endfunction

    // Ruta del modelo visual de sangre (se adjunta al "chest" del target).
    private function LB_GetBloodSfxPath takes nothing returns string
        return "Objects\\Spawnmodels\\Human\\HumanBlood\\HumanBloodLarge0.mdl"
    endfunction

    // Ruta del modelo visual del RASTRO que deja el heroe al volar.
    // Se crea en el suelo cada N ticks (ver LB_GetTrailInterval).
    // Opciones atractivas:
    //   "Abilities\\Spells\\Undead\\Carrion Swarm\\CarrionSwarmDamage.mdl" (humo oscuro)
    //   "Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl"     (polvo de estampida)
    //   "Abilities\\Spells\\Orc\\MirrorImage\\MirrorImageCaster.mdl"      (espejismo)
    //   "Abilities\\Spells\\Human\\HolyBolt\\HolyBoltSpecialArt.mdl"     (destello dorado)
    //   "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl" (polvo de empalamiento)
    private function LB_GetTrailSfxPath takes nothing returns string
        return "Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl"
    endfunction

    // Cada cuantos ticks se genera un efecto de rastro.
    // 1 tick = 0.03s. Valor 3 = un efecto cada ~0.09s (denso).
    // Valor 5 = cada ~0.15s (moderado). Valor 8 = cada ~0.24s (espaciado).
    private function LB_GetTrailInterval takes nothing returns integer
        return 3
    endfunction


    // ==========================================
    // ===    VARIABLES DE INSTANCIA          ===
    // ==========================================

    globals
        // === IDs DE REFERENCIA ===
        private constant integer SPELL_ID = 'A040'  // Habilidad base del heroe (Canal)
        private constant integer DUMMY_ID = 'h00J'  // Unidad invisible (Dummy Caster)
        private constant integer SLOW_ID  = 'A03Z'  // Habilidad de ralentizacion del Dummy

        // Memoria para mapear timer -> struct de datos.
        private hashtable hash = InitHashtable()
    endglobals

    private struct JumpData
        unit    caster
        unit    target
        timer   t
        integer level
        real    speed       // Velocidad de vuelo (unidades/tick)
        real    pct         // Porcentaje de dano (fraccion decimal)
        effect  flightSfx   // Efecto visual durante el vuelo
        integer tickCount   // Contador de ticks para el rastro
    endstruct


    // ==========================================
    // ===       CALLBACK DEL TIMER           ===
    // ==========================================

    private function Loop takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local integer id = GetHandleId(t)
        local JumpData data = LoadInteger(hash, id, 0)
        local real cx = GetUnitX(data.caster)
        local real cy = GetUnitY(data.caster)
        local real tx = GetUnitX(data.target)
        local real ty = GetUnitY(data.target)
        local real dx = tx - cx
        local real dy = ty - cy
        local real dist = SquareRoot(dx * dx + dy * dy)
        local real angle
        local unit dummy
        local real targetDmg
        local real casterDmg
        local real lifeBefore
        local real manaBefore
        local real newLife

        // =============================================
        // 1. CONDICIÓN DE INTERRUPCIÓN
        // =============================================
        // Se interrumpe si el target o el caster mueren, o si el
        // caster recibe la orden Stop (851973).
        if GetWidgetLife(data.target) < 0.405 or GetWidgetLife(data.caster) < 0.405 or GetUnitCurrentOrder(data.caster) == 851973 then
            call PauseTimer(t)
            call DestroyTimer(t)
            call FlushChildHashtable(hash, id)
            call SetUnitPathing(data.caster, true)

            // Limpiamos el efecto de vuelo y la animación
            call DestroyEffect(data.flightSfx)
            call ResetUnitAnimation(data.caster)

            call data.destroy()
            set t = null
            set dummy = null
            return
        endif

        // =============================================
        // 2. EL IMPACTO (Llegada al objetivo)
        // =============================================
        if dist <= LB_GetImpactRadius() then
            call PauseTimer(t)
            call DestroyTimer(t)
            call FlushChildHashtable(hash, id)
            call SetUnitPathing(data.caster, true)

            // Apagar efecto de vuelo y resetear animación
            call DestroyEffect(data.flightSfx)
            call ResetUnitAnimation(data.caster)

            // Solo aplicar daño, slow y auto-ataque si es enemigo
            if IsUnitEnemy(data.target, GetOwningPlayer(data.caster)) then

                // Matemáticas del daño porcentual
                set lifeBefore = GetWidgetLife(data.target)
                set manaBefore = GetUnitState(data.target, UNIT_STATE_MANA)
                set targetDmg = lifeBefore * data.pct
                set casterDmg = GetWidgetLife(data.caster) * data.pct

                // Daño a la víctima (Caos + Universal = daño puro, salvo
                // etéreos: Caos x0 contra Banish)
                call UnitDamageTarget(data.caster, data.target, targetDmg, true, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_UNIVERSAL, WEAPON_TYPE_WHOKNOWS)

                // REGLA DEL PACTO: si el golpe conecta, pagan los dos; si no
                // conecta, no paga nadie. "Conecta" = la víctima perdió vida
                // (o maná, si un Escudo de Maná absorbió el golpe). Se mide
                // en vez de listar buffs: Banish, Escudo Divino, Ciclón o
                // cualquier protección futura dejan el golpe en 0 y el motor
                // es quien lo decide.
                if GetWidgetLife(data.target) < lifeBefore or GetUnitState(data.target, UNIT_STATE_MANA) < manaBefore then

                    // El precio del Troll NO es daño: se resta directo para
                    // que ninguna protección propia (Gran Vudú, Banish sobre
                    // él, Escudo Divino en aleatorio) se lo perdone. Nunca lo
                    // mata: SetWidgetLife a 0 no le daría la muerte a nadie.
                    if GetWidgetLife(data.caster) >= 0.405 then
                        set newLife = GetWidgetLife(data.caster) - casterDmg
                        if newLife < 1.00 then
                            set newLife = RMinBJ(1.00, GetWidgetLife(data.caster))
                        endif
                        call SetWidgetLife(data.caster, newLife)
                    endif

                    // Efectos de impacto (War Stomp + sangre): son la señal
                    // visible de que hubo reducción de vida. Sin golpe, no salen.
                    call DestroyEffect(AddSpecialEffect(LB_GetImpactSfxPath(), tx, ty))
                    call DestroyEffect(AddSpecialEffectTarget(LB_GetBloodSfxPath(), data.target, "chest"))

                    // Dummy Caster: aplicar ralentización. También solo si
                    // conectó: un golpe nulo (Banish...) no lanza el slow, así
                    // no le gasta el Amuleto Antimagia a la víctima.
                    set dummy = CreateUnit(GetOwningPlayer(data.caster), DUMMY_ID, tx, ty, 0)
                    call UnitAddAbility(dummy, SLOW_ID)
                    call SetUnitAbilityLevel(dummy, SLOW_ID, data.level)
                    call IssueTargetOrder(dummy, "slow", data.target)
                    call UnitApplyTimedLife(dummy, 'BTLF', 1.0)
                endif

                // Forzar auto-ataque inmediato al enemigo
                call IssueTargetOrder(data.caster, "attack", data.target)
            endif

            call data.destroy()

        else
            // =============================================
            // 3. EL VUELO (Avanzar hacia el target)
            // =============================================
            set angle = Atan2(dy, dx)
            call SetUnitX(data.caster, cx + data.speed * Cos(angle))
            call SetUnitY(data.caster, cy + data.speed * Sin(angle))
            call SetUnitFacing(data.caster, angle * bj_RADTODEG)

            // Rastro visual: dejar efecto en el suelo cada N ticks
            set data.tickCount = data.tickCount + 1
            if data.tickCount >= LB_GetTrailInterval() then
                set data.tickCount = 0
                call DestroyEffect(AddSpecialEffect(LB_GetTrailSfxPath(), cx, cy))
            endif
        endif

        set t = null
        set dummy = null
    endfunction


    // ==========================================
    // ===       ACCIÓN DE CASTEO             ===
    // ==========================================

    private function Actions takes nothing returns nothing
        local JumpData data = JumpData.create()
        local timer t = CreateTimer()

        set data.caster = GetTriggerUnit()
        set data.target = GetSpellTargetUnit()
        set data.level  = GetUnitAbilityLevel(data.caster, SPELL_ID)
        set data.t      = t
        set data.speed  = LB_GetFlightSpeed(data.level)
        set data.pct    = LB_GetDamagePercent(data.level)

        // Efecto visual de vuelo (adjunto al "chest" del caster)
        set data.flightSfx = AddSpecialEffectTarget(LB_GetFlightSfxPath(), data.caster, "chest")

        // Desactivar pathing para atravesar unidades y terreno
        call SetUnitPathing(data.caster, false)

        // Forzar animación de ataque durante el vuelo
        call SetUnitAnimation(data.caster, "attack")

        // Registrar en hashtable y arrancar timer
        call SaveInteger(hash, GetHandleId(t), 0, data)
        call TimerStart(t, LB_GetTick(), true, function Loop)

        set t = null
    endfunction


    // ==========================================
    // ===       INICIALIZACIÓN               ===
    // ==========================================

    private function Conditions takes nothing returns boolean
        return GetSpellAbilityId() == SPELL_ID
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        call TriggerAddCondition(t, Condition(function Conditions))
        call TriggerAddAction(t, function Actions)
        set t = null
    endfunction

endscope