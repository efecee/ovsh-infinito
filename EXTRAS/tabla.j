//===========================================================================
// SISTEMA DE TABLA (MULTIBOARD) 5v5 - VERSIÓN LIMPIA & FINAL
//===========================================================================

globals
    timer MB_Timer = CreateTimer() // Creamos un reloj EXCLUSIVO para la tabla
    timer MB_ClockTimer = null     // Timer periódico para actualizar el cronómetro visual
    sound MB_Snd_Leave = null      // Sonido global reutilizable para abandonos
    hashtable MB_AoEHash = null    // Contexto de timers diferidos/periódicos (Tier B+C)

    // =====================================================================
    // ICONOS DE LA TABLA - ZONA EDITABLE
    // =====================================================================
    // Cambia estas dos rutas si quieres otro icono provisional por facción.
    // El ancho del NOMBRE sigue siendo 0.1024; esta columna es independiente.
    constant real MB_ICON_WIDTH = 0.015
    constant string MB_ICON_HUMAN_PLACEHOLDER = "ReplaceableTextures\\CommandButtons\\BTNPeasant.blp"
    constant string MB_ICON_ORC_PLACEHOLDER = "ReplaceableTextures\\CommandButtons\\BTNPeon.blp"

    // Icono para quien abandono SIN elegir heroe. Se muestra recien cuando su
    // equipo revela los iconos; hasta entonces conserva el provisional de faccion.
    // Tambien sirve de salvavidas para un heroe nuevo sin ruta registrada.
    constant string MB_ICON_UNKNOWN = "ReplaceableTextures\\CommandButtons\\BTNnegro.blp"

    // ---------------------------------------------------------------------
    // SONIDO "EQUIPO LISTO" (EXPERIMENTAL) - ZONA EDITABLE
    // ---------------------------------------------------------------------
    // Suena para TODOS (humanos y orcos) una vez por faccion, en el instante en
    // que esa faccion revela sus iconos: maximo dos veces por partida.
    // Para desactivarlo basta poner el booleano en false; para probar otro
    // sonido, cambiar solo la ruta. El revelado de iconos NO depende de esto.
    constant boolean MB_TEAMREADY_SOUND_ENABLED = true
    constant string MB_SND_TEAMREADY_PATH = "Sound\\Interface\\WayPointBling.wav"
    sound MB_Snd_TeamReady = null  // Persistente (patron MB_Snd_Leave): se crea UNA vez en init, nunca se destruye

    // Rawcode elegido por cada slot. Se captura al crear el héroe base para
    // que una transformación posterior no cambie el retrato de la tabla.
    integer array MB_HeroType
    boolean MB_BoardReady = false
    boolean MB_HumanIconsRevealed = false
    boolean MB_OrcIconsRevealed = false
endglobals

// --- 1. COLORES DE JUGADORES ---
function MB_GetColor takes player p returns string
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

// =====================================================================
// ICONOS REALES DE HEROES - ZONA EDITABLE
// =====================================================================
// Para cambiar un icono, modifica SOLO el texto entre comillas de su rawcode.
// En el Editor de Objetos: Unidades > el heroe > Arte - Icono de interfaz.
// La ruta debe conservar las barras dobles "\\" dentro del string JASS.
// Ejemplo: ReplaceableTextures\\CommandButtons\\BTNHeroPaladin.blp
function MB_GetHeroIcon takes integer heroType returns string
    // ---------------- HUMANOS (19) ----------------
    if (heroType == 'Ekee') then // Guardian del Bosque
        return "ReplaceableTextures\\CommandButtons\\BTNKeeperOfTheGrove.blp"
    elseif (heroType == 'Emoo') then // Sacerdotisa de la Luna
        return "ReplaceableTextures\\CommandButtons\\BTNPriestessOfTheMoon.blp"
    elseif (heroType == 'Edem') then // Cazador de Demonios
        return "ReplaceableTextures\\CommandButtons\\BTNEvilIllidan.blp"
    elseif (heroType == 'Ewar') then // Guardiana
        return "ReplaceableTextures\\CommandButtons\\BTNHeroWarden.blp"
    elseif (heroType == 'Hpal') then // Paladin
        return "ReplaceableTextures\\CommandButtons\\BTNHeroPaladin.blp"
    elseif (heroType == 'Hamg') then // Archimago
        return "ReplaceableTextures\\CommandButtons\\BTNHeroArchMage.blp"
    elseif (heroType == 'Hmkg') then // Rey de la Montana
        return "ReplaceableTextures\\CommandButtons\\BTNHeroMountainKing.blp"
    elseif (heroType == 'Hblm') then // Mago sanguinario
        return "ReplaceableTextures\\CommandButtons\\BTNBloodMage2.blp"
    elseif (heroType == 'Nalc') then // Alquimista
        return "ReplaceableTextures\\CommandButtons\\BTNHeroAlchemist.blp"
    elseif (heroType == 'Ntin') then // Hojalatero
        return "ReplaceableTextures\\CommandButtons\\BTNHeroTinker.blp"
    elseif (heroType == 'Npbm') then // Alquimista pandaren
        return "ReplaceableTextures\\CommandButtons\\BTNPandarenBrewmaster.blp"
    elseif (heroType == 'Hlgr') then // Lord Garithos
        return "ReplaceableTextures\\CommandButtons\\BTNGarithos.blp"
    elseif (heroType == 'Hvwd') then // Sylvanas humana/elfa
        return "ReplaceableTextures\\CommandButtons\\BTNSylvanusWindrunner.blp"
    elseif (heroType == 'E005') then // Asesina
        return "ReplaceableTextures\\CommandButtons\\BTNAssassin.blp"
    elseif (heroType == 'H00U') then // Goblin Techies
        return "ReplaceableTextures\\CommandButtons\\BTNGoblinSapper.blp"
    elseif (heroType == 'H00R') then // Sniper
        return "ReplaceableTextures\\CommandButtons\\BTNRifleman.blp"
    elseif (heroType == 'H00Q') then // Bandido
        return "ReplaceableTextures\\CommandButtons\\BTNBandit.blp"
    elseif (heroType == 'O00B') then // Magnadefender
        return "ReplaceableTextures\\CommandButtons\\BTNMagnataur.blp"
    elseif (heroType == 'H00G') then // Darth'Remar
        return "ReplaceableTextures\\CommandButtons\\BTNSpellBreakerMagicUnDefend.blp"

        // ---------------- ORCOS (18) ----------------
    elseif (heroType == 'Obla') then // Maestro de las Espadas
        return "ReplaceableTextures\\CommandButtons\\BTNHeroBlademaster.blp"
    elseif (heroType == 'Ofar') then // Vidente
        return "ReplaceableTextures\\CommandButtons\\BTNThrall.blp"
    elseif (heroType == 'Otch') then // Jefe Tauren
        return "ReplaceableTextures\\CommandButtons\\BTNHeroTaurenChieftain.blp"
    elseif (heroType == 'Oshd') then // Cazador de sombras
        return "ReplaceableTextures\\CommandButtons\\BTNShadowHunter.blp"
    elseif (heroType == 'Udea') then // Caballero de la Muerte
        return "ReplaceableTextures\\CommandButtons\\BTNHeroDeathKnight.blp"
    elseif (heroType == 'Ulic') then // Lich
        return "ReplaceableTextures\\CommandButtons\\BTNLichVersion2.blp"
    elseif (heroType == 'Udre') then // Senor del Terror
        return "ReplaceableTextures\\CommandButtons\\BTNHeroDreadLord.blp"
    elseif (heroType == 'Ucrl') then // Senor de la Cripta
        return "ReplaceableTextures\\CommandButtons\\BTNHeroCryptLord.blp"
    elseif (heroType == 'Nngs') then // Bruja de mar naga
        return "ReplaceableTextures\\CommandButtons\\BTNNagaSeaWitch.blp"
    elseif (heroType == 'Nfir') then // Senor del Fuego
        return "ReplaceableTextures\\CommandButtons\\BTNHeroAvatarOfFlame.blp"
    elseif (heroType == 'Nplh') then // Senor del Foso
        return "ReplaceableTextures\\CommandButtons\\BTNPitLord.blp"
    elseif (heroType == 'Nman') then // Nigromante
        return "ReplaceableTextures\\CommandButtons\\BTNNecromancer.blp"
    elseif (heroType == 'Ogrh') then // Grom Hellscream
        return "ReplaceableTextures\\CommandButtons\\BTNHellScream.blp"
    elseif (heroType == 'Usyl') then // Sylvanas no-muerta
        return "ReplaceableTextures\\CommandButtons\\BTNBansheeRanger.blp"
    elseif (heroType == 'H00P') then // Butcher Abomination
        return "ReplaceableTextures\\CommandButtons\\BTNAbomination.blp"
    elseif (heroType == 'H00V') then // Naga Royal
        return "ReplaceableTextures\\CommandButtons\\BTNNagaMyrmidon.blp"
    elseif (heroType == 'H00K') then // Invocador del Trueno
        return "ReplaceableTextures\\CommandButtons\\BTNPandarenBrewmaster.blp"
    elseif (heroType == 'N020') then // Troll Berserker
        return "ReplaceableTextures\\CommandButtons\\BTNHeadHunterBerserker.blp"
    endif

    // Salvavidas para cualquier heroe nuevo que aun no tenga ruta registrada.
    if (heroType != 0) then
        return MB_ICON_UNKNOWN
    endif
    return ""
