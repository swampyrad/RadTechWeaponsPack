enum PhazerNums{
PHAZER_CAP=5,
PHAZER_MAXCAP=30}

class PhazerPistol:HDHandgun{
    
	default{
		//$Category "Weapons/Hideous Destructor"
		//$Title "Phazer"
		//$Sprite "PHZP0"

		+hdweapon.fitsinbackpack
		weapon.selectionorder 70;
		weapon.slotnumber 2;
		weapon.slotpriority 5;
		weapon.ammouse 1;
		scale 0.6;
		obituary "$OB_PHAZER";
		hdweapon.barrelsize 10,1.6,3;
		hdweapon.refid "PHZ";
		tag "$TAG_PHAZER";
	}
	override bool AddSpareWeapon(actor newowner){return AddSpareWeaponRegular(newowner);}
	override hdweapon GetSpareWeapon(actor newowner,bool reverse,bool doselect){
	    return GetSpareWeaponRegular(newowner,reverse,doselect);
	}

	override void tick(){
		super.tick();
		let capcharge = weaponstatus[PHAZER_CAP];
		let cellcharge = weaponstatus[TBS_BATTERY];
		
		if(capcharge<PHAZER_MAXCAP&&cellcharge>0){
		    weaponstatus[PHAZER_CAP]++;
		    if (!random(0,99))weaponstatus[TBS_BATTERY]--;
		    }
	}

	override string pickupmessage(){
		return Stringtable.Localize("$PICKUP_PHAZER");
	}

	override double gunmass(){
		return 4+(weaponstatus[TBS_BATTERY]<0?0:1);
	}

	override double weaponbulk(){
		return 50+(weaponstatus[1]>=0?(ENC_BATTERY_LOADED/2):0);
	}

    override string,double getpickupsprite(){
        return "PHZPA0",1.;
    }


