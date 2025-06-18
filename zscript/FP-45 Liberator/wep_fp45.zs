//------------------------------------------------------------
// Liberator .45 "Pistol"
// ------------------------------------------------------------

const HDLD_FP45 = "p45";

class HDFP45:HDHandgun{

	default{
		+hdweapon.fitsinbackpack
		+hdweapon.reverseguninertia
		scale 0.50;
		weapon.selectionorder 50;
		weapon.slotnumber 2;
		weapon.slotpriority 0.9;
		weapon.kickback 30;
		weapon.bobrangex 0.1;
		weapon.bobrangey 0.6;
		weapon.bobspeed 2.5;
		weapon.bobstyle "normal";
		obituary "$OB_FP45";
		tag "$TAG_FP45";
		hdweapon.refid HDLD_FP45;
		hdweapon.barrelsize 6,0.3,0.5;
	}
	
	override string pickupmessage(){return Stringtable.Localize("$PICKUP_FP45");}
    override bool AddSpareWeapon(actor newowner){return AddSpareWeaponRegular(newowner);}
	override hdweapon GetSpareWeapon(actor newowner,bool reverse,bool doselect){return GetSpareWeaponRegular(newowner,reverse,doselect);}

	override double weaponbulk(){
		return 20+(weaponstatus[FP45_CHAMBER]>1?HD45ACPAmmo.EncRoundLoaded:0)
	             +(weaponstatus[FP45_SPAREROUNDS]*HD45ACPAmmo.EncRoundLoaded);
	}//hardly weighs a thing, it's mostly stamped sheet metal
	override double gunmass(){
		return 6+(weaponstatus[FP45_SPAREROUNDS]*0.25);
	}//is a bit heavier if filled with extra rounds
	override string,double getpickupsprite(bool usespare){
		return "LIBPA0",1.;
	}

  override void postbeginplay(){
		super.postbeginplay();
        weaponspecial=1337;
	}
  
	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
	    if(sb.hudlevel==1){
			int coltrounds=hpl.countinv("HD45ACPAmmo");
			sb.drawimage("45RNA0",(-46,-10),sb.DI_SCREEN_CENTER_BOTTOM,alpha:coltrounds?1:0.6,scale:(2.1,2.1));
			sb.drawnum(coltrounds,-44,-8,sb.DI_SCREEN_CENTER_BOTTOM);
			}
	    
	    //chamber indicator
		if(hdw.weaponstatus[FP45_CHAMBER]>1)sb.drawrect(-23,-11,2,2);
		if(hdw.weaponstatus[FP45_CHAMBER]>0)sb.drawrect(-20,-11,3,2);
		
