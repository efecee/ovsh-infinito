---
name: arquitectura-laning-stp
description: Convención de arquitectura del comportamiento de carril de los bots (Sense-Think-Act + pizarra)
metadata:
  type: project
---

El comportamiento de carril (IA_State_Laning) se refactorizó (2026-05-27) al patrón **SENTIR → PENSAR → ACTUAR** con pizarra (blackboard) tipada.

- `IA_Blackboard.j` define `struct LaningBrain` (una por bot, vía hashtable por GetHandleId). Reemplazó las 9 "claves mágicas" de la antigua hashtable `IA_Laning_Memory` (ya eliminada). Campos PERSISTENTES (memoria entre ciclos) vs SCRATCH (decisión del frame, reseteados con `IABlackboard_ResetBrainScratch`).
- `Think()` (privada) = SENTIR+PENSAR: escanea, puntúa objetivos (Utility AI), tolerancia/decay, y **NO emite ninguna orden**. Solo escribe la decisión en `brain`.
- `IAStateLaning_ExecuteLaning()` = ACTUAR: **único lugar autorizado a emitir IssueOrder**. Lee `brain.*`.

**Why:** el monolito de 770 líneas acoplaba percepción+decisión+órdenes, causando bugs en cascada al editar. La separación permite tocar scoring sin tocar la FSM.

**How to apply:** todo estado táctico nuevo del bot va como campo en `LaningBrain`, NUNCA en hashtables sueltas ni en el `struct Bot` de IACore (ese solo guarda identidad/estado estratégico). Cualquier `IssueOrder` nuevo va en la fase ACTUAR, no en Think.

Dos capas de retirada distintas (no confundir): ESTRATÉGICA = estado 3 Survival (HP<35%, ir a curarse); TÁCTICA/de-aggro = dentro de Laning (soltar aggro sin dejar el carril). El selector estricto de IACore garantiza una sola por frame.

Tabla de peligrosidad `(d)`: `IAData_GetHeroDanger(typeId)` (default 1.0 neutro) modula `safetyPenalty` de héroes enemigos en Think. Es **infraestructura sin poblar**: el usuario debe rellenar `RegisterHeroDanger(...)` en `IA_Data.j` con su conocimiento de balance.

Guía de depuración: `SISTEMA_IA/GUIA_DEBUG_BOTS.md` (mapa síntoma→ubicación + invariantes). Referenciada desde CLAUDE.md. Leerla antes de arreglar comportamiento de bots.

DECISIÓN (2026-05-27, IMPLEMENTADA): los bots y el **modo aleatorio de habilidades** son mutuamente excluyentes — nunca coexisten, así que no hay que deshabilitar IA dentro del modo. Se bloquean las DOS únicas vías de entrada de bots:
1. Inicio con bots → `MenuHabilidades_MostrarPantalla()` (`Core_Menu_Habilidades.j`) detecta `udg_Core_HayBots`, NO muestra la Pantalla 3 y fuerza Clásico (`modoHabil=1`). La lógica post-selección se extrajo a `EjecutarPostSeleccion()` (reutilizada por OnClick y por la ruta de bots).
2. Encuesta de abandono → `Voto_AbrirVotacion()` (`Sistema_Voto.j`) omite el botón BOT (`Voto_BtnBot=null`) cuando `ModoAl_Activo`, dejando solo DROP y RMK.
`udg_Core_HayBots` se fija a los 0.05s en `Core_DetectarHost.j` (UI), antes de los menús. `ModoAl_Activo` es global no privado de la library `ModoAleatorio`, accesible desde Sistema_Voto sin `requires`.

Aclaración tabla de peligrosidad (d): el daño/tankiness del enemigo YA se diferencia solo vía `IAData_GetHeroEstimatedDamage` dentro de `incomingDamage`. `GetHeroDanger` es SOLO para amenaza oculta (burst/CC de hechizos) que el bot no modela. No meter daño/vida en ese valor.

Separación melee/rango del ACTOR: vía `amIMelee` (myRange<150) en Think; es ortogonal a la peligrosidad del TARGET.

Navegación de empuje (2026-05-27): `IABrainMacro_UpdateObjective(botUnit, lane)` decide el objetivo de avance por FASES leyendo el anti-backdoor (`EXTRAS/Sistema_AntiBackdoor.j`: grupos `AB_HUM/ORC_F*` y booleanos `*_Open`). Orden: F3→F2 propio carril → F3→F2 otro carril (con reruteo por base propia vía `ApplyRerouteIfNeeded`, orden "move") → F1 → F0. Antes el bot avanzaba a `GetLaneTarget` = FUENTE enemiga y se suicidaba en su torre. `GetLaneTarget` se conserva solo como referencia direccional del kite. `IsInEnemyFountain` (keep-out por rect `gg_rct_Base_*` + `FOUNTAIN_MARGIN=256`) se aplica en `Think()` para no targetear unidades dentro de la fuente. **SIN PROBAR en juego** — verificar: que pjass no se queje de los globales `AB_*` (si pasa, reordenar triggers), centroides correctos, y que el keep-out no bloquee torres legítimas (si pasa, bajar `FOUNTAIN_MARGIN`).

Reporte de bugs de bots: el MODO de juego (oro/selección/aleatorio) NO afecta el comportamiento — no mencionarlo. Lo útil: héroe (melee/rango), observado vs esperado, contexto, texttag de debug.

Pendiente del usuario: sistema de aprendizaje de habilidades de los bots en modo NORMAL (asignación manual por nivel; el modo aleatorio queda sin bots).
