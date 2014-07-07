// Template file v5.202 (02/20/02)
////////////////////////////////////////////////////////////////////////
// File: move.wdl
//		WDL prefabs for player movement
////////////////////////////////////////////////////////////////////////
// Use:
//		Include AFTER "movment.wdl"
//
//]- Created: 06/15/01 DCP
//]-
//]- Mod Date: 07/27/01 DCP
//]-		wade_gravity(): Updated wading forces to reflect my_height_passable
//]-
//]- Mod Date: 08/08/01 DCP
//]-		player_move: Fixed '1 frame swim to wade' problem when entering
//]-			water.
//]-
//]- Mod Date: 12/18/01
//]-		Added WED 'uses' comments to all WED editable fields
//
// Mod Date: 02/12/02 DCP
//			player_move(): Increased distance (by 3) that entity must be "above"
//		a passable surface to not swim.
//
// Mod Date: 02/20/02 DCP
//			move_gravity(): Improved jumping code (no longer frame rate dependent)
//
// Mod Date: 04/22/02 DCP
//			changed player_move & client_move
//			added _player_rotate
//       Changes made to reduce latency on multiplayer games. Rotation is
//		handled on the client and the resulting rotation is sent to the server
//		(along with the forces).
//
// Mod Date: 09/19/02 JCL
//    changed _player_rotate, player_move2, client_move
//    Fixed a bug with the pan angle jittering, and added tilt in multiplayer


//@ Move Defines


//@ Move Vars

//@ Move Actions
//	Each of these three actions call 'player_move'
//		player_walk -	player walk (basic move) action
//		player_swim -	player swim action
//		player_drive -	player drive action


/////////////////////////////////////////////////////////////////////////
// Desc: player walk action
//
//]- Mod Date: 8/31/00 DCP
//]-		Scale the player by vec_scale
//
// no WED defined skills
// uses _WALKFRAMES, _RUNFRAMES, _WALKSOUND
/*
ACTION player_walk
{
	MY._MOVEMODE = _MODE_WALKING;
	MY._FORCE = 0.75;
	MY._BANKING = -0.1;
	MY.__JUMP = ON;
	MY.__DUCK = ON;
	MY.__STRAFE = ON;
	MY.__BOB = ON;
	MY.__TRIGGER = ON;

	player_move();
}
*/
/////////////////////////////////////////////////////////////////////////
// Desc: player swim action
//
// uses _WALKFRAMES, _RUNFRAMES, _WALKSOUND
/*
ACTION player_swim
{
	MY._MOVEMODE = _MODE_SWIMMING;
	MY._FORCE = 0.75;
	MY._BANKING = 0;
	MY.__JUMP = ON;
	MY.__DUCK = ON;
	MY.__STRAFE = OFF;
	MY.__BOB = ON;

	player_move();
}
*/
/////////////////////////////////////////////////////////////////////////
// Desc: player drive action
//
//]- Mod Date: 8/31/00 DCP
//]-		Scale the player by vec_scale
//
// uses _WALKFRAMES, _RUNFRAMES, _WALKSOUND
/*
ACTION player_drive
{
	MY._MOVEMODE = _MODE_DRIVING;
	MY._FORCE = 1.5;
	MY._BANKING = 0.5;
	MY.__SLOPES = ON;
	MY.__TRIGGER = ON;

	player_move();
}

*/

//@ Move Function Protypes
//ACTION player_move  - This is the main movement function, it handles the player movement
//@@ player_move helper functions
function move_gravity();	// handle movement on solids
function wade_gravity();	// handle movement while wading
function swim_gravity();	// handle movement in passables
function scan_floor();		// scan surface under ME entity, sets values (also called from actor_move)
function	fall_damage();		// return damage from falling
function _player_force();	// set the values for force and aforce

function client_move();	// handles client entity movement


function move_airborne();	// Airborne movement function


//@ Move Functions

// Desc: code to handle rotation of the player.
function	_player_rotate()
{
		my = player;
		// accelerate the angular speed, and change his angles
		temp = max(1-TIME*ang_fric,0);     // replaced min with max (to eliminate 'creep')
		MY._ASPEED_PAN  = (TIME * aforce.pan)  + (temp * MY._ASPEED_PAN);    // vp = ap * dt + max(1-(af*dt),0)  * vp
		MY._ASPEED_TILT = (TIME * aforce.tilt) + (temp * MY._ASPEED_TILT);
		MY._ASPEED_ROLL = (TIME * aforce.roll) + (temp * MY._ASPEED_ROLL);

  		temp = MY._ASPEED_PAN * MY._SPEED_X * 0.05;
		if(MY.__WHEELS)
		{
			// Turn only if moving ahead
			my.pan += temp * time;
		}
		else
		{
			my.pan += my._aspeed_pan * time;
		}
		my.roll += (temp * MY._BANKING + MY._ASPEED_ROLL) * time;

// set the camera tilt angle for the player
		head_angle.tilt += my._ASPEED_TILT * time;

// Limit the TILT value
		head_angle.tilt = ang(head_angle.tilt);
		if(head_angle.tilt > 80) { head_angle.tilt = 80; }
		if(head_angle.tilt < -80) { head_angle.tilt = -80; }
}

