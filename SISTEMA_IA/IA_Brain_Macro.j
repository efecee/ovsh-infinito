library IABrainMacro requires IAUtils

    globals
        // Coordenadas de las BASES DE CURACIÓN (Top y Bot)
        real HUM_BASE_TOP_X
        real HUM_BASE_TOP_Y
        real HUM_BASE_BOT_X
        real HUM_BASE_BOT_Y
        
        real ORC_BASE_TOP_X
        real ORC_BASE_TOP_Y
        real ORC_BASE_BOT_X
        real ORC_BASE_BOT_Y
        
        // Coordenadas de los Castillos (Para atacar al final)
        real CASTLE_HUM_X
        real CASTLE_HUM_Y
        real CASTLE_ORC_X
        real CASTLE_ORC_Y
    endglobals

    // Inicializa leyendo TUS REGIONES
    public function InitMacro takes nothing returns nothing
        // 1. Configurar Bases de Curación HUMANAS
        set HUM_BASE_TOP_X = GetRectCenterX(gg_rct_Base_Hum_Top)
        set HUM_BASE_TOP_Y = GetRectCenterY(gg_rct_Base_Hum_Top)
        
        set HUM_BASE_BOT_X = GetRectCenterX(gg_rct_Base_Hum_Bot)
        set HUM_BASE_BOT_Y = GetRectCenterY(gg_rct_Base_Hum_Bot)
        
        // 2. Configurar Bases de Curación ORCAS
        set ORC_BASE_TOP_X = GetRectCenterX(gg_rct_Base_Orc_Top)
        set ORC_BASE_TOP_Y = GetRectCenterY(gg_rct_Base_Orc_Top)
        
        set ORC_BASE_BOT_X = GetRectCenterX(gg_rct_Base_Orc_Bot)
        set ORC_BASE_BOT_Y = GetRectCenterY(gg_rct_Base_Orc_Bot)

        // 3. Configurar Castillos (Objetivo Final)
        set CASTLE_HUM_X = GetRectCenterX(gg_rct_Castillo_Hum)
        set CASTLE_HUM_Y = GetRectCenterY(gg_rct_Castillo_Hum)
        set CASTLE_ORC_X = GetRectCenterX(gg_rct_Castillo_Orc)
        set CASTLE_ORC_Y = GetRectCenterY(gg_rct_Castillo_Orc)
    endfunction

    // --- LÓGICA DE INTELIGENCIA ESPACIAL ---
    
    // Función privada auxiliar para calcular distancia cuadrada (más rápido para CPU)
    private function GetDistSq takes real x1, real y1, real x2, real y2 returns real
        return (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1)
    endfunction

    // Obtener la Coordenada X de la base de curación más cercana
    public function GetClosestHomeX takes unit bot returns real
        local real botX = GetUnitX(bot)
        local real botY = GetUnitY(bot)
        local real distTop
        local real distBot
        
        // Si soy aliado de Humanos (Jugador 0-4)
        if IsPlayerAlly(GetOwningPlayer(bot), Player(0)) then
            set distTop = GetDistSq(botX, botY, HUM_BASE_TOP_X, HUM_BASE_TOP_Y)
            set distBot = GetDistSq(botX, botY, HUM_BASE_BOT_X, HUM_BASE_BOT_Y)
            
            if distTop < distBot then
                return HUM_BASE_TOP_X
            else
                return HUM_BASE_BOT_X
            endif
        else
            // Soy Orco
            set distTop = GetDistSq(botX, botY, ORC_BASE_TOP_X, ORC_BASE_TOP_Y)
            set distBot = GetDistSq(botX, botY, ORC_BASE_BOT_X, ORC_BASE_BOT_Y)
            
            if distTop < distBot then
                return ORC_BASE_TOP_X
            else
                return ORC_BASE_BOT_X
            endif
        endif
    endfunction

    // Obtener la Coordenada Y de la base de curación más cercana
    public function GetClosestHomeY takes unit bot returns real
        local real botX = GetUnitX(bot)
        local real botY = GetUnitY(bot)
        local real distTop
        local real distBot
        
        if IsPlayerAlly(GetOwningPlayer(bot), Player(0)) then
            set distTop = GetDistSq(botX, botY, HUM_BASE_TOP_X, HUM_BASE_TOP_Y)
            set distBot = GetDistSq(botX, botY, HUM_BASE_BOT_X, HUM_BASE_BOT_Y)
            
            if distTop < distBot then
                return HUM_BASE_TOP_Y
            else
                return HUM_BASE_BOT_Y
            endif
        else
            set distTop = GetDistSq(botX, botY, ORC_BASE_TOP_X, ORC_BASE_TOP_Y)
            set distBot = GetDistSq(botX, botY, ORC_BASE_BOT_X, ORC_BASE_BOT_Y)
            
            if distTop < distBot then
                return ORC_BASE_TOP_Y
            else
                return ORC_BASE_BOT_Y
            endif
        endif
    endfunction

    // --- FUNCIONES OFENSIVAS ---
    public function GetEnemyBaseX takes player p returns real
        if IsPlayerAlly(p, Player(0)) then
            return CASTLE_ORC_X
        else
            return CASTLE_HUM_X
        endif
    endfunction

    public function GetEnemyBaseY takes player p returns real
        if IsPlayerAlly(p, Player(0)) then
            return CASTLE_ORC_Y
        else
            return CASTLE_HUM_Y
        endif
    endfunction
    
    public function GetLaneTargetX takes integer lane, player p returns real
        // Si soy aliado de Humanos (Jugador 0-4), ataco bases Orcas
        if IsPlayerAlly(p, Player(0)) then
            if lane == 1 then
                return ORC_BASE_TOP_X // Atacar Top Orco
            else
                return ORC_BASE_BOT_X // Atacar Bot Orco
            endif
        else
            // Soy Orco, ataco bases Humanas
            if lane == 1 then
                return HUM_BASE_TOP_X // Atacar Top Humano
            else
                return HUM_BASE_BOT_X // Atacar Bot Humano
            endif
        endif
    endfunction

    public function GetLaneTargetY takes integer lane, player p returns real
        if IsPlayerAlly(p, Player(0)) then
            if lane == 1 then
                return ORC_BASE_TOP_Y
            else
                return ORC_BASE_BOT_Y
            endif
        else
            if lane == 1 then
                return HUM_BASE_TOP_Y
            else
                return HUM_BASE_BOT_Y
            endif
        endif
    endfunction

    // --- [RECUPERADO] ASIGNACIÓN DE LÍNEAS ---
    // Vital para decidir si el bot va a TOP o BOT al nacer
    public function AssignLane takes player p returns integer
        local integer id = GetPlayerId(p)
        // Lógica simple: Pares e Impares (o la lógica que prefieras)
        if (id - (id / 2) * 2) == 0 then
            return 1 // Top
        else
            return 2 // Bot
        endif
    endfunction

    // ============================================================
    //  NAVEGACIÓN DE EMPUJE POR FASES  +  KEEP-OUT DE FUENTE
    // ============================================================
    // Decide a QUÉ estructura enemiga avanzar respetando el orden de desbloqueo
    // del anti-backdoor (EXTRAS/Sistema_AntiBackdoor.j) y, al cambiar de carril,
    // rerutea por la base PROPIA en vez de atravesar la base enemiga.
    //
    // ACOPLAMIENTO: lee directamente los globales del anti-backdoor (grupos AB_*
    // y booleanos *_Open). Son globales de mapa (no de library), accesibles sin
    // 'requires'. Si el compilador se queja de "undeclared", mover el bloque
    // 'globals' del anti-backdoor a un trigger que compile antes, o a una library
    // base. Solo se LEEN en runtime (el loop corre mucho después del init de AB).
    //
    // Orden de objetivos (visto desde el carril asignado del bot):
    //   1) F3 propio  -> 2) F2 propio  -> 3) F3 otro (reruteo) ->
    //   4) F2 otro (reruteo) -> 5) F1 central -> 6) F0 (castillo/fortaleza)

    globals
        // Resultado de UpdateObjective (lectura vía getters):
        private real    bm_objX = 0.0
        private real    bm_objY = 0.0
        private boolean bm_objIsMove = false   // true => orden "move" (reruteo); false => "attack" (empuje)

        // Resultado de ResolveOwnDefense (línea de defensa PROPIA, carril pasivo):
        private real    bm_defX = 0.0
        private real    bm_defY = 0.0

        // Temporales del centroide:
        private real    bm_cx = 0.0
        private real    bm_cy = 0.0
        private real    acc_x = 0.0
        private real    acc_y = 0.0
        private integer acc_n = 0

        // Anticipación alrededor de la REGIÓN de fuente (gg_rct_Fuente*): frena al
        // bot ANTES de tocar la zona mortal. La región ya está dibujada al radio de
        // peligro de la torre; este margen es solo colchón de reacción. Reducir si
        // el bot se niega a atacar una torre legítima cercana a la fuente.
        private constant real FOUNTAIN_MARGIN = 256.0
    endglobals

    // --- Centroide de las unidades VIVAS de un grupo (no destructivo) ---
    private function AccumPos takes nothing returns nothing
        if not IsUnitType(GetEnumUnit(), UNIT_TYPE_DEAD) then
            set acc_x = acc_x + GetUnitX(GetEnumUnit())
            set acc_y = acc_y + GetUnitY(GetEnumUnit())
            set acc_n = acc_n + 1
        endif
    endfunction

    // Devuelve true si el grupo tiene >=1 unidad viva; deja el centroide en bm_cx/bm_cy.
    private function GroupCentroid takes group g returns boolean
        set acc_x = 0.0
        set acc_y = 0.0
        set acc_n = 0
        call ForGroup(g, function AccumPos)
        if acc_n == 0 then
            return false
        endif
        set bm_cx = acc_x / acc_n
        set bm_cy = acc_y / acc_n
        return true
    endfunction

    // Si el bot debe ir al carril CONTRARIO y aún está del lado equivocado,
    // sobrescribe el objetivo con la FUENTE PROPIA de ese carril (orden "move"),
    // forzando la U por la base propia en lugar de cruzar la base enemiga.
    private function ApplyRerouteIfNeeded takes unit botUnit, integer assignedLane returns nothing
        local boolean isHuman = IsPlayerAlly(GetOwningPlayer(botUnit), Player(0))
        local real botY = GetUnitY(botUnit)

        if assignedLane == 1 then
            // Mi carril es Top; el contrario es Bot (Y<0). ¿Sigo arriba?
            if botY > 0.0 then
                if isHuman then
                    set bm_objX = HUM_BASE_BOT_X
                    set bm_objY = HUM_BASE_BOT_Y
                else
                    set bm_objX = ORC_BASE_BOT_X
                    set bm_objY = ORC_BASE_BOT_Y
                endif
                set bm_objIsMove = true
            endif
        else
            // Mi carril es Bot; el contrario es Top (Y>0). ¿Sigo abajo?
            if botY < 0.0 then
                if isHuman then
                    set bm_objX = HUM_BASE_TOP_X
                    set bm_objY = HUM_BASE_TOP_Y
                else
                    set bm_objX = ORC_BASE_TOP_X
                    set bm_objY = ORC_BASE_TOP_Y
                endif
                set bm_objIsMove = true
            endif
        endif
    endfunction

    // Calcula el objetivo de empuje del bot. Devuelve false si no hay ninguna
    // estructura enemiga desbloqueada y viva (partida prácticamente ganada).
    // Resultado en bm_objX/bm_objY/bm_objIsMove (leer con los getters).
    public function UpdateObjective takes unit botUnit, integer assignedLane returns boolean
        local boolean isHuman = IsPlayerAlly(GetOwningPlayer(botUnit), Player(0))
        // Estructuras del ENEMIGO según mi facción y mi carril asignado:
        local group myF3
        local group myF2
        local boolean myF2Open
        local group otherF3
        local group otherF2
        local boolean otherF2Open
        local group cF1
        local boolean cF1Open
        local group cF0
        local boolean cF0Open

        set bm_objIsMove = false

        if isHuman then
            // Humano ataca estructuras ORCAS
            set cF1 = AB_ORC_F1
            set cF1Open = AB_ORC_F1_Open
            set cF0 = AB_ORC_F0
            set cF0Open = AB_ORC_F0_Open
            if assignedLane == 1 then
                set myF3 = AB_ORC_F3_TOP
                set myF2 = AB_ORC_F2_TOP
                set myF2Open = AB_ORC_F2Top_Open
                set otherF3 = AB_ORC_F3_BOT
                set otherF2 = AB_ORC_F2_BOT
                set otherF2Open = AB_ORC_F2Bot_Open
            else
                set myF3 = AB_ORC_F3_BOT
                set myF2 = AB_ORC_F2_BOT
                set myF2Open = AB_ORC_F2Bot_Open
                set otherF3 = AB_ORC_F3_TOP
                set otherF2 = AB_ORC_F2_TOP
                set otherF2Open = AB_ORC_F2Top_Open
            endif
        else
            // Orco ataca estructuras HUMANAS
            set cF1 = AB_HUM_F1
            set cF1Open = AB_HUM_F1_Open
            set cF0 = AB_HUM_F0
            set cF0Open = AB_HUM_F0_Open
            if assignedLane == 1 then
                set myF3 = AB_HUM_F3_TOP
                set myF2 = AB_HUM_F2_TOP
                set myF2Open = AB_HUM_F2Top_Open
                set otherF3 = AB_HUM_F3_BOT
                set otherF2 = AB_HUM_F2_BOT
                set otherF2Open = AB_HUM_F2Bot_Open
            else
                set myF3 = AB_HUM_F3_BOT
                set myF2 = AB_HUM_F2_BOT
                set myF2Open = AB_HUM_F2Bot_Open
                set otherF3 = AB_HUM_F3_TOP
                set otherF2 = AB_HUM_F2_TOP
                set otherF2Open = AB_HUM_F2Top_Open
            endif
        endif

        // 1) Mi carril: F3 (siempre vulnerable), luego F2 (si desbloqueada).
        if GroupCentroid(myF3) then
            set bm_objX = bm_cx
            set bm_objY = bm_cy
            return true
        endif
        if myF2Open and GroupCentroid(myF2) then
            set bm_objX = bm_cx
            set bm_objY = bm_cy
            return true
        endif

        // 2) Mi carril limpio -> carril contrario (reruteando por mi base).
        if GroupCentroid(otherF3) then
            set bm_objX = bm_cx
            set bm_objY = bm_cy
            call ApplyRerouteIfNeeded(botUnit, assignedLane)
            return true
        endif
        if otherF2Open and GroupCentroid(otherF2) then
            set bm_objX = bm_cx
            set bm_objY = bm_cy
            call ApplyRerouteIfNeeded(botUnit, assignedLane)
            return true
        endif

        // 3) Ambos carriles exteriores caídos -> empuje central (F1, luego F0).
        if cF1Open and GroupCentroid(cF1) then
            set bm_objX = bm_cx
            set bm_objY = bm_cy
            return true
        endif
        if cF0Open and GroupCentroid(cF0) then
            set bm_objX = bm_cx
            set bm_objY = bm_cy
            return true
        endif

        return false
    endfunction

    public function GetObjectiveX takes nothing returns real
        return bm_objX
    endfunction
    public function GetObjectiveY takes nothing returns real
        return bm_objY
    endfunction
    public function GetObjectiveIsMove takes nothing returns boolean
        return bm_objIsMove
    endfunction

    // --- FRENTE DE ASEDIO (profundidad permitida de caza) ---
    // Devuelve la X del centroide de la estructura ENEMIGA VIVA más adelantada,
    // siguiendo el MISMO orden de desbloqueo que UpdateObjective (F3 propio ->
    // F2 propio -> F3 otro -> F2 otro -> F1 -> F0), pero SIN el reruteo ni el
    // flag move/attack: solo la línea hasta donde ha progresado el asedio. Si no
    // queda ninguna estructura viva, devuelve la base enemiga (todo permitido).
    //
    // Uso previsto: medir/decidir "hasta dónde puede meterse el bot a cazar
    // héroes". La línea se ENCOGE/EXTIENDE sola con las fases (cuando cae F3, el
    // frente pasa a F2, etc.), porque lee las MISMAS estructuras vivas que el
    // anti-backdoor: cero coordenadas hardcodeadas, cero drift.
    //
    // NOTA: el bloque de selección de grupos por facción/carril está DUPLICADO a
    // propósito respecto a UpdateObjective (para no tocar esa función que ya
    // funciona). Si el veto de profundidad se vuelve definitivo, factorizar ambos
    // a un helper común.
    public function GetSiegeFrontX takes unit botUnit, integer assignedLane returns real
        local boolean isHuman = IsPlayerAlly(GetOwningPlayer(botUnit), Player(0))
        local group myF3
        local group myF2
        local boolean myF2Open
        local group otherF3
        local group otherF2
        local boolean otherF2Open
        local group cF1
        local boolean cF1Open
        local group cF0
        local boolean cF0Open

        if isHuman then
            set cF1 = AB_ORC_F1
            set cF1Open = AB_ORC_F1_Open
            set cF0 = AB_ORC_F0
            set cF0Open = AB_ORC_F0_Open
            if assignedLane == 1 then
                set myF3 = AB_ORC_F3_TOP
                set myF2 = AB_ORC_F2_TOP
                set myF2Open = AB_ORC_F2Top_Open
                set otherF3 = AB_ORC_F3_BOT
                set otherF2 = AB_ORC_F2_BOT
                set otherF2Open = AB_ORC_F2Bot_Open
            else
                set myF3 = AB_ORC_F3_BOT
                set myF2 = AB_ORC_F2_BOT
                set myF2Open = AB_ORC_F2Bot_Open
                set otherF3 = AB_ORC_F3_TOP
                set otherF2 = AB_ORC_F2_TOP
                set otherF2Open = AB_ORC_F2Top_Open
            endif
        else
            set cF1 = AB_HUM_F1
            set cF1Open = AB_HUM_F1_Open
            set cF0 = AB_HUM_F0
            set cF0Open = AB_HUM_F0_Open
            if assignedLane == 1 then
                set myF3 = AB_HUM_F3_TOP
                set myF2 = AB_HUM_F2_TOP
                set myF2Open = AB_HUM_F2Top_Open
                set otherF3 = AB_HUM_F3_BOT
                set otherF2 = AB_HUM_F2_BOT
                set otherF2Open = AB_HUM_F2Bot_Open
            else
                set myF3 = AB_HUM_F3_BOT
                set myF2 = AB_HUM_F2_BOT
                set myF2Open = AB_HUM_F2Bot_Open
                set otherF3 = AB_HUM_F3_TOP
                set otherF2 = AB_HUM_F2_TOP
                set otherF2Open = AB_HUM_F2Top_Open
            endif
        endif

        if GroupCentroid(myF3) then
            return bm_cx
        endif
        if myF2Open and GroupCentroid(myF2) then
            return bm_cx
        endif
        if GroupCentroid(otherF3) then
            return bm_cx
        endif
        if otherF2Open and GroupCentroid(otherF2) then
            return bm_cx
        endif
        if cF1Open and GroupCentroid(cF1) then
            return bm_cx
        endif
        if cF0Open and GroupCentroid(cF0) then
            return bm_cx
        endif
        return GetEnemyBaseX(GetOwningPlayer(botUnit))
    endfunction

    // --- LÍNEA DE DEFENSA PROPIA (espera del CARRIL PASIVO) ---
    // Centroide vivo de la Fase 3 PROPIA del carril del bot (sus torres más
    // adelantadas, hacia el centro). Lo usa el carril PASIVO (melee sin su 1ª
    // armadura) para esperar junto a sus torres cuando todavía no hay creeps
    // aliados en combate en su carril. Si la F3 propia ya cayó, cae a la F2
    // propia. Devuelve false si no queda ninguna estructura propia de esas dos
    // (late-game que el modo pasivo nunca alcanza). Resultado en bm_defX/bm_defY
    // (leer con GetOwnDefenseX/GetOwnDefenseY justo después).
    public function ResolveOwnDefense takes unit botUnit, integer lane returns boolean
        local boolean isHuman = IsPlayerAlly(GetOwningPlayer(botUnit), Player(0))
        local group f3
        local group f2
        if isHuman then
            if lane == 1 then
                set f3 = AB_HUM_F3_TOP
                set f2 = AB_HUM_F2_TOP
            else
                set f3 = AB_HUM_F3_BOT
                set f2 = AB_HUM_F2_BOT
            endif
        else
            if lane == 1 then
                set f3 = AB_ORC_F3_TOP
                set f2 = AB_ORC_F2_TOP
            else
                set f3 = AB_ORC_F3_BOT
                set f2 = AB_ORC_F2_BOT
            endif
        endif
        if GroupCentroid(f3) then
            set bm_defX = bm_cx
            set bm_defY = bm_cy
            return true
        endif
        if GroupCentroid(f2) then
            set bm_defX = bm_cx
            set bm_defY = bm_cy
            return true
        endif
        return false
    endfunction

    public function GetOwnDefenseX takes nothing returns real
        return bm_defX
    endfunction
    public function GetOwnDefenseY takes nothing returns real
        return bm_defY
    endfunction

    // ¿Debe estar ACTIVO el veto de profundidad de caza para el jugador p?
    // Regla (pedido explícito del usuario): solo MIENTRAS la F1 enemiga (anillo
    // del castillo/fortaleza) siga PROTEGIDA. En cuanto F1 se abre — lo que ocurre
    // al caer AMBAS F2 (ver AB_CheckHumF1/AB_CheckOrcF1) y vuelve vulnerable el
    // castillo/fortaleza — el veto se DESACTIVA por completo: ya rompiste las
    // defensas, el endgame es sitiar la base libremente.
    public function IsSiegeVetoActive takes player p returns boolean
        if IsPlayerAlly(p, Player(0)) then
            return not AB_ORC_F1_Open   // humano sitia base orca
        else
            return not AB_HUM_F1_Open   // orco sitia base humana
        endif
    endfunction

    // --- KEEP-OUT DE LA FUENTE ENEMIGA ---
    // Usa REGIONES dedicadas dibujadas en el Editor alrededor del radio mortal de
    // cada fuente (gg_rct_Fuente*), NO la base de curación. Así el veto cubre justo
    // donde la torre de la fuente mata, sin estorbar el carril.

    private function InRectMargin takes real x, real y, rect r returns boolean
        return x >= GetRectMinX(r) - FOUNTAIN_MARGIN and x <= GetRectMaxX(r) + FOUNTAIN_MARGIN and y >= GetRectMinY(r) - FOUNTAIN_MARGIN and y <= GetRectMaxY(r) + FOUNTAIN_MARGIN
    endfunction

    // Devuelve la rect de fuente ENEMIGA que contiene/roza (x,y) para el jugador p,
    // o null si ninguna. Punto único que decide qué cuenta como "zona de fuente".
    private function GetEnemyFountainRect takes real x, real y, player p returns rect
        if IsPlayerAlly(p, Player(0)) then
            if InRectMargin(x, y, gg_rct_FuenteOrcTop) then
                return gg_rct_FuenteOrcTop
            elseif InRectMargin(x, y, gg_rct_FuenteOrcBot) then
                return gg_rct_FuenteOrcBot
            endif
            return null
        endif
        if InRectMargin(x, y, gg_rct_FuenteHumTop) then
            return gg_rct_FuenteHumTop
        elseif InRectMargin(x, y, gg_rct_FuenteHumBot) then
            return gg_rct_FuenteHumBot
        endif
        return null
    endfunction

    // ¿La coordenada está dentro de la zona de una fuente ENEMIGA del jugador p?
    // (Lo usa Think() para NO targetear unidades dentro de la fuente.)
    public function IsInEnemyFountain takes real x, real y, player p returns boolean
        return GetEnemyFountainRect(x, y, p) != null
    endfunction

    // GUARDIA DE FUENTE: si 'botUnit' está dentro (o rozando, por el margen) de una
    // fuente enemiga, deja en bm_objX/bm_objY un PUNTO DE ESCAPE (radial, alejándose
    // del centro de esa fuente, lo bastante lejos para salir del margen) y devuelve
    // true. Si no está en ninguna fuente devuelve false y no toca el objetivo.
    // Se lee con GetObjectiveX/GetObjectiveY (válido solo inmediatamente después).
    public function GetFountainEscape takes unit botUnit returns boolean
        local player p = GetOwningPlayer(botUnit)
        local real x = GetUnitX(botUnit)
        local real y = GetUnitY(botUnit)
        local rect r = GetEnemyFountainRect(x, y, p)
        local real cx
        local real cy
        local real ang
        if r == null then
            return false
        endif
        set cx = GetRectCenterX(r)
        set cy = GetRectCenterY(r)
        set ang = Atan2(y - cy, x - cx)
        set bm_objX = cx + Cos(ang) * ((GetRectMaxX(r) - GetRectMinX(r)) * 0.5 + FOUNTAIN_MARGIN + 400.0)
        set bm_objY = cy + Sin(ang) * ((GetRectMaxY(r) - GetRectMinY(r)) * 0.5 + FOUNTAIN_MARGIN + 400.0)
        set r = null
        return true
    endfunction

    // ============================================================
    //  AVANCE AGRUPADO LATE-GAME (WAR PARTY)
    // ============================================================
    // Cuando una F1 (propia o enemiga) se abre, las creeperas de ese bando (las
    // barracas viven en F2) ya murieron: ese carril pierde la cobertura de
    // creeps y un héroe que avanza SOLO es presa del focus 5v5 (CC en cadena =
    // sin escape). Desde ese momento los bots dejan de avanzar en solitario:
    // se reúnen y empujan en grupo (la DECISIÓN vive en Think, IA_State_Laning;
    // aquí solo el sensado de equipo y el punto de reunión).
    //
    // DISPARADOR SIMÉTRICO y permanente (las *_F1_Open nunca se cierran):
    //   warParty = AB_ORC_F1_Open or AB_HUM_F1_Open
    //   * F1 ENEMIGA abierta  = rompimos sus 2 F2 => ellos defienden agrupados
    //     su última línea: empujar solo = regalarse. (Es además el instante
    //     exacto en que IsSiegeVetoActive se apaga: el war party lo reemplaza
    //     como freno espacial.)
    //   * F1 PROPIA abierta   = perdimos nuestras creeperas => carriles sin
    //     cobertura propia: defender/avanzar siempre en grupo.
    //
    // CACHE POR FACCIÓN (no por bot): una pasada sobre IACore_AllHeroes[] cada
    // WP_RECALC s; la primera consulta del tick paga el escaneo y el resto lee.
    // IACore_AllHeroes/IACore_AllHeroCount son GLOBALES (JassHelper iza todos
    // los bloques globals al tope del script, igual que las AB_*): legibles
    // sin 'requires' aunque IACore compile después.

    globals
        private constant real WP_RECALC = 0.30   // s entre recálculos del cache de equipo
        private real wp_lastCalc = -100.0

        // Censo por facción (Humanos / Orcos):
        private integer wp_humTotal = 0          // héroes del equipo (vivos o muertos: los muertos reviven)
        private integer wp_orcTotal = 0
        private integer wp_humAlive = 0
        private integer wp_orcAlive = 0
        private integer wp_humHumansAlive = 0    // jugadores REALES vivos (deciden el primer golpe)
        private integer wp_orcHumansAlive = 0
        // Carril mayoritario de los héroes vivos FUERA de las bases de curación
        // (un AFK parado en la fuente no cuenta) (1=Top, 2=Bot, 0=empate):
        private integer wp_humMajLane = 0
        private integer wp_orcMajLane = 0
        // Lado de REUNIÓN por facción (1=Top, 2=Bot, 0=sin historial): la
        // mayoría actual, o la última conocida si hay empate. Es el MISMO para
        // todo el equipo => nadie se reúne en un lado distinto al del resto.
        private integer wp_humRallySide = 0
        private integer wp_orcRallySide = 0

        // Resultado de ResolveRally (leer con los getters justo después):
        private real wp_rallyX = 0.0
        private real wp_rallyY = 0.0
    endglobals

    private function InRectXY takes real x, real y, rect r returns boolean
        return x >= GetRectMinX(r) and x <= GetRectMaxX(r) and y >= GetRectMinY(r) and y <= GetRectMaxY(r)
    endfunction

    // ¿(x,y) está dentro de una base de curación PROPIA de esa facción?
    private function InOwnHealingBase takes real x, real y, boolean isHuman returns boolean
        if isHuman then
            return InRectXY(x, y, gg_rct_Base_Hum_Top) or InRectXY(x, y, gg_rct_Base_Hum_Bot)
        endif
        return InRectXY(x, y, gg_rct_Base_Orc_Top) or InRectXY(x, y, gg_rct_Base_Orc_Bot)
    endfunction

    // ¿Modo agrupado activo? (mismo valor para ambos bandos: cualquiera de las
    // dos F1 abiertas marca el inicio del late game sin cobertura de creeps).
    public function IsWarPartyActive takes nothing returns boolean
        return AB_ORC_F1_Open or AB_HUM_F1_Open
    endfunction

    // Recalcula el censo de equipo (throttle interno). Llamar antes de leer los
    // getters de abajo; barato si ya se recalculó hace < WP_RECALC.
    public function UpdateWarPartyCache takes nothing returns nothing
        local real now = IAUtils_GetGameTime()
        local integer i = 0
        local unit h
        local boolean isHum
        local real hx
        local real hy
        local integer humTop = 0
        local integer humBot = 0
        local integer orcTop = 0
        local integer orcBot = 0

        if now - wp_lastCalc < WP_RECALC then
            return
        endif
        set wp_lastCalc = now

        set wp_humTotal = 0
        set wp_orcTotal = 0
        set wp_humAlive = 0
        set wp_orcAlive = 0
        set wp_humHumansAlive = 0
        set wp_orcHumansAlive = 0

        loop
            exitwhen i >= IACore_AllHeroCount
            set h = IACore_AllHeroes[i]
            if h != null and GetUnitTypeId(h) != 0 then
                set isHum = IsPlayerAlly(GetOwningPlayer(h), Player(0))
                if isHum then
                    set wp_humTotal = wp_humTotal + 1
                else
                    set wp_orcTotal = wp_orcTotal + 1
                endif
                if not IsUnitType(h, UNIT_TYPE_DEAD) then
                    set hx = GetUnitX(h)
                    set hy = GetUnitY(h)
                    if isHum then
                        set wp_humAlive = wp_humAlive + 1
                        // Humano = controller USER **y slot PLAYING**: el héroe de un
                        // LEAVER tomado por la IA (takeover) conserva controller USER
                        // (slot LEFT) y contaba como "humano vivo" => el HOLD FIRE
                        // esperaba el primer golpe de un humano que era un bot.
                        if GetPlayerController(GetOwningPlayer(h)) == MAP_CONTROL_USER and GetPlayerSlotState(GetOwningPlayer(h)) == PLAYER_SLOT_STATE_PLAYING then
                            set wp_humHumansAlive = wp_humHumansAlive + 1
                        endif
                        if not InOwnHealingBase(hx, hy, true) then
                            if hy >= 0.0 then
                                set humTop = humTop + 1
                            else
                                set humBot = humBot + 1
                            endif
                        endif
                    else
                        set wp_orcAlive = wp_orcAlive + 1
                        // Mismo criterio que arriba: humano = USER + PLAYING (excluye
                        // bots takeover de leavers).
                        if GetPlayerController(GetOwningPlayer(h)) == MAP_CONTROL_USER and GetPlayerSlotState(GetOwningPlayer(h)) == PLAYER_SLOT_STATE_PLAYING then
                            set wp_orcHumansAlive = wp_orcHumansAlive + 1
                        endif
                        if not InOwnHealingBase(hx, hy, false) then
                            if hy >= 0.0 then
                                set orcTop = orcTop + 1
                            else
                                set orcBot = orcBot + 1
                            endif
                        endif
                    endif
                endif
            endif
            set i = i + 1
        endloop

        if humTop > humBot then
            set wp_humMajLane = 1
        elseif humBot > humTop then
            set wp_humMajLane = 2
        else
            set wp_humMajLane = 0
        endif
        if orcTop > orcBot then
            set wp_orcMajLane = 1
        elseif orcBot > orcTop then
            set wp_orcMajLane = 2
        else
            set wp_orcMajLane = 0
        endif
        // Lado de reunión pegajoso: en empate se conserva el anterior.
        if wp_humMajLane != 0 then
            set wp_humRallySide = wp_humMajLane
        endif
        if wp_orcMajLane != 0 then
            set wp_orcRallySide = wp_orcMajLane
        endif

        set h = null
    endfunction

    public function GetTeamTotalHeroes takes player p returns integer
        if IsPlayerAlly(p, Player(0)) then
            return wp_humTotal
        endif
        return wp_orcTotal
    endfunction

    public function GetTeamAliveHeroes takes player p returns integer
        if IsPlayerAlly(p, Player(0)) then
            return wp_humAlive
        endif
        return wp_orcAlive
    endfunction

    public function GetTeamHumansAlive takes player p returns integer
        if IsPlayerAlly(p, Player(0)) then
            return wp_humHumansAlive
        endif
        return wp_orcHumansAlive
    endfunction

    // Carril donde está la mayoría del equipo (fuera de base). 0 = sin mayoría.
    public function GetMajorityLane takes player p returns integer
        if IsPlayerAlly(p, Player(0)) then
            return wp_humMajLane
        endif
        return wp_orcMajLane
    endfunction

    // PUNTO DE REUNIÓN para botUnit (resultado en GetWPRallyX/Y). Prioridad:
    //   1) Cluster del equipo en UN SOLO LADO: centroide de los héroes vivos
    //      FUERA de base que están en el lado de reunión del equipo (Top Y>=0 /
    //      Bot Y<0; mayoría, pegajoso en empate), EXCLUYENDO al propio bot (si
    //      el equipo empuja, el rally avanza con él; si resetea, retrocede).
    //      Si el bot está del OTRO lado, primero va a su base propia de ese
    //      lado (misma U que ApplyRerouteIfNeeded: no cruza por la base enemiga).
    //   2) Nadie más en ese lado: la defensa propia más adelantada que siga
    //      viva (F3/F2 de ese lado -> anillo F1 -> F0): esperar adelante pero
    //      seguro; el resto del equipo viene a este lado.
    //   3) Último recurso (sin estructuras, no debería darse): fuente propia.
    //
    // FIX TRAMPA-CENTRO (2026-10-13): antes el cluster era el centroide de TODO
    // el equipo. Con aliados repartidos entre Top y Bot el promedio caía ENTRE
    // los carriles, dentro de la montaña central (intransitable); el "move" del
    // motor deja al bot en el punto alcanzable más cercano = el callejón de la
    // tienda secreta, pegado a la pared y quieto. Se auto-refuerza (el bot
    // atascado, ya fuera de base, mantiene el promedio en el centro) y volvía
    // ahí tras comprar o tras un TP a base. Un solo lado nunca promedia a través
    // de la montaña.
    public function ResolveRally takes unit botUnit, integer lane returns nothing
        local boolean isHum = IsPlayerAlly(GetOwningPlayer(botUnit), Player(0))
        local integer side
        local integer i = 0
        local unit h
        local real hx
        local real hy
        local real sx = 0.0
        local real sy = 0.0
        local integer n = 0

        if isHum then
            set side = wp_humRallySide
        else
            set side = wp_orcRallySide
        endif
        if side == 0 then
            set side = lane
        endif

        // Escaneo directo (no el cache) para excluirme por IDENTIDAD: restar mi
        // posición actual a una suma de hace 0.30s fallaba al cruzar Y=0 o
        // entrar/salir de base.
        loop
            exitwhen i >= IACore_AllHeroCount
            set h = IACore_AllHeroes[i]
            if h != null and h != botUnit and GetUnitTypeId(h) != 0 and not IsUnitType(h, UNIT_TYPE_DEAD) and IsPlayerAlly(GetOwningPlayer(h), Player(0)) == isHum then
                set hx = GetUnitX(h)
                set hy = GetUnitY(h)
                if (hy >= 0.0) == (side == 1) and not InOwnHealingBase(hx, hy, isHum) then
                    set sx = sx + hx
                    set sy = sy + hy
                    set n = n + 1
                endif
            endif
            set i = i + 1
        endloop
        set h = null

        if n > 0 then
            if (GetUnitY(botUnit) >= 0.0) == (side == 1) then
                set wp_rallyX = sx / I2R(n)
                set wp_rallyY = sy / I2R(n)
            elseif side == 1 then
                if isHum then
                    set wp_rallyX = HUM_BASE_TOP_X
                    set wp_rallyY = HUM_BASE_TOP_Y
                else
                    set wp_rallyX = ORC_BASE_TOP_X
                    set wp_rallyY = ORC_BASE_TOP_Y
                endif
            else
                if isHum then
                    set wp_rallyX = HUM_BASE_BOT_X
                    set wp_rallyY = HUM_BASE_BOT_Y
                else
                    set wp_rallyX = ORC_BASE_BOT_X
                    set wp_rallyY = ORC_BASE_BOT_Y
                endif
            endif
            return
        endif

        // Defensa propia: F3/F2 del lado de reunión (helper existente)...
        if ResolveOwnDefense(botUnit, side) then
            set wp_rallyX = bm_defX
            set wp_rallyY = bm_defY
            return
        endif
        // ...y en late game (F3/F2 muertas) el anillo F1 propio, luego F0.
        if isHum then
            if GroupCentroid(AB_HUM_F1) then
                set wp_rallyX = bm_cx
                set wp_rallyY = bm_cy
                return
            endif
            if GroupCentroid(AB_HUM_F0) then
                set wp_rallyX = bm_cx
                set wp_rallyY = bm_cy
                return
            endif
        else
            if GroupCentroid(AB_ORC_F1) then
                set wp_rallyX = bm_cx
                set wp_rallyY = bm_cy
                return
            endif
            if GroupCentroid(AB_ORC_F0) then
                set wp_rallyX = bm_cx
                set wp_rallyY = bm_cy
                return
            endif
        endif
        set wp_rallyX = GetClosestHomeX(botUnit)
        set wp_rallyY = GetClosestHomeY(botUnit)
    endfunction

    public function GetWPRallyX takes nothing returns real
        return wp_rallyX
    endfunction
    public function GetWPRallyY takes nothing returns real
        return wp_rallyY
    endfunction

endlibrary