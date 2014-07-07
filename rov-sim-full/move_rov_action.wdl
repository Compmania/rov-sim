var move_dist[3];  							// Create array move_dist - needed to use move_dist.x y z
var deep_count;								// Create variable deep_count (used on depth gauge)


			///////////////////////////////////////////////////////////////////////////////
			// This portion is used to create the action move_ROV. Actions in 3D Gamestudio
			// Work much like a function, but they are specifically assigned to entities in
			// the WED program. This action tells the game how to move the ROV with the
			// on-screen controls.
			///////////////////////////////////////////////////////////////////////////////

action move_ROV								// Create move_ROV action
{
	
			//////////////////////////////////////////////////////////////////////////
			// my is a pointer referring to the entity that this action is assigned to
			//////////////////////////////////////////////////////////////////////////
			// my.narrow and my.fat are used by 3D Gamestudio to calculate the size of
			// the entity in regards to collisions. If the ROV gets a certain distance
			// away from a rock, for example. These tell the game engine "when" the
			// ROV "hits" the surface of it. I found having these on simulates
			// realistic size quite well.
			//////////////////////////////////////////////////////////////////////////
	
	my.narrow = on;							// Turn my.narrow on	
	my.fat = on;								// Turn my.fat on
	

	while(1)										// Put all conditions inside a while loop
	{

		/////////////////////////////////////////////////////////////////////////
		// Create the portion of the topographical grid that moves the ROV
		/////////////////////////////////////////////////////////////////////////
		// Definition - The u_dot variable is created in panel_function.wdl
		// this variable is set to the variable of the dot panel and is offset
		// to represent the exact center point of the dot. This makes the center
		// point of the dot the place where speed changes when it is moved around
		// the grid.
		/////////////////////////////////////////////////////////////////////////
		// Logic - If the u_dot variable x & y positions are inside each
		// respective square of the grid (defined in defines.wdl), change the
		// move_dist variable in that respective axis and/or change the speed
		// of the left (+=) or the right (-=) of the my.pan variable (my = entity
		// and pan is the left or right turning of that entity)
		/////////////////////////////////////////////////////////////////////////
		// Variable definition - 	the dot_*_*_lx, _ty, _rx, and _by variables
		// were defined in the defines.wdl file, and each represents the
		// coordinates of the outside edges of the grids in the topographical
		// grid. Each number inside the variable describes the row and column
		// of that square. 
		// 
		// 1_1 = row 1 (top) column 1 (left)
		// 2_2 = row 2 (next down from 1) column 2 (next right from 1)
		// 3_3 = row 3 (next down from 2) column 3 (next right from 2)
		// 4_4 = row 4 (next down from 3) column 4 (next right from 3) (center row & column)
		// 5_5 = row 5 (next down from 4) column 5 (next right from 4)
		// 6_6 = row 6 (next down from 5) column 6 (next right from 5)
		// 7_7 = row 7 (next down from 6) column 7 (next right from 6) (bottom right)
		//
		// dot_*_*_lx (top left x coordinate of square)
		// dot_*_*_ty (top left y coordinate of square)
		// dot_*_*_rx (bottom right x coordinate of square)
		// dot_*_*_by (bottom right y coordinate of square)
		/////////////////////////////////////////////////////////////////////////


		////////////////////////////////////////////////////////////////////////
		// Row 1		-		Starts from the top down, moving left to right!	
		////////////////////////////////////////////////////////////////////////		
		
		if ((u_dot.pos_x >= dot_1_1_lx) && (u_dot.pos_y >= dot_1_1_ty) && (u_dot.pos_x <= dot_1_1_rx) && (u_dot.pos_y <= dot_1_1_by))
			
			{
				move_dist.y = sn_fast;
				my.pan += sp_fast;
			}
		
		if ((u_dot.pos_x >= dot_1_2_lx) && (u_dot.pos_y >= dot_1_2_ty) && (u_dot.pos_x <= dot_1_2_rx) && (u_dot.pos_y <= dot_1_2_by))
			{
				move_dist.y = sn_fast;
				my.pan += sp_med;
			}
		
		if ((u_dot.pos_x >= dot_1_3_lx) && (u_dot.pos_y >= dot_1_3_ty) && (u_dot.pos_x <= dot_1_3_rx) && (u_dot.pos_y <= dot_1_3_by))
			{
				move_dist.y = sn_fast;
				my.pan += sp_slow;
			}
		
		if ((u_dot.pos_x >= dot_1_4_lx) && (u_dot.pos_y >= dot_1_4_ty) && (u_dot.pos_x <= dot_1_4_rx) && (u_dot.pos_y <= dot_1_4_by))
			{
				move_dist.y = sn_fast;
			}
			
		if ((u_dot.pos_x >= dot_1_5_lx) && (u_dot.pos_y >= dot_1_5_ty) && (u_dot.pos_x <= dot_1_5_rx) && (u_dot.pos_y <= dot_1_5_by))
			{
				move_dist.y = sn_fast;
				my.pan += ns_slow;
			}
		
		if ((u_dot.pos_x >= dot_1_6_lx) && (u_dot.pos_y >= dot_1_6_ty) && (u_dot.pos_x <= dot_1_6_rx) && (u_dot.pos_y <= dot_1_6_by))
			{
				move_dist.y = sn_fast;
				my.pan += ns_med;
			}
		
		if ((u_dot.pos_x >= dot_1_7_lx) && (u_dot.pos_y >= dot_1_7_ty) && (u_dot.pos_x <= dot_1_7_rx) && (u_dot.pos_y <= dot_1_7_by))
			{
				move_dist.y = sn_fast;
				my.pan += ns_fast;
						
			}
		
		
		////////////////////////////////////////////////////////////////////////
		// Row 2
		////////////////////////////////////////////////////////////////////////		
		
		if ((u_dot.pos_x >= dot_2_1_lx) && (u_dot.pos_y >= dot_2_1_ty) && (u_dot.pos_x <= dot_2_1_rx) && (u_dot.pos_y <= dot_2_1_by))
			{
				move_dist.y = sn_med;
				my.pan += sp_fast;
			}
		
		if ((u_dot.pos_x >= dot_2_2_lx) && (u_dot.pos_y >= dot_2_2_ty) && (u_dot.pos_x <= dot_2_2_rx) && (u_dot.pos_y <= dot_2_2_by))
			{
				move_dist.y = sn_med;
				my.pan += sp_med;
			}
		
		if ((u_dot.pos_x >= dot_2_3_lx) && (u_dot.pos_y >= dot_2_3_ty) && (u_dot.pos_x <= dot_2_3_rx) && (u_dot.pos_y <= dot_2_3_by))
			{
				move_dist.y = sn_med;
				my.pan += sp_slow;
			}
		
		if ((u_dot.pos_x >= dot_2_4_lx) && (u_dot.pos_y >= dot_2_4_ty) && (u_dot.pos_x <= dot_2_4_rx) && (u_dot.pos_y <= dot_2_4_by))
			{
				move_dist.y = sn_med;
			}
			
		if ((u_dot.pos_x >= dot_2_5_lx) && (u_dot.pos_y >= dot_2_5_ty) && (u_dot.pos_x <= dot_2_5_rx) && (u_dot.pos_y <= dot_2_5_by))
			{
				move_dist.y = sn_med;
				my.pan += ns_slow;
			}
		
		if ((u_dot.pos_x >= dot_2_6_lx) && (u_dot.pos_y >= dot_2_6_ty) && (u_dot.pos_x <= dot_2_6_rx) && (u_dot.pos_y <= dot_2_6_by))
			{
				move_dist.y = sn_med;
				my.pan += ns_med;
			}
		
		if ((u_dot.pos_x >= dot_2_7_lx) && (u_dot.pos_y >= dot_2_7_ty) && (u_dot.pos_x <= dot_2_7_rx) && (u_dot.pos_y <= dot_2_7_by))
			{
				move_dist.y = sn_med;
				my.pan += ns_fast;
						
			}
		
		
		////////////////////////////////////////////////////////////////////////
		// Row 3
		////////////////////////////////////////////////////////////////////////		
		
		if ((u_dot.pos_x >= dot_3_1_lx) && (u_dot.pos_y >= dot_3_1_ty) && (u_dot.pos_x <= dot_3_1_rx) && (u_dot.pos_y <= dot_3_1_by))
			{
				move_dist.y = sn_slow;
				my.pan += sp_fast;
			}
		
		if ((u_dot.pos_x >= dot_3_2_lx) && (u_dot.pos_y >= dot_3_2_ty) && (u_dot.pos_x <= dot_3_2_rx) && (u_dot.pos_y <= dot_3_2_by))
			{
				move_dist.y = sn_slow;
				my.pan += sp_med;
			}
		
		if ((u_dot.pos_x >= dot_3_3_lx) && (u_dot.pos_y >= dot_3_3_ty) && (u_dot.pos_x <= dot_3_3_rx) && (u_dot.pos_y <= dot_3_3_by))
			{
				move_dist.y = sn_slow;
				my.pan += sp_slow;
			}
		
		if ((u_dot.pos_x >= dot_3_4_lx) && (u_dot.pos_y >= dot_3_4_ty) && (u_dot.pos_x <= dot_3_4_rx) && (u_dot.pos_y <= dot_3_4_by))
			{
				move_dist.y = sn_slow;
			}
			
		if ((u_dot.pos_x >= dot_3_5_lx) && (u_dot.pos_y >= dot_3_5_ty) && (u_dot.pos_x <= dot_3_5_rx) && (u_dot.pos_y <= dot_3_5_by))
			{
				move_dist.y = sn_slow;
				my.pan += ns_slow;
			}
		
		if ((u_dot.pos_x >= dot_3_6_lx) && (u_dot.pos_y >= dot_3_6_ty) && (u_dot.pos_x <= dot_3_6_rx) && (u_dot.pos_y <= dot_3_6_by))
			{
				move_dist.y = sn_slow;
				my.pan += ns_med;
			}
		
		if ((u_dot.pos_x >= dot_3_7_lx) && (u_dot.pos_y >= dot_3_7_ty) && (u_dot.pos_x <= dot_3_7_rx) && (u_dot.pos_y <= dot_3_7_by))
			{
				move_dist.y = sn_slow;
				my.pan += ns_fast;
						
			}
		
		
		////////////////////////////////////////////////////////////////////////
		// Row 4
		////////////////////////////////////////////////////////////////////////		
		
		if ((u_dot.pos_x >= dot_4_1_lx) && (u_dot.pos_y >= dot_4_1_ty) && (u_dot.pos_x <= dot_4_1_rx) && (u_dot.pos_y <= dot_4_1_by))
			{
				move_dist.y = 0;
				my.pan += sp_fast;
			}
		
		if ((u_dot.pos_x >= dot_4_2_lx) && (u_dot.pos_y >= dot_4_2_ty) && (u_dot.pos_x <= dot_4_2_rx) && (u_dot.pos_y <= dot_4_2_by))
			{
				move_dist.y = 0;
				my.pan += sp_med;
			}
		
		if ((u_dot.pos_x >= dot_4_3_lx) && (u_dot.pos_y >= dot_4_3_ty) && (u_dot.pos_x <= dot_4_3_rx) && (u_dot.pos_y <= dot_4_3_by))
			{
				move_dist.y = 0;
				my.pan += sp_slow;
			}
		
		if ((u_dot.pos_x >= dot_4_4_lx) && (u_dot.pos_y >= dot_4_4_ty) && (u_dot.pos_x <= dot_4_4_rx) && (u_dot.pos_y <= dot_4_4_by))
			{
				move_dist.y = 0;
			}
			
		if ((u_dot.pos_x >= dot_4_5_lx) && (u_dot.pos_y >= dot_4_5_ty) && (u_dot.pos_x <= dot_4_5_rx) && (u_dot.pos_y <= dot_4_5_by))
			{
				move_dist.y = 0;
				my.pan += ns_slow;
			}
		
		if ((u_dot.pos_x >= dot_4_6_lx) && (u_dot.pos_y >= dot_4_6_ty) && (u_dot.pos_x <= dot_4_6_rx) && (u_dot.pos_y <= dot_4_6_by))
			{
				move_dist.y = 0;
				my.pan += ns_med;
			}
		
		if ((u_dot.pos_x >= dot_4_7_lx) && (u_dot.pos_y >= dot_4_7_ty) && (u_dot.pos_x <= dot_4_7_rx) && (u_dot.pos_y <= dot_4_7_by))
			{
				move_dist.y = 0;
				my.pan += ns_fast;	
				
			}
		
		////////////////////////////////////////////////////////////////////////
		// Row 5
		////////////////////////////////////////////////////////////////////////		
		
		if ((u_dot.pos_x >= dot_5_1_lx) && (u_dot.pos_y >= dot_5_1_ty) && (u_dot.pos_x <= dot_5_1_rx) && (u_dot.pos_y <= dot_5_1_by))
			{
				move_dist.y = nn_slow;
				my.pan += sp_fast;
			}
		
		if ((u_dot.pos_x >= dot_5_2_lx) && (u_dot.pos_y >= dot_5_2_ty) && (u_dot.pos_x <= dot_5_2_rx) && (u_dot.pos_y <= dot_5_2_by))
			{
				move_dist.y = nn_slow;
				my.pan += sp_med;
			}
		
		if ((u_dot.pos_x >= dot_5_3_lx) && (u_dot.pos_y >= dot_5_3_ty) && (u_dot.pos_x <= dot_5_3_rx) && (u_dot.pos_y <= dot_5_3_by))
			{
				move_dist.y = nn_slow;
				my.pan += sp_slow;
			}
		
		if ((u_dot.pos_x >= dot_5_4_lx) && (u_dot.pos_y >= dot_5_4_ty) && (u_dot.pos_x <= dot_5_4_rx) && (u_dot.pos_y <= dot_5_4_by))
			{
				move_dist.y = nn_slow;
			}
			
		if ((u_dot.pos_x >= dot_5_5_lx) && (u_dot.pos_y >= dot_5_5_ty) && (u_dot.pos_x <= dot_5_5_rx) && (u_dot.pos_y <= dot_5_5_by))
			{
				move_dist.y = nn_slow;
				my.pan += ns_slow;
			}
		
		if ((u_dot.pos_x >= dot_5_6_lx) && (u_dot.pos_y >= dot_5_6_ty) && (u_dot.pos_x <= dot_5_6_rx) && (u_dot.pos_y <= dot_5_6_by))
			{
				move_dist.y = nn_slow;
				my.pan += ns_med;
			}
		
		if ((u_dot.pos_x >= dot_5_7_lx) && (u_dot.pos_y >= dot_5_7_ty) && (u_dot.pos_x <= dot_5_7_rx) && (u_dot.pos_y <= dot_5_7_by))
			{
				move_dist.y = nn_slow;
				my.pan += ns_fast;
						
			}
		
		
		////////////////////////////////////////////////////////////////////////
		// Row 6
		////////////////////////////////////////////////////////////////////////		
		
		if ((u_dot.pos_x >= dot_6_1_lx) && (u_dot.pos_y >= dot_6_1_ty) && (u_dot.pos_x <= dot_6_1_rx) && (u_dot.pos_y <= dot_6_1_by))
			{
				move_dist.y = nn_med;
				my.pan += sp_fast;
			}
		
		if ((u_dot.pos_x >= dot_6_2_lx) && (u_dot.pos_y >= dot_6_2_ty) && (u_dot.pos_x <= dot_6_2_rx) && (u_dot.pos_y <= dot_6_2_by))
			{
				move_dist.y = nn_med;
				my.pan += sp_med;
			}
		
		if ((u_dot.pos_x >= dot_6_3_lx) && (u_dot.pos_y >= dot_6_3_ty) && (u_dot.pos_x <= dot_6_3_rx) && (u_dot.pos_y <= dot_6_3_by))
			{
				move_dist.y = nn_med;
				my.pan += sp_slow;
			}
		
		if ((u_dot.pos_x >= dot_6_4_lx) && (u_dot.pos_y >= dot_6_4_ty) && (u_dot.pos_x <= dot_6_4_rx) && (u_dot.pos_y <= dot_6_4_by))
			{
				move_dist.y = nn_med;
			}
			
		if ((u_dot.pos_x >= dot_6_5_lx) && (u_dot.pos_y >= dot_6_5_ty) && (u_dot.pos_x <= dot_6_5_rx) && (u_dot.pos_y <= dot_6_5_by))
			{
				move_dist.y = nn_med;
				my.pan += ns_slow;
			}
		
		if ((u_dot.pos_x >= dot_6_6_lx) && (u_dot.pos_y >= dot_6_6_ty) && (u_dot.pos_x <= dot_6_6_rx) && (u_dot.pos_y <= dot_6_6_by))
			{
				move_dist.y = nn_med;
				my.pan += ns_med;
			}
		
		if ((u_dot.pos_x >= dot_6_7_lx) && (u_dot.pos_y >= dot_6_7_ty) && (u_dot.pos_x <= dot_6_7_rx) && (u_dot.pos_y <= dot_6_7_by))
			{
				move_dist.y = nn_med;
				my.pan += ns_fast;
						
			}
		
		////////////////////////////////////////////////////////////////////////
		// Row 7		-		Bottom row!
		////////////////////////////////////////////////////////////////////////		
		
		if ((u_dot.pos_x >= dot_7_1_lx) && (u_dot.pos_y >= dot_7_1_ty) && (u_dot.pos_x <= dot_7_1_rx) && (u_dot.pos_y <= dot_7_1_by))
			{
				move_dist.y = nn_fast;
				my.pan += sp_fast;
			}
		
		if ((u_dot.pos_x >= dot_7_2_lx) && (u_dot.pos_y >= dot_7_2_ty) && (u_dot.pos_x <= dot_7_2_rx) && (u_dot.pos_y <= dot_7_2_by))
			{
				move_dist.y = nn_fast;
				my.pan += sp_med;
			}
		
		if ((u_dot.pos_x >= dot_7_3_lx) && (u_dot.pos_y >= dot_7_3_ty) && (u_dot.pos_x <= dot_7_3_rx) && (u_dot.pos_y <= dot_7_3_by))
			{
				move_dist.y = nn_fast;
				my.pan += sp_slow;
			}
		
		if ((u_dot.pos_x >= dot_7_4_lx) && (u_dot.pos_y >= dot_7_4_ty) && (u_dot.pos_x <= dot_7_4_rx) && (u_dot.pos_y <= dot_7_4_by))
			{
				move_dist.y = nn_fast;
			}
			
		if ((u_dot.pos_x >= dot_7_5_lx) && (u_dot.pos_y >= dot_7_5_ty) && (u_dot.pos_x <= dot_7_5_rx) && (u_dot.pos_y <= dot_7_5_by))
			{
				move_dist.y = nn_fast;
				my.pan += ns_slow;
			}
		
		if ((u_dot.pos_x >= dot_7_6_lx) && (u_dot.pos_y >= dot_7_6_ty) && (u_dot.pos_x <= dot_7_6_rx) && (u_dot.pos_y <= dot_7_6_by))
			{
				move_dist.y = nn_fast;
				my.pan += ns_med;
			}
		
		if ((u_dot.pos_x >= dot_7_7_lx) && (u_dot.pos_y >= dot_7_7_ty) && (u_dot.pos_x <= dot_7_7_rx) && (u_dot.pos_y <= dot_7_7_by))
			{
				move_dist.y = nn_fast;
				my.pan += ns_fast;
						
			}
		

		
		
		////////////////////////////////////////////////////////////////////////
		// Create the portion of the vertical slider that moves the character
		////////////////////////////////////////////////////////////////////////
		// Definitions - select_panel is detecting the x & y coordinates of the
		// top left of the selection panel (defined in panel.wdl)
		// this is used in conjunction with panel_function.wdl where the actual
		// looping code tells how the panel moves around and where it can go.
		////////////////////////////////////////////////////////////////////////
		// Logic - if the panel is set at specific coordinates (grid) then
		// the ROV will move along the z axis at different speeds.
		// The deep_count variable is also set here so that the four incremental
		// buttons will change the speed based upon the current speed.
		////////////////////////////////////////////////////////////////////////
		// Location - all speed variables (up_fast, dn_slow, etc...) are defined
		// inside the defines.wdl file
		////////////////////////////////////////////////////////////////////////
		
		////////////////////
		// Top depth grid
		////////////////////
		
			if (select_panel.pos_x == 579) && (select_panel.pos_y == 145)
													// If the panel is located at the top grid
		{

			move_dist.z = up_fast;			// Move upward at full thrust
			deep_count = 1;					// Set deep_count to 1
			wait(1);								// Wait 1 sec.
		}
		
		
		/////////////////////////////
		// Second depth grid from top
		/////////////////////////////
		
			if	(select_panel.pos_x == 579) && (select_panel.pos_y == 164)
													// If the panel is located at the 2nd from the top grid
		{
			
		////////////////////////////////////////////////////////////////////////////////////
		// Logic - if the thruster is not at full up or down thrust, and the deep_count does
		// not equil this panel already, set the speed to add up_med.
		////////////////////////////////////////////////////////////////////////////////////
		
			if (move_dist.z != up_fast) || (move_dist.z != dn_fast) && (deep_count != 2)
			{
				if (mouse_left == 1)				// If the user clicks on the grid
				{
					move_dist.z += up_med;		// This will add up_med to the current speed
				}
				else									// Otherwise, set the speed to up_med.
				{
					move_dist = up_med;
				}
			}
			
														// Otherwise, set the speed to up_med.
			else
			{
				move_dist.z = up_med;
			}
			deep_count = 2;						// Set deep_count to 2
			wait(1);									// Wait 1 sec.
		}
		
		
		////////////////////////////
		// Third depth grid from top
		////////////////////////////
		
			if (select_panel.pos_x == 579) && (select_panel.pos_y == 184)
		{
			
		
		////////////////////////////////////////////////////////////////////////////////////
		// Logic - if the thruster is not at full up or down thrust, and the deep_count does
		// not equil this panel already, set the speed to add up_slow.
		////////////////////////////////////////////////////////////////////////////////////
					
			if (move_dist.z != up_fast) || (move_dist.z != dn_fast) && (deep_count != 3)
			{
				if (mouse_left == 1)				// If the user clicks on the grid
				{
					move_dist.z += up_slow;		// This will add up_slow to the current speed
				}
				else
				{
					move_dist = up_slow;			// Otherwise, set the speed to up_slow
				}
			}
			
			else
			{
				move_dist.z = up_slow;			// Otherwise, set the speed to up_slow
			}
			deep_count = 3;						// Set deep_count to 3
			wait(1);									// Wait 1 sec.
		}
		
		
		/////////////////////////////
		// Fourth - Center depth grid
		/////////////////////////////
		
			if (select_panel.pos_x == 579) && (select_panel.pos_y == 203)
		{			
			move_dist.z = 0;						// Set thrusters to all stop
			deep_count = 4;						// Set deep_count to 4
			wait(1);									// Wait 1 sec.
			
		}
		
		
		///////////////////
		// Fifth depth grid
		///////////////////
		
			if (select_panel.pos_x == 579) && (select_panel.pos_y == 223)
		{
			
		////////////////////////////////////////////////////////////////////////////////////
		// Logic - if the thruster is not at full up or down thrust, and the deep_count does
		// not equil this panel already, set the speed to add dn_slow (a negative number).
		////////////////////////////////////////////////////////////////////////////////////
			
			if (move_dist.z != up_fast) || (move_dist.z != dn_fast) && (deep_count != 5)
			{
				if (mouse_left == 1)				// If the mouse is clicked
				{
					move_dist.z += dn_slow;		// This will add dn_slow to current speed (negative variable)
				}
				else
				{
					move_dist = dn_slow;			// Otherwise, set speed to dn_slow
				}
			}
			
			else
			{
				move_dist.z = dn_slow;			// Otherwise, set speed to dn_slow
			}
			deep_count = 5;						// Set deep_count to 5
			wait(1);									// Wait 1 sec.
			
		}
		
		///////////////////
		// Sixth depth grid
		///////////////////
		
			if (select_panel.pos_x == 579) && (select_panel.pos_y == 242)
		{
			
		////////////////////////////////////////////////////////////////////////////////////
		// Logic - if the thruster is not at full up or down thrust, and the deep_count does
		// not equil this panel already, set the speed to add dn_med (a negative number).
		////////////////////////////////////////////////////////////////////////////////////
			
			if (move_dist.z != up_fast) || (move_dist.z != dn_fast) && (deep_count != 6)
			{
				if (mouse_left == 1)				// If the mouse is clicked
				{
					move_dist.z += dn_med;		// This will add dn_med to current speed (negative variable)
				}
				else
				{
					move_dist = dn_med;			// Otherwise, set speed to dn_med
				}
			}
			
			else
			{
				move_dist.z = dn_med;			// Otherwise, set speed to dn_med
			}
			deep_count = 6;						// Set deep_count to 6
			wait(1);									// Wait 1 sec.
			
		}
		
		
		//////////////////////////////
		// Seventh depth grid (bottom)
		//////////////////////////////
		
			if (select_panel.pos_x == 579) && (select_panel.pos_y == 262)
		{
			move_dist.z = dn_fast;				// Move downward at full thrust
			deep_count = 7;						// Set deep_count to 7
			wait(1);									// Wait 1 sec.
		}
		
		
		/////////////////////////////////////////////////////////////////////
		// Logic - These set constraints to the upward and downward thrusters
		// If the number gets above or below the fastest speed, set thrust to
		// full speed.
		///////////////////////////////////////////////////////////////////// 
		
		
		if (move_dist.z > up_fast)
		{
			move_dist.z = up_fast;
		}
		if (move_dist.z < dn_fast)
		{
			move_dist.z = dn_fast;
		}
		
		
		
		
		/*
		
		////////////////////////////////////////////////////////////////////////////
		// Info - This code was left in to aid in the future use of the simulator
		// These each accomidate the use of the keyboard as well as the on-screen
		// controls. As you can see, it is fairly straight-foreward as far as how
		// to include keys to run the same things as the on-screen controls.
		//
		// To check keyboard codes, go to the 3D Gamestudio help file inside SED,
		// search for key and look for key functions inside the key help file.
		// This will give you a list of all the keyboard calls that could be needed.
		////////////////////////////////////////////////////////////////////////////
	
		
		if (key_cuu)
		{
			move_dist.y = sn_fast;
		}
		if (key_cud)
		{
			move_dist.y = nn_fast;
		}
		if (key_cul)
		{
			my.pan += sp_fast;
		}
		if (key_cur)
		{
			my.pan += ns_fast;
		}
		if (key_a)
		{
			move_dist.z = up_fast;
		}
		if (key_z)
		{
			move_dist.z = dn_fast;
		}

	*/
		

		//////////////////////////////////////////////////////////////////////////////////
		// C_move function - this is what makes the ROV actually move inside the simulator
		// the calls it makes refer to different portions of the simulator:
		//
		// my - the entity, in this case, the ROV
		//
		// move_dist - this is the array that includes the x, y, and z planes the the ROV
		// moves along. This is passed in as the movement variable of the ROV.
		//
		// surgedir - this is the function surgedir. In order for the surge to affect the
		// ROV, it has to push against it at all times. In this case, if the ROV is moving
		// or not, it will push against it, this is very similar to using wind against an
		// entity.
		//
		// glide - This is part of the 3D Gamestudio program, it tells the c_move function
		// that the ROV must glide along solid object that it encounters. This makes
		// pressing against a rock similar to the real world where you can still move
		// slightly even when pushed against an object.
		//////////////////////////////////////////////////////////////////////////////////


		c_move (my, move_dist, surgedir, glide);
	
	

		///////////////////////////////////////////////////////////
		// Set the function key properties
		///////////////////////////////////////////////////////////
		// Logic - These each work in a fashion where if the panel
		// (created in panel.wdl) is moved in a particular location
		// (from panel_function.wdl) then a specific function
		// is then called. 
		//
		// This MUST be done because the panel_function.wdl file
		// contains one single function and you cannot call another
		// function from within a function without difficulties.
		//
		// So, to get around this, the code is seperated between
		// the files so a function call can be made based on where
		// the panel is located.
		///////////////////////////////////////////////////////////

if (camera_select.pos_x == cam1_lx) && (camera_select.pos_y == cam1_ty)
{
	FuncCamera();
	wait(1);
}

if (camera_select.pos_x == cam2_lx) && (camera_select.pos_y == cam2_ty)
{
	FuncCamera2();
	wait(1);
}

if (camera_select.pos_x == cam3_lx) && (camera_select.pos_y == cam3_ty)
{
	FuncCamera3();
	wait(1);
}

if (surge_select.pos_x == surge_on_lx) && (surge_select.pos_y == surge_on_ty)
{
	changesurge();										// Start the surge function
	wait(1);
}

if (surge_select.pos_x == surge_off_lx) && (surge_select.pos_y == surge_off_ty)
{
	nosurge();											// No surge
	wait(1);
}

if (day_select.pos_x == day_lx) && (day_select.pos_y == day_ty)
{
	

	////////////////////////////////////////////////////
	// Set the fog effects that are used inside the game
	////////////////////////////////////////////////////
 	
 	CLIP_RANGE = 2000;							// Set the clip range of fog (overall area that it is used)
 	camera.fog = 1; 								// Definition so that shadows aren't affected by fog  
 	FOG_COLOR = 3; 								// set global fog to #3 from WED, this is green fog
   camera.fog_start = 0.15 * clip_range; 	// fog from 15% of clip_range
	camera.fog_end = 0.85 * clip_range; 	// fog until 85% of clip_range
	wait(1);
}

if (day_select.pos_x == night_lx) && (day_select.pos_y == night_ty)
{
	

	//////////////////////////////////////////////////////////
	// Set the night fog effects that are used inside the game
	//////////////////////////////////////////////////////////
 	
 	CLIP_RANGE = 2000;							// Set the clip range of fog (overall area that it is used)
 	camera.fog = 1; 								// Definition so that shadows aren't affected by fog  
 	FOG_COLOR = 1; 								// set global fog to #1 from WED, this is black fog
   camera.fog_start = 0.2 * clip_range; 	// fog from 2% of clip_range
	camera.fog_end = 0.5 * clip_range; 		// fog until 5% of clip_range
	wait(1);
}

	
	
	
	
	
	
	
	
	
		wait(1);		
	}	

	
}


