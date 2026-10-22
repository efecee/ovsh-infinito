//===========================================================================
// SISTEMA DE VOTACIÓN DEMOCRÁTICA POR ABANDONO
//===========================================================================
// Cuando un jugador abandona o es kickeado, este sistema pausa la acción
// y abre una votación de 8 segundos para que los jugadores restantes decidan.
// El equipo afectado recibe BOT/DROP/RMK y el rival CONTINUAR/RMK:
//   CONTINUAR/BOT/DROP cuentan juntos contra RMK (todos los votos pesan 1).
//   Si un equipo vota unánimemente RMK entre quienes participaron, fuerza RMK.
//   Si no gana RMK, solo el equipo afectado decide BOT contra DROP.
//   Una salida posterior del equipo rival recibe DROP por defecto.
//   BOT  ? La IA toma control del héroe
//   DROP ? Items a la base, héroe eliminado (default si nadie vota).
//          Su oro ACTUAL pasa COMPLETO a sus aliados (HUMANOS y BOTS por
//          igual). Los BOTS cuentan en AMBOS sentidos: un bot que se va
//          reparte su oro igual, y uno que se queda hereda como cualquier
//          aliado. El caso KICK (desertor sin héroe) reparte el oro
//          exactamente igual. (El BONUS de oro/seg por desertor fue RETIRADO
//          el 2026-07-19: hoy solo se reparte el oro actual y los items.)
//   RMK  ? Partida cancelada, todos expulsados
//
// FLUJO: Detección ? Congelar unidades ? Votación ? Resolución
//
// CONGELAMIENTO: Usamos PauseUnit en todas las unidades del mapa en vez de
// PauseGame, porque PauseGame tiene un límite de usos en partidas online.
// PauseUnit no tiene límite y detiene todo el combate igualmente.
// Los Dialogs funcionan con o sin PauseGame (estamos en trigger-context).
//
// DEPENDENCIAS:
//   - IACore (library): IACore_RegisterHero, IACore_StartEngine, etc.
//   - udg_MB_Hash (hashtable de tabla.j): flags de procesamiento, y la foto
//     de estadísticas del que abandona (keys 710-720, ver
//     Voto_CongelarClasificacion) que lee Sistema_Victoria.j
//   - Sistema_AntiBackdoor.j: AB_SiegeF0-F3 (copiados a la foto)
//   - ModoPartida (library en Core_Menu_Modo.j): en Modo Rápido no hay BOT
//===========================================================================

