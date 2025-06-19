// ------------------------------------------------------------
//  Explosive Shotgun
// ------------------------------------------------------------
class HDShotgunExplosive:HDWeapon{
	default{
		weapon.bobrangex 0.21;
		weapon.bobrangey 0.86;
		scale 0.6;
		inventory.pickupmessage "$PICKUP_ESHOTGUN";
		obituary "$OB_ESHOTGUN";
	}
	override bool AddSpareWeapon(actor newowner){return AddSpareWeaponRegular(newowner);}
	override hdweapon GetSpareWeapon(actor newowner,bool reverse,bool doselect){return GetSpareWeaponRegular(newowner,reverse,doselect);}
	int exhandshells;

	action void ExEmptyHand(int amt=-1,bool careful=false){
		if(!amt)return;
		if(amt>0)invoker.exhandshells=amt;
		while(invoker.exhandshells>0){
			if(careful&&!A_JumpIfInventory("HDExplosiveShellAmmo",0,"null")){
				invoker.exhandshells--;
				HDF.Give(self,"HDExplosiveShellAmmo",1);
 			}else if(invoker.exhandshells>=4){
				invoker.exhandshells-=4;
				A_SpawnItemEx("ExplosiveShellPickup",
					cos(pitch)*1,1,height-7-sin(pitch)*1,
					cos(pitch)*cos(angle)*frandom(1,2)+vel.x,
					cos(pitch)*sin(angle)*frandom(1,2)+vel.y,
					-sin(pitch)+vel.z,
					0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
				);
			}else{
				invoker.exhandshells--;
				A_SpawnItemEx("HDFumblingExplosiveShell",
					cos(pitch)*5,1,height-7-sin(pitch)*5,
					cos(pitch)*cos(angle)*frandom(1,4)+vel.x,
					cos(pitch)*sin(angle)*frandom(1,4)+vel.y,
					-sin(pitch)*random(1,4)+vel.z,
					0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
				);
			}
		}
	}

	action void A_ExUnloadSideSaddle(){
		int uamt=clamp(invoker.weaponstatus[EXSHOTS_SIDESADDLE],0,4);
		if(!uamt)return;
		invoker.weaponstatus[EXSHOTS_SIDESADDLE]-=uamt;
		int maxpocket=min(uamt,HDPickup.MaxGive(self,"HDExplosiveShellAmmo",ENC_SHELL));
		if(maxpocket>0&&pressingunload()){
			A_SetTics(16);
			uamt-=maxpocket;
			A_GiveInventory("HDExplosiveShellAmmo",maxpocket);
		}
		A_StartSound("weapons/pocket",9);
		ExEmptyHand(uamt);
	}

	//not all loads are equal
	double shotpower;
	static double getshotpower(){return frandom(0.9,1.05);}
	override void DetachFromOwner(){
		if(exhandshells>0){
			if(owner)owner.A_DropItem("HDExplosiveShellAmmo",exhandshells);
			else A_DropItem("HDExplosiveShellAmmo",exhandshells);
		}
		exhandshells=0;
		super.detachfromowner();
	}
	override void failedpickupunload(){
		int sss=weaponstatus[EXSHOTS_SIDESADDLE];
		if(sss<1)return;
		A_StartSound("weapons/pocket",9);
		int dropamt=min(sss,4);
		A_DropItem("HDExplosiveShellAmmo",dropamt);
		weaponstatus[EXSHOTS_SIDESADDLE]-=dropamt;
		setstatelabel("spawn");
	}
	override void DropOneAmmo(int amt){
		if(owner){
			amt=clamp(amt,1,10);
			owner.A_DropInventory("HDExplosiveShellAmmo",amt*4);
		}
	}
	override void ForceBasicAmmo(){
		owner.A_SetInventory("HDExplosiveShellAmmo",20);
	}
	clearscope string getpickupframe(bool usespare){
		int ssh=GetSpareWeaponValue(SHOTS_SIDESADDLE,usespare);
		if(ssh>=11)return "A";
		if(ssh>=9)return "B";
		if(ssh>=7)return "C";
		if(ssh>=5)return "D";
		if(ssh>=3)return "E";
		if(ssh>=1)return "F";
		return "G";
	}
}

enum hdexshottystatus{
	EXSHOTS_SIDESADDLE=3,
};