////////////////////////////////////////////////////////////////////////
// Desc: main player movement action
//			called from 'player_walk', 'player_drive', & 'player_swim'
//
//]- Mod Date: 5/10/00 @ 973 Doug Poston
//]-           Added code to handle swimming
//]- Mod Date: 5/11/00 @ 097 Doug Poston
//]-           Added code to handle ducking and crawling
//]- Mod Date: 5/16/00  Doug Poston
//]-				 Modified underwater fog code
//]-				 Modified player MIN_Z (when getting in & out of water)
//]-				 Fixed so you can no longer crawl over water
//]- Mod Date: 5/16/00 Doug Poston
//]-				 Returned fog control back to the camera views
//]- Mod Date: 5/18/00 Doug Poston
//]-				 Removed MIN_Z modifications (too easy to get stuck in objects)
//]-Mod Date: 5/25/00 Doug Poston
//]-				 Using an 'offset sonar' (7 units) while swimming to check if
//]-				the player is ON_PASSABLE
//]-Mod Date: 5/29/00 Doug Poston
//]-				 Change 'offset sonar' from 7 to 16 units
//]-Mod Date: 6/5/00 Doug Poston
//]-				 Removed Sets
//]-Mod Date: 6/27/00 Doug Poston
//]-				 Replaced ACCEL
//]-Mod Date: 6/29/00 Doug Poston
//]-				Remove IN_PASSABLE check for wading (fixed in v4.193)
//]-Mod Date: 10/31/00 Doug Poston
//]-				Replaced min with max in ASPEED (to eliminate 'creep')
//]-Mod Date: 11/1/00 DCP
//]-				Replace SHOOT with trace() and VECROTATE with vec_rotate
//]-Mod Date: 11/10/00 DCP
//]-				Edited code dealing with swimming (collision info has changed)
//]-Mod Date: 02/09/01 DCP
//]-				If entering passable block stop falling (MY._SPEED_Z = 0)
//]-Mod Date: 02/11/01 DCP
//]-				Use "my_height_passable" for passable blocks (fixed wading)
//]-Mod Date: 05/30/01 DCP
//]-			  	Changed -MY.MIN_Z + 5 to -MY.MIN_Z + 6 in "swim check" to
//]-	      replace '<=' compare with '<' (do NOT use '<=', '>=', or '==' to compare
//]-	      non-int values).
//]-Mod Date: 05/31/01 DCP
//]-      	Use 'content()' to check for switch from wade to swim
//]-				No longer change from wade to swim if still over water
//]-
//]- Mod Date: 06/12/01 DCP
//]-				Move 'actor_anim()' call inside if(MY._MOVEMODE != _MODE_STILL)
//]-			block.
//]-
//]- Mod Date: 08/08/01 DCP
//]-				Added an offset by "my_height_passable" when checking to see if the
//]-			players is wading. Fixes '1 frame swim to wade' problem when entering
//]-			water.
//]-
//]- Mod Date: 02/12/02 DCP
//]-				Increased distance that entity must be "above" a passable surface
//]-			to not swim (previous vers allowed "Jesus Walk")
//
//	Mod Date: 04/16/02 DCP
//		player rotation is handle in a seperate funtion ("_player_rotate()")
//		player rotation is handled on the client, not the server
//
// uses _FORCE, _MOVEMODE, _BANKING, _WALKFRAMES, _RUNFRAMES, _WALKSOUND
// uses __FALL, __WHEELS, __SLOPES, __JUMP, __DUCK, __STRAFE, __BOB, __TRIGGER
/*
ACTION player_move
{
	if(MY.CLIENT == 0) { player = ME; } // created on the server?

	MY._TYPE = _TYPE_PLAYER;
	MY.ENABLE_SCAN = ON;	// so that enemies can detect me
	if((MY.TRIGGER_RANGE == 0) && (MY.__TRIGGER == ON)) { MY.TRIGGER_RANGE = 32; }

	if(MY._FORCE == 0) {  MY._FORCE = 1.5; }
	if(MY._MOVEMODE == 0) { MY._MOVEMODE = _MODE_WALKING; }
	if(MY._WALKFRAMES == 0) { MY._WALKFRAMES = DEFAULT_WALK; }
	if(MY._RUNFRAMES == 0) { MY._RUNFRAMES = DEFAULT_RUN; }
	if(MY._WALKSOUND == 0) { MY._WALKSOUND = _SOUND_WALKER; }

	anim_init();      // init old style animation
	perform_handle();	// react on pressing the handle key


	// while we are in a valid movemode
	while((MY._MOVEMODE > 0)&&(MY._MOVEMODE <= _MODE_STILL))
	{
		// if we are not in 'still' mode
		if(MY._MOVEMODE != _MODE_STILL)
		{
			// Get the angular and translation forces (set aforce & force values)
			_player_force();

			// is this movement "local"?
			if(client_moving == 0)
			{
				// rotate the player
				_player_rotate();
			}

			// find ground below (set my_height, my_floornormal, & my_floorspeed)
			scan_floor();

			// if they are on or in a passable block...
			if( ((ON_PASSABLE != 0) && (my_height_passable < (-MY.MIN_Z + 19)))    // upped from 16 to 19 (3q 'buffer')
				|| (IN_PASSABLE != 0) )
			{

				// if not already swimming or wading...
				if((MY._MOVEMODE != _MODE_SWIMMING) && (MY._MOVEMODE != _MODE_WADING))
				{
  					//play_sound(splash,50);
  					MY._MOVEMODE = _MODE_SWIMMING;
//---					actor_anim_transition(anim_swim_str);	//!!!!!

					// stay on/near surface of water
					MY._SPEED_Z = 0;
  				}

				// if swimming...
  				if(MY._MOVEMODE == _MODE_SWIMMING) // swimming on/in a passable block
				{
					if(ON_PASSABLE == ON) // && (IN_PASSABLE != ON)) -> Not need with version 4.193+
					{
						// check for wading
						temp.X = MY.X;
    					temp.Y = MY.Y;
    		  			temp.Z = MY.Z + MY.MIN_Z - my_height_passable;	// can my feet touch? (mod: 080801)
						trace_mode = IGNORE_ME + IGNORE_PASSABLE + IGNORE_PASSENTS;
						trace(MY.POS,temp);

						if(RESULT > 0)
						{
							// switch to wading
							MY._MOVEMODE = _MODE_WADING;
 				 			MY.TILT = 0;       // stop tilting
							my_height = RESULT + MY.MIN_Z;	// calculate wading height
//---							actor_anim_transition(anim_wade_str);	//!!!!!
						}

 					}

				}// END swimming on/in a passable block
				else
				{	// not swimming

					// if wading...
 					if(MY._MOVEMODE == _MODE_WADING) // wading on/in a passable block
					{
  						// if model center is in the water switch to swimming mode
						result = content(MY.POS);
						if (result == content_passable)
						{
							// switch to swimming
							MY._MOVEMODE = _MODE_SWIMMING;
						}
						else	// use SOLID surface for height (can't walk on water)
						{
  							// get height to solid underwater surface
							temp.X = MY.X;
    						temp.Y = MY.Y;
    						temp.Z = MY.Z - 1000;//-- + MY.MIN_Z;	// can my feet touch?

							trace_mode = IGNORE_SPRITES + IGNORE_ME + IGNORE_PASSABLE + IGNORE_PASSENTS;
							result = trace(MY.POS,temp);
  							my_height = RESULT + MY.MIN_Z;    // calculate wading height
						}
					} // END wading on/in a passable block
				}



	 		} // END if they are on or in a passable block...
			else  // not in or on a passable block
			{
				// if wading or swimming while *not* on/in a passable block...
				if(   (MY._MOVEMODE == _MODE_SWIMMING)
					|| ( (ON_PASSABLE == 0) && (MY._MOVEMODE == _MODE_WADING) )
				  )
				{
					// get out of the water (go to walk mode)
					MY._MOVEMODE = _MODE_WALKING;
					MY.TILT = 0;       // stop tilting
				}
 			} // END not in or above water


  			// if he is on a slope, change his angles, and maybe let him slide down
			if(MY.__SLOPES == ON)
			{
				// Adapt the player angle to the floor slope
				MY_ANGLE.TILT = 0;
				MY_ANGLE.ROLL = 0;
				if((my_height < 10) && ((my_floornormal.X != 0) || (my_floornormal.Y != 0) ))
				{	// on a slope?
					// rotate the floor normal relative to the player
					MY_ANGLE.PAN = -MY.PAN;
					vec_rotate(my_floornormal,MY_ANGLE);
					// calculate the destination tilt and roll angles
					MY_ANGLE.TILT = -ASIN(my_floornormal.X);
					MY_ANGLE.ROLL = -ASIN(my_floornormal.Y);
				}
				// change the player angles towards the destination angles
				MY.TILT += 0.2 * ANG(MY_ANGLE.TILT-MY.TILT);
				MY.ROLL += 0.2 * ANG(MY_ANGLE.ROLL-MY.ROLL);
			}
			else
			{
				// If the ROLL angle was not equal to zero,
				// apply a ROLL force to set the angle back
				//jcl 07-08-00 fix loopings on < 3 fps systems
				MY.ROLL -= 0.2*ANG(MY.ROLL);
			}
/*
/*
MOVED INTO function _player_rotate()!!!
// CODE for handling rotation
			// Now accelerate the angular speed, and change his angles
			temp = max(1-TIME*ang_fric,0);     // replaced min with max (to eliminate 'creep')
			MY._ASPEED_PAN  = (TIME * aforce.pan)  + (temp * MY._ASPEED_PAN);    // vp = ap * dt + max(1-(af*dt),0)  * vp
			MY._ASPEED_TILT = (TIME * aforce.tilt) + (temp * MY._ASPEED_TILT);
			MY._ASPEED_ROLL = (TIME * aforce.roll) + (temp * MY._ASPEED_ROLL);

  			temp = MY._ASPEED_PAN * MY._SPEED_X * 0.05;
			if(MY.__WHEELS)
			{	// Turn only if moving ahead
				//jcl 07-03-00 patch to fix movement
				MY.PAN += temp * TIME;
			}
			else
			{
				MY.PAN += MY._ASPEED_PAN * TIME;
			}
			MY.ROLL += (temp * MY._BANKING + MY._ASPEED_ROLL) * TIME;

			// the head angle is only set on the player in a single player system.
			if (ME == player)
			{
				head_angle.TILT += MY._ASPEED_TILT * TIME;
				//jcl 07-03-00 end of patcht

				// Limit the TILT value
				head_angle.TILT = ang(head_angle.TILT);
				if(head_angle.TILT > 80) { head_angle.TILT = 80; }
				if(head_angle.TILT < -80) { head_angle.TILT = -80; }
			}
*/
/*
			// disable strafing
			if(MY.__STRAFE == OFF)
			{
				force.Y = 0;	// no strafe
			}


			// if swimming...
			if(MY._MOVEMODE == _MODE_SWIMMING)
			{
 				// move in water
  				swim_gravity();
			}
			else // not swimming
			{
				// if wading...
				if(MY._MOVEMODE == _MODE_WADING)
				{
					wade_gravity();
				}
				else // not swimming or wading (not in water)
				{
					// Ducking or crawling...
					if((MY._MOVEMODE == _MODE_DUCKING) || (MY._MOVEMODE == _MODE_CRAWLING))
					{
						if(force.Z >= 0)
						{
							MY._MOVEMODE = _MODE_WALKING;
						}
						else	// still ducking
						{
							// reduce height by ducking value
							my_height += duck_height;
						}

					}
					else  // not ducking or crawling
					{
						// if we have a ducking force and are not already ducking or crawling...
						if((force.Z < 0) && (MY.__DUCK == ON))		// dcp 7/28/00 added __DUCK
						{
							// ...switch to ducking mode
							MY._MOVEMODE = _MODE_DUCKING;
							MY._ANIMDIST = 0;
							force.Z = 0;
						}
					}

					// Decide whether the actor can jump or not. He can't if he is in the air
					if((jump_height <= 0)
						|| (MY.__JUMP == OFF)
						|| (my_height > 4)
						|| (force.Z <= 0))
					{
						force.Z = 0;
					}

					// move on land
					move_gravity();
				}  // END (not in water)
			}// END not swimming

		} // END not in 'still' mode

//		if(MY._MOVEMODE != _MODE_TRANSITION)
//		{
		// animate the actor
		actor_anim();
//		}

		// If I'm the only player, draw the camera and weapon with ME
		if(client_moving == 0) { move_view(); }

		carry();		// action pointer used to carry items with the player (eg. a gun or sword)

		// Wait one tick, then repeat
		wait(1);
	}  // END while((MY._MOVEMODE > 0)&&(MY._MOVEMODE <= _MODE_STILL))
} // end ACTION player_move
*/