endfunction

// Escribe exclusivamente la columna 0. Nunca toca nombre, K, D ni A.
function MB_SetPlayerIcon takes integer id, string iconPath, boolean showIcon returns nothing
    local integer row = LoadInteger(udg_MB_Hash, id, 0)
    local multiboarditem mb_item

    if (not MB_BoardReady or row == 0) then
        return
    endif

    set mb_item = MultiboardGetItem(udg_MB_Tabla, row - 1, 0)
    call MultiboardSetItemWidth(mb_item, MB_ICON_WIDTH)
    if (showIcon) then
        call MultiboardSetItemIcon(mb_item, iconPath)
        call MultiboardSetItemStyle(mb_item, false, true)
    else
        call MultiboardSetItemIcon(mb_item, "")
        call MultiboardSetItemStyle(mb_item, false, false)
    endif
    call MultiboardReleaseItem(mb_item)
    set mb_item = null
endfunction

// Un slot cuenta para completar la seleccion mientras su fila siga activa.
// key 102 = IA sustituta activa; key 103 = fila definitivamente atenuada.
function MB_IsRequiredForReveal takes integer id returns boolean
    if (LoadInteger(udg_MB_Hash, id, 0) == 0) then
        return false
    endif
    if (LoadBoolean(udg_MB_Hash, id, 102)) then
        return true
    endif
    if (LoadBoolean(udg_MB_Hash, id, 103)) then
        return false
    endif
    return GetPlayerSlotState(Player(id)) == PLAYER_SLOT_STATE_PLAYING
endfunction

// Sonido global de "equipo listo". Aislado para poder quitarlo sin tocar el
// revelado: con el flag en false o sin sonido creado, no hace nada.
function MB_PlayTeamReadySound takes nothing returns nothing
    if (not MB_TEAMREADY_SOUND_ENABLED or MB_Snd_TeamReady == null) then
        return
    endif
    call SetSoundVolume(MB_Snd_TeamReady, 127)
    call StartSound(MB_Snd_TeamReady)
endfunction

// Revela una faccion completa. Un desertor que alcanzo a escoger conserva el
// icono real sin atenuar; si nunca escogio, muestra el icono de interrogacion
// (hasta este momento conservaba el provisional de su faccion).
// Devuelve cuantos slots recibieron un icono de heroe real.
function MB_RevealTeam takes integer firstId, integer lastId returns integer
    local integer i = firstId
    local integer revealed = 0
    local string iconPath

    loop
        exitwhen i > lastId
        if (LoadInteger(udg_MB_Hash, i, 0) > 0) then
            if (MB_HeroType[i] != 0) then
                set iconPath = MB_GetHeroIcon(MB_HeroType[i])
                call MB_SetPlayerIcon(i, iconPath, iconPath != "")
                set revealed = revealed + 1
            else
                call MB_SetPlayerIcon(i, MB_ICON_UNKNOWN, true)
            endif
        endif
        set i = i + 1
    endloop
    return revealed
endfunction

function MB_TryRevealTeam takes boolean humanTeam returns nothing
    local integer firstId = 5
    local integer lastId = 9
    local integer i
    local integer revealed = 0

    if (humanTeam) then
        if (MB_HumanIconsRevealed) then
            return
        endif
        set firstId = 0
        set lastId = 4
    elseif (MB_OrcIconsRevealed) then
        return
    endif

    set i = firstId
    loop
        exitwhen i > lastId
        if (MB_IsRequiredForReveal(i) and MB_HeroType[i] == 0) then
            return
        endif
        set i = i + 1
    endloop

    set revealed = MB_RevealTeam(firstId, lastId)
    if (humanTeam) then
        set MB_HumanIconsRevealed = true
    else
        set MB_OrcIconsRevealed = true
    endif

    // Aviso sonoro (experimental) solo si la faccion tiene al menos un heroe
    // real: una faccion vacia o formada solo por desertores sin heroe no suena.
    if (revealed > 0) then
        call MB_PlayTeamReadySound()
    endif
endfunction

function MB_CheckRevealStates takes nothing returns nothing
    if (not MB_BoardReady) then
        return
    endif
    call MB_TryRevealTeam(true)
    call MB_TryRevealTeam(false)
endfunction

// Conserva el rawcode del primer heroe real creado para el slot.
function MB_RecordHero takes unit u returns nothing
    local integer id
    local string iconPath

    if (u == null or not IsUnitType(u, UNIT_TYPE_HERO) or IsUnitIllusion(u)) then
        return
    endif

    set id = GetPlayerId(GetOwningPlayer(u))
    if (id < 0 or id > 9 or MB_HeroType[id] != 0) then
        return
    endif

    set MB_HeroType[id] = GetUnitTypeId(u)
    if (MB_BoardReady) then
        if ((id <= 4 and MB_HumanIconsRevealed) or (id >= 5 and MB_OrcIconsRevealed)) then
            set iconPath = MB_GetHeroIcon(MB_HeroType[id])
            call MB_SetPlayerIcon(id, iconPath, iconPath != "")
        else
            call MB_CheckRevealStates()
        endif
    endif
endfunction

// Respaldo para heroes creados antes de que la tabla visual aparezca a los 2s.
function MB_CaptureExistingHeroes takes nothing returns nothing
    local integer i = 0
    local group g = CreateGroup()
    local unit u

    loop
        exitwhen i > 9
        if (LoadInteger(udg_MB_Hash, i, 0) > 0 and MB_HeroType[i] == 0) then
            call GroupEnumUnitsOfPlayer(g, Player(i), null)
            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                call GroupRemoveUnit(g, u)
                if (IsUnitType(u, UNIT_TYPE_HERO) and not IsUnitIllusion(u)) then
                    call MB_RecordHero(u)
                endif
            endloop
        endif
        call GroupClear(g)
        set i = i + 1
    endloop

    call DestroyGroup(g)
    set g = null
    set u = null
endfunction

// --- CONFIGURACIÓN: HECHIZOS DE CONTROL (SIN DAÑO) ---
// Rawcodes de los poderes que dan asistencia sin quitar vida.
function MB_IsControlSpell takes integer spellId returns boolean
    // Cambia estos IDs por los de tu mapa
    if (spellId == 'AHdr' or spellId == 'AOhx' or spellId == 'ANhx' or spellId == 'AHbn' or spellId == 'AUsl' or spellId == 'ANdh' or spellId == 'A03S' or spellId == 'A00A' or spellId == 'A02R' or spellId == 'A04N' or spellId == 'AHtb' or spellId == 'AEer' or spellId == 'A03T' or spellId == 'A02O') then
        return true
    endif
    return false
endfunction

// --- CONFIGURACIÓN: HECHIZOS DE CURACIÓN (TARGET UNITARIO) ---
// Rawcodes de heals que se castean sobre un aliado.
// Los heals AoE sin target (Pulverizador, Tranquilidad) no aplican aquí
// porque GetSpellTargetUnit() retorna null en esos casos.
function MB_IsHealSpell takes integer spellId returns boolean
    if (spellId == 'AHhb' or spellId == 'AOhw' or spellId == 'A03Q' or spellId == 'A045') then
        return true
    endif
    return false
endfunction

