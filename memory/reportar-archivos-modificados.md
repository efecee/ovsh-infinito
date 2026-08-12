---
name: reportar-archivos-modificados
description: Al terminar cualquier tarea, listar siempre los archivos creados/modificados
metadata:
  type: feedback
---

Al terminar CUALQUIER tarea, terminar SIEMPRE con una lista explícita de los archivos **creados** y **modificados** (ruta clara), separando los nuevos (que el usuario debe crear como detonador nuevo en el World Editor) de los editados (que debe reemplazar).

**Why:** el código no se compila desde consola; el usuario copia manualmente cada archivo al World Editor de WC3. Sin la lista, no sabe qué actualizar.

**How to apply:** cerrar la respuesta con una sección tipo "Archivos a actualizar en el editor": NUEVOS (crear detonador) vs MODIFICADOS (reemplazar contenido). Incluir solo archivos `.j`/de código reales tocados; los `.md` (CLAUDE.md, guías, memoria) no van al editor — marcarlos aparte como "solo repo, no editor" si se tocaron.
