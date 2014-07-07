// Template file v5.202 (02/20/02)
////////////////////////////////////////////////////////////////////////
// File: camera.wdl
//		WDL prefabs for camera movment
////////////////////////////////////////////////////////////////////////
// Use:
//		Include AFTER "movment.wdl"
//
//]- Created: 06/13/01 DCP
//]-
//]- Mod Date: 07/27/01 DCP
//]-		move_view_3rd(): Added check for var camera_solidpass. If != 0 camera
//]-				no longer avoids entering solids.
//]-
//]- Mod Date: 12/18/01
//]-		Added WED 'uses' comments to all WED editable fields
//
// Mod Date: 04/22/02
//			Two methods for 3rd person camera. Improved method used when the
//	first bit of the variable "move_view_cap" is set (i.e. move_view_cap = 1;)
//	otherwise the older method is used for backwards compatibility

IFNDEF CAMERA_ORBIT_DEFS;
	DEFINE kOrbitCameraPanInc, 5;
	DEFINE kOrbitCameraDistInc, 5;
	DEFINE kOrbitCameraZOffInc, 5;
ENDIF;

//@ Camera Vars
//#var person_3rd	= 0;		// 0: 1st person mode; 0.5-1: 3rd person mode  DEFINED in movement.wdl

var camera_solidpass = 0;			// 0: avoid passing into solids (may cause
											//   shaky camera)
											// 1: pass through solids

var	move_view_cap;   		// 0: use old 3rd person camera
									// 1: use new 3rd person camera




var camera_dist[3] = 90,0,0;   			// camera distance to entity in 3rd person view

var chase_camera_dist[3] = -20,90,0;  // camera distance to entity in chase view


var orbit_camera_pan = 180;   // pan around center point
var orbit_camera_dist = 150;  // distance from center point
var orbit_camera_zOff = 5;		// distance up

///////////////////////////////////////////////////////////////////////
//]- Mod Date: 7/4/00 DCP
//]-	 Changed speed -> camera_speed
//]-          aspeed-> camera_aspeed
var camera_speed[3] = 0,0,0;	// cartesian speed, entity coordinates
var camera_aspeed[3];		// angular speed

var	current_fog_index	= 0;	// the current fog color index

var walk_rate = 3; 	// for head wave, 360 / step width
var wave_rate = 25; 	// same for swimming, 360 / wave time
var walk_ampl = 4;	// walking head wave amplitude
var wave_ampl = 2; 	// swimming head wave amplitude






//@ Function prototypes
//ACTION camera_move	- Attach to entity in a level without player, free move camera
function move_view_1st();	// Handles first person camera view
function move_view_3rd();  // Handles third person camera view
function move_view_orbit();// Handles the 'orbit' camera
function move_view_chase();// Handles the 'chase' camera
function move_view();		// Call the appropriate function to move the camera
function toggle_person();	// Toggle between 1st and 3rd person views
function cycle_person_view();// Cycle from 1st to 3rd to orbit person views
function set_pos_ahead();  // Calculate a position directly ahead of the camera
function _set_pos_ahead_xyz();	// Calculate a position ahead of the player


//@ Function Code


// ----



/////////////////////////////////////////////////////////////////////////
// desc: Used to move a 'free' camera
//	desc:	Good for testing levels and making "fly-thrus"
//
// help:	Camera is not attached to any object, therefor it can move into
//	help:solid space (walls)
//
//
//]- Mod Date: 6/27/00 Doug Poston
//]-				Replaced ACCEL (x2)
//]- Mod Date: 7/3/00 Doug Poston
//]-				Added time correction to CAMERA.PAN,.TILT, & .ROLL
//]- Mod Date: 7/4/00 DCP
//]-				Switched generic speed and aspeed to camera_speed and camera_aspeed
//]-				Movement is now time corrected
//]- Mod Date: 11/8/00 DCP
//]-				Replace move_view with a simple vec_add()
ACTION camera_move
{
	_camera = 1;
	while(_camera == 1)
	{
		_player_intentions();     // set force and aforce value from user input

 		// -old method- ACCEL	aspeed,aforce,0.9;
		camera_aspeed.pan  += (TIME * aforce.pan)  - (0.9 * camera_aspeed.pan);
		camera_aspeed.tilt += (TIME * aforce.tilt) - (0.9 * camera_aspeed.tilt);
		camera_aspeed.roll += (TIME * aforce.roll) - (0.9 * camera_aspeed.roll);

		CAMERA.PAN += camera_aspeed.PAN * TIME;
		CAMERA.TILT += camera_aspeed.TILT * TIME;
		CAMERA.ROLL += camera_aspeed.ROLL * TIME;

		// Calculate camera's new speed
 		// -old method- ACCEL	speed,force,0.9;
		camera_speed.x += (TIME * force.x) - (0.9 * camera_speed.x);
		camera_speed.y += (TIME * force.y) - (0.9 * camera_speed.y);
		camera_speed.z += (TIME * force.z) - (0.9 * camera_speed.z);

		// calculate relative distance
   	dist.x = camera_speed.x * TIME;
 	 	dist.y = camera_speed.y * TIME;
 	 	dist.z = camera_speed.z * TIME;

		// Replace move_view with XYZ displacement
		//move_view CAMERA,dist,NULLSKILL;
		vec_rotate(dist.x,CAMERA.pan);
		vec_add(CAMERA.X, dist.X);

		wait(1);
	}
}