// --- HELPER: REGISTRAR DAÑO (Enemigo → Víctima) ---
// Guarda el timestamp del último daño Y acumula el daño total recibido.
// Si el golpe anterior expiró (fuera de ventana 10s), reinicia el acumulado.
function MB_RegisterTimestamp takes unit victim, unit attacker, real damage returns nothing
    local integer idVic
    local integer idAtt
    local real time = TimerGetElapsed(MB_Timer)
    local real lastTime
    
    // Validamos: VÍCTIMA héroe (no ilusión) y enemiga del atacante. Excluimos
    // ilusiones COMO VÍCTIMA: el daño hecho A una ilusión no debe contar para
    // asistencias (key 500) ni para "El Verdugo" (key 700).
    // El ATACANTE ya NO se exige héroe: puede ser una invocación (Infernal,
    // wards), una ilusión o un clon (panda Alquimista). Lo que importa es que su
    // DUEÑO sea un jugador REAL (0-9), así el daño se acredita al héroe dueño y
    // suma asistencia si cruza el umbral. Todas las invocaciones/clones de un
    // mismo jugador acumulan en el MISMO bucket (key 500+idAtt), junto con el
    // daño del propio héroe. Estructuras y creeps (dueño 10/11) quedan fuera del
    // rango 0-9 → nunca otorgan asistencia (el bucle de reparto solo lee 0-9).
    if (IsUnitType(victim, UNIT_TYPE_HERO) and not IsUnitIllusion(victim)) then
        set idAtt = GetPlayerId(GetOwningPlayer(attacker))
        if (idAtt >= 0 and idAtt <= 9 and IsPlayerEnemy(GetOwningPlayer(victim), GetOwningPlayer(attacker))) then
            set idVic = GetPlayerId(GetOwningPlayer(victim))

            // Leer el timestamp del golpe anterior
            set lastTime = LoadReal(udg_MB_Hash, idVic, 200 + idAtt)
            
            // Si el golpe anterior expiró (más de 10s), reiniciar el acumulado
            if (lastTime <= 0.0 or (time - lastTime) > 10.0) then
                call SaveReal(udg_MB_Hash, idVic, 500 + idAtt, damage)
            else
                // Dentro de ventana: acumular normalmente
                call SaveReal(udg_MB_Hash, idVic, 500 + idAtt, LoadReal(udg_MB_Hash, idVic, 500 + idAtt) + damage)
            endif
            
            // Guardamos el tiempo del último daño (siempre se actualiza)
            call SaveReal(udg_MB_Hash, idVic, 200 + idAtt, time)

            // Acumulado TOTAL de daño a héroes enemigos (premio "El Verdugo").
            // A diferencia del key 500+i (ventana de 10s), este NO expira:
            // es el daño de toda la partida, guardado sobre el ATACANTE (key 700).
            call SaveReal(udg_MB_Hash, idAtt, 700, LoadReal(udg_MB_Hash, idAtt, 700) + damage)
        endif
    endif
endfunction

// --- HELPER: REGISTRAR CONTROL (Hechizo sin daño → Víctima) ---
// Timestamp separado (key 600+i) para que los CC no necesiten umbral de daño.
function MB_RegisterControlTimestamp takes unit victim, unit attacker returns nothing
    local integer idVic
    local integer idAtt
    local real time = TimerGetElapsed(MB_Timer)
    
    if (IsUnitType(victim, UNIT_TYPE_HERO) and IsUnitType(attacker, UNIT_TYPE_HERO) and not IsUnitIllusion(victim)) then
        if (IsPlayerEnemy(GetOwningPlayer(victim), GetOwningPlayer(attacker))) then
            set idVic = GetPlayerId(GetOwningPlayer(victim))
            set idAtt = GetPlayerId(GetOwningPlayer(attacker))
            call SaveReal(udg_MB_Hash, idVic, 600 + idAtt, time)
        endif
    endif
endfunction

// --- HELPER: REGISTRAR CURACIÓN (Healer → Aliado) ---
// Guarda el timestamp de curación en key 300 + idHealer sobre el héroe aliado.
// Esto permite dar asistencia al healer cuando su aliado consigue una kill.
function MB_RegisterHealTimestamp takes unit target, unit caster returns nothing
    local integer idTarget
    local integer idCaster
    local real time = TimerGetElapsed(MB_Timer)
    
    // Validamos: Ambos Héroes, Aliados, y no el mismo jugador.
    // Excluimos curar a una ilusión (no debe otorgar asistencia por curación).
    if (IsUnitType(target, UNIT_TYPE_HERO) and IsUnitType(caster, UNIT_TYPE_HERO) and not IsUnitIllusion(target)) then
        if (IsPlayerAlly(GetOwningPlayer(target), GetOwningPlayer(caster))) then
            set idTarget = GetPlayerId(GetOwningPlayer(target))
            set idCaster = GetPlayerId(GetOwningPlayer(caster))
            
            // No registrar auto-heal
            if (idTarget != idCaster) then
                call SaveReal(udg_MB_Hash, idTarget, 300 + idCaster, time)
            endif
        endif
    endif
endfunction

// ==========================================================================
// HABILIDADES DE ÁREA (AoE) — ENUM SELLADO POR CASTER
// ==========================================================================
// Problema: las habilidades de área no tienen target unitario, así que
// GetSpellTargetUnit() retorna null. Además, sus buffs de stun reales son
// ocultos/genéricos (no coinciden con el conjuro benéfico del editor) y en
// Modo Aleatorio cualquier héroe puede portar cualquier habilidad, por lo
// que NO se puede deducir al caster por el tipo de héroe ni por el buff.
//
// Solución: en el frame del casteo conocemos al CASTER real (GetTriggerUnit).
// Hacemos un único enum en el área y sellamos a cada víctima/aliado con el
// timestamp del caster correcto, reutilizando las Vías 2 (control, key 600+i)
// y 3 (curación, key 300+i) ya existentes. NO se lee ningún buff.
//
// AJUSTE: Los radios de abajo son estimaciones generosas. Ajústalos al campo
// "Área de efecto" de cada habilidad en tu Object Editor si quieres precisión.
// Para asistencias, pecar de generoso es aceptable (son habilidades
// determinantes por diseño).

// ¿La habilidad impacta en LÍNEA (avanza desde el caster) en vez de en círculo?
// Empalar y Carne de Carnicero recorren una línea recta; un solo círculo
// dejaría fuera a los enemigos del inicio o del final del recorrido.
function MB_AoEIsLine takes integer spellId returns boolean
    return (spellId == 'AUim' or spellId == 'A03N')
endfunction

// Longitud del recorrido en línea (solo para habilidades de tipo línea).
function MB_AoELineDist takes integer spellId returns real
    if (spellId == 'AUim') then        // Empalar (Señor de la Cripta)
        return 600.0
    elseif (spellId == 'A03N') then    // Carne de Carnicero (Butcher) — línea muy corta
        return 30.0
    endif
    return 0.0
endfunction

// Radio AoE de CONTROL/DAÑO sobre enemigos, ESCALADO POR NIVEL. 0.0 = no aplica.
// Para habilidades de línea, este valor es el ANCHO de la púa (radio lateral).
// Los valores reflejan la data exacta del editor; ajústalos si cambias el spell.
function MB_AoEControlRadius takes integer spellId, integer level returns real
    if (spellId == 'AHtc') then
        // Trueno (10 niveles)
        if (level == 1) then
            return 250.0
        elseif (level == 2) then
            return 300.0
        elseif (level == 3) then
            return 350.0
        elseif (level == 4) then
            return 400.0
        elseif (level == 5) then
            return 450.0
        elseif (level == 6) then
            return 500.0
        elseif (level == 7) then
            return 550.0
        elseif (level == 8) then
            return 600.0
        elseif (level == 9) then
            return 650.0
        elseif (level == 10) then
            return 800.0
        endif
        return 250.0
    elseif (spellId == 'AOws') then
        // Pisotón (Jefe Tauren): estimación fija (no hay data por nivel; ajusta si escala)
        return 350.0
    elseif (spellId == 'A04L') then
        // Aplauso de Mirmidón (6 niveles)
        if (level == 1) then
            return 500.0
        elseif (level == 2) then
            return 580.0
        elseif (level == 3) then
            return 660.0
        elseif (level == 4) then
            return 740.0
        elseif (level == 5) then
            return 820.0
        elseif (level == 6) then
            return 900.0
        endif
        return 500.0
    elseif (spellId == 'AUim') then
        // Empalar — ANCHO de la línea (10 niveles). Línea de 600 (ver MB_AoELineDist).
        if (level == 1) then
            return 250.0
        elseif (level == 2) then
            return 262.0
        elseif (level == 3) then
            return 274.0
        elseif (level == 4) then
            return 286.0
        elseif (level == 5) then
            return 298.0
        elseif (level == 6) then
            return 310.0
        elseif (level == 7) then
            return 322.0
        elseif (level == 8) then
            return 334.0
        elseif (level == 9) then
            return 346.0
        elseif (level == 10) then
            return 358.0
        endif
        return 250.0
    elseif (spellId == 'A03N') then
        // Carne de Carnicero — ancho fijo 125 (línea corta de 30)
        return 125.0
    endif
    return 0.0
