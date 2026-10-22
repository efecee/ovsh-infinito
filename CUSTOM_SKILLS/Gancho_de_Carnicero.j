//===========================================================================
// SISTEMA: GANCHO DE CARNICERO (MEAT HOOK) - v2.0
// IDs: Habilidad A03L | Cabeza n01Z | Pasiva Butcher Flesh A03N
//===========================================================================
//
// DESCRIPCIÓN:
//   El Butcher lanza un gancho en línea recta. El gancho tiene DOS partes
//   visuales:
//     1. CABEZA (n01Z): Una sola unidad dummy en la punta, con forma de
//        flecha/garfio. Aparece UNA SOLA VEZ. Es el "anzuelo".
//     2. CUERPO (Lightning): Un rayo azul tipo cadena que conecta al
//        héroe con la cabeza. Se actualiza en tiempo real.
//
//   El héroe NO se bloquea al lanzar el gancho. Puede moverse libremente.
//   La presa arrastrada siempre termina en la posición ACTUAL del héroe,
//   no en la posición donde lanzó el gancho. Esto permite la jugada
//   táctica de alejarse en dirección contraria para arrastrar más lejos.
//
//   La PRESA, en cambio, queda CORTADA: al engancharla se interrumpe lo que
//   esté haciendo (TP de Botas, canalizaciones, ataques) y durante todo el
//   arrastre no puede iniciar ni completar nada. Ver bloque INTERRUPCIÓN DE
//   LA PRESA, antes del callback del timer.
//
//   Durante la retracción, el cuerpo (lightning) deja un rastro fantasma
//   que se desvanece gradualmente (trail con alpha decreciente).
//
//===========================================================================
//
// ╔══════════════════════════════════════════════════════════════════════╗
// ║   GUÍA: ¿DÓNDE CAMBIAR CADA COSA?                                  ║
// ╠══════════════════════════════════════════════════════════════════════╣
// ║                                                                    ║
// ║  ► DISTANCIA MÁXIMA DEL GANCHO (por nivel):                        ║
// ║    → Aquí, función Hook_GetMaxDistance.                            ║
// ║    → NOTA: Puede (y debe) superar el alcance de casteo.            ║
// ║                                                                    ║
// ║  ► DAÑO DE IMPACTO AL ENGANCHAR (por nivel):                       ║
// ║    → Aquí, función Hook_GetImpactDamage.                           ║
// ║    → Se aplica UNA vez al momento del enganche, solo a enemigos.   ║
// ║                                                                    ║
// ║  ► VELOCIDAD DEL GANCHO (por nivel):                               ║
// ║    → Aquí, función Hook_GetChainSpeed.                             ║
// ║    → Unidades de mapa por tick (0.03s). 38 ≈ ~1267 uds/seg.        ║
// ║                                                                    ║
// ║  ► ALCANCE DE CASTEO (rango para poder lanzar el gancho):          ║
// ║    → En el EDITOR DE OBJETOS, habilidad A03L (Meat Hook).          ║
// ║    → Campo "Cast Range". Ponlo MENOR que la distancia máxima       ║
// ║      para que el gancho viaje más lejos que el rango de casteo.    ║
// ║                                                                    ║
// ║  ► COOLDOWN Y MANÁ:                                                ║
// ║    → En el EDITOR DE OBJETOS, habilidad A03L (Meat Hook).          ║
// ║                                                                    ║
// ║  ► MODELO VISUAL DE LA CABEZA:                                     ║
// ║    → En el EDITOR DE OBJETOS, unidad n01Z.                         ║
// ║    → Cambiar su modelo artístico (Art - Model File).               ║
// ║    → IMPORTANTE: Esta unidad solo aparece UNA vez en la punta.     ║
// ║                                                                    ║
// ║  ► COLOR/TIPO DEL CUERPO (rayo azul):                              ║
// ║    → Aquí, función Hook_GetLightningType.                          ║
// ║    → Tipos comunes: "CLPB" (azul brillante),                       ║
// ║      "LEAS" (spirit link), "FORK" (bifurcado).                     ║
// ║                                                                    ║
// ║  ► RADIO DE DETECCIÓN (qué tan cerca debe pasar para enganchar):   ║
// ║    → Aquí, función Hook_GetHitRadius.                              ║
// ║                                                                    ║
// ║  ► QUÉ UNIDADES IGNORA EL GANCHO (pasa de largo sin engancharlas): ║
// ║    → Aquí, función Hook_IsHookImmune.                              ║
// ║  ► CANCELAR EL TP (Y TODA CANALIZACIÓN) DE LA PRESA AL ENGANCHAR:  ║
// ║    → Aquí, bloque INTERRUPCIÓN DE LA PRESA (stop+SetUnitPosition). ║
// ║    → NO volver a SetUnitX/Y para la presa: deja terminar el TP.    ║
// ║                                                                    ║
// ║                                                                    ║
// ╚══════════════════════════════════════════════════════════════════════╝
//
//===========================================================================

