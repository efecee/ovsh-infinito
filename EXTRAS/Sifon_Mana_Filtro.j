scope SifonManaFiltro initializer Init

    // ============================================================================
    // SIFÓN DE MANÁ ('AHdr') — NO ROBA MANÁ AL TANQUE SALVAJE NI AL GUARDIA DEL
    // APOCALIPSIS
    // ----------------------------------------------------------------------------
    //   "Objetivos permitidos" del Editor de Objetos no puede excluir unidades
    //   concretas, así que el filtro va por código: si el objetivo es ENEMIGO y
    //   es una de las unidades protegidas, cancelamos el cast con "stop" al
    //   arrancar (SPELL_CHANNEL, antes del efecto: no gasta maná ni enfría).
    //
    //   POR QUÉ UNA LISTA Y NO "ES INVOCACIÓN": el Guardia del Apocalipsis nace
    //   al morir la víctima de Perdición y el motor NO lo marca como invocación
    //   (UNIT_TYPE_SUMMONED da false: confirmado en juego). Marcarlo a mano
    //   cambiaría todo lo que lee esa marca (recompensa en Transmutar y Méritos,
    //   la IA, Disipar magia que daña invocaciones).
    //
    //   - A todo lo demás (creeps, héroes, otras invocaciones) se le sigue
    //     pudiendo robar.
    //   - Donar maná a un aliado no se toca.
    //
    //   Unidad nueva a proteger (p.ej. otro nivel de Perdición): sumar su rawcode
    //   en EsProtegida.
    //   Editor de Objetos: NO hay que cambiar nada (Aire, Tierra, Orgánico, Otro).
    // ============================================================================

    globals
        private constant integer SIFON_ID = 'AHdr'
        // Segundos que el aviso queda en pantalla.
        private constant real    MENSAJE_DURACION = 3.00
    endglobals

    // Unidades a las que el Sifón no les puede robar maná.
    //   'o00D'  Tanque Salvaje (la misma unidad en los 10 niveles)
    //   Guardia del Apocalipsis, una unidad por nivel de Perdición:
    //   'n00W' nv1, 'n00U' nv2, 'n00S' nv3, 'n00T' nv4, 'n00R' nv5, 'n00V' nv6
    private function EsProtegida takes unit u returns boolean
        local integer id = GetUnitTypeId(u) // null -> 0, no coincide con ninguno
        return id == 'o00D' or id == 'n00W' or id == 'n00U' or id == 'n00S' or id == 'n00T' or id == 'n00R' or id == 'n00V'
    endfunction

    private function BloquearSifon takes nothing returns nothing
        local unit caster
        local unit target
        if GetSpellAbilityId() != SIFON_ID then
            return
        endif
        set caster = GetTriggerUnit()
        set target = GetSpellTargetUnit()
        if EsProtegida(target) and IsUnitEnemy(target, GetOwningPlayer(caster)) then
            call IssueImmediateOrder(caster, "stop")
            call DisplayTimedTextToPlayer(GetOwningPlayer(caster), 0, 0, MENSAJE_DURACION, /*
            */ "|cffff5555No puedes robar maná a esta invocación.|r")
        endif
        set caster = null
        set target = null
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_CHANNEL)
        call TriggerAddAction(t, function BloquearSifon)
        set t = null
    endfunction

endscope
