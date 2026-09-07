//===========================================================================
// SISTEMA DE COMANDOS DE ECONOMÍA (TRANSFERENCIA Y PETICIÓN DE ORO/MADERA)
//===========================================================================
//
// COMANDOS:
//   -oro <jugador> <cantidad|todo>     Transferencia directa de oro.
//   -madera <jugador> <cantidad|todo>  Transferencia directa de madera.
//   -fondo / -f <cantidad>             Abre una petición de oro (bote) para tu equipo.
//   ok / -ok                           Aporta al bote activo de tu equipo (da solo lo que falta).
//
// PETICIÓN DE ORO (bote / crowdfunding, SOLO ORO):
//   - UNA petición activa por equipo a la vez. Dura ECO_REQ_DURATION segundos.
//     Mientras una está activa, todo "-fondo"/"-f" nuevo del equipo se IGNORA en silencio.
//   - La solicitud muestra un PANEL vivo en pantalla (texttag que sigue la cámara,
//     estilo Datos_EnVivo) con progreso y contador en vivo; se reemplaza al instante
//     y desaparece de golpe. Además deja un LOG corto en el chat por cada hito.
//   - "ok" o "-ok" entrega min(faltante, tu oro). Varios aportes llenan el bote hasta la meta.
//     El "ok" sin guion solo se interpreta durante los 20s de una petición activa;
//     fuera de esa ventana es chat normal y se ignora por completo.
//   - "-oro <pedidor> N" envía N literal (capado solo a tu oro); si llega/supera la meta, cierra.
//   - Una contribución (por "ok"/"-ok" o por "-oro" al pedidor) es PÚBLICA: mismo mensaje para
//     todo el equipo (no las 3 vistas personalizadas de una transferencia directa).
//     El aporte que completa anuncia "(meta/meta) ¡Completada!" en el chat; si "-oro"
//     sobrepasó la meta, agrega "+N extra" (el sobrante también va al pedidor).
//   - El cuadro de apertura tiene variante en 1ra persona para el propio pedidor.
//   - Visible SOLO para aliados (mensajes por slot y panel según el POV observado).
//
// CONTABILIDAD (premio "Top Donador" / puntaje en Sistema_Victoria.j):
//   - TODO oro que cambia de bolsillo suma key 701 al DONANTE y key 702 al
//     RECEPTOR en udg_MB_Hash. Sistema_Victoria.j puntúa el NETO
//     max(0, 701 - 702): circular oro entre aliados (ping-pong, círculos de
//     3+) se cancela solo; únicamente puntúa lo regalado por encima de lo
//     recibido. Devolver oro no pedido restaura el neto del que devuelve.
//   - La madera NO suma a key 701/702 (igual que siempre).
//===========================================================================

globals
    sound Eco_Snd_Gold   = null // Global persistente (patrón tabla.j)
    sound Eco_Snd_Lumber = null // Global persistente (patrón tabla.j)
    boolean array Eco_HudHidden             // true = jugador desactivó el HUD con -hud; escrito por Datos_EnVivo.j

    // --- Estado del bote de petición de oro (índice 0 = Humanos, 1 = Orcos) ---
    constant real     ECO_REQ_DURATION = 20.0
    constant integer  ECO_REQ_MAX_GOAL = 6500   // tope de la petición de -fondo (el exceso se recorta en silencio)
    boolean array     Eco_Req_Active     // ¿hay una petición activa en ese equipo?
    integer array     Eco_Req_Requester  // playerId del que pidió
    integer array     Eco_Req_Goal       // meta de oro
    integer array     Eco_Req_Filled     // oro recaudado hasta ahora
    timer array       Eco_Req_Timer      // tick periódico (ECO_REQ_TICK) mientras hay colecta
    texttag array     Eco_Req_Tag        // panel vivo en pantalla (sigue la cámara)
    real array        Eco_Req_Elapsed    // segundos transcurridos (para el contador)
    integer array     Eco_Req_LastSec    // último segundo dibujado (evita rebuild por tick)
    boolean array     Eco_Req_Closing    // true durante el grace de cierre del panel
    real array        Eco_Req_CloseGrace // segundos restantes del grace de cierre

    // === Panel vivo (texttag). AJUSTABLES: calibrar offsets en el World Editor ===
    constant real     ECO_REQ_TICK       = 0.03    // ~33 FPS: sigue la cámara fluido
    constant real     ECO_OPEN_DUR       = 7.0     // duración del cuadro de chat de apertura
    constant real     ECO_PANEL_GRACE    = 2.0     // cuánto se queda el estado final (verde/rojo) antes de borrarse
    constant real     ECO_PANEL_SIZE     = 0.020   // tamaño del texto del panel (bájalo si hace salto de línea)
    constant real     ECO_PANEL_ZOOM_REF = 1650.0  // zoom de referencia (igual que el HUD)
    constant real     ECO_PANEL_OFFSET_X = -75.0  // desplazamiento desde el centro de cámara
    constant real     ECO_PANEL_OFFSET_Y = -420.0   // (+Y = arriba). AJUSTAR para no chocar con otros HUD

    // === DETECCIÓN DE ORO TRANSFERIDO POR F11 (panel de aliados) ===
    // El motor NO dispara ningún evento al regalar recursos por F11; la única
    // vía es SONDEAR el oro de cada jugador y emparejar un −X (emisor) con un
    // +X (receptor) entre DOS aliados REALES en el mismo tick. El F11 es "UN
    // COMANDO MÁS": alimenta el MISMO pool que los comandos (keys 701 enviado /
    // 702 recibido), así Sistema_Victoria.j lo puntúa SIN CAMBIOS y el filtro
    // anti-abuso NETO max(0, 701-702) es ÚNICO (mandar y devolver se cancela aunque
    // un canal sea F11 y el otro un comando).
    //
    // INVARIANTE: el sondeo solo debe "ver" como delta los REGALOS F11. Por eso
    // TODO otro movimiento de oro que NO sea un regalo F11 debe mantener
    // Eco_GoldBaseline en sync (avanzar la base o re-sembrar). Fuentes enganchadas:
    //   - comandos -oro/-fondo/-f/ok/-ok ..... Eco_MoveGold (este archivo)
    //   - renta base (a todos, 1s) ........... Core_Mecanica_Oro (GUI custom script)
    //   - reparto del oro del desertor ....... Voto_EjecutarDrop (Sistema_Voto.j)
    //   - COMPRAS en tienda .................. Eco_OnItemBought (este archivo, vía IADataItems)
    //   - VENTA/EMPEÑO (reembolso mitad) ..... Eco_OnItemPawned (este archivo, vía IADataItems)
    //   - Sello de Fortificación ('gfor') .... Sistema_Sello_Fortificacion.j (no está en la DB)
    //   - BOUNTY de matar (fijo) ............. Sistema_Merito_Track.j
    // Si falta uno, ese movimiento se confundiría con un regalo F11 (falso positivo)
    // o descuadraría un par real (regalo perdido). El gasto/recompensa unilateral
    // que NO se sincronice solo causa un raro falso negativo (dirección segura).
    constant real     ECO_POLL_TICK          = 0.10
    constant integer  ECO_F11_ALLIN_MAXLEFT  = 150   // si al emisor le queda < esto, se acepta un monto NO múltiplo de 100 (caso "mando todo": el último incremento se completa con el resto del bolsillo). AJUSTABLE (debug-first).
    integer array     Eco_GoldBaseline               // último oro sondeado, por jugador (0-9)
    boolean           Eco_PollSeeded         = false
    timer             Eco_PollTimer          = null
    // Scratch reusado cada tick (JASS no tiene arrays locales).
    integer array     Eco_PollGoldNow
    integer array     Eco_PollDelta
    boolean array     Eco_PollUsed
