//===========================================================================
// SISTEMA: SELLO DE FORTIFICACION
//---------------------------------------------------------------------------
// Comodin anti-backdoor (inspirado en el Glifo de Fortificacion de Dota 2).
// Un item tipo RECURSO (Power Up) que, al comprarse, se consume al instante y
// vuelve INVULNERABLES por unos segundos TODAS las estructuras del equipo del
// comprador, sin romper el sistema de fases de Sistema_AntiBackdoor.j.
//
// === DEPENDENCIA / ORDEN DE COMPILACION ===
//   Este trigger DEBE ir DESPUES de "Sistema_AntiBackdoor" en la lista del
//   editor de triggers, porque reutiliza sus globals (AB_HUM_F0, flags, tintes).
//
// === QUE CREAR EN EL OBJECT EDITOR (usuario) ===
//   1. Item "Sello de Fortificacion":
//        - Crear como COPIA de un Tomo (clase = "Power Up"/"Mejora").
//        - Quitarle la habilidad de bonus (campo de habilidades vacio) -> no da stats.
//        - Pegar su rawcode en la constante AB_GLYPH_ITEM (abajo).
//   2. Vender el item en la tienda de CADA base (humana y orca) con disponibilidad
//      INFINITA: "Estructuras - Objetos vendidos", Stock Maximo = 0, SIN reposicion
//      ni cooldown. El tope real ("max. N por equipo") lo impone AB_GLYPH_MAX_USES.
//      En la DESCRIPCION del item, advertir: "Maximo N por equipo. Solo lo usa tu
//      equipo; un intento invalido se cancela sin cobrar oro."
//   (El sonido de activacion proviene del propio hechizo de invulnerabilidad.)
//
// NOTA: si un ENEMIGO intenta comprarlo en la base ajena, se bloquea y se le REEMBOLSA
//       el oro (no hay castigo): solo se le impide la compra con un aviso. NO te puede
//       agotar la carga: el tope vive en el contador del codigo (SF_*_Charges), no en
//       la reserva de la tienda -> por eso la tienda DEBE tener stock infinito (no
//       reservas=1/cooldown). Un ALIADO que recompra despues de usado tambien recibe
//       reembolso (clic por error). Solo la primera compra valida de cada equipo gasta oro.
//
// (No se intenta "precio mas alto solo para el enemigo": en 1.27b el costo del item
//  es estado global sincronizado, no hay native para cambiarlo y por jugador
//  desincronizaria. El bloqueo por evento + contador de codigo es la via correcta.)
//===========================================================================

globals
    // === CONFIG (ajustar) ===
    constant integer AB_GLYPH_ITEM     = 'gfor'  // <-- rawcode real del item
    constant real    AB_GLYPH_DURATION = 30.0    // segundos de invulnerabilidad
    constant integer AB_GLYPH_MAX_USES = 1       // usos por EQUIPO por partida
    constant integer AB_GLYPH_COST     = 1000    // <-- DEBE igualar el costo en oro del item en el editor (para reembolsar toda compra que no activa el sello)
    // Separadores coloreados por equipo (estilo VOTO_SEP)
    constant string  SF_SEP_HUM = "|cff66B3FF==============================|r"
    constant string  SF_SEP_ORC = "|cffFF3333==========================|r"

    // === ESTADO ===
    integer SF_HUM_Charges = 1
    integer SF_ORC_Charges = 1
    timer   SF_HUM_Timer   = null
    timer   SF_ORC_Timer   = null

    boolean SF_TmpInvuln   = false               // estado para ForGroup (no acepta argumentos)

    effect array SF_HUM_FX
    integer      SF_HUM_FXn = 0
    effect array SF_ORC_FX
    integer      SF_ORC_FXn = 0
endglobals

// ===================== HELPERS =====================

