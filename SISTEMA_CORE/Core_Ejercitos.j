//===========================================================================
// CORE: EJERCITOS (duenos de los creeps y de las estructuras de cada faccion)
//===========================================================================
// Los creeps de carril y TODAS las estructuras (castillo, fortaleza, torres
// F1-F3, barracas) son de dos jugadores ocultos que nunca aparecen en la sala:
//   Ejercito Humano = Player(13) (el neutral "Victima")
//   Ejercito Orco   = Player(14) (el neutral "Extra")
// Antes eran Player(10) y Player(11), dos slots de Computadora de la sala.
// Sacarlos de ahi libera esos dos lugares para OBSERVADORES
// (Core_Observadores.j): en la 1.27b la sala tiene 12 lugares en total,
// contando a los observadores, y los observadores ocupan los numeros de
// jugador libres. No queda otro dueno posible que un jugador neutral.
//
// Lo que antes le daba el editor a los jugadores 11 y 12 (Escenario >
// Fuerzas) se hace aqui al cargar el mapa, ANTES de que init.j cree las
// estructuras (las libraries arrancan antes que los detonadores):
//   - Aliado + vision compartida con su equipo, en los dos sentidos.
//   - Enemigo del otro equipo y del otro ejercito.
//   - Pasivo con el Neutral Pasivo (tiendas, fuentes, tabernas).
//   - Da recompensa de oro, y conserva su nombre y su color de siempre
//     (verde oscuro el humano, cafe el orco).
//
// LOS NEUTRALES SON "CREEPS" PARA EL MOTOR (comprobado en partida el
// 2026-10-20): los jugadores 13 a 16 tienen controlador "creep", y cambiarlo
// con SetPlayerController no cambia su conducta. Sus unidades:
//   1. Se alejan un trecho de donde nacieron y el motor les ordena volver
//      ("move"), aun con RemoveGuardPosition y SetUnitCreepGuard apagado.
//   2. No atacan estructuras por si solas, ni la torre que les dispara.
//   3. Dan la experiencia reducida de los creeps neutrales (constante
//      "Exp heroe ganada - Tabla de reduccion de creeps": con 80,70,60,50,0
//      un heroe de nivel 5+ gana 0). Se arregla en el editor poniendo esa
//      tabla en 100: el mapa no tiene creeps hostiles de verdad.
// Este archivo hace que los creeps marchen como antes:
//   - La orden de volver se cancela en el acto (evento de orden + timer de
//     0 s: dentro del propio evento el motor pisaria la orden nueva).
//   - Sin unidades enemigas a su alcance de adquisicion, el creep ataca la
//     estructura enemiga vulnerable mas cercana a ese alcance, o la que le
//     disparo (las torres pegan a 700-800 y los creeps adquieren a 500-600).
//     Si aparecen unidades enemigas, vuelve a avanzar atacando (pelea con
//     ellas, como antes). Las estructuras invulnerables (fases bloqueadas
//     del anti-backdoor) no cuentan, igual que con el ataque-mover.
//   - No deja una fase a medias. En su carril, la fase que le toca romper es
//     la F3, despues la F2, despues la F1 (cuando se abre) y el castillo.
//     Lejos de esa fase marcha como siempre. Si llega a su altura (o la pasa)
//     sin ver ninguna estructura de ella, va a por la mas cercana aunque este
//     fuera de su vista, arriba o abajo del carril. Sin esto seguia de largo
//     hasta una fase invulnerable y moria ahi.
//     Unica excepcion: la F1 cerrada porque la F2 del OTRO carril sigue en
//     pie. Los creeps no cambian de carril, asi que avanzan hasta la F1 como
//     siempre.
//   - Cada 0,5 s se revisa a todos (red de seguridad): el quieto, o con una
//     orden de moverse/parar, recibe otra vez su orden de avanzar.
//
// INSTALACION EN EL EDITOR: crear un detonador NUEVO llamado "Core_Ejercitos",
// Editar > Convertir en texto personalizado, y pegar este archivo.
//===========================================================================

