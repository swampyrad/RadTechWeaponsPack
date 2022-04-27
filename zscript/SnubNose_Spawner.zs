class SnubNose_Spawner : EventHandler
{
override void CheckReplacement(ReplaceEvent e) {
	switch (e.Replacee.GetClassName()) {
	
  case 'HDHandgunRandomDrop' 			: if (!random(0, 3)) {e.Replacement = "HDSnubNoseRevolver";} break;

		case 'DeinoSpawn' 			: if (!random(0, 1)) {e.Replacement = "SnubNoseSpawn";} break;
		}
	e.IsFinal = false;
	}
}
