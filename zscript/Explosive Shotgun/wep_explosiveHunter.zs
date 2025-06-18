// ------------------------------------------------------------
// A 12-gauge pump for EXPLODING KNEES
// ------------------------------------------------------------
class ExplosiveHunter:HDShotgunExplosive{
	default{
		//$Category "Weapons/Hideous Destructor"
		//$Title "ExplosiveHunter"
		//$Sprite "HUNTA0"

		weapon.selectionorder 31;
		weapon.slotnumber 3;
		weapon.slotpriority 3;
		weapon.bobrangex 0.21;
		weapon.bobrangey 0.86;
		scale 0.6;
		hdweapon.barrelsize 30,0.5,2;
		hdweapon.refid "XSG";
		tag "$TAG_EXPLOSIVESHOTGUN";
		obituary "$OB_EXPLSHOTGUN";

		hdweapon.loadoutcodes "
			\cufiremode - 0-1, pump/semi";
	}

	//returns the power of the load just fired
	static double Fire(actor caller,int choke=1){
		double spread=6.;
		double speedfactor=1.;
		let hhh=ExplosiveHunter(caller.findinventory("ExplosiveHunter"));
		if(hhh)choke=hhh.weaponstatus[EXHUNTS_CHOKE];

		choke=7;
		spread=6.5-0.5*choke;
		speedfactor=1.+0.02857*choke;

		double shotpower=getshotpower();
		spread*=shotpower;
		speedfactor*=shotpower;
		HDBulletActor.FireBullet(caller,"HDB_wad");
		let p=HDBulletActor.FireBullet(caller,"HDB_12GuageSlugMissile",
			spread:spread,speedfactor:speedfactor,amount:1
		);
		distantnoise.make(p,"weapons/esg_firefar");
		caller.A_StartSound("weapons/esg_fire",CHAN_WEAPON);
		return shotpower;
	}
	const EXHUNTER_MINSHOTPOWER=0.901;

	action void A_FireExplosiveHunter(){
		double shotpower=invoker.Fire(self);
		A_GunFlash();
		vector2 shotrecoil=(randompick(-1,1),-2.6);
		if(invoker.weaponstatus[EXHUNTS_FIREMODE]>0)shotrecoil=(randompick(-1,1)*1.4,-3.4);
		shotrecoil*=shotpower;
		A_MuzzleClimb(0,0,shotrecoil.x,shotrecoil.y,randompick(-1,1)*shotpower,-0.3*shotpower);
		invoker.weaponstatus[EXHUNTS_CHAMBER]=1;
		invoker.shotpower=shotpower;
	}

	// I don't think any of these are used but the last one but oh well might as well do it. - [Ted]
	override string pickupmessage(){
		if(weaponstatus[0]&EXHUNTF_CANFULLAUTO)return Stringtable.Localize("$PICKUP_EXPLOSIVEHUNTER3");
		else if(weaponstatus[0]&EXHUNTF_EXPORT)return Stringtable.Localize("$PICKUP_EXPLOSIVEHUNTER2");
		return Stringtable.Localize("$PICKUP_EXPLOSIVEHUNTER1");
	}

override void failedpickupunload(){
		int sss=weaponstatus[EXSHOTS_SIDESADDLE];
		if(sss<1)return;
		A_StartSound("weapons/pocket",9);
		int dropamt=min(sss,4);
		A_DropItem("HDExplosiveShellAmmo",dropamt);
		weaponstatus[EXSHOTS_SIDESADDLE]-=dropamt;
		setstatelabel("spawn");
	}
	override void DropOneAmmo(int amt){
		if(owner){
			amt=clamp(amt,1,10);
			owner.A_DropInventory("HDExplosiveShellAmmo",amt*4);
		}
	}
	override void ForceBasicAmmo(){
		owner.A_SetInventory("HDExplosiveShellAmmo",20);
	}

