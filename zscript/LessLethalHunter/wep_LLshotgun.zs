// ------------------------------------------------------------
// Shotgun (Common)
// ------------------------------------------------------------
class HDLLShotgun:HDWeapon{
	default{
		weapon.bobrangex 0.21;
		weapon.bobrangey 0.86;
		scale 0.6;
		inventory.pickupmessage "You got a shotgun!";
		obituary "%o got %h the hot bullets of %k's shotgun to die.";
	}
	override bool AddSpareWeapon(actor newowner){return AddSpareWeaponRegular(newowner);}
	override hdweapon GetSpareWeapon(actor newowner,bool reverse,bool doselect){return GetSpareWeaponRegular(newowner,reverse,doselect);}
	int handshells;
	action void EmptyHand(int amt=-1,bool careful=false){
		if(!amt)return;
		if(amt>0)invoker.handshells=amt;
		while(invoker.handshells>0){
			if(careful&&!A_JumpIfInventory("HDLLShellAmmo",0,"null")){
				invoker.handshells--;
				HDF.Give(self,"HDLLShellAmmo",1);
 			}else if(invoker.handshells>=4){
				invoker.handshells-=4;
				A_SpawnItemEx("LLShellPickup",
					cos(pitch)*1,1,height-7-sin(pitch)*1,
					cos(pitch)*cos(angle)*frandom(1,2)+vel.x,
					cos(pitch)*sin(angle)*frandom(1,2)+vel.y,
					-sin(pitch)+vel.z,
					0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
				);
			}else{
				invoker.handshells--;
				A_SpawnItemEx("HDLLFumblingShell",
					cos(pitch)*5,1,height-7-sin(pitch)*5,
					cos(pitch)*cos(angle)*frandom(1,4)+vel.x,
					cos(pitch)*sin(angle)*frandom(1,4)+vel.y,
					-sin(pitch)*random(1,4)+vel.z,
					0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
				);
			}
		}
	}
	action void A_UnloadSideSaddle(){
		int uamt=clamp(invoker.weaponstatus[SHOTS_SIDESADDLE],0,4);
		if(!uamt)return;
		invoker.weaponstatus[SHOTS_SIDESADDLE]-=uamt;
		int maxpocket=min(uamt,HDPickup.MaxGive(self,"HDLLShellAmmo",ENC_SHELL));
		if(maxpocket>0&&pressingunload()){
			A_SetTics(16);
			uamt-=maxpocket;
			A_GiveInventory("HDLLShellAmmo",maxpocket);
		}
		A_StartSound("weapons/pocket",9);
		EmptyHand(uamt);
	}
	
	//not all loads are equal
	double shotpower;
	static double getshotpower(){return frandom(0.9,1.05);}
	override void DetachFromOwner(){
		if(handshells>0){
			if(owner)owner.A_DropItem("HDLLShellAmmo",handshells);
			else A_DropItem("HDLLShellAmmo",handshells);
		}
		handshells=0;
		super.detachfromowner();
	}
	override void failedpickupunload(){
		int sss=weaponstatus[SHOTS_SIDESADDLE];
		if(sss<1)return;
		A_StartSound("weapons/pocket",9);
		int dropamt=min(sss,4);
		A_DropItem("HDLLShellAmmo",dropamt);
		weaponstatus[SHOTS_SIDESADDLE]-=dropamt;
		setstatelabel("spawn");
	}
	override void DropOneAmmo(int amt){
		if(owner){
			amt=clamp(amt,1,10);
			owner.A_DropInventory("HDLLShellAmmo",amt*4);
		}
	}
	override void ForceBasicAmmo(){
		owner.A_SetInventory("HDLLShellAmmo",20);
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

/*
enum hdshottystatus{
	SHOTS_SIDESADDLE=3,
};
*/
