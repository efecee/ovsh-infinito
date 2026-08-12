# Guía de Depuración del Comportamiento de Bots (OvsH)

> Objetivo: que ante un comportamiento incorrecto observado en partida, se sepa
> **exactamente dónde tocar** y se minimice el riesgo de bugs indirectos.
> Esta guía asume la arquitectura **SENTIR → PENSAR → ACTUAR** (ver IA_Blackboard.j).

---

## Regla de oro (de dónde NO salirse)

Casi todo arreglo de carril cae en **una** de estas dos mitades de `IA_State_Laning.j`:

| Si el problema es… | Editar SOLO | Por qué |
|---|---|---|
| **A QUIÉN ataca / persigue / si farmea o no** (la DECISIÓN) | `Think()` | Es donde se puntúan objetivos (Utility AI), tolerancia y de-aggro. No emite órdenes. |
| **CÓMO ejecuta** (tiembla, no pega a tiempo, orb-walk roto, no avanza) | `ExecuteLaning()` (la FSM) | Es el único lugar con `IssueOrder`. El timing vive aquí. |

Si tocas `Think()`, **no** deberías necesitar tocar la FSM, y viceversa. Si crees
que sí, probablemente el dato que falta debe pasar por la **pizarra** (`LaningBrain`),
no por una variable nueva acoplada.

---

## Mapa SÍNTOMA → UBICACIÓN

### Selección de objetivo / persecución (→ `Think()` en IA_State_Laning.j)
- **"Persigue a un héroe demasiado lejos / se mete a la base enemiga"** → bloque de
  scoring de héroes (`currentScore` / `safetyPenalty`), y el **BONUS DE CAZA**
  (`hitsToKill`). Subir `safetyPenalty` lo hace más cobarde. Además hay un tope
  espacial duro: el **VETO DE PROFUNDIDAD** (ver siguiente bullet).
- **"No ataca a un héroe que tengo justo ahí (metido en la base enemiga)"** o
  **"suelta una caza que parecía ganada"** → es el **VETO DE PROFUNDIDAD DE CAZA**
  (`tooDeepToHunt` en `Think`). Veta targetear HÉROES que estén más de
  `ENEMY_DEPTH_SLACK` (=200) MÁS ALLÁ del **frente de asedio** (estructura enemiga
  viva más adelantada, `IABrainMacro_GetSiegeFrontX`). Es solo TARGETING: no emite
  movimiento (no puede crear bucle avanzar/retroceder) y NO toca estructuras/creeps
  ni el avance por fases. **DOS excepciones** que lo levantan:
  1. **Rematable en `<= HUNT_LETHAL_HITS` (=2) golpes** contando la ARMADURA del
     héroe (`heroHitsToKill = HP / (myDamage * reducción)`). **NO es porcentaje** —
     un tanque a 20% puede seguir siendo >2 golpes. Mismo criterio de golpes que el
     despeje de `IA_Breakout.j`, pero con armadura (héroes = armadura + HP).
  2. **Aliado HUMANO (no bot) enfocándolo** (`humanFocusGroup`, poblado en el
     escaneo de asistencia con `controller USER` **+ slot `PLAYING`** — el héroe de un
     leaver tomado por la IA conserva controller USER y no debe contar). El foco de
     un BOT aliado NO levanta el veto (estaría igual de vetado, no justifica dive).
  Se **apaga entero** cuando la F1 enemiga abre (`IABrainMacro_IsSiegeVetoActive` =
  `not AB_*_F1_Open`: tras romper ambas F2, el castillo/fortaleza es vulnerable y se
  sitia libre). Debug (texttags, solo cuando aplican ese frame):
  - `VETO sf=<frente> dp=<prof.> n=<vetados>` → bloqueó perseguir a ≥1 héroe.
  - `CAZA-PROF dp=<prof.> r=H htk=<golpes> dmg=<daño> n=<exentos>` (o `r=A`) → un héroe
    estaba profundo pero una excepción lo dejó cazar igual (`r=H` rematable ≤2 golpes,
    `r=A` aliado humano). En `r=H`, `htk` = golpes-para-matar **estimados** y `dmg` =
    daño estimado del bot. **Si ves `CAZA-PROF` y el bot muere sin matar → la excepción
    está dejando pasar un dive malo:** revisa `HUNT_LETHAL_HITS` (bajarlo a 1.0 = solo
    one-shots). **Si `htk` sale ≤2 pero en la partida el héroe aguanta 10+ golpes
    reales → la ESTIMACIÓN está rota** (daño/armadura en `IA_Data.j`), no el umbral.
