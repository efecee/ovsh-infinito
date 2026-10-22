//===========================================================================
// CORE: OBSERVADORES
//===========================================================================
// La sala tiene tres bloques: Humanos (jugadores 1-5), Orcos (6-10) y
// Observadores (11 y 12, verde oscuro y marron; Player(10) y Player(11)).
// Quien se sienta en el bloque Observadores acepta ser espectador: no recibe
// wisp ni heroe, no tiene aliados en los equipos y el mapa lo trata como
// observador. Es un observador "del mapa": la opcion "Observadores" del
// motor (al crear la partida) sale bloqueada para este mapa, y de todos
// modos no cabria (la sala tiene 12 lugares en total). Los ejercitos de
// creeps ya no ocupan lugares de la sala (Core_Ejercitos.j).
//
// QUE PUEDE HACER UN OBSERVADOR:
//   - Ver todo el mapa revelado (como "iseedeadpeople"), y ademas lo que ve
//     cada equipo (vision compartida de los 10 jugadores y de los dos
//     ejercitos): asi tambien ve las unidades invisibles que algun equipo
//     detecta.
//   - Usar el zoom (-z1, -z2, -z3, -z+, -z-, -z 1800). Empieza en -z3
//     (Zoom.j).
//   - Seguir a un jugador con -foco o -fo (ver FOCO).
//   - Ver las habilidades y el oro del heroe que selecciona (ver
//     SELECCION).
//   Ningun otro comando: los demas se registran solo para 0-9.
//   - Escribir en el chat: "a todos" lo leen todos; "a aliados", solo el otro
//     observador. NO ve el chat de aliados de los equipos (el motor lo manda
//     solo a los aliados de quien escribe).
//   - Ser Master SOLO si ningun humano juega en los slots 1-10 (sala de solo
//     bots). Con al menos un humano jugando, el Master es como siempre.
//   - Al final de la partida ve el mismo resumen que los jugadores, con el
//     titulo "FIN DE LA PARTIDA" (Sistema_Victoria.j).
//   - No cobra la renta de oro (Core_Mecanica_Oro.j paga solo a los slots 0-9).
//
// FOCO: "-foco 3" o "-fo 3" sigue al heroe del jugador 3. El jugador se
// elige igual que en -oro (Comandos_Economia.j): numero 1-10, color o el
// principio del nombre. "-foco" o "-fo" solo, lo quita. Mientras dura:
//   - La camara queda pegada al heroe y el observador no la puede mover
//     (comprobado en partida). Cada 0,1 s se comprueba y, si se aparto (el
//     heroe revivio en la base), se vuelve a pegar: solo -foco la suelta.
//   - El heroe queda siempre seleccionado, asi se ven su vida, mana, nivel
//     y objetos. Si el observador selecciona otra cosa, se le vuelve a
//     seleccionar el heroe (muerto no se puede: espera a que reviva). Esa
//     reseleccion automatica no muestra el bloque de SELECCION.
//   - El zoom (-z) sigue funcionando. Al soltar, la camara vuelve a la
//     normal con el zoom que tenia.
// Camara y seleccion son de cada jugador: se cambian solo en su pantalla
// (GetLocalPlayer), sin riesgo de desincronizar.
//
// SELECCION: cada clic del observador en un heroe le muestra 6 s un bloque
// enmarcado: una linea por habilidad aprendida (en orden Q, W, E, R, T) y,
// tras una linea en blanco, el oro de su dueno en ese momento:
//   ===========================
//   03 = Martillo de tormenta (Q)
//   01 = Bash (E)
//   02 = Entrenamiento (T)
//
//   Oro: 1250
//   ===========================
// Sin nada aprendido sale solo la linea del oro. El nivel va primero y con
// dos cifras, y la letra al final: medido en la fuente de los mensajes
// (Fonts\FRIZQT__.TTF), los diez numeros miden lo mismo, pero las letras no
// (la W es casi el doble de ancha que la T) y correrian lo que va detras.
// Un solo bloque en pantalla: durante 7 s despues de mostrar uno (dura 6 s)
// ningun clic muestra otro, ni del mismo heroe ni de otro. Pasado eso, cada
// clic lo muestra con los datos de ese momento, aunque el heroe ya este
// seleccionado. Las habilidades salen del catalogo de Modo_Aleatorio_DB.j (todas
// las de heroe, por columna), asi que vale tambien en el modo de habilidades
// aleatorias; Entrenamiento (T) va aparte porque no esta en ninguna columna.
// Lo no aprendido no sale: hasta entonces el heroe no la tiene para el
// motor. La 1.27b no deja saber si una habilidad esta en enfriamiento.
//
// AVISO "MODO OBSERVADOR" (MostrarReglas): lo programa Core_Menu_Modo.j, 15 s
// despues de que el Master termina de configurar (con bots, despues de los
// mensajes de los bots), con la misma forma, duracion y sonidos que el aviso
// del Modo Rapido, que los 10 jugadores ven en otro momento. Sale en
// cualquier modo. Desde 7 s antes hasta 1 s despues, los clics en heroes no
// muestran el bloque de SELECCION (ReservarPantalla): el aviso sale solo.
//
// SOLO HUMANOS: una Computadora puesta en el bloque Observadores no cuenta
// para nada (ni vision, ni Master, ni bot, ni resumen): es como un lugar
// vacio. Los bots solo existen en los 10 slots de los equipos.
//
// EXPULSION: el Master lo saca con -kick 11 o -kick 12 (Sistema_Kick.j). Se
// le saca igual que a un jugador (ve "Has sido expulsado." y solo puede
// salir), pero sin voto ni sonido.
//
// AVISO AL SALIR: cuando un observador se va o lo expulsan, todos ven 2 s y
// sin sonido "Observador <nombre> se ha retirado." o "... ha sido
// expulsado.", aparte del aviso de abandono de los jugadores (tabla.j).
//
// INSTALACION EN EL EDITOR: crear un detonador NUEVO llamado
// "Core_Observadores", Editar > Convertir en texto personalizado, y pegar
// este archivo.
//===========================================================================

