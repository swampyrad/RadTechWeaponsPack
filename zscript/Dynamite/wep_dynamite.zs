// ------------------------------------------------------------
// HEEHEEEHEEHEEEHAAHAA!
// ------------------------------------------------------------
const ENC_DYNAMITE=ENC_FRAG*1.2;

class HDDynamiteThrower:HDWeapon{
	class<inventory> dynamiteammotype;
	property ammotype:dynamiteammotype;
	class<actor> throwtype;
	property throwtype:throwtype;
	class<actor> throwtype_unlit;
	property throwtype_unlit:throwtype_unlit;
	class<actor> spoontype;
	property spoontype:spoontype;
	
	int botid;
	
	default{
		+weapon.no_auto_switch 
		+weapon.noalert 
		+weapon.wimpy_weapon
		+hdweapon.dontdisarm
		+hdweapon.dontnull
		+nointeraction
		weapon.bobstyle "Alpha";
		weapon.bobspeed 2.5;
		weapon.bobrangex 0.1;
		weapon.bobrangey 0.5;

		//adding the defaults here to prevent needless crashes
		hddynamitethrower.ammotype "HDDynamiteAmmo";
		hddynamitethrower.throwtype "HDDynamite";
		hddynamitethrower.throwtype_unlit "HDDynamiteUnlit";
		hddynamitethrower.spoontype "HDDynaFuse";

		inventory.maxamount 1;
	}
	
	override void DoEffect(){
		if(weaponstatus[0]&DYNAF_SPOONOFF){
			weaponstatus[DYNAS_TIMER]++;//continue burning fuse if already lit
			if(
				owner.health<1
				||weaponstatus[DYNAS_TIMER]>176
			)TossDynamite(true);//throw if player is dead or fuse is burnt out
		}
		else if(
			weaponstatus[0]&DYNAF_INHAND
			&&weaponstatus[0]&DYNAF_PINOUT
			&&owner.player.cmd.buttons&BT_ATTACK
			&&owner.player.cmd.buttons&BT_ALTFIRE
			&&!(owner.player.oldbuttons&BT_ALTFIRE)
		    )StartCooking();//light fuse if preparing throw and lighter is ready
		
		super.doeffect();
	}
	
