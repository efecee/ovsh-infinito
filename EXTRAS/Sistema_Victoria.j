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
//   6. A la izquierda, cada jugador ve SU resumen personal (Sistema_Resumen.j):
//      puesto, mejor racha y duelos. El centro y la tabla son iguales para todos.
//   7. Partida ajustada: si el Castillo/Fortaleza del ganador también estaba
//      vulnerable y quedó bajo el 50% de vida, una línea sin etiqueta lo dice
//      debajo de la duración (ver SV_BuildCloseFinish). En Modo Rápido el 100%
//      es la vida con la que empezó (ModoPartida_FactorVidaEstructuras).
//   8. Debajo de la duración, el modo de partida y la renta ("Modo: Rápido
//      (18 oro)"), para comparar cuánto dura cada modo.
//
// DEPENDENCIAS:
//   - Sistema_Voto.j (library SistemaVoto): Voto_GameOver, ForceEndVote
//   - Sistema_AntiBackdoor.j: AB_SiegeF0/F1/F2/F3, AB_HUM_F0_Open, AB_ORC_F0_Open
//   - Sistema_Resumen.j: SistemaResumen_ShowFinal (invocada mediante ExecuteFunc);
//     lee SV_Rank, SV_Score, SV_HasRow y SV_PlayerCount de este archivo
//   - tabla.j: MB_Timer, MB_GetColor, udg_MB_Hash, udg_MB_Tabla
//   - init.j: udg_unit19 (Castillo Humano), udg_unit24 (Fortaleza Orca)
//   - Core_Menu_Click.j: udg_Config_Cantidad_Oro (renta: 6/9/12 Normal, 12/15/18 Rápido)
//   - Core_Menu_Modo.j (library ModoPartida): modo de partida y vida de inicio
//     de las estructuras
//   - Sistema_Voto.j: foto de estadísticas del que abandona (udg_MB_Hash 710-720)
//
// FÓRMULA DE PUNTAJE (Top 3):
//   Score = Kills*5 + Asistencias*3 - Muertes*4 + PuntosOro
//   PuntosOro = redondeo(OroDonadoNeto / OroPorPunto), con
//   OroPorPunto = 1000 * renta / 12. El modo de referencia es 12 oro/seg (el
//   más jugado): 1 punto vale los mismos SEGUNDOS de renta en cualquier modo
//   (6 -> 500 de oro, 9 -> 750, 12 -> 1000, 15 -> 1250). Ver SV_GoldPoints.
//   OroDonadoNeto = max(0, enviado(key 701) - recibido(key 702)): el oro que
//   circula entre aliados (ping-pong, círculos) se cancela solo y no infla el
//   puntaje; solo puntúa lo regalado por encima de lo recibido.
//   No suman 701: el oro enviado antes de elegir héroe (Eco_CountsAsDonor en
//   Comandos_Economia.j) ni el reparto del oro de un desertor (Sistema_Voto.j).
//   Desempate: menos muertes, luego más daño a héroes (ver SV_IsBetterRank).
//   Abandono: el puntaje y las distinciones se CONGELAN al salir (sin
//   penalización). Lo que haga después la IA sustituta no suma al que se fue.
//   Se muestran los 3 primeros puestos.
//
//   DECISIONES DE DISEÑO (2026-10-13, no reintroducir sin discutirlo):
//   - El asedio NO suma puntos: lo hacen sobre todo los héroes de daño, que ya
//     cobran por sus kills, y castigaría a los soportes. Lo reconoce Demoledor.
//   - Ganar o perder NO suma: la Clasificación mide el aporte individual, gane
//     o pierda su equipo (en 6 de 7 partidas revisadas el 1.º ya era ganador).
//   - Abandonar NO resta: no se distingue una desconexión de un abandono a
//     propósito, y congelar ya le cuesta dejar de sumar.
//
// PREMIOS INDIVIDUALES (resumen final):
//   Demoledor   = mayor daño efectivo a estructuras clave enemigas (F0-F3)
//   Cazahéroes  = mayor daño total a héroes  (udg_MB_Hash key 700, lo llena tabla.j)
//   Donador     = más oro donado NETO (udg_MB_Hash keys 701/702, Comandos_Economia.j)
//   Soporte     = más asistencias            (udg_MB_Hash key 4)
//===========================================================================