endglobals

// --- FUNCIÓN DE BÚSQUEDA ---
function Economia_GetPlayer takes string s returns player
    local string input = StringCase(s, false)
    local player p
    local integer i = 0

    // 0. INPUT VACÍO (p.ej. doble espacio en "-oro  500"): sin esta guarda, el
    //    match de nombres parciales con prefijo de longitud 0 devolvía al PRIMER
    //    jugador PLAYING del loop (el rojo) y le regalaba el oro.
    if (input == "") then
        return null
    endif

    // 1. NÚMEROS DE JUGADOR (1 al 10)
    if (input == "1") then
        return Player(0)
    elseif (input == "2") then
        return Player(1)
    elseif (input == "3") then
        return Player(2)
    elseif (input == "4") then
        return Player(3)
    elseif (input == "5") then
        return Player(4)
    elseif (input == "6") then
        return Player(5)
    elseif (input == "7") then
        return Player(6)
    elseif (input == "8") then
        return Player(7)
    elseif (input == "9") then
        return Player(8)
    elseif (input == "10") then
        return Player(9)
    endif

    // 2. COLORES
    if (input == "rojo" or input == "red") then
        return Player(0)
    elseif (input == "azul" or input == "blue") then
        return Player(1)
    elseif (input == "teal" or input == "cian") then
        return Player(2)
    elseif (input == "morado" or input == "purple") then
        return Player(3)
    elseif (input == "amarillo" or input == "yellow") then
        return Player(4)
    elseif (input == "naranja" or input == "orange") then
        return Player(5)
    elseif (input == "verde" or input == "green") then
        return Player(6)
    elseif (input == "rosa" or input == "pink") then
        return Player(7)
    elseif (input == "gris" or input == "grey" or input == "gray") then
        return Player(8)
    elseif (input == "celeste" or input == "light") then
        return Player(9)
    endif

    // 3. NOMBRES PARCIALES
    set i = 0
    loop
        exitwhen i > 9
        set p = Player(i)
        if (GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING) then
            if (SubString(StringCase(GetPlayerName(p), false), 0, StringLength(input)) == input) then
                return p
            endif
        endif
        set i = i + 1
    endloop

    set p = null
    return null
endfunction

// --- HELPER DE COLOR (Para los mensajes) ---
function Economia_GetColor takes player p returns string
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

// --- Nombre coloreado listo para mensajes ---
function Eco_CName takes player p returns string
    return Economia_GetColor(p) + GetPlayerName(p) + "|r"
endfunction

// --- Índice de equipo (0 = Humanos slots 0-4, 1 = Orcos slots 5-9) ---
function Eco_TeamIndex takes player p returns integer
    if (GetPlayerId(p) <= 4) then
        return 0
    endif
    return 1
endfunction

// --- Anuncio uniforme a todo el equipo (solo jugadores humanos jugando) ---
function Eco_AnnounceTeam takes integer team, string msg returns nothing
    local integer i
    local integer lo = 0
    local integer hi = 4
    if (team == 1) then
        set lo = 5
        set hi = 9
    endif
    set i = lo
    loop
        exitwhen i > hi
        if (GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(i)) == MAP_CONTROL_USER) then
            call DisplayTimedTextToPlayer(Player(i), 0, 0, 8.0, msg)
        endif
        set i = i + 1
    endloop
endfunction

// --- Sonido de oro SOLO para un jugador (patrón tabla: global persistente) ---
function Eco_PlayGoldSound takes player toWhom returns nothing
    call SetSoundVolume(Eco_Snd_Gold, 0)
    if (GetLocalPlayer() == toWhom) then
        call SetSoundVolume(Eco_Snd_Gold, 127)
    endif
    call StartSound(Eco_Snd_Gold)