	override string,double getpickupsprite(bool usespare){return "XLSP"..getpickupframe(usespare).."0",1.;}
	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
			sb.drawimage("XLS1A0",(-47,-10),basestatusbar.DI_SCREEN_CENTER_BOTTOM);
			sb.drawnum(hpl.countinv("HDExplosiveShellAmmo"),-46,-8,
				basestatusbar.DI_SCREEN_CENTER_BOTTOM
			);
		}
		if(hdw.weaponstatus[EXHUNTS_CHAMBER]>1){
			sb.drawrect(-24,-14,5,3);
			sb.drawrect(-18,-14,2,3);
		}
		else if(hdw.weaponstatus[EXHUNTS_CHAMBER]>0){
			sb.drawrect(-18,-14,2,3);
		}
		if(!(hdw.weaponstatus[0]&EXHUNTF_EXPORT))sb.drawwepcounter(hdw.weaponstatus[EXHUNTS_FIREMODE],
			-26,-12,"blank","RBRSA3A7","STFULAUT"
		);
		sb.drawwepnum(hdw.weaponstatus[EXHUNTS_TUBE],hdw.weaponstatus[EXHUNTS_TUBESIZE],posy:-7);
		for(int i=hdw.weaponstatus[EXSHOTS_SIDESADDLE];i>0;i--){
			sb.drawrect(-16-i*2,-5,1,3);
		}
	}
	override string gethelptext(){
		return
		LWPHELP_FIRE.."  Shoot\n"
		..LWPHELP_ALTFIRE.."  Pump\n"
		..LWPHELP_RELOAD.."  Reload (side saddles first)\n"
		..LWPHELP_ALTRELOAD.."  Reload (pockets only)\n"
		..(weaponstatus[0]&EXHUNTF_EXPORT?"":(LWPHELP_FIREMODE.."  Pump/Semi"..(weaponstatus[0]&EXHUNTF_CANFULLAUTO?"/Auto":"").."\n"))
		..LWPHELP_FIREMODE.."+"..LWPHELP_RELOAD.."  Load side saddles\n"
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
//		bobb.y=clamp(bobb.y,-8,8);
		sb.drawimage(
			"redfsite",(0,0)+bobb,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP
		);
		sb.SetClipRect(cx,cy,cw,ch);
		sb.drawimage(
			"redbsite",(0,0)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			alpha:0.9
		);
	}
	override double gunmass(){
		int tube=weaponstatus[EXHUNTS_TUBE];
		if(tube>4)tube+=(tube-4)*2;
		return 8+tube*0.3+weaponstatus[EXSHOTS_SIDESADDLE]*0.08;
	}
	override double weaponbulk(){
		return 125+(weaponstatus[EXSHOTS_SIDESADDLE]+weaponstatus[EXHUNTS_TUBE])*ENC_SHELLLOADED;
	}
	action void A_SwitchFireMode(bool forwards=true){
		if(invoker.weaponstatus[0]&EXHUNTF_EXPORT){
			invoker.weaponstatus[EXHUNTS_FIREMODE]=0;
			return;
		}
		int newfm=invoker.weaponstatus[EXHUNTS_FIREMODE]+(forwards?1:-1);
		int newmax=(invoker.weaponstatus[0]&EXHUNTF_CANFULLAUTO)?2:1;
		if(newfm>newmax)newfm=0;
		else if(newfm<0)newfm=newmax;
		invoker.weaponstatus[EXHUNTS_FIREMODE]=newfm;
	}
	action void A_SetAltHold(bool which){
		if(which)invoker.weaponstatus[0]|=EXHUNTF_ALTHOLDING;
		else invoker.weaponstatus[0]&=~EXHUNTF_ALTHOLDING;
	}
	action void A_Chamber(bool careful=false){
		int chm=invoker.weaponstatus[EXHUNTS_CHAMBER];
		invoker.weaponstatus[EXHUNTS_CHAMBER]=0;
		if(invoker.weaponstatus[EXHUNTS_TUBE]>0){
			invoker.weaponstatus[EXHUNTS_CHAMBER]=2;
			invoker.weaponstatus[EXHUNTS_TUBE]--;
		}
		vector3 cockdir;double cp=cos(pitch);
		if(careful)cockdir=(-cp,cp,-5);
		else cockdir=(0,-cp*5,sin(pitch)*frandom(4,6));
		cockdir.xy=rotatevector(cockdir.xy,angle);
		actor fbs;bool gbg;
		if(chm>1){
			if(careful&&!A_JumpIfInventory("HDExplosiveShellAmmo",0,"null")){
				HDF.Give(self,"HDExplosiveShellAmmo",1);
			}else{
				[gbg,fbs]=A_SpawnItemEx("HDFumblingExplosiveShell",
					cos(pitch)*8,0,height-8-sin(pitch)*8,
					vel.x+cockdir.x,vel.y+cockdir.y,vel.z+cockdir.z,
					0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
				);
			}
		}else if(chm>0){	
			cockdir*=frandom(1.,1.3);
			[gbg,fbs]=A_SpawnItemEx("HDSpentExplosiveShell",
				cos(pitch)*8,frandom(-0.1,0.1),height-8-sin(pitch)*8,
				vel.x+cockdir.x,vel.y+cockdir.y,vel.z+cockdir.z,
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
			);
		}
	}
	action void A_CheckPocketSaddles(){
		if(invoker.weaponstatus[EXSHOTS_SIDESADDLE]<1)invoker.weaponstatus[0]|=EXHUNTF_FROMPOCKETS;
		if(!countinv("HDExplosiveShellAmmo"))invoker.weaponstatus[0]&=~EXHUNTF_FROMPOCKETS;
	}
	action bool A_LoadTubeFromHand(){
		int hand=invoker.exhandshells;
		if(
			!hand
			||(
				invoker.weaponstatus[EXHUNTS_CHAMBER]>0
				&&invoker.weaponstatus[EXHUNTS_TUBE]>=invoker.weaponstatus[EXHUNTS_TUBESIZE]
			)
		){
			ExEmptyHand();
			return false;
		}
		invoker.weaponstatus[EXHUNTS_TUBE]++;
		invoker.exhandshells--;
		A_StartSound("weapons/esg_reload",8,CHANF_OVERLAP);
		return true;
	}
	action bool A_GrabShells(int maxhand=3,bool settics=false,bool alwaysone=false){
		if(maxhand>0)ExEmptyHand();else maxhand=abs(maxhand);
		bool fromsidesaddles=!(invoker.weaponstatus[0]&EXHUNTF_FROMPOCKETS);
		int toload=min(
			fromsidesaddles?invoker.weaponstatus[EXSHOTS_SIDESADDLE]:countinv("HDExplosiveShellAmmo"),
			alwaysone?1:(invoker.weaponstatus[EXHUNTS_TUBESIZE]-invoker.weaponstatus[EXHUNTS_TUBE]),
			max(1,health/22),
			maxhand
		);
		if(toload<1)return false;
		invoker.exhandshells=toload;
		if(fromsidesaddles){
			invoker.weaponstatus[EXSHOTS_SIDESADDLE]-=toload;
			if(settics)A_SetTics(2);
			A_StartSound("weapons/pocket",8,CHANF_OVERLAP,0.4);
			A_MuzzleClimb(
				frandom(0.1,0.15),frandom(0.05,0.08),
				frandom(0.1,0.15),frandom(0.05,0.08)
			);
		}else{
			A_TakeInventory("HDExplosiveShellAmmo",toload,TIF_NOTAKEINFINITE);
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
		XLSG A 0;
		goto select0big;
	deselect0:
		XLSG A 0;
		goto deselect0big;
	firemode:
		XLSG A 0 a_switchfiremode();
	firemodehold:
		---- A 1{
			if(pressingreload()){
				a_switchfiremode(false); //untoggle
				setweaponstate("reloadss");
			}else A_WeaponReady(WRF_NONE);
		}
		---- A 0 A_JumpIf(pressingfiremode()&&invoker.weaponstatus[EXSHOTS_SIDESADDLE]<12,"firemodehold");
		goto nope;
	ready:
		//XLSG A 0 A_JumpIf(pressingunload()&&(pressinguse()||pressingzoom()),"cannibalize");
		XLSG A 0 A_JumpIf(pressingaltfire(),2);
		XLSG A 0{
			if(!pressingaltfire()){
				if(!pressingfire())A_ClearRefire();
				A_SetAltHold(false);
			}
		}
		XLSG A 1 A_WeaponReady(WRF_ALL);
		goto readyend;
	reloadSS:
		XLSG A 1 offset(1,34);
		XLSG A 2 offset(2,34);
		XLSG A 3 offset(3,36);
	reloadSSrestart:
		XLSG A 6 offset(3,35);
		XLSG A 9 offset(4,34);
		XLSG A 4 offset(3,34){
			int hnd=min(
				countinv("HDExplosiveShellAmmo"),
				12-invoker.weaponstatus[EXSHOTS_SIDESADDLE],
				max(1,health/22),
				3
			);
			if(hnd<1)setweaponstate("reloadSSend");
			else{
				A_TakeInventory("HDExplosiveShellAmmo",hnd);
				invoker.weaponstatus[EXSHOTS_SIDESADDLE]+=hnd;
				A_StartSound("weapons/pocket",8);
			}
		}
		XLSG A 0 {
			if(
				!PressingReload()
				&&!PressingAltReload()
			)setweaponstate("reloadSSend");
			else if(
				invoker.weaponstatus[EXSHOTS_SIDESADDLE]<12
				&&countinv("HDExplosiveShellAmmo")
			)setweaponstate("ReloadSSrestart");
		}
	reloadSSend:
		XLSG A 3 offset(2,34);
		XLSG A 1 offset(1,34) ExEmptyHand(careful:true);
		goto nope;
	hold:
		XLSG A 0{
			bool paf=pressingaltfire();
			if(
				paf&&!(invoker.weaponstatus[0]&EXHUNTF_ALTHOLDING)
			)setweaponstate("chamber");
			else if(!paf)invoker.weaponstatus[0]&=~EXHUNTF_ALTHOLDING;
		}
		XLSG A 1 A_WeaponReady(WRF_NONE);
		XLSG A 0 A_Refire();
		goto ready;
	fire:
		XLSG A 0 A_JumpIf(invoker.weaponstatus[EXHUNTS_CHAMBER]==2,"shoot");
		XLSG A 1 A_WeaponReady(WRF_NONE);
		XLSG A 0 A_Refire();
		goto ready;
	shoot:
		XLSG A 2;
		XLSG A 1 offset(0,36) A_FireExplosiveHunter();
		XLSG E 1;
		XLSG E 0{
			if(
				invoker.weaponstatus[EXHUNTS_FIREMODE]>0
				&&invoker.shotpower>EXHUNTER_MINSHOTPOWER
			)setweaponstate("chamberauto");
		}goto ready;
	altfire:
	chamber:
		XLSG A 0 A_JumpIf(invoker.weaponstatus[0]&EXHUNTF_ALTHOLDING,"nope");
		XLSG A 0 A_SetAltHold(true);
		XLSG A 1 A_Overlay(120,"playsgco");
		XLSG AE 1 A_MuzzleClimb(0,frandom(0.6,1.));
		XLSG E 1 A_JumpIf(pressingaltfire(),"longstroke");
		XLSG EA 1 A_MuzzleClimb(0,-frandom(0.6,1.));
		XLSG E 0 A_StartSound("weapons/esg_short",8);
		XLSG E 0 A_Refire("ready");
		goto ready;
	longstroke:
		XLSG F 2 A_MuzzleClimb(frandom(1.,2.));
		XLSG F 0{
			A_Chamber();
			A_MuzzleClimb(-frandom(1.,2.));
		}
	racked:
		XLSG F 1 A_WeaponReady(WRF_NOFIRE);
		XLSG F 0 A_JumpIf(!pressingaltfire(),"unrack");
		XLSG F 0 A_JumpIf(pressingunload(),"rackunload");
		XLSG F 0 A_JumpIf(invoker.weaponstatus[EXHUNTS_CHAMBER],"racked");
		XLSG F 0{
			int rld=0;
			if(pressingreload()){
				rld=1;
				if(invoker.weaponstatus[EXSHOTS_SIDESADDLE]>0)
				invoker.weaponstatus[0]&=~EXHUNTF_FROMPOCKETS;
				else{
					invoker.weaponstatus[0]|=EXHUNTF_FROMPOCKETS;
					rld=2;
				}
			}else if(pressingaltreload()){
				rld=2;
				invoker.weaponstatus[0]|=EXHUNTF_FROMPOCKETS;
			}
			if(
				(rld==2&&countinv("HDExplosiveShellAmmo"))
				||(rld==1&&invoker.weaponstatus[EXSHOTS_SIDESADDLE]>0)
			)setweaponstate("rackreload");
		}
		loop;
	rackreload:
		XLSG F 1 offset(-1,35) A_WeaponBusy(true);
		XLSG F 2 offset(-2,37);
		XLSG F 4 offset(-3,40);
		XLSG F 1 offset(-4,42) A_GrabShells(1,true,true);
		XLSG F 0 A_JumpIf(!(invoker.weaponstatus[0]&EXHUNTF_FROMPOCKETS),"rackloadone");
		XLSG F 6 offset(-5,43);
		XLSG F 6 offset(-4,41) A_StartSound("weapons/pocket",9);
	rackloadone:
		XLSG F 1 offset(-4,42);
		XLSG F 2 offset(-4,41);
		XLSG F 3 offset(-4,40){
			A_StartSound("weapons/esg_reload",8,CHANF_OVERLAP);
			invoker.weaponstatus[EXHUNTS_CHAMBER]=2;
			invoker.exhandshells--;
			ExEmptyHand(careful:true);
		}
		XLSG F 5 offset(-4,41);
		XLSG F 4 offset(-4,40) A_JumpIf(invoker.exhandshells>0,"rackloadone");
		goto rackreloadend;
	rackreloadend:
		XLSG F 1 offset(-3,39);
		XLSG F 1 offset(-2,37);
		XLSG F 1 offset(-1,34);
		XLSG F 0 A_WeaponBusy(false);
		goto racked;

	rackunload:
		XLSG F 1 offset(-1,35) A_WeaponBusy(true);
		XLSG F 2 offset(-2,37);
		XLSG F 4 offset(-3,40);
		XLSG F 1 offset(-4,42);
		XLSG F 2 offset(-4,41);
		XLSG F 3 offset(-4,40){
			int chm=invoker.weaponstatus[EXHUNTS_CHAMBER];
			invoker.weaponstatus[EXHUNTS_CHAMBER]=0;
			if(chm==2){
				invoker.exhandshells++;
				ExEmptyHand(careful:true);
			}else if(chm==1)A_SpawnItemEx("HDSpentExplosiveShell",
				cos(pitch)*8,0,height-7-sin(pitch)*8,
				vel.x+cos(pitch)*cos(angle-random(86,90))*5,
				vel.y+cos(pitch)*sin(angle-random(86,90))*5,
				vel.z+sin(pitch)*random(4,6),
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
			);
			if(chm)A_StartSound("weapons/esg_reload",8,CHANF_OVERLAP);
		}
		XLSG F 5 offset(-4,41);
		XLSG F 4 offset(-4,40) A_JumpIf(invoker.exhandshells>0,"rackloadone");
		goto rackreloadend;

	unrack:
		XLSG F 0 A_Overlay(120,"playsgco2");
		XLSG E 1 A_JumpIf(!pressingfire(),1);
		XLSG EA 2{
			if(pressingfire())A_SetTics(1);
			A_MuzzleClimb(0,-frandom(0.6,1.));
		}
		XLSG A 0 A_ClearRefire();
		goto ready;
	playsgco:
		TNT1 A 8 A_StartSound("weapons/esg_rackup",8);
		TNT1 A 0 A_StopSound(8);
		stop;
	playsgco2:
		TNT1 A 8 A_StartSound("weapons/esg_rackdown",8);
		TNT1 A 0 A_StopSound(8);
		stop;
	chamberauto:
		XLSG A 1 A_Chamber();
		XLSG A 1 A_JumpIf(invoker.weaponstatus[0]&EXHUNTF_CANFULLAUTO&&invoker.weaponstatus[EXHUNTS_FIREMODE]==2,"ready");
		XLSG A 0 A_Refire();
		goto ready;
	flash:
		SHTF B 1 bright{
			A_Light2();
			HDFlashAlpha(-32);
		}
		TNT1 A 1 A_ZoomRecoil(0.9);
		TNT1 A 0 A_Light0();
		TNT1 A 0 A_AlertMonsters();
		stop;
	altreload:
	reloadfrompockets:
		XLSG A 0{
			if(!countinv("HDExplosiveShellAmmo"))setweaponstate("nope");
			else invoker.weaponstatus[0]|=EXHUNTF_FROMPOCKETS;
		}goto startreload;
	reload:
	reloadfromsidesaddles:
		XLSG A 0{
			int sss=invoker.weaponstatus[EXSHOTS_SIDESADDLE];
			int ppp=countinv("HDExplosiveShellAmmo");
			if(ppp<1&&sss<1)setweaponstate("nope");
				else if(sss<1)
					invoker.weaponstatus[0]|=EXHUNTF_FROMPOCKETS;
				else invoker.weaponstatus[0]&=~EXHUNTF_FROMPOCKETS;
		}goto startreload;
	startreload:
		XLSG A 1{
			if(
				invoker.weaponstatus[EXHUNTS_TUBE]>=invoker.weaponstatus[EXHUNTS_TUBESIZE]
			){
				if(
					invoker.weaponstatus[EXSHOTS_SIDESADDLE]<12
					&&countinv("HDExplosiveShellAmmo")
				)setweaponstate("ReloadSS");
				else setweaponstate("nope");
			}
		}
		XLSG AB 4 A_MuzzleClimb(frandom(.6,.7),-frandom(.6,.7));
	reloadstarthand:
		XLSG C 1 offset(0,36);
		XLSG C 1 offset(0,38);
		XLSG C 2 offset(0,36);
		XLSG C 2 offset(0,34);
		XLSG C 3 offset(0,36);
		XLSG C 3 offset(0,40) A_CheckPocketSaddles();
		XLSG C 0 A_JumpIf(invoker.weaponstatus[0]&EXHUNTF_FROMPOCKETS,"reloadpocket");
	reloadfast:
		XLSG C 4 offset(0,40) A_GrabShells(3,false);
		XLSG C 3 offset(0,42) A_StartSound("weapons/pocket",9,volume:0.4);
		XLSG C 3 offset(0,41);
		goto reloadashell;
	reloadpocket:
		XLSG C 4 offset(0,39) A_GrabShells(3,false);
		XLSG C 4 offset(0,40) A_StartSound("weapons/pocket",9);
		XLSG C 8 offset(0,42) A_StartSound("weapons/pocket",9);
		XLSG C 6 offset(0,41) A_StartSound("weapons/pocket",9);
		XLSG C 6 offset(0,40);
		goto reloadashell;
	reloadashell:
		XLSG C 2 offset(0,36);
		XLSG C 4 offset(0,34)A_LoadTubeFromHand();
		XLSG CCCCCC 1 offset(0,33){
			if(
				PressingReload()
				||PressingAltReload()
				||PressingUnload()
				||PressingFire()
				||PressingAltfire()
				||PressingZoom()
				||PressingFiremode()
			)invoker.weaponstatus[0]|=EXHUNTF_HOLDING;
			else invoker.weaponstatus[0]&=~EXHUNTF_HOLDING;

			if(
				invoker.weaponstatus[EXHUNTS_TUBE]>=invoker.weaponstatus[EXHUNTS_TUBESIZE]
				||(
					invoker.exhandshells<1&&(
						invoker.weaponstatus[0]&EXHUNTF_FROMPOCKETS
						||invoker.weaponstatus[EXSHOTS_SIDESADDLE]<1
					)&&
					!countinv("HDExplosiveShellAmmo")
				)
			)setweaponstate("reloadend");
			else if(
				!pressingaltreload()
				&&!pressingreload()
			)setweaponstate("reloadend");
			else if(invoker.exhandshells<1)setweaponstate("reloadstarthand");
		}goto reloadashell;
	reloadend:
		XLSG C 4 offset(0,34) A_StartSound("weapons/esg_open",8);
		XLSG C 1 offset(0,36) ExEmptyHand(careful:true);
		XLSG C 1 offset(0,34);
		XLSG CBA 3;
		XLSG A 0 A_JumpIf(invoker.weaponstatus[0]&EXHUNTF_HOLDING,"nope");
		goto ready;

/*
	cannibalize:
		XLSG A 2 offset(0,36) A_JumpIf(!countinv("Slayer"),"nope");
		XLSG A 2 offset(0,40) A_StartSound("weapons/pocket",9);
		XLSG A 6 offset(0,42);
		XLSG A 4 offset(0,44);
		XLSG A 6 offset(0,42);
		XLSG A 2 offset (0,36) A_CannibalizeOtherShotgun();
		goto ready;
*/

	unloadSS:
		XLSG A 2 offset(1,34) A_JumpIf(invoker.weaponstatus[EXSHOTS_SIDESADDLE]<1,"nope");
		XLSG A 1 offset(2,34);
		XLSG A 1 offset(3,36);
	unloadSSLoop1:
		XLSG A 4 offset(4,36);
		XLSG A 2 offset(5,37) A_ExUnloadSideSaddle();
		XLSG A 3 offset(4,36){	//decide whether to loop
			if(
				PressingReload()
				||PressingFire()
				||PressingAltfire()
				||invoker.weaponstatus[EXSHOTS_SIDESADDLE]<1
			)setweaponstate("unloadSSend");
		}goto unloadSSLoop1;
	unloadSSend:
		XLSG A 3 offset(4,35);
		XLSG A 2 offset(3,35);
		XLSG A 1 offset(2,34);
		XLSG A 1 offset(1,34);
		goto nope;
	unload:
		XLSG A 1{
			if(
				invoker.weaponstatus[EXSHOTS_SIDESADDLE]>0
				&&!(player.cmd.buttons&BT_USE)
			)setweaponstate("unloadSS");
			else if(
				invoker.weaponstatus[EXHUNTS_CHAMBER]<1
				&&invoker.weaponstatus[EXHUNTS_TUBE]<1
			)setweaponstate("nope");
		}
		XLSG BC 4 A_MuzzleClimb(frandom(1.2,2.4),-frandom(1.2,2.4));
		XLSG C 1 offset(0,34);
		XLSG C 1 offset(0,36) A_StartSound("weapons/esg_open",8);
		XLSG C 1 offset(0,38);
		XLSG C 4 offset(0,36){
			A_MuzzleClimb(-frandom(1.2,2.4),frandom(1.2,2.4));
			if(invoker.weaponstatus[EXHUNTS_CHAMBER]<1){
				setweaponstate("unloadtube");
			}else A_StartSound("weapons/esg_rack",8,CHANF_OVERLAP);
		}
		XLSG D 8 offset(0,34){
			A_MuzzleClimb(-frandom(1.2,2.4),frandom(1.2,2.4));
			int chm=invoker.weaponstatus[EXHUNTS_CHAMBER];
			invoker.weaponstatus[EXHUNTS_CHAMBER]=0;
			if(chm>1){
				A_StartSound("weapons/esg_reload",8);
				if(A_JumpIfInventory("HDExplosiveShellAmmo",0,"null"))A_SpawnItemEx("HDFumblingExplosiveShell",
					cos(pitch)*8,0,height-7-sin(pitch)*8,
					vel.x+cos(pitch)*cos(angle-random(86,90))*5,
					vel.y+cos(pitch)*sin(angle-random(86,90))*5,
					vel.z+sin(pitch)*random(4,6),
					0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
				);else{
					HDF.Give(self,"HDExplosiveShellAmmo",1);
					A_StartSound("weapons/pocket",9);
					A_SetTics(5);
				}
			}else if(chm>0)A_SpawnItemEx("HDSpentExplosiveShell",
				cos(pitch)*8,0,height-7-sin(pitch)*8,
				vel.x+cos(pitch)*cos(angle-random(86,90))*5,
				vel.y+cos(pitch)*sin(angle-random(86,90))*5,
				vel.z+sin(pitch)*random(4,6),
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
			);
		}
		XLSG C 0 A_JumpIf(!pressingunload(),"reloadend");
		XLSG C 4 offset(0,40);
	unloadtube:
		XLSG C 6 offset(0,40) ExEmptyHand(careful:true);
	unloadloop:
		XLSG C 8 offset(1,41){
			if(invoker.weaponstatus[EXHUNTS_TUBE]<1)setweaponstate("reloadend");
			else if(invoker.exhandshells>=3)setweaponstate("unloadloopend");
			else{
				invoker.exhandshells++;
				invoker.weaponstatus[EXHUNTS_TUBE]--;
			}
		}
		XLSG C 4 offset(0,40) A_StartSound("weapons/esg_reload",8);
		loop;
	unloadloopend:
		XLSG C 6 offset(1,41);
		XLSG C 3 offset(1,42){
			int rmm=HDPickup.MaxGive(self,"HDExplosiveShellAmmo",ENC_SHELL);
			if(rmm>0){
				A_StartSound("weapons/pocket",9);
				A_SetTics(8);
				HDF.Give(self,"HDExplosiveShellAmmo",min(rmm,invoker.exhandshells));
				invoker.exhandshells=max(invoker.exhandshells-rmm,0);
			}
		}
		XLSG C 0 ExEmptyHand(careful:true);
		XLSG C 6 A_Jumpif(!pressingunload(),"reloadend");
		goto unloadloop;
	spawn:
		XLSP ABCDEFG -1 nodelay{
			int ssh=invoker.weaponstatus[EXSHOTS_SIDESADDLE];
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
		weaponstatus[EXHUNTS_CHAMBER]=2;
		if(!idfa){
			weaponstatus[EXHUNTS_TUBESIZE]=7;
			weaponstatus[EXHUNTS_CHOKE]=7;
		}
		weaponstatus[EXHUNTS_TUBE]=weaponstatus[EXHUNTS_TUBESIZE];
		weaponstatus[EXSHOTS_SIDESADDLE]=12;
		exhandshells=0;
	}
	override void loadoutconfigure(string input){
		int type=getloadoutvar(input,"type",1);
		if(type>=0){
			switch(type){
			case 0:
				weaponstatus[0]|=EXHUNTF_EXPORT;
				weaponstatus[0]&=~EXHUNTF_CANFULLAUTO;
				break;
			case 1:
				weaponstatus[0]&=~EXHUNTF_EXPORT;
				weaponstatus[0]&=~EXHUNTF_CANFULLAUTO;
				break;
			case 2:
				weaponstatus[0]&=~EXHUNTF_EXPORT;
				weaponstatus[0]|=EXHUNTF_CANFULLAUTO;
				break;
			default:
				break;
			}
		}
		if(type<0||type>2)type=1;
		int firemode=getloadoutvar(input,"firemode",1);
		if(firemode>=0)weaponstatus[EXHUNTS_FIREMODE]=clamp(firemode,0,type);
		int choke=min(getloadoutvar(input,"choke",1),7);
		if(choke>=0)weaponstatus[EXHUNTS_CHOKE]=choke;

		int tubesize=((weaponstatus[0]&EXHUNTF_EXPORT)?5:7);
		if(weaponstatus[EXHUNTS_TUBE]>tubesize)weaponstatus[EXHUNTS_TUBE]=tubesize;
		weaponstatus[EXHUNTS_TUBESIZE]=tubesize;
	}
}
enum explosivehunterstatus{
	EXHUNTF_CANFULLAUTO=1,
	EXHUNTF_JAMMED=2,
	EXHUNTF_UNLOADONLY=4,
	EXHUNTF_FROMPOCKETS=8,
	EXHUNTF_ALTHOLDING=16,
	EXHUNTF_HOLDING=32,
	EXHUNTF_EXPORT=64,

	EXHUNTS_FIREMODE=1,
	EXHUNTS_CHAMBER=2,
	//3 is for side saddles
	EXHUNTS_TUBE=4,
	EXHUNTS_TUBESIZE=5,
	EXHUNTS_HAND=6,
	EXHUNTS_CHOKE=7,
};


class ExplosiveHunterRandom:IdleDummy{
	states{
	spawn:
		TNT1 A 0 nodelay{
			let ggg=ExplosiveHunter(spawn("ExplosiveHunter",pos,ALLOW_REPLACE));
			if(!ggg)return;
			HDF.TransferSpecials(self,ggg,HDF.TS_ALL);

			ggg.weaponstatus[EXHUNTS_CHOKE]=7;
			if(!random(0,32)){
				ggg.weaponstatus[0]&=~EXHUNTF_EXPORT;
				ggg.weaponstatus[0]|=EXHUNTF_CANFULLAUTO;
			}else if(!random(0,7)){
				ggg.weaponstatus[0]|=EXHUNTF_EXPORT;
				ggg.weaponstatus[0]&=~EXHUNTF_CANFULLAUTO;
			}
			int tubesize=((ggg.weaponstatus[0]&EXHUNTF_EXPORT)?5:7);
			if(ggg.weaponstatus[EXHUNTS_TUBE]>tubesize)ggg.weaponstatus[EXHUNTS_TUBE]=tubesize;
			ggg.weaponstatus[EXHUNTS_TUBESIZE]=tubesize;
		}stop;
	}
}

