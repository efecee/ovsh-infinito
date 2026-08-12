//===========================================================================
// SISTEMA DE KILLS: MULTI-KILL + RACHAS (Estilo DotA)
//===========================================================================
// DEPENDENCIAS:
//   - tabla.j            (MB_Timer)
//   - Sistema_Anuncios.j (Kill_GetColor)
//
// ─────────────────────────────────────────────────────────────────────────
// SISTEMA A: MULTI-KILL (ventana de 25s desde la ÚLTIMA kill)
//   Cuenta kills rápidas consecutivas. El timer se reinicia en cada kill.
//   mk=1 → Excellent      (kill normal, suena siempre)
//   mk=2 → Double Kill
//   mk=3 → Triple Kill
//   mk=4 → Ultra Kill
//   mk=5 → Rampage        (máximo posible en un 5v5)
//
// SISTEMA B: RACHA (kills seguidas sin morir — independiente del timer)
//   Solo suena en los umbrales exactos.
//   streak=3  → Killing Spree
//   streak=4  → Dominating
//   streak=5  → Unstoppable
//   streak=6  → Monster Kill
//   streak=7+ → Godlike  (se repite en cada kill posterior)
//   *Matar a alguien con racha >= 7 → Holy Shit
//
// AMBOS SISTEMAS SON INDEPENDIENTES y pueden sonar al mismo tiempo.
// Ejemplo: kill #3 en racha + 3ª en 25s → Killing Spree + Triple Kill.
//
// REGLAS DE PRIORIDAD DE SONIDO (por kill):
//   1. First Blood           → solo firstblood.mp3, nada más.
//   2. Multi-Kill (mk>=2)    → solo el sonido de multi-kill.
//   3. Streak en umbral (mk=1) → solo el sonido de racha.
//   4. Sin umbral (mk=1) o racha intermedia → Excellent llena el silencio.
//
// ⚠️  REEMPLAZA LOS NOMBRES DE ARCHIVO en InitTrig_Sistema_Kills
//     con los nombres EXACTOS de tus MP3 importados al mapa.
//===========================================================================

globals
    // --- SONIDOS (Persistentes — patrón tabla.j, nunca se destruyen) ---
    sound KS_Snd_Excellent    = null  // Kill básica (mk=1), reemplaza al drexcelent
    sound KS_Snd_FirstBlood   = null
    sound KS_Snd_DoubleKill   = null
    sound KS_Snd_TripleKill   = null
    sound KS_Snd_UltraKill    = null
    sound KS_Snd_Rampage      = null
    sound KS_Snd_KillingSpree = null
    sound KS_Snd_Dominating   = null
    sound KS_Snd_Unstoppable  = null
    sound KS_Snd_MonsterKill  = null
    sound KS_Snd_Godlike      = null
    sound KS_Snd_HolyShit     = null

    // --- ESTADO POR JUGADOR (índice 0-9) ---
    integer array KS_Streak        // Kills seguidas sin morir
    integer array KS_MultiKill     // Kills rápidas en la ventana actual
    real    array KS_LastKillTime  // Timestamp de la última kill (vía MB_Timer)
    boolean KS_FirstBloodDone = false
endglobals

// --- HELPER: Reproducir sonido para TODOS los jugadores ---
function KS_PlaySound takes sound s returns nothing
    call SetSoundVolume(s, 127)
    call StartSound(s)
endfunction

// --- HELPER: Obtener el héroe de un jugador ---
// Busca el primer héroe vivo del jugador. Zero-waste: DestroyGroup en la misma función.
function KS_GetPlayerHero takes player p returns unit
    local group g = CreateGroup()
    local unit u
    local unit hero = null
    
    call GroupEnumUnitsOfPlayer(g, p, null)
    loop
        set u = FirstOfGroup(g)
        exitwhen u == null
        call GroupRemoveUnit(g, u)
        if (IsUnitType(u, UNIT_TYPE_HERO) and hero == null) then
            set hero = u
        endif
    endloop
    
    call DestroyGroup(g)
    set g = null
    set u = null
    return hero
endfunction



