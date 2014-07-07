// Template file v5.202 (02/20/02)
////////////////////////////////////////////////////////////////////////
// Last Mod: 02/11/01
////////////////////////////////////////////////////////////////////////
// File: movement.wdl
//		WDL prefabs for entity movement
////////////////////////////////////////////////////////////////////////
//]- Mod Date: 6/5/00
//]- Added code to handle new animation
//]- Player can now stand, walk, run, duck, jump, crawl, swim, and wade
//]-
//]- Mod Date: 6/8/00
//]- Converted code to 4.187 format (removed SETs and CALLs)
//]-
//]- Mod Date: 6/19/00
//]- Added __FALL (FLAG1) and _FALLTIME (SKILL31)
//]- If __FALL is ON, player takes damage from falls
//]- _FALLTIME contains the amount of time spent falling (calculated in move_gravity)
//]-
//]- Mod Date: 7/18/00
//]-	Changed slope gravity (added var 'slopefac')
//]-
//]- Mod Date: 7/19/00
//]- Added code to adjust my_height while ducking and crawling
//]-		- Add var 'duck_height'
//]-		- modified var 'eye_height_duck' to equal 'eye_height_up'
//]-
//]- Mod Date: 7/28/00
//]- Added __DUCK flag as flag #8 (replaces __SOUND flag)
//]- Player can only duck if the __DUCK flag is set to ON
//]- NOTE: __SOUND flag is still used for "old style" animation!
//]-
//]- Mod Date: 8/28/00 DCP
//]-	Removed Actions 'player_heli' and 'player_fly' (experimental code)
//]-	Added MODEs _MODE_PLANE &  _MODE_CHOPPER
//]-	Expanded var 'camera_dist' & 'temp_cdist' into vectors (X,Y,Z fields)
//]- Modified 'move_view_3rd' FUNCTION to take advantage of 'camera_dist' vector
//]- Replaced min with max (to eliminate 'creep') in 'gravity' functions
//]-
//]- Mod Date: 8/31/00 DCP
//]-	Added movement_scale and actor_scale to scale movement and models (to make world appear larger or smaller)
//]- Modified "swim_gravity" to scale dist and absdist by movement_scale before MOVE
//]- Modified "wade_gravity" to scale dist and absdist by movement_scale before MOVE
//]- Modified "move_gravity" to scale dist and absdist by movement_scale before MOVE
//]- Modified function "anim_init" to use actor_scale to scale the entity that calls it.
//]- Modified 'walk_or_run' by 'movement_scale' in function "actor_anim"
//]-
//]- Mod Date: 9/2/00 DCP
//]-	Modified 'move_view_3rd' to set camera_dist.Z to player.MAX_Z if zero
//]-
//]- Mod Date: 10/31/00 DCP
//]-	Modified 'player_move':	Replaced min with max in ASPEED (to eliminate 'creep')
//]-	Changed to 4.30 format
//]-
//]- Mod Date: 11/8/00 DCP
//]-	Modified 'camera_move':	Replace move_view with a simple vec_add()
//]- Modified 'actor_anim': Replace set_frame and set_cycle with ent_frame and ent_cycle
//]-
//]- Mod Date: 11/9/00 DCP
//]-	Modified 'move_shadow': Replaced sonar with trace()
//]- Modified 'scan_floor': Replaced sonar with trace()
//]- Modified 'move_gravity': Replaced the double MOVE with a single MOVE and a distance check
//]- Modified 'swim_gravity': Change diving (player no longer rotates)
//]-
//]- Mod Date: 11/13/00 DCP
//]-	Added 'mouse_to_level': uses trace() and vec_for_screen() to set TARGET
//]-								to the nearest point under the cursor.
//]- Modified 'move_view_1st': Headwave only when 'on_passable_' && swimming
//]-
//]- Mod Date: 01/16/01 JCL
//]-	"swim_gravity", "wade_gravity", & "move_gravity"
//]-	Removed absdist movement_scale because absdist is calculated from external forces
//]-
//]- Mod Date: 02/02/01 JCL
//]-	Added function 'attach_entity': attaches an entity that has the same origin and the same frame cycles
//]-
//]- Mod Date: 02/07/01 DCP
//]- "move_view_1st": Check camera 'content' for swimming headbob (don't bob if
//]-			          underwater, do if swimming on top)
//]-				 		  Removed swimming 'eye_height_down' value
//]-				 		  Change formating, grouped like actions together
//]- "move_view_3rd": Adjusted eye height
//]- 					  Don't tilt camera if swimming
//]-
//]- Replace 'eye_height_down' with 'eye_height_swim'
//]-
//]- Mod Date: 02/08/01 DCP
//]- "scan_floor": Modified 'offset sonar' to calculate height when in water (no
//]-			longer uses the hull, assume swim animation is centered vertically).
//]-
//]- Mod Date: 02/09/01 DCP
//]-	"swim_gravity": Added code to 'surface' section that allows the player to 'hop' out of the water.
//]-	"player_move":	If entering passable block stop falling (MY._SPEED_Z = 0)
//]-
//]- Mod Date: 02/11/01 DCP
//]-	Added new var "my_height_passable".  This is the height of the player model's center
//]- above any passable surface. It is only valid is the player model is in or on a passable surface.
//]- It is set in "scan_floor" and used in "player_move" & "swim_gravity".
//]-
//]- Mod Date: 04/17/01 DCP
//]-	Added '_test_arrow' test code. make object passable and remove after 128 ticks
//]-	(CREATE(<ARROW.PCX>,gun_source,_test_arrow);)
//]-
//]- Mod Date: 05/30/01 DCP
//]-		player_move():	Changed -MY.MIN_Z + 5 to -MY.MIN_Z + 6 in "swim check" to
//]-	replace '<=' compare with '<' (do NOT use '<=', '>=', or '==' to compare
//]-	non-int values).
//]-
//]- Mod Date: 05/31/01 DCP
//]-	player_move() & wade_gravity(): Changed 'wading' behavior so player
//]-	no longer 'stutters' from wade-to-swim when entering/exiting the water.
//]-
//]- Mod Date: 06/08/01 DCP
//]-		swim_gravity(), wade_gravity(), & move_gravity() : Replaced move() with ent_move()
//]-
//]- Mod Date: 06/11/01 DCP
//]-		Add function "actor_anim_old_style_anim()", removed code from "actor_anim"
//]-		Add function "actor_anim_transition()"
//]-		**NOTE** actor_anim_transition is still a work in progress.
//]-
//]- Mod Date: 06/13/01 DCP
//]-		Moved all code dealing with camera movement into its own WDL (camera.wdl)
//]-
//]- Mod Date: 06/14/01 DCP
//]-		Moved all code dealing with animation into its own WDL (animate.wdl)
//]-		Moved all code dealing with input into its own WDL (input.wdl)
//]-
//]- Mod Date: 06/15/01 DCP
//]-		Moved all code dealing with moving into its own WDL (move.wdl)
//]-
//]- Mod Date: 06/21/01 DCP
//]-		Replace SYNONYMs with pointers