// Desc: advanced player movement function.
//			uses advanced blended animation
// Mod: 121102  Added 3rd person walking sound


function player_move2()
{
	var sound_dist;    // used to play walking noise

	if(MY.CLIENT == 0) { player = ME; } // created on the server?

	MY._TYPE = _TYPE_PLAYER;
	MY.ENABLE_SCAN = ON;	// so that enemies can detect me
	if((MY.TRIGGER_RANGE == 0) && (MY.__TRIGGER == ON)) { MY.TRIGGER_RANGE = 32; }

	if(MY._FORCE == 0) {  MY._FORCE = 1.5; }
	if(MY._MOVEMODE == 0) { MY._MOVEMODE = _MODE_WALKING; }
	if(MY._WALKFRAMES == 0) { MY._WALKFRAMES = DEFAULT_WALK; }
	if(MY._RUNFRAMES == 0) { MY._RUNFRAMES = DEFAULT_RUN; }
	if(MY._WALKSOUND == 0) { MY._WALKSOUND = _SOUND_WALKER; }

  //--	anim_init();      // init old style animation
	perform_handle();	// react on pressing the handle key

	actor_adv_anim2();	// use new animation style (with blending)


	// while we are in a valid movemode
	while((MY._MOVEMODE > 0)&&(MY._MOVEMODE <= _MODE_STILL))
	{
		// check signal from actor_adv_anim2() to see if we have finished a previous state...
		if(my._ANIMDIST == -99)
		{
			if(MY._MOVEMODE == _MODE_JUMPING)
			{
				// exit from jumping state
				my._ANIMDIST = 0;	// signal that we have recieved the flag
				MY._MOVEMODE = _MODE_WALKING;
			}

/* ducking/crawling is handled like stand/walk/run is
			if(MY._MOVEMODE == _MODE_DUCKING)
			{
				// exit from ducking state
				MY._MOVEMODE = _MODE_CRAWLING;;
			}
 */
		}// end check singal returned from actor_adv_anim2()


		// if we are not in 'still' mode
		if(MY._MOVEMODE != _MODE_STILL)
		{
			// Get the angular and translation forces (set aforce & force values)
			_player_force();

			// is this movement "local"?
			if(client_moving == 0)
			{
				// rotate the player
				_player_rotate();
			}

			// find ground below (set my_height, my_floornormal, & my_floorspeed)
			scan_floor();

			// if they are on or in a passable block...
			if( ((ON_PASSABLE != 0) && (my_height_passable < (-MY.MIN_Z + 19)))    // upped from 16 to 19 (3q 'buffer')
				|| (IN_PASSABLE != 0) )
			{

				// if not already swimming or wading...
				if((MY._MOVEMODE != _MODE_SWIMMING) && (MY._MOVEMODE != _MODE_WADING))
				{
  					//play_sound(splash,50);
  					MY._MOVEMODE = _MODE_SWIMMING;

					// stay on/near surface of water
					MY._SPEED_Z = 0;
  				}

				// if swimming...
  				if(MY._MOVEMODE == _MODE_SWIMMING) // swimming on/in a passable block
				{
					if(ON_PASSABLE == ON) // && (IN_PASSABLE != ON)) -> Not need with version 4.193+
					{
						// check for wading
						temp.X = MY.X;
    					temp.Y = MY.Y;
    		  			temp.Z = MY.Z + MY.MIN_Z - my_height_passable;	// can my feet touch? (mod: 080801)
						trace_mode = IGNORE_ME + IGNORE_PASSABLE + IGNORE_PASSENTS;
						trace(MY.POS,temp);

						if(RESULT > 0)
						{
							// switch to wading
							MY._MOVEMODE = _MODE_WADING;
 				 			MY.TILT = 0;       // stop tilting
							my_height = RESULT + MY.MIN_Z;	// calculate wading height
						}

 					}

				}// END swimming on/in a passable block
				else
				{	// not swimming

					// if wading...
 					if(MY._MOVEMODE == _MODE_WADING) // wading on/in a passable block
					{
  						// if model center is in the water switch to swimming mode
						result = content(MY.POS);
						if (result == content_passable)
						{
							// switch to swimming
							MY._MOVEMODE = _MODE_SWIMMING;
						}
						else	// use SOLID surface for height (can't walk on water)
						{
  							// get height to solid underwater surface
							temp.X = MY.X;
    						temp.Y = MY.Y;
    						temp.Z = MY.Z - 1000;//-- + MY.MIN_Z;	// can my feet touch?

							trace_mode = IGNORE_SPRITES + IGNORE_ME + IGNORE_PASSABLE + IGNORE_PASSENTS;
							result = trace(MY.POS,temp);
  							my_height = RESULT + MY.MIN_Z;    // calculate wading height
						}
					} // END wading on/in a passable block
				}



	 		} // END if they are on or in a passable block...
			else  // not in or on a passable block
			{
				// if wading or swimming while *not* on/in a passable block...
				if(   (MY._MOVEMODE == _MODE_SWIMMING)
					|| ( (ON_PASSABLE == 0) && (MY._MOVEMODE == _MODE_WADING) )
				  )
				{
					// get out of the water (go to walk mode)
					MY._MOVEMODE = _MODE_WALKING;
					MY.TILT = 0;       // stop tilting
				}
 			} // END not in or above water


  			// if he is on a slope, change his angles, and maybe let him slide down
			if(MY.__SLOPES == ON)
			{
				// Adapt the player angle to the floor slope
				MY_ANGLE.TILT = 0;
				MY_ANGLE.ROLL = 0;
				if((my_height < 10) && ((my_floornormal.X != 0) || (my_floornormal.Y != 0) ))
				{	// on a slope?
					// rotate the floor normal relative to the player
					MY_ANGLE.PAN = -MY.PAN;
					vec_rotate(my_floornormal,MY_ANGLE);
					// calculate the destination tilt and roll angles
					MY_ANGLE.TILT = -ASIN(my_floornormal.X);
					MY_ANGLE.ROLL = -ASIN(my_floornormal.Y);
				}
				// change the player angles towards the destination angles
				MY.TILT += 0.2 * ANG(MY_ANGLE.TILT-MY.TILT);
				MY.ROLL += 0.2 * ANG(MY_ANGLE.ROLL-MY.ROLL);
			}
			else
			{
				// If the ROLL angle was not equal to zero,
				// apply a ROLL force to set the angle back
				//jcl 07-08-00 fix loopings on < 3 fps systems
				MY.ROLL -= 0.2*ANG(MY.ROLL);
			}

/*MOVED INTO function _player_rotate()!!!
			// the head angle is only set on the player in a single player system.
			if (ME == player)
			{
				head_angle.TILT += MY._ASPEED_TILT * TIME;
				//jcl 07-03-00 end of patcht

				// Limit the TILT value
				head_angle.TILT = ang(head_angle.TILT);
				if(head_angle.TILT > 80) { head_angle.TILT = 80; }
				if(head_angle.TILT < -80) { head_angle.TILT = -80; }
			}
*/
			// disable strafing
			if(MY.__STRAFE == OFF)
			{
				force.Y = 0;	// no strafe
			}


			// if swimming...
			if(MY._MOVEMODE == _MODE_SWIMMING)
			{
 				// move in water
  				swim_gravity();
			}
			else // not swimming
			{
				// if wading...
				if(MY._MOVEMODE == _MODE_WADING)
				{
					wade_gravity();
				}
				else // not swimming or wading (not in water)
				{
					// Ducking or crawling...
					if((MY._MOVEMODE == _MODE_DUCKING) || (MY._MOVEMODE == _MODE_CRAWLING))
					{
  		 				temp2 = (frc(-MY._ADVANIM_DIST)<<10);// walk_or_run
   					// you can only duck at walking speeds or below.
						if((my_dist >= temp2*TIME*movement_scale)	// to fast to duck?
							|| (force.Z >= 0)) // player chooses to stand up
						{
							MY._MOVEMODE = _MODE_WALKING; // catch the walking mode below this one
 						}
						else	// still ducking
						{
							// reduce height by ducking value
							my_height += duck_height;
						}

					}
					else  // not ducking or crawling
					{
						// if we have a ducking force and are not already ducking or crawling...
						if((force.Z < 0) && (MY.__DUCK == ON))		// dcp 7/28/00 added __DUCK
						{
							// ...switch to ducking mode
							MY._MOVEMODE = _MODE_DUCKING;
						//--	MY._ANIMDIST = 0;
							force.Z = 0;
						}
					}

					// Decide whether the actor can jump or not. He can't if he is in the air
					if((jump_height <= 0)
						|| (MY.__JUMP == OFF)
						|| (my_height > 4)
						|| (force.Z <= 0))
					{
						force.Z = 0;
					}

					// move on land
					move_gravity();
				}  // END (not in water)
			}// END not swimming

		} // END not in 'still' mode

		// play walking sound as needed...
		if((person_3rd>0)  // using a 3rd person camera and..
			&& (my._MOVEMODE == _MODE_WALKING))  // walking
		{
			sound_dist += my_dist;
			if(sound_dist > 50)
			{
				//play_sound(thud,30);
				sound_dist = 0;
			}
		}

 		// set movment amount
		if(force.X < 0)
		{
			// moving backwards
			my._WALKDIST = -my_dist;	// my_dist is set in move_gravity, wade_gravity, or swim_gravity
		}
		else
		{
			// moving forward, sideways, or standing still
			my._WALKDIST = my_dist;		// my_dist is set in move_gravity, wade_gravity, or swim_gravity
		}
		// If I'm the only player, draw the camera and weapon with ME
		if(client_moving == 0) { move_view(); }



		carry();		// action pointer used to carry items with the player (eg. a gun or sword)

		// Wait one tick, then repeat
		wait(1);
	}  // END while((MY._MOVEMODE > 0)&&(MY._MOVEMODE <= _MODE_STILL))
} // end function player_move2



