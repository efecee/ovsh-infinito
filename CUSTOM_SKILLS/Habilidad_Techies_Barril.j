//===========================================================================
// SISTEMA: BARRIL EXPLOSIVO (GOBLIN TECHIES) - v2.0 (Sistema de Golpes)
// IDs: Habilidad A042 | Unidad h00T | Stun A04Z
//===========================================================================
// CONFIGURACIÓN REQUERIDA EN EL EDITOR DE OBJETOS (UNIDAD h00T):
//   - Puntos de Impacto (HP):             900
//   - Índice de Regen de Impacto:        -290
//   - Defensa Base:                       1000
//
//   Con estos valores el barril se auto-destruye por regen en ~3.10s.
//   El timer de explosión se ejecuta a los 3.0s (justo antes de morir).
//   ¿POR QUÉ -290 y no -300?  Porque HP/|regen| debe ser LIGERAMENTE
//   MAYOR que el delay del timer, para evitar una race condition donde
//   el barril muere en el mismo instante que el timer.
//   Si cambias el delay, recalcula:  HP / |regen| > delay
//   Ejemplo actual:  900 / 290 = 3.10  >  3.0  ✅
//===========================================================================

// ==========================================
// ===        IDs DE REFERENCIA           ===
// ==========================================

function Techies_GetBarrelAbilityId takes nothing returns integer
    return 'A042' // Habilidad del Héroe (Barril Explosivo)
endfunction

function Techies_GetBarrelUnitId takes nothing returns integer
    return 'h00T' // Unidad Barril (la que aparece en el suelo)
endfunction

function Techies_GetStunAbilityId takes nothing returns integer
    return 'A04Z' // Habilidad Dummy para Stun (War Stomp) - ¡MANÁ debe ser 0!
endfunction

// --- DURACIÓN DEL STUN ---
// El tiempo de aturdimiento NO se configura aquí en el código.
// Se configura en el EDITOR DE OBJETOS, en la habilidad A04Z (War Stomp).
// Cada NIVEL de A04Z define su propia duración de stun.
// El código sincroniza automáticamente el nivel del barril con el de A04Z:
//   SetUnitAbilityLevel(dummy, A04Z, level)
// Así que si el barril es nivel 9, el stun será el del nivel 9 de A04Z.

// ==========================================
// ===    CONFIGURACIÓN PERSONALIZABLE    ===
// === (Modifica estos valores a tu gusto) ==
// ==========================================

// --- TIEMPO ANTES DE EXPLOTAR (segundos) ---
// Cuánto tarda el barril en explotar automáticamente tras ser lanzado.
// IMPORTANTE: Si cambias este valor, ajusta HP y regen en el Editor de Objetos.
// Fórmula: HP / |regen| debe ser LIGERAMENTE MAYOR que este valor.
function Techies_GetExplosionDelay takes nothing returns real
    return 3.0
endfunction

// --- DAÑO POR NIVEL (control manual, 10 niveles) ---
// Modifica cada valor A TU GUSTO para cada nivel. Sin fórmula, tú decides.
function Techies_GetDamage takes integer level returns real
    if (level == 1) then
        return 100.00
    elseif (level == 2) then
        return 120.0
    elseif (level == 3) then
        return 140.0
    elseif (level == 4) then
        return 160.0
    elseif (level == 5) then
        return 180.0
    elseif (level == 6) then
        return 200.0
    elseif (level == 7) then
        return 220.0
    elseif (level == 8) then
        return 240.0
    elseif (level == 9) then
        return 260.0
    elseif (level == 10) then
        return 280.0
    endif
    return 130.0
endfunction

// --- GOLPES PARA DESTRUIR POR NIVEL (control manual, 10 niveles) ---
// Cuántos golpes necesita recibir el barril para ser destruido
// ANTES de que explote. No importa el daño del golpe, solo la cantidad.
// Modifica cada valor A TU GUSTO para cada nivel.
function Techies_GetHitsToDestroy takes integer level returns integer
    if (level == 1) then
        return 1
    elseif (level == 2) then
        return 2
    elseif (level == 3) then
        return 3
    elseif (level == 4) then
        return 4
    elseif (level == 5) then
        return 5
    elseif (level == 6) then
        return 6
    elseif (level == 7) then
        return 7
    elseif (level == 8) then
        return 8
    elseif (level == 9) then
        return 9
    elseif (level == 10) then
        return 10
    endif
    return 1
