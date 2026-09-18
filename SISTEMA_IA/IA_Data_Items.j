// ==========================================================================
// IA_Data_Items.j — Base de Datos Centralizada de Ítems
// ==========================================================================
// Esquema SPARSE: Solo se guardan los campos que aplican a cada ítem.
// Consultas O(1) vía Hashtable. Si un campo no existe, retorna 0/false.
//
// CÓMO AGREGAR UN ÍTEM NUEVO:
//   1. Ir a la función OnInit al final de este archivo.
//   2. Añadir UNA línea por cada propiedad que aplique.
//   3. Listo. No tocar IA_Utils.j ni IA_Data.j.
//
// PLANTILLA MAESTRA: Ver la Esfera de Hielo 'ofro' como referencia.
// ==========================================================================

library IADataItems initializer OnInit

    globals
        private hashtable itemDb = null

        // ==============================
        // CAMPOS MECÁNICOS (Esquema Sparse)
        // Datos numéricos que la calculadora usa.
        // Solo crear la constante si existe en el juego.
        // ==============================
        constant integer ITEM_FIELD_FLAT_DAMAGE    = 1   // real: Daño plano verde (+X daño)
        constant integer ITEM_FIELD_ATTACK_SPEED   = 2   // real: % de AS pasivo (+0.25 = +25%)
        constant integer ITEM_FIELD_BUFF_ID        = 3   // integer: ID del buff que produce (on-hit O cast)
        constant integer ITEM_FIELD_GOLD_COST      = 4   // integer: Costo total en oro

        // --- Probabilidades de Activación (RNG) ---
        // Solo para ítems con efecto basado en probabilidad.
        // Si no se guardan, el efecto se considera GARANTIZADO.
        constant integer ITEM_FIELD_PROC_HERO      = 5   // real: Prob. vs Héroes (0.05 = 5%)
        constant integer ITEM_FIELD_PROC_UNIT      = 6   // real: Prob. vs Unidades normales
        constant integer ITEM_FIELD_PROC_SUMMON    = 7   // real: Prob. vs Invocaciones

        // --- Propiedades de Área ---
        // Radio genérico: splash de daño (ofir), aura de equipo (ajen),
        // revelación (dust), o espinas (I003). El contexto lo da el ítem.
        // Consumidor: IA_State_Combat (priorizar targets rodeados de enemigos).
        constant integer ITEM_FIELD_AOE_RADIUS     = 8   // real: Radio de efecto (splash, aura, reveal)

        // --- Stock y Disponibilidad ---
        // Consumidor: IA_Brain_Macro (priorizar compra temprana de ítems escasos).
        // La verificación REAL de stock se hace en runtime con natives de WC3.
        // Este campo es para PLANIFICACIÓN: "¿Es un recurso que puede agotarse?"
        constant integer ITEM_FIELD_MAX_STOCK       = 9   // integer: Stock máximo POR TIENDA (0 = ilimitado)

        // --- Sistema de Recetas ---
        constant integer ITEM_FIELD_RECIPE_COUNT   = 10  // integer: Número de componentes
        constant integer ITEM_FIELD_RECIPE_1       = 11  // integer: ID del componente 1
        constant integer ITEM_FIELD_RECIPE_2       = 12  // integer: ID del componente 2
        constant integer ITEM_FIELD_RECIPE_3       = 13  // integer: ID del componente 3
        constant integer ITEM_FIELD_RECIPE_4       = 14  // integer: ID del componente 4
        constant integer ITEM_FIELD_RECIPE_5       = 15  // integer: ID del componente 5
        constant integer ITEM_FIELD_RECIPE_6       = 16  // integer: ID del componente 6

        // ==============================
        // TAGS TÁCTICOS DEL ÍTEM (Bitmask, potencias de 2)
        // FUENTE ÚNICA DE VERDAD para las propiedades lógicas.
        // Combinables con +. Consultables vía HasTag().
        // ==============================
        constant integer ITEM_FIELD_TAGS           = 20  // integer: Combinación de ITEM_TAG_XXX

        // --- Propiedades de Ítems Activos (Casteables) ---
        // WC3 1.27b NO tiene natives para leer estos datos en runtime.
        // Consumidores: IA_State_Combat (decidir cuándo castear).
        constant integer ITEM_FIELD_CAST_RANGE     = 21  // real: Rango de casteo del ítem activo
        constant integer ITEM_FIELD_MANA_COST      = 22  // integer: Costo de maná para activar
        constant integer ITEM_FIELD_COOLDOWN       = 23  // real: Tiempo de recarga en segundos
        constant integer ITEM_FIELD_CHANNEL_TIME   = 41  // real: Duración de canalización (FSM pausa órdenes)

        // --- Propiedades de Resurrección ---
        // Consumidor: IA_State_Survival (ajustar agresividad con segunda vida).
        // Si REVIVE_DELAY > 0 → el ítem otorga resurrección automática.
        // NO crear ITEM_TAG_REVIVE: el campo ya expresa la propiedad.
        constant integer ITEM_FIELD_REVIVE_DELAY   = 24  // real: Segundos antes de revivir
        constant integer ITEM_FIELD_REVIVE_HP      = 25  // real: HP con el que revive

        // --- Estadísticas Defensivas ---
        // Consumidores: IA_Utils (calculadora de físicas: reducción de daño),
        //               IA_State_Survival (estimación de supervivencia).
        constant integer ITEM_FIELD_ARMOR          = 26  // real: Armadura plana (+X armor)
        constant integer ITEM_FIELD_BONUS_HP       = 27  // real: Vida máxima adicional (+X HP)

        // --- CC Integrado (para ítems sin buff único) ---
        // Cuando el stun es propiedad del ÍTEM, no de un buff separado.
        // Consumidor: IA_State_Combat (combo planning, cancel timing).
        constant integer ITEM_FIELD_STUN_HERO      = 28  // real: Duración stun en Héroes
        constant integer ITEM_FIELD_STUN_UNIT      = 29  // real: Duración stun en Unidades

        // --- Daño de Casteo ---
        // Diferente de FLAT_DAMAGE (auto-attack). Esto es daño al USAR el ítem.
        // Consumidor: IA_State_Combat (lethal check / kill steal).
        constant integer ITEM_FIELD_CAST_DAMAGE    = 30  // real: Daño en el impacto

        // --- Daño Anti-Invocaciones ---
        // Consumidor: IA_State_Combat ("¿Enemigo tiene summons? → ¿tengo anti-summon?")
        constant integer ITEM_FIELD_BONUS_DMG_SUMMON = 31 // real: Daño extra a invocaciones

        // --- Curación y Regeneración ---
        // Consumidores: IA_State_Survival (pasiva: regen estima supervivencia;
        //               activa: GetHealAmount > 0 → "tengo cura de emergencia").
        // NO crear ITEM_TAG_HEAL: el campo ya es la señal (mismo que REVIVE_DELAY).
        constant integer ITEM_FIELD_HP_REGEN       = 32  // real: Regeneración de HP/seg pasiva
        constant integer ITEM_FIELD_HEAL_AMOUNT    = 33  // real: Cura instantánea al consumir

        // --- Maná: Regeneración y Restauración ---
        // Consumidores: IA_State_Combat ("tengo maná para castear?"),
        //               IA_State_Survival ("necesito maná para escapar").
        // MANA_REGEN_PCT es porcentual (+0.25 = +25%), no plano como HP_REGEN.
        constant integer ITEM_FIELD_MANA_REGEN_PCT = 34  // real: % extra de regen de maná
        constant integer ITEM_FIELD_RESTORE_MANA   = 35  // real: Maná instantáneo al consumir

        // --- Atributos Primarios ---
        // Consumidores: IA_Utils (calculadora de físicas).
        //   STR → HP + regen HP.  AGI → AS + Armor.  INT → Maná + regen maná.
        constant integer ITEM_FIELD_BONUS_STR      = 36  // integer: +X Fuerza
        constant integer ITEM_FIELD_BONUS_AGI      = 37  // integer: +X Agilidad
        constant integer ITEM_FIELD_BONUS_INT      = 38  // integer: +X Inteligencia

        // --- Evasión ---
        // Consumidor: IA_Utils (calculadora de físicas: EHP efectivo),
        //             IA_State_Shopping ("¿Enemigo es melee/físico? → evasión vale").
        constant integer ITEM_FIELD_EVASION_PCT    = 39  // real: % de esquivar ataques (0.14 = 14%)

        // --- Velocidad de Movimiento ---
        // Consumidor: IA_Utils (calculadora de físicas: MS total),
        //             IA_State_Survival ("puedo escapar?").
        constant integer ITEM_FIELD_MOVE_SPEED     = 40  // real: Velocidad de movimiento plana (+60.0)

        // --- Costo Secundario (Madera) ---
        // Consumidor: IA_State_Shopping ("tengo oro Y madera suficiente?").
        // Solo se registra si el ítem cuesta madera además de oro.
        constant integer ITEM_FIELD_LUMBER_COST    = 43  // integer: Costo en madera

        // --- Golpe Crítico ---
        // Consumidor: IA_Utils (calculadora de DPS esperado).
        //   dps_esperado = dps_base * (1 + CRIT_CHANCE * (CRIT_MULT - 1))
        // Ambos campos son necesarios: chance sin multiplier no calcula nada.
        constant integer ITEM_FIELD_CRIT_CHANCE    = 44  // real: Probabilidad de crítico (0.30 = 30%)
        constant integer ITEM_FIELD_CRIT_MULTIPLIER = 45 // real: Multiplicador de daño (2.0 = x2)

        // --- Maná Máximo ---
        // Consumidor: IA_State_Combat ("tengo maná para castear?"),
        //             IA_State_Survival ("tengo maná para escapar").
        constant integer ITEM_FIELD_BONUS_MP       = 42  // real: Maná máximo adicional (+X MP)

        // --- Tienda y Disponibilidad Temporal ---
        // Consumidor: IA_State_Shopping (saber dónde y cuándo comprar).
        constant integer ITEM_FIELD_SHOP_TYPE      = 48  // integer: TypeId de la tienda que vende este ítem
        constant integer ITEM_FIELD_INITIAL_STOCK_DELAY = 49 // real: Segundos desde inicio de partida hasta estar disponible

        // --- Estado de Transformación ---
        // Consumidor: IA_State_Combat / IA_State_Shopping.
        //   "Tengo Power Treads en INT pero soy STR → clic N veces."
        //   Cadena circular: I017 → I019 → I018 → I017.
        constant integer ITEM_FIELD_NEXT_STATE     = 46  // integer: ID del ítem al hacer clic

        // --- Daño Porcentual Pasivo ---
        // Consumidor: IA_Utils (GetHeroDPS: multiplicador de daño blanco).
        // Para ítems que otorgan +X% de daño base SIN generar un buff de aura.
        // Los buffs de aura (BEar, B00R) se leen por separado desde buffDb.
        constant integer ITEM_FIELD_PCT_DAMAGE     = 47  // real: % de daño base (+0.20 = +20%)

        // --- Categoría funcional ---
        constant integer ITEM_TAG_OFFENSIVE        = 1     // Mejora daño/ataque
        constant integer ITEM_TAG_DEFENSIVE        = 2     // Mejora defensa/supervivencia
        constant integer ITEM_TAG_UTILITY          = 4     // Utilidad general (TP, Wards)

        // --- Tipo de efecto al golpear ---
        // NOTA: ORB_EFFECT = "Unique Attack Modifier" (UAM) en WC3.
        // Incluye Orbes de tienda Y otros modificadores exclusivos (ej: Hand).
        // Regla de la IA de compras: máximo 1 ítem con ORB_EFFECT por héroe.
        constant integer ITEM_TAG_ORB_EFFECT       = 8     // UAM: no acumula con otros ORB_EFFECT
        constant integer ITEM_TAG_SOFT_CC          = 16    // Aplica ralentización (Slow)
        constant integer ITEM_TAG_HARD_CC          = 32    // Aplica stun/root/disable
        constant integer ITEM_TAG_PROC_CHANCE      = 64    // Efecto NO garantizado (basado en RNG)

        // --- Propiedades de inventario ---
        constant integer ITEM_TAG_CONSUMABLE       = 128   // Se gasta (1 o más cargas) y desaparece
        constant integer ITEM_TAG_RECIPE_RESULT    = 256   // Es resultado de una fusión

        // --- Reglas de compra ---
        constant integer ITEM_TAG_UNIQUE_TEAM      = 512   // Solo 1 por equipo debe comprarlo
        constant integer ITEM_TAG_GRANTS_AA        = 1024  // Permite atacar unidades aéreas (melee)
        constant integer ITEM_TAG_AOE              = 2048  // Daño en área (splash). Priorizar targets rodeados.

        // --- Tipo de activación ---
        // Si tiene BUFF_ID + ACTIVE → el buff se aplica al CASTEAR (click en target).
        // Si tiene BUFF_ID sin ACTIVE → el buff se aplica al GOLPEAR (on-hit/orbe).
        constant integer ITEM_TAG_ACTIVE           = 4096  // Requiere activación manual (clic)

        // --- Visión e inteligencia ---
        // Consumidor: IA_State_Combat ("¿Enemigo invisible? → ¿tengo REVEAL?")
        constant integer ITEM_TAG_REVEAL           = 8192  // Revela unidades invisibles

        // --- Tipo de targeting ---
        // Consumidor: IA_State_Combat (qué native de WC3 emitir).
        // CAST_RANGE=0 → Self-cast (UseItemNoTarget).
        // CAST_RANGE>0 sin POINT_TARGET → Unit-Target (UseItemTarget).
        // CAST_RANGE>0 con POINT_TARGET → Point-Target (UseItemPoint).
        constant integer ITEM_TAG_POINT_TARGET     = 16384 // Se lanza a coordenadas X/Y

        // --- Interacción con sistema de buffs ---
        // Consumidor: IA_State_Combat (consulta cruzada con IA_Data_Buffs).
        // Flujo emergente: aliado tiene buff TAG_DEBUFF (no TAG_STUN)
        //   → buscar ITEM_TAG_PURGE en inventario → usar para limpiar.
        constant integer ITEM_TAG_PURGE            = 32768 // Disipa buffs/debuffs en el área

        // --- Restricción de tipo de ataque ---
        // Consumidor: IA_State_Shopping.
        //   if HasTag(itemId, ITEM_TAG_MELEE_ONLY) and IsRanged(hero) → NO comprar.
        //   if HasTag(itemId, ITEM_TAG_RANGED_ONLY) and IsMelee(hero) → NO comprar.
        // También aplica a la evaluación de equipo:
        //   "¿Mi equipo es mayormente ranged? → MELEE_ONLY vale menos."
        constant integer ITEM_TAG_MELEE_ONLY       = 65536  // Solo beneficia a unidades melee
        constant integer ITEM_TAG_RANGED_ONLY      = 131072 // Solo beneficia a unidades ranged

        // --- Prioridad de compra ---
        // Consumidor: IA_State_Shopping.
        //   Regla 1: if HasTag(itemId, ITEM_TAG_CORE) and !TengoCore() → comprar PRIMERO.
        //   Regla 2: if HasTag(itemId, ITEM_TAG_BOOTS) and YaTengoBotas() → NO comprar.
        constant integer ITEM_TAG_CORE             = 262144  // Obligatorio comprar al inicio
        constant integer ITEM_TAG_BOOTS            = 524288  // Solo 1 par de botas por héroe

        // --- Canalización y targeting aliado ---
        // Consumidor: IA_State_Macro / IA_State_Combat.
        //   CHANNELING: FSM no emite nuevas órdenes durante CHANNEL_TIME.
        //   TARGET_ALLY: usar UseItemTarget(aliado), no UseItemTarget(enemigo).
        constant integer ITEM_TAG_CHANNELING       = 1048576  // Canalización (no moverse)
        constant integer ITEM_TAG_TARGET_ALLY      = 2097152  // Se usa sobre un aliado

        // --- Protección mágica pasiva ---
        // Consumidor: IA_State_Combat ("soy inmune a un hechizo
        // dirigido → puedo ser más agresivo").
        // NO registrar cooldown del bloqueo: es interno de WC3,
        // la IA no puede controlarlo ni consultarlo.
        constant integer ITEM_TAG_SPELL_BLOCK      = 4194304  // Bloquea 1 hechizo dirigido

        // --- Exclusividad por héroe ---
        // Consumidor: IA_State_Shopping.
        //   Distinto de BOOTS (solo botas) y UNIQUE_TEAM (solo 1 por equipo).
        //   Ej: Power Treads — solo 1 por héroe, pero NO son botas.
        constant integer ITEM_TAG_UNIQUE_HERO      = 8388608  // Solo 1 por héroe
    endglobals

    // ==============================
    // API PÚBLICA DE CONSULTA
    // ==============================

    // Obtener daño plano del ítem. Retorna 0.0 si no tiene.
    public function GetFlatDamage takes integer itemId returns real
        return LoadReal(itemDb, itemId, ITEM_FIELD_FLAT_DAMAGE)
    endfunction

    // Obtener bonus de velocidad de ataque del ítem. Retorna 0.0 si no tiene.
    public function GetAttackSpeed takes integer itemId returns real
        return LoadReal(itemDb, itemId, ITEM_FIELD_ATTACK_SPEED)
    endfunction

    // Obtener ID del buff asociado (on-hit, on-cast o aura). Retorna 0 si no tiene.
    public function GetBuffId takes integer itemId returns integer
        return LoadInteger(itemDb, itemId, ITEM_FIELD_BUFF_ID)
    endfunction

    // Obtener costo en oro del ítem. Retorna 0 si no se registró.
    public function GetGoldCost takes integer itemId returns integer
        return LoadInteger(itemDb, itemId, ITEM_FIELD_GOLD_COST)
    endfunction

    // Obtener costo en madera del ítem. Retorna 0 si solo cuesta oro.
    public function GetLumberCost takes integer itemId returns integer
        return LoadInteger(itemDb, itemId, ITEM_FIELD_LUMBER_COST)
    endfunction

    // Obtener radio de salpicadura (AoE). Retorna 0.0 si no tiene splash.
    public function GetAoeRadius takes integer itemId returns real
        return LoadReal(itemDb, itemId, ITEM_FIELD_AOE_RADIUS)
    endfunction

    // Obtener stock máximo por tienda. Retorna 0 si es ilimitado.
    // Uso: if GetMaxStock('ofir') > 0 then /* es recurso escaso */
    public function GetMaxStock takes integer itemId returns integer
        return LoadInteger(itemDb, itemId, ITEM_FIELD_MAX_STOCK)
    endfunction

    // --- API de Ítems Activos ---

    // Obtener rango de casteo. Retorna 0.0 si no es activo.
    public function GetCastRange takes integer itemId returns real
        return LoadReal(itemDb, itemId, ITEM_FIELD_CAST_RANGE)
    endfunction

    // Obtener costo de maná. Retorna 0 si no tiene.
    public function GetManaCost takes integer itemId returns integer
        return LoadInteger(itemDb, itemId, ITEM_FIELD_MANA_COST)
    endfunction

    // Obtener cooldown en segundos. Retorna 0.0 si no tiene.
    public function GetCooldown takes integer itemId returns real
        return LoadReal(itemDb, itemId, ITEM_FIELD_COOLDOWN)
    endfunction

    // --- API de Resurrección ---

    // Obtener delay de resurrección. Retorna 0.0 si no tiene revive.
    // Uso: if GetReviveDelay(itemId) > 0 then /* tiene segunda vida */
    public function GetReviveDelay takes integer itemId returns real
        return LoadReal(itemDb, itemId, ITEM_FIELD_REVIVE_DELAY)
    endfunction

    // Obtener HP con el que revive. Retorna 0.0 si no tiene revive.
    public function GetReviveHP takes integer itemId returns real
        return LoadReal(itemDb, itemId, ITEM_FIELD_REVIVE_HP)
    endfunction

    // --- API de Estadísticas Defensivas ---

    // Obtener armadura plana del ítem. Retorna 0.0 si no tiene.
    public function GetArmor takes integer itemId returns real
        return LoadReal(itemDb, itemId, ITEM_FIELD_ARMOR)
    endfunction

    // Obtener bonus de vida máxima. Retorna 0.0 si no tiene.
    public function GetBonusHP takes integer itemId returns real
        return LoadReal(itemDb, itemId, ITEM_FIELD_BONUS_HP)
    endfunction

    // Obtener bonus de maná máximo. Retorna 0.0 si no tiene.
    public function GetBonusMP takes integer itemId returns real
        return LoadReal(itemDb, itemId, ITEM_FIELD_BONUS_MP)
    endfunction

    // --- API de CC Integrado ---

    // Obtener duración de stun del ítem en Héroes. Retorna 0.0 si no tiene.
    public function GetStunHero takes integer itemId returns real
        return LoadReal(itemDb, itemId, ITEM_FIELD_STUN_HERO)
    endfunction

    // Obtener duración de stun del ítem en Unidades. Retorna 0.0 si no tiene.
    public function GetStunUnit takes integer itemId returns real
        return LoadReal(itemDb, itemId, ITEM_FIELD_STUN_UNIT)
    endfunction

    // --- API de Evasión ---

    // Obtener probabilidad de esquivar ataques. Retorna 0.0 si no tiene.
    public function GetEvasionPct takes integer itemId returns real
        return LoadReal(itemDb, itemId, ITEM_FIELD_EVASION_PCT)
    endfunction

    // --- API de Velocidad de Movimiento ---

    // Obtener bonus de velocidad de movimiento plano. Retorna 0.0 si no tiene.
    public function GetMoveSpeed takes integer itemId returns real
        return LoadReal(itemDb, itemId, ITEM_FIELD_MOVE_SPEED)
    endfunction

    // --- API de Golpe Crítico ---

    // Obtener probabilidad de crítico. Retorna 0.0 si no tiene.
    public function GetCritChance takes integer itemId returns real
        return LoadReal(itemDb, itemId, ITEM_FIELD_CRIT_CHANCE)
    endfunction

    // Obtener multiplicador de crítico. Retorna 0.0 si no tiene.
    public function GetCritMultiplier takes integer itemId returns real
        return LoadReal(itemDb, itemId, ITEM_FIELD_CRIT_MULTIPLIER)
    endfunction

    // Obtener daño porcentual pasivo. Retorna 0.0 si no tiene.
    public function GetPctDamage takes integer itemId returns real
        return LoadReal(itemDb, itemId, ITEM_FIELD_PCT_DAMAGE)
    endfunction

    // --- API de Estado de Transformación ---

    // Obtener ID del ítem siguiente al hacer clic. Retorna 0 si no se transforma.
    public function GetNextState takes integer itemId returns integer
        return LoadInteger(itemDb, itemId, ITEM_FIELD_NEXT_STATE)
    endfunction

    // --- API de Canalización ---

    // Obtener duración de canalización. Retorna 0.0 si no es canalizado.
    public function GetChannelTime takes integer itemId returns real
        return LoadReal(itemDb, itemId, ITEM_FIELD_CHANNEL_TIME)
    endfunction

    // --- API de Daño de Casteo ---

    // Obtener daño de impacto al usar el ítem. Retorna 0.0 si no tiene.
    public function GetCastDamage takes integer itemId returns real
        return LoadReal(itemDb, itemId, ITEM_FIELD_CAST_DAMAGE)
    endfunction

    // Obtener daño extra a invocaciones. Retorna 0.0 si no aplica.
    public function GetBonusDmgSummon takes integer itemId returns real
        return LoadReal(itemDb, itemId, ITEM_FIELD_BONUS_DMG_SUMMON)
    endfunction

    // --- API de Curación ---

    // Obtener regeneración pasiva de HP/seg. Retorna 0.0 si no tiene.
    public function GetHpRegen takes integer itemId returns real
        return LoadReal(itemDb, itemId, ITEM_FIELD_HP_REGEN)
    endfunction

    // Obtener cura instantánea al consumir. Retorna 0.0 si no tiene.
    // Uso: if GetHealAmount(itemId) > 0 then /* tengo cura de emergencia */
    public function GetHealAmount takes integer itemId returns real
        return LoadReal(itemDb, itemId, ITEM_FIELD_HEAL_AMOUNT)
    endfunction

    // --- API de Maná ---

    // Obtener % extra de regeneración de maná. Retorna 0.0 si no tiene.
    public function GetManaRegenPct takes integer itemId returns real
        return LoadReal(itemDb, itemId, ITEM_FIELD_MANA_REGEN_PCT)
    endfunction

    // Obtener maná instantáneo al consumir. Retorna 0.0 si no tiene.
    public function GetRestoreMana takes integer itemId returns real
        return LoadReal(itemDb, itemId, ITEM_FIELD_RESTORE_MANA)
    endfunction

    // --- API de Atributos ---

    // Obtener bonus de Fuerza. Retorna 0 si no tiene.
    public function GetBonusStr takes integer itemId returns integer
        return LoadInteger(itemDb, itemId, ITEM_FIELD_BONUS_STR)
    endfunction

    // Obtener bonus de Agilidad. Retorna 0 si no tiene.
    public function GetBonusAgi takes integer itemId returns integer
        return LoadInteger(itemDb, itemId, ITEM_FIELD_BONUS_AGI)
    endfunction

    // Obtener bonus de Inteligencia. Retorna 0 si no tiene.
    public function GetBonusInt takes integer itemId returns integer
        return LoadInteger(itemDb, itemId, ITEM_FIELD_BONUS_INT)
    endfunction

    // --- API de Probabilidades (RNG) ---
    // Retornan 0.0 si el ítem no tiene RNG (efecto garantizado).

    // Probabilidad de activación contra Héroes (0.05 = 5%)
    public function GetProcHero takes integer itemId returns real
        return LoadReal(itemDb, itemId, ITEM_FIELD_PROC_HERO)
    endfunction

    // Probabilidad de activación contra Unidades normales
    public function GetProcUnit takes integer itemId returns real
        return LoadReal(itemDb, itemId, ITEM_FIELD_PROC_UNIT)
    endfunction

    // Probabilidad de activación contra Invocaciones
    public function GetProcSummon takes integer itemId returns real
        return LoadReal(itemDb, itemId, ITEM_FIELD_PROC_SUMMON)
    endfunction

    // ¿Tiene este tag táctico? (Fuente única de verdad)
    // Uso: IADataItems_HasTag('ofro', ITEM_TAG_ORB_EFFECT)
    public function HasTag takes integer itemId, integer tag returns boolean
        local integer tags = LoadInteger(itemDb, itemId, ITEM_FIELD_TAGS)
        // Bitmask check: extraer el bit correspondiente
        return (tags / tag - (tags / (tag * 2)) * 2) == 1
    endfunction

    // --- API de Recetas ---
    public function GetRecipeCount takes integer itemId returns integer
        return LoadInteger(itemDb, itemId, ITEM_FIELD_RECIPE_COUNT)
    endfunction

    public function GetRecipeComponent takes integer itemId, integer slot returns integer
        // slot va de 1 a 6, corresponde a ITEM_FIELD_RECIPE_1..6 (keys 11..16)
        return LoadInteger(itemDb, itemId, ITEM_FIELD_RECIPE_COUNT + slot)
    endfunction

    // --- API de Tienda y Stock ---

    // Obtener TypeId de la tienda que vende este ítem. Retorna 0 si no se registró.
    public function GetShopType takes integer itemId returns integer
        return LoadInteger(itemDb, itemId, ITEM_FIELD_SHOP_TYPE)
    endfunction

    // Obtener retraso inicial de stock en segundos. Retorna 0.0 si disponible desde el inicio.
    public function GetInitialStockDelay takes integer itemId returns real
        return LoadReal(itemDb, itemId, ITEM_FIELD_INITIAL_STOCK_DELAY)
    endfunction

    // ==============================
    // REGISTRO DE DATOS (OnInit)
    // ==============================
    private function OnInit takes nothing returns nothing
        set itemDb = InitHashtable()



        // ==========================================================
        //  PLANTILLA MAESTRA 1 — ESFERA DE HIELO 'ofro'
        //  Referencia definitiva de cómo registrar un ítem completo.
        //
        //  DECISIONES ARQUITECTÓNICAS APLICADAS:
        //  1. SIN campo IS_ORB boolean. Usa ITEM_TAG_ORB_EFFECT (tag).
        //  2. ITEM_TAG_GRANTS_AA: La IA de shopping preguntará
        //     "¿Es melee Y NO tiene un ítem con GRANTS_AA?" para
        //     decidir si comprarlo. Héroes de rango ya atacan al aire
        //     por naturaleza; este tag no les aplica.
        //  3. ITEM_TAG_UNIQUE_TEAM: La IA verificará si un aliado ya
        //     tiene un ítem con este tag antes de comprarlo.
        //  4. ITEM_TAG_SOFT_CC: Distingue del HARD_CC (stun/root).
        //     La IA priorizará HARD_CC para iniciar peleas y SOFT_CC
        //     para persecuciones y kiting.
        // ==========================================================

        // --- Esfera de Hielo 'ofro' ---
        // Mecánica: +6 daño plano, 800 oro, aplica buff 'Bfro' al golpear.
        call SaveReal(itemDb, 'ofro', ITEM_FIELD_FLAT_DAMAGE, 6.0)
        call SaveInteger(itemDb, 'ofro', ITEM_FIELD_BUFF_ID, 'Bfro')
        call SaveInteger(itemDb, 'ofro', ITEM_FIELD_GOLD_COST, 800)
        // Táctica: Ofensivo + Orbe + Soft CC + Único por equipo + Permite AA
        call SaveInteger(itemDb, 'ofro', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE + ITEM_TAG_ORB_EFFECT + ITEM_TAG_SOFT_CC + ITEM_TAG_UNIQUE_TEAM + ITEM_TAG_GRANTS_AA)

        // ==========================================================
        // OTROS ÍTEMS DE ORBE (Siguen la misma estructura)
        // ==========================================================

        // ==========================================================
        //  PLANTILLA MAESTRA 2 — ESFERA DE RALENTIZACIÓN 'oslo'
        //  Primer ítem con RNG (probabilidad de activación).
        //
        //  DECISIONES ARQUITECTÓNICAS:
        //  1. Las probabilidades van en el ÍTEM (no en el buff).
        //     El ítem es quien "tira el dado"; el buff solo contiene
        //     los efectos una vez que se activó.
        //  2. UNIQUE_HERO: solo 1 por héroe, sin restricción de equipo.
        //     Múltiples aliados pueden comprarlo porque su efecto es
        //     probabilístico (a más esferas en el equipo, más procs).
        //  3. PROC_CHANCE: ofro aplica su slow en CADA golpe (garantizado),
        //     oslo solo tiene PROBABILIDAD de aplicarlo por ataque.
        //  4. ORB_EFFECT impide comprarlo junto con 'ofro' o 'Hand'
        //     en el MISMO héroe (un solo UAM por héroe).
        // ==========================================================

        // --- Esfera de Ralentización 'oslo' ---
        // Mecánica: +6 daño, 400 oro, aplica buff 'Bslo' al golpear (con RNG).
        call SaveReal(itemDb, 'oslo', ITEM_FIELD_FLAT_DAMAGE, 6.0)
        call SaveInteger(itemDb, 'oslo', ITEM_FIELD_BUFF_ID, 'Bslo')
        call SaveInteger(itemDb, 'oslo', ITEM_FIELD_GOLD_COST, 400)
        // Probabilidades de activación por tipo de objetivo:
        call SaveReal(itemDb, 'oslo', ITEM_FIELD_PROC_HERO, 0.05)    // 5% vs Héroes
        call SaveReal(itemDb, 'oslo', ITEM_FIELD_PROC_UNIT, 0.15)    // 15% vs Unidades
        call SaveReal(itemDb, 'oslo', ITEM_FIELD_PROC_SUMMON, 0.35)  // 35% vs Invocados
        // Táctica: Ofensivo + Orbe + Soft CC + RNG + Permite AA
        // NO lleva UNIQUE_TEAM (múltiples aliados pueden comprarlo)
        call SaveInteger(itemDb, 'oslo', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE + ITEM_TAG_ORB_EFFECT + ITEM_TAG_SOFT_CC + ITEM_TAG_PROC_CHANCE + ITEM_TAG_GRANTS_AA + ITEM_TAG_UNIQUE_HERO)

        // ==========================================================
        //  PLANTILLA MAESTRA 3 — ESFERA DE RAYO 'oli2'
        //  Primer ítem con buff de DOBLE FASE (Stun → Slow).
        //
        //  DECISIONES ARQUITECTÓNICAS:
        //  1. +150 daño a invocados: Registrado en BONUS_DMG_SUMMON.
        //     Relevante para IA_State_Combat al evaluar targets invocados.
        //  2. Lleva SOFT_CC + HARD_CC simultáneamente: tiene ambas
        //     fases (1s stun + 5s slow en héroes).
        //  3. Sin restricción de exclusividad (ni UNIQUE_TEAM ni UNIQUE_HERO).
        //     Múltiples aliados pueden comprarlo, y un héroe podría
        //     tener más de uno (aunque no es práctico por UAM).
        //  4. Sinergia con AS: NO necesita tag especial. La fórmula
        //     será: procs_por_minuto = ataques_por_minuto × prob.
        //     El cerebro de compras calculará esto automáticamente.
        // ==========================================================

        // --- Esfera de Rayo 'oli2' ---
        // Mecánica: +5 daño, 300 oro, aplica buff 'Bprg' al golpear (con RNG).
        // Buff de doble fase: 1s stun + 5s slow en héroes (con purge).
        call SaveReal(itemDb, 'oli2', ITEM_FIELD_FLAT_DAMAGE, 5.0)
        call SaveInteger(itemDb, 'oli2', ITEM_FIELD_BUFF_ID, 'Bprg')
        call SaveInteger(itemDb, 'oli2', ITEM_FIELD_GOLD_COST, 300)
        // Probabilidades de activación:
        call SaveReal(itemDb, 'oli2', ITEM_FIELD_PROC_HERO, 0.10)    // 10% vs Héroes
        call SaveReal(itemDb, 'oli2', ITEM_FIELD_PROC_UNIT, 0.35)    // 35% vs Unidades
        call SaveReal(itemDb, 'oli2', ITEM_FIELD_PROC_SUMMON, 0.35)  // 35% vs Invocados
        call SaveReal(itemDb, 'oli2', ITEM_FIELD_BONUS_DMG_SUMMON, 150.0) // +150 daño a invocados
        // Táctica: Ofensivo + Orbe + Soft CC + Hard CC + RNG + AA
        call SaveInteger(itemDb, 'oli2', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE + ITEM_TAG_ORB_EFFECT + ITEM_TAG_SOFT_CC + ITEM_TAG_HARD_CC + ITEM_TAG_PROC_CHANCE + ITEM_TAG_GRANTS_AA)



        // --- Esfera de Oscuridad 'odef' ---
        // +6 daño, 100 oro, Orbe. Invoca un Dark Minion al matar (buff 'BNba').
        // DECISIÓN: NO registramos BNba ni creamos tags de invocación.
        //   - BNba no modifica AS/MS/stats → la calculadora no tiene nada que leer.
        //   - El minion es débil, muere rápido, y WC3 lo controla automáticamente.
        //   - Crear ITEM_TAG_SUMMON sin un consumidor que lo lea = basura arquitectónica.
        // Para la IA de shopping: simplemente un orbe barato con daño y anti-aéreo.
        // UNIQUE_HERO: solo 1 por héroe, sin restricción de equipo.
        call SaveReal(itemDb, 'odef', ITEM_FIELD_FLAT_DAMAGE, 6.0)
        call SaveInteger(itemDb, 'odef', ITEM_FIELD_GOLD_COST, 100)
        call SaveInteger(itemDb, 'odef', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE + ITEM_TAG_ORB_EFFECT + ITEM_TAG_GRANTS_AA + ITEM_TAG_UNIQUE_HERO)

        // --- Esfera de Veneno 'oven' ---
        // +5 daño, 300 oro, Orbe. Aplica veneno (9 DPS × 6s = 54 daño total).
        // DECISIÓN: NO registramos el buff (Blpb/BIpb/Blpd/BIpd).
        //   - El ID del buff es ambiguo (L vs I) y bugeado en el editor.
        //   - 54 daño total es irrelevante para cálculos de combate.
        //   - Nadie lo compra → no merece columnas nuevas (BUFF_FIELD_DPS).
        // UNIQUE_HERO: solo 1 por héroe, sin restricción de equipo.
        call SaveReal(itemDb, 'oven', ITEM_FIELD_FLAT_DAMAGE, 5.0)
        call SaveInteger(itemDb, 'oven', ITEM_FIELD_GOLD_COST, 300)
        call SaveInteger(itemDb, 'oven', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE + ITEM_TAG_ORB_EFFECT + ITEM_TAG_GRANTS_AA + ITEM_TAG_UNIQUE_HERO)

        // --- Esfera de Fuego 'ofir' ---
        // +25 daño, 1000 oro, Orbe con splash (radio 140). Stock: 1 por tienda.
        // DECISIONES:
        //   - AOE_RADIUS = 140: la IA priorizará targets rodeados de creeps.
        //   - NO hay AOE_DAMAGE separado: el splash = FLAT_DAMAGE (25).
        //   - NO hay buff: el fuego no aplica debuff con nombre.
        //   - MAX_STOCK = 1: Solo 1 por tienda (2 en todo el mapa).
        //     La IA de shopping calculará:
        //       prioridad = (valor / gold_cost) × (1 / max_stock)
        //     Si max_stock=1 y valor alto → prioridad se dispara sola.
        //   - NO necesita TAG_RUSH/TAG_CONTESTED (YAGNI): esas son
        //     ESTRATEGIAS de IA_Brain_Macro, no DATOS del ítem.
        call SaveReal(itemDb, 'ofir', ITEM_FIELD_FLAT_DAMAGE, 25.0)
        call SaveInteger(itemDb, 'ofir', ITEM_FIELD_GOLD_COST, 1000)
        call SaveReal(itemDb, 'ofir', ITEM_FIELD_AOE_RADIUS, 140.0)
        call SaveInteger(itemDb, 'ofir', ITEM_FIELD_MAX_STOCK, 1)
        call SaveInteger(itemDb, 'ofir', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE + ITEM_TAG_ORB_EFFECT + ITEM_TAG_GRANTS_AA + ITEM_TAG_AOE)

        // ==========================================================
        //  PLANTILLA MAESTRA 4 — HEX 'I01G'
        //  Primer ítem ACTIVO (click en target para castear).
        //
        //  DECISIONES ARQUITECTÓNICAS:
        //  1. BUFF_ID + ACTIVE: El buff BOhx se aplica al CASTEAR,
        //     no al golpear. El tag ACTIVE lo distingue de los orbes.
        //  2. SIN campo IS_ORB/ORB_EFFECT: Hex NO es un UAM. No choca
        //     con orbes. Un héroe puede llevar Hex + Esfera de Hielo.
        //  3. SIN stats pasivos: NO tiene FLAT_DAMAGE ni ATTACK_SPEED.
        //     Solo ocupa slot de inventario.
        //  4. Campos activos (CAST_RANGE, MANA_COST, COOLDOWN): WC3
        //     1.27b no tiene natives para leerlos → los guardamos aquí.
        //  5. Draft logic (comprar solo si falta stun aliado o hay
        //     Blademaster enemigo): pertenece a IA_State_Shopping,
        //     NO a la base de datos. Aquí solo van DATOS puros.
        // ==========================================================

        // --- Hex 'I01G' ---
        // 1250 oro, activo con cast. Aplica buff BOhx (ya registrado).
        // Stock: 2 por tienda (4 en todo el mapa). Altamente disputado.
        call SaveInteger(itemDb, 'I01G', ITEM_FIELD_BUFF_ID, 'BOhx')
        call SaveInteger(itemDb, 'I01G', ITEM_FIELD_GOLD_COST, 1250)
        call SaveInteger(itemDb, 'I01G', ITEM_FIELD_MAX_STOCK, 2)
        // Propiedades de casteo:
        call SaveReal(itemDb, 'I01G', ITEM_FIELD_CAST_RANGE, 750.0)
        call SaveInteger(itemDb, 'I01G', ITEM_FIELD_MANA_COST, 50)
        call SaveReal(itemDb, 'I01G', ITEM_FIELD_COOLDOWN, 30.0)
        // Táctica: Utilidad + Hard CC + Activo (NO es orbe, NO es ofensivo)
        call SaveInteger(itemDb, 'I01G', ITEM_FIELD_TAGS, ITEM_TAG_UTILITY + ITEM_TAG_HARD_CC + ITEM_TAG_ACTIVE + ITEM_TAG_UNIQUE_HERO)

        // ==========================================================
        //  PLANTILLA MAESTRA 5 — ANKH DE REENCARNACIÓN 'ankh'
        //  Primer consumible PASIVO (se activa al morir).
        //
        //  DECISIONES ARQUITECTÓNICAS:
        //  1. REVIVE_DELAY/REVIVE_HP: Datos clave para Survival.
        //     Si tiene REVIVE_DELAY > 0, la IA sabe que tiene
        //     segunda vida y puede ser más agresiva.
        //  2. Sin ITEM_TAG_REVIVE: el campo ya lo expresa.
        //     Misma regla que IS_ORB vs ORB_EFFECT — una sola
        //     fuente de verdad, sin redundancia.
        //  3. Maná al 100%: constante lógica del ítem, no campo.
        //     Si un futuro ítem revive con maná distinto, se crea.
        //  4. 'Compra de pánico': es ESTRATEGIA de IA_State_Survival,
        //     no dato del ítem. La IA detectará "HP bajo + cerca de
        //     tienda + oro suficiente → comprar Ankh".
        // ==========================================================

        // --- Ankh de Reencarnación 'ankh' ---
        // 500 oro, consumible pasivo. Se destruye al morir, revive en 7s.
        call SaveInteger(itemDb, 'ankh', ITEM_FIELD_GOLD_COST, 500)
        call SaveReal(itemDb, 'ankh', ITEM_FIELD_REVIVE_DELAY, 7.0)
        call SaveReal(itemDb, 'ankh', ITEM_FIELD_REVIVE_HP, 500.0)
        // Táctica: Defensivo + Consumible (NO es activo, NO es orbe)
        call SaveInteger(itemDb, 'ankh', ITEM_FIELD_TAGS, ITEM_TAG_DEFENSIVE + ITEM_TAG_CONSUMABLE)

        // --- Book of the Siege 'I002' ---
        // 450 oro, consumible activo. Invoca 5x Tirador de Sables (ebal).
        // Duran 300s, daño de área (~50 c/u). Glass cannons para asedio.
        // DECISIÓN: NO registramos datos de invocación (YAGNI).
        //   - SUMMON_UNIT_ID, SUMMON_COUNT, SUMMON_DURATION: sin consumidor.
        //   - La lógica "comprar solo si enemigos muertos/empujando"
        //     es ESTRATEGIA de IA_Brain_Macro, no dato del ítem.
        //   - Cuando exista lógica de asedio, se agregan los campos.
        call SaveInteger(itemDb, 'I002', ITEM_FIELD_GOLD_COST, 450)
        call SaveInteger(itemDb, 'I002', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE + ITEM_TAG_ACTIVE + ITEM_TAG_CONSUMABLE)

        // --- Polvo de Aparición 'dust' ---
        // 75 oro, consumible activo (2 cargas). Revela invisibles (AoE 1000).
        // DECISIONES:
        //   - CHARGES: YAGNI. WC3 native GetItemCharges(item) lo lee en runtime.
        //   - CAST_RANGE = 0: Implica self-cast (No-Target). La IA deduce:
        //     if GetCastRange == 0 then UseItemNoTarget() else UseItemOnTarget()
        //     NO necesita ITEM_TAG_NO_TARGET.
        //   - AOE_RADIUS = 1000: Radio de revelación, no de daño.
        //   - BUFF_ID = 'Bdet': Registrado en IA_Data_Buffs con TAG_REVEAL.
        //     Consumidor: IA_State_Survival ("tengo Bdet → soy visible,
        //     Wind Walk no servirá para escapar").
        call SaveInteger(itemDb, 'dust', ITEM_FIELD_BUFF_ID, 'Bdet')
        call SaveInteger(itemDb, 'dust', ITEM_FIELD_GOLD_COST, 75)
        call SaveReal(itemDb, 'dust', ITEM_FIELD_COOLDOWN, 20.0)
        call SaveReal(itemDb, 'dust', ITEM_FIELD_AOE_RADIUS, 1000.0)
        call SaveReal(itemDb, 'dust', ITEM_FIELD_CAST_RANGE, 0.0)
        // Táctica: Utilidad + Activo + Consumible + Revelar
        call SaveInteger(itemDb, 'dust', ITEM_FIELD_TAGS, ITEM_TAG_UTILITY + ITEM_TAG_ACTIVE + ITEM_TAG_CONSUMABLE + ITEM_TAG_REVEAL)

        // --- Escudo Encantado 'shen' ---
        // 700 oro, pasivo puro. +10 armadura, +150 HP. Stock: 2 por tienda.
        // DECISIONES:
        //   - Sin ITEM_TAG_EARLY_GAME: la IA de shopping deducirá por
        //     matemáticas que vender shen (10 arm + 150 HP) para comprar
        //     el escudo grande (20 arm + 2000 HP) es mejor en Late Game.
        //   - Primer ítem puramente defensivo con stats numéricos.
        call SaveReal(itemDb, 'shen', ITEM_FIELD_ARMOR, 10.0)
        call SaveReal(itemDb, 'shen', ITEM_FIELD_BONUS_HP, 150.0)
        call SaveInteger(itemDb, 'shen', ITEM_FIELD_GOLD_COST, 700)
        call SaveInteger(itemDb, 'shen', ITEM_FIELD_MAX_STOCK, 2)
        call SaveInteger(itemDb, 'shen', ITEM_FIELD_TAGS, ITEM_TAG_DEFENSIVE)

        // ==========================================================
        //  PLANTILLA MAESTRA 8 — PIEDRA INFERNAL 'infs'
        //  Primer consumible POINT-TARGET con CC y daño integrados.
        //
        //  DECISIONES ARQUITECTÓNICAS:
        //  1. POINT_TARGET: La IA emitirá UnitUseItemPoint(u, item, x, y).
        //     Tri-estado completo de targeting:
        //       CAST_RANGE=0           → Self-cast (dust)
        //       CAST_RANGE>0           → Unit-Target (Hex)
        //       CAST_RANGE>0 + PT tag  → Point-Target (infs)
        //  2. STUN_HERO/UNIT en el ÍTEM: El stun es genérico/compartido,
        //     no tiene buff propio. Los tiempos van aquí, no en buffDb.
        //  3. CAST_DAMAGE: 50 de daño al impacto. Diferente de FLAT_DAMAGE.
        //     Consumidor: lethal check ("¿enemigo tiene <50 HP? → Piedra").
        //  4. Invocación del Infernal: YAGNI (mismo que I002/odef).
        //     WC3 lo controla automáticamente. Body-block es micro-estrategia.
        // ==========================================================

        // --- Piedra Infernal 'infs' ---
        // 500 oro, consumible activo point-target. Stun AoE + 50 daño.
        call SaveInteger(itemDb, 'infs', ITEM_FIELD_GOLD_COST, 500)
        call SaveReal(itemDb, 'infs', ITEM_FIELD_CAST_RANGE, 900.0)
        call SaveReal(itemDb, 'infs', ITEM_FIELD_AOE_RADIUS, 250.0)
        call SaveReal(itemDb, 'infs', ITEM_FIELD_CAST_DAMAGE, 50.0)
        call SaveReal(itemDb, 'infs', ITEM_FIELD_STUN_HERO, 2.0)
        call SaveReal(itemDb, 'infs', ITEM_FIELD_STUN_UNIT, 4.0)
        // Táctica: Ofensivo + Activo + Consumible + Hard CC + Point-Target + AoE
        call SaveInteger(itemDb, 'infs', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE + ITEM_TAG_ACTIVE + ITEM_TAG_CONSUMABLE + ITEM_TAG_HARD_CC + ITEM_TAG_POINT_TARGET + ITEM_TAG_AOE)

        // --- Libro de los Muertos 'fgsk' ---
        // 450 oro, consumible activo self-cast. Invoca esqueletos (basura actual).
        // DECISIONES:
        //   - ZERO-VALUE LOGIC: Sin OFFENSIVE/DEFENSIVE/UTILITY.
        //     La fórmula de shopping: prioridad = (tags_valor × stats) / gold.
        //     tags_valor = 0 → prioridad = 0 → la IA lo ignora naturalmente.
        //     NO necesita ITEM_TAG_TRASH. Cuando se balancee, agregar
        //     ITEM_TAG_OFFENSIVE y la IA empezará a considerarlo.
        //   - Invocaciones: YAGNI (mismo que I002/odef).
        call SaveInteger(itemDb, 'fgsk', ITEM_FIELD_GOLD_COST, 450)
        call SaveReal(itemDb, 'fgsk', ITEM_FIELD_CAST_RANGE, 0.0)
        call SaveInteger(itemDb, 'fgsk', ITEM_FIELD_TAGS, ITEM_TAG_ACTIVE + ITEM_TAG_CONSUMABLE)

        // --- Varita de Negación 'wneg' ---
        // 200 oro, consumible activo point-target (3 cargas). Dispel AoE.
        // DECISIONES:
        //   - BONUS_DMG_SUMMON = 1000: One-shot a invocaciones.
        //   - ITEM_TAG_PURGE: Habilita consulta cruzada con buffDb.
        //     IA_State_Combat: "aliado tiene TAG_DEBUFF (no STUN) →
        //     ¿tengo PURGE? → apuntar AoE al aliado → limpiar".
        //   - Fusión de cargas: YAGNI. WC3 lo hace automáticamente.
        //   - Contra-juego Etéreo: emerge de tags existentes.
        //     Desterrar tendrá TAG_DEBUFF en buffDb + esta varita tiene
        //     ITEM_TAG_PURGE → la IA descubre la sinergia sola.
        call SaveInteger(itemDb, 'wneg', ITEM_FIELD_GOLD_COST, 200)
        call SaveReal(itemDb, 'wneg', ITEM_FIELD_CAST_RANGE, 800.0)
        call SaveReal(itemDb, 'wneg', ITEM_FIELD_AOE_RADIUS, 325.0)
        call SaveReal(itemDb, 'wneg', ITEM_FIELD_COOLDOWN, 7.0)
        call SaveReal(itemDb, 'wneg', ITEM_FIELD_BONUS_DMG_SUMMON, 1000.0)
        // Táctica: Utilidad + Activo + Consumible + Point-Target + AoE + Purga
        call SaveInteger(itemDb, 'wneg', ITEM_FIELD_TAGS, ITEM_TAG_UTILITY + ITEM_TAG_ACTIVE + ITEM_TAG_CONSUMABLE + ITEM_TAG_POINT_TARGET + ITEM_TAG_AOE + ITEM_TAG_PURGE)

        // --- Piedra de la Salud 'hlst' ---
        // 450 oro, híbrido: pasivo (+1 HP/seg) + activo consumible (cura 500 HP).
        // DECISIONES:
        //   - HP_REGEN = 1.0: Calculadora pasiva de supervivencia.
        //   - HEAL_AMOUNT = 500: IA_State_Survival lo detecta con
        //     GetHealAmount > 0 → "tengo burst heal de emergencia".
        //   - Sin ITEM_TAG_HEAL: el campo ya es la señal.
        //   - Sin HEAL_THRESHOLD: la heurística "cuándo comer la piedra"
        //     vive en IA_State_Survival, no en la base de datos.
        call SaveInteger(itemDb, 'hlst', ITEM_FIELD_GOLD_COST, 450)
        call SaveReal(itemDb, 'hlst', ITEM_FIELD_HP_REGEN, 1.0)
        call SaveReal(itemDb, 'hlst', ITEM_FIELD_HEAL_AMOUNT, 500.0)
        call SaveReal(itemDb, 'hlst', ITEM_FIELD_CAST_RANGE, 0.0)
        // Táctica: Defensivo + Activo + Consumible
        call SaveInteger(itemDb, 'hlst', ITEM_FIELD_TAGS, ITEM_TAG_DEFENSIVE + ITEM_TAG_ACTIVE + ITEM_TAG_CONSUMABLE)

        // ==========================================================
        // ESPACIO PARA FUTUROS ÍTEMS
        // Plantillas de referencia:
        //   Orbe pasivo      → ver 'ofro' (Plantilla Maestra 1)
        //   Orbe RNG         → ver 'oslo' (Plantilla Maestra 2)
        //   Orbe dual-CC     → ver 'oli2' (Plantilla Maestra 3)
        //   Ítem activo      → ver 'I01G' (Plantilla Maestra 4)
        //   Consumible pasivo→ ver 'ankh' (Plantilla Maestra 5)
        //   Consumible reveal→ ver 'dust' (Plantilla Maestra 6)
        //   Pasivo defensivo → ver 'shen' (Plantilla Maestra 7)
        //   Point-target CC  → ver 'infs' (Plantilla Maestra 8)
        //   Point-target purge→ ver 'wneg' (Plantilla Maestra 9)
        //   Híbrido pasivo+heal→ ver 'hlst' (Plantilla Maestra 10)
        // ==========================================================

        // --- Piedra de Maná 'mnst' ---
        // 450 oro, híbrido: pasivo (+25% regen maná) + activo (restaura 300 maná).
        // DECISIONES:
        //   - MANA_REGEN_PCT = 0.25: Porcentual (no plano como HP_REGEN).
        //   - RESTORE_MANA = 300: IA_State_Combat/Survival detectan
        //     GetRestoreMana > 0 → "tengo recarga de maná de emergencia".
        //   - Counter-pick vs Mago Sanguinario: estrategia de draft
        //     en IA_State_Shopping, no dato del ítem.
        //   - Fall-off: la IA calcula 300 / costo_habilidad → si < 1 uso,
        //     prioridad baja naturalmente.
        call SaveInteger(itemDb, 'mnst', ITEM_FIELD_GOLD_COST, 450)
        call SaveReal(itemDb, 'mnst', ITEM_FIELD_MANA_REGEN_PCT, 0.25)
        call SaveReal(itemDb, 'mnst', ITEM_FIELD_RESTORE_MANA, 300.0)
        call SaveReal(itemDb, 'mnst', ITEM_FIELD_CAST_RANGE, 0.0)
        // Táctica: Utilidad + Activo + Consumible
        call SaveInteger(itemDb, 'mnst', ITEM_FIELD_TAGS, ITEM_TAG_UTILITY + ITEM_TAG_ACTIVE + ITEM_TAG_CONSUMABLE)

        // --- Hacha de Ataque +25 'I008' ---
        // 1500 oro, pasivo. +25 daño, +3 STR, +1 AGI, +1 INT.
        // DECISIONES:
        //   - Es COMPONENTE de receta (1500 → 3000 → 4500).
        //     Sin RECIPE_RESULT ni RECIPE_COUNT: esos van en el
        //     ítem fusionado futuro que apuntará a este ID.
        //   - Primer ítem con atributos primarios mixtos.
        call SaveReal(itemDb, 'I008', ITEM_FIELD_FLAT_DAMAGE, 25.0)
        call SaveInteger(itemDb, 'I008', ITEM_FIELD_GOLD_COST, 1500)
        call SaveInteger(itemDb, 'I008', ITEM_FIELD_BONUS_STR, 3)
        call SaveInteger(itemDb, 'I008', ITEM_FIELD_BONUS_AGI, 1)
        call SaveInteger(itemDb, 'I008', ITEM_FIELD_BONUS_INT, 1)
        call SaveInteger(itemDb, 'I008', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE)

        // --- Garras +50 'I009' ---
        // 3000 oro, pasivo. +50 daño, +6 STR, +3 AGI, +3 INT.
        // Ítem independiente (NO es evolución de I008).
        // Puede ser INGREDIENTE de una fusión futura (estilo Exodia).
        call SaveReal(itemDb, 'I009', ITEM_FIELD_FLAT_DAMAGE, 50.0)
        call SaveInteger(itemDb, 'I009', ITEM_FIELD_GOLD_COST, 3000)
        call SaveInteger(itemDb, 'I009', ITEM_FIELD_BONUS_STR, 6)
        call SaveInteger(itemDb, 'I009', ITEM_FIELD_BONUS_AGI, 3)
        call SaveInteger(itemDb, 'I009', ITEM_FIELD_BONUS_INT, 3)
        call SaveInteger(itemDb, 'I009', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE)

        // --- Hacha Infernal +75 'I00A' ---
        // 4500 oro, pasivo. +75 daño, +9 STR, +6 AGI, +6 INT.
        // Tercer ingrediente independiente (estilo Exodia).
        call SaveReal(itemDb, 'I00A', ITEM_FIELD_FLAT_DAMAGE, 75.0)
        call SaveInteger(itemDb, 'I00A', ITEM_FIELD_GOLD_COST, 4500)
        call SaveInteger(itemDb, 'I00A', ITEM_FIELD_BONUS_STR, 9)
        call SaveInteger(itemDb, 'I00A', ITEM_FIELD_BONUS_AGI, 6)
        call SaveInteger(itemDb, 'I00A', ITEM_FIELD_BONUS_INT, 6)
        call SaveInteger(itemDb, 'I00A', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE)

        // --- Daga de Ataque +25 'I00C' ---
        // 1500 oro, pasivo. +25 daño, +1 STR, +3 AGI, +1 INT.
        call SaveReal(itemDb, 'I00C', ITEM_FIELD_FLAT_DAMAGE, 25.0)
        call SaveInteger(itemDb, 'I00C', ITEM_FIELD_GOLD_COST, 1500)
        call SaveInteger(itemDb, 'I00C', ITEM_FIELD_BONUS_STR, 1)
        call SaveInteger(itemDb, 'I00C', ITEM_FIELD_BONUS_AGI, 3)
        call SaveInteger(itemDb, 'I00C', ITEM_FIELD_BONUS_INT, 1)
        call SaveInteger(itemDb, 'I00C', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE)

        // --- Puñal de Ataque +50 'I00D' ---
        // 3000 oro, pasivo. +50 daño, +3 STR, +6 AGI, +3 INT.
        call SaveReal(itemDb, 'I00D', ITEM_FIELD_FLAT_DAMAGE, 50.0)
        call SaveInteger(itemDb, 'I00D', ITEM_FIELD_GOLD_COST, 3000)
        call SaveInteger(itemDb, 'I00D', ITEM_FIELD_BONUS_STR, 3)
        call SaveInteger(itemDb, 'I00D', ITEM_FIELD_BONUS_AGI, 6)
        call SaveInteger(itemDb, 'I00D', ITEM_FIELD_BONUS_INT, 3)
        call SaveInteger(itemDb, 'I00D', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE)

        // --- Impacto Blanco +75 'I00E' ---
        // 4500 oro, pasivo. +75 daño, +6 STR, +9 AGI, +6 INT.
        call SaveReal(itemDb, 'I00E', ITEM_FIELD_FLAT_DAMAGE, 75.0)
        call SaveInteger(itemDb, 'I00E', ITEM_FIELD_GOLD_COST, 4500)
        call SaveInteger(itemDb, 'I00E', ITEM_FIELD_BONUS_STR, 6)
        call SaveInteger(itemDb, 'I00E', ITEM_FIELD_BONUS_AGI, 9)
        call SaveInteger(itemDb, 'I00E', ITEM_FIELD_BONUS_INT, 6)
        call SaveInteger(itemDb, 'I00E', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE)

        // --- Varita Oscura +25 'I00G' ---
        // 1500 oro, pasivo. +25 daño, +1 STR, +1 AGI, +3 INT.
        call SaveReal(itemDb, 'I00G', ITEM_FIELD_FLAT_DAMAGE, 25.0)
        call SaveInteger(itemDb, 'I00G', ITEM_FIELD_GOLD_COST, 1500)
        call SaveInteger(itemDb, 'I00G', ITEM_FIELD_BONUS_STR, 1)
        call SaveInteger(itemDb, 'I00G', ITEM_FIELD_BONUS_AGI, 1)
        call SaveInteger(itemDb, 'I00G', ITEM_FIELD_BONUS_INT, 3)
        call SaveInteger(itemDb, 'I00G', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE)

        // --- Libro Oscuro +50 'I00H' ---
        // 3000 oro, pasivo. +50 daño, +3 STR, +3 AGI, +6 INT.
        call SaveReal(itemDb, 'I00H', ITEM_FIELD_FLAT_DAMAGE, 50.0)
        call SaveInteger(itemDb, 'I00H', ITEM_FIELD_GOLD_COST, 3000)
        call SaveInteger(itemDb, 'I00H', ITEM_FIELD_BONUS_STR, 3)
        call SaveInteger(itemDb, 'I00H', ITEM_FIELD_BONUS_AGI, 3)
        call SaveInteger(itemDb, 'I00H', ITEM_FIELD_BONUS_INT, 6)
        call SaveInteger(itemDb, 'I00H', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE)

        // --- Báculo de Ataque +75 'I00I' ---
        // 4500 oro, pasivo. +75 daño, +6 STR, +6 AGI, +9 INT.
        call SaveReal(itemDb, 'I00I', ITEM_FIELD_FLAT_DAMAGE, 75.0)
        call SaveInteger(itemDb, 'I00I', ITEM_FIELD_GOLD_COST, 4500)
        call SaveInteger(itemDb, 'I00I', ITEM_FIELD_BONUS_STR, 6)
        call SaveInteger(itemDb, 'I00I', ITEM_FIELD_BONUS_AGI, 6)
        call SaveInteger(itemDb, 'I00I', ITEM_FIELD_BONUS_INT, 9)
        call SaveInteger(itemDb, 'I00I', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE)

        // --- Ancestro Janggo 'ajen' ---
        // 500 oro, aura pasiva. +18% AS, +10% MS a aliados en 900 AoE.
        // DECISIONES:
        //   - AS/MS van en el BUFF (B00S), no en el ítem.
        //     B00S = buff personalizado del ítem (mismo ícono que BOae).
        //     BOae = buff de Endurance Aura (habilidad Tauren Chief).
        //   - UNIQUE_TEAM: solo 1 por equipo (no se acumula).
        //   - "No comprar si hay Tauren aliado": IA_State_Shopping.
        call SaveInteger(itemDb, 'ajen', ITEM_FIELD_BUFF_ID, 'BOae')
        call SaveInteger(itemDb, 'ajen', ITEM_FIELD_GOLD_COST, 800)
        call SaveReal(itemDb, 'ajen', ITEM_FIELD_AOE_RADIUS, 900.0)
        call SaveInteger(itemDb, 'ajen', ITEM_FIELD_TAGS, ITEM_TAG_UTILITY + ITEM_TAG_UNIQUE_TEAM)

        // --- Flauta de Alleria 'afac' ---
        // 400 oro, aura pasiva. +15% daño a aliados ranged en 900 AoE.
        // DECISIONES:
        //   - DMG_PCT va en el BUFF (BEar), no en el ítem.
        //   - UNIQUE_TEAM: solo 1 por equipo (no se acumula).
        //   - RANGED_ONLY: solo beneficia a unidades a distancia.
        //   - "No comprar si 'la gata' está en el equipo": IA_State_Shopping.
        call SaveInteger(itemDb, 'afac', ITEM_FIELD_BUFF_ID, 'BEar')
        call SaveInteger(itemDb, 'afac', ITEM_FIELD_GOLD_COST, 400)
        call SaveReal(itemDb, 'afac', ITEM_FIELD_AOE_RADIUS, 900.0)
        call SaveInteger(itemDb, 'afac', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE + ITEM_TAG_UNIQUE_TEAM + ITEM_TAG_RANGED_ONLY)

        // --- Campanillas de hueso del Azote 'sbch' ---
        // 450 oro, aura pasiva. +10% lifesteal a aliados melee en 900 AoE.
        // DECISIONES:
        //   - LIFESTEAL_PCT va en el BUFF (BUav), no en el ítem.
        //   - UNIQUE_TEAM: solo 1 por equipo.
        //   - MELEE_ONLY: solo beneficia a unidades cuerpo a cuerpo.
        //   - No stackea con Vampiric Aura (orco): IA_State_Shopping.
        call SaveInteger(itemDb, 'sbch', ITEM_FIELD_BUFF_ID, 'BUav')
        call SaveInteger(itemDb, 'sbch', ITEM_FIELD_GOLD_COST, 450)
        call SaveReal(itemDb, 'sbch', ITEM_FIELD_AOE_RADIUS, 900.0)
        call SaveInteger(itemDb, 'sbch', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE + ITEM_TAG_UNIQUE_TEAM + ITEM_TAG_MELEE_ONLY)

        // --- Tambores de Guerra 1 'I01J' ---
        // 400 oro, aura pasiva. +10% daño base a aliados melee en 1000 AoE.
        // DECISIONES:
        //   - DMG_PCT va en el BUFF (B00R), no en el ítem.
        //   - UNIQUE_TEAM: solo 1 por equipo.
        //   - MELEE_ONLY: solo beneficia a unidades cuerpo a cuerpo.
        call SaveInteger(itemDb, 'I01J', ITEM_FIELD_BUFF_ID, 'B00R')
        call SaveInteger(itemDb, 'I01J', ITEM_FIELD_GOLD_COST, 400)
        call SaveReal(itemDb, 'I01J', ITEM_FIELD_AOE_RADIUS, 1000.0)
        call SaveInteger(itemDb, 'I01J', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE + ITEM_TAG_UNIQUE_TEAM + ITEM_TAG_MELEE_ONLY)

        // --- Legión el Cuerno del Apocalipsis 'lgdh' ---
        // 400 oro, aura pasiva. +2.2 HP/s, +10% MS a aliados en 900 AoE.
        // DECISIONES:
        //   - HP_REGEN_PCT y MS_MOD van en el BUFF (BUau).
        //   - UNIQUE_TEAM: solo 1 por equipo.
        //   - No stackea con Unholy Aura: IA_State_Shopping.
        //   - Sinergia con Janggo (ajen): ambos dan MS, se suman.
        call SaveInteger(itemDb, 'lgdh', ITEM_FIELD_BUFF_ID, 'BUau')
        call SaveInteger(itemDb, 'lgdh', ITEM_FIELD_GOLD_COST, 800)
        call SaveReal(itemDb, 'lgdh', ITEM_FIELD_AOE_RADIUS, 900.0)
        call SaveInteger(itemDb, 'lgdh', ITEM_FIELD_TAGS, ITEM_TAG_UTILITY + ITEM_TAG_UNIQUE_TEAM)

        // --- Talismán de Evasión 'evtl' ---
        // 400 oro, pasivo. 14% de esquivar ataques. Solo beneficia al portador.
        // DECISIONES:
        //   - Sin buff: no aplica aura ni efecto visible.
        //   - No stackea con Evasion innata: IA_State_Shopping.
        call SaveReal(itemDb, 'evtl', ITEM_FIELD_EVASION_PCT, 0.14)
        call SaveInteger(itemDb, 'evtl', ITEM_FIELD_GOLD_COST, 400)
        call SaveInteger(itemDb, 'evtl', ITEM_FIELD_TAGS, ITEM_TAG_DEFENSIVE + ITEM_TAG_UNIQUE_HERO)

        // --- Botas de Velocidad 'bspd' ---
        // 350 oro, pasivo. +60 MS plano. Componente de Botas TP.
        // DECISIONES:
        //   - CORE: primera compra obligatoria del juego.
        //   - BOOTS: solo 1 par de botas por héroe (no se acumulan).
        //   - Sin buff: el bono de MS es del ítem, no de un aura.
        call SaveReal(itemDb, 'bspd', ITEM_FIELD_MOVE_SPEED, 60.0)
        call SaveInteger(itemDb, 'bspd', ITEM_FIELD_GOLD_COST, 350)
        call SaveInteger(itemDb, 'bspd', ITEM_FIELD_TAGS, ITEM_TAG_UTILITY + ITEM_TAG_CORE + ITEM_TAG_BOOTS)

        // --- Báculo de Teletransporte 'brac' ---
        // 100 oro, activo. TP a aliado (global). 90s CD, 3s canalización.
        // DECISIONES:
        //   - CORE: segundo ingrediente obligatorio de Botas TP.
        //   - CHANNELING + CHANNEL_TIME: FSM pausa órdenes 3s.
        //   - TARGET_ALLY: se usa sobre una unidad aliada.
        //   - CAST_RANGE 99999 = global (cualquier parte del mapa).
        //   - Sin ITEM_FIELD_INITIAL_STOCK_DELAY: YAGNI, la IA verifica
        //     stock en la tienda con natives de WC3 en tiempo real.
        call SaveInteger(itemDb, 'brac', ITEM_FIELD_GOLD_COST, 100)
        call SaveReal(itemDb, 'brac', ITEM_FIELD_CAST_RANGE, 99999.0)
        call SaveReal(itemDb, 'brac', ITEM_FIELD_COOLDOWN, 90.0)
        call SaveReal(itemDb, 'brac', ITEM_FIELD_CHANNEL_TIME, 3.0)
        call SaveInteger(itemDb, 'brac', ITEM_FIELD_TAGS, ITEM_TAG_UTILITY + ITEM_TAG_ACTIVE + ITEM_TAG_CORE + ITEM_TAG_CHANNELING + ITEM_TAG_TARGET_ALLY + ITEM_TAG_UNIQUE_HERO)

        // --- Guantes de Presteza 'gcel' ---
        // 300 oro, pasivo. +25% AS. Stat stick de early game.
        // Nota: En late game, héroes AGI alcanzan AS Cap (+400%)
        // y este ítem se vuelve obsoleto → IA_State_Shopping evalúa.
        call SaveReal(itemDb, 'gcel', ITEM_FIELD_ATTACK_SPEED, 0.25)
        call SaveInteger(itemDb, 'gcel', ITEM_FIELD_GOLD_COST, 300)
        call SaveInteger(itemDb, 'gcel', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE)

        // --- Mano del Rey 'I01Q' ---
        // Pasivo. +200% AS. Mismo patrón que gcel pero ×8 valor.
        call SaveReal(itemDb, 'I01Q', ITEM_FIELD_ATTACK_SPEED, 3.50)
        call SaveInteger(itemDb, 'I01Q', ITEM_FIELD_GOLD_COST, 4500)
        call SaveInteger(itemDb, 'I01Q', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE)

        // --- Robe of the Magi 'ciri' ---
        // 300 oro, pasivo. +6 INT. Stat stick de early game.
        call SaveInteger(itemDb, 'ciri', ITEM_FIELD_BONUS_INT, 6)
        call SaveInteger(itemDb, 'ciri', ITEM_FIELD_GOLD_COST, 300)
        call SaveInteger(itemDb, 'ciri', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE)

        // --- Boots of Quel'Thalas 'belv' ---
        // 500 oro, pasivo. +6 AGI.
        call SaveInteger(itemDb, 'belv', ITEM_FIELD_BONUS_AGI, 6)
        call SaveInteger(itemDb, 'belv', ITEM_FIELD_GOLD_COST, 500)
        call SaveInteger(itemDb, 'belv', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE)

        // --- Armadura Lunar Avanzada +20 'I00U' ---
        // 5500 oro, pasivo. +20 Armor, +2000 HP, +1200 MP, +12 AGI.
        // Híbrido defensivo/ofensivo. Ingrediente de Tier Alto.
        // NOTA: Aunque da +12 AGI (ofensivo incidental), su propósito
        // absoluto es supervivencia → estrictamente DEFENSIVE.
        call SaveReal(itemDb, 'I00U', ITEM_FIELD_ARMOR, 20.0)
        call SaveReal(itemDb, 'I00U', ITEM_FIELD_BONUS_HP, 2000.0)
        call SaveReal(itemDb, 'I00U', ITEM_FIELD_BONUS_MP, 1200.0)
        call SaveInteger(itemDb, 'I00U', ITEM_FIELD_BONUS_AGI, 12)
        call SaveInteger(itemDb, 'I00U', ITEM_FIELD_GOLD_COST, 5500)
        call SaveInteger(itemDb, 'I00U', ITEM_FIELD_TAGS, ITEM_TAG_DEFENSIVE)

        // --- Coraza de Infame +20 'I00M' ---
        // 5500 oro, pasivo. +20 Armor, +2000 HP, +1200 MP, +12 STR.
        // Contraparte STR de la Armadura Lunar (I00U). Estrictamente DEFENSIVE.
        call SaveReal(itemDb, 'I00M', ITEM_FIELD_ARMOR, 20.0)
        call SaveReal(itemDb, 'I00M', ITEM_FIELD_BONUS_HP, 2000.0)
        call SaveReal(itemDb, 'I00M', ITEM_FIELD_BONUS_MP, 1200.0)
        call SaveInteger(itemDb, 'I00M', ITEM_FIELD_BONUS_STR, 12)
        call SaveInteger(itemDb, 'I00M', ITEM_FIELD_GOLD_COST, 5500)
        call SaveInteger(itemDb, 'I00M', ITEM_FIELD_TAGS, ITEM_TAG_DEFENSIVE)

        // --- Escamas de Dragón +20 'I00Q' ---
        // 5500 oro, pasivo. +20 Armor, +2000 HP, +1200 MP, +12 INT.
        // Contraparte INT de la Armadura Lunar (I00U). Estrictamente DEFENSIVE.
        call SaveReal(itemDb, 'I00Q', ITEM_FIELD_ARMOR, 20.0)
        call SaveReal(itemDb, 'I00Q', ITEM_FIELD_BONUS_HP, 2000.0)
        call SaveReal(itemDb, 'I00Q', ITEM_FIELD_BONUS_MP, 1200.0)
        call SaveInteger(itemDb, 'I00Q', ITEM_FIELD_BONUS_INT, 12)
        call SaveInteger(itemDb, 'I00Q', ITEM_FIELD_GOLD_COST, 5500)
        call SaveInteger(itemDb, 'I00Q', ITEM_FIELD_TAGS, ITEM_TAG_DEFENSIVE)

        // --- Hacha Única +100 'I007' ---
        // 6500 oro, pasivo. +100 daño, +12 STR, +9 AGI, +9 INT.
        call SaveReal(itemDb, 'I007', ITEM_FIELD_FLAT_DAMAGE, 100.0)
        call SaveInteger(itemDb, 'I007', ITEM_FIELD_BONUS_STR, 12)
        call SaveInteger(itemDb, 'I007', ITEM_FIELD_BONUS_AGI, 9)
        call SaveInteger(itemDb, 'I007', ITEM_FIELD_BONUS_INT, 9)
        call SaveInteger(itemDb, 'I007', ITEM_FIELD_GOLD_COST, 6500)
        call SaveInteger(itemDb, 'I007', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE)

        // --- Impacto Oscuro de ataque +100 'I00B' ---
        // 6500 oro, pasivo. +100 daño, +9 STR, +12 AGI, +9 INT.
        call SaveReal(itemDb, 'I00B', ITEM_FIELD_FLAT_DAMAGE, 100.0)
        call SaveInteger(itemDb, 'I00B', ITEM_FIELD_BONUS_STR, 9)
        call SaveInteger(itemDb, 'I00B', ITEM_FIELD_BONUS_AGI, 12)
        call SaveInteger(itemDb, 'I00B', ITEM_FIELD_BONUS_INT, 9)
        call SaveInteger(itemDb, 'I00B', ITEM_FIELD_GOLD_COST, 6500)
        call SaveInteger(itemDb, 'I00B', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE)

        // --- Libro Maestro de ataque +100 'I00F' ---
        // 6500 oro, pasivo. +100 daño, +9 STR, +9 AGI, +12 INT.
        call SaveReal(itemDb, 'I00F', ITEM_FIELD_FLAT_DAMAGE, 100.0)
        call SaveInteger(itemDb, 'I00F', ITEM_FIELD_BONUS_STR, 9)
        call SaveInteger(itemDb, 'I00F', ITEM_FIELD_BONUS_AGI, 9)
        call SaveInteger(itemDb, 'I00F', ITEM_FIELD_BONUS_INT, 12)
        call SaveInteger(itemDb, 'I00F', ITEM_FIELD_GOLD_COST, 6500)
        call SaveInteger(itemDb, 'I00F', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE)

        // --- Armadura Lunar +5 'I00R' ---
        // 1300 oro, pasivo. +5 Armor, +500 HP, +300 MP, +3 AGI. DEFENSIVE.
        call SaveReal(itemDb, 'I00R', ITEM_FIELD_ARMOR, 5.0)
        call SaveReal(itemDb, 'I00R', ITEM_FIELD_BONUS_HP, 500.0)
        call SaveReal(itemDb, 'I00R', ITEM_FIELD_BONUS_MP, 300.0)
        call SaveInteger(itemDb, 'I00R', ITEM_FIELD_BONUS_AGI, 3)
        call SaveInteger(itemDb, 'I00R', ITEM_FIELD_GOLD_COST, 1300)
        call SaveInteger(itemDb, 'I00R', ITEM_FIELD_TAGS, ITEM_TAG_DEFENSIVE)

        // --- Armadura Lunar Mejorada +10 'I00S' ---
        // 2600 oro, pasivo. +10 Armor, +1000 HP, +600 MP, +6 AGI. DEFENSIVE.
        call SaveReal(itemDb, 'I00S', ITEM_FIELD_ARMOR, 10.0)
        call SaveReal(itemDb, 'I00S', ITEM_FIELD_BONUS_HP, 1000.0)
        call SaveReal(itemDb, 'I00S', ITEM_FIELD_BONUS_MP, 600.0)
        call SaveInteger(itemDb, 'I00S', ITEM_FIELD_BONUS_AGI, 6)
        call SaveInteger(itemDb, 'I00S', ITEM_FIELD_GOLD_COST, 2600)
        call SaveInteger(itemDb, 'I00S', ITEM_FIELD_TAGS, ITEM_TAG_DEFENSIVE)

        // --- Piel Reforzada +15 'I00K' ---
        // 3900 oro, pasivo. +15 Armor, +1500 HP, +900 MP, +9 AGI. DEFENSIVE.
        call SaveReal(itemDb, 'I00K', ITEM_FIELD_ARMOR, 15.0)
        call SaveReal(itemDb, 'I00K', ITEM_FIELD_BONUS_HP, 1500.0)
        call SaveReal(itemDb, 'I00K', ITEM_FIELD_BONUS_MP, 900.0)
        call SaveInteger(itemDb, 'I00K', ITEM_FIELD_BONUS_AGI, 9)
        call SaveInteger(itemDb, 'I00K', ITEM_FIELD_GOLD_COST, 3900)
        call SaveInteger(itemDb, 'I00K', ITEM_FIELD_TAGS, ITEM_TAG_DEFENSIVE)

        // --- Armadura Infame +5 'I00N' ---
        // 1300 oro, pasivo. +5 Armor, +500 HP, +300 MP, +3 INT. DEFENSIVE.
        call SaveReal(itemDb, 'I00N', ITEM_FIELD_ARMOR, 5.0)
        call SaveReal(itemDb, 'I00N', ITEM_FIELD_BONUS_HP, 500.0)
        call SaveReal(itemDb, 'I00N', ITEM_FIELD_BONUS_MP, 300.0)
        call SaveInteger(itemDb, 'I00N', ITEM_FIELD_BONUS_INT, 3)
        call SaveInteger(itemDb, 'I00N', ITEM_FIELD_GOLD_COST, 1300)
        call SaveInteger(itemDb, 'I00N', ITEM_FIELD_TAGS, ITEM_TAG_DEFENSIVE)

        // --- Armadura de Cuero Mejorada +10 'I00O' ---
        // 2600 oro, pasivo. +10 Armor, +1000 HP, +600 MP, +6 INT. DEFENSIVE.
        call SaveReal(itemDb, 'I00O', ITEM_FIELD_ARMOR, 10.0)
        call SaveReal(itemDb, 'I00O', ITEM_FIELD_BONUS_HP, 1000.0)
        call SaveReal(itemDb, 'I00O', ITEM_FIELD_BONUS_MP, 600.0)
        call SaveInteger(itemDb, 'I00O', ITEM_FIELD_BONUS_INT, 6)
        call SaveInteger(itemDb, 'I00O', ITEM_FIELD_GOLD_COST, 2600)
        call SaveInteger(itemDb, 'I00O', ITEM_FIELD_TAGS, ITEM_TAG_DEFENSIVE)

        // --- Armadura de Cuero Reforzada +15 'I00P' ---
        // 3900 oro, pasivo. +15 Armor, +1500 HP, +900 MP, +9 INT. DEFENSIVE.
        call SaveReal(itemDb, 'I00P', ITEM_FIELD_ARMOR, 15.0)
        call SaveReal(itemDb, 'I00P', ITEM_FIELD_BONUS_HP, 1500.0)
        call SaveReal(itemDb, 'I00P', ITEM_FIELD_BONUS_MP, 900.0)
        call SaveInteger(itemDb, 'I00P', ITEM_FIELD_BONUS_INT, 9)
        call SaveInteger(itemDb, 'I00P', ITEM_FIELD_GOLD_COST, 3900)
        call SaveInteger(itemDb, 'I00P', ITEM_FIELD_TAGS, ITEM_TAG_DEFENSIVE)

        // --- Coraza de Hierro +5 'I00J' ---
        // 1300 oro, pasivo. +5 Armor, +500 HP, +300 MP, +3 STR. DEFENSIVE.
        call SaveReal(itemDb, 'I00J', ITEM_FIELD_ARMOR, 5.0)
        call SaveReal(itemDb, 'I00J', ITEM_FIELD_BONUS_HP, 500.0)
        call SaveReal(itemDb, 'I00J', ITEM_FIELD_BONUS_MP, 300.0)
        call SaveInteger(itemDb, 'I00J', ITEM_FIELD_BONUS_STR, 3)
        call SaveInteger(itemDb, 'I00J', ITEM_FIELD_GOLD_COST, 1300)
        call SaveInteger(itemDb, 'I00J', ITEM_FIELD_TAGS, ITEM_TAG_DEFENSIVE)

        // --- Coraza de Acero +10 'I00L' ---
        // 2600 oro, pasivo. +10 Armor, +1000 HP, +600 MP, +6 STR. DEFENSIVE.
        call SaveReal(itemDb, 'I00L', ITEM_FIELD_ARMOR, 10.0)
        call SaveReal(itemDb, 'I00L', ITEM_FIELD_BONUS_HP, 1000.0)
        call SaveReal(itemDb, 'I00L', ITEM_FIELD_BONUS_MP, 600.0)
        call SaveInteger(itemDb, 'I00L', ITEM_FIELD_BONUS_STR, 6)
        call SaveInteger(itemDb, 'I00L', ITEM_FIELD_GOLD_COST, 2600)
        call SaveInteger(itemDb, 'I00L', ITEM_FIELD_TAGS, ITEM_TAG_DEFENSIVE)

        // --- Coraza de Honor +15 'I00T' ---
        // 3900 oro, pasivo. +15 Armor, +1500 HP, +900 MP, +9 STR. DEFENSIVE.
        call SaveReal(itemDb, 'I00T', ITEM_FIELD_ARMOR, 15.0)
        call SaveReal(itemDb, 'I00T', ITEM_FIELD_BONUS_HP, 1500.0)
        call SaveReal(itemDb, 'I00T', ITEM_FIELD_BONUS_MP, 900.0)
        call SaveInteger(itemDb, 'I00T', ITEM_FIELD_BONUS_STR, 9)
        call SaveInteger(itemDb, 'I00T', ITEM_FIELD_GOLD_COST, 3900)
        call SaveInteger(itemDb, 'I00T', ITEM_FIELD_TAGS, ITEM_TAG_DEFENSIVE)

        // --- Critical Sword 'I004' ---
        // 3500 oro + 10 madera, pasivo. 30% crítico a x2.0 daño.
        // DECISIONES:
        //   - OFFENSIVE: puro daño, escala con AGI.
        //   - NO PROC_CHANCE: el crítico es una estadística pasiva de DPS,
        //     no un efecto on-hit poco confiable. La fórmula de DPS ya
        //     lo integra matemáticamente como valor esperado.
        call SaveReal(itemDb, 'I004', ITEM_FIELD_CRIT_CHANCE, 0.30)
        call SaveReal(itemDb, 'I004', ITEM_FIELD_CRIT_MULTIPLIER, 2.0)
        call SaveInteger(itemDb, 'I004', ITEM_FIELD_GOLD_COST, 3500)
        call SaveInteger(itemDb, 'I004', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE + ITEM_TAG_UNIQUE_HERO)

        // --- Corazón de Bloodfeather 'bfhr' ---
        // 2500 oro, pasivo. +2000 HP. Puro tanque.
        call SaveReal(itemDb, 'bfhr', ITEM_FIELD_BONUS_HP, 2000.0)
        call SaveInteger(itemDb, 'bfhr', ITEM_FIELD_GOLD_COST, 2500)
        call SaveInteger(itemDb, 'bfhr', ITEM_FIELD_TAGS, ITEM_TAG_DEFENSIVE)

        // --- Escudo de Arcanita 'arsh' ---
        // 3000 oro, pasivo. +35 Armor. Puro tanque físico.
        call SaveReal(itemDb, 'arsh', ITEM_FIELD_ARMOR, 35.0)
        call SaveInteger(itemDb, 'arsh', ITEM_FIELD_GOLD_COST, 3000)
        call SaveInteger(itemDb, 'arsh', ITEM_FIELD_TAGS, ITEM_TAG_DEFENSIVE)

        // --- Guardahielo 'frgd' ---
        // 2500 oro, pasivo on-hit. +50 daño, aplica B00T (-25% AS, -50% MS).
        // DECISIONES:
        //   - ORB_EFFECT: UAM, no stackea con Hand ni otras orbes.
        //   - SOFT_CC: aplica slow.
        //   - NO GRANTS_AA: a diferencia de ofro, no permite atacar aire.
        call SaveReal(itemDb, 'frgd', ITEM_FIELD_FLAT_DAMAGE, 50.0)
        call SaveInteger(itemDb, 'frgd', ITEM_FIELD_BUFF_ID, 'B00T')
        call SaveInteger(itemDb, 'frgd', ITEM_FIELD_GOLD_COST, 2500)
        call SaveInteger(itemDb, 'frgd', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE + ITEM_TAG_ORB_EFFECT + ITEM_TAG_SOFT_CC + ITEM_TAG_UNIQUE_TEAM)

        // --- Amuleto Antimagia 'I003' ---
        // 1500 oro, pasivo. Aura de espinas (BEah) + bloqueo de hechizo.
        // DECISIONES:
        //   - BUFF_ID = BEah (aura constante, espinas 11%). YAGNI en BNss
        //     (buff visual de milisegundo al bloquear, sin valor para la IA).
        //   - SPELL_BLOCK: protege contra 1 hechizo dirigido. NO usar
        //     ITEM_FIELD_COOLDOWN (40s) porque NO es activo — la FSM
        //     intentaría clicarlo. El CD es interno de WC3.
        //   - DEFENSIVE: su propósito absoluto es no morir.
        call SaveInteger(itemDb, 'I003', ITEM_FIELD_BUFF_ID, 'BEah')
        call SaveReal(itemDb, 'I003', ITEM_FIELD_AOE_RADIUS, 1000.0)
        call SaveInteger(itemDb, 'I003', ITEM_FIELD_GOLD_COST, 1500)
        call SaveInteger(itemDb, 'I003', ITEM_FIELD_TAGS, ITEM_TAG_DEFENSIVE + ITEM_TAG_SPELL_BLOCK + ITEM_TAG_UNIQUE_HERO)

        // --- Finger of Harm 'I006' ---
        // 1000 oro + 10 madera, activo. 300 daño directo a enemigo, 800 rango, 30s CD.
        // DECISIONES:
        //   - NO TARGET_ENEMY: convención = el defecto es enemigo.
        //     Solo TARGET_ALLY es excepción explícita.
        //   - NO ITEM_TAG_NUKE: CAST_DAMAGE ya es la señal para lethal check.
        //     FSM: if enemyHP <= GetCastDamage(itemId) → usar.
        //   - YAGNI en retraso gráfico (0.25s): WC3 lo maneja internamente.
        //   - Sin receta: la fusión (I006 + I006 = Lvl2) se registra en el Lvl2.
        call SaveReal(itemDb, 'I006', ITEM_FIELD_CAST_DAMAGE, 300.0)
        call SaveReal(itemDb, 'I006', ITEM_FIELD_CAST_RANGE, 800.0)
        call SaveReal(itemDb, 'I006', ITEM_FIELD_COOLDOWN, 30.0)
        call SaveInteger(itemDb, 'I006', ITEM_FIELD_GOLD_COST, 1000)
        call SaveInteger(itemDb, 'I006', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE + ITEM_TAG_ACTIVE)

        // --- Hand of Wickness 'I005' ---
        // 2000 oro, pasivo on-hit. Reduce -20 armor al objetivo (BIcb), 5s.
        // DECISIONES:
        //   - ORB_EFFECT: UAM, no stackea con frgd/ofro ni flechas elementales.
        //   - UNIQUE_TEAM: solo 1 por equipo (no se acumula).
        //   - RANGED_ONLY: solo ranged puede aplicar el debuff de forma
        //     confiable a través de los creeps. Melee no llega al objetivo.
        //   - NO ITEM_TAG_CORE: CORE = "rush minuto 0" (botas).
        //     El Hand es vital pero NO es rush. UNIQUE_TEAM + la matemática
        //     de -20 armor bastarán para que Shopping lo priorice naturalmente.
        call SaveInteger(itemDb, 'I005', ITEM_FIELD_BUFF_ID, 'BIcb')
        call SaveInteger(itemDb, 'I005', ITEM_FIELD_GOLD_COST, 2000)
        call SaveInteger(itemDb, 'I005', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE + ITEM_TAG_ORB_EFFECT + ITEM_TAG_UNIQUE_TEAM + ITEM_TAG_RANGED_ONLY)

        // ==========================================================
        // ÍTEMS DE FUSIÓN (RECETAS)
        // ==========================================================
        // Convención:
        //   - GOLD_COST = costo EXTRA de la receta (0 = gratis al juntar).
        //   - RECIPE_1..N = IDs de ingredientes, SIN significado posicional.
        //     El orden de columnas para el bug de fusión lo maneja
        //     IA_State_Shopping en runtime (primer comprado → col 1).
        //   - RECIPE_RESULT tag = "no se compra en tienda, se fabrica".
        // ==========================================================

        // --- Báculo de Velocidad y Teletransporte 'I00W' (Botas TP) ---
        // Fusión: bspd + brac (gratis). +60 MS, TP a aliado, 90s CD, 3s channel.
        // DECISIONES:
        //   - GOLD_COST = 0: la fusión no cuesta oro extra.
        //     Shopping calcula inversión restante de ingredientes faltantes.
        //   - CORE + BOOTS + RECIPE_RESULT: prioridad máxima de fabricación,
        //     solo 1 par de botas, no se vende nunca.
        //   - Hereda mecánicas de brac: ACTIVE, CHANNELING, TARGET_ALLY.
        //   - Una vez fabricado, Shopping NUNCA vuelve a comprar bspd ni brac
        //     (ya están fusionados dentro de I00W).
        call SaveReal(itemDb, 'I00W', ITEM_FIELD_MOVE_SPEED, 60.0)
        call SaveReal(itemDb, 'I00W', ITEM_FIELD_CAST_RANGE, 99999.0)
        call SaveReal(itemDb, 'I00W', ITEM_FIELD_COOLDOWN, 90.0)
        call SaveReal(itemDb, 'I00W', ITEM_FIELD_CHANNEL_TIME, 3.0)
        call SaveInteger(itemDb, 'I00W', ITEM_FIELD_GOLD_COST, 0)
        call SaveInteger(itemDb, 'I00W', ITEM_FIELD_RECIPE_COUNT, 2)
        call SaveInteger(itemDb, 'I00W', ITEM_FIELD_RECIPE_1, 'bspd')
        call SaveInteger(itemDb, 'I00W', ITEM_FIELD_RECIPE_2, 'brac')
        call SaveInteger(itemDb, 'I00W', ITEM_FIELD_TAGS, ITEM_TAG_UTILITY + ITEM_TAG_ACTIVE + ITEM_TAG_CORE + ITEM_TAG_BOOTS + ITEM_TAG_CHANNELING + ITEM_TAG_TARGET_ALLY + ITEM_TAG_RECIPE_RESULT)

        // --- Power Treads [Inteligencia] 'I017' ---
        // Fusión: belv + gcel + ciri (gratis). +20 INT, +25% AS.
        // DECISIONES:
        //   - Única forma con RECIPE: es el resultado directo de la fusión.
        //   - NEXT_STATE → I019 (AGI). Bucle: I017 → I019 → I018 → I017.
        //   - NO son botas: coexisten con Botas TP (I00W) sin conflicto.
        //   - UNIQUE_HERO: solo 1 set de Power Treads por héroe.
        //   - ACTIVE + CAST_RANGE 0: self-cast (clic para cambiar forma).
        //   - YAGNI en cooldown: cambio es instantáneo.
        //   - Se vende en Late Game: Shopping lo deducirá matemáticamente
        //     cuando un ítem de Tier Alto supere su valor de +20 stats.
        call SaveInteger(itemDb, 'I017', ITEM_FIELD_BONUS_INT, 20)
        call SaveReal(itemDb, 'I017', ITEM_FIELD_ATTACK_SPEED, 0.25)
        call SaveReal(itemDb, 'I017', ITEM_FIELD_CAST_RANGE, 0.0)
        call SaveInteger(itemDb, 'I017', ITEM_FIELD_NEXT_STATE, 'I019')
        call SaveInteger(itemDb, 'I017', ITEM_FIELD_GOLD_COST, 0)
        call SaveInteger(itemDb, 'I017', ITEM_FIELD_RECIPE_COUNT, 3)
        call SaveInteger(itemDb, 'I017', ITEM_FIELD_RECIPE_1, 'belv')
        call SaveInteger(itemDb, 'I017', ITEM_FIELD_RECIPE_2, 'gcel')
        call SaveInteger(itemDb, 'I017', ITEM_FIELD_RECIPE_3, 'ciri')
        call SaveInteger(itemDb, 'I017', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE + ITEM_TAG_ACTIVE + ITEM_TAG_UNIQUE_HERO + ITEM_TAG_RECIPE_RESULT)

        // --- Power Treads [Agilidad] 'I019' ---
        // +20 AGI, +25% AS. Forma 2 del bucle.
        call SaveInteger(itemDb, 'I019', ITEM_FIELD_BONUS_AGI, 20)
        call SaveReal(itemDb, 'I019', ITEM_FIELD_ATTACK_SPEED, 0.25)
        call SaveReal(itemDb, 'I019', ITEM_FIELD_CAST_RANGE, 0.0)
        call SaveInteger(itemDb, 'I019', ITEM_FIELD_NEXT_STATE, 'I018')
        call SaveInteger(itemDb, 'I019', ITEM_FIELD_GOLD_COST, 0)
        call SaveInteger(itemDb, 'I019', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE + ITEM_TAG_ACTIVE + ITEM_TAG_UNIQUE_HERO + ITEM_TAG_RECIPE_RESULT)

        // --- Power Treads [Fuerza] 'I018' ---
        // +20 STR, +25% AS. Forma 3 del bucle. Cierra el ciclo → I017.
        call SaveInteger(itemDb, 'I018', ITEM_FIELD_BONUS_STR, 20)
        call SaveReal(itemDb, 'I018', ITEM_FIELD_ATTACK_SPEED, 0.25)
        call SaveReal(itemDb, 'I018', ITEM_FIELD_CAST_RANGE, 0.0)
        call SaveInteger(itemDb, 'I018', ITEM_FIELD_NEXT_STATE, 'I017')
        call SaveInteger(itemDb, 'I018', ITEM_FIELD_GOLD_COST, 0)
        call SaveInteger(itemDb, 'I018', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE + ITEM_TAG_ACTIVE + ITEM_TAG_UNIQUE_HERO + ITEM_TAG_RECIPE_RESULT)

        // --- Wand of Negation 6 cargas 'I012' ---
        // Fusión: wneg + wneg (gratis). Misma funcionalidad, el doble de cargas.
        // DECISIONES:
        //   - Primera receta A + A = B: RECIPE_1 y RECIPE_2 = mismo ID.
        //     Por eso wneg NUNCA lleva UNIQUE_HERO (necesita comprar 2).
        //   - Mismos stats que wneg: 800 rango, 325 AoE, 7s CD, 1000 DMG summons.
        //   - YAGNI en MAX_CHARGES: WC3 tiene GetItemCharges() nativo.
        //   - CONSUMABLE: se gasta y desaparece → Shopping sabe que debe reponer.
        //   - Tags = wneg + RECIPE_RESULT.
        call SaveInteger(itemDb, 'I012', ITEM_FIELD_GOLD_COST, 0)
        call SaveReal(itemDb, 'I012', ITEM_FIELD_CAST_RANGE, 800.0)
        call SaveReal(itemDb, 'I012', ITEM_FIELD_AOE_RADIUS, 325.0)
        call SaveReal(itemDb, 'I012', ITEM_FIELD_COOLDOWN, 7.0)
        call SaveReal(itemDb, 'I012', ITEM_FIELD_BONUS_DMG_SUMMON, 1000.0)
        call SaveInteger(itemDb, 'I012', ITEM_FIELD_RECIPE_COUNT, 2)
        call SaveInteger(itemDb, 'I012', ITEM_FIELD_RECIPE_1, 'wneg')
        call SaveInteger(itemDb, 'I012', ITEM_FIELD_RECIPE_2, 'wneg')
        call SaveInteger(itemDb, 'I012', ITEM_FIELD_TAGS, ITEM_TAG_UTILITY + ITEM_TAG_ACTIVE + ITEM_TAG_CONSUMABLE + ITEM_TAG_POINT_TARGET + ITEM_TAG_AOE + ITEM_TAG_PURGE + ITEM_TAG_RECIPE_RESULT)

        // --- Wand of Negation 9 cargas 'I01S' ---
        // Fusión: I012 (6 cargas) + wneg (3 cargas) = 9 cargas. TOPE de fusión.
        // DECISIONES:
        //   - Segunda receta mixta: I012 + wneg → I01S.
        //     Inversión total: 3 compras de wneg (200×3 = 600 oro).
        //   - Mismos stats que wneg/I012: 800 rango, 325 AoE, 7s CD, 1000 DMG summons.
        //   - CONSUMABLE: se gasta y desaparece → Shopping sabe que debe reponer.
        //   - Tags = I012 + RECIPE_RESULT (hereda).
        //   - TOPE: no existe fusión posterior. Máximo 9 cargas por slot.
        call SaveInteger(itemDb, 'I01S', ITEM_FIELD_GOLD_COST, 0)
        call SaveReal(itemDb, 'I01S', ITEM_FIELD_CAST_RANGE, 800.0)
        call SaveReal(itemDb, 'I01S', ITEM_FIELD_AOE_RADIUS, 325.0)
        call SaveReal(itemDb, 'I01S', ITEM_FIELD_COOLDOWN, 7.0)
        call SaveReal(itemDb, 'I01S', ITEM_FIELD_BONUS_DMG_SUMMON, 1000.0)
        call SaveInteger(itemDb, 'I01S', ITEM_FIELD_RECIPE_COUNT, 2)
        call SaveInteger(itemDb, 'I01S', ITEM_FIELD_RECIPE_1, 'I012')
        call SaveInteger(itemDb, 'I01S', ITEM_FIELD_RECIPE_2, 'wneg')
        call SaveInteger(itemDb, 'I01S', ITEM_FIELD_TAGS, ITEM_TAG_UTILITY + ITEM_TAG_ACTIVE + ITEM_TAG_CONSUMABLE + ITEM_TAG_POINT_TARGET + ITEM_TAG_AOE + ITEM_TAG_PURGE + ITEM_TAG_RECIPE_RESULT)

        // --- Garra de Mannoroth +150 'I01K' ---
        // Fusión: I008 (Hacha +25) + I009 (Garras +50) + I00A (Hacha Inf. +75).
        // +150 daño, +18 STR, +10 AGI, +10 INT. STR-primary.
        call SaveReal(itemDb, 'I01K', ITEM_FIELD_FLAT_DAMAGE, 150.0)
        call SaveInteger(itemDb, 'I01K', ITEM_FIELD_BONUS_STR, 18)
        call SaveInteger(itemDb, 'I01K', ITEM_FIELD_BONUS_AGI, 10)
        call SaveInteger(itemDb, 'I01K', ITEM_FIELD_BONUS_INT, 10)
        call SaveInteger(itemDb, 'I01K', ITEM_FIELD_GOLD_COST, 0)
        call SaveInteger(itemDb, 'I01K', ITEM_FIELD_RECIPE_COUNT, 3)
        call SaveInteger(itemDb, 'I01K', ITEM_FIELD_RECIPE_1, 'I008')
        call SaveInteger(itemDb, 'I01K', ITEM_FIELD_RECIPE_2, 'I009')
        call SaveInteger(itemDb, 'I01K', ITEM_FIELD_RECIPE_3, 'I00A')
        call SaveInteger(itemDb, 'I01K', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE + ITEM_TAG_RECIPE_RESULT)

        // --- Colmillo de Hakkar +150 'I01L' ---
        // Fusión: I00C (Daga +25) + I00D (Puñal +50) + I00E (Impacto +75).
        // +150 daño, +10 STR, +18 AGI, +10 INT. AGI-primary.
        call SaveReal(itemDb, 'I01L', ITEM_FIELD_FLAT_DAMAGE, 150.0)
        call SaveInteger(itemDb, 'I01L', ITEM_FIELD_BONUS_STR, 10)
        call SaveInteger(itemDb, 'I01L', ITEM_FIELD_BONUS_AGI, 18)
        call SaveInteger(itemDb, 'I01L', ITEM_FIELD_BONUS_INT, 10)
        call SaveInteger(itemDb, 'I01L', ITEM_FIELD_GOLD_COST, 0)
        call SaveInteger(itemDb, 'I01L', ITEM_FIELD_RECIPE_COUNT, 3)
        call SaveInteger(itemDb, 'I01L', ITEM_FIELD_RECIPE_1, 'I00C')
        call SaveInteger(itemDb, 'I01L', ITEM_FIELD_RECIPE_2, 'I00D')
        call SaveInteger(itemDb, 'I01L', ITEM_FIELD_RECIPE_3, 'I00E')
        call SaveInteger(itemDb, 'I01L', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE + ITEM_TAG_RECIPE_RESULT)

        // --- Cetro de Kel'Thuzad +150 'I01M' ---
        // Fusión: I00G (Varita +25) + I00H (Libro +50) + I00I (Báculo +75).
        // +150 daño, +10 STR, +10 AGI, +18 INT. INT-primary.
        call SaveReal(itemDb, 'I01M', ITEM_FIELD_FLAT_DAMAGE, 150.0)
        call SaveInteger(itemDb, 'I01M', ITEM_FIELD_BONUS_STR, 10)
        call SaveInteger(itemDb, 'I01M', ITEM_FIELD_BONUS_AGI, 10)
        call SaveInteger(itemDb, 'I01M', ITEM_FIELD_BONUS_INT, 18)
        call SaveInteger(itemDb, 'I01M', ITEM_FIELD_GOLD_COST, 0)
        call SaveInteger(itemDb, 'I01M', ITEM_FIELD_RECIPE_COUNT, 3)
        call SaveInteger(itemDb, 'I01M', ITEM_FIELD_RECIPE_1, 'I00G')
        call SaveInteger(itemDb, 'I01M', ITEM_FIELD_RECIPE_2, 'I00H')
        call SaveInteger(itemDb, 'I01M', ITEM_FIELD_RECIPE_3, 'I00I')
        call SaveInteger(itemDb, 'I01M', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE + ITEM_TAG_RECIPE_RESULT)

        // --- Super Armadura Lunar +40 'I01B' ---
        // Fusión: I00U + I00U (gratis). +40 Armor, +4000 HP, +2400 MP, +24 AGI.
        // A+A=B: por eso I00U NO lleva UNIQUE_HERO.
        call SaveReal(itemDb, 'I01B', ITEM_FIELD_ARMOR, 40.0)
        call SaveReal(itemDb, 'I01B', ITEM_FIELD_BONUS_HP, 4000.0)
        call SaveReal(itemDb, 'I01B', ITEM_FIELD_BONUS_MP, 2400.0)
        call SaveInteger(itemDb, 'I01B', ITEM_FIELD_BONUS_AGI, 24)
        call SaveInteger(itemDb, 'I01B', ITEM_FIELD_GOLD_COST, 0)
        call SaveInteger(itemDb, 'I01B', ITEM_FIELD_RECIPE_COUNT, 2)
        call SaveInteger(itemDb, 'I01B', ITEM_FIELD_RECIPE_1, 'I00U')
        call SaveInteger(itemDb, 'I01B', ITEM_FIELD_RECIPE_2, 'I00U')
        call SaveInteger(itemDb, 'I01B', ITEM_FIELD_TAGS, ITEM_TAG_DEFENSIVE + ITEM_TAG_RECIPE_RESULT)

        // --- Super Coraza de Infame +40 'I01A' ---
        // Fusión: I00M + I00M (gratis). +40 Armor, +4000 HP, +2400 MP, +24 STR.
        // A+A=B: por eso I00M NO lleva UNIQUE_HERO.
        call SaveReal(itemDb, 'I01A', ITEM_FIELD_ARMOR, 40.0)
        call SaveReal(itemDb, 'I01A', ITEM_FIELD_BONUS_HP, 4000.0)
        call SaveReal(itemDb, 'I01A', ITEM_FIELD_BONUS_MP, 2400.0)
        call SaveInteger(itemDb, 'I01A', ITEM_FIELD_BONUS_STR, 24)
        call SaveInteger(itemDb, 'I01A', ITEM_FIELD_GOLD_COST, 0)
        call SaveInteger(itemDb, 'I01A', ITEM_FIELD_RECIPE_COUNT, 2)
        call SaveInteger(itemDb, 'I01A', ITEM_FIELD_RECIPE_1, 'I00M')
        call SaveInteger(itemDb, 'I01A', ITEM_FIELD_RECIPE_2, 'I00M')
        call SaveInteger(itemDb, 'I01A', ITEM_FIELD_TAGS, ITEM_TAG_DEFENSIVE + ITEM_TAG_RECIPE_RESULT)

        // --- Super Escamas de Dragón +40 'I01C' ---
        // Fusión: I00Q + I00Q (gratis). +40 Armor, +4000 HP, +2400 MP, +24 INT.
        // A+A=B: por eso I00Q NO lleva UNIQUE_HERO.
        call SaveReal(itemDb, 'I01C', ITEM_FIELD_ARMOR, 40.0)
        call SaveReal(itemDb, 'I01C', ITEM_FIELD_BONUS_HP, 4000.0)
        call SaveReal(itemDb, 'I01C', ITEM_FIELD_BONUS_MP, 2400.0)
        call SaveInteger(itemDb, 'I01C', ITEM_FIELD_BONUS_INT, 24)
        call SaveInteger(itemDb, 'I01C', ITEM_FIELD_GOLD_COST, 0)
        call SaveInteger(itemDb, 'I01C', ITEM_FIELD_RECIPE_COUNT, 2)
        call SaveInteger(itemDb, 'I01C', ITEM_FIELD_RECIPE_1, 'I00Q')
        call SaveInteger(itemDb, 'I01C', ITEM_FIELD_RECIPE_2, 'I00Q')
        call SaveInteger(itemDb, 'I01C', ITEM_FIELD_TAGS, ITEM_TAG_DEFENSIVE + ITEM_TAG_RECIPE_RESULT)

        // --- Hacha Suprema +200 'I01E' ---
        // Fusión: I007 + I007 (gratis). +200 daño, +24 STR, +18 AGI, +18 INT.
        // A+A=B: por eso I007 NO lleva UNIQUE_HERO. STR-primary.
        call SaveReal(itemDb, 'I01E', ITEM_FIELD_FLAT_DAMAGE, 200.0)
        call SaveInteger(itemDb, 'I01E', ITEM_FIELD_BONUS_STR, 24)
        call SaveInteger(itemDb, 'I01E', ITEM_FIELD_BONUS_AGI, 18)
        call SaveInteger(itemDb, 'I01E', ITEM_FIELD_BONUS_INT, 18)
        call SaveInteger(itemDb, 'I01E', ITEM_FIELD_GOLD_COST, 0)
        call SaveInteger(itemDb, 'I01E', ITEM_FIELD_RECIPE_COUNT, 2)
        call SaveInteger(itemDb, 'I01E', ITEM_FIELD_RECIPE_1, 'I007')
        call SaveInteger(itemDb, 'I01E', ITEM_FIELD_RECIPE_2, 'I007')
        call SaveInteger(itemDb, 'I01E', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE + ITEM_TAG_RECIPE_RESULT)

        // --- Super Impacto Oscuro +200 'I01D' ---
        // Fusión: I00B + I00B (gratis). +200 daño, +18 STR, +24 AGI, +18 INT.
        // A+A=B: por eso I00B NO lleva UNIQUE_HERO. AGI-primary.
        call SaveReal(itemDb, 'I01D', ITEM_FIELD_FLAT_DAMAGE, 200.0)
        call SaveInteger(itemDb, 'I01D', ITEM_FIELD_BONUS_STR, 18)
        call SaveInteger(itemDb, 'I01D', ITEM_FIELD_BONUS_AGI, 24)
        call SaveInteger(itemDb, 'I01D', ITEM_FIELD_BONUS_INT, 18)
        call SaveInteger(itemDb, 'I01D', ITEM_FIELD_GOLD_COST, 0)
        call SaveInteger(itemDb, 'I01D', ITEM_FIELD_RECIPE_COUNT, 2)
        call SaveInteger(itemDb, 'I01D', ITEM_FIELD_RECIPE_1, 'I00B')
        call SaveInteger(itemDb, 'I01D', ITEM_FIELD_RECIPE_2, 'I00B')
        call SaveInteger(itemDb, 'I01D', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE + ITEM_TAG_RECIPE_RESULT)

        // --- Supremo Libro Maestro +200 'I01F' ---
        // Fusión: I00F + I00F (gratis). +200 daño, +18 STR, +18 AGI, +24 INT.
        // A+A=B: por eso I00F NO lleva UNIQUE_HERO. INT-primary.
        call SaveReal(itemDb, 'I01F', ITEM_FIELD_FLAT_DAMAGE, 200.0)
        call SaveInteger(itemDb, 'I01F', ITEM_FIELD_BONUS_STR, 18)
        call SaveInteger(itemDb, 'I01F', ITEM_FIELD_BONUS_AGI, 18)
        call SaveInteger(itemDb, 'I01F', ITEM_FIELD_BONUS_INT, 24)
        call SaveInteger(itemDb, 'I01F', ITEM_FIELD_GOLD_COST, 0)
        call SaveInteger(itemDb, 'I01F', ITEM_FIELD_RECIPE_COUNT, 2)
        call SaveInteger(itemDb, 'I01F', ITEM_FIELD_RECIPE_1, 'I00F')
        call SaveInteger(itemDb, 'I01F', ITEM_FIELD_RECIPE_2, 'I00F')
        call SaveInteger(itemDb, 'I01F', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE + ITEM_TAG_RECIPE_RESULT)

        // --- Manto de Maiev +30 'I01N' ---
        // Fusión: I00R (AGI) + I00S (AGI) + I00K (AGI).
        // +30 Armor, +3000 HP, +1800 MP, +18 AGI. DEFENSIVE.
        call SaveReal(itemDb, 'I01N', ITEM_FIELD_ARMOR, 30.0)
        call SaveReal(itemDb, 'I01N', ITEM_FIELD_BONUS_HP, 3000.0)
        call SaveReal(itemDb, 'I01N', ITEM_FIELD_BONUS_MP, 1800.0)
        call SaveInteger(itemDb, 'I01N', ITEM_FIELD_BONUS_AGI, 18)
        call SaveInteger(itemDb, 'I01N', ITEM_FIELD_GOLD_COST, 0)
        call SaveInteger(itemDb, 'I01N', ITEM_FIELD_RECIPE_COUNT, 3)
        call SaveInteger(itemDb, 'I01N', ITEM_FIELD_RECIPE_1, 'I00R')
        call SaveInteger(itemDb, 'I01N', ITEM_FIELD_RECIPE_2, 'I00S')
        call SaveInteger(itemDb, 'I01N', ITEM_FIELD_RECIPE_3, 'I00K')
        call SaveInteger(itemDb, 'I01N', ITEM_FIELD_TAGS, ITEM_TAG_DEFENSIVE + ITEM_TAG_RECIPE_RESULT)

        // --- Vestiduras de Ner'zhul +30 'I01O' ---
        // Fusión: I00N (INT) + I00O (INT) + I00P (INT).
        // +30 Armor, +3000 HP, +1800 MP, +18 INT. DEFENSIVE.
        call SaveReal(itemDb, 'I01O', ITEM_FIELD_ARMOR, 30.0)
        call SaveReal(itemDb, 'I01O', ITEM_FIELD_BONUS_HP, 3000.0)
        call SaveReal(itemDb, 'I01O', ITEM_FIELD_BONUS_MP, 1800.0)
        call SaveInteger(itemDb, 'I01O', ITEM_FIELD_BONUS_INT, 18)
        call SaveInteger(itemDb, 'I01O', ITEM_FIELD_GOLD_COST, 0)
        call SaveInteger(itemDb, 'I01O', ITEM_FIELD_RECIPE_COUNT, 3)
        call SaveInteger(itemDb, 'I01O', ITEM_FIELD_RECIPE_1, 'I00N')
        call SaveInteger(itemDb, 'I01O', ITEM_FIELD_RECIPE_2, 'I00O')
        call SaveInteger(itemDb, 'I01O', ITEM_FIELD_RECIPE_3, 'I00P')
        call SaveInteger(itemDb, 'I01O', ITEM_FIELD_TAGS, ITEM_TAG_DEFENSIVE + ITEM_TAG_RECIPE_RESULT)

        // --- Baluarte de Lothar +30 'I01P' ---
        // Fusión: I00J (STR) + I00L (STR) + I00T (STR).
        // +30 Armor, +3000 HP, +1800 MP, +18 STR. DEFENSIVE.
        call SaveReal(itemDb, 'I01P', ITEM_FIELD_ARMOR, 30.0)
        call SaveReal(itemDb, 'I01P', ITEM_FIELD_BONUS_HP, 3000.0)
        call SaveReal(itemDb, 'I01P', ITEM_FIELD_BONUS_MP, 1800.0)
        call SaveInteger(itemDb, 'I01P', ITEM_FIELD_BONUS_STR, 18)
        call SaveInteger(itemDb, 'I01P', ITEM_FIELD_GOLD_COST, 0)
        call SaveInteger(itemDb, 'I01P', ITEM_FIELD_RECIPE_COUNT, 3)
        call SaveInteger(itemDb, 'I01P', ITEM_FIELD_RECIPE_1, 'I00J')
        call SaveInteger(itemDb, 'I01P', ITEM_FIELD_RECIPE_2, 'I00L')
        call SaveInteger(itemDb, 'I01P', ITEM_FIELD_RECIPE_3, 'I00T')
        call SaveInteger(itemDb, 'I01P', ITEM_FIELD_TAGS, ITEM_TAG_DEFENSIVE + ITEM_TAG_RECIPE_RESULT)

        // --- Finger of Harm [Level 2] 'I013' ---
        // Fusión: I006 + I006 (gratis). 650 daño, 900 rango, 60s CD, 300 maná.
        // DECISIONES:
        //   - A+A=B: por eso I006 NO lleva UNIQUE_HERO.
        //   - A diferencia de I006 (base), este SÍ cuesta maná (300).
        //   - Mayor rango (900 vs 800) y mayor CD (60s vs 30s).
        //   - Lethal check: if enemyHP <= 650 and mana >= 300 → usar.
        call SaveReal(itemDb, 'I013', ITEM_FIELD_CAST_DAMAGE, 650.0)
        call SaveReal(itemDb, 'I013', ITEM_FIELD_CAST_RANGE, 900.0)
        call SaveReal(itemDb, 'I013', ITEM_FIELD_COOLDOWN, 60.0)
        call SaveInteger(itemDb, 'I013', ITEM_FIELD_MANA_COST, 300)
        call SaveInteger(itemDb, 'I013', ITEM_FIELD_GOLD_COST, 0)
        call SaveInteger(itemDb, 'I013', ITEM_FIELD_RECIPE_COUNT, 2)
        call SaveInteger(itemDb, 'I013', ITEM_FIELD_RECIPE_1, 'I006')
        call SaveInteger(itemDb, 'I013', ITEM_FIELD_RECIPE_2, 'I006')
        call SaveInteger(itemDb, 'I013', ITEM_FIELD_TAGS, ITEM_TAG_OFFENSIVE + ITEM_TAG_ACTIVE + ITEM_TAG_RECIPE_RESULT)

        // ==========================================================
        // ÍTEMS FALTANTES — TIENDA n000 (Tomos y Libros)
        // ==========================================================
        // Estos son consumibles instantáneos que se usan al comprarse.
        // No ocupan slot de inventario. Registrados para uso futuro.

        // --- Tomo de Experiencia 'texp' ---
        // 200 oro, consumible instantáneo. +100 XP al héroe.
        call SaveInteger(itemDb, 'texp', ITEM_FIELD_GOLD_COST, 200)
        call SaveInteger(itemDb, 'texp', ITEM_FIELD_SHOP_TYPE, 'n000')
        call SaveInteger(itemDb, 'texp', ITEM_FIELD_TAGS, ITEM_TAG_CONSUMABLE)

        // --- Tomo de Fuerza 'tstr' ---
        // 100 oro, consumible instantáneo. +1 STR permanente.
        call SaveInteger(itemDb, 'tstr', ITEM_FIELD_GOLD_COST, 100)
        call SaveInteger(itemDb, 'tstr', ITEM_FIELD_BONUS_STR, 1)
        call SaveInteger(itemDb, 'tstr', ITEM_FIELD_SHOP_TYPE, 'n000')
        call SaveInteger(itemDb, 'tstr', ITEM_FIELD_TAGS, ITEM_TAG_CONSUMABLE)

        // --- Tomo de Destreza 'tdex' ---
        // 100 oro, consumible instantáneo. +1 AGI permanente.
        call SaveInteger(itemDb, 'tdex', ITEM_FIELD_GOLD_COST, 100)
        call SaveInteger(itemDb, 'tdex', ITEM_FIELD_BONUS_AGI, 1)
        call SaveInteger(itemDb, 'tdex', ITEM_FIELD_SHOP_TYPE, 'n000')
        call SaveInteger(itemDb, 'tdex', ITEM_FIELD_TAGS, ITEM_TAG_CONSUMABLE)

        // --- Tomo de Inteligencia 'tint' ---
        // 100 oro, consumible instantáneo. +1 INT permanente.
        call SaveInteger(itemDb, 'tint', ITEM_FIELD_GOLD_COST, 100)
        call SaveInteger(itemDb, 'tint', ITEM_FIELD_BONUS_INT, 1)
        call SaveInteger(itemDb, 'tint', ITEM_FIELD_SHOP_TYPE, 'n000')
        call SaveInteger(itemDb, 'tint', ITEM_FIELD_TAGS, ITEM_TAG_CONSUMABLE)

        // --- Libro de reconversion 'tret' ---
        // Consumible instantáneo. Desaprende todas las habildiades del heroe.
        call SaveInteger(itemDb, 'tret', ITEM_FIELD_GOLD_COST, 300)
        call SaveInteger(itemDb, 'tret', ITEM_FIELD_SHOP_TYPE, 'n000')
        call SaveInteger(itemDb, 'tret', ITEM_FIELD_TAGS, ITEM_TAG_CONSUMABLE)

        // --- Tomo de nivel ---
        // sube un nivel al heroe que lo compra.
        call SaveInteger(itemDb, 'I01R', ITEM_FIELD_GOLD_COST, 1000)
        call SaveInteger(itemDb, 'I01R', ITEM_FIELD_SHOP_TYPE, 'n000')
        call SaveInteger(itemDb, 'I01R', ITEM_FIELD_TAGS, ITEM_TAG_CONSUMABLE)

        // --- Habilidad aleatoria (solo disponible en modo aleatorio de habilidades) ---
        // Otorga una habilidad aleatoria al heroe que lo compra
        call SaveInteger(itemDb, 'I001', ITEM_FIELD_LUMBER_COST, 1)
        call SaveInteger(itemDb, 'I001', ITEM_FIELD_SHOP_TYPE, 'n000')
        call SaveInteger(itemDb, 'I001', ITEM_FIELD_TAGS, ITEM_TAG_CONSUMABLE)

        // ==========================================================
        // REGISTRO DE TIENDA (SHOP_TYPE) Y RETRASO DE STOCK
        // ==========================================================
        // Mapeo: qué tienda vende cada ítem + cuándo está disponible.
        // Consumidor: IA_State_Shopping.

        // --- Tienda ngme (General: botas, auras, componentes PT) ---
        call SaveInteger(itemDb, 'bspd', ITEM_FIELD_SHOP_TYPE, 'ngme')
        call SaveReal(itemDb, 'bspd', ITEM_FIELD_INITIAL_STOCK_DELAY, 0.0)

        call SaveInteger(itemDb, 'brac', ITEM_FIELD_SHOP_TYPE, 'ngme')
        call SaveReal(itemDb, 'brac', ITEM_FIELD_INITIAL_STOCK_DELAY, 60.0)

        call SaveInteger(itemDb, 'ajen', ITEM_FIELD_SHOP_TYPE, 'ngme')
        call SaveReal(itemDb, 'ajen', ITEM_FIELD_INITIAL_STOCK_DELAY, 240.0)

        call SaveInteger(itemDb, 'afac', ITEM_FIELD_SHOP_TYPE, 'ngme')

        call SaveInteger(itemDb, 'sbch', ITEM_FIELD_SHOP_TYPE, 'ngme')

        call SaveInteger(itemDb, 'I01J', ITEM_FIELD_SHOP_TYPE, 'ngme')

        call SaveInteger(itemDb, 'lgdh', ITEM_FIELD_SHOP_TYPE, 'ngme')
        call SaveReal(itemDb, 'lgdh', ITEM_FIELD_INITIAL_STOCK_DELAY, 240.0)

        call SaveInteger(itemDb, 'evtl', ITEM_FIELD_SHOP_TYPE, 'ngme')

        call SaveInteger(itemDb, 'gcel', ITEM_FIELD_SHOP_TYPE, 'ngme')

        call SaveInteger(itemDb, 'ciri', ITEM_FIELD_SHOP_TYPE, 'ngme')

        call SaveInteger(itemDb, 'belv', ITEM_FIELD_SHOP_TYPE, 'ngme')

        // --- Tienda n00O (Armas/Armaduras Tier Alto: +100 daño, +20 armor) ---
        call SaveInteger(itemDb, 'I00U', ITEM_FIELD_SHOP_TYPE, 'n00O')
        call SaveReal(itemDb, 'I00U', ITEM_FIELD_INITIAL_STOCK_DELAY, 240.0)

        call SaveInteger(itemDb, 'I00M', ITEM_FIELD_SHOP_TYPE, 'n00O')
        call SaveReal(itemDb, 'I00M', ITEM_FIELD_INITIAL_STOCK_DELAY, 240.0)

        call SaveInteger(itemDb, 'I00Q', ITEM_FIELD_SHOP_TYPE, 'n00O')
        call SaveReal(itemDb, 'I00Q', ITEM_FIELD_INITIAL_STOCK_DELAY, 240.0)

        call SaveInteger(itemDb, 'I007', ITEM_FIELD_SHOP_TYPE, 'n00O')
        call SaveReal(itemDb, 'I007', ITEM_FIELD_INITIAL_STOCK_DELAY, 240.0)

        call SaveInteger(itemDb, 'I00B', ITEM_FIELD_SHOP_TYPE, 'n00O')
        call SaveReal(itemDb, 'I00B', ITEM_FIELD_INITIAL_STOCK_DELAY, 240.0)

        call SaveInteger(itemDb, 'I00F', ITEM_FIELD_SHOP_TYPE, 'n00O')
        call SaveReal(itemDb, 'I00F', ITEM_FIELD_INITIAL_STOCK_DELAY, 240.0)

        // --- Tienda n00M (Armas progresivas: +25/+50/+75 daño) ---
        call SaveInteger(itemDb, 'I008', ITEM_FIELD_SHOP_TYPE, 'n00M')
        call SaveReal(itemDb, 'I008', ITEM_FIELD_INITIAL_STOCK_DELAY, 30.0)

        call SaveInteger(itemDb, 'I009', ITEM_FIELD_SHOP_TYPE, 'n00M')
        call SaveReal(itemDb, 'I009', ITEM_FIELD_INITIAL_STOCK_DELAY, 90.0)

        call SaveInteger(itemDb, 'I00A', ITEM_FIELD_SHOP_TYPE, 'n00M')
        call SaveReal(itemDb, 'I00A', ITEM_FIELD_INITIAL_STOCK_DELAY, 270.0)

        call SaveInteger(itemDb, 'I00C', ITEM_FIELD_SHOP_TYPE, 'n00M')
        call SaveReal(itemDb, 'I00C', ITEM_FIELD_INITIAL_STOCK_DELAY, 30.0)

        call SaveInteger(itemDb, 'I00D', ITEM_FIELD_SHOP_TYPE, 'n00M')
        call SaveReal(itemDb, 'I00D', ITEM_FIELD_INITIAL_STOCK_DELAY, 90.0)

        call SaveInteger(itemDb, 'I00E', ITEM_FIELD_SHOP_TYPE, 'n00M')
        call SaveReal(itemDb, 'I00E', ITEM_FIELD_INITIAL_STOCK_DELAY, 270.0)

        call SaveInteger(itemDb, 'I00G', ITEM_FIELD_SHOP_TYPE, 'n00M')
        call SaveReal(itemDb, 'I00G', ITEM_FIELD_INITIAL_STOCK_DELAY, 30.0)

        call SaveInteger(itemDb, 'I00H', ITEM_FIELD_SHOP_TYPE, 'n00M')
        call SaveReal(itemDb, 'I00H', ITEM_FIELD_INITIAL_STOCK_DELAY, 90.0)

        call SaveInteger(itemDb, 'I00I', ITEM_FIELD_SHOP_TYPE, 'n00M')
        call SaveReal(itemDb, 'I00I', ITEM_FIELD_INITIAL_STOCK_DELAY, 270.0)

        // --- Tienda n00N (Armaduras progresivas: +5/+10/+15 armor) ---
        call SaveInteger(itemDb, 'I00R', ITEM_FIELD_SHOP_TYPE, 'n00N')
        call SaveReal(itemDb, 'I00R', ITEM_FIELD_INITIAL_STOCK_DELAY, 30.0)

        call SaveInteger(itemDb, 'I00S', ITEM_FIELD_SHOP_TYPE, 'n00N')
        call SaveReal(itemDb, 'I00S', ITEM_FIELD_INITIAL_STOCK_DELAY, 90.0)

        call SaveInteger(itemDb, 'I00K', ITEM_FIELD_SHOP_TYPE, 'n00N')
        call SaveReal(itemDb, 'I00K', ITEM_FIELD_INITIAL_STOCK_DELAY, 270.0)

        call SaveInteger(itemDb, 'I00N', ITEM_FIELD_SHOP_TYPE, 'n00N')
        call SaveReal(itemDb, 'I00N', ITEM_FIELD_INITIAL_STOCK_DELAY, 30.0)

        call SaveInteger(itemDb, 'I00O', ITEM_FIELD_SHOP_TYPE, 'n00N')
        call SaveReal(itemDb, 'I00O', ITEM_FIELD_INITIAL_STOCK_DELAY, 90.0)

        call SaveInteger(itemDb, 'I00P', ITEM_FIELD_SHOP_TYPE, 'n00N')
        call SaveReal(itemDb, 'I00P', ITEM_FIELD_INITIAL_STOCK_DELAY, 270.0)

        call SaveInteger(itemDb, 'I00J', ITEM_FIELD_SHOP_TYPE, 'n00N')
        call SaveReal(itemDb, 'I00J', ITEM_FIELD_INITIAL_STOCK_DELAY, 30.0)

        call SaveInteger(itemDb, 'I00L', ITEM_FIELD_SHOP_TYPE, 'n00N')
        call SaveReal(itemDb, 'I00L', ITEM_FIELD_INITIAL_STOCK_DELAY, 90.0)

        call SaveInteger(itemDb, 'I00T', ITEM_FIELD_SHOP_TYPE, 'n00N')
        call SaveReal(itemDb, 'I00T', ITEM_FIELD_INITIAL_STOCK_DELAY, 270.0)

        // --- Tienda nfh1 (Consumibles y utilidades) ---
        call SaveInteger(itemDb, 'I01G', ITEM_FIELD_SHOP_TYPE, 'nfh1')
        call SaveInteger(itemDb, 'ankh', ITEM_FIELD_SHOP_TYPE, 'nfh1')
        call SaveInteger(itemDb, 'dust', ITEM_FIELD_SHOP_TYPE, 'nfh1')
        call SaveInteger(itemDb, 'I002', ITEM_FIELD_SHOP_TYPE, 'nfh1')
        call SaveInteger(itemDb, 'shen', ITEM_FIELD_SHOP_TYPE, 'nfh1')
        call SaveInteger(itemDb, 'wneg', ITEM_FIELD_SHOP_TYPE, 'nfh1')
        call SaveInteger(itemDb, 'infs', ITEM_FIELD_SHOP_TYPE, 'nfh1')
        call SaveInteger(itemDb, 'fgsk', ITEM_FIELD_SHOP_TYPE, 'nfh1')
        call SaveInteger(itemDb, 'hlst', ITEM_FIELD_SHOP_TYPE, 'nfh1')
        call SaveInteger(itemDb, 'mnst', ITEM_FIELD_SHOP_TYPE, 'nfh1')

        // --- Tienda n001 (Orbes) ---
        call SaveInteger(itemDb, 'ofro', ITEM_FIELD_SHOP_TYPE, 'n001')
        call SaveInteger(itemDb, 'oli2', ITEM_FIELD_SHOP_TYPE, 'n001')
        call SaveInteger(itemDb, 'ofir', ITEM_FIELD_SHOP_TYPE, 'n001')
        call SaveInteger(itemDb, 'oslo', ITEM_FIELD_SHOP_TYPE, 'n001')
        call SaveInteger(itemDb, 'oven', ITEM_FIELD_SHOP_TYPE, 'n001')
        call SaveInteger(itemDb, 'odef', ITEM_FIELD_SHOP_TYPE, 'n001')

        // --- Tienda ngt2 (Central, única en el mapa) ---
        call SaveInteger(itemDb, 'I01Q', ITEM_FIELD_SHOP_TYPE, 'ngt2')
        call SaveInteger(itemDb, 'I004', ITEM_FIELD_SHOP_TYPE, 'ngt2')
        call SaveInteger(itemDb, 'bfhr', ITEM_FIELD_SHOP_TYPE, 'ngt2')
        call SaveInteger(itemDb, 'I006', ITEM_FIELD_SHOP_TYPE, 'ngt2')
        call SaveInteger(itemDb, 'arsh', ITEM_FIELD_SHOP_TYPE, 'ngt2')
        call SaveInteger(itemDb, 'I005', ITEM_FIELD_SHOP_TYPE, 'ngt2')
        call SaveInteger(itemDb, 'frgd', ITEM_FIELD_SHOP_TYPE, 'ngt2')
        call SaveInteger(itemDb, 'I003', ITEM_FIELD_SHOP_TYPE, 'ngt2')

    endfunction

endlibrary
