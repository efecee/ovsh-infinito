//===========================================================================
// SISTEMA: TRANSMUTAR - RECOMPENSA SEPARADA DEL ORO TRANSMUTADO
//---------------------------------------------------------------------------
// PROBLEMA: Transmutar ('ANtm', Alquimista) mata al creep y el motor dibuja
// DOS textos de oro en el MISMO punto y al MISMO tiempo: el oro transmutado
// (costo x factor del nivel) y la recompensa normal por matar. Salen
// superpuestos y no se leen.
//
// POR QUE NO SE "MUEVE" UNO DE LOS DOS: ambos textos los crea el motor, y en
// 1.27b no existe forma de leerlos, moverlos ni ocultarlos por codigo.
//
// SOLUCION: se apaga la recompensa NATIVA de esa muerte y este sistema la
// entrega con su propio texto RETRASADO: para cuando aparece, el texto del
// motor ya subio, asi que quedan uno debajo del otro en la misma X.
//
//   efecto ANtm      -> apaga "da recompensa" del DUENO del creep
//                       (PLAYER_STATE_GIVES_BOUNTY) y recuerda el objetivo
//   frasco en vuelo  -> toda OTRA muerte de ese dueno se paga por codigo
//                       (el motor no la pago): mismo monto, texto inmediato
//   muerte objetivo  -> guarda posicion y a quien pagar (quien lo mato)
//   tick siguiente   -> restaura la bandera
//   TEXT_DELAY s     -> paga la recompensa del objetivo + texto "+N"
//
// HECHOS MEDIDOS EN PARTIDA (trazas 2026-09-17), no cambiar sin volver a medir:
//   - "Datos - Permitir recompensa" (Ntm4) en falso NO quita la recompensa.
//   - Transmutar lanza un frasco a ~700 u/s: la muerte llega 0.4s (dist 288)
//     a 1.05s (dist 743) despues del efecto.
//   - El motor paga la recompensa ANTES del evento de muerte: apagar la
//     bandera en OnDeath llega tarde (salian 3 textos y se cobraba doble).
//     Hay que apagarla en el efecto y cubrir el vuelo con la compensacion.
//   - Apagar la bandera NO quita el oro de Transmutar.
//   - OJO al verificar: "+20" sobre "+200" se tapa exacto (el texto se ancla a
//     la izquierda) y parece que funciona; el delta de oro es lo que manda.
//
// MULTIJUGADOR: todo el estado (oro, bandera, timers) cambia por eventos
// sincronizados, igual en todos los clientes. El texto se CREA para todos y
// solo su VISIBILIDAD es local (patron de Sistema_Deny.j): lo ve quien cobra,
// o su POV en una repeticion. Bots: mismo camino, el texto no lo ve un humano.
//
// === RECOMPENSA (INVARIANTE) ===
//   NativeBounty es ESPEJO EXACTO de la tabla de Sistema_Merito_Track.j (bounty
//   nativo fijo): heroe 500, barraca 450, otra estructura 150, invocacion 0,
//   tanque 40, resto 20, ilusion 0. Si cambias un bounty en el Object Editor,
//   ajusta AMBOS archivos.
//
// === DETECTOR DE ORO F11 (Comandos_Economia.j) ===
//   - Recompensa del OBJETIVO: la paga este sistema y avanza Eco_GoldBaseline;
//     IsPending() hace que Sistema_Merito_Track.j NO la avance por su cuenta.
//   - Muertes COMPENSADAS (no pendientes): Sistema_Merito_Track.j avanza la base
//     como siempre y este sistema paga el mismo monto en el mismo instante sin
//     tocarla; el neto queda cuadrado.
//===========================================================================

