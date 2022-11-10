// ------------------------------------------------------------
// A 12-gauge pump for protection
// ------------------------------------------------------------
class LLHunter:HDLLShotgun{
	default{
		//$Category "Weapons/Hideous Destructor"
		//$Title "LLHunter"
		//$Sprite "LLSPA0"

 +hdweapon.fitsinbackpack
		weapon.selectionorder 31;
		weapon.slotnumber 3;
		weapon.slotpriority 5;
		weapon.bobrangex 0.21;
		weapon.bobrangey 0.86;
		scale 0.6;
		hdweapon.barrelsize 30,0.5,2;
		hdweapon.refid "LLH";
		tag "$TAG_LESSLETHALHUNTER";
		obituary "$OB_LLSHOTGUN";
	}
	//returns the power of the load just fired
	static double Fire(actor caller,int choke=1){
		double spread=6.;
		double speedfactor=1.;
		let hhh=LLHunter(caller.findinventory("LLHunter"));
		if(hhh)choke=hhh.weaponstatus[LL_HUNTS_CHOKE];

		choke=1;
		spread=9.5-0.5*choke;//1.5x the spread, better for knocking down crowds
		speedfactor=1.+0.02857*choke;

		double shotpower=getshotpower();
		spread*=shotpower;
		speedfactor*=shotpower;
		HDBulletActor.FireBullet(caller,"HDB_wad");
		let p=HDBulletActor.FireBullet(caller,"HDB_00Rubber",
			spread:spread,speedfactor:speedfactor,amount:10
		);
		distantnoise.make(p,"world/shotgunfar");
		caller.A_StartSound("weapons/hunter",CHAN_WEAPON);
		return shotpower;
	}
	const HUNTER_MINSHOTPOWER=0.901;
	action void A_FireLLHunter(){
		double shotpower=invoker.Fire(self);
		A_GunFlash();
		vector2 shotrecoil=(randompick(-1,1),-2.6);
		if(invoker.weaponstatus[LL_HUNTS_FIREMODE]>0)shotrecoil=(randompick(-1,1)*1.4,-3.4);
		shotrecoil*=shotpower;
		A_MuzzleClimb(0,0,shotrecoil.x,shotrecoil.y,randompick(-1,1)*shotpower,-0.3*shotpower);
		invoker.weaponstatus[LL_HUNTS_CHAMBER]=1;
		invoker.shotpower=shotpower;
	}
	override string pickupmessage(){
		if(weaponstatus[0]&LL_HUNTF_CANFULLAUTO)return string.format("You got the "..gettag().."! You notice some tool marks near the fire selector...",super.pickupmessage());
		else if(weaponstatus[0]&LL_HUNTF_EXPORT)return string.format("You got the "..gettag().."! Where is the fire selector on this thing!?",super.pickupmessage());
		return "You got the "..gettag().."!";
	}
	override string,double getpickupsprite(bool usespare){return "LLSP"..getpickupframe(usespare).."0",1.;}
	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
			sb.drawimage("LLS1A0",(-47,-10),basestatusbar.DI_SCREEN_CENTER_BOTTOM);
			sb.drawnum(hpl.countinv("HDLLShellAmmo"),-46,-8,
				basestatusbar.DI_SCREEN_CENTER_BOTTOM
			);
		}
		if(hdw.weaponstatus[LL_HUNTS_CHAMBER]>1){
			sb.drawrect(-24,-14,5,3);
			sb.drawrect(-18,-14,2,3);
		}
		else if(hdw.weaponstatus[LL_HUNTS_CHAMBER]>0){
			sb.drawrect(-18,-14,2,3);
		}
		if(!(hdw.weaponstatus[0]&LL_HUNTF_EXPORT))sb.drawwepcounter(hdw.weaponstatus[LL_HUNTS_FIREMODE],
			-26,-12,"blank","RBRSA3A7","STFULAUT"
		);
		sb.drawwepnum(hdw.weaponstatus[LL_HUNTS_TUBE],hdw.weaponstatus[LL_HUNTS_TUBESIZE],posy:-7);
		for(int i=hdw.weaponstatus[SHOTS_SIDESADDLE];i>0;i--){
			sb.drawrect(-16-i*2,-5,1,3);
		}
	}
	override string gethelptext(){
		return
		WEPHELP_FIRE.."  Shoot\n"
		..WEPHELP_ALTFIRE.."  Pump\n"
		..WEPHELP_RELOAD.."  Reload (side saddles first)\n"
		..WEPHELP_ALTRELOAD.."  Reload (pockets only)\n"
                ..WEPHELP_FIREMODE.."+"..WEPHELP_RELOAD.."  Load side saddles\n"
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
			"fblusite",(0,0)+bobb,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP
		);
		sb.SetClipRect(cx,cy,cw,ch);
		sb.drawimage(
			"bluesite",(0,0)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			alpha:0.9
		);
	}
	override double gunmass(){
		int tube=weaponstatus[LL_HUNTS_TUBE];
		if(tube>4)tube+=(tube-4)*2;
		return 7+tube*0.3+weaponstatus[SHOTS_SIDESADDLE]*0.08;
	}
	override double weaponbulk(){
		return 100+(weaponstatus[SHOTS_SIDESADDLE]+weaponstatus[LL_HUNTS_TUBE])*ENC_SHELLLOADED;
	}

	action void A_SwitchFireMode(bool forwards=true){
		if(invoker.weaponstatus[0]&LL_HUNTF_EXPORT){
			invoker.weaponstatus[LL_HUNTS_FIREMODE]=0;
			return;
		}

		int newfm=invoker.weaponstatus[LL_HUNTS_FIREMODE]+(forwards?1:-1);
		int newmax=(invoker.weaponstatus[0]&LL_HUNTF_CANFULLAUTO)?2:1;
		if(newfm>newmax)newfm=0;
		else if(newfm<0)newfm=newmax;
		invoker.weaponstatus[LL_HUNTS_FIREMODE]=0;
	}

	action void A_SetAltHold(bool which){
		if(which)invoker.weaponstatus[0]|=LL_HUNTF_ALTHOLDING;
		else invoker.weaponstatus[0]&=~LL_HUNTF_ALTHOLDING;
	}
	action void A_Chamber(bool careful=false){
		int chm=invoker.weaponstatus[LL_HUNTS_CHAMBER];
		invoker.weaponstatus[LL_HUNTS_CHAMBER]=0;
		if(invoker.weaponstatus[LL_HUNTS_TUBE]>0){
			invoker.weaponstatus[LL_HUNTS_CHAMBER]=2;
			invoker.weaponstatus[LL_HUNTS_TUBE]--;
		}
		vector3 cockdir;double cp=cos(pitch);
		if(careful)cockdir=(-cp,cp,-5);
		else cockdir=(0,-cp*5,sin(pitch)*frandom(4,6));
		cockdir.xy=rotatevector(cockdir.xy,angle);
		actor fbs;bool gbg;
		if(chm>1){
			if(careful&&!A_JumpIfInventory("HDLLShellAmmo",0,"null")){
				HDF.Give(self,"HDLLShellAmmo",1);
			}else{
				[gbg,fbs]=A_SpawnItemEx("HDLLFumblingShell",
					cos(pitch)*8,0,height-8-sin(pitch)*8,
					vel.x+cockdir.x,vel.y+cockdir.y,vel.z+cockdir.z,
					0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
				);
			}
		}else if(chm>0){	
			cockdir*=frandom(1.,1.3);
			[gbg,fbs]=A_SpawnItemEx("HDLLSpentShell",
				cos(pitch)*8,frandom(-0.1,0.1),height-8-sin(pitch)*8,
				vel.x+cockdir.x,vel.y+cockdir.y,vel.z+cockdir.z,
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
			);
		}
	}
	action void A_CheckPocketSaddles(){
		if(invoker.weaponstatus[SHOTS_SIDESADDLE]<1)invoker.weaponstatus[0]|=LL_HUNTF_FROMPOCKETS;
		if(!countinv("HDLLShellAmmo"))invoker.weaponstatus[0]&=~LL_HUNTF_FROMPOCKETS;
	}
	action bool A_LoadTubeFromHand(){
		int hand=invoker.handshells;
		if(
			!hand
			||(
				invoker.weaponstatus[LL_HUNTS_CHAMBER]>0
				&&invoker.weaponstatus[LL_HUNTS_TUBE]>=invoker.weaponstatus[LL_HUNTS_TUBESIZE]
			)
		){
			EmptyHand();
			return false;
		}
		invoker.weaponstatus[LL_HUNTS_TUBE]++;
		invoker.handshells--;
		A_StartSound("weapons/huntreload",8,CHANF_OVERLAP);
		return true;
	}
	action bool A_GrabShells(int maxhand=3,bool settics=false,bool alwaysone=false){
		if(maxhand>0)EmptyHand();else maxhand=abs(maxhand);
		bool fromsidesaddles=!(invoker.weaponstatus[0]&LL_HUNTF_FROMPOCKETS);
		int toload=min(
			fromsidesaddles?invoker.weaponstatus[SHOTS_SIDESADDLE]:countinv("HDLLShellAmmo"),
			alwaysone?1:(invoker.weaponstatus[LL_HUNTS_TUBESIZE]-invoker.weaponstatus[LL_HUNTS_TUBE]),
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
			A_TakeInventory("HDLLShellAmmo",toload,TIF_NOTAKEINFINITE);
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
		LLSG A 0;
		goto select0big;
	deselect0:
		LLSG A 0;
		goto deselect0big;
	firemode:
		LLSG A 0 a_switchfiremode();
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
		LLSG A 0 A_JumpIf(pressingunload()&&(pressinguse()||pressingzoom()),"cannibalize");
		LLSG A 0 A_JumpIf(pressingaltfire(),2);
		LLSG A 0{
			if(!pressingaltfire()){
				if(!pressingfire())A_ClearRefire();
				A_SetAltHold(false);
			}
		}
		LLSG A 1 A_WeaponReady(WRF_ALL);
		goto readyend;
	reloadSS:
		LLSG A 1 offset(1,34);
		LLSG A 2 offset(2,34);
		LLSG A 3 offset(3,36);
	reloadSSrestart:
		LLSG A 6 offset(3,35);
		LLSG A 9 offset(4,34);
		LLSG A 4 offset(3,34){
			int hnd=min(
				countinv("HDLLShellAmmo"),
				12-invoker.weaponstatus[SHOTS_SIDESADDLE],
				max(1,health/22),
				3
			);
			if(hnd<1)setweaponstate("reloadSSend");
			else{
				A_TakeInventory("HDLLShellAmmo",hnd);
				invoker.weaponstatus[SHOTS_SIDESADDLE]+=hnd;
				A_StartSound("weapons/pocket",8);
			}
		}
		LLSG A 0 {
			if(
				!PressingReload()
				&&!PressingAltReload()
			)setweaponstate("reloadSSend");
			else if(
				invoker.weaponstatus[SHOTS_SIDESADDLE]<12
				&&countinv("HDLLShellAmmo")
			)setweaponstate("ReloadSSrestart");
		}
	reloadSSend:
		LLSG A 3 offset(2,34);
		LLSG A 1 offset(1,34) EmptyHand(careful:true);
		goto nope;
	hold:
		LLSG A 0{
			bool paf=pressingaltfire();
			if(
				paf&&!(invoker.weaponstatus[0]&LL_HUNTF_ALTHOLDING)
			)setweaponstate("chamber");
			else if(!paf)invoker.weaponstatus[0]&=~LL_HUNTF_ALTHOLDING;
		}
		LLSG A 1 A_WeaponReady(WRF_NONE);
		LLSG A 0 A_Refire();
		goto ready;
	fire:
		LLSG A 0 A_JumpIf(invoker.weaponstatus[LL_HUNTS_CHAMBER]==2,"shoot");
		LLSG A 1 A_WeaponReady(WRF_NONE);
		LLSG A 0 A_Refire();
		goto ready;
	shoot:
		LLSG A 2;
		LLSG A 1 offset(0,36) A_FireLLHunter();
		LLSG E 1;
		LLSG E 0{
			if(
				invoker.weaponstatus[LL_HUNTS_FIREMODE]>0
				&&invoker.shotpower>HUNTER_MINSHOTPOWER
			)setweaponstate("chamberauto");
		}goto ready;
	altfire:
	chamber:
		LLSG A 0 A_JumpIf(invoker.weaponstatus[0]&LL_HUNTF_ALTHOLDING,"nope");
		LLSG A 0 A_SetAltHold(true);
		LLSG A 1 A_Overlay(120,"playsgco");
		LLSG AE 1 A_MuzzleClimb(0,frandom(0.6,1.));
		LLSG E 1 A_JumpIf(pressingaltfire(),"longstroke");
		LLSG EA 1 A_MuzzleClimb(0,-frandom(0.6,1.));
		LLSG E 0 A_StartSound("weapons/huntshort",8);
		LLSG E 0 A_Refire("ready");
		goto ready;
	longstroke:
		LLSG F 2 A_MuzzleClimb(frandom(1.,2.));
		LLSG F 0{
			A_Chamber();
			A_MuzzleClimb(-frandom(1.,2.));
		}
	racked:
		LLSG F 1 A_WeaponReady(WRF_NOFIRE);
		LLSG F 0 A_JumpIf(!pressingaltfire(),"unrack");
		LLSG F 0 A_JumpIf(pressingunload(),"rackunload");
		LLSG F 0 A_JumpIf(invoker.weaponstatus[LL_HUNTS_CHAMBER],"racked");
		LLSG F 0{
			int rld=0;
			if(pressingreload()){
				rld=1;
				if(invoker.weaponstatus[SHOTS_SIDESADDLE]>0)
				invoker.weaponstatus[0]&=~LL_HUNTF_FROMPOCKETS;
				else{
					invoker.weaponstatus[0]|=LL_HUNTF_FROMPOCKETS;
					rld=2;
				}
			}else if(pressingaltreload()){
				rld=2;
				invoker.weaponstatus[0]|=LL_HUNTF_FROMPOCKETS;
			}
			if(
				(rld==2&&countinv("HDLLShellAmmo"))
				||(rld==1&&invoker.weaponstatus[SHOTS_SIDESADDLE]>0)
			)setweaponstate("rackreload");
		}
		loop;
	rackreload:
		LLSG F 1 offset(-1,35) A_WeaponBusy(true);
		LLSG F 2 offset(-2,37);
		LLSG F 4 offset(-3,40);
		LLSG F 1 offset(-4,42) A_GrabShells(1,true,true);
		LLSG F 0 A_JumpIf(!(invoker.weaponstatus[0]&LL_HUNTF_FROMPOCKETS),"rackloadone");
		LLSG F 6 offset(-5,43);
		LLSG F 6 offset(-4,41) A_StartSound("weapons/pocket",9);
	rackloadone:
		LLSG F 1 offset(-4,42);
		LLSG F 2 offset(-4,41);
		LLSG F 3 offset(-4,40){
			A_StartSound("weapons/huntreload",8,CHANF_OVERLAP);
			invoker.weaponstatus[LL_HUNTS_CHAMBER]=2;
			invoker.handshells--;
			EmptyHand(careful:true);
		}
		LLSG F 5 offset(-4,41);
		LLSG F 4 offset(-4,40) A_JumpIf(invoker.handshells>0,"rackloadone");
		goto rackreloadend;
	rackreloadend:
		LLSG F 1 offset(-3,39);
		LLSG F 1 offset(-2,37);
		LLSG F 1 offset(-1,34);
		LLSG F 0 A_WeaponBusy(false);
		goto racked;

	rackunload:
		LLSG F 1 offset(-1,35) A_WeaponBusy(true);
		LLSG F 2 offset(-2,37);
		LLSG F 4 offset(-3,40);
		LLSG F 1 offset(-4,42);
		LLSG F 2 offset(-4,41);
		LLSG F 3 offset(-4,40){
			int chm=invoker.weaponstatus[LL_HUNTS_CHAMBER];
			invoker.weaponstatus[LL_HUNTS_CHAMBER]=0;
			if(chm==2){
				invoker.handshells++;
				EmptyHand(careful:true);
			}else if(chm==1)A_SpawnItemEx("HDLLSpentShell",
				cos(pitch)*8,0,height-7-sin(pitch)*8,
				vel.x+cos(pitch)*cos(angle-random(86,90))*5,
				vel.y+cos(pitch)*sin(angle-random(86,90))*5,
				vel.z+sin(pitch)*random(4,6),
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
			);
			if(chm)A_StartSound("weapons/huntreload",8,CHANF_OVERLAP);
		}
		LLSG F 5 offset(-4,41);
		LLSG F 4 offset(-4,40) A_JumpIf(invoker.handshells>0,"rackloadone");
		goto rackreloadend;

	unrack:
		LLSG F 0 A_Overlay(120,"playsgco2");
		LLSG E 1 A_JumpIf(!pressingfire(),1);
		LLSG EA 2{
			if(pressingfire())A_SetTics(1);
			A_MuzzleClimb(0,-frandom(0.6,1.));
		}
		LLSG A 0 A_ClearRefire();
		goto ready;
	playsgco:
		TNT1 A 8 A_StartSound("weapons/huntrackup",8);
		TNT1 A 0 A_StopSound(8);
		stop;
	playsgco2:
		TNT1 A 8 A_StartSound("weapons/huntrackdown",8);
		TNT1 A 0 A_StopSound(8);
		stop;
	chamberauto:
		LLSG A 1 A_Chamber();
		LLSG A 1 A_JumpIf(invoker.weaponstatus[0]&LL_HUNTF_CANFULLAUTO&&invoker.weaponstatus[LL_HUNTS_FIREMODE]==2,"ready");
		LLSG A 0 A_Refire();
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
		LLSG A 0{
			if(!countinv("HDLLShellAmmo"))setweaponstate("nope");
			else invoker.weaponstatus[0]|=LL_HUNTF_FROMPOCKETS;
		}goto startreload;
	reload:
	reloadfromsidesaddles:
		LLSG A 0{
			int sss=invoker.weaponstatus[SHOTS_SIDESADDLE];
			int ppp=countinv("HDLLShellAmmo");
			if(ppp<1&&sss<1)setweaponstate("nope");
				else if(sss<1)
					invoker.weaponstatus[0]|=LL_HUNTF_FROMPOCKETS;
				else invoker.weaponstatus[0]&=~LL_HUNTF_FROMPOCKETS;
		}goto startreload;
	startreload:
		LLSG A 1{
			if(
				invoker.weaponstatus[LL_HUNTS_TUBE]>=invoker.weaponstatus[LL_HUNTS_TUBESIZE]
			){
				if(
					invoker.weaponstatus[SHOTS_SIDESADDLE]<12
					&&countinv("HDLLShellAmmo")
				)setweaponstate("ReloadSS");
				else setweaponstate("nope");
			}
		}
		LLSG AB 4 A_MuzzleClimb(frandom(.6,.7),-frandom(.6,.7));
	reloadstarthand:
		LLSG C 1 offset(0,36);
		LLSG C 1 offset(0,38);
		LLSG C 2 offset(0,36);
		LLSG C 2 offset(0,34);
		LLSG C 3 offset(0,36);
		LLSG C 3 offset(0,40) A_CheckPocketSaddles();
		LLSG C 0 A_JumpIf(invoker.weaponstatus[0]&LL_HUNTF_FROMPOCKETS,"reloadpocket");
	reloadfast:
		LLSG C 4 offset(0,40) A_GrabShells(3,false);
		LLSG C 3 offset(0,42) A_StartSound("weapons/pocket",9,volume:0.4);
		LLSG C 3 offset(0,41);
		goto reloadashell;
	reloadpocket:
		LLSG C 4 offset(0,39) A_GrabShells(3,false);
		LLSG C 6 offset(0,40) A_JumpIf(health>40,1);
		LLSG C 4 offset(0,40) A_StartSound("weapons/pocket",9);
		LLSG C 8 offset(0,42) A_StartSound("weapons/pocket",9);
		LLSG C 6 offset(0,41) A_StartSound("weapons/pocket",9);
		LLSG C 6 offset(0,40);
		goto reloadashell;
	reloadashell:
		LLSG C 2 offset(0,36);
		LLSG C 4 offset(0,34)A_LoadTubeFromHand();
		LLSG CCCCCC 1 offset(0,33){
			if(
				PressingReload()
				||PressingAltReload()
				||PressingUnload()
				||PressingFire()
				||PressingAltfire()
				||PressingZoom()
				||PressingFiremode()
			)invoker.weaponstatus[0]|=LL_HUNTF_HOLDING;
			else invoker.weaponstatus[0]&=~LL_HUNTF_HOLDING;

			if(
				invoker.weaponstatus[LL_HUNTS_TUBE]>=invoker.weaponstatus[LL_HUNTS_TUBESIZE]
				||(
					invoker.handshells<1&&(
						invoker.weaponstatus[0]&LL_HUNTF_FROMPOCKETS
						||invoker.weaponstatus[SHOTS_SIDESADDLE]<1
					)&&
					!countinv("HDLLShellAmmo")
				)
			)setweaponstate("reloadend");
			else if(
				!pressingaltreload()
				&&!pressingreload()
			)setweaponstate("reloadend");
			else if(invoker.handshells<1)setweaponstate("reloadstarthand");
		}goto reloadashell;
	reloadend:
		LLSG C 4 offset(0,34) A_StartSound("weapons/huntopen",8);
		LLSG C 1 offset(0,36) EmptyHand(careful:true);
		LLSG C 1 offset(0,34);
		LLSG CBA 3;
		LLSG A 0 A_JumpIf(invoker.weaponstatus[0]&LL_HUNTF_HOLDING,"nope");
		goto ready;

	cannibalize:
				goto ready;

	unloadSS:
		LLSG A 2 offset(1,34) A_JumpIf(invoker.weaponstatus[SHOTS_SIDESADDLE]<1,"nope");
		LLSG A 1 offset(2,34);
		LLSG A 1 offset(3,36);
	unloadSSLoop1:
		LLSG A 4 offset(4,36);
		LLSG A 2 offset(5,37) A_UnloadSideSaddle();
		LLSG A 3 offset(4,36){	//decide whether to loop
			if(
				PressingReload()
				||PressingFire()
				||PressingAltfire()
				||invoker.weaponstatus[SHOTS_SIDESADDLE]<1
			)setweaponstate("unloadSSend");
		}goto unloadSSLoop1;
	unloadSSend:
		LLSG A 3 offset(4,35);
		LLSG A 2 offset(3,35);
		LLSG A 1 offset(2,34);
		LLSG A 1 offset(1,34);
		goto nope;
	unload:
		LLSG A 1{
			if(
				invoker.weaponstatus[SHOTS_SIDESADDLE]>0
				&&!(player.cmd.buttons&BT_USE)
			)setweaponstate("unloadSS");
			else if(
				invoker.weaponstatus[LL_HUNTS_CHAMBER]<1
				&&invoker.weaponstatus[LL_HUNTS_TUBE]<1
			)setweaponstate("nope");
		}
		LLSG BC 4 A_MuzzleClimb(frandom(1.2,2.4),-frandom(1.2,2.4));
		LLSG C 1 offset(0,34);
		LLSG C 1 offset(0,36) A_StartSound("weapons/huntopen",8);
		LLSG C 1 offset(0,38);
		LLSG C 4 offset(0,36){
			A_MuzzleClimb(-frandom(1.2,2.4),frandom(1.2,2.4));
			if(invoker.weaponstatus[LL_HUNTS_CHAMBER]<1){
				setweaponstate("unloadtube");
			}else A_StartSound("weapons/huntrack",8,CHANF_OVERLAP);
		}
		LLSG D 8 offset(0,34){
			A_MuzzleClimb(-frandom(1.2,2.4),frandom(1.2,2.4));
			int chm=invoker.weaponstatus[LL_HUNTS_CHAMBER];
			invoker.weaponstatus[LL_HUNTS_CHAMBER]=0;
			if(chm>1){
				A_StartSound("weapons/huntreload",8);
				if(A_JumpIfInventory("HDLLShellAmmo",0,"null"))A_SpawnItemEx("HDLLFumblingShell",
					cos(pitch)*8,0,height-7-sin(pitch)*8,
					vel.x+cos(pitch)*cos(angle-random(86,90))*5,
					vel.y+cos(pitch)*sin(angle-random(86,90))*5,
					vel.z+sin(pitch)*random(4,6),
					0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
				);else{
					HDF.Give(self,"HDLLShellAmmo",1);
					A_StartSound("weapons/pocket",9);
					A_SetTics(5);
				}
			}else if(chm>0)A_SpawnItemEx("HDLLSpentShell",
				cos(pitch)*8,0,height-7-sin(pitch)*8,
				vel.x+cos(pitch)*cos(angle-random(86,90))*5,
				vel.y+cos(pitch)*sin(angle-random(86,90))*5,
				vel.z+sin(pitch)*random(4,6),
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
			);
		}
		LLSG C 0 A_JumpIf(!pressingunload(),"reloadend");
		LLSG C 4 offset(0,40);
	unloadtube:
		LLSG C 6 offset(0,40) EmptyHand(careful:true);
	unloadloop:
		LLSG C 8 offset(1,41){
			if(invoker.weaponstatus[LL_HUNTS_TUBE]<1)setweaponstate("reloadend");
			else if(invoker.handshells>=3)setweaponstate("unloadloopend");
			else{
				invoker.handshells++;
				invoker.weaponstatus[LL_HUNTS_TUBE]--;
			}
		}
		LLSG C 4 offset(0,40) A_StartSound("weapons/huntreload",8);
		loop;
	unloadloopend:
		LLSG C 6 offset(1,41);
		LLSG C 3 offset(1,42){
			int rmm=HDPickup.MaxGive(self,"HDLLShellAmmo",ENC_SHELL);
			if(rmm>0){
				A_StartSound("weapons/pocket",9);
				A_SetTics(8);
				HDF.Give(self,"HDLLShellAmmo",min(rmm,invoker.handshells));
				invoker.handshells=max(invoker.handshells-rmm,0);
			}
		}
		LLSG C 0 EmptyHand(careful:true);
		LLSG C 6 A_Jumpif(!pressingunload(),"reloadend");
		goto unloadloop;
	spawn:
		LLSP ABCDEFG -1 nodelay{
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
		weaponstatus[LL_HUNTS_CHAMBER]=2;
		if(!idfa){
			weaponstatus[LL_HUNTS_TUBESIZE]=5;
			weaponstatus[LL_HUNTS_CHOKE]=1;
		}
		weaponstatus[LL_HUNTS_TUBE]=weaponstatus[LL_HUNTS_TUBESIZE];
		weaponstatus[SHOTS_SIDESADDLE]=12;
		handshells=0;
	}
	override void loadoutconfigure(string input){
		int type=getloadoutvar(input,"type",1);
		if(type>=0){
			switch(type){
			case 0:
				weaponstatus[0]|=LL_HUNTF_EXPORT;
				weaponstatus[0]&=~LL_HUNTF_CANFULLAUTO;
				break;
			case 1:
				weaponstatus[0]&=~LL_HUNTF_EXPORT;
				weaponstatus[0]&=~LL_HUNTF_CANFULLAUTO;
				break;
			case 2:
				weaponstatus[0]&=~LL_HUNTF_EXPORT;
				weaponstatus[0]|=LL_HUNTF_CANFULLAUTO;
				break;
			default:
				break;
			}
		}
		if(type<0||type>2)type=0;
		int firemode=getloadoutvar(input,"firemode",0);
		if(firemode>=0)weaponstatus[LL_HUNTS_FIREMODE]=clamp(firemode,0,type);
		
   /*  disabling choke, it's not meant for sniping lmao
   int choke=min(getloadoutvar(input,"choke",1),7);
		if(choke>=0)weaponstatus[LL_HUNTS_CHOKE]=choke;
    */
		int tubesize=((weaponstatus[0]&LL_HUNTF_EXPORT)?5:5);
		if(weaponstatus[LL_HUNTS_TUBE]>tubesize)weaponstatus[LL_HUNTS_TUBE]=tubesize;
		weaponstatus[LL_HUNTS_TUBESIZE]=tubesize;
	}
}
enum lesslethal_hunterstatus{
	LL_HUNTF_CANFULLAUTO=1,
	LL_HUNTF_JAMMED=2,
	LL_HUNTF_UNLOADONLY=4,
	LL_HUNTF_FROMPOCKETS=8,
	LL_HUNTF_ALTHOLDING=16,
	LL_HUNTF_HOLDING=32,
	LL_HUNTF_EXPORT=64,

	LL_HUNTS_FIREMODE=1,
	LL_HUNTS_CHAMBER=2,
	//3 is for side saddles
	LL_HUNTS_TUBE=4,
	LL_HUNTS_TUBESIZE=5,
	LL_HUNTS_HAND=6,
	LL_HUNTS_CHOKE=7,
};


class LLHunterRandom:IdleDummy{
	states{
	spawn:
		TNT1 A 0 nodelay{
			let ggg=LLHunter(spawn("LLHunter",pos,ALLOW_REPLACE));
			if(!ggg)return;
			HDF.TransferSpecials(self,ggg,HDF.TS_ALL);
/*
	if(!random(0,7))ggg.weaponstatus[LL_HUNTS_CHOKE]=random(0,7);
			if(!random(0,32)){
				ggg.weaponstatus[0]&=~LL_HUNTF_EXPORT;
				ggg.weaponstatus[0]|=LL_HUNTF_CANFULLAUTO;
			}else if(!random(0,7)){
				ggg.weaponstatus[0]|=LL_HUNTF_EXPORT;
				ggg.weaponstatus[0]&=~LL_HUNTF_CANFULLAUTO;
			}
*/
			int tubesize=((ggg.weaponstatus[0]&LL_HUNTF_EXPORT)?5:5);
			if(ggg.weaponstatus[LL_HUNTS_TUBE]>tubesize)ggg.weaponstatus[LL_HUNTS_TUBE]=tubesize;
			ggg.weaponstatus[LL_HUNTS_TUBESIZE]=tubesize;
		}stop;
	}
}
