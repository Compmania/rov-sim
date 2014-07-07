// Template file v5.202 (02/20/02)
////////////////////////////////////////////////////////////////////////
// File: actor.wdl
//		WDL prefabs for actors and enemies
////////////////////////////////////////////////////////////////////////
//]- Mod Date: 7/5/00 DCP
//]-				Changed to 4.19 format
//]- Mod Date: 10/31/00 DCP
//]-				Changed to 4.20 format
//]- Mod Date: 6/21/01 by DCP
//]-			_actor_connect(): Added wait(1) before remove
//]-
//]- Mod Date: 12/18/01
//]-		Added WED 'uses' comments to all WED editable fields
//]-
////////////////////////////////////////////////////////////////////////
// ACTIONS:
//		patrol: move from target to target
//    actor_follow: follow the player
//
//	FUNCTIONS:
//		actor_move(): move aheading using 'force' (scan_floor, move_gravity, actor_anim)
//		actor_turn(): PAN towards target angle MY_ANGLE, according to force
//		_actor_connect(): remove self on EVENT_DISCONNECT
//	   _scan_target(): find next start position
////////////////////////////////////////////////////////////////////////


// Desc: move from target to target
//
// uses _FORCE, _MOVEMODE, _WALKFRAMES, _RUNFRAMES, _WALKSOUND
action patrol
{
	//if(MY._FORCE == 0) {  MY._FORCE = 1; }
	//if(MY._MOVEMODE == 0) { MY._MOVEMODE = _MODE_WALKING; }
	//if(MY._WALKFRAMES == 0) { MY._WALKFRAMES = DEFAULT_WALK; }
	//if(MY._RUNFRAMES == 0) { MY._RUNFRAMES = DEFAULT_RUN; }
	//if(MY._WALKSOUND == 0) { MY._WALKSOUND = _SOUND_WALKER; }
	//anim_init();

	// find next start position
	MY._TARGET_X = MY.X;
	MY._TARGET_Y = MY.Y;
	MY._TARGET_Z = MY.Z;
	scan_sector.PAN = 360;
	_scan_target();

	while(MY._MOVEMODE > 0)
	{
		// find direction
		MY_POS.X = MY._TARGET_X - MY.X;
		MY_POS.Y = MY._TARGET_Y - MY.Y;
		MY_POS.Z = MY._TARGET_Z - MY.Z;
		result = vec_to_angle(MY_ANGLE,MY_POS);   // 10/31/00 replace TO_ANGLE

		if (result < 30) 	// near target? Find next
		{
			scan_sector.PAN = 20;
			_scan_target();
		}

		force = MY._FORCE * 2;
		actor_turn();	// look to target

		force = MY._FORCE;
		if(abs(aforce.PAN) > MY._FORCE) 	// reduce speed if turning
		{
			force *= 0.5;
		}
		if(MY_ANGLE.Z < 40) 	// reduce speed near target
		{
			force *= 0.5;
		}
		actor_move();
		// Wait one tick, then repeat
		wait(1);
	}
}

// Desc: move along a path
//
// uses _FORCE, _MOVEMODE, _WALKFRAMES, _WALKSOUND
action patrol_path
{
	//actor_init();

	// attach next path
	temp.pan = 360;
	temp.tilt = 180;
	temp.z = 1000;
	result = scan_path(my.x,temp);
	//if (result == 0) { my._MOVEMODE = 0; }	// no path found

	// find first waypoint
	ent_waypoint(my._TARGET_X,1);

	while (1)
	{
		// find direction
		temp.x = MY._TARGET_X - MY.X;
		temp.y = MY._TARGET_Y - MY.Y;
		temp.z = MY._TARGET_Z - MY.Z;
		result = vec_to_angle(my_angle,temp);

	//	force = MY._FORCE;

		// near target? Find next waypoint
		// compare radius must exceed the turning cycle!
		if (result < 25) { ent_nextpoint(my._TARGET_X); }

		// turn and walk towards target
		actor_turnto(my_angle.PAN);
		actor_move();

		// Wait one tick, then repeat
		wait(1);
	}
}

///////////////////////////////////////////////////////////////////////
// helper actions

// Desc: initialize a walking actor
function actor_init()
{
	if (my._FORCE == 0) {  my._FORCE = 1; }
	if (my._MOVEMODE == 0) { my._MOVEMODE = _MODE_WALKING; }
	if (my._WALKFRAMES == 0) { my._WALKFRAMES = 1; }
	if (my._WALKSOUND == 0) { my._WALKSOUND = _SOUND_WALKER; }
	anim_init();
}

