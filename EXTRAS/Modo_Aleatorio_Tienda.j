// ==========================================================================
// Modo_Aleatorio_Tienda.j — Triggers de Ítem y Nivel para Modo Aleatorio
// ==========================================================================
//
// TRIGGER 1: Cuando un héroe recoge el ítem I001 (Powerup consumible)
//   → Llama a ModoAleatorio_OnTomeAcquired para dar/mejorar habilidad
//
// TRIGGER 1b: Libro de Reconversión ('tret', habilidad 'Aret')
//   → INCOMPATIBLE con el modo aleatorio: 'Aret' devuelve al héroe tantos
//     skill points como nivel tiene, reabriendo el menú de habilidades del
//     héroe (cruz roja) y permitiendo aprender las habilidades stock
//     (rompe el sistema aleatorio).
//   → El powerup ya se consumió cuando dispara el evento (no se puede
//     cancelar), así que se DESHACE: puntos a 0 + reembolso del oro.
//
// TRIGGER 2: Cuando un héroe sube de nivel
//   → Quita el skill point ganado (UnitModifySkillPoints -1)
//   → Da 2 de Madera al jugador
//
// Todos los triggers solo se activan si ModoAl_Activo == true
//
// ==========================================================================

library ModoAlTienda initializer OnInit requires ModoAleatorio

    globals
        // Libro de Reconversión (habilidad 'Aret')
        private constant integer ITEM_RETRAINING      = 'tret'
        // Precio en oro. Espejo manual del Object Editor
        // (igual que IA_Data_Items.j). Si cambia el precio, actualizar ambos.
        private constant integer RETRAINING_GOLD_COST = 300
    endglobals

    // ==============================
    // TRIGGER 1: Ítem I001 recogido (Powerup se consume solo)
    // TRIGGER 1b: Libro de Reconversión bloqueado en modo aleatorio
    // ==============================
    private function OnItemPickup takes nothing returns nothing
        local unit hero = GetTriggerUnit()
        local item it = GetManipulatedItem()
        local integer itemId = GetItemTypeId(it)
        local player p

        // Solo procesar si el modo aleatorio está activo
        if not ModoAl_Activo then
            set hero = null
            set it = null
            return
        endif

        // Libro de Reconversión: deshacer su efecto y reembolsar.
        // 'Aret' ya se aplicó al disparar este evento: dejó al héroe con
        // tantos skill points como nivel tiene. Restar GetHeroLevel los
        // vuelve a 0 exacto (el modo aleatorio los mantiene siempre en 0),
        // con lo que la cruz roja del learn menu desaparece de inmediato.
        if itemId == ITEM_RETRAINING and IsUnitType(hero, UNIT_TYPE_HERO) then
            set p = GetOwningPlayer(hero)
            call UnitModifySkillPoints(hero, -GetHeroLevel(hero))
            // Si el ítem no fuera auto-consumible y quedara en inventario,
            // eliminarlo evita un segundo uso; si ya se consumió, es inocuo.
            call RemoveItem(it)
            call SetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD) + RETRAINING_GOLD_COST)
            call DisplayTimedTextToPlayer(p, 0, 0, 5.0, "Item NO disponible en Modo Aleatorio de Habilidades. Oro devuelto.")
            set p = null
            set hero = null
            set it = null
            return
        endif

        // Solo procesar el ítem I001
        if itemId != 'I001' then
            set hero = null
            set it = null
            return
        endif

        // Solo procesar para héroes
        if not IsUnitType(hero, UNIT_TYPE_HERO) then
            set hero = null
            set it = null
            return
        endif

        // Ejecutar algoritmo de habilidad aleatoria
        call ModoAleatorio_OnTomeAcquired(hero)

        set hero = null
        set it = null
    endfunction

    // ==============================
    // TRIGGER 2: Héroe sube de nivel
    // Convierte skill point → 1 Madera
    // ==============================
    private function OnHeroLevel takes nothing returns nothing
        local unit hero = GetLevelingUnit()
        local player p

        // Solo en modo aleatorio
        if not ModoAl_Activo then
            set hero = null
            return
        endif

        // Solo para héroes de jugadores (0-9)
        set p = GetOwningPlayer(hero)
        if GetPlayerId(p) > 9 then
            set hero = null
            set p = null
            return
        endif

        // Quitar el skill point que acaba de ganar
        call UnitModifySkillPoints(hero, -1)

        // Dar 2 de madera
        call SetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER, GetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER) + 2)

        set hero = null
        set p = null
    endfunction

    // ==============================
    // INICIALIZACIÓN
    // ==============================
    private function OnInit takes nothing returns nothing
        local trigger tItem = CreateTrigger()
        local trigger tLevel = CreateTrigger()
        local integer i = 0

        loop
            exitwhen i > 9
            call TriggerRegisterPlayerUnitEvent(tItem, Player(i), EVENT_PLAYER_UNIT_PICKUP_ITEM, null)
            call TriggerRegisterPlayerUnitEvent(tLevel, Player(i), EVENT_PLAYER_HERO_LEVEL, null)
            set i = i + 1
        endloop

        call TriggerAddAction(tItem, function OnItemPickup)
        call TriggerAddAction(tLevel, function OnHeroLevel)

        set tItem = null
        set tLevel = null
    endfunction

endlibrary
