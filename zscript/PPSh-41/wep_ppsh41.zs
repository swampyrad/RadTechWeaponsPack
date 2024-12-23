//based off Juan Horseshoe Pistol code

class HDPPSh41 :HDHandgun{
    //flags used for managing reloads
    //bool MAG_BOX;
    //bool MAG_DRUM;
    bool MAG_FORCEBOX;
    bool MAG_FORCEDRUM;
    
	default{
		+hdweapon.fitsinbackpack
		scale 0.65;
		weapon.selectionorder 50;
		weapon.slotnumber 4;
		weapon.slotpriority 3;
		weapon.kickback 30;
		weapon.bobrangex 0.1;
		weapon.bobrangey 0.6;
		weapon.bobspeed 2.5;
		weapon.bobstyle "normal";
		obituary "$OB_PPSH41";
		tag "$TAG_PPSH41";
		hdweapon.refid "pps";
		hdweapon.barrelsize 30,0.3,0.4;
    inventory.icon "PS41C0";

		hdweapon.loadoutcodes "
		//switchtype config unused, afaik all 
		//Soviet-era PPSh-41s had full-auto
			\cufiremode - 0/1, semi/auto
			\box - start loaded with a box magazine instead"
			;
	}

	override void postbeginplay(){
		super.postbeginplay();
		weaponspecial=1337;//UaS stabilizer compatibility
		weaponstatus[0]|=PPSHF_SELECTFIRE;//full-auto enabled
	}

		override string pickupmessage(){
		return Stringtable.Localize("$PICKUP_PPSH41");
	}

	override double weaponbulk(){
	  // weapon bulk
		int result = 110;//a bit heavier than the SMG
		
		// magazine bulk
		if(weaponstatus[PPSHS_MAG]
		   &&weaponstatus[PPSHS_MAGTYPE]==2
		  )result += ENC_TOKAREV_DRUM_EMPTY;
		else if(weaponstatus[PPSHS_MAG]
		        &&weaponstatus[PPSHS_MAGTYPE]==1
		       )result += ENC_TOKAREV_BOX_EMPTY;

    // ammo bulk
		int mgg=weaponstatus[PPSHS_MAG];
		
		// total bulk
		return result+(mgg<0?0:(mgg*ENC_762TOKAREV_LOADED));
	}
	
	override double gunmass(){
		int mgg=weaponstatus[PPSHS_MAG];
		
		//add weight of ammo and magazine, if loaded
		return 7+(mgg<0?0:0.10*(mgg+1))
		        +(weaponstatus[PPSHS_MAGTYPE]==1?1:0)
		        +(weaponstatus[PPSHS_MAGTYPE]==2?3:0);
	}
	
	override void failedpickupunload(){
	if(weaponstatus[PPSHS_MAGTYPE]==1)
	  failedpickupunloadmag(PPSHS_MAG,"HDTokarevMag35");
	else failedpickupunloadmag(PPSHS_MAG,"HDTokarevMag71");
	}
	
	override string,double getpickupsprite(bool usespare)
    { string sprind;
      string sprname="PS41";

			// For ammo reloads via cheats. 
			if(GetSpareWeaponValue(PPSHS_MAG, usespare) >= 0
			   &&weaponstatus[PPSHS_MAGTYPE]==2)
			{
				sprind="C";
			}
			else if(GetSpareWeaponValue(PPSHS_MAG, usespare) >= 0
			        &&weaponstatus[PPSHS_MAGTYPE]==1)
			{
				sprind="B";
			}
			else sprind="A";

      return sprname..sprind.."0",1.;
    }

	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
		
