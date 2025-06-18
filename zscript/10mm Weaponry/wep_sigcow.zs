// ------------------------------------------------------------
// M-211 Semi-Automatic Gas-Operated Combat Weapon (aka Sig-Cow)
// ------------------------------------------------------------

//Sig-Cow magazine encumberance values
const enc_10MAG=9;
const enc_10MAG_EMPTY=enc_10MAG*0.3;
const enc_10MAG_LOADED=enc_10MAG_EMPTY*0.1;
const enc_10MAG25_EMPTY=enc_10MAG_EMPTY*2.5;
const enc_10MAG25=enc_10MAG25_EMPTY+enc_10_LOADED*25;
const enc_10MAG25_LOADED=enc_10MAG25*0.8;

class HDSigCow:HDWeapon{
    //melee stuff
    int targettimer;
	int targethealth;
	int targetspawnhealth;
	bool flicked;
	bool washolding;

    //track player strength to modify melee damage/attack speed
    double strength;
	action void A_StrengthTics(int mintics,int maxtics=-1){
		if(invoker.strength==1.)return;
		if(maxtics<0)maxtics=tics;
		int ttt=min(maxtics,int(tics/invoker.strength));
		A_SetTics(max(mintics,int(ttt)));
	}

	default{
		//$Category "Weapons/Hideous Destructor"
		//$Title "Sig-Cow"
		//$Sprite "RF10A0"
		
		+hdweapon.fitsinbackpack
		obituary "%o stepped in %k's cow pie.";
		weapon.selectionorder 24;
		weapon.slotnumber 4;
		weapon.slotpriority 0.1;
		weapon.kickback 30;
		weapon.bobrangex 0.3;
		weapon.bobrangey 0.8;
		weapon.bobspeed 2.5;
		scale 0.55;
		inventory.pickupmessage "$PICKUP_SIGCOW";
		hdweapon.barrelsize 26,0.5,1;
		hdweapon.refid "scw";
		tag "$TAG_SIGCOW";
		inventory.icon "RF10A0";

		hdweapon.ammo1 "HD10mMag25",1;

		hdweapon.loadoutcodes "
			\cufiremode - 0-2, semi/burst/auto
			\cufireswitch - 0-4, default/semi/auto/full/all
		";
	}
	
	override bool AddSpareWeapon(actor newowner){return AddSpareWeaponRegular(newowner);}
	override hdweapon GetSpareWeapon(actor newowner,bool reverse,bool doselect){return GetSpareWeaponRegular(newowner,reverse,doselect);}
	
	override double gunmass(){
		return 5+((weaponstatus[SCWS_MAG]<0)?-0.5:(weaponstatus[SCWS_MAG]*0.05));
	}
	
	override double weaponbulk(){
		int mg=weaponstatus[SCWS_MAG];
		if(mg<0)return 80;//-10 bulk less than the SMG
		else return (80+ENC_10MAG25_LOADED)+mg*(ENC_10_LOADED);
	}
	
	override void failedpickupunload(){
		failedpickupunloadmag(SCWS_MAG,"HD10mMag25");
	}
	
	override void DropOneAmmo(int amt){
		if(owner){
			amt=clamp(amt,1,10);
			if(owner.countinv("HD10mAmmo"))owner.A_DropInventory("HD10mAmmo",amt*25);
			else owner.A_DropInventory("HD10mMag25",amt);
		}
	}
	
	override void postbeginplay(){
		super.postbeginplay();
		if(weaponstatus[SCWS_AUTO]>0){
		switch(weaponstatus[SCWS_SWITCHTYPE]){
		case 1:
			weaponstatus[SCWS_AUTO]=0;
			break;
		case 2:
			weaponstatus[SCWS_AUTO]=1;
			break;
		case 3:
			weaponstatus[SCWS_AUTO]=2;
			break;
		default:
			break;
		}}
	}
	
	override void ForceBasicAmmo(){
		owner.A_TakeInventory("HD10mAmmo");
		ForceOneBasicAmmo("HD10mMag25");
	}
	
