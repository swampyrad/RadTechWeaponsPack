//------------------------------------------------------------
// Colt 1911 .45 Pistol
// ------------------------------------------------------------


class HDColt1911:HDHandgun{
	default{
		+hdweapon.fitsinbackpack
		+hdweapon.reverseguninertia
		scale 0.63;
		weapon.selectionorder 50;
		weapon.slotnumber 2;
		weapon.slotpriority 3;
		weapon.kickback 30;
		weapon.bobrangex 0.1;
		weapon.bobrangey 0.6;
		weapon.bobspeed 2.5;
		weapon.bobstyle "normal";
		obituary "$OB_COLT1911";
//		inventory.pickupmessage "You got the Colt 1911! Semper Fi!";
		tag "$TAG_C19";
		hdweapon.refid "c19";
		hdweapon.barrelsize 10,0.3,0.5;
	}

	override string pickupmessage(){
		return Stringtable.Localize("$PICKUP_COLT1911");
	}

	override double weaponbulk(){
		int mgg=weaponstatus[PISS_MAG];
		return 40+(mgg<0?0:(ENC_1911MAG_LOADED+mgg*HD45ACPAmmo.EncRoundLoaded));
	}
	override double gunmass(){
		int mgg=weaponstatus[PISS_MAG];
		return 8+(mgg<0?0:0.25*(mgg+1));
	}
	override void failedpickupunload(){
		failedpickupunloadmag(PISS_MAG,"HDColtMag7");
	}
	override string,double getpickupsprite(bool usespare){
		string spr;
		int wep0=GetSpareWeaponValue(0,usespare);
		if(GetSpareWeaponValue(PISS_CHAMBER,usespare)<1){
			if(wep0&PISF_SELECTFIRE)spr="D";
			else spr="B";
		}else{
			if(wep0&PISF_SELECTFIRE)spr="C";
			else spr="A";
		}
		return "M191"..spr.."0",1.;
	}