// Desc: turn towards a destination angle
// force must be set to 0.5..5
function actor_turnto(angle)
{
	angle = ang(angle - MY.PAN);

	if (angle > 10)
	{
		temp = force * 5;
	}
	else
	{
		if(angle < -10)
		{
			temp = -force * 5;
		}
		else
		{
			temp = force * angle * 0.5;
		}
	}

// Now change MY angles
	MY.PAN += temp * min(1,time);
}

// Desc: move ahead, according to force.X
//
//]- Mod Date: 7/5/00 by DCP
//]-				Changed to function
function actor_move()
{
	force.X = 0;
	//force.Y = 10;
	//force.Z = 10;

	// find ground below
	//scan_floor();
	//move_gravity();
	//actor_anim();
}

// Desc: follow the player
//
// uses _FORCE, _MOVEMODE, _WALKFRAMES, _RUNFRAMES, _WALKSOUND
action actor_follow
{
	if(MY._FORCE == 0) {  MY._FORCE = 2; }
	if(MY._MOVEMODE == 0) { MY._MOVEMODE = _MODE_WALKING; }
	if(MY._WALKFRAMES == 0) { MY._WALKFRAMES = DEFAULT_WALK; }
	if(MY._RUNFRAMES == 0) { MY._RUNFRAMES = DEFAULT_RUN; }
	if(MY._WALKSOUND == 0) { MY._WALKSOUND = _SOUND_WALKER; }
	anim_init();

	while(1)
	{
		// calculate a direction to walk into
		temp.X = player.X - MY.X;
		temp.Y = player.Y - MY.Y;
		temp.Z = 0;
		vec_to_angle(MY_ANGLE,temp);  // 10/31/00 replace TO_ANGLE

		// turn towards player
		MY_ANGLE.TILT = 0;
		MY_ANGLE.ROLL = 0;
		force = MY._FORCE * 2;
		actor_turn();

		// walk towards him
		force = MY._FORCE;
		MY._MOVEMODE = _MODE_WALKING;
		actor_move();

		WAIT(1);
	}
}


//]- Mod Date: 7/5/00 by DCP
//]-				Changed to function
//]- Mod Date: 6/21/01 by DCP
//]-			Added wait(1) before remove
// Desc: network code, remove actor on disconnect event
function _actor_connect()
{
	if(EVENT_TYPE == EVENT_DISCONNECT) { wait(1); ent_remove(ME); }
}

// Desc: PAN towards target angle MY_ANGLE, according to force
//
//]- Mod Date: 6/27/00 Doug Poston
//]-				Replaced ACCEL
//]- Mod Date: 7/4/00 Doug Poston
//]-				TIME corrected
//]- Mod Date: 7/5/00 by DCP
//]-				Changed to function
//]-				Removed aforce.PAN and aforce.TILT
function actor_turn()
{
	temp = ANG(MY_ANGLE.PAN - MY.PAN);
	if(temp > 5)
	{
		aforce.PAN = force;
	}
	else
	{
		if(temp < -5)
		{
			aforce.PAN = -force;
		}
		else
		{
			aforce.PAN = force * temp * 0.25;
		}
	}

	// Now accelerate the angular speed, and change MY angles
	// -old method- ACCEL	MY._ASPEED,aforce,ang_fric;
	temp = min(TIME*ang_fric,1);
	MY._ASPEED_PAN  += (TIME * aforce.pan)  - (temp * MY._ASPEED_PAN);

	MY.PAN += MY._ASPEED_PAN  * TIME;
}

// Desc: Find next start position
//
//]- Mod Date: 7/5/00 by DCP
//]-				Changed to function
function _scan_target()
{
	// scan from old target
	MY_POS.X = MY._TARGET_X;
	MY_POS.Y = MY._TARGET_Y;
	MY_POS.Z = MY._TARGET_Z;
	MY_ANGLE.PAN = MY._TARGET_PAN;
	MY_ANGLE.TILT = 0;
	scan_sector.TILT = 90;
	scan_sector.Z = 2000;
	SCAN_POS MY_POS,MY_ANGLE,scan_sector;
	if(RESULT > 0)
	{
		// if found, set new target
		MY._TARGET_X = MY_POS.X;
		MY._TARGET_Y = MY_POS.Y;
		MY._TARGET_Z = MY_POS.Z;
		MY._TARGET_PAN = MY_ANGLE.PAN;
		MY._MOVEMODE = _MODE_WALKING;
	}
	else
	{
		MY._MOVEMODE = 0;
	}
}
//////////////////////////////////////////////////////////////////////