- **"El bot persigue/ataca un héroe DENTRO de la zona vetada aunque el veto esté
  activo"** → **ARREGLADO (2026-06-10):** el ring-scan de `IABreakout_Try` y los
  dos pases de `SelectBerserkTarget` ahora rechazan héroes enemigos en zona de
  veto vía `IsHeroTooDeep` (`IA_Breakout.j`, espejo de `tooDeepToHunt`; lee
  `dbgVetoActive`/`dbgSiegeX` de la pizarra — esos campos ya no son solo debug,
  son carga útil). Creeps/estructuras quedan como única salida del cerco.
  **Limitación asumida:** si el ÚNICO bloqueador es un héroe profundo, el bot no
  lo ataca y puede oscilar en la detección (preferible al dive). La constante
  `DEEP_VETO_SLACK` (200, `IA_Breakout.j`) debe mantenerse SINCRONIZADA a mano
  con `ENEMY_DEPTH_SLACK` (`IA_State_Laning.j`). Diagnóstico (texttags):
  - `DEEP dp=<prof.> tgt=<H|C|S|A|0> ret=.. brk=.. bsk=..` → el **BOT** está más allá
    del frente por > `ENEMY_DEPTH_SLACK` con el veto activo. `tgt`=qué trae
    (`H`=héroe enemigo / `C`=creep enemigo / `S`=estructura / `A`=aliado / `0`=ninguno);
    `ret`=huyendo; `brk`=lo retiene el anti-encierro; `bsk`=berserker. Lecturas:
    `tgt=H brk=0 bsk=0` = fallo del veto en `Think`; `tgt=H` con `brk=1`/`bsk=1` = el
    breakout/berserker pisa el veto; `tgt=C` = entró/sigue profundo por un creep.
  - `BRK-DIVE dp=<prof.> c<ciclo>` / `BSK-DIVE dp=<prof.>` → **CANARIOS**: tras el
    fix no deberían aparecer NUNCA. Si aparecen = regresión de `IsHeroTooDeep`.

  **Posibles problemas → ajuste de una línea** (todos en los `globals` de `IA_State_Laning.j`):

  | Síntoma | Ajuste |
  |---|---|
  | Suelta cazas que SÍ debería rematar / muy cobarde cerca de torres | **subir `ENEMY_DEPTH_SLACK`** (p.ej. 400) |
  | Se mete demasiado a cazar en la base | **bajar `ENEMY_DEPTH_SLACK`** |
  | Dive feo a por un "2 golpes" que no muere | **bajar `HUNT_LETHAL_HITS`** a 1.0 |
  | No remata heroes claramente matables a 2 golpes | **subir `HUNT_LETHAL_HITS`** a 3.0 |
  | No respeta el dive de un aliado humano | el target del humano no está trackeado (usó hechizo, no ataque); el tracking de `IA_Utils.j` capta órdenes attack/smart y ataques físicos |
- **"No farmea creeps, solo molesta héroes"** (o al revés) → comparar las bases de
  `currentScore` entre creeps, héroes y el HARASS UNIVERSAL (`dist <= myRange`).
- **"No hace last-hit / no remata"** → SELECCION NIVEL 1 (`predictedHP <= myDamage`,
  `isLethalHero`) y la predicción (`predictedTravelTime`, `enumRegen`).
- **"No se suma cuando mis aliados pelean" / "se suma al foco equivocado"** →
  escaneo de asistencia (`teamFocusTarget`, `teamFocusCount`) y los bonus de
  OPORTUNIDAD GRUPAL. Desde 2026-06-10 el foco es un **TALLY POR OBJETIVO**:
  cada aliado vota por su target y gana el héroe con MÁS votos (empate: menor
  HP%). El texttag `FOCO n=<votos> h=<humanos>` (solo con ≥2) muestra el conteo
  REAL (`n`) y cuántos de esos votos son de JUGADORES REALES (`h`). Antes el
  contador sumaba aliados pegándole a CUALQUIER héroe y el target era el último
  enumerado (azar) — si ves focos imposibles, revisa el tally.
- **"El bot enfoca el blanco de los bots y no el del jugador real"** →
  **PONDERACIÓN HUMANO vs BOT del bonus de asistencia (2026-06-11)**. El bonus de
  OPORTUNIDAD GRUPAL ya no usa `teamFocusCount` crudo sino `effectiveFocus`: cada
  voto de un JUGADOR REAL (controller USER + slot PLAYING, igual criterio que el
  veto de profundidad) pesa `ASSIST_HUMAN_WEIGHT` (2.0), un voto de bot pesa 1.0.
  Así, a igual nº de atacantes, el bot puntúa MÁS alto la víctima que un humano
  está enfocando (el humano elige mejor; un foco solo-bots puede auto-confirmarse
  en mal blanco). `teamFocusCount` NO se toca (el kill-commit y la tolerancia de
  equipo lo necesitan como nº literal de cuerpos). Diales: subir
  `ASSIST_HUMAN_WEIGHT` = más obediencia al humano; 1.0 = comportamiento viejo
  (humano = bot). El conteo humano del foco ganador sale en el texttag `FOCO h=`.
- **"Persigue eternamente / nunca suelta a la víctima"** → SISTEMA DE DECAY
  (`decayActive`, `DECAY_INTERVAL`, `DECAY_AMOUNT`). Al agotarse la tolerancia
  (llega a 0 por decay) ahora además **descarta `lastTarget`** (`Decay:
  soltando presa`): antes, si nadie golpeaba al bot, la caza seguía por inercia.
- **"Le teme/ignora al héroe equivocado"** → tabla de peligrosidad: `IAData_GetHeroDanger`
  (datos en IA_Data.j, con RÚBRICA de puntuación al final del archivo). Recordar:
  el daño/tankiness ya se mide solo vía stats; `danger` es solo para burst/CC
  oculto. La penalización ahora lleva **componente aditiva** (`dist*0.10` por
  punto de exceso): un peligroso EN rango ya no queda con penalización 0.
- **"Huye de un héroe que ni lo ha tocado"** → AMENAZA ANTICIPADA (`ANT <v>
  e=<enem> a=<ali>`): héroes con `danger >= DANGER_ANTICIPATE` (1.4) a
  `DANGER_RADIUS` (800) suman daño POTENCIAL al de-aggro **solo en inferioridad
  local** (aliados cerca < enemigos cerca). Es a propósito (tomar distancia del
  Señor del Terror estando solo). Si exagera: subir `DANGER_ANTICIPATE` o bajar
  el `danger` del héroe. Si baila entrar/salir del radio: subir `DEAGGRO_COMMIT`.
- **"En late game tiene un héroe enfrente y no lo ataca"** → HOLD FIRE del war
  party (`WP HoldFire`): en standoff (sin foco de equipo, ≥2 héroes enemigos
  cerca, nadie me ataca) el PRIMER golpe lo decide un humano vivo del equipo
  (sin humanos: solo con superioridad local). Los REMATES (`killTarget`) no se
  retienen. Es comportamiento pedido, no bug.

