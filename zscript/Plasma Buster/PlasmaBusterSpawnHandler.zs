class PlasmaBuster_Spawner : EventHandler
{
override void CheckReplacement(ReplaceEvent e) {
	switch (e.Replacee.GetClassName()) {
		case 'CellPackReplacer' 			: if (!random(0, 9)) {e.Replacement = "PlasmaBuster";} break;
		}
	e.IsFinal = false;
	}
}

class PlasmaBusterInjector:StaticEventHandler{
override void WorldThingSpawned(WorldEvent e) { 
		let CellAmmo = HDAmmo(e.Thing); 	
	 if (CellAmmo){ 			
  switch (CellAmmo.GetClassName()){
  case 'HDBattery': CellAmmo.ItemsThatUseThis.Push("PlasmaBuster"); 					break;		 		
        }
    	}
 		} 	
} 
