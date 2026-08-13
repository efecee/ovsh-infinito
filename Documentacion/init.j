// Map deprotected by X-deprotect (version 2006-10-02) by zibada
// http://dimon.xgm.ru/xdep/
// Visit our modmaking community at http://xgm.ru/


function InitGlobals3 takes nothing returns nothing

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
		exitwhen(i>1)
		set udg_integers01[i]=0
		set i=i+1
	endloop
	set i=0
	loop
		exitwhen(i>1)
		set udg_strings01[i]=""
		set i=i+1
	endloop
	set udg_integer03=0
	set udg_integer04=0
	set i=0
	loop
		exitwhen(i>1)
		set udg_integers02[i]=0
		set i=i+1
	endloop
	set i=0
	loop
		exitwhen(i>1)
		set udg_integers03[i]=0
		set i=i+1
	endloop
	set i=0
	loop
		exitwhen(i>1)
		set udg_strings02[i]=""
		set i=i+1
	endloop
	set udg_integer05=0
	set udg_timer01=CreateTimer()
	set udg_integer06=0
	set udg_group01=CreateGroup()
	set i=0
	loop
		exitwhen(i>1)
		set udg_timers01[i]=CreateTimer()
		set i=i+1
	endloop
	set udg_real01=0
	set udg_real02=20.00
	set udg_boolean01=false
	set udg_boolean02=false
	set udg_force01=CreateForce()
	set udg_group02=CreateGroup()
	set i=0
	loop
		exitwhen(i>12)
		set udg_strings03[i]=""
		set i=i+1
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
		exitwhen(i>1)
		set udg_integers04[i]=0
		set i=i+1
	endloop
	set i=0
	loop
		exitwhen(i>1)
		set udg_integers06[i]=0
		set i=i+1
	endloop
	set udg_integer14=0
	set udg_integer15=0
	set udg_integer16=0
	set i=0
	loop
		exitwhen(i>1)
		set udg_integers09[i]=0
		set i=i+1
	endloop
	set i=0
	loop
		exitwhen(i>1)
		set udg_integers10[i]=0
		set i=i+1
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
		exitwhen(i>1)
		set udg_integers11[i]=0
		set i=i+1
	endloop
	set udg_integer22=0
	set i=0
	loop
		exitwhen(i>1)
		set udg_integers12[i]=0
		set i=i+1
	endloop
	set udg_boolean03=false
	set udg_integer23=0
	set udg_integer24=0
	set udg_integer25=0
	set udg_integer26=0
	set i=0
	loop
		exitwhen(i>1)
		set udg_integers15[i]=0
		set i=i+1
	endloop
	set i=0
	loop
		exitwhen(i>1)
		set udg_integers16[i]=0
		set i=i+1
	endloop
	set udg_integer27=0
	set udg_integer28=0
	set udg_integer29=0
	set udg_force11=CreateForce()
	set udg_force12=CreateForce()
	set i=0
	loop
		exitwhen(i>1)
		set udg_integers17[i]=0
		set i=i+1
	endloop
	set i=0
	loop
		exitwhen(i>1)
		set udg_integers18[i]=0
		set i=i+1
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
		exitwhen(i>1)
		set udg_dialogs01[i]=DialogCreate()
		set i=i+1
	endloop
	set i=0
	loop
		exitwhen(i>1)
		set udg_dialogs02[i]=DialogCreate()
		set i=i+1
	endloop
	set i=0
	loop
		exitwhen(i>1)
		set udg_dialogs03[i]=DialogCreate()
		set i=i+1
	endloop
	set udg_boolean07=false
	set udg_dialog01=DialogCreate()
	set i=0
	loop
		exitwhen(i>1)
		set udg_booleans01[i]=false
		set i=i+1
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
		exitwhen(i>6)
		set udg_booleans02[i]=false
		set i=i+1
	endloop
	set udg_integer43=0
	set udg_integer44=0
	set udg_integer45=0
	set udg_integer46=0
	set i=0
	loop
		exitwhen(i>1)
		set udg_dialogs04[i]=DialogCreate()
		set i=i+1
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
	set udg_unit14=CreateUnit(p,'ewsp',-6015.8,-404.4,260.810)
endfunction

function CreateUnitsForPlayer1 takes nothing returns nothing
	local player p=Player(1)
	local unit u
	local integer unitID
	local trigger t
	local real life
	set udg_unit15=CreateUnit(p,'ewsp',-5727.0,-399.6,296.710)
endfunction

function CreateUnitsForPlayer2 takes nothing returns nothing
	local player p=Player(2)
	local unit u
	local integer unitID
	local trigger t
	local real life
	set udg_unit16=CreateUnit(p,'ewsp',-5869.9,-467.1,166.390)
endfunction

function CreateUnitsForPlayer3 takes nothing returns nothing
	local player p=Player(3)
	local unit u
	local integer unitID
	local trigger t
	local real life
	set udg_unit17=CreateUnit(p,'ewsp',-5962.0,-571.0,278.580)
endfunction

function CreateUnitsForPlayer4 takes nothing returns nothing
	local player p=Player(4)
	local unit u
	local integer unitID
	local trigger t
	local real life
	set udg_unit18=CreateUnit(p,'ewsp',-5797.5,-576.1,150.560)
endfunction

function CreateUnitsForPlayer5 takes nothing returns nothing
	local player p=Player(5)
	local unit u
	local integer unitID
	local trigger t
	local real life
	set udg_unit39=CreateUnit(p,'e006',5786.4,-816.2,345.179)
endfunction

function CreateUnitsForPlayer6 takes nothing returns nothing
	local player p=Player(6)
	local unit u
	local integer unitID
	local trigger t
	local real life
	set udg_unit40=CreateUnit(p,'e006',5909.7,-852.6,145.452)
endfunction

function CreateUnitsForPlayer7 takes nothing returns nothing
	local player p=Player(7)
	local unit u
	local integer unitID
	local trigger t
	local real life
	set udg_unit41=CreateUnit(p,'e006',6019.7,-781.9,331.413)
endfunction

function CreateUnitsForPlayer8 takes nothing returns nothing
	local player p=Player(8)
	local unit u
	local integer unitID
	local trigger t
	local real life
	set udg_unit42=CreateUnit(p,'e006',5846.9,-1049.6,357.945)
endfunction

function CreateUnitsForPlayer9 takes nothing returns nothing
	local player p=Player(9)
	local unit u
	local integer unitID
	local trigger t
	local real life
	set udg_unit43=CreateUnit(p,'e006',5982.9,-1047.2,164.097)
endfunction

function CreateBuildingsForPlayer10 takes nothing returns nothing
	local player p=Player(10)
	local unit u
	local integer unitID
	local trigger t
	local real life
	set u=CreateUnit(p,'etrp',-3872.0,96.0,270.000)
	set u=CreateUnit(p,'etrp',-4064.0,-608.0,270.000)
	set u=CreateUnit(p,'etrp',-3744.0,-480.0,270.000)
	set udg_unit20=CreateUnit(p,'hbla',-3136.0,-2432.0,270.000)
	set u=CreateUnit(p,'h005',-4800.0,2688.0,270.000)
	set u=CreateUnit(p,'h005',-4608.0,-3136.0,270.000)
	set udg_unit19=CreateUnit(p,'hcas',-4096.0,-256.0,270.000)
	set u=CreateUnit(p,'etrp',-4064.0,96.0,270.000)
	set u=CreateUnit(p,'etrp',-3744.0,-96.0,270.000)
	set u=CreateUnit(p,'etrp',-3744.0,-288.0,270.000)
	set u=CreateUnit(p,'etrp',-4256.0,96.0,270.000)
	set u=CreateUnit(p,'etrp',-3872.0,-672.0,270.000)
	set u=CreateUnit(p,'etrp',-4256.0,-608.0,270.000)
	set u=CreateUnit(p,'hgtw',-3008.0,-2240.0,270.000)
	set u=CreateUnit(p,'hgtw',-3136.0,-2112.0,270.000)
	set u=CreateUnit(p,'hgtw',-3136.0,-1984.0,270.000)
	set u=CreateUnit(p,'hgtw',-3008.0,-1984.0,270.000)
	set udg_unit21=CreateUnit(p,'eaom',-3264.0,-1728.0,270.000)
	set u=CreateUnit(p,'hgtw',-3072.0,-2624.0,270.000)
	set u=CreateUnit(p,'hgtw',-3008.0,-1536.0,270.000)
	set udg_unit22=CreateUnit(p,'edob',-3200.0,1216.0,270.000)
	set udg_unit23=CreateUnit(p,'hbar',-3392.0,1920.0,270.000)
	set u=CreateUnit(p,'hgtw',-3072.0,1024.0,270.000)
	set u=CreateUnit(p,'hgtw',-3136.0,1472.0,270.000)
	set u=CreateUnit(p,'hgtw',-3136.0,1728.0,270.000)
	set u=CreateUnit(p,'hgtw',-3136.0,2112.0,270.000)
	set u=CreateUnit(p,'hgtw',-3264.0,1536.0,270.000)
	set u=CreateUnit(p,'hgtw',-3264.0,1664.0,270.000)
	set u=CreateUnit(p,'hgtw',-1600.0,1216.0,270.000)
	set u=CreateUnit(p,'hgtw',-1664.0,2112.0,270.000)
	set u=CreateUnit(p,'hgtw',-1792.0,2112.0,270.000)
	set u=CreateUnit(p,'hgtw',-1728.0,1216.0,270.000)
	set u=CreateUnit(p,'hgtw',-1664.0,1344.0,270.000)
	set u=CreateUnit(p,'hgtw',-1728.0,1984.0,270.000)
	set u=CreateUnit(p,'hgtw',-1856.0,-1600.0,270.000)
	set u=CreateUnit(p,'hgtw',-1728.0,-1600.0,270.000)
	set u=CreateUnit(p,'hgtw',-1792.0,-1728.0,270.000)
	set u=CreateUnit(p,'hgtw',-1792.0,-2624.0,270.000)
	set u=CreateUnit(p,'hgtw',-1664.0,-2624.0,270.000)
	set u=CreateUnit(p,'hgtw',-1728.0,-2496.0,270.000)
endfunction

function CreateBuildingsForPlayer11 takes nothing returns nothing
	local player p=Player(11)
	local unit u
	local integer unitID
	local trigger t
	local real life
	set u=CreateUnit(p,'h005',4288.0,-3072.0,270.000)
	set u=CreateUnit(p,'uzg2',2976.0,-1696.0,270.000)
	set udg_unit25=CreateUnit(p,'obar',2944.0,-2240.0,270.000)
	set udg_unit24=CreateUnit(p,'ofrt',3840.0,-256.0,270.000)
	set u=CreateUnit(p,'uzg1',4000.0,-608.0,270.000)
	set u=CreateUnit(p,'uzg1',3936.0,96.0,270.000)
	set u=CreateUnit(p,'uzg1',3808.0,-608.0,270.000)
	set u=CreateUnit(p,'uzg1',3616.0,-608.0,270.000)
	set u=CreateUnit(p,'uzg1',3488.0,-416.0,270.000)
	set u=CreateUnit(p,'uzg1',3488.0,-224.0,270.000)
	set u=CreateUnit(p,'uzg1',3488.0,-32.0,270.000)
	set u=CreateUnit(p,'uzg1',3552.0,160.0,270.000)
	set u=CreateUnit(p,'uzg1',3744.0,96.0,270.000)
	set u=CreateUnit(p,'h005',4480.0,2368.0,270.000)
	set u=CreateUnit(p,'uzg2',2976.0,-1952.0,270.000)
	set u=CreateUnit(p,'uzg2',2784.0,-1952.0,270.000)
	set udg_unit26=CreateUnit(p,'uslh',2944.0,-1408.0,270.000)
	set u=CreateUnit(p,'uzg2',2784.0,-1696.0,270.000)
	set u=CreateUnit(p,'uzg2',2976.0,-2528.0,270.000)
	set u=CreateUnit(p,'uzg2',2912.0,-1120.0,270.000)
	set u=CreateUnit(p,'owtw',2688.0,1600.0,270.000)
	set u=CreateUnit(p,'owtw',2816.0,1536.0,270.000)
	set u=CreateUnit(p,'owtw',2816.0,1408.0,270.000)
	set u=CreateUnit(p,'owtw',2688.0,1344.0,270.000)
	set udg_unit27=CreateUnit(p,'usep',2816.0,1856.0,270.000)
	set udg_unit28=CreateUnit(p,'otto',2816.0,1088.0,270.000)
	set u=CreateUnit(p,'owtw',2752.0,832.0,270.000)
	set u=CreateUnit(p,'owtw',2688.0,2112.0,270.000)
	set u=CreateUnit(p,'owtw',1344.0,1088.0,270.000)
	set u=CreateUnit(p,'owtw',1472.0,1088.0,270.000)
	set u=CreateUnit(p,'owtw',1408.0,1216.0,270.000)
	set u=CreateUnit(p,'owtw',1280.0,2112.0,270.000)
	set u=CreateUnit(p,'owtw',1408.0,2112.0,270.000)
	set u=CreateUnit(p,'owtw',1344.0,1920.0,270.000)
	set u=CreateUnit(p,'owtw',1600.0,-2624.0,270.000)
	set u=CreateUnit(p,'owtw',1728.0,-2624.0,270.000)
	set u=CreateUnit(p,'owtw',1664.0,-2496.0,270.000)
	set u=CreateUnit(p,'owtw',1536.0,-1728.0,270.000)
	set u=CreateUnit(p,'owtw',1664.0,-1728.0,270.000)
	set u=CreateUnit(p,'owtw',1600.0,-1856.0,270.000)
endfunction

function CreateNeutralPassiveBuildings2 takes nothing returns nothing
	local player p=Player(PLAYER_NEUTRAL_PASSIVE)
	local unit u
	local integer unitID
	local trigger t
	local real life
	set u=CreateUnit(p,'nfoh',-4160.0,-3072.0,270.000)
	set u=CreateUnit(p,'nmoo',-4608.0,-2752.0,270.000)
	set u=CreateUnit(p,'nbfl',4288.0,-2688.0,270.000)
	set u=CreateUnit(p,'nfh1',3680.0,-1376.0,270.000)
	set u=CreateUnit(p,'nmoo',-4864.0,2304.0,270.000)
	set u=CreateUnit(p,'nfoh',-4416.0,2496.0,270.000)
	set u=CreateUnit(p,'nfh1',-3936.0,-1504.0,270.000)
	set u=CreateUnit(p,'n000',-4224.0,-1408.0,270.000)
	set u=CreateUnit(p,'n001',-4160.0,832.0,270.000)
	set u=CreateUnit(p,'ntav',-3776.0,832.0,270.000)
	call SetUnitColor(u,ConvertPlayerColor(0))
	set u=CreateUnit(p,'ngme',-2496.0,-128.0,270.000)
	set u=CreateUnit(p,'n00N',-2496.0,-896.0,270.000)
	set u=CreateUnit(p,'n00O',-2496.0,-512.0,270.000)
	set u=CreateUnit(p,'n00M',-2688.0,320.0,270.000)
	set u=CreateUnit(p,'ngt2',-224.0,-288.0,270.000)
	set u=CreateUnit(p,'ndfl',4160.0,2368.0,270.000)
	set u=CreateUnit(p,'nbfl',4544.0,2048.0,270.000)
	set u=CreateUnit(p,'ndfl',3904.0,-2880.0,270.000)
	set u=CreateUnit(p,'n000',3968.0,-1280.0,270.000)
	set u=CreateUnit(p,'n00F',3456.0,640.0,270.000)
	call SetUnitColor(u,ConvertPlayerColor(0))
	set u=CreateUnit(p,'n001',3904.0,576.0,270.000)
	set u=CreateUnit(p,'ngme',2176.0,-128.0,270.000)
	set u=CreateUnit(p,'n00N',2176.0,-896.0,270.000)
	set u=CreateUnit(p,'n00O',2176.0,-512.0,270.000)
	set u=CreateUnit(p,'n00M',2240.0,320.0,270.000)
endfunction