// Devuelve el oro del item a CUALQUIER comprador cuya compra no activa el sello
// (aliado que recompra ya usado, o enemigo que intenta comprar en base ajena).
// No hay castigo: la compra simplemente se impide y nadie pierde oro.
function SF_Refund takes player p returns nothing
    call SetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD) + AB_GLYPH_COST)
    // Sync detector de oro F11 (Comandos_Economia.j): el reembolso DEVUELVE el oro,
    // cancelando la resta de base que hizo SF_OnSell al comprar (neto base = 0).
    set Eco_GoldBaseline[GetPlayerId(p)] = Eco_GoldBaseline[GetPlayerId(p)] + AB_GLYPH_COST
endfunction

function SF_ApplyInvuln takes nothing returns nothing
    call SetUnitInvulnerable(GetEnumUnit(), SF_TmpInvuln)
endfunction

function SF_SetGroupInvuln takes group g, boolean inv returns nothing
    set SF_TmpInvuln = inv
    call ForGroup(g, function SF_ApplyInvuln)
endfunction

function SF_TintWhite takes nothing returns nothing
    call SetUnitVertexColor(GetEnumUnit(), 255, 255, 255, 255)
endfunction

// Brillo dorado sutil mientras dura el sello
function SF_Glow takes nothing returns nothing
    call SetUnitVertexColor(GetEnumUnit(), 255, 230, 120, 255)
endfunction

// Adjunta la burbuja de Escudo Divino y guarda el handle para destruirlo luego
function SF_AddShield_Hum takes nothing returns nothing
    set SF_HUM_FX[SF_HUM_FXn] = AddSpecialEffectTarget("Abilities\\Spells\\Human\\DivineShield\\DivineShieldTarget.mdl", GetEnumUnit(), "origin")
    set SF_HUM_FXn = SF_HUM_FXn + 1
endfunction

function SF_AddShield_Orc takes nothing returns nothing
    set SF_ORC_FX[SF_ORC_FXn] = AddSpecialEffectTarget("Abilities\\Spells\\Human\\DivineShield\\DivineShieldTarget.mdl", GetEnumUnit(), "origin")
    set SF_ORC_FXn = SF_ORC_FXn + 1
endfunction

function SF_ClearShield_Hum takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i >= SF_HUM_FXn
        call DestroyEffect(SF_HUM_FX[i])
        set SF_HUM_FX[i] = null
        set i = i + 1
    endloop
    set SF_HUM_FXn = 0
endfunction

function SF_ClearShield_Orc takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i >= SF_ORC_FXn
        call DestroyEffect(SF_ORC_FX[i])
        set SF_ORC_FX[i] = null
        set i = i + 1
    endloop
    set SF_ORC_FXn = 0
endfunction

// ===================== RESTAURACION (recalculo desde flags) =====================
// Durante la invulnerabilidad nada puede morir => no hay transiciones de fase.
// Al expirar, recalculamos el estado correcto de cada grupo leyendo los flags
// de Sistema_AntiBackdoor. Idempotente y a prueba de bugs.

function SF_RestoreHuman takes nothing returns nothing
    // 1) invulnerabilidad correcta por fase
    call SF_SetGroupInvuln(AB_HUM_F0,     not AB_HUM_F0_Open)
    call SF_SetGroupInvuln(AB_HUM_F1,     not AB_HUM_F1_Open)
    call SF_SetGroupInvuln(AB_HUM_F2_TOP, not AB_HUM_F2Top_Open)
    call SF_SetGroupInvuln(AB_HUM_F2_BOT, not AB_HUM_F2Bot_Open)
    call SF_SetGroupInvuln(AB_HUM_F3_TOP, false)
    call SF_SetGroupInvuln(AB_HUM_F3_BOT, false)
    // 2) reset visual a blanco
    call ForGroup(AB_HUM_F0,     function SF_TintWhite)
    call ForGroup(AB_HUM_F1,     function SF_TintWhite)
    call ForGroup(AB_HUM_F2_TOP, function SF_TintWhite)
    call ForGroup(AB_HUM_F2_BOT, function SF_TintWhite)
    call ForGroup(AB_HUM_F3_TOP, function SF_TintWhite)
    call ForGroup(AB_HUM_F3_BOT, function SF_TintWhite)
    // 3) re-tinte de las que SIGUEN protegidas (mantiene el look del AntiBackdoor)
    if not AB_HUM_F0_Open then
        call ForGroup(AB_HUM_F0, function AB_TintHuman)
    endif
    if not AB_HUM_F1_Open then
        call ForGroup(AB_HUM_F1, function AB_TintHuman)
    endif
    if not AB_HUM_F2Top_Open then
        call ForGroup(AB_HUM_F2_TOP, function AB_TintHuman)
    endif
    if not AB_HUM_F2Bot_Open then
        call ForGroup(AB_HUM_F2_BOT, function AB_TintHuman)
    endif
