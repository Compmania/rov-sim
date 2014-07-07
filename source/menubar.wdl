////////////////////////////////////////////////////////
// These functions are used for the startup menu screens
////////////////////////////////////////////////////////

function start_game()							// Define the start_game function
{	
	////////////////////////////////////////////////////////////////////
	// Set the black selection boxes to specific locations at game start
	////////////////////////////////////////////////////////////////////
	
	select_panel.pos_x = 579;					// Vertical selection in center
	select_panel.pos_y = 203;					// Vertical selection in center
	
	camera_select.pos_x = cam1_lx;			// Camera selection at ROV Camera
	camera_select.pos_y = cam1_ty;			// Camera selection at ROV Camera
	
	bubble(4000,4000,2000,5000);  			// Start the particles (called bubble(s)...)
	freeze_mode = 0;								// Un-freeze the game
	wait(3);											// Wait 3 seconds so everything loads correctly

	screen_help.visible = off;					// Turn screen_help panel off
	function_help.visible = off;				// Turn function_help panel off
	dot_help.visible = off;						// Turn dot_help panel off
	grid_help.visible = off;					// Turn grid_help panel off
	depth_help.visible = off;					// Turn depth_help panel off
	Menubar_pan.visible = OFF;  				// Turn main menu panel off
	Credits_pan.visible = off;					// Turn credits panel off
	How_pan.visible = off;						// Turn how-to panel off
	
	
}

function quit_game()								// Define the quit_game function
{
	exit;												// Exit the ROVing Otter Simulator
}

