// ------------------------------------------------------------
// A 12-gauge pump for protection
// ------------------------------------------------------------
class DoomHunter:HDShotgun{
	default{
		//$Category "Weapons/Hideous Destructor"
		//$Title "Doomed Shotgun"
		//$Sprite "HUNTA0"

		weapon.selectionorder 31;
		weapon.slotnumber 3;
		weapon.slotpriority 1;
		weapon.bobrangex 0.21;
		weapon.bobrangey 0.86;
		scale 0.6;
		hdweapon.barrelsize 30,0.5,2;
		hdweapon.refid "dsg";
		tag "$TAG_DOOMHUNT";
		obituary "$OB_DOOMSHOTGUN";
	}

override void postbeginplay(){
		super.postbeginplay();
  weaponspecial=1337;
		}

	//returns the power of the load just fired
	static double Fire(actor caller,int choke=1){
		double spread=6.;
		double speedfactor=1.;
		let hhh=DoomHunter(caller.findinventory("DoomHunter"));
		if(hhh)choke=hhh.weaponstatus[DHUNS_CHOKE];

		choke=clamp(choke,0,7);
		spread=15-0.5*choke;
		speedfactor=1.+0.02857*choke;

		double shotpower=getshotpower();
		spread*=shotpower;
		speedfactor*=shotpower;
		HDBulletActor.FireBullet(caller,"HDB_wad");

  HDBulletActor.FireBullet(caller,"HDB_00",	spread:spread,aimoffx:random(-1, 1),speedfactor:speedfactor,amount:1);//1
  HDBulletActor.FireBullet(caller,"HDB_00",	spread:spread,aimoffx:random(-2, 0),speedfactor:speedfactor,amount:1);//2
  HDBulletActor.FireBullet(caller,"HDB_00",	spread:spread,aimoffx:random( 0, 2),speedfactor:speedfactor,amount:1);//3
  HDBulletActor.FireBullet(caller,"HDB_00",	spread:spread,aimoffx:random(-3,-1),speedfactor:speedfactor,amount:1);//4
  HDBulletActor.FireBullet(caller,"HDB_00",	spread:spread,aimoffx:random( 1, 3),speedfactor:speedfactor,amount:1);//5
  HDBulletActor.FireBullet(caller,"HDB_00",	spread:spread,aimoffx:random(-4,-2),speedfactor:speedfactor,amount:1);//6
  HDBulletActor.FireBullet(caller,"HDB_00",	spread:spread,aimoffx:random( 2, 4),speedfactor:speedfactor,amount:1);//7
  HDBulletActor.FireBullet(caller,"HDB_00",	spread:spread,aimoffx:random(-5,-3),speedfactor:speedfactor,amount:1);//8
  HDBulletActor.FireBullet(caller,"HDB_00",	spread:spread,aimoffx:random( 3, 5),speedfactor:speedfactor,amount:1);//9
  HDBulletActor.FireBullet(caller,"HDB_00",	spread:spread,aimoffx:random(-1, 1),speedfactor:speedfactor,amount:1);//10
		let p=HDBulletActor.FireBullet(caller,"HDB_00",	spread:spread,speedfactor:speedfactor,amount:0);//this one's just so the script works
		distantnoise.make(p,"weapons/dhunt_far");
		caller.A_StartSound("weapons/doomhunt_fire",CHAN_WEAPON);
		return shotpower;
	}
	const HUNTER_MINSHOTPOWER=0.901;
	action void A_FireHunter(){
		double shotpower=invoker.Fire(self);
		A_GunFlash();
		vector2 shotrecoil=(randompick(-1,1),-2.6);
		if(invoker.weaponstatus[DHUNS_FIREMODE]>0)shotrecoil=(randompick(-1,1)*1.4,-3.4);
		shotrecoil*=shotpower;
		A_MuzzleClimb(0,0,shotrecoil.x,shotrecoil.y,randompick(-1,1)*shotpower,-0.3*shotpower);
		invoker.weaponstatus[DHUNS_CHAMBER]=1;
		invoker.shotpower=shotpower;
	}

	override string pickupmessage(){
		if(weaponstatus[0]&DHUNF_CANFULLAUTO)return Stringtable.Localize("$PICKUP_DOOMEDHUNTER2");
		else if(weaponstatus[0]&DHUNF_EXPORT)return Stringtable.Localize("$PICKUP_DOOMEDHUNTER3");
		else if(weaponstatus[0]&DHUNF_SCOUT)return Stringtable.Localize("$PICKUP_DOOMEDHUNTER4");
		return Stringtable.Localize("$PICKUP_DOOMEDHUNTER1");
	}

