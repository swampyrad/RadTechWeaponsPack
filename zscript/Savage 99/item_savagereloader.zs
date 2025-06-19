// ------------------------------------------------------------
// 7.76mm Reloading Bot
// ------------------------------------------------------------
class SavageAutoReloadingThingy:HDWeapon{
	int powders;
	int brass;
	bool makinground;
	override void beginplay(){
		super.beginplay();
		brass=0;powders=0;makinground=false;
	}
	override void Consolidate(){
		int totalpowder=owner.countinv("FourMilAmmo");
		int totalbrass=owner.countinv("Savage300Brass");
		int onppowder=totalpowder;
		int onpbrass=totalbrass;
		let bp=hdbackpack(owner.FindInventory("HDBackpack",true));
		if(bp){
			totalpowder+=bp.Storage.GetAmount('fourmilammo');
			totalbrass+=bp.Storage.GetAmount('savage300brass');
		}
		if(!totalbrass||totalpowder<4)return;
		int canmake=min(totalbrass,totalpowder/4);
		//matter is being lost in this exchange. if you have a backpack you WILL have space.
		int onpspace=HDPickup.MaxGive(owner,"Savage300Ammo",ENC_776);
		if(!bp)canmake=min(canmake,onpspace);

		//evaluate amounts
		totalpowder-=canmake*4;
		totalbrass-=canmake;
		int didmake=canmake-random(0,canmake/10);

		//deduct inventory
		//remove inv first, then bp
		int deductfrombp=canmake-onpbrass;
		owner.A_TakeInventory("savage300brass",canmake);
		if(deductfrombp>0)bp.Storage.AddAmount('savage300brass',-deductfrombp);
		deductfrombp=canmake*4-onppowder;
		owner.A_TakeInventory("fourmilammo",canmake*4);
		if(deductfrombp>0)bp.Storage.AddAMount('fourmilammo',-deductfrombp);


		//add resulting rounds
		//fill up inv first, then bp
		if(didmake<1)return;

		int bpadd=didmake-onpspace;
		int onpadd=didmake-max(0,bpadd);

		if(bpadd>0)bp.Storage.AddAmount("Savage300Ammo",bpadd,flags:BF_IGNORECAP);
		if(onpadd>0)owner.A_GiveInventory("Savage300Ammo",onpadd);


		owner.A_Log(Stringtable.Localize("$SRLD_HELPTEXT_1")..didmake..Stringtable.Localize("$SRLD_HELPTEXT_2"),true);
	}

	override void actualpickup(actor other,bool silent){
		super.actualpickup(other,silent);
		if(!other)return;
		while(powders>0){
			powders--;
			if(other.A_JumpIfInventory("FourMilAmmo",0,"null"))
				other.A_SpawnItemEx("FourMilAmmo",0,0,other.height-16,2,0,1);
			else HDF.Give(other,"FourMilAmmo",1);
		}
		while(brass>0){
			brass--;
			if(other.A_JumpIfInventory("Savage300Brass",0,"null"))
				other.A_SpawnItemEx("Savage300Brass",0,0,owner.height-16,2,0,1);
			else HDF.Give(other,"Savage300Brass",1);
		}
	}
	void A_Chug(){
		A_StartSound("roundmaker/chug1",8);
		A_StartSound("roundmaker/chug2",9);
		vel.xy+=(frandom(-0.1,0.1),frandom(-0.1,0.1));
		if(floorz>=pos.z)vel.z+=frandom(0,1);
	}
	void A_MakeRound(){
		if(brass<1||powders<4){
			makinground=false;
			setstatelabel("spawn");
			return;
		}
		brass--;powders-=4;
		A_StartSound("roundmaker/pop",10);
		if(!random(0,63)){
			A_SpawnItemEx("HDExplosion");
			A_Explode(32,32);
		}else A_SpawnItemEx("LooseSavage300",0,0,0,1,0,3,0,SXF_NOCHECKPOSITION);
	}
	action void A_CheckChug(bool anyotherconditions=true){
		if(
			anyotherconditions
			&&countinv("Savage300Brass")
			&&countinv("FourMilAmmo")>=4
		){
			invoker.makinground=true;
			int counter=min(10,countinv("Savage300Brass"));
			invoker.brass=counter;A_TakeInventory("Savage300Brass",counter);
			counter=min(30,countinv("FourMilAmmo"));
			invoker.powders=counter;A_TakeInventory("FourMilAmmo",counter);
			dropinventory(invoker);
		}
	}
	states{
	chug:
		---- AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 3{invoker.A_Chug();}
		---- A 10{invoker.A_MakeRound();}
		---- A 0 A_Jump(256,"spawn");
	}
}
class SavageAutoReloader:SavageAutoReloadingThingy{
	default{
		//$Category "Weapons/Hideous Destructor"
		//$Title "Savage Auto-Reloader"
		//$Sprite "SRLDA0"

		+weapon.wimpy_weapon
		+inventory.invbar
		+hdweapon.fitsinbackpack
		inventory.pickupsound "misc/w_pkup";
		inventory.pickupmessage "You got the Savage reloading machine!";
		scale 0.5;
		hdweapon.refid "srd";
		tag "Savage .300 Reloading Device";
	}
//	override string PickupMessage() {String pickupmessage = Stringtable.Localize("$PICKUP_RELOADER"); return pickupmessage;}
	override double gunmass(){return 0;}
	override double weaponbulk(){
		return 20*amount;
	}
	override string,double getpickupsprite(){return "SRLDA0",1.;}
	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		vector2 bob=hpl.wepbob*0.3;
		int brass=hpl.countinv("Savage300Brass");
		int fourm=hpl.countinv("FourMilAmmo");
		double lph=(brass&&fourm>=4)?1.:0.6;
		sb.drawimage("SRLDA0",(0,-64)+bob,
			sb.DI_SCREEN_CENTER_BOTTOM|sb.DI_ITEM_CENTER,
			alpha:lph,scale:(2,2)
		);
		sb.drawimage("RBRSA3A7",(-30,-64)+bob,
			sb.DI_SCREEN_CENTER_BOTTOM|sb.DI_ITEM_CENTER|sb.DI_ITEM_RIGHT,
			alpha:lph,scale:(2.5,2.5)
		);
		sb.drawimage("RCLSA3A7",(30,-64)+bob,
			sb.DI_SCREEN_CENTER_BOTTOM|sb.DI_ITEM_CENTER|sb.DI_ITEM_LEFT,
			alpha:lph,scale:(1.9,4.7)
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
		LWPHELP_FIRE..Stringtable.Localize("$SRLD_HELPTEXT_3")
		..LWPHELP_USE.."+"..LWPHELP_UNLOAD..Stringtable.Localize("$SRLD_HELPTEXT_4")
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
			A_SelectWeapon("PickupManager");
		}
		goto ready;
	user4:
	unload:
		TNT1 A 1 A_CheckChug(pressinguse());
		goto ready;
	spawn:
		SRLD A -1 nodelay A_JumpIf(
			invoker.makinground
			&&invoker.brass>0
			&&invoker.powders>=3,
		"chug");
		stop;
	}
}