globals
    constant real SV_SIEGE_EPSILON = 0.01
    // Puntos por oro: en el modo de referencia (12 oro/seg) 1000 de oro = 1 punto.
    constant integer SV_GOLD_REF_RATE      = 12
    constant integer SV_GOLD_PER_POINT_REF = 1000
    // Partida ajustada: vida máxima (fracción) del edificio del ganador para
    // mencionarla en el resumen. Por encima no fue una carrera.
    constant real SV_CLOSE_FINISH_PCT = 0.50
    boolean SV_GameEnded  = false      // Guardia contra re-entrada
    boolean SV_HumansLost = false       // true = Castillo destruido, false = Fortaleza
    // Buffers para el cálculo del Top 3 al terminar (índice 0-9). Se usan una sola
    // vez (SV_GameEnded impide re-entrada), pero se reinicializan al calcular.
    integer array SV_Score
    integer array SV_Deaths     // desempate 1: menos muertes
    real    array SV_HeroDmg    // desempate 2: más daño a héroes
    boolean array SV_HasRow
    boolean array SV_Used
    integer array SV_Rank       // Puesto final (1 = primero); 0 = sin fila. Lo lee Sistema_Resumen.j
    // Resultado ya calculado, copiado a globales para construir una sola vez el
    // mismo resumen que verán todos los jugadores dentro de su cuadro final.
    string  SV_WinTeam     = ""
    string  SV_DurStr      = ""
    string  SV_CloseFinish = ""        // Línea de partida ajustada; "" si no corresponde
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

// --- ESTADÍSTICAS PARA CLASIFICACIÓN Y DISTINCIONES ---
// Si el jugador abandonó, SistemaVoto_OnPlayerLeave dejó una foto de sus
// estadísticas en udg_MB_Hash (710 = foto tomada; 711-720 = valores). Su
// puntaje queda congelado en ese momento: conserva lo logrado, pero no suma lo
// que haga después la IA sustituta (voto BOT) ni asistencias póstumas.
// liveKey = clave viva (1/2/4/700/701/702); frozenKey = su copia en la foto.
function SV_StatInt takes integer pid, integer liveKey, integer frozenKey returns integer
    if LoadBoolean(udg_MB_Hash, pid, 710) then
        return LoadInteger(udg_MB_Hash, pid, frozenKey)
    endif
    return LoadInteger(udg_MB_Hash, pid, liveKey)
endfunction

function SV_StatReal takes integer pid, integer liveKey, integer frozenKey returns real
    if LoadBoolean(udg_MB_Hash, pid, 710) then
        return LoadReal(udg_MB_Hash, pid, frozenKey)
    endif
    return LoadReal(udg_MB_Hash, pid, liveKey)
endfunction

// Daño de asedio en una fase (0 = F0 ... 3 = F3), congelado si abandonó.
function SV_GetSiegePhase takes integer pid, integer phase returns real
    if LoadBoolean(udg_MB_Hash, pid, 710) then
        return LoadReal(udg_MB_Hash, pid, 717 + phase)
    endif
    if phase == 0 then
        return AB_SiegeF0[pid]
    elseif phase == 1 then
        return AB_SiegeF1[pid]
    elseif phase == 2 then
        return AB_SiegeF2[pid]
    endif
    return AB_SiegeF3[pid]
endfunction

