//------------------------------------------------------------------------------
// Juan! Juan. 
//------------------------------------------------------------------------------
//credit for weapon name goes to .BenitezClance4 from the HD Discord

class HDHorseshoePistol:HDHandgun{
    bool MAG_15;
    bool MAG_30;
    bool FORCE_15;
    
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
		obituary "$OB_JUAN";
		tag "$TAG_JUANPIS";
		hdweapon.refid "jua";
		hdweapon.barrelsize 19,0.3,0.5;

		hdweapon.loadoutcodes "
			\cuselectfire - 0/1, whether it has a fire selector
			\cufiremode - 0/1, semi/auto, subject to the above";
	}

	override void postbeginplay(){
		super.postbeginplay();
		weaponspecial=1337;
	}

	override string pickupmessage(){
		return Stringtable.Localize("$PICKUP_JUANPISTOL");
	}

	override double weaponbulk(){
		int result = 17;
		
		// Magazine bulk. 
		if(weaponstatus[HPISS_MAG] >= 0)
		{
			result += ENC_9MAG_EMPTY*2;
		}
		int mgg=weaponstatus[HPISS_MAG];
		return result+(mgg<0?0:(ENC_9MAG_LOADED+mgg*ENC_9_LOADED));
	}
	//updated gunmass to match standard pistol's formula,
	//was a lot heavier than it should have been
	override double gunmass(){
		int mgg=weaponstatus[HPISS_MAG];
		return 3.5+(mgg<0?0:0.08*(mgg+1));
	}
	override void failedpickupunload(){
	if(MAG_15)failedpickupunloadmag(HPISS_MAG,"hd9mmag15");
	else failedpickupunloadmag(HPISS_MAG,"hdhorseshoe9m");
	}
	
	override string,double getpickupsprite(bool usespare)
    {
        string sprind;
        string sprname="HPIS";
        
        if(GetSpareWeaponValue(0,usespare)&PISF_SELECTFIRE)
        {
			// For ammo reloads via cheats. 
			if(GetSpareWeaponValue(HPISS_MAG, usespare) >= 0&&MAG_30)
			{
				if(GetSpareWeaponValue(HPISS_CHAMBER, usespare)<1)
					sprind="F";
				else
					sprind="E";
			}
			else
			{
				if(GetSpareWeaponValue(HPISS_CHAMBER, usespare)<1)
					sprind="H";
				else
					sprind="G";
			}
        }
        else
		{
			// For ammo reloads via cheats. 
			if(GetSpareWeaponValue(HPISS_MAG, usespare) >= 0&&MAG_30)
			{
				if(GetSpareWeaponValue(HPISS_CHAMBER, usespare)<1)
					sprind="B";
				else
					sprind="A";
			}
			else
			{
				if(GetSpareWeaponValue(HPISS_CHAMBER, usespare)<1)
					sprind="D";
				else
					sprind="C";
			}
		}
        return sprname..sprind.."0",1.;
    }

	// Carbon copy of getpickupsprite for spawned weapons. 
	int	getframeindex()
	{

		int frind = 0;
		
		// Checks for full auto. 
		if((weaponstatus[0]&HPISF_SELECTFIRE))
		{
		frind += 4;
		}
		
		// For ammo reloads via cheats. 
		if(weaponstatus[HPISS_MAG] >= 0&&MAG_30)
		{
			if(weaponstatus[HPISS_CHAMBER]<1)
				frind+=1;
			else
				frind+=0;
		}
		else
		{
			if(weaponstatus[HPISS_CHAMBER]<1)
				frind+=3;
			else
				frind+=2;
		}
		return frind;
	}

	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
		
		//horseshoe mags
			int nextmagloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("hdhorseshoe9m")));
			if(nextmagloaded>=30){
				sb.drawimage("HSMGA0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(2,2));
			}else if(nextmagloaded<1){
				sb.drawimage("HSMGC0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextmagloaded?0.6:1.,scale:(2,2));
			}else
			{
				// Rescaling doesn't seem to work with sb.drawbar, so this'll have to do. 
				sb.drawimage("HSMGA0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextmagloaded?0.6:1.,scale:(2,2));
			}
			
		//standard pistol mags
			int nextpmagloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("HD9mMag15")));
			if(nextpmagloaded>=15){
				sb.drawimage("CLP2NORM",(-56,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1,1));
			}else if(nextpmagloaded<1){
				sb.drawimage("CLP2EMPTY",(-56,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextpmagloaded?0.6:1.,scale:(1,1));
			}else sb.drawbar(
				"CLP2NORM","CLP2GREY",
				nextpmagloaded,15,
				(-56,-3),-1,
				sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
			);

			sb.drawnum(hpl.countinv("hdhorseshoe9m"),-43,-8,sb.DI_SCREEN_CENTER_BOTTOM);
	        sb.drawnum(hpl.countinv("hd9mmag15"),-53,-8,sb.DI_SCREEN_CENTER_BOTTOM);
	
		}
		if(hdw.weaponstatus[0]&HPISF_SELECTFIRE)sb.drawwepcounter(hdw.weaponstatus[0]&HPISF_FIREMODE,
			-22,-10,"RBRSA3A7","STFULAUT"
		);
		
		//sb.drawwepnum(hdw.weaponstatus[HPISS_MAG],30);
		//first value is current ammo left, second is max ammo capacity
		
		//use same code as PPSh-41 for drawing second ammobar
		sb.drawwepnum(hdw.weaponstatus[HPISS_MAG],
		              hdw.weaponstatus[HPISS_MAG]>15?
		              hdw.weaponstatus[HPISS_MAG]:15,-16);
		              //simple hack to make sure it never draws yellow "overload" tick 
		              //if >15 rounds when horseshoe mag is loaded
		              
		//draw second ammobar if more than 15 rounds left (i.e. horseshoe mag loaded)
		if(hdw.weaponstatus[HPISS_MAG]>15)
	    	sb.drawwepnum(hdw.weaponstatus[HPISS_MAG]-15,15,-16,-2);

		if(hdw.weaponstatus[HPISS_CHAMBER]==2)sb.drawrect(-19,-11,3,1);
	}
	override string gethelptext(){
		LocalizeHelp();
		return
		LWPHELP_FIRESHOOT
		..((weaponstatus[0]&HPISF_SELECTFIRE)?(LWPHELP_FIREMODE..Stringtable.Localize("$JUAN_HELPTEXT_1")):"")
		..LWPHELP_ALTRELOAD..Stringtable.Localize("$JUAN_HELPTEXT_2")
		..LWPHELP_RELOAD..Stringtable.Localize("$JUAN_HELPTEXT_3")
		..LWPHELP_FIREMODE.."+"..LWPHELP_RELOAD..Stringtable.Localize("$JUAN_HELPTEXT_4")
		..LWPHELP_USE.."+"..LWPHELP_RELOAD..Stringtable.Localize("$JUAN_HELPTEXT_5")
		..LWPHELP_MAGMANAGER
		..LWPHELP_UNLOADUNLOAD
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
			alpha:1,
			scale:scc
		);
	}
	override void DropOneAmmo(int amt){
		if(owner){
			amt=clamp(amt,1,10);
			if(owner.countinv("HDPistolAmmo"))owner.A_DropInventory("HDPistolAmmo",amt*30);
			else owner.A_DropInventory("hdhorseshoe9m",amt);
		}
	}
	override void ForceBasicAmmo(){
		owner.A_TakeInventory("HDPistolAmmo");
		ForceOneBasicAmmo("hdhorseshoe9m");
	}
	action void A_CheckPistolHand(){
		if(invoker.wronghand)player.getpsprite(PSP_WEAPON).sprite=getspriteindex("PI2GA0");
	}
	
	//updated to use new pistol sprite index
	states{
	select0:
		PI1G A 0{
			if(!countinv("NulledWeapon"))invoker.wronghand=false;
			A_TakeInventory("NulledWeapon");
			A_CheckPistolHand();
		}
		#### A 0 A_JumpIf(invoker.weaponstatus[HPISS_CHAMBER]>0,2);
		#### C 0;
		---- A 1 A_Raise();
		---- A 1 A_Raise(30);
		---- A 1 A_Raise(30);
		---- A 1 A_Raise(24);
		---- A 1 A_Raise(18);
		wait;
	deselect0:
		PI1G A 0 A_CheckPistolHand();
		#### A 0 A_JumpIf(invoker.weaponstatus[HPISS_CHAMBER]>0,2);
		#### C 0;
		---- AAA 1 A_Lower();
		---- A 1 A_Lower(18);
		---- A 1 A_Lower(24);
		---- A 1 A_Lower(30);
		wait;

	ready:
		PI1G A 0 A_CheckPistolHand();
		#### A 0 A_JumpIf(invoker.weaponstatus[HPISS_CHAMBER]>0,2);
		#### C 0;
		#### # 0 A_SetCrosshair(21);
		#### # 1 {A_WeaponReady(WRF_ALL);
		        invoker.FORCE_15=FALSE;
		        }
		goto readyend;
	
	user3:
		---- A 0 A_MagManager("hdhorseshoe9m");
		goto ready;
	user2:
	firemode:
		---- A 0{
			if(invoker.weaponstatus[0]&HPISF_SELECTFIRE)
			invoker.weaponstatus[0]^=HPISF_FIREMODE;
			else invoker.weaponstatus[0]&=~HPISF_FIREMODE;
		}
	fmhold:
	    ---- A 1;
		---- A 1{if(PressingReload())
		            {invoker.FORCE_15=true;
		             setweaponstate("reload2");
		            }else if(PressingFireMode())setweaponstate("fmhold");
	}
		goto nope;
	altfire:
		---- A 0{
			invoker.weaponstatus[0]&=~HPISF_JUSTUNLOAD;
			if(
				invoker.weaponstatus[HPISS_CHAMBER]!=2
				&&invoker.weaponstatus[HPISS_MAG]>0
			)setweaponstate("chamber_manual");
		}goto nope;
	chamber_manual:
		---- A 0 A_JumpIf(
			!(invoker.weaponstatus[0]&HPISF_JUSTUNLOAD)
			&&(
				invoker.weaponstatus[HPISS_CHAMBER]==2
				||invoker.weaponstatus[HPISS_MAG]<1
			)
			,"nope"
		);
		#### B 3 offset(0,34);
		#### C 4 offset(0,37){
			A_MuzzleClimb(frandom(0.4,0.5),-frandom(0.6,0.8));
			A_StartSound("weapons/juan_chamber2",8);
			int psch=invoker.weaponstatus[HPISS_CHAMBER];
			invoker.weaponstatus[HPISS_CHAMBER]=0;
			if(psch==2){
				A_EjectCasing("HDPistolAmmo",-frandom(89,92),(frandom(2,3),0,0),(13,0,0));
			}else if(psch==1){
				A_EjectCasing("HDSpent9mm",-frandom(89,92),(frandom(6,7),0,0),(13,0,0));
			}
			if(invoker.weaponstatus[HPISS_MAG]>0){
				invoker.weaponstatus[HPISS_CHAMBER]=2;
				invoker.weaponstatus[HPISS_MAG]--;
			}
		}
		#### B 3 offset(0,35);
		goto nope;
	althold:
	hold:
		goto nope;
	fire:
		---- A 0{
			invoker.weaponstatus[0]&=~HPISF_JUSTUNLOAD;
			if(invoker.weaponstatus[HPISS_CHAMBER]==2)setweaponstate("shoot");
			else if(invoker.weaponstatus[HPISS_MAG]>0)setweaponstate("chamber_manual");
		}goto nope;
	shoot:
		#### B 1{
			if(invoker.weaponstatus[HPISS_CHAMBER]==2)A_GunFlash();
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
			A_EjectCasing("HDSpent9mm",-frandom(89,92),(frandom(6,7),0,0),(13,0,0));
			invoker.weaponstatus[HPISS_CHAMBER]=0;
			if(invoker.weaponstatus[HPISS_MAG]<1){
				A_StartSound("weapons/juan_dry",8,CHANF_OVERLAP,0.9);
				setweaponstate("nope");
			}
		}
		#### B 1{
			A_WeaponReady(WRF_NOFIRE);
			invoker.weaponstatus[HPISS_CHAMBER]=2;
			invoker.weaponstatus[HPISS_MAG]--;
			if(
				(invoker.weaponstatus[0]&(HPISF_FIREMODE|HPISF_SELECTFIRE))
				==(HPISF_FIREMODE|HPISF_SELECTFIRE)
			){
				
				A_GiveInventory("IsMoving",5);
				A_Refire("fire");
			}else A_Refire();
		}goto ready;
	flash:
		PI2F A 0 A_JumpIf(invoker.wronghand,2);
		PISF A 0;
		---- A 1 bright{
			HDFlashAlpha(64);
			A_Light1();
			let bbb=HDBulletActor.FireBullet(self,"HDB_9",spread:2.,speedfactor:frandom(0.97,1.03));
			if(
				frandom(0,ceilingz-floorz)<bbb.speed*0.3
			)A_AlertMonsters(256);

			invoker.weaponstatus[HPISS_CHAMBER]=1;
			A_ZoomRecoil(0.995);
			
			
			int recoilmod = 30;
			double muzzlemod = 0.035;
			
			// More predictable recoil while filled.
			double muzzle1 = 0.4;
			double muzzle2 = 1.0;
			
			double muzzle3 = 0.6;
			double muzzle4 = 1.2;
			
			recoilmod -= invoker.weaponstatus[HPISS_MAG];
			muzzlemod *= recoilmod;
			
			A_MuzzleClimb(
			-frandom(muzzle1 + muzzlemod, muzzle2 + (muzzlemod/2)),
			-frandom(muzzle3 + muzzlemod, muzzle4 + (muzzlemod/2)));
		}
		---- A 0 A_StartSound("weapons/juan_fire",CHAN_WEAPON);
		---- A 0 A_Light0();
		stop;
	unload:
		---- A 0{
			invoker.weaponstatus[0]|=HPISF_JUSTUNLOAD;
			if(invoker.weaponstatus[HPISS_MAG]>=0&&invoker.MAG_30)setweaponstate("unmag");
			if(invoker.weaponstatus[HPISS_MAG]>=0&&invoker.MAG_15)setweaponstate("unmag2");
		}goto chamber_manual;
	loadchamber:
		---- A 0 A_JumpIf(invoker.weaponstatus[HPISS_CHAMBER]>0,"nope");
		---- A 1 offset(0,36) A_StartSound("weapons/pocket",9);
		---- A 1 offset(2,40);
		---- A 1 offset(2,50);
		---- A 1 offset(3,60);
		---- A 2 offset(5,90);
		---- A 2 offset(7,80);
		---- A 2 offset(10,90);
		#### C 2 offset(8,96);
		#### C 3 offset(6,88){
			if(countinv("HDPistolAmmo")){
				A_TakeInventory("HDPistolAmmo",1,TIF_NOTAKEINFINITE);
				invoker.weaponstatus[HPISS_CHAMBER]=2;
				A_StartSound("weapons/juan_chamber1",8);
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
	    ---- A 0 A_JumpIf(invoker.MAG_15,"reload2");
		---- A 0
			{
			invoker.weaponstatus[0]&=~HPISF_JUSTUNLOAD;
			bool nomags=HDMagAmmo.NothingLoaded(self,"hdhorseshoe9m");
			if(invoker.weaponstatus[HPISS_MAG]>=30)setweaponstate("nope");
			else if(
				invoker.weaponstatus[HPISS_MAG]<1
				&&(
					pressinguse()
					||nomags
				)
			){
				if(
					countinv("HDPistolAmmo")
				)setweaponstate("loadchamber");
			}else if(nomags)setweaponstate("nope");
		}
		goto unmag;
	
	unmag:
		---- A 1 offset(0,34) A_SetCrosshair(21);
		---- A 1 offset(1,38);
		---- A 2 offset(2,42);
		---- A 3 offset(3,46) A_StartSound("weapons/juan_magclick",8,CHANF_OVERLAP);
		---- A 0{
			int pmg=invoker.weaponstatus[HPISS_MAG];
			invoker.weaponstatus[HPISS_MAG]=-1;
			if(pmg<0)setweaponstate("magout");
			else if(    //horseshoe mags
				(!PressingUnload()&&!PressingReload())
				||A_JumpIfInventory("hdhorseshoe9m",0,"null")
			){
				HDMagAmmo.SpawnMag(self,"hdhorseshoe9m",pmg);
				invoker.MAG_30 = false;
				setweaponstate("magout");
			}
			else{
				HDMagAmmo.GiveMag(self,"hdhorseshoe9m",pmg);
				A_StartSound("weapons/pocket",9);
				invoker.MAG_30 = false;
				setweaponstate("pocketmag");
			}
			
		}
		
	pocketmag:
		---- AAA 5 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		goto magout;
	
	magout:
		---- A 0{
			if(invoker.weaponstatus[0]&HPISF_JUSTUNLOAD)setweaponstate("reloadend");
    		else if(invoker.FORCE_15)setweaponstate("loadmag2");
	
    		else setweaponstate("loadmag");
		}

	loadmag:
	    ---- A 0 A_JumpIf(!countinv("hdhorseshoe9m"),"loadmag2");
		---- A 4 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		---- A 0 A_StartSound("weapons/pocket",9);
		---- A 5 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		---- A 3;
		---- A 0{
			let mmm=hdmagammo(findinventory("hdhorseshoe9m"));
			if(mmm){
				invoker.weaponstatus[HPISS_MAG]=mmm.TakeMag(true);
				A_StartSound("weapons/juan_magclick",8);
				invoker.MAG_30 = true;
				invoker.MAG_15 = false;
				setweaponstate("reloadend");
			}
		}
		goto reloadend;
	
	reload2:
		---- A 0
			{				
			invoker.weaponstatus[0]&=~HPISF_JUSTUNLOAD;
			bool nomags=HDMagAmmo.NothingLoaded(self,"hd9mmag15");
			if(invoker.weaponstatus[HPISS_MAG]>=15)setweaponstate("nope");
			else if(
				invoker.weaponstatus[HPISS_MAG]<1
				&&(
					pressinguse()
					||nomags
				)
			){
				if(
					countinv("HDPistolAmmo")
				)setweaponstate("loadchamber");
			}else if(nomags)setweaponstate("nope");
		}
		---- A 0 A_Jumpif(invoker.MAG_15,"unmag2");
		goto unmag;
	
	unmag2:
		---- A 1 offset(0,34) A_SetCrosshair(21);
		---- A 1 offset(1,38);
		---- A 2 offset(2,42);
		---- A 3 offset(3,46)
		{
			A_StartSound("weapons/juan_magclick",8,CHANF_OVERLAP);
		}
		---- A 0{
			int pmg=invoker.weaponstatus[HPISS_MAG];
			invoker.weaponstatus[HPISS_MAG]=-1;
			
			if(pmg<0)setweaponstate("magout2");
			else if(   //standard mags
				(!PressingUnload()&&!PressingReload())
				||A_JumpIfInventory("hd9mmag15",0,"null")
			){
				HDMagAmmo.SpawnMag(self,"hd9mmag15",pmg);
				invoker.MAG_15 = false;
				setweaponstate("magout2");
			}
			else{
				HDMagAmmo.GiveMag(self,"hd9mmag15",pmg);
				A_StartSound("weapons/pocket",9);
				invoker.MAG_15 = false;
				setweaponstate("pocketmag2");
			}
		}
	
	pocketmag2:
		---- AAA 5 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		goto magout2;
		
	magout2:
		---- A 0{
			if(invoker.weaponstatus[0]&HPISF_JUSTUNLOAD)setweaponstate("reloadend");
			else setweaponstate("loadmag2");
		}
		
    loadmag2:
		---- A 4 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		---- A 0 A_StartSound("weapons/pocket",9);
		---- A 5 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		---- A 3 ;
		---- A 0{
			let mmm=hdmagammo(findinventory("hd9mmag15"));
			if(mmm){
				invoker.weaponstatus[HPISS_MAG]=mmm.TakeMag(true);
				A_StartSound("weapons/juan_magclick",8);
				invoker.MAG_15 = true;
				invoker.MAG_30 = false;
				setweaponstate("reloadend");
			}
		}
		goto reloadend;

	reloadend:
		---- A 2 offset(3,46);
		---- A 1 offset(2,42);
		---- A 1 offset(2,38);
		---- A 1 offset(1,34);
		---- A 0 A_JumpIf(!(invoker.weaponstatus[0]&HPISF_JUSTUNLOAD),"chamber_manual");
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
		PI1G A 0 A_CheckPistolHand();
		goto nope;
	lowerleft:
		PI1G A 0 A_JumpIf(Wads.CheckNumForName("id",0)!=-1,2);
		PI2G A 0;
		#### B 1 offset(-6,38);
		#### B 1 offset(-12,48);
		#### B 1 offset(-20,60);
		#### B 1 offset(-34,76);
		#### B 1 offset(-50,86);
		stop;
	lowerright:
		PI2G A 0 A_JumpIf(Wads.CheckNumForName("id",0)!=-1,2);
		PI1G A 0;
		#### B 1 offset(6,38);
		#### B 1 offset(12,48);
		#### B 1 offset(20,60);
		#### B 1 offset(34,76);
		#### B 1 offset(50,86);
		stop;
	raiseleft:
		PI1G A 0 A_JumpIf(Wads.CheckNumForName("id",0)!=-1,2);
		PI2G A 0;
		#### A 1 offset(-50,86);
		#### A 1 offset(-34,76);
		#### A 1 offset(-20,60);
		#### A 1 offset(-12,48);
		#### A 1 offset(-6,38);
		stop;
	raiseright:
		PI2G A 0 A_JumpIf(Wads.CheckNumForName("id",0)!=-1,2);
		PI1G A 0;
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
		PI1G A 0{
			invoker.wronghand=!invoker.wronghand;
			A_CheckPistolHand();
		}
		#### B 1 offset(0,76);
		#### B 1 offset(0,60);
		#### B 1 offset(0,48);
		goto nope;

	spawn:
		HPIS A -1 nodelay
		{
			frame = invoker.getframeindex();
		}
		stop;
	}
	override void initializewepstats(bool idfa){
		weaponstatus[HPISS_MAG]=30;
		weaponstatus[HPISS_CHAMBER]=2;
		MAG_30 = true;
		MAG_15 = false;
	}
	override void loadoutconfigure(string input){
		int selectfire=getloadoutvar(input,"selectfire",1);
		if(!selectfire){
			weaponstatus[0]&=~HPISF_SELECTFIRE;
			weaponstatus[0]&=~HPISF_FIREMODE;
		}else if(selectfire>0){
			weaponstatus[0]|=HPISF_SELECTFIRE;
		}
		if(weaponstatus[0]&HPISF_SELECTFIRE){
			int firemode=getloadoutvar(input,"firemode",1);
			if(!firemode)weaponstatus[0]&=~HPISF_FIREMODE;
			else if(firemode>0)weaponstatus[0]|=HPISF_FIREMODE;
		}
	}
}

// Workaround for Merchants compat and random drops. Not a real variant. 
// A dirty fix, but this is the best I could come up with. 
class HDHorseshoePistolAuto : HDMobBase
{
	states
	{
		spawn:
			TNT1 A 0 NODELAY
			{
				// Spawns a brand new pistol. 
				let www = DropNewWeapon("HDHorseshoePistol");
				// Makes it full auto (even works indoors!). 
				www.weaponstatus[0] |= 1;
			}
			stop;
	}
}

enum juan_pistolstatus
{
	HPISF_SELECTFIRE=1,
	HPISF_FIREMODE=2,
	HPISF_JUSTUNLOAD=4,

	HPISS_FLAGS=0,
	HPISS_MAG=1,
	HPISS_CHAMBER=2, //0 empty, 1 spent, 2 loaded
};

//use this to give an autopistol in a custom loadout
class HDHorseshoeAutoPistol:HDWeaponGiver
{
	default{
		tag "$TAG_JUANAUTO";
		hdweapongiver.bulk 34;
		hdweapongiver.weapontogive "HDHorseshoePistol";
		hdweapongiver.config "selectfire";
		hdweapongiver.weprefid "hrs";
		inventory.icon "HPISA0";
	}
}
