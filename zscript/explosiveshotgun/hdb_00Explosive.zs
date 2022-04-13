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
			if(max(abs(pos.x),abs(pos.y),abs(pos.z))>=8192){destroy();return;}
			vel.z+=4;
			A_StartSound(deathsound,CHAN_BODY);
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

class HDB_00Explosive:HDB_00{
	default{
		pushfactor 0.3;
		mass 150;
		speed HDCONST_MPSTODUPT*500;//720;
		accuracy 200;
		stamina 1850;
		woundhealth 3;
		hdbulletactor.hardness 0;
	}
override actor Puff(){
		if(max(abs(pos.x),abs(pos.y))>=8192)return null;
		setorigin(pos-(2*(cos(angle),sin(angle)),0),false);

		A_SprayDecal("BrontoScorch",8);
		if(vel==(0,0,0))A_ChangeVelocity(cos(pitch),0,-sin(pitch),CVF_RELATIVE|CVF_REPLACE);
		else vel*=0.01;
		if(tracer){ //warhead damage
			int dmg=random(90,99);//fuck this line of code in particular

			//find the point at which it would pierce the middle
			vector3 hitpoint=pos+vel.unit()*tracer.radius;

			//find the "heart" point on the victim
			vector3 tracmid=(tracer.pos.xy,tracer.pos.z+tracer.height*0.618);

			dmg=int((1.-((hitpoint-tracmid).length()/tracer.radius))*dmg);
			tracer.damagemobj(
				self,target,
				dmg,
				"electrical",DMG_THRUSTLESS
			);
		}
		//doordestroyer.destroydoor(self,64,frandom(4,16),6,dedicated:true);

/*  this is so OP

		A_HDBlast(
			fragradius:16,
    fragtype:"HDB_frag",
			immolateradius:48,
    immolateamount:random(12,20),
    immolatechance:64,
			source:target
		);

*/

A_HDBlast(
			fragradius:0,
    fragtype:"HDB_fragBronto",
			immolateradius:48,
    immolateamount:random(12,20),
    immolatechance:64,
			source:target
		);

		DistantQuaker.Quake(self,3,35,64,12);
		actor aaa=Spawn("HDSmoke",pos,ALLOW_REPLACE);
		//A_SpawnChunks("BigWallChunk",20,4,20);
		//A_SpawnChunks("HDSmoke",4,1,7);
		aaa=spawn("HDMiniExplosion",pos,ALLOW_REPLACE);
  aaa.vel.z=2;
		distantnoise.make(aaa,"world/rocketfar");
		//A_SpawnChunks("HDSmokeChunk",random(3,4),6,12);

		bmissile=false;
		bnointeraction=true;
		vel=(0,0,0);
		if(!instatesequence(curstate,findstate("death")))setstatelabel("death");
		return null;
	}
	override void onhitactor(actor hitactor,vector3 hitpos,vector3 vu,int flags){
		double spbak=speed;
		super.onhitactor(hitactor,hitpos,vu,flags);
		if(spbak-speed>10)puff();
	}
	
	states{
	death:
		TNT1 A 0{if(tracer)puff();}
		goto super::death;
	}
}
