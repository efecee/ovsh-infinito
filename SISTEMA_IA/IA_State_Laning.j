library IAStateLaning requires IAUtils, IAData, IABrainMacro, IABlackboard, IABreakout, IABuildProgress

    // ============================================================
    // ARQUITECTURA: SENTIR -> PENSAR -> ACTUAR
    // ============================================================
    // Este comportamiento de carril se divide en dos fases claras que se
    // comunican EXCLUSIVAMENTE a través de la pizarra (LaningBrain):
    //
    //   1) Think()        -> SENTIR + PENSAR. Escanea el mundo, puntúa
    //                        objetivos (Utility AI), gestiona tolerancia y
    //                        decay, y RESUELVE qué hacer. NO emite ni una
    //                        sola orden. Solo escribe su decisión en la
    //                        pizarra (brain.attackTarget, brain.incomingDamage...).
    //
    //   2) ExecuteLaning() -> ACTUAR. Único lugar autorizado a emitir
    //                        órdenes. Lee la decisión de la pizarra y la
    //                        traduce a IssueOrder.
    //
    // Esta separación es la que evita los bugs en cascada: se puede tocar
    // el scoring sin tocar la FSM de timing, y viceversa.
    // ============================================================

    globals
        // Margen para compensar el tiempo de giro de la unidad.
        // El héroe necesita girarse (~0.2s) antes de iniciar la animación.
        // Sin esto, la FSM cancela el ataque antes de que el proyectil salga.
        private constant real TURN_TIME_MARGIN = 0.25

        // Colchón de COLISIÓN (melee Y rango): GetDistanceUnits mide centro-a-
        // centro, pero el motor permite golpear descontando el radio de colisión
        // del objetivo, así que un héroe pegándole/disparándole a un creep queda
        // a (rango + ~colisión_del_creep) de centro a centro. Observado: melee
        // ~159-181 con rango 128 (sobrepaso ~30-53); rango 659-663 con rango 600
        // (sobrepaso ~60). El sobrepaso depende de la COLISIÓN DEL OBJETIVO, no
        // del rango del atacante, por eso el mismo colchón sirve para ambos. Sin
        // él, un héroe quieto atacando en rango se cree "fuera de rango" ->
        // wantsToMove falso -> falso "Encerrado". Solo afecta el gate de breakout
        // (no la FSM ni inAttackRange, para no alterar timing/last-hit).
        private constant real ATTACK_REACH_SLACK = 100.0

        // --- HISTÉRESIS DE ESCAPE DE FUENTE ENEMIGA ---
        // Cuando la guardia de fuente rebota al bot, se compromete a SEGUIR
        // alejándose hacia su propia casa durante esta ventana, aunque el frame
        // siguiente ya esté fuera del margen. Sin esto, "Avanzando" (macro) lo
        // re-apunta a la zona y rebota: ping-pong Avanzando<->FUENTE + falso
        // Berserker. La ventana es corta: solo despeja el margen y suelta al
        // héroe que se refugió; al vencer, el scoring normal (assist/empuje)
        // reanuda solo (el héroe en la fuente ya está excluido del scoring).
        private constant real FOUNTAIN_ESCAPE_COMMIT = 1.2

        // --- HISTÉRESIS DEL DE-AGGRO TÁCTICO ---
        // Una vez que el de-aggro dispara, el bot se compromete a alejarse esta
        // cantidad de segundos aunque el daño cese entre golpes. Rompe el
        // ping-pong avanzar<->retroceder en el borde de torre (mismo principio
        // que FOUNTAIN_ESCAPE_COMMIT). Se RE-ARMA con cada golpe nuevo, así que
        // la retirada total dura hasta salir del peligro + este margen. Sin esto,
        // el primer frame sin daño volvía a "Avanzar" y el siguiente golpe hacía
        // huir -> baile / falso "Encerrado" por desplazamiento neto ~0.
        private constant real DEAGGRO_COMMIT = 1.2

        // --- SISTEMA DE TOLERANCIA ADITIVO ---
        public  constant real TOLERANCE_BASE     = 5.0   // Base: 5% de HP como umbral mínimo
        private constant real TOLERANCE_MAX      = 30.0  // Techo máximo (30%)
        private constant real DECAY_INTERVAL     = 2.0   // Verificar cada 2 segundos
        private constant real DECAY_AMOUNT       = 5.0   // Reducción por fallo de decay
        private constant real TOLERANCE_TEAM_MIN = 10.0  // Mínimo en team focus

        // --- SIEMBRA PREDICTIVA DE TOLERANCIA (predecir-para-COMPROMETER) ---
        // La rampa de tolerancia de abajo es REACTIVA: solo sube DESPUÉS de medir
        // un golpe real sobre el target (observedDmgPerHit). Antes de ese 1er
        // golpe la tolerancia está en base y el de-aggro puede SOLTAR a un héroe
        // que SÍ podía rematar (recibe fuego de vuelta antes de aterrizar su
        // golpe). Aquí, con daño MODELADO (mi daño vs SU armadura estimada, misma
        // cuenta que el BONUS DE CAZA), si lo mato en pocos golpes y lo tengo a
        // alcance, SIEMBRO un piso de tolerancia ANTES del 1er golpe y armo el
        // decay (predigo para comprometer, observo para sostener, decay para
        // corregir). Pisos MODESTOS (< TOLERANCE_MAX): comprometen UNA pasada, no
        // un suicidio — el recorte por focus enemigo sigue aplicándose ENCIMA.
        // DIALES (tunear en partida con el texttag PRED, regla debug-first):
        private constant real PRED_FLOOR_2 = 16.0  // golpes-modelados-para-matar <= 2
        private constant real PRED_FLOOR_3 = 12.0  // <= 3 golpes
        private constant real PRED_FLOOR_4 =  8.0  // <= 4 golpes

        // --- VETO DE PROFUNDIDAD DE CAZA (anti-dive a la base enemiga) ---
        // Cuánto MÁS ALLÁ del frente de asedio (estructura enemiga viva más
        // adelantada, IABrainMacro_GetSiegeFrontX) se tolera perseguir un héroe
        // antes de vetar la caza. dp > este valor => no se persigue. La línea se
        // encoge/extiende sola con las fases (cae F3 -> frente pasa a F2 -> más
        // adentro permitido) y el veto ENTERO se apaga cuando la F1 enemiga abre
        // (IABrainMacro_IsSiegeVetoActive). Solo afecta el TARGETING de HÉROES:
        // estructuras y creeps NUNCA se vetan, y el avance por fases queda intacto,
        // así que NO puede crear bucle avanzar/retroceder (el veto no emite orden).
        private constant real ENEMY_DEPTH_SLACK  = 200.0

        // Umbral de "rematable" que LEVANTA el veto de profundidad: si el bot
        // mata al héroe en <= estos golpes vale la pena rematarlo aunque esté
        // metido en la base. Mismo criterio de GOLPES que el despeje de
        // IA_Breakout.j (MAX_HITS_*), pero aquí contando la ARMADURA del héroe
        // (héroes manejan armadura + HP, no solo HP como los creeps): un tanque a
        // 20% de vida puede seguir siendo >2 golpes. NO se usa porcentaje.
        private constant real HUNT_LETHAL_HITS   = 2.0

        // --- SENSORES: ANTICIPACIÓN DE PELIGRO (daño POTENCIAL, no recibido) ---
        // Héroes enemigos marcados peligrosos en IA_Data (danger >= DANGER_ANTICIPATE)
        // a rango de combo suman amenaza al de-aggro SOLO en INFERIORIDAD local
        // (aliados cerca < enemigos cerca). Con compañía no se anticipa nada:
        // los stats y el foco gobiernan. (Pedido del usuario: "si te quedas solo
        // con el Señor del Terror, toma distancia"; el daño se ANTICIPA aunque
        // aún no se haya recibido.)
        private constant real DANGER_RADIUS      = 800.0  // a este radio el peligroso ya te alcanza con su combo
        private constant real DANGER_ANTICIPATE  = 1.4    // danger mínimo que dispara anticipación
        private constant real ANTICIPATE_HITS    = 2.0    // nº de "golpes" del exceso de peligro sumados como amenaza

        // --- ALIADO CONDENADO ("EL SIGUIENTE SOY YO") ---
        // Si un aliado cercano va a morir en < ALLY_DOOM_T al ritmo REAL de daño
        // (EMA central de su pérdida de vida, IA_Blackboard) bajo focus enemigo
        // (>=2 héroes) y, sin él, quedamos en inferioridad local, el bot se
        // retira AHORA aunque tenga la vida llena: el siguiente del focus es él.
        // 6s = punto medio del rango pedido (5-7): menos = no da tiempo a huir
        // (lo cazan enseguida); más = abandona peleas todavía ganables.
        private constant real ALLY_DOOM_T        = 6.0
        private constant real ALLY_DOOM_MIN_LOSS = 30.0   // HP/s mínimos para considerar que el aliado "está cayendo" (filtra ruido)

        // --- TOLERANCIA 2.0: RECORTE POR FOCUS ENEMIGO ---
        // Cada héroe enemigo EXTRA enfocándome recorta el umbral EFECTIVO de
        // de-aggro de este frame (1 encima = aguante normal; 3 = la mitad).
        // OJO: solo el umbral del frame; la tolerancia PERSISTIDA no se toca
        // (persistirla recortada realimentaría la rampa a la baja en espiral).
        private constant real FOCUS_TOL_CUT      = 0.25

        // --- PONDERACIÓN HUMANO vs BOT DEL BONUS DE ASISTENCIA ---
        // El bonus de "OPORTUNIDAD GRUPAL" sube el puntaje de una víctima por cada
        // aliado que la enfoca. Pero un JUGADOR REAL elige mejor a quién pegarle;
        // un foco formado SOLO por bots puede auto-confirmarse en el blanco
        // equivocado (varios bots votándose en cadena al objetivo que no toca).
        // Por eso cada voto de un humano pesa este factor (un voto de bot = 1.0):
        // a igual nº de atacantes, la víctima que enfoca un humano recibe MÁS
        // puntaje y el bot se suma a ESE blanco. 2.0 = el target de 1 humano vale
        // como el de 2 bots. NO altera teamFocusCount (nº crudo de aliados, que el
        // kill-commit y la tolerancia de equipo necesitan literal): solo pondera el
        // puntaje del bonus de asistencia.
        private constant real ASSIST_HUMAN_WEIGHT = 2.0

        // --- AVANCE AGRUPADO (WAR PARTY, late game) ---
        // Activo desde que cualquier F1 se abre (IABrainMacro_IsWarPartyActive).
        // Regla de grupo: min(héroes del equipo, 3) — en equipos de 3 se espera
        // a TODOS (pedido del usuario), en equipos de 4-5 basta la mayoría (3).
        private constant real GROUP_RADIUS   = 900.0  // aliados a este radio cuentan como "mi grupo"
        private constant real WP_COMMIT      = 6.0    // s que el push sigue válido aunque un compañero se rezague
        private constant real WP_REISSUE_EPS = 200.0  // re-emitir el move al rally solo si éste se movió más que esto

        // --- CARRIL PASIVO (MELEE SIN SU 1ª ARMADURA) ---
        // Un melee cuerpo a cuerpo juega pasivo hasta conseguir su 1ª armadura:
        // NO farmea/harasea/persigue (se apaga todo el Utility-AI ofensivo); solo
        // se coloca tras la línea de creeps aliados, ~PASSIVE_BEHIND por detrás del
        // creep enganchado (en combate) más rezagado, y MANTIENE posición (hold).
        // Si aún no hay creeps en combate, espera junto a su Fase 3 propia. Al
        // conseguir la armadura, el cerrojo (brain.armorGateOpen) se abre y el
        // sistema se desactiva por completo: el héroe juega como si no existiera.
        private constant real PASSIVE_BEHIND      = 400.0   // distancia tras el creep rezagado (hacia casa)
        private constant real PASSIVE_ARRIVE_DIST = 150.0   // llegué al destino => mantener (hold)
        private constant real PASSIVE_UNPARK_DIST = 350.0   // el destino se alejó => volver a seguir
        private constant real PASSIVE_REISSUE_EPS = 120.0   // el destino se movió esto => re-emitir "move"
        private constant real PASSIVE_SCAN_RADIUS = 2200.0  // radio para detectar la línea de creeps en combate
    endglobals

    // ============================================================
    //  [PASIVO] CÁLCULO DEL ANCLA TRAS LA LÍNEA DE CREEPS ALIADOS
    // ============================================================
    // Busca el creep ALIADO enganchado (en combate, NO en marcha) más REZAGADO
    // (el más cercano a la base propia) en el carril del bot, y deja el ancla en
    // la pizarra a PASSIVE_BEHIND por detrás de él (hacia casa). "Enganchado" =
    // tiene OBJETIVO FÍSICO vivo enemigo (está golpeando a alguien), NO basta con
    // la orden: los creeps marchan con attack-move, así que un recién aparecido que
    // solo se desplaza NO cuenta hasta que ataque de verdad. Si no hay ninguno
    // enganchado, brain.passiveHasAnchor = false (el caller esperará en su Fase 3
    // propia). Es fase PENSAR: NO emite órdenes. DestroyGroup + nullea.
    private function ComputePassiveAnchor takes unit botUnit, player botOwner, integer botLane, LaningBrain brain returns nothing
        local boolean isHuman = IsPlayerAlly(botOwner, Player(0))
        local real botX = GetUnitX(botUnit)
        local real botY = GetUnitY(botUnit)
        local group g = CreateGroup()
        local unit u
        local unit ct       // objetivo físico del creep (a quién está golpeando)
        local real ux
        local real uy
        local unit best = null
        local real bestX = 0.0

        call GroupEnumUnitsInRange(g, botX, botY, PASSIVE_SCAN_RADIUS, null)
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            call GroupRemoveUnit(g, u)
            if u != botUnit and not IsUnitType(u, UNIT_TYPE_DEAD) and IsUnitAlly(u, botOwner) and not IsUnitType(u, UNIT_TYPE_HERO) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_SUMMONED) then
                set uy = GetUnitY(u)
                // Mismo carril (mismo signo de Y que el bot): evita anclar a creeps
                // del otro carril si el radio llegara a rozarlo.
                if (botY >= 0.0 and uy >= 0.0) or (botY < 0.0 and uy < 0.0) then
                    // ENGANCHADO = está atacando EFECTIVAMENTE a un enemigo VIVO.
                    // OJO: los creeps de este mapa MARCHAN con attack-move (orden
                    // "attack"), así que "orden != move" contaba a los recién
                    // aparecidos que solo se desplazan. La señal correcta es su
                    // OBJETIVO FÍSICO (IA_Target_Memory key 1): solo se setea cuando
                    // el creep golpea a alguien (EVENT_..._ATTACKED). Sin objetivo
                    // físico vivo enemigo = solo marchando => se IGNORA.
                    set ct = IAUtils_GetUnitPhysicalTarget(u)
                    if ct != null and not IsUnitType(ct, UNIT_TYPE_DEAD) and IsUnitEnemy(ct, botOwner) then
                        set ux = GetUnitX(u)
                        // Más rezagado = más cercano a casa: min X humano / max X orco.
                        if best == null or (isHuman and ux < bestX) or ((not isHuman) and ux > bestX) then
                            set best = u
                            set bestX = ux
                        endif
                    endif
                endif
            endif
        endloop
        call DestroyGroup(g)
        set g = null

        if best != null then
            set brain.passiveHasAnchor = true
            if isHuman then
                set brain.passiveAnchorX = bestX - PASSIVE_BEHIND
            else
                set brain.passiveAnchorX = bestX + PASSIVE_BEHIND
            endif
            set brain.passiveAnchorY = GetUnitY(best)
        else
            set brain.passiveHasAnchor = false
        endif
        set best = null
        set u = null
        set ct = null
    endfunction

    // ============================================================
    //  FASE 1 + 2: SENTIR + PENSAR  (NO emite ninguna orden)
    // ============================================================
    // Rellena la pizarra con la decisión del frame. Todo lo que la fase
    // ACTUAR necesita queda guardado en 'brain'.
    private function Think takes unit botUnit, player botOwner, integer botLane, LaningBrain brain returns nothing
        // --- 1. VARIABLES ---
        local group g

        // OBJETIVOS
        local unit killTarget = null
        local unit standardTarget = null
        local unit enumUnit
        local unit lastTarget = null

        // ASISTENCIA MACRO (tally por objetivo, fix del foco grupal)
        local unit teamFocusTarget = null
        local integer teamFocusCount = 0
        local unit allyTarget
        local unit array tallyHero
        local integer array tallyCount
        local integer array tallyHumanCount   // de tallyCount, cuántos votos son de jugadores REALES (subconjunto)
        local integer tallyN = 0
        local integer ti
        local integer tIdx                     // índice del objetivo en el tally (encontrado o recién creado)
        local integer bestTally
        local integer bestIdx                  // índice del foco ganador (para leer su recuento humano)
        local integer teamFocusHumanCount = 0  // de los teamFocusCount votos del foco, cuántos son humanos
        local real effectiveFocus = 0.0        // votos ponderados (humano pesa más) para el bonus de asistencia

        // SENSORES DE PRESIÓN LOCAL
        local integer enemyHeroesNear = 0
        local integer allyHeroesNear = 0
        local integer alliesClose = 0
        local integer enemiesTargetingMe = 0
        local unit physT
        local unit intentT
        local real dangerExcess = 0.0      // amenaza acumulada de héroes peligrosos a DANGER_RADIUS
        local real anticip = 0.0
        local real heroDangerVal

        // ALIADO CONDENADO
        local LaningBrain allyBrain
        local real allyLoss
        local real allyT2D
        local real minAllyT2D = 99999.0

        // TOLERANCIA EFECTIVA Y PENALIZACIÓN
        local real effTolerance
        local real candPenalty

        // AVANCE AGRUPADO (WAR PARTY)
        local integer wpTotal
        local integer wpNeeded
        local boolean wpActive = false
        local boolean wpAdvanceOK = true
        local boolean wpHoldFire = false

        // VALORES
        local real lowestKillHP = 99999.0
        local real bestStandardScore = -99999.0
        local real currentScore

        // DATOS DE LA UNIDAD
        local real enumHP
        local real enumMaxHP
        local boolean isEnemy
        local boolean isHero
        local boolean isStruct
        local boolean inEnemyFountain
        local real dist

        // DATOS PROPIOS
        local real myDamage
        local real myRange
        local boolean amIMelee = false
        local boolean passiveActive = false  // [PASIVO] melee sin su 1ª armadura

        // VETO DE PROFUNDIDAD DE CAZA (anti-dive a la base enemiga)
        local boolean vetoActive
        local boolean botIsHuman
        local real siegeFrontX = 0.0
        local boolean tooDeepToHunt
        local real dp
        local group humanFocusGroup     // héroes enemigos enfocados por un aliado HUMANO (no bot)
        local real enemyArmorEst        // armadura estimada del héroe evaluado
        local real enemyDmgRed          // multiplicador de daño tras SU armadura
        local real heroHitsToKill       // golpes-para-matar a ESTE héroe (HP / daño-mitigado)

        // SEGURIDAD Y DE-AGGRO
        local boolean isLethalHero
        local real safetyPenalty
        local boolean isRetreating
        local real incomingDamage = 0.0
        local real damageThreshold = 0.0
        local real enemyDamage = 0.0
        // [DEBUG_IA] desglose de incomingDamage por fuente (torre/héroe/creep).
        // Sirve para distinguir el ping-pong del anillo de torre del de
        // persecución de héroe. Quitar junto con su uso al cerrar el bug.
        local real dmgTower = 0.0
        local real dmgHero = 0.0
        local real dmgCreep = 0.0
        local real myHPPct
        local real lethalRange

        // TOLERANCIA ADITIVA Y OBSERVACIÓN
        local real tolerance
        local real preAttackHP
        local real observedDmgPerHit
        local real lastDecayCheckTime
        local boolean decayActive
        local real decayBaselineHP
        local real hpDelta
        local real hitsToKill
        local boolean allyAssisting
        local real currentTargetHP
        // SIEMBRA PREDICTIVA DE TOLERANCIA
        local boolean predCommitActive
        local real predFloor

        // --- CÁLCULO DE ARMADURA ---
        local real myArmor
        local real damageReductionMult

        // --- VARIABLES DE AGGRO REAL ---
        // (intencionalmente ninguna orden aquí)

        // --- FSM Y PREDICCIÓN MATEMÁTICA ---
        local real enumRegen
        local real predictedTravelTime
        local real dynamicDamagePoint
        local real dynamicCooldown
        local real totalDelay
        local real predictedHP
        local real currentTime
        local real lastAttackTime
        local unit attackTarget = null
        local real windupEnd
        local real cooldownEnd

        // --- 2. PREPARACIÓN ---
        set myRange = IAData_GetHeroAttackRange(botUnit)
        set myDamage = IAData_GetHeroEstimatedDamage(botUnit)
        set myArmor = IAData_GetHeroEstimatedArmor(botUnit)
        set lastTarget = brain.lastTarget

        set currentTime = IAUtils_GetGameTime()
        set lastAttackTime = brain.lastAttackTime
        set dynamicDamagePoint = IAUtils_GetUnitDamagePoint(botUnit)
        set dynamicCooldown = IAUtils_GetUnitAttackCooldown(botUnit)
        set windupEnd = lastAttackTime + dynamicDamagePoint + TURN_TIME_MARGIN
        // FALLA D: cooldownEnd YA NO lleva TURN_TIME_MARGIN. dynamicCooldown =
        // baseCD/mod ENCOGE con la velocidad de disparo (hasta /5 a +400%), así que
        // sumar un +0.25 PLANO al gate de re-disparo se volvía proporcionalmente
        // enorme: a máx. velocidad casi DUPLICABA el cooldown (p.ej. 0.38 -> 0.63 =
        // ~40% menos DPS). El margen de giro se queda SOLO en windupEnd (ahí sí
        // protege: evita kitear/cancelar el ataque antes de soltar el proyectil). El
        // re-disparo lo gobierna el cooldown REAL; emitir el ataque un pelín antes es
        // inofensivo (el motor gestiona el giro solo, no genera temblor).
        set cooldownEnd = lastAttackTime + dynamicCooldown

        if myRange < 150.0 then
            set amIMelee = true
        endif

        // --- CARRIL PASIVO: CERROJO DE ARMADURA (un solo sentido) ---
        // Un melee juega pasivo hasta su 1ª armadura. El cerrojo se ABRE una vez y
        // NO se re-evalúa jamás: al conseguir la armadura, el sistema se desactiva
        // por completo (aunque luego pierda la armadura o reviva). Solo un melee
        // paga el escaneo de inventario, y solo hasta abrir el cerrojo; un héroe a
        // distancia (amIMelee=false) nunca entra aquí ni queda pasivo.
        if amIMelee and not brain.armorGateOpen then
            if IABuildProgress_HasFirstArmor(botUnit) then
                set brain.armorGateOpen = true
                // Limpieza del estado pasivo para un traspaso 100% limpio a la
                // FSM normal (que esto no deje rastro tras desactivarse).
                set brain.passiveParked = false
                set brain.passiveLastIssuedX = 0.0
                set brain.passiveLastIssuedY = 0.0
            endif
        endif
        set passiveActive = amIMelee and not brain.armorGateOpen

        // --- VETO DE PROFUNDIDAD DE CAZA (preparación, una vez por frame) ---
        // Activo solo mientras la F1 enemiga siga protegida. siegeFrontX = la X
        // hasta donde llegó el asedio; por héroe se mide cuánto se metió MÁS
        // ALLÁ de esa línea (dp) y, si supera ENEMY_DEPTH_SLACK, no se persigue.
        set botIsHuman = IsPlayerAlly(botOwner, Player(0))
        set vetoActive = IABrainMacro_IsSiegeVetoActive(botOwner)
        if vetoActive then
            set siegeFrontX = IABrainMacro_GetSiegeFrontX(botUnit, botLane)
        endif
        set brain.dbgSiegeX = siegeFrontX     // [DEBUG_IA]
        set brain.dbgVetoActive = vetoActive  // [DEBUG_IA] lo leen ExecuteLaning/Breakout/Berserk para medir la profundidad del BOT

        // --- CÁLCULO DE MITIGACIÓN DE ARMADURA (Fórmula Nativa WC3) ---
        if myArmor >= 0.0 then
            set damageReductionMult = 1.0 - ((myArmor * 0.06) / (1.0 + (myArmor * 0.06)))
        else
            // Armadura negativa incrementa daño (Aprox. 6% por punto)
            set damageReductionMult = 1.0 - (myArmor * 0.06)
        endif

        // --- 3. GESTIÓN DE ESTADO DE PÁNICO (PERSISTENCIA) ---
        // Recuperamos si estábamos huyendo en el ciclo anterior
        set isRetreating = brain.isRetreating

        // --- TOLERANCIA: CARGAR DATOS PERSISTENTES ---
        set tolerance = brain.tolerance
        set observedDmgPerHit = brain.observedDmgPerHit
        set decayActive = brain.decayActive
        set lastDecayCheckTime = brain.lastDecayCheckTime
        set decayBaselineHP = brain.decayBaselineHP
        set predCommitActive = brain.predCommitActive

        // Inicializar tolerancia en primer ciclo
        if tolerance < 0.01 and not decayActive then
            set tolerance = TOLERANCE_BASE
        endif

        // --- 4. ESCANEO DE ASISTENCIA (PRE-LOOP) ---
        // ¿Qué FOCO tiene mi equipo? TALLY POR OBJETIVO (fix del bug de foco):
        // cada aliado vota por SU target y el foco del equipo es el héroe
        // enemigo CON MÁS VOTOS (empate: el de menor HP%). Antes se
        // sobreescribía teamFocusTarget con cada aliado enumerado y el contador
        // sumaba aliados pegándole a CUALQUIERA: con A->X y B->Y reportaba
        // "2 aliados sobre <el último en enumerarse>", inflando el bonus de
        // asistencia y disparando el kill-commit con focos que no existían.
        // Mismo patrón de tally que SelectBerserkTarget (IA_Breakout.j).
        // En esta misma pasada se censan los aliados cercanos (sensores) y el
        // ALIADO CONDENADO (t2d = su HP / su pérdida real, IA_Blackboard).
        set teamFocusTarget = null
        set teamFocusCount = 0
        // [VETO] héroes enemigos que un aliado HUMANO (no bot) está enfocando.
        // Solo el compromiso de un jugador real LEVANTA el veto de profundidad
        // (un bot aliado estaría igual de vetado, no justifica un dive grupal).
        set humanFocusGroup = CreateGroup()

        set g = CreateGroup()
        call GroupEnumUnitsInRange(g, GetUnitX(botUnit), GetUnitY(botUnit), 1200.0, null)

        loop
            set enumUnit = FirstOfGroup(g)
            exitwhen enumUnit == null

            if not IsUnitType(enumUnit, UNIT_TYPE_DEAD) and IsUnitAlly(enumUnit, botOwner) and enumUnit != botUnit then
                if IsUnitType(enumUnit, UNIT_TYPE_HERO) then
                    // SENSOR: aliados cerca (1200) y pegados a mí (war party)
                    set allyHeroesNear = allyHeroesNear + 1
                    if IAUtils_GetDistanceUnits(botUnit, enumUnit) <= GROUP_RADIUS then
                        set alliesClose = alliesClose + 1
                    endif

                    // ALIADO CONDENADO: ritmo real de caída del aliado (EMA
                    // central, la mantiene IACore via IABlackboard_UpdateHPTrack)
                    set allyBrain = IABlackboard_GetLaningBrain(enumUnit)
                    set allyLoss = allyBrain.selfLossRate
                    if allyLoss >= ALLY_DOOM_MIN_LOSS then
                        set allyT2D = GetUnitState(enumUnit, UNIT_STATE_LIFE) / allyLoss
                        if allyT2D < minAllyT2D then
                            set minAllyT2D = allyT2D
                        endif
                    endif

                    // VOTO DE FOCO: ¿a qué héroe enemigo ataca este aliado?
                    set allyTarget = IAUtils_GetUnitTarget(enumUnit)
                    if allyTarget != null and not IsUnitType(allyTarget, UNIT_TYPE_DEAD) and IsUnitType(allyTarget, UNIT_TYPE_HERO) and IsUnitEnemy(allyTarget, botOwner) then
                        // Localiza (o crea) la entrada del tally para este objetivo.
                        set ti = 0
                        set tIdx = -1
                        loop
                            exitwhen ti >= tallyN
                            if tallyHero[ti] == allyTarget then
                                set tIdx = ti
                                set ti = tallyN
                            endif
                            set ti = ti + 1
                        endloop
                        if tIdx < 0 then
                            set tIdx = tallyN
                            set tallyHero[tallyN] = allyTarget
                            set tallyCount[tallyN] = 0
                            set tallyHumanCount[tallyN] = 0
                            set tallyN = tallyN + 1
                        endif
                        set tallyCount[tIdx] = tallyCount[tIdx] + 1
                        // ¿El aliado que lo enfoca es un JUGADOR HUMANO (no bot)?
                        // Humano = controller USER **y slot PLAYING**: el héroe de un
                        // leaver tomado por la IA (takeover) conserva controller USER
                        // y NO debe contar como intención humana. El voto humano se
                        // cuenta APARTE (tallyHumanCount) para ponderar el bonus de
                        // asistencia: el jugador real sabe a quién enfocar; el bot puede
                        // auto-confirmarse en mal blanco, así que su voto pesa menos.
                        if GetPlayerController(GetOwningPlayer(enumUnit)) == MAP_CONTROL_USER and GetPlayerSlotState(GetOwningPlayer(enumUnit)) == PLAYER_SLOT_STATE_PLAYING then
                            set tallyHumanCount[tIdx] = tallyHumanCount[tIdx] + 1
                            call GroupAddUnit(humanFocusGroup, allyTarget)
                        endif
                    endif
                endif
            endif
            call GroupRemoveUnit(g, enumUnit)
        endloop

        // FOCO DEL EQUIPO = el héroe enemigo con MÁS votos; empate => menor HP%.
        set bestTally = 0
        set bestIdx = -1
        set ti = 0
        loop
            exitwhen ti >= tallyN
            if tallyCount[ti] > bestTally then
                set bestTally = tallyCount[ti]
                set teamFocusTarget = tallyHero[ti]
                set bestIdx = ti
            elseif tallyCount[ti] == bestTally and teamFocusTarget != null and (GetUnitState(tallyHero[ti], UNIT_STATE_LIFE) / GetUnitState(tallyHero[ti], UNIT_STATE_MAX_LIFE)) < (GetUnitState(teamFocusTarget, UNIT_STATE_LIFE) / GetUnitState(teamFocusTarget, UNIT_STATE_MAX_LIFE)) then
                set teamFocusTarget = tallyHero[ti]
                set bestIdx = ti
            endif
            set tallyHero[ti] = null
            set ti = ti + 1
        endloop
        set teamFocusCount = bestTally
        // De los votos del foco ganador, ¿cuántos son de jugadores REALES?
        // (tallyHumanCount es array aparte: no se anula en el bucle de arriba.)
        if bestIdx >= 0 then
            set teamFocusHumanCount = tallyHumanCount[bestIdx]
        else
            set teamFocusHumanCount = 0
        endif
        // PESO EFECTIVO del bonus de asistencia: cada voto HUMANO suma
        // ASSIST_HUMAN_WEIGHT (los bots suman 1.0). A igual nº de atacantes, el
        // foco que enfoca un humano puntúa más alto. teamFocusCount sigue crudo.
        set effectiveFocus = teamFocusCount + teamFocusHumanCount * (ASSIST_HUMAN_WEIGHT - 1.0)

        // Publicamos el foco de equipo en la pizarra (documenta la decisión).
        set brain.teamFocusTarget = teamFocusTarget
        set brain.teamFocusCount = teamFocusCount

        // --- 5. ESCANEO PRINCIPAL ---
        call GroupEnumUnitsInRange(g, GetUnitX(botUnit), GetUnitY(botUnit), 1200.0, null)

        // MEMORY EXTENSION: Retención del Target Principal si huye y sale brevemente de visión/rango
        if lastTarget != null and not IsUnitType(lastTarget, UNIT_TYPE_DEAD) and IAUtils_GetDistanceUnits(botUnit, lastTarget) <= 1500.0 then
            call GroupAddUnit(g, lastTarget)
        endif

        loop
            set enumUnit = FirstOfGroup(g)
            exitwhen enumUnit == null
            call GroupRemoveUnit(g, enumUnit)

            if not IsUnitType(enumUnit, UNIT_TYPE_DEAD) then
                set enumHP = GetUnitState(enumUnit, UNIT_STATE_LIFE)
                set enumMaxHP = GetUnitState(enumUnit, UNIT_STATE_MAX_LIFE)
                set isEnemy = IsUnitEnemy(enumUnit, botOwner)
                set isHero = IsUnitType(enumUnit, UNIT_TYPE_HERO)
                set isStruct = IsUnitType(enumUnit, UNIT_TYPE_STRUCTURE)
                set dist = IAUtils_GetDistanceUnits(botUnit, enumUnit)

                // KEEP-OUT: ¿este objetivo está dentro de una fuente enemiga?
                // Si lo está, NO lo perseguimos/targeteamos (evita meternos a la
                // zona de la fuente y comernos la torre). El daño entrante (abajo)
                // sí se cuenta, para que el bot se aleje si lo molestan desde ahí.
                set inEnemyFountain = isEnemy and IABrainMacro_IsInEnemyFountain(GetUnitX(enumUnit), GetUnitY(enumUnit), botOwner)

                // --- SENSOR DE AGGRO REAL (CERTEZA FÍSICA Y ESTIMACIÓN DE DAÑO) ---
                if isEnemy then
                    // Estimamos el daño base según la clasificación empírica proporcionada por el usuario
                    if isHero then
                        set enemyDamage = IAData_GetHeroEstimatedDamage(enumUnit)
                    elseif isStruct then
                        set enemyDamage = 85.0 // Promedio de Torre Vigía (75) y Ancestro Protector (95)
                    else
                        set enemyDamage = 25.0 // Promedio paramétrico de creeps Humanos y Orcos (20 a 30)
                    endif

                    // CERTEZA FÍSICA (ÍNDICE 1 del tracker): solo contamos el daño
                    // de una unidad si REALMENTE nos está atacando (su objetivo físico
                    // somos nosotros). Antes las TORRES eran excepción: sumaban amenaza
                    // por mera PROXIMIDAD (dist<750), así el bot huía ANTES de recibir un
                    // golpe; al re-acercarse por avanzar volvía a "ver peligro" y retro-
                    // cedía -> baile infinito avanzar/retroceder en el borde de la torre.
                    // Ahora la torre se trata IGUAL que héroes y creeps: primero te dispara
                    // (EVENT_ATTACKED registra el índice 1), recién entonces cuenta como
                    // amenaza. REACTIVO, no preventivo (lo pidió el usuario). Las torres de
                    // fuente que matan al instante NO dependen de esto: son keep-out por
                    // región (IsInEnemyFountain / GetFountainEscape), sistema aparte.
                    if IAUtils_GetUnitPhysicalTarget(enumUnit) == botUnit then
                        set incomingDamage = incomingDamage + (enemyDamage * damageReductionMult)
                        if isStruct then // [DEBUG_IA]
                            set dmgTower = dmgTower + (enemyDamage * damageReductionMult) // [DEBUG_IA]
                        elseif isHero then // [DEBUG_IA]
                            set dmgHero = dmgHero + (enemyDamage * damageReductionMult) // [DEBUG_IA]
                        else // [DEBUG_IA]
                            set dmgCreep = dmgCreep + (enemyDamage * damageReductionMult) // [DEBUG_IA]
                        endif // [DEBUG_IA]
                    endif

                    // --- SENSORES DE PRESIÓN LOCAL (héroes enemigos) ---
                    if isHero then
                        set enemyHeroesNear = enemyHeroesNear + 1
                        // ¿Me tiene de objetivo? (físico O intención de orden:
                        // la intención capta al que viene caminando hacia mí)
                        set physT = IAUtils_GetUnitPhysicalTarget(enumUnit)
                        set intentT = IAUtils_GetUnitTarget(enumUnit)
                        if physT == botUnit or intentT == botUnit then
                            set enemiesTargetingMe = enemiesTargetingMe + 1
                        endif
                        // AMENAZA ANTICIPADA: exceso de peligrosidad (tabla
                        // danger de IA_Data) de héroes a rango de combo. Se
                        // ACUMULA aquí y se APLICA tras el loop SOLO si estamos
                        // en inferioridad local (daño potencial, no recibido).
                        set heroDangerVal = IAData_GetHeroDanger(GetUnitTypeId(enumUnit))
                        if heroDangerVal >= DANGER_ANTICIPATE and dist <= DANGER_RADIUS then
                            set dangerExcess = dangerExcess + (heroDangerVal - 1.0) * enemyDamage * damageReductionMult * ANTICIPATE_HITS
                        endif
                    endif
                endif

                // --- PREDICCIÓN MATEMÁTICA (ORB WALKING & LAST HIT) ---
                if isHero then
                    set enumRegen = 2.5 // Regeneración base heroica estimada
                else
                    set enumRegen = 1.0 // Regeneración creep estimada
                endif

                set predictedTravelTime = IAUtils_GetProjectileTravelTime(botUnit, enumUnit)
                set totalDelay = predictedTravelTime + dynamicDamagePoint
                set predictedHP = enumHP + (enumRegen * totalDelay)

                // --- ZONA LETAL ---
                if amIMelee then
                    set lethalRange = myRange + 250.0
                else
                    set lethalRange = myRange + 450.0
                endif

                // Si estamos persiguiendo a nuestro objetivo actual, extendemos el rango focal.
                if enumUnit == lastTarget then
                    set lethalRange = lethalRange + 400.0
                endif

                if amIMelee then
                    set isLethalHero = (isHero and isEnemy and (predictedHP / enumMaxHP) < 0.20 and dist <= lethalRange)
                else
                    set isLethalHero = (isHero and isEnemy and (predictedHP / enumMaxHP) < 0.25 and dist <= lethalRange)
                endif

                // --- VETO DE PROFUNDIDAD: ¿este héroe está demasiado adentro? ---
                // Solo HÉROES enemigos y solo con el veto activo (F1 enemiga aún
                // protegida). dp = cuánto se metió MÁS ALLÁ del frente de asedio
                // hacia la base enemiga. DOS excepciones que LEVANTAN el veto:
                //   (1) REMATABLE en <= HUNT_LETHAL_HITS golpes, contando SU
                //       armadura (héroes = armadura + HP, no %): un kill casi
                //       seguro vale el dive. heroHitsToKill = HP / (miDaño * red).
                //   (2) ALIADO HUMANO (no bot) enfocándolo: si un jugador real ya
                //       se comprometió, me sumo al dive grupal (humanFocusGroup).
                // El daño entrante de este héroe se sigue contando aparte (de-aggro),
                // igual que con la fuente: si te pega estando vetado, te retiras solo.
                set tooDeepToHunt = false
                if vetoActive and isHero and isEnemy then
                    if botIsHuman then
                        set dp = GetUnitX(enumUnit) - siegeFrontX
                    else
                        set dp = siegeFrontX - GetUnitX(enumUnit)
                    endif
                    if dp > ENEMY_DEPTH_SLACK then
                        set tooDeepToHunt = true
                        // (1) golpes-para-matar CON armadura (fórmula nativa WC3).
                        set enemyArmorEst = IAData_GetHeroEstimatedArmor(enumUnit)
                        if enemyArmorEst >= 0.0 then
                            set enemyDmgRed = 1.0 - ((enemyArmorEst * 0.06) / (1.0 + (enemyArmorEst * 0.06)))
                        else
                            set enemyDmgRed = 1.0 - (enemyArmorEst * 0.06)
                        endif
                        set heroHitsToKill = 99999.0
                        if myDamage * enemyDmgRed > 0.01 then
                            set heroHitsToKill = enumHP / (myDamage * enemyDmgRed)
                        endif
                        if heroHitsToKill <= HUNT_LETHAL_HITS then
                            set tooDeepToHunt = false
                            set brain.dbgExemptReason = 1 // [DEBUG_IA] rematable
                            set brain.dbgExemptHits = heroHitsToKill // [DEBUG_IA] golpes estimados (para falsar "math rota")
                        elseif IsUnitInGroup(enumUnit, humanFocusGroup) then
                            set tooDeepToHunt = false
                            set brain.dbgExemptReason = 2 // [DEBUG_IA] aliado humano
                        endif
                        // [DEBUG_IA] héroe profundo que una excepción dejó cazar.
                        if not tooDeepToHunt then
                            set brain.dbgExemptCount = brain.dbgExemptCount + 1
                            set brain.dbgExemptDp = dp
                        endif
                    endif
                    // [DEBUG_IA] registra el caso vetado borderline (menor dp).
                    if tooDeepToHunt then
                        set brain.dbgVetoCount = brain.dbgVetoCount + 1
                        if brain.dbgVetoCount == 1 or dp < brain.dbgVetoDp then
                            set brain.dbgVetoDp = dp
                        endif
                    endif
                endif

                // --- SELECCION NIVEL 1 (LAST HIT / KILL) ---
                if not inEnemyFountain and not tooDeepToHunt and ((not amIMelee) or isHero or (dist <= myRange + 150.0)) then
                    if (isEnemy and (predictedHP <= myDamage or isLethalHero)) or (not isEnemy and predictedHP <= myDamage and (enumHP / enumMaxHP) <= 0.30 and not isHero) then
                        if isHero and isEnemy then
                            if (killTarget == null) or (not IsUnitType(killTarget, UNIT_TYPE_HERO)) or (predictedHP < lowestKillHP) then
                                set lowestKillHP = predictedHP
                                set killTarget = enumUnit
                            endif
                        else
                            if (killTarget == null) or ((not IsUnitType(killTarget, UNIT_TYPE_HERO)) and predictedHP < lowestKillHP) then
                                set lowestKillHP = predictedHP
                                set killTarget = enumUnit
                            endif
                        endif
                    endif
                endif

                // --- SELECCION NIVEL 2 (ESTÁNDAR) ---
                if isEnemy and not inEnemyFountain and not tooDeepToHunt and (killTarget == null or isHero) then

                    // FILTRO MELEE INTELIGENTE:
                    if (not amIMelee) or (isHero) or (dist < 300.0) or (enumUnit == lastTarget) then

                        set currentScore = 0.0

                        if isStruct and (enumHP / enumMaxHP) < 0.15 then
                            set currentScore = 5000.0 + (enumMaxHP - enumHP)
                            set safetyPenalty = dist * 0.2
                        elseif isHero then

                            // FUSIÓN min() DE PENALIZACIONES: cada oportunidad PROPONE
                            // una penalización y se conserva la MENOR. Antes se
                            // sobreescribían en cadena y el ORDEN de los bloques
                            // cambiaba el resultado (p.ej. el harass dejaba penalty=0
                            // y el bloque de baja vida la volvía a SUBIR a dist*0.2).
                            if amIMelee then
                                // --- LÓGICA MELEE ---
                                set currentScore = 240.0 + ( (1.0 - (enumHP/enumMaxHP)) * 300.0 )
                                set safetyPenalty = dist * 0.9 // Penalización altísima, no persigue si está lejos.

                                // OPORTUNIDAD INDIVIDUAL: CC o baja vida (< 40%)
                                if (enumHP / enumMaxHP) < 0.40 then
                                    set currentScore = currentScore + 200.0
                                    set candPenalty = dist * 0.4
                                    if candPenalty < safetyPenalty then
                                        set safetyPenalty = candPenalty
                                    endif
                                endif

                                // OPORTUNIDAD GRUPAL (ASISTENCIA): Si mis amigos le pegan, me sumo.
                                // effectiveFocus pondera: el blanco de un humano pesa más que el de un bot.
                                if enumUnit == teamFocusTarget then
                                    set currentScore = currentScore + (150.0 * effectiveFocus)
                                    set candPenalty = dist * 0.5
                                    if candPenalty < safetyPenalty then
                                        set safetyPenalty = candPenalty
                                    endif
                                endif

                            else
                                // --- LÓGICA RANGO ---
                                set currentScore = 260.0 + ( (1.0 - (enumHP/enumMaxHP)) * 400.0 )
                                set safetyPenalty = dist * 0.6

                                // HARASS UNIVERSAL (Prioridad a Héroes a rango natural)
                                if dist <= myRange then
                                    set currentScore = currentScore + 200.0
                                    set safetyPenalty = 0.0
                                endif

                                // OPORTUNIDAD INDIVIDUAL: Vida por debajo de la mitad (< 50%)
                                if (enumHP / enumMaxHP) < 0.50 then
                                    set currentScore = currentScore + 250.0
                                    set candPenalty = dist * 0.2
                                    if candPenalty < safetyPenalty then
                                        set safetyPenalty = candPenalty
                                    endif
                                endif

                                // OPORTUNIDAD GRUPAL (ASISTENCIA): Si mis amigos disparan, yo también.
                                // effectiveFocus pondera: el blanco de un humano pesa más que el de un bot.
                                if enumUnit == teamFocusTarget then
                                    set currentScore = currentScore + (300.0 * effectiveFocus)
                                    set candPenalty = dist * 0.1
                                    if candPenalty < safetyPenalty then
                                        set safetyPenalty = candPenalty
                                    endif
                                endif
                            endif

                            // BONUS DE CAZA: persecución ya comprometida (lastTarget)
                            // que puedo terminar YO. Golpes-para-matar con MI daño
                            // MODELADO contra SU armadura (fórmula nativa WC3, misma
                            // que la excepción del veto). Antes se usaba el delta de
                            // HP observado, que mezclaba el daño de TODO el equipo
                            // caído en la ventana de 0.1s (un nuke aliado parecía un
                            // golpe propio gigante => el bot solo se sobre-comprometía
                            // contra tanques). El delta observado SIGUE alimentando la
                            // RAMPA DE TOLERANCIA más abajo: ahí "progreso real del
                            // equipo sobre el target" sí es la señal correcta.
                            if enumUnit == lastTarget then
                                set enemyArmorEst = IAData_GetHeroEstimatedArmor(enumUnit)
                                if enemyArmorEst >= 0.0 then
                                    set enemyDmgRed = 1.0 - ((enemyArmorEst * 0.06) / (1.0 + (enemyArmorEst * 0.06)))
                                else
                                    set enemyDmgRed = 1.0 - (enemyArmorEst * 0.06)
                                endif
                                if myDamage * enemyDmgRed > 0.01 then
                                    set hitsToKill = enumHP / (myDamage * enemyDmgRed)
                                    if hitsToKill <= 2.0 then
                                        set currentScore = currentScore + 1000.0
                                        set candPenalty = dist * 0.05
                                    elseif hitsToKill <= 3.0 then
                                        set currentScore = currentScore + 800.0
                                        set candPenalty = dist * 0.1
                                    elseif hitsToKill <= 4.0 then
                                        set currentScore = currentScore + 600.0
                                        set candPenalty = dist * 0.15
                                    elseif hitsToKill <= 5.0 then
                                        set currentScore = currentScore + 400.0
                                        set candPenalty = dist * 0.2
                                    else
                                        set candPenalty = safetyPenalty
                                    endif
                                    if candPenalty < safetyPenalty then
                                        set safetyPenalty = candPenalty
                                    endif
                                endif
                            endif

                            // (d) MODULADOR DE PELIGROSIDAD POR HÉROE:
                            // Héroes marcados como peligrosos en IAData escalan la
                            // penalización de seguridad (el bot guarda más distancia).
                            // Default = 1.0 => SIN efecto hasta poblar la tabla.
                            // COMPONENTE ADITIVA (dist*0.10 por punto de exceso):
                            // garantiza efecto aunque la penalización venga en 0 —
                            // antes penalty=0 (harass en rango) * danger ANULABA la
                            // tabla justo cuando el peligroso estaba más cerca.
                            set heroDangerVal = IAData_GetHeroDanger(GetUnitTypeId(enumUnit))
                            set safetyPenalty = (safetyPenalty + dist * 0.10 * (heroDangerVal - 1.0)) * heroDangerVal
                            if safetyPenalty < 0.0 then
                                set safetyPenalty = 0.0 // danger < 1.0 anima, pero nunca bonifica
                            endif

                        elseif isStruct then
                            set currentScore = 400.0 - enumHP
                            set safetyPenalty = dist * 0.2
                        else
                            set currentScore = 200.0 + (100.0 - (enumHP / enumMaxHP) * 100.0)
                            set safetyPenalty = dist * 0.2
                        endif

                        // Aplicar la penalización
                        set currentScore = currentScore - safetyPenalty

                        // Persistencia
                        if enumUnit == lastTarget then
                            set currentScore = currentScore + 50.0
                        endif

                        if currentScore > bestStandardScore then
                            set bestStandardScore = currentScore
                            set standardTarget = enumUnit
                        endif
                    endif
                endif

            endif
        endloop
        call DestroyGroup(g)
        set g = null
        call DestroyGroup(humanFocusGroup) // [VETO] grupo de foco humano
        set humanFocusGroup = null

        // [PASIVO] Melee sin su 1ª armadura: APAGAR toda la ofensiva del Utility-AI
        // (farm/last-hit/deny/harass/persecución) anulando los objetivos ANTES de
        // resolver attackTarget y la observación de daño. Así attackTarget queda
        // null (la FSM no atacará, la observación se limpia y la tolerancia se
        // queda en base => de-aggro limpio). El posicionamiento tras la línea lo
        // resuelve ExecutePassiveLaning (fase ACTUAR). Esto SOLO corre mientras el
        // cerrojo está cerrado; tras la 1ª armadura no se ejecuta nunca más.
        if passiveActive then
            set killTarget = null
            set standardTarget = null
            call ComputePassiveAnchor(botUnit, botOwner, botLane, brain)
        endif

        // ============================================================
        // AMENAZA REAL + ANTICIPADA (sensores)
        // ============================================================
        // (1) PÉRDIDA REAL: la estimación física de arriba (un golpe mitigado
        // por atacante con certeza física) es CIEGA a hechizos/dots/torres de
        // hechizo. La EMA de pérdida real (IA_Blackboard.UpdateHPTrack) lo ve
        // TODO. Tomamos el MAYOR de ambas (no se suman: el golpe físico ya
        // está dentro de la pérdida real; max() evita el doble conteo). Esto
        // hace que el de-aggro por tolerancia reaccione también a los nukes.
        if brain.selfLossRate > incomingDamage then
            set incomingDamage = brain.selfLossRate
        endif
        // (2) ANTICIPACIÓN (daño POTENCIAL, aún no recibido): solo en
        // INFERIORIDAD local. Con compañía no se anticipa (el Terror 1v1
        // asusta; con tu equipo al lado, se pelea).
        if dangerExcess > 0.0 and allyHeroesNear < enemyHeroesNear then
            set anticip = dangerExcess
            set incomingDamage = incomingDamage + anticip
        endif

        // ============================================================
        // ALIADO CONDENADO ("EL SIGUIENTE SOY YO")
        // ============================================================
        // El combate local está perdido: un aliado cercano cae en < ALLY_DOOM_T
        // al ritmo real medido, hay >=2 héroes enemigos cerca (focus de verdad
        // — en un 1v1 del aliado lo correcto es AYUDAR, no huir) y sin él
        // quedamos en igualdad o inferioridad. Pedimos retirada táctica AHORA,
        // aunque la vida esté llena. La ejecuta el canal del de-aggro (misma
        // histéresis de commit); si hay un kill-commit en curso (remate casi
        // seguro), el gate de IACore tiene prioridad y este flag se ignora.
        if minAllyT2D < ALLY_DOOM_T and enemyHeroesNear >= 2 and allyHeroesNear <= enemyHeroesNear then
            set brain.dangerRetreat = true
        endif

        // ============================================================
        // AVANCE AGRUPADO (WAR PARTY) — DECISIÓN
        // ============================================================
        // Late game (alguna F1 abierta): no avanzar solo. Grupo requerido =
        // min(héroes del equipo, 3). Histéresis WP_COMMIT: formado el grupo,
        // el push no se corta porque un compañero se rezague un instante.
        // La ORDEN (avanzar/reagrupar) la emite IssueAdvance leyendo esto.
        if IABrainMacro_IsWarPartyActive() then
            call IABrainMacro_UpdateWarPartyCache()
            set wpTotal = IABrainMacro_GetTeamTotalHeroes(botOwner)
            if wpTotal >= 2 then
                set wpActive = true
                set wpNeeded = wpTotal
                if wpNeeded > 3 then
                    set wpNeeded = 3
                endif
                if 1 + alliesClose >= wpNeeded then
                    set wpAdvanceOK = true
                    set brain.wpCommitUntil = currentTime + WP_COMMIT
                elseif currentTime < brain.wpCommitUntil then
                    set wpAdvanceOK = true
                else
                    set wpAdvanceOK = false
                    call IABrainMacro_ResolveRally(botUnit, botLane)
                    set brain.wpRallyX = IABrainMacro_GetWPRallyX()
                    set brain.wpRallyY = IABrainMacro_GetWPRallyY()
                endif
                set brain.wpGroupNeeded = wpNeeded

                // HOLD FIRE (standoff): en el cara-a-cara previo al choque, el
                // PRIMER golpe a un héroe lo decide un jugador HUMANO (él sabe
                // cuándo es el momento). Condición: nadie del equipo enganchó
                // aún (sin foco), hay >=2 héroes enemigos cerca y nadie me
                // ataca a mí (si me inician, me defiendo). Si el equipo no
                // tiene humanos vivos, los bots solo inician con superioridad
                // local. Los REMATES (killTarget) NUNCA se retienen.
                if teamFocusCount == 0 and enemyHeroesNear >= 2 and enemiesTargetingMe == 0 then
                    if IABrainMacro_GetTeamHumansAlive(botOwner) > 0 then
                        set wpHoldFire = true
                    elseif 1 + allyHeroesNear <= enemyHeroesNear then
                        set wpHoldFire = true
                    endif
                endif
            endif
        endif
        set brain.wpActive = wpActive
        set brain.wpAdvanceOK = wpAdvanceOK
        set brain.wpHoldFire = wpHoldFire

        // HOLD FIRE: anular el objetivo ESTÁNDAR si es héroe enemigo (el
        // harass también inicia la pelea). killTarget (remate) no se toca.
        if wpHoldFire and standardTarget != null and IsUnitType(standardTarget, UNIT_TYPE_HERO) and IsUnitEnemy(standardTarget, botOwner) then
            set standardTarget = null
        endif

        // --- TOMA DE DECISIÓN (sigue siendo PENSAR: nada de órdenes) ---

        // A2) PRIORIDAD ABSOLUTA DE HARASS:
        if standardTarget != null and IsUnitType(standardTarget, UNIT_TYPE_HERO) then
            if IAUtils_GetDistanceUnits(botUnit, standardTarget) <= myRange then
                if killTarget != null and not IsUnitType(killTarget, UNIT_TYPE_HERO) then
                    set killTarget = null
                endif
            endif
        endif

        // RESOLVER ATTACKTARGET (anticipado para observación y tolerancia)
        if killTarget != null then
            set attackTarget = killTarget
        elseif standardTarget != null then
            set attackTarget = standardTarget
        endif

        // ============================================================
        // SISTEMA DE OBSERVACIÓN DE DAÑO (Detección de Oportunidad)
        // ============================================================
        if attackTarget != null and IsUnitType(attackTarget, UNIT_TYPE_HERO) and IsUnitEnemy(attackTarget, botOwner) then
            set currentTargetHP = GetUnitState(attackTarget, UNIT_STATE_LIFE)
            set preAttackHP = brain.preAttackHP

            // DETECCIÓN DE CAMBIO DE TARGET
            if attackTarget != lastTarget then
                set observedDmgPerHit = 0.0
                set preAttackHP = 0.0
                set brain.observedDmgPerHit = 0.0
                if not decayActive then
                    set tolerance = TOLERANCE_BASE
                endif
                set decayActive = false
                set brain.decayActive = false
                // Nuevo objetivo => permitir re-sembrar el piso predictivo.
                set predCommitActive = false
                set brain.predCommitActive = false
            endif

            // OBSERVACIÓN DE DAÑO
            if preAttackHP > 0.01 and attackTarget == lastTarget then
                set hpDelta = preAttackHP - currentTargetHP
                if hpDelta > 0.0 then
                    if observedDmgPerHit < 0.01 or hpDelta >= observedDmgPerHit * 0.5 then
                        set observedDmgPerHit = hpDelta
                        set brain.observedDmgPerHit = observedDmgPerHit

                        // ESCALAR TOLERANCIA (una vez por golpe significativo)
                        set hitsToKill = currentTargetHP / observedDmgPerHit
                        if hitsToKill <= 2.0 then
                            set tolerance = tolerance + 5.0
                        elseif hitsToKill <= 3.0 then
                            set tolerance = tolerance + 4.0
                        elseif hitsToKill <= 4.0 then
                            set tolerance = tolerance + 3.0
                        elseif hitsToKill <= 5.0 then
                            set tolerance = tolerance + 2.0
                        elseif hitsToKill <= 7.0 then
                            set tolerance = tolerance + 1.0
                        endif

                        if tolerance > TOLERANCE_MAX then
                            set tolerance = TOLERANCE_MAX
                        endif

                        // ¿Alcanzamos el máximo? Activar Decay
                        if tolerance >= TOLERANCE_MAX and not decayActive then
                            set decayActive = true
                            set lastDecayCheckTime = currentTime
                            set decayBaselineHP = currentTargetHP
                            set brain.decayActive = true
                            set brain.lastDecayCheckTime = lastDecayCheckTime
                            set brain.decayBaselineHP = decayBaselineHP
                        endif
                    endif
                endif
            endif

            // Actualizar snapshot SIEMPRE (baseline para el siguiente frame)
            set brain.preAttackHP = currentTargetHP

        else
            // No atacamos héroe enemigo: limpiar observación si había
            if observedDmgPerHit > 0.0 then
                set observedDmgPerHit = 0.0
                set brain.observedDmgPerHit = 0.0
                set brain.preAttackHP = 0.0
                if not decayActive then
                    set tolerance = TOLERANCE_BASE
                endif
                set decayActive = false
                set brain.decayActive = false
            endif
            // Sin héroe enemigo de target: el compromiso predictivo termina.
            if predCommitActive then
                set predCommitActive = false
                set brain.predCommitActive = false
            endif
        endif

        // ============================================================
        // SISTEMA DE DECAY (Anti-Persecución Infinita)
        // ============================================================
        if decayActive and attackTarget != null then
            if currentTime - lastDecayCheckTime >= DECAY_INTERVAL then
                set allyAssisting = (teamFocusTarget == attackTarget and teamFocusCount > 0)

                if allyAssisting then
                    // En equipo: NO decrementar, solo resetear timer
                    set lastDecayCheckTime = currentTime
                    set decayBaselineHP = GetUnitState(attackTarget, UNIT_STATE_LIFE)
                else
                    set currentTargetHP = GetUnitState(attackTarget, UNIT_STATE_LIFE)
                    if currentTargetHP < decayBaselineHP then
                        // SÍ hizo daño: mantener tolerancia, resetear timer
                        set decayBaselineHP = currentTargetHP
                        set lastDecayCheckTime = currentTime
                    else
                        // NO hizo daño: bajar tolerancia
                        set tolerance = tolerance - DECAY_AMOUNT
                        set lastDecayCheckTime = currentTime
                        set decayBaselineHP = currentTargetHP

                        if tolerance < 0.0 then
                            set tolerance = 0.0
                        endif
                        // DECAY AGOTADO => SOLTAR LA PRESA. Antes solo bajaba el
                        // umbral de de-aggro: si NADIE me pegaba (perseguir a un
                        // héroe que huye sin devolver daño), la caza seguía por
                        // inercia hasta que la distancia erosionara el score.
                        // Ahora, sin progreso de daño y sin aliados asistiendo,
                        // el target se descarta y el scoring re-decide de cero.
                        if tolerance <= 0.0 then
                            set brain.lastTarget = null
                        endif
                    endif
                endif

                set brain.lastDecayCheckTime = lastDecayCheckTime
                set brain.decayBaselineHP = decayBaselineHP
            endif
        endif

        // ============================================================
        // BONUS DE EQUIPO (Tolerancia mínima en Team Focus)
        // ============================================================
        set myHPPct = GetUnitState(botUnit, UNIT_STATE_LIFE) / GetUnitState(botUnit, UNIT_STATE_MAX_LIFE)

        if attackTarget != null and attackTarget == teamFocusTarget and teamFocusCount > 0 then
            if myHPPct > 0.40 and tolerance < TOLERANCE_TEAM_MIN then
                set tolerance = TOLERANCE_TEAM_MIN
            endif
        endif

        // ============================================================
        // SIEMBRA PREDICTIVA DE TOLERANCIA (predecir-para-COMPROMETER)
        // ============================================================
        // Hermano del piso de team-focus de arriba, pero individual y PREDICTIVO:
        // si tengo a un héroe enemigo a ALCANCE y lo MODELO muerto en pocos golpes
        // (mi daño vs SU armadura estimada), siembro UNA vez un piso de tolerancia
        // ANTES de que la rampa OBSERVADA pueda medir el 1er golpe — así el
        // de-aggro no lo suelta antes de aterrizarlo. Armo el decay (baseline = HP
        // actual) para que una predicción que NO se cumple (sin progreso de HP en
        // DECAY_INTERVAL) se auto-corrija bajando la tolerancia. Una sola siembra
        // por objetivo (predCommitActive); decayActive lo persiste y la rampa
        // observada/decay toman el relevo. Gate myHPPct>0.40: por debajo, la
        // decisión de quedarse a rematar es del kill-commit, no de este piso.
        if not predCommitActive and myHPPct > 0.40 and attackTarget != null and IsUnitType(attackTarget, UNIT_TYPE_HERO) and IsUnitEnemy(attackTarget, botOwner) then
            set enemyArmorEst = IAData_GetHeroEstimatedArmor(attackTarget)
            if enemyArmorEst >= 0.0 then
                set enemyDmgRed = 1.0 - ((enemyArmorEst * 0.06) / (1.0 + (enemyArmorEst * 0.06)))
            else
                set enemyDmgRed = 1.0 - (enemyArmorEst * 0.06)
            endif
            if myDamage * enemyDmgRed > 0.01 and IAUtils_GetDistanceUnits(botUnit, attackTarget) <= myRange + ATTACK_REACH_SLACK then
                set currentTargetHP = GetUnitState(attackTarget, UNIT_STATE_LIFE)
                set hitsToKill = currentTargetHP / (myDamage * enemyDmgRed)
                set predFloor = 0.0
                if hitsToKill <= 2.0 then
                    set predFloor = PRED_FLOOR_2
                elseif hitsToKill <= 3.0 then
                    set predFloor = PRED_FLOOR_3
                elseif hitsToKill <= 4.0 then
                    set predFloor = PRED_FLOOR_4
                endif
                // Solo sembramos si SUBE el aguante (max(), no +=): no rebaja una
                // tolerancia ya rampada ni la compone en espiral.
                if predFloor > tolerance then
                    set tolerance = predFloor
                    // Armar decay para auto-corrección (predicción que no se cumple).
                    set decayActive = true
                    set lastDecayCheckTime = currentTime
                    set decayBaselineHP = currentTargetHP
                    set predCommitActive = true
                    set brain.decayActive = true
                    set brain.lastDecayCheckTime = lastDecayCheckTime
                    set brain.decayBaselineHP = decayBaselineHP
                    set brain.predCommitActive = true
                endif
            endif
        endif

        // GUARDAR TOLERANCIA (persistida SIN modular: la modulación de abajo
        // es solo del frame; si se persistiera recortada, la rampa de
        // observación realimentaría a la baja en espiral)
        set brain.tolerance = tolerance

        // TOLERANCIA EFECTIVA (recorte defensivo): cada héroe enemigo EXTRA
        // enfocándome recorta el aguante del frame un FOCUS_TOL_CUT. La rampa
        // ofensiva ("aguanto más si estoy por matarlo") se conserva intacta;
        // esto solo responde "¿cuántos me están cayendo encima?".
        set effTolerance = tolerance
        if enemiesTargetingMe >= 2 then
            set effTolerance = effTolerance * (1.0 - FOCUS_TOL_CUT * I2R(enemiesTargetingMe - 1))
            if effTolerance < 0.0 then
                set effTolerance = 0.0
            endif
        endif

        // CALCULAR UMBRAL DE DE-AGGRO
        set damageThreshold = GetUnitState(botUnit, UNIT_STATE_LIFE) * (effTolerance / 100.0)

        // ============================================================
        // HANDOFF -> PIZARRA: publicamos la decisión para la fase ACTUAR
        // ============================================================
        set brain.killTarget = killTarget
        set brain.standardTarget = standardTarget
        set brain.attackTarget = attackTarget
        set brain.incomingDamage = incomingDamage
        set brain.damageThreshold = damageThreshold
        // Sensores de presión local (los leen Survival contextual, kill-commit
        // y la capa de de-aggro/war party de ExecuteLaning):
        set brain.enemyHeroesNear = enemyHeroesNear
        set brain.allyHeroesNear = allyHeroesNear
        set brain.alliesClose = alliesClose
        set brain.enemiesTargetingMe = enemiesTargetingMe
        set brain.incomingAnticip = anticip
        set brain.dmgTower = dmgTower // [DEBUG_IA]
        set brain.dmgHero = dmgHero   // [DEBUG_IA]
        set brain.dmgCreep = dmgCreep // [DEBUG_IA]
        set brain.amIMelee = amIMelee
        set brain.passiveActive = passiveActive // [PASIVO]
        set brain.myRange = myRange
        set brain.myDamage = myDamage
        set brain.currentTime = currentTime
        set brain.windupEnd = windupEnd
        set brain.cooldownEnd = cooldownEnd
        set brain.dynamicCooldown = dynamicCooldown

        // Limpieza de locales (evitar leaks de referencias de unit/group)
        set enumUnit = null
        set killTarget = null
        set standardTarget = null
        set attackTarget = null
        set lastTarget = null
        set teamFocusTarget = null
        set allyTarget = null
        set physT = null
        set intentT = null
        set g = null
    endfunction

    // Emite la orden de AVANCE hacia el objetivo de empuje por FASES (ver
    // IABrainMacro_UpdateObjective). Reemplaza el viejo attack-move a la fuente
    // enemiga, que era la causa de que el bot se metiera a la fuente y muriera.
    // Usa "move" en reruteo (volver por la base propia) y "attack" en empuje.
    //
    // WAR PARTY (late game): respeta la DECISIÓN de Think publicada en la
    // pizarra. Sin grupo suficiente NO se avanza: se va al punto de reunión
    // (centroide del equipo fuera de base, o la defensa propia). Con grupo,
    // se adopta además el CARRIL DE LA MAYORÍA ("ir por donde van los
    // aliados, norte o sur"); el cruce seguro lo hace ApplyRerouteIfNeeded.
    private function IssueAdvance takes unit botUnit, player botOwner, integer botLane, integer currentOrder returns nothing
        local real dX
        local real dY
        local integer useLane = botLane
        local integer ml
        local LaningBrain brain = IABlackboard_GetLaningBrain(botUnit)

        if brain.wpActive then
            if not brain.wpAdvanceOK then
                // REAGRUPAR: move al rally. Anti-respam con eps (como el carril
                // pasivo): solo re-emitir si no voy en "move" o el rally se movió.
                if currentOrder != OrderId("move") or (((brain.wpRallyX - brain.wpLastIssuedX) * (brain.wpRallyX - brain.wpLastIssuedX) + (brain.wpRallyY - brain.wpLastIssuedY) * (brain.wpRallyY - brain.wpLastIssuedY)) > WP_REISSUE_EPS * WP_REISSUE_EPS) then
                    call IssuePointOrder(botUnit, "move", brain.wpRallyX, brain.wpRallyY)
                    set brain.wpLastIssuedX = brain.wpRallyX
                    set brain.wpLastIssuedY = brain.wpRallyY
                endif
                return
            endif
            // Avance agrupado: ir por el carril de la MAYORÍA del equipo.
            set ml = IABrainMacro_GetMajorityLane(botOwner)
            if ml != 0 then
                set useLane = ml
            endif
        endif

        if IABrainMacro_UpdateObjective(botUnit, useLane) then
            set dX = IABrainMacro_GetObjectiveX()
            set dY = IABrainMacro_GetObjectiveY()
            if IABrainMacro_GetObjectiveIsMove() then
                if currentOrder != OrderId("move") then
                    call IssuePointOrder(botUnit, "move", dX, dY)
                endif
            else
                if currentOrder != OrderId("attack") then
                    call IssuePointOrder(botUnit, "attack", dX, dY)
                endif
            endif
        else
            // Sin estructura enemiga desbloqueada y viva: empujar a la fortaleza.
            set dX = IABrainMacro_GetEnemyBaseX(botOwner)
            set dY = IABrainMacro_GetEnemyBaseY(botOwner)
            if currentOrder != OrderId("attack") then
                call IssuePointOrder(botUnit, "attack", dX, dY)
            endif
        endif
    endfunction

    // ============================================================
    //  [PASIVO] EJECUCIÓN DEL CARRIL PASIVO  (emite órdenes)
    // ============================================================
    // Melee sin su 1ª armadura: reemplaza a la FSM de combate. Se coloca tras la
    // línea de creeps y MANTIENE la posición (hold), sin farmear/perseguir. Tres
    // situaciones de DESTINO:
    //   * Hay ancla (creep enganchado)  -> PASSIVE_BEHIND tras el más rezagado.
    //   * No hay ancla                  -> su Fase 3 propia (espera con sus torres).
    //   * Sin F3/F2 propia viva (no pasa en early game) -> su fuente más cercana.
    // VIAJE con "move" (NO attack-move: nunca auto-ataca de camino). Al LLEGAR,
    // "holdposition": no se desplaza por nada (no abandona el puesto para farmear/
    // perseguir), aunque puede dar un golpe de auto-defensa si algo entra a su
    // rango. El hold se rompe solo cuando el de-aggro/Survival emiten "move" para
    // salvar la vida; al calmarse, re-viaja y re-mantiene. Histéresis park/unpark
    // para no temblar siguiendo a los creeps que se mueven/mueren cada frame.
    private function ExecutePassiveLaning takes unit botUnit, player botOwner, integer botLane, LaningBrain brain, integer currentOrder returns nothing
        local real destX
        local real destY
        local real dist
        local boolean justParked = false

        // --- Resolver destino ---
        if brain.passiveHasAnchor then
            set destX = brain.passiveAnchorX
            set destY = brain.passiveAnchorY
        elseif IABrainMacro_ResolveOwnDefense(botUnit, botLane) then
            set destX = IABrainMacro_GetOwnDefenseX()
            set destY = IABrainMacro_GetOwnDefenseY()
        else
            set destX = IABrainMacro_GetClosestHomeX(botUnit)
            set destY = IABrainMacro_GetClosestHomeY(botUnit)
        endif

        set dist = IAUtils_GetDistanceUnitXY(botUnit, destX, destY)

        // --- Histéresis park/unpark ---
        if brain.passiveParked then
            if dist > PASSIVE_UNPARK_DIST then
                set brain.passiveParked = false
            endif
        else
            if dist <= PASSIVE_ARRIVE_DIST then
                set brain.passiveParked = true
                set justParked = true
            endif
        endif

        if brain.passiveParked then
            // MANTENER POSICIÓN. Forzamos "hold" al llegar (justParked) aunque
            // viniera de un auto-ataque del viaje; después NO re-emitimos si ya
            // está en hold o auto-atacando en rango (no cancelar la auto-defensa,
            // que el usuario acepta porque NO desplaza). Solo re-holdeamos si quedó
            // en move/stop/idle (p.ej. tras soltarse de un de-aggro).
            if justParked or (currentOrder != OrderId("holdposition") and currentOrder != OrderId("attack") and currentOrder != OrderId("smart")) then
                call IssueImmediateOrder(botUnit, "holdposition")
            endif
        else
            // VIAJAR al destino con "move" (sin auto-atacar de camino). Anti-respam:
            // re-emitimos solo si no vamos ya en "move", o si el destino se movió
            // > PASSIVE_REISSUE_EPS desde lo último emitido (los creeps se desplazan).
            if currentOrder != OrderId("move") or (((destX - brain.passiveLastIssuedX) * (destX - brain.passiveLastIssuedX) + (destY - brain.passiveLastIssuedY) * (destY - brain.passiveLastIssuedY)) > PASSIVE_REISSUE_EPS * PASSIVE_REISSUE_EPS) then
                call IssuePointOrder(botUnit, "move", destX, destY)
                set brain.passiveLastIssuedX = destX
                set brain.passiveLastIssuedY = destY
            endif
        endif

        // El pasivo nunca arrastra foco ofensivo.
        set brain.lastTarget = null
    endfunction

    // ============================================================
    //  FASE 3: ACTUAR  (ÚNICO lugar que emite órdenes)
    // ============================================================
    public function ExecuteLaning takes unit botUnit, player botOwner, integer botLane returns nothing
        local LaningBrain brain = IABlackboard_GetLaningBrain(botUnit)
        local integer currentOrder = GetUnitCurrentOrder(botUnit)
        local real destX
        local real destY
        local boolean inAttackRange = false
        local boolean wantsToMove = false
        local boolean isRetreatingState = false
        local real nowTime = IAUtils_GetGameTime()
        // ¿hay daño fresco que supere la tolerancia ESTE frame? (vs. seguir
        // huyendo solo por la ventana de commit del de-aggro)
        local boolean freshDeaggro = false

        // ============================================================
        // GUARDIA DE FUENTE (MÁXIMA PRIORIDAD — antes que nada)
        // ============================================================
        // Si el bot entró o roza una fuente ENEMIGA, la torre de la fuente lo
        // mata en segundos: nada más importa este frame. Abortamos toda otra
        // lógica y lo sacamos radialmente de la zona. No corremos siquiera
        // Think() (no queremos decisiones tomadas dentro de la zona mortal).
        if IABrainMacro_GetFountainEscape(botUnit) then
            set destX = IABrainMacro_GetObjectiveX()
            set destY = IABrainMacro_GetObjectiveY()
            if currentOrder != OrderId("move") then
                call IssuePointOrder(botUnit, "move", destX, destY)
            endif
            set brain.lastTarget = null
            // HISTÉRESIS: commitea a seguir alejándose un instante más, aunque el
            // frame siguiente ya esté fuera del margen. Sin esto, "Avanzando"
            // (macro) lo re-apunta a la zona y rebota (ping-pong) + falso encierro.
            set brain.fountainEscapeUntil = nowTime + FOUNTAIN_ESCAPE_COMMIT
            // Un rebote de guardia NO es un encierro: corta el conteo de
            // reincidencia y cualquier Berserker armado por el ping-pong.
            set brain.breakoutCycle = 0
            set brain.berserkActive = false
            return
        endif

        // VENTANA DE COMMIT: ya salimos del margen pero seguimos alejándonos hacia
        // CASA propia para despejar la zona antes de que el macro (IssueAdvance)
        // nos vuelva a arrastrar. Así soltamos de verdad al héroe que se refugió y
        // la re-evaluación normal (assist/empuje) arranca limpia. El héroe en la
        // fuente ya está excluido del scoring, así que no se re-targetea solo.
        if nowTime < brain.fountainEscapeUntil then
            // Ordenamos al DESTINO REAL (fuente propia más cercana), NO a un punto
            // proyectado a 500 a vuelo de pájaro: ese hop intermedio podía caer sobre
            // tienda/montaña (terreno bloqueado) y clavar al bot contra la pared. El
            // pathfinder de WC3 rutea solo hasta la fuente, esquivando estructuras,
            // montañas y unidades. La dirección es la misma (hacia casa), así que la
            // histéresis de "soltar fuente" se conserva intacta.
            set destX = IABrainMacro_GetClosestHomeX(botUnit)
            set destY = IABrainMacro_GetClosestHomeY(botUnit)
            if currentOrder != OrderId("move") then
                call IssuePointOrder(botUnit, "move", destX, destY)
            endif
            set brain.lastTarget = null
            return
        endif

        // --- SENTIR + PENSAR (rellena la pizarra, sin órdenes) ---
        call IABlackboard_ResetBrainScratch(brain)
        call Think(botUnit, botOwner, botLane, brain)

        // ============================================================
        // GUARDIAS ANTI-ENCIERRO (3 capas + Berserker)
        // ============================================================
        // Orden estricto: BERSERKER -> DESPEJE EN RUTA -> ENCIERRO REAL.
        // Detalle completo en IA_Breakout.j.
        //
        // isRetreatingState: estamos huyendo en alguna forma (de-aggro este
        // frame, veníamos retirándonos, o seguimos dentro de la VENTANA DE
        // COMMIT del de-aggro). Esto cambia la métrica de "atascado" a eje X,
        // habilita el despeje en ruta (Capa 1) y —clave— mantiene apagada la
        // métrica rápida de combate (0.7s) durante el commit, que era la que
        // daba el falso "Encerrado" por el baile avanzar<->retroceder.
        // dangerRetreat ("aliado condenado") cuenta como huida: misma métrica
        // de atascado y mismo canal de ejecución que el de-aggro clásico.
        set isRetreatingState = (brain.incomingDamage >= brain.damageThreshold and brain.incomingDamage > 0.0) or brain.isRetreating or nowTime < brain.deaggroCommitUntil or brain.dangerRetreat

        // (1) BERSERKER: si está activo y emite orden, se lleva el frame.
        //     Si está activo pero no encontró héroe/invocación en rango,
        //     devuelve false y caemos al escape normal (manteniendo el modo).
        if brain.berserkActive then
            if IABreakout_ExecuteBerserk(botUnit, botOwner) then
                return
            endif
        endif

        // (2) DESPEJE EN RUTA: solo durante huida. Mata creeps estacionarios
        //     en el cono frontal que pueda matar en <=3 golpes.
        if isRetreatingState then
            if IABreakout_TryPathClear(botUnit, botOwner) then
                return
            endif
        endif

        // (3) ENCIERRO REAL: detecta atascado (eje X si huye, euclídeo si no),
        //     escanea anillo con prioridad y fuerza ataque. Maneja el contador
        //     de reincidencia y activa Berserker al 3er ciclo.
        set wantsToMove = isRetreatingState
        if not wantsToMove then
            if brain.passiveActive then
                // [PASIVO] manteniendo (hold) => NO "quiere moverse", así un bot
                // quieto tras la línea no dispara un falso "Encerrado". Viajando =>
                // sí quiere (el breakout sigue funcionando si se atasca de camino;
                // huyendo ya entra por isRetreatingState arriba).
                set wantsToMove = not brain.passiveParked
            elseif brain.attackTarget == null then
                set wantsToMove = true
            else
                // +ATTACK_REACH_SLACK (melee Y rango): el centro-a-centro a un
                // objetivo que sí está golpeando/disparando supera el rango crudo
                // por la colisión del objetivo. Mismo colchón para ambos: el
                // sobrepaso depende de la colisión del target, no del rango propio.
                set wantsToMove = (IAUtils_GetDistanceUnits(botUnit, brain.attackTarget) > brain.myRange + ATTACK_REACH_SLACK)
            endif
        endif

        // EXCEPCIÓN — PERSECUCIÓN DE HÉROE (no es encierro):
        // Si el sistema de puntaje (Think) decidió perseguir un HÉROE enemigo
        // que salió de rango, NO disparamos la Capa 2. Que un héroe se aleje no
        // nos atrapa: perseguir es una decisión deliberada, no un cerco. Un
        // melee solo debe rodear los creeps que le estorban el contacto; si el
        // creep cae en <=2 golpes lo despeja, y si no, dejamos que el MOTOR
        // rodee solo (la FSM "fuera de rango" emite attack y WC3 navega). El
        // rango ataca por encima de los creeps, así que ni siquiera despeja.
        // Así evitamos los falsos "Encerrado" al hostigar un héroe que retrocede.
        if (not isRetreatingState) and wantsToMove and brain.attackTarget != null and IsUnitType(brain.attackTarget, UNIT_TYPE_HERO) and IsUnitEnemy(brain.attackTarget, botOwner) then
            if brain.amIMelee then
                if IABreakout_TryChaseClear(botUnit, botOwner, brain.attackTarget) then
                    return
                endif
            endif
            // Sin despeje: caemos a la FSM (pathfinding nativo). NO Capa 2.
        else
            if IABreakout_Try(botUnit, botOwner, isRetreatingState, wantsToMove, currentOrder) then
                return
            endif
        endif

        // ============================================================
        // CAPA DE RETIRADA TÁCTICA (DE-AGGRO)
        // ============================================================
        // IMPORTANTE - DOS CAPAS DE RETIRADA DISTINTAS:
        //   * RETIRADA ESTRATÉGICA (ir a curarse): vive en IACore -> IAStateSurvival
        //     (estado 3). Dispara con HP < 40% y devuelve a laning con HP > 95%.
        //   * RETIRADA TÁCTICA / DE-AGGRO (esta): retroceso breve para soltar el
        //     aggro de creeps/torres cuando el daño entrante supera la tolerancia,
        //     SIN abandonar el carril ni ir a base.
        // Por el selector ESTRICTO de IACore.update(), solo una corre por frame:
        // si Survival está activo, ExecuteLaning ni siquiera se ejecuta. No hay
        // conflicto de órdenes entre ambas capas.
        // COMPROMISO DE REMATE (KILL-COMMIT): si el selector decidió que el equipo va a
        // cerrar un kill casi seguro y mi vida supera el piso, IGNORAMOS la retirada
        // táctica este frame para mantener el DPS sobre el foco. Cerramos cualquier
        // retirada en curso (re-engancha YA, sin el frame de "Volviendo al Farm") pero
        // NO reseteamos la tolerancia: queremos seguir peleando, y Think la sigue
        // rampando vía observación de daño. Scope quirúrgico: la guardia de fuente y los
        // 3 guardias de breakout/berserker (más arriba) ya corrieron y NO se saltan.
        // INVARIANTE: solo limpiamos isRetreating (igual que la salida normal del
        // de-aggro); no escribimos lastTarget. Al caer, la FSM normal de abajo atacará
        // a brain.attackTarget (= el foco, por el bonus de asistencia del scoring).
        if brain.killCommitActive then
            set brain.isRetreating = false
            // (no return: seguimos a la FSM de combate normal)
        else

            // Daño fresco que supera la tolerancia ESTE frame -> (re)arma el commit.
            // dangerRetreat ("aliado condenado", lo decide Think) dispara el MISMO
            // canal: mientras la condición se sostenga, el commit se re-arma cada
            // frame y el bot sigue alejándose aunque tenga la vida llena.
            set freshDeaggro = (brain.incomingDamage >= brain.damageThreshold and brain.incomingDamage > 0.0) or brain.dangerRetreat
            if freshDeaggro then
                set brain.deaggroCommitUntil = nowTime + DEAGGRO_COMMIT
            endif

            // RETIRADA TÁCTICA con HISTÉRESIS: huimos si hay daño fresco O si seguimos
            // dentro de la ventana de commit. La ventana evita el baile avanzar<->
            // retroceder: una vez disparado el de-aggro, el bot se compromete a
            // alejarse aunque la torre deje de pegarle entre golpes (el desplazamiento
            // neto ~0 de ese baile era justo lo que disparaba el falso "Encerrado").
            // Mismo patrón que FOUNTAIN_ESCAPE_COMMIT. Se re-arma con cada golpe nuevo.
            if freshDeaggro or nowTime < brain.deaggroCommitUntil then

                // RETIRADA TÁCTICA: ordenamos al DESTINO REAL (fuente propia más cercana
                // vía GetClosestHome), NO a un punto proyectado a 500 a vuelo de pájaro.
                // Ese hop intermedio se recalculaba cada frame y, en zona enemiga, caía
                // sobre tienda/montaña (blk=1), clavando al bot contra la pared mientras
                // su vector "a vuelo de pájaro" seguía apuntando hacia dentro del muro.
                // Apuntando a la fuente, el pathfinder de WC3 rodea solo todo obstáculo.
                // NO vamos a "llegar" a casa: la ventana de commit / caída del daño libera
                // el de-aggro mucho antes (igual que con el hop). La distancia de retroceso
                // NO cambia; solo se arregla el ruteo.
                set destX = IABrainMacro_GetClosestHomeX(botUnit)
                set destY = IABrainMacro_GetClosestHomeY(botUnit)

                if (currentOrder != OrderId("move")) then
                    call IssuePointOrder(botUnit, "move", destX, destY)
                endif

                // GUARDAMOS ESTADO: "Estoy retirándome" + olvidar foco ofensivo
                set brain.isRetreating = true
                set brain.lastTarget = null
                set brain.observedDmgPerHit = 0.0
                set brain.preAttackHP = 0.0
                return
            endif
        endif // cierra el if/else del COMPROMISO DE REMATE (kill-commit)

        // ============================================================
        // [PASIVO] CARRIL PASIVO (MELEE SIN SU 1ª ARMADURA)
        // ============================================================
        // Reemplaza la FSM de combate: el bot no ataca/farmea/persigue, solo se
        // coloca tras la línea de creeps y mantiene. El de-aggro (arriba) ya tuvo
        // prioridad este frame; Survival/Shopping son estados aparte (IACore). Al
        // conseguir su 1ª armadura, brain.passiveActive pasa a false PARA SIEMPRE y
        // este bloque deja de ejecutarse: el héroe continúa por la FSM normal de
        // abajo, exactamente como si este sistema no existiera.
        if brain.passiveActive then
            // Si veníamos huyendo y el de-aggro ya no dispara, cerramos la retirada
            // igual que "Volviendo al Farm" (reset de tolerancia/observación).
            if brain.isRetreating then
                set brain.isRetreating = false
                set brain.tolerance = TOLERANCE_BASE
                set brain.decayActive = false
                set brain.observedDmgPerHit = 0.0
                set brain.preAttackHP = 0.0
            endif
            call ExecutePassiveLaning(botUnit, botOwner, botLane, brain, currentOrder)
            return
        endif

        // El De-Aggro NO se activó este frame. ¿Veníamos huyendo?
        if brain.isRetreating then
            // Logramos escapar del foco (o el enemigo murió). Volvemos al farm.
            set brain.isRetreating = false

            // RESET TOLERANCIA: Restaurar al estado base después de escapar
            set brain.tolerance = TOLERANCE_BASE
            set brain.decayActive = false
            set brain.observedDmgPerHit = 0.0
            set brain.preAttackHP = 0.0

            // [SEMILLA LATE-GAME] TODO: antes de volver al farm, verificar si
            // estamos en zona enemiga sin aliados cercanos (no pushear solo).

            call IssueAdvance(botUnit, botOwner, botLane, currentOrder)
            return // No ejecutar FSM este frame; dar tiempo a estabilizarse.
        endif

        // ==========================================================
        // MÁQUINA DE ESTADOS FINITOS DE COMBATE (FSM)
        // ==========================================================
        // attackTarget ya viene resuelto desde PENSAR (brain.attackTarget).

        // CORRECCIÓN BUG 1: COMPUERTA DE RANGO
        // La FSM de timing SOLO se activa si estamos dentro del rango de ataque.
        if brain.attackTarget != null then
            if brain.amIMelee then
                set inAttackRange = (IAUtils_GetDistanceUnits(botUnit, brain.attackTarget) <= brain.myRange)
            else
                set inAttackRange = (IAUtils_GetDistanceUnits(botUnit, brain.attackTarget) <= brain.myRange + 50.0)
            endif
        endif

        if inAttackRange then
            // --- FSM ACTIVA (Dentro de rango) ---

            // 2. WINDUP (Cargando el golpe + margen de giro)
            if brain.currentTime < brain.windupEnd then
                return
            endif

            // 3. BACKSWING / ORB WALKING (Residuos de animación)
            if brain.currentTime >= brain.windupEnd and brain.currentTime < brain.cooldownEnd then
                if brain.attackTarget != null and IAUtils_GetDistanceUnits(botUnit, brain.attackTarget) > brain.myRange then
                    // Si corre, lo seguimos agresivamente
                    if currentOrder != OrderId("move") then
                        call IssueTargetOrder(botUnit, "move", brain.attackTarget)
                    endif
                else
                    // Reposicionamiento / Amague (Kite/S-Tap)
                    // FALLA A+B+C (orb-walk): el kite ahora retrocede hacia la
                    // FUENTE PROPIA más cercana (GetClosestHome) y deja rutear al
                    // MOTOR (move al punto real, NO a un hop proyectado). Antes
                    // proyectaba 300 crudos en sentido opuesto a la base ENEMIGA
                    // (GetLaneTarget): (A) dirección equivocada pegado al castillo
                    // —la fuente está en Y, no en X— y punto SIN pathing que caía
                    // sobre montaña/tienda y CLAVABA al bot (mismo bug ya resuelto
                    // en el de-aggro táctico de abajo); (B) los 300 sacaban al
                    // objetivo del rango -> reaproximar -> perdía DPS. Apuntando a
                    // la fuente, el desplazamiento queda ACOTADO por la ventana de
                    // backswing (al llegar cooldownEnd vuelve a disparar), así que
                    // no hay hop fijo que sobrepase el rango. (C) Solo kitea contra
                    // un HÉROE ENEMIGO: contra creeps/torres se queda quieto (Hold)
                    // y mantiene el DPS/last-hit en vez de alejarse de algo que no
                    // lo persigue (el aggro de creeps ya lo cubre el de-aggro).
                    if brain.attackTarget != null and not brain.amIMelee and IsUnitType(brain.attackTarget, UNIT_TYPE_HERO) and IsUnitEnemy(brain.attackTarget, botOwner) and IAUtils_GetDistanceUnits(botUnit, brain.attackTarget) <= brain.myRange * 0.5 then
                        // Kite hacia la fuente propia (retroceder disparando)
                        set destX = IABrainMacro_GetClosestHomeX(botUnit)
                        set destY = IABrainMacro_GetClosestHomeY(botUnit)
                        if currentOrder != OrderId("move") then
                            call IssuePointOrder(botUnit, "move", destX, destY)
                        endif
                    else
                        // Hold position / Amague
                        if currentOrder != OrderId("stop") then
                            call IssueImmediateOrder(botUnit, "stop")
                        endif
                    endif
                endif
                return // Impide ejecutar órdenes de ataque
            endif

            // 4. PRE-ATAQUE / RECUPERADO (Arma lista para disparar)
            if brain.currentTime >= brain.cooldownEnd then

                if brain.attackTarget != null then
                    // S-Tap Amague (Si el Last Hit aún no está en rango letal preciso, detenemos el disparo)
                    if brain.attackTarget == brain.killTarget then
                        if GetUnitState(brain.attackTarget, UNIT_STATE_LIFE) > brain.myDamage and (not IsUnitEnemy(brain.attackTarget, botOwner) or not IsUnitType(brain.attackTarget, UNIT_TYPE_HERO)) then
                            if currentOrder != OrderId("stop") then
                                call IssueImmediateOrder(botUnit, "stop")
                            endif
                            // (S-Tap) coherente con cooldownEnd SIN margen (Falla D):
                            // retrasa lastAttackTime para re-evaluar el last-hit en ~0.1s.
                            set brain.lastAttackTime = brain.currentTime - brain.dynamicCooldown + 0.1
                            return
                        endif
                    endif

                    // Ejecutamos DISPARO LETAL ESTÁNDAR
                    if (currentOrder != OrderId("attack") and currentOrder != OrderId("smart")) or (brain.attackTarget != brain.lastTarget) then
                        call IssueTargetOrder(botUnit, "attack", brain.attackTarget)
                        set brain.lastTarget = brain.attackTarget
                        set brain.lastAttackTime = brain.currentTime
                    else
                        // SYNC FSM: el héroe ya atacaba a este objetivo (orden Legacy).
                        set brain.lastAttackTime = brain.currentTime
                    endif

                    // D) SIN OBJETIVOS CERCANOS: AVANZAR (empuje por fases)
                else
                    set brain.lastTarget = null
                    call IssueAdvance(botUnit, botOwner, botLane, currentOrder)
                endif
            endif

        else
            // --- FUERA DE RANGO: Modo Legacy (sin FSM) ---
            // Dejamos que WC3 maneje el pathfinding sin interferir.
            if brain.attackTarget != null then
                if (currentOrder != OrderId("attack") and currentOrder != OrderId("smart")) or (brain.attackTarget != brain.lastTarget) then
                    call IssueTargetOrder(botUnit, "attack", brain.attackTarget)
                    set brain.lastTarget = brain.attackTarget
                    // NO guardar lastAttackTime aquí — el héroe aún camina.
                endif
            else
                set brain.lastTarget = null
                call IssueAdvance(botUnit, botOwner, botLane, currentOrder)
            endif
        endif
    endfunction

endlibrary