endfunction

// Radio AoE de CURACIÓN sobre aliados (Vía 3), ESCALADO POR NIVEL. 0.0 = no aplica.
function MB_AoEHealRadius takes integer spellId, integer level returns real
    if (spellId == 'ANhs') then
        // Pulverizador Curativo (Alquimista) — área fija 250
        return 250.0
    elseif (spellId == 'AEtq') then
        // Tranquilidad (6 niveles). Canalizada → enum al inicio.
        if (level == 1) then
            return 850.0
        elseif (level == 2) then
            return 900.0
        elseif (level == 3) then
            return 950.0
        elseif (level == 4) then
            return 1000.0
        elseif (level == 5) then
            return 1050.0
        elseif (level == 6) then
            return 1100.0
        endif
        return 850.0
    endif
    return 0.0
endfunction

// Procesa una habilidad AoE: enumera el área y sella a cada unidad válida con
// el timestamp del caster. Maneja control (enemigos), heal (aliados) y línea.
// Si el spellId no está registrado, retorna sin hacer nada.
function MB_OnAoEAbility takes integer spellId, unit caster returns nothing
    local integer level = GetUnitAbilityLevel(caster, spellId)
    local real radCtrl = MB_AoEControlRadius(spellId, level)
    local real radHeal = MB_AoEHealRadius(spellId, level)
    local boolean isHeal = (radHeal > 0.0)
    local real radius
    local real cx
    local real cy
    local real angle
    local real cosA
    local real sinA
    local real lineDist
    local real d
    local real step
    local group g
    local unit u

    if (radCtrl <= 0.0 and radHeal <= 0.0) then
        return
    endif

    if (isHeal) then
        set radius = radHeal
    else
        set radius = radCtrl
    endif

    set g = CreateGroup()

    if (MB_AoEIsLine(spellId)) then
        // --- HABILIDAD EN LÍNEA (Empalar, Carne): barremos círculos solapados
        // desde el caster hacia el punto objetivo (mismo patrón que Fisure.j),
        // para cubrir todo el recorrido sin huecos. Solo afecta enemigos.
        set cx = GetUnitX(caster)
        set cy = GetUnitY(caster)
        set angle = Atan2(GetSpellTargetY() - cy, GetSpellTargetX() - cx)
        set cosA = Cos(angle)
        set sinA = Sin(angle)
        set lineDist = MB_AoELineDist(spellId)
        set step = radius * 0.5   // solapamiento para cobertura continua
        if (step < 1.0) then
            set step = 1.0
        endif
        set d = 0.0
        loop
            exitwhen d > lineDist
            call GroupEnumUnitsInRange(g, cx + d * cosA, cy + d * sinA, radius, null)
            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                call GroupRemoveUnit(g, u)
                if (not IsUnitType(u, UNIT_TYPE_DEAD)) then
                    // Idempotente: re-sellar la misma víctima solo reescribe el timestamp.
                    call MB_RegisterControlTimestamp(u, caster)
                endif
            endloop
            set d = d + step
        endloop
    else
        // --- HABILIDAD CIRCULAR: centro en el punto objetivo si existe; si es
        // sin-target (0,0), la posición del caster (salvavidas igual que en AS).
        set cx = GetSpellTargetX()
        set cy = GetSpellTargetY()
        if (cx == 0.0 and cy == 0.0) then
            set cx = GetUnitX(caster)
            set cy = GetUnitY(caster)
        endif
        call GroupEnumUnitsInRange(g, cx, cy, radius, null)
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            call GroupRemoveUnit(g, u)
            // Helpers existentes: validan héroe+héroe, bando y excluyen auto-heal.
            if (not IsUnitType(u, UNIT_TYPE_DEAD)) then
                if (isHeal) then
                    call MB_RegisterHealTimestamp(u, caster)
                else
                    call MB_RegisterControlTimestamp(u, caster)
                endif
            endif
        endloop
    endif

    call DestroyGroup(g)
    set g = null
    set u = null
endfunction

// --- DETECTOR: DAÑO ---
function MB_OnDamage takes nothing returns nothing
    local real dmg = GetEventDamage()
    // Solo registramos si el daño es > 0
    if (dmg > 0) then
        call MB_RegisterTimestamp(GetTriggerUnit(), GetEventDamageSource(), dmg)
    endif
endfunction

// ==========================================================================
// TIER B+C — HABILIDADES AoE CON RETARDO / PERIÓDICAS
// ==========================================================================
// Algunas AoE no impactan en el frame del casteo: el Infernal cae ~1.2s
// después, los Cohetes golpean en ráfagas durante 1.2s, y el Volcán arroja
// rocas cada X segundos durante toda su vida. Para estas NO sirve el enum
// inmediato: programamos enum(s) diferido(s) con un timer.
//
// CLAVE DE ROBUSTEZ: el contexto del timer guarda el PLAYER ID del caster,
// no su unidad. Así, si el caster muere o abandona antes del impacto, el
// enum sigue funcionando sin punteros colgantes.
//
// Contexto en MB_AoEHash, parent = GetHandleId(timer):
//   key 0 = pid (jugador caster) | 1 = cx | 2 = cy | 3 = radio | 4 = ticks restantes

// Callback: enumera el área guardada y sella control (key 600+pid) a enemigos.
function MB_AoETimerFire takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer hid = GetHandleId(t)
    local integer pid = LoadInteger(MB_AoEHash, hid, 0)
    local real cx = LoadReal(MB_AoEHash, hid, 1)
    local real cy = LoadReal(MB_AoEHash, hid, 2)
    local real radius = LoadReal(MB_AoEHash, hid, 3)
    local integer ticks = LoadInteger(MB_AoEHash, hid, 4)
    local player caster = Player(pid)
    local real time = TimerGetElapsed(MB_Timer)
    local group g = CreateGroup()
    local unit u

    call GroupEnumUnitsInRange(g, cx, cy, radius, null)
    loop
        set u = FirstOfGroup(g)
        exitwhen u == null
        call GroupRemoveUnit(g, u)
        if (IsUnitType(u, UNIT_TYPE_HERO) and not IsUnitType(u, UNIT_TYPE_DEAD) and not IsUnitIllusion(u)) then
            if (IsPlayerEnemy(GetOwningPlayer(u), caster)) then
                call SaveReal(udg_MB_Hash, GetPlayerId(GetOwningPlayer(u)), 600 + pid, time)
            endif
        endif
    endloop
    call DestroyGroup(g)

    // Decrementar ticks. Al agotarse, liberar timer y contexto.
    set ticks = ticks - 1
    if (ticks <= 0) then
        call FlushChildHashtable(MB_AoEHash, hid)
        call PauseTimer(t)
        call DestroyTimer(t)
    else
        call SaveInteger(MB_AoEHash, hid, 4, ticks)
    endif

    set g = null
    set u = null
    set t = null
endfunction

// Programa enum(s) diferido(s). ticks<=1 → un solo disparo tras 'delay'.
// ticks>1 → periódico cada 'interval' (primer disparo a los 'interval' seg).
function MB_AoESchedule takes integer pid, real cx, real cy, real radius, real delay, real interval, integer ticks returns nothing
    local timer t = CreateTimer()
    local integer hid = GetHandleId(t)
    call SaveInteger(MB_AoEHash, hid, 0, pid)
    call SaveReal(MB_AoEHash, hid, 1, cx)
    call SaveReal(MB_AoEHash, hid, 2, cy)
    call SaveReal(MB_AoEHash, hid, 3, radius)
    call SaveInteger(MB_AoEHash, hid, 4, ticks)
    if (ticks <= 1) then
        call TimerStart(t, delay, false, function MB_AoETimerFire)
    else
        call TimerStart(t, interval, true, function MB_AoETimerFire)
    endif
    set t = null
endfunction

