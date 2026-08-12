// ==========================================================================
// IA_Data_Buffs.j — Base de Datos de Modificadores de Attack Speed
// ==========================================================================
// PROPÓSITO ÚNICO: Registrar buffs, auras y habilidades que modifican
// la Velocidad de Ataque (AS). Consumidores exclusivos:
//   - EXTRAS/Comando_AS.j (desglose visual para el jugador)
//   - IA_Utils.j → GetAttackSpeedMod() (cálculo interno)
//
// Esquema SPARSE: Solo se guardan los campos que aplican a cada buff.
// Para habilidades con escalado por nivel: clave offset (FIELD_BASE + nivel).
//
// CÓMO AGREGAR UN NUEVO MODIFICADOR DE AS:
//   Buff simple:     call SaveReal(buffDb, 'Bxxx', BUFF_FIELD_AS_MOD, -0.25)
//                    call RegisterASBuff('Bxxx')
//   Aura propia:     call RegisterASAura('Axxx', 'Bxxx')
//                    + SaveReal niveles ABIL_AS_LVL_BASE + 1..10
//   Self-buff:       call RegisterASSelf('Axxx', 'Bxxx')
//                    + SaveReal niveles ABIL_AS_LVL_BASE + 1..10
//   Escalado (Cat4): call RegisterScaledEffect('Bxxx', 'Axxx', tipo, ABIL_AS_LVL_BASE, bando)
//                    + SaveReal niveles ABIL_AS_LVL_BASE + 1..10
// ==========================================================================