endfunction

// --- Movimiento de ORO de bajo nivel: estado + contabilidad (keys 701/702) + sonido al receptor.
//     NO emite mensajes (cada caller decide qué mensaje mostrar). ---
function Eco_MoveGold takes player fromP, player toP, integer amount returns nothing
    if (amount <= 0) then
        return
    endif
    call SetPlayerState(fromP, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(fromP, PLAYER_STATE_RESOURCE_GOLD) - amount)
    call SetPlayerState(toP, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(toP, PLAYER_STATE_RESOURCE_GOLD) + amount)
    // Contabilidad "Top Donador": key 701 = oro enviado (sobre el donante),
    // key 702 = oro recibido (sobre el receptor). Sistema_Victoria.j puntúa
    // el NETO max(0, 701 - 702) para que circular oro no fabrique puntos.
    call SaveInteger(udg_MB_Hash, GetPlayerId(fromP), 701, LoadInteger(udg_MB_Hash, GetPlayerId(fromP), 701) + amount)
    call SaveInteger(udg_MB_Hash, GetPlayerId(toP), 702, LoadInteger(udg_MB_Hash, GetPlayerId(toP), 702) + amount)
    // Sincroniza la línea base del poller F11: este movimiento es por COMANDO
    // (ya contabilizado en 701/702), así que el sondeo NO debe volver a contarlo
    // como un regalo F11. Avanzar la base por el monto deja delta 0 en esa parte
    // y conserva intacto cualquier F11 simultáneo del mismo tick.
    set Eco_GoldBaseline[GetPlayerId(fromP)] = Eco_GoldBaseline[GetPlayerId(fromP)] - amount
    set Eco_GoldBaseline[GetPlayerId(toP)]   = Eco_GoldBaseline[GetPlayerId(toP)]   + amount
    call Eco_PlayGoldSound(toP)
endfunction

// --- Transferencia directa: cada jugador del equipo ve UN mensaje según su rol.
//     Emisor (1ra persona) / Receptor (1ra persona) / aliado espectador (3ra persona). ---
function Eco_BroadcastTransfer takes player fromP, player toP, integer amount, string resName returns nothing
    local integer team = Eco_TeamIndex(fromP)
    local integer lo = 0
    local integer hi = 4
    local integer i
    local player p
    if (team == 1) then
        set lo = 5
        set hi = 9
    endif
    set i = lo
    loop
        exitwhen i > hi
        set p = Player(i)
        if (GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(p) == MAP_CONTROL_USER) then
            if (p == fromP) then
                call DisplayTimedTextToPlayer(p, 0, 0, 8.0, "Enviaste " + I2S(amount) + " de " + resName + " a " + Eco_CName(toP) + ".")
            elseif (p == toP) then
                call DisplayTimedTextToPlayer(p, 0, 0, 8.0, Eco_CName(fromP) + " te envió " + I2S(amount) + " de " + resName + ".")
            else
                call DisplayTimedTextToPlayer(p, 0, 0, 8.0, Eco_CName(fromP) + " envió " + I2S(amount) + " de " + resName + " a " + Eco_CName(toP) + ".")
            endif
        endif
        set i = i + 1
    endloop
    set p = null
endfunction

// --- Texto del panel vivo (1 línea; los texttags no son multilínea). COMPACTO a
//     propósito para no hacer salto de línea: nombre + progreso + segundos. ---
function Eco_Req_PanelText takes integer team, integer secsLeft returns string
    return Eco_CName(Player(Eco_Req_Requester[team])) + " |cffFFCC00" + I2S(Eco_Req_Filled[team]) + "/" + I2S(Eco_Req_Goal[team]) + "|r  " + I2S(secsLeft) + "s"
endfunction

// --- Reposiciona el panel contra la cámara del POV observado (en juego normal,
//     la cámara local). Solo es visible para aliados del que pidió y respeta
//     -hud (desync-safe: el texttag es puramente visual). ---
function Eco_Req_Reposition takes integer team returns nothing
    local player req = Player(Eco_Req_Requester[team])
    local player viewer = GetReplayPlayerCached()
    local real ratio
    if (Eco_Req_Tag[team] == null) then
        set req = null
        set viewer = null
        return
    endif
    if ((IsPlayerAlly(viewer, req) or viewer == req) and not Eco_HudHidden[GetPlayerId(viewer)]) then
        set ratio = GetCameraField(CAMERA_FIELD_TARGET_DISTANCE) / ECO_PANEL_ZOOM_REF
        if (ratio < 0.5) then
            set ratio = 0.5
        elseif (ratio > 3.0) then
            set ratio = 3.0
        endif
        call SetTextTagPos(Eco_Req_Tag[team], GetCameraTargetPositionX() + ECO_PANEL_OFFSET_X * ratio, GetCameraTargetPositionY() + ECO_PANEL_OFFSET_Y * ratio, 0.0)
        call SetTextTagVisibility(Eco_Req_Tag[team], true)
    else
        call SetTextTagVisibility(Eco_Req_Tag[team], false)
    endif
    set req = null
    set viewer = null
endfunction

// --- Cierre INMEDIATO: destruye panel + timer y resetea (sin grace). ---
function Eco_Req_FullTeardown takes integer team returns nothing
    if (Eco_Req_Timer[team] != null) then
        call PauseTimer(Eco_Req_Timer[team])
        call DestroyTimer(Eco_Req_Timer[team])
        set Eco_Req_Timer[team] = null
    endif
    if (Eco_Req_Tag[team] != null) then
        call DestroyTextTag(Eco_Req_Tag[team])
        set Eco_Req_Tag[team] = null
    endif
    set Eco_Req_Active[team]  = false
    set Eco_Req_Closing[team] = false
