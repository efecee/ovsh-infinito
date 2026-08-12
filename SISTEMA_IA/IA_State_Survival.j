library IAStateSurvival requires IAUtils, IABrainMacro, IABreakout, IABlackboard

    globals
        public constant real LOW_HP_THRESHOLD = 0.40
        public constant real HEALTHY_THRESHOLD = 0.95

        // ----- SURVIVAL CONTEXTUAL (umbral dinámico) -----
        // El 40% deja de ser plano. Lee los sensores de presión de la pizarra
        // (los rellena Think; aquí llegan con 0.10s de staleness, igual que el
        // kill-commit). Dos ajustes en direcciones opuestas:
        //   * FOCUS: cada héroe enemigo EXTRA enfocándome sube el umbral (huir
        //     ANTES cuando me cae el equipo entero encima — a 40% bajo focus de
        //     3 ya es tarde).
        //   * SEGURIDAD: con CERO peligro (sin héroes enemigos cerca, sin daño
        //     entrante, sin pérdida real de vida) el umbral BAJA: no abandonar
        //     un carril vacío a 39% para caminar 30s a base.
        public constant real RETREAT_PER_FOCUS  = 0.07  // +7% de umbral por héroe enemigo extra enfocándome
        public constant real RETREAT_MAX        = 0.60  // techo del umbral dinámico
        public constant real SAFE_RETREAT_FLOOR = 0.28  // umbral con cero peligro detectado

        // ----- COMPROMISO DE REMATE (KILL-COMMIT) -----
        // Diales de criterio humano del override que evita huir cuando el equipo va a
        // cerrar un kill casi seguro. Son los ÚNICOS valores a tocar para subir/bajar
        // la agresividad de este sistema (no afectan a nada más del Survival).
        public constant real    KILLCOMMIT_HP_FLOOR    = 0.20  // bajo esto, SIEMPRE huye (no vale morir)
        public constant real    KILLCOMMIT_TARGET_HP   = 0.30  // el enemigo-foco debe estar bajo esto ("a punto de morir")
        public constant integer KILLCOMMIT_MIN_ALLIES  = 2     // teamFocusCount >= 2 (con el bot = 3 atacantes)
    endglobals

    // ¿DEBO HUIR? (umbral CONTEXTUAL — ver constantes arriba)
    // Si los sensores aún no corrieron nunca (bot recién nacido), valen 0 y el
    // resultado es exactamente el umbral base de siempre.
    public function ShouldRetreat takes unit botUnit, real hpPercent returns boolean
        local LaningBrain brain = IABlackboard_GetLaningBrain(botUnit)
        local real thr = LOW_HP_THRESHOLD
        if brain.enemiesTargetingMe >= 2 then
            // Focus enemigo: huir antes.
            set thr = thr + RETREAT_PER_FOCUS * I2R(brain.enemiesTargetingMe - 1)
            if thr > RETREAT_MAX then
                set thr = RETREAT_MAX
            endif
        elseif brain.enemyHeroesNear == 0 and brain.incomingDamage <= 0.0 and brain.selfLossRate < 1.0 then
            // Cero peligro: seguir farmeando hasta un piso más bajo.
            set thr = SAFE_RETREAT_FLOOR
        endif
        return hpPercent < thr
    endfunction

    // ¿ESTOY SANO?
    public function IsHealthy takes real hpPercent returns boolean
        return hpPercent > HEALTHY_THRESHOLD
    endfunction

    // ============================================================
    // COMPROMISO DE REMATE (KILL-COMMIT)
    // ============================================================
    // ¿Hay un remate de equipo casi seguro que justifique NO huir y seguir aportando
    // DPS aunque la vida baje del 40%? Condición (perfil ajustado):
    //   (1) la vida del bot supera el piso (si no, siempre huir),
    //   (2) >= KILLCOMMIT_MIN_ALLIES aliados enfocando el MISMO héroe enemigo, y
    //   (3) ese héroe está por debajo de KILLCOMMIT_TARGET_HP (agonizante).
    // Lee SOLO datos ya calculados por Think() (teamFocusTarget/teamFocusCount). Son
    // frescos: el gate mantiene al bot en Laning, así que Think corre cada frame. NO
    // emite órdenes ni escribe estado de combate; solo responde sí/no. El selector de
    // IA_Core publica el resultado en brain.killCommitActive.
    public function KillCommitActive takes unit botUnit, real hpPercent returns boolean
        local LaningBrain brain
        local unit ft
        local boolean result = false
        // (1) PISO: por debajo, siempre huir (salida temprana, ft aún null).
        if hpPercent <= KILLCOMMIT_HP_FLOOR then
            return false
        endif
        set brain = IABlackboard_GetLaningBrain(botUnit)
        set ft = brain.teamFocusTarget
        // (2) foco grupal vivo + (3) >= MIN_ALLIES aliados + (4) enemigo agonizante.
        if ft != null and not IsUnitType(ft, UNIT_TYPE_DEAD) and brain.teamFocusCount >= KILLCOMMIT_MIN_ALLIES then
            set result = (GetUnitState(ft, UNIT_STATE_LIFE) / GetUnitState(ft, UNIT_STATE_MAX_LIFE)) < KILLCOMMIT_TARGET_HP
        endif
        set ft = null
        return result
    endfunction

    // EJECUTAR HUIDA (ANTI-SHAKE V2)
    public function ExecuteRetreat takes unit botUnit, player botOwner returns nothing
        local LaningBrain brain = IABlackboard_GetLaningBrain(botUnit)
        local real homeX
        local real homeY
        local real dist
        local integer currentOrder
        local real escX
        local real escY

        // ============================================================
        // GUARDIA DE FUENTE (espejo del que hace Laning).
        // ============================================================
        // Si un bot a poca vida quedó dentro de la fuente enemiga (p.ej. lo
        // empujaron al perseguir), aquí también lo sacamos antes que cualquier
        // otra cosa: la torre de fuente lo mata en segundos.
        if IABrainMacro_GetFountainEscape(botUnit) then
            set escX = IABrainMacro_GetObjectiveX()
            set escY = IABrainMacro_GetObjectiveY()
            if GetUnitCurrentOrder(botUnit) != OrderId("move") then
                call IssuePointOrder(botUnit, "move", escX, escY)
            endif
            return
        endif

        set homeX = IABrainMacro_GetClosestHomeX(botUnit)
        set homeY = IABrainMacro_GetClosestHomeY(botUnit)
        set currentOrder = GetUnitCurrentOrder(botUnit)
        set dist = IAUtils_GetDistanceUnitXY(botUnit, homeX, homeY)

        // ============================================================
        // ¿YA LLEGUÉ A CASA? (debe ir ANTES del anti-encierro)
        // ============================================================
        // Si la distancia a la base es muy pequeña (< 150), ya llegamos y
        // estamos curando: NO damos orden (evita temblor) y, sobre todo, NO
        // corremos las guardias anti-encierro. Si las corriéramos, el bot
        // parado curándose no progresa en eje X y a los 4s dispararía un falso
        // "Encerrado!" (atacando creeps aliados de la fuente y escalando a
        // Berserker en su propia base). El encierro solo tiene sentido EN RUTA.
        if dist < 150.0 then
            return
        endif

        // ============================================================
        // GUARDIAS ANTI-ENCIERRO (3 capas + Berserker)
        // ============================================================
        // En Survival siempre estamos huyendo, así que isRetreating=true y
        // wantsToMove=true. Detalle en IA_Breakout.j.

        // (1) BERSERKER si está activo y encuentra target.
        if brain.berserkActive then
            if IABreakout_ExecuteBerserk(botUnit, botOwner) then
                return
            endif
        endif

        // (2) DESPEJE EN RUTA: creep estacionario en cono, <=3 golpes -> matarlo.
        if IABreakout_TryPathClear(botUnit, botOwner) then
            return
        endif

        // (3) ENCIERRO REAL (métrica eje X, 4s).
        if IABreakout_Try(botUnit, botOwner, true, true, currentOrder) then
            return
        endif

        // Si ya tengo la orden de "move" (851986), no la repito, sin importar la distancia,
        // para que el pathfinding de Warcraft 3 fluya suavemente sin interrupciones.
        if currentOrder == OrderId("move") then
            return
        endif
        
        // Si no estoy moviéndome o fui interrumpido, doy la orden de ir a base.
        call IssuePointOrder(botUnit, "move", homeX, homeY)
    endfunction

endlibrary