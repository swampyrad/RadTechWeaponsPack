// Wild flaregun spawns; mostly self explanatory. 
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
				if(weaponToSpawn != "none")
				{
					let weapon = Actor.Spawn(invoker.weaponToSpawn, (invoker.pos.x, invoker.pos.y, invoker.pos.z + 5));
					weapon.vel.x += frandom[huminahumina](-2,2);
					weapon.vel.y += frandom[huminahumina](-2,2);
					weapon.vel.z += frandom[huminahumina](1,2);
				}
				
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

// only spawns the ammo (used for spawning ontop of shellpickups). 
class HDFlareAmmoRandom : WildFlareGun
{
	
	default
	{
		wildflaregun.weaponToSpawn "none";
	}
}