endfunction

// --- Cierre con GRACIA: deja de aceptar, muestra el estado final en el panel y
//     programa su borrado instantáneo tras ECO_PANEL_GRACE (lo destruye el tick). ---
function Eco_Req_BeginClose takes integer team, string finalText returns nothing
    set Eco_Req_Active[team]     = false
    set Eco_Req_Closing[team]    = true
    set Eco_Req_CloseGrace[team] = ECO_PANEL_GRACE
    if (Eco_Req_Tag[team] != null) then
        call SetTextTagText(Eco_Req_Tag[team], finalText, ECO_PANEL_SIZE)
    endif
endfunction

// --- Registra un aporte ya transferido: actualiza panel + log de chat; cierra al completar. ---
function Eco_Req_RegisterContribution takes integer team, player donor, integer given returns nothing
    local player req = Player(Eco_Req_Requester[team])
    local integer goal = Eco_Req_Goal[team]
    local integer shown
    set Eco_Req_Filled[team] = Eco_Req_Filled[team] + given
    set shown = Eco_Req_Filled[team]
    if (shown > goal) then
        set shown = goal
    endif
    if (Eco_Req_Filled[team] >= goal) then
        // LOG (1 línea): el chat persiste más que el panel (grace 3.5s), así que el
        // cierre va explícito aquí. Si hubo exceso (-oro envía literal), el desglose
        // "+N extra" aclara que el sobrante también se entregó al pedidor.
        if (Eco_Req_Filled[team] > goal) then
            call Eco_AnnounceTeam(team, Eco_CName(donor) + " aportó |cffFFCC00" + I2S(given) + "|r de oro  (|cffFFCC00" + I2S(goal) + "/" + I2S(goal) + "|r, +" + I2S(Eco_Req_Filled[team] - goal) + " extra)  |cff40ff40¡Completado!|r")
        else
            call Eco_AnnounceTeam(team, Eco_CName(donor) + " aportó |cffFFCC00" + I2S(given) + "|r de oro  (|cffFFCC00" + I2S(goal) + "/" + I2S(goal) + "|r)  |cff40ff40¡Completado!|r")
        endif
        // PANEL: estado final + borrado instantáneo tras el grace.
        call Eco_Req_BeginClose(team, "|cff40ff40COMPLETADO  " + I2S(goal) + "/" + I2S(goal) + "|r")
    else
        // LOG (1 línea): aporte parcial.
        call Eco_AnnounceTeam(team, Eco_CName(donor) + " aportó |cffFFCC00" + I2S(given) + "|r de oro  (|cffFFCC00" + I2S(shown) + "/" + I2S(goal) + "|r)")
        // Fuerza rebuild del panel en el próximo tick (cambió el progreso).
        set Eco_Req_LastSec[team] = -1
    endif
    set req = null
endfunction

// --- Expiración (se agotó ECO_REQ_DURATION sin completarse): solo cierre con gracia. ---
function Eco_Req_Expire takes integer team returns nothing
    local player req = Player(Eco_Req_Requester[team])
    // Sin línea de chat: el panel en vivo ya muestra "EXPIRADA".
    call Eco_Req_BeginClose(team, "|cffff6060EXPIRADO  " + I2S(Eco_Req_Filled[team]) + "/" + I2S(Eco_Req_Goal[team]) + "|r")
    set req = null
endfunction

// --- Tick del panel (ECO_REQ_TICK mientras hay colecta): sigue la cámara, baja el
//     contador, dispara la expiración y, en el grace, borra el panel de golpe. ---
function Eco_Req_Tick takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer team = 0
    local integer secsLeft
    loop
        exitwhen team > 1
        if (Eco_Req_Timer[team] == t) then
            if (Eco_Req_Closing[team]) then
                // Grace: solo seguir la cámara; al agotarse, borrado instantáneo.
                set Eco_Req_CloseGrace[team] = Eco_Req_CloseGrace[team] - ECO_REQ_TICK
                call Eco_Req_Reposition(team)
                if (Eco_Req_CloseGrace[team] <= 0.0) then
                    call Eco_Req_FullTeardown(team)
                endif
                set t = null
                return
            endif
            // Activo: avanzar el contador.
            set Eco_Req_Elapsed[team] = Eco_Req_Elapsed[team] + ECO_REQ_TICK
            set secsLeft = R2I(ECO_REQ_DURATION - Eco_Req_Elapsed[team] + 0.9999)
            if (secsLeft < 0) then
                set secsLeft = 0
            endif
            if (secsLeft != Eco_Req_LastSec[team]) then
                set Eco_Req_LastSec[team] = secsLeft
                call SetTextTagText(Eco_Req_Tag[team], Eco_Req_PanelText(team, secsLeft), ECO_PANEL_SIZE)
            endif
            call Eco_Req_Reposition(team)
            if (Eco_Req_Elapsed[team] >= ECO_REQ_DURATION) then
                call Eco_Req_Expire(team)
            endif
            set t = null
            return
        endif
        set team = team + 1
    endloop
    set t = null
endfunction