// --- PUNTOS POR ORO DONADO (normalizados por el modo de renta) ---
// El oro que se puede donar crece en proporción exacta a la renta; las kills
// no. Medido en oro fijo, el mismo soporte valía más en los modos rápidos.
// Por eso el oro por punto escala con la renta: 1 punto = los mismos segundos
// de renta en cualquier modo. Redondea al entero más cercano.
function SV_GoldPoints takes integer goldNet returns integer
    local integer rate = udg_Config_Cantidad_Oro
    local integer perPoint
    if (rate <= 0) then
        set rate = SV_GOLD_REF_RATE
    endif
    set perPoint = (rate * SV_GOLD_PER_POINT_REF) / SV_GOLD_REF_RATE
    return (goldNet + perPoint / 2) / perPoint
endfunction

// --- ORDEN DE LA CLASIFICACIÓN ---
// Más puntos primero. A igualdad de puntos: menos muertes, luego más daño a
// héroes. Sin esto el empate lo ganaba siempre el slot más bajo (Rojo antes
// que Azul, y cualquier Humano antes que cualquier Orco).
function SV_IsBetterRank takes integer candidate, integer current returns boolean
    if SV_Score[candidate] != SV_Score[current] then
        return SV_Score[candidate] > SV_Score[current]
    endif
    if SV_Deaths[candidate] != SV_Deaths[current] then
        return SV_Deaths[candidate] < SV_Deaths[current]
    endif
    return SV_HeroDmg[candidate] > SV_HeroDmg[current]
endfunction

// --- PUESTO DE CADA JUGADOR (lo muestra el resumen personal) ---
// Mismo orden que el podio de SV_BuildReport: SV_IsBetterRank y, en empate
// total, el slot más bajo primero (es lo que hace su selección por pasadas).
// Así el puesto personal nunca contradice al podio del centro.
function SV_ComputeRanks takes nothing returns nothing
    local integer i = 0
    local integer j
    local integer rank
    loop
        exitwhen i > 9
        set SV_Rank[i] = 0
        if (SV_HasRow[i]) then
            set rank = 1
            set j = 0
            loop
                exitwhen j > 9
                if (j != i and SV_HasRow[j]) then
                    if (SV_IsBetterRank(j, i) or (j < i and not SV_IsBetterRank(i, j))) then
                        set rank = rank + 1
                    endif
                endif
                set j = j + 1
            endloop
            set SV_Rank[i] = rank
        endif
        set i = i + 1
    endloop
endfunction

// --- PARTIDA AJUSTADA: vida que le quedó al edificio del GANADOR ---
// Hay partidas que se deciden en una carrera: los de más daño rompen la base
// rival mientras los de control defienden (y reparan) la propia. Si el
// Castillo/Fortaleza del ganador también estaba vulnerable (su F1 ya había
// caído) y le quedaba menos de SV_CLOSE_FINISH_PCT, se muestra cuánto le
// quedó: ese es el margen de la carrera. Si repararon, el porcentaje ya lo
// refleja. Sin etiqueta y corta a propósito ("La Fortaleza quedó al 6%",
// ~25 chars) para no salirse del cuadro. Mínimo 1%: el edificio sigue en pie.
// MODO RÁPIDO: normalmente su vida MÁXIMA ya está a la mitad y empieza con la
// barra llena (factor 1.0). Solo si se usó el plan B de Core_Menu_Modo.j
// empieza con la mitad de la barra, y entonces el 100% es esa vida de inicio
// (si no, el aviso saldría en casi todas las partidas rápidas).
function SV_BuildCloseFinish takes nothing returns string
    local unit building
    local boolean vulnerable
    local string name
    local real life
    local real maxLife
    local integer pct

    if (SV_HumansLost) then
        set building   = udg_unit24 // Ganaron los Orcos: su Fortaleza
        set vulnerable = AB_ORC_F0_Open
        set name       = "La Fortaleza"
    else
        set building   = udg_unit19 // Ganaron los Humanos: su Castillo
        set vulnerable = AB_HUM_F0_Open
        set name       = "El Castillo"
    endif
    set life    = GetWidgetLife(building)
    set maxLife = GetUnitState(building, UNIT_STATE_MAX_LIFE) * ModoPartida_FactorVidaEstructuras()
    set building = null

    if (not vulnerable or life <= 0.405 or maxLife <= 0.0 or life >= maxLife * SV_CLOSE_FINISH_PCT) then
        return ""
    endif
    set pct = R2I(life * 100.0 / maxLife)
    if (pct < 1) then
        set pct = 1
    endif
    return "|cffC0C0C0" + name + " quedó al|r |cffFFCC00" + I2S(pct) + "%|r"
