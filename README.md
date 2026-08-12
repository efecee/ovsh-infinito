# Orcos vs Humanos Infinito — Editor de Detonadores

Este repositorio contiene una parte del mapa **Orcos vs Humanos Infinito** para *Warcraft III*. No es el mapa completo ni una versión que pueda jugarse por sí sola: muestra los archivos correspondientes al **Editor de Detonadores** (accesible con `F4`) del mapa original.

El mapa original es un único archivo con extensión `.w3x`, llamado `original.w3x`. Dentro de él se almacena el juego completo, incluyendo los detonadores, la edición de objetos, unidades, habilidades, conjuros benéficos y el terreno, entre otros datos. Por lo tanto, para reproducir o editar completamente el mapa es indispensable contar con `original.w3x`; los archivos de este repositorio no son suficientes.

## Alcance de este proyecto

Los archivos aquí presentes pertenecen a la sección **Editor de Detonadores** de `original.w3x` y están escritos en código JASS. Es esta parte la que se publica y se puede consultar en el repositorio.

Sin embargo, incluso esta sección está incompleta. En el archivo original, el Editor de Detonadores contiene siete carpetas:

- `SISTEMA_IA`
- `SISTEMA_CORE`
- `HEROES_PICK`
- `CUSTOM_SKILLS`
- `COMBINACION_OBJETOS`
- `EXTRAS`
- `init`

La carpeta `HEROES_PICK` no está incluida en este proyecto. Además, `COMBINACION_OBJETOS` existe aquí, pero solo incluye algunos detonadores: en el mapa original contiene más detonadores de objetos.

Los detonadores omitidos fueron creados en **GUI** (la interfaz gráfica del editor de Warcraft), no en JASS. Por esa razón no se trasladaron a este repositorio, aunque sí permanecen dentro de `original.w3x`.

## Lo que no incluye

Para reconstruir el mapa completo también harían falta los datos y las ediciones del Editor de Objetos —incluidas unidades, habilidades y conjuros benéficos—, así como la información del Editor de Terreno y el propio archivo del mapa. Esa información no se comparte en este repositorio.

En resumen, este proyecto es una referencia parcial del Editor de Detonadores de **Orcos vs Humanos Infinito**, centrada en los detonadores disponibles en JASS, y no una copia completa ni ejecutable del mapa.