///////////////////////////////////////////////////////////////////////
// First person camera view
// This should be a client-only action!!
//
//]- Mod Date: 5/10/00 @ 954 Doug Poston
//]-           Added code to create 'under water' fog
//]- Mod Date: 5/15/00 @ 947 Doug Poston
//]-				 Added eye_height adjustment for ducking and crawling
//]- Mod Date: 5/22/00 Doug Poston
//]-				 Added TOUCH for underwater fog
//]- Mod Date: 6/5/00 Doug Poston
//]-				 Replaced TOUCH with ent_content() function
//]- Mod Date: 6/26/00 Doug Poston
//]-				 Modifed IF to accept Swimming at any height
//]- Mod Date: 11/13/00 DCP
//]-				 headwave only when 'on_passable_' && swimming
//]- Mod Date: 02/07/01 DCP
//]-           Check camera 'content' for swimming headbob (don't bob if
//]-			underwater, do if swimming on top)
//]-				 Removed swimming 'eye_height_down' value
//]-				 Change 'layout', grouped like actions together
function move_view_1st()
{
	if(_camera == 0) // If the camera does not move itself
	{
		// Position the camera

		CAMERA.DIAMETER = 0;		// make the camera passable
		CAMERA.GENIUS = player;	// don't display parts of ME
	  	CAMERA.X = player.X;    // place camera at player's location
		CAMERA.Y = player.Y;
		CAMERA.Z = player.Z + player.MIN_Z;  // start at 'feet', move up later...

		// Move the eye height up depending on the _MOVEMODE (start at feet)
 		if(player._MOVEMODE == _MODE_SWIMMING)
		{
			// adjust eye height for swimming
		  	CAMERA.Z += (player.MAX_Z-player.MIN_Z)*eye_height_swim;
		}
		else  // not swimming
		{

 			if((player._MOVEMODE == _MODE_DUCKING) || (player._MOVEMODE == _MODE_CRAWLING))
			{
				// adjust eye height for ducking and crawling
				CAMERA.Z += (player.MAX_Z-player.MIN_Z)*eye_height_duck;
			}
			else
			{
				// adjust eye height for 'normal' modes
				CAMERA.Z += (player.MAX_Z-player.MIN_Z)*eye_height_up;
			}
 		}

		CAMERA.PAN = player.PAN;
		CAMERA.TILT = player.TILT + head_angle.TILT;
		CAMERA.ROLL = player.ROLL;

		// Handle head-bob

		if(my_height < 5 || (player._MOVEMODE == _MODE_SWIMMING) )
		{
			// use
			headwave = sin(player_dist*walk_rate);

			if((player._MOVEMODE == 0)	// moving on client?
				|| (player._MOVEMODE == _MODE_WALKING))
			{
				// Play the right and left foot sound
				if(((headwave > 0) && (walkwave <= 0))
					|| ((headwave <= 0) && (walkwave > 0)))
				{
					//play_sound(thud,30);
				}
				// head bobbing
				walkwave = headwave;
				headwave = walk_ampl*(abs(headwave)-0.5);
			}

			if((player._MOVEMODE == _MODE_SWIMMING) && (ent_content(NULL,CAMERA.x) != CONTENT_PASSABLE))//(on_passable_ == ON))
			{
				if((headwave > 0) && (walkwave <= 0))
				{
					//play_sound(splash,30);
				}
				// in-water wave movement
				walkwave = headwave;
				headwave = wave_ampl*sin(TOTAL_TICKS*wave_rate);
				head_angle.TILT += 0.1*wave_ampl*sin(TOTAL_TICKS*wave_rate - 60);
			}
		} // END if(my_height < 5 || (player._MOVEMODE == _MODE_SWIMMING) )


		if(player.__BOB == ON) { CAMERA.Z += headwave;	}



// check to see if camera is located in a passable block and set fog color index
//jcl 07-22-00  old fog is saved
		if (ent_content(NULL,CAMERA.x) == CONTENT_PASSABLE)
		{
			if (FOG_COLOR != _FOG_UNDERWATER)
			{
				current_fog_index = FOG_COLOR;	// save old fog
				FOG_COLOR = _FOG_UNDERWATER;	// set fog color to underwater fog
			}
		}
		else
		{
			if (FOG_COLOR == _FOG_UNDERWATER)
			{
				// else restore current_fog_index
				FOG_COLOR = current_fog_index;
			}
		}

		person_3rd = 0;  // we are in first person mode

	} // END if(_camera == 0) // If the camera does not move itself
}

