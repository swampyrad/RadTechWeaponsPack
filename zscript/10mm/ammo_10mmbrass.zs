
//(primers and bullet lead can be cannibalized from 9mm rounds)
class TenMilBrass:HDAmmo{
	default{
		+inventory.ignoreskill +forcexybillboard +cannotpush
		+hdpickup.multipickup
		+hdpickup.cheatnogive
		height 16;radius 8;
		tag "10mm casing";
		hdpickup.refid "c10";
		hdpickup.bulk ENC_776B;
		xscale 0.7;yscale 0.8;
		inventory.pickupmessage "Picked up some 10mm brass.";
		inventory.icon "CS10B0";
	}
	override void GetItemsThatUseThis(){
		itemsthatusethis.push("TenMilAutoReloader");
  itemsthatusethis.push("HD10mmPistol");
	}
	states{
	spawn:
		CS10 B -1;
		stop;
	}
}

