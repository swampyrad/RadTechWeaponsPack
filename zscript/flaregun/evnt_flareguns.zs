class WildFlareGun : IdleDummy
{
	class<hdweapon> weaponToSpawn;
	property weaponToSpawn : weaponToSpawn;
	
	default
	{
		wildflaregun.weaponToSpawn 'FireBlooper';
	}
	
	states
	{
		Spawn:
			TNT1 A 0 NODELAY
			{
				let weapon = Actor.Spawn(invoker.weaponToSpawn, (invoker.pos.x, invoker.pos.y, invoker.pos.z + 5));
				weapon.vel.x += frandom[huminahumina](-2,2);
				weapon.vel.y += frandom[huminahumina](-2,2);
				weapon.vel.z += frandom[huminahumina](1,2);
				
				let ammo = HDFlareAmmo(Actor.Spawn("HDFlareAmmo", (invoker.pos.x, invoker.pos.y, invoker.pos.z + 5)));
				ammo.vel.x += frandom[huminahumina](-2,2);
				ammo.vel.y += frandom[huminahumina](-2,2);
				ammo.vel.z += frandom[huminahumina](1,2);
				ammo.amount += random(2,5);
			}
			stop;
	}
}

class WildMetalFlareGun : WildFlareGun
{
	
	default
	{
		wildflaregun.weaponToSpawn 'MetalFireBlooper';
	}
}


class FlareEvent : EventHandler
{



	// Inits to false when a map is first loaded. 
	private bool cvarsAvailable;
	
	
	
	// Could these be in a list? Probably,
	// but the cvars already take up unique names. 
	private int weaponSpawnBiasActual;
	private int metalSpawnBiasActual;
	private int flareSpawnBiasActual;
	private int boxSpawnBiasActual;
	private int weaponDropBiasActual;
	
	
	
	// Shoves cvar values into their non-cvar shaped holes.
	// I have no idea why names for cvars become reserved here.
	// But, this works. So no complaints. 
	void init()
	{
		cvarsAvailable = true;
		weaponSpawnBiasActual = fl_weapon_spawn_bias;
		metalSpawnBiasActual  = fl_metal_chance_bias;
		flareSpawnBiasActual  = fl_flare_spawn_bias;
		boxSpawnBiasActual    = fl_box_spawn_bias;
		weaponDropBiasActual  = fl_weapon_drop_chance_bias;
	}



	// 'Initalizes' the event handler,
	// In my testing, this is called after events are fired. 
	override void WorldLoaded(WorldEvent e)
	{
		// always calls init anyways. It's what other worldloaded's do. 
		init();
		super.WorldLoaded(e);
	}



	// Randomizer function, uses one cvar per spawn rate. 
	bool giverandom(int chance)
	{
		bool result = false;
		
		
		// temp storage for the random value. 
		int iii = random(0, chance);


		// Checks to see if the cvar is disabled. 
		if (iii < 1)
		{
			// Zero is true, anything else is false. 
			if(chance > -1)
				result = true;
		}
		
		return result;
	}
	
	
	void AmmoListUpdate(Worldevent e)
	{
		// Seperate ammo handler. 
		// Exclusively for shotgun shells and the metal flaregun upgrade. 
		let hothands = HDAmmo(e.Thing); 	
		if(hothands)
		{ 			
			switch(hothands.GetClassName())
			{
				case 'HDShellAmmo':
					hothands.ItemsThatUseThis.Push("MetalFireBlooper");
					hothands.ItemsThatUseThis.Push("FireBlooper");
					break;	
			}
		}
	}
	
	
	
	void WeaponSpawnRandom(Worldevent e, bool forcedrop=false)
	{	
		// For weapon spawns,
		// works with other mods. 
		if(e.thing is "HDHandgun" || e.thing is "HDShotgun" || forcedrop)
		{
			if(giverandom(weaponSpawnBiasActual) || forcedrop)
			{
				if(giverandom(metalSpawnBiasActual))
				{
					WildMetalFlareGun(Actor.Spawn('WildMetalFlareGun', e.Thing.pos));
				}
				else
				{
					WildFlareGun(Actor.Spawn('WildFlareGun', e.Thing.pos));
				}
			}
		}
	}
	
	// For ammo drops,
	// uses 'is' for the sake of replacement mods.
	// has force switches for letting other drop code access these. 
	void AmmoSpawnRandom(WorldEvent e, bool forcebox=false, bool forceshell=false)
	{
	
		if(e.thing is "ShellBoxPickup" || forcebox)
		{
			if(giverandom(boxSpawnBiasActual) || forcebox)
			{
				let aaa = FlareShellBoxPickup(Actor.Spawn('FlareShellBoxPickup', (e.Thing.pos.x, e.Thing.pos.y, e.Thing.pos.z + 5)));
				aaa.vel.x += frandom[huminahumina](-2,2);
				aaa.vel.y += frandom[huminahumina](-2,2);
				aaa.vel.z += frandom[huminahumina](1,2);
				// as a treat. 
				WeaponSpawnRandom(e, true);
			}
		}
		else if(e.thing is "ShellPickup" || forceshell)
		{
			if(giverandom(flareSpawnBiasActual) || forceshell)
			{
				let aaa = HDFlareAmmo(Actor.Spawn('HDFlareAmmo', (e.Thing.pos.x, e.Thing.pos.y, e.Thing.pos.z + 5)));
				aaa.vel.x += frandom[huminahumina](-2,2);
				aaa.vel.y += frandom[huminahumina](-2,2);
				aaa.vel.z += frandom[huminahumina](1,2);
				aaa.amount += random(5,10);
			}
		}
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
				else
				{
					if(giverandom(metalSpawnBiasActual))
					{
						e.replacement = "WildMetalFlareGun";
					}
					else
					{
						e.replacement = "WildFlareGun";
					}
				}
		}
		
	}
	
	
	
	// Things are about to get... crispy. 
	override void WorldThingSpawned(WorldEvent e)
	{ 
		// Makes sure the values are always loaded before
		// taking in events.
		if(!cvarsAvailable)
			init();
		
		// in case it's not real. 
		if(!e.Thing)
		{
			return;
		}
		else
		{
			// In case the thing in question is owned by someone.
			// We check for this since a variable like e.isfinal
			// doesn't exist for worldthingspawned :(
			if(e.Thing is "Inventory" && Inventory(e.Thing).Owner)
			{
				// Ammo owned has to have it's list updated.
				AmmoListUpdate(e);
				return;
			}
			
			// Updates the item if it's an ammo. 
			AmmoListUpdate(e);
			
			// Don't spawn anything if the level has been loaded more than a tic.
			if (!(level.maptime > 1))
			{
				WeaponSpawnRandom(e);
				AmmoSpawnRandom(e);
			}	
		}
	}
}