	override string,double getpickupsprite(){return "DYNAA0",0.6;}
	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
			sb.drawimage(
				(weaponstatus[0]&DYNAF_SPOONOFF)?"DYNAG0I0":
				(weaponstatus[0]&DYNAF_PINOUT)?"DYNAF0":"DYNAA0",
				(-52,-4),sb.DI_SCREEN_CENTER_BOTTOM,scale:(0.6,0.6)
			);
			sb.drawnum(hpl.countinv("HDDynamiteAmmo"),-45,-8,sb.DI_SCREEN_CENTER_BOTTOM);
		}
		
		sb.drawwepnum(
			hpl.countinv("HDDynamiteAmmo"),
			(HDCONST_MAXPOCKETSPACE/(ENC_DYNAMITE))
		);
		
		sb.drawwepnum(hdw.weaponstatus[DYNAS_FORCE],50,posy:-10,alwaysprecise:true);
		if(!(hdw.weaponstatus[0]&DYNAF_SPOONOFF)){
			sb.drawrect(-21,-19,5,4);
			if(!(hdw.weaponstatus[0]&DYNAF_PINOUT))sb.drawrect(-25,-18,3,2);
		}else{
			int timer=hdw.weaponstatus[DYNAS_TIMER];
			if(timer%3)sb.drawwepnum(180-timer,180,posy:-15,alwaysprecise:true);
		}
	}
	
	override string gethelptext(){
		if(weaponstatus[0]&DYNAF_SPOONOFF)return
		WEPHELP_FIRE.."  Wind up, release to throw\n(\cxSTOP READING AND DO THIS"..WEPHELP_RGCOL..")";
		return
		WEPHELP_FIRE.."  Wind up, release to throw\n"
		..WEPHELP_ALTFIRE.."  Ready lighter, again to light fuse\n"
		..WEPHELP_RELOAD.."  Abort/close lighter\n"
		..WEPHELP_FIREMODE.."  Plant a bomb"
		;
	}
	
	override inventory CreateTossable(int amt){
		ReturnHandToOwner();
		owner.A_DropInventory(dynamiteammotype,owner.countinv(dynamiteammotype));
		owner.A_GiveInventory("HDFist");
		owner.A_SelectWeapon("HDFist");
		return null;
	}
	
	override void InitializeWepStats(bool idfa){
		//if(idfa)owner.A_SetInventory(dynamiteammotype,max(3,owner.countinv(dynamiteammotype)));
	}
	
	override void DropOneAmmo(int amt){
		if(owner){
			amt=clamp(amt,1,10);
			owner.A_DropInventory(dynamiteammotype,1);
		}
	}
	
	override void ForceBasicAmmo(){
		owner.A_SetInventory("HDDynamiteAmmo",1);
	}
	
	//for involuntary dropping
	override void OnPlayerDrop(){
		if(weaponstatus[0]&DYNAF_SPOONOFF)TossDynamite(true);//do this only if fuse is lit
		else{
			bool inhand=weaponstatus[0]&DYNAF_INHAND;
			if(inhand||owner.countinv(dynamiteammotype)){
				if(!inhand)A_TakeInventory(dynamiteammotype,1);
				A_DropItem(dynamiteammotype);
			    }
			weaponstatus[0]&=~DYNAF_INHAND;
		}
	}
	
	void DropDynamite(){
		if(weaponstatus[0]&DYNAF_SPOONOFF)TossDynamite(true);//do this only if fuse is lit
		else{
			bool inhand=weaponstatus[0]&DYNAF_INHAND;
			if(inhand||owner.countinv(dynamiteammotype)){
				if(!inhand)A_TakeInventory(dynamiteammotype,1);
				A_DropItem(dynamiteammotype);
			    }
			weaponstatus[0]&=~DYNAF_INHAND;
		    }
	}
	
	//any reset should do this
	action void A_ReturnHandToOwner(){invoker.ReturnHandToOwner();}
	void ReturnHandToOwner(){
		if(!owner)return;
		int wepstat=weaponstatus[0];
		if(wepstat&DYNAF_INHAND){
			if(wepstat&DYNAF_SPOONOFF)TossDynamite(true);
			else{
				if(wepstat&DYNAF_PINOUT){
					owner.A_StartSound("weapons/dyna_pinout",8);
					weaponstatus[0]&=~DYNAF_PINOUT;
				}
				
				if(
					owner.A_JumpIfInventory(dynamiteammotype,0,"null")
				)owner.A_DropItem(dynamiteammotype);
				else HDF.Give(owner,dynamiteammotype,1);
			}
		}
		weaponstatus[0]&=~DYNAF_INHAND;
		weaponstatus[DYNAS_FORCE]=0;
		weaponstatus[DYNAS_REALLYPULL]=0;
	}
	
	vector3 SwingThrow(){
		vector2 iyy=(owner.angle,owner.pitch);
		double cosp=cos(iyy.y);
		vector3 oldpos=(
			cosp*cos(iyy.x),
			cosp*sin(iyy.x),
			sin(iyy.y)
		);
		iyy+=(
				owner.getplayerinput(MODINPUT_YAW),
				owner.getplayerinput(MODINPUT_PITCH)
			)
			*(360./65536.);
		cosp=cos(iyy.y);
		vector3 newpos=(
			cosp*cos(iyy.x),
			cosp*sin(iyy.x),
			sin(iyy.y)
		);
		return newpos-oldpos;
	}
	
	//because it's tedious to type each time
	action bool NoDynamite(){
		return !(invoker.weaponstatus[0]&DYNAF_INHAND)
		        &&!countinv(invoker.dynamiteammotype);
	}
	
	//ready the lighter
	action void A_LightFuse(){
		invoker.weaponstatus[DYNAS_REALLYPULL]=0;
		invoker.weaponstatus[0]|=(DYNAF_PINOUT|DYNAF_INHAND);
		A_TakeInventory(invoker.dynamiteammotype,1,TIF_NOTAKEINFINITE);
		A_StartSound("weapons/dyna_pinin",8);
	}
	
	//actually light the fuse
	action void A_StartCooking(){
		invoker.StartCooking();
		A_SetHelpText();
	}
	void StartCooking(){
		if(!owner)return;
		bool gbg;actor spn;
		double ptch=owner.pitch;
		double cpp=cos(ptch);double spp=sin(ptch);
		[gbg,spn]=owner.A_SpawnItemEx(spoontype,
			cpp*4,-1,gunheight()+2-spp*4,
				cpp*4+vel.x,
				0,
				-sin(pitch)*4+vel.z,
			0,SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
		);
		spn.vel+=owner.vel;
		weaponstatus[0]|=DYNAF_SPOONOFF;
		if(DoHelpText(owner))A_WeaponMessage("\cgThe fuse is lit!\n\n\n\n\cgRemember to throw!",100);
		owner.A_StartSound("weapons/dyna_spoonoff",8,attenuation:20);
	}
	
	//we need to start from the inventory itself so it can go into DoEffect
	action void A_TossDynamite(bool oshit=false){
		invoker.TossDynamite(oshit);
		A_SetHelpText();
	}
	void TossDynamite(bool oshit=false){
		if(!owner)return;
		int garbage;actor ggg;
		double cpp=cos(owner.pitch);
		double spp=sin(owner.pitch);
        
        //play throw sound
        A_StartSound("weapons/dyna_throw",8);

		//create the spoon
		if(!(weaponstatus[0]&DYNAF_SPOONOFF)){
			[garbage,ggg]=owner.A_SpawnItemEx(
				spoontype,cpp*-4,-3,owner.height*0.88-spp*-4,
				cpp*3,0,-sin(owner.pitch+random(10,20))*3,
				frandom(33,45),SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
			);
			ggg.vel+=owner.vel;
		}

		//create the dynamite
		[garbage,ggg]=owner.A_SpawnItemEx(throwtype,
			0,0,owner.height*0.88,
			cpp*4,
			0,
			-spp*4,
			0,SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
		);
		ggg.vel+=owner.vel;

		//force calculation
		double gforce=clamp(weaponstatus[DYNAS_FORCE]*0.5,1,40+owner.health*0.1);
		if(oshit)gforce=min(gforce,frandom(4,20));
		if(hdplayerpawn(owner))gforce*=hdplayerpawn(owner).strength;

		let dynamite=HDDynamite(ggg);if(!dynamite)return;
		dynamite.fuze=weaponstatus[DYNAS_TIMER];

		if(owner.player){dynamite.vel+=SwingThrow()*gforce;}
		
		dynamite.a_changevelocity(
			cpp*gforce*0.6,
			0,
			-spp*gforce*0.6,
			CVF_RELATIVE
		);
		weaponstatus[DYNAS_TIMER]=0;
		weaponstatus[DYNAS_FORCE]=0;
		weaponstatus[0]&=~DYNAF_PINOUT;
		weaponstatus[0]&=~DYNAF_SPOONOFF;
		weaponstatus[DYNAS_REALLYPULL]=0;

		weaponstatus[0]&=~DYNAF_INHAND;
		weaponstatus[0]|=DYNAF_JUSTTHREW;
	}
	
	//separate function for throwing unlit dynamite
	action void A_TossDynamiteUnlit(bool oshit=false){
		invoker.TossDynamiteUnlit(oshit);
	//	A_SetHelpText();
	}
	void TossDynamiteUnlit(bool oshit=false){
		if(!owner)return;
		int garbage;actor ggg;
		double cpp=cos(owner.pitch);
		double spp=sin(owner.pitch);
        
        //play throw sound
        A_StartSound("weapons/dyna_throw",8);

		//create the dynamite
		[garbage,ggg]=owner.A_SpawnItemEx(throwtype_unlit,
			0,0,owner.height*0.88,
			cpp*4,
			0,
			-spp*4,
			0,SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
		);
		ggg.vel+=owner.vel;

		//force calculation
		double gforce=clamp(weaponstatus[DYNAS_FORCE]*0.5,1,40+owner.health*0.1);
		if(oshit)gforce=min(gforce,frandom(4,20));
		if(hdplayerpawn(owner))gforce*=hdplayerpawn(owner).strength;

		let dynamite=HDDynamiteUnlit(ggg);if(!dynamite)return;
		dynamite.fuze=weaponstatus[DYNAS_TIMER];

		if(owner.player){dynamite.vel+=SwingThrow()*gforce;}
		
		dynamite.a_changevelocity(
			cpp*gforce*0.6,
			0,
			-spp*gforce*0.6,
			CVF_RELATIVE
		);
		weaponstatus[DYNAS_TIMER]=0;
		weaponstatus[DYNAS_FORCE]=0;
		weaponstatus[0]&=~DYNAF_PINOUT;
		weaponstatus[DYNAS_REALLYPULL]=0;
		
		weaponstatus[0]&=~DYNAF_INHAND;
		weaponstatus[0]|=DYNAF_JUSTTHREW;
	}
	
	override int getsbarnum(int flags){return botid;}
	action void A_PlantDynamite(){//copied from doorbuster code
		if(invoker.amount<1){
			invoker.destroy();return;
		}
		vector3 startpos=HDMath.GetGunPos(self);
		flinetracedata dlt;
		linetrace(
			angle,48,pitch,flags:TRF_THRUACTORS,
			offsetz:startpos.z,
			data:dlt
		);
		if(
			!dlt.hitline
			||HDF.linetracehitsky(dlt)
		){
			A_Log(string.format("Find a wall to stick the dynamite on."),true);
			return;
		}
		vector3 plantspot=dlt.hitlocation-dlt.hitdir*3;
		let ddd=DynamitePlanted(spawn("DynamitePlanted",plantspot,ALLOW_REPLACE));
		if(!ddd){
			A_Log("Can't plant here.",true);
			return;
		}
		ddd.A_StartSound("doorbust/stick",CHAN_BODY);
		ddd.stuckline=dlt.hitline;
		ddd.translation=translation;
		ddd.master=self;
		ddd.detonating=false;

		let delta=dlt.hitline.delta;
		if(dlt.lineside==line.back)delta=-delta;
		ddd.angle=VectorAngle(-delta.y,delta.x);

		if(!dlt.hitline.backsector){
			ddd.stuckheight=ddd.pos.z;
			ddd.stucktier=0;
		}else{
			sector othersector=hdmath.oppositesector(dlt.hitline,dlt.hitsector);
			ddd.stuckpoint=plantspot.xy;
			double stuckceilingz=othersector.ceilingplane.zatpoint(ddd.stuckpoint);
			double stuckfloorz=othersector.floorplane.zatpoint(ddd.stuckpoint);
			ddd.stuckbacksector=othersector;
			double dpz=ddd.pos.z;
			if(dpz-ddd.height>stuckceilingz){
				ddd.stuckheight=dpz-ddd.height-stuckceilingz;
				ddd.stucktier=1;
			}else if(dpz<stuckfloorz){
				ddd.stuckheight=dpz-stuckfloorz;
				ddd.stucktier=-1;
			}else{
				ddd.stuckheight=ddd.pos.z;
				ddd.stucktier=0;
			}
		}
		string feedback=string.format("Dynamite planted! Now get away!");
		A_Log(feedback,true);
		TakeInventory("HDDynamiteAmmo", 1);
		if(!countinv("HDDynamiteAmmo")){
		    string feedback=string.format("You have no dynamite to plant.");
		    A_Log(feedback,true);
		    invoker.destroy();
		    }
	}
	
	states{
	select0:
		TNT1 A 0 A_JumpIf(NoDynamite(),"selectinstant");
		TNT1 A 8{
			if(!countinv("NulledWeapon"))A_SetTics(tics+4);
			A_TakeInventory("NulledWeapon");
			invoker.weaponstatus[DYNAS_REALLYPULL]=0;
			invoker.weaponstatus[DYNAS_FORCE]=0;
		}
		FRGG B 1 A_Raise(32);
		wait;
	selectinstant:
		TNT1 A 0 A_WeaponBusy(false);
	readytodonothing:
		TNT1 A 0 A_JumpIf(pressing(BT_SPEED)||pressingfire()||pressingaltfire()||pressingreload()||pressingzoom(),2);
		TNT1 A 1 A_WeaponReady(WRF_NOFIRE);
		loop;
		TNT1 A 0 A_SelectWeapon("HDFist");
		TNT1 A 1 A_WeaponReady(WRF_NOFIRE);
		wait;
	deselect0:
		---- A 1{
			if(invoker.weaponstatus[0]&DYNAF_PINOUT)A_SetTics(8);
			else if(NoDynamite())setweaponstate("deselectinstant");
			invoker.ReturnHandToOwner();
		}
		---- A 1 A_Lower(72);
		wait;
	deselectinstant:
		TNT1 A 0 A_Lower(999);
		wait;
	ready:
		FRGG B 0{
			invoker.weaponstatus[DYNAS_FORCE]=0;
			invoker.weaponstatus[DYNAS_REALLYPULL]=0;
		}
		FRGG B 1 A_WeaponReady(WRF_ALL);
		goto ready3;
	ready3:
		---- A 0{
			invoker.weaponstatus[0]&=~DYNAF_JUSTTHREW;
			A_WeaponBusy(false);
		}goto readyend;

	zoom://no tripwires, it's dynamite, it can't light itself
		goto nope;

	pinout:
		FRGG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		loop;

	altfire:
		TNT1 A 0 A_JumpIf(invoker.weaponstatus[0]&DYNAF_SPOONOFF,"nope");//do nothing if already lit
		TNT1 A 0 A_JumpIf(invoker.weaponstatus[0]&DYNAF_PINOUT,"startcooking");//light fuse if light ready
		TNT1 A 0 A_JumpIf(NoDynamite(),"selectinstant");
		TNT1 A 0 A_Refire();
		goto ready;
	althold:
		TNT1 A 0 A_JumpIf(invoker.weaponstatus[0]&DYNAF_SPOONOFF,"nope");
		TNT1 A 0 A_JumpIf(invoker.weaponstatus[0]&DYNAF_PINOUT,"nope");
		TNT1 A 0 A_JumpIf(NoDynamite(),"selectinstant");
		goto startpull;
	startpull:
		FRGG B 1{
			if(invoker.weaponstatus[DYNAS_REALLYPULL]>=16)setweaponstate("endpull");
			else invoker.weaponstatus[DYNAS_REALLYPULL]++;
		}
		FRGG B 0 A_Refire();
		goto ready;
	endpull:
		FRGG B 1 offset(0,34);
		FRGG B 1 offset(0,36);
		FRGG B 1 offset(0,38);
		TNT1 A 6;
		TNT1 A 3 A_LightFuse();
		TNT1 A 0 A_Refire();
		goto ready;
	startcooking:
		TNT1 A 6 A_StartCooking();
		TNT1 A 0 A_Refire();
		goto ready;
	fire:
		TNT1 A 0 A_JumpIf(invoker.weaponstatus[0]&DYNAF_JUSTTHREW,"nope");
		TNT1 A 0 A_JumpIf(NoDynamite(),"selectinstant");
		TNT1 A 0 A_JumpIf(hdplayerpawn(self)&&hdplayerpawn(self).strength>1.7,4);
		TNT1 A 0 A_JumpIf(hdplayerpawn(self)&&hdplayerpawn(self).strength>1.3,2);
		FRGG B 1 offset(0,34);
		FRGG B 1 offset(0,36);
		FRGG B 1 offset(0,38);
		TNT1 A 0 A_Refire();
		goto ready;
	hold:
		TNT1 A 0 A_JumpIf(invoker.weaponstatus[0]&DYNAF_JUSTTHREW,"nope");
		TNT1 A 0 A_JumpIf(invoker.weaponstatus[0]&DYNAF_PINOUT,"hold2");
		TNT1 A 6 A_JumpIf(invoker.weaponstatus[DYNAS_FORCE]>=1,"hold2");
		TNT1 A 6 A_SetTics(hdplayerpawn(self)?int(5./hdplayerpawn(self).strength):6);
		TNT1 A 0 A_JumpIf(NoDynamite(),"selectinstant");
		TNT1 A 3 A_LightFuse();
	hold2:
		TNT1 A 0 A_JumpIf(NoDynamite(),"selectinstant");
		FRGG E 0 A_JumpIf(invoker.weaponstatus[DYNAS_FORCE]>=40,"hold3a");
		FRGG D 0 A_JumpIf(invoker.weaponstatus[DYNAS_FORCE]>=30,"hold3a");
		FRGG C 0 A_JumpIf(invoker.weaponstatus[DYNAS_FORCE]>=20,"hold3");
		FRGG B 0 A_JumpIf(invoker.weaponstatus[DYNAS_FORCE]>=10,"hold3");
		goto hold3;
	hold3a:
		FRGG # 0{
			if(invoker.weaponstatus[DYNAS_FORCE]<50)invoker.weaponstatus[DYNAS_FORCE]++;
		}
	hold3:
		FRGG # 1{
			A_WeaponReady(
				invoker.weaponstatus[0]&DYNAF_SPOONOFF?WRF_NOFIRE:WRF_NOFIRE|WRF_ALLOWRELOAD
			);
			if(invoker.weaponstatus[DYNAS_FORCE]<50)invoker.weaponstatus[FRAGS_FORCE]++;
		}
		TNT1 A 0 A_Refire();
		goto throw;
	throw:
		TNT1 A 0 A_JumpIf(NoDynamite(),"selectinstant");
		FRGG A 1 offset(0,34) {if(invoker.weaponstatus[0]&DYNAF_SPOONOFF)
		                        {A_TossDynamite();}//check if fuse is lit
		                        else A_TossDynamiteUnlit();//otherwise just throw unlit bundle
		                      }
		FRGG A 1 offset(0,38);
		FRGG A 1 offset(0,48);
		FRGG A 1 offset(0,52);
		FRGG A 0 A_Refire();
		goto ready;
	reload:
		TNT1 A 0 A_JumpIf(NoDynamite(),"selectinstant");
		TNT1 A 0 A_JumpIf(invoker.weaponstatus[DYNAS_FORCE]>=1,"pinbackin");
		TNT1 A 0 A_JumpIf(invoker.weaponstatus[0]&DYNAF_PINOUT,"altpinbackin");
		goto ready;
	pinbackin:
		FRGG B 1 offset(0,34) A_ReturnHandToOwner();
		FRGG B 1 offset(0,36);
		FRGG B 1 offset(0,38);
	altpinbackin:
		FRGG A 0 A_JumpIf(invoker.weaponstatus[DYNAS_TIMER]>0,"juststopthrowing");
		TNT1 A 8 A_ReturnHandToOwner();
		TNT1 A 0 A_Refire("nope");
		FRGG B 1 offset(0,38);
		FRGG B 1 offset(0,36);
		FRGG B 1 offset(0,34);
		goto ready;
	juststopthrowing:
		TNT1 A 10;
		FRGG A 0{invoker.weaponstatus[DYNAS_FORCE]=0;}
		TNT1 A 0 A_Refire();
		FRGG B 1 offset(0,38);
		FRGG B 1 offset(0,36);
		FRGG B 1 offset(0,34);
		goto ready;
		
	firemode://uses dynamite like it's a doorbuster
	    plantbomb:
	    TNT1 A 1 A_PlantDynamite();
	    goto nope;
	    
	spawn:
		TNT1 A 1;
		TNT1 A 0 A_SpawnItemEx(invoker.dynamiteammotype,SXF_NOCHECKPOSITION);
		stop;
	}
}
enum DynamiteWepNums{
	DYNAF_INHAND=1,
	DYNAF_PINOUT=2,
	DYNAF_SPOONOFF=4,
	DYNAF_JUSTTHREW=8,

