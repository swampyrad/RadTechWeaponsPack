//------------------------------------------------------------------------------
// Beware! I live..!
//------------------------------------------------------------------------------
enum flaregunstatus
{
	FLARE_LOADED=1,
	FLARE_JUSTUNLOAD=2,
	FLARE_STATUS=0,
	FLARE_LOADEDSHELL=2,
	FLARE_SPENTSHELL=4,
	FLARE_LOADEDSLUG=8,
	FLARE_SPENTSLUG=16,
	FLARE_LOADEDSLUGEXP=32,
	FLARE_SPENTSLUGEXP=64,
	FLARE_METAL=26,
};

//dummy bullet, used to transfer weapon pitch to flare ball
//(using the same hack as the plasma rifle because
// i'm too dumb ro figure out a better way

class HDB_FlareMissile:HDBulletActor{
    
    default{speed 32;}
    
	states{
	spawn:
		TNT1 A 0;
	death:
	    TNT1 A 0 A_SpawnItemEx(
	                "HDFlareBall",
	                0, 0, 0,
                    invoker.vel.x,
                    invoker.vel.y,
                    invoker.vel.z,
                    invoker.angle,
	                SXF_TRANSFERPOINTERS);
		stop;
	}
}

class FireBlooper : HDHandgun
{
	bool destroyed;
	default
	{
		//$Category "Weapons/Hideous Destructor"
		//$Title "Flare Launcher"
		//$Sprite "FLGNA0"

		+hdweapon.fitsinbackpack
		weapon.selectionorder 93;
		weapon.slotnumber 3;//flare pistol
		weapon.slotpriority 0.3; // It's mostly a backup weapon, it shouldn't have a 9 for slot priority. - [Ted]
		scale 0.5;
		obituary "$OB_FLAREGUN";
		hdweapon.barrelsize 24,1.6,3;
		tag "$TAG_FLAREGUN";
		hdweapon.refid "fgn";
	}
	override string pickupmessage(){
		return Stringtable.Localize("$PICKUP_PLASTICFLAREGUN");
	}

	override bool AddSpareWeapon(actor newowner){return AddSpareWeaponRegular(newowner);}
	override hdweapon GetSpareWeapon(actor newowner,bool reverse,bool doselect){return GetSpareWeaponRegular(newowner,reverse,doselect);}

//this code triggers the hand swap mechanic
action void A_SwapFlareguns(){
		let mwt=SpareWeapons(findinventory("SpareWeapons"));
		if(!mwt){
			setweaponstate("whyareyousmiling");
			return;
		}
		int fgunindex=mwt.weapontype.find(invoker.getclassname());
		if(fgunindex==mwt.weapontype.size()){
			setweaponstate("whyareyousmiling");
			return;
		}
		A_WeaponBusy();

		array<string> wepstat;
		string wepstat2="";
		mwt.weaponstatus[fgunindex].split(wepstat,",");
		for(int i=0;i<wepstat.size();i++){
			if(i)wepstat2=wepstat2..",";
			wepstat2=wepstat2..invoker.weaponstatus[i];
			invoker.weaponstatus[i]=wepstat[i].toint();
		}
		mwt.weaponstatus[fgunindex]=wepstat2;

		invoker.wronghand=!invoker.wronghand;
	}

//this code checks for which sprite index to use for each hand
action void A_CheckFlareGunHand(bool filled)
{
		if(invoker.wronghand && filled)
		{
			player.getpsprite(PSP_WEAPON).sprite=getspriteindex("FBR1A0");
		}
		else if(invoker.wronghand && !filled)
		{
			player.getpsprite(PSP_WEAPON).sprite=getspriteindex("FBR2A0");
		}
		else if(!(invoker.wronghand) && filled)
		{
			player.getpsprite(PSP_WEAPON).sprite=getspriteindex("FBL1A0");
		}
		else if(!(invoker.wronghand) && !filled)
		{
			player.getpsprite(PSP_WEAPON).sprite=getspriteindex("FBL2A0");
		}
}

	action int A_GetFrameIndex()
	{
		int result = 0;
		if(!invoker.weaponstatus[0]&FLARE_LOADED)
		{
		 result = 1;
		}
		return result;
	}

