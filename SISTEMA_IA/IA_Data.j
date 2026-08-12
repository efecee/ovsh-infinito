library IAData initializer OnInit requires IADataItems

    globals
        private hashtable dataDb = InitHashtable()
        
        // --- CONSTANTES DE ATRIBUTO PRINCIPAL ---
        public constant integer ATTR_STR = 1
        public constant integer ATTR_AGI = 2
        public constant integer ATTR_INT = 3
        
        // --- CONSTANTES ESTÁNDAR (Fallback) ---
        public constant real DEFAULT_RANGE_MELEE = 128.0
        public constant real DEFAULT_RANGE_RANGED = 550.0
        public constant real DEFAULT_DMG_POINT = 0.40 
        public constant real DEFAULT_BASE_COOLDOWN = 0.60
        public constant real DEFAULT_PROJ_SPEED = 900.0
        public constant real DEFAULT_MOVE_SPEED = 300.0
        public constant real DEFAULT_CAST_POINT = 0.50
        public constant real DEFAULT_CAST_BACKSWING = 0.50
        public constant real BASE_DAMAGE_AVG = 30.0
        public constant real BASE_ARMOR_AVG = 2.0
    

        // Enumeración de datos en la hashtable
        private constant integer FIELD_ARMOR_BASE = 1
        private constant integer FIELD_DAMAGE_BASE = 2
        private constant integer FIELD_RANGE = 3
        private constant integer FIELD_PRIMARY_ATTR = 4
        private constant integer FIELD_IS_MELEE = 5
    
        // Atributos
        private constant integer FIELD_STR_BASE = 6
        private constant integer FIELD_AGI_BASE = 7
        private constant integer FIELD_INT_BASE = 8
        private constant integer FIELD_STR_PLVL = 9
        private constant integer FIELD_AGI_PLVL = 10
        private constant integer FIELD_INT_PLVL = 11

        // Dados
        private constant integer FIELD_DICE_NUM = 12
        private constant integer FIELD_DICE_SIDES = 13

        // Tiempos y Velocidades
        private constant integer FIELD_DMG_POINT = 14
        private constant integer FIELD_BASE_COOLDOWN = 15
        private constant integer FIELD_PROJ_SPEED = 16
        private constant integer FIELD_MOVE_SPEED = 17
        private constant integer FIELD_CAST_POINT = 18
        private constant integer FIELD_CAST_BACKSWING = 19

        // Peligrosidad táctica del héroe (modulador de distancia de seguridad).
        private constant integer FIELD_DANGER = 20
    endglobals

    // ==========================================
    //            API DE REGISTRO
    // ==========================================
    private function RegisterHeroStats takes integer unitId, real armorBase, real dmgBase, integer diceNum, integer diceSides, real atkRange, integer primaryAttr, boolean isMelee returns nothing
        call SaveReal(dataDb, unitId, FIELD_ARMOR_BASE, armorBase)
        call SaveReal(dataDb, unitId, FIELD_DAMAGE_BASE, dmgBase)
        call SaveInteger(dataDb, unitId, FIELD_DICE_NUM, diceNum)
        call SaveInteger(dataDb, unitId, FIELD_DICE_SIDES, diceSides)
        call SaveReal(dataDb, unitId, FIELD_RANGE, atkRange)
        call SaveInteger(dataDb, unitId, FIELD_PRIMARY_ATTR, primaryAttr)
        call SaveBoolean(dataDb, unitId, FIELD_IS_MELEE, isMelee)
    endfunction

    private function RegisterHeroAttributes takes integer unitId, real strBase, real agiBase, real intBase, real strPerLvl, real agiPerLvl, real intPerLvl returns nothing
        call SaveReal(dataDb, unitId, FIELD_STR_BASE, strBase)
        call SaveReal(dataDb, unitId, FIELD_AGI_BASE, agiBase)
        call SaveReal(dataDb, unitId, FIELD_INT_BASE, intBase)
        call SaveReal(dataDb, unitId, FIELD_STR_PLVL, strPerLvl)
        call SaveReal(dataDb, unitId, FIELD_AGI_PLVL, agiPerLvl)
        call SaveReal(dataDb, unitId, FIELD_INT_PLVL, intPerLvl)
    endfunction

    private function RegisterHeroDynamics takes integer unitId, real dmgPoint, real baseCooldown, real projSpeed, real moveSpeed, real castPoint, real castBackswing returns nothing
        call SaveReal(dataDb, unitId, FIELD_DMG_POINT, dmgPoint)
        call SaveReal(dataDb, unitId, FIELD_BASE_COOLDOWN, baseCooldown)
        call SaveReal(dataDb, unitId, FIELD_PROJ_SPEED, projSpeed)
        call SaveReal(dataDb, unitId, FIELD_MOVE_SPEED, moveSpeed)
        call SaveReal(dataDb, unitId, FIELD_CAST_POINT, castPoint)
        call SaveReal(dataDb, unitId, FIELD_CAST_BACKSWING, castBackswing)
    endfunction

    // (d) Registro de PELIGROSIDAD TÁCTICA por héroe.
    // 'danger' es un MULTIPLICADOR de la penalización de seguridad que usa el bot
    // al puntuar a un héroe enemigo en IA_State_Laning. Interpretación:
    //   1.0  = neutro (default, no cambia nada).
    //   >1.0 = más peligroso => el bot guarda MÁS distancia / lo persigue menos.
    //          (héroes de burst/CC fuerte: 1.3, 1.6, 2.0...)
    //   <1.0 = blando/farmeable => el bot se anima a acercarse más. (0.8, 0.6...)
    // Solo necesitas registrar las EXCEPCIONES; lo no registrado vale 1.0.
    private function RegisterHeroDanger takes integer unitId, real danger returns nothing
        call SaveReal(dataDb, unitId, FIELD_DANGER, danger)
    endfunction

    // ==========================================
    //            API DE CONSULTAS
    // ==========================================

    // 0. Obtener Peligrosidad Táctica (multiplicador de penalización de seguridad)
    // Consumidor: IA_State_Laning (modula safetyPenalty al puntuar héroes enemigos).
    public function GetHeroDanger takes integer heroTypeId returns real
        if HaveSavedReal(dataDb, heroTypeId, FIELD_DANGER) then
            return LoadReal(dataDb, heroTypeId, FIELD_DANGER)
        endif
        return 1.0 // Neutro: comportamiento idéntico al actual hasta poblar la tabla.
    endfunction

    // 1. Obtener Rango
    public function GetHeroAttackRange takes unit u returns real
        local integer id = GetUnitTypeId(u)
        if HaveSavedReal(dataDb, id, FIELD_RANGE) then
            return LoadReal(dataDb, id, FIELD_RANGE)
        endif
        if IsUnitType(u, UNIT_TYPE_MELEE_ATTACKER) then
            return DEFAULT_RANGE_MELEE
        endif
        return DEFAULT_RANGE_RANGED
    endfunction

    // 2. Obtener Punto de Daño (Delay)
    public function GetHeroDamagePoint takes unit u returns real
        local integer id = GetUnitTypeId(u)
        if HaveSavedReal(dataDb, id, FIELD_DMG_POINT) then
            return LoadReal(dataDb, id, FIELD_DMG_POINT)
        endif
        return DEFAULT_DMG_POINT
    endfunction

    // 2b. Obtener Base Cooldown (Backswing físico)
    public function GetHeroBaseCooldown takes unit u returns real
        local integer id = GetUnitTypeId(u)
        if HaveSavedReal(dataDb, id, FIELD_BASE_COOLDOWN) then
            return LoadReal(dataDb, id, FIELD_BASE_COOLDOWN)
        endif
        return DEFAULT_BASE_COOLDOWN
    endfunction

    // 2c. Obtener Velocidad de Proyectil
    public function GetHeroProjectileSpeed takes unit u returns real
        local integer id = GetUnitTypeId(u)
        if HaveSavedReal(dataDb, id, FIELD_PROJ_SPEED) then
            return LoadReal(dataDb, id, FIELD_PROJ_SPEED)
        endif
        return DEFAULT_PROJ_SPEED
    endfunction

    // 2d. Obtener Velocidad de Movimiento Base
    public function GetHeroMovementSpeedBase takes unit u returns real
        local integer id = GetUnitTypeId(u)
        if HaveSavedReal(dataDb, id, FIELD_MOVE_SPEED) then
            return LoadReal(dataDb, id, FIELD_MOVE_SPEED)
        endif
        return DEFAULT_MOVE_SPEED
    endfunction

    // 2e. Obtener Cast Point (Punto de Lanzamiento)
    public function GetHeroCastPoint takes unit u returns real
        local integer id = GetUnitTypeId(u)
        if HaveSavedReal(dataDb, id, FIELD_CAST_POINT) then
            return LoadReal(dataDb, id, FIELD_CAST_POINT)
        endif
        return DEFAULT_CAST_POINT
    endfunction

    // 2f. Obtener Cast Backswing (Recuperación de Lanzamiento)
    public function GetHeroCastBackswing takes unit u returns real
        local integer id = GetUnitTypeId(u)
        if HaveSavedReal(dataDb, id, FIELD_CAST_BACKSWING) then
            return LoadReal(dataDb, id, FIELD_CAST_BACKSWING)
        endif
        return DEFAULT_CAST_BACKSWING
    endfunction

    // 3. Obtener Daño Estimado Real (Daño Base + Dados + Atributo + Ítems)
    public function GetHeroEstimatedDamage takes unit u returns real
        local integer id = GetUnitTypeId(u)
        local real dmg = BASE_DAMAGE_AVG
        local integer diceNum = 0
        local integer diceSides = 0
        local integer attrType = ATTR_STR
        local integer attrValue = 0
        local real bonusDice = 0.0
        local real itemDmg = 0.0
        local integer i
        local item it

        if HaveSavedReal(dataDb, id, FIELD_DAMAGE_BASE) then
            set dmg = LoadReal(dataDb, id, FIELD_DAMAGE_BASE)
            set diceNum = LoadInteger(dataDb, id, FIELD_DICE_NUM)
            set diceSides = LoadInteger(dataDb, id, FIELD_DICE_SIDES)
            set attrType = LoadInteger(dataDb, id, FIELD_PRIMARY_ATTR)
            
            if diceNum > 0 and diceSides > 0 then
                set bonusDice = I2R(diceNum) * (1.0 + I2R(diceSides)) / 2.0
            endif

            if attrType == ATTR_STR then
                set attrValue = GetHeroStr(u, true)
            elseif attrType == ATTR_AGI then
                set attrValue = GetHeroAgi(u, true)
            else
                set attrValue = GetHeroInt(u, true)
            endif
            
            // Sumar daño plano de ítems — Consulta O(1) via IADataItems
            set i = 0
            loop
                exitwhen i > 5
                set it = UnitItemInSlot(u, i)
                if it != null then
                    set itemDmg = itemDmg + IADataItems_GetFlatDamage(GetItemTypeId(it))
                endif
                set i = i + 1
            endloop
            
            return dmg + bonusDice + I2R(attrValue) + itemDmg
        endif
        
        // Fallback para unidades no registradas
        return BASE_DAMAGE_AVG + I2R(GetHeroStr(u, true))
    endfunction

    // 3b. Obtener Daño "Blanco" (Base + Dados + Atributo, SIN Ítems)
    // Es la porción de daño afectada por multiplicadores % (BEar, B00R).
    // Consumidor: IA_Utils.GetHeroDPS (separar white de green damage).
    public function GetHeroWhiteDamage takes unit u returns real
        local integer id = GetUnitTypeId(u)
        local real dmg = BASE_DAMAGE_AVG
        local integer diceNum = 0
        local integer diceSides = 0
        local integer attrType = ATTR_STR
        local integer attrValue = 0
        local real bonusDice = 0.0

        if HaveSavedReal(dataDb, id, FIELD_DAMAGE_BASE) then
            set dmg = LoadReal(dataDb, id, FIELD_DAMAGE_BASE)
            set diceNum = LoadInteger(dataDb, id, FIELD_DICE_NUM)
            set diceSides = LoadInteger(dataDb, id, FIELD_DICE_SIDES)
            set attrType = LoadInteger(dataDb, id, FIELD_PRIMARY_ATTR)

            if diceNum > 0 and diceSides > 0 then
                set bonusDice = I2R(diceNum) * (1.0 + I2R(diceSides)) / 2.0
            endif

            if attrType == ATTR_STR then
                set attrValue = GetHeroStr(u, true)
            elseif attrType == ATTR_AGI then
                set attrValue = GetHeroAgi(u, true)
            else
                set attrValue = GetHeroInt(u, true)
            endif

            return dmg + bonusDice + I2R(attrValue)
        endif

        return BASE_DAMAGE_AVG + I2R(GetHeroStr(u, true))
    endfunction

    // 4. Obtener Armadura Estimada Real (Armadura Base + Agilidad*0.3)
    public function GetHeroEstimatedArmor takes unit u returns real
        local integer id = GetUnitTypeId(u)
        local real baseArmor = BASE_ARMOR_AVG
        local real currentAgi = I2R(GetHeroAgi(u, true))
        
        if HaveSavedReal(dataDb, id, FIELD_ARMOR_BASE) then
            set baseArmor = LoadReal(dataDb, id, FIELD_ARMOR_BASE)
        endif
        
        // Fórmula nativa clásica: Armadura Base + (Agilidad Actual * 0.3)
        // Nota: Agilidad actual ya incluye sumas por objetos e ítems comprados en 1.27b.
        return baseArmor + (currentAgi * 0.3)
    endfunction

    // 5. Obtener Atributo Principal del héroe (ATTR_STR=1, ATTR_AGI=2, ATTR_INT=3)
    // Consumidor: IA_State_Shopping (decidir qué ítems comprar según atributo).
    // IMPORTANTE: Recibe heroTypeId (NO la unidad), para poder usar el ID original
    // del héroe sin importar si está transformado en otra forma.
    public function GetPrimaryAttr takes integer heroTypeId returns integer
        if HaveSavedInteger(dataDb, heroTypeId, FIELD_PRIMARY_ATTR) then
            return LoadInteger(dataDb, heroTypeId, FIELD_PRIMARY_ATTR)
        endif
        return ATTR_AGI // Fallback conservador
    endfunction

    // ==========================================
    //       INICIALIZACIÓN DE LA BASE DE DATOS
    // ==========================================
    private function OnInit takes nothing returns nothing
        // ------------------------------------------------------------------------------------------------------------------------
        // GUÍA DE RELLENADO (LEER CUIDADOSAMENTE):
        // 
        // 1. EL ID: Usa comillas simples ('Ekee'). Si el código tiene 4 letras o números (Ej: E005), va igual ('E005').
        // 2. DAÑO BASE Y DADOS: Es el "Daño Base", "Cantidad de Dados" (ua1d) y "Caras por Dado" (ua1s). (Ej: 0.0, 2, 4 para 0 base y 2d4).
        //    (JASS calculará Atributo + Daño Base + Promedio de Dados automáticamente).
        // 3. ARMADURA BASE: Es "Combate - Defensa Base".
        // 4. RANGO DE ATAQUE: Es "Combate - Ataque 1 - Alcance". (NO uses "Adquisición de alcance").
        // 5. ATTR: ATTR_STR (Fuerza), ATTR_AGI (Agilidad), ATTR_INT (Inteligencia). Escríbelos usando estas variables.
        // 6. MELEE: true (cuerpo a cuerpo) o false (arqueros/magos).
        // 7. DYNAMICS: Punto de Daño (udp1), Base Cooldown (ua1c), Velocidad Proyectil (ua1z, 0 para Melee), Velocidad Movimiento (umvs), Cast Point (ucpt), Cast Backswing (ucbs).
        // ------------------------------------------------------------------------------------------------------------------------

        // ------------------------------------------
        // EQUIPO HUMANOS (19 Héroes)
        // ------------------------------------------
        // 01 [H] Guardián del Bosque
        call RegisterHeroStats(       'Ekee', 0.0, 0.0, 2, 4, 600.0, ATTR_INT, false)
        call RegisterHeroAttributes(  'Ekee', 16.0, 15.0, 18.0,   1.8, 1.5, 2.7) // Fue, Agi, Int  | +Fue, +Agi, +Int
        call RegisterHeroDynamics(    'Ekee', 0.400, 1.90, 900.0, 370.0, 0.700, 0.800)
        
        // 02 [H] Sacerdotisa de la Luna
        call RegisterHeroStats(       'Emoo', 0.0, 0.0, 2, 6, 600.0, ATTR_AGI, false)
        call RegisterHeroAttributes(  'Emoo', 18.0, 21.0, 15.0,   2.0, 3.0, 1.5)
        call RegisterHeroDynamics(    'Emoo', 0.300, 2.20, 900.0, 320.0, 0.500, 0.830)
        
        // 03 [H] Cazador de Demonios
        call RegisterHeroStats(       'Edem', 0.0, 2.0, 2, 12, 100.0, ATTR_AGI, true)
        call RegisterHeroAttributes(  'Edem', 19.0, 22.0, 16.0,   2.4, 2.25, 2.1)
        call RegisterHeroDynamics(    'Edem', 0.300, 1.70, 0.0, 320.0, 0.300, 0.470)
        
        // 04 [H] Guardiana
        call RegisterHeroStats(       'Ewar', 0.0, 2.0, 2, 11, 100.0, ATTR_AGI, true)
        call RegisterHeroAttributes(  'Ewar', 18.0, 20.0, 15.0,   2.0, 3.0, 2.0)
        call RegisterHeroDynamics(    'Ewar', 0.300, 1.90, 0.0, 320.0, 0.500, 0.830)
        
        // 05 [H] Paladin
        call RegisterHeroStats(       'Hpal', 2.0, 0.0, 2, 6, 100.0, ATTR_STR, true)
        call RegisterHeroAttributes(  'Hpal', 22.0, 13.0, 17.0,   3.0, 1.65, 1.8)
        call RegisterHeroDynamics(    'Hpal', 0.433, 2.20, 0.0, 310.0, 0.500, 1.670)
        
        // 06 [H] Archimago
        call RegisterHeroStats(       'Hamg', 3.0, 0.0, 2, 4, 600.0, ATTR_INT, false)
        call RegisterHeroAttributes(  'Hamg', 20.0, 20.0, 19.0,   2.0, 2.0, 3.3)
        call RegisterHeroDynamics(    'Hamg', 0.550, 2.13, 900.0, 320.0, 0.300, 2.400)
        
        // 07 [H] Rey de la Montaña
        call RegisterHeroStats(       'Hmkg', 2.0, 0.0, 2, 6, 100.0, ATTR_STR, true)
        call RegisterHeroAttributes(  'Hmkg', 24.0, 11.0, 15.0,   3.1, 1.5, 1.5)
        call RegisterHeroDynamics(    'Hmkg', 0.350, 2.22, 0.0, 270.0, 0.400, 0.500)
        
        // 08 [H] Mago sanguinario
        call RegisterHeroStats(       'Hblm', 0.0, 0.0, 2, 4, 600.0, ATTR_INT, false)
        call RegisterHeroAttributes(  'Hblm', 18.0, 14.0, 19.0,   2.0, 1.5, 3.0)
        call RegisterHeroDynamics(    'Hblm', 0.550, 2.13, 900.0, 300.0, 0.300, 2.400)
        
        // 09 [H] Alquimista
        call RegisterHeroStats(       'Nalc', 2.0, 0.0, 3, 10, 100.0, ATTR_STR, true)
        call RegisterHeroAttributes(  'Nalc', 22.0, 11.0, 17.0,   3.0, 1.5, 1.8)
        call RegisterHeroDynamics(    'Nalc', 0.350, 2.20, 0.0, 270.0, 0.400, 0.500)
        
        // 10 [H] Hojalatero
        call RegisterHeroStats(       'Ntin', 2.0, 0.0, 2, 4, 128.0, ATTR_STR, true)
        call RegisterHeroAttributes(  'Ntin', 24.0, 15.0, 15.0,   3.2, 1.8, 1.65)
        call RegisterHeroDynamics(    'Ntin', 0.350, 2.00, 0.0, 290.0, 0.530, 0.500)
        
        // 11 [H] Alquimista pandaren
        call RegisterHeroStats(       'Npbm', 2.0, 0.0, 2, 6, 100.0, ATTR_STR, true)
        call RegisterHeroAttributes(  'Npbm', 22.0, 14.0, 15.0,   3.0, 1.5, 1.5)
        call RegisterHeroDynamics(    'Npbm', 0.350, 2.22, 0.0, 270.0, 0.400, 0.500)
        
        // 12 [H] Lord Garithos
        call RegisterHeroStats(       'Hlgr', 2.0, 0.0, 2, 6, 100.0, ATTR_STR, true)
        call RegisterHeroAttributes(  'Hlgr', 22.0, 13.0, 17.0,   3.5, 2.0, 1.5)
        call RegisterHeroDynamics(    'Hlgr', 0.433, 2.20, 0.0, 270.0, 0.500, 1.670)

        // 13 [H] Sylvanas (Versión Humana/Elfa, 0.50, 0.50)
        call RegisterHeroStats(       'Hvwd', 0.0, 0.0, 2, 6, 600.0, ATTR_AGI, false)
        call RegisterHeroAttributes(  'Hvwd', 14.0, 23.0, 15.0,   1.9, 2.6, 1.8)
        call RegisterHeroDynamics(    'Hvwd', 0.700, 2.20, 1100.0, 350.0, 0.300, 0.510)
        
        // 14 [H] Asesina (La personalizada E005, 0.50, 0.50)
        call RegisterHeroStats(       'E005', 0.0, 0.0, 2, 11, 100.0, ATTR_AGI, true)
        call RegisterHeroAttributes(  'E005', 18.0, 20.0, 15.0,   2.0, 2.85, 2.0)
        call RegisterHeroDynamics(    'E005', 0.300, 1.90, 0.0, 320.0, 0.500, 0.830)
        
        // 15 [H] Goblin Techies
        call RegisterHeroStats(       'H00U', 1.0, 0.0, 2, 6, 600.0, ATTR_INT, false)
        call RegisterHeroAttributes(  'H00U', 17.0, 15.0, 20.0,   2.15, 2.0, 2.8)
        call RegisterHeroDynamics(    'H00U', 0.350, 2.00, 1500.0, 305.0, 0.400, 0.400)
        
        // 16 [H] Sniper (El H00R, 0.50, 0.50)
        call RegisterHeroStats(       'H00R', 1.0, 0.0, 2, 6, 600.0, ATTR_AGI, false)
        call RegisterHeroAttributes(  'H00R', 20.0, 23.0, 19.0,   2.0, 2.1, 2.2)
        call RegisterHeroDynamics(    'H00R', 0.350, 1.80, 2000.0, 300.0, 0.001, 0.001)
        
        // 17 [H] Bandido
        call RegisterHeroStats(       'H00Q', 1.0, 0.0, 2, 6, 100.0, ATTR_AGI, true)
        call RegisterHeroAttributes(  'H00Q', 19.0, 24.0, 17.0,   2.0, 1.9, 2.2)
        call RegisterHeroDynamics(    'H00Q', 0.350, 1.90, 0.0, 305.0, 0.400, 0.500)
        
        // 18 [H] Magnadefender (O00B, 0.50, 0.50)
        call RegisterHeroStats(       'O00B', 2.0, 0.0, 2, 6, 128.0, ATTR_STR, true)
        call RegisterHeroAttributes(  'O00B', 25.0, 10.0, 14.0,   3.2, 1.6, 1.6)
        call RegisterHeroDynamics(    'O00B', 0.360, 2.05, 0.0, 290.0, 0.470, 0.800)
        
        // 19 [H] Darth'Remar
        call RegisterHeroStats(       'H00G', 0.0, 0.0, 2, 5, 600.0, ATTR_INT, false)
        call RegisterHeroAttributes(  'H00G', 16.0, 15.0, 19.0,   2.0, 1.6, 3.0)
        call RegisterHeroDynamics(    'H00G', 0.550, 1.50, 900.0, 285.0, 0.300, 2.400)

        // ------------------------------------------
        // EQUIPO ORCOS (18 Héroes)
        // ------------------------------------------
        // 01 [O] Maestro de las Espadas
        call RegisterHeroStats(       'Obla', 0.0, 2.0, 2, 12, 100.0, ATTR_AGI, true)
        call RegisterHeroAttributes(  'Obla', 18.0, 23.0, 16.0,   2.0, 2.7, 1.2)
        call RegisterHeroDynamics(    'Obla', 0.330, 1.75, 0.0, 300.0, 0.300, 0.510)
        
        // 02 [O] Vidente
        call RegisterHeroStats(       'Ofar', 0.0, 0.0, 2, 4, 600.0, ATTR_INT, false)
        call RegisterHeroAttributes(  'Ofar', 15.0, 18.0, 19.0,   2.0, 1.5, 3.5)
        call RegisterHeroDynamics(    'Ofar', 0.300, 2.28, 1200.0, 320.0, 0.300, 1.070)
        
        // 03 [O] Jefe Tauren
        call RegisterHeroStats(       'Otch', 2.0, 0.0, 2, 6, 128.0, ATTR_STR, true)
        call RegisterHeroAttributes(  'Otch', 25.0, 10.0, 14.0,   3.2, 1.6, 1.6)
        call RegisterHeroDynamics(    'Otch', 0.360, 2.00, 0.0, 250.0, 0.470, 0.800)
        
        // 04 [O] Cazador de sombras
        call RegisterHeroStats(       'Oshd', 0.0, 0.0, 2, 4, 600.0, ATTR_AGI, false)
        call RegisterHeroAttributes(  'Oshd', 15.0, 20.0, 17.0,   1.7, 3.0, 2.0)
        call RegisterHeroDynamics(    'Oshd', 0.300, 2.15, 900.0, 320.0, 0.300, 1.070)
        
        // 05 [O] Caballero de la Muerte
        call RegisterHeroStats(       'Udea', 2.0, 2.0, 2, 6, 100.0, ATTR_STR, true)
        call RegisterHeroAttributes(  'Udea', 25.0, 15.0, 18.0,   3.2, 1.6, 1.8)
        call RegisterHeroDynamics(    'Udea', 0.560, 1.95, 0.0, 320.0, 0.452, 1.008)
        
        // 06 [O] Lich
        call RegisterHeroStats(       'Ulic', 0.0, 0.0, 2, 4, 600.0, ATTR_INT, false)
        call RegisterHeroAttributes(  'Ulic', 15.0, 14.0, 20.0,   2.0, 1.25, 3.4)
        call RegisterHeroDynamics(    'Ulic', 0.460, 1.90, 900.0, 320.0, 0.400, 1.100)
        
        // 07 [O] Señor del terror
        call RegisterHeroStats(       'Udre', 2.0, 2.0, 2, 6, 100.0, ATTR_STR, true)
        call RegisterHeroAttributes(  'Udre', 20.0, 16.0, 18.0,   3.0, 1.5, 1.5)
        call RegisterHeroDynamics(    'Udre', 0.550, 1.95, 0.0, 285.0, 0.300, 1.530)
        
        // 08 [O] Señor de la cripta
        call RegisterHeroStats(       'Ucrl', 2.0, 2.0, 2, 4, 128.0, ATTR_STR, true)
        call RegisterHeroAttributes(  'Ucrl', 26.0, 14.0, 14.0,   3.0, 1.7, 1.6)
        call RegisterHeroDynamics(    'Ucrl', 0.460, 1.90, 0.0, 270.0, 0.400, 1.100)
        
        // 09 [O] Bruja de mar naga
        call RegisterHeroStats(       'Nngs', 0.0, 0.0, 2, 6, 600.0, ATTR_INT, false)
        call RegisterHeroAttributes(  'Nngs', 15.0, 16.0, 22.0,   2.0, 1.5, 3.0)
        call RegisterHeroDynamics(    'Nngs', 0.730, 1.90, 900.0, 320.0, 0.670, 0.400)
        
        // 10 [O] Señor del Fuego
        call RegisterHeroStats(       'Nfir', 0.0, 0.0, 2, 4, 550.0, ATTR_AGI, false)
        call RegisterHeroAttributes(  'Nfir', 15.0, 20.0, 18.0,   2.0, 2.0, 2.5)
        call RegisterHeroDynamics(    'Nfir', 0.500, 1.80, 1200.0, 320.0, 0.670, 0.400)
        
        // 11 [O] Señor del foso
        call RegisterHeroStats(       'Nplh', 2.0, 0.0, 2, 6, 100.0, ATTR_STR, true)
        call RegisterHeroAttributes(  'Nplh', 24.0, 14.0, 14.0,   3.2, 1.5, 1.5)
        call RegisterHeroDynamics(    'Nplh', 0.800, 2.00, 0.0, 300.0, 0.750, 0.510)
        
        // 12 [O] Nigromante
        call RegisterHeroStats(       'Nman', 0.0, 0.0, 1, 8, 520.0, ATTR_INT, false)
        call RegisterHeroAttributes(  'Nman', 15.0, 19.0, 35.0,   1.95, 1.15, 2.35)
        call RegisterHeroDynamics(    'Nman', 0.833, 1.30, 0.0, 250.0, 0.500, 0.510)
        
        // 13 [O] Grom Hellscream
        call RegisterHeroStats(       'Ogrh', 0.0, 2.0, 2, 12, 100.0, ATTR_AGI, true)
        call RegisterHeroAttributes(  'Ogrh', 19.0, 23.0, 16.0,   2.5, 1.75, 2.25)
        call RegisterHeroDynamics(    'Ogrh', 0.500, 1.75, 0.0, 320.0, 0.300, 0.510)
        
        // 14 [O] Sylvanas (Versión No-Muerta, 0.50, 0.50)
        call RegisterHeroStats(       'Usyl', 0.0, 0.0, 2, 6, 600.0, ATTR_AGI, false)
        call RegisterHeroAttributes(  'Usyl', 18.0, 19.0, 15.0,   1.9, 3.0, 2.6)
        call RegisterHeroDynamics(    'Usyl', 0.300, 2.20, 1100.0, 320.0, 0.400, 0.500)
        
        // 15 [O] Butcher Abomination
        call RegisterHeroStats(       'H00P', 1.0, 0.0, 2, 6, 100.0, ATTR_STR, true)
        call RegisterHeroAttributes(  'H00P', 23.0, 17.0, 19.0,   3.2, 1.7, 2.1)
        call RegisterHeroDynamics(    'H00P', 0.350, 2.00, 0.0, 300.0, 0.001, 0.001)
        
        // 16 [O] Naga Royal
        call RegisterHeroStats(       'H00V', 1.0, 0.0, 2, 6, 100.0, ATTR_STR, true)
        call RegisterHeroAttributes(  'H00V', 24.0, 15.0, 17.0,   3.2, 1.9, 2.2)
        call RegisterHeroDynamics(    'H00V', 0.350, 2.00, 0.0, 295.0, 0.400, 0.500)
        
        // 17 [O] Invocador del Trueno
        call RegisterHeroStats(       'H00K', 1.0, 0.0, 2, 6, 600.0, ATTR_INT, false)
        call RegisterHeroAttributes(  'H00K', 18.0, 14.0, 19.0,   2.0, 1.5, 2.5)
        call RegisterHeroDynamics(    'H00K', 0.550, 2.13, 900.0, 300.0, 0.300, 2.400)
        
        // 18 [O] Troll Berserker (El N020, 0.50, 0.50)
        call RegisterHeroStats(       'H020', 0.0, 0.0, 2, 6, 600.0, ATTR_STR, false)
        call RegisterHeroAttributes(  'N020', 21.0, 16.0, 19.0,   3.1, 1.8, 2.3)
        call RegisterHeroDynamics(    'N020', 0.150, 2.20, 1200.0, 300.0, 0.600, 0.300)

        // ------------------------------------------
        // UNIDADES ALTERNATIVAS (Transformaciones)
        // ------------------------------------------
        // Nota: Cuando un héroe se transforma, mantiene los atributos (Fue/Agi/Int) 
        // del héroe base. Sin embargo, el motor SÍ cambia su Rango, Cooldown (Tiempo Muerto)
        // y Animaciones de ataque. Por tanto, es vital registrar sus Estadísticas y Dinámicas.
        
        // 01 Cazador de Demonios (Forma Demonio 'Edmm') - (bien registrado)
        call RegisterHeroStats(       'Edmm', 0.0, 0.0, 2, 12, 600.0, ATTR_AGI, false)
        call RegisterHeroAttributes(  'Edmm', 22.0, 20.0, 16.0,   2.2, 1.5, 2.1)
        call RegisterHeroDynamics(    'Edmm', 0.260, 1.60, 900.0, 320.0, 0.300, 0.470)

        // 02 Alquimista (Furia Quimica 'Nal3')
        call RegisterHeroStats(       'Nal3', 0.0, 0.0, 2, 12, 100.0, ATTR_STR, true)
        call RegisterHeroAttributes(  'Nal3', 22.0, 20.0, 16.0,   2.2, 1.5, 2.1)
        call RegisterHeroDynamics(    'Nal3', 0.260, 0.90, 900.0, 420.0, 0.300, 0.470)

        // 03 Hojalatero (Robo Goblin 'Nrob')
        call RegisterHeroStats(       'Nrob', 0.0, 0.0, 2, 12, 100.0, ATTR_STR, true)
        call RegisterHeroAttributes(  'Nrob', 22.0, 20.0, 16.0,   2.2, 1.5, 2.1)
        call RegisterHeroDynamics(    'Nrob', 0.260, 1.50, 900.0, 420.0, 0.300, 0.470)

        // 04 Grom Hellscream (Sed de Sangre 'Opgh')
        call RegisterHeroStats(       'Opgh', 0.0, 0.0, 2, 12, 100.0, ATTR_STR, true)
        call RegisterHeroAttributes(  'Opgh', 22.0, 20.0, 16.0,   2.2, 1.5, 2.1)
        call RegisterHeroDynamics(    'Opgh', 0.260, 1.30, 900.0, 420.0, 0.300, 0.470)
        
        // 05 Troll Berserker (Soy Huskar 'N021')
        call RegisterHeroStats(       'N021', 0.0, 0.0, 2, 12, 100.0, ATTR_STR, true)
        call RegisterHeroAttributes(  'N021', 22.0, 20.0, 16.0,   2.2, 1.5, 2.1)
        call RegisterHeroDynamics(    'N021', 0.260, 0.90, 900.0, 420.0, 0.300, 0.470)

        // ------------------------------------------
        // (d) PELIGROSIDAD TÁCTICA
        // ------------------------------------------
        // SOLO registra las EXCEPCIONES; lo no listado vale 1.0 (neutro).
        //
        // RÚBRICA (danger = 1.0 + componentes, escala recomendada 0.6 .. 2.0):
        //   +0.5..0.6  CC que HABILITA el focus / NIEGA el escape (dormir, hex,
        //              atrapar, stun largo). Lo más valioso de castigar: gana
        //              tiempo para que el equipo enemigo llegue y te encierre.
        //   +0.2..0.3  CC medio (stun corto, slow fuerte) o CC en ÁREA a distancia.
        //   +0.1..0.2  invocaciones que bloquean el paso (infernal, etc.).
        //   +0.1..0.2  amenaza de ejecución OCULTA a los stats (procs de orbe,
        //              críticos, evasión).
        //   -0.2..0.3  héroe sin amenaza real estando solo (soporte de curación
        //              pura sin CC).
        // REGLA DEL PROYECTO: el daño blanco y la tankiness YA se miden por
        // stats (daño/armadura/HP registrados arriba). danger es SOLO para lo
        // que los stats NO ven. NO restes por "tiene poca vida" (eso ya lo ve
        // el scoring vía HP/armadura) ni sumes por "pega fuerte" (eso ya lo ve
        // GetHeroEstimatedDamage).
        //
        // DÓNDE PEGA (IA_State_Laning):
        //   * eleva safetyPenalty al targetearlo (el bot guarda más distancia);
        //   * danger >= 1.4 (DANGER_ANTICIPATE) además dispara la AMENAZA
        //     ANTICIPADA: en inferioridad local el bot toma distancia ANTES de
        //     recibir el combo, aunque aún no le hayan hecho ni un punto de daño.
        //
        // Resueltos con el usuario (2026-06-10):
        call RegisterHeroDanger('Udre', 1.9) // Señor del Terror: dormir (+0.6, habilita el focus aliado y niega el escape) + infernal con stun en área a distancia (+0.2) + bloqueador de caminos invocado (+0.1). Que él haga poco daño NO importa: el peligro es el CC.
        call RegisterHeroDanger('Nman', 1.3) // Nigromante: orbe relámpago con proc que detiene ~1s (+0.2; con su AS alta procea seguido) + ejecución a distancia con AS maximizada (+0.1). Su fragilidad ya la ven los stats: NO se resta.
        //
        // PLANTILLA (descomenta y puntúa con la rúbrica; las TRANSFORMACIONES
        // tienen rawcode propio — si la forma alterna conserva el CC, regístrala):
        //   call RegisterHeroDanger('Hmkg', 1.5)  // Rey de la Montaña: stun fuerte single-target
        //   call RegisterHeroDanger('Hamg', 1.3)  // Archimago: nova/slow en área
        //   call RegisterHeroDanger('Hpal', 0.8)  // Paladín: curación, poca amenaza estando solo
    endfunction

endlibrary