	DYNAS_REALLYPULL=1,
	DYNAS_TIMER=2,
	DYNAS_FORCE=3,
}


class HDDynamites:HDDynamiteThrower{//the actual weapon
	default{
		weapon.selectionorder 1020;
		weapon.slotnumber 0;
		weapon.slotpriority 0.1;
		tag "$TAG_DYNAMITE";
		hddynamitethrower.ammotype "HDDynamiteAmmo";
		hddynamitethrower.throwtype "HDDynamite";
		hddynamitethrower.spoontype "HDDynaFuse";
		
		inventory.icon "DYNAA0";
	}
}

//lit dynamite bundles
class HDDynamiteRoller:HDActor{//the projectile after it hits the ground
	int fuze;
	vector3 keeprolling;
	default{
		-noextremedeath 
		-floorclip 
		+shootable 
		+noblood 
		+forcexybillboard
		+activatemcross 
		-noteleport 
		+noblockmonst 
		+explodeonwater
		+missile 
		+bounceonactors 
		+usebouncestate
		
		health 10;
		
		bouncetype "doom";
		bouncesound "weapons/dynaknock";
		radius 8;
		height 8;
		damagetype "none";
		scale 0.3;
		obituary "%o was blown to smitheteens by %k.";
		radiusdamagefactor 0.04;
		pushfactor 1.4;
		maxstepheight 2;
		mass 30;
	}
	
