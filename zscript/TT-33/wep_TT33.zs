//------------------------------------------------------------
// 7.62mm Tokarev Pistol
// ------------------------------------------------------------

const ENC_TOKAREV_MAG8=9;
const ENC_TOKAREV_MAG8_EMPTY=ENC_TOKAREV_MAG8*0.3;
const ENC_TOKAREV_MAG8_LOADED=ENC_TOKAREV_MAG8_EMPTY*0.1;

class HDTokarevMag8:HDMagAmmo{
	default{
		//$Category "Ammo/Hideous Destructor/"
		//$Title "Tokarev Pistol Magazine"
		//$Sprite "TMG8A0"
		hdmagammo.maxperunit 8;
		hdmagammo.roundtype "HD762TokarevAmmo";
		hdmagammo.roundbulk ENC_762TOKAREV_LOADED;
		hdmagammo.magbulk ENC_TOKAREV_MAG8_EMPTY; 
		scale 0.35;
		tag "$TAG_TT33MAG";
		hdpickup.refid "TM8";
	}

    override string pickupmessage(){
		return Stringtable.Localize("$PICKUP_TT33MAG");
	}

	override string,string,name,double getmagsprite(int thismagamt){
		string magsprite=(thismagamt>0)?"TMG8A0":"TMG8C0";
		return magsprite,"T762A0","HD762TokarevAmmo",0.6;
	}
	override void GetItemsThatUseThis(){
		itemsthatusethis.push("HDTT33Pistol");
	}
	states{
	spawn:
		TMG8 A -1;
		stop;
	spawnempty:
		TMG8 B -1{
			brollsprite=true;brollcenter=true;
			roll=randompick(0,0,0,0,2,2,2,2,1,3)*90;
		}stop;
	}
}

class HDTokarevPistolEmptyMag:IdleDummy{
	override void postbeginplay(){
		super.postbeginplay();
		HDMagAmmo.SpawnMag(self,"HDTokarevMag8",0);
		destroy();
	}
}

class HDTT33Pistol:HDHandgun{
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
		obituary "$OB_TT33";
		tag "$TAG_TT33";
		hdweapon.refid "t33";
		hdweapon.barrelsize 19,0.3,0.5;

