//===========================================================================
// SISTEMA: RESUMEN PERSONAL DE FIN DE PARTIDA (lado izquierdo)
//===========================================================================
// Reemplaza al antiguo panel "ÚLTIMAS 10 BAJAS". Al terminar la partida hay
// tres zonas: el centro (Sistema_Victoria.j) y la tabla de la derecha son
// iguales para todos; la izquierda es DISTINTA para cada jugador y SOLO trae
// datos suyos. Así cada uno tiene su propia foto para mandar al grupo.
//
// CÓMO SE VE (bloques separados por UNA línea en blanco; el del medio solo
// aparece si tuviste asistencias):
//
//   ========= TU RESUMEN =========
//   Tú: magio                            1) tus datos
//   Puesto: 6 de 10 (21 pts)
//   Mejor racha: 5 (la cortó granadero)
//
//   Soporte Controlador                  2) tus asistencias: con título de
//   (12 asistencias)                        soporte, o "Asistencias: 8" sin él
//
//   Tú 4 - 1 frijolito (tu hijo)         3) tus duelos: uno por enemigo, máx. 5
//   Tú 0 - 4 granadero (tu papá)
//   Tú 3 - 3 jade (tu rival)
//   Tú 2 - 0 tank 20
//   Tú 1 - 1 plaga
//   ===============================      cierre: sin él parece cortado
//
// ALTO: peor caso 14 líneas (con asistencias y 5 duelos), ya visto completo
// en juego. Ancho: ninguna línea pasa de ~41 caracteres visibles con nombres
// de 15 letras, el mismo ancho del panel anterior.
//
// COLORES: gris = etiquetas (como el centro), dorado = cifras y el tipo de
// soporte, blanco = "Tú" y lo que va entre paréntesis, y el color de cada
// jugador SOLO en su nombre.
//
// REGLAS (los números están en la ZONA EDITABLE):
//   - SOPORTE: títulos ÚNICOS por partida, uno por tipo de asistencia (Daño =
//     Ofensivo, Control = Controlador, Bloqueo = Bloqueador, Apoyo =
//     Protector): máximo 4 títulos y máximo 1 por jugador. Cada título es de
//     quien hizo MÁS asistencias DE ESE TIPO. Reparto (ver AssignTitles):
//       1) Ganadores claros (sin empate en la cantidad) reciben su título.
//          Si uno gana claro dos tipos, se queda el de más asistencias
//          (empate: el menos común) y el otro se reevalúa sin él.
//       2) Empates: se descarta a quien ya tiene título; entre los que
//          quedan gana el de más asistencias totales (luego, mejor puesto).
//       Se repite hasta que no quede nadie: si todos los empatados ya tenían
//       título, se lleva el siguiente con más asistencias de ese tipo.
//     Un tipo que nadie usó no se entrega. Quien abandonó no compite (su
//     slot lo juega la IA).
//     Con título: "Soporte X" y debajo "(N asistencias)". Con asistencias pero
//     sin título: solo "Asistencias: N". Sin asistencias: el bloque no aparece.
//     N es el total de todos los tipos (el mismo número de la columna A).
//   - DUELO: kills entre dos enemigos, con la misma regla que la columna K de
//     la tabla (dueño de la unidad asesina; víctima héroe que no sea ilusión).
//   - ABANDONO: desde que alguien sale (foto 710 de Sistema_Voto.j), las kills
//     donde participa su slot ya no cuentan: la IA sustituta no hereda ni
//     arruina sus duelos (igual que su puntaje se congela). Por eso, si hubo
//     abandonos, los duelos pueden sumar menos que la columna K.
//   - tu hijo: lo mataste >= 3 veces y le sacas >= 2. tu papá: al revés.
//     tu rival: >= 2 kills cada uno y <= 1 de diferencia (el más peleado).
//     Cada marca sale una sola vez; primero los duelos marcados y luego el
//     resto, por kills entre ustedes. Nunca se muestra un 0-0.
//   - MEJOR RACHA: récord de Sistema_Kills.j. Desde 3 dice cómo terminó.
//   - PUESTO: SV_Rank de Sistema_Victoria.j (mismos desempates que el podio).
//
// ENCABEZADO Y CIERRE: medidos en una captura del juego, el encabezado ocupa
// 468 px y cada "=" avanza 15 px, así que el cierre lleva 31 "=" (463 px). Si
// se cambia el texto del encabezado, volver a medir.
//
// DEPENDENCIAS (solo globales: esta library compila arriba de todo y no llama
// funciones de los triggers, así no depende del orden de los triggers):
//   - tabla.j: udg_MB_Hash (key 5 = nombre, key 710 = abandonó),
//     MB_AssistByType y MB_ASIST_* (asistencias por tipo)
//   - Sistema_Kills.j: KS_BestStreak, KS_BestStreakEnd, KS_END_*
//   - Sistema_Victoria.j: SV_HasRow, SV_Rank, SV_Score, SV_PlayerCount.
//     La invoca con ExecuteFunc("SistemaResumen_ShowFinal").
//
// DESYNC / REPETICIONES: cada texto se arma en todas las PCs y se envía a su
// slot con DisplayTimedTextToPlayer (mismo método que KF_DisplayTimedTextToAll):
// nada se calcula en local, y en una repetición se ve el del jugador observado.
//===========================================================================
library SistemaResumen initializer Init

    globals
        // --- ZONA EDITABLE ---
        private constant integer SON_MIN         = 3 // tu hijo / tu papá: kills mínimas...
        private constant integer SON_LEAD        = 2 // ...y ventaja mínima
        private constant integer RIVAL_MIN       = 2 // tu rival: kills mínimas de cada uno...
        private constant integer RIVAL_MAX_GAP   = 1 // ...y diferencia máxima
        private constant integer STREAK_SHOW_END = 3 // desde esta racha se dice cómo terminó
        private constant string  HEADER = "|cffFFCC00========= TU RESUMEN =========|r"
        private constant string  FOOTER = "|cffFFCC00===============================|r"

        // --- INTERNOS ---
        private constant real    DURATION = 99999.0
        private constant string  C_LABEL  = "|cffC0C0C0" // etiquetas (igual que el centro)
        private constant string  C_VALUE  = "|cffFFCC00" // cifras
        private constant string  C_TEXT   = "|cffFFFFFF" // paréntesis y "Tú"
        private integer array Kills     // [asesino * 10 + víctima], jugadores 0-9 enemigos
        private integer array TitleOf   // título de soporte por jugador: MB_ASIST_* o -1
        private boolean array TypeTaken // por tipo MB_ASIST_*: su título ya tiene dueño
        private integer array Cand      // por tipo: mejor candidato sin título en esta vuelta, o -1
        private boolean array TopTied   // por tipo: ese candidato empató en la cantidad (no es claro)
    endglobals

    // Kills de a sobre b.
    private function KillsOf takes integer a, integer b returns integer
        return Kills[a * 10 + b]
    endfunction

    // Paleta de tabla.j (MB_GetColor). Se replica porque esta library compila
    // ANTES que los triggers y no puede llamar a sus funciones.
    private function ColorOf takes integer pid returns string
        if (pid == 0) then
            return "|cffd02222" // Rojo
        elseif (pid == 1) then
            return "|cff2254dd" // Azul
        elseif (pid == 2) then
            return "|cff1CE6B9" // Teal
        elseif (pid == 3) then
            return "|cff7134c2" // Morado
        elseif (pid == 4) then
            return "|cffFFFC00" // Amarillo
        elseif (pid == 5) then
            return "|cffFE8A0E" // Naranja
        elseif (pid == 6) then
            return "|cff20C000" // Verde
        elseif (pid == 7) then
            return "|cffE55BB0" // Rosa
        elseif (pid == 8) then
            return "|cff959697" // Gris
        elseif (pid == 9) then
            return "|cff7EBFF1" // Celeste
        endif
        return "|cffFFFFFF"
    endfunction

    // Nombre guardado por tabla.j (key 5), con el nativo de respaldo (como SV_NameOf).
    private function ColoredName takes integer pid returns string
        local string s = LoadStr(udg_MB_Hash, pid, 5)
        if (s == null or s == "") then
            set s = GetPlayerName(Player(pid))
        endif
        return ColorOf(pid) + s + "|r"
    endfunction

    // Marcador estilo fútbol: "4 - 1".
    private function Score takes integer a, integer b returns string
        return C_VALUE + I2S(a) + " - " + I2S(b) + "|r"
    endfunction

    // --- "Puesto: 6 de 10 (21 pts)" ---
    private function BuildRankLine takes integer p returns string
        return C_LABEL + "Puesto:|r " + C_VALUE + I2S(SV_Rank[p]) + " de " + I2S(SV_PlayerCount) + "|r " + C_TEXT + "(" + I2S(SV_Score[p]) + " pts)|r"
    endfunction

    // --- "Mejor racha: 5 (la cortó granadero)" ---
    // Desde STREAK_SHOW_END dice cómo terminó. KS_END_OTHER (aliado, suicidio,
    // IA sustituta) deja solo el número.
    private function BuildStreakLine takes integer p returns string
        local integer best = KS_BestStreak[p]
        local integer endBy = KS_BestStreakEnd[p]
        local string s = C_LABEL + "Mejor racha:|r " + C_VALUE + I2S(best) + "|r"
        if (best < STREAK_SHOW_END) then
            return s
        endif
        if (endBy >= 0 and endBy <= 9) then
            return s + C_TEXT + " (la cortó|r " + ColoredName(endBy) + C_TEXT + ")|r"
        elseif (endBy == KS_END_TOWER) then
            return s + C_TEXT + " (la cortó una torre)|r"
        elseif (endBy == KS_END_CREEPS) then
            return s + C_TEXT + " (la cortaron los creeps)|r"
        elseif (endBy == KS_END_ALIVE) then
            return s + C_TEXT + " (nadie la cortó)|r"
        endif
        return s
    endfunction

    // --- ASISTENCIAS POR TIPO (contadas en tabla.j) ---
    private function AssistsOf takes integer p, integer tipo returns integer
        return MB_AssistByType[p * 4 + tipo]
    endfunction

    private function TotalAssists takes integer p returns integer
        return AssistsOf(p, MB_ASIST_DANO) + AssistsOf(p, MB_ASIST_CONTROL) + AssistsOf(p, MB_ASIST_BLOQUEO) + AssistsOf(p, MB_ASIST_APOYO)
    endfunction

    // Orden de desempate entre tipos de un mismo jugador: el menos común primero.
    private function TypeByRarity takes integer order returns integer
        if (order == 0) then
            return MB_ASIST_BLOQUEO
        elseif (order == 1) then
            return MB_ASIST_APOYO
        elseif (order == 2) then
            return MB_ASIST_CONTROL
        endif
        return MB_ASIST_DANO
    endfunction

    private function TitleName takes integer tipo returns string
        if (tipo == MB_ASIST_BLOQUEO) then
            return "Bloqueador"
        elseif (tipo == MB_ASIST_APOYO) then
            return "Protector"
        elseif (tipo == MB_ASIST_CONTROL) then
            return "Controlador"
        endif
        return "Ofensivo"
    endfunction

    // Puede competir por un título: tiene fila, aún no tiene título y no
    // abandonó (su slot lo juega la IA sustituta).
    private function CanCompete takes integer p returns boolean
        return SV_HasRow[p] and TitleOf[p] < 0 and not LoadBoolean(udg_MB_Hash, p, 710)
    endfunction

    // Mejor candidato sin título para el tipo: más asistencias de ese tipo;
    // en empate, más asistencias totales y luego mejor puesto. Deja en
    // TopTied[tipo] si la cantidad estaba empatada (ganador no claro).
    // -1 si nadie que compita tiene asistencias de ese tipo.
    private function BestCandidate takes integer tipo returns integer
        local integer p = 0
        local integer best = -1
        local integer n
        set TopTied[tipo] = false
        loop
            exitwhen p > 9
            if (CanCompete(p)) then
                set n = AssistsOf(p, tipo)
                if (n > 0) then
                    if (best < 0 or n > AssistsOf(best, tipo)) then
                        set best = p
                        set TopTied[tipo] = false
                    elseif (n == AssistsOf(best, tipo)) then
                        set TopTied[tipo] = true
                        if (TotalAssists(p) > TotalAssists(best) or (TotalAssists(p) == TotalAssists(best) and SV_Rank[p] < SV_Rank[best])) then
                            set best = p
                        endif
                    endif
                endif
            endif
            set p = p + 1
        endloop
        return best
    endfunction

    // De los tipos que p gana CLARO en esta vuelta, el de más asistencias
    // (empate: el menos común, porque se recorre por rareza). -1 si ninguno.
    private function BestClearWin takes integer p returns integer
        local integer order = 0
        local integer tipo
        local integer best = -1
        loop
            exitwhen order > 3
            set tipo = TypeByRarity(order)
            if (Cand[tipo] == p and not TopTied[tipo]) then
                if (best < 0 or AssistsOf(p, tipo) > AssistsOf(p, best)) then
                    set best = tipo
                endif
            endif
            set order = order + 1
        endloop
        return best
    endfunction

    private function GiveTitle takes integer p, integer tipo returns nothing
        set TitleOf[p] = tipo
        set TypeTaken[tipo] = true
    endfunction

    // --- TÍTULOS DE SOPORTE: uno por tipo y uno por jugador (máx. 4) ---
    // Por vueltas. En cada una se busca el mejor candidato sin título de cada
    // tipo libre:
    //   1) Si hay ganadores claros, reciben su título (uno por jugador: el de
    //      su tipo con más asistencias) y se pasa a la vuelta siguiente.
    //   2) Si solo quedan empates, se resuelve UNO (el de mayor cantidad;
    //      empate: el tipo menos común): gana el de más asistencias totales.
    //      Volver a la vuelta 1 descarta a quien ya tiene título.
    // Termina cuando ningún tipo libre tiene candidatos.
    private function AssignTitles takes nothing returns nothing
        local integer p = 0
        local integer tipo
        local integer order
        local integer tieType
        local boolean assigned
        loop
            exitwhen p > 9
            set TitleOf[p] = -1
            set p = p + 1
        endloop
        set tipo = 0
        loop
            exitwhen tipo > 3
            set TypeTaken[tipo] = false
            set tipo = tipo + 1
        endloop

        loop
            set tipo = 0
            loop
                exitwhen tipo > 3
                set Cand[tipo] = -1
                if (not TypeTaken[tipo]) then
                    set Cand[tipo] = BestCandidate(tipo)
                endif
                set tipo = tipo + 1
            endloop

            // 1) Ganadores claros.
            set assigned = false
            set tipo = 0
            loop
                exitwhen tipo > 3
                set p = Cand[tipo]
                if (p >= 0 and not TopTied[tipo] and TitleOf[p] < 0 and BestClearWin(p) == tipo) then
                    call GiveTitle(p, tipo)
                    set assigned = true
                endif
                set tipo = tipo + 1
            endloop

            // 2) Solo empates: resolver el de mayor cantidad.
            if (not assigned) then
                set tieType = -1
                set order = 0
                loop
                    exitwhen order > 3
                    set tipo = TypeByRarity(order)
                    if (Cand[tipo] >= 0 and TopTied[tipo]) then
                        if (tieType < 0 or AssistsOf(Cand[tipo], tipo) > AssistsOf(Cand[tieType], tieType)) then
                            set tieType = tipo
                        endif
                    endif
                    set order = order + 1
                endloop
                exitwhen tieType < 0
                call GiveTitle(Cand[tieType], tieType)
            endif
        endloop
    endfunction

    // --- BLOQUE DE ASISTENCIAS ---
    // Con título: "Soporte Controlador" + "(12 asistencias)".
    // Sin título:  "Asistencias: 8". Sin asistencias: "" (no aparece).
    private function BuildSupport takes integer p returns string
        local integer total = TotalAssists(p)
        local string count
        if (total <= 0) then
            return ""
        endif
        if (TitleOf[p] < 0) then
            return C_LABEL + "Asistencias:|r " + C_VALUE + I2S(total) + "|r"
        endif
        if (total == 1) then
            set count = "(1 asistencia)"
        else
            set count = "(" + I2S(total) + " asistencias)"
        endif
        return C_LABEL + "Soporte|r " + C_VALUE + TitleName(TitleOf[p]) + "|r\n" + C_TEXT + count + "|r"
    endfunction

    // --- "Tú 4 - 1 frijolito (tu hijo)" ---
    private function DuelLine takes integer p, integer j, string tag returns string
        local string s = C_TEXT + "Tú|r " + Score(KillsOf(p, j), KillsOf(j, p)) + " " + ColoredName(j)
        if (tag != "") then
            set s = s + " " + C_TEXT + "(" + tag + ")|r"
        endif
        return s
    endfunction

    private function AddLine takes string text, string line returns string
        if (text == "") then
            return line
        endif
        return text + "\n" + line
    endfunction

    // --- DUELOS DEL JUGADOR p (uno por enemigo con al menos una kill) ---
    // Primero las marcas (tu hijo, tu papá, tu rival), luego el resto con más
    // kills entre ustedes primero (a igualdad, más kills tuyas; luego slot).
    private function BuildDuels takes integer p returns string
        local boolean array used
        local integer j = 0
        local integer mine
        local integer theirs
        local integer gap
        local integer son = -1
        local integer sonMine = 0
        local integer sonGap = 0
        local integer dad = -1
        local integer dadTheirs = 0
        local integer dadGap = 0
        local integer rival = -1
        local integer rivalTotal = 0
        local integer rivalGap = 0
        local integer best
        local integer bestTotal = 0
        local integer bestMine = 0
        local string s = ""

        // Marcas: la más clara de cada una (a igualdad total, el primer slot).
        loop
            exitwhen j > 9
            set mine = KillsOf(p, j)
            set theirs = KillsOf(j, p)
            set gap = mine - theirs
            if (mine >= SON_MIN and gap >= SON_LEAD) then
                if (son < 0 or gap > sonGap or (gap == sonGap and mine > sonMine)) then
                    set son = j
                    set sonGap = gap
                    set sonMine = mine
                endif
            elseif (theirs >= SON_MIN and -gap >= SON_LEAD) then
                if (dad < 0 or -gap > dadGap or (-gap == dadGap and theirs > dadTheirs)) then
                    set dad = j
                    set dadGap = -gap
                    set dadTheirs = theirs
                endif
            elseif (mine >= RIVAL_MIN and theirs >= RIVAL_MIN and gap <= RIVAL_MAX_GAP and -gap <= RIVAL_MAX_GAP) then
                if (gap < 0) then
                    set gap = -gap
                endif
                if (rival < 0 or mine + theirs > rivalTotal or (mine + theirs == rivalTotal and gap < rivalGap)) then
                    set rival = j
                    set rivalTotal = mine + theirs
                    set rivalGap = gap
                endif
            endif
            set j = j + 1
        endloop

        if (son >= 0) then
            set used[son] = true
            set s = AddLine(s, DuelLine(p, son, "tu hijo"))
        endif
        if (dad >= 0) then
            set used[dad] = true
            set s = AddLine(s, DuelLine(p, dad, "tu papá"))
        endif
        if (rival >= 0) then
            set used[rival] = true
            set s = AddLine(s, DuelLine(p, rival, "tu rival"))
        endif

        // Resto por selección: cada pasada agrega el duelo pendiente con más kills.
        loop
            set best = -1
            set j = 0
            loop
                exitwhen j > 9
                if (not used[j]) then
                    set mine = KillsOf(p, j)
                    set theirs = KillsOf(j, p)
                    if (mine + theirs > 0) then
                        if (best < 0 or mine + theirs > bestTotal or (mine + theirs == bestTotal and mine > bestMine)) then
                            set best = j
                            set bestTotal = mine + theirs
                            set bestMine = mine
                        endif
                    endif
                endif
                set j = j + 1
            endloop
            exitwhen best < 0
            set used[best] = true
            set s = AddLine(s, DuelLine(p, best, ""))
        endloop
        return s
    endfunction

    // --- ENTRADA PÚBLICA: mostrar a cada jugador su resumen ---
    // La llama Sistema_Victoria.j (ExecuteFunc) DESPUÉS de calcular puntajes y
    // puestos. Solo para jugadores con fila en la tabla (SV_HasRow).
    // Los bloques se separan con una línea en blanco que lleva un espacio, por
    // si el motor colapsa las líneas vacías.
    public function ShowFinal takes nothing returns nothing
        local string support
        local string duels
        local string s
        local integer p = 0
        call AssignTitles()
        loop
            exitwhen p > 9
            if (SV_HasRow[p]) then
                set s = HEADER
                set s = s + "\n" + C_LABEL + "Tú:|r " + ColoredName(p)
                set s = s + "\n" + BuildRankLine(p)
                set s = s + "\n" + BuildStreakLine(p)
                set support = BuildSupport(p)
                if (support != "") then
                    set s = s + "\n \n" + support
                endif
                set duels = BuildDuels(p)
                if (duels != "") then
                    set s = s + "\n \n" + duels
                endif
                set s = s + "\n" + FOOTER
                call DisplayTimedTextToPlayer(Player(p), 0, 0, DURATION, s)
            endif
            set p = p + 1
        endloop
    endfunction

    // --- REGISTRO DE DUELOS: misma regla que la columna K de tabla.j ---
    private function OnDeath takes nothing returns nothing
        local unit victim = GetDyingUnit()
        local unit killer = GetKillingUnit()
        local integer idK
        local integer idV
        if (killer != null and IsUnitType(victim, UNIT_TYPE_HERO) and not IsUnitIllusion(victim)) then
            set idK = GetPlayerId(GetOwningPlayer(killer))
            set idV = GetPlayerId(GetOwningPlayer(victim))
            if (idK >= 0 and idK <= 9 and idV >= 0 and idV <= 9 and IsPlayerEnemy(Player(idK), Player(idV))) then
                // Abandono: lo que haga la IA sustituta no entra en los duelos.
                if (not LoadBoolean(udg_MB_Hash, idK, 710) and not LoadBoolean(udg_MB_Hash, idV, 710)) then
                    set Kills[idK * 10 + idV] = Kills[idK * 10 + idV] + 1
                endif
            endif
        endif
        set victim = null
        set killer = null
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH)
        call TriggerAddAction(t, function OnDeath)
        set t = null
    endfunction

endlibrary