// ==========================================
// ===        IDs DE REFERENCIA           ===
// ==========================================

// Habilidad del Héroe (Meat Hook).
// Se configura en el Editor de Objetos: cooldown, maná, alcance de casteo.
// El alcance de casteo DEBE ser MENOR que Hook_GetMaxDistance para que el
// gancho viaje más lejos de lo que el héroe puede apuntar.
function Hook_GetAbilityId takes nothing returns integer
    return 'A03L'
endfunction

// Unidad dummy que representa la CABEZA del gancho (el garfio/anzuelo).
// Solo aparece UNA VEZ en la punta. Su modelo visual se cambia en el
// Editor de Objetos (Art - Model File de la unidad n01Z).
function Hook_GetDummyUnitId takes nothing returns integer
    return 'n01Z'
endfunction


// ==========================================
// ===    CONFIGURACIÓN POR NIVEL         ===
// ===    (MODIFICA A TU ANTOJO)          ===
// ==========================================

// --- DISTANCIA MÁXIMA DEL GANCHO (por nivel, 10 niveles) ---
// Qué tan lejos viaja la cabeza del gancho antes de retraerse.
// DEBE ser mayor que el alcance de casteo de A03L en el editor.
function Hook_GetMaxDistance takes integer level returns real
    if (level == 1) then
        return 650.00 //650 original
    elseif (level == 2) then
        return 739.00
    elseif (level == 3) then
        return 828.00
    elseif (level == 4) then
        return 917.00
    elseif (level == 5) then
        return 1006.00
    elseif (level == 6) then
        return 1094.00
    elseif (level == 7) then
        return 1183.00
    elseif (level == 8) then
        return 1272.00
    elseif (level == 9) then
        return 1361.00
    elseif (level == 10) then
        return 1450.00 //1550 original
    endif
    return 1450.00
endfunction

// --- DAÑO DE IMPACTO AL ENGANCHAR (por nivel, 10 niveles) ---
// Se aplica UNA sola vez, en el instante del enganche. Solo a enemigos.
// Tipo de ataque: Caos. Tipo de daño: Desconocido.
function Hook_GetImpactDamage takes integer level returns real
    if (level == 1) then
        return 30.00
    elseif (level == 2) then
        return 60.00
    elseif (level == 3) then
        return 90.00
    elseif (level == 4) then
        return 120.00
    elseif (level == 5) then
        return 150.00
    elseif (level == 6) then
        return 180.00
    elseif (level == 7) then
        return 210.00
    elseif (level == 8) then
        return 240.00
    elseif (level == 9) then
        return 270.00
    elseif (level == 10) then
        return 300.00
    endif
    return 30.00
endfunction

// --- VELOCIDAD DEL GANCHO (por nivel, 10 niveles) ---
// Unidades de mapa que avanza la cabeza por tick (cada 0.03s).
// Valor 38 ≈ 1267 unidades/segundo. Más alto = más rápido.
// Aplica tanto para extensión como para retracción.
function Hook_GetChainSpeed takes integer level returns real
    if (level == 1) then
        return 40.00
    elseif (level == 2) then
        return 40.00
    elseif (level == 3) then
        return 40.00
    elseif (level == 4) then
        return 40.00
    elseif (level == 5) then
        return 40.00
    elseif (level == 6) then
        return 40.00
    elseif (level == 7) then
        return 40.00
    elseif (level == 8) then
        return 40.00
    elseif (level == 9) then
        return 40.00
    elseif (level == 10) then
        return 40.00
    endif
    return 40.00
endfunction

// ==========================================
// ===    CONSTANTES INTERNAS             ===
// ==========================================

// Período del timer (0.03s ≈ 33 FPS de la cadena).
function Hook_GetTick takes nothing returns real
    return 0.03
endfunction

// Distancia inicial del primer tick desde el caster.
function Hook_GetInitialDistance takes nothing returns real
    return 40.00
