// ------------------------------------------------------------
// Savage 99 Lever-Action Rifle
// ------------------------------------------------------------

//extra ammo that spawns with the Savage 99
class HDSavage300AmmoPickup:HDUPK{
	default{
		//$Category "Ammo/Hideous Destructor/"
		//$Title ".300 Savage Ammo Pickup"
		//$Sprite "SVG6A0"

        xscale 0.7;yscale 0.8;
        hdupk.amount 6;
		hdupk.pickupsound "weapons/pocket";
		hdupk.pickupmessage "Picked up some .300 Savage ammo.";
		hdupk.pickuptype "Savage300Ammo";
	}
	states{
	spawn:
		SVG6 A -1;
	}
}


class Savage99RifleSpawner:IdleDummy{
	states{
	spawn:
		TNT1 A 0 nodelay{
			if(!random(0,9))A_SpawnItemEx("SavageAutoReloader",1,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
			A_SpawnItemEx("HDSavage300AmmoPickup",1,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
			let ggg=Savage99SniperRifle(spawn("Savage99SniperRifle",pos,ALLOW_REPLACE));
			HDF.TransferSpecials(self,ggg,HDF.TS_ALL);
		}stop;
	}
}

const HDLD_S99 = "s99";

class Savage99SniperRifle:HDWeapon{
	default{
		weapon.slotnumber 8;
		weapon.slotpriority 0.1;
		weapon.kickback 15;
		weapon.selectionorder 80;
		inventory.pickupSound "misc/w_pkup";
		weapon.bobrangex 0.28;
		weapon.bobrangey 1.1;
		scale 0.75;
		obituary "$OB_S99";
		hdweapon.barrelsize 40,1,2;
		hdweapon.refid HDLD_S99;
		tag "$TAG_S99";

		hdweapon.loadoutcodes "
			\cufrontreticle - 0/1, whether crosshair scales with zoom
			\cubulletdrop - 0-600, amount of compensation for bullet drop
			\cuzoom - 5-60, 10x the resulting FOV in degrees";
	}
	
	override string PickupMessage(){return Stringtable.Localize("$PICKUP_S99");}

	override bool AddSpareWeapon(actor newowner){return AddSpareWeaponRegular(newowner);}
	override hdweapon GetSpareWeapon(actor newowner,bool reverse,bool doselect){return GetSpareWeaponRegular(newowner,reverse,doselect);}

	action void A_ChamberGrit(int amt,bool onlywhileempty=false){
		int ibg=invoker.weaponstatus[BOSSS_GRIME];
		if(!onlywhileempty||invoker.weaponstatus[BOSSS_CHAMBER]<1)ibg+=amt;
		else if(!random(0,4))ibg++;
		invoker.weaponstatus[BOSSS_GRIME]=clamp(ibg,0,100);
		//if(hd_debug)A_Log(string.format("Savage 99 grit level: %i",invoker.weaponstatus[BOSSS_GRIME]));
	}
	int pickuprounds;
	override void tick(){
		super.tick();
		drainheat(BOSSS_HEAT,4);
	}
	override double gunmass(){
		return 10;
	}
	override double weaponbulk(){
		return 124+weaponstatus[BOSSS_MAG]*ENC_776_LOADED;
	}
	override void GunBounce(){
		super.GunBounce();
		weaponstatus[BOSSS_GRIME]+=random(-7,3);
		if(weaponstatus[BOSSS_CHAMBER]>2&&!random(0,7))weaponstatus[BOSSS_CHAMBER]-=2;
	}
	int jamchance(){
		int jc=
		weaponstatus[BOSSS_GRIME]
		+(weaponstatus[BOSSS_HEAT]>>2)
		+weaponstatus[BOSSS_CHAMBER]
		;
		return jc;
	}
	override string,double getpickupsprite(){return "SV39A0",1.;}
	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
			int savagerounds=hpl.countinv("Savage300Ammo");
			sb.drawimage("SVG6A0",(-56,-4),sb.DI_SCREEN_CENTER_BOTTOM,alpha:savagerounds?1:0.6,scale:(1.2,1.2));
			sb.drawnum(savagerounds,-52,-8,sb.DI_SCREEN_CENTER_BOTTOM);
		}
		sb.drawwepnum(hdw.weaponstatus[BOSSS_MAG],6);
		sb.drawnum(hdw.weaponstatus[BOSSS_MAG],-44,-12,sb.DI_SCREEN_CENTER_BOTTOM, Font.CR_GOLD);
    //rifle has a built-in mechanical round counter
	
		sb.drawwepcounter(hdw.weaponstatus[BOSSS_CHAMBER],
			-16,-10,"blank","RBRSA1A5","RBRSA3A7","RBRSA4A6"
		);
	    sb.drawstring(
			sb.mAmountFont,string.format("%.1f",hdw.weaponstatus[BOSSS_ZOOM]*0.1),
			(-36,-18),sb.DI_SCREEN_CENTER_BOTTOM|sb.DI_TEXT_ALIGN_RIGHT,Font.CR_DARKGRAY
		);
		sb.drawstring(
			sb.mAmountFont,string.format("%i",hdw.weaponstatus[BOSSS_DROPADJUST]),
			(-16,-18),sb.DI_SCREEN_CENTER_BOTTOM|sb.DI_TEXT_ALIGN_RIGHT,Font.CR_WHITE
		);

	}
	override string gethelptext(){
		return
		WEPHELP_FIRESHOOT
		..WEPHELP_ALTFIRE.."  Work lever\n"
		.."While holding "..WEPHELP_ALTFIRE.."...\n"
		.."  +"..WEPHELP_RELOAD.."  Reload chamber/magazine\n"
		.."  +"..WEPHELP_UNLOAD.."  Unload chamber/magazine/Clean rifle\n"
		..WEPHELP_ZOOM.."+"..WEPHELP_FIREMODE.."  Zoom\n"
		..WEPHELP_ZOOM.."+"..WEPHELP_USE.."  Bullet drop\n"
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
		sb.drawimage(
			"bsfrntsit",bob*1.14,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP
		);
		sb.SetClipRect(cx,cy,cw,ch);

		sb.drawimage(
			"bsbaksit",(0,0)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			alpha:0.9
		);

		if(scopeview){
			int scaledwidth=89;
			int scaledyoffset=0;//centered scope
			double degree=0.1*hdw.weaponstatus[BOSSS_ZOOM];
			double deg=1/degree;
			int cx,cy,cw,ch;
			[cx,cy,cw,ch]=screen.GetClipRect();
			sb.SetClipRect(-44+bob.x,-44+bob.y,scaledwidth,scaledwidth,
				sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP
			);

			sb.fill(color(255,0,0,0),
				bob.x-44,0+bob.y-44,
				88,88,sb.DI_SCREEN_CENTER
			);

			texman.setcameratotexture(hpc,"HDXCAM_SAVAGE99",degree);
			let cam     = texman.CheckForTexture("HDXCAM_SAVAGE99",TexMan.Type_Any);
			let reticle = texman.CheckForTexture("bossret1",TexMan.Type_Any);

			vector2 frontoffs=(0,0)+bob*3;

			double camSize  = texman.GetSize(cam);
			sb.DrawCircle(cam, frontoffs, 0.125,usePixelRatio:true);

			//[2022-09-17] there's a glitch in GZDoom where if the reticle would be drawn completely off screen,
			//the cliprect is ignored. The figure is a product of trial and error.
			if((bob.y/fov)<0.4){
				let reticleScale = camSize / texman.GetSize(reticle);
			//	if(hdw.weaponstatus[0]&BOSSF_FRONTRETICLE){
			//		sb.DrawCircle(reticle, frontoffs, .5*reticleScale, bob*deg*5-bob, 1.6*deg);
			//	}else{
					sb.DrawCircle(reticle, (0,0)+bob, .5*reticleScale,uvScale:.5);
			//	}
			}

			//let holeScale    = camSize / texman.GetSize(hole);
			//let hole    = texman.CheckForTexture("scophole",TexMan.Type_Any);
			//sb.DrawCircle(hole, (0, scaledyoffset) + bob, .5 * holeScale, bob * 5, 1.5);


			screen.SetClipRect(cx,cy,cw,ch);

			sb.drawimage(
				"s99scope",(0,0)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_CENTER,
				scale:(1.44,1.44)
			);
			sb.drawstring(
				sb.mAmountFont,string.format("%.1f",degree),
				(6+bob.x,105+bob.y),sb.DI_SCREEN_CENTER|sb.DI_TEXT_ALIGN_RIGHT,
				Font.CR_BLACK
			);
			sb.drawstring(
				sb.mAmountFont,string.format("%i",hdw.weaponstatus[BOSSS_DROPADJUST]),
				(6+bob.x,-50+bob.y),sb.DI_SCREEN_CENTER|sb.DI_TEXT_ALIGN_RIGHT,
				Font.CR_BLACK
			);
		}
		// the scope display is in 10ths of an arcminute.
		// one dot = 6 arcminutes.
	}
	override void consolidate(){
		weaponstatus[BOSSS_GRIME]=random(0,20);
	}
	override void DropOneAmmo(int amt){
		if(owner){
			amt=clamp(amt,1,6);
			
			if(owner.countinv("Savage300Ammo"))owner.A_DropInventory("Savage300Ammo",6);
		}
	}
	override void ForceBasicAmmo(){
		owner.A_SetInventory("Savage300Ammo",7);
		owner.A_TakeInventory("SevenMilBrass");
	}

