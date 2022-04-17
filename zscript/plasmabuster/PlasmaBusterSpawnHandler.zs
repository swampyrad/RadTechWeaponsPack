class PlasmaBuster_Spawner : EventHandler
{
override void CheckReplacement(ReplaceEvent e) {
	switch (e.Replacee.GetClassName()) {
		case 'CellPackReplacer' 			: if (!random(0, 3)) {e.Replacement = "PlasmaBuster";} break;
		}
	e.IsFinal = false;
	}
}

class PlasmaBusterInjector:StaticEventHandler{
override void WorldThingSpawned(WorldEvent e) { 
		let ShellAmmo = HDAmmo(e.Thing); 	
	 if (ShellAmmo){ 			
  switch (ShellAmmo.GetClassName()){
  case 'HDBattery': ShellAmmo.ItemsThatUseThis.Push("PlasmaBuster"); 					break;		 		
        }
    	}
 		} 	
} 
