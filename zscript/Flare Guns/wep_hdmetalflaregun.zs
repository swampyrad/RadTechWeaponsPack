//------------------------------------------------------------------------------
// I live..! Again!
//------------------------------------------------------------------------------


class MetalFireBlooper: FireBlooper
{
	default
	{
		obituary "$OB_METALFLAREGUN";
		tag "$TAG_METALFLAREGUN";
		hdweapon.refid "fgm";
	}
	override string pickupmessage(){
		return Stringtable.Localize("$PICKUP_METALFLAREGUN");
	}


//this code checks for which sprite index to use for each hand
action void A_CheckMetalFlareGunHand(bool filled)
{
		if(invoker.wronghand && filled)
		{
			player.getpsprite(PSP_WEAPON).sprite=getspriteindex("FMR1A0");
		}
		else if(invoker.wronghand && !filled)
		{
			player.getpsprite(PSP_WEAPON).sprite=getspriteindex("FMR2A0");
		}
		else if(!(invoker.wronghand) && filled)
		{
			player.getpsprite(PSP_WEAPON).sprite=getspriteindex("FML1A0");
		}
		else if(!(invoker.wronghand) && !filled)
		{
			player.getpsprite(PSP_WEAPON).sprite=getspriteindex("FML2A0");
		}
}


	override double gunmass()
	{
		double result = 7;

		if(weaponstatus[0]&FLARE_LOADED)
			result += 1;
		else if(weaponstatus[0]&FLARE_LOADEDSHELL
		      ||weaponstatus[0]&FLARE_LOADEDSLUG)
			result += 2;
		else if(weaponstatus[0]&FLARE_LOADEDSLUGEXP)
			result += 3;
		return result;
	}

	override double weaponbulk()
	{
		double result = 36;
		if(weaponstatus[0]&FLARE_LOADED)//flare shell
			result += ENC_SHELL/2;
		else if(weaponstatus[0]&FLARE_LOADEDSHELL
		      ||weaponstatus[0]&FLARE_LOADEDSLUG)//shotgun shell
			result += ENC_SHELL;
		else if(weaponstatus[0]&FLARE_LOADEDSLUGEXP)//explosive slug
			result += ENC_SHELL*2;
		else if(weaponstatus[0]&FLARE_SPENTSHELL    //spent shells
		      ||weaponstatus[0]&FLARE_SPENTSLUG
		      ||weaponstatus[0]&FLARE_SPENTSLUGEXP)
			result += ENC_SHELL/3;
		return result;
	}

	override string,double getpickupsprite(bool usespare)
	{
		string result = "FLMN";
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
		{
			sb.drawimage("SLG1A0",(-53,-19),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1.1,1.1));
			sb.drawnum(hpl.countinv("HDSlugAmmo"),-50,-23,sb.DI_SCREEN_CENTER_BOTTOM);
		
			sb.drawimage("XLS1A0",(-38,-19),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1.1,1.1));
			sb.drawnum(hpl.countinv("HDExplosiveShellAmmo"),-35,-23,sb.DI_SCREEN_CENTER_BOTTOM);

			sb.drawimage("FLARA0",(-48,-4),sb.DI_SCREEN_CENTER_BOTTOM,scale:(0.6,0.6));
			sb.drawnum(hpl.countinv("HDFlareAmmo"),-45,-8,sb.DI_SCREEN_CENTER_BOTTOM);
			