/////////////////////////////////////////////////////////////////////////
// Desc: on ground movement action
//			use when player is not swimming or wading
//
//]- Mod Date: 5/10/00 @ 942 by Doug Poston
//]-				Added code to switch to jumping mode when needed
//]- Mod Date: 5/25/00 by Doug Poston
//]-				Split MOVE into two, so my_dist is now a function of player
//]-			  movement only (ie. not effected by elevators or platforms)
//]- Mod Date: 6/19/00 by Doug Poston
//]-          Added falling damage.
//]-				_FALLTIME keeps track of the time spent falling
//]-				if __FALL is set, damage is taken when landing
//]- Mod Date: 6/27/00 Doug Poston
//]-				Replace ACCEL (x2)
//]- Mod Date: 7/3/00 JCL
//]-				quick patch to fix movement for Adeptus
//]- Mod Date: 7/3/00 DCP
//]-				Modified code so speed and distance are TIME dependent
//]- Mod Date: 7/18/00 DCP
//]-				Removed time dependence on forces
//]-				Changed slope gravity
//]- Mod Date: 7/19/00 DCP
//]-				Changed jumping code so player always jumps to the same height
//]- Mod Date: 8/10/00 JCL
//]-				Changed 'airborne' force values to prevent entities from 'sticking'
//]- Mod Date: 8/10/00 JCL
//]-      		"bring to ground level - only if slope not too steep"
//]- Mod Date: 8/10/00 DCP
//]-				Replace fall damge formula with call to 'fall_damage'
//]- Mod Date: 8/31/00 DCP
//]-				Scale dist and absdist by movement_scale before MOVE command
//]- Mod Date: 11/9/00 DCP
//]- 			Replaced the double MOVE with a single MOVE and a distance check
//]- Mod Date: 01/16/01 JCL
//]-				Removed absdist movement_scale because absdist is calculated from external forces
//]-				Apply movement_scale to jumping force only
//]- Mod Date: 06/08/01 DCP
//]-				Replace move() with ent_move()
//]- Mod Date: 08/22/01 DCP
//]-				Added a Check for ducking and crawling when adding to _FALLTIME
//]-
//]- Mod Date: 02/20/02 DCP
//]-				Improved jumping code (no longer frame dependent)
//]-
//]- Mod Date: 04/30/02 DCP
//]-				Removed animation setting from the beginning of the jump section
//]-				Fixed bug in forces when the player in ducking (caused player
//]-			to get 'stuck' while ducking).
// Mod Date: 10/01/02  DCP
//			Modified 'bring to ground level' code to be time corrected and bound.