endfunction

// Radio de detección (unidades de mapa). Si una unidad está a esta
// distancia de la cabeza, se engancha. 130 es generoso para que
// unidades grandes (abominaciones, taurens) sean enganchadas cuando
// visualmente la cabeza está sobre ellas. Reduce si quieres más precisión.
function Hook_GetHitRadius takes nothing returns real
    return 90.00
endfunction

// Tipo de Lightning para el cuerpo del gancho.
// "LEAS" = Spirit Link (azul suave, línea fina y estable).
// Otros: "CLPB" (azul grueso, animado), "FORK" (bifurcado),
//        "DRAM" (drain mana, azul-morado), "SPLK" (spirit link alt).
function Hook_GetLightningType takes nothing returns string
    return "LEAS" //DRAM
endfunction

// Velocidad de desvanecimiento del rastro (trail) durante retracción.
// Cuánto alpha pierde por tick. 0.04 = se desvanece en ~0.75 segundos.
function Hook_GetTrailFadeRate takes nothing returns real
    return 0.04
endfunction

// Distancia mínima para considerar que la cabeza llegó al caster.
function Hook_GetSnapDistance takes nothing returns real
    return 45.00
endfunction


// ==========================================
// ===    VARIABLES DE INSTANCIA          ===
// ==========================================
// Reutiliza las globales udg_* del mapa donde es posible.
// Agrega nuevas globales para la cabeza, lightning y trail.

globals
    // --- Nuevas (sistema de lightning + cabeza única) ---
    unit      array Hook_HeadDummy     // Unidad n01Z en la punta (1 por instancia)
    lightning array Hook_ChainLfx      // Lightning principal: caster → cabeza
    lightning array Hook_TrailLfx      // Lightning trail fantasma (retracción)
    real      array Hook_HeadX         // Posición X actual de la cabeza
    real      array Hook_HeadY         // Posición Y actual de la cabeza
    real      array Hook_MaxReachX     // X donde la cabeza llegó al máximo (para trail)
    real      array Hook_MaxReachY     // Y donde la cabeza llegó al máximo (para trail)
    real      array Hook_TrailAlpha    // Alpha actual del trail (1.0 → 0.0)
    real      array Hook_LaunchAngleR  // Ángulo de lanzamiento en radianes (pre-calculado)
    timer            Hook_Timer = null // Timer único compartido por todas las instancias
endglobals

// ==========================================
// ===      FILTRO DE DETECCIÓN           ===
// ==========================================
// Excluye: estructuras, unidades aéreas, muertos, inmunes al gancho (ver
// Hook_IsHookImmune), el propio caster, y TODO lo que esté dentro de la zona
// de selección (maniquíes de display, Wisps, Almas Corruptas).
// udg_HookMUI[3] = índice de la instancia actual (set en el loop).

// Devuelve true si el punto (x,y) cae dentro del rect r.
function Hook_PointInRect takes real x, real y, rect r returns boolean
    return x >= GetRectMinX(r) and x <= GetRectMaxX(r) and /*
    */ y >= GetRectMinY(r) and y <= GetRectMaxY(r)
endfunction

// --- ¿La unidad está INVULNERABLE en este instante? ---
//
// Pregunta de ESTADO, no de identidad: no importa qué habilidad, ítem o sistema
// se la dio. Una unidad invulnerable no se engancha, punto.
//
// PROBLEMA DE 1.27b: no hay un native que responda esto. NO existe la constante
// UNIT_TYPE_INVULNERABLE, y BlzIsUnitInvulnerable es de 1.29+ (el autocompletado
// de VSCode lo ofrece porque su common.j es de Reforged: usarlo compila acá y
// revienta en el World Editor). Hay que leer los MARCADORES que deja el motor.
//
// El motor tiene DOS mecanismos distintos para volver invulnerable a una unidad,
// y cada uno deja un marcador distinto:
//
//   'Avul'  MARCADOR GENÉRICO. Es la ability de invulnerabilidad que el propio
//           motor engancha a cualquier unidad pasada por SetUnitInvulnerable.
//           Cubre TODA invulnerabilidad hecha por trigger, presente y futura,
//           sin que haya que tocar esta función (ej.: Zona_Seleccion.j,
//           Sistema_Sello_Fortificacion.j, o un ítem futuro).
//
//   'BHds'  PARCHE DEL AGUJERO. La familia Escudo Divino ('AHds', que cualquier
//           héroe puede recibir por el modo aleatorio de habilidades) NO pasa
//           por SetUnitInvulnerable: el motor la marca solo con su buff. Sin
//           esta línea, el Paladín escudado se engancharía igual.
//
// CÓMO EXTENDER: si mañana aparece otra fuente de invulnerabilidad, fijate cómo
// la aplica. Si usa SetUnitInvulnerable, ya está cubierta sola. Si es una
// habilidad tipo Escudo Divino con buff propio (una copia custom tiene rawcode
// de buff propio), agregá ese buff acá abajo, en una línea.
function Hook_IsInvulnerable takes unit u returns boolean
    return GetUnitAbilityLevel(u, 'Avul') > 0 or GetUnitAbilityLevel(u, 'BHds') > 0