// --- Cuadro de chat de APERTURA (estilo Cmd_Soy, dura ECO_OPEN_DUR), solo a aliados.
//     El seguimiento en vivo lo lleva el panel; aquí NO se menciona el tiempo.
//     El propio pedidor ve una variante en 1ra persona (a él "-ok" le daría error). ---
function Eco_Req_AnnounceOpen takes integer team, player req, integer amount returns nothing
    local integer i
    local integer lo = 0
    local integer hi = 4
    local player p
    if (team == 1) then
        set lo = 5
        set hi = 9
    endif
    set i = lo
    loop
        exitwhen i > hi
        set p = Player(i)
        if (GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(p) == MAP_CONTROL_USER) then
            call DisplayTimedTextToPlayer(p, 0, 0, ECO_OPEN_DUR, " ")
            call DisplayTimedTextToPlayer(p, 0, 0, ECO_OPEN_DUR, "|cffFFCC00====================================|r")
            if (p == req) then
                call DisplayTimedTextToPlayer(p, 0, 0, ECO_OPEN_DUR, "   Pediste |cffFFCC00" + I2S(amount) + "|r de oro a tu equipo")
                call DisplayTimedTextToPlayer(p, 0, 0, ECO_OPEN_DUR, "   Tus aliados pueden aportar con |cffFFCC00ok|r")
            else
                call DisplayTimedTextToPlayer(p, 0, 0, ECO_OPEN_DUR, "   " + Eco_CName(req) + " ha solicitado |cffFFCC00" + I2S(amount) + "|r de oro")
                call DisplayTimedTextToPlayer(p, 0, 0, ECO_OPEN_DUR, "   Escribe |cffFFCC00ok|r para aportar")
            endif
            call DisplayTimedTextToPlayer(p, 0, 0, ECO_OPEN_DUR, "|cffFFCC00====================================|r")
        endif
        set i = i + 1
    endloop
    set p = null
endfunction

// --- "-fondo <cantidad>" / "-f <cantidad>": abre una colecta de oro para el equipo del emisor ---
function Eco_HandlePido takes player sender, string amountStr returns nothing
    local integer team = Eco_TeamIndex(sender)
    local integer amount
    // SOLO UNA colecta por equipo a la vez. Si ya hay una activa o cerrándose (de quien
    // sea, incluido el propio emisor), se ignora la nueva POR COMPLETO: sin mensaje a nadie.
    if (Eco_Req_Active[team] or Eco_Req_Closing[team]) then
        return
    endif
    set amount = S2I(amountStr)
    if (amount <= 0) then
        call DisplayTimedTextToPlayer(sender, 0, 0, 5.0, "Cantidad inválida. Usa: -fondo 500 o -f 500")
        return
    endif
    // Tope silencioso: aunque pida más, la colecta nunca excede ECO_REQ_MAX_GOAL.
    if (amount > ECO_REQ_MAX_GOAL) then
        set amount = ECO_REQ_MAX_GOAL
    endif
    set Eco_Req_Active[team]    = true
    set Eco_Req_Closing[team]   = false
    set Eco_Req_Requester[team] = GetPlayerId(sender)
    set Eco_Req_Goal[team]      = amount
    set Eco_Req_Filled[team]    = 0
    set Eco_Req_Elapsed[team]   = 0.0
    set Eco_Req_LastSec[team]   = R2I(ECO_REQ_DURATION + 0.9999)
    // Panel vivo (texttag): se posiciona contra la cámara y solo lo ven los aliados.
    set Eco_Req_Tag[team] = CreateTextTag()
    call SetTextTagPermanent(Eco_Req_Tag[team], true)
    call SetTextTagText(Eco_Req_Tag[team], Eco_Req_PanelText(team, Eco_Req_LastSec[team]), ECO_PANEL_SIZE)
    call SetTextTagVisibility(Eco_Req_Tag[team], false)
    call Eco_Req_Reposition(team)
    // Tick periódico: sigue la cámara + baja el contador + dispara la expiración.
    set Eco_Req_Timer[team] = CreateTimer()
    call TimerStart(Eco_Req_Timer[team], ECO_REQ_TICK, true, function Eco_Req_Tick)
    // Cuadro de apertura en chat (estilo Cmd_Soy, 5s, sin mención del tiempo).
    call Eco_Req_AnnounceOpen(team, sender, amount)
endfunction

// --- "ok" / "-ok": aporta al bote activo del equipo del emisor (da solo lo que falta) ---
function Eco_HandleOk takes player sender returns nothing
    local integer team = Eco_TeamIndex(sender)
    local player req
    local integer remaining
    local integer have
    local integer give
    if (not Eco_Req_Active[team]) then
        call DisplayTimedTextToPlayer(sender, 0, 0, 5.0, "No hay ninguna petición activa en tu equipo.")
        return
    endif
    if (Eco_Req_Requester[team] == GetPlayerId(sender)) then
        call DisplayTimedTextToPlayer(sender, 0, 0, 5.0, "No puedes aportar a tu propia petición.")
        return
    endif
    set req = Player(Eco_Req_Requester[team])
    // El que pidió ya no está (salió) -> cancelar.
    if (GetPlayerSlotState(req) != PLAYER_SLOT_STATE_PLAYING) then
        call Eco_Req_FullTeardown(team)
        call DisplayTimedTextToPlayer(sender, 0, 0, 5.0, "La petición ya no está disponible.")
        set req = null
        return
    endif
    set remaining = Eco_Req_Goal[team] - Eco_Req_Filled[team]
    set have = GetPlayerState(sender, PLAYER_STATE_RESOURCE_GOLD)
    set give = remaining
    if (have < give) then
        set give = have
    endif
    if (give <= 0) then
        call DisplayTimedTextToPlayer(sender, 0, 0, 5.0, "No tienes oro para aportar.")
        set req = null
        return
    endif
    call Eco_MoveGold(sender, req, give)                 // mueve + keys 701/702 + sonido al que pidió
    call Eco_Req_RegisterContribution(team, sender, give) // mensajes + posible cierre
    set req = null
endfunction

