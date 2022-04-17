// ------------------------------------------------------------
// Vanilla Thunder Buster
// ------------------------------------------------------------
class PlasmaFoof:HDFireball{
	default{
		height 6;//-6
  radius 6;//-6, to fit through smaller gaps
  speed 32;
		gravity 0;
		decal "BulletScratch";
  damagetype "cold";
		damagefunction(random(20,40));
		//hdfireball.firefatigue int(HDCONST_MAXFIREFATIGUE*0.25);
	}
	void ZapPlasma(){
		roll=frandom(0,360);
		A_StartSound("misc/arczap",CHAN_BODY);
  HDMobAI.Frighten(self,512);//oh no, a ball of sparkly hot death, run away !!!
		blockthingsiterator it=blockthingsiterator.create(self,72);
		actor tb=target;
		actor zit=null;
		bool didzap=false;
		while(it.next()){
			if(
				it.thing.bshootable
				&&abs(it.thing.pos.z-pos.z)<72
			){
				zit=it.thing;
				if(
					zit.health>0
					&&checksight(it.thing)
					&&(
						!tb
						||zit==tb.target
/*
						||!(zit is "Trilobite")
*/
					)
				){
					A_Face(zit,0,0,flags:FAF_MIDDLE);
					ZapArc(self,zit,ARC2_RANDOMDEST);
      zit.damagemobj(self,tb,random(0,2),"thermal");
					zit.damagemobj(self,tb,random(0,5),"electrical");//less spark damage
					didzap=true;
					break;
				}
			}
		}
		if(!zit||zit==tb){pitch=frandom(-90,90);angle=frandom(0,360);}
		if(!didzap)ZapArc(self,null,ARC2_SILENT,radius:32,height:32,pvel:vel);

		A_FaceTracer(4,4);

		if(
			bmissile
			&&tracer
		){

			vector3 vvv=tracer.pos-pos;
			if(vvv.x||vvv.y||vvv.z){
				vvv*=1./max(abs(vvv.x),abs(vvv.y),abs(vvv.z));
				//vel+=vvv;

			}
		}
		if(pos.z-floorz<24)vel.z+=0.0;
	}
	states{
	spawn:
  PLSS AB 2;
  zap:
		PLSS A 0 ZapPlasma();
		PLSS AB 2 light("PLAZMABX1");//no corkscrews
		loop;
	death:
		PLSS A 0 A_SprayDecal("CacoScorch",radius*1.5);
		PLSS A 0 A_StartSound("weapons/plasmax",5);
   PLSS A 0 A_HDBlast(
			immolateradius:32,
    immolateamount:random(8,15),
    immolatechance:50,
			source:target
		);
		PLSE ABCDE 3 light("BAKAPOST1") ZapPlasma();
	death2:
		PLSE E 0 ZapPlasma();
		PLSE E 3 light("PLAZMABX2") A_FadeOut(0.3);
		loop;
	}
}

class PlasmaBuster:HDCellWeapon{
	default{
		//$Category "Weapons/Hideous Destructor"
		//$Title "Plasma Buster"
		//$Sprite "PLASA0"

		+hdweapon.fitsinbackpack
		weapon.selectionorder 70;
		weapon.slotnumber 6;
		weapon.slotpriority 3;
		weapon.ammouse 1;
		scale 0.6;
		inventory.pickupmessage "You got the DM-93 plasma launcher!";
		obituary "%o was vaporized by %k's plasma launcher.";
		hdweapon.barrelsize 35,1.6,3;
		hdweapon.refid "d93";
		tag "dm-93 plasma launcher";

		hdweapon.loadoutcodes "
			\cualt - 0/1, whether to start in spray fire mode";
	}
	override bool AddSpareWeapon(actor newowner){return AddSpareWeaponRegular(newowner);}
	override hdweapon GetSpareWeapon(actor newowner,bool reverse,bool doselect){return GetSpareWeaponRegular(newowner,reverse,doselect);}