		hdweapon.loadoutcodes "
			\cuselectfire - 0/1, whether it has a fire selector
			\cufiremode - 0/1, semi/auto, subject to the above";
	}
    int TT33_GUNDAMAGE;//tracks how messed up you gun is

	override string pickupmessage(){
		return Stringtable.Localize("$PICKUP_TT33");
	}

	override double weaponbulk(){
		int mgg=weaponstatus[PISS_MAG];
		return 40+(mgg<0?0:(ENC_TOKAREV_MAG8_LOADED+mgg*ENC_762TOKAREV_LOADED));
	}
	override double gunmass(){
		int mgg=weaponstatus[PISS_MAG];
		return 8+(mgg<0?0:0.25*(mgg+1));
	}
	override void failedpickupunload(){
		failedpickupunloadmag(PISS_MAG,"HDTokarevMag8");
	}
	
	override string,double getpickupsprite(bool usespare){
		string spr;
		int wep0=GetSpareWeaponValue(0,usespare);
		if(GetSpareWeaponValue(PISS_CHAMBER,usespare)<1
		){
			if(wep0&PISF_SELECTFIRE)spr="D";
			else spr="B";
		}else{
			if(wep0&PISF_SELECTFIRE)spr="C";
			else spr="A";
		}
		return "TKRV"..spr.."0",1.;
	}

	//grime mechanic borrowed from Boss rifle
	
	action void A_ChamberGrit(int amt,bool onlywhileempty=false){
		int ibg=invoker.TT33_GUNDAMAGE;
		
		if(!onlywhileempty||invoker.weaponstatus[PISS_CHAMBER]<1)ibg+=amt;
		else if(!random(0,4))ibg++;
		invoker.TT33_GUNDAMAGE=clamp(ibg,0,100);
		if(hd_debug)A_Log(string.format("TT-33 grit level: %i",invoker.TT33_GUNDAMAGE));
	}
	
	override void GunBounce(){
		super.GunBounce();
		TT33_GUNDAMAGE+=random(TT33_GUNDAMAGE>=30?-5:0,5);
		//throwing your gun has a chance to damage, or 
		//sometimes even improve its condition,
		//depending on how dirty it is
	}
	
	//random dirtiness across levels,
	//make sure to maintain your guns
    override void consolidate(){
		TT33_GUNDAMAGE=random(0,30);
	}

  override void postbeginplay(){
		super.postbeginplay();
  		weaponspecial=1337;
	}
  
	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
			int nextmagloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("HDTokarevMag8")));
			if(nextmagloaded>=8){
				sb.drawimage("TMG8A0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1,1));
			}else if(nextmagloaded<1){
				sb.drawimage("TMG8MPTY",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextmagloaded?0.6:1.,scale:(1,1));
			}else sb.drawbar(
				"TMG8A0","TMG8GREY",
				nextmagloaded,8,
				(-46,-3),-1,
				sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
			);
			sb.drawnum(hpl.countinv("HDTokarevMag8"),-43,-8,sb.DI_SCREEN_CENTER_BOTTOM);
		}
		if(hdw.weaponstatus[0]&PISF_SELECTFIRE)sb.drawwepcounter(hdw.weaponstatus[0]&PISF_FIREMODE,
			-22,-10,"RBRSA3A7","STFULAUT"
		);
		sb.drawwepnum(hdw.weaponstatus[PISS_MAG],8);
		if(hdw.weaponstatus[PISS_CHAMBER]==2)sb.drawrect(-19,-11,3,1);
	}
	override string gethelptext(){
		return
		WEPHELP_FIRESHOOT
		..((weaponstatus[0]&PISF_SELECTFIRE)?(WEPHELP_FIREMODE.."  Semi/Auto\n"):"")
	    ..WEPHELP_ALTFIRE.."  Rack slide\n"
		..WEPHELP_ALTRELOAD.."  Quick-Swap (if available)\n"
		..WEPHELP_RELOAD.."  Reload mag\n"
		..WEPHELP_ALTFIRE.."+"..WEPHELP_RELOAD.."  Reload chamber\n"
		..WEPHELP_ALTFIRE.."+"..WEPHELP_UNLOAD.."  Unload chamber/Clean pistol\n"
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
			"tt33bkst",(0,0)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			alpha:0.9,
			scale:scc
		);
	}
	override void DropOneAmmo(int amt){
		if(owner){
			amt=clamp(amt,1,10);
			if(owner.countinv("HD762TokarevAmmo"))owner.A_DropInventory("HD762TokarevAmmo",amt*8);
			else owner.A_DropInventory("HDTokarevMag8",amt);
		}
	}
	override void ForceBasicAmmo(){
		owner.A_TakeInventory("HD762TokarevAmmo");
		ForceOneBasicAmmo("HDTokarevMag8");
	}
	
	action void A_CheckPistolHand(){
		if(invoker.wronghand)player.getpsprite(PSP_WEAPON).sprite=getspriteindex("T233A0");
	}
	states{
	select0:
		TT33 A 0{
		    if(invoker.weaponstatus[PISS_MAG]>8)invoker.weaponstatus[PISS_MAG]=8;
			if(!countinv("NulledWeapon"))invoker.wronghand=false;
			A_TakeInventory("NulledWeapon");
			A_CheckPistolHand();
		}
		#### A 0 A_JumpIf(invoker.weaponstatus[PISS_CHAMBER]>0,2);
		#### C 0;
		---- # 1 A_Raise();
		---- # 1 A_Raise(30);
		---- # 1 A_Raise(30);
		---- # 1 A_Raise(24);
		---- # 1 A_Raise(18);
		wait;
	deselect0:
		TT33 A 0 A_CheckPistolHand();
		#### A 0 A_JumpIf(invoker.weaponstatus[PISS_CHAMBER]>0,2);
		#### C 0;
		---- ### 1 A_Lower();
		---- # 1 A_Lower(18);
		---- # 1 A_Lower(24);
		---- # 1 A_Lower(30);
		wait;

	ready:
		TT33 A 0 A_CheckPistolHand();
		#### A 0 A_JumpIf(invoker.weaponstatus[PISS_CHAMBER]>0,2);
		#### C 0;
		#### # 0 A_SetCrosshair(21);
		#### # 1 A_WeaponReady(WRF_ALL);
		goto readyend;
	user3:
		---- A 0 A_MagManager("HDTokarevMag8");
		goto ready;
	user2:
	firemode:
		---- A 0{
			if(invoker.weaponstatus[0]&PISF_SELECTFIRE)
			invoker.weaponstatus[0]^=PISF_FIREMODE;
			else invoker.weaponstatus[0]&=~PISF_FIREMODE;
		}goto nope;
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
				A_EjectCasing("HD762TokarevAmmo",
				              -frandom(89,92),
				              (frandom(2,3),0,0),
				              (13,0,0));
			}else if(psch==1){
				A_EjectCasing("HDSpent762Tokarev",
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
	            else if(invoker.weaponstatus[PISS_CHAMBER]<1)
	                setweaponstate("altholdclean");
	                }
	            if(invoker.weaponstatus[PISS_CHAMBER]<1
	            &&PressingReload()
	            &&countinv("HD762TokarevAmmo")
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
				A_TakeInventory("HD762TokarevAmmo",1,TIF_NOTAKEINFINITE);
				invoker.weaponstatus[PISS_CHAMBER]=2;
				A_StartSound("weapons/tt33_load",8,0.3);
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
			A_StartSound("weapons/tt33_load",8,0.3);
			int psch=invoker.weaponstatus[PISS_CHAMBER];
			invoker.weaponstatus[PISS_CHAMBER]=0;
			if(psch==2){
				A_EjectCasing("HD762TokarevAmmo",
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
        
    altholdclean:
		#### C 1 offset(2,36) A_ClearRefire();
		#### C 1 offset(3,38);
		#### C 1 offset(5,41) A_Log("Looking inside that chamber...",true);
		#### C 1 offset(8,44) A_StartSound("weapons/pocket",9);
		#### C 1 offset(7,50) A_MuzzleClimb(frandom(-0.2,0.2),0.2,
		                                    frandom(-0.2,0.2),0.2,
		                                    frandom(-0.2,0.2),0.2);
		TNT1 A 3 A_StartSound("weapons/pocket",10);
		TNT1 AAAA 4 A_MuzzleClimb(frandom(-0.2,0.2),
		                          frandom(-0.2,0.2),
		                          frandom(-0.2,0.2),
		                          frandom(-0.2,0.2),
		                          frandom(-0.2,0.2),
		                          frandom(-0.2,0.2),
		                          frandom(-0.2,0.2),
		                          frandom(-0.2,0.2));
		TNT1 A 3 A_StartSound("weapons/pocket",9);
		TNT1 AAAA 4 A_MuzzleClimb(frandom(-0.2,0.2),
		                          frandom(-0.2,0.2),
		                          frandom(-0.2,0.2),
		                          frandom(-0.2,0.2),
		                          frandom(-0.2,0.2),
		                          frandom(-0.2,0.2),
		                          frandom(-0.2,0.2),
		                          frandom(-0.2,0.2));
		TNT1 A 40{
			A_StartSound("weapons/pocket",9);
			int amt=invoker.TT33_GUNDAMAGE;
			string amts="It's in decent condition. ";
			if(amt>70)amts="CYKA BLYAT. ";
			else if(amt>50)amts="God, it's almost rusted shut. ";
			else if(amt>30)amts="It could really use some oil. ";
			else if(amt>10)amts="It's getting a bit dirty. ";

			static const string cleanverbs[]={"extract","scrape off","wipe away","{care|skil|force}fully remove","dump out","pick out","blow off","shake out","scrub off","fish out"};
			static const string contaminants[]={"some dust","a lot of dust","a bit of powder residue","a disturbing amount of powder residue","some excess grease","a layer of soot","some iron filings","a bit of hair","an eyelash","a patch of dried blood","a bit of rust","a crumb","a dead {insect|spider|ant|wasp}","ashes","some loose bits of skin","a sticky fluid of some sort","wow some fucking *gunk*","a booger","trace fecal matter","yet even more of that anonymous grey debris that all those bullet impacts make","a dollop of {straw|blue|rasp}berry jam","the dried husk of a {pinto|fava|mung} bean with residual hog components","a tiny cancerous nodule of Second Flesh","some crystalline buildup of congealed Frag","a nesting queen space ant","a single modern-day transistor","a tiny Makarov pistol (also jammed)","a colourless film of darkness made visible"};
			static const string actionparts[]={"bolt carrier","main extractor","auxiliary extractor","cam pin","bolt head","striker","firing pin spring","ejector slot","striker spring","ejector spring"};
			for(int i=amt;i>0;i-=random(8,16))amts.appendformat("You %s %s from the %s. ",
				cleanverbs[random(0,cleanverbs.size()-1)],
				contaminants[random(0,random(0,contaminants.size()-1))],
				actionparts[random(0,random((actionparts.size()>>1),actionparts.size()-1))]
			);
			amts=HDMath.BuildVariableString(amts);
			amts.appendformat("\n");

			amt=randompick(-3,-5,-5,-random(8,16));

			A_ChamberGrit(amt,true);
			amt=invoker.TT33_GUNDAMAGE;
			if(amt>60)amts.appendformat("You barely scrape the surface of this all-encrusting abomination.");
			else if(amt>45)amts.appendformat("The gun will need a lot more work than this before it can be deployed again.");
			else if(amt>30)amts.appendformat("You might get a few shots out of it now.");
			else if(amt>15)amts.appendformat("It's better, but still not good.");
			else amts.appendformat("Good to go.");
			A_Log(amts,true);
		}
		TT33 C 1 offset(7,52) A_CheckPistolHand();
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
	fire:
		---- A 0{
		    A_StartSound("weapons/tt33_load", 8, 0.2);
		    //makes a soft click for trigger pull
			invoker.weaponstatus[0]&=~PISF_JUSTUNLOAD;
			if(invoker.weaponstatus[PISS_CHAMBER]==2)setweaponstate("shoot");
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
		#### C 0{
		    if(!random(0,99-invoker.TT33_GUNDAMAGE))setweaponstate("nope");
		    //jams after firing, but casing gets stuck
			A_EjectCasing("HDSpent762Tokarev",
			              -frandom(89,92),
			              (frandom(6,7),0,0),
			              (13,0,0));
			invoker.weaponstatus[PISS_CHAMBER]=0;
			if(invoker.weaponstatus[PISS_MAG]<1){
				A_StartSound("weapons/tt33_load",8,CHANF_OVERLAP,0.5);
				setweaponstate("nope");
			}
		}
		#### B 1{
			A_WeaponReady(WRF_NOFIRE);
			if(!random(0,99-invoker.TT33_GUNDAMAGE))setweaponstate("ready");
			//jams sometimes before loading the next round
			
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
		P10F A 0 A_JumpIf(invoker.wronghand,2);
		P10F A 0;
		---- A 1 bright{
			HDFlashAlpha(64);
			A_Light1();
			let bbb=HDBulletActor.FireBullet(self,"HDB_762Tokarev",
			                                 spread:2.,
			                                 speedfactor:frandom(0.97,1.03));
			if(
				frandom(0,ceilingz-floorz)<bbb.speed*0.3
			)A_AlertMonsters(240);

            //chance of adding dirt after firing
            A_ChamberGrit(randompick(0,0,0,0,-1,1,2),true);
			invoker.weaponstatus[PISS_CHAMBER]=1;
			A_ZoomRecoil(0.995);
			A_MuzzleClimb(-frandom(0.7,2.4),-frandom(0.7,3.0));
                    //extra recoil (+0.4,+1.2)
		}           //kicks a bit less than the Delta Elite
		---- A 0 A_StartSound("weapons/tt33",CHAN_WEAPON);
		---- A 0 A_StartSound("weapons/tt33_chamber",0.3,CHAN_WEAPON);
		---- A 0 A_Light0();
		stop;
	unload:
		---- A 0{
			invoker.weaponstatus[0]|=PISF_JUSTUNLOAD;
			if(invoker.weaponstatus[PISS_MAG]>=0)setweaponstate("unmag");
		}goto nope;

	loadchamber:
		---- A 0 A_JumpIf(invoker.weaponstatus[PISS_CHAMBER]>0,"nope");
		---- A 1 offset(0,36) A_StartSound("weapons/pocket",9);
		---- A 1 offset(2,40);
		---- A 1 offset(2,50);
		---- A 1 offset(3,60);
		---- A 2 offset(5,90);
		---- A 2 offset(7,80);
		---- A 2 offset(10,90);
		#### C 2 offset(8,96)A_StartSound("weapons/tt33_load",8);
		#### C 3 offset(6,88){
			if(countinv("HD762TokarevAmmo")){
				A_TakeInventory("HD762TokarevAmmo",1,TIF_NOTAKEINFINITE);
				invoker.weaponstatus[PISS_CHAMBER]=2;
				A_StartSound("weapons/tt33_chamber",8);
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
			if(invoker.weaponstatus[PISS_MAG]>=8)setweaponstate("nope");
		}goto unmag;
	unmag:
		---- A 1 offset(0,34) A_SetCrosshair(21);
		---- A 1 offset(1,38);
		---- A 2 offset(2,42);
		---- A 3 offset(3,46) A_StartSound("weapons/tt33_load",8,0.5,CHANF_OVERLAP);
		---- A 0{
			int pmg=invoker.weaponstatus[PISS_MAG];
			invoker.weaponstatus[PISS_MAG]=-1;
			if(pmg<0)setweaponstate("magout");
			else if(
				(!PressingUnload()&&!PressingReload())
				||A_JumpIfInventory("HDTokarevMag8",0,"null")
			){
				HDMagAmmo.SpawnMag(self,"HDTokarevMag8",pmg);
				setweaponstate("magout");
			}
			else{
				HDMagAmmo.GiveMag(self,"HDTokarevMag8",pmg);
				A_StartSound("weapons/pocket",9);
				setweaponstate("pocketmag");
			}
		}
	pocketmag:
		---- AAA 5 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),
		                                      frandom(-0.2,0.4));
		goto magout;
	magout:
		---- A 0{
			if(invoker.weaponstatus[0]&PISF_JUSTUNLOAD)setweaponstate("reloadend");
			else setweaponstate("loadmag");
		}

	loadmag:
		---- A 4 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),
		                                    frandom(-0.2,0.4));
		---- A 0 A_StartSound("weapons/pocket",9);
		---- A 5 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),
		                                    frandom(-0.2,0.4));
		---- A 3;
		---- A 0{
			let mmm=hdmagammo(findinventory("HDTokarevMag8"));
			if(mmm){
				invoker.weaponstatus[PISS_MAG]=mmm.TakeMag(true);
				A_StartSound("weapons/tt33_chamber",8,0.5);
			}
		}
		goto reloadend;

	reloadend:
		---- A 2 offset(3,46);
		---- A 1 offset(2,42);
		---- A 1 offset(2,38);
		---- A 1 offset(1,34);
