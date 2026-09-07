//===========================================================================
// SISTEMA ANTI-BACKDOOR POR FASES (Modular / Future-Proof)
//===========================================================================

globals
    group AB_HUM_F0       = null
    group AB_HUM_F1       = null
    group AB_HUM_F2_TOP   = null
    group AB_HUM_F2_BOT   = null
    group AB_HUM_F3_TOP   = null
    group AB_HUM_F3_BOT   = null
    group AB_ORC_F0       = null
    group AB_ORC_F1       = null
    group AB_ORC_F2_TOP   = null
    group AB_ORC_F2_BOT   = null
    group AB_ORC_F3_TOP   = null
    group AB_ORC_F3_BOT   = null
    boolean AB_HUM_F2Top_Open = false
    boolean AB_HUM_F2Bot_Open = false
    boolean AB_HUM_F1_Open    = false
    boolean AB_HUM_F0_Open    = false
    boolean AB_ORC_F2Top_Open = false
    boolean AB_ORC_F2Bot_Open = false
    boolean AB_ORC_F1_Open    = false
    boolean AB_ORC_F0_Open    = false
    sound AB_SND_GameFound    = null
    sound AB_SND_Rescue       = null
    sound AB_SND_QuestFailed  = null
endglobals

// ===================== UTILIDADES =====================

function AB_GetUnitAt takes integer uid, real x, real y returns unit
    local group g = CreateGroup()
    local unit u
    local unit found = null
    call GroupEnumUnitsInRange(g, x, y, 64.0, null)
    loop
        set u = FirstOfGroup(g)
        exitwhen u == null
        if GetUnitTypeId(u) == uid then
            set found = u
        endif
        call GroupRemoveUnit(g, u)
    endloop
    call DestroyGroup(g)
    set g = null
    set u = null
    return found
endfunction

// Activa permanentemente la variante de animacion "work" en todas las
// unidades colocadas en el mapa que coincidan con el rawcode indicado.
function AB_EnableWorkAnimation takes integer uid returns nothing
    local group g = CreateGroup()
    local unit u
    call GroupEnumUnitsInRect(g, bj_mapInitialPlayableArea, null)
    loop
        set u = FirstOfGroup(g)
        exitwhen u == null
        if GetUnitTypeId(u) == uid then
            call AddUnitAnimationProperties(u, "work", true)
        endif
        call GroupRemoveUnit(g, u)
    endloop
    call DestroyGroup(g)
    set g = null
    set u = null
endfunction

// Captura unidad, agrega al grupo. Si protect=true: invulnerable + tinte visual sutil.
function AB_Capture takes group g, integer uid, real x, real y, boolean protect returns nothing
    local unit u = AB_GetUnitAt(uid, x, y)
    if u != null then
        call GroupAddUnit(g, u)
        if protect then
            call SetUnitInvulnerable(u, true)
        endif
    endif
    set u = null
endfunction

// Remueve proteccion de una sola estructura y restaura su color original.
function AB_UnlockUnit takes unit u returns nothing
    if u != null then
        call SetUnitInvulnerable(u, false)
        call SetUnitVertexColor(u, 255, 255, 255, 255)
    endif
endfunction

// Callback de grupo: remueve proteccion y restaura color original.
function AB_RemoveProtection takes nothing returns nothing
    call AB_UnlockUnit(GetEnumUnit())
endfunction

function AB_UnlockGroup takes group g returns nothing
    call ForGroup(g, function AB_RemoveProtection)
endfunction