	override bool used(actor user){
		angle=user.angle;
		A_StartSound(bouncesound);
		if(hdplayerpawn(user)&&hdplayerpawn(user).incapacitated)A_ChangeVelocity(4,0,1,CVF_RELATIVE);
		else A_ChangeVelocity(12,0,4,CVF_RELATIVE);
		return true;
	}
	
	states{
	spawn:
		DYNA A 0 nodelay{
			HDMobAI.Frighten(self,256);
		}
		#### A 0 A_StartSound("weapons/dyna_spoonoff");
	spawn2:
		DYNA GHIJ 2{
			if(abs(vel.z-keeprolling.z)>10)A_StartSound("weapons/dynaknock",CHAN_BODY);
			else if(floorz>=pos.z)A_StartSound("weapons/dynaroll");
			keeprolling=vel;
			if(abs(vel.x)<0.4 && abs(vel.y)<0.4) setstatelabel("death");
		}loop;
	bounce:
		#### # 0{
			bmissile=false;
			vel*=0.3;
		}goto spawn2;
	death:
		#### # 2{
			if(abs(vel.z-keeprolling.z)>3){
				A_StartSound("weapons/dynaknock",CHAN_BODY);
				keeprolling=vel;
			}
			if(abs(vel.x)>0.4 || abs(vel.y)>0.4) setstatelabel("spawn");
		}wait;
	destroy:
		TNT1 A 1{
			bsolid=false;bpushable=false;bmissile=false;bnointeraction=true;bshootable=false;
			HDDynamite.Kaboom(self);
			HDDynamite.DynamiteShot(self,64);
			actor xpl=spawn("WallChunker",self.pos-(0,0,1),ALLOW_REPLACE);
				xpl.target=target;xpl.master=master;xpl.stamina=stamina;
			xpl=spawn("HDExplosion",self.pos-(0,0,1),ALLOW_REPLACE);
				xpl.target=target;xpl.master=master;xpl.stamina=stamina;
			A_SpawnChunks("BigWallChunk",14,4,12);
		}
		stop;
	}
	
	override void tick(){
		if(isfrozen())return;
		else if(bnointeraction){
			NextTic();
			return;
		}else{
			fuze++;
			if(health<1 || fuze>=180 && !bnointeraction){
				setstatelabel("destroy");
				NextTic();
				return;
			}else super.tick();
		}
	}
}