////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////


//@ Defines
// Change them by re-defining them in your main wdl script
// BEFORE the include, and adding DEFINE MOVE_DEFS;
IFNDEF MOVE_DEFS;
	//SOUND  thud,<tap.wav>;
	//SOUND  robo_thud,<tap.wav>;  //??
	//SOUND  splash,<splash.wav>;
	DEFINE shadowsprite,<shadow.tga>;
	DEFINE shadowflat,<shadflat.pcx>;
	DEFINE DEFAULT_WALK,13.040;
	DEFINE DEFAULT_RUN,5.060;
ENDIF;


////////////////////////////////////////////////////////////////////////
// User modifiable global skill definitions
// Duplicate them in your wdl script AFTER the include
// to give them new values
// NOTE: in most cases it is a good idea to make actor_scale == movement_scale
var movement_scale = 1.00;  // used to scale the movement
var actor_scale = 1.00;	// used to scale the size of actors

var gnd_fric = 0.5;		// ground friction
var air_fric = 0.03; 	// air friction
var water_fric = 0.75;	// water friction
var ang_fric = 0.6;		// angular friction

var gravity = 0;//6; 			// gravity force
var elasticity = 0.1; 	// of the floor

// dcp: 10/02/02 changed from 2 to 0.5 to fit with constant slope force change in move
var slopefac = 0.5; // gravity on slopes, determines the max angle to climb

