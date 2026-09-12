//===========================================================================
// SISTEMA DE VICTORIA / DERROTA
//===========================================================================
// Reemplaza la lógica legacy de init.j (Trig_Lose_for_humans / Trig_Lose_for_Orcs).
//
// MEJORAS SOBRE EL ORIGINAL:
//   1. Activa Voto_GameOver ANTES de victoria/derrota, previniendo
//      encuestas espurias del Sistema_Voto al terminar la partida.
//   2. Si hay una votación en curso, la cierra limpiamente.
//   3. Muestra el resumen dentro del cuadro final de victoria/derrota.
//   4. Fuerza la tabla (multiboard) visible y expandida al terminar.
//   5. Ganadores y perdedores reciben el mismo resumen, con cabecera distinta.
//   6. Muestra a la izquierda las últimas bajas registradas durante la partida.
//
// DEPENDENCIAS:
//   - Sistema_Voto.j (library SistemaVoto): Voto_GameOver, ForceEndVote
//   - Sistema_AntiBackdoor.j: AB_SiegeF0/F1/F2/F3
//   - Sistema_Anuncios.j: KF_DisplayFinalLog (invocada mediante ExecuteFunc)
//   - tabla.j: MB_Timer, MB_GetColor, udg_MB_Hash, udg_MB_Tabla
//   - init.j: udg_unit19 (Castillo Humano), udg_unit24 (Fortaleza Orca)
//
// FÓRMULA DE PUNTAJE (Top 3):
//   Score = Kills*5 + Asistencias*3 - Muertes*4 + redondeo(OroDonadoNeto / 1000)
//   OroDonadoNeto = max(0, enviado(key 701) - recibido(key 702)): el oro que
//   circula entre aliados (ping-pong, círculos) se cancela solo y no infla el
//   puntaje; solo puntúa lo regalado por encima de lo recibido.
//   El oro se redondea al entero más cercano: (oro + 500) / 1000.
//   Se muestran los 3 primeros puestos.
//
// PREMIOS INDIVIDUALES (resumen final):
//   Demoledor   = mayor daño efectivo a estructuras clave enemigas (F0-F3)
//   Cazahéroes  = mayor daño total a héroes  (udg_MB_Hash key 700, lo llena tabla.j)
//   Donador     = más oro donado NETO (udg_MB_Hash keys 701/702, Comandos_Economia.j)
//   Soporte     = más asistencias            (udg_MB_Hash key 4)
//===========================================================================

globals
    constant real SV_SIEGE_EPSILON = 0.01
    boolean SV_GameEnded  = false      // Guardia contra re-entrada
    boolean SV_HumansLost = false       // true = Castillo destruido, false = Fortaleza
    // Buffers para el cálculo del Top 3 al terminar (índice 0-9). Se usan una sola
    // vez (SV_GameEnded impide re-entrada), pero se reinicializan al calcular.
    integer array SV_Score
    boolean array SV_HasRow
    boolean array SV_Used
    // Resultado ya calculado, copiado a globales para construir una sola vez el
    // mismo resumen que verán todos los jugadores dentro de su cuadro final.
    string  SV_WinTeam     = ""
    string  SV_DurStr      = ""
    string  SV_ReportText  = ""
    string  SV_VictoryText = ""
    string  SV_DefeatText  = ""
    integer SV_PlayerCount = 0
    integer SV_DmgId       = -1
    integer SV_SiegeId     = -1
    integer SV_GoldId      = -1
    integer SV_AssistId    = -1
endglobals

// --- FUNCIÓN LOCAL: COLOR DE JUGADOR ---
// Replicamos la función de tabla.j para evitar problemas de orden de compilación
// donde tabla.j se compila DESPUÉS de Sistema_Victoria.j.
function SV_GetColor takes player p returns string
    local integer id = GetPlayerId(p)
    if (id == 0) then
        return "|cffd02222" // Rojo (claro)
    elseif (id == 1) then
        return "|cff2254dd" // Azul (claro)
    elseif (id == 2) then
        return "|cff1CE6B9" // Teal
    elseif (id == 3) then
        return "|cff7134c2" // Morado (lavanda)
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

