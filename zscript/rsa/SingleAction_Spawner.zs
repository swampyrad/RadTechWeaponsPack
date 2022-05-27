class SingleAction_Spawner : EventHandler
{
override void CheckReplacement(ReplaceEvent e) {
	switch (e.Replacee.GetClassName()) {
	
  case 'HDHandgunRandomDrop' 			: if (!random(0,9)) {e.Replacement = "HDSingleActionRandomDrop";} break;

		case 'DeinoSpawn' 			: if (!random(0, 1)) {e.Replacement = "SADeinoSpawn";} break;
		}
	e.IsFinal = false;
	}
}

class HDSingleActionRandomDrop:RandomSpawner{
	default{
		dropitem "HDPistol",16,5;
		dropitem "HDSingleActionRevolver",16,1;
	}
}