var strength[3] = 5,4,75;	// default ahead, side, jump strength   (25)
var astrength[3] = 7,5,2;	// default pan, tilt, roll strength

var jump_height = 50; 	// maximum jump height above ground
var fall_time = 6;		// max fall time before health is reduced
var duck_height = 25;	// distance to adjust my_height while ducking

var power_max = 1; 		// maximum engine power for aircraft


// values set in scan_floor
var on_passable_;
var in_passable_;
var in_solid_;



///////////////////////////////////////////////////////////////////////
// Entity skill & flag definitions
// some definitions here are also needed for ACTORS.WDL and WAR.WDL
DEFINE _WALKFRAMES,SKILL1;	// non-zero for old style animation
DEFINE _RUNFRAMES,SKILL2;
DEFINE _ATTACKFRAMES,SKILL3;
DEFINE _DIEFRAMES,SKILL4;

// 'advanced animation' style
DEFINE _ADVANIM_TICK,SKILL1;	// 'tick' related animation
DEFINE _ADVANIM_DIST,SKILL2;  // 'dist' related animation


DEFINE _WALKDIST,SKILL27;	// distance per walk cycle
DEFINE _RUNDIST,SKILL28;	// distance per run cycle


DEFINE _FORCE,SKILL5;		// determines speed
DEFINE _ENTFORCE,SKILL5;
DEFINE _BANKING,SKILL6;		// banking - for player only
DEFINE _PENDOLINO,SKILL6;	// banking - for player only
DEFINE _HITMODE,SKILL6;		// for actors
DEFINE _MOVEMODE,SKILL7;
DEFINE _FIREMODE,SKILL8;	// for actors



DEFINE __FALL,FLAG1;		// take damage from falls

DEFINE __WHEELS,FLAG2;	// block turns without moving
DEFINE __SLOPES,FLAG3;	// adapt the tilt and roll angle to slopes
DEFINE __JUMP,FLAG4;		// be able to jump
DEFINE __BOB,FLAG5;   	// head wave
DEFINE __STRAFE,FLAG6;	// be able to move sidewards
DEFINE __TRIGGER,FLAG7;	// be able to trigger doors automatically

DEFINE __DUCK, FLAG8;	// be able to duck

DEFINE __SOUND,FLAG8;	// internal flag

///////////////////////////////////////////////////////////////////////
DEFINE _HEALTH,SKILL9;
DEFINE _ARMOR,SKILL10;

DEFINE _SPEED,SKILL11;		// speed
DEFINE _SPEED_X,SKILL11;
DEFINE _SPEED_Y,SKILL12;
DEFINE _POWER,SKILL12;		// engine power for aircraft models
DEFINE _SPEED_Z,SKILL13;
DEFINE _ASPEED,SKILL14;		// angular speed
DEFINE _ASPEED_PAN,SKILL14;
DEFINE _ASPEED_TILT,SKILL15;
DEFINE _ASPEED_ROLL,SKILL16;

// for actor entities, and for doors and platforms
DEFINE _TARGET_X,SKILL17;
DEFINE _TARGET_Y,SKILL18;
DEFINE _TARGET_Z,SKILL19;
DEFINE _TARGET_PAN,SKILL20;
DEFINE _TARGET_TILT,SKILL21;
DEFINE _TARGET_ROLL,SKILL22;

// for player entities
DEFINE _FORCE_X,SKILL17;
DEFINE _FORCE_Y,SKILL18;
DEFINE _FORCE_Z,SKILL19;
DEFINE _AFORCE_PAN,SKILL20;
DEFINE _AFORCE_TILT,SKILL21;
DEFINE _AFORCE_ROLL,SKILL22;