//		---- A 0 A_JumpIf(!(invoker.weaponstatus[0]&PISF_JUSTUNLOAD)
//		                    &&(invoker.weaponstatus[PISS_CHAMBER]==0)
//		                    ,"chamber_start");
	    goto nope;

//removing auto-chamber mechanic; since
//the TT-33 lacks a safety, it was common
//for the Soviets to carry them unchambered
//to avoid misfires in case they dropped it,
//only pulling back the slide once they were
//ready to shoot

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
		TT33 A 0 A_CheckPistolHand();
		goto nope;
	lowerleft:
		TT33 A 0;
		#### B 1 offset(-6,38);
		#### B 1 offset(-12,48);
		#### B 1 offset(-20,60);
		#### B 1 offset(-34,76);
		#### B 1 offset(-50,86);
		stop;
	lowerright:
		T233 A 0 ;
		#### B 1 offset(6,38);
		#### B 1 offset(12,48);
		#### B 1 offset(20,60);
		#### B 1 offset(34,76);
		#### B 1 offset(50,86);
		stop;
	raiseleft:
		TT33 A 0 ;
		#### A 1 offset(-50,86);
		#### A 1 offset(-34,76);
		#### A 1 offset(-20,60);
		#### A 1 offset(-12,48);
		#### A 1 offset(-6,38);
		stop;
	raiseright:
		T233 A 0;
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
		TT33 A 0{
			invoker.wronghand=!invoker.wronghand;
			A_CheckPistolHand();
		}
		#### B 1 offset(0,76);
		#### B 1 offset(0,60);
		#### B 1 offset(0,48);
		goto nope;


	spawn:
		TKRV ABCD -1 nodelay{
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
		weaponstatus[PISS_MAG]=8;
		weaponstatus[PISS_CHAMBER]=2;
		TT33_GUNDAMAGE=0;
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

/*
enum pistolstatus{
	PISF_SELECTFIRE=1,
	PISF_FIREMODE=2,
	PISF_JUSTUNLOAD=4,

	PISS_FLAGS=0,
	PISS_MAG=1,
	PISS_CHAMBER=2, //0 empty, 1 spent, 2 loaded
};
*/


//use this to give an autopistol in a custom loadout
class HDTT33AutoPistol:HDWeaponGiver{
	default{
		//$Category "Weapons/Hideous Destructor"
		//$Title "TT-33 Pistol (select-fire)"
		//$Sprite "PISTA0"
		tag "TT-33 7.62mm Pistol (select-fire)";
		hdweapongiver.bulk 40;
		hdweapongiver.weapontogive "HDTT33Pistol";
		hdweapongiver.config "selectfire";
		hdweapongiver.weprefid "tkv";
		inventory.icon "TKRVC0";
	}
}

class TT33Spawn:actor{
	override void postbeginplay(){
		super.postbeginplay();
  		spawn("HDTokarevMag8",pos,ALLOW_REPLACE);
  		spawn("HDTokarevMag8",pos,ALLOW_REPLACE);
  		if(!random(0,9))spawn("TokarevAutoReloader",pos,ALLOW_REPLACE);
  		if(!random(0,9))spawn("HDTT33AutoPistol",pos,ALLOW_REPLACE);
  		else spawn("HDTT33Pistol",pos,ALLOW_REPLACE);
		self.Destroy();
	}
}
