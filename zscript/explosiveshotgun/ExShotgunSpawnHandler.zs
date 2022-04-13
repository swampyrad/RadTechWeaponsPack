class ExShotgun_Spawner : EventHandler
{
override void CheckReplacement(ReplaceEvent e) {
	switch (e.Replacee.GetClassName()) {
	
	//Ammo Pickups
	
	//Shotgun shells
		case 'ShellRandom' 				: if (!random(0, 5)) {e.Replacement = "HDExplosiveShellAmmo";} 	break;
		case 'ShellBoxRandom' 			: if (!random(0, 9)) {e.Replacement = "ExplosiveShellBoxPickup";} break; 
		case 'ShotgunReplaces' 			: if (!random(0, 5)) {e.Replacement = "ExplosiveHunter";} break;
		}
	e.IsFinal = false;
	}
}