			sb.drawimage("SHL1A0",(-33,-4),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1.1,1.1));
			sb.drawnum(hpl.countinv("HDShellAmmo"),-28,-8,sb.DI_SCREEN_CENTER_BOTTOM);
		}
		
		if(hdw.weaponstatus[0]&FLARE_LOADED)
		    {
			sb.drawrect(-24,-13,7,3);
		    }
		else if(hdw.weaponstatus[0]==FLARE_LOADEDSHELL ||
		        hdw.weaponstatus[0]==FLARE_LOADEDSLUG  ||  //make distinct slug graphic later
    	        hdw.weaponstatus[0]==FLARE_LOADEDSLUGEXP)
		    {
			sb.drawrect(-24,-13,5,3);
			sb.drawrect(-18,-13,2,3);
		    }
		else if(hdw.weaponstatus[0]==FLARE_SPENTSHELL ||
		        hdw.weaponstatus[0]==FLARE_SPENTSLUG  ||
		        hdw.weaponstatus[0]==FLARE_SPENTSLUGEXP)
		    {
			sb.drawrect(-18,-13,2,3);
		    }
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
		LocalizeHelp();
		return
		LWPHELP_FIRESHOOT
		..LWPHELP_ALTFIRE..", "..LWPHELP_FIREMODE..Stringtable.Localize("$FGUN_HELPTEXT_1")
		..LWPHELP_RELOAD..Stringtable.Localize("$FGUN_HELPTEXT_2")
		..LWPHELP_ALTRELOAD..Stringtable.Localize("$FGUN_HELPTEXT_3")
		..LWPHELP_FIREMODE.."+"..LWPHELP_RELOAD..Stringtable.Localize("$FGUN_HELPTEXT_4")
		..LWPHELP_FIREMODE.."+"..LWPHELP_ALTRELOAD..Stringtable.Localize("$FGUN_HELPTEXT_5")
		..LWPHELP_UNLOADUNLOAD
		;
	}
	
	
	bool A_IsFilled()
	{
		return self.weaponstatus[0]&FLARE_LOADED    ||
		    self.weaponstatus[0]&FLARE_LOADEDSHELL  ||
		    self.weaponstatus[0]&FLARE_LOADEDSLUG   ||
		    self.weaponstatus[0]&FLARE_LOADEDSLUGEXP;
	}
	

	override void loadoutconfigure(string input){

		int shellround=getloadoutvar(input,"shell",1);
		int sluground=getloadoutvar(input,"slug",1);
		int exsluground=getloadoutvar(input,"markcollins",1);
		
		if(shellround==1)
			weaponstatus[0]=FLARE_LOADEDSHELL;
		else if(sluground==1)
			weaponstatus[0]=FLARE_LOADEDSLUG;
		else if(exsluground==1)
			weaponstatus[0]=FLARE_LOADEDSLUGEXP;// ;)
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
		#### A 0;
		#### A 1;
		goto select0small;
		
	deselect0:
	deselect0real:
		FML1 A 0;
		#### A 0
		{
			A_CheckMetalFlareGunHand(invoker.A_IsFilled());
		}
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
		#### A 0 A_JumpIf(invoker.weaponstatus[0]==FLARE_LOADEDSHELL,"reallyshootshell");
		#### A 0 A_JumpIf(invoker.weaponstatus[0]==FLARE_LOADEDSLUG,"reallyshootslug");
		#### A 0 A_JumpIf(invoker.weaponstatus[0]==FLARE_LOADED,"reallyshoot");
		#### A 0 A_JumpIf(invoker.weaponstatus[0]==FLARE_LOADEDSLUGEXP,"reallyshoothell");
		goto nope;

	reallyshoothell:
		//shoot a REAL fireball
		#### A 2 offset(0,37)
		{
			A_FireHell();
			A_CheckMetalFlareGunHand(invoker.A_IsFilled());
		}
		#### A 1;
		#### A 0;
		goto nope;


	reallyshootshell:
		//shoot a fireball
		#### A 2 offset(0,37)
		{
			A_FireShell();
			A_CheckMetalFlareGunHand(invoker.A_IsFilled());
		}
		#### A 1;
		#### A 0;
		goto nope;
		
	reallyshootslug:
		//shoot a slug
		#### A 2 offset(0,37)
		{
			A_FireSlug();
			A_CheckMetalFlareGunHand(invoker.A_IsFilled());
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

    loadslug:

		#### A 0 A_JumpIf(
		invoker.weaponstatus[0]&FLARE_LOADED         ||
		invoker.weaponstatus[0]&FLARE_LOADEDSHELL    ||
		invoker.weaponstatus[0]&FLARE_SPENTSHELL     ||
		invoker.weaponstatus[0]&FLARE_SPENTSLUG     ||
		invoker.weaponstatus[0]&FLARE_SPENTSLUGEXP  ||
		invoker.weaponstatus[0]&FLARE_LOADEDSLUG    ||
		invoker.weaponstatus[0]&FLARE_LOADEDSLUGEXP ||
		!countinv("HDSlugAmmo"), "nope");
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
			A_TakeInventory("HDSlugAmmo",1,TIF_NOTAKEINFINITE);
			invoker.weaponstatus[0]|=FLARE_LOADEDSLUG;
			A_SetTics(5);
		}
		goto reloadend;

	mark:
		#### A 0 A_JumpIf(
		invoker.weaponstatus[0]&FLARE_LOADED         ||
		invoker.weaponstatus[0]&FLARE_LOADEDSHELL    ||
		invoker.weaponstatus[0]&FLARE_SPENTSHELL     ||
		invoker.weaponstatus[0]&FLARE_SPENTSLUG     ||
		invoker.weaponstatus[0]&FLARE_SPENTSLUGEXP  ||
		invoker.weaponstatus[0]&FLARE_LOADEDSLUG    ||
		invoker.weaponstatus[0]&FLARE_LOADEDSLUGEXP ||
		!countinv("HDExplosiveShellAmmo"), "nope");
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
			A_TakeInventory("HDExplosiveShellAmmo",1,TIF_NOTAKEINFINITE);
			invoker.weaponstatus[0]|=FLARE_LOADEDSLUGEXP;
			A_SetTics(5);
		}
		goto reloadend;
	
	firemode:
	fmhold:
	    ---- A 1;
		---- A 1{if(PressingReload())setweaponstate("loadslug");
		        else if(PressingAltReload())setweaponstate("mark");
		            else if(PressingFireMode())setweaponstate("fmhold");
	}goto nope;

	
	altreload:
		#### A 0;
		#### A 0 A_JumpIf(
		invoker.weaponstatus[0]&FLARE_LOADED        ||
		invoker.weaponstatus[0]&FLARE_LOADEDSHELL   ||
		invoker.weaponstatus[0]&FLARE_LOADEDSLUG    ||
		invoker.weaponstatus[0]&FLARE_LOADEDSLUGEXP ||
		invoker.weaponstatus[0]&FLARE_SPENTSHELL    ||
		invoker.weaponstatus[0]&FLARE_SPENTSLUG     ||
		invoker.weaponstatus[0]&FLARE_SPENTSLUGEXP  ||
		!countinv("HDShellAmmo"), "nope");
		#### A 0 offset(2,36)A_StartSound("weapons/fgnrel1",8);
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
			invoker.weaponstatus[0]&FLARE_LOADED         ||
			invoker.weaponstatus[0]&FLARE_LOADEDSHELL    ||
			invoker.weaponstatus[0]&FLARE_LOADEDSLUG ||
			invoker.weaponstatus[0]&FLARE_LOADEDSLUGEXP ||
			invoker.weaponstatus[0]&FLARE_SPENTSLUG  ||
			invoker.weaponstatus[0]&FLARE_SPENTSLUGEXP  ||
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
					(!PressingUnload()&&!PressingReload())              ||
					A_JumpIfInventory("HDFlareAmmo",0,"null")           ||
					A_JumpIfInventory("HDShellAmmo",0,"null")           ||
					A_JumpIfInventory("HDSlugAmmo",0,"null")            ||
					A_JumpIfInventory("HDExplosiveShellAmmo",0,"null")  ||
					invoker.weaponstatus[0]==FLARE_SPENTSHELL           ||
					invoker.weaponstatus[0]==FLARE_SPENTSLUG            ||
					invoker.weaponstatus[0]==FLARE_SPENTSLUGEXP     
				)
				{
					if(invoker.weaponstatus[0]==FLARE_SPENTSLUGEXP)
						A_SpawnItemEx("HDSpentExplosiveShell",10,0,height-16,vel.x,vel.y,vel.z+2,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION);
					else if(invoker.weaponstatus[0]==FLARE_SPENTSHELL)
						A_SpawnItemEx("HDSpentShell",10,0,height-16,vel.x,vel.y,vel.z+2,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION);
					else if(invoker.weaponstatus[0]==FLARE_SPENTSLUG)
						A_SpawnItemEx("HDSpentSlug",10,0,height-16,vel.x,vel.y,vel.z+2,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION);
					else if(invoker.weaponstatus[0]==FLARE_LOADED)
						A_SpawnItemEx("HDFlareAmmo",10,0,height-16,vel.x,vel.y,vel.z+2,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION);
					else if(invoker.weaponstatus[0]==FLARE_LOADEDSHELL)
						A_SpawnItemEx("HDShellAmmo",10,0,height-16,vel.x,vel.y,vel.z+2,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION);
                    else if(invoker.weaponstatus[0]==FLARE_LOADEDSLUG)
						A_SpawnItemEx("HDSlugAmmo",10,0,height-16,vel.x,vel.y,vel.z+2,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION);
					else if(invoker.weaponstatus[0]==FLARE_LOADEDSLUGEXP)
						A_SpawnItemEx("HDExplosiveShellAmmo",10,0,height-16,vel.x,vel.y,vel.z+2,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION);
				
					
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
					else if(!(invoker.weaponstatus[0]&~FLARE_LOADEDSLUG))
					{
						A_GiveInventory("HDSlugAmmo",1);
						A_StartSound("weapons/pocket",9);
						A_SetTics(4);
					}
					else if(!(invoker.weaponstatus[0]&~FLARE_LOADEDSLUGEXP))
					{
						A_GiveInventory("HDExplosiveShellAmmo",1);
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
		invoker.weaponstatus[0]&FLARE_LOADED         ||
		invoker.weaponstatus[0]&FLARE_LOADEDSHELL    ||
		invoker.weaponstatus[0]&FLARE_LOADEDSLUGEXP ||
		invoker.weaponstatus[0]&FLARE_SPENTSHELL     ||
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
		FML1 A 0
		{
			A_CheckMetalFlareGunHand(invoker.A_IsFilled());
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
		FML1 A 0
		{
			A_CheckMetalFlareGunHand(invoker.A_IsFilled());
		}
		goto nope;
	lowerleft:
		FMR2 A 0
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
		FML2 A 0
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
		FMR2 A 0
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
		FML2 A 0
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