// Dispatcher de las AoE con retardo/periódicas. No-op si el spellId no aplica.
function MB_OnAoEDelayed takes integer sid, unit caster returns nothing
    local integer pid = GetPlayerId(GetOwningPlayer(caster))
    local real tx = GetSpellTargetX()
    local real ty = GetSpellTargetY()
    local integer level = GetUnitAbilityLevel(caster, sid)
    local real radius

    if (sid == 'AUin' or sid == 'A00B') then
        // Infernal / Mago Infernal: stun al caer. Editor dice 1.0s de retraso;
        // usamos 1.2s para enumerar DESPUÉS de que el stun ya se aplicó (ver nota).
        // Área del stun (6 niveles):
        if (level == 1) then
            set radius = 250.0
        elseif (level == 2) then
            set radius = 275.0
        elseif (level == 3) then
            set radius = 300.0
        elseif (level == 4) then
            set radius = 325.0
        elseif (level == 5) then
            set radius = 350.0
        elseif (level == 6) then
            set radius = 375.0
        else
            set radius = 250.0
        endif
        call MB_AoESchedule(pid, tx, ty, radius, 1.2, 0.0, 1)
    elseif (sid == 'AIin') then
        // Ítem Infernal ('infs'): clon del ulti Infernal pero como ítem. Sin niveles,
        // así que área fija 250. Mismo retraso (1.0s oficial + 0.2s de margen = 1.2s).
        call MB_AoESchedule(pid, tx, ty, 250.0, 1.2, 0.0, 1)
    elseif (sid == 'ANcs') then
        // Cohetes de Dispersión: duración 1.2s, daño cada 0.25s → ~5 impactos.
        // Área fija 275 en los 10 niveles.
        call MB_AoESchedule(pid, tx, ty, 275.0, 0.0, 0.25, 5)
    endif
    // Volcán (ANvc) y Trampa Eléctrica (Asta): DESCARTADOS por decisión de diseño.
endfunction

// --- DETECTOR: HECHIZOS (CONTROL SIN DAÑO + CURACIÓN) ---
function MB_OnSpell takes nothing returns nothing
    local integer sid = GetSpellAbilityId()
    
    // A) Hechizo de Control sin daño → registrar timestamp de control (key 600+i)
    if (MB_IsControlSpell(sid)) then
        call MB_RegisterControlTimestamp(GetSpellTargetUnit(), GetTriggerUnit())
    endif
    
    // B) Hechizo de Curación → registrar como interacción de apoyo
    if (MB_IsHealSpell(sid)) then
        call MB_RegisterHealTimestamp(GetSpellTargetUnit(), GetTriggerUnit())
    endif

    // C) Habilidad de Área instantánea (control o curación) → enum sellado por caster.
    // Función segura: si el spellId no está en sus tablas, no hace nada.
    call MB_OnAoEAbility(sid, GetTriggerUnit())

    // D) Habilidad de Área con retardo/periódica (Tier B+C) → enum diferido.
    // Función segura: si el spellId no aplica, no hace nada.
    call MB_OnAoEDelayed(sid, GetTriggerUnit())
endfunction

// --- 2. ACTUALIZAR FILA (CON ASISTENCIAS) ---
function MB_UpdateRow takes player p returns nothing
    local integer id = GetPlayerId(p)
    local integer row = LoadInteger(udg_MB_Hash, id, 0)
    local integer kills = LoadInteger(udg_MB_Hash, id, 1)
    local integer deaths = LoadInteger(udg_MB_Hash, id, 2)
    local integer assists = LoadInteger(udg_MB_Hash, id, 4) // Key 4: Asistencias
    // Key 103: fila atenuada (el slot ya no lo juega NADIE: leaver/kick/DROP, o
    // re-expulsión de un bot). Si está activo, los valores se reescriben en gris
    // para no romper el atenuado al actualizar K/D/A (p.ej. asistencia póstuma de
    // un leaver, o héroe que muere durante la votación). El BOT lo deja en false.
    local boolean faded = LoadBoolean(udg_MB_Hash, id, 103)
    local string pre = ""
    local string suf = ""
    local multiboarditem mb_item

    if (row == 0) then
        return
    endif

    if (faded) then
        set pre = "|cff222222"
        set suf = "|r"
    endif

    // Columna 2: Kills (0=icono, 1=nombre)
    set mb_item = MultiboardGetItem(udg_MB_Tabla, row - 1, 2)
    call MultiboardSetItemValue(mb_item, pre + I2S(kills) + suf)
    call MultiboardSetItemStyle(mb_item, true, false)
    call MultiboardReleaseItem(mb_item)

    // Columna 3: Deaths
    set mb_item = MultiboardGetItem(udg_MB_Tabla, row - 1, 3)
    call MultiboardSetItemValue(mb_item, pre + I2S(deaths) + suf)
    call MultiboardSetItemStyle(mb_item, true, false)
    call MultiboardReleaseItem(mb_item)

    // Columna 4: Assists
    set mb_item = MultiboardGetItem(udg_MB_Tabla, row - 1, 4)
    call MultiboardSetItemValue(mb_item, pre + I2S(assists) + suf)
    call MultiboardSetItemStyle(mb_item, true, false)
    call MultiboardReleaseItem(mb_item)

    set mb_item = null
endfunction

