//===========================================================================
// SISTEMA DE VICTORIA / DERROTA
//===========================================================================
// Reemplaza la lógica legacy de init.j (Trig_Lose_for_humans / Trig_Lose_for_Orcs).
//
// MEJORAS SOBRE EL ORIGINAL:
//   1. Activa Voto_GameOver ANTES de victoria/derrota, previniendo
//      encuestas espurias del Sistema_Voto al terminar la partida.
//   2. Si hay una votación en curso, la cierra limpiamente.
//   3. Muestra resumen: equipo ganador, duración, MVP y LVP (por puntaje).
//   4. Fuerza la tabla (multiboard) visible y expandida al terminar.
//   5. Resumen con duración ~permanente; victoria/derrota inmediata (sin delay).
//
// DEPENDENCIAS:
//   - Sistema_Voto.j (library SistemaVoto): Voto_GameOver, ForceEndVote
//   - tabla.j: MB_Timer, MB_GetColor, udg_MB_Hash, udg_MB_Tabla
//   - init.j: udg_unit19 (Castillo Humano), udg_unit24 (Fortaleza Orca)
//
// FÓRMULA DE PUNTAJE (Top 3 + MVP):
//   Score = Kills*5 + Asistencias*3 - Muertes*4 + redondeo(OroDonadoNeto / 1000)
//   OroDonadoNeto = max(0, enviado(key 701) - recibido(key 702)): el oro que
//   circula entre aliados (ping-pong, círculos) se cancela solo y no infla el
//   puntaje; solo puntúa lo regalado por encima de lo recibido.
//   El oro se redondea al entero más cercano: (oro + 500) / 1000.
//   El #1 del ranking es el MVP. Se muestran los 3 primeros puestos.
//
// PREMIOS INDIVIDUALES (resumen final):
//   El Verdugo    = mayor daño total a héroes  (udg_MB_Hash key 700, lo llena tabla.j)
//   Banquero      = más oro donado NETO (udg_MB_Hash keys 701/702, Comandos_Economia.j)
//   Mano Derecha  = más asistencias            (udg_MB_Hash key 4)
//   Primera Sangre = quién hizo el primer kill (udg_MB_Hash parent 999, Sistema_Kills.j)
//===========================================================================

globals
    boolean SV_GameEnded  = false      // Guardia contra re-entrada
    boolean SV_HumansLost = false       // true = Castillo destruido, false = Fortaleza
    constant real SV_TEXT_DUR = 99999.0 // Duración del resumen: ~permanente (no desaparece)
    // Buffers para el cálculo del Top 3 al terminar (índice 0-9). Se usan una sola
    // vez (SV_GameEnded impide re-entrada), pero se reinicializan al calcular.
    integer array SV_Score
    boolean array SV_HasRow
    boolean array SV_Used
    // Resultado ya calculado, copiado a globales para que SV_PrintReport pueda
    // imprimir (y RE-imprimir en multijugador tras ClearTextMessages).
    string  SV_WinTeam     = ""
    string  SV_DurStr      = ""
    integer SV_PlayerCount = 0
    real    SV_BestDmg     = 0.0
    integer SV_DmgId       = -1
    integer SV_BestGold    = 0
    integer SV_GoldId      = -1
    integer SV_BestAssist  = 0
    integer SV_AssistId    = -1
endglobals

// --- HELPER: Formatear entero con separador de miles ("15200" -> "15,200") ---
// Solo para números no negativos (daño/oro). Mantiene <= 3 dígitos sin cambios.
function SV_FormatThousands takes integer n returns string
    local string s = I2S(n)
    local integer len = StringLength(s)
    local integer first = len - (len / 3) * 3 // dígitos antes del primer grupo de 3
    local string result
    local integer i
    if (len <= 3) then
        return s
    endif
    if (first == 0) then
        set result = SubString(s, 0, 3)
        set i = 3
    else
        set result = SubString(s, 0, first)
        set i = first
    endif
    loop
        exitwhen i >= len
        set result = result + "," + SubString(s, i, i + 3)
        set i = i + 3
    endloop
    return result