	override string,double getpickupsprite(bool usespare){
		int wep0=GetSpareWeaponValue(0,usespare);
		return ("RF10")
			..((GetSpareWeaponValue(SCWS_MAG,usespare)<0)?"B":"A").."0",1.;
	}

	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
			int nextmagloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("HD10mMag25")));
			if(nextmagloaded>=25){
				sb.drawimage("C10MA0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1,1));
			}else if(nextmagloaded<1){
				sb.drawimage("C10MD0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextmagloaded?0.6:1.,scale:(1,1));
			}else sb.drawbar(
				"C10MA0","C10MC0",
				nextmagloaded,25,
				(-46,-3),-1,
				sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
			);
			sb.drawnum(hpl.countinv("HD10mMag25"),-43,-8,sb.DI_SCREEN_CENTER_BOTTOM);
		}

		if(weaponstatus[SCWS_SWITCHTYPE]!=1)sb.drawwepcounter(hdw.weaponstatus[SCWS_AUTO],
			-22,-10,"RBRSA3A7","STBURAUT","STFULAUT"
		);
		sb.drawwepnum(hdw.weaponstatus[SCWS_MAG],25);
		if(hdw.weaponstatus[SCWS_CHAMBER]==2)sb.drawrect(-19,-11,3,1);
	}

	override string gethelptext(){
		return  
		LWPHELP_FIRESHOOT
        ..LWPHELP_ALTFIRE.."  Bayonet Stab\n"
		..LWPHELP_RELOAD.."  Reload mag\n"
		..LWPHELP_USE.."+"..LWPHELP_RELOAD.."  Reload chamber\n"
		..LWPHELP_FIREMODE.."  Semi/Burst/Auto\n"
		..LWPHELP_MAGMANAGER
		..LWPHELP_UNLOADUNLOAD  
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
		sb.drawimage(
			"smgfrntsit",(0,0)+bobb,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP
		);
		sb.SetClipRect(cx,cy,cw,ch);
		sb.drawimage(
			"scbksite",(0,0)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			alpha:0.9
		);
	}
	
	//check for melee target and berserk activated
	override void DoEffect(){
		super.DoEffect();
		if(targettimer<70)targettimer++;else{
			tracer=null;
			targettimer=0;
			targethealth=0;
		}
		
		let hdp=hdplayerpawn(owner);
		strength=hdp?hdp.strength:1.;
		if(owner.countinv("HDZerk")>HDZerk.HDZERK_COOLOFF){
			strength*=1.2;
			if(!random[zrkbs](0,70)){
				static const string zrkbs[]={"kill","k i l l","k I L L",
				                            "K\n   I\n       L\n          L",
				                            "Kill.","KILL","k i l l","Kill!",
				                            "K  I  L  L","kill...","Kill...",
				                            "k i l l . . .","      kill","  ... kill ...",
				                            "kill,","kiiiilllll!!!","kill~","kill <3",
				                            "kill uwu"};
				hdp.usegametip("\cr"..zrkbs[random(0,zrkbs.size()-1)]);
			}
		}
	}
	
	//bayonet stab attack
	action void HD_SigCowStab(double dmg){
		let punchrange=96;// 1.5x extra range compared to fist attack
		if(hdplayerpawn(self))punchrange*=hdplayerpawn(self).heightmult;

		flinetracedata punchline;
		bool punchy=linetrace(
			angle,punchrange,pitch,
			TRF_NOSKY,
			offsetz:height*0.77,
			data:punchline
		);
		if(!punchy)return;

		//actual puff effect if the shot connects
		LineAttack(
			angle,
			punchrange,
			pitch,
			punchline.hitline?(int(frandom(5,15)*invoker.strength)):0,
			"none",
			(invoker.strength>1.5)?"BulletPuffMedium":"BulletPuffSmall",
			flags:LAF_NORANDOMPUFFZ|LAF_OVERRIDEZ,
			offsetz:height*0.78
		);

		if(!punchline.hitactor){
			HDF.Give(self,"WallChunkAmmo",1);
			if(punchline.hitline){
			    doordestroyer.CheckDirtyWindowBreak(punchline.hitline,
			                                        0.15+0.01*invoker.strength,
			                                        punchline.hitlocation
			                                        );
			 }
			return;
		}
		actor punchee=punchline.hitactor;

		//charge!
		dmg*=1.5;
		dmg += 1;

		//come in swinging
		let onr=hdplayerpawn(self);
		double ptch=0.;
		double pyaw=0.;
		if(onr){
			ptch=deltaangle(onr.lastpitch,onr.pitch);
			pyaw=deltaangle(onr.lastangle,onr.angle);
			double iy=max(abs(ptch),abs(pyaw));
			if(pyaw<0)iy*=1.6;
			if(player.onground)dmg+=min(abs(iy)*5,dmg*3);
		}

		//shit happens
		dmg*=invoker.strength*frandom(1.,1.2);

		//other effects
		if(
			onr
			&&!punchee.bdontthrust
			&&(
				punchee.mass<200
				||(
					punchee.radius*2<punchee.height
					&& punchline.hitlocation.z>punchee.pos.z+punchee.height*0.6
				)
			)
		){
			if(abs(pyaw)>(0.5)){
				punchee.A_SetAngle(clamp(normalize180(punchee.angle-pyaw*100),-50,50),SPF_INTERPOLATE);
			}
			if(abs(ptch)>(0.5*65535/360)){
				punchee.A_SetPitch(clamp((punchee.angle+ptch*100)%90,-30,30),SPF_INTERPOLATE);
			}
		}

		let hdmp=hdmobbase(punchee);

		//headshot lol
		if(
			!punchee.bnopain
			&&punchee.health>0
			&&(
				!hdmp
				||!hdmp.bheadless
			)
			&&punchline.hitlocation.z>punchee.pos.z+punchee.height*0.75
		){
			if(hd_debug)A_Log("HEAD SHOT");
			hdmobbase.forcepain(punchee);
			dmg*=frandom(1.1,1.8);
			if(hdmp)hdmp.stunned+=(int(dmg)>>2);
		}

		if(hd_debug)A_Log("Shanked "..punchee.getclassname().." for "..int(dmg).." damage!");

		bool puncheewasalive=!punchee.bcorpse&&punchee.health>0;

		if(dmg*2>punchee.health)punchee.A_StartSound("misc/bulletflesh",CHAN_AUTO);
		
		let aaa = HDFistPuncher(invoker.spawn("HDFistPuncher", invoker.pos));
		if(aaa)
		{
			aaa.master = invoker;
			punchee.damagemobj(aaa,self,int(dmg),"slashing");
        
        //bleed code borrowed from PBWeappns knife zscript
        //bonus points to BenitezClanceIV for suggesting it
        if(!punchee.countinv("HDArmourWorn")){
	        HDBleedingWound.inflict(punchee,dmg*frandom(1.3,1.8));
	        HDBleedingWound.inflict(punchee,dmg*frandom(1.3,1.8));
            }		
			aaa.destroy();
		}
		if(!punchee)invoker.targethealth=0;else{
			invoker.targethealth=punchee.health;
			invoker.targetspawnhealth=punchee.spawnhealth();
			invoker.targettimer=0;
			if(
				(
					punchee.bismonster
					||!!punchee.player
				)
				&&countinv("HDZerk")>HDZerk.HDZERK_COOLOFF
			){
				if(
					punchee.bcorpse
					&&puncheewasalive
				){
					A_StartSound("weapons/zerkding2",CHAN_WEAPON,CHANF_OVERLAP|CHANF_LOCAL);
					givebody(10);
					if(onr){
						onr.fatigue-=onr.fatigue>>2;
						onr.usegametip("\cfK I L L !");
					}
				}else{
					A_StartSound("weapons/zerkding",CHAN_WEAPON,CHANF_OVERLAP|CHANF_LOCAL);
				}
			}
		}
	}
	
	states{
	select0:
		RBAY A 0;
		goto select0small;
	deselect0:
		RBAY A 0;
		goto deselect0small;
		RBAY AB 0;

	ready:
		RBAY A 0{invoker.breverseguninertia=false;}
		#### A 1{
			A_SetCrosshair(21);
			invoker.weaponstatus[SCWS_RATCHET]=0;
			A_WeaponReady(WRF_ALL);
		}
		goto readyend;
	user3:
		---- A 0 A_MagManager("HD10mMag25");
		goto ready;
		
	altfire:
	RBAY B 1{invoker.breverseguninertia=true;}
	RBAY B 1 A_JumpIf(pressingaltfire(),"altfire");//adds a windup before stabbing
	RBAY C 3 {A_StrengthTics(0,2); A_Recoil(-1);}// adds a short charge before stabbing
	RBAY D 0 A_Recoil(min(0,1.-invoker.strength));
	RBAY D 0 HD_SigCowStab(20);
	RBAY D 4 A_StrengthTics(3,10);
	RBAY C 2 A_StrengthTics(1,5);
	RBAY A 3 A_StrengthTics(0,5);
	RBAY A 0 A_JumpIf(pressingaltfire(),"altfire");
	RBAY A 1 A_ReFire();
	goto ready;
	
	althold:
	//	goto altfire;
	
	hold:
		#### A 0{
			if(
				invoker.weaponstatus[SCWS_CHAMBER]==2  //live round chambered
				&&(
					invoker.weaponstatus[SCWS_AUTO]==2  //full auto
					||(
						invoker.weaponstatus[SCWS_AUTO]==1  //burst
						&&invoker.weaponstatus[SCWS_RATCHET]<=2
					)
				)
			)setweaponstate("fire2");
		}goto nope;
	user2:
	firemode:
		---- A 1{
			int canaut=invoker.weaponstatus[SCWS_SWITCHTYPE];
			if(canaut==1){
				invoker.weaponstatus[SCWS_AUTO]=0;
				return;
			}
			int maxmode=(canaut>0)?(canaut-1):2;
			int aut=invoker.weaponstatus[SCWS_AUTO];
			if(aut>=maxmode)invoker.weaponstatus[SCWS_AUTO]=0;
			else if(aut<0)invoker.weaponstatus[SCWS_AUTO]=0;
			else if(canaut>0)invoker.weaponstatus[SCWS_AUTO]=maxmode;
			else invoker.weaponstatus[SCWS_AUTO]++;
		}goto nope;
	fire:
		#### A 0;
	fire2:
		#### B 0{
			if(invoker.weaponstatus[SCWS_CHAMBER]==2)A_GunFlash();
			else setweaponstate("chamber_manual");
		}
		#### A 1;
		#### A 0{
			if(invoker.weaponstatus[SCWS_CHAMBER]==1){
				A_EjectCasing("HDSpent10mm",
					frandom(-1,2),
					(frandom(0.2,0.3),-frandom(7,7.5),frandom(0,0.2)),
					(0,0,-2)
				);
				invoker.weaponstatus[SCWS_CHAMBER]=0;
			}
			if(invoker.weaponstatus[SCWS_MAG]>0){
				invoker.weaponstatus[SCWS_MAG]--;
				invoker.weaponstatus[SCWS_CHAMBER]=2;
			}
			if(invoker.weaponstatus[SCWS_AUTO]==2)A_SetTics(1);

			//don't allow firing if supposed to be lowered
			A_WeaponReady(WRF_NOFIRE);
		}
		#### A 2 {if(invoker.weaponstatus[SCWS_AUTO]==1)A_SetTics(1);}
		//burst-fire is faster than full-auto
		#### A 0 A_ReFire();
		goto ready;
	flash:
		#### B 0{
			let bbb=HDBulletActor.FireBullet(self,"HDB_10",speedfactor:1.1);
			if(
				frandom(16,ceilingz-floorz)<bbb.speed*0.1
			)A_AlertMonsters(200);

			A_ZoomRecoil(0.995);
			A_StartSound("weapons/sigcow",CHAN_WEAPON);
			invoker.weaponstatus[SCWS_RATCHET]++;
			invoker.weaponstatus[SCWS_CHAMBER]=1;
		}
		SCWF A 1 bright{
			HDFlashAlpha(-200);
			A_Light1();
		}
		TNT1 A 0 A_MuzzleClimb(-frandom(0.4,0.48),-frandom(0.6,0.72),
                               -frandom(0.6,0.72),-frandom(0.8,0.96));
		goto lightdone;


	unloadchamber:
		#### B 4 A_JumpIf(invoker.weaponstatus[SCWS_CHAMBER]<1,"nope");
		#### B 10{
			class<actor>which=invoker.weaponstatus[SCWS_CHAMBER]>1?"HD10mAmmo":"HDSpent10mm";
			invoker.weaponstatus[SCWS_CHAMBER]=0;
			A_SpawnItemEx(which,
				cos(pitch)*10,0,height*0.82-sin(pitch)*10,
				vel.x,vel.y,vel.z,
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
			);
		}goto readyend;
	loadchamber:
		---- A 0 A_JumpIf(invoker.weaponstatus[SCWS_CHAMBER]>0,"nope");
		---- A 0 A_JumpIf(!countinv("HD10mAmmo"),"nope");
		---- A 1 offset(0,34) A_StartSound("weapons/pocket",9);
		---- A 1 offset(2,36);
		---- A 1 offset(2,44);
		#### B 1 offset(5,58);
		#### B 2 offset(7,70);
		#### B 6 offset(8,80);
		#### A 10 offset(8,87){
			if(countinv("HD10mAmmo")){
				A_TakeInventory("HD10mAmmo",1,TIF_NOTAKEINFINITE);
				invoker.weaponstatus[SCWS_CHAMBER]=2;
				A_StartSound("weapons/sigcow_chamber",8);
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
	user4:
	unload:
		#### A 0{
			invoker.weaponstatus[0]|=SCWF_JUSTUNLOAD;
			if(
				invoker.weaponstatus[SCWS_MAG]>=0
			)setweaponstate("unmag");
			else if(invoker.weaponstatus[SCWS_CHAMBER]>0)setweaponstate("unloadchamber");
		}goto nope;
	reload:
		#### A 0{
			invoker.weaponstatus[0]&=~SCWF_JUSTUNLOAD;
			bool nomags=HDMagAmmo.NothingLoaded(self,"HD10mMag25");
			if(invoker.weaponstatus[SCWS_MAG]>=25)setweaponstate("nope");
			else if(
				invoker.weaponstatus[SCWS_MAG]<1
				&&(
					pressinguse()
					||nomags
				)
			){
				if(
					countinv("HD10mAmmo")
				)setweaponstate("loadchamber");
				else setweaponstate("nope");
			}else if(nomags)setweaponstate("nope");
		}goto unmag;
	unmag:
		#### A 1 offset(0,34) A_SetCrosshair(21);
		#### A 1 offset(5,38);
		#### A 1 offset(10,42);
		#### B 2 offset(20,46) A_StartSound("weapons/sigcow_magclick",8);
		#### B 4 offset(30,52){
			A_MuzzleClimb(0.3,0.4);
			A_StartSound("weapons/sigcow_magmove",8,CHANF_OVERLAP);
		}
		#### B 0{
			int magamt=invoker.weaponstatus[SCWS_MAG];
			if(magamt<0){
				setweaponstate("magout");
				return;
			}
			invoker.weaponstatus[SCWS_MAG]=-1;
			if(
				(!PressingUnload()&&!PressingReload())
				||A_JumpIfInventory("HD10mMag25",0,"null")
			){
				HDMagAmmo.SpawnMag(self,"HD10mMag25",magamt);
				setweaponstate("magout");
			}else{
				HDMagAmmo.GiveMag(self,"HD10mMag25",magamt);
				A_StartSound("weapons/pocket",9);
				setweaponstate("pocketmag");
			}
		}
	pocketmag:
		#### BB 7 offset(34,54) A_MuzzleClimb(frandom(0.2,-0.8),frandom(-0.2,0.4));
	magout:
		#### B 0{
			if(invoker.weaponstatus[0]&SCWF_JUSTUNLOAD)setweaponstate("reloadend");
			else setweaponstate("loadmag");
		}

	loadmag:
		#### B 0 A_StartSound("weapons/pocket",9);
		#### B 6 offset(34,54) A_MuzzleClimb(frandom(0.2,-0.8),frandom(-0.2,0.4));
		#### B 7 offset(34,52) A_MuzzleClimb(frandom(0.2,-0.8),frandom(-0.2,0.4));
		#### B 10 offset(32,50);
		#### B 3 offset(32,49){
			let mmm=hdmagammo(findinventory("HD10mMag25"));
			if(mmm){
				invoker.weaponstatus[SCWS_MAG]=mmm.TakeMag(true);
				A_StartSound("weapons/smgmagclick",8,CHANF_OVERLAP);
			}
			if(
				invoker.weaponstatus[SCWS_MAG]<1
				||invoker.weaponstatus[SCWS_CHAMBER]>0
			)setweaponstate("reloadend");
		}
		goto reloadend;

	reloadend:
		#### B 3 offset(30,52);
		#### B 2 offset(20,46);
		#### A 1 offset(10,42);
		#### A 1 offset(5,38);
		#### A 1 offset(0,34);
		goto chamber_manual;

	chamber_manual:
		#### A 0 A_JumpIf(
			invoker.weaponstatus[SCWS_MAG]<1
			||invoker.weaponstatus[SCWS_CHAMBER]==2
		,"nope");
		#### B 2 offset(3,32){
			A_WeaponBusy();
			invoker.weaponstatus[SCWS_MAG]--;
			invoker.weaponstatus[SCWS_CHAMBER]=2;
		}
		#### B 3 offset(5,35) A_StartSound("weapons/sigcow_chamber",8,CHANF_OVERLAP);
		#### A 1 offset(3,32);
		#### A 1 offset(2,31);
		goto nope;


	spawn:
		TNT1 A 1;
		RF10 A -1{
			if(invoker.weaponstatus[SCWS_MAG]<0)frame=1;
			invoker.sprite=getspriteindex("RF10A0");
		}
		RF10 # -1;
		stop;
	}
	override void initializewepstats(bool idfa){
		weaponstatus[SCWS_MAG]=25;
		weaponstatus[SCWS_CHAMBER]=2;
	}
	override void loadoutconfigure(string input){
		int firemode=getloadoutvar(input,"firemode",1);
		if(firemode>=0)weaponstatus[SCWS_AUTO]=clamp(firemode,0,2);

		int fireswitch=getloadoutvar(input,"fireswitch",1);

    if(fireswitch<0)weaponstatus[SCWS_SWITCHTYPE]=1;
    //standard issue is semi-only, just like in the books
		if(fireswitch>3)weaponstatus[SCWS_SWITCHTYPE]=0;
		else if(fireswitch>0)weaponstatus[SCWS_SWITCHTYPE]=clamp(fireswitch,0,3);
	}
}

