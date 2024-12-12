
// ------------------------------------------------------------
// STEN Mk. 2 (S) Sub-Machine Gun
// ------------------------------------------------------------
const HDLD_STEN="MK2";
const HDSTEN_OVERHEAT=55;

class HDStenMk2:HDWeapon{
	default{
		//$Category "Weapons/Hideous Destructor"
		//$Title "Suppressed STEN Mk. 2"
		//$Sprite "STENA0"

		+hdweapon.fitsinbackpack
		obituary "%o was silenced by %k's STEN gun.";
		weapon.selectionorder 24;
		weapon.slotnumber 2;
		weapon.slotpriority 0.9;
		weapon.kickback 30;
		weapon.bobrangex 0.3;
		weapon.bobrangey 0.8;
		weapon.bobspeed 2.5;
		scale 0.35;
		hdweapon.barrelsize 21,0.5,1;
		hdweapon.refid HDLD_STEN;
		tag "$TAG_STEN";
		inventory.icon "STNPA0";
		//no configs, WYSIWYG
	}
	override void tick(){
		super.tick();
		if(weaponstatus[STENS_HEAT]>0) 
		weaponstatus[STENS_HEAT]--;
	}
	override bool AddSpareWeapon(actor newowner){return AddSpareWeaponRegular(newowner);}
	override hdweapon GetSpareWeapon(actor newowner,bool reverse,bool doselect){return GetSpareWeaponRegular(newowner,reverse,doselect);}
	override double gunmass(){
		return 5+((weaponstatus[STENS_MAG]<0)?-0.5:(weaponstatus[STENS_MAG]*0.05));
	}
	override string pickupmessage(){
		return Stringtable.Localize("$PICKUP_STENMK2");
	}
	override double weaponbulk(){
		int mg=weaponstatus[STENS_MAG];
		if(mg<0)return 80;//lighter than the SMG
		else return (80+ENC_9MAG30_LOADED)+mg*ENC_9_LOADED;
	}
	override void failedpickupunload(){
		failedpickupunloadmag(STENS_MAG,"HD9mMag30");
	}
	override void DropOneAmmo(int amt){
		if(owner){
			amt=clamp(amt,1,10);
			if(owner.countinv("HDPistolAmmo"))owner.A_DropInventory("HDPistolAmmo",amt*30);
			else owner.A_DropInventory("HD9mMag30",amt);
		}
	}
	override void ForceBasicAmmo(){
		owner.A_TakeInventory("HDPistolAmmo");
		ForceOneBasicAmmo("HD9mMag30");
	}
	override string,double getpickupsprite(bool usespare){
		int wep0=GetSpareWeaponValue(0,usespare);
		return "STNP"..((GetSpareWeaponValue(STENS_MAG,usespare)<0)?"B":"A").."0",0.6;
	}
	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
			int nextmagloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("HD9mMag30")));
			if(nextmagloaded>=30){
				sb.drawimage("CLP3A0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(3,3));
			}else if(nextmagloaded<1){
				sb.drawimage("CLP3B0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextmagloaded?0.6:1.,scale:(3,3));
			}else sb.drawbar(
				"CLP3NORM","CLP3GREY",
				nextmagloaded,30,
				(-46,-3),-1,
				sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
			);
			sb.drawnum(hpl.countinv("HD9mMag30"),-43,-8,sb.DI_SCREEN_CENTER_BOTTOM);
		}
		
		if(weaponstatus[STENS_SWITCHTYPE]!=1)sb.drawwepcounter(hdw.weaponstatus[STENS_AUTO],
			-22,-10,"RBRSA3A7","STBURAUT","STFULAUT"
		);
		
		sb.drawwepnum(hdw.weaponstatus[STENS_MAG],30);
		sb.drawwepnum(hdw.weaponstatus[STENS_HEAT],HDSTEN_OVERHEAT-5,-16,-14);
		//draws a heat indicator bar above the firemode
		
		if(hdw.weaponstatus[STENS_CHAMBER]>0)sb.drawrect(-19,-11,3,1);
	}
	override string gethelptext(){
		return
		WEPHELP_FIRESHOOT
		..WEPHELP_ALTFIRE.."  Open bolt/Clear jam\n"
		..WEPHELP_RELOAD.."  Reload mag\n"
		//..WEPHELP_USE.."+"..WEPHELP_RELOAD.."  Reload chamber\n"
		..WEPHELP_FIREMODE.."  Semi/Auto\n"
		..WEPHELP_MAGMANAGER
		..WEPHELP_UNLOADUNLOAD
		;
	}
	override void DrawSightPicture(
		HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl,
		bool sightbob,vector2 bob,double fov,bool scopeview,actor hpc
	){
		vector2 bobb=bob*1.18;
		
			int cx,cy,cw,ch;
			[cx,cy,cw,ch]=screen.GetClipRect();
			sb.SetClipRect(
				-16+bob.x,-4+bob.y,32,16,
				sb.DI_SCREEN_CENTER
			);
			//bobb.y=clamp(bobb.y,-8,8);
			sb.drawimage(
				"stenfsit",(0,-5)+bobb,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP
			);
			sb.SetClipRect(cx,cy,cw,ch);
			sb.drawimage(
				"stenbkst",(0,-9)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
				alpha:0.9
			);
		
	}
	
	
	action void A_CheckReflexSight(){
		Player.GetPSprite(PSP_WEAPON).sprite=getspriteindex("STENA0");
	}
	
	
	states{
	select0:
		STEN A 0 A_JumpIf(invoker.weaponstatus[STENS_MAG]>-1
		                &&!invoker.weaponstatus[STENS_JAMMED], 4);//has mag,and bolt open
		#### C 0 A_JumpIf(invoker.weaponstatus[STENS_MAG]>-1
		                &&invoker.weaponstatus[STENS_JAMMED], 3);//has mag, but bolt closed/jammed
		#### D 0 A_JumpIf(invoker.weaponstatus[STENS_MAG]<0
		                &&!invoker.weaponstatus[STENS_JAMMED],2);//no mag, bolt open
		#### E 0 ;//no mag, bolt closed/jammed
		#### # 0 ;
		goto select0small;
	deselect0:
		STEN A 0 A_JumpIf(invoker.weaponstatus[STENS_MAG]>-1
		                &&!invoker.weaponstatus[STENS_JAMMED], 4);//has mag,and bolt open
		#### C 0 A_JumpIf(invoker.weaponstatus[STENS_MAG]>-1
		                &&invoker.weaponstatus[STENS_JAMMED], 3);//has mag, but bolt closed/jammed
		#### D 0 A_JumpIf(invoker.weaponstatus[STENS_MAG]<0
		                &&!invoker.weaponstatus[STENS_JAMMED],2);//no mag, bolt open
		#### E 0 ;//no mag, bolt closed/jammed
		#### # 0 ;
		goto deselect0small;

	ready:
		STEN A 0 A_JumpIf(invoker.weaponstatus[STENS_MAG]>-1
		                &&!invoker.weaponstatus[STENS_JAMMED], 4);//has mag,and bolt open
		#### C 0 A_JumpIf(invoker.weaponstatus[STENS_MAG]>-1
		                &&invoker.weaponstatus[STENS_JAMMED], 3);//has mag, but bolt closed/jammed
		#### D 0 A_JumpIf(invoker.weaponstatus[STENS_MAG]<0
		                &&!invoker.weaponstatus[STENS_JAMMED],2);//no mag, bolt open
		#### E 0 ;//no mag, bolt closed/jammed
		#### # 0 ;
		#### # 1{
			A_SetCrosshair(21);
			//invoker.weaponstatus[STENS_RATCHET]=0;
			A_WeaponReady(WRF_ALL);
		}
		goto readyend;
	user3:
		---- # 0 A_MagManager("HD9mMag30");
		goto ready;
	altfire:
		goto unjam;
	althold:
		//goto nope;

	hold:
		#### # 0{
			if(invoker.weaponstatus[STENS_MAG]>0  // if mag is empty, stop firing
			 &&invoker.weaponstatus[STENS_AUTO]==2  //full auto
			)setweaponstate("fire2");
		    else if(invoker.weaponstatus[STENS_AUTO]==2)setweaponstate("jam");
		}goto nope;
		
	user2:
	firemode:
    //no burst, only semi and auto
		---- # 1{ 
			    int canaut=invoker.weaponstatus[STENS_AUTO];
			
			    //if set to auto, reset to semi
		    	if(canaut==2)invoker.weaponstatus[STENS_AUTO]=0;
				
                //set to auto if in semi
		    	else invoker.weaponstatus[STENS_AUTO]=2;
		    }
	    	goto nope;
		
		
	fire:
	    #### # 0 A_JumpIf(invoker.weaponstatus[STENS_JAMMED],"nope");
	    #### # 0 A_JumpIf(invoker.weaponstatus[STENS_MAG]==-1,"dryfire");
	   	#### # 0 A_JumpIf(invoker.weaponstatus[STENS_MAG]==0,"jam");
	             //do nothing if jammed, no ammo or no mag
	fire2:     
	    #### A 1 {
	    		if(invoker.weaponstatus[STENS_MAG]>0){
				    invoker.weaponstatus[STENS_MAG]--;
				    invoker.weaponstatus[STENS_CHAMBER]=2;
		    	    }//if there's rounds in the mag,
		    	    //remove one and chamber it

	    	    A_StartSound("weapons/sten_chamber",8,CHANF_OVERLAP);
	    	    A_MuzzleClimb(-frandom(0.2,0.24),-frandom(0.3,0.36),frandom(0.2,0.24),-frandom(0.3,0.36));
                //play chamber sfx 
                //weapon jumps sightly before firing
	    	    }
	
		#### C 1 {
		        A_GunFlash();//fire the gun, then eject the spent casing
		       
		        if(!random(0,79-invoker.weaponstatus[STENS_HEAT]))
		            setweaponstate("jam");
				 //random chance to jam, overheating makes it more likely
				 			    
			    if(invoker.weaponstatus[STENS_HEAT]>=HDSTEN_OVERHEAT)
			        setweaponstate("overheat");
			     //jams if overheating
		}
		#### B 1 {A_EjectCasing("HDSpent9mm",
					frandom(-1,2),
					(frandom(0.2,0.3),-frandom(7,7.5),frandom(0,0.2)),
					(0,0,-2)
				    );
				    invoker.weaponstatus[STENS_CHAMBER]=0;
				  }
		#### BA 1;//+2 tic, slower firerate than the SMG
		#### A 0 A_ReFire();
		goto ready;
	flash:
		#### A 0{
			let bbb=HDBulletActor.FireBullet(self,"HDB_9",spread:2,speedfactor:frandom(0.83,0.89));
			//average muzzle velocity of 300 m/s
			//slight spread due to poor build quality
			
			if(
				frandom(16,ceilingz-floorz)<bbb.speed*0.1
			)A_AlertMonsters(100);//quieter than the SMG

			A_ZoomRecoil(0.995);
			A_StartSound("weapons/sten",CHAN_WEAPON,volume:0.8);
			invoker.weaponstatus[STENS_HEAT]+=10;
			invoker.weaponstatus[STENS_CHAMBER]=1;
		}
		STNF A 1 bright{
			HDFlashAlpha(-200);
			A_Light1();
		}
		TNT1 A 0 A_MuzzleClimb(-frandom(0.2,0.24),-frandom(0.3,0.36),-frandom(0.2,0.24),-frandom(0.3,0.36));
		goto lightdone;

	unjam:
		#### # 0 A_JumpIf(!invoker.weaponstatus[STENS_JAMMED],"nope");
		#### # 1 offset(0,34) A_SetCrosshair(21);
		#### # 1 offset(5,42);
		#### # 1 offset(10,50);
		#### # 2 offset(20,58){
			A_StartSound("weapons/stenmagclick",CHAN_WEAPON,CHANF_OVERLAP);

	        A_MuzzleClimb(frandom(0.2,0.24),-frandom(0.3,0.36),frandom(0.2,0.24),-frandom(0.3,0.36));
            
            if(invoker.weaponstatus[STENS_CHAMBER]==1)
            {
			A_SpawnItemEx("HDSpent9mm",
				cos(pitch)*10,0,height*0.82-sin(pitch)*10,
				vel.x,vel.y,vel.z,
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
			    );
			A_StartSound("weapons/sten_chamber",8,CHANF_OVERLAP);
			}
			invoker.weaponstatus[STENS_CHAMBER]=0;
			invoker.weaponstatus[STENS_JAMMED]=0;  
		}
		#### A 0 A_JumpIf(invoker.weaponstatus[STENS_MAG]>-1,2);
		#### D 0; 
		#### # 2 offset(20,58);		
		#### # 1 offset(10,50);
		#### # 1 offset(5,42);
		#### # 1 offset(0,34); 
		goto readyend;
		
	jam:
		#### C 1 offset(-1,36){
		    invoker.weaponstatus[STENS_JAMMED]=1;  
			A_StartSound("weapons/stenjam",CHAN_WEAPON,CHANF_OVERLAP);
			A_StartSound("weapons/stenmagclick",CHAN_WEAPON,CHANF_OVERLAP);
			}
		#### # 1 offset(1,30);
		goto nope;
		
	dryfire:
		#### E 1 offset(-1,36){
		    invoker.weaponstatus[STENS_JAMMED]=1;  
			A_StartSound("weapons/stenmagclick",CHAN_WEAPON,CHANF_OVERLAP);
			}
		#### # 1 offset(1,30);
		goto nope;
		
	overheat:
	    #### C 1 offset(-1,36){
			A_StartSound("weapons/sten_overheat",CHAN_WEAPON,CHANF_OVERLAP);
			invoker.weaponstatus[STENS_JAMMED]=1;
			}//bolt gets stuck due to heat warping
		#### CCCCC 10 offset(1,30) A_SpawnItemEx("HDGunSmoke",
				cos(pitch)*10,0,height*0.82-sin(pitch)*10,
				vel.x,vel.y,vel.z,
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
			);
        goto nope;
	user4:
	unload:
		#### # 0{
			invoker.weaponstatus[0]|=STENF_JUSTUNLOAD;
			if(
				invoker.weaponstatus[STENS_MAG]>=0
			)setweaponstate("unmag");
			else if(invoker.weaponstatus[STENS_CHAMBER]>0)setweaponstate("unjam");
		}goto nope;
	reload:
		#### # 0{
			invoker.weaponstatus[0]&=~STENF_JUSTUNLOAD;
			bool nomags=HDMagAmmo.NothingLoaded(self,"HD9mMag30");
			if(invoker.weaponstatus[STENS_MAG]>=30)setweaponstate("nope");
			//do not reload if full mag 
			
			else if (nomags)setweaponstate("nope");
		}goto unmag;
		
	unmag:
		#### # 1 offset(0,34) A_SetCrosshair(21);
		#### # 1 offset(5,42);
		#### # 1 offset(10,50);
		#### # 2 offset(20,58) A_StartSound("weapons/stenmagclick",8);
		#### # 4 offset(30,70){
			A_MuzzleClimb(0.3,0.4);
			A_StartSound("weapons/stenmagmove",8,CHANF_OVERLAP);
		}
		#### # 0{
			int magamt=invoker.weaponstatus[STENS_MAG];
			if(magamt<0){
				setweaponstate("magout");
				return;
			}
			invoker.weaponstatus[STENS_MAG]=-1;
			if(
				(!PressingUnload()&&!PressingReload())
				||A_JumpIfInventory("HD9mMag30",0,"null")
			){
				HDMagAmmo.SpawnMag(self,"HD9mMag30",magamt);
				setweaponstate("magout");
			}else{
				HDMagAmmo.GiveMag(self,"HD9mMag30",magamt);
				A_StartSound("weapons/pocket",9);
				setweaponstate("pocketmag");
			}
		}
	pocketmag:
		#### DD 7 offset(35,80) A_MuzzleClimb(frandom(0.2,-0.8),frandom(-0.2,0.4));
	magout:
		#### D 0{
			if(invoker.weaponstatus[0]&STENF_JUSTUNLOAD)setweaponstate("reloadend_nomag");
			else setweaponstate("loadmag");
		}

	loadmag:
		#### D 0 A_StartSound("weapons/pocket",9);
		#### D 6 offset(35,80) A_MuzzleClimb(frandom(0.2,-0.8),frandom(-0.2,0.4));
		#### D 7 offset(33,79) A_MuzzleClimb(frandom(0.2,-0.8),frandom(-0.2,0.4));
		#### D 10 offset(32,77);
		#### D 3 offset(32,75){
			let mmm=hdmagammo(findinventory("HD9mMag30"));
			if(mmm){
				invoker.weaponstatus[STENS_MAG]=mmm.TakeMag(true);
				A_StartSound("weapons/stenmagclick",8,CHANF_OVERLAP);
			}
			if(
				invoker.weaponstatus[STENS_MAG]<1
				||invoker.weaponstatus[STENS_CHAMBER]>0
			)setweaponstate("reloadend");
		}
		goto reloadend;

	reloadend:
	    #### C 0 A_JumpIf(invoker.weaponstatus[STENS_JAMMED],2);
	    #### A 0;
		#### # 3 offset(30,69); 
		#### # 2 offset(20,59);
		#### # 1 offset(10,49);
		#### # 1 offset(5,38);
		#### # 2 offset(0,34);
		#### # 0;
		goto nope;
		
    reloadend_nomag:
        #### E 0 A_JumpIf(invoker.weaponstatus[STENS_JAMMED],2);
        #### D 0;
		#### # 3 offset(30,69); 
		#### # 2 offset(20,59);
		#### # 1 offset(10,49);
		#### # 1 offset(5,38);
		#### # 1 offset(0,34);
		goto nope;

	chamber_manual://no manual chamber, it's openbolt
	
		goto nope;

	spawn:
		TNT1 A 1;
		STNP A -1{
			if(invoker.weaponstatus[STENS_MAG]<0)frame=1;
		}
		STNP # -1;
		stop;
	}
	override void initializewepstats(bool idfa){
		weaponstatus[STENS_MAG]=30;
		weaponstatus[STENS_AUTO]=0;
		weaponstatus[STENS_CHAMBER]=0;//it's an openbolt, no round in the chamber
		weaponstatus[STENS_JAMMED]=0;//clear any jams
		weaponstatus[STENS_HEAT]=0;//remove any heat
	}
	override void loadoutconfigure(string input){}
}
enum stenmk2status{
	STENF_JUSTUNLOAD=1,
	STENF_REFLEXSIGHT=2,

	STEN_SEMIONLY=1,
	STEN_BURSTONLY=2,
	STEN_FULLONLY=3,

	STENS_FLAGS=0,
	STENS_MAG=1,
	STENS_CHAMBER=2, //0 empty, 1 spent, 2 loaded
	STENS_AUTO=3, //0 semi, 1 burst, 2 auto
	STENS_RATCHET=4,
	STENS_SWITCHTYPE=5,
	STENS_HEAT=6,
	STENS_JAMMED=7,
};

class HDSTENRandom:IdleDummy{
	states{
	spawn:
		TNT1 A 0 nodelay{
			let lll=HDStenMk2(spawn("HDStenMk2",pos,ALLOW_REPLACE));
			if(!lll)return;
			lll.special=special;
			lll.vel=vel;
			for(int i=0;i<5;i++)lll.args[i]=args[i];
			//if(!random(0,2))lll.weaponstatus[0]|=STENF_REFLEXSIGHT;
			//if(!random(0,2))lll.weaponstatus[STENS_SWITCHTYPE]=random(0,3);
		}stop;
	}
}
