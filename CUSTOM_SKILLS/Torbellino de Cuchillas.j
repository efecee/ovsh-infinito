scope VisualBladestorm initializer Init

    //===========================================================================
    // SISTEMA: INDICADOR VISUAL DE ÁREA - TORBELLINO DE CUCHILLAS (BLADESTORM)
    // ID de Habilidad: AOww
    //===========================================================================
    //
    // DESCRIPCIÓN:
    //   Crea un ANILLO DE RELÁMPAGOS alrededor del héroe durante el
    //   Torbellino de Cuchillas. El anillo muestra al jugador EXACTAMENTE
    //   el perímetro del área de efecto donde se aplica el daño por segundo.
    //   El anillo sigue al héroe mientras se mueve y desaparece cuando
    //   la duración termina o el héroe muere.
    //
    // TÉCNICA:
    //   Se crea un polígono de N lados usando líneas de relámpago (Lightning).
    //   Más lados = círculo más suave. 24 lados es un buen equilibrio.
    //   El tipo de relámpago define el aspecto visual (eléctrico, sutil, etc.)
    //
    // NOTA: La unidad dummy h010 ya NO se usa. Este sistema usa Lightning puro.
    //
    //===========================================================================

    // --- ALMACENAMIENTO DE RELÁMPAGOS (interno, no tocar) ---
    globals
        private lightning array stormRing   // Segmentos del anillo
        private boolean stormActive = false // ¿Hay un anillo activo?
        private integer stormSegCount = 0   // Segmentos activos
    endglobals

    // ==========================================
    // ===        IDs DE REFERENCIA           ===
    // ==========================================

    function Bladestorm_GetAbilityId takes nothing returns integer
        return 'AOww' // Habilidad Torbellino de Cuchillas
    endfunction

    // ==========================================
    // ===    CONFIGURACIÓN PERSONALIZABLE    ===
    // === (Modifica estos valores a tu gusto) ==
    // ==========================================

    // --- TIPO DE RELÁMPAGO (visual del anillo) ---
    // Cambia este valor para probar diferentes estilos de anillo.
    // Opciones disponibles:
    //   "SPLK" = Spirit Link      (fino, azul/púrpura, sutil y elegante)
    //   "CLPB" = Chain Lightning   (eléctrico azul, más visible)
    //   "HWPB" = Healing Wave     (verde brillante)
    //   "DRAM" = Drain Mana       (azul drenaje, discreto)
    //   "FORK" = Forked Lightning  (bifurcación eléctrica, dramático)
    //   "LEAS" = Leash            (muy fino, casi invisible)
    //   "AFOD" = Finger of Death  (oscuro, dramático)
    function Bladestorm_GetLightningType takes nothing returns string
        return "LEAS"
    endfunction

    // --- NÚMERO DE SEGMENTOS DEL ANILLO ---
    // Cuántos lados tiene el polígono que forma el círculo.
    // Más lados = círculo más suave pero más costoso.
    //   12 = dodecágono (rápido, se notan los lados)
    //   24 = casi circular (recomendado)
    //   32 = muy suave (más pesado)
    function Bladestorm_GetNumSegments takes nothing returns integer
        return 18
    endfunction

    // --- ÁREA DE EFECTO POR NIVEL (control manual, 6 niveles) ---
    // El radio del área de daño del Torbellino. DEBE coincidir con lo que
    // tienes configurado en el Editor de Objetos para la habilidad AOww.
    function Bladestorm_GetAoE takes integer level returns real
        if (level == 1) then
            return 200.0
        elseif (level == 2) then
            return 250.0
        elseif (level == 3) then
            return 300.0
        elseif (level == 4) then
            return 350.0
        elseif (level == 5) then
            return 400.0
        elseif (level == 6) then
            return 500.0
        endif
        return 500.0
    endfunction

    // --- DURACIÓN POR NIVEL (control manual, 6 niveles) ---
    // Cuántos segundos dura el Torbellino. DEBE coincidir con la duración
    // configurada en el Editor de Objetos para la habilidad AOww.
    function Bladestorm_GetDuration takes integer level returns real
        if (level == 1) then
            return 7.0
        elseif (level == 2) then
            return 7.0
        elseif (level == 3) then
            return 7.0
        elseif (level == 4) then
            return 7.0
        elseif (level == 5) then
            return 7.0
        elseif (level == 6) then
            return 7.0
        endif
        return 7.0
    endfunction


    // ==========================================
    // ===   MOTOR DE RASTREO (cada 0.03s)    ===
    // ==========================================
    // Mueve el anillo de relámpagos para que siga al héroe.
    // Si el héroe muere o el tiempo expira, destruye el anillo.
    private function Periodic takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local integer tId = GetHandleId(t)
        local unit caster = LoadUnitHandle(udg_MB_Hash, tId, 0)
        local real remaining = LoadReal(udg_MB_Hash, tId, 1)
        local real radius = LoadReal(udg_MB_Hash, tId, 2)
        local integer numSeg = LoadInteger(udg_MB_Hash, tId, 3)
        local real cx = GetUnitX(caster)
        local real cy = GetUnitY(caster)
        local real step = 2.0 * bj_PI / I2R(numSeg)
        local real a1
        local real a2
        local integer i

        // Descontar tiempo
        set remaining = remaining - 0.03

        if (remaining <= 0.0) or (GetWidgetLife(caster) <= 0.405) then
            // --- LIMPIEZA: destruir todos los segmentos ---
            set i = 0
            loop
                exitwhen i >= numSeg
                call DestroyLightning(stormRing[i])
                set stormRing[i] = null
                set i = i + 1
            endloop
            set stormActive = false
            set stormSegCount = 0
            call FlushChildHashtable(udg_MB_Hash, tId)
            call DestroyTimer(t)
        else
            // --- RASTREO: mover cada segmento a la nueva posición ---
            set i = 0
            loop
                exitwhen i >= numSeg
                set a1 = I2R(i) * step
                set a2 = I2R(i + 1) * step
                call MoveLightning(stormRing[i], true, /*
                */ cx + radius * Cos(a1), cy + radius * Sin(a1), /*
                */ cx + radius * Cos(a2), cy + radius * Sin(a2))
                set i = i + 1
            endloop
            call SaveReal(udg_MB_Hash, tId, 1, remaining)
        endif

        set t = null
        set caster = null
    endfunction


    // ==========================================
    // ===   DETONADOR PRINCIPAL (CAST)       ===
    // ==========================================
    private function OnCast takes nothing returns nothing
        local unit caster = GetTriggerUnit()
        local integer level = GetUnitAbilityLevel(caster, Bladestorm_GetAbilityId())
        local real aoe = Bladestorm_GetAoE(level)
        local integer numSeg = Bladestorm_GetNumSegments()
        local string ltype = Bladestorm_GetLightningType()
        local real cx = GetUnitX(caster)
        local real cy = GetUnitY(caster)
        local real step = 2.0 * bj_PI / I2R(numSeg)
        local real a1
        local real a2
        local timer t
        local integer tId
        local integer i

        // Si ya hay un anillo activo (edge case), limpiarlo primero
        if stormActive then
            set i = 0
            loop
                exitwhen i >= stormSegCount
                call DestroyLightning(stormRing[i])
                set stormRing[i] = null
                set i = i + 1
            endloop
        endif

        // 1. Crear el anillo de relámpagos (polígono de N lados)
        set i = 0
        loop
            exitwhen i >= numSeg
            set a1 = I2R(i) * step
            set a2 = I2R(i + 1) * step
            set stormRing[i] = AddLightning(ltype, true, /*
            */ cx + aoe * Cos(a1), cy + aoe * Sin(a1), /*
            */ cx + aoe * Cos(a2), cy + aoe * Sin(a2))
            set i = i + 1
        endloop
        set stormActive = true
        set stormSegCount = numSeg

        // 2. Crear timer de rastreo
        set t = CreateTimer()
        set tId = GetHandleId(t)
        call SaveUnitHandle(udg_MB_Hash, tId, 0, caster)
        call SaveReal(udg_MB_Hash, tId, 1, Bladestorm_GetDuration(level))
        call SaveReal(udg_MB_Hash, tId, 2, aoe)
        call SaveInteger(udg_MB_Hash, tId, 3, numSeg)

        // 3. Iniciar rastreo (33 FPS)
        call TimerStart(t, 0.03, true, function Periodic)

        set caster = null
        set t = null
    endfunction


    // ==========================================
    // ===       INICIALIZACIÓN               ===
    // ==========================================

    private function Conditions takes nothing returns boolean
        return GetSpellAbilityId() == Bladestorm_GetAbilityId()
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        call TriggerAddCondition(t, Condition(function Conditions))
        call TriggerAddAction(t, function OnCast)
        set t = null
    endfunction

endscope