enum sigcowstatus{
	SCWF_JUSTUNLOAD=1,

	SCWN_SEMIONLY=1,
	SCWN_BURSTONLY=2,
	SCWN_FULLONLY=3,

	SCWS_FLAGS=0,
	SCWS_MAG=1,
	SCWS_CHAMBER=2, //0 empty, 1 spent, 2 loaded
	SCWS_AUTO=3, //0 semi, 1 burst, 2 auto
	SCWS_RATCHET=4,
	SCWS_SWITCHTYPE=5,
	SCWS_DOT=6,
};

class HDSigCowSelectfire:IdleDummy{
	states{
	spawn:
		TNT1 A 0 nodelay{
			let lll=HDSigCow(spawn("HDSigCow",pos,ALLOW_REPLACE));
			if(!lll)return;
			lll.special=special;
			lll.vel=vel;
			for(int i=0;i<5;i++)lll.args[i]=args[i];
		
		}stop;
	}
}

class HDSigCowSemi:IdleDummy{
	states{
	spawn:
		TNT1 A 0 nodelay{
			let semi=HDSigCow(spawn("HDSigCow",pos,ALLOW_REPLACE));
			if(!semi)return;
			semi.special=special;
			semi.vel=vel;
			for(int i=0;i<5;i++)semi.args[i]=args[i];
			
			semi.weaponstatus[SCWS_SWITCHTYPE]=1;
		}stop;
	}
}

