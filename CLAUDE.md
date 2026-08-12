# CLAUDE.md

Guía para Claude Code (claude.ai/code) al trabajar en este repositorio.

> **Foco actual del trabajo: el COMPORTAMIENTO DE LOS BOTS** (sistema de carril).
> Antes de tocar nada de bots, lee **[`SISTEMA_IA/GUIA_DEBUG_BOTS.md`](SISTEMA_IA/GUIA_DEBUG_BOTS.md)**
> (mapa síntoma→ubicación, plantilla de reporte e invariantes). El contexto
> persistente entre sesiones vive en **`memory/`** (índice en `memory/MEMORY.md`).

---

## Contexto del Proyecto

Mapa competitivo de **Warcraft III** estilo MOBA llamado **"Orcos vs Humanos" (OvsH)**, escrito en **vJASS** para el parche **1.27b**.

- **Geografía:** 2 carriles horizontales (Top/Bot), **Humanos = Oeste (X−), Orcos = Este (X+)**. Detalle completo y sistema de coordenadas en **[Geografía del Mapa](#geografía-del-mapa-sistema-de-coordenadas)** (leer antes de tocar navegación/huida de bots).
- **Pool de Héroes:** registrado en `SISTEMA_IA/IA_Data.j` (Humanos y Orcos, incluidas formas de transformación con su propio rawcode).
- **Este código NO se compila/ejecuta desde consola.** Todo el JASS se copia manualmente al World Editor. No hay build system ni tests automatizados; la verificación final es siempre dentro del editor/juego.

---

## Geografía del Mapa (Sistema de Coordenadas)

> Mapa = **rectángulo grande horizontal**. El **eje X es el eje de avance** (Humanos al Oeste = X negativo; Orcos al Este = X positivo). El **eje Y separa los carriles** (Top = Y positivo; Bot = Y negativo). La **línea blanca de nieve central es X ≈ 0** (mitad del mapa). Las zonas oscuras de la imagen son **intransitables por tierra Y aire**; solo lo claro es jugable.
>
> ⚠️ Las **estructuras se crean después de cargar el mapa** (por eso no se ven en un screenshot inicial), pero existen siempre en runtime. Las coordenadas de abajo salen de `EXTRAS/Sistema_AntiBackdoor.j` (única fuente de verdad de posiciones de torres/castillos).

### Marco general

| Elemento | Humanos (Oeste) | Orcos (Este) |
|---|---|---|
| **Castillo / Fortaleza** (objetivo final, F0) | `'hcas'` en **(−4096, −256)** | `'ofrt'` en **(3840, −256)** |
| Lado del mapa | X negativo | X positivo |
| Pared de fondo | extremo Oeste (X muy negativo) | extremo Este (X muy positivo) |

Los **castillos están al CENTRO de la pared de fondo** (Y ≈ −256, casi el centro vertical), no en una esquina. Se llega a ellos uniendo la base Norte con la base Sur de cada facción y tocando la pared por el medio.

### Las cuatro esquinas = bases de curación / spawn / revive

Las **4 esquinas** del rectángulo son las **bases de curación**, una por carril y facción. Cada una tiene **Fuente de Vida + Fuente de Maná + Torre de protección de daño exagerado** (mata al instante a quien entre):

| Esquina | Base | Región (centro) |
|---|---|---|
| Noroeste | Humana Top | `gg_rct_Base_Hum_Top` (fuente: `gg_rct_FuenteHumTop`) |
| Suroeste | Humana Bot | `gg_rct_Base_Hum_Bot` (fuente: `gg_rct_FuenteHumBot`) |
| Noreste | Orca Top | `gg_rct_Base_Orc_Top` (fuente: `gg_rct_FuenteOrcTop`) |
| Sureste | Orca Bot | `gg_rct_Base_Orc_Bot` (fuente: `gg_rct_FuenteOrcBot`) |

Estas bases son **donde el héroe aparece al elegirlo (Círculos de Poder), donde revive, y el lugar MÁS SEGURO del mapa para curarse**. El bot lee su base propia más cercana con `IABrainMacro_GetClosestHomeX/Y` (distancia euclídea X+Y, solo entre las **dos bases de su propia facción** — nunca la enemiga).

> **Zona de selección:** los dos rectángulos verticales pequeños a izquierda (Humanos, controlan un *wisp*) y derecha (Orcos, controlan un *alma corrupta*) son solo para elegir héroe en All Pick / Pick. Al tocar el maniquí del héroe, el wisp/alma muere y el héroe nace en el Círculo de Poder de la esquina correspondiente. No es zona de combate.

### Centro: montaña partida, callejón y TIENDA SECRETA (trampa)

En el centro (X ≈ 0) hay una **montaña intransitable partida en dos**, dejando un **callejón/túnel vertical** que coincide con la mitad del mapa. En el **punto más estrecho** del callejón (dos salientes redondeados de la montaña, a la misma altura) está la **TIENDA SECRETA**, que **bloquea por completo el paso**.

- Quien entra al callejón **queda atrapado**: la única salida es por donde entró. **NO se puede cruzar al otro carril por el centro.**
- Para ir de una base a otra hay que tomar **obligatoriamente el carril Top o el Bot**. A mitad de mapa el héroe puede **seguir de frente** (sigue en su carril) o **desviarse hacia la tienda** (callejón sin salida).

### Carriles y avance

- **Carril Top:** corredor horizontal en **Y ≈ +830 … +2110**.
- **Carril Bot:** corredor horizontal en **Y ≈ −1120 … −2640**.
- Avanzar = moverse en **X** hacia la facción enemiga. Si un héroe **sigue de frente sin volver**, termina en la **fuente enemiga** del fondo y **la torre de protección lo mata al instante** (de ahí el keep-out `IsInEnemyFountain` / `GetFountainEscape`).

### Estructuras por FASES (anti-backdoor) — orden de caída

El enemigo avanza desde el centro hacia la base; las torres caen de afuera (centro) hacia adentro (castillo). **F3 es la más adelantada/vulnerable (cae primero); F0 es el castillo (cae último).** Cada fase se desbloquea (se vuelve vulnerable) al destruir la anterior — ver `Sistema_AntiBackdoor.j` (`AB_*_F*`, booleanos `*_Open`).

| Fase | Qué es | Posición (X aprox. desde el centro) | ¿Por carril? |
|---|---|---|---|
| **F3** | Primera línea, **nace vulnerable**, cae primero | a la **longitud de los extremos interiores de la montaña central** (Hum X ≈ −1600…−1850 / Orc X ≈ +1280…+1730) | **Sí**, Top y Bot por separado |
| **F2** | Segunda línea | **a mitad de camino entre F3 y el castillo** (Hum X ≈ −3000…−3390 / Orc X ≈ +2690…+2980) | **Sí**, Top y Bot por separado |
| **F1** | Anillo de torres **alrededor del castillo/fortaleza** | Hum X ≈ −3744…−4256 / Orc X ≈ +3488…+4000 (Y ≈ −670…+160) | **No**, solo central (no hay Top/Bot) |
| **F0** | El **castillo/fortaleza** mismo | Hum (−4096, −256) / Orc (3840, −256) | **No**, único y central |

Navegación de empuje del bot (`IABrainMacro_UpdateObjective`): **F3 propio carril → F2 propio carril → F3 otro carril (reruteando por la base propia) → F2 otro carril → F1 central → F0**.

### Geometría de la HUIDA (clave para bots)

El lugar más seguro siempre es **la fuente propia más cercana (Top o Sur), nunca la enemiga**. Pero la dirección de retirada **no es siempre horizontal**:

- **En el carril** (Top/Bot, lejos de la base): el carril es horizontal, así que retroceder hacia casa **avanza casi todo por el eje X**.
- **Pegado al castillo/fortaleza** (X ≈ ±4000, Y ≈ −256): la fuente está arriba (Norte) o abajo (Sur), así que retroceder **avanza casi todo por el eje Y**.

Por eso el progreso de huida se mide como **reducción de distancia en línea recta a la fuente (X+Y combinados)**, no por el eje X solo (ver `IABreakout_Try`, modo `isRetreating`). De-aggro táctico (`IA_State_Laning.j`) y huida estratégica (`IA_State_Survival.j`) ya apuntan a `GetClosestHomeX/Y` (fuente propia más cercana por distancia completa).

---

## Estructura del Código

Dos capas:

| Capa | Ubicación | Rol |
|---|---|---|
| **Legacy Base** | `Documentacion/init.j` | Código original desprotegido. Solo lectura conceptual; triggers y globals generadas por el editor. |
| **Código Nuevo (activo)** | `SISTEMA_IA/`, `SISTEMA_CORE/`, `EXTRAS/`, `CUSTOM_SKILLS/` | Todo el código nuevo, modular. Aquí se lee y escribe. |

**Código Activo Total = `init.j` + las 4 carpetas nuevas.**

> ⚠️ `Documentacion/_REFERENCIA_GLOBAL.j` está **desactualizado**: úsalo solo para consultar **nombres de globales del editor** (`udg_*`, `gg_*`). Nunca tomes su lógica como referencia.

El resto del código nuevo, **fuera del foco actual** (consultar solo si el problema lo toca):
- **`SISTEMA_CORE/`**: arranque de partida — detección de host, índice de héroes, menús de modo (All Pick / Random), economía de oro, asignación aleatoria de héroes, AFK.
- **`EXTRAS/`**: sistemas complementarios — kills, votación, méritos, anti-backdoor, economía, modo aleatorio de habilidades, zoom, easter eggs.
- **`CUSTOM_SKILLS/`**: habilidades en vJASS puro (Gancho de Carnicero, Torbellino, Quebrantavidas, Fisura, Barril). Cada archivo trae cabecera con los campos del Object Editor a ajustar.

---

## Arquitectura del Sistema de IA (`SISTEMA_IA/`) — FOCO

La IA corre un **loop de 0.10s** (`TimerStart(IA_Timer_Loop, 0.10, true, function MainLoop)`) que recorre los bots activos y llama a `Bot.update()`, una **FSM** de estados.

### Jerarquía de Libraries (orden por `requires`)

```
IADataItems   ←─ base (sin dependencias)
IADataBuffs   ←─ base
IABlackboard  ←─ base (pizarra tipada del laning: struct LaningBrain)
IAData        ←─ requires IADataItems
IAUtils       ←─ requires IAData, IADataItems, IADataBuffs
IABrainMacro  ←─ requires IAUtils
IABreakout    ←─ requires IAUtils, IABlackboard, IABrainMacro, IAData (anti-encierro 3 capas + berserker)
IAStateLaning ←─ requires IAUtils, IAData, IABrainMacro, IABlackboard, IABreakout
IAStateSurvival ←─ requires IAUtils, IABrainMacro, IABreakout, IABlackboard
IAStateShopping ←─ requires IAUtils, IAData, IADataItems, IABrainMacro, IAStateSurvival (al terminar en la tienda con <85% HP, deriva a Survival a curarse antes de volver al carril)
IACore        ←─ requires IAUtils, IAStateLaning, IABrainMacro, IAStateSurvival, IAStateShopping, IABreakout
```

### Struct `Bot` (en `IA_Core.j`) y la pizarra

- `Bot` guarda **identidad y estado estratégico**: `hero`, `owner`, `heroId`, `lane` (1=Top, 2=Bot), `state`, `hpPercent`, `mpPercent`.
- El **estado táctico de carril** (target, tolerancia, observación de daño, timing FSM) vive en **`struct LaningBrain`** (`IA_Blackboard.j`), una pizarra por bot. **Una sola fuente de verdad por dato** — no duplicar estado entre `Bot` y la pizarra ni en hashtables sueltas.

### Estados del Bot

| Estado | Archivo | Descripción |
|---|---|---|
| `1` — Laning | `IA_State_Laning.j` | Farm, harass, orb-walking, last-hit, de-aggro |
| `3` — Survival | `IA_State_Survival.j` | Huida a base a curarse. Umbral **CONTEXTUAL**: 40% base, +7% por héroe enemigo extra enfocándome, baja a 28% con cero peligro |
| `4` — Shopping | `IA_State_Shopping.j` | Camina a la tienda y compra (con oro) |

Selector **estricto**: solo un estado se ejecuta por frame (`Bot.update()`).

### Comportamiento de carril: SENTIR → PENSAR → ACTUAR

`IA_State_Laning.j` se divide en dos fases que se comunican **solo** por la pizarra:
- `Think()` (privada) = SENTIR + PENSAR: escanea, puntúa objetivos (Utility AI), tolerancia/decay. **NO emite ninguna orden.**
- `IAStateLaning_ExecuteLaning()` = ACTUAR: **único lugar que emite `IssueOrder`.**

Sistemas del laning (2026-06-10, ver detalle en la guía de debug):
- **Foco grupal por TALLY**: el foco del equipo es el héroe enemigo con MÁS aliados atacándolo (voto por objetivo, no el último enumerado). Alimenta bonus de asistencia, tolerancia de equipo y kill-commit.
- **Sensores de presión** (scratch en la pizarra): `enemyHeroesNear/allyHeroesNear/alliesClose/enemiesTargetingMe`, más la **EMA de pérdida real de vida** (`selfLossRate`, mantenida por `IACore.MainLoop` → `IABlackboard_UpdateHPTrack` para TODOS los héroes). El de-aggro usa `max(estimación física, pérdida real)` → **ve hechizos**.
- **Amenaza ANTICIPADA**: héroes con `danger >= 1.4` a ≤800 suman daño potencial al de-aggro **solo en inferioridad local** (tomar distancia del peligroso estando solo).
- **Aliado condenado ("el siguiente soy yo")**: si un aliado cercano cae en <6s al ritmo real bajo focus (≥2 enemigos) y sin él quedamos en inferioridad, retirada táctica aunque la vida esté llena (`dangerRetreat`, canal del de-aggro).
- **Tolerancia efectiva**: el umbral del frame se recorta 25% por enemigo extra enfocándome (la tolerancia persistida NO se modula). Decay agotado → suelta `lastTarget`.
- **WAR PARTY (late game)**: desde que cualquier F1 abre (`IABrainMacro_IsWarPartyActive`), no avanzar solo: grupo = min(equipo, 3); sin grupo, `IssueAdvance` manda al punto de reunión (centroide del equipo fuera de base / defensa propia); con grupo, adopta el carril de la mayoría. **HOLD FIRE**: en standoff el primer golpe a héroes lo decide un humano vivo (sin humanos: solo con superioridad); los remates no se retienen.

> Regla base de depuración: la **DECISIÓN** (a quién atacar/perseguir, farmear o huir) se edita en `Think()`; la **EJECUCIÓN** (timing, temblor, kite) en la FSM de `ExecuteLaning()`. **Nunca mezclar.** Detalle completo en [`GUIA_DEBUG_BOTS.md`](SISTEMA_IA/GUIA_DEBUG_BOTS.md).

### Subsistemas de soporte (gotchas que importan)

- **`IA_Target_Memory`** (hashtable global en `IAUtils`): intención de ataque (`key 0`) y target físico (`key 1`) por unidad; datos de Shopping en `keys 100-119`. **Nunca usar `FlushChildHashtable`** sobre un héroe (destruiría la cola de compras al morir); borrar selectivo con `RemoveSaved*`.
- **`IACore_AllHeroes[]`**: array global con todos los héroes (bots + humanos), poblado en `InitializeBots`. Lo usan buffs/auras para escaneos O(n).
- **`IAData`**: stats de héroes (rango, daño, armadura, proyectil…) + tabla de **peligrosidad** (`IAData_GetHeroDanger`, default 1.0 = neutro; solo para burst/CC oculto, NO para daño/tankiness que ya se mide vía stats).
- **`IADataBuffs`**: buffs/debuffs escalados; `GetScaledEffectLevel` con 3 mecanismos: Target (A), AoE (B), Aura con scan de `AllHeroes[]` (C).
- **`IABrainMacro`**: coordenadas de bases/castillos, asignación de carril al nacer, y **navegación de empuje por fases** (`UpdateObjective`): elige a qué estructura avanzar leyendo el estado del anti-backdoor (grupos `AB_*`/`*_Open`), rerutea por la base propia al cambiar de carril (`ApplyRerouteIfNeeded`) y define el **keep-out de la fuente enemiga** (`IsInEnemyFountain`). Acopla a `EXTRAS/Sistema_AntiBackdoor.j` (lee sus globales). Además aloja el **censo de equipo del WAR PARTY** (`UpdateWarPartyCache`, throttle 0.30s: vivos, humanos vivos, centroide fuera de base, carril mayoritario, `ResolveRally`).
- **`IABreakout`** (`IA_Breakout.j`): **anti-encierro en 3 capas + Berserker**. Estado persistente en `LaningBrain`. Detalle en [`GUIA_DEBUG_BOTS.md`](SISTEMA_IA/GUIA_DEBUG_BOTS.md). Capas:
  - **Capa 1 — Despeje en ruta** (`IABreakout_TryPathClear`, oportunista, solo durante huida): mata de paso un creep que **tape de verdad el corredor recto a casa** (`|perp| <= CORRIDOR_HALF`, no un cono ancho) y esté **ANCLADO** (con objetivo físico vivo o quieto — `IsCreepAnchored`, NO por la orden) si lo tumba en ≤2 golpes. Un creep que **marcha/circula** (attack-move sin objetivo físico) se **ignora**: se aparta solo (sin esto, la oleada attack-move entera salía como "muro" y el bot la mataba uno por uno o perseguía al que esquivaba). Si toma >2 golpes, rodea. No toca héroes. **No incrementa el contador.** (CHANGE A/B 2026-06-11.)
  - **Capa 2 — Encierro real** (`IABreakout_Try`): detección de "quería moverse y no se desplazó". Métrica = **acercamiento a casa en línea recta (X+Y)** (4s) si huye, euclídeo (0.7s) si no. (El avance de huida se mide como reducción de distancia a la fuente propia más cercana: en el carril avanza por X, pero pegado al castillo/fortaleza avanza por Y subiendo/bajando a la fuente. Medir solo X daba falsos "encierros" dentro de la propia base.) Al confirmar, ring scan con prioridad **héroe enemigo > creep enemigo > creep aliado** y preferencia por víctimas en cono de salida; nunca héroes aliados, **nunca héroes en zona de veto de asedio** (`IsHeroTooDeep`, espejo de `tooDeepToHunt` — fix BRK/BSK-DIVE 2026-06-10; aplica también al berserker). **RE-EVALUACIÓN (CHANGE C 2026-06-11):** un breakout de huida activo se SUELTA por **evidencia positiva** si el corredor recto a casa quedó libre (`IsCorridorClearToHome`: sin estructuras, sin unidades ancladas, terreno transitable; throttle 0.30s) — ataca "el creep se apartó pero el bot sigue matándolo". Salidas: `FREE_DIST` / muerte de víctima / **camino libre** / `BREAKOUT_TIMEOUT`. El COMPROMISO-hasta-matar sigue vigente cuando el camino NO está libre (no reabre el ping-pong con la Emergencia).
  - **Capa 3 — Berserker** (`IABreakout_ExecuteBerserk`): contador de reincidencia con ventana 2s. Al 3er encierro consecutivo, el bot **acepta su muerte** y prioriza matar: (1) héroe enemigo en rango con más presión aliada, (2) menor hits-to-kill, (3) invocación en rango, (4) si nada, fallback a creep-escape manteniendo el modo. Sale al morir / matar target / alejarse ≥600 / recuperar HP >70%. **`Bot.update()`** llama `IABreakout_ResetOnRevive` en la transición muerto→vivo para no resucitar arrastrando berserker.
  - **Invariante**: ni breakout ni berserker escriben `lastTarget`/`isRetreating`; usan canales propios (`breakoutTarget`, `berserkTarget`). Al salir, la lógica normal recalcula la intención original sola.

---

## Reglas Arquitectónicas Estrictas (vJASS 1.27b)

1. **Rendimiento:** coordenadas X/Y siempre. **Prohibido** `Location`, `TriggerSleepAction`, `PolledWait`. Destruir todo grupo con `DestroyGroup(g)` en la misma función.
2. **Orden de compilación:** nunca referencies algo declarado **después** en el orden. Verifica las `requires` de cada library.
3. **`onInit` / inicialización:** asegúrate de que todo bloque de init esté implementado y llamado. Diálogos/interfaces mal inicializados fallan **silenciosamente**.
4. **Memory leaks:** nullea siempre los locales `unit`, `group`, `trigger` al final de cada función.
5. **Hashtable de Shopping (keys 100-119):** no `FlushChildHashtable` en `IA_Target_Memory` sobre un héroe; usa `RemoveSaved*`.
6. **Invariantes de bots:** `Think()` jamás emite órdenes; solo `ExecuteLaning()` emite (excepción acotada: la guardia `IABreakout_Try` también emite, como interrupción transitoria de máxima prioridad). El estado táctico vive en `LaningBrain`, no en `Bot` ni en hashtables nuevas. El **breakout nunca escribe** `lastTarget`/`isRetreating` (canal propio `breakoutTarget`). (Ver `GUIA_DEBUG_BOTS.md`.)

---

## Invariantes de Física del Motor (distancia / rango / encierro)

> Origen: una familia de falsos "Encerrado" salió de comparar **distancia cruda contra rango crudo**. Estas reglas previenen toda esa familia de bugs **sin necesidad de probar en el juego**. Aplícalas a CUALQUIER comparación de rango, no solo en breakout.

1. **`GetDistanceUnits` mide CENTRO A CENTRO.** El motor de WC3, en cambio, permite atacar cuando la distancia ≤ `rango + colisión del objetivo`. Por eso un atacante que **sí está golpeando en rango** mide más que su rango crudo (observado: melee 159-181 con rango 128; rango 659-663 con rango 600 → sobrepaso ~30-60).
   - **Nunca** decidas "¿está en rango / necesita acercarse?" con `dist > rango` pelado: es un umbral demasiado sensible que dispara falsos positivos.
   - Suma un **colchón de colisión** (`ATTACK_REACH_SLACK ≈ 100`, en `IA_State_Laning.j`). El sobrepaso depende de la **colisión del objetivo**, no del rango del atacante → **el mismo colchón vale para melee y rango**.
   - Excepción consciente: la **compuerta de la FSM** (`inAttackRange`) usa el rango crudo a propósito (afecta timing/last-hit); no le metas el colchón sin querer.

2. **Quietud ≠ encierro.** Un bot quieto **no** está atrapado por estar quieto. La detección de encierro (`IABreakout_Try`, métrica euclídea 0.7s) solo es válida cuando el bot **necesita desplazarse y no puede**. NO es encierro:
   - Estar quieto **atacando algo que sí alcanza** (en rango del motor, aunque `dist > rango` crudo) → por eso `wantsToMove` lleva el colchón de arriba.
   - No poder alcanzar un objetivo **opcional** (p.ej. **perseguir un héroe que retrocede**): perseguir es una decisión del **sistema de puntaje en `Think`**, no un cerco. Esa rama está **excluida** de la Capa 2 en `ExecuteLaning` (target héroe enemigo fuera de rango); el melee usa `IABreakout_TryChaseClear` y, si el creep es muy duro, deja que el **motor rodee** solo.
   - Encierro **real** = el bot quiere ir a un punto que **necesita** (huir a su fuente / avanzar al objetivo de fase) y su posición no cambia pese a intentarlo.

3. **Geometría en runtime ⇒ debug-first.** Para lógica que depende de posiciones/colisión/pathing reales (rango, encierro, kite, navegación), **instrumenta y observa números de partida ANTES de fijar umbrales**. No hardcodees un umbral "a ojo" dándolo por bueno (así se cazaron estos bugs: texttags `STK-cmb d/o/T/M`).

---

## Flujo de Inicio del Mapa

1. `IA_Permisos`: al inicio, permite a humanos seleccionar héroes de los bots por 60s.
2. Al vencer el timer → `IA_Arrancar` quita el control compartido y llama `IACore_InitializeBots()`.
3. `InitializeBots()` itera los 16 slots, registra héroes humanos en `AllHeroes[]` y bots (Computer) en `BotsActive[]`, y llama `StartEngine()`.
4. `StartEngine()` inicia el timer de 0.10s con `MainLoop`.

> **Modo aleatorio de habilidades:** desactivado cuando hay bots presentes (los bots no aprenden/usan habilidades aleatorias). No mezclar ese modo con IA.

## Convención de Rawcodes

Héroes y habilidades se referencian por rawcode de 4 caracteres entre comillas simples: `'Ekee'`, `'Obla'`, `'H00P'`, `'A023'`. Las formas de transformación tienen su propio rawcode, registrado aparte en `IAData`.