endfunction

function SF_RestoreOrc takes nothing returns nothing
    call SF_SetGroupInvuln(AB_ORC_F0,     not AB_ORC_F0_Open)
    call SF_SetGroupInvuln(AB_ORC_F1,     not AB_ORC_F1_Open)
    call SF_SetGroupInvuln(AB_ORC_F2_TOP, not AB_ORC_F2Top_Open)
    call SF_SetGroupInvuln(AB_ORC_F2_BOT, not AB_ORC_F2Bot_Open)
    call SF_SetGroupInvuln(AB_ORC_F3_TOP, false)
    call SF_SetGroupInvuln(AB_ORC_F3_BOT, false)
    call ForGroup(AB_ORC_F0,     function SF_TintWhite)
    call ForGroup(AB_ORC_F1,     function SF_TintWhite)
    call ForGroup(AB_ORC_F2_TOP, function SF_TintWhite)
    call ForGroup(AB_ORC_F2_BOT, function SF_TintWhite)
    call ForGroup(AB_ORC_F3_TOP, function SF_TintWhite)
    call ForGroup(AB_ORC_F3_BOT, function SF_TintWhite)
    if not AB_ORC_F0_Open then
        call ForGroup(AB_ORC_F0, function AB_TintOrc)
    endif
    if not AB_ORC_F1_Open then
        call ForGroup(AB_ORC_F1, function AB_TintOrc)
    endif
    if not AB_ORC_F2Top_Open then
        call ForGroup(AB_ORC_F2_TOP, function AB_TintOrc)
    endif
    if not AB_ORC_F2Bot_Open then
        call ForGroup(AB_ORC_F2_BOT, function AB_TintOrc)
    endif
endfunction

// ===================== FIN DE SELLO (callback del timer) =====================

function SF_EndHuman takes nothing returns nothing
    call SF_RestoreHuman()
    call SF_ClearShield_Hum()
endfunction

function SF_EndOrc takes nothing returns nothing
    call SF_RestoreOrc()
    call SF_ClearShield_Orc()
endfunction

// ===================== ACTIVACION =====================

