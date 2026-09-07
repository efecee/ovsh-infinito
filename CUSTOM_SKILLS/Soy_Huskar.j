//===========================================================================
// SOY HUSKAR - COLOR DE LA FORMA ALTERNATIVA
//---------------------------------------------------------------------------
// La habilidad A05Q transforma al Troll Berserker N020 en N021. El morfeo
// conserva el mismo handle de unidad, pero GetUnitTypeId refleja la forma que
// se ve en ese instante. Esto tambien permite reconocer los morfeos externos:
// durante Hex el tipo deja de ser N021 y, al terminar Hex, vuelve a N021 o a
// N020 segun la transformacion siga activa o ya haya terminado.
//
// Por eso el color no depende de la duracion configurada en el Editor de
// Objetos. Un timer corto observa el tipo real y aplica una unica regla:
//
//     tipo N021 -> rojo
//     otro tipo -> color normal
//
// Cuando reaparece N020 despues de haber visto N021, la transformacion termino
// de verdad. Se confirma durante dos ticks y se restaura su propiedad de
// animacion "alternate": Chemical Rage puede dejar activa la apariencia del
// Troll Headhunter aunque el unit-type ya sea N020. El limite de espera solo
// evita dejar un timer vivo si el lanzamiento fuera cancelado antes de llegar
// a N021; no decide cuanto dura el color.
//===========================================================================

scope FuriaHuskar initializer Init

    globals
        private constant integer ABILITY_ID         = 'A05Q'
        private constant integer BASE_UNIT_ID       = 'N020'
        private constant integer TRANSFORMED_UNIT_ID = 'N021'

        private constant real    UPDATE_PERIOD      = 0.03
        private constant integer MAX_START_TICKS    = 400 // 12 s de salvaguarda
        private constant integer BASE_CONFIRM_TICKS = 2   // 0.06 s; estabiliza el fin del morfeo

        private constant integer TIMER_UNIT_KEY     = 0
        private constant integer TIMER_SEEN_KEY     = 1
        private constant integer TIMER_WAIT_KEY     = 2
        private constant integer TIMER_BASE_KEY     = 3
        private constant integer UNIT_TIMER_KEY     = 0

        private hashtable State = InitHashtable()
    endglobals

    private function SetRed takes unit u returns nothing
        call SetUnitVertexColor(u, 200, 20, 20, 255)
    endfunction

    private function SetNormal takes unit u returns nothing
        call SetUnitVertexColor(u, 255, 255, 255, 255)
    endfunction

    // Destruye solo la instancia que sigue siendo la vigente para esta unidad.
    // Asi un lanzamiento nuevo no puede ser apagado por el timer anterior.
    private function StopTracking takes timer t, unit u, boolean resetColor returns nothing
        local integer timerId = GetHandleId(t)
        local integer unitId

        if u != null then
            set unitId = GetHandleId(u)

            if resetColor then
                call SetNormal(u)
            endif

            if LoadInteger(State, unitId, UNIT_TIMER_KEY) == timerId then
                call RemoveSavedInteger(State, unitId, UNIT_TIMER_KEY)
            endif
        endif

        call FlushChildHashtable(State, timerId)
        call PauseTimer(t)
        call DestroyTimer(t)
    endfunction

    private function UpdateColor takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local integer timerId = GetHandleId(t)
        local unit caster = LoadUnitHandle(State, timerId, TIMER_UNIT_KEY)
        local integer unitId
        local integer currentType
        local integer waited
        local integer baseTicks

        if caster == null then
            call StopTracking(t, caster, false)
            set t = null
            return
        endif

        set unitId = GetHandleId(caster)

        // Hay un lanzamiento posterior siguiendo el mismo heroe.
        if LoadInteger(State, unitId, UNIT_TIMER_KEY) != timerId then
            call StopTracking(t, caster, false)
            set caster = null
            set t = null
            return
        endif

        // Una unidad removida ya no admite ningun cambio visual.
        if GetUnitTypeId(caster) == 0 then
            call StopTracking(t, caster, false)
            set caster = null
            set t = null
            return
        endif

        // La muerte termina el efecto y evita que el tinte alcance al cadaver
        // o a una resurreccion posterior.
        if GetWidgetLife(caster) <= 0.405 then
            call StopTracking(t, caster, true)
            set caster = null
            set t = null
            return
        endif

        set currentType = GetUnitTypeId(caster)

        if currentType == TRANSFORMED_UNIT_ID then
            // Se reaplica en cada tick porque algunos efectos reconstruyen el
            // modelo sin cambiar el handle de la unidad.
            call SetRed(caster)
            call SaveBoolean(State, timerId, TIMER_SEEN_KEY, true)

            if LoadInteger(State, timerId, TIMER_BASE_KEY) != 0 then
                call RemoveSavedInteger(State, timerId, TIMER_BASE_KEY)
            endif

        else
            // Incluye N020, Hex y cualquier otro morfeo temporal.
            call SetNormal(caster)

            if LoadBoolean(State, timerId, TIMER_SEEN_KEY) then
                // Solo N020 demuestra que Soy Huskar ya termino. Un animal de
                // Hex se conserva en seguimiento porque aun puede volver a N021.
                if currentType == BASE_UNIT_ID then
                    // Chemical Rage puede retirar o dejar obsoleta la propiedad
                    // "alternate" al desmontar el morfeo. Se repone desde el
                    // primer tick de N020 y se reinicia la animacion solamente
                    // cuando N020 permanece estable durante un segundo tick.
                    call AddUnitAnimationProperties(caster, "alternate", true)
                    set baseTicks = LoadInteger(State, timerId, TIMER_BASE_KEY) + 1

                    if baseTicks >= BASE_CONFIRM_TICKS then
                        call ResetUnitAnimation(caster)
                        call StopTracking(t, caster, false)
                        set caster = null
                        set t = null
                        return
                    endif

                    call SaveInteger(State, timerId, TIMER_BASE_KEY, baseTicks)

                elseif LoadInteger(State, timerId, TIMER_BASE_KEY) != 0 then
                    // Si un morfeo externo interrumpe la confirmacion, se vuelve
                    // a exigir dos ticks consecutivos cuando reaparezca N020.
                    call RemoveSavedInteger(State, timerId, TIMER_BASE_KEY)
                endif
            else
                // Salvaguarda para un lanzamiento que nunca llego a morfear.
                set waited = LoadInteger(State, timerId, TIMER_WAIT_KEY) + 1
                call SaveInteger(State, timerId, TIMER_WAIT_KEY, waited)

                if waited >= MAX_START_TICKS then
                    call StopTracking(t, caster, false)
                    set caster = null
                    set t = null
                    return
                endif
            endif
        endif

        set caster = null
        set t = null
    endfunction

    private function Actions takes nothing returns nothing
        local unit caster = GetTriggerUnit()
        local timer t = CreateTimer()
        local integer timerId = GetHandleId(t)

        call SaveUnitHandle(State, timerId, TIMER_UNIT_KEY, caster)
        call SaveInteger(State, GetHandleId(caster), UNIT_TIMER_KEY, timerId)
        call TimerStart(t, UPDATE_PERIOD, true, function UpdateColor)

        set caster = null
        set t = null
    endfunction

    private function Conditions takes nothing returns boolean
        return GetSpellAbilityId() == ABILITY_ID
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()

        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        call TriggerAddCondition(t, Condition(function Conditions))
        call TriggerAddAction(t, function Actions)

        set t = null
    endfunction

endscope
