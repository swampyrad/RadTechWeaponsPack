class GoldSingleAction_Spawner : EventHandler
{
override void CheckReplacement(ReplaceEvent e) {
	switch (e.Replacee.GetClassName()) {

  case 'HDHandgunRandomDrop' 			: if (!random(0,9)) {e.Replacement = "HDGoldenGunRandomDrop";} break;	

		case 'DeinoSpawn' 			: if (!random(0, 9)) {e.Replacement = "GoldSADeinoSpawn";} break;
		}
	e.IsFinal = false;
	}
}

class HDGoldenGunRandomDrop:RandomSpawner{
	default{
		dropitem "HDPistol",16,5;
		dropitem "HDGoldSingleActionRevolver",4,1;
	}
}