function move_gravity()
{
	// Filter the forces and frictions dependent on the state of the actor,
	// and then apply them, and move him

	// First, decide whether the actor is standing on the floor or not
	if(my_height < 5)
	{
		// Calculate falling damage
 		if((MY.__FALL == ON) && (MY._FALLTIME > fall_time))
  		{
			MY._HEALTH -= fall_damage();		// take damage depending on fall_time
 		}
		MY._FALLTIME = 0; 	// reset falltime

		friction = gnd_fric;
		if(MY._MOVEMODE == _MODE_DRIVING)
		{
			// Driving - less friction, less force
			friction *= 0.3;
			force.X *= 0.3;
		}

		// reset absolute forces
		absforce.X = 0;
		absforce.Y = 0;
		absforce.Z = 0;

		// If on a slope, apply gravity to draw him downwards:
		if(my_floornormal.Z < 0.9)
		{
			// reduce ahead force because player force it is now deflected upwards
			force.x *= my_floornormal.z;
			force.y *= my_floornormal.z;
			// gravity draws him down the slope
			absforce.X = my_floornormal.x * gravity * slopefac;
			absforce.Y = my_floornormal.y * gravity * slopefac;
		}
	}
	else	// (my_height >= 5)
	{
		if((MY._MOVEMODE == _MODE_DUCKING) || (MY._MOVEMODE == _MODE_CRAWLING))
		{
			friction = gnd_fric;	// ducking and crawling are handled differently
		}
		else
		{
			// airborne - reduce all relative forces
			// to prevent him from jumping or further moving in the air
			friction = air_fric;
			//jcl 10-08-00
			force.X *= 0.2; // don't set the force completely to zero, otherwise
			force.Y *= 0.2; // player could be stuck on top of a non-wmb entity
			force.Z = 0;
		}

		absforce.X = 0;
		absforce.Y = 0;
		// Add the world gravity force
		absforce.Z = -gravity;

		// only falling if moving downward (but not if ducking)
		if( (MY._SPEED_Z <= 0) && ((MY._MOVEMODE != _MODE_DUCKING) && (MY._MOVEMODE != _MODE_CRAWLING)) )
		{
			MY._FALLTIME += TIME;   // add falling time
		}
	}

	// accelerate the entity relative speed by the force
 	// replaced min with max (to eliminate 'creep')
	temp = max((1-TIME*friction),0);
	MY._SPEED_X = (TIME * force.x) + (temp * MY._SPEED_X);    // vx = ax*dt + max(1-f*dt,0) * vx
	MY._SPEED_Y = (TIME * force.y) + (temp * MY._SPEED_Y);    // vy = ay*dt + max(1-f*dt,0) * vy
	MY._SPEED_Z = (TIME * absforce.z) + (temp * MY._SPEED_Z);

	// calculate relative distances to move
	dist.x = MY._SPEED_X * TIME;  	// dx = vx * dt
	dist.y = MY._SPEED_Y * TIME;     // dy = vy * dt
	dist.z = 0;                      // dz = 0  (only gravity and jumping)

	// calculate absolute distance to move
	// NOTE: changed absforce from d=f*dt^2 to d=f*dt because the absforce calculated
	//from the slope is not an 'actual' force.
	absdist.x = absforce.x * TIME;// * TIME;   // dx = ax*dt^2
	absdist.y = absforce.y * TIME;// * TIME;   // dy = ay*dt^2
	absdist.z = MY._SPEED_Z * TIME;         // dz = vz*dt

	// Add the speed given by the ground elasticity and the jumping force
	if(my_height < 5)
	{
		// bring to ground level - only if slope not too steep
		//jcl 10-08-00
  		if(my_floornormal.Z > slopefac/4)
		{
			//absdist.z = -max(my_height,-10);    // replaced with time corrected and bound version 10/01/02
			absdist.z = -max(my_height,-10*time);
			if((my_height + absdist.z) > 6) // allow a maximum of 6 quant penetration
			{ absdist.z = -my_height -6; }
		}

		// if we have a jumping force...
		if(force.Z > 0)
		{
			MY._JUMPTARGET = jump_height - my_height;	// calculate jump delta

			// ...switch to jumping mode
			MY._MOVEMODE = _MODE_JUMPING;
//--			MY._ANIMDIST = 0;
		}

		// If the actor is standing on a moving platform, add it's horizontal displacement
		absdist.X += my_floorspeed.X;
		absdist.Y += my_floorspeed.Y;
	}

	// if we are still 'jumping'
	if(MY._JUMPTARGET > 0)
	{
		// calculate velocity

		// predict the current speed required to reach the jump height
 		MY._SPEED_Z = sqrt((MY._JUMPTARGET)*2*gravity);

		// scale distance from jump (absdist.z) by movement_scale
		absdist.z = MY._SPEED_Z * TIME * movement_scale;
		MY._JUMPTARGET -= absdist.z;
	}

	// Restrict the vertical distance to the maximum jumping height
	// (scale jump_height by movement_scale)
	if((MY.__JUMP == ON) && (absdist.z > 0) && (absdist.z + my_height > (jump_height * movement_scale)))
	{
		absdist.z = max((jump_height * movement_scale)- my_height,0);
	}

	// Now move ME by the relative and the absolute speed
	YOU = NULL;	// YOU entity is considered passable by MOVE

	vec_scale(dist,movement_scale);	// scale distance by movement_scale
	// jcl: removed absdist scaling because absdist is calculated from external forces
	//--- vec_scale(absdist,movement_scale);	// scale absolute distance by movement_scale


	// Replaced the double MOVE with a single MOVE and a distance check
	move_mode = ignore_you + ignore_passable + ignore_push + activate_trigger + glide;
	result = ent_move(dist,absdist);
	if(result > 0)
	{
		// only use the relative distance traveled (for animation)
		my_dist = vec_length(dist);
	}
	else
	{
		// player is not moving, do not animate
		my_dist = 0;
	}

	// Store the distance for player 1st person head bobbing
	// (only for single player system)
	if(ME == player)
	{
		player_dist += SQRT(dist.X*dist.X + dist.Y*dist.Y);
	}

}


