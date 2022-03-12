class DoomShotgun_Spawner : EventHandler
{
override void CheckReplacement(ReplaceEvent e) {
	switch (e.Replacee.GetClassName()) {
		case 'ShotgunReplaces' 			: if (!random(0, 3)) {e.Replacement = "DoomHunterRandom";} break;
		}
	e.IsFinal = false;
	}
}

class DoomedShellInjector:StaticEventHandler{
override void WorldThingSpawned(WorldEvent e) { 
		let ShellAmmo = HDAmmo(e.Thing); 	
	 if (ShellAmmo){ 			
  switch (ShellAmmo.GetClassName()){
  case 'HDShellAmmo': ShellAmmo.ItemsThatUseThis.Push("DoomHunter"); 					break;		 		
        }
    	}
 		} 	
} 
