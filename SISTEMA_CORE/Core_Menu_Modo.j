//===========================================================================
// CORE: MODO DE PARTIDA (Pantalla 1 del Master) + REGLAS DEL MODO RAPIDO
//===========================================================================
// ORDEN DE LAS PANTALLAS DEL MASTER:
//   Sala SIN bots: 1) Modo (este archivo) -> 2) Oro (Core_Menu_Oro.j)
//                  -> 3) Heroes (Core_Menu_Heroes.j) -> 4) Habilidades
//                  (Core_Menu_Habilidades.j).
//   Sala CON bots: no hay Modo Rapido. Esta pantalla no se muestra: se juega
//                  Normal y la primera pantalla es la de oro (y, como siempre,
//                  no aparece la de habilidades).
//
// MASTER AFK: los 15 s de Core_Master_AFK.j se cuentan en la PRIMERA pantalla
// visible (esta, o la de oro si hay bots). Si el Master rota o se va,
// Core_Master_AFK vuelve a ejecutar este detonador (gg_trg_Core_Menu_Modo) y
// la configuracion empieza otra vez desde aqui.
//
// MODO RAPIDO (solo salas sin bots). Lo elegido se GUARDA al hacer clic, pero
// las reglas recien se APLICAN al terminar la ultima pantalla
// (CoreMenuModo_Aplicar, la llama Core_Menu_Habilidades.j). Asi, si el Master
// rota a mitad de los menus, no queda nada aplicado a medias:
//   1. Las estructuras de fase (grupos AB_* de Sistema_AntiBackdoor.j) pasan a
//      tener la MITAD DE SU VIDA MAXIMA, con la barra llena (asi no arrancan
//      en llamas: el fuego del motor sale segun el % de vida). En 1.27b no hay
//      nativa para cambiar la vida maxima: se usa la habilidad del Editor de
//      Objetos MODO_RAPIDO_ABIL_VIDA (ver ReducirVidaMaxima). Si esa habilidad
//      no existe, plan B: la vida ACTUAL queda en la mitad (con fuego) y sale
//      un aviso.
//   2. Se quitan las dos tabernas ('ntav' humana, 'n00F' orca): venden los
//      obreros, que son la unica forma de reparar.
//   3. Ninguna armadura se fusiona. Lo filtran Fusiones Clasicas.j (las de
//      5500) y Baluarte de Lothar / Vestiduras de Ner zhul / Manto de Maiev
//      (las de 3 piezas). Los daños siguen fusionandose.
//   Otros sistemas que leen el modo: Core_Menu_Oro.j y Core_Menu_Click.j (oro
//   12/15/18), Sistema_Voto.j (sin opcion BOT) y Sistema_Victoria.j (vida de
//   inicio de los edificios y linea "Modo" del resumen final).
//
// AVISOS DE REGLAS: bloques de 10 s, cada uno en el momento tranquilo de
// quien lo ve (nadie ve los dos), contado desde el fin de la configuracion.
// Objetivo: que ningun mensaje programado comparta la pantalla con otro.
//   - "MODO RAPIDO" (los 10 jugadores, solo si el Master lo eligio): 60 s
//     despues. El primer minuto es el de los comandos de inicio (-ma, -al,
//     -as, -z). El rapido nunca tiene bots.
//   - "MODO OBSERVADOR" (los observadores, siempre;
//     Observadores_MostrarReglas, Core_Observadores.j): no usan esos
//     comandos, asi que sale 15 s despues (los textos de configuracion duran
//     10 s). Con bots, 3 s despues del ultimo mensaje de los bots, que salen
//     a hora fija desde el fin de la configuracion: "Los bots atacan" de
//     IA_Arrancar (60 + 5 s) o, con los dos equipos al azar, "Bots
//     activados!" de Core_Logica_Random (25 + 5 s). Si cambian esos tiempos,
//     actualizar BOTS_FIN / BOTS_AZAR_FIN. Mientras se acerca y dura, los
//     clics del observador en un heroe no muestran su bloque
//     (Observadores_ReservarPantalla).
//   Si un aviso caeria encima del aviso del F9 (Zoom.j: sale a los 75 s de
//   juego y dura 12 s), sale cuando ese termina. Los dos sonidos suenan solo
//   para quien recibe el bloque.
//
// INSTALACION EN EL EDITOR: crear un detonador NUEVO llamado EXACTAMENTE
// "Core_Menu_Modo", Editar > Convertir en texto personalizado, y pegar este
// archivo. No crea variables en el gestor de variables (udg_): el dialogo y
// sus botones viven aqui, igual que en Core_Menu_Habilidades.j.
//
// HABILIDAD DEL EDITOR DE OBJETOS (para bajar la vida maxima):
//   Nueva habilidad basada en "Objeto Bonificacion de vida (Minimo)" (AIlf).
//   Niveles = 6. Campo "Vida max. ganada" por nivel (POSITIVOS):
//     nivel 1 = 0, nivel 2 = 1, nivel 3 = 10, nivel 4 = 100,
//     nivel 5 = 1000, nivel 6 = 10000.
//   Su rawcode va en MODO_RAPIDO_ABIL_VIDA (abajo). El nivel 1 TIENE que ser 0.
//   Son positivos aunque la vida BAJA: ver el truco en ReducirVidaMaxima.
//   (Con valores negativos la vida maxima SUBE: probado en juego el
//   2026-10-20, una torre de 6000 quedo en 9000.)
//===========================================================================

