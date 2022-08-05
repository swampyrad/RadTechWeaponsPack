// ------------------------------------------------------------
// Explosive Shotgun Shells
// ------------------------------------------------------------
class HDExplosiveShellAmmo:HDRoundAmmo{
	default{
		+inventory.ignoreskill
		+hdpickup.multipickup
		inventory.pickupmessage "Picked up an explosive shell.";
		scale 0.3;
		tag "explosive shell";
		hdpickup.refid "xsh";
		hdpickup.bulk ENC_SHELL;
		inventory.icon "XLS4A0";
	}
	override void GetItemsThatUseThis(){
		itemsthatusethis.push("ExplosiveHunter");
		//itemsthatusethis.push("ExplosiveSlayer");
	}
	override void SplitPickup(){
		SplitPickupBoxableRound(4,20,"ExplosiveShellBoxPickup","XLS4A0","XLS1A0");
	}
	override string pickupmessage(){
		if(amount>1)return "Picked up some explosive shells.";
		return super.pickupmessage();
	}
	states{
	spawn:
		XLS1 A -1;
		stop;
	death:
		XLLS A -1{
			frame=randompick(0,0,0,0,4,4,4,4,2,2,5);
		}stop;
	}
}
class HDSpentExplosiveShell:HDDebris{
	default{
		-noteleport +forcexybillboard
		seesound "misc/casing2";scale 0.3;height 2;radius 2;
		bouncefactor 0.5;
	}
	override void postbeginplay(){
		super.postbeginplay();
			if(vel==(0,0,0))A_ChangeVelocity(0.0001,0,-0.1,CVF_RELATIVE);
	}
	vector3 lastvel;
	override void Tick(){
		if(!isFrozen())lastvel=vel;
		super.Tick();
	}
	states{
	spawn:
		XLLS ABCDEFGH 2;
		loop;
	death:
		XLLS A -1{
			frame=randompick(0,0,0,0,4,4,4,4,2,2,5);
		}stop;
	}
}
//a shell that can be caught in hand, launched from the Slayer
class HDUnSpentExplosiveShell:HDSpentShell{
	states{
	spawn:
		XLLS ABCDE 2;
		TNT1 A 0{
			if(A_JumpIfInTargetInventory("HDExplosiveShellAmmo",0,"null"))
			A_SpawnItemEx("HDFumblingExplosiveShell",
				0,0,0,vel.x+frandom(-1,1),vel.y+frandom(-1,1),vel.z,
				0,SXF_NOCHECKPOSITION|SXF_ABSOLUTEMOMENTUM
			);else A_GiveToTarget("HDExplosiveShellAmmo",1);
		}
		stop;
	}
}
//any other single shell tumblng out
class HDFumblingExplosiveShell:HDSpentShell{
	default{
		bouncefactor 0.3;
	}
	states{
	spawn:
		XLLS ABCDEFGH 2;
		loop;
	death:
		TNT1 A 0{
			let sss=spawn("HDExplosiveShellAmmo",pos);
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


class ExplosiveShellBoxPickup:HDUPK{
	default{
		//$Category "Ammo/Hideous Destructor/"
		//$Title "Box of Explosive Shells"
		//$Sprite "XLBXA0"
		scale 0.4;
		hdupk.amount 20;
		hdupk.pickupsound "weapons/pocket";
		hdupk.pickupmessage "Picked up some explosive shells.";
		hdupk.pickuptype "HDExplosiveShellAmmo";
		//translation "160:167=80:105";
	}
	states{
	spawn:
		XLBX A -1 nodelay;

	}
}
class ExplosiveShellPickup:IdleDummy{
	default{
		//$Category "Ammo/Hideous Destructor/"
		//$Title "Four Shotgun Shells"
		//$Sprite "XLS4A0"
	}
	states{
	spawn:
		XLS4 A 0 nodelay{
			let iii=hdpickup(spawn("HDExplosiveShellAmmo",pos,ALLOW_REPLACE));
			if(iii){
				hdf.transferspecials(self,iii,hdf.TS_ALL);
				iii.amount=4;
			}
		}stop;
	}
}
