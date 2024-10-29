// ------------------------------------------------------------
// "Hush Puppy" Silenced Pistol - 
//
// "Okay, now sit! Roll Over! Play dead! *twip* Good boy."
// ------------------------------------------------------------

class HushpuppyPistol:HDHandgun{
	default{
		+hdweapon.fitsinbackpack
		+hdweapon.reverseguninertia
		scale 0.63;
		weapon.selectionorder 50;
		weapon.slotnumber 2;
		weapon.slotpriority 0.2;
		weapon.kickback 30;
		weapon.bobrangex 0.1;
		weapon.bobrangey 0.6;
		weapon.bobspeed 2.5;
		weapon.bobstyle "normal";
		obituary "$OB_PUP";
		tag "$TAG_HPUPPY";
		hdweapon.refid "pup";
		hdweapon.barrelsize 29,0.3,0.5;//was 19
		//extended barrel length to account for silencer

        //no loadout codes
	}
	override string pickupmessage(){
		return Stringtable.Localize("$PICKUP_HUSHPUPPY");
	}
	override double weaponbulk(){
		int mgg=weaponstatus[PUPPY_MAG];
		return 42+(mgg<0?0:(ENC_9MAG_LOADED+mgg*ENC_9_LOADED));
	    //was 30,silencer makes it bulkier
	}
	override double gunmass(){
		int mgg=weaponstatus[PUPPY_MAG];
		return 3.5+(mgg<0?0:0.08*(mgg+1));
	}
	override void failedpickupunload(){
		failedpickupunloadmag(PUPPY_MAG,"HD9mMag15");
	}
	override string,double getpickupsprite(bool usespare){
		return "HUSHA0",1.;
	}
	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
			int nextmagloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("HD9mMag15")));
			if(nextmagloaded>=15){
				sb.drawimage("CLP2NORM",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1,1));
			}else if(nextmagloaded<1){
				sb.drawimage("CLP2EMPTY",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextmagloaded?0.6:1.,scale:(1,1));
			}else sb.drawbar(
				"CLP2NORM","CLP2GREY",
				nextmagloaded,15,
				(-46,-3),-1,
				sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
			);
			sb.drawnum(hpl.countinv("HD9mMag15"),-43,-8,sb.DI_SCREEN_CENTER_BOTTOM);
		}
		
		
		sb.drawwepnum(hdw.weaponstatus[PUPPY_MAG],15);
		if(hdw.weaponstatus[PUPPY_CHAMBER]==2)sb.drawrect(-19,-11,3,1);
	}
	
	override string gethelptext(){
		return
		WEPHELP_FIRESHOOT
	    ..WEPHELP_ALTFIRE.."  Rack slide\n"
		..WEPHELP_ALTRELOAD.."  Quick-Swap (if available)\n"
		..WEPHELP_RELOAD.."  Reload mag\n"
		..WEPHELP_ALTFIRE.."+"..WEPHELP_RELOAD.."  Reload chamber\n"
		..WEPHELP_ALTFIRE.."+"..WEPHELP_UNLOAD.."  Unload chamber\n"
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
		vector2 bobb=bob*1.3;

		//never throw sights off line
		//slide always stays locked

		sb.SetClipRect(
			-8+bob.x,-9+bob.y,16,15,
			sb.DI_SCREEN_CENTER
		);
		scc=(0.5,0.5);//was 0.6, smaller sight picture
		
		
		//slight offset to match suppressor sights
		sb.drawimage(
			"frntsite",(0,-2)+bobb,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			scale:scc
		);
		sb.SetClipRect(cx,cy,cw,ch);
		sb.drawimage(
			"backsite",(0,-2)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			alpha:0.9,
			scale:scc
		);
	}
	override void DropOneAmmo(int amt){
		if(owner){
			amt=clamp(amt,1,10);
			if(owner.countinv("HDPistolAmmo"))owner.A_DropInventory("HDPistolAmmo",amt*15);
			else owner.A_DropInventory("HD9mMag15",amt);
		}
	}
	override void ForceBasicAmmo(){
		owner.A_TakeInventory("HDPistolAmmo");
		ForceOneBasicAmmo("HD9mMag15");
	}
	action void A_CheckPistolHand(){
		if(invoker.wronghand)player.getpsprite(PSP_WEAPON).sprite=getspriteindex("PUP2A0");
	}
	
	states{
	select0:
		PUPG A 0{
			if(!countinv("NulledWeapon"))invoker.wronghand=false;
			A_TakeInventory("NulledWeapon");
			A_CheckPistolHand();
		}
		#### A 0 A_JumpIf(invoker.weaponstatus[PUPPY_CHAMBER]>0,2);
		#### C 0;
		---- A 1 A_Raise();
		---- A 1 A_Raise(30);
		---- A 1 A_Raise(30);
		---- A 1 A_Raise(24);
		---- A 1 A_Raise(18);
		wait;
	deselect0:
		PUPG A 0 A_CheckPistolHand();
		#### A 0 A_JumpIf(invoker.weaponstatus[PUPPY_CHAMBER]>0,2);
		#### C 0;
		---- AAA 1 A_Lower();
		---- A 1 A_Lower(18);
		---- A 1 A_Lower(24);
		---- A 1 A_Lower(30);
		wait;

	ready:
		PUPG A 0 A_CheckPistolHand();
		#### A 0 A_JumpIf(invoker.weaponstatus[PUPPY_CHAMBER]>0,2);
		#### C 0;
		#### # 0 A_SetCrosshair(21);
		#### # 1 A_WeaponReady(WRF_ALL);
		goto readyend;
	user3:
		---- A 0 A_MagManager("HD9mMag15");
		goto ready;
	user2:
	firemode:
		goto nope;
		
	//reuse TT-33's sliderack chamber style for more *immersion*
	altfire:
    #### B 3;
	#### B 1 offset(0,34){if(!PressingAltFire())setweaponstate("nope");}

	chamber_start:
		#### C 5 offset(0,37){
			A_MuzzleClimb(frandom(0.4,0.5),-frandom(0.6,0.8));
			A_StartSound("weapons/tt33_load",8);
			int psch=invoker.weaponstatus[PISS_CHAMBER];
			invoker.weaponstatus[PISS_CHAMBER]=0;
			if(psch==2){
				A_EjectCasing("HDPistolAmmo",
				              -frandom(89,92),
				              (frandom(2,3),0,0),
				              (13,0,0));
			}else if(psch==1){
				A_EjectCasing("HDSpent9mm",
				              -frandom(89,92),
				              (frandom(6,7),0,0),
				              (13,0,0));
			}
			if(invoker.weaponstatus[PISS_MAG]>0){
				invoker.weaponstatus[PISS_CHAMBER]=2;
				invoker.weaponstatus[PISS_MAG]--;
			}
		}goto althold;
	
	althold:
	    #### C 1 offset(0,37){if(PressingUnload()){
	              if(invoker.weaponstatus[PISS_CHAMBER]>0)
	                setweaponstate("alt_unchamber");
	            
	                }
	            if(invoker.weaponstatus[PISS_CHAMBER]<1
	            &&PressingReload()
	            &&countinv("HDPistolAmmo")
	              )setweaponstate("alt_chamber");
	            }
	    #### C 0 A_JumpIf(!PressingAltFire(),"althold_end");
	    goto althold;
	    
	alt_chamber:
	    #### C 1 offset(2,36);
	    #### C 1 offset(3,38);
		#### C 1 offset(5,42);
		#### C 1 offset(8,48);
	    #### C 1 offset(7,52);
	   	#### C 3 {
				A_TakeInventory("HDPistolAmmo",1,TIF_NOTAKEINFINITE);
				invoker.weaponstatus[PISS_CHAMBER]=2;
				A_StartSound("weapons/hushpup_chamber1",8,0.3);
		}
		#### C 1 offset(7,52);
		#### C 1 offset(8,48);
		#### C 1 offset(5,42);
		#### C 1 offset(3,38);
		#### C 1 offset(2,36);
        goto althold;
    	
	alt_unchamber:
	    #### C 1 offset(2,36);
	    #### C 1 offset(3,38);
		#### C 1 offset(5,42);
		#### C 1 offset(8,48);
	    #### C 1 offset(7,52);
	    #### C 3 {
			A_MuzzleClimb(frandom(0.4,0.5),-frandom(0.6,0.8));
			A_StartSound("weapons/hushpup_chamber1",8,0.3);
			int psch=invoker.weaponstatus[PISS_CHAMBER];
			invoker.weaponstatus[PISS_CHAMBER]=0;
			if(psch==2){
				A_EjectCasing("HDPistolAmmo",
				-frandom(89,92),
				(frandom(2,3),0,0),
				(13,0,0)
				);
			}
		}
		#### C 1 offset(7,52);
		#### C 1 offset(8,48);
		#### C 1 offset(5,42);
		#### C 1 offset(3,38);
		#### C 1 offset(2,36);
        goto althold;
        
	althold_end:
		#### B 2 offset(0,35);
		#### B 0 A_StartSound("weapons/tt33_chamber",8);
		goto nope;
	
	hold:
		goto nope;
	hold:
		goto nope;
	fire:
		---- A 0{
			invoker.weaponstatus[0]&=~PUPF_JUSTUNLOAD;
			if(invoker.weaponstatus[PUPPY_CHAMBER]==2)setweaponstate("shoot");
			//else if(invoker.weaponstatus[PUPPY_MAG]>0)setweaponstate("chamber_manual");
			//can only work the slide with AltFire
		}goto nope;
	shoot:
		#### B 1{
			if(invoker.weaponstatus[PUPPY_CHAMBER]==2)A_GunFlash();
		}
		#### C 1{
			if(hdplayerpawn(self)){
				hdplayerpawn(self).gunbraced=false;
			}
			A_MuzzleClimb(
				-frandom(0.8,1.),-frandom(1.2,1.6),
				frandom(0.4,0.5),frandom(0.6,0.8)
			);
		}
		#### C 0{
			invoker.weaponstatus[PUPPY_CHAMBER]=1;//do not eject casing automatically
			if(invoker.weaponstatus[PUPPY_MAG]<1){
				setweaponstate("nope");
			}
		}
		
		#### B 1;
		goto nope;//do nothing until the Fire button is released
	flash:
		PP2F A 0 A_JumpIf(invoker.wronghand,2);
		PUPF A 0;
		---- A 1 bright{
			HDFlashAlpha(64);
			A_Light1();
			let bbb=HDBulletActor.FireBullet(self,"HDB_9",spread:3.,speedfactor:frandom(0.83,0.89));
			//same as Sten, subsonic muzzle velocity
			//has poorer accuracy due to suppressor sights being imprecise
			if(
				frandom(0,ceilingz-floorz)<bbb.speed*0.3
			)A_AlertMonsters(64);//was 256, quieter than the Sten

			invoker.weaponstatus[PUPPY_CHAMBER]=1;
			A_ZoomRecoil(0.995);
			A_MuzzleClimb(-frandom(0.4,1.2),-frandom(0.4,1.6));
		}
		---- A 0 A_StartSound("weapons/hushpup_fire",CHAN_WEAPON,volume:0.5);//same gunshot sound as Sten, but quieter
		---- A 0 A_Light0();
		stop;
		
	unload://only unloads mag
		---- A 0{
			invoker.weaponstatus[0]|=PUPF_JUSTUNLOAD;
			if(invoker.weaponstatus[PUPPY_MAG]>=0)setweaponstate("unmag");
		}goto nope;//must hold slide open to unchamber


	reload://only loads mags
		---- A 0{
			invoker.weaponstatus[0]&=~PUPF_JUSTUNLOAD;
			bool nomags=HDMagAmmo.NothingLoaded(self,"HD9mMag15");
			if(invoker.weaponstatus[PUPPY_MAG]>=15)setweaponstate("nope");
			else if(nomags)setweaponstate("nope");
		}goto unmag;
	unmag:
		---- A 1 offset(0,34) A_SetCrosshair(21);
		---- A 1 offset(1,38);
		---- A 2 offset(2,42);
		---- A 3 offset(3,46) A_StartSound("weapons/pismagclick",8,CHANF_OVERLAP);
		---- A 0{
			int pmg=invoker.weaponstatus[PUPPY_MAG];
			invoker.weaponstatus[PUPPY_MAG]=-1;
			if(pmg<0)setweaponstate("magout");
			else if(
				(!PressingUnload()&&!PressingReload())
				||A_JumpIfInventory("HD9mMag15",0,"null")
			){
				HDMagAmmo.SpawnMag(self,"HD9mMag15",pmg);
				setweaponstate("magout");
			}
			else{
				HDMagAmmo.GiveMag(self,"HD9mMag15",pmg);
				A_StartSound("weapons/pocket",9);
				setweaponstate("pocketmag");
			}
		}
	pocketmag:
		---- AAA 5 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		goto magout;
	magout:
		---- A 0{
			if(invoker.weaponstatus[0]&PUPF_JUSTUNLOAD)setweaponstate("reloadend");
			else setweaponstate("loadmag");
		}

	loadmag:
		---- A 4 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		---- A 0 A_StartSound("weapons/pocket",9);
		---- A 5 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		---- A 3;
		---- A 0{
			let mmm=hdmagammo(findinventory("HD9mMag15"));
			if(mmm){
				invoker.weaponstatus[PUPPY_MAG]=mmm.TakeMag(true);
				A_StartSound("weapons/hushpup_magclick",8);
			}
		}
		goto reloadend;

	reloadend:
		---- A 2 offset(3,46);
		---- A 1 offset(2,42);
		---- A 1 offset(2,38);
		---- A 1 offset(1,34);
	  //---- A 0 A_JumpIf(!(invoker.weaponstatus[0]&PUPF_JUSTUNLOAD),"chamber_manual");
	  //no auto-chambering, you have to chamber manually
	  //after inserting a new mag
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
		PUPG A 0 A_CheckPistolHand();
		goto nope;
	lowerleft:
		PUPG A 0 A_JumpIf(Wads.CheckNumForName("id",0)!=-1,2);
		PUP2 A 0;
		#### B 1 offset(-6,38);
		#### B 1 offset(-12,48);
		#### B 1 offset(-20,60);
		#### B 1 offset(-34,76);
		#### B 1 offset(-50,86);
		stop;
	lowerright:
		PUP2 A 0 A_JumpIf(Wads.CheckNumForName("id",0)!=-1,2);
		PUPG A 0;
		#### B 1 offset(6,38);
		#### B 1 offset(12,48);
		#### B 1 offset(20,60);
		#### B 1 offset(34,76);
		#### B 1 offset(50,86);
		stop;
	raiseleft:
		PUPG A 0 A_JumpIf(Wads.CheckNumForName("id",0)!=-1,2);
		PUP2 A 0;
		#### A 1 offset(-50,86);
		#### A 1 offset(-34,76);
		#### A 1 offset(-20,60);
		#### A 1 offset(-12,48);
		#### A 1 offset(-6,38);
		stop;
	raiseright:
		PUP2 A 0 A_JumpIf(Wads.CheckNumForName("id",0)!=-1,2);
		PUPG A 0;
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
		PUPG A 0{
			invoker.wronghand=!invoker.wronghand;
			A_CheckPistolHand();
		}
		#### B 1 offset(0,76);
		#### B 1 offset(0,60);
		#### B 1 offset(0,48);
		goto nope;


	spawn:
	    HUSH A -1;
	    stop;
	}
	override void initializewepstats(bool idfa){
		weaponstatus[PUPPY_MAG]=15;
		weaponstatus[PUPPY_CHAMBER]=2;
	}
	override void loadoutconfigure(string input){
	}
}
enum hushpuppystatus{
	PUPF_SELECTFIRE=1,//unused
	PUPF_FIREMODE=2,
	PUPF_JUSTUNLOAD=4,

	PUPPY_FLAGS=0,
	PUPPY_MAG=1,
	PUPPY_CHAMBER=2, //0 empty, 1 spent, 2 loaded
};
