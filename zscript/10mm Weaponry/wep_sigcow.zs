// ------------------------------------------------------------
// SMG
// ------------------------------------------------------------
class HDSigCow:HDWeapon{

int targettimer;
	int targethealth;
	int targetspawnhealth;
	bool flicked;
	bool washolding;

	default{
		//$Category "Weapons/Hideous Destructor"
		//$Title "SigCow"
		//$Sprite "SMGNA0"

		+hdweapon.fitsinbackpack
		obituary "%o stepped in %k's cow pie.";
		weapon.selectionorder 24;
		weapon.slotnumber 4;
		weapon.slotpriority 2;
		weapon.kickback 30;//this does nothing to recoil :(
		weapon.bobrangex 0.3;
		weapon.bobrangey 0.6;
		weapon.bobspeed 2.5;
		scale 0.55;
		inventory.pickupmessage "You got the M-211 Sig-Cow!"; 
		hdweapon.barrelsize 26,0.5,1;
		hdweapon.refid "SCW";
		tag "M-211 Sig-Cow";
		inventory.icon "RF10A0";
	}
  
	override bool AddSpareWeapon(actor newowner){return AddSpareWeaponRegular(newowner);}
	override hdweapon GetSpareWeapon(actor newowner,bool reverse,bool doselect){return GetSpareWeaponRegular(newowner,reverse,doselect);}

	override double gunmass(){
		return 5+(weaponstatus[SMGS_MAG]<0)?-0.5:(weaponstatus[SMGS_MAG]*0.02);
	}

	override double weaponbulk(){
		int mg=weaponstatus[SMGS_MAG];
		if(mg<0)return 80;//-10 bulk less than the SMG
		else return (80+ENC_10MAG25_LOADED)+mg*(ENC_10_LOADED);
	}
	override void failedpickupunload(){
		failedpickupunloadmag(SMGS_MAG,"HD10mMag25");
	}