// Desc: New 3rd person camera code. This method is used when move_view_cap equals 1
//
// Calls: <none>
// Called by: move_view_3rd()
// modifies: camera, camera_dist, temp_cdist, temp, temp2, person_3rd,
//       FOG_COLOR
//
//
//]- Mod Date: 04/17/02 DCP
//]-			Test #1, works great (no bounce), but camera can get close enough to wall to see through it
//]- Mod Date: 04/18/02 DCP
//]-			Test #2, use_box on trace stops box from entering walls,
//]-						movement of camera needs work (simplify)
//]-
//]- Mod Date: 04/19/02 DCP
//]-			Test #3, (old test backed up) create 'delay effect'
//]-
// Mod Date: 04/19/02 DCP
//				New 3rd person camera, has improved collision and movement
//				To use this method, set move_view_cap equal to 1
//
// Mod Date: 06/04/02 DCP
//				Changed method used to keep camera from entering walls or "bouncing".
//
// Mod Date: 06/05/02 DCP
//		Fixed collision issues with walls. View should not penetrate walls.
//
// Mod Date: 06/06/02 DCP
//		Player eye height (eye_height_up) used as offset when 'zooming in' the camera.
function move_view_3rd_2()
{
	var   vec_view_target[3];

	if ((_camera == 0) && (player != NULL))
	{

 		CAMERA.DIAMETER = 0;		// make the camera passable
		CAMERA.genius = player; // don't show the player if we are inside of them


		// orientate the camera
 		CAMERA.pan += 0.2 * ang(player.pan-CAMERA.pan);

		// tilt the camera differently if we are using a vehicle
 		if ( (player._MOVEMODE == _MODE_PLANE)
 			||(player._MOVEMODE == _MODE_CHOPPER))
 		{
 			CAMERA.tilt += 0.2 * ang(player.tilt-CAMERA.tilt);

			// set view target to player origin
			vec_set(vec_view_target.x,player.x);
 		}
		else
		{
			// walking, swimming etc.
		  	CAMERA.TILT = head_angle.TILT;  // tilt camera with head angle

			// up the camera by the eye_height_up value
			if((person_3rd < 1) && (camera_dist.Z == 0))	// switching to 3rd person
			{
				camera_dist.Z = -(player.MAX_Z-player.MIN_Z)*eye_height_up;//- player.MAX_Z;
			}

			// set view target to player origin + eye_height offset
			vec_set(vec_view_target.x,player.x);
			vec_view_target.z += (player.MAX_Z)*eye_height_up;
		}



		// temp is now the target offset
		vec_set(temp,camera_dist);
		vec_scale(temp,-1);        // negate direction (compatibility issues)

		// Rotate the camera offset by the player's orientation
		if(player._MOVEMODE == _MODE_SWIMMING)         // don't tilt camera if swimming
		{
			temp2 = player.TILT;				// save player tilt
			player.TILT = 0;
			vec_rotate(temp,player.PAN);  // temp = new target vector
			player.TILT = temp2;        	// restore player tilt
		}
		else
		{
			temp2 = player.TILT;				// save player tilt
			player.TILT = head_angle.tilt;// use head angle for tilt
			vec_rotate(temp,player.PAN);  // temp = new target vector
			player.TILT = temp2;        	// restore player tilt
		}

		// offset camera offset by player position
		vec_add(temp,player.x);


		// move towards target position
		temp2 = min(1,0.5 * TIME);    // value of 1 places us at target
		temp_cdist.X += temp2*(temp.x - temp_cdist.X);
		temp_cdist.Y += temp2*(temp.y - temp_cdist.Y);
		temp_cdist.Z += temp2*(temp.z - temp_cdist.Z);



		// keep camera from penetrating walls
		vec_diff(temp2.x,temp_cdist.x,vec_view_target.x);
		vec_normalize(temp2.x,16);
		vec_add(temp2.x,temp_cdist.x);	// temp2 = temp_cdist + 16 units away from view target

		me = player;
		trace_mode = ignore_me + ignore_passable + ignore_models + ignore_sprites;
		if( trace(vec_view_target.x,temp2.x) > 0)	// extended trace hit something
		{

			// note: trace sets target vector to hit point
			vec_diff(temp2.x,vec_view_target.x,target.x);	// temp2 is vector from target to view target
			vec_normalize(temp2.x,16);             // back off 16 units from wall
			//+++check to make sure we don't over correct
			// note: as long as the player's center point can not get within
			//16 units of a wall this step is unnecessary

			// set camera = target - 16 units
			vec_set(camera.x,target.x);
			vec_add(camera.x,temp2.x);
		}
		else
		{
			vec_set(camera.x,temp_cdist.x);	// set to original camera target
		}

 		// test if camera is IN_PASSABLE for water 'fog' effect
		temp = ent_content(NULL,CAMERA.X);
		// check to see if camera is located in a passable block and set fog color index
		if (temp == CONTENT_PASSABLE)
		{
			if (FOG_COLOR != _FOG_UNDERWATER)
			{
				current_fog_index = FOG_COLOR;	// save old fog
				FOG_COLOR = _FOG_UNDERWATER; 		// set fog color to underwater fog
			}
		}
		else
		{
			if (FOG_COLOR == _FOG_UNDERWATER)
			{
				// else restore current_fog_index
				FOG_COLOR = current_fog_index;
			}
		}

		// set flag
		person_3rd = 1; 	// camera is fully in 3rd person mode
	}

}