  override void postbeginplay(){
		super.postbeginplay();
  weaponspecial=1337;
	}
  
	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
			int nextmagloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("HDColtMag7")));
			if(nextmagloaded>=7){
				sb.drawimage("CMG7A0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1,1));
			}else if(nextmagloaded<1){
				sb.drawimage("CMG7D0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextmagloaded?0.6:1.,scale:(1,1));
			}else sb.drawbar(
				"CMG7A0","CMG7C0",
				nextmagloaded,7,
				(-46,-3),-1,
				sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
			);
			sb.drawnum(hpl.countinv("HDColtMag7"),-43,-8,sb.DI_SCREEN_CENTER_BOTTOM);
		}
		if(hdw.weaponstatus[0]&PISF_SELECTFIRE)sb.drawwepcounter(hdw.weaponstatus[0]&PISF_FIREMODE,
			-22,-10,"RBRSA3A7","STFULAUT"
		);
		sb.drawwepnum(hdw.weaponstatus[PISS_MAG],7);
		if(hdw.weaponstatus[PISS_CHAMBER]==2)sb.drawrect(-19,-11,3,1);
	}
	override string gethelptext(){
		return
		WEPHELP_FIRESHOOT
		..((weaponstatus[0]&PISF_SELECTFIRE)?(WEPHELP_FIREMODE.."  Semi/Auto\n"):"")
		..WEPHELP_ALTRELOAD.."  Quick-Swap (if available)\n"
		..WEPHELP_RELOAD.."  Reload mag\n"
		..WEPHELP_USE.."+"..WEPHELP_RELOAD.."  Reload chamber\n"
		..WEPHELP_MAGMANAGER
		..WEPHELP_UNLOADUNLOAD
		;
	}
	override void DrawSightPicture(
		HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl,
		bool sightbob,vector2 bob,double fov,bool scopeview,actor hpc
	){
		int cx,cy,cw,ch;
		[cx,cy,cw,ch]=screen.GetClipRect();
		vector2 scc;
		vector2 bobb=bob*1.6;

		//if slide is pushed back, throw sights off line
		if(hpl.player.getpsprite(PSP_WEAPON).frame>=2){
			sb.SetClipRect(
				-10+bob.x,-10+bob.y,20,19,
				sb.DI_SCREEN_CENTER
			);
			bobb.y-=2;
			scc=(0.7,0.8);
		}else{
			sb.SetClipRect(
				-8+bob.x,-9+bob.y,16,15,
				sb.DI_SCREEN_CENTER
			);
			scc=(0.6,0.6);
		}
		sb.drawimage(
			"frntsite",(0,0)+bobb,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			scale:scc
		);
		sb.SetClipRect(cx,cy,cw,ch);
		sb.drawimage(
			"backsite",(0,0)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			alpha:0.9,
			scale:scc
		);
	}
	override void DropOneAmmo(int amt){
		if(owner){
			amt=clamp(amt,1,10);
			if(owner.countinv("HD45ACPAmmo"))owner.A_DropInventory("HD45ACPAmmo",amt*7);
			else owner.A_DropInventory("HDColtMag7",amt);
		}
	}
	override void ForceBasicAmmo(){
		owner.A_TakeInventory("HD45ACPAmmo");
		ForceOneBasicAmmo("HDColtMag7");
	}
	action void A_CheckPistolHand(){
		if(invoker.wronghand)player.getpsprite(PSP_WEAPON).sprite=getspriteindex("C245A0");  //i hate this line of code so much, it never works for me :(

	}
	states{
	select0:
		CT45 A 0{
			if(!countinv("NulledWeapon"))invoker.wronghand=false;
			A_TakeInventory("NulledWeapon");
			A_CheckPistolHand();
		}
		#### A 0 A_JumpIf(invoker.weaponstatus[PISS_CHAMBER]>0,2);
		#### C 0;
		---- A 1 A_Raise();
		---- A 1 A_Raise(30);
		---- A 1 A_Raise(30);
		---- A 1 A_Raise(24);
		---- A 1 A_Raise(18);
		wait;
	deselect0:
		CT45 A 0 A_CheckPistolHand();
		#### A 0 A_JumpIf(invoker.weaponstatus[PISS_CHAMBER]>0,2);
		#### C 0;
		---- AAA 1 A_Lower();
		---- A 1 A_Lower(18);
		---- A 1 A_Lower(24);
		---- A 1 A_Lower(30);
		wait;

	ready:
		CT45 A 0 A_CheckPistolHand();
		#### A 0 A_JumpIf(invoker.weaponstatus[PISS_CHAMBER]>0,2);
		#### B 0;//slidelocked frame
		#### # 0 A_SetCrosshair(21);
		#### # 1 A_WeaponReady(WRF_ALL);
		goto readyend;
	user3:
		---- A 0 A_MagManager("HDColtMag7");
		goto ready;
	user2:
	firemode:
		---- A 0{
			if(invoker.weaponstatus[0]&PISF_SELECTFIRE)
			invoker.weaponstatus[0]^=PISF_FIREMODE;
			else invoker.weaponstatus[0]&=~PISF_FIREMODE;
		}goto nope;
	altfire:
		---- A 0{
			invoker.weaponstatus[0]&=~PISF_JUSTUNLOAD;
			if(
				invoker.weaponstatus[PISS_CHAMBER]!=2
				&&invoker.weaponstatus[PISS_MAG]>0
			)setweaponstate("chamber_manual");
		}goto nope;
	chamber_manual:
		---- A 0 A_JumpIf(
			!(invoker.weaponstatus[0]&PISF_JUSTUNLOAD)
			&&(
				invoker.weaponstatus[PISS_CHAMBER]==2
				||invoker.weaponstatus[PISS_MAG]<1
			)
			,"nope"
		);
		#### B 3 offset(0,34);
		#### C 4 offset(0,37){
			A_MuzzleClimb(frandom(0.4,0.5),-frandom(0.6,0.8));
			A_StartSound("weapons/1911chamber2",8);
			int psch=invoker.weaponstatus[PISS_CHAMBER];
			invoker.weaponstatus[PISS_CHAMBER]=0;

    if(psch==2){
				A_EjectCasing("HD45ACPAmmo",
      -frandom(89,92),
      (frandom(2,3),0,0),(13,0,0));			
      }
    else if(psch==1){	
      A_EjectCasing("HDSpent45ACP",
      -frandom(89,92),
      (frandom(6,7),0,0),(13,0,0));
			  }

			if(invoker.weaponstatus[PISS_MAG]>0){
				invoker.weaponstatus[PISS_CHAMBER]=2;
				invoker.weaponstatus[PISS_MAG]--;
			}
		}
