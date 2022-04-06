class GoldSingleAction_Spawner : EventHandler
{
override void CheckReplacement(ReplaceEvent e) {
	switch (e.Replacee.GetClassName()) {
	
		case 'DeinoSpawn' 			: if (!random(0, 9)) {e.Replacement = "GoldSADeinoSpawn";} break;
		}
	e.IsFinal = false;
	}
}