// Las creeperas de F2 estan enlazadas por carril y posicion vertical.
// Al morir una, solo su equivalente enemiga se vuelve vulnerable.
// La equivalente permanece dentro de su grupo F2: no abre la fase ni
// deja de ser requisito para desbloquear F1 mientras siga con vida.
function AB_UnlockPairedCreepera takes unit dying returns nothing
    local unit paired = null

    // Norte, arriba: Humana hbar <-> Orca usep
    if dying == udg_unit23 then
        set paired = udg_unit27
    elseif dying == udg_unit27 then
        set paired = udg_unit23

    // Norte, abajo: Humana edob <-> Orca otto
    elseif dying == udg_unit22 then
        set paired = udg_unit28
    elseif dying == udg_unit28 then
        set paired = udg_unit22

    // Sur, manada: Humana eaom (arriba) <-> Orca obar (abajo)
    elseif dying == udg_unit21 then
        set paired = udg_unit25
    elseif dying == udg_unit25 then
        set paired = udg_unit21

    // Sur, tanque: Humana hbla (abajo) <-> Orca uslh (arriba)
    elseif dying == udg_unit20 then
        set paired = udg_unit26
    elseif dying == udg_unit26 then
        set paired = udg_unit20
    endif

    if paired != null and GetWidgetLife(paired) > 0.405 then
        call AB_UnlockUnit(paired)
    endif

    set paired = null
endfunction

function AB_IsGroupDead takes group g returns boolean
    return CountUnitsInGroup(g) == 0
endfunction

// Reproduce un sonido a volumen especifico (0-127)
function AB_PlaySound takes sound s, integer vol returns nothing
    call SetSoundVolume(s, vol)
    call StartSound(s)
endfunction

// Sonido diferenciado por facción (Multiplayer-Safe)
// losingFac: 0 = Humanos pierden (oyen QuestFailed), Orcos atacan (oyen Rescue)
//            1 = Orcos pierden   (oyen QuestFailed), Humanos atacan (oyen Rescue)
function AB_PlayFactionSound takes integer losingFac returns nothing
    local integer pid = GetPlayerId(GetLocalPlayer())
    local boolean isDefender
    
    if (losingFac == 0) then
        set isDefender = (pid <= 4)
    else
        set isDefender = (pid >= 5)
    endif
    
    // QuestFailed para el equipo que perdió sus torres
    call SetSoundVolume(AB_SND_QuestFailed, 0)
    if (isDefender) then
        call SetSoundVolume(AB_SND_QuestFailed, 127)
    endif
    call StartSound(AB_SND_QuestFailed)
    
    // Rescue para el equipo que destruyó las torres
    call SetSoundVolume(AB_SND_Rescue, 0)
    if (not isDefender) then
        call SetSoundVolume(AB_SND_Rescue, 127)
    endif
    call StartSound(AB_SND_Rescue)
endfunction

// Callbacks de tinte por faccion
function AB_TintHuman takes nothing returns nothing
    call SetUnitVertexColor(GetEnumUnit(), 150, 150, 255, 140)
endfunction

function AB_TintOrc takes nothing returns nothing
    call SetUnitVertexColor(GetEnumUnit(), 255, 150, 150, 140)
endfunction

// ===================== LOGICA DE FASES =====================

function AB_CheckHumF1 takes nothing returns nothing
    if AB_HUM_F1_Open then
        return
    endif
    if AB_IsGroupDead(AB_HUM_F2_TOP) and AB_IsGroupDead(AB_HUM_F2_BOT) then
        set AB_HUM_F1_Open = true
        call AB_UnlockGroup(AB_HUM_F1)
        call AB_PlayFactionSound(0)
        call Replay_DisplayTextToAll("La guerra ha llegado a la |cff3399FFultima linea|r de defensa |cff3399FFHumana|r.")
    endif
endfunction

function AB_CheckOrcF1 takes nothing returns nothing
    if AB_ORC_F1_Open then
        return
    endif
    if AB_IsGroupDead(AB_ORC_F2_TOP) and AB_IsGroupDead(AB_ORC_F2_BOT) then
        set AB_ORC_F1_Open = true
        call AB_UnlockGroup(AB_ORC_F1)
        call AB_PlayFactionSound(1)
        call Replay_DisplayTextToAll("La guerra ha llegado a la |cffFF3333ultima linea|r de defensa |cffFF3333Orca|r.")
    endif