library SistemaVoto initializer OnInit requires IACore, ModoAleatorio, ReplayPOVDetection, ModoPartida

    // ==========================================================
    // CONSTANTES
    // ==========================================================
    globals
        private constant real    RMK_DELAY        = 0.0
        // Red de seguridad: en multi el juego corre, así que este timer cierra
        // el voto aunque haya AFKs. En un jugador el Dialog auto-pausa el juego
        // y este timer queda congelado (inofensivo: el host siempre puede votar).
        private constant real    RESOLVE_TIMEOUT  = 8.0
        private constant integer VOTE_NONE = 0
        private constant integer VOTE_BOT  = 1
        private constant integer VOTE_DROP = 2
        private constant integer VOTE_RMK  = 3
        private constant integer VOTE_CONTINUE = 4

        // Separador de resultados (estilo comando AS: línea dorada de "=").
        // Envuelve el bloque "Resultado / explicación" arriba y abajo.
        private constant string  VOTO_SEP = "|cffFFCC00=======================================|r"

        // === AVISO CENTRAL "VOTACION EN CURSO" (texttag estilo Datos_EnVivo) ===
        // Se muestra SOLO a quien YA voto, mientras la encuesta sigue abierta
        // (sus unidades quedan congeladas y sin el aviso pareceria un cuelgue).
        // Desaparece al instante en que se descongela (Voto_BannerTeardown).
        // Offsets relativos al CENTRO de la camara; AJUSTAR EN EDITOR (ver nota final).
        private constant real    BANNER_OFFSET_X       = -100.0  // < 0 = mover a la izquierda
        private constant real    BANNER_OFFSET_Y       =  -200.0  // > 0 = subir (centro-arriba)
        private constant real    BANNER_TEXT_SIZE      =  0.032  // "grande" (Datos usa 0.020)
        private constant real    BANNER_UPDATE_INTERVAL = 0.10   // refresco/seguimiento de camara
        private constant real    BANNER_DEFAULT_ZOOM   = 1650.0  // zoom base (igual que Datos)
    endglobals

    // ==========================================================
    // ESTADO DEL SISTEMA
    // ==========================================================
    globals
        // Sonido de resultados (persistente — patrón AntiBackdoor, evita bug de primer play)
        private sound Voto_SndResult = null

        // FSM: 0=IDLE, 2=VOTING
        private integer Voto_State = 0
        // Flag de fin de partida: impide que el sistema de voto se active
        // cuando los jugadores salen por victoria/derrota (no por abandono).
        public boolean Voto_GameOver = false

        // Fase de configuración del Master (Oro/Héroes/Habilidades).
        // Mientras sea false, las votaciones se DIFIEREN: WC3 solo permite
        // UN Dialog visible por jugador, y el menú del Master (1.00s) pisaría
        // el Dialog del voto dejándolo sin poder votar (bloqueo de 8s).
        // MenuHabilidades llama OnMenusFinished() al terminar la configuración.
        private boolean Voto_MenusDone = false
        // ¿Hay desertores esperando la apertura diferida de la votación?
        private boolean Voto_Diferido = false

        // --- Desertores ---
        private boolean array Voto_Desertores    // [playerId] = true
        private unit    array Voto_HeroRef       // [playerId] = hero unit (retenido vivo)
        private integer       Voto_NumDesertores = 0

        // --- Timers ---
        private timer Voto_TimerRmk  = null
        // Timer de cierre por tiempo (red de seguridad, solo efectivo en multi)
        private timer Voto_TimerResolve = null

        // --- Congelamiento (PauseUnit safety group) ---
        // Guarda las unidades que NOSOTROS pausamos, para no romper
        // stuns ni efectos de otros sistemas al descongelar.
        private group Voto_FrozenUnits = null
        // Timer periódico que congela unidades nuevas (creeps de spawners)
        private timer Voto_TimerFreeze = null

        // --- UI (Dialogs por equipo) ---
        // El equipo afectado decide BOT/DROP/RMK; el rival CONTINUAR/RMK.
        // Si no hay héroe, ambos equipos reciben CONTINUAR/RMK.
        private dialog Voto_DialogAffected = null
        private dialog Voto_DialogOpposing = null
        private button Voto_BtnAffectedBot      = null
        private button Voto_BtnAffectedDrop     = null
        private button Voto_BtnAffectedContinue = null
        private button Voto_BtnAffectedRmk      = null
        private button Voto_BtnOpposingContinue = null
        private button Voto_BtnOpposingRmk      = null

        // --- Votos ---
        private integer array Voto_Votos       // [playerId] = VOTE_*
        private integer       Voto_Emitidos    = 0
        private integer       Voto_Validos     = 0  // votantes válidos

        // Caso 1 vs Caso 2: ¿algún desertor tiene héroe?
        private boolean       Voto_AnyHeroDesertor = false
        // Equipo del primer abandono que abrió este ciclo de votación.
        // Se fija al registrar al primer desertor y no cambia si sale alguien más.
        private boolean       Voto_AffectedIsHuman = false
        // El primer desertor tenía héroe: habilita BOT/DROP para su equipo.
        // Las salidas posteriores nunca cambian los Dialogs de la encuesta.
        private boolean       Voto_PrimaryHasHero = false

        // --- Aviso central "Votación en curso" ---
        // Un texttag por slot (se crea perezosamente y se REUSA entre ciclos,
        // nunca se destruye ? paridad de handles en todos los clientes).
        private texttag array Voto_BannerTag
        private timer         Voto_TimerBanner = null

        // Expulsados por encuesta (DROP/KICK), marca PERSISTENTE (no se
        // limpia en Voto_Reset). Necesaria porque el kick del master deja al
        // jugador conectado viendo la derrota con su slot aún PLAYING: sin
        // esto contaría como votante o "aliado real" en ciclos futuros.
        private boolean array Voto_Expulsado
    endglobals

    // ==========================================================
    // HELPERS INTERNOS
    // ==========================================================

    // Color de jugador (inlineado porque tabla.j no es library)
    private function Voto_GetColor takes player p returns string
        local integer id = GetPlayerId(p)
        if (id == 0) then
            return "|cffd02222"
        elseif (id == 1) then
            return "|cff2254dd"
        elseif (id == 2) then
            return "|cff1CE6B9"
        elseif (id == 3) then
            return "|cff7134c2"
        elseif (id == 4) then
            return "|cffFFFC00"
        elseif (id == 5) then
            return "|cffFE8A0E"
        elseif (id == 6) then
            return "|cff20C000"
        elseif (id == 7) then
            return "|cffE55BB0"
        elseif (id == 8) then
            return "|cff959697"
        elseif (id == 9) then
            return "|cff7EBFF1"
        endif
        return "|cffFFFFFF"
    endfunction

    // Nombre legible de la opción de voto
    private function Voto_GetVoteName takes integer vote returns string
        if (vote == VOTE_BOT) then
            return "|cff00CCFFBOT|r"
        elseif (vote == VOTE_DROP) then
            return "|cffFFCC00DROP|r"
        elseif (vote == VOTE_RMK) then
            return "|cffFF4444RMK|r"
        elseif (vote == VOTE_CONTINUE) then
            return "|cff55DD55CONTINUAR|r"
        endif
        return "???"
    endfunction

    // ¿Es un votante válido? (Conectado, humano, no desertor)
    private function Voto_IsValidVoter takes integer id returns boolean
        if (id < 0 or id > 9) then
            return false
        endif
        if (Voto_Desertores[id]) then
            return false
        endif
        // Expulsado por una encuesta anterior: aunque su slot siga PLAYING
        // (kickeado mirando la pantalla de derrota), ya no vota.
        if (Voto_Expulsado[id]) then
            return false
        endif
        if (GetPlayerSlotState(Player(id)) != PLAYER_SLOT_STATE_PLAYING) then
            return false
        endif
        // Excluir computadoras (bots): solo humanos votan
        if (GetPlayerController(Player(id)) != MAP_CONTROL_USER) then
            return false
        endif
        return true
    endfunction

    // Cuenta los votantes válidos actuales (recalculable: refleja desconexiones)
    private function Voto_CountValidVoters takes nothing returns integer
        local integer i = 0
        local integer c = 0
        loop
            exitwhen i > 9
            if (Voto_IsValidVoter(i)) then
                set c = c + 1
            endif
            set i = i + 1
        endloop
        return c
    endfunction

    // ==========================================================
    // EQUIPO: helpers para reparto de oro
    // ==========================================================
    // ¿Puede 'pid' heredar del equipo indicado? (ALIADO ACTIVO del equipo por
    // slot, que no sea desertor pendiente ni expulsado por una encuesta
    // anterior). Cuenta tanto el HUMANO (controller USER) como el BOT
    // (controller COMPUTER): ambos heredan el oro actual (el bot lo gasta
    // comprando items). Solo quedan fuera los slots vacíos/sin dueño.
    // ÚNICA fuente de elegibilidad del reparto de oro del desertor.
    private function Voto_IsHeir takes integer pid, boolean humanTeam returns boolean
        local mapcontrol ctrl
        if (pid < 0 or pid > 9) then
            return false
        endif
        if ((pid <= 4) != humanTeam) then
            return false  // equipo contrario
        endif
        if (Voto_Desertores[pid] or Voto_Expulsado[pid]) then
            return false
        endif
        if (GetPlayerSlotState(Player(pid)) != PLAYER_SLOT_STATE_PLAYING) then
            return false
        endif
        // Aliado activo = humano (USER) o bot (COMPUTER). Slots vacíos (NONE) no.
        set ctrl = GetPlayerController(Player(pid))
        if (ctrl != MAP_CONTROL_USER and ctrl != MAP_CONTROL_COMPUTER) then
            return false
        endif
        return true
    endfunction

    // ¿Es 'j' un ALIADO (humano o bot) del desertor 'desId'? (El propio
    // desertor cae por Voto_Desertores dentro de IsHeir.)
    private function Voto_IsAllyOfDeserter takes integer j, integer desId returns boolean
        return Voto_IsHeir(j, desId <= 4)
    endfunction

    // ==========================================================
    // AVISO CENTRAL: apagar el banner "Votación en curso"
    // ==========================================================
    // Detiene el timer de refresco y oculta TODOS los texttags (en todos los
    // clientes — ocultar es simétrico y seguro). Los handles se conservan para
    // reusarse en el próximo ciclo. Idempotente: seguro de llamar varias veces.
    private function Voto_BannerTeardown takes nothing returns nothing
        local integer i = 0
        if (Voto_TimerBanner != null) then
            call PauseTimer(Voto_TimerBanner)
            call DestroyTimer(Voto_TimerBanner)
            set Voto_TimerBanner = null
        endif
        loop
            exitwhen i > 9
            if (Voto_BannerTag[i] != null) then
                call SetTextTagVisibility(Voto_BannerTag[i], false)
            endif
            set i = i + 1
        endloop
    endfunction

    // ==========================================================
    // RESET: Limpia todo el estado para el próximo ciclo
    // ==========================================================
    private function Voto_Reset takes nothing returns nothing
        local integer i = 0
        // Apagar el aviso central (red de seguridad; ya se apaga al descongelar)
        call Voto_BannerTeardown()
        set Voto_State = 0
        set Voto_NumDesertores = 0
        set Voto_Emitidos = 0
        set Voto_Validos = 0
        set Voto_AnyHeroDesertor = false
        set Voto_AffectedIsHuman = false
        set Voto_PrimaryHasHero = false
        loop
            exitwhen i > 9
            set Voto_Desertores[i] = false
            set Voto_HeroRef[i] = null
            set Voto_Votos[i] = VOTE_NONE
            set i = i + 1
        endloop
        // Limpiar grupo de congelamiento (por si quedó algo)
        if (Voto_FrozenUnits != null) then
            call DestroyGroup(Voto_FrozenUnits)
            set Voto_FrozenUnits = null
        endif
        if (Voto_TimerFreeze != null) then
            call PauseTimer(Voto_TimerFreeze)
            call DestroyTimer(Voto_TimerFreeze)
            set Voto_TimerFreeze = null
        endif
        if (Voto_TimerResolve != null) then
            call PauseTimer(Voto_TimerResolve)
            call DestroyTimer(Voto_TimerResolve)
            set Voto_TimerResolve = null
        endif
    endfunction

    // ==========================================================
    // CONGELAMIENTO: PauseUnit en todas las unidades del mapa
    // ==========================================================
    // Usa un safety group para no romper stuns u otros pause existentes.
    // Las unidades ya pausadas (e.g. héroe capturado) se saltan.

    // Callback: congela unidades nuevas que aparecieron desde el último scan
    // (creeps de spawners, invocaciones, etc.)
    private function Voto_FreezeNewUnits takes nothing returns nothing
        local group g = CreateGroup()
        local unit u
        call GroupEnumUnitsInRect(g, GetPlayableMapRect(), null)
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            call GroupRemoveUnit(g, u)
            if (not IsUnitPaused(u) and GetWidgetLife(u) > 0.405) then
                call PauseUnit(u, true)
                call GroupAddUnit(Voto_FrozenUnits, u)
            endif
        endloop
        call DestroyGroup(g)
        set g = null
        set u = null
    endfunction

    private function Voto_FreezeAllUnits takes nothing returns nothing
        local group g = CreateGroup()
        local unit u

        // Crear grupo de tracking (limpiar si ya existía)
        if (Voto_FrozenUnits != null) then
            call DestroyGroup(Voto_FrozenUnits)
        endif
        set Voto_FrozenUnits = CreateGroup()

        call GroupEnumUnitsInRect(g, GetPlayableMapRect(), null)
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            call GroupRemoveUnit(g, u)
            if (not IsUnitPaused(u) and GetWidgetLife(u) > 0.405) then
                call PauseUnit(u, true)
                call GroupAddUnit(Voto_FrozenUnits, u)
            endif
        endloop
        call DestroyGroup(g)

        // Iniciar timer periódico que congela unidades nuevas (creeps de spawners)
        if (Voto_TimerFreeze != null) then
            call PauseTimer(Voto_TimerFreeze)
            call DestroyTimer(Voto_TimerFreeze)
        endif
        set Voto_TimerFreeze = CreateTimer()
        call TimerStart(Voto_TimerFreeze, 0.5, true, function Voto_FreezeNewUnits)

        set g = null
        set u = null
    endfunction

    // Descongelar solo las unidades que NOSOTROS pausamos
    private function Voto_UnfreezeAllUnits takes nothing returns nothing
        local unit u

        // Detener timer de re-scan
        if (Voto_TimerFreeze != null) then
            call PauseTimer(Voto_TimerFreeze)
            call DestroyTimer(Voto_TimerFreeze)
            set Voto_TimerFreeze = null
        endif

        if (Voto_FrozenUnits == null) then
            return
        endif
        loop
            set u = FirstOfGroup(Voto_FrozenUnits)
            exitwhen u == null
            call GroupRemoveUnit(Voto_FrozenUnits, u)
            call PauseUnit(u, false)
        endloop
        call DestroyGroup(Voto_FrozenUnits)
        set Voto_FrozenUnits = null
        set u = null
    endfunction

    // ==========================================================
    // AVISO CENTRAL: texto e iteración por frame
    // ==========================================================
    // Texto GLOBAL (idéntico para todos los que lo ven): cuántos votantes
    // faltan y cuántos segundos quedan para el cierre automático.
    private function Voto_BuildBannerText takes nothing returns string
        local integer pending = Voto_Validos - Voto_Emitidos
        local integer secs    = 0
        local string  lineP
        local string  lineS
        if (pending < 0) then
            set pending = 0
        endif
        // Segundos reales restantes del timer de seguridad (efectivo en multi).
        if (Voto_TimerResolve != null) then
            set secs = R2I(TimerGetRemaining(Voto_TimerResolve) + 0.5)
        endif
        if (secs < 0) then
            set secs = 0
        endif
        if (pending == 1) then
            set lineP = "Falta |cffFFCC001|r jugador por votar"
        else
            set lineP = "Faltan |cffFFCC00" + I2S(pending) + "|r jugadores por votar"
        endif
        if (secs == 1) then
            set lineS = "|cffAAAAAACierre automático en |cffFFCC001|cffAAAAAAs|r"
        else
            set lineS = "|cffAAAAAACierre automático en |cffFFCC00" + I2S(secs) + "|cffAAAAAAs|r"
        endif
        return "|cff00CCFFVOTACIÓN EN CURSO|r" + "\n" + lineP + "\n" + lineS
    endfunction

    // Loop del banner (timer BANNER_UPDATE_INTERVAL). Por cada slot:
    //   - Crea su texttag SIMÉTRICAMENTE en todos los clientes (paridad de
    //     handles ? sin desync). Solo el cliente/POV correspondiente lo muestra.
    //   - Lo ve únicamente quien YA votó y mientras la votación siga abierta
    //     (al último votante nunca le aparece: su clic resuelve en el acto).
    private function Voto_BannerLoop takes nothing returns nothing
        local integer pid    = 0
        local integer viewer = GetPlayerId(GetReplayPlayerCached())
        local boolean active = (Voto_State == 2)
        local string  txt    = ""
        local real    camX
        local real    camY
        local real    zoom

        if (active) then
            set txt = Voto_BuildBannerText()
        endif

        loop
            exitwhen pid > 9

            // Crear el texttag de este slot en TODOS los clientes (simétrico)
            if (Voto_BannerTag[pid] == null) then
                set Voto_BannerTag[pid] = CreateTextTag()
                call SetTextTagPermanent(Voto_BannerTag[pid], true)
            endif

            // Mostrar SOLO si: votación activa, es votante válido, YA votó, y
            // este es su cliente o el POV observado. El resto ? oculto.
            if (active and Voto_IsValidVoter(pid) and Voto_Votos[pid] != VOTE_NONE and viewer == pid) then
                set camX = GetCameraTargetPositionX()
                set camY = GetCameraTargetPositionY()
                set zoom = GetCameraField(CAMERA_FIELD_TARGET_DISTANCE) / BANNER_DEFAULT_ZOOM
                if (zoom < 0.5) then
                    set zoom = 0.5
                elseif (zoom > 3.0) then
                    set zoom = 3.0
                endif
                call SetTextTagPos(Voto_BannerTag[pid], camX + BANNER_OFFSET_X * zoom, camY + BANNER_OFFSET_Y * zoom, 0.0)
                call SetTextTagText(Voto_BannerTag[pid], txt, BANNER_TEXT_SIZE)
                call SetTextTagVisibility(Voto_BannerTag[pid], true)
            else
                call SetTextTagVisibility(Voto_BannerTag[pid], false)
            endif

            set pid = pid + 1
        endloop
    endfunction

    // ==========================================================
    // EJECUCIÓN DE CONTINUAR: BOT/DROP/KICK POR DESERTOR
    // ==========================================================
    // BOT solo puede aplicarse a héroes del equipo del PRIMER desertor.
    // Todo desertor posterior del equipo contrario recibe DROP. Un desertor
    // sin héroe siempre recibe KICK, aunque BOT haya ganado para su equipo.

    private function Voto_HasHeroDeserterInTeam takes boolean humanTeam returns boolean
        local integer i = 0
        loop
            exitwhen i > 9
            if (Voto_Desertores[i] and (i <= 4) == humanTeam and Voto_HeroRef[i] != null) then
                return true
            endif
            set i = i + 1
        endloop
        return false
    endfunction

    private function Voto_HasNoHeroDeserter takes nothing returns boolean
        local integer i = 0
        loop
            exitwhen i > 9
            if (Voto_Desertores[i] and Voto_HeroRef[i] == null) then
                return true
            endif
            set i = i + 1
        endloop
        return false
    endfunction

    private function Voto_IsBotTarget takes integer id returns boolean
        if (not Voto_Desertores[id]) then
            return false
        endif
        if ((id <= 4) != Voto_AffectedIsHuman) then
            return false
        endif
        if (Voto_HeroRef[id] == null) then
            return false
        endif
        return GetUnitTypeId(Voto_HeroRef[id]) != 0
    endfunction

    private function Voto_ShowContinueResultForPlayer takes player p, boolean isAffected, integer winner returns nothing
        local boolean otherHasHero = Voto_HasHeroDeserterInTeam(not Voto_AffectedIsHuman)
        local boolean anyNoHero = Voto_HasNoHeroDeserter()

        call DisplayTimedTextToPlayer(p, 0, 0, 10.0, VOTO_SEP)

        // Si el primer jugador salió sin héroe, ambos equipos recibieron
        // CONTINUAR/RMK. Por eso ambos ven CONTINUAR como resultado.
        if (not Voto_PrimaryHasHero) then
            call DisplayTimedTextToPlayer(p, 0, 0, 10.0, "Resultado: |cff55DD55CONTINUAR|r")
            if (Voto_AnyHeroDesertor) then
                call DisplayTimedTextToPlayer(p, 0, 0, 10.0, "Items de los desconectados a sus bases. Oro repartido.")
            elseif (anyNoHero) then
                call DisplayTimedTextToPlayer(p, 0, 0, 10.0, "Su oro se reparte entre aliados.")
            endif

            // El equipo afectado reconoce BOT o DROP, igual que en su Dialog.
        elseif (isAffected) then
            if (winner == VOTE_BOT) then
                call DisplayTimedTextToPlayer(p, 0, 0, 10.0, "Resultado: |cff00CCFFBOT|r")
                call DisplayTimedTextToPlayer(p, 0, 0, 10.0, "La IA controla a los desconectados de tu equipo.")
                if (otherHasHero) then
                    call DisplayTimedTextToPlayer(p, 0, 0, 10.0, "El rival desconectado pierde su héroe. Items en su base, oro repartido.")
                endif
            else
                call DisplayTimedTextToPlayer(p, 0, 0, 10.0, "Resultado: |cffFFCC00DROP|r")
                if (otherHasHero) then
                    call DisplayTimedTextToPlayer(p, 0, 0, 10.0, "Items de los desconectados a sus bases. Oro repartido.")
                else
                    call DisplayTimedTextToPlayer(p, 0, 0, 10.0, "Items del desconectado a la base. Oro repartido.")
                endif
            endif
            if (anyNoHero) then
                call DisplayTimedTextToPlayer(p, 0, 0, 10.0, "También se reparte el oro de quienes salieron sin héroe.")
            endif

            // El rival solo eligió CONTINUAR/RMK: siempre ve CONTINUAR y una
            // explicación, nunca BOT o DROP como un segundo resultado.
        else
            call DisplayTimedTextToPlayer(p, 0, 0, 10.0, "Resultado: |cff55DD55CONTINUAR|r")
            if (winner == VOTE_BOT) then
                call DisplayTimedTextToPlayer(p, 0, 0, 10.0, "La IA controla a los desconectados rivales.")
                if (otherHasHero) then
                    call DisplayTimedTextToPlayer(p, 0, 0, 10.0, "Tu aliado desconectado pierde su héroe. Items en tu base, oro repartido.")
                endif
            elseif (otherHasHero) then
                call DisplayTimedTextToPlayer(p, 0, 0, 10.0, "Items de los desconectados a sus bases. Oro repartido.")
            else
                call DisplayTimedTextToPlayer(p, 0, 0, 10.0, "El rival pierde su héroe. Items en su base, oro repartido.")
            endif
            if (anyNoHero) then
                call DisplayTimedTextToPlayer(p, 0, 0, 10.0, "También se reparte el oro de quienes salieron sin héroe.")
            endif
        endif

        call DisplayTimedTextToPlayer(p, 0, 0, 10.0, VOTO_SEP)
    endfunction

    private function Voto_ShowContinueResult takes integer winner returns nothing
        local integer i = 0
        loop
            exitwhen i > 9
            if (Voto_IsValidVoter(i)) then
                call Voto_ShowContinueResultForPlayer(Player(i), (i <= 4) == Voto_AffectedIsHuman, winner)
            endif
            set i = i + 1
        endloop
    endfunction

    // Convierte UN desertor elegible en bot. Solo se llama con héroe válido.
    private function Voto_ConvertOneToBot takes integer id, boolean engineWasOff returns nothing
        local unit hero = Voto_HeroRef[id]
        local integer row
        local multiboarditem mb_item

        // Si el motor estaba apagado, InitializeBots saltó al desertor porque
        // su slot ya no estaba jugando. Agregar su héroe manualmente a AllHeroes.
        if (engineWasOff) then
            call IACore_RegisterGlobalHero(hero)
        endif
        call IACore_RegisterHero(hero)
        call PauseUnit(hero, false)

        // Restaurar la fila y marcar este slot como bot post-encuesta.
        call SaveBoolean(udg_MB_Hash, id, 101, true)
        call SaveBoolean(udg_MB_Hash, id, 102, true)
        call SaveBoolean(udg_MB_Hash, id, 103, false)
        call SetPlayerName(Player(id), "|cFFFFCC00IA|r " + Voto_GetColor(Player(id)) + LoadStr(udg_MB_Hash, id, 5))

        set row = LoadInteger(udg_MB_Hash, id, 0)
        if (row > 0) then
            // Columna 0 conserva el icono; el nombre ahora vive en la 1.
            set mb_item = MultiboardGetItem(udg_MB_Tabla, row - 1, 1)
            call MultiboardSetItemValue(mb_item, "|cFFFFCC00IA|r " + Voto_GetColor(Player(id)) + LoadStr(udg_MB_Hash, id, 5) + "|r")
            call MultiboardSetItemStyle(mb_item, true, false)
            call MultiboardReleaseItem(mb_item)

            set mb_item = MultiboardGetItem(udg_MB_Tabla, row - 1, 2)
            call MultiboardSetItemValue(mb_item, I2S(LoadInteger(udg_MB_Hash, id, 1)))
            call MultiboardSetItemStyle(mb_item, true, false)
            call MultiboardReleaseItem(mb_item)

            set mb_item = MultiboardGetItem(udg_MB_Tabla, row - 1, 3)
            call MultiboardSetItemValue(mb_item, I2S(LoadInteger(udg_MB_Hash, id, 2)))
            call MultiboardSetItemStyle(mb_item, true, false)
            call MultiboardReleaseItem(mb_item)

            set mb_item = MultiboardGetItem(udg_MB_Tabla, row - 1, 4)
            call MultiboardSetItemValue(mb_item, I2S(LoadInteger(udg_MB_Hash, id, 4)))
            call MultiboardSetItemStyle(mb_item, true, false)
            call MultiboardReleaseItem(mb_item)
        endif

        set hero = null
        set mb_item = null
    endfunction

    // Aplica DROP o KICK a UN desertor. Sin héroe, el mismo flujo reparte
    // el oro y no encuentra unidades ni items que retirar.
    private function Voto_DropOne takes integer id, boolean silent returns nothing
        local integer slot
        local group g
        local unit u
        local unit hero
        local item it
        local integer locID
        local real baseX
        local real baseY
        local integer j
        local integer goldD
        local integer allyCount = 0
        local integer share = 0

        call SaveBoolean(udg_MB_Hash, id, 101, true)
        set Voto_Expulsado[id] = true

        set goldD = GetPlayerState(Player(id), PLAYER_STATE_RESOURCE_GOLD)
        set j = 0
        loop
            exitwhen j > 9
            if (Voto_IsAllyOfDeserter(j, id)) then
                set allyCount = allyCount + 1
            endif
            set j = j + 1
        endloop

        // Este reparto lo hace el SISTEMA, no es un regalo del desertor: a
        // propósito NO escribe las keys 701/702 de udg_MB_Hash (Donador /
        // Clasificación en Sistema_Victoria.j). Así el que se va no gana puntos
        // ni Donador por su oro repartido, y los herederos no quedan penalizados
        // por recibirlo. El re-sembrado de Eco_GoldBaseline al final de
        // Voto_EjecutarContinuar impide que el detector F11 lo cuente.
        if (allyCount > 0 and goldD > 0) then
            set share = goldD / allyCount
        endif

        if (allyCount > 0) then
            set j = 0
            loop
                exitwhen j > 9
                if (Voto_IsAllyOfDeserter(j, id) and share > 0) then
                    call SetPlayerState(Player(j), PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(Player(j), PLAYER_STATE_RESOURCE_GOLD) + share)
                    // Incluso en el DROP automatico silencioso, cada heredero
                    // humano conserva un unico aviso con el oro recibido.
                    if (GetPlayerController(Player(j)) == MAP_CONTROL_USER) then
                        call DisplayTimedTextToPlayer(Player(j), 0, 0, 10.0, "Recibes |cffFFCC00+" + I2S(share) + "|r de oro.")
                    endif
                endif
                set j = j + 1
            endloop
            if (goldD > 0) then
                call SetPlayerState(Player(id), PLAYER_STATE_RESOURCE_GOLD, 0)
            endif
        endif

        set locID = GetPlayerStartLocation(Player(id))
        set baseX = GetStartLocationX(locID)
        set baseY = GetStartLocationY(locID)

        set hero = Voto_HeroRef[id]
        if (hero != null) then
            call PauseUnit(hero, false)
        endif

        set g = CreateGroup()
        call GroupEnumUnitsOfPlayer(g, Player(id), null)
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            call GroupRemoveUnit(g, u)
            if (IsUnitType(u, UNIT_TYPE_HERO)) then
                set slot = 0
                loop
                    exitwhen slot > 5
                    set it = UnitItemInSlot(u, slot)
                    if (it != null) then
                        call UnitRemoveItem(u, it)
                        call SetItemPosition(it, baseX, baseY)
                    endif
                    set slot = slot + 1
                endloop
            endif
            call RemoveUnit(u)
        endloop
        call DestroyGroup(g)

        set g = null
        set u = null
        set hero = null
        set it = null
    endfunction

    private function Voto_EjecutarContinuar takes integer winner, boolean silent returns nothing
        local integer i = 0
        local boolean hasBot = false
        local boolean engineWasOff = false
        local boolean didDrop = false

        if (not silent) then
            call Voto_ShowContinueResult(winner)
        endif

        if (winner == VOTE_BOT) then
            loop
                exitwhen i > 9
                if (Voto_IsBotTarget(i)) then
                    set hasBot = true
                endif
                set i = i + 1
            endloop
        endif

        if (hasBot) then
            set engineWasOff = not IA_System_On
            if (engineWasOff) then
                call IACore_InitializeBots()
            endif
        endif

        set i = 0
        loop
            exitwhen i > 9
            if (Voto_Desertores[i]) then
                if (winner == VOTE_BOT and Voto_IsBotTarget(i)) then
                    call Voto_ConvertOneToBot(i, engineWasOff)
                else
                    call Voto_DropOne(i, silent)
                    set didDrop = true
                endif
            endif
            set i = i + 1
        endloop

        // Absorber los movimientos directos de oro para que el detector F11
        // no los confunda con regalos entre jugadores.
        if (didDrop) then
            set i = 0
            loop
                exitwhen i > 9
                set Eco_GoldBaseline[i] = GetPlayerState(Player(i), PLAYER_STATE_RESOURCE_GOLD)
                set i = i + 1
            endloop
        endif
    endfunction

    private function Voto_EjecutarBot takes nothing returns nothing
        call Voto_EjecutarContinuar(VOTE_BOT, false)
    endfunction

    // silent=true omite el resultado general; el aviso individual de oro se conserva.
    private function Voto_EjecutarDrop takes boolean silent returns nothing
        call Voto_EjecutarContinuar(VOTE_DROP, silent)
    endfunction

    // ==========================================================
    // EJECUCIÓN: RMK — Callback del siguiente tick del motor
    // ==========================================================
    private function Voto_EjecutarRmk_Callback takes nothing returns nothing
        local integer i = 0

        // Destruir el timer de RMK
        call PauseTimer(Voto_TimerRmk)
        call DestroyTimer(Voto_TimerRmk)
        set Voto_TimerRmk = null

        // Marcar TODOS como procesados para que tabla.j no interfiera
        loop
            exitwhen i > 9
            call SaveBoolean(udg_MB_Hash, i, 101, true)
            set i = i + 1
        endloop

        // Expulsar a todos los jugadores conectados
        set i = 0
        loop
            exitwhen i > 9
            if (GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING) then
                call CustomDefeatBJ(Player(i), "Remake votado por la mayoría.")
            endif
            set i = i + 1
        endloop

        call Voto_Reset()
    endfunction

    // Inicia el timer para RMK (0.0s = siguiente tick del motor, seguro)
    private function Voto_EjecutarRmk takes nothing returns nothing
        call Replay_DisplayTimedTextToAll(15.0, VOTO_SEP)
        call Replay_DisplayTimedTextToAll(15.0, "Resultado: |cffFF4444RMK|r")
        call Replay_DisplayTimedTextToAll(15.0, "Partida cancelada. Expulsando...")
        call Replay_DisplayTimedTextToAll(15.0, VOTO_SEP)

        set Voto_TimerRmk = CreateTimer()
        call TimerStart(Voto_TimerRmk, RMK_DELAY, false, function Voto_EjecutarRmk_Callback)
    endfunction

    // ==========================================================
    // RESOLUCIÓN: RMK/CONTINUAR, luego BOT/DROP, ejecutar
    // ==========================================================
    private function Voto_Resolver takes nothing returns nothing
        local integer i = 0
        local integer countBot  = 0
        local integer countDrop = 0
        local integer countRmk  = 0
        local integer countContinue = 0
        local integer humanVotes = 0
        local integer humanRmk   = 0
        local integer orcVotes   = 0
        local integer orcRmk     = 0
        local integer winner    = VOTE_DROP  // Default si nadie vota

        // Guarda anti-doble-resolución: solo UNA resolución por voto.
        // Puede invocarse desde el último clic, el timer de 8s o el recuento
        // al abandonar; el primero gana y los demás se vuelven no-op.
        if (Voto_State != 2) then
            return
        endif
        set Voto_State = 0
        // Matar el timer de seguridad (puede ser quien nos invocó; patrón seguro,
        // igual que Voto_EjecutarRmk_Callback destruye su propio timer).
        if (Voto_TimerResolve != null) then
            call PauseTimer(Voto_TimerResolve)
            call DestroyTimer(Voto_TimerResolve)
            set Voto_TimerResolve = null
        endif

        // Ocultar dialog a todos
        set i = 0
        loop
            exitwhen i > 9
            call DialogDisplay(Player(i), Voto_DialogAffected, false)
            call DialogDisplay(Player(i), Voto_DialogOpposing, false)
            set i = i + 1
        endloop

        // Contar SOLO votos emitidos por jugadores que siguen siendo válidos.
        // Todos pesan 1. Para la primera decisión, BOT, DROP y CONTINUAR
        // pertenecen al bloque CONTINUAR; RMK forma el bloque contrario.
        set i = 0
        loop
            exitwhen i > 9
            if (Voto_IsValidVoter(i) and Voto_Votos[i] != VOTE_NONE) then
                if (i <= 4) then
                    set humanVotes = humanVotes + 1
                else
                    set orcVotes = orcVotes + 1
                endif

                if (Voto_Votos[i] == VOTE_BOT) then
                    set countContinue = countContinue + 1
                    if ((i <= 4) == Voto_AffectedIsHuman) then
                        set countBot = countBot + 1
                    endif
                elseif (Voto_Votos[i] == VOTE_DROP) then
                    set countContinue = countContinue + 1
                    if ((i <= 4) == Voto_AffectedIsHuman) then
                        set countDrop = countDrop + 1
                    endif
                elseif (Voto_Votos[i] == VOTE_RMK) then
                    set countRmk = countRmk + 1
                    if (i <= 4) then
                        set humanRmk = humanRmk + 1
                    else
                        set orcRmk = orcRmk + 1
                    endif
                elseif (Voto_Votos[i] == VOTE_CONTINUE) then
                    set countContinue = countContinue + 1
                endif
            endif
            set i = i + 1
        endloop

        // FASE 1: RMK contra CONTINUAR usando solo votos emitidos.
        // Excepción: si TODOS los votantes que sí participaron en cualquiera
        // de los dos equipos eligieron RMK, ese equipo fuerza el RMK. Se exige
        // al menos un voto para que un equipo sin participación no sea unánime
        // por vacío. Una abstención no suma ni bloquea esta excepción.
        // Fuera de la excepción, RMK gana solo si supera al bloque CONTINUAR;
        // el empate favorece continuar.
        //
        // FASE 2: si se continúa, solo BOT/DROP del equipo afectado llegaron
        // mediante su Dialog. BOT requiere mayoría estricta; todo empate,
        // incluido 0-0, conserva el default DROP.
        set winner = VOTE_DROP
        if ((humanVotes > 0 and humanRmk == humanVotes) or (orcVotes > 0 and orcRmk == orcVotes)) then
            set winner = VOTE_RMK
        elseif (countRmk > countContinue) then
            set winner = VOTE_RMK
        elseif (countBot > countDrop) then
            set winner = VOTE_BOT
        endif

        // Descongelar todas las unidades que nosotros pausamos
        call Voto_UnfreezeAllUnits()

        // Apagar el aviso central en el MISMO frame que el descongelamiento:
        // para quien ya había votado, el banner desaparece justo cuando su
        // héroe vuelve a responder.
        call Voto_BannerTeardown()

        // Restaurar la tabla (WC3 la oculta al mostrar un Dialog)
        call MultiboardDisplay(udg_MB_Tabla, true)
        call MultiboardMinimize(udg_MB_Tabla, false)

        // Sonido de resultados
        call SetSoundVolume(Voto_SndResult, 127)
        call StartSound(Voto_SndResult)

        // Ejecutar resultado (línea en blanco separa votos del resultado)
        call Replay_DisplayTimedTextToAll(7.0, " ")
        if (winner == VOTE_BOT) then
            call Voto_EjecutarBot()
        elseif (winner == VOTE_DROP) then
            call Voto_EjecutarDrop(false)
        else
            call Voto_EjecutarRmk()
        endif

        // Limpiar estado (RMK limpia en su callback)
        if (winner != VOTE_RMK) then
            call Voto_Reset()
            // Notificar al sistema de Master AFK que el voto terminó.
            // Si el master salió durante los menús, PostVoteCheck rotará y mostrará el Oro.
            call CoreMasterAFK_PostVoteCheck()
        endif
    endfunction

    // ==========================================================
    // DIALOG: Un jugador hizo clic en una opción
    // ==========================================================
    private function Voto_OnDialogClick takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer id = GetPlayerId(p)
        local button clicked = GetClickedButton()
        local integer vote = VOTE_NONE

        // Determinar qué botón presionó
        if (clicked == Voto_BtnAffectedBot) then
            set vote = VOTE_BOT
        elseif (clicked == Voto_BtnAffectedDrop) then
            set vote = VOTE_DROP
        elseif (clicked == Voto_BtnAffectedRmk or clicked == Voto_BtnOpposingRmk) then
            set vote = VOTE_RMK
        elseif (clicked == Voto_BtnAffectedContinue or clicked == Voto_BtnOpposingContinue) then
            set vote = VOTE_CONTINUE
        endif

        // Seguridad: Solo registrar si es un voto válido y no ha votado antes
        if (vote != VOTE_NONE and Voto_Votos[id] == VOTE_NONE and Voto_IsValidVoter(id)) then
            // Registrar voto
            set Voto_Votos[id] = vote
            set Voto_Emitidos = Voto_Emitidos + 1

            // Anunciar al público
            call Replay_DisplayTimedTextToAll(7.0, Voto_GetColor(p) + GetPlayerName(p) + "|r ha votado por: " + Voto_GetVoteName(vote))

            // ¿Votaron TODOS los válidos? ? Resolver de inmediato.
            // Los AFK ya no bloquean: si alguno no vota, el timer de 8s
            // (RESOLVE_TIMEOUT) cierra el voto solo (efectivo en multi).
            if (Voto_Emitidos >= Voto_Validos) then
                call Voto_Resolver()
            endif
        endif

        set p = null
        set clicked = null
    endfunction

    // ==========================================================
    // ¿Fase 2 completa (norte y sur) vulnerable en alguna facción?
    // ==========================================================
    // Lee los booleanos globales del anti-backdoor (Sistema_AntiBackdoor.j):
    // cada uno pasa a true cuando cae por completo la F3 de su carril y la F2
    // correspondiente queda atacable. Un solo carril abierto NO basta: norte
    // y sur deben estar abiertos para la misma facción. No hace falta que las
    // dos facciones cumplan la condición; con una sola es suficiente.
    private function Voto_F2Vulnerable takes nothing returns boolean
        return (AB_HUM_F2Top_Open and AB_HUM_F2Bot_Open) or (AB_ORC_F2Top_Open and AB_ORC_F2Bot_Open)
    endfunction

    // ==========================================================
    // ¿Algún desertor pendiente conserva su héroe?
    // ==========================================================
    // Mantiene correcto el resumen final. Los botones dependen exclusivamente
    // de Voto_PrimaryHasHero: una salida posterior nunca cambia la encuesta.
    private function Voto_RefreshAnyHeroDesertor takes nothing returns nothing
        local integer i = 0
        set Voto_AnyHeroDesertor = false
        loop
            exitwhen i > 9
            if (Voto_Desertores[i] and Voto_HeroRef[i] != null) then
                set Voto_AnyHeroDesertor = true
            endif
            set i = i + 1
        endloop
    endfunction

    // ==========================================================
    // ABRIR VOTACIÓN: congelar unidades, crear Dialog, esperar clicks/timer
    // ==========================================================
    // NO llamamos PauseGame (límite de usos en multi). Solo PauseUnit.
    // Nota: en UN JUGADOR, mostrar el Dialog auto-pausa la partida entera
    // (comportamiento del motor), por eso allí el timer de 8s queda congelado;
    // es inofensivo porque el único votante (el host) siempre puede cerrar.
    // Llamada directamente desde OnPlayerLeave (que corre en trigger-context).
    private function Voto_AbrirVotacion takes nothing returns nothing
        local integer i = 0

        // Cambiar estado
        set Voto_State = 2

        // Mantener correcto el resumen incluso si no queda nadie para votar.
        call Voto_RefreshAnyHeroDesertor()

        // Contar votantes válidos
        set Voto_Validos = Voto_CountValidVoters()

        // Seguridad: Si no hay votantes válidos, ejecutar DROP por defecto
        if (Voto_Validos <= 0) then
            call Voto_EjecutarDrop(false)
            call Voto_Reset()
            return
        endif

        // Congelar todas las unidades del mapa (sin límite, a diferencia de PauseGame)
        call Voto_FreezeAllUnits()

        // Preparar ambos Dialogs. Los handles de botones anteriores dejan de ser
        // válidos tras DialogClear, así que se nullea todo antes de reconstruir.
        call DialogClear(Voto_DialogAffected)
        call DialogClear(Voto_DialogOpposing)
        call DialogSetMessage(Voto_DialogAffected, "Un jugador se desconectó")
        call DialogSetMessage(Voto_DialogOpposing, "Un jugador se desconectó")
        set Voto_BtnAffectedBot = null
        set Voto_BtnAffectedDrop = null
        set Voto_BtnAffectedContinue = null
        set Voto_BtnAffectedRmk = null
        set Voto_BtnOpposingContinue = null
        set Voto_BtnOpposingRmk = null

        if (Voto_PrimaryHasHero) then
            // CASO 2: Tiene héroe. El equipo afectado decide cómo continuar.
            set Voto_BtnAffectedDrop = DialogAddButton(Voto_DialogAffected, "DROP (Soltar items y repartir su oro)", 0)
            // BOT solo está permitido FUERA del Modo Aleatorio de Habilidades y
            // del Modo Rápido (Core_Menu_Modo.j). En esos modos un bot no puede
            // reemplazar al desertor: se omite la opción para garantizar que
            // ningún bot los juegue. Sin el botón nadie puede votar BOT, y el
            // resultado por defecto ya es DROP.
            if (not ModoAl_Activo and not ModoPartida_EsRapido()) then
                set Voto_BtnAffectedBot = DialogAddButton(Voto_DialogAffected, "BOT (Un BOT lo reemplaza)", 0)
            endif
            set Voto_BtnAffectedRmk = DialogAddButton(Voto_DialogAffected, "RMK (Expulsar a todos)", 0)

            // El equipo contrario solo decide si la partida continúa.
            set Voto_BtnOpposingContinue = DialogAddButton(Voto_DialogOpposing, "CONTINUAR (Seguir jugando)", 0)
            set Voto_BtnOpposingRmk = DialogAddButton(Voto_DialogOpposing, "RMK (Expulsar a todos)", 0)
        else
            // CASO 1: No tiene héroe. Para ambos equipos CONTINUAR ejecuta
            // el KICK actual: repartir su oro y seguir, sin héroe ni items.
            set Voto_BtnAffectedContinue = DialogAddButton(Voto_DialogAffected, "CONTINUAR (Repartir su oro y seguir)", 0)
            set Voto_BtnAffectedRmk = DialogAddButton(Voto_DialogAffected, "RMK (Expulsar a todos)", 0)
            set Voto_BtnOpposingContinue = DialogAddButton(Voto_DialogOpposing, "CONTINUAR (Repartir su oro y seguir)", 0)
            set Voto_BtnOpposingRmk = DialogAddButton(Voto_DialogOpposing, "RMK (Expulsar a todos)", 0)
        endif

        // Mostrar a cada votante válido el Dialog que corresponde a su equipo.
        set i = 0
        loop
            exitwhen i > 9
            if (Voto_IsValidVoter(i)) then
                if ((i <= 4) == Voto_AffectedIsHuman) then
                    call DialogDisplay(Player(i), Voto_DialogAffected, true)
                else
                    call DialogDisplay(Player(i), Voto_DialogOpposing, true)
                endif
            endif
            set i = i + 1
        endloop

        // Red de seguridad: cerrar el voto a los 8s aunque queden AFKs.
        // (Solo dispara en multi; en SP el Dialog pausa el juego y lo congela.)
        set Voto_TimerResolve = CreateTimer()
        call TimerStart(Voto_TimerResolve, RESOLVE_TIMEOUT, false, function Voto_Resolver)

        // Aviso central para quienes ya votaron (se irá mostrando a medida que
        // cada uno emita su voto y desaparece al resolver/descongelar).
        set Voto_TimerBanner = CreateTimer()
        call TimerStart(Voto_TimerBanner, BANNER_UPDATE_INTERVAL, true, function Voto_BannerLoop)
    endfunction


    // ==========================================================
    // CONGELAR CLASIFICACIÓN: foto de las estadísticas al salir
    // ==========================================================
    // El que abandona (o es expulsado) deja de sumar para la Clasificación y
    // las Distinciones de Sistema_Victoria.j, pero conserva lo logrado: si se
    // desconectó siendo el mejor, puede seguir en el podio. Sin la foto, con
    // voto BOT la IA seguía sumando en su misma fila (y el podio mostraba su
    // nombre con puntos del bot). La tabla (multiboard) sigue mostrando el
    // slot en vivo; la foto solo la lee Sistema_Victoria.j (SV_StatInt/Real).
    // udg_MB_Hash, parent = playerId: 710 = foto tomada (boolean);
    // 711 kills, 712 muertes, 713 asistencias, 714 oro enviado, 715 oro
    // recibido (integer); 716 daño a héroes, 717-720 asedio F0-F3 (real).
    private function Voto_CongelarClasificacion takes integer id returns nothing
        if (LoadBoolean(udg_MB_Hash, id, 710)) then
            return
        endif
        call SaveBoolean(udg_MB_Hash, id, 710, true)
        call SaveInteger(udg_MB_Hash, id, 711, LoadInteger(udg_MB_Hash, id, 1))
        call SaveInteger(udg_MB_Hash, id, 712, LoadInteger(udg_MB_Hash, id, 2))
        call SaveInteger(udg_MB_Hash, id, 713, LoadInteger(udg_MB_Hash, id, 4))
        call SaveInteger(udg_MB_Hash, id, 714, LoadInteger(udg_MB_Hash, id, 701))
        call SaveInteger(udg_MB_Hash, id, 715, LoadInteger(udg_MB_Hash, id, 702))
        call SaveReal(udg_MB_Hash, id, 716, LoadReal(udg_MB_Hash, id, 700))
        call SaveReal(udg_MB_Hash, id, 717, AB_SiegeF0[id])
        call SaveReal(udg_MB_Hash, id, 718, AB_SiegeF1[id])
        call SaveReal(udg_MB_Hash, id, 719, AB_SiegeF2[id])
        call SaveReal(udg_MB_Hash, id, 720, AB_SiegeF3[id])
    endfunction

    // ==========================================================
    // CAPTURAR HÉROE: Busca y retiene el héroe del jugador
    // ==========================================================
    private function Voto_CapturarHeroe takes player p returns nothing
        local integer id = GetPlayerId(p)
        local group g = CreateGroup()
        local unit u

        call GroupEnumUnitsOfPlayer(g, p, null)
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            call GroupRemoveUnit(g, u)
            if (IsUnitType(u, UNIT_TYPE_HERO) and not IsUnitType(u, UNIT_TYPE_STRUCTURE)) then
                set Voto_HeroRef[id] = u
                call PauseUnit(u, true)
            endif
        endloop
        call DestroyGroup(g)

        set g = null
        set u = null
    endfunction

    // ==========================================================
    // API PÚBLICA: La fase de menús del Master terminó
    // ==========================================================
    // Llamada por MenuHabilidades (Core_Menu_Habilidades.j) al FINAL de
    // EjecutarPostSeleccion — tanto por clic en la Pantalla 3 como por la
    // ruta de bots que la saltea. Si hubo abandonos durante la pantalla de
    // carga o los menús, abre la votación AHORA que la pantalla del Master
    // está libre de Dialogs (y con ModoAl_Activo ya decidido).
    public function OnMenusFinished takes nothing returns nothing
        set Voto_MenusDone = true
        if (Voto_Diferido and not Voto_GameOver and Voto_State == 0) then
            set Voto_Diferido = false
            call Voto_AbrirVotacion()
        endif
    endfunction

    // ==========================================================
    // API PÚBLICA: Cancelar votación en curso (usado por Sistema_Victoria)
    // ==========================================================
    // Cierra la votación limpiamente sin ejecutar ningún resultado.
    // Llamado cuando la partida termina mientras hay un voto activo.
    public function ForceEndVote takes nothing returns nothing
        local integer i = 0
        if (Voto_State != 2) then
            return
        endif
        // Ocultar dialog a todos
        loop
            exitwhen i > 9
            call DialogDisplay(Player(i), Voto_DialogAffected, false)
            call DialogDisplay(Player(i), Voto_DialogOpposing, false)
            set i = i + 1
        endloop
        // Descongelar todas las unidades
        call Voto_UnfreezeAllUnits()
        // Apagar el aviso central
        call Voto_BannerTeardown()
        // Restaurar la tabla
        call MultiboardDisplay(udg_MB_Tabla, true)
        call MultiboardMinimize(udg_MB_Tabla, false)
        // Reset completo
        call Voto_Reset()
    endfunction

    // ==========================================================
    // API PÚBLICA: Punto de entrada cuando un jugador sale/es kickeado
    // ==========================================================
    public function OnPlayerLeave takes player p returns nothing
        local integer id = GetPlayerId(p)

        // No procesar si la partida ya terminó (victoria/derrota)
        if (Voto_GameOver) then
            return
        endif

        // Si un RMK ya fue votado (expulsión inminente), ignorar nuevos
        // abandonos: todos serán expulsados igual en el próximo tick.
        if (Voto_TimerRmk != null) then
            return
        endif

        // Seguridad: No procesar dos veces al mismo jugador
        if (Voto_Desertores[id]) then
            return
        endif

        // Congelar su Clasificación en este instante, antes de que la votación
        // (BOT/DROP) o una asistencia póstuma toquen sus estadísticas.
        call Voto_CongelarClasificacion(id)

        // Capturar héroe ANTES de que otro sistema lo borre
        call Voto_CapturarHeroe(p)

        // Fijar una sola vez el equipo afectado de este ciclo. Los abandonos
        // adicionales se agregan al resultado actual, pero no cambian los
        // Dialogs que ya recibieron los jugadores.
        if (Voto_NumDesertores == 0) then
            set Voto_AffectedIsHuman = (id <= 4)
            set Voto_PrimaryHasHero = (Voto_HeroRef[id] != null)
        endif

        // Marcar como desertor
        set Voto_Desertores[id] = true
        set Voto_NumDesertores = Voto_NumDesertores + 1
        call Voto_RefreshAnyHeroDesertor()

        // --- FASE 2 COMPLETA VULNERABLE: DROP automático, sin encuesta ---
        // Si F2 norte Y F2 sur de CUALQUIER facción ya están desbloqueadas,
        // no interrumpimos con la votación ni con el resultado general.
        // Un solo carril F2 vulnerable no activa esta omisión. Solo quedan el
        // aviso estándar de abandono y "Recibes +X de oro" para cada heredero;
        // el efecto DROP (items, oro) se aplica completo, reutilizando
        // Voto_EjecutarDrop para heredar sin duplicar cualquier cambio futuro
        // de la lógica de DROP.
        // Guarda != 2: si un voto ya estaba abierto (empezó antes de que cayera
        // la segunda F3 requerida), lo dejamos resolver por su vía normal.
        if (Voto_F2Vulnerable() and Voto_State != 2) then
            call Voto_EjecutarDrop(true)
            call Voto_Reset()
            return
        endif

        // --- LÓGICA DE ESTADO ---

        if (Voto_State == 0) then
            if (not Voto_MenusDone) then
                // FASE DE MENÚS (pantalla de carga o configuración del Master):
                // DIFERIR la votación. Abrir el Dialog ahora colisionaría con
                // los menús del Master (WC3: un Dialog por jugador) y lo
                // dejaría sin poder votar. El desertor ya quedó registrado
                // (Voto_Desertores + héroe capturado); OnMenusFinished abrirá
                // la encuesta al terminar la configuración.
                set Voto_Diferido = true
            else
                // IDLE ? Abrir votación inmediatamente
                call Voto_AbrirVotacion()
            endif

        elseif (Voto_State == 2) then
            // VOTING ? recontar votantes válidos (el que se fue ya no cuenta) y
            // re-chequear el cierre: si era el voto que faltaba, resolver ya en
            // vez de esperar el timer. En SP es no-op (los que se van son bots).
            call Replay_DisplayTimedTextToAll(5.0, "|cffFFCC00[SISTEMA]|r Otro jugador abandonó.")
            // Si ya había votado, retirar ese voto: al abandonar deja de ser
            // votante válido y tampoco debe provocar un cierre anticipado falso.
            if (Voto_Votos[id] != VOTE_NONE) then
                set Voto_Votos[id] = VOTE_NONE
                set Voto_Emitidos = Voto_Emitidos - 1
                if (Voto_Emitidos < 0) then
                    set Voto_Emitidos = 0
                endif
            endif
            set Voto_Validos = Voto_CountValidVoters()
            if (Voto_Validos <= 0 or Voto_Emitidos >= Voto_Validos) then
                call Voto_Resolver()
            endif
        endif
    endfunction

    // ==========================================================
    // INICIALIZACIÓN
    // ==========================================================
    private function OnInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        set Voto_DialogAffected = DialogCreate()
        set Voto_DialogOpposing = DialogCreate()
        call TriggerRegisterDialogEvent(t, Voto_DialogAffected)
        call TriggerRegisterDialogEvent(t, Voto_DialogOpposing)
        call TriggerAddAction(t, function Voto_OnDialogClick)
        set t = null

        // Sonido persistente: se crea una vez en init para evitar el bug de
        // "primera reproducción silenciosa" (mismo patrón que AntiBackdoor)
        set Voto_SndResult = CreateSound("Sound\\Interface\\SecretFound.wav", false, false, false, 10, 10, "")
        call SetSoundVolume(Voto_SndResult, 127)
    endfunction

endlibrary