	override void tick(){
		super.tick();
		drainheat(TBS_HEAT,12);
	}

	override double gunmass(){
		return 10+(weaponstatus[TBS_BATTERY]<0?0:2);
	}

	override double weaponbulk(){
		return 145+(weaponstatus[1]>=0?ENC_BATTERY_LOADED:0);
	}

	override string,double getpickupsprite(){return "PLASA0",1.;}

/*
	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
			sb.drawbattery(-54,-4,sb.DI_SCREEN_CENTER_BOTTOM,reloadorder:true);
			sb.drawnum(hpl.countinv("HDBattery"),-46,-8,sb.DI_SCREEN_CENTER_BOTTOM);
		}
		if(hdw.weaponstatus[0]&TBF_ALT){
			sb.drawimage(
				"STBURAUT",(-28,-10),
				sb.DI_SCREEN_CENTER_BOTTOM|sb.DI_TRANSLATABLE|sb.DI_ITEM_RIGHT
			);
			sb.drawnum(int(2000/HDCONST_ONEMETRE),-16,-17,sb.DI_SCREEN_CENTER_BOTTOM,font.CR_GRAY);
		}else sb.drawnum(hdw.weaponstatus[TBS_MAXRANGEDISPLAY],-16,-17,sb.DI_SCREEN_CENTER_BOTTOM,font.CR_GRAY);
		int bat=hdw.weaponstatus[TBS_BATTERY];
		if(bat>0)sb.drawwepnum(bat,20);
		else if(!bat)sb.drawstring(
			sb.mamountfont,"00000",
			(-16,-9),sb.DI_TEXT_ALIGN_RIGHT|sb.DI_TRANSLATABLE|sb.DI_SCREEN_CENTER_BOTTOM,
			Font.CR_DARKGRAY
		);
	}
*/

override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
			sb.drawbattery(-54,-4,sb.DI_SCREEN_CENTER_BOTTOM,reloadorder:true);
			sb.drawnum(hpl.countinv("HDBattery"),-46,-8,sb.DI_SCREEN_CENTER_BOTTOM);
		}
		if(!hdw.weaponstatus[1])sb.drawstring(
			sb.mamountfont,"00000",(-16,-9),sb.DI_TEXT_ALIGN_RIGHT|
			sb.DI_TRANSLATABLE|sb.DI_SCREEN_CENTER_BOTTOM,
			Font.CR_DARKGRAY
		);else if(hdw.weaponstatus[1]>0)sb.drawwepnum(hdw.weaponstatus[1],20);
	}

	override string gethelptext(){
		return
		WEPHELP_FIRE.."  Auto-fire\n"
  ..WEPHELP_ALTFIRE.."  Burst-fire\n"
		..WEPHELP_RELOADRELOAD
		..WEPHELP_UNLOADUNLOAD
		;
	}
	int rangefinder;

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
//		bobb.y=clamp(bobb.y,-8,8);
		sb.drawimage(
			"tbfrntsit",(0,0)+bobb,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP
		);
		sb.SetClipRect(cx,cy,cw,ch);
		sb.drawimage(
			"tbbaksit",(0,0)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			alpha:0.9
		);

		if(scopeview){
			bool alt=hdw.weaponstatus[0]&TBF_ALT;
			int scaledyoffset=36;

			bool lz=HDMath.Pre460();
			name ctex=lz?"HDXHCAM1":"HDXCAM_TB";

			texman.setcameratotexture(hpc,ctex,3);
			sb.drawimage(
				ctex,(0,scaledyoffset)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_CENTER,
				alpha:alt?(hpl.flip?0.7:0.8):1.,scale:(lz?1:(1/1.2),1)
			);
			let tb=PlasmaBuster(hdw);
			sb.drawnum(min(tb.rangefinder,999),
				24+bob.x,12+bob.y,sb.DI_SCREEN_CENTER,
				(
					tb.rangefinder>=10
					&&tb.rangefinder<hdw.weaponstatus[TBS_MAXRANGEDISPLAY]
				)?Font.CR_GRAY:Font.CR_RED
				,0.4
			);
			sb.drawnum(hdw.weaponstatus[TBS_MAXRANGEDISPLAY],
				24+bob.x,20+bob.y,sb.DI_SCREEN_CENTER,Font.CR_WHITE,0.4
			);
			if(alt)sb.drawnum(int(2000/HDCONST_ONEMETRE),
				23+bob.x,19+bob.y,sb.DI_SCREEN_CENTER,Font.CR_BLACK,1.
			);
			sb.drawimage(
				"tbwindow",(0,scaledyoffset)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_CENTER,
				scale:(1,1)
			);
			bobb*=3;
			double dotoff=max(abs(bobb.x),abs(bobb.y));
			if(dotoff<40)sb.drawimage(
				"redpxl",(0,scaledyoffset)+bobb,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
				alpha:(alt?0.4:0.9)*(1.-dotoff*0.04),scale:alt?(hpl.flip?(3,3):(1,1)):(2,2)
			);
		}
	}

	override void failedpickupunload(){
		failedpickupunloadmag(TBS_BATTERY,"HDBattery");
	}

	override void consolidate(){
		CheckBFGCharge(TBS_BATTERY);
	}


	static void PlasmaZap(
		actor caller,
		double zoffset=32,
		bool alt=false,
		int battery=20
	){
		//determine angle
		double shootangle=caller.angle;
		double shootpitch=caller.pitch;
		let hdp=hdplayerpawn(caller);
		if(hdp&&hdp.scopecamera){
			shootangle=hdp.scopecamera.angle;
			shootpitch=hdp.scopecamera.pitch;
		}
		if(alt){
			shootangle+=frandom(-1.2,1.2);
			shootpitch+=frandom(-1.3,1.1);
		}

		//create the line
		flinetracedata tlt;
		caller.linetrace(
			shootangle,
			8000+200*battery,
			shootpitch,
			flags:TRF_NOSKY,
			offsetz:zoffset,
			data:tlt
		);
		if(
			tlt.hittype==Trace_HitNone
			||(
				tlt.hitline&&(
					tlt.hitline.special==Line_Horizon
					||(
						tlt.linepart==2
						&&tlt.hitsector.gettexture(0)==skyflatnum
					)||(
						tlt.linepart==1
						&&tlt.hitline.sidedef[1]
						&&hdmath.oppositesector(tlt.hitline,tlt.hitsector).gettexture(0)==skyflatnum
					)
				)
			)
		)return;

		//alt does a totally different thing
		if(alt){
			if(tlt.hittype==Trace_HitNone||tlt.distance>2000)return;
			actor bbb=spawn("BeamSpotFlash",tlt.hitlocation-tlt.hitdir,ALLOW_REPLACE);
			if(!random(0,3))(lingeringthunder.zap(bbb,bbb,caller,40,true));
			beamspotflash(bbb).impactdistance=tlt.distance-16*battery;
			bbb.angle=caller.angle;
			bbb.A_SprayDecal("Scorch",12);
			bbb.pitch=caller.pitch;
			bbb.target=caller;
			bbb.tracer=tlt.hitactor; //damage inflicted on the puff's end
			return;
		}

		int basedmg=int(max(0,20-tlt.distance*(1./50.)));
		int dmgflags=caller&&caller.player?DMG_PLAYERATTACK:0; //don't know why the player damagemobj doesn't work

		//wet actor
		if(tlt.hitactor){
			actor hitactor=tlt.hitactor;
			if(hitactor.bloodtype=="ShieldNotBlood"){
				hitactor.damagemobj(null,caller,random(1,(battery<<2)),"Balefire",dmgflags);
			}else if(
				hitactor.bnodamage
				||(hitactor.bnoblood&&!random(0,3))
				||hitactor.bloodtype=="NotQuiteBloodSplat"
				||hitactor.countinv("ImmunityToFire")
				||!random(0,7)
				||HDWoundFixer.CheckCovered(hitactor,true)
			){
				//dry actor - ping damage and continue
				if(!random(0,5))(lingeringthunder.zap(hitactor,hitactor,caller,40,true));
				hdf.give(hitactor,"Heat",(basedmg>>1));
				hitactor.damagemobj(null,caller,1,"electrical",dmgflags);
			}else{
				//wet actor
				if(!random(0,7))(lingeringthunder.zap(hitactor,hitactor,caller,(basedmg<<1),true));
				hdf.give(hitactor,"Heat",(basedmg<<1));
				hitactor.damagemobj(null,caller,basedmg,"electrical",dmgflags);
				actor sss=spawn("HDGunsmoke",tlt.hitlocation,ALLOW_REPLACE);
				sss.vel=(0,0,1)-tlt.hitdir;
				return;
			}
		}
		//where where the magic happens happens
		actor bbb=spawn("BeamSpot",tlt.hitlocation-tlt.hitdir,ALLOW_REPLACE);
		bbb.target=caller;
		bbb.stamina=basedmg;
		bbb.angle=caller.angle;
		bbb.pitch=caller.pitch;
	}
	action void A_PlasmaZap(){
		if(invoker.weaponstatus[TBS_HEAT]>20)return;
		int battery=invoker.weaponstatus[TBS_BATTERY];
		if(battery<1){
			setweaponstate("nope");
			return;
		}

		//preliminary effects
		A_ZoomRecoil(0.99);
		A_StartSound("weapons/plasidle");
		if(countinv("IsMoving")>9)A_MuzzleClimb(frandom(-0.8,0.8),frandom(-0.8,0.8));

		//the actual call
		PlasmaBuster.PlasmaZap(
			self,
			HDWeapon.GetShootOffset(self,invoker.barrellength,invoker.barrellength-HDCONST_SHOULDERTORADIUS),
			invoker.weaponstatus[0]&TBF_ALT,
			battery
		);

		//aftereffects
		if(invoker.weaponstatus[0]&TBF_ALT){
			if(!random(0,4))invoker.weaponstatus[TBS_BATTERY]--;
			A_MuzzleClimb(
				frandom(0.05,0.2),frandom(-0.2,-0.4),
				frandom(0.1,0.3),frandom(-0.2,-0.6),
				frandom(0.04,0.12),frandom(-0.1,-0.3),
				frandom(0.01,0.03),frandom(-0.1,-0.2)
			);
			invoker.weaponstatus[TBS_HEAT]+=6;
		}else if(!random(0,6))invoker.weaponstatus[TBS_BATTERY]--;
		invoker.weaponstatus[TBS_HEAT]+=random(0,3);

		//update range thingy
		invoker.weaponstatus[TBS_MAXRANGEDISPLAY]=int(
			(battery>0?battery*200+8000:0)/HDCONST_ONEMETRE
		);
	}