endfunction

// --- RADIO DE EXPLOSIÓN (AoE de daño y stun) ---
function Techies_GetExplosionRadius takes nothing returns real
    return 300.0
endfunction

// --- RADIO INTERNO (por encima de este rango, daño reducido) ---
function Techies_GetInnerRadius takes nothing returns real
    return 230.0
endfunction

// --- MULTIPLICADOR DE DAÑO REDUCIDO (fuera del radio interno) ---
function Techies_GetOuterDamageRatio takes nothing returns real
    return 0.70 // 70% del daño base
endfunction

// --- MULTIPLICADOR DE DAÑO A EDIFICIOS ---
function Techies_GetBuildingDamageRatio takes nothing returns real
    return 1.50 // 150% del daño base (50% extra)
endfunction


// ==========================================
// ===      DETECTOR DE GOLPES            ===
// ==========================================
// Se ejecuta cada vez que el barril recibe daño de CUALQUIER fuente.
// Cualquier golpe cuenta (aliado o enemigo). Solo importa la cantidad.
// Muestra un texto flotante "(golpes/máximo)" visible para TODOS los jugadores.
// Si hay un texto anterior, se destruye para evitar superposición.
function Trig_Techies_OnBarrelHit takes nothing returns nothing
    local unit barrel = GetTriggerUnit()
    local integer bId = GetHandleId(barrel)
    local integer hits = LoadInteger(udg_MB_Hash, bId, 10) + 1
    local integer maxHits = LoadInteger(udg_MB_Hash, bId, 11)
    local texttag ttOld
    local texttag tt

    // --- Destruir el texto flotante ANTERIOR (evita superposición) ---
    set ttOld = LoadTextTagHandle(udg_MB_Hash, bId, 12)
    if (ttOld != null) then
        call DestroyTextTag(ttOld)
    endif

    // --- Crear NUEVO texto flotante: "(golpes/máximo)" ---
    set tt = CreateTextTag()
    call SetTextTagText(tt, "(" + I2S(hits) + "/" + I2S(maxHits) + ")", 0.024)
    call SetTextTagPos(tt, GetUnitX(barrel), GetUnitY(barrel), 80.0)
    call SetTextTagColor(tt, 255, 220, 50, 255)  // Amarillo-dorado
    call SetTextTagVelocity(tt, 0, 0.0355)        // Flota hacia arriba
    call SetTextTagLifespan(tt, 1.5)               // Dura 1.5 segundos
    call SetTextTagFadepoint(tt, 0.8)              // Empieza a desvanecerse a los 0.8s
    call SetTextTagPermanent(tt, false)             // Se auto-destruye al expirar
    call SetTextTagVisibility(tt, true)
    call SaveTextTagHandle(udg_MB_Hash, bId, 12, tt) // Guardar referencia para el próximo golpe

    if (hits >= maxHits) then
        // ¡Suficientes golpes! Destruir el barril SIN explosión.
        // RemoveUnit cancela todo: no hay daño, no hay stun, no hay animación.
        call RemoveUnit(barrel)
    else
        // Aún no alcanza el máximo, guardar contador actualizado
        call SaveInteger(udg_MB_Hash, bId, 10, hits)
    endif

    set barrel = null
    set ttOld = null
    set tt = null
endfunction


