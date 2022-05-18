class Sigcow_Spawner : EventHandler
{
override void CheckReplacement(ReplaceEvent e) {
	switch (e.Replacee.GetClassName()) {

case 'ClipBoxPickup' 			: if (!random(0, 4)) {e.Replacement = "SigCowRandomSpawn";} break;
		}
	e.IsFinal = false;
	}
}

class SigCowRandomSpawn:IdleDummy{
	override void postbeginplay(){
		super.postbeginplay();
		A_SpawnItemEx("HD10mMag25",flags:SXF_NOCHECKPOSITION);
		if(random(0,2))A_SpawnItemEx("HDFragGrenadeAmmo",-3,-3,flags:SXF_NOCHECKPOSITION);
		if(random(0,9)){
    A_SpawnItemEx("TenMilAutoReloader",5,5,flags:SXF_NOCHECKPOSITION);
			A_SpawnItemEx("HD10mMag25",3,3,flags:SXF_NOCHECKPOSITION);
			A_SpawnItemEx("HDSigCowSelectfire",1,1,flags:SXF_NOCHECKPOSITION);
		}else if(random(0,4)){
			A_SpawnItemEx("HD10mMag25",3,3,flags:SXF_NOCHECKPOSITION);
			A_SpawnItemEx("HDSigCowSemiBurst",1,1,flags:SXF_NOCHECKPOSITION);
		}else A_SpawnItemEx("HDSigCowSemi",1,1,flags:SXF_NOCHECKPOSITION);
		destroy();
	}
}