function SF_ActivateHuman takes nothing returns nothing
    // invulnerabilidad total de lo que este vivo
    call SF_SetGroupInvuln(AB_HUM_F0,     true)
    call SF_SetGroupInvuln(AB_HUM_F1,     true)
    call SF_SetGroupInvuln(AB_HUM_F2_TOP, true)
    call SF_SetGroupInvuln(AB_HUM_F2_BOT, true)
    call SF_SetGroupInvuln(AB_HUM_F3_TOP, true)
    call SF_SetGroupInvuln(AB_HUM_F3_BOT, true)
    // brillo dorado en toda la base
    call ForGroup(AB_HUM_F0,     function SF_Glow)
    call ForGroup(AB_HUM_F1,     function SF_Glow)
    call ForGroup(AB_HUM_F2_TOP, function SF_Glow)
    call ForGroup(AB_HUM_F2_BOT, function SF_Glow)
    call ForGroup(AB_HUM_F3_TOP, function SF_Glow)
    call ForGroup(AB_HUM_F3_BOT, function SF_Glow)
    // burbuja de Escudo Divino sobre cada estructura viva
    call SF_ClearShield_Hum()  // por si hubiera un sello previo activo (overlap)
    call ForGroup(AB_HUM_F0,     function SF_AddShield_Hum)
    call ForGroup(AB_HUM_F1,     function SF_AddShield_Hum)
    call ForGroup(AB_HUM_F2_TOP, function SF_AddShield_Hum)
    call ForGroup(AB_HUM_F2_BOT, function SF_AddShield_Hum)
    call ForGroup(AB_HUM_F3_TOP, function SF_AddShield_Hum)
    call ForGroup(AB_HUM_F3_BOT, function SF_AddShield_Hum)
    // aviso global (lo leen todos por igual)
    call Replay_DisplayTimedTextToAll(AB_GLYPH_DURATION - 1.0, SF_SEP_HUM)
    call Replay_DisplayTimedTextToAll(AB_GLYPH_DURATION - 1.0, "|cff66B3FFSELLO HUMANO ACTIVADO!|r")
    call Replay_DisplayTimedTextToAll(AB_GLYPH_DURATION - 1.0, SF_SEP_HUM)
    // timer reutilizado (no se recrea por uso) -> sin fuga de handles
    if SF_HUM_Timer == null then
        set SF_HUM_Timer = CreateTimer()
    endif
    call TimerStart(SF_HUM_Timer, AB_GLYPH_DURATION, false, function SF_EndHuman)
endfunction

function SF_ActivateOrc takes nothing returns nothing
    call SF_SetGroupInvuln(AB_ORC_F0,     true)
    call SF_SetGroupInvuln(AB_ORC_F1,     true)
    call SF_SetGroupInvuln(AB_ORC_F2_TOP, true)
    call SF_SetGroupInvuln(AB_ORC_F2_BOT, true)
    call SF_SetGroupInvuln(AB_ORC_F3_TOP, true)
    call SF_SetGroupInvuln(AB_ORC_F3_BOT, true)
    call ForGroup(AB_ORC_F0,     function SF_Glow)
    call ForGroup(AB_ORC_F1,     function SF_Glow)
    call ForGroup(AB_ORC_F2_TOP, function SF_Glow)
    call ForGroup(AB_ORC_F2_BOT, function SF_Glow)
    call ForGroup(AB_ORC_F3_TOP, function SF_Glow)
    call ForGroup(AB_ORC_F3_BOT, function SF_Glow)
    call SF_ClearShield_Orc()
    call ForGroup(AB_ORC_F0,     function SF_AddShield_Orc)
    call ForGroup(AB_ORC_F1,     function SF_AddShield_Orc)
    call ForGroup(AB_ORC_F2_TOP, function SF_AddShield_Orc)
    call ForGroup(AB_ORC_F2_BOT, function SF_AddShield_Orc)
    call ForGroup(AB_ORC_F3_TOP, function SF_AddShield_Orc)
    call ForGroup(AB_ORC_F3_BOT, function SF_AddShield_Orc)
    call Replay_DisplayTimedTextToAll(AB_GLYPH_DURATION - 1.0, SF_SEP_ORC)
    call Replay_DisplayTimedTextToAll(AB_GLYPH_DURATION - 1.0, "|cffFF3333SELLO ORCO ACTIVADO!|r")
    call Replay_DisplayTimedTextToAll(AB_GLYPH_DURATION - 1.0, SF_SEP_ORC)
    if SF_ORC_Timer == null then
        set SF_ORC_Timer = CreateTimer()
    endif
    call TimerStart(SF_ORC_Timer, AB_GLYPH_DURATION, false, function SF_EndOrc)
endfunction

