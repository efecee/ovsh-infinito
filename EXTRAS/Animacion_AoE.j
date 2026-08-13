scope AnimacionAoE initializer Init

    //===========================================================================
    //
    //  SISTEMA GENÉRICO: ANILLO VISUAL DE ÁREA DE EFECTO (Lightning Ring)
    //
    //===========================================================================
    //
    //  DESCRIPCIÓN:
    //    Dibuja un anillo de relámpagos (polígono) alrededor del área de efecto
    //    de cualquier habilidad registrada. El jugador puede ver EXACTAMENTE
    //    el perímetro donde la habilidad está haciendo efecto.
    //
    //  CÓMO AGREGAR UNA NUEVA HABILIDAD:
    //    1. En IsRegistered(), agrega:  or id == 'XXXX'
    //    2. En GetRingMode(), agrega un bloque elseif con el modo
    //    3. En GetRingLightningType(), agrega el tipo de rayo
    //    4. En GetRingSegments(), agrega la cantidad de segmentos
    //    5. En GetRingAoE(), agrega el AoE por nivel
    //    6. En GetRingDuration(), agrega la duración por nivel
    //    7. Si es CANALIZADA, en IsChanneled() agrega:  or id == 'XXXX'
    //
    //  MODOS:
    //    RING_FOLLOW_CASTER (0) - Sigue al héroe. Muere si el héroe muere.
    //                             Ejemplo: Torbellino, Inmolación.
    //    RING_STATIC_TARGET (1) - Fijo donde apuntaste. Persiste si muere el héroe.
    //                             Ejemplo: Vista Lejana, Lluvia de Fuego.
    //    RING_STATIC_CASTER (2) - Fijo donde estaba el héroe. Persiste si muere.
    //                             Ejemplo: Grito de Guerra, Thunder Clap.
    //
    //  TIPOS DE RELÁMPAGO:
    //    "SPLK" = Spirit Link (fino, sutil)
    //    "CLPB" = Chain Lightning (eléctrico azul)
    //    "HWPB" = Healing Wave (verde brillante)
    //    "DRAM" = Drain Mana (azul, discreto)
    //    "FORK" = Forked Lightning (bifurcado)
    //    "LEAS" = Leash (muy fino)
    //    "AFOD" = Finger of Death (oscuro)
    //
    //  CASO NO CUBIERTO:
    //    Si encuentras una habilidad que no encaja en ningún modo,
    //    documéntala aquí y diseña un nuevo modo antes de implementar.
    //
    //===========================================================================
    //
    //  MOTOR (refactor 2026-06-20) — POR QUÉ ES ROBUSTO:
    //
    //    Antes cada anillo arrancaba SU PROPIO timer de 0.03s. En un 5v5 con
    //    muchos casts simultáneos eso era una tormenta de timers, y CUALQUIER
    //    carrera entre los puntos de limpieza (expiración / muerte / ENDCAST /
    //    re-toggle) podía dejar relámpagos huérfanos pegados al mapa para siempre
    //    (sobre todo en PCs lentas, donde el orden de los eventos cambia).
    //
    //    Ahora hay UN SOLO timer-motor (Driver) que recorre la lista de anillos
    //    activos cada 0.03s. Invariante central:
    //
    //        ringInUse[idx]  <=>  idx está en activeList  <=>  sus relámpagos viven
    //
    //    El Driver es la ÚNICA autoridad: cuenta el tiempo de TODOS los anillos
    //    activos cada tick y limpia exactamente al llegar a 0. No existe ningún
    //    camino por el que un anillo siga dibujado sin que el Driver lo esté
    //    contando => es IMPOSIBLE que un anillo "se quede pegado". Como cada
    //    anillo lleva su PROPIO tiempo restante, el barrido nunca borra uno
    //    todavía válido: solo cae el que ya cumplió su duración.
    //
    //    Blindajes adicionales:
    //      - CleanupRingByIdx es IDEMPOTENTE (guarda ringInUse): llamarlo dos
    //        veces sobre el mismo anillo no hace nada la segunda vez. Se acabó el
    //        doble-free / doble-destroy que envenenaba el pool de índices.
    //      - El pool está ACOTADO a MAX_RINGS con expulsión del más próximo a
    //        expirar => nunca crece sin límite ni desborda el array.
    //
    //    AISLAMIENTO: este sistema NO usa udg_MB_Hash ni ningún global/hashtable
    //    compartido. Todo su estado vive en arrays PRIVADOS de este scope + un
    //    único timer privado. No puede interferir con la tabla de kills/muertes/
    //    asistencias ni con ningún otro sistema.
    //
    //===========================================================================


    // ==========================================
    // ===   CONSTANTES Y ALMACENAMIENTO      ===
    // ==========================================

    globals
        constant integer RING_FOLLOW_CASTER = 0
        constant integer RING_STATIC_TARGET = 1
        constant integer RING_STATIC_CASTER = 2

        private constant integer MAX_SEGMENTS = 48   // Debe ser >= al mayor GetRingSegments
        private constant integer MAX_RINGS    = 64   // Tope del pool. 64*48=3072 < 8192 (límite de array)
        private constant real    TICK         = 0.03 // Periodo del motor (igual que antes, movimiento suave)
        private constant real    FADE_DURATION = 1.5 // Segundos extra para desvanecimiento
        private constant real    RING_BASE_ALPHA = 0.40 // Alpha base del estilo gris (resto de habilidades)
        private constant real    RING_ITEM_ALPHA = 0.05 // Alpha base de la categoría OBJETOS (pálido/sutil; sube=más visible, baja=casi invisible)

        // --- Estado por anillo (indexado por ringIdx 0..MAX_RINGS-1) ---
        private lightning array ringData        // [ringIdx * MAX_SEGMENTS + segmento]
        private boolean   array ringInUse       // dueño del slot: true mientras el anillo vive
        private unit      array ringCaster      // héroe que lo creó
        private integer   array ringAbil        // rawcode de la habilidad
        private integer   array ringMode        // RING_FOLLOW_CASTER / STATIC_TARGET / STATIC_CASTER
        private integer   array ringSeg         // nº de segmentos de ESTE anillo
        private real      array ringRadius      // radio (AoE) para mover los segmentos (modo FOLLOW)
        private real      array ringRemaining   // segundos de juego restantes (incluye el fade)
        private boolean   array ringTimed       // true = expira por tiempo; false = toggle (vive según buff)
        private integer   array ringToggleBuff  // buff del toggle (0 si no es toggle)
        private boolean   array ringSkipEndcast // toggle: ignorar UNA vez el ENDCAST de activación

        // --- Allocator de índices (pila de libres + marca de agua) ---
        private integer   array freeStack
        private integer freeCount = 0
        private integer nextIndex = 0

        // --- Lista compacta de anillos activos (iteración O(activos) y borrado O(1)) ---
        private integer   array activeList      // activeList[0..activeCount-1] = ringIdx
        private integer   array activePos       // activePos[ringIdx] = su posición en activeList
        private integer activeCount = 0

        // --- Motor ---
        private timer DriverTimer = null
        private boolean driverRunning = false
    endglobals


    // ==========================================
    // ===   CONFIGURACIÓN DE HABILIDADES     ===
    // ==========================================
    // Modifica estas funciones para agregar/cambiar habilidades.
    // Sigue los ejemplos existentes.

    // --- PASO 1: Registrar la habilidad ---
    // Agrega el raw code de tu habilidad con:  or id == 'XXXX'
    private function IsRegistered takes integer id returns boolean
        return id == 'AOww' or id == 'A046' or id == 'AOfs' or id == 'AEfk' or id == 'AHtc' or id == 'A00F' or id == 'AEsf' or id == 'AEtq' or id == 'AOws' or id == 'Awrs' or id == 'AOvd' or id == 'AUan' or id == 'AUls' or id == 'ANht' or id == 'AEim' or id == 'A03O' or id == 'A04L' or id == 'A03C' or id == 'AItb'
    endfunction

    // --- PASO 7 (opcional): Marcar como canalizada ---
    // Si la habilidad se puede interrumpir con stun y el anillo
    // debe desaparecer al interrumpirse, agrégala aquí.
    private function IsChanneled takes integer id returns boolean
        return id == 'AEsf' or id == 'AEtq' or id == 'AOvd'
    endfunction

    // --- PASO 8 (opcional): Marcar como Toggle ---
    // Habilidades que se activan/desactivan manualmente (ej: Inmolación).
    // El anillo aparece al activar y desaparece al desactivar o sin maná.
    private function IsToggle takes integer id returns boolean
        return id == 'AEim' or id == 'A03O'
    endfunction

    // --- PASO 9 (solo toggles): Buff asociado al toggle ---
    // Cuando este buff desaparece del héroe, el anillo se destruye.
    // Es lo que permite detectar la desactivación (WC3 no dispara eventos).
    private function GetToggleBuff takes integer id returns integer
        if (id == 'AEim') or (id == 'A03O') then
            return 'BEim'
        endif
        return 0
    endfunction

    // --- PASO 2: Modo de comportamiento ---
    private function GetRingMode takes integer id returns integer
        // Torbellino / Estrella Fugaz: sigue al héroe
        if (id == 'AOww') or (id == 'AEsf') or (id == 'AEtq') or (id == 'AOvd') or (id == 'AUls') or (id == 'AEim') or (id == 'A03O') then
            return RING_FOLLOW_CASTER
            // Vista Lejana: fijo donde apuntaste
        elseif (id == 'AOfs') or (id == 'A046') then
            return RING_STATIC_TARGET
            // Abanico / Trueno / Grito / Detector (objeto AItb): instantánea, centrada en el héroe
        elseif (id == 'AEfk') or (id == 'AHtc') or (id == 'A00F') or (id == 'AOws') or (id == 'Awrs') or (id == 'AUan') or (id == 'ANht') or (id == 'A04L') or (id == 'A03C') or (id == 'AItb') then
            return RING_STATIC_CASTER
        endif
        return RING_FOLLOW_CASTER
    endfunction

    // --- PASO 3: Tipo de relámpago ---
    private function GetRingLightningType takes integer id returns string
        if (id == 'AOww') or (id == 'AEfk') or (id == 'AHtc') or (id == 'A00F') or (id == 'AEsf') or (id == 'AEtq') or (id == 'AOws') or (id == 'Awrs') or (id == 'AOvd') or (id == 'AUan') or (id == 'AUls') or (id == 'ANht') or (id == 'AEim') or (id == 'A03O') or (id == 'A04L') or (id == 'A03C') then
            return "LEAS"
        elseif (id == 'AOfs') or (id == 'A046') then
            return "SPLK"
        elseif (id == 'AItb') then
            // Objeto detector: rayo frío/pálido (azul muy claro, casi blanco)
            return "DRAM"
        endif
        return "LEAS"
    endfunction

    // --- PASO 4: Número de segmentos ---
    // Más segmentos = círculo más suave (18-36 recomendado)
    private function GetRingSegments takes integer id returns integer
        if (id == 'AOww') or (id == 'AEim') or (id == 'A03O') then
            return 18
        elseif (id == 'AEfk') or (id == 'AHtc') or (id == 'A00F') or (id == 'AEtq') or (id == 'AEsf') or (id == 'AOws') or (id == 'Awrs') or (id == 'AOvd') or (id == 'AUan') or (id == 'AUls') or (id == 'ANht') or (id == 'A04L') or (id == 'A03C') then
            return 24
        elseif (id == 'AOfs') or (id == 'A046') or (id == 'AItb') then
            return 42
        endif
        return 24
    endfunction

    // --- PASO 4b: Categoría OBJETOS (anillos con color propio) ---
    // Anillos que vienen de un ÍTEM y deben verse distintos al resto:
    // blanco muy fino y casi invisible, en vez del gris de las habilidades.
    // Para sumar otro objeto a esta categoría: agrega  or id == 'XXXX'
    private function IsItemRing takes integer id returns boolean
        return id == 'AItb'
    endfunction

    // --- PASO 4c: Color y opacidad del anillo ---
    // Usa SetLightningColor(l, rojo, verde, azul, alpha). Valores de 0.0 a 1.0;
    // alpha bajo = más transparente. `alphaScale` (0.0 a 1.0) atenúa la opacidad
    // base: 1.0 = opacidad plena; durante el desvanecimiento baja de 1.0 a 0.0.
    //
    // FUENTE ÚNICA del color: tanto la creación como el fade llaman aquí, así
    // que el color/opacidad de cada anillo se define en UN solo lugar.
    //
    // ESTILOS:
    //   Gris sutil (habilidades): 0.55, 0.55, 0.60  @ RING_BASE_ALPHA
    //   Blanco casi invisible (objetos): 1.00, 1.00, 1.00  @ RING_ITEM_ALPHA
    //
    private function ApplyRingColorScaled takes lightning l, integer id, real alphaScale returns nothing
        if IsItemRing(id) then
            // Categoría OBJETOS: blanco muy sutil, casi invisible
            call SetLightningColor(l, 1.00, 1.00, 1.00, RING_ITEM_ALPHA * alphaScale)
        else
            // Estilo sutil gris para el resto de las habilidades
            call SetLightningColor(l, 0.55, 0.55, 0.60, RING_BASE_ALPHA * alphaScale)
        endif
    endfunction

    // --- PASO 5: Área de efecto por nivel ---
    // Debe coincidir con el Editor de Objetos.
    private function GetRingAoE takes integer id, integer level returns real
        // ========== TORBELLINO DE CUCHILLAS (AOww) — 6 niveles ==========
        if (id == 'AOww') then
            if (level == 1) then
                return 200.0
            elseif (level == 2) then
                return 250.0
            elseif (level == 3) then
                return 300.0
            elseif (level == 4) then
                return 350.0
            elseif (level == 5) then
                return 400.0
            elseif (level == 6) then
                return 500.0
            endif
            return 200.0
            // ========== VISTA LEJANA (AOfs) — 10 niveles ==========
        elseif (id == 'AOfs') or (id == 'A046') then
            if (level == 1) then
                return 1200.0
            elseif (level == 2) then
                return 1400.0
            elseif (level == 3) then
                return 1700.0
            elseif (level == 4) then
                return 2000.0
            elseif (level == 5) then
                return 2500.0
            elseif (level == 6) then
                return 3200.0
            elseif (level == 7) then
                return 3600.0
            elseif (level == 8) then
                return 3800.0
            elseif (level == 9) then
                return 4200.0
            elseif (level == 10) then
                return 4600.0
            endif
            return 1400.0
            // ========== ABANICO DE CUCHILLAS (AEfk) — 10 niveles ==========
        elseif (id == 'AEfk') then
            if (level == 1) then
                return 400.0
            elseif (level == 2) then
                return 427.0
            elseif (level == 3) then
                return 454.0
            elseif (level == 4) then
                return 481.0
            elseif (level == 5) then
                return 508.0
            elseif (level == 6) then
                return 535.0
            elseif (level == 7) then
                return 562.0
            elseif (level == 8) then
                return 589.0
            elseif (level == 9) then
                return 616.0
            elseif (level == 10) then
                return 643.0
            endif
            return 400.0
            // ========== TRUENO (AHtc) — 10 niveles ==========
        elseif (id == 'AHtc') then
            if (level == 1) then
                return 250.0
            elseif (level == 2) then
                return 300.0
            elseif (level == 3) then
                return 350.0
            elseif (level == 4) then
                return 400.0
            elseif (level == 5) then
                return 450.0
            elseif (level == 6) then
                return 500.0
            elseif (level == 7) then
                return 550.0
            elseif (level == 8) then
                return 600.0
            elseif (level == 9) then
                return 650.0
            elseif (level == 10) then
                return 700.0
            endif
            return 250.0
            // ========== GRITO DE GUERRA (A00F) — 650 fijo ==========
        elseif (id == 'A00F') then
            return 650.0
            // ========== PISOTÓN (AOws) — 300 fijo ==========
        elseif (id == 'AOws') then
            return 300.0
            // ========== PISOTÓN GUARDIAN DEL APOCALIPSIS (Awrs) — 250 fijo, sin niveles ==========
        elseif (id == 'Awrs') then
            return 250.0
            // ========== ANIMAR A LOS MUERTOS (AUan) — 900 fijo ==========
        elseif (id == 'AUan') then
            return 900.0
            // ========== APLAUSO DE MIRMIDÓN (A04L) — 6 niveles ==========
        elseif (id == 'A04L') then
            if (level == 1) then
                return 500.0
            elseif (level == 2) then
                return 580.0
            elseif (level == 3) then
                return 660.0
            elseif (level == 4) then
                return 740.0
            elseif (level == 5) then
                return 820.0
            elseif (level == 6) then
                return 900.0
            endif
            return 500.0
            // ========== BENDICIÓN DE ZEUS (A03C) — 10 niveles ==========
        elseif (id == 'A03C') then
            if (level == 1) then
                return 570.0
            elseif (level == 2) then
                return 610.0
            elseif (level == 3) then
                return 650.0
            elseif (level == 4) then
                return 690.0
            elseif (level == 5) then
                return 730.0
            elseif (level == 6) then
                return 770.0
            elseif (level == 7) then
                return 810.0
            elseif (level == 8) then
                return 850.0
            elseif (level == 9) then
                return 890.0
            elseif (level == 10) then
                return 930.0
            endif
            return 570.0
            // ========== INMOLACIÓN (AEim / A03O) — 10 niveles ==========
        elseif (id == 'AEim') or (id == 'A03O') then
            if (level == 1) then
                return 160.0
            elseif (level == 2) then
                return 164.0
            elseif (level == 3) then
                return 168.0
            elseif (level == 4) then
                return 172.0
            elseif (level == 5) then
                return 176.0
            elseif (level == 6) then
                return 180.0
            elseif (level == 7) then
                return 184.0
            elseif (level == 8) then
                return 188.0
            elseif (level == 9) then
                return 192.0
            elseif (level == 10) then
                return 196.0
            endif
            return 160.0
            // ========== AULLIDO DE TERROR (ANht) — 10 niveles ==========
        elseif (id == 'ANht') then
            if (level == 1) then
                return 600.0
            elseif (level == 2) then
                return 645.0
            elseif (level == 3) then
                return 690.0
            elseif (level == 4) then
                return 735.0
            elseif (level == 5) then
                return 780.0
            elseif (level == 6) then
                return 825.0
            elseif (level == 7) then
                return 870.0
            elseif (level == 8) then
                return 915.0
            elseif (level == 9) then
                return 960.0
            elseif (level == 10) then
                return 1000.0
            endif
            return 600.0
            // ========== ESTRELLA FUGAZ (AEsf) — 900 fijo ==========
        elseif (id == 'AEsf') then
            return 900.0
            // ========== TRANQUILIDAD (AEtq) — 6 niveles ==========
        elseif (id == 'AEtq') then
            if (level == 1) then
                return 850.0
            elseif (level == 2) then
                return 900.0
            elseif (level == 3) then
                return 950.0
            elseif (level == 4) then
                return 1000.0
            elseif (level == 5) then
                return 1050.0
            elseif (level == 6) then
                return 1100.0
            endif
            return 850.0
            // ========== GRAN VUDÚ MALVADO (AOvd) — 6 niveles ==========
        elseif (id == 'AOvd') then
            if (level == 1) then
                return 700.0
            elseif (level == 2) then
                return 800.0
            elseif (level == 3) then
                return 1000.0
            elseif (level == 4) then
                return 1200.0
            elseif (level == 5) then
                return 1400.0
            elseif (level == 6) then
                return 1600.0
            endif
            return 700.0
            // ========== Enjambre de Langostas (AUls) — 6 niveles ==========
        elseif (id == 'AUls') then
            if (level == 1) then
                return 800.0
            elseif (level == 2) then
                return 890.0
            elseif (level == 3) then
                return 980.0
            elseif (level == 4) then
                return 1070.0
            elseif (level == 5) then
                return 1160.0
            elseif (level == 6) then
                return 1250.0
            endif
            return 1250.0
            // ========== DETECTOR (objeto AItb) — 1000 fijo, sin niveles ==========
        elseif (id == 'AItb') then
            return 1000.0
        endif
        return 0.0
    endfunction

    // --- PASO 6: Duración por nivel ---
    // Debe coincidir con la duración real de la habilidad.
    private function GetRingDuration takes integer id, integer level returns real
        // ========== TORBELLINO DE CUCHILLAS (AOww) — 6 niveles ==========
        if (id == 'AOww') then
            if (level == 1) then
                return 7.0
            elseif (level == 2) then
                return 7.0
            elseif (level == 3) then
                return 7.0
            elseif (level == 4) then
                return 7.0
            elseif (level == 5) then
                return 7.0
            elseif (level == 6) then
                return 7.0
            endif
            return 7.0
            // ========== VISTA LEJANA (AOfs) — 10 niveles ==========
        elseif (id == 'AOfs') or (id == 'A046') then
            if (level == 1) then
                return 8.0
            elseif (level == 2) then
                return 9.0
            elseif (level == 3) then
                return 10.0
            elseif (level == 4) then
                return 11.0
            elseif (level == 5) then
                return 12.0
            elseif (level == 6) then
                return 12.0
            elseif (level == 7) then
                return 12.0
            elseif (level == 8) then
                return 12.0
            elseif (level == 9) then
                return 12.0
            elseif (level == 10) then
                return 12.0
            endif
            return 8.0
            // ====== ABANICO / TRUENO / GRITO / DETECTOR (objeto AItb) — 1s fijo ======
        elseif (id == 'AEfk') or (id == 'AHtc') or (id == 'A00F') or (id == 'AOws') or (id == 'Awrs') or (id == 'AUan') or (id == 'ANht') or (id == 'A04L') or (id == 'A03C') or (id == 'AItb') then
            return 1.0
            // ========== ESTRELLA FUGAZ (AEsf) — 6 niveles ==========
        elseif (id == 'AEsf') then
            if (level == 1) then
                return 25.0
            elseif (level == 2) then
                return 28.0
            elseif (level == 3) then
                return 31.0
            elseif (level == 4) then
                return 34.0
            elseif (level == 5) then
                return 37.0
            elseif (level == 6) then
                return 40.0
            endif
            return 25.0
            // ========== TRANQUILIDAD (AEtq) — 6 niveles ==========
        elseif (id == 'AEtq') then
            if (level == 1) then
                return 30.0
            elseif (level == 2) then
                return 25.0
            elseif (level == 3) then
                return 20.0
            elseif (level == 4) then
                return 15.0
            elseif (level == 5) then
                return 10.0
            elseif (level == 6) then
                return 8.0
            endif
            return 30.0
            // ========== GRAN VUDÚ MALVADO (AOvd) — 40s fijo ==========
        elseif (id == 'AOvd') then
            return 40.0
            // ========== Enjambre de Langostas (AUls) — 20s fijo ==========
        elseif (id == 'AUls') then
            return 20.0
            // ========== INMOLACIÓN (AEim / A03O) — Toggle, duración de seguridad ==========
        elseif (id == 'AEim') or (id == 'A03O') then
            return 9999.0
        endif
        return 0.0
    endfunction


    // ==========================================
    // ===   ALLOCATOR DE ÍNDICES (interno)   ===
    // ==========================================

    private function FreeRing takes integer idx returns nothing
        set freeStack[freeCount] = idx
        set freeCount = freeCount + 1
    endfunction

    // Devuelve un índice libre, o -1 si el pool está lleno (el llamador debe
    // expulsar primero con EvictOneRing). Nunca crece más allá de MAX_RINGS.
    private function AllocRing takes nothing returns integer
        local integer idx
        if (freeCount > 0) then
            set freeCount = freeCount - 1
            set idx = freeStack[freeCount]
        elseif (nextIndex < MAX_RINGS) then
            set idx = nextIndex
            set nextIndex = nextIndex + 1
        else
            return -1
        endif
        return idx
    endfunction


    // ==========================================
    // ===   BÚSQUEDA POR CASTER+HABILIDAD    ===
    // ==========================================
    // Reemplaza la antigua referencia caster->timer guardada en udg_MB_Hash.
    // Solo se llama en eventos poco frecuentes (ENDCAST / re-toggle), así que
    // un escaneo lineal de la lista activa (<= MAX_RINGS) es de sobra barato y,
    // a cambio, este sistema no toca NINGÚN hashtable compartido.

    private function FindRingByCasterAbil takes unit caster, integer abilId returns integer
        local integer i = 0
        local integer idx
        loop
            exitwhen i >= activeCount
            set idx = activeList[i]
            if (ringCaster[idx] == caster) and (ringAbil[idx] == abilId) then
                return idx
            endif
            set i = i + 1
        endloop
        return -1
    endfunction


    // ==========================================
    // ===   LIMPIEZA DE ANILLO (interno)     ===
    // ==========================================
    //
    // IDEMPOTENTE: la guarda ringInUse hace que una segunda llamada sobre el
    // mismo anillo no haga absolutamente nada. Eso elimina el doble-free / el
    // doble-destroy que antes envenenaba el pool y dejaba relámpagos huérfanos.

    private function CleanupRingByIdx takes integer idx returns nothing
        local integer base
        local integer numSeg
        local integer i
        local integer lastIdx

        if (idx < 0) then
            return
        endif
        if (not ringInUse[idx]) then
            return  // ya fue limpiado: no repetir nada
        endif
        set ringInUse[idx] = false  // marcar PRIMERO => a prueba de re-entrada

        // Destruir todos los segmentos de lightning de este anillo
        set base = idx * MAX_SEGMENTS
        set numSeg = ringSeg[idx]
        set i = 0
        loop
            exitwhen i >= numSeg
            if (ringData[base + i] != null) then
                call DestroyLightning(ringData[base + i])
                set ringData[base + i] = null
            endif
            set i = i + 1
        endloop

        // Sacar de la lista activa (swap-remove O(1) con el último)
        set lastIdx = activeList[activeCount - 1]
        set activeList[activePos[idx]] = lastIdx
        set activePos[lastIdx] = activePos[idx]
        set activeCount = activeCount - 1

        set ringCaster[idx] = null
        call FreeRing(idx)
    endfunction


    // Expulsa UN anillo cuando el pool está lleno. Elige el más próximo a
    // expirar (el menos disruptivo visualmente), prefiriendo anillos con tiempo
    // sobre toggles. Solo se ejecuta en el caso extremo de pool saturado.
    private function EvictOneRing takes nothing returns nothing
        local integer i = 0
        local integer idx
        local integer victim = -1
        local real best = 0.0
        loop
            exitwhen i >= activeCount
            set idx = activeList[i]
            if ringTimed[idx] then
                if (victim == -1) or (ringRemaining[idx] < best) then
                    set victim = idx
                    set best = ringRemaining[idx]
                endif
            endif
            set i = i + 1
        endloop
        if (victim == -1) and (activeCount > 0) then
            set victim = activeList[0]  // todos son toggles: cae el más antiguo
        endif
        if (victim != -1) then
            call CleanupRingByIdx(victim)
        endif
    endfunction


    // ==========================================
    // ===   MOTOR ÚNICO (Driver, cada 0.03s) ===
    // ==========================================
    //
    // Recorre SOLO los anillos activos. Para cada uno: descuenta tiempo,
    // chequea condiciones de salida, mueve los segmentos (modo FOLLOW) y aplica
    // el fade del último segundo. Cuando no queda ninguno, se pausa solo.

    private function Driver takes nothing returns nothing
        local integer i = 0
        local integer idx
        local integer mode
        local integer numSeg
        local integer base
        local unit caster
        local real radius
        local real cx
        local real cy
        local real step
        local real a1
        local real a2
        local real alpha
        local integer s
        local boolean kill

        loop
            exitwhen i >= activeCount
            set idx = activeList[i]
            set mode = ringMode[idx]
            set caster = ringCaster[idx]
            set kill = false

            // --- CONDICIONES DE SALIDA ---
            if ringTimed[idx] then
                set ringRemaining[idx] = ringRemaining[idx] - TICK
                if (ringRemaining[idx] <= 0.0) then
                    set kill = true
                endif
            endif
            if (not kill) and (mode == RING_FOLLOW_CASTER) and (GetWidgetLife(caster) <= 0.405) then
                set kill = true
            endif
            // Toggle: si el buff ya no está en el héroe → desactivado o sin maná
            if (not kill) and (not ringTimed[idx]) and (GetUnitAbilityLevel(caster, ringToggleBuff[idx]) == 0) then
                set kill = true
            endif

            if kill then
                call CleanupRingByIdx(idx)
                // NO incrementar i: la posición i ahora tiene el anillo movido
            else
                // --- FOLLOW mueve los segmentos (el centro sigue al héroe) ---
                if (mode == RING_FOLLOW_CASTER) then
                    set numSeg = ringSeg[idx]
                    set base = idx * MAX_SEGMENTS
                    set radius = ringRadius[idx]
                    set cx = GetUnitX(caster)
                    set cy = GetUnitY(caster)
                    set step = 2.0 * bj_PI / I2R(numSeg)
                    set s = 0
                    loop
                        exitwhen s >= numSeg
                        set a1 = I2R(s) * step
                        set a2 = I2R(s + 1) * step
                        call MoveLightning(ringData[base + s], false, cx + radius * Cos(a1), cy + radius * Sin(a1), cx + radius * Cos(a2), cy + radius * Sin(a2))
                        set s = s + 1
                    endloop
                endif

                // --- FADE-OUT en el último segundo (solo anillos con tiempo) ---
                if ringTimed[idx] and (ringRemaining[idx] <= FADE_DURATION) then
                    set numSeg = ringSeg[idx]
                    set base = idx * MAX_SEGMENTS
                    // Escala de opacidad: baja de 1.0 a 0.0 durante FADE_DURATION.
                    // ApplyRingColorScaled la multiplica por el alpha base de cada
                    // anillo, así el color/opacidad sale de UNA sola fuente.
                    set alpha = ringRemaining[idx] / FADE_DURATION
                    set s = 0
                    loop
                        exitwhen s >= numSeg
                        call ApplyRingColorScaled(ringData[base + s], ringAbil[idx], alpha)
                        set s = s + 1
                    endloop
                endif

                set i = i + 1
            endif
        endloop

        // Sin anillos activos → apagar el motor (cero coste en reposo)
        if (activeCount == 0) then
            call PauseTimer(DriverTimer)
            set driverRunning = false
        endif

        set caster = null
    endfunction


    // Arranca el motor si está dormido. Idempotente.
    private function EnsureDriverRunning takes nothing returns nothing
        if (not driverRunning) then
            set driverRunning = true
            call TimerStart(DriverTimer, TICK, true, function Driver)
        endif
    endfunction

    // Añade un anillo a la lista activa y garantiza que el motor corra.
    private function ActivateRing takes integer idx returns nothing
        set activeList[activeCount] = idx
        set activePos[idx] = activeCount
        set activeCount = activeCount + 1
        call EnsureDriverRunning()
    endfunction


    // ==========================================
    // ===   DETONADOR (SPELL_EFFECT)         ===
    // ==========================================

    private function OnCast takes nothing returns nothing
        local integer abilId = GetSpellAbilityId()
        local unit caster = GetTriggerUnit()
        local integer level = GetUnitAbilityLevel(caster, abilId)
        local integer mode = GetRingMode(abilId)
        local real aoe = GetRingAoE(abilId, level)
        local real dur = GetRingDuration(abilId, level)
        local integer numSeg = GetRingSegments(abilId)
        local string ltype = GetRingLightningType(abilId)
        local boolean toggle = IsToggle(abilId)
        local real cx
        local real cy
        local real step
        local real a1
        local real a2
        local integer ringIdx
        local integer base
        local integer i
        local integer oldIdx

        // Seguridad: capear segmentos al máximo permitido
        if (numSeg > MAX_SEGMENTS) then
            set numSeg = MAX_SEGMENTS
        endif

        // Seguridad: si el nivel no tiene AoE o duración, no crear anillo
        if (aoe <= 0.0) or (dur <= 0.0) then
            set caster = null
            return
        endif

        // --- TOGGLE: si queda un anillo viejo de este mismo toggle, limpiarlo ---
        if toggle then
            set oldIdx = FindRingByCasterAbil(caster, abilId)
            if (oldIdx >= 0) then
                call CleanupRingByIdx(oldIdx)
            endif
        endif

        // --- DETERMINAR CENTRO según el modo ---
        if (mode == RING_STATIC_TARGET) then
            set cx = GetSpellTargetX()
            set cy = GetSpellTargetY()
        else
            set cx = GetUnitX(caster)
            set cy = GetUnitY(caster)
        endif

        // --- CAPACIDAD: si el pool está lleno, expulsar el más próximo a expirar ---
        if (freeCount == 0) and (nextIndex >= MAX_RINGS) then
            call EvictOneRing()
        endif
        set ringIdx = AllocRing()
        if (ringIdx < 0) then
            // No debería ocurrir (acabamos de expulsar); aborta limpio si pasa
            set caster = null
            return
        endif

        // --- CREAR ANILLO ---
        set base = ringIdx * MAX_SEGMENTS
        set step = 2.0 * bj_PI / I2R(numSeg)
        set i = 0
        loop
            exitwhen i >= numSeg
            set a1 = I2R(i) * step
            set a2 = I2R(i + 1) * step
            set ringData[base + i] = AddLightning(ltype, false, cx + aoe * Cos(a1), cy + aoe * Sin(a1), cx + aoe * Cos(a2), cy + aoe * Sin(a2))
            call ApplyRingColorScaled(ringData[base + i], abilId, 1.0)
            set i = i + 1
        endloop

        // --- REGISTRAR ESTADO DEL ANILLO ---
        set ringInUse[ringIdx] = true
        set ringCaster[ringIdx] = caster
        set ringAbil[ringIdx] = abilId
        set ringMode[ringIdx] = mode
        set ringSeg[ringIdx] = numSeg
        set ringRadius[ringIdx] = aoe
        set ringSkipEndcast[ringIdx] = false
        if toggle then
            // Toggle: vive según el buff, no por tiempo. Ignora el ENDCAST de activación.
            set ringTimed[ringIdx] = false
            set ringToggleBuff[ringIdx] = GetToggleBuff(abilId)
            set ringSkipEndcast[ringIdx] = true
        else
            set ringTimed[ringIdx] = true
            set ringToggleBuff[ringIdx] = 0
            set ringRemaining[ringIdx] = dur + FADE_DURATION  // +fade para el desvanecimiento
        endif

        call ActivateRing(ringIdx)

        set caster = null
    endfunction


    // ==========================================
    // ===   LIMPIEZA POR INTERRUPCIÓN        ===
    // ==========================================
    //
    // Solo para habilidades CANALIZADAS (IsChanneled) y TOGGLES (IsToggle).
    // Cuando el canal se interrumpe (stun, hex, silencio, red, muerte),
    // WC3 dispara ENDCAST y destruimos el anillo de inmediato.
    //
    // Para habilidades NO canalizadas, ENDCAST se dispara INMEDIATAMENTE
    // al castear (WC3 las trata como casts instantáneos), por eso
    // ConditionsEndCast filtra y solo deja pasar canalizadas/toggles.
    //

    private function OnEndCast takes nothing returns nothing
        local integer abilId = GetSpellAbilityId()
        local unit caster = GetTriggerUnit()
        local integer idx = FindRingByCasterAbil(caster, abilId)

        if (idx >= 0) then
            // Toggle: ignorar el ENDCAST que WC3 dispara al ACTIVAR.
            // Solo responder al ENDCAST de desactivación (ej: maná = 0).
            if IsToggle(abilId) and ringSkipEndcast[idx] then
                set ringSkipEndcast[idx] = false
                set caster = null
                return
            endif
            call CleanupRingByIdx(idx)
        endif

        set caster = null
    endfunction


    // ==========================================
    // ===       INICIALIZACIÓN               ===
    // ==========================================

    private function Conditions takes nothing returns boolean
        return IsRegistered(GetSpellAbilityId())
    endfunction

    // Canalizadas + Toggles necesitan responder a ENDCAST
    private function ConditionsEndCast takes nothing returns boolean
        local integer id = GetSpellAbilityId()
        return IsRegistered(id) and (IsChanneled(id) or IsToggle(id))
    endfunction

    private function Init takes nothing returns nothing
        local trigger tCast = CreateTrigger()
        local trigger tEnd = CreateTrigger()

        // Motor único (privado). Arranca dormido; ActivateRing lo despierta.
        set DriverTimer = CreateTimer()

        // Detectar CAST de cualquier habilidad registrada
        call TriggerRegisterAnyUnitEventBJ(tCast, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        call TriggerAddCondition(tCast, Condition(function Conditions))
        call TriggerAddAction(tCast, function OnCast)

        // Detectar FIN DE CANAL (solo canalizadas / toggles)
        call TriggerRegisterAnyUnitEventBJ(tEnd, EVENT_PLAYER_UNIT_SPELL_ENDCAST)
        call TriggerAddCondition(tEnd, Condition(function ConditionsEndCast))
        call TriggerAddAction(tEnd, function OnEndCast)

        set tCast = null
        set tEnd = null
    endfunction

endscope
