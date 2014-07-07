///////////////////////////////////////////////////////////////////////////////////////
// Create the panels
///////////////////////////////////////////////////////////////////////////////////////
// Info - each variable assigned to bitmaps are used only between the definition of the
// variable and its use in creating the panel. These variables are not what is
// needed to call panels themselves.
///////////////////////////////////////////////////////////////////////////////////////

//////////////
// Menu images
//////////////

bmap menu_backg = <Main.bmp>; 					// Assign main.bmp to menu_backg variable
bmap credits = <Credits.bmp>; 					// Assign credits.bmp to credits variable
bmap how_to = <Help_prep_ROV.bmp>; 			// Assign help_prep_rov.bmp to how_to variable


/////////////////////////
// How-to help box images
/////////////////////////

bmap grid_hlp = <grid_help.bmp>; 				// Assign grid_help.bmp to grid_hlp variable
bmap dot_hlp = <dot_help.bmp>; 					// Assign dot_help.bmp to dot_hlp variable
bmap depth_hlp = <depth_help.bmp>; 			// Assign depth_help.bmp to depth_hlp variable
bmap function_hlp = <function_help.bmp>; 	// Assign function_help.bmp to function_hlp variable
bmap screen_hlp = <screen_help.bmp>; 			// Assign screen_help.bmp to screen_hlp variable


////////////////
// Button images
////////////////

bmap how_button = <How.bmp>; 					// Assign how.bmp to how_button variable
bmap quit = <Quit.bmp>; 							// Assign quit.bmp to quit variable
bmap run = <run.bmp>; 								// Assign run.bmp to run variable
bmap credit_button = <credit_button.bmp>; 	// Assign credit_button.bmp to credit_button variable
bmap back_button = <back.bmp>; 					// Assign back.bmp to back_button variable


/////////////////////////////
// Panel images for simulator
/////////////////////////////

BMAP under_dot = <under_dot.pcx>;				// Assign under_dot.pcx to under_dot variable
BMAP dot_map = <dot.tga>;							// Assign dot.tga to dot_map variable
BMAP sur_select = <select_surge.tga>;			// Assign select_surge.tga to sur_select variable
BMAP cam_select = <select_camera.tga>;			// Assign select_camera.tga to cam_select variable
BMAP day_i_select = <select_day.tga>;			// Assign select_day.tga to day_i_select variable
BMAP grid_lft = <grid.pcx>;						// Assign grid.pcx to grid_left variable
BMAP grid_map = <grid2.pcx>;						// Assign grid2.pcx to grid_map variable
BMAP select_map = <select.pcx>;					// Assign select.pcx to select_map variable


///////////////////////////////////////////////////////////////////////////////
// Create the specific panels used in the simulator
///////////////////////////////////////////////////////////////////////////////
// Info - higher layers set here will show up above others. This is similar to
// how programs like Photoshop use layers. 
//
// Buttons are created using the button
// call and then define the x,y coordinates of the top-left corner of the panel
// used as a button, then the on-off-over bitmaps used based on how the mouse
// interacts with the button, and finally the on-off-over functions that are
// called in the same fashion.
//
// Flags are different settings that can be used inside the game. Most
// useful is whether the panel is visible from the start or not.
//
// D3D supposedly set it to be used with Direct 3D programming, but I have
// never seen a difference between using it or not...
///////////////////////////////////////////////////////////////////////////////

//////////
// Credits
//////////


panel credits_pan										// Define the credits_pan panel
{
bmap credits; 											// Call the credits variable as the bitmap
layer = 40;												// Set the layer number
button =	15, 426, back_button, back_button, back_button, show_menubar, null, null; // Back to main menu
															// Set the back button with these parameters

FLAGS D3D;												// Set the flags
}


/////////
// How-to
/////////


panel how_pan											// Define the how_pan panel
{
bmap how_to;											// Call the how_to variable as the bitmap
button =	520, 430, back_button, back_button, back_button, show_menubar, null, null;
															// Set the back button with these parameters
layer = 41;												// Set the layer
flags D3D;												// Set the flags
}


////////////
// Main Menu
////////////

panel menubar_pan										// Define the menubar_pan panel
{
bmap menu_backg; 										// Call the menu_backg variable as the bitmap
LAYER = 42;												// Set the layer
button =	333, 214, run, run, run, start_game, null, null; 											
button =	333, 273, how_button, how_button, how_button, show_how_to, null, null; 				
button =	333, 333, credit_button, credit_button, credit_button, show_credits, null, null; 
button =	333, 389, quit, quit, quit, quit_game, null, null; 									
															// Set buttons to start, how-to, credits, and quit
FLAGS = D3D, visible;									// Set the flags
}


/////////////////////////////////////////////////////
// Left grid panel (camera window seperate from grid)
/////////////////////////////////////////////////////

