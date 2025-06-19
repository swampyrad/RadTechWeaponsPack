// ------------------------------------------------------------
// COP .357 Derringer
// ------------------------------------------------------------
const HDLD_COP357="cop";

class COP357Pistol:HDHandgun{
	bool chamberopen; //don't use weaponstatus since it shouldn't be saved anyway

	default{
		+hdweapon.fitsinbackpack
		+hdweapon.reverseguninertia
		scale 0.5;
		weapon.selectionorder 35;
		weapon.slotnumber 2;
		weapon.slotpriority 0.357;
		weapon.kickback 30;
		weapon.bobrangex 0.1;
		weapon.bobrangey 0.6;
		weapon.bobspeed 2.5;
		weapon.bobstyle "normal";
		obituary "$OB_COP357";
		tag "$TAG_COP357";
		inventory.pickupmessage "$PICKUP_COP357";
		hdweapon.refid HDLD_COP357;
		hdweapon.barrelsize 12,0.5,0.7; //shorter and thicker than the revolver
	
	    hdweapon.loadoutcodes "
			\cuquadshot - modifies pistol to shoot all 4 barrels at once";
	}
	
	override string PickupMessage() {
	    String msg = Super.PickupMessage();
		if(weaponstatus[COPS_QUADSHOT]) return Stringtable.Localize("$PICKUP_COP357OFF");
	    return msg;
	}
	
	override void loadoutconfigure(string input){
		int quad=getloadoutvar(input,"quadshot",1);
		  	 if(!quad)weaponstatus[COPS_QUADSHOT]=0;
		else if(quad>0)weaponstatus[COPS_QUADSHOT]=1;
	}
	