// ===================== LÓGICA DE RACHA =====================
// Se llama DESPUÉS de incrementar KS_Streak[pid].
// Retorna TRUE si sonó un sonido de racha (para que el caller no agregue Excellent).
function KS_HandleStreak takes integer pid returns boolean
    local integer streak = KS_Streak[pid]

    if (streak == 3) then
        call KS_PlaySound(KS_Snd_KillingSpree)
        return true
    elseif (streak == 4) then
        call KS_PlaySound(KS_Snd_Dominating)
        return true
    elseif (streak == 5) then
        call KS_PlaySound(KS_Snd_Unstoppable)
        return true
    elseif (streak == 6) then
        call KS_PlaySound(KS_Snd_MonsterKill)
        return true
    elseif (streak >= 7) then
        call KS_PlaySound(KS_Snd_Godlike)
        return true
    endif
    return false
endfunction

// ===================== LÓGICA DE MULTI-KILL =====================
// Solo maneja mk>=2. El caso mk=1 lo gestiona KS_OnHeroDeath directamente.
function KS_HandleMultiKill takes integer pid returns nothing
    local integer mk = KS_MultiKill[pid]

    if (mk == 2) then
        call KS_PlaySound(KS_Snd_DoubleKill)
    elseif (mk == 3) then
        call KS_PlaySound(KS_Snd_TripleKill)
    elseif (mk == 4) then
        call KS_PlaySound(KS_Snd_UltraKill)
    elseif (mk >= 5) then
        call KS_PlaySound(KS_Snd_Rampage)
    endif
endfunction