endfunction

// --- ¿A quién NO puede enganchar el gancho? ---
//
// POR QUÉ ESTE CHEQUEO EXISTE: el gancho no es un hechizo dirigido. La presa
// se detecta por geometría (GroupEnumUnitsInRange alrededor de la cabeza) y se
// arrastra escribiendo su posición (SetUnitX/Y). El motor NUNCA aplica sus
// propias reglas de inmunidad sobre eso, porque no hay ningún efecto de
// habilidad apuntando a la víctima. Si no se filtra a mano, se engancha todo.
//
// Se ignora (la cabeza le pasa de largo y sigue buscando otra presa):
//   1. HÉROE CON INMUNIDAD MÁGICA — Gran Avatar ('AHav') del Rey de la Montaña.
//   2. INVULNERABILIDAD, sea de quien sea — ver Hook_IsInvulnerable.
//
// ═══ POR QUÉ LA REGLA 1 PIDE "HÉROE" Y NO SOLO "INMUNE" ═══
// El Infernal del Señor del Terror trae de fábrica 'ACmi' (Inmunidad a conjuros,
// Hostil neutral) además de Piel Resistente. Un filtro por inmunidad mágica a
// secas lo sacaría también del gancho — y en el mapa clásico, del que sale la
// expectativa aprendida de todos los jugadores, el gancho SÍ jala Infernales y
// NO jala al Avatar. Pedir que además sea HÉROE separa los dos casos sin
// depender de qué reporta exactamente 'ACmi': el Infernal es una invocación,
// nunca un héroe, así que se sigue jalando pase lo que pase.
//
// Efecto lateral buscado: cualquier héroe que consiga inmunidad mágica (ítem o
// habilidad futura) queda inganchable por la misma regla, sin tocar código.
//
// ═══ POR QUÉ NO SE USA EL BUFF DEL AVATAR ═══
// Porque NO TIENE. Verificado en el Editor de Objetos (2026-08-02): 'AHav' tiene
// el campo de conjuros benéficos VACÍO, y en partida no aparece ningún ícono de
// estado al activarlo. No hay buff que leer. La inmunidad que otorga la propia
// habilidad es el único rastro que deja, y por eso es lo que se consulta.
//
// ⚠ SUPUESTO SIN MEDIR: que 'AHav' levante UNIT_TYPE_MAGIC_IMMUNE. Es la única
// pieza de esta función que no está verificada en partida. Medila con el trigger
// temporal EXTRAS/_DEBUG_Flags_Unidad.j (comando -flags) antes de dar el
// comportamiento por bueno. Si el Avatar diera NO, esta regla no lo excluye y
// hay que buscar otro rastro.
//
// El resto sigue siendo por ESTADO, no por identidad: acá no hay ni un rawcode
// de héroe ni de forma. Las transformaciones con rawcode propio (Robo Goblin
// 'Nrob', Forma Demonio 'Edmm', etc.) SÍ son enganchables mientras no den
// inmunidad mágica.
function Hook_IsHookImmune takes unit u returns boolean
    if (IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) and IsUnitType(u, UNIT_TYPE_HERO)) then
        return true
    endif
    return Hook_IsInvulnerable(u)
endfunction

