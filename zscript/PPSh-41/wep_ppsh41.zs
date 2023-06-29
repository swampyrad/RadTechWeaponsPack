//based off Juan Horseshoe Pistol code

class HDPPSh41 :HDHandgun{
    bool MAG_BOX;
    bool MAG_DRUM;
    bool MAG_FORCEBOX;
    bool MAG_FORCEDRUM;
    
	default{
		+hdweapon.fitsinbackpack
		+hdweapon.reverseguninertia
		scale 0.65;
		weapon.selectionorder 50;
		weapon.slotnumber 4;//it doesn't really fit in the same spot as handguns
		weapon.slotpriority 3;
		weapon.kickback 30;
		weapon.bobrangex 0.1;
		weapon.bobrangey 0.6;
		weapon.bobspeed 2.5;
		weapon.bobstyle "normal";
		obituary "$OB_PPSH41";
		tag "$TAG_PPSH41";
		hdweapon.refid "pps";
		hdweapon.barrelsize 30,0.3,0.4;

		hdweapon.loadoutcodes "
			\cufiremode - 0/1, semi/auto, subject to the above
			\box - start loaded with a box magazine instead"
			;
	}

	override void postbeginplay(){
		super.postbeginplay();
		weaponspecial=1337;
		weaponstatus[0]|=PPSHF_SELECTFIRE;
	}

		override string pickupmessage(){
		return Stringtable.Localize("$PICKUP_PPSH41");
	}

	override double weaponbulk(){
		int result = 97;
		
		// Magazine bulk. 
		if(weaponstatus[PPSHS_MAG]&&MAG_DRUM >= 0)
		{
			result += ENC_TOKAREV_DRUM_EMPTY;
		} else if(weaponstatus[PPSHS_MAG]&&MAG_BOX >= 0)
		{
			result += ENC_TOKAREV_BOX_EMPTY;
		}

		int mgg=weaponstatus[PPSHS_MAG];
		return result+(mgg<0?0:(mgg*ENC_762TOKAREV_LOADED));
	}
	override double gunmass(){
		int mgg=weaponstatus[PPSHS_MAG];
		return 8+(mgg<0?0:0.10*(mgg+1));
	}
	override void failedpickupunload(){
	if(MAG_BOX)failedpickupunloadmag(PPSHS_MAG,"HDTokarevMag35");
	else failedpickupunloadmag(PPSHS_MAG,"HDTokarevMag71");
	}
	
	override string,double getpickupsprite(bool usespare)
    {
        string sprind;
        string sprname="PS41";

			// For ammo reloads via cheats. 
			if(GetSpareWeaponValue(PPSHS_MAG, usespare) >= 0&&MAG_DRUM)
			{
					sprind="A";
			}
			else if(GetSpareWeaponValue(PPSHS_MAG, usespare) >= 0&&MAG_BOX)
			{
					sprind="C";
			}
			else{	sprind="B"; }

        return sprname..sprind.."0",1.;
    }

	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
		