    override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
			int nextcellloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("HDMicroCell")));
			if(nextcellloaded>6){
				sb.drawimage("mclla0",(-46, -10),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1,1));
			}else if(nextcellloaded>3){
				sb.drawimage("mcllb0",(-46, -10),sb.DI_SCREEN_CENTER_BOTTOM,alpha:1.,scale:(1,1));
			}else if(nextcellloaded>0){
				sb.drawimage("mcllc0",(-46, -10),sb.DI_SCREEN_CENTER_BOTTOM,alpha:1.,scale:(1,1));
			}else sb.drawimage("mclld0",(-46, -10),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextcellloaded?0.6:1.,scale:(1,1));

			sb.drawnum(hpl.countinv("HDMicroCell"),-46,-8,sb.DI_SCREEN_CENTER_BOTTOM);
		}
		
		sb.drawwepnum(hdw.weaponstatus[PHAZER_CAP],PHAZER_MAXCAP,-16,-10);//capacitor charge indicator
		
		if(!hdw.weaponstatus[1])sb.drawstring(
			sb.mamountfont,"00000",(-16,-9),sb.DI_TEXT_ALIGN_RIGHT|
			sb.DI_TRANSLATABLE|sb.DI_SCREEN_CENTER_BOTTOM,
			Font.CR_DARKGRAY
		);else if(hdw.weaponstatus[1]>0)sb.drawwepnum(hdw.weaponstatus[1],10);
		}

	override string gethelptext(){
		return
		  WEPHELP_FIRE.."  Fire\n"
		..WEPHELP_FIREMODE.."  Quick-swap (if available)\n"
		..WEPHELP_RELOADRELOAD
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

		sb.drawimage(
			"frntsite",(0,0)+bobb,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP
		);
		sb.SetClipRect(cx,cy,cw,ch);
		sb.drawimage(
			"backsite",(0,0)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			alpha:1
		);
	}
	
	override void failedpickupunload(){
		failedpickupunloadmag(TBS_BATTERY,"HDMicroCell");
	}
	
	override void consolidate(){
		CheckBFGCharge(TBS_BATTERY);
	}

    action void A_SwapPhazers(){
		let mwt=SpareWeapons(findinventory("SpareWeapons"));
		if(!mwt){
			setweaponstate("whyareyousmiling");
			return;
		}
		int pistindex=mwt.weapontype.find(invoker.getclassname());
		if(pistindex==mwt.weapontype.size()){
			setweaponstate("whyareyousmiling");
			return;
		}
		A_WeaponBusy();

		array<string> wepstat;
		string wepstat2="";
		mwt.weaponstatus[pistindex].split(wepstat,",");
		for(int i=0;i<wepstat.size();i++){
			if(i)wepstat2=wepstat2..",";
			wepstat2=wepstat2..invoker.weaponstatus[i];
			invoker.weaponstatus[i]=wepstat[i].toint();
		}
		mwt.weaponstatus[pistindex]=wepstat2;
		invoker.wronghand=!invoker.wronghand;
	}

    action void A_CheckPhazerHand()
    {	
        if(invoker.wronghand)
            player.getpsprite(PSP_WEAPON).sprite=
            getspriteindex("PHZ2");
	}

	states{
	ready:
		PHZR A 1{
            A_CheckPhazerHand();
			A_WeaponReady(WRF_ALL&~WRF_ALLOWUSER1);
		}goto readyend;
	fire:
	hold:
		#### A 0 A_JumpIf(invoker.weaponstatus[PHAZER_CAP]>10,"shoot");
		goto nope;
	shoot:
  #### A 0 {A_GunFlash();
            A_StartSound("weapons/phazer_fire");}
  #### B 1 bright {HDBulletActor.FireBullet(self,"HDB_Plasma");}
  #### C 1 {
		//aftereffects
    A_MuzzleClimb(-frandom(0.5,1),-frandom(0.5,1));
	invoker.weaponstatus[PHAZER_CAP]-=10;
}
		#### D 1 A_WeaponReady(WRF_NONE);
		#### A 0{
			A_WeaponReady(WRF_NOFIRE);
		}goto nope;
	flash:
		#### B 1 bright{
			HDFlashAlpha(64);
			A_Light2();
		}
		stop;
	altfire:
	    goto nope;
	    
	firemode:
      swappistols:
		---- A 0 A_SwapPhazers();
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
		PHZR A 0 A_CheckPhazerHand();
		goto nope;
	lowerleft:
		PHZR A 0;
		#### D 1 offset(-6,38);
		#### D 1 offset(-12,48);
		#### D 1 offset(-20,60);
		#### D 1 offset(-34,76);
		#### D 1 offset(-50,86);
		stop;
	lowerright:
		PHZ2 A 0 ;
		#### D 1 offset(6,38);
		#### D 1 offset(12,48);
		#### D 1 offset(20,60);
		#### D 1 offset(34,76);
		#### D 1 offset(50,86);
		stop;
	raiseleft:
		PHZR A 0 ;
		#### D 1 offset(-50,86);
		#### D 1 offset(-34,76);
		#### D 1 offset(-20,60);
		#### D 1 offset(-12,48);
		#### D 1 offset(-6,38);
		stop;
	raiseright:
		PHZ2 A 0;
		#### D 1 offset(50,86);
		#### D 1 offset(34,76);
		#### D 1 offset(20,60);
		#### D 1 offset(12,48);
		#### D 1 offset(6,38);
		stop;
	whyareyousmiling:
		#### D 1 offset(0,48);
		#### D 1 offset(0,60);
		#### D 1 offset(0,76);
		TNT1 A 7;
		PHZR A 0{
			invoker.wronghand=!invoker.wronghand;
			A_CheckPhazerHand();
		}
		#### D 1 offset(0,76);
		#### D 1 offset(0,60);
		#### D 1 offset(0,48);
		goto nope;
  
	select0:
		PHZR D 0 A_CheckPhazerHand();
		goto select0big;
	deselect0:
		PHZR D 0 A_CheckPhazerHand();
		goto deselect0big;

	unload:
		#### A 0{
			invoker.weaponstatus[0]|=TBF_JUSTUNLOAD;
			if(invoker.weaponstatus[TBS_BATTERY]>=0)
				return resolvestate("unmag");
			return resolvestate("nope");
		}
	unmag:
		#### A 2 offset(0,33){
			A_SetCrosshair(21);
			A_MuzzleClimb(frandom(-1.2,-2.4),frandom(1.2,2.4));
		}
		#### A 3 offset(0,35);
		#### A 2 offset(0,40) A_StartSound("weapons/phazer_open",8);
		#### A 0{
			int bat=invoker.weaponstatus[TBS_BATTERY];
			A_MuzzleClimb(frandom(-1.2,-2.4),frandom(1.2,2.4));
			if(
				(
					bat<0
				)||(
					!PressingUnload()&&!PressingReload()
				)
			)return resolvestate("dropmag");
			return resolvestate("pocketmag");
		}

	dropmag:
		---- A 0{
			int bat=invoker.weaponstatus[TBS_BATTERY];
			invoker.weaponstatus[TBS_BATTERY]=-1;
			if(bat>=0){
				HDMagAmmo.SpawnMag(self,"HDMicroCell",bat);
			}
		}goto magout;

	pocketmag:
		---- A 0{
			int bat=invoker.weaponstatus[TBS_BATTERY];
			invoker.weaponstatus[TBS_BATTERY]=-1;
			if(bat>=0){
				HDMagAmmo.GiveMag(self,"HDMicroCell",bat);
			}
		}
		#### A 8 offset(0,43) A_StartSound("weapons/pocket",9);
		#### A 8 offset(0,42) A_StartSound("weapons/pocket",9);
		goto magout;

	magout:
		---- A 0 A_JumpIf(invoker.weaponstatus[0]&TBF_JUSTUNLOAD,"Reload3");
		goto loadmag;

	reload:
		#### A 0{
			invoker.weaponstatus[0]&=~TBF_JUSTUNLOAD;
			if(
				invoker.weaponstatus[TBS_BATTERY]<10
				&&countinv("HDMicroCell")
			)setweaponstate("unmag");
		}goto nope;

	loadmag:
		#### A 12 offset(0,42);
		#### AA 2 offset(0,42);
		#### A 2 offset(0,44) A_StartSound("weapons/pocket",9);
		#### A 4 offset(0,43) A_StartSound("weapons/pocket",9);
		#### A 6 offset(0,42);
		#### A 8 offset(0,38)A_StartSound("weapons/phazer_load",8);
		#### A 4 offset(0,36)A_StartSound("weapons/phazer_close",8);

		#### A 0{
			let mmm=HDMagAmmo(findinventory("HDMicroCell"));
			if(mmm)invoker.weaponstatus[TBS_BATTERY]=mmm.TakeMag(true);
		}goto reload3;

	reload3:
		#### A 6 offset(0,40){
			A_StartSound("weapons/phazer_close2",8);
		}
		#### A 2 offset(0,36);
		#### A 4 offset(0,33);
		goto nope;

	user3:
		#### A 0 A_MagManager("HDMicroCell");
		goto ready;

	spawn:
		PHZP A -1;
		stop;
	}
	override void initializewepstats(bool idfa){
		weaponstatus[TBS_BATTERY]=10;
		weaponstatus[PHAZER_CAP]=PHAZER_MAXCAP;
	}
}
