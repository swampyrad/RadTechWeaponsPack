class JuanEvent : EventHandler
{


	private bool cvarsAvailable;
	private int weaponSpawnBiasActual;
	private int magSpawnBiasActual;
	private int autoSpawnBiasActual;
	private int weaponDropBiasActual;	

	
	// Shoves cvar values into their non-cvar shaped holes.
	// I have no idea why names for cvars become reserved here.
	// But, this works. So no complaints. 
	void init()
	{
		cvarsAvailable = true;
		weaponSpawnBiasActual = ja_weapon_spawn_bias;
		magSpawnBiasActual    = ja_mag_spawn_bias;
		autoSpawnBiasActual   = ja_firemode_chance_bias;
		weaponDropBiasActual  = ja_weapon_drop_chance_bias;
	}

	// 'Initalizes' the event handler,
	// In my testing, this is called after events are fired. 
	override void WorldLoaded(WorldEvent e)
	{
		// always calls init.
		init();
		super.WorldLoaded(e);
	}

	bool giverandom(int chance)
	{
		bool result = false;
		
		// temp storage for the random value. 
		int iii = random(0, chance);
		
		// force negative values to be 0. 
		if(iii < 0)
			iii = 0;
			
		
		if (iii == 0)
		{
			if(chance > -1)
				result = true;
		}
		
		return result;
	}

	// Handles 'item propegation'. Woo, fancy. 
	override void CheckReplacement(ReplaceEvent e)
	{
		// Makes sure the values are always loaded before
		// taking in replaceevents. 
		if(!cvarsAvailable)
			init();
		
		// Don't replace if it's final, or doesn't exist. 
		if (!e.Replacement || e.IsFinal)
		{
			return;
		}
		
		
		switch(e.Replacement.GetClassName())
		{
			case 'HDHandgunRandomDrop':
			case 'PepperPistolReplacer':
				// dirty inverted logic gate for spawn drops. 
				if (random(0, weaponDropBiasActual) || weaponDropBiasActual == -1)
				{
					break;
				}
			case 'HDPistol':
				{
					
					if(giverandom(weaponSpawnBiasActual))
					{
						if(giverandom(autoSpawnBiasActual))
						{
							e.Replacement = "HDHorseShoePistolAuto";
						}
						else
						{
							e.Replacement = "HDHorseShoePistol";
						}
					}
					break;
				}
			case 'HD9mMag15':
				if(giverandom(magSpawnBiasActual))
				{
					e.Replacement = "HDHorseshoe9m"; 
				}
				break;
		}
		
	}

	


	
	// Juan, stop dropping your pellets!	
	override void WorldThingSpawned(WorldEvent e)
	{ 
		let Horsefeed = HDAmmo(e.Thing); 	
		if(Horsefeed)
		{ 			
			switch(Horsefeed.GetClassName())
			{
				case 'HDPistolAmmo':
					Horsefeed.ItemsThatUseThis.Push("HDHorseshoePistol");
					break;		 			
			}
		}
	}
}