class SingleAction_Spawner : EventHandler
{
override void CheckReplacement(ReplaceEvent e) {
	switch (e.Replacee.GetClassName()) {
	
		case 'DeinoSpawn' 			: if (!random(0, 1)) {e.Replacement = "SADeinoSpawn";} break;
		}
	e.IsFinal = false;
	}
}
