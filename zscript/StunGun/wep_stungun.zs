
// ------------------------------------------------------------
// "DON'T TASE ME, BRO!"
// ------------------------------------------------------------

const HDLD_STUNGUN="STU";
const STUNGUNDRAIN=400;//was 1023; lower values mean faster drain


class HDStunGun:HDWeapon{//Tasers and stun guns are not the same, apparently
	default{
		//$Category "Weapons/Hideous Destructor"
		//$Title "Stun Gun"
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
		hdweapon.refid HDLD_STUNGUN;
		tag "$TAG_STUNGUN";
		obituary "$OB_STUNGUN";
	}
	override bool AddSpareWeapon(actor newowner){return AddSpareWeaponRegular(newowner);}
	override hdweapon GetSpareWeapon(actor newowner,bool reverse,bool doselect){return GetSpareWeaponRegular(newowner,reverse,doselect);}
	override string pickupmessage(){
		return Stringtable.Localize("$PICKUP_STUNGUN");
	}
	override string,double getpickupsprite(){return "TASRA0",0.7;}
	
	int walldamagemeter;//strip out all wallcutting code
	
	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
			//sb.drawbattery(-54,-4,sb.DI_SCREEN_CENTER_BOTTOM,reloadorder:true);
			int nextcellloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("HDMicroCell")));
			if(nextcellloaded>6){
				sb.drawimage("mclla0",(-46, -10),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1,1));
			}else if(nextcellloaded>3){
				sb.drawimage("mcllb0",(-46, -10),sb.DI_SCREEN_CENTER_BOTTOM,alpha:1.,scale:(1,1));
			}else if(nextcellloaded>0){
				sb.drawimage("mcllc0",(-46, -10),sb.DI_SCREEN_CENTER_BOTTOM,alpha:1.,scale:(1,1));
			}else sb.drawimage("mclld0",(-46, -10),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextcellloaded?0.6:1.,scale:(1,1));

			sb.drawnum(hpl.countinv("HDMicroCell"),-46,-8,sb.DI_SCREEN_CENTER_BOTTOM);
		}
		if(!hdw.weaponstatus[1])sb.drawstring(
			sb.mamountfont,"00000",(-16,-9),sb.DI_TEXT_ALIGN_RIGHT|
			sb.DI_TRANSLATABLE|sb.DI_SCREEN_CENTER_BOTTOM,
			Font.CR_DARKGRAY
		);else if(hdw.weaponstatus[1]>0)sb.drawwepnum(hdw.weaponstatus[1],10);
	}
	override string gethelptext(){
		return
		WEPHELP_FIRE.."  Zap\n"
		..WEPHELP_ALTFIRE.."  Quick Prod\n"
		..WEPHELP_RELOADRELOAD
		..WEPHELP_UNLOADUNLOAD
		;
	}
	override double gunmass(){
		return 2+(weaponstatus[STUNGUNS_BATTERY]<0?0:1);
	}
	override double weaponbulk(){
		return 30+(weaponstatus[STUNGUNS_BATTERY]>=0?ENC_BATTERY_LOADED/2:0);
	}
	
	override void consolidate(){
	//	CheckBFGCharge(STUNGUNS_BATTERY);
	// micro-cell weaponry is not compatible 
	// with the BFG auto-charge mechanic
	}
	
	action void A_HDTase(){
		A_WeaponReady(WRF_NONE);
		int battery=invoker.weaponstatus[STUNGUNS_BATTERY];
		int inertia=invoker.weaponstatus[STUNGUNS_INERTIA];

		if(battery<1)return;

		int drainprob=STUNGUNDRAIN;
		int dmg=0;
		
		name sawpuff="HDGunSmoke";//remove puffs
		
		A_StartSound("weapons/taser",CHAN_WEAPON);
		
	//more charge means more current means more damage
		dmg=battery/4;
		
		if(battery>0&&!random(0,drainprob))invoker.weaponstatus[STUNGUNS_BATTERY]--;

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
                && victim.health<=80
				&& battery>3 //a weak battery will not be strong enough to incap
                && victim.ResolveState("falldown")
                && !victim.InStateSequence
                (victim.CurState,victim.ResolveState("falldown")))
		        hdmobbase(victim).SetStateLabel("falldown");
    
			}
		}
	}
	
	//prod attack borrowed frm HDFist
		
    int targettimer;
	int targethealth;
	int targetspawnhealth;
	bool flicked;
	bool washolding;
	
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

	action void HD_StunProd(double dmg){
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
			if(punchline.hitline)doordestroyer.CheckDirtyWindowBreak(punchline.hitline,0.06+0.01*invoker.strength,punchline.hitlocation);
			//this is the part that does window damage, 
			//gave it 2x window damage because sharp points 
			//break glass more easily
			
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

		if(hd_debug)A_Log("Prodded "..punchee.getclassname().." for "..int(dmg).." damage!");

		bool puncheewasalive=!punchee.bcorpse&&punchee.health>0;

		if(dmg*2>punchee.health)punchee.A_StartSound("misc/bulletflesh",CHAN_AUTO);
		
		let aaa = HDFistPuncher(invoker.spawn("HDFistPuncher", invoker.pos));
		if(aaa)
		{
			aaa.master = invoker;
			punchee.damagemobj(aaa,self,int(dmg),"melee");


			aaa.destroy();
		}
	}

	states{
	ready:
		STNG C 1{
			A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER3|WRF_ALLOWUSER4);
		}goto readyend;
	select0:
		STNG D 0;
		goto select0big;
	deselect0:
		STNG D 0;
		goto deselect0big;
	hold:
		STNG C 0 A_JumpIf(invoker.weaponstatus[STUNGUNS_BATTERY]>0,"tase");
		goto nope;
	fire:
		STNG C 1 A_JumpIf(invoker.weaponstatus[STUNGUNS_BATTERY]>0,"tase");
		goto nope;
	altfire://super zap punch!
		STNG F 0;//disables blur if invisible
		#### C 2 Offset(-30,-25);
		#### C 2 Offset(-10, -5);
		#### C 0 Offset(30,15) HD_StunProd(10);//hits a bit weaker than a regular punch
		#### D 8 Offset(30,15) A_JumpIf(invoker.weaponstatus[STUNGUNS_BATTERY]>0,"zappunch");
		#### D 2 Offset(25,10);
		#### D 2 Offset(15,5);
		#### D 2 Offset(5, 2);
		#### D 2 Offset(0,0);
		goto readyend;
	zappunch:
		#### ABAB 2 Offset(30,15) A_HDTase();
		#### D 2 Offset(25, 10);
		#### D 2 Offset(15, 5);
		#### D 2 Offset(5, 2);
		#### D 2 Offset(0, 0);
		goto readyend;
	tase:
		STNG AB 2 A_HDTase();
		STNG B 0 A_Refire();
		goto readyend;

	reload:
		STNG C 0{
			if(
				invoker.weaponstatus[STUNGUNS_BATTERY]>=10
				||!countinv("HDMicroCell")
			){return resolvestate("nope");}
			invoker.weaponstatus[0]&=~STUNGUNF_JUSTUNLOAD;
			return resolvestate("unmag");
		}

	user4:
	unload:
		STNG C 0{
			if(invoker.weaponstatus[STUNGUNS_BATTERY]<0){
				return resolvestate("nope");
			}invoker.weaponstatus[0]|=STUNGUNF_JUSTUNLOAD;return resolvestate(null);
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
		STNG D 7 offset(6,78)A_StartSound("weapons/taseropen",8);
		STNG D 0{
			A_StartSound("weapons/taserload",8,CHANF_OVERLAP);
			if(
				!PressingUnload()&&!PressingReload()
			){
				setweaponstate("dropmag");
			}else setweaponstate("pocketmag");
		}
	dropmag:
		STNG D 0{
			if(invoker.weaponstatus[STUNGUNS_BATTERY]>=0){
				HDMagAmmo.SpawnMag(self,"HDMicroCell",invoker.weaponstatus[STUNGUNS_BATTERY]);
			}
			invoker.weaponstatus[STUNGUNS_BATTERY]=-1;
		}goto magout;
	pocketmag:
		STNG D 6 offset(7,80){
			if(invoker.weaponstatus[STUNGUNS_BATTERY]>=0){
				HDMagAmmo.GiveMag(self,"HDMicroCell",invoker.weaponstatus[STUNGUNS_BATTERY]);
				A_StartSound("weapons/pocket",9);
				A_MuzzleClimb(
					randompick(-1,1)*frandom(-0.3,-1.2),
					randompick(-1,1)*frandom(0.3,1.8)
				);
			}
			invoker.weaponstatus[STUNGUNS_BATTERY]=-1;
		}
		STNG D 7 offset(6,81) A_StartSound("weapons/pocket",9);
		goto magout;

	magout:
		STNG D 0 A_JumpIf(invoker.weaponstatus[0]&STUNGUNF_JUSTUNLOAD,"reloadend");
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
			let mmm=HDMagAmmo(findinventory("HDMicroCell"));
			if(mmm)invoker.weaponstatus[STUNGUNS_BATTERY]=mmm.TakeMag(true);
		}
	reloadend:
		STNG D 6 offset(5,72);
		STNG D 5 offset(4,74)A_StartSound("weapons/taserclose",8);
		STNG D 4 offset(2,62);
		STNG D 3 offset(0,52);
		STNG D 4 offset(0,44);
		STNG D 1 offset(0,37);
		STNG D 1 offset(0,35);
		STNG C 1 offset(0,33);
		goto ready;

	user3:
		STNG D 0 A_MagManager("HDMicroCell");
		goto ready;

	spawn:
		TASR A -1;
	}
	override void initializewepstats(bool idfa){
		weaponstatus[STUNGUNS_BATTERY]=10;
	}
}
enum taserstatus{
	STUNGUNF_JUSTUNLOAD=1,

	STUNGUNS_FLAGS=0,
	STUNGUNS_BATTERY=1,
	STUNGUNS_INERTIA=2,
};