function CreateNeutralPassive2 takes nothing returns nothing
	local player p=Player(PLAYER_NEUTRAL_PASSIVE)
	local unit u
	local integer unitID
	local trigger t
	local real life
	set udg_unit03=CreateUnit(p,'Hamg',-5460.8,1.6,180.000)
	call SetHeroLevel(udg_unit03,50,false)
	call SetUnitState(udg_unit03,UNIT_STATE_MANA,0)
	set udg_unit04=CreateUnit(p,'Hmkg',-5464.0,-273.0,180.000)
	call SetHeroLevel(udg_unit04,50,false)
	call SetUnitState(udg_unit04,UNIT_STATE_MANA,0)
	set udg_unit05=CreateUnit(p,'Hblm',-5474.1,-514.5,180.000)
	call SetHeroLevel(udg_unit05,50,false)
	call SetUnitState(udg_unit05,UNIT_STATE_MANA,0)
	set udg_unit06=CreateUnit(p,'Edem',-6320.2,288.1,356.240)
	call SetHeroLevel(udg_unit06,50,false)
	call SetUnitState(udg_unit06,UNIT_STATE_MANA,0)
	set udg_unit07=CreateUnit(p,'Hpal',-5472.8,267.8,180.000)
	call SetHeroLevel(udg_unit07,50,false)
	call SetUnitState(udg_unit07,UNIT_STATE_MANA,0)
	set udg_unit08=CreateUnit(p,'Ekee',-6318.5,-508.2,2.010)
	call SetHeroLevel(udg_unit08,50,false)
	call SetUnitState(udg_unit08,UNIT_STATE_MANA,0)
	set udg_unit09=CreateUnit(p,'N003',-6329.8,-233.7,4.620)
	call SetHeroLevel(udg_unit09,50,false)
	set udg_unit10=CreateUnit(p,'Hvwd',-5903.4,-1667.5,90.000)
	call SetHeroLevel(udg_unit10,50,false)
	set udg_unit11=CreateUnit(p,'E005',-6324.9,-738.3,9.580)
	call SetHeroLevel(udg_unit11,50,false)
	set udg_unit12=CreateUnit(p,'N002',-6321.3,17.7,0.650)
	call SetHeroLevel(udg_unit12,50,false)
	call SetUnitState(udg_unit12,UNIT_STATE_MANA,0)
	set udg_unit13=CreateUnit(p,'Hlgr',-5440.2,-786.2,174.000)
	call SetHeroLevel(udg_unit13,50,false)
	set udg_unit29=CreateUnit(p,'Udea',6314.2,-130.0,173.540)
	call SetHeroLevel(udg_unit29,50,false)
	call SetUnitState(udg_unit29,UNIT_STATE_MANA,0)
	set udg_unit30=CreateUnit(p,'Oshd',5427.2,-748.3,0.000)
	call SetHeroLevel(udg_unit30,50,false)
	call SetUnitState(udg_unit30,UNIT_STATE_MANA,0)
	set udg_unit31=CreateUnit(p,'Ofar',5455.3,-82.6,0.000)
	call SetHeroLevel(udg_unit31,50,false)
	call SetUnitState(udg_unit31,UNIT_STATE_MANA,0)
	set udg_unit32=CreateUnit(p,'Ucrl',6297.6,133.3,177.830)
	call SetHeroLevel(udg_unit32,50,false)
	call SetUnitState(udg_unit32,UNIT_STATE_MANA,0)
	set udg_unit33=CreateUnit(p,'Udre',6333.9,-426.4,184.240)
	call SetHeroLevel(udg_unit33,50,false)
	call SetUnitState(udg_unit33,UNIT_STATE_MANA,0)
	set udg_unit34=CreateUnit(p,'Ulic',6335.9,-750.9,170.150)
	call SetHeroLevel(udg_unit34,50,false)
	call SetUnitState(udg_unit34,UNIT_STATE_MANA,0)
	set udg_unit35=CreateUnit(p,'Nman',6310.6,-1074.5,162.910)
	call SetHeroLevel(udg_unit35,50,false)
	set udg_unit36=CreateUnit(p,'Nfir',5927.9,-2038.5,93.000)
	call SetHeroLevel(udg_unit36,50,false)
	set udg_unit37=CreateUnit(p,'Otch',5439.8,-419.7,0.000)
	call SetHeroLevel(udg_unit37,50,false)
	call SetUnitState(udg_unit37,UNIT_STATE_MANA,0)
	set udg_unit38=CreateUnit(p,'Obla',5443.0,196.7,0.000)
	call SetHeroLevel(udg_unit38,50,false)
	call SetUnitState(udg_unit38,UNIT_STATE_MANA,0)
	set udg_unit47=CreateUnit(p,'Ogrh',5456.2,-1052.0,359.300)
	call SetHeroLevel(udg_unit47,50,false)
	set udg_unit46=CreateUnit(p,'H00G',-5453.7,-1083.5,166.110)
	call SetHeroLevel(udg_unit46,50,false)
	set udg_unit45=CreateUnit(p,'O00B',-6325.5,-1094.6,26.740)
	call SetHeroLevel(udg_unit45,50,false)
	set udg_unit44=CreateUnit(p,'Usyl',5491.8,-1639.2,6.580)
	call SetHeroLevel(udg_unit44,50,false)
	set udg_unit48=CreateUnit(p,'H00K',6424.8,-1510.1,195.400)
	call SetHeroLevel(udg_unit48,50,false)
endfunction

function CreateRegions2 takes nothing returns nothing
	local weathereffect we
	set udg_rect01=Rect(-5952.0,-1568.0,-5856.0,-1472.0)
	set udg_rect02=Rect(-5632.0,-32.0,-5568.0,32.0)
	set udg_rect03=Rect(-6208.0,-800.0,-6144.0,-736.0)
	set udg_rect04=Rect(5568.0,96.0,5632.0,160.0)
	set udg_rect05=Rect(-5632.0,-544.0,-5568.0,-480.0)
	set udg_rect06=Rect(-6208.0,-544.0,-6144.0,-480.0)
	set udg_rect07=Rect(6112.0,96.0,6176.0,160.0)
	set udg_rect08=Rect(6112.0,-160.0,6176.0,-96.0)
	set udg_rect09=Rect(-6208.0,224.0,-6144.0,288.0)
	set udg_rect10=Rect(6112.0,-480.0,6176.0,-416.0)
	set udg_rect11=Rect(5568.0,-128.0,5632.0,-64.0)
	set udg_rect12=Rect(-4672.0,2016.0,-4288.0,2304.0)
	set udg_rect13=Rect(-4416.0,-2784.0,-4128.0,-2528.0)
	set udg_rect14=Rect(5856.0,-1856.0,5984.0,-1760.0)
	set udg_rect15=Rect(4032.0,1792.0,4384.0,2176.0)
	set udg_rect16=Rect(3776.0,-2688.0,4160.0,-2400.0)
	set udg_rect17=Rect(-5632.0,-800.0,-5568.0,-736.0)
	set udg_rect18=Rect(-6016.0,-416.0,-5760.0,-96.0)
	set udg_rect19=Rect(-3072.0,1728.0,-2752.0,2080.0)
	set udg_rect20=Rect(-3072.0,1088.0,-2752.0,1408.0)
	set udg_rect21=Rect(-2976.0,-1952.0,-2656.0,-1600.0)
	set udg_rect22=Rect(-2976.0,-2592.0,-2656.0,-2272.0)
	set udg_rect23=Rect(-3488.0,-480.0,-3136.0,-96.0)
	set udg_rect24=Rect(5568.0,-1056.0,5632.0,-992.0)
	set udg_rect25=Rect(6112.0,-800.0,6208.0,-704.0)
	set udg_rect26=Rect(-5632.0,-288.0,-5568.0,-224.0)
	set udg_rect27=Rect(6144.0,-1088.0,6208.0,-1024.0)
	set udg_rect28=Rect(5760.0,-448.0,6048.0,-96.0)
	set udg_rect29=Rect(2304.0,1696.0,2624.0,1984.0)
	set udg_rect30=Rect(2400.0,896.0,2688.0,1184.0)
	set udg_rect31=Rect(2400.0,-1728.0,2720.0,-1440.0)
	set udg_rect32=Rect(2336.0,-2560.0,2720.0,-2240.0)
	set udg_rect33=Rect(2912.0,-416.0,3264.0,-64.0)
	set udg_rect34=Rect(-5632.0,224.0,-5568.0,288.0)
	set udg_rect35=Rect(-6208.0,-32.0,-6144.0,32.0)
	set udg_rect36=Rect(-3808.0,-800.0,-3648.0,-608.0)
	set udg_rect37=Rect(-3840.0,96.0,-3648.0,352.0)
	set udg_rect38=Rect(3392.0,128.0,3552.0,320.0)
	set udg_rect39=Rect(3392.0,-640.0,3552.0,-448.0)
	set udg_rect40=Rect(5568.0,-800.0,5632.0,-736.0)
	set udg_rect41=Rect(5568.0,-480.0,5632.0,-416.0)
	set udg_rect42=Rect(-6208.0,-288.0,-6144.0,-224.0)
	set udg_rect43=Rect(5536.0,-1504.0,5632.0,-1376.0)
	set udg_rect44=Rect(6176.0,-1504.0,6272.0,-1440.0)
	set udg_rect45=Rect(-6208.0,-1120.0,-6144.0,-1056.0)
	set udg_rect46=Rect(-5632.0,-1120.0,-5568.0,-1056.0)
endfunction

function GetHost takes nothing returns nothing
	local gamecache g=InitGameCache("Map.w3v")
	call StoreInteger(g,"Map","Host",GetPlayerId(GetLocalPlayer())+1)
	call TriggerSyncStart()
	call SyncStoredInteger(g,"Map","Host")
	call TriggerSyncReady()
	set udg_player09=Player(GetStoredInteger(g,"Map","Host")-1)
	call FlushGameCache(g)
	set g=null
endfunction

function CountItemsOnUnit takes integer I,unit U returns integer
	local integer LoopA=0
	local integer CountNo=0
	loop
		exitwhen LoopA>5
		if GetItemTypeId(UnitItemInSlot(U,LoopA))==I then
			set CountNo=CountNo+1
		endif
		set LoopA=LoopA+1
	endloop
	return CountNo
endfunction

function Trig_Elsin_Actions takes nothing returns nothing
	call PauseGameOff()
endfunction

function Trig_Kick_Player_Func001Func001C takes nothing returns boolean
	if(not(GetEventPlayerChatString()==("-kick "+GetPlayerName(ConvertedPlayer(GetForLoopIndexA())))))then
		return false
	endif
	return true
endfunction

function Trig_Kick_Player_Func002Func003A takes nothing returns nothing
	call CustomDefeatBJ(udg_player08,"TRIGSTR_8795")
	call RemoveUnit(GetEnumUnit())
endfunction

function Trig_Kick_Player_Func002Func004A takes nothing returns nothing
	call SetPlayerAllianceStateBJ(udg_player08,GetEnumPlayer(),bj_ALLIANCE_UNALLIED)
	call SetPlayerAllianceStateBJ(GetEnumPlayer(),udg_player08,bj_ALLIANCE_UNALLIED)
endfunction

function Trig_Kick_Player_Func002C takes nothing returns boolean
	if(not(udg_booleans01[GetConvertedPlayerId(udg_player08)]==false))then
		return false
	endif
	return true
endfunction

function Trig_Kick_Player_Actions takes nothing returns nothing
	set bj_forLoopAIndex=2
	set bj_forLoopAIndexEnd=10
	loop
		exitwhen bj_forLoopAIndex>bj_forLoopAIndexEnd
		if(Trig_Kick_Player_Func001Func001C())then
			set udg_player08=ConvertedPlayer(GetForLoopIndexA())
		else
		endif
		set bj_forLoopAIndex=bj_forLoopAIndex+1
	endloop
	if(Trig_Kick_Player_Func002C())then
		set udg_booleans01[GetConvertedPlayerId(udg_player08)]=true
		call DisplayTextToForce(GetPlayersAll(),("|cffFF6666"+(GetPlayerName(udg_player08)+"|r was kicked.")))
		call ForGroupBJ(GetUnitsOfPlayerAll(udg_player08),function Trig_Kick_Player_Func002Func003A)
		call ForForce(GetPlayersAll(),function Trig_Kick_Player_Func002Func004A)
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
	call DialogAddButtonBJ(udg_dialogs01[1],"TRIGSTR_8796")
	set udg_buttons01[1]=GetLastCreatedButtonBJ()
	call DialogAddButtonBJ(udg_dialogs01[1],"TRIGSTR_8797")
	set udg_buttons01[2]=GetLastCreatedButtonBJ()
	call DialogDisplayBJ(true,udg_dialogs01[1],Player(0))
	call PauseGameOn()
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Acciones_Menu1_3_DE_ORO_Conditions takes nothing returns boolean
	if(not(GetClickedButtonBJ()==udg_buttons01[1]))then
		return false
	endif
	return true
endfunction

function Trig_Acciones_Menu1_3_DE_ORO_Actions takes nothing returns nothing
	call DisplayTextToForce(GetPlayersAll(),"TRIGSTR_8798")
	call EnableTrigger(udg_trigger98)
	call DialogClearBJ(udg_dialogs01[1])
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Acciones_Menu1_6_DE_ORO_Conditions takes nothing returns boolean
	if(not(GetClickedButtonBJ()==udg_buttons01[2]))then
		return false
	endif
	return true
endfunction

function Trig_Acciones_Menu1_6_DE_ORO_Actions takes nothing returns nothing
	call DisplayTextToForce(GetPlayersAll(),"TRIGSTR_8799")
	call EnableTrigger(udg_trigger99)
	call DialogClearBJ(udg_dialogs01[1])
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Menu2_______SM_y_USM_Actions takes nothing returns nothing
	call DialogAddButtonBJ(udg_dialogs02[1],"TRIGSTR_8800")
	set udg_buttons02[1]=GetLastCreatedButtonBJ()
	call DialogAddButtonBJ(udg_dialogs02[1],"TRIGSTR_8801")
	set udg_buttons02[2]=GetLastCreatedButtonBJ()
	call DialogDisplayBJ(true,udg_dialogs02[1],Player(0))
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Acciones_Menu2_SM_Conditions takes nothing returns boolean
	if(not(GetClickedButtonBJ()==udg_buttons02[1]))then
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
	if(not(GetClickedButtonBJ()==udg_buttons02[2]))then
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
	call DialogAddButtonBJ(udg_dialogs03[1],"TRIGSTR_8802")
	set udg_buttons03[1]=GetLastCreatedButtonBJ()
	call DialogAddButtonBJ(udg_dialogs03[1],"TRIGSTR_8803")
	set udg_buttons03[2]=GetLastCreatedButtonBJ()
	call DialogAddButtonBJ(udg_dialogs03[1],"TRIGSTR_8804")
	set udg_buttons03[3]=GetLastCreatedButtonBJ()
	call DialogDisplayBJ(true,udg_dialogs03[1],Player(0))
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Acciones_Menu3_ALLPICK_Conditions takes nothing returns boolean
	if(not(GetClickedButtonBJ()==udg_buttons03[1]))then
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
	if(not(GetClickedButtonBJ()==udg_buttons03[2]))then
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
	if(not(GetClickedButtonBJ()==udg_buttons03[3]))then
		return false
	endif
	return true
endfunction

function Trig_Acciones_Menu3_MODO_CLASICO_Actions takes nothing returns nothing
	call DisplayTextToForce(GetPlayersAll(),"TRIGSTR_8806")
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
	call PanCameraToTimedLocForPlayer(Player(0),GetRectCenter(udg_rect18),1.00)
	call PanCameraToTimedLocForPlayer(Player(1),GetRectCenter(udg_rect18),1.00)
	call PanCameraToTimedLocForPlayer(Player(2),GetRectCenter(udg_rect18),1.00)
	call PanCameraToTimedLocForPlayer(Player(3),GetRectCenter(udg_rect18),1.00)
	call PanCameraToTimedLocForPlayer(Player(4),GetRectCenter(udg_rect18),1.00)
	call PanCameraToTimedLocForPlayer(Player(5),GetRectCenter(udg_rect28),1.00)
	call PanCameraToTimedLocForPlayer(Player(6),GetRectCenter(udg_rect28),1.00)
	call PanCameraToTimedLocForPlayer(Player(7),GetRectCenter(udg_rect28),1.00)
	call PanCameraToTimedLocForPlayer(Player(8),GetRectCenter(udg_rect28),1.00)
	call PanCameraToTimedLocForPlayer(Player(9),GetRectCenter(udg_rect28),1.00)
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Attack_1_Barracas_1_Conditions takes nothing returns boolean
	if(not(GetOwningPlayer(GetTriggerUnit())==Player(10)))then
		return false
	endif
	return true
endfunction

function Trig_Attack_1_Barracas_1_Actions takes nothing returns nothing
	call IssuePointOrder(GetTriggerUnit(), "attack", GetRectCenterX(udg_rect38), GetRectCenterY(udg_rect38))
endfunction

function Trig_Attack_1_Blacksmith_1_Conditions takes nothing returns boolean
	if(not(GetOwningPlayer(GetTriggerUnit())==Player(10)))then
		return false
	endif
	return true
endfunction

function Trig_Attack_1_Blacksmith_1_Actions takes nothing returns nothing
	call IssuePointOrder(GetTriggerUnit(), "attack", GetRectCenterX(udg_rect38), GetRectCenterY(udg_rect38))
endfunction

function Trig_Attack_1_Barracas_2_Conditions takes nothing returns boolean
	if(not(GetOwningPlayer(GetTriggerUnit())==Player(10)))then
		return false
	endif
	return true
endfunction

function Trig_Attack_1_Barracas_2_Actions takes nothing returns nothing
	call IssuePointOrder(GetTriggerUnit(), "attack", GetRectCenterX(udg_rect39), GetRectCenterY(udg_rect39))
endfunction

function Trig_Attack_1_Blacsmith_2_Conditions takes nothing returns boolean
	if(not(GetOwningPlayer(GetTriggerUnit())==Player(10)))then
		return false
	endif
	return true
endfunction

function Trig_Attack_1_Blacsmith_2_Actions takes nothing returns nothing
	call IssuePointOrder(GetTriggerUnit(), "attack", GetRectCenterX(udg_rect39), GetRectCenterY(udg_rect39))
endfunction

function Trig_Attack_1_orc_Barracas_2_Conditions takes nothing returns boolean
	if(not(GetOwningPlayer(GetTriggerUnit())==Player(11)))then
		return false
	endif
	return true
endfunction

function Trig_Attack_1_orc_Barracas_2_Actions takes nothing returns nothing
	call IssuePointOrder(GetTriggerUnit(), "attack", GetRectCenterX(udg_rect37), GetRectCenterY(udg_rect37))
endfunction

function Trig_Attack_1_orc_Tauren_2_Conditions takes nothing returns boolean
	if(not(GetOwningPlayer(GetTriggerUnit())==Player(11)))then
		return false
	endif
	return true
endfunction

function Trig_Attack_1_orc_Tauren_2_Actions takes nothing returns nothing
	call IssuePointOrder(GetTriggerUnit(), "attack", GetRectCenterX(udg_rect37), GetRectCenterY(udg_rect37))
endfunction

function Trig_Attack_1_orc_Tauren_1_Conditions takes nothing returns boolean
	if(not(GetOwningPlayer(GetTriggerUnit())==Player(11)))then
		return false
	endif
	return true
endfunction

function Trig_Attack_1_orc_Tauren_1_Actions takes nothing returns nothing
	call IssuePointOrder(GetTriggerUnit(), "attack", GetRectCenterX(udg_rect36), GetRectCenterY(udg_rect36))
endfunction

function Trig_Attack_1_orc_Barracas_1_Conditions takes nothing returns boolean
	if(not(GetOwningPlayer(GetTriggerUnit())==Player(11)))then
		return false
	endif
	return true
endfunction

function Trig_Attack_1_orc_Barracas_1_Actions takes nothing returns nothing
	call IssuePointOrder(GetTriggerUnit(), "attack", GetRectCenterX(udg_rect36), GetRectCenterY(udg_rect36))
endfunction

// DESACTIVADO: First Blood legacy — MIGRADO completamente a Sistema_Kills.j
// Bug original: si una invocación hacía la primera sangre, este trigger no se
// desactivaba y lanzaba el texto "First Blood" en una kill posterior.
//function Trig_First_Blood_Conditions takes nothing returns boolean
//	if(not(IsUnitType(GetDyingUnit(),UNIT_TYPE_HERO)==true))then
//		return false
//	endif
//	if(not(IsUnitType(GetKillingUnitBJ(),UNIT_TYPE_HERO)==true))then
//		return false
//	endif
//	return true
//endfunction

//function Trig_First_Blood_Actions takes nothing returns nothing
//	call DisplayTextToForce(GetPlayersAll(),"TRIGSTR_8815")
//	call PlaySoundBJ(udg_sound01)
//	call DisableTrigger(GetTriggeringTrigger())
//	call EnableTrigger(udg_trigger23)
//endfunction

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
	//call QuestMessageBJ(GetPlayersAll(),bj_QUESTMESSAGE_ALWAYSHINT,"TRIGSTR_8816")
	//call QuestMessageBJ(GetPlayersAll(),bj_QUESTMESSAGE_ALWAYSHINT,"TRIGSTR_8817")
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_AllianceMusic_Conditions takes nothing returns boolean
	if(not(GetUnitTypeId(GetDyingUnit())=='owtw'))then
		return false
	endif
	return true
