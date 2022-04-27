class SingleAction_Spawner : EventHandler
{
override void CheckReplacement(ReplaceEvent e) {
	switch (e.Replacee.GetClassName()) {
	
  case 'HDHandgunRandomDrop' 			: if (!random(0, 9)) {e.Replacement = "HDSingleActionRevolver";} break;

		case 'DeinoSpawn' 			: if (!random(0, 1)) {e.Replacement = "SADeinoSpawn";} break;
		}
	e.IsFinal = false;
	}
}