// ===================== EVENTO PRINCIPAL: MUERTE =====================
function KS_OnHeroDeath takes nothing returns nothing
    local unit victim = GetDyingUnit()
    local unit killer = GetKillingUnit()
    local player pVictim
    local player pKiller
    local integer pidV
    local integer pidK
    local real currentTime
    local boolean isFirstBlood = false
    local boolean streakSounded = false

    // Solo héroes víctimas (las ilusiones cuentan como héroe: excluirlas para
    // no disparar First Blood/racha/multikill falsos ni resetear la racha real del dueño)
    if (not IsUnitType(victim, UNIT_TYPE_HERO) or IsUnitIllusion(victim)) then
        set victim = null
        set killer = null
        return
    endif

    // --- REATRIBUCIÓN DE INVOCACIÓN → HÉROE DUEÑO (Estilo DotA) ---
    // Si el killer no es un héroe (ej: invocación, ward, trampa),
    // buscamos el héroe del jugador dueño para atribuirle la kill.
    if (not IsUnitType(killer, UNIT_TYPE_HERO)) then
        set pKiller = GetOwningPlayer(killer)
        if (GetPlayerId(pKiller) >= 0 and GetPlayerId(pKiller) <= 9) then
            set killer = KS_GetPlayerHero(pKiller)
        endif
        set pKiller = null
    endif

    set pVictim = GetOwningPlayer(victim)
    set pidV    = GetPlayerId(pVictim)

    // --- A) ¿Era Godlike la víctima y la remató un ENEMIGO? → Holy Shit ---
    // El taunt + crédito "Racha cortada" es una RECOMPENSA del enemigo que la
    // derribó (estilo Dota 2: el corte de racha solo lo gana un rival). Por eso
    // se exige IsUnitEnemy ADEMÁS de que el killer sea héroe (incluida invocación
    // enemiga, ya reatribuida a su héroe dueño arriba).
    //   - Deny de un aliado, suicidio o invocación aliada → NO suena, NO acredita.
    //   - Torre/creep (jugador 10/11) ya no entran porque no son héroes.
    // La racha igual se resetea para TODOS más abajo (B), como en Dota.
    if (KS_Streak[pidV] >= 7 and IsUnitType(killer, UNIT_TYPE_HERO) and IsUnitEnemy(killer, pVictim)) then
        call KS_PlaySound(KS_Snd_HolyShit)
        call DisplayTimedTextToPlayer(GetOwningPlayer(killer), 0, 0, 7.0, "|cffFFCC00Racha Godlike cortada!|r")
    endif

    // --- B) Resetear racha de la víctima ---
    set KS_Streak[pidV] = 0

    // --- C) Si el asesino no es un héroe enemigo, terminar aquí ---
    if (not IsUnitType(killer, UNIT_TYPE_HERO)) then
        set victim = null
        set killer = null
        set pVictim = null
        return
    endif
    if (not IsUnitEnemy(killer, pVictim)) then
        set victim = null
        set killer = null
        set pVictim = null
        return
    endif

    set pKiller    = GetOwningPlayer(killer)
    set pidK       = GetPlayerId(pKiller)
    set currentTime = TimerGetElapsed(MB_Timer)

    // --- D) First Blood ---
    if (not KS_FirstBloodDone) then
        set KS_FirstBloodDone = true
        set isFirstBlood = true
        call KS_PlaySound(KS_Snd_FirstBlood)
        call DisplayTimedTextToPlayer(Player(pidK), 0, 0, 7.0, "|cffFFCC00Primera sangre de la partida!|r")
        // Guardar QUIÉN logró la primera sangre para el resumen final.
        // Se guarda en udg_MB_Hash (parent 999) en vez de un global propio para
        // evitar problemas de orden de compilación con Sistema_Victoria.j.
        // pid+1 (así 0 = "nadie aún").
        call SaveInteger(udg_MB_Hash, 999, 0, pidK + 1)
    endif

    // --- E) Multi-Kill (ventana de 25s desde la ÚLTIMA kill del asesino) ---
    if (KS_LastKillTime[pidK] > 0.0 and (currentTime - KS_LastKillTime[pidK]) <= 25.0) then
        set KS_MultiKill[pidK] = KS_MultiKill[pidK] + 1
    else
        set KS_MultiKill[pidK] = 1  // Primera kill de una nueva ventana
    endif
    set KS_LastKillTime[pidK] = currentTime

    // --- F) Racha ---
    set KS_Streak[pidK] = KS_Streak[pidK] + 1
    set streakSounded = KS_HandleStreak(pidK)

    // --- G) PRIORIDAD DE SONIDO ---
    // 1. First Blood: ya sonó arriba, no agregar nada más
    // 2. Multi-Kill (mk>=2): el sonido de multi-kill es el protagonista
    // 3. mk=1 + racha en umbral: el sonido de racha reemplaza al Excellent
    // 4. mk=1 + racha intermedia (4,6,7,9) o sin racha: Excellent llena el silencio
    if (not isFirstBlood) then
        if (KS_MultiKill[pidK] >= 2) then
            call KS_HandleMultiKill(pidK)
        elseif (not streakSounded) then
            call KS_PlaySound(KS_Snd_Excellent)
        endif
    endif

    // --- H) TOOLTIPS EDUCATIVOS (solo para el killer) ---
    // Mensajes cortos en dorado que explican el significado de cada sonido.
    // First Blood ya fue manejado arriba (sección D).
    // Kill normal (Excellent, mk=1) no lleva tooltip para no saturar.
    if (not isFirstBlood) then
        // Multi-Kill: ventana temporal
        if (KS_MultiKill[pidK] == 2) then
            call DisplayTimedTextToPlayer(Player(pidK), 0, 0, 7.0, "|cffFFCC00Double Kill! — 2 kills seguidas.|r")
        elseif (KS_MultiKill[pidK] == 3) then
            call DisplayTimedTextToPlayer(Player(pidK), 0, 0, 7.0, "|cffFFCC00Triple Kill! — 3 kills seguidas.|r")
        elseif (KS_MultiKill[pidK] == 4) then
            call DisplayTimedTextToPlayer(Player(pidK), 0, 0, 7.0, "|cffFFCC00Ultra Kill! — 4 kills seguidas.|r")
        elseif (KS_MultiKill[pidK] >= 5) then
            call DisplayTimedTextToPlayer(Player(pidK), 0, 0, 7.0, "|cffFFCC00Rampage! — 5 kills seguidas.|r")
        endif
        // Racha: kills seguidas sin morir (solo en umbrales)
        if (KS_Streak[pidK] == 3) then
            call DisplayTimedTextToPlayer(Player(pidK), 0, 0, 7.0, "|cffFFCC00Killing Spree! — Racha de 3 kills.|r")
        elseif (KS_Streak[pidK] == 4) then
            call DisplayTimedTextToPlayer(Player(pidK), 0, 0, 7.0, "|cffFFCC00Dominating! — Racha de 4 kills.|r")
        elseif (KS_Streak[pidK] == 5) then
            call DisplayTimedTextToPlayer(Player(pidK), 0, 0, 7.0, "|cffFFCC00Unstoppable! — Racha de 5 kills.|r")
        elseif (KS_Streak[pidK] == 6) then
            call DisplayTimedTextToPlayer(Player(pidK), 0, 0, 7.0, "|cffFFCC00Monster Kill! — Racha de 6 kills.|r")
        elseif (KS_Streak[pidK] >= 7) then
            call DisplayTimedTextToPlayer(Player(pidK), 0, 0, 7.0, "|cffFFCC00Godlike! — Racha de " + I2S(KS_Streak[pidK]) + " kills.|r")
        endif
    endif

    set victim  = null
    set killer  = null
    set pVictim = null
    set pKiller = null
