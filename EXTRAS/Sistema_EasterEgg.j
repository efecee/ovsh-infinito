// ==========================================================================
// Sistema_EasterEgg.j
// ==========================================================================
//
// PROPÓSITO:
//   Maneja la reaparición del Ave Errante ("Easter Egg") cuando es asesinada.
//   Escrito estrictamente en JASS usando Timers y Coordenadas X/Y para 
//   cumplir con la Arquitectura (Cero Location, cero Wait).
//
// MOVIMIENTO:
//   Usa IssuePointOrder("move") re-emitido cada MOVE_INTERVAL segundos.
//   Esto garantiza que el ave siempre tenga un destino nuevo y nunca
//   se quede quieta tras llegar a un punto.
//
// WATCHDOG ANTI-ATASCADO:
//   CreateUnit es el ÚNICO teletransporte del sistema: ignora el pathing y
//   puede depositar al ave dentro de una zona sellada (zonas de selección,
//   montaña central) de la que jamás podría salir volando. El resultado sería
//   un ave inalcanzable para siempre y el easter egg muerto en silencio: el
//   respawn solo se dispara con la muerte, así que nadie se enteraría.
//
//   Detección: el ave recibe una orden nueva cada MOVE_INTERVAL segundos SÍ O
//   SÍ, luego la quietud legítima máxima es MOVE_INTERVAL (llegó temprano y
//   espera). Superado STUCK_TIMEOUT sin desplazarse, la única explicación
//   posible es que no puede moverse. Se reubica y se reintenta.
//
//   Por qué basta con medir quietud: GenerateSafeCoords filtra los destinos,
//   así que TODO destino que el ave recibe está fuera de las zonas prohibidas.
//   Un ave encerrada solo recibe órdenes hacia el otro lado del muro, no tiene
//   a dónde pasear adentro. Queda inmóvil, no confinada-pero-móvil.
//
// ==========================================================================