endfunction

// --- HELPERS: PREMIO DEMOLEDOR ---
function SV_GetSiegeTotal takes integer pid returns real
    return SV_GetSiegePhase(pid, 0) + SV_GetSiegePhase(pid, 1) + SV_GetSiegePhase(pid, 2) + SV_GetSiegePhase(pid, 3)
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
    local integer phase
    local real candidatePhase
    local real currentPhase

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
        // F0 > F1 > F2 > F3: la primera fase que difiere decide.
        set phase = 0
        loop
            exitwhen phase > 3
            set candidatePhase = SV_GetSiegePhase(candidate, phase)
            set currentPhase = SV_GetSiegePhase(current, phase)
            if candidatePhase > currentPhase + SV_SIEGE_EPSILON then
                return true
            elseif currentPhase > candidatePhase + SV_SIEGE_EPSILON then
                return false
            endif
            set phase = phase + 1
        endloop
    endif

    // Solo lectura de la estadistica existente: Demoledor no escribe ni limpia
    // ninguna clave de udg_MB_Hash.
    set candidateKills = SV_StatInt(candidate, 1, 711)
    set currentKills = SV_StatInt(current, 1, 711)
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
// Los ejercitos de creeps (Core_Ejercitos.j) no ganan ni pierden: son
// neutrales ocultos. Los slots 10 y 11 son de observadores: reciben el mismo
// resumen, sin victoria ni derrota.
function SV_ExecuteResult takes nothing returns nothing
    local integer i = 0
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
    else
        // Orcos pierden, Humanos ganan
        call SV_CustomVictoryBJ(Player(0), SV_VictoryText)
        call SV_CustomVictoryBJ(Player(1), SV_VictoryText)
        call SV_CustomVictoryBJ(Player(2), SV_VictoryText)
        call SV_CustomVictoryBJ(Player(3), SV_VictoryText)
        call SV_CustomVictoryBJ(Player(4), SV_VictoryText)
        call CustomDefeatBJ(Player(5), SV_DefeatText)
        call CustomDefeatBJ(Player(6), SV_DefeatText)
        call CustomDefeatBJ(Player(7), SV_DefeatText)
        call CustomDefeatBJ(Player(8), SV_DefeatText)
        call CustomDefeatBJ(Player(9), SV_DefeatText)
    endif
    loop
        exitwhen i > 11
        if (Observadores_Es(Player(i))) then
            call SV_CustomVictoryDialog(Player(i), "|cffFFCC00FIN DE LA PARTIDA|r|n" + SV_ReportText)
        endif
        set i = i + 1
    endloop
endfunction

