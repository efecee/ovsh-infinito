//===========================================================================
// SISTEMA: KILL FEED (ANUNCIOS DE MUERTE HUMILLANTES)
// Versión: Victima Primero | Nombres de Jugador | Texto Blanco
// + Registro Histórico de Bajas en F9 (Ring Buffer de 20 entradas)
//===========================================================================

globals
    // --- REGISTRO F9: Quest y Ring Buffer ---
    quest    KF_Quest       = null   // Pestaña del F9 ("Registro de Bajas")
    string array KF_Log            // Ring buffer: últimas 20 entradas
    integer  KF_LogCount   = 0      // Total de kills registradas (crece sin límite)
    integer  KF_LogMax     = 35     // Capacidad máxima visible en F9
endglobals

// --- 1. COLORES DE JUGADORES ---
function Kill_GetColor takes player p returns string
    local integer id = GetPlayerId(p)
    if (id == 0) then 
        return "|cffd02222" // Rojo
    elseif (id == 1) then 
        return "|cff2254dd" // Azul
    elseif (id == 2) then 
        return "|cff1CE6B9" // Teal
    elseif (id == 3) then 
        return "|cff7134c2" // Morado
    elseif (id == 4) then 
        return "|cffFFFC00" // Amarillo
    elseif (id == 5) then 
        return "|cffFE8A0E" // Naranja
    elseif (id == 6) then 
        return "|cff20C000" // Verde
    elseif (id == 7) then 
        return "|cffE55BB0" // Rosa
    elseif (id == 8) then 
        return "|cff959697" // Gris
    elseif (id == 9) then 
        return "|cff7EBFF1" // Celeste
    endif
    return "|cffFFFFFF"
endfunction

// --- 2. GENERADOR DE FRASES ---
// Mecánica de Dado d6:
//   Caras 1-5 (83.3%) → Frase principal: "ha sido asesinado por"
//   Cara  6   (16.7%) → Frase aleatoria de la lista curada (12 frases)
function Kill_GetSpecialPhrase takes string sVic, string sKill returns string
    local integer r = GetRandomInt(1, 12) // 12 frases en la lista curada
    local string w = "|cffFFFFFF"

    if (r == 1) then
        return sVic + w + " fue borrado del mapa por |r" + sKill + "."
    elseif (r == 2) then
        return sVic + w + " aprendió por las malas quién manda: |r" + sKill + "."
    elseif (r == 3) then
        return sVic + w + " terminó sometido por |r" + sKill + "."
    elseif (r == 4) then
        return sVic + w + " no aguantó la presión de |r" + sKill + "."
    elseif (r == 5) then
        return sVic + w + " fue dominado por |r" + sKill + "."
    elseif (r == 6) then
        return sVic + w + " fue controlado de principio a fin por |r" + sKill + "."
    elseif (r == 7) then
        return sVic + w + " sintió todo el poder de |r" + sKill + "."
    elseif (r == 8) then
        return sVic + w + " fue abusado por |r" + sKill + w + " (y le gustó).|r"
    elseif (r == 9) then
        return sVic + w + " fue humillado públicamente por |r" + sKill + "."
    elseif (r == 10) then
        return sVic + w + " es oficialmente hijo de |r" + sKill + "."
    elseif (r == 11) then
        return sVic + w + " se enamoró perdidamente de la daga de |r" + sKill + "."
    elseif (r == 12) then
        return sVic + w + " encontro a su papá: |r" + sKill + "."
    endif

    return sVic + w + " ha sido asesinado por |r" + sKill + "." // Fallback
endfunction

function GetRandomKillMessage takes string sVic, string sKill returns string
    local integer dado = GetRandomInt(1, 6)
    local string w = "|cffFFFFFF"

    // Caras 1-5: Frase principal (83.3% de probabilidad)
    if (dado <= 5) then
        return sVic + w + " ha sido asesinado por |r" + sKill + "."
    endif

    // Cara 6: Frase especial aleatoria (16.7% de probabilidad)
    return Kill_GetSpecialPhrase(sVic, sKill)
