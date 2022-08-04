class HDMiniExplosion:IdleDummy{
	default{
  +forcexybillboard 
  +bright
		alpha 0.9;
   renderstyle "add";
		deathsound "world/explode";
   xscale 0.25;
   yscale 0.25;
	}

	states{
	spawn:
	death:
		MISL B 0 nodelay{
			if(max(abs(pos.x),abs(pos.y),abs(pos.z))>=32000){destroy();return;}
			vel.z+=4;
			A_StartSound(deathsound,CHAN_BODY);

    A_SpawnChunksFrags("HDB_00",20,1);
    A_SpawnChunksFrags("HDB_frag",10,1);

			let xxx=spawn("HDExplosionLight",pos);
			xxx.target=self;
		}

		MISL B 0 A_SpawnItemEx("ParticleWhiteSmall", 0,0,0, vel.x+random(-2,2),vel.y+random(-2,2),vel.z,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPOINTERS);
		MISL B 0 A_SpawnItemEx("HDSmoke", 0,0,0, vel.x+frandom(-2,2),vel.y+frandom(-2,2),vel.z,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPOINTERS);
		MISL B 0 A_Jump(256,"fade");
	fade:
		MISL B 1 A_FadeOut(0.1);
		MISL C 1 A_FadeOut(0.2);
		MISL DD 1 A_FadeOut(0.2);
		TNT1 A 20;
		stop;
	}
}

class HDB_12GuageSlugMissile:HDB_00{
	default{
		pushfactor 0.3;
		mass 200;
		speed HDCONST_MPSTODUPT*500;//720;
		accuracy 100;
		stamina 1850;
		woundhealth 10;
		hdbulletactor.hardness 1;
	}

override actor Puff(){


		if(max(abs(pos.x),abs(pos.y))>32000)return null;
		double sp=speed*speed*mass*0.000015;
		if(sp<50)return null;

  A_HDBlast(
     blastradius:16,
     blastdamage:25,
     fullblastradius:1,
     blastdamagetype:"bashing",
     immolateradius:48,
     immolateamount:random(16,24),
     immolatechance:48
			);
		
		A_SprayDecal("BrontoScorch",4);

		let aaa=HDBulletPuff(spawn("HDMiniExplosion",pos));
		if(aaa){
			aaa.angle=angle;aaa.pitch=pitch;
			aaa.stamina=int(sp*0.01);
			aaa.scarechance=max(0,20-int(sp*0.001));
			aaa.scale=(1.,1.)*(0.4+0.05*aaa.stamina);
			aaa.target=target;
    distantnoise.make(aaa,"world/rocketfar");
		}
		return aaa;
	}

	states{
	death:
		TNT1 A 0 {if(tracer)puff();}
		goto super::death;
	}
}
