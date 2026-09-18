//===========================================================================
// SISTEMA F9 (MENU DE MISIONES / AYUDA)
//===========================================================================
// Centraliza las pestañas ESTATICAS del menu F9.
//
// ESTRUCTURA:
//   IZQUIERDA - "Explicaciones/Extras" (required=true):
//     1. Guia de Jugadores
//     2. Economia
//     3. Sistema de Kick
//     4. v1.0 - Novedades Infinito (version base)
//     5. v1.1
//     6. v1.2
//     7. v1.3
//     8. v1.4
//     9. v1.5
//    10. v1.6
//    11. v1.7
//    12. v1.8
//    13. v1.9
//    14. v2.0
//    15. v2.1 (actual)
//    16. Acerca de
//
//   DERECHA - "Informacion en Vivo" (required=false):
//     1. Registro de Bajas  -> vive en Sistema_Anuncios.j (NO se mueve aqui)
//     2. Comandos
//
// ─────────────────────────────────────────────────────────────────────────
// NOTA DE ACOPLAMIENTO (leer antes de mover logica aqui):
//   La pestaña "Registro de Bajas" NO vive aqui: vive en Sistema_Anuncios.j
//   porque es la superficie de render del kill feed (ring buffer KF_*,
//   alimentado por el evento de muerte de heroes). Mantenerla alli evita una
//   dependencia BIDIRECCIONAL Anuncios<->F9 y el consiguiente riesgo de orden
//   de compilacion. Este archivo crea SOLO pestañas estaticas (sin estado).
//
// ─────────────────────────────────────────────────────────────────────────
// NOTA DE LIMITE (leer antes de agrandar cualquier pestaña):
//   El texto de cada 'quest' tiene un techo practico en WC3 1.27b (~4096
//   caracteres, contando codigos |cff..|r y |n). Pasarse CRASHEA el mapa al
//   final de la carga (~90%), SIN error de compilacion. Por eso el historial
//   de versiones se reparte en UNA PESTAÑA POR VERSION: cada version futura es
//   una pestaña nueva, nunca se acumula todo en un solo string gigante.
//===========================================================================

globals
    // Handles de las pestañas estaticas, por si luego hay que togglearlas/editarlas.
    quest F9_QGuia      = null
    quest F9_QEconomia  = null
    quest F9_QKick      = null
    quest F9_QV10       = null   // v1.0 (Novedades / version base Infinito)
    quest F9_QV11       = null   // v1.1
    quest F9_QV12       = null   // v1.2
    quest F9_QV13       = null   // v1.3
    quest F9_QV14       = null   // v1.4
    quest F9_QV15       = null   // v1.5
    quest F9_QV16       = null   // v1.6
    quest F9_QV17       = null   // v1.7
    quest F9_QV18       = null   // v1.8
    quest F9_QV19       = null   // v1.9
    quest F9_QV20       = null   // v2.0
    quest F9_QV21       = null   // v2.1 (version actual)
    quest F9_QAcerca    = null
    quest F9_QComandos  = null
endglobals

// --- HELPER: crear una pestaña estatica del F9 ---
//   required = true  -> seccion IZQUIERDA del F9 ("Explicaciones/Extras")
//   required = false -> seccion DERECHA del F9  ("Informacion en Vivo")
//   fixedText se muestra arriba como subtitulo y NO se mueve al hacer scroll.
//   desc se muestra abajo, en la zona desplazable.
//   En ambos textos usar "|n" para salto de linea y "|cffRRGGBB ... |r" para color.
//   Si una pestaña no necesita resumen fijo, pasar "" en fixedText.
//   Devuelve el handle (guardarlo solo si luego se va a modificar en runtime).
function F9_CreateTab takes string title, string icon, string fixedText, string desc, boolean required returns quest
    local quest q = CreateQuest()
    local questitem qi = null
    call QuestSetTitle(q, title)
    call QuestSetIconPath(q, icon)
    call QuestSetDescription(q, desc)
    if (fixedText != "") then
        set qi = QuestCreateItem(q)
        call QuestItemSetDescription(qi, fixedText)
        call QuestItemSetCompleted(qi, false)
    endif
    call QuestSetRequired(q, required)   // ubicacion (izquierda/derecha)
    call QuestSetDiscovered(q, true)     // visible desde el inicio
    call QuestSetCompleted(q, false)     // nunca se "completa"
    call QuestSetEnabled(q, true)        // habilitada
    set qi = null
    return q
endfunction

