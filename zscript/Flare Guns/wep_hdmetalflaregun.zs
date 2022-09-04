//------------------------------------------------------------------------------
// I live..! Again!
//------------------------------------------------------------------------------


class MetalFireBlooper: FireBlooper
{
	default
	{
		inventory.pickupmessage "You got the flare gun! Feels pretty heavy...";
		obituary "%o is S.O.L. thanks to %k's S.0.S.";
		tag "Metal Flare Gun";
		hdweapon.refid "fgm";
	}


//this code checks for which sprite index to use for each hand
action void A_CheckMetalFlareGunHand(bool filled)
{
		if(invoker.wronghand && filled)
		{
			player.getpsprite(PSP_WEAPON).sprite=getspriteindex("FMR1A0");//just use the same sprites lol
		}
		else if(invoker.wronghand && !filled)
		{
			player.getpsprite(PSP_WEAPON).sprite=getspriteindex("FMR2A0");//just use the same sprites lol
		}
		else if(!(invoker.wronghand) && filled)
		{
			player.getpsprite(PSP_WEAPON).sprite=getspriteindex("FML1A0");//just use the same sprites lol
		}
		else if(!(invoker.wronghand) && !filled)
		{
			player.getpsprite(PSP_WEAPON).sprite=getspriteindex("FML2A0");//just use the same sprites lol
		}
}


	override double gunmass()
	{
		double result = 7;
		if(weaponstatus[0]&FLARE_LOADED)
			result += 1;
		else if(weaponstatus[0]&FLARE_LOADEDSHELL)
			result += 1;
		return result;
	}

	override double weaponbulk()
	{
		double result = 48;
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
		string result = "FLGM";
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
		string result = "FLGM";
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
	{
	sb.drawimage(
				"fbmsite",(0,+4)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_CENTER,
				scale:(1.2, 1.2)
	);
	}
	
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
	

	override void loadoutconfigure(string input){

		int shellround=getloadoutvar(input,"shell",1);
		if(shellround>0)
			weaponstatus[0]=FLARE_LOADEDSHELL;
		else
			weaponstatus[0]=FLARE_LOADED;
	}
	
	override void InitializeWepStats(bool idfa)
	{
		// Randomizes wild flareguns.
		weaponstatus[0]=FLARE_LOADED;

		/*
		if(!idfa && !owner)
		{
			switch(random(0,1))
			{
			case 1:
				weaponstatus[0]=FLARE_LOADEDSHELL;
				break;
			}
		}*/
		
		// Nothing to see here, move along. 
		weaponstatus[2]|=FLARE_METAL;
	}


	States
	{

	select0:
		FBM1 A 0;
		#### A 0
		{
			A_CheckMetalFlareGunHand(invoker.A_IsFilled());
		}
		FBM2 A 0;
		#### A 1;
		#### A 1;
		goto select0small;

	deselect0:
	select0:
		FML1 A 0;
		FML1 B 0;
		FML2 A 0;
		FML2 B 0;
		FMR1 A 0;
		FMR1 B 0;
		FMR2 A 0;
		FMR2 B 0;
		FML1 A 0;
		#### A 0
		{
			A_CheckMetalFlareGunHand(invoker.A_IsFilled());
		}
		FBM2 A 0;
		#### A 1;
		goto deselect0small;

	ready:
		#### A 0;
		#### A 0
		{
			A_CheckMetalFlareGunHand(invoker.A_IsFilled());
		}
		#### A 0;
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
		goto nope;

	//i think it finally works!!!
	reallyshoot:
		//shoot a fireball
		#### A 2 offset(0,37)
		{
			A_FireFlare();
			A_CheckMetalFlareGunHand(invoker.A_IsFilled());
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
		FML1 B 0
		{
			A_CheckMetalFlareGunHand(invoker.A_IsFilled());
			if(health<40)A_SetTics(3);
			else if(health<60)A_SetTics(2);
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
		#### B 0
		{
			A_CheckMetalFlareGunHand(invoker.A_IsFilled());
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
		#### B 0;
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
		#### B 0
		{
			A_CheckMetalFlareGunHand(invoker.A_IsFilled());
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
		FBM1 A 0
		{
			A_StartSound("weapons/fgnrel1",8,CHANF_OVERLAP);
		}
		FBM1 A 1 offset(8,78);
		FBM1 A 1 offset(8,66);
		FBM1 A 1 offset(8,52);
		FBM1 A 1 offset(4,40);
		FBM1 A 1 offset(2,34);
		goto ready;
	
	firemode:
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
		FBM1 A 0 A_CheckMetalFlareGunHand(invoker.A_IsFilled());
		goto nope;
	lowerleft:
		FBM2 A 0;
		#### A 0
		{
			A_CheckMetalFlareGunHand(invoker.A_IsFilled());
		}
		#### A 1 offset(-6,38);
		#### A 1 offset(-12,48);
		#### A 1 offset(-20,60);
		#### A 1 offset(-34,76);
		#### A 1 offset(-50,86);
		stop;
	lowerright:
		#### A 0
		{
			A_CheckMetalFlareGunHand(invoker.A_IsFilled());
		}
		#### A 1 offset(6,38);
		#### A 1 offset(12,48);
		#### A 1 offset(20,60);
		#### A 1 offset(34,76);
		#### A 1 offset(50,86);
		stop;
	raiseleft:
		#### A 0
		{
			A_CheckMetalFlareGunHand(invoker.A_IsFilled());
		}
		#### A 1 offset(-50,86);
		#### A 1 offset(-34,76);
		#### A 1 offset(-20,60);
		#### A 1 offset(-12,48);
		#### A 1 offset(-6,38);
		stop;
	raiseright:
		#### A 0
		{
			A_CheckMetalFlareGunHand(invoker.A_IsFilled());
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
			invoker.wronghand=!invoker.wronghand;
			A_CheckMetalFlareGunHand(invoker.A_IsFilled());
		}
		#### A 1 offset(0,76);
		#### A 1 offset(0,60);
		#### A 1 offset(0,48);
		goto nope;
	
	
	
	
	spawn:
		FLMN A -1 nodelay
		{
			frame = invoker.A_GetFrameIndex();
		}
		stop;
	}
}
