// ------------------------------------------------------------
// Minerva
// ------------------------------------------------------------
const MNV_REFID = "MNV";
enum mnvstatus
{
	MNVF_FAST=1,
	MNVF_SPINNINGFAST=2,
	MNVF_JUSTUNLOAD=4,
	MNVF_LOADCELL=8,

	MNVF_DIRTYMAG=16,

	MNVS_MAG1=1,
	MNVS_MAG2=2,
	MNVS_MAG3=3,
	MNVS_MAG4=4,
	MNVS_MAG5=5,

	MNVS_CHAMBER1=6,
	MNVS_CHAMBER2=7,
	MNVS_CHAMBER3=8,
	MNVS_CHAMBER4=9,
	MNVS_CHAMBER5=10,

	MNVS_BATTERY=11,
	MNVS_ZOOM=12,
	MNVS_HEAT=13,
	MNVS_BREAKCHANCE=14,
	MNVS_PERMADAMAGE=15,

	MNVS_DOT=16,
};
class MinervaChaingun:ZM66ScopeHaver{
	default{
		//$Category "Weapons/Hideous Destructor"
		//$Title "Minerva"
		//$Sprite "VULCA0"

		//+hdweapon.hinderlegs
   		//its ergonomic design design makes it easier to walk around with
		scale 0.8;
		weapon.selectionorder 40;
		weapon.slotnumber 4;
		weapon.slotpriority 1;
		weapon.kickback 24;
		weapon.bobrangex 1.2;
		weapon.bobrangey 1.5;
		weapon.bobspeed 1.8;
		weapon.bobstyle "normal";
		obituary "$OB_MINERVA";
		hdweapon.barrelsize 30,3,4;
		hdweapon.refid MNV_REFID;
		tag "$TAG_MINERVA";

		hdweapon.loadoutcodes"
			\cufast - 0/1, whether to start in \"fuller auto\" mode
			\cuzoom - 16-70, 10x the resulting FOV in degrees
			\cudot - 0-5";
	}
override void postbeginplay(){
		super.postbeginplay();
  weaponspecial=1337;
		}//add this for UaS stabilizer support

	override bool AddSpareWeapon(actor newowner){return AddSpareWeaponRegular(newowner);}
	override hdweapon GetSpareWeapon(actor newowner,bool reverse,bool doselect){return GetSpareWeaponRegular(newowner,reverse,doselect);}
	override string pickupmessage(){
		string msg=Stringtable.Localize("$PICKUP_MINERVA");
		int bc=weaponstatus[MNVS_BREAKCHANCE];
		
                if(bc>100){
			msg.replace("!","!");
			msg.replace("the","the");
		}
        
		if(!bc)msg=msg..Stringtable.Localize("$PICKUP_MINERVADAMAGE0");
		else if(bc>500)msg=msg..Stringtable.Localize("$PICKUP_MINERVADAMAGE500");
		else if(bc>200)msg=msg..Stringtable.Localize("$PICKUP_MINERVADAMAGE200");
		else if(bc>100)msg=msg..Stringtable.Localize("$PICKUP_MINERVADAMAGE100");
		return msg;
	}

	override void DoEffect(){
		let hdp=hdplayerpawn(owner);
		if(hdp){
			//droop downwards
			if(
				!hdp.gunbraced
				&&!!hdp.player
				&&hdp.player.readyweapon==self
				&&hdp.strength
				&&hdp.pitch<frandom(5,8)
				&&!(weaponstatus[0]&BFGF_STRAPPED)
			)hdp.A_MuzzleClimb((
				frandom(-0.05,0.05),
				frandom(0.1,clamp(1-pitch,0.06/hdp.strength,0.12))
			),(0,0),(0,0),(0,0));
		}
		Super.DoEffect();
	}


	override void tick(){
		super.tick();
		drainheat(MNVS_HEAT,18);
	}
	override inventory createtossable(){
		let ctt=minervachaingun(super.createtossable());
		if(!ctt)return null;
		if(ctt.bmissile)ctt.weaponstatus[MNVS_BREAKCHANCE]+=random(0,70);
		return ctt;
	}