	override void DropOneAmmo(int amt){
		if(owner){
			amt=clamp(amt,1,10);
			if(owner.countinv("HD10mAmmo"))owner.A_DropInventory("HD10mAmmo",amt*25);
			else owner.A_DropInventory("HD10mMag25",amt);
		}
	}

double strength;
	action void A_StrengthTics(int mintics,int maxtics=-1){
		if(invoker.strength==1.)return;
		if(maxtics<0)maxtics=tics;
		int ttt=min(maxtics,int(tics/invoker.strength));
		A_SetTics(max(mintics,int(ttt)));
	}

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
				static const string zrkbs[]={"kill","k i l l","k I L L","K\n   I\n       L\n          L","Kill.","KILL","k i l l","Kill!","K  I  L  L","kill...","Kill...","k i l l . . .","      kill","  ... kill ...","kill,","kiiiilllll!!!","kill~","kill <3","kill uwu"};
				hdp.usegametip("\cr"..zrkbs[random(0,zrkbs.size()-1)]);
			}
		}
	}

	action void HD_SigCowStab(double dmg){
		let punchrange=96;// 1.5x etra range compared to fist attack
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
			return;
		}
		actor punchee=punchline.hitactor;


		//charge!
		dmg*=1.5;
		dmg += 1;
		//else dmg+=HDMath.TowardsEachOther(self,punchee)*3;

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
	    //increasing bleed chance, the medical rework nerfed bleed out
	    //since the wounds close up too fast now
	    //also, it should roll twice for each tip of the bayonet
	    //now that i think about it
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


	override void postbeginplay(){
		super.postbeginplay();
    weaponspecial=1337;
		if(weaponstatus[SMGS_AUTO]>0){
		switch(weaponstatus[SMGS_SWITCHTYPE]){
		case 1:
			weaponstatus[SMGS_AUTO]=0;
			break;
		case 2:
			weaponstatus[SMGS_AUTO]=1;
			break;
		case 3:
			weaponstatus[SMGS_AUTO]=2;
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
		return ((wep0&SMGF_REFLEXSIGHT)?"RF10":"RF10")
			..((GetSpareWeaponValue(SMGS_MAG,usespare)<0)?"B":"A").."0",1.;
	}

	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
			int nextmagloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("HD10mMag25")));
			if(nextmagloaded>=25){
				sb.drawimage("C10MA0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(3,3));
			}else if(nextmagloaded<1){
				sb.drawimage("C10MD0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextmagloaded?0.6:1.,scale:(3,3));
			}else sb.drawbar(
				"C10MA0","C10MC0",
				nextmagloaded,25,
				(-46,-3),-1,
				sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
			);
			sb.drawnum(hpl.countinv("HD10mMag25"),-43,-8,sb.DI_SCREEN_CENTER_BOTTOM);
		}

		if(weaponstatus[SMGS_SWITCHTYPE]!=1)sb.drawwepcounter(hdw.weaponstatus[SMGS_AUTO],
			-22,-10,"RBRSA3A7","STBURAUT","STFULAUT"
		);
		sb.drawwepnum(hdw.weaponstatus[SMGS_MAG],25);
		if(hdw.weaponstatus[SMGS_CHAMBER]==2)sb.drawrect(-19,-11,3,1);
	}


	override string gethelptext(){
		return
		WEPHELP_FIRESHOOT
  ..WEPHELP_ALTFIRE.." Bayonet Stab\n"
		..WEPHELP_RELOAD.."  Reload mag\n"
		..WEPHELP_USE.."+"..WEPHELP_RELOAD.."  Reload chamber\n"
		..WEPHELP_FIREMODE.."  Semi/Burst/Auto\n"
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
			sb.SetClipRect(
				-16+bob.x,-4+bob.y,32,16,
				sb.DI_SCREEN_CENTER
			);
			vector2 bobb=bob*3;
			bobb.y=clamp(bobb.y,-8,8);
			sb.drawimage(
				"smgfrntsit",(0,0)+bobb,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP
			);
			sb.SetClipRect(cx,cy,cw,ch);
			sb.drawimage(
				"scbksite",(0,0)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
				alpha:0.9
			);
		}


	override void SetReflexReticle(int which){weaponstatus[SMGS_DOT]=which;}
	action void A_CheckReflexSight(){
		if(
			invoker.weaponstatus[0]&SMGF_REFLEXSIGHT
		)Player.GetPSprite(PSP_WEAPON).sprite=getspriteindex("RBAYA0");
		else Player.GetPSprite(PSP_WEAPON).sprite=getspriteindex("RBAYA0");
	}

	states{
	select0:
		RBAY A 0 A_CheckDefaultReflexReticle(SMGS_DOT);
		RBAY A 0 A_CheckReflexSight();
		goto select0small;
	deselect0:
		RBAY A 0 A_CheckReflexSight();
		goto deselect0small;
		RBAY AB 0;
		SMSG AB 0;

	ready:
		RBAY A 0 A_CheckReflexSight();
		#### A 1{
			A_SetCrosshair(21);
			invoker.weaponstatus[SMGS_RATCHET]=0;
			A_WeaponReady(WRF_ALL);
		}
		goto readyend;

	user3:
		---- A 0 A_MagManager("HD10mMag25");
		goto ready;

    //you can now stab enemies with the rifle :D
	altfire:
		RBAY B 1;// A_DontFreedoomFrameB();
   RBAY B 1 A_JumpIf(pressingaltfire(),"altfire");//adds a windup bedore stabbing
		RBAY C 3 {A_StrengthTics(0,2); A_Recoil(-1);}// adds a short charge before stabbing
		RBAY D 0 A_Recoil(min(0,1.-invoker.strength));
		RBAY D 0 HD_SigCowStab(20);
		RBAY D 4 A_StrengthTics(3,10);
		RBAY C 2 A_StrengthTics(1,5);
		//#### B 0 A_DontFreedoomFrameB();
		RBAY A 3 A_StrengthTics(0,5);
		RBAY A 0 A_JumpIf(pressingaltfire(),"altfire");
		RBAY A 1 A_ReFire();
		goto ready;

	althold:
	//	goto altfire;
	hold:
		#### A 0{
			if(
				invoker.weaponstatus[SMGS_CHAMBER]==2  
      //live round chambered
				&&(
					invoker.weaponstatus[SMGS_AUTO]==2  
      //full auto
					||(
						invoker.weaponstatus[SMGS_AUTO]==1  
      //burst
						&&invoker.weaponstatus[SMGS_RATCHET]<=2
					)
				)
			)setweaponstate("fire2");
		}goto nope;
	user2:

	firemode:
    //do this when firemode is triggered
		---- A 1{
			int canaut=invoker.weaponstatus[SMGS_SWITCHTYPE];
    //canaut checks if selectfire set to Auto
			if(canaut==1){
				invoker.weaponstatus[SMGS_AUTO]=0;
    //if it is, set selectfire to Semi-Auto
				return;
			}
			int maxmode=(canaut>0)?(canaut-1):2;
  //maxmode checks that canaut doesn't go higher than 2
			int aut=invoker.weaponstatus[SMGS_AUTO];
  //aut checks the current selectfire mode
			if(aut>=maxmode)invoker.weaponstatus[SMGS_AUTO]=0;
  //if aut is greater than canaut, force Semi-Auto
			else if(aut<0)invoker.weaponstatus[SMGS_AUTO]=0;
  //but, if aut is somehow less than 0, also force Semi-Auto
			else if(canaut>0)invoker.weaponstatus[SMGS_AUTO]=maxmode;
  //but, if aut is greater than 0, 
  //aut equals maxmode, force Auto
			else invoker.weaponstatus[SMGS_AUTO]++;
  //finally set selectfire to Burst 
  //once all of these checks failed
		}goto nope;

	fire:
		#### A 0;
  //don't mess with this lol

	fire2:
		#### B 0{
			if(invoker.weaponstatus[SMGS_CHAMBER]==2)A_GunFlash();
   //check if a round is chambered, then jump to state "flash"
			else setweaponstate("chamber_manual");
		}
  //jump to state "chamber_manual" if no round is found

		#### A 1;

		#### A 0{
			if(invoker.weaponstatus[SMGS_CHAMBER]==1){
				A_EjectCasing("HDSpent10mm",-frandom(79,81),(frandom(7,7.5),0,0),(13,0,0));
  //if a round has been fired, eject a spent casing
				invoker.weaponstatus[SMGS_CHAMBER]=0;
			}
  //chamber is empty
			if(invoker.weaponstatus[SMGS_MAG]>0){
  //do this if chamber is empty
				invoker.weaponstatus[SMGS_MAG]--;
  //remove one round from the magazine
				invoker.weaponstatus[SMGS_CHAMBER]=2;
  //chamber the round
			}
			if(invoker.weaponstatus[SMGS_AUTO]==2)A_SetTics(1);
		}
  #### A 2; //going back to 2 tics, three is too slow :(
		#### A 0 A_ReFire();
  //fire another round if selectfire is set to Auto
		goto ready;
  //jump to state "ready"


	flash:
		#### B 0{
			let bbb=HDBulletActor.FireBullet(self,"HDB_10",speedfactor:1.1);
  //fire a 10mm bullet
			if(
				frandom(16,ceilingz-floorz)<bbb.speed*0.1
			)A_AlertMonsters(200);
  //loud bang make imp ANGRY >:[

			A_ZoomRecoil(0.995);
  //do the weird zoomin effect to simulate recoil
			A_StartSound("weapons/sigcow",CHAN_WEAPON,volume:1);
  //play gunshot sfx
			invoker.weaponstatus[SMGS_RATCHET]++;
			invoker.weaponstatus[SMGS_CHAMBER]=1;
  //empty casing in the chamber
		}
		SCWF A 1 bright{
			HDFlashAlpha(-200);
			A_Light1();
  //display muzzle flash
		}
		TNT1 A 0 A_MuzzleClimb(
				-frandom(0.1,0.1),-frandom(0,0.1),
				-0.2,-frandom(0.3,0.4),
				-frandom(0.4,1.4),-frandom(1.3,2.6)
    );