// ===================== HANDLER DE COMPRA =====================
// Usamos SELL_ITEM (no PICKUP): se dispara SIEMPRE que una tienda vende, aunque el
// inventario este lleno o el item sea Power Up. Asi el item nunca "se cae al suelo"
// ni el evento se salta. Lo quitamos al instante con RemoveItem.
//
// IMPORTANTE (config de tienda): vende el item con disponibilidad INFINITA
// (Stock Maximo = 0, sin reposicion ni cooldown). El tope por equipo lo controla el
// contador AB_GLYPH_MAX_USES. Asi un enemigo NO puede gastar tu stock ni reiniciar
// ningun cooldown: su compra se cancela y se le reembolsa el oro (sin castigo).
//
// Anti-exploit: la BASE se determina por la X de la TIENDA (fija):
//   X < 0 = base Humana (Oeste), X > 0 = base Orca (Este).

function SF_OnSell takes nothing returns nothing
    local item    it    = GetSoldItem()
    local unit    shop  = GetSellingUnit()
    local unit    buyer = GetBuyingUnit()
    local player  p
    local boolean buyerHuman
    local boolean baseHuman

    if GetItemTypeId(it) != AB_GLYPH_ITEM then
        set it = null
        set shop = null
        set buyer = null
        return
    endif

    set p = GetOwningPlayer(buyer)
    set buyerHuman = (GetPlayerId(p) <= 4)
    set baseHuman  = (GetUnitX(shop) < 0.0)  // tienda humana al Oeste (X-), orca al Este (X+)

    // Sync detector de oro F11 (Comandos_Economia.j): el engine YA descontó
    // AB_GLYPH_COST al comprar este ítem, y 'gfor' NO está en IADataItems (el hook
    // genérico de compras no lo cubre). Restarlo de la base evita que ese gasto
    // descuadre un regalo F11 del mismo tick. Si la compra no activa el sello
    // (aliado que recompra usado o enemigo en base ajena), SF_Refund lo vuelve a
    // sumar (neto 0). Solo la compra que SÍ activa el sello deja el gasto en pie.
    set Eco_GoldBaseline[GetPlayerId(p)] = Eco_GoldBaseline[GetPlayerId(p)] - AB_GLYPH_COST

    call RemoveItem(it)  // el item nunca queda en inventario ni en el suelo

    // === ENEMIGO comprando en base ajena: bloquear y reembolsar (sin castigo) ===
    if buyerHuman != baseHuman then
        call SF_Refund(p)  // se le devuelve el oro: no hay castigo, solo se le impide la compra
        call DisplayTextToPlayer(p, 0, 0, "|cffff8000Prohibido robar este item.|r")
        set it = null
        set shop = null
        set buyer = null
        set p = null
        return
    endif

    // === ALIADO en su propia base ===
    if buyerHuman then
        if SF_HUM_Charges <= 0 then
            call SF_Refund(p)  // aliado recompro por error: se le devuelve el oro
            call DisplayTextToPlayer(p, 0, 0, "|cffff8000Sello ya utilizado.|r")
        else
            set SF_HUM_Charges = SF_HUM_Charges - 1
            call SF_ActivateHuman()
        endif
    else
        if SF_ORC_Charges <= 0 then
            call SF_Refund(p)  // aliado recompro por error: se le devuelve el oro
            call DisplayTextToPlayer(p, 0, 0, "|cffff8000Sello ya utilizado.|r")
        else
            set SF_ORC_Charges = SF_ORC_Charges - 1
            call SF_ActivateOrc()
        endif
    endif

    set it = null
    set shop = null
    set buyer = null
    set p = null
endfunction

// ===================== TRIGGER INIT =====================

function InitTrig_Sistema_Sello_Fortificacion takes nothing returns nothing
    local trigger t = CreateTrigger()

    set SF_HUM_Charges = AB_GLYPH_MAX_USES
    set SF_ORC_Charges = AB_GLYPH_MAX_USES


    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SELL_ITEM)
    call TriggerAddAction(t, function SF_OnSell)
    set t = null
endfunction