/////////////////////////////////////////////////////////////////////////
// Desc: Old third person camera view. Used when move_view_cap equals 0
//
//]- Mod Data: 5/10/00 DCP
//]-           Added code to create 'under water' fog
//]- Mod Date: 5/22/00 Doug Poston
//]-				 Added TOUCH for underwater fog
//]- Mod Date: 6/5/00 DCP
//]-				 Replaced TOUCH with ent_content() function
//]- Mod Date: 8/28/00 DCP
//]-				 Replaced 4.205 function with modified 'Fly Level' function
//]- Mod Date: 2/07/01 DCP
//]-				 Adjusted eye height
//]- 			 Don't tilt camera if swimming
//]- Mod Date: 07/27/01 DCP
//]-			Added check for var camera_solidpass. If != 0 camera no longer
//]-		avoids entering solids.
// Mod Date: 04/19/02 DCP
//				Renamed from "move_view_3rd"
//				This is the 'old' method for 3rd person, kept for compatibility
//				To use this method, set move_view_cap equal to 0
function move_view_3rd_old()
{
	if ((_camera == 0) && (player != NULL))
	{

 		CAMERA.DIAMETER = 0;		// make the camera passable
		CAMERA.genius = player;
		CAMERA.pan += 0.2 * ang(player.pan-CAMERA.pan);

		// tilt the camera differently if we are using a vehicle
 		if ( (player._MOVEMODE == _MODE_PLANE)
 			||(player._MOVEMODE == _MODE_CHOPPER))
 		{
 			CAMERA.tilt += 0.2 * ang(player.tilt-CAMERA.tilt);
 		}
		else
		{
			// walking, swimming etc.
			CAMERA.TILT = head_angle.TILT;

  		  	if((person_3rd < 1) && (camera_dist.Z == 0))	// switching to 3rd person
			{
				camera_dist.Z = -(player.MAX_Z-player.MIN_Z)*eye_height_up;//- player.MAX_Z;
			}


		}

		vec_set(temp,temp_cdist);      // temp = temp_cdist
		// don't tilt camera if swimming
		if(player._MOVEMODE == _MODE_SWIMMING)
		{
			temp2 = player.TILT;
			player.TILT = 0;
			vec_rotate(temp,player.PAN);
			player.TILT = temp2;
		}
		else
		{
			vec_rotate(temp,player.PAN);
		}
      CAMERA.X += 0.3*(player.X - temp.X - CAMERA.X);
      CAMERA.Y += 0.3*(player.Y - temp.Y - CAMERA.Y);
      CAMERA.Z += 0.3*(player.Z - temp.Z - CAMERA.Z);

 		// test if camera is IN_PASSABLE or IN_SOLID
		temp = ent_content(NULL,CAMERA.X);

		// if camera moved into a wall...
		if((temp == CONTENT_SOLID) && (camera_solidpass == 0))
		{
			temp_cdist.X *= 0.7;	// place it closer to the player
			temp_cdist.Y *= 0.7;
			temp_cdist.Z *= 0.7;
		}
		else
		{
			temp_cdist.X += 0.2*(player.MAX_X + camera_dist.X - temp_cdist.X);
			temp_cdist.Y += 0.2*(player.MAX_Y + camera_dist.Y - temp_cdist.Y);
			temp_cdist.Z += 0.2*(player.MAX_Z + camera_dist.Z - temp_cdist.Z);
		}

		// check to see if camera is located in a passable block and set fog color index
		if (temp == CONTENT_PASSABLE)
		{
			if (FOG_COLOR != _FOG_UNDERWATER)
			{
				current_fog_index = FOG_COLOR;	// save old fog
				FOG_COLOR = _FOG_UNDERWATER; 		// set fog color to underwater fog
			}
		}
		else
		{
			if (FOG_COLOR == _FOG_UNDERWATER)
			{
				// else restore current_fog_index
				FOG_COLOR = current_fog_index;
			}
		}
		person_3rd = 1; 	// fully 3rd person
	}

}

