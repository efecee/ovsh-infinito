//===========================================================================
// SED DE SANGRE - TRANSICION VISUAL DE LA METAMORFOSIS
//---------------------------------------------------------------------------
// La habilidad A00I transforma a Grom Ogrh en su forma poseida Opgh. Ambos
// tipos usan modelos distintos y esos modelos no contienen una pareja de
// animaciones Morph compatible como la Metamorfosis original de Illidan.
// Por eso la habilidad funciona, pero el cambio de modelo se ve brusco.
//
// Este detonador crea una transicion visual alrededor del cambio real:
//
//   lanzamiento A00I -> animacion "spell" + velo rojo
//   aparece Opgh     -> estallido de sangre + grito de Grom en radio 1500
//   reaparece Ogrh   -> regreso limpio, sin agregar otro efecto
//
// No cuenta los 60 segundos de la habilidad. Un timer observa el UnitTypeId
// del mismo heroe y solo termina cuando Opgh ya fue visto y Ogrh reaparece.
// Si Hex u otro morfeo muestra un tercer tipo, se conserva el seguimiento
// hasta que vuelva Opgh u Ogrh. MAX_START_TICKS es solo una salvaguarda para
// un lanzamiento que nunca alcance a transformarse.
//===========================================================================

scope SedDeSangreVisual initializer Init

    globals
        private constant integer ABILITY_ID          = 'A00I'
        private constant integer BASE_UNIT_ID        = 'Ogrh'
        private constant integer TRANSFORMED_UNIT_ID = 'Opgh'

        private constant real    UPDATE_PERIOD        = 0.03
        private constant real    SOUND_HEARING_RADIUS = 1500.00
        private constant integer MAX_START_TICKS      = 400 // 12 s de salvaguarda

        private constant integer TIMER_UNIT_KEY      = 0
        private constant integer TIMER_VEIL_KEY      = 1
        private constant integer TIMER_SEEN_KEY      = 2
        private constant integer TIMER_WAIT_KEY      = 3
        private constant integer UNIT_TIMER_KEY      = 0

        private hashtable State = InitHashtable()

        // Sonido persistente: se crea una sola vez en Init y nunca se destruye,
        // igual que los sonidos de EXTRAS/Sistema_Kills.j.
        private sound GromTransformationCry = null
    endglobals

    // Cambia estas funciones si prefieres otra animacion u otros efectos.
    private function GetTransitionAnimation takes nothing returns string
        return "spell"
    endfunction

    private function GetVeilEffect takes nothing returns string
        return "Abilities\\Spells\\Orc\\Bloodlust\\BloodlustTarget.mdl"
    endfunction

    private function GetBloodEffect takes nothing returns string
        return "Objects\\Spawnmodels\\Human\\HumanBlood\\HumanBloodLarge0.mdl"
    endfunction

    private function GetVeilAttachment takes nothing returns string
        return "origin"
    endfunction

    private function PlayBloodEffect takes unit u returns nothing
        call DestroyEffect(AddSpecialEffectTarget(GetBloodEffect(), u, "chest"))
    endfunction

    private function PlayTransformationCry takes unit u returns nothing
        local real dx = GetCameraTargetPositionX() - GetUnitX(u)
        local real dy = GetCameraTargetPositionY() - GetUnitY(u)

        // El handle ya existe desde Init. Reutilizarlo evita que la primera
        // transformacion dependa de crear y cargar el sonido en ese instante.
        // Cada cliente compara el centro horizontal de su camara con Grom.
        // Solo se modifica audio local: no interviene ningun estado sincronizado.
        call SetSoundVolume(GromTransformationCry, 0)
        if dx * dx + dy * dy <= SOUND_HEARING_RADIUS * SOUND_HEARING_RADIUS then
            call SetSoundVolume(GromTransformationCry, 127)
        endif
        call StartSound(GromTransformationCry)
    endfunction

    private function DestroyVeil takes integer timerId returns nothing
        local effect veil = LoadEffectHandle(State, timerId, TIMER_VEIL_KEY)

        if veil != null then
            call DestroyEffect(veil)
            call RemoveSavedHandle(State, timerId, TIMER_VEIL_KEY)
        endif

        set veil = null
    endfunction

    // Destruye solo la instancia que sigue siendo la vigente para esta unidad.
    // Asi un lanzamiento posterior no puede ser apagado por el timer anterior.
    private function StopTracking takes timer t, unit caster, boolean resetAnimation returns nothing
        local integer timerId = GetHandleId(t)
        local integer unitId

        call DestroyVeil(timerId)

        if caster != null then
            set unitId = GetHandleId(caster)

            if resetAnimation and GetUnitTypeId(caster) != 0 then
                call ResetUnitAnimation(caster)
            endif

            if LoadInteger(State, unitId, UNIT_TIMER_KEY) == timerId then
                call RemoveSavedInteger(State, unitId, UNIT_TIMER_KEY)
            endif
        endif

        call FlushChildHashtable(State, timerId)
        call PauseTimer(t)
        call DestroyTimer(t)
    endfunction

    private function UpdateTransition takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local integer timerId = GetHandleId(t)
        local unit caster = LoadUnitHandle(State, timerId, TIMER_UNIT_KEY)
        local integer unitId
        local integer currentType
        local integer waited
        local boolean transformedSeen

        if caster == null then
            call StopTracking(t, caster, false)
            set t = null
            return
        endif

        set unitId = GetHandleId(caster)

        // Hay un lanzamiento posterior siguiendo al mismo heroe.
        if LoadInteger(State, unitId, UNIT_TIMER_KEY) != timerId then
            call StopTracking(t, caster, false)
            set caster = null
            set t = null
            return
        endif

        // Una unidad removida o muerta ya no necesita la transicion.
        if GetUnitTypeId(caster) == 0 or GetWidgetLife(caster) <= 0.405 then
            call StopTracking(t, caster, false)
            set caster = null
            set t = null
            return
        endif

        set currentType = GetUnitTypeId(caster)
        set transformedSeen = LoadBoolean(State, timerId, TIMER_SEEN_KEY)

        if currentType == TRANSFORMED_UNIT_ID then
            if not transformedSeen then
                // El cambio de modelo ya ocurrio: termina el velo inferior y
                // la forma roja aparece con el estallido elegido.
                call DestroyVeil(timerId)
                call PlayBloodEffect(caster)
                call PlayTransformationCry(caster)
                call ResetUnitAnimation(caster)
                call SaveBoolean(State, timerId, TIMER_SEEN_KEY, true)
            endif

        elseif transformedSeen and currentType == BASE_UNIT_ID then
            // El regreso real ya ocurrio. No se agrega otro golpe ni se fuerza
            // "spell": el propio morfeo conserva una salida minima y natural.
            call ResetUnitAnimation(caster)
            call StopTracking(t, caster, false)

            set caster = null
            set t = null
            return

        elseif not transformedSeen then
            // Ogrh, Hex u otro tipo temporal antes de que aparezca Opgh.
            set waited = LoadInteger(State, timerId, TIMER_WAIT_KEY) + 1
            call SaveInteger(State, timerId, TIMER_WAIT_KEY, waited)

            if waited >= MAX_START_TICKS then
                call StopTracking(t, caster, true)
                set caster = null
                set t = null
                return
            endif
        endif

        set caster = null
        set t = null
    endfunction

    private function Actions takes nothing returns nothing
        local unit caster = GetTriggerUnit()
        local timer t = CreateTimer()
        local integer timerId = GetHandleId(t)
        local effect veil

        // Da movimiento al lanzamiento mientras el efecto rojo cubre el
        // intervalo configurado por Metamorfosis antes de reemplazar el modelo.
        call SetUnitAnimation(caster, GetTransitionAnimation())
        call QueueUnitAnimation(caster, "stand")
        set veil = AddSpecialEffectTarget(GetVeilEffect(), caster, GetVeilAttachment())

        call SaveUnitHandle(State, timerId, TIMER_UNIT_KEY, caster)
        call SaveEffectHandle(State, timerId, TIMER_VEIL_KEY, veil)
        call SaveInteger(State, GetHandleId(caster), UNIT_TIMER_KEY, timerId)
        call TimerStart(t, UPDATE_PERIOD, true, function UpdateTransition)

        set veil = null
        set caster = null
        set t = null
    endfunction

    private function Conditions takes nothing returns boolean
        local unit caster = GetTriggerUnit()
        local boolean accepted = GetSpellAbilityId() == ABILITY_ID and GetUnitTypeId(caster) == BASE_UNIT_ID and LoadInteger(State, GetHandleId(caster), UNIT_TIMER_KEY) == 0

        // Metamorfosis vuelve a emitir un evento al desmontar Opgh. Exigir la
        // forma base sin otro seguimiento activo descarta ese falso inicio.
        set caster = null
        return accepted
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()

        // Sonido global persistente, siguiendo el patron de Sistema_Kills.j.
        set GromTransformationCry = CreateSound("Units\\Orc\\Hellscream\\GromYesAttack1.wav", false, false, false, 10, 10, "")
        call SetSoundVolume(GromTransformationCry, 127)
        call SetSoundPitch(GromTransformationCry, 1.00)

        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        call TriggerAddCondition(t, Condition(function Conditions))
        call TriggerAddAction(t, function Actions)

        set t = null
    endfunction

endscope
