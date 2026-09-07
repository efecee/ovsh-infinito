// ==========================================================================
// SISTEMA: DATOS EN VIVO (HUD)
// Muestra Attack Speed y Movement Speed en tiempo real.
//
// ARQUITECTURA:
//   Timer a 0.03s (~33 FPS) para reposicionar el texto fluidamente.
//   Contador interno: cada 17 ticks (~0.51s) recalcula AS/MS.
//   Contador de deteccion: cada 33 ticks (~1s) busca heroes nuevos.
//
//
// DETECCION: Escanea periodicamente (~1s) buscando heroes de jugadores
//   humanos. Excluye Wisps ('ewsp') y Wisps Oscuros ('e006').
//   Se activa automaticamente al obtener un heroe (All Pick o Aleatorio).
//
// COLORES REACTIVOS:
//   Valores AS/MS blancos por defecto. Verde al detectar mejora,
//   rojo al detectar empeoramiento. Transicion suave de vuelta a blanco.
//
// COMANDOS:
//   -hud    ? Activa/Desactiva el HUD
// ==========================================================================
// DEPENDENCIA: ReplayPOVDetection (Replay_POV.j).
scope DatosEnVivo initializer Init

    globals
        private timer   HUD_Timer       = null
        private integer HUD_TickCount   = 0
        private integer HUD_DetectCount = 0
        // En juego normal siempre equivale al jugador local. En replay se
        // refresca cada ~0.51s para seguir el POV seleccionado.
        private integer HUD_ViewerPid   = 0
        private boolean HUD_AllDetected = false  // true = todos los humanos tienen heroe, dejar de buscar

        // === AJUSTABLES ===
        private constant real HUD_BASE_OFFSET_X = -95.0
        private constant real HUD_BASE_OFFSET_Y = -460.0
        private constant real HUD_BASE_TEXT_SIZE = 0.020

        // === COLORES REACTIVOS ===
        private constant real HUD_HIGHLIGHT_DUR    = 5.0
        private constant real HUD_FADE_DUR         = 2.0
        private constant real HUD_THRESH_AS        = 0.02
        private constant real HUD_THRESH_MS        = 3.0

        // === INTERNOS ===
        private constant real HUD_DEFAULT_ZOOM     = 1650.0
        private constant real HUD_CONTENT_INTERVAL = 0.51

        // IDs de Wisps (excluidos de la deteccion)
        private constant integer WISP_HUMAN_ID = 'ewsp'
        private constant integer WISP_ORC_ID   = 'e006'

        // Por jugador
        private texttag array HUD_Tag
        private boolean array HUD_On
        private unit    array HUD_Hero
        private boolean array HUD_Active
        private string  array HUD_CachedText

        // Deteccion de cambios
        private real    array HUD_PrevAS
        private real    array HUD_PrevMS
        private real    array HUD_AS_Timer
        private real    array HUD_MS_Timer
        private boolean array HUD_AS_IsBuff
        private boolean array HUD_MS_IsBuff
        private boolean array HUD_FirstTick
    endglobals

    // ========================================================================
    // HELPER: Busca el primer heroe vivo del jugador (excluye Wisps)
    // ========================================================================
    private function FindHero takes player p returns unit
        local group g = CreateGroup()
        local unit u
        local unit hero = null
        local integer uid

        call GroupEnumUnitsOfPlayer(g, p, null)
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            call GroupRemoveUnit(g, u)
            set uid = GetUnitTypeId(u)
            if IsUnitType(u, UNIT_TYPE_HERO) and uid != WISP_HUMAN_ID and uid != WISP_ORC_ID and hero == null then
                set hero = u
            endif
        endloop

        call DestroyGroup(g)
        set g = null
        set u = null
        return hero
    endfunction

    // ========================================================================
    // HELPER: Int a Hex (2 digitos)
    // ========================================================================
    private function Int2Hex takes integer v returns string
        local string h = "0123456789ABCDEF"
        local integer hi
        local integer lo
        if v < 0 then
            set v = 0
        elseif v > 255 then
            set v = 255
        endif
        set hi = v / 16
        set lo = v - hi * 16
        return SubString(h, hi, hi + 1) + SubString(h, lo, lo + 1)
    endfunction

    // ========================================================================
    // HELPER: Color de highlight con fade gradual
    // ========================================================================
    private function GetHighlightColor takes real tmr, boolean isBuff returns string
        local real fade
        local integer r
        local integer g
        local integer b
        if tmr <= 0.0 then
            return "|cffFFFFFF"
        endif
        if tmr > HUD_FADE_DUR then
            set fade = 0.0
        else
            set fade = 1.0 - (tmr / HUD_FADE_DUR)
        endif
        if isBuff then
            set r = R2I(fade * 255.0)
            set g = 255
            set b = R2I(fade * 255.0)
        else
            set r = 255
            set g = 68 + R2I(fade * 187.0)
            set b = 68 + R2I(fade * 187.0)
        endif
        return "|cff" + Int2Hex(r) + Int2Hex(g) + Int2Hex(b)
    endfunction

    // ========================================================================
    // HELPER: Construye texto principal con colores reactivos
    // ========================================================================
    private function BuildHudText takes unit hero, string asValColor, string msValColor returns string
        local real atkCd = IAUtils_GetUnitAttackCooldown(hero)
        local real asMod = IAUtils_GetAttackSpeedMod(hero)
        local integer asPercent = R2I(asMod * 100.0)
        local real ms = GetUnitMoveSpeed(hero)
        local string asSign = ""
        if asPercent >= 0 then
            set asSign = "+"
        endif
        // Principal: con color codes
        return "|cffFFCC00AS:|r " + asValColor + R2SW(atkCd, 1, 2) + "s|r |cff888888(" + asSign + I2S(asPercent) + "%)|r  |cffAAAAAA|||r  |cffFFCC00MS:|r " + msValColor + I2S(R2I(ms)) + "|r"
    endfunction

    // ========================================================================
    // REPOSICIONAR: Cada 0.03s. Mueve el texto siguiendo la camara.
    // ========================================================================
    private function Reposition takes integer pid returns nothing
        local real camX
        local real camY
        local real camDist
        local real zoomRatio
        local real posX
        local real posY

        if HUD_Tag[pid] == null then
            set HUD_Tag[pid] = CreateTextTag()
            call SetTextTagPermanent(HUD_Tag[pid], true)
            call SetTextTagText(HUD_Tag[pid], "...", HUD_BASE_TEXT_SIZE)
        endif

        if HUD_ViewerPid == pid then
            set camX = GetCameraTargetPositionX()
            set camY = GetCameraTargetPositionY()
            set camDist = GetCameraField(CAMERA_FIELD_TARGET_DISTANCE)

            set zoomRatio = camDist / HUD_DEFAULT_ZOOM
            if zoomRatio < 0.5 then
                set zoomRatio = 0.5
            elseif zoomRatio > 3.0 then
                set zoomRatio = 3.0
            endif

            set posX = camX + HUD_BASE_OFFSET_X * zoomRatio
            set posY = camY + HUD_BASE_OFFSET_Y * zoomRatio

            call SetTextTagPos(HUD_Tag[pid], posX, posY, 0.0)
            call SetTextTagText(HUD_Tag[pid], HUD_CachedText[pid], HUD_BASE_TEXT_SIZE)
            call SetTextTagVisibility(HUD_Tag[pid], true)
        else
            call SetTextTagVisibility(HUD_Tag[pid], false)
        endif
    endfunction

    // ========================================================================
    // ACTUALIZAR CONTENIDO: Cada ~0.51s
    // ========================================================================
    private function UpdateContent takes integer pid returns nothing
        local real currAS
        local real currMS
        local real diffAS
        local real diffMS
        local string asColor
        local string msColor

        // 1. Descontar timers de highlight
        if HUD_AS_Timer[pid] > 0.0 then
            set HUD_AS_Timer[pid] = HUD_AS_Timer[pid] - HUD_CONTENT_INTERVAL
        endif
        if HUD_MS_Timer[pid] > 0.0 then
            set HUD_MS_Timer[pid] = HUD_MS_Timer[pid] - HUD_CONTENT_INTERVAL
        endif

        // 2. Leer valores actuales
        set currAS = IAUtils_GetUnitAttackCooldown(HUD_Hero[pid])
        set currMS = GetUnitMoveSpeed(HUD_Hero[pid])

        // 3. Detectar cambios
        if not HUD_FirstTick[pid] then
            set diffAS = currAS - HUD_PrevAS[pid]
            if diffAS < 0.0 then
                set diffAS = -diffAS
            endif
            set diffMS = currMS - HUD_PrevMS[pid]
            if diffMS < 0.0 then
                set diffMS = -diffMS
            endif
            if diffAS > HUD_THRESH_AS then
                set HUD_AS_IsBuff[pid] = (currAS < HUD_PrevAS[pid])
                set HUD_AS_Timer[pid] = HUD_HIGHLIGHT_DUR
            endif
            if diffMS > HUD_THRESH_MS then
                set HUD_MS_IsBuff[pid] = (currMS > HUD_PrevMS[pid])
                set HUD_MS_Timer[pid] = HUD_HIGHLIGHT_DUR
            endif
        else
            set HUD_FirstTick[pid] = false
        endif

        // 4. Guardar valores actuales
        set HUD_PrevAS[pid] = currAS
        set HUD_PrevMS[pid] = currMS

        // 5. Calcular colores y reconstruir texto
        set asColor = GetHighlightColor(HUD_AS_Timer[pid], HUD_AS_IsBuff[pid])
        set msColor = GetHighlightColor(HUD_MS_Timer[pid], HUD_MS_IsBuff[pid])
        set HUD_CachedText[pid] = BuildHudText(HUD_Hero[pid], asColor, msColor)
    endfunction

    // ========================================================================
    // DETECCION DE HEROES: Cada ~1s busca heroes no registrados.
    // Una vez detectado, el heroe se guarda PERMANENTEMENTE.
    // El jugador nunca cambia de heroe durante la partida.
    // Cuando TODOS los jugadores humanos tienen heroe, se activa
    // HUD_AllDetected y la deteccion se desactiva para siempre.
    // ========================================================================
    private function TryDetectHero takes integer pid returns nothing
        local integer checkId
        local boolean allFound

        if HUD_Active[pid] then
            return
        endif
        if GetPlayerSlotState(Player(pid)) != PLAYER_SLOT_STATE_PLAYING then
            return
        endif
        if GetPlayerController(Player(pid)) != MAP_CONTROL_USER then
            return
        endif
        set HUD_Hero[pid] = FindHero(Player(pid))
        if HUD_Hero[pid] != null then
            set HUD_Active[pid] = true
            set HUD_On[pid] = true
            // Arranca el panel de -fondo SINCRONIZADO con el HUD (ambos "mostrar")
            // al adquirir el heroe: evita que un -hud escrito durante la seleccion
            // (antes de tener heroe) deje los dos flags invertidos entre si.
            set Eco_HudHidden[pid] = false
            set HUD_FirstTick[pid] = true
            set HUD_PrevAS[pid] = IAUtils_GetUnitAttackCooldown(HUD_Hero[pid])
            set HUD_PrevMS[pid] = GetUnitMoveSpeed(HUD_Hero[pid])
            set HUD_CachedText[pid] = BuildHudText(HUD_Hero[pid], "|cffFFFFFF", "|cffFFFFFF")

            // Verificar si TODOS los jugadores humanos ya tienen heroe
            set allFound = true
            set checkId = 0
            loop
                exitwhen checkId > 9
                if GetPlayerSlotState(Player(checkId)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(checkId)) == MAP_CONTROL_USER then
                    if not HUD_Active[checkId] then
                        set allFound = false
                    endif
                endif
                set checkId = checkId + 1
            endloop
            if allFound then
                set HUD_AllDetected = true
            endif
        endif
    endfunction

    // ========================================================================
    // LOOP PRINCIPAL: 0.03s (~33 FPS)
    // ========================================================================
    private function HUD_MainLoop takes nothing returns nothing
        local integer pid = 0
        local boolean updateContent
        local boolean detectHeroes

        set HUD_TickCount = HUD_TickCount + 1
        set updateContent = (HUD_TickCount >= 17)
        if updateContent then
            set HUD_TickCount = 0
            set HUD_ViewerPid = GetPlayerId(GetReplayPlayerCached())
        endif

        // Deteccion: solo si aun faltan jugadores por detectar
        if not HUD_AllDetected then
            set HUD_DetectCount = HUD_DetectCount + 1
            set detectHeroes = (HUD_DetectCount >= 33)
            if detectHeroes then
                set HUD_DetectCount = 0
            endif
        else
            set detectHeroes = false
        endif

        loop
            exitwhen pid > 9

            // Deteccion de heroes (~1s, solo mientras falten)
            if detectHeroes then
                call TryDetectHero(pid)
            endif

            if HUD_Active[pid] and HUD_On[pid] then

                if HUD_Hero[pid] != null and not IsUnitType(HUD_Hero[pid], UNIT_TYPE_DEAD) then
                    if updateContent then
                        call UpdateContent(pid)
                    endif
                    call Reposition(pid)
                else
                    // Heroe muerto: ocultar texttag
                    if HUD_ViewerPid == pid then
                        if HUD_Tag[pid] != null then
                            call SetTextTagVisibility(HUD_Tag[pid], false)
                        endif
                    endif
                endif
            endif
            set pid = pid + 1
        endloop
    endfunction

    // ========================================================================
    // DESTRUCCION
    // ========================================================================
    private function DestroyHud takes integer pid returns nothing
        if HUD_Tag[pid] != null then
            call DestroyTextTag(HUD_Tag[pid])
            set HUD_Tag[pid] = null
        endif
    endfunction

    // ========================================================================
    // COMANDO: -hud (toggle)
    // ========================================================================
    private function OnHudToggle takes nothing returns nothing
        local integer pid = GetPlayerId(GetTriggerPlayer())
        set HUD_On[pid]        = not HUD_On[pid]
        set Eco_HudHidden[pid] = not Eco_HudHidden[pid]
        if HUD_On[pid] then
            set HUD_FirstTick[pid] = true
            call DisplayTimedTextToPlayer(Player(pid), 0, 0, 3.0, "|cff00FF00[HUD]|r Paneles del centro (datos y colectas) |cff00FFFFvisibles|r")
        else
            call DestroyHud(pid)
            call DisplayTimedTextToPlayer(Player(pid), 0, 0, 3.0, "|cffFF0000[HUD]|r Paneles del centro (datos y colectas) |cffFF4444ocultos|r")
        endif
    endfunction

    // ========================================================================
    // INICIALIZACION
    // ========================================================================
    private function Init takes nothing returns nothing
        local trigger tHud = CreateTrigger()
        local integer i = 0

        set HUD_ViewerPid = GetPlayerId(GetLocalPlayer())

        loop
            exitwhen i > 9
            set HUD_Tag[i] = null
            set HUD_On[i] = false
            set HUD_Hero[i] = null
            set HUD_Active[i] = false
            set HUD_CachedText[i] = ""
            set HUD_PrevAS[i] = 0.0
            set HUD_PrevMS[i] = 0.0
            set HUD_AS_Timer[i] = 0.0
            set HUD_MS_Timer[i] = 0.0
            set HUD_AS_IsBuff[i] = false
            set HUD_MS_IsBuff[i] = false
            set HUD_FirstTick[i] = true
            set i = i + 1
        endloop

        set i = 0
        loop
            exitwhen i > 9
            call TriggerRegisterPlayerChatEvent(tHud, Player(i), "-hud", true)
            set i = i + 1
        endloop
        call TriggerAddAction(tHud, function OnHudToggle)

        // Timer principal: 0.03s (~33 FPS)
        set HUD_Timer = CreateTimer()
        call TimerStart(HUD_Timer, 0.03, true, function HUD_MainLoop)

        set tHud = null
    endfunction

endscope
