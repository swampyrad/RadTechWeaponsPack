// ------------------------------------------------------------
// Less-Lethal Shotgun Shells
// ------------------------------------------------------------
class HDLLShellAmmo:HDRoundAmmo{
	default{
		+inventory.ignoreskill
		+hdpickup.multipickup
		inventory.pickupmessage "Picked up a less-lethal shell.";
		scale 0.3;
		tag "less-lethal shells";
		hdpickup.refid "LLS";
		hdpickup.bulk ENC_SHELL;
		inventory.icon "LLS4A0";
	}
	override void GetItemsThatUseThis(){
		itemsthatusethis.push("LLHunter");
	}
	override void SplitPickup(){
		SplitPickupBoxableRound(4,20,"LLShellBoxPickup","LLS4A0","LLS1A0");
	}
	override string pickupmessage(){
		if(amount>1)return "Picked up some less-lethal shells.";
		return super.pickupmessage();
	}
	states{
	spawn:
		lls1 A -1;
		stop;
	death:
		ELLS A -1{
			if(Wads.CheckNumForName("id",0)==-1)A_SetTranslation("FreeShell");
			frame=randompick(0,0,0,0,4,4,4,4,2,2,5);
		}stop;
	}
}
class HDLLSpentShell:HDDebris{
	default{
		-noteleport +forcexybillboard
		seesound "misc/casing2";scale 0.3;height 2;radius 2;
		bouncefactor 0.5;
	}
	override void postbeginplay(){
		super.postbeginplay();
		if(Wads.CheckNumForName("id",0)==-1)A_SetTranslation("FreeShell");
		if(vel==(0,0,0))A_ChangeVelocity(0.0001,0,-0.1,CVF_RELATIVE);
	}
	vector3 lastvel;
	override void Tick(){
		if(!isFrozen())lastvel=vel;
		super.Tick();
	}
	states{
	spawn:
		ELLS ABCDEFGH 2;
		loop;
	death:
		ELLS A -1{
			frame=randompick(0,0,0,0,4,4,4,4,2,2,5);
		}stop;
	}
}

class HDLLFumblingShell:HDSpentShell{
	default{
		bouncefactor 0.3;
	}
	states{
	spawn:
		ELLS ABCDEFGH 2;
		loop;
	death:
		TNT1 A 0{
			let sss=spawn("HDLLShellAmmo",pos);
			sss.vel.xy=lastvel.xy+lastvel.xy.unit()*abs(lastvel.z);
			sss.setstatelabel("death");
			if(sss.vel.x||sss.vel.y){
				sss.A_FaceMovementDirection();
				sss.angle+=90;
				sss.frame=randompick(0,4);
			}else sss.frame=randompick(0,0,0,4,4,4,2,2,5);
			inventory(sss).amount=1;
		}stop;
	}
}

class LLShellBoxPickup:HDUPK{
	default{
		//$Category "Ammo/Hideous Destructor/"
		//$Title "Box of Less-Lethal Shells"
		//$Sprite "LLBXA0"
		scale 0.4;
		hdupk.amount 20;
		hdupk.pickupsound "weapons/pocket";
		hdupk.pickupmessage "Picked up some less-lethal shells.";
		hdupk.pickuptype "HDLLShellAmmo";
		translation "160:167=80:105";
	}
	states{
	spawn:
		LLBX A -1 nodelay{
			if(Wads.CheckNumForName("id",0)==-1)scale=(0.25,0.25);
		}
	}
}
class LLShellPickup:IdleDummy{
	default{
		//$Category "Ammo/Hideous Destructor/"
		//$Title "Four Less-Lethal Shells"
		//$Sprite "LLS4A0"
	}
	states{
	spawn:
		LLS4 A 0 nodelay{
			let iii=hdpickup(spawn("HDLLShellAmmo",pos,ALLOW_REPLACE));
			if(iii){
				hdf.transferspecials(self,iii,hdf.TS_ALL);
				iii.amount=4;
			}
		}stop;
	}
}