PANEL grid_lf											// Define the grid_lf panel
{
BMAP grid_lft;											// Call the grid_lft variable as the bitmap
pos_x = 0;												// Set the x position
pos_y = 0;												// Set the y position
LAYER = 4;												// Set the layer
FLAGS = OVERLAY, VISIBLE;							// Set the flags (note: black in an image with overlay enables renders the black transparent!)
}


////////////////////////////////
// Right grid panel (grid panel)
////////////////////////////////

panel grid_panel										// Define the grid_panel panel
{
bmap grid_map;											// Call the grid_map variable as the bitmap
pos_x = 397;											// Set the x position												// Set the y position
LAYER = 14;												// Set the layer

FLAGS = D3D, VISIBLE;										// Set the flags
}

////////////////////
// Control Dot panel
////////////////////

panel dot_panel										// Define the dot_panel panel
{
	BMAP dot_map;										// Call the dot_map variable as the bitmap
   pos_x = 459;										// Set the x position
   pos_y = 205;										// Set the y position
   layer = 16;											// Set the layer (above the grid)
   flags = visible;									// Set the flags
}


/////////////////////////////////////////////////////////////////////////////////
// Underneath the control dot panel
// (This is used to define the center of the dot, so that particular point
// is what registers when the dot moves over the grid rather than the top corner)
/////////////////////////////////////////////////////////////////////////////////

panel u_dot												// Define the u_dot panel
{
	bmap under_dot;									// Call the under_dot variable as the bitmap
	pos_x = 467;										// Set the x position
	pos_y = 205;										// Set the y position
	layer = 15;											// Set the layer (under the dot layer)
	flags = transparent;								// Make this flag transparent!
}


//////////////////////////////////////////////////////
// Selection panel - used to select on the depth gauge
//////////////////////////////////////////////////////

panel select_panel									// Define the select_panel panel
{
	BMAP select_map;									// Call the select_map variable as the bitmap
	pos_x = 640;										// Set the x position
	pos_y = 480;										// Set the y position
	layer = 17;											// Set the layer (above the grid)
	flags = visible;									// Set the flags
}


/////////////////////////////////////////////////////
// Function selection panels
/////////////////////////////////////////////////////

panel camera_select									// Define the camera_select panel
{
	bmap cam_select;									// Call the cam_select variable
	pos_x = 400;										// Set the x position
	pos_y = 330;										// Set the y position
	layer = 31;											// Set the layer (above the grid)
	flags = visible, overlay;						// Set the flags (note: black in an image with overlay enables renders the black transparent!)
}

panel surge_select									// Define the surge_select panel
{
	bmap sur_select;									// Call the sur_select variable
	pos_x = 441;										// Set the x position
	pos_y = 368;										// Set the y position
	layer = 32;											// Set the layer
	flags = visible, overlay;						// Set the flags (note: black in an image with overlay enables renders the black transparent!)
}

panel day_select										// Define the day_select panel
{
	bmap day_i_select;								// Call the day_i_select variable
	pos_x = 441;										// Set the x position
	pos_y = 400;										// Set the y position
	layer = 33;											// Set the layer
	flags = visible, overlay;						// Set the flags (note: black in an image with overlay enables renders the black transparent!)
}


//////////////////////////////
// Grid-help information panel
//////////////////////////////

panel grid_help										// Define the grid_help panel
{	
	bmap grid_hlp;										// Call the grid_hlp variable as the bitmap
	pos_x = 18;											// Set the x position
	pos_y = 220;										// Set the y position
	layer = 50;											// Set the layer (above the how-to panel)
	flags = D3D;										// Set the flags
}

panel dot_help											// Define the dot_help panel
{
	bmap dot_hlp;										// Call the dot_hlp variable as the bitmap
	pos_x = 18;											// Set the x position
	pos_y = 220;										// Set the y position
	layer = 51;											// Set the layer (above the how-to panel)
	flags = D3D;										// Set the flags
}

panel depth_help										// Define the depth_help panel
{
	bmap depth_hlp;									// Call the depth_hlp variable as the bitmap
	pos_x = 18;											// Set the x position
	pos_y = 220;										// Set the y position
	layer = 52;											// Set the layer (above the how-to panel)
	flags = D3D;										// Set the flags
}

panel function_help									// Define the function_help panel
{
	bmap function_hlp;								// Call the function_hlp variable as the bitmap
	pos_x = 18;											// Set the x position
	pos_y = 220;										// Set the y position
	layer = 53;											// Set the layer (above the how-to panel)
	flags = D3D;										// Set the flags
}

panel screen_help										// Define the screen_help panel
{
	bmap screen_hlp;									// Call the screen_hlp variable as the bitmap
	pos_x = 18;											// Set the x position
	pos_y = 220;										// Set the y position
	layer = 54;											// Set the layer (above the how-to panel)
	flags = D3D;										// Set the flags
}