function show_how_to()							// Define the show_how_to function
{
	Credits_pan.visible = off;					// Turn credits panel off
	Menubar_pan.visible = off;					// Turn main menu panel off
	How_pan.visible = on;						// Turn how-to panel off

while (how_pan.visible == on)					// While the how-to panel is visible...
{
	
	
			/////////////////////////////////////////////////////////////////////////////////////
			// Logic - While the mouse is INSIDE the grid, if the user clicks on the dot, the dot
			// help panel is visible. If the user clicks anywhere else in the grid, the grid help
			// panel is visible.
			/////////////////////////////////////////////////////////////////////////////////////
	
	
	while (mouse_pos.x >= 397) && (mouse_pos.x <= 555) && (mouse_pos.y >= 140) && (mouse_pos.y <= 285) && (mouse_pos.x != dot_4_4_lx) && (mouse_pos.y != dot_4_4_ty) && (mouse_pos.x != dot_4_4_rx) && (mouse_pos.y != dot_4_4_by)
														// While the mouse is inside the grid area...
	{
		if (mouse_pos.x >= dot_4_4_lx) && (mouse_pos.y >= dot_4_4_ty) && (mouse_pos.x <= dot_4_4_rx) && (mouse_pos.y <= dot_4_4_by) && (mouse_left == 1)
		
														// If the mouse is in the dot area... Turn dot_help panel on
	{
		
															
		screen_help.visible = off;				// Turn screen_help panel off
		function_help.visible = off;			// Turn function_help panel off
		depth_help.visible = off;				// Turn depth_help panel off
		grid_help.visible = off;				// Turn grid_help panel off
		dot_help.visible = on;					// Turn dot_help panel on
		wait(1);										// Wait 1 sec.
	}
	
	else												// When mouse is not in dot area...
	{
	
	if (mouse_left == 1)							// This would mean the mouse clicks on the grid, so grid_help turns on
	{
		screen_help.visible = off;				// Turn screen_help panel off
		function_help.visible = off;			// Turn function_help panel off
		depth_help.visible = off;				// Turn depth_help panel off
		dot_help.visible = off;					// Turn dot_help panel off
		grid_help.visible = on;					// Turn grid_help panel on
	wait(1);											// Wait 1 sec.
	}
	
	}
	
	wait (1);										// Wait 1 sec. (must be used in while loops)
	
	}
	
	
			////////////////////////////////////////////////////////////////////////////////
			// Logic - While the mouse is inside the depth bar, if the mouse is clicked, the 
			// depth help panel is visible.
			////////////////////////////////////////////////////////////////////////////////
	
	
	while (mouse_pos.x >= 577) && (mouse_pos.x <= 598) && (mouse_pos.y >= 143) && (mouse_pos.y <= 281)
														// While the mouse is inside depth bar
	{
		if (mouse_left == 1)						// If the mouse is clicked
		{
		
		screen_help.visible = off;				// Turn screen_help panel off
		function_help.visible = off;			// Turn function_help panel off
		grid_help.visible = off;				// Turn grid_help panel off
		dot_help.visible = off;					// Turn dot_help panel off
		depth_help.visible = on;				// Turn depth_help panel on
		}
	
		
		wait(1);										// Wait 1 sec. (must be used in while loops)
	}
	
	
			////////////////////////////////////////////////////////////////////////////////
			// Logic - While the mouse is inside the function bar, if the mouse is clicked,
			// the function help panel is visible.
			////////////////////////////////////////////////////////////////////////////////
	
	
		while (mouse_pos.x >= 400) && (mouse_pos.y >= 330) && (mouse_pos.y <= 420)
															// While the mouse is inside function bar
	{
		if (mouse_left == 1)							// If the mouse is clicked
		{
		
		screen_help.visible = off;					// Turn screen_help panel off
		grid_help.visible = off;					// Turn grid_help panel off
		dot_help.visible = off;						// Turn dot_help panel off
		depth_help.visible = off;					// Turn depth_help panel off
		function_help.visible = on;				// Turn function_help panel on
		}
		
		
		wait(1);											// Wait 1 sec. (must be used in while loops)
	}
	
	
			////////////////////////////////////////////////////////////////////////////////
			// Logic - While the mouse is inside the camera screen, if the mouse is clicked,
			// the screen help panel is visible.
			////////////////////////////////////////////////////////////////////////////////
	
	
		while (mouse_pos.x >= 4) && (mouse_pos.x <= 390) && (mouse_pos.y >= 26) && (mouse_pos.y <= 453)
															// While the mouse is inside camera screen
	{
		if (mouse_left == 1)							// If the mouse is clicked
		{
		
		grid_help.visible = off;					// Turn grid_help panel off
		dot_help.visible = off;						// Turn dot_help panel off
		depth_help.visible = off;					// Turn depth_help panel off
		function_help.visible = off;				// Turn function_help panel off
		screen_help.visible = on;					// Turn screen_help panel on
		}
		
		
		wait(1);											// Wait 1 sec. (must be used in while loops)
	}


			////////////////////////////////////////////////////////////////////////////////
			// Logic - If the mouse is clicked, and no other conditions are true, turn off
			// help panels. (blank screen area)
			////////////////////////////////////////////////////////////////////////////////

	
		if (mouse_left == 1)							// If mouse clicked on green area
		{
			screen_help.visible = off;				// Turn screen_help panel off
			function_help.visible = off;			// Turn function_help panel off
			grid_help.visible = off;				// Turn grid_help panel off
			dot_help.visible = off;					// Turn dot_help panel off
			depth_help.visible = off;				// Turn depth_help panel off
			wait(1);										// Wait 1 sec.
		}

	wait(1);												// Wait 1 sec. (must be used in while loops)
	}

	
}


function show_menubar()								// Define the show_menubar function
{
	dot_help.visible = off;							// Turn dot_help panel off
	grid_help.visible = off;						// Turn grid_help panel off
	depth_help.visible = off;						// Turn depth_help panel off
	function_help.visible = off;					// Turn function_help panel off
	screen_help.visible = off;						// Turn screen_help panel off
	How_pan.visible = off;							// Turn how-to panel off
	Credits_pan.visible = OFF;						// Turn credits panel off
	Menubar_pan.visible= ON;						// Turn menubar panel on
}
	
function show_credits()								// Define the show_credits function
{
	dot_help.visible = off;							// Turn dot_help panel off
	grid_help.visible = off;						// Turn grid_help panel off
	depth_help.visible = off;						// Turn depth_help panel off
	function_help.visible = off;					// Turn function_help panel off
	screen_help.visible = off;						// Turn screen_help panel off
	How_pan.visible = off;							// Turn how-to panel off
	Menubar_pan.visible = OFF;						// Turn menubar panel off
	Credits_pan.visible = ON;						// Turn credits panel on
	
}