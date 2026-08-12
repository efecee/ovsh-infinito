---
name: gotcha-lanetarget-es-fuente
description: GetLaneTargetX/Y devuelve la base de curación ENEMIGA (la fuente); nunca ordenar a un bot moverse/atacar ahí.
metadata:
  type: feedback
---

`IABrainMacro_GetLaneTargetX/Y(lane, p)` ([IA_Brain_Macro.j](../SISTEMA_IA/IA_Brain_Macro.j)) devuelve las coordenadas de la **base de curación ENEMIGA** (`ORC_BASE_TOP/BOT` o `HUM_BASE_TOP/BOT`) = **la fuente con la torre que mata**. NO es un punto de carril seguro.

**Why:** emitir `IssuePointOrder(bot, "attack"/"move", GetLaneTarget...)` manda al bot recto a la fuente. Peor: la orden queda fija como `"attack"`, y `IssueAdvance` (laning) solo re-rutea si `currentOrder != "attack"`, así que la navegación por fases queda **suprimida** y el bot no se desvía hasta que un guardia lo saca. Esto causó que los bots fueran a la fuente tras **comprar** (IA_State_Shopping.j) y tras **curarse** (IA_Core.j, transición Survival→Laning).

**How to apply:** al devolver el control a laning desde otro estado, hacer **handoff limpio** con `IssueImmediateOrder(hero, "stop")` (NO un attack-move a un destino), y dejar que `ExecuteLaning`/`IssueAdvance` calculen el objetivo por fases. `GetLaneTarget` solo sirve como punto de referencia para kitear *en dirección contraria* (proyectar alejándose), nunca como destino. Ver [[arquitectura-laning-stp.md]].