endfunction

// ===================== HANDLER DE MUERTE =====================

function AB_OnStructureDeath takes nothing returns nothing
    local unit dying = GetDyingUnit()

    // Excepcion de creeperas: vulnerabilidad individual y simetrica.
    // No modifica grupos ni booleanos de apertura de fase.
    call AB_UnlockPairedCreepera(dying)

    // ========== HUMANOS: Fase 3 Top ==========
    if IsUnitInGroup(dying, AB_HUM_F3_TOP) then
        call GroupRemoveUnit(AB_HUM_F3_TOP, dying)
        if not AB_HUM_F2Top_Open and AB_IsGroupDead(AB_HUM_F3_TOP) then
            set AB_HUM_F2Top_Open = true
            call AB_UnlockGroup(AB_HUM_F2_TOP)
            call AB_PlayFactionSound(0)
            call Replay_DisplayTextToAll("El |cff3399FFnorte|r ha caido, segunda linea |cff3399FFHumana|r vulnerable.")
        endif
        set dying = null
        return
    endif

    // ========== HUMANOS: Fase 3 Bot ==========
    if IsUnitInGroup(dying, AB_HUM_F3_BOT) then
        call GroupRemoveUnit(AB_HUM_F3_BOT, dying)
        if not AB_HUM_F2Bot_Open and AB_IsGroupDead(AB_HUM_F3_BOT) then
            set AB_HUM_F2Bot_Open = true
            call AB_UnlockGroup(AB_HUM_F2_BOT)
            call AB_PlayFactionSound(0)
            call Replay_DisplayTextToAll("El |cff3399FFsur|r ha caido, segunda linea |cff3399FFHumana|r vulnerable.")
        endif
        set dying = null
        return
    endif

    // ========== HUMANOS: Fase 2 Top ==========
    if IsUnitInGroup(dying, AB_HUM_F2_TOP) then
        call GroupRemoveUnit(AB_HUM_F2_TOP, dying)
        if AB_IsGroupDead(AB_HUM_F2_TOP) then
            call AB_CheckHumF1()
        endif
        set dying = null
        return
    endif

    // ========== HUMANOS: Fase 2 Bot ==========
    if IsUnitInGroup(dying, AB_HUM_F2_BOT) then
        call GroupRemoveUnit(AB_HUM_F2_BOT, dying)
        if AB_IsGroupDead(AB_HUM_F2_BOT) then
            call AB_CheckHumF1()
        endif
        set dying = null
        return
    endif

    // ========== HUMANOS: Fase 1 ==========
    if IsUnitInGroup(dying, AB_HUM_F1) then
        call GroupRemoveUnit(AB_HUM_F1, dying)
        if not AB_HUM_F0_Open and AB_IsGroupDead(AB_HUM_F1) then
            set AB_HUM_F0_Open = true
            call AB_UnlockGroup(AB_HUM_F0)
            call UnitRemoveAbility(udg_unit19, 'A032')
            call AB_PlaySound(AB_SND_GameFound, 127)
            call Replay_DisplayTextToAll("|cff3399FFEL CASTILLO AHORA ES VULNERABLE!|r")
        endif
        set dying = null
        return
    endif

    // ========== ORCOS: Fase 3 Top ==========
    if IsUnitInGroup(dying, AB_ORC_F3_TOP) then
        call GroupRemoveUnit(AB_ORC_F3_TOP, dying)
        if not AB_ORC_F2Top_Open and AB_IsGroupDead(AB_ORC_F3_TOP) then
            set AB_ORC_F2Top_Open = true
            call AB_UnlockGroup(AB_ORC_F2_TOP)
            call AB_PlayFactionSound(1)
            call Replay_DisplayTextToAll("El |cffFF3333norte|r ha caido, segunda linea |cffFF3333Orca|r vulnerable.")
        endif
        set dying = null
        return
    endif

    // ========== ORCOS: Fase 3 Bot ==========
    if IsUnitInGroup(dying, AB_ORC_F3_BOT) then
        call GroupRemoveUnit(AB_ORC_F3_BOT, dying)
        if not AB_ORC_F2Bot_Open and AB_IsGroupDead(AB_ORC_F3_BOT) then
            set AB_ORC_F2Bot_Open = true
            call AB_UnlockGroup(AB_ORC_F2_BOT)
            call AB_PlayFactionSound(1)
            call Replay_DisplayTextToAll("El |cffFF3333sur|r ha caido, segunda linea |cffFF3333Orca|r vulnerable.")
        endif
        set dying = null
        return
    endif

    // ========== ORCOS: Fase 2 Top ==========
    if IsUnitInGroup(dying, AB_ORC_F2_TOP) then
        call GroupRemoveUnit(AB_ORC_F2_TOP, dying)
        if AB_IsGroupDead(AB_ORC_F2_TOP) then
            call AB_CheckOrcF1()
        endif
        set dying = null
        return
    endif

    // ========== ORCOS: Fase 2 Bot ==========
    if IsUnitInGroup(dying, AB_ORC_F2_BOT) then
        call GroupRemoveUnit(AB_ORC_F2_BOT, dying)
        if AB_IsGroupDead(AB_ORC_F2_BOT) then
            call AB_CheckOrcF1()
        endif
        set dying = null
        return
    endif

    // ========== ORCOS: Fase 1 ==========
    if IsUnitInGroup(dying, AB_ORC_F1) then
        call GroupRemoveUnit(AB_ORC_F1, dying)
        if not AB_ORC_F0_Open and AB_IsGroupDead(AB_ORC_F1) then
            set AB_ORC_F0_Open = true
            call AB_UnlockGroup(AB_ORC_F0)
            call UnitRemoveAbility(udg_unit24, 'A032')
            call AB_PlaySound(AB_SND_GameFound, 127)
            call Replay_DisplayTextToAll("|cffFF3333LA FORTALEZA AHORA ES VULNERABLE!|r")
        endif
        set dying = null
        return
    endif

    set dying = null