// --- 3. EVENTO: MATAR (CALCULO K/D/A CON TIMER SEGURO) ---
function Trig_MB_Kill_Actions takes nothing returns nothing
    local unit killerUnit = GetKillingUnit()
    local unit victimUnit = GetDyingUnit()
    local player pKiller = GetOwningPlayer(killerUnit)
    local player pVictim = GetOwningPlayer(victimUnit)
    local integer idK = GetPlayerId(pKiller)
    local integer idV = GetPlayerId(pVictim)
    
    // Variables para Asistencias
    local integer i = 0
    local real lastHitTime = 0.0
    local real ctrlTime = 0.0
    local real healTime = 0.0
    local real accDmg = 0.0
    local real currentTime = TimerGetElapsed(MB_Timer)
    local integer assistCount = 0
    local integer allyAssists = 0
    local integer enemyAssists = 0
    // Umbral de daño mínimo: 5% de la vida máxima de la víctima.
    // Ajusta este valor si quieres un umbral más alto o más bajo.
    local real threshold = 0.0
    
    // Excluimos ilusiones: su "muerte" no debe dar kill/death/asistencia ni
    // limpiar los timestamps del jugador dueño (las claves son por jugador).
    if (IsUnitType(victimUnit, UNIT_TYPE_HERO) and not IsUnitIllusion(victimUnit)) then

        // Calcular umbral (5% del HP máximo de la víctima al morir)
        set threshold = GetUnitState(victimUnit, UNIT_STATE_MAX_LIFE) * 0.05
        
        // A) Kill
        if (pKiller != null and IsPlayerEnemy(pKiller, pVictim)) then
            call SaveInteger(udg_MB_Hash, idK, 1, LoadInteger(udg_MB_Hash, idK, 1) + 1)
            call MB_UpdateRow(pKiller)
        endif

        // B) Death
        call SaveInteger(udg_MB_Hash, idV, 2, LoadInteger(udg_MB_Hash, idV, 2) + 1)
        call MB_UpdateRow(pVictim)
        
        // C) ASISTENCIAS POR DAÑO O CONTROL
        // Daño: requiere ventana de 10s + daño acumulado >= 5% HP máximo.
        // Control: solo requiere ventana de 10s (sin umbral de daño).
        
        loop
            exitwhen i > 9
            // El jugador (i) no debe ser el asesino (si aplica) Y debe ser enemigo de la víctima
            if (i != idK or idK < 0 or idK > 9) then
                if (IsPlayerEnemy(Player(i), pVictim)) then
                    
                    set lastHitTime = LoadReal(udg_MB_Hash, idV, 200 + i)
                    set ctrlTime = LoadReal(udg_MB_Hash, idV, 600 + i)
                    set accDmg = LoadReal(udg_MB_Hash, idV, 500 + i)
                    
                    // Vía 1: Daño dentro de ventana Y supera el umbral mínimo
                    if ( (currentTime - lastHitTime) <= 10.0 and lastHitTime > 0.0 and accDmg >= threshold ) then
                        call SaveInteger(udg_MB_Hash, i, 4, LoadInteger(udg_MB_Hash, i, 4) + 1)
                        call MB_UpdateRow(Player(i))
                        call DisplayTimedTextToPlayer(Player(i), 0, 0, 7.0, "|cff00FF00+1 Asistencia|r")
                        set assistCount = assistCount + 1
                        call SaveBoolean(udg_MB_Hash, idV, 400 + i, true)
                        // Vía 2: Hechizo de control dentro de ventana (sin umbral)
                    elseif ( (currentTime - ctrlTime) <= 10.0 and ctrlTime > 0.0 ) then
                        call SaveInteger(udg_MB_Hash, i, 4, LoadInteger(udg_MB_Hash, i, 4) + 1)
                        call MB_UpdateRow(Player(i))
                        call DisplayTimedTextToPlayer(Player(i), 0, 0, 7.0, "|cff00FF00+1 Asistencia|r")
                        set assistCount = assistCount + 1
                        call SaveBoolean(udg_MB_Hash, idV, 400 + i, true)
                    endif
                endif
            endif
            set i = i + 1
        endloop
        
        // C2) ASISTENCIAS POR CURACIÓN
        // Si un healer curó al asesino dentro de la ventana de 10s, recibe asistencia.
        // Solo aplica si el asesino es un jugador válido (0-9) y no se le dio asistencia ya.
        if (idK >= 0 and idK <= 9) then
            set i = 0
            loop
                exitwhen i > 9
                if (i != idK) then
                    if (LoadBoolean(udg_MB_Hash, idV, 400 + i) != true) then
                        if (IsPlayerEnemy(Player(i), pVictim)) then
                            
                            set healTime = LoadReal(udg_MB_Hash, idK, 300 + i)
                            
                            if ( (currentTime - healTime) <= 10.0 and healTime > 0.0 ) then
                                call SaveInteger(udg_MB_Hash, i, 4, LoadInteger(udg_MB_Hash, i, 4) + 1)
                                call MB_UpdateRow(Player(i))
                                call DisplayTimedTextToPlayer(Player(i), 0, 0, 7.0, "|cff00FF00+1 Asistencia (Curación)|r")
                                set assistCount = assistCount + 1
                                call SaveBoolean(udg_MB_Hash, idV, 400 + i, true)
                            endif
                        endif
                    endif
                endif
                set i = i + 1
            endloop
        endif
        
        // C3) NOTIFICACIÓN AL ASESINO
        // Distinguir asistencias aliadas vs enemigas respecto al killer.
        if (assistCount > 0 and idK >= 0 and idK <= 9) then
            // Contar cuántas asistencias fueron para aliados del killer
            // y cuántas para enemigos del killer.
            set i = 0
            loop
                exitwhen i > 9
                if (i != idK) then
                    // ¿Este jugador (i) recibió asistencia en esta kill?
                    if (LoadBoolean(udg_MB_Hash, idV, 400 + i) == true) then
                        if (IsPlayerAlly(Player(i), Player(idK))) then
                            set allyAssists = allyAssists + 1
                        else
                            set enemyAssists = enemyAssists + 1
                        endif
                    endif
                endif
                set i = i + 1
            endloop
            
            // Mensaje para asistencias aliadas
            if (allyAssists > 0) then
                if (allyAssists == 1) then
                    call DisplayTimedTextToPlayer(Player(idK), 0, 0, 7.0, "|cff00FF00+1 asistencia para aliados|r")
                else
                    call DisplayTimedTextToPlayer(Player(idK), 0, 0, 7.0, "|cff00FF00+" + I2S(allyAssists) + " asistencias para aliados|r")
                endif
            endif
            
            // Mensaje para asistencias enemigas (caso teamkill)
            if (enemyAssists > 0) then
                if (enemyAssists == 1) then
                    call DisplayTimedTextToPlayer(Player(idK), 0, 0, 7.0, "|cffFF4444+1 asistencia para enemigos|r")
                else
                    call DisplayTimedTextToPlayer(Player(idK), 0, 0, 7.0, "|cffFF4444+" + I2S(enemyAssists) + " asistencias para enemigos|r")
                endif
            endif
        endif
        
        // D) Limpieza de timestamps (sobre la víctima)
        set i = 0
        loop
            exitwhen i > 9
            call RemoveSavedReal(udg_MB_Hash, idV, 200 + i)   // Timestamp daño
            call RemoveSavedReal(udg_MB_Hash, idV, 500 + i)   // Daño acumulado
            call RemoveSavedReal(udg_MB_Hash, idV, 600 + i)   // Timestamp control
            call RemoveSavedBoolean(udg_MB_Hash, idV, 400 + i) // Flag anti-duplicado
            // NOTA: Heal timestamps (key 300+i) NO se limpian. Expiran solos por ventana de 10s.
            set i = i + 1
        endloop
    endif
    
    set killerUnit = null
    set victimUnit = null
    set pKiller = null
    set pVictim = null
endfunction

// --- FUNCIÓN AUXILIAR: SOLTAR ITEMS EN BASE Y BORRAR HEROE ---
function MB_DropItems takes player p returns nothing
    local group g = CreateGroup()
    local unit u
    local item it
    local integer i = 0
    // CAMBIO 1: Calculamos la coordenada X,Y de la "Casa" (Start Location) del jugador
    local integer locationID = GetPlayerStartLocation(p)
    local real baseX = GetStartLocationX(locationID)
    local real baseY = GetStartLocationY(locationID)
    
    call GroupEnumUnitsOfPlayer(g, p, null)
    
    loop
        set u = FirstOfGroup(g)
        exitwhen u == null
        call GroupRemoveUnit(g, u)
        
        // Verificamos si es un Héroe para salvar sus items
        if (IsUnitType(u, UNIT_TYPE_HERO)) then
            set i = 0
            loop
                exitwhen i > 5
                set it = UnitItemInSlot(u, i)
                if (it != null) then
                    call UnitRemoveItem(u, it)
                    // CAMBIO 2: Teletransportamos el item a la Base (Seguridad)
                    call SetItemPosition(it, baseX, baseY)
                endif
                set i = i + 1
            endloop
        endif
        
        // CAMBIO 3: El héroe desaparece del mapa (Nadie gana XP ni oro extra)
        call RemoveUnit(u)
    endloop
    
    call DestroyGroup(g)
    set g = null
    set u = null
    set it = null
endfunction

// --- FADE ROW: Atenúa toda la fila de un jugador que abandonó ---
// Cambia nombre y stats a gris apagado (|cccffffff) para indicar que ya no juega.
// El nombre y los datos K/D/A se conservan visibles pero atenuados.
function MB_FadeRow takes integer id returns nothing
    local integer row = LoadInteger(udg_MB_Hash, id, 0)
    local integer kills = LoadInteger(udg_MB_Hash, id, 1)
    local integer deaths = LoadInteger(udg_MB_Hash, id, 2)
    local integer assists = LoadInteger(udg_MB_Hash, id, 4)
    local string name = LoadStr(udg_MB_Hash, id, 5)
    local multiboarditem mb_item
    
    if (row == 0) then
        return
    endif

    // Marcar la fila como atenuada para que MB_UpdateRow respete el gris al
    // refrescar K/D/A (asistencia póstuma del leaver, muerte durante la votación).
    call SaveBoolean(udg_MB_Hash, id, 103, true)

    // Columna 1: Nombre atenuado. El icono (columna 0) no se oscurece:
    // si el jugador habia escogido, conserva el retrato normal.
    set mb_item = MultiboardGetItem(udg_MB_Tabla, row - 1, 1)
    call MultiboardSetItemValue(mb_item, "|cff222222" + name + "|r")
    call MultiboardSetItemStyle(mb_item, true, false)
    call MultiboardReleaseItem(mb_item)
    
    // Columna 2: Kills atenuado
    set mb_item = MultiboardGetItem(udg_MB_Tabla, row - 1, 2)
    call MultiboardSetItemValue(mb_item, "|cff222222" + I2S(kills) + "|r")
    call MultiboardSetItemStyle(mb_item, true, false)
    call MultiboardReleaseItem(mb_item)
    
    // Columna 3: Deaths atenuado
    set mb_item = MultiboardGetItem(udg_MB_Tabla, row - 1, 3)
    call MultiboardSetItemValue(mb_item, "|cff222222" + I2S(deaths) + "|r")
    call MultiboardSetItemStyle(mb_item, true, false)
    call MultiboardReleaseItem(mb_item)
    
    // Columna 4: Assists atenuado
    set mb_item = MultiboardGetItem(udg_MB_Tabla, row - 1, 4)
    call MultiboardSetItemValue(mb_item, "|cff222222" + I2S(assists) + "|r")
    call MultiboardSetItemStyle(mb_item, true, false)
    call MultiboardReleaseItem(mb_item)
    
    set mb_item = null
endfunction

