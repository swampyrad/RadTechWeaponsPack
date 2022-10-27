
// ------------------------------------------------------------
// "DON'T TASE ME, BRO!"
// ------------------------------------------------------------

const HDLD_TASER="TSR";
const TASERDRAIN=2047;//was 1023


class HDTaser:HDCellWeapon{
	default{
		//$Category "Weapons/Hideous Destructor"
		//$Title "Taser"
		//$Sprite "TASRA0"
		+hdweapon.fitsinbackpack
		weapon.selectionorder 90;
		weapon.slotnumber 1;
		weapon.slotpriority 0.1;
		weapon.bobstyle "Alpha";
		weapon.bobrangex 0.3;
		weapon.bobrangey 1.4;
		weapon.bobspeed 2.1;
		weapon.kickback 2;
		scale 0.4;
		hdweapon.barrelsize 36,3,2;
		hdweapon.refid HDLD_TASER;
		tag "Taser";
		obituary "%o got fried by %k's Taser.";
	}
	override bool AddSpareWeapon(actor newowner){return AddSpareWeaponRegular(newowner);}
	override hdweapon GetSpareWeapon(actor newowner,bool reverse,bool doselect){return GetSpareWeaponRegular(newowner,reverse,doselect);}
	override string pickupmessage(){
		return "You got the "..gettag().."! Zap, zap!";
	}
	override string,double getpickupsprite(){return "TASRA0",0.7;}
	