endfunction

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
// Devuelve el nombre guardado por tabla.j (key 5). Si está vacío (p.ej. la
// primera sangre la hizo alguien sin fila registrada en la tabla), cae al
// nombre nativo del jugador para no mostrar nunca un nombre en blanco.
function SV_NameOf takes integer pid returns string
    local string s = LoadStr(udg_MB_Hash, pid, 5)
    if (s == null or s == "") then
        return GetPlayerName(Player(pid))
    endif
    return s
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

// --- Ejecuta victoria/derrota (llamado directamente, sin delay) ---
function SV_ExecuteResult takes nothing returns nothing
    if (SV_HumansLost) then
        // Humanos pierden, Orcos ganan
        call CustomDefeatBJ(Player(0), "Caíste, fallaste y perdiste")
        call CustomDefeatBJ(Player(1), "Hoy solo serviste de vergüenza")
        call CustomDefeatBJ(Player(2), "No queda nada: has perdido.")
        call CustomDefeatBJ(Player(3), "Tu castillo ha sido reducido a ruinas.")
        call CustomDefeatBJ(Player(4), "Hoy no sumaste nada.")
        call CustomVictoryBJ(Player(5), true, true)
        call CustomVictoryBJ(Player(6), true, true)
        call CustomVictoryBJ(Player(7), true, true)
        call CustomVictoryBJ(Player(8), true, true)
        call CustomVictoryBJ(Player(9), true, true)
        call CustomDefeatBJ(Player(10), "TRIGSTR_8849")
        call CustomVictoryBJ(Player(11), true, true)
    else
        // Orcos pierden, Humanos ganan
        call CustomVictoryBJ(Player(0), true, true)
        call CustomVictoryBJ(Player(1), true, true)
        call CustomVictoryBJ(Player(2), true, true)
        call CustomVictoryBJ(Player(3), true, true)
        call CustomVictoryBJ(Player(4), true, true)
        call CustomVictoryBJ(Player(10), true, true)
        call CustomDefeatBJ(Player(5), "Caíste, fallaste y perdiste")
        call CustomDefeatBJ(Player(6), "Has pasado a la historia como una vergüenza.")
        call CustomDefeatBJ(Player(7), "No hubo remontada. Solo derrota.")
        call CustomDefeatBJ(Player(8), "Perdiste, no estuviste a la altura.")
        call CustomDefeatBJ(Player(9), "Viniste a jugar, te vas humillado")
        call CustomDefeatBJ(Player(11), "TRIGSTR_8855")
    endif
endfunction

