const ENC_TOKAREV_DRUM_EMPTY = 20;//those drums are chonky bois :3
const ENC_TOKAREV_BOX_EMPTY = 9;

const ENC_TOKAREV_DRUM_LOADED = ENC_TOKAREV_DRUM_EMPTY*0.9;
const ENC_TOKAREV_BOX_LOADED = ENC_TOKAREV_BOX_EMPTY*0.7;


class HDTokarevMag71:HDMagAmmo{
	default{
		//$Category "Ammo/Hideous Destructor/"
		//$Title "PPSh-41 Drum Magazine"
		//$Sprite "PSDMA0"
        scale 0.35;

		hdmagammo.maxperunit 71;
		hdmagammo.roundtype "HD762TokarevAmmo";
		hdmagammo.roundbulk ENC_762TOKAREV_LOADED;
		hdmagammo.magbulk ENC_TOKAREV_DRUM_EMPTY;
		tag "$TAG_PPSH41MAG71";
//		inventory.pickupmessage "Picked up a PPSh-41 drum magazine.";
		hdpickup.refid "tm7";
	}
    
    	override string pickupmessage(){
		return Stringtable.Localize("$PICKUP_PPSH41MAG71");
	}

	
	override string,string,name,double getmagsprite(int thismagamt)
	{
		string magsprite;
		if(thismagamt>0)
			magsprite = "PSDMA0";
		else
			magsprite = "PSDMC0";
		return magsprite,"T762A0","HD762TokarevAmmo",1;
	}
	override void GetItemsThatUseThis(){
		itemsthatusethis.push("HDPPSh41");
	}
	
	states{
	spawn:
		PSDM A -1;
		stop;
	spawnempty:
		PSDM D -1{
			brollsprite=true;brollcenter=true;
			roll=randompick(1,1,1, 2, 3,3,3)*90;
		}stop;
	}
}

class HDTokarevMag35:HDMagAmmo{
	default{
		//$Category "Ammo/Hideous Destructor/"
		//$Title "PPSh-41 Box Magazine"
		//$Sprite "PSDMA0"
        scale 0.35;

		hdmagammo.maxperunit 35;
		hdmagammo.roundtype "HD762TokarevAmmo";
		hdmagammo.roundbulk ENC_762TOKAREV_LOADED;
		hdmagammo.magbulk ENC_TOKAREV_BOX_EMPTY;
		tag "$TAG_PPSH41MAG35";
	//	inventory.pickupmessage "Picked up a PPSh-41 box magazine.";
		hdpickup.refid "tm3";
	}

	override string pickupmessage(){
		return Stringtable.Localize("$PICKUP_PPSH41MAG35");
	}

	
	override string,string,name,double getmagsprite(int thismagamt)
	{
		string magsprite;
		if(thismagamt>0)
			magsprite = "PSHMA0";
		else
			magsprite = "PSHMC0";
		return magsprite,"T762A0","HD762TokarevAmmo",1;
	}
	override void GetItemsThatUseThis(){
		itemsthatusethis.push("HDPPSh41");
	}
	
	states{
	spawn:
		PSHM A -1;
		stop;
	spawnempty:
		PSHM D -1{
			brollsprite=true;brollcenter=true;
			roll=randompick(1,1,1, 2, 3,3,3)*90;
		}stop;
	}
}

class HDPPSh41EmptyMag:IdleDummy{
	override void postbeginplay(){
		super.postbeginplay();
		HDMagAmmo.SpawnMag(self,"HDTokarevMag35",0);
		destroy();
	}
}

class HDPPSh41EmptyDrum:IdleDummy{
	override void postbeginplay(){
		super.postbeginplay();
		HDMagAmmo.SpawnMag(self,"HDTokarevMag71",0);
		destroy();
	}
}

class PapashaMagSpawner:actor{
	override void postbeginplay(){
		super.postbeginplay();
		if(!random(0,3)) spawn("HDTokarevMag71",pos,ALLOW_REPLACE);
  		else spawn("HDTokarevMag35",pos,ALLOW_REPLACE);
  		
		self.Destroy();
	}
}