	override double gunmass(){
		double amt=10+weaponstatus[MNVS_BATTERY]<0?0:1;
          //2 less points of mass than Vulcanette, easier to aim
		for(int i=MNVS_MAG1;i<=MNVS_MAG5;i++){
			if(weaponstatus[i]>=0)amt+=3.6;
		}
		return amt;
	}
	override double weaponbulk(){//50 less bulk than the Vulcanette
		double blx=150+(weaponstatus[MNVS_BATTERY]>=0?ENC_BATTERY_LOADED:0);
		for(int i=MNVS_MAG1;i<=MNVS_MAG5;i++){
			int wsi=weaponstatus[i];
			if(wsi>=0)blx+=ENC_9_LOADED*wsi+ENC_9MAG30_LOADED/2;
		}//less bulk due to more of the mag going inside the gun
		return blx;
	}
	override string,double getpickupsprite(){return "MNVNA0",1.;}
	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
			int nextmagloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("HD9mMag30")));
			if(nextmagloaded>30){
				sb.drawimage("CLP3A0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(2,2));
			}else if(nextmagloaded<1){
				sb.drawimage("CLP3B0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextmagloaded?0.6:1.,scale:(2,2));
			}else sb.drawbar(
				"CLP3NORM","CLP3GREY",
				nextmagloaded,30,
				(-46,-3),-1,
				sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
			);
			sb.drawbattery(-64,-4,sb.DI_SCREEN_CENTER_BOTTOM,reloadorder:true);
			sb.drawnum(hpl.countinv("HD9mMag30"),-43,-8,sb.DI_SCREEN_CENTER_BOTTOM);
			sb.drawnum(hpl.countinv("HDBattery"),-56,-8,sb.DI_SCREEN_CENTER_BOTTOM);
		}
		bool bat=hdw.weaponstatus[MNVS_BATTERY]>0;
		for(int i=0;i<5;i++){
			if(i>0&&hdw.weaponstatus[MNVS_MAG1+i]>=0)sb.drawrect(-19-i*4,-14,3,2);
			if(hdw.weaponstatus[MNVS_CHAMBER1+i]>0)sb.drawrect(-15,-14+i*2,1,1);
		}
		sb.drawwepnum(
			hdw.weaponstatus[MNVS_MAG1],
			30,posy:-9
		);
		sb.drawwepcounter(hdw.weaponstatus[0]&MNVF_FAST,
			-28,-16,"blank","STFULAUT"
		);
		if(bat){
			int lod=min(30,hdw.weaponstatus[MNVS_MAG1]);
			if(lod>=0)sb.drawnum(lod,-20,-22,
				sb.DI_SCREEN_CENTER_BOTTOM|sb.DI_TEXT_ALIGN_RIGHT,Font.CR_RED
			);
			sb.drawwepnum(hdw.weaponstatus[MNVS_BATTERY],20);
		}else if(!hdw.weaponstatus[MNVS_BATTERY])sb.drawstring(
			sb.mamountfont,"00000",(-16,-8),
			sb.DI_TEXT_ALIGN_RIGHT|sb.DI_TRANSLATABLE|sb.DI_SCREEN_CENTER_BOTTOM,
			Font.CR_DARKGRAY
		);
		sb.drawnum(hdw.weaponstatus[MNVS_ZOOM],
			-30,-22,
			sb.DI_SCREEN_CENTER_BOTTOM|sb.DI_TEXT_ALIGN_RIGHT,
			Font.CR_DARKGRAY
		);
	}
	override string gethelptext(){
		LocalizeHelp();
		return
		LWPHELP_FIRESHOOT
		..LWPHELP_RELOAD..Stringtable.Localize("$9LMG_HELPTEXT_1")
		..LWPHELP_ALTRELOAD..Stringtable.Localize("$9LMG_HELPTEXT_2")
		..LWPHELP_FIREMODE..Stringtable.Localize("$9LMG_HELPTEXT_3")..(weaponstatus[0]&MNVF_FAST?Stringtable.Localize("$9LMG_HELPTEXT_4"):Stringtable.Localize("$9LMG_HELPTEXT_5"))..Stringtable.Localize("$9LMG_HELPTEXT_6")
		..LWPHELP_ZOOM.."+"..LWPHELP_FIREMODE.."+"..LWPHELP_UPDOWN..Stringtable.Localize("$9LMG_HELPTEXT_7")
		..LWPHELP_ZOOM.."+"..LWPHELP_UNLOAD..Stringtable.Localize("$9LMG_HELPTEXT_8")
		..LWPHELP_MAGMANAGER
		..LWPHELP_UNLOADUNLOAD
		..LWPHELP_USE.."+"..LWPHELP_UNLOAD..Stringtable.Localize("$9LMG_HELPTEXT_9")..LWPHELP_USE.."+"..LWPHELP_ALTRELOAD..Stringtable.Localize("$9LMG_HELPTEXT_10")
		;
	}
	override void DrawSightPicture(
		HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl,
		bool sightbob,vector2 bob,double fov,bool scopeview,actor hpc
	){
		double dotoff=max(abs(bob.x),abs(bob.y));
		if(dotoff<40){
			string whichdot=sb.ChooseReflexReticle(hdw.weaponstatus[MNVS_DOT]);
			sb.drawimage(
				whichdot,(0,0)+bob*1.18,sb.DI_SCREEN_CENTER|sb.DI_ITEM_CENTER,
				alpha:0.8-dotoff*0.01,
				col:0xFF000000|sb.crosshaircolor.GetInt()
			);
		}
		sb.drawimage(
			"z66site",(0,0)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_CENTER
		);
		int scaledyoffset=47;

		if(scopeview)ShowZMScope(hdw.weaponstatus[MNVS_ZOOM],hpc,sb,scaledyoffset,bob);
	}
	override void SetReflexReticle(int which){weaponstatus[MNVS_DOT]=which;}
	override void consolidate(){
		CheckBFGCharge(MNVS_BATTERY);
		if(weaponstatus[MNVS_BREAKCHANCE]>0){
			int bc=weaponstatus[MNVS_BREAKCHANCE];
			if(bc>weaponstatus[MNVS_PERMADAMAGE])weaponstatus[MNVS_PERMADAMAGE]+=max(1,bc>>7);
			int oldbc=bc;
			weaponstatus[MNVS_BREAKCHANCE]=random(bc*2/3,bc)+weaponstatus[MNVS_PERMADAMAGE];
			if(!owner)return;
			string msg="You try to unwarp some of the parts of your Minerva";
			if(bc>oldbc)msg=msg..", but only made things worse.";
			else if(bc<oldbc*9/10)msg=msg..". It seems to scroll more smoothly now.";
			else msg=msg..", to little if any avail.";
			owner.A_Log(msg,true);
		}
	}
	override void DropOneAmmo(int amt){
		if(owner){
			amt=clamp(amt,1,10);
			if(owner.countinv("HDPistolAmmo"))owner.A_DropInventory("HDPistolAmmo",30);
			else{
				owner.angle-=10;
				owner.A_DropInventory("HD9mMag30",1);
				owner.angle+=20;
				owner.A_DropInventory("HDBattery",1);
				owner.angle-=10;
			}
		}
	}
	override void ForceBasicAmmo(){
		owner.A_TakeInventory("HDPistolAmmo");
		ForceOneBasicAmmo("HD9mMag30",5);
		ForceOneBasicAmmo("HDBattery");
	}
	states{
	select0:
   TNT1 A 1 ;//wait tic to avoid droop crash bug
		MNVG A 0 A_CheckDefaultReflexReticle(MNVS_DOT);
		goto select0bfg;
	deselect0:
		MNVG A 0;
		goto deselect0bfg;
	ready:
		MNVG A 1{
			A_SetCrosshair(21);
			if(pressingzoom())A_ZoomAdjust(MNVS_ZOOM,16,70);
			else if(justpressed(BT_FIREMODE|BT_ALTFIRE)){
				invoker.weaponstatus[0]^=MNVF_FAST;
				A_StartSound("weapons/minerva_fmswitch",CHAN_WEAPON,CHANF_OVERLAP,0.4);
				A_SetHelpText();
				A_WeaponReady(WRF_NONE);
			}else A_WeaponReady(WRF_ALL);
		}
		goto readyend;

	fire:
		MNVG A 1{
			A_WeaponReady(WRF_NONE);
			if(
				invoker.weaponstatus[MNVS_BATTERY]>0 
				&&!random(0,max(0,700-(invoker.weaponstatus[MNVS_BREAKCHANCE]>>1)))
			)invoker.weaponstatus[MNVS_BATTERY]--;
		}goto shoot;
	hold:
		MNVG A 0{
			if(invoker.weaponstatus[MNVS_BATTERY]<1)setweaponstate("nope");
		}
	shoot:
		MNVG A 2{
			A_WeaponReady(WRF_NOFIRE);
			if(
				invoker.weaponstatus[MNVS_BATTERY]>0    
				&&!random(0,invoker.weaponstatus[0]&MNVF_SPINNINGFAST?200:210)
			)invoker.weaponstatus[MNVS_BATTERY]--;
			invoker.weaponstatus[0]&=~MNVF_SPINNINGFAST;

			//check speed and then shoot
			if(
				invoker.weaponstatus[0]&MNVF_FAST
				&&invoker.weaponstatus[MNVS_BATTERY]>=4
				&&invoker.weaponstatus[MNVS_BREAKCHANCE]<random(100,5000)
			){
				A_SetTics(1);
				invoker.weaponstatus[0]|=MNVF_SPINNINGFAST;
			}else if(invoker.weaponstatus[MNVS_BATTERY]<2){
				A_SetTics(random(3,4));
			}else if(invoker.weaponstatus[MNVS_BATTERY]<3){
				A_SetTics(random(2,3));
			}

			if(invoker.weaponstatus[MNVS_CHAMBER1])
				A_EjectCasing("HDSpent9mm",-frandom(89,92),(frandom(7,9),0,0),(13,0,-10));
			VulcShoot();
			VulcNextRound();
		}
 		MNVG B 1{
			A_WeaponReady(WRF_NOFIRE);
			//check speed and then shoot
			if(
				invoker.weaponstatus[0]&MNVF_SPINNINGFAST
			){
				A_SetTics(1);
				VulcShoot(true);
				VulcNextRound();
			}else if(invoker.weaponstatus[MNVS_BATTERY]<2){
				A_SetTics(random(3,4));
			}else if(invoker.weaponstatus[MNVS_BATTERY]<3){
				A_SetTics(random(2,3));
			}
		}
		MNVG B 2{  //adding a tic
			A_WeaponReady(WRF_NONE);
			if(invoker.weaponstatus[MNVS_BATTERY]<1)setweaponstate("spindown");
			else A_Refire("holdswap");
		}goto spindown;
	holdswap:
		MNVG A 0{
			if(invoker.weaponstatus[MNVS_MAG1]<1){
				VulcNextMag();
				A_StartSound("weapons/mnvashunt",CHAN_WEAPON,CHANF_OVERLAP);
			}
		}goto hold;
	spindown:
		MNVG B 0{
			A_ClearRefire();
			if(!(invoker.weaponstatus[0]&MNVF_SPINNINGFAST))setweaponstate("nope");
			invoker.weaponstatus[0]&=~MNVF_SPINNINGFAST;
		}
		MNVG AB 1{
			A_WeaponReady(WRF_NONE);
			A_MuzzleClimb(frandom(0.4,0.6),-frandom(0.4,0.6));
		}
		MNVG ABAABB 2 A_WeaponReady(WRF_NOFIRE|WRF_NOSWITCH);
		goto ready;


	flash2:
		MNVF B 0;
		goto flashfollow;
	flash:
		MNVF A 0;
		goto flashfollow;
	flashfollow:
		---- A 0{
			A_MuzzleClimb(0,0,-frandom(0.05,0.15),-frandom(0.2,0.4));
			A_ZoomRecoil(0.99);
			HDFlashAlpha(invoker.weaponstatus[MNVS_HEAT]*48);
		}
		---- A 1 bright A_Light2();
		goto lightdone;


	reload:
		MNVG A 0{
			if(
				//abort if all mag slots taken or no spare ammo
				(
					invoker.weaponstatus[MNVS_MAG1]>=0
					&&invoker.weaponstatus[MNVS_MAG2]>=0
					&&invoker.weaponstatus[MNVS_MAG3]>=0
					&&invoker.weaponstatus[MNVS_MAG4]>=0
					&&invoker.weaponstatus[MNVS_MAG5]>=0
				)
				||!countinv("HD9mMag30")
			)setweaponstate("nope");else{
				invoker.weaponstatus[0]&=~(MNVF_JUSTUNLOAD|MNVF_LOADCELL);
				setweaponstate("lowertoopen");
			}
		}
	altreload:
	cellreload:
		MNVG A 0{
			int batt=invoker.weaponstatus[MNVS_BATTERY];
			if(
				player.cmd.buttons&BT_USE
			){
				invoker.weaponstatus[0]|=MNVF_JUSTUNLOAD;
				invoker.weaponstatus[0]|=MNVF_LOADCELL;
				setweaponstate("lowertoopen");
				return;
			}else if(
				batt<20
				&&countinv("HDBattery")
			){
				invoker.weaponstatus[0]&=~MNVF_JUSTUNLOAD;
				invoker.weaponstatus[0]|=MNVF_LOADCELL;
				setweaponstate("lowertoopen");
				return;
			}
			setweaponstate("nope");
		}
	unload:
		MNVG A 0{
			if(player.cmd.buttons&BT_USE)invoker.weaponstatus[0]|=MNVF_LOADCELL;
			else invoker.weaponstatus[0]&=~MNVF_LOADCELL;
			invoker.weaponstatus[0]|=MNVF_JUSTUNLOAD;
			setweaponstate("lowertoopen");
		}
	//what key to use for cellunload???
	cellunload:
		MNVG A 0{
			//abort if no cell to unload
			if(invoker.weaponstatus[MNVS_BATTERY]<0)
			setweaponstate("nope");else{
				invoker.weaponstatus[0]|=MNVF_JUSTUNLOAD;
				invoker.weaponstatus[0]|=MNVF_LOADCELL;
				setweaponstate("uncell");
			}
		}

	//lower the weapon, open it, decide what to do
	lowertoopen:
		MNVG A 2 offset(0,36);
		MNVG A 2 offset(4,38){
			A_StartSound("weapons/minerva_click2",CHAN_WEAPON);
			A_MuzzleClimb(-frandom(1.2,1.8),-frandom(1.8,2.4));
		}
		MNVG A 6 offset(9,41)A_StartSound("weapons/pocket",CHAN_WEAPON);
		MNVG A 8 offset(12,43)A_StartSound("weapons/mnvaopen1",CHAN_WEAPON,CHANF_OVERLAP);
		MNVG A 5 offset(10,41)A_StartSound("weapons/mnvaopen2",CHAN_WEAPON,CHANF_OVERLAP);
		MNVG A 0 A_JumpIf(
			invoker.weaponstatus[MNVS_CHAMBER1]<1
			&&invoker.weaponstatus[MNVS_CHAMBER2]<1
			&&invoker.weaponstatus[MNVS_CHAMBER3]<1
			&&invoker.weaponstatus[MNVS_CHAMBER4]<1
			&&invoker.weaponstatus[MNVS_CHAMBER5]<1
			&&invoker.weaponstatus[MNVS_BATTERY]<0
			&&invoker.weaponstatus[MNVS_MAG1]<0
			&&invoker.weaponstatus[MNVS_MAG2]<0
			&&invoker.weaponstatus[MNVS_MAG3]<0
			&&invoker.weaponstatus[MNVS_MAG4]<0
			&&invoker.weaponstatus[MNVS_MAG5]<0
			&&pressingzoom()
			,"openforrepair"
		);
		MNVG A 0{
			if(invoker.weaponstatus[0]&MNVF_LOADCELL)setweaponstate("uncell");
			else if(invoker.weaponstatus[0]&MNVF_JUSTUNLOAD)setweaponstate("unmag");
		}goto loadmag;

	uncell:
		MNVG A 10 offset(11,42){
			int btt=invoker.weaponstatus[MNVS_BATTERY];
			invoker.weaponstatus[MNVS_BATTERY]=-1;
			if(btt<0)setweaponstate("cellout");
			else if(
				!PressingUnload()
				&&!PressingAltReload()
				&&!PressingReload()
			){
				A_SetTics(4);
				HDMagAmmo.SpawnMag(self,"HDBattery",btt);
				
			}else{
				A_StartSound("weapons/pocket",CHAN_WEAPON);
				HDMagAmmo.GiveMag(self,"HDBattery",btt);
			}
		}goto cellout;

	cellout:
		MNVG A 0 offset(10,40) A_JumpIf(invoker.weaponstatus[0]&MNVF_JUSTUNLOAD,"reloadend");
	loadcell:
		MNVG A 0{
			let bbb=HDMagAmmo(findinventory("HDBattery"));
			if(bbb)invoker.weaponstatus[MNVS_BATTERY]=bbb.TakeMag(true);
		}goto reloadend;

	reloadend:
		MNVG A 3 offset(9,41);
		MNVG A 2 offset(6,38);
		MNVG A 3 offset(2,34);
	reloadendend:
		MNVG A 0 A_JumpIf(!pressingreload()&&!pressingunload(),"ready");
		MNVG A 0 A_ReadyEnd();
		MNVG A 1 A_WeaponReady(WRF_NONE);
		loop;


	unchamber:
		MNVG B 4{
			A_StartSound("weapons/mnvaextract",CHAN_AUTO,CHANF_DEFAULT,0.3);
			VulcNextRound();
		}MNVG A 4;
		MNVG A 0 A_JumpIf(PressingUnload(),"unchamber");
		goto nope;
	unmag:
		//if no mags, remove battery
		//if not even battery, remove rounds from chambers
		MNVG A 0{
			if(
				invoker.weaponstatus[MNVS_MAG1]<0
				&&invoker.weaponstatus[MNVS_MAG2]<0
				&&invoker.weaponstatus[MNVS_MAG3]<0
				&&invoker.weaponstatus[MNVS_MAG4]<0
				&&invoker.weaponstatus[MNVS_MAG5]<0
			){
				if(invoker.weaponstatus[MNVS_BATTERY]>=0)setweaponstate("cellunload");    
				else setweaponstate("unchamber");
			}
		}
		//first, check if there's a mag2-5.
		//if there's no mag2 but stuff after that, shunt everything over until there is.
		//if there's nothing but mag1, unload mag1.
		MNVG A 6 offset(10,40){
			if(
				!invoker.weaponstatus[0]&MNVF_JUSTUNLOAD
			)setweaponstate("loadmag");
			A_StartSound("weapons/mnvamag",CHAN_WEAPON,CHANF_OVERLAP);
			A_MuzzleClimb(-frandom(1.2,1.8),-frandom(1.8,2.4));
		}
	//remove mag #2 first, #1 only if out of options
	unmagpick:
		MNVG A 0{
			if(invoker.weaponstatus[MNVS_MAG2]>=0)setweaponstate("unmag2");
			else if(
				invoker.weaponstatus[MNVS_MAG3]>=0
				||invoker.weaponstatus[MNVS_MAG4]>=0
				||invoker.weaponstatus[MNVS_MAG5]>=0
			)setweaponstate("unmagshunt");
			else if(
				invoker.weaponstatus[MNVS_MAG1]>=0    
			)setweaponstate("unmag1");
		}goto reloadend;
	unmagshunt:
		MNVG A 0{
			for(int i=MNVS_MAG2;i<MNVS_MAG5;i++){
				invoker.weaponstatus[i]=invoker.weaponstatus[i+1];
			}
			invoker.weaponstatus[MNVS_MAG5]=-1;
			A_StartSound("weapons/mnvashunt",CHAN_WEAPON,CHANF_OVERLAP);
		}
		MNVG AB 2 A_MuzzleClimb(-frandom(0.4,0.6),frandom(0.4,0.6));
		goto ready;

	unmag2:
		VULC A 0{
			int mg=invoker.weaponstatus[MNVS_MAG2];
			invoker.weaponstatus[MNVS_MAG2]=-1;
			if(mg<0){
				setweaponstate("mag2out");
				return;
			}
			if(
				!PressingUnload()
				&&!PressingReload()
			){
				HDMagAmmo.SpawnMag(self,"HD9mMag30",mg);
				setweaponstate("mag2out");
			}else{
				HDMagAmmo.GiveMag(self,"HD9mMag30",mg);
				setweaponstate("pocketmag");
			}
		}goto mag2out;
	unmag1:
		VULC A 0{
			int mg=invoker.weaponstatus[MNVS_MAG1];
			invoker.weaponstatus[MNVS_MAG1]=-1;
			if(mg<0){
				setweaponstate("reloadend");
				return;
			}
			if(
				!PressingUnload()
				&&!PressingReload()
			){
				HDMagAmmo.SpawnMag(self,"HD9mMag30",mg);
				setweaponstate("mag2out");
			}else{
				HDMagAmmo.GiveMag(self,"HD9mMag30",mg);
				setweaponstate("pocketmag");
			}
		}goto reloadend;
	pocketmag:
		MNVG A 0 A_StartSound("weapons/pocket");
		MNVG AA 6 A_MuzzleClimb(frandom(0.4,0.6),-frandom(0.4,0.6));
		goto mag2out;
	mag2out:
		MNVG A 1{
			for(int i=MNVS_MAG2;i<MNVS_MAG5;i++){
				invoker.weaponstatus[i]=invoker.weaponstatus[i+1];
			}
			invoker.weaponstatus[MNVS_MAG5]=-1;
			A_StartSound("weapons/mnvashunt",CHAN_WEAPON,CHANF_OVERLAP);
		}
		MNVG AB 2 A_MuzzleClimb(-frandom(0.4,0.6),frandom(0.4,0.6));
		MNVG A 6 A_JumpIf(invoker.weaponstatus[MNVS_MAG2]<0,"reloadend");
		goto unmag2;

	loadmag:
		//pick the first empty slot and fill that
		MNVG A 0 A_StartSound("weapons/pocket");
		MNVG AA 6 A_MuzzleClimb(-frandom(0.4,0.6),frandom(-0.4,0.4));
		MNVG A 6 offset(10,41){
			if(HDMagAmmo.NothingLoaded(self,"HD9mMag30")){setweaponstate("reloadend");return;}
			A_StartSound("weapons/mnvamag",CHAN_WEAPON,CHANF_OVERLAP);
			int lod=HDMagAmmo(findinventory("HD9mMag30")).TakeMag(true);

			int magslot=-1;
			for(int i=MNVS_MAG1;i<=MNVS_MAG5;i++){
				if(invoker.weaponstatus[i]<0){
					magslot=i;
					break;
				}
			}
			if(magslot<0){
				setweaponstate("reloadend");
				return;
			}

			if(lod<31){
				if(!random(0,7)){
					A_StartSound("weapons/mnvaforcemag",CHAN_WEAPON,CHANF_OVERLAP);
					lod=max(0,lod-random(0,1));
					//A_Log(HDCONST_426MAGMSG,true);
					if(magslot==MNVS_MAG1)invoker.weaponstatus[0]|=MNVF_DIRTYMAG;
				}
			}else if(magslot==MNVS_MAG1)invoker.weaponstatus[0]&=~MNVF_DIRTYMAG;
			invoker.weaponstatus[magslot]=lod;

			A_MuzzleClimb(-frandom(0.4,0.8),-frandom(0.5,0.7));
		}
		MNVG A 8 offset(9,38){
			A_StartSound("weapons/minerva_click",CHAN_WEAPON,CHANF_OVERLAP);
			A_MuzzleClimb(
				-frandom(0.2,0.8),-frandom(0.2,0.3)
				-frandom(0.2,0.8),-frandom(0.2,0.3)
			);
		}
		MNVG A 0{
			if(
				(
					PressingReload()
					||PressingUnload()
					||PressingFire()
					||!countinv("HD9mMag30")
				)||(
					invoker.weaponstatus[MNVS_MAG1]>=0
					&&invoker.weaponstatus[MNVS_MAG2]>=0
					&&invoker.weaponstatus[MNVS_MAG3]>=0
					&&invoker.weaponstatus[MNVS_MAG4]>=0
					&&invoker.weaponstatus[MNVS_MAG5]>=0
				)
			)setweaponstate("reloadend");
		}goto loadmag;

	user3:
		VULC A 0 A_MagManager("HD9mMag30");
		goto ready;


	openforrepair:
		MNVG A 0{
			let bbb=invoker.weaponstatus[MNVS_BREAKCHANCE];
			string msg="decent in there.";
			if(bbb>400)msg="ready for scrap, to be honest.";
			else if(bbb>150)msg="pretty bad.";
			else if(bbb>40)msg="like it needs some repairs.";
			else if(bbb>0)msg="like it could use a tune-up.";
			A_Log("This Minerva looks "..msg,true);
			A_WeaponBusy();
		}
	readytorepair:
		MNVG A 1 offset(11,42){
			if(
				invoker.weaponstatus[MNVS_BREAKCHANCE]<1
				||!pressingzoom()
			){
				setweaponstate("reloadend");
				return;
			}
			if(
				pressingfire()
				||pressingunload()
			){
				if(
					!random(0,23)
					&&invoker.weaponstatus[MNVS_BREAKCHANCE]>0
				){
					invoker.weaponstatus[MNVS_BREAKCHANCE]--;
					A_StartSound("weapons/mnvafix",CHAN_WEAPONBODY,CHANF_OVERLAP);
					VulcRepairMsg();
				}else if(!random(0,95))invoker.weaponstatus[MNVS_PERMADAMAGE]++;
				if(hd_debug)A_Log("Break chance: "..invoker.weaponstatus[MNVS_BREAKCHANCE],true);
				switch(random(0,4)){
				case 1:setweaponstate("tryfix1");break;
				case 2:setweaponstate("tryfix2");break;
				case 3:setweaponstate("tryfix3");break;
				default:setweaponstate("tryfix0");break;
				}
			}
		}wait;
	tryfix0:
		MNVG B 4 offset(10,43)A_StartSound("weapons/mnvatryfix",CHAN_WEAPONBODY,CHANF_OVERLAP);
		MNVG A 10 offset(11,42)A_MuzzleClimb(0.3,0.3,-0.3,-0.3,0.3,0.3,-0.3,-0.3);
		goto readytorepair;
	tryfix1:
		MNVG B 0 A_MuzzleClimb(1,1,-1,-1,1,1,-1,-1);
		MNVG B 2 offset(10,43)A_StartSound("weapons/mnvabelt",CHAN_WEAPONBODY,CHANF_OVERLAP);
		MNVG AABBAABABABAABBAABBBAAAA 1 offset(11,44);
		goto readytorepair;
	tryfix2:
		MNVG B 4 offset(11,43)A_MuzzleClimb(frandom(-1,1),frandom(-1,1),frandom(-1,1),frandom(-1,1),frandom(-1,1),frandom(-1,1),frandom(-1,1),frandom(-1,1));
		MNVG B 10 offset(12,43)A_StartSound("weapons/mnvatryfix2",CHAN_WEAPONBODY,CHANF_OVERLAP);
		MNVG A 10 offset(13,45)A_MuzzleClimb(frandom(-1,1),frandom(-1,1),frandom(-1,1),frandom(-1,1),frandom(-1,1),frandom(-1,1),frandom(-1,1),frandom(-1,1));
		MNVG B 15 offset(14,47)A_MuzzleClimb(frandom(-1,1),frandom(-1,1),frandom(-1,1),frandom(-1,1),frandom(-1,1),frandom(-1,1),frandom(-1,1),frandom(-1,1));
		MNVG BA 3 offset(12,44)A_StartSound("weapons/mnvatryfix2",CHAN_WEAPONBODY,CHANF_OVERLAP);
		MNVG B 10 offset(12,43);
		goto readytorepair;
	tryfix3:
		MNVG B 0 A_MuzzleClimb(1,1,-1,-1,1,1,-1,-1);
		MNVG B 1 offset(11,45);
		MNVG B 1 offset(11,48)A_StartSound("weapons/mnvatryfix1",CHAN_WEAPONBODY,CHANF_OVERLAP);
		MNVG B 2 offset(12,54);
		MNVG B 0 A_MuzzleClimb(1,1,-1,-1,1,1,-1,-1);
		MNVG B 4 offset(15,58);
		MNVG B 3 offset(14,56);
		MNVG B 2 offset(12,52);
		MNVG B 1 offset(11,50);
		MNVG B 1 offset(10,48);
		goto readytorepair;


	spawn:
		MNVN A -1;
	}


	override void InitializeWepStats(bool idfa){
		weaponstatus[MNVS_BATTERY]=20;
		weaponstatus[MNVS_ZOOM]=30;
		weaponstatus[MNVS_MAG1]=30;
		weaponstatus[MNVS_MAG2]=30;
		weaponstatus[MNVS_MAG3]=30;
		weaponstatus[MNVS_MAG4]=30;
		weaponstatus[MNVS_MAG5]=30;
		int chm=idfa?1:0;
		weaponstatus[MNVS_CHAMBER1]=chm;
		weaponstatus[MNVS_CHAMBER2]=chm;
		weaponstatus[MNVS_CHAMBER3]=chm;
		weaponstatus[MNVS_CHAMBER4]=chm;
		weaponstatus[MNVS_CHAMBER5]=chm;
		weaponstatus[0]&=~MNVF_DIRTYMAG;
	}
	override void loadoutconfigure(string input){
		int fast=getloadoutvar(input,"fast",1);
		if(!fast)weaponstatus[0]&=~MNVF_FAST;
		else if(fast>0)weaponstatus[0]|=MNVF_FAST;

		int zoom=getloadoutvar(input,"zoom",3);
		if(zoom>=0)weaponstatus[MNVS_ZOOM]=clamp(zoom,16,70);

		int xhdot=getloadoutvar(input,"dot",3);
		if(xhdot>=0)weaponstatus[MNVS_DOT]=xhdot;

		if(getage()<1){
			weaponstatus[MNVS_MAG1]=25;
			weaponstatus[MNVS_CHAMBER1]=1;
			weaponstatus[MNVS_CHAMBER2]=1;
			weaponstatus[MNVS_CHAMBER3]=1;
			weaponstatus[MNVS_CHAMBER4]=1;
			weaponstatus[MNVS_CHAMBER5]=1;
		}
	}

	//shooting and cycling actions
	//move this somewhere sensible
	action void VulcShoot(bool flash2=false){
		invoker.weaponstatus[MNVS_BREAKCHANCE]+=random(0,random(0,invoker.weaponstatus[MNVS_HEAT]/256));

		int ccc=invoker.weaponstatus[MNVS_CHAMBER1];
		if(ccc<1)return;
		if(ccc>1){
			invoker.weaponstatus[MNVS_BREAKCHANCE]+=random(0,7);
			if(hd_debug)A_Log("Break chance: "..invoker.weaponstatus[MNVS_BREAKCHANCE]);
			return;
		}

		if(random(random(1,500),5000)<invoker.weaponstatus[MNVS_BREAKCHANCE]){
			setweaponstate("nope");
			return;
		}
		if(!random(0,255))invoker.weaponstatus[MNVS_BREAKCHANCE]++;

		if(flash2)A_GunFlash("flash2");else A_GunFlash("flash");
		A_StartSound("weapons/minerva",CHAN_WEAPON,CHANF_OVERLAP);
		A_AlertMonsters();

		double cm=countinv("IsMoving");if(
			invoker.weaponstatus[0]&MNVF_FAST
		)cm*=hdplayerpawn(self)?2./hdplayerpawn(self).strength:2.;
		double offx=frandom(-0.1,0.1)*cm;
		double offy=frandom(-0.1,0.1)*cm;

		int heat=min(50,invoker.weaponstatus[MNVS_HEAT]);
		HDBulletActor.FireBullet(self,"HDB_9",zofs:height-8,
			spread:heat>20?heat*0.1:0,
			distantsound:"world/mnvafar"
		);
		invoker.weaponstatus[MNVS_HEAT]+=2;

		if(random(0,8192)<min(10,heat))invoker.weaponstatus[MNVS_BATTERY]++;

		invoker.weaponstatus[MNVS_CHAMBER1]=0;
	}
	action void VulcNextRound(){
		int thisch=invoker.weaponstatus[MNVS_CHAMBER1];
		if(thisch>0){
			//spit out a misfired, wasted or broken round
			if(thisch>1){
				for(int i=0;i<5;i++){
					A_SpawnItemEx("HDSpent9mm",3,0,height-18,
						random(4,7),random(-2,2),random(-2,1),
						-30,SXF_NOCHECKPOSITION
					);
				}
			}else{
				A_SpawnItemEx("HDLoose9mm",3,0,height-18,
					random(4,7),random(-2,2),random(-2,1),
					-30,SXF_NOCHECKPOSITION
				);
			}
			A_MuzzleClimb(frandom(0.6,2.4),frandom(1.2,2.4));
		}

		//cycle all chambers
		for(int i=MNVS_CHAMBER1;i<MNVS_CHAMBER5;i++){
			invoker.weaponstatus[i]=invoker.weaponstatus[i+1];
		}

		//check if mag is full. 
		int inmag=invoker.weaponstatus[MNVS_MAG1];
		if(inmag==30)
		{
			invoker.weaponstatus[0]&=~MNVF_DIRTYMAG;
			inmag=30;
		}

		//extract a round from the mag
		if(inmag>0){
			invoker.weaponstatus[MNVS_MAG1]--;
			A_StartSound("weapons/mnvachamber",CHAN_WEAPON,CHANF_OVERLAP);
			if(random(0,2000)<=
				1+(invoker.weaponstatus[0]&MNVF_DIRTYMAG?(invoker.weaponstatus[0]&MNVF_FAST?13:9):0)
			)invoker.weaponstatus[MNVS_CHAMBER5]=2;
			else invoker.weaponstatus[MNVS_CHAMBER5]=1;
		}else invoker.weaponstatus[MNVS_CHAMBER5]=0;
	}
	action void VulcNextMag(){
		int thismag=invoker.weaponstatus[MNVS_MAG1];
		if(thismag>=0){
			double cp=cos(pitch);double ca=cos(angle+60);
			double sp=sin(pitch);double sa=sin(angle+60);
			actor mmm=HDMagAmmo.SpawnMag(self,"HD9mMag30",thismag);
			mmm.setorigin(pos+(
				cp*ca*16,
				cp*sa*16,
				height-12-12*sp
			),false);
			mmm.vel=vel+(
				cp*cos(angle+random(55,65)),
				cp*sin(angle+random(55,65)),
				sp
			);
		}
		for(int i=MNVS_MAG1;i<MNVS_MAG5;i++){
			invoker.weaponstatus[i]=invoker.weaponstatus[i+1];
		}
		invoker.weaponstatus[MNVS_MAG5]=-1;

		if(invoker.weaponstatus[MNVS_MAG1]<51)invoker.weaponstatus[0]|=MNVF_DIRTYMAG;
	}

	action void VulcRepairMsg(){
		static const string vordinals[]={"first","second","third","fourth","fifth"};
		static const string vverbs[]={"remove some","buff out","realign","secure","grease","grab a spare part to replace","fiddle around and eventually suspect a problem with","forcibly un-warp","reassemble"};
		static const string vdebris[]={"debris","grease","dust","steel filings","powder","blood","pus","hair","dead insects","blueberry jam","cheese puff powder","tiny Bosses"};
		static const string vpart[]={"crank shaft","main gear","magazine feeder","mag scanner head","barrel shroud","cylinder","cylinder feed port","motor power feed","CPU auxiliary power turbine","misfire ejector lug"};
		static const string vpart2[]={"barrel feed port","chamber","extractor","extruder","barrel feed port seal","barrel","transfer gear","firing pin","safety scanner"};

		string msg="You ";
		if(!random(0,3))msg=msg.."attempt to ";
		int which=random(0,vverbs.size()-1);
		msg=msg..vverbs[which].." ";
		if(!which)msg=msg..vdebris[abs(random(1,vdebris.size())-random(1,vdebris.size()))].." from ";
		msg=msg.."the ";

		which=random(0,vpart.size());
		if(which==vpart.size())msg=msg..vordinals[random(0,4)].." "..vpart2[random(0,vpart2.size()-1)];
		else msg=msg..vpart[which];

		A_Log(msg..".",true);
	}
}

class MinervaRandom:actor{
	override void postbeginplay(){
		super.postbeginplay();
		spawn("MinervaChaingun",pos,ALLOW_REPLACE);
  spawn("HD9mMag30",pos,ALLOW_REPLACE);
  spawn("HDFragGrenadeAmmo",pos,ALLOW_REPLACE);
		self.Destroy();
	}
}
