class LLShotgun_Spawner : EventHandler
{
override void CheckReplacement(ReplaceEvent e) {
	switch (e.Replacee.GetClassName()) {
	
	//Ammo Pickups
	
	//Shotgun shells
		case 'ShellRandom' 				: if (!random(0, 3)) {e.Replacement = "HDLLShellAmmo";} 	break;
		case 'ShellBoxRandom' 			: if (!random(0, 4)) {e.Replacement = "LLShellBoxPickup";} break; 
		case 'ShotgunReplaces' 			: if (!random(0, 3)) {e.Replacement = "LLHunter";} break;
		}
	e.IsFinal = false;
	}
}
