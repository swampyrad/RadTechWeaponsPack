class Sigcow_Spawner : EventHandler
{
override void CheckReplacement(ReplaceEvent e) {
	switch (e.Replacee.GetClassName()) {

//these are fucking broken lmao	

		//case 'HD9mMag15' 				: if (!random(0, 2)) {e.Replacement = "HD10mMag15";} 	break;
		//case 'HD9mMag30' 			: if (!random(0, 2)) {e.Replacement = 'HD10mMag50';} break; 
//		case 'HDSMG' 			: if (!random(0, 2)) {e.Replacement = "HDSigCow";} break;
//case 'HDPistol' 			: if (!random(0, 2)) {e.Replacement = "HD10mmPistol";} break;

case 'ZMRandom' 			: if (!random(0, 2)) {e.Replacement = "SigCowRandomSpawn";} break;
		}
	e.IsFinal = false;
	}
}
