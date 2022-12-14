# RadTechWeaponsPack

A collection of weapons for the GZDoom mod 'Hideous Destructor' made by Swampyrad and more.
**Requires [HDBulletLib-Recasted](https://github.com/Gay-Snake-Squad/HDBulletLib-Recasted)!**

## M-211 Semi-Automatic Gas-Operated Combat Weapon

* **Actor Class**: `HDSigCow`
* **Loadout Code**: `scw`
  * `selectfire [0/1]` - whether it has a fire selector or not
  * `firemode [0/1]` - semi/auto, subject to the above
* **Ammunition Code**: `s25`
  * A pistol-caliber carbine chambered in 10mm Auto and the trusted weapon of the UAC's Light Drop Infantry Division. Comes with a bayonet affixed by default for close-quarters engagements or can opening.

![Thumbnail](https://github.com/Gay-Snake-Squad/RTWP-ImageHosting/blob/main/Screenshots/m211sigcow.png)

### M-211 Sigcow Settings

* **Spawn Bias**: `sigcow_cbox_spawn_bias` - How common the M-211 Sigcow spawns on Clip Boxes. Lower is more common.
  * `19` = Default Spawn Chance
* **Persistent Spawning**: `sigcow_persistent_spawning` - If the M-211 Sigcow can spawn after mapload.
  * `False` = Default Value
  * `True` = Enables persistency for spawning

### M-211 Sigcow Controls

* **Fire**: Shoot
* **Alt. Fire**: Bayonet Stab
* **Reload**: Reload magazine
* **Use + Reload**: Reload chamber
* **Firemode**: Semi/Auto/Burst
* **User3**: Magazine Manager
* **Unload**: Unload magazine/GL

## Obrozz Sawn-Off Boss Rifle

* **Actor Class**: `ObrozzPistol`
* **Loadout Code**: `obz`
  * `customchamber [0/1]` - whether to reduce jam change for less power
  * `frontreticle [0/1]` - whether crosshair size scales with zoom
  * `bulletdrop [0-600]` - amount of bullet drop compensation
  * `zoom - [16-70]` - Scope zoom, 10x the resulting FOV in degrees
* **Ammunition Code**: `710 | 7mm | 7mr`
  * An Obrez'd version of the Mk. IV Boss bolt-action rifle. A crude but deadly weapon, "Obrez" pistols were used by resistance members of the past for assasinations and self defense. The stock and barrel have been cut down to make one-handed firing possible, and its small size makes it easier to conceal than a full-length rifle.

![Thumbnail](https://github.com/Gay-Snake-Squad/RTWP-ImageHosting/blob/main/Screenshots/obrozzsawedoffboss.png)

### Obrozz Settings

* **Spawn Bias**: `obrozz_spawn_bias` - How common the Obrozz spawns on Hunters. Lower is more common.
  * `24` = Default Spawn Chance
* **Persistent Spawning**: `obrozz_persistent_spawning` - If the Obrozz can spawn after mapload.
  * `False` = Default Value
  * `True` = Enables persistency for spawning

### Obrozz Controls

* **Fire**: Shoot
* **Firemode**: Quick-swap
* **Alt. Fire**: Work bolt
* **Reload**: Reload rounds/clip
* **Zoom + Firemode + Mouselook**: Adjust Zoom
* **Zoom + Use** Adjust bullet drop
* **Zoom + Drop** Force drop non-recast
* **Zoom + Alt. Reload** Force load recast
* **Alt. Fire + Unload** Unload Chamber/Clean Rifle
* **Unload**: Unload

## Hacked ZM66 Assault Rifle

* **Actor Class**: `HackedZM66AssaultRifle`
* **Loadout Code**: `hzm`
  * `nogl [0/1]` - whether it has a grenade launcher or not
  * `semi [0/1]` - whether it has a fire selector or not
  * `firemode [0/1/2]` whether it starts in semi, automatic or burst. Subject to the above.
  * `zoom [16-70]` - Scope zoom, 10x the resulting FOV in degrees
  * `dot [0-5]` - Chosen reflex sight dot
* **Ammunition Code**: `450`
  * A 'jailbroken' model of the Volt ZM66 assault rifle. This weapon has been stripped of most of its 'less desirable' features, mainly being the magazine DRM system. The firerate is reduced and the ammo counter is non-functional, but most users give it a unique 4-round "Quad-Burst" firemode as a compromise.

![Thumbnail](https://github.com/Gay-Snake-Squad/RTWP-ImageHosting/blob/main/Screenshots/hackedzm66.png)

### Hacked ZM66 Settings

* **Spawn Bias**: `hacked_zm66_spawn_bias` - How common the Hacked ZM66 spawns on ZM66s. Lower is more common.
  * `19` = Default Spawn Chance
* **Persistent Spawning**: `hacked_persistent_spawning` - If the Hacked ZM66 can spawn after mapload.
  * `False` = Default Value
  * `True` = Enables persistency for spawning

### Hacked ZM66 Controls

* **Fire**: Shoot
* **Alt. Fire**: Swap between GL mode and RIfle mode
* **Reload**: Reload magazine
* **Alt. Reload**: Reload GL
* **Firemode**: Semi/Auto/Burst
* **GL Mode + Firemode + Mouselook** Adjust airburst
* **Zoom + Firemode + Mouselook**: Adjust Zoom
* **User3**: Magazine Manager
* **Unload**: Unload magazine/GL

## Sten Mk. 2(S)

* **Actor Class**: `HDStenMk2`
* **Loadout Code**: `mk2`
* **Ammunition Code**: `930`
  * An old sub-machine gun designed and used by the British during WWII, known mostly for being problematic due to its jamming and overheating issues. This version has been modified with an integrally suppressed barrel, making its overall sound signature comparable to a handclap at best. Many compare it to the MP-46 SMG of today's time, though very few use it over that due to its many issues.

![Thumbnail](https://github.com/Gay-Snake-Squad/RTWP-ImageHosting/blob/main/Screenshots/Sten.png)

### Sten Mk. 2(S) Settings

* **Spawn Bias**: `sten_spawn_bias` - How often the Sten Mk. 2(S) spawns on SMGs. Lower is more common.
  * `19` = Default Spawn Chance
* **Spawn Bias**: `sten_ammobox_spawn_bias` - How often the Sten Mk. 2(S) spawns on Clip Boxes. Lower is more common.
  * `19` = Default Spawn Chance
* **Persistent Spawning**: `sten_persistent_spawning` - If the Sten Mk. 2(S) can spawn after mapload.
  * `False` = Default Value
  * `True` = Enables persistency for spawning

### Sten Mk. 2(S) Controls

* **Fire**: Shoot
* **Alt. Reload**: Quick-Swap (if available)
* **Reload**: Reload magazine
* **Use + Reload**: Reload chamber
* **User3**: Magazine Manager
* **Unload**: Unload

## Minerva 9mm Chaingun

* **Actor Class**: `MinervaChaingun`
* **Loadout Code**: `mnv`
  * `fast [0/1]` - whether to start in "fuller auto" mode or not
  * `zoom [16-70]` - Scope zoom, 10x the resulting FOV in degrees
  * `dot [0-5]` - Chosen reflex sight dot
* **Ammunition Code**: `930`
  * A support weapon chambered in 9mm, takes standard UAC SMG magazines and can hold a total of 150+5 rounds, or 5 magazines plus a round chambered. Remember to hold onto empty magazines, they're a lot more expensive than 4mm ones.

![Thumbnail](https://github.com/Gay-Snake-Squad/RTWP-ImageHosting/blob/main/Screenshots/minerva9mmchaingun.png)

### Minerva Settings

* **Spawn Bias**: `minerva_chaingun_spawn_bias` - How common the Minerva spawns on Vulcanettes. Lower is more common.
  * `24` = Default Spawn Chance
* **Spawn Bias**: `minerva_smg_spawn_bias` - How common the Minerva spawns on SMGs. Lower is more common.
  * `19` = Default Spawn Chance
* **Persistent Spawning**: `minerva_persistent_spawning` - If the Minerva can spawn after mapload.
  * `False` = Default Value
  * `True` = Enables persistency for spawning

### Minerva Controls

* **Fire**: Shoot
* **Reload**: Reload magazines
* **Alt. Reload**: Reload battery
* **Firemode**: Switch to 2100 RPM
* **Zoom + Firemode + Mouselook**: Adjust Zoom
* **Zoom + Unload** Repair
* **User3**: Magazine Manager
* **Unload**: Unload magazines
* **Use + Unload or Alt. Reload**: Unload Battery

## Doomed Hunter

* **Actor Class**: `DoomHunter`
* **Loadout Code**: `dsg`
* **Ammunition Code**: `shl`
  * A modified hunter designed to mimic the behavior of the vanilla Doom shotgun, fitted with a duckbill choke for a V-shaped spread pattern and an old-school pumping animation

![Thumbnail](https://github.com/Gay-Snake-Squad/RTWP-ImageHosting/blob/main/Screenshots/doomedhunter.png)

### Doomed Hunter Settings

* **Spawn Bias**: `dHunt_shotgun_spawn_bias` - How common the Doomed Hunter spawns on Shotguns. Lower is more common.
  * `19` = Default Spawn Chance
* **Persistent Spawning**: `dHunt_persistent_spawning` - If the Doomed Hunter can spawn after mapload.
  * `False` = Default Value
  * `True` = Enables persistency for spawning

### Doomed Hunter Controls

* **Fire**: Shoot
* **Alt-Fire**: Pump
* **Reload**: Reload (side saddles first)
* **Alt-Reload**: Reload (pockets first)
* **Firemode**: Pump/Semi
* **Firemode + Reload**: Load side saddles only
* **Unload**: Unload
* **Use + Unload** Steal ammo from Slayer

## Ithaca M37 Combat Shotgun

* **Actor Class**: `HDCombatShotgun`
* **Loadout Code**: `csg`
* **Ammunition Code**: `shl`
  * A compact shotgun often seen in the hands of space marines throughout the galaxy. Despite having no side saddles, or a butt stock to attach them to, in the right hands it's just as deadly as any other shotgun. Toss one in your pack the next time you leave base, it might become incredibly handy.

![Thumbnail](https://github.com/Gay-Snake-Squad/RTWP-ImageHosting/blob/main/Screenshots/combatshotgun.png)

### Ithaca M37 Settings

* **Spawn Bias**: `cshotgun_shotgun_spawn_bias` - How common the Ithaca M37 spawns on Hunters. Lower is more common.
  * `24` = Default Spawn Chance
* **Persistent Spawning**: `cshotgun_persistent_spawning` - If the Ithaca M37 can spawn after mapload.
  * `False` = Default Value
  * `True` = Enables persistency for spawning

### Ithaca M37 Controls

* **Fire**: Shoot
* **Alt-Fire**: Pump
* **Reload**: Reload
* **Unload**: Unload

## Explosive Shotgun

* **Actor Class**: `ExplosiveHunter`
* **Loadout Code**: `xsg`
  * `firemode [0/1]` - Pump/Semi
* **Ammunition Code**: `xsh`
  * The antithesis of the Less-Lethal Shotgun, this modified Hunter fires shells loaded with miniature HE grenade slugs, causing serious injuries and burns upon impact. Using this weapon in close quarters is usually ill-advised, as the slug's propellent may splash back at the user and burn them along with their target.

![Thumbnail](https://github.com/Gay-Snake-Squad/RTWP-ImageHosting/blob/main/Screenshots/explosiveshotgun.png)

### Explosive Shotgun Settings

* **Spawn Bias**: `esg_shotgun_spawn_bias` - How common the Explosive Shotgun spawns on Hunters. Lower is more common.
  * `49` = Default Spawn Chance
* **Persistent Spawning**: `esg_persistent_spawning` - If the Explosive Shotgun can spawn after mapload.
  * `False` = Default Value
  * `True` = Enables persistency for spawning

### Explosive Shotgun Controls

* **Fire**: Shoot
* **Alt-Fire**: Pump
* **Reload**: Reload (side saddles first)
* **Alt-Reload**: Reload (pockets first)
* **Firemode**: Pump/Semi
* **Firemode + Reload**: Load side saddles only
* **Unload**: Unload

## Bernoulli M1053 Less-Lethal Shotgun

* **Actor Class**: `LLHunter`
* **Loadout Code**: `llh`
* **Ammunition Code**: `lls`
  * A polymer-based shotgun designed for riot control and crowd dispersion. It's chambered for Less-Lethal shotgun shells, which contain a load of rubberized buckshot pellets. Useful for situations where a low fatality count is crucial.

![Thumbnail](https://github.com/Gay-Snake-Squad/RTWP-ImageHosting/blob/main/Screenshots/lesslethalhunter.png)

### Bernoulli M1053 Settings

* **Spawn Bias**: `llh_shotgun_spawn_bias` - How common the Bernoulli M1053 spawns on Hunters. Lower is more common.
  * `49` = Default Spawn Chance
* **Persistent Spawning**: `llh_persistent_spawning` - If the Bernoulli M1053 can spawn after mapload.
  * `False` = Default Value
  * `True` = Enables persistency for spawning

### Bernoulli M1053 Controls

* **Fire**: Shoot
* **Alt-Fire**: Pump
* **Reload**: Reload (side saddles first)
* **Alt-Reload**: Reload (pockets first)
* **Firemode + Reload**: Load side saddles only
* **Unload**: Unload

## Single-Action Revolver

* **Actor Class**: `HDSingleActionRevolver`
* **Loadout Code**: `rsa`
* **Ammunition Code**: `45l`
  * An ancient firearm better suited for a cowboy than a space marine. Chambered in .45 Long COlt, this revolver will definitely punch a hole in whatever it hits. It has a much greater ricochet chance which makes it handy for bouncing rounds off walls to perform 'trickshots'.

![Thumbnail](https://github.com/Gay-Snake-Squad/RTWP-ImageHosting/blob/main/Screenshots/singleactionrevolver.png)

### Single-Action Revolver Settings

* **Spawn Bias**: `sa_pistol_spawn_bias` - How common the Single-Action spawns on Handguns. Lower is more common.
  * `24` = Default Spawn Chance
* **Persistent Spawning**: `sa_persistent_spawning` - If the Single-Action can spawn after mapload.
  * `False` = Default Value
  * `True` = Enables persistency for spawning

### Single-Action Controls

* **Fire**: Shoot | Close cylinder
* **Alt-Fire**: Pull back hammer | Cycle Cylinder
* **Alt. Reload or Firemode**: Quick-Swap
* **Reload**: Open Cylinder | Load round (Hold Firemode to force using 9mm)
* **Unload**: Open Cylinder | Hit extractor
* **Zoom**: Reverse cylinder cycle

## Juan 9mm 'Horseshoe' Pistol

* **Actor Class**: `HDHorseshoePistol`
* **Loadout Code**: `jua`
  * `selectfire [0|1]` - whether it has a fire selector or not
  * `firemode [0|1]` - semi/auto, subject to the above
* **Ammunition Code**: `j30 | 915`
  * A variant of the standard-issue pistol, albeit with compatibility for a non-standard issue magazine. As the name suggests, it used to only use a unique "horseshoe" magazine that holds 30 rounds, though recent models have been modified to accept standard pistol mags. However, its small size makes it hard to control in full-auto mode, which experienced users remedy by using a "galloping" shooting pattern, firing in short, controlled bursts to stay on target.

![Thumbnail](https://github.com/Gay-Snake-Squad/RTWP-ImageHosting/blob/main/Screenshots/juanpistol.png)

### Juan Pistol Settings

* **Spawn Bias**: `ja_weapon_spawn_bias` - How common the Juan spawns on Handguns. Lower is more common.
  * `19` = Default Spawn Chance
* **Spawn Bias**: `ja_mag_spawn_bias` - How common Juan Magazines spawn on 9mm Pistol Magazines. Lower is more common.
  * `9` = Default Spawn Chance
* **Spawn Bias**: `ja_firemode_chance_bias` - How common Select-Fire Juans spawn on Handguns. Lower is more common.
  * `49` = Default Spawn Chance
* **Drop Bias**: `ja_weapon_drop_chance_bias` - How common Juans drop from enemies. Lower is more common.
  * `49` = Default Spawn Chance

### Juan Controls

* **Fire**: Shoot
* **Alt. Reload**: Quick-Swap (if available)
* **Reload**: Reload magazine (horseshoe mags first)
* **Use + Reload**: Reload chamber
* **User3**: Magazine Manager
* **Unload**: Unload

## 'Hush Puppy' Suppressed Pistol

* **Actor Class**: `HushpuppyPistol`
* **Loadout Code**: `pup`
* **Ammunition Code**: `915`
  * A modified 99FX with a suppressor attachment. Single-action only.

![Thumbnail](https://github.com/Gay-Snake-Squad/RTWP-ImageHosting/blob/main/Screenshots/Puppy.png)

### 'Hush Puppy' Settings

* **Spawn Bias**: `hushpuppy_spawn_bias` - How often the Hush Puppy spawns on Handguns. Lower is more common.
  * `19` = Default Spawn Chance
* **Persistent Spawning**: `hushpuppy_persistent_spawning` - If the Hush Puppy can spawn after mapload.
  * `False` = Default Value
  * `True` = Enables persistency for spawning

### 'Hush Puppy' Controls

* **Fire**: Shoot
* **Alt. Fire**: Rack slide
* **Alt. Reload**: Quick-Swap (if available)
* **Reload**: Reload magazine
* **Use + Reload**: Reload chamber
* **User3**: Magazine Manager
* **Unload**: Unload

## Colt 1911 .45 Pistol

* **Actor Class**: `HDColt1911`
* **Loadout Code**: `c19`
* **Ammunition Code**: `cm7`
  * An old service pistol made many centuries ago, using .45 ACP rounds as it's ammunition. Still packs quite a punch, getting relatively close to the 10mm Delta Elites used by police forces until recently. Just make sure to take good care of it.

![Thumbnail](https://github.com/Gay-Snake-Squad/RTWP-ImageHosting/blob/main/Screenshots/Coltm1911.png)

### Colt 1911 Settings

* **Spawn Bias**: `colt1911_spawn_bias` - How common the Colt 1911 spawns on Handguns. Lower is more common.
  * `19` = Default Spawn Chance
* **Spawn Bias**: `colt1911_ammobox_spawn_bias` - How common the Colt 1911 spawns on ammo boxes. Lower is more common.
  * `19` = Default Spawn Chance
* **Spawn Bias**: `colt1911_mags_spawn_bias` - How common the Colt 1911's mags spawn on magazines. Lower is more common.
  * `19` = Default Spawn Chance
* **Persistent Spawning**: `colt1911_persistent_spawning` - If the Colt 1911 can spawn after mapload.
  * `False` = Default Value
  * `True` = Enables persistency for spawning

### Colt 1911 Controls

* **Fire**: Shoot
* **Alt. Reload**: Quick-Swap (if available)
* **Reload**: Reload magazine
* **Use + Reload**: Reload chamber
* **User3**: Magazine Manager
* **Unload**: Unload

## Delta Elite 10mm Pistol

* **Actor Class**: `HD10mmPistol`
* **Loadout Code**: `p1m`
  * `selectfire [0|1]` - whether it has a fire selector or not
  * `firemode [0|1]` - semi/auto, subject to the above
* **Ammunition Code**: `sc8`
  * A handgun released in the late 80s, adopted by the FBI following the aftermath of a tragic shooting incident that resulted in the deaths of two special angents. This pistol offers better penetration and higher muzzle velocity than either 9mm or .355 firearms, but is much harder to control due to the increased recoil.

![Thumbnail](https://github.com/Gay-Snake-Squad/RTWP-ImageHosting/blob/main/Screenshots/deltaelite.png)

### Delta Elite Settings

* **Spawn Bias**: `tenpis_handgun_spawn_bias` - How common the Delta Elite spawns on Handguns. Lower is more common.
  * `19` = Default Spawn Chance
* **Persistent Spawning**: `tenpis_persistent_spawning` - If the Delta Elite can spawn after mapload.
  * `False` = Default Value
  * `True` = Enables persistency for spawning

### Delta Elite Controls

* **Fire**: Shoot
* **Alt-Reload**: Quick-Swap
* **Reload**: Reload mag
* **Use + Reload** Reload chamber
* **User3** Magazine Manager
* **Unload**: Unload

## Detective Special Snubnose Revolver

* **Actor Class**: `HDSnubNoseRevolver`
* **Loadout Code**: `snb`
* **Ammunition Code**: `355`
  * A sidearm once popular with police and private investigators of the past, this revolver fits better in your pocket, at the cost of accuracy and firepower.

![Thumbnail](https://github.com/Gay-Snake-Squad/RTWP-ImageHosting/blob/main/Screenshots/snubnoserevolver.png)

### Detective Special Settings

* **Spawn Bias**: `snose_pistol_spawn_bias` - How common the Detective Special spawns on Handguns. Lower is more common.
  * `19` = Default Spawn Chance
* **Persistent Spawning**: `snose_persistent_spawning` - If the Detective Special can spawn after mapload.
  * `False` = Default Value
  * `True` = Enables persistency for spawning

### Detective Special Controls

* **Fire**: Shoot | Close cylinder
* **Alt-Fire**: Pull back hammer | Cycle Cylinder
* **Alt. Reload or Firemode**: Quick-Swap
* **Reload**: Open Cylinder | Load round (Hold Firemode to force using 9mm)
* **Unload**: Open Cylinder | Hit extractor (Double tap to dump live rounds)
* **Zoom**: Reverse cylinder cycle

## DM-93 Plasma Rifle

* **Actor Class**: `PlasmaBuster`
* **Loadout Code**: `d93`
* **Ammunition Code**: `bat`
  * A revised version of the "Thunder Buster" particle beam gun. After receiving a disturbing number of incident reports involving self-detonations caused by careless use of the Thunder Buster, UAC tasked a junior researcher with finding a solution to this problem. The answer was found when they tweaked the ion emitter so that the plasma particles are contained an electromagnetic field which holds it together until it impacts a target. This plasma has a smaller, but safer blast radius so direct contact is required to cause maximum damage. Automatic fire emits an accurate stream of projectiles, while burst-fire shoots out a spread of multiple shots intended for close-quarters encounters.

![Thumbnail](https://github.com/Gay-Snake-Squad/RTWP-ImageHosting/blob/main/Screenshots/dm93.png)

### DM-93 Settings

* **Spawn Bias**: `pbuster_cpack_spawn_bias` - How common the DM-93 Plasma Rifle spawns on Cell Packs. Lower is more common.
  * `19` = Default Spawn Chance
* **Persistent Spawning**: `pbuster_persistent_spawning` - If the DM-93 Plasma Rifle can spawn after mapload.
  * `False` = Default Value
  * `True` = Enables persistency for spawning

### DM-93 Controls

* **Fire**: Automatic fire
* **Alt-Fire**: Burst fire
* **Reload**: Reload battery
* **Unload**: Unload battery

## Phazer Energy Pistol

* **Actor Class**: `PhazerPistol`
* **Loadout Code**: `phz`
* **Ammunition Code**: `mcl`
  * A "sidearm" version of the Plasma Rifle. Fires in semi-auto only to compensate for its reduced power output, Uses Micro-Cell Batteries. It uses a compact version of the cell battery, which has half the charge and bulk of a full-sized cell.

![Thumbnail](https://github.com/Gay-Snake-Squad/RTWP-ImageHosting/blob/main/Screenshots/Phazer.png)

### Phazer Pistol Settings

* **Spawn Bias**: `phazer_spawn_bias` - How often the Phazer spawns on Clip Boxes. Lower is more common.
  * `19` = Default Spawn Chance
* **Persistent Spawning**: `phazer_persistent_spawning` - If the Phazer can spawn after mapload.
  * `False` = Default Value
  * `True` = Enables persistency for spawning

### Phazer Pistol Controls

* **Fire**: Shoot
* **Firemode**: Quick-swap
* **Reload**: Reload
* **Unload**: Unload

## Stun Gun

* **Actor Class**: `HDStunGun`
* **Loadout Code**: `stu`
* **Ammunition Code**: `mcl`
  * A common device used for personal protection. Delivers high voltage into your foes, rendering them a smouldering pile of flesh.

![Thumbnail](https://github.com/Gay-Snake-Squad/RTWP-ImageHosting/blob/main/Screenshots/Stun.png)

### Stun Gun Settings

* **Spawn Bias**: `stungun_spawn_bias` - How often the Stun Gun spawns on Chainsaws. Lower is more common.
  * `19` = Default Spawn Chance
* **Persistent Spawning**: `stungun_persistent_spawning` - If the Stun Gun can spawn after mapload.
  * `False` = Default Value
  * `True` = Enables persistency for spawning

### Stun Gun Controls

* **Fire**: Zap
* **Alt. Fire**: Quick Prod
* **Reload**: Reload
* **Unload**: Unload

## Dynamite

* **Actor Class**: `HDDynamiteAmmo`
* **Loadout Code**: `dyn`
  * Apparently mostly re-surfacing after a large cult was found and dispatched by an unknown force, dynamite originally was known as a 'wild west' sort of thing usually used for mining out large areas. Currently though, it serves its job perfectly well by blowing up your foes.

![Thumbnail](https://github.com/Gay-Snake-Squad/RTWP-ImageHosting/blob/main/Screenshots/Dynamite.png)

### Dynamite Settings

* **Spawn Bias**: `dynamite_spawn_bias` - How often Dynamite spawns on grenades. Lower is more common.
  * `19` = Default Spawn Chance
* **Persistent Spawning**: `dynamite_persistent_spawning` - If Dynamite can spawn after mapload.
  * `False` = Default Value
  * `True` = Enables persistency for spawning

### Dynamite Controls

* **Fire**: Light Fuse/Wind Up
* **Alt. Reload**: Ready lighter
* **Reload**: Abort/close lighter
* **Firemode**: Plant a bomb

## Flare Guns

* **Actor Class**: `FireBlooper | MetalFireBlooper`
* **Loadout Codes**: `fgn | fgm`
* **Ammunition Code**: `fsh`
  * A common survival tool, useful for lighting up dark areas, or the occasional foe. Both are also capable of firing 12-gauge buckshot shells, but the plastic variant can't take as much abuse.

![Thumbnail](https://github.com/Gay-Snake-Squad/RTWP-ImageHosting/blob/main/Screenshots/flareguns.png)

### Flare Gun Settings

* **Spawn Bias**: `fl_weapon_spawn_bias` - How common the Plastic Flare Gun spawns on various weapons. Lower is more common.
  * `19` = Default Spawn Chance
* **Drop Bias**: `fl_weapon_drop_chance_bias` - How common the Plastic Flare Gun drops from enemies. Lower is more common.
  * `19` = Default Spawn Chance
* **Persistent Spawning**: `fl_weapon_persistent_spawning` - If the Plastic Flare Gun can spawn after mapload.
  * `False` = Default Value
  * `True` = Enables persistency for spawning

* **Spawn Bias**: `fl_metal_spawn_bias` - How common the Metal Flare Gun spawns on various weapons. Lower is more common.
  * `49` = Default Spawn Chance
* **Drop Bias**: `fl_metal_drop_chance_bias` - How common the Metal Flare Gun drops from enemies. Lower is more common.
  * `49` = Default Spawn Chance
* **Persistent Spawning**: `fl_metal_persistent_spawning` - If the Metal Flare Gun can spawn after mapload.
  * `False` = Default Value
  * `True` = Enables persistency for spawning

### Flare Gun Controls

* **Fire**: Shoot
* **Alt-Fire or Firemode**: Quick-Swap (if available)
* **Reload**: Reload flare shell
* **Alt. Reload**: Load a shotgun shell
* **Unload**: Unload

## Credits

* 1911 sprites provided courtesy of ChopBlock223 from the HD Discord
* Flaregun sprites by FDA and Swampyrad
* Flare Ammo sprites by Swampyrad
* Flare Projectiles from Half-Life 1.
* Metal Flaregun's front sight by FDA.
* Name and Obituary suggestions by BenitezClance4
* Various Bugtesting from FDA,
* Matt for the original code from Hideous Destructor for the Minerva, Single-Action Revolver and Snubnose.
* Matt for the original sprites for the Single-Action revolver and the 10mm Auto-Reloader.
* Minerva Sprites by Id Software, Skulltag, Ghastly and FDA for various edits. (<https://www.realm667.com/index.php/en/armory-mainmenu-157-97317/doom-style-mainmenu-158-94349/641-minigun>)
* Red/Toxitiy for the Single-Action firing sounds.
* Sig-cow sprites from El Doofer, based off the Doom Alpha Rifle by Id Software. Pickup was based off the Super Shotgun sprite, inspired by the Bayonet Rifle pickup from the Doom prototype.
* 10mm Bullet Casing sprites taken from the Doom Prototype spriterip by Superdave938.
* Various TEXTURES, ZScript code and sprite edits by a1337spy.
* 10mm 'Delta Elite' pistol sprites by ChopBlock223, based off the FreeDoom pistol sprites.
* Pickup sprite and SHOTA0 sprite edits by Swampyrad
* Original Shotgun sprite by iD Software
* Hand sprite on IM37A0 is taken from a sprite by Neoworm
* Ithaca 37 weapon sprites by LossForWords
* Dynamite sprites and sounds are from nadeto's Blood Dynamite grenade reskin which they got from the BLOOM game mod
* Dynamite code based off Frag Grenade code by mc776
* DM-93 Plasma Rifle and Phazer code based off Thunderbuster code by mc776
* Phazer weapon sprites by Mike12, JAM Software, and PaulNWN
* Micro-Cell code based off HDBattery code by mc76
* Phazer and Micro-Cell pickup sprites by Swampyrad
* Ted the Dragon for various code, organization and documentation improvements.

## Extra thanks to

* Scuba Steve (for drawing the FreeDoom pistol it's based off of)
* 3D Realms (for the muzzle flash based on one from Shadow Warrior)
* PB-Weapon-Addon (reused alternate drop bind code)
* War Trophies (reused CVAR Code)
