// ------------------------------------------------------------
// Flare Gun Shells
// ------------------------------------------------------------
class HDFlareAmmo:HDRoundAmmo{
	default{
		+inventory.ignoreskill
		+hdpickup.multipickup
		inventory.pickupmessage "Picked up a flare shell.";
		scale 0.2;
		tag "flare shells";
		hdpickup.refid "fsh";
		hdpickup.bulk ENC_SHELL*0.9;
		inventory.icon "FLA4A0";
	}
	override void GetItemsThatUseThis(){
		itemsthatusethis.push("FireBlooper");
		itemsthatusethis.push("MetalFireBlooper");
	}

	override void SplitPickup(){	SplitPickupBoxableRound(
4,20,"FlareShellBoxPickup","FLA4A0","FLARA0");
	}

	override string pickupmessage(){
		if(amount>1)return "Picked up some flare shells.";
		return super.pickupmessage();
	}
	states{
	spawn:
		FLAR A -1;
		stop;
	death:
		ELLS A -1{
			if(Wads.CheckNumForName("id",0)==-1)A_SetTranslation("FreeShell");
			frame=randompick(0,0,0,0,4,4,4,4,2,2,5);
		}stop;
	}
}


class FlareShellBoxPickup:HDUPK{
	default{
		//$Category "Ammo/Hideous Destructor/"
		//$Title "Box of Flare Shells"
		//$Sprite "FLBXA0"
		scale 0.4;
		hdupk.amount 20;
		hdupk.pickupsound "weapons/pocket";
		hdupk.pickupmessage "Picked up some flare shells.";
		hdupk.pickuptype "HDFlareAmmo";
		translation "160:167=80:105";
	}
	states{
	spawn:
		FLBX A -1 nodelay{
			if(Wads.CheckNumForName("id",0)==-1)scale=(0.25,0.25);
		}
	}
}
class FlareShellPickup:IdleDummy{
	default{
		//$Category "Ammo/Hideous Destructor/"
		//$Title "Four Flare Shells"
		//$Sprite "FLA4A0"
	}
	states{
	spawn:
		FLA4 A 0 nodelay{
			let iii=hdpickup(spawn("HDFlareAmmo",pos,ALLOW_REPLACE));
			if(iii){
				hdf.transferspecials(self,iii,hdf.TS_ALL);
				iii.amount=4;
			}
		}stop;
	}
}