class HDDynamite:SlowProjectile{//the projectile when thrown
	int fuze;
	vector3 keeprolling;
	class<actor> rollertype;
	property rollertype:rollertype;
	default{
		-noextremedeath 
		-floorclip 
		+bloodlessimpact
		+shootable 
		-noblockmap 
		+noblood
		+activatemcross 
		-noteleport

		health 10;
		
		radius 8;
		height 8;
		damagetype "none";
		scale 0.3;
		obituary "%o was blown to smithereens by %k.";
		mass 400;
		hddynamite.rollertype "HDDynamiteRoller";
	}
	static void Kaboom(HDActor caller){
		distantnoise.make(caller,"world/rocketfar");
		DistantQuaker.Quake(caller,4,35,512,10);
		caller.A_StartSound("world/explode",CHAN_BODY,CHANF_OVERLAP);
		caller.A_AlertMonsters();
		//caller.A_SpawnChunksFrags();

		caller.A_HDBlast(
			pushradius:128,
			pushamount:4096,
			fullpushradius:64,
			fragradius:HDCONST_ONEMETRE*64
		);

	}
	    //a copy of HDHEAT.HEATShot
		static void DynamiteShot(actor caller,double squirtamt){
		vector3 originalpos=caller.pos;

		//do a series of linetracers to drill through everything
		caller.A_SprayDecal("BigScorch",squirtamt);
		array<actor>hitactors;hitactors.clear();
		flinetracedata sqtrace;
		do{
			caller.linetrace(
				caller.angle,
				squirtamt,
				caller.pitch,
				data:sqtrace
			);

			caller.setorigin(sqtrace.hitlocation-sqtrace.hitdir,false);
			if(sqtrace.hitactor){
				int dmgg=int(frandom(70,240+squirtamt));
				int dangle=int(absangle(caller.angle,caller.angleto(sqtrace.hitactor)));
				bool crapshot=dangle>40;
				if(dangle<20){
					dmgg+=int((90-dangle)*squirtamt*frandom(0.4,0.45));
					if(hd_debug)console.printf("CRIT!");
				}else if(!crapshot)dmgg+=int(frandom(100,400-dangle+squirtamt*2));
				int originalhealth=sqtrace.hitactor.health;
				sqtrace.hitactor.damagemobj(
					caller,caller.target,dmgg,crapshot?"Slashing":"Piercing",
					crapshot?0:DMG_NO_ARMOR
				);
				int fdmg=0;
				if(sqtrace.hitactor){
					fdmg=originalhealth-sqtrace.hitactor.health;
					if(
						sqtrace.hitactor.health>0
						&&(fdmg<<3)<sqtrace.hitactor.spawnhealth()
					)break;
					else{
						hitactors.push(sqtrace.hitactor);
						sqtrace.hitactor.bnonshootable=true;
					}
				}
				squirtamt-=max(8,fdmg>>6);
			}else{
				doordestroyer.destroydoor(caller,maxwidth:squirtamt*frandom(1.3,1.6),dedicated:true);
				squirtamt-=max(16,sqtrace.distance);
			}
		}while(squirtamt>0);
		for(int i=0;i<hitactors.size();i++){
			if(hitactors[i])hitactors[i].bnonshootable=false;
		}
		vector3 finalpos=caller.pos;
		caller.setorigin(originalpos,false);

		if(finalpos!=originalpos){
			int iii=int((finalpos-originalpos).length());
			vector3 trailpos=(0,0,0);
			vector3 vu=caller.vel.unit();
			vector3 vu2=vu*4;
			for(int i=0;i<iii;i++){
				trailpos+=vu;
				caller.A_SpawnParticle(
					"white",
					SPF_FULLBRIGHT,
					5,
					frandom(0.04,0.07)*(iii-i*0.5),
					caller.angle,
					trailpos.x+frandom(-12,12),trailpos.y+frandom(-12,12),trailpos.z+frandom(-12,12),
					vu2.x,vu2.y,vu2.z,
					0,0,0.6,
					sizestep:4
				);
			}
		}
	}
	