library ModoPartida
    // Estado del modo de partida. Library SIN dependencias para que cualquier
    // sistema pueda consultarla.

    globals
        // Fraccion de su vida maxima original que tienen las estructuras de
        // fase en el modo rapido.
        constant real MODO_RAPIDO_VIDA_ESTRUCTURAS = 0.50
        private boolean rapido = false
        // Vida con la que empezaron las estructuras, como fraccion de su vida
        // maxima ACTUAL: 1.0 si se bajo la vida maxima (barra llena); la
        // fraccion de arriba si se uso el plan B (vida actual a la mitad).
        private real factorInicio = 1.0
    endglobals

    // true si el Master eligio el modo rapido en la Pantalla 1.
    public function EsRapido takes nothing returns boolean
        return rapido
    endfunction

    // Solo la usa CoreMenuModo (clic en la Pantalla 1, o al volver a mostrarla).
    public function SetRapido takes boolean activo returns nothing
        set rapido = activo
    endfunction

    // Vida de inicio de las estructuras de fase, como fraccion de su vida
    // maxima actual. 1.0 en normal y en rapido con la vida maxima ya bajada;
    // MODO_RAPIDO_VIDA_ESTRUCTURAS solo si se uso el plan B. Lo usa
    // Sistema_Victoria.j para el aviso "quedo al X%".
    public function FactorVidaEstructuras takes nothing returns real
        if (rapido) then
            return factorInicio
        endif
        return 1.0
    endfunction

    // Solo la usa CoreMenuModo, si tuvo que usar el plan B.
    public function SetFactorVidaEstructuras takes real factor returns nothing
        set factorInicio = factor
    endfunction
endlibrary