endfunction

function Trig_AllianceMusic_Func002001 takes nothing returns boolean
	return(udg_integer47==22)
endfunction

function Trig_AllianceMusic_Actions takes nothing returns nothing
	set udg_integer47=(udg_integer47+1)
	if(Trig_AllianceMusic_Func002001())then
		call PlayMusicBJ(udg_string01)
	else
		call DoNothing()
	endif
endfunction

function Trig_HordeMusic_Conditions takes nothing returns boolean
	if(not(GetUnitTypeId(GetDyingUnit())=='hgtw'))then
		return false
	endif
	return true
endfunction

function Trig_HordeMusic_Func002001 takes nothing returns boolean
	return(udg_integer48==22)
endfunction

function Trig_HordeMusic_Actions takes nothing returns nothing
	set udg_integer48=(udg_integer48+1)
	if(Trig_HordeMusic_Func002001())then
		call PlayMusicBJ(udg_string01)
	else
		call DoNothing()
	endif
endfunction

function Trig_Command_Short_Mode_Conditions takes nothing returns boolean
	if(not(GetClickedButtonBJ()==udg_buttons02[1]))then
		return false
	endif
	return true
endfunction

function Trig_Command_Short_Mode_Func003C takes nothing returns boolean
	if(not(udg_boolean05==true))then
		return false
	endif
	return true
endfunction

function Trig_Command_Short_Mode_Actions takes nothing returns nothing
	if(Trig_Command_Short_Mode_Func003C())then
		call QuestMessageBJ(GetPlayersAll(),bj_QUESTMESSAGE_UPDATED,"TRIGSTR_8818")
	else
		set udg_boolean05=true
		call QuestMessageBJ(GetPlayersAll(),bj_QUESTMESSAGE_DISCOVERED,"TRIGSTR_8819")
		call SetPlayerHandicapXPBJ(Player(0),150.00)
		call SetPlayerHandicapXPBJ(Player(1),150.00)
		call SetPlayerHandicapXPBJ(Player(2),150.00)
		call SetPlayerHandicapXPBJ(Player(3),150.00)
		call SetPlayerHandicapXPBJ(Player(4),150.00)
		call SetPlayerHandicapXPBJ(Player(5),150.00)
		call SetPlayerHandicapXPBJ(Player(6),150.00)
		call SetPlayerHandicapXPBJ(Player(7),150.00)
		call SetPlayerHandicapXPBJ(Player(8),150.00)
		call SetPlayerHandicapXPBJ(Player(9),150.00)
		call DisableTrigger(udg_trigger28)
		call DestroyTrigger(GetTriggeringTrigger())
	endif
endfunction

function Trig_Command_Ultra_Short_Mode_Conditions takes nothing returns boolean
	if(not(GetClickedButtonBJ()==udg_buttons02[2]))then
		return false
	endif
	return true
endfunction

function Trig_Command_Ultra_Short_Mode_Func003C takes nothing returns boolean
	if(not(udg_boolean03==true))then
		return false
	endif
	return true
endfunction

function Trig_Command_Ultra_Short_Mode_Actions takes nothing returns nothing
	if(Trig_Command_Ultra_Short_Mode_Func003C())then
		call QuestMessageBJ(GetPlayersAll(),bj_QUESTMESSAGE_UPDATED,"TRIGSTR_8820")
	else
		set udg_boolean03=true
		call QuestMessageBJ(GetPlayersAll(),bj_QUESTMESSAGE_DISCOVERED,"TRIGSTR_8821")
		call SetPlayerHandicapXPBJ(Player(0),200.00)
		call SetPlayerHandicapXPBJ(Player(1),200.00)
		call SetPlayerHandicapXPBJ(Player(2),200.00)
		call SetPlayerHandicapXPBJ(Player(3),200.00)
		call SetPlayerHandicapXPBJ(Player(4),200.00)
		call SetPlayerHandicapXPBJ(Player(5),200.00)
		call SetPlayerHandicapXPBJ(Player(6),200.00)
		call SetPlayerHandicapXPBJ(Player(7),200.00)
		call SetPlayerHandicapXPBJ(Player(8),200.00)
		call SetPlayerHandicapXPBJ(Player(9),200.00)
		call DisableTrigger(udg_trigger27)
		call DestroyTrigger(GetTriggeringTrigger())
	endif
endfunction

function Trig_Create_Multiboard_Func002002001001001 takes nothing returns boolean
	return(GetPlayerController(GetFilterPlayer())==MAP_CONTROL_USER)
endfunction

function Trig_Create_Multiboard_Func002002001001002 takes nothing returns boolean
	return(GetPlayerSlotState(GetFilterPlayer())==PLAYER_SLOT_STATE_PLAYING)
endfunction

function Trig_Create_Multiboard_Func002002001001 takes nothing returns boolean
	return GetBooleanAnd(Trig_Create_Multiboard_Func002002001001001(),Trig_Create_Multiboard_Func002002001001002())
endfunction

function Trig_Create_Multiboard_Func009001001001 takes nothing returns boolean
	return(GetPlayerSlotState(GetFilterPlayer())==PLAYER_SLOT_STATE_PLAYING)
endfunction

function Trig_Create_Multiboard_Func009001001002 takes nothing returns boolean
	return(GetPlayerController(GetFilterPlayer())==MAP_CONTROL_USER)
endfunction

function Trig_Create_Multiboard_Func009001001 takes nothing returns boolean
	return GetBooleanAnd(Trig_Create_Multiboard_Func009001001001(),Trig_Create_Multiboard_Func009001001002())
endfunction

function Trig_Create_Multiboard_Func009A takes nothing returns nothing
	set udg_integers01[GetConvertedPlayerId(GetEnumPlayer())]=udg_integer02
	call MultiboardSetItemValueBJ(GetLastCreatedMultiboard(),1,udg_integer02,(udg_strings01[GetConvertedPlayerId(GetEnumPlayer())]+(GetPlayerName(GetEnumPlayer())+"|r")))
	call MultiboardSetItemValueBJ(GetLastCreatedMultiboard(),2,udg_integer02,"TRIGSTR_8826")
	call MultiboardSetItemValueBJ(GetLastCreatedMultiboard(),3,udg_integer02,"TRIGSTR_8827")
	set udg_integer02=(udg_integer02+1)
endfunction

function Trig_Create_Multiboard_Actions takes nothing returns nothing
	set udg_integer01=CountPlayersInForceBJ(GetPlayersMatching(Condition(function Trig_Create_Multiboard_Func002002001001)))
	call CreateMultiboardBJ(3,(1+udg_integer01),"TRIGSTR_8822")
	call MultiboardSetItemValueBJ(GetLastCreatedMultiboard(),1,1,"TRIGSTR_8823")
	call MultiboardSetItemValueBJ(GetLastCreatedMultiboard(),2,1,"TRIGSTR_8824")
	call MultiboardSetItemValueBJ(GetLastCreatedMultiboard(),3,1,"TRIGSTR_8825")
	set bj_forLoopAIndex=1
	set bj_forLoopAIndexEnd=(1+udg_integer01)
	loop
		exitwhen bj_forLoopAIndex>bj_forLoopAIndexEnd
		call MultiboardSetItemStyleBJ(GetLastCreatedMultiboard(),1,1,true,false)
		call MultiboardSetItemStyleBJ(GetLastCreatedMultiboard(),1,GetForLoopIndexA(),true,false)
		call MultiboardSetItemStyleBJ(GetLastCreatedMultiboard(),2,GetForLoopIndexA(),true,false)
		call MultiboardSetItemStyleBJ(GetLastCreatedMultiboard(),3,GetForLoopIndexA(),true,false)
		call MultiboardSetItemWidthBJ(GetLastCreatedMultiboard(),1,GetForLoopIndexA(),8.00)
		call MultiboardSetItemWidthBJ(GetLastCreatedMultiboard(),2,GetForLoopIndexA(),7.00)
		call MultiboardSetItemWidthBJ(GetLastCreatedMultiboard(),3,GetForLoopIndexA(),5.00)
		set bj_forLoopAIndex=bj_forLoopAIndex+1
	endloop
	set udg_integer02=2
	call ForForce(GetPlayersMatching(Condition(function Trig_Create_Multiboard_Func009001001)),function Trig_Create_Multiboard_Func009A)
	call MultiboardSetItemColorBJ(GetLastCreatedMultiboard(),2,1,100.00,100.00,100.00,0)
	call MultiboardSetItemColorBJ(GetLastCreatedMultiboard(),3,1,100.00,100.00,100.00,0)
	call MultiboardDisplayBJ(true,GetLastCreatedMultiboard())
endfunction

function Trig_Player_Kills_Upd_Conditions takes nothing returns boolean
	if(not(IsUnitType(GetDyingUnit(),UNIT_TYPE_HERO)==true))then
		return false
	endif
	if(not(GetPlayerController(GetOwningPlayer(GetKillingUnitBJ()))==MAP_CONTROL_USER))then
		return false
	endif
	return true
endfunction

function Trig_Player_Kills_Upd_Actions takes nothing returns nothing
	set udg_integers02[GetConvertedPlayerId(GetOwningPlayer(GetKillingUnitBJ()))]=(udg_integers02[GetConvertedPlayerId(GetOwningPlayer(GetKillingUnitBJ()))]+1)
	call MultiboardSetItemValueBJ(GetLastCreatedMultiboard(),2,udg_integers01[GetConvertedPlayerId(GetOwningPlayer(GetKillingUnitBJ()))],I2S(udg_integers02[GetConvertedPlayerId(GetOwningPlayer(GetKillingUnitBJ()))]))
endfunction

function Trig_Player_Hero_Death_Func004001 takes nothing returns boolean
	return(IsUnitType(GetTriggerUnit(),UNIT_TYPE_HERO)==true)
endfunction

function Trig_Player_Hero_Death_Func004002 takes nothing returns boolean
	return(GetPlayerController(GetOwningPlayer(GetDyingUnit()))==MAP_CONTROL_USER)
endfunction

function Trig_Player_Hero_Death_Conditions takes nothing returns boolean
	if(not GetBooleanAnd(Trig_Player_Hero_Death_Func004001(),Trig_Player_Hero_Death_Func004002()))then
		return false
	endif
	return true
endfunction

function Trig_Player_Hero_Death_Func003C takes nothing returns boolean
	if(not(GetPlayerController(GetOwningPlayer(GetKillingUnitBJ()))!=MAP_CONTROL_COMPUTER))then
		return false
	endif
	return true
endfunction

function Trig_Player_Hero_Death_Actions takes nothing returns nothing
	set udg_integers03[GetConvertedPlayerId(GetOwningPlayer(GetDyingUnit()))]=(udg_integers03[GetConvertedPlayerId(GetOwningPlayer(GetDyingUnit()))]+1)
	call MultiboardSetItemValueBJ(GetLastCreatedMultiboard(),3,udg_integers01[GetConvertedPlayerId(GetOwningPlayer(GetDyingUnit()))],I2S(udg_integers03[GetConvertedPlayerId(GetOwningPlayer(GetDyingUnit()))]))
	if(Trig_Player_Hero_Death_Func003C())then
	else
		call DoNothing()
	endif
endfunction

function Trig_Player_leaves_Func001A takes nothing returns nothing
	call UnitDropItemPointLoc(GetTriggerUnit(),UnitItemInSlotBJ(GetTriggerUnit(),1),GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())))
	call UnitDropItemPointLoc(GetTriggerUnit(),UnitItemInSlotBJ(GetTriggerUnit(),2),GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())))
	call UnitDropItemPointLoc(GetTriggerUnit(),UnitItemInSlotBJ(GetTriggerUnit(),3),GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())))
	call UnitDropItemPointLoc(GetTriggerUnit(),UnitItemInSlotBJ(GetTriggerUnit(),4),GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())))
	call UnitDropItemPointLoc(GetTriggerUnit(),UnitItemInSlotBJ(GetTriggerUnit(),5),GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())))
	call UnitDropItemPointLoc(GetTriggerUnit(),UnitItemInSlotBJ(GetTriggerUnit(),6),GetPlayerStartLocationLoc(GetOwningPlayer(GetTriggerUnit())))
	call DisplayTextToForce(GetPlayersAll(),("|cffFFFF00"+(GetPlayerName(GetTriggerPlayer())+"|r has left the game.")))
	call PlaySoundBJ(udg_sound03)
	call RemoveUnit(GetEnumUnit())
	call MultiboardSetItemValueBJ(GetLastCreatedMultiboard(),1,udg_integers01[GetConvertedPlayerId(GetTriggerPlayer())],"TRIGSTR_8828")
	call MultiboardSetItemValueBJ(GetLastCreatedMultiboard(),2,udg_integers01[GetConvertedPlayerId(GetTriggerPlayer())],"TRIGSTR_8829")
	call MultiboardSetItemValueBJ(GetLastCreatedMultiboard(),3,udg_integers01[GetConvertedPlayerId(GetTriggerPlayer())],"TRIGSTR_8830")
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
		exitwhen bj_forLoopAIndex>bj_forLoopAIndexEnd
		set udg_strings03[GetForLoopIndexA()]=((udg_strings01[GetForLoopIndexA()]+GetPlayerName(ConvertedPlayer(GetForLoopIndexA())))+"|r")
		set bj_forLoopAIndex=bj_forLoopAIndex+1
	endloop
endfunction

function Trig_Setup_Players_Func002002001001 takes nothing returns boolean
	return(GetPlayerController(GetFilterPlayer())==MAP_CONTROL_USER)
endfunction

function Trig_Setup_Players_Func002002001002 takes nothing returns boolean
	return(GetPlayerSlotState(GetFilterPlayer())==PLAYER_SLOT_STATE_PLAYING)
endfunction

function Trig_Setup_Players_Func002002001 takes nothing returns boolean
	return GetBooleanAnd(Trig_Setup_Players_Func002002001001(),Trig_Setup_Players_Func002002001002())
endfunction

function Trig_Setup_Players_Func003002001001 takes nothing returns boolean
	return(GetPlayerController(GetFilterPlayer())==MAP_CONTROL_USER)
endfunction

function Trig_Setup_Players_Func003002001002 takes nothing returns boolean
	return(GetPlayerSlotState(GetFilterPlayer())==PLAYER_SLOT_STATE_PLAYING)
endfunction

function Trig_Setup_Players_Func003002001 takes nothing returns boolean
	return GetBooleanAnd(Trig_Setup_Players_Func003002001001(),Trig_Setup_Players_Func003002001002())
endfunction

function Trig_Setup_Players_Func005A takes nothing returns nothing
	call SetPlayerStateBJ(GetEnumPlayer(),PLAYER_STATE_RESOURCE_FOOD_CAP,6)
endfunction

function Trig_Setup_Players_Actions takes nothing returns nothing
	set udg_force03=GetPlayersMatching(Condition(function Trig_Setup_Players_Func002002001))
	set udg_force08=GetPlayersMatching(Condition(function Trig_Setup_Players_Func003002001))
	set udg_integer04=CountPlayersInForceBJ(udg_force03)
	call ForForce(udg_force03,function Trig_Setup_Players_Func005A)
	set udg_force04=GetPlayersAllies(Player(11))
	call ForceRemovePlayerSimple(Player(11),udg_force04)
	set udg_integer19=CountPlayersInForceBJ(udg_force04)
	set udg_force06=GetPlayersAllies(Player(11))
	call ForceRemovePlayerSimple(Player(11),udg_force06)
	set udg_force09=GetPlayersAllies(Player(11))
	call ForceRemovePlayerSimple(Player(11),udg_force09)
	set udg_force05=bj_FORCE_PLAYER[10]
	call ForceRemovePlayerSimple(Player(11),udg_force05)
	set udg_integer20=CountPlayersInForceBJ(udg_force05)
	set udg_force07=GetPlayersAllies(Player(10))
	call ForceRemovePlayerSimple(Player(10),udg_force07)
	set udg_force10=GetPlayersAllies(Player(10))
	call ForceRemovePlayerSimple(Player(10),udg_force10)
endfunction

function Trig_Heros_array_Func001A takes nothing returns nothing
	call PanCameraToTimedLocForPlayer(GetTriggerPlayer(),GetPlayerStartLocationLoc(GetTriggerPlayer()),0)
	call SetPlayerStateBJ(GetEnumPlayer(),PLAYER_STATE_RESOURCE_FOOD_CAP,6)
endfunction

function Trig_Heros_array_Actions takes nothing returns nothing
	call ForForce(GetPlayersAll(),function Trig_Heros_array_Func001A)
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
		exitwhen bj_forLoopAIndex>bj_forLoopAIndexEnd
		set udg_integers04[GetForLoopIndexA()]=GetForLoopIndexA()
		set bj_forLoopAIndex=bj_forLoopAIndex+1
	endloop
	set bj_forLoopAIndex=1
	set bj_forLoopAIndexEnd=udg_integer15
	loop
		exitwhen bj_forLoopAIndex>bj_forLoopAIndexEnd
		set udg_integers10[GetForLoopIndexA()]=GetForLoopIndexA()
		set bj_forLoopAIndex=bj_forLoopAIndex+1
	endloop
	set bj_forLoopAIndex=14
	set bj_forLoopAIndexEnd=udg_integer25
	loop
		exitwhen bj_forLoopAIndex>bj_forLoopAIndexEnd
		set udg_integers09[GetForLoopIndexA()]=GetForLoopIndexA()
		set bj_forLoopAIndex=bj_forLoopAIndex+1
	endloop
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Team_Random_Command_Conditions takes nothing returns boolean
	if(not(GetClickedButtonBJ()==udg_buttons03[2]))then
		return false
	endif
	return true
endfunction

function Trig_Team_Random_Command_Func006Func001C takes nothing returns boolean
	if(not(GetPlayerSlotState(ConvertedPlayer(GetForLoopIndexA()))==PLAYER_SLOT_STATE_PLAYING))then
		return false
	endif
	return true
endfunction

function Trig_Team_Random_Command_Func007Func001C takes nothing returns boolean
	if(not(GetPlayerSlotState(ConvertedPlayer(GetForLoopIndexA()))==PLAYER_SLOT_STATE_PLAYING))then
		return false
	endif
	return true
endfunction

