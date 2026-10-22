//===========================================================================
// CORE: INDICE DE HEROES (sorteo del modo Random)
//===========================================================================
// Llena las listas de heroes de cada equipo (Array_Heroes_Humanos/Orcos y
// Config_Total_Heroes) que usa Core_Logica_Random.j para sortear.
// SE EJECUTA AL INICIAR EL MAPA: no tiene eventos. En el editor tiene marcada
// la casilla "Ejecutar al iniciar el mapa"; al convertirlo a texto esa casilla
// se conserva. NO desmarcarla.
//
// TEXTO PERSONALIZADO (antes era GUI). En el editor: seleccionar el detonador
// "Core_Indice_Heroes", Editar > Convertir en texto personalizado, y reemplazar todo
// por este archivo. El nombre del detonador NO debe cambiar.
// Conversion 1:1 del GUI que tenia el mapa el 2026-10-20: mismo comportamiento.
//===========================================================================
function Trig_Core_Indice_Heroes_Actions takes nothing returns nothing
    set udg_Config_Total_Heroes[1]=19
    set udg_Config_Total_Heroes[2]=18
    set udg_Array_Heroes_Humanos[1]='Ekee'
    set udg_Array_Heroes_Humanos[2]='Emoo'
    set udg_Array_Heroes_Humanos[3]='Edem'
    set udg_Array_Heroes_Humanos[4]='Ewar'
    set udg_Array_Heroes_Humanos[5]='Hpal'
    set udg_Array_Heroes_Humanos[6]='Hamg'
    set udg_Array_Heroes_Humanos[7]='Hmkg'
    set udg_Array_Heroes_Humanos[8]='Hblm'
    set udg_Array_Heroes_Humanos[9]='Nalc'
    set udg_Array_Heroes_Humanos[10]='Ntin'
    set udg_Array_Heroes_Humanos[11]='Npbm'
    set udg_Array_Heroes_Humanos[12]='Hlgr'
    set udg_Array_Heroes_Humanos[13]='Hvwd'
    set udg_Array_Heroes_Humanos[14]='E005'
    set udg_Array_Heroes_Humanos[15]='H00U'
    set udg_Array_Heroes_Humanos[16]='H00R'
    set udg_Array_Heroes_Humanos[17]='H00Q'
    set udg_Array_Heroes_Humanos[18]='O00B'
    set udg_Array_Heroes_Humanos[19]='H00G'
    set udg_Array_Heroes_Orcos[1]='Obla'
    set udg_Array_Heroes_Orcos[2]='Ofar'
    set udg_Array_Heroes_Orcos[3]='Otch'
    set udg_Array_Heroes_Orcos[4]='Oshd'
    set udg_Array_Heroes_Orcos[5]='Udea'
    set udg_Array_Heroes_Orcos[6]='Ulic'
    set udg_Array_Heroes_Orcos[7]='Udre'
    set udg_Array_Heroes_Orcos[8]='Ucrl'
    set udg_Array_Heroes_Orcos[9]='Nngs'
    set udg_Array_Heroes_Orcos[10]='Nfir'
    set udg_Array_Heroes_Orcos[11]='Nplh'
    set udg_Array_Heroes_Orcos[12]='Nman'
    set udg_Array_Heroes_Orcos[13]='Ogrh'
    set udg_Array_Heroes_Orcos[14]='Usyl'
    set udg_Array_Heroes_Orcos[15]='H00P'
    set udg_Array_Heroes_Orcos[16]='H00V'
    set udg_Array_Heroes_Orcos[17]='H00K'
    set udg_Array_Heroes_Orcos[18]='N020'
endfunction

//===========================================================================
function InitTrig_Core_Indice_Heroes takes nothing returns nothing
    set gg_trg_Core_Indice_Heroes=CreateTrigger()
    call TriggerAddAction(gg_trg_Core_Indice_Heroes, function Trig_Core_Indice_Heroes_Actions)
endfunction