// ==========================================
// ===       LÓGICA DE EXPLOSIÓN          ===
// ==========================================
// Se ejecuta cuando el timer expira (tras Techies_GetExplosionDelay segundos).
// Si el barril sigue vivo → EXPLOTA (daño + stun).
// Si fue destruido por golpes → no hace nada.
function Trig_Techies_Explode takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer tId = GetHandleId(t)

    // Recuperamos los datos guardados
    local unit barrel = LoadUnitHandle(udg_MB_Hash, tId, 0)
    local unit caster = LoadUnitHandle(udg_MB_Hash, tId, 1)
    local integer level = LoadInteger(udg_MB_Hash, tId, 2)
    local trigger tDef = LoadTriggerHandle(udg_MB_Hash, tId, 3)
    // FIX: Leer bId guardado en el contexto del timer (key 4), NO de GetHandleId(barrel).
    // Si el barril fue destruido por golpes (RemoveUnit), barrel es null y
    // GetHandleId(null) = 0 en WC3 1.27b. Parent key 0 en udg_MB_Hash pertenece
    // a Player(0), así que FlushChildHashtable(udg_MB_Hash, 0) borraba TODOS sus
    // stats (kills, deaths, assists, fila del multiboard).
    local integer bId = LoadInteger(udg_MB_Hash, tId, 4)

    // Variables locales
    local group g
    local unit target
    local real damageBase
    local real finalDamage
    local real dist
    local unit dummy
    local real bx
    local real by

    // ¿El barril sigue vivo? (Si fue destruido por golpes, HP será ≤ 0.405)
    if (GetUnitState(barrel, UNIT_STATE_LIFE) > 0.405) then

        set damageBase = Techies_GetDamage(level)
        set bx = GetUnitX(barrel)
        set by = GetUnitY(barrel)

        // 1. STUN (Dummy invisible con War Stomp)
        set dummy = CreateUnit(GetOwningPlayer(caster), 'uloc', bx, by, 0)
        call UnitAddAbility(dummy, Techies_GetStunAbilityId())
        call SetUnitAbilityLevel(dummy, Techies_GetStunAbilityId(), level)
        call IssueImmediateOrder(dummy, "stomp")
        call UnitApplyTimedLife(dummy, 'BTLF', 1.0)

        // 2. DAÑO EN ÁREA
        set g = CreateGroup()
        call GroupEnumUnitsInRange(g, bx, by, Techies_GetExplosionRadius(), null)

        loop
            set target = FirstOfGroup(g)
            exitwhen target == null
            call GroupRemoveUnit(g, target)

            if (IsUnitEnemy(target, GetOwningPlayer(caster)) and IsUnitAliveBJ(target)) then
                set finalDamage = damageBase

                // Registrar asistencia (vía Control, key 600+i).
                // El stun lo aplica un dummy (invisible al sistema). El daño directo
                // es bajo y no siempre supera el umbral del 5%. Registramos manualmente
                // para que la explosión+stun siempre cuente como asistencia.
                // (Lógica inlineada de MB_RegisterControlTimestamp — evita error de orden de compilación)
                if (IsUnitType(target, UNIT_TYPE_HERO)) then
                    call SaveReal(udg_MB_Hash, GetPlayerId(GetOwningPlayer(target)), 600 + GetPlayerId(GetOwningPlayer(caster)), TimerGetElapsed(MB_Timer))
                endif

                // Regla A: Daño reducido si está fuera del radio interno
                set dist = SquareRoot(Pow(GetUnitX(target) - bx, 2) + Pow(GetUnitY(target) - by, 2))
                if (dist > Techies_GetInnerRadius()) then
                    set finalDamage = finalDamage * Techies_GetOuterDamageRatio()
                endif

                // Regla B: Daño extra a Edificios
                if (IsUnitType(target, UNIT_TYPE_STRUCTURE)) then
                    set finalDamage = finalDamage * Techies_GetBuildingDamageRatio()
                endif

                // Aplicar Daño Mágico
                call UnitDamageTarget(caster, target, finalDamage, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, WEAPON_TYPE_WHOKNOWS)
            endif
        endloop

        call DestroyGroup(g)

        // Desactivamos el Trigger de Golpes para que no interfiera
        call DisableTrigger(tDef)

        // Matar el barril tras la explosión para que no se quede con 1 HP
        // (la regen negativa no siempre lo mata; KillUnit lo garantiza)
        call KillUnit(barrel)

    else
        // SI LLEGAMOS AQUÍ: el barril fue destruido por golpes enemigos.
        // No hay explosión, no hay daño, no hay stun.
        call RemoveUnit(barrel) // Limpia cadáver residual si quedó alguno
    endif

    // --- LIMPIEZA COMPLETA (sin memory leaks) ---
    // FIX: Guard defensivo — nunca flushear parent keys 0-9 (datos de jugadores).
    // En condiciones normales bId es un handle ID alto (>100000), pero si por
    // algún motivo llegara a ser 0 (handle reciclado), este guard lo impide.
    if (bId > 9) then
        call FlushChildHashtable(udg_MB_Hash, bId)  // Datos del barril (contador de golpes)
    endif
    call DestroyTrigger(tDef)
    call FlushChildHashtable(udg_MB_Hash, tId)   // Datos del timer
    call DestroyTimer(t)
    set t = null
    set barrel = null
    set caster = null
    set g = null
    set target = null
    set dummy = null
    set tDef = null