endfunction

// --- F9: FORMATEAR TIMESTAMP MM:SS ---
// Lee el tiempo transcurrido de MB_Timer (declarado en tabla.j)
function KF_GetTimestamp takes nothing returns string
    local real elapsed = TimerGetElapsed(MB_Timer)
    local integer totalSec = R2I(elapsed)
    local integer mins = totalSec / 60
    local integer secs = totalSec - (mins * 60)
    local string sMin = ""
    local string sSec = ""

    if (mins < 10) then
        set sMin = "0" + I2S(mins)
    else
        set sMin = I2S(mins)
    endif
    if (secs < 10) then
        set sSec = "0" + I2S(secs)
    else
        set sSec = I2S(secs)
    endif

    return sMin + ":" + sSec
endfunction

// --- F9: RECONSTRUIR DESCRIPCIÓN DEL QUEST ---
// Concatena todas las entradas válidas del ring buffer en un solo string.
// El orden es cronológico: la más antigua arriba, la más reciente abajo.
function KF_RebuildDescription takes nothing returns nothing
    local string desc = ""
    local integer total = KF_LogCount
    local integer start = 0
    local integer i = 0
    local integer idx = 0

    // Si hay menos de KF_LogMax entradas, empezar desde 0
    // Si hay más, empezar desde (total - KF_LogMax) para mostrar las últimas 20
    if (total > KF_LogMax) then
        set start = total - KF_LogMax
    endif

    // Iterar desde la entrada más antigua visible hasta la más reciente
    set i = start
    loop
        exitwhen i >= total
        // Calcular el índice real en el array circular (módulo KF_LogMax)
        set idx = i - (i / KF_LogMax) * KF_LogMax
        if (desc == "") then
            set desc = KF_Log[idx]
        else
            set desc = desc + "|n" + KF_Log[idx]
        endif
        set i = i + 1
    endloop

    // Si no hay kills aún, texto por defecto
    if (desc == "") then
        set desc = "|cff888888Aún no se registran bajas.|r"
    endif

    call QuestSetDescription(KF_Quest, desc)
endfunction

// --- F9: REGISTRAR UNA KILL EN EL HISTORIAL ---
// Genera la línea "MM:SS → NombreVictima asesinado por NombreKiller"
// y la almacena en el ring buffer, luego reconstruye la descripción.
function KF_RegisterKill takes string sVictimName, string sKillerName returns nothing
    local string timestamp = KF_GetTimestamp()
    local integer slot = 0
    local string entry = ""

    // Construir la línea del log
    // Formato: "[MM:SS] => Victima asesinado por Killer"
    set entry = "|cffFFCC00" + timestamp + "|r |cffFFCC00=>|r " + sVictimName + " |cffFFFFFFasesinado por|r " + sKillerName

    // Calcular slot circular: KF_LogCount mod KF_LogMax
    set slot = KF_LogCount - (KF_LogCount / KF_LogMax) * KF_LogMax
    set KF_Log[slot] = entry
    set KF_LogCount = KF_LogCount + 1

    // Reconstruir texto del F9
    call KF_RebuildDescription()
endfunction

// --- HELPER: Obtener el héroe de un jugador ---
// Busca el primer héroe vivo del jugador. Zero-waste: DestroyGroup en la misma función.
// Función pública: usada también por Sistema_Kills.j.
function KF_GetPlayerHero takes player p returns unit
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