// --- NOMBRE DE JUGADOR (con respaldo) ---
// Devuelve el nombre guardado por tabla.j (key 5). Si está vacío, cae al nombre
// nativo del jugador para no mostrar nunca un nombre en blanco.
function SV_NameOf takes integer pid returns string
    local string s = LoadStr(udg_MB_Hash, pid, 5)
    if (s == null or s == "") then
        return GetPlayerName(Player(pid))
    endif
    return s
endfunction

// --- HELPERS: PREMIO DEMOLEDOR ---
function SV_GetSiegeTotal takes integer pid returns real
    return AB_SiegeF0[pid] + AB_SiegeF1[pid] + AB_SiegeF2[pid] + AB_SiegeF3[pid]
endfunction

function SV_IsWinningPid takes integer pid returns boolean
    if SV_HumansLost then
        return pid >= 5 and pid <= 9
    endif
    return pid >= 0 and pid <= 4
endfunction

// Compara solo candidatos que ya tienen daño de asedio positivo.
// Orden: total > equipo ganador > F0 > F1 > F2 > F3 > kills > menor pid.
// La prioridad por fase es lexicografica: nunca compensa un total inferior.
function SV_IsBetterSiegeCandidate takes integer candidate, integer current returns boolean
    local real candidateTotal = SV_GetSiegeTotal(candidate)
    local real currentTotal = SV_GetSiegeTotal(current)
    local boolean candidateWon
    local boolean currentWon
    local boolean sameTeam
    local integer candidateKills
    local integer currentKills

    if candidateTotal > currentTotal + SV_SIEGE_EPSILON then
        return true
    elseif currentTotal > candidateTotal + SV_SIEGE_EPSILON then
        return false
    endif

    set candidateWon = SV_IsWinningPid(candidate)
    set currentWon = SV_IsWinningPid(current)
    if candidateWon and not currentWon then
        return true
    elseif currentWon and not candidateWon then
        return false
    endif

    set sameTeam = (candidate <= 4 and current <= 4) or (candidate >= 5 and current >= 5)
    if sameTeam then
        if AB_SiegeF0[candidate] > AB_SiegeF0[current] + SV_SIEGE_EPSILON then
            return true
        elseif AB_SiegeF0[current] > AB_SiegeF0[candidate] + SV_SIEGE_EPSILON then
            return false
        endif
        if AB_SiegeF1[candidate] > AB_SiegeF1[current] + SV_SIEGE_EPSILON then
            return true
        elseif AB_SiegeF1[current] > AB_SiegeF1[candidate] + SV_SIEGE_EPSILON then
            return false
        endif
        if AB_SiegeF2[candidate] > AB_SiegeF2[current] + SV_SIEGE_EPSILON then
            return true
        elseif AB_SiegeF2[current] > AB_SiegeF2[candidate] + SV_SIEGE_EPSILON then
            return false
        endif
        if AB_SiegeF3[candidate] > AB_SiegeF3[current] + SV_SIEGE_EPSILON then
            return true
        elseif AB_SiegeF3[current] > AB_SiegeF3[candidate] + SV_SIEGE_EPSILON then
            return false
        endif
    endif

    // Solo lectura de la estadistica existente: Demoledor no escribe ni limpia
    // ninguna clave de udg_MB_Hash.
    set candidateKills = LoadInteger(udg_MB_Hash, candidate, 1)
    set currentKills = LoadInteger(udg_MB_Hash, current, 1)
    if candidateKills > currentKills then
        return true
    elseif currentKills > candidateKills then
        return false
    endif

    return candidate < current
endfunction

