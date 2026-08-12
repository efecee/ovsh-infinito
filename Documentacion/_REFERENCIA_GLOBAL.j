globals
    //globals from IAData:
    constant boolean LIBRARY_IAData=true
    // --- CONFIGURACIÓN ESTÁNDAR ---
    constant real IAData_DEFAULT_RANGE_MELEE= 128.0
    constant real IAData_DEFAULT_RANGE_RANGED= 550.0
        
    // Tiempo de animación de ataque (0.4s promedio)
    constant real IAData_DEFAULT_DMG_POINT= 0.40
        
    // Daño Base Promedio (Sin atributos) para cálculo inicial
    constant real IAData_BASE_DAMAGE_AVG= 30.0
    //endglobals from IAData
    //globals from IAUtils:
    constant boolean LIBRARY_IAUtils=true
    // Constante para conversiones rápidas
    constant real IAUtils_DEGTORAD= 0.017453292
    constant real IAUtils_RADTODEG= 57.29577951
    //endglobals from IAUtils
    //globals from IABrainMacro:
    constant boolean LIBRARY_IABrainMacro=true
    // Coordenadas de las BASES DE CURACIÓN (Top y Bot)
    real HUM_BASE_TOP_X
    real HUM_BASE_TOP_Y
    real HUM_BASE_BOT_X
    real HUM_BASE_BOT_Y
        
    real ORC_BASE_TOP_X
    real ORC_BASE_TOP_Y
    real ORC_BASE_BOT_X
    real ORC_BASE_BOT_Y
        
    // Coordenadas de los Castillos (Para atacar al final)
    real CASTLE_HUM_X
    real CASTLE_HUM_Y
    real CASTLE_ORC_X
    real CASTLE_ORC_Y
    //endglobals from IABrainMacro
    //globals from IALogicLaning:
    constant boolean LIBRARY_IALogicLaning=true
    hashtable IA_Laning_Memory= InitHashtable()
    //endglobals from IALogicLaning
    //globals from IALogicSurvival:
    constant boolean LIBRARY_IALogicSurvival=true
    constant real IALogicSurvival_LOW_HP_THRESHOLD= 0.25
    constant real IALogicSurvival_HEALTHY_THRESHOLD= 0.85
    //endglobals from IALogicSurvival
    //globals from IACore:
    constant boolean LIBRARY_IACore=true
    integer array BotsActive
    integer BotsCount= 0
    timer IA_Timer_Loop
    boolean IA_System_On= false
    //endglobals from IACore
    // User-defined
    integer udg_integer01= 0
    integer udg_integer02= 0
    integer array udg_integers01
    string array udg_strings01
    integer udg_integer03= 0
    integer udg_integer04= 0
    integer array udg_integers02
    integer array udg_integers03
    string array udg_strings02
    integer udg_integer05= 0
    timer udg_timer01= null
    integer udg_integer06= 0
    group udg_group01= null
    timer array udg_timers01
    real udg_real01= 0
    real udg_real02= 0
    boolean udg_boolean01= false
    timerdialog udg_timerdialog01= null
    boolean udg_boolean02= false
    force udg_force01= null
    group udg_group02= null
    string array udg_strings03
    integer udg_integer07= 0
    integer udg_integer08= 0
    group udg_group03= null
    force udg_force02= null
    integer udg_integer09= 0
    integer udg_integer10= 0
    integer udg_integer11= 0
    force udg_force03= null
    integer udg_integer12= 0
    integer udg_integer13= 0
    integer array udg_integers04
    integer array udg_integers05
    integer array udg_integers06
    integer udg_integer14= 0
    integer array udg_integers07
    integer udg_integer15= 0
    integer array udg_integers08
    integer udg_integer16= 0
    integer array udg_integers09
    integer array udg_integers10
    force udg_force04= null
    force udg_force05= null
    integer udg_integer17= 0
    player array udg_players01
    force udg_force06= null
    force udg_force07= null
    integer udg_integer18= 0
    force udg_force08= null
    integer udg_integer19= 0
    force udg_force09= null
    integer udg_integer20= 0
    force udg_force10= null
    integer udg_integer21= 0
    integer array udg_integers11
    integer udg_integer22= 0
    integer array udg_integers12
    boolean udg_boolean03= false
    integer udg_integer23= 0
    integer array udg_integers13
    integer udg_integer24= 0
    integer array udg_integers14
    integer udg_integer25= 0
    integer udg_integer26= 0
    integer array udg_integers15
    integer array udg_integers16
    integer udg_integer27= 0
    integer udg_integer28= 0
    integer udg_integer29= 0
    force udg_force11= null
    leaderboard udg_leaderboard01= null
    force udg_force12= null
    leaderboard udg_leaderboard02= null
    integer array udg_integers17
    integer array udg_integers18
    boolean udg_boolean04= false
    force udg_force13= null
    leaderboard udg_leaderboard03= null
    leaderboard udg_leaderboard04= null
    timer udg_timer02= null
    timer udg_timer03= null
    timer udg_timer04= null
    timer udg_timer05= null
    timer udg_timer06= null
    timer udg_timer07= null
    timer udg_timer08= null
    timer udg_timer09= null
    timer udg_timer10= null
    timer udg_timer11= null
    player udg_player01= null
    player array udg_players02
    player udg_player02= null
    player udg_player03= null
    player udg_player04= null
    playercolor udg_playercolor01= null
    player udg_player05= null
    player udg_player06= null
    player udg_player07= null
    timerdialog udg_timerdialog02= null
    timerdialog udg_timerdialog03= null
    timerdialog udg_timerdialog04= null
    timerdialog udg_timerdialog05= null
    timerdialog udg_timerdialog06= null
    timerdialog udg_timerdialog07= null
    timerdialog udg_timerdialog08= null
    timerdialog udg_timerdialog09= null
    timerdialog udg_timerdialog10= null
    timerdialog udg_timerdialog11= null
    timerdialog udg_timerdialog12= null
    boolean udg_boolean05= false
    force udg_force14= null
    force udg_force15= null
    boolean udg_boolean06= false
    dialog array udg_dialogs01
    button array udg_buttons01
    dialog array udg_dialogs02
    button array udg_buttons02
    dialog array udg_dialogs03
    button array udg_buttons03
    playercolor array udg_playercolors01
    unit udg_unit01= null
    boolean udg_boolean07= false
    dialog udg_dialog01= null
    button array udg_buttons04
    boolean array udg_booleans01
    button udg_button01= null
    integer udg_integer30= 0
    integer udg_integer31= 0
    integer udg_integer32= 0
    player udg_player08= null
    multiboard udg_multiboard01= null
    multiboard udg_multiboard02= null
    integer udg_integer33= 0
    integer udg_integer34= 0
    integer udg_integer35= 0
    dialog udg_dialog02= null
    button udg_button02= null
    button udg_button03= null
    integer udg_integer36= 0
    boolean udg_boolean08= false
    dialog udg_dialog03= null
    unit array udg_units01
    timerdialog array udg_timerdialogs01
    integer udg_integer37= 0
    boolean udg_boolean09= false
    integer udg_integer38= 0
    integer udg_integer39= 0
    integer udg_integer40= 0
    group udg_group04= null
    real udg_real03= 0
    unit udg_unit02= null
    location udg_location01= null
    location udg_location02= null
    integer udg_integer41= 0
    integer udg_integer42= 0
    real udg_real04= 0
    location array udg_locations01
    destructable array udg_destructables01
    group udg_group05= null
    boolean array udg_booleans02
    integer udg_integer43= 0
    integer array udg_integers19
    player udg_player09= null
    integer udg_integer44= 0
    integer udg_integer45= 0
    integer udg_integer46= 0
    dialog array udg_dialogs04
    button array udg_buttons05
    integer udg_integer47= 0
    integer udg_integer48= 0
    boolean udg_boolean10= false
    rect udg_rect01= null
    rect udg_rect02= null
    rect udg_rect03= null
    rect udg_rect04= null
    rect udg_rect05= null
    rect udg_rect06= null
    rect udg_rect07= null
    rect udg_rect08= null
    rect udg_rect09= null
    rect udg_rect10= null
    rect udg_rect11= null
    rect udg_rect12= null
    rect udg_rect13= null
    rect udg_rect14= null
    rect udg_rect15= null
    rect udg_rect16= null
    rect udg_rect17= null
    rect udg_rect18= null
    rect udg_rect19= null
    rect udg_rect20= null
    rect udg_rect21= null
    rect udg_rect22= null
    rect udg_rect23= null
    rect udg_rect24= null
    rect udg_rect25= null
    rect udg_rect26= null
    rect udg_rect27= null
    rect udg_rect28= null
    rect udg_rect29= null
    rect udg_rect30= null
    rect udg_rect31= null
    rect udg_rect32= null
    rect udg_rect33= null
    rect udg_rect34= null
    rect udg_rect35= null
    rect udg_rect36= null
    rect udg_rect37= null
    rect udg_rect38= null
    rect udg_rect39= null
    rect udg_rect40= null
    rect udg_rect41= null
    rect udg_rect42= null
    rect udg_rect43= null
    rect udg_rect44= null
    rect udg_rect45= null
    rect udg_rect46= null
    sound udg_sound01= null
    sound udg_sound02= null
    sound udg_sound03= null
    string udg_string01
    trigger udg_trigger01= null
    trigger udg_trigger02= null
    trigger udg_trigger03= null
    trigger udg_trigger04= null
    trigger udg_trigger05= null
    trigger udg_trigger06= null
    trigger udg_trigger07= null
    trigger udg_trigger08= null
    trigger udg_trigger09= null
    trigger udg_trigger10= null
    trigger udg_trigger11= null
    trigger udg_trigger12= null
    trigger udg_trigger13= null
    trigger udg_trigger14= null
    trigger udg_trigger15= null
    trigger udg_trigger16= null
    trigger udg_trigger17= null
    trigger udg_trigger18= null
    trigger udg_trigger19= null
    trigger udg_trigger20= null
    trigger udg_trigger21= null
    trigger udg_trigger22= null
    trigger udg_trigger23= null
    trigger udg_trigger24= null
    trigger udg_trigger25= null
    trigger udg_trigger26= null
    trigger udg_trigger27= null
    trigger udg_trigger28= null
    trigger udg_trigger29= null
    trigger udg_trigger30= null
    trigger udg_trigger31= null
    trigger udg_trigger32= null
    trigger udg_trigger33= null
    trigger udg_trigger34= null
    trigger udg_trigger35= null
    trigger udg_trigger36= null
    trigger udg_trigger37= null
    trigger udg_trigger38= null
    trigger udg_trigger39= null
    trigger udg_trigger40= null
    trigger udg_trigger41= null
    trigger udg_trigger42= null
    trigger udg_trigger43= null
    trigger udg_trigger44= null
    trigger udg_trigger45= null
    trigger udg_trigger46= null
    trigger udg_trigger47= null
    trigger udg_trigger48= null
    trigger udg_trigger49= null
    trigger udg_trigger50= null
    trigger udg_trigger51= null
    trigger udg_trigger52= null
    trigger udg_trigger53= null
    trigger udg_trigger54= null
    trigger udg_trigger55= null
    trigger udg_trigger56= null
    trigger udg_trigger57= null
    trigger udg_trigger58= null
    trigger udg_trigger59= null
    trigger udg_trigger60= null
    trigger udg_trigger61= null
    trigger udg_trigger62= null
    trigger udg_trigger63= null
    trigger udg_trigger64= null
    trigger udg_trigger65= null
    trigger udg_trigger66= null
    trigger udg_trigger67= null
    trigger udg_trigger68= null
    trigger udg_trigger69= null
    trigger udg_trigger70= null
    trigger udg_trigger71= null
    trigger udg_trigger72= null
    trigger udg_trigger73= null
    trigger udg_trigger74= null
    trigger udg_trigger75= null
    trigger udg_trigger76= null
    trigger udg_trigger77= null
    trigger udg_trigger78= null
    trigger udg_trigger79= null
    trigger udg_trigger80= null
    trigger udg_trigger81= null
    trigger udg_trigger82= null
    trigger udg_trigger83= null
    trigger udg_trigger84= null
    trigger udg_trigger85= null
    trigger udg_trigger86= null
    trigger udg_trigger87= null
    trigger udg_trigger88= null
    trigger udg_trigger89= null
    trigger udg_trigger90= null
    trigger udg_trigger91= null
    trigger udg_trigger92= null
    trigger udg_trigger93= null
    trigger udg_trigger94= null
    trigger udg_trigger95= null
    trigger udg_trigger96= null
    trigger udg_trigger97= null
    trigger udg_trigger98= null
    trigger udg_trigger99= null
    trigger udg_trigger100= null
    trigger udg_trigger101= null
    trigger udg_trigger102= null
    trigger udg_trigger103= null
    trigger udg_trigger104= null
    trigger udg_trigger105= null
    trigger udg_trigger106= null
    trigger udg_trigger107= null
    trigger udg_trigger108= null
    trigger udg_trigger109= null
    trigger udg_trigger110= null
    trigger udg_trigger111= null
    trigger udg_trigger112= null
    trigger udg_trigger113= null
    trigger udg_trigger114= null
    trigger udg_trigger115= null
    trigger udg_trigger116= null
    trigger udg_trigger117= null
    trigger udg_trigger118= null
    trigger udg_trigger119= null
    unit udg_unit03= null
    unit udg_unit04= null
    unit udg_unit05= null
    unit udg_unit06= null
    unit udg_unit07= null
    unit udg_unit08= null
    unit udg_unit09= null
    unit udg_unit10= null
    unit udg_unit11= null
    unit udg_unit12= null
    unit udg_unit13= null
    unit udg_unit14= null
    unit udg_unit15= null
    unit udg_unit16= null
    unit udg_unit17= null
    unit udg_unit18= null
    unit udg_unit19= null
    unit udg_unit20= null
    unit udg_unit21= null
    unit udg_unit22= null
    unit udg_unit23= null
    unit udg_unit24= null
    unit udg_unit25= null
    unit udg_unit26= null
    unit udg_unit27= null
    unit udg_unit28= null
    unit udg_unit29= null
    unit udg_unit30= null
    unit udg_unit31= null
    unit udg_unit32= null
    unit udg_unit33= null
    unit udg_unit34= null
    unit udg_unit35= null
    unit udg_unit36= null
    unit udg_unit37= null
    unit udg_unit38= null
    unit udg_unit39= null
    unit udg_unit40= null
    unit udg_unit41= null
    unit udg_unit42= null
    unit udg_unit43= null
    unit udg_unit44= null
    unit udg_unit45= null
    unit udg_unit46= null
    unit udg_unit47= null
    unit udg_unit48= null
    trigger udg_trigger120= null
    group udg_IA_Grupo_Humanos= null
    group udg_IA_Grupo_Orcos= null
    player udg_IA_Bot_Actual= null
    string array udg_IA_Estado
    timer udg_IA_Temporizador= null
    timerdialog udg_IA_Ventana_Tiempo= null
    location udg_Temp_Punto= null
    group udg_Temp_Grupo= null
    integer udg_IA_Amenaza= 0
    player udg_Core_JugadorMaestro= null
    player udg_TempPlayer= null
    dialog udg_UI_Ventana_General= null
    button udg_UI_Boton_OroNormal= null
    button udg_UI_Boton_OroRapido= null
    integer udg_Config_Modo_Humanos= 0
    integer udg_Config_Modo_Orcos= 0
    dialog udg_UI_Ventana_Heroes= null
    button udg_UI_Boton_TodosPick= null
    button udg_UI_Boton_TodosRandom= null
    button udg_UI_Boton_HumPick_OrcRnd= null
    button udg_UI_Boton_HumRnd_OrcPick= null
    integer udg_Config_Cantidad_Oro= 0
    force udg_Grupo_Humanos= null
    force udg_Grupo_Orcos= null
    boolean udg_Core_HayBots= false
    boolean udg_Temp_MasterEncontrado= false
    button udg_UI_Boton_OroInsano= null
    integer array udg_Array_Heroes_Humanos
    integer array udg_Array_Heroes_Orcos
    integer array udg_Config_Total_Heroes
    integer udg_Temp_Int_Random= 0
    integer udg_Temp_Unit_Type= 0
    rect udg_Temp_Region= null
    hashtable udg_Hash_Heroes= null
    hashtable udg_TablaHash= null
    integer array udg_HookMUI
    unit array udg_Hook_Caster
    location array udg_PUNTO_Gancho
    location array udg_PUNTO_Spell
    real array udg_Angulo
    real array udg_Distancia
    real array udg_Distancia_MAX
    real array udg_Damange
    real array udg_Velocidad_Cadena
    boolean array udg_Hook_Drag
    boolean array udg_ON_OFF
    unit udg_Dummy_Cadena= null
    integer array udg_Contador_Cadena
    location array udg_PUNTO_Objetivo
    unit array udg_Hook_Target
    group array udg_Hook_Grupo
    multiboard udg_MB_Tabla= null
    hashtable udg_MB_Hash= null
    sound udg_sonido_bots= null
    boolean udg_IA_Sistema_Activo= false
    rect array udg_IA_Base_Humana
    rect array udg_IA_Base_Orca
    rect udg_IA_Linea_Top= null
    rect udg_IA_Linea_Bot= null

    // Generated
    rect gg_rct_Base_Hum_Top= null
    rect gg_rct_Base_Hum_Bot= null
    rect gg_rct_Base_Orc_Top= null
    rect gg_rct_Base_Orc_Bot= null
    rect gg_rct_Linea_Arriba= null
    rect gg_rct_Linea_Abajo= null
    rect gg_rct_Reg_Sel_Sniper= null
    rect gg_rct_Reg_Sel_Bandido= null
    rect gg_rct_Reg_Sel_Sylvanas_Humano= null
    rect gg_rct_Reg_Sel_CoCo= null
    rect gg_rct_Reg_Sel_Magnadefender= null
    rect gg_rct_Reg_Sel_Goblin_Techies= null
    rect gg_rct_Reg_Sel_Asesina= null
    rect gg_rct_Reg_Sel_Guardi__n_del_Bosque= null
    rect gg_rct_Reg_Sel_Guardiana= null
    rect gg_rct_Reg_Sel_Sacerdotisa_de_la_Luna= null
    rect gg_rct_Reg_Sel_Alquimista= null
    rect gg_rct_Reg_Sel_Cazador_de_Demonios= null
    rect gg_rct_Reg_Sel_Hojalatero= null
    rect gg_rct_Reg_Sel_Paladin= null
    rect gg_rct_Reg_Sel_Archimago= null
    rect gg_rct_Reg_Sel_Rey_de_la_Monta__a= null
    rect gg_rct_Reg_Sel_Mago_sanguinario= null
    rect gg_rct_Reg_Sel_Lord_Garithos= null
    rect gg_rct_Reg_Sel_Alquimista_pandaren= null
    rect gg_rct_Reg_Sel_DarthRemar= null
    rect gg_rct_Reg_Sel_Se__or_del_Fuego= null
    rect gg_rct_Reg_Sel_Se__or_de_las_bestias= null
    rect gg_rct_Reg_Sel_Naga_Royal= null
    rect gg_rct_Reg_Sel_Summoner_of_the_Thunder= null
    rect gg_rct_Reg_Sel_Troll_Berserker= null
    rect gg_rct_Reg_Sel_Nigromante= null
    rect gg_rct_Reg_Sel_Lich= null
    rect gg_rct_Reg_Sel_Se__or_del_terror= null
    rect gg_rct_Reg_Sel_Caballero_de_la_Muerte= null
    rect gg_rct_Reg_Sel_Se__or_de_la_cripta= null
    rect gg_rct_Reg_Sel_Butcher_Abomination= null
    rect gg_rct_Reg_Sel_Se__or_del_foso= null
    rect gg_rct_Reg_Sel_Maestro_de_las_Espadas= null
    rect gg_rct_Reg_Sel_Vidente= null
    rect gg_rct_Reg_Sel_Jefe_Tauren= null
    rect gg_rct_Reg_Sel_Cazador_de_sombras= null
    rect gg_rct_Reg_Sel_Grom_Hellscream= null
    rect gg_rct_Reg_Sel_Sylvanas_Orco= null
    rect gg_rct_Reg_Sel_Bruja_de_mar_naga= null
    rect gg_rct_Castillo_Hum= null
    rect gg_rct_Castillo_Orc= null
    sound gg_snd_CreepAggroWhat1= null
    sound gg_snd_Rescue= null
    sound gg_snd_ClanInvitation= null
    trigger gg_trg_IA_Brain_Macro= null
    trigger gg_trg_IA_Logic_Laning= null
    trigger gg_trg_IA_Data= null
    trigger gg_trg_IA_Core= null
    trigger gg_trg_IA_Utils= null
    trigger gg_trg_IA_Cerebro_Loop= null
    trigger gg_trg_IA_Arrancar= null
    trigger gg_trg_IA_Permisos= null
    trigger gg_trg_Core_Indice_Heroes= null
    trigger gg_trg_Core_Logica_Random= null
    trigger gg_trg_Core_Menu_Heroes_Click= null
    trigger gg_trg_Core_Menu_Heroes= null
    trigger gg_trg_Core_Mecanica_Oro= null
    trigger gg_trg_Core_Menu_Click= null
    trigger gg_trg_Core_Menu_Oro= null
    trigger gg_trg_Core_DetectarHost= null
    trigger gg_trg_Pick_01_Guardian_del_Bosque= null
    trigger gg_trg_Pick_02_Sacerdotisa_de_la_Luna= null
    trigger gg_trg_Pick_03_Cazador_de_Demonios= null
    trigger gg_trg_Pick_04_Guardiana= null
    trigger gg_trg_Pick_05_Paladin= null
    trigger gg_trg_Pick_06_Archimago= null
    trigger gg_trg_Pick_07_Rey_de_la_Montana= null
    trigger gg_trg_Pick_08_Mago_sanguinario= null
    trigger gg_trg_Pick_09_Alquimista= null
    trigger gg_trg_Pick_10_Hojalatero= null
    trigger gg_trg_Pick_11_Alquimista_pandaren= null
    trigger gg_trg_Pick_12_Lord_Garithos= null
    trigger gg_trg_Pick_13_SylvanasH= null
    trigger gg_trg_Pick_14_Asesina= null
    trigger gg_trg_Pick_15_Goblin_Techies= null
    trigger gg_trg_Pick_16_Sniper= null
    trigger gg_trg_Pick_17_Bandido= null
    trigger gg_trg_Pick_18_Magnadefender= null
    trigger gg_trg_Pick_19_CoCo= null
    trigger gg_trg_Pick_20_DarthRemar= null
    trigger gg_trg_Pick_21_Maestro_de_las_Espadas= null
    trigger gg_trg_Pick_22_Vidente= null
    trigger gg_trg_Pick_23_Jefe_Tauren= null
    trigger gg_trg_Pick_24_Cazador_de_sombras= null
    trigger gg_trg_Pick_25_Caballero_de_la_Muerte= null
    trigger gg_trg_Pick_26_Lich= null
    trigger gg_trg_Pick_27_Senor_del_terror= null
    trigger gg_trg_Pick_28_Senor_de_la_cripta= null
    trigger gg_trg_Pick_29_Bruja_de_mar_naga= null
    trigger gg_trg_Pick_30_Senor_de_las_bestias= null
    trigger gg_trg_Pick_31_Senor_del_Fuego= null
    trigger gg_trg_Pick_32_Senor_del_foso= null
    trigger gg_trg_Pick_33_Nigromante= null
    trigger gg_trg_Pick_34_Grom_Hellscream= null
    trigger gg_trg_Pick_35_SylvanasO= null
    trigger gg_trg_Pick_36_Butcher_Abomination= null
    trigger gg_trg_Pick_37_Naga_Royal= null
    trigger gg_trg_Pick_38_Summoner_of_the_Thunder= null
    trigger gg_trg_Pick_39_Troll_Berserker= null
    trigger gg_trg_Habilidad_Techies_Barril= null
    trigger gg_trg_Hook_TH= null
    trigger gg_trg_Hook_Init= null
    trigger gg_trg_Hook_Loop= null
    trigger gg_trg_Mega_Armadura_Fuerza= null
    trigger gg_trg_Mega_Armadura_Agilidad= null
    trigger gg_trg_Mega_Armadura_Inteligencia= null
    trigger gg_trg_Mega_Impacto_de_Dano= null
    trigger gg_trg_Mega_Hacha_Unicas= null
    trigger gg_trg_Mega_Libro_de_Ataque= null
    trigger gg_trg_Power_Treads= null
    trigger gg_trg_Fuerza_a_Inteligencia= null
    trigger gg_trg_Inteligencia_a_Agilidad= null
    trigger gg_trg_Agilidad_a_Fuerza= null
    trigger gg_trg_Botas_de_TP= null
    trigger gg_trg_Sistema_Deny= null
    trigger gg_trg_Sistema_Anuncios= null
    trigger gg_trg_Sistema_Cheat= null
    trigger gg_trg_Comando_Bounty= null
    trigger gg_trg_Sistema_Bounty_Track= null
    trigger gg_trg_Sistema_Kick= null
    trigger gg_trg_tabla= null
    trigger gg_trg_Zoom= null
    trigger gg_trg_init= null
    trigger gg_trg_IA_Logic_Survival= null
    trigger gg_trg_Colmillo_de_Hakkar= null
    trigger gg_trg_Garra_de_Mannoroth= null
    trigger gg_trg_Cetro_de_Kel_Thuzad= null
    trigger gg_trg_Manto_de_Maiev= null
    trigger gg_trg_Vestiduras_de_Ner_zhul= null
    trigger gg_trg_Baluarte_de_Lothar= null
    timer MB_Timer= CreateTimer()


    //JASSHelper struct globals:
    constant integer si__Bot=1
    integer si__Bot_F=0
    integer si__Bot_I=0
    integer array si__Bot_V
    unit array s__Bot_hero
    player array s__Bot_owner
    integer array s__Bot_heroId
    integer array s__Bot_lane
    integer array s__Bot_state
    real array s__Bot_hpPercent
    real array s__Bot_mpPercent

endglobals


//Generated allocator of Bot
function s__Bot__allocate takes nothing returns integer
    local integer this=si__Bot_F
    if (this!=0) then
        set si__Bot_F=si__Bot_V[this]
    else
        set si__Bot_I=si__Bot_I+1
        set this=si__Bot_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__Bot_V[this]=-1
    return this
endfunction

//Generated destructor of Bot
function s__Bot_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__Bot_V[this]!=-1) then
        return
    endif
    set si__Bot_V[this]=si__Bot_F
    set si__Bot_F=this
endfunction



// 1. Obtener Rango
function IAData_GetHeroAttackRange takes unit u returns real
    if IsUnitType(u, UNIT_TYPE_MELEE_ATTACKER) then
        return IAData_DEFAULT_RANGE_MELEE
    else
        return IAData_DEFAULT_RANGE_RANGED
    endif
endfunction

// 2. Obtener Punto de Daño (Delay)
function IAData_GetHeroDamagePoint takes unit u returns real
    return IAData_DEFAULT_DMG_POINT
endfunction

// 3. NUEVA FUNCIÓN: Obtener Daño Estimado (Compatible con 1.26)
function IAData_GetHeroEstimatedDamage takes unit u returns real
    local real damage= IAData_BASE_DAMAGE_AVG
    local integer primaryAttr= 0
        
    // En JASS clásico es difícil saber el atributo principal dinámicamente.
    // Por ahora, sumamos la Fuerza como aproximación segura o un promedio.
    // MÁS ADELANTE: Usaremos el ID del héroe para saber si sumar STR, AGI o INT.
        
    // Estimación: Daño Base + Fuerza (La mayoría de héroes ganan algo de daño con fuerza o es su stat)
    // Nota: Esto es temporal hasta que llenemos la tabla de héroes.
    set primaryAttr=GetHeroStr(u, true)
        
    return damage + I2R(primaryAttr)
endfunction


// ===================================================
// LIBRERÍA DE UTILIDADES MATEMÁTICAS PARA IA
// ===================================================


// 1. Obtener Distancia entre dos unidades
function IAUtils_GetDistanceUnits takes unit u1,unit u2 returns real
    local real dx= GetUnitX(u2) - GetUnitX(u1)
    local real dy= GetUnitY(u2) - GetUnitY(u1)
    return SquareRoot(dx * dx + dy * dy)
endfunction

// 2. Obtener Distancia entre unidad y punto (XY)
function IAUtils_GetDistanceUnitXY takes unit u,real x,real y returns real
    local real dx= x - GetUnitX(u)
    local real dy= y - GetUnitY(u)
    return SquareRoot(dx * dx + dy * dy)
endfunction

// 3. Obtener Ángulo entre dos unidades (en grados)
function IAUtils_GetAngleBetweenUnits takes unit u1,unit u2 returns real
    return Atan2(GetUnitY(u2) - GetUnitY(u1), GetUnitX(u2) - GetUnitX(u1)) * IAUtils_RADTODEG
endfunction
    
// 4. Proyección de Puntos (Moverse "dist" distancia hacia un ángulo)
// Retorna X
function IAUtils_ProjectX takes real x,real dist,real angle returns real
    return x + dist * Cos(angle * IAUtils_DEGTORAD)
endfunction
    
// Retorna Y
function IAUtils_ProjectY takes real y,real dist,real angle returns real
    return y + dist * Sin(angle * IAUtils_DEGTORAD)
endfunction




// Inicializa leyendo TUS REGIONES
function IABrainMacro_InitMacro takes nothing returns nothing
    // 1. Configurar Bases de Curación HUMANAS
    set HUM_BASE_TOP_X=GetRectCenterX(gg_rct_Base_Hum_Top)
    set HUM_BASE_TOP_Y=GetRectCenterY(gg_rct_Base_Hum_Top)
        
    set HUM_BASE_BOT_X=GetRectCenterX(gg_rct_Base_Hum_Bot)
    set HUM_BASE_BOT_Y=GetRectCenterY(gg_rct_Base_Hum_Bot)
        
    // 2. Configurar Bases de Curación ORCAS
    set ORC_BASE_TOP_X=GetRectCenterX(gg_rct_Base_Orc_Top)
    set ORC_BASE_TOP_Y=GetRectCenterY(gg_rct_Base_Orc_Top)
        
    set ORC_BASE_BOT_X=GetRectCenterX(gg_rct_Base_Orc_Bot)
    set ORC_BASE_BOT_Y=GetRectCenterY(gg_rct_Base_Orc_Bot)

    // 3. Configurar Castillos (Objetivo Final)
    set CASTLE_HUM_X=GetRectCenterX(gg_rct_Castillo_Hum)
    set CASTLE_HUM_Y=GetRectCenterY(gg_rct_Castillo_Hum)
    set CASTLE_ORC_X=GetRectCenterX(gg_rct_Castillo_Orc)
    set CASTLE_ORC_Y=GetRectCenterY(gg_rct_Castillo_Orc)
endfunction

// --- LÓGICA DE INTELIGENCIA ESPACIAL ---
    
// Función privada auxiliar para calcular distancia cuadrada (más rápido para CPU)
function IABrainMacro__GetDistSq takes real x1,real y1,real x2,real y2 returns real
    return ( x2 - x1 ) * ( x2 - x1 ) + ( y2 - y1 ) * ( y2 - y1 )
endfunction

// Obtener la Coordenada X de la base de curación más cercana
function IABrainMacro_GetClosestHomeX takes unit bot returns real
    local real botX= GetUnitX(bot)
    local real botY= GetUnitY(bot)
    local real distTop
    local real distBot
        
    // Si soy aliado de Humanos (Jugador 0-4)
    if IsPlayerAlly(GetOwningPlayer(bot), Player(0)) then
        set distTop=IABrainMacro__GetDistSq(botX , botY , HUM_BASE_TOP_X , HUM_BASE_TOP_Y)
        set distBot=IABrainMacro__GetDistSq(botX , botY , HUM_BASE_BOT_X , HUM_BASE_BOT_Y)
            
        if distTop < distBot then
            return HUM_BASE_TOP_X
        else
            return HUM_BASE_BOT_X
        endif
    else
        // Soy Orco
        set distTop=IABrainMacro__GetDistSq(botX , botY , ORC_BASE_TOP_X , ORC_BASE_TOP_Y)
        set distBot=IABrainMacro__GetDistSq(botX , botY , ORC_BASE_BOT_X , ORC_BASE_BOT_Y)
            
        if distTop < distBot then
            return ORC_BASE_TOP_X
        else
            return ORC_BASE_BOT_X
        endif
    endif
endfunction

// Obtener la Coordenada Y de la base de curación más cercana
function IABrainMacro_GetClosestHomeY takes unit bot returns real
    local real botX= GetUnitX(bot)
    local real botY= GetUnitY(bot)
    local real distTop
    local real distBot
        
    if IsPlayerAlly(GetOwningPlayer(bot), Player(0)) then
        set distTop=IABrainMacro__GetDistSq(botX , botY , HUM_BASE_TOP_X , HUM_BASE_TOP_Y)
        set distBot=IABrainMacro__GetDistSq(botX , botY , HUM_BASE_BOT_X , HUM_BASE_BOT_Y)
            
        if distTop < distBot then
            return HUM_BASE_TOP_Y
        else
            return HUM_BASE_BOT_Y
        endif
    else
        set distTop=IABrainMacro__GetDistSq(botX , botY , ORC_BASE_TOP_X , ORC_BASE_TOP_Y)
        set distBot=IABrainMacro__GetDistSq(botX , botY , ORC_BASE_BOT_X , ORC_BASE_BOT_Y)
            
        if distTop < distBot then
            return ORC_BASE_TOP_Y
        else
            return ORC_BASE_BOT_Y
        endif
    endif
endfunction

// --- FUNCIONES OFENSIVAS ---
function IABrainMacro_GetEnemyBaseX takes player p returns real
    if IsPlayerAlly(p, Player(0)) then
        return CASTLE_ORC_X
    else
        return CASTLE_HUM_X
    endif
endfunction

function IABrainMacro_GetEnemyBaseY takes player p returns real
    if IsPlayerAlly(p, Player(0)) then
        return CASTLE_ORC_Y
    else
        return CASTLE_HUM_Y
    endif
endfunction
    
function IABrainMacro_GetLaneTargetX takes integer lane,player p returns real
    // Si soy aliado de Humanos (Jugador 0-4), ataco bases Orcas
    if IsPlayerAlly(p, Player(0)) then
        if lane == 1 then
            return ORC_BASE_TOP_X // Atacar Top Orco
        else
            return ORC_BASE_BOT_X // Atacar Bot Orco
        endif
    else
        // Soy Orco, ataco bases Humanas
        if lane == 1 then
            return HUM_BASE_TOP_X // Atacar Top Humano
        else
            return HUM_BASE_BOT_X // Atacar Bot Humano
        endif
    endif
endfunction

function IABrainMacro_GetLaneTargetY takes integer lane,player p returns real
    if IsPlayerAlly(p, Player(0)) then
        if lane == 1 then
            return ORC_BASE_TOP_Y
        else
            return ORC_BASE_BOT_Y
        endif
    else
        if lane == 1 then
            return HUM_BASE_TOP_Y
        else
            return HUM_BASE_BOT_Y
        endif
    endif
endfunction

// --- [RECUPERADO] ASIGNACIÓN DE LÍNEAS ---
// Vital para decidir si el bot va a TOP o BOT al nacer
function IABrainMacro_AssignLane takes player p returns integer
    local integer id= GetPlayerId(p)
    // Lógica simple: Pares e Impares (o la lógica que prefieras)
    if ( id - ( id / 2 ) * 2 ) == 0 then
        return 1 // Top
    else
        return 2 // Bot
    endif
endfunction




function IALogicLaning_ExecuteLaning takes unit botUnit,player botOwner returns nothing
    // --- 1. VARIABLES ---
    local group g
        
    // OBJETIVOS
    local unit killTarget= null
    local unit standardTarget= null
    local unit enumUnit
    local unit lastTarget= null
        
    // VALORES
    local real lowestKillHP= 99999.0
    local real bestStandardScore= - 99999.0
    local real currentScore
        
    // DATOS DE LA UNIDAD
    local real enumHP
    local real enumMaxHP
    local boolean isEnemy
    local boolean isHero
    local boolean isStruct
    local real dist
        
    // DATOS PROPIOS
    local real myDamage
    local real myRange
    local integer botHandle= GetHandleId(botUnit)
    local integer currentOrder= GetUnitCurrentOrder(botUnit)
    local boolean amIMelee= false
        
    // SEGURIDAD
    local boolean isLethalHero
    local real safetyPenalty
    local integer nearbyAggroCount= 0
    local integer nearbyTowerCount= 0
    local boolean isRetreating
    local real safeX
    local real safeY
        
    // MOVIMIENTO
    local real destX
    local real destY

    // --- 2. PREPARACIÓN ---
    set myRange=IAData_GetHeroAttackRange(botUnit)
    set myDamage=IAData_GetHeroEstimatedDamage(botUnit)
    set lastTarget=LoadUnitHandle(IA_Laning_Memory, botHandle, 0)
        
    if myRange < 150.0 then
        set amIMelee=true
    endif

    // --- 3. GESTIÓN DE ESTADO DE PÁNICO (PERSISTENCIA) ---
    // Recuperamos si estábamos huyendo en el ciclo anterior
    set isRetreating=LoadBoolean(IA_Laning_Memory, botHandle, 1)

    // --- 4. ESCANEO ---
    set g=CreateGroup()
    call GroupEnumUnitsInRange(g, GetUnitX(botUnit), GetUnitY(botUnit), 800.0, null)
        
    loop
        set enumUnit=FirstOfGroup(g)
        exitwhen enumUnit == null
        call GroupRemoveUnit(g, enumUnit)
            
        if not IsUnitType(enumUnit, UNIT_TYPE_DEAD) then
            set enumHP=GetUnitState(enumUnit, UNIT_STATE_LIFE)
            set enumMaxHP=GetUnitState(enumUnit, UNIT_STATE_MAX_LIFE)
            set isEnemy=IsUnitEnemy(enumUnit, botOwner)
            set isHero=IsUnitType(enumUnit, UNIT_TYPE_HERO)
            set isStruct=IsUnitType(enumUnit, UNIT_TYPE_STRUCTURE)
            set dist=IAUtils_GetDistanceUnits(botUnit , enumUnit)
                
            // --- SENSOR DE AGGRO ---
            if isEnemy then
                // RANGED: Pánico a < 250
                // MELEE: Pánico a < 200 (Permitimos contacto cercano)
                // RETIRADA: Si ya estamos huyendo, somos más sensibles (contamos hasta 500 para dejar de huir)
                if not isStruct then
                    if ( isRetreating and dist < 500.0 ) or ( not isRetreating and dist < ( 250.0 ) ) then
                        set nearbyAggroCount=nearbyAggroCount + 1
                    endif
                endif
                    
                // TORRES
                if isStruct and dist < 750.0 then
                    set nearbyTowerCount=nearbyTowerCount + 1
                endif
            endif
                
            // --- ZONA LETAL ---
            set isLethalHero=( isHero and isEnemy and ( enumHP / enumMaxHP ) < 0.15 and dist <= myRange + 200 )
                
            // --- SELECCION NIVEL 1 (LAST HIT / KILL) ---
            // NOTA: Aquí NO aplicamos filtro de distancia melee. El ORO es sagrado.
            if ( isEnemy and ( enumHP <= myDamage or isLethalHero ) ) or ( not isEnemy and enumHP <= myDamage and enumHP < enumMaxHP * 0.50 and not isHero ) then
                if isHero and isEnemy then
                    set killTarget=enumUnit
                    set lowestKillHP=- 1.0
                else
                    if enumHP < lowestKillHP and lowestKillHP != - 1.0 then
                        set lowestKillHP=enumHP
                        set killTarget=enumUnit
                    endif
                endif
            endif
                
            // --- SELECCION NIVEL 2 (ESTÁNDAR) ---
            if isEnemy and killTarget == null then
                    
                // FILTRO MELEE INTELIGENTE:
                // Solo ignoramos objetivos ESTÁNDAR lejanos. No last hits.
                // Si soy Melee y está lejos (>300) y NO es Héroe, lo ignoro.
                if ( not amIMelee ) or ( isHero ) or ( dist < 300.0 ) or ( enumUnit == lastTarget ) then
                    
                    set currentScore=0.0
                        
                    if isStruct and ( enumHP / enumMaxHP ) < 0.15 then
                        set currentScore=5000.0 + ( enumMaxHP - enumHP )
                    elseif isHero then
                        set currentScore=300.0 + ( ( 1.0 - ( enumHP / enumMaxHP ) ) * 500.0 )
                    elseif isStruct then
                        set currentScore=400.0 - enumHP
                    else
                        set currentScore=200.0 + ( 100.0 - ( enumHP / enumMaxHP ) * 100.0 )
                    endif
                        
                    // Penalización Distancia
                    if isHero then
                        set safetyPenalty=dist * 0.8
                    else
                        set safetyPenalty=dist * 0.2
                    endif
                    set currentScore=currentScore - safetyPenalty
                        
                    // Persistencia
                    if enumUnit == lastTarget then
                        set currentScore=currentScore + 50.0
                    endif

                    if currentScore > bestStandardScore then
                        set bestStandardScore=currentScore
                        set standardTarget=enumUnit
                    endif
                endif
            endif
                
        endif
    endloop
    call DestroyGroup(g)
        
    // --- 4. TOMA DE DECISIÓN ---
        
    // A) LÓGICA DE SUPERVIVENCIA (DE-AGGRO con HISTÉRESIS)
    // Solo huimos si NO estamos asegurando una kill
    if ( lowestKillHP != - 1.0 ) then
        // Condiciones de activación del pánico
        if ( ( not amIMelee ) and ( nearbyAggroCount >= 1 ) ) or ( amIMelee and ( ( nearbyAggroCount >= 3 ) or ( nearbyAggroCount >= 2 and GetUnitState(botUnit, UNIT_STATE_LIFE) < GetUnitState(botUnit, UNIT_STATE_MAX_LIFE) * 0.50 ) ) ) or ( ( nearbyTowerCount > 0 ) and ( GetUnitState(botUnit, UNIT_STATE_LIFE) < GetUnitState(botUnit, UNIT_STATE_MAX_LIFE) * 0.70 ) ) then
                
            // EJECUTAR RETIRADA
            set safeX=IABrainMacro_GetClosestHomeX(botUnit)
            set safeY=IABrainMacro_GetClosestHomeY(botUnit)
                
            // Solo ordenamos mover si no estamos ya moviéndonos (Anti-Spam)
            // O si la orden anterior era atacar (hay que cancelar ataque para huir)
            if ( currentOrder != OrderId("move") ) then
                call IssuePointOrder(botUnit, "move", safeX, safeY)
            endif
                
            // GUARDAMOS ESTADO: "Estoy retirándome"
            call SaveBoolean(IA_Laning_Memory, botHandle, 1, true)
            call RemoveSavedHandle(IA_Laning_Memory, botHandle, 0) // Olvidar target ofensivo
            return
        endif
    endif
        
    // Si llegamos aquí, NO estamos en peligro crítico.
    // PERO verificamos: ¿Estábamos huyendo antes? Si es así, significa que ya estamos seguros (nearbyAggroCount bajó).
    if isRetreating then
        // Ya no hay peligro (Aggro count es bajo). Apagamos la alarma.
        call SaveBoolean(IA_Laning_Memory, botHandle, 1, false)
        // No hacemos return, dejamos que fluya a la lógica ofensiva para "contraatacar" al instante.
    endif

    // B) OFENSIVA: LAST HIT
    if killTarget != null then
        if IAUtils_GetDistanceUnits(botUnit , killTarget) <= myRange + 50 then
            if ( currentOrder != OrderId("attack") ) or ( killTarget != lastTarget ) then
                call IssueTargetOrder(botUnit, "attack", killTarget)
                call SaveUnitHandle(IA_Laning_Memory, botHandle, 0, killTarget)
            endif
        else
            call IssuePointOrder(botUnit, "move", GetUnitX(killTarget), GetUnitY(killTarget))
            call RemoveSavedHandle(IA_Laning_Memory, botHandle, 0)
        endif
            
        // C) OFENSIVA: ESTÁNDAR
    elseif standardTarget != null then
        if IAUtils_GetDistanceUnits(botUnit , standardTarget) <= myRange + 50 then
            if ( currentOrder != OrderId("attack") ) or ( standardTarget != lastTarget ) then
                call IssueTargetOrder(botUnit, "attack", standardTarget)
                call SaveUnitHandle(IA_Laning_Memory, botHandle, 0, standardTarget)
            endif
        else
            // Volvemos a IssuePointOrder MOVE o ATTACK según prefieras.
            // Attack es más seguro para no ignorar colisiones, Move es más preciso.
            // Para melee, MOVE es mejor para acercarse sin distraerse.
            call IssuePointOrder(botUnit, "move", GetUnitX(standardTarget), GetUnitY(standardTarget))
            call RemoveSavedHandle(IA_Laning_Memory, botHandle, 0)
        endif
            
        // D) SIN OBJETIVOS: AVANCE
    else
        call RemoveSavedHandle(IA_Laning_Memory, botHandle, 0)
        set destX=IABrainMacro_GetEnemyBaseX(botOwner)
        set destY=IABrainMacro_GetEnemyBaseY(botOwner)
            
        if currentOrder != OrderId("attack") then
            call IssuePointOrder(botUnit, "attack", destX, destY)
        endif
    endif
        
    // Limpieza
    set killTarget=null
    set standardTarget=null
    set enumUnit=null
    set lastTarget=null
endfunction




// ¿DEBO HUIR?
function IALogicSurvival_ShouldRetreat takes real hpPercent returns boolean
    return hpPercent < IALogicSurvival_LOW_HP_THRESHOLD
endfunction

// ¿ESTOY SANO?
function IALogicSurvival_IsHealthy takes real hpPercent returns boolean
    return hpPercent > IALogicSurvival_HEALTHY_THRESHOLD
endfunction

// EJECUTAR HUIDA (ANTI-SHAKE V2)
function IALogicSurvival_ExecuteRetreat takes unit botUnit,player botOwner returns nothing
    local real homeX
    local real homeY
    local real dist
    local integer currentOrder
        
    set homeX=IABrainMacro_GetClosestHomeX(botUnit)
    set homeY=IABrainMacro_GetClosestHomeY(botUnit)
    set currentOrder=GetUnitCurrentOrder(botUnit)
        
    // Calculamos distancia a la base
    set dist=IAUtils_GetDistanceUnitXY(botUnit , homeX , homeY)
        
    // --- FILTRO ANTI-TEMBLOR ---
    // Si ya tengo la orden de "move" (851986) Y estoy relativamente lejos de la base (> 300),
    // ASUMIMOS que ya estoy corriendo hacia allá. No doy la orden de nuevo.
    // Esto permite que el pathfinding de Warcraft 3 fluya suavemente.
    if currentOrder == OrderId("move") and dist > 300.0 then
        return
    endif
        
    // Si no estoy moviéndome, o estoy haciendo otra cosa, doy la orden.
    call IssuePointOrder(botUnit, "move", homeX, homeY)
endfunction



// ==========================================================
// ESTRUCTURA DEL BOT
// ==========================================================
        
// --- PROPIEDAD NUEVA ---
        
// --- ESTADOS MENTALES ---
// 1=Laning, 3=Survival (Huida)
        
// --- DATOS TÁCTICOS ---
        
function s__Bot_create takes unit u returns integer
    local integer b= s__Bot__allocate()
    set s__Bot_hero[b]=u
    set s__Bot_owner[b]=GetOwningPlayer(u)
    set s__Bot_heroId[b]=GetUnitTypeId(u)
    set s__Bot_state[b]=1
            
    // ASIGNAMOS SU CARRIL AL NACER Y LO RECORDAMOS PARA SIEMPRE
    set s__Bot_lane[b]=IABrainMacro_AssignLane(s__Bot_owner[b])
            
    return b
endfunction
        
function s__Bot_update takes integer this returns nothing
    // Seguridad: Si está muerto, no pensamos
    if IsUnitType(s__Bot_hero[this], UNIT_TYPE_DEAD) or GetUnitTypeId(s__Bot_hero[this]) == 0 then
        return
    endif

    // 1. ACTUALIZAR SENSORES
    set s__Bot_hpPercent[this]=GetUnitState(s__Bot_hero[this], UNIT_STATE_LIFE) / GetUnitState(s__Bot_hero[this], UNIT_STATE_MAX_LIFE)
    set s__Bot_mpPercent[this]=GetUnitState(s__Bot_hero[this], UNIT_STATE_MANA) / GetUnitState(s__Bot_hero[this], UNIT_STATE_MAX_MANA)
            
    // ==================================================
    // MÁQUINA DE ESTADOS (SELECTOR ESTRICTO)
    // ==================================================
            
    // TRANSICIONES
    if s__Bot_state[this] != 3 then
        // Si estamos bien, chequeamos si debemos huir
        if (((s__Bot_hpPercent[this])*1.0) < IALogicSurvival_LOW_HP_THRESHOLD) then // INLINED!!
            set s__Bot_state[this]=3 // ¡CAMBIO A HUIDA!
        endif
    else
        // Si estamos huyendo, chequeamos si ya estamos sanos
        if (((s__Bot_hpPercent[this])*1.0) > IALogicSurvival_HEALTHY_THRESHOLD) then // INLINED!!
            set s__Bot_state[this]=1 // ¡VOLVER A LANING!
                    
            // CORRECCIÓN: Volvemos a NUESTRA línea (this.lane), no siempre a la 1.
            // Nota: Asumo que tienes funciones GetLaneTargetX/Y que aceptan el ID del lane.
            // Si no las tienes en BrainMacro, avísame, pero conceptualmente es esto:
            // Corrección: Pasamos 'this.owner' para saber si atacar base Orca o Humana
            call IssuePointOrder(s__Bot_hero[this], "attack", IABrainMacro_GetLaneTargetX(s__Bot_lane[this] , s__Bot_owner[this]), IABrainMacro_GetLaneTargetY(s__Bot_lane[this] , s__Bot_owner[this]))

        endif
    endif

    // ==================================================
    // EJECUCIÓN
    // ==================================================
            
    if s__Bot_state[this] == 3 then
        // MODO SUPERVIVENCIA (Prioridad Total)
        call IALogicSurvival_ExecuteRetreat(s__Bot_hero[this] , s__Bot_owner[this])
                
    elseif s__Bot_state[this] == 1 then
        // MODO LANING
        // Pasamos "this.lane" si tu lógica de laning necesita saber en qué carril estar,
        // aunque IALogicLaning actual es muy "local" (ataca lo que ve), así que con hero/owner basta.
        call IALogicLaning_ExecuteLaning(s__Bot_hero[this] , s__Bot_owner[this])
    endif

endfunction

// ==========================================================
// SISTEMA CENTRAL (ENGINE) - SIN CAMBIOS
// ==========================================================

function IACore_RegisterHero takes unit u returns nothing
    set BotsActive[BotsCount]=s__Bot_create(u)
    set BotsCount=BotsCount + 1
endfunction

function IACore___MainLoop takes nothing returns nothing
    local integer i= 0
    loop
        exitwhen i >= BotsCount
        if not IsUnitType(s__Bot_hero[BotsActive[i]], UNIT_TYPE_DEAD) and GetUnitTypeId(s__Bot_hero[BotsActive[i]]) != 0 then
            call s__Bot_update(BotsActive[i])
        endif
        set i=i + 1
    endloop
endfunction

function IACore_StartEngine takes nothing returns nothing
    if IA_System_On == true then
        return
    endif
        
    // INICIALIZAR EL MACRO
    call IABrainMacro_InitMacro()
        
    set IA_System_On=true
    set IA_Timer_Loop=CreateTimer()
    call TimerStart(IA_Timer_Loop, 0.10, true, function IACore___MainLoop)
    call BJDebugMsg("|cff00FFFF[IA SYSTEM]|r MOTOR INICIADO. Ciclos: 0.1s")
endfunction

function IACore_InitializeBots takes nothing returns nothing
    local integer i= 0
    local player p
    local group g
    local unit u
        
    if IA_System_On == true then
        return
    endif

    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 5.0, "|cffFFCC00[SISTEMA]|r Detectando Heroes y Activando IA...")

    loop
        exitwhen i > 9
        set p=Player(i)
        if GetPlayerController(p) == MAP_CONTROL_COMPUTER and GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING then
            set g=CreateGroup()
            call GroupEnumUnitsOfPlayer(g, p, null)
            loop
                set u=FirstOfGroup(g)
                exitwhen u == null
                call GroupRemoveUnit(g, u)
                if IsUnitType(u, UNIT_TYPE_HERO) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                    call IACore_RegisterHero(u)
                endif
            endloop
            call DestroyGroup(g)
        endif
        set i=i + 1
    endloop
        
    set p=null
    set g=null
    set u=null
        
    call IACore_StartEngine()
endfunction


//===========================================================================
// 
// OvsH XS 1.09 + AI
// 
//   Warcraft III map script
//   Generated by the Warcraft III World Editor
//   Date: Mon Jan 26 10:10:30 2026
//   Map Author: -=| MateViva
// 
//===========================================================================

//***************************************************************************
//*
//*  Global Variables
//*
//***************************************************************************


function InitGlobals takes nothing returns nothing
    local integer i= 0
    set udg_integer01=0
    set udg_integer02=0
    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_integers01[i]=0
        set i=i + 1
    endloop

    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_strings01[i]=""
        set i=i + 1
    endloop

    set udg_integer03=0
    set udg_integer04=0
    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_integers02[i]=0
        set i=i + 1
    endloop

    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_integers03[i]=0
        set i=i + 1
    endloop

    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_strings02[i]=""
        set i=i + 1
    endloop

    set udg_integer05=0
    set udg_timer01=CreateTimer()
    set udg_integer06=0
    set udg_group01=CreateGroup()
    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_timers01[i]=CreateTimer()
        set i=i + 1
    endloop

    set udg_real01=0
    set udg_real02=0
    set udg_boolean01=false
    set udg_boolean02=false
    set udg_force01=CreateForce()
    set udg_group02=CreateGroup()
    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_strings03[i]=""
        set i=i + 1
    endloop

    set udg_integer07=0
    set udg_integer08=0
    set udg_group03=CreateGroup()
    set udg_force02=CreateForce()
    set udg_integer09=0
    set udg_integer10=0
    set udg_integer11=0
    set udg_force03=CreateForce()
    set udg_integer12=0
    set udg_integer13=0
    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_integers04[i]=0
        set i=i + 1
    endloop

    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_integers05[i]=0
        set i=i + 1
    endloop

    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_integers06[i]=0
        set i=i + 1
    endloop

    set udg_integer14=0
    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_integers07[i]=0
        set i=i + 1
    endloop

    set udg_integer15=0
    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_integers08[i]=0
        set i=i + 1
    endloop

    set udg_integer16=0
    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_integers09[i]=0
        set i=i + 1
    endloop

    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_integers10[i]=0
        set i=i + 1
    endloop

    set udg_force04=CreateForce()
    set udg_force05=CreateForce()
    set udg_integer17=0
    set udg_force06=CreateForce()
    set udg_force07=CreateForce()
    set udg_integer18=0
    set udg_force08=CreateForce()
    set udg_integer19=0
    set udg_force09=CreateForce()
    set udg_integer20=0
    set udg_force10=CreateForce()
    set udg_integer21=0
    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_integers11[i]=0
        set i=i + 1
    endloop

    set udg_integer22=0
    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_integers12[i]=0
        set i=i + 1
    endloop

    set udg_boolean03=false
    set udg_integer23=0
    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_integers13[i]=0
        set i=i + 1
    endloop

    set udg_integer24=0
    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_integers14[i]=0
        set i=i + 1
    endloop

    set udg_integer25=0
    set udg_integer26=0
    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_integers15[i]=0
        set i=i + 1
    endloop

    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_integers16[i]=0
        set i=i + 1
    endloop

    set udg_integer27=0
    set udg_integer28=0
    set udg_integer29=0
    set udg_force11=CreateForce()
    set udg_force12=CreateForce()
    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_integers17[i]=0
        set i=i + 1
    endloop

    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_integers18[i]=0
        set i=i + 1
    endloop

    set udg_boolean04=false
    set udg_force13=CreateForce()
    set udg_timer02=CreateTimer()
    set udg_timer03=CreateTimer()
    set udg_timer04=CreateTimer()
    set udg_timer05=CreateTimer()
    set udg_timer06=CreateTimer()
    set udg_timer07=CreateTimer()
    set udg_timer08=CreateTimer()
    set udg_timer09=CreateTimer()
    set udg_timer10=CreateTimer()
    set udg_timer11=CreateTimer()
    set udg_boolean05=false
    set udg_force14=CreateForce()
    set udg_force15=CreateForce()
    set udg_boolean06=false
    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_dialogs01[i]=DialogCreate()
        set i=i + 1
    endloop

    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_dialogs02[i]=DialogCreate()
        set i=i + 1
    endloop

    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_dialogs03[i]=DialogCreate()
        set i=i + 1
    endloop

    set udg_boolean07=false
    set udg_dialog01=DialogCreate()
    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_booleans01[i]=false
        set i=i + 1
    endloop

    set udg_integer30=0
    set udg_integer31=0
    set udg_integer32=0
    set udg_integer33=0
    set udg_integer34=0
    set udg_integer35=0
    set udg_dialog02=DialogCreate()
    set udg_integer36=0
    set udg_boolean08=false
    set udg_dialog03=DialogCreate()
    set udg_integer37=0
    set udg_boolean09=false
    set udg_integer38=0
    set udg_integer39=0
    set udg_integer40=0
    set udg_group04=CreateGroup()
    set udg_real03=0
    set udg_integer41=0
    set udg_integer42=0
    set udg_real04=0
    set udg_group05=CreateGroup()
    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_booleans02[i]=false
        set i=i + 1
    endloop

    set udg_integer43=0
    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_integers19[i]=0
        set i=i + 1
    endloop

    set udg_integer44=0
    set udg_integer45=0
    set udg_integer46=0
    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_dialogs04[i]=DialogCreate()
        set i=i + 1
    endloop

    set udg_integer47=0
    set udg_integer48=0
    set udg_boolean10=false
    set udg_string01=""
    set udg_IA_Grupo_Humanos=CreateGroup()
    set udg_IA_Grupo_Orcos=CreateGroup()
    set i=0
    loop
        exitwhen ( i > 12 )
        set udg_IA_Estado[i]="IDLE"
        set i=i + 1
    endloop

    set udg_IA_Temporizador=CreateTimer()
    set udg_Temp_Grupo=CreateGroup()
    set udg_IA_Amenaza=0
    set udg_UI_Ventana_General=DialogCreate()
    set udg_Config_Modo_Humanos=0
    set udg_Config_Modo_Orcos=0
    set udg_UI_Ventana_Heroes=DialogCreate()
    set udg_Config_Cantidad_Oro=1
    set udg_Grupo_Humanos=CreateForce()
    set udg_Grupo_Orcos=CreateForce()
    set udg_Core_HayBots=false
    set udg_Temp_MasterEncontrado=false
    set i=0
    loop
        exitwhen ( i > 2 )
        set udg_Config_Total_Heroes[i]=0
        set i=i + 1
    endloop

    set udg_Temp_Int_Random=0
    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_HookMUI[i]=0
        set i=i + 1
    endloop

    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_Angulo[i]=0
        set i=i + 1
    endloop

    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_Distancia[i]=0
        set i=i + 1
    endloop

    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_Distancia_MAX[i]=0
        set i=i + 1
    endloop

    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_Damange[i]=0
        set i=i + 1
    endloop

    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_Velocidad_Cadena[i]=0
        set i=i + 1
    endloop

    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_Hook_Drag[i]=false
        set i=i + 1
    endloop

    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_ON_OFF[i]=false
        set i=i + 1
    endloop

    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_Contador_Cadena[i]=0
        set i=i + 1
    endloop

    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_Hook_Grupo[i]=CreateGroup()
        set i=i + 1
    endloop

    set udg_IA_Sistema_Activo=false
endfunction

//***************************************************************************
//*
//*  Sounds
//*
//***************************************************************************

function InitSounds takes nothing returns nothing
    set gg_snd_CreepAggroWhat1=CreateSound("Sound\\Interface\\CreepAggroWhat1.wav", false, false, false, 10, 10, "")
    call SetSoundParamsFromLabel(gg_snd_CreepAggroWhat1, "CreepAggro")
    call SetSoundDuration(gg_snd_CreepAggroWhat1, 1236)
    set gg_snd_Rescue=CreateSound("Sound\\Interface\\Rescue.wav", false, false, false, 10, 10, "")
    call SetSoundParamsFromLabel(gg_snd_Rescue, "Rescue")
    call SetSoundDuration(gg_snd_Rescue, 3796)
    set gg_snd_ClanInvitation=CreateSound("Sound\\Interface\\ClanInvitation.wav", false, false, false, 10, 10, "")
    call SetSoundParamsFromLabel(gg_snd_ClanInvitation, "ClanInvitation")
    call SetSoundDuration(gg_snd_ClanInvitation, 4296)
endfunction

//***************************************************************************
//*
//*  Unit Creation
//*
//***************************************************************************

//===========================================================================
function CreateNeutralPassive takes nothing returns nothing
    local player p= Player(PLAYER_NEUTRAL_PASSIVE)
    local unit u
    local integer unitID
    local trigger t
    local real life

    set u=CreateUnit(p, 'H00Q', - 5749.2, - 1557.5, 109.978)
    set u=CreateUnit(p, 'H00R', - 6008.8, - 1557.3, 86.029)
    set u=CreateUnit(p, 'H00Y', - 6276.4, - 1357.7, 37.009)
    set u=CreateUnit(p, 'Hvwd', - 5503.2, - 1328.9, 122.560)
    set u=CreateUnit(p, 'O00B', - 6323.5, - 1090.3, 347.992)
    set u=CreateUnit(p, 'H00G', - 5476.7, - 1095.2, 196.962)
    set u=CreateUnit(p, 'H00U', - 6310.0, - 836.7, 284.324)
    set u=CreateUnit(p, 'Ntin', - 5747.0, 515.9, 237.843)
    set u=CreateUnit(p, 'E005', - 6307.9, - 604.8, 3.973)
    set u=CreateUnit(p, 'Hlgr', - 5432.7, - 600.6, 163.372)
    set u=CreateUnit(p, 'Hblm', - 5468.8, - 332.1, 204.590)
    set u=CreateUnit(p, 'Ekee', - 6300.9, - 368.0, 351.188)
    set u=CreateUnit(p, 'Ewar', - 6305.4, - 131.1, 358.422)
    set u=CreateUnit(p, 'Hmkg', - 5471.3, - 134.9, 200.968)
    set u=CreateUnit(p, 'Emoo', - 6337.3, 63.3, 356.782)
    set u=CreateUnit(p, 'Hamg', - 5458.5, 49.5, 185.448)
    set u=CreateUnit(p, 'Edem', - 6049.7, 520.3, 259.864)
    set u=CreateUnit(p, 'Hpal', - 5496.6, 339.9, 234.642)
    set u=CreateUnit(p, 'Nalc', - 6305.1, 326.2, 316.676)
    set u=CreateUnit(p, 'Npbm', - 5455.4, - 845.6, 187.555)
    set u=CreateUnit(p, 'Nfir', 5895.0, - 2039.7, 100.679)
    set u=CreateUnit(p, 'Nngs', 5564.6, - 1908.6, 15.294)
    set u=CreateUnit(p, 'Nbst', 6168.8, - 1972.3, 108.221)
    set u=CreateUnit(p, 'Usyl', 5457.9, - 1582.8, 13.803)
    set u=CreateUnit(p, 'H00V', 6394.2, - 1708.4, 175.372)
    set u=CreateUnit(p, 'H00K', 6352.5, - 1480.6, 178.843)
    set u=CreateUnit(p, 'Ogrh', 5426.9, - 1231.0, 339.488)
    set u=CreateUnit(p, 'N020', 6365.9, - 1246.7, 178.487)
    set u=CreateUnit(p, 'Nman', 6338.7, - 997.8, 180.939)
    set u=CreateUnit(p, 'Oshd', 5376.0, - 929.1, 5.825)
    set u=CreateUnit(p, 'Otch', 5387.0, - 615.6, 12.110)
    set u=CreateUnit(p, 'Udre', 6340.4, - 535.8, 199.893)
    set u=CreateUnit(p, 'Ofar', 5377.8, - 309.1, 351.485)
    set u=CreateUnit(p, 'Udea', 6358.4, - 297.6, 185.910)
    set u=CreateUnit(p, 'Obla', 5407.0, - 43.8, 340.535)
    set u=CreateUnit(p, 'Ucrl', 6297.6, 31.6, 209.644)
    set u=CreateUnit(p, 'Nplh', 5645.2, 265.6, 267.118)
    set u=CreateUnit(p, 'H00P', 5978.9, 270.2, 235.814)
    set u=CreateUnit(p, 'Ulic', 6339.5, - 759.2, 177.932)
endfunction

//===========================================================================
function CreatePlayerBuildings takes nothing returns nothing
endfunction

//===========================================================================
function CreatePlayerUnits takes nothing returns nothing
endfunction

//===========================================================================
function CreateAllUnits takes nothing returns nothing
    call CreatePlayerBuildings()
    call CreateNeutralPassive()
    call CreatePlayerUnits()
endfunction

//***************************************************************************
//*
//*  Regions
//*
//***************************************************************************

function CreateRegions takes nothing returns nothing
    local weathereffect we

    set gg_rct_Base_Hum_Top=Rect(- 4736.0, 2240.0, - 4416.0, 2528.0)
    set gg_rct_Base_Hum_Bot=Rect(- 4640.0, - 3072.0, - 4224.0, - 2752.0)
    set gg_rct_Base_Orc_Top=Rect(4160.0, 1984.0, 4544.0, 2304.0)
    set gg_rct_Base_Orc_Bot=Rect(4032.0, - 3040.0, 4384.0, - 2784.0)
    set gg_rct_Linea_Arriba=Rect(- 864.0, 1120.0, 352.0, 2112.0)
    set gg_rct_Linea_Abajo=Rect(- 864.0, - 2656.0, 352.0, - 1728.0)
    set gg_rct_Reg_Sel_Sniper=Rect(- 6112.0, - 1664.0, - 5888.0, - 1376.0)
    set gg_rct_Reg_Sel_Bandido=Rect(- 5856.0, - 1664.0, - 5632.0, - 1376.0)
    set gg_rct_Reg_Sel_Sylvanas_Humano=Rect(- 5632.0, - 1376.0, - 5408.0, - 1216.0)
    set gg_rct_Reg_Sel_CoCo=Rect(- 6432.0, - 1440.0, - 6112.0, - 1216.0)
    set gg_rct_Reg_Sel_Magnadefender=Rect(- 6464.0, - 1184.0, - 6176.0, - 992.0)
    set gg_rct_Reg_Sel_Goblin_Techies=Rect(- 6464.0, - 928.0, - 6144.0, - 736.0)
    set gg_rct_Reg_Sel_Asesina=Rect(- 6464.0, - 672.0, - 6144.0, - 512.0)
    set gg_rct_Reg_Sel_Guardi__n_del_Bosque=Rect(- 6464.0, - 416.0, - 6144.0, - 224.0)
    set gg_rct_Reg_Sel_Guardiana=Rect(- 6464.0, - 192.0, - 6144.0, - 64.0)
    set gg_rct_Reg_Sel_Sacerdotisa_de_la_Luna=Rect(- 6496.0, - 32.0, - 6144.0, 128.0)
    set gg_rct_Reg_Sel_Alquimista=Rect(- 6432.0, 192.0, - 6144.0, 416.0)
    set gg_rct_Reg_Sel_Cazador_de_Demonios=Rect(- 6144.0, 352.0, - 5920.0, 640.0)
    set gg_rct_Reg_Sel_Hojalatero=Rect(- 5856.0, 352.0, - 5632.0, 640.0)
    set gg_rct_Reg_Sel_Paladin=Rect(- 5632.0, 192.0, - 5376.0, 416.0)
    set gg_rct_Reg_Sel_Archimago=Rect(- 5632.0, - 32.0, - 5312.0, 160.0)
    set gg_rct_Reg_Sel_Rey_de_la_Monta__a=Rect(- 5632.0, - 192.0, - 5312.0, - 64.0)
    set gg_rct_Reg_Sel_Mago_sanguinario=Rect(- 5632.0, - 416.0, - 5312.0, - 256.0)
    set gg_rct_Reg_Sel_Lord_Garithos=Rect(- 5632.0, - 704.0, - 5312.0, - 512.0)
    set gg_rct_Reg_Sel_Alquimista_pandaren=Rect(- 5632.0, - 928.0, - 5312.0, - 768.0)
    set gg_rct_Reg_Sel_DarthRemar=Rect(- 5600.0, - 1152.0, - 5344.0, - 1024.0)
    set gg_rct_Reg_Sel_Se__or_del_Fuego=Rect(5792.0, - 2144.0, 5984.0, - 1824.0)
    set gg_rct_Reg_Sel_Se__or_de_las_bestias=Rect(6048.0, - 2048.0, 6272.0, - 1792.0)
    set gg_rct_Reg_Sel_Naga_Royal=Rect(6208.0, - 1792.0, 6496.0, - 1600.0)
    set gg_rct_Reg_Sel_Summoner_of_the_Thunder=Rect(6208.0, - 1536.0, 6464.0, - 1408.0)
    set gg_rct_Reg_Sel_Troll_Berserker=Rect(6176.0, - 1344.0, 6496.0, - 1184.0)
    set gg_rct_Reg_Sel_Nigromante=Rect(6144.0, - 1056.0, 6496.0, - 896.0)
    set gg_rct_Reg_Sel_Lich=Rect(6176.0, - 800.0, 6528.0, - 672.0)
    set gg_rct_Reg_Sel_Se__or_del_terror=Rect(6176.0, - 608.0, 6528.0, - 448.0)
    set gg_rct_Reg_Sel_Caballero_de_la_Muerte=Rect(6112.0, - 384.0, 6496.0, - 192.0)
    set gg_rct_Reg_Sel_Se__or_de_la_cripta=Rect(6144.0, - 128.0, 6496.0, 96.0)
    set gg_rct_Reg_Sel_Butcher_Abomination=Rect(5824.0, 64.0, 6080.0, 384.0)
    set gg_rct_Reg_Sel_Se__or_del_foso=Rect(5568.0, 64.0, 5728.0, 352.0)
    set gg_rct_Reg_Sel_Maestro_de_las_Espadas=Rect(5312.0, - 160.0, 5568.0, 64.0)
    set gg_rct_Reg_Sel_Vidente=Rect(5248.0, - 416.0, 5536.0, - 256.0)
    set gg_rct_Reg_Sel_Jefe_Tauren=Rect(5280.0, - 704.0, 5568.0, - 544.0)
    set gg_rct_Reg_Sel_Cazador_de_sombras=Rect(5280.0, - 992.0, 5568.0, - 800.0)
    set gg_rct_Reg_Sel_Grom_Hellscream=Rect(5312.0, - 1344.0, 5600.0, - 1088.0)
    set gg_rct_Reg_Sel_Sylvanas_Orco=Rect(5344.0, - 1664.0, 5664.0, - 1472.0)
    set gg_rct_Reg_Sel_Bruja_de_mar_naga=Rect(5504.0, - 1952.0, 5728.0, - 1760.0)
    set gg_rct_Castillo_Hum=Rect(- 4320.0, - 480.0, - 3872.0, - 64.0)
    set gg_rct_Castillo_Orc=Rect(3648.0, - 480.0, 4064.0, - 32.0)
endfunction

//***************************************************************************
//*
//*  Custom Script Code
//*
//***************************************************************************
// Map deprotected by X-deprotect (version 2006-10-02) by zibada
// http://dimon.xgm.ru/xdep/
// Visit our modmaking community at http://xgm.ru/


//***************************************************************************
//*
//*  Triggers
//*
//***************************************************************************

//===========================================================================
// Trigger: IA_Brain_Macro
//===========================================================================
//TESH.scrollpos=112
//TESH.alwaysfold=0
// Trigger: IA_Logic_Laning
//===========================================================================
//TESH.scrollpos=180
//TESH.alwaysfold=0
// Trigger: IA_Data
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0
// Trigger: IA_Core
//===========================================================================
//TESH.scrollpos=30
//TESH.alwaysfold=0
// Trigger: IA_Utils
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0
// Trigger: IA_Cerebro_Loop
//
// Latido DEL BOT: Este detonador se ejecuta cada 1.00s para evaluar el estado de los héroes de la IA.
// LÓGICA DE RECUPERACIÓN: Si un héroe está vivo pero su orden actual es 'stop' (detenido), se asume que acaba de revivir o quedó inactivo (idle). El sistema fuerza inmediatamente un cambio de estado a 'ATTACK' y le ordena moverse a una línea aleatoria (Split Push) para mantener el flujo de juego constante.
//===========================================================================
function Trig_IA_Cerebro_Loop_Func001Func001Func002001002 takes nothing returns boolean
    return ( IsUnitType(GetFilterUnit(), UNIT_TYPE_HERO) == true )
endfunction

function Trig_IA_Cerebro_Loop_Func001Func001Func002Func001Func002002003001 takes nothing returns boolean
    return ( IsPlayerEnemy(GetOwningPlayer(GetFilterUnit()), GetOwningPlayer(GetEnumUnit())) == true )
endfunction

function Trig_IA_Cerebro_Loop_Func001Func001Func002Func001Func002002003002 takes nothing returns boolean
    return ( IsUnitType(GetFilterUnit(), UNIT_TYPE_HERO) == true )
endfunction

function Trig_IA_Cerebro_Loop_Func001Func001Func002Func001Func002002003 takes nothing returns boolean
    return GetBooleanAnd((IsPlayerEnemy(GetOwningPlayer(GetFilterUnit()), GetOwningPlayer(GetEnumUnit())) == true), (IsUnitType(GetFilterUnit(), UNIT_TYPE_HERO) == true)) // INLINED!!
endfunction

function Trig_IA_Cerebro_Loop_Func001Func001Func002Func001Func006Func001Func002C takes nothing returns boolean
    if ( not ( GetRandomInt(1, 2) == 1 ) ) then
        return false
    endif
    return true
endfunction

function Trig_IA_Cerebro_Loop_Func001Func001Func002Func001Func006Func001Func004C takes nothing returns boolean
    if ( ( GetUnitCurrentOrder(GetEnumUnit()) == String2OrderIdBJ("stop") ) ) then
        return true
    endif
    if ( ( OrderId2StringBJ(GetUnitCurrentOrder(GetEnumUnit())) == "" ) ) then
        return true
    endif
    return false
endfunction

function Trig_IA_Cerebro_Loop_Func001Func001Func002Func001Func006Func001C takes nothing returns boolean
    if ( not ( GetUnitLifePercent(GetEnumUnit()) >= 82.00 ) ) then
        return false
    endif
    if ( not Trig_IA_Cerebro_Loop_Func001Func001Func002Func001Func006Func001Func004C() ) then
        return false
    endif
    return true
endfunction

function Trig_IA_Cerebro_Loop_Func001Func001Func002Func001Func006Func003C takes nothing returns boolean
    if ( not ( GetConvertedPlayerId(GetEnumPlayer()) <= 5 ) ) then
        return false
    endif
    return true
endfunction

function Trig_IA_Cerebro_Loop_Func001Func001Func002Func001Func006Func004C takes nothing returns boolean
    if ( ( GetUnitLifePercent(GetEnumUnit()) <= 38.00 ) ) then
        return true
    endif
    if ( ( udg_IA_Amenaza >= 3 ) ) then
        return true
    endif
    return false
endfunction

function Trig_IA_Cerebro_Loop_Func001Func001Func002Func001Func006C takes nothing returns boolean
    if ( not Trig_IA_Cerebro_Loop_Func001Func001Func002Func001Func006Func004C() ) then
        return false
    endif
    return true
endfunction

function Trig_IA_Cerebro_Loop_Func001Func001Func002Func001C takes nothing returns boolean
    if ( not ( IsUnitAliveBJ(GetEnumUnit()) == true ) ) then
        return false
    endif
    return true
endfunction

function Trig_IA_Cerebro_Loop_Func001Func001Func002A takes nothing returns nothing
    if ( Trig_IA_Cerebro_Loop_Func001Func001Func002Func001C() ) then
        set udg_Temp_Punto=GetUnitLoc(GetEnumUnit())
        set udg_Temp_Grupo=GetUnitsInRangeOfLocMatching(800.00, udg_Temp_Punto, Condition(function Trig_IA_Cerebro_Loop_Func001Func001Func002Func001Func002002003))
        set udg_IA_Amenaza=CountUnitsInGroup(udg_Temp_Grupo)
        call RemoveLocation(udg_Temp_Punto)
        call DestroyGroup(udg_Temp_Grupo)
        if ( Trig_IA_Cerebro_Loop_Func001Func001Func002Func001Func006C() ) then
            set udg_IA_Estado[GetConvertedPlayerId(udg_IA_Bot_Actual)]="RETREAT"
            if ( Trig_IA_Cerebro_Loop_Func001Func001Func002Func001Func006Func003C() ) then
                call IssuePointOrderLocBJ(GetEnumUnit(), "move", GetRectCenter(gg_rct_Base_Hum_Top))
            else
                call IssuePointOrderLocBJ(GetEnumUnit(), "move", GetRectCenter(gg_rct_Base_Orc_Bot))
            endif
        else
            if ( Trig_IA_Cerebro_Loop_Func001Func001Func002Func001Func006Func001C() ) then
                set udg_IA_Estado[GetConvertedPlayerId(udg_IA_Bot_Actual)]="ATTACK"
                if ( Trig_IA_Cerebro_Loop_Func001Func001Func002Func001Func006Func001Func002C() ) then
                    call IssuePointOrderLocBJ(GetEnumUnit(), "attack", GetRectCenter(gg_rct_Linea_Arriba))
                else
                    call IssuePointOrderLocBJ(GetEnumUnit(), "attack", GetRectCenter(gg_rct_Linea_Abajo))
                endif
            else
            endif
        endif
    else
    endif
endfunction

function Trig_IA_Cerebro_Loop_Func001Func001C takes nothing returns boolean
    if ( not ( GetPlayerController(GetEnumPlayer()) == MAP_CONTROL_COMPUTER ) ) then
        return false
    endif
    return true
endfunction

function Trig_IA_Cerebro_Loop_Func001A takes nothing returns nothing
    if ( Trig_IA_Cerebro_Loop_Func001Func001C() ) then
        set udg_IA_Bot_Actual=GetEnumPlayer()
        call ForGroupBJ(GetUnitsOfPlayerMatching(udg_IA_Bot_Actual, Condition(function Trig_IA_Cerebro_Loop_Func001Func001Func002001002)), function Trig_IA_Cerebro_Loop_Func001Func001Func002A)
    else
    endif
endfunction

function Trig_IA_Cerebro_Loop_Actions takes nothing returns nothing
    call ForForce(GetPlayersAll(), function Trig_IA_Cerebro_Loop_Func001A)
endfunction

//===========================================================================
function InitTrig_IA_Cerebro_Loop takes nothing returns nothing
    set gg_trg_IA_Cerebro_Loop=CreateTrigger()
    call DisableTrigger(gg_trg_IA_Cerebro_Loop)
    call TriggerRegisterTimerEventPeriodic(gg_trg_IA_Cerebro_Loop, 1.00)
    call TriggerAddAction(gg_trg_IA_Cerebro_Loop, function Trig_IA_Cerebro_Loop_Actions)
endfunction

//===========================================================================
// Trigger: IA_Arrancar
//
// Este trigger quita el control compartido,  manda a los héroes a las líneas y activa su cerebro
//===========================================================================
function Trig_IA_Arrancar_Func004Func001Func002A takes nothing returns nothing
    call SetPlayerAllianceBJ(udg_IA_Bot_Actual, ALLIANCE_SHARED_CONTROL, false, GetEnumPlayer())
endfunction

function Trig_IA_Arrancar_Func004Func001C takes nothing returns boolean
    if ( not ( GetPlayerController(GetEnumPlayer()) == MAP_CONTROL_COMPUTER ) ) then
        return false
    endif
    return true
endfunction

function Trig_IA_Arrancar_Func004A takes nothing returns nothing
    if ( Trig_IA_Arrancar_Func004Func001C() ) then
        set udg_IA_Bot_Actual=GetEnumPlayer()
        call ForForce(GetPlayersAllies(udg_IA_Bot_Actual), function Trig_IA_Arrancar_Func004Func001Func002A)
    else
    endif
endfunction

function Trig_IA_Arrancar_Actions takes nothing returns nothing
    call DestroyTimerDialogBJ(udg_IA_Ventana_Tiempo)
    call PlaySoundBJ(gg_snd_ClanInvitation)
    call DisplayTimedTextToForce(GetPlayersAll(), 5.00, "TRIGSTR_3796")
    call ForForce(GetPlayersAll(), function Trig_IA_Arrancar_Func004A)
    call IACore_InitializeBots()
endfunction

//===========================================================================
function InitTrig_IA_Arrancar takes nothing returns nothing
    set gg_trg_IA_Arrancar=CreateTrigger()
    call TriggerRegisterTimerExpireEventBJ(gg_trg_IA_Arrancar, udg_IA_Temporizador)
    call TriggerAddAction(gg_trg_IA_Arrancar, function Trig_IA_Arrancar_Actions)
endfunction

//===========================================================================
// Trigger: IA_Permisos
//
// Detecta a los bots y  permite que los jugadores seleccionen los héroes por los bots durante el primer minuto.
//===========================================================================
function Trig_IA_Permisos_Func007Func001Func001Func002A takes nothing returns nothing
    call SetPlayerAllianceBJ(udg_IA_Bot_Actual, ALLIANCE_SHARED_CONTROL, true, GetEnumPlayer())
endfunction

function Trig_IA_Permisos_Func007Func001Func001C takes nothing returns boolean
    if ( not ( IsPlayerInForce(GetEnumPlayer(), udg_Grupo_Humanos) == true ) ) then
        return false
    endif
    if ( not ( udg_Config_Modo_Humanos == 1 ) ) then
        return false
    endif
    return true
endfunction

function Trig_IA_Permisos_Func007Func001Func002Func002A takes nothing returns nothing
    call SetPlayerAllianceBJ(udg_IA_Bot_Actual, ALLIANCE_SHARED_CONTROL, true, GetEnumPlayer())
endfunction

function Trig_IA_Permisos_Func007Func001Func002C takes nothing returns boolean
    if ( not ( IsPlayerInForce(GetEnumPlayer(), udg_Grupo_Orcos) == true ) ) then
        return false
    endif
    if ( not ( udg_Config_Modo_Orcos == 1 ) ) then
        return false
    endif
    return true
endfunction

function Trig_IA_Permisos_Func007Func001C takes nothing returns boolean
    if ( not ( GetPlayerController(GetEnumPlayer()) == MAP_CONTROL_COMPUTER ) ) then
        return false
    endif
    return true
endfunction

function Trig_IA_Permisos_Func007A takes nothing returns nothing
    if ( Trig_IA_Permisos_Func007Func001C() ) then
        if ( Trig_IA_Permisos_Func007Func001Func001C() ) then
            set udg_IA_Bot_Actual=GetEnumPlayer()
            call ForForce(GetPlayersAllies(udg_IA_Bot_Actual), function Trig_IA_Permisos_Func007Func001Func001Func002A)
        else
        endif
        if ( Trig_IA_Permisos_Func007Func001Func002C() ) then
            set udg_IA_Bot_Actual=GetEnumPlayer()
            call ForForce(GetPlayersAllies(udg_IA_Bot_Actual), function Trig_IA_Permisos_Func007Func001Func002Func002A)
        else
        endif
    else
    endif
endfunction

function Trig_IA_Permisos_Actions takes nothing returns nothing
    call StartTimerBJ(udg_IA_Temporizador, false, 60.00)
    call CreateTimerDialogBJ(udg_IA_Temporizador, "TRIGSTR_3711")
    set udg_IA_Ventana_Tiempo=GetLastCreatedTimerDialogBJ()
    call TimerDialogDisplayBJ(true, udg_IA_Ventana_Tiempo)
    call DisplayTextToForce(GetPlayersAll(), "TRIGSTR_3712")
    call DisplayTimedTextToForce(GetPlayersAll(), 45.00, "TRIGSTR_3783")
    call ForForce(GetPlayersAll(), function Trig_IA_Permisos_Func007A)
endfunction

//===========================================================================
function InitTrig_IA_Permisos takes nothing returns nothing
    set gg_trg_IA_Permisos=CreateTrigger()
    call TriggerAddAction(gg_trg_IA_Permisos, function Trig_IA_Permisos_Actions)
endfunction

//===========================================================================
// Trigger: Core_Indice_Heroes
//===========================================================================
function Trig_Core_Indice_Heroes_Actions takes nothing returns nothing
    set udg_Config_Total_Heroes[1]=20
    set udg_Config_Total_Heroes[2]=19
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
    set udg_Array_Heroes_Humanos[19]='H00Y'
    set udg_Array_Heroes_Humanos[20]='H00G'
    set udg_Array_Heroes_Orcos[1]='Obla'
    set udg_Array_Heroes_Orcos[2]='Ofar'
    set udg_Array_Heroes_Orcos[3]='Otch'
    set udg_Array_Heroes_Orcos[4]='Oshd'
    set udg_Array_Heroes_Orcos[5]='Udea'
    set udg_Array_Heroes_Orcos[6]='Ulic'
    set udg_Array_Heroes_Orcos[7]='Udre'
    set udg_Array_Heroes_Orcos[8]='Ucrl'
    set udg_Array_Heroes_Orcos[9]='Nngs'
    set udg_Array_Heroes_Orcos[10]='Nbst'
    set udg_Array_Heroes_Orcos[11]='Nfir'
    set udg_Array_Heroes_Orcos[12]='Nplh'
    set udg_Array_Heroes_Orcos[13]='Nman'
    set udg_Array_Heroes_Orcos[14]='Ogrh'
    set udg_Array_Heroes_Orcos[15]='Usyl'
    set udg_Array_Heroes_Orcos[16]='H00P'
    set udg_Array_Heroes_Orcos[17]='H00V'
    set udg_Array_Heroes_Orcos[18]='H00K'
    set udg_Array_Heroes_Orcos[19]='N020'
endfunction

//===========================================================================
function InitTrig_Core_Indice_Heroes takes nothing returns nothing
    set gg_trg_Core_Indice_Heroes=CreateTrigger()
    call TriggerAddAction(gg_trg_Core_Indice_Heroes, function Trig_Core_Indice_Heroes_Actions)
endfunction

//===========================================================================
// Trigger: Core_Logica_Random
//
// despues de 1 segundo es escojen aleatoriamente los heroes
//===========================================================================
function Trig_Core_Logica_Random_Func001Func002Func002Func008002 takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Core_Logica_Random_Func001Func002Func002C takes nothing returns boolean
    if ( not ( GetConvertedPlayerId(udg_TempPlayer) <= 5 ) ) then
        return false
    endif
    if ( not ( udg_Config_Modo_Humanos == 2 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Core_Logica_Random_Func001Func002Func003Func008002 takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Core_Logica_Random_Func001Func002Func003C takes nothing returns boolean
    if ( not ( GetConvertedPlayerId(udg_TempPlayer) >= 6 ) ) then
        return false
    endif
    if ( not ( udg_Config_Modo_Orcos == 2 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Core_Logica_Random_Func001Func002C takes nothing returns boolean
    if ( not ( GetConvertedPlayerId(udg_TempPlayer) <= 10 ) ) then
        return false
    endif
    if ( not ( GetPlayerSlotState(udg_TempPlayer) == PLAYER_SLOT_STATE_PLAYING ) ) then
        return false
    endif
    return true
endfunction

function Trig_Core_Logica_Random_Func001A takes nothing returns nothing
    set udg_TempPlayer=GetEnumPlayer()
    if ( Trig_Core_Logica_Random_Func001Func002C() ) then
        if ( Trig_Core_Logica_Random_Func001Func002Func002C() ) then
            set udg_Temp_Int_Random=GetRandomInt(1, udg_Config_Total_Heroes[1])
            call CreateNUnitsAtLoc(1, udg_Array_Heroes_Humanos[udg_Temp_Int_Random], udg_TempPlayer, GetPlayerStartLocationLoc(udg_TempPlayer), bj_UNIT_FACING)
            call AddSpecialEffectTargetUnitBJ("origin", GetLastCreatedUnit(), "Abilities\\Spells\\Human\\MassTeleport\\MassTeleportTarget.mdl")
            call DestroyEffectBJ(GetLastCreatedEffectBJ())
            call SelectUnitForPlayerSingle(GetLastCreatedUnit(), udg_TempPlayer)
            set udg_Array_Heroes_Humanos[udg_Temp_Int_Random]=udg_Array_Heroes_Humanos[udg_Config_Total_Heroes[1]]
            set udg_Config_Total_Heroes[1]=( udg_Config_Total_Heroes[1] - 1 )
            call ForGroupBJ(GetUnitsOfPlayerAndTypeId(udg_TempPlayer, 'ewsp'), function Trig_Core_Logica_Random_Func001Func002Func002Func008002)
        else
        endif
        if ( Trig_Core_Logica_Random_Func001Func002Func003C() ) then
            set udg_Temp_Int_Random=GetRandomInt(1, udg_Config_Total_Heroes[2])
            call CreateNUnitsAtLoc(1, udg_Array_Heroes_Orcos[udg_Temp_Int_Random], udg_TempPlayer, GetPlayerStartLocationLoc(udg_TempPlayer), bj_UNIT_FACING)
            call AddSpecialEffectTargetUnitBJ("origin", GetLastCreatedUnit(), "Abilities\\Spells\\Human\\MassTeleport\\MassTeleportTarget.mdl")
            call DestroyEffectBJ(GetLastCreatedEffectBJ())
            call SelectUnitForPlayerSingle(GetLastCreatedUnit(), udg_TempPlayer)
            set udg_Array_Heroes_Orcos[udg_Temp_Int_Random]=udg_Array_Heroes_Orcos[udg_Config_Total_Heroes[2]]
            set udg_Config_Total_Heroes[2]=( udg_Config_Total_Heroes[2] - 1 )
            call ForGroupBJ(GetUnitsOfPlayerAndTypeId(udg_TempPlayer, 'e006'), function Trig_Core_Logica_Random_Func001Func002Func003Func008002)
        else
        endif
    else
    endif
endfunction

function Trig_Core_Logica_Random_Func002Func001C takes nothing returns boolean
    if ( not ( udg_Config_Modo_Humanos == 2 ) ) then
        return false
    endif
    if ( not ( udg_Config_Modo_Orcos == 2 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Core_Logica_Random_Func002C takes nothing returns boolean
    if ( not ( udg_Core_HayBots == true ) ) then
        return false
    endif
    return true
endfunction

function Trig_Core_Logica_Random_Actions takes nothing returns nothing
    call ForForce(GetPlayersAll(), function Trig_Core_Logica_Random_Func001A)
    if ( Trig_Core_Logica_Random_Func002C() ) then
        if ( Trig_Core_Logica_Random_Func002Func001C() ) then
            call DisplayTextToForce(GetPlayersAll(), "TRIGSTR_3777")
            call DisplayTimedTextToForce(GetPlayersAll(), 20.00, "TRIGSTR_3784")
            call TriggerSleepAction(25.00)
            call PlaySoundBJ(gg_snd_ClanInvitation)
            call DisplayTimedTextToForce(GetPlayersAll(), 5.00, "TRIGSTR_3795")
            call IACore_InitializeBots()
        else
        endif
    else
    endif
endfunction

//===========================================================================
function InitTrig_Core_Logica_Random takes nothing returns nothing
    set gg_trg_Core_Logica_Random=CreateTrigger()
    call TriggerAddAction(gg_trg_Core_Logica_Random, function Trig_Core_Logica_Random_Actions)
endfunction

//===========================================================================
// Trigger: Core_Menu_Heroes_Click
//===========================================================================
//TESH.scrollpos=36
//TESH.alwaysfold=0
//===========================================================================
// CORE: CLICK EN MENU DE HEROES + CAMARA INTELIGENTE + ULTRA SHORT TEXT
//===========================================================================
function Trig_Core_Menu_Heroes_Click_Actions takes nothing returns nothing
    
    // --- 1. CONFIGURAR MODOS SEGUN EL BOTON ---
    if ( GetClickedButton() == udg_UI_Boton_TodosPick ) then
        set udg_Config_Modo_Humanos=1
        set udg_Config_Modo_Orcos=1
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10.0, "Modo: All Pick Seleccionado")
        
    elseif ( GetClickedButton() == udg_UI_Boton_TodosRandom ) then
        set udg_Config_Modo_Humanos=2
        set udg_Config_Modo_Orcos=2
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10.0, "Modo: All Random Seleccionado")
        
    elseif ( GetClickedButton() == udg_UI_Boton_HumPick_OrcRnd ) then
        set udg_Config_Modo_Humanos=1
        set udg_Config_Modo_Orcos=2
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10.0, "Modo: Humanos Eligen / Orcos Random")
        
    else // (Boton HumRnd_OrcPick)
        set udg_Config_Modo_Humanos=2
        set udg_Config_Modo_Orcos=1
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10.0, "Modo: Humanos Random / Orcos Eligen")
    endif

    // --- 2. EL MENSAJE "ULTRA SHORT" (TU REQUISITO) ---
    // Tal como lo pusiste en tu GUI, este mensaje sale siempre, sea Pick o Random.
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10.0, "Modo: Ultra Short activado por defecto (+100% XP).")

    // --- 3. CAMARA INTELIGENTE (LA NUEVA FUNCION) ---
    // Movemos la cámara ANTES de despausar para que el jugador ya esté enfocado al empezar.
    
    // A) CAMARA HUMANOS (Solo si eligieron Pick)
    if ( udg_Config_Modo_Humanos == 1 ) then
        // Usamos las variables de unidades Wisp detectadas en tu mapa (unit14 a unit18)
        if ( GetLocalPlayer() == Player(0) ) then
            call PanCameraToTimed(GetUnitX(udg_unit14), GetUnitY(udg_unit14), 0.0)
        elseif ( GetLocalPlayer() == Player(1) ) then
            call PanCameraToTimed(GetUnitX(udg_unit15), GetUnitY(udg_unit15), 0.0)
        elseif ( GetLocalPlayer() == Player(2) ) then
            call PanCameraToTimed(GetUnitX(udg_unit16), GetUnitY(udg_unit16), 0.0)
        elseif ( GetLocalPlayer() == Player(3) ) then
            call PanCameraToTimed(GetUnitX(udg_unit17), GetUnitY(udg_unit17), 0.0)
        elseif ( GetLocalPlayer() == Player(4) ) then
            call PanCameraToTimed(GetUnitX(udg_unit18), GetUnitY(udg_unit18), 0.0)
        endif
    endif

    // B) CAMARA ORCOS (Solo si eligieron Pick)
    if ( udg_Config_Modo_Orcos == 1 ) then
        // Usamos las variables de Wisps Orcos (unit39 a unit43)
        if ( GetLocalPlayer() == Player(5) ) then
            call PanCameraToTimed(GetUnitX(udg_unit39), GetUnitY(udg_unit39), 0.0)
        elseif ( GetLocalPlayer() == Player(6) ) then
            call PanCameraToTimed(GetUnitX(udg_unit40), GetUnitY(udg_unit40), 0.0)
        elseif ( GetLocalPlayer() == Player(7) ) then
            call PanCameraToTimed(GetUnitX(udg_unit41), GetUnitY(udg_unit41), 0.0)
        elseif ( GetLocalPlayer() == Player(8) ) then
            call PanCameraToTimed(GetUnitX(udg_unit42), GetUnitY(udg_unit42), 0.0)
        elseif ( GetLocalPlayer() == Player(9) ) then
            call PanCameraToTimed(GetUnitX(udg_unit43), GetUnitY(udg_unit43), 0.0)
        endif
    endif

    // --- 4. DESCONGELAR JUEGO ---
    // Respetamos tu orden: Despausamos antes de ejecutar la lógica pesada.
    call PauseGame(false)

    // --- 5. EJECUTAR LOGICA RANDOM ---
    // Si alguno eligió Random, corremos el sorteo.
    if ( udg_Config_Modo_Humanos == 2 or udg_Config_Modo_Orcos == 2 ) then
        call TriggerExecute(gg_trg_Core_Logica_Random)
    endif

    // --- 6. PERMISOS IA (BOTS) ---
    // Tu lógica corregida: Si hay bots Y (Humanos NO son random O Orcos NO son random)
    if ( udg_Core_HayBots ) then
        if ( udg_Config_Modo_Humanos != 2 or udg_Config_Modo_Orcos != 2 ) then
            call TriggerExecute(gg_trg_IA_Permisos)
        endif
    endif

endfunction

//===========================================================================
function InitTrig_Core_Menu_Heroes_Click takes nothing returns nothing
    set gg_trg_Core_Menu_Heroes_Click=CreateTrigger()
    call TriggerRegisterDialogEvent(gg_trg_Core_Menu_Heroes_Click, udg_UI_Ventana_Heroes)
    call TriggerAddAction(gg_trg_Core_Menu_Heroes_Click, function Trig_Core_Menu_Heroes_Click_Actions)
endfunction//===========================================================================
// Trigger: Core_Menu_Heroes
//
// muestra la segunda pantalla
// solo a MASTER
//===========================================================================
function Trig_Core_Menu_Heroes_Actions takes nothing returns nothing
    call DialogClearBJ(udg_UI_Ventana_Heroes)
    call DialogSetMessageBJ(udg_UI_Ventana_Heroes, "TRIGSTR_3721")
    call DialogAddButtonBJ(udg_UI_Ventana_Heroes, "TRIGSTR_3722")
    set udg_UI_Boton_TodosPick=GetLastCreatedButtonBJ()
    call DialogAddButtonBJ(udg_UI_Ventana_Heroes, "TRIGSTR_3723")
    set udg_UI_Boton_TodosRandom=GetLastCreatedButtonBJ()
    call DialogAddButtonBJ(udg_UI_Ventana_Heroes, "TRIGSTR_3724")
    set udg_UI_Boton_HumPick_OrcRnd=GetLastCreatedButtonBJ()
    call DialogAddButtonBJ(udg_UI_Ventana_Heroes, "TRIGSTR_3725")
    set udg_UI_Boton_HumRnd_OrcPick=GetLastCreatedButtonBJ()
    call DialogDisplayBJ(true, udg_UI_Ventana_Heroes, udg_Core_JugadorMaestro)
endfunction

//===========================================================================
function InitTrig_Core_Menu_Heroes takes nothing returns nothing
    set gg_trg_Core_Menu_Heroes=CreateTrigger()
    call TriggerAddAction(gg_trg_Core_Menu_Heroes, function Trig_Core_Menu_Heroes_Actions)
endfunction

//===========================================================================
// Trigger: Core_Mecanica_Oro
//
// Asigna cada segundo la cantidad de oro guardada en "Config_Cantidad_Oro"
//===========================================================================
function Trig_Core_Mecanica_Oro_Func001A takes nothing returns nothing
    call AdjustPlayerStateBJ(udg_Config_Cantidad_Oro, GetEnumPlayer(), PLAYER_STATE_RESOURCE_GOLD)
endfunction

function Trig_Core_Mecanica_Oro_Actions takes nothing returns nothing
    call ForForce(GetPlayersAll(), function Trig_Core_Mecanica_Oro_Func001A)
endfunction

//===========================================================================
function InitTrig_Core_Mecanica_Oro takes nothing returns nothing
    set gg_trg_Core_Mecanica_Oro=CreateTrigger()
    call TriggerRegisterTimerEventPeriodic(gg_trg_Core_Mecanica_Oro, 1.00)
    call TriggerAddAction(gg_trg_Core_Mecanica_Oro, function Trig_Core_Mecanica_Oro_Actions)
endfunction

//===========================================================================
// Trigger: Core_Menu_Click
//
// Al hacer click en la primera pantalla
// verifica en que opcion fue
// guarda en la variable "Config_Cantidad_Oro" el numero de oro correspondiente
// ejecuta el trigger "Core_Menu_Heroes"
//===========================================================================
function Trig_Core_Menu_Click_Func001Func001C takes nothing returns boolean
    if ( not ( GetClickedButtonBJ() == udg_UI_Boton_OroRapido ) ) then
        return false
    endif
    return true
endfunction

function Trig_Core_Menu_Click_Func001C takes nothing returns boolean
    if ( not ( GetClickedButtonBJ() == udg_UI_Boton_OroNormal ) ) then
        return false
    endif
    return true
endfunction

function Trig_Core_Menu_Click_Actions takes nothing returns nothing
    if ( Trig_Core_Menu_Click_Func001C() ) then
        set udg_Config_Cantidad_Oro=6
        call DisplayTimedTextToForce(GetPlayersAll(), 12.00, "TRIGSTR_3790")
    else
        if ( Trig_Core_Menu_Click_Func001Func001C() ) then
            set udg_Config_Cantidad_Oro=12
            call DisplayTimedTextToForce(GetPlayersAll(), 12.00, "TRIGSTR_3791")
        else
            set udg_Config_Cantidad_Oro=18
            call DisplayTimedTextToForce(GetPlayersAll(), 12.00, "TRIGSTR_3792")
        endif
    endif
    call TriggerExecute(gg_trg_Core_Menu_Heroes)
endfunction

//===========================================================================
function InitTrig_Core_Menu_Click takes nothing returns nothing
    set gg_trg_Core_Menu_Click=CreateTrigger()
    call TriggerRegisterDialogEventBJ(gg_trg_Core_Menu_Click, udg_UI_Ventana_General)
    call TriggerAddAction(gg_trg_Core_Menu_Click, function Trig_Core_Menu_Click_Actions)
endfunction

//===========================================================================
// Trigger: Core_Menu_Oro
//
// Al pasar 1 segundo 
// congela el juego,
// muestra la primera pantalla (ORO)
//  y solo se la muestra al MASTER
//===========================================================================
function Trig_Core_Menu_Oro_Actions takes nothing returns nothing
    call PauseGameOn()
    call DialogClearBJ(udg_UI_Ventana_General)
    call DialogSetMessageBJ(udg_UI_Ventana_General, "TRIGSTR_3715")
    call DialogAddButtonBJ(udg_UI_Ventana_General, "TRIGSTR_3716")
    set udg_UI_Boton_OroNormal=GetLastCreatedButtonBJ()
    call DialogAddButtonBJ(udg_UI_Ventana_General, "TRIGSTR_3717")
    set udg_UI_Boton_OroRapido=GetLastCreatedButtonBJ()
    call DialogAddButtonBJ(udg_UI_Ventana_General, "TRIGSTR_3736")
    set udg_UI_Boton_OroInsano=GetLastCreatedButtonBJ()
    call DialogDisplayBJ(true, udg_UI_Ventana_General, udg_Core_JugadorMaestro)
endfunction

//===========================================================================
function InitTrig_Core_Menu_Oro takes nothing returns nothing
    set gg_trg_Core_Menu_Oro=CreateTrigger()
    call TriggerRegisterTimerEventSingle(gg_trg_Core_Menu_Oro, 1.00)
    call TriggerAddAction(gg_trg_Core_Menu_Oro, function Trig_Core_Menu_Oro_Actions)
endfunction

//===========================================================================
// Trigger: Core_DetectarHost
//
// Función: Escanea los 10 slots de jugadores al iniciar el mapa para configurar la partida automáticamente.
// - Asignación de Equipos:
//  (Slots 1-5 -> Grupo Humanos)
//  y (Slots 6-10 -> Grupo Orcos)
// - Detección de IA: Verifica si hay Bots presentes para activar la lógica artificial (Core_HayBots).
// - Designación del Host (Master): Identifica al primer jugador humano real y le entrega el control de los menús de configuración
// - Configuración Global: Aplica el handicap de experiencia (Modo Ultra Short) a todos los jugadores activos.
//===========================================================================
function Trig_Core_DetectarHost_Func004Func002Func001C takes nothing returns boolean
    if ( not ( GetForLoopIndexA() <= 5 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Core_DetectarHost_Func004Func002Func002C takes nothing returns boolean
    if ( not ( GetPlayerController(udg_TempPlayer) == MAP_CONTROL_COMPUTER ) ) then
        return false
    endif
    return true
endfunction

function Trig_Core_DetectarHost_Func004Func002Func003C takes nothing returns boolean
    if ( not ( GetPlayerController(udg_TempPlayer) == MAP_CONTROL_USER ) ) then
        return false
    endif
    if ( not ( udg_Temp_MasterEncontrado == false ) ) then
        return false
    endif
    return true
endfunction

function Trig_Core_DetectarHost_Func004Func002C takes nothing returns boolean
    if ( not ( GetPlayerSlotState(udg_TempPlayer) == PLAYER_SLOT_STATE_PLAYING ) ) then
        return false
    endif
    return true
endfunction

function Trig_Core_DetectarHost_Func005C takes nothing returns boolean
    if ( not ( udg_Core_HayBots == true ) ) then
        return false
    endif
    return true
endfunction

function Trig_Core_DetectarHost_Actions takes nothing returns nothing
    set udg_Core_HayBots=false
    set udg_Temp_MasterEncontrado=false
    set udg_Core_JugadorMaestro=Player(0)
    set bj_forLoopAIndex=1
    set bj_forLoopAIndexEnd=10
    loop
        exitwhen bj_forLoopAIndex > bj_forLoopAIndexEnd
        set udg_TempPlayer=ConvertedPlayer(GetForLoopIndexA())
        if ( Trig_Core_DetectarHost_Func004Func002C() ) then
            if ( Trig_Core_DetectarHost_Func004Func002Func001C() ) then
                call ForceAddPlayerSimple(udg_TempPlayer, udg_Grupo_Humanos)
            else
                call ForceAddPlayerSimple(udg_TempPlayer, udg_Grupo_Orcos)
            endif
            if ( Trig_Core_DetectarHost_Func004Func002Func002C() ) then
                set udg_Core_HayBots=true
            else
            endif
            if ( Trig_Core_DetectarHost_Func004Func002Func003C() ) then
                set udg_Core_JugadorMaestro=udg_TempPlayer
                set udg_Temp_MasterEncontrado=true
                call DisplayTimedTextToForce(GetPlayersAll(), 5.00, ( ( "|cffFFCC00" + GetPlayerName(udg_Core_JugadorMaestro) ) + "|r es el MASTER de la partida." ))
            else
            endif
            call SetPlayerHandicapXP(udg_TempPlayer, 2.00)
        else
        endif
        set bj_forLoopAIndex=bj_forLoopAIndex + 1
    endloop
    if ( Trig_Core_DetectarHost_Func005C() ) then
        call DisplayTimedTextToForce(GetPlayersAll(), 5.00, "TRIGSTR_3804")
    else
        call DisplayTimedTextToForce(GetPlayersAll(), 5.00, "TRIGSTR_3805")
    endif
endfunction

//===========================================================================
function InitTrig_Core_DetectarHost takes nothing returns nothing
    set gg_trg_Core_DetectarHost=CreateTrigger()
    call TriggerRegisterTimerEventSingle(gg_trg_Core_DetectarHost, 0.05)
    call TriggerAddAction(gg_trg_Core_DetectarHost, function Trig_Core_DetectarHost_Actions)
endfunction

//===========================================================================
// Trigger: Pick_01_Guardian_del_Bosque
//===========================================================================
function Trig_Pick_01_Guardian_del_Bosque_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_01_Guardian_del_Bosque_Conditions takes nothing returns boolean
    if ( not Trig_Pick_01_Guardian_del_Bosque_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_01_Guardian_del_Bosque_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_01_Guardian_del_Bosque_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'Ekee', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Guardi__n_del_Bosque)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Guardi__n_del_Bosque)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_01_Guardian_del_Bosque_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_01_Guardian_del_Bosque takes nothing returns nothing
    set gg_trg_Pick_01_Guardian_del_Bosque=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_01_Guardian_del_Bosque, gg_rct_Reg_Sel_Guardi__n_del_Bosque)
    call TriggerAddCondition(gg_trg_Pick_01_Guardian_del_Bosque, Condition(function Trig_Pick_01_Guardian_del_Bosque_Conditions))
    call TriggerAddAction(gg_trg_Pick_01_Guardian_del_Bosque, function Trig_Pick_01_Guardian_del_Bosque_Actions)
endfunction

//===========================================================================
// Trigger: Pick_02_Sacerdotisa_de_la_Luna
//===========================================================================
function Trig_Pick_02_Sacerdotisa_de_la_Luna_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_02_Sacerdotisa_de_la_Luna_Conditions takes nothing returns boolean
    if ( not Trig_Pick_02_Sacerdotisa_de_la_Luna_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_02_Sacerdotisa_de_la_Luna_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_02_Sacerdotisa_de_la_Luna_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'Emoo', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Sacerdotisa_de_la_Luna)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Sacerdotisa_de_la_Luna)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_02_Sacerdotisa_de_la_Luna_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_02_Sacerdotisa_de_la_Luna takes nothing returns nothing
    set gg_trg_Pick_02_Sacerdotisa_de_la_Luna=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_02_Sacerdotisa_de_la_Luna, gg_rct_Reg_Sel_Sacerdotisa_de_la_Luna)
    call TriggerAddCondition(gg_trg_Pick_02_Sacerdotisa_de_la_Luna, Condition(function Trig_Pick_02_Sacerdotisa_de_la_Luna_Conditions))
    call TriggerAddAction(gg_trg_Pick_02_Sacerdotisa_de_la_Luna, function Trig_Pick_02_Sacerdotisa_de_la_Luna_Actions)
endfunction

//===========================================================================
// Trigger: Pick_03_Cazador_de_Demonios
//===========================================================================
function Trig_Pick_03_Cazador_de_Demonios_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_03_Cazador_de_Demonios_Conditions takes nothing returns boolean
    if ( not Trig_Pick_03_Cazador_de_Demonios_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_03_Cazador_de_Demonios_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_03_Cazador_de_Demonios_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'Edem', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Cazador_de_Demonios)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Cazador_de_Demonios)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_03_Cazador_de_Demonios_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_03_Cazador_de_Demonios takes nothing returns nothing
    set gg_trg_Pick_03_Cazador_de_Demonios=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_03_Cazador_de_Demonios, gg_rct_Reg_Sel_Cazador_de_Demonios)
    call TriggerAddCondition(gg_trg_Pick_03_Cazador_de_Demonios, Condition(function Trig_Pick_03_Cazador_de_Demonios_Conditions))
    call TriggerAddAction(gg_trg_Pick_03_Cazador_de_Demonios, function Trig_Pick_03_Cazador_de_Demonios_Actions)
endfunction

//===========================================================================
// Trigger: Pick_04_Guardiana
//===========================================================================
function Trig_Pick_04_Guardiana_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_04_Guardiana_Conditions takes nothing returns boolean
    if ( not Trig_Pick_04_Guardiana_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_04_Guardiana_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_04_Guardiana_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'Ewar', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Guardiana)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Guardiana)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_04_Guardiana_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_04_Guardiana takes nothing returns nothing
    set gg_trg_Pick_04_Guardiana=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_04_Guardiana, gg_rct_Reg_Sel_Guardiana)
    call TriggerAddCondition(gg_trg_Pick_04_Guardiana, Condition(function Trig_Pick_04_Guardiana_Conditions))
    call TriggerAddAction(gg_trg_Pick_04_Guardiana, function Trig_Pick_04_Guardiana_Actions)
endfunction

//===========================================================================
// Trigger: Pick_05_Paladin
//===========================================================================
function Trig_Pick_05_Paladin_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_05_Paladin_Conditions takes nothing returns boolean
    if ( not Trig_Pick_05_Paladin_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_05_Paladin_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_05_Paladin_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'Hpal', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Paladin)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Paladin)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_05_Paladin_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_05_Paladin takes nothing returns nothing
    set gg_trg_Pick_05_Paladin=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_05_Paladin, gg_rct_Reg_Sel_Paladin)
    call TriggerAddCondition(gg_trg_Pick_05_Paladin, Condition(function Trig_Pick_05_Paladin_Conditions))
    call TriggerAddAction(gg_trg_Pick_05_Paladin, function Trig_Pick_05_Paladin_Actions)
endfunction

//===========================================================================
// Trigger: Pick_06_Archimago
//===========================================================================
function Trig_Pick_06_Archimago_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_06_Archimago_Conditions takes nothing returns boolean
    if ( not Trig_Pick_06_Archimago_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_06_Archimago_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_06_Archimago_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'Hamg', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Archimago)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Archimago)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_06_Archimago_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_06_Archimago takes nothing returns nothing
    set gg_trg_Pick_06_Archimago=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_06_Archimago, gg_rct_Reg_Sel_Archimago)
    call TriggerAddCondition(gg_trg_Pick_06_Archimago, Condition(function Trig_Pick_06_Archimago_Conditions))
    call TriggerAddAction(gg_trg_Pick_06_Archimago, function Trig_Pick_06_Archimago_Actions)
endfunction

//===========================================================================
// Trigger: Pick_07_Rey_de_la_Montana
//===========================================================================
function Trig_Pick_07_Rey_de_la_Montana_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_07_Rey_de_la_Montana_Conditions takes nothing returns boolean
    if ( not Trig_Pick_07_Rey_de_la_Montana_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_07_Rey_de_la_Montana_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_07_Rey_de_la_Montana_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'Hmkg', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Rey_de_la_Monta__a)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Rey_de_la_Monta__a)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_07_Rey_de_la_Montana_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_07_Rey_de_la_Montana takes nothing returns nothing
    set gg_trg_Pick_07_Rey_de_la_Montana=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_07_Rey_de_la_Montana, gg_rct_Reg_Sel_Rey_de_la_Monta__a)
    call TriggerAddCondition(gg_trg_Pick_07_Rey_de_la_Montana, Condition(function Trig_Pick_07_Rey_de_la_Montana_Conditions))
    call TriggerAddAction(gg_trg_Pick_07_Rey_de_la_Montana, function Trig_Pick_07_Rey_de_la_Montana_Actions)
endfunction

//===========================================================================
// Trigger: Pick_08_Mago_sanguinario
//===========================================================================
function Trig_Pick_08_Mago_sanguinario_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_08_Mago_sanguinario_Conditions takes nothing returns boolean
    if ( not Trig_Pick_08_Mago_sanguinario_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_08_Mago_sanguinario_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_08_Mago_sanguinario_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'Hblm', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Mago_sanguinario)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Mago_sanguinario)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_08_Mago_sanguinario_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_08_Mago_sanguinario takes nothing returns nothing
    set gg_trg_Pick_08_Mago_sanguinario=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_08_Mago_sanguinario, gg_rct_Reg_Sel_Mago_sanguinario)
    call TriggerAddCondition(gg_trg_Pick_08_Mago_sanguinario, Condition(function Trig_Pick_08_Mago_sanguinario_Conditions))
    call TriggerAddAction(gg_trg_Pick_08_Mago_sanguinario, function Trig_Pick_08_Mago_sanguinario_Actions)
endfunction

//===========================================================================
// Trigger: Pick_09_Alquimista
//===========================================================================
function Trig_Pick_09_Alquimista_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_09_Alquimista_Conditions takes nothing returns boolean
    if ( not Trig_Pick_09_Alquimista_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_09_Alquimista_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_09_Alquimista_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'Nalc', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Alquimista)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Alquimista)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_09_Alquimista_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_09_Alquimista takes nothing returns nothing
    set gg_trg_Pick_09_Alquimista=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_09_Alquimista, gg_rct_Reg_Sel_Alquimista)
    call TriggerAddCondition(gg_trg_Pick_09_Alquimista, Condition(function Trig_Pick_09_Alquimista_Conditions))
    call TriggerAddAction(gg_trg_Pick_09_Alquimista, function Trig_Pick_09_Alquimista_Actions)
endfunction

//===========================================================================
// Trigger: Pick_10_Hojalatero
//===========================================================================
function Trig_Pick_10_Hojalatero_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_10_Hojalatero_Conditions takes nothing returns boolean
    if ( not Trig_Pick_10_Hojalatero_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_10_Hojalatero_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_10_Hojalatero_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'Ntin', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Hojalatero)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Hojalatero)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_10_Hojalatero_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_10_Hojalatero takes nothing returns nothing
    set gg_trg_Pick_10_Hojalatero=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_10_Hojalatero, gg_rct_Reg_Sel_Hojalatero)
    call TriggerAddCondition(gg_trg_Pick_10_Hojalatero, Condition(function Trig_Pick_10_Hojalatero_Conditions))
    call TriggerAddAction(gg_trg_Pick_10_Hojalatero, function Trig_Pick_10_Hojalatero_Actions)
endfunction

//===========================================================================
// Trigger: Pick_11_Alquimista_pandaren
//===========================================================================
function Trig_Pick_11_Alquimista_pandaren_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_11_Alquimista_pandaren_Conditions takes nothing returns boolean
    if ( not Trig_Pick_11_Alquimista_pandaren_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_11_Alquimista_pandaren_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_11_Alquimista_pandaren_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'Npbm', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Alquimista_pandaren)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Alquimista_pandaren)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_11_Alquimista_pandaren_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_11_Alquimista_pandaren takes nothing returns nothing
    set gg_trg_Pick_11_Alquimista_pandaren=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_11_Alquimista_pandaren, gg_rct_Reg_Sel_Alquimista_pandaren)
    call TriggerAddCondition(gg_trg_Pick_11_Alquimista_pandaren, Condition(function Trig_Pick_11_Alquimista_pandaren_Conditions))
    call TriggerAddAction(gg_trg_Pick_11_Alquimista_pandaren, function Trig_Pick_11_Alquimista_pandaren_Actions)
endfunction

//===========================================================================
// Trigger: Pick_12_Lord_Garithos
//===========================================================================
function Trig_Pick_12_Lord_Garithos_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_12_Lord_Garithos_Conditions takes nothing returns boolean
    if ( not Trig_Pick_12_Lord_Garithos_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_12_Lord_Garithos_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_12_Lord_Garithos_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'Hlgr', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Lord_Garithos)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Lord_Garithos)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_12_Lord_Garithos_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_12_Lord_Garithos takes nothing returns nothing
    set gg_trg_Pick_12_Lord_Garithos=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_12_Lord_Garithos, gg_rct_Reg_Sel_Lord_Garithos)
    call TriggerAddCondition(gg_trg_Pick_12_Lord_Garithos, Condition(function Trig_Pick_12_Lord_Garithos_Conditions))
    call TriggerAddAction(gg_trg_Pick_12_Lord_Garithos, function Trig_Pick_12_Lord_Garithos_Actions)
endfunction

//===========================================================================
// Trigger: Pick_13_SylvanasH
//===========================================================================
function Trig_Pick_13_SylvanasH_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_13_SylvanasH_Conditions takes nothing returns boolean
    if ( not Trig_Pick_13_SylvanasH_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_13_SylvanasH_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_13_SylvanasH_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'Hvwd', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Sylvanas_Humano)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Sylvanas_Humano)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_13_SylvanasH_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_13_SylvanasH takes nothing returns nothing
    set gg_trg_Pick_13_SylvanasH=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_13_SylvanasH, gg_rct_Reg_Sel_Sylvanas_Humano)
    call TriggerAddCondition(gg_trg_Pick_13_SylvanasH, Condition(function Trig_Pick_13_SylvanasH_Conditions))
    call TriggerAddAction(gg_trg_Pick_13_SylvanasH, function Trig_Pick_13_SylvanasH_Actions)
endfunction

//===========================================================================
// Trigger: Pick_14_Asesina
//===========================================================================
function Trig_Pick_14_Asesina_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_14_Asesina_Conditions takes nothing returns boolean
    if ( not Trig_Pick_14_Asesina_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_14_Asesina_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_14_Asesina_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'E005', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Asesina)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Asesina)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_14_Asesina_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_14_Asesina takes nothing returns nothing
    set gg_trg_Pick_14_Asesina=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_14_Asesina, gg_rct_Reg_Sel_Asesina)
    call TriggerAddCondition(gg_trg_Pick_14_Asesina, Condition(function Trig_Pick_14_Asesina_Conditions))
    call TriggerAddAction(gg_trg_Pick_14_Asesina, function Trig_Pick_14_Asesina_Actions)
endfunction

//===========================================================================
// Trigger: Pick_15_Goblin_Techies
//===========================================================================
function Trig_Pick_15_Goblin_Techies_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_15_Goblin_Techies_Conditions takes nothing returns boolean
    if ( not Trig_Pick_15_Goblin_Techies_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_15_Goblin_Techies_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_15_Goblin_Techies_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'H00U', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Goblin_Techies)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Goblin_Techies)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_15_Goblin_Techies_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_15_Goblin_Techies takes nothing returns nothing
    set gg_trg_Pick_15_Goblin_Techies=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_15_Goblin_Techies, gg_rct_Reg_Sel_Goblin_Techies)
    call TriggerAddCondition(gg_trg_Pick_15_Goblin_Techies, Condition(function Trig_Pick_15_Goblin_Techies_Conditions))
    call TriggerAddAction(gg_trg_Pick_15_Goblin_Techies, function Trig_Pick_15_Goblin_Techies_Actions)
endfunction

//===========================================================================
// Trigger: Pick_16_Sniper
//===========================================================================
function Trig_Pick_16_Sniper_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_16_Sniper_Conditions takes nothing returns boolean
    if ( not Trig_Pick_16_Sniper_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_16_Sniper_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_16_Sniper_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'H00R', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Sniper)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Sniper)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_16_Sniper_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_16_Sniper takes nothing returns nothing
    set gg_trg_Pick_16_Sniper=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_16_Sniper, gg_rct_Reg_Sel_Sniper)
    call TriggerAddCondition(gg_trg_Pick_16_Sniper, Condition(function Trig_Pick_16_Sniper_Conditions))
    call TriggerAddAction(gg_trg_Pick_16_Sniper, function Trig_Pick_16_Sniper_Actions)
endfunction

//===========================================================================
// Trigger: Pick_17_Bandido
//===========================================================================
function Trig_Pick_17_Bandido_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_17_Bandido_Conditions takes nothing returns boolean
    if ( not Trig_Pick_17_Bandido_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_17_Bandido_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_17_Bandido_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'H00Q', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Bandido)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Bandido)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_17_Bandido_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_17_Bandido takes nothing returns nothing
    set gg_trg_Pick_17_Bandido=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_17_Bandido, gg_rct_Reg_Sel_Bandido)
    call TriggerAddCondition(gg_trg_Pick_17_Bandido, Condition(function Trig_Pick_17_Bandido_Conditions))
    call TriggerAddAction(gg_trg_Pick_17_Bandido, function Trig_Pick_17_Bandido_Actions)
endfunction

//===========================================================================
// Trigger: Pick_18_Magnadefender
//===========================================================================
function Trig_Pick_18_Magnadefender_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_18_Magnadefender_Conditions takes nothing returns boolean
    if ( not Trig_Pick_18_Magnadefender_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_18_Magnadefender_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_18_Magnadefender_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'O00B', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Magnadefender)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Magnadefender)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_18_Magnadefender_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_18_Magnadefender takes nothing returns nothing
    set gg_trg_Pick_18_Magnadefender=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_18_Magnadefender, gg_rct_Reg_Sel_Magnadefender)
    call TriggerAddCondition(gg_trg_Pick_18_Magnadefender, Condition(function Trig_Pick_18_Magnadefender_Conditions))
    call TriggerAddAction(gg_trg_Pick_18_Magnadefender, function Trig_Pick_18_Magnadefender_Actions)
endfunction

//===========================================================================
// Trigger: Pick_19_CoCo
//===========================================================================
function Trig_Pick_19_CoCo_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_19_CoCo_Conditions takes nothing returns boolean
    if ( not Trig_Pick_19_CoCo_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_19_CoCo_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_19_CoCo_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'H00Y', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_CoCo)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_CoCo)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_19_CoCo_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_19_CoCo takes nothing returns nothing
    set gg_trg_Pick_19_CoCo=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_19_CoCo, gg_rct_Reg_Sel_CoCo)
    call TriggerAddCondition(gg_trg_Pick_19_CoCo, Condition(function Trig_Pick_19_CoCo_Conditions))
    call TriggerAddAction(gg_trg_Pick_19_CoCo, function Trig_Pick_19_CoCo_Actions)
endfunction

//===========================================================================
// Trigger: Pick_20_DarthRemar
//===========================================================================
function Trig_Pick_20_DarthRemar_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_20_DarthRemar_Conditions takes nothing returns boolean
    if ( not Trig_Pick_20_DarthRemar_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_20_DarthRemar_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_20_DarthRemar_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'H00G', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_DarthRemar)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_DarthRemar)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_20_DarthRemar_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_20_DarthRemar takes nothing returns nothing
    set gg_trg_Pick_20_DarthRemar=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_20_DarthRemar, gg_rct_Reg_Sel_DarthRemar)
    call TriggerAddCondition(gg_trg_Pick_20_DarthRemar, Condition(function Trig_Pick_20_DarthRemar_Conditions))
    call TriggerAddAction(gg_trg_Pick_20_DarthRemar, function Trig_Pick_20_DarthRemar_Actions)
endfunction

//===========================================================================
// Trigger: Pick_21_Maestro_de_las_Espadas
//===========================================================================
function Trig_Pick_21_Maestro_de_las_Espadas_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_21_Maestro_de_las_Espadas_Conditions takes nothing returns boolean
    if ( not Trig_Pick_21_Maestro_de_las_Espadas_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_21_Maestro_de_las_Espadas_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_21_Maestro_de_las_Espadas_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'Obla', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Maestro_de_las_Espadas)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Maestro_de_las_Espadas)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_21_Maestro_de_las_Espadas_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_21_Maestro_de_las_Espadas takes nothing returns nothing
    set gg_trg_Pick_21_Maestro_de_las_Espadas=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_21_Maestro_de_las_Espadas, gg_rct_Reg_Sel_Maestro_de_las_Espadas)
    call TriggerAddCondition(gg_trg_Pick_21_Maestro_de_las_Espadas, Condition(function Trig_Pick_21_Maestro_de_las_Espadas_Conditions))
    call TriggerAddAction(gg_trg_Pick_21_Maestro_de_las_Espadas, function Trig_Pick_21_Maestro_de_las_Espadas_Actions)
endfunction

//===========================================================================
// Trigger: Pick_22_Vidente
//===========================================================================
function Trig_Pick_22_Vidente_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_22_Vidente_Conditions takes nothing returns boolean
    if ( not Trig_Pick_22_Vidente_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_22_Vidente_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_22_Vidente_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'Ofar', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Vidente)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Vidente)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_22_Vidente_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_22_Vidente takes nothing returns nothing
    set gg_trg_Pick_22_Vidente=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_22_Vidente, gg_rct_Reg_Sel_Vidente)
    call TriggerAddCondition(gg_trg_Pick_22_Vidente, Condition(function Trig_Pick_22_Vidente_Conditions))
    call TriggerAddAction(gg_trg_Pick_22_Vidente, function Trig_Pick_22_Vidente_Actions)
endfunction

//===========================================================================
// Trigger: Pick_23_Jefe_Tauren
//===========================================================================
function Trig_Pick_23_Jefe_Tauren_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_23_Jefe_Tauren_Conditions takes nothing returns boolean
    if ( not Trig_Pick_23_Jefe_Tauren_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_23_Jefe_Tauren_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_23_Jefe_Tauren_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'Otch', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Jefe_Tauren)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Jefe_Tauren)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_23_Jefe_Tauren_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_23_Jefe_Tauren takes nothing returns nothing
    set gg_trg_Pick_23_Jefe_Tauren=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_23_Jefe_Tauren, gg_rct_Reg_Sel_Jefe_Tauren)
    call TriggerAddCondition(gg_trg_Pick_23_Jefe_Tauren, Condition(function Trig_Pick_23_Jefe_Tauren_Conditions))
    call TriggerAddAction(gg_trg_Pick_23_Jefe_Tauren, function Trig_Pick_23_Jefe_Tauren_Actions)
endfunction

//===========================================================================
// Trigger: Pick_24_Cazador_de_sombras
//===========================================================================
function Trig_Pick_24_Cazador_de_sombras_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_24_Cazador_de_sombras_Conditions takes nothing returns boolean
    if ( not Trig_Pick_24_Cazador_de_sombras_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_24_Cazador_de_sombras_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_24_Cazador_de_sombras_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'Oshd', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Cazador_de_sombras)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Cazador_de_sombras)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_24_Cazador_de_sombras_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_24_Cazador_de_sombras takes nothing returns nothing
    set gg_trg_Pick_24_Cazador_de_sombras=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_24_Cazador_de_sombras, gg_rct_Reg_Sel_Cazador_de_sombras)
    call TriggerAddCondition(gg_trg_Pick_24_Cazador_de_sombras, Condition(function Trig_Pick_24_Cazador_de_sombras_Conditions))
    call TriggerAddAction(gg_trg_Pick_24_Cazador_de_sombras, function Trig_Pick_24_Cazador_de_sombras_Actions)
endfunction

//===========================================================================
// Trigger: Pick_25_Caballero_de_la_Muerte
//===========================================================================
function Trig_Pick_25_Caballero_de_la_Muerte_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_25_Caballero_de_la_Muerte_Conditions takes nothing returns boolean
    if ( not Trig_Pick_25_Caballero_de_la_Muerte_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_25_Caballero_de_la_Muerte_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_25_Caballero_de_la_Muerte_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'Udea', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Caballero_de_la_Muerte)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Caballero_de_la_Muerte)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_25_Caballero_de_la_Muerte_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_25_Caballero_de_la_Muerte takes nothing returns nothing
    set gg_trg_Pick_25_Caballero_de_la_Muerte=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_25_Caballero_de_la_Muerte, gg_rct_Reg_Sel_Caballero_de_la_Muerte)
    call TriggerAddCondition(gg_trg_Pick_25_Caballero_de_la_Muerte, Condition(function Trig_Pick_25_Caballero_de_la_Muerte_Conditions))
    call TriggerAddAction(gg_trg_Pick_25_Caballero_de_la_Muerte, function Trig_Pick_25_Caballero_de_la_Muerte_Actions)
endfunction

//===========================================================================
// Trigger: Pick_26_Lich
//===========================================================================
function Trig_Pick_26_Lich_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_26_Lich_Conditions takes nothing returns boolean
    if ( not Trig_Pick_26_Lich_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_26_Lich_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_26_Lich_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'Ulic', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Lich)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Lich)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_26_Lich_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_26_Lich takes nothing returns nothing
    set gg_trg_Pick_26_Lich=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_26_Lich, gg_rct_Reg_Sel_Lich)
    call TriggerAddCondition(gg_trg_Pick_26_Lich, Condition(function Trig_Pick_26_Lich_Conditions))
    call TriggerAddAction(gg_trg_Pick_26_Lich, function Trig_Pick_26_Lich_Actions)
endfunction

//===========================================================================
// Trigger: Pick_27_Senor_del_terror
//===========================================================================
function Trig_Pick_27_Senor_del_terror_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_27_Senor_del_terror_Conditions takes nothing returns boolean
    if ( not Trig_Pick_27_Senor_del_terror_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_27_Senor_del_terror_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_27_Senor_del_terror_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'Udre', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Se__or_del_terror)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Se__or_del_terror)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_27_Senor_del_terror_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_27_Senor_del_terror takes nothing returns nothing
    set gg_trg_Pick_27_Senor_del_terror=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_27_Senor_del_terror, gg_rct_Reg_Sel_Se__or_del_terror)
    call TriggerAddCondition(gg_trg_Pick_27_Senor_del_terror, Condition(function Trig_Pick_27_Senor_del_terror_Conditions))
    call TriggerAddAction(gg_trg_Pick_27_Senor_del_terror, function Trig_Pick_27_Senor_del_terror_Actions)
endfunction

//===========================================================================
// Trigger: Pick_28_Senor_de_la_cripta
//===========================================================================
function Trig_Pick_28_Senor_de_la_cripta_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_28_Senor_de_la_cripta_Conditions takes nothing returns boolean
    if ( not Trig_Pick_28_Senor_de_la_cripta_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_28_Senor_de_la_cripta_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_28_Senor_de_la_cripta_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'Ucrl', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Se__or_de_la_cripta)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Se__or_de_la_cripta)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_28_Senor_de_la_cripta_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_28_Senor_de_la_cripta takes nothing returns nothing
    set gg_trg_Pick_28_Senor_de_la_cripta=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_28_Senor_de_la_cripta, gg_rct_Reg_Sel_Se__or_de_la_cripta)
    call TriggerAddCondition(gg_trg_Pick_28_Senor_de_la_cripta, Condition(function Trig_Pick_28_Senor_de_la_cripta_Conditions))
    call TriggerAddAction(gg_trg_Pick_28_Senor_de_la_cripta, function Trig_Pick_28_Senor_de_la_cripta_Actions)
endfunction

//===========================================================================
// Trigger: Pick_29_Bruja_de_mar_naga
//===========================================================================
function Trig_Pick_29_Bruja_de_mar_naga_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_29_Bruja_de_mar_naga_Conditions takes nothing returns boolean
    if ( not Trig_Pick_29_Bruja_de_mar_naga_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_29_Bruja_de_mar_naga_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_29_Bruja_de_mar_naga_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'Nngs', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Bruja_de_mar_naga)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Bruja_de_mar_naga)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_29_Bruja_de_mar_naga_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_29_Bruja_de_mar_naga takes nothing returns nothing
    set gg_trg_Pick_29_Bruja_de_mar_naga=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_29_Bruja_de_mar_naga, gg_rct_Reg_Sel_Bruja_de_mar_naga)
    call TriggerAddCondition(gg_trg_Pick_29_Bruja_de_mar_naga, Condition(function Trig_Pick_29_Bruja_de_mar_naga_Conditions))
    call TriggerAddAction(gg_trg_Pick_29_Bruja_de_mar_naga, function Trig_Pick_29_Bruja_de_mar_naga_Actions)
endfunction

//===========================================================================
// Trigger: Pick_30_Senor_de_las_bestias
//===========================================================================
function Trig_Pick_30_Senor_de_las_bestias_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_30_Senor_de_las_bestias_Conditions takes nothing returns boolean
    if ( not Trig_Pick_30_Senor_de_las_bestias_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_30_Senor_de_las_bestias_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_30_Senor_de_las_bestias_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'Nbst', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Se__or_de_las_bestias)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Se__or_de_las_bestias)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_30_Senor_de_las_bestias_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_30_Senor_de_las_bestias takes nothing returns nothing
    set gg_trg_Pick_30_Senor_de_las_bestias=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_30_Senor_de_las_bestias, gg_rct_Reg_Sel_Se__or_de_las_bestias)
    call TriggerAddCondition(gg_trg_Pick_30_Senor_de_las_bestias, Condition(function Trig_Pick_30_Senor_de_las_bestias_Conditions))
    call TriggerAddAction(gg_trg_Pick_30_Senor_de_las_bestias, function Trig_Pick_30_Senor_de_las_bestias_Actions)
endfunction

//===========================================================================
// Trigger: Pick_31_Senor_del_Fuego
//===========================================================================
function Trig_Pick_31_Senor_del_Fuego_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_31_Senor_del_Fuego_Conditions takes nothing returns boolean
    if ( not Trig_Pick_31_Senor_del_Fuego_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_31_Senor_del_Fuego_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_31_Senor_del_Fuego_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'Nfir', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Se__or_del_Fuego)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Se__or_del_Fuego)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_31_Senor_del_Fuego_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_31_Senor_del_Fuego takes nothing returns nothing
    set gg_trg_Pick_31_Senor_del_Fuego=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_31_Senor_del_Fuego, gg_rct_Reg_Sel_Se__or_del_Fuego)
    call TriggerAddCondition(gg_trg_Pick_31_Senor_del_Fuego, Condition(function Trig_Pick_31_Senor_del_Fuego_Conditions))
    call TriggerAddAction(gg_trg_Pick_31_Senor_del_Fuego, function Trig_Pick_31_Senor_del_Fuego_Actions)
endfunction

//===========================================================================
// Trigger: Pick_32_Senor_del_foso
//===========================================================================
function Trig_Pick_32_Senor_del_foso_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_32_Senor_del_foso_Conditions takes nothing returns boolean
    if ( not Trig_Pick_32_Senor_del_foso_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_32_Senor_del_foso_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_32_Senor_del_foso_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'Nplh', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Se__or_del_foso)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Se__or_del_foso)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_32_Senor_del_foso_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_32_Senor_del_foso takes nothing returns nothing
    set gg_trg_Pick_32_Senor_del_foso=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_32_Senor_del_foso, gg_rct_Reg_Sel_Se__or_del_foso)
    call TriggerAddCondition(gg_trg_Pick_32_Senor_del_foso, Condition(function Trig_Pick_32_Senor_del_foso_Conditions))
    call TriggerAddAction(gg_trg_Pick_32_Senor_del_foso, function Trig_Pick_32_Senor_del_foso_Actions)
endfunction

//===========================================================================
// Trigger: Pick_33_Nigromante
//===========================================================================
function Trig_Pick_33_Nigromante_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_33_Nigromante_Conditions takes nothing returns boolean
    if ( not Trig_Pick_33_Nigromante_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_33_Nigromante_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_33_Nigromante_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'Nman', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Nigromante)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Nigromante)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_33_Nigromante_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_33_Nigromante takes nothing returns nothing
    set gg_trg_Pick_33_Nigromante=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_33_Nigromante, gg_rct_Reg_Sel_Nigromante)
    call TriggerAddCondition(gg_trg_Pick_33_Nigromante, Condition(function Trig_Pick_33_Nigromante_Conditions))
    call TriggerAddAction(gg_trg_Pick_33_Nigromante, function Trig_Pick_33_Nigromante_Actions)
endfunction

//===========================================================================
// Trigger: Pick_34_Grom_Hellscream
//===========================================================================
function Trig_Pick_34_Grom_Hellscream_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_34_Grom_Hellscream_Conditions takes nothing returns boolean
    if ( not Trig_Pick_34_Grom_Hellscream_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_34_Grom_Hellscream_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_34_Grom_Hellscream_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'Ogrh', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Grom_Hellscream)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Grom_Hellscream)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_34_Grom_Hellscream_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_34_Grom_Hellscream takes nothing returns nothing
    set gg_trg_Pick_34_Grom_Hellscream=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_34_Grom_Hellscream, gg_rct_Reg_Sel_Grom_Hellscream)
    call TriggerAddCondition(gg_trg_Pick_34_Grom_Hellscream, Condition(function Trig_Pick_34_Grom_Hellscream_Conditions))
    call TriggerAddAction(gg_trg_Pick_34_Grom_Hellscream, function Trig_Pick_34_Grom_Hellscream_Actions)
endfunction

//===========================================================================
// Trigger: Pick_35_SylvanasO
//===========================================================================
function Trig_Pick_35_SylvanasO_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_35_SylvanasO_Conditions takes nothing returns boolean
    if ( not Trig_Pick_35_SylvanasO_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_35_SylvanasO_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_35_SylvanasO_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'Usyl', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Sylvanas_Orco)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Sylvanas_Orco)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_35_SylvanasO_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_35_SylvanasO takes nothing returns nothing
    set gg_trg_Pick_35_SylvanasO=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_35_SylvanasO, gg_rct_Reg_Sel_Sylvanas_Orco)
    call TriggerAddCondition(gg_trg_Pick_35_SylvanasO, Condition(function Trig_Pick_35_SylvanasO_Conditions))
    call TriggerAddAction(gg_trg_Pick_35_SylvanasO, function Trig_Pick_35_SylvanasO_Actions)
endfunction

//===========================================================================
// Trigger: Pick_36_Butcher_Abomination
//===========================================================================
function Trig_Pick_36_Butcher_Abomination_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_36_Butcher_Abomination_Conditions takes nothing returns boolean
    if ( not Trig_Pick_36_Butcher_Abomination_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_36_Butcher_Abomination_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_36_Butcher_Abomination_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'H00P', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Butcher_Abomination)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Butcher_Abomination)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_36_Butcher_Abomination_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_36_Butcher_Abomination takes nothing returns nothing
    set gg_trg_Pick_36_Butcher_Abomination=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_36_Butcher_Abomination, gg_rct_Reg_Sel_Butcher_Abomination)
    call TriggerAddCondition(gg_trg_Pick_36_Butcher_Abomination, Condition(function Trig_Pick_36_Butcher_Abomination_Conditions))
    call TriggerAddAction(gg_trg_Pick_36_Butcher_Abomination, function Trig_Pick_36_Butcher_Abomination_Actions)
endfunction

//===========================================================================
// Trigger: Pick_37_Naga_Royal
//===========================================================================
function Trig_Pick_37_Naga_Royal_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_37_Naga_Royal_Conditions takes nothing returns boolean
    if ( not Trig_Pick_37_Naga_Royal_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_37_Naga_Royal_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_37_Naga_Royal_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'H00V', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Naga_Royal)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Naga_Royal)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_37_Naga_Royal_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_37_Naga_Royal takes nothing returns nothing
    set gg_trg_Pick_37_Naga_Royal=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_37_Naga_Royal, gg_rct_Reg_Sel_Naga_Royal)
    call TriggerAddCondition(gg_trg_Pick_37_Naga_Royal, Condition(function Trig_Pick_37_Naga_Royal_Conditions))
    call TriggerAddAction(gg_trg_Pick_37_Naga_Royal, function Trig_Pick_37_Naga_Royal_Actions)
endfunction

//===========================================================================
// Trigger: Pick_38_Summoner_of_the_Thunder
//===========================================================================
function Trig_Pick_38_Summoner_of_the_Thunder_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_38_Summoner_of_the_Thunder_Conditions takes nothing returns boolean
    if ( not Trig_Pick_38_Summoner_of_the_Thunder_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_38_Summoner_of_the_Thunder_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_38_Summoner_of_the_Thunder_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'H00K', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Summoner_of_the_Thunder)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Summoner_of_the_Thunder)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_38_Summoner_of_the_Thunder_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_38_Summoner_of_the_Thunder takes nothing returns nothing
    set gg_trg_Pick_38_Summoner_of_the_Thunder=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_38_Summoner_of_the_Thunder, gg_rct_Reg_Sel_Summoner_of_the_Thunder)
    call TriggerAddCondition(gg_trg_Pick_38_Summoner_of_the_Thunder, Condition(function Trig_Pick_38_Summoner_of_the_Thunder_Conditions))
    call TriggerAddAction(gg_trg_Pick_38_Summoner_of_the_Thunder, function Trig_Pick_38_Summoner_of_the_Thunder_Actions)
endfunction

//===========================================================================
// Trigger: Pick_39_Troll_Berserker
//===========================================================================
function Trig_Pick_39_Troll_Berserker_Func015C takes nothing returns boolean
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'ewsp' ) ) then
        return true
    endif
    if ( ( GetUnitTypeId(GetTriggerUnit()) == 'e006' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Pick_39_Troll_Berserker_Conditions takes nothing returns boolean
    if ( not Trig_Pick_39_Troll_Berserker_Func015C() ) then
        return false
    endif
    return true
endfunction

function Trig_Pick_39_Troll_Berserker_Func008A takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Pick_39_Troll_Berserker_Actions takes nothing returns nothing
    call DisableTrigger(GetTriggeringTrigger())
    call CreateNUnitsAtLoc(1, 'N020', GetOwningPlayer(GetTriggerUnit()), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())), bj_UNIT_FACING)
    set udg_Temp_Punto=GetRectCenter(gg_rct_Reg_Sel_Troll_Berserker)
    call AddSpecialEffectLocBJ(udg_Temp_Punto, "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call RemoveUnit(GetTriggerUnit())
    set udg_Temp_Grupo=GetUnitsInRectAll(gg_rct_Reg_Sel_Troll_Berserker)
    call ForGroupBJ(udg_Temp_Grupo, function Trig_Pick_39_Troll_Berserker_Func008A)
    call DestroyGroup(udg_Temp_Grupo)
    call RemoveLocation(udg_Temp_Punto)
    set udg_Temp_Punto=GetPlayerStartLocationLoc(GetOwningPlayer(GetLastCreatedUnit()))
    call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
    call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetLastCreatedUnit()), udg_Temp_Punto, 2.00)
    call RemoveLocation(udg_Temp_Punto)
endfunction

//===========================================================================
function InitTrig_Pick_39_Troll_Berserker takes nothing returns nothing
    set gg_trg_Pick_39_Troll_Berserker=CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Pick_39_Troll_Berserker, gg_rct_Reg_Sel_Troll_Berserker)
    call TriggerAddCondition(gg_trg_Pick_39_Troll_Berserker, Condition(function Trig_Pick_39_Troll_Berserker_Conditions))
    call TriggerAddAction(gg_trg_Pick_39_Troll_Berserker, function Trig_Pick_39_Troll_Berserker_Actions)
endfunction

//===========================================================================
// Trigger: Habilidad_Techies_Barril
//===========================================================================
//TESH.scrollpos=114
//TESH.alwaysfold=0
//===========================================================================
// SISTEMA: BARRIL EXPLOSIVO (GOBLIN TECHIES) - VERSIÓN FINAL
// IDs: Habilidad A042 | Unidad h00T | Stun A04Z
//===========================================================================

// --- CONFIGURACIÓN ---
function Techies_GetBarrelAbilityId takes nothing returns integer
    return 'A042' // Habilidad del Héroe (Barril)
endfunction

function Techies_GetBarrelUnitId takes nothing returns integer
    return 'h00T' // Unidad Barril
endfunction

function Techies_GetStunAbilityId takes nothing returns integer
    return 'A04Z' // Habilidad Dummy (Stun) - ¡RECUERDA MANÁ 0!
endfunction

// --- FÓRMULA DE DAÑO ---
function Techies_GetDamage takes integer level returns real
    return 90.0 + ( 40.0 * I2R(level) )
endfunction

// --- FUNCIÓN NUEVA: ANTIBOMBA (DETECTA SI LA MATAN) ---
function Trig_Techies_Cancel_Explosion takes nothing returns nothing
    // Si la unidad que mató al barril es un enemigo...
    if ( IsUnitEnemy(GetKillingUnit(), GetOwningPlayer(GetTriggerUnit())) ) then
        // ... ¡BORRAR EL BARRIL YA!
        // Al removerla en el instante exacto de la muerte, se cancela la animación de explosión.
        call RemoveUnit(GetTriggerUnit())
    endif
    // Si murió por el Timer (GetKillingUnit es null), no entra aquí y explota normal.
endfunction

// --- LÓGICA DE EXPLOSIÓN ---
function Trig_Techies_Explode takes nothing returns nothing
    local timer t= GetExpiredTimer()
    local integer tId= GetHandleId(t)
    
    // Recuperamos los datos
    local unit barrel= LoadUnitHandle(udg_MB_Hash, tId, 0)
    local unit caster= LoadUnitHandle(udg_MB_Hash, tId, 1)
    local integer level= LoadInteger(udg_MB_Hash, tId, 2)
    local trigger tDef= LoadTriggerHandle(udg_MB_Hash, tId, 3)
    
    // Variables locales
    local group g
    local unit target
    local real damageBase
    local real finalDamage
    local real dist
    local unit dummy
    
    // Verificamos si el barril sigue vivo
    if ( GetUnitState(barrel, UNIT_STATE_LIFE) > 0.405 ) then
        
        set damageBase=(90.0 + ( 40.0 * I2R((level)) )) // INLINED!!
        
        // 1. STUN (Dummy invisible)
        // Crea un dummy en la posición del barril
        set dummy=CreateUnit(GetOwningPlayer(caster), 'uloc', GetUnitX(barrel), GetUnitY(barrel), 0)
        call UnitAddAbility(dummy, ('A04Z')) // INLINED!!
        
        // Sincronizamos el nivel del stun con el nivel del barril
        // (Asegúrate que A04Z tenga 10 niveles o esto se quedará en nivel 1)
        call SetUnitAbilityLevel(dummy, ('A04Z'), level) // INLINED!!
        
        // Ordenamos el Pisotón (War Stomp -> orderstring: "stomp")
        call IssueImmediateOrder(dummy, "stomp")
        call UnitApplyTimedLife(dummy, 'BTLF', 1.0)
        
        // 2. DAÑO EN ÁREA
        set g=CreateGroup()
        call GroupEnumUnitsInRange(g, GetUnitX(barrel), GetUnitY(barrel), 300.0, null)
        
        loop
            set target=FirstOfGroup(g)
            exitwhen target == null
            call GroupRemoveUnit(g, target)
            
            if ( IsUnitEnemy(target, GetOwningPlayer(caster)) and IsUnitAliveBJ(target) ) then
                set finalDamage=damageBase
                
                // Regla A: Mitad de daño si está lejos (> 150 de distancia)
                set dist=SquareRoot(Pow(GetUnitX(target) - GetUnitX(barrel), 2) + Pow(GetUnitY(target) - GetUnitY(barrel), 2))
                if ( dist > 230.0 ) then
                    set finalDamage=finalDamage * 0.70
                endif
                
                // Regla B: 50% Extra a Edificios
                if ( IsUnitType(target, UNIT_TYPE_STRUCTURE) ) then
                    set finalDamage=finalDamage * 1.50
                endif
                
                // Aplicar Daño Mágico
                call UnitDamageTarget(caster, target, finalDamage, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, WEAPON_TYPE_WHOKNOWS)
            endif
        endloop
        
        call DestroyGroup(g)
        
        // Desactivamos el Trigger Escolta para que no interfiera
        call DisableTrigger(tDef)
        
    else
        // SI LLEGAMOS AQUÍ, UN ENEMIGO LO MATÓ ANTES.
        // El Trigger Escolta ya se encargó de hacerle RemoveUnit, así que no hacemos nada.
        call RemoveUnit(barrel)
    endif
    
    // Limpieza
    call DestroyTrigger(tDef)
    call FlushChildHashtable(udg_MB_Hash, tId)
    call DestroyTimer(t)
    set t=null
    set barrel=null
    set caster=null
    set g=null
    set target=null
    set dummy=null
    set tDef=null
endfunction

// --- ACCIÓN: LANZAMIENTO ---
function Trig_Techies_Cast_Actions takes nothing returns nothing
    local unit caster= GetTriggerUnit()
    local real x= GetSpellTargetX()
    local real y= GetSpellTargetY()
    local integer level= GetUnitAbilityLevel(caster, ('A042')) // INLINED!!
    local unit barrel
    local timer t
    local trigger tDef
    
    // 1. CREAR BARRIL
    set barrel=CreateUnit(GetOwningPlayer(caster), ('h00T'), x, y, 0) // INLINED!!
    
    // 2. CREAR EL TRIGGER ESCOLTA (Detector de muerte enemiga)
    set tDef=CreateTrigger()
    call TriggerRegisterUnitEvent(tDef, barrel, EVENT_UNIT_DEATH)
    call TriggerAddAction(tDef, function Trig_Techies_Cancel_Explosion)
    
    // 3. INICIAR RELOJ (2 Segundos)
    set t=CreateTimer()
    
    // 4. GUARDAR DATOS
    call SaveUnitHandle(udg_MB_Hash, GetHandleId(t), 0, barrel)
    call SaveUnitHandle(udg_MB_Hash, GetHandleId(t), 1, caster)
    call SaveInteger(udg_MB_Hash, GetHandleId(t), 2, level)
    call SaveTriggerHandle(udg_MB_Hash, GetHandleId(t), 3, tDef) // Guardamos el trigger para borrarlo luego
    
    // 5. EJECUTAR
    call TimerStart(t, 2.0, false, function Trig_Techies_Explode)
    
    set caster=null
    set barrel=null
    set t=null
    set tDef=null
endfunction

//===========================================================================
function IsBarrelAbility takes nothing returns boolean
    return GetSpellAbilityId() == ('A042') // INLINED!!
endfunction

function InitTrig_Habilidad_Techies_Barril takes nothing returns nothing
    set gg_trg_Habilidad_Techies_Barril=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Habilidad_Techies_Barril, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddCondition(gg_trg_Habilidad_Techies_Barril, Condition(function IsBarrelAbility))
    call TriggerAddAction(gg_trg_Habilidad_Techies_Barril, function Trig_Techies_Cast_Actions)
endfunction//===========================================================================
// Trigger: Hook TH
//===========================================================================
function Trig_Hook_TH_Actions takes nothing returns nothing
    call InitHashtableBJ()
    set udg_TablaHash=GetLastCreatedHashtableBJ()
endfunction

//===========================================================================
function InitTrig_Hook_TH takes nothing returns nothing
    set gg_trg_Hook_TH=CreateTrigger()
    call TriggerAddAction(gg_trg_Hook_TH, function Trig_Hook_TH_Actions)
endfunction

//===========================================================================
// Trigger: Hook Init
//
// 120
// 200
// 280
// 360
//===========================================================================
function Trig_Hook_Init_Conditions takes nothing returns boolean
    if ( not ( GetSpellAbilityId() == 'A03L' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Hook_Init_Func001C takes nothing returns boolean
    if ( not ( udg_HookMUI[1] == 0 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Hook_Init_Func006C takes nothing returns boolean
    if ( not ( GetSpellTargetUnit() == null ) ) then
        return false
    endif
    return true
endfunction

function Trig_Hook_Init_Actions takes nothing returns nothing
    if ( Trig_Hook_Init_Func001C() ) then
        call EnableTrigger(gg_trg_Hook_Loop)
    else
    endif
    set udg_HookMUI[1]=( udg_HookMUI[1] + 1 )
    set udg_HookMUI[2]=( udg_HookMUI[2] + 1 )
    set udg_Hook_Caster[udg_HookMUI[2]]=GetTriggerUnit()
    set udg_PUNTO_Gancho[udg_HookMUI[2]]=GetUnitLoc(udg_Hook_Caster[udg_HookMUI[2]])
    if ( Trig_Hook_Init_Func006C() ) then
        set udg_PUNTO_Spell[udg_HookMUI[2]]=GetSpellTargetLoc()
    else
        set udg_PUNTO_Spell[udg_HookMUI[2]]=GetUnitLoc(GetSpellTargetUnit())
    endif
    set udg_Angulo[udg_HookMUI[2]]=AngleBetweenPoints(udg_PUNTO_Gancho[udg_HookMUI[2]], udg_PUNTO_Spell[udg_HookMUI[2]])
    set udg_Distancia[udg_HookMUI[2]]=40.00
    // ==Confugurables==
    set udg_Distancia_MAX[udg_HookMUI[2]]=( 550.00 + ( 85.00 * I2R(GetUnitAbilityLevelSwapped('A03L', udg_Hook_Caster[udg_HookMUI[2]])) ) )
    set udg_Damange[udg_HookMUI[2]]=( 0.00 + ( 30.00 * I2R(GetUnitAbilityLevelSwapped('A03L', udg_Hook_Caster[udg_HookMUI[2]])) ) )
    set udg_Velocidad_Cadena[udg_HookMUI[2]]=( 38.00 + ( 0.00 * I2R(GetUnitAbilityLevelSwapped('A03L', udg_Hook_Caster[udg_HookMUI[2]])) ) )
    // == Fin Confugurables==
    set udg_Hook_Drag[udg_HookMUI[2]]=false
    set udg_ON_OFF[udg_HookMUI[2]]=true
    call PauseUnitBJ(true, udg_Hook_Caster[udg_HookMUI[2]])
    call SetUnitAnimation(udg_Hook_Caster[udg_HookMUI[2]], "Attack")
    call RemoveLocation(udg_PUNTO_Spell[udg_HookMUI[2]])
endfunction

//===========================================================================
function InitTrig_Hook_Init takes nothing returns nothing
    set gg_trg_Hook_Init=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Hook_Init, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddCondition(gg_trg_Hook_Init, Condition(function Trig_Hook_Init_Conditions))
    call TriggerAddAction(gg_trg_Hook_Init, function Trig_Hook_Init_Actions)
endfunction

//===========================================================================
// Trigger: Hook Loop
//===========================================================================
function Trig_Hook_Loop_Func001Func001Func001Func006Func004C takes nothing returns boolean
    if ( not ( IsUnitEnemy(udg_Hook_Target[udg_HookMUI[3]], GetOwningPlayer(udg_Hook_Caster[udg_HookMUI[3]])) == true ) ) then
        return false
    endif
    return true
endfunction

function Trig_Hook_Loop_Func001Func001Func001Func006C takes nothing returns boolean
    if ( not ( udg_Hook_Target[udg_HookMUI[3]] != null ) ) then
        return false
    endif
    return true
endfunction

function Trig_Hook_Loop_Func001Func001Func001Func008Func010C takes nothing returns boolean
    if ( not ( udg_HookMUI[1] == 0 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Hook_Loop_Func001Func001Func001Func008C takes nothing returns boolean
    if ( not ( udg_Contador_Cadena[udg_HookMUI[3]] == 0 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Hook_Loop_Func001Func001Func001Func011002003001 takes nothing returns boolean
    return ( IsUnitType(GetFilterUnit(), UNIT_TYPE_STRUCTURE) == false )
endfunction

function Trig_Hook_Loop_Func001Func001Func001Func011002003002001 takes nothing returns boolean
    return ( IsUnitAliveBJ(GetFilterUnit()) == true )
endfunction

function Trig_Hook_Loop_Func001Func001Func001Func011002003002002 takes nothing returns boolean
    return ( GetFilterUnit() != udg_Hook_Caster[udg_HookMUI[3]] )
endfunction

function Trig_Hook_Loop_Func001Func001Func001Func011002003002 takes nothing returns boolean
    return GetBooleanAnd((IsUnitAliveBJ(GetFilterUnit()) == true), (GetFilterUnit() != udg_Hook_Caster[udg_HookMUI[3]])) // INLINED!!
endfunction

function Trig_Hook_Loop_Func001Func001Func001Func011002003 takes nothing returns boolean
    return GetBooleanAnd((IsUnitType(GetFilterUnit(), UNIT_TYPE_STRUCTURE) == false), (GetBooleanAnd((IsUnitAliveBJ(GetFilterUnit()) == true), (GetFilterUnit() != udg_Hook_Caster[udg_HookMUI[3]])))) // INLINED!!
endfunction

function Trig_Hook_Loop_Func001Func001Func001Func017Func002C takes nothing returns boolean
    if ( not ( IsUnitEnemy(udg_Hook_Target[udg_HookMUI[3]], GetOwningPlayer(udg_Hook_Caster[udg_HookMUI[3]])) == true ) ) then
        return false
    endif
    return true
endfunction

function Trig_Hook_Loop_Func001Func001Func001Func017C takes nothing returns boolean
    if ( not ( udg_Hook_Target[udg_HookMUI[3]] != null ) ) then
        return false
    endif
    return true
endfunction

function Trig_Hook_Loop_Func001Func001Func001Func019C takes nothing returns boolean
    if ( not ( udg_Distancia_MAX[udg_HookMUI[3]] <= udg_Distancia[udg_HookMUI[3]] ) ) then
        return false
    endif
    return true
endfunction

function Trig_Hook_Loop_Func001Func001Func001C takes nothing returns boolean
    if ( not ( udg_Hook_Drag[udg_HookMUI[3]] == false ) ) then
        return false
    endif
    return true
endfunction

function Trig_Hook_Loop_Func001Func001C takes nothing returns boolean
    if ( not ( udg_ON_OFF[udg_HookMUI[3]] == true ) ) then
        return false
    endif
    return true
endfunction

function Trig_Hook_Loop_Actions takes nothing returns nothing
    set udg_HookMUI[3]=1
    loop
        exitwhen udg_HookMUI[3] > udg_HookMUI[2]
        if ( Trig_Hook_Loop_Func001Func001C() ) then
            if ( Trig_Hook_Loop_Func001Func001Func001C() ) then
                set udg_PUNTO_Objetivo[udg_HookMUI[3]]=PolarProjectionBJ(udg_PUNTO_Gancho[udg_HookMUI[3]], udg_Distancia[udg_HookMUI[3]], udg_Angulo[udg_HookMUI[3]])
                call CreateNUnitsAtLoc(1, 'n01Z', GetOwningPlayer(udg_Hook_Caster[udg_HookMUI[3]]), udg_PUNTO_Objetivo[udg_HookMUI[3]], udg_Angulo[udg_HookMUI[3]])
                set udg_Hook_Grupo[udg_HookMUI[3]]=GetUnitsInRangeOfLocMatching(80.00, udg_PUNTO_Objetivo[udg_HookMUI[3]], Condition(function Trig_Hook_Loop_Func001Func001Func001Func011002003))
                call RemoveLocation(udg_PUNTO_Objetivo[udg_HookMUI[3]])
                set udg_Contador_Cadena[udg_HookMUI[3]]=( udg_Contador_Cadena[udg_HookMUI[3]] + 1 )
                call SaveUnitHandleBJ(GetLastCreatedUnit(), udg_Contador_Cadena[udg_HookMUI[3]], udg_HookMUI[3], udg_TablaHash)
                set udg_Distancia[udg_HookMUI[3]]=( udg_Distancia[udg_HookMUI[3]] + udg_Velocidad_Cadena[udg_HookMUI[3]] )
                set udg_Hook_Target[udg_HookMUI[3]]=FirstOfGroup(udg_Hook_Grupo[udg_HookMUI[3]])
                if ( Trig_Hook_Loop_Func001Func001Func001Func017C() ) then
                    set udg_Hook_Drag[udg_HookMUI[3]]=true
                    if ( Trig_Hook_Loop_Func001Func001Func001Func017Func002C() ) then
                        call UnitDamageTargetBJ(udg_Hook_Caster[udg_HookMUI[3]], udg_Hook_Target[udg_HookMUI[3]], udg_Damange[udg_HookMUI[3]], ATTACK_TYPE_CHAOS, DAMAGE_TYPE_UNKNOWN)
                        call AddSpecialEffectTargetUnitBJ("origin", udg_Hook_Target[udg_HookMUI[3]], "Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl")
                        call DestroyEffectBJ(GetLastCreatedEffectBJ())
                    else
                    endif
                    call AddSpecialEffectTargetUnitBJ("overhead", udg_Hook_Target[udg_HookMUI[3]], "Abilities\\Spells\\Other\\TalkToMe\\TalkToMe.mdl")
                    call DestroyEffectBJ(GetLastCreatedEffectBJ())
                else
                endif
                call DestroyGroup(udg_Hook_Grupo[udg_HookMUI[3]])
                if ( Trig_Hook_Loop_Func001Func001Func001Func019C() ) then
                    set udg_Hook_Drag[udg_HookMUI[3]]=true
                else
                endif
            else
                set udg_Dummy_Cadena=LoadUnitHandleBJ(udg_Contador_Cadena[udg_HookMUI[3]], udg_HookMUI[3], udg_TablaHash)
                set udg_PUNTO_Objetivo[udg_HookMUI[3]]=GetUnitLoc(udg_Dummy_Cadena)
                call RemoveUnit(udg_Dummy_Cadena)
                set udg_Dummy_Cadena=null
                set udg_Contador_Cadena[udg_HookMUI[3]]=( udg_Contador_Cadena[udg_HookMUI[3]] - 1 )
                if ( Trig_Hook_Loop_Func001Func001Func001Func006C() ) then
                    call SetUnitPathing(udg_Hook_Target[udg_HookMUI[3]], false)
                    call SetUnitPositionLoc(udg_Hook_Target[udg_HookMUI[3]], udg_PUNTO_Objetivo[udg_HookMUI[3]])
                    if ( Trig_Hook_Loop_Func001Func001Func001Func006Func004C() ) then
                        call UnitDamageTargetBJ(udg_Hook_Caster[udg_HookMUI[3]], udg_Hook_Target[udg_HookMUI[3]], ( 1.00 * I2R(GetUnitAbilityLevelSwapped('A03N', udg_Hook_Caster[udg_HookMUI[3]])) ), ATTACK_TYPE_CHAOS, DAMAGE_TYPE_UNKNOWN)
                        call AddSpecialEffectLocBJ(udg_PUNTO_Objetivo[udg_HookMUI[3]], "Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl")
                        call DestroyEffectBJ(GetLastCreatedEffectBJ())
                    else
                    endif
                else
                endif
                call RemoveLocation(udg_PUNTO_Objetivo[udg_HookMUI[3]])
                if ( Trig_Hook_Loop_Func001Func001Func001Func008C() ) then
                    call SetUnitPathing(udg_Hook_Target[udg_HookMUI[3]], true)
                    call PauseUnitBJ(false, udg_Hook_Caster[udg_HookMUI[3]])
                    call ResetUnitAnimation(udg_Hook_Caster[udg_HookMUI[3]])
                    set udg_HookMUI[1]=( udg_HookMUI[1] - 1 )
                    set udg_Hook_Target[udg_HookMUI[3]]=null
                    set udg_Hook_Caster[udg_HookMUI[3]]=null
                    call RemoveLocation(udg_PUNTO_Objetivo[udg_HookMUI[3]])
                    call RemoveLocation(udg_PUNTO_Gancho[udg_HookMUI[3]])
                    set udg_ON_OFF[udg_HookMUI[3]]=false
                    if ( Trig_Hook_Loop_Func001Func001Func001Func008Func010C() ) then
                        set udg_HookMUI[2]=0
                        call DisableTrigger(GetTriggeringTrigger())
                    else
                    endif
                else
                endif
            endif
        else
        endif
        set udg_HookMUI[3]=udg_HookMUI[3] + 1
    endloop
endfunction

//===========================================================================
function InitTrig_Hook_Loop takes nothing returns nothing
    set gg_trg_Hook_Loop=CreateTrigger()
    call DisableTrigger(gg_trg_Hook_Loop)
    call TriggerRegisterTimerEventPeriodic(gg_trg_Hook_Loop, 0.03)
    call TriggerAddAction(gg_trg_Hook_Loop, function Trig_Hook_Loop_Actions)
endfunction

//===========================================================================
// Trigger: Mega Armadura Fuerza
//===========================================================================
function Trig_Mega_Armadura_Fuerza_Conditions takes nothing returns boolean
    if ( not ( GetItemOfTypeFromUnitBJ(GetManipulatingUnit(), 'I00M') != GetManipulatedItem() ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetManipulatedItem()) == 'I00M' ) ) then
        return false
    endif
    if ( not ( UnitHasItem(GetManipulatingUnit(), GetItemOfTypeFromUnitBJ(GetManipulatingUnit(), 'I00M')) == true ) ) then
        return false
    endif
    return true
endfunction

function Trig_Mega_Armadura_Fuerza_Actions takes nothing returns nothing
    // Cuando una unidad aqdquiera un objeto revisas si tiene lo necesario para armar esta receta, en caso que lo tenga eliminas los items necesarios y le das el objeto armado al heroe
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00M'))
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00M'))
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call UnitAddItemByIdSwapped('I01A', GetTriggerUnit())
endfunction

//===========================================================================
function InitTrig_Mega_Armadura_Fuerza takes nothing returns nothing
    set gg_trg_Mega_Armadura_Fuerza=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Mega_Armadura_Fuerza, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    call TriggerAddCondition(gg_trg_Mega_Armadura_Fuerza, Condition(function Trig_Mega_Armadura_Fuerza_Conditions))
    call TriggerAddAction(gg_trg_Mega_Armadura_Fuerza, function Trig_Mega_Armadura_Fuerza_Actions)
endfunction

//===========================================================================
// Trigger: Mega Armadura Agilidad
//===========================================================================
function Trig_Mega_Armadura_Agilidad_Conditions takes nothing returns boolean
    if ( not ( GetItemOfTypeFromUnitBJ(GetManipulatingUnit(), 'I00U') != GetManipulatedItem() ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetManipulatedItem()) == 'I00U' ) ) then
        return false
    endif
    if ( not ( UnitHasItem(GetManipulatingUnit(), GetItemOfTypeFromUnitBJ(GetManipulatingUnit(), 'I00U')) == true ) ) then
        return false
    endif
    return true
endfunction

function Trig_Mega_Armadura_Agilidad_Actions takes nothing returns nothing
    // Cuando una unidad aqdquiera un objeto revisas si tiene lo necesario para armar esta receta, en caso que lo tenga eliminas los items necesarios y le das el objeto armado al heroe
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00U'))
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00U'))
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call UnitAddItemByIdSwapped('I01B', GetTriggerUnit())
endfunction

//===========================================================================
function InitTrig_Mega_Armadura_Agilidad takes nothing returns nothing
    set gg_trg_Mega_Armadura_Agilidad=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Mega_Armadura_Agilidad, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    call TriggerAddCondition(gg_trg_Mega_Armadura_Agilidad, Condition(function Trig_Mega_Armadura_Agilidad_Conditions))
    call TriggerAddAction(gg_trg_Mega_Armadura_Agilidad, function Trig_Mega_Armadura_Agilidad_Actions)
endfunction

//===========================================================================
// Trigger: Mega Armadura Inteligencia
//===========================================================================
function Trig_Mega_Armadura_Inteligencia_Conditions takes nothing returns boolean
    if ( not ( GetItemOfTypeFromUnitBJ(GetManipulatingUnit(), 'I00Q') != GetManipulatedItem() ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetManipulatedItem()) == 'I00Q' ) ) then
        return false
    endif
    if ( not ( UnitHasItem(GetManipulatingUnit(), GetItemOfTypeFromUnitBJ(GetManipulatingUnit(), 'I00Q')) == true ) ) then
        return false
    endif
    return true
endfunction

function Trig_Mega_Armadura_Inteligencia_Actions takes nothing returns nothing
    // Cuando una unidad aqdquiera un objeto revisas si tiene lo necesario para armar esta receta, en caso que lo tenga eliminas los items necesarios y le das el objeto armado al heroe
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00Q'))
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00Q'))
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call UnitAddItemByIdSwapped('I01C', GetTriggerUnit())
endfunction

//===========================================================================
function InitTrig_Mega_Armadura_Inteligencia takes nothing returns nothing
    set gg_trg_Mega_Armadura_Inteligencia=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Mega_Armadura_Inteligencia, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    call TriggerAddCondition(gg_trg_Mega_Armadura_Inteligencia, Condition(function Trig_Mega_Armadura_Inteligencia_Conditions))
    call TriggerAddAction(gg_trg_Mega_Armadura_Inteligencia, function Trig_Mega_Armadura_Inteligencia_Actions)
endfunction

//===========================================================================
// Trigger: Mega Impacto de Dano
//===========================================================================
function Trig_Mega_Impacto_de_Dano_Conditions takes nothing returns boolean
    if ( not ( GetItemOfTypeFromUnitBJ(GetManipulatingUnit(), 'I00B') != GetManipulatedItem() ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetManipulatedItem()) == 'I00B' ) ) then
        return false
    endif
    if ( not ( UnitHasItem(GetManipulatingUnit(), GetItemOfTypeFromUnitBJ(GetManipulatingUnit(), 'I00B')) == true ) ) then
        return false
    endif
    return true
endfunction

function Trig_Mega_Impacto_de_Dano_Actions takes nothing returns nothing
    // Cuando una unidad aqdquiera un objeto revisas si tiene lo necesario para armar esta receta, en caso que lo tenga eliminas los items necesarios y le das el objeto armado al heroe
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00B'))
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00B'))
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call UnitAddItemByIdSwapped('I01D', GetTriggerUnit())
endfunction

//===========================================================================
function InitTrig_Mega_Impacto_de_Dano takes nothing returns nothing
    set gg_trg_Mega_Impacto_de_Dano=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Mega_Impacto_de_Dano, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    call TriggerAddCondition(gg_trg_Mega_Impacto_de_Dano, Condition(function Trig_Mega_Impacto_de_Dano_Conditions))
    call TriggerAddAction(gg_trg_Mega_Impacto_de_Dano, function Trig_Mega_Impacto_de_Dano_Actions)
endfunction

//===========================================================================
// Trigger: Mega Hacha Unicas
//===========================================================================
function Trig_Mega_Hacha_Unicas_Conditions takes nothing returns boolean
    if ( not ( GetItemOfTypeFromUnitBJ(GetManipulatingUnit(), 'I007') != GetManipulatedItem() ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetManipulatedItem()) == 'I007' ) ) then
        return false
    endif
    if ( not ( UnitHasItem(GetManipulatingUnit(), GetItemOfTypeFromUnitBJ(GetManipulatingUnit(), 'I007')) == true ) ) then
        return false
    endif
    return true
endfunction

function Trig_Mega_Hacha_Unicas_Actions takes nothing returns nothing
    // Cuando una unidad aqdquiera un objeto revisas si tiene lo necesario para armar esta receta, en caso que lo tenga eliminas los items necesarios y le das el objeto armado al heroe
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I007'))
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I007'))
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call UnitAddItemByIdSwapped('I01E', GetTriggerUnit())
endfunction

//===========================================================================
function InitTrig_Mega_Hacha_Unicas takes nothing returns nothing
    set gg_trg_Mega_Hacha_Unicas=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Mega_Hacha_Unicas, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    call TriggerAddCondition(gg_trg_Mega_Hacha_Unicas, Condition(function Trig_Mega_Hacha_Unicas_Conditions))
    call TriggerAddAction(gg_trg_Mega_Hacha_Unicas, function Trig_Mega_Hacha_Unicas_Actions)
endfunction

//===========================================================================
// Trigger: Mega Libro de Ataque
//===========================================================================
function Trig_Mega_Libro_de_Ataque_Conditions takes nothing returns boolean
    if ( not ( GetItemOfTypeFromUnitBJ(GetManipulatingUnit(), 'I00F') != GetManipulatedItem() ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetManipulatedItem()) == 'I00F' ) ) then
        return false
    endif
    if ( not ( UnitHasItem(GetManipulatingUnit(), GetItemOfTypeFromUnitBJ(GetManipulatingUnit(), 'I00F')) == true ) ) then
        return false
    endif
    return true
endfunction

function Trig_Mega_Libro_de_Ataque_Actions takes nothing returns nothing
    // Cuando una unidad aqdquiera un objeto revisas si tiene lo necesario para armar esta receta, en caso que lo tenga eliminas los items necesarios y le das el objeto armado al heroe
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00F'))
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00F'))
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call UnitAddItemByIdSwapped('I01F', GetTriggerUnit())
endfunction

//===========================================================================
function InitTrig_Mega_Libro_de_Ataque takes nothing returns nothing
    set gg_trg_Mega_Libro_de_Ataque=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Mega_Libro_de_Ataque, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    call TriggerAddCondition(gg_trg_Mega_Libro_de_Ataque, Condition(function Trig_Mega_Libro_de_Ataque_Conditions))
    call TriggerAddAction(gg_trg_Mega_Libro_de_Ataque, function Trig_Mega_Libro_de_Ataque_Actions)
endfunction

//===========================================================================
// Trigger: Power Treads
//===========================================================================
function Trig_Power_Treads_Func001C takes nothing returns boolean
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'belv')) == 'belv' ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'gcel')) == 'gcel' ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'ciri')) == 'ciri' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Power_Treads_Actions takes nothing returns nothing
    if ( Trig_Power_Treads_Func001C() ) then
        call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'belv'))
        call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'gcel'))
        call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'ciri'))
        call CreateItemLoc('I017', GetRectCenter(GetPlayableMapRect()))
        call UnitAddItemSwapped(GetLastCreatedItem(), GetTriggerUnit())
        call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Items\\AIem\\AIemTarget.mdl")
        call DestroyEffectBJ(GetLastCreatedEffectBJ())
    else
    endif
endfunction

//===========================================================================
function InitTrig_Power_Treads takes nothing returns nothing
    set gg_trg_Power_Treads=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Power_Treads, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    call TriggerAddAction(gg_trg_Power_Treads, function Trig_Power_Treads_Actions)
endfunction

//===========================================================================
// Trigger: Fuerza a Inteligencia
//===========================================================================
function Trig_Fuerza_a_Inteligencia_Conditions takes nothing returns boolean
    if ( not ( GetItemTypeId(GetManipulatedItem()) == 'I018' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Fuerza_a_Inteligencia_Actions takes nothing returns nothing
    call RemoveItem(GetManipulatedItem())
    call UnitAddItemByIdSwapped('I017', GetTriggerUnit())
endfunction

//===========================================================================
function InitTrig_Fuerza_a_Inteligencia takes nothing returns nothing
    set gg_trg_Fuerza_a_Inteligencia=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Fuerza_a_Inteligencia, EVENT_PLAYER_UNIT_USE_ITEM)
    call TriggerAddCondition(gg_trg_Fuerza_a_Inteligencia, Condition(function Trig_Fuerza_a_Inteligencia_Conditions))
    call TriggerAddAction(gg_trg_Fuerza_a_Inteligencia, function Trig_Fuerza_a_Inteligencia_Actions)
endfunction

//===========================================================================
// Trigger: Inteligencia a Agilidad
//===========================================================================
function Trig_Inteligencia_a_Agilidad_Conditions takes nothing returns boolean
    if ( not ( GetItemTypeId(GetManipulatedItem()) == 'I017' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Inteligencia_a_Agilidad_Actions takes nothing returns nothing
    call RemoveItem(GetManipulatedItem())
    call UnitAddItemByIdSwapped('I019', GetTriggerUnit())
endfunction

//===========================================================================
function InitTrig_Inteligencia_a_Agilidad takes nothing returns nothing
    set gg_trg_Inteligencia_a_Agilidad=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Inteligencia_a_Agilidad, EVENT_PLAYER_UNIT_USE_ITEM)
    call TriggerAddCondition(gg_trg_Inteligencia_a_Agilidad, Condition(function Trig_Inteligencia_a_Agilidad_Conditions))
    call TriggerAddAction(gg_trg_Inteligencia_a_Agilidad, function Trig_Inteligencia_a_Agilidad_Actions)
endfunction

//===========================================================================
// Trigger: Agilidad a Fuerza
//===========================================================================
function Trig_Agilidad_a_Fuerza_Conditions takes nothing returns boolean
    if ( not ( GetItemTypeId(GetManipulatedItem()) == 'I019' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Agilidad_a_Fuerza_Actions takes nothing returns nothing
    call RemoveItem(GetManipulatedItem())
    call UnitAddItemByIdSwapped('I018', GetTriggerUnit())
endfunction

//===========================================================================
function InitTrig_Agilidad_a_Fuerza takes nothing returns nothing
    set gg_trg_Agilidad_a_Fuerza=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Agilidad_a_Fuerza, EVENT_PLAYER_UNIT_USE_ITEM)
    call TriggerAddCondition(gg_trg_Agilidad_a_Fuerza, Condition(function Trig_Agilidad_a_Fuerza_Conditions))
    call TriggerAddAction(gg_trg_Agilidad_a_Fuerza, function Trig_Agilidad_a_Fuerza_Actions)
endfunction

//===========================================================================
// Trigger: Botas de TP
//===========================================================================
function Trig_Botas_de_TP_Func001C takes nothing returns boolean
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'bspd')) == 'bspd' ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'brac')) == 'brac' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Botas_de_TP_Actions takes nothing returns nothing
    if ( Trig_Botas_de_TP_Func001C() ) then
        call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'bspd'))
        call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'brac'))
        call CreateItemLoc('I00W', GetRectCenter(GetPlayableMapRect()))
        call UnitAddItemSwapped(GetLastCreatedItem(), GetTriggerUnit())
        call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Items\\AIem\\AIemTarget.mdl")
        call DestroyEffectBJ(GetLastCreatedEffectBJ())
    else
    endif
endfunction

//===========================================================================
function InitTrig_Botas_de_TP takes nothing returns nothing
    set gg_trg_Botas_de_TP=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Botas_de_TP, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    call TriggerAddAction(gg_trg_Botas_de_TP, function Trig_Botas_de_TP_Actions)
endfunction

//===========================================================================
// Trigger: Sistema_Deny
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0
//===========================================================================
// SISTEMA: VISUALIZADOR DE DENEGACIONES (SOLO ALIADOS)
// Muestra un signo "!" SOLO a los aliados del que deniega.
//===========================================================================

function Trig_Deny_Actions takes nothing returns nothing
    local unit victim= GetDyingUnit()
    local unit killer= GetKillingUnit()
    local texttag tag
    
    // CONDICIONES LÓGICAS (Sin cambios):
    if ( killer != null and IsUnitAlly(killer, GetOwningPlayer(victim)) and killer != victim ) then
        
        // 1. CREACIÓN GLOBAL (CRÍTICO PARA EVITAR DESYNCS)
        // El objeto 'tag' debe crearse para todos los jugadores al mismo tiempo.
        set tag=CreateTextTag()
        
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
        // La función IsUnitAlly devuelve true si el 'killer' considera aliado al 'GetLocalPlayer'.
        // Esto incluye al propio jugador dueño del killer y a sus compañeros de equipo.
        
        call SetTextTagVisibility(tag, IsUnitAlly(killer, GetLocalPlayer()))

    endif
    
    // LIMPIEZA DE MEMORIA (Nulling handles)
    set victim=null
    set killer=null
    set tag=null
endfunction

//===========================================================================
function InitTrig_Sistema_Deny takes nothing returns nothing
    set gg_trg_Sistema_Deny=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Sistema_Deny, EVENT_PLAYER_UNIT_DEATH)
    call TriggerAddAction(gg_trg_Sistema_Deny, function Trig_Deny_Actions)
endfunction//===========================================================================
// Trigger: Sistema_Anuncios
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0
//===========================================================================
// SISTEMA: KILL FEED (ANUNCIOS DE MUERTE HUMILLANTES)
// Versión: Victima Primero | Nombres de Jugador | Texto Blanco
//===========================================================================

// --- 1. COLORES DE JUGADORES ---
function Kill_GetColor takes player p returns string
    local integer id= GetPlayerId(p)
    if ( id == 0 ) then
        return "|cffFF0303" // Rojo
    elseif ( id == 1 ) then
        return "|cff0042FF" // Azul
    elseif ( id == 2 ) then
        return "|cff1CE6B9" // Teal
    elseif ( id == 3 ) then
        return "|cff540081" // Morado
    elseif ( id == 4 ) then
        return "|cffFFFC00" // Amarillo
    elseif ( id == 5 ) then
        return "|cffFE8A0E" // Naranja
    elseif ( id == 6 ) then
        return "|cff20C000" // Verde
    elseif ( id == 7 ) then
        return "|cffE55BB0" // Rosa
    elseif ( id == 8 ) then
        return "|cff959697" // Gris
    elseif ( id == 9 ) then
        return "|cff7EBFF1" // Celeste
    endif
    return "|cffFFFFFF"
endfunction

// --- 2. GENERADOR DE FRASES ---
// Esta función construye la frase exacta insertando los nombres
function GetRandomKillMessage takes string sVic,string sKill returns string
    local integer r= GetRandomInt(1, 39)
    local string w= "|cffFFFFFF"
    
    // --- LISTA DE FRASES ---
    if ( r == 1 ) then
        return sVic + w + " intentó pelear… |r" + sKill + w + " fue superior.|r"
    elseif ( r == 2 ) then
        return sVic + w + " cayó sin entender qué pasó; |r" + sKill + w + " sí lo entendió.|r"
    elseif ( r == 3 ) then
        return sVic + w + " fue borrado del mapa por |r" + sKill + "."
    elseif ( r == 4 ) then
        return sVic + w + " fue castigado por |r" + sKill + w + " por exceso de confianza.|r"
    elseif ( r == 5 ) then
        return sVic + w + " cayó como creep frente a |r" + sKill + "."
    elseif ( r == 6 ) then
        return sVic + w + " jugó a perder, |r" + sKill + w + " jugó a ganar.|r"
    elseif ( r == 7 ) then
        return sVic + w + " pensó que escapaba… |r" + sKill + w + " pensó lo contrario.|r"
    elseif ( r == 8 ) then
        return sVic + w + " cayó, |r" + sKill + w + " sumó otro nombre a la lista.|r"
    elseif ( r == 9 ) then
        return sVic + w + " probó suerte, |r" + sKill + w + " probó habilidad.|r"
    elseif ( r == 10 ) then
        return sVic + w + " jugó sin pensar, |r" + sKill + w + " pensó por los dos.|r"
    elseif ( r == 11 ) then
        return sVic + w + " quiso brillar, |r" + sKill + w + " apagó la luz.|r"
    elseif ( r == 12 ) then
        return sVic + w + " se regaló, |r" + sKill + w + " aceptó el obsequio.|r"
    elseif ( r == 13 ) then
        return sVic + w + " sirvió de ejemplo para todos; |r" + sKill + w + " fue el profesor.|r"
    elseif ( r == 14 ) then
        return sVic + w + " aprendió por las malas quién manda: |r" + sKill + "."
    elseif ( r == 15 ) then
        return sVic + w + " terminó sometido por |r" + sKill + "."
    elseif ( r == 16 ) then
        return sVic + w + " no aguantó la presión de |r" + sKill + "."
    elseif ( r == 17 ) then
        return sVic + w + " fue dominado sin delicadeza por |r" + sKill + "."
    elseif ( r == 18 ) then
        return sVic + w + " no estaba listo para lo que hizo |r" + sKill + "."
    elseif ( r == 19 ) then
        return sVic + w + " fue controlado de principio a fin por |r" + sKill + "."
    elseif ( r == 20 ) then
        return sVic + w + " le acaba de regalar oro a |r" + sKill + "."
    elseif ( r == 21 ) then
        return sVic + w + " fue sacrificado en honor a |r" + sKill + "."
    elseif ( r == 22 ) then
        return sVic + w + " se convirtió en la nueva mascota de |r" + sKill + "."
    elseif ( r == 23 ) then
        return sVic + w + " es propiedad legal de |r" + sKill + "."
    elseif ( r == 24 ) then
        return sVic + w + " financió la compra de ítems de |r" + sKill + "."
    elseif ( r == 25 ) then
        return sVic + w + " es el patrocinador oficial del inventario de |r" + sKill + "."
    elseif ( r == 26 ) then
        return sVic + w + " se arrodilló a la altura de la cintura de |r" + sKill + "."
    elseif ( r == 27 ) then
        return sVic + w + " sintió todo el poder de |r" + sKill + w + " adentro.|r"
    elseif ( r == 28 ) then
        return sVic + w + " acaba de bajarle el cierre con los dientes a |r" + sKill + "."
    elseif ( r == 29 ) then
        return sVic + w + " quedó caminando chueco por culpa de |r" + sKill + "."
    elseif ( r == 30 ) then
        return sVic + w + " fue abusado por |r" + sKill + w + " (y le gustó).|r"
    elseif ( r == 31 ) then
        return sVic + w + " andaba regalando su tesorito, y |r" + sKill + w + " estaba cerca.|r"
    elseif ( r == 32 ) then
        return sVic + w + " fue humillado públicamente por |r" + sKill + "."
    elseif ( r == 33 ) then
        return sVic + w + " hizo todo mal; |r" + sKill + w + " hizo todo bien.|r"
    elseif ( r == 34 ) then
        return sVic + w + " ahora es oficialmente hijo de |r" + sKill + "."
    elseif ( r == 35 ) then
        return sVic + w + " se puso de perrito para |r" + sKill + "."
    elseif ( r == 36 ) then
        return sVic + w + " se enamoró perdidamente de la daga de |r" + sKill + "."
    elseif ( r == 37 ) then
        return sVic + w + " probó la espada de |r" + sKill + w + " y le gustó.|r"
    elseif ( r == 38 ) then
        return sVic + w + " fue el ejemplo de qué no hacer; |r" + sKill + w + " dio la cátedra.|r"
    elseif ( r == 39 ) then
        return sVic + w + " fue usado y desechado como objeto por |r" + sKill + "."
    endif
    
    return sVic + w + " murió a manos de |r" + sKill // Fallback por seguridad
endfunction

// --- 3. ACCIONES PRINCIPALES ---
function Trig_Anuncios_Kill_Actions takes nothing returns nothing
    local unit victim= GetDyingUnit()
    local unit killer= GetKillingUnit()
    local player pVictim
    local player pKiller
    local string sKillerName
    local string sVictimName
    local string finalMsg
    
    // 1. VALIDACIÓN: Ambos Héroes y Enemigos
    if ( IsUnitType(victim, UNIT_TYPE_HERO) and IsUnitType(killer, UNIT_TYPE_HERO) ) then
        if ( killer != victim and IsUnitEnemy(killer, GetOwningPlayer(victim)) ) then
            
            // 2. OBTENER JUGADORES
            set pVictim=GetOwningPlayer(victim)
            set pKiller=GetOwningPlayer(killer)
            
            // 3. OBTENER NOMBRES REALES DE JUGADOR (CON COLOR)
            // Usamos GetPlayerName para obtener "Pedrito", no el nombre del Héroe
            set sVictimName=Kill_GetColor(pVictim) + GetPlayerName(pVictim) + "|r"
            set sKillerName=Kill_GetColor(pKiller) + GetPlayerName(pKiller) + "|r"
            
            // 4. GENERAR MENSAJE ALEATORIO
            // Pasamos los nombres a la funcion para que los incruste en la frase
            set finalMsg=GetRandomKillMessage(sVictimName , sKillerName)
            
            // 5. MOSTRAR A TODOS
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10.0, finalMsg)
            
            // 6. SONIDO ORIGINAL (NO PERDERLO)
            // Usamos tu variable global de sonido udg_sound02
            call PlaySoundBJ(udg_sound02)
        endif
    endif
    
    set victim=null
    set killer=null
    set pVictim=null
    set pKiller=null
endfunction

//===========================================================================
function InitTrig_Sistema_Anuncios takes nothing returns nothing
    set gg_trg_Sistema_Anuncios=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Sistema_Anuncios, EVENT_PLAYER_UNIT_DEATH)
    call TriggerAddAction(gg_trg_Sistema_Anuncios, function Trig_Anuncios_Kill_Actions)
endfunction//===========================================================================
// Trigger: Sistema_Cheat
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0
//===========================================================================
// SISTEMA DE CHEAT PRIVADO (NOMBRE + FRASE)
//===========================================================================
function Trig_Cheat_Actions takes nothing returns nothing
    local player p= GetTriggerPlayer()
    local string nombre= StringCase(GetPlayerName(p), false)
    
    // 1. VERIFICACIÓN DE IDENTIDAD (La llave maestra)
    // Comparamos el nombre en minusculas. "materiaviva" es tu ID segura.
    if ( nombre == "laptop" ) then
        
        // 2. EFECTO DEL CHEAT (Solo para ti)
        // Ejemplo: Dar 1000 de Oro y 500 de Madera
        call AdjustPlayerStateBJ(1000, p, PLAYER_STATE_RESOURCE_GOLD)
        call AdjustPlayerStateBJ(100, p, PLAYER_STATE_RESOURCE_LUMBER)
        
        // 3. CONFIRMACIÓN SILENCIOSA
        // Solo tú verás este mensaje. Los demás no verán NADA (excepto tu texto de chat si no lo borras)
        call DisplayTimedTextToPlayer(p, 0, 0, 5.0, "|cff00FF00[SISTEMA]|r Protocolo Omega Activado: Recursos añadidos.")
        
    else
        // Si alguien más escribe la frase, no pasa NADA. 
        // El sistema lo ignora, pareciendo una frase normal de chat.
    endif
    
    set p=null
endfunction

//===========================================================================
function InitTrig_Sistema_Cheat takes nothing returns nothing
    local integer i= 0
    set gg_trg_Sistema_Cheat=CreateTrigger()
    
    loop
        exitwhen i > 9
        // FRASE CLAVE: Puedes cambiar "que buen dia" por lo que quieras.
        // Debe ser exacto.
        call TriggerRegisterPlayerChatEvent(gg_trg_Sistema_Cheat, Player(i), "go", true)
        set i=i + 1
    endloop
    
    call TriggerAddAction(gg_trg_Sistema_Cheat, function Trig_Cheat_Actions)
endfunction//===========================================================================
// Trigger: Comando_Bounty
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0
//===========================================================================
// COMANDO: -bounty (REPORTE FINANCIERO)
// Muestra el oro generado activamente por el jugador.
//===========================================================================
function Trig_Cmd_Bounty_Actions takes nothing returns nothing
    local player p= GetTriggerPlayer()
    local integer id= GetPlayerId(p)
    local integer totalGold= LoadInteger(udg_MB_Hash, id, 3)
    local string color= "|cffFFFF00"
    
    // Mostrar mensaje solo al jugador que preguntó
    call DisplayTimedTextToPlayer(p, 0, 0, 7.0, "Has generado " + color + I2S(totalGold) + "|r de oro por merito propio.")
    
    set p=null
endfunction

//===========================================================================
function InitTrig_Comando_Bounty takes nothing returns nothing
    local integer i= 0
    set gg_trg_Comando_Bounty=CreateTrigger()
    
    loop
        exitwhen i > 9
        // "-bounty" y "-gold"
        call TriggerRegisterPlayerChatEvent(gg_trg_Comando_Bounty, Player(i), "-bounty", true)
        call TriggerRegisterPlayerChatEvent(gg_trg_Comando_Bounty, Player(i), "-gold", true)
        set i=i + 1
    endloop
    
    call TriggerAddAction(gg_trg_Comando_Bounty, function Trig_Cmd_Bounty_Actions)
endfunction//===========================================================================
// Trigger: Sistema_Bounty_Track
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0
//===========================================================================
// SISTEMA: RASTREO DE ORO (-bounty)
// Héroes: 250 | Barracas: 450 | Torres: 150 | Tanques: 40 | Creeps: 20
//===========================================================================
function Trig_Bounty_Track_Actions takes nothing returns nothing
    local unit victim= GetDyingUnit()
    local unit killer= GetKillingUnit()
    local player p= GetOwningPlayer(killer)
    local integer id= GetPlayerId(p)
    local integer uType= GetUnitTypeId(victim)
    local integer goldGained= 0
    local integer currentTotal= 0

    // 1. VALIDACIÓN: Solo contamos si el asesino es un jugador (0-9) y es enemigo
    if ( killer != null and id <= 9 and IsUnitEnemy(victim, p) ) then
        
        // --- A) HÉROES (250 Oro) ---
        if ( IsUnitType(victim, UNIT_TYPE_HERO) ) then
            set goldGained=250
            
            // --- B) ESTRUCTURAS ---
        elseif ( IsUnitType(victim, UNIT_TYPE_STRUCTURE) ) then
            // Verificamos si es una de las 8 "Barracas" que generan creeps
            // IDs extraídos de tu mapa: hbar, edob, eaom, hbla (Humanos) | obar, uslh, usep, otto (Orcos)
            if ( uType == 'hbar' or uType == 'edob' or uType == 'eaom' or uType == 'hbla' or uType == 'obar' or uType == 'uslh' or uType == 'usep' or uType == 'otto' ) then
                // Barracas Generadoras: 450 Oro
                set goldGained=450
            else
                // Torres y otros edificios: 150 Oro
                set goldGained=150
            endif
            
            // --- C) INVOCACIONES (0 Oro) ---
            // Evitamos que farmear lobos o esqueletos cuente para el bounty tracker
        elseif ( IsUnitType(victim, UNIT_TYPE_SUMMONED) ) then
            set goldGained=0
            
            // --- D) UNIDADES DE LÍNEA ---
        else
            // Detectamos los "Tanques" (Gigantes y Taurens)
            if ( uType == 'h009' or uType == 'o002' or uType == 'o008' ) then
                set goldGained=40
            else
                // Cualquier otra unidad (Melee/Rango): 20 Oro
                set goldGained=20
            endif
        endif

        // 3. GUARDAR EN LA BASE DE DATOS (Si hubo ganancia)
        if ( goldGained > 0 ) then
            set currentTotal=LoadInteger(udg_MB_Hash, id, 3)
            call SaveInteger(udg_MB_Hash, id, 3, currentTotal + goldGained)
        endif
    endif

    set victim=null
    set killer=null
    set p=null
endfunction

//===========================================================================
function InitTrig_Sistema_Bounty_Track takes nothing returns nothing
    set gg_trg_Sistema_Bounty_Track=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Sistema_Bounty_Track, EVENT_PLAYER_UNIT_DEATH)
    call TriggerAddAction(gg_trg_Sistema_Bounty_Track, function Trig_Bounty_Track_Actions)
endfunction//===========================================================================
// Trigger: Sistema_Kick
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0
//===========================================================================
// SISTEMA DE KICK PROFESIONAL (ESTABLE + ANTI-SPAM)
//===========================================================================

// --- FUNCIÓN DE BÚSQUEDA (Sin cambios, funciona bien) ---
function Kick_GetPlayer takes string s returns player
    local string input= StringCase(s, false)
    local player p
    local integer i= 0
    
    // 1. COLORES
    if ( input == "rojo" or input == "red" ) then
        return Player(0)
    elseif ( input == "azul" or input == "blue" ) then
        return Player(1)
    elseif ( input == "teal" or input == "cian" or input == "celeste" ) then
        return Player(2)
    elseif ( input == "morado" or input == "purple" ) then
        return Player(3)
    elseif ( input == "amarillo" or input == "yellow" ) then
        return Player(4)
    elseif ( input == "naranja" or input == "orange" ) then
        return Player(5)
    elseif ( input == "verde" or input == "green" ) then
        return Player(6)
    elseif ( input == "rosa" or input == "pink" ) then
        return Player(7)
    elseif ( input == "gris" or input == "grey" or input == "gray" ) then
        return Player(8)
    elseif ( input == "lb" or input == "light" or input == "azul claro" ) then
        return Player(9)
    endif

    // 2. NOMBRES PARCIALES
    loop
        exitwhen i > 9
        set p=Player(i)
        if ( GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING ) then
            if ( SubString(StringCase(GetPlayerName(p), false), 0, StringLength(input)) == input ) then
                return p
            endif
        endif
        set i=i + 1
    endloop

    return null
endfunction

// --- ACCIÓN PRINCIPAL (EJECUCIÓN MANUAL GLOBAL) ---
function Trig_Sistema_Kick_Actions takes nothing returns nothing
    local string chat= GetEventPlayerChatString()
    local player master= udg_Core_JugadorMaestro
    local player kicker= GetTriggerPlayer()
    local player target= null
    local string param= ""
    local integer id= 0
    
    // Variables para ejecución manual
    local integer row= 0
    local multiboarditem mb_item
    local sound snd
    
    // Variables para Drop Manual
    local group g
    local unit u
    local item it
    local integer slot
    local integer locationID
    local real baseX
    local real baseY
    
    // 1. SEGURIDAD
    if ( kicker != master ) then
        return
    endif
    
    // 2. OBTENER OBJETIVO
    set param=SubString(chat, 6, StringLength(chat))
    set target=Kick_GetPlayer(param)
    
    // 3. EJECUCIÓN
    if ( target != null ) then
        set id=GetPlayerId(target)
        
        if ( target == kicker ) then
            call DisplayTimedTextToPlayer(kicker, 0, 0, 5.0, "|cffFF0000[ERROR]|r No te puedes auto-expulsar bro.")
        
            // CHECK: ¿Ya procesado? (Usamos hash 101 para "Ya Limpiado")
        elseif ( LoadBoolean(udg_MB_Hash, id, 101) == true ) then
            call DisplayTimedTextToPlayer(kicker, 0, 0, 5.0, "|cffFF0000[ERROR]|r Jugador ya expulsado.")
            
        else
            // --- PASO A: MARCAR COMO PROCESADO ---
            // Esto evita que el trigger 'tabla' lo vuelva a hacer si el evento llega tarde.
            call SaveBoolean(udg_MB_Hash, id, 100, true) // Marca: Fue Kick
            call SaveBoolean(udg_MB_Hash, id, 101, true) // Marca: Ya Limpiamos
            
            // --- [RESTITUIDO] AVISO DE TEXTO AL PÚBLICO ---
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 7.0, GetPlayerName(target) + " fue expulsado.")
            
            // --- PASO B: ACTUALIZAR TABLA MANUALMENTE (Para Todos) ---
            set row=LoadInteger(udg_MB_Hash, id, 0)
            if ( row > 0 ) then
                set mb_item=MultiboardGetItem(udg_MB_Tabla, row - 1, 0)
                call MultiboardSetItemValue(mb_item, "|cffFFFFFF-----------|r")
                call MultiboardSetItemStyle(mb_item, true, false)
                call MultiboardReleaseItem(mb_item)
            endif
            
            // --- PASO C: SOLTAR ITEMS MANUALMENTE (Copia de seguridad local) ---
            set locationID=GetPlayerStartLocation(target)
            set baseX=GetStartLocationX(locationID)
            set baseY=GetStartLocationY(locationID)
            set g=CreateGroup()
            call GroupEnumUnitsOfPlayer(g, target, null)
            loop
                set u=FirstOfGroup(g)
                exitwhen u == null
                call GroupRemoveUnit(g, u)
                if ( IsUnitType(u, UNIT_TYPE_HERO) ) then
                    set slot=0
                    loop
                        exitwhen slot > 5
                        set it=UnitItemInSlot(u, slot)
                        if ( it != null ) then
                            call UnitRemoveItem(u, it)
                            call SetItemPosition(it, baseX, baseY)
                        endif
                        set slot=slot + 1
                    endloop
                endif
                call RemoveUnit(u)
            endloop
            call DestroyGroup(g)
            
            // --- PASO D: SONIDO MANUAL ---
            set snd=CreateSound("Sound\\Interface\\CreepAggroWhat1.wav", false, false, false, 10, 10, "")
            call SetSoundVolume(snd, 127)
            call StartSound(snd)
            call KillSoundWhenDone(snd)
            set snd=null

            // --- PASO E: EL GOLPE FINAL ---
            call CustomDefeatBJ(target, "Has sido expulsado.")
        endif
    else
        call DisplayTimedTextToPlayer(kicker, 0, 0, 5.0, "|cffFF0000[ERROR]|r Jugador no encontrado: " + param)
    endif
    
    set master=null
    set kicker=null
    set target=null
    set g=null
    set u=null
    set it=null
    set mb_item=null
endfunction

//===========================================================================
function InitTrig_Sistema_Kick takes nothing returns nothing
    local integer i= 0
    set gg_trg_Sistema_Kick=CreateTrigger()
    
    loop
        exitwhen i > 9
        call TriggerRegisterPlayerChatEvent(gg_trg_Sistema_Kick, Player(i), "-kick ", false)
        set i=i + 1
    endloop
    
    call TriggerAddAction(gg_trg_Sistema_Kick, function Trig_Sistema_Kick_Actions)
endfunction//===========================================================================
// Trigger: tabla
//===========================================================================
//TESH.scrollpos=249
//TESH.alwaysfold=0
//===========================================================================
// SISTEMA DE TABLA (MULTIBOARD) 5v5 - VERSIÓN LIMPIA & FINAL
//===========================================================================


// --- 1. COLORES DE JUGADORES ---
function MB_GetColor takes player p returns string
    local integer id= GetPlayerId(p)
    if ( id == 0 ) then
        return "|cffFF0303" // Rojo
    elseif ( id == 1 ) then
        return "|cff0042FF" // Azul
    elseif ( id == 2 ) then
        return "|cff1CE6B9" // Teal
    elseif ( id == 3 ) then
        return "|cff540081" // Morado
    elseif ( id == 4 ) then
        return "|cffFFFC00" // Amarillo
    elseif ( id == 5 ) then
        return "|cffFE8A0E" // Naranja
    elseif ( id == 6 ) then
        return "|cff20C000" // Verde
    elseif ( id == 7 ) then
        return "|cffE55BB0" // Rosa
    elseif ( id == 8 ) then
        return "|cff959697" // Gris
    elseif ( id == 9 ) then
        return "|cff7EBFF1" // Celeste
    endif
    return "|cffFFFFFF"
endfunction

// --- CONFIGURACIÓN: HECHIZOS DE CONTROL (SIN DAÑO) ---
// Rawcodes de los poderes que dan asistencia sin quitar vida.
function MB_IsControlSpell takes integer spellId returns boolean
    // Cambia estos IDs por los de tu mapa
    if ( spellId == 'AHdr' or spellId == 'AOhx' or spellId == 'ANhx' or spellId == 'AHbn' or spellId == 'AUsl' or spellId == 'ANdh' or spellId == 'A03S' or spellId == 'A00A' or spellId == 'A02R' or spellId == 'A04N' ) then
        return true
    endif
    return false
endfunction

// --- HELPER: REGISTRAR INTERACCIÓN (Daño o Control) ---
function MB_RegisterTimestamp takes unit victim,unit attacker returns nothing
    local integer idVic
    local integer idAtt
    local real time= TimerGetElapsed(MB_Timer)
    
    // Validamos: Ambos Héroes, Enemigos
    if ( IsUnitType(victim, UNIT_TYPE_HERO) and IsUnitType(attacker, UNIT_TYPE_HERO) ) then
        if ( IsPlayerEnemy(GetOwningPlayer(victim), GetOwningPlayer(attacker)) ) then
            set idVic=GetPlayerId(GetOwningPlayer(victim))
            set idAtt=GetPlayerId(GetOwningPlayer(attacker))
            
            // Guardamos el tiempo
            call SaveReal(udg_MB_Hash, idVic, 200 + idAtt, time)
        endif
    endif
endfunction

// --- DETECTOR: DAÑO ---
function MB_OnDamage takes nothing returns nothing
    // Solo registramos si el daño es > 0
    if ( GetEventDamage() > 0 ) then
        call MB_RegisterTimestamp(GetTriggerUnit() , GetEventDamageSource())
    endif
endfunction

// --- DETECTOR: HECHIZOS (CONTROL SIN DAÑO) ---
function MB_OnSpell takes nothing returns nothing
    // Verificamos si es un hechizo de la lista "Control sin Daño"
    if ( MB_IsControlSpell(GetSpellAbilityId()) ) then
        call MB_RegisterTimestamp(GetSpellTargetUnit() , GetTriggerUnit())
    endif
endfunction

// --- 2. ACTUALIZAR FILA (CON ASISTENCIAS) ---
function MB_UpdateRow takes player p returns nothing
    local integer id= GetPlayerId(p)
    local integer row= LoadInteger(udg_MB_Hash, id, 0)
    local integer kills= LoadInteger(udg_MB_Hash, id, 1)
    local integer deaths= LoadInteger(udg_MB_Hash, id, 2)
    local integer assists= LoadInteger(udg_MB_Hash, id, 4)
    local multiboarditem mb_item
    
    if ( row == 0 ) then
        return
    endif

    // Columna 1: Kills
    set mb_item=MultiboardGetItem(udg_MB_Tabla, row - 1, 1)
    call MultiboardSetItemValue(mb_item, I2S(kills))
    call MultiboardSetItemStyle(mb_item, true, false)
    call MultiboardReleaseItem(mb_item)

    // Columna 2: Deaths
    set mb_item=MultiboardGetItem(udg_MB_Tabla, row - 1, 2)
    call MultiboardSetItemValue(mb_item, I2S(deaths))
    call MultiboardSetItemStyle(mb_item, true, false)
    call MultiboardReleaseItem(mb_item)
    
    // Columna 3: Assists (NUEVA)
    set mb_item=MultiboardGetItem(udg_MB_Tabla, row - 1, 3)
    call MultiboardSetItemValue(mb_item, I2S(assists))
    call MultiboardSetItemStyle(mb_item, true, false)
    call MultiboardReleaseItem(mb_item)
    
    set mb_item=null
endfunction

// --- 3. EVENTO: MATAR (CALCULO K/D/A CON TIMER SEGURO) ---
function Trig_MB_Kill_Actions takes nothing returns nothing
    local unit killerUnit= GetKillingUnit()
    local unit victimUnit= GetDyingUnit()
    local player pKiller= GetOwningPlayer(killerUnit)
    local player pVictim= GetOwningPlayer(victimUnit)
    local integer idK= GetPlayerId(pKiller)
    local integer idV= GetPlayerId(pVictim)
    
    // Variables para Asistencias
    local integer i= 0
    local real lastHitTime= 0.0
    local real currentTime= TimerGetElapsed(MB_Timer)
    local integer assistCount= 0
    
    if ( IsUnitType(victimUnit, UNIT_TYPE_HERO) ) then
        
        // A) Kill
        if ( pKiller != null and IsPlayerEnemy(pKiller, pVictim) ) then
            call SaveInteger(udg_MB_Hash, idK, 1, LoadInteger(udg_MB_Hash, idK, 1) + 1)
            call MB_UpdateRow(pKiller)
        endif

        // B) Death
        call SaveInteger(udg_MB_Hash, idV, 2, LoadInteger(udg_MB_Hash, idV, 2) + 1)
        call MB_UpdateRow(pVictim)
        
        // C) ASISTENCIAS (MODIFICADO)
        // PROPUESTA SENIOR: El "Portero Lógico".
        // Solo entramos a repartir asistencias si el golpe final lo dio un HÉROE.
        // Si lo mató una Torre, un Creep o un Minion, esto devuelve false y se salta todo el bucle.
        
        if ( IsUnitType(killerUnit, UNIT_TYPE_HERO) ) then
        
            loop
                exitwhen i > 9
                // El jugador (i) no debe ser el asesino Y debe ser enemigo de la víctima (Aliado del asesino)
                if ( Player(i) != pKiller and IsPlayerEnemy(Player(i), pVictim) ) then
                    
                    set lastHitTime=LoadReal(udg_MB_Hash, idV, 200 + i)

                    // Verificamos ventana de tiempo (5.0 segundos)
                    if ( ( currentTime - lastHitTime ) <= 5.0 and lastHitTime > 0.0 ) then
                        set assistCount=LoadInteger(udg_MB_Hash, i, 4)
                        call SaveInteger(udg_MB_Hash, i, 4, assistCount + 1)
                        call MB_UpdateRow(Player(i))
                        
                        call DisplayTimedTextToPlayer(Player(i), 0, 0, 4.0, "|cff00FF00+1 Asistencia|r")
                    endif
                endif
                set i=i + 1
            endloop
            
        endif
        
        // D) Limpieza
        set i=0
        loop
            exitwhen i > 9
            call RemoveSavedReal(udg_MB_Hash, idV, 200 + i)
            set i=i + 1
        endloop
    endif
    
    set killerUnit=null
    set victimUnit=null
    set pKiller=null
    set pVictim=null
endfunction

// --- FUNCIÓN AUXILIAR: SOLTAR ITEMS EN BASE Y BORRAR HEROE ---
function MB_DropItems takes player p returns nothing
    local group g= CreateGroup()
    local unit u
    local item it
    local integer i= 0
    // CAMBIO 1: Calculamos la coordenada X,Y de la "Casa" (Start Location) del jugador
    local integer locationID= GetPlayerStartLocation(p)
    local real baseX= GetStartLocationX(locationID)
    local real baseY= GetStartLocationY(locationID)
    
    call GroupEnumUnitsOfPlayer(g, p, null)
    
    loop
        set u=FirstOfGroup(g)
        exitwhen u == null
        call GroupRemoveUnit(g, u)
        
        // Verificamos si es un Héroe para salvar sus items
        if ( IsUnitType(u, UNIT_TYPE_HERO) ) then
            set i=0
            loop
                exitwhen i > 5
                set it=UnitItemInSlot(u, i)
                if ( it != null ) then
                    call UnitRemoveItem(u, it)
                    // CAMBIO 2: Teletransportamos el item a la Base (Seguridad)
                    call SetItemPosition(it, baseX, baseY)
                endif
                set i=i + 1
            endloop
        endif
        
        // CAMBIO 3: El héroe desaparece del mapa (Nadie gana XP ni oro extra)
        call RemoveUnit(u)
    endloop
    
    call DestroyGroup(g)
    set g=null
    set u=null
    set it=null
endfunction

// --- EVENTO: SALIR (SOLO SI NO FUE PROCESADO ANTES) ---
function Trig_MB_Leaver_Actions takes nothing returns nothing
    local player p= GetTriggerPlayer()
    local integer id= GetPlayerId(p)
    local integer row= 0
    local multiboarditem mb_item
    local sound snd
    
    // CRUCIAL: ¿Ya lo limpió el comando kick?
    // Si es TRUE, significa que el Sistema_Kick ya hizo todo (Sonido, items, tabla).
    // Así que nos detenemos aquí para no repetir cosas.
    if ( LoadBoolean(udg_MB_Hash, id, 101) == true ) then
        return
    endif
    
    // --- SI LLEGAMOS AQUI, FUE UN LEAVER VOLUNTARIO (ALT+F4 / SALIR) ---
    
    // 1. MENSAJE DE ABANDONO
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10.0, GetPlayerName(p) + " ha abandonado la partida.")

    // 2. ACTUALIZAR TABLA
    set row=LoadInteger(udg_MB_Hash, id, 0)
    if ( row > 0 ) then
        set mb_item=MultiboardGetItem(udg_MB_Tabla, row - 1, 0)
        call MultiboardSetItemValue(mb_item, "|cffFFFFFF-----------|r")
        call MultiboardSetItemStyle(mb_item, true, false)
        call MultiboardReleaseItem(mb_item)
    endif

    // 3. SOLTAR ITEMS
    call MB_DropItems(p)

    // 4. SONIDO
    set snd=CreateSound("Sound\\Interface\\CreepAggroWhat1.wav", false, false, false, 10, 10, "")
    call SetSoundVolume(snd, 127)
    call StartSound(snd)
    call KillSoundWhenDone(snd)
    set snd=null
    
    set p=null
    set mb_item=null
endfunction

// --- 5. INICIALIZACIÓN (Diseño UI: Estilo Original Preservado) ---
function Trig_MB_Init_Actions takes nothing returns nothing
    local integer i= 0
    local integer rows= 0
    local integer currentRow= 0
    local multiboarditem mb_item
    local player p
    
    // Mantenemos esto aquí ya que descartamos el cambio de "Race Condition"
    set udg_MB_Hash=InitHashtable()
    
    // --- CREAR TABLA ---
    set udg_MB_Tabla=CreateMultiboard()
    call MultiboardSetColumnCount(udg_MB_Tabla, 4) // CAMBIO: 4 Columnas
    call MultiboardSetTitleText(udg_MB_Tabla, "Orcos vs Humanos")
    
    // --- CABECERAS ---
    call MultiboardSetRowCount(udg_MB_Tabla, 1)
    
    // Columna 0: Jugadores
    set mb_item=MultiboardGetItem(udg_MB_Tabla, 0, 0)
    call MultiboardSetItemValue(mb_item, " ")
    call MultiboardSetItemWidth(mb_item, 0.08)
    call MultiboardSetItemStyle(mb_item, true, false) // Icono APAGADO
    call MultiboardReleaseItem(mb_item)
    
    // Columna 1: Kills
    set mb_item=MultiboardGetItem(udg_MB_Tabla, 0, 1)
    call MultiboardSetItemValue(mb_item, "K")
    call MultiboardSetItemWidth(mb_item, 0.02) // Ajustado
    call MultiboardSetItemStyle(mb_item, true, false)
    call MultiboardReleaseItem(mb_item)
    
    // Columna 2: Deaths
    set mb_item=MultiboardGetItem(udg_MB_Tabla, 0, 2)
    call MultiboardSetItemValue(mb_item, "D")
    call MultiboardSetItemWidth(mb_item, 0.02) // Ajustado
    call MultiboardSetItemStyle(mb_item, true, false)
    call MultiboardReleaseItem(mb_item)

    // Columna 3: Assists (NUEVA)
    set mb_item=MultiboardGetItem(udg_MB_Tabla, 0, 3)
    call MultiboardSetItemValue(mb_item, "A")
    call MultiboardSetItemWidth(mb_item, 0.02) // Ajustado
    call MultiboardSetItemStyle(mb_item, true, false) // Icono APAGADO
    call MultiboardReleaseItem(mb_item)
    
    set currentRow=1

    // --- BLOQUE HUMANOS (0 al 4) ---
    set i=0
    loop
        exitwhen i > 4
        set p=Player(i)
        if ( GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING ) then
            set rows=rows + 1
            call MultiboardSetRowCount(udg_MB_Tabla, currentRow + 1)
            call SaveInteger(udg_MB_Hash, i, 0, currentRow + 1)
            
            // Nombre
            set mb_item=MultiboardGetItem(udg_MB_Tabla, currentRow, 0)
            call MultiboardSetItemValue(mb_item, MB_GetColor(p) + GetPlayerName(p) + "|r")
            call MultiboardSetItemWidth(mb_item, 0.08)
            call MultiboardSetItemStyle(mb_item, true, false) // Icono FALSE
            call MultiboardReleaseItem(mb_item)
            
            // Kills
            set mb_item=MultiboardGetItem(udg_MB_Tabla, currentRow, 1)
            call MultiboardSetItemValue(mb_item, "0")
            call MultiboardSetItemWidth(mb_item, 0.02)
            call MultiboardSetItemStyle(mb_item, true, false) // Icono FALSE
            call MultiboardReleaseItem(mb_item)
            
            // Deaths
            set mb_item=MultiboardGetItem(udg_MB_Tabla, currentRow, 2)
            call MultiboardSetItemValue(mb_item, "0")
            call MultiboardSetItemWidth(mb_item, 0.02)
            call MultiboardSetItemStyle(mb_item, true, false) // Icono FALSE
            call MultiboardReleaseItem(mb_item)

            // Assists (NUEVO)
            set mb_item=MultiboardGetItem(udg_MB_Tabla, currentRow, 3)
            call MultiboardSetItemValue(mb_item, "0")
            call MultiboardSetItemWidth(mb_item, 0.02)
            call MultiboardSetItemStyle(mb_item, true, false) // Icono FALSE
            call MultiboardReleaseItem(mb_item)
            
            set currentRow=currentRow + 1
        endif
        set i=i + 1
    endloop

    // --- SEPARADOR (Ahora cubre 4 columnas) ---
    call MultiboardSetRowCount(udg_MB_Tabla, currentRow + 1)
    set i=0
    loop
        exitwhen i > 3 // CAMBIO: De 2 a 3 (para cubrir col 0,1,2,3)
        set mb_item=MultiboardGetItem(udg_MB_Tabla, currentRow, i)
        call MultiboardSetItemValue(mb_item, " ")
        call MultiboardSetItemStyle(mb_item, true, false) // Icono FALSE
        call MultiboardReleaseItem(mb_item)
        set i=i + 1
    endloop
    set currentRow=currentRow + 1

    // --- BLOQUE ORCOS (5 al 9) ---
    set i=5
    loop
        exitwhen i > 9
        set p=Player(i)
        if ( GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING ) then
            set rows=rows + 1
            call MultiboardSetRowCount(udg_MB_Tabla, currentRow + 1)
            call SaveInteger(udg_MB_Hash, i, 0, currentRow + 1)
            
            // Nombre
            set mb_item=MultiboardGetItem(udg_MB_Tabla, currentRow, 0)
            call MultiboardSetItemValue(mb_item, MB_GetColor(p) + GetPlayerName(p) + "|r")
            call MultiboardSetItemWidth(mb_item, 0.08)
            call MultiboardSetItemStyle(mb_item, true, false) // Icono FALSE
            call MultiboardReleaseItem(mb_item)
            
            // Kills
            set mb_item=MultiboardGetItem(udg_MB_Tabla, currentRow, 1)
            call MultiboardSetItemValue(mb_item, "0")
            call MultiboardSetItemWidth(mb_item, 0.02)
            call MultiboardSetItemStyle(mb_item, true, false) // Icono FALSE
            call MultiboardReleaseItem(mb_item)
            
            // Deaths
            set mb_item=MultiboardGetItem(udg_MB_Tabla, currentRow, 2)
            call MultiboardSetItemValue(mb_item, "0")
            call MultiboardSetItemWidth(mb_item, 0.02)
            call MultiboardSetItemStyle(mb_item, true, false) // Icono FALSE
            call MultiboardReleaseItem(mb_item)

            // Assists (NUEVO)
            set mb_item=MultiboardGetItem(udg_MB_Tabla, currentRow, 3)
            call MultiboardSetItemValue(mb_item, "0")
            call MultiboardSetItemWidth(mb_item, 0.02)
            call MultiboardSetItemStyle(mb_item, true, false) // Icono FALSE
            call MultiboardReleaseItem(mb_item)
            
            set currentRow=currentRow + 1
        endif
        set i=i + 1
    endloop
    
    // VISIBILIDAD
    call MultiboardDisplay(udg_MB_Tabla, true)
    call MultiboardMinimize(udg_MB_Tabla, false)
    
    set mb_item=null
endfunction

// --- FUNCIÓN AUXILIAR: CONECTAR SENSOR DE DAÑO ---
// Esta función se activa cada vez que una unidad entra al mapa (o se crea).
function MB_Register_Damage_Event takes nothing returns nothing
    local unit u= GetTriggerUnit()
    
    // Si es un Héroe, le conectamos el cable para detectar cuando le pegan.
    if ( IsUnitType(u, UNIT_TYPE_HERO) ) then
        call TriggerRegisterUnitEvent(gg_trg_tabla, u, EVENT_UNIT_DAMAGED)
    endif
    
    set u=null
endfunction

//===========================================================================
// INICIALIZACIÓN FINAL (CON FIX DE TIMER + FIX DE SONIDO)
//===========================================================================
function InitTrig_tabla takes nothing returns nothing
    local trigger tInit= CreateTrigger()
    local trigger tKill= CreateTrigger()
    local trigger tLeave= CreateTrigger()
    local trigger tEnter= CreateTrigger()
    local integer i= 0
    // Variables locales para el loop de sonido
    local string soundPath= "Sound\\Interface\\CreepAggroWhat1.wav"
    local sound sndDummy
    local integer loadLoop= 0
    
    // 1. INICIAR LA BASE DE DATOS (0.00s)
    set udg_MB_Hash=InitHashtable()
    
    // 2. FIX RELOJ (Vital para asistencias)
    // Iniciamos el timer01 para que el conteo de los 5 segundos funcione.
    call TimerStart(MB_Timer, 100000.0, false, null)

    // 3. FIX SONIDO (Loop de precarga x2)
    // Restaurado para asegurar que el sonido funcione al primer kick/leaver.
    loop
        exitwhen loadLoop > 1
        set sndDummy=CreateSound(soundPath, false, false, false, 10, 10, "")
        call SetSoundVolume(sndDummy, 0)
        call StartSound(sndDummy)
        call KillSoundWhenDone(sndDummy)
        set sndDummy=null
        set loadLoop=loadLoop + 1
    endloop

    // 4. TRIGGER GLOBAL DE TABLA
    set gg_trg_tabla=CreateTrigger()
    
    // 5. REGISTROS DE COMBATE
    // A) Acción de Daño (Sensor principal)
    call TriggerAddAction(gg_trg_tabla, function MB_OnDamage)
    
    // B) Sensor de Entrada (Conecta el sensor de daño a héroes nuevos)
    call TriggerRegisterEnterRectSimple(tEnter, GetPlayableMapRect())
    call TriggerAddAction(tEnter, function MB_Register_Damage_Event)
    
    // C) Hechizos (Control sin daño)
    set tKill=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(tKill, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddAction(tKill, function MB_OnSpell)
    set tKill=null

    // 6. OTROS EVENTOS (Tabla visual, Kills, Leavers)
    call TriggerRegisterTimerEvent(tInit, 2.00, false)
    call TriggerAddAction(tInit, function Trig_MB_Init_Actions)

    // Evento Muerte    
    set tKill=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(tKill, EVENT_PLAYER_UNIT_DEATH)
    call TriggerAddAction(tKill, function Trig_MB_Kill_Actions)
    
    loop
        exitwhen i > 9
        call TriggerRegisterPlayerEvent(tLeave, Player(i), EVENT_PLAYER_LEAVE)
        call TriggerRegisterPlayerEvent(tLeave, Player(i), EVENT_PLAYER_DEFEAT)
        set i=i + 1
    endloop
    call TriggerAddAction(tLeave, function Trig_MB_Leaver_Actions)
    
    set tInit=null
    set tKill=null
    set tLeave=null
    set tEnter=null
endfunction//===========================================================================
// Trigger: Zoom
//===========================================================================
//TESH.scrollpos=19
//TESH.alwaysfold=0
//===========================================================================
// SISTEMA DE ZOOM "ORC VS HUMAN" (10 JUGADORES + AVISO)
//===========================================================================

// --- FUNCIÓN 1: EL MENSAJE AUTOMÁTICO ---
function Trig_Zoom_Message takes nothing returns nothing
    // Usamos códigos de color: |cff(Hex)Texto|r
    // Amarillo: |cffFFCC00

    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10.00, "Escribe |cffFFCC00-z1|r, |cffFFCC00-z2|r o |cffFFCC00-z3|r para alejar la vista.")
    
    // LIMPIEZA DE MEMORIA:
    // Destruimos este detonador temporal porque ya cumplió su función (sonar a los 15s).
    // Así no ocupa memoria el resto de la partida.
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

// --- FUNCIÓN 2: LA ACCIÓN DE ZOOM ---
function Trig_Zoom_Actions takes nothing returns nothing
    local string chat= GetEventPlayerChatString()
    local player p= GetTriggerPlayer()
    local real distancia= 0.0

    // CONFIGURACIÓN DE NIVELES
    if ( chat == "-z1" ) then
        set distancia=1800.0 // Táctico
    elseif ( chat == "-z2" ) then
        set distancia=2000.0 // Estratégico
    elseif ( chat == "-z3" ) then
        set distancia=2200.0 // Global
    endif

    // APLICACIÓN SEGURA
    if ( distancia > 0.0 ) then
        if ( GetLocalPlayer() == p ) then
            call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, distancia, 0.20)
        endif
    endif

    set p=null
endfunction

//===========================================================================
// FUNCIÓN DE INICIALIZACIÓN (EL CEREBRO)
//===========================================================================
function InitTrig_Zoom takes nothing returns nothing
    local integer i= 0
    // Variable temporal para el detonador del mensaje
    local trigger t_msg= CreateTrigger()
    
    // 1. CONFIGURAR EL SISTEMA DE ZOOM (PRINCIPAL)
    set gg_trg_Zoom=CreateTrigger()
    
    loop
        exitwhen i > 9 // Solo slots 0 al 9 (Jugadores reales)
        call TriggerRegisterPlayerChatEvent(gg_trg_Zoom, Player(i), "-z1", true)
        call TriggerRegisterPlayerChatEvent(gg_trg_Zoom, Player(i), "-z2", true)
        call TriggerRegisterPlayerChatEvent(gg_trg_Zoom, Player(i), "-z3", true)
        set i=i + 1
    endloop
    call TriggerAddAction(gg_trg_Zoom, function Trig_Zoom_Actions)
    
    // 2. CONFIGURAR EL AVISO (TEMPORIZADOR)
    // Esto crea un evento que se dispara a los 15.00 segundos exactos de juego.
    call TriggerRegisterTimerEvent(t_msg, 75.00, false)
    call TriggerAddAction(t_msg, function Trig_Zoom_Message)
    
    // Limpieza de la variable local "t_msg" (No destruye el detonador, solo la referencia)
    set t_msg=null
endfunction//===========================================================================
// Trigger: init
//===========================================================================
//TESH.scrollpos=2805
//TESH.alwaysfold=0
// Map deprotected by X-deprotect (version 2006-10-02) by zibada
// http://dimon.xgm.ru/xdep/
// Visit our modmaking community at http://xgm.ru/


function InitGlobals3 takes nothing returns nothing
    local integer i=0
	set udg_integer01=0
	set udg_integer02=0
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_integers01[i]=0
		set i=i + 1
	endloop
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_strings01[i]=""
		set i=i + 1
	endloop
	set udg_integer03=0
	set udg_integer04=0
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_integers02[i]=0
		set i=i + 1
	endloop
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_integers03[i]=0
		set i=i + 1
	endloop
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_strings02[i]=""
		set i=i + 1
	endloop
	set udg_integer05=0
	set udg_timer01=CreateTimer()
	set udg_integer06=0
	set udg_group01=CreateGroup()
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_timers01[i]=CreateTimer()
		set i=i + 1
	endloop
	set udg_real01=0
	set udg_real02=0
	set udg_boolean01=false
	set udg_boolean02=false
	set udg_force01=CreateForce()
	set udg_group02=CreateGroup()
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_strings03[i]=""
		set i=i + 1
	endloop
	set udg_integer07=0
	set udg_integer08=0
	set udg_group03=CreateGroup()
	set udg_force02=CreateForce()
	set udg_integer09=0
	set udg_integer10=0
	set udg_integer11=0
	set udg_force03=CreateForce()
	set udg_integer12=0
	set udg_integer13=0
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_integers04[i]=0
		set i=i + 1
	endloop
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_integers05[i]=0
		set i=i + 1
	endloop
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_integers06[i]=0
		set i=i + 1
	endloop
	set udg_integer14=0
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_integers07[i]=0
		set i=i + 1
	endloop
	set udg_integer15=0
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_integers08[i]=0
		set i=i + 1
	endloop
	set udg_integer16=0
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_integers09[i]=0
		set i=i + 1
	endloop
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_integers10[i]=0
		set i=i + 1
	endloop
	set udg_force04=CreateForce()
	set udg_force05=CreateForce()
	set udg_integer17=0
	set udg_force06=CreateForce()
	set udg_force07=CreateForce()
	set udg_integer18=0
	set udg_force08=CreateForce()
	set udg_integer19=0
	set udg_force09=CreateForce()
	set udg_integer20=0
	set udg_force10=CreateForce()
	set udg_integer21=0
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_integers11[i]=0
		set i=i + 1
	endloop
	set udg_integer22=0
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_integers12[i]=0
		set i=i + 1
	endloop
	set udg_boolean03=false
	set udg_integer23=0
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_integers13[i]=0
		set i=i + 1
	endloop
	set udg_integer24=0
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_integers14[i]=0
		set i=i + 1
	endloop
	set udg_integer25=0
	set udg_integer26=0
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_integers15[i]=0
		set i=i + 1
	endloop
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_integers16[i]=0
		set i=i + 1
	endloop
	set udg_integer27=0
	set udg_integer28=0
	set udg_integer29=0
	set udg_force11=CreateForce()
	set udg_force12=CreateForce()
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_integers17[i]=0
		set i=i + 1
	endloop
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_integers18[i]=0
		set i=i + 1
	endloop
	set udg_boolean04=false
	set udg_force13=CreateForce()
	set udg_timer02=CreateTimer()
	set udg_timer03=CreateTimer()
	set udg_timer04=CreateTimer()
	set udg_timer05=CreateTimer()
	set udg_timer06=CreateTimer()
	set udg_timer07=CreateTimer()
	set udg_timer08=CreateTimer()
	set udg_timer09=CreateTimer()
	set udg_timer10=CreateTimer()
	set udg_timer11=CreateTimer()
	set udg_boolean05=false
	set udg_force14=CreateForce()
	set udg_force15=CreateForce()
	set udg_boolean06=false
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_dialogs01[i]=DialogCreate()
		set i=i + 1
	endloop
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_dialogs02[i]=DialogCreate()
		set i=i + 1
	endloop
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_dialogs03[i]=DialogCreate()
		set i=i + 1
	endloop
	set udg_boolean07=false
	set udg_dialog01=DialogCreate()
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_booleans01[i]=false
		set i=i + 1
	endloop
	set udg_integer30=0
	set udg_integer31=0
	set udg_integer32=0
	set udg_integer33=0
	set udg_integer34=0
	set udg_integer35=0
	set udg_dialog02=DialogCreate()
	set udg_integer36=0
	set udg_boolean08=false
	set udg_dialog03=DialogCreate()
	set udg_integer37=0
	set udg_boolean09=false
	set udg_integer38=0
	set udg_integer39=0
	set udg_integer40=0
	set udg_group04=CreateGroup()
	set udg_real03=0
	set udg_integer41=0
	set udg_integer42=0
	set udg_real04=0
	set udg_group05=CreateGroup()
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_booleans02[i]=false
		set i=i + 1
	endloop
	set udg_integer43=0
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_integers19[i]=0
		set i=i + 1
	endloop
	set udg_integer44=0
	set udg_integer45=0
	set udg_integer46=0
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_dialogs04[i]=DialogCreate()
		set i=i + 1
	endloop
	set udg_integer47=0
	set udg_integer48=0
	set udg_boolean10=false
	set udg_string01=""
endfunction

//***************************************************************************
//*
//*Custom Script Code
//*
//***************************************************************************
//Map deprotected by X-deprotect(version 2006-10-02)by zibada
//http://dimon.xgm.ru/xdep/
//Visit our modmaking community at http://xgm.ru/
//***************************************************************************
//*
//*Triggers
//*
//***************************************************************************
//===========================================================================
//Trigger:init
//===========================================================================
//Map deprotected by X-deprotect(version 2006-10-02)by zibada
//http://dimon.xgm.ru/xdep/
//Visit our modmaking community at http://xgm.ru/
function InitGlobals2 takes nothing returns nothing
    local integer i=0
	set udg_integer01=0
	set udg_integer02=0
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_integers01[i]=0
		set i=i + 1
	endloop
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_strings01[i]=""
		set i=i + 1
	endloop
	set udg_integer03=0
	set udg_integer04=0
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_integers02[i]=0
		set i=i + 1
	endloop
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_integers03[i]=0
		set i=i + 1
	endloop
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_strings02[i]=""
		set i=i + 1
	endloop
	set udg_integer05=0
	set udg_timer01=CreateTimer()
	set udg_integer06=0
	set udg_group01=CreateGroup()
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_timers01[i]=CreateTimer()
		set i=i + 1
	endloop
	set udg_real01=0
	set udg_real02=20.00
	set udg_boolean01=false
	set udg_boolean02=false
	set udg_force01=CreateForce()
	set udg_group02=CreateGroup()
	set i=0
	loop
		exitwhen ( i > 12 )
		set udg_strings03[i]=""
		set i=i + 1
	endloop
	set udg_integer07=0
	set udg_integer08=0
	set udg_group03=CreateGroup()
	set udg_force02=bj_FORCE_PLAYER[0]
	set udg_integer09=0
	set udg_integer10=0
	set udg_integer11=0
	set udg_force03=CreateForce()
	set udg_integer12=0
	set udg_integer13=0
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_integers04[i]=0
		set i=i + 1
	endloop
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_integers06[i]=0
		set i=i + 1
	endloop
	set udg_integer14=0
	set udg_integer15=0
	set udg_integer16=0
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_integers09[i]=0
		set i=i + 1
	endloop
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_integers10[i]=0
		set i=i + 1
	endloop
	set udg_force04=CreateForce()
	set udg_force05=CreateForce()
	set udg_integer17=0
	set udg_force06=CreateForce()
	set udg_force07=CreateForce()
	set udg_integer18=0
	set udg_force08=CreateForce()
	set udg_integer19=0
	set udg_force09=CreateForce()
	set udg_integer20=0
	set udg_force10=CreateForce()
	set udg_integer21=0
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_integers11[i]=0
		set i=i + 1
	endloop
	set udg_integer22=0
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_integers12[i]=0
		set i=i + 1
	endloop
	set udg_boolean03=false
	set udg_integer23=0
	set udg_integer24=0
	set udg_integer25=0
	set udg_integer26=0
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_integers15[i]=0
		set i=i + 1
	endloop
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_integers16[i]=0
		set i=i + 1
	endloop
	set udg_integer27=0
	set udg_integer28=0
	set udg_integer29=0
	set udg_force11=CreateForce()
	set udg_force12=CreateForce()
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_integers17[i]=0
		set i=i + 1
	endloop
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_integers18[i]=0
		set i=i + 1
	endloop
	set udg_boolean04=false
	set udg_force13=CreateForce()
	set udg_timer02=CreateTimer()
	set udg_timer03=CreateTimer()
	set udg_timer04=CreateTimer()
	set udg_timer05=CreateTimer()
	set udg_timer06=CreateTimer()
	set udg_timer07=CreateTimer()
	set udg_timer08=CreateTimer()
	set udg_timer09=CreateTimer()
	set udg_timer10=CreateTimer()
	set udg_timer11=CreateTimer()
	set udg_player01=Player(9)
	set udg_player02=Player(2)
	set udg_player03=Player(3)
	set udg_player04=Player(4)
	set udg_playercolor01=PLAYER_COLOR_ORANGE
	set udg_player05=Player(6)
	set udg_player06=Player(7)
	set udg_player07=Player(8)
	set udg_boolean05=false
	set udg_force14=CreateForce()
	set udg_force15=CreateForce()
	set udg_boolean06=false
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_dialogs01[i]=DialogCreate()
		set i=i + 1
	endloop
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_dialogs02[i]=DialogCreate()
		set i=i + 1
	endloop
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_dialogs03[i]=DialogCreate()
		set i=i + 1
	endloop
	set udg_boolean07=false
	set udg_dialog01=DialogCreate()
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_booleans01[i]=false
		set i=i + 1
	endloop
	set udg_integer30=0
	set udg_integer31=0
	set udg_integer32=0
	set udg_integer33=0
	set udg_integer34=0
	set udg_integer35=0
	set udg_dialog02=DialogCreate()
	set udg_integer36=0
	set udg_boolean08=false
	set udg_dialog03=DialogCreate()
	set udg_integer37=0
	set udg_boolean09=false
	set udg_integer38=0
	set udg_integer39=0
	set udg_integer40='ewsp'
	set udg_group04=CreateGroup()
	set udg_real03=0
	set udg_integer41=0
	set udg_integer42=0
	set udg_real04=0
	set udg_group05=CreateGroup()
	set i=0
	loop
		exitwhen ( i > 6 )
		set udg_booleans02[i]=false
		set i=i + 1
	endloop
	set udg_integer43=0
	set udg_integer44=0
	set udg_integer45=0
	set udg_integer46=0
	set i=0
	loop
		exitwhen ( i > 1 )
		set udg_dialogs04[i]=DialogCreate()
		set i=i + 1
	endloop
	set udg_integer47=0
	set udg_integer48=0
	set udg_boolean10=false
endfunction

function CreateUnitsForPlayer0 takes nothing returns nothing
    local player p=Player(0)
    local unit u
    local integer unitID
    local trigger t
    local real life
	set udg_unit14=CreateUnit(p, 'ewsp', - 6015.8, - 404.4, 260.810)
endfunction

function CreateUnitsForPlayer1 takes nothing returns nothing
    local player p=Player(1)
    local unit u
    local integer unitID
    local trigger t
    local real life
	set udg_unit15=CreateUnit(p, 'ewsp', - 5727.0, - 399.6, 296.710)
endfunction

function CreateUnitsForPlayer2 takes nothing returns nothing
    local player p=Player(2)
    local unit u
    local integer unitID
    local trigger t
    local real life
	set udg_unit16=CreateUnit(p, 'ewsp', - 5869.9, - 467.1, 166.390)
endfunction

function CreateUnitsForPlayer3 takes nothing returns nothing
    local player p=Player(3)
    local unit u
    local integer unitID
    local trigger t
    local real life
	set udg_unit17=CreateUnit(p, 'ewsp', - 5962.0, - 571.0, 278.580)
endfunction

function CreateUnitsForPlayer4 takes nothing returns nothing
    local player p=Player(4)
    local unit u
    local integer unitID
    local trigger t
    local real life
	set udg_unit18=CreateUnit(p, 'ewsp', - 5797.5, - 576.1, 150.560)
endfunction

function CreateUnitsForPlayer5 takes nothing returns nothing
    local player p=Player(5)
    local unit u
    local integer unitID
    local trigger t
    local real life
	set udg_unit39=CreateUnit(p, 'e006', 5786.4, - 816.2, 345.179)
endfunction

function CreateUnitsForPlayer6 takes nothing returns nothing
    local player p=Player(6)
    local unit u
    local integer unitID
    local trigger t
    local real life
	set udg_unit40=CreateUnit(p, 'e006', 5909.7, - 852.6, 145.452)
endfunction

function CreateUnitsForPlayer7 takes nothing returns nothing
    local player p=Player(7)
    local unit u
    local integer unitID
    local trigger t
    local real life
	set udg_unit41=CreateUnit(p, 'e006', 6019.7, - 781.9, 331.413)
endfunction

function CreateUnitsForPlayer8 takes nothing returns nothing
    local player p=Player(8)
    local unit u
    local integer unitID
    local trigger t
    local real life
	set udg_unit42=CreateUnit(p, 'e006', 5846.9, - 1049.6, 357.945)
endfunction

function CreateUnitsForPlayer9 takes nothing returns nothing
    local player p=Player(9)
    local unit u
    local integer unitID
    local trigger t
    local real life
	set udg_unit43=CreateUnit(p, 'e006', 5982.9, - 1047.2, 164.097)
endfunction

function CreateBuildingsForPlayer10 takes nothing returns nothing
    local player p=Player(10)
    local unit u
    local integer unitID
    local trigger t
    local real life
	set u=CreateUnit(p, 'etrp', - 3872.0, 96.0, 270.000)
	set u=CreateUnit(p, 'etrp', - 4064.0, - 608.0, 270.000)
	set u=CreateUnit(p, 'etrp', - 3744.0, - 480.0, 270.000)
	set udg_unit20=CreateUnit(p, 'hbla', - 3136.0, - 2432.0, 270.000)
	set u=CreateUnit(p, 'h005', - 4800.0, 2688.0, 270.000)
	set u=CreateUnit(p, 'h005', - 4608.0, - 3136.0, 270.000)
	set udg_unit19=CreateUnit(p, 'hcas', - 4096.0, - 256.0, 270.000)
	set u=CreateUnit(p, 'etrp', - 4064.0, 96.0, 270.000)
	set u=CreateUnit(p, 'etrp', - 3744.0, - 96.0, 270.000)
	set u=CreateUnit(p, 'etrp', - 3744.0, - 288.0, 270.000)
	set u=CreateUnit(p, 'etrp', - 4256.0, 96.0, 270.000)
	set u=CreateUnit(p, 'etrp', - 3872.0, - 672.0, 270.000)
	set u=CreateUnit(p, 'etrp', - 4256.0, - 608.0, 270.000)
	set u=CreateUnit(p, 'hgtw', - 3008.0, - 2240.0, 270.000)
	set u=CreateUnit(p, 'hgtw', - 3136.0, - 2112.0, 270.000)
	set u=CreateUnit(p, 'hgtw', - 3136.0, - 1984.0, 270.000)
	set u=CreateUnit(p, 'hgtw', - 3008.0, - 1984.0, 270.000)
	set udg_unit21=CreateUnit(p, 'eaom', - 3264.0, - 1728.0, 270.000)
	set u=CreateUnit(p, 'hgtw', - 3072.0, - 2624.0, 270.000)
	set u=CreateUnit(p, 'hgtw', - 3008.0, - 1536.0, 270.000)
	set udg_unit22=CreateUnit(p, 'edob', - 3200.0, 1216.0, 270.000)
	set udg_unit23=CreateUnit(p, 'hbar', - 3392.0, 1920.0, 270.000)
	set u=CreateUnit(p, 'hgtw', - 3072.0, 1024.0, 270.000)
	set u=CreateUnit(p, 'hgtw', - 3136.0, 1472.0, 270.000)
	set u=CreateUnit(p, 'hgtw', - 3136.0, 1728.0, 270.000)
	set u=CreateUnit(p, 'hgtw', - 3136.0, 2112.0, 270.000)
	set u=CreateUnit(p, 'hgtw', - 3264.0, 1536.0, 270.000)
	set u=CreateUnit(p, 'hgtw', - 3264.0, 1664.0, 270.000)
	set u=CreateUnit(p, 'hgtw', - 1600.0, 1216.0, 270.000)
	set u=CreateUnit(p, 'hgtw', - 1664.0, 2112.0, 270.000)
	set u=CreateUnit(p, 'hgtw', - 1792.0, 2112.0, 270.000)
	set u=CreateUnit(p, 'hgtw', - 1728.0, 1216.0, 270.000)
	set u=CreateUnit(p, 'hgtw', - 1664.0, 1344.0, 270.000)
	set u=CreateUnit(p, 'hgtw', - 1728.0, 1984.0, 270.000)
	set u=CreateUnit(p, 'hgtw', - 1856.0, - 1600.0, 270.000)
	set u=CreateUnit(p, 'hgtw', - 1728.0, - 1600.0, 270.000)
	set u=CreateUnit(p, 'hgtw', - 1792.0, - 1728.0, 270.000)
	set u=CreateUnit(p, 'hgtw', - 1792.0, - 2624.0, 270.000)
	set u=CreateUnit(p, 'hgtw', - 1664.0, - 2624.0, 270.000)
	set u=CreateUnit(p, 'hgtw', - 1728.0, - 2496.0, 270.000)
endfunction

function CreateBuildingsForPlayer11 takes nothing returns nothing
    local player p=Player(11)
    local unit u
    local integer unitID
    local trigger t
    local real life
	set u=CreateUnit(p, 'h005', 4288.0, - 3072.0, 270.000)
	set u=CreateUnit(p, 'uzg2', 2976.0, - 1696.0, 270.000)
	set udg_unit25=CreateUnit(p, 'obar', 2944.0, - 2240.0, 270.000)
	set udg_unit24=CreateUnit(p, 'ofrt', 3840.0, - 256.0, 270.000)
	set u=CreateUnit(p, 'uzg1', 4000.0, - 608.0, 270.000)
	set u=CreateUnit(p, 'uzg1', 3936.0, 96.0, 270.000)
	set u=CreateUnit(p, 'uzg1', 3808.0, - 608.0, 270.000)
	set u=CreateUnit(p, 'uzg1', 3616.0, - 608.0, 270.000)
	set u=CreateUnit(p, 'uzg1', 3488.0, - 416.0, 270.000)
	set u=CreateUnit(p, 'uzg1', 3488.0, - 224.0, 270.000)
	set u=CreateUnit(p, 'uzg1', 3488.0, - 32.0, 270.000)
	set u=CreateUnit(p, 'uzg1', 3552.0, 160.0, 270.000)
	set u=CreateUnit(p, 'uzg1', 3744.0, 96.0, 270.000)
	set u=CreateUnit(p, 'h005', 4480.0, 2368.0, 270.000)
	set u=CreateUnit(p, 'uzg2', 2976.0, - 1952.0, 270.000)
	set u=CreateUnit(p, 'uzg2', 2784.0, - 1952.0, 270.000)
	set udg_unit26=CreateUnit(p, 'uslh', 2944.0, - 1408.0, 270.000)
	set u=CreateUnit(p, 'uzg2', 2784.0, - 1696.0, 270.000)
	set u=CreateUnit(p, 'uzg2', 2976.0, - 2528.0, 270.000)
	set u=CreateUnit(p, 'uzg2', 2912.0, - 1120.0, 270.000)
	set u=CreateUnit(p, 'owtw', 2688.0, 1600.0, 270.000)
	set u=CreateUnit(p, 'owtw', 2816.0, 1536.0, 270.000)
	set u=CreateUnit(p, 'owtw', 2816.0, 1408.0, 270.000)
	set u=CreateUnit(p, 'owtw', 2688.0, 1344.0, 270.000)
	set udg_unit27=CreateUnit(p, 'usep', 2816.0, 1856.0, 270.000)
	set udg_unit28=CreateUnit(p, 'otto', 2816.0, 1088.0, 270.000)
	set u=CreateUnit(p, 'owtw', 2752.0, 832.0, 270.000)
	set u=CreateUnit(p, 'owtw', 2688.0, 2112.0, 270.000)
	set u=CreateUnit(p, 'owtw', 1344.0, 1088.0, 270.000)
	set u=CreateUnit(p, 'owtw', 1472.0, 1088.0, 270.000)
	set u=CreateUnit(p, 'owtw', 1408.0, 1216.0, 270.000)
	set u=CreateUnit(p, 'owtw', 1280.0, 2112.0, 270.000)
	set u=CreateUnit(p, 'owtw', 1408.0, 2112.0, 270.000)
	set u=CreateUnit(p, 'owtw', 1344.0, 1920.0, 270.000)
	set u=CreateUnit(p, 'owtw', 1600.0, - 2624.0, 270.000)
	set u=CreateUnit(p, 'owtw', 1728.0, - 2624.0, 270.000)
	set u=CreateUnit(p, 'owtw', 1664.0, - 2496.0, 270.000)
	set u=CreateUnit(p, 'owtw', 1536.0, - 1728.0, 270.000)
	set u=CreateUnit(p, 'owtw', 1664.0, - 1728.0, 270.000)
	set u=CreateUnit(p, 'owtw', 1600.0, - 1856.0, 270.000)
endfunction

function CreateNeutralPassiveBuildings2 takes nothing returns nothing
    local player p=Player(PLAYER_NEUTRAL_PASSIVE)
    local unit u
    local integer unitID
    local trigger t
    local real life
	set u=CreateUnit(p, 'nfoh', - 4160.0, - 3072.0, 270.000)
	set u=CreateUnit(p, 'nmoo', - 4608.0, - 2752.0, 270.000)
	set u=CreateUnit(p, 'nbfl', 4288.0, - 2688.0, 270.000)
	set u=CreateUnit(p, 'nfh1', 3680.0, - 1376.0, 270.000)
	set u=CreateUnit(p, 'nmoo', - 4864.0, 2304.0, 270.000)
	set u=CreateUnit(p, 'nfoh', - 4416.0, 2496.0, 270.000)
	set u=CreateUnit(p, 'nfh1', - 3936.0, - 1504.0, 270.000)
	set u=CreateUnit(p, 'n000', - 4224.0, - 1408.0, 270.000)
	set u=CreateUnit(p, 'n001', - 4160.0, 832.0, 270.000)
	set u=CreateUnit(p, 'ntav', - 3776.0, 832.0, 270.000)
	call SetUnitColor(u, ConvertPlayerColor(0))
	set u=CreateUnit(p, 'ngme', - 2496.0, - 128.0, 270.000)
	set u=CreateUnit(p, 'n00N', - 2496.0, - 896.0, 270.000)
	set u=CreateUnit(p, 'n00O', - 2496.0, - 512.0, 270.000)
	set u=CreateUnit(p, 'n00M', - 2688.0, 320.0, 270.000)
	set u=CreateUnit(p, 'ngt2', - 224.0, - 288.0, 270.000)
	set u=CreateUnit(p, 'ndfl', 4160.0, 2368.0, 270.000)
	set u=CreateUnit(p, 'nbfl', 4544.0, 2048.0, 270.000)
	set u=CreateUnit(p, 'ndfl', 3904.0, - 2880.0, 270.000)
	set u=CreateUnit(p, 'n000', 3968.0, - 1280.0, 270.000)
	set u=CreateUnit(p, 'n00F', 3456.0, 640.0, 270.000)
	call SetUnitColor(u, ConvertPlayerColor(0))
	set u=CreateUnit(p, 'n001', 3904.0, 576.0, 270.000)
	set u=CreateUnit(p, 'ngme', 2176.0, - 128.0, 270.000)
	set u=CreateUnit(p, 'n00N', 2176.0, - 896.0, 270.000)
	set u=CreateUnit(p, 'n00O', 2176.0, - 512.0, 270.000)
	set u=CreateUnit(p, 'n00M', 2240.0, 320.0, 270.000)
endfunction

function CreateNeutralPassive2 takes nothing returns nothing
    local player p=Player(PLAYER_NEUTRAL_PASSIVE)
    local unit u
    local integer unitID
    local trigger t
    local real life
	set udg_unit03=CreateUnit(p, 'Hamg', - 5460.8, 1.6, 180.000)
	call SetHeroLevel(udg_unit03, 50, false)
	call SetUnitState(udg_unit03, UNIT_STATE_MANA, 0)
	set udg_unit04=CreateUnit(p, 'Hmkg', - 5464.0, - 273.0, 180.000)
	call SetHeroLevel(udg_unit04, 50, false)
	call SetUnitState(udg_unit04, UNIT_STATE_MANA, 0)
	set udg_unit05=CreateUnit(p, 'Hblm', - 5474.1, - 514.5, 180.000)
	call SetHeroLevel(udg_unit05, 50, false)
	call SetUnitState(udg_unit05, UNIT_STATE_MANA, 0)
	set udg_unit06=CreateUnit(p, 'Edem', - 6320.2, 288.1, 356.240)
	call SetHeroLevel(udg_unit06, 50, false)
	call SetUnitState(udg_unit06, UNIT_STATE_MANA, 0)
	set udg_unit07=CreateUnit(p, 'Hpal', - 5472.8, 267.8, 180.000)
	call SetHeroLevel(udg_unit07, 50, false)
	call SetUnitState(udg_unit07, UNIT_STATE_MANA, 0)
	set udg_unit08=CreateUnit(p, 'Ekee', - 6318.5, - 508.2, 2.010)
	call SetHeroLevel(udg_unit08, 50, false)
	call SetUnitState(udg_unit08, UNIT_STATE_MANA, 0)
	set udg_unit09=CreateUnit(p, 'N003', - 6329.8, - 233.7, 4.620)
	call SetHeroLevel(udg_unit09, 50, false)
	set udg_unit10=CreateUnit(p, 'Hvwd', - 5903.4, - 1667.5, 90.000)
	call SetHeroLevel(udg_unit10, 50, false)
	set udg_unit11=CreateUnit(p, 'E005', - 6324.9, - 738.3, 9.580)
	call SetHeroLevel(udg_unit11, 50, false)
	set udg_unit12=CreateUnit(p, 'N002', - 6321.3, 17.7, 0.650)
	call SetHeroLevel(udg_unit12, 50, false)
	call SetUnitState(udg_unit12, UNIT_STATE_MANA, 0)
	set udg_unit13=CreateUnit(p, 'Hlgr', - 5440.2, - 786.2, 174.000)
	call SetHeroLevel(udg_unit13, 50, false)
	set udg_unit29=CreateUnit(p, 'Udea', 6314.2, - 130.0, 173.540)
	call SetHeroLevel(udg_unit29, 50, false)
	call SetUnitState(udg_unit29, UNIT_STATE_MANA, 0)
	set udg_unit30=CreateUnit(p, 'Oshd', 5427.2, - 748.3, 0.000)
	call SetHeroLevel(udg_unit30, 50, false)
	call SetUnitState(udg_unit30, UNIT_STATE_MANA, 0)
	set udg_unit31=CreateUnit(p, 'Ofar', 5455.3, - 82.6, 0.000)
	call SetHeroLevel(udg_unit31, 50, false)
	call SetUnitState(udg_unit31, UNIT_STATE_MANA, 0)
	set udg_unit32=CreateUnit(p, 'Ucrl', 6297.6, 133.3, 177.830)
	call SetHeroLevel(udg_unit32, 50, false)
	call SetUnitState(udg_unit32, UNIT_STATE_MANA, 0)
	set udg_unit33=CreateUnit(p, 'Udre', 6333.9, - 426.4, 184.240)
	call SetHeroLevel(udg_unit33, 50, false)
	call SetUnitState(udg_unit33, UNIT_STATE_MANA, 0)
	set udg_unit34=CreateUnit(p, 'Ulic', 6335.9, - 750.9, 170.150)
	call SetHeroLevel(udg_unit34, 50, false)
	call SetUnitState(udg_unit34, UNIT_STATE_MANA, 0)
	set udg_unit35=CreateUnit(p, 'Nman', 6310.6, - 1074.5, 162.910)
	call SetHeroLevel(udg_unit35, 50, false)
	set udg_unit36=CreateUnit(p, 'Nfir', 5927.9, - 2038.5, 93.000)
	call SetHeroLevel(udg_unit36, 50, false)
	set udg_unit37=CreateUnit(p, 'Otch', 5439.8, - 419.7, 0.000)
	call SetHeroLevel(udg_unit37, 50, false)
	call SetUnitState(udg_unit37, UNIT_STATE_MANA, 0)
	set udg_unit38=CreateUnit(p, 'Obla', 5443.0, 196.7, 0.000)
	call SetHeroLevel(udg_unit38, 50, false)
	call SetUnitState(udg_unit38, UNIT_STATE_MANA, 0)
	set udg_unit47=CreateUnit(p, 'Ogrh', 5456.2, - 1052.0, 359.300)
	call SetHeroLevel(udg_unit47, 50, false)
	set udg_unit46=CreateUnit(p, 'H00G', - 5453.7, - 1083.5, 166.110)
	call SetHeroLevel(udg_unit46, 50, false)
	set udg_unit45=CreateUnit(p, 'O00B', - 6325.5, - 1094.6, 26.740)
	call SetHeroLevel(udg_unit45, 50, false)
	set udg_unit44=CreateUnit(p, 'Usyl', 5491.8, - 1639.2, 6.580)
	call SetHeroLevel(udg_unit44, 50, false)
	set udg_unit48=CreateUnit(p, 'H00K', 6424.8, - 1510.1, 195.400)
	call SetHeroLevel(udg_unit48, 50, false)
endfunction

function CreateRegions2 takes nothing returns nothing
    local weathereffect we
	set udg_rect01=Rect(- 5952.0, - 1568.0, - 5856.0, - 1472.0)
	set udg_rect02=Rect(- 5632.0, - 32.0, - 5568.0, 32.0)
	set udg_rect03=Rect(- 6208.0, - 800.0, - 6144.0, - 736.0)
	set udg_rect04=Rect(5568.0, 96.0, 5632.0, 160.0)
	set udg_rect05=Rect(- 5632.0, - 544.0, - 5568.0, - 480.0)
	set udg_rect06=Rect(- 6208.0, - 544.0, - 6144.0, - 480.0)
	set udg_rect07=Rect(6112.0, 96.0, 6176.0, 160.0)
	set udg_rect08=Rect(6112.0, - 160.0, 6176.0, - 96.0)
	set udg_rect09=Rect(- 6208.0, 224.0, - 6144.0, 288.0)
	set udg_rect10=Rect(6112.0, - 480.0, 6176.0, - 416.0)
	set udg_rect11=Rect(5568.0, - 128.0, 5632.0, - 64.0)
	set udg_rect12=Rect(- 4672.0, 2016.0, - 4288.0, 2304.0)
	set udg_rect13=Rect(- 4416.0, - 2784.0, - 4128.0, - 2528.0)
	set udg_rect14=Rect(5856.0, - 1856.0, 5984.0, - 1760.0)
	set udg_rect15=Rect(4032.0, 1792.0, 4384.0, 2176.0)
	set udg_rect16=Rect(3776.0, - 2688.0, 4160.0, - 2400.0)
	set udg_rect17=Rect(- 5632.0, - 800.0, - 5568.0, - 736.0)
	set udg_rect18=Rect(- 6016.0, - 416.0, - 5760.0, - 96.0)
	set udg_rect19=Rect(- 3072.0, 1728.0, - 2752.0, 2080.0)
	set udg_rect20=Rect(- 3072.0, 1088.0, - 2752.0, 1408.0)
	set udg_rect21=Rect(- 2976.0, - 1952.0, - 2656.0, - 1600.0)
	set udg_rect22=Rect(- 2976.0, - 2592.0, - 2656.0, - 2272.0)
	set udg_rect23=Rect(- 3488.0, - 480.0, - 3136.0, - 96.0)
	set udg_rect24=Rect(5568.0, - 1056.0, 5632.0, - 992.0)
	set udg_rect25=Rect(6112.0, - 800.0, 6208.0, - 704.0)
	set udg_rect26=Rect(- 5632.0, - 288.0, - 5568.0, - 224.0)
	set udg_rect27=Rect(6144.0, - 1088.0, 6208.0, - 1024.0)
	set udg_rect28=Rect(5760.0, - 448.0, 6048.0, - 96.0)
	set udg_rect29=Rect(2304.0, 1696.0, 2624.0, 1984.0)
	set udg_rect30=Rect(2400.0, 896.0, 2688.0, 1184.0)
	set udg_rect31=Rect(2400.0, - 1728.0, 2720.0, - 1440.0)
	set udg_rect32=Rect(2336.0, - 2560.0, 2720.0, - 2240.0)
	set udg_rect33=Rect(2912.0, - 416.0, 3264.0, - 64.0)
	set udg_rect34=Rect(- 5632.0, 224.0, - 5568.0, 288.0)
	set udg_rect35=Rect(- 6208.0, - 32.0, - 6144.0, 32.0)
	set udg_rect36=Rect(- 3808.0, - 800.0, - 3648.0, - 608.0)
	set udg_rect37=Rect(- 3840.0, 96.0, - 3648.0, 352.0)
	set udg_rect38=Rect(3392.0, 128.0, 3552.0, 320.0)
	set udg_rect39=Rect(3392.0, - 640.0, 3552.0, - 448.0)
	set udg_rect40=Rect(5568.0, - 800.0, 5632.0, - 736.0)
	set udg_rect41=Rect(5568.0, - 480.0, 5632.0, - 416.0)
	set udg_rect42=Rect(- 6208.0, - 288.0, - 6144.0, - 224.0)
	set udg_rect43=Rect(5536.0, - 1504.0, 5632.0, - 1376.0)
	set udg_rect44=Rect(6176.0, - 1504.0, 6272.0, - 1440.0)
	set udg_rect45=Rect(- 6208.0, - 1120.0, - 6144.0, - 1056.0)
	set udg_rect46=Rect(- 5632.0, - 1120.0, - 5568.0, - 1056.0)
endfunction

function GetHost takes nothing returns nothing
    local gamecache g=InitGameCache("Map.w3v")
	call StoreInteger(g, "Map", "Host", GetPlayerId(GetLocalPlayer()) + 1)
	call TriggerSyncStart()
	call SyncStoredInteger(g, "Map", "Host")
	call TriggerSyncReady()
	set udg_player09=Player(GetStoredInteger(g, "Map", "Host") - 1)
	call FlushGameCache(g)
	set g=null
endfunction

function CountItemsOnUnit takes integer I,unit U returns integer
    local integer LoopA=0
    local integer CountNo=0
	loop
		exitwhen LoopA > 5
		if GetItemTypeId(UnitItemInSlot(U, LoopA)) == I then
			set CountNo=CountNo + 1
		endif
		set LoopA=LoopA + 1
	endloop
	return CountNo
endfunction

function Trig_Elsin_Actions takes nothing returns nothing
	call PauseGameOff()
endfunction

function Trig_Kick_Player_Func001Func001C takes nothing returns boolean
	if ( not ( GetEventPlayerChatString() == ( "-kick " + GetPlayerName(ConvertedPlayer(GetForLoopIndexA())) ) ) ) then
		return false
	endif
	return true
endfunction

function Trig_Kick_Player_Func002Func003A takes nothing returns nothing
	call CustomDefeatBJ(udg_player08, "TRIGSTR_8795")
	call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Kick_Player_Func002Func004A takes nothing returns nothing
	call SetPlayerAllianceStateBJ(udg_player08, GetEnumPlayer(), bj_ALLIANCE_UNALLIED)
	call SetPlayerAllianceStateBJ(GetEnumPlayer(), udg_player08, bj_ALLIANCE_UNALLIED)
endfunction

function Trig_Kick_Player_Func002C takes nothing returns boolean
	if ( not ( udg_booleans01[GetConvertedPlayerId(udg_player08)] == false ) ) then
		return false
	endif
	return true
endfunction

function Trig_Kick_Player_Actions takes nothing returns nothing
	set bj_forLoopAIndex=2
	set bj_forLoopAIndexEnd=10
	loop
		exitwhen bj_forLoopAIndex > bj_forLoopAIndexEnd
		if ( Trig_Kick_Player_Func001Func001C() ) then
			set udg_player08=ConvertedPlayer(GetForLoopIndexA())
		else
		endif
		set bj_forLoopAIndex=bj_forLoopAIndex + 1
	endloop
	if ( Trig_Kick_Player_Func002C() ) then
		set udg_booleans01[GetConvertedPlayerId(udg_player08)]=true
		call DisplayTextToForce(GetPlayersAll(), ( "|cffFF6666" + ( GetPlayerName(udg_player08) + "|r was kicked." ) ))
		call ForGroupBJ(GetUnitsOfPlayerAll(udg_player08), function Trig_Kick_Player_Func002Func003A)
		call ForForce(GetPlayersAll(), function Trig_Kick_Player_Func002Func004A)
	else
	endif
endfunction

function Trig_Inicialization_Actions takes nothing returns nothing
	call TriggerExecute(udg_trigger34)
	call TriggerExecute(udg_trigger33)
	call GetHost()
	call SetTimeOfDay(7.00)
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Menu1_______3_DE_ORO_y_6_DE_ORO_Actions takes nothing returns nothing
	call DialogAddButtonBJ(udg_dialogs01[1], "TRIGSTR_8796")
	set udg_buttons01[1]=GetLastCreatedButtonBJ()
	call DialogAddButtonBJ(udg_dialogs01[1], "TRIGSTR_8797")
	set udg_buttons01[2]=GetLastCreatedButtonBJ()
	call DialogDisplayBJ(true, udg_dialogs01[1], Player(0))
	call PauseGameOn()
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Acciones_Menu1_3_DE_ORO_Conditions takes nothing returns boolean
	if ( not ( GetClickedButtonBJ() == udg_buttons01[1] ) ) then
		return false
	endif
	return true
endfunction

function Trig_Acciones_Menu1_3_DE_ORO_Actions takes nothing returns nothing
	call DisplayTextToForce(GetPlayersAll(), "TRIGSTR_8798")
	call EnableTrigger(udg_trigger98)
	call DialogClearBJ(udg_dialogs01[1])
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Acciones_Menu1_6_DE_ORO_Conditions takes nothing returns boolean
	if ( not ( GetClickedButtonBJ() == udg_buttons01[2] ) ) then
		return false
	endif
	return true
endfunction

function Trig_Acciones_Menu1_6_DE_ORO_Actions takes nothing returns nothing
	call DisplayTextToForce(GetPlayersAll(), "TRIGSTR_8799")
	call EnableTrigger(udg_trigger99)
	call DialogClearBJ(udg_dialogs01[1])
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Menu2_______SM_y_USM_Actions takes nothing returns nothing
	call DialogAddButtonBJ(udg_dialogs02[1], "TRIGSTR_8800")
	set udg_buttons02[1]=GetLastCreatedButtonBJ()
	call DialogAddButtonBJ(udg_dialogs02[1], "TRIGSTR_8801")
	set udg_buttons02[2]=GetLastCreatedButtonBJ()
	call DialogDisplayBJ(true, udg_dialogs02[1], Player(0))
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Acciones_Menu2_SM_Conditions takes nothing returns boolean
	if ( not ( GetClickedButtonBJ() == udg_buttons02[1] ) ) then
		return false
	endif
	return true
endfunction

function Trig_Acciones_Menu2_SM_Actions takes nothing returns nothing
	call EnableTrigger(udg_trigger27)
	call DialogClearBJ(udg_dialogs01[1])
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Acciones_Menu2_USM_Conditions takes nothing returns boolean
	if ( not ( GetClickedButtonBJ() == udg_buttons02[2] ) ) then
		return false
	endif
	return true
endfunction

function Trig_Acciones_Menu2_USM_Actions takes nothing returns nothing
	call EnableTrigger(udg_trigger28)
	call DialogClearBJ(udg_dialogs01[1])
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Menu3_______Game_Modes_Actions takes nothing returns nothing
	call DialogAddButtonBJ(udg_dialogs03[1], "TRIGSTR_8802")
	set udg_buttons03[1]=GetLastCreatedButtonBJ()
	call DialogAddButtonBJ(udg_dialogs03[1], "TRIGSTR_8803")
	set udg_buttons03[2]=GetLastCreatedButtonBJ()
	call DialogAddButtonBJ(udg_dialogs03[1], "TRIGSTR_8804")
	set udg_buttons03[3]=GetLastCreatedButtonBJ()
	call DialogDisplayBJ(true, udg_dialogs03[1], Player(0))
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Acciones_Menu3_ALLPICK_Conditions takes nothing returns boolean
	if ( not ( GetClickedButtonBJ() == udg_buttons03[1] ) ) then
		return false
	endif
	return true
endfunction

function Trig_Acciones_Menu3_ALLPICK_Actions takes nothing returns nothing
	call PauseGameOff()
	call DialogClearBJ(udg_dialogs01[1])
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Acciones_Menu3_ALLRADOM_Conditions takes nothing returns boolean
	if ( not ( GetClickedButtonBJ() == udg_buttons03[2] ) ) then
		return false
	endif
	return true
endfunction

function Trig_Acciones_Menu3_ALLRADOM_Actions takes nothing returns nothing
	call EnableTrigger(udg_trigger38)
	call PauseGameOff()
	call DialogClearBJ(udg_dialogs01[1])
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Acciones_Menu3_MODO_CLASICO_Conditions takes nothing returns boolean
	if ( not ( GetClickedButtonBJ() == udg_buttons03[3] ) ) then
		return false
	endif
	return true
endfunction

function Trig_Acciones_Menu3_MODO_CLASICO_Actions takes nothing returns nothing
	call DisplayTextToForce(GetPlayersAll(), "TRIGSTR_8806")
	call RemoveUnit(udg_unit45)
	call RemoveUnit(udg_unit46)
	call RemoveUnit(udg_unit44)
	call RemoveUnit(udg_unit48)
	call DisableTrigger(udg_trigger56)
	call DisableTrigger(udg_trigger57)
	call DisableTrigger(udg_trigger80)
	call DisableTrigger(udg_trigger81)
	call PauseGameOff()
	call DialogClearBJ(udg_dialogs01[1])
	call PanCameraToTimedLocForPlayer(Player(0), GetRectCenter(udg_rect18), 1.00)
	call PanCameraToTimedLocForPlayer(Player(1), GetRectCenter(udg_rect18), 1.00)
	call PanCameraToTimedLocForPlayer(Player(2), GetRectCenter(udg_rect18), 1.00)
	call PanCameraToTimedLocForPlayer(Player(3), GetRectCenter(udg_rect18), 1.00)
	call PanCameraToTimedLocForPlayer(Player(4), GetRectCenter(udg_rect18), 1.00)
	call PanCameraToTimedLocForPlayer(Player(5), GetRectCenter(udg_rect28), 1.00)
	call PanCameraToTimedLocForPlayer(Player(6), GetRectCenter(udg_rect28), 1.00)
	call PanCameraToTimedLocForPlayer(Player(7), GetRectCenter(udg_rect28), 1.00)
	call PanCameraToTimedLocForPlayer(Player(8), GetRectCenter(udg_rect28), 1.00)
	call PanCameraToTimedLocForPlayer(Player(9), GetRectCenter(udg_rect28), 1.00)
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Attack_1_Barracas_1_Conditions takes nothing returns boolean
	if ( not ( GetOwningPlayer(GetTriggerUnit()) == Player(10) ) ) then
		return false
	endif
	return true
endfunction

function Trig_Attack_1_Barracas_1_Actions takes nothing returns nothing
	call IssuePointOrderLocBJ(GetTriggerUnit(), "attack", GetRectCenter(udg_rect38))
endfunction

function Trig_Attack_1_Blacksmith_1_Conditions takes nothing returns boolean
	if ( not ( GetOwningPlayer(GetTriggerUnit()) == Player(10) ) ) then
		return false
	endif
	return true
endfunction

function Trig_Attack_1_Blacksmith_1_Actions takes nothing returns nothing
	call IssuePointOrderLocBJ(GetTriggerUnit(), "attack", GetRectCenter(udg_rect38))
endfunction

function Trig_Attack_1_Barracas_2_Conditions takes nothing returns boolean
	if ( not ( GetOwningPlayer(GetTriggerUnit()) == Player(10) ) ) then
		return false
	endif
	return true
endfunction

function Trig_Attack_1_Barracas_2_Actions takes nothing returns nothing
	call IssuePointOrderLocBJ(GetTriggerUnit(), "attack", GetRectCenter(udg_rect39))
endfunction

function Trig_Attack_1_Blacsmith_2_Conditions takes nothing returns boolean
	if ( not ( GetOwningPlayer(GetTriggerUnit()) == Player(10) ) ) then
		return false
	endif
	return true
endfunction

function Trig_Attack_1_Blacsmith_2_Actions takes nothing returns nothing
	call IssuePointOrderLocBJ(GetTriggerUnit(), "attack", GetRectCenter(udg_rect39))
endfunction

function Trig_Attack_1_orc_Barracas_2_Conditions takes nothing returns boolean
	if ( not ( GetOwningPlayer(GetTriggerUnit()) == Player(11) ) ) then
		return false
	endif
	return true
endfunction

function Trig_Attack_1_orc_Barracas_2_Actions takes nothing returns nothing
	call IssuePointOrderLocBJ(GetTriggerUnit(), "attack", GetRectCenter(udg_rect37))
endfunction

function Trig_Attack_1_orc_Tauren_2_Conditions takes nothing returns boolean
	if ( not ( GetOwningPlayer(GetTriggerUnit()) == Player(11) ) ) then
		return false
	endif
	return true
endfunction

function Trig_Attack_1_orc_Tauren_2_Actions takes nothing returns nothing
	call IssuePointOrderLocBJ(GetTriggerUnit(), "attack", GetRectCenter(udg_rect37))
endfunction

function Trig_Attack_1_orc_Tauren_1_Conditions takes nothing returns boolean
	if ( not ( GetOwningPlayer(GetTriggerUnit()) == Player(11) ) ) then
		return false
	endif
	return true
endfunction

function Trig_Attack_1_orc_Tauren_1_Actions takes nothing returns nothing
	call IssuePointOrderLocBJ(GetTriggerUnit(), "attack", GetRectCenter(udg_rect36))
endfunction

function Trig_Attack_1_orc_Barracas_1_Conditions takes nothing returns boolean
	if ( not ( GetOwningPlayer(GetTriggerUnit()) == Player(11) ) ) then
		return false
	endif
	return true
endfunction

function Trig_Attack_1_orc_Barracas_1_Actions takes nothing returns nothing
	call IssuePointOrderLocBJ(GetTriggerUnit(), "attack", GetRectCenter(udg_rect36))
endfunction

function Trig_First_Blood_Conditions takes nothing returns boolean
	if ( not ( IsUnitType(GetDyingUnit(), UNIT_TYPE_HERO) == true ) ) then
		return false
	endif
	if ( not ( IsUnitType(GetKillingUnitBJ(), UNIT_TYPE_HERO) == true ) ) then
		return false
	endif
	return true
endfunction

function Trig_First_Blood_Actions takes nothing returns nothing
	call DisplayTextToForce(GetPlayersAll(), "TRIGSTR_8815")
	call PlaySoundBJ(udg_sound01)
	call DisableTrigger(GetTriggeringTrigger())
	call EnableTrigger(udg_trigger23)
endfunction

//function Trig_Hero_Kill_Conditions takes nothing returns boolean
//if(not(IsUnitType(GetDyingUnit(),UNIT_TYPE_HERO)==true))then
//return false
//endif
//if(not(IsUnitType(GetKillingUnitBJ(),UNIT_TYPE_HERO)==true))then
//return false
//endif
//return true
//endfunction

//function Trig_Hero_Kill_Actions takes nothing returns nothing
//call QuestMessageBJ(udg_force03,bj_QUESTMESSAGE_ALWAYSHINT,(("|cff00ccffHero Kill|r - "+udg_strings03[GetConvertedPlayerId(GetOwningPlayer(GetDyingUnit()))])+(" ha sido asesinado por "+(udg_strings03[GetConvertedPlayerId(GetOwningPlayer(GetKillingUnitBJ()))]+" for an additional Gold."))))
//call PlaySoundBJ(udg_sound02)
//anuncio antiguo
//endfunction

function Trig_Tips_Actions takes nothing returns nothing
	//call QuestMessageBJ(GetPlayersAll(), bj_QUESTMESSAGE_ALWAYSHINT, "TRIGSTR_8816")
	//call QuestMessageBJ(GetPlayersAll(), bj_QUESTMESSAGE_ALWAYSHINT, "TRIGSTR_8817")
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_AllianceMusic_Conditions takes nothing returns boolean
	if ( not ( GetUnitTypeId(GetDyingUnit()) == 'owtw' ) ) then
		return false
	endif
	return true
endfunction

function Trig_AllianceMusic_Func002001 takes nothing returns boolean
	return ( udg_integer47 == 22 )
endfunction

function Trig_AllianceMusic_Actions takes nothing returns nothing
	set udg_integer47=( udg_integer47 + 1 )
	if ( (udg_integer47 == 22) ) then // INLINED!!
		call PlayMusicBJ(udg_string01)
	else
		call DoNothing()
	endif
endfunction

function Trig_HordeMusic_Conditions takes nothing returns boolean
	if ( not ( GetUnitTypeId(GetDyingUnit()) == 'hgtw' ) ) then
		return false
	endif
	return true
endfunction

function Trig_HordeMusic_Func002001 takes nothing returns boolean
	return ( udg_integer48 == 22 )
endfunction

function Trig_HordeMusic_Actions takes nothing returns nothing
	set udg_integer48=( udg_integer48 + 1 )
	if ( (udg_integer48 == 22) ) then // INLINED!!
		call PlayMusicBJ(udg_string01)
	else
		call DoNothing()
	endif
endfunction

function Trig_Command_Short_Mode_Conditions takes nothing returns boolean
	if ( not ( GetClickedButtonBJ() == udg_buttons02[1] ) ) then
		return false
	endif
	return true
endfunction

function Trig_Command_Short_Mode_Func003C takes nothing returns boolean
	if ( not ( udg_boolean05 == true ) ) then
		return false
	endif
	return true
endfunction

function Trig_Command_Short_Mode_Actions takes nothing returns nothing
	if ( Trig_Command_Short_Mode_Func003C() ) then
		call QuestMessageBJ(GetPlayersAll(), bj_QUESTMESSAGE_UPDATED, "TRIGSTR_8818")
	else
		set udg_boolean05=true
		call QuestMessageBJ(GetPlayersAll(), bj_QUESTMESSAGE_DISCOVERED, "TRIGSTR_8819")
		call SetPlayerHandicapXPBJ(Player(0), 150.00)
		call SetPlayerHandicapXPBJ(Player(1), 150.00)
		call SetPlayerHandicapXPBJ(Player(2), 150.00)
		call SetPlayerHandicapXPBJ(Player(3), 150.00)
		call SetPlayerHandicapXPBJ(Player(4), 150.00)
		call SetPlayerHandicapXPBJ(Player(5), 150.00)
		call SetPlayerHandicapXPBJ(Player(6), 150.00)
		call SetPlayerHandicapXPBJ(Player(7), 150.00)
		call SetPlayerHandicapXPBJ(Player(8), 150.00)
		call SetPlayerHandicapXPBJ(Player(9), 150.00)
		call DisableTrigger(udg_trigger28)
		call DestroyTrigger(GetTriggeringTrigger())
	endif
endfunction

function Trig_Command_Ultra_Short_Mode_Conditions takes nothing returns boolean
	if ( not ( GetClickedButtonBJ() == udg_buttons02[2] ) ) then
		return false
	endif
	return true
endfunction

function Trig_Command_Ultra_Short_Mode_Func003C takes nothing returns boolean
	if ( not ( udg_boolean03 == true ) ) then
		return false
	endif
	return true
endfunction

function Trig_Command_Ultra_Short_Mode_Actions takes nothing returns nothing
	if ( Trig_Command_Ultra_Short_Mode_Func003C() ) then
		call QuestMessageBJ(GetPlayersAll(), bj_QUESTMESSAGE_UPDATED, "TRIGSTR_8820")
	else
		set udg_boolean03=true
		call QuestMessageBJ(GetPlayersAll(), bj_QUESTMESSAGE_DISCOVERED, "TRIGSTR_8821")
		call SetPlayerHandicapXPBJ(Player(0), 200.00)
		call SetPlayerHandicapXPBJ(Player(1), 200.00)
		call SetPlayerHandicapXPBJ(Player(2), 200.00)
		call SetPlayerHandicapXPBJ(Player(3), 200.00)
		call SetPlayerHandicapXPBJ(Player(4), 200.00)
		call SetPlayerHandicapXPBJ(Player(5), 200.00)
		call SetPlayerHandicapXPBJ(Player(6), 200.00)
		call SetPlayerHandicapXPBJ(Player(7), 200.00)
		call SetPlayerHandicapXPBJ(Player(8), 200.00)
		call SetPlayerHandicapXPBJ(Player(9), 200.00)
		call DisableTrigger(udg_trigger27)
		call DestroyTrigger(GetTriggeringTrigger())
	endif
endfunction

function Trig_Create_Multiboard_Func002002001001001 takes nothing returns boolean
	return ( GetPlayerController(GetFilterPlayer()) == MAP_CONTROL_USER )
endfunction

function Trig_Create_Multiboard_Func002002001001002 takes nothing returns boolean
	return ( GetPlayerSlotState(GetFilterPlayer()) == PLAYER_SLOT_STATE_PLAYING )
endfunction

function Trig_Create_Multiboard_Func002002001001 takes nothing returns boolean
	return GetBooleanAnd((GetPlayerController(GetFilterPlayer()) == MAP_CONTROL_USER), (GetPlayerSlotState(GetFilterPlayer()) == PLAYER_SLOT_STATE_PLAYING)) // INLINED!!
endfunction

function Trig_Create_Multiboard_Func009001001001 takes nothing returns boolean
	return ( GetPlayerSlotState(GetFilterPlayer()) == PLAYER_SLOT_STATE_PLAYING )
endfunction

function Trig_Create_Multiboard_Func009001001002 takes nothing returns boolean
	return ( GetPlayerController(GetFilterPlayer()) == MAP_CONTROL_USER )
endfunction

function Trig_Create_Multiboard_Func009001001 takes nothing returns boolean
	return GetBooleanAnd((GetPlayerSlotState(GetFilterPlayer()) == PLAYER_SLOT_STATE_PLAYING), (GetPlayerController(GetFilterPlayer()) == MAP_CONTROL_USER)) // INLINED!!
endfunction

function Trig_Create_Multiboard_Func009A takes nothing returns nothing
	set udg_integers01[GetConvertedPlayerId(GetEnumPlayer())]=udg_integer02
	call MultiboardSetItemValueBJ(GetLastCreatedMultiboard(), 1, udg_integer02, ( udg_strings01[GetConvertedPlayerId(GetEnumPlayer())] + ( GetPlayerName(GetEnumPlayer()) + "|r" ) ))
	call MultiboardSetItemValueBJ(GetLastCreatedMultiboard(), 2, udg_integer02, "TRIGSTR_8826")
	call MultiboardSetItemValueBJ(GetLastCreatedMultiboard(), 3, udg_integer02, "TRIGSTR_8827")
	set udg_integer02=( udg_integer02 + 1 )
endfunction

function Trig_Create_Multiboard_Actions takes nothing returns nothing
	set udg_integer01=CountPlayersInForceBJ(GetPlayersMatching(Condition(function Trig_Create_Multiboard_Func002002001001)))
	call CreateMultiboardBJ(3, ( 1 + udg_integer01 ), "TRIGSTR_8822")
	call MultiboardSetItemValueBJ(GetLastCreatedMultiboard(), 1, 1, "TRIGSTR_8823")
	call MultiboardSetItemValueBJ(GetLastCreatedMultiboard(), 2, 1, "TRIGSTR_8824")
	call MultiboardSetItemValueBJ(GetLastCreatedMultiboard(), 3, 1, "TRIGSTR_8825")
	set bj_forLoopAIndex=1
	set bj_forLoopAIndexEnd=( 1 + udg_integer01 )
	loop
		exitwhen bj_forLoopAIndex > bj_forLoopAIndexEnd
		call MultiboardSetItemStyleBJ(GetLastCreatedMultiboard(), 1, 1, true, false)
		call MultiboardSetItemStyleBJ(GetLastCreatedMultiboard(), 1, GetForLoopIndexA(), true, false)
		call MultiboardSetItemStyleBJ(GetLastCreatedMultiboard(), 2, GetForLoopIndexA(), true, false)
		call MultiboardSetItemStyleBJ(GetLastCreatedMultiboard(), 3, GetForLoopIndexA(), true, false)
		call MultiboardSetItemWidthBJ(GetLastCreatedMultiboard(), 1, GetForLoopIndexA(), 8.00)
		call MultiboardSetItemWidthBJ(GetLastCreatedMultiboard(), 2, GetForLoopIndexA(), 7.00)
		call MultiboardSetItemWidthBJ(GetLastCreatedMultiboard(), 3, GetForLoopIndexA(), 5.00)
		set bj_forLoopAIndex=bj_forLoopAIndex + 1
	endloop
	set udg_integer02=2
	call ForForce(GetPlayersMatching(Condition(function Trig_Create_Multiboard_Func009001001)), function Trig_Create_Multiboard_Func009A)
	call MultiboardSetItemColorBJ(GetLastCreatedMultiboard(), 2, 1, 100.00, 100.00, 100.00, 0)
	call MultiboardSetItemColorBJ(GetLastCreatedMultiboard(), 3, 1, 100.00, 100.00, 100.00, 0)
	call MultiboardDisplayBJ(true, GetLastCreatedMultiboard())
endfunction

function Trig_Player_Kills_Upd_Conditions takes nothing returns boolean
	if ( not ( IsUnitType(GetDyingUnit(), UNIT_TYPE_HERO) == true ) ) then
		return false
	endif
	if ( not ( GetPlayerController(GetOwningPlayer(GetKillingUnitBJ())) == MAP_CONTROL_USER ) ) then
		return false
	endif
	return true
endfunction

function Trig_Player_Kills_Upd_Actions takes nothing returns nothing
	set udg_integers02[GetConvertedPlayerId(GetOwningPlayer(GetKillingUnitBJ()))]=( udg_integers02[GetConvertedPlayerId(GetOwningPlayer(GetKillingUnitBJ()))] + 1 )
	call MultiboardSetItemValueBJ(GetLastCreatedMultiboard(), 2, udg_integers01[GetConvertedPlayerId(GetOwningPlayer(GetKillingUnitBJ()))], I2S(udg_integers02[GetConvertedPlayerId(GetOwningPlayer(GetKillingUnitBJ()))]))
endfunction

function Trig_Player_Hero_Death_Func004001 takes nothing returns boolean
	return ( IsUnitType(GetTriggerUnit(), UNIT_TYPE_HERO) == true )
endfunction

function Trig_Player_Hero_Death_Func004002 takes nothing returns boolean
	return ( GetPlayerController(GetOwningPlayer(GetDyingUnit())) == MAP_CONTROL_USER )
endfunction

function Trig_Player_Hero_Death_Conditions takes nothing returns boolean
	if ( not GetBooleanAnd((IsUnitType(GetTriggerUnit(), UNIT_TYPE_HERO) == true), (GetPlayerController(GetOwningPlayer(GetDyingUnit())) == MAP_CONTROL_USER)) ) then // INLINED!!
		return false
	endif
	return true
endfunction

function Trig_Player_Hero_Death_Func003C takes nothing returns boolean
	if ( not ( GetPlayerController(GetOwningPlayer(GetKillingUnitBJ())) != MAP_CONTROL_COMPUTER ) ) then
		return false
	endif
	return true
endfunction

function Trig_Player_Hero_Death_Actions takes nothing returns nothing
	set udg_integers03[GetConvertedPlayerId(GetOwningPlayer(GetDyingUnit()))]=( udg_integers03[GetConvertedPlayerId(GetOwningPlayer(GetDyingUnit()))] + 1 )
	call MultiboardSetItemValueBJ(GetLastCreatedMultiboard(), 3, udg_integers01[GetConvertedPlayerId(GetOwningPlayer(GetDyingUnit()))], I2S(udg_integers03[GetConvertedPlayerId(GetOwningPlayer(GetDyingUnit()))]))
	if ( Trig_Player_Hero_Death_Func003C() ) then
	else
		call DoNothing()
	endif
endfunction

function Trig_Player_leaves_Func001A takes nothing returns nothing
	call UnitDropItemPointLoc(GetTriggerUnit(), UnitItemInSlotBJ(GetTriggerUnit(), 1), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())))
	call UnitDropItemPointLoc(GetTriggerUnit(), UnitItemInSlotBJ(GetTriggerUnit(), 2), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())))
	call UnitDropItemPointLoc(GetTriggerUnit(), UnitItemInSlotBJ(GetTriggerUnit(), 3), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())))
	call UnitDropItemPointLoc(GetTriggerUnit(), UnitItemInSlotBJ(GetTriggerUnit(), 4), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())))
	call UnitDropItemPointLoc(GetTriggerUnit(), UnitItemInSlotBJ(GetTriggerUnit(), 5), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())))
	call UnitDropItemPointLoc(GetTriggerUnit(), UnitItemInSlotBJ(GetTriggerUnit(), 6), GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())))
	call DisplayTextToForce(GetPlayersAll(), ( "|cffFFFF00" + ( GetPlayerName(GetTriggerPlayer()) + "|r has left the game." ) ))
	call PlaySoundBJ(udg_sound03)
	call RemoveUnit(GetEnumUnit())
	call MultiboardSetItemValueBJ(GetLastCreatedMultiboard(), 1, udg_integers01[GetConvertedPlayerId(GetTriggerPlayer())], "TRIGSTR_8828")
	call MultiboardSetItemValueBJ(GetLastCreatedMultiboard(), 2, udg_integers01[GetConvertedPlayerId(GetTriggerPlayer())], "TRIGSTR_8829")
	call MultiboardSetItemValueBJ(GetLastCreatedMultiboard(), 3, udg_integers01[GetConvertedPlayerId(GetTriggerPlayer())], "TRIGSTR_8830")
endfunction

//function Trig_Player_leaves_Actions takes nothing returns nothing
//call ForGroupBJ(GetUnitsOfPlayerAll(GetTriggerPlayer()),function Trig_Player_leaves_Func001A)
//endfunction

function Trig_Player_Colors_Actions takes nothing returns nothing
	set udg_strings01[1]="|c00ff0303"
	set udg_strings01[2]="|c000042ff"
	set udg_strings01[3]="|c001ce6b9"
	set udg_strings01[4]="|c00540081"
	set udg_strings01[5]="|c00fffc01"
	set udg_strings01[6]="|c00ff8000"
	set udg_strings01[7]="|c0020c000"
	set udg_strings01[8]="|c00e55bb0"
	set udg_strings01[9]="|c00959697"
	set udg_strings01[10]="|c007ebff1"
	set udg_strings01[11]="|c00106246"
	set udg_strings01[12]="|c004e2a04"
	set bj_forLoopAIndex=1
	set bj_forLoopAIndexEnd=12
	loop
		exitwhen bj_forLoopAIndex > bj_forLoopAIndexEnd
		set udg_strings03[GetForLoopIndexA()]=( ( udg_strings01[GetForLoopIndexA()] + GetPlayerName(ConvertedPlayer(GetForLoopIndexA())) ) + "|r" )
		set bj_forLoopAIndex=bj_forLoopAIndex + 1
	endloop
endfunction

function Trig_Setup_Players_Func002002001001 takes nothing returns boolean
	return ( GetPlayerController(GetFilterPlayer()) == MAP_CONTROL_USER )
endfunction

function Trig_Setup_Players_Func002002001002 takes nothing returns boolean
	return ( GetPlayerSlotState(GetFilterPlayer()) == PLAYER_SLOT_STATE_PLAYING )
endfunction

function Trig_Setup_Players_Func002002001 takes nothing returns boolean
	return GetBooleanAnd((GetPlayerController(GetFilterPlayer()) == MAP_CONTROL_USER), (GetPlayerSlotState(GetFilterPlayer()) == PLAYER_SLOT_STATE_PLAYING)) // INLINED!!
endfunction

function Trig_Setup_Players_Func003002001001 takes nothing returns boolean
	return ( GetPlayerController(GetFilterPlayer()) == MAP_CONTROL_USER )
endfunction

function Trig_Setup_Players_Func003002001002 takes nothing returns boolean
	return ( GetPlayerSlotState(GetFilterPlayer()) == PLAYER_SLOT_STATE_PLAYING )
endfunction

function Trig_Setup_Players_Func003002001 takes nothing returns boolean
	return GetBooleanAnd((GetPlayerController(GetFilterPlayer()) == MAP_CONTROL_USER), (GetPlayerSlotState(GetFilterPlayer()) == PLAYER_SLOT_STATE_PLAYING)) // INLINED!!
endfunction

function Trig_Setup_Players_Func005A takes nothing returns nothing
	call SetPlayerStateBJ(GetEnumPlayer(), PLAYER_STATE_RESOURCE_FOOD_CAP, 6)
endfunction

function Trig_Setup_Players_Actions takes nothing returns nothing
	set udg_force03=GetPlayersMatching(Condition(function Trig_Setup_Players_Func002002001))
	set udg_force08=GetPlayersMatching(Condition(function Trig_Setup_Players_Func003002001))
	set udg_integer04=CountPlayersInForceBJ(udg_force03)
	call ForForce(udg_force03, function Trig_Setup_Players_Func005A)
	set udg_force04=GetPlayersAllies(Player(11))
	call ForceRemovePlayerSimple(Player(11), udg_force04)
	set udg_integer19=CountPlayersInForceBJ(udg_force04)
	set udg_force06=GetPlayersAllies(Player(11))
	call ForceRemovePlayerSimple(Player(11), udg_force06)
	set udg_force09=GetPlayersAllies(Player(11))
	call ForceRemovePlayerSimple(Player(11), udg_force09)
	set udg_force05=bj_FORCE_PLAYER[10]
	call ForceRemovePlayerSimple(Player(11), udg_force05)
	set udg_integer20=CountPlayersInForceBJ(udg_force05)
	set udg_force07=GetPlayersAllies(Player(10))
	call ForceRemovePlayerSimple(Player(10), udg_force07)
	set udg_force10=GetPlayersAllies(Player(10))
	call ForceRemovePlayerSimple(Player(10), udg_force10)
endfunction

function Trig_Heros_array_Func001A takes nothing returns nothing
	call PanCameraToTimedLocForPlayer(GetTriggerPlayer(), GetPlayerStartLocationLoc(GetTriggerPlayer()), 0)
	call SetPlayerStateBJ(GetEnumPlayer(), PLAYER_STATE_RESOURCE_FOOD_CAP, 6)
endfunction

function Trig_Heros_array_Actions takes nothing returns nothing
	call ForForce(GetPlayersAll(), function Trig_Heros_array_Func001A)
	set udg_integer25=26
	set udg_integer26=26
	set udg_integer38=13
	set udg_integer15=13
	set udg_integer14=14
	set udg_integer39=26
	set udg_integers13[1]='Edem'
	set udg_integers13[2]='Hpal'
	set udg_integers13[3]='Emoo'
	set udg_integers13[4]='Hamg'
	set udg_integers13[5]='Ewar'
	set udg_integers13[6]='Hmkg'
	set udg_integers13[7]='Ekee'
	set udg_integers13[8]='Hblm'
	set udg_integers13[9]='E005'
	set udg_integers13[10]='Hlgr'
	set udg_integers13[11]='Hvwd'
	set udg_integers13[12]='H00G'
	set udg_integers13[13]='O00B'
	set udg_integers13[14]='Ofar'
	set udg_integers13[15]='Udea'
	set udg_integers13[16]='Otch'
	set udg_integers13[17]='Udre'
	set udg_integers13[18]='Oshd'
	set udg_integers13[19]='Ulic'
	set udg_integers13[20]='Ogrh'
	set udg_integers13[21]='Nman'
	set udg_integers13[22]='Nfir'
	set udg_integers13[23]='Usyl'
	set udg_integers13[24]='Ucrl'
	set udg_integers13[25]='Obla'
	set udg_integers13[26]='H00K'
	set bj_forLoopAIndex=1
	set bj_forLoopAIndexEnd=udg_integer25
	loop
		exitwhen bj_forLoopAIndex > bj_forLoopAIndexEnd
		set udg_integers04[GetForLoopIndexA()]=GetForLoopIndexA()
		set bj_forLoopAIndex=bj_forLoopAIndex + 1
	endloop
	set bj_forLoopAIndex=1
	set bj_forLoopAIndexEnd=udg_integer15
	loop
		exitwhen bj_forLoopAIndex > bj_forLoopAIndexEnd
		set udg_integers10[GetForLoopIndexA()]=GetForLoopIndexA()
		set bj_forLoopAIndex=bj_forLoopAIndex + 1
	endloop
	set bj_forLoopAIndex=14
	set bj_forLoopAIndexEnd=udg_integer25
	loop
		exitwhen bj_forLoopAIndex > bj_forLoopAIndexEnd
		set udg_integers09[GetForLoopIndexA()]=GetForLoopIndexA()
		set bj_forLoopAIndex=bj_forLoopAIndex + 1
	endloop
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Team_Random_Command_Conditions takes nothing returns boolean
	if ( not ( GetClickedButtonBJ() == udg_buttons03[2] ) ) then
		return false
	endif
	return true
endfunction

function Trig_Team_Random_Command_Func006Func001C takes nothing returns boolean
	if ( not ( GetPlayerSlotState(ConvertedPlayer(GetForLoopIndexA())) == PLAYER_SLOT_STATE_PLAYING ) ) then
		return false
	endif
	return true
endfunction

function Trig_Team_Random_Command_Func007Func001C takes nothing returns boolean
	if ( not ( GetPlayerSlotState(ConvertedPlayer(GetForLoopIndexA())) == PLAYER_SLOT_STATE_PLAYING ) ) then
		return false
	endif
	return true
endfunction

function Trig_Team_Random_Command_Actions takes nothing returns nothing
	call QuestMessageBJ(GetPlayersAll(), bj_QUESTMESSAGE_UPDATED, "TRIGSTR_8831")
	call DisableTrigger(udg_trigger37)
	call DisableTrigger(udg_trigger36)
	set bj_forLoopAIndex=1
	set bj_forLoopAIndexEnd=5
	loop
		exitwhen bj_forLoopAIndex > bj_forLoopAIndexEnd
		if ( Trig_Team_Random_Command_Func006Func001C() ) then
			set udg_integer12=GetRandomInt(1, udg_integer38)
			call CreateNUnitsAtLoc(1, udg_integers13[udg_integers10[udg_integer12]], ConvertedPlayer(GetForLoopIndexA()), GetPlayerStartLocationLoc(ConvertedPlayer(GetForLoopIndexA())), bj_UNIT_FACING)
			call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
			call DisplayTextToForce(GetPlayersAll(), ( ( GetPlayerName(GetTriggerPlayer()) + " Has Randomed the hero " ) + GetUnitName(GetLastCreatedUnit()) ))
			set udg_integers10[udg_integer12]=udg_integers10[udg_integer38]
			set udg_integer38=( udg_integer38 - 1 )
		else
			call DoNothing()
		endif
		set bj_forLoopAIndex=bj_forLoopAIndex + 1
	endloop
	set bj_forLoopAIndex=6
	set bj_forLoopAIndexEnd=10
	loop
		exitwhen bj_forLoopAIndex > bj_forLoopAIndexEnd
		if ( Trig_Team_Random_Command_Func007Func001C() ) then
			set udg_integer27=GetRandomInt(14, udg_integer26)
			call CreateNUnitsAtLoc(1, udg_integers13[udg_integers09[udg_integer27]], ConvertedPlayer(GetForLoopIndexA()), GetPlayerStartLocationLoc(ConvertedPlayer(GetForLoopIndexA())), bj_UNIT_FACING)
			call SelectUnitForPlayerSingle(GetLastCreatedUnit(), GetOwningPlayer(GetLastCreatedUnit()))
			call DisplayTextToForce(GetPlayersAll(), ( ( GetPlayerName(GetTriggerPlayer()) + " Has Randomed the hero " ) + GetUnitName(GetLastCreatedUnit()) ))
			set udg_integers09[udg_integer27]=udg_integers09[udg_integer26]
			set udg_integer26=( udg_integer26 - 1 )
		else
			call DoNothing()
		endif
		set bj_forLoopAIndex=bj_forLoopAIndex + 1
	endloop
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_AllPick_Conditions takes nothing returns boolean
	if ( not ( GetClickedButtonBJ() == udg_buttons03[1] ) ) then
		return false
	endif
	return true
endfunction

function Trig_AllPick_Actions takes nothing returns nothing
	call DisplayTextToForce(GetPlayersAll(), "TRIGSTR_8832")
	call PanCameraToTimedLocForPlayer(Player(0), GetRectCenter(udg_rect18), 1.00)
	call PanCameraToTimedLocForPlayer(Player(1), GetRectCenter(udg_rect18), 1.00)
	call PanCameraToTimedLocForPlayer(Player(2), GetRectCenter(udg_rect18), 1.00)
	call PanCameraToTimedLocForPlayer(Player(3), GetRectCenter(udg_rect18), 1.00)
	call PanCameraToTimedLocForPlayer(Player(4), GetRectCenter(udg_rect18), 1.00)
	call PanCameraToTimedLocForPlayer(Player(5), GetRectCenter(udg_rect28), 1.00)
	call PanCameraToTimedLocForPlayer(Player(6), GetRectCenter(udg_rect28), 1.00)
	call PanCameraToTimedLocForPlayer(Player(7), GetRectCenter(udg_rect28), 1.00)
	call PanCameraToTimedLocForPlayer(Player(8), GetRectCenter(udg_rect28), 1.00)
	call PanCameraToTimedLocForPlayer(Player(9), GetRectCenter(udg_rect28), 1.00)
	call DisableTrigger(GetTriggeringTrigger())
	call DisableTrigger(udg_trigger36)
	call DoNothing()
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Clear_Wisps_y_Almas_Corruptas_allrandom_Conditions takes nothing returns boolean
	if ( not ( GetClickedButtonBJ() == udg_buttons03[2] ) ) then
		return false
	endif
	return true
endfunction

function Trig_Clear_Wisps_y_Almas_Corruptas_allrandom_Actions takes nothing returns nothing
	call ExplodeUnitBJ(udg_unit14)
	call ExplodeUnitBJ(udg_unit15)
	call ExplodeUnitBJ(udg_unit16)
	call ExplodeUnitBJ(udg_unit17)
	call ExplodeUnitBJ(udg_unit18)
	call ExplodeUnitBJ(udg_unit39)
	call ExplodeUnitBJ(udg_unit40)
	call ExplodeUnitBJ(udg_unit41)
	call ExplodeUnitBJ(udg_unit42)
	call ExplodeUnitBJ(udg_unit43)
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Camara_allpick_Actions takes nothing returns nothing
	call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetTriggerUnit()), GetUnitLoc(GetTriggerUnit()), 1.00)
	call DisableTrigger(GetTriggeringTrigger())
	call EnableTrigger(udg_trigger40)
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Camara_Conditions takes nothing returns boolean
	if ( not ( IsUnitType(GetTriggerUnit(), UNIT_TYPE_HERO) == true ) ) then
		return false
	endif
	return true
endfunction

function Trig_Camara_Actions takes nothing returns nothing
	call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetTriggerUnit()), GetUnitLoc(GetTriggerUnit()), 1.00)
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Vulnerability_Actions takes nothing returns nothing
	call UnitAddAbilityBJ('A032', udg_unit19)
	call UnitAddAbilityBJ('A032', udg_unit24)
	call DisplayTextToForce(GetPlayersAll(), "TRIGSTR_8833")
	call SetUnitInvulnerable(udg_unit19, true)
	call SetUnitInvulnerable(udg_unit24, true)
endfunction

function Trig_Alliance_Base_Conditions takes nothing returns boolean
	if ( not ( GetUnitTypeId(GetDyingUnit()) == 'etrp' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Alliance_Base_Func002C takes nothing returns boolean
	if ( not ( udg_integer08 == 9 ) ) then
		return false
	endif.0
	return true
endfunction

function Trig_Alliance_Base_Actions takes nothing returns nothing
	set udg_integer08=( udg_integer08 + 1 )
	if ( Trig_Alliance_Base_Func002C() ) then
		call SetUnitInvulnerable(udg_unit19, false)
		call UnitRemoveAbilityBJ('A032', udg_unit19)
		call QuestMessageBJ(GetPlayersAll(), bj_QUESTMESSAGE_UPDATED, "TRIGSTR_8834")
		call DisableTrigger(GetTriggeringTrigger())
	else
	endif
endfunction

function Trig_Orc_Base_Conditions takes nothing returns boolean
	if ( not ( GetUnitTypeId(GetDyingUnit()) == 'uzg1' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Orc_Base_Func002C takes nothing returns boolean
	if ( not ( udg_integer07 == 9 ) ) then
		return false
	endif
	return true
endfunction

function Trig_Orc_Base_Actions takes nothing returns nothing
	set udg_integer07=( udg_integer07 + 1 )
	if ( Trig_Orc_Base_Func002C() ) then
		call SetUnitInvulnerable(udg_unit24, false)
		call UnitRemoveAbilityBJ('A032', udg_unit24)
		call QuestMessageBJ(GetPlayersAll(), bj_QUESTMESSAGE_UPDATED, "TRIGSTR_8835")
		call DisableTrigger(GetTriggeringTrigger())
	else
	endif
endfunction

function Trig_Human_Footmen_Conditions takes nothing returns boolean
	if ( not ( GetUnitStateSwap(UNIT_STATE_LIFE, udg_unit23) > 0.00 ) ) then
		return false
	endif
	return true
endfunction

function Trig_Human_Footmen_Actions takes nothing returns nothing
	call CreateNUnitsAtLoc(4, 'h000', Player(10), GetRectCenter(udg_rect19), bj_UNIT_FACING)
endfunction

function Trig_Human_Riflemen_Conditions takes nothing returns boolean
	if ( not ( GetUnitStateSwap(UNIT_STATE_LIFE, udg_unit23) > 0.00 ) ) then
		return false
	endif
	return true
endfunction

function Trig_Human_Riflemen_Actions takes nothing returns nothing
	call CreateNUnitsAtLoc(2, 'h001', Player(10), GetRectCenter(udg_rect19), bj_UNIT_FACING)
endfunction

function Trig_Human_Mountan_Giant_Conditions takes nothing returns boolean
	if ( not ( GetUnitStateSwap(UNIT_STATE_LIFE, udg_unit22) > 0.00 ) ) then
		return false
	endif
	return true
endfunction

function Trig_Human_Mountan_Giant_Actions takes nothing returns nothing
	call CreateNUnitsAtLoc(1, 'h009', Player(10), GetRectCenter(udg_rect20), bj_UNIT_FACING)
endfunction

function Trig_Human_Huntress_Conditions takes nothing returns boolean
	if ( not ( GetUnitStateSwap(UNIT_STATE_LIFE, udg_unit21) > 0.00 ) ) then
		return false
	endif
	return true
endfunction

function Trig_Human_Huntress_Actions takes nothing returns nothing
	call CreateNUnitsAtLoc(2, 'h006', Player(10), GetRectCenter(udg_rect21), bj_UNIT_FACING)
endfunction

function Trig_Human_Archer_Conditions takes nothing returns boolean
	if ( not ( GetUnitStateSwap(UNIT_STATE_LIFE, udg_unit21) > 0.00 ) ) then
		return false
	endif
	return true
endfunction

function Trig_Human_Archer_Actions takes nothing returns nothing
	call CreateNUnitsAtLoc(4, 'h007', Player(10), GetRectCenter(udg_rect22), bj_UNIT_FACING)
endfunction

function Trig_Human_Mountain_Giant_Conditions takes nothing returns boolean
	if ( not ( GetUnitStateSwap(UNIT_STATE_LIFE, udg_unit20) > 0.00 ) ) then
		return false
	endif
	return true
endfunction

function Trig_Human_Mountain_Giant_Actions takes nothing returns nothing
	call CreateNUnitsAtLoc(1, 'h009', Player(10), GetRectCenter(udg_rect22), bj_UNIT_FACING)
endfunction

function Trig_Orcs_Ghoul_Conditions takes nothing returns boolean
	if ( not ( GetUnitStateSwap(UNIT_STATE_LIFE, udg_unit27) > 0.00 ) ) then
		return false
	endif
	return true
endfunction

function Trig_Orcs_Ghoul_Actions takes nothing returns nothing
	call CreateNUnitsAtLoc(4, 'o000', Player(11), GetRectCenter(udg_rect29), bj_UNIT_FACING)
endfunction

function Trig_Orcs_Necremancer_Conditions takes nothing returns boolean
	if ( not ( GetUnitStateSwap(UNIT_STATE_LIFE, udg_unit27) > 0.00 ) ) then
		return false
	endif
	return true
endfunction

function Trig_Orcs_Necremancer_Actions takes nothing returns nothing
	call CreateNUnitsAtLoc(2, 'o001', Player(11), GetRectCenter(udg_rect29), bj_UNIT_FACING)
endfunction

function Trig_Orcs_Tauren_Conditions takes nothing returns boolean
	if ( not ( GetUnitStateSwap(UNIT_STATE_LIFE, udg_unit28) > 0.00 ) ) then
		return false
	endif
	return true
endfunction

function Trig_Orcs_Tauren_Actions takes nothing returns nothing
	call CreateNUnitsAtLoc(1, 'o002', Player(11), GetRectCenter(udg_rect30), bj_UNIT_FACING)
endfunction

function Trig_Orcs_Tauren_de_abajo_Conditions takes nothing returns boolean
	if ( not ( GetUnitStateSwap(UNIT_STATE_LIFE, udg_unit26) > 0.00 ) ) then
		return false
	endif
	return true
endfunction

function Trig_Orcs_Tauren_de_abajo_Actions takes nothing returns nothing
	call CreateNUnitsAtLoc(1, 'o008', Player(11), GetRectCenter(udg_rect31), bj_UNIT_FACING)
endfunction

function Trig_Orcs_Grunts_Conditions takes nothing returns boolean
	if ( not ( GetUnitStateSwap(UNIT_STATE_LIFE, udg_unit25) > 0.00 ) ) then
		return false
	endif
	return true
endfunction

function Trig_Orcs_Grunts_Actions takes nothing returns nothing
	call CreateNUnitsAtLoc(4, 'o007', Player(11), GetRectCenter(udg_rect32), bj_UNIT_FACING)
endfunction

function Trig_Orcs_Shamans_Conditions takes nothing returns boolean
	if ( not ( GetUnitStateSwap(UNIT_STATE_LIFE, udg_unit25) > 0.00 ) ) then
		return false
	endif
	return true
endfunction

function Trig_Orcs_Shamans_Actions takes nothing returns nothing
	call CreateNUnitsAtLoc(2, 'o009', Player(11), GetRectCenter(udg_rect32), bj_UNIT_FACING)
endfunction

function Trig_Magnadefender_Conditions takes nothing returns boolean
	if ( not ( GetUnitTypeId(GetEnteringUnit()) == 'ewsp' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Magnadefender_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1, 'O00B', GetOwningPlayer(GetEnteringUnit()), GetRectCenter(udg_rect23), bj_UNIT_FACING)
	call KillUnit(udg_unit45)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Magic_Gladiator_Conditions takes nothing returns boolean
	if ( not ( GetUnitTypeId(GetEnteringUnit()) == 'ewsp' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Magic_Gladiator_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1, 'H00G', GetOwningPlayer(GetEnteringUnit()), GetRectCenter(udg_rect23), bj_UNIT_FACING)
	call KillUnit(udg_unit46)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Demon_Hunter_Conditions takes nothing returns boolean
	if ( not ( GetUnitTypeId(GetEnteringUnit()) == 'ewsp' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Demon_Hunter_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1, 'Edem', GetOwningPlayer(GetEnteringUnit()), GetRectCenter(udg_rect23), bj_UNIT_FACING)
	call KillUnit(udg_unit06)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Priestess_of_the_Moon_Conditions takes nothing returns boolean
	if ( not ( GetUnitTypeId(GetEnteringUnit()) == 'ewsp' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Priestess_of_the_Moon_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1, 'Emoo', GetOwningPlayer(GetEnteringUnit()), GetRectCenter(udg_rect23), bj_UNIT_FACING)
	call KillUnit(udg_unit12)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Warden_Conditions takes nothing returns boolean
	if ( not ( GetUnitTypeId(GetEnteringUnit()) == 'ewsp' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Warden_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1, 'Ewar', GetOwningPlayer(GetEnteringUnit()), GetRectCenter(udg_rect23), bj_UNIT_FACING)
	call KillUnit(udg_unit09)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Keeper_of_the_Groove_Conditions takes nothing returns boolean
	if ( not ( GetUnitTypeId(GetEnteringUnit()) == 'ewsp' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Keeper_of_the_Groove_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1, 'Ekee', GetOwningPlayer(GetEnteringUnit()), GetRectCenter(udg_rect23), bj_UNIT_FACING)
	call KillUnit(udg_unit08)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Asesina_Conditions takes nothing returns boolean
	if ( not ( GetUnitTypeId(GetEnteringUnit()) == 'ewsp' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Asesina_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1, 'E005', GetOwningPlayer(GetEnteringUnit()), GetRectCenter(udg_rect23), bj_UNIT_FACING)
	call KillUnit(udg_unit11)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Paladin_Conditions takes nothing returns boolean
	if ( not ( GetUnitTypeId(GetEnteringUnit()) == 'ewsp' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Paladin_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1, 'Hpal', GetOwningPlayer(GetEnteringUnit()), GetRectCenter(udg_rect23), bj_UNIT_FACING)
	call KillUnit(udg_unit07)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Archmage_Conditions takes nothing returns boolean
	if ( not ( GetUnitTypeId(GetEnteringUnit()) == 'ewsp' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Archmage_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1, 'Hamg', GetOwningPlayer(GetEnteringUnit()), GetRectCenter(udg_rect23), bj_UNIT_FACING)
	call KillUnit(udg_unit03)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Mountain_King_Conditions takes nothing returns boolean
	if ( not ( GetUnitTypeId(GetEnteringUnit()) == 'ewsp' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Mountain_King_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1, 'Hmkg', GetOwningPlayer(GetEnteringUnit()), GetRectCenter(udg_rect23), bj_UNIT_FACING)
	call KillUnit(udg_unit04)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Blood_Mage_Conditions takes nothing returns boolean
	if ( not ( GetUnitTypeId(GetEnteringUnit()) == 'ewsp' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Blood_Mage_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1, 'Hblm', GetOwningPlayer(GetEnteringUnit()), GetRectCenter(udg_rect23), bj_UNIT_FACING)
	call KillUnit(udg_unit05)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Lord_Gharitos_Conditions takes nothing returns boolean
	if ( not ( GetUnitTypeId(GetEnteringUnit()) == 'ewsp' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Lord_Gharitos_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1, 'Hlgr', GetOwningPlayer(GetEnteringUnit()), GetRectCenter(udg_rect23), bj_UNIT_FACING)
	call KillUnit(udg_unit13)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Ranger_Conditions takes nothing returns boolean
	if ( not ( GetUnitTypeId(GetEnteringUnit()) == 'ewsp' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Ranger_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1, 'Hvwd', GetOwningPlayer(GetEnteringUnit()), GetRectCenter(udg_rect23), bj_UNIT_FACING)
	call KillUnit(udg_unit10)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Blademaster_Conditions takes nothing returns boolean
	if ( not ( GetUnitTypeId(GetEnteringUnit()) == 'e006' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Blademaster_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1, 'Obla', GetOwningPlayer(GetEnteringUnit()), GetRectCenter(udg_rect33), bj_UNIT_FACING)
	call KillUnit(udg_unit38)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Far_Seer_Conditions takes nothing returns boolean
	if ( not ( GetUnitTypeId(GetEnteringUnit()) == 'e006' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Far_Seer_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1, 'Ofar', GetOwningPlayer(GetEnteringUnit()), GetRectCenter(udg_rect33), bj_UNIT_FACING)
	call KillUnit(udg_unit31)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Tauren_Chieftain_Conditions takes nothing returns boolean
	if ( not ( GetUnitTypeId(GetEnteringUnit()) == 'e006' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Tauren_Chieftain_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1, 'Otch', GetOwningPlayer(GetEnteringUnit()), GetRectCenter(udg_rect33), bj_UNIT_FACING)
	call KillUnit(udg_unit37)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Shadow_Hunter_Conditions takes nothing returns boolean
	if ( not ( GetUnitTypeId(GetEnteringUnit()) == 'e006' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Shadow_Hunter_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1, 'Oshd', GetOwningPlayer(GetEnteringUnit()), GetRectCenter(udg_rect33), bj_UNIT_FACING)
	call KillUnit(udg_unit30)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Warsong_Chieftain_Conditions takes nothing returns boolean
	if ( not ( GetUnitTypeId(GetEnteringUnit()) == 'e006' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Warsong_Chieftain_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1, 'Ogrh', GetOwningPlayer(GetEnteringUnit()), GetRectCenter(udg_rect33), bj_UNIT_FACING)
	call KillUnit(udg_unit47)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Crypt_Lord_Conditions takes nothing returns boolean
	if ( not ( GetUnitTypeId(GetEnteringUnit()) == 'e006' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Crypt_Lord_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1, 'Ucrl', GetOwningPlayer(GetEnteringUnit()), GetRectCenter(udg_rect33), bj_UNIT_FACING)
	call KillUnit(udg_unit32)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Death_Knight_Conditions takes nothing returns boolean
	if ( not ( GetUnitTypeId(GetEnteringUnit()) == 'e006' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Death_Knight_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1, 'Udea', GetOwningPlayer(GetEnteringUnit()), GetRectCenter(udg_rect33), bj_UNIT_FACING)
	call KillUnit(udg_unit29)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Dreadlord_Conditions takes nothing returns boolean
	if ( not ( GetUnitTypeId(GetEnteringUnit()) == 'e006' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Dreadlord_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1, 'Udre', GetOwningPlayer(GetEnteringUnit()), GetRectCenter(udg_rect33), bj_UNIT_FACING)
	call KillUnit(udg_unit33)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Lich_Conditions takes nothing returns boolean
	if ( not ( GetUnitTypeId(GetEnteringUnit()) == 'e006' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Lich_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1, 'Ulic', GetOwningPlayer(GetEnteringUnit()), GetRectCenter(udg_rect33), bj_UNIT_FACING)
	call KillUnit(udg_unit34)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Nigromante_Conditions takes nothing returns boolean
	if ( not ( GetUnitTypeId(GetEnteringUnit()) == 'e006' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Nigromante_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1, 'Nman', GetOwningPlayer(GetEnteringUnit()), GetRectCenter(udg_rect33), bj_UNIT_FACING)
	call KillUnit(udg_unit35)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Firelord_Conditions takes nothing returns boolean
	if ( not ( GetUnitTypeId(GetEnteringUnit()) == 'e006' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Firelord_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1, 'Nfir', GetOwningPlayer(GetEnteringUnit()), GetRectCenter(udg_rect33), bj_UNIT_FACING)
	call KillUnit(udg_unit36)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Dark_Ranger_Conditions takes nothing returns boolean
	if ( not ( GetUnitTypeId(GetEnteringUnit()) == 'e006' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Dark_Ranger_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1, 'Usyl', GetOwningPlayer(GetEnteringUnit()), GetRectCenter(udg_rect33), bj_UNIT_FACING)
	call KillUnit(udg_unit44)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Storm_Conditions takes nothing returns boolean
	if ( not ( GetUnitTypeId(GetEnteringUnit()) == 'e006' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Storm_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1, 'H00K', GetOwningPlayer(GetEnteringUnit()), GetRectCenter(udg_rect33), bj_UNIT_FACING)
	call KillUnit(udg_unit48)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Revive_Human_hero_player_1_Conditions takes nothing returns boolean
	if ( not ( IsUnitType(GetDyingUnit(), UNIT_TYPE_HERO) == true ) ) then
		return false
	endif
	return true
endfunction

function Trig_Revive_Human_hero_player_1_Actions takes nothing returns nothing
	set udg_real01=( udg_real02 + ( I2R(GetHeroLevel(GetTriggerUnit())) * 3.00 ) )
	call CreateTimerDialogBJ(udg_timer02, GetPlayerName(GetTriggerPlayer()))
	set udg_timerdialog03=GetLastCreatedTimerDialogBJ()
	call StartTimerBJ(udg_timer02, false, udg_real01)
	call TriggerSleepAction(udg_real01)
	call DestroyTimerDialogBJ(udg_timerdialog03)
	call ReviveHeroLoc(GetTriggerUnit(), GetRectCenter(udg_rect12), true)
endfunction

function Trig_Revive_Human_hero_player_2_Conditions takes nothing returns boolean
	if ( not ( IsUnitType(GetDyingUnit(), UNIT_TYPE_HERO) == true ) ) then
		return false
	endif
	return true
endfunction

function Trig_Revive_Human_hero_player_2_Actions takes nothing returns nothing
	set udg_real01=( udg_real02 + ( I2R(GetHeroLevel(GetTriggerUnit())) * 3.00 ) )
	call CreateTimerDialogBJ(udg_timer03, GetPlayerName(GetTriggerPlayer()))
	set udg_timerdialog04=GetLastCreatedTimerDialogBJ()
	call StartTimerBJ(udg_timer03, false, udg_real01)
	call TriggerSleepAction(udg_real01)
	call DestroyTimerDialogBJ(udg_timerdialog04)
	call ReviveHeroLoc(GetTriggerUnit(), GetRectCenter(udg_rect12), true)
endfunction

function Trig_Revive_Human_hero_player_3_Conditions takes nothing returns boolean
	if ( not ( IsUnitType(GetDyingUnit(), UNIT_TYPE_HERO) == true ) ) then
		return false
	endif
	return true
endfunction

function Trig_Revive_Human_hero_player_3_Actions takes nothing returns nothing
	set udg_real01=( udg_real02 + ( I2R(GetHeroLevel(GetTriggerUnit())) * 3.00 ) )
	call CreateTimerDialogBJ(udg_timer04, GetPlayerName(GetTriggerPlayer()))
	set udg_timerdialog05=GetLastCreatedTimerDialogBJ()
	call StartTimerBJ(udg_timer04, false, udg_real01)
	call TriggerSleepAction(udg_real01)
	call DestroyTimerDialogBJ(udg_timerdialog05)
	call ReviveHeroLoc(GetTriggerUnit(), GetRectCenter(udg_rect13), true)
endfunction

function Trig_Revive_Human_hero_player_4_Conditions takes nothing returns boolean
	if ( not ( IsUnitType(GetDyingUnit(), UNIT_TYPE_HERO) == true ) ) then
		return false
	endif
	return true
endfunction

function Trig_Revive_Human_hero_player_4_Actions takes nothing returns nothing
	set udg_real01=( udg_real02 + ( I2R(GetHeroLevel(GetTriggerUnit())) * 3.00 ) )
	call CreateTimerDialogBJ(udg_timer05, GetPlayerName(GetTriggerPlayer()))
	set udg_timerdialog12=GetLastCreatedTimerDialogBJ()
	call StartTimerBJ(udg_timer05, false, udg_real01)
	call TriggerSleepAction(udg_real01)
	call DestroyTimerDialogBJ(udg_timerdialog12)
	call ReviveHeroLoc(GetTriggerUnit(), GetRectCenter(udg_rect13), true)
endfunction

function Trig_Revive_Human_hero_player_5_Conditions takes nothing returns boolean
	if ( not ( IsUnitType(GetDyingUnit(), UNIT_TYPE_HERO) == true ) ) then
		return false
	endif
	return true
endfunction

function Trig_Revive_Human_hero_player_5_Actions takes nothing returns nothing
	set udg_real01=( udg_real02 + ( I2R(GetHeroLevel(GetTriggerUnit())) * 3.00 ) )
	call CreateTimerDialogBJ(udg_timer06, GetPlayerName(GetTriggerPlayer()))
	set udg_timerdialog07=GetLastCreatedTimerDialogBJ()
	call StartTimerBJ(udg_timer06, false, udg_real01)
	call TriggerSleepAction(udg_real01)
	call DestroyTimerDialogBJ(udg_timerdialog07)
	call ReviveHeroLoc(GetTriggerUnit(), GetRectCenter(udg_rect13), true)
endfunction

function Trig_Revive_Orc_hero_player_6_Conditions takes nothing returns boolean
	if ( not ( IsUnitType(GetDyingUnit(), UNIT_TYPE_HERO) == true ) ) then
		return false
	endif
	return true
endfunction

function Trig_Revive_Orc_hero_player_6_Actions takes nothing returns nothing
	set udg_real01=( udg_real02 + ( I2R(GetHeroLevel(GetTriggerUnit())) * 3.00 ) )
	call CreateTimerDialogBJ(udg_timer07, GetPlayerName(GetTriggerPlayer()))
	set udg_timerdialog06=GetLastCreatedTimerDialogBJ()
	call StartTimerBJ(udg_timer07, false, udg_real01)
	call TriggerSleepAction(udg_real01)
	call DestroyTimerDialogBJ(udg_timerdialog06)
	call ReviveHeroLoc(GetTriggerUnit(), GetRectCenter(udg_rect15), true)
endfunction

function Trig_Revive_Orc_hero_player_7_Conditions takes nothing returns boolean
	if ( not ( IsUnitType(GetDyingUnit(), UNIT_TYPE_HERO) == true ) ) then
		return false
	endif
	return true
endfunction

function Trig_Revive_Orc_hero_player_7_Actions takes nothing returns nothing
	set udg_real01=( udg_real02 + ( I2R(GetHeroLevel(GetTriggerUnit())) * 3.00 ) )
	call CreateTimerDialogBJ(udg_timer08, GetPlayerName(GetTriggerPlayer()))
	set udg_timerdialog10=GetLastCreatedTimerDialogBJ()
	call StartTimerBJ(udg_timer08, false, udg_real01)
	call TriggerSleepAction(udg_real01)
	call DestroyTimerDialogBJ(udg_timerdialog10)
	call ReviveHeroLoc(GetTriggerUnit(), GetRectCenter(udg_rect15), true)
endfunction

function Trig_Revive_Orc_hero_player_8_Conditions takes nothing returns boolean
	if ( not ( IsUnitType(GetDyingUnit(), UNIT_TYPE_HERO) == true ) ) then
		return false
	endif
	return true
endfunction

function Trig_Revive_Orc_hero_player_8_Actions takes nothing returns nothing
	set udg_real01=( udg_real02 + ( I2R(GetHeroLevel(GetTriggerUnit())) * 3.00 ) )
	call CreateTimerDialogBJ(udg_timer09, GetPlayerName(GetTriggerPlayer()))
	set udg_timerdialog09=GetLastCreatedTimerDialogBJ()
	call StartTimerBJ(udg_timer09, false, udg_real01)
	call TriggerSleepAction(udg_real01)
	call DestroyTimerDialogBJ(udg_timerdialog09)
	call ReviveHeroLoc(GetTriggerUnit(), GetRectCenter(udg_rect16), true)
endfunction

function Trig_Revive_Orc_hero_player_9_Conditions takes nothing returns boolean
	if ( not ( IsUnitType(GetDyingUnit(), UNIT_TYPE_HERO) == true ) ) then
		return false
	endif
	return true
endfunction

function Trig_Revive_Orc_hero_player_9_Actions takes nothing returns nothing
	set udg_real01=( udg_real02 + ( I2R(GetHeroLevel(GetTriggerUnit())) * 3.00 ) )
	call CreateTimerDialogBJ(udg_timer10, GetPlayerName(GetTriggerPlayer()))
	set udg_timerdialog08=GetLastCreatedTimerDialogBJ()
	call StartTimerBJ(udg_timer10, false, udg_real01)
	call TriggerSleepAction(udg_real01)
	call DestroyTimerDialogBJ(udg_timerdialog08)
	call ReviveHeroLoc(GetTriggerUnit(), GetRectCenter(udg_rect16), true)
endfunction

function Trig_Revive_Orc_hero_player_10_Conditions takes nothing returns boolean
	if ( not ( IsUnitType(GetDyingUnit(), UNIT_TYPE_HERO) == true ) ) then
		return false
	endif
	return true
endfunction

function Trig_Revive_Orc_hero_player_10_Actions takes nothing returns nothing
	set udg_real01=( udg_real02 + ( I2R(GetHeroLevel(GetTriggerUnit())) * 3.00 ) )
	call CreateTimerDialogBJ(udg_timer11, GetPlayerName(GetTriggerPlayer()))
	set udg_timerdialog11=GetLastCreatedTimerDialogBJ()
	call StartTimerBJ(udg_timer11, false, udg_real01)
	call TriggerSleepAction(udg_real01)
	call DestroyTimerDialogBJ(udg_timerdialog11)
	call ReviveHeroLoc(GetTriggerUnit(), GetRectCenter(udg_rect16), true)
endfunction

function Trig_Blademaster_Invul_Blade_Conditions takes nothing returns boolean
	if ( not ( GetSpellAbilityId() == 'AOww' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Blademaster_Invul_Blade_Actions takes nothing returns nothing
	call SetUnitInvulnerable(GetTriggerUnit(), true)
	call TriggerSleepAction(7.00)
	call SetUnitInvulnerable(GetTriggerUnit(), false)
endfunction

function Trig_Help_Actions takes nothing returns nothing
	call CreateQuestBJ(bj_QUESTTYPE_REQ_DISCOVERED, "TRIGSTR_8836", "TRIGSTR_8837", "ReplaceableTextures\\PassiveButtons\\PASBTNStatUp.blp")
	call CreateQuestBJ(bj_QUESTTYPE_REQ_DISCOVERED, "TRIGSTR_8838", "TRIGSTR_8839", "ReplaceableTextures\\CommandButtons\\BTNAvatarOff.blp")
	call CreateQuestBJ(bj_QUESTTYPE_REQ_DISCOVERED, "TRIGSTR_8840", "TRIGSTR_8841", "ReplaceableTextures\\CommandButtons\\BTNDruidOfTheClaw.blp")
	call CreateQuestBJ(bj_QUESTTYPE_OPT_DISCOVERED, "TRIGSTR_8842", "TRIGSTR_8843", "ReplaceableTextures\\CommandButtons\\BTNScrollUber.blp")
endfunction

function Trig_Matchup_Func001002002 takes nothing returns boolean
	return ( IsUnitType(GetFilterUnit(), UNIT_TYPE_HERO) == true )
endfunction

function Trig_Matchup_Func002Func001C takes nothing returns boolean
	if ( not ( IsPlayerEnemy(GetOwningPlayer(GetEnumUnit()), GetTriggerPlayer()) == true ) ) then
		return false
	endif
	return true
endfunction

function Trig_Matchup_Func002A takes nothing returns nothing
	if ( Trig_Matchup_Func002Func001C() ) then
		call DisplayTextToForce(GetForceOfPlayer(GetTriggerPlayer()), ( udg_strings03[GetConvertedPlayerId(GetOwningPlayer(GetEnumUnit()))] + ( " controls " + GetUnitName(GetEnumUnit()) ) ))
	else
	endif
endfunction

function Trig_Matchup_Actions takes nothing returns nothing
	set udg_group02=GetUnitsInRectMatching(GetPlayableMapRect(), Condition(function Trig_Matchup_Func001002002))
	call ForGroupBJ(udg_group02, function Trig_Matchup_Func002A)
endfunction

function Trig_Movespeed_Func001002002 takes nothing returns boolean
	return ( IsUnitType(GetFilterUnit(), UNIT_TYPE_HERO) == true )
endfunction

function Trig_Movespeed_Func002A takes nothing returns nothing
	call DisplayTextToForce(GetForceOfPlayer(GetTriggerPlayer()), ( udg_strings01[GetConvertedPlayerId(GetTriggerPlayer())] + ( GetUnitName(GetEnumUnit()) + ( "|r movement speed is " + R2SW(GetUnitMoveSpeed(GetEnumUnit()), 4, 3) ) ) ))
endfunction

function Trig_Movespeed_Actions takes nothing returns nothing
	set udg_group02=GetUnitsOfPlayerMatching(GetTriggerPlayer(), Condition(function Trig_Movespeed_Func001002002))
	call ForGroupBJ(udg_group02, function Trig_Movespeed_Func002A)
endfunction

function Trig_Item_Drop_Humanos_Func003A takes nothing returns nothing
	set bj_forLoopAIndex=1
	set bj_forLoopAIndexEnd=6
	loop
		exitwhen bj_forLoopAIndex > bj_forLoopAIndexEnd
		call CreateItemLoc(GetItemTypeId(UnitItemInSlotBJ(GetEnumUnit(), GetForLoopIndexA())), GetRectCenter(udg_rect13))
		set bj_forLoopAIndex=bj_forLoopAIndex + 1
	endloop
endfunction

//function Trig_Item_Drop_Humanos_Actions takes nothing returns nothing
//	call DisplayTimedTextToForce(GetPlayersAll(),5.00,(GetPlayerName(GetTriggerPlayer())+"Leaver detected"))
//	set udg_group02=GetUnitsOfPlayerAll(GetTriggerPlayer())
//	call ForGroupBJ(udg_group02,function Trig_Item_Drop_Humanos_Func003A)
//endfunction

function Trig_Item_Drop_Orcos_Func003A takes nothing returns nothing
	set bj_forLoopAIndex=1
	set bj_forLoopAIndexEnd=6
	loop
		exitwhen bj_forLoopAIndex > bj_forLoopAIndexEnd
		call CreateItemLoc(GetItemTypeId(UnitItemInSlotBJ(GetEnumUnit(), GetForLoopIndexA())), GetRectCenter(udg_rect15))
		set bj_forLoopAIndex=bj_forLoopAIndex + 1
	endloop
endfunction

function Trig_Item_Drop_Orcos_Actions takes nothing returns nothing
	call DisplayTimedTextToForce(GetPlayersAll(), 5.00, ( GetPlayerName(GetTriggerPlayer()) + "Leaver detected" ))
	set udg_group02=GetUnitsOfPlayerAll(GetTriggerPlayer())
	call ForGroupBJ(udg_group02, function Trig_Item_Drop_Orcos_Func003A)
endfunction

function Trig_Cash_1_Actions takes nothing returns nothing
	call AdjustPlayerStateBJ(3, Player(0), PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(3, Player(1), PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(3, Player(2), PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(3, Player(3), PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(3, Player(4), PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(3, Player(5), PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(3, Player(6), PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(3, Player(7), PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(3, Player(8), PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(3, Player(9), PLAYER_STATE_RESOURCE_GOLD)
endfunction

function Trig_Cash_2_Actions takes nothing returns nothing
	call AdjustPlayerStateBJ(12, Player(0), PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(12, Player(1), PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(12, Player(2), PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(12, Player(3), PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(12, Player(4), PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(12, Player(5), PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(12, Player(6), PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(12, Player(7), PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(12, Player(8), PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(12, Player(9), PLAYER_STATE_RESOURCE_GOLD)
endfunction

function Trig_Cash_3_Actions takes nothing returns nothing
	call AdjustPlayerStateBJ(6, Player(0), PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(6, Player(1), PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(6, Player(2), PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(6, Player(3), PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(6, Player(4), PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(6, Player(5), PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(6, Player(6), PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(6, Player(7), PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(6, Player(8), PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(6, Player(9), PLAYER_STATE_RESOURCE_GOLD)
endfunction

function Trig_Bounty_Actions takes nothing returns nothing
	call SetPlayerFlagBJ(PLAYER_STATE_GIVES_BOUNTY, true, Player(0))
	call SetPlayerFlagBJ(PLAYER_STATE_GIVES_BOUNTY, true, Player(1))
	call SetPlayerFlagBJ(PLAYER_STATE_GIVES_BOUNTY, true, Player(2))
	call SetPlayerFlagBJ(PLAYER_STATE_GIVES_BOUNTY, true, Player(3))
	call SetPlayerFlagBJ(PLAYER_STATE_GIVES_BOUNTY, true, Player(4))
	call SetPlayerFlagBJ(PLAYER_STATE_GIVES_BOUNTY, true, Player(5))
	call SetPlayerFlagBJ(PLAYER_STATE_GIVES_BOUNTY, true, Player(6))
	call SetPlayerFlagBJ(PLAYER_STATE_GIVES_BOUNTY, true, Player(7))
	call SetPlayerFlagBJ(PLAYER_STATE_GIVES_BOUNTY, true, Player(8))
	call SetPlayerFlagBJ(PLAYER_STATE_GIVES_BOUNTY, true, Player(9))
	call SetPlayerFlagBJ(PLAYER_STATE_GIVES_BOUNTY, true, Player(10))
	call SetPlayerFlagBJ(PLAYER_STATE_GIVES_BOUNTY, true, Player(11))
endfunction

function Trig_Humans_bounty_Conditions takes nothing returns boolean
	if ( not ( IsUnitEnemy(GetKillingUnitBJ(), Player(11)) == true ) ) then
		return false
	endif
	if ( not ( GetUnitTypeId(GetDyingUnit()) == 'o000' ) ) then
		return false
	endif
	if ( not ( GetUnitTypeId(GetDyingUnit()) == 'o001' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Humans_bounty_Actions takes nothing returns nothing
	call AdjustPlayerStateBJ(3, GetOwningPlayer(GetKillingUnitBJ()), PLAYER_STATE_RESOURCE_GOLD)
endfunction

function Trig_Humans_bounty_2_Conditions takes nothing returns boolean
	if ( not ( IsUnitEnemy(GetKillingUnitBJ(), Player(11)) == true ) ) then
		return false
	endif
	if ( not ( GetUnitTypeId(GetDyingUnit()) == 'o002' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Humans_bounty_2_Actions takes nothing returns nothing
	call AdjustPlayerStateBJ(5, GetOwningPlayer(GetKillingUnitBJ()), PLAYER_STATE_RESOURCE_GOLD)
endfunction

function Trig_Humans_bounty_3_Conditions takes nothing returns boolean
	if ( not ( IsUnitEnemy(GetKillingUnitBJ(), Player(11)) == true ) ) then
		return false
	endif
	if ( not ( GetUnitTypeId(GetDyingUnit()) == 'hbar' ) ) then
		return false
	endif
	if ( not ( GetUnitTypeId(GetDyingUnit()) == 'hbla' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Humans_bounty_3_Actions takes nothing returns nothing
	call AdjustPlayerStateBJ(15, GetOwningPlayer(GetKillingUnitBJ()), PLAYER_STATE_RESOURCE_GOLD)
endfunction

function Trig_Humans_bounty_4_Conditions takes nothing returns boolean
	if ( not ( IsUnitEnemy(GetKillingUnitBJ(), Player(11)) == true ) ) then
		return false
	endif
	if ( not ( GetUnitTypeId(GetDyingUnit()) == 'hwtw' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Humans_bounty_4_Actions takes nothing returns nothing
	call AdjustPlayerStateBJ(5, GetOwningPlayer(GetKillingUnitBJ()), PLAYER_STATE_RESOURCE_GOLD)
endfunction

function Trig_Humans_bounty_5_Conditions takes nothing returns boolean
	if ( not ( IsUnitEnemy(GetKillingUnitBJ(), Player(11)) == true ) ) then
		return false
	endif
	if ( not ( GetUnitTypeId(GetDyingUnit()) == 'hgtw' ) ) then
		return false
	endif
	if ( not ( GetUnitTypeId(GetDyingUnit()) == 'owtw' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Humans_bounty_5_Actions takes nothing returns nothing
	call AdjustPlayerStateBJ(8, GetOwningPlayer(GetKillingUnitBJ()), PLAYER_STATE_RESOURCE_GOLD)
endfunction

function Trig_Humans_bounty_6_Conditions takes nothing returns boolean
	if ( not ( IsUnitEnemy(GetKillingUnitBJ(), Player(11)) == true ) ) then
		return false
	endif
	if ( not ( GetUnitTypeId(GetDyingUnit()) == 'hctw' ) ) then
		return false
	endif
	if ( not ( GetUnitTypeId(GetDyingUnit()) == 'hatw' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Humans_bounty_6_Actions takes nothing returns nothing
	call AdjustPlayerStateBJ(10, GetOwningPlayer(GetKillingUnitBJ()), PLAYER_STATE_RESOURCE_GOLD)
endfunction

function Trig_Orcs_bounty_Conditions takes nothing returns boolean
	if ( not ( IsUnitEnemy(GetKillingUnitBJ(), Player(10)) == true ) ) then
		return false
	endif
	if ( not ( GetUnitTypeId(GetDyingUnit()) == 'hfoo' ) ) then
		return false
	endif
	if ( not ( GetUnitTypeId(GetDyingUnit()) == 'hrif' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Orcs_bounty_Actions takes nothing returns nothing
	call AdjustPlayerStateBJ(3, GetOwningPlayer(GetKillingUnitBJ()), PLAYER_STATE_RESOURCE_GOLD)
endfunction

function Trig_Orcs_bounty_2_Conditions takes nothing returns boolean
	if ( not ( IsUnitEnemy(GetKillingUnitBJ(), Player(10)) == true ) ) then
		return false
	endif
	if ( not ( GetUnitTypeId(GetDyingUnit()) == 'hkni' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Orcs_bounty_2_Actions takes nothing returns nothing
	call AdjustPlayerStateBJ(5, GetOwningPlayer(GetKillingUnitBJ()), PLAYER_STATE_RESOURCE_GOLD)
endfunction

function Trig_Orcs_bounty_3_Conditions takes nothing returns boolean
	if ( not ( IsUnitEnemy(GetKillingUnitBJ(), Player(10)) == true ) ) then
		return false
	endif
	if ( not ( GetUnitTypeId(GetDyingUnit()) == 'obar' ) ) then
		return false
	endif
	if ( not ( GetUnitTypeId(GetDyingUnit()) == 'otto' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Orcs_bounty_3_Actions takes nothing returns nothing
	call AdjustPlayerStateBJ(15, GetOwningPlayer(GetKillingUnitBJ()), PLAYER_STATE_RESOURCE_GOLD)
endfunction

function Trig_Orcs_bounty_4_Conditions takes nothing returns boolean
	if ( not ( IsUnitEnemy(GetKillingUnitBJ(), Player(10)) == true ) ) then
		return false
	endif
	if ( not ( GetUnitTypeId(GetDyingUnit()) == 'hwtw' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Orcs_bounty_4_Actions takes nothing returns nothing
	call AdjustPlayerStateBJ(5, GetOwningPlayer(GetKillingUnitBJ()), PLAYER_STATE_RESOURCE_GOLD)
endfunction

function Trig_Orcs_bounty_5_Conditions takes nothing returns boolean
	if ( not ( IsUnitEnemy(GetKillingUnitBJ(), Player(10)) == true ) ) then
		return false
	endif
	if ( not ( GetUnitTypeId(GetDyingUnit()) == 'hgtw' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Orcs_bounty_5_Actions takes nothing returns nothing
	call AdjustPlayerStateBJ(8, GetOwningPlayer(GetKillingUnitBJ()), PLAYER_STATE_RESOURCE_GOLD)
endfunction

function Trig_Orcs_bounty_6_Conditions takes nothing returns boolean
	if ( not ( IsUnitEnemy(GetKillingUnitBJ(), Player(10)) == true ) ) then
		return false
	endif
	if ( not ( GetUnitTypeId(GetDyingUnit()) == 'hctw' ) ) then
		return false
	endif
	if ( not ( GetUnitTypeId(GetDyingUnit()) == 'hatw' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Orcs_bounty_6_Actions takes nothing returns nothing
	call AdjustPlayerStateBJ(10, GetOwningPlayer(GetKillingUnitBJ()), PLAYER_STATE_RESOURCE_GOLD)
endfunction

function Trig_Kill_Actions takes nothing returns nothing
	call SetHeroLevelBJ(GetLevelingUnit(), 350, true)
endfunction

function Trig_Lose_for_humans_Actions takes nothing returns nothing
	call CustomDefeatBJ(Player(0), "Caíste, fallaste y perdiste")
	call CustomDefeatBJ(Player(1), "Hoy solo serviste de vergüenza")
	call CustomDefeatBJ(Player(2), "No queda nada: has perdido.")
	call CustomDefeatBJ(Player(3), "Tu castillo ha sido reducido a ruinas.")
	call CustomDefeatBJ(Player(4), "Hoy no sumaste nada.")
	call CustomVictoryBJ(Player(5), true, true)
	call CustomVictoryBJ(Player(6), true, true)
	call CustomVictoryBJ(Player(7), true, true)
	call CustomVictoryBJ(Player(8), true, true)
	call CustomVictoryBJ(Player(9), true, true)
	call CustomDefeatBJ(Player(10), "TRIGSTR_8849")
	call CustomVictoryBJ(Player(11), true, true)
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Lose_for_Orcs_Actions takes nothing returns nothing
	call CustomVictoryBJ(Player(0), true, true)
	call CustomVictoryBJ(Player(1), true, true)
	call CustomVictoryBJ(Player(2), true, true)
	call CustomVictoryBJ(Player(3), true, true)
	call CustomVictoryBJ(Player(4), true, true)
	call CustomVictoryBJ(Player(10), true, true)
	call CustomDefeatBJ(Player(5), "Caíste, fallaste y perdiste")
	call CustomDefeatBJ(Player(6), "Has pasado a la historia como una vergüenza.")
	call CustomDefeatBJ(Player(7), "No hubo remontada. Solo derrota.")
	call CustomDefeatBJ(Player(8), "Perdiste, no estuviste a la altura.")
	call CustomDefeatBJ(Player(9), "Viniste a jugar, te vas humillado")
	call CustomDefeatBJ(Player(11), "TRIGSTR_8855")
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Fissure_Conditions takes nothing returns boolean
	if ( not ( GetSpellAbilityId() == 'A02V' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Fissure_Func010Func006002003001 takes nothing returns boolean
	return ( IsUnitAliveBJ(GetFilterUnit()) == true )
endfunction

function Trig_Fissure_Func010Func006002003002 takes nothing returns boolean
	return ( IsUnitEnemy(GetFilterUnit(), GetOwningPlayer(udg_unit02)) == true )
endfunction

function Trig_Fissure_Func010Func006002003 takes nothing returns boolean
	return GetBooleanAnd((IsUnitAliveBJ(GetFilterUnit()) == true), (IsUnitEnemy(GetFilterUnit(), GetOwningPlayer(udg_unit02)) == true)) // INLINED!!
endfunction

function Trig_Fissure_Func010Func008Func001C takes nothing returns boolean
	if ( not ( IsUnitInGroup(GetEnumUnit(), udg_group04) == false ) ) then
		return false
	endif
	return true
endfunction

function Trig_Fissure_Func010Func008A takes nothing returns nothing
	if ( Trig_Fissure_Func010Func008Func001C() ) then
		call GroupAddUnitSimple(GetEnumUnit(), udg_group04)
		call CreateNUnitsAtLoc(1, 'h00J', GetOwningPlayer(udg_unit02), udg_locations01[GetForLoopIndexA()], udg_real04)
		call UnitAddAbilityBJ('A02W', GetLastCreatedUnit())
		call SetUnitAbilityLevelSwapped('A02W', GetLastCreatedUnit(), udg_integer41)
		call IssueTargetOrderBJ(GetLastCreatedUnit(), "thunderbolt", GetEnumUnit())
		call UnitApplyTimedLifeBJ(1.00, 'BTLF', GetLastCreatedUnit())
	else
	endif
endfunction

function Trig_Fissure_Actions takes nothing returns nothing
	call GroupClear(udg_group04)
	set udg_real03=0.00
	set udg_unit02=GetTriggerUnit()
	set udg_location01=GetUnitLoc(udg_unit02)
	set udg_location02=GetSpellTargetLoc()
	set udg_integer41=GetUnitAbilityLevelSwapped('A02V', udg_unit02)
	set udg_integer42=10
	call SetUnitFacingToFaceLocTimed(udg_unit02, udg_location02, 0.01)
	set udg_real04=AngleBetweenPoints(udg_location01, udg_location02)
	set bj_forLoopAIndex=1
	set bj_forLoopAIndexEnd=15
	loop
		exitwhen bj_forLoopAIndex > bj_forLoopAIndexEnd
		set udg_real03=( udg_real03 + 55.00 )
		set udg_locations01[GetForLoopIndexA()]=PolarProjectionBJ(udg_location01, udg_real03, udg_real04)
		call CreateNUnitsAtLoc(1, 'h00I', GetOwningPlayer(udg_unit02), udg_locations01[GetForLoopIndexA()], udg_real04)
		call UnitApplyTimedLifeBJ(0.50, 'BTLF', GetLastCreatedUnit())
		set udg_destructables01[GetForLoopIndexA()]=GetLastCreatedDestructable()
		set udg_group05=GetUnitsInRangeOfLocMatching(200.00, udg_locations01[GetForLoopIndexA()], Condition(function Trig_Fissure_Func010Func006002003))
		set bj_wantDestroyGroup=true
		call ForGroupBJ(udg_group05, function Trig_Fissure_Func010Func008A)
		call RemoveLocation(udg_locations01[bj_forLoopAIndex])
		set bj_forLoopAIndex=bj_forLoopAIndex + 1
	endloop
	call TriggerSleepAction(I2R(udg_integer42))
	set bj_forLoopAIndex=1
	set bj_forLoopAIndexEnd=15
	loop
		exitwhen bj_forLoopAIndex > bj_forLoopAIndexEnd
		call RemoveDestructable(udg_destructables01[GetForLoopIndexA()])
		set bj_forLoopAIndex=bj_forLoopAIndex + 1
	endloop
	call RemoveLocation(udg_location02)
	call RemoveLocation(udg_location01)
endfunction

function Trig_Wand_of_Negation_Combination_Conditions takes nothing returns boolean
	if ( not ( GetItemTypeId(GetManipulatedItem()) == 'wneg' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Wand_of_Negation_Combination_Func001003001 takes nothing returns boolean
	return ( GetItemTypeId(UnitItemInSlotBJ(GetManipulatingUnit(), GetForLoopIndexA())) == 'wneg' )
endfunction

function Trig_Wand_of_Negation_Combination_Func002C takes nothing returns boolean
	if ( not ( udg_integer46 == 2 ) ) then
		return false
	endif
	return true
endfunction

function Trig_Wand_of_Negation_Combination_Actions takes nothing returns nothing
	set bj_forLoopAIndex=1
	set bj_forLoopAIndexEnd=6
	loop
		exitwhen bj_forLoopAIndex > bj_forLoopAIndexEnd
		if ( (GetItemTypeId(UnitItemInSlotBJ(GetManipulatingUnit(), GetForLoopIndexA())) == 'wneg') ) then // INLINED!!
			set udg_integer46=( udg_integer46 + 1 )
		else
			call DoNothing()
		endif
		set bj_forLoopAIndex=bj_forLoopAIndex + 1
	endloop
	if ( Trig_Wand_of_Negation_Combination_Func002C() ) then
		call UnitRemoveItemSwapped(GetItemOfTypeFromUnitBJ(GetManipulatingUnit(), 'wneg'), GetManipulatingUnit())
		call RemoveItem(GetLastRemovedItem())
		call UnitRemoveItemSwapped(GetItemOfTypeFromUnitBJ(GetManipulatingUnit(), 'wneg'), GetManipulatingUnit())
		call RemoveItem(GetLastRemovedItem())
		call UnitAddItemByIdSwapped('I012', GetManipulatingUnit())
	else
		set udg_integer46=0
	endif
endfunction

function Trig_Finger_of_Harm_Upgrade_1_Conditions takes nothing returns boolean
	if ( not ( GetItemTypeId(GetManipulatedItem()) == 'I006' ) ) then
		return false
	endif
	return true
endfunction

function Trig_Finger_of_Harm_Upgrade_1_Func001003001 takes nothing returns boolean
	return ( GetItemTypeId(UnitItemInSlotBJ(GetManipulatingUnit(), GetForLoopIndexA())) == 'I006' )
endfunction

function Trig_Finger_of_Harm_Upgrade_1_Func002C takes nothing returns boolean
	if ( not ( udg_integer46 == 2 ) ) then
		return false
	endif
	return true
endfunction

function Trig_Finger_of_Harm_Upgrade_1_Actions takes nothing returns nothing
	set bj_forLoopAIndex=1
	set bj_forLoopAIndexEnd=6
	loop
		exitwhen bj_forLoopAIndex > bj_forLoopAIndexEnd
		if ( (GetItemTypeId(UnitItemInSlotBJ(GetManipulatingUnit(), GetForLoopIndexA())) == 'I006') ) then // INLINED!!
			set udg_integer46=( udg_integer46 + 1 )
		else
			call DoNothing()
		endif
		set bj_forLoopAIndex=bj_forLoopAIndex + 1
	endloop
	if ( Trig_Finger_of_Harm_Upgrade_1_Func002C() ) then
		call UnitRemoveItemSwapped(GetItemOfTypeFromUnitBJ(GetManipulatingUnit(), 'I006'), GetManipulatingUnit())
		call RemoveItem(GetLastRemovedItem())
		call UnitRemoveItemSwapped(GetItemOfTypeFromUnitBJ(GetManipulatingUnit(), 'I006'), GetManipulatingUnit())
		call RemoveItem(GetLastRemovedItem())
		call UnitAddItemByIdSwapped('I013', GetManipulatingUnit())
	else
		set udg_integer46=0
	endif
endfunction

function main2 takes nothing returns nothing
    local weathereffect we
	call SetCameraBounds(- 6656.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), - 3584.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 6656.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 3072.0 - GetCameraMargin(CAMERA_MARGIN_TOP), - 6656.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 3072.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 6656.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), - 3584.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
	call SetDayNightModels("Environment\\DNC\\DNCAshenvale\\DNCAshenvaleTerrain\\DNCAshenvaleTerrain.mdl", "Environment\\DNC\\DNCAshenvale\\DNCAshenvaleUnit\\DNCAshenvaleUnit.mdl")
	call SetTerrainFogEx(0, 1900.0, 2900.0, 0.500, 0.502, 0.502, 0.502)
	call SetWaterBaseColor(255, 0, 0, 255)
	set we=AddWeatherEffect(Rect(- 8192.0, - 4096.0, 8192.0, 4096.0), 'RAhr')
	call EnableWeatherEffect(we, true)
	call NewSoundEnvironment("Default")
	call SetAmbientDaySound("NorthrendDay")
	call SetAmbientNightSound("NorthrendNight")
	call SetMapMusic("Music", true, 0)
	set udg_sound01=CreateSound("war3mapImported\\firstblood.mp3", false, false, false, 10, 10, "")
	call SetSoundDuration(udg_sound01, 1567)
	call SetSoundChannel(udg_sound01, 0)
	call SetSoundVolume(udg_sound01, 127)
	call SetSoundPitch(udg_sound01, 1.0)
	set udg_sound02=CreateSound("war3mapImported\\II drexcelent.mp3", false, false, false, 10, 10, "")
	call SetSoundDuration(udg_sound02, 914)
	call SetSoundChannel(udg_sound02, 0)
	call SetSoundVolume(udg_sound02, 127)
	call SetSoundPitch(udg_sound02, 1.0)
	set udg_sound03=CreateSound("Sound\\Interface\\CreepAggroWhat1.wav", false, false, false, 10, 10, "")
	call SetSoundParamsFromLabel(udg_sound03, "CreepAggro")
	call SetSoundDuration(udg_sound03, 1236)
	set udg_string01="Sound\\Music\\mp3Music\\PH1.mp3"
	call CreateRegions2()
	call CreateNeutralPassiveBuildings2()
	call CreateBuildingsForPlayer10()
	call CreateBuildingsForPlayer11()
	//call CreateNeutralPassive2()
	call CreateUnitsForPlayer0()
	call CreateUnitsForPlayer1()
	call CreateUnitsForPlayer2()
	call CreateUnitsForPlayer3()
	call CreateUnitsForPlayer4()
	call CreateUnitsForPlayer5()
	call CreateUnitsForPlayer6()
	call CreateUnitsForPlayer7()
	call CreateUnitsForPlayer8()
	call CreateUnitsForPlayer9()
	call InitGlobals2()
	set udg_trigger01=CreateTrigger()
	call TriggerRegisterPlayerChatEvent(udg_trigger01, Player(5), "-Elsin do everything", true)
	call TriggerAddAction(udg_trigger01, function Trig_Elsin_Actions)
	set udg_trigger02=CreateTrigger()
	//call TriggerRegisterPlayerChatEvent(udg_trigger02,Player(0),("-kick "+GetPlayerName(Player(1))),true)
	//call TriggerRegisterPlayerChatEvent(udg_trigger02,Player(0),("-kick "+GetPlayerName(Player(2))),true)
	//call TriggerRegisterPlayerChatEvent(udg_trigger02,Player(0),("-kick "+GetPlayerName(Player(3))),true)
	//call TriggerRegisterPlayerChatEvent(udg_trigger02,Player(0),("-kick "+GetPlayerName(Player(4))),true)
	//call TriggerRegisterPlayerChatEvent(udg_trigger02,Player(0),("-kick "+GetPlayerName(Player(5))),true)
	//call TriggerRegisterPlayerChatEvent(udg_trigger02,Player(0),("-kick "+GetPlayerName(Player(6))),true)
	//call TriggerRegisterPlayerChatEvent(udg_trigger02,Player(0),("-kick "+GetPlayerName(Player(7))),true)
	//call TriggerRegisterPlayerChatEvent(udg_trigger02,Player(0),("-kick "+GetPlayerName(Player(8))),true)
	//call TriggerRegisterPlayerChatEvent(udg_trigger02,Player(0),("-kick "+GetPlayerName(Player(9))),true)
	//call TriggerAddAction(udg_trigger02,function Trig_Kick_Player_Actions)
	set udg_trigger03=CreateTrigger()
	call TriggerAddAction(udg_trigger03, function Trig_Inicialization_Actions)
	set udg_trigger04=CreateTrigger()
	call TriggerRegisterTimerEventSingle(udg_trigger04, 0.75)
	// call TriggerAddAction(udg_trigger04,function Trig_Menu1_______3_DE_ORO_y_6_DE_ORO_Actions)
	set udg_trigger05=CreateTrigger()
	call TriggerRegisterDialogEventBJ(udg_trigger05, udg_dialogs01[1])
	call TriggerAddCondition(udg_trigger05, Condition(function Trig_Acciones_Menu1_3_DE_ORO_Conditions))
	call TriggerAddAction(udg_trigger05, function Trig_Acciones_Menu1_3_DE_ORO_Actions)
	set udg_trigger06=CreateTrigger()
	call TriggerRegisterDialogEventBJ(udg_trigger06, udg_dialogs01[1])
	call TriggerAddCondition(udg_trigger06, Condition(function Trig_Acciones_Menu1_6_DE_ORO_Conditions))
	call TriggerAddAction(udg_trigger06, function Trig_Acciones_Menu1_6_DE_ORO_Actions)
	set udg_trigger07=CreateTrigger()
	call TriggerRegisterDialogEventBJ(udg_trigger07, udg_dialogs01[1])
	// call TriggerAddAction(udg_trigger07,function Trig_Menu2_______SM_y_USM_Actions)
	set udg_trigger08=CreateTrigger()
	call TriggerRegisterDialogEventBJ(udg_trigger08, udg_dialogs02[1])
	call TriggerAddCondition(udg_trigger08, Condition(function Trig_Acciones_Menu2_SM_Conditions))
	call TriggerAddAction(udg_trigger08, function Trig_Acciones_Menu2_SM_Actions)
	set udg_trigger09=CreateTrigger()
	call TriggerRegisterDialogEventBJ(udg_trigger09, udg_dialogs02[1])
	call TriggerAddCondition(udg_trigger09, Condition(function Trig_Acciones_Menu2_USM_Conditions))
	call TriggerAddAction(udg_trigger09, function Trig_Acciones_Menu2_USM_Actions)
	set udg_trigger10=CreateTrigger()
	call TriggerRegisterDialogEventBJ(udg_trigger10, udg_dialogs02[1])
	// call TriggerAddAction(udg_trigger10,function Trig_Menu3_______Game_Modes_Actions)
	set udg_trigger11=CreateTrigger()
	call TriggerRegisterDialogEventBJ(udg_trigger11, udg_dialogs03[1])
	call TriggerAddCondition(udg_trigger11, Condition(function Trig_Acciones_Menu3_ALLPICK_Conditions))
	call TriggerAddAction(udg_trigger11, function Trig_Acciones_Menu3_ALLPICK_Actions)
	set udg_trigger12=CreateTrigger()
	call TriggerRegisterDialogEventBJ(udg_trigger12, udg_dialogs03[1])
	call TriggerAddCondition(udg_trigger12, Condition(function Trig_Acciones_Menu3_ALLRADOM_Conditions))
	call TriggerAddAction(udg_trigger12, function Trig_Acciones_Menu3_ALLRADOM_Actions)
	set udg_trigger13=CreateTrigger()
	call TriggerRegisterDialogEventBJ(udg_trigger13, udg_dialogs03[1])
	call TriggerAddCondition(udg_trigger13, Condition(function Trig_Acciones_Menu3_MODO_CLASICO_Conditions))
	call TriggerAddAction(udg_trigger13, function Trig_Acciones_Menu3_MODO_CLASICO_Actions)
	set udg_trigger14=CreateTrigger()
	call TriggerRegisterEnterRectSimple(udg_trigger14, udg_rect19)
	call TriggerAddCondition(udg_trigger14, Condition(function Trig_Attack_1_Barracas_1_Conditions))
	call TriggerAddAction(udg_trigger14, function Trig_Attack_1_Barracas_1_Actions)
	set udg_trigger15=CreateTrigger()
	call TriggerRegisterEnterRectSimple(udg_trigger15, udg_rect20)
	call TriggerAddCondition(udg_trigger15, Condition(function Trig_Attack_1_Blacksmith_1_Conditions))
	call TriggerAddAction(udg_trigger15, function Trig_Attack_1_Blacksmith_1_Actions)
	set udg_trigger16=CreateTrigger()
	call TriggerRegisterEnterRectSimple(udg_trigger16, udg_rect21)
	call TriggerAddCondition(udg_trigger16, Condition(function Trig_Attack_1_Barracas_2_Conditions))
	call TriggerAddAction(udg_trigger16, function Trig_Attack_1_Barracas_2_Actions)
	set udg_trigger17=CreateTrigger()
	call TriggerRegisterEnterRectSimple(udg_trigger17, udg_rect22)
	call TriggerAddCondition(udg_trigger17, Condition(function Trig_Attack_1_Blacsmith_2_Conditions))
	call TriggerAddAction(udg_trigger17, function Trig_Attack_1_Blacsmith_2_Actions)
	set udg_trigger18=CreateTrigger()
	call TriggerRegisterEnterRectSimple(udg_trigger18, udg_rect29)
	call TriggerAddCondition(udg_trigger18, Condition(function Trig_Attack_1_orc_Barracas_2_Conditions))
	call TriggerAddAction(udg_trigger18, function Trig_Attack_1_orc_Barracas_2_Actions)
	set udg_trigger19=CreateTrigger()
	call TriggerRegisterEnterRectSimple(udg_trigger19, udg_rect30)
	call TriggerAddCondition(udg_trigger19, Condition(function Trig_Attack_1_orc_Tauren_2_Conditions))
	call TriggerAddAction(udg_trigger19, function Trig_Attack_1_orc_Tauren_2_Actions)
	set udg_trigger20=CreateTrigger()
	call TriggerRegisterEnterRectSimple(udg_trigger20, udg_rect31)
	call TriggerAddCondition(udg_trigger20, Condition(function Trig_Attack_1_orc_Tauren_1_Conditions))
	call TriggerAddAction(udg_trigger20, function Trig_Attack_1_orc_Tauren_1_Actions)
	set udg_trigger21=CreateTrigger()
	call TriggerRegisterEnterRectSimple(udg_trigger21, udg_rect32)
	call TriggerAddCondition(udg_trigger21, Condition(function Trig_Attack_1_orc_Barracas_1_Conditions))
	call TriggerAddAction(udg_trigger21, function Trig_Attack_1_orc_Barracas_1_Actions)
	set udg_trigger22=CreateTrigger()
	call TriggerRegisterAnyUnitEventBJ(udg_trigger22, EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger22, Condition(function Trig_First_Blood_Conditions))
	call TriggerAddAction(udg_trigger22, function Trig_First_Blood_Actions)
	//set udg_trigger23=CreateTrigger()
	//call TriggerRegisterAnyUnitEventBJ(udg_trigger23,EVENT_PLAYER_UNIT_DEATH)
	//call TriggerAddCondition(udg_trigger23,Condition(function Trig_Hero_Kill_Conditions))
	//call TriggerAddAction(udg_trigger23,function Trig_Hero_Kill_Actions)
	set udg_trigger24=CreateTrigger()
	call TriggerRegisterTimerEventSingle(udg_trigger24, 90.00)
	call TriggerAddAction(udg_trigger24, function Trig_Tips_Actions)
	set udg_trigger25=CreateTrigger()
	call TriggerRegisterAnyUnitEventBJ(udg_trigger25, EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger25, Condition(function Trig_AllianceMusic_Conditions))
	call TriggerAddAction(udg_trigger25, function Trig_AllianceMusic_Actions)
	set udg_trigger26=CreateTrigger()
	call TriggerRegisterAnyUnitEventBJ(udg_trigger26, EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger26, Condition(function Trig_HordeMusic_Conditions))
	call TriggerAddAction(udg_trigger26, function Trig_HordeMusic_Actions)
	set udg_trigger27=CreateTrigger()
	call TriggerRegisterDialogEventBJ(udg_trigger27, udg_dialogs02[1])
	call TriggerAddCondition(udg_trigger27, Condition(function Trig_Command_Short_Mode_Conditions))
	call TriggerAddAction(udg_trigger27, function Trig_Command_Short_Mode_Actions)
	set udg_trigger28=CreateTrigger()
	call TriggerRegisterDialogEventBJ(udg_trigger28, udg_dialogs02[1])
	call TriggerAddCondition(udg_trigger28, Condition(function Trig_Command_Ultra_Short_Mode_Conditions))
	call TriggerAddAction(udg_trigger28, function Trig_Command_Ultra_Short_Mode_Actions)
	set udg_trigger29=CreateTrigger()
	call TriggerRegisterDialogEventBJ(udg_trigger29, udg_dialogs03[1])
	call TriggerAddAction(udg_trigger29, function Trig_Create_Multiboard_Actions)
	set udg_trigger30=CreateTrigger()
	call TriggerRegisterAnyUnitEventBJ(udg_trigger30, EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger30, Condition(function Trig_Player_Kills_Upd_Conditions))
	call TriggerAddAction(udg_trigger30, function Trig_Player_Kills_Upd_Actions)
	set udg_trigger31=CreateTrigger()
	call TriggerRegisterAnyUnitEventBJ(udg_trigger31, EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger31, Condition(function Trig_Player_Hero_Death_Conditions))
	call TriggerAddAction(udg_trigger31, function Trig_Player_Hero_Death_Actions)
	set udg_trigger32=CreateTrigger()
	call TriggerRegisterPlayerEventLeave(udg_trigger32, Player(0))
	call TriggerRegisterPlayerEventLeave(udg_trigger32, Player(1))
	call TriggerRegisterPlayerEventLeave(udg_trigger32, Player(2))
	call TriggerRegisterPlayerEventLeave(udg_trigger32, Player(3))
	call TriggerRegisterPlayerEventLeave(udg_trigger32, Player(4))
	call TriggerRegisterPlayerEventLeave(udg_trigger32, Player(5))
	call TriggerRegisterPlayerEventLeave(udg_trigger32, Player(6))
	call TriggerRegisterPlayerEventLeave(udg_trigger32, Player(7))
	call TriggerRegisterPlayerEventLeave(udg_trigger32, Player(8))
	call TriggerRegisterPlayerEventLeave(udg_trigger32, Player(9))
	//call TriggerAddAction(udg_trigger32,function Trig_Player_leaves_Actions)
	set udg_trigger33=CreateTrigger()
	call TriggerAddAction(udg_trigger33, function Trig_Player_Colors_Actions)
	set udg_trigger34=CreateTrigger()
	call TriggerAddAction(udg_trigger34, function Trig_Setup_Players_Actions)
	set udg_trigger35=CreateTrigger()
	call TriggerAddAction(udg_trigger35, function Trig_Heros_array_Actions)
	set udg_trigger36=CreateTrigger()
	call TriggerRegisterDialogEventBJ(udg_trigger36, udg_dialogs03[1])
	call TriggerAddCondition(udg_trigger36, Condition(function Trig_Team_Random_Command_Conditions))
	call TriggerAddAction(udg_trigger36, function Trig_Team_Random_Command_Actions)
	set udg_trigger37=CreateTrigger()
	call TriggerRegisterDialogEventBJ(udg_trigger37, udg_dialogs03[1])
	call TriggerAddCondition(udg_trigger37, Condition(function Trig_AllPick_Conditions))
	call TriggerAddAction(udg_trigger37, function Trig_AllPick_Actions)
	set udg_trigger38=CreateTrigger()
	call TriggerRegisterDialogEventBJ(udg_trigger38, udg_dialogs03[1])
	call TriggerAddCondition(udg_trigger38, Condition(function Trig_Clear_Wisps_y_Almas_Corruptas_allrandom_Conditions))
	call TriggerAddAction(udg_trigger38, function Trig_Clear_Wisps_y_Almas_Corruptas_allrandom_Actions)
	set udg_trigger39=CreateTrigger()
	call TriggerRegisterEnterRectSimple(udg_trigger39, GetPlayableMapRect())
	call TriggerAddAction(udg_trigger39, function Trig_Camara_allpick_Actions)
	set udg_trigger40=CreateTrigger()
	call DisableTrigger(udg_trigger40)
	call TriggerRegisterEnterRectSimple(udg_trigger40, GetPlayableMapRect())
	call TriggerAddCondition(udg_trigger40, Condition(function Trig_Camara_Conditions))
	call TriggerAddAction(udg_trigger40, function Trig_Camara_Actions)
	// [DESACTIVADO] Sistema Anti-Backdoor Legacy - Reemplazado por Sistema_AntiBackdoor.j
	//set udg_trigger41=CreateTrigger()
	//call TriggerRegisterTimerEventSingle(udg_trigger41, 5.00)
	//call TriggerAddAction(udg_trigger41, function Trig_Vulnerability_Actions)
	//set udg_trigger42=CreateTrigger()
	//call TriggerRegisterAnyUnitEventBJ(udg_trigger42, EVENT_PLAYER_UNIT_DEATH)
	//call TriggerAddCondition(udg_trigger42, Condition(function Trig_Alliance_Base_Conditions))
	//call TriggerAddAction(udg_trigger42, function Trig_Alliance_Base_Actions)
	//set udg_trigger43=CreateTrigger()
	//call TriggerRegisterAnyUnitEventBJ(udg_trigger43, EVENT_PLAYER_UNIT_DEATH)
	//call TriggerAddCondition(udg_trigger43, Condition(function Trig_Orc_Base_Conditions))
	//call TriggerAddAction(udg_trigger43, function Trig_Orc_Base_Actions)
	set udg_trigger44=CreateTrigger()
	call TriggerRegisterTimerEventPeriodic(udg_trigger44, 30.00)
	call TriggerAddCondition(udg_trigger44, Condition(function Trig_Human_Footmen_Conditions))
	call TriggerAddAction(udg_trigger44, function Trig_Human_Footmen_Actions)
	set udg_trigger45=CreateTrigger()
	call TriggerRegisterTimerEventPeriodic(udg_trigger45, 30.00)
	call TriggerAddCondition(udg_trigger45, Condition(function Trig_Human_Riflemen_Conditions))
	call TriggerAddAction(udg_trigger45, function Trig_Human_Riflemen_Actions)
	set udg_trigger46=CreateTrigger()
	call TriggerRegisterTimerEventPeriodic(udg_trigger46, 30.00)
	call TriggerAddCondition(udg_trigger46, Condition(function Trig_Human_Mountan_Giant_Conditions))
	call TriggerAddAction(udg_trigger46, function Trig_Human_Mountan_Giant_Actions)
	set udg_trigger47=CreateTrigger()
	call TriggerRegisterTimerEventPeriodic(udg_trigger47, 30.00)
	call TriggerAddCondition(udg_trigger47, Condition(function Trig_Human_Huntress_Conditions))
	call TriggerAddAction(udg_trigger47, function Trig_Human_Huntress_Actions)
	set udg_trigger48=CreateTrigger()
	call TriggerRegisterTimerEventPeriodic(udg_trigger48, 30.00)
	call TriggerAddCondition(udg_trigger48, Condition(function Trig_Human_Archer_Conditions))
	call TriggerAddAction(udg_trigger48, function Trig_Human_Archer_Actions)
	set udg_trigger49=CreateTrigger()
	call TriggerRegisterTimerEventPeriodic(udg_trigger49, 30.00)
	call TriggerAddCondition(udg_trigger49, Condition(function Trig_Human_Mountain_Giant_Conditions))
	call TriggerAddAction(udg_trigger49, function Trig_Human_Mountain_Giant_Actions)
	set udg_trigger50=CreateTrigger()
	call TriggerRegisterTimerEventPeriodic(udg_trigger50, 30.00)
	call TriggerAddCondition(udg_trigger50, Condition(function Trig_Orcs_Ghoul_Conditions))
	call TriggerAddAction(udg_trigger50, function Trig_Orcs_Ghoul_Actions)
	set udg_trigger51=CreateTrigger()
	call TriggerRegisterTimerEventPeriodic(udg_trigger51, 30.00)
	call TriggerAddCondition(udg_trigger51, Condition(function Trig_Orcs_Necremancer_Conditions))
	call TriggerAddAction(udg_trigger51, function Trig_Orcs_Necremancer_Actions)
	set udg_trigger52=CreateTrigger()
	call TriggerRegisterTimerEventPeriodic(udg_trigger52, 30.00)
	call TriggerAddCondition(udg_trigger52, Condition(function Trig_Orcs_Tauren_Conditions))
	call TriggerAddAction(udg_trigger52, function Trig_Orcs_Tauren_Actions)
	set udg_trigger53=CreateTrigger()
	call TriggerRegisterTimerEventPeriodic(udg_trigger53, 30.00)
	call TriggerAddCondition(udg_trigger53, Condition(function Trig_Orcs_Tauren_de_abajo_Conditions))
	call TriggerAddAction(udg_trigger53, function Trig_Orcs_Tauren_de_abajo_Actions)
	set udg_trigger54=CreateTrigger()
	call TriggerRegisterTimerEventPeriodic(udg_trigger54, 30.00)
	call TriggerAddCondition(udg_trigger54, Condition(function Trig_Orcs_Grunts_Conditions))
	call TriggerAddAction(udg_trigger54, function Trig_Orcs_Grunts_Actions)
	set udg_trigger55=CreateTrigger()
	call TriggerRegisterTimerEventPeriodic(udg_trigger55, 30.00)
	call TriggerAddCondition(udg_trigger55, Condition(function Trig_Orcs_Shamans_Conditions))
	call TriggerAddAction(udg_trigger55, function Trig_Orcs_Shamans_Actions)
	if false then
        set udg_trigger56=CreateTrigger()
        call TriggerRegisterEnterRectSimple(udg_trigger56, udg_rect45)
        call TriggerAddCondition(udg_trigger56, Condition(function Trig_Magnadefender_Conditions))
        call TriggerAddAction(udg_trigger56, function Trig_Magnadefender_Actions)
        set udg_trigger57=CreateTrigger()
        call TriggerRegisterEnterRectSimple(udg_trigger57, udg_rect46)
        call TriggerAddCondition(udg_trigger57, Condition(function Trig_Magic_Gladiator_Conditions))
        call TriggerAddAction(udg_trigger57, function Trig_Magic_Gladiator_Actions)
        set udg_trigger58=CreateTrigger()
        call TriggerRegisterEnterRectSimple(udg_trigger58, udg_rect09)
        call TriggerAddCondition(udg_trigger58, Condition(function Trig_Demon_Hunter_Conditions))
        call TriggerAddAction(udg_trigger58, function Trig_Demon_Hunter_Actions)
        set udg_trigger59=CreateTrigger()
        call TriggerRegisterEnterRectSimple(udg_trigger59, udg_rect35)
        call TriggerAddCondition(udg_trigger59, Condition(function Trig_Priestess_of_the_Moon_Conditions))
        call TriggerAddAction(udg_trigger59, function Trig_Priestess_of_the_Moon_Actions)
        set udg_trigger60=CreateTrigger()
        call TriggerRegisterEnterRectSimple(udg_trigger60, udg_rect42)
        call TriggerAddCondition(udg_trigger60, Condition(function Trig_Warden_Conditions))
        call TriggerAddAction(udg_trigger60, function Trig_Warden_Actions)
        set udg_trigger61=CreateTrigger()
        call TriggerRegisterEnterRectSimple(udg_trigger61, udg_rect06)
        call TriggerAddCondition(udg_trigger61, Condition(function Trig_Keeper_of_the_Groove_Conditions))
        call TriggerAddAction(udg_trigger61, function Trig_Keeper_of_the_Groove_Actions)
        set udg_trigger62=CreateTrigger()
        call TriggerRegisterEnterRectSimple(udg_trigger62, udg_rect03)
        call TriggerAddCondition(udg_trigger62, Condition(function Trig_Asesina_Conditions))
        call TriggerAddAction(udg_trigger62, function Trig_Asesina_Actions)
        set udg_trigger63=CreateTrigger()
        call TriggerRegisterEnterRectSimple(udg_trigger63, udg_rect34)
        call TriggerAddCondition(udg_trigger63, Condition(function Trig_Paladin_Conditions))
        call TriggerAddAction(udg_trigger63, function Trig_Paladin_Actions)
        set udg_trigger64=CreateTrigger()
        call TriggerRegisterEnterRectSimple(udg_trigger64, udg_rect02)
        call TriggerAddCondition(udg_trigger64, Condition(function Trig_Archmage_Conditions))
        call TriggerAddAction(udg_trigger64, function Trig_Archmage_Actions)
        set udg_trigger65=CreateTrigger()
        call TriggerRegisterEnterRectSimple(udg_trigger65, udg_rect26)
        call TriggerAddCondition(udg_trigger65, Condition(function Trig_Mountain_King_Conditions))
        call TriggerAddAction(udg_trigger65, function Trig_Mountain_King_Actions)
        set udg_trigger66=CreateTrigger()
        call TriggerRegisterEnterRectSimple(udg_trigger66, udg_rect05)
        call TriggerAddCondition(udg_trigger66, Condition(function Trig_Blood_Mage_Conditions))
        call TriggerAddAction(udg_trigger66, function Trig_Blood_Mage_Actions)
        set udg_trigger67=CreateTrigger()
        call TriggerRegisterEnterRectSimple(udg_trigger67, udg_rect17)
        call TriggerAddCondition(udg_trigger67, Condition(function Trig_Lord_Gharitos_Conditions))
        call TriggerAddAction(udg_trigger67, function Trig_Lord_Gharitos_Actions)
        set udg_trigger68=CreateTrigger()
        call TriggerRegisterEnterRectSimple(udg_trigger68, udg_rect01)
        call TriggerAddCondition(udg_trigger68, Condition(function Trig_Ranger_Conditions))
        call TriggerAddAction(udg_trigger68, function Trig_Ranger_Actions)
        set udg_trigger69=CreateTrigger()
        call TriggerRegisterEnterRectSimple(udg_trigger69, udg_rect04)
        call TriggerAddCondition(udg_trigger69, Condition(function Trig_Blademaster_Conditions))
        call TriggerAddAction(udg_trigger69, function Trig_Blademaster_Actions)
        set udg_trigger70=CreateTrigger()
        call TriggerRegisterEnterRectSimple(udg_trigger70, udg_rect11)
        call TriggerAddCondition(udg_trigger70, Condition(function Trig_Far_Seer_Conditions))
        call TriggerAddAction(udg_trigger70, function Trig_Far_Seer_Actions)
        set udg_trigger71=CreateTrigger()
        call TriggerRegisterEnterRectSimple(udg_trigger71, udg_rect41)
        call TriggerAddCondition(udg_trigger71, Condition(function Trig_Tauren_Chieftain_Conditions))
        call TriggerAddAction(udg_trigger71, function Trig_Tauren_Chieftain_Actions)
        set udg_trigger72=CreateTrigger()
        call TriggerRegisterEnterRectSimple(udg_trigger72, udg_rect40)
        call TriggerAddCondition(udg_trigger72, Condition(function Trig_Shadow_Hunter_Conditions))
        call TriggerAddAction(udg_trigger72, function Trig_Shadow_Hunter_Actions)
        set udg_trigger73=CreateTrigger()
        call TriggerRegisterEnterRectSimple(udg_trigger73, udg_rect24)
        call TriggerAddCondition(udg_trigger73, Condition(function Trig_Warsong_Chieftain_Conditions))
        call TriggerAddAction(udg_trigger73, function Trig_Warsong_Chieftain_Actions)
        set udg_trigger74=CreateTrigger()
        call TriggerRegisterEnterRectSimple(udg_trigger74, udg_rect07)
        call TriggerAddCondition(udg_trigger74, Condition(function Trig_Crypt_Lord_Conditions))
        call TriggerAddAction(udg_trigger74, function Trig_Crypt_Lord_Actions)
        set udg_trigger75=CreateTrigger()
        call TriggerRegisterEnterRectSimple(udg_trigger75, udg_rect08)
        call TriggerAddCondition(udg_trigger75, Condition(function Trig_Death_Knight_Conditions))
        call TriggerAddAction(udg_trigger75, function Trig_Death_Knight_Actions)
        set udg_trigger76=CreateTrigger()
        call TriggerRegisterEnterRectSimple(udg_trigger76, udg_rect10)
        call TriggerAddCondition(udg_trigger76, Condition(function Trig_Dreadlord_Conditions))
        call TriggerAddAction(udg_trigger76, function Trig_Dreadlord_Actions)
        set udg_trigger77=CreateTrigger()
        call TriggerRegisterEnterRectSimple(udg_trigger77, udg_rect25)
        call TriggerAddCondition(udg_trigger77, Condition(function Trig_Lich_Conditions))
        call TriggerAddAction(udg_trigger77, function Trig_Lich_Actions)
        set udg_trigger78=CreateTrigger()
        call TriggerRegisterEnterRectSimple(udg_trigger78, udg_rect27)
        call TriggerAddCondition(udg_trigger78, Condition(function Trig_Nigromante_Conditions))
        call TriggerAddAction(udg_trigger78, function Trig_Nigromante_Actions)
        set udg_trigger79=CreateTrigger()
        call TriggerRegisterEnterRectSimple(udg_trigger79, udg_rect14)
        call TriggerAddCondition(udg_trigger79, Condition(function Trig_Firelord_Conditions))
        call TriggerAddAction(udg_trigger79, function Trig_Firelord_Actions)
        set udg_trigger80=CreateTrigger()
        call TriggerRegisterEnterRectSimple(udg_trigger80, udg_rect43)
        call TriggerAddCondition(udg_trigger80, Condition(function Trig_Dark_Ranger_Conditions))
        call TriggerAddAction(udg_trigger80, function Trig_Dark_Ranger_Actions)
        set udg_trigger81=CreateTrigger()
        call TriggerRegisterEnterRectSimple(udg_trigger81, udg_rect44)
        call TriggerAddCondition(udg_trigger81, Condition(function Trig_Storm_Conditions))
        call TriggerAddAction(udg_trigger81, function Trig_Storm_Actions)
    endif
	set udg_trigger82=CreateTrigger()
	call TriggerRegisterPlayerUnitEventSimple(udg_trigger82, Player(0), EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger82, Condition(function Trig_Revive_Human_hero_player_1_Conditions))
	call TriggerAddAction(udg_trigger82, function Trig_Revive_Human_hero_player_1_Actions)
	set udg_trigger83=CreateTrigger()
	call TriggerRegisterPlayerUnitEventSimple(udg_trigger83, Player(1), EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger83, Condition(function Trig_Revive_Human_hero_player_2_Conditions))
	call TriggerAddAction(udg_trigger83, function Trig_Revive_Human_hero_player_2_Actions)
	set udg_trigger84=CreateTrigger()
	call TriggerRegisterPlayerUnitEventSimple(udg_trigger84, Player(2), EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger84, Condition(function Trig_Revive_Human_hero_player_3_Conditions))
	call TriggerAddAction(udg_trigger84, function Trig_Revive_Human_hero_player_3_Actions)
	set udg_trigger85=CreateTrigger()
	call TriggerRegisterPlayerUnitEventSimple(udg_trigger85, Player(3), EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger85, Condition(function Trig_Revive_Human_hero_player_4_Conditions))
	call TriggerAddAction(udg_trigger85, function Trig_Revive_Human_hero_player_4_Actions)
	set udg_trigger86=CreateTrigger()
	call TriggerRegisterPlayerUnitEventSimple(udg_trigger86, Player(4), EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger86, Condition(function Trig_Revive_Human_hero_player_5_Conditions))
	call TriggerAddAction(udg_trigger86, function Trig_Revive_Human_hero_player_5_Actions)
	set udg_trigger87=CreateTrigger()
	call TriggerRegisterPlayerUnitEventSimple(udg_trigger87, Player(5), EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger87, Condition(function Trig_Revive_Orc_hero_player_6_Conditions))
	call TriggerAddAction(udg_trigger87, function Trig_Revive_Orc_hero_player_6_Actions)
	set udg_trigger88=CreateTrigger()
	call TriggerRegisterPlayerUnitEventSimple(udg_trigger88, Player(6), EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger88, Condition(function Trig_Revive_Orc_hero_player_7_Conditions))
	call TriggerAddAction(udg_trigger88, function Trig_Revive_Orc_hero_player_7_Actions)
	set udg_trigger89=CreateTrigger()
	call TriggerRegisterPlayerUnitEventSimple(udg_trigger89, Player(7), EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger89, Condition(function Trig_Revive_Orc_hero_player_8_Conditions))
	call TriggerAddAction(udg_trigger89, function Trig_Revive_Orc_hero_player_8_Actions)
	set udg_trigger90=CreateTrigger()
	call TriggerRegisterPlayerUnitEventSimple(udg_trigger90, Player(8), EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger90, Condition(function Trig_Revive_Orc_hero_player_9_Conditions))
	call TriggerAddAction(udg_trigger90, function Trig_Revive_Orc_hero_player_9_Actions)
	set udg_trigger91=CreateTrigger()
	call TriggerRegisterPlayerUnitEventSimple(udg_trigger91, Player(9), EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger91, Condition(function Trig_Revive_Orc_hero_player_10_Conditions))
	call TriggerAddAction(udg_trigger91, function Trig_Revive_Orc_hero_player_10_Actions)
	set udg_trigger92=CreateTrigger()
	call TriggerRegisterAnyUnitEventBJ(udg_trigger92, EVENT_PLAYER_UNIT_SPELL_CAST)
	call TriggerAddCondition(udg_trigger92, Condition(function Trig_Blademaster_Invul_Blade_Conditions))
	call TriggerAddAction(udg_trigger92, function Trig_Blademaster_Invul_Blade_Actions)
	set udg_trigger93=CreateTrigger()
	call TriggerAddAction(udg_trigger93, function Trig_Help_Actions)
	set udg_trigger94=CreateTrigger()
	call TriggerRegisterPlayerChatEvent(udg_trigger94, Player(0), "-ma", true)
	call TriggerRegisterPlayerChatEvent(udg_trigger94, Player(1), "-ma", true)
	call TriggerRegisterPlayerChatEvent(udg_trigger94, Player(2), "-ma", true)
	call TriggerRegisterPlayerChatEvent(udg_trigger94, Player(3), "-ma", true)
	call TriggerRegisterPlayerChatEvent(udg_trigger94, Player(4), "-ma", true)
	call TriggerRegisterPlayerChatEvent(udg_trigger94, Player(5), "-ma", true)
	call TriggerRegisterPlayerChatEvent(udg_trigger94, Player(6), "-ma", true)
	call TriggerRegisterPlayerChatEvent(udg_trigger94, Player(7), "-ma", true)
	call TriggerRegisterPlayerChatEvent(udg_trigger94, Player(8), "-ma", true)
	call TriggerRegisterPlayerChatEvent(udg_trigger94, Player(9), "-ma", true)
	call TriggerAddAction(udg_trigger94, function Trig_Matchup_Actions)
	set udg_trigger95=CreateTrigger()
	call TriggerRegisterPlayerChatEvent(udg_trigger95, Player(0), "-ms", true)
	call TriggerRegisterPlayerChatEvent(udg_trigger95, Player(1), "-ms", true)
	call TriggerRegisterPlayerChatEvent(udg_trigger95, Player(2), "-ms", true)
	call TriggerRegisterPlayerChatEvent(udg_trigger95, Player(3), "-ms", true)
	call TriggerRegisterPlayerChatEvent(udg_trigger95, Player(4), "-ms", true)
	call TriggerRegisterPlayerChatEvent(udg_trigger95, Player(5), "-ms", true)
	call TriggerRegisterPlayerChatEvent(udg_trigger95, Player(6), "-ms", true)
	call TriggerRegisterPlayerChatEvent(udg_trigger95, Player(7), "-ms", true)
	call TriggerRegisterPlayerChatEvent(udg_trigger95, Player(8), "-ms", true)
	call TriggerRegisterPlayerChatEvent(udg_trigger95, Player(9), "-ms", true)
	call TriggerAddAction(udg_trigger95, function Trig_Movespeed_Actions)
	set udg_trigger96=CreateTrigger()
	call TriggerRegisterPlayerEventLeave(udg_trigger96, Player(0))
	call TriggerRegisterPlayerEventDefeat(udg_trigger96, Player(0))
	call TriggerRegisterPlayerEventLeave(udg_trigger96, Player(1))
	call TriggerRegisterPlayerEventDefeat(udg_trigger96, Player(1))
	call TriggerRegisterPlayerEventLeave(udg_trigger96, Player(2))
	call TriggerRegisterPlayerEventDefeat(udg_trigger96, Player(2))
	call TriggerRegisterPlayerEventLeave(udg_trigger96, Player(3))
	call TriggerRegisterPlayerEventDefeat(udg_trigger96, Player(3))
	call TriggerRegisterPlayerEventLeave(udg_trigger96, Player(4))
	call TriggerRegisterPlayerEventDefeat(udg_trigger96, Player(4))
	//call TriggerAddAction(udg_trigger96,function Trig_Item_Drop_Humanos_Actions)
	set udg_trigger97=CreateTrigger()
	call TriggerRegisterPlayerEventLeave(udg_trigger97, Player(5))
	call TriggerRegisterPlayerEventDefeat(udg_trigger97, Player(5))
	call TriggerRegisterPlayerEventLeave(udg_trigger97, Player(6))
	call TriggerRegisterPlayerEventDefeat(udg_trigger97, Player(6))
	call TriggerRegisterPlayerEventLeave(udg_trigger97, Player(7))
	call TriggerRegisterPlayerEventDefeat(udg_trigger97, Player(7))
	call TriggerRegisterPlayerEventLeave(udg_trigger97, Player(8))
	call TriggerRegisterPlayerEventDefeat(udg_trigger97, Player(8))
	call TriggerRegisterPlayerEventLeave(udg_trigger97, Player(9))
	call TriggerRegisterPlayerEventDefeat(udg_trigger97, Player(9))
	//call TriggerAddAction(udg_trigger97,function Trig_Item_Drop_Orcos_Actions)
	set udg_trigger98=CreateTrigger()
	call DisableTrigger(udg_trigger98)
	call TriggerRegisterTimerEventPeriodic(udg_trigger98, 1.00)
	call TriggerAddAction(udg_trigger98, function Trig_Cash_1_Actions)
	set udg_trigger99=CreateTrigger()
	call DisableTrigger(udg_trigger99)
	call TriggerRegisterTimerEventPeriodic(udg_trigger99, 1.00)
	call TriggerAddAction(udg_trigger99, function Trig_Cash_2_Actions)
	set udg_trigger100=CreateTrigger()
	call DisableTrigger(udg_trigger100)
	call TriggerRegisterTimerEventPeriodic(udg_trigger100, 1.00)
	call TriggerAddAction(udg_trigger100, function Trig_Cash_3_Actions)
	set udg_trigger101=CreateTrigger()
	call TriggerAddAction(udg_trigger101, function Trig_Bounty_Actions)
	set udg_trigger102=CreateTrigger()
	call TriggerRegisterPlayerUnitEventSimple(udg_trigger102, Player(11), EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger102, Condition(function Trig_Humans_bounty_Conditions))
	call TriggerAddAction(udg_trigger102, function Trig_Humans_bounty_Actions)
	set udg_trigger103=CreateTrigger()
	call TriggerRegisterPlayerUnitEventSimple(udg_trigger103, Player(11), EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger103, Condition(function Trig_Humans_bounty_2_Conditions))
	call TriggerAddAction(udg_trigger103, function Trig_Humans_bounty_2_Actions)
	set udg_trigger104=CreateTrigger()
	call TriggerRegisterPlayerUnitEventSimple(udg_trigger104, Player(11), EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger104, Condition(function Trig_Humans_bounty_3_Conditions))
	call TriggerAddAction(udg_trigger104, function Trig_Humans_bounty_3_Actions)
	set udg_trigger105=CreateTrigger()
	call TriggerRegisterPlayerUnitEventSimple(udg_trigger105, Player(11), EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger105, Condition(function Trig_Humans_bounty_4_Conditions))
	call TriggerAddAction(udg_trigger105, function Trig_Humans_bounty_4_Actions)
	set udg_trigger106=CreateTrigger()
	call TriggerRegisterPlayerUnitEventSimple(udg_trigger106, Player(11), EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger106, Condition(function Trig_Humans_bounty_5_Conditions))
	call TriggerAddAction(udg_trigger106, function Trig_Humans_bounty_5_Actions)
	set udg_trigger107=CreateTrigger()
	call TriggerRegisterPlayerUnitEventSimple(udg_trigger107, Player(11), EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger107, Condition(function Trig_Humans_bounty_6_Conditions))
	call TriggerAddAction(udg_trigger107, function Trig_Humans_bounty_6_Actions)
	set udg_trigger108=CreateTrigger()
	call TriggerRegisterPlayerUnitEventSimple(udg_trigger108, Player(10), EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger108, Condition(function Trig_Orcs_bounty_Conditions))
	call TriggerAddAction(udg_trigger108, function Trig_Orcs_bounty_Actions)
	set udg_trigger109=CreateTrigger()
	call TriggerRegisterPlayerUnitEventSimple(udg_trigger109, Player(10), EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger109, Condition(function Trig_Orcs_bounty_2_Conditions))
	call TriggerAddAction(udg_trigger109, function Trig_Orcs_bounty_2_Actions)
	set udg_trigger110=CreateTrigger()
	call TriggerRegisterPlayerUnitEventSimple(udg_trigger110, Player(10), EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger110, Condition(function Trig_Orcs_bounty_3_Conditions))
	call TriggerAddAction(udg_trigger110, function Trig_Orcs_bounty_3_Actions)
	set udg_trigger111=CreateTrigger()
	call TriggerRegisterPlayerUnitEventSimple(udg_trigger111, Player(10), EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger111, Condition(function Trig_Orcs_bounty_4_Conditions))
	call TriggerAddAction(udg_trigger111, function Trig_Orcs_bounty_4_Actions)
	set udg_trigger112=CreateTrigger()
	call TriggerRegisterPlayerUnitEventSimple(udg_trigger112, Player(10), EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger112, Condition(function Trig_Orcs_bounty_5_Conditions))
	call TriggerAddAction(udg_trigger112, function Trig_Orcs_bounty_5_Actions)
	set udg_trigger113=CreateTrigger()
	call TriggerRegisterPlayerUnitEventSimple(udg_trigger113, Player(10), EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger113, Condition(function Trig_Orcs_bounty_6_Conditions))
	call TriggerAddAction(udg_trigger113, function Trig_Orcs_bounty_6_Actions)
	set udg_trigger114=CreateTrigger()
	call TriggerAddAction(udg_trigger114, function Trig_Kill_Actions)
	set udg_trigger115=CreateTrigger()
	call TriggerRegisterUnitEvent(udg_trigger115, udg_unit19, EVENT_UNIT_DEATH)
	call TriggerAddAction(udg_trigger115, function Trig_Lose_for_humans_Actions)
	set udg_trigger116=CreateTrigger()
	call TriggerRegisterUnitEvent(udg_trigger116, udg_unit24, EVENT_UNIT_DEATH)
	call TriggerAddAction(udg_trigger116, function Trig_Lose_for_Orcs_Actions)
	set udg_trigger117=CreateTrigger()
	call TriggerRegisterAnyUnitEventBJ(udg_trigger117, EVENT_PLAYER_UNIT_SPELL_EFFECT)
	call TriggerAddCondition(udg_trigger117, Condition(function Trig_Fissure_Conditions))
	call TriggerAddAction(udg_trigger117, function Trig_Fissure_Actions)
	set udg_trigger118=CreateTrigger()
	call TriggerRegisterAnyUnitEventBJ(udg_trigger118, EVENT_PLAYER_UNIT_PICKUP_ITEM)
	call TriggerAddCondition(udg_trigger118, Condition(function Trig_Wand_of_Negation_Combination_Conditions))
	call TriggerAddAction(udg_trigger118, function Trig_Wand_of_Negation_Combination_Actions)
	set udg_trigger119=CreateTrigger()
	call TriggerRegisterAnyUnitEventBJ(udg_trigger119, EVENT_PLAYER_UNIT_PICKUP_ITEM)
	call TriggerAddCondition(udg_trigger119, Condition(function Trig_Finger_of_Harm_Upgrade_1_Conditions))
	call TriggerAddAction(udg_trigger119, function Trig_Finger_of_Harm_Upgrade_1_Actions)
	call ConditionalTriggerExecute(udg_trigger03)
	call ConditionalTriggerExecute(udg_trigger33)
	call ConditionalTriggerExecute(udg_trigger35)
	call ConditionalTriggerExecute(udg_trigger93)
	call ConditionalTriggerExecute(udg_trigger101)
	call ConditionalTriggerExecute(udg_trigger114)
endfunction

//===========================================================================
//***************************************************************************
//*
//*Players
//*
//***************************************************************************
//***************************************************************************
//*
//*Main Initialization
//*
//***************************************************************************
//===========================================================================
function main3 takes nothing returns nothing
    local weathereffect we
	call SetCameraBounds(- 6528.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), - 3328.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 6528.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 2816.0 - GetCameraMargin(CAMERA_MARGIN_TOP), - 6528.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 2816.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 6528.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), - 3328.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
	call SetDayNightModels("Environment\\DNC\\DNCAshenvale\\DNCAshenvaleTerrain\\DNCAshenvaleTerrain.mdl", "Environment\\DNC\\DNCAshenvale\\DNCAshenvaleUnit\\DNCAshenvaleUnit.mdl")
	call SetTerrainFogEx(0, 1900.0, 2900.0, 0.500, 0.502, 0.502, 0.502)
	call SetWaterBaseColor(255, 0, 0, 255)
	set we=AddWeatherEffect(Rect(- 8192.0, - 4096.0, 8192.0, 4096.0), 'RAhr')
	call EnableWeatherEffect(we, true)
	call NewSoundEnvironment("Default")
	call SetAmbientDaySound("NorthrendDay")
	call SetAmbientNightSound("NorthrendNight")
	call SetMapMusic("Music", true, 0)
	call InitGlobals3()
	
	call ExecuteFunc("main2")
endfunction

//***************************************************************************
//*
//*Map Configuration
//*
//***************************************************************************
function InitTrig_init takes nothing returns nothing
	
	call ExecuteFunc("main3")
endfunction

//===========================================================================
// Trigger: IA_Logic_Survival
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0
// Trigger: Colmillo de Hakkar
//===========================================================================
function Trig_Colmillo_de_Hakkar_Conditions takes nothing returns boolean
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00C')) == 'I00C' ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00D')) == 'I00D' ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00E')) == 'I00E' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Colmillo_de_Hakkar_Actions takes nothing returns nothing
    // Cuando una unidad aqdquiera un objeto revisas si tiene lo necesario para armar esta receta, en caso que lo tenga eliminas los items necesarios y le das el objeto armado al heroe
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00C'))
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00D'))
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00E'))
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call UnitAddItemByIdSwapped('I01L', GetTriggerUnit())
endfunction

//===========================================================================
function InitTrig_Colmillo_de_Hakkar takes nothing returns nothing
    set gg_trg_Colmillo_de_Hakkar=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Colmillo_de_Hakkar, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    call TriggerAddCondition(gg_trg_Colmillo_de_Hakkar, Condition(function Trig_Colmillo_de_Hakkar_Conditions))
    call TriggerAddAction(gg_trg_Colmillo_de_Hakkar, function Trig_Colmillo_de_Hakkar_Actions)
endfunction

//===========================================================================
// Trigger: Garra de Mannoroth
//===========================================================================
function Trig_Garra_de_Mannoroth_Conditions takes nothing returns boolean
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I008')) == 'I008' ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I009')) == 'I009' ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00A')) == 'I00A' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Garra_de_Mannoroth_Actions takes nothing returns nothing
    // Cuando una unidad aqdquiera un objeto revisas si tiene lo necesario para armar esta receta, en caso que lo tenga eliminas los items necesarios y le das el objeto armado al heroe
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I008'))
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I009'))
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00A'))
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call UnitAddItemByIdSwapped('I01K', GetTriggerUnit())
endfunction

//===========================================================================
function InitTrig_Garra_de_Mannoroth takes nothing returns nothing
    set gg_trg_Garra_de_Mannoroth=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Garra_de_Mannoroth, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    call TriggerAddCondition(gg_trg_Garra_de_Mannoroth, Condition(function Trig_Garra_de_Mannoroth_Conditions))
    call TriggerAddAction(gg_trg_Garra_de_Mannoroth, function Trig_Garra_de_Mannoroth_Actions)
endfunction

//===========================================================================
// Trigger: Cetro de Kel Thuzad
//===========================================================================
function Trig_Cetro_de_Kel_Thuzad_Conditions takes nothing returns boolean
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00G')) == 'I00G' ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00H')) == 'I00H' ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00I')) == 'I00I' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Cetro_de_Kel_Thuzad_Actions takes nothing returns nothing
    // Cuando una unidad aqdquiera un objeto revisas si tiene lo necesario para armar esta receta, en caso que lo tenga eliminas los items necesarios y le das el objeto armado al heroe
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00G'))
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00H'))
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00I'))
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call UnitAddItemByIdSwapped('I01M', GetTriggerUnit())
endfunction

//===========================================================================
function InitTrig_Cetro_de_Kel_Thuzad takes nothing returns nothing
    set gg_trg_Cetro_de_Kel_Thuzad=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Cetro_de_Kel_Thuzad, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    call TriggerAddCondition(gg_trg_Cetro_de_Kel_Thuzad, Condition(function Trig_Cetro_de_Kel_Thuzad_Conditions))
    call TriggerAddAction(gg_trg_Cetro_de_Kel_Thuzad, function Trig_Cetro_de_Kel_Thuzad_Actions)
endfunction

//===========================================================================
// Trigger: Manto de Maiev
//===========================================================================
function Trig_Manto_de_Maiev_Conditions takes nothing returns boolean
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00R')) == 'I00R' ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00S')) == 'I00S' ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00K')) == 'I00K' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Manto_de_Maiev_Actions takes nothing returns nothing
    // Cuando una unidad aqdquiera un objeto revisas si tiene lo necesario para armar esta receta, en caso que lo tenga eliminas los items necesarios y le das el objeto armado al heroe
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00R'))
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00S'))
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00K'))
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call UnitAddItemByIdSwapped('I01N', GetTriggerUnit())
endfunction

//===========================================================================
function InitTrig_Manto_de_Maiev takes nothing returns nothing
    set gg_trg_Manto_de_Maiev=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Manto_de_Maiev, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    call TriggerAddCondition(gg_trg_Manto_de_Maiev, Condition(function Trig_Manto_de_Maiev_Conditions))
    call TriggerAddAction(gg_trg_Manto_de_Maiev, function Trig_Manto_de_Maiev_Actions)
endfunction

//===========================================================================
// Trigger: Vestiduras de Ner zhul
//===========================================================================
function Trig_Vestiduras_de_Ner_zhul_Conditions takes nothing returns boolean
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00N')) == 'I00N' ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00O')) == 'I00O' ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00P')) == 'I00P' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Vestiduras_de_Ner_zhul_Actions takes nothing returns nothing
    // Cuando una unidad aqdquiera un objeto revisas si tiene lo necesario para armar esta receta, en caso que lo tenga eliminas los items necesarios y le das el objeto armado al heroe
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00N'))
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00O'))
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00P'))
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call UnitAddItemByIdSwapped('I01O', GetTriggerUnit())
endfunction

//===========================================================================
function InitTrig_Vestiduras_de_Ner_zhul takes nothing returns nothing
    set gg_trg_Vestiduras_de_Ner_zhul=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Vestiduras_de_Ner_zhul, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    call TriggerAddCondition(gg_trg_Vestiduras_de_Ner_zhul, Condition(function Trig_Vestiduras_de_Ner_zhul_Conditions))
    call TriggerAddAction(gg_trg_Vestiduras_de_Ner_zhul, function Trig_Vestiduras_de_Ner_zhul_Actions)
endfunction

//===========================================================================
// Trigger: Baluarte de Lothar
//===========================================================================
function Trig_Baluarte_de_Lothar_Conditions takes nothing returns boolean
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00J')) == 'I00J' ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00L')) == 'I00L' ) ) then
        return false
    endif
    if ( not ( GetItemTypeId(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00T')) == 'I00T' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Baluarte_de_Lothar_Actions takes nothing returns nothing
    // Cuando una unidad aqdquiera un objeto revisas si tiene lo necesario para armar esta receta, en caso que lo tenga eliminas los items necesarios y le das el objeto armado al heroe
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00J'))
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00L'))
    call RemoveItem(GetItemOfTypeFromUnitBJ(GetTriggerUnit(), 'I00T'))
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call AddSpecialEffectLocBJ(GetUnitLoc(GetTriggerUnit()), "Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl")
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
    call UnitAddItemByIdSwapped('I01P', GetTriggerUnit())
endfunction

//===========================================================================
function InitTrig_Baluarte_de_Lothar takes nothing returns nothing
    set gg_trg_Baluarte_de_Lothar=CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Baluarte_de_Lothar, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    call TriggerAddCondition(gg_trg_Baluarte_de_Lothar, Condition(function Trig_Baluarte_de_Lothar_Conditions))
    call TriggerAddAction(gg_trg_Baluarte_de_Lothar, function Trig_Baluarte_de_Lothar_Actions)
endfunction

//===========================================================================
function InitCustomTriggers takes nothing returns nothing
    //Function not found: call InitTrig_IA_Brain_Macro()
    //Function not found: call InitTrig_IA_Logic_Laning()
    //Function not found: call InitTrig_IA_Data()
    //Function not found: call InitTrig_IA_Core()
    //Function not found: call InitTrig_IA_Utils()
    call InitTrig_IA_Cerebro_Loop()
    call InitTrig_IA_Arrancar()
    call InitTrig_IA_Permisos()
    call InitTrig_Core_Indice_Heroes()
    call InitTrig_Core_Logica_Random()
    call InitTrig_Core_Menu_Heroes_Click()
    call InitTrig_Core_Menu_Heroes()
    call InitTrig_Core_Mecanica_Oro()
    call InitTrig_Core_Menu_Click()
    call InitTrig_Core_Menu_Oro()
    call InitTrig_Core_DetectarHost()
    call InitTrig_Pick_01_Guardian_del_Bosque()
    call InitTrig_Pick_02_Sacerdotisa_de_la_Luna()
    call InitTrig_Pick_03_Cazador_de_Demonios()
    call InitTrig_Pick_04_Guardiana()
    call InitTrig_Pick_05_Paladin()
    call InitTrig_Pick_06_Archimago()
    call InitTrig_Pick_07_Rey_de_la_Montana()
    call InitTrig_Pick_08_Mago_sanguinario()
    call InitTrig_Pick_09_Alquimista()
    call InitTrig_Pick_10_Hojalatero()
    call InitTrig_Pick_11_Alquimista_pandaren()
    call InitTrig_Pick_12_Lord_Garithos()
    call InitTrig_Pick_13_SylvanasH()
    call InitTrig_Pick_14_Asesina()
    call InitTrig_Pick_15_Goblin_Techies()
    call InitTrig_Pick_16_Sniper()
    call InitTrig_Pick_17_Bandido()
    call InitTrig_Pick_18_Magnadefender()
    call InitTrig_Pick_19_CoCo()
    call InitTrig_Pick_20_DarthRemar()
    call InitTrig_Pick_21_Maestro_de_las_Espadas()
    call InitTrig_Pick_22_Vidente()
    call InitTrig_Pick_23_Jefe_Tauren()
    call InitTrig_Pick_24_Cazador_de_sombras()
    call InitTrig_Pick_25_Caballero_de_la_Muerte()
    call InitTrig_Pick_26_Lich()
    call InitTrig_Pick_27_Senor_del_terror()
    call InitTrig_Pick_28_Senor_de_la_cripta()
    call InitTrig_Pick_29_Bruja_de_mar_naga()
    call InitTrig_Pick_30_Senor_de_las_bestias()
    call InitTrig_Pick_31_Senor_del_Fuego()
    call InitTrig_Pick_32_Senor_del_foso()
    call InitTrig_Pick_33_Nigromante()
    call InitTrig_Pick_34_Grom_Hellscream()
    call InitTrig_Pick_35_SylvanasO()
    call InitTrig_Pick_36_Butcher_Abomination()
    call InitTrig_Pick_37_Naga_Royal()
    call InitTrig_Pick_38_Summoner_of_the_Thunder()
    call InitTrig_Pick_39_Troll_Berserker()
    call InitTrig_Habilidad_Techies_Barril()
    call InitTrig_Hook_TH()
    call InitTrig_Hook_Init()
    call InitTrig_Hook_Loop()
    call InitTrig_Mega_Armadura_Fuerza()
    call InitTrig_Mega_Armadura_Agilidad()
    call InitTrig_Mega_Armadura_Inteligencia()
    call InitTrig_Mega_Impacto_de_Dano()
    call InitTrig_Mega_Hacha_Unicas()
    call InitTrig_Mega_Libro_de_Ataque()
    call InitTrig_Power_Treads()
    call InitTrig_Fuerza_a_Inteligencia()
    call InitTrig_Inteligencia_a_Agilidad()
    call InitTrig_Agilidad_a_Fuerza()
    call InitTrig_Botas_de_TP()
    call InitTrig_Sistema_Deny()
    call InitTrig_Sistema_Anuncios()
    call InitTrig_Sistema_Cheat()
    call InitTrig_Comando_Bounty()
    call InitTrig_Sistema_Bounty_Track()
    call InitTrig_Sistema_Kick()
    call InitTrig_tabla()
    call InitTrig_Zoom()
    call ExecuteFunc("main3") // INLINED!!
    //Function not found: call InitTrig_IA_Logic_Survival()
    call InitTrig_Colmillo_de_Hakkar()
    call InitTrig_Garra_de_Mannoroth()
    call InitTrig_Cetro_de_Kel_Thuzad()
    call InitTrig_Manto_de_Maiev()
    call InitTrig_Vestiduras_de_Ner_zhul()
    call InitTrig_Baluarte_de_Lothar()
endfunction

//===========================================================================
function RunInitializationTriggers takes nothing returns nothing
    call ConditionalTriggerExecute(gg_trg_Core_Indice_Heroes)
    call ConditionalTriggerExecute(gg_trg_Hook_TH)
endfunction

//***************************************************************************
//*
//*  Players
//*
//***************************************************************************

function InitCustomPlayerSlots takes nothing returns nothing

    // Player 0
    call SetPlayerStartLocation(Player(0), 0)
    call ForcePlayerStartLocation(Player(0), 0)
    call SetPlayerColor(Player(0), ConvertPlayerColor(0))
    call SetPlayerRacePreference(Player(0), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(0), false)
    call SetPlayerController(Player(0), MAP_CONTROL_USER)

    // Player 1
    call SetPlayerStartLocation(Player(1), 1)
    call ForcePlayerStartLocation(Player(1), 1)
    call SetPlayerColor(Player(1), ConvertPlayerColor(1))
    call SetPlayerRacePreference(Player(1), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(1), false)
    call SetPlayerController(Player(1), MAP_CONTROL_USER)

    // Player 2
    call SetPlayerStartLocation(Player(2), 2)
    call ForcePlayerStartLocation(Player(2), 2)
    call SetPlayerColor(Player(2), ConvertPlayerColor(2))
    call SetPlayerRacePreference(Player(2), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(2), false)
    call SetPlayerController(Player(2), MAP_CONTROL_USER)

    // Player 3
    call SetPlayerStartLocation(Player(3), 3)
    call ForcePlayerStartLocation(Player(3), 3)
    call SetPlayerColor(Player(3), ConvertPlayerColor(3))
    call SetPlayerRacePreference(Player(3), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(3), false)
    call SetPlayerController(Player(3), MAP_CONTROL_USER)

    // Player 4
    call SetPlayerStartLocation(Player(4), 4)
    call ForcePlayerStartLocation(Player(4), 4)
    call SetPlayerColor(Player(4), ConvertPlayerColor(4))
    call SetPlayerRacePreference(Player(4), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(4), false)
    call SetPlayerController(Player(4), MAP_CONTROL_USER)

    // Player 5
    call SetPlayerStartLocation(Player(5), 5)
    call ForcePlayerStartLocation(Player(5), 5)
    call SetPlayerColor(Player(5), ConvertPlayerColor(5))
    call SetPlayerRacePreference(Player(5), RACE_PREF_ORC)
    call SetPlayerRaceSelectable(Player(5), false)
    call SetPlayerController(Player(5), MAP_CONTROL_USER)

    // Player 6
    call SetPlayerStartLocation(Player(6), 6)
    call ForcePlayerStartLocation(Player(6), 6)
    call SetPlayerColor(Player(6), ConvertPlayerColor(6))
    call SetPlayerRacePreference(Player(6), RACE_PREF_ORC)
    call SetPlayerRaceSelectable(Player(6), false)
    call SetPlayerController(Player(6), MAP_CONTROL_USER)

    // Player 7
    call SetPlayerStartLocation(Player(7), 7)
    call ForcePlayerStartLocation(Player(7), 7)
    call SetPlayerColor(Player(7), ConvertPlayerColor(7))
    call SetPlayerRacePreference(Player(7), RACE_PREF_ORC)
    call SetPlayerRaceSelectable(Player(7), false)
    call SetPlayerController(Player(7), MAP_CONTROL_USER)

    // Player 8
    call SetPlayerStartLocation(Player(8), 8)
    call ForcePlayerStartLocation(Player(8), 8)
    call SetPlayerColor(Player(8), ConvertPlayerColor(8))
    call SetPlayerRacePreference(Player(8), RACE_PREF_ORC)
    call SetPlayerRaceSelectable(Player(8), false)
    call SetPlayerController(Player(8), MAP_CONTROL_USER)

    // Player 9
    call SetPlayerStartLocation(Player(9), 9)
    call ForcePlayerStartLocation(Player(9), 9)
    call SetPlayerColor(Player(9), ConvertPlayerColor(9))
    call SetPlayerRacePreference(Player(9), RACE_PREF_ORC)
    call SetPlayerRaceSelectable(Player(9), false)
    call SetPlayerController(Player(9), MAP_CONTROL_USER)

    // Player 10
    call SetPlayerStartLocation(Player(10), 10)
    call ForcePlayerStartLocation(Player(10), 10)
    call SetPlayerColor(Player(10), ConvertPlayerColor(10))
    call SetPlayerRacePreference(Player(10), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(10), false)
    call SetPlayerController(Player(10), MAP_CONTROL_COMPUTER)

    // Player 11
    call SetPlayerStartLocation(Player(11), 11)
    call ForcePlayerStartLocation(Player(11), 11)
    call SetPlayerColor(Player(11), ConvertPlayerColor(11))
    call SetPlayerRacePreference(Player(11), RACE_PREF_ORC)
    call SetPlayerRaceSelectable(Player(11), false)
    call SetPlayerController(Player(11), MAP_CONTROL_COMPUTER)

endfunction

function InitCustomTeams takes nothing returns nothing
    // Force: TRIGSTR_5587
    call SetPlayerTeam(Player(0), 0)
    call SetPlayerState(Player(0), PLAYER_STATE_ALLIED_VICTORY, 1)
    call SetPlayerTeam(Player(1), 0)
    call SetPlayerState(Player(1), PLAYER_STATE_ALLIED_VICTORY, 1)
    call SetPlayerTeam(Player(2), 0)
    call SetPlayerState(Player(2), PLAYER_STATE_ALLIED_VICTORY, 1)
    call SetPlayerTeam(Player(3), 0)
    call SetPlayerState(Player(3), PLAYER_STATE_ALLIED_VICTORY, 1)
    call SetPlayerTeam(Player(4), 0)
    call SetPlayerState(Player(4), PLAYER_STATE_ALLIED_VICTORY, 1)
    call SetPlayerTeam(Player(10), 0)
    call SetPlayerState(Player(10), PLAYER_STATE_ALLIED_VICTORY, 1)

    //   Allied
    call SetPlayerAllianceStateAllyBJ(Player(0), Player(1), true)
    call SetPlayerAllianceStateAllyBJ(Player(0), Player(2), true)
    call SetPlayerAllianceStateAllyBJ(Player(0), Player(3), true)
    call SetPlayerAllianceStateAllyBJ(Player(0), Player(4), true)
    call SetPlayerAllianceStateAllyBJ(Player(0), Player(10), true)
    call SetPlayerAllianceStateAllyBJ(Player(1), Player(0), true)
    call SetPlayerAllianceStateAllyBJ(Player(1), Player(2), true)
    call SetPlayerAllianceStateAllyBJ(Player(1), Player(3), true)
    call SetPlayerAllianceStateAllyBJ(Player(1), Player(4), true)
    call SetPlayerAllianceStateAllyBJ(Player(1), Player(10), true)
    call SetPlayerAllianceStateAllyBJ(Player(2), Player(0), true)
    call SetPlayerAllianceStateAllyBJ(Player(2), Player(1), true)
    call SetPlayerAllianceStateAllyBJ(Player(2), Player(3), true)
    call SetPlayerAllianceStateAllyBJ(Player(2), Player(4), true)
    call SetPlayerAllianceStateAllyBJ(Player(2), Player(10), true)
    call SetPlayerAllianceStateAllyBJ(Player(3), Player(0), true)
    call SetPlayerAllianceStateAllyBJ(Player(3), Player(1), true)
    call SetPlayerAllianceStateAllyBJ(Player(3), Player(2), true)
    call SetPlayerAllianceStateAllyBJ(Player(3), Player(4), true)
    call SetPlayerAllianceStateAllyBJ(Player(3), Player(10), true)
    call SetPlayerAllianceStateAllyBJ(Player(4), Player(0), true)
    call SetPlayerAllianceStateAllyBJ(Player(4), Player(1), true)
    call SetPlayerAllianceStateAllyBJ(Player(4), Player(2), true)
    call SetPlayerAllianceStateAllyBJ(Player(4), Player(3), true)
    call SetPlayerAllianceStateAllyBJ(Player(4), Player(10), true)
    call SetPlayerAllianceStateAllyBJ(Player(10), Player(0), true)
    call SetPlayerAllianceStateAllyBJ(Player(10), Player(1), true)
    call SetPlayerAllianceStateAllyBJ(Player(10), Player(2), true)
    call SetPlayerAllianceStateAllyBJ(Player(10), Player(3), true)
    call SetPlayerAllianceStateAllyBJ(Player(10), Player(4), true)

    //   Shared Vision
    call SetPlayerAllianceStateVisionBJ(Player(0), Player(1), true)
    call SetPlayerAllianceStateVisionBJ(Player(0), Player(2), true)
    call SetPlayerAllianceStateVisionBJ(Player(0), Player(3), true)
    call SetPlayerAllianceStateVisionBJ(Player(0), Player(4), true)
    call SetPlayerAllianceStateVisionBJ(Player(0), Player(10), true)
    call SetPlayerAllianceStateVisionBJ(Player(1), Player(0), true)
    call SetPlayerAllianceStateVisionBJ(Player(1), Player(2), true)
    call SetPlayerAllianceStateVisionBJ(Player(1), Player(3), true)
    call SetPlayerAllianceStateVisionBJ(Player(1), Player(4), true)
    call SetPlayerAllianceStateVisionBJ(Player(1), Player(10), true)
    call SetPlayerAllianceStateVisionBJ(Player(2), Player(0), true)
    call SetPlayerAllianceStateVisionBJ(Player(2), Player(1), true)
    call SetPlayerAllianceStateVisionBJ(Player(2), Player(3), true)
    call SetPlayerAllianceStateVisionBJ(Player(2), Player(4), true)
    call SetPlayerAllianceStateVisionBJ(Player(2), Player(10), true)
    call SetPlayerAllianceStateVisionBJ(Player(3), Player(0), true)
    call SetPlayerAllianceStateVisionBJ(Player(3), Player(1), true)
    call SetPlayerAllianceStateVisionBJ(Player(3), Player(2), true)
    call SetPlayerAllianceStateVisionBJ(Player(3), Player(4), true)
    call SetPlayerAllianceStateVisionBJ(Player(3), Player(10), true)
    call SetPlayerAllianceStateVisionBJ(Player(4), Player(0), true)
    call SetPlayerAllianceStateVisionBJ(Player(4), Player(1), true)
    call SetPlayerAllianceStateVisionBJ(Player(4), Player(2), true)
    call SetPlayerAllianceStateVisionBJ(Player(4), Player(3), true)
    call SetPlayerAllianceStateVisionBJ(Player(4), Player(10), true)
    call SetPlayerAllianceStateVisionBJ(Player(10), Player(0), true)
    call SetPlayerAllianceStateVisionBJ(Player(10), Player(1), true)
    call SetPlayerAllianceStateVisionBJ(Player(10), Player(2), true)
    call SetPlayerAllianceStateVisionBJ(Player(10), Player(3), true)
    call SetPlayerAllianceStateVisionBJ(Player(10), Player(4), true)

    // Force: TRIGSTR_5588
    call SetPlayerTeam(Player(5), 1)
    call SetPlayerState(Player(5), PLAYER_STATE_ALLIED_VICTORY, 1)
    call SetPlayerTeam(Player(6), 1)
    call SetPlayerState(Player(6), PLAYER_STATE_ALLIED_VICTORY, 1)
    call SetPlayerTeam(Player(7), 1)
    call SetPlayerState(Player(7), PLAYER_STATE_ALLIED_VICTORY, 1)
    call SetPlayerTeam(Player(8), 1)
    call SetPlayerState(Player(8), PLAYER_STATE_ALLIED_VICTORY, 1)
    call SetPlayerTeam(Player(9), 1)
    call SetPlayerState(Player(9), PLAYER_STATE_ALLIED_VICTORY, 1)
    call SetPlayerTeam(Player(11), 1)
    call SetPlayerState(Player(11), PLAYER_STATE_ALLIED_VICTORY, 1)

    //   Allied
    call SetPlayerAllianceStateAllyBJ(Player(5), Player(6), true)
    call SetPlayerAllianceStateAllyBJ(Player(5), Player(7), true)
    call SetPlayerAllianceStateAllyBJ(Player(5), Player(8), true)
    call SetPlayerAllianceStateAllyBJ(Player(5), Player(9), true)
    call SetPlayerAllianceStateAllyBJ(Player(5), Player(11), true)
    call SetPlayerAllianceStateAllyBJ(Player(6), Player(5), true)
    call SetPlayerAllianceStateAllyBJ(Player(6), Player(7), true)
    call SetPlayerAllianceStateAllyBJ(Player(6), Player(8), true)
    call SetPlayerAllianceStateAllyBJ(Player(6), Player(9), true)
    call SetPlayerAllianceStateAllyBJ(Player(6), Player(11), true)
    call SetPlayerAllianceStateAllyBJ(Player(7), Player(5), true)
    call SetPlayerAllianceStateAllyBJ(Player(7), Player(6), true)
    call SetPlayerAllianceStateAllyBJ(Player(7), Player(8), true)
    call SetPlayerAllianceStateAllyBJ(Player(7), Player(9), true)
    call SetPlayerAllianceStateAllyBJ(Player(7), Player(11), true)
    call SetPlayerAllianceStateAllyBJ(Player(8), Player(5), true)
    call SetPlayerAllianceStateAllyBJ(Player(8), Player(6), true)
    call SetPlayerAllianceStateAllyBJ(Player(8), Player(7), true)
    call SetPlayerAllianceStateAllyBJ(Player(8), Player(9), true)
    call SetPlayerAllianceStateAllyBJ(Player(8), Player(11), true)
    call SetPlayerAllianceStateAllyBJ(Player(9), Player(5), true)
    call SetPlayerAllianceStateAllyBJ(Player(9), Player(6), true)
    call SetPlayerAllianceStateAllyBJ(Player(9), Player(7), true)
    call SetPlayerAllianceStateAllyBJ(Player(9), Player(8), true)
    call SetPlayerAllianceStateAllyBJ(Player(9), Player(11), true)
    call SetPlayerAllianceStateAllyBJ(Player(11), Player(5), true)
    call SetPlayerAllianceStateAllyBJ(Player(11), Player(6), true)
    call SetPlayerAllianceStateAllyBJ(Player(11), Player(7), true)
    call SetPlayerAllianceStateAllyBJ(Player(11), Player(8), true)
    call SetPlayerAllianceStateAllyBJ(Player(11), Player(9), true)

    //   Shared Vision
    call SetPlayerAllianceStateVisionBJ(Player(5), Player(6), true)
    call SetPlayerAllianceStateVisionBJ(Player(5), Player(7), true)
    call SetPlayerAllianceStateVisionBJ(Player(5), Player(8), true)
    call SetPlayerAllianceStateVisionBJ(Player(5), Player(9), true)
    call SetPlayerAllianceStateVisionBJ(Player(5), Player(11), true)
    call SetPlayerAllianceStateVisionBJ(Player(6), Player(5), true)
    call SetPlayerAllianceStateVisionBJ(Player(6), Player(7), true)
    call SetPlayerAllianceStateVisionBJ(Player(6), Player(8), true)
    call SetPlayerAllianceStateVisionBJ(Player(6), Player(9), true)
    call SetPlayerAllianceStateVisionBJ(Player(6), Player(11), true)
    call SetPlayerAllianceStateVisionBJ(Player(7), Player(5), true)
    call SetPlayerAllianceStateVisionBJ(Player(7), Player(6), true)
    call SetPlayerAllianceStateVisionBJ(Player(7), Player(8), true)
    call SetPlayerAllianceStateVisionBJ(Player(7), Player(9), true)
    call SetPlayerAllianceStateVisionBJ(Player(7), Player(11), true)
    call SetPlayerAllianceStateVisionBJ(Player(8), Player(5), true)
    call SetPlayerAllianceStateVisionBJ(Player(8), Player(6), true)
    call SetPlayerAllianceStateVisionBJ(Player(8), Player(7), true)
    call SetPlayerAllianceStateVisionBJ(Player(8), Player(9), true)
    call SetPlayerAllianceStateVisionBJ(Player(8), Player(11), true)
    call SetPlayerAllianceStateVisionBJ(Player(9), Player(5), true)
    call SetPlayerAllianceStateVisionBJ(Player(9), Player(6), true)
    call SetPlayerAllianceStateVisionBJ(Player(9), Player(7), true)
    call SetPlayerAllianceStateVisionBJ(Player(9), Player(8), true)
    call SetPlayerAllianceStateVisionBJ(Player(9), Player(11), true)
    call SetPlayerAllianceStateVisionBJ(Player(11), Player(5), true)
    call SetPlayerAllianceStateVisionBJ(Player(11), Player(6), true)
    call SetPlayerAllianceStateVisionBJ(Player(11), Player(7), true)
    call SetPlayerAllianceStateVisionBJ(Player(11), Player(8), true)
    call SetPlayerAllianceStateVisionBJ(Player(11), Player(9), true)

endfunction

function InitAllyPriorities takes nothing returns nothing

    call SetStartLocPrioCount(0, 1)
    call SetStartLocPrio(0, 0, 1, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(1, 1)
    call SetStartLocPrio(1, 0, 0, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(2, 2)
    call SetStartLocPrio(2, 0, 3, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(2, 1, 4, MAP_LOC_PRIO_LOW)

    call SetStartLocPrioCount(3, 2)
    call SetStartLocPrio(3, 0, 2, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(3, 1, 4, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(4, 2)
    call SetStartLocPrio(4, 0, 2, MAP_LOC_PRIO_LOW)
    call SetStartLocPrio(4, 1, 3, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(5, 1)
    call SetStartLocPrio(5, 0, 6, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(6, 1)
    call SetStartLocPrio(6, 0, 5, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(7, 2)
    call SetStartLocPrio(7, 0, 8, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(7, 1, 9, MAP_LOC_PRIO_LOW)

    call SetStartLocPrioCount(8, 2)
    call SetStartLocPrio(8, 0, 7, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(8, 1, 9, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(9, 2)
    call SetStartLocPrio(9, 0, 7, MAP_LOC_PRIO_LOW)
    call SetStartLocPrio(9, 1, 8, MAP_LOC_PRIO_HIGH)
endfunction

//***************************************************************************
//*
//*  Main Initialization
//*
//***************************************************************************

//===========================================================================
function main takes nothing returns nothing
    local weathereffect we
    call SetCameraBounds(- 6528.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), - 3328.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 6528.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 2816.0 - GetCameraMargin(CAMERA_MARGIN_TOP), - 6528.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 2816.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 6528.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), - 3328.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
    call SetDayNightModels("Environment\\DNC\\DNCAshenvale\\DNCAshenvaleTerrain\\DNCAshenvaleTerrain.mdl", "Environment\\DNC\\DNCAshenvale\\DNCAshenvaleUnit\\DNCAshenvaleUnit.mdl")
    call SetTerrainFogEx(0, 1900.0, 2900.0, 0.500, 0.502, 0.502, 0.502)
    call SetWaterBaseColor(255, 0, 0, 255)
    set we=AddWeatherEffect(Rect(- 8192.0, - 4096.0, 8192.0, 4096.0), 'RAhr')
    call EnableWeatherEffect(we, true)
    call NewSoundEnvironment("Default")
    call SetAmbientDaySound("NorthrendDay")
    call SetAmbientNightSound("NorthrendNight")
    call SetMapMusic("Music", true, 0)
    call InitSounds()
    call CreateRegions()
    call CreateAllUnits()
    call InitBlizzard()

    call ExecuteFunc("jasshelper__init584")

    call InitGlobals()
    call InitCustomTriggers()
    call RunInitializationTriggers()

endfunction

//***************************************************************************
//*
//*  Map Configuration
//*
//***************************************************************************

function config takes nothing returns nothing
    call SetMapName("TRIGSTR_001")
    call SetMapDescription("TRIGSTR_1839")
    call SetPlayers(12)
    call SetTeams(12)
    call SetGamePlacement(MAP_PLACEMENT_TEAMS_TOGETHER)

    call DefineStartLocation(0, - 4416.0, 2112.0)
    call DefineStartLocation(1, - 4352.0, 2048.0)
    call DefineStartLocation(2, - 4224.0, - 2688.0)
    call DefineStartLocation(3, - 4160.0, - 2688.0)
    call DefineStartLocation(4, - 4160.0, - 2624.0)
    call DefineStartLocation(5, 4224.0, 1856.0)
    call DefineStartLocation(6, 4160.0, 1792.0)
    call DefineStartLocation(7, 3904.0, - 2624.0)
    call DefineStartLocation(8, 3904.0, - 2560.0)
    call DefineStartLocation(9, 3840.0, - 2560.0)
    call DefineStartLocation(10, - 4096.0, - 256.0)
    call DefineStartLocation(11, 3840.0, - 256.0)

    // Player setup
    call InitCustomPlayerSlots()
    call InitCustomTeams()
    call InitAllyPriorities()
endfunction




//All initializer functions called in proper order:

function jasshelper__init584 takes nothing returns nothing



endfunction

