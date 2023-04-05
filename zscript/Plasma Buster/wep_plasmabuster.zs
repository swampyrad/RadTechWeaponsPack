// ------------------------------------------------------------
// Vanilla Thunder Buster
// ------------------------------------------------------------

//dummy bullet, used to transfer weapon pitch to plasma
class HDB_Plasma:HDBulletActor{
    default{
        speed 32;
    }
	states{
	spawn:
		TNT1 A 0;
	death:
	    TNT1 A 0 A_SpawnItemEx(
	                "PlasmaFoof",
	                0, 0, 0,
                    invoker.vel.x,
                    invoker.vel.y,
                    invoker.vel.z,
                    invoker.angle,
	                SXF_TRANSFERPOINTERS);
		stop;
	}
}


class PlasmaFoof:HDFireball{
	default{
		height 6;//-6
		radius 6;//-6, to fit through smaller gaps
	//	speed 32;
		gravity 0;
		decal "BulletScratch";
		damagetype "cold";
		damagefunction(random(20,30));//does an average of 25 damage
		//hdfireball.firefatigue int(HDCONST_MAXFIREFATIGUE*0.25);
	}
	void ZapPlasma(){
		roll=frandom(0,360);
		A_StartSound("weapons/pbust_arczap",CHAN_BODY);
                HDMobAI.Frighten(self,512);//oh no, a ball of sparkly hot death, run away !!!
		blockthingsiterator it=blockthingsiterator.create(self,32);
		actor tb=target;
		actor zit=null;
		bool didzap=false;
		while(it.next()){
			if(
				it.thing.bshootable
				&&abs(it.thing.pos.z-pos.z)<32//testing wider zap range
			){
				zit=it.thing;
				if(
					zit.health>0
					&&checksight(it.thing)
					&&(
						!tb
						||zit==tb.target
					)
				){
					A_Face(zit,0,0,flags:FAF_MIDDLE);
					ZapArc(self,zit,ARC2_RANDOMDEST);
					zit.damagemobj(self,tb,random(0,1),"electrical");//less spark damage
					didzap=true;
					break;
				}
			}
		}
		if(!zit||zit==tb){pitch=frandom(-90,90);angle=frandom(0,360);}
		if(!didzap)ZapArc(self,null,ARC2_SILENT,radius:16,height:16,pvel:vel);//changes size of zap arcs

		A_FaceTracer(16,16);

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
        PLSS A 0 A_AlertMonsters(400);
        PLSS ABAB 2;//extend pre-zap stage by 4 tics
    zap:
		PLSS A 0 ZapPlasma();
		PLSS AB 2 light("PLAZMABX1");//no corkscrews
		PLSS A 0 A_JumpIf(vel.x == 0 || vel.y == 0 || vel.z == 0, "death");//plasma sometimes gets stuck in walls if fired too close
		loop;
	death:
		PLSS A 0 A_SprayDecal("CacoScorch",radius*1.5);
		PLSS A 0 A_StartSound("weapons/pbust_x",5);
        PLSS A 0 A_AlertMonsters(400);
        PLSS A 0 A_HDBlast(
			immolateradius:32,
            immolateamount:random(8,15),
            immolatechance:50,
			source:target
		);
		PLSE ABCDE 3 light("BAKAPOST1") ZapPlasma();
	death2:
		PLSE E 0 ZapPlasma();
		PLSE E 2 light("PLAZMABX2") A_FadeOut(0.3);
		PLSE E 0 {if(!random(0,2))ArcZap(self,radius*16,16,true);}
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
		obituary "$OB_DM93";
		hdweapon.barrelsize 35,1.6,3;
		hdweapon.refid "d93";
		tag "$TAG_DM93PLASMA";
	}
	override bool AddSpareWeapon(actor newowner){return AddSpareWeaponRegular(newowner);}
	override hdweapon GetSpareWeapon(actor newowner,bool reverse,bool doselect){return GetSpareWeaponRegular(newowner,reverse,doselect);}