	override void tick(){
		ClearInterpolation();
		if(isfrozen())return;
		if(health<1){
			Kaboom(self);
			destroy();return;
		}
		if(!bmissile){
			hdactor.tick();return;
		}else if(fuze<180){
		    fuze++;
			keeprolling=vel;
			super.tick();
		}else{
			if(inthesky){
				Kaboom(self);
				destroy();return;
			}
			let gr=HDDynamiteRoller(spawn(rollertype,pos,ALLOW_REPLACE));
			gr.target=self.target;gr.master=self.master;gr.vel=self.vel;
			gr.fuze=fuze;
			destroy();return;
		}
	}
	
	override void postbeginplay(){
		hdactor.postbeginplay();
		divrad=1./(radius*1.9);
		grav=getgravity();
		A_StartSound("weapons/dyna_spoonoff",8);
	}
	
	states{
	spawn:
		DYNA GHIJ 2;
		loop;
	death:
		TNT1 A 10{
			bmissile=false;
			let gr=HDDynamiteRoller(spawn(rollertype,self.pos,ALLOW_REPLACE));
			if(!gr)return;
			gr.target=self.target;gr.master=self.master;
			gr.fuze=self.fuze;
			gr.vel=self.keeprolling;
			gr.keeprolling=self.keeprolling;
			gr.A_StartSound("weapons/dynaknock",CHAN_BODY);
			HDMobAI.Frighten(gr,256);
		}stop;
	}
}

