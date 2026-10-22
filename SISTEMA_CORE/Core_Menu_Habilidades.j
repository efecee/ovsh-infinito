// ==========================================================================
// Core_Menu_Habilidades.j — Pantalla 4: Modo de Habilidades
// ==========================================================================
//
// PROPÓSITO:
//   Cuarta (última) pantalla de configuración. El Master elige entre:
//     - Clásico: Habilidades originales (sin cambios).
//     - Aleatorio: Habilidades redistribuidas por columna (Q?Q, W?W, etc.).
//
// FLUJO:
//   Pantalla 1 (Modo, Core_Menu_Modo.j) -> Pantalla 2 (Oro) -> Pantalla 3
//   (Héroes) -> [ESTA] Pantalla 4 (Habilidades)
//   -> Reglas del Modo Rápido + Cámara + Descongelar + Random + Shuffle + IA
//   (Con bots no aparecen ni la pantalla de modo ni esta.)
//
//   EXCEPCIÓN BOTS: Si la partida arrancó con bots (udg_Core_HayBots == true),
//   la Pantalla 4 NUNCA se muestra: se fuerza Clásico automáticamente. Esto
//   garantiza que ningún bot juegue el Modo Aleatorio de Habilidades.
//
// DEPENDENCIAS:
//   - ModoAleatorio (library en Modo_Aleatorio_DB.j)
//   - SistemaVoto (library en Sistema_Voto.j): aviso de fin de menús para
//     abrir la votación diferida (abandonos durante carga/menús)
//   - CoreMenuModo (library en Core_Menu_Modo.j): aplica las reglas del Modo
//     Rápido al terminar los menús
//   - Variables udg_* del editor GUI (Config_Modo_*, Core_*, unit*, etc.)
//   - Triggers GUI: gg_trg_Core_Logica_Random, gg_trg_IA_Permisos
//
// ==========================================================================