DEFINE _WALKSOUND,SKILL23;	// walking sound
DEFINE _SIGNAL,SKILL24;		// communication for actions or client->server
DEFINE _COUNTER,SKILL25;	// internal counter
DEFINE _STATE,SKILL26;		// the state it is in (walk, attack, escape etc.)

DEFINE _ANIMDIST,SKILL28;	// time for standing, jumping, and ducking animations

DEFINE _JUMPTARGET,SKILL29;// target height to jump to

DEFINE _TYPE,SKILL30;		// the type of the entity - door, key, etc.

DEFINE _FALLTIME,SKILL31;	// amount of time spent falling

// Skills up to 32 are reserved for future template actions
// Skills 33-40 can be used freely

//@@ Vector Vars
// Force Vars
var force[3];		// cartesian force, entity coordinates
var absforce[3];	// cartesian force, world coordinates
var aforce[3];		// angular force

//@@ Distance Vars
var abspeed[3] = 0,0,0;	// cartesian speed, world coordinates
var dist[3];
var absdist[3];	// distances used for MOVE

//@@ Camera Vars
var person_3rd	= 0;		// 0: 1st person mode; 0.5: 3rd person mode

var eye_height_up = 0.8;	// eye position factor for walking, driving
var eye_height_swim = 0.7;	// first person camera offset for swimming
var eye_height_duck = 0.8; // first person camera offset for ducking (7/19/00: same as eye_height_up since ducking is controlled by my_height)

//@@ Multiplayer Vars
var client_moving = 0; 	// multiplayer mode


//@@ Mics Vars
var p[3];
var friction;
var limit[3];
var covered_dist;
var anim_dist;

var head_angle[3] = 0,0,0;	// separated from other values
var headwave = 0;
var walkwave = 0;
var my_dist;			// distance for actor anim
var player_dist;		// distance for head bobbing
var scan_sector;
var my_height;
var my_height_passable;	// height above passable surface (valid only if on passable surface)
var my_floornormal[3];
var my_floorspeed[3];
var temp_cdist[3] = 120,0,0;   // current camera distance in 3rd p view
//-var debugskill;

// temp values used to replace sonar with trace (DCP-11/9/00)
var vecFrom[3];
var vecTo[3];

var temp2[3];	// another temp var


//SYNONYM player { TYPE ENTITY; }
//SYNONYM temp_ent { TYPE ENTITY; }
//SYNONYM carry { TYPE ACTION; }
entity*	player;	// pointer to player entity
entity*	temp_ent;
action*	carry;

DEFINE _MODE_NONE,0;		// no movement (i.e. player dead)
DEFINE _MODE_WALKING,1;		// covers standing,walking, and running (speed dependent)
DEFINE _MODE_DRIVING,2;
DEFINE _MODE_SWIMMING,3;
DEFINE _MODE_DIVING,4;
DEFINE _MODE_WADING,5;
DEFINE _MODE_HELICOPTER,6;	// very primitive helicopter mode
DEFINE _MODE_ROCKETEER,7;
DEFINE _MODE_DUCKING,8;		// ducking
DEFINE _MODE_JUMPING,9;		// jumping
DEFINE _MODE_CRAWLING,10;	// crawling
DEFINE _MODE_TRANSITION,14; // transitioning between modes
DEFINE _MODE_STILL,15;

DEFINE _MODE_PLANE,16;
DEFINE _MODE_CHOPPER,17;


// modes 20 and above are handled by a different wdl
DEFINE _MODE_ATTACK,20;

DEFINE _SOUND_WALKER,1;
DEFINE _SOUND_ROBOT,2;

DEFINE _TYPE_PLAYER,1;
DEFINE _TYPE_ACTOR,2;
DEFINE _TYPE_FOE,3;
DEFINE _TYPE_DOOR,10;
DEFINE _TYPE_GATE,11;
DEFINE _TYPE_ELEVATOR,12;
DEFINE _TYPE_GUN,20;
DEFINE _TYPE_AMMO,21;
DEFINE _TYPE_ARMOR,22;
DEFINE _TYPE_HEALTH,23;

