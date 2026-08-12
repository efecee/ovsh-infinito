
// SISTEMA DE ZOOM PROFESIONAL "ORC VS HUMAN" (10 JUGADORES + AVISO)
//
// COMANDOS:
//   -z1 / -z2 / -z3     Presets   (1650 / 2200 / 2750)
//   -z [numero]         Zoom libre, con espacio: "-z 1800", "-z 2500" (1650-2750)
//   -z+ / -z-           Ajuste fino incremental (+100 / -100)
//
// Cualquier valor fuera de rango se clampea al limite mas cercano.
// Cada cambio muestra feedback privado (barra visual) solo al jugador que escribe.

globals
    constant real ZOOM_MIN     = 1650.0  // vista cerrada (defecto WC3)
    constant real ZOOM_MAX     = 2750.0  // vista global
    constant real ZOOM_STEP    = 100.0   // paso incremental -z+ / -z-
    constant real ZOOM_DEFAULT = 1650.0  // zoom inicial por jugador
    real array ZoomActual                // zoom actual por jugador (indice = slot 0..9)
endglobals

// --- HELPER: clampea un valor de zoom al rango seguro ---
function Zoom_Clamp takes real v returns real
    if ( v < ZOOM_MIN ) then
        return ZOOM_MIN
    elseif ( v > ZOOM_MAX ) then
        return ZOOM_MAX
    endif
    return v
endfunction

// --- HELPER: nombre del preset si la distancia coincide, si no "" ---
function Zoom_PresetName takes real dist returns string
    if ( dist >= 1649.5 and dist <= 1650.5 ) then
        return "  (Defecto)"
    elseif ( dist >= 2199.5 and dist <= 2200.5 ) then
        return "  (Clasico)"
    elseif ( dist >= 2749.5 and dist <= 2750.5 ) then
        return "  (Global)"
    endif
    return ""
endfunction

// --- HELPER: barra visual tipo "slider" con ASCII puro (compatible 1.27b) ---
//   Min  [O----------]   Medio [=====O-----]   Max [==========O]
//   La 'O' es la perilla: marca donde esta el zoom dentro del rango min-max.
//   '=' es recorrido hecho (mas cerca), '-' es recorrido restante (mas lejos).
function Zoom_BuildBar takes real dist returns string
    local integer total= 11                                  // celdas internas del slider
    local integer knob = R2I((dist - ZOOM_MIN) / (ZOOM_MAX - ZOOM_MIN) * (total - 1) + 0.5)
    local integer i= 0
    local string bar= "["
    if ( knob < 0 ) then
        set knob=0
    elseif ( knob > total - 1 ) then
        set knob=total - 1
    endif
    loop
        exitwhen i >= total
        if ( i < knob ) then
            set bar=bar + "="      // tramo recorrido
        elseif ( i == knob ) then
            set bar=bar + "O"      // perilla (posicion actual)
        else
            set bar=bar + "-"      // tramo restante
        endif
        set i=i + 1
    endloop
    return bar + "]"
endfunction

// --- FUNCIÓN 1: EL MENSAJE AUTOMÁTICO ---
function Trig_Zoom_Message takes nothing returns nothing
    // Usamos códigos de color: |cff(Hex)Texto|r
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 12.00, "Nuevos |cffFFCC00comandos|r y modificaciones |cffFFCC00añadidos|r.\nPresiona |cffFFCC00F9|r.")
    call StartSound(bj_questUpdatedSound)
    call StartSound(CreateSound("Sound\\Interface\\QuestActivateWhat1.wav", false, false, false, 10, 10, ""))

    // LIMPIEZA DE MEMORIA:
    // Destruimos este detonador temporal porque ya cumplió su función (sonar a los 75s).
    // Así no ocupa memoria el resto de la partida.
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