/////////////////////////////////////////////////////////////////////////
// Desc: wading movement action
//       this action should be called when the player is wading (_MODE_WADING)
//
//]- Mod Date: 5/18/00 by Doug Poston
//]-				Created
//]- Mod Date: 5/25/00 by Doug Poston
//]-				Adjusted ground elasticity (so it doesn't force player to swim)
//]- Mod Date: 5/25/00 by Doug Poston
//]-				Adjust player force by water depth (slower the deeper the player is wading)
//]- Mod Date: 5/29/00 Doug Poston
//]-				 Change 'offset sonar' from 7 to 16 units
//]- Mod Date: 6/19/00 Doug Poston
//]-				 Reset _FALLTIME (no falling damage is you land in water)
//]- Mod Date: 6/27/00 Doug Poston
//]-				Replaced ACCEL (x2)
//]- Mod Date: 7/3/00 Doug Poston
//]-				Fixed code so speed and distance are TIME dependent
//]- Mod Date: 8/31/00 DCP
//]-				Scaled dist and absdist by movement_scale before MOVE command
//]- Mod Date: 01/16/01 JCL
//]-				Removed absdist movement_scale because absdist is calculated from external forces
//]- Mod Date: 05/31/01 DCP
//]-				Add gravity to 'pull' player down to underwater surface
//]- Mod Date: 06/08/01 DCP
//]-				Replace move() with ent_move()
//]- Mod Date: 07/27/01 DCP
//]-				Updated wading forces to reflect my_height_passable
function wade_gravity()
{
	// basic friction
	friction = gnd_fric;

	MY._FALLTIME = 0;	// reset falltime (no falling damage in water)

	//adjust player force depending on depth of water
	temp = (my_height_passable / max(1,-MY.MIN_Z));	// MY.min_z can be 0!!
	if(temp < 0.1)	// minimum speed
	{
		temp = 0.1;
	}
	force.X *= temp;
	force.Y *= temp;
	force.Z *= temp;

	// reset absforce
	absforce.X = 0;
	absforce.Y = 0;
	absforce.Z = 0;

	// If on a slope, apply gravity to draw him downwards:
	if(my_floornormal.Z < 0.9)
	{
		// reduce ahead force because player force it is now deflected upwards
		force.x *= my_floornormal.z;
		force.y *= my_floornormal.z;
		// gravity draws him down the slope (but only at 1/4 of above water)
		absforce.X = my_floornormal.x * gravity * slopefac * 0.25;
		absforce.Y = my_floornormal.y * gravity * slopefac * 0.25;
	}

	// -old method- ACCEL	speed,force,friction;
 	// replaced min with max (to eliminate 'creep')
	temp = max((1-TIME*friction),0);
	MY._SPEED_X = (TIME * force.x) + (temp * MY._SPEED_X);    // vx = ax*dt + max(1-f*dt,0) * vx
	MY._SPEED_Y = (TIME * force.y) + (temp * MY._SPEED_Y);    // vy = ay*dt + max(1-f*dt,0) * vy
	MY._SPEED_Z = (TIME * absforce.z) + (temp * MY._SPEED_Z);


	// calculate relative distances
	dist.x = MY._SPEED_X * TIME; 		// dx = vx * dt
	dist.y = MY._SPEED_Y * TIME;     // dy = vy * dt
	dist.z = 0;                      // dz = 0

	// calculate absolute distances
	absdist.x = absforce.x * TIME;// * TIME; 		// dx = ax * dt^2
	absdist.y = absforce.y * TIME;// * TIME;     // dy = ay * dt^2
	absdist.z = 0; // NO JUMPING WHILE WADING

 	// Add the speed given by the ground elasticity
 	if(my_height < -5)
	{
		temp = my_height;
		if(temp < -10)  { temp = -10; }
 		absdist.Z -= (temp - 5);
	}
	else
	{
 		// Pull back down to the underwater surface
		absdist.Z = max(-my_height,-gravity);

	}

	// Now move ME by the relative and the absolute speed
	YOU = NULL;	// YOU entity is considered passable by MOVE
	vec_scale(dist,movement_scale);	// scale distance by movement_scale
	//--vec_scale(absdist,movement_scale);	// scale absolute distance by movement_scale
	move_mode = ignore_you + ignore_passable + ignore_push + activate_trigger + glide;
	result = ent_move(dist,absdist);

	// Store the distance covered, for animation
	my_dist = RESULT;
	// Store the distance for player 1st person head bobbing
	// (only for single player system)
	if(ME == player)
	{
		player_dist = my_dist;
	}
}