//it seems the way this works is, 
//it progresses to higher values
//the more consecutive shots are made,
//getting worse and worse until it reaches
//the last set of values
//in other wprds, "short, controlled bursts"


  //using zm66's MuzzleClimb code
  //A_muzzleClimb moves the camera around


/* original smg MuzzleClimb, wimpy

TNT1 A 0 A_MuzzleClimb(-frandom(0.2,0.24),-frandom(0.3,0.36),-frandom(0.2,0.24),-frandom(0.3,0.36));

*/

		goto lightdone;


	unloadchamber:
		#### B 4 A_JumpIf(invoker.weaponstatus[SMGS_CHAMBER]<1,"nope");
  //checks if there's even a round to eject
  //if not, do nothing
		#### B 10{
			class<actor>which=invoker.weaponstatus[SMGS_CHAMBER]>1?"HD10mAmmo":"HDSpent10mm";
			invoker.weaponstatus[SMGS_CHAMBER]=0;
			A_SpawnItemEx(which,
				cos(pitch)*10,0,height*0.82-sin(pitch)*10,
				vel.x,vel.y,vel.z,
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
			);
    //this checks whether to eject 
    //a casing or an unspent round
		}goto readyend;

	loadchamber:
		---- A 0 A_JumpIf(invoker.weaponstatus[SMGS_CHAMBER]>0,"nope");
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
				invoker.weaponstatus[SMGS_CHAMBER]=2;
				A_StartSound("weapons/smgchamber",8);
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
			invoker.weaponstatus[0]|=SMGF_JUSTUNLOAD;
			if(
				invoker.weaponstatus[SMGS_MAG]>=0
			)setweaponstate("unmag");
			else if(invoker.weaponstatus[SMGS_CHAMBER]>0)setweaponstate("unloadchamber");
		}goto nope;
	reload:
		#### A 0{
			invoker.weaponstatus[0]&=~SMGF_JUSTUNLOAD;
			bool nomags=HDMagAmmo.NothingLoaded(self,"HD10mMag25");
			if(invoker.weaponstatus[SMGS_MAG]>=25)setweaponstate("nope");
			else if(
				invoker.weaponstatus[SMGS_MAG]<1
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
		#### B 2 offset(20,46) A_StartSound("weapons/smgmagclick",8);
		#### B 4 offset(30,52){
			A_MuzzleClimb(0.3,0.4);
			A_StartSound("weapons/smgmagmove",8,CHANF_OVERLAP);
		}
		#### B 0{
			int magamt=invoker.weaponstatus[SMGS_MAG];
			if(magamt<0){
				setweaponstate("magout");
				return;
			}
			invoker.weaponstatus[SMGS_MAG]=-1;
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
			if(invoker.weaponstatus[0]&SMGF_JUSTUNLOAD)setweaponstate("reloadend");
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
				invoker.weaponstatus[SMGS_MAG]=mmm.TakeMag(true);
				A_StartSound("weapons/smgmagclick",8,CHANF_OVERLAP);
			}
			if(
				invoker.weaponstatus[SMGS_MAG]<1
				||invoker.weaponstatus[SMGS_CHAMBER]>0
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
			invoker.weaponstatus[SMGS_MAG]<1
			||invoker.weaponstatus[SMGS_CHAMBER]==2
		,"nope");
		#### B 2 offset(3,32){
			A_WeaponBusy();
			invoker.weaponstatus[SMGS_MAG]--;
			invoker.weaponstatus[SMGS_CHAMBER]=2;
		}
		#### B 3 offset(5,35) A_StartSound("weapons/smgchamber",8,CHANF_OVERLAP);
		#### A 1 offset(3,32);
		#### A 1 offset(2,31);
		goto nope;


	spawn:
		TNT1 A 1;
		RF10 A -1{
			if(invoker.weaponstatus[SMGS_MAG]<0)frame=1;
			if(
				invoker.weaponstatus[0]&SMGF_REFLEXSIGHT
			)invoker.sprite=getspriteindex("RF10A0");
		}
		RF10 # -1;
		stop;
	}
	override void initializewepstats(bool idfa){
		weaponstatus[SMGS_MAG]=25;
		weaponstatus[SMGS_CHAMBER]=2;
	}
	override void loadoutconfigure(string input){
		int firemode=getloadoutvar(input,"firemode",1);
		if(firemode>=0)weaponstatus[SMGS_AUTO]=clamp(firemode,0,2);

		int xhdot=getloadoutvar(input,"dot",3);
		int reflexsight=getloadoutvar(input,"reflexsight",1);
		if(
			!reflexsight
			&&xhdot<0
		)weaponstatus[0]&=~SMGF_REFLEXSIGHT;
		else{
			weaponstatus[0]|=SMGF_REFLEXSIGHT;
			if(xhdot>=0)weaponstatus[SMGS_DOT]=xhdot;
		}

		int fireswitch=getloadoutvar(input,"fireswitch",1);

  if(fireswitch<0)weaponstatus[SMGS_SWITCHTYPE]=1;
    //standard issue is semi-only, just like in the books
		if(fireswitch>3)weaponstatus[SMGS_SWITCHTYPE]=0;
		else if(fireswitch>0)weaponstatus[SMGS_SWITCHTYPE]=clamp(fireswitch,0,3);
	}
}
enum smgstatus{
	SMGF_JUSTUNLOAD=1,
	SMGF_REFLEXSIGHT=2,

