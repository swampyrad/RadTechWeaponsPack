class TokarevAutoReloadingThingy:HDWeapon{
	int powders;
	int brass;
	bool makinground;
	override void beginplay(){
		super.beginplay();
		brass=0;powders=0;makinground=false;
	}
	override void Consolidate(){
		int totalpowder=owner.countinv("HDPistolAmmo");
		int totalbrass=owner.countinv("TokarevBrass");
		int onppowder=totalpowder;
		int onpbrass=totalbrass;
		let bp=hdbackpack(owner.FindInventory("HDBackpack",true));
		if(bp){
			totalpowder+=bp.Storage.GetAmount('HDPistolAmmo');
			totalbrass+=bp.Storage.GetAmount('TokarevBrass');
		}
		if(!totalbrass||totalpowder<2)return;
		int canmake=min(totalbrass,totalpowder/2);
		//matter is being lost in this exchange. if you have a backpack you WILL have space.
		int onpspace=HDPickup.MaxGive(owner,"HD762TokarevAmmo",ENC_762TOKAREV);
		if(!bp)canmake=min(canmake,onpspace);




		//evaluate amounts
		totalpowder-=canmake*2;
		totalbrass-=canmake;
		int didmake=canmake-random(0,canmake/16);

		//deduct inventory
		//remove inv first, then bp
		int deductfrombp=canmake-onpbrass;
		owner.A_TakeInventory("TokarevBrass",canmake);
		if(deductfrombp>0)bp.Storage.AddAmount('TokarevBrass',-deductfrombp);
		deductfrombp=canmake*2-onppowder;
		owner.A_TakeInventory("HDPistolAmmo",canmake*2);
		if(deductfrombp>0)bp.Storage.AddAMount('HDPistolAmmo',-deductfrombp);


		//add resulting rounds
		//fill up inv first, then bp
		if(didmake<1)return;

		int bpadd=didmake-onpspace;
		int onpadd=didmake-max(0,bpadd);

		if(bpadd>0)bp.Storage.AddAmount("HD762TokarevAmmo",bpadd,flags:BF_IGNORECAP);
		if(onpadd>0)owner.A_GiveInventory("HD762TokarevAmmo",onpadd);


		owner.A_Log("You reloaded "..didmake.." 7.62 Tokarev rounds during your downtime, comrade.",true);
	}
	override void actualpickup(actor other,bool silent){
		super.actualpickup(other,silent);
		if(!other)return;
		while(powders>0){
			powders--;
			if(other.A_JumpIfInventory("HDPistolAmmo",0,"null"))
				other.A_SpawnItemEx("HDPistolAmmo",0,0,other.height-16,2,0,1);
			else HDF.Give(other,"HDPistolAmmo",1);
		}
		while(brass>0){
			brass--;
			if(other.A_JumpIfInventory("TokarevBrass",0,"null"))
				other.A_SpawnItemEx("TokarevBrass",0,0,owner.height-16,2,0,1);
			else HDF.Give(other,"TokarevBrass",1);
		}
	}
	void A_Chug(){
		A_StartSound("roundmaker/chug1",8);
		A_StartSound("roundmaker/chug2",9);
		vel.xy+=(frandom(-0.1,0.1),frandom(-0.1,0.1));
		if(floorz>=pos.z)vel.z+=frandom(0,1);
	}
	void A_MakeRound(){
		if(brass<1||powders<2){
			makinground=false;
			setstatelabel("spawn");
			return;
		}
		brass--;powders-=2;
		A_StartSound("roundmaker/pop",10);
		if(!random(0,63)){
			A_SpawnItemEx("HDExplosion");
			A_Explode(32,32);
		}else A_SpawnItemEx("HD762TokarevAmmo",0,0,0,1,0,3,0,SXF_NOCHECKPOSITION);
	}
	action void A_CheckChug(bool anyotherconditions=true){
		if(
			anyotherconditions
			&&countinv("TokarevBrass")
			&&countinv("HDPistolAmmo")>=1
		){
			invoker.makinground=true;
			int counter=min(8,countinv("TokarevBrass"));
			invoker.brass=counter;A_TakeInventory("TokarevBrass",counter);
			counter=min(16,countinv("HDPistolAmmo"));
			invoker.powders=counter;A_TakeInventory("HDPistolAmmo",counter);
			dropinventory(invoker);
		}
	}
	states{
	chug:
		---- AAAAAAAA 5{invoker.A_Chug();}
		---- AAAAAAAAAAAAAAAA 3{invoker.A_Chug();}
		---- AAAAAAAAAAA 4{invoker.A_Chug();}
		---- AAAAA 7{invoker.A_Chug();}
  ---- AA 0 A_EjectCasing("HDSpent9mm",-frandom(89,92),(frandom(2,3),0,0),(13,0,0));
		---- A 10{invoker.A_MakeRound();}
		---- A 0 A_Jump(256,"spawn");
	}
}


