// ------------------------------------------------------------
// A 20-gauge pump for bird hunting
// ------------------------------------------------------------
const HDLD_DUCKUNT = "DUK";

//yes, it's a 20g shotgun now,
//because 12g shells hold too many pellets
//to fire them all at once without
//performance issues

class DuckHunter:HDShotgun{
	default{
		//$Category "Weapons/Hideous Destructor"
		//$Title "Duck Hunter"
		//$Sprite "DHNTA0"

		weapon.selectionorder 31;
		weapon.slotnumber 3;
		weapon.slotpriority 0.1;
		weapon.bobrangex 0.21;
		weapon.bobrangey 0.9;
		scale 0.6;
		hdweapon.barrelsize 30,0.5,2;
		hdweapon.refid HDLD_DUCKUNT;
		tag "$TAG_DUCKHUNT";
		obituary "$OB_DUCKHUNT";
		
		hdweapon.loadoutcodes "
			\cuchoke - 0-7, 0 skeet, 7 full";
	}
	
	override string pickupmessage(){
		return Stringtable.Localize("$PICKUP_DUCKHUNT");
	}
	
	//returns the power of the load just fired
	static double Fire(actor caller,int choke=1){
		double spread=6.;
		double speedfactor=1.;
		let hhh=DuckHunter(caller.findinventory("DuckHunter"));
		if(hhh)choke=hhh.weaponstatus[DUCKHUNTS_CHOKE];

		choke=clamp(choke,0,7);
		spread=6.5-0.5*choke;
		speedfactor=1.+0.02857*choke;

		double shotpower=getshotpower();
		spread*=shotpower;
		speedfactor*=shotpower;
		HDBulletActor.FireBullet(caller,"HDB_wad");
		let p=HDBulletActor.FireBullet(caller,"HDB_BBShot",
			spread:spread,speedfactor:speedfactor,amount:30
		);
		distantnoise.make(p,"world/duckfar");
		caller.A_StartSound("weapons/duckhunter",CHAN_WEAPON);
		return shotpower;
	}
	const HUNTER_MINSHOTPOWER=0.901;
	action void A_FireHunter(){
		double shotpower=invoker.Fire(self);
		A_GunFlash();
		vector2 shotrecoil=(randompick(-1,1),-2.6);
		if(invoker.weaponstatus[DUCKHUNTS_FIREMODE]>0)shotrecoil=(randompick(-1,1)*1.4,-3.4);
		shotrecoil*=shotpower;
		A_MuzzleClimb(0,0,shotrecoil.x,shotrecoil.y,randompick(-1,1)*shotpower,-0.3*shotpower);
		invoker.weaponstatus[DUCKHUNTS_CHAMBER]=1;
		invoker.shotpower=shotpower;
	}
	/*
	override string pickupmessage(){
		if(weaponstatus[0]&DUCKHUNTF_CANFULLAUTO)return string.format("%s You notice some tool marks near the fire selector...",super.pickupmessage());
		else if(weaponstatus[0]&DUCKHUNTF_EXPORT)return string.format("%s Where is the fire selector on this thing!?",super.pickupmessage());
		return super.pickupmessage();
	}
	*/
	override string,double getpickupsprite(bool usespare){return "DHNT"..getpickupframe(usespare).."0",1.;}
	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
			sb.drawimage("BSHLA0",(-47,-10),basestatusbar.DI_SCREEN_CENTER_BOTTOM);
			sb.drawnum(hpl.countinv("HDBirdshotShellAmmo"),-46,-8,
				basestatusbar.DI_SCREEN_CENTER_BOTTOM
			);
		}
		if(hdw.weaponstatus[DUCKHUNTS_CHAMBER]>1){
			sb.drawrect(-24,-14,5,3);
			sb.drawrect(-18,-14,2,3);
		}
		else if(hdw.weaponstatus[DUCKHUNTS_CHAMBER]>0){
			sb.drawrect(-18,-14,2,3);
		}
		if(!(hdw.weaponstatus[0]&DUCKHUNTF_EXPORT))sb.drawwepcounter(hdw.weaponstatus[DUCKHUNTS_FIREMODE],
			-26,-12,"blank","RBRSA3A7","STFULAUT"
		);
		sb.drawwepnum(hdw.weaponstatus[DUCKHUNTS_TUBE],hdw.weaponstatus[HUNTS_TUBESIZE],posy:-7);
		for(int i=hdw.weaponstatus[SHOTS_SIDESADDLE];i>0;i--){
			sb.drawrect(-16-i*2,-5,1,3);
		}
	}
	override string gethelptext(){
		return
		LWPHELP_FIRE.."  Shoot (choke: "..weaponstatus[DUCKHUNTS_CHOKE]..")\n"
		..LWPHELP_ALTFIRE.."  Pump\n"
		..LWPHELP_RELOAD.."  Reload (side saddles first)\n"
		..LWPHELP_ALTRELOAD.."  Reload (pockets only)\n"
	//	..(weaponstatus[0]&HUNTF_EXPORT?"":(LWPHELP_FIREMODE.."  Pump/Semi"..(weaponstatus[0]&HUNTF_CANFULLAUTO?"/Auto":"").."\n"))
		..LWPHELP_FIREMODE.."+"..LWPHELP_RELOAD.."  Load side saddles\n"
	//	..LWPHELP_USE.."+"..LWPHELP_UNLOAD.."  Steal ammo from Slayer\n"
		..LWPHELP_UNLOADUNLOAD
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
		vector2 bobb=bob*1.1;
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
		int tube=weaponstatus[DUCKHUNTS_TUBE];
		if(tube>4)tube+=(tube-4)*2;
		return 8+tube*0.3+weaponstatus[SHOTS_SIDESADDLE]*0.08;
	}
	override double weaponbulk(){
		return 125+(weaponstatus[SHOTS_SIDESADDLE]+weaponstatus[HUNTS_TUBE])*ENC_SHELLLOADED;
	}
	
	action void A_SwitchFireMode(bool forwards=true){
		if(invoker.weaponstatus[0]&DUCKHUNTF_EXPORT){
			invoker.weaponstatus[DUCKHUNTS_FIREMODE]=0;
			return;
		}
		int newfm=invoker.weaponstatus[DUCKHUNTS_FIREMODE]+(forwards?1:-1);
		int newmax=(invoker.weaponstatus[0]&DUCKHUNTF_CANFULLAUTO)?2:1;
		if(newfm>newmax)newfm=0;
		else if(newfm<0)newfm=newmax;
		invoker.weaponstatus[DUCKHUNTS_FIREMODE]=newfm;
	}
	
	action void A_SetAltHold(bool which){
		if(which)invoker.weaponstatus[0]|=DUCKHUNTF_ALTHOLDING;
		else invoker.weaponstatus[0]&=~DUCKHUNTF_ALTHOLDING;
	}
	action void A_Chamber(bool careful=false){
		int chm=invoker.weaponstatus[DUCKHUNTS_CHAMBER];
		invoker.weaponstatus[DUCKHUNTS_CHAMBER]=0;
		if(invoker.weaponstatus[DUCKHUNTS_TUBE]>0){
			invoker.weaponstatus[DUCKHUNTS_CHAMBER]=2;
			invoker.weaponstatus[DUCKHUNTS_TUBE]--;
		}
		vector3 cockdir;double cp=cos(pitch);
		if(careful)cockdir=(-cp,cp,-5);
		else cockdir=(0,-cp*5,sin(pitch)*frandom(4,6));
		cockdir.xy=rotatevector(cockdir.xy,angle);
		bool pocketed=false;
		if(chm>1){
			if(careful&&!A_JumpIfInventory("HDBirdshotShellAmmo",0,"null")){
				HDF.Give(self,"HDBirdshotShellAmmo",1);
				pocketed=true;
			}
		}else if(chm>0){	
			cockdir*=frandom(1.,1.3);
		}

		if(
			!pocketed
			&&chm>=1
		){
			vector3 gunofs=HDMath.RotateVec3D((9,-1,-2),angle,pitch);
			actor rrr=null;

			if(chm>1)rrr=spawn("HDFumblingBirdshotShell",(pos.xy,pos.z+height*0.85)+gunofs+viewpos.offset);
			else rrr=spawn("HDSpentBirdshotShell",(pos.xy,pos.z+height*0.85)+gunofs+viewpos.offset);

			rrr.target=self;
			rrr.angle=angle;
			rrr.vel=HDMath.RotateVec3D((1,-5,0.2),angle,pitch);
			if(chm==1)rrr.vel*=1.3;
			rrr.vel+=vel;
		}
	}
	action void A_CheckPocketSaddles(){
		if(invoker.weaponstatus[SHOTS_SIDESADDLE]<1)invoker.weaponstatus[0]|=HUNTF_FROMPOCKETS;
		if(!countinv("HDBirdshotShellAmmo"))invoker.weaponstatus[0]&=~HUNTF_FROMPOCKETS;
	}
	action bool A_LoadTubeFromHand(){
		int hand=invoker.handshells;
		if(
			!hand
			||(
				invoker.weaponstatus[DUCKHUNTS_CHAMBER]>0
				&&invoker.weaponstatus[DUCKHUNTS_TUBE]>=invoker.weaponstatus[DUCKHUNTS_TUBESIZE]
			)
		){
			EmptyHand();
			return false;
		}
		invoker.weaponstatus[DUCKHUNTS_TUBE]++;
		invoker.handshells--;
		A_StartSound("weapons/huntreload",8,CHANF_OVERLAP);
		return true;
	}
	action bool A_GrabShells(int maxhand=3,bool settics=false,bool alwaysone=false){
		if(maxhand>0)EmptyHand();else maxhand=abs(maxhand);

		bool fromsidesaddles=!(invoker.weaponstatus[0]&HUNTF_FROMPOCKETS);
		int toload=min(
			fromsidesaddles?invoker.weaponstatus[SHOTS_SIDESADDLE]:countinv("HDBirdshotShellAmmo"),
			alwaysone?1:(invoker.weaponstatus[DUCKHUNTS_TUBESIZE]-invoker.weaponstatus[DUCKHUNTS_TUBE]),
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
			A_TakeInventory("HDBirdshotShellAmmo",toload,TIF_NOTAKEINFINITE);
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
	
	action void EmptyDuckHand(int amt=-1,bool careful=false){
		if(!amt)return;
		if(amt>0)invoker.handshells=amt;
		while(invoker.handshells>0){
			if(careful&&!A_JumpIfInventory("HDBirdshotShellAmmo",0,"null")){
				invoker.handshells--;
				HDF.Give(self,"HDBirdshotShellAmmo",1);
 			}else if(invoker.handshells>=4){
				invoker.handshells-=4;
				A_SpawnItemEx("BirdshotShellPickup",
					cos(pitch)*1,1,height-7-sin(pitch)*1,
					cos(pitch)*cos(angle)*frandom(1,2)+vel.x,
					cos(pitch)*sin(angle)*frandom(1,2)+vel.y,
					-sin(pitch)+vel.z,
					0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
				);
			}else{
				invoker.handshells--;
				A_SpawnItemEx("HDFumblingBirdshotShell",
					cos(pitch)*5,1,height-7-sin(pitch)*5,
					cos(pitch)*cos(angle)*frandom(1,4)+vel.x,
					cos(pitch)*sin(angle)*frandom(1,4)+vel.y,
					-sin(pitch)*random(1,4)+vel.z,
					0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
				);
			}
		}
	}
	
	action void A_UnloadDuckSaddle(){
		int uamt=clamp(invoker.weaponstatus[SHOTS_SIDESADDLE],0,4);
		if(!uamt)return;
		invoker.weaponstatus[SHOTS_SIDESADDLE]-=uamt;
		int maxpocket=min(uamt,HDPickup.MaxGive(self,"HDBirdshotShellAmmo",ENC_SHELL));
		if(maxpocket>0&&pressingunload()){
			A_SetTics(16);
			uamt-=maxpocket;
			A_GiveInventory("HDBirdshotShellAmmo",maxpocket);
		}
		A_StartSound("weapons/pocket",9);
		EmptyDuckHand(uamt);
	}
	
	
	
	states{
	select0:
		DKSG A 0;
		goto select0big;
	deselect0:
		DKSG A 0;
		goto deselect0big;
		
	firemode:
	//	DKSG A 0 a_switchfiremode();
	firemodehold:
		---- A 1{
			if(pressingreload()){
				setweaponstate("reloadss");
			}else A_WeaponReady(WRF_NONE);
		}
		---- A 0 A_JumpIf(pressingfiremode()&&invoker.weaponstatus[SHOTS_SIDESADDLE]<12,"firemodehold");
		goto nope;
	ready:
		DKSG A 0 A_JumpIf(pressingaltfire(),2);
		DKSG A 0{
			if(!pressingaltfire()){
				if(!pressingfire())A_ClearRefire();
				A_SetAltHold(false);
			}
		}
		DKSG A 1 A_WeaponReady(WRF_ALL);
		goto readyend;
	reloadSS:
		DKSG A 1 offset(1,34);
		DKSG A 2 offset(2,34);
		DKSG A 3 offset(3,36);
	reloadSSrestart:
		DKSG A 6 offset(3,35);
		DKSG A 9 offset(4,34);
		DKSG A 4 offset(3,34){
			int hnd=min(
				countinv("HDBirdshotShellAmmo"),
				12-invoker.weaponstatus[SHOTS_SIDESADDLE],
				3
			);
			if(hnd<1)setweaponstate("reloadSSend");
			else{
				A_TakeInventory("HDBirdshotShellAmmo",hnd);
				invoker.weaponstatus[SHOTS_SIDESADDLE]+=hnd;
				A_StartSound("weapons/pocket",8);
			}
		}
		DKSG A 0 {
			if(
				!PressingReload()
				&&!PressingAltReload()
			)setweaponstate("reloadSSend");
			else if(
				invoker.weaponstatus[SHOTS_SIDESADDLE]<12
				&&countinv("HDBirdshotShellAmmo")
			)setweaponstate("ReloadSSrestart");
		}
	reloadSSend:
		DKSG A 3 offset(2,34);
		DKSG A 1 offset(1,34) EmptyDuckHand(careful:true);
		goto nope;
	hold:
		DKSG A 0{
			bool paf=pressingaltfire();
			if(
				paf&&!(invoker.weaponstatus[0]&DUCKHUNTF_ALTHOLDING)
			)setweaponstate("chamber");
			else if(!paf)invoker.weaponstatus[0]&=~DUCKHUNTF_ALTHOLDING;
		}
		DKSG A 1 A_WeaponReady(WRF_NONE);
		DKSG A 0 A_Refire();
		goto ready;
	fire:
		DKSG A 0 A_JumpIf(invoker.weaponstatus[DUCKHUNTS_CHAMBER]==2,"shoot");
		DKSG A 1 A_WeaponReady(WRF_NONE);
		DKSG A 0 A_Refire();
		goto ready;
	shoot:
		DKSG A 2;
		DKSG A 1 offset(0,36) A_FireHunter();
		DKSG E 1;
		DKSG E 0{
			if(
				invoker.weaponstatus[DUCKHUNTS_FIREMODE]>0
				&&invoker.shotpower>HUNTER_MINSHOTPOWER
			)setweaponstate("chamberauto");
		}goto ready;
	altfire:
	chamber:
		DKSG A 0 A_JumpIf(invoker.weaponstatus[0]&DUCKHUNTF_ALTHOLDING,"nope");
		DKSG A 0 A_SetAltHold(true);
		DKSG A 1 A_Overlay(120,"playsgco");
		DKSG AE 1 A_MuzzleClimb(0,frandom(0.6,1.));
		DKSG E 1 A_JumpIf(pressingaltfire(),"longstroke");
		DKSG EA 1 A_MuzzleClimb(0,-frandom(0.06,0.1));
		DKSG E 0 A_StartSound("weapons/duckshort",8);
		DKSG E 0 A_Refire("ready");
		goto ready;
	longstroke:
		DKSG F 2 A_MuzzleClimb(frandom(0.1,0.2));
		DKSG F 0{
			A_Chamber();
			A_MuzzleClimb(-frandom(0.1,0.2));
		}
	racked:
		DKSG F 1 A_WeaponReady(WRF_NOFIRE);
		DKSG F 0 A_JumpIf(!pressingaltfire(),"unrack");
		DKSG F 0 A_JumpIf(pressingunload(),"rackunload");
		DKSG F 0 A_JumpIf(invoker.weaponstatus[DUCKHUNTS_CHAMBER],"racked");
		DKSG F 0{
			int rld=0;
			if(pressingreload()){
				rld=1;
				if(invoker.weaponstatus[SHOTS_SIDESADDLE]>0)
				invoker.weaponstatus[0]&=~HUNTF_FROMPOCKETS;
				else{
					invoker.weaponstatus[0]|=HUNTF_FROMPOCKETS;
					rld=2;
				}
			}else if(pressingaltreload()){
				rld=2;
				invoker.weaponstatus[0]|=HUNTF_FROMPOCKETS;
			}
			if(
				(rld==2&&countinv("HDBirdshotShellAmmo"))
				||(rld==1&&invoker.weaponstatus[SHOTS_SIDESADDLE]>0)
			)setweaponstate("rackreload");
		}
		loop;
	rackreload:
		DKSG F 1 offset(-1,35) A_WeaponBusy(true);
		DKSG F 2 offset(-2,37);
		DKSG F 4 offset(-3,40);
		DKSG F 1 offset(-4,42) A_GrabShells(1,true,true);
		DKSG F 0 A_JumpIf(!(invoker.weaponstatus[0]&HUNTF_FROMPOCKETS),"rackloadone");
		DKSG F 6 offset(-5,43);
		DKSG F 6 offset(-4,41) A_StartSound("weapons/pocket",9);
	rackloadone:
		DKSG F 1 offset(-4,42);
		DKSG F 2 offset(-4,41);
		DKSG F 3 offset(-4,40){
			A_StartSound("weapons/duckreload",8,CHANF_OVERLAP);
			invoker.weaponstatus[DUCKHUNTS_CHAMBER]=2;
			invoker.handshells--;
			EmptyHand(careful:true);
		}
		DKSG F 5 offset(-4,41);
		DKSG F 4 offset(-4,40) A_JumpIf(invoker.handshells>0,"rackloadone");
		goto rackreloadend;
	rackreloadend:
		DKSG F 1 offset(-3,39);
		DKSG F 1 offset(-2,37);
		DKSG F 1 offset(-1,34);
		DKSG F 0 A_WeaponBusy(false);
		goto racked;

	rackunload:
		DKSG F 1 offset(-1,35) A_WeaponBusy(true);
		DKSG F 2 offset(-2,37);
		DKSG F 4 offset(-3,40);
		DKSG F 1 offset(-4,42);
		DKSG F 2 offset(-4,41);
		DKSG F 3 offset(-4,40){
			int chm=invoker.weaponstatus[DUCKHUNTS_CHAMBER];
			invoker.weaponstatus[DUCKHUNTS_CHAMBER]=0;
			if(chm==2){
				invoker.handshells++;
				EmptyDuckHand(careful:true);
			}else if(chm==1)A_SpawnItemEx("HDSpentBirdshotShell",
				cos(pitch)*8,0,height-7-sin(pitch)*8,
				vel.x+cos(pitch)*cos(angle-random(86,90))*5,
				vel.y+cos(pitch)*sin(angle-random(86,90))*5,
				vel.z+sin(pitch)*random(4,6),
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
			);
			if(chm)A_StartSound("weapons/duckreload",8,CHANF_OVERLAP);
		}
		DKSG F 5 offset(-4,41);
		DKSG F 4 offset(-4,40) A_JumpIf(invoker.handshells>0,"rackloadone");
		goto rackreloadend;

	unrack:
		DKSG F 0 A_Overlay(120,"playsgco2");
		DKSG E 1 A_JumpIf(!pressingfire(),1);
		DKSG EA 2{
			if(pressingfire())A_SetTics(1);
			A_MuzzleClimb(0,-frandom(0.6,1.));
		}
		DKSG A 0 A_ClearRefire();
		goto ready;
	playsgco:
		TNT1 A 8 A_StartSound("weapons/duckrackup",8);
		TNT1 A 0 A_StopSound(8);
		stop;
	playsgco2:
		TNT1 A 8 A_StartSound("weapons/duckrackdown",8);
		TNT1 A 0 A_StopSound(8);
		stop;
	chamberauto:
		DKSG A 1 A_Chamber();
		DKSG A 1 A_JumpIf(invoker.weaponstatus[0]&DUCKHUNTF_CANFULLAUTO&&invoker.weaponstatus[HUNTS_FIREMODE]==2,"ready");
		DKSG A 0 A_Refire();
		goto ready;
	flash:
		DKSF A 1 bright{
			A_Light2();
			HDFlashAlpha(-32);
		}
		TNT1 A 1 A_ZoomRecoil(0.9);
		TNT1 A 0 A_Light0();
		TNT1 A 0 A_AlertMonsters();
		stop;
	altreload:
	reloadfrompockets:
		DKSG A 0{
			if(!countinv("HDBirdshotShellAmmo"))setweaponstate("nope");
			else invoker.weaponstatus[0]|=HUNTF_FROMPOCKETS;
		}goto startreload;
	reload:
	reloadfromsidesaddles:
		DKSG A 0{
			int sss=invoker.weaponstatus[SHOTS_SIDESADDLE];
			int ppp=countinv("HDBirdshotShellAmmo");
			if(ppp<1&&sss<1)setweaponstate("nope");
				else if(sss<1)
					invoker.weaponstatus[0]|=HUNTF_FROMPOCKETS;
				else invoker.weaponstatus[0]&=~HUNTF_FROMPOCKETS;
		}goto startreload;
	startreload:
		DKSG A 1{
			if(
				invoker.weaponstatus[DUCKHUNTS_TUBE]>=invoker.weaponstatus[DUCKHUNTS_TUBESIZE]
			){
				if(
					invoker.weaponstatus[SHOTS_SIDESADDLE]<12
					&&countinv("HDBirdshotShellAmmo")
				)setweaponstate("ReloadSS");
				else setweaponstate("nope");
			}
		}
		DKSG AB 4 A_MuzzleClimb(frandom(.6,.7),-frandom(.6,.7));
	reloadstarthand:
		DKSG C 1 offset(0,36);
		DKSG C 1 offset(0,38);
		DKSG C 2 offset(0,36);
		DKSG C 2 offset(0,34);
		DKSG C 3 offset(0,36);
		DKSG C 3 offset(0,40) A_CheckPocketSaddles();
		DKSG C 0 A_JumpIf(invoker.weaponstatus[0]&HUNTF_FROMPOCKETS,"reloadpocket");
	reloadfast:
		DKSG C 3 offset(0,40) A_GrabShells(3,false);
		DKSG C 3 offset(0,42) A_StartSound("weapons/pocket",9,volume:0.4);
		DKSG C 2 offset(0,41);
		goto reloadashell;
	reloadpocket:
		DKSG C 3 offset(0,39) A_GrabShells(3,false);
		DKSG C 5 offset(0,42) A_StartSound("weapons/pocket",9);
		DKSG C 6 offset(0,41) A_StartSound("weapons/pocket",9);
		DKSG C 4 offset(0,40);
		goto reloadashell;
	reloadashell:
		DKSG C 2 offset(0,36);
		DKSG C 4 offset(0,34)A_LoadTubeFromHand();
		DKSG CCCCCC 1 offset(0,33){
			if(
				PressingReload()
				||PressingAltReload()
				||PressingUnload()
				||PressingFire()
				||PressingAltfire()
				||PressingZoom()
				||PressingFiremode()
			)invoker.weaponstatus[0]|=DUCKHUNTF_HOLDING;
			else invoker.weaponstatus[0]&=~DUCKHUNTF_HOLDING;

			if(
				invoker.weaponstatus[DUCKHUNTS_TUBE]>=invoker.weaponstatus[DUCKHUNTS_TUBESIZE]
				||(
					invoker.handshells<1&&(
						invoker.weaponstatus[0]&HUNTF_FROMPOCKETS
						||invoker.weaponstatus[SHOTS_SIDESADDLE]<1
					)&&
					!countinv("HDBirdshotShellAmmo")
				)
			)setweaponstate("reloadend");
			else if(
				!pressingaltreload()
				&&!pressingreload()
			)setweaponstate("reloadend");
			else if(invoker.handshells<1)setweaponstate("reloadstarthand");
		}goto reloadashell;
	reloadend:
		DKSG C 4 offset(0,34) A_StartSound("weapons/duckopen",8);
		DKSG C 1 offset(0,36) EmptyDuckHand(careful:true);
		DKSG C 1 offset(0,34);
		DKSG CBA 3;
		DKSG A 0 A_JumpIf(invoker.weaponstatus[0]&DUCKHUNTF_HOLDING,"nope");
		goto ready;

	cannibalize:
	//	DKSG A 2 offset(0,36) A_JumpIf(!countinv("Slayer"),"nope");
	//	DKSG A 2 offset(0,40) A_StartSound("weapons/pocket",9);
	//	DKSG A 6 offset(0,42);
	//	DKSG A 4 offset(0,44);
	//	DKSG A 6 offset(0,42);
	//	DKSG A 2 offset (0,36) A_CannibalizeOtherShotgun();
		goto ready;

	unloadSS:
		DKSG A 2 offset(1,34) A_JumpIf(invoker.weaponstatus[SHOTS_SIDESADDLE]<1,"nope");
		DKSG A 1 offset(2,34);
		DKSG A 1 offset(3,36);
	unloadSSLoop1:
		DKSG A 4 offset(4,36);
		DKSG A 2 offset(5,37) A_UnloadDuckSaddle();
		DKSG A 3 offset(4,36){	//decide whether to loop
			if(
				PressingReload()
				||PressingFire()
				||PressingAltfire()
				||invoker.weaponstatus[SHOTS_SIDESADDLE]<1
			)setweaponstate("unloadSSend");
		}goto unloadSSLoop1;
	unloadSSend:
		DKSG A 3 offset(4,35);
		DKSG A 2 offset(3,35);
		DKSG A 1 offset(2,34);
		DKSG A 1 offset(1,34);
		goto nope;
	unload:
		DKSG A 1{
			if(
				invoker.weaponstatus[SHOTS_SIDESADDLE]>0
				&&!(player.cmd.buttons&BT_USE)
			)setweaponstate("unloadSS");
			else if(
				invoker.weaponstatus[DUCKHUNTS_CHAMBER]<1
				&&invoker.weaponstatus[DUCKHUNTS_TUBE]<1
			)setweaponstate("nope");
		}
		DKSG BC 4 A_MuzzleClimb(frandom(1.2,2.4),-frandom(1.2,2.4));
		DKSG C 1 offset(0,34);
		DKSG C 1 offset(0,36) A_StartSound("weapons/duckopen",8);
		DKSG C 1 offset(0,38);
		DKSG C 4 offset(0,36){
			A_MuzzleClimb(-frandom(1.2,2.4),frandom(1.2,2.4));
			if(invoker.weaponstatus[DUCKHUNTS_CHAMBER]<1){
				setweaponstate("unloadtube");
			}else A_StartSound("weapons/duckrack",8,CHANF_OVERLAP);
		}
		DKSG D 8 offset(0,34){
			A_MuzzleClimb(-frandom(1.2,2.4),frandom(1.2,2.4));
			int chm=invoker.weaponstatus[DUCKHUNTS_CHAMBER];
			invoker.weaponstatus[DUCKHUNTS_CHAMBER]=0;
			if(chm>1){
				A_StartSound("weapons/duckreload",8);
				if(A_JumpIfInventory("HDBirdshotShellAmmo",0,"null"))A_SpawnItemEx("HDFumblingShell",
					cos(pitch)*8,0,height-7-sin(pitch)*8,
					vel.x+cos(pitch)*cos(angle-random(86,90))*5,
					vel.y+cos(pitch)*sin(angle-random(86,90))*5,
					vel.z+sin(pitch)*random(4,6),
					0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
				);else{
					HDF.Give(self,"HDBirdshotShellAmmo",1);
					A_StartSound("weapons/pocket",9);
					A_SetTics(5);
				}
			}else if(chm>0)A_SpawnItemEx("HDSpentBirdshotShell",
				cos(pitch)*8,0,height-7-sin(pitch)*8,
				vel.x+cos(pitch)*cos(angle-random(86,90))*5,
				vel.y+cos(pitch)*sin(angle-random(86,90))*5,
				vel.z+sin(pitch)*random(4,6),
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
			);
		}
		DKSG C 0 A_JumpIf(!pressingunload(),"reloadend");
		DKSG C 4 offset(0,40);
	unloadtube:
		DKSG C 6 offset(0,40) EmptyDuckHand(careful:true);
	unloadloop:
		DKSG C 8 offset(1,41){
			if(invoker.weaponstatus[DUCKHUNTS_TUBE]<1)setweaponstate("reloadend");
			else if(invoker.handshells>=3)setweaponstate("unloadloopend");
			else{
				invoker.handshells++;
				invoker.weaponstatus[DUCKHUNTS_TUBE]--;
			}
		}
		DKSG C 4 offset(0,40) A_StartSound("weapons/duckreload",8);
		loop;
	unloadloopend:
		DKSG C 6 offset(1,41);
		DKSG C 3 offset(1,42){
			int rmm=HDPickup.MaxGive(self,"HDBirdshotShellAmmo",ENC_SHELL);
			if(rmm>0){
				A_StartSound("weapons/pocket",9);
				A_SetTics(8);
				HDF.Give(self,"HDBirdshotShellAmmo",min(rmm,invoker.handshells));
				invoker.handshells=max(invoker.handshells-rmm,0);
			}
		}
		DKSG C 0 EmptyDuckHand(careful:true);
		DKSG C 6 A_Jumpif(!pressingunload(),"reloadend");
		goto unloadloop;
	spawn:
		DHNT ABCDEFG -1 nodelay{
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
		weaponstatus[DUCKHUNTS_CHAMBER]=2;
		if(!idfa){
			weaponstatus[DUCKHUNTS_TUBESIZE]=3;
			weaponstatus[DUCKHUNTS_CHOKE]=1;
		}
		weaponstatus[DUCKHUNTS_TUBE]=weaponstatus[HUNTS_TUBESIZE];
		weaponstatus[SHOTS_SIDESADDLE]=12;
		weaponstatus[DUCKHUNTS_FIREMODE]=0;
		handshells=0;
	}
	override void loadoutconfigure(string input){
	/*
		int type=getloadoutvar(input,"type",1);
		if(type>=0){
			switch(type){
			case 0:
				weaponstatus[0]|=DUCKHUNTF_EXPORT;
				weaponstatus[0]&=~DUCKHUNTF_CANFULLAUTO;
				break;
			case 1:
				weaponstatus[0]&=~DUCKHUNTF_EXPORT;
				weaponstatus[0]&=~DUCKHUNTF_CANFULLAUTO;
				break;
			case 2:
				weaponstatus[0]&=~DUCKHUNTF_EXPORT;
				weaponstatus[0]|=DUCKHUNTF_CANFULLAUTO;
				break;
			default:
				break;
			}
		}
		if(type<0||type>2)type=1;

		int firemode=getloadoutvar(input,"firemode",1);
		if(firemode>=0)weaponstatus[DUCKHUNTS_FIREMODE]=clamp(firemode,0,type);
	*/	
		int choke=min(getloadoutvar(input,"choke",1),7);
		if(choke>=0)weaponstatus[DUCKHUNTS_CHOKE]=choke;
    /*
		int tubesize=((weaponstatus[0]&DUCKHUNTF_EXPORT)?3:3);
		if(weaponstatus[DUCKHUNTS_TUBE]>tubesize)weaponstatus[HUNTS_TUBE]=tubesize;
		weaponstatus[DUCKHUNTS_TUBESIZE]=tubesize;
    */
	}
}
enum duckhunterstatus{
	DUCKHUNTF_CANFULLAUTO=1,
	DUCKHUNTF_JAMMED=2,
	DUCKHUNTF_UNLOADONLY=4,
	DUCKHUNTF_ALTHOLDING=16,
	DUCKHUNTF_HOLDING=32,
	DUCKHUNTF_EXPORT=64,

	DUCKHUNTS_FIREMODE=1,
	DUCKHUNTS_CHAMBER=2,
	//3 is for side saddles
	DUCKHUNTS_TUBE=4,
	DUCKHUNTS_TUBESIZE=5,
	DUCKHUNTS_HAND=6,
	DUCKHUNTS_CHOKE=7,
};

class DuckHunterRandom:IdleDummy{
	states{
	spawn:
		TNT1 A 0 nodelay{
			let ggg=DuckHunter(spawn("DuckHunter",pos,ALLOW_REPLACE));
			if(!ggg)return;
			HDF.TransferSpecials(self,ggg,HDF.TS_ALL);

			if(!random(0,7))ggg.weaponstatus[DUCKHUNTS_CHOKE]=random(0,7);
			
		}stop;
	}
}

