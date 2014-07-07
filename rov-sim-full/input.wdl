// Template file v5.202 (02/20/02)
////////////////////////////////////////////////////////////////////////
// File: input.wdl
//		WDL prefabs for user input (mouse, keyboard, joystick, ..)
////////////////////////////////////////////////////////////////////////
// Use:
//		Include AFTER "movment.wdl"
//



//@ Input Defines
DEFINE _HANDLE,1;		// SCAN via space key
DEFINE _EXPLODE,2;	// SCAN by an explosion
DEFINE _GUNFIRE,3;	// SHOOT fired by a gun
DEFINE _WATCH,4;		// looking for an enemy
DEFINE _DETECTED,5;	// detected by an enemy
DEFINE _SHOOT1,6;		// shoot key pressed (not used yet)


//@ Input Vars
var indicator = 0;


var mouseview = 1;  		// mouse factor, set 0 to disable mouse



//@ Input Function Protypes

function _player_intentions();	// core function handling input from the player

function do_handle();		// Handle action, calls 'scan_handle'
function scan_handle();		// scan a cone using '_HANDLE' indicator
function perform_handle();	// checks for receiving a handle signal
function send_handle();		// send a handle signal (player._SIGNAL = _HANDLE;)

function mouse_to_level();	// set TARGET to a point in the level under mouse pointer, return distance


//@ Input Functions

/////////////////////////////////////////////////////////////////////////
// Desc: Get key input from the player
//
// Set aforce & force values using player input (keyboard/mouse/joystick)
// Make sure these values are within limit
//
function _player_intentions()
{
// Set the angular forces according to the player intentions
	aforce.PAN = -astrength.PAN*(KEY_FORCE.X+JOY_FORCE.X);
	aforce.TILT = astrength.TILT*(KEY_PGUP-KEY_PGDN);
	if(MOUSE_MODE == 0)
	{	// Mouse switched off?
		 aforce.PAN += -astrength.PAN*MOUSE_FORCE.X*mouseview*(1+KEY_SHIFT);
		 aforce.TILT += astrength.TILT*MOUSE_FORCE.Y*mouseview*(1+KEY_SHIFT);
	}
	aforce.ROLL = 0;
// Set ROLL force if ALT was pressed
	if(KEY_ALT != 0)
	{
		aforce.ROLL = aforce.PAN;
		aforce.PAN = 0;
	}
// Double the forces in case the player pressed SHIFT
/*--	if(KEY_SHIFT != 0)
	{
		aforce.PAN += aforce.PAN;
		aforce.TILT += aforce.TILT;
		aforce.ROLL += aforce.ROLL;
	}--*/
// Limit the forces in case the player
// pressed buttons, mouse and joystick simultaneously
	limit.PAN = 2*astrength.PAN;
	limit.TILT = 2*astrength.TILT;
	limit.ROLL = 2*astrength.ROLL;

	if(aforce.PAN > limit.PAN) {  aforce.PAN = limit.PAN; }
	if(aforce.PAN < -limit.PAN) {  aforce.PAN = -limit.PAN; }
	if(aforce.TILT > limit.TILT) {  aforce.TILT = limit.TILT; }
	if(aforce.TILT < -limit.TILT) {  aforce.TILT = -limit.TILT; }
	if(aforce.ROLL > limit.ROLL) {  aforce.ROLL = limit.ROLL; }
	if(aforce.ROLL < -limit.ROLL) {  aforce.ROLL = -limit.ROLL; }

// Set the cartesian forces according to the player intentions
	force.X = strength.X*(KEY_FORCE.Y+JOY_FORCE.Y);  // forward/back
	force.Y = strength.Y*(KEY_COMMA-KEY_PERIOD);     // side to side
	force.Z = strength.Z*(KEY_HOME-KEY_END);         // up and down
	if(MOUSE_MODE == 0)
	{	// Mouse switched off?
		force.X += strength.X*MOUSE_RIGHT*mouseview;
	}

// Double the forces in case the player pressed SHIFT
/*--	if(KEY_SHIFT != 0)
	{
		force.X += force.X;
		force.Y += force.Y;
		force.Z += force.Z;
	}--*/

// Limit the forces in case the player tried to cheat by
// operating buttons, mouse and joystick simultaneously

	limit.X = 2*strength.X;
	limit.Y = 2*strength.Y;
	limit.Z = 2*strength.Z;

	if(force.X > limit.X) {  force.X = limit.X; }
	if(force.X < -limit.X) { force.X = -limit.X; }
	if(force.Y > limit.Y) {  force.Y = limit.Y; }
	if(force.Y < -limit.Y) { force.Y = -limit.Y; }
	if(force.Z > limit.Z) {  force.Z = limit.Z; }
	if(force.Z < -limit.Z) { force.Z = -limit.Z; }
}



////////////////////////////////////////////////////////////////////////
// Desc: Handle action. Set to SPACE by default.
// Will operate doors or items within 200 quants.
//
function do_handle()
{
	if(player != NULL)
	{
		MY_POS.X = player.X;
		MY_POS.Y = player.Y;
		MY_POS.Z = player.Z;
		MY_ANGLE.PAN = player.PAN;
	}
	else
	{
		MY_POS.X = CAMERA.X;
		MY_POS.Y = CAMERA.Y;
		MY_POS.Z = CAMERA.Z;
		MY_ANGLE.PAN = CAMERA.PAN;
	}
	MY_ANGLE.TILT = CAMERA.TILT;
	scan_handle();
}


/////////////////////////////////////////////////////////////////////////
// Desc: scan a wide cone of 200 quants range
function scan_handle()
{
	temp.PAN = 120;
	temp.TILT = 180;
	temp.Z = 200;
	indicator = _HANDLE;
	scan(MY_POS,MY_ANGLE,temp);
}



/////////////////////////////////////////////////////////////////////////
// Desc: This action can be run by a player entity on the server
// 		It checks for receiving a handle signal, then performs a scan
function perform_handle()
{
	while(1)
	{
		if(MY._SIGNAL == _HANDLE)
		{	// client has pressed handle key
			my._SIGNAL = 0;				// reset it
			vec_set(my_pos,my.x);
			vec_set(my_angle,my.pan);
			scan_handle();
		}
		wait(1);
	}
}

/////////////////////////////////////////////////////////////////////////
// Desc: send a '_HANDLE' signal
function send_handle()
{
	if(player != NULL)
	{
		player._SIGNAL = _HANDLE;	// send command to perform a scan
		send(player._SIGNAL);
	}
}


/////////////////////////////////////////////////////////////////////
// Desc: set TARGET to a point in the map that appears under the mouse pointer
//			returns the distance to that point
//
// Modifies: vecTo, vecFrom, TARGET, NORMAL, YOU, TEX_NAME, TEX_LIGHT
// Returns: distance to TARGET (or 0 if NULL)
function mouse_to_level()
{
	vecFrom.X = MOUSE_POS.X;
	vecFrom.Y = MOUSE_POS.Y;
	vecFrom.Z = 10;
	vec_set(vecTo,vecFrom);
	vec_for_screen(vecFrom,CAMERA); // near point

	vecTo.Z = 5000;
	vec_for_screen(vecTo,CAMERA);   // far point

	return(trace(vecFrom,vecTo));  // trace a line between the two points
}





/////////////////////////////////////////////////////////////////////
//jcl (key assignments always at the end)
ON_SPACE send_handle;