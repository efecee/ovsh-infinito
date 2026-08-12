// ==========================================================================
// SISTEMA DE ÍTEMS ÚNICOS (Restricción de Inventario)
// ==========================================================================

library IAItemRestrictions initializer OnInit

    private function OnItemPickup takes nothing returns nothing
        local unit hero = GetTriggerUnit()
        local item pickedItem = GetManipulatedItem()
        local integer pickedId = GetItemTypeId(pickedItem)
        local integer i = 0
        local integer treadsCount = 0
        local item slotItem
        local integer slotId

        // 1. Verificamos si el ítem que acaba de tocar es un Power Treads (cualquier color)
        if pickedId == 'I017' or pickedId == 'I018' or pickedId == 'I019' then
            
            // 2. Escaneamos los 6 slots del inventario
            loop
                exitwhen i > 5
                set slotItem = UnitItemInSlot(hero, i)
                if slotItem != null then
                    set slotId = GetItemTypeId(slotItem)
                    // Si encontramos cualquier variante del Power Treads, sumamos al contador
                    if slotId == 'I017' or slotId == 'I018' or slotId == 'I019' then
                        set treadsCount = treadsCount + 1
                    endif
                endif
                set i = i + 1
            endloop

            // 3. Si tiene más de 1 en total, lo obligamos a soltar el que acaba de agarrar
            if treadsCount > 1 then
                call UnitDropItemPoint(hero, pickedItem, GetUnitX(hero), GetUnitY(hero))
                
                // Opcional: Feedback visual y sonoro para que el jugador entienda qué pasó
                call DisplayTimedTextToPlayer(GetOwningPlayer(hero), 0, 0, 4.0, "|cffffcc00No puedes equipar más de un Power Treads a la vez.|r")
            endif
        endif

        set hero = null
        set pickedItem = null
        set slotItem = null
    endfunction

    private function OnInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer i = 0
        
        // Registramos el evento para todos los jugadores posibles
        loop
            exitwhen i > 15
            call TriggerRegisterPlayerUnitEvent(t, Player(i), EVENT_PLAYER_UNIT_PICKUP_ITEM, null)
            set i = i + 1
        endloop
        
        call TriggerAddAction(t, function OnItemPickup)
    endfunction

endlibrary