	override void tick(){
		super.tick();
		drainheat(TBS_HEAT,12);
	}

	override string pickupmessage(){
		return Stringtable.Localize("$PICKUP_PLASMABUSTER");
	}

	override double gunmass(){
		return 10+(weaponstatus[TBS_BATTERY]<0?0:2);
	}

	override double weaponbulk(){
		return 145+(weaponstatus[1]>=0?ENC_BATTERY_LOADED:0);
	}

  override string,double getpickupsprite(){return "PLASA0",1.;}


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
//		bobb.y=clamp(bobb.y,-8,8);
		sb.drawimage(
			"tbfrntsit",(0,0)+bobb,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP
		);
		sb.SetClipRect(cx,cy,cw,ch);
		sb.drawimage(
			"tbbaksit",(0,0)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			alpha:0.9
		);
	}


	override void failedpickupunload(){
		failedpickupunloadmag(TBS_BATTERY,"HDBattery");
	}

	override void consolidate(){
		CheckBFGCharge(TBS_BATTERY);
	}


	states{
	ready:
		PLSG A 1{
			A_CheckIdSprite("THBGA0","PLSGA0");
			invoker.weaponstatus[TBS_WARMUP]=0;

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
  #### A 0 {A_GunFlash();
            A_StartSound("weapons/pbust_fire");}
            //zappy noises
  #### A 1 bright {HDBulletActor.FireBullet(self,"HDB_Plasma");}
                    //this makes zappy balls fly out
  #### A 0 {
		//aftereffects
    A_MuzzleClimb(-frandom(0.4,0.8),-frandom(0.4,0.8));
	 if(!random(0,9))invoker.weaponstatus[TBS_BATTERY]--;
}
//this uses up battery charge

		#### A 1 offset(0,34) A_WeaponReady(WRF_NONE);
		#### A 1 offset(-1,33) A_WeaponReady(WRF_NONE);
		#### A 0{
			if(invoker.weaponstatus[TBS_BATTERY]<1){
				A_StartSound("weapons/pbust_s",CHAN_WEAPON);
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

  #### A 0 A_GunFlash();
  #### AAAAA 1 bright {
    HDBulletActor.FireBullet(self,"HDB_Plasma");
    A_StartSound("weapons/pbust_fire");//zappy noises
    A_MuzzleClimb(-frandom(0.8,1.6),-frandom(0.8,1.6));
    }
  #### A 0 {
		//aftereffects
			if(!random(0,3))invoker.weaponstatus[TBS_BATTERY]--;
  }
  //burst fire uses up battery charge faster

		#### A 1 offset(0,34) A_WeaponReady(WRF_NONE);
		#### A 1 offset(-1,33) A_WeaponReady(WRF_NONE);
  	#### BBB 4{
			A_WeaponReady(WRF_NOFIRE);
		}
		#### A 0{
			if(invoker.weaponstatus[TBS_BATTERY]<1){
				A_StartSound("weapons/pbust_s",CHAN_WEAPON);
				A_GunFlash();
				setweaponstate("nope");
			}else{
				setweaponstate("nope");
			}
		}
	goto nope;

	firemode:
  goto nope;
  
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
		#### A 2 offset(0,40) A_StartSound("weapons/pbust_open",8);
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
		#### A 8 offset(0,38)A_StartSound("weapons/pbust_load",8);
		#### A 4 offset(0,37){if(health>39)A_SetTics(0);}
		#### A 4 offset(0,36)A_StartSound("weapons/pbust_close",8);

		#### A 0{
			let mmm=HDMagAmmo(findinventory("HDBattery"));
			if(mmm)invoker.weaponstatus[TBS_BATTERY]=mmm.TakeMag(true);
		}goto reload3;

	reload3:
		#### A 6 offset(0,40){
			invoker.weaponstatus[TBS_MAXRANGEDISPLAY]=int(
				(8000+200*invoker.weaponstatus[TBS_BATTERY])/HDCONST_ONEMETRE
			);
			A_StartSound("weapons/pbust_close2",8);
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
	}
}