library SistemaEasterEgg initializer Init

    globals
        // ==========================================
        // CONFIGURACIÓN DE IDs (Ajustar en el Editor)
        // ==========================================
        constant integer UNIT_AVE_EASTER_EGG = 'nmdm' // La unidad
        constant integer ITEM_EASTER_EGG     = 'I014' // El objeto a soltar
        
        // ==========================================
        // CONFIGURACIÓN DE SISTEMA
        // ==========================================
        constant real RESPAWN_TIME     = 300.0
        constant real MOVE_INTERVAL    = 7.0   // Re-emitir orden de movimiento cada N segundos
        constant real FIRST_MOVE_DELAY = 1.0   // Retardo antes de la primera orden post-spawn

        // ==========================================
        // CONFIGURACIÓN DEL WATCHDOG ANTI-ATASCADO
        // ==========================================
        // STUCK_TIMEOUT DEBE ser mayor que MOVE_INTERVAL: el ave que llegó a su
        // destino espera legítimamente hasta MOVE_INTERVAL segundos por la orden
        // siguiente. El margen (10 - 7 = 3s) absorbe el desfase del muestreo.
        // Si algún día se sube MOVE_INTERVAL, SUBIR ESTE TAMBIÉN.
        constant real STUCK_TIMEOUT        = 10.0  // Quietud máxima tolerada antes de rescatar
        constant real STUCK_CHECK_INTERVAL = 2.0   // Cada cuánto se muestrea la posición
        // Radio bajo el cual se considera que el ave "no se movió". No se compara
        // posición exacta: un ave apoyada contra un muro puede rozarlo unas pocas
        // unidades sin estar avanzando a ningún lado.
        constant real STUCK_TOLERANCE      = 64.0

        // Tope de reintentos del generador de coordenadas. Evita congelar el hilo
        // si las zonas prohibidas crecieran hasta cubrir casi todo el mapa.
        constant integer SAFE_COORDS_TRIES = 50

        // ==========================================
        // VARIABLES INTERNAS
        // ==========================================
        private unit  BirdUnit  = null
        private timer MoveTimer = CreateTimer()
        // Outputs del generador de coordenadas seguras
        private real  SafeX     = 0.0
        private real  SafeY     = 0.0
        // Estado del watchdog: última posición muestreada y quietud acumulada
        private timer StuckTimer = CreateTimer()
        private real  LastX      = 0.0
        private real  LastY      = 0.0
        private real  StuckTime  = 0.0
    endglobals

    // ==========================================================
    // GENERADOR DE COORDENADAS SEGURAS
    // Genera X/Y aleatorias que no caigan en zonas de selección.
    // Retorna valores vía las globals SafeX / SafeY.
    // ==========================================================
    private function GenerateSafeCoords takes nothing returns nothing
        local real minX = GetRectMinX(bj_mapInitialPlayableArea)
        local real maxX = GetRectMaxX(bj_mapInitialPlayableArea)
        local real minY = GetRectMinY(bj_mapInitialPlayableArea)
        local real maxY = GetRectMaxY(bj_mapInitialPlayableArea)
        local integer tries = 0

        loop
            set SafeX = GetRandomReal(minX, maxX)
            set SafeY = GetRandomReal(minY, maxY)
            set tries = tries + 1
            // Salir solo si las coordenadas NO caen dentro de ninguna zona de selección
            exitwhen not RectContainsCoords(gg_rct_ZonaHumanos, SafeX, SafeY) and not RectContainsCoords(gg_rct_ZonaOrcos, SafeX, SafeY)
            // Válvula de escape: nunca colgar el hilo. Si se agotan los intentos se
            // acepta el último candidato aunque sea malo — el watchdog lo rescata a
            // los STUCK_TIMEOUT segundos. Un punto malo se corrige solo; un bucle
            // infinito congela la partida entera.
            exitwhen tries >= SAFE_COORDS_TRIES
        endloop
    endfunction

    // ==========================================================
    // ORDEN DE MOVIMIENTO ALEATORIO
    // Elige un destino seguro y ordena al ave moverse allí.
    // ==========================================================
    private function MoveBird takes nothing returns nothing
        if BirdUnit != null and GetWidgetLife(BirdUnit) > 0.405 then
            call GenerateSafeCoords()
            call IssuePointOrder(BirdUnit, "move", SafeX, SafeY)
        endif
    endfunction

    // ==========================================================
    // WATCHDOG: RESCATE DEL AVE ATASCADA
    // Muestrea la posición. Si el ave no se desplaza pese a tener
    // órdenes vigentes, nació en un punto sellado del que no puede
    // salir: se la reubica y se reintenta hasta que quede libre.
    // ==========================================================
    private function CheckStuck takes nothing returns nothing
        local real x
        local real y
        local real dx
        local real dy

        // GUARDA IMPRESCINDIBLE: sin ave viva no hay nada que vigilar.
        // GetUnitX sobre una referencia nula devuelve 0.0, y un valor que nunca
        // cambia haría que el ave MUERTA pareciera atascada. El "rescate" crearía
        // movimiento durante los 300s de respawn y terminaríamos con dos aves.
        if BirdUnit == null or GetWidgetLife(BirdUnit) <= 0.405 then
            set StuckTime = 0.0
            return
        endif

        set x = GetUnitX(BirdUnit)
        set y = GetUnitY(BirdUnit)
        set dx = x - LastX
        set dy = y - LastY

        // Se desplazó más que la tolerancia: el ave está sana, reiniciar conteo.
        if dx * dx + dy * dy > STUCK_TOLERANCE * STUCK_TOLERANCE then
            set LastX = x
            set LastY = y
            set StuckTime = 0.0
            return
        endif

        // Sigue en el mismo sitio. Acumular y salir si aún no se agotó el plazo.
        set StuckTime = StuckTime + STUCK_CHECK_INTERVAL
        if StuckTime < STUCK_TIMEOUT then
            return
        endif

        // ===== ATASCADA =====
        // Reubicar con SetUnitX/Y, NUNCA con CreateUnit: crear otra ave dejaría
        // a ésta encerrada para siempre y duplicaría tanto el ave como el objeto
        // que suelta al morir.
        call GenerateSafeCoords()
        // OJO: SafeX/SafeY son globales y MoveBird las sobrescribe al pedir un
        // destino nuevo. Copiar a locales ANTES de llamarla, o el ping acabaría
        // marcando el destino en vez de la posición real del ave.
        set x = SafeX
        set y = SafeY

        call SetUnitX(BirdUnit, x)
        call SetUnitY(BirdUnit, y)

        set LastX = x
        set LastY = y
        set StuckTime = 0.0

        // Aviso: el ave cambió de lugar, los jugadores deben poder encontrarla.
        call PingMinimap(x, y, 3.0)

        // Orden inmediata + realineado del ciclo: sin esto el ave quedaría hasta
        // MOVE_INTERVAL segundos flotando sin rumbo después del rescate.
        call MoveBird()
        call TimerStart(MoveTimer, MOVE_INTERVAL, true, function MoveBird)
    endfunction

    // ==========================================================
    // ARRANQUE DEL MOVIMIENTO PERIÓDICO
    // Se ejecuta 1.0s después del spawn. Emite la primera orden
    // y luego arranca el timer periódico cada MOVE_INTERVAL.
    // ==========================================================
    private function StartPeriodicMove takes nothing returns nothing
        // Destruir el timer one-shot del retardo inicial
        call DestroyTimer(GetExpiredTimer())

        // Si el ave murió durante FIRST_MOVE_DELAY no hay nada que arrancar
        // (OnDeath ya pausó los timers; arrancarlos aquí los reviviría en vacío).
        if BirdUnit == null or GetWidgetLife(BirdUnit) <= 0.405 then
            return
        endif

        // Primera orden de movimiento
        call MoveBird()

        // Arrancar re-emisión periódica de órdenes (cada MOVE_INTERVAL el ave recibe nuevo destino)
        call TimerStart(MoveTimer, MOVE_INTERVAL, true, function MoveBird)

        // Watchdog: arranca JUNTO con el movimiento, no en el spawn. Durante
        // FIRST_MOVE_DELAY el ave está quieta de forma legítima (todavía no
        // recibió ninguna orden) y contarlo como atasco sería un falso positivo.
        set LastX = GetUnitX(BirdUnit)
        set LastY = GetUnitY(BirdUnit)
        set StuckTime = 0.0
        call TimerStart(StuckTimer, STUCK_CHECK_INTERVAL, true, function CheckStuck)
    endfunction

    // ==========================================================
    // FUNCIÓN DE CREACIÓN: Spawnea un ave en el mapa
    // ==========================================================
    private function SpawnBird takes nothing returns nothing
        // Generar coordenadas seguras para el spawn (excluye zonas de selección)
        call GenerateSafeCoords()

        // Crear la unidad para Neutral Pasivo para que no ataque a nadie
        set BirdUnit = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), UNIT_AVE_EASTER_EGG, SafeX, SafeY, bj_UNIT_FACING)

        // Desactivar el "guard position" que ancla creeps a su punto de spawn
        call SetUnitCreepGuard(BirdUnit, false)

        // Inmunidad a magia: configurada en el Object Editor con
        // "Conjuro de inmunidad (Hostil neutral)" en campo uabi de la unidad.

        // Programar: 1.0s de gracia → primera orden + arranque periódico
        call TimerStart(CreateTimer(), FIRST_MOVE_DELAY, false, function StartPeriodicMove)

        // === Ping en el minimapa para encontrarla ===
        call PingMinimap(SafeX, SafeY, 3.0)
    endfunction

    // ==========================================================
    // CALLBACK DEL TIMER: Reaparición después de morir
    // ==========================================================
    private function RespawnBird takes nothing returns nothing
        local timer t = GetExpiredTimer()
        
        call SpawnBird()

        // Limpiar memoria
        call DestroyTimer(t)
        set t = null
    endfunction

    // ==========================================================
    // EVENTO DE MUERTE
    // ==========================================================
    private function OnDeath takes nothing returns boolean
        local timer t
        
        // Verificamos si la unidad que muere es nuestra Ave
        if GetUnitTypeId(GetDyingUnit()) == UNIT_AVE_EASTER_EGG then

            // Detener los timers de movimiento y vigilancia (el ave ya no existe).
            // El watchdog DEBE pausarse aquí: durante los 300s de respawn no hay
            // ave que vigilar y dejarlo vivo solo gasta ciclos en vano.
            call PauseTimer(MoveTimer)
            call PauseTimer(StuckTimer)
            set StuckTime = 0.0

            // Soltamos el objeto exactamente donde murió (usando X e Y)
            call CreateItem(ITEM_EASTER_EGG, GetUnitX(GetDyingUnit()), GetUnitY(GetDyingUnit()))

            // Limpiar referencia
            set BirdUnit = null

            // Iniciamos el timer para reaparecer
            set t = CreateTimer()
            call TimerStart(t, RESPAWN_TIME, false, function RespawnBird)
            set t = null
        endif
        
        return false
    endfunction

    // ==========================================================
    // INICIALIZACIÓN
    // ==========================================================
    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        
        // Registramos la muerte de cualquier unidad en el mapa (incluye Neutral Pasivo)
        // NOTA: TriggerRegisterAnyUnitEventBJ ya itera TODOS los slots (incluido NEUTRAL_PASSIVE).
        //       NO duplicar con TriggerRegisterPlayerUnitEvent o el callback se ejecutará 2 veces.
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH)
        call TriggerAddCondition(t, Condition(function OnDeath))
        
        set t = null

        // Crear la primera ave al iniciar la partida (0.1s después para que WC3 inicialice rects)
        call TimerStart(CreateTimer(), 0.1, false, function RespawnBird)
    endfunction

endlibrary