library MenuHabilidades initializer OnInit requires ModoAleatorio, SistemaVoto, CoreMenuModo

    globals
        private dialog   menuDlg      = null
        private button   btnClasico   = null
        private button   btnAleatorio = null
        private integer  modoHabil    = 1      // 1 = Clásico, 2 = Aleatorio
        private timer    initTimer    = null   // Timer para detectar héroes
        private hashtable initDb      = null   // Tracking de héroes inicializados
        private integer  initCount    = 0
        private integer  initMaxPlayers = 0
        private real     initTime     = 0.0
        // Sonido "configuración terminada" (QuestNew). Se crea una vez en OnInit
        // para evitar el bug de "primera reproducción silenciosa" (mismo patrón
        // que Sistema_Voto / AntiBackdoor). Suena una sola vez por partida.
        private sound    sndConfigDone = null
    endglobals

    // ==============================
    // API PÚBLICA: Consultar el modo seleccionado
    // ==============================
    public function GetModoHabilidades takes nothing returns integer
        return modoHabil
    endfunction

    // ==============================
    // TIMER: Detecta héroes y los inicializa para modo aleatorio
    // ==============================
    private function InitTimerCB takes nothing returns nothing
        local integer i = 0
        local group g
        local unit u
        local integer hId

        set initTime = initTime + 0.50

        loop
            exitwhen i > 9
            if GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
                set g = CreateGroup()
                call GroupEnumUnitsOfPlayer(g, Player(i), null)
                loop
                    set u = FirstOfGroup(g)
                    exitwhen u == null
                    call GroupRemoveUnit(g, u)
                    if IsUnitType(u, UNIT_TYPE_HERO) and not IsUnitIllusion(u) and GetWidgetLife(u) > 0.405 then
                        set hId = GetHandleId(u)
                        if not LoadBoolean(initDb, hId, 0) then
                            call ModoAleatorio_InitHeroForRandomMode(u)
                            call SaveBoolean(initDb, hId, 0, true)
                            set initCount = initCount + 1
                        endif
                    endif
                endloop
                call DestroyGroup(g)
            endif
            set i = i + 1
        endloop

        if initCount >= initMaxPlayers then
            call PauseTimer(initTimer)
            call DestroyTimer(initTimer)
            set initTimer = null
        endif
    endfunction

    function InitRandomModeTimer takes nothing returns nothing
        local integer i = 0
        set initCount = 0
        set initTime  = 0.0
        set initMaxPlayers = 0
        // Contar jugadores activos reales
        loop
            exitwhen i > 9
            if GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
                set initMaxPlayers = initMaxPlayers + 1
            endif
            set i = i + 1
        endloop
        if initDb == null then
            set initDb = InitHashtable()
        endif
        set initTimer = CreateTimer()
        call TimerStart(initTimer, 0.50, true, function InitTimerCB)
    endfunction

    // ==============================
    // LÓGICA POST-SELECCIÓN
    // Asume que 'modoHabil' ya fue fijado (1=Clásico, 2=Aleatorio).
    // Reutilizada por:
    //   - OnClick()        : tras el clic del Master en la Pantalla 4.
    //   - MostrarPantalla(): ruta de bots, sin mostrar Pantalla 4 (Clásico forzado).
    // ==============================
    private function EjecutarPostSeleccion takes nothing returns nothing
        // --- 0. REGLAS DEL MODO RÁPIDO ---
        // Se aplican AQUÍ, con todas las pantallas ya respondidas y el juego
        // todavía congelado: si el Master rotó a mitad de los menús, nada quedó
        // aplicado a medias. En modo Normal no hace nada. Ver Core_Menu_Modo.j.
        call CoreMenuModo_Aplicar()

        // --- 1. MENSAJE ULTRA SHORT ---
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10.0, "|cFFFFCC00Modo:|r Ultra Short activado por defecto (+100% XP).")

        // --- 2. DESBLOQUEAR SELECTORES Y CÁMARA INTELIGENTE ---
        // Los Wisps/Almas estaban congelados para evitar control prematuro durante los menús.
        call CoreMasterAFK_UnlockSelectors()

        // A) CÁMARA HUMANOS (Solo si eligieron Pick)
        if (udg_Config_Modo_Humanos == 1) then
            if (GetLocalPlayer() == Player(0)) then
                call PanCameraToTimed(GetUnitX(udg_unit14), GetUnitY(udg_unit14), 0.0)
                call ClearSelection()
                call SelectUnit(udg_unit14, true)
            elseif (GetLocalPlayer() == Player(1)) then
                call PanCameraToTimed(GetUnitX(udg_unit15), GetUnitY(udg_unit15), 0.0)
                call ClearSelection()
                call SelectUnit(udg_unit15, true)
            elseif (GetLocalPlayer() == Player(2)) then
                call PanCameraToTimed(GetUnitX(udg_unit16), GetUnitY(udg_unit16), 0.0)
                call ClearSelection()
                call SelectUnit(udg_unit16, true)
            elseif (GetLocalPlayer() == Player(3)) then
                call PanCameraToTimed(GetUnitX(udg_unit17), GetUnitY(udg_unit17), 0.0)
                call ClearSelection()
                call SelectUnit(udg_unit17, true)
            elseif (GetLocalPlayer() == Player(4)) then
                call PanCameraToTimed(GetUnitX(udg_unit18), GetUnitY(udg_unit18), 0.0)
                call ClearSelection()
                call SelectUnit(udg_unit18, true)
            endif
        endif

        // B) CÁMARA ORCOS (Solo si eligieron Pick)
        if (udg_Config_Modo_Orcos == 1) then
            if (GetLocalPlayer() == Player(5)) then
                call PanCameraToTimed(GetUnitX(udg_unit39), GetUnitY(udg_unit39), 0.0)
                call ClearSelection()
                call SelectUnit(udg_unit39, true)
            elseif (GetLocalPlayer() == Player(6)) then
                call PanCameraToTimed(GetUnitX(udg_unit40), GetUnitY(udg_unit40), 0.0)
                call ClearSelection()
                call SelectUnit(udg_unit40, true)
            elseif (GetLocalPlayer() == Player(7)) then
                call PanCameraToTimed(GetUnitX(udg_unit41), GetUnitY(udg_unit41), 0.0)
                call ClearSelection()
                call SelectUnit(udg_unit41, true)
            elseif (GetLocalPlayer() == Player(8)) then
                call PanCameraToTimed(GetUnitX(udg_unit42), GetUnitY(udg_unit42), 0.0)
                call ClearSelection()
                call SelectUnit(udg_unit42, true)
            elseif (GetLocalPlayer() == Player(9)) then
                call PanCameraToTimed(GetUnitX(udg_unit43), GetUnitY(udg_unit43), 0.0)
                call ClearSelection()
                call SelectUnit(udg_unit43, true)
            endif
        endif

        // --- 3. DESCONGELAR JUEGO ---
        call PauseGame(false)

        // --- 3b. SONIDO: CONFIGURACIÓN DEL MASTER TERMINADA ---
        // Punto único de convergencia: con bots se llega aquí tras la pantalla de
        // héroes y sin bots tras la de habilidades. En ambos casos el
        // juego se acaba de descongelar = el Master terminó de configurar la sala.
        call SetSoundVolume(sndConfigDone, 127)
        call StartSound(sndConfigDone)

        // --- 4. EJECUTAR LÓGICA RANDOM (héroes) ---
        if (udg_Config_Modo_Humanos == 2 or udg_Config_Modo_Orcos == 2) then
            call TriggerExecute(gg_trg_Core_Logica_Random)
        endif

        // --- 5. SETUP MODO ALEATORIO (si Aleatorio) ---
        if modoHabil == 2 then
            set ModoAl_Activo = true
            // Iniciar timer que detecta héroes y los prepara
            call InitRandomModeTimer()
        endif

        // --- 6. PERMISOS IA (BOTS) ---
        if (udg_Core_HayBots) then
            if (udg_Config_Modo_Humanos != 2 or udg_Config_Modo_Orcos != 2) then
                call TriggerExecute(gg_trg_IA_Permisos)
            endif
        endif

        // --- 7. VOTACIÓN DIFERIDA (Sistema_Voto) ---
        // Si alguien abandonó durante la pantalla de carga o los menús, la
        // votación se DIFIRIÓ para no pisar los Dialogs del Master (WC3 solo
        // permite un Dialog visible por jugador). Ahora que la configuración
        // terminó y la pantalla está libre, se abre la encuesta. DEBE ser el
        // último paso: así el voto congela un estado ya estable (héroes
        // random creados, modo de habilidades decidido).
        call SistemaVoto_OnMenusFinished()
    endfunction

    // ==============================
    // HANDLER: Click en Pantalla 4
    // ==============================
    private function OnClick takes nothing returns nothing
        // Fase de menús completada: desactivar vigilancia de Leave
        call CoreMasterAFK_Finish()

        // --- GUARDAR MODO DE HABILIDADES ---
        if GetClickedButton() == btnClasico then
            set modoHabil = 1
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10.0, "|cFFFFCC00Modo Habilidades:|r Clasico (Original)")
        else
            set modoHabil = 2
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10.0, "|cFFFFCC00Modo Habilidades:|r Aleatorio (Shuffle)")
        endif

        call EjecutarPostSeleccion()
    endfunction

    // ==============================
    // API PÚBLICA: Muestra la Pantalla 4 al Master
    // Llamada desde Core_Menu_Heroes_Click.j
    // ==============================
    public function MostrarPantalla takes nothing returns nothing
        // --- EXCEPCIÓN BOTS: Modo Aleatorio PROHIBIDO con bots ---
        // Si la partida arrancó con bots, saltamos la Pantalla 4 y forzamos
        // Clásico. Así ningún bot puede jugar el Modo Aleatorio de Habilidades.
        if (udg_Core_HayBots) then
            call CoreMasterAFK_Finish()
            set modoHabil = 1
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10.0, "|cFFFFCC00Modo Habilidades:|r Clasico (Original)")
            call EjecutarPostSeleccion()
            return
        endif

        call DialogClear(menuDlg)
        call DialogSetMessage(menuDlg, "Selecciona el Modo de Habilidades")
        set btnClasico  = DialogAddButton(menuDlg, "Clasico (Original)", 0)
        set btnAleatorio = DialogAddButton(menuDlg, "Aleatorio (Shuffle)", 0)
        call DialogDisplay(udg_Core_JugadorMaestro, menuDlg, true)
    endfunction

    // ==============================
    // INICIALIZACIÓN
    // ==============================
    private function OnInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        set menuDlg = DialogCreate()
        call TriggerRegisterDialogEvent(t, menuDlg)
        call TriggerAddAction(t, function OnClick)
        set t = null

        // Sonido persistente "configuración terminada": se crea una sola vez aquí
        // para evitar el bug de primera reproducción silenciosa (se reproduce con
        // SetSoundVolume + StartSound en EjecutarPostSeleccion).
        set sndConfigDone = CreateSound("Sound\\Interface\\QuestNew.wav", false, false, false, 10, 10, "")
        call SetSoundVolume(sndConfigDone, 127)
    endfunction

endlibrary