function Hook_FilterEnum takes nothing returns boolean
    local unit f = GetFilterUnit()
    local real fx = GetUnitX(f)
    local real fy = GetUnitY(f)
    if (IsUnitType(f, UNIT_TYPE_STRUCTURE)) then
        set f = null
        return false
    endif
    // El gancho es un arma de suelo: las unidades aereas se ignoran por
    // completo (la cabeza les pasa por debajo y sigue viajando).
    if (IsUnitType(f, UNIT_TYPE_FLYING)) then
        set f = null
        return false
    endif
    if (GetWidgetLife(f) <= 0.405) then
        set f = null
        return false
    endif
    // Inmune al gancho por estado (magia inmune / invulnerable): pasa de largo.
    if (Hook_IsHookImmune(f)) then
        set f = null
        return false
    endif
    if (f == udg_Hook_Caster[udg_HookMUI[3]]) then
        set f = null
        return false
    endif
    // Nunca enganchar nada dentro de la zona de selección (filtro por ZONA, no
    // por identidad). Sin Locust: los maniquíes siguen siendo seleccionables y
    // detectables por los triggers de pick con GroupEnumUnitsInRect.
    if (Hook_PointInRect(fx, fy, gg_rct_ZonaHumanos) or Hook_PointInRect(fx, fy, gg_rct_ZonaOrcos)) then
        set f = null
        return false
    endif
    set f = null
    return true
endfunction

// ==========================================
// ===   INTERRUPCIÓN DE LA PRESA (TP)    ===
// ==========================================
// QUÉ GARANTIZA: enganchar a alguien CORTA lo que esté haciendo. El caso que
// importa en partida es el TP de las Botas ('I00W' / báculo 'brac'): una
// canalización de motor de 3s que el rival usa para huir y que todo el mapa
// sabe que se cancela con hex, stun, raíces, red... y con el gancho.
//
// CÓMO LO ROMPE EL MOTOR: una canalización muere cuando la unidad recibe una
// orden nueva o cuando el motor le resetea la orden actual. Acá se usan las
// dos vías, en dos momentos distintos:
//
//   1. AL ENGANCHAR (una vez): orden "stop" inmediata a la presa. Es la misma
//      vía que usa Zona_Seleccion.j para cortar el TP sobre wisps. Corta el TP
//      en el instante del enganche, sin esperar al primer tick de arrastre.
//
//   2. DURANTE EL ARRASTRE (cada tick): la presa se mueve con SetUnitPosition,
//      NO con SetUnitX/Y. Son dos natives distintos A PROPÓSITO:
//        - SetUnitX/Y: mueve "por debajo" del motor; la unidad CONSERVA su
//          orden. Si estaba canalizando el TP, lo TERMINA mientras la
//          arrastran (ese era exactamente el bug reportado en v2.0).
//        - SetUnitPosition: mueve Y resetea la orden actual. La presa no
//          puede iniciar ni completar nada mientras cuelga del gancho.
//      Es lo que hacía el gancho original (SetUnitPositionLoc, en GUI) y por
//      eso "el gancho de antes" sí cancelaba el TP. La reescritura pasó a
//      SetUnitX/Y (idioma moderno de knockback) sin reparar en este efecto.
//
//      SetUnitPathing(false) se mantiene durante el arrastre: con pathing
//      apagado, SetUnitPosition coloca a la unidad EXACTO donde se le indica
//      (no busca "el punto libre más cercano"), así que el arrastre por
//      terreno intransitable se comporta igual que antes.
//
// La CABEZA dummy (n01Z) no cambia: para ella SetUnitX/Y no renderiza bien y
// se recrea cada tick (ver callback).

// ==========================================
// ===       CALLBACK DEL TIMER           ===
// ==========================================