// --- EVENTO: SALIR (SOLO SI NO FUE PROCESADO ANTES) ---
function Trig_MB_Leaver_Actions takes nothing returns nothing
    local player p = GetTriggerPlayer()
    local integer id = GetPlayerId(p)
    
    // Guard: No procesar si la partida ya terminó (victoria/derrota)
    if (SistemaVoto_Voto_GameOver) then
        set p = null
        return
    endif
    
    // CRUCIAL: ¿Ya lo limpió el comando kick?
    // Si es TRUE, significa que el Sistema_Kick ya hizo todo (Sonido, items, tabla).
    // Así que nos detenemos aquí para no repetir cosas.
    if (LoadBoolean(udg_MB_Hash, id, 101) == true) then
        // El kick ya atenuo la fila. Solo re-evaluamos si el equipo ya puede
        // revelar sus iconos; no repetimos sonido, items ni votacion.
        call MB_CheckRevealStates()
        set p = null
        return 
    endif
    
    // --- SI LLEGAMOS AQUI, FUE UN LEAVER VOLUNTARIO (ALT+F4 / SALIR) ---
    
    // 1. MENSAJE DE ABANDONO
    call Replay_DisplayTimedTextToAll(5.0, MB_GetColor(p) + GetPlayerName(p) + "|r ha abandonado la partida.")

    // 2. ATENUAR FILA EN LA TABLA (Nombre + K/D/A en gris)
    call MB_FadeRow(id)

    // El desertor deja de ser requisito. Antes de revelar conserva el icono
    // provisional; al revelar, sin heroe muestra la interrogacion y con heroe lo conserva.
    call MB_CheckRevealStates()

    // 3. INICIAR VOTACIÓN (El sistema de voto decide qué hacer con el héroe)
    call SistemaVoto_OnPlayerLeave(p)

    // 4. SONIDO (Usamos la variable global reciclada, sin destruirla)
    call StartSound(MB_Snd_Leave)
    
    set p = null
endfunction

// --- CRONÓMETRO: Actualiza el título del Multiboard cada segundo ---
function MB_UpdateClock takes nothing returns nothing
    local real elapsed = TimerGetElapsed(MB_Timer)
    local integer totalSec = R2I(elapsed)
    local integer mins = totalSec / 60
    local integer secs = totalSec - (mins * 60)
    local string sMin = ""
    local string sSec = ""

    // Formato con cero a la izquierda
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

    call MultiboardSetTitleText(udg_MB_Tabla, "Orcos vs Humanos  -   |cff6EACCE" + sMin + ":" + sSec + "|r")

    // Salvavidas para cambios de estado externos (kick/BOT/DROP). Despues de
    // revelar ambas facciones, MB_TryRevealTeam retorna inmediatamente.
    if (not MB_HumanIconsRevealed or not MB_OrcIconsRevealed) then
        call MB_CheckRevealStates()
    endif
endfunction

// --- 5. INICIALIZACIÓN (Diseño UI: Estilo Original Preservado) ---
function Trig_MB_Init_Actions takes nothing returns nothing
    local integer i = 0
    local integer rows = 0
    local integer currentRow = 0
    local multiboarditem mb_item
    local player p
    
    // Mantenemos esto aquí ya que descartamos el cambio de "Race Condition"
    set udg_MB_Hash = InitHashtable()
    
    // --- CREAR TABLA ---
    set MB_BoardReady = false
    set udg_MB_Tabla = CreateMultiboard()
    call MultiboardSetColumnCount(udg_MB_Tabla, 5)
    call MultiboardSetTitleText(udg_MB_Tabla, "Orcos vs Humanos")
    
    // --- CABECERAS ---
    call MultiboardSetRowCount(udg_MB_Tabla, 1)
    
    // Columna 0: Icono independiente (cabecera vacia)
    set mb_item = MultiboardGetItem(udg_MB_Tabla, 0, 0)
    call MultiboardSetItemValue(mb_item, " ")
    call MultiboardSetItemWidth(mb_item, MB_ICON_WIDTH)
    call MultiboardSetItemStyle(mb_item, false, false)
    call MultiboardReleaseItem(mb_item)

    // Columna 1: Jugadores. Se conserva EXACTAMENTE el ancho probado.
    set mb_item = MultiboardGetItem(udg_MB_Tabla, 0, 1)
    call MultiboardSetItemValue(mb_item, " ")
    call MultiboardSetItemWidth(mb_item, 0.1024) // Ajuste extremo
    call MultiboardSetItemStyle(mb_item, true, false)
    call MultiboardReleaseItem(mb_item)
    
    // Columna 2: Kills
    set mb_item = MultiboardGetItem(udg_MB_Tabla, 0, 2)
    call MultiboardSetItemValue(mb_item, "|cffFFCC00K|r")
    call MultiboardSetItemWidth(mb_item, 0.014) // Ajuste extremo
    call MultiboardSetItemStyle(mb_item, true, false)
    call MultiboardReleaseItem(mb_item)
    
    // Columna 3: Deaths
    set mb_item = MultiboardGetItem(udg_MB_Tabla, 0, 3)
    call MultiboardSetItemValue(mb_item, "|cffFFCC00D|r")
    call MultiboardSetItemWidth(mb_item, 0.014) // Ajuste extremo
    call MultiboardSetItemStyle(mb_item, true, false)
    call MultiboardReleaseItem(mb_item)

    // Columna 4: Assists
    set mb_item = MultiboardGetItem(udg_MB_Tabla, 0, 4)
    call MultiboardSetItemValue(mb_item, "|cffFFCC00A|r")
    call MultiboardSetItemWidth(mb_item, 0.014) // Ajuste extremo
    call MultiboardSetItemStyle(mb_item, true, false)
    call MultiboardReleaseItem(mb_item)
    
    set currentRow = 1 

    // --- BLOQUE HUMANOS (0 al 4) ---
    set i = 0
    loop
        exitwhen i > 4
        set p = Player(i)
        if (GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING) then
            set rows = rows + 1
            call MultiboardSetRowCount(udg_MB_Tabla, currentRow + 1)
            call SaveInteger(udg_MB_Hash, i, 0, currentRow + 1)
            
            // Icono provisional humano. No comparte ancho con el nick.
            set mb_item = MultiboardGetItem(udg_MB_Tabla, currentRow, 0)
            call MultiboardSetItemValue(mb_item, "")
            call MultiboardSetItemWidth(mb_item, MB_ICON_WIDTH)
            call MultiboardSetItemIcon(mb_item, MB_ICON_HUMAN_PLACEHOLDER)
            call MultiboardSetItemStyle(mb_item, false, true)
            call MultiboardReleaseItem(mb_item)

            // Nombre
            // Guardar nombre en Hash (key 5) para poder recuperarlo en MB_FadeRow
            call SaveStr(udg_MB_Hash, i, 5, GetPlayerName(p))
            
            set mb_item = MultiboardGetItem(udg_MB_Tabla, currentRow, 1)
            call MultiboardSetItemValue(mb_item, MB_GetColor(p) + GetPlayerName(p) + "|r")
            call MultiboardSetItemWidth(mb_item, 0.1024) // Ajuste extremo
            call MultiboardSetItemStyle(mb_item, true, false)
            call MultiboardReleaseItem(mb_item)
            
            // Kills
            set mb_item = MultiboardGetItem(udg_MB_Tabla, currentRow, 2)
            call MultiboardSetItemValue(mb_item, "0")
            call MultiboardSetItemWidth(mb_item, 0.014) // Ajuste extremo
            call MultiboardSetItemStyle(mb_item, true, false)
            call MultiboardReleaseItem(mb_item)
            
            // Deaths
            set mb_item = MultiboardGetItem(udg_MB_Tabla, currentRow, 3)
            call MultiboardSetItemValue(mb_item, "0")
            call MultiboardSetItemWidth(mb_item, 0.014) // Ajuste extremo
            call MultiboardSetItemStyle(mb_item, true, false)
            call MultiboardReleaseItem(mb_item)

            // Assists
            set mb_item = MultiboardGetItem(udg_MB_Tabla, currentRow, 4)
            call MultiboardSetItemValue(mb_item, "0")
            call MultiboardSetItemWidth(mb_item, 0.014) // Ajuste extremo
            call MultiboardSetItemStyle(mb_item, true, false)
            call MultiboardReleaseItem(mb_item)
            
            set currentRow = currentRow + 1
        endif
        set i = i + 1
    endloop

    // --- SEPARADOR (cubre las 5 columnas sin alterar sus anchos) ---
    call MultiboardSetRowCount(udg_MB_Tabla, currentRow + 1)
    set i = 0
    loop
        exitwhen i > 4
        set mb_item = MultiboardGetItem(udg_MB_Tabla, currentRow, i)
        call MultiboardSetItemValue(mb_item, " ")
        if (i == 0) then
            call MultiboardSetItemWidth(mb_item, MB_ICON_WIDTH)
            call MultiboardSetItemStyle(mb_item, false, false)
        elseif (i == 1) then
            call MultiboardSetItemWidth(mb_item, 0.1024)
            call MultiboardSetItemStyle(mb_item, true, false)
        else
            call MultiboardSetItemWidth(mb_item, 0.014)
            call MultiboardSetItemStyle(mb_item, true, false)
        endif
        call MultiboardReleaseItem(mb_item)
        set i = i + 1
    endloop
    set currentRow = currentRow + 1

    // --- BLOQUE ORCOS (5 al 9) ---
    set i = 5
    loop
        exitwhen i > 9
        set p = Player(i)
        if (GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING) then
            set rows = rows + 1
            call MultiboardSetRowCount(udg_MB_Tabla, currentRow + 1)
            call SaveInteger(udg_MB_Hash, i, 0, currentRow + 1)
            
            // Icono provisional orco. No comparte ancho con el nick.
            set mb_item = MultiboardGetItem(udg_MB_Tabla, currentRow, 0)
            call MultiboardSetItemValue(mb_item, "")
            call MultiboardSetItemWidth(mb_item, MB_ICON_WIDTH)
            call MultiboardSetItemIcon(mb_item, MB_ICON_ORC_PLACEHOLDER)
            call MultiboardSetItemStyle(mb_item, false, true)
            call MultiboardReleaseItem(mb_item)

            // Nombre
            // Guardar nombre en Hash (key 5) para poder recuperarlo en MB_FadeRow
            call SaveStr(udg_MB_Hash, i, 5, GetPlayerName(p))
            
            set mb_item = MultiboardGetItem(udg_MB_Tabla, currentRow, 1)
            call MultiboardSetItemValue(mb_item, MB_GetColor(p) + GetPlayerName(p) + "|r")
            call MultiboardSetItemWidth(mb_item, 0.1024) // Ajuste extremo
            call MultiboardSetItemStyle(mb_item, true, false)
            call MultiboardReleaseItem(mb_item)
            
            // Kills
            set mb_item = MultiboardGetItem(udg_MB_Tabla, currentRow, 2)
            call MultiboardSetItemValue(mb_item, "0")
            call MultiboardSetItemWidth(mb_item, 0.014) // Ajuste extremo
            call MultiboardSetItemStyle(mb_item, true, false)
            call MultiboardReleaseItem(mb_item)
            
            // Deaths
            set mb_item = MultiboardGetItem(udg_MB_Tabla, currentRow, 3)
            call MultiboardSetItemValue(mb_item, "0")
            call MultiboardSetItemWidth(mb_item, 0.014) // Ajuste extremo
            call MultiboardSetItemStyle(mb_item, true, false)
            call MultiboardReleaseItem(mb_item)

            // Assists
            set mb_item = MultiboardGetItem(udg_MB_Tabla, currentRow, 4)
            call MultiboardSetItemValue(mb_item, "0")
            call MultiboardSetItemWidth(mb_item, 0.014) // Ajuste extremo
            call MultiboardSetItemStyle(mb_item, true, false)
            call MultiboardReleaseItem(mb_item)
            
            set currentRow = currentRow + 1
        endif
        set i = i + 1
    endloop
    
    // La tabla ya esta completa: capturar picks tempranos y comprobar si cada
    // faccion puede revelar. Todos los clientes ejecutan el mismo cambio.
    set MB_BoardReady = true
    call MB_CaptureExistingHeroes()
    call MB_CheckRevealStates()

    // VISIBILIDAD
    call MultiboardDisplay(udg_MB_Tabla, true)
    call MultiboardMinimize(udg_MB_Tabla, false)

    // CRONÓMETRO: Iniciar actualización cada 1 segundo
    set MB_ClockTimer = CreateTimer()
    call TimerStart(MB_ClockTimer, 1.00, true, function MB_UpdateClock)
    
    set mb_item = null
