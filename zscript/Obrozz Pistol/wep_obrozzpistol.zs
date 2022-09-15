// ------------------------------------------------------------
// Obrozz Pistol (a sawn-off Boss rifle that can be concealed)
// ------------------------------------------------------------
class ObrozzSpawner:IdleDummy{
	states{
	spawn:
		TNT1 A 0 nodelay{
			A_SpawnItemEx("HD7mClip",-3,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
			A_SpawnItemEx("HD7mClip",3,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
			A_SpawnItemEx("HD7mClip",1,0,0,0,0,0,0,SXF_NOCHECKPOSITION);

			let ggg=ObrozzPistol(spawn("ObrozzPistol",pos,ALLOW_REPLACE));
			HDF.TransferSpecials(self,ggg,HDF.TS_ALL);
		}stop;
	}
}

class ObrozzPistol:HDHandgun{
	default{
   +hdweapon.fitsinbackpack
		weapon.slotnumber 8;
		weapon.slotpriority 2;
		weapon.kickback 15;
		weapon.selectionorder 80;
		inventory.pickupSound "misc/w_pkup";
		inventory.pickupMessage "You got the Obrozz Pistol!";
		weapon.bobrangex 0.98;
		weapon.bobrangey 1.1;
		scale 0.75;
		Obituary "%o sure showed %k who was the 'brozz!";
		hdweapon.barrelsize 20,1,2;//rifle's been cut in half, basically
		hdweapon.refid "obz";
		tag "Obrozz Pistol";

		hdweapon.loadoutcodes "
			\cucustomchamber - 0/1, whether to reduce jam for less power
			\cufrontreticle - 0/1, whether crosshair scales with zoom
			\cubulletdrop - 0-600, amount of compensation for bullet drop
			\cuzoom - 5-60, 10x the resulting FOV in degrees";
	}
	override bool AddSpareWeapon(actor newowner){return AddSpareWeaponRegular(newowner);}
	override hdweapon GetSpareWeapon(actor newowner,bool reverse,bool doselect){return GetSpareWeaponRegular(newowner,reverse,doselect);}
	action void A_ChamberGrit(int amt,bool onlywhileempty=false){
		int ibg=invoker.weaponstatus[OBROZZS_GRIME];
		bool customchamber=(invoker.weaponstatus[0]&OBROZZF_CUSTOMCHAMBER);
		if(amt>0&&customchamber)amt>>=1;
		if(!onlywhileempty||invoker.weaponstatus[OBROZZS_CHAMBER]<1)ibg+=amt;
		else if(!random(0,4))ibg++;
		invoker.weaponstatus[OBROZZS_GRIME]=clamp(ibg,0,100);
		//if(hd_debug)A_Log(string.format("Boss grit level: %i",invoker.weaponstatus[OBROZZS_GRIME]));
	}


  action void A_SwapRifles(){
		let mwt=SpareWeapons(findinventory("SpareWeapons"));
		if(!mwt){
			setweaponstate("whyareyousmiling");
			return;
		}
		int pistindex=mwt.weapontype.find(invoker.getclassname());
		if(pistindex==mwt.weapontype.size()){
			setweaponstate("whyareyousmiling");
			return;
		}
		A_WeaponBusy();

		array<string> wepstat;
		string wepstat2="";
		mwt.weaponstatus[pistindex].split(wepstat,",");
		for(int i=0;i<wepstat.size();i++){
			if(i)wepstat2=wepstat2..",";
			wepstat2=wepstat2..invoker.weaponstatus[i];
			invoker.weaponstatus[i]=wepstat[i].toint();
		}
		mwt.weaponstatus[pistindex]=wepstat2;

		invoker.wronghand=!invoker.wronghand;
	}


action void A_CheckRifleHand(){	if(invoker.wronghand)player.getpsprite(PSP_WEAPON).sprite=getspriteindex("BARGA0");//just use the same sprites lol
	}


	int pickuprounds;
	override void tick(){
		super.tick();
		drainheat(OBROZZS_HEAT,3);//4-1=3
   //stays hot longer due to less barrel to disperse heat away
	}
	override double gunmass(){
		return 15;//12+3=15, it`s heavier because you're one-handing it
	}
	override double weaponbulk(){
		return 74+weaponstatus[OBROZZS_MAG]*ENC_776_LOADED;//144-70=74
   //almost half the bulk due to cutting the stock and barrel
	}
	override void GunBounce(){
		super.GunBounce();
		weaponstatus[OBROZZS_GRIME]+=random(-7,3);
		if(weaponstatus[OBROZZS_CHAMBER]>2&&!random(0,7))weaponstatus[OBROZZS_CHAMBER]-=2;
	}
	int jamchance(){
		int jc=
		weaponstatus[OBROZZS_GRIME]
		+(weaponstatus[OBROZZS_HEAT]>>2)
		+weaponstatus[OBROZZS_CHAMBER]
		;
		if(weaponstatus[0]&OBROZZF_CUSTOMCHAMBER)return jc>>5;
		return jc;
	}
	override string,double getpickupsprite(){return "OBRZA0",1.;}
	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
			int nextmagloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("HD7mClip")));
			if(nextmagloaded<1){
				sb.drawimage("RCLPF0",(-50,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextmagloaded?0.6:1.,scale:(1.2,1.2));
			}else if(nextmagloaded<3){
				sb.drawimage("RCLPE0",(-50,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1.2,1.2));
			}else if(nextmagloaded<5){
				sb.drawimage("RCLPD0",(-50,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1.2,1.2));
			}else if(nextmagloaded<7){
				sb.drawimage("RCLPC0",(-50,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1.2,1.2));
			}else if(nextmagloaded<9){
				sb.drawimage("RCLPB0",(-50,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1.2,1.2));
			}else sb.drawimage("RCLPA0",(-50,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1.2,1.2));
			sb.drawnum(hpl.countinv("HD7mClip"),-43,-8,sb.DI_SCREEN_CENTER_BOTTOM);

			int sevenrounds=hpl.countinv("SevenMilAmmo");
			sb.drawimage("TEN7A0",(-62,-4),sb.DI_SCREEN_CENTER_BOTTOM,alpha:sevenrounds?1:0.6,scale:(1.2,1.2));
			sb.drawnum(sevenrounds,-56,-8,sb.DI_SCREEN_CENTER_BOTTOM);

			sevenrounds=hpl.countinv("SevenMilAmmoRecast");
			if(sevenrounds>0){
				sb.drawimage("TEN7A0",(-62,-14),sb.DI_SCREEN_CENTER_BOTTOM,alpha:sevenrounds?1:0.6,scale:(1.2,1.2));
				sb.drawnum(sevenrounds,-56,-18,sb.DI_SCREEN_CENTER_BOTTOM);
			}
		}
		sb.drawwepnum(hdw.weaponstatus[OBROZZS_MAG],10);
		sb.drawwepcounter(hdw.weaponstatus[OBROZZS_CHAMBER],
			-16,-10,"blank","RBRSA1A5","RBRSA3A7","RBRSA4A6"
		);
		sb.drawstring(
			sb.mAmountFont,string.format("%.1f",hdw.weaponstatus[OBROZZS_ZOOM]*0.1),
			(-36,-18),sb.DI_SCREEN_CENTER_BOTTOM|sb.DI_TEXT_ALIGN_RIGHT,Font.CR_DARKGRAY
		);
		sb.drawstring(
			sb.mAmountFont,string.format("%i",hdw.weaponstatus[OBROZZS_DROPADJUST]),
			(-16,-18),sb.DI_SCREEN_CENTER_BOTTOM|sb.DI_TEXT_ALIGN_RIGHT,Font.CR_WHITE
		);
	}
	override string gethelptext(){
		return
		WEPHELP_FIRESHOOT
                ..WEPHELP_FIREMODE.."  Quick-swap(if available)\n"
		..WEPHELP_ALTFIRE.."  Work bolt\n"
		..WEPHELP_RELOAD.."  Reload rounds/clip\n"
		..WEPHELP_ZOOM.."+"..WEPHELP_FIREMODE.."  Zoom\n"
		..WEPHELP_ZOOM.."+"..WEPHELP_USE.."  Bullet drop\n"
		..WEPHELP_ZOOM.."+"..WEPHELP_DROPONE.."  Force drop non-recast\n"
		..WEPHELP_ZOOM.."+"..WEPHELP_ALTRELOAD.."  Force load recast\n"
		..WEPHELP_ALTFIRE.."+"..WEPHELP_UNLOAD.."  Unload chamber/Clean rifle\n"
		..WEPHELP_UNLOADUNLOAD
		;
	}


	override void DrawSightPicture(
		HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl,
		bool sightbob,vector2 bob,double fov,bool scopeview,actor hpc
	){
		int cx,cy,cw,ch;
		[cx,cy,cw,ch]=Screen.GetClipRect();


		sb.SetClipRect(
			-16+bob.x,-64+bob.y,32,76,
			sb.DI_SCREEN_CENTER
		);

//  no front sight, lol

		sb.drawimage(
			"bsfrntsit",(0,0)+bob*1.14,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,alpha:0.0
		);

		sb.SetClipRect(cx,cy,cw,ch);
		sb.drawimage(
			"bsbaksit",(0,0)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			alpha:0.9
		);

		if(scopeview){
			int scaledwidth=89;
			int scaledyoffset=60;
			double degree=0.1*hdw.weaponstatus[OBROZZS_ZOOM];
			double deg=1/degree;
			int cx,cy,cw,ch;
			[cx,cy,cw,ch]=screen.GetClipRect();
			sb.SetClipRect(-44+bob.x,16+bob.y,scaledwidth,scaledwidth,
				sb.DI_SCREEN_CENTER
			);

			sb.fill(color(255,0,0,0),
				bob.x-44,scaledyoffset+bob.y-44,
				88,88,sb.DI_SCREEN_CENTER|sb.DI_ITEM_CENTER
			);

			texman.setcameratotexture(hpc,"HDXCAM_BOSS",degree);
			let cam     = texman.CheckForTexture("HDXCAM_BOSS",TexMan.Type_Any);
			let reticle = texman.CheckForTexture("bossret1",TexMan.Type_Any);

			vector2 frontoffs=(0,scaledyoffset)+bob*3;

			double camSize  = texman.GetSize(cam);
			sb.DrawCircle(cam, frontoffs, 0.125,usePixelRatio:true);

			let reticleScale = camSize / texman.GetSize(reticle);
			if(hdw.weaponstatus[0]&OBROZZF_FRONTRETICLE){
				sb.DrawCircle(reticle, frontoffs, .5*reticleScale, bob*deg*5-bob, 1.6*deg);
			}else{
				sb.DrawCircle(reticle, (0,scaledyoffset)+bob, .5*reticleScale,uvScale:.5);
			}

			//let holeScale    = camSize / texman.GetSize(hole);
			//let hole    = texman.CheckForTexture("scophole",TexMan.Type_Any);
			//sb.DrawCircle(hole, (0, scaledyoffset) + bob, .5 * holeScale, bob * 5, 1.5);


			screen.SetClipRect(cx,cy,cw,ch);

			sb.drawimage(
				"bossscope",(0,scaledyoffset)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_CENTER,
				scale:(1.24,1.24)
			);
			sb.drawstring(
				sb.mAmountFont,string.format("%.1f",degree),
				(6+bob.x,105+bob.y),sb.DI_SCREEN_CENTER|sb.DI_TEXT_ALIGN_RIGHT,
				Font.CR_BLACK
			);
			sb.drawstring(
				sb.mAmountFont,string.format("%i",hdw.weaponstatus[OBROZZS_DROPADJUST]),
				(6+bob.x,9+bob.y),sb.DI_SCREEN_CENTER|sb.DI_TEXT_ALIGN_RIGHT,
				Font.CR_BLACK
			);
		}
		// the scope display is in 10ths of an arcminute.
		// one dot = 6 arcminutes.
	}

	override void consolidate(){
		weaponstatus[OBROZZS_GRIME]=random(0,20);
	}
	override void DropOneAmmo(int amt){
		if(owner){
			amt=clamp(amt,1,10);
			if(
				owner.countinv("SevenMilAmmoRecast")
				&&(
					!(
						owner.player
						&&owner.player.cmd.buttons&BT_ZOOM
					)||!owner.countinv("SevenMilAmmo")
				)
			)owner.A_DropInventory("SevenMilAmmoRecast",10);
			else if(owner.countinv("SevenMilAmmo"))owner.A_DropInventory("SevenMilAmmo",10);
			else owner.A_DropInventory("HD7mClip",1);
		}
	}
	override void ForceBasicAmmo(){
		owner.A_SetInventory("SevenMilAmmo",11);
		owner.A_TakeInventory("SevenMilBrass");
		owner.A_TakeInventory("FourMilAmmo");
		ForceOneBasicAmmo("HD7mClip");
	}

	int handrounds;
	override void DetachFromOwner(){
		if(handrounds>0){
			actor dropper=self;
			if(owner)dropper=owner;

			int fullets=handrounds/100;

			if(fullets>0)dropper.A_DropItem("SevenMilAmmo",fullets);

			handrounds=(handrounds%100)-fullets;
			if(handrounds>0)dropper.A_DropItem("SevenMilAmmoRecast",handrounds);
		}
		super.DetachFromOwner();
	}

	states{
	select0:
		BARG A 0;
		goto select0bfg;
	deselect0:
		BARG A 0;
		goto deselect0big;

	ready:
		BARG A 1{
			if(pressingzoom()){
				if(player.cmd.buttons&BT_USE){
					A_ZoomAdjust(OBROZZS_DROPADJUST,0,1600,BT_USE);
				}else if(invoker.weaponstatus[0]&OBROZZF_FRONTRETICLE)A_ZoomAdjust(OBROZZS_ZOOM,12,40);
				else A_ZoomAdjust(OBROZZS_ZOOM,5,60);
				A_WeaponReady(WRF_NONE);
			}else A_WeaponReady(WRF_ALL);
		}goto readyend;
	user3:
		---- A 0 A_MagManager("HD7mClip");
		goto ready;
	fire:
		BARG A 1 A_JumpIf(invoker.weaponstatus[OBROZZS_CHAMBER]==2,"shoot");
		goto ready;
	shoot:
		BARG A 1{
			bool recast=invoker.weaponstatus[0]&OBROZZF_RECAST;
			A_Gunflash();
			invoker.weaponstatus[OBROZZS_CHAMBER]=1;
			invoker.weaponstatus[0]&=~OBROZZF_RECAST;
			A_StartSound("weapons/bigrifle2",CHAN_WEAPON,CHANF_OVERLAP,
				pitch:!(invoker.weaponstatus[0]&OBROZZF_CUSTOMCHAMBER)?1.1:1.
			);
			A_AlertMonsters();

			HDBulletActor.FireBullet(self,recast?"HDB_776r":"HDB_776",
				aimoffy:(-HDCONST_GRAVITY/1000.)*invoker.weaponstatus[OBROZZS_DROPADJUST],
				speedfactor:(invoker.weaponstatus[0]&OBROZZF_CUSTOMCHAMBER)?0.79:0.87
			);//worse muzzle velocity from cutdown barrel

    A_MuzzleClimb(
				0,0,
				-frandom(0.3,0.5),-frandom(0.8,1.3),
				-frandom(0.5,0.9),-frandom(1.6,2.8),
				-frandom(0.5,0.9),-frandom(1.6,2.8)
			);//higher muzzleclimb from one-handed grip

/*	original muzzleclimb

		A_MuzzleClimb(
				0,0,
				-frandom(0.2,0.4),-frandom(0.6,1.),
				-frandom(0.4,0.7),-frandom(1.2,2.1),
				-frandom(0.4,0.7),-frandom(1.2,2.1)
			);
*/
		}
		BARG F 1;
		BARG F 1 A_JumpIf(gunbraced(),"ready");
		goto ready;
	flash:
		BARF A 1 bright{
			A_Light1();
			HDFlashAlpha(-96);
			A_ZoomRecoil(0.93);
			A_ChamberGrit(randompick(0,0,0,0,0,1,1,1,1,-1));
		}
		TNT1 A 0 A_Light0();
		stop;
	altfire:
		BARG A 1 A_WeaponBusy();
		BARG B 2 A_JumpIf(invoker.weaponstatus[0]&OBROZZF_CUSTOMCHAMBER,1);
		BARG B 1 A_JumpIf(invoker.weaponstatus[OBROZZS_CHAMBER]>2,"jamderp");
		BARG B 1 A_MuzzleClimb(-frandom(0.06,0.1),-frandom(0.3,0.5));
		BARG B 0 A_ChamberGrit(randompick(0,0,0,0,-1,1,2),true);
		BARG B 0 A_Refire("chamber");
		goto ready;
	althold:
		BARG E 1 A_WeaponReady(WRF_NOFIRE);
		BARG E 1{
			A_ClearRefire();
			bool chempty=invoker.weaponstatus[OBROZZS_CHAMBER]<1;
			if(pressingunload()){
				if(chempty){
					return resolvestate("altholdclean");
				}else{
					invoker.weaponstatus[0]|=OBROZZF_UNLOADONLY;
					return resolvestate("loadchamber");
				}
			}else if(pressingreload()){
				if(
					!chempty
				){
					invoker.weaponstatus[0]|=OBROZZF_UNLOADONLY;
					return resolvestate("loadchamber");
				}else if(
					countinv("SevenMilAmmo")
					||countinv("SevenMilAmmoRecast")
				){
					invoker.weaponstatus[0]&=~OBROZZF_UNLOADONLY;
					return resolvestate("loadchamber");
				}
			}
			if(pressingaltfire())return resolvestate("althold");
			return resolvestate("altholdend");
		}
	altholdend:
		BARG E 0 A_StartSound("weapons/boltfwd",8);
		BARG DC 2 A_WeaponReady(WRF_NOFIRE);
		BARG B 3{
			A_WeaponReady(WRF_NOFIRE);
			if(invoker.weaponstatus[0]&OBROZZF_CUSTOMCHAMBER)A_SetTics(1);
		}
		goto ready;
	loadchamber:
		BARG E 1 offset(2,36) A_ClearRefire();
		BARG E 1 offset(3,38);
		BARG E 1 offset(5,42);
		BARG E 1 offset(8,48) A_StartSound("weapons/pocket",9);
		BARG E 1 offset(9,52) A_MuzzleClimb(frandom(-0.2,0.2),0.2,frandom(-0.2,0.2),0.2,frandom(-0.2,0.2),0.2);
		BARG E 2 offset(8,60);
		BARG E 2 offset(7,72);
		TNT1 A 18 A_StartSound("weapons/pocket",9);
		TNT1 A 4{
			A_StartSound("weapons/bossload",8,volume:0.7);
			if(invoker.weaponstatus[0]&OBROZZF_UNLOADONLY){
				bool recast=invoker.weaponstatus[0]&OBROZZF_RECAST;
				int chm=invoker.weaponstatus[OBROZZS_CHAMBER];
				invoker.weaponstatus[OBROZZS_CHAMBER]=0;
				invoker.weaponstatus[0]&=~OBROZZF_RECAST;
				if(
					chm<2
					||A_JumpIfInventory(recast?"SevenMilAmmoRecast":"SevenMilAmmo",0,"null")
				){
					class<actor> whatkind=chm==2?
						(recast?"HDLoose7mmRecast":"HDLoose7mm")
						:"HDSpent7mm"
					;
					actor rrr=spawn(whatkind,pos+(cos(angle)*10,sin(angle)*10,height-12),ALLOW_REPLACE);
					rrr.angle=angle;rrr.A_ChangeVelocity(1,2,1,CVF_RELATIVE);
				}else HDF.Give(self,"SevenMilAmmo",1);
				A_ChamberGrit(randompick(0,0,0,0,-1,1),true);
			}else{
				class<inventory> rndtp="SevenMilAmmo";
				if(!countinv(rndtp)){
					invoker.weaponstatus[0]|=OBROZZF_RECAST;
					rndtp="SevenMilAmmoRecast";
				}
				A_TakeInventory(rndtp,1,TIF_NOTAKEINFINITE);
				invoker.weaponstatus[OBROZZS_CHAMBER]=2;
			}
		} 
		BARG E 2 offset(7,72);
		BARG E 2 offset(8,60);
		BARG E 1 offset(6,52);
		BARG E 1 offset(5,42);
		BARG E 1 offset(4,38);
		BARG E 1 offset(3,35);
		goto althold;
	altholdclean:
		BARG E 1 offset(2,36) A_ClearRefire();
		BARG E 1 offset(3,38);
		BARG E 1 offset(5,41) A_Log("Looking inside that chamber...",true);
		BARG E 1 offset(8,44) A_StartSound("weapons/pocket",9);
		BARG E 1 offset(7,50) A_MuzzleClimb(frandom(-0.2,0.2),0.2,frandom(-0.2,0.2),0.2,frandom(-0.2,0.2),0.2);
		TNT1 A 3 A_StartSound("weapons/pocket",10);
		TNT1 AAAA 4 A_MuzzleClimb(frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2));
		TNT1 A 3 A_StartSound("weapons/pocket",9);
		TNT1 AAAA 4 A_MuzzleClimb(frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2));
		TNT1 A 40{
			A_StartSound("weapons/pocket",9);
			int amt=invoker.weaponstatus[OBROZZS_GRIME];
			string amts="There doesn't seem to be much. ";
			if(amt>40)amts="What the FUCK. ";
			else if(amt>30)amts="About time - this gun is barely functional. ";
			else if(amt>20)amts="This is starting to gum up badly. ";
			else if(amt>10)amts="It can use some cleaning. ";

			static const string cleanverbs[]={"extract","scrape off","wipe away","{care|skil|force}fully remove","dump out","pick out","blow off","shake out","scrub off","fish out"};
			static const string contaminants[]={"some dust","a lot of dust","a bit of powder residue","a disturbing amount of powder residue","some excess grease","a layer of soot","some iron filings","a bit of hair","an eyelash","a patch of dried blood","a bit of rust","a crumb","a dead {insect|spider|ant|wasp}","ashes","some loose bits of skin","a sticky fluid of some sort","wow some fucking *gunk*","a booger","trace fecal matter","yet even more of that anonymous grey debris that all those bullet impacts make","a dollop of {straw|blue|rasp}berry jam","the dried husk of a {pinto|fava|mung} bean with residual hog components","a tiny cancerous nodule of Second Flesh","some crystalline buildup of congealed Frag","a nesting queen space ant","a single modern-day transistor","a tiny Boss rifle (also jammed)","a colourless film of darkness made visible"};
			static const string actionparts[]={"bolt carrier","main extractor","auxiliary extractor","cam pin","bolt head","striker","firing pin spring","ejector slot","striker spring","ejector spring"};
			for(int i=amt;i>0;i-=random(8,16))amts.appendformat("You %s %s from the %s. ",
				cleanverbs[random(0,cleanverbs.size()-1)],
				contaminants[random(0,random(0,contaminants.size()-1))],
				actionparts[random(0,random((actionparts.size()>>1),actionparts.size()-1))]
			);
			amts=HDMath.BuildVariableString(amts);
			amts.appendformat("\n");

			amt=randompick(-3,-5,-5,-random(8,16));

			A_ChamberGrit(amt,true);
			amt=invoker.weaponstatus[OBROZZS_GRIME];
			if(amt>40)amts.appendformat("You barely scrape the surface of this all-encrusting abomination.");
			else if(amt>30)amts.appendformat("The gun will need a lot more work than this before it can be deployed again.");
			else if(amt>20)amts.appendformat("You might get a few shots out of it now.");
			else if(amt>10)amts.appendformat("It's better, but still not good.");
			else amts.appendformat("Good to go.");
			A_Log(amts,true);
		}
		BARG E 1 offset(7,52);
		BARG E 1 offset(8,48);
		BARG E 1 offset(5,42);
		BARG E 1 offset(3,38);
		BARG E 1 offset(2,36);
		goto althold;
	jam:
		BARG A 0{
			int chm=invoker.weaponstatus[OBROZZS_CHAMBER];
			if(chm<1)setweaponstate("chamber");
			else if(chm<3)invoker.weaponstatus[OBROZZS_CHAMBER]+=2;
		}
	jamderp:
		BARG A 0 A_StartSound("weapons/rifleclick",8,CHANF_OVERLAP);
		BARG D 1 offset(4,38);
		BARG D 2 offset(2,36);
		BARG D 2 offset(4,38)A_MuzzleClimb(frandom(-0.5,0.6),frandom(-0.3,0.6));
		BARG D 3 offset(2,36){
			A_MuzzleClimb(frandom(-0.5,0.6),frandom(-0.3,0.6));
			if(random(0,invoker.jamchance())<12){
				setweaponstate("chamber");
				if(invoker.weaponstatus[OBROZZS_CHAMBER]>2)  
					invoker.weaponstatus[OBROZZS_CHAMBER]-=2;
			}
		}
		BARG D 2 offset(4,38);
		BARG D 3 offset(2,36);
		BARG A 0 A_Refire("jamderp");
		goto ready;
	chamber:
		BARG C 2{
			if(
				random(0,max(2,invoker.weaponstatus[OBROZZS_GRIME]>>3))
				&&invoker.weaponstatus[OBROZZS_CHAMBER]>2
			){
				invoker.weaponstatus[OBROZZS_CHAMBER]+=2;
				A_MuzzleClimb(
					-frandom(0.6,2.3),-frandom(0.6,2.3),
					-frandom(0.6,1.3),-frandom(0.6,1.3),
					-frandom(0.6,1.3),-frandom(0.6,1.3)
				);
				setweaponstate("jamderp");
			}else A_StartSound("weapons/boltback",8);
		}
		BARG D 2 offset(1,34)A_JumpIf(invoker.weaponstatus[0]&OBROZZF_CUSTOMCHAMBER,1);
		BARG D 1 offset(2,36){
			if(gunbraced())A_MuzzleClimb(
				frandom(-0.1,0.3),frandom(-0.1,0.3)
			);else A_MuzzleClimb(
				frandom(-0.2,0.8),frandom(-0.4,0.8)
			);
			int jamch=invoker.jamchance();
			if(hd_debug)A_Log("jam chance: "..jamch);
			if(random(0,100)<jamch)setweaponstate("jam");
		}
		BARG D 2 offset(1,34){
			//eject
			int chm=invoker.weaponstatus[OBROZZS_CHAMBER];
			bool recast=invoker.weaponstatus[0]&OBROZZF_RECAST;
			invoker.weaponstatus[0]&=~OBROZZF_RECAST;
			class<actor> rndtp=chm==1?"HDSpent7mm":recast?"HDLoose7mmRecast":"HDLoose7mm";
			double cp=cos(pitch);
			double sp=sin(pitch);
			actor rrr=null;
			if(chm>=1){
				vector3 gunofs=HDMath.RotateVec3D((10,-1,0),angle,pitch);
				actor rrr=spawn(rndtp,(pos.xy,pos.z+height*0.85)+gunofs+viewpos.offset);
				rrr.target=self;
				rrr.angle=angle;
				rrr.vel=HDMath.RotateVec3D((1,-4,2),angle,pitch);
				if(chm==1)rrr.vel*=1.3;
				rrr.vel+=vel;
			}


			//cycle new
			int bbm=invoker.weaponstatus[OBROZZS_MAG];
			if(bbm>0){
				if(
					HD7mMag.CheckRecast(bbm,invoker.weaponstatus[OBROZZS_RECASTS])
				){
					invoker.weaponstatus[OBROZZS_RECASTS]--;
					invoker.weaponstatus[0]|=OBROZZF_RECAST;
				}
				invoker.weaponstatus[OBROZZS_CHAMBER]=2;
				invoker.weaponstatus[OBROZZS_MAG]--;
			}else invoker.weaponstatus[OBROZZS_CHAMBER]=0;
		}
		BARG E 1 A_WeaponReady(WRF_NOFIRE);
		BARG E 0 A_Refire("althold");
		goto altholdend;

	reload:
		---- A 0{invoker.weaponstatus[0]&=~OBROZZF_DONTUSECLIPS;}
		goto reloadstart;
	altreload:
		---- A 0{invoker.weaponstatus[0]|=OBROZZF_DONTUSECLIPS;}
		goto reloadstart;
	reloadstart:
		BARG A 1 offset(0,34);
		BARG A 1 offset(2,36);
		BARG A 1 offset(4,40);
		BARG A 2 offset(8,42){
			A_StartSound("weapons/rifleclick2",8,CHANF_OVERLAP,0.9,pitch:0.95);
			A_MuzzleClimb(-frandom(0.4,0.8),frandom(0.4,1.4));
		}
		BARG A 4 offset(14,46){
			A_StartSound("weapons/bossloadm",8,CHANF_OVERLAP);
			A_MuzzleClimb(-frandom(0.4,0.8),frandom(0.4,1.4));
		}
		BARG A 0{
			int mg=invoker.weaponstatus[OBROZZS_MAG];
			if(mg==10)setweaponstate("reloaddone");
			else if(invoker.weaponstatus[0]&OBROZZF_DONTUSECLIPS)setweaponstate("loadhand");
			else if(
				(
					mg<1
					||(
						!countinv("SevenMilAmmo")
						&&!countinv("SevenMilAmmoRecast")
					)
				)&&!HDMagAmmo.NothingLoaded(self,"HD7mClip")
			)setweaponstate("loadclip");
		}
	loadhand:
		BARG A 0 A_JumpIfInventory("SevenMilAmmo",1,"loadhandloop");
		BARG A 0 A_JumpIfInventory("SevenMilAmmoRecast",1,"loadhandloop");
		goto reloaddone;
	loadhandloop:
		BARG A 4{
			class<inventory> rndtp="SevenMilAmmo";
			if(
				!countinv(rndtp)
				||(
					countinv("SevenMilAmmoRecast")
					&&pressingzoom()
				)
			)rndtp="SevenMilAmmoRecast";
			int hnd=min(
				countinv(rndtp),3,
				10-invoker.weaponstatus[OBROZZS_MAG]
			);
			if(hnd<1){
				setweaponstate("reloaddone");
				return;
			}else{
				A_TakeInventory(rndtp,hnd,TIF_NOTAKEINFINITE);
				invoker.handrounds=hnd;
				if(rndtp=="SevenMilAmmo")invoker.handrounds+=hnd*100;
				A_StartSound("weapons/pocket",9);
			}
		}
	loadone:
		BARG A 2 offset(16,50) A_JumpIf(invoker.handrounds<1,"loadhandnext");
		BARG A 4 offset(14,46){
			if(invoker.handrounds>100)invoker.handrounds-=100;
			else invoker.weaponstatus[OBROZZS_RECASTS]++;

			invoker.handrounds--;
			invoker.weaponstatus[OBROZZS_MAG]++;

			A_StartSound("weapons/rifleclick2",8);
		}loop;
	loadhandnext:
		BARG A 8 offset(16,48){
			if(
				PressingReload()||
				PressingFire()||
				PressingAltFire()||
				PressingZoom()||
				(
					!countinv("SevenMilAmmo")	//don't strip clips automatically
					&&!countinv("SevenMilAmmoRecast")
				)
			)setweaponstate("reloaddone");
			else A_StartSound("weapons/pocket",9);
		}goto loadhandloop;
	loadclip:
		BARG A 0 A_JumpIf(invoker.weaponstatus[OBROZZS_MAG]>9,"reloaddone");
		BARG A 3 offset(16,50){
			let ccc=hdmagammo(findinventory("HD7mClip"));
			if(ccc){
				//find the last mag that has anything in it and load from that
				bool fullmag=false;
				int magindex=-1;
				for(int i=ccc.mags.size()-1;i>=0;i--){
					if(ccc.mags[i]>=10)fullmag=true;
					if(magindex<0&&ccc.mags[i]>0)magindex=i;
					if(fullmag&&magindex>0)break;
				}
				if(magindex<0){
					setweaponstate("reloaddone");
					return;
				}

				//load the whole clip at once if possible
				if(
					fullmag
					&&invoker.weaponstatus[OBROZZS_MAG]<1
				){
					setweaponstate("loadwholeclip");
					return;
				}

				//strip one round and load it
				A_StartSound("weapons/rifleclick2",CHAN_WEAPONBODY);

				if(HD7mMag.CheckRecast(ccc.mags[magindex])){
					invoker.weaponstatus[OBROZZS_RECASTS]++;
				}else{
					ccc.mags[magindex]-=100;
				}
				invoker.weaponstatus[OBROZZS_MAG]++;
				ccc.mags[magindex]--;
			}
		}
		BARG A 5 offset(16,52) A_JumpIf(
			PressingReload()||
			PressingFire()||
			PressingAltFire()||
			PressingZoom()
		,"reloaddone");
		loop;
	loadwholeclip:
		BARG A 4 offset(16,50) A_StartSound("weapons/rifleclick2",8);
		BARG AAA 3 offset(17,52) A_StartSound("weapons/rifleclick2",8,pitch:1.01);
		BARG AAA 2 offset(16,50) A_StartSound("weapons/rifleclick2",8,CHANF_OVERLAP,pitch:1.02);
		BARG AAA 1 offset(15,48) A_StartSound("weapons/rifleclick2",8,CHANF_OVERLAP,pitch:1.02);
		BARG A 2 offset(14,46){
			A_StartSound("weapons/rifleclick",CHAN_WEAPONBODY);
			let ccc=hdmagammo(findinventory("HD7mClip"));
			if(ccc){
				int roundraw=ccc.TakeMag(true);
				int roundcount=roundraw%100;
				int reccount=roundcount-(roundraw/100);

				invoker.weaponstatus[OBROZZS_RECASTS]=reccount;
				invoker.weaponstatus[OBROZZS_MAG]=roundcount;

				if(pressingreload()){
					ccc.addamag(0);
					A_SetTics(10);
					A_StartSound("weapons/pocket",CHAN_POCKETS);
				}else HDMagAmmo.SpawnMag(self,"HD7mClip",0);
			}
		}goto reloaddone;
	reloaddone:
		BARG A 1 offset(4,40);
		BARG A 1 offset(2,36);
		BARG A 1 offset(0,34);
		goto nope;
	unload:
		BARG A 1 offset(0,34);
		BARG A 1 offset(2,36);
		BARG A 1 offset(4,40);
		BARG A 2 offset(8,42){
			A_MuzzleClimb(-frandom(0.4,0.8),frandom(0.4,1.4));
			A_StartSound("weapons/rifleclick2",8);
		}
		BARG A 4 offset (14,46){
			A_MuzzleClimb(-frandom(0.4,0.8),frandom(0.4,1.4));
			A_StartSound("weapons/bossloadm",8);
		}
	unloadloop:
		BARG A 4 offset(3,41){
			if(invoker.weaponstatus[OBROZZS_MAG]<1)setweaponstate("unloaddone");
			else{
				int bbm=invoker.weaponstatus[OBROZZS_MAG];
				bool recast=HD7mMag.CheckRecast(bbm,invoker.weaponstatus[OBROZZS_RECASTS]);
				class<inventory> rndtp=recast?"SevenMilAmmoRecast":"SevenMilAmmo";

				A_StartSound("weapons/rifleclick2",8);
				invoker.weaponstatus[OBROZZS_MAG]--;
				if(recast)invoker.weaponstatus[OBROZZS_RECASTS]--;
				if(A_JumpIfInventory(rndtp,0,"null")){
					A_SpawnItemEx(
						recast?"HDLoose7mmRecast":"HDLoose7mm",cos(pitch)*8,0,height-7-sin(pitch)*8,
						cos(pitch)*cos(angle-40)*1+vel.x,
						cos(pitch)*sin(angle-40)*1+vel.y,
						-sin(pitch)*1+vel.z,
						0,SXF_ABSOLUTEMOMENTUM|
						SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
					);
				}else A_GiveInventory(rndtp,1);
			}
		}
		BARG A 2 offset(2,42);
		BARG A 0{
			if(
				PressingReload()||
				PressingFire()||
				PressingAltFire()||
				PressingZoom()
			)setweaponstate("unloaddone");
		}loop;
	unloaddone:
		BARG A 2 offset(2,42);
		BARG A 3 offset(3,41);
		BARG A 1 offset(4,40) A_StartSound("weapons/rifleclick",8);
		BARG A 1 offset(2,36);
		BARG A 1 offset(0,34);
		goto ready;

