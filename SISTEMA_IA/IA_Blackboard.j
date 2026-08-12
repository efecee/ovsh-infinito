library IABlackboard

    // ============================================================
    // PIZARRA (BLACKBOARD) DE COMPORTAMIENTO DE CARRIL
    // ============================================================
    // Patrón estándar de IA de juegos: una sola estructura tipada por bot
    // que TODAS las fases del comportamiento de laning leen y escriben.
    //
    // Sustituye a la antigua hashtable IA_Laning_Memory con sus 9 "claves
    // mágicas" (key 0..8). Ahora cada dato tiene NOMBRE y DUEÑO claro, lo que
    // elimina la fuente principal de bugs en cascada: estado disperso sin
    // ownership.
    //
    // DIVISIÓN DE CAMPOS:
    //   - PERSISTENTES: sobreviven entre ciclos (memoria real del bot).
    //   - SCRATCH (por frame): canal de comunicación entre la fase PENSAR
    //     y la fase ACTUAR dentro de un mismo ciclo. Think() los rellena,
    //     ExecuteLaning() los consume. Se resetean al inicio de cada Think().
    //
    // NOTA DE MEMORIA (vJASS 1.27b): nunca destruimos un LaningBrain (uno por
    // unidad, vive para siempre). Por eso cada instancia usa un id nuevo cuyo
    // backing-array arranca en 0/null/false, igual que un Load* sobre una
    // clave nunca escrita. No hace falta inicializar los miembros a mano.
    // ============================================================

    globals
        private hashtable BRAIN_TABLE = InitHashtable()
    endglobals

    struct LaningBrain
        // ----- PERSISTENTE (memoria entre ciclos) -----
        unit    lastTarget          // (antes key 0) objetivo ofensivo recordado
        boolean isRetreating        // (antes key 1) ¿estábamos en de-aggro táctico?
        real    lastAttackTime      // (antes key 2) reloj FSM del último ataque
        real    tolerance           // (antes key 3) % de HP tolerado como umbral de-aggro
        real    preAttackHP         // (antes key 4) snapshot de HP del target el frame previo
        real    observedDmgPerHit   // (antes key 5) daño observado por golpe contra el target
        real    lastDecayCheckTime  // (antes key 6) último chequeo del decay anti-persecución
        boolean decayActive         // (antes key 7) ¿decay activo? (tolerancia en el techo)
        real    decayBaselineHP     // (antes key 8) HP de referencia para medir progreso del decay
        // SIEMBRA PREDICTIVA DE TOLERANCIA (predecir-para-COMPROMETER): ¿ya
        // sembramos el piso de tolerancia para el target actual? Se siembra UNA
        // vez por objetivo (cold-start: antes del 1er golpe medido) y se limpia
        // al cambiar/soltar el target. Evita re-bombear la tolerancia cada frame
        // (dejaría que el decay auto-corrija una predicción que no se cumple).
        boolean predCommitActive

        // ----- ESCAPE DE FUENTE ENEMIGA (histéresis) — persistente -----
        // Reloj hasta el cual el bot sigue comprometido a alejarse de una fuente
        // enemiga tras rozarla, aunque ya esté fuera del margen. Rompe el ping-pong
        // Avanzando<->FUENTE. Lo escribe/lee la guardia de fuente en ExecuteLaning.
        real    fountainEscapeUntil

        // ----- HISTÉRESIS DEL DE-AGGRO TÁCTICO — persistente -----
        // Mismo patrón que fountainEscapeUntil: al dispararse el de-aggro, el bot
        // se COMPROMETE a alejarse hasta este reloj aunque la torre/creep deje de
        // pegarle entre golpes. Evita el baile avanzar<->retroceder en el borde de
        // torre (net displacement ~0 que disparaba falsos "Encerrado"). Lo
        // escribe/lee la capa de de-aggro en ExecuteLaning.
        real    deaggroCommitUntil

        // ----- ANTI-ENCIERRO (BREAKOUT) — persistente -----
        // Sistema en 3 capas (ver IA_Breakout.j):
        //   1) Despeje en ruta (huyendo): mata creeps en el camino que pueda
        //      eliminar en <=3 golpes; si no, rodea; si en 4s no se acerca a casa
        //      (distancia X+Y), fuerza el ataque sin importar los golpes.
        //   2) Encierro real: 0.7s sin progreso + intención de moverse =>
        //      rompe atacando al más débil en la dirección de salida.
        //   3) Contador 1-2-3 con ventana de 2s entre encierros consecutivos:
        //      al 3er encierro entra BERSERKER (ver berserkActive).
        // Estos campos NO se tocan en ResetBrainScratch.
        real    lastPosX            // posición de referencia para medir progreso
        real    lastPosY
        real    stuckRefTime        // momento del último progreso real (reloj FSM)
        boolean breakoutActive      // ¿estamos rompiendo un encierro ahora mismo?
        unit    breakoutTarget      // víctima del breakout (canal propio, NO es lastTarget)
        real    breakoutStartTime   // cuándo empezó el breakout (para timeout)
        real    breakoutRefX        // posición al iniciar (para medir si ya nos liberamos)
        real    breakoutRefY
        real    breakoutPathCheckTime // throttle del chequeo "camino libre" (CHANGE C): el corredor se re-escanea cada CORRIDOR_RECHECK s, no cada tick

        // --- DETECCIÓN DE PROGRESO DE HUIDA (acercamiento a casa, X+Y) ---
        real    xRef                // distancia a casa en la última referencia (mide acercamiento)
        real    xRefTime            // momento de la última referencia de distancia

        // --- CONTADOR DE REINCIDENCIA Y BERSERKER ---
        integer breakoutCycle       // 0=libre, 1=primer encierro, 2=segundo, 3=trigger berserker
        real    lastBreakoutEndTime // cuándo terminó el último breakout (ventana 2s)
        boolean berserkActive       // modo "aceptar muerte y matar" activo
        real    berserkEntryX       // posición al entrar (para exit por desplazamiento>=600)
        real    berserkEntryY
        unit    berserkTarget       // héroe/invocación elegido en berserker

        // ----- COMPROMISO DE REMATE (KILL-COMMIT) — persistente -----
        // Lo ESCRIBE el selector de IA_Core cada frame (antes de ExecuteLaning); lo LEE
        // la capa de de-aggro de ExecuteLaning para saltear la retirada táctica cuando el
        // equipo va a cerrar un kill casi seguro (foco grupal sobre un enemigo agonizante)
        // y la vida del bot supera el piso. Persistente a propósito: ResetBrainScratch
        // (que corre dentro de Think, DESPUÉS de que el selector lo escribe) NO debe
        // borrarlo. INVARIANTE: igual que breakout/berserker, NO escribe lastTarget ni
        // isRetreating; usa este canal propio (no-pegajosidad).
        boolean killCommitActive

        // ----- RASTREO DE PÉRDIDA DE VIDA REAL — persistente -----
        // EMA de la pérdida de HP por segundo de ESTA unidad, medida sobre su
        // vida real: ve TODO (hechizos, torres, dots), no solo auto-ataques.
        // Lo actualiza IACore.MainLoop una vez por tick para TODOS los héroes
        // (bots Y humanos) vía IABlackboard_UpdateHPTrack. Consumidores:
        //  - de-aggro consciente de hechizos: incoming = max(físico, real)
        //    (IA_State_Laning, Think).
        //  - "aliado condenado": t2d del aliado = su HP / su selfLossRate.
        //  - Survival contextual (IA_State_Survival.ShouldRetreat).
        real    selfPrevHP
        real    selfLossRate

        // ----- AVANCE AGRUPADO (WAR PARTY) — persistente -----
        // Late game (alguna F1 abierta): el bot no avanza solo; espera grupo.
        real    wpCommitUntil       // histéresis: formado el grupo, el push no se corta por un rezagado breve
        real    wpLastIssuedX       // anti-respam del "move" al punto de reunión
        real    wpLastIssuedY

        // ----- CESIÓN DE PASO A ALIADO HUMANO (YIELD) — persistente -----
        // Cuando un JUGADOR HUMANO ALIADO fuerza ataque (tecla A) sobre el bot,
        // es una señal inequívoca de "me estás tapando el paso, muévete". El bot
        // da un paso PERPENDICULAR a la dirección de empuje (aliado->bot) para
        // vaciar el corredor, sin abandonar definitivamente lo que hacía: al
        // expirar yieldUntil, la lógica normal (Think) recalcula su intención.
        // INVARIANTE NO-PEGAJOSIDAD: igual que breakout, NO escribe lastTarget /
        // isRetreating; usa este canal propio. Ver IA_Breakout.j (IABreakout_TryYield).
        real    yieldUntil          // reloj hasta el que sigo cediendo (se refresca con cada golpe aliado)
        unit    yieldBlocker        // el aliado humano que me golpea (referencia de dirección)
        integer yieldSide           // 0=sin elegir, 1/-1 = lado perpendicular elegido
        boolean yieldTriedBoth      // ¿ya probé el otro lado? (si ambos fallan => ceder a breakout)
        real    yieldDestX          // punto fijo del paso al lado (no recalcular cada frame: evita drift)
        real    yieldDestY
        real    yieldRefX           // referencia de posición para medir si me desplacé
        real    yieldRefY
        real    yieldRefTime        // momento de la última referencia (ventana de atascado)

        // ----- IDENTIDAD DE BOT — persistente (la escribe IA_Core.Bot.create) -----
        // ¿Esta unidad es un héroe-BOT del motor? ÚNICA fuente de verdad para
        // "es bot". NO usar GetPlayerController == MAP_CONTROL_COMPUTER: un
        // LEAVER conserva controller USER (su slot solo pasa a LEFT), así que el
        // héroe tomado por la IA tras el voto (takeover, Sistema_Voto.j) NUNCA
        // pasa ese chequeo — así se rompió el gate de cast manual: el latch no se
        // armaba y el IA-cancel mataba con "stop" todo cast del humano sobre el
        // bot takeover (bug Hojalatero 2026-06-11). true para bots de lobby Y
        // takeover; false para héroes de humanos conectados.
        boolean isBotHero

        // ----- CONTROL MANUAL DEL HUMANO (MANUAL CAST) — persistente -----
        // humanCastLatch: lo activa el detector de órdenes (IABreakout_OnBotSpellOrder)
        // cuando un aliado humano (control compartido) ORDENA un hechizo del bot. Sirve
        // para distinguir el cast del HUMANO (con latch => ceder) del AUTO-CAST del
        // motor del jugador computadora (sin latch => cancelar con "stop").
        // humanCastPendingUntil: ventana de protección entre la ORDEN (ISSUE) y el
        // arranque real del cast (SPELL_CHANNEL). Cubre giro + caminata a rango y,
        // sobre todo, habilidades cuya orden NO se publica en GetUnitCurrentOrder
        // (sin esta ventana, el primer tick post-click veía "orden IA" y la FSM
        // pisaba el cast — p.ej. Cohetes de Dispersión del Hojalatero).
        // humanCastChanneling: true entre SPELL_CHANNEL y SPELL_ENDCAST (el cast está
        // corriendo de verdad, lo diga o no GetUnitCurrentOrder). Verdad del motor.
        // humanCastGraceUntil: colchón de gracia post-cast para no robarle el frame al
        // héroe en la animación de remate. Los lee/escribe IABreakout_TryManualCastYield.
        boolean humanCastLatch
        real    humanCastPendingUntil
        boolean humanCastChanneling
        real    humanCastGraceUntil

        // ----- [DEBUG] DIAGNÓSTICO ANTI-ENCIERRO (rate-limit de texttags) -----
        // Solo para depurar la detección de encierro. Persistentes (NO se tocan
        // en ResetBrainScratch). Sirven para emitir el trace de la guardia y de
        // los resets de ventana sin spamear la columna (15 msgs / TTL 10s).
        // (El trace GRD ya no necesita rate-limit propio: emite un string ESTABLE
        // cada frame y el contador "xN" lo fusiona en una sola línea.)
        real    dbgResetTime        // último instante en que se logueó un reset de ventana

        // [DEBUG_IA] CONGELAMIENTO DE-AGGRO: posición del frame anterior para medir
        // si el bot REALMENTE se desplaza mientras se le ordena huir. Persistente.
        // Quitar junto con su uso al cerrar el bug del congelamiento.
        real    dbgPrevX
        real    dbgPrevY

        // ----- CARRIL PASIVO (MELEE SIN SU 1ª ARMADURA) — persistente -----
        // Cerrojo de un solo sentido: un melee cuerpo a cuerpo juega PASIVO (no
        // farmea/harasea/persigue; se mantiene tras la línea de creeps) hasta
        // conseguir su 1ª armadura. Al abrirse (IABuildProgress_HasFirstArmor da
        // true UNA vez), el sistema se DESACTIVA por completo y para siempre: el
        // héroe vuelve a jugar exactamente como si esto no existiera. NO se
        // re-evalúa nunca más, ni aunque luego pierda la armadura, ni tras
        // muerte/revive (la pizarra persiste y ResetOnRevive no lo toca).
        boolean armorGateOpen
        boolean passiveParked       // ¿manteniendo posición (hold) tras la línea?
        real    passiveLastIssuedX  // último destino de viaje emitido (anti-respam del "move")
        real    passiveLastIssuedY

        // ----- SCRATCH (válido solo dentro del frame actual) -----
        // Decisión producida por PENSAR y consumida por ACTUAR:
        unit    killTarget          // objetivo de last-hit / remate
        unit    standardTarget      // objetivo estándar (harass / farm / asistencia)
        unit    attackTarget        // objetivo resuelto final (kill || standard)
        unit    teamFocusTarget     // foco compartido del equipo (asistencia)
        integer teamFocusCount      // nº de aliados pegándole al foco

        real    incomingDamage      // amenaza entrante estimada este frame
        real    damageThreshold     // umbral de daño tolerado (HP * tolerance/100)

        // ----- SENSORES DE PRESIÓN LOCAL (scratch, los rellena Think) -----
        integer enemyHeroesNear     // héroes enemigos vivos a <=1200
        integer allyHeroesNear      // héroes aliados vivos a <=1200 (sin contarme)
        integer alliesClose         // héroes aliados vivos a <=GROUP_RADIUS (war party)
        integer enemiesTargetingMe  // héroes enemigos cuyo objetivo (físico o intención) soy yo
        real    incomingAnticip     // amenaza ANTICIPADA: daño POTENCIAL de héroes peligrosos en inferioridad local (no recibido aún)
        boolean dangerRetreat       // PENSAR pide retirada táctica YA ("aliado condenado") aunque el daño clásico no llegue al umbral

        // ----- AVANCE AGRUPADO (WAR PARTY) — scratch -----
        boolean wpActive            // modo agrupado activo este frame (alguna F1 abierta y equipo >= 2)
        boolean wpAdvanceOK         // ¿grupo suficiente (o commit vigente) para avanzar?
        boolean wpHoldFire          // standoff: NO iniciar pelea de héroes (el primer golpe lo da un humano / superioridad)
        real    wpRallyX            // punto de reunión si wpAdvanceOK = false
        real    wpRallyY
        integer wpGroupNeeded       // tamaño de grupo requerido: min(héroes del equipo, 3)

        // [DEBUG_IA] desglose de incomingDamage por fuente (torre/héroe/creep).
        // Solo diagnóstico del ping-pong de torre vs persecución. Scratch (se
        // resetean cada frame). Quitar junto con su uso al cerrar el bug.
        real    dmgTower
        real    dmgHero
        real    dmgCreep

        // [DEBUG_IA] VETO DE PROFUNDIDAD DE CAZA: diagnóstico de cuándo el veto
        // bloqueó perseguir un héroe metido en la base enemiga. Scratch (por
        // frame). Sirve para detectar en el futuro "no ataca a ese héroe porque
        // está demasiado adentro". Quitar junto con su uso si se estabiliza.
        real    dbgSiegeX       // X del frente de asedio usado este frame
        boolean dbgVetoActive   // ¿el veto de asedio estaba ACTIVO este frame? (siegeFrontX válido) — lo leen ExecuteLaning/Breakout/Berserk para medir la profundidad del BOT
        real    dbgVetoDp       // dp (profundidad más allá del frente) del héroe vetado borderline
        integer dbgVetoCount    // nº de héroes enemigos vetados este frame
        integer dbgExemptCount  // nº de héroes PROFUNDOS que una excepción dejó cazar igual
        real    dbgExemptDp     // dp de un héroe profundo exento (diagnóstico)
        integer dbgExemptReason // 1=rematable(<=2 golpes con armadura)  2=aliado humano  0=ninguno
        real    dbgExemptHits   // golpes-para-matar ESTIMADOS del exento r=H (para falsar "math rota": si sale <=2 pero el héroe sobrevive 10+ golpes reales, la estimación miente)

        // Datos propios cacheados para la fase ACTUAR (evita recalcular):
        boolean amIMelee
        real    myRange
        real    myDamage
        real    currentTime
        real    windupEnd
        real    cooldownEnd
        real    dynamicCooldown

        // [PASIVO] decisión del frame (scratch): ¿juega pasivo y dónde pararse?
        boolean passiveActive
        boolean passiveHasAnchor
        real    passiveAnchorX
        real    passiveAnchorY

        static method create takes nothing returns thistype
            return thistype.allocate()
        endmethod
    endstruct

    // Devuelve la pizarra del bot, creándola la primera vez. El handle de un
    // héroe es estable a través de muerte/resurrección en WC3, así que la
    // memoria persiste correctamente (misma semántica que la hashtable previa).
    public function GetLaningBrain takes unit u returns LaningBrain
        local integer h = GetHandleId(u)
        local LaningBrain b
        if HaveSavedInteger(BRAIN_TABLE, h, 0) then
            return LoadInteger(BRAIN_TABLE, h, 0)
        endif
        set b = LaningBrain.create()
        call SaveInteger(BRAIN_TABLE, h, 0, b)
        return b
    endfunction

    // Resetea SOLO los campos scratch (decisión del frame). Los persistentes
    // quedan intactos. Se llama al inicio de cada ciclo de PENSAR.
    public function ResetBrainScratch takes LaningBrain b returns nothing
        set b.killTarget = null
        set b.standardTarget = null
        set b.attackTarget = null
        set b.teamFocusTarget = null
        set b.teamFocusCount = 0
        set b.incomingDamage = 0.0
        set b.damageThreshold = 0.0
        set b.enemyHeroesNear = 0
        set b.allyHeroesNear = 0
        set b.alliesClose = 0
        set b.enemiesTargetingMe = 0
        set b.incomingAnticip = 0.0
        set b.dangerRetreat = false
        set b.wpActive = false
        set b.wpAdvanceOK = true
        set b.wpHoldFire = false
        set b.wpRallyX = 0.0
        set b.wpRallyY = 0.0
        set b.wpGroupNeeded = 0
        set b.dmgTower = 0.0 // [DEBUG_IA]
        set b.dmgHero = 0.0  // [DEBUG_IA]
        set b.dmgCreep = 0.0 // [DEBUG_IA]
        set b.dbgSiegeX = 0.0       // [DEBUG_IA]
        set b.dbgVetoActive = false // [DEBUG_IA]
        set b.dbgVetoDp = 0.0       // [DEBUG_IA]
        set b.dbgVetoCount = 0      // [DEBUG_IA]
        set b.dbgExemptCount = 0    // [DEBUG_IA]
        set b.dbgExemptDp = 0.0     // [DEBUG_IA]
        set b.dbgExemptReason = 0   // [DEBUG_IA]
        set b.dbgExemptHits = 0.0   // [DEBUG_IA]
        set b.passiveActive = false      // [PASIVO]
        set b.passiveHasAnchor = false   // [PASIVO]
        set b.passiveAnchorX = 0.0       // [PASIVO]
        set b.passiveAnchorY = 0.0       // [PASIVO]
    endfunction

    // ============================================================
    // RASTREADOR DE PÉRDIDA DE VIDA REAL (por unidad)
    // ============================================================
    // Lo llama IACore.MainLoop UNA vez por tick para TODOS los héroes del mapa
    // (bots y humanos): así cualquier consumidor puede leer el ritmo real de
    // caída de cualquier héroe sin recalcularlo. dt = periodo del tick (0.10).
    // EMA (alfa 0.25, constante de tiempo ~0.35s): suaviza golpes sueltos pero
    // reacciona rápido a un focus. Las curaciones (delta negativo) empujan la
    // media hacia abajo, con clamp en 0 (nunca "pérdida negativa"). En muerte
    // se resetea para no arrastrar un ritmo viejo al revivir.
    public function UpdateHPTrack takes unit u, real dt returns nothing
        local LaningBrain b
        local real cur
        if u == null or GetUnitTypeId(u) == 0 then
            return
        endif
        set b = GetLaningBrain(u)
        if IsUnitType(u, UNIT_TYPE_DEAD) then
            set b.selfPrevHP = 0.0
            set b.selfLossRate = 0.0
            return
        endif
        set cur = GetUnitState(u, UNIT_STATE_LIFE)
        if b.selfPrevHP > 0.01 and dt > 0.001 then
            set b.selfLossRate = b.selfLossRate * 0.75 + ((b.selfPrevHP - cur) / dt) * 0.25
            if b.selfLossRate < 0.0 then
                set b.selfLossRate = 0.0
            endif
        endif
        set b.selfPrevHP = cur
    endfunction

endlibrary