library CoreMenuModo initializer Init requires ModoPartida, CoreMasterAFK, Observadores

    globals
        // Habilidad "Modo Rapido - Vida maxima" del Editor de Objetos (ver la
        // cabecera). REEMPLAZAR por el rawcode que le asigne el editor. Si el
        // rawcode no existe, se usa el plan B (vida actual a la mitad) y avisa.
        private constant integer MODO_RAPIDO_ABIL_VIDA = 'A062'

        // Avisos de reglas: segundos despues de terminar la configuracion, y
        // cuanto quedan en pantalla (ver la cabecera).
        private constant real RAPIDO_RETRASO = 60.0
        private constant real OBS_RETRASO    = 15.0
        private constant real BOTS_FIN       = 65.0   // "Los bots atacan" se apaga
        private constant real BOTS_AZAR_FIN  = 30.0   // "Bots activados!" se apaga
        private constant real MARGEN         = 3.0
        private constant real AVISO_DURACION = 10.0
        // Aviso del F9 (Zoom.j): sale a los 75 s de juego y dura 12 s. Se deja
        // un margen de 3 s a cada lado para que los dos avisos no se junten.
        private constant real F9_AVISO_INICIO = 72.0
        private constant real F9_AVISO_FIN    = 90.0

        private dialog  ventana    = null
        private button  btnNormal  = null
        private button  btnRapido  = null
        private boolean avisoBots  = false  // con bots, "Modo: Partida normal" sale una sola vez
        private boolean aplicado   = false
        private boolean planB      = false  // alguna estructura no pudo bajar su vida maxima
        // Prueba de la habilidad, una vez por partida: 0 = sin probar,
        // 1 = baja la vida maxima (bien), 2 = no la baja (falta o mal armada).
        private integer estadoHabVida = 0
        // Tiempo de juego desde la carga. Como todo timer, no corre mientras
        // el juego esta pausado, igual que el aviso del F9.
        private timer   reloj      = null
        // Segundo sonido del aviso de reglas (el mismo que el aviso del F9 de
        // Zoom.j). Se crea UNA vez en Init y se reutiliza: creado al momento
        // de sonar, la primera reproduccion sale muda (patron MB_Snd_Leave).
        private sound   sndAviso   = null
    endglobals

    // ==========================================================
    // PANTALLA 1. La ejecuta el detonador Core_Menu_Modo a 1 s de partida y
    // Core_Master_AFK cada vez que rota al Master.
    // ==========================================================
    public function Mostrar takes nothing returns nothing
        local integer i = 0

        // Si el Master cerro durante la carga o en el primer segundo, rotar
        // ANTES de mostrar la pantalla: si no, se muestra a un fantasma y
        // nadie puede configurar la partida.
        call CoreMasterAFK_EnsureMasterValid()

        // Empezar de nuevo: el modo se vuelve a elegir y la ventana se oculta
        // a todos (por si el Master anterior seguia con ella abierta).
        call ModoPartida_SetRapido(false)
        // Renta 0 hasta que el nuevo Master elija el oro. Si el anterior se fue
        // en las pantallas 2 a 4, la renta que eligio seguiria puesta y, con
        // 2+ humanos, CoreMasterAFK_Start descongela el juego mientras se
        // espera al nuevo: todos cobrarian antes de terminar la configuracion.
        // En la primera llamada (1 s de partida) ya vale 0.
        set udg_Config_Cantidad_Oro = 0
        loop
            exitwhen i > 9
            call DialogDisplay(Player(i), ventana, false)
            set i = i + 1
        endloop

        // CON BOTS: no hay Modo Rapido. Se juega Normal y la primera pantalla
        // es la de oro, como antes de existir esta pantalla.
        if (udg_Core_HayBots) then
            if (not avisoBots) then
                set avisoBots = true
                call DisplayTimedTextToForce(GetPlayersAll(), 10.00, "|cFFFFCC00Modo:|r Partida normal")
            endif
            call TriggerExecute(gg_trg_Core_Menu_Oro)
            call CoreMasterAFK_Start()
            return
        endif

        // El juego pinta de blanco el primer boton: Normal queda por defecto.
        call DialogClear(ventana)
        call DialogSetMessage(ventana, "Selecciona el Modo de Partida")
        set btnNormal = DialogAddButton(ventana, "Partida normal", 0)
        set btnRapido = DialogAddButton(ventana, "Partida rapida", 0)
        call DialogDisplay(udg_Core_JugadorMaestro, ventana, true)

        // Pausa / congelado de selectores / timer AFK segun cantidad de humanos.
        call CoreMasterAFK_Start()
    endfunction

    // Clic en la Pantalla 1: guarda el modo, lo anuncia y abre la de oro.
    private function OnClick takes nothing returns nothing
        local button clicked = GetClickedButton()

        // El Master respondio: detener el temporizador AFK y congelar el juego.
        call CoreMasterAFK_Stop()

        if (clicked == btnRapido) then
            call ModoPartida_SetRapido(true)
            call DisplayTimedTextToForce(GetPlayersAll(), 10.00, "|cFFFFCC00Modo:|r Partida rapida")
        else
            call ModoPartida_SetRapido(false)
            call DisplayTimedTextToForce(GetPlayersAll(), 10.00, "|cFFFFCC00Modo:|r Partida normal")
        endif

        // Pantalla 2: oro, con las opciones del modo elegido.
        call TriggerExecute(gg_trg_Core_Menu_Oro)

        set clicked = null
    endfunction

    // ==========================================================
    // REGLAS DEL MODO RAPIDO
    // ==========================================================

    // Baja la vida MAXIMA de u en 'cuanto' puntos, en "monedas" de 10000, 1000,
    // 100, 10 y 1 (niveles 6 a 2 de MODO_RAPIDO_ABIL_VIDA). Truco conocido de
    // 1.2x con "Objeto Bonificacion de vida": al AGREGARLA se suma el bono del
    // nivel 1 (0); al cambiarle el nivel el bono NO se actualiza; y al QUITARLA
    // el motor resta el bono del nivel en que quedo. Resultado de agregar ->
    // nivel N -> quitar: la vida maxima baja el valor del nivel N, para siempre.
    // Por eso los niveles son POSITIVOS. Es el mismo truco de SetUnitMaxState.
    // Si la habilidad no existe, UnitAddAbility no hace nada.
    private function ReducirVidaMaxima takes unit u, integer cuanto returns nothing
        local integer moneda = 10000
        local integer nivel = 6
        loop
            exitwhen moneda < 1
            loop
                exitwhen cuanto < moneda
                if (not UnitAddAbility(u, MODO_RAPIDO_ABIL_VIDA)) then
                    return
                endif
                call SetUnitAbilityLevel(u, MODO_RAPIDO_ABIL_VIDA, nivel)
                call UnitRemoveAbility(u, MODO_RAPIDO_ABIL_VIDA)
                set cuanto = cuanto - moneda
            endloop
            set moneda = moneda / 10
            set nivel = nivel - 1
        endloop
    endfunction

    private function ReducirVidaCallback takes nothing returns nothing
        local unit u = GetEnumUnit()
        local real maxOriginal = GetUnitState(u, UNIT_STATE_MAX_LIFE)
        local integer objetivo = R2I(maxOriginal * MODO_RAPIDO_VIDA_ESTRUCTURAS + 0.5)

        // PRUEBA (solo con la primera estructura): bajar 1 punto y mirar que la
        // vida maxima de verdad BAJO. Si la habilidad falta o tiene los niveles
        // con el signo al reves, no se toca ninguna estructura mas (como mucho
        // esta queda con 1 punto de mas) y se usa el plan B.
        if (estadoHabVida == 0) then
            if (UnitAddAbility(u, MODO_RAPIDO_ABIL_VIDA)) then
                call SetUnitAbilityLevel(u, MODO_RAPIDO_ABIL_VIDA, 2)
                call UnitRemoveAbility(u, MODO_RAPIDO_ABIL_VIDA)
            endif
            if (GetUnitState(u, UNIT_STATE_MAX_LIFE) < maxOriginal - 0.5) then
                set estadoHabVida = 1
            else
                set estadoHabVida = 2
            endif
        endif

        if (estadoHabVida == 1) then
            call ReducirVidaMaxima(u, R2I(GetUnitState(u, UNIT_STATE_MAX_LIFE) + 0.5) - objetivo)
        endif
        if (GetUnitState(u, UNIT_STATE_MAX_LIFE) > objetivo + 0.5) then
            set planB = true   // no bajo la vida maxima: queda la vida actual a la mitad
        endif
        // Barra llena con la nueva vida maxima (en el plan B, la mitad de la barra).
        call SetWidgetLife(u, objetivo)
        set u = null
    endfunction

    // Regla 1. Los grupos AB_* ya estan llenos: Sistema_AntiBackdoor.j los
    // arma con un timer de 0 s al cargar el mapa.
    private function ReducirVidaEstructuras takes nothing returns nothing
        call ForGroup(AB_HUM_F0,     function ReducirVidaCallback)
        call ForGroup(AB_HUM_F1,     function ReducirVidaCallback)
        call ForGroup(AB_HUM_F2_TOP, function ReducirVidaCallback)
        call ForGroup(AB_HUM_F2_BOT, function ReducirVidaCallback)
        call ForGroup(AB_HUM_F3_TOP, function ReducirVidaCallback)
        call ForGroup(AB_HUM_F3_BOT, function ReducirVidaCallback)
        call ForGroup(AB_ORC_F0,     function ReducirVidaCallback)
        call ForGroup(AB_ORC_F1,     function ReducirVidaCallback)
        call ForGroup(AB_ORC_F2_TOP, function ReducirVidaCallback)
        call ForGroup(AB_ORC_F2_BOT, function ReducirVidaCallback)
        call ForGroup(AB_ORC_F3_TOP, function ReducirVidaCallback)
        call ForGroup(AB_ORC_F3_BOT, function ReducirVidaCallback)
        if (planB) then
            // Para el aviso "quedo al X%" de Sistema_Victoria.j: el 100% es la
            // vida con la que empezo.
            call ModoPartida_SetFactorVidaEstructuras(MODO_RAPIDO_VIDA_ESTRUCTURAS)
            call DisplayTimedTextToForce(GetPlayersAll(), 15.00, "|cffFF4444Modo Rapido:|r la habilidad de vida maxima no funciona (revisa sus niveles).")
        endif
    endfunction

    // Regla 2. Las tabernas son del jugador neutral pasivo (init.j) y ningun
    // otro codigo las usa.
    private function QuitarTabernas takes nothing returns nothing
        local group g = CreateGroup()
        local unit u
        call GroupEnumUnitsOfPlayer(g, Player(PLAYER_NEUTRAL_PASSIVE), null)
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            call GroupRemoveUnit(g, u)
            if (GetUnitTypeId(u) == 'ntav' or GetUnitTypeId(u) == 'n00F') then
                call RemoveUnit(u)
            endif
        endloop
        call DestroyGroup(g)
        set g = null
        set u = null
    endfunction

    // Los mismos dos sonidos que el aviso del F9 (Zoom.j). Se llama solo en
    // la pantalla de quien recibe el bloque (como StartSoundForPlayerBJ: el
    // sonido no altera la partida, asi que tocarlo en un solo cliente no
    // desincroniza).
    private function Sonar takes nothing returns nothing
        call StartSound(bj_questUpdatedSound)
        call StartSound(sndAviso)
    endfunction

    // Una llamada por linea: en los mensajes de pantalla "|n" NO salta de linea
    // (sale escrito tal cual; solo funciona en el F9, tooltips y dialogos).
    // Se envia slot por slot (como Replay_DisplayTimedTextToAll) para que la
    // repeticion muestre el bloque del jugador observado.
    private function MostrarAvisoRapido takes nothing returns nothing
        local integer i = 0
        local player p
        call DestroyTimer(GetExpiredTimer())
        loop
            exitwhen i > 9
            set p = Player(i)
            call DisplayTimedTextToPlayer(p, 0, 0, AVISO_DURACION, "|cffFFCC00MODO RAPIDO|r")
            call DisplayTimedTextToPlayer(p, 0, 0, AVISO_DURACION, "- Las estructuras tienen la mitad de vida.")
            call DisplayTimedTextToPlayer(p, 0, 0, AVISO_DURACION, "- No hay tabernas: nadie puede reparar.")
            call DisplayTimedTextToPlayer(p, 0, 0, AVISO_DURACION, "- Ninguna armadura se fusiona (los daños sí).")
            set i = i + 1
        endloop
        if (GetPlayerId(GetLocalPlayer()) <= 9) then
            call Sonar()
        endif
        set p = null
    endfunction

    private function MostrarAvisoObservador takes nothing returns nothing
        call DestroyTimer(GetExpiredTimer())
        if (Observadores_Es(Player(10))) then
            call Observadores_MostrarReglas(Player(10), AVISO_DURACION)
        endif
        if (Observadores_Es(Player(11))) then
            call Observadores_MostrarReglas(Player(11), AVISO_DURACION)
        endif
        if (Observadores_Es(GetLocalPlayer())) then
            call Sonar()
        endif
    endfunction

    // Segundos desde ahora hasta un aviso que quiere salir dentro de
    // "retraso" s. Si se juntaria con el aviso del F9, sale cuando ese termina.
    private function Espera takes real retraso returns real
        local real ahora = TimerGetElapsed(reloj)
        local real cuando = ahora + retraso
        if (cuando + AVISO_DURACION > F9_AVISO_INICIO and cuando < F9_AVISO_FIN) then
            set cuando = F9_AVISO_FIN
        endif
        return cuando - ahora
    endfunction

    // Del aviso del observador: sin bots, apenas se apagan los textos de
    // configuracion; con bots, despues del ultimo mensaje de los bots.
    private function RetrasoObservador takes nothing returns real
        if (not udg_Core_HayBots) then
            return OBS_RETRASO
        elseif (udg_Config_Modo_Humanos == 2 and udg_Config_Modo_Orcos == 2) then
            return BOTS_AZAR_FIN + MARGEN
        endif
        return BOTS_FIN + MARGEN
    endfunction

    private function ProgramarAvisos takes nothing returns nothing
        local real obs = Espera(RetrasoObservador())
        if (ModoPartida_EsRapido()) then
            call TimerStart(CreateTimer(), Espera(RAPIDO_RETRASO), false, function MostrarAvisoRapido)
        endif
        call Observadores_ReservarPantalla(obs, AVISO_DURACION)
        call TimerStart(CreateTimer(), obs, false, function MostrarAvisoObservador)
    endfunction

    // Aplica las reglas del modo rapido y programa los avisos de reglas. La
    // llama Core_Menu_Habilidades.j al terminar la ultima pantalla, antes de
    // descongelar el juego, en cualquier modo. En modo normal solo programa el
    // del observador (sale si hay alguno). Solo actua una vez por partida.
    public function Aplicar takes nothing returns nothing
        if (aplicado) then
            return
        endif
        set aplicado = true
        if (ModoPartida_EsRapido()) then
            call ReducirVidaEstructuras()
            call QuitarTabernas()
        endif
        call ProgramarAvisos()
    endfunction

    // ==========================================================
    // INICIALIZACION
    // ==========================================================
    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        set ventana = DialogCreate()
        call TriggerRegisterDialogEvent(t, ventana)
        call TriggerAddAction(t, function OnClick)
        set t = null

        set reloj = CreateTimer()
        call TimerStart(reloj, 100000.0, false, null)

        set sndAviso = CreateSound("Sound\\Interface\\QuestActivateWhat1.wav", false, false, false, 10, 10, "")
        call SetSoundVolume(sndAviso, 127)
    endfunction

endlibrary

//===========================================================================
function InitTrig_Core_Menu_Modo takes nothing returns nothing
    set gg_trg_Core_Menu_Modo = CreateTrigger()
    // Al segundo 1 de partida (antes lo hacia Core_Menu_Oro).
    call TriggerRegisterTimerEvent(gg_trg_Core_Menu_Modo, 1.00, false)
    call TriggerAddAction(gg_trg_Core_Menu_Modo, function CoreMenuModo_Mostrar)
endfunction