function Trig_Team_Random_Command_Actions takes nothing returns nothing
	call QuestMessageBJ(GetPlayersAll(),bj_QUESTMESSAGE_UPDATED,"TRIGSTR_8831")
	call DisableTrigger(udg_trigger37)
	call DisableTrigger(udg_trigger36)
	set bj_forLoopAIndex=1
	set bj_forLoopAIndexEnd=5
	loop
		exitwhen bj_forLoopAIndex>bj_forLoopAIndexEnd
		if(Trig_Team_Random_Command_Func006Func001C())then
			set udg_integer12=GetRandomInt(1,udg_integer38)
			call CreateNUnitsAtLoc(1,udg_integers13[udg_integers10[udg_integer12]],ConvertedPlayer(GetForLoopIndexA()),GetPlayerStartLocationLoc(ConvertedPlayer(GetForLoopIndexA())),bj_UNIT_FACING)
			call SelectUnitForPlayerSingle(GetLastCreatedUnit(),GetOwningPlayer(GetLastCreatedUnit()))
			call DisplayTextToForce(GetPlayersAll(),((GetPlayerName(GetTriggerPlayer())+" Has Randomed the hero ")+GetUnitName(GetLastCreatedUnit())))
			set udg_integers10[udg_integer12]=udg_integers10[udg_integer38]
			set udg_integer38=(udg_integer38-1)
		else
			call DoNothing()
		endif
		set bj_forLoopAIndex=bj_forLoopAIndex+1
	endloop
	set bj_forLoopAIndex=6
	set bj_forLoopAIndexEnd=10
	loop
		exitwhen bj_forLoopAIndex>bj_forLoopAIndexEnd
		if(Trig_Team_Random_Command_Func007Func001C())then
			set udg_integer27=GetRandomInt(14,udg_integer26)
			call CreateNUnitsAtLoc(1,udg_integers13[udg_integers09[udg_integer27]],ConvertedPlayer(GetForLoopIndexA()),GetPlayerStartLocationLoc(ConvertedPlayer(GetForLoopIndexA())),bj_UNIT_FACING)
			call SelectUnitForPlayerSingle(GetLastCreatedUnit(),GetOwningPlayer(GetLastCreatedUnit()))
			call DisplayTextToForce(GetPlayersAll(),((GetPlayerName(GetTriggerPlayer())+" Has Randomed the hero ")+GetUnitName(GetLastCreatedUnit())))
			set udg_integers09[udg_integer27]=udg_integers09[udg_integer26]
			set udg_integer26=(udg_integer26-1)
		else
			call DoNothing()
		endif
		set bj_forLoopAIndex=bj_forLoopAIndex+1
	endloop
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_AllPick_Conditions takes nothing returns boolean
	if(not(GetClickedButtonBJ()==udg_buttons03[1]))then
		return false
	endif
	return true
endfunction

function Trig_AllPick_Actions takes nothing returns nothing
	call DisplayTextToForce(GetPlayersAll(),"TRIGSTR_8832")
	call PanCameraToTimedLocForPlayer(Player(0),GetRectCenter(udg_rect18),1.00)
	call PanCameraToTimedLocForPlayer(Player(1),GetRectCenter(udg_rect18),1.00)
	call PanCameraToTimedLocForPlayer(Player(2),GetRectCenter(udg_rect18),1.00)
	call PanCameraToTimedLocForPlayer(Player(3),GetRectCenter(udg_rect18),1.00)
	call PanCameraToTimedLocForPlayer(Player(4),GetRectCenter(udg_rect18),1.00)
	call PanCameraToTimedLocForPlayer(Player(5),GetRectCenter(udg_rect28),1.00)
	call PanCameraToTimedLocForPlayer(Player(6),GetRectCenter(udg_rect28),1.00)
	call PanCameraToTimedLocForPlayer(Player(7),GetRectCenter(udg_rect28),1.00)
	call PanCameraToTimedLocForPlayer(Player(8),GetRectCenter(udg_rect28),1.00)
	call PanCameraToTimedLocForPlayer(Player(9),GetRectCenter(udg_rect28),1.00)
	call DisableTrigger(GetTriggeringTrigger())
	call DisableTrigger(udg_trigger36)
	call DoNothing()
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Clear_Wisps_y_Almas_Corruptas_allrandom_Conditions takes nothing returns boolean
	if(not(GetClickedButtonBJ()==udg_buttons03[2]))then
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
	call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetTriggerUnit()),GetUnitLoc(GetTriggerUnit()),1.00)
	call DisableTrigger(GetTriggeringTrigger())
	call EnableTrigger(udg_trigger40)
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Camara_Conditions takes nothing returns boolean
	if(not(IsUnitType(GetTriggerUnit(),UNIT_TYPE_HERO)==true))then
		return false
	endif
	return true
endfunction

function Trig_Camara_Actions takes nothing returns nothing
	call PanCameraToTimedLocForPlayer(GetOwningPlayer(GetTriggerUnit()),GetUnitLoc(GetTriggerUnit()),1.00)
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Vulnerability_Actions takes nothing returns nothing
	call UnitAddAbilityBJ('A032',udg_unit19)
	call UnitAddAbilityBJ('A032',udg_unit24)
	call DisplayTextToForce(GetPlayersAll(),"TRIGSTR_8833")
	call SetUnitInvulnerable(udg_unit19,true)
	call SetUnitInvulnerable(udg_unit24,true)
endfunction

function Trig_Alliance_Base_Conditions takes nothing returns boolean
	if(not(GetUnitTypeId(GetDyingUnit())=='etrp'))then
		return false
	endif
	return true
endfunction

function Trig_Alliance_Base_Func002C takes nothing returns boolean
	if(not(udg_integer08==9))then
		return false
	endif
	return true
endfunction

function Trig_Alliance_Base_Actions takes nothing returns nothing
	set udg_integer08=(udg_integer08+1)
	if(Trig_Alliance_Base_Func002C())then
		call SetUnitInvulnerable(udg_unit19,false)
		call UnitRemoveAbilityBJ('A032',udg_unit19)
		call QuestMessageBJ(GetPlayersAll(),bj_QUESTMESSAGE_UPDATED,"TRIGSTR_8834")
		call DisableTrigger(GetTriggeringTrigger())
	else
	endif
endfunction

function Trig_Orc_Base_Conditions takes nothing returns boolean
	if(not(GetUnitTypeId(GetDyingUnit())=='uzg1'))then
		return false
	endif
	return true
endfunction

function Trig_Orc_Base_Func002C takes nothing returns boolean
	if(not(udg_integer07==9))then
		return false
	endif
	return true
endfunction

function Trig_Orc_Base_Actions takes nothing returns nothing
	set udg_integer07=(udg_integer07+1)
	if(Trig_Orc_Base_Func002C())then
		call SetUnitInvulnerable(udg_unit24,false)
		call UnitRemoveAbilityBJ('A032',udg_unit24)
		call QuestMessageBJ(GetPlayersAll(),bj_QUESTMESSAGE_UPDATED,"TRIGSTR_8835")
		call DisableTrigger(GetTriggeringTrigger())
	else
	endif
endfunction

// ==================== HUMANOS ====================
function Trig_Human_Footmen_Conditions takes nothing returns boolean
	if(not(GetUnitStateSwap(UNIT_STATE_LIFE,udg_unit23)>0.00))then
		return false
	endif
	return true
endfunction

function Trig_Human_Footmen_Actions takes nothing returns nothing
	local integer i = 0
	local real x = GetRectCenterX(udg_rect19)
	local real y = GetRectCenterY(udg_rect19)
	loop
		exitwhen i == 4
		call CreateUnit(Player(10), 'h000', x, y, bj_UNIT_FACING)
		set i = i + 1
	endloop
endfunction

function Trig_Human_Riflemen_Conditions takes nothing returns boolean
	if(not(GetUnitStateSwap(UNIT_STATE_LIFE,udg_unit23)>0.00))then
		return false
	endif
	return true
endfunction

function Trig_Human_Riflemen_Actions takes nothing returns nothing
	local integer i = 0
	local real x = GetRectCenterX(udg_rect19)
	local real y = GetRectCenterY(udg_rect19)
	loop
		exitwhen i == 2
		call CreateUnit(Player(10), 'h001', x, y, bj_UNIT_FACING)
		set i = i + 1
	endloop
endfunction

function Trig_Human_Mountan_Giant_Conditions takes nothing returns boolean
	if(not(GetUnitStateSwap(UNIT_STATE_LIFE,udg_unit22)>0.00))then
		return false
	endif
	return true
endfunction

function Trig_Human_Mountan_Giant_Actions takes nothing returns nothing
	call CreateUnit(Player(10), 'h009', GetRectCenterX(udg_rect20), GetRectCenterY(udg_rect20), bj_UNIT_FACING)
endfunction

function Trig_Human_Huntress_Conditions takes nothing returns boolean
	if(not(GetUnitStateSwap(UNIT_STATE_LIFE,udg_unit21)>0.00))then
		return false
	endif
	return true
endfunction

function Trig_Human_Huntress_Actions takes nothing returns nothing
	local integer i = 0
	local real x = GetRectCenterX(udg_rect21)
	local real y = GetRectCenterY(udg_rect21)
	loop
		exitwhen i == 2
		call CreateUnit(Player(10), 'h006', x, y, bj_UNIT_FACING)
		set i = i + 1
	endloop
endfunction

function Trig_Human_Archer_Conditions takes nothing returns boolean
	if(not(GetUnitStateSwap(UNIT_STATE_LIFE,udg_unit21)>0.00))then
		return false
	endif
	return true
endfunction

function Trig_Human_Archer_Actions takes nothing returns nothing
	local integer i = 0
	local real x = GetRectCenterX(udg_rect22)
	local real y = GetRectCenterY(udg_rect22)
	loop
		exitwhen i == 4
		call CreateUnit(Player(10), 'h007', x, y, bj_UNIT_FACING)
		set i = i + 1
	endloop
endfunction

function Trig_Human_Mountain_Giant_Conditions takes nothing returns boolean
	if(not(GetUnitStateSwap(UNIT_STATE_LIFE,udg_unit20)>0.00))then
		return false
	endif
	return true
endfunction

function Trig_Human_Mountain_Giant_Actions takes nothing returns nothing
	call CreateUnit(Player(10), 'h009', GetRectCenterX(udg_rect22), GetRectCenterY(udg_rect22), bj_UNIT_FACING)
endfunction

// ==================== ORCOS ====================
function Trig_Orcs_Ghoul_Conditions takes nothing returns boolean
	if(not(GetUnitStateSwap(UNIT_STATE_LIFE,udg_unit27)>0.00))then
		return false
	endif
	return true
endfunction

function Trig_Orcs_Ghoul_Actions takes nothing returns nothing
	local integer i = 0
	local real x = GetRectCenterX(udg_rect29)
	local real y = GetRectCenterY(udg_rect29)
	loop
		exitwhen i == 4
		call CreateUnit(Player(11), 'o000', x, y, bj_UNIT_FACING)
		set i = i + 1
	endloop
endfunction

function Trig_Orcs_Necremancer_Conditions takes nothing returns boolean
	if(not(GetUnitStateSwap(UNIT_STATE_LIFE,udg_unit27)>0.00))then
		return false
	endif
	return true
endfunction

function Trig_Orcs_Necremancer_Actions takes nothing returns nothing
	local integer i = 0
	local real x = GetRectCenterX(udg_rect29)
	local real y = GetRectCenterY(udg_rect29)
	loop
		exitwhen i == 2
		call CreateUnit(Player(11), 'o001', x, y, bj_UNIT_FACING)
		set i = i + 1
	endloop
endfunction

function Trig_Orcs_Tauren_Conditions takes nothing returns boolean
	if(not(GetUnitStateSwap(UNIT_STATE_LIFE,udg_unit28)>0.00))then
		return false
	endif
	return true
endfunction

function Trig_Orcs_Tauren_Actions takes nothing returns nothing
	call CreateUnit(Player(11), 'o002', GetRectCenterX(udg_rect30), GetRectCenterY(udg_rect30), bj_UNIT_FACING)
endfunction

function Trig_Orcs_Tauren_de_abajo_Conditions takes nothing returns boolean
	if(not(GetUnitStateSwap(UNIT_STATE_LIFE,udg_unit26)>0.00))then
		return false
	endif
	return true
endfunction

function Trig_Orcs_Tauren_de_abajo_Actions takes nothing returns nothing
	call CreateUnit(Player(11), 'o008', GetRectCenterX(udg_rect31), GetRectCenterY(udg_rect31), bj_UNIT_FACING)
endfunction

function Trig_Orcs_Grunts_Conditions takes nothing returns boolean
	if(not(GetUnitStateSwap(UNIT_STATE_LIFE,udg_unit25)>0.00))then
		return false
	endif
	return true
endfunction

function Trig_Orcs_Grunts_Actions takes nothing returns nothing
	local integer i = 0
	local real x = GetRectCenterX(udg_rect32)
	local real y = GetRectCenterY(udg_rect32)
	loop
		exitwhen i == 4
		call CreateUnit(Player(11), 'o007', x, y, bj_UNIT_FACING)
		set i = i + 1
	endloop
endfunction

function Trig_Orcs_Shamans_Conditions takes nothing returns boolean
	if(not(GetUnitStateSwap(UNIT_STATE_LIFE,udg_unit25)>0.00))then
		return false
	endif
	return true
endfunction

function Trig_Orcs_Shamans_Actions takes nothing returns nothing
	local integer i = 0
	local real x = GetRectCenterX(udg_rect32)
	local real y = GetRectCenterY(udg_rect32)
	loop
		exitwhen i == 2
		call CreateUnit(Player(11), 'o009', x, y, bj_UNIT_FACING)
		set i = i + 1
	endloop
endfunction

function Trig_Magnadefender_Conditions takes nothing returns boolean
	if(not(GetUnitTypeId(GetEnteringUnit())=='ewsp'))then
		return false
	endif
	return true
endfunction

function Trig_Magnadefender_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1,'O00B',GetOwningPlayer(GetEnteringUnit()),GetRectCenter(udg_rect23),bj_UNIT_FACING)
	call KillUnit(udg_unit45)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Magic_Gladiator_Conditions takes nothing returns boolean
	if(not(GetUnitTypeId(GetEnteringUnit())=='ewsp'))then
		return false
	endif
	return true
endfunction

function Trig_Magic_Gladiator_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1,'H00G',GetOwningPlayer(GetEnteringUnit()),GetRectCenter(udg_rect23),bj_UNIT_FACING)
	call KillUnit(udg_unit46)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Demon_Hunter_Conditions takes nothing returns boolean
	if(not(GetUnitTypeId(GetEnteringUnit())=='ewsp'))then
		return false
	endif
	return true
endfunction

function Trig_Demon_Hunter_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1,'Edem',GetOwningPlayer(GetEnteringUnit()),GetRectCenter(udg_rect23),bj_UNIT_FACING)
	call KillUnit(udg_unit06)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Priestess_of_the_Moon_Conditions takes nothing returns boolean
	if(not(GetUnitTypeId(GetEnteringUnit())=='ewsp'))then
		return false
	endif
	return true
endfunction

function Trig_Priestess_of_the_Moon_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1,'Emoo',GetOwningPlayer(GetEnteringUnit()),GetRectCenter(udg_rect23),bj_UNIT_FACING)
	call KillUnit(udg_unit12)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Warden_Conditions takes nothing returns boolean
	if(not(GetUnitTypeId(GetEnteringUnit())=='ewsp'))then
		return false
	endif
	return true
endfunction

function Trig_Warden_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1,'Ewar',GetOwningPlayer(GetEnteringUnit()),GetRectCenter(udg_rect23),bj_UNIT_FACING)
	call KillUnit(udg_unit09)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Keeper_of_the_Groove_Conditions takes nothing returns boolean
	if(not(GetUnitTypeId(GetEnteringUnit())=='ewsp'))then
		return false
	endif
	return true
endfunction

function Trig_Keeper_of_the_Groove_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1,'Ekee',GetOwningPlayer(GetEnteringUnit()),GetRectCenter(udg_rect23),bj_UNIT_FACING)
	call KillUnit(udg_unit08)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Asesina_Conditions takes nothing returns boolean
	if(not(GetUnitTypeId(GetEnteringUnit())=='ewsp'))then
		return false
	endif
	return true
endfunction

function Trig_Asesina_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1,'E005',GetOwningPlayer(GetEnteringUnit()),GetRectCenter(udg_rect23),bj_UNIT_FACING)
	call KillUnit(udg_unit11)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Paladin_Conditions takes nothing returns boolean
	if(not(GetUnitTypeId(GetEnteringUnit())=='ewsp'))then
		return false
	endif
	return true
endfunction

function Trig_Paladin_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1,'Hpal',GetOwningPlayer(GetEnteringUnit()),GetRectCenter(udg_rect23),bj_UNIT_FACING)
	call KillUnit(udg_unit07)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Archmage_Conditions takes nothing returns boolean
	if(not(GetUnitTypeId(GetEnteringUnit())=='ewsp'))then
		return false
	endif
	return true
endfunction

function Trig_Archmage_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1,'Hamg',GetOwningPlayer(GetEnteringUnit()),GetRectCenter(udg_rect23),bj_UNIT_FACING)
	call KillUnit(udg_unit03)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Mountain_King_Conditions takes nothing returns boolean
	if(not(GetUnitTypeId(GetEnteringUnit())=='ewsp'))then
		return false
	endif
	return true
endfunction

function Trig_Mountain_King_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1,'Hmkg',GetOwningPlayer(GetEnteringUnit()),GetRectCenter(udg_rect23),bj_UNIT_FACING)
	call KillUnit(udg_unit04)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Blood_Mage_Conditions takes nothing returns boolean
	if(not(GetUnitTypeId(GetEnteringUnit())=='ewsp'))then
		return false
	endif
	return true
endfunction

function Trig_Blood_Mage_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1,'Hblm',GetOwningPlayer(GetEnteringUnit()),GetRectCenter(udg_rect23),bj_UNIT_FACING)
	call KillUnit(udg_unit05)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Lord_Gharitos_Conditions takes nothing returns boolean
	if(not(GetUnitTypeId(GetEnteringUnit())=='ewsp'))then
		return false
	endif
	return true
endfunction

function Trig_Lord_Gharitos_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1,'Hlgr',GetOwningPlayer(GetEnteringUnit()),GetRectCenter(udg_rect23),bj_UNIT_FACING)
	call KillUnit(udg_unit13)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Ranger_Conditions takes nothing returns boolean
	if(not(GetUnitTypeId(GetEnteringUnit())=='ewsp'))then
		return false
	endif
	return true
endfunction