	SMGN_SEMIONLY=1,
	SMGN_BURSTONLY=2,
	SMGN_FULLONLY=3,

	SMGS_FLAGS=0,
	SMGS_MAG=1,
	SMGS_CHAMBER=2, //0 empty, 1 spent, 2 loaded
	SMGS_AUTO=3, //0 semi, 1 burst, 2 auto
	SMGS_RATCHET=4,
	SMGS_SWITCHTYPE=5,
	SMGS_DOT=6,
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
			
			semi.weaponstatus[SMGS_SWITCHTYPE]=1;
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
			
			semiburst.weaponstatus[SMGS_SWITCHTYPE]=2;
		}stop;
	}
}

class SigCowRandomSpawn:IdleDummy{
	override void postbeginplay(){
		super.postbeginplay();
		A_SpawnItemEx("HD10mMag25",flags:SXF_NOCHECKPOSITION);
		if(random(0,2))A_SpawnItemEx("HDFragGrenadeAmmo",-3,-3,flags:SXF_NOCHECKPOSITION);
		if(random(0,9)){
    A_SpawnItemEx("TenMilAutoReloader",5,5,flags:SXF_NOCHECKPOSITION);
			A_SpawnItemEx("HD10mMag25",3,3,flags:SXF_NOCHECKPOSITION);
			A_SpawnItemEx("HDSigCowSelectfire",1,1,flags:SXF_NOCHECKPOSITION);
		}else if(random(0,4)){
			A_SpawnItemEx("HD10mMag25",3,3,flags:SXF_NOCHECKPOSITION);
			A_SpawnItemEx("HDSigCowSemiBurst",1,1,flags:SXF_NOCHECKPOSITION);
		}else A_SpawnItemEx("HDSigCowSemi",1,1,flags:SXF_NOCHECKPOSITION);
		destroy();
	}
}
