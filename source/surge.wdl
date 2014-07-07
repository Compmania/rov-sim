//////////////////////////////////////////
// Surge & no-surge functions
// These are called in move_rov_action.wdl
//////////////////////////////////////////


var surgedir[3];											// Create the array surgedir
var radius;													// Create the radius variable
var counter;												// Create the counter variable


starter sinCurve()										// Starter is a function that always runs
{ 
   while(1)													// While true,
   {
   
   //////////////////////////////////////////////////////////
   // Logic - This is the function that makes the surge work.
   // The radius is gathering the sine of the counter * 3. To
   // Change the length of the surge, change that number.
   //
   // The counter variable is then counting up and down based
   // on the sin call (it will stay between pos. 3 & neg. 3
   // because of this). Change the += number to increase or
   // decrease the speed based on the maximum number (3)
   //////////////////////////////////////////////////////////
   	
		radius = sin(counter)*3; 						// Radius = the sine of counter with a max of +/-3				
   	counter+=.75; 										// Counter = speed of travel along sine curve
   	wait(1);												// Wait 1 sec. (required in while statements)
   }
}


/*
		////////////////////////////////////////////////////////////////////
		// Info - this panel was left commented out for possible future use.
		// The purpose of this panel is to display the variable radius on
		// the screen at positions x = 20 y = 20. This helps to visually
		// see the number change if the surge function is changed.
		////////////////////////////////////////////////////////////////////

panel showValue											// Define panel showValue
{
   pos_x = 20;												// Set the x coordinate to 20
   pos_y = 20;												// Set the y coordinate to 20
   digits = 10,10,7.3,_a4font,1,radius;			// Set to digits, their size, # of digits, font, variables...
   layer = 80;												// Set the layer
   flags = visible;										// Set the flags
}
*/


function changesurge() 									// Define the function changesurge
{

while(1) 
{
	
/*

	////////////////////////////////////////////////////////////////////////
	// Info - this was the original code to create the surge based on random
	// variables. This was left in for information purposes, but the method
	// is not recommended. It "fakes" surge, but the effect is quite bumpy
	////////////////////////////////////////////////////////////////////////
	var my_angle;
	my_angle+=Random(180*time);
	my_angle-=Random(-180*time);
	radius = sin(my_angle)*5;

*/

	   ///////////////////////////////////////////////////////////////////////
	   // Info - Here is where the end result of the surge gets passed to the
	   // game engine. The vec_set sets the second set of vectors to the first
	   // so that the surge is held inside surgedir.x
	   // 
	   // vec_scale multiplies the two together so that the new variables are
	   // factoring in time to give a smooth effect.
	   ///////////////////////////////////////////////////////////////////////


	vec_set(surgedir,vector(radius,0,0));				// Pass the radius variable to the vector set
	vec_scale(surgedir,time);								// Set the scale to the surgedir variables and time.
	
wait(1);															// Wait 1 sec. (required in while statements)

}

}


////////////////////////////////////////////////////
// The nosurge function simply zero's out everything
// that was set up in the changesurge function.
// This creates no surge.
////////////////////////////////////////////////////

function nosurge() 											// Define the function nosurge
{
	
while(1) 														// While true,
{

vec_set(surgedir,vector(0,0,0));							// Zero it out
vec_scale(surgedir,time);									// Factor in time
wait(1);															// Wait 1 sec. (required in while statements)

}
}