		//drum mags
			int nextmagloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("HDTokarevMag71")));
			if(nextmagloaded>=71){
				sb.drawimage("PSDMA0",(-50,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1,1));
			}else if(nextmagloaded<1){
				sb.drawimage("PSDMC0",(-50,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextmagloaded?0.6:1.,scale:(1,1));
			}else sb.drawbar(
				"PSDMA0","PSDMC0",
				nextmagloaded,71,
				(-50,-3),-1,
				sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
			);
			
		//box mags
			int nextpmagloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("HDTokarevMag35")));
			if(nextpmagloaded>=35){
				sb.drawimage("PSHMA0",(-63,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1,1));
			}else if(nextpmagloaded<1){
				sb.drawimage("PSHMC0",(-63,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextpmagloaded?0.6:1.,scale:(1,1));
			}else sb.drawbar(
				"PSHMA0","PSHMC0",
				nextpmagloaded,35,
				(-63,-3),-1,
				sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
			);
    
    //spare mag counters
			sb.drawnum(hpl.countinv("HDTokarevMag71"),-43,-8,sb.DI_SCREEN_CENTER_BOTTOM);
	    sb.drawnum(hpl.countinv("HDTokarevMag35"),-56,-8,sb.DI_SCREEN_CENTER_BOTTOM);
		}
	  
	  //firemode setting
		sb.drawwepcounter(hdw.weaponstatus[0]&PPSHF_FIREMODE,
			-22,-10,"RBRSA3A7","STFULAUT"
		);
		
		//main ammobar
		sb.drawwepnum(hdw.weaponstatus[PPSHS_MAG],
		              hdw.weaponstatus[PPSHS_MAG]>35?
		                hdw.weaponstatus[PPSHS_MAG]:35,-16);
		
		//second ammobar, for drum mags
		if(hdw.weaponstatus[PPSHS_MAG]>35)
	    sb.drawwepnum(hdw.weaponstatus[PPSHS_MAG]-35,35,-16,-2);
		
		//chamber status
		if(hdw.weaponstatus[PPSHS_CHAMBER]==2)sb.drawrect(-19,-11,3,1);
		if(hdw.weaponstatus[PPSHS_CHAMBER]==1)sb.drawrect(-17,-11,1,1);
	}
	
	override string gethelptext(){
		return
		WEPHELP_FIRESHOOT
		..WEPHELP_ALTFIRE.."  Rack bolt\n"
		..WEPHELP_FIREMODE.."  Semi/Auto\n"
		..WEPHELP_RELOAD.."  Reload mag (drum mags first)\n"
		..WEPHELP_ALTRELOAD.."  Reload box magazine\n"
		..WEPHELP_MAGMANAGER
		..WEPHELP_UNLOADUNLOAD
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
			-8+bob.x,-9+bob.y,17,19,
			sb.DI_SCREEN_CENTER
		);
		scc=(0.6,0.6);
		
		//front sight
		sb.drawimage(
			"ppshfsit",(0,-3)+bobb,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			scale:scc
		);

    //rear sight
		sb.SetClipRect(cx,cy,cw,ch);
		sb.drawimage(
			"ppshbsit",(0,-3)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			alpha:1,
			scale:scc
		);
	}
	
	override void DropOneAmmo(int amt){
		if(owner){
			amt=clamp(amt,1,10);
			if(owner.countinv("HD762TokarevAmmo"))
			  owner.A_DropInventory("HD762TokarevAmmo",amt*35);
			else if(owner.countinv("HDTokarevMag71"))
			  owner.A_DropInventory("HDTokarevMag71",amt);
		  else if(owner.countinv("HDTokarevMag35"))
		    owner.A_DropInventory("HDTokarevMag35",amt);
		}
	}
	
	override void ForceBasicAmmo(){
		owner.A_TakeInventory("HD762TokarevAmmo");
		ForceOneBasicAmmo("HDTokarevMag71");
	}
	
	states{
	select0:
	  PPSH F 0 A_JumpIf(!invoker.weaponstatus[PPSHS_COCKED]
	                    &&invoker.weaponstatus[PPSHS_MAGTYPE]==2,6);//drum mag, uncocked
		#### E 0 A_JumpIf(!invoker.weaponstatus[PPSHS_COCKED]
			                &&invoker.weaponstatus[PPSHS_MAGTYPE]==1,5);//box nag, uncocked
		#### D 0 A_JumpIf(!invoker.weaponstatus[PPSHS_COCKED]
					            &&invoker.weaponstatus[PPSHS_MAGTYPE]==0,4);//no mag, uncocked
		PPSH C 0 A_JumpIf(invoker.weaponstatus[PPSHS_MAGTYPE]==2,3);//drum mag, cocked
		#### B 0 A_JumpIf(invoker.weaponstatus[PPSHS_MAGTYPE]==1,2);//box mag, cocked
		#### A 0;//no mag, cocked
		#### # 0;
		goto select0big;
	deselect0:
		PPSH F 0 A_JumpIf(!invoker.weaponstatus[PPSHS_COCKED]
					            &&invoker.weaponstatus[PPSHS_MAGTYPE]==2,6);//drum mag, uncocked
		#### E 0 A_JumpIf(!invoker.weaponstatus[PPSHS_COCKED]
					            &&invoker.weaponstatus[PPSHS_MAGTYPE]==1,5);//box nag, uncocked
		#### D 0 A_JumpIf(!invoker.weaponstatus[PPSHS_COCKED]
					            &&invoker.weaponstatus[PPSHS_MAGTYPE]==0,4);//no mag, uncocked
		PPSH C 0 A_JumpIf(invoker.weaponstatus[PPSHS_MAGTYPE]==2,3);//drum mag, cocked
		#### B 0 A_JumpIf(invoker.weaponstatus[PPSHS_MAGTYPE]==1,2);//box mag, cocked
		#### A 0;//no mag, cocked
		#### # 0;
		goto deselect0big;

	ready:
		PPSH F 0 A_JumpIf(!invoker.weaponstatus[PPSHS_COCKED]
					            &&invoker.weaponstatus[PPSHS_MAGTYPE]==2,6);//drum mag, uncocked
		#### E 0 A_JumpIf(!invoker.weaponstatus[PPSHS_COCKED]
					            &&invoker.weaponstatus[PPSHS_MAGTYPE]==1,5);//box nag, uncocked
		#### D 0 A_JumpIf(!invoker.weaponstatus[PPSHS_COCKED]
					            &&invoker.weaponstatus[PPSHS_MAGTYPE]==0,4);//no mag, uncocked
		PPSH C 0 A_JumpIf(invoker.weaponstatus[PPSHS_MAGTYPE]==2,3);//drum mag, cocked
		#### B 0 A_JumpIf(invoker.weaponstatus[PPSHS_MAGTYPE]==1,2);//box mag, cocked
		#### A 0;//no mag, cocked
		#### # 0 A_SetCrosshair(21);
		#### # 1 {A_WeaponReady(WRF_ALL);
		            invoker.MAG_FORCEDRUM=false;
		            invoker.MAG_FORCEBOX=false;
		            //resets reload flags
		        }
		goto readyend;
	
	user3:
		---- # 0 {if(countinv("HDTokarevMag71"))
		            A_MagManager("HDTokarevMag71");
		          else A_MagManager("HDTokarevMag35");
		          }
		goto ready;
		
	user2:
	firemode:
		---- # 0{
		        invoker.weaponstatus[0]^=PPSHF_FIREMODE;
	            }
		goto nope;
		
	altfire:
  rackbolt:
	#### # 0 A_JumpIf(invoker.weaponstatus[PPSHS_COCKED],"nope");
		#### # 2 offset(1,32);
		#### # 2 offset(2,42);
		PPSH C 0 A_JumpIf(invoker.weaponstatus[PPSHS_MAGTYPE]==2,3);//drum mag, cocked
		#### B 0 A_JumpIf(invoker.weaponstatus[PPSHS_MAGTYPE]==1,2);//box mag, cocked
		#### A 0;//no mag, cocked
		#### # 2 offset(3,48){A_StartSound("weapons/tt33_chamber",8,CHANF_OVERLAP);
	      			            A_MuzzleClimb(frandom(0.2,0.24),-frandom(0.3,0.36),frandom(0.2,0.24),-frandom(0.3,0.36));
        
        			            //spawns an unspent round 
  			                  if(invoker.weaponstatus[PPSHS_CHAMBER]==2)
  			                    A_SpawnItemEx("HDLoose762Tokarev",
					            		                 cos(pitch)*10,0,height*0.82-sin(pitch)*10,
					            		                 vel.x,vel.y,vel.z,
					            		                 0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
				    			    		                );
				    			    		                
        			            //spawns an spent casing 
  			                  if(invoker.weaponstatus[PPSHS_CHAMBER]==1)
  			                    A_SpawnItemEx("HDSpent762Tokarev",
					            		                 cos(pitch)*10,0,height*0.82-sin(pitch)*10,
					            		                 vel.x,vel.y,vel.z,
					            		                 0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
				    			    		                );
  			                    
						    			    //chamber empty, bolt cocked
					    			    	invoker.weaponstatus[PPSHS_CHAMBER]=0;
					    			    	invoker.weaponstatus[PPSHS_COCKED]=1;
					    			     }
		#### # 2 offset(2,42);	
		#### # 2 offset(1,32);
		goto readyend;
		
		//drop bolt without firing round
	dropbolt:
	  #### F 0 A_JumpIf(invoker.weaponstatus[PPSHS_MAGTYPE]==2,3);
		#### E 0 A_JumpIf(invoker.weaponstatus[PPSHS_MAGTYPE]==1,2);
		#### D 0;
		#### # 1 offset(-1,36) A_StartSound("weapons/tt33_load",CHAN_WEAPON,CHANF_OVERLAP);
		#### # 1 offset(1,30) A_StartSound("weapons/rifleclick",CHAN_WEAPON,CHANF_OVERLAP);
		goto readyend;
		
	althold:
	hold:
		goto nope;
	fire:
	  #### # 0 A_JumpIf(!invoker.weaponstatus[PPSHS_COCKED]
	                    ,"nope");//do nothing if not cocked
	shoot:
	  #### # 0 {//drop the bolt
		    	    invoker.weaponstatus[PPSHS_COCKED]=0;
		    	    
		    	    //abort if no magazine or ammo
		    	    if(invoker.weaponstatus[PPSHS_MAG]<=0
		    	      )setweaponstate("dropbolt");
		    	   }
		#### F 0 A_JumpIf(invoker.weaponstatus[PPSHS_MAGTYPE]==2,2);
		#### E 0;
	  #### # 1 {//using modified version of Sten's jamming mechanic
	  
		          let drumjam = invoker.weaponstatus[PPSHS_MAG]/3;
		          let boxjam = invoker.weaponstatus[PPSHS_MAG]/4;
		            
		          //box mags are less likely to jam than drums
		          if(!random(0,99
		              -(invoker.weaponstatus[PPSHS_MAGTYPE]==2?drumjam:boxjam)
		              -(drumjam>65?10:0)//higher chance to jam on a full drum
		              )
		            )setweaponstate("dropbolt");
		    
		          //failure to feed,
				      //extra chance to jam if drum is too full,
				      //something to do with the spring being too tight
	           
	            //this is the only part where the magazine plays
	            //a factor in jamming, everything else is based
	            //on the weapon's mechanisms itself, not the mag's 
	   
	            //if magazine not empty, chamber a round
	    		    if(invoker.weaponstatus[PPSHS_MAG]>0
	    		      ){invoker.weaponstatus[PPSHS_MAG]--;
				          invoker.weaponstatus[PPSHS_CHAMBER]=2;
		  	         }
		    	    
		    	    // random chance of light primer strike
		          if(!random(0,99)
		            )setweaponstate("dropbolt");
	    	     }
		#### # 0 {if(invoker.weaponstatus[PPSHS_CHAMBER]==2)
		            {A_GunFlash();
		             A_MuzzleClimb(-frandom(0.6,0.9),-frandom(0.8,1.1),
				                       frandom(0.4,0.5),frandom(0.6,0.8)
			                        );
		            }
		            
		          //random chance of failure to eject
		          if(!random(0,99))
		            setweaponstate("dropbolt");
		         }
		#### C 0 A_JumpIf(invoker.weaponstatus[PPSHS_MAGTYPE]==2,2);
		#### B 0;         
		#### # 1 {//eject spent casing
		          if(invoker.weaponstatus[PPSHS_CHAMBER]==1)
		      	    A_EjectCasing("HDSpent762Tokarev",
		      	                   -frandom(89,91), //angle, -90 is standard
		      	                  (0,               //x axis velocity
		      	                   frandom(1,2),    //y axis velocity, positive is forward
		      	                   frandom(6,7)),   //z axis velocity, positive is upwards
		      	                  (13,0,0)          //spawn coordinates (z,x,y)
		      	                 );
	      		  
	      		  //chamber empty, bolt recocked
	      		  invoker.weaponstatus[PPSHS_CHAMBER]=0;
	      		  invoker.weaponstatus[PPSHS_COCKED]=1;
		         }
		#### # 1 {
		        	A_WeaponReady(WRF_NOFIRE);
	        		if(
	        			(invoker.weaponstatus[0]&
	        			(PPSHF_FIREMODE|PPSHF_SELECTFIRE))
	        			==(PPSHF_FIREMODE|PPSHF_SELECTFIRE)
	        		){
	        			A_Refire("fire");
	        		}else A_Refire();
		}goto ready;
		
	flash:
		PPFL A 0 A_StartSound("weapons/ppsh41",CHAN_WEAPON);
		#### # 1 bright{HDFlashAlpha(64);
			              A_Light1();
			      			  let bbb=HDBulletActor.FireBullet(self,"HDB_762TOKAREV",spread:2.,speedfactor:frandom(0.99,1.05));
			    			    if(frandom(0,ceilingz-floorz)<bbb.speed*0.3
						          )A_AlertMonsters(240);
                    //round fired, spent casing in chamber
						        invoker.weaponstatus[PPSHS_CHAMBER]=1;
						        A_ZoomRecoil(0.995);
			
						        A_MuzzleClimb(
						          -frandom(0.6,0.8),-frandom(1.,1.2),
				        		  frandom(0.4,0.5),frandom(0.6,0.8)
						        );
	
			         		 }
		#### # 0 A_Light0();
		stop;
		
	unload:
		---- # 0{invoker.weaponstatus[0]|=PPSHF_JUSTUNLOAD;
			       if(invoker.weaponstatus[PPSHS_MAGTYPE]>0)setweaponstate("unmag");
		}goto nope;
		
	loadchamber:
		goto readyend;

    //note to self: 
    //never put "altreload" before "reload",
    //it screws everything up lmao
    
	reload:
	  ---- # 0 {invoker.weaponstatus[0]&=~PPSHF_JUSTUNLOAD;
	            
			        //full box mag ammo check
			        if( invoker.weaponstatus[PPSHS_MAGTYPE]==1
			            &&invoker.weaponstatus[PPSHS_MAG]>=35
			          )setweaponstate("nope");
			          
			        //full drum mag ammo check
			        if( invoker.weaponstatus[PPSHS_MAGTYPE]==2
			            &&invoker.weaponstatus[PPSHS_MAG]>=71
			          )setweaponstate("nope");
			       
			        //do nothing if no mags or drums left
			        if(  !countinv("HDTokarevMag71")
			           &&!countinv("HDTokarevMag35")
			          )setweaponstate("nope");
			       }
	  ---- # 0 {//reload box mags if no drums left
			        if(!countinv("HDTokarevMag71")
			          ){invoker.MAG_FORCEBOX=true;
		              setweaponstate("unmag");
		             }
		          
		          //reload drum mag if AltReload wasn't pressed
		          if(invoker.MAG_FORCEBOX==false)
			          invoker.MAG_FORCEDRUM=true;
		         }
		goto unmag;

	unmag:
		---- # 1 offset(0,34) A_SetCrosshair(21);
		---- # 1 offset(2,40);
		---- # 2 offset(4,46);
		---- # 3 offset(6,52) A_StartSound("weapons/rifleunload",8,CHANF_OVERLAP,0.3);
		#### D 0 A_JumpIf(!invoker.weaponstatus[PPSHS_COCKED],2);
		#### A 0;
		#### # 0 {//track current mag ammo
		          int pmg=invoker.weaponstatus[PPSHS_MAG];
		          //set weapon to "unloaded"
			        invoker.weaponstatus[PPSHS_MAG]=-1;

			        if(invoker.weaponstatus[PPSHS_MAGTYPE]==2)
			        {//skip if already unloaded
			          invoker.weaponstatus[PPSHS_MAGTYPE]=0;
			          if(pmg<0)setweaponstate("drummagout");
			          else if (
				               (!PressingUnload()&&!PressingReload()&&!PressingAltReload())
				                ||A_JumpIfInventory("HDTokarevMag71",0,"null")
			                ){//drop drum mag
			                  HDMagAmmo.SpawnMag(self,"HDTokarevMag71",pmg);
				                setweaponstate("drummagout");
			                 }else
			                 {//pocket drum mag
			                  HDMagAmmo.GiveMag(self,"HDTokarevMag71",pmg);
				                A_StartSound("weapons/pocket",9);
				                setweaponstate("pocketdrummag");
			                 }
			        }
		               
			        if(invoker.weaponstatus[PPSHS_MAGTYPE]==1)
			        {//skip if already unloaded
			          invoker.weaponstatus[PPSHS_MAGTYPE]=0;
					  	  if(pmg<0)setweaponstate("boxmagout");
					  	  else if(
					  		      (!PressingUnload()&&!PressingReload()&&!PressingAltReload())
					  		      ||A_JumpIfInventory("HDTokarevMag35",0,"null")
				  		       ){//drop box mag
				  			       HDMagAmmo.SpawnMag(self,"HDTokarevMag35",pmg);
				  		         setweaponstate("boxmagout");
				  		        }else
				  		        {//pocket box mag
					  		       HDMagAmmo.GiveMag(self,"HDTokarevMag35",pmg);
				  			       A_StartSound("weapons/pocket",9);
				  		         setweaponstate("pocketboxmag");
				  		        }
				  	  }
				  	 }
		goto drummagout;

	pocketdrummag:
		---- # 5 offset(6,52) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		---- # 5 offset(6,52) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		---- # 5 offset(6,52) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		goto drummagout;
	
	pocketboxmag:
		---- # 5 offset(6,52) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		---- # 5 offset(6,52) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		---- # 5 offset(6,52) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		goto boxmagout;
	
	drummagout:
		#### # 0{
			if(invoker.weaponstatus[0]&PPSHF_JUSTUNLOAD)setweaponstate("reloadend");
			else if(invoker.MAG_FORCEBOX)setweaponstate("loadbox");
			else setweaponstate("loaddrum");
		}
		
	boxmagout:
		#### # 0{
			if(invoker.weaponstatus[0]&PPSHF_JUSTUNLOAD)setweaponstate("reloadend");
			else if(invoker.MAG_FORCEDRUM)setweaponstate("loaddrum");
			else setweaponstate("loadbox");
		}

  loaddrum:
	  #### # 0 A_JumpIf(!countinv("HDTokarevMag71")||invoker.MAG_FORCEBOX,"loadbox");
		#### # 3 offset(6,52) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		#### # 0 A_StartSound("weapons/pocket",9);
		#### # 3 offset(6,52) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		#### F 0 A_JumpIf(!invoker.weaponstatus[PPSHS_COCKED],2);		
		#### C 0;
		#### # 3 offset(6,58);
		---- # 0 {let mmm=hdmagammo(findinventory("HDTokarevMag71"));
			        if(mmm){invoker.weaponstatus[PPSHS_MAG]=mmm.TakeMag(true);
				              invoker.weaponstatus[PPSHS_MAGTYPE]=2;
				
				              A_StartSound("weapons/rifleclick",8);
				              A_StartSound("weapons/rifleload",8,CHANF_OVERLAP);
				              //setweaponstate("reloadend");
			               }
		}
		#### # 3 offset(6,64);
		#### # 6 offset(6,58);
		#### # 2 offset(7,64);
		#### # 2 offset(8,70);
		#### # 2 offset(9,76);
		#### # 2 offset(8,82) A_StartSound("weapons/smack",8);
		#### # 2 offset(9,76);
		#### # 2 offset(8,70);
		#### # 2 offset(7,64);
		#### # 2 offset(6,52);
		goto reloadend;
	    
  loadbox:
		#### # 3 offset(6,52) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		#### # 0 A_StartSound("weapons/pocket",9);
		#### # 3 offset(6,52) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
		#### # 3 offset(6,58);
		---- # 0 {let mmm=hdmagammo(findinventory("HDTokarevMag35"));
			        if(mmm){invoker.weaponstatus[PPSHS_MAG]=mmm.TakeMag(true);
				              invoker.weaponstatus[PPSHS_MAGTYPE]=1;
				              
								      A_StartSound("weapons/rifleclick",8);
								      A_StartSound("weapons/rifleload",8,CHANF_OVERLAP);
											//setweaponstate("reloadend");
							       }
		}
		#### # 2 offset(6,64);
		#### E 0 A_JumpIf(!invoker.weaponstatus[PPSHS_COCKED],2);		
		#### B 0;
		#### # 2 offset(6,70);
		#### # 2 offset(6,64);
		#### # 2 offset(6,58);
		#### # 2 offset(6,52);
		goto reloadend;

	reloadend:
		#### # 2 offset(6,46);
		---- # 2 offset(4,40);
		---- # 2 offset(2,34);
		---- # 0 A_JumpIf(PressingReload()||PressingAltReload(),"nope");
		goto ready;

	user1:
	altreload:
	    ---- # 0 {
	            invoker.MAG_FORCEBOX=true;
	            }//set this so it forces a box mag reload
	    goto reload;
	
	spawn:
		PS41 ABC -1 nodelay
		{
			if(invoker.weaponstatus[PPSHS_MAGTYPE]==2)
			    frame = 2;
			else if (invoker.weaponstatus[PPSHS_MAGTYPE]==1)
			    frame = 1;
			else frame = 0;
		}
		stop;
	}
	
	override void initializewepstats(bool idfa){
		weaponstatus[PPSHS_MAG]=71;
		weaponstatus[PPSHS_CHAMBER]=0;//open bolt
		weaponstatus[PPSHS_MAGTYPE]=2;//drum mag
		weaponstatus[PPSHS_COCKED]=1;//bolt cocked
	}
	
	override void loadoutconfigure(string input){
		weaponstatus[0]|=PPSHF_SELECTFIRE;
		
		if(weaponstatus[0]&PPSHF_SELECTFIRE){
			int firemode=getloadoutvar(input,"firemode",1);
			if(!firemode)weaponstatus[0]&=~PPSHF_FIREMODE;
			else if(firemode>0)weaponstatus[0]|=PPSHF_FIREMODE;
		}
		
		int boxmag=getloadoutvar(input,"box",1);
		if(!boxmag){weaponstatus[PPSHS_MAG]=71;
		            weaponstatus[PPSHS_MAGTYPE]=2;
		}else if(boxmag>0){weaponstatus[PPSHS_MAG]=35;
		                   weaponstatus[PPSHS_MAGTYPE]=1;
		                  }
	}
}

enum papasha_status
{
	PPSHF_SELECTFIRE=1,
	PPSHF_FIREMODE=2,
	PPSHF_JUSTUNLOAD=4,

	PPSHS_FLAGS=0,
	PPSHS_MAG=1,
	PPSHS_CHAMBER=2, //0 empty, 1 spent, 2 loaded
	PPSHS_MAGTYPE=3, //0 none, 1 box mag, 2 drum mag
	PPSHS_COCKED=4,  //0 uncocked, 1 cocked
};

class PapashaSpawn:actor{
	override void postbeginplay(){
		super.postbeginplay();
		if(!random(0,9))spawn("TokarevAutoReloader",pos,ALLOW_REPLACE);
		if(!random(0,9)){
  		spawn("HDTokarevMag71",pos,ALLOW_REPLACE);
  		spawn("HDTokarevMag71",pos,ALLOW_REPLACE);
  		}else{
  		spawn("HDTokarevMag35",pos,ALLOW_REPLACE);
  		spawn("HDTokarevMag35",pos,ALLOW_REPLACE);
  		}
  	    spawn("HDPPSh41",pos,ALLOW_REPLACE);
		self.Destroy();
	}
}
