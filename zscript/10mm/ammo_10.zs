// ------------------------------------------------------------
// 10mm Ammo
// -- ----------------------------------------------------------

const enc_10MAG=9;
const enc_10MAG_EMPTY=enc_10MAG*0.3;
const enc_10_LOADED=(enc_10MAG*0.7)/8.;

const enc_10=enc_10_LOADED*1.3;
const enc_10MAG_LOADED=enc_10MAG_EMPTY*0.1;

const enc_10MAG25_EMPTY=enc_10MAG_EMPTY*2.5;
const enc_10MAG25=enc_10MAG25_EMPTY+enc_10_LOADED*25;
const enc_10MAG25_LOADED=enc_10MAG25*0.8; 




class HD10mAmmo:HDRoundAmmo{//10mm ammo pickup
	default{
		+inventory.ignoreskill
		+cannotpush
		+forcexybillboard
		+rollsprite +rollcenter
		+hdpickup.multipickup
		xscale 0.7;
		yscale 0.6;
		inventory.pickupmessage "Picked up a 10mm round.";
		hdpickup.refid "10M";
		tag "10mm round";
		hdpickup.bulk enc_10;
		inventory.icon "T10MA0";
	}

	override void SplitPickup(){
		SplitPickupBoxableRound(10,100,"HD10mBoxPickup","T10MA0","PR10A0");
	}

	override void GetItemsThatUseThis(){
		itemsthatusethis.push("HDSigCow");
                itemsthatusethis.push("HD10mmPistol");
	}

	states{
	spawn:
		PR10 A -1;
		T10M A -1;
	}
}



class HD10mMag8:HDMagAmmo{
	default{
		//$Category "Ammo/Hideous Destructor/"
		//$Title "Pistol Magazine"
		//$Sprite "SC15A0"
		hdmagammo.maxperunit 8;
		hdmagammo.roundtype "HD10mAmmo";
		hdmagammo.roundbulk enc_10_LOADED;
		hdmagammo.magbulk enc_10MAG_EMPTY; 
		scale 0.45;
		tag "10mm pistol magazine";
		inventory.pickupmessage "Picked up a 10mm pistol magazine.";
		hdpickup.refid "SC8";
	}
	override string,string,name,double getmagsprite(int thismagamt){
		string magsprite=(thismagamt>0)?"SC15NORM":"SC15MPTY";
		return magsprite,"PR10A0","HD10mAmmo",0.6;
	}
	override void GetItemsThatUseThis(){
		itemsthatusethis.push("HD10mmPistol");
	}
	states{
	spawn:
		SC15 A -1;
		stop;
	spawnempty:
		SC15 B -1{
			brollsprite=true;brollcenter=true;
			roll=randompick(0,0,0,0,2,2,2,2,1,3)*90;
		}stop;
	}
}

class HD10mMag25:HD10mMag8{
	default{
		//$Category "Ammo/Hideous Destructor/"
		//$Title "SigCow Magazine"
		//$Sprite "CLP3A0"

		hdmagammo.maxperunit 25;
		hdmagammo.magbulk enc_10mag25_EMPTY;
		tag "Sig-Cow magazine";
		inventory.pickupmessage "Picked up an Sig-Cow magazine.";
		hdpickup.refid "S25";
	}

	override string,string,name,double getmagsprite(int thismagamt){
		string magsprite=(thismagamt>0)?"C10MA0":"C10MB0";
		return magsprite,"PR10A0","HD10mAmmo",2.;
	}
	override void GetItemsThatUseThis(){
		itemsthatusethis.push("HDSigCow");
	}
	states{
	spawn:
		C10M A -1;//clip, 10mm
		stop;
	spawnempty:
		C10M B -1{
			brollsprite=true;brollcenter=true;
			roll=randompick(0,0,0,0,2,2,2,2,1,3)*90;
		}stop;
	}
}


class HDSpent10mm:HDUPK{
	default{
		+missile
		+hdupk.multipickup
		height 4;radius 2;
		bouncetype "doom";
		hdupk.pickuptype "TenMilBrass";
		hdupk.pickupmessage "Picked up a 10mm casing.";

		bouncesound "misc/casing";
		bouncefactor 0.4;
		xscale 0.7;yscale 0.8;
		maxstepheight 0.6;
	}
	vector3 lastvel;
	override void Tick(){
		if(!isFrozen())lastvel=vel;
		super.Tick();
	}
	states{
	spawn:
		CS10 A 2{
			if(bseesdaggers)angle-=45;else angle+=45;
			if(pos.z-floorz<2&&abs(vel.z)<2.)setstatelabel("death");
		}wait;
	death:
		CS10 B -1{
			bmissile=false;
			vel.xy+=(pos.xy-prev.xy)*max(abs(vel.z),abs(prev.z-pos.z),1.);
			if(vel.xy==(0,0)){
				double aaa=angle-90;
				vel.x+=cos(aaa);
				vel.y+=sin(aaa);
			}else{
				A_FaceMovementDirection();
				angle+=90;
			}
			let gdb=getdefaultbytype(pickuptype);
			A_SetSize(gdb.radius,gdb.height);
			return;
		}stop;
	}
}




class HDLoose10mm:HDSpent10mm{
	default{
		bouncefactor 0.5;
	}
	states{
	death:
		TNT1 A 1{
			actor a=spawn("HD10mAmmo",self.pos,ALLOW_REPLACE);
			a.roll=self.roll;a.vel=self.vel;
		}stop;
	}
}

class HD10mPistolEmptyMag:IdleDummy{
//useless atm, no 10mm pistol yet
	override void postbeginplay(){
		super.postbeginplay();
		HDMagAmmo.SpawnMag(self,"HD10mMag8",0);
		destroy();
	}
}
class HDSigCowEmptyMag:IdleDummy{
	override void postbeginplay(){
		super.postbeginplay();
		HDMagAmmo.SpawnMag(self,"HD10mMag25",0);
		destroy();
	}
}


class HD10mBoxPickup:HDUPK{
	default{
		//$Category "Ammo/Hideous Destructor/"
		//$Title "Box of 10mm"
		//$Sprite "BX10A0"

		scale 0.4;
		hdupk.amount 100;
		hdupk.pickupsound "weapons/pocket";
		hdupk.pickupmessage "Picked up some 10mm ammo.";
		hdupk.pickuptype "HD10mAmmo";
	}
	states{
	spawn:
		BX10 A -1;
	}
}