/*

*/

		#### B 3 offset(0,35);
		goto nope;
	althold:
	hold:
		goto nope;
	fire:
		---- A 0{
			invoker.weaponstatus[0]&=~PISF_JUSTUNLOAD;
			if(invoker.weaponstatus[PISS_CHAMBER]==2)setweaponstate("shoot");
			else if(invoker.weaponstatus[PISS_MAG]>0)setweaponstate("chamber_manual");
		}goto nope;
	shoot:
  #### A 1;//extra tic to increase trigger pull
		#### B 1{
			if(invoker.weaponstatus[PISS_CHAMBER]==2)A_GunFlash();
		}
		#### C 1{
			if(hdplayerpawn(self)){
				hdplayerpawn(self).gunbraced=false;
			}
			A_MuzzleClimb(
				-frandom(1.21,1.8),-frandom(1.3,2.1),
				-frandom(0.5,1.3),frandom(.9,1.0),frandom(0.7,0.7)
			);
		}
		#### D 0{

			A_EjectCasing("HDSpent45ACP",
      -frandom(89,92),
      (frandom(6,7),0,0),(13,0,0));

			invoker.weaponstatus[PISS_CHAMBER]=0;
			if(invoker.weaponstatus[PISS_MAG]<1){
				A_StartSound("weapons/1911dryfire",8,CHANF_OVERLAP,0.9);
				setweaponstate("nope");
			}
		}
   #### D 1;
		#### C 1{
			A_WeaponReady(WRF_NOFIRE);
			invoker.weaponstatus[PISS_CHAMBER]=2;
			invoker.weaponstatus[PISS_MAG]--;
			if(
				(invoker.weaponstatus[0]&(PISF_FIREMODE|PISF_SELECTFIRE))
				==(PISF_FIREMODE|PISF_SELECTFIRE)
			){
				A_GiveInventory("IsMoving",5);
				A_Refire("fire");
			}else A_Refire();
		}goto ready;
	flash:
		C45F A 0 A_JumpIf(invoker.wronghand,2);
		C45F A 0;
		---- A 1 bright{
			HDFlashAlpha(64);
			A_Light1();
			let bbb=HDBulletActor.FireBullet(self,"HDB_45ACP",spread:2.,speedfactor:frandom(0.97,1.03));
			if(
				frandom(0,ceilingz-floorz)<bbb.speed*0.3
			)A_AlertMonsters(256);

			invoker.weaponstatus[PISS_CHAMBER]=1;
			A_ZoomRecoil(0.995);
			A_MuzzleClimb(-frandom(0.8,2.7),-frandom(0.8,3.3));
                   
		}                  
		---- A 0 A_StartSound("weapons/colt1911",CHAN_WEAPON);
		---- A 0 A_Light0();
		stop;
	unload:
		---- A 0{
			invoker.weaponstatus[0]|=PISF_JUSTUNLOAD;
			if(invoker.weaponstatus[PISS_MAG]>=0)setweaponstate("unmag");
		}goto chamber_manual;
	loadchamber:
		---- A 0 A_JumpIf(invoker.weaponstatus[PISS_CHAMBER]>0,"nope");
		---- A 1 offset(0,36) A_StartSound("weapons/pocket",9);
		---- A 1 offset(2,40);
		---- A 1 offset(2,50);
		---- A 1 offset(3,60);
		---- A 2 offset(5,90);
		---- A 2 offset(7,80);
		---- A 2 offset(10,90);
		#### C 2 offset(8,96);
		#### C 3 offset(6,88){
			if(countinv("HD45ACPAmmo")){
				A_TakeInventory("HD45ACPAmmo",1,TIF_NOTAKEINFINITE);
				invoker.weaponstatus[PISS_CHAMBER]=2;
				A_StartSound("weapons/1911chamber1",8);
			}
		}
		#### B 2 offset(5,76);
		#### B 1 offset(4,64);
		#### B 1 offset(3,56);
		#### B 1 offset(2,48);
		#### B 2 offset(1,38);
		#### B 3 offset(0,34);
		goto readyend;
	reload:
		---- A 0{
			invoker.weaponstatus[0]&=~PISF_JUSTUNLOAD;
			bool nomags=HDMagAmmo.NothingLoaded(self,"HDColtMag7");
			if(invoker.weaponstatus[PISS_MAG]>=7)setweaponstate("nope");
			else if(
				invoker.weaponstatus[PISS_MAG]<1
				&&(
					pressinguse()
					||nomags
				)
			){
				if(
					countinv("HD45ACPAmmo")
				)setweaponstate("loadchamber");
				else setweaponstate("nope");
			}else if(nomags)setweaponstate("nope");
		}goto unmag;
	unmag:
		---- A 1 offset(0,34) A_SetCrosshair(21);
		---- A 1 offset(1,38);
		---- A 2 offset(2,42);
		---- A 3 offset(3,46) A_StartSound("weapons/1911_magclick",8,CHANF_OVERLAP);
		---- A 0{
			int pmg=invoker.weaponstatus[PISS_MAG];
			invoker.weaponstatus[PISS_MAG]=-1;
			if(pmg<0)setweaponstate("magout");
			else if(
				(!PressingUnload()&&!PressingReload())
				||A_JumpIfInventory("HDColtMag7",0,"null")
			){
				HDMagAmmo.SpawnMag(self,"HDColtMag7",pmg);
				setweaponstate("magout");
			}
			else{
				HDMagAmmo.GiveMag(self,"HDColtMag7",pmg);
				A_StartSound("weapons/pocket",9);
				setweaponstate("pocketmag");
			}
		}
	pocketmag:
		---- AAA 5 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		goto magout;
	magout:
		---- A 0{
			if(invoker.weaponstatus[0]&PISF_JUSTUNLOAD)setweaponstate("reloadend");
			else setweaponstate("loadmag");
		}

	loadmag:
		---- A 4 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		---- A 0 A_StartSound("weapons/pocket",9);
		---- A 5 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		---- A 3;
		---- A 0{
			let mmm=hdmagammo(findinventory("HDColtMag7"));
			if(mmm){
				invoker.weaponstatus[PISS_MAG]=mmm.TakeMag(true);
				A_StartSound("weapons/1911_magclick",8);
			}
		}
		goto reloadend;

	reloadend:
		---- A 2 offset(3,46);
		---- A 1 offset(2,42);
		---- A 1 offset(2,38);
		---- A 1 offset(1,34);
		---- A 0 A_JumpIf(!(invoker.weaponstatus[0]&PISF_JUSTUNLOAD),"chamber_manual");
		goto nope;

	user1:
	altreload:
	swappistols:
		---- A 0 A_SwapHandguns();
		---- A 0{
			bool id=(Wads.CheckNumForName("id",0)!=-1);
			bool offhand=invoker.wronghand;
			bool lefthanded=(id!=offhand);
			if(lefthanded){
				A_Overlay(1025,"raiseleft");
				A_Overlay(1026,"lowerright");
			}else{
				A_Overlay(1025,"raiseright");
				A_Overlay(1026,"lowerleft");
			}
		}
		TNT1 A 5;
		CT45 A 0 A_CheckPistolHand();
		goto nope;
	lowerleft:
		CT45 A 0;
		#### B 1 offset(-6,38);
		#### B 1 offset(-12,48);
		#### B 1 offset(-20,60);
		#### B 1 offset(-34,76);
		#### B 1 offset(-50,86);
		stop;
	lowerright:
		C245 A 0 ;
		#### B 1 offset(6,38);
		#### B 1 offset(12,48);
		#### B 1 offset(20,60);
		#### B 1 offset(34,76);
		#### B 1 offset(50,86);
		stop;
	raiseleft:
		CT45 A 0 ;
		#### A 1 offset(-50,86);
		#### A 1 offset(-34,76);
		#### A 1 offset(-20,60);
		#### A 1 offset(-12,48);
		#### A 1 offset(-6,38);
		stop;
	raiseright:
		C245 A 0;
		#### A 1 offset(50,86);
		#### A 1 offset(34,76);
		#### A 1 offset(20,60);
		#### A 1 offset(12,48);
		#### A 1 offset(6,38);
		stop;
	whyareyousmiling:
		#### B 1 offset(0,48);
		#### B 1 offset(0,60);
		#### B 1 offset(0,76);
		TNT1 A 7;
		CT45 A 0{
			invoker.wronghand=!invoker.wronghand;
			A_CheckPistolHand();
		}
		#### B 1 offset(0,76);
		#### B 1 offset(0,60);
		#### B 1 offset(0,48);
		goto nope;


	spawn:
		M191 ABCD -1 nodelay{
			if(invoker.weaponstatus[PISS_CHAMBER]<1){
				if(invoker.weaponstatus[0]&PISF_SELECTFIRE)frame=3;
				else frame=1;
			}else{
				if(invoker.weaponstatus[0]&PISF_SELECTFIRE)frame=2;
				else frame=0;
			}
		}stop;
	}
	override void initializewepstats(bool idfa){
		weaponstatus[PISS_MAG]=7;
		weaponstatus[PISS_CHAMBER]=2;
	}
	override void loadoutconfigure(string input){
		int selectfire=getloadoutvar(input,"selectfire",1);
		if(!selectfire){
			weaponstatus[0]&=~PISF_SELECTFIRE;
			weaponstatus[0]&=~PISF_FIREMODE;
		}else if(selectfire>0){
			weaponstatus[0]|=PISF_SELECTFIRE;
		}
		if(weaponstatus[0]&PISF_SELECTFIRE){
			int firemode=getloadoutvar(input,"firemode",1);
			if(!firemode)weaponstatus[0]&=~PISF_FIREMODE;
			else if(firemode>0)weaponstatus[0]|=PISF_FIREMODE;
		}
	}
}

