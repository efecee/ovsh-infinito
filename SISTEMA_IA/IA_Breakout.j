library IABreakout requires IAUtils, IABlackboard, IABrainMacro, IAData

    // ============================================================
    // ANTI-ENCIERRO (BREAKOUT) — 3 capas + Berserker
    // ============================================================
    //
    // CAPA 1 — DESPEJE EN RUTA (huyendo, oportunista):
    //   Mientras huye (Survival o de-aggro), si hay un creep estacionario en
    //   el cono frontal hacia casa y lo puede matar en <= 2 golpes, lo mata
    //   de paso. Si tomaría más golpes, lo rodea (no fuerza nada). Si el creep
    //   está moviéndose, espera a que pase. Aplica SOLO a creeps (cualquier
    //   bando). No a héroes.
    //
    // CAPA 2 — ENCIERRO REAL (intención de moverse + no progresa):
    //   Detección por métrica adecuada al contexto:
    //     - Huyendo  -> acercamiento a casa en LÍNEA RECTA (X+Y) (4s sin avanzar = atascado).
    //     - Combate  -> desplazamiento euclídeo (0.7s sin moverse = atascado).
    //   Al confirmarse, escanea el anillo (~200) y fuerza ataque con prioridad:
    //   HÉROE ENEMIGO > CREEP ENEMIGO > CREEP ALIADO, prefiriendo víctimas en
    //   el cono de salida (hacia casa). NUNCA héroes aliados.
    //
    // CAPA 3 — CONTADOR DE REINCIDENCIA Y BERSERKER:
    //   Cada vez que un breakout TERMINA, abre una ventana de 2 segundos. Si
    //   el bot se vuelve a atascar dentro de esa ventana, el contador sube
    //   (1->2->3). Al 3er encierro consecutivo entra en BERSERKER: acepta su
    //   muerte y, en vez de seguir intentando escapar inútilmente, gasta los
    //   últimos segundos matando lo más valioso posible:
    //     1) Héroe enemigo en mi rango con mayor presión aliada.
    //     2) Si no, héroe enemigo en mi rango con menor golpes-para-matar
    //        (HP / (damage * armorReduction)).
    //     3) Si no hay héroe en mi rango, invocación en mi rango.
    //     4) Si no hay ni una ni la otra, sigue intentando escapar (cae al
    //        flujo normal de TryPathClear / Try) — mantiene el modo activo.
    //   SALIDAS del modo Berserker: muere, mata al target elegido, se aleja
    //   >=600 del punto de entrada, o recupera HP > 70%.
    //
    // INVARIANTE NO-PEGAJOSIDAD: ni breakout ni berserker escriben jamás
    // brain.lastTarget / isRetreating / objetivo de avance. Usan sus propios
    // canales (breakoutTarget, berserkTarget). Al salir, la lógica normal
    // (Think + de-aggro / Survival) recalcula la intención sola.
    // ============================================================

    globals
        // CAPA 2 — encierro genérico (combate)
        private constant real MOVE_EPS          = 60.0   // unidades de progreso real (no euclídeo)
        private constant real STUCK_TIME        = 0.70   // s sin progreso => atascado
        // CAPA 1+2 — modo huida (acercamiento a casa en línea recta, X+Y)
        private constant real X_PROGRESS_EPS    = 60.0   // unidades de acercamiento a casa (línea recta)
        private constant real X_STUCK_TIME      = 4.00   // s sin acercarse => forzar matar incluso si toma >3 golpes (encierro INICIAL)
        private constant real X_STUCK_TIME_CHAIN = 1.90  // s para RE-detectar atascado dentro de CYCLE_WINDOW (cadena C1->C2->C3->Berserker). Cae en el tick 1.9 del loop de 0.10s, un tick entero por debajo de la ventana de 2.0s; 2.0 quedaría en el borde exacto y fallaría intermitentemente por drift de coma flotante.
        // Búsqueda de víctima
        private constant real BREAKOUT_RADIUS   = 200.0  // anillo de bloqueadores
        private constant real PATH_CONE_RADIUS  = 250.0  // distancia a creep frontal en path-clear (largo del corredor de despeje)
        private constant real CONE_WIDE_HALF    = 1.047198  // 60° (cono más permisivo para ring breakout)
        // Path-clear
        private constant real MAX_HITS_INLINE   = 2.0    // huida: si lo mato en <= 2, lo mato de paso
        private constant real MAX_HITS_CHASE    = 2.0    // persecución: umbral más estricto (perseguir es opcional)
        // CORREDOR DE DESPEJE (CHANGE B/C): "¿el bloqueador TAPA de verdad?"
        private constant real CORRIDOR_HALF     = 110.0  // medio ancho del pasillo (colisión bot+creep+margen). Un creep más lejos de la LÍNEA RECTA bot->destino no tapa el paso: se rodea, no se mata. Reemplaza el cono ancho de 45° que daba por "muro" a creeps que sólo estaban cerca del camino.
        private constant real CORRIDOR_LOOK     = 350.0  // largo del segmento hacia casa que debe estar despejado para SOLTAR un encierro de huida (CHANGE C)
        private constant real CORRIDOR_RECHECK  = 0.30   // s entre chequeos de "camino libre" durante un breakout activo de huida (el escaneo es O(n)+muestras de terreno; no hace falta cada tick de 0.10s)
        // Salidas del breakout
        private constant real FREE_DIST         = 120.0  // ya me moví => salí del cerco
        private constant real BREAKOUT_TIMEOUT  = 2.50   // [SIN USO] antes cerraba el breakout a los 2.5s; ahora el modo se compromete a matar a la víctima (ver Try). Se conserva para la futura evaluación post-kill (C2/C3).
        // Contador de reincidencias y berserker
        private constant real CYCLE_WINDOW      = 2.00   // s desde el último breakout para encadenar
        private constant real BERSERK_FREE_DIST = 600.0  // me alejé tanto del foco => salgo de berserker
        private constant real BERSERK_HP_EXIT   = 0.70   // recuperé HP > 70% => salgo de berserker
        // Escaneos auxiliares
        private constant real ALLY_SCAN_RADIUS  = 1200.0 // radio para tally de presión aliada
        // Espejo del veto de profundidad de caza (ENEMY_DEPTH_SLACK en
        // IA_State_Laning.j). IABreakout compila ANTES que IAStateLaning y no
        // puede leer su constante privada: mantener ambos valores SINCRONIZADOS.
        private constant real DEEP_VETO_SLACK   = 200.0
        // Anti-CC: si el bot está bajo pausa, no disparamos breakout
        // (se mira con IsUnitPaused)

        // CESIÓN DE PASO A ALIADO HUMANO (YIELD)
        private constant real YIELD_DURATION    = 1.20   // s que sigo cediendo tras el último golpe aliado
        private constant real YIELD_STEP        = 200.0  // distancia del paso perpendicular (despeja colisión)
        private constant real YIELD_MAX_DIST    = 350.0  // el aliado debe estar pegado para que tenga sentido
        private constant real YIELD_MOVE_EPS    = 50.0   // me desplacé esto => sigo progresando
        private constant real YIELD_STUCK_TIME  = 0.60   // s intentando apartarme sin desplazarme => atascado
        private constant real YIELD_ARRIVE_DIST = 64.0   // llegué al punto del paso => ya estoy fuera del medio

        // CESIÓN POR HECHIZO DEL HUMANO (MANUAL CAST)
        private constant real MANUAL_CAST_GRACE   = 0.60 // s que la IA sigue cediendo tras terminar/romperse el cast
        private constant real MANUAL_CAST_PENDING = 3.00 // s de protección entre la ORDEN de hechizo (ISSUE) y el arranque real del cast (SPELL_CHANNEL). Cubre giro + caminata a rango y habilidades que NO publican su orden en GetUnitCurrentOrder (p.ej. 'ANcs' Cohetes de Dispersión / 'ANsy' Fábrica de Bolsillo del Hojalatero). Si el cast no arrancó al vencer, se suelta (la orden murió: sin maná, target inválido, etc.).
    endglobals

    // ====================================================
    //  HELPERS PRIVADOS
    // ====================================================

    // Fórmula nativa WC3 de mitigación por armadura.
    private function ArmorReductionMult takes real armor returns real
        if armor >= 0.0 then
            return 1.0 - ((armor * 0.06) / (1.0 + (armor * 0.06)))
        endif
        return 1.0 - (armor * 0.06)
    endfunction

    // Refresca todas las referencias de progreso a la posición/tiempo actuales.
    // 'xRef' guarda ahora la DISTANCIA a casa (no la X): así la métrica de huida
    // combina X+Y y registra avance tanto por el carril (horizontal) como al
    // subir/bajar hacia la fuente dentro de la propia base (vertical).
    private function ResetStuckRef takes LaningBrain brain, unit bot, real x, real y, real now returns nothing
        set brain.lastPosX  = x
        set brain.lastPosY  = y
        set brain.stuckRefTime = now
        set brain.xRef      = IAUtils_GetDistanceUnitXY(bot, IABrainMacro_GetClosestHomeX(bot), IABrainMacro_GetClosestHomeY(bot))
        set brain.xRefTime  = now
    endfunction

    // Cierra el breakout activo y marca el momento (para la ventana de 2s).
    private function CloseBreakout takes LaningBrain brain, real now returns nothing
        set brain.breakoutActive = false
        set brain.breakoutTarget = null
        set brain.lastBreakoutEndTime = now
    endfunction

    private function ExitBerserkInternal takes LaningBrain brain returns nothing
        set brain.berserkActive = false
        set brain.berserkTarget = null
    endfunction

    // Diferencia angular en [-PI, PI].
    private function NormAng takes real a returns real
        loop
            exitwhen a <= 3.14159
            set a = a - 6.28319
        endloop
        loop
            exitwhen a >= -3.14159
            set a = a + 6.28319
        endloop
        return a
    endfunction

    // ¿El bot está bajo CC inmovilizante (pausado)? En ese caso no debemos
    // dispararle breakout — no es que esté atrapado, es que no puede hacer nada.
    private function IsLocked takes unit u returns boolean
        return IsUnitPaused(u)
    endfunction

    // CHANGE A — ¿el creep 'u' es un BLOQUEADOR REAL (anclado) y no uno que va de
    // paso? El despeje sólo debe matar muros que NO se apartarán solos:
    //   - ANCLADO = tiene objetivo físico vivo (está pegándole a alguien): clavado
    //     en el sitio peleando. (Era tu intención original: "el creep está en una
    //     acción, atacando a alguien".)
    //   - o está realmente QUIETO (stop / hold / idle).
    // NO es bloqueador un creep que MARCHA o CIRCULA: orden de movimiento
    // (attack-move/move/smart) SIN objetivo físico => va a pasar solo, hay que
    // dejarlo. Antes se usaba "orden != move", pero los creeps de carril marchan
    // con ATTACK-MOVE (orden "attack"), así que la oleada entera salía como "muro
    // estacionario": el bot la mataba uno por uno y hasta perseguía al creep que
    // sólo esquivaba. Misma lección que el carril pasivo (objetivo físico, no orden).
    private function IsCreepAnchored takes unit u returns boolean
        local integer o = GetUnitCurrentOrder(u)
        local unit pt = IAUtils_GetUnitPhysicalTarget(u)
        if pt != null and not IsUnitType(pt, UNIT_TYPE_DEAD) then
            set pt = null
            return true
        endif
        set pt = null
        return o == 0 or o == OrderId("stop") or o == OrderId("holdposition")
    endfunction

    // ¿El HÉROE enemigo 'u' está en ZONA DE VETO (más allá del frente de asedio
    // por > DEEP_VETO_SLACK con el veto activo)? Cierra el bug BRK-DIVE/BSK-DIVE:
    // el anti-encierro y el berserker ya NO eligen héroes en zona prohibida;
    // creeps y estructuras quedan como única salida del cerco (espejo de
    // tooDeepToHunt en Think). Lee el frente cacheado por Think en la pizarra
    // (dbgSiegeX/dbgVetoActive: nacieron como debug pero ahora son CARGA ÚTIL;
    // en Survival conservan el último valor del laning — el frente se mueve
    // lento, staleness de segundos es aceptable).
    // LIMITACIÓN ASUMIDA: si el ÚNICO bloqueador del cerco es un héroe profundo,
    // el bot no lo ataca y puede quedarse oscilando en la detección — preferible
    // al dive reportado (morir persiguiendo héroes pegados a su fuente).
    private function IsHeroTooDeep takes LaningBrain brain, player botOwner, unit u returns boolean
        local real dp
        if not brain.dbgVetoActive then
            return false
        endif
        if IsPlayerAlly(botOwner, Player(0)) then
            set dp = GetUnitX(u) - brain.dbgSiegeX
        else
            set dp = brain.dbgSiegeX - GetUnitX(u)
        endif
        return dp > DEEP_VETO_SLACK
    endfunction

    // ¿'u' es un héroe-BOT del motor? Lee brain.isBotHero (lo escribe
    // IA_Core.Bot.create al registrar CUALQUIER bot: lobby o takeover).
    // NO usar GetPlayerController == MAP_CONTROL_COMPUTER: el bot por TAKEOVER
    // (voto de leaver, Sistema_Voto.j) conserva al dueño con controller USER
    // (el slot del leaver pasa a LEFT, el controller no cambia) => ese chequeo
    // lo excluía y el gate IA-cancel mataba los casts manuales del humano sobre
    // él (bug Hojalatero 2026-06-11; los bots de lobby sí funcionaban).
    // El pre-filtro IsUnitType(HERO) mantiene barato el camino caliente (corre
    // en CADA orden emitida del mapa) y evita crear brains de unidades no-héroe.
    private function IsBotHero takes unit u returns boolean
        return u != null and IsUnitType(u, UNIT_TYPE_HERO) and IABlackboard_GetLaningBrain(u).isBotHero
    endfunction

    // ====================================================
    //  RESET POR REVIVE (lo llama Bot.update)
    // ====================================================
    // Cuando el héroe muere y revive, hay que limpiar el estado de breakout y
    // berserker; si no, podría revivir directamente en berserker.
    public function ResetOnRevive takes unit hero returns nothing
        local LaningBrain brain = IABlackboard_GetLaningBrain(hero)
        set brain.breakoutActive       = false
        set brain.breakoutTarget       = null
        set brain.breakoutCycle        = 0
        set brain.lastBreakoutEndTime  = 0.0
        set brain.berserkActive        = false
        set brain.berserkTarget        = null
        // Cesión de paso: no resucitar cediendo a un aliado de la vida pasada.
        set brain.yieldUntil           = 0.0
        set brain.yieldBlocker         = null
        set brain.yieldSide            = 0
        set brain.yieldTriedBoth       = false
        // Control manual del humano: no revivir con un cast latcheado/gracia vieja.
        set brain.humanCastLatch        = false
        set brain.humanCastPendingUntil = 0.0
        set brain.humanCastChanneling   = false
        set brain.humanCastGraceUntil   = 0.0
        // Las referencias de progreso quedan stale tras la muerte; las
        // marcamos como "no inicializadas" para que el primer Try() del
        // bot resucitado las refresque a su nueva posición.
        set brain.stuckRefTime = 0.0
        set brain.xRefTime     = 0.0
    endfunction

    // ====================================================
    //  SELECCIÓN DE OBJETIVO EN BERSERKER
    // ====================================================
    // Devuelve héroe enemigo o invocación a atacar, o null si el caller debe
    // caer al flujo normal de fuga (paso 4 del protocolo del usuario).
    //
    // Orden estricto:
    //   1) Mayor presión aliada (héroes aliados atacándolo) entre los que estén
    //      en mi rango de ataque.
    //   2) Si no, héroe enemigo en mi rango con menor golpes-para-matar
    //      (HP_actual / (myDamage * reduccionPorSuArmadura)).
    //   3) Si no hay héroe en mi rango, una invocación en mi rango.
    //   4) Null.
    private function SelectBerserkTarget takes unit botUnit, player botOwner returns unit
        local LaningBrain brain = IABlackboard_GetLaningBrain(botUnit)
        local group g
        local unit u
        local unit allyTgt
        local unit array tallyHero
        local integer array tallyCount
        local integer tallyN = 0
        local integer i
        local boolean found
        local real myRange = IAData_GetHeroAttackRange(botUnit)
        local real myDmg   = IAData_GetHeroEstimatedDamage(botUnit)
        local real enemyArmor
        local real reduction
        local real hits
        local real bestHits = 99999.0
        local unit bestByHits = null
        local unit bestByPressure = null
        local integer bestPressure = 0
        local unit summonPick = null
        local real d
        local real myX = GetUnitX(botUnit)
        local real myY = GetUnitY(botUnit)

        // Pase 1: tally de presión aliada sobre héroes enemigos.
        set g = CreateGroup()
        call GroupEnumUnitsInRange(g, myX, myY, ALLY_SCAN_RADIUS, null)
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            call GroupRemoveUnit(g, u)
            if u != botUnit and not IsUnitType(u, UNIT_TYPE_DEAD) and IsUnitType(u, UNIT_TYPE_HERO) and IsUnitAlly(u, botOwner) then
                set allyTgt = IAUtils_GetUnitPhysicalTarget(u)
                if allyTgt != null and not IsUnitType(allyTgt, UNIT_TYPE_DEAD) and IsUnitType(allyTgt, UNIT_TYPE_HERO) and IsUnitEnemy(allyTgt, botOwner) then
                    set i = 0
                    set found = false
                    loop
                        exitwhen i >= tallyN
                        if tallyHero[i] == allyTgt then
                            set tallyCount[i] = tallyCount[i] + 1
                            set found = true
                            set i = tallyN
                        endif
                        set i = i + 1
                    endloop
                    if not found then
                        set tallyHero[tallyN] = allyTgt
                        set tallyCount[tallyN] = 1
                        set tallyN = tallyN + 1
                    endif
                endif
                set allyTgt = null
            endif
        endloop
        call DestroyGroup(g)
        set g = null

        // Paso 1: entre los del tally, el de mayor count que esté en mi rango.
        // (Excluye héroes en zona de veto de asedio — fix BSK-DIVE.)
        set i = 0
        loop
            exitwhen i >= tallyN
            if tallyCount[i] > bestPressure then
                set d = IAUtils_GetDistanceUnits(botUnit, tallyHero[i])
                if d <= myRange and not IsHeroTooDeep(brain, botOwner, tallyHero[i]) then
                    set bestPressure = tallyCount[i]
                    set bestByPressure = tallyHero[i]
                endif
            endif
            set i = i + 1
        endloop

        // Limpia el array para no dejar referencias colgadas.
        set i = 0
        loop
            exitwhen i >= tallyN
            set tallyHero[i] = null
            set i = i + 1
        endloop

        if bestByPressure != null then
            set u = null
            return bestByPressure
        endif

        // Pasos 2+3+4: escaneo en rango => mejor hits-to-kill (héroe) y backup invocación.
        set g = CreateGroup()
        call GroupEnumUnitsInRange(g, myX, myY, myRange + 50.0, null)
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            call GroupRemoveUnit(g, u)
            if u != botUnit and not IsUnitType(u, UNIT_TYPE_DEAD) and IsUnitEnemy(u, botOwner) then
                if IsUnitType(u, UNIT_TYPE_HERO) then
                    // Fix BSK-DIVE: nunca comprometerse con un héroe en zona de veto.
                    if not IsHeroTooDeep(brain, botOwner, u) then
                        set enemyArmor = IAData_GetHeroEstimatedArmor(u)
                        set reduction = ArmorReductionMult(enemyArmor)
                        if myDmg * reduction > 0.01 then
                            set hits = GetUnitState(u, UNIT_STATE_LIFE) / (myDmg * reduction)
                            if hits < bestHits then
                                set bestHits = hits
                                set bestByHits = u
                            endif
                        endif
                    endif
                elseif IsUnitType(u, UNIT_TYPE_SUMMONED) and summonPick == null then
                    set summonPick = u
                endif
            endif
        endloop
        call DestroyGroup(g)
        set g = null
        set u = null

        if bestByHits != null then
            set summonPick = null
            return bestByHits
        endif
        return summonPick
    endfunction

    // ====================================================
    //  EJECUCIÓN DE BERSERKER (un frame)
    // ====================================================
    // Devuelve true si emitió la orden de este frame (caller hace return).
    // Devuelve false en dos casos:
    //   - acabamos de salir del modo berserker (alguna condición de salida),
    //   - el modo sigue activo pero no encontró héroe/invocación en rango
    //     => caller debe seguir con TryPathClear / Try (creep-escape normal).
    public function ExecuteBerserk takes unit botUnit, player botOwner returns boolean
        local LaningBrain brain = IABlackboard_GetLaningBrain(botUnit)
        local unit target
        local real botHP
        local real botMaxHP

        if not brain.berserkActive then
            return false
        endif

        // Salida (a): recuperé HP > 70%.
        set botHP    = GetUnitState(botUnit, UNIT_STATE_LIFE)
        set botMaxHP = GetUnitState(botUnit, UNIT_STATE_MAX_LIFE)
        if botMaxHP > 0.01 and (botHP / botMaxHP) > BERSERK_HP_EXIT then
            call ExitBerserkInternal(brain)
            return false
        endif

        // Salida (b): me alejé del foco.
        if IAUtils_GetDistanceUnitXY(botUnit, brain.berserkEntryX, brain.berserkEntryY) >= BERSERK_FREE_DIST then
            call ExitBerserkInternal(brain)
            return false
        endif

        // Salida (c): el target anterior murió.
        if brain.berserkTarget != null and IsUnitType(brain.berserkTarget, UNIT_TYPE_DEAD) then
            call ExitBerserkInternal(brain)
            return false
        endif

        // Selección de target por el protocolo.
        set target = SelectBerserkTarget(botUnit, botOwner)
        if target == null then
            // No hay héroe ni invocación en rango: el caller hará escape normal.
            // Mantenemos el modo activo (no se sale por esto).
            set brain.berserkTarget = null
            return false
        endif

        // Anti-spam: solo re-emitir si cambió la víctima o la orden.
        if GetUnitCurrentOrder(botUnit) != OrderId("attack") or target != brain.berserkTarget then
            call IssueTargetOrder(botUnit, "attack", target)
        endif
        set brain.berserkTarget = target
        set target = null
        return true
    endfunction

    // ====================================================
    //  CESIÓN DE PASO A ALIADO HUMANO (YIELD)
    // ====================================================
    // PROBLEMA: un bot aliado, atacando a un héroe, tapa físicamente la única
    // salida de un jugador humano. El humano fuerza ataque (tecla A) sobre su
    // propio bot para pedirle "muévete". Como atacar a un aliado SIEMPRE es
    // deliberado (requiere forzarlo), es una señal inequívoca.
    //
    // TRUCO DE DIRECCIÓN: no hace falta leer a dónde quiere ir el humano. El
    // humano empuja contra el bot, así que la dirección de empuje ≈ (aliado->bot).
    // Si el bot retrocede en esa línea sigue estorbando ("baile de pasillo"); si
    // da un paso PERPENDICULAR, vacía el corredor y el humano fluye. El pathing
    // propio del humano hace el resto (incluido rodear muros).
    //
    // CASCADA: si el bot intenta apartarse a ambos lados y no logra desplazarse,
    // es que él también está atrapado => devuelve false y deja que la lógica
    // normal (y su propio breakout) actúe.

    // Handler de EVENT_PLAYER_UNIT_ATTACKED: marca la cesión cuando un JUGADOR
    // HUMANO ALIADO golpea a un bot. (Auto-adquisición nunca apunta a aliados,
    // así que un humano pegándole a un bot aliado es siempre fuego amigo forzado.)
    private function OnAllyAttack takes nothing returns nothing
        local unit victim   = GetTriggerUnit()
        local unit attacker = GetAttacker()
        local player vp
        local LaningBrain brain
        if victim == null or attacker == null or attacker == victim then
            set victim = null
            set attacker = null
            return
        endif
        // La víctima debe ser un bot (identidad de registro, NO controller:
        // el bot por takeover conserva controller USER — ver IsBotHero).
        set vp = GetOwningPlayer(victim)
        if not IsBotHero(victim) then
            set victim = null
            set attacker = null
            return
        endif
        // El atacante debe ser un JUGADOR HUMANO ALIADO y CONECTADO (slot
        // PLAYING): un bot takeover también es controller USER, y sus ataques
        // no deben tratarse como "humano pidiendo paso".
        if GetPlayerController(GetOwningPlayer(attacker)) != MAP_CONTROL_USER or GetPlayerSlotState(GetOwningPlayer(attacker)) != PLAYER_SLOT_STATE_PLAYING or not IsUnitAlly(attacker, vp) then
            set victim = null
            set attacker = null
            return
        endif
        set brain = IABlackboard_GetLaningBrain(victim)
        set brain.yieldUntil   = IAUtils_GetGameTime() + YIELD_DURATION
        set brain.yieldBlocker = attacker
        set victim = null
        set attacker = null
    endfunction

    // Registra el detector. Lo llama IACore_StartEngine.
    public function InitYield takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer i = 0
        loop
            exitwhen i > 15
            call TriggerRegisterPlayerUnitEvent(t, Player(i), EVENT_PLAYER_UNIT_ATTACKED, null)
            set i = i + 1
        endloop
        call TriggerAddAction(t, function OnAllyAttack)
        set t = null
    endfunction

    // Un frame de cesión. Devuelve true si manejó el frame (emitió el paso al
    // lado, o ya está apartado): el caller (Bot.update) hace return y SALTEA la
    // FSM. Devuelve false si no hay cesión activa o si el bot no puede apartarse
    // (atrapado) => el caller sigue con su lógica normal/breakout.
    public function TryYield takes unit botUnit, player botOwner returns boolean
        local LaningBrain brain = IABlackboard_GetLaningBrain(botUnit)
        local real now = IAUtils_GetGameTime()
        local unit blocker
        local real bx
        local real by
        local real ax
        local real ay
        local real ang
        local real perpAng
        local real disp
        local real homeX
        local real homeY
        local real s1X
        local real s1Y
        local real s2X
        local real s2Y
        local boolean s1ok
        local boolean s2ok

        // ¿Cesión activa?
        if now >= brain.yieldUntil then
            // Expiró: limpiar el canal para que la próxima cesión elija lado de cero.
            if brain.yieldBlocker != null or brain.yieldSide != 0 then
                set brain.yieldBlocker   = null
                set brain.yieldSide      = 0
                set brain.yieldTriedBoth = false
            endif
            return false
        endif

        set blocker = brain.yieldBlocker
        // Validar bloqueador: vivo, válido y todavía pegado a mí.
        if blocker == null or IsUnitType(blocker, UNIT_TYPE_DEAD) or GetUnitTypeId(blocker) == 0 then
            return false
        endif
        if IAUtils_GetDistanceUnits(botUnit, blocker) > YIELD_MAX_DIST then
            set blocker = null
            return false
        endif
        // Bajo CC no puedo apartarme: que la lógica normal decida.
        if IsLocked(botUnit) then
            set blocker = null
            return false
        endif

        set bx = GetUnitX(botUnit)
        set by = GetUnitY(botUnit)
        set ax = GetUnitX(blocker)
        set ay = GetUnitY(blocker)

        // Dirección de empuje ≈ (aliado -> bot). Perpendicular = +90°.
        set ang = Atan2(by - ay, bx - ax)
        set perpAng = ang + 1.5708

        // Ya me aparté lo suficiente: me quedo quieto fuera del medio hasta que
        // deje de golpearme (yieldUntil expira) o tenga que reintentar.
        if brain.yieldSide != 0 and IAUtils_GetDistanceUnitXY(botUnit, brain.yieldDestX, brain.yieldDestY) < YIELD_ARRIVE_DIST then
            set blocker = null
            return true
        endif

        // Elegir lado la primera vez: preferir el transitable; si ambos lo son,
        // el más cercano a casa (pierdo menos terreno).
        if brain.yieldSide == 0 then
            set s1X = bx + YIELD_STEP * Cos(perpAng)
            set s1Y = by + YIELD_STEP * Sin(perpAng)
            set s2X = bx - YIELD_STEP * Cos(perpAng)
            set s2Y = by - YIELD_STEP * Sin(perpAng)
            // IsTerrainPathable devuelve TRUE cuando está BLOQUEADO (contraintuitivo).
            set s1ok = not IsTerrainPathable(s1X, s1Y, PATHING_TYPE_WALKABILITY)
            set s2ok = not IsTerrainPathable(s2X, s2Y, PATHING_TYPE_WALKABILITY)
            set homeX = IABrainMacro_GetClosestHomeX(botUnit)
            set homeY = IABrainMacro_GetClosestHomeY(botUnit)
            if s1ok and s2ok then
                if (s1X-homeX)*(s1X-homeX)+(s1Y-homeY)*(s1Y-homeY) <= (s2X-homeX)*(s2X-homeX)+(s2Y-homeY)*(s2Y-homeY) then
                    set brain.yieldSide  = 1
                    set brain.yieldDestX = s1X
                    set brain.yieldDestY = s1Y
                else
                    set brain.yieldSide  = -1
                    set brain.yieldDestX = s2X
                    set brain.yieldDestY = s2Y
                endif
                set brain.yieldTriedBoth = false
            elseif s1ok then
                set brain.yieldSide      = 1
                set brain.yieldDestX     = s1X
                set brain.yieldDestY     = s1Y
                set brain.yieldTriedBoth = true   // el otro está bloqueado, no hay alternativa
            elseif s2ok then
                set brain.yieldSide      = -1
                set brain.yieldDestX     = s2X
                set brain.yieldDestY     = s2Y
                set brain.yieldTriedBoth = true
            else
                // Ningún lado transitable: no puedo apartarme => breakout/normal.
                set blocker = null
                return false
            endif
            set brain.yieldRefX    = bx
            set brain.yieldRefY    = by
            set brain.yieldRefTime = now
        else
            // Ya estoy en pleno paso: ¿me estoy desplazando?
            set disp = SquareRoot((bx-brain.yieldRefX)*(bx-brain.yieldRefX) + (by-brain.yieldRefY)*(by-brain.yieldRefY))
            if disp >= YIELD_MOVE_EPS then
                set brain.yieldRefX    = bx
                set brain.yieldRefY    = by
                set brain.yieldRefTime = now
            elseif (now - brain.yieldRefTime) >= YIELD_STUCK_TIME then
                if brain.yieldTriedBoth then
                    // Probé ambos lados y no me desplazo: yo también estoy atrapado.
                    set blocker = null
                    return false
                endif
                // Probar el lado opuesto (recalculado desde la posición actual).
                set brain.yieldSide      = -brain.yieldSide
                set brain.yieldTriedBoth = true
                set brain.yieldDestX     = bx + I2R(brain.yieldSide) * YIELD_STEP * Cos(perpAng)
                set brain.yieldDestY     = by + I2R(brain.yieldSide) * YIELD_STEP * Sin(perpAng)
                set brain.yieldRefX      = bx
                set brain.yieldRefY      = by
                set brain.yieldRefTime   = now
            endif
        endif

        // Emitir el paso (anti-spam: solo si no voy ya en "move").
        if GetUnitCurrentOrder(botUnit) != OrderId("move") then
            call IssuePointOrder(botUnit, "move", brain.yieldDestX, brain.yieldDestY)
        endif

        set blocker = null
        return true
    endfunction

    // ====================================================
    //  CONTROL MANUAL DEL HUMANO: CEDER SUS CASTS / CANCELAR AUTO-CASTS DEL MOTOR
    // ====================================================
    // El bot comparte el control a sus aliados humanos. Eso genera DOS efectos a
    // manejar, ambos resueltos aquí:
    //
    //  (1) HECHIZO DEL HUMANO: cuando un humano ordena lanzar/canalizar una
    //      habilidad del bot, la IA (que corre cada 0.10s y reemite attack/move)
    //      la cancelaría o lo sacaría de la canalización. => Le CEDEMOS el frame.
    //
    //  (2) AUTO-CAST DEL MOTOR: el jugador COMPUTADORA tiene IA de unidad propia
    //      que lanza sola las habilidades aprendidas (como un creep). NO lo
    //      queremos (el bot no debe decidir hechizos por su cuenta). => Lo
    //      CANCELAMOS con "stop".
    //
    // CÓMO DISTINGUIR (1) de (2) sin saber qué habilidades tiene cada héroe:
    //   - La IA propia SOLO emite { attack, move, smart, stop, holdposition }.
    //     Cualquier OTRA orden emitida/actual en el héroe es un HECHIZO (IsAIOrder=false).
    //   - Toda orden de hechizo arma el LATCH (humanCastLatch). CONFIRMADO EN
    //     JUEGO: el auto-cast del motor TAMBIÉN dispara EVENT_PLAYER_UNIT_ISSUED_*
    //     y GetTriggerPlayer == dueño en TODOS los casos, así que el latch no
    //     distingue al emisor; se latchea SIEMPRE (proteger el cast humano vale
    //     más que dejar pasar algún auto-cast del motor).
    //
    // BUG "habilidades ignoradas" (Hojalatero 2026-06-11) — CAUSA CONFIRMADA:
    //   ocurría SOLO en bots TAKEOVER (héroe de leaver tomado por la IA tras el
    //   voto, Sistema_Voto.j). El leaver conserva controller USER, así que el
    //   viejo guard "controller == COMPUTER" del detector de órdenes nunca
    //   armaba el latch => el gate caía en IA-cancel y mataba el cast con
    //   "stop" cada vez ('ANcs' Cohetes / 'ANsy' Fábrica nunca salían; Robo
    //   Goblin "funcionaba" solo porque la metamorfosis se consuma antes del
    //   stop). En bots de lobby (slot Computer real) todo funcionaba — lo
    //   confirmó el test del usuario. FIX: IsBotHero lee brain.isBotHero
    //   (identidad de registro escrita por Bot.create), NO el controller.
    //
    // POR QUÉ ADEMÁS EVENTOS DE HECHIZO Y NO SOLO GetUnitCurrentOrder:
    //   defensa en profundidad agregada en el mismo fix: nada garantiza que
    //   GetUnitCurrentOrder publique la orden de TODA habilidad en todo momento
    //   (giro, caminata a rango, firmas por-habilidad). La verdad del motor son
    //   los EVENTOS de hechizo, que disparan para CUALQUIER habilidad:
    //
    //   SEÑALES DE PROTECCIÓN (orden de prioridad en TryManualCastYield):
    //     a) humanCastChanneling — entre SPELL_CHANNEL y SPELL_ENDCAST: el cast
    //        corre de verdad. Ceder siempre.
    //     b) Orden actual fuera del vocabulario IA — vía clásica (habilidades que
    //        sí publican su orden; cubre también la caminata LARGA a rango).
    //        Con latch => ceder; sin latch => cancelar con "stop" (auto-cast).
    //     c) humanCastPendingUntil — ventana ISSUE->CHANNEL (MANUAL_CAST_PENDING):
    //        protege giro + caminata corta + habilidades del caso 'ANcs'. Si el
    //        cast no arrancó al vencer, la orden murió (sin maná, target
    //        inválido...) y se suelta — con aviso [MCAST] en chat.
    //     d) humanCastGraceUntil — colchón post-cast (lo arma el ENDCAST y cada
    //        frame cedido por (b)): no robarle el frame a la animación de remate.
    //
    // AUTOCAST tipo orbe (p.ej. Flechas de Hielo): se aplica DENTRO del ataque y
    // NO cambia GetUnitCurrentOrder (sigue en "attack"), así que ni se cede ni se
    // cancela: el héroe sigue atacando normal (confirmado en juego).
    //
    // ANTI-FALSO-ENCIERRO: en cada frame cedido reseteamos breakout/berserker y
    // las referencias de progreso (el héroe estuvo quieto sin correr la FSM; si no,
    // el primer Try() al retomar vería "no me moví en X s" => falso "Encerrado").

    // ¿La orden 'o' pertenece al vocabulario que emite la IA (o es idle)?
    private function IsAIOrder takes integer o returns boolean
        return o == 0 or o == OrderId("attack") or o == OrderId("move") or o == OrderId("smart") or o == OrderId("stop") or o == OrderId("holdposition")
    endfunction

    // El humano maneja al héroe: soltamos TODO el estado anti-encierro (para no
    // arrastrar un falso "Encerrado"/Berserker al retomar) y refrescamos las
    // referencias de progreso a la posición/tiempo actuales.
    private function NotifyManualControlInternal takes LaningBrain brain, unit hero, real now returns nothing
        set brain.breakoutActive      = false
        set brain.breakoutTarget      = null
        set brain.breakoutCycle       = 0
        set brain.lastBreakoutEndTime = 0.0
        set brain.berserkActive       = false
        set brain.berserkTarget       = null
        call ResetStuckRef(brain, hero, GetUnitX(hero), GetUnitY(hero), now)
    endfunction

    // Handler de EVENT_PLAYER_UNIT_ISSUED_*_ORDER sobre un héroe-bot.
    // (El guard IsBotHero vive en la sección de helpers, arriba: lee la
    // identidad de registro de la pizarra, NO el controller — ver su comentario.)
    //
    //  - Orden de HECHIZO => latch + ventana pendiente (ISSUE->CHANNEL). No
    //    intentamos atribuir el emisor (GetTriggerPlayer == dueño SIEMPRE,
    //    refutado en juego): se latchea todo hechizo ordenado.
    //  - Orden del VOCABULARIO IA mientras protegíamos un cast => durante la
    //    cesión la FSM no emite nada, así que vino de afuera: el humano movió/
    //    paró al héroe a mano (canceló su propio cast) o algún otro sistema del
    //    mapa ordenó al héroe — la línea [MCAST] lo delata. Soltamos la
    //    protección ya mismo; si había canalización en curso, el motor la rompe
    //    con esa misma orden y su ENDCAST llega igual (no hará nada).
    private function OnBotSpellOrder takes nothing returns nothing
        local unit u = GetTriggerUnit()
        local integer o = GetIssuedOrderId()
        local LaningBrain brain
        if not IsBotHero(u) then
            set u = null
            return
        endif
        set brain = IABlackboard_GetLaningBrain(u)
        if not IsAIOrder(o) then
            set brain.humanCastLatch        = true
            set brain.humanCastPendingUntil = IAUtils_GetGameTime() + MANUAL_CAST_PENDING
            // Una orden de hechizo nueva reemplaza cualquier canalización previa
            // (el CHANNEL de la nueva la volverá a marcar).
            set brain.humanCastChanneling   = false
        elseif brain.humanCastLatch or brain.humanCastChanneling then
            set brain.humanCastLatch        = false
            set brain.humanCastPendingUntil = 0.0
            set brain.humanCastChanneling   = false
        endif
        set u = null
    endfunction

    // EVENT_PLAYER_UNIT_SPELL_CHANNEL: el cast ARRANCÓ de verdad. Dispara para
    // TODA habilidad, publique o no su orden en GetUnitCurrentOrder (esta es la
    // señal que faltaba para Cohetes de Dispersión / Fábrica de Bolsillo). Solo
    // lo marcamos si venía de una orden latcheada: así el IA-cancel de hechizos
    // sin ISSUE previo conserva su semántica.
    private function OnBotSpellChannel takes nothing returns nothing
        local unit u = GetTriggerUnit()
        local LaningBrain brain
        if not IsBotHero(u) then
            set u = null
            return
        endif
        set brain = IABlackboard_GetLaningBrain(u)
        if brain.humanCastLatch then
            set brain.humanCastChanneling   = true
            set brain.humanCastPendingUntil = 0.0 // la ventana ya cumplió su trabajo
        endif
        set u = null
    endfunction

    // EVENT_PLAYER_UNIT_SPELL_ENDCAST: el cast terminó (completado O roto por
    // stun/muerte/cancelación). Cerramos toda la protección y dejamos el colchón
    // post-cast para la animación de remate.
    private function OnBotSpellEndcast takes nothing returns nothing
        local unit u = GetTriggerUnit()
        local LaningBrain brain
        if not IsBotHero(u) then
            set u = null
            return
        endif
        set brain = IABlackboard_GetLaningBrain(u)
        if brain.humanCastChanneling or brain.humanCastLatch then
            set brain.humanCastChanneling   = false
            set brain.humanCastLatch        = false
            set brain.humanCastPendingUntil = 0.0
            set brain.humanCastGraceUntil   = IAUtils_GetGameTime() + MANUAL_CAST_GRACE
        endif
        set u = null
    endfunction

    // Registra el detector de órdenes + los eventos de hechizo. Lo llama StartEngine.
    public function InitManualControl takes nothing returns nothing
        local trigger t  = CreateTrigger()
        local trigger tc = CreateTrigger()
        local trigger te = CreateTrigger()
        local integer i = 0
        loop
            exitwhen i > 15
            call TriggerRegisterPlayerUnitEvent(t,  Player(i), EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, null)
            call TriggerRegisterPlayerUnitEvent(t,  Player(i), EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, null)
            call TriggerRegisterPlayerUnitEvent(t,  Player(i), EVENT_PLAYER_UNIT_ISSUED_ORDER, null)
            call TriggerRegisterPlayerUnitEvent(tc, Player(i), EVENT_PLAYER_UNIT_SPELL_CHANNEL, null)
            call TriggerRegisterPlayerUnitEvent(te, Player(i), EVENT_PLAYER_UNIT_SPELL_ENDCAST, null)
            set i = i + 1
        endloop
        call TriggerAddAction(t,  function OnBotSpellOrder)
        call TriggerAddAction(tc, function OnBotSpellChannel)
        call TriggerAddAction(te, function OnBotSpellEndcast)
        set t  = null
        set tc = null
        set te = null
    endfunction

    // Devuelve true si cedió el frame (el caller hace return y saltea la FSM).
    public function TryManualCastYield takes unit hero returns boolean
        local LaningBrain brain = IABlackboard_GetLaningBrain(hero)
        local real now = IAUtils_GetGameTime()
        local integer o = GetUnitCurrentOrder(hero)

        // (a) CAST EN CURSO confirmado por eventos (CHANNEL sin ENDCAST aún):
        //     verdad del motor, independiente de qué publique GetUnitCurrentOrder
        //     para esta habilidad. Ceder siempre.
        if brain.humanCastChanneling then
            call NotifyManualControlInternal(brain, hero, now)
            return true
        endif

        // (b) Vía clásica: la orden actual del héroe es un HECHIZO publicado.
        if not IsAIOrder(o) then
            if brain.humanCastLatch then
                // Cast ordenado (humano): cederle el frame.
                set brain.humanCastGraceUntil = now + MANUAL_CAST_GRACE
                call NotifyManualControlInternal(brain, hero, now)
                return true
            endif
            // Hechizo actual SIN orden emitida previa: cancelar con "stop".
            call IssueImmediateOrder(hero, "stop")
            return true
        endif

        // (c) HECHIZO ORDENADO QUE AÚN NO ARRANCA (ventana ISSUE->CHANNEL): la
        //     orden actual se lee como vocabulario IA porque esta habilidad no la
        //     publica (o el héroe está girando / caminando a rango). Sin esta
        //     ventana, aquí se soltaba el latch y la FSM pisaba el cast antes de
        //     arrancar (bug Cohetes de Dispersión / Fábrica de Bolsillo).
        if brain.humanCastLatch and now < brain.humanCastPendingUntil then
            call NotifyManualControlInternal(brain, hero, now)
            return true
        endif

        // Nada en curso ni pendiente.
        set brain.humanCastLatch        = false
        set brain.humanCastPendingUntil = 0.0
        if now < brain.humanCastGraceUntil then
            call NotifyManualControlInternal(brain, hero, now)
            return true
        endif
        return false
    endfunction

    // ====================================================
    //  CAPA 1 — DESPEJE EN RUTA (oportunista, mientras huye)
    // ====================================================
    // Solo se llama cuando isRetreating = true. Busca un creep que TAPE de verdad
    // el corredor recto hacia casa (CHANGE B: |perp| <= CORRIDOR_HALF, no un cono
    // ancho) y que esté ANCLADO (CHANGE A: con objetivo físico o quieto, NO por la
    // orden — los creeps marchan con attack-move). Si lo puede matar en <= 2 golpes,
    // lo ataca de paso.
    //   - Si el creep MARCHA/circula (sin objetivo físico), lo dejamos pasar: se
    //     aparta solo (esto evita la matanza serial de la oleada y perseguir al que
    //     esquiva).
    //   - Si está en el camino pero tomaría >2 golpes, NO lo atacamos: rodeamos
    //     (caller emitirá move). El forzar igualmente queda a cargo de Try() tras 4s.
    // NUNCA toca héroes (de ningún bando).
    public function TryPathClear takes unit botUnit, player botOwner returns boolean
        local LaningBrain brain = IABlackboard_GetLaningBrain(botUnit)
        local real botX = GetUnitX(botUnit)
        local real botY = GetUnitY(botUnit)
        local real homeX = IABrainMacro_GetClosestHomeX(botUnit)
        local real homeY = IABrainMacro_GetClosestHomeY(botUnit)
        local real homeAng = Atan2(homeY - botY, homeX - botX)
        local real homeDirX = Cos(homeAng)
        local real homeDirY = Sin(homeAng)
        local group g
        local unit u
        local unit best = null
        local real bestHits = 99999.0
        local real myDmg = IAData_GetHeroEstimatedDamage(botUnit)
        local real cux
        local real cuy
        local real along
        local real perp
        local real hits

        if IsLocked(botUnit) then
            return false
        endif
        if myDmg < 0.01 then
            return false
        endif

        set g = CreateGroup()
        call GroupEnumUnitsInRange(g, botX, botY, PATH_CONE_RADIUS, null)
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            call GroupRemoveUnit(g, u)
            if u != botUnit and not IsUnitType(u, UNIT_TYPE_DEAD) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_HERO) then
                set cux = GetUnitX(u)
                set cuy = GetUnitY(u)
                // CHANGE B — test de CORREDOR: el creep debe TAPAR de verdad el
                // paso a casa, no sólo estar "cerca". Proyección sobre la línea
                // recta bot->casa: por delante (along>0) y dentro de medio ancho
                // de pasillo (|perp| <= CORRIDOR_HALF). Reemplaza el cono de 45°
                // que daba por muro a creeps desviados con espacio de sobra.
                set along = (cux - botX) * homeDirX + (cuy - botY) * homeDirY
                if along > 0.0 and along <= PATH_CONE_RADIUS then
                    set perp = (cux - botX) * homeDirY - (cuy - botY) * homeDirX
                    if perp < 0.0 then
                        set perp = -perp
                    endif
                    // CHANGE A — anclado (objetivo físico o quieto), no por la orden.
                    if perp <= CORRIDOR_HALF and IsCreepAnchored(u) then
                        set hits = GetUnitState(u, UNIT_STATE_LIFE) / myDmg
                        if hits <= MAX_HITS_INLINE and hits < bestHits then
                            set bestHits = hits
                            set best = u
                        endif
                    endif
                endif
            endif
        endloop
        call DestroyGroup(g)
        set g = null

        if best == null then
            set u = null
            return false
        endif

        // Atacar de paso (sin tocar el contador de reincidencias: esto NO es un
        // "encierro real", es un blocker barato que se mata en menos de 1 segundo).
        if GetUnitCurrentOrder(botUnit) != OrderId("attack") or IAUtils_GetUnitPhysicalTarget(botUnit) != best then
            call IssueTargetOrder(botUnit, "attack", best)
        endif

        set u = null
        set best = null
        return true
    endfunction

    // ====================================================
    //  DESPEJE EN PERSECUCIÓN (melee, oportunista)
    // ====================================================
    // Cuando el SISTEMA DE PUNTAJE (Think) ya decidió perseguir un HÉROE enemigo
    // que salió de rango, un melee debe rodear creeps para hacer contacto. Si hay
    // un creep estacionario en el cono hacia el HÉROE PERSEGUIDO y lo mata en <=2
    // golpes, lo derriba de paso para abrir el camino. Si tomaría más, NO fuerza:
    // devuelve false y el caller deja que el MOTOR rodee solo (la FSM "fuera de
    // rango" emite attack al héroe y WC3 navega).
    //
    // Diferencias con TryPathClear (huida): cono hacia el TARGET (no hacia casa) y
    // umbral 2 golpes (perseguir es opcional, no malgastar golpes en un creep).
    // Igual que la Capa 1: oportunista, NUNCA toca héroes ni el contador de
    // reincidencias, jamás dispara berserker. No es un encierro: es ejecución de
    // una persecución ya decidida.
    public function TryChaseClear takes unit botUnit, player botOwner, unit chaseTarget returns boolean
        local real botX = GetUnitX(botUnit)
        local real botY = GetUnitY(botUnit)
        local real tgtAng = Atan2(GetUnitY(chaseTarget) - botY, GetUnitX(chaseTarget) - botX)
        local real tgtDirX = Cos(tgtAng)
        local real tgtDirY = Sin(tgtAng)
        local group g
        local unit u
        local unit best = null
        local real bestHits = 99999.0
        local real myDmg = IAData_GetHeroEstimatedDamage(botUnit)
        local real cux
        local real cuy
        local real along
        local real perp
        local real hits

        if IsLocked(botUnit) then
            return false
        endif
        if myDmg < 0.01 then
            return false
        endif

        set g = CreateGroup()
        call GroupEnumUnitsInRange(g, botX, botY, PATH_CONE_RADIUS, null)
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            call GroupRemoveUnit(g, u)
            if u != botUnit and u != chaseTarget and not IsUnitType(u, UNIT_TYPE_DEAD) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_HERO) then
                set cux = GetUnitX(u)
                set cuy = GetUnitY(u)
                // CHANGE B — corredor hacia el HÉROE perseguido (no hacia casa):
                // sólo despeja creeps que tapan de verdad la línea de contacto.
                set along = (cux - botX) * tgtDirX + (cuy - botY) * tgtDirY
                if along > 0.0 and along <= PATH_CONE_RADIUS then
                    set perp = (cux - botX) * tgtDirY - (cuy - botY) * tgtDirX
                    if perp < 0.0 then
                        set perp = -perp
                    endif
                    // CHANGE A — anclado (objetivo físico o quieto), no por la orden.
                    if perp <= CORRIDOR_HALF and IsCreepAnchored(u) then
                        set hits = GetUnitState(u, UNIT_STATE_LIFE) / myDmg
                        if hits <= MAX_HITS_CHASE and hits < bestHits then
                            set bestHits = hits
                            set best = u
                        endif
                    endif
                endif
            endif
        endloop
        call DestroyGroup(g)
        set g = null

        if best == null then
            set u = null
            return false
        endif

        if GetUnitCurrentOrder(botUnit) != OrderId("attack") or IAUtils_GetUnitPhysicalTarget(botUnit) != best then
            call IssueTargetOrder(botUnit, "attack", best)
        endif

        set u = null
        set best = null
        return true
    endfunction

    // ====================================================
    //  CHANGE C — ¿EL CORREDOR A CASA SE ABRIÓ? (re-evaluación del encierro)
    // ====================================================
    // EVIDENCIA POSITIVA de salida para soltar un breakout de huida ACTIVO cuyo
    // bloqueador ya se apartó, SIN esperar a matarlo ni a un timeout. Mira el
    // segmento recto bot->casa (largo CORRIDOR_LOOK, medio ancho CORRIDOR_HALF) y
    // lo declara libre si NO hay:
    //   - estructura (tienda secreta / torre): muro permanente;
    //   - unidad ANCLADA (IsCreepAnchored: peleando o quieta): no se aparta sola;
    //   - terreno intransitable en las muestras del segmento.
    // Un creep que MARCHA/circula NO cuenta (pasará): por eso soltar es seguro.
    // Si la evidencia fuese falsa (el motor igual no puede pasar en diagonal), la
    // re-detección en cadena (X_STUCK_TIME_CHAIN, 1.9s) re-dispara el breakout:
    // costo acotado y auto-corregible. NO toca el berserker (su caller lo excluye).
    private function IsCorridorClearToHome takes unit botUnit returns boolean
        local real botX  = GetUnitX(botUnit)
        local real botY  = GetUnitY(botUnit)
        local real homeX = IABrainMacro_GetClosestHomeX(botUnit)
        local real homeY = IABrainMacro_GetClosestHomeY(botUnit)
        local real ang   = Atan2(homeY - botY, homeX - botX)
        local real dirX  = Cos(ang)
        local real dirY  = Sin(ang)
        local real distHome = SquareRoot((homeX-botX)*(homeX-botX) + (homeY-botY)*(homeY-botY))
        local real look  = CORRIDOR_LOOK
        local real cx
        local real cy
        local real along
        local real perp
        local real t
        local integer i
        local real midX
        local real midY
        local real scanR
        local group g
        local unit u
        local boolean blocked = false

        // No exijas corredor más allá de la propia casa (si ya casi llegué, no
        // hay encierro que romper).
        if look > distHome then
            set look = distHome
        endif
        if look < 1.0 then
            return true
        endif

        // (1) Muestras de terreno en el centro del corredor (IsTerrainPathable
        //     devuelve TRUE cuando está BLOQUEADO — contraintuitivo).
        set i = 1
        loop
            exitwhen i > 4
            set t  = look * (I2R(i) / 4.0)
            set cx = botX + dirX * t
            set cy = botY + dirY * t
            if IsTerrainPathable(cx, cy, PATHING_TYPE_WALKABILITY) then
                return false
            endif
            set i = i + 1
        endloop

        // (2) Muros persistentes (estructura o unidad anclada) dentro del corredor.
        set midX  = botX + dirX * (look * 0.5)
        set midY  = botY + dirY * (look * 0.5)
        set scanR = look * 0.5 + CORRIDOR_HALF + 64.0
        set g = CreateGroup()
        call GroupEnumUnitsInRange(g, midX, midY, scanR, null)
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            call GroupRemoveUnit(g, u)
            if u != botUnit and not IsUnitType(u, UNIT_TYPE_DEAD) then
                set cx = GetUnitX(u)
                set cy = GetUnitY(u)
                set along = (cx - botX) * dirX + (cy - botY) * dirY
                if along > 0.0 and along <= look then
                    set perp = (cx - botX) * dirY - (cy - botY) * dirX
                    if perp < 0.0 then
                        set perp = -perp
                    endif
                    if perp <= CORRIDOR_HALF then
                        if IsUnitType(u, UNIT_TYPE_STRUCTURE) or IsCreepAnchored(u) then
                            set blocked = true
                        endif
                    endif
                endif
            endif
        endloop
        call DestroyGroup(g)
        set g = null
        set u = null
        return not blocked
    endfunction

    // ====================================================
    //  CAPA 2 — ENCIERRO REAL (detección + ring breakout + contador)
    // ====================================================
    // Métrica de estancamiento:
    //   - isRetreating: acercamiento a casa en línea recta (X+Y), ventana X_STUCK_TIME (4s).
    //   - !isRetreating: desplazamiento euclídeo, ventana STUCK_TIME (0.7s).
    //
    // Al confirmar atascado, escanea el anillo y ataca con prioridad:
    //   HÉROE ENEMIGO > CREEP ENEMIGO > CREEP ALIADO, prefiriendo el que esté
    //   en el cono de salida (hacia casa). Nunca héroes aliados.
    //
    // Maneja el CONTADOR DE REINCIDENCIA y activa BERSERKER al 3er ciclo.
    public function Try takes unit botUnit, player botOwner, boolean isRetreating, boolean wantsToMove, integer currentOrder returns boolean
        local LaningBrain brain = IABlackboard_GetLaningBrain(botUnit)
        local real now = IAUtils_GetGameTime()
        local real botX = GetUnitX(botUnit)
        local real botY = GetUnitY(botUnit)
        local real homeX
        local real homeY
        local real homeAng
        local real progress
        local real stuckWin
        local real distHome
        local boolean stuck = false
        local boolean moved
        local group g
        local unit u
        local unit best = null
        local real bestScore = -99999.0
        local real score
        local real tier
        local real hp
        local real ang
        local real angDiff
        local real coneBonus
        local boolean isHeroU
        local boolean isAlly
        local boolean elig
        local unit prevTgt = null
        // desplazamiento euclídeo del instante de detección (métrica de combate)
        local real dbgDisp = 0.0

        // Anti-CC: si está pausado, ni siquiera intentamos.
        if IsLocked(botUnit) then
            return false
        endif

        // --- Salvaguarda de referencias rancias ---
        // Tras estados que no llaman a Try (Shopping, fountain-escape) o tras
        // revive, las referencias de progreso pueden ser viejas. Si lo son y no
        // hay breakout activo, las re-inicializamos al "ahora". Sin esto, un
        // bot que vuelve a huir después de un rato puede disparar X-stuck en el
        // primer frame por (now - xRefTime) muy grande.
        if not brain.breakoutActive then
            if brain.stuckRefTime < 0.01 or (now - brain.stuckRefTime) > 5.0 then
                call ResetStuckRef(brain, botUnit, botX, botY, now)
                return false
            endif
        endif

        // --- Salidas del breakout activo ---
        if brain.breakoutActive then
            // EXIT (a) ESCAPE GENUINO: me alejé de verdad del punto del cerco.
            if IAUtils_GetDistanceUnitXY(botUnit, brain.breakoutRefX, brain.breakoutRefY) >= FREE_DIST then
                call CloseBreakout(brain, now)
                call ResetStuckRef(brain, botUnit, botX, botY, now)
                return false
            endif
            // EXIT (b) VÍCTIMA MUERTA: rompimos este eslabón. Cerramos para re-evaluar
            // (¿ya puedo escapar? ¿sigo atrapado? -> el escaneo de abajo elegirá otra
            // víctima si todavía hay bloqueadores).
            if brain.breakoutTarget == null or IsUnitType(brain.breakoutTarget, UNIT_TYPE_DEAD) then
                call CloseBreakout(brain, now)
                call ResetStuckRef(brain, botUnit, botX, botY, now)
                return false
            endif
            // EXIT (c) CAMINO LIBRE (CHANGE C, sólo huida y fuera de berserker): el
            // bloqueador se apartó y el corredor recto a casa quedó despejado.
            // Soltamos por evidencia POSITIVA, sin esperar a matar a la víctima.
            // Esto ataca la queja "el creep se movió a un lado y el bot sigue
            // insistiendo en matarlo aunque ya no tapa nada". NO reabre el bug del
            // ping-pong con la Emergencia: sólo suelta cuando el camino está
            // demostrablemente libre; si no, el COMPROMISO de abajo sigue vigente.
            // Throttle CORRIDOR_RECHECK (el escaneo es O(n)+terreno).
            if isRetreating and not brain.berserkActive and (now - brain.breakoutPathCheckTime) >= CORRIDOR_RECHECK then
                set brain.breakoutPathCheckTime = now
                if IsCorridorClearToHome(botUnit) then
                    call CloseBreakout(brain, now)
                    call ResetStuckRef(brain, botUnit, botX, botY, now)
                    return false
                endif
            endif
            // COMPROMISO HASTA MATAR (sin timeout): mientras la víctima siga VIVA y el
            // bot no haya escapado, el breakout permanece ACTIVO y Try() devuelve true
            // cada frame. Eso BLOQUEA que la "Emergencia: Volviendo a Base" (Survival)
            // o el De-Aggro (Laning) se cuelen a interrumpir el ataque. Antes un
            // BREAKOUT_TIMEOUT de 2.5s cerraba el modo aunque el bot siguiera atrapado
            // y la víctima viva; en ese hueco Survival emitía la emergencia y el bot
            // dejaba de pelear (capturas: bot azul encerrado entre tiendas, alternando
            // "Encerrado c1" <-> "Emergencia" sin llegar a matar al bloqueador). El
            // usuario lo pidió explícito: encerrado = atacar al que estorba HASTA
            // matarlo; solo la muerte de la víctima o un escape real liberan el modo.
            // sigue activo, caemos al escaneo
        endif

        // --- Sin intención de moverse y no activo: nada que hacer ---
        if not wantsToMove and not brain.breakoutActive then
            call ResetStuckRef(brain, botUnit, botX, botY, now)
            return false
        endif

        // --- Detección de estancamiento (métrica según contexto) ---
        if not brain.breakoutActive then
            if isRetreating then
                // Progreso de huida = cuánto NOS ACERCAMOS a casa en línea recta
                // (combina X+Y). En el carril el acercamiento es casi todo X; pero
                // dentro de la propia base, yendo a la fuente norte/sur pegado al
                // castillo, es casi todo Y. Medir solo X daría un falso "atascado"
                // al subir/bajar hacia la fuente. brain.xRef = distancia previa.
                set homeX = IABrainMacro_GetClosestHomeX(botUnit)
                set homeY = IABrainMacro_GetClosestHomeY(botUnit)
                set distHome = SquareRoot((botX-homeX)*(botX-homeX) + (botY-homeY)*(botY-homeY))
                set progress = brain.xRef - distHome        // positivo => me acerqué a casa
                if progress >= X_PROGRESS_EPS then
                    set brain.xRef = distHome
                    set brain.xRefTime = now
                    return false
                endif
                // Umbral de detección DINÁMICO (clave de la cadena de ciclos):
                //   - Encierro INICIAL (sin cadena activa): X_STUCK_TIME = 4.0s.
                //   - RE-detección dentro de la ventana de reincidencia (ya hubo un
                //     breakout y seguimos dentro de CYCLE_WINDOW): X_STUCK_TIME_CHAIN
                //     = 1.9s, para re-confirmar "atascado" ANTES de que la ventana de
                //     2s expire; si no, la cadena C1->C2->C3->Berserker nunca avanza
                //     (4s de re-detección > 2s de ventana => el ciclo se reiniciaba).
                // El gate es EXACTAMENTE el mismo predicado que el contador de ciclo
                // (más abajo): si el bot escapó o el próximo encierro llega 5s/1min
                // después, (now - lastBreakoutEndTime) > CYCLE_WINDOW => el umbral
                // VUELVE a 4.0s y el ciclo reinicia a 1. El 1.9s nunca se queda pegado
                // para el resto de la partida: solo vive dentro de la ventana de 2s.
                set stuckWin = X_STUCK_TIME
                if brain.breakoutCycle > 0 and (now - brain.lastBreakoutEndTime) <= CYCLE_WINDOW then
                    set stuckWin = X_STUCK_TIME_CHAIN
                endif
                if (now - brain.xRefTime) < stuckWin then
                    return false
                endif
                set stuck = true
            else
                set dbgDisp = SquareRoot((botX-brain.lastPosX)*(botX-brain.lastPosX) + (botY-brain.lastPosY)*(botY-brain.lastPosY))
                set moved = (dbgDisp >= MOVE_EPS)
                if moved then
                    call ResetStuckRef(brain, botUnit, botX, botY, now)
                    return false
                endif
                if (now - brain.stuckRefTime) < STUCK_TIME then
                    return false
                endif
                set stuck = true
            endif
        endif

        // --- Si recién detectamos atascado (no estaba activo), abrir ciclo ---
        if stuck and not brain.breakoutActive then
            // ¿Estamos dentro de la ventana de 2s desde el último breakout?
            if brain.breakoutCycle > 0 and (now - brain.lastBreakoutEndTime) <= CYCLE_WINDOW then
                set brain.breakoutCycle = brain.breakoutCycle + 1
            else
                set brain.breakoutCycle = 1
            endif

            // 3er encierro consecutivo => Berserker. NO hacemos breakout normal,
            // entramos directo y este frame ya emite la orden de berserker.
            if brain.breakoutCycle >= 3 and not brain.berserkActive then
                set brain.berserkActive  = true
                set brain.berserkEntryX  = botX
                set brain.berserkEntryY  = botY
                set brain.berserkTarget  = null
                // Ejecutamos berserker AHORA mismo. Si encuentra target -> handled.
                // Si no (sin héroe/invocación en rango), caemos abajo al ring scan
                // para hacer creep-escape, manteniendo el modo activo.
                if ExecuteBerserk(botUnit, botOwner) then
                    return true
                endif
                // Fall-through: berserker activo pero sin target, hacemos creep escape.
            endif

            // Abrimos breakout normal (ciclo 1 o 2, o berserker sin target).
            set brain.breakoutActive    = true
            set brain.breakoutStartTime = now
            set brain.breakoutRefX      = botX
            set brain.breakoutRefY      = botY
        endif

        // --- Escaneo del anillo + selección por prioridad ---
        set homeX = IABrainMacro_GetClosestHomeX(botUnit)
        set homeY = IABrainMacro_GetClosestHomeY(botUnit)
        set homeAng = Atan2(homeY - botY, homeX - botX)

        set g = CreateGroup()
        call GroupEnumUnitsInRange(g, botX, botY, BREAKOUT_RADIUS, null)
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            call GroupRemoveUnit(g, u)
            if u != botUnit and not IsUnitType(u, UNIT_TYPE_DEAD) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                set isHeroU = IsUnitType(u, UNIT_TYPE_HERO)
                set isAlly  = IsUnitAlly(u, botOwner)
                // Elegible = enemigo (creep o héroe) o creep aliado. Nunca héroe aliado.
                set elig = (not isAlly) or (not isHeroU)
                if elig and isHeroU and not isAlly then
                    // Saltar enemigos dentro de fuente enemiga (no nos metamos ahí).
                    if IABrainMacro_IsInEnemyFountain(GetUnitX(u), GetUnitY(u), botOwner) then
                        set elig = false
                    endif
                    // Fix BRK-DIVE: tampoco héroes en zona de veto de asedio
                    // (más allá del frente). Creeps/estructuras siguen siendo
                    // la salida del cerco; el dive reportado era esto.
                    if elig and IsHeroTooDeep(brain, botOwner, u) then
                        set elig = false
                    endif
                endif
                if elig then
                    // tier: 300 héroe enemigo > 200 creep enemigo > 100 creep aliado
                    if isHeroU and not isAlly then
                        set tier = 300.0
                    elseif not isAlly then
                        set tier = 200.0
                    else
                        set tier = 100.0
                    endif
                    // bonus si está en cono de salida (preferimos derribar el muro hacia casa)
                    set ang = Atan2(GetUnitY(u) - botY, GetUnitX(u) - botX)
                    set angDiff = NormAng(ang - homeAng)
                    if angDiff > -CONE_WIDE_HALF and angDiff < CONE_WIDE_HALF then
                        set coneBonus = 50.0
                    else
                        set coneBonus = 0.0
                    endif
                    set hp = GetUnitState(u, UNIT_STATE_LIFE)
                    // Mismo tier+cono => desempata por HP (menos HP = mejor).
                    set score = tier + coneBonus - (hp / 1000.0)
                    if score > bestScore then
                        set bestScore = score
                        set best = u
                    endif
                endif
            endif
        endloop
        call DestroyGroup(g)
        set g = null

        if best == null then
            // Sin víctima: cerramos breakout sin "logro" y dejamos al flujo normal.
            call CloseBreakout(brain, now)
            call ResetStuckRef(brain, botUnit, botX, botY, now)
            set u = null
            return false
        endif

        // Emisión anti-spam.
        set prevTgt = brain.breakoutTarget
        if currentOrder != OrderId("attack") or best != prevTgt then
            call IssueTargetOrder(botUnit, "attack", best)
        endif
        set brain.breakoutTarget = best

        set u = null
        set best = null
        set prevTgt = null
        return true
    endfunction

endlibrary
