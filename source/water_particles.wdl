////////////////////////////////////////////////////////
// Water particle function
// This is called in menubar.wdl
////////////////////////////////////////////////////////
// Extra - tga files are used in particular because they
// can hold an extra channel called an alpha channel.
// This channel holds a black & white version of the
// image that works as a mask. Once brought into 3d
// Gamestudio, the masks cuts out what we need in the
// image.
////////////////////////////////////////////////////////


bmap bubble_map = <bub.tga>;										// Define the bubble map with bub.tga

var g_bubblebox[3];													// Initalize the array g_bubblebox

function infinity()													// Define the function infinity
{
   
   ///////////////////////////////////////////////////////////////////////////
   // The vec_set call tells the game engine how to cycle the bubble
   // particles inside the game & make them live for a certain period of time.
   ///////////////////////////////////////////////////////////////////////////
   
   vec_set(my.x,vector(cycle(my.x,camera.x-g_bubblebox.x,camera.x+g_bubblebox.x),
   cycle(my.y,camera.y-g_bubblebox.y,camera.y+g_bubblebox.y),
   cycle(my.z,camera.z-g_bubblebox.z,camera.z+g_bubblebox.z)));
   
   my.lifespan=1; 													// Makes the bubbles live forever
}

function effect_bubbleflake()
{
	
	////////////////////////////////////////////////////////////////
	// Vector sets to create the bubble particles
	////////////////////////////////////////////////////////////////
	
   vec_set(my.x,vector(camera.x+random(g_bubblebox.x*2)-g_bubblebox.x,
       camera.y+random(g_bubblebox.y*2)-g_bubblebox.y,
       camera.z+random(g_bubblebox.z*2)-g_bubblebox.z));
   
   vec_set(my.vel_z,vector((random(4)+4), random(2)-1, random(2)-1));
   
   
   //////////////////////////////////////////////////////////////////////////////////////////
   // These are the portions of the bubble particles that would need to be changed if desired
   //////////////////////////////////////////////////////////////////////////////////////////
   
   my.bmap=bubble_map;												// Set the bitmap used for the particles
   my.size=random(1)+2;												// Set the size of the particles
   my.alpha=random(30)+10;											// Set the alpha opacity of the particles
   my.move=on;															// Set the particles to move based on speed vector
   
   my.function=infinity;											// Refers back to the infinity function to cycle the particles
}

function bubble(cx,cy,cz,numparticles)							// Create the bubble function
{
	
	///////////////////////////////////////////////////////////////////////////////
	// The variables cx, cy, cz, and numparticles are passed in through the call in
	// menubar.wdl
	//
	// They are then assigned to the g_bubblebox array to create the area and number
	// of particles to use in the scene. To increase/decrease these inside the game,
	// change the numbers found in menubar.wdl
	////////////////////////////////////////////////////////////////////////////////
	
   g_bubblebox.x=cx/2;
   g_bubblebox.y=cy/2;
   g_bubblebox.z=cz/2;
   effect(effect_bubbleflake,numparticles,nullvector,nullvector);			// Calls the particle effect generator
}