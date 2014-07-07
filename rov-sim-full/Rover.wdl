//////////////////////////////////////////////////////////////////
// Rover: The ROV Game - main script
//////////////////////////////////////////////////////////////////
// Originally created by David Bawiec as a Senior Capstone project
// for Dr. Steve Moore of the ESSP Department in the Fall of 2006
// at California State University: Monterey Bay
//////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////////
// The PATH keyword gives directories where game files can be found,
// relative to the level directory. In this instance, a path is made to the 3D Gamestudio
// (3DGS) directory for required files.
/////////////////////////////////////////////////////////////////////////////////////////

path "C:\\Program Files\\GStudio6\\template";
path "Images";
path "Models";

////////////////////////////////////////////////////////////////////////////
// The include keyword adds other script files to be compiled by 3DGS
////////////////////////////////////////////////////////////////////////////

include <movement.wdl>;		 			// Needed by 3DGS
include <messages.wdl>;		 			// Needed by 3DGS
include <menu.wdl>;		  	 			// Needed by 3DGS
include <actors.wdl>;   	 			// Needed by 3DGS
include <function_key.wdl>; 			// This removes 3DGS assigned function keys
include <panel.wdl>; 					// This script defines the on screen panels
include <defines.wdl>; 		 			// This script defines all the variables for the panels
include <panel_function.wdl>;  		// This script makes the red dot work
include <surge.wdl>;			 			// This script creates surge (underwater waves)


include <move_rov_action.wdl>; 		// This script is the action that moves the ROV
												// when attached to a character

include <water_particles.wdl>;		// This script creates the water particles (bubbles)
include <menubar.wdl>;		 			// This script is for the start up menus


////////////////////////////////////////////////////////////////////////////
// The following variables set the screen size, color, and window/fullscreen
////////////////////////////////////////////////////////////////////////////



IFDEF LORES;								// If lo-resolution is defined by computer
var video_depth = 8; 					// set to 256 colors maximum
var video_mode = 6; 						// 640x480

IFELSE;										// Otherwise
var video_mode = 6; 						// 640x480
var video_depth = 16;					// 16-bit color maximum

ENDIF;
var video_screen = 1; // Fullscreen mode



//////////////////////////////////////////////////
// Create the camera view that is seen by the user
//////////////////////////////////////////////////

view camera			// defines the only camera used
{
	pos_x = 4; 		// upper left edge 4 pixel right
	pos_y = 28; 	// upper left edge 28 pixel down
	size_x = 388;	// size x between left & right green areas
	size_y = 425;	// size y between top & bottom green areas
	layer = 11;		// sets the layer of the camera
}


/////////////////////////////////////////////////////////////////////////////////
// This string defines a link to the 3DGS main file through the keyword rov_level
/////////////////////////////////////////////////////////////////////////////////

string rov_level = <Rover.wmb>; // Give ROVER file name in angular brackets


/////////////////////////////////////////////////////////////////////////////
// These functions change the view of the camera based on which T# is chosen.
// All of these simply change the view and do not create seperate cameras.
/////////////////////////////////////////////////////////////////////////////


///////////////////////////////
// Create the 1st person camera
///////////////////////////////

Function FuncCamera()								// Define the 1st camera
{
while(1)
{
Camera.x = My.x;										// Camera's x location = ROV's x location
Camera.y = My.y;										// Camera's y location = ROV's y location
Camera.z = My.z + 10;								// Camera's z location = ROV's z location + 10 (so user does not run under ground)
Camera.Pan = My.Pan + 80;							// Set the pan of the camera (Z-axis) = ROV's pan + 65
camera.tilt = 0;										// Set the tilt of the camera (X-axis)
camera.genius = my; 									// Set the genius to the ROV
Camera.arc = min(camera.arc + time, 30);     // Field of view. Change last number for more/less viewable area
camera.ambient = 10;									// Is supposed to set the ambient "brightness" seen though the camera
wait(1);													// Wait is always needed in a while loop.
}
}


/////////////////////////////
// Create the top-view camera
/////////////////////////////

Function FuncCamera2()								// Define the 2nd camera
{
while(1)
{
Camera.x = my.x;										// Camera's x location = ROV's x location
Camera.y = my.y;										// Camera's y location = ROV's y location
Camera.z = my.z + 100;								// Camera's z location = 220 (above ROV)
Camera.Pan = my.pan + 90;							// Set the pan of the camera (z-axis) to 180
camera.tilt = -90;									// Set the tilt of the camera (x-axis) to -90
camera.genius = my; 									// Set the genius to the ROV
Camera.arc = 75; 										// Set the field of view as a static area
camera.ambient = 10;									// Is supposed to set the ambient "brightness" seen though the camera
wait(1);													// Wait is always needed in a while loop.
}
}


