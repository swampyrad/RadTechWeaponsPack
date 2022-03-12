Adds a 9mm pistol variant, the Juan, which can hold up to 30 rounds.
The Juan kicks noticably more than a normal pistol, and kicks harder the 
emptier it's magazine currently is. 
--------------------------------------------------------------------------------
Loadout codes,
	Juan: jua,
	Horseshoe Magazine: j30.
 
Loadout flags,
	Fullauto: jua selectfire.
--------------------------------------------------------------------------------
Cvars:
integer info:
	- set to 0 for 100% chance, -1 to disable,
	- chance is 1 in cvar + 1, (EX, 2 is 1 in 3).  
|------------------------------------------------|
|type   | name                     | defaults    |
|------------------------------------------------|
|integer|ja_weapon_spawn_bias      | 19| 1 in 20 |
|integer|ja_mag_spawn_bias         |  9| 1 in 10 |
|integer|ja_firemode_chance_bias   | 49| 1 in 50 |
|integer|ja_weapon_drop_chance_bias| 49| 1 in 50 |
|------------------------------------------------|