	int handrounds;
	override void DetachFromOwner(){
		if(handrounds>0){
			actor dropper=self;
			if(owner)dropper=owner;

			int bullets=handrounds;

			if(bullets>0)
			dropper.A_DropItem("Savage300Ammo",bullets);
		}
		super.DetachFromOwner();
	}

	states{
	select0:
		SAVG A 0;
		goto select0big;
	deselect0:
		SAVG A 0;
		goto deselect0big;

	ready:
		SAVG A 1{
			if(pressingzoom()){
				if(player.cmd.buttons&BT_USE){
					A_ZoomAdjust(BOSSS_DROPADJUST,0,1600,BT_USE);
				}else if(invoker.weaponstatus[0]&BOSSF_FRONTRETICLE)A_ZoomAdjust(BOSSS_ZOOM,12,40);
				else A_ZoomAdjust(BOSSS_ZOOM,5,60);
				A_WeaponReady(WRF_NONE);
			}else A_WeaponReady(WRF_ALL);
		}goto readyend;
	user3:
		#### A 0 A_MagManager("");
		goto ready;
	fire:
		SAVG A 1 A_JumpIf(invoker.weaponstatus[BOSSS_CHAMBER]==2,"shoot");
		goto ready;
	shoot:
		#### A 1{
			A_Gunflash();
			invoker.weaponstatus[BOSSS_CHAMBER]=1;
			A_StartSound("weapons/bigrifle2",CHAN_WEAPON,CHANF_OVERLAP
			);
			A_AlertMonsters();

			HDBulletActor.FireBullet(self,"HDB_300Savage",
				aimoffy:(-HDCONST_GRAVITY/1000.)*invoker.weaponstatus[BOSSS_DROPADJUST],
				speedfactor:frandom(0.97,1.03)
			);
			A_MuzzleClimb(
				0,0,
				-frandom(0.2,0.4),-frandom(0.6,1.),
				-frandom(0.4,0.7),-frandom(1.2,2.1),
				-frandom(0.4,0.7),-frandom(1.2,2.1)
			);
		}
		#### A 1;
		#### A 1 A_JumpIf(gunbraced(),"ready");
		goto ready;
	flash:
		SVGF A 1 bright{
			A_Light1();
			HDFlashAlpha(-96);
			A_ZoomRecoil(0.93);
			A_ChamberGrit(randompick(0,0,0,0,0,1,1,1,1,-1));
		}
		TNT1 A 0 A_Light0();
		stop;
	altfire:
		SAVG AB 2 A_WeaponBusy();
		#### B 1 A_JumpIf(invoker.weaponstatus[BOSSS_CHAMBER]>2,"jamderp");
		#### B 1 A_MuzzleClimb(-frandom(0.06,0.1),-frandom(0.3,0.5));
		#### B 0 A_ChamberGrit(randompick(0,0,0,0,-1,1,2),true);
		#### B 0 A_Refire("chamber");
		goto ready;
		