class HDSigCowSemiBurst:IdleDummy{
	states{
	spawn:
		TNT1 A 0 nodelay{
			let semiburst=HDSigCow(spawn("HDSigCow",pos,ALLOW_REPLACE));
			if(!semiburst)return;
			semiburst.special=special;
			semiburst.vel=vel;
			for(int i=0;i<5;i++)semiburst.args[i]=args[i];
			
			semiburst.weaponstatus[SCWS_SWITCHTYPE]=2;
		}stop;
	}
}

class SigCowRandomSpawn:IdleDummy{
	override void postbeginplay(){
		super.postbeginplay();
		A_SpawnItemEx("HD10mMag25",flags:SXF_NOCHECKPOSITION);
		if(!random(0,2))A_SpawnItemEx("HDFragGrenadeAmmo",-3,-3,flags:SXF_NOCHECKPOSITION);
		if(!random(0,9)){
    A_SpawnItemEx("TenMilAutoReloader",5,5,flags:SXF_NOCHECKPOSITION);
			A_SpawnItemEx("HD10mMag25",3,3,flags:SXF_NOCHECKPOSITION);
			A_SpawnItemEx("HDSigCowSelectfire",1,1,flags:SXF_NOCHECKPOSITION);
		}else if(!random(0,4)){
			A_SpawnItemEx("HD10mMag25",3,3,flags:SXF_NOCHECKPOSITION);
			A_SpawnItemEx("HDSigCowSemiBurst",1,1,flags:SXF_NOCHECKPOSITION);
		}else A_SpawnItemEx("HDSigCowSemi",1,1,flags:SXF_NOCHECKPOSITION);
		destroy();
	}
}

