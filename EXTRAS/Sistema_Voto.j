//===========================================================================
// SISTEMA DE VOTACIÓN DEMOCRÁTICA POR ABANDONO
//===========================================================================
// Cuando un jugador abandona o es kickeado, este sistema pausa la acción
// y abre una votación para que los jugadores restantes decidan:
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
//   - udg_MB_Hash (hashtable de tabla.j): flags de procesamiento
//===========================================================================

library SistemaVoto initializer OnInit requires IACore, ModoAleatorio

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
        // el Dialog del voto dejándolo sin poder votar (bloqueo de 15s).
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

        // --- UI (Dialog) ---
        private dialog Voto_Dialog   = null
        private button Voto_BtnBot   = null
        private button Voto_BtnDrop  = null
        private button Voto_BtnRmk   = null

        // --- Votos ---
        private integer array Voto_Votos       // [playerId] = VOTE_*
        private integer array Voto_Orden       // [playerId] = orden de votación (1,2,3...)
        private integer       Voto_OrdenCount  = 0
        private integer       Voto_Emitidos    = 0
        private integer       Voto_Validos     = 0  // votantes válidos
        
        // Caso 1 vs Caso 2: ¿algún desertor tiene héroe?
        private boolean       Voto_AnyHeroDesertor = false

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
            if (Voto_AnyHeroDesertor) then
                return "|cffFFCC00DROP|r"
            else
                return "|cffFFCC00KICK|r"
            endif
        elseif (vote == VOTE_RMK) then
            return "|cffFF4444RMK|r"
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
    // EQUIPO: helpers para voto ponderado y reparto de oro
    // ==========================================================
    // Equipo del PRIMER desertor por slot (0-4 Humanos = true / 5-9 Orcos =
    // false; misma convención que Eco_TeamIndex en Comandos_Economia.j). Si no
    // hubiera ninguno (no debería pasar en una resolución real), default true.
    private function Voto_DesertorIsHuman takes nothing returns boolean
        local integer i = 0
        loop
            exitwhen i > 9
            if (Voto_Desertores[i]) then
                return (i <= 4)
            endif
            set i = i + 1
        endloop
        return true
    endfunction

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
        set Voto_OrdenCount = 0
        set Voto_Emitidos = 0
        set Voto_Validos = 0
        loop
            exitwhen i > 9
            set Voto_Desertores[i] = false
            set Voto_HeroRef[i] = null
            set Voto_Votos[i] = VOTE_NONE
            set Voto_Orden[i] = 0
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
            set lineS = "|cffAAAAAASe cierra sola en |cffFFCC001|cffAAAAAA segundo|r"
        else
            set lineS = "|cffAAAAAASe cierra sola en |cffFFCC00" + I2S(secs) + "|cffAAAAAA segundos|r"
        endif
        return "|cff00CCFFVOTACION EN CURSO|r" + "\n" + lineP + "\n" + lineS
    endfunction

    // Loop del banner (timer BANNER_UPDATE_INTERVAL). Por cada slot:
    //   - Crea su texttag SIMÉTRICAMENTE en todos los clientes (paridad de
    //     handles ? sin desync). Solo el cliente DUEÑO lo posiciona/muestra.
    //   - Lo ve únicamente quien YA votó y mientras la votación siga abierta
    //     (al último votante nunca le aparece: su clic resuelve en el acto).
    private function Voto_BannerLoop takes nothing returns nothing
        local integer pid    = 0
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
            // este es su propio cliente. El resto de combinaciones ? oculto.
            if (active and Voto_IsValidVoter(pid) and Voto_Votos[pid] != VOTE_NONE and GetLocalPlayer() == Player(pid)) then
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
    // EJECUCIÓN: BOT — La IA toma control
    // ==========================================================
    private function Voto_EjecutarBot takes nothing returns nothing
        local integer i = 0
        local unit hero
        local boolean engineWasOff = not IA_System_On
        local integer row
        local multiboarditem mb_item

        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10.0, VOTO_SEP)
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10.0, "Resultado: |cff00CCFFBOT|r")
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10.0, "Jugador eliminado. La IA tomará el control de su Héroe.")
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10.0, VOTO_SEP)

        // Encender el cerebro de la IA si está apagado
        if (engineWasOff) then
            call IACore_InitializeBots()
        endif

        // Registrar cada héroe desertor en la IA
        loop
            exitwhen i > 9
            if (Voto_Desertores[i]) then
                set hero = Voto_HeroRef[i]
                if (hero != null and GetUnitTypeId(hero) != 0) then
                    // --- AllHeroes[] (array global para aura scan) ---
                    // Si el motor ESTABA APAGADO: InitializeBots escaneó a todos,
                    // pero saltó al desertor (PLAYER_SLOT_STATE_LEFT).
                    // Necesitamos agregarlo manualmente.
                    //
                    // Si el motor YA ESTABA ENCENDIDO: InitializeBots ya lo
                    // registró al inicio (cuando el jugador aún estaba conectado).
                    // NO volver a agregarlo o habrá duplicado en AllHeroes[],
                    // causando que GetScaledDebuffLevel procese este héroe 2 veces.
                    if (engineWasOff) then
                        call IACore_RegisterGlobalHero(hero)
                    endif

                    // --- BotsActive[] (motor de IA) ---
                    // Siempre necesario: el héroe era humano, nunca tuvo Bot struct.
                    call IACore_RegisterHero(hero)

                    // Descongelar al héroe (lo pausamos al detectar abandono)
                    call PauseUnit(hero, false)
                endif

                // --- TABLA: Restaurar fila (MB_FadeRow la atenuó antes del voto) ---
                // Marcar como bot post-encuesta (key 102) para que Sistema_Kick
                // permita re-expulsar sin encuesta.
                call SaveBoolean(udg_MB_Hash, i, 101, true) // Ya procesado
                call SaveBoolean(udg_MB_Hash, i, 102, true) // Bot post-encuesta
                call SaveBoolean(udg_MB_Hash, i, 103, false) // Fila NO atenuada (hay un bot jugando el slot)

                // Renombrar jugador globalmente: todos los GetPlayerName()
                // ahora retornan "IA NombreOriginal" automáticamente.
                // Esto cubre: Sistema_Anuncios, Comandos_Economia, F9, etc.
                call SetPlayerName(Player(i), "|cFFFFCC00IA|r " + Voto_GetColor(Player(i)) + LoadStr(udg_MB_Hash, i, 5))

                // Nombre en tabla: prefijo blanco IA + color del jugador + nombre
                set row = LoadInteger(udg_MB_Hash, i, 0)
                if (row > 0) then
                    set mb_item = MultiboardGetItem(udg_MB_Tabla, row - 1, 0)
                    call MultiboardSetItemValue(mb_item, "|cFFFFCC00IA|r " + Voto_GetColor(Player(i)) + LoadStr(udg_MB_Hash, i, 5) + "|r")
                    call MultiboardSetItemStyle(mb_item, true, false)
                    call MultiboardReleaseItem(mb_item)

                    // KDA: restaurar a color normal (deshacer el atenuado)
                    set mb_item = MultiboardGetItem(udg_MB_Tabla, row - 1, 1)
                    call MultiboardSetItemValue(mb_item, I2S(LoadInteger(udg_MB_Hash, i, 1)))
                    call MultiboardSetItemStyle(mb_item, true, false)
                    call MultiboardReleaseItem(mb_item)

                    set mb_item = MultiboardGetItem(udg_MB_Tabla, row - 1, 2)
                    call MultiboardSetItemValue(mb_item, I2S(LoadInteger(udg_MB_Hash, i, 2)))
                    call MultiboardSetItemStyle(mb_item, true, false)
                    call MultiboardReleaseItem(mb_item)

                    set mb_item = MultiboardGetItem(udg_MB_Tabla, row - 1, 3)
                    call MultiboardSetItemValue(mb_item, I2S(LoadInteger(udg_MB_Hash, i, 4)))
                    call MultiboardSetItemStyle(mb_item, true, false)
                    call MultiboardReleaseItem(mb_item)
                endif
            endif
            set i = i + 1
        endloop

        set hero = null
        set mb_item = null
    endfunction

    // ==========================================================
    // EJECUCIÓN: DROP — Items a base, héroe eliminado
    // ==========================================================
    // Lógica inlineada de MB_DropItems (tabla.j no es library)
    // silent = true: aplica TODO el efecto (items, oro, flags) pero sin
    // emitir NINGÚN mensaje. Lo usa la ruta automática de F0 vulnerable
    // (OnPlayerLeave): en el final de la partida los abandonos se resuelven
    // en silencio para no llenar la pantalla. Las rutas de encuesta pasan
    // false y conservan sus mensajes de siempre.
    private function Voto_EjecutarDrop takes boolean silent returns nothing
        local integer i = 0
        local integer slot
        local group g
        local unit u
        local unit hero
        local item it
        local integer locID
        local real baseX
        local real baseY
        // Reparto de oro del desertor entre sus aliados (humanos o bots).
        local integer j
        local integer goldD
        local integer allyCount
        local integer share

        if (not silent) then
            if (Voto_AnyHeroDesertor) then
                call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10.0, VOTO_SEP)
                call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10.0, "Resultado: |cffFFCC00DROP|r")
                call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10.0, "Jugador eliminado. Suelta sus items y reparte su oro actual.")
                call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10.0, VOTO_SEP)
            else
                call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10.0, VOTO_SEP)
                call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10.0, "Resultado: |cffFFCC00KICK|r")
                call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10.0, "Jugador expulsado. Reparte su oro actual.")
                call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10.0, VOTO_SEP)
            endif
        endif

        loop
            exitwhen i > 9
            if (Voto_Desertores[i]) then
                // Marcar como procesado para que tabla.j no re-ejecute
                call SaveBoolean(udg_MB_Hash, i, 101, true)

                // Expulsado por encuesta: marca PERSISTENTE. Nunca más vota
                // ni hereda, aunque su slot siga PLAYING (el kick del master
                // llama OnPlayerLeave ANTES de CustomDefeatBJ y el kickeado
                // puede quedarse conectado viendo la derrota).
                set Voto_Expulsado[i] = true

                // === REPARTO DE ORO ACTUAL ===
                // Aplica a DROP y a KICK. El oro ACTUAL del desertor se divide
                // en partes IGUALES entre sus aliados vivos — HUMANOS y BOTS por
                // igual (residuo de la división entera descartado).
                set goldD = GetPlayerState(Player(i), PLAYER_STATE_RESOURCE_GOLD)
                set allyCount = 0
                set j = 0
                loop
                    exitwhen j > 9
                    if (Voto_IsAllyOfDeserter(j, i)) then
                        set allyCount = allyCount + 1
                    endif
                    set j = j + 1
                endloop

                set share = 0
                if (allyCount > 0 and goldD > 0) then
                    set share = goldD / allyCount
                endif

                if (allyCount > 0) then
                    set j = 0
                    loop
                        exitwhen j > 9
                        if (Voto_IsAllyOfDeserter(j, i)) then
                            if (share > 0) then
                                call SetPlayerState(Player(j), PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(Player(j), PLAYER_STATE_RESOURCE_GOLD) + share)
                                // Aviso SOLO al aliado HUMANO (los bots no leen).
                                // Los enemigos NO entran a este loop. En modo
                                // silent el oro igual se acredita; solo
                                // desaparece el texto.
                                if (not silent and GetPlayerController(Player(j)) == MAP_CONTROL_USER) then
                                    call DisplayTimedTextToPlayer(Player(j), 0, 0, 10.0, "Heredas |cffFFCC00+" + I2S(share) + "|r de oro.")
                                endif
                            endif
                        endif
                        set j = j + 1
                    endloop
                    // Vaciar el oro del desertor (repartido; residuo descartado)
                    if (goldD > 0) then
                        call SetPlayerState(Player(i), PLAYER_STATE_RESOURCE_GOLD, 0)
                    endif
                endif

                set locID = GetPlayerStartLocation(Player(i))
                set baseX = GetStartLocationX(locID)
                set baseY = GetStartLocationY(locID)

                // Despausar héroe antes de manipularlo
                set hero = Voto_HeroRef[i]
                if (hero != null) then
                    call PauseUnit(hero, false)
                endif

                // Soltar items y eliminar unidades del jugador
                set g = CreateGroup()
                call GroupEnumUnitsOfPlayer(g, Player(i), null)
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
            endif
            set i = i + 1
        endloop

        // Re-sembrar la línea base del detector de oro F11 (Comandos_Economia.j):
        // el reparto del desertor movió oro entre aliados con SetPlayerState
        // directo (sin pasar por Eco_MoveGold). Si no re-sembramos, el dump del
        // desertor (sobre todo con UN solo aliado restante, que recibe el total
        // exacto) se vería como un par −X/+X y el sondeo lo acreditaría como un
        // regalo F11 falso. Esto absorbe ese movimiento.
        set i = 0
        loop
            exitwhen i > 9
            set Eco_GoldBaseline[i] = GetPlayerState(Player(i), PLAYER_STATE_RESOURCE_GOLD)
            set i = i + 1
        endloop

        set g = null
        set u = null
        set hero = null
        set it = null
    endfunction

    // ==========================================================
    // EJECUCIÓN: RMK — Callback del timer de 2 segundos
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
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 15.0, VOTO_SEP)
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 15.0, "Resultado: |cffFF4444RMK|r")
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 15.0, "Partida cancelada. Expulsando...")
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 15.0, VOTO_SEP)

        set Voto_TimerRmk = CreateTimer()
        call TimerStart(Voto_TimerRmk, RMK_DELAY, false, function Voto_EjecutarRmk_Callback)
    endfunction

    // ==========================================================
    // RESOLUCIÓN: Contar votos, desempatar, ejecutar
    // ==========================================================
    private function Voto_Resolver takes nothing returns nothing
        local integer i = 0
        local integer countBot  = 0
        local integer countDrop = 0
        local integer countRmk  = 0
        local integer bestBot   = 999
        local integer bestDrop  = 999
        local integer bestRmk   = 999
        local integer winner    = VOTE_DROP  // Default si nadie vota
        // Voto ponderado: equipo del desertor y peso del votante actual.
        local boolean desertorIsHuman = Voto_DesertorIsHuman()
        local integer w = 1

        // Guarda anti-doble-resolución: solo UNA resolución por voto.
        // Puede invocarse desde el último clic, el timer de 15s o el recuento
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
            call DialogDisplay(Player(i), Voto_Dialog, false)
            set i = i + 1
        endloop

        // Contar votos (PONDERADO) y registrar orden más temprano por opción.
        // Peso: el voto de un ALIADO del desertor vale 2; el de un enemigo, 1.
        // Da prioridad al equipo afectado sin silenciar al rival. El desempate
        // (best*) sigue por orden de EMISIÓN, sin ponderar.
        set i = 0
        loop
            exitwhen i > 9
            if (Voto_Votos[i] != VOTE_NONE) then
                if ((i <= 4) == desertorIsHuman) then
                    set w = 2
                else
                    set w = 1
                endif
                if (Voto_Votos[i] == VOTE_BOT) then
                    set countBot = countBot + w
                    if (Voto_Orden[i] < bestBot) then
                        set bestBot = Voto_Orden[i]
                    endif
                elseif (Voto_Votos[i] == VOTE_DROP) then
                    set countDrop = countDrop + w
                    if (Voto_Orden[i] < bestDrop) then
                        set bestDrop = Voto_Orden[i]
                    endif
                elseif (Voto_Votos[i] == VOTE_RMK) then
                    set countRmk = countRmk + w
                    if (Voto_Orden[i] < bestRmk) then
                        set bestRmk = Voto_Orden[i]
                    endif
                endif
            endif
            set i = i + 1
        endloop

        // Determinar ganador (mayor conteo; desempate por voto más temprano)
        // Si nadie votó (todo en 0), el default VOTE_DROP se mantiene.
        set winner = VOTE_DROP

        if (countBot > countDrop and countBot > countRmk) then
            // BOT gana con mayoría estricta
            set winner = VOTE_BOT
        elseif (countRmk > countBot and countRmk > countDrop) then
            // RMK gana con mayoría estricta
            set winner = VOTE_RMK
        elseif (countDrop > countBot and countDrop > countRmk) then
            // DROP gana con mayoría estricta
            set winner = VOTE_DROP
        else
            // EMPATE entre 2 o más opciones (o todos en 0)
            // Desempate: la opción cuyo primer voto fue más temprano gana.
            // Si nadie votó, todos los best* quedan en 999 y DROP gana por default.
            if (countBot > 0 and countBot >= countDrop and countBot >= countRmk) then
                if (bestBot <= bestDrop and bestBot <= bestRmk) then
                    set winner = VOTE_BOT
                endif
            endif
            if (countRmk > 0 and countRmk >= countBot and countRmk >= countDrop) then
                if (bestRmk <= bestBot and bestRmk <= bestDrop) then
                    set winner = VOTE_RMK
                endif
            endif
            // Si ningún empate fue resuelto, VOTE_DROP se mantiene como default.
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
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 7.0, " ")
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
        if (clicked == Voto_BtnBot) then
            set vote = VOTE_BOT
        elseif (clicked == Voto_BtnDrop) then
            set vote = VOTE_DROP
        elseif (clicked == Voto_BtnRmk) then
            set vote = VOTE_RMK
        endif

        // Seguridad: Solo registrar si es un voto válido y no ha votado antes
        if (vote != VOTE_NONE and Voto_Votos[id] == VOTE_NONE and Voto_IsValidVoter(id)) then
            // Registrar voto
            set Voto_Votos[id] = vote
            set Voto_OrdenCount = Voto_OrdenCount + 1
            set Voto_Orden[id] = Voto_OrdenCount
            set Voto_Emitidos = Voto_Emitidos + 1

            // Anunciar al público
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 7.0, Voto_GetColor(p) + GetPlayerName(p) + "|r ha votado por: " + Voto_GetVoteName(vote))

            // ¿Votaron TODOS los válidos? ? Resolver de inmediato.
            // Los AFK ya no bloquean: si alguno no vota, el timer de 7s
            // (RESOLVE_TIMEOUT) cierra el voto solo (efectivo en multi).
            if (Voto_Emitidos >= Voto_Validos) then
                call Voto_Resolver()
            endif
        endif

        set p = null
        set clicked = null
    endfunction

    // ==========================================================
    // ¿Fase 0 (castillo o fortaleza) vulnerable?
    // ==========================================================
    // Lee los booleanos globales del anti-backdoor (Sistema_AntiBackdoor.j):
    // pasan a true cuando cae por completo la F1 de esa facción y su F0
    // (castillo 'hcas' / fortaleza 'ofrt') queda atacable. Basta con que UNA
    // facción tenga su F0 abierta: la partida está por definirse.
    private function Voto_F0Vulnerable takes nothing returns boolean
        return AB_HUM_F0_Open or AB_ORC_F0_Open
    endfunction

    // ==========================================================
    // ¿Algún desertor pendiente conserva su héroe?
    // ==========================================================
    // Fija Voto_AnyHeroDesertor, que decide el texto DROP (con héroe) vs
    // KICK (sin héroe) en Voto_EjecutarDrop y el set de botones del Dialog.
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
    // (comportamiento del motor), por eso allí el timer de 7s queda congelado;
    // es inofensivo porque el único votante (el host) siempre puede cerrar.
    // Llamada directamente desde OnPlayerLeave (que corre en trigger-context).
    private function Voto_AbrirVotacion takes nothing returns nothing
        local integer i = 0

        // Cambiar estado
        set Voto_State = 2

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

        // Detectar si algún desertor tiene héroe (Caso 1 vs Caso 2)
        call Voto_RefreshAnyHeroDesertor()

        // Preparar Dialog
        call DialogClear(Voto_Dialog)
        call DialogSetMessage(Voto_Dialog, "Que hacer con el desconectado?")
        if (Voto_AnyHeroDesertor) then
            // CASO 2: Tiene héroe.
            set Voto_BtnDrop = DialogAddButton(Voto_Dialog, "DROP (Soltar items y repartir su oro)", 0)
            // BOT solo está permitido FUERA del Modo Aleatorio de Habilidades.
            // Con ModoAl_Activo, un bot no puede reemplazar al desertor: se omite
            // la opción para garantizar que ningún bot juegue ese modo.
            if (not ModoAl_Activo) then
                set Voto_BtnBot = DialogAddButton(Voto_Dialog, "BOT (Un BOT lo reemplaza)", 0)
            else
                set Voto_BtnBot = null
            endif
            set Voto_BtnRmk  = DialogAddButton(Voto_Dialog, "RMK (Expulsar a todos)", 0)
        else
            // CASO 1: No tiene héroe ? 2 opciones (sin BOT)
            set Voto_BtnDrop = DialogAddButton(Voto_Dialog, "KICK (Repartir su oro y seguir)", 0)
            set Voto_BtnBot  = null
            set Voto_BtnRmk  = DialogAddButton(Voto_Dialog, "RMK (Expulsar a todos)", 0)
        endif

        // Mostrar a todos los votantes válidos
        set i = 0
        loop
            exitwhen i > 9
            if (Voto_IsValidVoter(i)) then
                call DialogDisplay(Player(i), Voto_Dialog, true)
            endif
            set i = i + 1
        endloop

        // Red de seguridad: cerrar el voto a los 15s aunque queden AFKs.
        // (Solo dispara en multi; en SP el Dialog pausa el juego y lo congela.)
        set Voto_TimerResolve = CreateTimer()
        call TimerStart(Voto_TimerResolve, RESOLVE_TIMEOUT, false, function Voto_Resolver)

        // Aviso central para quienes ya votaron (se irá mostrando a medida que
        // cada uno emita su voto y desaparece al resolver/descongelar).
        set Voto_TimerBanner = CreateTimer()
        call TimerStart(Voto_TimerBanner, BANNER_UPDATE_INTERVAL, true, function Voto_BannerLoop)
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
            call DialogDisplay(Player(i), Voto_Dialog, false)
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

        // Capturar héroe ANTES de que otro sistema lo borre
        call Voto_CapturarHeroe(p)

        // Marcar como desertor
        set Voto_Desertores[id] = true
        set Voto_NumDesertores = Voto_NumDesertores + 1

        // --- FASE 0 VULNERABLE: DROP automático, sin encuesta y SIN MENSAJES ---
        // Si el castillo/fortaleza (F0) de CUALQUIER facción ya está
        // desbloqueado, la partida está por definirse: no interrumpimos con la
        // votación NI con textos propios (silent=true). Queda solo el aviso de
        // abandono estándar de tabla.j/Sistema_Kick; el efecto DROP (items,
        // oro) se aplica completo en silencio, reutilizando
        // Voto_EjecutarDrop para heredar sin duplicar cualquier cambio futuro
        // de la lógica de DROP.
        // Guarda != 2: si un voto ya estaba abierto (empezó antes de que cayera
        // la F1), lo dejamos resolver por su vía normal en vez de pisarlo.
        if (Voto_F0Vulnerable() and Voto_State != 2) then
            call Voto_RefreshAnyHeroDesertor()
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
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 5.0, "|cffFFCC00[SISTEMA]|r Abandono adicional registrado.")
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
        set Voto_Dialog = DialogCreate()
        call TriggerRegisterDialogEvent(t, Voto_Dialog)
        call TriggerAddAction(t, function Voto_OnDialogClick)
        set t = null

        // Sonido persistente: se crea una vez en init para evitar el bug de
        // "primera reproducción silenciosa" (mismo patrón que AntiBackdoor)
        set Voto_SndResult = CreateSound("Sound\\Interface\\SecretFound.wav", false, false, false, 10, 10, "")
        call SetSoundVolume(Voto_SndResult, 127)
    endfunction

endlibrary