DEFINE _FOG_UNDERWATER,2;	// fog color 2 is used for underwater fog

//SOUND beep_sound,<beep.wav>;
//SYNONYM debugsyn { TYPE ENTITY; }



/////////////////////////////////////////////////////////////////////////
//@ MISC movement functions


/////////////////////////////////////////////////////////////////////////
//@ animate.wdl function prototype
function	actor_anim_transition(str_anim_target,trans_ticks);

var	q_anim_trans_use = 0;


/////////////////////////////////////////////////////////////////////////
// Desc: player tips over, can be used for death
function player_tip()
{
	MY._MOVEMODE = 0;	// suspend normal movement action
	eye_height_up.Z = eye_height_up;	// store original eye height
	while(MY.ROLL < 80)
	{
		MY.ROLL += 8 * TIME;
		MY.TILT += 2 * TIME;
		if(eye_height_up > 0.15)
		{
			eye_height_up -= 0.1 * TIME;
		}

		if(client_moving==0) { move_view(); }
		wait(1);
	}
	MY.ROLL = 80;
	MY.TILT = 20;
	eye_height_up = eye_height_up.Z;	// restore original eye height
}



////////////////////////////////////////////////////////////////////////
// Desc: event action to indicate any event by resetting the event flag
//
//]- Mod Date: 6/9/00 Doug Poston
//]-				changed to function
function _setback()
{
	if(EVENT_TYPE == EVENT_BLOCK) { MY.ENABLE_BLOCK = OFF; }
	if(EVENT_TYPE == EVENT_ENTITY) { MY.ENABLE_ENTITY = OFF; }
	if(EVENT_TYPE == EVENT_STUCK) { MY.ENABLE_STUCK = OFF; }

	if(EVENT_TYPE == EVENT_PUSH) { MY.ENABLE_PUSH = OFF; }
	if(EVENT_TYPE == EVENT_IMPACT) { MY.ENABLE_IMPACT = OFF; }

	if(EVENT_TYPE == EVENT_DETECT) { MY.ENABLE_DETECT = OFF; }
	if(EVENT_TYPE == EVENT_SCAN) { MY.ENABLE_SCAN = OFF; }
	if(EVENT_TYPE == EVENT_SHOOT) { MY.ENABLE_SHOOT = OFF; }
	if(EVENT_TYPE == EVENT_TRIGGER) { MY.ENABLE_TRIGGER = OFF; }

	if(EVENT_TYPE == EVENT_TOUCH) { MY.ENABLE_TOUCH = OFF; }
	if(EVENT_TYPE == EVENT_RELEASE) { MY.ENABLE_RELEASE = OFF; }
	if(EVENT_TYPE == EVENT_CLICK) { MY.ENABLE_CLICK = OFF; }
}



// Mod Date: 6/9/00 Doug Poston
//				changed to function
function _beep() { BEEP; }

// Desc: play some kinds of foot sound
//
//]- Mod Date: 6/9/00 Doug Poston
//]-				changed to function
function _play_walksound()
{
	if((ME == player) && (person_3rd == 0)) { return; }	// don't play entity sounds for 1st person player
	//if(MY._WALKSOUND == _SOUND_WALKER) { play_entsound(ME,thud,60); }
	//if(MY._WALKSOUND == _SOUND_ROBOT) { play_entsound(ME,robo_thud,60); }
}


// Desc: test code. make object passable and remove after 128 ticks
function _test_arrow()
{
	MY.PASSABLE = ON;
	MY.alpha = 25;
	MY.transparent = ON;
	MY.SCALE_X = 0.45;
	MY.SCALE_Y = 0.45;
	waitt(32);//(128);
	remove(ME);
}




// INCLUDED CODE (originally part of movement.wdl
include <move.wdl>;
include <camera.wdl>;	// handle camera movement
include <animate.wdl>;  // handle animation
include <input.wdl>;    // handle user input (mouse, keyboard, joystick, ..)