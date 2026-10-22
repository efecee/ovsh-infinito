//===========================================================================
// SISTEMA: VISUALIZADOR DE DENEGACIONES (SOLO ALIADOS)
// Muestra un signo "!" SOLO a los aliados del que deniega.
//===========================================================================

function Trig_Deny_Actions takes nothing returns nothing
    local unit victim = GetDyingUnit()
    local unit killer = GetKillingUnit()
    local texttag tag
    
    // CONDICIONES LÓGICAS (excluir ilusiones: no mostrar "deny" al perder una ilusión):
    if (killer != null and IsUnitAlly(killer, GetOwningPlayer(victim)) and killer != victim and not IsUnitIllusion(victim)) then
        
        // 1. CREACIÓN GLOBAL (CRÍTICO PARA EVITAR DESYNCS)
        // El objeto 'tag' debe crearse para todos los jugadores al mismo tiempo.
        set tag = CreateTextTag()

        // GUARDA: el motor tiene un tope (~100) de textos flotantes a la vez.
        // Si el pool está lleno (teamfight con muchos números), CreateTextTag
        // devuelve null; saltamos la configuración para no operar sobre un
        // handle vacío. El comportamiento visible es el mismo, pero el código
        // queda limpio y no malgasta llamadas.
        if (tag != null) then

            // 2. CONFIGURACIÓN ESTÁNDAR
            call SetTextTagText(tag, "!", 0.023)
            call SetTextTagPosUnit(tag, victim, 0.0)
            call SetTextTagColor(tag, 0, 100, 255, 255)
            call SetTextTagVelocity(tag, 0.0, 0.03)
            call SetTextTagPermanent(tag, false)
            call SetTextTagLifespan(tag, 2.0)
            call SetTextTagFadepoint(tag, 1.0)

            // 3. FILTRO DE VISIBILIDAD LOCAL (La magia ocurre aquí)
            // Por defecto, CreateTextTag lo hace visible. Ahora lo restringimos.
            // IsUnitAlly usa el POV observado en replay y el jugador local en
            // partida normal. Incluye al dueño del killer y a sus compañeros,
            // y a los observadores (Core_Observadores.j), que lo ven todo.

            call SetTextTagVisibility(tag, IsUnitAlly(killer, GetReplayPlayerCached()) or Observadores_Es(GetReplayPlayerCached()))

        endif

    endif
    
    // LIMPIEZA DE MEMORIA (Nulling handles)
    set victim = null
    set killer = null
    set tag = null
endfunction

//===========================================================================
function InitTrig_Sistema_Deny takes nothing returns nothing
    set gg_trg_Sistema_Deny = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Sistema_Deny, EVENT_PLAYER_UNIT_DEATH)
    call TriggerAddAction(gg_trg_Sistema_Deny, function Trig_Deny_Actions)
endfunction