function Trig_Ranger_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1,'Hvwd',GetOwningPlayer(GetEnteringUnit()),GetRectCenter(udg_rect23),bj_UNIT_FACING)
	call KillUnit(udg_unit10)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Blademaster_Conditions takes nothing returns boolean
	if(not(GetUnitTypeId(GetEnteringUnit())=='e006'))then
		return false
	endif
	return true
endfunction

function Trig_Blademaster_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1,'Obla',GetOwningPlayer(GetEnteringUnit()),GetRectCenter(udg_rect33),bj_UNIT_FACING)
	call KillUnit(udg_unit38)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Far_Seer_Conditions takes nothing returns boolean
	if(not(GetUnitTypeId(GetEnteringUnit())=='e006'))then
		return false
	endif
	return true
endfunction

function Trig_Far_Seer_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1,'Ofar',GetOwningPlayer(GetEnteringUnit()),GetRectCenter(udg_rect33),bj_UNIT_FACING)
	call KillUnit(udg_unit31)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Tauren_Chieftain_Conditions takes nothing returns boolean
	if(not(GetUnitTypeId(GetEnteringUnit())=='e006'))then
		return false
	endif
	return true
endfunction

function Trig_Tauren_Chieftain_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1,'Otch',GetOwningPlayer(GetEnteringUnit()),GetRectCenter(udg_rect33),bj_UNIT_FACING)
	call KillUnit(udg_unit37)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Shadow_Hunter_Conditions takes nothing returns boolean
	if(not(GetUnitTypeId(GetEnteringUnit())=='e006'))then
		return false
	endif
	return true
endfunction

function Trig_Shadow_Hunter_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1,'Oshd',GetOwningPlayer(GetEnteringUnit()),GetRectCenter(udg_rect33),bj_UNIT_FACING)
	call KillUnit(udg_unit30)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Warsong_Chieftain_Conditions takes nothing returns boolean
	if(not(GetUnitTypeId(GetEnteringUnit())=='e006'))then
		return false
	endif
	return true
endfunction

function Trig_Warsong_Chieftain_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1,'Ogrh',GetOwningPlayer(GetEnteringUnit()),GetRectCenter(udg_rect33),bj_UNIT_FACING)
	call KillUnit(udg_unit47)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Crypt_Lord_Conditions takes nothing returns boolean
	if(not(GetUnitTypeId(GetEnteringUnit())=='e006'))then
		return false
	endif
	return true
endfunction

function Trig_Crypt_Lord_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1,'Ucrl',GetOwningPlayer(GetEnteringUnit()),GetRectCenter(udg_rect33),bj_UNIT_FACING)
	call KillUnit(udg_unit32)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Death_Knight_Conditions takes nothing returns boolean
	if(not(GetUnitTypeId(GetEnteringUnit())=='e006'))then
		return false
	endif
	return true
endfunction

function Trig_Death_Knight_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1,'Udea',GetOwningPlayer(GetEnteringUnit()),GetRectCenter(udg_rect33),bj_UNIT_FACING)
	call KillUnit(udg_unit29)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Dreadlord_Conditions takes nothing returns boolean
	if(not(GetUnitTypeId(GetEnteringUnit())=='e006'))then
		return false
	endif
	return true
endfunction

function Trig_Dreadlord_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1,'Udre',GetOwningPlayer(GetEnteringUnit()),GetRectCenter(udg_rect33),bj_UNIT_FACING)
	call KillUnit(udg_unit33)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Lich_Conditions takes nothing returns boolean
	if(not(GetUnitTypeId(GetEnteringUnit())=='e006'))then
		return false
	endif
	return true
endfunction

function Trig_Lich_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1,'Ulic',GetOwningPlayer(GetEnteringUnit()),GetRectCenter(udg_rect33),bj_UNIT_FACING)
	call KillUnit(udg_unit34)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Nigromante_Conditions takes nothing returns boolean
	if(not(GetUnitTypeId(GetEnteringUnit())=='e006'))then
		return false
	endif
	return true
endfunction

function Trig_Nigromante_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1,'Nman',GetOwningPlayer(GetEnteringUnit()),GetRectCenter(udg_rect33),bj_UNIT_FACING)
	call KillUnit(udg_unit35)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Firelord_Conditions takes nothing returns boolean
	if(not(GetUnitTypeId(GetEnteringUnit())=='e006'))then
		return false
	endif
	return true
endfunction

function Trig_Firelord_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1,'Nfir',GetOwningPlayer(GetEnteringUnit()),GetRectCenter(udg_rect33),bj_UNIT_FACING)
	call KillUnit(udg_unit36)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Dark_Ranger_Conditions takes nothing returns boolean
	if(not(GetUnitTypeId(GetEnteringUnit())=='e006'))then
		return false
	endif
	return true
endfunction

function Trig_Dark_Ranger_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1,'Usyl',GetOwningPlayer(GetEnteringUnit()),GetRectCenter(udg_rect33),bj_UNIT_FACING)
	call KillUnit(udg_unit44)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Storm_Conditions takes nothing returns boolean
	if(not(GetUnitTypeId(GetEnteringUnit())=='e006'))then
		return false
	endif
	return true
endfunction

function Trig_Storm_Actions takes nothing returns nothing
	call ExplodeUnitBJ(GetEnteringUnit())
	call CreateNUnitsAtLoc(1,'H00K',GetOwningPlayer(GetEnteringUnit()),GetRectCenter(udg_rect33),bj_UNIT_FACING)
	call KillUnit(udg_unit48)
	call DisableTrigger(GetTriggeringTrigger())
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Trig_Revive_Human_hero_player_1_Conditions takes nothing returns boolean
	if(not(IsUnitType(GetDyingUnit(),UNIT_TYPE_HERO)==true))then
		return false
	endif
	return true
endfunction

function Trig_Revive_Human_hero_player_1_Actions takes nothing returns nothing
	set udg_real01=(udg_real02+(I2R(GetHeroLevel(GetTriggerUnit()))*3.00))
	call CreateTimerDialogBJ(udg_timer02,GetPlayerName(GetTriggerPlayer()))
	set udg_timerdialog03=GetLastCreatedTimerDialogBJ()
	call StartTimerBJ(udg_timer02,false,udg_real01)
	call TriggerSleepAction(udg_real01)
	call DestroyTimerDialogBJ(udg_timerdialog03)
	call ReviveHeroLoc(GetTriggerUnit(),GetRectCenter(udg_rect12),true)
endfunction

function Trig_Revive_Human_hero_player_2_Conditions takes nothing returns boolean
	if(not(IsUnitType(GetDyingUnit(),UNIT_TYPE_HERO)==true))then
		return false
	endif
	return true
endfunction

function Trig_Revive_Human_hero_player_2_Actions takes nothing returns nothing
	set udg_real01=(udg_real02+(I2R(GetHeroLevel(GetTriggerUnit()))*3.00))
	call CreateTimerDialogBJ(udg_timer03,GetPlayerName(GetTriggerPlayer()))
	set udg_timerdialog04=GetLastCreatedTimerDialogBJ()
	call StartTimerBJ(udg_timer03,false,udg_real01)
	call TriggerSleepAction(udg_real01)
	call DestroyTimerDialogBJ(udg_timerdialog04)
	call ReviveHeroLoc(GetTriggerUnit(),GetRectCenter(udg_rect12),true)
endfunction

function Trig_Revive_Human_hero_player_3_Conditions takes nothing returns boolean
	if(not(IsUnitType(GetDyingUnit(),UNIT_TYPE_HERO)==true))then
		return false
	endif
	return true
endfunction

function Trig_Revive_Human_hero_player_3_Actions takes nothing returns nothing
	set udg_real01=(udg_real02+(I2R(GetHeroLevel(GetTriggerUnit()))*3.00))
	call CreateTimerDialogBJ(udg_timer04,GetPlayerName(GetTriggerPlayer()))
	set udg_timerdialog05=GetLastCreatedTimerDialogBJ()
	call StartTimerBJ(udg_timer04,false,udg_real01)
	call TriggerSleepAction(udg_real01)
	call DestroyTimerDialogBJ(udg_timerdialog05)
	call ReviveHeroLoc(GetTriggerUnit(),GetRectCenter(udg_rect13),true)
endfunction

function Trig_Revive_Human_hero_player_4_Conditions takes nothing returns boolean
	if(not(IsUnitType(GetDyingUnit(),UNIT_TYPE_HERO)==true))then
		return false
	endif
	return true
endfunction

function Trig_Revive_Human_hero_player_4_Actions takes nothing returns nothing
	set udg_real01=(udg_real02+(I2R(GetHeroLevel(GetTriggerUnit()))*3.00))
	call CreateTimerDialogBJ(udg_timer05,GetPlayerName(GetTriggerPlayer()))
	set udg_timerdialog12=GetLastCreatedTimerDialogBJ()
	call StartTimerBJ(udg_timer05,false,udg_real01)
	call TriggerSleepAction(udg_real01)
	call DestroyTimerDialogBJ(udg_timerdialog12)
	call ReviveHeroLoc(GetTriggerUnit(),GetRectCenter(udg_rect13),true)
endfunction

function Trig_Revive_Human_hero_player_5_Conditions takes nothing returns boolean
	if(not(IsUnitType(GetDyingUnit(),UNIT_TYPE_HERO)==true))then
		return false
	endif
	return true
endfunction

function Trig_Revive_Human_hero_player_5_Actions takes nothing returns nothing
	set udg_real01=(udg_real02+(I2R(GetHeroLevel(GetTriggerUnit()))*3.00))
	call CreateTimerDialogBJ(udg_timer06,GetPlayerName(GetTriggerPlayer()))
	set udg_timerdialog07=GetLastCreatedTimerDialogBJ()
	call StartTimerBJ(udg_timer06,false,udg_real01)
	call TriggerSleepAction(udg_real01)
	call DestroyTimerDialogBJ(udg_timerdialog07)
	call ReviveHeroLoc(GetTriggerUnit(),GetRectCenter(udg_rect13),true)
endfunction

function Trig_Revive_Orc_hero_player_6_Conditions takes nothing returns boolean
	if(not(IsUnitType(GetDyingUnit(),UNIT_TYPE_HERO)==true))then
		return false
	endif
	return true
endfunction

function Trig_Revive_Orc_hero_player_6_Actions takes nothing returns nothing
	set udg_real01=(udg_real02+(I2R(GetHeroLevel(GetTriggerUnit()))*3.00))
	call CreateTimerDialogBJ(udg_timer07,GetPlayerName(GetTriggerPlayer()))
	set udg_timerdialog06=GetLastCreatedTimerDialogBJ()
	call StartTimerBJ(udg_timer07,false,udg_real01)
	call TriggerSleepAction(udg_real01)
	call DestroyTimerDialogBJ(udg_timerdialog06)
	call ReviveHeroLoc(GetTriggerUnit(),GetRectCenter(udg_rect15),true)
endfunction

function Trig_Revive_Orc_hero_player_7_Conditions takes nothing returns boolean
	if(not(IsUnitType(GetDyingUnit(),UNIT_TYPE_HERO)==true))then
		return false
	endif
	return true
endfunction

function Trig_Revive_Orc_hero_player_7_Actions takes nothing returns nothing
	set udg_real01=(udg_real02+(I2R(GetHeroLevel(GetTriggerUnit()))*3.00))
	call CreateTimerDialogBJ(udg_timer08,GetPlayerName(GetTriggerPlayer()))
	set udg_timerdialog10=GetLastCreatedTimerDialogBJ()
	call StartTimerBJ(udg_timer08,false,udg_real01)
	call TriggerSleepAction(udg_real01)
	call DestroyTimerDialogBJ(udg_timerdialog10)
	call ReviveHeroLoc(GetTriggerUnit(),GetRectCenter(udg_rect15),true)
endfunction

function Trig_Revive_Orc_hero_player_8_Conditions takes nothing returns boolean
	if(not(IsUnitType(GetDyingUnit(),UNIT_TYPE_HERO)==true))then
		return false
	endif
	return true
endfunction

function Trig_Revive_Orc_hero_player_8_Actions takes nothing returns nothing
	set udg_real01=(udg_real02+(I2R(GetHeroLevel(GetTriggerUnit()))*3.00))
	call CreateTimerDialogBJ(udg_timer09,GetPlayerName(GetTriggerPlayer()))
	set udg_timerdialog09=GetLastCreatedTimerDialogBJ()
	call StartTimerBJ(udg_timer09,false,udg_real01)
	call TriggerSleepAction(udg_real01)
	call DestroyTimerDialogBJ(udg_timerdialog09)
	call ReviveHeroLoc(GetTriggerUnit(),GetRectCenter(udg_rect16),true)
endfunction

function Trig_Revive_Orc_hero_player_9_Conditions takes nothing returns boolean
	if(not(IsUnitType(GetDyingUnit(),UNIT_TYPE_HERO)==true))then
		return false
	endif
	return true
endfunction

function Trig_Revive_Orc_hero_player_9_Actions takes nothing returns nothing
	set udg_real01=(udg_real02+(I2R(GetHeroLevel(GetTriggerUnit()))*3.00))
	call CreateTimerDialogBJ(udg_timer10,GetPlayerName(GetTriggerPlayer()))
	set udg_timerdialog08=GetLastCreatedTimerDialogBJ()
	call StartTimerBJ(udg_timer10,false,udg_real01)
	call TriggerSleepAction(udg_real01)
	call DestroyTimerDialogBJ(udg_timerdialog08)
	call ReviveHeroLoc(GetTriggerUnit(),GetRectCenter(udg_rect16),true)
endfunction

function Trig_Revive_Orc_hero_player_10_Conditions takes nothing returns boolean
	if(not(IsUnitType(GetDyingUnit(),UNIT_TYPE_HERO)==true))then
		return false
	endif
	return true
endfunction

function Trig_Revive_Orc_hero_player_10_Actions takes nothing returns nothing
	set udg_real01=(udg_real02+(I2R(GetHeroLevel(GetTriggerUnit()))*3.00))
	call CreateTimerDialogBJ(udg_timer11,GetPlayerName(GetTriggerPlayer()))
	set udg_timerdialog11=GetLastCreatedTimerDialogBJ()
	call StartTimerBJ(udg_timer11,false,udg_real01)
	call TriggerSleepAction(udg_real01)
	call DestroyTimerDialogBJ(udg_timerdialog11)
	call ReviveHeroLoc(GetTriggerUnit(),GetRectCenter(udg_rect16),true)
endfunction

function Trig_Blademaster_Invul_Blade_Conditions takes nothing returns boolean
	if(not(GetSpellAbilityId()=='AOww'))then
		return false
	endif
	return true
endfunction

function Trig_Blademaster_Invul_Blade_Actions takes nothing returns nothing
	call SetUnitInvulnerable(GetTriggerUnit(),true)
	call TriggerSleepAction(7.00)
	call SetUnitInvulnerable(GetTriggerUnit(),false)
endfunction

function Trig_Help_Actions takes nothing returns nothing
	// [DESACTIVADO 2026-06-09] Quests fantasma del F9 (legacy).
	// Sus titulos (TRIGSTR_88xx) viven en war3map.wts y estan VACIOS -> generaban
	// 4 pestañas sin nombre en el menu F9. El F9 limpio se construye desde cero en
	// EXTRAS/Sistema_F9.j (titulos directos en codigo). NO reactivar estas lineas.
	//call CreateQuestBJ(bj_QUESTTYPE_REQ_DISCOVERED,"TRIGSTR_8836","TRIGSTR_8837","ReplaceableTextures\\PassiveButtons\\PASBTNStatUp.blp")
	//call CreateQuestBJ(bj_QUESTTYPE_REQ_DISCOVERED,"TRIGSTR_8838","TRIGSTR_8839","ReplaceableTextures\\CommandButtons\\BTNAvatarOff.blp")
	//call CreateQuestBJ(bj_QUESTTYPE_REQ_DISCOVERED,"TRIGSTR_8840","TRIGSTR_8841","ReplaceableTextures\\CommandButtons\\BTNDruidOfTheClaw.blp")
	//call CreateQuestBJ(bj_QUESTTYPE_OPT_DISCOVERED,"TRIGSTR_8842","TRIGSTR_8843","ReplaceableTextures\\CommandButtons\\BTNScrollUber.blp")
endfunction

function Trig_Matchup_Actions takes nothing returns nothing
	local player p = GetTriggerPlayer()
	local group g = CreateGroup()
	local unit u
	local player enemy
	local integer i = 0
	local boolean foundHero
	local string status
	local boolean hasEnemies = false
    
	// ====================================================
	// BÚSQUEDA HÍPER-EFICIENTE (Cero Lag)
	// ====================================================
	// Iteramos por los 12 slots de jugadores posibles (IDs 0 a 11)
	loop
		exitwhen i > 9
		set enemy = Player(i)
        
		// 1. Verificamos: ¿Está en la partida? ¿Es un jugador humano? ¿Es un ENEMIGO?
		if GetPlayerSlotState(enemy) == PLAYER_SLOT_STATE_PLAYING and (GetPlayerController(enemy) == MAP_CONTROL_USER or GetPlayerController(enemy) == MAP_CONTROL_COMPUTER) and IsPlayerEnemy(enemy, p) then
            
			if not hasEnemies then
				call DisplayTimedTextToPlayer(p, 0, 0, 15.0, "|cffFFCC00============= MATCHUP ===============|r")
				set hasEnemies = true
			endif
            
			set foundHero = false
            
			// 2. Agrupamos SOLO las unidades de este enemigo puntual (Rapidísimo, no escanea el mapa)
			call GroupEnumUnitsOfPlayer(g, enemy, null)
            
			loop
				set u = FirstOfGroup(g)
				exitwhen u == null
                
				// 3. Filtro a prueba de balas: Es Héroe y NO es Ilusión
				// OJO: Aquí NO verificamos si está vivo en el 'if' principal, porque si el enemigo 
				// está muerto esperando revivir, ¡aún así queremos saber qué héroe es!
				if IsUnitType(u, UNIT_TYPE_HERO) and not IsUnitIllusion(u) then
                    
					// Detalle táctico: Comprobamos el estado vital para informarle al jugador
					if GetWidgetLife(u) > 0.405 then
						set status = "Vivo"
					else
						set status = "Muerto"
					endif
                    
					// udg_strings03 ya tiene el color nativo y nombre del enemigo (ej: "|c00ff0303Player 1|r")
					// Sumamos + 1 al índice porque en JASS las arrays de tu GUI original empezaron en 1
					call DisplayTimedTextToPlayer(p, 0, 0, 15.0, udg_strings03[i + 1] + " controla a: |cff00FFFF" + GetUnitName(u) + "|r")
                    
					set foundHero = true
					exitwhen true // Cortocircuito: Encontramos su héroe, saltamos al siguiente jugador
				endif
                
				// Sacamos la unidad descartada del grupo para seguir iterando
				call GroupRemoveUnit(g, u)
			endloop
            
			// Vaciar el grupo (Nuestro confiable Anti Shadow-Leaks por salir temprano del loop)
			call GroupClear(g)
            
			// 4. Si el enemigo está en la partida pero aún no eligió héroe en la taberna
			if not foundHero then
				call DisplayTimedTextToPlayer(p, 0, 0, 15.0, udg_strings03[i + 1] + " |cff888888(Sin héroe)|r")
			endif
		endif
        
		set i = i + 1
	endloop
    
	// Pie del reporte
	if hasEnemies then
		call DisplayTimedTextToPlayer(p, 0, 0, 15.0, "|cffFFCC00======================================|r")
	endif
    
	// ====================================================
	// LIMPIEZA DE PUNTEROS (100% Sin Fugas)
	// ====================================================
	call DestroyGroup(g)
	set g = null
	set p = null
	set enemy = null
	set u = null