// --- Limpia los timerdialogs de resurrección (sistema legacy de init.j) ---
// Al terminar la partida, si en la esquina superior derecha hay 2+ ventanas
// (la tabla + temporizadores de héroes muertos), el motor de WC3 las desmonta
// en cascada al mostrar la pantalla de victoria, llevándose la tabla. Dejando
// SOLO la tabla, ese desmontaje no ocurre (verificado empíricamente).
// DestroyTimerDialogBJ es seguro con handles null o ya destruidos (no-op).
function SV_ClearReviveTimers takes nothing returns nothing
    call DestroyTimerDialogBJ(udg_timerdialog03)
    call DestroyTimerDialogBJ(udg_timerdialog04)
    call DestroyTimerDialogBJ(udg_timerdialog05)
    call DestroyTimerDialogBJ(udg_timerdialog06)
    call DestroyTimerDialogBJ(udg_timerdialog07)
    call DestroyTimerDialogBJ(udg_timerdialog08)
    call DestroyTimerDialogBJ(udg_timerdialog09)
    call DestroyTimerDialogBJ(udg_timerdialog10)
    call DestroyTimerDialogBJ(udg_timerdialog11)
    call DestroyTimerDialogBJ(udg_timerdialog12)
endfunction

// --- Cuadro de victoria nativo, pero con mensaje personalizado. ---
// CustomVictoryBJ no recibe texto: su cuadro usa GAMEOVER_VICTORY_MSG fijo.
// Esta réplica conserva sus botones, sonido y comportamiento, cambiando solo
// el mensaje para poder mostrar exactamente el mismo resumen que en derrota.
function SV_CustomVictoryDialog takes player whichPlayer, string message returns nothing
    local trigger t = null
    local dialog d = DialogCreate()

    call DialogSetMessage(d, message)

    set t = CreateTrigger()
    call TriggerRegisterDialogButtonEvent(t, DialogAddButton(d, GetLocalizedString("GAMEOVER_CONTINUE"), GetLocalizedHotkey("GAMEOVER_CONTINUE")))
    call TriggerAddAction(t, function CustomVictoryOkBJ)

    set t = CreateTrigger()
    call TriggerRegisterDialogButtonEvent(t, DialogAddButton(d, GetLocalizedString("GAMEOVER_QUIT_MISSION"), GetLocalizedHotkey("GAMEOVER_QUIT_MISSION")))
    call TriggerAddAction(t, function CustomVictoryQuitBJ)

    if (GetLocalPlayer() == whichPlayer) then
        call EnableUserControl(true)
        if bj_isSinglePlayer then
            call PauseGame(true)
        endif
        call EnableUserUI(false)
    endif

    call DialogDisplay(whichPlayer, d, true)
    call VolumeGroupSetVolumeForPlayerBJ(whichPlayer, SOUND_VOLUMEGROUP_UI, 1.0)
    call StartSoundForPlayerBJ(whichPlayer, bj_victoryDialogSound)

    set t = null
    set d = null
endfunction

// --- Victoria real con el cuadro personalizado anterior. ---
// Replica CustomVictoryBJ para mantener RemovePlayer, el aviso multijugador y
// la pantalla de puntuaciones, evitando que aparezca además el cuadro fijo.
function SV_CustomVictoryBJ takes player whichPlayer, string message returns nothing
    if AllowVictoryDefeat(PLAYER_GAME_RESULT_VICTORY) then
        call RemovePlayer(whichPlayer, PLAYER_GAME_RESULT_VICTORY)

        if not bj_isSinglePlayer then
            call DisplayTimedTextFromPlayer(whichPlayer, 0, 0, 60, GetLocalizedString("PLAYER_VICTORIOUS"))
        endif

        if (GetPlayerController(whichPlayer) == MAP_CONTROL_USER) then
            set bj_changeLevelShowScores = true
            call SV_CustomVictoryDialog(whichPlayer, message)
        endif
    endif
endfunction

