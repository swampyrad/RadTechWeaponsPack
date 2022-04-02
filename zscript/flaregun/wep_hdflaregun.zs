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
	FLARE_METAL=26,
};


class FireBlooper : HDWeapon
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
		weapon.slotpriority 3;
		scale 0.6;
		inventory.pickupmessage "You got the flare gun! It's like christmas morning...";
		obituary "%o was set ablaze by %k.";
		hdweapon.barrelsize 24,1.6,3;
		tag "Flare Gun";
		hdweapon.refid "fgn";
	}

	override bool AddSpareWeapon(actor newowner){return AddSpareWeaponRegular(newowner);}
	override hdweapon GetSpareWeapon(actor newowner,bool reverse,bool doselect){return GetSpareWeaponRegular(newowner,reverse,doselect);}

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
			result += 1;
		return result;
	}

	override double weaponbulk()
	{
		double result = 24;
		if(weaponstatus[0]&FLARE_LOADED)
			result += ENC_SHELL;
		else if(weaponstatus[0]&FLARE_LOADEDSHELL)
			result += ENC_SHELL/2;
		else if(weaponstatus[0]&FLARE_SPENTSHELL)
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

		/*
	override string,double getpickupsprite()
	{
		string result = "FLGN";
		string index  = "B0";
		if((weaponstatus[0]&FLARE_LOADED))
			index  = "A0";
		else if((weaponstatus[0]&FLARE_LOADEDSHELL))
			index  = "A0";
		return result..index,1.;
	}
	*/
	
	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl)
	{
		if(sb.hudlevel==1)
		{
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
		//sb.drawwepnum(hpl.countinv("HDFlareAmmo"),(HDCONST_MAXPOCKETSPACE/ENC_ROCKET));
	}
	
	// No sight picture. 
	override void DrawSightPicture(
		HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl,
		bool sightbob,vector2 bob,double fov,bool scopeview,actor hpc
	)
	{}
	
	override string gethelptext()
	{
		return
		WEPHELP_FIRESHOOT
		..WEPHELP_RELOADRELOAD
		..WEPHELP_ALTRELOAD.." Load a shotgun shell\n"
		..WEPHELP_UNLOADUNLOAD
		;
	}
	
	
	bool A_IsFilled()
	{
		return self.weaponstatus[0]&FLARE_LOADED || 
		self.weaponstatus[0]&FLARE_LOADEDSHELL;
	}
	
	
	
	action void A_FireFlare()
	{
			A_StartSound("weapons/fgnblast", CHAN_WEAPON,CHANF_OVERLAP);
			A_SpawnProjectile("HDFlareBall",(11+hdplayerpawn(self).height/2)*hdplayerpawn(self).heightmult,0,frandom(-1,1),CMF_AIMDIRECTION,pitch+frandom(-2,1.8));;
			invoker.weaponstatus[0]&=~FLARE_LOADED;
			A_MuzzleClimb(-frandom(2.,2.7),-frandom(3.4,5.2));
			A_StartSound("weapons/fgnclk",CHAN_WEAPON,CHANF_OVERLAP);
			for(int i=0;i<5;i++)A_SpawnItemEx("FourMilChunk",0,0,invoker.owner.height * 0.80,
				random(4,7),random(-2,2),random(-2,1),0,SXF_NOCHECKPOSITION
			);
	}
	
	
	action void A_FireShell()
	{
			invoker.weaponstatus[0]&=~FLARE_LOADEDSHELL;
			HDBulletActor.FireBullet(self,"HDB_wad");
			let sss=HDBulletActor.FireBullet(self,"HDB_00",
			spread:35,speedfactor:1,amount:10
			);
			distantnoise.make(sss,"world/shotgunfar");
			self.A_StartSound("weapons/hunter",CHAN_WEAPON);
			invoker.weaponstatus[0]=FLARE_SPENTSHELL;
			A_MuzzleClimb(-frandom(2.,2.7),-frandom(3.4,5.2));
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
		FBL1 A 0 A_JumpIf(invoker.A_IsFilled(), 2);
		FBL2 A 0;
		#### A 1;
		#### A 1;
		goto select0small;

	deselect0:
	deselect0real:
		FBL1 A 0;
		FBL1 A 0 A_JumpIf(invoker.A_IsFilled(),2);
		FBL2 A 0;
		#### A 1;
		goto deselect0small;

	ready:
		FBL1 A 0;
		FBL1 A 0 A_JumpIf(invoker.A_IsFilled(),2);
		FBL2 A 0;
	ReadyReal:
		#### A 0 A_SetCrosshair(21);
		#### A 1
		{
			A_WeaponReady(WRF_ALL);
		}
		goto readyend;


	hold:
	altfire:
		goto ready;

	fire:
		#### A 0 A_JumpIf(invoker.weaponstatus[0]&FLARE_LOADEDSHELL,"reallyshootshell");
		#### A 0 A_JumpIf(invoker.weaponstatus[0]&FLARE_LOADED,"reallyshoot");
		goto nope;



	reallyshootshell:
		//shoot a fireball
		#### A 2 offset(0,37)
		{
			A_FireShell();
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
		#### A 0
		{
			if(health<40)A_SetTics(7);
			else if(health<60)A_SetTics(6);
		}
		#### A 2 offset(12,74) A_StartSound("weapons/fgnrel1",8);
		#### A 1 offset(10,72)
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
		#### A 0
		{
			if(health<40)A_SetTics(3);
			else if(health<60)A_SetTics(2);
		}
		#### A 2 offset(12,74) A_StartSound("weapons/fgnrel1",8);
		#### A 1 offset(10,72)
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
		#### A 0
		{
			if(health<40)A_SetTics(3);
			else if(health<60)A_SetTics(2);
		}
		#### A 2 offset(12,74) A_StartSound("weapons/fgnrel1",8);
		#### A 1 offset(10,72)
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
			A_StartSound("weapons/fgnrel1",8,CHANF_OVERLAP);
		}
		FBL1 A 1 offset(8,78);
		FBL1 A 1 offset(8,66);
		FBL1 A 1 offset(8,52);
		FBL1 A 1 offset(4,40);
		FBL1 A 1 offset(2,34);
		goto ready;
	
	
	
	diediedie:
		---- A 0
		{
			A_StartSound("weapons/fgnclk",CHAN_WEAPON,CHANF_OVERLAP);
			for(int i=0;i<30;i++)A_SpawnItemEx("FourMilChunk",0,0,invoker.owner.height * 0.80,
				random(4,7),random(-2,2),random(-2,1),0,SXF_NOCHECKPOSITION
			);
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
