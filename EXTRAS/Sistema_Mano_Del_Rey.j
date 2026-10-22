//===========================================================================
// INDICADOR VISUAL: MANO DEL REY ('I01Q')
//---------------------------------------------------------------------------
// Marca con un efecto sobre la cabeza al heroe QUE TENGA el item en su
// inventario, y SOLO mientras lo tenga. El item es UNICO en la partida, asi
// que en todo momento existe como maximo UN portador marcado.
//
// El objetivo es de diseño, no cosmetico: el que compra la Mano del Rey gana
// velocidad de ataque pero se vuelve un objetivo marcado. Sin el indicador,
// esa mitad de la mecanica solo existe si alguien revisa inventarios a mano.
//
// === REGLA UNICA ===
//   El item esta en el inventario de un heroe  ->  ese heroe muestra el efecto.
//   Cualquier otro caso                        ->  no lo muestra nadie.
//
//   De esa regla salen solos todos los casos, sin codigo especial para cada uno:
//     - Compra en tienda / recoge del suelo / se lo pasa un aliado -> aparece.
//     - Muere (el item cae al suelo), lo suelta, lo transfiere,
//       lo destruyen en el suelo                                  -> desaparece.
//     - Item tirado en el suelo                                   -> nadie lo muestra.
//
//===========================================================================
// LAS DOS SUPERFICIES DE FALLA (leer antes de tocar nada)
//---------------------------------------------------------------------------
// Este sistema puede perder el indicador por dos motivos INDEPENDIENTES, y
// cada uno tiene su propia defensa. No los mezcles.
//
// --- 1. IDENTIDAD: "¿quien lo lleva?" -------------------------------------
//   El motor puede ESCONDER temporalmente el inventario de una unidad sin que
//   el item cambie de dueño. Caso real: Hex / Polimorfia. El heroe se vuelve
//   un critter, el critter tiene 0 slots de inventario, y toda consulta de
//   inventario responde "no lo tiene" durante esos segundos.
//
//   Por eso la identidad NO se decide por ausencia de evidencia. Se decide asi:
//     - El item aparece en el inventario de alguien -> ese es el portador.
//     - El portador sigue vivo pero MORFEADO        -> sigue siendo el portador.
//     - El item aparece en el suelo                 -> no hay portador.
//     - No aparece en NINGUN lado                   -> se CONSERVA el portador si
//       sigue vivo; sin portador vivo, candidato a destruido (ver "dormir").
//
//   El morfeo se detecta comparando el unit-type actual contra el que tenia AL
//   AGARRAR el item (CarrierBaseType). Eso es prueba A FAVOR de que el motor le
//   escondio el inventario, no una deduccion por descarte, y ahorra barrer el
//   mapa entero durante todos los segundos que dure el Hex.
//
//   La ultima rama (vivo, sin morfear, y el item en ningun lado) no deberia
//   ocurrir nunca: nada en el mapa le saca el item del inventario a un heroe vivo
//   (verificado: 'I01Q' no participa de ninguna receta de COMBINACION_OBJETOS, y
//   la unica salida es soltarlo o morir, ambas por evento). Si alguna vez se lo
//   mete en una fusion, ESTA es la suposicion a revisar. Ante la duda se conserva
//   el indicador: perderlo es exactamente el bug que este sistema viene a matar.
//
//   Ademas el item se identifica por TIPO ('I01Q'), nunca por handle guardado.
//   Un handle aprendido por evento se puede invalidar (o el motor lo recicla) y
//   entonces el sistema queda ciego para siempre, porque no hay ningun evento
//   que lo vuelva a enseñar. El tipo no caduca nunca: el item es unico.
//
// --- 2. RENDER: "¿mi efecto sigue visible?" -------------------------------
//   El motor destruye el modelo adjunto cuando reconstruye la instancia de
//   modelo de la unidad, y NO avisa. Casos confirmados en este mapa: Empalar
//   ('AUim', Señor de la Cripta) y cualquier morfeo. En 1.27b no existe ninguna
//   API para preguntar si un effect sigue renderizado: el handle sigue siendo
//   valido aunque en pantalla ya no haya nada.
//
//   Por lo tanto NO se intenta detectar la causa. Enumerar habilidades no puede
//   ser definitivo: siempre queda la que no probaste. En su lugar el efecto se
//   trata como DESECHABLE y se reconstruye cada MDR_BEAT ticks, pase lo que
//   pase. Se crea el nuevo ANTES de destruir el viejo, asi nunca hay un frame
//   vacio y el solapamiento disimula el pulso.
//
//   MDR_BEAT es LA perilla a calibrar en partida:
//     mas corto  -> vuelve antes despues de un Empalar, pulso mas frecuente.
//     mas largo  -> pulso mas raro, hueco mas largo tras perderlo.
//
//   OJO: el latido NO afecta el cambio de portador. Soltar y entregar el item
//   sigue siendo instantaneo (eventos PICKUP/DROP). El latido solo re-pega el
//   MISMO efecto sobre el MISMO portador.
//===========================================================================
// EL SISTEMA DUERME SALVO QUE EL ITEM EXISTA
//---------------------------------------------------------------------------
//   La Mano del Rey tiene ~11 minutos de retraso inicial en la tienda y puede no
//   comprarse NUNCA en toda la partida. Sin puerta de entrada, el sondeo barreria
//   inventarios cada latido durante 40 minutos para no encontrar nada jamas.
//
//   Por eso el timer arranca PAUSADO. Solo corre mientras el item existe:
//     - DESPIERTA con la venta de la tienda o con el PICKUP del item.
//     - DUERME cuando confirma que el item ya no existe (destruido).
//
//   Dormir es seguro porque el item es UNICO: la tienda vende uno y no repone en
//   el tiempo de una partida, asi que "destruido" es definitivo. Igual el apagado
//   NO es irreversible: los triggers de evento quedan registrados para siempre, y
//   si el item volviera a aparecer por cualquier via, lo vuelven a despertar.
//
//   La confirmacion pide MDR_MISSING latidos seguidos sin rastro. No es paranoia:
//   entre la muerte del portador y el instante en que el item toca el suelo hay
//   una ventana en la que no esta en ningun lado, y sin confirmar se apagaria el
//   sistema justo ahi.
//===========================================================================
//
// === TRANSFORMACION ===
//   Un heroe morfeado conserva el MISMO handle y el MISMO inventario, asi que
//   sigue siendo el portador por definicion. El cambio de GetUnitTypeId se
//   sigue vigilando, pero ya no como unica defensa: solo sirve para reenganchar
//   en el acto en vez de esperar al latido. Bajo Hex el indicador queda sobre
//   el animalito, que es lo correcto: el portador no cambio.
//
// === COPIAS / ILUSIONES ===
//   Las ilusiones del portador nacen con la velocidad de ataque del item ya
//   aplicada, asi que tienen que mentir igual que el original: llevan el mismo
//   indicador. Una ilusion NO tiene inventario, por eso no la cubre la regla
//   unica y necesita su propio rastreo. Sus efectos se reconstruyen en el mismo
//   latido que el del portador.
//   Identificacion (ver MDR_IsCopyOfCarrier): ilusion viva + mismo dueño que el
//   portador + mismo unit-type. En este mapa cada jugador controla UN heroe, asi
//   que esa terna solo puede ser una copia del portador. Si alguna vez deja de
//   valer "un heroe por jugador", esta es la suposicion a revisar.
//
// === POR QUE HAY UN SONDEO Y NO SOLO EVENTOS ===
//   Los eventos PICKUP/DROP cubren el caso normal con latencia cero, pero NO
//   cubren todas las salidas del inventario: la MUERTE del portador (el motor
//   suelta el inventario sin garantia de DROP_ITEM), la destruccion del item en
//   el suelo, o cualquier remocion por codigo. Por eso la FUENTE DE VERDAD es
//   el tick: verifica quien lo tiene DE VERDAD, y los eventos solo sirven para
//   reaccionar al instante.
//   El barrido completo (FindCarrier) corre solo en el latido lento y solo
//   cuando el portador conocido no responde, nunca en el tick rapido.
//
// === SLOTS DE JUGADOR (0-9) ===
//   La partida es 5 humanos vs 5 orcos: los jugadores REALES son el 0 al 9 (ver
//   EXTRAS/tabla.j, que valida exactamente ese rango). Solo un heroe de esos
//   slots puede llevar el item, asi que los eventos y los barridos se registran
//   hasta MDR_LAST_PLAYER y no tocan los slots neutrales, que son justamente los
//   que concentran la masa de unidades del mapa (creeps y estructuras).
//   Excepcion: la venta se registra para TODOS los slots, porque la tienda es
//   una unidad neutral y el evento se dispara del lado del vendedor.
//
// === ANUNCIO DE COMPRA ===
//   Cuando alguien COMPRA el item se avisa a TODOS (jugadores y observadores) durante
//   MDR_ANNOUNCE_TIME segundos, una sola vez por partida y SIN decir quien lo
//   tiene: la noticia es que el item entro en juego, no una delacion.
//   Cuelga del evento de venta, que es el unico que significa "compra" (el PICKUP
//   no distingue comprar de levantarlo del suelo), y ademas lleva un booleano de
//   una sola via. Cambiar de manos y recogerlo del suelo NO anuncian nada.
//   El texto es MDR_ANNOUNCE_MSG, literal: si renombras el item, editalo ahi.
//
// === LIMITE DEL MOTOR EN 1.27b ===
//   No existe BlzSetSpecialEffectScale (llego en 1.29/Reforged): el tamaño del
//   indicador es el que trae el modelo y NO se puede corregir por codigo. Si
//   alguna vez hay que cambiarle la escala, se hornea en un modelo propio.
//
// === QUE CREAR EN EL OBJECT EDITOR ===
//   Nada. Este sistema no necesita unidades, habilidades ni items nuevos: solo
//   lee el item 'I01Q' que ya existe.
//
// === DEPENDENCIAS / ORDEN DE COMPILACION ===
//   Ninguna. Library autocontenida, puede ir en cualquier posicion de la lista
//   de triggers del editor.
//===========================================================================

