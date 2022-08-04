class SnubNose_Spawner : EventHandler
{
override void CheckReplacement(ReplaceEvent e) {
	switch (e.Replacee.GetClassName()) {
	
  case 'HDHandgunRandomDrop' 			: if (!random(0,9)) {e.Replacement = "HDSnubNoseRandomDrop";} break;

		case 'DeinoSpawn' 			: if (!random(0, 1)) {e.Replacement = "SnubNoseSpawn";} break;
		}
	e.IsFinal = false;
	}
}

class HDSnubNoseRandomDrop:RandomSpawner{
	default{
		dropitem "HDPistol",16,5;
		dropitem "HDSnubNoseRevolver",16,1;
	}
}
