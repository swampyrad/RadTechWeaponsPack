// ------------------------------------------------------------
// "Frag Cannon" Frag Grenade Launcher
// ------------------------------------------------------------

class FragCannon:HDWeapon{
	default{
		//$Category "Weapons/Hideous Destructor"
		//$Title "Frag Grenade Launcher"
		//$Sprite "BLOPA0"

		+weapon.explosive
		+hdweapon.fitsinbackpack
		weapon.selectionorder 93;
		weapon.slotnumber 5;
		weapon.slotpriority 4;
		scale 0.6;
		obituary "$OB_FRAGCANNON";
		hdweapon.barrelsize 24,1.6,3;
		tag "$TAG_FRAGCANNON";
		hdweapon.refid "FCN";
	}
	
	override string pickupmessage(){
		return Stringtable.Localize("$PICKUP_FRAGCANNON");
	}
	
	override bool AddSpareWeapon(actor newowner){return AddSpareWeaponRegular(newowner);}
	override hdweapon GetSpareWeapon(actor newowner,bool reverse,bool doselect){return GetSpareWeaponRegular(newowner,reverse,doselect);}
	override double gunmass(){
		return weaponstatus[0]&BLOPF_LOADED?6:4;
	}
	override double weaponbulk(){
		return 60+(weaponstatus[0]&BLOPF_LOADED?ENC_FRAG:0);
	}
	override string,double getpickupsprite(){return "FGCNA0",1.;}
	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
			sb.drawimage("FRAGA0",(-52,-4),sb.DI_SCREEN_CENTER_BOTTOM,scale:(0.6,0.6));
			sb.drawnum(hpl.countinv("HDFragGrenadeAmmo"),-45,-8,sb.DI_SCREEN_CENTER_BOTTOM);
		}
		if(hdw.weaponstatus[0]&BLOPF_LOADED)sb.drawrect(-21,-13,5,3);
	
		sb.drawwepnum(
			hpl.countinv("HDFragGrenadeAmmo"),
			(HDCONST_MAXPOCKETSPACE/ENC_FRAG)
		);
	}
	override string gethelptext(){
		LocalizeHelp();
		return
		LWPHELP_FIRESHOOT
		..LWPHELP_RELOADRELOAD
		..LWPHELP_UNLOADUNLOAD
		;
	}
	override void DrawSightPicture(
		HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl,
		bool sightbob,vector2 bob,double fov,bool scopeview,actor hpc
	){
		sb.drawgrenadeladder(hdw.airburst,bob);
	}
	override void DropOneAmmo(int amt){
		if(owner){
			amt=clamp(amt,1,10);
			owner.A_DropInventory("HDFragGrenadeAmmo",1);
		}
	}
	override void ForceBasicAmmo(){
		owner.A_SetInventory("HDFragGrenadeAmmo",1);
	}
	
	//code borrowed from Frag Grenade
    void FireGrenade(){
		if(!owner)return;
		int garbage;actor ggg;
		double cpp=cos(owner.pitch);
		double spp=sin(owner.pitch);

		//create the spoon
		if(!(weaponstatus[0]&FRAGF_SPOONOFF)){
			[garbage,ggg]=owner.A_SpawnItemEx(
				"HDFragSpoon",cpp*-4,-3,owner.height*0.88-spp*-4,
				cpp*3,0,-sin(owner.pitch+random(10,20))*3,
				frandom(33,45),SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
			);
			ggg.vel+=owner.vel;
		}

		//create the grenade
		[garbage,ggg]=owner.A_SpawnItemEx("HDFragGrenade",
			0,0,owner.height*0.88,
			cpp*4,
			0,
			-spp*4,
			0,SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
		);
		ggg.vel+=owner.vel;

		//force calculation
		double gforce=90;//pre-set force
	//	if(hdplayerpawn(owner))gforce*=hdplayerpawn(owner).strength;
    //  do not factor player strength, the cannon deals with it

		let grenade=HDFragGrenade(ggg);if(!grenade)return;
		grenade.fuze=weaponstatus[FRAGS_TIMER];

//		if(owner.player){
//			grenade.vel+=gforce;
//		}
		
		grenade.a_changevelocity(
			cpp*gforce*0.6,
			0,
			-spp*gforce*0.6,
			CVF_RELATIVE
		);
		
		weaponstatus[FRAGS_TIMER]=0;
		weaponstatus[FRAGS_FORCE]=0;
		weaponstatus[0]&=~FRAGF_PINOUT;
		weaponstatus[0]&=~FRAGF_SPOONOFF;
		weaponstatus[FRAGS_REALLYPULL]=0;

		weaponstatus[0]&=~FRAGF_INHAND;
		weaponstatus[0]|=FRAGF_JUSTTHREW;
	}
	
	states{
	select0:
		FCNN A 0;
		goto select0small;
	deselect0:
		FCNN A 0;
		goto deselect0small;

	ready:
		FCNN A 1 A_WeaponReady(WRF_ALL);
		goto readyend;
	hold:
	altfire:
	firemode:
		goto nope;

	fire:
		---- A 0 A_JumpIf(invoker.weaponstatus[0]&BLOPF_LOADED,"reallyshoot");
		goto nope;
	reallyshoot:
		---- A 1{
			A_ZoomRecoil(0.9);
			invoker.FireGrenade();
			invoker.weaponstatus[0]&=~BLOPF_LOADED;
			A_StartSound("weapons/fragcannon",8);
		}
		---- A 1 offset(0,34);
		---- A 0 A_MuzzleClimb(-frandom(2.,2.7),-frandom(3.4,5.2));
		goto nope;
	loadcommon:
		---- A 1 offset(2,34)A_StartSound("weapons/fragcannon_open",8,CHANF_OVERLAP);
		---- A 1 offset(4,38)A_MuzzleClimb(-frandom(1.2,2.4),frandom(1.2,2.4));
		---- A 1 offset(10,44);
		---- A 2 offset(12,50)A_MuzzleClimb(-frandom(1.2,2.4),frandom(1.2,2.4));
		---- A 3 offset(13,55) A_StartSound("weapons/fragcannon_open2",8,CHANF_OVERLAP);
		---- A 3 offset(14,60);
		---- A 3 offset(11,64)A_StartSound("weapons/pocket",9);
		---- A 7 offset(10,66);
		---- A 0{
			if(health<40)A_SetTics(7);
			else if(health<60)A_SetTics(3);
		}
		---- D 4 offset(12,68) A_StartSound("weapons/fragcannon_reload",8);
		---- D 2 offset(10,66){
			if(invoker.weaponstatus[0]&BLOPF_JUSTUNLOAD){
				if(
					!(invoker.weaponstatus[0]&BLOPF_LOADED)
				)setweaponstate("reloadend");else{
					invoker.weaponstatus[0]&=~BLOPF_LOADED;
					if(
						(!PressingUnload()&&!PressingReload())
						||A_JumpIfInventory("HDFragGrenadeAmmo",0,"null")
					)
					A_SpawnItemEx(
						"HDFragGrenadeAmmo",10,0,height-16,vel.x,vel.y,vel.z+2,
						0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION
					);
					else{
						A_GiveInventory("HDFragGrenadeAmmo",1);
						A_StartSound("weapons/pocket",9);
						A_SetTics(4);
					}
				}
			}else{
				if(
					invoker.weaponstatus[0]&BLOPF_LOADED
					||!countinv("HDFragGrenadeAmmo")
				)setweaponstate("reloadend");else{
					A_TakeInventory("HDFragGrenadeAmmo",1,TIF_NOTAKEINFINITE);
					invoker.weaponstatus[0]|=BLOPF_LOADED;
					A_SetTics(5);
				}
			}
		}
	reloadend:
		---- D 1 offset(12,68) A_StartSound("weapons/fragcannon_open2",8);
		---- D 1 offset(11,70);
		---- D 4 offset(10,69);
		---- D 0 A_StartSound("weapons/fragcannon_open",8,CHANF_OVERLAP);
		---- D 1 offset(9,66);
		---- D 1 offset(9,60);
		---- C 1 offset(8,53);
		---- C 1 offset(8,48);
		---- C 1 offset(6,43);
		---- B 1 offset(4,38);
		---- B 1 offset(2,34);
		goto ready;
	altreload:
	reload:
		---- B 0 A_JumpIf(
			invoker.weaponstatus[0]&BLOPF_LOADED
			||!countinv("HDFragGrenadeAmmo"),
			"nope"
		);
		---- B 0{
			if(
				invoker.weaponstatus[0]&BLOPF_LOADED
				||!countinv("HDFragGrenadeAmmo")
			)setweaponstate("nope");else{
				invoker.weaponstatus[0]&=~BLOPF_JUSTUNLOAD;
			}
		}goto loadcommon;
	unload:
		---- B 0{
			if(
				!(invoker.weaponstatus[0]&BLOPF_LOADED)
			)setweaponstate("nope");else{
				invoker.weaponstatus[0]|=BLOPF_JUSTUNLOAD;
			}
		}goto loadcommon;

	spawn:
		FGCN A -1;
	}
	override void loadoutconfigure(string input){
		//there isn't actually anything to configure,
		//but we need this to keep it loaded
		weaponstatus[0]|=BLOPF_LOADED;
	}
	override void InitializeWepStats(bool idfa){
		weaponstatus[0]|=BLOPF_LOADED;
		if(!idfa && !owner){
			airburst=0;
		}
	}
}

class FragCannonPickup:DynaP{
	override void postbeginplay(){
		super.postbeginplay();
		A_SpawnItemEx("HDFragGrenadeAmmo",-4,0,flags:SXF_NOCHECKPOSITION);
		A_SpawnItemEx("HDFragGrenadeAmmo",-4,4,flags:SXF_NOCHECKPOSITION);
		A_SpawnItemEx("FragCannon",0,4,flags:SXF_NOCHECKPOSITION);
		A_SpawnItemEx("HDFragGrenadeAmmo",4,0,flags:SXF_NOCHECKPOSITION);
		A_SpawnItemEx("HDFragGrenadeAmmo",4,4,flags:SXF_NOCHECKPOSITION);
	}
}

/*
enum bloopstatus{
	BLOPF_LOADED=1,
	BLOPF_JUSTUNLOAD=2,

	BLOPS_STATUS=0,
	BLOPS_AIRBURST=1,
};
*/