	override string,double getpickupsprite(bool usespare){return "HUNT"..getpickupframe(usespare).."0",1.;}
	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
			sb.drawimage("SHL1A0",(-47,-10),basestatusbar.DI_SCREEN_CENTER_BOTTOM);
			sb.drawnum(hpl.countinv("HDShellAmmo"),-46,-8,
				basestatusbar.DI_SCREEN_CENTER_BOTTOM
			);
		}
		if(hdw.weaponstatus[DHUNS_CHAMBER]>1){
			sb.drawrect(-24,-14,5,3);
			sb.drawrect(-18,-14,2,3);
		}
		else if(hdw.weaponstatus[DHUNS_CHAMBER]>0){
			sb.drawrect(-18,-14,2,3);
		}
		if(!(hdw.weaponstatus[0]&DHUNF_EXPORT))sb.drawwepcounter(hdw.weaponstatus[DHUNS_FIREMODE],
			-26,-12,"blank","RBRSA3A7","STFULAUT"
		);
		sb.drawwepnum(hdw.weaponstatus[DHUNS_TUBE],hdw.weaponstatus[DHUNS_TUBESIZE],posy:-7);
		for(int i=hdw.weaponstatus[SHOTS_SIDESADDLE];i>0;i--){
			sb.drawrect(-16-i*2,-5,1,3);
		}
	}
	override string gethelptext(){
		return
		WEPHELP_FIRE.."  Shoot (choke: "..weaponstatus[DHUNS_CHOKE]..")\n"
		..WEPHELP_ALTFIRE.."  Pump\n"
		..WEPHELP_RELOAD.."  Reload (side saddles first)\n"
		..WEPHELP_ALTRELOAD.."  Reload (pockets only)\n"
		..(weaponstatus[0]&DHUNF_EXPORT?"":(WEPHELP_FIREMODE.."  Pump/Semi"..(weaponstatus[0]&DHUNF_CANFULLAUTO?"/Auto":"").."\n"))
		..WEPHELP_FIREMODE.."+"..WEPHELP_RELOAD.."  Load side saddles\n"
		..WEPHELP_USE.."+"..WEPHELP_UNLOAD.."  Steal ammo from Slayer\n"
		..WEPHELP_UNLOADUNLOAD
		;
	}
	override void DrawSightPicture(
		HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl,
		bool sightbob,vector2 bob,double fov,bool scopeview,actor hpc
	){
		int cx,cy,cw,ch;
		[cx,cy,cw,ch]=screen.GetClipRect();
		sb.SetClipRect(
			-16+bob.x,-32+bob.y,32,40,
			sb.DI_SCREEN_CENTER
		);
		vector2 bobb=bob*2;
//		bobb.y=clamp(bobb.y,-8,8);
		sb.drawimage(
			"frntsite",(0,0)+bobb,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP
		);
		sb.SetClipRect(cx,cy,cw,ch);
		sb.drawimage(
			"sgbaksit",(0,0)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			alpha:0.9
		);
	}
	override double gunmass(){
		int tube=weaponstatus[DHUNS_TUBE];
		if(tube>4)tube+=(tube-4)*2;
		return 8+tube*0.3+weaponstatus[SHOTS_SIDESADDLE]*0.08;
	}
	override double weaponbulk(){
		return 125+(weaponstatus[SHOTS_SIDESADDLE]+weaponstatus[DHUNS_TUBE])*ENC_SHELLLOADED;
	}

	action void A_SwitchFireMode(bool forwards=true){
		if(invoker.weaponstatus[0]&DHUNF_EXPORT){
			invoker.weaponstatus[DHUNS_FIREMODE]=0;
			return;
		}
		int newfm=invoker.weaponstatus[DHUNS_FIREMODE]+(forwards?1:-1);
		int newmax=(invoker.weaponstatus[0]&DHUNF_CANFULLAUTO)?2:1;
		if(newfm>newmax)newfm=0;
		else if(newfm<0)newfm=newmax;
		invoker.weaponstatus[DHUNS_FIREMODE]=newfm;
	}
	action void A_SetAltHold(bool which){
		if(which)invoker.weaponstatus[0]|=DHUNF_ALTHOLDING;
		else invoker.weaponstatus[0]&=~DHUNF_ALTHOLDING;
	}
	action void A_Chamber(bool careful=false){
		int chm=invoker.weaponstatus[DHUNS_CHAMBER];
		invoker.weaponstatus[DHUNS_CHAMBER]=0;
		if(invoker.weaponstatus[DHUNS_TUBE]>0){
			invoker.weaponstatus[DHUNS_CHAMBER]=2;
			invoker.weaponstatus[DHUNS_TUBE]--;
		}
		vector3 cockdir;double cp=cos(pitch);
		if(careful)cockdir=(-cp,cp,-5);
		else cockdir=(0,-cp*5,sin(pitch)*frandom(4,6));
		cockdir.xy=rotatevector(cockdir.xy,angle);
		actor fbs;bool gbg;
		if(chm>1){
			if(careful&&!A_JumpIfInventory("HDShellAmmo",0,"null")){
				HDF.Give(self,"HDShellAmmo",1);
			}else{
				[gbg,fbs]=A_SpawnItemEx("HDFumblingShell",
					cos(pitch)*8,0,height-8-sin(pitch)*8,
					vel.x+cockdir.x,vel.y+cockdir.y,vel.z+cockdir.z,
					0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
				);
			}
		}else if(chm>0){	
			cockdir*=frandom(1.,1.3);
			[gbg,fbs]=A_SpawnItemEx("HDSpentShell",
				cos(pitch)*8,frandom(-0.1,0.1),height-8-sin(pitch)*8,
				vel.x+cockdir.x,vel.y+cockdir.y,vel.z+cockdir.z,
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
			);
		}
	}
	action void A_CheckPocketSaddles(){
		if(invoker.weaponstatus[SHOTS_SIDESADDLE]<1)invoker.weaponstatus[0]|=DHUNF_FROMPOCKETS;
		if(!countinv("HDShellAmmo"))invoker.weaponstatus[0]&=~DHUNF_FROMPOCKETS;
	}
	action bool A_LoadTubeFromHand(){
		int hand=invoker.handshells;
		if(
			!hand
			||(
				invoker.weaponstatus[DHUNS_CHAMBER]>0
				&&invoker.weaponstatus[DHUNS_TUBE]>=invoker.weaponstatus[DHUNS_TUBESIZE]
			)
		){
			EmptyHand();
			return false;
		}
		invoker.weaponstatus[DHUNS_TUBE]++;
		invoker.handshells--;
		A_StartSound("weapons/dhunt_reload",8,CHANF_OVERLAP);
		return true;
	}
	action bool A_GrabShells(int maxhand=3,bool settics=false,bool alwaysone=false){
		if(maxhand>0)EmptyHand();else maxhand=abs(maxhand);
		bool fromsidesaddles=!(invoker.weaponstatus[0]&DHUNF_FROMPOCKETS);
		int toload=min(
			fromsidesaddles?invoker.weaponstatus[SHOTS_SIDESADDLE]:countinv("HDShellAmmo"),
			alwaysone?1:(invoker.weaponstatus[DHUNS_TUBESIZE]-invoker.weaponstatus[DHUNS_TUBE]),
			max(1,health/22),
			maxhand
		);
		if(toload<1)return false;
		invoker.handshells=toload;
		if(fromsidesaddles){
			invoker.weaponstatus[SHOTS_SIDESADDLE]-=toload;
			if(settics)A_SetTics(2);
			A_StartSound("weapons/pocket",8,CHANF_OVERLAP,0.4);
			A_MuzzleClimb(
				frandom(0.1,0.15),frandom(0.05,0.08),
				frandom(0.1,0.15),frandom(0.05,0.08)
			);
		}else{
			A_TakeInventory("HDShellAmmo",toload,TIF_NOTAKEINFINITE);
			if(settics)A_SetTics(7);
			A_StartSound("weapons/pocket",9);
			A_MuzzleClimb(
				frandom(0.1,0.15),frandom(0.2,0.4),
				frandom(0.2,0.25),frandom(0.3,0.4),
				frandom(0.1,0.35),frandom(0.3,0.4),
				frandom(0.1,0.15),frandom(0.2,0.4)
			);
		}
		return true;
	}
	states{
	select0:
		DMSG A 0;
		goto select0big;
	deselect0:
		DMSG A 0;
		goto deselect0big;
	firemode:
		DMSG A 0 a_switchfiremode();
	firemodehold:
		---- A 1{
			if(pressingreload()){
				a_switchfiremode(false); //untoggle
				setweaponstate("reloadss");
			}else A_WeaponReady(WRF_NONE);
		}
		---- A 0 A_JumpIf(pressingfiremode()&&invoker.weaponstatus[SHOTS_SIDESADDLE]<12,"firemodehold");
		goto nope;
	ready:
		DMSG A 0 A_JumpIf(pressingunload()&&(pressinguse()||pressingzoom()),"cannibalize");
		DMSG A 0 A_JumpIf(pressingaltfire(),2);
		DMSG A 0{
			if(!pressingaltfire()){
				if(!pressingfire())A_ClearRefire();
				A_SetAltHold(false);
			}
		}
		DMSG A 1 A_WeaponReady(WRF_ALL);
		goto readyend;
	reloadSS:
		DMSG A 1 offset(1,34);
		DMSG A 2 offset(2,34);
		DMSG A 3 offset(3,36);
	reloadSSrestart:
		DMSG A 6 offset(3,35);
		DMSG A 9 offset(4,34);
		DMSG A 4 offset(3,34){
			int hnd=min(
				countinv("HDShellAmmo"),
				12-invoker.weaponstatus[SHOTS_SIDESADDLE],
				max(1,health/22),
				3
			);
			if(hnd<1)setweaponstate("reloadSSend");
			else{
				A_TakeInventory("HDShellAmmo",hnd);
				invoker.weaponstatus[SHOTS_SIDESADDLE]+=hnd;
				A_StartSound("weapons/pocket",8);
			}
		}
		DMSG A 0 {
			if(
				!PressingReload()
				&&!PressingAltReload()
			)setweaponstate("reloadSSend");
			else if(
				invoker.weaponstatus[SHOTS_SIDESADDLE]<12
				&&countinv("HDShellAmmo")
			)setweaponstate("ReloadSSrestart");
		}
	reloadSSend:
		DMSG A 3 offset(2,34);
		DMSG A 1 offset(1,34) EmptyHand(careful:true);
		goto nope;
	hold:
		DMSG A 0{
			bool paf=pressingaltfire();
			if(
				paf&&!(invoker.weaponstatus[0]&DHUNF_ALTHOLDING)
			)setweaponstate("chamber");
			else if(!paf)invoker.weaponstatus[0]&=~DHUNF_ALTHOLDING;
		}
		DMSG A 1 A_WeaponReady(WRF_NONE);
		DMSG A 0 A_Refire();
		goto ready;
	fire:
		DMSG A 0 A_JumpIf(invoker.weaponstatus[DHUNS_CHAMBER]==2,"shoot");
		DMSG A 1 A_WeaponReady(WRF_NONE);
		DMSG A 0 A_Refire();
		goto ready;
	shoot:
		DMSG A 2;
		DMSG A 1 offset(0,36) A_FireHunter();
		DMSG A 1;
		DMSG A 0{
			if(
				invoker.weaponstatus[DHUNS_FIREMODE]>0
				&&invoker.shotpower>HUNTER_MINSHOTPOWER
			)setweaponstate("chamberauto");
		}goto ready;
	altfire:  //this is the important part
	chamber:
		DMSG A 0 A_JumpIf(invoker.weaponstatus[0]&DHUNF_ALTHOLDING,"nope");
		DMSG A 0 A_SetAltHold(true);
		DMSG A 1 A_Overlay(120,"playsgco");
		DMSG AB 3 A_MuzzleClimb(0,frandom(0.6,1.));
		DMSG C 2 A_JumpIf(pressingaltfire(),"longstroke");
		DMSG CB 3 A_MuzzleClimb(0,-frandom(0.6,1.));
		DMSG B 0 A_StartSound("weapons/dhunt_short",8);
		DMSG A 0 A_Refire("ready");
		goto ready;
	longstroke:
		DMSG D 2 A_MuzzleClimb(frandom(1.,2.));
		DMSG D 0{
			A_Chamber();
			A_MuzzleClimb(-frandom(1.,2.));
		}
	racked:
		DMSG D 1 A_WeaponReady(WRF_NOFIRE);
		DMSG D 0 A_JumpIf(!pressingaltfire(),"unrack");
		DMSG D 0 A_JumpIf(pressingunload(),"rackunload");
		DMSG D 0 A_JumpIf(invoker.weaponstatus[DHUNS_CHAMBER],"racked");
		DMSG D 0{
			int rld=0;
			if(pressingreload()){
				rld=1;
				if(invoker.weaponstatus[SHOTS_SIDESADDLE]>0)
				invoker.weaponstatus[0]&=~DHUNF_FROMPOCKETS;
				else{
					invoker.weaponstatus[0]|=DHUNF_FROMPOCKETS;
					rld=2;
				}
			}else if(pressingaltreload()){
				rld=2;
				invoker.weaponstatus[0]|=DHUNF_FROMPOCKETS;
			}
			if(
				(rld==2&&countinv("HDShellAmmo"))
				||(rld==1&&invoker.weaponstatus[SHOTS_SIDESADDLE]>0)
			)setweaponstate("rackreload");
		}
		loop;
	rackreload:
		DMSG D 1 offset(-1,35) A_WeaponBusy(true);
		DMSG D 2 offset(-2,37);
		DMSG D 4 offset(-3,40);
		DMSG D 1 offset(-4,42) A_GrabShells(1,true,true);
		DMSG D 0 A_JumpIf(!(invoker.weaponstatus[0]&DHUNF_FROMPOCKETS),"rackloadone");
		DMSG D 6 offset(-5,43);
		DMSG D 6 offset(-4,41) A_StartSound("weapons/pocket",9);
	rackloadone:
		DMSG D 1 offset(-4,42);
		DMSG D 2 offset(-4,41);
		DMSG D 3 offset(-4,40){
			A_StartSound("weapons/dhunt_reload",8,CHANF_OVERLAP);
			invoker.weaponstatus[DHUNS_CHAMBER]=2;
			invoker.handshells--;
			EmptyHand(careful:true);
		}
		DMSG D 5 offset(-4,41);
		DMSG D 4 offset(-4,40) A_JumpIf(invoker.handshells>0,"rackloadone");
		goto rackreloadend;
	rackreloadend:
		DMSG D 1 offset(-3,39);
		DMSG D 1 offset(-2,37);
		DMSG D 1 offset(-1,34);
		DMSG D 0 A_WeaponBusy(false);
		goto racked;

	rackunload:
		DMSG D 1 offset(-1,35) A_WeaponBusy(true);
		DMSG D 2 offset(-2,37);
		DMSG D 4 offset(-3,40);
		DMSG D 1 offset(-4,42);
		DMSG D 2 offset(-4,41);
		DMSG D 3 offset(-4,40){
			int chm=invoker.weaponstatus[DHUNS_CHAMBER];
			invoker.weaponstatus[DHUNS_CHAMBER]=0;
			if(chm==2){
				invoker.handshells++;
				EmptyHand(careful:true);
			}else if(chm==1)A_SpawnItemEx("HDSpentShell",
				cos(pitch)*8,0,height-7-sin(pitch)*8,
				vel.x+cos(pitch)*cos(angle-random(86,90))*5,
				vel.y+cos(pitch)*sin(angle-random(86,90))*5,
				vel.z+sin(pitch)*random(4,6),
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
			);
			if(chm)A_StartSound("weapons/dhunt_reload",8,CHANF_OVERLAP);
		}
		DMSG D 5 offset(-4,41);
		DMSG D 4 offset(-4,40) A_JumpIf(invoker.handshells>0,"rackloadone");
		goto rackreloadend;

	unrack:  //this is also important
		DMSG D 0 A_Overlay(120,"playsgco2");
		DMSG C 3 A_JumpIf(!pressingfire(),1);
		DMSG BA 3{
			if(pressingfire())A_SetTics(1);
			A_MuzzleClimb(0,-frandom(0.6,1.));
		}
		DMSG A 0 A_ClearRefire();
		goto ready;
	playsgco:
		TNT1 A 8 A_StartSound("weapons/dhunt_rackup",8);
		TNT1 A 0 A_StopSound(8);
		stop;
	playsgco2:
		TNT1 A 8 A_StartSound("weapons/dhunt_rackdown",8);
		TNT1 A 0 A_StopSound(8);
		stop;
	chamberauto:
		DMSG A 1 A_Chamber();
		DMSG A 1 A_JumpIf(invoker.weaponstatus[0]&DHUNF_CANFULLAUTO&&invoker.weaponstatus[DHUNS_FIREMODE]==2,"ready");
		DMSG A 0 A_Refire();
		goto ready;
	flash:
		DSGF A 1 bright{
			A_Light2();
			HDFlashAlpha(-32);
		}
		TNT1 A 1 A_ZoomRecoil(0.9);
		TNT1 A 0 A_Light0();
		TNT1 A 0 A_AlertMonsters();
		stop;
	altreload:
	reloadfrompockets:
		DMSG A 0{
			if(!countinv("HDShellAmmo"))setweaponstate("nope");
			else invoker.weaponstatus[0]|=DHUNF_FROMPOCKETS;
		}goto startreload;
	reload:
	reloadfromsidesaddles:
		DMSG A 0{
			int sss=invoker.weaponstatus[SHOTS_SIDESADDLE];
			int ppp=countinv("HDShellAmmo");
			if(ppp<1&&sss<1)setweaponstate("nope");
				else if(sss<1)
					invoker.weaponstatus[0]|=DHUNF_FROMPOCKETS;
				else invoker.weaponstatus[0]&=~DHUNF_FROMPOCKETS;
		}goto startreload;
	startreload:
		DMSG A 1{
			if(
				invoker.weaponstatus[DHUNS_TUBE]>=invoker.weaponstatus[DHUNS_TUBESIZE]
			){
				if(
					invoker.weaponstatus[SHOTS_SIDESADDLE]<12
					&&countinv("HDShellAmmo")
				)setweaponstate("ReloadSS");
				else setweaponstate("nope");
			}
		}
		DMSG AB 4 A_MuzzleClimb(frandom(.6,.7),-frandom(.6,.7));
	reloadstarthand:
		DMSG C 1 offset(0,36);
		DMSG C 1 offset(0,38);
		DMSG C 2 offset(0,36);
		DMSG C 2 offset(0,34);
		DMSG C 3 offset(0,36);
		DMSG C 3 offset(0,40) A_CheckPocketSaddles();
		DMSG C 0 A_JumpIf(invoker.weaponstatus[0]&DHUNF_FROMPOCKETS,"reloadpocket");
	reloadfast:
		DMSG C 4 offset(0,40) A_GrabShells(3,false);
		DMSG C 3 offset(0,42) A_StartSound("weapons/pocket",9,volume:0.4);
		DMSG C 3 offset(0,41);
		goto reloadashell;
	reloadpocket:
		DMSG C 4 offset(0,39) A_GrabShells(3,false);
		DMSG C 6 offset(0,40) A_JumpIf(health>40,1);
		DMSG C 4 offset(0,40) A_StartSound("weapons/pocket",9);
		DMSG C 8 offset(0,42) A_StartSound("weapons/pocket",9);
		DMSG C 6 offset(0,41) A_StartSound("weapons/pocket",9);
		DMSG C 6 offset(0,40);
		goto reloadashell;
	reloadashell:
		DMSG C 2 offset(0,36);
		DMSG C 4 offset(0,34)A_LoadTubeFromHand();
		DMSG CCCCCC 1 offset(0,33){
			if(
				PressingReload()
				||PressingAltReload()
				||PressingUnload()
				||PressingFire()
				||PressingAltfire()
				||PressingZoom()
				||PressingFiremode()
			)invoker.weaponstatus[0]|=DHUNF_HOLDING;
			else invoker.weaponstatus[0]&=~DHUNF_HOLDING;

			if(
				invoker.weaponstatus[DHUNS_TUBE]>=invoker.weaponstatus[DHUNS_TUBESIZE]
				||(
					invoker.handshells<1&&(
						invoker.weaponstatus[0]&DHUNF_FROMPOCKETS
						||invoker.weaponstatus[SHOTS_SIDESADDLE]<1
					)&&
					!countinv("HDShellAmmo")
				)
			)setweaponstate("reloadend");
			else if(
				!pressingaltreload()
				&&!pressingreload()
			)setweaponstate("reloadend");
			else if(invoker.handshells<1)setweaponstate("reloadstarthand");
		}goto reloadashell;
	reloadend:
		DMSG C 4 offset(0,34) A_StartSound("weapons/dhunt_open",8);
		DMSG C 1 offset(0,36) EmptyHand(careful:true);
		DMSG C 1 offset(0,34);
		DMSG CBA 3;
		DMSG A 0 A_JumpIf(invoker.weaponstatus[0]&DHUNF_HOLDING,"nope");
		goto ready;

	cannibalize:
		DMSG A 2 offset(0,36) A_JumpIf(!countinv("Slayer"),"nope");
		DMSG A 2 offset(0,40) A_StartSound("weapons/pocket",9);
		DMSG A 6 offset(0,42);
		DMSG A 4 offset(0,44);
		DMSG A 6 offset(0,42);
		DMSG A 2 offset (0,36) A_CannibalizeOtherShotgun();
		goto ready;

	unloadSS:
		DMSG A 2 offset(1,34) A_JumpIf(invoker.weaponstatus[SHOTS_SIDESADDLE]<1,"nope");
		DMSG A 1 offset(2,34);
		DMSG A 1 offset(3,36);
	unloadSSLoop1:
		DMSG A 4 offset(4,36);
		DMSG A 2 offset(5,37) A_UnloadSideSaddle();
		DMSG A 3 offset(4,36){	//decide whether to loop
			if(
				PressingReload()
				||PressingFire()
				||PressingAltfire()
				||invoker.weaponstatus[SHOTS_SIDESADDLE]<1
			)setweaponstate("unloadSSend");
		}goto unloadSSLoop1;
	unloadSSend:
		DMSG A 3 offset(4,35);
		DMSG A 2 offset(3,35);
		DMSG A 1 offset(2,34);
		DMSG A 1 offset(1,34);
		goto nope;
	unload:
		DMSG A 1{
			if(
				invoker.weaponstatus[SHOTS_SIDESADDLE]>0
				&&!(player.cmd.buttons&BT_USE)
			)setweaponstate("unloadSS");
			else if(
				invoker.weaponstatus[DHUNS_CHAMBER]<1
				&&invoker.weaponstatus[DHUNS_TUBE]<1
			)setweaponstate("nope");
		}
		DMSG BC 4 A_MuzzleClimb(frandom(1.2,2.4),-frandom(1.2,2.4));
		DMSG C 1 offset(0,34);
		DMSG C 1 offset(0,36) A_StartSound("weapons/dhunt_open",8);
		DMSG C 1 offset(0,38);
		DMSG C 4 offset(0,36){
			A_MuzzleClimb(-frandom(1.2,2.4),frandom(1.2,2.4));
			if(invoker.weaponstatus[DHUNS_CHAMBER]<1){
				setweaponstate("unloadtube");
			}else A_StartSound("weapons/dhunt_rack",8,CHANF_OVERLAP);
		}
		DMSG D 8 offset(0,34){
			A_MuzzleClimb(-frandom(1.2,2.4),frandom(1.2,2.4));
			int chm=invoker.weaponstatus[DHUNS_CHAMBER];
			invoker.weaponstatus[DHUNS_CHAMBER]=0;
			if(chm>1){
				A_StartSound("weapons/dhunt_reload",8);
				if(A_JumpIfInventory("HDShellAmmo",0,"null"))A_SpawnItemEx("HDFumblingShell",
					cos(pitch)*8,0,height-7-sin(pitch)*8,
					vel.x+cos(pitch)*cos(angle-random(86,90))*5,
					vel.y+cos(pitch)*sin(angle-random(86,90))*5,
					vel.z+sin(pitch)*random(4,6),
					0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
				);else{
					HDF.Give(self,"HDShellAmmo",1);
					A_StartSound("weapons/pocket",9);
					A_SetTics(5);
				}
			}else if(chm>0)A_SpawnItemEx("HDSpentShell",
				cos(pitch)*8,0,height-7-sin(pitch)*8,
				vel.x+cos(pitch)*cos(angle-random(86,90))*5,
				vel.y+cos(pitch)*sin(angle-random(86,90))*5,
				vel.z+sin(pitch)*random(4,6),
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
			);
		}
		DMSG C 0 A_JumpIf(!pressingunload(),"reloadend");
		DMSG C 4 offset(0,40);
	unloadtube:
		DMSG C 6 offset(0,40) EmptyHand(careful:true);
	unloadloop:
		DMSG C 8 offset(1,41){
			if(invoker.weaponstatus[DHUNS_TUBE]<1)setweaponstate("reloadend");
			else if(invoker.handshells>=3)setweaponstate("unloadloopend");
			else{
				invoker.handshells++;
				invoker.weaponstatus[DHUNS_TUBE]--;
			}
		}
		DMSG C 4 offset(0,40) A_StartSound("weapons/dhunt_reload",8);
		loop;
	unloadloopend:
		DMSG C 6 offset(1,41);
		DMSG C 3 offset(1,42){
			int rmm=HDPickup.MaxGive(self,"HDShellAmmo",ENC_SHELL);
			if(rmm>0){
				A_StartSound("weapons/pocket",9);
				A_SetTics(8);
				HDF.Give(self,"HDShellAmmo",min(rmm,invoker.handshells));
				invoker.handshells=max(invoker.handshells-rmm,0);
			}
		}
		DMSG C 0 EmptyHand(careful:true);
		DMSG C 6 A_Jumpif(!pressingunload(),"reloadend");
		goto unloadloop;
	spawn:
		DHUN ABCDEFG -1 nodelay{
			int ssh=invoker.weaponstatus[SHOTS_SIDESADDLE];
			if(ssh>=11)frame=0;
			else if(ssh>=9)frame=1;
			else if(ssh>=7)frame=2;
			else if(ssh>=5)frame=3;
			else if(ssh>=3)frame=4;
			else if(ssh>=1)frame=5;
			else frame=6;
		}
	}
	override void InitializeWepStats(bool idfa){
		weaponstatus[DHUNS_CHAMBER]=2;
		if(!idfa){
			  weaponstatus[DHUNS_TUBESIZE]=7;
			  weaponstatus[DHUNS_CHOKE]=1;
		}

  if(weaponstatus[0]&DHUNF_SCOUT){
      weaponstatus[DHUNS_TUBESIZE]=5;
    }

		weaponstatus[DHUNS_TUBE]=weaponstatus[DHUNS_TUBESIZE];
		weaponstatus[SHOTS_SIDESADDLE]=12;
		handshells=0;
	}
	override void loadoutconfigure(string input){
		int type=getloadoutvar(input,"type",1);
		if(type>=0){
			switch(type){
			case 0:
				weaponstatus[0]|=DHUNF_EXPORT;
				weaponstatus[0]&=~DHUNF_CANFULLAUTO;
				break;
			case 1:
				weaponstatus[0]&=~DHUNF_EXPORT;
				weaponstatus[0]&=~DHUNF_CANFULLAUTO;
				break;
			case 2:
				weaponstatus[0]&=~DHUNF_EXPORT;
				weaponstatus[0]|=DHUNF_CANFULLAUTO;
				break;
    case 3:
				weaponstatus[0]|=DHUNF_SCOUT;
				weaponstatus[0]&=~DHUNF_CANFULLAUTO;
				break;
    case 4:
				weaponstatus[0]|=DHUNF_SCOUT;
				weaponstatus[0]|=DHUNF_CANFULLAUTO;
				break;
			default:
				break;
			}
		}
		if(type<0||type>4)type=1;
		int firemode=getloadoutvar(input,"firemode",1);
		if(firemode>=0)weaponstatus[DHUNS_FIREMODE]=clamp(firemode,0,type);
		int choke=min(getloadoutvar(input,"choke",1),7);
		if(choke>=0)weaponstatus[DHUNS_CHOKE]=choke;

		int tubesize=((weaponstatus[0]&DHUNF_EXPORT)?5:7);
  int tubesizescout=((weaponstatus[0]&DHUNF_SCOUT)?5:7);

//god this is so confusing Dx
 if(weaponstatus[DHUNS_TUBE]>tubesize)weaponstatus[DHUNS_TUBE]=tubesize;
		weaponstatus[DHUNS_TUBESIZE]=tubesize;  

if (weaponstatus[0]&DHUNF_SCOUT){
   if(weaponstatus[DHUNS_TUBE]>tubesizescout){
    weaponstatus[DHUNS_TUBE]=tubesizescout;
    }
		weaponstatus[DHUNS_TUBESIZE]=tubesizescout;  
  }
/*  original code for reference

int tubesize=((weaponstatus[0]&DHUNF_EXPORT)?5:7);
		if(weaponstatus[DHUNS_TUBE]>tubesize)weaponstatus[DHUNS_TUBE]=tubesize;
		weaponstatus[DHUNS_TUBESIZE]=tubesize;

*/

  
	}
}
enum doomedhunterstatus{
	DHUNF_CANFULLAUTO=1,
	DHUNF_JAMMED=2,
	DHUNF_UNLOADONLY=4,
	DHUNF_FROMPOCKETS=8,
	DHUNF_ALTHOLDING=16,
	DHUNF_HOLDING=32,
	DHUNF_EXPORT=64,
 	DHUNF_SCOUT=128,