### Huida / retirada (DOS capas distintas — no confundir)
- **"Se va a curarse muy pronto / muy tarde"** (retirada ESTRATÉGICA) →
  `IA_State_Survival.j`: el umbral ya NO es 40% plano, es **CONTEXTUAL**:
  `LOW_HP_THRESHOLD` (0.40) **+ `RETREAT_PER_FOCUS` (0.07) por héroe enemigo
  extra enfocándome** (huye antes bajo focus), y baja a `SAFE_RETREAT_FLOOR`
  (0.28) con CERO peligro (sin héroes enemigos cerca, sin daño entrante, sin
  pérdida real). `HEALTHY_THRESHOLD` (0.95) no cambia.
- **"Retrocede/suelta aggro mal, pero sin ir a base"** (retirada TÁCTICA / de-aggro) →
  `Think()`: cálculo de `incomingDamage` vs `damageThreshold`, y el sistema de
  tolerancia (`TOLERANCE_BASE/MAX`, escalado por `hitsToKill`). La ACCIÓN de
  retroceder está en `ExecuteLaning()` (bloque "CAPA DE RETIRADA TÁCTICA").
  Tres entradas NUEVAS al mismo canal (2026-06-10):
  - **Pérdida REAL medida**: `incomingDamage = max(estimación física, EMA de
    pérdida de HP propia)` — el de-aggro ya VE hechizos/dots/torres mágicas (la
    EMA la mantiene `IABlackboard_UpdateHPTrack`, llamada desde IACore.MainLoop
    para TODOS los héroes). Antes solo contaban auto-ataques físicos.
  - **Tolerancia efectiva**: el umbral del frame se recorta `FOCUS_TOL_CUT`
    (25%) por héroe enemigo extra enfocándome. Solo el umbral; la tolerancia
    PERSISTIDA no se toca (evita la espiral de realimentación).
  - **"ALIADO CONDENADO"** (`DOOM t2d=<s> e=.. a=..` y marcador ` doom` en la
    línea De-Aggro): si un aliado cercano muere en < `ALLY_DOOM_T` (6s) al
    ritmo real medido, con ≥2 héroes enemigos cerca y quedando en igualdad o
    inferioridad sin él, el bot se retira AUNQUE TENGA LA VIDA LLENA ("el
    siguiente soy yo"). Si abandona peleas ganables: bajar `ALLY_DOOM_T`; si
    muere acompañando causas perdidas: subirlo (rango razonable 5-7).

### Avance agrupado late-game / WAR PARTY (→ IA_State_Laning.j + IA_Brain_Macro.j)

Desde que **cualquier F1 se abre** (`AB_*_F1_Open`; ahí mueren las creeperas de
F2 y los carriles pierden cobertura), los bots **no avanzan solos**: la decisión
vive en `Think()` (publica `wpActive/wpAdvanceOK/wpRallyX,Y/wpHoldFire` en la
pizarra) y la orden la emite **solo `IssueAdvance`**. Censo de equipo cacheado
por facción en `IA_Brain_Macro.j` (`UpdateWarPartyCache`, throttle 0.30s).

Reglas: grupo requerido = **min(héroes del equipo, 3)** (equipo de 3 espera a
TODOS; de 4-5 basta mayoría de 3, contando al bot). Con grupo formado, commit
de `WP_COMMIT` (6s). Sin grupo → `move` al **punto de reunión**: centroide de
los héroes vivos del equipo FUERA de las bases de curación (excluyéndose a sí
mismo), o si nadie está fuera, la defensa propia más adelantada viva
(F3/F2 → anillo F1 → F0 → fuente). Con grupo, además adopta el **carril de la
mayoría** (`GetMajorityLane`) al resolver el objetivo de fases.

| Síntoma | Dónde tocar |
|---|---|
| "Los bots no avanzan nunca en late game" | ¿Cuántos vivos? Si vivos < `wpGroupNeeded`, esperan revives a propósito (no pushear en desventaja). Si hay grupo y no avanzan: ver `WP Reagrupar n=x/y` — si `n` nunca llega a `y`, bajar `GROUP_RADIUS` no, SUBIRLO (se cuentan a 900) o revisar que el rally converja. |
| "Avanza solo igual" | ¿`wpActive`? El modo exige F1 abierta Y equipo ≥2 héroes. Dentro de `WP_COMMIT` (6s) tras perder el grupo sigue avanzando a propósito (histéresis). |
| "Se quedan parados en la fuente en vez de adelante" | El rally cayó al fallback: nadie fuera de base y sin estructuras propias vivas. Revisar `ResolveRally`. |
| "Ping-pong avanzar/reagrupar en el borde del radio" | Subir `WP_COMMIT` o `GROUP_RADIUS` (la histéresis actual es solo del lado avance). |
| "No inicia pelea ni con ventaja" | HOLD FIRE: con humanos vivos en el equipo, SIEMPRE espera a que un humano enganche (pedido del usuario). Sin humanos, exige superioridad local. |
| "Va al carril equivocado en el push" | `GetMajorityLane` (mayoría por signo de Y de los héroes fuera de base; 0 = empate = carril propio). |

### Encierro / no puede desplazarse (→ IA_Breakout.j)

Sistema en 3 capas + Berserker. Mensajes en la **columna de texttags** flotando sobre la cabeza del bot (ver "Cómo leer los mensajes de debug" más abajo):

| Mensaje | Capa | Qué pasó |
|---|---|---|
| `Despeje (2-hit)` | 1 | Huyendo, mató/está matando un creep que **tapa de verdad** el corredor a casa (CHANGE B: `|perp| <= CORRIDOR_HALF` de la línea recta bot→casa, no un cono ancho) y está **ANCLADO** (CHANGE A: con objetivo físico vivo o quieto — NO por la orden) porque lo tumba en ≤2 golpes. Un creep que MARCHA/circula se ignora (se aparta solo): así no mata la oleada entera uno por uno ni persigue al que esquiva. NO incrementa el contador de reincidencias. |
| `Despeje persec (2-hit)` | 1b | **Melee** persiguiendo un HÉROE enemigo fuera de rango (decisión de Think): derribó un creep **anclado que tapaba** la línea de contacto (mismo test corredor+anclado) porque cae en ≤2 golpes. Si es más duro, NO fuerza: deja que el motor rodee. NUNCA dispara Capa 2 ni berserker. |
| `STK-cmb d=.. o=.. T=dist/range M=0/1` | debug | Instante en que la Capa 2 (combate) detectó "atascado". `d`=desplazamiento real, `o`=orden, `T`=dist al target físico/`myRange`, `M`=melee. **No** sale al perseguir un héroe (esa rama ya no usa Capa 2). |
| `STK-fle prog=.. dt=.. dH=.. o=..` | debug | Igual pero en huida (métrica acercamiento a casa). |
| `Encerrado! Rompiendo c1` / `c2` | 2 | Atascado de verdad: detectó "quería moverse y no se desplazó" (acercamiento a casa X+Y si huye, euclídeo si no). c1 / c2 = nº de ciclo consecutivo (ventana de 2s). |
| `Encierro: camino libre` | 2 | **CHANGE C**: un breakout de huida ACTIVO se SOLTÓ porque el bloqueador se apartó y el corredor recto a casa (`CORRIDOR_LOOK`×`CORRIDOR_HALF`) quedó despejado — sin esperar a matar a la víctima. Evidencia positiva (estructuras + unidades ancladas + muestras de terreno). Si era falso (el motor igual no pasa en diagonal), la re-detección en cadena (1.9s) re-dispara. No aplica en berserker. |
| `BRK-DIVE dp=.. c<ciclo>` / `BSK-DIVE dp=..` | 2/3 | **Bug abierto:** el breakout/berserker eligió un HÉROE enemigo en zona de veto de asedio (no consultan el veto). `dp`=profundidad del bot más allá del frente. Ver bullet del veto en "Selección de objetivo". |
| `Entrando BERSERKER` | 3 | 3er encierro dentro de la ventana de 2s. Acepta su muerte. |
| `Berserker -> Héroe` / `-> Invocación` / `(creep)` | 3 | En berserker, atacando al objetivo prioritizado (héroe en mi rango con presión aliada o menor golpes-para-matar, invocación, o creep para seguir escapando). |
| `Berserker OFF (HP)` / `(escape)` / `(kill)` | 3 | Salió del modo: recuperó >70% HP, se alejó ≥600, o mató al objetivo. |
| `FUENTE! Escapando (Survival)` | guardia | Quedó dentro de fuente enemiga estando en Survival. Sale radial antes de cualquier otra cosa. |
| `Soltando fuente` | guardia | Ya salió del margen de la fuente enemiga pero sigue en la VENTANA DE COMMIT (`FOUNTAIN_ESCAPE_COMMIT`, 1.2s): se aleja hacia su casa para no rebotar contra el borde. Rompe el ping-pong `Avanzando`<->`FUENTE! Escapando` (y el falso Berserker que generaba). |

Síntomas comunes y dónde tocar:

- **"Se queda bailando en el sitio rodeado y lo matan sin reaccionar"** → es `IABreakout_Try`. Si en la columna de debug no aparece ningún mensaje de encierro, falló la DETECCIÓN: revisar `STUCK_TIME` / `MOVE_EPS` (combate) o `X_STUCK_TIME` / `X_PROGRESS_EPS` (huida). Si aparece "Rompiendo" pero la víctima es la equivocada → tier/cono en el scoring del ring scan.
- **"Mata creeps cuando no debería (interrumpe farmeo / persecución)"** → revisar `wantsToMove` en el caller (`ExecuteLaning`). Un melee con `attackTarget` en rango NO debe disparar breakout.
- **"Dice Encerrado/entra berserker estando quieto atacando o persiguiendo un héroe que retrocede"** → NO es un encierro real. Hay DOS causas (ambas resueltas en `ExecuteLaning`):
  - *Persiguiendo un HÉROE fuera de rango* (decisión del sistema de puntaje en `Think`): EXCLUIDO de la Capa 2 (rama `IsUnitType(attackTarget, HERO)`). El melee usa `IABreakout_TryChaseClear` (≤2 golpes) y, si no, el motor rodea.
  - *Atacando un CREEP en rango real* (melee `STK-cmb T=181/128 M=1`, rango `T=659/600 M=0`): `GetDistanceUnits` es centro-a-centro y supera el rango crudo por la colisión del objetivo (sobrepaso ~30-60, depende del tamaño del creep, NO del atacante). Lo cubre `ATTACK_REACH_SLACK` (100.0) sumado a `myRange` en el `wantsToMove` del breakout, **igual para melee y rango**. Si un creep enorme aún lo dispara, subir el slack. NO cambiar `inAttackRange` de la FSM (afecta last-hit/timing).
- **"Se queda pegado a la víctima y no retoma la huida"** → salidas de `Try`: `FREE_DIST`, muerte de víctima, `BREAKOUT_TIMEOUT`. El breakout NUNCA escribe `lastTarget`/`isRetreating`: al salir, la lógica normal recalcula sola.
- **"Huyendo, rodea un creep que podría matar de 2 golpes"** → es Capa 1 (`TryPathClear`). Verificar `MAX_HITS_INLINE`, el ancho de corredor `CORRIDOR_HALF` y que el creep esté ANCLADO (`IsCreepAnchored`: objetivo físico o quieto). Un creep que marcha/circula se ignora a propósito.
- **"Huyendo, mata creeps de la oleada uno por uno / persigue al creep que esquiva"** → era el bug del cono+orden (toda la oleada attack-move salía como muro). ARREGLADO (CHANGE A/B): sólo despeja creeps ANCLADOS que TAPAN el corredor recto. Si reaparece: revisar que el aggro-tracker (key 1) registre el objetivo físico de los creeps y el ancho `CORRIDOR_HALF`.
- **"Encerrado, el creep se apartó pero el bot sigue matándolo"** → CHANGE C: `IsCorridorClearToHome` debería soltar (`Encierro: camino libre`). Si no suelta: o hay otra unidad anclada/estructura en el corredor, o el corredor es demasiado largo/ancho — calibrar `CORRIDOR_LOOK`/`CORRIDOR_HALF`. Sólo aplica en HUIDA (`isRetreating`) y fuera de berserker.
- **"Huyendo, contra un creep gordo no avanza nunca"** → el escalado a Capa 2 ocurre cuando `X_STUCK_TIME` (4s) sin acercarse a casa (distancia X+Y); ahí ya ignora el límite de 2 golpes.
- **"Entra en Berserker cuando no debería"** → ventana `CYCLE_WINDOW` (2s). Si el bot encadena 3 atascos dentro de 2s entre cada uno, entra. Para hacerlo más estricto, ajustar `CYCLE_WINDOW` a la baja o aumentar `BERSERK_HP_EXIT`.
- **"En Berserker ataca al héroe equivocado"** → orden de prioridad en `SelectBerserkTarget`: (1) tally de presión aliada en rango, (2) menor hits-to-kill en rango, (3) invocación en rango, (4) null → fallback creep.
- **"Resucita en Berserker"** → fallo del reset en `Bot.update()` (transición `wasDead` → vivo llama `IABreakout_ResetOnRevive`).

### Control manual del humano sobre el bot (casts compartidos) (→ IA_Breakout.j, gate `TryManualCastYield`)

Los bots comparten control a sus aliados HUMANOS; cuando el humano ordena un hechizo del bot, el gate (primera prioridad de `Bot.update()`) cede frames para que la FSM no pise el cast.

**Bug histórico clave (2026-06-11, CONFIRMADO):** los casts manuales se ignoraban **solo en bots TAKEOVER** (héroe de leaver tomado por la IA tras el voto). Un leaver **conserva `controller == USER`** (su slot pasa a `LEFT`), así que el viejo guard `GetPlayerController == MAP_CONTROL_COMPUTER` nunca armaba el latch → la rama IA-cancel mataba el cast con `stop` (Cohetes de Dispersión/Fábrica de Bolsillo nunca salían; Robo Goblin "funcionaba" porque la metamorfosis se consuma antes del stop). En bots de lobby todo andaba. **Regla general: para identificar "es un bot" usar `brain.isBotHero` (lo escribe `Bot.create`), JAMÁS el controller; para "es un humano" exigir `controller USER` + `slot PLAYING`.** Misma familia corregida en: cesión de paso (`OnAllyAttack`), censo de humanos del War Party (`UpdateWarPartyCache`) y tally de foco humano (`Think`).

Además, el gate es **dirigido por eventos** (defensa en profundidad: no confía solo en `GetUnitCurrentOrder`, cuya firma puede variar por habilidad). Señales, en orden: **(a)** `humanCastChanneling` (entre `SPELL_CHANNEL` y `SPELL_ENDCAST`), **(b)** orden actual fuera del vocabulario IA (con latch cede / sin latch cancela auto-cast con stop), **(c)** ventana `humanCastPendingUntil` entre la orden emitida y el arranque real (`MANUAL_CAST_PENDING`, 3s), **(d)** gracia post-cast (`MANUAL_CAST_GRACE`, 0.6s).

Debug en DOS lugares: texttags sobre el héroe (por-tick) y **líneas de chat `[MCAST]`** a la izquierda (transiciones; apagar con `MANUAL_CAST_CHAT_DEBUG`):

| Mensaje | Dónde | Qué pasó |
|---|---|---|
| `[MCAST] ... ISSUE ord=.. (cur=..)` | chat | Se emitió una orden de hechizo sobre el bot (humano o auto-cast del motor: indistinguibles). Arma latch + ventana pendiente. |
| `[MCAST] ... CHANNEL <habilidad>` | chat | El cast ARRANCÓ de verdad (evento del motor). Desde aquí la cesión es a prueba de firmas de orden raras. |
| `[MCAST] ... ENDCAST <habilidad>` | chat | El cast terminó (completado o roto). Se suelta todo y queda la gracia de 0.6s. |
| `[MCAST] ... PEND venció sin CHANNEL (cur=..)` | chat | **El diagnóstico clave:** hubo orden de hechizo pero el cast nunca arrancó en 3s. La orden murió: sin maná, target inválido, pathing imposible, o la pisó una orden externa. |
| `[MCAST] ... protección cancelada por orden externa '..'` | chat | Mientras se protegía un cast llegó una orden del vocabulario IA que NO emitió la FSM (la FSM calla durante la cesión): el humano canceló a mano, o **otro sistema del mapa ordenó al héroe** (sospechar de EXTRAS/triggers legacy). |
| `MCAST canal` | texttag | Cediendo por canalización confirmada (señal a). |
| `MCAST humano` | texttag | Cediendo por orden de hechizo publicada como orden actual (señal b). |
| `MCAST pend` | texttag | Cediendo por ventana ISSUE→CHANNEL (señal c): la habilidad no publica su orden o el héroe gira/camina a rango. |
| `MCAST IA-cancel` | texttag | Hechizo como orden actual SIN orden emitida previa: se cancela con stop. |

Síntomas comunes y dónde tocar:

- **"Lanzo una habilidad del bot y la ignora / nunca sale"** → primero: ¿es un bot **takeover**? Si en los texttags sale `MCAST IA-cancel` con tus casts, la identidad de bot falló (el latch no se armó — revisar `IsBotHero`/`brain.isBotHero`; fue la causa confirmada del bug del Hojalatero). Después mirar el chat: si hay `ISSUE` pero ni `CHANNEL` ni `PEND venció` → imposible (la ventana cubre ese hueco); si hay `PEND venció` → la orden murió antes de arrancar (maná/target/pathing o orden externa: ver línea de cancelación); si NO hay `ISSUE` → el evento de orden nunca llegó (¿error de maná/cooldown del lado del jugador? El motor no emite la orden en esos casos). Si el cast necesita caminar >3s con una habilidad que no publica su orden, subir `MANUAL_CAST_PENDING`.
- **"El bot se congela unos segundos tras ordenarle un hechizo que no salió"** → es la ventana pendiente esperando un `CHANNEL` que no llega (hasta `MANUAL_CAST_PENDING`, 3s). Bajar el dial si molesta.
- **"El bot se lanza hechizos solo"** → auto-cast del motor del jugador computadora (IA de unidad nativa, destapada al permitir aprender habilidades). El latch NO lo distingue del humano (refutado en juego); opción `PauseCompAI` quedó pendiente de probar. Ver memoria `control-humano-bots-cast-yield`.
- **"Falso Encerrado/Berserker después de un cast manual"** → cada frame cedido debe pasar por `NotifyManualControlInternal` (resetea breakout/berserker + refs de progreso). Si reaparece, alguna rama nueva del gate cede sin llamarlo.

### Ejecución / movimiento (→ `ExecuteLaning()` FSM en IA_State_Laning.j)
- **"Tiembla / Parkinson / cancela su propio ataque"** → COMPUERTA DE RANGO
  (`inAttackRange`) y las fases WINDUP / BACKSWING / PRE-ATAQUE (`windupEnd`,
  `cooldownEnd`, `TURN_TIME_MARGIN`). **OJO (Falla D):** `TURN_TIME_MARGIN` (0.25)
  se aplica **SOLO a `windupEnd`** (ahí protege el disparo de un kite prematuro). NO
  va en `cooldownEnd`: era un valor PLANO sumado a un cooldown que **encoge** con la
  velocidad de disparo (`dynamicCooldown = baseCD/mod`, hasta `/5` a +400%), así que a
  máx. velocidad casi duplicaba el cooldown (~40% menos DPS). El re-disparo lo gobierna
  el cooldown REAL. Hay un debug temporal en el paso PRE-ATAQUE — `CD r=.. ef=.. ms` —
  que muestra cooldown real (`r`) vs efectivo del gate (`ef`): **deben coincidir**.
  Si vuelve a divergir (`ef` >> `r`), alguien volvió a sumar un margen al re-disparo.
- **"No patea (kite) bien / melee intenta kitear"** → bloque BACKSWING / ORB WALKING
  (la rama `not amIMelee` del kite). El kite **solo aplica a rango y solo contra un
  HÉROE ENEMIGO a ≤ 0.5·rango**: retrocede ordenando `move` a la **fuente propia más
  cercana** (`GetClosestHomeX/Y`) y deja **rutear al motor** (igual que el de-aggro),
  no a un punto proyectado. Contra creeps/torres NO kitea: hace `Hold` (stop) y
  conserva DPS/last-hit (el aggro de creeps lo cubre el de-aggro). Debug en la
  columna: `bsw Kite-casa` (retrocede a su fuente), `bsw Hold` (quieto disparando),
  `bsw Seguir` (héroe fuera de rango: lo persigue). El desplazamiento del kite queda
  acotado por la ventana de backswing (al llegar `cooldownEnd` vuelve a disparar), así
  que ya no hay hop fijo de 300 que sobrepasara el rango ni cayera sobre montaña/tienda
  clavando al bot. **Tuning:** la agresividad del kite se controla por el umbral
  `0.5·myRange` (subirlo = kitea desde más lejos) en la condición del bloque.
- **"No avanza cuando no hay enemigos"** → ramas "SIN OBJETIVOS CERCANOS: AVANZAR".

### Carril pasivo (melee sin su 1ª armadura) (→ IA_State_Laning.j)

Un **melee cuerpo a cuerpo** juega **pasivo hasta conseguir su 1ª armadura**: no
farmea/harasea/persigue (se apaga todo el Utility-AI ofensivo), solo se coloca
**tras la línea de creeps aliados** y **MANTIENE posición** (`holdposition`). Al
conseguir la armadura, el **cerrojo** `brain.armorGateOpen` se abre y el sistema
se **desactiva por completo y para siempre** (no se re-evalúa ni aunque pierda la
armadura, ni tras revive): el héroe vuelve a la FSM normal como si esto no
existiera. Mensajes en la columna (todos `Pasivo:`):

| Mensaje | Qué pasó |
|---|---|
| `Pasivo: tras creep` | Viajando (con **`move`**, no attack-move: no auto-ataca de camino) a `PASSIVE_BEHIND` (=400) detrás del creep aliado **enganchado más rezagado** de su carril. "Enganchado" = tiene **objetivo físico vivo enemigo** (`IAUtils_GetUnitPhysicalTarget`), o sea está golpeando a alguien — NO basta la orden, porque los creeps marchan con attack-move (un recién aparecido que solo se desplaza se ignora hasta que ataque). |
| `Pasivo: a F3` | Aún no hay creeps en combate (early / takeover muy temprano): viaja a su **Fase 3 propia** a esperar junto a sus torres (`IABrainMacro_ResolveOwnDefense`). |
| `Pasivo: mantener (tras línea)` / `(F3)` | Llegó: `holdposition`. No se desplaza por nada (no abandona el puesto para farmear/perseguir); puede dar un golpe de auto-defensa en rango, pero no se mueve. |

Síntomas y dónde tocar (todo en `IA_State_Laning.j`, salvo nota):

- **"Un melee con armadura sigue pasivo / no ataca"** → el cerrojo no se abrió.
  Revisar `IABuildProgress_HasFirstArmor` (rawcodes de armadura base+súper) y que
  `passiveActive = amIMelee and not brain.armorGateOpen` se publique en la pizarra.
- **"Un héroe a distancia se quedó pasivo"** → no debería: `passiveActive` exige
  `amIMelee` (rango<150). Revisar el rango registrado en `IA_Data.j`.
- **"Se para muy lejos / muy cerca de la línea"** → `PASSIVE_BEHIND` (400) y la
  banda de histéresis `PASSIVE_ARRIVE_DIST` (150, llegó→hold) / `PASSIVE_UNPARK_DIST`
  (350, se alejó→re-seguir).
- **"No detecta la línea desde su F3 / se queda en F3 con combate cerca"** → subir
  `PASSIVE_SCAN_RADIUS` (2200). "Enganchado" = el creep tiene objetivo físico vivo
  enemigo (`IAUtils_GetUnitPhysicalTarget`), NO la orden (los creeps marchan con
  attack-move; "orden != move" daba falsos positivos con los recién aparecidos).
- **"Sigue a los creeps recién aparecidos en vez de quedarse tras los que pelean"**
  → era exactamente el bug de usar la orden; ya se usa el objetivo físico. Si
  reaparece, verificar que el aggro-tracker (IA_Utils, key 1) registre a los creeps
  del bando aliado (debe, ya lo usa el de-aggro para contar daño de creeps).
- **"Tiembla siguiendo a los creeps"** → `PASSIVE_REISSUE_EPS` (120): solo re-emite
  `move` si el destino se movió más que eso. Subirlo = re-rutea menos.
- **"Dice Encerrado estando quieto tras la línea"** → en `ExecuteLaning`, el gate de
  breakout fija `wantsToMove = not brain.passiveParked` para el pasivo; si parado
  dispara breakout, revisar que `passiveParked` se esté seteando (histéresis arriba).
- **De-aggro / Survival / Shopping / Breakout**: funcionan IGUAL que para cualquier
  bot (el pasivo solo reemplaza la FSM de ATAQUE; el `hold` se rompe solo cuando el
  de-aggro/Survival emiten `move` para salvar la vida, y al calmarse re-mantiene).

### Datos del héroe (→ IA_Data.j)
- **"Calcula mal su rango/daño/armadura/velocidad de proyectil"** → registro del héroe
  en `OnInit` (`RegisterHeroStats/Attributes/Dynamics`). Si un héroe se comporta raro
  solo cuando se **transforma**, revisar su forma alternativa (sección Transformaciones).

### Macro / posición / navegación (→ IA_Brain_Macro.j)
- **"Va al carril equivocado"** → `AssignLane` (par→Top, impar→Bot).
- **"Huye hacia el punto equivocado"** → `GetClosestHome*` (base de curación más cercana).
- **"Avanza/empuja al objetivo equivocado, no termina en el castillo"** →
  `UpdateObjective` + `ResolveObjective`: empuje por FASES leyendo el estado del
  anti-backdoor (grupos `AB_*`, booleanos `*_Open`). Orden: F3→F2(propio carril)→
  F3→F2(otro carril, con **reruteo** por la base propia)→F1→F0.
- **"Cruza la base enemiga para cambiar de carril"** → `ApplyRerouteIfNeeded` (manda
  primero a la fuente propia del otro carril; `bm_objIsMove=true` => orden "move").
- **"Se mete a la fuente enemiga / lo mata la torre de la fuente"** → keep-out por
  REGIONES dedicadas `gg_rct_Fuente{Hum,Orc}{Top,Bot}` + `FOUNTAIN_MARGIN` (colchón
  de reacción). DOS capas, ambas en IA_Brain_Macro.j:
  - `IsInEnemyFountain` → en `Think()`: no **targetea** unidades dentro de la fuente.
  - `GetFountainEscape` → guardia de **máxima prioridad** al inicio de
    `ExecuteLaning()`: si el bot entró/roza la zona, aborta todo y emite "move"
    radial hacia afuera ("FUENTE! Escapando"). Es el único veto físico de entrada.
    Tras rebotar, deja una **ventana de histéresis** (`FOUNTAIN_ESCAPE_COMMIT`,
    1.2s, en `brain.fountainEscapeUntil`) durante la cual el bot sigue alejándose
    hacia su CASA propia ("Soltando fuente") aunque ya esté fuera del margen, para
    que el macro (`IssueAdvance`) no lo re-arrastre al borde. Sin esto se producía
    el bucle `Avanzando`<->`FUENTE! Escapando` + falso Berserker cuando un héroe
    enemigo se refugiaba en su fuente (el bot ya lo excluye del scoring vía
    `IsInEnemyFountain`, así que NO es un problema de puntaje: es físico).
    **"Síntoma: el bot rebota/baila en el borde de la fuente enemiga y entra en
    Berserker"** → es esto; ajustar `FOUNTAIN_ESCAPE_COMMIT` (subir si aún rebota).
  Si el bot se niega a atacar una torre legítima cercana, **reducir `FOUNTAIN_MARGIN`**
  o achicar la región en el Editor. El castillo/fortaleza (objetivo central) NO usa
  región: sale de `AB_*_F0` (anti-backdoor) vía `UpdateObjective`/`GetEnemyBase*`.

### Arranque / quién recibe IA (→ IA_Core.j / IA_Arrancar.j / IA_Permisos.j)
- **"Un slot no recibe bot / bot no arranca"** → `InitializeBots` (itera slots 0-15,
  `MAP_CONTROL_COMPUTER`).
- **"El bot no piensa estando vivo"** → `Bot.update()` (selector estricto de estados).

---

## Cómo reportar un problema (plantilla)

Para localizar rápido y arreglar sin romper, describir:

> El **modo de juego no importa** para los bots: el oro es solo economía (compras
> ya resueltas), la selección de héroe (All Pick/Random) no cambia el cerebro, y el
> modo aleatorio de habilidades **no tiene bots**. No hace falta mencionarlo.

1. **Quién**: nombre del héroe y si es **melee o rango** (cambia toda la lógica).
2. **Qué hizo** (observado) vs **qué debería haber hecho** (esperado).
3. **Contexto**: ¿había aliados/enemigos cerca?, ¿estaba a poca vida?, ¿perseguía o
   farmeaba?, ¿torres cerca?
5. Si se puede, qué decían los últimos mensajes en la **columna de debug**
   sobre la cabeza del bot (Caza Letal / Orb Walk / De-Aggro / Volviendo al
   Farm / Avanzando…) — eso dice en qué rama de la FSM estaba. Para verlos:
   ver sección siguiente.

Con eso se va directo a la fila correcta del mapa de arriba.

---

## Cómo leer los mensajes de debug (texttags apilados sobre el héroe)

Cada bot emite mensajes vía `IAUtils_DebugMsg(unit, string)` desde su `Think()`,
FSM, breakout, survival y shopping. Esos mensajes aparecen como una **columna
vertical de text tags flotando sobre la cabeza del bot**, y la columna sigue
al héroe mientras se mueve (no se quedan flotando en el aire donde nacieron).

**Layout:** slot 0 (el más nuevo) arriba; slot N-1 (el más viejo) abajo.
Cuando llega un mensaje nuevo, los anteriores bajan una fila para hacerle hueco
en la cima.

**No usamos multiboard** porque WC3 1.27 sólo muestra UNA multiboard a la vez,
y el slot ya lo ocupa la tabla de kills/muertes/asistencias.

**Reglas del buffer** (en `IA_Utils.j` → `IA_DEBUG_MAX` / `IA_DEBUG_TTL`):

Un mensaje **solo** desaparece por una de estas dos vías (nunca antes):

1. **Máximo 15 mensajes** simultáneos por bot. Si llega el 16°, el más viejo
   (último de la columna) se destruye y el resto baja una fila.
2. **TTL 10 segundos** por mensaje. Al cumplirse, el tag se destruye y los
   mensajes más nuevos que estaban arriba bajan a cubrir el hueco. (Barrido
   cada 0.10s.)

**Contador de repeticiones "xN" (anti-spam).** Todo mensaje se muestra con un
contador a la izquierda: `x1 Avanzando…`. Si el **mismo** texto se vuelve a
emitir y sigue siendo el más nuevo (slot 0), **no se crea línea nueva**: solo
sube el contador (`x2`, `x3`, … `x12`) y se **refresca su TTL**. Así un mensaje
que se dispara 12 veces seguidas ocupa **una sola línea** en vez de tapar la
columna. Solo coalesce contra el slot 0: si entre dos repeticiones aparece un
mensaje distinto, la siguiente repetición arranca una línea nueva (`x1`).
Implementado de forma central en `DebugBufferPush` (`IA_Utils.j`), así que
**aplica automáticamente a TODOS los mensajes** que pasan por `DebugMsg` —
presentes y futuros. No hay que hacer nada especial al crear un mensaje nuevo:
pásalo crudo a `IAUtils_DebugMsg(unit, "texto")` y el `xN` se gestiona solo.
> Matiz del TTL: al refrescarse en cada repetición, los 10 s se miden desde la
> **última** aparición. Un mensaje que deja de repetirse expira 10 s después de
> su último disparo; mientras se siga repitiendo, permanece vivo. Las dos vías
> de desaparición de arriba se respetan igual.

**Ajustes visuales** (constantes en `IA_Utils.j`):

| Constante | Default | Qué controla |
|---|---|---|
| `IA_DEBUG_OFFSET_X` | `0.0` | Desplazamiento horizontal respecto al héroe. `+X` = derecha, `-X` = izquierda, `0` = encima. |
| `IA_DEBUG_BASE_Z` | `280.0` | Altura del tag más nuevo (cima de la columna). |
| `IA_DEBUG_ROW_Z` | `28.0` | Separación vertical entre filas. |
| `IA_DEBUG_TEXT_SZ` | `0.014` | Tamaño del texto. **Importante:** WC3 1.27 **parte (wrap)** un texttag demasiado largo en 2 renglones; el 2º renglón **pierde el prefijo `xN`** (va solo al inicio del string) y se **solapa** con el slot de abajo. Texto más pequeño = más caracteres por renglón = no se parte. Si ves un mensaje partido en dos, baja este valor o acorta ese mensaje. |

**Limitaciones a tener en cuenta:**

- Si dos bots están muy juntos, sus columnas pueden solaparse entre sí. Mover
  la cámara o seleccionar otra zona ayuda. Si molesta mucho, alternar
  `IA_DEBUG_OFFSET_X` con un valor positivo (p.ej. `64.0`) los desplaza a la
  derecha del modelo y separa visualmente.
- Hay un cap interno de text tags vivos en WC3 (~100). Con muchos bots × 15 tags
  se puede superar el límite teórico (el contador `xN` ayuda mucho a no llegar,
  porque las ráfagas repetidas ya no crean tags nuevos). Si aparecen mensajes
  "fantasma" que no se ven, bajar `IA_DEBUG_MAX`.

**Convivencia con `UpdateToleranceTag`:** el porcentaje verde sobre la cabeza
del bot (sistema de tolerancia) sigue funcionando aparte — es un único text
tag actualizado in-place, no entra a la columna ni se solapa con nada.

---

## Invariantes que NO se deben romper (para no generar bugs indirectos)

1. **`Think()` jamás emite una orden.** Solo escribe en `brain`.
2. **Solo `ExecuteLaning()` emite `IssueOrder`.**
3. **Estado táctico del bot → `LaningBrain`** (IA_Blackboard.j). Nunca volver a
   guardar estado en hashtables sueltas ni en el `struct Bot` (ese es solo identidad
   + estado estratégico).
4. **Rendimiento (regla del proyecto):** coordenadas X/Y, nada de `Location` /
   `TriggerSleepAction`; `DestroyGroup` en la misma función; nullear locales `unit`/
   `group` al final.
5. Las **dos capas de retirada** nunca corren el mismo frame (selector estricto en
   `Bot.update()`). No mezclar sus condiciones.
6. **El BREAKOUT (anti-encierro) es transitorio:** jamás escribe `lastTarget`,
   `isRetreating` ni el objetivo de avance. Usa su propio canal
   (`brain.breakoutTarget`) y sale por `FREE_DIST` / muerte de la víctima /
   `BREAKOUT_TIMEOUT`. Así la intención original se recalcula sola al salir.