endfunction

function Trig_Movespeed_Actions takes nothing returns nothing
	local player p = GetTriggerPlayer()
	local group g = CreateGroup()
	local unit u
	local unit hero = null
    
	local real baseMS
	local real finalMS
	local real bonusMS
    
	// ====================================================
	// 1. BUSCAR AL HÉROE (Máximo Rendimiento + Anti-Leaks)
	// ====================================================
	call GroupEnumUnitsOfPlayer(g, p, null)
	loop
		set u = FirstOfGroup(g)
		exitwhen u == null
        
		// Filtro a prueba de balas: Héroe, Real (no ilusión) y Vivo
		if IsUnitType(u, UNIT_TYPE_HERO) and not IsUnitIllusion(u) and GetWidgetLife(u) > 0.405 then
			set hero = u
			exitwhen true // Cortocircuito: Rompe el loop para ahorrar procesamiento
		endif
        
		// Removemos la unidad NO-HÉROE para seguir buscando
		call GroupRemoveUnit(g, u)
	endloop
    
	// ¡EL TOQUE PURISTA ANTI-LEAKS!
	// Como salimos temprano, el grupo AÚN tiene unidades adentro.
	// Usamos GroupClear para vaciarlo obligatoriamente antes de destruirlo.
	call GroupClear(g)
	call DestroyGroup(g)
	set g = null
    
	if hero == null then
		call DisplayTimedTextToPlayer(p, 0, 0, 5.0, "|cffFF0000[Sistema]|r No se encontró un héroe activo o vivo.")
		set p = null
		set u = null
		return
	endif
    
	// ====================================================
	// 2. EXTRAER DATOS
	// ====================================================
	set baseMS = GetUnitDefaultMoveSpeed(hero)
	set finalMS = GetUnitMoveSpeed(hero)
	set bonusMS = finalMS - baseMS
    
	// ====================================================
	// 3. IMPRIMIR REPORTE (Estética Perfecta)
	// ====================================================
	call DisplayTimedTextToPlayer(p, 0, 0, 15.0, "|cffFFCC00===== VELOCIDAD DE MOVIMIENTO =====|r")
    
	// SECCIÓN 1: Identificación y Base
	call DisplayTimedTextToPlayer(p, 0, 0, 15.0, "Héroe: |cff00FFFF" + GetUnitName(hero) + "|r")
	call DisplayTimedTextToPlayer(p, 0, 0, 15.0, "Velocidad Base: " + I2S(R2I(baseMS)) + " pts|r")
	call DisplayTimedTextToPlayer(p, 0, 0, 15.0, " ")
    
	// SECCIÓN 2: Modificadores (Neto en puntos)
	if bonusMS > 0.0 then
		call DisplayTimedTextToPlayer(p, 0, 0, 15.0, "|cffAAAAAA[A]|r Bono (Items/Auras):  |cff00FF00+" + I2S(R2I(bonusMS)) + " pts|r")
	elseif bonusMS < 0.0 then
		call DisplayTimedTextToPlayer(p, 0, 0, 15.0, "|cffAAAAAA[A]|r Penalización: |cffFF0000" + I2S(R2I(bonusMS)) + " pts|r")
	else
		call DisplayTimedTextToPlayer(p, 0, 0, 15.0, "|cffAAAAAA[A]|r Bono (Items/Auras):  |cff8888880 pts|r")
	endif
    
	call DisplayTimedTextToPlayer(p, 0, 0, 15.0, " ")
    
	// SECCIÓN 3: Resultado Final
	call DisplayTimedTextToPlayer(p, 0, 0, 15.0, "Velocidad de Movimiento Final: |cffFFFF00" + I2S(R2I(finalMS)) + " pts|r")
	call DisplayTimedTextToPlayer(p, 0, 0, 15.0, "|cffFFCC00=======================================|r")
    
	// ====================================================
	// 4. LIMPIEZA DE PUNTEROS
	// ====================================================
	set p = null
	set hero = null
	set u = null
endfunction

function Trig_Item_Drop_Humanos_Func003A takes nothing returns nothing
	set bj_forLoopAIndex=1
	set bj_forLoopAIndexEnd=6
	loop
		exitwhen bj_forLoopAIndex>bj_forLoopAIndexEnd
		call CreateItemLoc(GetItemTypeId(UnitItemInSlotBJ(GetEnumUnit(),GetForLoopIndexA())),GetRectCenter(udg_rect13))
		set bj_forLoopAIndex=bj_forLoopAIndex+1
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
		exitwhen bj_forLoopAIndex>bj_forLoopAIndexEnd
		call CreateItemLoc(GetItemTypeId(UnitItemInSlotBJ(GetEnumUnit(),GetForLoopIndexA())),GetRectCenter(udg_rect15))
		set bj_forLoopAIndex=bj_forLoopAIndex+1
	endloop
endfunction

function Trig_Item_Drop_Orcos_Actions takes nothing returns nothing
	call DisplayTimedTextToForce(GetPlayersAll(),5.00,(GetPlayerName(GetTriggerPlayer())+"Leaver detected"))
	set udg_group02=GetUnitsOfPlayerAll(GetTriggerPlayer())
	call ForGroupBJ(udg_group02,function Trig_Item_Drop_Orcos_Func003A)
endfunction