	chamber:
		#### C 2{
			if(
				random(0,max(2,invoker.weaponstatus[BOSSS_GRIME]>>3))
				&&invoker.weaponstatus[BOSSS_CHAMBER]>2
			){
				invoker.weaponstatus[BOSSS_CHAMBER]+=2;
				A_MuzzleClimb(
					-frandom(0.6,2.3),-frandom(0.6,2.3),
					-frandom(0.6,1.3),-frandom(0.6,1.3),
					-frandom(0.6,1.3),-frandom(0.6,1.3)
				);
				setweaponstate("jamderp");
			}else A_StartSound("weapons/savage_cock",8);
		}
		#### C 1 offset(2,36){
			if(gunbraced())A_MuzzleClimb(
				frandom(-0.1,0.3),frandom(-0.1,0.3)
			);else A_MuzzleClimb(
				frandom(-0.2,0.8),frandom(-0.4,0.8)
			);
			int jamch=invoker.jamchance();
			if(hd_debug)A_Log("jam chance: "..jamch);
			if(random(0,200)<jamch)setweaponstate("jam");
		}//50% less jammy than the Boss
		#### D 2 offset(1,34){
			//eject
			int chm=invoker.weaponstatus[BOSSS_CHAMBER];
			class<actor> rndtp=chm==1?"SpentSavage300":"LooseSavage300";
			double cp=cos(pitch);
			double sp=sin(pitch);
			actor rrr=null;
			if(chm>=1){
				vector3 gunofs=HDMath.RotateVec3D((10,-1,0),angle,pitch);
				actor rrr=spawn(rndtp,(pos.xy,pos.z+height*0.85)+gunofs+viewpos.offset);
				rrr.target=self;
				rrr.angle=angle;
				rrr.vel=HDMath.RotateVec3D((-1,-4,1),angle,pitch);
				if(chm==1)rrr.vel*=1.3;
				rrr.vel+=vel;
			}

			//cycle new
			int bbm=invoker.weaponstatus[BOSSS_MAG];
			if(bbm>0){
				invoker.weaponstatus[BOSSS_CHAMBER]=2;
				invoker.weaponstatus[BOSSS_MAG]--;
			}else invoker.weaponstatus[BOSSS_CHAMBER]=0;
		}
		#### E 1 A_WeaponReady(WRF_NOFIRE);
		#### E 0 A_Refire("althold");
		goto altholdend;
		
	althold:
		#### E 1 A_WeaponReady(WRF_NOFIRE);
		#### E 1{
			A_ClearRefire();
			bool chempty=invoker.weaponstatus[BOSSS_CHAMBER]==0;
			bool magempty=invoker.weaponstatus[BOSSS_MAG]<1;
		
		
			if(pressingunload()){
				if(chempty&&magempty){//clean the rifle when empty
					return resolvestate("altholdclean");
				}else if(!chempty)//unload chambered round
				{
					invoker.weaponstatus[0]|=BOSSF_UNLOADONLY;
					return resolvestate("unloadchamber");
				}
				else//unload magazine
				{
				return resolvestate("lever_unload");
				}
			}else if(pressingreload()){
			
				if(
					chempty //chamber a round first if empty
				){
					invoker.weaponstatus[0]|=~BOSSF_UNLOADONLY;
					return resolvestate("altloadchamber");
				}else 
			
				if(
					countinv("Savage300Ammo")
    		){//load magazine if round chambered
				return resolvestate("lever_reload");
				}
			}
			if(pressingaltfire())return resolvestate("althold");
			return resolvestate("altholdend");
		}
	altholdend:
		#### E 0 A_StartSound("weapons/savage_uncock",8);
		#### DCB 2 A_WeaponReady(WRF_NOFIRE);
		goto ready;
	unloadchamber:
		#### E 1 offset(2,36);// A_ClearRefire();
		#### D 1 offset(3,38);
		#### D 1 offset(5,42);
		#### C 1 offset(8,48) A_StartSound("weapons/pocket",9);
		#### C 1 offset(9,52) A_MuzzleClimb(frandom(-0.2,0.2),0.2,frandom(-0.2,0.2),0.2,frandom(-0.2,0.2),0.2);
		#### B 2 offset(8,60);
		#### B 2 offset(7,72);
		TNT1 A 18 A_StartSound("weapons/pocket",9);
		TNT1 A 4{
			A_StartSound("weapons/bossload",8,volume:0.7);
			if(invoker.weaponstatus[0]&BOSSF_UNLOADONLY){
				int chm=invoker.weaponstatus[BOSSS_CHAMBER];
				invoker.weaponstatus[BOSSS_CHAMBER]=0;
				if(
					chm<2
					||A_JumpIfInventory("Savage300Ammo",0,"null")
				){
					class<actor> whatkind=chm==2?
						"Savage300Ammo":"SpentSavage300"
					;
					actor rrr=spawn(whatkind,pos+(cos(angle)*10,sin(angle)*10,height-12),ALLOW_REPLACE);
					rrr.angle=angle;rrr.A_ChangeVelocity(1,2,1,CVF_RELATIVE);
				}else HDF.Give(self,"Savage300Ammo",1);
				A_ChamberGrit(randompick(0,0,0,0,-1,1),true);
			}else{
				class<inventory> rndtp="Savage300Ammo";
				A_TakeInventory(rndtp,1,TIF_NOTAKEINFINITE);
				invoker.weaponstatus[BOSSS_CHAMBER]=2;
			}
		} 
		SAVG B 2 offset(7,72);
		#### B 2 offset(8,60);
		#### C 1 offset(6,52);
		#### C 1 offset(5,42);
		#### D 1 offset(4,38);
		#### D 1 offset(3,35);
		goto althold;
		
	altloadchamber://doing it this way because logic makes my brain hurt
		#### E 1 offset(2,36);
		#### D 1 offset(3,38);
		#### D 1 offset(5,42);
		#### C 1 offset(8,48) A_StartSound("weapons/pocket",9);
		#### C 1 offset(9,52) A_MuzzleClimb(frandom(-0.2,0.2),0.2,frandom(-0.2,0.2),0.2,frandom(-0.2,0.2),0.2);
		#### B 2 offset(8,60);
		#### B 2 offset(7,72);
		TNT1 A 18 A_StartSound("weapons/pocket",9);
		TNT1 A 4{
				if(countinv("Savage300Ammo")>0){
		    	    A_StartSound("weapons/bossload",8,volume:0.7);
				    class<inventory> rndtp="Savage300Ammo";
				    A_TakeInventory(rndtp,1,TIF_NOTAKEINFINITE);
    				invoker.weaponstatus[BOSSS_CHAMBER]=2;
	            }
		}
		SAVG B 2 offset(7,72);
		#### B 2 offset(8,60);
		#### C 1 offset(6,52);
		#### C 1 offset(5,42);
		#### D 1 offset(4,38);
		#### D 1 offset(3,35);
		goto althold;	
	
	altholdclean:
		#### E 1 offset(2,36) A_ClearRefire();
		#### D 2 offset(3,38);
		#### C 2 offset(5,41) A_Log("Looking inside that chamber...",true);
		#### B 2 offset(8,44) A_StartSound("weapons/pocket",9);
		#### B 2 offset(7,50) A_MuzzleClimb(frandom(-0.2,0.2),0.2,frandom(-0.2,0.2),0.2,frandom(-0.2,0.2),0.2);
		TNT1 A 3 A_StartSound("weapons/pocket",10);
		TNT1 AAAA 4 A_MuzzleClimb(frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2));
		TNT1 A 3 A_StartSound("weapons/pocket",9);
		TNT1 AAAA 4 A_MuzzleClimb(frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2));
		TNT1 A 40{
			A_StartSound("weapons/pocket",9);
			int amt=invoker.weaponstatus[BOSSS_GRIME];
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
			amt=invoker.weaponstatus[BOSSS_GRIME];
			if(amt>40)amts.appendformat("You barely scrape the surface of this all-encrusting abomination.");
			else if(amt>30)amts.appendformat("The gun will need a lot more work than this before it can be deployed again.");
			else if(amt>20)amts.appendformat("You might get a few shots out of it now.");
			else if(amt>10)amts.appendformat("It's better, but still not good.");
			else amts.appendformat("Good to go.");
			A_Log(amts,true);
		}
		SAVG B 2 offset(7,52);
		#### B 2 offset(8,48);
		#### C 2 offset(5,42);
		#### D 2 offset(3,38);
		#### E 2 offset(2,36);
		goto althold;
	jam:
		#### B 0{
			int chm=invoker.weaponstatus[BOSSS_CHAMBER];
			if(chm<1)setweaponstate("chamber");
			else if(chm<3)invoker.weaponstatus[BOSSS_CHAMBER]+=2;
		}
	jamderp:
		#### B 0 A_StartSound("weapons/rifleclick",8,CHANF_OVERLAP);
		#### B 2 offset(4,38);
		#### C 2 offset(2,36);
		#### D 2 offset(4,38)A_MuzzleClimb(frandom(-0.5,0.6),frandom(-0.3,0.6));
		#### D 3 offset(2,36){
			A_MuzzleClimb(frandom(-0.5,0.6),frandom(-0.3,0.6));
			if(random(0,invoker.jamchance())<15){
				setweaponstate("chamber");
				if(invoker.weaponstatus[BOSSS_CHAMBER]>2)  
					invoker.weaponstatus[BOSSS_CHAMBER]-=2;
			}
		}
		#### C 2 offset(4,38);
		#### B 3 offset(2,36);
		#### B 0 A_Refire("jamderp");
		goto ready;

	reload:
	altreload:
	 goto nope;
	lever_reload:
		#### E 0{invoker.weaponstatus[0]|=BOSSF_DONTUSECLIPS;}
		goto reloadstart;
	reloadstart:
		#### E 1 offset(0,34);
		#### D 1 offset(2,36);
		#### D 1 offset(4,40);
		#### C 2 offset(8,42){
			A_StartSound("weapons/rifleclick2",8,CHANF_OVERLAP,0.9,pitch:0.95);
			A_MuzzleClimb(-frandom(0.4,0.8),frandom(0.4,1.4));
		}
		#### B 4 offset(14,46){
			A_StartSound("weapons/bossloadm",8,CHANF_OVERLAP);
			A_MuzzleClimb(-frandom(0.4,0.8),frandom(0.4,1.4));
		}
		#### B 0{
			int mg=invoker.weaponstatus[BOSSS_MAG];
			if(mg==6)setweaponstate("reloaddone");
		}
	loadhand:
		#### B 0 A_JumpIfInventory("Savage300Ammo",1,"loadhandloop");
		goto reloaddone;
	loadhandloop:
		#### B 4{
			class<inventory> rndtp="Savage300Ammo";
	
			int hnd=min(
				countinv(rndtp),1,
				6-invoker.weaponstatus[BOSSS_MAG]
			);
			if(hnd<1){
				setweaponstate("reloaddone");
				return;
			}else{
				A_TakeInventory(rndtp,hnd,TIF_NOTAKEINFINITE);
				invoker.handrounds=hnd;
				A_StartSound("weapons/pocket",9);
			}
		}
	loadone:
		#### B 2 offset(16,50) A_JumpIf(invoker.handrounds<1,"loadhandnext");
		#### B 4 offset(14,46){
			invoker.handrounds--;
			invoker.weaponstatus[BOSSS_MAG]++;

			A_StartSound("weapons/rifleclick2",8);
		}loop;
	loadhandnext:
		#### B 8 offset(16,48){
			if(
				PressingReload()||
				PressingFire()||
				!PressingAltFire()||
				PressingZoom()||
				(
					!countinv("Savage300Ammo")	
				)
			)setweaponstate("reloaddone");
	//		else A_StartSound("weapons/pocket",9);
		}goto loadhandloop;

	reloaddone:
		#### B 1 offset(4,40);
		#### C 1 offset(2,36);
		#### D 1 offset(0,34);
		goto althold;
	unload:
	    goto nope;
	lever_unload:
		#### E 1 offset(0,34);
		#### D 1 offset(2,36);
		#### D 1 offset(4,40);
		#### C 2 offset(8,42){
			A_MuzzleClimb(-frandom(0.4,0.8),frandom(0.4,1.4));
			A_StartSound("weapons/rifleclick2",8);
		}
		#### B 4 offset (14,46){
			A_MuzzleClimb(-frandom(0.4,0.8),frandom(0.4,1.4));
			A_StartSound("weapons/bossloadm",8);
		}
	unloadloop:
		#### B 4 offset(3,41){
			if(invoker.weaponstatus[BOSSS_MAG]<1)setweaponstate("unloaddone");
			else{
				int bbm=invoker.weaponstatus[BOSSS_MAG];
				class<inventory> rndtp="Savage300Ammo";

				A_StartSound("weapons/rifleclick2",8);
				invoker.weaponstatus[BOSSS_MAG]--;
				if(A_JumpIfInventory(rndtp,0,"null")){
					A_SpawnItemEx(
						"LooseSavage300",cos(pitch)*8,0,height-7-sin(pitch)*8,
						cos(pitch)*cos(angle-40)*1+vel.x,
						cos(pitch)*sin(angle-40)*1+vel.y,
						-sin(pitch)*1+vel.z,
						0,SXF_ABSOLUTEMOMENTUM|
						SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
					);
				}else A_GiveInventory(rndtp,1);
			}
		}
		#### B 2 offset(2,42);
		#### B 0{
			if(
				PressingReload()||
				PressingFire()||
			!	PressingAltFire()||
				PressingZoom()
			)setweaponstate("unloaddone");
		}loop;
	unloaddone:
		#### B 2 offset(2,42);
		#### C 2 offset(3,41);
		#### D 1 offset(4,40) A_StartSound("weapons/rifleclick",8);
		#### D 1 offset(2,36);
		#### E 1 offset(0,34);
		goto althold;
		

	spawn:
		SV39 A -1;
		stop;
	}
	override void InitializeWepStats(bool idfa){
		weaponstatus[BOSSS_CHAMBER]=2;
		weaponstatus[BOSSS_MAG]=6;
		if(!idfa){
			weaponstatus[BOSSS_HEAT]=0;
		}
		if(!owner){
			if(randompick(0,0,1))weaponstatus[0]&=~BOSSF_FRONTRETICLE;
				else weaponstatus[0]|=BOSSF_FRONTRETICLE;
			weaponstatus[BOSSS_ZOOM]=20;
			weaponstatus[BOSSS_DROPADJUST]=127;
		}
	}
	override void loadoutconfigure(string input){
		int frontreticle=getloadoutvar(input,"frontreticle",1);
		if(!frontreticle)weaponstatus[0]&=~BOSSF_FRONTRETICLE;
		else if(frontreticle>0)weaponstatus[0]|=BOSSF_FRONTRETICLE;

		int bulletdrop=getloadoutvar(input,"bulletdrop",3);
		if(bulletdrop>=0)weaponstatus[BOSSS_DROPADJUST]=clamp(bulletdrop,0,1600);

		int zoom=getloadoutvar(input,"zoom",3);
		if(zoom>0)weaponstatus[BOSSS_ZOOM]=
			(weaponstatus[0]&BOSSF_FRONTRETICLE)?
			clamp(zoom,12,40):
			clamp(zoom,5,60);
	}
}
/*
enum bossstatus{
	BOSSF_FRONTRETICLE=1,
	BOSSF_CUSTOMCHAMBER=2,
	BOSSF_UNLOADONLY=4,
	BOSSF_DONTUSECLIPS=8,
	BOSSF_RECAST=16,

	BOSSS_CHAMBER=1, //0=nothing, 1=brass, 2=loaded, 3/4=jammed brass/round
	BOSSS_MAG=2,
	BOSSS_ZOOM=3,
	BOSSS_DROPADJUST=4,
	BOSSS_HEAT=5,
	BOSSS_GRIME=6,
	BOSSS_RECASTS=7,
}
*/