endfunction

//===========================================================================
function InitTrig_Sistema_Kills takes nothing returns nothing
    local trigger t = CreateTrigger()
    local integer i = 0

    // --- Inicializar estado de todos los jugadores ---
    loop
        exitwhen i > 9
        set KS_Streak[i]       = 0
        set KS_MultiKill[i]    = 0
        set KS_LastKillTime[i] = 0.0
        set i = i + 1
    endloop

    // ============================================================
    // SONIDOS GLOBALES PERSISTENTES (patrón tabla.j)
    // ============================================================
    // Kill básica: el clásico drexcelent suena en cada kill normal (mk=1)
    set KS_Snd_Excellent    = CreateSound("war3mapImported\\II drexcelent.mp3", false, false, false, 10, 10, "")
    call SetSoundVolume(KS_Snd_Excellent, 127)

    set KS_Snd_FirstBlood   = CreateSound("war3mapImported\\firstblood.mp3",    false, false, false, 10, 10, "")
    call SetSoundVolume(KS_Snd_FirstBlood, 127)

    set KS_Snd_DoubleKill   = CreateSound("war3mapImported\\Double Kill.mp3",   false, false, false, 10, 10, "")
    call SetSoundVolume(KS_Snd_DoubleKill, 127)

    set KS_Snd_TripleKill   = CreateSound("war3mapImported\\Triple Kill.mp3",   false, false, false, 10, 10, "")
    call SetSoundVolume(KS_Snd_TripleKill, 127)

    set KS_Snd_UltraKill    = CreateSound("war3mapImported\\Ultra Kill.mp3",    false, false, false, 10, 10, "")
    call SetSoundVolume(KS_Snd_UltraKill, 127)

    set KS_Snd_Rampage      = CreateSound("war3mapImported\\Rampage.mp3",       false, false, false, 10, 10, "")
    call SetSoundVolume(KS_Snd_Rampage, 127)

    set KS_Snd_KillingSpree = CreateSound("war3mapImported\\Killing Spree.mp3", false, false, false, 10, 10, "")
    call SetSoundVolume(KS_Snd_KillingSpree, 127)

    set KS_Snd_Dominating   = CreateSound("war3mapImported\\Dominating.mp3",    false, false, false, 10, 10, "")
    call SetSoundVolume(KS_Snd_Dominating, 127)

    set KS_Snd_Unstoppable  = CreateSound("war3mapImported\\Unstoppable.mp3",   false, false, false, 10, 10, "")
    call SetSoundVolume(KS_Snd_Unstoppable, 127)

    set KS_Snd_MonsterKill  = CreateSound("war3mapImported\\M-m-m-m-Monster Kill.mp3", false, false, false, 10, 10, "")
    call SetSoundVolume(KS_Snd_MonsterKill, 127)

    set KS_Snd_Godlike      = CreateSound("war3mapImported\\godlike.mp3",       false, false, false, 10, 10, "")
    call SetSoundVolume(KS_Snd_Godlike, 127)

    set KS_Snd_HolyShit     = CreateSound("war3mapImported\\Holy Shit.mp3",     false, false, false, 10, 10, "")
    call SetSoundVolume(KS_Snd_HolyShit, 127)

    // --- Registrar evento de muerte ---
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH)
    call TriggerAddAction(t, function KS_OnHeroDeath)
    set t = null
endfunction