//dummy spoon that exists just to play the fuse sfx
class HDDynaFuse:HDDebris{
	default{scale 0.3;bouncefactor 0.6;}
	
	override void postbeginplay(){
	    A_StartSound("weapons/dyna_spoonoff",8);
		super.postbeginplay();
	}
	
	states{
	spawn:
	death:
		stop;
	}
}

//unlit bundles you can toss to set off at your leisure
//can be picked back up later if you change your mind

class HDDynamiteRollerUnlit:HDUPK{//the projectile after it hits the ground
	int fuze;
	vector3 keeprolling;
	default{
		-noextremedeath 
		-floorclip 
		+shootable 
		+noblood 
		+forcexybillboard
		+activatemcross 
		-noteleport 
		+noblockmonst 
		+explodeonwater
		+missile 
		+bounceonactors 
		+usebouncestate
		
		hdupk.amount 1;
		hdupk.pickuptype "HDDynamiteAmmo";
		hdupk.pickupmessage "Picked up a bundle of dynamite.";
		hdupk.pickupsound "weapons/rifleclick2";
		stamina 1;
		
		health 10;
		
		bouncetype "doom";
		bouncesound "weapons/dynaknock";
		radius 8;
		height 8;
		damagetype "none";
		scale 0.3;
		obituary "%o was blown to smitheteens by %k.";
		radiusdamagefactor 0.04;
		pushfactor 1.4;
		maxstepheight 2;
		mass 30;
	}
	
	override bool used(actor user){
		return true;
	}
	
	//adding this so it doesn't phase through monsters or objects
	override bool cancollidewith(actor other,bool passive){
		return HDPickerUpper(other) || HDActor(other);
	}
	
	states{
	spawn:
		DYNA A 0;
	spawn2:
		#### BCDE 2{
			if(abs(vel.z-keeprolling.z)>10)A_StartSound("weapons/dynaknock",CHAN_BODY);
			else if(floorz>=pos.z)A_StartSound("weapons/dynaroll");
			keeprolling=vel;
			if(abs(vel.x)<0.4 && abs(vel.y)<0.4) setstatelabel("death");
		}loop;
	bounce:
		#### # 0{
			bmissile=false;
			vel*=0.3;
		}goto spawn2;
	death:
		#### # 2{
			if(abs(vel.z-keeprolling.z)>3){
				A_StartSound("weapons/dynaknock",CHAN_BODY);
				keeprolling=vel;
			}
			if(abs(vel.x)>0.4 || abs(vel.y)>0.4) setstatelabel("spawn");
		}wait;
	destroy:
		TNT1 A 1{
			bsolid=false;bpushable=false;bmissile=false;bnointeraction=true;bshootable=false;
			HDDynamite.Kaboom(self);
			HDDynamite.DynamiteShot(self,64);
			actor xpl=spawn("WallChunker",self.pos-(0,0,1),ALLOW_REPLACE);
				xpl.target=target;xpl.master=master;xpl.stamina=stamina;
			xpl=spawn("HDExplosion",self.pos-(0,0,1),ALLOW_REPLACE);
				xpl.target=target;xpl.master=master;xpl.stamina=stamina;
			A_SpawnChunks("BigWallChunk",14,4,12);
		}
		stop;
	}
	
	override void tick(){
		if(isfrozen())return;
		else if(bnointeraction){
			NextTic();
			return;
		}else{
			if(health >= 1)fuze=170;
			else fuze++;
			if(fuze>=180 && !bnointeraction){
				setstatelabel("destroy");
				NextTic();
				return;
			}else super.tick();
		}
	}
}

class HDDynamiteUnlit:HDDynamite{//the projectile when thrown
	default{+bounceonactors 
	        hddynamite.rollertype "HDDynamiteRollerUnlit";
	        }
	
	override void tick(){
		ClearInterpolation();
		if(isfrozen())return;
		if(health >= 1)fuze=170;
		if(health<1){
		//    fuze++;
			Kaboom(self);
			destroy();return;
		}
		if(!bmissile){
			hdactor.tick();return;
		}else if(fuze<180){
			keeprolling=vel;
			super.tick();
		}else{
			if(inthesky){
				destroy();return;
			}
			let gr=HDDynamiteRollerUnlit(spawn(rollertype,pos,ALLOW_REPLACE));
			gr.target=self.target;gr.master=self.master;gr.vel=self.vel;
			gr.fuze=170;
			destroy();return;//remove self and spawn roller
		}
	}
	
	override void postbeginplay(){
		hdactor.postbeginplay();
		divrad=1./(radius*1.9);
		grav=getgravity();
	}
	
