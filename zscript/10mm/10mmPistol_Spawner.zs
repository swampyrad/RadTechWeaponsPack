class HD10mmPistol_Spawner : EventHandler
{
override void CheckReplacement(ReplaceEvent e) {
	switch (e.Replacee.GetClassName()) {
	
  case 'HDHandgunRandomDrop' 			: if (!random(0,9)) {e.Replacement = "HDTenMilRandomDrop";} break;

		}
	e.IsFinal = false;
	}
}

class HDTenMilRandomDrop:RandomSpawner{
	default{
		dropitem "HDPistol",16,5;
		dropitem "HD10mmPistol",16,1;
	}
}