// --- "ok" sin guion: respuesta contextual y silenciosa fuera de una colecta. ---
// Este listener recibe el chat general para poder ignorar mayusculas/minusculas,
// pero exige que el mensaje completo sea "ok" y que la ventana siga activa.
function Eco_HandleBareOkChat takes nothing returns nothing
    local string chat = StringCase(GetEventPlayerChatString(), false)
    local player sender = GetTriggerPlayer()
    local integer team
    if (chat == "ok") then
        set team = Eco_TeamIndex(sender)
        if (Eco_Req_Active[team]) then
            call Eco_HandleOk(sender)
        endif
    endif
    set sender = null
endfunction

// --- ACCIÓN PRINCIPAL ---
function Trig_Comandos_Economia_Actions takes nothing returns nothing
    local string chat = GetEventPlayerChatString()
    local player sender = GetTriggerPlayer()
    local string fullParam = ""
    local string targetStr = ""
    local string amountStr = ""
    local integer spaceIndex = -1
    local integer len
    local integer i = 0
    local integer team = 0

    local player target = null
    local playerstate resType
    local integer currentRes = 0
    local integer transferAmount = 0
    local boolean isGold = true
    local string resName = ""

    // 0. COMANDOS DE PETICIÓN (bote de oro)
    if (chat == "-ok") then
        call Eco_HandleOk(sender)
        set sender = null
        return
    elseif (SubString(chat, 0, 7) == "-fondo ") then
        call Eco_HandlePido(sender, SubString(chat, 7, StringLength(chat)))
        set sender = null
        return
    elseif (SubString(chat, 0, 3) == "-f ") then
        call Eco_HandlePido(sender, SubString(chat, 3, StringLength(chat)))
        set sender = null
        return
    endif

    // 1. IDENTIFICAR COMANDO DE TRANSFERENCIA DIRECTA
    if (SubString(chat, 0, 5) == "-oro ") then
        set fullParam = SubString(chat, 5, StringLength(chat))
        set resType = PLAYER_STATE_RESOURCE_GOLD
        set isGold = true
        set resName = "oro"
    elseif (SubString(chat, 0, 8) == "-madera ") then
        set fullParam = SubString(chat, 8, StringLength(chat))
        set resType = PLAYER_STATE_RESOURCE_LUMBER
        set isGold = false
        set resName = "madera"
    else
        set sender = null
        return // No es un comando válido
    endif

    // 2. PARSEAR PARÁMETROS ("jugador cantidad")
    set len = StringLength(fullParam)
    set i = 0
    loop
        exitwhen i >= len
        if (SubString(fullParam, i, i+1) == " ") then
            set spaceIndex = i
            exitwhen true
        endif
        set i = i + 1
    endloop

    if (spaceIndex == -1) then
        call DisplayTimedTextToPlayer(sender, 0, 0, 5.0, "Formato incorrecto.")
        set sender = null
        return
    endif

    set targetStr = SubString(fullParam, 0, spaceIndex)
    set amountStr = SubString(fullParam, spaceIndex + 1, len)

    // 3. BUSCAR JUGADOR OBJETIVO
    set target = Economia_GetPlayer(targetStr)

    if (target == null) then
        call DisplayTimedTextToPlayer(sender, 0, 0, 5.0, "Jugador no encontrado: " + targetStr)
        set sender = null
        return
    endif

    // 4. VALIDACIONES DE SEGURIDAD
    if (target == sender) then
        call DisplayTimedTextToPlayer(sender, 0, 0, 5.0, "No puedes enviarte " + resName + " a ti mismo.")
        set sender = null
        set target = null
        return
    endif

    // ¿Es un bot post-encuesta? (jugador salió, IA lo reemplazó)
    // Verificar ANTES de GetPlayerSlotState porque el jugador tiene PLAYER_SLOT_STATE_LEFT
    if (LoadBoolean(udg_MB_Hash, GetPlayerId(target), 102) == true) then
        call DisplayTimedTextToPlayer(sender, 0, 0, 5.0, "No puedes transferir recursos a la IA.")
        set sender = null
        set target = null
        return
    endif

    if (GetPlayerSlotState(target) != PLAYER_SLOT_STATE_PLAYING) then
        call DisplayTimedTextToPlayer(sender, 0, 0, 5.0, "El jugador objetivo no está jugando.")
        set sender = null
        set target = null
        return
    endif

    if (GetPlayerController(target) == MAP_CONTROL_COMPUTER) then
        call DisplayTimedTextToPlayer(sender, 0, 0, 5.0, "No puedes transferir recursos a la IA.")
        set sender = null
        set target = null
        return
    endif

    if (not IsPlayerAlly(sender, target)) then
        call DisplayTimedTextToPlayer(sender, 0, 0, 5.0, "Solo puedes transferir recursos a tus aliados.")
        set sender = null
        set target = null
        return
    endif

    // 5. DETERMINAR CANTIDAD A TRANSFERIR
    set currentRes = GetPlayerState(sender, resType)

    if (StringCase(amountStr, false) == "todo") then
        set transferAmount = currentRes
    else
        set transferAmount = S2I(amountStr)
        if (transferAmount <= 0) then
            call DisplayTimedTextToPlayer(sender, 0, 0, 5.0, "Cantidad inválida: " + amountStr)
            set sender = null
            set target = null
            return
        endif
        // Si no tiene suficiente, transfiere todo lo que tiene (capado a su bolsillo).
        if (transferAmount > currentRes) then
            set transferAmount = currentRes
        endif
    endif

    if (transferAmount <= 0) then
        call DisplayTimedTextToPlayer(sender, 0, 0, 5.0, "No tienes " + resName + ". Transferencia cancelada.")
        set sender = null
        set target = null
        return
    endif

    set team = Eco_TeamIndex(sender) // sender y target son aliados => mismo equipo

    // 6. EJECUTAR TRANSFERENCIA
    if (isGold) then
        call Eco_MoveGold(sender, target, transferAmount) // estado + keys 701/702 + sonido al receptor
        // ¿El objetivo tiene una petición activa? -> el oro aporta al bote (sin tope; -oro envía literal).
        if (Eco_Req_Active[team] and Eco_Req_Requester[team] == GetPlayerId(target)) then
            call Eco_Req_RegisterContribution(team, sender, transferAmount)
        else
            call Eco_BroadcastTransfer(sender, target, transferAmount, "oro")
        endif
    else
        call SetPlayerState(sender, resType, currentRes - transferAmount)
        call SetPlayerState(target, resType, GetPlayerState(target, resType) + transferAmount)
        // Sonido de madera SOLO al receptor.
        call SetSoundVolume(Eco_Snd_Lumber, 0)
        if (GetLocalPlayer() == target) then
            call SetSoundVolume(Eco_Snd_Lumber, 127)
        endif
        call StartSound(Eco_Snd_Lumber)
        call Eco_BroadcastTransfer(sender, target, transferAmount, "madera")
    endif

    set sender = null
    set target = null