endfunction

// ===================== INICIALIZACION =====================

function AB_PopulateGroups takes nothing returns nothing
    set AB_HUM_F0     = CreateGroup()
    set AB_HUM_F1     = CreateGroup()
    set AB_HUM_F2_TOP = CreateGroup()
    set AB_HUM_F2_BOT = CreateGroup()
    set AB_HUM_F3_TOP = CreateGroup()
    set AB_HUM_F3_BOT = CreateGroup()
    set AB_ORC_F0     = CreateGroup()
    set AB_ORC_F1     = CreateGroup()
    set AB_ORC_F2_TOP = CreateGroup()
    set AB_ORC_F2_BOT = CreateGroup()
    set AB_ORC_F3_TOP = CreateGroup()
    set AB_ORC_F3_BOT = CreateGroup()

    // === HUMANOS F0 + A032 ===
    call AB_Capture(AB_HUM_F0, 'hcas', -4096.0, -256.0, true)
    call UnitAddAbility(udg_unit19, 'A032')

    // === HUMANOS: Fase 1 ===
    call AB_Capture(AB_HUM_F1, 'etrp', -3872.0, 96.0, true)
    call AB_Capture(AB_HUM_F1, 'etrp', -4064.0, -608.0, true)
    call AB_Capture(AB_HUM_F1, 'etrp', -3744.0, -480.0, true)
    call AB_Capture(AB_HUM_F1, 'etrp', -4064.0, 96.0, true)
    call AB_Capture(AB_HUM_F1, 'etrp', -3744.0, -96.0, true)
    call AB_Capture(AB_HUM_F1, 'etrp', -3744.0, -288.0, true)
    call AB_Capture(AB_HUM_F1, 'etrp', -4256.0, 96.0, true)
    call AB_Capture(AB_HUM_F1, 'etrp', -3872.0, -672.0, true)
    call AB_Capture(AB_HUM_F1, 'etrp', -4256.0, -608.0, true)

    // === HUMANOS: Fase 2 Top ===
    call AB_Capture(AB_HUM_F2_TOP, 'hgtw', -3072.0, 1024.0, true)
    call AB_Capture(AB_HUM_F2_TOP, 'hgtw', -3136.0, 1472.0, true)
    call AB_Capture(AB_HUM_F2_TOP, 'hgtw', -3136.0, 1728.0, true)
    call AB_Capture(AB_HUM_F2_TOP, 'hgtw', -3136.0, 2112.0, true)
    call AB_Capture(AB_HUM_F2_TOP, 'hgtw', -3264.0, 1536.0, true)
    call AB_Capture(AB_HUM_F2_TOP, 'hgtw', -3264.0, 1664.0, true)
    call AB_Capture(AB_HUM_F2_TOP, 'edob', -3200.0, 1216.0, true)
    call AB_Capture(AB_HUM_F2_TOP, 'hbar', -3392.0, 1920.0, true)

    // === HUMANOS: Fase 2 Bot ===
    call AB_Capture(AB_HUM_F2_BOT, 'hgtw', -3008.0, -2240.0, true)
    call AB_Capture(AB_HUM_F2_BOT, 'hgtw', -3136.0, -2112.0, true)
    call AB_Capture(AB_HUM_F2_BOT, 'hgtw', -3136.0, -1984.0, true)
    call AB_Capture(AB_HUM_F2_BOT, 'hgtw', -3008.0, -1984.0, true)
    call AB_Capture(AB_HUM_F2_BOT, 'hgtw', -3072.0, -2624.0, true)
    call AB_Capture(AB_HUM_F2_BOT, 'hgtw', -3008.0, -1536.0, true)
    call AB_Capture(AB_HUM_F2_BOT, 'hbla', -3136.0, -2432.0, true)
    call AB_Capture(AB_HUM_F2_BOT, 'eaom', -3264.0, -1728.0, true)

    // === HUMANOS: Fase 3 Top - VULNERABLE ===
    call AB_Capture(AB_HUM_F3_TOP, 'hgtw', -1600.0, 1216.0, false)
    call AB_Capture(AB_HUM_F3_TOP, 'hgtw', -1664.0, 2112.0, false)
    call AB_Capture(AB_HUM_F3_TOP, 'hgtw', -1792.0, 2112.0, false)
    call AB_Capture(AB_HUM_F3_TOP, 'hgtw', -1728.0, 1216.0, false)
    call AB_Capture(AB_HUM_F3_TOP, 'hgtw', -1664.0, 1344.0, false)
    call AB_Capture(AB_HUM_F3_TOP, 'hgtw', -1728.0, 1984.0, false)

    // === HUMANOS: Fase 3 Bot - VULNERABLE ===
    call AB_Capture(AB_HUM_F3_BOT, 'hgtw', -1856.0, -1600.0, false)
    call AB_Capture(AB_HUM_F3_BOT, 'hgtw', -1728.0, -1600.0, false)
    call AB_Capture(AB_HUM_F3_BOT, 'hgtw', -1792.0, -1728.0, false)
    call AB_Capture(AB_HUM_F3_BOT, 'hgtw', -1792.0, -2624.0, false)
    call AB_Capture(AB_HUM_F3_BOT, 'hgtw', -1664.0, -2624.0, false)
    call AB_Capture(AB_HUM_F3_BOT, 'hgtw', -1728.0, -2496.0, false)

    // === ORCOS: Fase 0 (Base) - PROTEGIDO + A032 ===
    call AB_Capture(AB_ORC_F0, 'ofrt', 3840.0, -256.0, true)
    call UnitAddAbility(udg_unit24, 'A032')

    // === ORCOS: Fase 1 ===
    call AB_Capture(AB_ORC_F1, 'uzg1', 4000.0, -608.0, true)
    call AB_Capture(AB_ORC_F1, 'uzg1', 3936.0, 96.0, true)
    call AB_Capture(AB_ORC_F1, 'uzg1', 3808.0, -608.0, true)
    call AB_Capture(AB_ORC_F1, 'uzg1', 3616.0, -608.0, true)
    call AB_Capture(AB_ORC_F1, 'uzg1', 3488.0, -416.0, true)
    call AB_Capture(AB_ORC_F1, 'uzg1', 3488.0, -224.0, true)
    call AB_Capture(AB_ORC_F1, 'uzg1', 3488.0, -32.0, true)
    call AB_Capture(AB_ORC_F1, 'uzg1', 3552.0, 160.0, true)
    call AB_Capture(AB_ORC_F1, 'uzg1', 3744.0, 96.0, true)

    // === ORCOS: Fase 2 Top ===
    call AB_Capture(AB_ORC_F2_TOP, 'owtw', 2688.0, 1600.0, true)
    call AB_Capture(AB_ORC_F2_TOP, 'owtw', 2816.0, 1536.0, true)
    call AB_Capture(AB_ORC_F2_TOP, 'owtw', 2816.0, 1408.0, true)
    call AB_Capture(AB_ORC_F2_TOP, 'owtw', 2688.0, 1344.0, true)
    call AB_Capture(AB_ORC_F2_TOP, 'owtw', 2752.0, 832.0, true)
    call AB_Capture(AB_ORC_F2_TOP, 'owtw', 2688.0, 2112.0, true)
    call AB_Capture(AB_ORC_F2_TOP, 'usep', 2816.0, 1856.0, true)
    call AB_Capture(AB_ORC_F2_TOP, 'otto', 2816.0, 1088.0, true)

    // === ORCOS: Fase 2 Bot ===
    call AB_Capture(AB_ORC_F2_BOT, 'uzg2', 2976.0, -1696.0, true)
    call AB_Capture(AB_ORC_F2_BOT, 'uzg2', 2976.0, -1952.0, true)
    call AB_Capture(AB_ORC_F2_BOT, 'uzg2', 2784.0, -1952.0, true)
    call AB_Capture(AB_ORC_F2_BOT, 'uzg2', 2784.0, -1696.0, true)
    call AB_Capture(AB_ORC_F2_BOT, 'uzg2', 2976.0, -2528.0, true)
    call AB_Capture(AB_ORC_F2_BOT, 'uzg2', 2912.0, -1120.0, true)
    call AB_Capture(AB_ORC_F2_BOT, 'obar', 2944.0, -2240.0, true)
    call AB_Capture(AB_ORC_F2_BOT, 'uslh', 2944.0, -1408.0, true)

    // === ORCOS: Fase 3 Top - VULNERABLE ===
    call AB_Capture(AB_ORC_F3_TOP, 'owtw', 1344.0, 1088.0, false)
    call AB_Capture(AB_ORC_F3_TOP, 'owtw', 1472.0, 1088.0, false)
    call AB_Capture(AB_ORC_F3_TOP, 'owtw', 1408.0, 1216.0, false)
    call AB_Capture(AB_ORC_F3_TOP, 'owtw', 1280.0, 2112.0, false)
    call AB_Capture(AB_ORC_F3_TOP, 'owtw', 1408.0, 2112.0, false)
    call AB_Capture(AB_ORC_F3_TOP, 'owtw', 1344.0, 1920.0, false)

    // === ORCOS: Fase 3 Bot - VULNERABLE ===
    call AB_Capture(AB_ORC_F3_BOT, 'owtw', 1600.0, -2624.0, false)
    call AB_Capture(AB_ORC_F3_BOT, 'owtw', 1728.0, -2624.0, false)
    call AB_Capture(AB_ORC_F3_BOT, 'owtw', 1664.0, -2496.0, false)
    call AB_Capture(AB_ORC_F3_BOT, 'owtw', 1536.0, -1728.0, false)
    call AB_Capture(AB_ORC_F3_BOT, 'owtw', 1664.0, -1728.0, false)
    call AB_Capture(AB_ORC_F3_BOT, 'owtw', 1600.0, -1856.0, false)

    // === APLICAR TINTES POR FACCION ===
    call ForGroup(AB_HUM_F0, function AB_TintHuman)
    call ForGroup(AB_HUM_F1, function AB_TintHuman)
    call ForGroup(AB_HUM_F2_TOP, function AB_TintHuman)
    call ForGroup(AB_HUM_F2_BOT, function AB_TintHuman)
    call ForGroup(AB_ORC_F0, function AB_TintOrc)
    call ForGroup(AB_ORC_F1, function AB_TintOrc)
    call ForGroup(AB_ORC_F2_TOP, function AB_TintOrc)
    call ForGroup(AB_ORC_F2_BOT, function AB_TintOrc)

    // === ANIMACION "PUERTAS ABIERTAS" PERMANENTE EN CREEPERAS ===
    // Persistente (boolean add=true): el edificio mantiene "work" sin timer de refresco.
    // Solo visual: no afecta colision, invulnerabilidad ni el evento de muerte del anti-backdoor.
    // Humanas
    call AddUnitAnimationProperties(udg_unit20, "work", true)  // hbla
    call AddUnitAnimationProperties(udg_unit21, "work", true)  // eaom
    call AddUnitAnimationProperties(udg_unit22, "work", true)  // edob
    call AddUnitAnimationProperties(udg_unit23, "work", true)  // hbar
    // Orcas
    call AddUnitAnimationProperties(udg_unit25, "work", true)  // obar
    call AddUnitAnimationProperties(udg_unit26, "work", true)  // uslh
    call AddUnitAnimationProperties(udg_unit27, "work", true)  // usep
    call AddUnitAnimationProperties(udg_unit28, "work", true)  // otto

    // === ANIMACION "WORK" PERMANENTE EN MERCADOS GOBLIN ===
    // Se aplica por rawcode para alcanzar las dos copias colocadas en el mapa.
    call AB_EnableWorkAnimation('ngme')  // Mercado goblin