/////////////////////////////////////////////////////////////////////////
// Desc: gravity / buoyancy effect on the player in water (IN_PASSABLE)
//       this action should be called when the player is swimming (_MODE_SWIMMING)
//
//]- Created: 05/9/00 @ 863 by Doug Poston
//]-
//]- Mod Date: 5/10/00 @ 913 by Doug Poston
//]-				Added code to TILT the player (allowing them to dive and rise in water)
//]- Mod Date: 5/18/00 by Doug Poston
//]-				Added code to drop player to the surface of the water
//]- Mod Data: 5/24/00 Doug Poston
//]-				 Using an 'offset sonar' (7 units) to check if the player is ON_PASSABLE
//]- Mod Date: 5/29/00 Doug Poston
//]-				 Change 'offset sonar' from 7 to 16 units
//]- Mod Date: 6/19/00 Doug Poston
//]-				 Reset _FALLTIME (no falling damage is you land in water)
//]- Mod Date: 6/27/00 Doug Poston
//]-				Replaced ACCEL
//]- Mod Date: 6/28/00 Doug Poston
//]-				Modified gravity check to handle ON_PASSABLE while IN_PASSABLE
//]- Mod Date: 6/29/00 Doug Poston
//]-				Remove IN_PASSABLE check while ON_PASSABLE (6/28/00 mod) (fixed in v4.193)
//]- Mod Date: 7/3/00 Doug Poston
//]-				Fixed code so forces are now completely TIME dependent
//]- Mod Date: 7/22/00 JCL
//]-				Modified because of changes in scan_floor
//]- Mod Date: 8/31/00 DCP
//]-				Scale dist and absdist by movement_scale before MOVE
//]- Mod Date: 11/9/00 DCP
//]-				Change diving (player no longer rotates)
//]- Mod Date: 01/16/01 JCL
//]-				Removed absdist movement_scale because absdist is calculated from external forces
//]- Mod Date: 02/08/01 DCP
//]-				Changes to "scan_floor"  remove need to offset for hull
//]- Mod Date: 02/09/01 DCP
//]-				Added code to 'surface' section that allows the player to 'hop' out of the water.
//]- Mod Date: 02/11/01 DCP
//]-				Use "my_height_passable" in place of "my_height"
//]- Mod: 06/08/01 DCP
//]-				Replaced move() with ent_move() in "hop out of water" and move section
function swim_gravity()
{
	friction = water_fric;     // set friction to water friction

	MY._FALLTIME = 0;	// no falling damage in water

	// force.Z is used for diving/surfacing
	if(force.Z == 0)
	{
		// level out player
		if(MY.TILT < 0)
		{
			MY.TILT += 3 * TIME;
			if(MY.TILT > 0)
			{
				MY.TILT = 0;
			}
		}
		else
		{
			if(MY.TILT > 0)
			{
				MY.TILT -= 3 * TIME;
				if(MY.TILT < 0)
				{
					MY.TILT = 0;
				}
 			}
		}
	}
	else
	{
		// surface player
		if(force.Z > 0)
		{
			MY.TILT += 3 * TIME;
			if(MY.TILT > 30)
			{
				MY.TILT = 30;
			}
		}
  		else
		{
			// player diving
			MY.TILT -= 3 * TIME;
			if(MY.TILT < -30)
			{
				MY.TILT = -30;
			}
		}
	}

/*	NO absforce needed in this swim_gravity
	// reset absolute forces
  	absforce.X = 0;
	absforce.Y = 0;
	absforce.Z = 0;
*/
	// Swimming - rhythmic acceleration
	force.X *= 0.5 + (0.25*walkwave);
	force.Y *= 0.5;
	force.Z *= 0.025;   // surface/diving force


	// accelerate the entity relative speed by the force
	// replaced min with max (to eliminate 'creep')
	temp = max((1-TIME*friction),0);
	MY._SPEED_X = (TIME * force.x) + (temp * MY._SPEED_X);    // vx = ax*dt - min(f*dt,1) * vx
	MY._SPEED_Y = (TIME * force.y) + (temp * MY._SPEED_Y);    // vy = ay*dt - min(f*dt,1) * vy
	MY._SPEED_Z = (TIME * force.z) + (temp * MY._SPEED_Z);    // vz = az*dt - min(f*dt,1) * vz


	// calculate relative distances
	dist.x = MY._SPEED_X * TIME; 		// dx = vx * dt
	dist.y = MY._SPEED_Y * TIME;     // dy = vy * dt
	dist.z = MY._SPEED_Z * TIME;     // dz = vz * dt


//jcl 07-22-00  scan_floor changed
	if( (on_passable_ == ON) )
	{
		// reset absolute distance
		absdist.x = 0;
		absdist.y = 0;
		absdist.z = 0;

		// if MY center (use passable height) is greater than the surface level...
		if(((my_height_passable) > 5))// (MY.MIN_Z + 21)))   // 21 = 16 "hull" + 5 "float value"
		{
			 // pull down to the surface of the water
  			absdist.Z -= min(gravity,my_height_passable);
		}


		// restrict climbing rotation on surface and check for edge...
		if(MY.TILT > 5)
		{
			MY.TILT = 5;   // shallow climb


			// If the user is near a solid edge and trying to swim up try to hop out
			// scan ahead of ME
			vec_set(vecFrom,MY.X);
			vecFrom.X += (MY.MAX_X + 25) * cos(MY.PAN);
			vecFrom.Y += (MY.MAX_X + 25) * sin(MY.PAN);
			vec_set(vecTo,vecFrom);
			vecFrom.Z += MY.MAX_Z;		// adjust this to adjust height

			trace_mode = IGNORE_ME + IGNORE_SPRITES + IGNORE_PASSENTS + IGNORE_MODELS + IGNORE_PASSABLE;
			if( (trace(vecFrom,vecTo)) != 0)
			{
				// hop out of water
				temp.X = 0; temp.Y = 0; temp.Z = MY.MAX_Z;
				//--move(ME,temp,NULLSKILL);
				move_mode = ignore_you + ignore_passable + ignore_push + activate_trigger + glide;
				ent_move(temp,NULLSKILL); // move up ..

				temp.X = MY.MAX_X; temp.Z = 0;
				//--move(ME,temp,NULLSKILL);
				result = ent_move(temp,NULLSKILL);// ... and over

			}
		}

		// Now move ME by the relative and the absolute speed
		YOU = NULL;	// YOU entity is considered passable by MOVE
		vec_scale(dist,movement_scale);	// scale distance by movement_scale
		//	Removed absdist movement_scale because absdist is calculated from external forces
		//---vec_scale(absdist,movement_scale);	// scale absolute distance by movement_scale
		//--move(ME,dist,absdist);
		move_mode = ignore_you + ignore_passable + ignore_push + activate_trigger + glide;
		result = ent_move(dist,absdist);
	}
	else   // underwater
	{
 		// NOTE: this is where we would add buoyancy (using absforce)
		// right now we are assuming zero buoyancy

		// NOTE: this is where we could add the effect of currents (using absforce)

		// Now move ME by the relative and the absolute speed
		YOU = NULL;	// YOU entity is considered passable by MOVE
		vec_scale(dist,movement_scale);	// scale distance by movement_scale
	  //--	move(ME,dist,NULLSKILL);
		move_mode = ignore_you + ignore_passable + ignore_push + activate_trigger + glide;
		result = ent_move(dist,NULLSKILL);
	}



	// Store the distance covered, for animation
	my_dist = RESULT;
	// Store the distance for player 1st person head bobbing
	// (only for single player system)
	if(ME == player)
	{
		player_dist += MY._SPEED_X;//SQRT(speed.X*speed.X + speed.Y*speed.Y);
	}
}