endfunction

// --- FUNCIÓN AUXILIAR: CONECTAR SENSOR DE DAÑO ---
// Esta función se activa cada vez que una unidad entra al mapa (o se crea).
function MB_Register_Damage_Event takes nothing returns nothing
    local unit u = GetTriggerUnit() // La unidad que entró/nació
    
    // Si es un Héroe, le conectamos el cable para detectar cuando le pegan.
    if (IsUnitType(u, UNIT_TYPE_HERO)) then
        call TriggerRegisterUnitEvent(gg_trg_tabla, u, EVENT_UNIT_DAMAGED)

        // El mismo nacimiento sirve para recordar el heroe elegido. Ilusiones
        // y slots ajenos al 0-9 se descartan dentro de MB_RecordHero.
        call MB_RecordHero(u)
    endif
    
    set u = null
endfunction

//===========================================================================
// INICIALIZACIÓN FINAL (CON FIX DE TIMER + FIX DE SONIDO)
//===========================================================================
function InitTrig_tabla takes nothing returns nothing
    local trigger tInit = CreateTrigger()
    local trigger tKill = CreateTrigger()
    local trigger tLeave = CreateTrigger()
    local trigger tEnter = CreateTrigger()
    local integer i = 0
    
    // 1. INICIAR LA BASE DE DATOS (0.00s)
    set udg_MB_Hash = InitHashtable()
    set MB_AoEHash = InitHashtable()   // Contexto de timers Tier B+C

    // 2. FIX RELOJ (Vital para asistencias)
    // Iniciamos el timer01 para que el conteo de los 5 segundos funcione.
    call TimerStart(MB_Timer, 100000.0, false, null)

    // 3. FIX SONIDO (Precarga real: Crear el sonido globalmente una sola vez)
    // Al no usar KillSoundWhenDone, evitamos el bug de duración=0 en la primera reproducción.
    set MB_Snd_Leave = CreateSound("Sound\\Interface\\CreepAggroWhat1.wav", false, false, false, 10, 10, "")
    call SetSoundVolume(MB_Snd_Leave, 127)

    // Sonido "equipo listo" (experimental): MISMO patron. Se crea aqui UNA sola
    // vez y se reutiliza con StartSound. Nunca KillSoundWhenDone ni CreateSound
    // en el momento de sonar: eso deja muda la primera reproduccion.
    if (MB_TEAMREADY_SOUND_ENABLED) then
        set MB_Snd_TeamReady = CreateSound(MB_SND_TEAMREADY_PATH, false, false, false, 10, 10, "")
        call SetSoundVolume(MB_Snd_TeamReady, 127)
    endif

    // 4. TRIGGER GLOBAL DE TABLA
    set gg_trg_tabla = CreateTrigger()
    
    // 5. REGISTROS DE COMBATE
    // A) Acción de Daño (Sensor principal)
    call TriggerAddAction(gg_trg_tabla, function MB_OnDamage)
    
    // B) Sensor de Entrada (Conecta el sensor de daño a héroes nuevos)
    call TriggerRegisterEnterRectSimple(tEnter, GetPlayableMapRect())
    call TriggerAddAction(tEnter, function MB_Register_Damage_Event)
    
    // C) Hechizos (Control sin daño)
    set tKill = CreateTrigger() 
    call TriggerRegisterAnyUnitEventBJ(tKill, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(tKill, function MB_OnSpell)
    set tKill = null 

    // 6. OTROS EVENTOS (Tabla visual, Kills, Leavers)
    call TriggerRegisterTimerEvent(tInit, 2.00, false)
    call TriggerAddAction(tInit, function Trig_MB_Init_Actions)

    // Evento Muerte    
    set tKill = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(tKill, EVENT_PLAYER_UNIT_DEATH)
    call TriggerAddAction(tKill, function Trig_MB_Kill_Actions)
    
    loop
        exitwhen i > 9
        call TriggerRegisterPlayerEvent(tLeave, Player(i), EVENT_PLAYER_LEAVE)
        call TriggerRegisterPlayerEvent(tLeave, Player(i), EVENT_PLAYER_DEFEAT) 
        set i = i + 1
    endloop
    call TriggerAddAction(tLeave, function Trig_MB_Leaver_Actions)
    
    set tInit = null
    set tKill = null
    set tLeave = null
    set tEnter = null
endfunction