// Desc: update the 3rd person camera using the correct method
function move_view_3rd()
{
	if(move_view_cap & 1) { move_view_3rd_2(); } // run new 3rd person animation
	else { move_view_3rd_old(); } // run older 3rd person animation

}

/////////////////////////////////////////////////////////////////////////
// Desc: functions used to change the orbit camera values
function inc_orbit_camera_pan()
{
	orbit_camera_pan += kOrbitCameraPanInc;
	IF (orbit_camera_pan > 360)
	{
		orbit_camera_pan -= 360;
	}
}
function dec_orbit_camera_pan()
{
	orbit_camera_pan -= kOrbitCameraPanInc;
	IF (orbit_camera_pan < 0)
	{
		orbit_camera_pan += 360;
	}
}
function inc_orbit_camera_dist()
{
	orbit_camera_dist += kOrbitCameraDistInc;
}
function dec_orbit_camera_dist()
{
	orbit_camera_dist -= kOrbitCameraZOffInc;
	IF (orbit_camera_pan < 0)
	{
		orbit_camera_pan = 0;
	}
}
function inc_orbit_camera_zOff()
{
	orbit_camera_zOff += kOrbitCameraDistInc;
}
function dec_orbit_camera_zOff()
{
	orbit_camera_zOff -= kOrbitCameraZOffInc;
}

/////////////////////////////////////////////////////////////////////////
// Desc: Orbit camera
//
//]- Mod Date: 5/18/00 DCP
//]-           Created
//]- Mod Date: 5/22/00 DCP
//]-				Added TOUCH for underwater fog
function move_view_orbit()
{
 	CAMERA.DIAMETER = 0;		// make the camera passable
 	CAMERA.GENIUS = PLAYER;
 	CAMERA.X = PLAYER.X + (orbit_camera_dist * SIN(orbit_camera_pan));
 	CAMERA.Y = PLAYER.Y + (orbit_camera_dist * COS(orbit_camera_pan));
 	CAMERA.Z = PLAYER.Z + orbit_camera_zOff;

 	// if the camera is IN_PASSABLE (set by TOUCH) assume it is underwater
	TOUCH	NULL,CAMERA.POS;
 	IF (IN_PASSABLE)
 	{
 	 	FOG_COLOR = _FOG_UNDERWATER;  // set fog color to underwater
 	}
 	ELSE
 	{
 		// else restore the current_fog_index
 		FOG_COLOR = current_fog_index;
 	}

 	// face the player
 	temp.X = player.X - camera.X;
   temp.Y = player.Y - camera.Y;
   temp.Z = player.Z - camera.Z;
 	vec_to_angle(temp,temp);
 	camera.PAN = temp.PAN;
 	camera.TILT = temp.TILT;
}