library IADataBuffs initializer OnInit

    globals
        private hashtable buffDb = null

        // ==============================
        // CAMPO DE BUFF (Esquema Sparse)
        // ==============================
        constant integer BUFF_FIELD_AS_MOD = 1   // real: % mod de Attack Speed (+0.10 o -0.25)

        // ==============================
        // CAMPOS DE HABILIDADES CON ESCALADO POR NIVEL
        // ==============================
        // Clave offset: BASE + nivel → key única por propiedad/nivel.
        // Ejemplo: LoadReal(buffDb, 'A01Y', ABIL_AS_LVL_BASE + 3) = AS del nivel 3.
        // Máximo estricto: 10 niveles por habilidad. Gap = 10 entre bloques.
        public constant integer ABIL_AS_LVL_BASE  = 100 // keys 101..110: Attack Speed por nivel
        public constant integer ABIL_AOE_LVL_BASE = 180 // keys 181..190: Área de efecto por nivel
        //                                                  (Usado por GetScaledEffectLevel para
        //                                                   calcular rango de auras con AS)

        // ==============================
        // TIPOS DE ENTREGA (Cat. 4 — Efectos Escalados)
        // ==============================
        public constant integer DEBUFF_TYPE_TARGET = 1 // Spell con target directo
        public constant integer DEBUFF_TYPE_AOE    = 2 // Spell AoE (punto o instantáneo)
        public constant integer DEBUFF_TYPE_AURA   = 3 // Aura pasiva (sin evento)

        // Bando del efecto:
        public constant integer EFFECT_SIDE_ENEMY  = 1 // Debuff: viene de enemigos
        public constant integer EFFECT_SIDE_ALLY   = 2 // Buff: viene de aliados
        public constant integer EFFECT_SIDE_ANY    = 3 // Híbrido: puede venir de cualquier bando

        // ==============================
        // REGISTRO DINÁMICO DE FUENTES DE AS
        // ==============================

        // Categoría 1: Buffs simples (if tiene buff → sumar AS_MOD)
        integer array asBuffRegistry
        integer       asBuffCount = 0

        // Categoría 2: Auras propias (if tiene habilidad → usar nivel;
        //               else if tiene buff aliado → sumar AS_MOD del buff)
        integer array asAuraAbilRegistry
        integer array asAuraBuffRegistry
        integer       asAuraCount = 0

        // Categoría 3: Self-buffs (if tiene habilidad + buff activo → usar nivel)
        integer array asSelfAbilRegistry
        integer array asSelfBuffRegistry
        integer       asSelfCount = 0

        // ==============================
        // REGISTRO DINÁMICO DE EFECTOS ESCALADOS (Cat. 4)
        // ==============================
        // Buffs y debuffs cuya penalización/bonificación de AS
        // escala por nivel. El trigger OnSpellEffect o el lector
        // de aura resuelven el nivel exacto.
        // 6 arrays paralelos:
        integer array sdBuffRegistry   // ID del buff/debuff que recibe la unidad
        integer array sdAbilRegistry   // ID de la habilidad que lo produce
        integer array sdTypeRegistry   // Tipo de entrega (TARGET/AOE/AURA)
        integer array sdFieldRegistry  // Qué offset afecta (ej. ABIL_AS_LVL_BASE)
        integer array sdSideRegistry   // Bando: ENEMY(1) o ALLY(2)
        integer       sdCount = 0
    endglobals

    // ==============================
    // API PÚBLICA DE CONSULTA
    // ==============================

    // Obtener modificador de Attack Speed de un buff. Retorna 0.0 si no tiene.
    public function GetBuffASMod takes integer buffId returns real
        return LoadReal(buffDb, buffId, BUFF_FIELD_AS_MOD)
    endfunction

    // Obtener AS de una habilidad propia por nivel (offset lookup).
    // Retorna 0.0 si ese nivel no está registrado.
    public function GetAbilityASByLevel takes integer abilId, integer lvl returns real
        return LoadReal(buffDb, abilId, ABIL_AS_LVL_BASE + lvl)
    endfunction

    // Obtener Área de efecto de una habilidad por nivel.
    // Consumidor: GetScaledEffectLevel (rango de auras con AS).
    public function GetAbilityAoEByLevel takes integer abilId, integer lvl returns real
        return LoadReal(buffDb, abilId, ABIL_AOE_LVL_BASE + lvl)
    endfunction

    // --- Funciones de registro dinámico (privadas) ---

    // Registra un buff simple que modifica AS.
    private function RegisterASBuff takes integer buffId returns nothing
        set asBuffRegistry[asBuffCount] = buffId
        set asBuffCount = asBuffCount + 1
    endfunction

    // Registra una aura propia: habilidad con nivel + buff aliado asociado.
    private function RegisterASAura takes integer abilId, integer buffId returns nothing
        set asAuraAbilRegistry[asAuraCount] = abilId
        set asAuraBuffRegistry[asAuraCount] = buffId
        set asAuraCount = asAuraCount + 1
    endfunction

    // Registra un self-buff: habilidad + buff de activación.
    private function RegisterASSelf takes integer abilId, integer buffId returns nothing
        set asSelfAbilRegistry[asSelfCount] = abilId
        set asSelfBuffRegistry[asSelfCount] = buffId
        set asSelfCount = asSelfCount + 1
    endfunction

    // Registra un efecto escalado (Cat. 4).
    // buffId: buff que la unidad recibe. abilId: habilidad que lo produce.
    // deliveryType: TARGET/AOE/AURA. field: offset. side: ENEMY/ALLY.
    private function RegisterScaledEffect takes integer buffId, integer abilId, integer deliveryType, integer field, integer side returns nothing
        set sdBuffRegistry[sdCount] = buffId
        set sdAbilRegistry[sdCount] = abilId
        set sdTypeRegistry[sdCount] = deliveryType
        set sdFieldRegistry[sdCount] = field
        set sdSideRegistry[sdCount] = side
        set sdCount = sdCount + 1
    endfunction

    // Helper: Guarda un valor fijo en todos los niveles de una habilidad.
    private function SaveFixedByLevel takes integer abilId, integer fieldBase, real value, integer maxLvl returns nothing
        local integer i = 1
        loop
            exitwhen i > maxLvl
            call SaveReal(buffDb, abilId, fieldBase + i, value)
            set i = i + 1
        endloop
    endfunction

    // --- API pública de consulta para loops dinámicos ---

    public function GetASBuffCount takes nothing returns integer
        return asBuffCount
    endfunction
    public function GetASBuffId takes integer index returns integer
        return asBuffRegistry[index]
    endfunction

    public function GetASAuraCount takes nothing returns integer
        return asAuraCount
    endfunction
    public function GetASAuraAbilId takes integer index returns integer
        return asAuraAbilRegistry[index]
    endfunction
    public function GetASAuraBuffId takes integer index returns integer
        return asAuraBuffRegistry[index]
    endfunction

    public function GetASSelfCount takes nothing returns integer
        return asSelfCount
    endfunction
    public function GetASSelfAbilId takes integer index returns integer
        return asSelfAbilRegistry[index]
    endfunction
    public function GetASSelfBuffId takes integer index returns integer
        return asSelfBuffRegistry[index]
    endfunction

    // --- API Scaled Effects (Cat. 4) ---
    public function GetSDCount takes nothing returns integer
        return sdCount
    endfunction
    public function GetSDBuffId takes integer index returns integer
        return sdBuffRegistry[index]
    endfunction
    public function GetSDAbilId takes integer index returns integer
        return sdAbilRegistry[index]
    endfunction
    public function GetSDType takes integer index returns integer
        return sdTypeRegistry[index]
    endfunction
    public function GetSDField takes integer index returns integer
        return sdFieldRegistry[index]
    endfunction
    public function GetSDSide takes integer index returns integer
        return sdSideRegistry[index]
    endfunction

    // ==============================
    // REGISTRO DE DATOS (OnInit)
    // ==============================
    private function OnInit takes nothing returns nothing
        set buffDb = InitHashtable()

        // ==========================================================
        //  SECCIÓN 1: BUFFS SIMPLES CON MODIFICADOR DE AS
        //  Cada uno registra solo BUFF_FIELD_AS_MOD + RegisterASBuff.
        // ==========================================================

        // 'Bfro' - Esfera de Hielo 'ofro' (-25% AS)
        call SaveReal(buffDb, 'Bfro', BUFF_FIELD_AS_MOD, -0.25)
        call RegisterASBuff('Bfro')

        // 'Bslo' - Esfera de Ralentización 'oslo' (-25% AS, se activa por RNG)
        call SaveReal(buffDb, 'Bslo', BUFF_FIELD_AS_MOD, -0.25)
        call RegisterASBuff('Bslo')

        // 'Bprg' - Purge / Esfera de Rayo 'oli2' (-25% AS en fase Slow)
        call SaveReal(buffDb, 'Bprg', BUFF_FIELD_AS_MOD, -0.25)
        call RegisterASBuff('Bprg')

        // 'BOae' - Ancestro Janggo (Aura del ítem, +18% AS)
        call SaveReal(buffDb, 'BOae', BUFF_FIELD_AS_MOD, 0.18)
        call RegisterASBuff('BOae')

        // 'BOhx' - Hex Ítem 'I01G' (-100% AS = desarme total)
        call SaveReal(buffDb, 'BOhx', BUFF_FIELD_AS_MOD, -1.00)
        call RegisterASBuff('BOhx')

        // 'B00T' - Guardahielo 'frgd' (-25% AS, mismos valores que Bfro)
        call SaveReal(buffDb, 'B00T', BUFF_FIELD_AS_MOD, -0.25)
        call RegisterASBuff('B00T')

        // 'B010' - Nova de Hielo 'AUfn' (Lich) — Target + AoE cercano (-25% AS)
        // Reducción fija en los 10 niveles. Detección: buff 'B010' en la víctima.
        call SaveReal(buffDb, 'B010', BUFF_FIELD_AS_MOD, -0.25)
        call RegisterASBuff('B010')

        // 'B011' - Aplauso de Mirmidón 'A04L' (Naga Royal 'H00V') — AoE No-Target (-100% AS)
        // Golpe al suelo: reduce AS a enemigos cercanos. 6 niveles, reducción fija.
        // Similar a Trueno pero sin escalado de AS → buff simple basta.
        // (El AoE sí escala 600→900, pero como el AS no cambia, no necesitamos
        //  Interceptor ni ABIL_AOE_LVL_BASE: solo chequeamos presencia de buff.)
        call SaveReal(buffDb, 'B011', BUFF_FIELD_AS_MOD, -1.50)
        call RegisterASBuff('B011')

        // ==========================================================
        //  SECCIÓN 2: HABILIDADES CON AS ESCALADO POR NIVEL
        // ==========================================================

        // --- Ralentización 'A03S' / Buff 'B00V' (Sniper 'H00R') ---
        // Conjuro target directo. Reduce AS del enemigo por nivel.
        // El buff 'B00V' aparece en la víctima.
        call RegisterScaledEffect('B00V', 'A03S', DEBUFF_TYPE_TARGET, ABIL_AS_LVL_BASE, EFFECT_SIDE_ENEMY)
        // Factor AS por nivel (reducción: -10% → -90%)
        call SaveReal(buffDb, 'A03S', ABIL_AS_LVL_BASE + 1, -0.10)
        call SaveReal(buffDb, 'A03S', ABIL_AS_LVL_BASE + 2, -0.20)
        call SaveReal(buffDb, 'A03S', ABIL_AS_LVL_BASE + 3, -0.30)
        call SaveReal(buffDb, 'A03S', ABIL_AS_LVL_BASE + 4, -0.40)
        call SaveReal(buffDb, 'A03S', ABIL_AS_LVL_BASE + 5, -0.50)
        call SaveReal(buffDb, 'A03S', ABIL_AS_LVL_BASE + 6, -0.60)
        call SaveReal(buffDb, 'A03S', ABIL_AS_LVL_BASE + 7, -0.70)
        call SaveReal(buffDb, 'A03S', ABIL_AS_LVL_BASE + 8, -0.80)
        call SaveReal(buffDb, 'A03S', ABIL_AS_LVL_BASE + 9, -0.90)
        call SaveReal(buffDb, 'A03S', ABIL_AS_LVL_BASE + 10, -1.00)

        // --- Bendición Divina 'A01Y' / Buff 'B006' (Lord Garithos 'Hlgr') ---
        // Aura pasiva aliada. Mejora AS de héroes y creeps aliados.
        // ARQUITECTURA ANTI-DOBLE CONTEO:
        //   Cat. 2 (RegisterASAura): el DUEÑO lee su AS directamente por nivel.
        //   Cat. 4 (RegisterScaledEffect): los ALIADOS leen AS via GetScaledEffectLevel.
        //   GetScaledEffectLevel tiene guard anti-owner que retorna 0
        //   si la víctima es el emisor (tiene A01Y), evitando doble conteo.
        call RegisterScaledEffect('B006', 'A01Y', DEBUFF_TYPE_AURA, ABIL_AS_LVL_BASE, EFFECT_SIDE_ALLY)
        call RegisterASAura('A01Y', 'B006')
        // Bonus de AS por nivel (+10% → +60%)
        call SaveReal(buffDb, 'A01Y', ABIL_AS_LVL_BASE + 1, 0.10)
        call SaveReal(buffDb, 'A01Y', ABIL_AS_LVL_BASE + 2, 0.17)
        call SaveReal(buffDb, 'A01Y', ABIL_AS_LVL_BASE + 3, 0.24)
        call SaveReal(buffDb, 'A01Y', ABIL_AS_LVL_BASE + 4, 0.31)
        call SaveReal(buffDb, 'A01Y', ABIL_AS_LVL_BASE + 5, 0.38)
        call SaveReal(buffDb, 'A01Y', ABIL_AS_LVL_BASE + 6, 0.45)
        call SaveReal(buffDb, 'A01Y', ABIL_AS_LVL_BASE + 7, 0.52)
        call SaveReal(buffDb, 'A01Y', ABIL_AS_LVL_BASE + 8, 0.59)
        call SaveReal(buffDb, 'A01Y', ABIL_AS_LVL_BASE + 9, 0.66)
        call SaveReal(buffDb, 'A01Y', ABIL_AS_LVL_BASE + 10, 0.73)
        // Área de efecto fija: 900 en los 10 niveles
        // (Necesario para GetScaledEffectLevel: cálculo de rango de aura)
        call SaveFixedByLevel('A01Y', ABIL_AOE_LVL_BASE, 900.0, 10)

        // --- Aura de Resistencia 'AOae' / Buff 'BOae' (Jefe Tauren 'Otch') ---
        // Aura pasiva aliada. Incrementa AS del dueño y unidades cercanas.
        // Misma arquitectura anti-doble conteo que Bendición Divina:
        //   Cat. 2 (RegisterASAura): el DUEÑO lee su AS directamente por nivel.
        //   Cat. 4 (RegisterScaledEffect): los ALIADOS leen AS via GetScaledEffectLevel.
        call RegisterScaledEffect('BOae', 'AOae', DEBUFF_TYPE_AURA, ABIL_AS_LVL_BASE, EFFECT_SIDE_ALLY)
        call RegisterASAura('AOae', 'BOae')
        // Bonus de AS por nivel (+6% → +60%)
        call SaveReal(buffDb, 'AOae', ABIL_AS_LVL_BASE + 1, 0.06)
        call SaveReal(buffDb, 'AOae', ABIL_AS_LVL_BASE + 2, 0.12)
        call SaveReal(buffDb, 'AOae', ABIL_AS_LVL_BASE + 3, 0.18)
        call SaveReal(buffDb, 'AOae', ABIL_AS_LVL_BASE + 4, 0.24)
        call SaveReal(buffDb, 'AOae', ABIL_AS_LVL_BASE + 5, 0.30)
        call SaveReal(buffDb, 'AOae', ABIL_AS_LVL_BASE + 6, 0.36)
        call SaveReal(buffDb, 'AOae', ABIL_AS_LVL_BASE + 7, 0.42)
        call SaveReal(buffDb, 'AOae', ABIL_AS_LVL_BASE + 8, 0.48)
        call SaveReal(buffDb, 'AOae', ABIL_AS_LVL_BASE + 9, 0.54)
        call SaveReal(buffDb, 'AOae', ABIL_AS_LVL_BASE + 10, 0.60)
        // Área de efecto fija: 900 en los 10 niveles
        call SaveFixedByLevel('AOae', ABIL_AOE_LVL_BASE, 900.0, 10)

        // --- Trueno 'AHtc' / Buff 'BHtc' (Rey de la Montaña 'Hmkg') ---
        // AoE Instantáneo No-Target (10 niveles). Reduce AS a enemigos.
        // El Interceptor (MECH B) usa el salvavidas cx=GetUnitX(caster)
        // porque GetSpellTargetX/Y devuelven 0 en hechizos No-Target.
        call RegisterScaledEffect('BHtc', 'AHtc', DEBUFF_TYPE_AOE, ABIL_AS_LVL_BASE, EFFECT_SIDE_ENEMY)
        // Reducción AS por nivel (NEGATIVA): -15% → -60%
        call SaveReal(buffDb, 'AHtc', ABIL_AS_LVL_BASE + 1, -0.60)
        call SaveReal(buffDb, 'AHtc', ABIL_AS_LVL_BASE + 2, -0.70)
        call SaveReal(buffDb, 'AHtc', ABIL_AS_LVL_BASE + 3, -0.80)
        call SaveReal(buffDb, 'AHtc', ABIL_AS_LVL_BASE + 4, -0.90)
        call SaveReal(buffDb, 'AHtc', ABIL_AS_LVL_BASE + 5, -1.00)
        call SaveReal(buffDb, 'AHtc', ABIL_AS_LVL_BASE + 6, -1.10)
        call SaveReal(buffDb, 'AHtc', ABIL_AS_LVL_BASE + 7, -1.20)
        call SaveReal(buffDb, 'AHtc', ABIL_AS_LVL_BASE + 8, -1.30)
        call SaveReal(buffDb, 'AHtc', ABIL_AS_LVL_BASE + 9, -1.40)
        call SaveReal(buffDb, 'AHtc', ABIL_AS_LVL_BASE + 10, -1.50)
        // SOLUCIÓN: El Interceptor necesita el Área de Efecto para saber a quiénes aplicarle el nivel en la memoria.
        call SaveReal(buffDb, 'AHtc', ABIL_AOE_LVL_BASE + 1, 250.0) 
        call SaveReal(buffDb, 'AHtc', ABIL_AOE_LVL_BASE + 2, 300.0)
        call SaveReal(buffDb, 'AHtc', ABIL_AOE_LVL_BASE + 3, 350.0)
        call SaveReal(buffDb, 'AHtc', ABIL_AOE_LVL_BASE + 4, 400.0)
        call SaveReal(buffDb, 'AHtc', ABIL_AOE_LVL_BASE + 5, 450.0)
        call SaveReal(buffDb, 'AHtc', ABIL_AOE_LVL_BASE + 6, 500.0)
        call SaveReal(buffDb, 'AHtc', ABIL_AOE_LVL_BASE + 7, 550.0)
        call SaveReal(buffDb, 'AHtc', ABIL_AOE_LVL_BASE + 8, 600.0)
        call SaveReal(buffDb, 'AHtc', ABIL_AOE_LVL_BASE + 9, 650.0)
        call SaveReal(buffDb, 'AHtc', ABIL_AOE_LVL_BASE + 10, 700.0)

        // --- Flechas de Hielo 'ANfa' / Buff 'Bcsd' (Sylvanas 'Hvwd', Bruja de Mar Naga 'Nngs') ---
        // Auto-cast con target directo. Reduce AS del enemigo por nivel.
        // El buff 'Bcsd' aparece en la víctima mientras dura el efecto.
        call RegisterScaledEffect('Bcsd', 'ANfa', DEBUFF_TYPE_TARGET, ABIL_AS_LVL_BASE, EFFECT_SIDE_ENEMY)
        // Factor AS por nivel (reducción: -25% → -70%)
        call SaveReal(buffDb, 'ANfa', ABIL_AS_LVL_BASE + 1, -0.30)
        call SaveReal(buffDb, 'ANfa', ABIL_AS_LVL_BASE + 2, -0.40)
        call SaveReal(buffDb, 'ANfa', ABIL_AS_LVL_BASE + 3, -0.50)
        call SaveReal(buffDb, 'ANfa', ABIL_AS_LVL_BASE + 4, -0.60)
        call SaveReal(buffDb, 'ANfa', ABIL_AS_LVL_BASE + 5, -0.70)
        call SaveReal(buffDb, 'ANfa', ABIL_AS_LVL_BASE + 6, -0.80)
        call SaveReal(buffDb, 'ANfa', ABIL_AS_LVL_BASE + 7, -0.90)
        call SaveReal(buffDb, 'ANfa', ABIL_AS_LVL_BASE + 8, -1.00)
        call SaveReal(buffDb, 'ANfa', ABIL_AS_LVL_BASE + 9, -1.10)
        call SaveReal(buffDb, 'ANfa', ABIL_AS_LVL_BASE + 10, -1.20)

        // --- Speed Bonus 'A05P' / Buff 'B00U' (Magnadefender 'O00B') ---
        // Aura pasiva personal. Incrementa AS solo del propio héroe.
        // Sin RegisterScaledEffect ni AOE: no afecta a aliados.
        call RegisterASAura('A05P', 'B00U')
        // Bonus de AS por nivel (+10% → +100%)
        call SaveReal(buffDb, 'A05P', ABIL_AS_LVL_BASE + 1, 0.10)
        call SaveReal(buffDb, 'A05P', ABIL_AS_LVL_BASE + 2, 0.20)
        call SaveReal(buffDb, 'A05P', ABIL_AS_LVL_BASE + 3, 0.30)
        call SaveReal(buffDb, 'A05P', ABIL_AS_LVL_BASE + 4, 0.40)
        call SaveReal(buffDb, 'A05P', ABIL_AS_LVL_BASE + 5, 0.50)
        call SaveReal(buffDb, 'A05P', ABIL_AS_LVL_BASE + 6, 0.60)
        call SaveReal(buffDb, 'A05P', ABIL_AS_LVL_BASE + 7, 0.70)
        call SaveReal(buffDb, 'A05P', ABIL_AS_LVL_BASE + 8, 0.80)
        call SaveReal(buffDb, 'A05P', ABIL_AS_LVL_BASE + 9, 0.90)
        call SaveReal(buffDb, 'A05P', ABIL_AS_LVL_BASE + 10, 1.00)

        // CÓMO AGREGAR UN NUEVO MODIFICADOR DE AS:
        //   Buff simple:     call SaveReal(buffDb, 'Bxxx', BUFF_FIELD_AS_MOD, -0.25)
        //                    call RegisterASBuff('Bxxx')
        //   Aura propia:     call RegisterASAura('Axxx', 'Bxxx')
        //                    + SaveReal niveles ABIL_AS_LVL_BASE + 1..10
        //                    + [!] OBLIGATORIO: ABIL_AOE_LVL_BASE para calcular rango.
        //   Self-buff:       call RegisterASSelf('Axxx', 'Bxxx')
        //                    + SaveReal niveles ABIL_AS_LVL_BASE + 1..10
        //   Escalado (Cat4): call RegisterScaledEffect('Bxxx', 'Axxx', tipo, ABIL_AS_LVL_BASE, bando)
        //                    + SaveReal niveles ABIL_AS_LVL_BASE + 1..10
        //                    + [!] OBLIGATORIO: Si el tipo es DEBUFF_TYPE_AOE (Instantáneo No-Target), 
        //                      DEBES registrar ABIL_AOE_LVL_BASE. El Interceptor lo necesita para 
        //                      saber a quiénes aplicar el nivel en la memoria.
    endfunction

endlibrary
