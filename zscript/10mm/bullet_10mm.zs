class HDB_10:HDBulletActor{
	default{
		pushfactor 0.25;//high-velocity, better grouping
		mass 120; // 2g more than 355
		speed HDCONST_MPSTODUPT*400;//50m per sec faster than 355
		accuracy 200;//Round ball bullet
		stamina 1000;//10mm, 1000
		woundhealth 18;//20% stronger than 355
		hdbulletactor.hardness 3;//Copper FMJ rounds
	}
}
/* for reference, 10mm should be just a bit better than 355,
almost twice as powerful as 9mm, but high recoil due to hot load

class HDB_355:HDBulletActor{
	default{
		pushfactor 0.3;
		mass 99;
		speed HDCONST_MPSTODUPT*355;//600;
		accuracy 355;
		stamina 902;
		woundhealth 15;
		hdbulletactor.hardness 3;
	}
}

*/