action void FirePlasmaBall(){
  A_SpawnProjectile("PlasmaFoof",(11+hdplayerpawn(self).height/2)*hdplayerpawn(self).heightmult,0, frandom(-1,1), CMF_AIMDIRECTION, pitch+frandom(-2,1.8));
  A_AlertMonsters(400);
  }

	states{
	ready:
		PLSG A 1{
			A_CheckIdSprite("THBGA0","PLSGA0");
			invoker.weaponstatus[TBS_WARMUP]=0;

			//update rangefinder
			if(
				invoker.weaponstatus[TBS_BATTERY]>0
				&&!(level.time&(1|2|4))
				&&max(abs(vel.x),abs(vel.y),abs(vel.z))<2
				&&(
					!player.cmd.pitch
					&&!player.cmd.yaw
				)
			){
				flinetracedata frt;
				linetrace(
					angle,512*HDCONST_ONEMETRE,pitch,flags:TRF_NOSKY,
					offsetz:height-6,
					data:frt
				);
				invoker.rangefinder=int(frt.distance*(1./HDCONST_ONEMETRE));
			}
			A_WeaponReady(WRF_ALL&~WRF_ALLOWUSER1);
		}goto readyend;
		PLSG AB 0;
		PLSF AB 0;
		THBG AB 0;
		THBF AB 0;
	fire:
		#### A 3 offset(0,35);
	hold:
		#### A 0 A_JumpIf(invoker.weaponstatus[TBS_BATTERY]>0,"shoot");
		goto nope;
	shoot:

/*

		#### A 1 offset(1,33) A_ThunderZap();//haha, teebee goes zap zap .')

*/
  #### A 0 A_StartSound("weapons/plasmaf");//zappy noises
  #### A 1 bright FirePlasmaBall();
//this makes zappy balls fly out

  #### A 0 {
		//aftereffects
		if(invoker.weaponstatus[0]&TBF_ALT){
			if(!random(0,5))invoker.weaponstatus[TBS_BATTERY]--;
			invoker.weaponstatus[TBS_HEAT]+=6;
		}else if(!random(0,9))invoker.weaponstatus[TBS_BATTERY]--;
		invoker.weaponstatus[TBS_HEAT]+=random(0,3);
}
//this uses up battery charge

		#### A 1 offset(0,34) A_WeaponReady(WRF_NONE);
		#### A 1 offset(-1,33) A_WeaponReady(WRF_NONE);
		#### A 0{
			if(invoker.weaponstatus[TBS_BATTERY]<1){
				A_StartSound("weapons/plasmas",CHAN_WEAPON);
				A_GunFlash();
				setweaponstate("nope");
			}else{
				A_Refire();
			}
		}
		#### AAA 4{
			A_WeaponReady(WRF_NOFIRE);
			A_GunFlash();
		}goto ready;
	flash:
		THBF AB 0;
		#### A 0 A_CheckIdSprite("THBFA0","PLSFA0",PSP_FLASH);
		#### A 1 bright{
			HDFlashAlpha(64);
			A_Light2();
		}
		#### BA 1 bright;
		#### B 1 bright A_Light1();
		#### AB 1 bright;
		#### B 0 bright A_Light0();
		stop;
	altfire://spread shot
		#### A 3 offset(0,35);
	althold:
		#### A 0 A_JumpIf(invoker.weaponstatus[TBS_BATTERY]>0,"altshoot");
		goto nope;
	altshoot:

