class HD10mmPistol_Spawner : EventHandler
{
override void CheckReplacement(ReplaceEvent e) {
	switch (e.Replacee.GetClassName()) {


  case 'ClipMagPickup' 			: if (!random(0,9)) {e.Replacement = "HD10mmMagPickup";} break;


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


class HD10mmMagPickup:HDInvRandomSpawner{
	default{
		dropitem "HD10mMag8",256,8;
		dropitem "HD10mMag25",256,4;
		dropitem "HD10mBoxPickup",256,1;
	}
}




