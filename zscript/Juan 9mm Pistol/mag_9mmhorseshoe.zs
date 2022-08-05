//------------------------------------------------------------------------------
// Not the wearing kind. 
//------------------------------------------------------------------------------
class HDHorseshoe9m:HDMagAmmo{
	default{
		//$Category "Ammo/Hideous Destructor/"
		//$Title "Horseshoe Pistol Magazine"
		//$Sprite "HSMGA0"


		hdmagammo.maxperunit 30;
		hdmagammo.roundtype "HDPistolAmmo";
		hdmagammo.roundbulk ENC_9_LOADED;
		hdmagammo.magbulk ENC_9MAG_EMPTY*4;
		tag "9mm pistol magazine (horseshoe)";
		inventory.pickupmessage "Picked up a horseshoe pistol magazine.";
		hdpickup.refid "j30";
	}
	override string,string,name,double getmagsprite(int thismagamt)
	{
		string magsprite;
		if(thismagamt>0)
			magsprite = "HSMGA0";
		else
			magsprite = "HSMGC0";
		return magsprite,"PBRSA0","HDPistolAmmo",1.5;
	}
	override void GetItemsThatUseThis(){
		itemsthatusethis.push("HDHorseshoePistol");
	}
	
	states{
	spawn:
		HSMG A -1;
		stop;
	spawnempty:
		HSMG B -1{
			brollsprite=true;brollcenter=true;
			roll=randompick(1,1,1, 2, 3,3,3)*90;
		}stop;
	}
}


class HDHorseshoeEmptyMag:IdleDummy{
	override void postbeginplay(){
		super.postbeginplay();
		HDMagAmmo.SpawnMag(self,"HDHorseshoe9m",0);
		destroy();
	}
}

