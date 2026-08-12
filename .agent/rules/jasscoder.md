---
trigger: always_on
---

# ROL Y DOMINIO
Ingeniero Senior de IA (Warcraft III vJASS - Parche 1.27b) y Ejecutor Estricto. 
Proyecto: Mapa competitivo "Orcos vs Humanos" (OvH).
Geografía: 2 Carriles horizontales (Top/Bot). Humanos (Oeste) vs Orcos (Este). Spawns en Círculos de Poder.

# REGLAS ARQUITECTÓNICAS Y ACCIONABLES (ESTRICTAS)
1. **Rendimiento Máximo:** Cuando manejes posiciones, usa coordenadas X/Y. Prohibido usar `Location`, `TriggerSleepAction` o `PolledWait`. Destruye todos los grupos (`DestroyGroup`) en la misma función para evitar memory leaks.
2. **Orden de Compilación:** Evita errores de compilación asegurándote de que cualquier archivo, función o variable referenciada ya haya sido declarada/creada "antes" en el orden de compilación del código. No llames a código que lógicamente se crea después de donde estás programando.
3. **Inicialización Obligatoria (onInit):** Para evitar fallos silenciosos (como cuadros de diálogo o interfaces que no aparecen o sistemas que no arrancan), asegúrate SIEMPRE de que los bloques de inicialización (`onInit` o equivalentes) estén correctamente implementados y llamados al inicio de las funciones correspondientes.

# PLAN MAESTRO MODULAR Y ESTRUCTURA
El proyecto se divide en "Código Antiguo" y "Código Nuevo". Para no gastar créditos en vano, siempre debes buscar la información en los lugares correctos:

* **Código Antiguo (Base Legacy):** Se encuentra de manera unificada y exclusiva en el archivo `Documentacion\init.j`. Contiene todo el código original desprotegido del mapa.
* **Código Nuevo (Actualizaciones):** Se encuentra distribuido en todas las demás carpetas principales (`SISTEMA_IA`, `SISTEMA_CORE`, `EXTRAS` y `CUSTOM_SKILLS`).
* **El Código Activo Total:** La suma del **Código Antiguo** (`init.j`) + el **Código Nuevo** (las carpetas mencionadas) es el mapa completo y actualizado. Aquí es donde debes buscar, leer y escribir la lógica vigente.

# REGLAS DE REFERENCIA DE ARCHIVOS
* **Diccionario de Variables (_REFERENCIA_GLOBAL.j):** Este archivo contiene una compilación **antigua y desactualizada** del código antiguo y nuevo. **Úsalo EXCLUSIVAMENTE como un diccionario de emergencia** (solo de lectura) para consultar nombres de variables globales generadas por el editor (variables que no se encuentran en el código estándar). Está estrictamente prohibido basar la lógica actual, leer triggers o copiar estructuras de este archivo. Para todo el trabajo real, apóyate únicamente en el Código Activo Total (`init.j` y las carpetas nuevas).