function Trig_Cash_1_Actions takes nothing returns nothing
	call AdjustPlayerStateBJ(3,Player(0),PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(3,Player(1),PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(3,Player(2),PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(3,Player(3),PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(3,Player(4),PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(3,Player(5),PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(3,Player(6),PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(3,Player(7),PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(3,Player(8),PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(3,Player(9),PLAYER_STATE_RESOURCE_GOLD)
endfunction

function Trig_Cash_2_Actions takes nothing returns nothing
	call AdjustPlayerStateBJ(12,Player(0),PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(12,Player(1),PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(12,Player(2),PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(12,Player(3),PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(12,Player(4),PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(12,Player(5),PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(12,Player(6),PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(12,Player(7),PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(12,Player(8),PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(12,Player(9),PLAYER_STATE_RESOURCE_GOLD)
endfunction

function Trig_Cash_3_Actions takes nothing returns nothing
	call AdjustPlayerStateBJ(6,Player(0),PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(6,Player(1),PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(6,Player(2),PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(6,Player(3),PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(6,Player(4),PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(6,Player(5),PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(6,Player(6),PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(6,Player(7),PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(6,Player(8),PLAYER_STATE_RESOURCE_GOLD)
	call AdjustPlayerStateBJ(6,Player(9),PLAYER_STATE_RESOURCE_GOLD)
endfunction

function Trig_Bounty_Actions takes nothing returns nothing
	call SetPlayerFlagBJ(PLAYER_STATE_GIVES_BOUNTY,true,Player(0))
	call SetPlayerFlagBJ(PLAYER_STATE_GIVES_BOUNTY,true,Player(1))
	call SetPlayerFlagBJ(PLAYER_STATE_GIVES_BOUNTY,true,Player(2))
	call SetPlayerFlagBJ(PLAYER_STATE_GIVES_BOUNTY,true,Player(3))
	call SetPlayerFlagBJ(PLAYER_STATE_GIVES_BOUNTY,true,Player(4))
	call SetPlayerFlagBJ(PLAYER_STATE_GIVES_BOUNTY,true,Player(5))
	call SetPlayerFlagBJ(PLAYER_STATE_GIVES_BOUNTY,true,Player(6))
	call SetPlayerFlagBJ(PLAYER_STATE_GIVES_BOUNTY,true,Player(7))
	call SetPlayerFlagBJ(PLAYER_STATE_GIVES_BOUNTY,true,Player(8))
	call SetPlayerFlagBJ(PLAYER_STATE_GIVES_BOUNTY,true,Player(9))
	call SetPlayerFlagBJ(PLAYER_STATE_GIVES_BOUNTY,true,Player(10))
	call SetPlayerFlagBJ(PLAYER_STATE_GIVES_BOUNTY,true,Player(11))
endfunction



function Trig_Kill_Actions takes nothing returns nothing
	call SetHeroLevelBJ(GetLevelingUnit(),350,true)
endfunction

// MIGRADO A Sistema_Victoria.j — Victoria/Derrota ahora incluye
// resumen de partida, MVP/LVP y protección contra encuestas espurias.
function Trig_Lose_for_humans_Actions takes nothing returns nothing
	return
	call CustomDefeatBJ(Player(0),"Caíste, fallaste y perdiste")
	call CustomDefeatBJ(Player(1),"Hoy solo serviste de vergüenza")
	call CustomDefeatBJ(Player(2),"No queda nada: has perdido.")
	call CustomDefeatBJ(Player(3),"Tu castillo ha sido reducido a ruinas.")
	call CustomDefeatBJ(Player(4),"Hoy no sumaste nada.")
	call CustomVictoryBJ(Player(5),true,true)
	call CustomVictoryBJ(Player(6),true,true)
	call CustomVictoryBJ(Player(7),true,true)
	call CustomVictoryBJ(Player(8),true,true)
	call CustomVictoryBJ(Player(9),true,true)
	call CustomDefeatBJ(Player(10),"TRIGSTR_8849")
	call CustomVictoryBJ(Player(11),true,true)
	call DestroyTrigger(GetTriggeringTrigger())
endfunction

// MIGRADO A Sistema_Victoria.j
function Trig_Lose_for_Orcs_Actions takes nothing returns nothing
	return
	call CustomVictoryBJ(Player(0),true,true)
	call CustomVictoryBJ(Player(1),true,true)
	call CustomVictoryBJ(Player(2),true,true)
	call CustomVictoryBJ(Player(3),true,true)
	call CustomVictoryBJ(Player(4),true,true)
	call CustomVictoryBJ(Player(10),true,true)
	call CustomDefeatBJ(Player(5),"Caíste, fallaste y perdiste")
	call CustomDefeatBJ(Player(6),"Has pasado a la historia como una vergüenza.")
	call CustomDefeatBJ(Player(7),"No hubo remontada. Solo derrota.")
	call CustomDefeatBJ(Player(8),"Perdiste, no estuviste a la altura.")
	call CustomDefeatBJ(Player(9),"Viniste a jugar, te vas humillado")
	call CustomDefeatBJ(Player(11),"TRIGSTR_8855")
	call DestroyTrigger(GetTriggeringTrigger())
endfunction



function Trig_Wand_of_Negation_Combination_Conditions takes nothing returns boolean
	if(not(GetItemTypeId(GetManipulatedItem())=='wneg'))then
		return false
	endif
	return true
endfunction

function Trig_Wand_of_Negation_Combination_Func001003001 takes nothing returns boolean
	return(GetItemTypeId(UnitItemInSlotBJ(GetManipulatingUnit(),GetForLoopIndexA()))=='wneg')
endfunction

function Trig_Wand_of_Negation_Combination_Func002C takes nothing returns boolean
	if(not(udg_integer46==2))then
		return false
	endif
	return true
endfunction

function Trig_Wand_of_Negation_Combination_Actions takes nothing returns nothing
	set bj_forLoopAIndex=1
	set bj_forLoopAIndexEnd=6
	loop
		exitwhen bj_forLoopAIndex>bj_forLoopAIndexEnd
		if(Trig_Wand_of_Negation_Combination_Func001003001())then
			set udg_integer46=(udg_integer46+1)
		else
			call DoNothing()
		endif
		set bj_forLoopAIndex=bj_forLoopAIndex+1
	endloop
	if(Trig_Wand_of_Negation_Combination_Func002C())then
		call UnitRemoveItemSwapped(GetItemOfTypeFromUnitBJ(GetManipulatingUnit(),'wneg'),GetManipulatingUnit())
		call RemoveItem(GetLastRemovedItem())
		call UnitRemoveItemSwapped(GetItemOfTypeFromUnitBJ(GetManipulatingUnit(),'wneg'),GetManipulatingUnit())
		call RemoveItem(GetLastRemovedItem())
		call UnitAddItemByIdSwapped('I012',GetManipulatingUnit())
	else
		set udg_integer46=0
	endif
endfunction

function Trig_Finger_of_Harm_Upgrade_1_Conditions takes nothing returns boolean
	if(not(GetItemTypeId(GetManipulatedItem())=='I006'))then
		return false
	endif
	return true
endfunction

function Trig_Finger_of_Harm_Upgrade_1_Func001003001 takes nothing returns boolean
	return(GetItemTypeId(UnitItemInSlotBJ(GetManipulatingUnit(),GetForLoopIndexA()))=='I006')
endfunction

function Trig_Finger_of_Harm_Upgrade_1_Func002C takes nothing returns boolean
	if(not(udg_integer46==2))then
		return false
	endif
	return true
endfunction

function Trig_Finger_of_Harm_Upgrade_1_Actions takes nothing returns nothing
	set bj_forLoopAIndex=1
	set bj_forLoopAIndexEnd=6
	loop
		exitwhen bj_forLoopAIndex>bj_forLoopAIndexEnd
		if(Trig_Finger_of_Harm_Upgrade_1_Func001003001())then
			set udg_integer46=(udg_integer46+1)
		else
			call DoNothing()
		endif
		set bj_forLoopAIndex=bj_forLoopAIndex+1
	endloop
	if(Trig_Finger_of_Harm_Upgrade_1_Func002C())then
		call UnitRemoveItemSwapped(GetItemOfTypeFromUnitBJ(GetManipulatingUnit(),'I006'),GetManipulatingUnit())
		call RemoveItem(GetLastRemovedItem())
		call UnitRemoveItemSwapped(GetItemOfTypeFromUnitBJ(GetManipulatingUnit(),'I006'),GetManipulatingUnit())
		call RemoveItem(GetLastRemovedItem())
		call UnitAddItemByIdSwapped('I013',GetManipulatingUnit())
	else
		set udg_integer46=0
	endif
endfunction

function main2 takes nothing returns nothing
	local weathereffect we
	call SetCameraBounds(-6656.0+GetCameraMargin(CAMERA_MARGIN_LEFT),-3584.0+GetCameraMargin(CAMERA_MARGIN_BOTTOM),6656.0-GetCameraMargin(CAMERA_MARGIN_RIGHT),3072.0-GetCameraMargin(CAMERA_MARGIN_TOP),-6656.0+GetCameraMargin(CAMERA_MARGIN_LEFT),3072.0-GetCameraMargin(CAMERA_MARGIN_TOP),6656.0-GetCameraMargin(CAMERA_MARGIN_RIGHT),-3584.0+GetCameraMargin(CAMERA_MARGIN_BOTTOM))
	call SetDayNightModels("Environment\\DNC\\DNCAshenvale\\DNCAshenvaleTerrain\\DNCAshenvaleTerrain.mdl","Environment\\DNC\\DNCAshenvale\\DNCAshenvaleUnit\\DNCAshenvaleUnit.mdl")
	// Niebla de terreno controlada desde Escenario > Opciones del mapa.
	// call SetTerrainFogEx(0,1900.0,2900.0,0.500,0.502,0.502,0.502)
	call SetWaterBaseColor(255,0,0,255)
	set we=AddWeatherEffect(Rect(-8192.0,-4096.0,8192.0,4096.0),'RAhr')
	call EnableWeatherEffect(we,true)
	call NewSoundEnvironment("Default")
	call SetAmbientDaySound("NorthrendDay")
	call SetAmbientNightSound("NorthrendNight")
	call SetMapMusic("Music",true,0)
	set udg_sound01=CreateSound("war3mapImported\\firstblood.mp3",false,false,false,10,10,"")
	call SetSoundDuration(udg_sound01,1567)
	call SetSoundChannel(udg_sound01,0)
	call SetSoundVolume(udg_sound01,127)
	call SetSoundPitch(udg_sound01,1.0)
	set udg_sound02=CreateSound("war3mapImported\\II drexcelent.mp3",false,false,false,10,10,"")
	call SetSoundDuration(udg_sound02,914)
	call SetSoundChannel(udg_sound02,0)
	call SetSoundVolume(udg_sound02,127)
	call SetSoundPitch(udg_sound02,1.0)
	set udg_sound03=CreateSound("Sound\\Interface\\CreepAggroWhat1.wav",false,false,false,10,10,"")
	call SetSoundParamsFromLabel(udg_sound03,"CreepAggro")
	call SetSoundDuration(udg_sound03,1236)
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
	call TriggerRegisterPlayerChatEvent(udg_trigger01,Player(5),"-Elsin do everything",true)
	call TriggerAddAction(udg_trigger01,function Trig_Elsin_Actions)
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
	call TriggerAddAction(udg_trigger03,function Trig_Inicialization_Actions)
	set udg_trigger04=CreateTrigger()
	call TriggerRegisterTimerEventSingle(udg_trigger04,0.75)
	// call TriggerAddAction(udg_trigger04,function Trig_Menu1_______3_DE_ORO_y_6_DE_ORO_Actions)
	set udg_trigger05=CreateTrigger()
	call TriggerRegisterDialogEventBJ(udg_trigger05,udg_dialogs01[1])
	call TriggerAddCondition(udg_trigger05,Condition(function Trig_Acciones_Menu1_3_DE_ORO_Conditions))
	call TriggerAddAction(udg_trigger05,function Trig_Acciones_Menu1_3_DE_ORO_Actions)
	set udg_trigger06=CreateTrigger()
	call TriggerRegisterDialogEventBJ(udg_trigger06,udg_dialogs01[1])
	call TriggerAddCondition(udg_trigger06,Condition(function Trig_Acciones_Menu1_6_DE_ORO_Conditions))
	call TriggerAddAction(udg_trigger06,function Trig_Acciones_Menu1_6_DE_ORO_Actions)
	set udg_trigger07=CreateTrigger()
	call TriggerRegisterDialogEventBJ(udg_trigger07,udg_dialogs01[1])
	// call TriggerAddAction(udg_trigger07,function Trig_Menu2_______SM_y_USM_Actions)
	set udg_trigger08=CreateTrigger()
	call TriggerRegisterDialogEventBJ(udg_trigger08,udg_dialogs02[1])
	call TriggerAddCondition(udg_trigger08,Condition(function Trig_Acciones_Menu2_SM_Conditions))
	call TriggerAddAction(udg_trigger08,function Trig_Acciones_Menu2_SM_Actions)
	set udg_trigger09=CreateTrigger()
	call TriggerRegisterDialogEventBJ(udg_trigger09,udg_dialogs02[1])
	call TriggerAddCondition(udg_trigger09,Condition(function Trig_Acciones_Menu2_USM_Conditions))
	call TriggerAddAction(udg_trigger09,function Trig_Acciones_Menu2_USM_Actions)
	set udg_trigger10=CreateTrigger()
	call TriggerRegisterDialogEventBJ(udg_trigger10,udg_dialogs02[1])
	// call TriggerAddAction(udg_trigger10,function Trig_Menu3_______Game_Modes_Actions)
	set udg_trigger11=CreateTrigger()
	call TriggerRegisterDialogEventBJ(udg_trigger11,udg_dialogs03[1])
	call TriggerAddCondition(udg_trigger11,Condition(function Trig_Acciones_Menu3_ALLPICK_Conditions))
	call TriggerAddAction(udg_trigger11,function Trig_Acciones_Menu3_ALLPICK_Actions)
	set udg_trigger12=CreateTrigger()
	call TriggerRegisterDialogEventBJ(udg_trigger12,udg_dialogs03[1])
	call TriggerAddCondition(udg_trigger12,Condition(function Trig_Acciones_Menu3_ALLRADOM_Conditions))
	call TriggerAddAction(udg_trigger12,function Trig_Acciones_Menu3_ALLRADOM_Actions)
	set udg_trigger13=CreateTrigger()
	call TriggerRegisterDialogEventBJ(udg_trigger13,udg_dialogs03[1])
	call TriggerAddCondition(udg_trigger13,Condition(function Trig_Acciones_Menu3_MODO_CLASICO_Conditions))
	call TriggerAddAction(udg_trigger13,function Trig_Acciones_Menu3_MODO_CLASICO_Actions)
	set udg_trigger14=CreateTrigger()
	call TriggerRegisterEnterRectSimple(udg_trigger14,udg_rect19)
	call TriggerAddCondition(udg_trigger14,Condition(function Trig_Attack_1_Barracas_1_Conditions))
	call TriggerAddAction(udg_trigger14,function Trig_Attack_1_Barracas_1_Actions)
	set udg_trigger15=CreateTrigger()
	call TriggerRegisterEnterRectSimple(udg_trigger15,udg_rect20)
	call TriggerAddCondition(udg_trigger15,Condition(function Trig_Attack_1_Blacksmith_1_Conditions))
	call TriggerAddAction(udg_trigger15,function Trig_Attack_1_Blacksmith_1_Actions)
	set udg_trigger16=CreateTrigger()
	call TriggerRegisterEnterRectSimple(udg_trigger16,udg_rect21)
	call TriggerAddCondition(udg_trigger16,Condition(function Trig_Attack_1_Barracas_2_Conditions))
	call TriggerAddAction(udg_trigger16,function Trig_Attack_1_Barracas_2_Actions)
	set udg_trigger17=CreateTrigger()
	call TriggerRegisterEnterRectSimple(udg_trigger17,udg_rect22)
	call TriggerAddCondition(udg_trigger17,Condition(function Trig_Attack_1_Blacsmith_2_Conditions))
	call TriggerAddAction(udg_trigger17,function Trig_Attack_1_Blacsmith_2_Actions)
	set udg_trigger18=CreateTrigger()
	call TriggerRegisterEnterRectSimple(udg_trigger18,udg_rect29)
	call TriggerAddCondition(udg_trigger18,Condition(function Trig_Attack_1_orc_Barracas_2_Conditions))
	call TriggerAddAction(udg_trigger18,function Trig_Attack_1_orc_Barracas_2_Actions)
	set udg_trigger19=CreateTrigger()
	call TriggerRegisterEnterRectSimple(udg_trigger19,udg_rect30)
	call TriggerAddCondition(udg_trigger19,Condition(function Trig_Attack_1_orc_Tauren_2_Conditions))
	call TriggerAddAction(udg_trigger19,function Trig_Attack_1_orc_Tauren_2_Actions)
	set udg_trigger20=CreateTrigger()
	call TriggerRegisterEnterRectSimple(udg_trigger20,udg_rect31)
	call TriggerAddCondition(udg_trigger20,Condition(function Trig_Attack_1_orc_Tauren_1_Conditions))
	call TriggerAddAction(udg_trigger20,function Trig_Attack_1_orc_Tauren_1_Actions)
	set udg_trigger21=CreateTrigger()
	call TriggerRegisterEnterRectSimple(udg_trigger21,udg_rect32)
	call TriggerAddCondition(udg_trigger21,Condition(function Trig_Attack_1_orc_Barracas_1_Conditions))
	call TriggerAddAction(udg_trigger21,function Trig_Attack_1_orc_Barracas_1_Actions)
	// DESACTIVADO: First Blood legacy — MIGRADO a Sistema_Kills.j
	//set udg_trigger22=CreateTrigger()
	//call TriggerRegisterAnyUnitEventBJ(udg_trigger22,EVENT_PLAYER_UNIT_DEATH)
	//call TriggerAddCondition(udg_trigger22,Condition(function Trig_First_Blood_Conditions))
	//call TriggerAddAction(udg_trigger22,function Trig_First_Blood_Actions)
	//set udg_trigger23=CreateTrigger()
	//call TriggerRegisterAnyUnitEventBJ(udg_trigger23,EVENT_PLAYER_UNIT_DEATH)
	//call TriggerAddCondition(udg_trigger23,Condition(function Trig_Hero_Kill_Conditions))
	//call TriggerAddAction(udg_trigger23,function Trig_Hero_Kill_Actions)
	set udg_trigger24=CreateTrigger()
	call TriggerRegisterTimerEventSingle(udg_trigger24,90.00)
	call TriggerAddAction(udg_trigger24,function Trig_Tips_Actions)
	set udg_trigger25=CreateTrigger()
	call TriggerRegisterAnyUnitEventBJ(udg_trigger25,EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger25,Condition(function Trig_AllianceMusic_Conditions))
	call TriggerAddAction(udg_trigger25,function Trig_AllianceMusic_Actions)
	set udg_trigger26=CreateTrigger()
	call TriggerRegisterAnyUnitEventBJ(udg_trigger26,EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger26,Condition(function Trig_HordeMusic_Conditions))
	call TriggerAddAction(udg_trigger26,function Trig_HordeMusic_Actions)
	set udg_trigger27=CreateTrigger()
	call TriggerRegisterDialogEventBJ(udg_trigger27,udg_dialogs02[1])
	call TriggerAddCondition(udg_trigger27,Condition(function Trig_Command_Short_Mode_Conditions))
	call TriggerAddAction(udg_trigger27,function Trig_Command_Short_Mode_Actions)
	set udg_trigger28=CreateTrigger()
	call TriggerRegisterDialogEventBJ(udg_trigger28,udg_dialogs02[1])
	call TriggerAddCondition(udg_trigger28,Condition(function Trig_Command_Ultra_Short_Mode_Conditions))
	call TriggerAddAction(udg_trigger28,function Trig_Command_Ultra_Short_Mode_Actions)
	set udg_trigger29=CreateTrigger()
	call TriggerRegisterDialogEventBJ(udg_trigger29,udg_dialogs03[1])
	call TriggerAddAction(udg_trigger29,function Trig_Create_Multiboard_Actions)
	set udg_trigger30=CreateTrigger()
	call TriggerRegisterAnyUnitEventBJ(udg_trigger30,EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger30,Condition(function Trig_Player_Kills_Upd_Conditions))
	call TriggerAddAction(udg_trigger30,function Trig_Player_Kills_Upd_Actions)
	set udg_trigger31=CreateTrigger()
	call TriggerRegisterAnyUnitEventBJ(udg_trigger31,EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger31,Condition(function Trig_Player_Hero_Death_Conditions))
	call TriggerAddAction(udg_trigger31,function Trig_Player_Hero_Death_Actions)
	set udg_trigger32=CreateTrigger()
	call TriggerRegisterPlayerEventLeave(udg_trigger32,Player(0))
	call TriggerRegisterPlayerEventLeave(udg_trigger32,Player(1))
	call TriggerRegisterPlayerEventLeave(udg_trigger32,Player(2))
	call TriggerRegisterPlayerEventLeave(udg_trigger32,Player(3))
	call TriggerRegisterPlayerEventLeave(udg_trigger32,Player(4))
	call TriggerRegisterPlayerEventLeave(udg_trigger32,Player(5))
	call TriggerRegisterPlayerEventLeave(udg_trigger32,Player(6))
	call TriggerRegisterPlayerEventLeave(udg_trigger32,Player(7))
	call TriggerRegisterPlayerEventLeave(udg_trigger32,Player(8))
	call TriggerRegisterPlayerEventLeave(udg_trigger32,Player(9))
	//call TriggerAddAction(udg_trigger32,function Trig_Player_leaves_Actions)
	set udg_trigger33=CreateTrigger()
	call TriggerAddAction(udg_trigger33,function Trig_Player_Colors_Actions)
	set udg_trigger34=CreateTrigger()
	call TriggerAddAction(udg_trigger34,function Trig_Setup_Players_Actions)
	set udg_trigger35=CreateTrigger()
	call TriggerAddAction(udg_trigger35,function Trig_Heros_array_Actions)
	set udg_trigger36=CreateTrigger()
	call TriggerRegisterDialogEventBJ(udg_trigger36,udg_dialogs03[1])
	call TriggerAddCondition(udg_trigger36,Condition(function Trig_Team_Random_Command_Conditions))
	call TriggerAddAction(udg_trigger36,function Trig_Team_Random_Command_Actions)
	set udg_trigger37=CreateTrigger()
	call TriggerRegisterDialogEventBJ(udg_trigger37,udg_dialogs03[1])
	call TriggerAddCondition(udg_trigger37,Condition(function Trig_AllPick_Conditions))
	call TriggerAddAction(udg_trigger37,function Trig_AllPick_Actions)
	set udg_trigger38=CreateTrigger()
	call TriggerRegisterDialogEventBJ(udg_trigger38,udg_dialogs03[1])
	call TriggerAddCondition(udg_trigger38,Condition(function Trig_Clear_Wisps_y_Almas_Corruptas_allrandom_Conditions))
	call TriggerAddAction(udg_trigger38,function Trig_Clear_Wisps_y_Almas_Corruptas_allrandom_Actions)
	set udg_trigger39=CreateTrigger()
	call TriggerRegisterEnterRectSimple(udg_trigger39,GetPlayableMapRect())
	call TriggerAddAction(udg_trigger39,function Trig_Camara_allpick_Actions)
	set udg_trigger40=CreateTrigger()
	call DisableTrigger(udg_trigger40)
	call TriggerRegisterEnterRectSimple(udg_trigger40,GetPlayableMapRect())
	call TriggerAddCondition(udg_trigger40,Condition(function Trig_Camara_Conditions))
	call TriggerAddAction(udg_trigger40,function Trig_Camara_Actions)
	//set udg_trigger41=CreateTrigger()
	//call TriggerRegisterTimerEventSingle(udg_trigger41,5.00)
	//call TriggerAddAction(udg_trigger41,function Trig_Vulnerability_Actions)
	//set udg_trigger42=CreateTrigger()
	//call TriggerRegisterAnyUnitEventBJ(udg_trigger42,EVENT_PLAYER_UNIT_DEATH)
	//call TriggerAddCondition(udg_trigger42,Condition(function Trig_Alliance_Base_Conditions))
	//call TriggerAddAction(udg_trigger42,function Trig_Alliance_Base_Actions)
	//set udg_trigger43=CreateTrigger()
	//call TriggerRegisterAnyUnitEventBJ(udg_trigger43,EVENT_PLAYER_UNIT_DEATH)
	//call TriggerAddCondition(udg_trigger43,Condition(function Trig_Orc_Base_Conditions))
	//call TriggerAddAction(udg_trigger43,function Trig_Orc_Base_Actions)
	set udg_trigger44=CreateTrigger()
	call TriggerRegisterTimerEventPeriodic(udg_trigger44,30.00)
	call TriggerAddCondition(udg_trigger44,Condition(function Trig_Human_Footmen_Conditions))
	call TriggerAddAction(udg_trigger44,function Trig_Human_Footmen_Actions)
	set udg_trigger45=CreateTrigger()
	call TriggerRegisterTimerEventPeriodic(udg_trigger45,30.00)
	call TriggerAddCondition(udg_trigger45,Condition(function Trig_Human_Riflemen_Conditions))
	call TriggerAddAction(udg_trigger45,function Trig_Human_Riflemen_Actions)
	set udg_trigger46=CreateTrigger()
	call TriggerRegisterTimerEventPeriodic(udg_trigger46,30.00)
	call TriggerAddCondition(udg_trigger46,Condition(function Trig_Human_Mountan_Giant_Conditions))
	call TriggerAddAction(udg_trigger46,function Trig_Human_Mountan_Giant_Actions)
	set udg_trigger47=CreateTrigger()
	call TriggerRegisterTimerEventPeriodic(udg_trigger47,30.00)
	call TriggerAddCondition(udg_trigger47,Condition(function Trig_Human_Huntress_Conditions))
	call TriggerAddAction(udg_trigger47,function Trig_Human_Huntress_Actions)
	set udg_trigger48=CreateTrigger()
	call TriggerRegisterTimerEventPeriodic(udg_trigger48,30.00)
	call TriggerAddCondition(udg_trigger48,Condition(function Trig_Human_Archer_Conditions))
	call TriggerAddAction(udg_trigger48,function Trig_Human_Archer_Actions)
	set udg_trigger49=CreateTrigger()
	call TriggerRegisterTimerEventPeriodic(udg_trigger49,30.00)
	call TriggerAddCondition(udg_trigger49,Condition(function Trig_Human_Mountain_Giant_Conditions))
	call TriggerAddAction(udg_trigger49,function Trig_Human_Mountain_Giant_Actions)
	set udg_trigger50=CreateTrigger()
	call TriggerRegisterTimerEventPeriodic(udg_trigger50,30.00)
	call TriggerAddCondition(udg_trigger50,Condition(function Trig_Orcs_Ghoul_Conditions))
	call TriggerAddAction(udg_trigger50,function Trig_Orcs_Ghoul_Actions)
	set udg_trigger51=CreateTrigger()
	call TriggerRegisterTimerEventPeriodic(udg_trigger51,30.00)
	call TriggerAddCondition(udg_trigger51,Condition(function Trig_Orcs_Necremancer_Conditions))
	call TriggerAddAction(udg_trigger51,function Trig_Orcs_Necremancer_Actions)
	set udg_trigger52=CreateTrigger()
	call TriggerRegisterTimerEventPeriodic(udg_trigger52,30.00)
	call TriggerAddCondition(udg_trigger52,Condition(function Trig_Orcs_Tauren_Conditions))
	call TriggerAddAction(udg_trigger52,function Trig_Orcs_Tauren_Actions)
	set udg_trigger53=CreateTrigger()
	call TriggerRegisterTimerEventPeriodic(udg_trigger53,30.00)
	call TriggerAddCondition(udg_trigger53,Condition(function Trig_Orcs_Tauren_de_abajo_Conditions))
	call TriggerAddAction(udg_trigger53,function Trig_Orcs_Tauren_de_abajo_Actions)
	set udg_trigger54=CreateTrigger()
	call TriggerRegisterTimerEventPeriodic(udg_trigger54,30.00)
	call TriggerAddCondition(udg_trigger54,Condition(function Trig_Orcs_Grunts_Conditions))
	call TriggerAddAction(udg_trigger54,function Trig_Orcs_Grunts_Actions)
	set udg_trigger55=CreateTrigger()
	call TriggerRegisterTimerEventPeriodic(udg_trigger55,30.00)
	call TriggerAddCondition(udg_trigger55,Condition(function Trig_Orcs_Shamans_Conditions))
	call TriggerAddAction(udg_trigger55,function Trig_Orcs_Shamans_Actions)
	if false then
		set udg_trigger56=CreateTrigger()
		call TriggerRegisterEnterRectSimple(udg_trigger56,udg_rect45)
		call TriggerAddCondition(udg_trigger56,Condition(function Trig_Magnadefender_Conditions))
		call TriggerAddAction(udg_trigger56,function Trig_Magnadefender_Actions)
		set udg_trigger57=CreateTrigger()
		call TriggerRegisterEnterRectSimple(udg_trigger57,udg_rect46)
		call TriggerAddCondition(udg_trigger57,Condition(function Trig_Magic_Gladiator_Conditions))
		call TriggerAddAction(udg_trigger57,function Trig_Magic_Gladiator_Actions)
		set udg_trigger58=CreateTrigger()
		call TriggerRegisterEnterRectSimple(udg_trigger58,udg_rect09)
		call TriggerAddCondition(udg_trigger58,Condition(function Trig_Demon_Hunter_Conditions))
		call TriggerAddAction(udg_trigger58,function Trig_Demon_Hunter_Actions)
		set udg_trigger59=CreateTrigger()
		call TriggerRegisterEnterRectSimple(udg_trigger59,udg_rect35)
		call TriggerAddCondition(udg_trigger59,Condition(function Trig_Priestess_of_the_Moon_Conditions))
		call TriggerAddAction(udg_trigger59,function Trig_Priestess_of_the_Moon_Actions)
		set udg_trigger60=CreateTrigger()
		call TriggerRegisterEnterRectSimple(udg_trigger60,udg_rect42)
		call TriggerAddCondition(udg_trigger60,Condition(function Trig_Warden_Conditions))
		call TriggerAddAction(udg_trigger60,function Trig_Warden_Actions)
		set udg_trigger61=CreateTrigger()
		call TriggerRegisterEnterRectSimple(udg_trigger61,udg_rect06)
		call TriggerAddCondition(udg_trigger61,Condition(function Trig_Keeper_of_the_Groove_Conditions))
		call TriggerAddAction(udg_trigger61,function Trig_Keeper_of_the_Groove_Actions)
		set udg_trigger62=CreateTrigger()
		call TriggerRegisterEnterRectSimple(udg_trigger62,udg_rect03)
		call TriggerAddCondition(udg_trigger62,Condition(function Trig_Asesina_Conditions))
		call TriggerAddAction(udg_trigger62,function Trig_Asesina_Actions)
		set udg_trigger63=CreateTrigger()
		call TriggerRegisterEnterRectSimple(udg_trigger63,udg_rect34)
		call TriggerAddCondition(udg_trigger63,Condition(function Trig_Paladin_Conditions))
		call TriggerAddAction(udg_trigger63,function Trig_Paladin_Actions)
		set udg_trigger64=CreateTrigger()
		call TriggerRegisterEnterRectSimple(udg_trigger64,udg_rect02)
		call TriggerAddCondition(udg_trigger64,Condition(function Trig_Archmage_Conditions))
		call TriggerAddAction(udg_trigger64,function Trig_Archmage_Actions)
		set udg_trigger65=CreateTrigger()
		call TriggerRegisterEnterRectSimple(udg_trigger65,udg_rect26)
		call TriggerAddCondition(udg_trigger65,Condition(function Trig_Mountain_King_Conditions))
		call TriggerAddAction(udg_trigger65,function Trig_Mountain_King_Actions)
		set udg_trigger66=CreateTrigger()
		call TriggerRegisterEnterRectSimple(udg_trigger66,udg_rect05)
		call TriggerAddCondition(udg_trigger66,Condition(function Trig_Blood_Mage_Conditions))
		call TriggerAddAction(udg_trigger66,function Trig_Blood_Mage_Actions)
		set udg_trigger67=CreateTrigger()
		call TriggerRegisterEnterRectSimple(udg_trigger67,udg_rect17)
		call TriggerAddCondition(udg_trigger67,Condition(function Trig_Lord_Gharitos_Conditions))
		call TriggerAddAction(udg_trigger67,function Trig_Lord_Gharitos_Actions)
		set udg_trigger68=CreateTrigger()
		call TriggerRegisterEnterRectSimple(udg_trigger68,udg_rect01)
		call TriggerAddCondition(udg_trigger68,Condition(function Trig_Ranger_Conditions))
		call TriggerAddAction(udg_trigger68,function Trig_Ranger_Actions)
		set udg_trigger69=CreateTrigger()
		call TriggerRegisterEnterRectSimple(udg_trigger69,udg_rect04)
		call TriggerAddCondition(udg_trigger69,Condition(function Trig_Blademaster_Conditions))
		call TriggerAddAction(udg_trigger69,function Trig_Blademaster_Actions)
		set udg_trigger70=CreateTrigger()
		call TriggerRegisterEnterRectSimple(udg_trigger70,udg_rect11)
		call TriggerAddCondition(udg_trigger70,Condition(function Trig_Far_Seer_Conditions))
		call TriggerAddAction(udg_trigger70,function Trig_Far_Seer_Actions)
		set udg_trigger71=CreateTrigger()
		call TriggerRegisterEnterRectSimple(udg_trigger71,udg_rect41)
		call TriggerAddCondition(udg_trigger71,Condition(function Trig_Tauren_Chieftain_Conditions))
		call TriggerAddAction(udg_trigger71,function Trig_Tauren_Chieftain_Actions)
		set udg_trigger72=CreateTrigger()
		call TriggerRegisterEnterRectSimple(udg_trigger72,udg_rect40)
		call TriggerAddCondition(udg_trigger72,Condition(function Trig_Shadow_Hunter_Conditions))
		call TriggerAddAction(udg_trigger72,function Trig_Shadow_Hunter_Actions)
		set udg_trigger73=CreateTrigger()
		call TriggerRegisterEnterRectSimple(udg_trigger73,udg_rect24)
		call TriggerAddCondition(udg_trigger73,Condition(function Trig_Warsong_Chieftain_Conditions))
		call TriggerAddAction(udg_trigger73,function Trig_Warsong_Chieftain_Actions)
		set udg_trigger74=CreateTrigger()
		call TriggerRegisterEnterRectSimple(udg_trigger74,udg_rect07)
		call TriggerAddCondition(udg_trigger74,Condition(function Trig_Crypt_Lord_Conditions))
		call TriggerAddAction(udg_trigger74,function Trig_Crypt_Lord_Actions)
		set udg_trigger75=CreateTrigger()
		call TriggerRegisterEnterRectSimple(udg_trigger75,udg_rect08)
		call TriggerAddCondition(udg_trigger75,Condition(function Trig_Death_Knight_Conditions))
		call TriggerAddAction(udg_trigger75,function Trig_Death_Knight_Actions)
		set udg_trigger76=CreateTrigger()
		call TriggerRegisterEnterRectSimple(udg_trigger76,udg_rect10)
		call TriggerAddCondition(udg_trigger76,Condition(function Trig_Dreadlord_Conditions))
		call TriggerAddAction(udg_trigger76,function Trig_Dreadlord_Actions)
		set udg_trigger77=CreateTrigger()
		call TriggerRegisterEnterRectSimple(udg_trigger77,udg_rect25)
		call TriggerAddCondition(udg_trigger77,Condition(function Trig_Lich_Conditions))
		call TriggerAddAction(udg_trigger77,function Trig_Lich_Actions)
		set udg_trigger78=CreateTrigger()
		call TriggerRegisterEnterRectSimple(udg_trigger78,udg_rect27)
		call TriggerAddCondition(udg_trigger78,Condition(function Trig_Nigromante_Conditions))
		call TriggerAddAction(udg_trigger78,function Trig_Nigromante_Actions)
		set udg_trigger79=CreateTrigger()
		call TriggerRegisterEnterRectSimple(udg_trigger79,udg_rect14)
		call TriggerAddCondition(udg_trigger79,Condition(function Trig_Firelord_Conditions))
		call TriggerAddAction(udg_trigger79,function Trig_Firelord_Actions)
		set udg_trigger80=CreateTrigger()
		call TriggerRegisterEnterRectSimple(udg_trigger80,udg_rect43)
		call TriggerAddCondition(udg_trigger80,Condition(function Trig_Dark_Ranger_Conditions))
		call TriggerAddAction(udg_trigger80,function Trig_Dark_Ranger_Actions)
		set udg_trigger81=CreateTrigger()
		call TriggerRegisterEnterRectSimple(udg_trigger81,udg_rect44)
		call TriggerAddCondition(udg_trigger81,Condition(function Trig_Storm_Conditions))
		call TriggerAddAction(udg_trigger81,function Trig_Storm_Actions)
	endif
	set udg_trigger82=CreateTrigger()
	call TriggerRegisterPlayerUnitEventSimple(udg_trigger82,Player(0),EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger82,Condition(function Trig_Revive_Human_hero_player_1_Conditions))
	call TriggerAddAction(udg_trigger82,function Trig_Revive_Human_hero_player_1_Actions)
	set udg_trigger83=CreateTrigger()
	call TriggerRegisterPlayerUnitEventSimple(udg_trigger83,Player(1),EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger83,Condition(function Trig_Revive_Human_hero_player_2_Conditions))
	call TriggerAddAction(udg_trigger83,function Trig_Revive_Human_hero_player_2_Actions)
	set udg_trigger84=CreateTrigger()
	call TriggerRegisterPlayerUnitEventSimple(udg_trigger84,Player(2),EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger84,Condition(function Trig_Revive_Human_hero_player_3_Conditions))
	call TriggerAddAction(udg_trigger84,function Trig_Revive_Human_hero_player_3_Actions)
	set udg_trigger85=CreateTrigger()
	call TriggerRegisterPlayerUnitEventSimple(udg_trigger85,Player(3),EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger85,Condition(function Trig_Revive_Human_hero_player_4_Conditions))
	call TriggerAddAction(udg_trigger85,function Trig_Revive_Human_hero_player_4_Actions)
	set udg_trigger86=CreateTrigger()
	call TriggerRegisterPlayerUnitEventSimple(udg_trigger86,Player(4),EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger86,Condition(function Trig_Revive_Human_hero_player_5_Conditions))
	call TriggerAddAction(udg_trigger86,function Trig_Revive_Human_hero_player_5_Actions)
	set udg_trigger87=CreateTrigger()
	call TriggerRegisterPlayerUnitEventSimple(udg_trigger87,Player(5),EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger87,Condition(function Trig_Revive_Orc_hero_player_6_Conditions))
	call TriggerAddAction(udg_trigger87,function Trig_Revive_Orc_hero_player_6_Actions)
	set udg_trigger88=CreateTrigger()
	call TriggerRegisterPlayerUnitEventSimple(udg_trigger88,Player(6),EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger88,Condition(function Trig_Revive_Orc_hero_player_7_Conditions))
	call TriggerAddAction(udg_trigger88,function Trig_Revive_Orc_hero_player_7_Actions)
	set udg_trigger89=CreateTrigger()
	call TriggerRegisterPlayerUnitEventSimple(udg_trigger89,Player(7),EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger89,Condition(function Trig_Revive_Orc_hero_player_8_Conditions))
	call TriggerAddAction(udg_trigger89,function Trig_Revive_Orc_hero_player_8_Actions)
	set udg_trigger90=CreateTrigger()
	call TriggerRegisterPlayerUnitEventSimple(udg_trigger90,Player(8),EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger90,Condition(function Trig_Revive_Orc_hero_player_9_Conditions))
	call TriggerAddAction(udg_trigger90,function Trig_Revive_Orc_hero_player_9_Actions)
	set udg_trigger91=CreateTrigger()
	call TriggerRegisterPlayerUnitEventSimple(udg_trigger91,Player(9),EVENT_PLAYER_UNIT_DEATH)
	call TriggerAddCondition(udg_trigger91,Condition(function Trig_Revive_Orc_hero_player_10_Conditions))
	call TriggerAddAction(udg_trigger91,function Trig_Revive_Orc_hero_player_10_Actions)
	set udg_trigger92=CreateTrigger()
	call TriggerRegisterAnyUnitEventBJ(udg_trigger92,EVENT_PLAYER_UNIT_SPELL_CAST)
	call TriggerAddCondition(udg_trigger92,Condition(function Trig_Blademaster_Invul_Blade_Conditions))
	call TriggerAddAction(udg_trigger92,function Trig_Blademaster_Invul_Blade_Actions)
	set udg_trigger93=CreateTrigger()
	call TriggerAddAction(udg_trigger93,function Trig_Help_Actions)
	set udg_trigger94=CreateTrigger()
	call TriggerRegisterPlayerChatEvent(udg_trigger94,Player(0),"-ma",true)
	call TriggerRegisterPlayerChatEvent(udg_trigger94,Player(1),"-ma",true)
	call TriggerRegisterPlayerChatEvent(udg_trigger94,Player(2),"-ma",true)
	call TriggerRegisterPlayerChatEvent(udg_trigger94,Player(3),"-ma",true)
	call TriggerRegisterPlayerChatEvent(udg_trigger94,Player(4),"-ma",true)
	call TriggerRegisterPlayerChatEvent(udg_trigger94,Player(5),"-ma",true)
	call TriggerRegisterPlayerChatEvent(udg_trigger94,Player(6),"-ma",true)
	call TriggerRegisterPlayerChatEvent(udg_trigger94,Player(7),"-ma",true)
	call TriggerRegisterPlayerChatEvent(udg_trigger94,Player(8),"-ma",true)
	call TriggerRegisterPlayerChatEvent(udg_trigger94,Player(9),"-ma",true)
	call TriggerAddAction(udg_trigger94,function Trig_Matchup_Actions)
	set udg_trigger95=CreateTrigger()
	call TriggerRegisterPlayerChatEvent(udg_trigger95,Player(0),"-ms",true)
	call TriggerRegisterPlayerChatEvent(udg_trigger95,Player(1),"-ms",true)
	call TriggerRegisterPlayerChatEvent(udg_trigger95,Player(2),"-ms",true)
	call TriggerRegisterPlayerChatEvent(udg_trigger95,Player(3),"-ms",true)
	call TriggerRegisterPlayerChatEvent(udg_trigger95,Player(4),"-ms",true)
	call TriggerRegisterPlayerChatEvent(udg_trigger95,Player(5),"-ms",true)
	call TriggerRegisterPlayerChatEvent(udg_trigger95,Player(6),"-ms",true)
	call TriggerRegisterPlayerChatEvent(udg_trigger95,Player(7),"-ms",true)
	call TriggerRegisterPlayerChatEvent(udg_trigger95,Player(8),"-ms",true)
	call TriggerRegisterPlayerChatEvent(udg_trigger95,Player(9),"-ms",true)
	call TriggerAddAction(udg_trigger95,function Trig_Movespeed_Actions)
	set udg_trigger96=CreateTrigger()
	call TriggerRegisterPlayerEventLeave(udg_trigger96,Player(0))
	call TriggerRegisterPlayerEventDefeat(udg_trigger96,Player(0))
	call TriggerRegisterPlayerEventLeave(udg_trigger96,Player(1))
	call TriggerRegisterPlayerEventDefeat(udg_trigger96,Player(1))
	call TriggerRegisterPlayerEventLeave(udg_trigger96,Player(2))
	call TriggerRegisterPlayerEventDefeat(udg_trigger96,Player(2))
	call TriggerRegisterPlayerEventLeave(udg_trigger96,Player(3))
	call TriggerRegisterPlayerEventDefeat(udg_trigger96,Player(3))
	call TriggerRegisterPlayerEventLeave(udg_trigger96,Player(4))
	call TriggerRegisterPlayerEventDefeat(udg_trigger96,Player(4))
	//call TriggerAddAction(udg_trigger96,function Trig_Item_Drop_Humanos_Actions)
	set udg_trigger97=CreateTrigger()
	call TriggerRegisterPlayerEventLeave(udg_trigger97,Player(5))
	call TriggerRegisterPlayerEventDefeat(udg_trigger97,Player(5))
	call TriggerRegisterPlayerEventLeave(udg_trigger97,Player(6))
	call TriggerRegisterPlayerEventDefeat(udg_trigger97,Player(6))
	call TriggerRegisterPlayerEventLeave(udg_trigger97,Player(7))
	call TriggerRegisterPlayerEventDefeat(udg_trigger97,Player(7))
	call TriggerRegisterPlayerEventLeave(udg_trigger97,Player(8))
	call TriggerRegisterPlayerEventDefeat(udg_trigger97,Player(8))
	call TriggerRegisterPlayerEventLeave(udg_trigger97,Player(9))
	call TriggerRegisterPlayerEventDefeat(udg_trigger97,Player(9))
	//call TriggerAddAction(udg_trigger97,function Trig_Item_Drop_Orcos_Actions)
	set udg_trigger98=CreateTrigger()
	call DisableTrigger(udg_trigger98)
	call TriggerRegisterTimerEventPeriodic(udg_trigger98,1.00)
	call TriggerAddAction(udg_trigger98,function Trig_Cash_1_Actions)
	set udg_trigger99=CreateTrigger()
	call DisableTrigger(udg_trigger99)
	call TriggerRegisterTimerEventPeriodic(udg_trigger99,1.00)
	call TriggerAddAction(udg_trigger99,function Trig_Cash_2_Actions)
	set udg_trigger100=CreateTrigger()
	call DisableTrigger(udg_trigger100)
	call TriggerRegisterTimerEventPeriodic(udg_trigger100,1.00)
	call TriggerAddAction(udg_trigger100,function Trig_Cash_3_Actions)
	set udg_trigger101=CreateTrigger()
	call TriggerAddAction(udg_trigger101,function Trig_Bounty_Actions)

	set udg_trigger114=CreateTrigger()
	call TriggerAddAction(udg_trigger114,function Trig_Kill_Actions)
	set udg_trigger115=CreateTrigger()
	call TriggerRegisterUnitEvent(udg_trigger115,udg_unit19,EVENT_UNIT_DEATH)
	call TriggerAddAction(udg_trigger115,function Trig_Lose_for_humans_Actions)
	set udg_trigger116=CreateTrigger()
	call TriggerRegisterUnitEvent(udg_trigger116,udg_unit24,EVENT_UNIT_DEATH)
	call TriggerAddAction(udg_trigger116,function Trig_Lose_for_Orcs_Actions)

	// MIGRADO A Fusion_Varitas.j — wneg+wneg→I012 e I012+wneg→I01S (9 cargas)
	//set udg_trigger118=CreateTrigger()
	//call TriggerRegisterAnyUnitEventBJ(udg_trigger118,EVENT_PLAYER_UNIT_PICKUP_ITEM)
	//call TriggerAddCondition(udg_trigger118,Condition(function Trig_Wand_of_Negation_Combination_Conditions))
	//call TriggerAddAction(udg_trigger118,function Trig_Wand_of_Negation_Combination_Actions)
	set udg_trigger119=CreateTrigger()
	call TriggerRegisterAnyUnitEventBJ(udg_trigger119,EVENT_PLAYER_UNIT_PICKUP_ITEM)
	call TriggerAddCondition(udg_trigger119,Condition(function Trig_Finger_of_Harm_Upgrade_1_Conditions))
	call TriggerAddAction(udg_trigger119,function Trig_Finger_of_Harm_Upgrade_1_Actions)
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
	call SetCameraBounds(-6528.0+GetCameraMargin(CAMERA_MARGIN_LEFT),-3328.0+GetCameraMargin(CAMERA_MARGIN_BOTTOM),6528.0-GetCameraMargin(CAMERA_MARGIN_RIGHT),2816.0-GetCameraMargin(CAMERA_MARGIN_TOP),-6528.0+GetCameraMargin(CAMERA_MARGIN_LEFT),2816.0-GetCameraMargin(CAMERA_MARGIN_TOP),6528.0-GetCameraMargin(CAMERA_MARGIN_RIGHT),-3328.0+GetCameraMargin(CAMERA_MARGIN_BOTTOM))
	call SetDayNightModels("Environment\\DNC\\DNCAshenvale\\DNCAshenvaleTerrain\\DNCAshenvaleTerrain.mdl","Environment\\DNC\\DNCAshenvale\\DNCAshenvaleUnit\\DNCAshenvaleUnit.mdl")
	// Niebla de terreno controlada desde Escenario > Opciones del mapa.
	// call SetTerrainFogEx(0,1900.0,2900.0,0.500,0.502,0.502,0.502)
	call SetWaterBaseColor(255,0,0,255)
	set we=AddWeatherEffect(Rect(-8192.0,-4096.0,8192.0,4096.0),'RAhr')
	call EnableWeatherEffect(we,true)
	call NewSoundEnvironment("Default")
	call SetAmbientDaySound("NorthrendDay")
	call SetAmbientNightSound("NorthrendNight")
	call SetMapMusic("Music",true,0)
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