firemode:
  swappistols:
		---- A 0 A_Swaprifles();
		---- A 0{
			bool id=(Wads.CheckNumForName("id",0)!=-1);
			bool offhand=invoker.wronghand;
			bool lefthanded=(id!=offhand);
			if(lefthanded){
				A_Overlay(1025,"raiseleft");
				A_Overlay(1026,"lowerright");
			}else{
				A_Overlay(1025,"raiseright");
				A_Overlay(1026,"lowerleft");
			}
		}
		TNT1 A 5;
		BARG A 0 A_CheckRifleHand();
		goto nope;
	lowerleft:
   BARG A 0 ;
		#### A 1 offset(-6,38);
		#### A 1 offset(-12,48);
		#### A 1 offset(-20,60);
		#### A 1 offset(-34,76);
		#### A 1 offset(-50,86);
		stop;
	lowerright:
   BARG A 0 ;
		#### A 1 offset(6,38);
		#### A 1 offset(12,48);
		#### A 1 offset(20,60);
		#### A 1 offset(34,76);
		#### A 1 offset(50,86);
		stop;
	raiseleft:
   BARG A 0;
		#### A 1 offset(-50,86);
		#### A 1 offset(-34,76);
		#### A 1 offset(-20,60);
		#### A 1 offset(-12,48);
		#### A 1 offset(-6,38);
		stop;
	raiseright:
		BARG A 0;
		#### A 1 offset(50,86);
		#### A 1 offset(34,76);
		#### A 1 offset(20,60);
		#### A 1 offset(12,48);
		#### A 1 offset(6,38);
		stop;
	whyareyousmiling:
		#### A 1 offset(0,48);
		#### A 1 offset(0,60);
		#### A 1 offset(0,76);
		TNT1 A 7;
   BARG A 0;
   #### A 0{
			invoker.wronghand=!invoker.wronghand;
			A_CheckRifleHand();
		}
		#### B 1 offset(0,76);
		#### B 1 offset(0,60);
		#### B 1 offset(0,48);
		goto nope;
	

	spawn:
		OBRZ A -1;
	}
	override void InitializeWepStats(bool idfa){
		weaponstatus[OBROZZS_CHAMBER]=2;
		weaponstatus[OBROZZS_MAG]=10;
		weaponstatus[OBROZZS_RECASTS]=0;
		if(!idfa){
			weaponstatus[OBROZZS_HEAT]=0;
		}
		if(!owner){
			if(randompick(0,0,1))weaponstatus[0]&=~OBROZZF_FRONTRETICLE;
				else weaponstatus[0]|=OBROZZF_FRONTRETICLE;
			if(random(0,3))weaponstatus[0]&=~OBROZZF_CUSTOMCHAMBER;
				else weaponstatus[0]|=OBROZZF_CUSTOMCHAMBER;
			weaponstatus[OBROZZS_ZOOM]=20;
			weaponstatus[OBROZZS_DROPADJUST]=127;
		}
	}
	override void loadoutconfigure(string input){
		int customchamber=getloadoutvar(input,"customchamber",1);
		if(!customchamber)weaponstatus[0]&=~OBROZZF_CUSTOMCHAMBER;
		else if(customchamber>0)weaponstatus[0]|=OBROZZF_CUSTOMCHAMBER;

		int frontreticle=getloadoutvar(input,"frontreticle",1);
		if(!frontreticle)weaponstatus[0]&=~OBROZZF_FRONTRETICLE;
		else if(frontreticle>0)weaponstatus[0]|=OBROZZF_FRONTRETICLE;

		int bulletdrop=getloadoutvar(input,"bulletdrop",3);
		if(bulletdrop>=0)weaponstatus[OBROZZS_DROPADJUST]=clamp(bulletdrop,0,1600);

		int zoom=getloadoutvar(input,"zoom",3);
		if(zoom>0)weaponstatus[OBROZZS_ZOOM]=
			(weaponstatus[0]&OBROZZF_FRONTRETICLE)?
			clamp(zoom,12,40):
			clamp(zoom,5,60);
	}
}
enum obrozzstatus{
	OBROZZF_FRONTRETICLE=1,
	OBROZZF_CUSTOMCHAMBER=2,
	OBROZZF_UNLOADONLY=4,
	OBROZZF_DONTUSECLIPS=8,
	OBROZZF_RECAST=16,

	OBROZZS_CHAMBER=1, //0=nothing, 1=brass, 2=loaded, 3/4=jammed brass/round
	OBROZZS_MAG=2,
	OBROZZS_ZOOM=3,
	OBROZZS_DROPADJUST=4,
	OBROZZS_HEAT=5,
	OBROZZS_GRIME=6,
	OBROZZS_RECASTS=7,
}