// --- Ejecuta victoria/derrota (llamado directamente, sin delay) ---
function SV_ExecuteResult takes nothing returns nothing
    if (SV_HumansLost) then
        // Humanos pierden, Orcos ganan
        call CustomDefeatBJ(Player(0), SV_DefeatText)
        call CustomDefeatBJ(Player(1), SV_DefeatText)
        call CustomDefeatBJ(Player(2), SV_DefeatText)
        call CustomDefeatBJ(Player(3), SV_DefeatText)
        call CustomDefeatBJ(Player(4), SV_DefeatText)
        call SV_CustomVictoryBJ(Player(5), SV_VictoryText)
        call SV_CustomVictoryBJ(Player(6), SV_VictoryText)
        call SV_CustomVictoryBJ(Player(7), SV_VictoryText)
        call SV_CustomVictoryBJ(Player(8), SV_VictoryText)
        call SV_CustomVictoryBJ(Player(9), SV_VictoryText)
        call CustomDefeatBJ(Player(10), SV_DefeatText)
        call SV_CustomVictoryBJ(Player(11), SV_VictoryText)
    else
        // Orcos pierden, Humanos ganan
        call SV_CustomVictoryBJ(Player(0), SV_VictoryText)
        call SV_CustomVictoryBJ(Player(1), SV_VictoryText)
        call SV_CustomVictoryBJ(Player(2), SV_VictoryText)
        call SV_CustomVictoryBJ(Player(3), SV_VictoryText)
        call SV_CustomVictoryBJ(Player(4), SV_VictoryText)
        call SV_CustomVictoryBJ(Player(10), SV_VictoryText)
        call CustomDefeatBJ(Player(5), SV_DefeatText)
        call CustomDefeatBJ(Player(6), SV_DefeatText)
        call CustomDefeatBJ(Player(7), SV_DefeatText)
        call CustomDefeatBJ(Player(8), SV_DefeatText)
        call CustomDefeatBJ(Player(9), SV_DefeatText)
        call CustomDefeatBJ(Player(11), SV_DefeatText)
    endif
endfunction

// --- Construye el resumen de fin de partida (resultado + Top 3 + premios). ---
// Ordena la información en datos generales, clasificación y distinciones.
// Usa |n para llevar cada línea dentro del diálogo.
function SV_BuildReport takes nothing returns string
    local integer i
    local integer rank
    local integer bestScore
    local integer bestIdx
    local string report = "|cffC0C0C0Equipo ganador:|r " + SV_WinTeam
    local string awards = ""

    set i = 0
    loop
        exitwhen i > 9
        set SV_Used[i] = false
        set i = i + 1
    endloop

    set report = report + "|n|cffC0C0C0Duración:|r |cffFFCC00" + SV_DurStr + "|r"

    // --- TOP 3 POR PUNTAJE (selección por pasadas) ---
    if (SV_PlayerCount >= 1) then
        set report = report + "|n|n|cffFFCC00CLASIFICACIÓN|r"
        set rank = 1
        loop
            exitwhen rank > 3
            set bestScore = -999999
            set bestIdx = -1
            set i = 0
            loop
                exitwhen i > 9
                if (SV_HasRow[i] and not SV_Used[i] and SV_Score[i] > bestScore) then
                    set bestScore = SV_Score[i]
                    set bestIdx = i
                endif
                set i = i + 1
            endloop
            exitwhen bestIdx == -1
            set SV_Used[bestIdx] = true
            set report = report + "|n|cffFFCC00" + I2S(rank) + ".|r " + SV_GetColor(Player(bestIdx)) + SV_NameOf(bestIdx) + "|r  |cffAAAAAA" + I2S(bestScore) + " pts|r"
            set rank = rank + 1
        endloop
    endif

    // --- PREMIOS INDIVIDUALES (cada línea solo si hay ganador con valor > 0) ---
    // Etiquetas breves y sin métricas para mantener cada distinción en una sola
    // línea incluso cuando el nombre del jugador sea largo.
    if (SV_DmgId >= 0 or SV_SiegeId >= 0 or SV_GoldId >= 0 or SV_AssistId >= 0) then
        if (SV_SiegeId >= 0) then
            if (awards != "") then
                set awards = awards + "|n"
            endif
            set awards = awards + "|cffC0C0C0Demoledor:|r " + SV_GetColor(Player(SV_SiegeId)) + SV_NameOf(SV_SiegeId) + "|r"
        endif
        if (SV_DmgId >= 0) then
            if (awards != "") then
                set awards = awards + "|n"
            endif
            set awards = awards + "|cffC0C0C0Cazahéroes:|r " + SV_GetColor(Player(SV_DmgId)) + SV_NameOf(SV_DmgId) + "|r"
        endif
        if (SV_GoldId >= 0) then
            if (awards != "") then
                set awards = awards + "|n"
            endif
            set awards = awards + "|cffC0C0C0Donador:|r " + SV_GetColor(Player(SV_GoldId)) + SV_NameOf(SV_GoldId) + "|r"
        endif
        if (SV_AssistId >= 0) then
            if (awards != "") then
                set awards = awards + "|n"
            endif
            set awards = awards + "|cffC0C0C0Soporte:|r " + SV_GetColor(Player(SV_AssistId)) + SV_NameOf(SV_AssistId) + "|r"
        endif
        set report = report + "|n|n|cffFFCC00DISTINCIONES|r|n" + awards
    endif

    return report