	override double gunmass()
	{
		double result = 5;
		if(weaponstatus[0]&FLARE_LOADED)
			result += 1;
		else if(weaponstatus[0]&FLARE_LOADEDSHELL)
			result += 2;
		return result;
	}

	override double weaponbulk()
	{
		double result = 24;//the flaregun itself
		
		if(weaponstatus[0]&FLARE_LOADED)//flare shell
			result += ENC_SHELL/2;
		else if(weaponstatus[0]&FLARE_LOADEDSHELL)//shotgun shell
			result += ENC_SHELL;
		else if(weaponstatus[0]&FLARE_SPENTSHELL)//spent shells
			result += ENC_SHELL/3;
		return result;
	}

	override string,double getpickupsprite(bool usespare)
	{
		string result = "FLGN";
		string index  = "B0";
		if((GetSpareWeaponValue(0, usespare)&FLARE_LOADED))
			index  = "A0";
		else if((GetSpareWeaponValue(0, usespare)&FLARE_LOADEDSHELL))
			index  = "A0";
		return result..index,1.;
	}
	
	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl)
	{
		if(sb.hudlevel==1)
		{//toggle alternate ammo counters for slugs
		    
			sb.drawimage("FLARA0",(-47,-4),sb.DI_SCREEN_CENTER_BOTTOM,scale:(0.6,0.6));
			sb.drawnum(hpl.countinv("HDFlareAmmo"),-40,-8,sb.DI_SCREEN_CENTER_BOTTOM);
				
			sb.drawimage("SHL1A0",(-30,-4),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1.4,1.4));
			sb.drawnum(hpl.countinv("HDShellAmmo"),-25,-8,sb.DI_SCREEN_CENTER_BOTTOM);
		    
		}
		if(hdw.weaponstatus[0]&FLARE_LOADED)
		{
			sb.drawrect(-24,-13,7,3);
		}
		else if(hdw.weaponstatus[0]&FLARE_LOADEDSHELL)
		{
			sb.drawrect(-24,-13,5,3);
			sb.drawrect(-18,-13,2,3);
		}
		else if(hdw.weaponstatus[0]&FLARE_SPENTSHELL)
		{
			sb.drawrect(-18,-13,2,3);
		}
	}
	
	override void DrawSightPicture(
		HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl,
		bool sightbob,vector2 bob,double fov,bool scopeview,actor hpc
	)
	{
	sb.drawimage(
				"fbpsite",(0,+4)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_CENTER,
				scale:(1.2, 1.2)
	);
	}
	
	override string gethelptext()
	{
		return
		WEPHELP_FIRESHOOT
		..WEPHELP_ALTFIRE..", "..WEPHELP_FIREMODE.."  Quick-Swap (if available)\n"
		..WEPHELP_RELOAD.."  Load flares\n"
		..WEPHELP_ALTRELOAD.."  Load shells\n"
		..WEPHELP_FIREMODE.."+"..WEPHELP_RELOAD.."  Load slugs\n"
		..WEPHELP_FIREMODE.."+"..WEPHELP_ALTRELOAD.."  Load explosive slugs\n"
		..WEPHELP_UNLOADUNLOAD
		;
	}
	
	
	bool A_IsFilled()
	{
		return self.weaponstatus[0]==FLARE_LOADED   ||
		self.weaponstatus[0]==FLARE_LOADEDSHELL     ||
		self.weaponstatus[0]==FLARE_LOADEDSLUG      ||
		self.weaponstatus[0]==FLARE_LOADEDSLUGEXP;
	}
	
	
	
	action void A_FireFlare()
	{
		
			A_StartSound("weapons/fgnblast", CHAN_WEAPON,CHANF_OVERLAP);
			HDBulletActor.FireBullet(self,"HDB_FlareMissile");
			
			invoker.weaponstatus[0]&=~FLARE_LOADED;
			A_MuzzleClimb(-frandom(2.,2.7),-frandom(3.4,5.2));
			A_StartSound("weapons/fgnclk",CHAN_WEAPON,CHANF_OVERLAP);
			for(int i=0;i<5;i++)A_SpawnItemEx("FourMilChunk",0,0,invoker.owner.height * 0.80,
				random(4,7),random(-2,2),random(-2,1),0,SXF_NOCHECKPOSITION
			);
			A_AlertMonsters();
	}
	
	action void A_FireShell()
	{
			invoker.weaponstatus[0]&=~FLARE_LOADEDSHELL;
			HDBulletActor.FireBullet(self,"HDB_wad");
			let sss=HDBulletActor.FireBullet(self,"HDB_00",
			spread:35,speedfactor:1,amount:10
			);
			distantnoise.make(sss,"weapons/flaregun_shellfar");
			self.A_StartSound("weapons/flaregun_shellfire",CHAN_WEAPON);
			invoker.weaponstatus[0]=FLARE_SPENTSHELL;
			A_MuzzleClimb(-frandom(2.,2.7),-frandom(3.4,5.2));
			A_AlertMonsters();
	}
	
	action void A_FireSlug()
	{
			invoker.weaponstatus[0]&=~FLARE_LOADEDSLUG;
			
			HDBulletActor.FireBullet(self,"HDB_wad");
			let sss=HDBulletActor.FireBullet(self,"HDB_Slug",
			spread:3,speedfactor:1,amount:1
			);
			distantnoise.make(sss,"weapons/flaregun_shellfar");
			self.A_StartSound("weapons/flaregun_shellfire",CHAN_WEAPON);
			invoker.weaponstatus[0]=FLARE_SPENTSLUG;
			A_MuzzleClimb(-frandom(2.,2.7),-frandom(3.4,5.2));
			A_AlertMonsters();
	}
	
    action void A_FireHell()
	{
			invoker.weaponstatus[0]|=FLARE_SPENTSLUGEXP;
			
			HDBulletActor.FireBullet(self,"HDB_wad");
			let sss=HDBulletActor.FireBullet(self,"HDB_12GuageSlugMissile",
			spread:3,speedfactor:1,amount:1
			);
			
			//flinching code borrowed from Brontornis
			IsMoving.Give(self,gunbraced()?2:7);
					if(
					  !binvulnerable
					  &&(
						floorz<pos.z
						||IsMoving.Count(self)>6
					  )
					){
						givebody(max(0,5-health));
						damagemobj(invoker,self,5,"bashing");
						IsMoving.Give(self,3);
					}
			
			distantnoise.make(sss,"weapons/flaregun_shellfar");
			self.A_StartSound("weapons/flaregun_shellfire",CHAN_WEAPON);
			A_MuzzleClimb(-frandom(2.,2.7),-frandom(3.4,5.2));
			A_AlertMonsters();
	}