/////////////////////////////////////////////////////////////////////////
// Desc: Chase camera
//
//]- Created: 06/11/01  JCL

var	chase_camera_ang[3];

function move_view_chase()
{
	if ((_camera == 0) && (player != NULL))
	{

 		CAMERA.DIAMETER = 0;		// make the camera passable
		CAMERA.genius = player;



  		// calculate the camera view direction angles to the player
   	vec_diff(temp,nullvector,chase_camera_dist);    // temp = -camera_dist
   	vec_to_angle(chase_camera_ang,temp);      // chase_camera_ang points towards player
   	chase_camera_ang.roll = 0; 					// zero out roll angle

		// place the camera at the right position to the ship
      vec_set(camera.x,chase_camera_dist);
      vec_rotate(camera.x,player.pan);
      vec_add(camera.x,player.x);
		// set the camera angles to the player's angles
      vec_set(camera.pan,player.pan);
		// and quaternion rotate them by the camera view direction angles
      ang_rotate(camera.pan,chase_camera_ang);
	}
}

/////////////////////////////////////////////////////////////////////
// Desc: Call the appropriate function to move the camera
//
//	note: person_3rd value used for branching
function move_view()
{
	if(player == NULL) { player = ME; }	// this action needs the player pointer
	if(player == NULL) { return; }			// still no player -> can't work

	if(person_3rd > 2)
	{
		move_view_chase();
		return;
	}

	if(person_3rd > 1)
	{
		move_view_orbit();
		return;
	}

	if(person_3rd > 0)
  	{
		move_view_3rd();
		return;
	}

	// default 1st person view
	move_view_1st();

}


/////////////////////////////////////////////////////////////////////
// Desc: Toggle between 1st and 3rd person views
//
//	Effects 'person_3rd' value
function toggle_person()
{
	if(person_3rd > 0)
	{
		person_3rd = 0;
	}
	else
	{
		person_3rd = 0.5;
	}
}

/////////////////////////////////////////////////////////////////////
// Desc: Cycle from 1st to 3rd to orbit person views
//
//	Effects 'person_3rd' value
function cycle_person_view()
{
	if(person_3rd > 2)   // in 'chase' range
	{
		person_3rd = 0; // switch to 1st person view
		return;
	}

	if(person_3rd > 1)   // in 'orbit' range
	{
		person_3rd = 3; // switch to chase person view
		return;
	}

	if(person_3rd > 0)  // 3rd person veiw
	{
		person_3rd = 2;  // switch to orbit
   	return;
	}

 	person_3rd = 0.5; // switch to 3rd person view

 }


/////////////////////////////////////////////////////////////
// Desc: Calculate a position directly ahead of the camera
// Input:  p (distance)
// Output: MY_POS
function set_pos_ahead()
{
	temp.X = cos(CAMERA.PAN);
	temp.Y = sin(CAMERA.PAN);
	temp.Z = p*cos(CAMERA.TILT);
	MY_POS.X = CAMERA.X + temp.Z*temp.X;
	MY_POS.Y = CAMERA.Y + temp.Z*temp.Y;
	MY_POS.Z = CAMERA.Z + p*sin(CAMERA.TILT);
}

/////////////////////////////////////////////////////////////
// Desc: Calculate a 3d position relative to the camera angles
// Input:  MY_POS
// Output: MY_POS
//
//]- Mod Date: 6/9/00 Doug Poston
//]-				changed to function
function _set_pos_ahead_xyz()
{
	vec_rotate(MY_POS,CAMERA.PAN);
	if(person_3rd != 0)
	{
		MY_POS.X += player.X;
		MY_POS.Y += player.Y;
		MY_POS.Z += player.Z;
	}
	else
	{
		MY_POS.X += CAMERA.X;
		MY_POS.Y += CAMERA.Y;
		MY_POS.Z += CAMERA.Z;
	}
}





// Define ON_KEY functions
//ON_F7 toggle_person;
ON_F7	cycle_person_view;