class TokarevAutoReloader:TokarevAutoReloadingThingy{
	default{
		//$Category "Weapons/Hideous Destructor"
		//$Title "7.62 Tokarev Auto-Reloader"
		//$Sprite "RDT7A0"

		+weapon.wimpy_weapon
		+inventory.invbar
		+hdweapon.fitsinbackpack
		inventory.pickupsound "misc/w_pkup";
    //	inventory.pickupmessage "You got the 7.62 Tokarev reloading machine! Own the means of production!";
		scale 0.5;
		hdweapon.refid "RT7";
		tag "$TAG_TOKRELOADER";
	}

    override string pickupmessage(){
		return Stringtable.Localize("$PICKUP_TOKRELOADER");
	}

	override double gunmass(){return 0;}
	override double weaponbulk(){
		return 25*amount;
	}//make it red
	override string,double getpickupsprite(){return "RDT7A0",1.;}
	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		vector2 bob=hpl.wepbob*0.3;
		int brass=hpl.countinv("TokarevBrass");
		int fourm=hpl.countinv("HDPistolAmmo");
		double lph=(brass&&fourm>=4)?1.:0.6;
		sb.drawimage("RDT7A0",(0,-64)+bob,
			sb.DI_SCREEN_CENTER_BOTTOM|sb.DI_ITEM_CENTER,
			alpha:lph,scale:(2,2)
		);
		sb.drawimage("T7CSB0",(-30,-64)+bob,
			sb.DI_SCREEN_CENTER_BOTTOM|sb.DI_ITEM_CENTER|sb.DI_ITEM_RIGHT,
			alpha:lph,scale:(2.5,2.5)
		);
		sb.drawimage("9boxa0",(30,-64)+bob,
			sb.DI_SCREEN_CENTER_BOTTOM|sb.DI_ITEM_CENTER|sb.DI_ITEM_LEFT,
			alpha:lph,scale:(2.,2.)
		);
		sb.drawstring(
			sb.psmallfont,""..brass,(-30,-54)+bob,
			sb.DI_TEXT_ALIGN_RIGHT|sb.DI_SCREEN_CENTER_BOTTOM,
			fourm?Font.CR_GOLD:Font.CR_DARKGRAY,alpha:lph
		);
		sb.drawstring(
			sb.psmallfont,""..fourm,(30,-54)+bob,
			sb.DI_TEXT_ALIGN_LEFT|sb.DI_SCREEN_CENTER_BOTTOM,
			fourm?Font.CR_LIGHTBLUE:Font.CR_DARKGRAY,alpha:lph
		);
	}
	override string gethelptext(){
		return
		WEPHELP_FIRE.."  Assemble 7.62 Tokarev rounds\n"
		..WEPHELP_USE.."+"..WEPHELP_UNLOAD.."  same"
		;
	}
	override bool AddSpareWeapon(actor newowner){return AddSpareWeaponRegular(newowner);}
	override hdweapon GetSpareWeapon(actor newowner,bool reverse,bool doselect){return GetSpareWeaponRegular(newowner,reverse,doselect);}
	states{
	select0:
		TNT1 A 0 A_Raise(999);
		wait;
	deselect0:
		TNT1 A 0 A_Lower(999);
		wait;
	ready:
		TNT1 A 1 A_WeaponReady(WRF_ALLOWUSER3|WRF_ALLOWUSER4);
		goto readyend;
	fire:
		TNT1 A 0 A_CheckChug();
		goto ready;
	hold:
		TNT1 A 1;
		TNT1 A 0 A_Refire("hold");
		goto ready;
	user3:
		---- A 0{
			if(countinv("HDTokarevMag8"))A_MagManager("HDTokarevMag8");
			else A_SelectWeapon("PickupManager");
		}
		goto ready;
	user4:
	unload:
		TNT1 A 1 A_CheckChug(pressinguse());
		goto ready;
	spawn:
		RDT7 A -1 nodelay A_JumpIf(
			invoker.makinground
			&&invoker.brass>0
			&&invoker.powders>=2,
		"chug");
		stop;
	}
}

/*
class TokarevReloaderInjector:StaticEventHandler{
override void WorldThingSpawned(WorldEvent e) { 
		let Reloader = HDAmmo(e.Thing); 	
	 if (Reloader){ 			
  switch (Reloader.GetClassName()){
  case 'HDPistolAmmo': Reloader.ItemsThatUseThis.Push("TokarevAutoReloader"); 					break;		 		
        }
    	}
 		} 	
} 
*/