library SistemaTransmutar initializer Init requires ReplayPOVDetection

    globals
        private constant integer ABILITY_ID = 'ANtm'

        // === AJUSTABLES ===
        private constant real TEXT_DELAY      = 0.75  // s tras la muerte; subir si aun se tocan
        private constant real TEXT_OFFSET_Y   = 0.00  // unidades de mapa; negativo = mas abajo en pantalla
        private constant real TEXT_HEIGHT     = 0.00  // altura sobre el suelo
        private constant real TEXT_SIZE       = 0.024
        private constant real TEXT_VELOCITY   = 0.03  // subida (igual para que la separacion no se cierre)
        private constant real TEXT_LIFESPAN   = 3.00
        private constant real TEXT_FADEPOINT  = 2.00
        // Si el objetivo no muere en este tiempo, se restaura la bandera y se olvida.
        // Holgado: el vuelo medido llega a 1.05s y un objetivo que huye lo alarga;
        // mientras tanto la compensacion cubre las demas muertes de ese dueno.
        private constant real PENDING_TIMEOUT = 3.00

        private constant integer KEY_REWARD  = 0     // parent = timer    -> Reward
        private constant integer KEY_PENDING = 1     // parent = objetivo -> Reward

        private hashtable State = InitHashtable()

        // Apagado de recompensa por dueno de creep. El contador evita que dos
        // Transmutar en vuelo sobre el mismo dueno restauren antes de tiempo
        // o guarden como "original" la bandera ya apagada.
        private integer array SuppressCount
        private integer array SavedGivesBounty
    endglobals

    // Struct (no hashtable) para el objetivo: el miembro global retiene la
    // referencia y evita que el handle se recicle si el motor quita la unidad.
    // OJO: vJASS no limpia miembros al reciclar; OnCast los asigna TODOS.
    private struct Reward
        unit    target
        integer targetId
        integer victimPid    // dueno del objetivo (bandera apagada)
        integer payTo        // quien cobra al morir el objetivo (-1 = nadie)
        real    x
        real    y
        integer bounty
        boolean died
        boolean suppressed
        timer   t
    endstruct

    // true mientras la recompensa de esta unidad la entrega este sistema.
    public function IsPending takes unit u returns boolean
        return HaveSavedInteger(State, GetHandleId(u), KEY_PENDING)
    endfunction

    // Bounty NATIVO fijo. ESPEJO EXACTO de Sistema_Merito_Track.j.
    public function NativeBounty takes unit u returns integer
        local integer id = GetUnitTypeId(u)
        if IsUnitIllusion(u) then
            return 0
        elseif IsUnitType(u, UNIT_TYPE_HERO) then
            return 500
        elseif IsUnitType(u, UNIT_TYPE_STRUCTURE) then
            if id == 'hbar' or id == 'edob' or id == 'eaom' or id == 'hbla' or id == 'obar' or id == 'uslh' or id == 'usep' or id == 'otto' then
                return 450
            endif
            return 150
        elseif IsUnitType(u, UNIT_TYPE_SUMMONED) then
            return 0
        elseif id == 'h009' or id == 'o002' or id == 'o008' then
            return 40
        endif
        return 20
    endfunction

    // Lee la bandera ORIGINAL aunque otro Transmutar la tenga apagada ahora.
    private function GivesBounty takes player p returns boolean
        local integer pid = GetPlayerId(p)
        if SuppressCount[pid] > 0 then
            return SavedGivesBounty[pid] > 0
        endif
        return GetPlayerState(p, PLAYER_STATE_GIVES_BOUNTY) > 0
    endfunction

    private function SuppressBounty takes Reward r returns nothing
        if SuppressCount[r.victimPid] == 0 then
            set SavedGivesBounty[r.victimPid] = GetPlayerState(Player(r.victimPid), PLAYER_STATE_GIVES_BOUNTY)
            call SetPlayerState(Player(r.victimPid), PLAYER_STATE_GIVES_BOUNTY, 0)
        endif
        set SuppressCount[r.victimPid] = SuppressCount[r.victimPid] + 1
        set r.suppressed = true
    endfunction

    private function RestoreBounty takes Reward r returns nothing
        if r.suppressed then
            set r.suppressed = false
            set SuppressCount[r.victimPid] = SuppressCount[r.victimPid] - 1
            if SuppressCount[r.victimPid] == 0 then
                call SetPlayerState(Player(r.victimPid), PLAYER_STATE_GIVES_BOUNTY, SavedGivesBounty[r.victimPid])
            endif
        endif
    endfunction

    // Texto "+N" con el aspecto del de recompensa del motor, solo para quien cobra.
    private function ShowBountyText takes integer pid, integer amount, real x, real y returns nothing
        // Creacion global (evita desync); solo la visibilidad es local.
        local texttag tt = CreateTextTag()
        // Tope del motor (~100 textos a la vez): sin texto, pero el oro ya se pago.
        if tt != null then
            call SetTextTagText(tt, "+" + I2S(amount), TEXT_SIZE)
            call SetTextTagPos(tt, x, y + TEXT_OFFSET_Y, TEXT_HEIGHT)
            call SetTextTagColor(tt, 255, 220, 0, 255)
            call SetTextTagVelocity(tt, 0.0, TEXT_VELOCITY)
            call SetTextTagPermanent(tt, false)
            call SetTextTagLifespan(tt, TEXT_LIFESPAN)
            call SetTextTagFadepoint(tt, TEXT_FADEPOINT)
            call SetTextTagVisibility(tt, GetReplayPlayerCached() == Player(pid))
        endif
        set tt = null
    endfunction

    private function Cleanup takes Reward r returns nothing
        call RemoveSavedInteger(State, r.targetId, KEY_PENDING)
        call RemoveSavedInteger(State, GetHandleId(r.t), KEY_REWARD)
        call DestroyTimer(r.t)
        set r.t = null
        set r.target = null
        call r.destroy()
    endfunction

    // Paga la recompensa del objetivo (con sync de la base F11) y libera todo.
    private function Deliver takes nothing returns nothing
        local Reward r = LoadInteger(State, GetHandleId(GetExpiredTimer()), KEY_REWARD)
        call AdjustPlayerStateBJ(r.bounty, Player(r.payTo), PLAYER_STATE_RESOURCE_GOLD)
        if r.payTo <= 9 then
            set Eco_GoldBaseline[r.payTo] = Eco_GoldBaseline[r.payTo] + r.bounty
        endif
        call ShowBountyText(r.payTo, r.bounty, r.x, r.y)
        call Cleanup(r)
    endfunction

    // Tick siguiente a la muerte del objetivo. El texto va SIEMPRE retrasado, lo
    // mate quien lo mate: si fue el frasco de OTRO Transmutar, su oro tambien sale
    // en ese punto y un texto inmediato se volveria a superponer.
    private function AfterDeath takes nothing returns nothing
        local Reward r = LoadInteger(State, GetHandleId(GetExpiredTimer()), KEY_REWARD)
        call RestoreBounty(r)
        if r.payTo < 0 then
            call Cleanup(r)
        else
            call TimerStart(r.t, TEXT_DELAY, false, function Deliver)
        endif
    endfunction

    // El objetivo no murio a tiempo (p.ej. se volvio inmune): se restaura y se olvida.
    private function OnTimeout takes nothing returns nothing
        local Reward r = LoadInteger(State, GetHandleId(GetExpiredTimer()), KEY_REWARD)
        call RestoreBounty(r)
        call Cleanup(r)
    endfunction

    // Otra unidad de un dueno con la bandera apagada murio durante el vuelo: el
    // motor no la pago. Misma regla que el motor: asesino enemigo; ilusion paga 0.
    // Sin sync de la base: Sistema_Merito_Track.j ya la avanza para esta muerte.
    private function Compensate takes unit u, unit k returns nothing
        local player kp
        local integer amount
        if k == null then
            return
        endif
        set kp = GetOwningPlayer(k)
        set amount = NativeBounty(u)
        if amount > 0 and IsUnitEnemy(u, kp) then
            call AdjustPlayerStateBJ(amount, kp, PLAYER_STATE_RESOURCE_GOLD)
            call ShowBountyText(GetPlayerId(kp), amount, GetUnitX(u), GetUnitY(u))
        endif
        set kp = null
    endfunction

    private function OnDeath takes nothing returns nothing
        local unit u = GetDyingUnit()
        local unit k = GetKillingUnit()
        local Reward r

        if HaveSavedInteger(State, GetHandleId(u), KEY_PENDING) then
            set r = LoadInteger(State, GetHandleId(u), KEY_PENDING)
            if not r.died then
                set r.died = true
                set r.x = GetUnitX(u)
                set r.y = GetUnitY(u)
                // Cobra quien lo mato (normalmente el lanzador), con la regla del motor.
                if k != null and IsUnitEnemy(u, GetOwningPlayer(k)) then
                    set r.payTo = GetPlayerId(GetOwningPlayer(k))
                else
                    set r.payTo = -1
                endif
                // Reemplaza la espera de PENDING_TIMEOUT por el tick siguiente.
                call TimerStart(r.t, 0.0, false, function AfterDeath)
            endif
        elseif SuppressCount[GetPlayerId(GetOwningPlayer(u))] > 0 then
            call Compensate(u, k)
        endif

        set u = null
        set k = null
    endfunction

    private function OnCast takes nothing returns nothing
        local unit caster = GetTriggerUnit()
        local unit target = GetSpellTargetUnit()
        local player owner = GetOwningPlayer(caster)
        local integer bounty = 0
        local Reward r

        // Misma regla que el motor: solo hay recompensa por enemigos cuyo dueno la otorga.
        // Sin pendiente previo: un segundo Transmutar al mismo objetivo en vuelo no duplica.
        if target != null and not IsPending(target) and IsUnitEnemy(target, owner) and GivesBounty(GetOwningPlayer(target)) then
            set bounty = NativeBounty(target)
        endif

        if bounty > 0 then
            set r = Reward.create()
            set r.target = target
            set r.targetId = GetHandleId(target)
            set r.victimPid = GetPlayerId(GetOwningPlayer(target))
            set r.payTo = -1
            set r.x = GetUnitX(target)
            set r.y = GetUnitY(target)
            set r.bounty = bounty
            set r.died = false
            set r.suppressed = false
            set r.t = CreateTimer()

            call SaveInteger(State, GetHandleId(r.t), KEY_REWARD, r)
            call SaveInteger(State, r.targetId, KEY_PENDING, r)
            // El motor paga la recompensa ANTES del evento de muerte: hay que apagarla
            // ya, en el efecto. La compensacion cubre las demas muertes durante el vuelo.
            call SuppressBounty(r)
            call TimerStart(r.t, PENDING_TIMEOUT, false, function OnTimeout)
        endif

        set caster = null
        set target = null
        set owner = null
    endfunction

    private function Conditions takes nothing returns boolean
        return GetSpellAbilityId() == ABILITY_ID
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        call TriggerAddCondition(t, Condition(function Conditions))
        call TriggerAddAction(t, function OnCast)

        set t = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH)
        call TriggerAddAction(t, function OnDeath)

        set t = null
    endfunction

endlibrary