endfunction


// ==========================================
// ===     ACCIÓN: LANZAMIENTO            ===
// ==========================================
function Trig_Techies_Cast_Actions takes nothing returns nothing
    local unit caster = GetTriggerUnit()
    local real x = GetSpellTargetX()
    local real y = GetSpellTargetY()
    local integer level = GetUnitAbilityLevel(caster, Techies_GetBarrelAbilityId())
    local unit barrel
    local timer t
    local trigger tDef
    local integer bId

    // 1. CREAR BARRIL en la posición objetivo
    set barrel = CreateUnit(GetOwningPlayer(caster), Techies_GetBarrelUnitId(), x, y, 0)

    // 2. CONFIGURAR SISTEMA DE GOLPES (datos asociados al barril)
    set bId = GetHandleId(barrel)
    call SaveInteger(udg_MB_Hash, bId, 10, 0)                              // Contador de golpes = 0
    call SaveInteger(udg_MB_Hash, bId, 11, Techies_GetHitsToDestroy(level)) // Golpes máximos según nivel

    // 3. CREAR TRIGGER DETECTOR DE GOLPES (EVENT_UNIT_DAMAGED)
    set tDef = CreateTrigger()
    call TriggerRegisterUnitEvent(tDef, barrel, EVENT_UNIT_DAMAGED)
    call TriggerAddAction(tDef, function Trig_Techies_OnBarrelHit)

    // 4. INICIAR RELOJ DE EXPLOSIÓN
    set t = CreateTimer()

    // 5. GUARDAR DATOS (asociados al timer, para la función de explosión)
    call SaveUnitHandle(udg_MB_Hash, GetHandleId(t), 0, barrel)
    call SaveUnitHandle(udg_MB_Hash, GetHandleId(t), 1, caster)
    call SaveInteger(udg_MB_Hash, GetHandleId(t), 2, level)
    call SaveTriggerHandle(udg_MB_Hash, GetHandleId(t), 3, tDef)
    call SaveInteger(udg_MB_Hash, GetHandleId(t), 4, bId) // FIX: Guardar bId del barril para limpieza segura en Explode

    // 6. ¡EJECUTAR! El barril explotará después del delay configurado
    call TimerStart(t, Techies_GetExplosionDelay(), false, function Trig_Techies_Explode)

    set caster = null
    set barrel = null
    set t = null
    set tDef = null
endfunction

//===========================================================================
function IsBarrelAbility takes nothing returns boolean
    return GetSpellAbilityId() == Techies_GetBarrelAbilityId()
endfunction

function InitTrig_Habilidad_Techies_Barril takes nothing returns nothing
    set gg_trg_Habilidad_Techies_Barril = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Habilidad_Techies_Barril, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddCondition(gg_trg_Habilidad_Techies_Barril, Condition(function IsBarrelAbility))
    call TriggerAddAction(gg_trg_Habilidad_Techies_Barril, function Trig_Techies_Cast_Actions)
endfunction