		//drum mags
			int nextmagloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("HDTokarevMag71")));
			if(nextmagloaded>=71){
				sb.drawimage("PSDMA0",(-50,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1,1));
			}else if(nextmagloaded<1){
				sb.drawimage("PSDMC0",(-50,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextmagloaded?0.6:1.,scale:(1,1));
			}else sb.drawbar(
				"PSDMA0","PSDMC0",
				nextmagloaded,71,
				(-50,-3),-1,
				sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
			);
			
		//box mags
			int nextpmagloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("HDTokarevMag35")));
			if(nextpmagloaded>=35){
				sb.drawimage("PSHMA0",(-63,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1,1));
			}else if(nextpmagloaded<1){
				sb.drawimage("PSHMC0",(-63,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextpmagloaded?0.6:1.,scale:(1,1));
			}else sb.drawbar(
				"PSHMA0","PSHMC0",
				nextpmagloaded,35,
				(-63,-3),-1,
				sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
			);

			sb.drawnum(hpl.countinv("HDTokarevMag71"),-43,-8,sb.DI_SCREEN_CENTER_BOTTOM);
	        sb.drawnum(hpl.countinv("HDTokarevMag35"),-56,-8,sb.DI_SCREEN_CENTER_BOTTOM);
	
		}
	
		sb.drawwepcounter(hdw.weaponstatus[0]&PPSHF_FIREMODE,
			-22,-10,"RBRSA3A7","STFULAUT"
		);
		sb.drawwepnum(hdw.weaponstatus[PPSHS_MAG],
		              hdw.weaponstatus[PPSHS_MAG]>35?
		                hdw.weaponstatus[PPSHS_MAG]:35,-16);
		if(hdw.weaponstatus[PPSHS_MAG]>35)
	    	sb.drawwepnum(hdw.weaponstatus[PPSHS_MAG]-35,35,-16,-2);
		
		if(hdw.weaponstatus[PPSHS_CHAMBER]>0)sb.drawrect(-19,-11,3,1);
	}
	override string gethelptext(){
		return
		WEPHELP_FIRESHOOT
		..WEPHELP_ALTFIRE.."  Clear Jam\n"
		..WEPHELP_FIREMODE.."  Semi/Auto\n"
		..WEPHELP_RELOAD.."  Reload mag (drum mags first)\n"
		..WEPHELP_ALTRELOAD.."  Reload box magazine\n"
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
			
		sb.SetClipRect(
			-8+bob.x,-9+bob.y,16,15,
			sb.DI_SCREEN_CENTER
		);
		scc=(0.6,0.6);
		

		sb.drawimage(
			"frntsite",(0,0)+bobb,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			scale:scc
		);
		sb.drawimage(
			"xh25",(0,-3)+bobb,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
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
			if(owner.countinv("HD762TokarevAmmo"))owner.A_DropInventory("HD762TokarevAmmo",amt*35);
			else if(owner.countinv("HDTokarevMag71"))owner.A_DropInventory("HDTokarevMag71",amt);
		    else if(owner.countinv("HDTokarevMag35"))owner.A_DropInventory("HDTokarevMag35",amt);
		}
	}
	override void ForceBasicAmmo(){
		owner.A_TakeInventory("HD762TokarevAmmo");
		ForceOneBasicAmmo("HDTokarevMag71");
	}
	
	states{
	select0:
		PPSH A 0 A_JumpIf(invoker.MAG_DRUM,3);
		#### D 0 A_JumpIf(invoker.MAG_BOX,2);
		#### C 0;
		#### # 0;
		goto select0big;
	deselect0:
		PPSH A 0 A_JumpIf(invoker.MAG_DRUM,3);
		#### D 0 A_JumpIf(invoker.MAG_BOX,2);
		#### C 0;
		#### # 0;
		goto deselect0big;

	ready:
		PPSH A 0 A_JumpIf(invoker.MAG_DRUM,3);
		#### D 0 A_JumpIf(invoker.MAG_BOX,3);
		#### C 0;
		#### # 0 A_SetCrosshair(21);
		#### # 1 {A_WeaponReady(WRF_ALL);
		            invoker.MAG_FORCEDRUM=false;
		            invoker.MAG_FORCEBOX=false;
		            //resets reload flags
		        }
		goto readyend;
	
	user3:
		---- # 0 A_MagManager("HDTokarevMag71");
		goto ready;
		
	user2:
	firemode:
		---- # 0{
		        invoker.weaponstatus[0]^=PPSHF_FIREMODE;
	            }
		goto nope;
		
	altfire:
        unloadchamber://basically just racking the bolt again
		#### # 0 A_JumpIf(!invoker.weaponstatus[PPSHS_JAMMED],"nope");
		#### # 2 offset(1,32);
		#### # 2 offset(2,42);
		#### # 2 offset(3,48){
		    A_StartSound("weapons/tt33_chamber",8,CHANF_OVERLAP);
	        A_MuzzleClimb(frandom(0.2,0.24),-frandom(0.3,0.36),frandom(0.2,0.24),-frandom(0.3,0.36));
        
            //spawns either a casing or unspent round if chamber jammed
            if(invoker.weaponstatus[PPSHS_CHAMBER]>0)
		    A_SpawnItemEx(invoker.weaponstatus[PPSHS_CHAMBER]==2?"HDLoose762Tokarev":"HDSpent762Tokarev",
				cos(pitch)*10,0,height*0.82-sin(pitch)*10,
				vel.x,vel.y,vel.z,
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
			);
			
			invoker.weaponstatus[PPSHS_JAMMED]=0;  
			invoker.weaponstatus[PPSHS_CHAMBER]=0;
		}
		#### # 2 offset(2,42);	
		#### # 2 offset(1,32);
		goto readyend;
		
		
	althold:
	hold:
		goto nope;
	fire:
	   	#### # 0 A_JumpIf(
		         invoker.weaponstatus[PPSHS_MAG]<1||
		         invoker.weaponstatus[PPSHS_JAMMED]
	             ,"nope");
	             //do nothing if no ammo left or jammed
	shoot:
	   	#### # 0{//using modified version of STEN's jamming mechanic
		        let drumjam = invoker.weaponstatus[PPSHS_MAG]/2;
		        let boxjam = invoker.weaponstatus[PPSHS_MAG]/4;
		        //box mags are less likely to jam than drums
		        if(!random(0,99
		                -(invoker.MAG_DRUM?drumjam:boxjam)
		                -(drumjam>65?10:0)//higher chance to jam on a full drum
		              )
		          )
		              setweaponstate("jam");
		    
		        //failure to feed,
				//extra chance to jam if drum is too full,
				//something to do with the spring being too tight
	            
	            //this is the only part where the magazine plays
	            //a factor in jamming, everything else is based
	            //on the weapon's mechanisms itself, not the mag's 
	   
	    		if(invoker.weaponstatus[PPSHS_MAG]>0){
				    invoker.weaponstatus[PPSHS_MAG]--;
				    invoker.weaponstatus[PPSHS_CHAMBER]=2;
		    	    }//if there's rounds in the mag,
		    	    //remove one and chamber it
		    	    
		    	// random chance of hammer not striking primer hard enough
		        if(!random(0,99))setweaponstate("jam");
		        //failure to fire, round didn't go off
	    	    }
		#### # 1{
			if(invoker.weaponstatus[PPSHS_CHAMBER]==2)A_GunFlash();
		}
		
		#### # 1{
            invoker.weaponstatus[PPSHS_CHAMBER]=1;
			A_MuzzleClimb(
				-frandom(0.6,0.9),-frandom(0.8,1.1),
				frandom(0.4,0.5),frandom(0.6,0.8)
			);
			
			//random chance of casing getting caught in the bolt
		    if(!random(0,99))setweaponstate("jam");//failure to eject
		    
			A_EjectCasing("HDSpent762Tokarev",-frandom(89,92),(frandom(6,7),-5,0),(13,0,0));
			invoker.weaponstatus[PPSHS_CHAMBER]=0;
			if(invoker.weaponstatus[PPSHS_MAG]<1){
				A_StartSound("weapons/tt33_load",8,CHANF_OVERLAP,0.9);
				setweaponstate("nope");
			}
		}
		#### # 1{
			A_WeaponReady(WRF_NOFIRE);
			if(
				(invoker.weaponstatus[0]&
				(PPSHF_FIREMODE|PPSHF_SELECTFIRE))
				==(PPSHF_FIREMODE|PPSHF_SELECTFIRE)
			){
				A_Refire("fire");
			}else A_Refire();
		}goto ready;
		
	flash:
		PPSH B 0 A_StartSound("weapons/ppsh41",CHAN_WEAPON);
		#### B 1 bright{
			HDFlashAlpha(64);
			A_Light1();
			let bbb=HDBulletActor.FireBullet(self,"HDB_762TOKAREV",spread:2.,speedfactor:frandom(0.99,1.05));
			if(
				frandom(0,ceilingz-floorz)<bbb.speed*0.3
			)A_AlertMonsters(240);

			invoker.weaponstatus[PPSHS_CHAMBER]=1;
			A_ZoomRecoil(0.995);
			
			A_MuzzleClimb(
			-frandom(0.6,0.8),-frandom(1.,1.2),
			frandom(0.4,0.5),frandom(0.6,0.8)
			);
	
		}
		#### B 0 A_Light0();
		stop;
		
	jam:
		#### # 1 offset(-1,36){
		    invoker.weaponstatus[PPSHS_JAMMED]=1;  
			A_StartSound("weapons/tt33_load",CHAN_WEAPON,CHANF_OVERLAP);
			}
		#### # 1 offset(1,30) A_StartSound("weapons/rifleclick",CHAN_WEAPON,CHANF_OVERLAP);
		goto nope;
		
		
	unload:
		---- # 0{
			invoker.weaponstatus[0]|=PPSHF_JUSTUNLOAD;
			if(invoker.MAG_DRUM)setweaponstate("unmagdrum");
			if(invoker.MAG_BOX)setweaponstate("unmagbox");
		}goto nope;
		
	loadchamber:
		goto readyend;

    //note to self: never put "altreload" before "reload",
    //              it screws everything up lmao
    
	 reload:
	    ---- # 0 {
			    invoker.weaponstatus[0]&=~PPSHF_JUSTUNLOAD;
			    if (!countinv("HDTokarevMag71")&&!countinv("HDTokarevMag35"))
			      setweaponstate("nope");
			    }//do nothing if no mags to load
	    reload_drum:
	    
		---- # 0{

			if(invoker.MAG_FORCEBOX)setweaponstate("reload_box");
			
		    A_JumpIfInventory("HDTokarevMag71",0,"nope");
			
			invoker.MAG_FORCEDRUM=true;
			if(invoker.weaponstatus[PPSHS_MAG]>=71)setweaponstate("nope");
		}
		---- # 0 A_Jumpif(invoker.MAG_BOX,"unmagbox");
		goto unmagdrum;
	
	    reload_box:
		---- # 0
			{				
			if(invoker.weaponstatus[PPSHS_MAG]>=35)setweaponstate("nope");
			
			A_JumpIfInventory("HDTokarevMag35",0,"nope");

			}
		---- # 0 A_Jumpif(invoker.MAG_BOX,"unmagbox");
		goto unmagdrum;
	
	    unmagdrum:
		---- # 1 offset(0,34) A_SetCrosshair(21);
		---- # 1 offset(1,38);
		---- # 2 offset(2,42);
		---- # 3 offset(3,46)
		{
			A_StartSound("weapons/rifleunload",8,CHANF_OVERLAP,0.3);
		}
		#### C 0{
			int pmg=invoker.weaponstatus[PPSHS_MAG];
			invoker.weaponstatus[PPSHS_MAG]=-1;
			invoker.MAG_DRUM = false;
			
			if(pmg<0)setweaponstate("drummagout");
			else if(    //drum mags
				(!PressingUnload()&&!PressingReload()&&!PressingAltReload())
				||A_JumpIfInventory("HDTokarevMag71",0,"null")
			){
				HDMagAmmo.SpawnMag(self,"HDTokarevMag71",pmg);
				setweaponstate("drummagout");
			}
			else{
				HDMagAmmo.GiveMag(self,"HDTokarevMag71",pmg);
				A_StartSound("weapons/pocket",9);
				setweaponstate("pocketdrummag");
			}
			
		}
		
		unmagbox:
		---- # 1 offset(0,34) A_SetCrosshair(21);
		---- # 1 offset(1,38);
		---- # 2 offset(2,42);
		---- C 3 offset(3,46)
		{
			A_StartSound("weapons/rifleunload",8,CHANF_OVERLAP,0.3);
		}
		#### C 0{
			int pmg=invoker.weaponstatus[PPSHS_MAG];
			invoker.weaponstatus[PPSHS_MAG]=-1;
			invoker.MAG_BOX = false;
			
			if(pmg<0)setweaponstate("boxmagout");
			else if(   //standard mags
				(!PressingUnload()&&!PressingReload()&&!PressingAltReload())
				||A_JumpIfInventory("HDTokarevMag35",0,"null")
			){
				HDMagAmmo.SpawnMag(self,"HDTokarevMag35",pmg);
				setweaponstate("boxmagout");
			}
			else{
				HDMagAmmo.GiveMag(self,"HDTokarevMag35",pmg);
				A_StartSound("weapons/pocket",9);
				setweaponstate("pocketboxmag");
			}
		}
	
		
	    pocketdrummag:
		---- # 5 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		---- # 5 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		---- # 5 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		goto drummagout;
	
	    pocketboxmag:
		---- # 5 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		---- # 5 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		---- # 5 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		goto boxmagout;
	
	    drummagout:
		#### # 0{
			if(invoker.weaponstatus[0]&PPSHF_JUSTUNLOAD)setweaponstate("reloadend");
			else if(invoker.MAG_FORCEBOX)setweaponstate("loadbox");
			else setweaponstate("loaddrum");
		}
		
		boxmagout:
		#### # 0{
			if(invoker.weaponstatus[0]&PPSHF_JUSTUNLOAD)setweaponstate("reloadend");
			else if(invoker.MAG_FORCEDRUM)setweaponstate("loaddrum");
			else setweaponstate("loadbox");
		}

	    loaddrum:
	    #### # 0 A_JumpIf(!countinv("HDTokarevMag71")||invoker.MAG_FORCEBOX,"loadbox");
		#### C 4 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		#### # 0 A_StartSound("weapons/pocket",9);
		#### C 5 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		#### A 3;
		---- A 0{
			let mmm=hdmagammo(findinventory("HDTokarevMag71"));
			if(mmm){
				invoker.weaponstatus[PPSHS_MAG]=mmm.TakeMag(true);
				invoker.MAG_DRUM = true;
				invoker.MAG_BOX = false;
				
				A_StartSound("weapons/rifleclick",8);
				A_StartSound("weapons/rifleload",8,CHANF_OVERLAP);
				setweaponstate("reloadend");
			}
		}
		goto reloadend;
	    
        loadbox:
		#### C 4 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		#### # 0 A_StartSound("weapons/pocket",9);
		#### C 5 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		#### C 3 ;
		---- # 0{
			let mmm=hdmagammo(findinventory("HDTokarevMag35"));
			if(mmm){
				invoker.weaponstatus[PPSHS_MAG]=mmm.TakeMag(true);
				invoker.MAG_BOX = true;
				invoker.MAG_DRUM = false;
				
				A_StartSound("weapons/rifleclick",8);
				A_StartSound("weapons/rifleload",8,CHANF_OVERLAP);
				setweaponstate("reloadend");
			}
		}
		goto reloadend;

	reloadend:
		#### # 2 offset(3,46);
		---- # 1 offset(2,42);
		---- # 1 offset(2,38);
		---- # 1 offset(1,34);
		---- # 2 A_JumpIf(invoker.weaponstatus[PPSHS_MAG]==-1, 7);
		---- # 2 offset(1,34)A_MuzzleClimb(
			                frandom(0.2,0.4),frandom(0.3,0.7),
		                	frandom(0.5,0.9),frandom(0.8,1)
	                		);
		---- # 2 offset(2,38);
		---- # 2 offset(2,42);
		---- # 2 offset(3,46)A_MuzzleClimb(
			                -frandom(0.2,0.4),-frandom(0.3,0.7),
		                	-frandom(0.5,0.9),-frandom(0.8,1)
		                	);
		---- # 2 offset(2,38)A_StartSound("weapons/tt33_chamber",8);//open the bolt
		---- # 2 offset(1,34);
		---- # 0 A_JumpIf(PressingReload()||PressingAltReload(),"nope");
		goto ready;

	user1:
	altreload:
	    ---- # 0 {
	            invoker.MAG_FORCEBOX=true;
	            }//set this so it forces a box mag reload
	    goto reload;

	
	spawn:
		PS41 A -1 nodelay
		{
			if(invoker.MAG_DRUM)
			    frame = 0;
			else if (invoker.MAG_BOX)
			    frame = 2;
			else frame = 1;
		}
		stop;
	}
	override void initializewepstats(bool idfa){
		weaponstatus[PPSHS_MAG]=71;
		weaponstatus[PPSHS_CHAMBER]=0;//open bolt
		MAG_DRUM = true;
		MAG_BOX = false;
	}
	override void loadoutconfigure(string input){
		weaponstatus[0]|=PPSHF_SELECTFIRE;
		
		if(weaponstatus[0]&PPSHF_SELECTFIRE){
			int firemode=getloadoutvar(input,"firemode",1);
			if(!firemode)weaponstatus[0]&=~PPSHF_FIREMODE;
			else if(firemode>0)weaponstatus[0]|=PPSHF_FIREMODE;
		}
		
		int boxmag=getloadoutvar(input,"box",1);
			if(!boxmag){
			    weaponstatus[PPSHS_MAG]=71;
			    MAG_DRUM = true;
		        MAG_BOX = false;
		    }
			else if(boxmag>0){
			    weaponstatus[PPSHS_MAG]=35;
			    MAG_DRUM = false;
		        MAG_BOX = true;
		    }
	}
}

enum papasha_status
{
	PPSHF_SELECTFIRE=1,
	PPSHF_FIREMODE=2,
	PPSHF_JUSTUNLOAD=4,

	PPSHS_FLAGS=0,
	PPSHS_MAG=1,
	PPSHS_CHAMBER=2, //0 empty, 1 spent, 2 loaded
	PPSHS_JAMMED=7,
};

class PapashaSpawn:actor{
	override void postbeginplay(){
		super.postbeginplay();
		if(!random(0,9))spawn("TokarevAutoReloader",pos,ALLOW_REPLACE);
		if(!random(0,9)){
  		spawn("HDTokarevMag71",pos,ALLOW_REPLACE);
  		spawn("HDTokarevMag71",pos,ALLOW_REPLACE);
  		}else{
  		spawn("HDTokarevMag35",pos,ALLOW_REPLACE);
  		spawn("HDTokarevMag35",pos,ALLOW_REPLACE);
  		}
  	    spawn("HDPPSh41",pos,ALLOW_REPLACE);
		self.Destroy();
	}
}