///////////////////////////////
// Create the 3rd person camera
///////////////////////////////

Function FuncCamera3()
{
while(1)
{
Camera.x = My.x + 120;								// Camera's x location = ROV's x location + 120 (behind)
Camera.y = My.y + 120;								// Camera's x location = ROV's x location + 120 (behind)
Camera.z = My.z + 60;								// Camera's x location = ROV's x location + 160 (above)
Camera.Pan = 225;										// Set the pan of the camera (z-axis) to 225
camera.tilt = -25;									// Turn the camera tilt down by -25
camera.genius = my;									// Set the genius to the ROV
Camera.arc = 50;								     	// Field of view. Change last number for more/less viewable area
camera.ambient = 10;									// Is supposed to set the ambient "brightness" seen though the camera
wait(1);													// Wait is always needed in a while loop.
}
}


/////////////////////////////////////////////////////////
// Set how the mouse cursor is to be initialized and used
/////////////////////////////////////////////////////////

BMAP arrow_map = <arrow.pcx>;			// Set the mouse arrow map to one similar to the MS mouse
function mouse_toggle 					// Switches the mouse on and off
{ 
MOUSE_MAP = arrow_map; 					// Sets the arrow as a mouse pointer
MOUSE_MODE += 2;							// Sets the mode of the mouse to one that clicks on things in the game



while (MOUSE_MODE > 0) 					// While the mouse moves over the screen
{ 
MOUSE_POS.X = POINTER.X;				// Set the defined mouse x position to variable pointer.x
MOUSE_POS.Y = POINTER.Y;				// Set the defined mouse y position to variable pointer.y
wait(1);										// Wait is always needed in a while loop.
}
}


///////////////////////////////////////////////
// The main() function is started at game start
///////////////////////////////////////////////

function main()									// Define the main function
{
	
	IFNDEF NOTEX; 													// Check if video card is weak
	
	D3D_TEXRESERVED = min(12000,D3D_TEXMEMORY/2);		// Drop down the texture memory for poor video cards
	
	ENDIF;															// End check
	
		
	////////////////////////////////////////////
	// Load the ROVER level into computer memory
	////////////////////////////////////////////
	
	level_load(rov_level);						// Load level defined earlier in this script
	freeze_mode = 1;								// freeze the game
	
	
	
	///////////////////////////////////////////////////////////
	// Set the video Frame Per Second requirements for the game
	///////////////////////////////////////////////////////////
	
	fps_min = 10;									// Minimum FPS is 10
	fps_max = 20;									// Maximum FPS is 20
	fps_lock = on;									// FPS is locked at 20 FPS Maximum
	
	
	/////////////////////////////////////////////////////////////////
	// Toggle the mouse settings that were set earlier in this script
	/////////////////////////////////////////////////////////////////
	
	mouse_toggle(); 								// Make the mouse a pointer that will work on-screen
	


	///////////////////////////////////////////////////////////////////////////
	// These functions are set to run if the user clicks or hits the escape key
	///////////////////////////////////////////////////////////////////////////
	
	on_click=DotPanelPos;						// On user mouse-click, run function DotPanelPos
	On_ESC = show_menubar;						// On user escape key press, show the menu bar
	

	////////////////////////////////////////////////////
	// Set the fog effects that are used inside the game
	// These are the default effects when game begins
	////////////////////////////////////////////////////
 	
 	CLIP_RANGE = 2000;							// Set the clip range of fog (overall area that it is used)
 	camera.fog = 1; 								// Definition so that shadows aren't affected by fog  
 	FOG_COLOR = 3; 								// set global fog to #3 from WED, this is green fog
   camera.fog_start = 0.15 * clip_range; 	// fog from 15% of clip_range
	camera.fog_end = 0.85 * clip_range; 	// fog until 85% of clip_range
	
}



/////////////////////////////////////////////////////////////////
// The following definitions are for 3DGS to work with 3D windows
/////////////////////////////////////////////////////////////////

WINDOW WINSTART												// Defines the window
{
	TITLE			"ROVER: THE ROV GAME";					// Sets the title of the window
	SIZE			388,425;										// Sets the x,y size of the window
	MODE			STANDARD;									// Sets a standard window mode
	BG_COLOR		RGB(240,240,240);							// Sets the background color to light-green
	FRAME			FTYP1,0,0,388,425;						// Sets the frame of the window
	TEXT_STDOUT	"Arial",RGB(0,0,0),10,10,460,280;	// Set the font type for the game
}