		//spare round counter
		for(int i=hdw.weaponstatus[FP45_SPAREROUNDS];i>0;i--){
			sb.drawrect(-16-i*4,-8,2,4);
			sb.drawrect(-16-i*4,-3,2,1);
		}
	}
	override string gethelptext(){
		return
		LWPHELP_ALTFIRE.."  Cock/Uncock hammer\n"
		..LWPHELP_ALTRELOAD.."  Quick-Swap (if available)\n\n"
		.."When hammer is uncocked...\n"
		.."  "..LWPHELP_RELOAD.."  Refill spare rounds\n"
		.."  "..LWPHELP_UNLOAD.."  Remove a spare round\n"
	    .."  "..LWPHELP_USE.." + "..LWPHELP_UNLOAD.."  Dump spare rounds\n\n"
		.."When hammer is cocked...\n"
		.."  "..LWPHELP_FIRESHOOT
		.."  "..LWPHELP_RELOAD.."  Reload chamber (spare rounds first)\n"
		.."  "..LWPHELP_UNLOAD.."  Unload chamber\n"
		.."While emptying chamber...\n"
		.."  "..LWPHELP_RELOAD.."(Hold)".."  Speed reload" 
		;
	}
	override void DrawSightPicture(
		HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl,
		bool sightbob,vector2 bob,double fov,bool scopeview,actor hpc
	){
		int cx,cy,cw,ch;
		[cx,cy,cw,ch]=screen.GetClipRect();
		vector2 scc;
		vector2 bobb=bob*1.3;
	
			sb.SetClipRect(
				-8+bob.x,-9+bob.y,16,15,
				sb.DI_SCREEN_CENTER
			);
			scc=(0.6,0.6);
		
		sb.drawimage(
			"fp45fsit",(0,0)+bobb,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			scale:scc
		);
		sb.SetClipRect(cx,cy,cw,ch);
		sb.drawimage(
			"fp45bsit",(0,0)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			alpha:0.9,
			scale:scc
		);
	}
	override void DropOneAmmo(int amt){
		if(owner){
			amt=clamp(amt,1,10);
			if(owner.countinv("HD45ACPAmmo"))owner.A_DropInventory("HD45ACPAmmo",amt*1);
		}
	}
	override void ForceBasicAmmo(){
		owner.A_TakeInventory("HD45ACPAmmo");
	}
	action void A_CheckPistolHand(){
		if(invoker.wronghand)player.getpsprite(PSP_WEAPON).sprite=getspriteindex("F245A0");
	}
	action void A_CockHammer(bool yes=true){
		if(yes)invoker.weaponstatus[0]|=FP45_COCKED;
		else invoker.weaponstatus[0]&=~FP45_COCKED;
	}
	states{
	select0:
		FP45 D 0{
			if(!countinv("NulledWeapon"))invoker.wronghand=false;
			A_TakeInventory("NulledWeapon");
			A_CheckPistolHand();
		}
		#### D 0 A_JumpIf(invoker.weaponstatus[0]&FP45_COCKED,2);
		#### A 0;
		---- # 1 A_Raise();
		---- # 1 A_Raise(30);
		---- # 1 A_Raise(30);
		---- # 1 A_Raise(24);
		---- # 1 A_Raise(18);
		wait;
	deselect0:
		FP45 D 0 A_CheckPistolHand();
		#### D 0 A_JumpIf(invoker.weaponstatus[0]&FP45_COCKED,2);
		#### A 0;
		---- # 3 A_Lower();
		---- # 1 A_Lower(18);
		---- # 1 A_Lower(24);
		---- # 1 A_Lower(30);
		wait;

	ready:
		FP45 # 0 A_CheckPistolHand();
		#### D 0 A_JumpIf(invoker.weaponstatus[0]&FP45_COCKED,2);
		#### A 0;
		#### # 0 A_SetCrosshair(21);
		#### # 1 A_WeaponReady(WRF_ALL);
		goto readyend;
	user3:
		---- # 0 A_MagManager("");
		goto ready;
	user2:
		goto nope;
		
	altfire:
		---- # 0 A_JumpIf(invoker.weaponstatus[0]&FP45_COCKED,"uncock");
	cocked:
		#### A 2 A_CockHammer();
		#### B 2 A_StartSound("weapons/smgmagclick");
		#### CD 2;
		#### D 0 A_JumpIf(pressingaltfire(),"nope");
		goto readyend;
	uncock:
		#### D 2;
		#### C 2 A_StartSound("weapons/smgmagclick");
		#### B 2 A_CockHammer(false);
		#### A 2;
		goto nope;

	althold:
	hold:
		goto nope;
	fire:
	    #### # 1 A_MuzzleClimb(-frandom(0.2,0.5),-frandom(0.4,0.9));
		---- # 0{
			    if(
			      invoker.weaponstatus[0]&FP45_COCKED
			     )setweaponstate("shoot");
		}goto nope;
	shoot:
        #### B 1 A_MuzzleClimb(-frandom(0.2,0.5),-frandom(0.4,0.9));//heavy trigger pull
        #### A 1 {if(invoker.weaponstatus[FP45_CHAMBER]==2)
                    A_GunFlash();
                  else A_StartSound("weapons/smgmagclick",8);
                  invoker.weaponstatus[0]&=~FP45_COCKED;
                  setweaponstate("nope");}
		#### A 1 offset(0,38){
			if(hdplayerpawn(self)){
				hdplayerpawn(self).gunbraced=false;
			}
			A_MuzzleClimb(
				-frandom(1.21,1.8),-frandom(1.5,2.3),
				-frandom(0.5,1.3),-frandom(.9,1.0),
				frandom(0.3,0.7), frandom(.7,.9)
			);
			A_WeaponReady(WRF_NOFIRE);
		}goto ready;
	flash:
		FP45 F 0;
		---- F 1 bright{
			HDFlashAlpha(64);
			A_Light1();
			let bbb=HDBulletActor.FireBullet(self,"HDB_45ACP",
			                                 spread:8.,//unrifled barrel makes it inaccurate
			                                 speedfactor:frandom(0.95,0.99));
			if(
				frandom(0,ceilingz-floorz)<bbb.speed*0.3
			)A_AlertMonsters(512);
            invoker.weaponstatus[0]&=~FP45_COCKED;
			invoker.weaponstatus[FP45_CHAMBER]=1;
			A_ZoomRecoil(0.995);
			A_MuzzleClimb(-frandom(0.8,1.7),-frandom(0.9,2.3)
			              -frandom(1.8,2.7),-frandom(2.1,3.3)
			            );

      damagemobj(invoker,self,random(3,5),
                 "bashing",DMG_NO_ARMOR);
        //make player flinch when shooting
        //this weapon is "not pleasant to fire"
		}                  
		---- # 0 A_StartSound("weapons/fp45",CHAN_WEAPON);
		---- # 0 A_Light0();
		stop;
	unload:
		---- # 0{//have to cock the hammer to unload/reload
			if(invoker.weaponstatus[FP45_CHAMBER]>0
			  &&invoker.weaponstatus[0]&FP45_COCKED
			  )setweaponstate("unloadchamber");
			 if(
		         !(invoker.weaponstatus[0]&FP45_COCKED)
		       &&invoker.weaponstatus[FP45_SPAREROUNDS]>0
		         )setweaponstate("unloadspares");
		}goto nope;
		
		unloadchamber:
		#### # 4 A_JumpIf(!invoker.weaponstatus[FP45_CHAMBER],"nope");
		#### # 1 offset(2,36);
		#### # 1 offset(3,38);
		#### # 1 offset(5,41) A_Log("You look for a stick or something...",true);
		#### # 1 offset(8,44) A_StartSound("weapons/pocket",9);
		#### # 1 offset(7,50) A_MuzzleClimb(frandom(-0.2,0.2),0.2,frandom(-0.2,0.2),0.2,frandom(-0.2,0.2),0.2);
		TNT1 A 3 A_StartSound("weapons/pocket",10);
		TNT1 AAAA 4 A_MuzzleClimb(frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2));
		TNT1 A 3 A_StartSound("weapons/pocket",9);
		TNT1 AAAA 4 A_MuzzleClimb(frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2),frandom(-0.2,0.2));
		TNT1 A 15 A_StartSound("weapons/smgmagclick",8);//open the chamber
		TNT1 A 15{A_StartSound("weapons/deinoload",8);//poke out the casing
			class<actor>which=invoker.weaponstatus[FP45_CHAMBER]>1?"HD45ACPAmmo":"HDSpent45ACP";
			invoker.weaponstatus[FP45_CHAMBER]=0;//chamber is now empty
			A_SpawnItemEx(which,//eject whatever was inside the chamber
				cos(pitch)*10,0,height*0.82-sin(pitch)*10,
				vel.x,vel.y,vel.z,
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
			);}
		TNT1 A 5 {if(PressingReload())
		            {//quick reload if timed right when chamber is empty
		            if(invoker.weaponstatus[FP45_SPAREROUNDS]>0)
		                setweaponstate("quick_sparereload");
		            else if(countinv("HD45ACPAmmo"))
		                setweaponstate("quick_pocketreload");
		            }
		          }
		      goto unload_end;//else, simply finish unload if not pressing Reload
		                      //or no ammo left to use
		quick_pocketreload:
		TNT1 AA 2 A_StartSound("weapons/pocket",9); 
		TNT1 A 16;
		TNT1 A 15{
		        A_TakeInventory("HD45ACPAmmo",1,TIF_NOTAKEINFINITE);
				invoker.weaponstatus[FP45_CHAMBER]=2;
				A_StartSound("weapons/deinoload",8);
			}
		    goto unload_end;
		quick_sparereload:
		TNT1 A 15{
		        invoker.weaponstatus[FP45_SPAREROUNDS]--;
				invoker.weaponstatus[FP45_CHAMBER]=2;
				A_StartSound("weapons/deinoload",8);
			}
		    goto unload_end;
		    
		unload_end:
		TNT1 A 15 A_StartSound("weapons/smgmagclick",8);
		FP45 D 0 A_CheckPistolHand();
		#### # 1 offset(7,52);
		#### # 1 offset(8,48);
		#### # 1 offset(5,42);
		#### # 1 offset(3,38);
		#### # 1 offset(2,36);
		    goto readyend;
		
		unloadspares:
		#### # 0 A_StartSound("weapons/pocket",9);
		#### # 1 offset(2,36);
		#### # 1 offset(3,38);
		#### # 1 offset(5,41);
		#### # 1 offset(8,44) A_StartSound("weapons/pocket",9);
		#### # 1 offset(7,50) A_MuzzleClimb(frandom(-0.2,0.2),0.2,frandom(-0.2,0.2),0.2,frandom(-0.2,0.2),0.2);
		TNT1 A 15 A_StartSound("weapons/smgmagclick",8);
		//open the bottom cover
		TNT1 A 0 A_JumpIf(PressingUse(),"dumpspares");
		
		TNT1 A 5{
		         A_SpawnItemEx("HD45ACPAmmo",
			    	cos(pitch)*10,0,height*0.82-sin(pitch)*10,
				    vel.x,vel.y,vel.z,
			    	0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
		    	    );				 
				 invoker.weaponstatus[FP45_SPAREROUNDS]--;
			     A_StartSound("weapons/deinoload",8);
		    	 }
		    goto unloadspareloop_end;
		
		dumpspares:
		TNT1 A 5{//empty spare rounds compartment
                 for(int i=invoker.weaponstatus[FP45_SPAREROUNDS];i>0;i--){
                    A_SpawnItemEx("HD45ACPAmmo",
			    	cos(pitch)*10,0,height*0.82-sin(pitch)*10,
				    vel.x+random(-1,1),vel.y+random(-1,1),vel.z,
			    	0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
		    	    );				 
			        }
			     invoker.weaponstatus[FP45_SPAREROUNDS]=0;
		    	 }
		unloadspareloop_end://close the bottom cover
		TNT1 A 15 A_StartSound("weapons/smgmagclick",8);
		FP45 D 0 A_CheckPistolHand();
		#### # 1 offset(7,52);
		#### # 1 offset(8,48);
		#### # 1 offset(5,42);
		#### # 1 offset(3,38);
		#### # 1 offset(2,36);
		goto readyend;

	reload:
	    ---- # 0 {// refill spare round compartment if uncocked
	                if(countinv("HD45ACPAmmo")
	                 &&invoker.weaponstatus[FP45_SPAREROUNDS]<5
	                 &&!(invoker.weaponstatus[0]&FP45_COCKED)
	                  )setweaponstate("reloadspares");
	              
	              // if cocked, check if chamber is empty
	                else if(invoker.weaponstatus[FP45_CHAMBER]>0)
	                    setweaponstate("nope");
	                     
	              // if empty, reload chamber
	                else if(
	                invoker.weaponstatus[0]&FP45_COCKED
	                &&(countinv("HD45ACPAmmo")
	                   ||invoker.weaponstatus[FP45_SPAREROUNDS]>0
	                   )
	                )setweaponstate("loadchamber");
	             }
	    goto nope;
	    
	    loadchamber:
		#### # 0 A_StartSound("weapons/pocket",9);
		#### # 1 offset(2,36);
		#### # 1 offset(3,38);
		#### # 1 offset(5,41);
		#### # 1 offset(8,44) A_StartSound("weapons/pocket",9);
		#### # 1 offset(7,50) A_MuzzleClimb(frandom(-0.2,0.2),0.2,frandom(-0.2,0.2),0.2,frandom(-0.2,0.2),0.2);
	    TNT1 A 0 {if(invoker.weaponstatus[FP45_SPAREROUNDS]>0)
	                setweaponstate("spare_reload");
	             }//skip pocket search if spare rounds in grip
	    pocket_reload:
		TNT1 A 20 A_StartSound("weapons/pocket",9);
		TNT1 A 15 A_StartSound("weapons/smgmagclick",8);
		TNT1 A 15{
		        A_TakeInventory("HD45ACPAmmo",1,TIF_NOTAKEINFINITE);
				invoker.weaponstatus[FP45_CHAMBER]=2;
				A_StartSound("weapons/deinoload",8);
			}
		goto reload_end;
		
		spare_reload:
		TNT1 A 15 A_StartSound("weapons/smgmagclick",8);
		TNT1 A 15{
			    invoker.weaponstatus[FP45_SPAREROUNDS]--;
				invoker.weaponstatus[FP45_CHAMBER]=2;
				A_StartSound("weapons/deinoload",8);
			}
		reload_end:
		TNT1 A 15 A_StartSound("weapons/smgmagclick",8);
		FP45 D 0 A_CheckPistolHand();
		#### # 1 offset(7,52);
		#### # 1 offset(8,48);
		#### # 1 offset(5,42);
		#### # 1 offset(3,38);
		#### # 1 offset(2,36);
		goto readyend;
		
		reloadspares:
		#### # 0 A_StartSound("weapons/pocket",9);
		#### # 1 offset(2,36);
		#### # 1 offset(3,38);
		#### # 1 offset(5,41);
		#### # 1 offset(8,44) A_StartSound("weapons/pocket",9);
		#### # 1 offset(7,50) A_MuzzleClimb(frandom(-0.2,0.2),0.2,frandom(-0.2,0.2),0.2,frandom(-0.2,0.2),0.2);
		TNT1 A 15 A_StartSound("weapons/smgmagclick",8);
		//open the bottom cover
		reloadspareloop:
		TNT1 A 20 A_StartSound("weapons/pocket",9);//fish for a loose round
		TNT1 A 10{//insert round into grip compartment
		         A_TakeInventory("HD45ACPAmmo",1,TIF_NOTAKEINFINITE);
				 invoker.weaponstatus[FP45_SPAREROUNDS]++;
			     A_StartSound("weapons/deinoload",8);
		    	 }
		TNT1 A 0 {//repeat if grip not full, still have ammo, or not ptessing Fire
		          if( countinv("HD45ACPAmmo")
		            &&invoker.weaponstatus[FP45_SPAREROUNDS]<5
		            &&!PressingFire()
		            &&!PressingReload()
		            )setweaponstate("reloadspareloop");
		            }
		goto reloadspareloop_end;

		reloadspareloop_end:	//close the bottom cover
		TNT1 A 15 A_StartSound("weapons/smgmagclick",8);
		FP45 D 0 A_CheckPistolHand();
		#### # 1 offset(7,52);
		#### # 1 offset(8,48);
		#### # 1 offset(5,42);
		#### # 1 offset(3,38);
		#### # 1 offset(2,36);
		goto readyend;

	user1:
	altreload:
	swappistols://make quickswap sprites
		---- # 0 A_SwapHandguns();
		---- # 0{
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
		FP45 A 0 A_CheckPistolHand();
		#### D 0 A_JumpIf(invoker.weaponstatus[0]&FP45_COCKED,2);
		#### A 0;
		#### # 0;
		goto nope;
	lowerleft:
		FP45 D 0 A_JumpIf(invoker.weaponstatus[0]&FP45_COCKED,2);
		#### A 0;
		#### # 1 offset(-6,38);
		#### # 1 offset(-12,48);
		#### # 1 offset(-20,60);
		#### # 1 offset(-34,76);
		#### # 1 offset(-50,86);
		stop;
	lowerright:
		F245 D 0 A_JumpIf(invoker.weaponstatus[0]&FP45_COCKED,2);
		#### A 0;
		#### # 1 offset(6,38);
		#### # 1 offset(12,48);
		#### # 1 offset(20,60);
		#### # 1 offset(34,76);
		#### # 1 offset(50,86);
		stop;
	raiseleft:
		FP45 D 0 A_JumpIf(invoker.weaponstatus[0]&FP45_COCKED,2);
		#### A 0;
		#### # 1 offset(-50,86);
		#### # 1 offset(-34,76);
		#### # 1 offset(-20,60);
		#### # 1 offset(-12,48);
		#### # 1 offset(-6,38);
		stop;
	raiseright:
		F245 D 0 A_JumpIf(invoker.weaponstatus[0]&FP45_COCKED,2);
		#### A 0;
		#### # 1 offset(50,86);
		#### # 1 offset(34,76);
		#### # 1 offset(20,60);
		#### # 1 offset(12,48);
		#### # 1 offset(6,38);
		stop;
	whyareyousmiling:
		#### A 1 offset(0,48);
		#### A 1 offset(0,60);
		#### A 1 offset(0,76);
		TNT1 A 7;
		FP45 A 0{
			invoker.wronghand=!invoker.wronghand;
			A_CheckPistolHand();
		}
		#### D 0 A_JumpIf(invoker.weaponstatus[0]&FP45_COCKED,2);
		#### A 0;
		#### # 1 offset(0,76);
		#### # 1 offset(0,60);
		#### # 1 offset(0,48);
		goto nope;

	spawn:
		LIBP A -1;
		stop;
	}
	override void initializewepstats(bool idfa){
		weaponstatus[FP45_CHAMBER]=0;//spawns unloaded
		weaponstatus[FP45_SPAREROUNDS]=5;//comes with 5 spare rounds
		weaponstatus[0]&=~FP45_COCKED;
	}
}

enum hdfp45status{
    FP45_COCKED=2,//tracks hammer cocking state
    
	FP45_SPAREROUNDS=1,//tracks no. of spare rounds in the grip
    FP45_CHAMBER=2,//tracks the chamber, duh
};

class HDFP45Spawn:actor{
	override void postbeginplay(){
		super.postbeginplay();
		spawn("HDFP45",pos,ALLOW_REPLACE);
		self.Destroy();
	}
}