//===========================================================================
function InitTrig_Sistema_F9 takes nothing returns nothing
    local string d = ""

    // ==================================================================
    // ZONA IZQUIERDA: "Explicaciones/Extras" (required = true)
    // Orden de creacion = orden de aparicion (arriba -> abajo)
    // ==================================================================

    // ------------------------------------------------------------------
    // PESTAÑA 1: GUIA DE JUGADORES
    // ------------------------------------------------------------------
    set d = "|cffFFCC00 #    Color                             Equipo|r"
    set d = d + "|n|cffd02222 1     Rojo / Red                   Humanos|r"
    set d = d + "|n|cff2254dd 2    Azul / Blue                  Humanos|r"
    set d = d + "|n|cff1CE6B9 3    Teal / Cian                   Humanos|r"
    set d = d + "|n|cff7134c2 4    Morado / Purple          Humanos|r"
    set d = d + "|n|cffFFFC00 5    Amarillo / Yellow         Humanos|r"
    set d = d + "|n|cffFE8A0E 6    Naranja / Orange        Orcos|r"
    set d = d + "|n|cff20C000 7    Verde / Green              Orcos|r"
    set d = d + "|n|cffE55BB0 8    Rosa / Pink                   Orcos|r"
    set d = d + "|n|cff959697 9    Gris / Grey / Gray        Orcos|r"
    set d = d + "|n|cff7EBFF110    Celeste / Light             Orcos|r"
    set d = d + "|n"
    set d = d + "|nTambien puedes usar el |cffFFCC00inicio del nombre|r."
    set d = d + "|nEj: |cff888888-kick mat|r expulsa a |cff888888MateriaViva|r"
    set F9_QGuia = F9_CreateTab("Guia de Jugadores", "ReplaceableTextures\\CommandButtons\\BTNPeasant.blp", "|cffFFCC00IDENTIFICA A CADA JUGADOR POR SU COLOR, NUMERO O NOMBRE.|r", d, true)

    // ------------------------------------------------------------------
    // PESTAÑA 2: ECONOMIA
    // ------------------------------------------------------------------
    set d = "|cffFFCC00Comando -oro|r"
    set d = d + "|nFormato: |cff888888-oro [jugador] [cantidad|todo]|r"
    set d = d + "|n"
    set d = d + "|n|cffFFCC00Ejemplos:|r"
    set d = d + "|n  |cffFFCC00-oro azul 500|r     Envia 500 de oro al azul (slot 2)."
    set d = d + "|n  |cffFFCC00-oro 2 500|r      Envia 500 de oro al azul (slot 2)."
    set d = d + "|n  |cffFFCC00-oro teal todo|r        Envia TODO tu oro al color teal (slot 3)."
    set d = d + "|n  |cffFFCC00-oro 10 3333|r     Envia 3333 de oro al celeste (slot 10)."
    set d = d + "|n  |cffFFCC00-oro ped 200|r       Envia 200 al jugador 'Pedrito'."
    set d = d + "|n"
    set d = d + "|n|cffFFCC00Comando -madera|r"
    set d = d + "|nFormato: |cff888888-madera [jugador] [cantidad|todo]|r"
    set d = d + "|n"
    set d = d + "|n|cffFFCC00Ejemplos:|r"
    set d = d + "|n  |cffFFCC00-madera 8 555|r      Envia 555 madera al color rosa (slot 8)."
    set d = d + "|n  |cffFFCC00-madera green todo|r  Envia toda tu madera al color verde (slot 7)."
    set d = d + "|n"
    set d = d + "|n|cffFFCC00Pedir oro: -fondo / -f / OK / -ok|r"
    set d = d + "|nCuando te falta oro, abre una colecta para tu equipo."
    set d = d + "|n"
    set d = d + "|n|cffFFCC00Ejemplos:|r"
    set d = d + "|n  |cffFFCC00-fondo 500|r o |cffFFCC00-f 500|r  Pides 500 de oro. A tus aliados les sale el aviso (expira en 20s)."
    set d = d + "|n  |cffFFCC00OK|r o |cffFFCC00-ok|r  Aportas a la colecta activa. Das solo lo que falta; entre varios la completan."
    set d = d + "|n"
    set d = d + "|n|cffFF4444Restricciones:|r"
    set d = d + "|n  - |cffFFCC00OK|r sin guion solo responde durante los 20s de una colecta activa."
    set d = d + "|n  - No puedes enviar recursos a bots."
    set d = d + "|n  - Si pides mas de lo que tienes, envia todo."
    set d = d + "|n  - |cffFFCC00todo|r = envia el 100% de tu recurso actual."
    set d = d + "|n  - El oro donado cuenta para el premio final (el NETO: lo que"
    set d = d + "|n    envias menos lo que recibes; pasarse oro en circulo no suma)."
    set F9_QEconomia = F9_CreateTab("Economia", "ReplaceableTextures\\CommandButtons\\BTNChestOfGold.blp", "|cffFFCC00ENVIA RECURSOS A TUS ALIADOS Y ORGANIZA COLECTAS EN EQUIPO.|r", d, true)

    // ------------------------------------------------------------------
    // PESTAÑA 3: SISTEMA DE KICK
    // ------------------------------------------------------------------
    set d = "|cffFFCC00Comando -kick|r  |cff888888(solo Master)|r"
    set d = d + "|nFormato: |cff888888-kick [jugador]|r"
    set d = d + "|n"
    set d = d + "|n|cffFFCC00Ejemplos:|r"
    set d = d + "|n  |cffFFCC00-kick rojo|r        Expulsa al rojo."
    set d = d + "|n  |cffFFCC00-kick blue|r        Expulsa al azul."
    set d = d + "|n  |cffFFCC00-kick ped|r         Expulsa a 'Pedrito' o el primero cuyo nick inicie asi."
    set d = d + "|n  |cffFFCC00-kick 7|r             Expulsa al slot 7 (verde)."
    set d = d + "|n"
    set d = d + "|n|cffFFCC00Quien es el Master?|r"
    set d = d + "|nEl primer jugador humano (no bot) de arriba"
    set d = d + "|nhacia abajo. Si sale o esta AFK, el rol rota"
    set d = d + "|nautomaticamente al siguiente."
    set d = d + "|n"
    set d = d + "|n|cffFFCC00Sistema de Votacion|r"
    set d = d + "|nCuando alguien abandona o es expulsado:"
    set d = d + "|n"
    set d = d + "|n  |cff00CCFFBOT|r    La IA toma control del heroe."
    set d = d + "|n  |cffFFCC00DROP|r   Items a la base, heroe eliminado."
    set d = d + "|n  |cffFF4444RMK|r    Partida cancelada para todos."
    set d = d + "|n"
    set d = d + "|nCon |cffFFCC00DROP|r/KICK, sus aliados se reparten"
    set d = d + "|n  su |cffFFCC00oro actual|r en partes iguales."
    set d = d + "|n"
    set d = d + "|nSi nadie vota, se aplica |cffFFCC00DROP|r por defecto."
    set d = d + "|nLa votacion se cierra sola a los |cffFFCC008 seg|r."
    set d = d + "|nEl juego se congela durante la votacion."
    set d = d + "|n"
    set d = d + "|n|cffFF4444Restricciones:|r"
    set d = d + "|n  - No puedes auto-expulsarte."
    set d = d + "|n  - Un bot post-voto puede ser re-expulsado."
    set F9_QKick = F9_CreateTab("Sistema de Kick", "ReplaceableTextures\\CommandButtons\\BTNBanish.blp", "|cffFFCC00EXPULSA JUGADORES Y DECIDE QUE HACER ANTE UNA DESCONEXION.|r", d, true)

    // ------------------------------------------------------------------
    // PESTAÑA 4: v1.0 - NOVEDADES OvsH INFINITO (VERSION BASE)
    // (Lo que "Infinito" agrega sobre el OvsH clasico. Cada version
    //  posterior tiene su propia pestaña: v1.1, v1.2, ... v1.5.)
    // ------------------------------------------------------------------
    set d = "|cffFFCC00v1.0 - VERSION BASE (OvsH INFINITO)|r"
    set d = d + "|nTodo lo que |cffFFCC00Infinito|r agrega sobre el OvsH clasico:"
    set d = d + "|n"
    set d = d + "|n- Selección inteligente de Master (anti AFK/Kitter/Rojo)"
    set d = d + "|n- Bots con IA agregados"
    set d = d + "|n- Kick inteligente (color/nombre/numero)"
    set d = d + "|n- Votacion al desconectarse (BOT/DROP/RMK)"
    set d = d + "|n- Asistencias (3 vias: daño, CC, curacion)"
    set d = d + "|n- Sonidos de kills estilo DotA 2"
    set d = d + "|n- Registro en vivo de kills en F9"
    set d = d + "|n- Visualizador de denegaciones"
    set d = d + "|n- HUD de datos en vivo (AS/MS)"
    set d = d + "|n- Anti-backdoor mejorado"
    set d = d + "|n- Animacion de area de efecto"
    set d = d + "|n- Nuevos comandos"
    set d = d + "|n- Victoria/derrota + formula de Score"
    set d = d + "|n- 18 de oro"
    set d = d + "|n- nuevo modo seleccion heroes"
    set d = d + "|n- Modo habilidades aleatorias (con madera)"
    set d = d + "|n- Heroes poco usados mejorados"
    set d = d + "|n- Iconos corregidos"
    set d = d + "|n- Bug de infernal arreglado"
    set d = d + "|n- Bug de fusion de items arreglado"
    set d = d + "|n- Montañas pisables arreglado"
    set d = d + "|n- Daño de torre humana arreglada"
    set d = d + "|n- Nuevas combinaciones de items"
    set d = d + "|n- Nuevo unico: Mano del Rey"
    set d = d + "|n- Nuevo: Sello de Fortificacion"
    set d = d + "|n- Varitas: 9 usos"
    set d = d + "|n- Mensajes de kills mejorados"
    set d = d + "|n- Contador visual: barriles del Goblin"
    set d = d + "|n- Infernales rediseñados"
    set d = d + "|n- Traducciones terminadas"
    set d = d + "|n- HP de torres aumentada"
    set d = d + "|n- Codigo viejo optimizado"
    set F9_QV10 = F9_CreateTab("v1.0 - Novedades Infinito", "ReplaceableTextures\\CommandButtons\\BTNEngineeringUpgrade.blp", "", d, true)

    // ------------------------------------------------------------------
    // PESTAÑA 5: v1.1
    // ------------------------------------------------------------------
    set d = "|cffFFCC00v1.1|r"
    set d = d + "|nAjustes de economia y aliados."
    set d = d + "|n"
    set d = d + "|n  - MODIFICADO: El comando |cff888888-pido|r pasa a llamarse |cffFFCC00-fondo|r. Sirve para"
    set d = d + "|n    pedirle oro a tu equipo cuando te falta; tus aliados te ayudan escribiendo |cffFFCC00-ok|r."
    set d = d + "|n    Es el mismo sistema, solo con un nombre mas claro."
    set d = d + "|n"
    set d = d + "|n  - NUEVO: El juego ahora reconoce los regalos de oro que haces por el panel |cffFFCC00F11|r"
    set d = d + "|n    (el panel de intercambio de recursos de Warcraft). Antes esos regalos no contaban;"
    set d = d + "|n    ahora suman a tu |cffFFCC00Score|r final y valen como aporte cuando alguien abre una"
    set d = d + "|n    colecta con |cffFFCC00-fondo|r."
    set F9_QV11 = F9_CreateTab("v1.1", "ReplaceableTextures\\CommandButtons\\BTNStatUp.blp", "", d, true)

    // ------------------------------------------------------------------
    // PESTAÑA 6: v1.2
    // ------------------------------------------------------------------
    set d = "|cffFFCC00v1.2|r"
    set d = d + "|nDesercion, votacion y torres."
    set d = d + "|n"
    set d = d + "|n  - MODIFICADO: Cuando alguien abandona y el equipo vota |cffFFCC00DROP|r o |cffFFCC00KICK|r, cada"
    set d = d + "|n    aliado del que se fue empieza a ganar |cff00FF00oro por segundo extra|r fijo"
    set d = d + "|n    (+1/+2/+3/+4, segun el oro elegido al inicio), sin importar cuantos aliados sean."
    set d = d + "|n    Ademas, el oro que tenia el desertor se reparte completo. Los |cffFFCC00bots|r cuentan"
    set d = d + "|n    igual: heredan el bono, y si un bot se va, su oro tambien se reparte."
    set d = d + "|n"
    set d = d + "|n  - MODIFICADO: La |cffFFCC00votacion|r al desconectarse ahora se cierra sola en |cffFFCC0015 seg|r."
    set d = d + "|n  - MODIFICADO: Las torres que no generan creeps de |cffFFCC00Fase 3|r y |cffFFCC00Fase 2|r cambian"
    set d = d + "|n    su armadura de |cffFF4444Fortificada|r a |cff00FF00Pesada|r (como en el mapa clasico):"
    set d = d + "|n    en la practica reciben mas daño de los ataques normales."
    set d = d + "|n  - NUEVO: Volvio el |cffFFCC00sonido clasico|r del inicio de la partida."
    set F9_QV12 = F9_CreateTab("v1.2", "ReplaceableTextures\\CommandButtons\\BTNStatUp.blp", "", d, true)

    // ------------------------------------------------------------------
    // PESTAÑA 7: v1.3
    // ------------------------------------------------------------------
    set d = "|cffFFCC00v1.3|r"
    set d = d + "|nItems, estructuras y rebalance."
    set d = d + "|n"
    set d = d + "|n  - REMOVIDO: Se quito el texto de |cff888888debug|r de las transferencias de oro por F11"
    set d = d + "|n    (era solo para pruebas)."
    set d = d + "|n  - MODIFICADO: La |cffFFCC00Mano del Rey|r (item unico) tarda mas en aparecer: |cffFFCC0012 min|r (antes 8)."
    set d = d + "|n  - MODIFICADO: |cffFFCC00Sello de Fortificacion|r: se quito la penalizacion por usarlo en"
    set d = d + "|n    base enemiga, y el aviso en pantalla ahora dura lo mismo que el efecto."
    set d = d + "|n  - NUEVO: Las |cffFFCC00estructuras|r ahora se pueden reparar (solo con oro)."
    set d = d + "|n  - REBALANCE: Ajustes al |cffFFCC00Maestro de las Espadas|r (Andar del Viento e Imagen"
    set d = d + "|n    del Espejo) y al |cffFFCC00Señor del Terror|r (Sueño)."
    set d = d + "|n  - MODIFICADO: |cffFFCC00Ave Errante|r mas resistente: vida |cff00FF005000 -> 7500|r,"
    set d = d + "|n    defensa |cff00FF00100 -> 200|r."
    set F9_QV13 = F9_CreateTab("v1.3", "ReplaceableTextures\\CommandButtons\\BTNStatUp.blp", "", d, true)

    // ------------------------------------------------------------------
    // PESTAÑA 8: v1.4
    // ------------------------------------------------------------------
    set d = "|cffFFCC00v1.4|r"
    set d = d + "|nInterfaz, items y rebalance de habilidades."
    set d = d + "|n"
    set d = d + "|n  - MODIFICADO: El comando |cffFFCC00-hud|r ahora oculta/muestra tambien el panel central"
    set d = d + "|n    de las colectas (|cffFFCC00-fondo|r), no solo los datos en vivo."
    set d = d + "|n  - MODIFICADO: El panel de la colecta (|cffFFCC00-fondo|r) ahora dura |cffFFCC0020s|r (antes 30) y"
    set d = d + "|n    bajo un poco en la pantalla para estorbar menos."
    set d = d + "|n  - ARREGLADO: El |cffFFCC00circulo|r que marca el borde de algunas habilidades de area ya no"
    set d = d + "|n    se queda |cffFF4444pegado|r en el suelo; ahora siempre se borra al terminar la habilidad."
    set d = d + "|n  - MEJORADO: |cffFFCC00Polvo de Aparicion|r (revela invisibles): ahora |cff00FF002 cargas|r, dura"
    set d = d + "|n    |cff00FF0025s|r (antes 20) y se repone cada |cff00FF0040s|r (antes 60); cuesta |cffFF4444100|r (antes 75)"
    set d = d + "|n    y muestra su area con un anillo."
    set d = d + "|n  - MODIFICADO: |cffFFCC00Mano del Rey|r aparece mas tarde, a los |cffFFCC0015 min|r (antes 12)."
    set d = d + "|n  - REBALANCE: |cff00FF00Furia Quimica|r (Alquimista) y |cff00FF00Soy Huskar|r (Troll) duran |cff00FF002s mas|r"
    set d = d + "|n    y enfrian mucho menos (de 120/60 a |cff00FF0048/30 seg|r)."
    set d = d + "|n  - NERF: |cffFF4444Armadura de Hielo|r: el frio que deja en el atacante dura |cffFF44445s|r (antes 8)."
    set d = d + "|n  - MODIFICADO: |cffFFCC00Sylvanas Orco|r cambio |cff888888Flecha Negra|r por |cffFFCC00Aura de Inexactitud|r."
    set d = d + "|n  - MEJORADO: |cff00FF00Fuego Interior|r ahora tambien funciona en creeps, no solo en heroes."
    set d = d + "|n  - MEJORADO: Mejoras a |cffFFCC00Aliento de Fuego|r y |cffFFCC00Aturdimiento por Alcohol|r (Alquimista"
    set d = d + "|n    Pandaren), |cffFFCC00Abanico de Cuchillas|r y |cffFFCC00Enjambre Carroñero|r."
    set F9_QV14 = F9_CreateTab("v1.4", "ReplaceableTextures\\CommandButtons\\BTNStatUp.blp", "", d, true)

    // ------------------------------------------------------------------
    // PESTAÑA 9: v1.5
    // ------------------------------------------------------------------
    set d = "|cffFFCC00v1.5|r"
    set d = d + "|nRebalance de heroes, items y sistemas."
    set d = d + "|n"
    set d = d + "|n  - REBALANCE: |cffFFCC00Maestro de las Espadas|r: sus habilidades |cffFFCC00Andar del Viento|r"
    set d = d + "|n    (invisibilidad) e |cffFFCC00Imagen del Espejo|r (clones) recargan |cff00FF001 seg mas rapido|r cada una."
    set d = d + "|n  - MEJORADO: |cffFFCC00Dormir|r (|cff888888Señor del Terror|r): su aturdimiento ahora dura |cff00FF001.5s|r (antes 1)."
    set d = d + "|n  - MEJORADO: |cffFFCC00Estrella Fugaz|r (ulti de la |cff888888Sacerdotisa de la Luna|r y de |cff888888Sylvanas Orco|r):"
    set d = d + "|n    llueven estrellas sobre un area. Ahora pegan |cff00FF00mucho mas fuerte|r y, en niveles altos,"
    set d = d + "|n    caen |cff00FF00mas seguido|r; a cambio cuesta |cffFF4444mas mana|r."
    set d = d + "|n  - MEJORADO: |cffFFCC00Raices Enredaderas|r (|cff888888Guardian del Bosque|r): atrapa e inmoviliza a un"
    set d = d + "|n    enemigo; ahora su duracion inicial es |cff00FF001s mas larga|r."
    set d = d + "|n  - REBALANCE: |cffFFCC00Tranquilidad|r (ulti del |cff888888Guardian del Bosque|r): cura a los aliados en area."
    set d = d + "|n    A nivel maximo cura mas por segundo, |cff00FF00415|r (antes 315); pero a nivel 1 dura menos."
    set d = d + "|n  - MEJORADO: |cffFFCC00Gancho de Carnicero|r (|cff888888Abominacion|r): lanza un gancho que"
    set d = d + "|n    arrastra al enemigo hacia ti; ahora llega mas lejos, |cff00FF001350|r de alcance (antes 1250)."
    set d = d + "|n  - NERF: |cffFFCC00Ciclon|r (|cff888888Invocador del Trueno|r): su alcance maximo baja |cffFF444450|r."
    set d = d + "|n  - MEJORADO: |cffFFCC00Sello de Fortificacion|r (item que vuelve invulnerables las estructuras de tu"
    set d = d + "|n    equipo por unos segundos): ahora esa proteccion dura |cff00FF0030s|r (antes 20)."
    set d = d + "|n  - MEJORADO: |cffFFCC00Libro de Experiencia|r: ahora da mas experiencia, |cff00FF00150|r por libro (antes 100)."
    set d = d + "|n  - MODIFICADO: |cffFFCC00Tomo de Nivel|r: baja de precio a |cff00FF00900|r (antes 999)."
    set d = d + "|n  - MODIFICADO: El |cffFFCC00Editor|r (el ave negra neutral que vuela por todo el mapa) ahora da el"
    set d = d + "|n    doble de oro al matarla: |cff00FF004000|r (antes 2000)."
    set d = d + "|n  - MODIFICADO: |cffFFCC00Modo habilidades aleatorias|r: si tras |cff00FF0010 mejoras seguidas|r no te salio"
    set d = d + "|n    la |cffFFCC00ulti|r, la siguiente la sube seguro (nunca te quedas sin ulti por mala suerte). Ademas,"
    set d = d + "|n    el |cffFFCC00libro de reconversion|r (el que reinicia habilidades) queda desactivado en este modo."
    set d = d + "|n  - MODIFICADO: |cffFFCC00Votacion por desconexion|r: cuando un jugador se va, se abre una votacion"
    set d = d + "|n    (|cff00CCFFBOT|r/|cffFFCC00DROP|r/|cffFF4444RMK|r) para decidir que hacer con su heroe. Ahora esa votacion dura menos:"
    set d = d + "|n    |cff00FF007 segundos|r maximo (antes 15)."
    set d = d + "|n  - MODIFICADO: Con el |cffFFCC00castillo|r o la |cffFFCC00fortaleza|r ya vulnerables, si un jugador se va NO se"
    set d = d + "|n    abre votacion: se aplica |cffFFCC00DROP|r automatico (para no frenar la partida en un momento clave)."
    set d = d + "|n  - REMOVIDO: El |cffFF4444oro/seg extra|r por DROP/KICK: los aliados del que abandona ya no ganan"
    set d = d + "|n    renta fija. Solo heredan su |cffFFCC00oro actual|r (repartido en partes iguales) y sus items botados."
    set F9_QV15 = F9_CreateTab("v1.5", "ReplaceableTextures\\CommandButtons\\BTNStatUp.blp", "", d, true)

    // ------------------------------------------------------------------
    // PESTAÑA 10: v1.6
    // NOTA DE ESTILO (v1.6 en adelante): una sola pestaña por version.
    // Para que entre en el limite de ~4096 chars (ver NOTA DE LIMITE arriba):
    //   - Una linea VISIBLE por cambio: WC3 salta automaticamente por ancho.
    //     Maximo practico: la linea "Cadena de Relampagos" de v1.9.
    //   - Notacion "x/y" = nivel 1 / nivel maximo (se aclara en la cabecera).
    //   - Solo el nombre en color; los numeros van planos (el color cuesta
    //     ~12 chars por par |cff..|r y es lo que mas infla el texto).
    //   - Agrupar por seccion (HABILIDADES / ITEMS Y SISTEMAS / ARREGLOS) en
    //     vez de repetir etiquetas MEJORADO/NERF en cada linea.
    //   - Decir "antes X, ahora Y". Nada de explicar como funciona la skill.
    // ------------------------------------------------------------------
    set d = "|cffFFCC00HABILIDADES|r"
    set d = d + "|n  - |cffFFCC00Aliento de Fuego|r |cff888888(Alquimista Pandaren)|r: daño 85/814 (100/640), tope 850/8140 (1000/6400), -mana."
    set d = d + "|n  - |cffFFCC00Aliento de Fuego + Aturdimiento por Alcohol|r: daño por segundo del combo 75/300 (60/150)."
    set d = d + "|n  - |cffFFCC00Aturdimiento por Alcohol|r: fallo 15%/60% (17/35), enf. 8/26s (8/38), dura 15s (11/20)."
    set d = d + "|n  - |cffFFCC00Tormenta, Tierra y Fuego|r: enfria 130/150s (140/240), dura 50/70s (60/160), mana 150/400 (150/275)."
    set d = d + "|n  - |cffFFCC00Empalar|r |cff888888(Señor de la Cripta)|r: alcance 650 (600), dura 2/9s (1/8.2), enf. 10/40s (9/45), mana 110/335."
    set d = d + "|n  - |cffFFCC00Fisura|r |cff888888(Magnadefender)|r: mana 110/335 (100/280), enfria 10/40s (10/34)."
    set d = d + "|n  - |cffFFCC00Defensa Magna|r |cff888888(Magnadefender)|r: bloquea 50/300 de daño (50/150)."
    set d = d + "|n  - |cffFFCC00Nova de Hielo|r |cff888888(Lich)|r: al objetivo 70/619 (100/600), a los cercanos 50/419 (50/300)."
    set d = d + "|n  - |cffFFCC00Rayo Conico|r |cff888888(Vidente y Bruja del Mar Naga)|r: daño 85/814 (150/527), enfria 10/28s (10/40)."
    set d = d + "|n  - |cffFFCC00Onda y Ola Expansiva|r |cff888888(Jefe Tauren y Naga Royal)|r: daño 85/814 (150/750), tope 850/8140."
    set d = d + "|n  - |cffFFCC00Mago Infernal|r |cff888888(Nigromante)|r: enfria 150/130s (175/150), area 250/400 (250/375)."
    set d = d + "|n  - |cffFFCC00Infernal|r |cff888888(Señor del Terror)|r: enfria 160/140s (185/160), area 250/400 (250/375)."
    set d = d + "|n  - |cffFFCC00Dormir|r |cff888888(Señor del Terror)|r: dura 5/14s (5/10), aturde 1.6s (1.5)."
    set d = d + "|n  - |cffFFCC00Quebrantavidas|r |cff888888(Troll Berserker)|r: alcance 600/900 (600/800), daño 15%/45% (15%/35%)."
    set d = d + "|n  - |cffFFCC00Barril de Explosivos|r |cff888888(Goblin)|r: golpes para romperlo 2/12 (1/10), explosion 100/280 (100/200)."
    set d = d + "|n"
    set d = d + "|n|cffFFCC00ITEMS Y SISTEMAS|r"
    set d = d + "|n  - |cffFFCC00Mano del Rey|r: ya no da velocidad de ataque extra, ahora te lleva al tope de velocidad de tu heroe. Aparece a los 11 min (antes 15). Nuevo indicador sobre el heroe que la lleva."
    set d = d + "|n  - |cffFFCC00Finger of Harm|r: daño 350 (antes 300). Nuevo: la fusion de 2 Fingers ahora tiene efecto visual."
    set d = d + "|n  - |cffFFCC00Editor|r |cff888888(ave neutral)|r: lo que deja caer se vende por 5000 (antes 4000)."
    set d = d + "|n  - |cffFFCC00Torres del castillo y la fortaleza|r: daño 150 (antes 95)."
    set d = d + "|n  - |cffFFCC00Votacion por desconexion|r: dura hasta 8s (antes 7); al expirar decide con los votos emitidos."
    set d = d + "|n"
    set d = d + "|n|cffFFCC00ARREGLOS|r"
    set d = d + "|n  - |cffFFCC00Barril de Explosivos|r |cff888888(Goblin)|r: ya no se queda sin explotar."
    set d = d + "|n  - |cffFFCC00Gancho|r |cff888888(Abominacion)|r: ya no arrastra unidades aereas."
    set d = d + "|n  - |cffFFCC00Editor|r: ya no nace en zonas inaccesibles ni queda trabado."
    set F9_QV16 = F9_CreateTab("v1.6", "ReplaceableTextures\\CommandButtons\\BTNStatUp.blp", "|cffFFCC00COMO LEER: nivel 1 / nivel maximo (valores anteriores).|r", d, true)

    // ------------------------------------------------------------------
    // PESTAÑA 11: v1.7
    // Mismo estilo que v1.6: una linea por cambio, secciones, "antes X, ahora
    // Y", solo el nombre en color. Ver NOTA DE LIMITE (~4096 chars) arriba.
    // ------------------------------------------------------------------
    set d = "|cffFFCC00HABILIDADES|r"
    set d = d + "|n  - |cffFFCC00Sed de Sangre|r |cff888888(Grom Hellscream)|r: regeneracion de vida del Espadachin Poseido 15/s (antes 8)."
    set d = d + "|n"
    set d = d + "|n|cffFFCC00ITEMS Y SISTEMAS|r"
    set d = d + "|n  - |cffFFCC00Mano del Rey|r: al comprarse aparece un aviso para todos. Sale una sola vez por partida y no dice quien la tiene."
    set d = d + "|n"
    set d = d + "|n|cffFFCC00ARREGLOS|r"
    set d = d + "|n  - |cffFFCC00Mano del Rey|r: el indicador sobre la cabeza ya no desaparece. Antes ciertas habilidades sobre el portador (|cffFFCC00Hex|r, |cffFFCC00Empalar|r) lo borraban para siempre y el heroe seguia con el item pero sin marca."
    set d = d + "|n  - |cffFFCC00Gancho|r |cff888888(Abominacion)|r: ya no arrastra al |cffFFCC00Rey de la Montaña|r en Gran Avatar. Tampoco arrastra unidades invulnerables (ej. |cffFFCC00Escudo Divino|r del Paladin): el gancho les pasa de largo y sigue viaje buscando otro objetivo."
    set F9_QV17 = F9_CreateTab("v1.7", "ReplaceableTextures\\CommandButtons\\BTNStatUp.blp", "|cffFFCC00COMO LEER: nivel 1 / nivel maximo (valores anteriores).|r", d, true)

    // ------------------------------------------------------------------
    // PESTAÑA 12: v1.8
    // ------------------------------------------------------------------
    set d = "|cffFFCC00HABILIDADES|r"
    set d = d + "|n  - |cffFFCC00Ventisca|r |cff888888(Archimago)|r: daño 35/197 (35/175), tope 140/788 (120/565)."
    set d = d + "|n  - |cffFFCC00Lluvia de Fuego|r |cff888888(Señor del Foso)|r: daño 35/197 (35/175), tope 140/788 (120/565)."
    set d = d + "|n  - |cffFFCC00Aullido de Terror|r |cff888888(Señor del Foso)|r: mana 50/290 (50/410), area 600/1000 (500/905), reduccion 16%/100% (10%/100%; ahora llega a 100% desde nivel 7), enfria 18s (20)."
    set d = d + "|n  - |cffFFCC00Perdicion|r |cff888888(Señor del Foso)|r: dura 120/180s (120/240), enfria 120/180s (200/250), mana 300/800 (200/700)."
    set d = d + "|n  - |cffFFCC00Guardian del Apocalipsis|r: defensa 20/50 (10/25), movimiento 325/450 (270/370), vida 2000/5000 (1500/4000), regeneracion de mana 5/s (0), velocidad de ataque 0.7 (1.0)."
    set d = d + "|n  - |cffFFCC00Pisoton Guardian del Apocalipsis|r: ahora muestra un anillo visual que delimita su area de efecto de 250."
    set d = d + "|n"
    set d = d + "|n|cffFFCC00MAPA Y AMBIENTE|r"
    set d = d + "|n  - |cffFFCC00Niebla y zoom|r: la distancia maxima de la niebla sube a 3500 (antes 2900). El comando |cffFFCC00-z3|r, con zoom 2750, ahora ofrece mas vision sin que la niebla resulte tan molesta."
    set d = d + "|n  - |cffFFCC00Clima|r: la lluvia intensa fue reemplazada por una combinacion de lluvia y nevada ligera."
    set d = d + "|n  - |cffFFCC00Decoracion|r: se agregaron dos pequenos adornos ambientales con cadaveres empalados o junto a una antorcha."
    set d = d + "|n  - |cffFFCC00Nuevo Comando (-aliados):|r muestra el oro actual de cada aliado."
    set d = d + "|n"
    set d = d + "|n|cffFFCC00ESTRUCTURAS Y CREEPS|r"
    set d = d + "|n  - NUEVO: Al destruir una |cffFFCC00cripera enemiga|r de Fase 2, la cripera equivalente de tu equipo queda vulnerable (manada con manada y tanque con tanque). Puedes destruirla para impedir que el rival siga ganando oro y experiencia con tus creeps. Las demas estructuras y el orden de las fases no cambian."
    set d = d + "|n"
    set d = d + "|n|cffFFCC00VOTACION POR ABANDONO|r"
    set d = d + "|n  - El equipo del primer desconectado elige |cff00CCFFBOT|r, |cffFFCC00DROP|r o |cffFF4444RMK|r. El rival elige |cff55DD55CONTINUAR|r o |cffFF4444RMK|r."
    set d = d + "|n  - Todos los votos valen 1. |cff00CCFFBOT|r, |cffFFCC00DROP|r y |cff55DD55CONTINUAR|r cuentan por seguir jugando. Los empates continuan."
    set d = d + "|n  - |cffFF4444RMK|r gana por mayoria de votos emitidos o si todos los que votaron en un equipo eligieron RMK."
    set d = d + "|n  - Si luego sale alguien del otro equipo, recibe |cffFFCC00DROP|r por defecto. Sin heroe siempre es |cffFFCC00KICK|r."
    set F9_QV18 = F9_CreateTab("v1.8", "ReplaceableTextures\\CommandButtons\\BTNStatUp.blp", "|cffFFCC00COMO LEER: nivel 1 / nivel maximo (valores anteriores).|r", d, true)

    // ------------------------------------------------------------------
    // PESTAÑA 13: v1.9  (version actual)
    // ------------------------------------------------------------------
    set d = "|cffFFCC00HABILIDADES|r"
    set d = d + "|n  - |cffFFCC00Elemental|r |cff888888(Archi)|r: atajos Q/W/E/R, Nube desbloqueada. Ola Aplastante: 0s, mana 200 (100)."
    set d = d + "|n  - |cffFFCC00Aullido de Terror|r |cff888888(Señor del Foso)|r: duracion 10/28s (8/26), enfria 15s (18)."
    set d = d + "|n  - |cffFFCC00Perdicion|r |cff888888(Señor del Foso)|r: guardian armadura 20/60 (20/50), vida 2000/6000 (2000/5000)."
    set d = d + "|n  - |cffFFCC00Sed de Sangre|r |cff888888(Grom)|r: nueva animacion y sonido; regen vida 30/s (antes 15)."
    set d = d + "|n  - |cffFFCC00Gran Avatar|r |cff888888(Rey de la Montaña)|r: vida adicional 500/1500 (antes 250/1500)."
    set d = d + "|n  - |cffFFCC00Andar del Viento|r |cff888888(Maestro Espadas / Grom)|r: daño sorpresa 100/1000 (100/550)."
    set d = d + "|n  - |cffFFCC00Cadena de Relampagos|r |cff888888(Vidente)|r: daño 210/903 (210/862), obj 4/13 (3/10), mana 150/384 (150/415)."
    set d = d + "|n  - |cffFFCC00Rayo Conico|r |cff888888(Vidente)|r: daño 105/906 (85/814), obj 3/12 (1/10), alcance 1005 (800), mana 379 (410)."
    set d = d + "|n  - |cffFFCC00Tanque Salvaje|r |cff888888(Vidente - reemplazo)|r: lobo 8000 HP, 200 def, taunt, traspaso, invis, slow."
    set d = d + "|n  - |cffFFCC00Banish|r |cff888888(Mago Sang.)|r: mana 75/237 (156), enfria 6/4.5s (6/3.5s)."
    set d = d + "|n  - |cffFFCC00Defensa Magna|r |cff888888(Magnadefender)|r: indicador de bloqueo."
    set d = d + "|n  - |cffFFCC00Gancho de Carnicero|r |cff888888(Abominacion)|r: alcance 650/1450 (650/1350), nueva cadena azul."
    set d = d + "|n  - |cffFFCC00Tormenta, Tierra y Fuego|r |cff888888(Pandaren)|r: armadura 15/40 (10/25), dura 60s (50/70), enfria 120s (150)."
    set d = d + "|n  - |cffFFCC00Aturd. Alcohol|r |cff888888(Pandaren)|r: lento 20/74% (10/50%), fallo 27/90% (15/60%), cd 11/20s (8/26)."
    set d = d + "|n  - |cffFFCC00Aliento de Fuego|r |cff888888(Pandaren)|r: daño 100/901 (85/814), DoT combo 72/360 (75/300), mana 335 (407)."
    set d = d + "|n  - |cffFFCC00Camorrista Borracho|r |cff888888(Pandaren)|r: crit x1.4/2.7 (x1.23/2.11), evasion 10/35% (6/24%), prob 10/35%."
    set d = d + "|n  - |cffFFCC00Aura Inexactitud / Robo Vida|r |cff888888(Sylvanas)|r: distancia -8/35% (7/30%); drena 25/304 vida (25/178)."
    set d = d + "|n  - |cffFFCC00Robo Goblin|r |cff888888(Hojalatero)|r: inmune a Dormir y P. Infernal (solo ultis); Demoler x1.4 a edificios (x2)."
    set d = d + "|n|cffFFCC00ITEMS Y SISTEMAS|r"
    set d = d + "|n  - |cffFFCC00Libro de los Muertos|r: +vel. ataque, 5 armadura, regen 20/s (guerr) / 10/s (arq), dura x2 (10 min)."
    set d = d + "|n  - |cffFFCC00Menu F9|r: textos y pestañas mejoradas con subtitulos explicativos."
    set d = d + "|n  - |cffFFCC00Votacion por abandono|r: con F2 norte y sur vulnerables, aplica |cffFFCC00DROP auto|r; avisa oro heredado."
    set d = d + "|n  - |cffFFCC00Pantalla final y resultados|r: puntajes y distinciones resumidos en el cuadro de victoria."
    set d = d + "|n  - |cffFFCC00Registro final de bajas|r: muestra las ultimas 10 bajas con minuto y segundo exacto."
    set d = d + "|n  - |cffFFCC00Editor|r: ave neutral 8000 vida (antes 7500), texto corregido; Mercado goblin animado."
    set d = d + "|n  - |cffFFCC00Colecta (-fondo)|r: atajo |cffFFCC00-f|r; acepta |cffFFCC00ok|r o |cffFFCC00-ok|r. |cffFFCC00Comando (-aliados)|r: atajo |cffFFCC00-al|r."
    set d = d + "|n  - |cffFFCC00Mano del Rey|r: costo 4000 (antes 4500). |cffFFCC00Multi-Kill|r: ventana 25s (+5s por kill, max 40s)."
    set d = d + "|n|cffFFCC00ARREGLOS|r"
    set d = d + "|n  - |cffFFCC00Soy Huskar|r |cff888888(Troll Berserker)|r: color rojo CC/Hex corregido; texto barra duracion corregido."
    set d = d + "|n  - |cffFFCC00Torres constructores|r: reparacion solo con oro. |cffFFCC00Repeticiones|r: datos en vivo correctos al cambiar."
    set d = d + "|n  - |cffFFCC00Armaduras (+10 def)|r: Coraza de Acero, Lunar Mejorada y Cuero Mejorada dan 10 def (antes 0)."
    set F9_QV19 = F9_CreateTab("v1.9", "ReplaceableTextures\\CommandButtons\\BTNStatUp.blp", "|cffFFCC00COMO LEER: nivel 1 / nivel maximo (valores anteriores).|r", d, true)

    // ------------------------------------------------------------------
    // PESTAÑA 14: v2.0
    // ------------------------------------------------------------------
    set d = "|cffFFCC00HEROES Y HABILIDADES|r"
    set d = d + "|n  - |cffFFCC00Alquimista pandaren|r: velocidad de movimiento base 290 (antes 270)."
    set d = d + "|n  - |cffFFCC00Transferencia|r |cff888888(Sylvanas Orco)|r: nuevo nombre de Robo de Vida; transfiere 30/300 (antes 25/304)."
    set d = d + "|n  - |cffFFCC00Llamarada|r |cff888888(Mago Sanguinario)|r: daño total causado 16/70 (antes 15/55)."
    set d = d + "|n  - |cffFFCC00Robo Goblin|r |cff888888(Hojalatero)|r: daño contra edificios x1.5 (antes x1.4)."
    set d = d + "|n  - |cffFFCC00Fabrica de Bolsillo|r |cff888888(Hojalatero)|r: defensa 100 (antes 0), aparicion 3.7/1.0s (4/1.3s)."
    set d = d + "|n  - |cffFFCC00Pulverizador Curativo|r |cff888888(Alquimista)|r: 6 oleadas (antes 5), cura max 300/3000 (150/1500)."
    set d = d + "|n  - |cffFFCC00Bomba Acida|r |cff888888(Alquimista)|r: daño/s 4/40 (3/30), mana 100/370 (100/460), reducción 3/30 (2/20)."
    set d = d + "|n  - |cffFFCC00Bendición de Zeus|r |cff888888(Invocador del Trueno)|r: mana 150/330 (antes 150/447)."
    set d = d + "|n  - |cffFFCC00Escudo de Rayo|r |cff888888(Invocador del Trueno)|r: daño/s 30/300 (15/150), enfria fijo 15s (10/15s)."
    set d = d + "|n  - |cffFFCC00Perdición|r |cff888888(PitLord)|r: vida 1500/4000 (2000/6000), def 15/40 (20/60), dura/cd 180/300s (120/180s)."
    set d = d + "|n  - |cffFFCC00Guardián del Apocalipsis|r: Pisotón cd 10s (6), dura 2s (3); Lisiar cd 5s (10); cambios en mana."
    set d = d + "|n  - |cffFFCC00Cadena Relampagos|r |cff888888(Vidente)|r: daño 210/1002 (903), enfria 10/28s (8/33), perdida 5% (15%)."
    set d = d + "|n  - |cffFFCC00Tanque Salvaje|r |cff888888(Vidente)|r: vida 5200 (8000), daño 1-3; pierde invisibilidad e inmunidad magica."
    set d = d + "|n"
    set d = d + "|n|cffFFCC00SISTEMAS|r"
    set d = d + "|n  - |cffFFCC00Recompensa por baja|r: oro obtenido por eliminar a un héroe aumentado a 500 (antes 250)."
    set d = d + "|n  - |cffFFCC00Nueva distinción|r: Demoledor, jugador con mayor daño acumulado a edificios/torres."
    set d = d + "|n  - |cffFFCC00Tabla|r: agregado icono de héroe; se revela cuando el equipo completo termina de elegir."
    set d = d + "|n"
    set d = d + "|n|cffFFCC00ARREGLOS|r"
    set d = d + "|n  - |cffFFCC00Repeticiones|r: se soluciono el error que impedia ver repeticiones o las reproducia con fallos."
    set d = d + "|n  - |cffFFCC00Soy Huskar|r |cff888888(Troll Berserker)|r: al revivir mantiene correctamente su apariencia."
    set d = d + "|n  - |cffFFCC00Gancho de Carnicero|r |cff888888(Abominacion)|r: el enganche vuelve a cancelar el TP (Botas TP) de la presa."
    set d = d + "|n  - |cffFFCC00Gancho de Carnicero|r |cff888888(Abominacion)|r: se restauro el color original de la cadena (naranja)."
    set d = d + "|n  - |cffFFCC00Robo Goblin|r |cff888888(Hojalatero)|r: su icono regresa siempre a su estado normal al transformarse."
    set F9_QV20 = F9_CreateTab("v2.0", "ReplaceableTextures\\CommandButtons\\BTNStatUp.blp", "|cffFFCC00COMO LEER HABILIDADES: nivel 1 / nivel maximo (valores anteriores).|r", d, true)

    // ------------------------------------------------------------------
    // PESTAÑA 15: v2.1 (version actual)
    // ------------------------------------------------------------------
    set d = "|cffFFCC00HEROES Y HABILIDADES|r"
    set d = d + "|n  - |cffFFCC00Transmutar|r |cff888888(Alquimista)|r: mana 300/600 (antes 100/300), enfria 280/420s (antes 60/160s)."
    set d = d + "|n  - |cffFFCC00Transferencia|r |cff888888(Sylvanas Orco)|r: transfiere 50/500 (antes 30/300), roba 10/82 vida/s (antes 0)."
    set d = d + "|n  - |cffFFCC00Act. Ingeniería|r |cff888888(Tinker)|r: daño 10/100 (antes 15/159), vel. mov 3/30% (antes 10/50%)."
    set d = d + "|n  - |cffFFCC00Robo Goblin|r |cff888888(Tinker)|r: fuerza 10/40 (antes 10/60); ya no da defensa extra (antes 8/25)."
    set d = d + "|n  - |cffFFCC00Barril Expl.|r |cff888888(Techies)|r: mana 150/330 (50/176), golpes 1/10 (2/12), cd 7/11s (6/10), stun 1/3s (1/3.5)."
    set d = d + "|n  - |cffFFCC00Trampa Eléctrica|r |cff888888(Techies)|r: mana 90/387 (antes 90/288)."
    set d = d + "|n  - |cffFFCC00Golpe de Sombras|r |cff888888(Guardiana)|r: daño/s 9/90 (8/80), dura 10s (13s), sin daño inicial (100/505)."
    set d = d + "|n  - |cffFFCC00Perdición|r |cff888888(PitLord)|r: ahora enfria 120/240s (antes 180/300s)."
    set d = d + "|n  - |cffFFCC00Inmolación|r |cff888888(Illidan / Butcher)|r: consumo de mana por seg. 7.0/9.7 (antes 7.0/4.3)."
    set d = d + "|n"
    set d = d + "|n|cffFFCC00ITEMS Y SISTEMAS|r"
    set d = d + "|n  - |cffFFCC00Sello de Fortificacion|r: costo 2000 (antes 1000)."
    set d = d + "|n  - |cffFFCC00Tomo de Nivel|r: costo 1000 (antes 900); disponible a los 30 min (antes al inicio)."
    set d = d + "|n  - |cffFFCC00Libro de Experiencia|r: costo 200 (antes 100), da 100 de experiencia (antes 150)."
    set d = d + "|n  - |cffFFCC00Libro de Experiencia|r: disponible a los 10 min (antes desde el inicio)."
    set d = d + "|n  - |cffFFCC00Tabernas de base|r |cff888888(tiendas)|r: vida 50.000 (antes 90.000)."
    set d = d + "|n  - |cffFFCC00merito|r: comando eliminado."
    set d = d + "|n"
    set d = d + "|n|cffFFCC00ARREGLOS|r"
    set d = d + "|n  - |cffFFCC00Transmutar|r |cff888888(Alquimista)|r: ya no se puede usar sobre el EDITOR (ave neutral)."
    set d = d + "|n  - |cffFFCC00Transmutar|r |cff888888(Alquimista)|r: el oro del hechizo y la recompensa del creep ya no se superponen."
    set F9_QV21 = F9_CreateTab("v2.1 (actual)", "ReplaceableTextures\\CommandButtons\\BTNStatUp.blp", "|cffFFCC00COMO LEER HABILIDADES: nivel 1 / nivel maximo (valores anteriores).|r", d, true)

    // ------------------------------------------------------------------
    // PESTAÑA 16: ACERCA DE
    // ------------------------------------------------------------------
    set d = "|cffFFCC00Orcos vs Humanos Infinito|r"
    set d = d + "|n|cffFFCC00Version 2.1|r"
    set d = d + "|n"
    set d = d + "|nMapa competitivo tipo MOBA"
    set d = d + "|npara Warcraft III 1.27b."
    set d = d + "|n"
    set d = d + "|n|cffFFCC00Mapa base:|r OvsH XS 1.08 2024v2"
    set d = d + "|n|cffFFCC00Editado por:|r MateriaViva"
    set d = d + "|n"
    set d = d + "|n|cff888888Para bugs o modificaciones:"
    set d = d + "|nDiscord: materia2023|r"
    set F9_QAcerca = F9_CreateTab("Acerca de", "ReplaceableTextures\\CommandButtons\\BTNTomeOfRetraining.blp", "", d, true)

    // ==================================================================
    // ZONA DERECHA: "Informacion en Vivo" (required = false)
    // Nota: "Registro de Bajas" se crea en Sistema_Anuncios.j
    // ==================================================================

    // ------------------------------------------------------------------
    // COMANDOS
    // ------------------------------------------------------------------
    set d = "|cffFFCC00-oro|r |cff888888[jugador] [cantidad]|r"
    set d = d + "|n  Enviar oro a un aliado."
    set d = d + "|n|cffFFCC00-madera|r |cff888888[jugador] [cantidad]|r"
    set d = d + "|n  Enviar madera a un aliado."
    set d = d + "|n|cffFFCC00-fondo|r |cff888888[cantidad] (o -f)|r"
    set d = d + "|n  Pedir oro al equipo (colecta de 20s)."
    set d = d + "|n|cffFFCC00OK|r |cff888888(o -ok)|r"
    set d = d + "|n  Aportar a la colecta activa durante sus 20s (lo que falte)."
    set d = d + "|n|cffFFCC00-hud|r"
    set d = d + "|n  Activar/Desactivar datos en vivo y panel central del comando -fondo."
    set d = d + "|n|cffFFCC00-as|r"
    set d = d + "|n  Ver velocidad de ataque detallada."
    set d = d + "|n|cffFFCC00-ms|r"
    set d = d + "|n  Ver tu velocidad de movimiento (base + bonus)."
    set d = d + "|n|cffFFCC00-ma|r"
    set d = d + "|n  Matchup: que heroe controla cada enemigo."
    set d = d + "|n|cffFFCC00-aliados|r |cff888888(o -al)|r"
    set d = d + "|n  Ver el oro actual de cada aliado."
    set d = d + "|n|cffFFCC00-kick|r |cff888888[jugador]|r"
    set d = d + "|n  Expulsar jugador (solo Master)."
    set d = d + "|n|cffFFCC00-z1|r / |cffFFCC00-z2|r / |cffFFCC00-z3|r"
    set d = d + "|n  Zoom preset (1650 / 2200 / 2750)."
    set d = d + "|n|cffFFCC00-z |r|cff888888[numero]|r"
    set d = d + "|n  Zoom personalizado con espacio (ej: -z 1800)."
    set d = d + "|n|cffFFCC00-z+|r / |cffFFCC00-z-|r"
    set d = d + "|n  Ajuste fino de camara (+100 / -100)."
    set F9_QComandos = F9_CreateTab("Comandos", "ReplaceableTextures\\CommandButtons\\BTNScrollUber.blp", "|cffFFCC00CONSULTA RAPIDA DE TODOS LOS COMANDOS DISPONIBLES.|r", d, false)

    // ------------------------------------------------------------------
    // Para agregar mas pestañas: repetir el patron (rellenar 'd' con sets y
    // llamar F9_CreateTab en UNA sola linea, incluyendo su subtitulo fijo).
    // Pasar "" si ese subtitulo no aporta informacion. No hace falta guardar el
    // handle si la pestaña es estatica.
    //
    // Para una NUEVA VERSION (ej. v2.1): copiar el bloque de una pestaña de
    // version, cambiar el titulo/contenido y agregar su global (F9_QV21).
    // NUNCA meter todas las versiones en una sola pestaña: se pasa del limite
    // de ~4096 chars y crashea la carga (ver NOTA DE LIMITE arriba).
    // ------------------------------------------------------------------
endfunction
