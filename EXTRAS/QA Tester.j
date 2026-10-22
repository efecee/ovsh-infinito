scope QATest initializer Init

    // ============================================================================
    // ?? ZONA DE CONFIGURACIÓN DEL TESTER (Modifica estos valores según necesites)
    // ============================================================================
    globals
        // 1. EL HÉROE A PROBAR: Coloca el ID de 4 letras de tu héroe.
        // (Ejemplo: Darth'Remar es 'H00G', un Blademaster es 'Obla')
        private constant integer HERO_ID = 'Nplh'

        // 2. NIVEL DEL HÉROE: Ponlo en 10 o más. Así tendrás todos los puntos 
        // de habilidad disponibles para leer los tooltips al subir de nivel.
        private constant integer HERO_LEVEL = 40

        // 3. RECURSOS: Por si necesitas comprar ítems en alguna tienda cercana.
        private constant integer BOLSITA_ORO = 100000
        private constant integer BOLSITA_MADERA = 10

        // 4. GENERADOR DE ENEMIGOS: ¿Quieres blancos de prueba?
        private constant boolean SPAWN_ENEMIES = true
    
        // 5. ID DEL ENEMIGO DE PRUEBA: 'hfoo' es el Soldado Raso humano.
        // Puedes cambiarlo por el ID de una torre o un creep de tu mapa.
        private constant integer ENEMY_DUMMY_ID = 'Ntin'
    endglobals
    // ============================================================================

    private function Actions takes nothing returns nothing
        // === DECLARACIÓN DE VARIABLES LOCALES (Siempre van arriba) ===
        local player p = Player(0)
        local player enemy = Player(1)
        local real x = GetStartLocationX(0)
        local real y = GetStartLocationY(0)
        local unit myHero
        local group g = CreateGroup() // <-- Creamos un grupo para los enemigos
        local unit dummy              // <-- Variable para seleccionar de a uno

        // --- PASO 1: Inyectar Recursos ---
        call SetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD, BOLSITA_ORO)
        call SetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER, BOLSITA_MADERA)

        // --- PASO 2: Crear tu Héroe de Prueba ---
        set myHero = CreateUnit(p, HERO_ID, x, y, 270.0)

        // --- PASO 3: Subir de Nivel ---
        call SetHeroLevel(myHero, HERO_LEVEL, true)
        call ModifyHeroSkillPoints(myHero, bj_MODIFYMETHOD_SET, HERO_LEVEL)

        // --- PASO 4: Generar 2 blancos de prueba al Sur (Abajo) ---
        if SPAWN_ENEMIES then
            call CreateUnit(enemy, ENEMY_DUMMY_ID, x - 100, y - 300, 180.0)
            call CreateUnit(enemy, ENEMY_DUMMY_ID, x + 100, y - 300, 180.0)
        endif

        // --- PASO 4.5: EL TRUCO DEL "ENEMIGO CONTROLADO" ---
        call SetPlayerAlliance(enemy, p, ALLIANCE_SHARED_VISION, true)
        call SetPlayerAlliance(enemy, p, ALLIANCE_SHARED_CONTROL, true)
    
        // 1. El Azul declara la guerra al Rojo
        call SetPlayerAlliance(enemy, p, ALLIANCE_PASSIVE, false)
        call SetPlayerState(enemy, PLAYER_STATE_ALLIED_VICTORY, 0)

        // 2. El Rojo le declara la guerra al Azul (¡Esto era lo que faltaba!)
        call SetPlayerAlliance(p, enemy, ALLIANCE_PASSIVE, false)
        call SetPlayerState(p, PLAYER_STATE_ALLIED_VICTORY, 0)

        // --- PASO 4.75 (CORREGIDO): MANTENER POSICIÓN ---
        // 1. Ordenamos a nuestro héroe
        call IssueImmediateOrder(myHero, "holdposition")
    
        // 2. Agrupamos a todos los enemigos creados y les damos la orden uno por uno
        call GroupEnumUnitsOfPlayer(g, enemy, null)
        loop
            set dummy = FirstOfGroup(g)
            exitwhen dummy == null // Si el grupo está vacío, salimos del bucle
            call IssueImmediateOrder(dummy, "holdposition")
            call GroupRemoveUnit(g, dummy) // Lo sacamos del grupo para pasar al siguiente
        endloop

        // --- PASO 5: Auto-Selección ---
        call SelectUnitForPlayerSingle(myHero, p)

        // === LIMPIEZA DE MEMORIA (Para evitar Lag) ===
        call DestroyGroup(g)
        set p = null
        set enemy = null
        set myHero = null
        set g = null
        set dummy = null
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        // Usamos un Timer de 0.1 segundos en lugar de "Map Initialization".
        // Esto evita que el motor se crashee al cargar muchos datos de golpe al inicio.
        call TriggerRegisterTimerEventSingle(t, 0.1)
        call TriggerAddAction(t, function Actions)
        set t = null
    endfunction

endscope