class HackedZM_Spawner : EventHandler
{
override void CheckReplacement(ReplaceEvent e) {
	switch (e.Replacee.GetClassName()) {
	
		case 'ZM66Random' 			: if (!random(0, 4)) {e.Replacement = "HackedZM66Random";} break;
		}
	e.IsFinal = false;
	}
}