	override double gunmass(){
		double blk=0;
		for(int i=COPS_BRL1;i<=COPS_BRL4;i++){//only has 4 barrels
			int wi=weaponstatus[i];
			if(wi==COPS_MASTERBALL)blk+=0.12;
			else if(wi==COPS_NINEMIL)blk+=0.1;
		}
		return blk+4;
	}
	override double weaponbulk(){
		double blk=0;
		for(int i=COPS_BRL1;i<=COPS_BRL4;i++){//only track the first 4 chambers
			int wi=weaponstatus[i];
			if(wi==COPS_MASTERBALL)blk+=ENC_355_LOADED;
			else if(wi==COPS_NINEMIL)blk+=ENC_9_LOADED;
		}
		return blk+25;//smaller than a revolver
	}
	override string,double getpickupsprite(bool usespare){
		return "COPPA0",1.;
	}

	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
			sb.drawimage("PRNDA0",(-47,-10),sb.DI_SCREEN_CENTER_BOTTOM,scale:(2.1,2.55));
			sb.drawnum(hpl.countinv("HDRevolverAmmo"),-44,-8,sb.DI_SCREEN_CENTER_BOTTOM);
			int ninemil=hpl.countinv("HDPistolAmmo");
			if(ninemil>0){
				sb.drawimage("PRNDA0",(-64,-10),sb.DI_SCREEN_CENTER_BOTTOM,scale:(2.1,2.1));
				sb.drawnum(ninemil,-60,-8,sb.DI_SCREEN_CENTER_BOTTOM);
			}
		}
		int plf=hpl.player.getpsprite(PSP_WEAPON).frame;
		
		int index=hdw.weaponstatus[COPS_INDEX];
		//index indicator, adds red outline
		sb.fill(
				color(255,255,0,0),
				index==1||index==4?-27:-18,
			    index<3?-25:-16,
				4,4,
				sb.DI_SCREEN_CENTER_BOTTOM|sb.DI_ITEM_RIGHT
			);
		
		//chamber/round indicators
		
		sb.fill(//upper left chamber
				hdw.weaponstatus[COPS_BRL1]>0?
				color(255,240,230,40)
				:color(200,30,26,24),
				-26, -24,
				3,3,
				sb.DI_SCREEN_CENTER_BOTTOM|sb.DI_ITEM_RIGHT
			);
		sb.fill(//upper right chamber
				hdw.weaponstatus[COPS_BRL2]>0?
				color(255,240,230,40)
				:color(200,30,26,24),
				-18, -24,
				3,3,
				sb.DI_SCREEN_CENTER_BOTTOM|sb.DI_ITEM_RIGHT
			);
		sb.fill(//bottom right chamber
				hdw.weaponstatus[COPS_BRL3]>0?
				color(255,240,230,40)
				:color(200,30,26,24),
				-18, -16,
				3,3,
				sb.DI_SCREEN_CENTER_BOTTOM|sb.DI_ITEM_RIGHT
			);
		sb.fill(//bottom left chamber
				hdw.weaponstatus[COPS_BRL4]>0?
				color(255,240,230,40)
				:color(200,30,26,24),
				-26, -16,
				3,3,
				sb.DI_SCREEN_CENTER_BOTTOM|sb.DI_ITEM_RIGHT
			);
	
	}
	override string gethelptext(){
		LocalizeHelp();
		if(chamberopen)return
		LWPHELP_FIRE..Stringtable.Localize("$C357_HELPTEXT_1")
		..LWPHELP_UNLOAD..Stringtable.Localize("$C357_HELPTEXT_2")
		..LWPHELP_RELOAD..Stringtable.Localize("$C357_HELPTEXT_3")..LWPHELP_FIREMODE..Stringtable.Localize("$C357_HELPTEXT_4")
		;
		return
		LWPHELP_FIRESHOOT
		..LWPHELP_ALTRELOAD.."/"..LWPHELP_FIREMODE..Stringtable.Localize("$C357_HELPTEXT_5")
		..LWPHELP_UNLOAD.."/"..LWPHELP_RELOAD..Stringtable.Localize("$C357_HELPTEXT_6")
		;
	}
	override void DrawSightPicture(
		HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl,
		bool sightbob,vector2 bob,double fov,bool scopeview,actor hpc
	){
		if(COP357Pistol(hdw).chamberopen)return;

		int cx,cy,cw,ch;
		[cx,cy,cw,ch]=screen.GetClipRect();
		vector2 scc;
		vector2 bobb=bob*1.3;

		sb.SetClipRect(
			-8+bob.x,-9+bob.y,16,15,
			sb.DI_SCREEN_CENTER
		);
		scc=(0.9,0.9);

		sb.drawimage(
			"copfsite",(0,0)+bobb,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			alpha:0.9,scale:scc
		);
		sb.SetClipRect(cx,cy,cw,ch);
		sb.drawimage(
			"copbsite",(0,0)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			scale:scc
		);
	}
	override void DropOneAmmo(int amt){
		if(owner){
			amt=clamp(amt,12,40);//min is 3x round capacity, max is 10x
			if(owner.countinv("HDRevolverAmmo"))owner.A_DropInventory("HDRevolverAmmo",amt);
			else owner.A_DropInventory("HDPistolAmmo",amt);
		}
	}
	override void ForceBasicAmmo(){
		owner.A_SetInventory("HDRevolverAmmo",1);
	}
	override void initializewepstats(bool idfa){
	// load all barrels with .355
		weaponstatus[COPS_BRL1]=COPS_MASTERBALL;
		weaponstatus[COPS_BRL2]=COPS_MASTERBALL;
		weaponstatus[COPS_BRL3]=COPS_MASTERBALL;
		weaponstatus[COPS_BRL4]=COPS_MASTERBALL;
		
		//set index to fire upper left barrel first
		weaponstatus[COPS_INDEX]=4;
		}

    //if playing FreeDoom, player is right-handed
    //if playing Doom, player is left-handed
	action bool HoldingRightHanded(){
		bool righthanded=invoker.wronghand;
		righthanded=
		(
			righthanded
			&&Wads.CheckNumForName("id",0)!=-1
		)||(
			!righthanded
			&&Wads.CheckNumForName("id",0)==-1
		);
		return righthanded;
	}
	
	action void A_CheckCOP357Hand(){
	    //check if playing FreeDoom
		bool righthanded=HoldingRightHanded();
		
		//use wronghand sprites if FreeDoom
		if(righthanded)player.getpsprite(PSP_WEAPON).sprite=getspriteindex("COPVA0");
		
		//use default sprites if Doom
		else player.getpsprite(PSP_WEAPON).sprite=getspriteindex("COPDA0");
	}

	action void A_LoadRound(){
	    //cancel if no empty barrels
		if(invoker.weaponstatus[COPS_BRL1]>0
		    &&invoker.weaponstatus[COPS_BRL2]>0
		    &&invoker.weaponstatus[COPS_BRL3]>0
		    &&invoker.weaponstatus[COPS_BRL4]>0
		)return;

		//force 9mm reload if holding FureMode
		bool useninemil=(//load 9mm if holding FireMode
			player.cmd.buttons&BT_FIREMODE
			||!countinv("HDRevolverAmmo")
		);
		
		//close gun if no 9mm left
		if(useninemil&&!countinv("HDPistolAmmo"))return;
		
		class<inventory>ammotype=useninemil?"HDPistolAmmo":"HDRevolverAmmo";
		A_TakeInventory(ammotype,1,TIF_NOTAKEINFINITE);
		
		//load the first empty barrel available,
		//starting from the upper left, going
		//clockwise until they're all full
		
		//first barrel
	     if(invoker.weaponstatus[COPS_BRL1]<1)	
		    invoker.weaponstatus[COPS_BRL1]=useninemil?COPS_NINEMIL:COPS_MASTERBALL;
        
        //second barrel
    else if(invoker.weaponstatus[COPS_BRL2]<1)	
	    	invoker.weaponstatus[COPS_BRL2]=useninemil?COPS_NINEMIL:COPS_MASTERBALL;
    
        //third barrel
    else if(invoker.weaponstatus[COPS_BRL3]<1)	
	   		invoker.weaponstatus[COPS_BRL3]=useninemil?COPS_NINEMIL:COPS_MASTERBALL;
    
        //fourth barrel
    else if(invoker.weaponstatus[COPS_BRL4]<1)	
	   		invoker.weaponstatus[COPS_BRL4]=useninemil?COPS_NINEMIL:COPS_MASTERBALL;
	   		
	   	//play reload sfx
		A_StartSound("weapons/deinoload",8,CHANF_OVERLAP);
	}
	
	action void A_OpenChamber(){
		A_StartSound("weapons/deinoopen",8);
		invoker.chamberopen=true;
		A_SetHelpText();
	}
	action void A_CloseChamber(){
		A_StartSound("weapons/deinoclose",8);
		invoker.chamberopen=false;
		A_SetHelpText();
	}
	
	action void A_RemoveSpentRound(){
	
		double cosp=cos(pitch);
		for(int i=COPS_BRL1;i<=COPS_BRL4;i++){
			int thischamber=invoker.weaponstatus[i];
			if(thischamber<1)continue;
			
			if(
				thischamber==COPS_NINEMILSPENT
				||thischamber==COPS_NINEMIL
				||thischamber==COPS_MASTERBALLSPENT
			){
				actor aaa=spawn(
					thischamber==COPS_NINEMIL?"HDLoose9mm"
						:thischamber==COPS_MASTERBALLSPENT?"HDSpent355"
						:"HDSpent9mm",
					(pos.xy,pos.z+height-10)
					+(cosp*cos(angle),cosp*sin(angle),sin(pitch))*7,
					ALLOW_REPLACE
				);
				aaa.vel=vel+(frandom(-1,1),frandom(-1,1),-1);
				aaa.angle=angle;
				invoker.weaponstatus[i]=0;
			}
		}
		A_StartSound("weapons/deinoeject",8,CHANF_OVERLAP);
	}
	action void A_ExtractAll(){
		double cosp=cos(pitch);
		bool gotany=false;
		for(int i=COPS_BRL1;i<=COPS_BRL4;i++){
			int thischamber=invoker.weaponstatus[i];
			if(thischamber<1)continue;
			if(
				thischamber==COPS_NINEMILSPENT
				||thischamber==COPS_MASTERBALLSPENT
			){
				actor aaa=spawn("HDSpent9mm",
					(pos.xy,pos.z+height-14)
					+(cosp*cos(angle),cosp*sin(angle),sin(pitch)-2)*3,
					ALLOW_REPLACE
				);
				aaa.vel=vel+(frandom(-0.3,0.3),frandom(-0.3,0.3),-1);
				if(thischamber==COPS_MASTERBALLSPENT)aaa.scale.y=0.85;
				invoker.weaponstatus[i]=0;
			}else{
				//give or spawn either 9mm or .355
				class<inventory>ammotype=
					thischamber==COPS_MASTERBALL?
					"HDRevolverAmmo":"HDPistolAmmo";
				if(A_JumpIfInventory(ammotype,0,"null")){
					actor aaa=spawn(ammotype,
						(pos.xy,pos.z+height-14)
						+(cosp*cos(angle),cosp*sin(angle),sin(pitch)-2)*3,
						ALLOW_REPLACE
					);
					aaa.vel=vel+(frandom(-1,1),frandom(-1,1),-1);
				}else{
					A_GiveInventory(ammotype,1);
					gotany=true;
				}
				invoker.weaponstatus[i]=0;
			}
		}
		if(gotany)A_StartSound("weapons/pocket",9);
	}
	
	action void A_FireCOP357(){
		//current chamber index
		int index=invoker.weaponstatus[COPS_INDEX];
		
		index++;//advance to next barrel on trigger-pull
		
		//if last barrel, reset to 1
		if(index<5)invoker.weaponstatus[COPS_INDEX]=index;
		else{invoker.weaponstatus[COPS_INDEX]=1;
		     index=1;}
		
		//check barrel after advancing index
		int barrel=invoker.weaponstatus[index];
		
		if(
			barrel!=COPS_MASTERBALL
			&&barrel!=COPS_NINEMIL
		){
		
		//just click if barrel empty or spent
			A_StartSound("weapons/deinoclick",8,CHANF_OVERLAP);
			return;
		}
		
		//barrel is spent
		if(barrel==2||barrel==4)invoker.weaponstatus[index]--;
		
		//check if .355 or 9mm
		bool masterball=barrel==COPS_MASTERBALL;
		
		//apply offsets based on which barrel is fired
		let bbb=HDBulletActor.FireBullet(self,
		                                 masterball?"HDB_355":"HDB_9",
		                                 spread:1.,
		                                 aimoffx:index==1||index==4?0.7:-0.7,
		                                 aimoffy:index>2?0.7:0,
		                                 speedfactor:frandom(0.99,1.01)
		                                 );
		
		if(
			frandom(0,ceilingz-floorz)<bbb.speed*(masterball?0.4:0.3)
		)A_AlertMonsters(masterball?512:256);
    
		//flinching code borrowed from Brontornis
		IsMoving.Give(self,gunbraced()?2:7);
					if(
					  !binvulnerable
					  &&!random(0,1)
					  &&(
						floorz<pos.z
						||IsMoving.Count(self)>6
					  )
					){
						givebody(max(0,5-health));
						damagemobj(invoker,self,5,"bashing",DMG_NO_ARMOR);
						IsMoving.Give(self,3);
					}

        //trigger muzzle flash
		A_GunFlash();
		A_Light1();
		A_ZoomRecoil(0.995);
		HDFlashAlpha(masterball?72:64);
		
		//play firing sfx
		A_StartSound("weapons/deinoblast1",CHAN_WEAPON,CHANF_OVERLAP);
		
		//unbrace gun after firing
		if(hdplayerpawn(self)){
			hdplayerpawn(self).gunbraced=false;
		}
		
		//play firing sfx again if .355
		if(masterball){
			A_MuzzleClimb(-frandom(0.8,1.6),-frandom(1.6,2.));
			A_StartSound("weapons/deinoblast1",CHAN_WEAPON,CHANF_OVERLAP,0.5);
			A_StartSound("weapons/deinoblast2",CHAN_WEAPON,CHANF_OVERLAP,0.4);
		}else{
			A_MuzzleClimb(-frandom(0.6,1.2),-frandom(0.8,1.8));
			A_StartSound("weapons/deinoblast2",CHAN_WEAPON,CHANF_OVERLAP,0.3);
		}
	}
	int cooldown;
	
	//hold chamber open, controls reload/unload mechanics
	action void A_ReadyOpen(){
		A_WeaponReady(WRF_NOFIRE|WRF_ALLOWUSER3);
		if(justpressed(BT_RELOAD)){
			if(
				(
					  invoker.weaponstatus[COPS_BRL1]>0
					&&invoker.weaponstatus[COPS_BRL2]>0
					&&invoker.weaponstatus[COPS_BRL3]>0
					&&invoker.weaponstatus[COPS_BRL4]>0
				)||(
					  !countinv("HDPistolAmmo")
					&&!countinv("HDRevolverAmmo")
				)
			)setweaponstate("open_closechamber");//close if all barrels filled or no ammo left
		else setweaponstate("open_loadround");
		}else if(justpressed(BT_ATTACK))
		        setweaponstate("open_closechamber");//close if pressed Fire
		else if(justpressed(BT_UNLOAD)){
			   if(!invoker.cooldown){
				  setweaponstate("open_dumpchamber");//remove spent rounds only
				  invoker.cooldown=6;
			    }else setweaponstate("open_dumpchamber_all");//remove live rounds
		}
		if(invoker.cooldown>0)invoker.cooldown--;//lower cooldown timer for full unload
	}
	
	//sets what frames used to display chambered round overlays
	action void A_RoundReady(int rndnm){
		int gunframe=-1;
		if(invoker.weaponstatus[rndnm]>0)gunframe=player.getpsprite(PSP_WEAPON).frame;
		let thissprite=player.getpsprite(COPS_OVRCYL+rndnm);
		switch(gunframe){
		case 3: //D, half-open
			thissprite.frame=1;//use B frame
			break;
		case 4: //E, fully open
			thissprite.frame=0;//use A frame
			break;
		default:
			thissprite.sprite=getspriteindex("TNT1A0");
			thissprite.frame=0;
			return;break;
		}
	}
	
	states{
	spawn:
		COPP A -1;
		stop;
		
	//chambered round overlays
	round1:CPD1 A 1 A_RoundReady(COPS_BRL1);wait;
	round2:CPD2 A 1 A_RoundReady(COPS_BRL2);wait;
	round3:CPD3 A 1 A_RoundReady(COPS_BRL3);wait;
	round4:CPD4 A 1 A_RoundReady(COPS_BRL4);wait;
	
	select0:
		COPD A 0{
		    //reset hand on weapon select
			if(!countinv("NulledWeapon"))invoker.wronghand=false;
			
			A_TakeInventory("NulledWeapon");
			A_CheckCOP357Hand();
			invoker.chamberopen=false;

            //activate overlays
			A_Overlay(COPS_OVRCYL+COPS_BRL1,"round1");
			A_Overlay(COPS_OVRCYL+COPS_BRL2,"round2");
			A_Overlay(COPS_OVRCYL+COPS_BRL3,"round3");
			A_Overlay(COPS_OVRCYL+COPS_BRL4,"round4");
		}
		---- A 1 A_Raise();
		---- A 1 A_Raise(40);
		---- A 1 A_Raise(40);
		---- A 1 A_Raise(25);
		---- A 1 A_Raise(20);
		wait;
	deselect0:
		COPD A 0 A_CheckCOP357Hand();
		#### # 0 A_JumpIf(!invoker.chamberopen,"deselect0a");//skip if already closed
		#### E 1 A_CloseChamber();//close chamber before switching weapons
		#### D 1;
		COPD A 0 A_CheckCOP357Hand();
		goto deselect0a;
	deselect0a:
		#### A 1 A_Lower();
		---- C 1 A_Lower(20);
		---- C 1 A_Lower(34);
		---- C 1 A_Lower(50);
		wait;
	ready:
		#### A 0 A_CheckCOP357Hand();
		---- A 0 A_JumpIf(invoker.chamberopen,"readyopen");
		---- A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWUSER1|WRF_ALLOWUSER2|WRF_ALLOWUSER3|WRF_ALLOWUSER4);
		goto readyend;
	fire:
		#### A 2 offset(0,34);//heavy trigger pull
		#### A 2 offset(0,35);
		#### A 2 offset(0,36);
		#### A 1 offset(0,34);
		#### A 1 offset(0,32);
		#### A 0 A_ClearRefire();
		#### A 0 A_JumpIf(invoker.weaponstatus[COPS_QUADSHOT], "quadshot");
	
	singleshot://cycle striker once
		#### A 1 A_FireCOP357();
		goto nope;
		
	quadshot://say goodbye to your wrists :P
		#### AAAA 0 A_FireCOP357();
		#### A 1;
		goto nope;
	
	//ow, my carpal tunnel!
	firerecoil:
		#### BC 2;
		#### A 0;
		goto nope;
		
	flash:
		COPF A 1 bright;
		---- A 0 A_Light0();
		---- A 0 setweaponstate("firerecoil");
		stop;
	    COPV ABCD 0;
		stop;

	//closed hammer, altfire does nothing		
	altfire:
	    goto nope;

	reload:
	unload:
		#### A 3 A_OpenChamber();
		#### D 3 A_ReadyOpen();
		goto readyopen;
	
	readyopen:
		#### E 1 A_ReadyOpen();
		goto readyend;
		
	open_loadround:
		#### E 2;
		#### E 4 A_LoadRound();
		goto readyopen;
		
	open_closechamber:
		#### ED 3;
		#### A 0{
			A_CloseChamber();
			A_CheckCOP357Hand();
		}goto nope;
		
	open_dumpchamber:
		#### E 2 A_RemoveSpentRound();
		goto readyopen;
		
	open_dumpchamber_all:
		#### E 1 offset(0,34);
		#### E 1 offset(0,42);
		#### E 1 offset(0,54);
		#### E 1 offset(0,68);
		TNT1 A 15 A_StartSound("weapons/pocket",8);
		TNT1 A 10 A_ExtractAll();
		COPD E 0 A_CheckCOP357Hand();
		#### E 1 offset(0,68);
		#### E 1 offset(0,54);
		#### E 1 offset(0,42);
		#### E 1 offset(0,34);
		goto readyopen;

	user1:
	user2:
	swappistols:
		---- A 0 A_SwapHandguns();
		#### D 0 A_JumpIf(player.getpsprite(PSP_WEAPON).sprite==getspriteindex("COPVA0"),"swappistols2");
	swappistols1:
		TNT1 A 0 A_Overlay(1025,"raiseright");
		TNT1 A 0 A_Overlay(1026,"lowerleft");
		TNT1 A 5;
		goto nope;
	swappistols2:
		TNT1 A 0 A_Overlay(1025,"raiseleft");
		TNT1 A 0 A_Overlay(1026,"lowerright");
		TNT1 A 5;
		goto nope;
	lowerleft:
		COPD A 0;
		---- A 1 offset(-6,38);
		---- A 1 offset(-12,48);
		COPD C 1 offset(-20,60);
		COPD C 1 offset(-34,76);
		COPD C 1 offset(-50,86);
		stop;
	lowerright:
		COPV A 0;
		---- A 1 offset(6,38);
		---- A 1 offset(12,48);
		COPV C 1 offset(20,60);
		COPV C 1 offset(34,76);
		COPV C 1 offset(50,86);
		stop;
	raiseleft:
		COPD C 1 offset(-50,86);
		COPD C 1 offset(-34,76);
		COPD A 0;
		---- A 1 offset(-20,60);
		---- A 1 offset(-12,48);
		---- A 1 offset(-6,38);
		stop;
	raiseright:
		COPV C 1 offset(50,86);
		COPV C 1 offset(34,76);
		COPV A 0;
		---- A 1 offset(20,60);
		---- A 1 offset(12,48);
		---- A 1 offset(6,38);
		stop;
	whyareyousmiling:
		#### C 1 offset(0,38);
		#### C 1 offset(0,48);
		#### C 1 offset(0,60);
		TNT1 A 7;
		COPD A 0{
			invoker.wronghand=!invoker.wronghand;
			A_CheckCOP357Hand();
		}
		#### C 1 offset(0,60);
		#### C 1 offset(0,48);
		#### C 1 offset(0,38);
		goto nope;
	}
}