library Observadores initializer Init requires Ejercitos, ReplayPOVDetection, EconomiaJugador, ModoAleatorio

    globals
        private constant real AVISO_DURACION = 2.0
        // El Master lo expulso: su salida ya se anuncio y deja de contar.
        private boolean array expulsado

        private constant real TICK = 0.10
        private constant real REENGANCHE = 300.0   // camara a mas de esto del heroe: volver a pegarla
        private constant real FOCO_AVISO = 3.0
        private constant real BLOQUE_DURACION = 6.0
        // Un segundo mas que el bloque: nunca hay dos en pantalla.
        private constant real ESPERA = BLOQUE_DURACION + 1.0
        private constant integer ENTRENAMIENTO = 'A023'   // ABIL_FIJA de Modo_Aleatorio_DB.j
        // Dorado = marco, oro y comandos (tambien en el aviso MODO
        // OBSERVADOR); verde = nivel; gris = signos; blanco = nombre; naranja
        // = letra de la tecla, el de las ayudas de habilidades del mapa.
        private constant string COLOR_DORADO = "|cffFFCC00"
        private constant string COLOR_NUMERO = "|cff7FFF7F"
        private constant string COLOR_SIGNO = "|cffAAAAAA"
        private constant string COLOR_LETRA = "|cffFEBA0E"
        // 27 "=": cubre la linea mas ancha ("10 = Invocar Elemental del Agua (W)").
        private constant string MARCO = "|cffFFCC00===========================|r"
        // Foco de cada observador (indice = su id, 10 u 11).
        private unit array focoHeroe
        private integer array focoJugador
        // Solo en la pantalla del observador: hasta cuando una seleccion del
        // heroe seguido es la reseleccion automatica de Vigilar, y cuando se
        // mostro el ultimo bloque.
        private real array autoHasta
        private real array ultimoBloque
        private real reloj = 0.0
        // Tramo en que sale el aviso MODO OBSERVADOR (ReservarPantalla).
        private real reservaDesde = 0.0
        private real reservaHasta = 0.0
        private unit encontrado = null
    endglobals

    // true si p es un observador: un humano sentado en el bloque Observadores
    // (slots 10 y 11 = jugadores 11 y 12) que no fue expulsado. IsPlayerObserver
    // cubre ademas a un observador del motor, si algun dia la sala lo permitiera.
    public function Es takes player p returns boolean
        local integer id = GetPlayerId(p)
        if (IsPlayerObserver(p)) then
            return true
        endif
        return id >= 10 and id <= 11 and GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(p) == MAP_CONTROL_USER and not expulsado[id]
    endfunction

    // true si algun humano conectado ocupa un slot de jugador (0-9).
    public function HayJugadores takes nothing returns boolean
        local integer i = 0
        loop
            exitwhen i > 9
            if (GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(i)) == MAP_CONTROL_USER) then
                return true
            endif
            set i = i + 1
        endloop
        return false
    endfunction

    // Quien puede ser Master (Core_DetectarHost.j y Core_Master_AFK.j). Con al
    // menos un humano jugando: solo los humanos de los slots 0-9, como
    // siempre. Sin ninguno (sala de solo bots): los observadores conectados.
    public function PuedeSerMaster takes player p returns boolean
        if (GetPlayerSlotState(p) != PLAYER_SLOT_STATE_PLAYING) then
            return false
        endif
        if (HayJugadores()) then
            return GetPlayerId(p) <= 9 and GetPlayerController(p) == MAP_CONTROL_USER
        endif
        return Es(p)
    endfunction

    // Todo el mapa revelado para p, mas la vision de los 10 jugadores y de los
    // dos ejercitos (lo que detecta cada equipo).
    private function Revelar takes player p returns nothing
        local integer i = 0
        call FogModifierStart(CreateFogModifierRect(p, FOG_OF_WAR_VISIBLE, bj_mapInitialPlayableArea, false, false))
        loop
            exitwhen i > 9
            call SetPlayerAlliance(Player(i), p, ALLIANCE_SHARED_VISION, true)
            set i = i + 1
        endloop
        call SetPlayerAlliance(Player(EJERCITO_HUMANO), p, ALLIANCE_SHARED_VISION, true)
        call SetPlayerAlliance(Player(EJERCITO_ORCO), p, ALLIANCE_SHARED_VISION, true)
    endfunction

    // Aviso corto y sin sonido para todos, para que sepan si alguien los sigue
    // mirando.
    private function Avisar takes player p, string que returns nothing
        call Replay_DisplayTimedTextToAll(AVISO_DURACION, "|cff999999Observador|r " + GetPlayerName(p) + " |cff999999" + que + "|r")
    endfunction

    // -kick 11 / -kick 12 del Master. false si en ese puesto no hay un
    // observador (vacio, una Computadora o ya expulsado).
    public function Expulsar takes player p returns boolean
        if (not Es(p)) then
            return false
        endif
        set expulsado[GetPlayerId(p)] = true
        call Avisar(p, "ha sido expulsado.")
        // CustomDefeatBJ es la unica forma de sacar a alguien en WC3 (igual
        // que en Sistema_Kick.j); el texto de derrota del motor esta vacio.
        call CustomDefeatBJ(p, "Has sido expulsado.")
        return true
    endfunction

    // Un observador cerro el juego. Si lo expulso el Master, ya se aviso.
    private function OnSalir takes nothing returns nothing
        local player p = GetTriggerPlayer()
        if (not expulsado[GetPlayerId(p)] and GetPlayerController(p) == MAP_CONTROL_USER) then
            call Avisar(p, "se ha retirado.")
        endif
        set p = null
    endfunction

    // Bloque "MODO OBSERVADOR" que ve p (un observador). Lo muestra
    // Core_Menu_Modo.j en el mismo segundo, con la misma forma y los mismos
    // sonidos que el aviso del Modo Rapido (que solo ven los 10 jugadores).
    // Una llamada por linea: en los mensajes "|n" no salta de linea.
    public function MostrarReglas takes player p, real duracion returns nothing
        call DisplayTimedTextToPlayer(p, 0, 0, duracion, "|cffFFCC00MODO OBSERVADOR|r")
        call DisplayTimedTextToPlayer(p, 0, 0, duracion, "- Ves todo el mapa.")
        call DisplayTimedTextToPlayer(p, 0, 0, duracion, "- Al seleccionar un héroe ves sus habilidades y su oro.")
        call DisplayTimedTextToPlayer(p, 0, 0, duracion, "- El Master te puede expulsar.")
        call DisplayTimedTextToPlayer(p, 0, 0, duracion, "- Cambias el zoom con " + COLOR_DORADO + "-z1|r, " + COLOR_DORADO + "-z2|r o " + COLOR_DORADO + "-z3|r.")
        call DisplayTimedTextToPlayer(p, 0, 0, duracion, "- Sigues a un jugador con " + COLOR_DORADO + "-foco|r (o " + COLOR_DORADO + "-fo|r) y su número, color o nombre.")
        call DisplayTimedTextToPlayer(p, 0, 0, duracion, "- Dejas de seguirlo con " + COLOR_DORADO + "-foco|r solo.")
    endfunction

    // Core_Menu_Modo.j avisa que MostrarReglas saldra dentro de "enSegundos"
    // y durara "duracion". Desde ESPERA s antes (un bloque de SELECCION dura
    // 6 s y seguiria en pantalla) hasta 1 s despues de que se apague, los
    // clics en heroes no muestran nada.
    public function ReservarPantalla takes real enSegundos, real duracion returns nothing
        set reservaDesde = reloj + enSegundos - ESPERA
        set reservaHasta = reloj + enSegundos + duracion + 1.0
    endfunction

    // ---------------------------------------------------------------- SELECCION

    // Nombre de la habilidad sin la aclaracion del editor entre parentesis
    // ("Speed Bonus (aura resistencia)") ni espacios al final ("Incinerar ").
    private function NombreHabilidad takes integer abil returns string
        local string s = GetObjectName(abil)
        local integer n = StringLength(s)
        local integer i = 0
        loop
            exitwhen i >= n
            if (SubString(s, i, i + 2) == " (") then
                set n = i
            endif
            set i = i + 1
        endloop
        loop
            exitwhen n == 0 or SubString(s, n - 1, n) != " "
            set n = n - 1
        endloop
        return SubString(s, 0, n)
    endfunction

    // La habilidad aprendida de esa columna, o 0.
    private function AprendidaDe takes unit h, integer slot returns integer
        local integer n = ModoAleatorio_GetPoolCount(slot)
        local integer i = 0
        loop
            exitwhen i >= n
            if (GetUnitAbilityLevel(h, ModoAleatorio_GetAbilId(slot, i)) > 0) then
                return ModoAleatorio_GetAbilId(slot, i)
            endif
            set i = i + 1
        endloop
        return 0
    endfunction

    // "04 = Golpe crítico (E)". Nada si abil es 0 (no aprendida).
    private function Linea takes player p, unit h, integer abil, string tecla returns nothing
        local integer nivel
        local string cifras
        if (abil != 0) then
            set nivel = GetUnitAbilityLevel(h, abil)
            set cifras = I2S(nivel)
            if (nivel < 10) then
                set cifras = "0" + cifras
            endif
            call DisplayTimedTextToPlayer(p, 0, 0, BLOQUE_DURACION, COLOR_NUMERO + cifras + "|r" + COLOR_SIGNO + " = |r" + NombreHabilidad(abil) + COLOR_SIGNO + " (|r" + COLOR_LETRA + tecla + "|r" + COLOR_SIGNO + ")|r")
        endif
    endfunction

    // Bloque de SELECCION: habilidades aprendidas y el oro de su dueno ahora.
    private function MostrarHeroe takes player p, unit h returns nothing
        local integer q = AprendidaDe(h, SLOT_Q)
        local integer w = AprendidaDe(h, SLOT_W)
        local integer e = AprendidaDe(h, SLOT_E)
        local integer r = AprendidaDe(h, SLOT_R)
        local integer t = 0
        local string oro = COLOR_DORADO + "Oro: " + I2S(GetPlayerState(GetOwningPlayer(h), PLAYER_STATE_RESOURCE_GOLD)) + "|r"
        if (GetUnitAbilityLevel(h, ENTRENAMIENTO) > 0) then
            set t = ENTRENAMIENTO
        endif
        // Sin nada aprendido no hay marco vacio: solo el oro.
        if (q == 0 and w == 0 and e == 0 and r == 0 and t == 0) then
            call DisplayTimedTextToPlayer(p, 0, 0, BLOQUE_DURACION, oro)
            return
        endif
        call DisplayTimedTextToPlayer(p, 0, 0, BLOQUE_DURACION, MARCO)
        call Linea(p, h, q, "Q")
        call Linea(p, h, w, "W")
        call Linea(p, h, e, "E")
        call Linea(p, h, r, "R")
        call Linea(p, h, t, "T")
        call DisplayTimedTextToPlayer(p, 0, 0, BLOQUE_DURACION, " ")
        call DisplayTimedTextToPlayer(p, 0, 0, BLOQUE_DURACION, oro)
        call DisplayTimedTextToPlayer(p, 0, 0, BLOQUE_DURACION, MARCO)
    endfunction

    // Todo se decide en la pantalla del observador: es la unica que sabe si
    // la seleccion fue la reseleccion automatica del foco, y la unica que ve
    // el bloque. No crea nada, solo muestra texto.
    private function OnSeleccion takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer id = GetPlayerId(p)
        local unit u = GetTriggerUnit()
        if (GetLocalPlayer() == p and Es(p) and IsUnitType(u, UNIT_TYPE_HERO)) then
            if (u == focoHeroe[id] and reloj < autoHasta[id]) then
                set autoHasta[id] = 0.0
            elseif (reloj - ultimoBloque[id] >= ESPERA and (reloj < reservaDesde or reloj >= reservaHasta)) then
                set ultimoBloque[id] = reloj
                call MostrarHeroe(p, u)
            endif
        endif
        set p = null
        set u = null
    endfunction

    // ---------------------------------------------------------------- FOCO

    // Heroe del jugador p (sin contar ilusiones), vivo o muerto, o null si
    // todavia no eligio.
    private function HeroeDe takes player p returns unit
        local group g = CreateGroup()
        local unit u
        set encontrado = null
        call GroupEnumUnitsOfPlayer(g, p, null)
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            call GroupRemoveUnit(g, u)
            if (encontrado == null and IsUnitType(u, UNIT_TYPE_HERO) and not IsUnitIllusion(u)) then
                set encontrado = u
            endif
        endloop
        call DestroyGroup(g)
        set g = null
        return encontrado
    endfunction

    // Pega la camara del observador al heroe y se lo selecciona, solo en su
    // pantalla.
    private function Pegar takes player p, unit h returns nothing
        if (GetLocalPlayer() == p) then
            call SetCameraTargetController(h, 0.0, 0.0, false)
            if (not IsUnitType(h, UNIT_TYPE_DEAD)) then
                call ClearSelection()
                call SelectUnit(h, true)
            endif
        endif
    endfunction

    // Suelta la camara y le devuelve al observador su zoom (Zoom.j).
    private function QuitarFoco takes player p returns nothing
        local integer id = GetPlayerId(p)
        set focoHeroe[id] = null
        set focoJugador[id] = -1
        if (GetLocalPlayer() == p) then
            call ResetToGameCamera(0.0)
            call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, ZoomActual[id], 0.0)
        endif
    endfunction

    private function Recortar takes string s returns string
        local integer a = 0
        local integer b = StringLength(s)
        loop
            exitwhen a >= b or SubString(s, a, a + 1) != " "
            set a = a + 1
        endloop
        loop
            exitwhen b <= a or SubString(s, b - 1, b) != " "
            set b = b - 1
        endloop
        return SubString(s, a, b)
    endfunction

    // -foco / -fo [jugador]. El evento es por prefijo "-fo": lo demas que
    // empiece asi se ignora.
    private function OnFoco takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer id = GetPlayerId(p)
        local string s = StringCase(GetEventPlayerChatString(), false)
        local string arg
        local player objetivo
        local unit h
        if (not Es(p)) then
            set p = null
            return
        endif
        if (SubString(s, 0, 6) == "-foco ") then
            set arg = Recortar(SubString(s, 6, StringLength(s)))
        elseif (SubString(s, 0, 4) == "-fo ") then
            set arg = Recortar(SubString(s, 4, StringLength(s)))
        elseif (s == "-foco" or s == "-fo") then
            set arg = ""
        else
            set p = null
            return
        endif

        if (arg == "") then
            if (focoHeroe[id] != null) then
                call QuitarFoco(p)
                call DisplayTimedTextToPlayer(p, 0, 0, FOCO_AVISO, "|cffFFCC00Foco:|r quitado.")
            endif
            set p = null
            return
        endif

        set objetivo = Economia_GetPlayer(arg)
        if (objetivo == null) then
            call DisplayTimedTextToPlayer(p, 0, 0, FOCO_AVISO, "Jugador no encontrado: " + arg)
        else
            set h = HeroeDe(objetivo)
            if (h == null) then
                call DisplayTimedTextToPlayer(p, 0, 0, FOCO_AVISO, Eco_CName(objetivo) + " todavía no tiene héroe.")
            else
                // Pegar lo selecciona: el bloque de SELECCION sale solo (si
                // no hay otro en pantalla).
                set focoHeroe[id] = h
                set focoJugador[id] = GetPlayerId(objetivo)
                call DisplayTimedTextToPlayer(p, 0, 0, FOCO_AVISO, "|cffFFCC00Foco:|r siguiendo a " + Eco_CName(objetivo) + ".")
                call Pegar(p, h)
            endif
        endif
        set p = null
        set objetivo = null
        set h = null
    endfunction

    // Cada 0,1 s: mantiene la camara pegada y el heroe seleccionado.
    private function Vigilar takes nothing returns nothing
        local integer i = 10
        local player p
        local unit h
        local real dx
        local real dy
        set reloj = reloj + TICK
        loop
            exitwhen i > 11
            set p = Player(i)
            if (focoHeroe[i] != null) then
                if (not Es(p)) then
                    // Se fue o lo expulsaron.
                    set focoHeroe[i] = null
                elseif (GetUnitTypeId(focoHeroe[i]) == 0) then
                    // El heroe ya no existe: se busca el que tenga ahora.
                    set focoHeroe[i] = HeroeDe(Player(focoJugador[i]))
                    if (focoHeroe[i] == null) then
                        call DisplayTimedTextToPlayer(p, 0, 0, FOCO_AVISO, "|cffFFCC00Foco:|r quitado, " + Eco_CName(Player(focoJugador[i])) + " ya no tiene héroe.")
                        call QuitarFoco(p)
                    else
                        call Pegar(p, focoHeroe[i])
                    endif
                elseif (GetLocalPlayer() == p) then
                    set h = focoHeroe[i]
                    set dx = GetCameraTargetPositionX() - GetUnitX(h)
                    set dy = GetCameraTargetPositionY() - GetUnitY(h)
                    if (dx * dx + dy * dy > REENGANCHE * REENGANCHE) then
                        call SetCameraTargetController(h, 0.0, 0.0, false)
                    endif
                    if (not IsUnitType(h, UNIT_TYPE_DEAD) and not IsUnitSelected(h, p)) then
                        set autoHasta[i] = reloj + 1.0
                        call ClearSelection()
                        call SelectUnit(h, true)
                    endif
                endif
            endif
            set i = i + 1
        endloop
        set p = null
        set h = null
    endfunction

    private function AlEmpezar takes nothing returns nothing
        local integer i = 0
        call DestroyTimer(GetExpiredTimer())
        loop
            exitwhen i > 11
            if (Es(Player(i))) then
                call Revelar(Player(i))
            endif
            set i = i + 1
        endloop
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local trigger tFoco = CreateTrigger()
        local trigger tSeleccion = CreateTrigger()
        // Con un timer de 0 s: corre al empezar la partida, con todo ya creado.
        call TimerStart(CreateTimer(), 0.0, false, function AlEmpezar)
        call TriggerRegisterPlayerEvent(t, Player(10), EVENT_PLAYER_LEAVE)
        call TriggerRegisterPlayerEvent(t, Player(11), EVENT_PLAYER_LEAVE)
        call TriggerAddAction(t, function OnSalir)

        // Un solo registro por prefijo "-fo" (como el "-z" de Zoom.j): el
        // chat no distingue mayusculas y atrapa -fo, -foco, -FO y -FOCO.
        call TriggerRegisterPlayerChatEvent(tFoco, Player(10), "-fo", false)
        call TriggerRegisterPlayerChatEvent(tFoco, Player(11), "-fo", false)
        call TriggerAddAction(tFoco, function OnFoco)
        call TriggerRegisterPlayerUnitEvent(tSeleccion, Player(10), EVENT_PLAYER_UNIT_SELECTED, null)
        call TriggerRegisterPlayerUnitEvent(tSeleccion, Player(11), EVENT_PLAYER_UNIT_SELECTED, null)
        call TriggerAddAction(tSeleccion, function OnSeleccion)
        set ultimoBloque[10] = -ESPERA
        set ultimoBloque[11] = -ESPERA
        call TimerStart(CreateTimer(), TICK, true, function Vigilar)

        set t = null
        set tFoco = null
        set tSeleccion = null
    endfunction

endlibrary
