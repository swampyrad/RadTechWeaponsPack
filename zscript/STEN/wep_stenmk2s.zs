
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
		inventory.pickupmessage "You got the STEN Mk. 2(S)!";
		hdweapon.barrelsize 21,0.5,1;
		hdweapon.refid HDLD_STEN;
		tag "STEN Mk.2(S)";
		inventory.icon "STNPA0";

		hdweapon.loadoutcodes "
		//	\cufiremode - 0-2, semi/burst/auto
		//	\cufireswitch - 0-4, default/semi/auto/full/all
		//	\cureflexsight - 0-1, no/yes
		//	\cudot - 0-5
			";//no configs, WYSIWYG
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
	override double weaponbulk(){
		int mg=weaponstatus[STENS_MAG];
		if(mg<0)return 80;
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
	override void postbeginplay(){
		super.postbeginplay();
			weaponstatus[STENS_AUTO]=0;
		    //set to semi by default
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
		sb.drawwepnum(hdw.weaponstatus[STENS_HEAT],HDSTEN_OVERHEAT,-16,-14);
		//draws a heat indicator bar above the firemode
		
		if(hdw.weaponstatus[STENS_CHAMBER]>=1)sb.drawrect(-19,-11,3,1);
	}
	override string gethelptext(){
		return
		WEPHELP_FIRESHOOT
		..WEPHELP_ALTFIRE.."  Clear jam\n"
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
			bobb.y=clamp(bobb.y,-8,8);
			sb.drawimage(
				"smgfrntsit",(0,0)+bobb,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP
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
		STEN A 0 ;
		goto select0small;
	deselect0:
		STEN A 0 ;
		goto deselect0small;
		STEN AB 0;
		STEN AB 0;

	ready:
		STEN A 0;
		#### A 1{
			A_SetCrosshair(21);
			invoker.weaponstatus[STENS_RATCHET]=0;
			A_WeaponReady(WRF_ALL);
		}
		goto readyend;
	user3:
		---- A 0 A_MagManager("HD9mMag30");
		goto ready;
	altfire:
		goto unloadchamber;
	althold:
		//goto nope;

	hold:
		#### A 0{
			if(
				invoker.weaponstatus[STENS_MAG]>0  // if mag is empty, stop firing
				&&(
					invoker.weaponstatus[STENS_AUTO]==2  //full auto
					||(
						invoker.weaponstatus[STENS_AUTO]==1  //burst
						&&invoker.weaponstatus[STENS_RATCHET]<=2
					)
				)
			)setweaponstate("fire2");
		}goto nope;
	user2:
	firemode:
    //no burst, only semi and auto
		---- A 1{ 
			    int canaut=invoker.weaponstatus[STENS_AUTO];
			
			    //if set to auto, reset to semi
		    	if(canaut==2)invoker.weaponstatus[STENS_AUTO]=0;
				
                //set to auto if in semi
		    	else invoker.weaponstatus[STENS_AUTO]=2;
			
		    }
	    	goto nope;
		
		
	fire:
	   	#### A 0 A_JumpIf(
		         invoker.weaponstatus[STENS_MAG]<1||
		         invoker.weaponstatus[STENS_JAMMED]
	             ,"nope");
	             //do nothing if no ammo left
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
	
		#### A 1 {
		        A_GunFlash();//fire the gun, then eject the spent casing
		       
		        if(!random(0,50))setweaponstate("jam");
				 //random chance to jam
				 
		        if(invoker.weaponstatus[STENS_CHAMBER]==1){
		            
				    A_EjectCasing("HDSpent9mm",
					frandom(-1,2),
					(frandom(0.2,0.3),-frandom(7,7.5),frandom(0,0.2)),
					(0,0,-2)
				    );
				    invoker.weaponstatus[STENS_CHAMBER]=0;
			    }
			if(invoker.weaponstatus[STENS_HEAT]>=HDSTEN_OVERHEAT)setweaponstate("overheat");
			//stop the gun once it hits max heat
		}
		#### A 3;//+2 tic, slower firerate than the SMG
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

	unloadchamber:
		#### B 4 A_JumpIf(!invoker.weaponstatus[STENS_JAMMED],"nope");
		#### B 10{
			//class<actor>which=invoker.weaponstatus[STENS_CHAMBER]>1?"HDPistolAmmo":"HDSpent9mm";
			invoker.weaponstatus[STENS_CHAMBER]=0;
			invoker.weaponstatus[STENS_JAMMED]=0;  
			A_StartSound("weapons/sten_chamber",8,CHANF_OVERLAP);
			A_StartSound("weapons/riflejam",CHAN_WEAPON,CHANF_OVERLAP);

	        A_MuzzleClimb(frandom(0.2,0.24),-frandom(0.3,0.36),frandom(0.2,0.24),-frandom(0.3,0.36));
  
			A_SpawnItemEx("HDSpent9mm",
				cos(pitch)*10,0,height*0.82-sin(pitch)*10,
				vel.x,vel.y,vel.z,
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
			);
		}goto readyend;
		
	loadchamber:
		---- A 0 A_JumpIf(invoker.weaponstatus[STENS_CHAMBER]>0,"nope");
		---- A 0 A_JumpIf(!countinv("HDPistolAmmo"),"nope");
		---- A 1 offset(0,34) A_StartSound("weapons/pocket",9);
		---- A 1 offset(2,36);
		---- A 1 offset(2,44);
		#### B 1 offset(5,58);
		#### B 2 offset(7,70);
		#### B 6 offset(8,80);
		#### A 10 offset(8,87){
			if(countinv("HDPistolAmmo")){
				A_TakeInventory("HDPistolAmmo",1,TIF_NOTAKEINFINITE);
				invoker.weaponstatus[STENS_CHAMBER]=2;
				A_StartSound("weapons/sten_chamber",8);
			}else A_SetTics(4);
		}
		#### A 3 offset(9,76);
		---- A 2 offset(5,70);
		---- A 1 offset(5,64);
		---- A 1 offset(5,52);
		---- A 1 offset(5,42);
		---- A 1 offset(2,36);
		---- A 2 offset(0,34);
		goto nope;
		
	jam:
		STEN B 1 offset(-1,36){
		    invoker.weaponstatus[STENS_CHAMBER]=1;
		    invoker.weaponstatus[STENS_JAMMED]=1;  
			A_StartSound("weapons/riflejam",CHAN_WEAPON,CHANF_OVERLAP);
			}
		STEN A 1 offset(1,30) A_StartSound("weapons/riflejam",CHAN_WEAPON,CHANF_OVERLAP);
		goto nope;
		
	overheat:
	    STEN A 1 offset(-1,36){
			A_StartSound("weapons/sten_overheat",CHAN_WEAPON,CHANF_OVERLAP);
			}
		STEN BBBBBA 10 offset(1,30) A_SpawnItemEx("HDGunSmoke",
				cos(pitch)*10,0,height*0.82-sin(pitch)*10,
				vel.x,vel.y,vel.z,
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
			);
        goto nope;
	user4:
	unload:
		#### A 0{
			invoker.weaponstatus[0]|=STENF_JUSTUNLOAD;
			if(
				invoker.weaponstatus[STENS_MAG]>=0
			)setweaponstate("unmag");
			else if(invoker.weaponstatus[STENS_CHAMBER]>0)setweaponstate("unloadchamber");
		}goto nope;
	reload:
		#### A 0{
			invoker.weaponstatus[0]&=~STENF_JUSTUNLOAD;
			bool nomags=HDMagAmmo.NothingLoaded(self,"HD9mMag30");
			if(invoker.weaponstatus[STENS_MAG]>=30)setweaponstate("nope");
			//do not reload if full mag 
			
			else if (nomags)setweaponstate("nope");
		}goto unmag;
		
	unmag:
		#### A 1 offset(0,34) A_SetCrosshair(21);
		#### A 1 offset(5,42);
		#### A 1 offset(10,50);
		#### B 2 offset(20,58) A_StartSound("weapons/smgmagclick",8);
		#### B 4 offset(30,70){
			A_MuzzleClimb(0.3,0.4);
			A_StartSound("weapons/smgmagmove",8,CHANF_OVERLAP);
		}
		#### B 0{
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
		#### BB 7 offset(35,80) A_MuzzleClimb(frandom(0.2,-0.8),frandom(-0.2,0.4));
	magout:
		#### B 0{
			if(invoker.weaponstatus[0]&STENF_JUSTUNLOAD)setweaponstate("reloadend");
			else setweaponstate("loadmag");
		}

	loadmag:
		#### B 0 A_StartSound("weapons/pocket",9);
		#### B 6 offset(35,80) A_MuzzleClimb(frandom(0.2,-0.8),frandom(-0.2,0.4));
		#### B 7 offset(33,79) A_MuzzleClimb(frandom(0.2,-0.8),frandom(-0.2,0.4));
		#### B 10 offset(32,77);
		#### B 3 offset(32,75){
			let mmm=hdmagammo(findinventory("HD9mMag30"));
			if(mmm){
				invoker.weaponstatus[STENS_MAG]=mmm.TakeMag(true);
				A_StartSound("weapons/smgmagclick",8,CHANF_OVERLAP);
			}
			if(
				invoker.weaponstatus[STENS_MAG]<1
				||invoker.weaponstatus[STENS_CHAMBER]>0
			)setweaponstate("reloadend");
		}
		goto reloadend;

	reloadend:
		#### B 3 offset(30,69);
		#### B 2 offset(20,59);
		#### A 1 offset(10,49);
		#### A 1 offset(5,38);
		#### A 1 offset(0,34);
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