/////////////////////////////////////////////////////////////////////////
// Desc: scan for a surface below the ME entity
//       set my_floornormal vector to the normal of the surface
//			set my_height to the distance between ME.MIN_Z and the surface
//			set floorspeed to the X & Y speed of any platform ME is on.
//			set on_passable_, in_passable_, and in_solid_ to the 'offset SONAR'
//		values.
//
//]- Mod Date: 7/22/00 JCL
//]-       sets on_passable_, in_passable_, and in_solid_ values using the
//]-		"MY.Z += 16 SONAR" method.
//]-
//]- Mod Date: 11/9/00 DCP
//]-				Replaced sonars with trace()
//]-
//]- Mod Date: 02/08/01 DCP
//]-          Modified 'offset sonar' to calculate height when in water (no
//]-			longer uses the hull, assume swim animation is centered vertically).
function scan_floor()
{
	// -old- SONAR	ME,4000;
//jcl 1-14-01: forgotten IGNORE_SPRITES fixed
	trace_mode = IGNORE_SPRITES + IGNORE_PASSENTS + IGNORE_MODELS + USE_BOX + ACTIVATE_SONAR;
	vec_set(vecFrom,MY.x);
	vec_set(vecTo,MY.x);
	vecTo.z -= 4000;
	my_height = trace(vecFrom,vecTo);  // this is the same as SONAR MY,distance;

	// if the first sonar shows we are in_passable or on_passable...
	if((IN_PASSABLE == ON) || (ON_PASSABLE == ON))
	{
		// the entity can be completely or partially under water
//--		vecFrom.z += 16;		// displace me upwards by the hull size - now my hull is outside the water
		vecFrom.z += (MY.MAX_Z + MY.MIN_Z);// displace upwards by model's vertical center
		trace_mode = IGNORE_SPRITES + IGNORE_PASSENTS + IGNORE_MODELS;
		my_height_passable = trace(vecFrom,vecTo);

	}
	else
	{
		my_height_passable = 0;
	}

	// save SONAR values for later use
	on_passable_ = ON_PASSABLE;
	in_passable_ = IN_PASSABLE;
	in_solid_ = IN_SOLID;

	my_floornormal.X = NORMAL.X; 	// set my_floornormal to the normal of the surface
	my_floornormal.Y = NORMAL.Y;
	my_floornormal.Z = NORMAL.Z;
//	my_height = RESULT;       		// set my_height to the distance between entity's MIN_Z and surface

	my_floorspeed.X = 0; 			// reset floorspeed to zero
	my_floorspeed.Y = 0;

	// if the player is standing on a platform, move him with it
	if(YOU != NULL)
	{
		if(YOUR._TYPE == _TYPE_ELEVATOR)
		{
			my_floorspeed.X = YOUR._SPEED_X;
			my_floorspeed.Y = YOUR._SPEED_Y;
			// Z speed is not necessary - this is done by the height adaption
		}
	}
}



/////////////////////////////////////////////////////////////////////////
// Desc: calculate the damage taken by a fall
//
//	Param: fall_time and MY must be set before calling
//
// Note: override this function if you want to use a different formula
//
// Called from 'move_gravity()'
function	fall_damage()
{
	// calculate damage depending on _FALLTIME
 	return(10 + INT((MY._FALLTIME - fall_time) * 1.75));
}



/////////////////////////////////////////////////////////////////////////
// Desc: set force and aforce values
//			these values come from _player_intentions (single player)
//		  or from the client (multiplayer)
//
//	Calls: _player_intentions
//
//	Called From: player_move()
//
//]- Mod Date: 6/9/00 Doug Poston
//]-				changed to function
function _player_force()
{
	// If the camera does not move itself
	if (_camera == 0)
	{
		// multiplayer mode
		if(connection > 0) // if (client_moving) does not work on a stand-alone server
		{
			// get forces from server
			vec_set(force,MY._FORCE_X);
			vec_set(aforce,MY._AFORCE_PAN);
		}
		else
		{
			// get forces from user input (local)
			_player_intentions();
		}

		vec_scale(aforce,MY._FORCE);
		vec_scale(force,MY._FORCE);
	}
	else
	{ // player is controlling camera - set actor forces to zero
		vec_set(aforce,nullvector);
		vec_set(force,nullvector);
	}
}




/////////////////////////////////////////////////////////////////////////
// Desc: used in multiplayer (client/server) games
//			set client_moving var to 1
//			take user input use that to adjust the 'player' forces
//			SEND player forces to the server
//       move the camera
//
// Mod: 04/18/02 rotation is now calculated on the client and sent to the server
//
// Call: _player_intentions
//			move_view
function client_move()
{
	client_moving = 1;
	while(1)
	{
		// player created on the client?
		if(player)
		{
			_player_intentions();	// user key/mouse input sets force and aforce values

// we are setting the player's angles directly on the client,
// and are sending them to the server, rather than sending a keyboard
// force. This eliminates network latency on rotation.
// However the player entity will receive the angles back from the
// server at random intervals, and we have to prevent that they
// overwrite our directly set angles. For this we store the angles
// in the aforce skills.
			vec_set(player.PAN,player._AFORCE_PAN);	// retrieve angles
			_player_rotate();			// rotate on client
			send_vec(player.pan); 	// send angles to server
			vec_set(player._AFORCE_PAN,player.PAN); // store angles

// we can't do the same with translation, due to collision detection.
// so set player forces to forces entered in _player_intentions()
			vec_set(player._FORCE_X,force);
// and then send player forces to server, for moving the player there
			send_vec(player._FORCE_X);

			// move the camera
			move_view();
		}
		wait(1);
	}
}




/////////////////////////////////////////////////////////////////////
// Desc: aitborne movement function
function move_airborne()
{
	MY._POWER += 0.1*force.Z;
	if(MY._POWER < 0) { MY._POWER = 0; }
	if(MY._POWER > power_max) { MY._POWER = power_max; }
	absforce.X = 0;
	absforce.Y = 0;
	absforce.Z = 0;

	friction = air_fric;
	force.X = 0;
	force.Y = 0;
	force.Z = 0;
}