endfunction

// --- ACCIÓN PRINCIPAL: Una estructura principal fue destruida ---
function SV_OnStructureDeath takes nothing returns nothing
    local unit dying = GetDyingUnit()
    local real elapsed = TimerGetElapsed(MB_Timer)
    local integer totalSec = R2I(elapsed)
    local integer mins = totalSec / 60
    local integer secs = totalSec - (mins * 60)
    local string sMin = ""
    local string sSec = ""
    local string winTeam = ""

    // Variables para puntajes y premios
    local integer i = 0
    local integer row
    local integer kills
    local integer deaths
    local integer assists
    local integer goldDon
    local integer score
    local integer playerCount = 0

    // Premios individuales
    local real    dmgVal
    local real    bestDmg    = 0.0
    local integer dmgId      = -1
    local integer siegeId    = -1
    local integer bestGold   = 0
    local integer goldId     = -1
    local integer bestAssist = 0
    local integer assistId   = -1

    // --- FILTRO: Solo nos interesan las dos estructuras principales ---
    // (Registramos muerte genérica, así que aquí descartamos todo lo demás.)
    if (dying != udg_unit19 and dying != udg_unit24) then
        set dying = null
        return
    endif

    // --- GUARDIA: No re-entrar si ya se procesó ---
    if (SV_GameEnded) then
        set dying = null
        return
    endif
    set SV_GameEnded = true

    // 1. ACTIVAR FLAG DE GAME OVER (bloquea encuestas futuras)
    set SistemaVoto_Voto_GameOver = true

    // 2. Si hay votación en curso, cerrarla limpiamente
    call SistemaVoto_ForceEndVote()

    // 3. Determinar equipo ganador
    if (dying == udg_unit19) then
        set SV_HumansLost = true
        set winTeam = "|cffFFCC00Orcos|r"
    else
        set SV_HumansLost = false
        set winTeam = "|cffFFCC00Humanos|r"
    endif

    // 4. Formato de duración (MM:SS con cero a la izquierda)
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

    // 5. Calcular puntajes y detectar premios individuales.
    //    Score = Kills*5 + Asist*3 - Muertes*4 + redondeo(OroDonadoNeto / 1000).
    //    El oro se redondea al entero más cercano con (oro + 500) / 1000.
    //    Solo jugadores con fila en la tabla (row > 0) participan.
    loop
        exitwhen i > 9
        set SV_Used[i] = false
        set row = LoadInteger(udg_MB_Hash, i, 0)
        if (row > 0) then
            set kills   = LoadInteger(udg_MB_Hash, i, 1)
            set deaths  = LoadInteger(udg_MB_Hash, i, 2)
            set assists = LoadInteger(udg_MB_Hash, i, 4)
            // Oro donado NETO = enviado(701) - recibido(702), con piso 0: el oro
            // que circula entre aliados se cancela solo (anti ping-pong/círculos);
            // únicamente puntúa regalar más de lo que te regalaron.
            set goldDon = LoadInteger(udg_MB_Hash, i, 701) - LoadInteger(udg_MB_Hash, i, 702)
            if (goldDon < 0) then
                set goldDon = 0
            endif
            set score   = (kills * 5) + (assists * 3) - (deaths * 4) + ((goldDon + 500) / 1000)
            set SV_Score[i] = score
            set SV_HasRow[i] = true
            set playerCount = playerCount + 1

            // Premio "El Verdugo": mayor daño total a héroes (key 700).
            set dmgVal = LoadReal(udg_MB_Hash, i, 700)
            if (dmgVal > bestDmg) then
                set bestDmg = dmgVal
                set dmgId = i
            endif
            // Premio "Demoledor": daño efectivo acumulado en F0-F3 enemigas.
            if SV_GetSiegeTotal(i) > 0.0 then
                if siegeId < 0 then
                    set siegeId = i
                elseif SV_IsBetterSiegeCandidate(i, siegeId) then
                    set siegeId = i
                endif
            endif
            // Premio "Banquero": más oro donado NETO (701 - 702, ya clampeado).
            if (goldDon > bestGold) then
                set bestGold = goldDon
                set goldId = i
            endif
            // Premio "Mano Derecha": más asistencias.
            if (assists > bestAssist) then
                set bestAssist = assists
                set assistId = i
            endif
        else
            set SV_HasRow[i] = false
        endif
        set i = i + 1
    endloop

    // 6a. Destruir los temporizadores de resurrección para dejar SOLO la tabla
    //     en la esquina superior derecha (evita el desmontaje en cascada).
    call SV_ClearReviveTimers()

    // 6b. Forzar la tabla visible y expandida (por si un jugador la ocultó).
    call MultiboardDisplay(udg_MB_Tabla, true)
    call MultiboardMinimize(udg_MB_Tabla, false)

    // 7. Copiar lo calculado a globales y construir una sola vez el resumen.
    set SV_WinTeam     = winTeam
    set SV_DurStr      = sMin + ":" + sSec
    set SV_PlayerCount = playerCount
    set SV_DmgId       = dmgId
    set SV_SiegeId     = siegeId
    set SV_GoldId      = goldId
    set SV_AssistId    = assistId
    set SV_ReportText  = SV_BuildReport()
    set SV_VictoryText = "|cff20C000VICTORIA!|r|n" + SV_ReportText
    set SV_DefeatText  = "|cffFF2020DERROTA|r|n" + SV_ReportText

    // 8. Ejecutar el resultado y reutilizar el antiguo espacio lateral para el
    //    registro de bajas. En single debe imprimirse antes del diálogo porque
    //    este pausa la partida; en multi, después de limpiar los avisos nativos.
    if bj_isSinglePlayer then
        call ExecuteFunc("KF_DisplayFinalLog")
        call SV_ExecuteResult()
    else
        call SV_ExecuteResult()
        // Quitar únicamente los avisos nativos "X salió victorioso/derrotado".
        // ClearTextMessages no afecta los cuadros Dialog recién mostrados.
        call ClearTextMessages()
        call ExecuteFunc("KF_DisplayFinalLog")
        // El motor NO honra PauseGame en multi al venir de RemovePlayer, así que
        // lo forzamos aquí para igualar la congelación del single player (ya se
        // usa en otros sistemas y funciona en multi).
        call PauseGame(true)
    endif

    set dying = null
endfunction

// --- INICIALIZACIÓN ---
// Registra muerte GENÉRICA (cualquier unidad) y filtra en la acción.
// MOTIVO: InitTrig_ se ejecuta ANTES de que el editor cree udg_unit19/udg_unit24,
// por lo que registrar sobre esos handles los encuentra null y falla en silencio.
// Al registrar muerte genérica, el filtro de SV_OnStructureDeath compara contra
// las estructuras (que YA existen al morir), volviéndolo inmune al orden de init.
function InitTrig_Sistema_Victoria takes nothing returns nothing
    local trigger t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH)
    call TriggerAddAction(t, function SV_OnStructureDeath)
    set t = null
endfunction
