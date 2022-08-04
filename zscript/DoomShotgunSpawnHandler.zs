// Handles the Doomed Shotgun's spawns and controls its usage of HDShellAmmo.
class DoomedShotgunHandler : EventHandler
{
	private bool cvarsAvailable;
	private int spawnBiasActualsg;
	private bool isPersistent;
	void init()
	{
		cvarsAvailable = true;
		spawnBiasActualsg = dHunt_shotgun_spawn_bias;
		isPersistent = dHunt_persistent_spawning;
	}

	override void WorldLoaded(WorldEvent e)
	{
		init();
		super.WorldLoaded(e);
	}

	bool giverandom(int chance)
	{
		bool result = false;
		int iii = random(0, chance);
		if(iii < 0)
			iii = 0;
		if (iii == 0)
		{
			if(chance > -1)
				result = true;
		}
		
		return result;
	}

	void trycreatestryk(worldevent e, int chance)
	{
		if(giverandom(chance))
		{
			let sss = HD_StrikerDropper(e.thing.Spawn("DoomHunterRandom", e.thing.pos, SXF_TRANSFERSPECIAL | SXF_NOCHECKPOSITION));
			if(sss)
			{
				
				e.thing.destroy();
			}

		}
	}
override void worldthingspawned(worldevent e)
  {
	if(!cvarsAvailable)
		init();
	if(!e.Thing)
	{
		return;
	}
	
	let strykAmmo = HDAmmo(e.Thing);
	if (!strykAmmo)
	{
		return;
	}
	switch (strykAmmo.GetClassName())
	{
		case 'HDShellAmmo':
			strykAmmo.ItemsThatUseThis.Push("DoomHunter");
			break;
	}
	if (!(level.maptime > 1) || isPersistent)
	{
		switch(e.Thing.GetClassName())
		{
			case 'ShotgunReplaces':
				trycreatestryk(e, spawnBiasActualsg);
				break;
		}
	}
	}
}