//the damn thing explodes when you do this,
//of course the damage output is going to suffer
action void A_FireShellPlastic()
	{
	   		invoker.weaponstatus[0]=FLARE_SPENTSHELL; 
	   		
			HDBulletActor.FireBullet(self,"HDB_wad");
			let sss=HDBulletActor.FireBullet(self,"HDB_00",
			spread:35,speedfactor:frandom(0.5,0.6),amount:10);
			distantnoise.make(sss,"weapons/flaregun_shellfar");
			self.A_StartSound("weapons/flaregun_shellfire",CHAN_WEAPON);
			A_MuzzleClimb(-frandom(2.,2.7),-frandom(3.4,5.2));
	}

//because firing  
//shotgun shells in a plastic
//gun is really dumb
action void A_Backfire()
  	{
   self.damagemobj(self,self,5,"hot",DMG_NO_ARMOR);
  }

	override void loadoutconfigure(string input){

		int shellround=getloadoutvar(input,"shell",1);
		if(shellround>0)
			weaponstatus[0]=FLARE_LOADEDSHELL;
		else
			weaponstatus[0]=FLARE_LOADED;
	}
	
	override void InitializeWepStats(bool idfa)
	{
		weaponstatus[0]=FLARE_LOADED;
		
		// Nothing to see here, move along. 
		weaponstatus[2]=0;
	}


	States
	{

	select0:
		FBL1 A 0;
		FBL1 B 0;
		FBL2 A 0;
		FBL2 B 0;
		FBR1 A 0;
		FBR1 B 0;
		FBR2 A 0;
		FBR2 B 0;
		FBL1 A 0;
		#### A 0
		{
			A_CheckFlareGunHand(invoker.A_IsFilled());
		}
		#### A 1;
		#### A 1;
		goto select0small;

	deselect0:
	deselect0real:
		FBL1 A 0;
		#### A 0
		{
			A_CheckFlareGunHand(invoker.A_IsFilled());
		}
		#### A 1;
		goto deselect0small;

	ready:
		FBL1 A 0;
		#### A 0
		{
			A_CheckFlareGunHand(invoker.A_IsFilled());
		}
	ReadyReal:
		#### A 0 A_SetCrosshair(21);
		#### A 1
		{
			A_WeaponReady(WRF_ALL);
		}
		goto readyend;


	hold:

	fire:
		#### A 0 A_JumpIf(invoker.weaponstatus[0]==FLARE_LOADEDSHELL,"reallyshootshell");
		#### A 0 A_JumpIf(invoker.weaponstatus[0]==FLARE_LOADED,"reallyshoot");
		goto nope;



	reallyshootshell:
		//shoot a fireball
		#### A 2 offset(0,37)
		{
			A_FireShellPlastic();
			A_CheckFlareGunHand(invoker.A_IsFilled());
		}
		#### A 1;
		#### A 0;
		// NOO! OUR FLAREGUN! IT'S BROKEN!!!
		#### A 0;
		goto diediedie;
		
	//i think it finally works!!!
	reallyshoot:
		//shoot a fireball
		#### A 2 offset(0,37)
		{
			A_FireFlare();
			A_CheckFlareGunHand(invoker.A_IsFilled());
		}
		#### A 1;
		#### A 0;
		goto nope;


	
	altreload:
		#### A 0 A_JumpIf(
		invoker.weaponstatus[0]&FLARE_LOADED      ||
		invoker.weaponstatus[0]&FLARE_LOADEDSHELL ||
		invoker.weaponstatus[0]&FLARE_SPENTSHELL  ||
		!countinv("HDShellAmmo"), "nope");
		#### A 1 offset(2,36)A_StartSound("weapons/fgnrel1",8);
		#### A 1 offset(4,42)A_MuzzleClimb(-frandom(1.2,2.4),frandom(1.2,2.4));
		#### A 1 offset(10,50);
		#### A 2 offset(12,60)A_MuzzleClimb(-frandom(1.2,2.4),frandom(1.2,2.4));
		#### A 1 offset(13,72) A_StartSound("weapons/fgnrel2",8,CHANF_OVERLAP);
		#### A 1 offset(14,74);
		#### A 1 offset(11,76)A_StartSound("weapons/fgnrel3",9);
		#### A 3 offset(10,72);
		FBL1 B 0
		{
			A_CheckFlareGunHand(invoker.A_IsFilled());
			if(health<40)A_SetTics(7);
			else if(health<60)A_SetTics(6);
		}
		#### B 2 offset(12,74) A_StartSound("weapons/fgnrel1",8);
		#### B 1 offset(10,72)
		{
			A_TakeInventory("HDShellAmmo",1,TIF_NOTAKEINFINITE);
			invoker.weaponstatus[0]|=FLARE_LOADEDSHELL;
			A_SetTics(5);
		}
		goto reloadend;



	unload:
		#### A 0
		{
			if
			(
			invoker.weaponstatus[0]&FLARE_LOADED      ||
			invoker.weaponstatus[0]&FLARE_LOADEDSHELL ||
			invoker.weaponstatus[0]&FLARE_SPENTSHELL
			)
			{
				invoker.weaponstatus[1]|=FLARE_JUSTUNLOAD;
			}
			else
			{
				setweaponstate("nope");
			}
		}
		#### A 1 offset(2,36)A_StartSound("weapons/fgnrel1",8);
		#### A 1 offset(4,42)A_MuzzleClimb(-frandom(1.2,2.4),frandom(1.2,2.4));
		#### A 1 offset(10,50);
		#### A 2 offset(12,60)A_MuzzleClimb(-frandom(1.2,2.4),frandom(1.2,2.4));
		#### A 1 offset(13,72) A_StartSound("weapons/fgnrel2",8,CHANF_OVERLAP);
		#### A 1 offset(14,74);
		#### A 1 offset(11,76)A_StartSound("weapons/fgnrel3",9);
		#### A 3 offset(10,72);
		FBL2 A 0
		{
			A_CheckFlareGunHand(invoker.A_IsFilled());
			if(health<40)A_SetTics(3);
			else if(health<60)A_SetTics(2);
		}
		#### B 2 offset(12,74) A_StartSound("weapons/fgnrel1",8);
		#### B 1 offset(10,72)
		{
			if(invoker.weaponstatus[1]&FLARE_JUSTUNLOAD)
			{
				// Unset unload state. 
				invoker.weaponstatus[1]&=~invoker.weaponstatus[1];
					
				// Toss ammo if not pressing anything. 
				if(
					(!PressingUnload()&&!PressingReload())    ||
					A_JumpIfInventory("HDFlareAmmo",0,"null") ||
					A_JumpIfInventory("HDShellAmmo",0,"null") ||
					invoker.weaponstatus[0]&FLARE_SPENTSHELL
				)
				{
					if(!(invoker.weaponstatus[0]&~FLARE_SPENTSHELL))
						A_SpawnItemEx("HDSpentShell",10,0,height-16,vel.x,vel.y,vel.z+2,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION);
					else if(!(invoker.weaponstatus[0]&~FLARE_LOADED))
						A_SpawnItemEx("HDFlareAmmo",10,0,height-16,vel.x,vel.y,vel.z+2,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION);
					else if(!(invoker.weaponstatus[0]&~FLARE_LOADEDSHELL))
						A_SpawnItemEx("HDShellAmmo",10,0,height-16,vel.x,vel.y,vel.z+2,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION);
					
					// Unset current ammo type. 
					invoker.weaponstatus[0]&=~invoker.weaponstatus[0];
				}
				// Pocket ammo if pressing a key. 
				else
				{
					if(!(invoker.weaponstatus[0]&~FLARE_LOADED))
					{
						A_GiveInventory("HDFlareAmmo",1);
						A_StartSound("weapons/pocket",9);
						A_SetTics(4);
					}
					else if(!(invoker.weaponstatus[0]&~FLARE_LOADEDSHELL))
					{
						A_GiveInventory("HDShellAmmo",1);
						A_StartSound("weapons/pocket",9);
						A_SetTics(4);
					}
					// Unset current ammo type. 
					invoker.weaponstatus[0]&=~invoker.weaponstatus[0];
				}
			}
		
		}
		#### A 0;
		goto reloadend;



	reload:
		#### A 0 A_JumpIf(
		invoker.weaponstatus[0]&FLARE_LOADED      ||
		invoker.weaponstatus[0]&FLARE_LOADEDSHELL ||
		invoker.weaponstatus[0]&FLARE_SPENTSHELL  ||
		!countinv("HDFlareAmmo"), "nope");
		#### A 1 offset(2,36)A_StartSound("weapons/fgnrel1",8);
		#### A 1 offset(4,42)A_MuzzleClimb(-frandom(1.2,2.4),frandom(1.2,2.4));
		#### A 1 offset(10,50);
		#### A 2 offset(12,60)A_MuzzleClimb(-frandom(1.2,2.4),frandom(1.2,2.4));
		#### A 1 offset(13,72) A_StartSound("weapons/fgnrel2",8,CHANF_OVERLAP);
		#### A 1 offset(14,74);
		#### A 1 offset(11,76)A_StartSound("weapons/fgnrel3",9);
		#### A 3 offset(10,72);
		FBL1 A 0
		{
			A_CheckFlareGunHand(invoker.A_IsFilled());
			if(health<40)A_SetTics(3);
			else if(health<60)A_SetTics(2);
		}
		#### B 2 offset(12,74) A_StartSound("weapons/fgnrel1",8);
		#### B 1 offset(10,72)
		{
			A_TakeInventory("HDFlareAmmo",1,TIF_NOTAKEINFINITE);
			invoker.weaponstatus[0]|=FLARE_LOADED;
			A_SetTics(5);
		}
		goto reloadend;
		
		
		
	reloadend:
		#### A 1 offset(12,80);
		#### A 1 offset(11,88);
		#### A 1 offset(10,90) A_StartSound("weapons/fgnrel2",8);
		#### A 1 offset(10,94);
		TNT1 A 2;
		FBL1 A 0
		{
			A_CheckFlareGunHand(invoker.A_IsFilled());
			A_StartSound("weapons/fgnrel1",8,CHANF_OVERLAP);
		}
		#### A 1 offset(8,78);
		#### A 1 offset(8,66);
		#### A 1 offset(8,52);
		#### A 1 offset(4,40);
		#### A 1 offset(2,34);
		goto ready;