class HD10mMag8:HDMagAmmo{
	default{
		//$Category "Ammo/Hideous Destructor/"
		//$Title "Pistol Magazine"
		//$Sprite "SC15A0"
		hdmagammo.maxperunit 8;
		hdmagammo.roundtype "HD10mAmmo";
		hdmagammo.roundbulk enc_10_LOADED;
		hdmagammo.magbulk enc_10MAG_EMPTY; 
		scale 0.35;
		tag "$TAG_10PISMAG";
		hdpickup.refid "SC8";
	}

	override string pickupmessage(){
		return Stringtable.Localize("$PICKUP_10MAG8");
	}

	override string,string,name,double getmagsprite(int thismagamt){
		string magsprite=(thismagamt>0)?"SC15A0":"SC15C0";
		return magsprite,"PR10A0","HD10mAmmo",0.6;
	}
	override void GetItemsThatUseThis(){
		itemsthatusethis.push("HD10mmPistol");
	}
	states{
	spawn:
		SC15 A -1;
		stop;
	spawnempty:
		SC15 B -1{
			brollsprite=true;brollcenter=true;
			roll=randompick(0,0,0,0,2,2,2,2,1,3)*90;
		}stop;
	}
}

class HD10mMag25:HD10mMag8{
	default{
		//$Category "Ammo/Hideous Destructor/"
		//$Title "SigCow Magazine"
		//$Sprite "CLP3A0"
        scale 0.35;
		hdmagammo.maxperunit 25;
		hdmagammo.magbulk enc_10mag25_EMPTY;
		tag "$TAG_SCWMAG";
		hdpickup.refid "S25";
	}

	override string pickupmessage(){
		return Stringtable.Localize("$PICKUP_10MAG25");
	}

	override string,string,name,double getmagsprite(int thismagamt){
		string magsprite=(thismagamt>0)?"C10MA0":"C10MB0";
		return magsprite,"PR10A0","HD10mAmmo",0.6;
	}
	override void GetItemsThatUseThis(){
		itemsthatusethis.push("HDSigCow");
	}
	states{
	spawn:
		C10M A -1;//clip, 10mm
		stop;
	spawnempty:
		C10M B -1{
			brollsprite=true;brollcenter=true;
			roll=randompick(0,0,0,0,2,2,2,2,1,3)*90;
		}stop;
	}
}

class HD10mPistolEmptyMag:IdleDummy{
	override void postbeginplay(){
		super.postbeginplay();
		HDMagAmmo.SpawnMag(self,"HD10mMag8",0);
		destroy();
	}
}
class HDSigCowEmptyMag:IdleDummy{
	override void postbeginplay(){
		super.postbeginplay();
		HDMagAmmo.SpawnMag(self,"HD10mMag25",0);
		destroy();
	}
}