	states{
	spawn:
		DYNA BCDE 2;
		loop;
	death:
		TNT1 A 10{
			bmissile=false;
			let gr=HDDynamiteRollerUnlit(spawn(rollertype,self.pos,ALLOW_REPLACE));
			if(!gr)return;
			gr.target=self.target;gr.master=self.master;
			gr.fuze=170;  
			gr.vel=self.keeprolling;
			gr.keeprolling=self.keeprolling;
			gr.A_StartSound("weapons/dynaknock",CHAN_BODY);
		}stop;
	}
}

class HDDynamiteAmmo:HDAmmo{
	default{
		//$Category "Ammo/Hideous Destructor/"
		//$Title "Dynamite"
		//$Sprite "DYNAA0"

		+forcexybillboard
		inventory.icon "DYNAA0";
		inventory.amount 1;
		scale 0.3;
		inventory.maxamount 50;
		inventory.pickupsound "weapons/pocket";
		tag "$TAG_DYNAMITEBUNDLE";
		hdpickup.refid "DYN";
		hdpickup.bulk ENC_DYNAMITE;
	}

	override string pickupmessage(){
		return Stringtable.Localize("$PICKUP_DYNAMITE");
	}
	
	//inv code borrowed from Melonades grenade pack
	override void AttachToOwner(Actor user)
	{
		if(!countinv("HDDynamites"))
		  user.GiveInventory("HDDynamites", 1);
		  
		super.AttachToOwner(user);
	}
	override void DetachFromOwner()
	{
		if(owner && owner.player && !(owner.player.ReadyWeapon is "HDDynamites"))
		{
			TakeInventory("HDDynamites", 1);
		}
		super.DetachFromOwner();
	}

	
	override bool IsUsed(){return true;}
	states{
	spawn:
		DYNA A -1;stop;
	}
}
class DynaP:HDUPK{
	default{
		+forcexybillboard
		scale 0.3;height 3;radius 3;
		hdupk.amount 1;
		hdupk.pickuptype "HDDynamiteAmmo";
		hdupk.pickupmessage "Picked up a bundle of dynamite.";
		hdupk.pickupsound "weapons/rifleclick2";
		stamina 1;
	}
	override void postbeginplay(){
		super.postbeginplay();
		pickupmessage=getdefaultbytype(pickuptype).pickupmessage();
	}
	states{
	spawn:
		DYNA A -1;
	}
}

class HDDynamitePickup:DynaP{
	override void postbeginplay(){
		super.postbeginplay();
		A_SpawnItemEx("DynaP",-4,0,flags:SXF_NOCHECKPOSITION);
		A_SpawnItemEx("DynaP",-4,4,flags:SXF_NOCHECKPOSITION);
		A_SpawnItemEx("DynaP",0,4,flags:SXF_NOCHECKPOSITION);
		A_SpawnItemEx("DynaP",4,0,flags:SXF_NOCHECKPOSITION);
		A_SpawnItemEx("DynaP",4,4,flags:SXF_NOCHECKPOSITION);
	}
}


class DynamitePlanted:DoorBusterPlanted{

override void postbeginplay(){
	    A_StartSound("weapons/dyna_spoonoff",8);
		super.postbeginplay();
	}
	
    override bool OnGrab(actor grabber){
		actor dbbb=spawn("HDDynamiteAmmo",pos,ALLOW_REPLACE);
		dbbb.translation=self.translation;
		GrabThinker.Grab(grabber,dbbb);
		destroy();
		return false;
	}
	states{
	spawn:
		DYNA F 180 A_DBStuck();
		goto death;
	unstucknow:
		---- A 2 A_StartSound("misc/fragknock",CHAN_BODY,CHANF_OVERLAP);
		---- A 1{
			actor dbs=spawn("HDDynamiteAmmo",pos,ALLOW_REPLACE);
			dbs.angle=angle;dbs.translation=translation;
			dbs.A_ChangeVelocity(1,0,0,CVF_RELATIVE);
			A_SpawnChunks("BigWallChunk",15);
			A_StartSound("weapons/bigcrack",CHAN_BODY,CHANF_OVERLAP);
		}
		stop;
	death:
		---- A 2 A_StartSound("misc/fragknock",CHAN_BODY,CHANF_OVERLAP);
		---- A 1{
			bnointeraction=true;
			int boost=min(accuracy*accuracy,256);
			bool busted=doordestroyer.destroydoor(self,70+boost,16+boost,dedicated:true);//original is 140,32

			A_SprayDecal(busted?"Scorch":"BrontoScorch",16);
        
			A_StartSound("weapons/bigcrack",CHAN_BODY,CHANF_OVERLAP);
			A_StartSound("world/explode",CHAN_VOICE,CHANF_OVERLAP);

			target=master;
			A_AlertMonsters();

			A_SpawnChunks("HDExplosion",busted?1:6,0,1);
			if(!busted){
				A_ChangeVelocity(-7,0,1,CVF_RELATIVE);
				A_SpawnChunks("HugeWallChunk",20,1,30);
				DistantQuaker.Quake(self,4,35,512,10);
				A_HDBlast(
					pushradius:256,pushamount:64,fullpushradius:64,
					fragradius:HDCONST_ONEMETRE*18,fragtype:"HDB_scrapDB"
				);
				A_Explode(50,32);
				A_Blast(5,16);
			}else{
				DistantQuaker.Quake(self,2,35,256,10);
				A_HDBlast(
					pushradius:128,pushamount:64,fullpushradius:32, 
					fragradius:HDCONST_ONEMETRE*10,fragtype:"HDB_scrapDB"
				);
				A_Explode(50,32);
				A_Blast(5,16);
			}
		}
		stop;
	}
}