//firemode:
altfire:
swappistols:
		---- A 0 A_SwapFlareguns();
		---- A 0{
			bool id=(Wads.CheckNumForName("id",0)!=-1);
			bool offhand=invoker.wronghand;
			bool lefthanded=(id!=offhand);
			if(lefthanded){
				A_Overlay(1025,"raiseleft");
				A_Overlay(1026,"lowerright");
			}else{
				A_Overlay(1025,"raiseright");
				A_Overlay(1026,"lowerleft");
			}
		}
		TNT1 A 5;
		FBL1 A 0
		{
			A_CheckFlareGunHand(invoker.A_IsFilled());
		}
		goto nope;
	lowerleft:
		FBL1 A 0;
		#### A 0
		{
			A_CheckFlareGunHand(invoker.A_IsFilled());
		}
		#### A 1 offset(-6,38);
		#### A 1 offset(-12,48);
		#### A 1 offset(-20,60);
		#### A 1 offset(-34,76);
		#### A 1 offset(-50,86);
		stop;
	lowerright:
		FBL1 A 0;
		#### A 0
		{
			A_CheckFlareGunHand(invoker.A_IsFilled());
		}
		#### A 1 offset(6,38);
		#### A 1 offset(12,48);
		#### A 1 offset(20,60);
		#### A 1 offset(34,76);
		#### A 1 offset(50,86);
		stop;
	raiseleft:
		FBL1 A 0;
		#### A 0
		{
			A_CheckFlareGunHand(invoker.A_IsFilled());
		}
		#### A 1 offset(-50,86);
		#### A 1 offset(-34,76);
		#### A 1 offset(-20,60);
		#### A 1 offset(-12,48);
		#### A 1 offset(-6,38);
		stop;
	raiseright:
		FBL1 A 0;
		#### A 0
		{
			A_CheckFlareGunHand(invoker.A_IsFilled());
		}
		#### A 1 offset(50,86);
		#### A 1 offset(34,76);
		#### A 1 offset(20,60);
		#### A 1 offset(12,48);
		#### A 1 offset(6,38);
		stop;
	whyareyousmiling:
		#### A 1 offset(0,48);
		#### A 1 offset(0,60);
		#### A 1 offset(0,76);
		TNT1 A 7;
		#### A 0
		{
			invoker.wronghand=!(invoker.wronghand);
			A_CheckFlareGunHand(invoker.A_IsFilled());
		}
		#### A 1 offset(0,76);
		#### A 1 offset(0,60);
		#### A 1 offset(0,48);
		goto nope;
	
	
	diediedie:
		---- A 0
		{
			A_StartSound("weapons/fgnclk",CHAN_WEAPON,CHANF_OVERLAP);

			for(int i=0;i<30;i++)A_SpawnItemEx("FourMilChunk",0,0,invoker.owner.height * 0.80,
				random(4,7),random(-2,2),random(-2,1),0,SXF_NOCHECKPOSITION
			);
    A_Backfire();
			A_SpawnItemEx("HDSpentShell",0,0,invoker.owner.height * 0.80,
				-random(4,7),-random(-2,2),-random(-2,1),0,SXF_NOCHECKPOSITION
			);
			invoker.destroyed = true;
			player.cmd.buttons|=BT_ZOOM;
			DropInventory(player.readyweapon);
		}
		TNT1 A 0;
		goto spawndie;
	spawn:
		FLGN A -1 nodelay
		{
			frame = invoker.A_GetFrameIndex();
		}
		stop;
		
	spawndie:
		TNT1 A -1
		{
			if(invoker.destroyed)
				invoker.destroy();
		}
		stop;
	}
}