// ------------------------------------------------------------
// Colt 1911 Ammo (Just the magazines)
// ------------------------------------------------------------

const enc_1911MAG=HD45ACPAmmo.EncRoundLoaded*8;

const enc_1911MAG_EMPTY=enc_1911MAG*0.3;

const enc_1911MAG_LOADED=enc_1911MAG_EMPTY*0.1;


class HDColtMag7:HDMagAmmo{
	default{
		//$Category "Ammo/Hideous Destructor/"
		//$Title "Colt 1911 Magazine"
		//$Sprite "CMG7A0"
		hdmagammo.maxperunit 7;
		hdmagammo.roundtype "HD45ACPAmmo";
		hdmagammo.roundbulk HD45ACPAmmo.EncRoundLoaded;
		hdmagammo.magbulk enc_1911MAG_EMPTY;
		tag "$TAG_CM7";
		inventory.pickupmessage "$PICKUP_CM7";
		hdpickup.refid "CM7";
   scale 0.45;
	}
	override string,string,name,double getmagsprite(int thismagamt){
		string magsprite=(thismagamt>0)?"CMG7A0":"CMG7D0";
		return magsprite,"45RNA0","HD45ACPAmmo",0.6;
	}
	override void GetItemsThatUseThis(){
		itemsthatusethis.push("HDColt1911");
	}
	states{
	spawn:
	CMG7	 A -1;
		stop;
	spawnempty:
		CMG7 B -1{
			brollsprite=true;brollcenter=true;
			roll=randompick(0,0,0,0,2,2,2,2,1,3)*90;
		}stop;
	}
}


class HDColt1911EmptyMag:IdleDummy{
	override void postbeginplay(){
		super.postbeginplay();
		HDMagAmmo.SpawnMag(self,"HDColtMag7",0);
		destroy();
	}
}


class HDColtMagPickup:HDInvRandomSpawner{
	default{
		dropitem "HDColtMag7",256,8;
	}
}

class HDColt1911Spawn:actor{
	override void postbeginplay(){
		super.postbeginplay();
		spawn("HDColt1911",pos,ALLOW_REPLACE);
  		spawn("HDColtMag7",pos,ALLOW_REPLACE);
  		spawn("HDColtMag7",pos,ALLOW_REPLACE);
		self.Destroy();
	}
}