	int walldamagemeter;//strip out all wallcutting code
	
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
		WEPHELP_FIRE.."  Zap\n"
		..WEPHELP_RELOADRELOAD
		..WEPHELP_UNLOADUNLOAD
		;
	}
	override double gunmass(){
		return 2+(weaponstatus[TASERS_BATTERY]<0?0:1);
	}
	override double weaponbulk(){
		return 30+(weaponstatus[TASERS_BATTERY]>=0?ENC_BATTERY_LOADED:0);
	}
	override void consolidate(){
		CheckBFGCharge(TASERS_BATTERY);
	}
	
	action void A_HDTase(){
		A_WeaponReady(WRF_NONE);
		int battery=invoker.weaponstatus[TASERS_BATTERY];
		int inertia=invoker.weaponstatus[TASERS_INERTIA];
		if(inertia<12)invoker.weaponstatus[TASERS_INERTIA]++;

		int drainprob=TASERDRAIN;
		int dmg=0;
		
		name sawpuff="HDSawPuff";//remove puffs
		
		A_StartSound("weapons/taser",CHAN_WEAPON);
		
		if((inertia>11)&&(battery>random(5,8))){
			dmg=random(3,4);
			
			
		}else if((inertia>6)&&(battery>random(2,4))){
			dmg=random(2,3);
			A_SetTics(2);

			
		}else if((inertia>1)&&(battery>random(1,4))){
			drainprob*=3/2;
			dmg=random(1,2);
			A_SetTics(random(2,4));
		}
		if(battery>0&&!random(0,drainprob))invoker.weaponstatus[TASERS_BATTERY]--;

		actor victim=null;
		int finaldmg=0;
		vector3 puffpos=pos+gunpos();
		flinetracedata flt;
		if(dmg>0){
			A_AlertMonsters();

			//determine angle
			double shootangle=angle;
			double shootpitch=pitch;
			vector3 shootpos=(0,0,height*0.8);
			let hdp=hdplayerpawn(self);
			if(hdp){
				shootangle=hdp.gunangle;
				shootpitch=hdp.gunpitch;
				shootpos=gunpos((0,0,-4));
			}

			//create the line
			linetrace(
				shootangle,
				invoker.barrellength+2,
				shootpitch,
				flags:TRF_NOSKY|TRF_ABSOFFSET,
				offsetz:shootpos.z,
				offsetforward:shootpos.x,
				offsetside:shootpos.y,
				data:flt
			);

			if(flt.hittype!=Trace_HitNone){
			  
				A_StartSound("weapons/taser",9);
			}

			if(flt.hitactor){
				victim=flt.hitactor;
				puffpos=flt.hitlocation+flt.hitdir*min(victim.radius,frandom(2,5));
				invoker.setxyz(flt.hitlocation);
				finaldmg=victim.damagemobj(invoker,self,dmg,"hot");//replace cutting with thermal damage
			}else if(flt.hittype!=Trace_HitNone){
				puffpos=flt.hitlocation-flt.hitdir*4;
				
			}
		}

		if(
			!!victim
			&&(
				finaldmg>0
				||victim.bcorpse
			)
		){
			if(victim.bnoblood)spawn("HDGunSmoke",puffpos,ALLOW_REPLACE);
			else{
				int pdmg=0;//was 7
				array<HDDamageHandler> handlers;
				HDDamageHandler.GetHandlers(victim,handlers);
				for(int i=0;i<handlers.Size();i++){
					let hhh=handlers[i];
					if(hhh&&hhh.owner==victim)pdmg=hhh.HandleDamage(
						pdmg,
						"thermal",
						0,
						invoker,
						self
					);
				}

				if(hdmobbase(victim)){
				    A_StartSound("weapons/taserzap",CHAN_WEAPON);
				
					hdmobbase(victim).stunned+=(dmg<<2);
					
					//heat buildup, sets enemies on fire if tased for too long
					hdmobbase(victim).A_GiveInventory("Heat",dmg*2);
			        hdmobbase(victim).damagemobj(self,target,max(1,dmg>>2),"hot");
		
				}
				
				//incap code copied from Less-Lethal Shells
				if(HDMobBase(victim) 
                && !HDMobBase(victim).bNOINCAP 
                && victim.health>0
                && victim.ResolveState("falldown")
                && !victim.InStateSequence
                (victim.CurState,victim.ResolveState("falldown")))
		        hdmobbase(victim).SetStateLabel("falldown");
    
			}
		}
		

	}
	states{
	ready:
		STNG C 1{
			invoker.weaponstatus[0]&=~TASERF_CHOPPINGFLESH;
			invoker.walldamagemeter=0;
			A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER3|WRF_ALLOWUSER4);
		}goto readyend;
	select0:
		STNG D 0{invoker.weaponstatus[TASERS_INERTIA]=0;}
		goto select0big;
	deselect0:
		STNG D 0;
		goto deselect0big;
	hold:
		STNG A 0 A_JumpIf(invoker.weaponstatus[TASERS_BATTERY]>0,"tase");
		goto nope;
	fire:
		STNG B 1 A_JumpIf(invoker.weaponstatus[TASERS_BATTERY]>0,"tase");
		goto nope;
	tase:
		STNG AB 2 A_HDTase();
		STNG B 0 A_Refire();
		goto readyend;

	reload:
		STNG C 0{
			if(
				invoker.weaponstatus[TASERS_BATTERY]>=20
				||!countinv("HDBattery")
			){return resolvestate("nope");}
			invoker.weaponstatus[0]&=~TASERF_JUSTUNLOAD;
			return resolvestate("unmag");
		}

	user4:
	unload:
		STNG C 0{
			if(invoker.weaponstatus[TASERS_BATTERY]<0){
				return resolvestate("nope");
			}invoker.weaponstatus[0]|=TASERF_JUSTUNLOAD;return resolvestate(null);
		}
	unmag:
		STNG D 1 offset(0,33);
		STNG D 1 offset(0,35);
		STNG D 1 offset(0,37);
		STNG D 1 offset(0,39);
		STNG D 2 offset(0,44);
		STNG D 2 offset(0,52);
		STNG D 3 offset(2,62);
		STNG D 4 offset(4,74);
		STNG D 7 offset(6,78)A_StartSound("weapons/csawopen",8);
		STNG D 0{
			A_StartSound("weapons/csawload",8,CHANF_OVERLAP);
			if(
				!PressingUnload()&&!PressingReload()
			){
				setweaponstate("dropmag");
			}else setweaponstate("pocketmag");
		}
	dropmag:
		STNG D 0{
			if(invoker.weaponstatus[TASERS_BATTERY]>=0){
				HDMagAmmo.SpawnMag(self,"HDBattery",invoker.weaponstatus[TASERS_BATTERY]);
			}
			invoker.weaponstatus[TASERS_BATTERY]=-1;
		}goto magout;
	pocketmag:
		STNG D 6 offset(7,80){
			if(invoker.weaponstatus[TASERS_BATTERY]>=0){
				HDMagAmmo.GiveMag(self,"HDBattery",invoker.weaponstatus[TASERS_BATTERY]);
				A_StartSound("weapons/pocket",9);
				A_MuzzleClimb(
					randompick(-1,1)*frandom(-0.3,-1.2),
					randompick(-1,1)*frandom(0.3,1.8)
				);
			}
			invoker.weaponstatus[TASERS_BATTERY]=-1;
		}
		STNG D 7 offset(6,81) A_StartSound("weapons/pocket",9);
		goto magout;

	magout:
		STNG D 0 A_JumpIf(invoker.weaponstatus[0]&TASERF_JUSTUNLOAD,"reloadend");
	loadmag:
		STNG D 4 offset(7,79) A_MuzzleClimb(
			randompick(-1,1)*frandom(-0.3,-1.2),
			randompick(-1,1)*frandom(0.3,0.8)
		);
		STNG D 2 offset(6,78) A_StartSound("weapons/pocket",9);
		STNG DD 5 offset(5,76) A_MuzzleClimb(
			randompick(-1,1)*frandom(-0.3,-1.2),
			randompick(-1,1)*frandom(0.3,0.8)
		);
		STNG D 0{
			let mmm=HDMagAmmo(findinventory("HDBattery"));
			if(mmm)invoker.weaponstatus[TASERS_BATTERY]=mmm.TakeMag(true);
		}
	reloadend:
		STNG D 6 offset(5,72);
		STNG D 5 offset(4,74)A_StartSound("weapons/csawclose",8);
		STNG D 4 offset(2,62);
		STNG D 3 offset(0,52);
		STNG D 4 offset(0,44);
		STNG D 1 offset(0,37);
		STNG D 1 offset(0,35);
		STNG C 1 offset(0,33);
		goto ready;

	user3:
		STNG D 0 A_MagManager("HDBattery");
		goto ready;

	spawn:
		TASR A -1;
	}
	override void initializewepstats(bool idfa){
		weaponstatus[TASERS_BATTERY]=20;
	}
}
enum taserstatus{
	TASERF_JUSTUNLOAD=1,
	TASERF_CHOPPINGFLESH=2,

	TASERS_FLAGS=0,
	TASERS_BATTERY=1,
	TASERS_INERTIA=2,
};