// --- 3. ACCIONES PRINCIPALES ---
function Trig_Anuncios_Kill_Actions takes nothing returns nothing
    local unit victim = GetDyingUnit()
    local unit killer = GetKillingUnit()
    local player pVictim
    local player pKiller
    local string sKillerName
    local string sVictimName
    local string finalMsg
    
    // 0. VALIDAR QUE LA VÍCTIMA SEA UN HÉROE (excluir ilusiones: no anunciar
    //    ni registrar en el F9 la "muerte" de una ilusión)
    if (not IsUnitType(victim, UNIT_TYPE_HERO) or IsUnitIllusion(victim)) then
        set victim = null
        set killer = null
        return
    endif
    
    // 1. REATRIBUCIÓN DE INVOCACIÓN → HÉROE DUEÑO (Estilo DotA)
    // Si el killer no es un héroe (ej: invocación, ward, trampa),
    // buscamos el héroe del jugador dueño para atribuirle la kill.
    if (not IsUnitType(killer, UNIT_TYPE_HERO)) then
        set pKiller = GetOwningPlayer(killer)
        // Solo reatribuir si el dueño es un jugador real (0-9) y enemigo
        if (GetPlayerId(pKiller) >= 0 and GetPlayerId(pKiller) <= 9) then
            set killer = KF_GetPlayerHero(pKiller)
        endif
        set pKiller = null
    endif
    
    // 2. VALIDACIÓN FINAL: Killer debe ser un héroe enemigo válido
    if (IsUnitType(killer, UNIT_TYPE_HERO)) then
        if (killer != victim and IsUnitEnemy(killer, GetOwningPlayer(victim))) then
            
            // 3. OBTENER JUGADORES
            set pVictim = GetOwningPlayer(victim)
            set pKiller = GetOwningPlayer(killer)
            
            // 4. OBTENER NOMBRES REALES DE JUGADOR (CON COLOR)
            // Usamos GetPlayerName para obtener "Pedrito", no el nombre del Héroe
            set sVictimName = Kill_GetColor(pVictim) + GetPlayerName(pVictim) + "|r"
            set sKillerName = Kill_GetColor(pKiller) + GetPlayerName(pKiller) + "|r"
            
            // 5. GENERAR MENSAJE ALEATORIO
            // Pasamos los nombres a la funcion para que los incruste en la frase
            set finalMsg = GetRandomKillMessage(sVictimName, sKillerName)
            
            // 6. MOSTRAR A TODOS
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 7.0, finalMsg)
            
            // 7. SONIDO ORIGINAL (NO PERDERLO)
            // Usamos tu variable global de sonido udg_sound02
            //call PlaySoundBJ(udg_sound02) // MIGRADO → Sistema_Kills.j (KS_OnHeroDeath)
            
            // 8. REGISTRAR EN HISTORIAL F9
            call KF_RegisterKill(sVictimName, sKillerName)
        endif
    endif
    
    set victim = null
    set killer = null
    set pVictim = null
    set pKiller = null
endfunction

//===========================================================================
function InitTrig_Sistema_Anuncios takes nothing returns nothing
    set gg_trg_Sistema_Anuncios = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Sistema_Anuncios, EVENT_PLAYER_UNIT_DEATH)
    call TriggerAddAction(gg_trg_Sistema_Anuncios, function Trig_Anuncios_Kill_Actions)
    
    // --- CREAR QUEST DEL REGISTRO DE BAJAS (F9) ---
    // Tipo "Optional" para que aparezca en la sección inferior del F9 (separada de Comandos/Acerca de).
    // Ícono: Calavera dorada (BTNOrbOfDeath) — temática de muerte.
    set KF_Quest = CreateQuest()
    call QuestSetTitle(KF_Quest, "Registro de Bajas")
    call QuestSetDescription(KF_Quest, "|cff888888Aún no se registran bajas.|r")
    call QuestSetIconPath(KF_Quest, "ReplaceableTextures\\CommandButtons\\BTNOrbOfDeath.blp")
    call QuestSetRequired(KF_Quest, false)    // false = "Optional" → sección inferior del F9
    call QuestSetDiscovered(KF_Quest, true)   // Visible desde el inicio
    call QuestSetCompleted(KF_Quest, false)    // Nunca se "completa"
    call QuestSetEnabled(KF_Quest, true)       // Habilitada
endfunction