endfunction

//===========================================================================
// DETECCIÓN DE ORO POR F11 (sondeo de oro + emparejado de aliados reales)
//===========================================================================

// --- Contabilidad de un regalo F11 detectado. NO mueve oro: el motor YA lo movió
//     (esa es la diferencia con Eco_MoveGold). Alimenta el MISMO pool que los
//     comandos (701/702) → puntúa idéntico y el NETO anti-abuso es único.
//     Además, si el receptor tiene un bote -fondo activo, se comporta como
//     "-oro <pedidor>": aporta el monto literal al bote. ---
function Eco_F11_Account takes integer fromId, integer toId, integer amount returns nothing
    local integer team = Eco_TeamIndex(Player(fromId))
    // POOL ÚNICO (igual que Eco_MoveGold): enviado en 701, recibido en 702.
    call SaveInteger(udg_MB_Hash, fromId, 701, LoadInteger(udg_MB_Hash, fromId, 701) + amount)
    call SaveInteger(udg_MB_Hash, toId,   702, LoadInteger(udg_MB_Hash, toId,   702) + amount)
    // IGUAL QUE "-oro <pedidor>": si el receptor es el pedidor de un bote -fondo
    // ACTIVO de su equipo, el regalo F11 APORTA el monto LITERAL al bote (mismo
    // mensaje de aporte + posible cierre que un -oro; NO capado como -ok). El oro ya
    // lo movió el motor y 701/702 ya están escritos arriba; Eco_Req_RegisterContribution
    // NO mueve oro: solo actualiza progreso/panel y avisa. (Mismo guard que el -oro.)
    if (Eco_Req_Active[team] and Eco_Req_Requester[team] == toId) then
        call Eco_Req_RegisterContribution(team, Player(fromId), amount)
    endif
endfunction

// --- ¿Jugador REAL (humano jugando)? Los bots NUNCA transfieren oro por F11,
//     así que quedan fuera de la detección (menos CPU y cero falsos positivos). ---
function Eco_IsRealPlayer takes integer id returns boolean
    return GetPlayerSlotState(Player(id)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(id)) == MAP_CONTROL_USER
endfunction

// --- Filtro de F11: el monto es múltiplo de 100 (cada clic/ruedita suma 100),
//     O el emisor quedó casi en cero (caso "mando todo": el último incremento se
//     completa con el resto del bolsillo, dando un monto no redondo). Cualquier
//     otro −X/+X exacto es coincidencia (gasto que casa con una recompensa) y se
//     descarta. ---
function Eco_F11_AmountValid takes integer amount, integer senderGoldNow returns boolean
    if (amount <= 0) then
        return false
    endif
    if (amount - (amount / 100) * 100 == 0) then       // múltiplo de 100
        return true
    endif
    if (senderGoldNow < ECO_F11_ALLIN_MAXLEFT) then    // "mandó todo" (quedó casi sin oro)
        return true
    endif
    return false
endfunction

// --- Empareja dentro de UN equipo (slots lo..hi): por cada emisor real con
//     delta<0, busca un receptor real aliado con delta == +monto exacto. El par
//     exacto e igual-y-opuesto entre dos aliados es la firma del regalo F11; el
//     oro/seg (siempre positivo) jamás crea esa firma. ---
function Eco_PollProcessTeam takes integer lo, integer hi returns nothing
    local integer a = lo
    local integer b
    local integer sendAmt
    loop
        exitwhen a > hi
        if (Eco_IsRealPlayer(a) and Eco_PollDelta[a] < 0) then
            set sendAmt = -Eco_PollDelta[a]
            set b = lo
            loop
                exitwhen b > hi
                if (b != a and not Eco_PollUsed[b] and Eco_IsRealPlayer(b) and Eco_PollDelta[b] == sendAmt) then
                    if (Eco_F11_AmountValid(sendAmt, Eco_PollGoldNow[a])) then
                        call Eco_F11_Account(a, b, sendAmt)
                        set Eco_PollUsed[b] = true
                    endif
                    exitwhen true   // a ya está resuelto (casó o se descartó); no buscar otro receptor
                endif
                set b = b + 1
            endloop
        endif
        set a = a + 1
    endloop
endfunction

