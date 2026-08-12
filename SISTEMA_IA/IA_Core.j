library IACore initializer InitMathEngine requires IAUtils, IAStateLaning, IABrainMacro, IAStateSurvival, IAStateShopping, IABreakout, IABlackboard

    // ==========================================================
    // CONTROL COMPARTIDO A ALIADOS HUMANOS (PERMANENTE)
    // ==========================================================
    // Comparte el control de las unidades del bot a TODOS sus aliados HUMANOS
    // (jugadores reales = MAP_CONTROL_USER), NUNCA a otros bots. Replica el
    // mecanismo de "Unidades compartidas" de IA_Permisos (control básico, que ya
    // permite castear y aprender/mejorar habilidades), pero filtrado a humanos.
    //
    // Se llama desde Bot.create => cubre los 3 caminos de nacimiento de un bot
    // (All Pick, Random y takeover por voto) en un solo punto, sin depender de
    // los detonadores GUI. Es idempotente: re-otorgarlo no tiene efecto adverso.
    // Permanente: no se revoca (a diferencia del control de la ventana de pick).
    public function ShareBotToHumanAllies takes player botOwner returns nothing
        local integer i = 0
        local player ally
        loop
            exitwhen i > 15
            set ally = Player(i)
            if ally != botOwner and GetPlayerSlotState(ally) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(ally) == MAP_CONTROL_USER and IsPlayerAlly(botOwner, ally) then
                call SetPlayerAlliance(botOwner, ally, ALLIANCE_SHARED_CONTROL, true)
            endif
            set i = i + 1
        endloop
        set ally = null
    endfunction

    // ==========================================================
    // ESTRUCTURA DEL BOT
    // ==========================================================
    struct Bot
        unit hero                   
        player owner                
        integer heroId              
        
        // --- PROPIEDAD NUEVA ---
        integer lane // 1 = Top, 2 = Bot (Recordar su carril)
        
        // --- ESTADOS MENTALES ---
        // 1=Laning, 3=Survival (Huida)
        integer state               
        
        // --- DATOS TÁCTICOS ---
        real hpPercent
        real mpPercent

        // Detector de transición muerto -> vivo, para limpiar el estado de
        // breakout/berserker en revive (no queremos resucitar en modo Berserker).
        // Lo procesa Bot.update() y llama a IABreakout_ResetOnRevive(hero).
        boolean wasDead

        // NOTA: el estado táctico de combate (lastAttackTime, target, tolerancia,
        // observación de daño, etc.) vive en la PIZARRA del carril (LaningBrain,
        // ver IA_Blackboard.j), NO aquí. El struct Bot solo guarda identidad y
        // estado ESTRATÉGICO (qué macro-estado ocupa, su carril, sus % de vida).
        // Mantener una sola fuente de verdad por dato evita bugs de desincronización.

        static method create takes unit u returns Bot
            local Bot b = Bot.allocate()
            set b.hero = u
            set b.owner = GetOwningPlayer(u)
            set b.heroId = GetUnitTypeId(u)
            set b.state = 1

            // IDENTIDAD DE BOT EN LA PIZARRA: única fuente de verdad para
            // "es héroe-bot" (la leen los handlers de IA_Breakout). Cubre lobby
            // Y takeover de leaver: el takeover conserva al dueño con controller
            // USER, así que cualquier chequeo por GetPlayerController ==
            // MAP_CONTROL_COMPUTER lo excluiría (bug del cast manual 2026-06-11).
            set IABlackboard_GetLaningBrain(u).isBotHero = true

            // CONTROL COMPARTIDO PERMANENTE A ALIADOS HUMANOS: desde que el cerebro
            // nace (cubre All Pick, Random y takeover), el bot cede el control de
            // sus unidades a sus aliados HUMANOS (nunca a otros bots). Así un
            // jugador real puede aprender/mejorar habilidades y lanzar los hechizos
            // del bot a mano. El gate IABreakout_TryManualCastYield evita que la IA
            // cancele esos lanzamientos.
            call ShareBotToHumanAllies(b.owner)

            // ASIGNAMOS SU CARRIL AL NACER Y LO RECORDAMOS PARA SIEMPRE
            set b.lane = IABrainMacro_AssignLane(b.owner)
            
            // ASIGNAMOS SU BUILD DE COMPRAS (CARA o SELLO) Y COLA DE ÍTEMS
            // Usamos b.heroId (capturado al nacer) para evitar problemas con
            // transformaciones que cambian el TypeId del héroe.
            call IAStateShopping_AssignBuild(u, b.heroId)
            
            return b
        endmethod
        
        method update takes nothing returns nothing
            local LaningBrain brain
            // Seguridad: Si está muerto, no pensamos. Marcamos wasDead para
            // detectar el revive en el siguiente tick vivo.
            if IsUnitType(this.hero, UNIT_TYPE_DEAD) or GetUnitTypeId(this.hero) == 0 then
                set this.wasDead = true
                return
            endif

            // Transición muerto -> vivo: limpiar estado breakout/berserker para
            // no resucitar arrastrando "estoy encerrado, modo berserker".
            if this.wasDead then
                set this.wasDead = false
                call IABreakout_ResetOnRevive(this.hero)
            endif

            // CESIÓN POR HECHIZO DEL HUMANO (PRIORIDAD MÁXIMA): si un aliado humano
            // (control compartido) le ordenó al bot lanzar/canalizar una habilidad,
            // le cedemos el frame para NO cancelar el cast ni sacarlo de la
            // canalización. La FSM se saltea este frame; al terminar el cast (o
            // romperse por stun/transformación/muerte del objetivo) el cerebro
            // retoma solo. Va ANTES del yield de paso para tener prioridad sobre él.
            if IABreakout_TryManualCastYield(this.hero) then
                return
            endif

            // CESIÓN DE PASO (máxima prioridad, transitoria): si un JUGADOR
            // HUMANO ALIADO me está forzando ataque, me estorba; doy un paso al
            // lado para liberarlo y salteo la FSM este frame. Si no puedo
            // apartarme (atrapado), TryYield devuelve false y seguimos normal.
            if IABreakout_TryYield(this.hero, this.owner) then
                return
            endif

            // 1. ACTUALIZAR SENSORES
            set this.hpPercent = GetUnitState(this.hero, UNIT_STATE_LIFE) / GetUnitState(this.hero, UNIT_STATE_MAX_LIFE)
            set this.mpPercent = GetUnitState(this.hero, UNIT_STATE_MANA) / GetUnitState(this.hero, UNIT_STATE_MAX_MANA)

            // COMPROMISO DE REMATE (KILL-COMMIT): se evalúa SIEMPRE, antes de las
            // transiciones, y se publica en la pizarra para que ExecuteLaning lea el
            // valor de ESTE frame (saltea el de-aggro táctico). Se mantiene en Laning:
            // así Think sigue corriendo y el foco (teamFocusTarget/Count) queda fresco.
            set brain = IABlackboard_GetLaningBrain(this.hero)
            set brain.killCommitActive = IAStateSurvival_KillCommitActive(this.hero, this.hpPercent)

            // ==================================================
            // MÁQUINA DE ESTADOS (SELECTOR ESTRICTO)
            // ==================================================
            // DOS CAPAS DE RETIRADA (no confundir):
            //   * ESTRATÉGICA  -> estado 3 (Survival). "Voy a curarme a base".
            //                     Dispara con HP < 40%, vuelve a laning con HP > 95%.
            //   * TÁCTICA/DE-AGGRO -> dentro de Laning (estado 1). Retroceso breve
            //                     para soltar aggro sin abandonar el carril.
            // El selector es ESTRICTO: solo UN estado se ejecuta por frame, así que
            // las dos capas nunca se pelean por el control del héroe.

            // TRANSICIONES
            if this.state != 3 then
                // Si estamos bien, chequeamos si debemos huir. EXCEPCIÓN: si estamos
                // comprometidos a rematar (el equipo va a cerrar un kill casi seguro y
                // mi vida supera el piso), NO huimos: nos quedamos en Laning a aportar
                // DPS. El gate se reevalúa cada frame, así que en cuanto el kill deja de
                // ser claro o la vida cae bajo el piso, el Survival reanuda solo.
                // ShouldRetreat ahora es CONTEXTUAL: lee los sensores del frame
                // anterior en la pizarra (más enemigos encima = huir antes; cero
                // peligro = apurar el umbral a la baja). Ver IA_State_Survival.j.
                if IAStateSurvival_ShouldRetreat(this.hero, this.hpPercent) and not brain.killCommitActive then
                    set this.state = 3 // ¡CAMBIO A HUIDA!
                endif
            else
                // Si estamos huyendo, chequeamos si ya estamos sanos
                if IAStateSurvival_IsHealthy(this.hpPercent) then
                    set this.state = 1 // ¡VOLVER A LANING!
                    
                    // HANDOFF LIMPIO A LANING: antes se emitía attack-move a
                    // GetLaneTarget (= base de curación ENEMIGA = la fuente), lo que
                    // mandaba al bot recto a la fuente y dejaba una orden "attack" fija
                    // que suprimía el re-ruteo por fases de ExecuteLaning. Con "stop"
                    // liberamos el control; ExecuteLaning (más abajo, este mismo frame)
                    // navega por fases hacia el objetivo correcto.
                    call IssueImmediateOrder(this.hero, "stop")

                endif
            endif

            // --- TRANSICIÓN LANING → SHOPPING ---
            // Solo si estamos en Laning y las condiciones de compra se cumplen.
            // ShouldStartShopping verifica: oro, stock, zona segura, no en combate.
            if this.state == 1 and IAStateShopping_ShouldStartShopping(this.hero, this.owner) then
                set this.state = 4 // ¡CAMBIO A SHOPPING!

                // HANDOFF LIMPIO A SHOPPING (mismo patrón que el "stop" de 3->1 arriba):
                // al venir de Laning el bot puede traer una orden "move" HEREDADA que
                // NO apunta a la tienda — típicamente el de-aggro táctico, que mueve a
                // GetClosestHome (= la fuente). El filtro anti-temblor de ExecuteShopping
                // (currentOrder != "move") asume que un "move" ya va a la tienda y NO lo
                // re-emite, así que el bot termina su trayecto a la FUENTE y solo al
                // llegar (orden=0) recién apunta a la tienda. Con "stop" soltamos esa
                // orden vieja; ExecuteShopping (este mismo frame) ya re-apunta a la tienda.
                call IssueImmediateOrder(this.hero, "stop")
            endif

            // ==================================================
            // EJECUCIÓN
            // ==================================================
            
            if this.state == 3 then
                // MODO SUPERVIVENCIA (Prioridad Total)
                call IAStateSurvival_ExecuteRetreat(this.hero, this.owner)
                
            elseif this.state == 4 then
                // MODO SHOPPING (Caminando a tienda / Comprando)
                // ExecuteShopping retorna el nuevo estado (4=seguir, 1=volver a laning)
                set this.state = IAStateShopping_ExecuteShopping(this.hero, this.owner, this.lane)

            elseif this.state == 1 then
                // MODO LANING
                // Ahora la lógica de Laning recibe el carril para saber a qué punto A-Movear.
                call IAStateLaning_ExecuteLaning(this.hero, this.owner, this.lane)
            endif

        endmethod
    endstruct

    // ==========================================================
    // SISTEMA CENTRAL (ENGINE) - SIN CAMBIOS
    // ==========================================================
    globals
        Bot array BotsActive        
        integer BotsCount = 0       
        timer IA_Timer_Loop         
        boolean IA_System_On = false 

        // Array global de TODOS los héroes del mapa (bots + humanos).
        // Consumidor: GetScaledDebuffLevel (Mec. C, aura scan sin GroupEnum).
        // Se puebla 1 vez en Init. Los handles sobreviven muerte/revive.
        public unit  array AllHeroes
        public integer     AllHeroCount = 0
    endglobals

    // Registra un héroe en el array global (todos los jugadores).
    // Llamar desde el detonador "Elegir Héroe" cuando el héroe se crea
    // después de StartEngine (sistema All Pick).
    //
    // GUARDA DE IDEMPOTENCIA: AllHeroes[] alimenta los escaneos O(n) de auras/
    // buffs (IA_Utils GetScaledDebuffLevel Mec. C) y de ítems de aliados. Varias
    // rutas registran el MISMO héroe (creación en Pick/Random — Core_Logica_Random.j
    // :48/:63 — y luego InitializeBots lo re-escanea), y un duplicado haría que el
    // héroe reciba su propia aura DOS VECES y se le cuente el inventario dos veces.
    // Los consumidores solo iteran 0..AllHeroCount-1 leyendo cada handle de forma
    // independiente (no hay acoplamiento por índice), así que saltar el duplicado
    // es 100% transparente. Mismo criterio que RegisterHero: un handle = una entrada.
    public function RegisterGlobalHero takes unit u returns nothing
        local integer k = 0
        loop
            exitwhen k >= AllHeroCount
            if AllHeroes[k] == u then
                return // ya registrado: no duplicar
            endif
            set k = k + 1
        endloop
        set AllHeroes[AllHeroCount] = u
        set AllHeroCount = AllHeroCount + 1
    endfunction

    public function RegisterHero takes unit u returns nothing
        // GUARDA DE IDEMPOTENCIA (FIX del temblor del melee pasivo).
        // Varias rutas registran bots y se solapaban: el héroe se crea en el Pick/
        // Random y se llama RegisterHero por unidad (SISTEMA_CORE/Core_Logica_Random.j
        // :50/:65), y ADEMÁS InitializeBots (mismo archivo :102, y IA_Arrancar) re-escanea
        // los slots de computadora y los vuelve a registrar. Resultado: DOS Bot structs
        // por héroe => MainLoop llamaba update() 2 veces/frame sobre la MISMA unidad.
        // Mientras ambos clones iban sincronizados no se notaba, pero al divergir de
        // estado (uno en Pasivo => holdposition, otro en Shopping => move) las órdenes
        // chocaban = TEMBLOR (confirmado con [OSC] DUP BOT: todos los héroes duplicados;
        // el que temblaba salía "st 1/4"). Solo afectaba a melee porque su carril pasivo
        // es el único que emite holdposition (crea el deadlock). Aquí cortamos el doble
        // registro en un único punto, robusto ante CUALQUIER ruta (pick, random,
        // InitializeBots, takeover por voto): un héroe = un solo cerebro.
        local integer k = 0
        loop
            exitwhen k >= BotsCount
            if BotsActive[k].hero == u then
                // Ya tiene Bot struct: registro redundante, no crear otro.
                return
            endif
            set k = k + 1
        endloop

        set BotsActive[BotsCount] = Bot.create(u)
        set BotsCount = BotsCount + 1
    endfunction

    private function MainLoop takes nothing returns nothing
        local integer i = 0

        // Actualizar Reloj Global
        call IAUtils_UpdateGameTime(0.10)

        // RASTREO DE PÉRDIDA DE VIDA REAL: una pasada por TODOS los héroes del
        // mapa (bots y humanos) por tick. Mantiene la EMA selfLossRate de cada
        // uno en su pizarra (IA_Blackboard.UpdateHPTrack). Alimenta el de-aggro
        // consciente de hechizos, el "aliado condenado" y el Survival contextual.
        set i = 0
        loop
            exitwhen i >= AllHeroCount
            call IABlackboard_UpdateHPTrack(AllHeroes[i], 0.10)
            set i = i + 1
        endloop

        set i = 0
        loop
            exitwhen i >= BotsCount
            if not IsUnitType(BotsActive[i].hero, UNIT_TYPE_DEAD) and GetUnitTypeId(BotsActive[i].hero) != 0 then
                call BotsActive[i].update()
            endif
            set i = i + 1
        endloop
    endfunction

    // ==========================================================
    // MOTOR MATEMÁTICO (Siempre ON — initializer de la library)
    // ==========================================================
    // Se ejecuta automáticamente al cargar el mapa (segundo 0.00).
    // Responsable de: IA_Target_Memory, SPELL_EFFECT interceptor,
    // GetScaledEffectLevel, calculadoras de AS/DPS.
    // NO depende de que existan bots en la partida.
    private function InitMathEngine takes nothing returns nothing
        call IAUtils_InitTargetTracker()
    endfunction

    // ==========================================================
    // CEREBRO IA (Solo si hay bots)
    // ==========================================================
    // Se ejecuta desde InitializeBots → StartEngine.
    // Responsable de: FSM, Macro, Escort, MainLoop.
    public function StartEngine takes nothing returns nothing
        if IA_System_On == true then
            return
        endif
        
        // INICIALIZAR EL MACRO
        call IABrainMacro_InitMacro()

        // INICIALIZAR SISTEMA DE COMPRAS (cachear tiendas)
        call IAStateShopping_InitShopping()

        // DETECTOR DE CESIÓN DE PASO (aliado humano fuerza ataque sobre el bot)
        call IABreakout_InitYield()

        // DETECTOR DE CONTROL MANUAL (humano ordena hechizos del bot por control
        // compartido). Distingue el cast del humano del auto-cast del motor.
        call IABreakout_InitManualControl()
        
        set IA_System_On = true
        set IA_Timer_Loop = CreateTimer()
        call TimerStart(IA_Timer_Loop, 0.10, true, function MainLoop)
    endfunction

    public function InitializeBots takes nothing returns nothing
        local integer i = 0
        local player p
        local group g
        local unit u
        local boolean isComputer
        local boolean hasHero

        if IA_System_On == true then
            return
        endif

        // Iterar sobre TODOS los jugadores (0-15) para poblar AllHeroes[].
        // Solo los Computer reciben IA (Bot struct).
        loop
            exitwhen i > 15
            set p = Player(i)
            if GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING then
                set isComputer = (GetPlayerController(p) == MAP_CONTROL_COMPUTER)
                set hasHero = false

                set g = CreateGroup()
                call GroupEnumUnitsOfPlayer(g, p, null)
                loop
                    set u = FirstOfGroup(g)
                    exitwhen u == null
                    call GroupRemoveUnit(g, u)
                    if IsUnitType(u, UNIT_TYPE_HERO) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                        // GLOBAL: Todos los héroes van al array global
                        call RegisterGlobalHero(u)
                        // IA: Solo los de computadora reciben cerebro
                        if isComputer then
                            call RegisterHero(u)
                            set hasHero = true
                        endif
                    endif
                endloop
                call DestroyGroup(g)

                // CONTROL COMPARTIDO PERMANENTE A ALIADOS HUMANOS — re-otorgar AQUÍ.
                // IA_Arrancar REVOCA el control compartido temporal del pick y luego
                // llama a InitializeBots; el re-share permanente vivía como efecto
                // secundario de Bot.create, pero con la guarda de idempotencia de
                // RegisterHero un bot ya registrado en el Pick no re-ejecuta Bot.create,
                // así que su re-share se perdía. Lo restablecemos explícito AQUÍ (corre
                // después del revoke).
                // CLAVE: SOLO para jugadores de computadora que controlan un HÉROE bot
                // (hasHero), NO para todo jugador computadora. El mapa tiene jugadores
                // de equipo (computadora) dueños de TORRES/ESTRUCTURAS/CREEPS; si les
                // compartiéramos el control, el aliado humano podría manejar esos creeps
                // (bug). Compartir solo dueños-de-héroe = exactamente lo que hacía el
                // Bot.create original (que solo corría por héroe). SHARED_CONTROL es por
                // JUGADOR, así que el dueño del héroe debe poseer únicamente su héroe.
                if isComputer and hasHero then
                    call ShareBotToHumanAllies(p)
                endif
            endif
            set i = i + 1
        endloop
        
        set p = null
        set g = null
        set u = null
        
        call StartEngine()
    endfunction

endlibrary