/*

		#### A 1 offset(1,33) A_ThunderZap();//haha, teebee goes zap zap .')

*/
  #### A 0 A_StartSound("weapons/plasmaf");//zappy noises
  #### A 1 bright FirePlasmaBall();
  #### A 0 A_StartSound("weapons/plasmaf");//zappy noises
  #### A 1 bright FirePlasmaBall();
  #### A 0 A_StartSound("weapons/plasmaf");//zappy noises
  #### A 1 bright FirePlasmaBall();
  #### A 0 A_StartSound("weapons/plasmaf");//zappy noises
  #### A 1 bright FirePlasmaBall();
  #### A 0 A_StartSound("weapons/plasmaf");//zappy noises
  #### A 1 bright FirePlasmaBall();
  #### A 0 {
		//aftereffects
		if(invoker.weaponstatus[0]&TBF_ALT){
			if(!random(0,2))invoker.weaponstatus[TBS_BATTERY]--;
			invoker.weaponstatus[TBS_HEAT]+=30;
		}else if(!random(0,4))invoker.weaponstatus[TBS_BATTERY]--;
		invoker.weaponstatus[TBS_HEAT]+=random(24,30);
}
//this uses up more battery charge

		#### A 1 offset(0,34) A_WeaponReady(WRF_NONE);
		#### A 1 offset(-1,33) A_WeaponReady(WRF_NONE);
  	#### BBB 4{
			A_WeaponReady(WRF_NOFIRE);
			//A_GunFlash();
		}
		#### A 0{
			if(invoker.weaponstatus[TBS_BATTERY]<1){
				A_StartSound("weapons/plasmas",CHAN_WEAPON);
				A_GunFlash();
				setweaponstate("nope");
			}else{
				setweaponstate("nope");
			}
		}
	goto nope;

	firemode:
  goto nope;
  /*
		#### B 1 offset(1,32) A_WeaponBusy();
		#### B 2 offset(2,32);
		#### B 1 offset(1,33) A_StartSound("weapons/plasswitch",8);
		#### B 2 offset(0,34);
		#### B 3 offset(-1,35);
		#### B 4 offset(-1,36);
		#### B 3 offset(-1,35);
		#### B 2 offset(0,34){
			invoker.weaponstatus[0]^=TBF_ALT;
			A_SetHelpText();
		}
		#### A 1;
		#### A 1 offset(0,34);
		#### A 1 offset(1,33);
		goto nope;
*/
	select0:
		PLSG A 0{
			invoker.weaponstatus[TBS_MAXRANGEDISPLAY]=int(
				(8000+200*invoker.weaponstatus[TBS_BATTERY])/HDCONST_ONEMETRE
			);
			A_CheckIdSprite("THBGA0","PLSGA0");
		}goto select0big;
	deselect0:
		PLSG A 0 A_CheckIdSprite("THBGA0","PLSGA0");
		#### A 0 A_Light0();
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
		#### A 2 offset(0,40) A_StartSound("weapons/plasopen",8);
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
				HDMagAmmo.SpawnMag(self,"HDBattery",bat);
			}
		}goto magout;

	pocketmag:
		---- A 0{
			int bat=invoker.weaponstatus[TBS_BATTERY];
			invoker.weaponstatus[TBS_BATTERY]=-1;
			if(bat>=0){
				HDMagAmmo.GiveMag(self,"HDBattery",bat);
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
				invoker.weaponstatus[TBS_BATTERY]<20
				&&countinv("HDBattery")
			)setweaponstate("unmag");
		}goto nope;

	loadmag:
		#### A 12 offset(0,42);
		#### A 2 offset(0,43){if(health>39)A_SetTics(0);}
		#### AA 2 offset(0,42);
		#### A 2 offset(0,44) A_StartSound("weapons/pocket",9);
		#### A 4 offset(0,43) A_StartSound("weapons/pocket",9);
		#### A 6 offset(0,42);
		#### A 8 offset(0,38)A_StartSound("weapons/plasload",8);
		#### A 4 offset(0,37){if(health>39)A_SetTics(0);}
		#### A 4 offset(0,36)A_StartSound("weapons/plasclose",8);

		#### A 0{
			let mmm=HDMagAmmo(findinventory("HDBattery"));
			if(mmm)invoker.weaponstatus[TBS_BATTERY]=mmm.TakeMag(true);
		}goto reload3;

	reload3:
		#### A 6 offset(0,40){
			invoker.weaponstatus[TBS_MAXRANGEDISPLAY]=int(
				(8000+200*invoker.weaponstatus[TBS_BATTERY])/HDCONST_ONEMETRE
			);
			A_StartSound("weapons/plasclose2",8);
		}
		#### A 2 offset(0,36);
		#### A 4 offset(0,33);
		goto nope;

	user3:
		#### A 0 A_MagManager("HDBattery");
		goto ready;

	spawn:
		PLAS A -1;
		stop;
	}
	override void initializewepstats(bool idfa){
		weaponstatus[TBS_BATTERY]=20;
	}
	override void loadoutconfigure(string input){
		int fm=getloadoutvar(input,"alt",1);
		if(!fm)weaponstatus[0]&=~TBF_ALT;
		else if(fm>0)weaponstatus[0]|=TBF_ALT;
	}
}