library Ejercitos initializer Init

    globals
        constant integer EJERCITO_HUMANO = 13   // bj_PLAYER_NEUTRAL_VICTIM
        constant integer EJERCITO_ORCO   = 14   // bj_PLAYER_NEUTRAL_EXTRA

        private constant real VIGILANCIA = 0.50
        // Claves de la tabla por creep (indice = handle del creep).
        private constant integer K_X = 0          // destino x
        private constant integer K_Y = 1          // destino y
        private constant integer K_OBJETIVO = 2   // estructura que se le mando atacar
        private constant integer K_AGRESOR = 3    // estructura que le disparo
        private constant integer K_META = 4       // estructura de la fase pendiente a la que va
        private constant integer K_ARRIBA = 5     // true = carril de arriba (Top)

        private group marchando = null   // creeps con orden de avanzar
        private hashtable creeps = null
        private group tmp = null
        // Creeps a revisar en el proximo instante: los que el motor mando de
        // vuelta (hay que reordenarlos si o si) y los que recibieron un
        // disparo de una estructura (solo si no estan peleando con unidades).
        private group pendVuelta = null
        private group pendDisparo = null
        private timer tPendientes = null
        private boolean hayUnidadesCerca = false
        private unit estructuraCerca = null
        // Busqueda de la estructura pendiente mas cercana (ForGroup).
        private real origenX = 0.0
        private real origenY = 0.0
        private real cercanaD = 0.0
        private unit cercana = null

        private integer ordenAtacar = 0
        private integer ordenMover = 0
        private integer ordenSmart = 0
        private integer ordenParar = 0
        private integer ordenQuieto = 0
    endglobals

    // Lo que el ataque-mover de un jugador normal atacaria: vivo, enemigo y
    // no invulnerable (SetUnitInvulnerable agrega 'Avul').
    private function Atacable takes unit t, player p returns boolean
        return t != null and GetUnitTypeId(t) != 0 and not IsUnitType(t, UNIT_TYPE_DEAD) and IsUnitEnemy(t, p) and GetUnitAbilityLevel(t, 'Avul') == 0
    endfunction

    // Mira alrededor de u, a su alcance de adquisicion: deja en
    // hayUnidadesCerca si hay unidades enemigas (no estructuras) y en
    // estructuraCerca la estructura enemiga atacable mas cercana.
    private function Explorar takes unit u returns nothing
        local player p = GetOwningPlayer(u)
        local real x = GetUnitX(u)
        local real y = GetUnitY(u)
        local real mejor = 1000000000.0
        local real d
        local unit t
        set hayUnidadesCerca = false
        set estructuraCerca = null
        call GroupEnumUnitsInRange(tmp, x, y, GetUnitAcquireRange(u), null)
        loop
            set t = FirstOfGroup(tmp)
            exitwhen t == null
            call GroupRemoveUnit(tmp, t)
            if (Atacable(t, p)) then
                if (IsUnitType(t, UNIT_TYPE_STRUCTURE)) then
                    set d = (GetUnitX(t) - x) * (GetUnitX(t) - x) + (GetUnitY(t) - y) * (GetUnitY(t) - y)
                    if (d < mejor) then
                        set mejor = d
                        set estructuraCerca = t
                    endif
                else
                    set hayUnidadesCerca = true
                endif
            endif
        endloop
        set p = null
        set t = null
    endfunction

    // Grupo del anti-backdoor que el creep tiene que terminar antes de seguir:
    // el primero con estructuras en pie de F3 -> F2 de su carril -> F1 -> F0.
    // null = la F1 sigue cerrada por la F2 del otro carril: marcha normal.
    private function Primera takes group f3, group f2, group f1, boolean f1Abierta, group f0 returns group
        if (CountUnitsInGroup(f3) > 0) then
            return f3
        elseif (CountUnitsInGroup(f2) > 0) then
            return f2
        elseif (CountUnitsInGroup(f1) > 0) then
            if (f1Abierta) then
                return f1
            endif
            return null
        elseif (CountUnitsInGroup(f0) > 0) then
            return f0
        endif
        return null
    endfunction

    // El ejercito humano rompe la base orca y el orco la humana.
    private function FasePendiente takes boolean humano, boolean arriba returns group
        if (humano) then
            if (arriba) then
                return Primera(AB_ORC_F3_TOP, AB_ORC_F2_TOP, AB_ORC_F1, AB_ORC_F1_Open, AB_ORC_F0)
            endif
            return Primera(AB_ORC_F3_BOT, AB_ORC_F2_BOT, AB_ORC_F1, AB_ORC_F1_Open, AB_ORC_F0)
        endif
        if (arriba) then
            return Primera(AB_HUM_F3_TOP, AB_HUM_F2_TOP, AB_HUM_F1, AB_HUM_F1_Open, AB_HUM_F0)
        endif
        return Primera(AB_HUM_F3_BOT, AB_HUM_F2_BOT, AB_HUM_F1, AB_HUM_F1_Open, AB_HUM_F0)
    endfunction

    private function CercanaEnum takes nothing returns nothing
        local unit t = GetEnumUnit()
        local real dx = GetUnitX(t) - origenX
        local real dy = GetUnitY(t) - origenY
        if (dx * dx + dy * dy < cercanaD and not IsUnitType(t, UNIT_TYPE_DEAD)) then
            set cercanaD = dx * dx + dy * dy
            set cercana = t
        endif
        set t = null
    endfunction

    // Estructura de la fase pendiente a la que tiene que ir el creep, o null
    // para la marcha normal al castillo enemigo.
    private function BuscarMeta takes unit u, integer id returns unit
        local boolean humano = GetPlayerId(GetOwningPlayer(u)) == EJERCITO_HUMANO
        local group g = FasePendiente(humano, LoadBoolean(creeps, id, K_ARRIBA))
        local unit actual = LoadUnitHandle(creeps, id, K_META)
        local real adelante
        set cercana = null
        if (g != null) then
            if (actual != null and IsUnitInGroup(actual, g)) then
                // Ya iba a por una de la fase: sigue con ella hasta romperla.
                set cercana = actual
            else
                set origenX = GetUnitX(u)
                set origenY = GetUnitY(u)
                set cercanaD = 1000000000.0
                call ForGroup(g, function CercanaEnum)
                // En marcha normal solo se desvia al llegar a la altura de la
                // fase: antes se la encuentra de frente, como siempre.
                if (actual == null and cercana != null) then
                    set adelante = GetUnitX(cercana) - origenX
                    if (not humano) then
                        set adelante = -adelante
                    endif
                    if (adelante > GetUnitAcquireRange(u)) then
                        set cercana = null
                    endif
                endif
            endif
        endif
        set g = null
        set actual = null
        return cercana
    endfunction

    // Avanza atacando hacia su meta (la estructura pendiente) o, sin meta,
    // hacia el castillo enemigo.
    private function Avanzar takes unit u, integer id returns nothing
        local unit meta = LoadUnitHandle(creeps, id, K_META)
        call SetUnitCreepGuard(u, false)
        call RemoveGuardPosition(u)
        if (meta != null and GetUnitTypeId(meta) != 0 and not IsUnitType(meta, UNIT_TYPE_DEAD)) then
            call IssuePointOrder(u, "attack", GetUnitX(meta), GetUnitY(meta))
        else
            call IssuePointOrder(u, "attack", LoadReal(creeps, id, K_X), LoadReal(creeps, id, K_Y))
        endif
        set meta = null
    endfunction

    private function EsOrdenDeVolver takes integer orden returns boolean
        return orden == 0 or orden == ordenMover or orden == ordenSmart or orden == ordenParar or orden == ordenQuieto
    endfunction

    // Decide que hace el creep ahora. forzar = el motor le acaba de ordenar
    // volver: hay que darle una orden si o si.
    private function Revisar takes unit u, boolean forzar returns nothing
        local integer id = GetHandleId(u)
        local player p = GetOwningPlayer(u)
        local unit objetivo
        local unit agresor
        local unit meta
        local integer orden

        if (GetUnitTypeId(u) == 0 or IsUnitType(u, UNIT_TYPE_DEAD)) then
            call GroupRemoveUnit(marchando, u)
            call FlushChildHashtable(creeps, id)
            set p = null
            return
        endif

        call Explorar(u)
        set orden = GetUnitCurrentOrder(u)
        set objetivo = LoadUnitHandle(creeps, id, K_OBJETIVO)

        // 1. Atacando una estructura que se le mando: sigue mientras no haya
        //    unidades enemigas cerca y la estructura siga atacable.
        if (objetivo != null) then
            if (not forzar and orden == ordenAtacar and not hayUnidadesCerca and Atacable(objetivo, p)) then
                set p = null
                set objetivo = null
                return
            endif
            call RemoveSavedHandle(creeps, id, K_OBJETIVO)
            set forzar = true
        endif

        // 2. Sin unidades enemigas cerca: atacar la estructura que le disparo
        //    o, si no, la mas cercana a su alcance.
        if (not hayUnidadesCerca) then
            set agresor = LoadUnitHandle(creeps, id, K_AGRESOR)
            call RemoveSavedHandle(creeps, id, K_AGRESOR)
            if (not Atacable(agresor, p)) then
                set agresor = estructuraCerca
            endif
            if (agresor != null) then
                call SaveUnitHandle(creeps, id, K_OBJETIVO, agresor)
                call IssueTargetOrder(u, "attack", agresor)
                set p = null
                set objetivo = null
                set agresor = null
                return
            endif
        endif

        // 3. Sin pelea: si llego a la fase pendiente de su carril sin verla (o
        //    la dejo atras), ir a por ella. La orden se da solo cuando cambia
        //    la meta, para no repetirla cada 0,5 s.
        if (not hayUnidadesCerca) then
            set meta = BuscarMeta(u, id)
            if (meta != LoadUnitHandle(creeps, id, K_META)) then
                if (meta == null) then
                    call RemoveSavedHandle(creeps, id, K_META)
                else
                    call SaveUnitHandle(creeps, id, K_META, meta)
                endif
                set forzar = true
            endif
        endif

        // 4. Volver a avanzar si el motor lo mando de vuelta, quedo quieto o
        //    cambio de meta.
        if (forzar or EsOrdenDeVolver(orden)) then
            call Avanzar(u, id)
        endif

        set p = null
        set objetivo = null
        set agresor = null
        set meta = null
    endfunction

    private function RevisarEnum takes nothing returns nothing
        call Revisar(GetEnumUnit(), false)
    endfunction

    private function RevisarVueltaEnum takes nothing returns nothing
        call Revisar(GetEnumUnit(), true)
    endfunction

    private function AtenderPendientes takes nothing returns nothing
        call ForGroup(pendVuelta, function RevisarVueltaEnum)
        call GroupClear(pendVuelta)
        call ForGroup(pendDisparo, function RevisarEnum)
        call GroupClear(pendDisparo)
    endfunction

    // El motor le ordeno a un creep volver: se cancela en el proximo instante.
    private function OnOrdenPunto takes nothing returns nothing
        local unit u = GetTriggerUnit()
        local integer orden = GetIssuedOrderId()
        if ((orden == ordenMover or orden == ordenSmart) and IsUnitInGroup(u, marchando)) then
            call GroupAddUnit(pendVuelta, u)
            call TimerStart(tPendientes, 0.0, false, function AtenderPendientes)
        endif
        set u = null
    endfunction

    // Una estructura enemiga le disparo a un creep: lo anota para que la
    // ataque si no esta peleando con unidades (los creeps neutrales no
    // responden solos a los edificios).
    private function OnAtacado takes nothing returns nothing
        local unit u = GetTriggerUnit()
        local unit a = GetAttacker()
        local integer id = GetHandleId(u)
        if (IsUnitType(a, UNIT_TYPE_STRUCTURE) and IsUnitInGroup(u, marchando) and not HaveSavedHandle(creeps, id, K_OBJETIVO)) then
            call SaveUnitHandle(creeps, id, K_AGRESOR, a)
            call GroupAddUnit(pendDisparo, u)
            call TimerStart(tPendientes, 0.0, false, function AtenderPendientes)
        endif
        set u = null
        set a = null
    endfunction

    private function VigilarTodos takes nothing returns nothing
        call ForGroup(marchando, function RevisarEnum)
    endfunction

    // Orden de avanzar de un creep recien nacido (la dan los detonadores
    // Attack_1_* de init.j al aparecer en su cripera).
    public function Marchar takes unit u, real x, real y returns nothing
        local integer id = GetHandleId(u)
        call SaveReal(creeps, id, K_X, x)
        call SaveReal(creeps, id, K_Y, y)
        // Carril: el de la cripera donde nacio (las de arriba estan en y > 0).
        call SaveBoolean(creeps, id, K_ARRIBA, GetUnitY(u) > 0.0)
        call GroupAddUnit(marchando, u)
        call Avanzar(u, id)
    endfunction

    // equipoDesde..equipoHasta = slots (0-9) del equipo del ejercito.
    private function Configurar takes player ejercito, player rival, integer equipoDesde, integer equipoHasta returns nothing
        local integer i = 0
        local player p
        loop
            exitwhen i > 9
            set p = Player(i)
            if (i >= equipoDesde and i <= equipoHasta) then
                call SetPlayerAllianceStateBJ(ejercito, p, bj_ALLIANCE_ALLIED_VISION)
                call SetPlayerAllianceStateBJ(p, ejercito, bj_ALLIANCE_ALLIED_VISION)
            else
                call SetPlayerAllianceStateBJ(ejercito, p, bj_ALLIANCE_UNALLIED)
                call SetPlayerAllianceStateBJ(p, ejercito, bj_ALLIANCE_UNALLIED)
            endif
            set i = i + 1
        endloop
        call SetPlayerAllianceStateBJ(ejercito, rival, bj_ALLIANCE_UNALLIED)
        call SetPlayerAllianceStateBJ(ejercito, Player(PLAYER_NEUTRAL_PASSIVE), bj_ALLIANCE_NEUTRAL)
        call SetPlayerAllianceStateBJ(Player(PLAYER_NEUTRAL_PASSIVE), ejercito, bj_ALLIANCE_NEUTRAL)
        call SetPlayerState(ejercito, PLAYER_STATE_GIVES_BOUNTY, 1)
        call SetPlayerState(ejercito, PLAYER_STATE_NO_CREEP_SLEEP, 1)
        set p = null
    endfunction

    private function Init takes nothing returns nothing
        local player hum = Player(EJERCITO_HUMANO)
        local player orc = Player(EJERCITO_ORCO)
        local trigger tOrden = CreateTrigger()
        local trigger tAtacado = CreateTrigger()

        call SetPlayerName(hum, "Ejercito Humano")
        call SetPlayerName(orc, "Ejercito Orco")
        call SetPlayerColor(hum, ConvertPlayerColor(10))
        call SetPlayerColor(orc, ConvertPlayerColor(11))
        call Configurar(hum, orc, 0, 4)
        call Configurar(orc, hum, 5, 9)

        set marchando = CreateGroup()
        set creeps = InitHashtable()
        set tmp = CreateGroup()
        set pendVuelta = CreateGroup()
        set pendDisparo = CreateGroup()
        set tPendientes = CreateTimer()
        set ordenAtacar = OrderId("attack")
        set ordenMover = OrderId("move")
        set ordenSmart = OrderId("smart")
        set ordenParar = OrderId("stop")
        set ordenQuieto = OrderId("holdposition")

        call TriggerRegisterPlayerUnitEvent(tOrden, hum, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, null)
        call TriggerRegisterPlayerUnitEvent(tOrden, orc, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, null)
        call TriggerAddAction(tOrden, function OnOrdenPunto)
        call TriggerRegisterPlayerUnitEvent(tAtacado, hum, EVENT_PLAYER_UNIT_ATTACKED, null)
        call TriggerRegisterPlayerUnitEvent(tAtacado, orc, EVENT_PLAYER_UNIT_ATTACKED, null)
        call TriggerAddAction(tAtacado, function OnAtacado)
        call TimerStart(CreateTimer(), VIGILANCIA, true, function VigilarTodos)

        set hum = null
        set orc = null
        set tOrden = null
        set tAtacado = null
    endfunction

endlibrary
