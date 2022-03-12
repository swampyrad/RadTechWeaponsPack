class SnubNose_Spawner : EventHandler
{
override void CheckReplacement(ReplaceEvent e) {
	switch (e.Replacee.GetClassName()) {
	
		case 'DeinoSpawn' 			: if (!random(0, 1)) {e.Replacement = "SnubNoseSpawn";} break;
		}
	e.IsFinal = false;
	}
}