enum COP357Stats{
	COPS_BRL1=1,
	COPS_BRL2=2,
	COPS_BRL3=3,
	COPS_BRL4=4,
	COPS_INDEX=5,       //track what chamber to fire next
	COPS_QUADSHOT=6,    //check whether modded for quadshot or standard
	COPS_OVRCYL=357,
	
	//odd means spent
	COPS_NINEMILSPENT=1,
	COPS_NINEMIL=2,
	COPS_MASTERBALLSPENT=3,
	COPS_MASTERBALL=4,
	
}

class COP357QuadPistol:HDWeaponGiver{
	default{
		//$Category "Weapons/Hideous Destructor"
		//$Title "COP .357 (quad-shot version)"
		//$Sprite "COPPA0"
		tag "COP .357";
		hdweapongiver.bulk 28;
		hdweapongiver.weapontogive "COP357Pistol";
		hdweapongiver.config "quadshot";
		hdweapongiver.weprefid HDLD_COP357;
		inventory.icon "COPPA0";
	}
}

class COP357Spawn:actor{
	override void postbeginplay(){
		super.postbeginplay();
		let box=spawn("HD355BoxPickup",pos,ALLOW_REPLACE);
		if(box)HDF.TransferSpecials(self,box);
		if(!random(0,9))spawn("COP357QuadPistol",pos,ALLOW_REPLACE);
		else spawn("COP357Pistol",pos,ALLOW_REPLACE);
		self.Destroy();
	}
}