function Hook_Loop_Callback takes nothing returns nothing
    local integer i
    local real cx          // Posición actual del caster (viva)
    local real cy
    local real dx
    local real dy
    local real dist
    local real moveAngle
    local real speed
    local group g
    local unit firstU
    local player ownerP

    set i = 1
    loop
        exitwhen i > udg_HookMUI[2]

        if (udg_ON_OFF[i]) then
            set udg_HookMUI[3] = i
            set ownerP = GetOwningPlayer(udg_Hook_Caster[i])
            set speed = udg_Velocidad_Cadena[i]

            // Posición VIVA del caster (permite movimiento libre)
            set cx = GetUnitX(udg_Hook_Caster[i])
            set cy = GetUnitY(udg_Hook_Caster[i])

            if (not udg_Hook_Drag[i]) then
                // =============================================
                // FASE 1: EXTENSIÓN — La cabeza avanza
                // =============================================

                // Avanzar la distancia
                set udg_Distancia[i] = udg_Distancia[i] + speed

                // Nueva posición de la cabeza (desde punto de lanzamiento)
                set Hook_HeadX[i] = Hook_MaxReachX[i] + udg_Distancia[i] * Cos(Hook_LaunchAngleR[i])
                set Hook_HeadY[i] = Hook_MaxReachY[i] + udg_Distancia[i] * Sin(Hook_LaunchAngleR[i])

                // Recrear la cabeza dummy (fix: SetUnitX/Y no renderiza bien n01Z)
                call RemoveUnit(Hook_HeadDummy[i])
                set Hook_HeadDummy[i] = CreateUnit(ownerP, Hook_GetDummyUnitId(), /*
                */ Hook_HeadX[i], Hook_HeadY[i], udg_Angulo[i])

                // Actualizar lightning (caster vivo → cabeza)
                call MoveLightning(Hook_ChainLfx[i], true, cx, cy, Hook_HeadX[i], Hook_HeadY[i])

                // Detectar unidades cerca de la cabeza
                set g = CreateGroup()
                call GroupEnumUnitsInRange(g, Hook_HeadX[i], Hook_HeadY[i], Hook_GetHitRadius(), Filter(function Hook_FilterEnum))
                set firstU = FirstOfGroup(g)
                call DestroyGroup(g)
                set g = null

                if (firstU != null) then
                    // ¡ENGANCHE!
                    set udg_Hook_Target[i] = firstU
                    set udg_Hook_Drag[i] = true

                    // Cortar EN EL ACTO lo que la presa esté haciendo (TP de Botas,
                    // canalización, ataque...). Ver bloque INTERRUPCIÓN DE LA PRESA.
                    call IssueImmediateOrder(firstU, "stop")

                    // Guardar posición de máximo alcance (para trail)
                    set Hook_MaxReachX[i] = Hook_HeadX[i]
                    set Hook_MaxReachY[i] = Hook_HeadY[i]

                    if (IsUnitEnemy(firstU, ownerP)) then
                        // Enemigo: daño de impacto
                        call UnitDamageTarget(udg_Hook_Caster[i], firstU, udg_Damange[i], /*
                        */ true, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_UNKNOWN, WEAPON_TYPE_WHOKNOWS)
                        call DestroyEffect(AddSpecialEffectTarget( /*
                        */ "Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", firstU, "origin"))
                        // Registrar como asistencia garantizada (vía Control, key 600+i).
                        // El daño del gancho es bajo y no supera el umbral del 5% en mid/late game,
                        // pero el gancho es una jugada determinante que siempre debe contar.
                        // (Lógica inlineada de MB_RegisterControlTimestamp — evita error de orden de compilación)
                        if (IsUnitType(firstU, UNIT_TYPE_HERO)) then
                            call SaveReal(udg_MB_Hash, GetPlayerId(GetOwningPlayer(firstU)), 600 + GetPlayerId(ownerP), TimerGetElapsed(MB_Timer))
                            if (MB_DEBUG_ASIST) then
                                call DisplayTimedTextToPlayer(ownerP, 0, 0, 15.0, "|cffFFCC00[Asist]|r Control+Bloqueo (Gancho) -> " + GetUnitName(firstU))
                            endif
                        endif
                    endif

                    // Efecto "enganchado" (siempre, aliado o enemigo)
                    call DestroyEffect(AddSpecialEffectTarget( /*
                    */ "Abilities\\Spells\\Other\\TalkToMe\\TalkToMe.mdl", firstU, "overhead"))

                    // Crear trail lightning (desde punto de enganche hacia atrás)
                    set Hook_TrailLfx[i] = AddLightning(Hook_GetLightningType(), true, /*
                    */ Hook_HeadX[i], Hook_HeadY[i], Hook_HeadX[i], Hook_HeadY[i])
                    set Hook_TrailAlpha[i] = 0.60
                    call SetLightningColor(Hook_TrailLfx[i], 0.6, 0.8, 1.0, Hook_TrailAlpha[i])
                endif

                set firstU = null

                // ¿Alcanzó distancia máxima sin enganchar?
                if (not udg_Hook_Drag[i]) and (udg_Distancia[i] >= udg_Distancia_MAX[i]) then
                    set udg_Hook_Drag[i] = true
                    // Guardar posición de máximo alcance
                    set Hook_MaxReachX[i] = Hook_HeadX[i]
                    set Hook_MaxReachY[i] = Hook_HeadY[i]
                    // Crear trail
                    set Hook_TrailLfx[i] = AddLightning(Hook_GetLightningType(), true, /*
                    */ Hook_HeadX[i], Hook_HeadY[i], Hook_HeadX[i], Hook_HeadY[i])
                    set Hook_TrailAlpha[i] = 0.60
                    call SetLightningColor(Hook_TrailLfx[i], 0.6, 0.8, 1.0, Hook_TrailAlpha[i])
                endif

            else
                // =============================================
                // FASE 2: RETRACCIÓN — La cabeza vuelve al héroe
                // =============================================
                // La cabeza se mueve hacia la posición ACTUAL del caster.
                // Esto permite la jugada táctica de alejarse para arrastrar más.

                set dx = cx - Hook_HeadX[i]
                set dy = cy - Hook_HeadY[i]
                set dist = SquareRoot(dx * dx + dy * dy)

                if (dist <= Hook_GetSnapDistance()) then
                    // ¡Llegó al caster! Finalizar instancia.

                    // Mover target a posición final del caster
                    if (udg_Hook_Target[i] != null) then
                        call SetUnitPosition(udg_Hook_Target[i], cx, cy)
                        call SetUnitPathing(udg_Hook_Target[i], true)
                    endif

                    // Destruir cabeza dummy
                    call RemoveUnit(Hook_HeadDummy[i])
                    set Hook_HeadDummy[i] = null

                    // Destruir lightnings
                    call DestroyLightning(Hook_ChainLfx[i])
                    set Hook_ChainLfx[i] = null
                    if (Hook_TrailLfx[i] != null) then
                        call DestroyLightning(Hook_TrailLfx[i])
                        set Hook_TrailLfx[i] = null
                    endif

                    // Limpiar instancia
                    set udg_HookMUI[1] = udg_HookMUI[1] - 1
                    set udg_Hook_Target[i] = null
                    set udg_Hook_Caster[i] = null
                    set udg_ON_OFF[i] = false

                    // ¿Era la última instancia activa?
                    if (udg_HookMUI[1] == 0) then
                        set udg_HookMUI[2] = 0
                        call PauseTimer(Hook_Timer)
                    endif
                else
                    // Mover cabeza hacia el caster
                    set moveAngle = Atan2(dy, dx)
                    set Hook_HeadX[i] = Hook_HeadX[i] + speed * Cos(moveAngle)
                    set Hook_HeadY[i] = Hook_HeadY[i] + speed * Sin(moveAngle)

                    // Recrear dummy cabeza (fix: SetUnitX/Y no renderiza bien n01Z)
                    // Usa udg_Angulo[i] (ángulo de lanzamiento) para que la cabeza
                    // SIEMPRE apunte en la dirección original, sin girar 180°.
                    call RemoveUnit(Hook_HeadDummy[i])
                    set Hook_HeadDummy[i] = CreateUnit(ownerP, Hook_GetDummyUnitId(), /*
                    */ Hook_HeadX[i], Hook_HeadY[i], udg_Angulo[i])

                    // Actualizar lightning principal (caster → cabeza)
                    call MoveLightning(Hook_ChainLfx[i], true, cx, cy, Hook_HeadX[i], Hook_HeadY[i])

                    // Arrastrar target (si hay uno)
                    if (udg_Hook_Target[i] != null) then
                        // SetUnitPosition, NO SetUnitX/Y: mueve Y resetea la orden de la
                        // presa en cada tick → no puede terminar ni iniciar el TP mientras
                        // cuelga del gancho. Ver bloque INTERRUPCIÓN DE LA PRESA.
                        call SetUnitPathing(udg_Hook_Target[i], false)
                        call SetUnitPosition(udg_Hook_Target[i], Hook_HeadX[i], Hook_HeadY[i])

                        // Efecto visual de arrastre (solo enemigos, sin daño)
                        if (IsUnitEnemy(udg_Hook_Target[i], ownerP)) then
                            call DestroyEffect(AddSpecialEffect( /*
                            */ "Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", /*
                            */ Hook_HeadX[i], Hook_HeadY[i]))
                        endif
                    endif

                    // Actualizar trail (fantasma desde max reach hasta cabeza)
                    if (Hook_TrailLfx[i] != null) then
                        set Hook_TrailAlpha[i] = Hook_TrailAlpha[i] - Hook_GetTrailFadeRate()
                        if (Hook_TrailAlpha[i] <= 0.0) then
                            call DestroyLightning(Hook_TrailLfx[i])
                            set Hook_TrailLfx[i] = null
                        else
                            call MoveLightning(Hook_TrailLfx[i], true, /*
                            */ Hook_MaxReachX[i], Hook_MaxReachY[i], Hook_HeadX[i], Hook_HeadY[i])
                            call SetLightningColor(Hook_TrailLfx[i], 0.6, 0.8, 1.0, Hook_TrailAlpha[i])
                        endif
                    endif
                endif
            endif
        endif

        set i = i + 1
    endloop

    set ownerP = null