// --- Construye el resumen de fin de partida (resultado + Top 3 + premios). ---
// Ordena la información en datos generales, clasificación y distinciones.
// Usa |n para llevar cada línea dentro del diálogo.
function SV_BuildReport takes nothing returns string
    local integer i
    local integer rank
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
    if (ModoPartida_EsRapido()) then
        set report = report + "|n|cffC0C0C0Modo:|r |cffFFCC00Rápido (" + I2S(udg_Config_Cantidad_Oro) + " oro)|r"
    else
        set report = report + "|n|cffC0C0C0Modo:|r |cffFFCC00Normal (" + I2S(udg_Config_Cantidad_Oro) + " oro)|r"
    endif
    if (SV_CloseFinish != "") then
        set report = report + "|n" + SV_CloseFinish
    endif

    // --- TOP 3 POR PUNTAJE (selección por pasadas) ---
    if (SV_PlayerCount >= 1) then
        set report = report + "|n|n|cffFFCC00CLASIFICACIÓN|r"
        set rank = 1
        loop
            exitwhen rank > 3
            set bestIdx = -1
            set i = 0
            loop
                exitwhen i > 9
                if (SV_HasRow[i] and not SV_Used[i]) then
                    if (bestIdx == -1) then
                        set bestIdx = i
                    elseif (SV_IsBetterRank(i, bestIdx)) then
                        set bestIdx = i
                    endif
                endif
                set i = i + 1
            endloop
            exitwhen bestIdx == -1
            set SV_Used[bestIdx] = true
            set report = report + "|n|cffFFCC00" + I2S(rank) + ".|r " + SV_GetColor(Player(bestIdx)) + SV_NameOf(bestIdx) + "|r  |cffFFFFFF" + I2S(SV_Score[bestIdx]) + " pts|r"
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
    //    Score = Kills*5 + Asist*3 - Muertes*4 + SV_GoldPoints(OroDonadoNeto).
    //    Solo jugadores con fila en la tabla (row > 0) participan; los que
    //    abandonaron también, con sus estadísticas congeladas (SV_StatInt/Real).
    loop
        exitwhen i > 9
        set SV_Used[i] = false
        set row = LoadInteger(udg_MB_Hash, i, 0)
        if (row > 0) then
            set kills   = SV_StatInt(i, 1, 711)
            set deaths  = SV_StatInt(i, 2, 712)
            set assists = SV_StatInt(i, 4, 713)
            // Oro donado NETO = enviado(701) - recibido(702), con piso 0: el oro
            // que circula entre aliados se cancela solo (anti ping-pong/círculos);
            // únicamente puntúa regalar más de lo que te regalaron.
            set goldDon = SV_StatInt(i, 701, 714) - SV_StatInt(i, 702, 715)
            if (goldDon < 0) then
                set goldDon = 0
            endif
            set score   = (kills * 5) + (assists * 3) - (deaths * 4) + SV_GoldPoints(goldDon)
            set dmgVal  = SV_StatReal(i, 700, 716)
            set SV_Score[i] = score
            set SV_Deaths[i] = deaths
            set SV_HeroDmg[i] = dmgVal
            set SV_HasRow[i] = true
            set playerCount = playerCount + 1

            // Premio "Cazahéroes": mayor daño total a héroes (key 700).
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
            // Premio "Donador": más oro donado NETO (701 - 702, ya clampeado).
            if (goldDon > bestGold) then
                set bestGold = goldDon
                set goldId = i
            endif
            // Premio "Soporte": más asistencias.
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
    set SV_CloseFinish = SV_BuildCloseFinish()
    call SV_ComputeRanks()
    set SV_ReportText  = SV_BuildReport()
    set SV_VictoryText = "|cff20C000VICTORIA!|r|n" + SV_ReportText
    set SV_DefeatText  = "|cffFF2020DERROTA|r|n" + SV_ReportText

    // 8. Ejecutar el resultado y mostrar a la izquierda el resumen personal
    //    de cada jugador. En single debe imprimirse antes del diálogo porque
    //    este pausa la partida; en multi, después de limpiar los avisos nativos.
    //    ExecuteFunc lo corre en otro hilo: si el resumen fallara, el
    //    resultado de la partida se ejecuta igual.
    if bj_isSinglePlayer then
        call ExecuteFunc("SistemaResumen_ShowFinal")
        call SV_ExecuteResult()
    else
        call SV_ExecuteResult()
        // Quitar únicamente los avisos nativos "X salió victorioso/derrotado".
        // ClearTextMessages no afecta los cuadros Dialog recién mostrados.
        call ClearTextMessages()
        call ExecuteFunc("SistemaResumen_ShowFinal")
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