// --- Imprime el resumen de fin de partida (resultado + Top 3 + premios). ---
// Se extrae a función propia para poder reimprimirlo en multijugador DESPUÉS de
// ClearTextMessages (ver SV_OnStructureDeath). Lee los valores ya calculados
// desde los globales SV_*. Reinicia SV_Used para que el Top 3 se pueda
// recomputar en cada llamada (la selección por pasadas marca SV_Used).
function SV_PrintReport takes nothing returns nothing
    local integer i
    local integer rank
    local integer bestScore
    local integer bestIdx
    local integer fbRaw
    local integer fbPid

    set i = 0
    loop
        exitwhen i > 9
        set SV_Used[i] = false
        set i = i + 1
    endloop

    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, SV_TEXT_DUR, " ")
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, SV_TEXT_DUR, "|cffFFCC00========== PARTIDA TERMINADA ==========|r")
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, SV_TEXT_DUR, "  Victoria para: " + SV_WinTeam)
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, SV_TEXT_DUR, "  Duración: |cffFFCC00" + SV_DurStr + "|r")

    // --- TOP 3 POR PUNTAJE (selección por pasadas; el #1 es el MVP) ---
    if (SV_PlayerCount >= 1) then
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, SV_TEXT_DUR, " ")
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
            if (rank == 1) then
                call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, SV_TEXT_DUR, "  [1] " + SV_GetColor(Player(bestIdx)) + SV_NameOf(bestIdx) + "|r  |cffFFCC00" + I2S(bestScore) + "|r pts |cffFFCC00(MVP!)|r")
            else
                call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, SV_TEXT_DUR, "  [" + I2S(rank) + "] " + SV_GetColor(Player(bestIdx)) + SV_NameOf(bestIdx) + "|r  |cffFFCC00" + I2S(bestScore) + "|r pts")
            endif
            set rank = rank + 1
        endloop
    endif

    // --- PREMIOS INDIVIDUALES (cada línea solo si hay ganador con valor > 0) ---
    if (SV_DmgId >= 0 or SV_GoldId >= 0 or SV_AssistId >= 0) then
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, SV_TEXT_DUR, " ")
        // Primera Sangre (pid+1 guardado por Sistema_Kills.j; 0 = no hubo).
        set fbRaw = LoadInteger(udg_MB_Hash, 999, 0)
        if (fbRaw > 0) then
            set fbPid = fbRaw - 1
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, SV_TEXT_DUR, "  Primera Sangre: " + SV_GetColor(Player(fbPid)) + SV_NameOf(fbPid) + "|r")
        endif
    endif
    if (SV_DmgId >= 0) then
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, SV_TEXT_DUR, "  Cazador de Héroes: " + SV_GetColor(Player(SV_DmgId)) + SV_NameOf(SV_DmgId) + "|r |cffAAAAAA(" + SV_FormatThousands(R2I(SV_BestDmg)) + " de Daño Acumulado)|r")
    endif
    if (SV_GoldId >= 0) then
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, SV_TEXT_DUR, "  Top Donador: " + SV_GetColor(Player(SV_GoldId)) + SV_NameOf(SV_GoldId) + "|r |cffAAAAAA(" + SV_FormatThousands(SV_BestGold) + " de Oro Compartido)|r")
    endif
    if (SV_AssistId >= 0) then
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, SV_TEXT_DUR, "  Mejor Soporte: " + SV_GetColor(Player(SV_AssistId)) + SV_NameOf(SV_AssistId) + "|r |cffAAAAAA(" + I2S(SV_BestAssist) + " Asistencias)|r")
    endif

    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, SV_TEXT_DUR, "|cffFFCC00=========================================|r")
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

    // 7. Copiar lo calculado a globales para que SV_PrintReport lo imprima
    //    (y pueda RE-imprimirlo en multijugador tras ClearTextMessages).
    set SV_WinTeam     = winTeam
    set SV_DurStr      = sMin + ":" + sSec
    set SV_PlayerCount = playerCount
    set SV_BestDmg     = bestDmg
    set SV_DmgId       = dmgId
    set SV_BestGold    = bestGold
    set SV_GoldId      = goldId
    set SV_BestAssist  = bestAssist
    set SV_AssistId    = assistId

    // 8. Mostrar resumen y ejecutar victoria/derrota.
    //    SINGLE PLAYER: CustomVictoryBJ muestra el diálogo y PAUSA el juego, sin
    //      emitir mensajes por jugador → basta imprimir el resumen ANTES (caso
    //      ya verificado funcionando; se mantiene idéntico).
    //    MULTIJUGADOR (incl. Partida Local / LAN aunque sea 1 humano + bots):
    //      CustomVictory/DefeatBJ NO pausan y emiten un "X salió victorioso/
    //      derrotado" NATIVO por jugador, que se imprime DESPUÉS y tapa/recorta
    //      el resumen. Solución: ejecutar primero, limpiar esos mensajes con
    //      ClearTextMessages y reimprimir el resumen al final (queda visible).
    if (bj_isSinglePlayer) then
        call SV_PrintReport()
        call SV_ExecuteResult()
    else
        call SV_ExecuteResult()
        call ClearTextMessages()
        call SV_PrintReport()
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