// --- Tick del sondeo (cada ECO_POLL_TICK): foto del oro, delta vs base,
//     emparejado por equipo, y refresco de la base. ---
function Eco_PollTick takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i > 9
        set Eco_PollGoldNow[i] = GetPlayerState(Player(i), PLAYER_STATE_RESOURCE_GOLD)
        set Eco_PollDelta[i]   = Eco_PollGoldNow[i] - Eco_GoldBaseline[i]
        set Eco_PollUsed[i]    = false
        set i = i + 1
    endloop
    if (Eco_PollSeeded) then
        call Eco_PollProcessTeam(0, 4)   // Humanos
        call Eco_PollProcessTeam(5, 9)   // Orcos
    endif
    set i = 0
    loop
        exitwhen i > 9
        set Eco_GoldBaseline[i] = Eco_PollGoldNow[i]
        set i = i + 1
    endloop
    set Eco_PollSeeded = true
endfunction

// --- Sync de baseline al COMPRAR en una tienda (SELL_ITEM = un ítem vendido).
//     El comprador gastó el costo del ítem; restarlo de la base lo vuelve invisible
//     al sondeo, así un regalo F11 que el comprador reciba en el MISMO tick que
//     compra NO se pierde (su delta queda en el +X limpio). El costo sale de la DB
//     central IADataItems_GetGoldCost.
//     EXCLUIDO a propósito: el Sello de Fortificación ('gfor') NO está en la DB
//     (GetGoldCost devuelve 0 → este hook no hace nada); su oro lo sincroniza
//     Sistema_Sello_Fortificacion.j (costo + reembolso). Si algún ítem comprable
//     no está en la DB, GetGoldCost=0 y ese gasto cae al comportamiento previo
//     (raro, dirección segura). ---
function Eco_OnItemBought takes nothing returns nothing
    local integer buyerId = GetPlayerId(GetOwningPlayer(GetBuyingUnit()))
    local integer cost = IADataItems_GetGoldCost(GetItemTypeId(GetSoldItem()))
    if (cost > 0 and buyerId >= 0 and buyerId <= 9) then
        set Eco_GoldBaseline[buyerId] = Eco_GoldBaseline[buyerId] - cost
    endif
endfunction

// --- Sync de baseline al VENDER/empeñar un ítem en la tienda (PAWN_ITEM): el
//     vendedor GANA la mitad del costo (reembolso a mitad de precio). Avanzar la
//     base por ese +costo/2 lo vuelve invisible al sondeo, así una venta que caiga
//     en el mismo tick que un regalo F11 recibido no descuadra el par. En PAWN el
//     que pawnea (y recibe el oro) es GetSellingUnit(); el ítem, GetSoldItem().
//     Degradación segura: si la DB no tiene el ítem (costo 0) → no hace nada. ---
function Eco_OnItemPawned takes nothing returns nothing
    local integer sellerId = GetPlayerId(GetOwningPlayer(GetSellingUnit()))
    local integer refund = IADataItems_GetGoldCost(GetItemTypeId(GetSoldItem())) / 2
    if (refund > 0 and sellerId >= 0 and sellerId <= 9) then
        set Eco_GoldBaseline[sellerId] = Eco_GoldBaseline[sellerId] + refund
    endif
endfunction

//===========================================================================
function InitTrig_Comandos_Economia takes nothing returns nothing
    local integer i = 0
    local trigger t = CreateTrigger()
    local trigger bareOk = CreateTrigger()

    // Crear sonidos globales persistentes (patrón tabla.j: nunca se destruyen)
    set Eco_Snd_Gold = CreateSound("Abilities\\Spells\\Items\\ResourceItems\\ReceiveGold.wav", false, false, false, 10, 10, "")
    call SetSoundVolume(Eco_Snd_Gold, 127)

    set Eco_Snd_Lumber = CreateSound("Abilities\\Spells\\Items\\ResourceItems\\BundleOfLumber.wav", false, false, false, 10, 10, "")
    call SetSoundVolume(Eco_Snd_Lumber, 127)

    loop
        exitwhen i > 9
        if (GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(i)) == MAP_CONTROL_USER) then
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-oro ", false)
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-madera ", false)
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-fondo ", false) // petición de oro
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-f ", false)     // alias corto de -fondo
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-ok", true)      // comando historico (coincidencia exacta)
            // Listener contextual: recibe cualquier chat, pero su accion solo acepta
            // un "ok" completo mientras Eco_Req_Active siga encendido para el equipo.
            call TriggerRegisterPlayerChatEvent(bareOk, Player(i), "", false)
        endif
        set i = i + 1
    endloop

    call TriggerAddAction(t, function Trig_Comandos_Economia_Actions)
    call TriggerAddAction(bareOk, function Eco_HandleBareOkChat)

    // Sembrar la línea base del poller F11 con el oro inicial y arrancar el
    // sondeo periódico. (El primer tick refresca la base de todos modos, así que
    // un oro inicial aún sin asignar solo daría un blip positivo inofensivo.)
    set i = 0
    loop
        exitwhen i > 9
        set Eco_GoldBaseline[i] = GetPlayerState(Player(i), PLAYER_STATE_RESOURCE_GOLD)
        set i = i + 1
    endloop
    set Eco_PollSeeded = true
    set Eco_PollTimer = CreateTimer()
    call TimerStart(Eco_PollTimer, ECO_POLL_TICK, true, function Eco_PollTick)

    // Hook de COMPRAS: sincroniza la base con el gasto del comprador (ver
    // Eco_OnItemBought). Trigger propio (no mezclar con los chat events).
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SELL_ITEM)
    call TriggerAddAction(t, function Eco_OnItemBought)

    // Hook de VENTA/EMPEÑO: sincroniza la base con el reembolso del vendedor.
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_PAWN_ITEM)
    call TriggerAddAction(t, function Eco_OnItemPawned)

    set t = null
    set bareOk = null
endfunction
