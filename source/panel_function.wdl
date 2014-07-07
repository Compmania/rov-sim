/////////////////////////////////////////////////////////////
// Panel function
/////////////////////////////////////////////////////////////
// This is the function that does all the magic with the dot.
// It keep the dot constrained inside the grid, and tells
// the game engine that you can click on it, and move it
// around.
/////////////////////////////////////////////////////////////


function DotPanelPos()											// Create the DotPanelPos function
{

	///////////////////////////////////////////////////////////////////////////
	// Logic - while the mouse pointer is inside the grid, if the mouse is on
	// the dot, and while the mouse is held down, the dot moves with the mouse.
	// If the mouse is let go, the dot snaps back to the center of the grid.
	// Boundries are also set - see below.
	///////////////////////////////////////////////////////////////////////////
		
	while (mouse_pos.x >= 397) && (mouse_pos.x <= 555) && (mouse_pos.y >= 140) && (mouse_pos.y <= 285)
																		// While inside the grid
	{
	if (mouse_pos.x >= dot_4_4_lx) && (mouse_pos.y >= dot_4_4_ty) && (mouse_pos.x <= dot_4_4_rx) && (mouse_pos.y <= dot_4_4_by)
																		// If the mouse is on the dot
	{
		
	 while (mouse_left == 1) 									// While the left mouse button is clicked
		{
			u_dot.pos_x = dot_panel.pos_x + 8;				// Set the x coordinate of the u_dot to the center of the dot
			u_dot.pos_y = dot_panel.pos_y + 8;				// Set the y coordinate of the u_dot to the center of the dot
		
		// This makes sure the dot location stays inside the grid box.
		
			if ((dot_panel.pos_x >= dot_1_1_lx) && (dot_panel.pos_y >= dot_1_1_ty) && (dot_panel.pos_x < dot_special_x) && (dot_panel.pos_y < dot_special_y))
																		// If the dot is inside the grid
			{
				dot_panel.pos_x = mouse_pos.x - 4;			// Keep the dot's x with the mouse
				dot_panel.pos_y = mouse_pos.y - 4;			// Keep the dot's y with the mouse
			}
			

			else														// Otherwise
			{
			
				while (mouse_pos.x > dot_1_1_lx) && (mouse_pos.y > dot_1_1_ty) && (mouse_pos.x < dot_special_x) && (mouse_pos.y < dot_special_y)
																		// While the mouse is inside the grid
				{
			
					dot_panel.pos_x = mouse_pos.x - 4;		// Keep the dot's x with the mouse
					dot_panel.pos_y = mouse_pos.y - 4;		// Keep the dot's y with the mouse
					u_dot.pos_x = dot_panel.pos_x + 8;		// Set the x coordinate of the u_dot to the center of the dot
					u_dot.pos_y = dot_panel.pos_y + 8;		// Set the y coordinate of the u_dot to the center of the dot
					wait(1);											// Wait 1 sec. (required in while statements)
				}
	
	
	////////////////////////////////////////////////////////////////////////////////////////		
	// These while statements check for the boundaries and make the dot stay inside the grid
	////////////////////////////////////////////////////////////////////////////////////////
					
					// Checks Bottom Left & Y-axis
					
				while (mouse_pos.x > dot_special_x) && (mouse_pos.y > dot_1_1_ty) && (mouse_pos.y < dot_special_y) && (mouse_left == 1)
																		// While the mouse is outside the grid & the mouse is still held down
				{
					dot_panel.pos_x = 518;						// Keep the x coordinate of the dot along 518 (right)
					dot_panel.pos_y = mouse_pos.y - 4;		// Keep the dot's y with the mouse
					u_dot.pos_x = dot_panel.pos_x + 8;		// Set the x coordinate of the u_dot to the center of the dot
					u_dot.pos_y = dot_panel.pos_y + 8;		// Set the y coordinate of the u_dot to the center of the dot
					wait(1);											// Wait 1 sec. (required in while statements)
				}			
					// Checks Top Left & Y-axis
					
				while (mouse_pos.x < dot_1_1_lx) && (mouse_pos.y > dot_1_1_ty) && (mouse_pos.y < dot_special_y) && (mouse_left == 1)
																		// While the mouse is outside the grid & the mouse is still held down
				{
					dot_panel.pos_x = 399;						// Keep the x coordinate of the dot along 399 (left)
					dot_panel.pos_y = mouse_pos.y - 4;		// Keep the dot's y with the mouse
					u_dot.pos_x = dot_panel.pos_x + 8;		// Set the x coordinate of the u_dot to the center of the dot
					u_dot.pos_y = dot_panel.pos_y + 8;		// Set the y coordinate of the u_dot to the center of the dot
					wait(1);											// Wait 1 sec. (required in while statements)
				}
					// Checks Bottom Right & X-axis
					
				while (mouse_pos.y > dot_special_y) && (mouse_pos.x > dot_1_1_lx) && (mouse_pos.x < dot_special_x) && (mouse_left == 1)
																		// While the mouse is outside the grid & the mouse is still held down
				{
					dot_panel.pos_x = mouse_pos.x - 4;		// Keep the dot's x with the mouse
					dot_panel.pos_y = 264;						// Keep the y coordinate of the dot along 264 (bottom)
					u_dot.pos_x = dot_panel.pos_x + 8;		// Set the x coordinate of the u_dot to the center of the dot
					u_dot.pos_y = dot_panel.pos_y + 8;		// Set the y coordinate of the u_dot to the center of the dot
					wait(1);											// Wait 1 sec. (required in while statements)
				}
					// Checks Top Right & X-axis
				
				while (mouse_pos.y < dot_1_1_ty) && (mouse_pos.x > dot_1_1_lx) && (mouse_pos.x < dot_special_x) && (mouse_left == 1)
																		// While the mouse is outside the grid & the mouse is still held down
				{
					dot_panel.pos_x = mouse_pos.x - 4;		// Keep the dot's x with the mouse
					dot_panel.pos_y = 145;						// Keep the y coordinate of the dot along 145 (top)
					u_dot.pos_x = dot_panel.pos_x + 8;		// Set the x coordinate of the u_dot to the center of the dot
					u_dot.pos_y = dot_panel.pos_y + 8;		// Set the y coordinate of the u_dot to the center of the dot
					wait(1);											// Wait 1 sec. (required in while statements)
				}
	
	
	
	//////////////////////////////////////////////////////////////////////////////			
	// These while statements check the corners of the grid and keep the dot there
	//////////////////////////////////////////////////////////////////////////////
	// Logic - if the mouse goes outside the grid in one of the four corners, then
	// the dot should stay stuck in that corner activating that particular ROV
	// speed.
	//////////////////////////////////////////////////////////////////////////////
	
					// Upper Right-hand Corner
						
				while (mouse_pos.x >= dot_special_x) && (mouse_pos.y <= dot_1_1_ty) && (mouse_left == 1)
																		// While the mouse is outside the grid & the mouse is still held down
				{
					dot_panel.pos_x = 517;						// Keep the dot at x = 517
					dot_panel.pos_y = 146;						// Keep the dot at y = 146
					u_dot.pos_x = dot_panel.pos_x + 8;		// Set the x coordinate of the u_dot to the center of the dot
					u_dot.pos_y = dot_panel.pos_y + 8;		// Set the y coordinate of the u_dot to the center of the dot
					wait(1);											// Wait 1 sec. (required in while statements)
				}			
				
					// Upper Left-hand Corner
					
				while (mouse_pos.x < dot_1_1_lx) && (mouse_pos.y < dot_1_1_ty) && (mouse_left == 1)
																		// While the mouse is outside the grid & the mouse is still held down
				{
					dot_panel.pos_x = 399;						// Keep the dot at x = 399
					dot_panel.pos_y = 145;						// Keep the dot at y = 145
					u_dot.pos_x = dot_panel.pos_x + 8;		// Set the x coordinate of the u_dot to the center of the dot
					u_dot.pos_y = dot_panel.pos_y + 8;		// Set the y coordinate of the u_dot to the center of the dot
					wait(1);											// Wait 1 sec. (required in while statements)
				}
				
					// Lower Right-hand Corner
				
				while (mouse_pos.x > dot_special_x) && (mouse_pos.y > dot_special_y) && (mouse_left == 1)
																		// While the mouse is outside the grid & the mouse is still held down
				{
					dot_panel.pos_x = 518;						// Keep the dot at x = 518
					dot_panel.pos_y = 264;						// Keep the dot at y = 264
					u_dot.pos_x = dot_panel.pos_x + 8;		// Set the x coordinate of the u_dot to the center of the dot
					u_dot.pos_y = dot_panel.pos_y + 8;		// Set the y coordinate of the u_dot to the center of the dot
					wait(1);											// Wait 1 sec. (required in while statements)
				}
				
					// Lower Left-hand Corner
				
				while (mouse_pos.x < dot_1_1_lx) && (mouse_pos.y > dot_special_y) && (mouse_left == 1)
																		// While the mouse is outside the grid & the mouse is still held down
				{
					dot_panel.pos_x = 399;						// Keep the dot at x = 399
					dot_panel.pos_y = 264;						// Keep the dot at y = 264
					u_dot.pos_x = dot_panel.pos_x + 8;		// Set the x coordinate of the u_dot to the center of the dot
					u_dot.pos_y = dot_panel.pos_y + 8;		// Set the y coordinate of the u_dot to the center of the dot
					wait(1);											// Wait 1 sec. (required in while statements)
				}
				
				
			wait(1);													// Wait 1 sec.
			}
	
		wait(1);														// Wait 1 sec. (required in while statements)
		}
		
			
		//////////////////////////////////////////////////////////
		// This checks that the mouse left button is not held down
		//////////////////////////////////////////////////////////
		
		while (mouse_left == 0) 
		{
			dot_panel.pos_x = 459;								// Return the dot to the center of the grid
			dot_panel.pos_y = 205;								// Return the dot to the center of the grid
			u_dot.pos_x = dot_panel.pos_x + 8;				// Set the x coordinate of the u_dot to the center of the dot
			u_dot.pos_y = dot_panel.pos_y + 8;				// Set the y coordinate of the u_dot to the center of the dot
			wait(1);													// Wait 1 sec. (required in while statements)
		}	
		
		
		
		
			wait(1);													// Wait 1 sec.
			}
			
			
				wait(1);												// Wait 1 sec. (required in while statements)
				}
			
		////////////////////////////////////////////////////////
		// This checks that the mouse left button is not clicked
		////////////////////////////////////////////////////////
		// Info - this is done a second time as a backup outside
		// the while loop. Just to make sure nothing slips by...
		////////////////////////////////////////////////////////
		
		while (mouse_left == 0) 
		{
			dot_panel.pos_x = 459;								// Return the dot to the center of the grid
			dot_panel.pos_y = 205;								// Return the dot to the center of the grid
			u_dot.pos_x = dot_panel.pos_x + 8;				// Set the x coordinate of the u_dot to the center of the dot
			u_dot.pos_y = dot_panel.pos_y + 8;				// Set the y coordinate of the u_dot to the center of the dot
			wait(1);													// Wait 1 sec. (required in while statements)
		}	
			

	
	///////////////////////////////////////////////////////////////////////
	// This while loop checks when the mouse is inside the depth gauge area
	///////////////////////////////////////////////////////////////////////
	// Logic - while inside the depth gauge area, if the mouse is inside
	// a defined box, and the mouse clicks, the selection panel
	// (select_panel) is moved to that grid. 
	//
	// From there, the actual movement is defined inside the
	// move_rov_action.wdl file based on what panel is selected here.
	///////////////////////////////////////////////////////////////////////

while (mouse_pos.x >= 556) && (mouse_pos.y >= 140) && (mouse_pos.y <= 285)
{


		//////////////////
		// Top depth gauge
		//////////////////
		// Move panel here
		//////////////////
			
			if (mouse_pos.x >= box_1_lx) && (mouse_pos.y >= box_1_ty) && (mouse_pos.x <= box_1_rx) && (mouse_pos.y <= box_1_by) && (mouse_left == 1)
		{
			select_panel.pos_x = box_1_lx;
			select_panel.pos_y = box_1_ty;
			
		}
		
		///////////////////////////////////
		// Second depth gauge down from top
		///////////////////////////////////
		// Move panel here
		//////////////////
		
			if (mouse_pos.x >= box_2_lx) && (mouse_pos.y >= box_2_ty) && (mouse_pos.x <= box_2_rx) && (mouse_pos.y <= box_2_by) && (mouse_left == 1)
		{
			select_panel.pos_x = box_2_lx;
			select_panel.pos_y = box_2_ty;
			
		}
		
		//////////////////////////////////
		// Third depth gauge down from top
		//////////////////////////////////
		// Move panel here
		//////////////////
		
			if (mouse_pos.x >= box_3_lx) && (mouse_pos.y >= box_3_ty) && (mouse_pos.x <= box_3_rx) && (mouse_pos.y <= box_3_by) && (mouse_left == 1)
		{
			select_panel.pos_x = box_3_lx;
			select_panel.pos_y = box_3_ty;
			
		}
		
		///////////////////////////////////////
		// Fourth depth gauge from top (center)
		///////////////////////////////////////
		// Move panel here
		//////////////////
		
				if (mouse_pos.x >= box_4_lx) && (mouse_pos.y >= box_4_ty) && (mouse_pos.x <= box_4_rx) && (mouse_pos.y <= box_4_by) && (mouse_left == 1)
		{
			select_panel.pos_x = box_4_lx;
			select_panel.pos_y = box_4_ty;
			
		}
		
		//////////////////////////////////
		// Fifth depth gauge down from top
		//////////////////////////////////
		// Move panel here
		//////////////////
		
				if (mouse_pos.x >= box_5_lx) && (mouse_pos.y >= box_5_ty) && (mouse_pos.x <= box_5_rx) && (mouse_pos.y <= box_5_by) && (mouse_left == 1)
		{
			select_panel.pos_x = box_5_lx;
			select_panel.pos_y = box_5_ty;
			
		}
		
		/////////////////////////////
		// Sixth depth gauge from top
		/////////////////////////////
		// Move panel here
		//////////////////
		
				if (mouse_pos.x >= box_6_lx) && (mouse_pos.y >= box_6_ty) && (mouse_pos.x <= box_6_rx) && (mouse_pos.y <= box_6_by) && (mouse_left == 1)
		{
			select_panel.pos_x = box_6_lx;
			select_panel.pos_y = box_6_ty;
			
		}
		
		////////////////////////////////////////
		// Seventh depth gauge from top (bottom)
		////////////////////////////////////////
		// Move panel here
		//////////////////
		
				if (mouse_pos.x >= box_7_lx) && (mouse_pos.y >= box_7_ty) && (mouse_pos.x <= box_7_rx) && (mouse_pos.y <= box_7_by) && (mouse_left == 1)
		{
			select_panel.pos_x = box_7_lx;
			select_panel.pos_y = box_7_ty;
			
		}
		
		wait(1);														// Wait 1 sec. (required in while statements)
}



	/////////////////////////////////////////////////////////////////////
	// This while loop checks when the mouse is inside the function area
	/////////////////////////////////////////////////////////////////////
	// Logic - while inside the function area, if the mouse is inside
	// a defined box, and the mouse clicks, the function selection panels
	// are moved to that grid. 
	//
	// From there, the actual movement is defined inside the
	// move_rov_action.wdl file based on what panel is selected here.
	// (This works just like the depth gauge, except there are three
	// seperate panels that must stay in their defined locations - one
	// for the cameras, one for the surge, and one for night/day
	///////////////////////////////////////////////////////////////////////


while (mouse_pos.y >= 330) && (mouse_pos.x >= 400)
{

		
		//////////////////
		// Camera 1
		//////////////////
		// Move panel here
		//////////////////
	
			if (mouse_pos.x >= cam1_lx) && (mouse_pos.y >= cam1_ty) && (mouse_pos.x <= cam1_rx) && (mouse_pos.y <= cam1_by) && (mouse_left == 1)
		{
			camera_select.pos_x = cam1_lx;
			camera_select.pos_y = cam1_ty;
		}
		
		
		//////////////////
		// Camera 2
		//////////////////
		// Move panel here
		//////////////////
	
			if (mouse_pos.x >= cam2_lx) && (mouse_pos.y >= cam2_ty) && (mouse_pos.x <= cam2_rx) && (mouse_pos.y <= cam2_by) && (mouse_left == 1)
		{
			camera_select.pos_x = cam2_lx;
			camera_select.pos_y = cam2_ty;
		}
		
		
		//////////////////
		// Camera 3
		//////////////////
		// Move panel here
		//////////////////
	
			if (mouse_pos.x >= cam3_lx) && (mouse_pos.y >= cam3_ty) && (mouse_pos.x <= cam3_rx) && (mouse_pos.y <= cam3_by) && (mouse_left == 1)
		{
			camera_select.pos_x = cam3_lx;
			camera_select.pos_y = cam3_ty;
		}
		
		
		//////////////////
		// Surge Off/On
		//////////////////
		// Move panel here
		//////////////////
	
			if (mouse_pos.x >= surge_off_lx) && (mouse_pos.y >= surge_off_ty) && (mouse_pos.x <= surge_off_rx) && (mouse_pos.y <= surge_off_by) && (mouse_left == 1)
		{
			surge_select.pos_x = surge_off_lx;
			surge_select.pos_y = surge_off_ty;
		}
		
		
			if (mouse_pos.x >= surge_on_lx) && (mouse_pos.y >= surge_on_ty) && (mouse_pos.x <= surge_on_rx) && (mouse_pos.y <= surge_on_by) && (mouse_left == 1)
		{
			surge_select.pos_x = surge_on_lx;
			surge_select.pos_y = surge_on_ty;
		}
		
		
		//////////////////
		// Day/Night
		//////////////////
		// Move panel here
		//////////////////
		
			if (mouse_pos.x >= day_lx) && (mouse_pos.y >= day_ty) && (mouse_pos.x <= day_rx) && (mouse_pos.y <= day_by) && (mouse_left == 1)
		{
			day_select.pos_x = day_lx;
			day_select.pos_y = day_ty;
		}
		
			if (mouse_pos.x >= night_lx) && (mouse_pos.y >= night_ty) && (mouse_pos.x <= night_rx) && (mouse_pos.y <= night_by) && (mouse_left == 1)
		{
			day_select.pos_x = night_lx;
			day_select.pos_y = night_ty;
		}
	
		
		wait(1);														// Wait 1 sec. (required in while statements)
}






}