	DHUNS_FIREMODE=1,
	DHUNS_CHAMBER=2,
	//3 is for side saddles
	DHUNS_TUBE=4,
	DHUNS_TUBESIZE=5,
	DHUNS_HAND=6,
	DHUNS_CHOKE=7,
};


class DoomHunterRandom:IdleDummy{
	states{
	spawn:
		TNT1 A 0 nodelay{
			let ggg=DoomHunter(spawn("DoomHunter",pos,ALLOW_REPLACE));
			if(!ggg)return;
			HDF.TransferSpecials(self,ggg,HDF.TS_ALL);

			if(!random(0,7))ggg.weaponstatus[DHUNS_CHOKE]=random(0,7);
			if(!random(0,32)){
				ggg.weaponstatus[0]&=~DHUNF_EXPORT;
				ggg.weaponstatus[0]|=DHUNF_CANFULLAUTO;
			}else if(!random(0,7)){
				ggg.weaponstatus[0]|=DHUNF_EXPORT;
				ggg.weaponstatus[0]&=~DHUNF_CANFULLAUTO;
			}
  else if(!random(0,7)){
				ggg.weaponstatus[0]|=DHUNF_SCOUT;
				ggg.weaponstatus[0]&=~DHUNF_CANFULLAUTO;
			}
  else if(!random(0,7)){
				ggg.weaponstatus[0]|=DHUNF_SCOUT;
				ggg.weaponstatus[0]|=DHUNF_CANFULLAUTO;
			}
			int tubesize=((ggg.weaponstatus[0]&DHUNF_EXPORT)?5:7);
    int tubesizescout=((ggg.weaponstatus[0]&DHUNF_SCOUT)?5:7);


if(ggg.weaponstatus[DHUNS_TUBE]>tubesize)ggg.weaponstatus[DHUNS_TUBE]=tubesize;
		ggg.weaponstatus[DHUNS_TUBESIZE]=tubesize;  

if (ggg.weaponstatus[0]&DHUNF_SCOUT){
   if(ggg.weaponstatus[DHUNS_TUBE]>tubesizescout){
    ggg.weaponstatus[DHUNS_TUBE]=tubesizescout;
    }
		ggg.weaponstatus[DHUNS_TUBESIZE]=tubesizescout;  
  }

		}stop;
	}
}