library ItemManoDelRey initializer OnInit

    globals
        // === CONFIG ===
        private constant integer MDR_ITEM_ID    = 'I01Q'     // rawcode de la Mano del Rey
        private constant string  MDR_MODEL      = "Abilities\\Spells\\Orc\\Bloodlust\\BloodlustTarget.mdl"
        private constant string  MDR_ATTACH     = "overhead" // punto de enganche del modelo
        private constant real    MDR_TICK       = 0.50       // tick rapido: muerte + copias
        private constant integer MDR_BEAT       = 4          // ticks por latido (4 * 0.50 = 2.00s)
        private constant integer MDR_MAX_COPIES = 8          // tope de ilusiones marcadas a la vez
        private constant integer MDR_LAST_PLAYER = 9         // ultimo slot real (5 humanos + 5 orcos)
        private constant integer MDR_LAST_VIEWER = 11        // ultimo slot que ve el anuncio (10-11 = observadores)
        private constant integer MDR_MISSING     = 2         // latidos sin rastro para darlo por destruido
        private constant real    MDR_ANNOUNCE_TIME = 5.0     // duracion del anuncio de compra
        // Mensaje literal: si le cambias el nombre al item en el Object Editor, hay
        // que editarlo aca tambien. Se escribe entero a mano y no con GetItemName
        // porque el nombre del item no trae articulo ("Mano del Rey"), y pegarle uno
        // por codigo solo funciona hasta que el nombre nuevo no sea femenino.
        private constant string  MDR_ANNOUNCE_MSG  = "|cffFFCC00La Mano del Rey|r ha sido reclamada."

        // === ESTADO ===
        private unit    Carrier     = null   // quien lo tiene ahora (null = nadie)
        private effect  FX          = null   // indicador vivo sobre Carrier
        private integer CarrierType = 0      // unit-type ACTUAL del portador (detecta transformacion)
        private integer CarrierBase = 0      // unit-type que tenia AL AGARRAR el item (detecta morfeo)
        private timer   TickTimer   = null
        private integer BeatCount   = 0      // ticks acumulados hacia el proximo latido

        private boolean InPlay      = false  // false = el item no existe: sistema dormido, timer pausado
        private integer MissingBeats = 0     // latidos seguidos sin encontrar el item en ningun lado
        private boolean Announced   = false  // el anuncio de compra ya salio (una vez por partida)

        private rect    WorldRect   = null   // limites del mapa, creados una vez (barrido de suelo)
        private boolean GroundHit   = false  // resultado del barrido de suelo

        // Copias (ilusiones) del portador que ya tienen su indicador.
        private unit array   CopyUnit
        private effect array CopyFX
        private integer      CopyCount = 0
    endglobals

    //=======================================================================
    // INDICADOR DEL PORTADOR
    //=======================================================================
    private function ClearFX takes nothing returns nothing
        if (FX != null) then
            call DestroyEffect(FX)
            set FX = null
        endif
    endfunction

    // Reconstruye el indicador SIN preguntar si hacia falta: es la unica defensa
    // posible contra un motor que borra el modelo adjunto sin avisar.
    // Crea el nuevo ANTES de destruir el viejo para no dejar un frame en blanco.
    private function RefreshFX takes nothing returns nothing
        local effect old = FX
        if (Carrier == null) then
            set old = null
            call ClearFX()
            return
        endif
        set FX = AddSpecialEffectTarget(MDR_MODEL, Carrier, MDR_ATTACH)
        if (old != null) then
            call DestroyEffect(old)
        endif
        set old = null
    endfunction

    //=======================================================================
    // INDICADORES DE LAS COPIAS
    //=======================================================================
    private function ClearCopies takes nothing returns nothing
        local integer i = 0
        loop
            exitwhen i >= CopyCount
            if (CopyFX[i] != null) then
                call DestroyEffect(CopyFX[i])
                set CopyFX[i] = null
            endif
            set CopyUnit[i] = null
            set i = i + 1
        endloop
        set CopyCount = 0
    endfunction

    // Mismo criterio que RefreshFX, aplicado a cada ilusion marcada: al motor le
    // da igual que sea una copia, tambien le borra el modelo adjunto.
    private function RefreshCopiesFX takes nothing returns nothing
        local integer i = 0
        local effect  old
        loop
            exitwhen i >= CopyCount
            if (CopyUnit[i] != null) then
                set old        = CopyFX[i]
                set CopyFX[i]  = AddSpecialEffectTarget(MDR_MODEL, CopyUnit[i], MDR_ATTACH)
                if (old != null) then
                    call DestroyEffect(old)
                endif
            endif
            set i = i + 1
        endloop
        set old = null
    endfunction

    private function IsCopyTracked takes unit u returns boolean
        local integer i = 0
        loop
            exitwhen i >= CopyCount
            if (CopyUnit[i] == u) then
                return true
            endif
            set i = i + 1
        endloop
        return false
    endfunction

    // Una ilusion viva, del mismo dueño y del mismo unit-type que el portador.
    // Con un heroe por jugador, esa terna solo puede ser una copia del portador.
    private function IsCopyOfCarrier takes unit u returns boolean
        if (u == null or u == Carrier or Carrier == null) then
            return false
        endif
        return IsUnitIllusion(u) and GetUnitTypeId(u) == CarrierType and GetOwningPlayer(u) == GetOwningPlayer(Carrier) and GetWidgetLife(u) > 0.405
    endfunction

    // Saca la copia del slot i: destruye su indicador y compacta el array trayendo
    // la ultima al hueco, para no dejar slots muertos en el medio.
    private function RemoveCopyAt takes integer i returns nothing
        if (i < 0 or i >= CopyCount) then
            return
        endif
        if (CopyFX[i] != null) then
            call DestroyEffect(CopyFX[i])
        endif
        set CopyUnit[i] = CopyUnit[CopyCount - 1]
        set CopyFX[i]   = CopyFX[CopyCount - 1]
        set CopyUnit[CopyCount - 1] = null
        set CopyFX[CopyCount - 1]   = null
        set CopyCount = CopyCount - 1
    endfunction

    // Suelta las copias que ya no califican (murieron o las removieron).
    private function PruneCopies takes nothing returns nothing
        local integer i = 0
        loop
            exitwhen i >= CopyCount
            if (CopyUnit[i] == null or GetWidgetLife(CopyUnit[i]) <= 0.405) then
                call RemoveCopyAt(i)
                // No se incrementa i: en este slot ahora hay otra copia sin revisar.
            else
                set i = i + 1
            endif
        endloop
    endfunction

    // Marca las copias nuevas. Solo enumera las unidades del dueño del portador
    // (una sola llamada, y unicamente mientras alguien lleve el item).
    private function ScanCopies takes nothing returns nothing
        local group g
        local unit  u
        if (Carrier == null) then
            call ClearCopies()
            return
        endif
        call PruneCopies()
        set g = CreateGroup()
        call GroupEnumUnitsOfPlayer(g, GetOwningPlayer(Carrier), null)
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            call GroupRemoveUnit(g, u)
            if (CopyCount < MDR_MAX_COPIES and IsCopyOfCarrier(u) and not IsCopyTracked(u)) then
                set CopyUnit[CopyCount] = u
                set CopyFX[CopyCount]   = AddSpecialEffectTarget(MDR_MODEL, u, MDR_ATTACH)
                set CopyCount = CopyCount + 1
            endif
        endloop
        call DestroyGroup(g)
        set g = null
        set u = null
    endfunction

    //=======================================================================
    // ANUNCIO DE COMPRA
    //=======================================================================
    // UNA sola vez por partida, y solo cuando lo COMPRAN. El item se vende una unica
    // vez (la tienda no repone dentro de una partida): despues de eso solo cambia de
    // manos o lo destruyen, y eso ya no es noticia. Por eso cuelga de la venta y no
    // del cambio de portador: recoger del suelo o recibirlo de un aliado NO anuncia.
    // El booleano es la garantia dura por si la venta llegara a dispararse dos veces.
    private function Announce takes nothing returns nothing
        local integer i = 0
        if (Announced) then
            return
        endif
        set Announced = true
        // No usar DisplayTimedTextToForce aqui: ese BJ resuelve el destinatario
        // con GetLocalPlayer(), que no cambia al alternar el POV de un replay.
        // El envio explicito mantiene una sola copia por cliente en partida normal
        // y deja disponible la copia correspondiente a cada POV en la repeticion.
        loop
            exitwhen i > MDR_LAST_VIEWER
            call DisplayTimedTextToPlayer(Player(i), 0, 0, MDR_ANNOUNCE_TIME, MDR_ANNOUNCE_MSG)
            set i = i + 1
        endloop
    endfunction

    //=======================================================================
    // CAMBIO DE PORTADOR
    //=======================================================================
    // UNICA puerta de entrada: destruye lo viejo (portador y copias) y pega lo
    // nuevo. Si el portador no cambio, no toca nada.
    private function SetCarrier takes unit u returns nothing
        if (u == Carrier) then
            return
        endif
        call ClearCopies()   // las copias son del portador viejo
        set Carrier = u
        if (u == null) then
            set CarrierType = 0
            set CarrierBase = 0
        else
            set CarrierType = GetUnitTypeId(u)
            set CarrierBase = CarrierType   // referencia fija: contra esto se mide el morfeo
        endif
        call RefreshFX()     // pega el del nuevo y destruye el del viejo
    endfunction

    // El item dejo de existir. Como es UNICO y la tienda no repone dentro de una
    // partida, se apaga el sistema entero en vez de seguir barriendo el mapa.
    // No es irreversible: los triggers de evento siguen vivos y lo despiertan.
    private function Sleep takes nothing returns nothing
        call SetCarrier(null)
        set InPlay       = false
        set MissingBeats = 0
        call PauseTimer(TickTimer)
    endfunction

    //=======================================================================
    // DONDE ESTA EL ITEM (siempre por TIPO, nunca por handle guardado)
    //=======================================================================
    private function UnitCarriesItem takes unit u returns boolean
        local integer i = 0
        local integer n
        if (u == null) then
            return false
        endif
        set n = UnitInventorySize(u)   // un morfeado sin inventario responde 0
        loop
            exitwhen i >= n
            if (GetItemTypeId(UnitItemInSlot(u, i)) == MDR_ITEM_ID) then
                return true
            endif
            set i = i + 1
        endloop
        return false
    endfunction

    // Barrido de inventarios de los slots reales (0-9). Solo corre en el latido
    // lento y solo cuando el portador conocido no responde.
    private function FindCarrier takes nothing returns unit
        local group   g     = CreateGroup()
        local unit    u
        local unit    found = null
        local integer i     = 0
        loop
            exitwhen i > MDR_LAST_PLAYER or found != null
            call GroupEnumUnitsOfPlayer(g, Player(i), null)
            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                call GroupRemoveUnit(g, u)
                if (found == null and UnitCarriesItem(u)) then
                    set found = u
                endif
            endloop
            set i = i + 1
        endloop
        call DestroyGroup(g)
        set g = null
        set u = null
        return found
    endfunction

    private function GroundScan takes nothing returns nothing
        if (GetItemTypeId(GetEnumItem()) == MDR_ITEM_ID) then
            set GroundHit = true
        endif
    endfunction

    // EnumItemsInRect solo ve items TIRADOS: los que estan en un inventario no
    // estan en el mundo. Por eso "no esta en ningun inventario y tampoco en el
    // suelo" significa limbo del motor, no perdida.
    private function ItemIsOnGround takes nothing returns boolean
        set GroundHit = false
        call EnumItemsInRect(WorldRect, null, function GroundScan)
        return GroundHit
    endfunction

    // Resuelve la identidad del portador con evidencia POSITIVA. Ver la cabecera
    // (superficie de falla 1) antes de cambiar el orden de estas ramas.
    private function ResolveCarrier takes nothing returns nothing
        local unit    u
        local boolean carrierAlive = Carrier != null and GetWidgetLife(Carrier) > 0.405

        // 1. Camino normal: el portador conocido sigue vivo y con el item. Sin barridos.
        if (carrierAlive and UnitCarriesItem(Carrier)) then
            set MissingBeats = 0
            return
        endif

        // 2. MORFEO = prueba a favor. Vivo y con otro unit-type del que tenia al
        //    agarrarlo: el motor le escondio el inventario (Hex/polimorfia). Sigue
        //    siendo el portador y no hace falta barrer nada.
        if (carrierAlive and GetUnitTypeId(Carrier) != CarrierBase) then
            set MissingBeats = 0
            return
        endif

        // 3. Barrido de inventarios.
        set u = FindCarrier()
        if (u != null) then
            call SetCarrier(u)
            set MissingBeats = 0
            set u = null
            return
        endif
        set u = null

        // 4. No lo tiene nadie: ¿esta tirado en el suelo?
        if (ItemIsOnGround()) then
            set MissingBeats = 0
            call SetCarrier(null)
            return
        endif

        // 5. Ni en inventarios ni en el suelo, con el portador vivo y sin morfear.
        //    Estado que no deberia existir. Ante la duda se CONSERVA el indicador:
        //    perderlo es el bug que este sistema viene a matar.
        if (carrierAlive) then
            return
        endif

        // 6. Sin portador vivo y sin rastro del item: candidato a destruido. Se pide
        //    confirmacion porque entre la muerte del portador y el instante en que el
        //    item toca el suelo hay una ventana en la que no esta en ningun lado.
        call SetCarrier(null)
        set MissingBeats = MissingBeats + 1
        if (MissingBeats >= MDR_MISSING) then
            call Sleep()
        endif
    endfunction

    //=======================================================================
    // TICK: fuente de verdad
    //=======================================================================
    private function OnTick takes nothing returns nothing
        // 1. Muerte del portador. El evento de muerte ya lo cubre; esto es la red
        //    por si el motor se lo lleva sin disparar evento.
        if (Carrier != null and GetWidgetLife(Carrier) <= 0.405) then
            call SetCarrier(null)
        endif

        // 2. LATIDO: reresolver identidad y reconstruir los efectos, sin importar
        //    si "hacia falta". Es lo unico que sobrevive a causas desconocidas.
        set BeatCount = BeatCount + 1
        if (BeatCount >= MDR_BEAT) then
            set BeatCount = 0
            call ResolveCarrier()
            call RefreshFX()
            call RefreshCopiesFX()
        endif

        // 3. Transformacion: mismo handle, mismo inventario, otro modelo. El latido
        //    lo arreglaria igual, pero hasta MDR_BEAT ticks despues; esto reengancha
        //    en el acto y mantiene el indicador tambien sobre la forma alterna.
        if (Carrier != null and GetUnitTypeId(Carrier) != CarrierType) then
            set CarrierType = GetUnitTypeId(Carrier)
            call RefreshFX()
        endif

        // 4. Copias del portador (ilusiones): marcarlas y limpiar las que murieron.
        call ScanCopies()
    endfunction

    //=======================================================================
    // EVENTOS: latencia cero (el tick igual corrige)
    //=======================================================================

    // El item entro en juego: arranca el sondeo. Se llama SOLO desde los eventos;
    // el tick no puede despertarse a si mismo porque esta pausado justamente hasta
    // que esto corra. Va despues de OnTick por el orden de declaracion de JASS.
    private function Wake takes nothing returns nothing
        if (InPlay) then
            return
        endif
        set InPlay       = true
        set MissingBeats = 0
        set BeatCount    = 0
        call TimerStart(TickTimer, MDR_TICK, true, function OnTick)
    endfunction

    // Comprar en tienda, recoger del suelo o recibir de un aliado.
    private function OnPickup takes nothing returns nothing
        if (GetItemTypeId(GetManipulatedItem()) != MDR_ITEM_ID) then
            return
        endif
        call Wake()
        call SetCarrier(GetTriggerUnit())
    endfunction

    // Venta de la tienda. Es el UNICO evento que significa "lo compraron": el PICKUP
    // no distingue una compra de levantarlo del suelo. Por eso el anuncio sale de
    // aca. Ademas despierta al sistema: la tienda NO vende con el inventario lleno,
    // asi que el PICKUP llega siempre y este despertador es redundante a proposito
    // (dos vias independientes cuestan un trigger y evitan depender de un evento).
    private function OnSold takes nothing returns nothing
        if (GetItemTypeId(GetSoldItem()) != MDR_ITEM_ID) then
            return
        endif
        call Wake()
        call Announce()
    endfunction

    // Soltar al suelo o pasarselo a otro (el receptor dispara su propio PICKUP).
    // Tambien despierta: si el sistema estaba dormido y este evento llega, el item
    // existe, y el sondeo tiene que volver a hacerse cargo.
    private function OnDrop takes nothing returns nothing
        if (GetItemTypeId(GetManipulatedItem()) != MDR_ITEM_ID) then
            return
        endif
        call Wake()
        call SetCarrier(null)
    endfunction

    // Muerte. El tick lo corregiria igual, pero hasta MDR_TICK segundos despues, y
    // en ese rato el indicador queda flotando sobre el cadaver. Al morir el item
    // cae al suelo: el portador deja de serlo en el acto.
    private function OnDeath takes nothing returns nothing
        local unit    d = GetTriggerUnit()
        local integer i = 0
        if (Carrier == null) then
            set d = null
            return
        endif
        if (d == Carrier) then
            call SetCarrier(null)   // arrastra tambien los indicadores de las copias
            set d = null
            return
        endif
        loop
            exitwhen i >= CopyCount
            if (CopyUnit[i] == d) then
                call RemoveCopyAt(i)
                exitwhen true
            endif
            set i = i + 1
        endloop
        set d = null
    endfunction

    //=======================================================================
    private function OnInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer i = 0

        // PICKUP y DROP para los slots reales 0-9 (incluye jugadores Computer: los
        // bots tambien compran y recogen items). Nadie fuera de esos slots puede
        // llevar el item, asi que registrar los neutrales seria trabajo al pedo.
        loop
            exitwhen i > MDR_LAST_PLAYER
            call TriggerRegisterPlayerUnitEvent(t, Player(i), EVENT_PLAYER_UNIT_PICKUP_ITEM, null)
            set i = i + 1
        endloop
        call TriggerAddAction(t, function OnPickup)

        set t = CreateTrigger()
        set i = 0
        loop
            exitwhen i > MDR_LAST_PLAYER
            call TriggerRegisterPlayerUnitEvent(t, Player(i), EVENT_PLAYER_UNIT_DROP_ITEM, null)
            set i = i + 1
        endloop
        call TriggerAddAction(t, function OnDrop)

        // Venta: la tienda es una unidad NEUTRAL y el evento se dispara del lado del
        // vendedor, asi que este si va registrado para todos los slots.
        set t = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SELL_ITEM)
        call TriggerAddAction(t, function OnSold)

        // Muerte del portador o de una copia: apagado instantaneo. Solo slots reales:
        // heroes e ilusiones pertenecen a un jugador 0-9, y asi la marea de muertes
        // de creeps (que son de slots neutrales) no llega ni a entrar al handler.
        set t = CreateTrigger()
        set i = 0
        loop
            exitwhen i > MDR_LAST_PLAYER
            call TriggerRegisterPlayerUnitEvent(t, Player(i), EVENT_PLAYER_UNIT_DEATH, null)
            set i = i + 1
        endloop
        call TriggerAddAction(t, function OnDeath)

        // Un solo rect para toda la partida: GetWorldBounds() devuelve uno nuevo
        // en cada llamada, pedirlo dentro del tick seria una fuga por latido.
        set WorldRect = GetWorldBounds()

        // El timer se crea PAUSADO: hasta que alguien compre el item (o aparezca por
        // cualquier via) este sistema no ejecuta absolutamente nada. Lo arranca Wake().
        set TickTimer = CreateTimer()

        set t = null
    endfunction

endlibrary