endfunction

// ==========================================
// ===       ACCIÓN DE CASTEO             ===
// ==========================================

function Hook_Cast_Actions takes nothing returns nothing
    local unit caster = GetTriggerUnit()
    local integer level = GetUnitAbilityLevel(caster, Hook_GetAbilityId())
    local real cx = GetUnitX(caster)
    local real cy = GetUnitY(caster)
    local real tx
    local real ty
    local unit tgt
    local real angle
    local integer idx

    // Determinar punto objetivo
    set tgt = GetSpellTargetUnit()
    if (tgt == null) then
        set tx = GetSpellTargetX()
        set ty = GetSpellTargetY()
    else
        set tx = GetUnitX(tgt)
        set ty = GetUnitY(tgt)
    endif

    // Ángulo de lanzamiento
    set angle = Atan2(ty - cy, tx - cx)

    // Arrancar timer si es el primer cast activo
    if (udg_HookMUI[1] == 0) then
        if (Hook_Timer == null) then
            set Hook_Timer = CreateTimer()
        endif
        call TimerStart(Hook_Timer, Hook_GetTick(), true, function Hook_Loop_Callback)
    endif

    // Registrar nueva instancia
    set udg_HookMUI[1] = udg_HookMUI[1] + 1
    set udg_HookMUI[2] = udg_HookMUI[2] + 1
    set idx = udg_HookMUI[2]

    // Datos de la instancia
    set udg_Hook_Caster[idx] = caster
    set udg_Angulo[idx] = angle * bj_RADTODEG
    set Hook_LaunchAngleR[idx] = angle
    set udg_Distancia[idx] = Hook_GetInitialDistance()
    set udg_Distancia_MAX[idx] = Hook_GetMaxDistance(level)
    set udg_Damange[idx] = Hook_GetImpactDamage(level)
    set udg_Velocidad_Cadena[idx] = Hook_GetChainSpeed(level)
    set udg_Hook_Drag[idx] = false
    set udg_ON_OFF[idx] = true
    set udg_Hook_Target[idx] = null

    // Guardar origen del lanzamiento (para extensión en línea recta)
    set Hook_MaxReachX[idx] = cx
    set Hook_MaxReachY[idx] = cy

    // Posición inicial de la cabeza
    set Hook_HeadX[idx] = cx + Hook_GetInitialDistance() * Cos(angle)
    set Hook_HeadY[idx] = cy + Hook_GetInitialDistance() * Sin(angle)

    // Crear cabeza dummy (UNA sola, en la punta)
    set Hook_HeadDummy[idx] = CreateUnit(GetOwningPlayer(caster), Hook_GetDummyUnitId(), /*
    */ Hook_HeadX[idx], Hook_HeadY[idx], udg_Angulo[idx])

    // Crear lightning principal (caster → cabeza)
    set Hook_ChainLfx[idx] = AddLightning(Hook_GetLightningType(), true, /*
    */ cx, cy, Hook_HeadX[idx], Hook_HeadY[idx])

    // Trail no existe aún (se crea al retraerse)
    set Hook_TrailLfx[idx] = null
    set Hook_TrailAlpha[idx] = 0.0


    // NO pausar al héroe. Puede moverse libremente.
    // El gancho regresa a su posición ACTUAL, no a la de lanzamiento.

    // Limpieza de locales
    set caster = null
    set tgt = null
endfunction

// ==========================================
// ===       INICIALIZACIÓN               ===
// ==========================================

function Hook_Cast_Condition takes nothing returns boolean
    return GetSpellAbilityId() == Hook_GetAbilityId()
endfunction

function InitTrig_Gancho_de_Carnicero takes nothing returns nothing
    local trigger t = CreateTrigger()

    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddCondition(t, Condition(function Hook_Cast_Condition))
    call TriggerAddAction(t, function Hook_Cast_Actions)

    // Fallback: si TablaHash no fue creada por Hook TH
    if (udg_TablaHash == null) then
        set udg_TablaHash = InitHashtable()
    endif

    set t = null
endfunction