endfunction

// ===================== TRIGGER INIT =====================

// Callback del timer: se ejecuta 0.0s despues de init, cuando TODAS las unidades ya existen.
function AB_DelayedInit takes nothing returns nothing
    local trigger t = CreateTrigger()
    call DestroyTimer(GetExpiredTimer())
    call AB_PopulateGroups()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH)
    call TriggerAddAction(t, function AB_OnStructureDeath)
    set t = null
endfunction

function InitTrig_Sistema_AntiBackdoor takes nothing returns nothing
    // Sonido propio de Rescue (sin label preconfigurado = sin cap de volumen)
    set AB_SND_Rescue = CreateSound("Sound\\Interface\\Rescue.wav", false, false, false, 10, 10, "")
    call SetSoundDuration(AB_SND_Rescue, 3796)
    call SetSoundVolume(AB_SND_Rescue, 127)
    // Sonido GameFound para base
    set AB_SND_GameFound = CreateSound("Sound\\Interface\\GameFound.wav", false, false, false, 10, 10, "")
    call SetSoundDuration(AB_SND_GameFound, 2000)
    call SetSoundVolume(AB_SND_GameFound, 127)
    // QuestFailed para el equipo que pierde torres
    set AB_SND_QuestFailed = CreateSound("Sound\\Interface\\QuestFailed.wav", false, false, false, 10, 10, "")
    call SetSoundVolume(AB_SND_QuestFailed, 127)
    // NOTA: No llamamos AB_PopulateGroups() aqui directamente.
    // El orden de InitTrig_* depende del editor y puede cambiar al agregar triggers.
    // Un timer 0.0s garantiza que se ejecute DESPUES de que todas las unidades existan.
    call TimerStart(CreateTimer(), 0.0, false, function AB_DelayedInit)
endfunction