// --- FUNCIÓN 2: LA ACCIÓN DE ZOOM ---
function Trig_Zoom_Actions takes nothing returns nothing
    local string chat= StringCase(GetEventPlayerChatString(), false)
    local player p= GetTriggerPlayer()
    local integer id= GetPlayerId(p)
    local integer len= StringLength(chat)
    local string rest
    local real distancia= -1.0

    // El registro es por prefijo "-z"; descartamos lo demasiado corto.
    if ( len < 2 ) then
        set p=null
        return
    endif

    // Sufijo despues de "-z": para presets/incrementales es "1".."+".."-",
    // para zoom libre llega con espacio inicial (ej: " 1800").
    set rest= SubString(chat, 2, len)

    if ( rest == "+" ) then
        // Incremental: alejar
        set distancia= Zoom_Clamp(ZoomActual[id] + ZOOM_STEP)
    elseif ( rest == "-" ) then
        // Incremental: acercar
        set distancia= Zoom_Clamp(ZoomActual[id] - ZOOM_STEP)
    elseif ( rest == "1" ) then
        set distancia= 1650.0 // Defecto
    elseif ( rest == "2" ) then
        set distancia= 2200.0 // Clásico
    elseif ( rest == "3" ) then
        set distancia= 2750.0 // Global
    else
        // Zoom libre: "-z 1800". Quitamos espacios iniciales y parseamos.
        loop
            exitwhen StringLength(rest) == 0 or SubString(rest, 0, 1) != " "
            set rest= SubString(rest, 1, StringLength(rest))
        endloop
        if ( StringLength(rest) > 0 and S2R(rest) > 0.0 ) then
            set distancia= Zoom_Clamp(S2R(rest))
        endif
    endif

    // APLICACIÓN SEGURA + MEMORIA + FEEDBACK
    if ( distancia > 0.0 ) then
        set ZoomActual[id]= distancia
        if ( GetLocalPlayer() == p ) then
            call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, distancia, 0.20)
        endif
        // Feedback privado (solo aparece en la pantalla del jugador p; no desincroniza).
        call DisplayTimedTextToPlayer(p, 0, 0, 3.00, "|cffFFCC00Zoom:|r " + I2S(R2I(distancia)) + "  " + Zoom_BuildBar(distancia) + Zoom_PresetName(distancia))
    endif

    set p=null
endfunction

//===========================================================================
// FUNCIÓN DE INICIALIZACIÓN (EL CEREBRO)
//===========================================================================
function InitTrig_Zoom takes nothing returns nothing
    local integer i= 0
    // Variable temporal para el detonador del mensaje
    local trigger t_msg= CreateTrigger()

    // 0. MEMORIA DE ZOOM: arrancamos a todos en el zoom por defecto.
    loop
        exitwhen i > 9
        set ZoomActual[i]= ZOOM_DEFAULT
        set i=i + 1
    endloop

    // 1. CONFIGURAR EL SISTEMA DE ZOOM (PRINCIPAL)
    set gg_trg_Zoom=CreateTrigger()

    // Un solo registro por jugador con prefijo (exact=false) captura TODO lo que
    // empiece con "-z": presets, zoom libre e incrementales. OJO: el match de chat
    // es CASE-INSENSITIVE, asi que "-z" tambien atrapa "-Z...". Registrar ademas
    // "-Z" dispararia la accion DOS veces (mensaje y zoom duplicados, y el
    // incremental -z+/-z- saltaria el doble). Por eso registramos solo "-z".
    set i=0
    loop
        exitwhen i > 9 // Solo slots 0 al 9 (Jugadores reales)
        call TriggerRegisterPlayerChatEvent(gg_trg_Zoom, Player(i), "-z", false)
        set i=i + 1
    endloop
    call TriggerAddAction(gg_trg_Zoom, function Trig_Zoom_Actions)

    // 2. CONFIGURAR EL AVISO (TEMPORIZADOR)
    // Esto crea un evento que se dispara a los 75.00 segundos exactos de juego.
    call TriggerRegisterTimerEvent(t_msg, 75.00, false)
    call TriggerAddAction(t_msg, function Trig_Zoom_Message)

    // Limpieza de la variable local "t_msg" (No destruye el detonador, solo la referencia)
    set t_msg=null
endfunction
