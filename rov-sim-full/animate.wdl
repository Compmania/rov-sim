// Template file v5.202 (02/20/02)
////////////////////////////////////////////////////////////////////////
// File: animate.wdl
//		WDL prefabs for model animation
////////////////////////////////////////////////////////////////////////
// Use:
//		Include AFTER "movment.wdl"
//
//]- Created: 06/14/01 DCP
//]-
//]- Mod Date: 07/10/01 DCP
//]-		actor_anim(): Added check for *ADVANCED ANIMATION*
//]-		actor_adv_anim(): Created. Uses SKILLS 1,2,3 & 4 for animation
//]-
//]-	Mod Date:  08/16/01  DCP
//]-		move_shadow(): Fixed drop shadow alignment on slopes.
//]-
//]- Mod Date: 12/18/01
//]-		Added WED 'uses' comments to all WED editable fields



//@ Animate Vars
var anim_attack_ticks = 16;// time for one attack animation cycle

var anim_stand_ticks = 16;	// time for one standing anim cycle
var anim_jump_ticks = 6; 	// time for one jump animation cycle
var anim_duck_ticks = 8; 	// time for one duck animation cycle

var anim_walk_dist = 1; 	// dist per model width per walk cycle
var anim_run_dist = 1.5;	// dist per model width per run cycle
var anim_crawl_dist = 0.8; // dist per model width per crawl cycle
var anim_wade_dist = 0.8;	// dist per model width per crawl cycle
var anim_swim_dist = 1; 	// dist per model width per swim cycle

var walk_or_run = 12; 	// max quants per tick to switch from walk to run animation


// strings for defining the animation frames
STRING anim_stand_str,"stand";
STRING anim_walk_str,"walk";
STRING anim_run_str,"run";
STRING anim_duck_str,"duck";
STRING anim_swim_str,"swim";
STRING anim_dive_str,"dive";
STRING anim_jump_str,"jump";
STRING anim_crawl_str,"crawl";
STRING anim_wade_str,"walk";

// string synonyms for defining the animation frames (and their default values)
STRING anim_default_death_str,"death";
STRING anim_default_attack_str,"attack";
//SYNONYM anim_attack_str { TYPE STRING; DEFAULT anim_default_attack_str;}
string* anim_attack_str = anim_default_attack_str;
//SYNONYM anim_death_str { TYPE STRING; DEFAULT anim_default_death_str;}
string* anim_death_str = anim_default_death_str;

//SYNONYM anim_str { TYPE STRING; }
string* anim_str;


// Define Masks
DEFINE MASK_ANIM_ATTACK_TICKS,2093056;	// upper 9 (less topbit)
DEFINE MASK_ANIM_JUMP_TICKS,4032; 		// mid 6
DEFINE MASK_ANIM_DUCK_TICKS,63; 			// lower 6

DEFINE MASK_ANIM_RUN_DIST,	2064384;	// upper 6 (less topbit)
DEFINE MASK_ANIM_WALK_DIST, 31744;	// next 5
DEFINE MASK_ANIM_CRAWL_DIST, 992;	// next 5
DEFINE MASK_ANIM_SWIM_DIST, 31;		// bottom 5


//@ Function prototypes

function anim_airborne();   // animate 'airborne' entity
function anim_init();		// initialize the actor animation style
function actor_anim();		// handle actor animation
//function	actor_anim_transition(str_anim_target);	// handle transition animation between states
function actor_anim_old_style_anim();	// old animation style (for compatability)

//#ACTION drop_shadow;			// create a shadow sprite under entity (use move_shadow() to move)
function move_shadow();		// move shadow sprite under entity
function attach_entity();	// attach an entity with same origin/frames

//@ Function code

//////////////////////////////////////////////////////////////////////////
// =======================================================================
// ANIMATION '2' functions (animation with blending, animation that makes sense)


// Desc: animate a blended transition between two states
//
//  'my' must be set to an actor (i.e. my = player)
//  my._ANIMDIST is set to 0 at the end of the transition, it is equal
//to -1 the rest of the time.
//
// str_anim_source is a string containing the source animation name
// str_anim_target is a string containing the target animation name
// trans_ticks is the number of ticks this function will take to complete
//
// e.g. actor_anim_transition2("walk","stand",16);
//		- blend from walk to stand in 16 ticks (one second)
function actor_anim_transition2(str_anim_source,str_anim_target,trans_ticks)
{
	var	perBlend_total;	// total percent blend (0-none, 100-finished)
	var	perBlend_inc;     // bend increaments
	var	source_frame_percent;	// the source frame % blending from

	source_frame_percent = my._ANIMDIST;
	my._ANIMDIST = -1; // used to flag the calling function

 	perBlend_total = 0;
	perBlend_inc = 100/trans_ticks;

	while(perBlend_total < 100)
	{
		// blend to the start of the target cycle
  		ent_cycle(str_anim_source,source_frame_percent);
		ent_blend(str_anim_target,0,perBlend_total);
		wait(1);
		perBlend_total += max(0.001,perBlend_inc*TIME);	// make sure we get some transition even if fps is extream
	}

	// set to start of animation cycle
	my._ANIMDIST = 0;                       // done with animation
	ent_cycle(str_anim_target,my._ANIMDIST);
//--breakpoint;
}





/*
STRING anim_stand_str,"stand";
STRING anim_walk_str,"walk";
STRING anim_run_str,"run";
STRING anim_duck_str,"duck";
STRING anim_swim_str,"swim";
STRING anim_dive_str,"dive";
STRING anim_jump_str,"jump";
STRING anim_crawl_str,"crawl";
STRING anim_wade_str,"walk";
*/

// pointers to animation strings
string*	pStr_old_anim;	// older animation string
string*	pStr_cur_anim;	// current animation string

// stand, walk, run, duck, crawl, jump, swim, attack, and death
DEFINE	_ANIM_MODE_QUIT,-1;	// quit animation
DEFINE	_ANIM_MODE_NONE,0;	// no animation
DEFINE	_ANIM_MODE_STAND,1;	// standing/idle animation (tick)
DEFINE	_ANIM_MODE_WALK,2;	// walking animation (dist)
DEFINE	_ANIM_MODE_RUN,3;		// running animation (dist)
DEFINE	_ANIM_MODE_WADE,4;	// wading animation
DEFINE	_ANIM_MODE_DUCK,5;	// ducking animation	(?)
DEFINE	_ANIM_MODE_CRAWL,6;	// crawling animation (?)
DEFINE	_ANIM_MODE_JUMP,7;	// jumping animation (tick)
DEFINE	_ANIM_MODE_SWIM,8;	// swimming animation (?)
DEFINE	_ANIM_MODE_ATTACK,9;	// attack animation
DEFINE	_ANIM_MODE_DEATH,10;  // dying animation

// if the movement distance is less than this value, the actor/player
//is concidered to be 'standing still' as far as the advanced animation
//functions are concerned (so it will choose to play the idle animations)
var anim_stillness_threshold = 0.025;

// Desc: get the animation string for the current animatino mode
//
// calls:
// called by: actor_adv_anim2
// uses: MY._ADVANIM_TICK, MY._ADVANIM_DIST (read only)
//
//
// set pStr_cur_anim to the right string
// return the cycle value if quant based or negitive cycle if tick based
function _actor_adv_anim2_get_string(anim_mode)
{
	// handle standing animation (tick based)
	if(anim_mode == _ANIM_MODE_STAND)
	{
		pStr_cur_anim = anim_stand_str;
		//opt. 			temp2 = 4*((FRC(-MY._ADVANIM_TICK))<<10);// anim_stand_ticks
 		return(-((FRC(-MY._ADVANIM_TICK))<<12));// anim_stand_ticks

	}

	// handle walking animation (quant based)
	if(anim_mode == _ANIM_MODE_WALK)
	{
		pStr_cur_anim = anim_walk_str;
		//opt. 		 		anim_dist = 0.25*INT(((-MY._ADVANIM_DIST)&MASK_ANIM_WALK_DIST)>>10);// anim_walk_dist
 		return(((-MY._ADVANIM_DIST)&MASK_ANIM_WALK_DIST)>>12);// anim_walk_dist

	}

	// handle running animation (quant based)
	if(anim_mode == _ANIM_MODE_RUN)
	{
		pStr_cur_anim = anim_run_str;
		//opt. 		 		anim_dist = 0.25*INT(((-MY._ADVANIM_DIST)&MASK_ANIM_RUN_DIST)>>15);// anim_run_dist
 		return(((-MY._ADVANIM_DIST)&MASK_ANIM_RUN_DIST)>>17);// anim_run_dist
	}

	// handle wading animation (quant based)
	if(anim_mode == _ANIM_MODE_WADE)
	{
		pStr_cur_anim = anim_wade_str;
		// NOTE! uses same distance as crawling!
		//opt. 		 		temp2 = 0.25*INT(((-MY._ADVANIM_DIST)&MASK_ANIM_CRAWL_DIST)>>5);// anim_crawl_dist == anim_crawl_dist
 		return(((-MY._ADVANIM_DIST)&MASK_ANIM_CRAWL_DIST)>>7);// anim_crawl_dist == anim_crawl_dist
	}

	// handle jumping animation (tick based)
	if(anim_mode == _ANIM_MODE_JUMP)
	{
		pStr_cur_anim = anim_jump_str;
  		//opt. 			temp2 = 4*INT(((-MY._ADVANIM_TICK)&MASK_ANIM_JUMP_TICKS)>>6);// anim_jump_ticks
 		return(-( INT(((-MY._ADVANIM_TICK)&MASK_ANIM_JUMP_TICKS)>>4) ));// anim_jump_ticks
	}

	// handle swimming animation (quant based)
	if(anim_mode == _ANIM_MODE_SWIM)
	{
		pStr_cur_anim = anim_swim_str;
		//opt. 		 		temp2 = 0.25*INT(((-MY._ADVANIM_DIST)&MASK_ANIM_SWIM_DIST));// anim_swim_dist
 		return(0.25*(((-MY._ADVANIM_DIST)&MASK_ANIM_SWIM_DIST)));// anim_swim_dist
	}

	// handle ducking animation (tick based)
	if(anim_mode == _ANIM_MODE_DUCK)
	{
		pStr_cur_anim = anim_duck_str;
		return(-4*INT(((-MY._ADVANIM_TICK)&MASK_ANIM_DUCK_TICKS)));// anim_duck_ticks
	}

	// handle crawling animation (quant based)
	if(anim_mode == _ANIM_MODE_CRAWL)
	{
		pStr_cur_anim = anim_crawl_str;
//opt. 		 		temp2 = 0.25*INT(((-MY._ADVANIM_DIST)&MASK_ANIM_CRAWL_DIST)>>5);// anim_crawl_dist
 	  	return(((-MY._ADVANIM_DIST)&MASK_ANIM_CRAWL_DIST)>>7);// anim_crawl_dist
	}

	// handle attack animation (tick based)
	if(anim_mode == _ANIM_MODE_ATTACK)
	{
		pStr_cur_anim = anim_attack_str;
//opt.	temp2 = 4*INT(((-MY._ADVANIM_TICK)&MASK_ANIM_ATTACK_TICKS)>>12);// anim_attack_ticks
		return(-INT(((-MY._ADVANIM_TICK)&MASK_ANIM_ATTACK_TICKS)>>10));// anim_attack_ticks
	}

	// handle dying animation (tick based)
	if(anim_mode == _ANIM_MODE_DEATH)
	{
		pStr_cur_anim = anim_death_str;

		return(-INT(((-MY._ADVANIM_TICK)&MASK_ANIM_ATTACK_TICKS)>>9)); // death twice as long as attack?
	}


	// ..add new animation modes here

	// default case
	pStr_cur_anim = anim_stand_str;
	return(10);
}


// Desc: evaluate the entity and select the correct animation mode
//
// calls:
// called by: actor_adv_anim2
//
//	takes: cur_anim_mode - current animation mode
//	uses:^my._FIREMODE  - see if actor is shooting
//		  ^my._MOVEMODE  - find out what movement state actor is in
//		  ^my._WALKDIST  - how far (quants) the actor moved last frame
//		  ^MY._ADVANIM_DIST - to calculate walk/run distance
//			temp
//			temp2
//
// returns the animation mode
// sets temp to 1 if this animation is 'once only' (e.g. jump, fire)
//
// Mod Date: 06/07/02 DCP
//		Time corrected MY._WALKDIST in calculations
function	_actor_adv_anim2_get_mode(cur_anim_mode)
{
// =====================================================================
// _MODE_STILL means "no animation"
// =====================================================================
	if(MY._MOVEMODE == _MODE_NONE)
	{
		temp = 0; // continuous animation cycle
		return(_ANIM_MODE_NONE);
	}

// =====================================================================
// special case animations that 'over ride' all other animation states
// =====================================================================

	// death
	if(MY._HEALTH <= 0)
	{
		temp = 1;	// "once only" flag
		return(_ANIM_MODE_DEATH);
	}



	// attack mode
	if(/*???( ME == PLAYER) &&???*/ (MY._FIREMODE != 0))   // NOTE!!! this may need to change!!!
	{
		temp = 1;	// "once only" flag
		return(_ANIM_MODE_ATTACK);
	}


// =====================================================================
// movemode animation (after special case)
// =====================================================================

	// walking or running mode
	if(MY._MOVEMODE == _MODE_WALKING)
	{
		// mod: 06/07/02 - added time correction to distance calculations
		// test for stand, walk, or run
		temp = abs(my._WALKDIST/TIME);   // absolute time corrected distance (quants)

		// movement less than stillness threshold?
		if(temp < anim_stillness_threshold)
		{
			// standing still
			temp = 0; // continuous animation cycle
			return(_ANIM_MODE_STAND);
		}

		// NOTE: we check to see if we are running already so we can have
		//an overlapping 'dead zone' where the animation remains the same
		//so we can avoid a constant state 'flip-flop'

 		temp2 = (frc(-MY._ADVANIM_DIST)<<10);// walk_or_run

		// decide whether to play the walk or run animation
		if(cur_anim_mode == _ANIM_MODE_RUN)	// we are in running mode now
		{
			if(temp < ((temp2)*movement_scale*0.75))	// fall back to walking      0.75
			{
				temp = 0; // continuous animation cycle
				return(_ANIM_MODE_WALK);
			}
			temp = 0; // continuous animation cycle
			return(_ANIM_MODE_RUN);	// continue running
		}


		if(temp < ((temp2)*movement_scale*1.15))	// keep walking      1.15
		{
			temp = 0; // continuous animation cycle
			return(_ANIM_MODE_WALK);
		}
		// start running
		temp = 0; // continuous animation cycle
		return(_ANIM_MODE_RUN);

	}

	if(MY._MOVEMODE == _MODE_WADING)
	{
		// test for stand, walk, or run
		temp = abs(my._WALKDIST/TIME);

		// movement less than stillness threshold?
		if(temp < anim_stillness_threshold)
		{
			// standing still
			temp = 0; // continuous animation cycle
			return(_ANIM_MODE_STAND);
		}
		// wading animation
		temp = 0; // continuous animation cycle
		return(_ANIM_MODE_WADE);
	}

	if( MY._MOVEMODE == _MODE_JUMPING)
	{
		temp = 1;	// "once only" flag
		return(_ANIM_MODE_JUMP);
	}

	if( MY._MOVEMODE == _MODE_SWIMMING)
	{
		temp = 0; // continuous animation cycle
		return(_ANIM_MODE_SWIM);
	}

	if( MY._MOVEMODE == _MODE_DUCKING)
	{
		// test for duck or crawl
		temp = abs(my._WALKDIST/TIME);
		// movement less than stillness threshold?
		if(temp < anim_stillness_threshold)
		{
			temp = 0; // continuous animation cycle
			return(_ANIM_MODE_DUCK);
		}
		temp = 0; // continuous animation cycle
		return(_ANIM_MODE_CRAWL);

	}

	if( MY._MOVEMODE == _MODE_CRAWLING)
	{
		temp = 0; // continuous animation cycle
		return(_ANIM_MODE_CRAWL);
	}

	// ..add new movemode animation modes here

	// default case
	// breakpoint; // uncomment to catch animations that 'fall thru'
	temp = 0; // continuous animation cycle
	return(_ANIM_MODE_STAND);	// when all else fails, stand around
}


// Desc: new animation method
//		- uses transitions
//		- loops every frame
//
//   'my' must be set before calling
//		my._WALKDIST must be set to the distance that the actor has covered (in quants)
//		my._ANIMDIST is modified in this function
//
//    global pStr_cur_anim is used
//
// Mod Date: 05/01/02 DCP
//		Once Off animations now use ent_frame instead of ent_cycle
//		Added a check for "no animation"
//
// Mod Date: 05/08/02 DCP
//		Fixed problem with multiple actions calling this function effecting the 'blend cycle'
//  We now make an aditional call to '_actor_adv_anim2_get_string'
//
// Mod Date: 06/07/02 DCP
//		Added "proc_late()" call to make sure this function is called only after
// MY._WALKDIST is set for the frame.
//
// Mod Date: 07/02/02 DCP
//		Added local var 'anim_percent' to store percent of animation cycle
//  Assign this value to my._ANIMDIST before calling actor_anim_transition2
//	 (bug fix: since actor_anim_transition2 expects _ANIMDIST to be a percent
//	 not a raw number).
function actor_adv_anim2()
{
	// init local variables
	var	cur_anim_mode;		// the current animation mode
	var	old_anim_mode;		// the old animation mode

	var	anim_cycle_val;	// the value of a complete animation cycle (in ticks or distance)
	var	anim_percent;		// percent value (0-100) of current animation cycle

	var	qOnceOnly;		// flag, equals 1 if this is a one cycle only animation


	while(my != null)	// loop while we have an actor
	{
		// this function needs to happen after the entity has finished setting
		//its "_WALKDIST" skill for this frame (which normally takes place in movement)
		proc_late();	// used to delay until end of frame

		// check movement/fire mode to set current animation mode and anim_cycle_val
		cur_anim_mode = _actor_adv_anim2_get_mode(cur_anim_mode);
		qOnceOnly = temp;	// set 'once only' flag
/*
// start debug code
tst_curr_state = cur_anim_mode;
tst_old_state = old_anim_mode;
// end debug code
*/
		if(cur_anim_mode == _ANIM_MODE_NONE) { wait(1); continue; }	// no animation


		// if current animation mode is not the same as old animation mode
		if(cur_anim_mode != old_anim_mode)
		{
			// get old and new values
			_actor_adv_anim2_get_string(old_anim_mode); // get the old animation mode string
			pStr_old_anim = pStr_cur_anim;	// save old value
			anim_cycle_val = _actor_adv_anim2_get_string(cur_anim_mode); // get new value

 			// set my._ANIMDIST to percentage
			MY._ANIMDIST = anim_percent;

			// do transition (continue in this loop until transition is complete)
			actor_anim_transition2(pStr_old_anim,pStr_cur_anim,2);
			// wait here until transition is done
			while(my._ANIMDIST == -1) { wait(1); }
		}

		// old animation mode = current animation mode
		old_anim_mode = cur_anim_mode;

		// get animation string for current animation mode
		// NOTE: move this to 'transition' section when we get local strings
		anim_cycle_val = _actor_adv_anim2_get_string(cur_anim_mode);

		// INC MY._ANIMDIST by TIME or my._WALKDIST (depending on animation)
		// if tick based
		if(anim_cycle_val < 0)
		{
 	  		my._ANIMDIST += time;          // update time
			anim_cycle_val = -anim_cycle_val;	// make it positive
		}
		else	// else dist based
		{
			// set the percent_width covered using percent of the model width
  			//my._WALKDIST is set in the actor's movement functions

			my._ANIMDIST += (MY._WALKDIST / (MY.MAX_X-MY.MIN_X));
		}

		// wrap animation time to a value between zero and anim_stand_ticks
		//and check to see if this cycle it a "once only",
		if(MY._ANIMDIST >= anim_cycle_val)
		{
			if(qOnceOnly > 0)   // a 'once only' animation
			{
				// signal to calling function that this cycle is finished
				my._ANIMDIST = -99;

				wait(1);   // must wait a frame to allow calling function time to respond
				continue;
	 		}

			while(MY._ANIMDIST > anim_cycle_val)    // 'wrap' time/dist
			{
				MY._ANIMDIST -= anim_cycle_val;
			}
		}

		// warp for negitive animation
		while(MY._ANIMDIST < 0)
		{
			MY._ANIMDIST += anim_cycle_val;
		}
		// calculate a percentage out of the animation time/dist
		anim_percent =  (100 * MY._ANIMDIST / anim_cycle_val);

		// check if it is a non-looping once only animation
		if(qOnceOnly > 0)
		{
			// animate in current mode (using time step/distance traveled)
			ent_frame(pStr_cur_anim,anim_percent);
		}
		else
		{
			// animate in current mode (using time step/distance traveled)
			ent_cycle(pStr_cur_anim,anim_percent);
		}


		wait(1);	// wait a frame
	} // end "while(my != null)" loop


}









// =======================================================================
//////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////
// Desc: animate 'airborne' entity
function anim_airborne()
{
	// standing animation
	if(MY._POWER > 0)	// engine running
	{
		MY._ANIMDIST += TIME * MY._POWER;
		// wrap animation time to a value between zero and anim_stand_ticks
		if(MY._ANIMDIST > anim_stand_ticks)
		{
			MY._ANIMDIST -= anim_stand_ticks;
		}
		// calculate a percentage out of the animation time
		temp =  100 * MY._ANIMDIST / anim_stand_ticks;
		// set the frame from the percentage
		ent_cycle(anim_stand_str,temp);
		return;
	}
	return;
}


/////////////////////////////////////////////////////////////////////////
// Desc: set up for animation
// 		scale entity by actor_scale
//			if using the "old style animation"
//	      	- split the integer and fractional parts of the animation
//				  frame numbers, and store distance factors
//
//]- Mod Date: 8/31/00 DCP
//]-		Scale the player by vec_scale
function anim_init()
{
	vec_scale(MY.SCALE_X,actor_scale);

	if(int(MY._WALKFRAMES) < 0) { return; }	// use adv animation

	// init 'old style' animation
	temp = frc(MY._WALKFRAMES) * 1000;
	if(temp != 0)
	{
		// old style animation
		MY._WALKFRAMES = int(MY._WALKFRAMES);
		if(MY._WALKFRAMES == 0) { MY._WALKFRAMES = 13; }
		MY._WALKDIST = MY._WALKFRAMES / temp;

		temp = frc(MY._RUNFRAMES) * 1000;
		MY._RUNFRAMES = int(MY._RUNFRAMES);
		if(MY._RUNFRAMES == 0) { MY._RUNFRAMES = 5; }
		MY._RUNDIST = MY._RUNFRAMES / temp;
	}
}



////////////////////////////////////////////////////////////////////////
// Desc: *ADVANCED* actor animation function
//
//]-	Mod Date: 7/17/01	DCP
//]-		First version finished


// Desc: 'Advanced' animation function. This allows the user to set animation
//		cycle distances and timing on an individual entity level.See the
//		"Scriptless Shooter" tutorial for details.
//]-
//]- Created 7/10/01 DCP
//
// Mod Date: 04/30/02 DCP
//		Removed check for transition move mode, use actor_adv_anim2()
function actor_adv_anim()
{
	// START ADVANCED STYLE ANIMATIONS (frame names)


	// Check to see if player is attacking
	if(( ME == PLAYER) && (MY._FIREMODE != 0))
	{
		// if you have more than one attacking animation, here's where you would test for it...
		// calculate a percentage out of the animation time
//opt.	temp2 = 4*INT(((-MY._ADVANIM_TICK)&MASK_ANIM_ATTACK_TICKS)>>12);// anim_attack_ticks
		temp2 = INT(((-MY._ADVANIM_TICK)&MASK_ANIM_ATTACK_TICKS)>>10);// anim_attack_ticks
		temp =  100 * MY._ANIMDIST / temp2;
		// set the frame from the percentage
		ent_frame(anim_attack_str,temp);

		// increment _ANIMDIST by elapsed time
		MY._ANIMDIST += TIME;
		// check to see if we finished the attack animation
		if(MY._ANIMDIST > temp2)
		{
			MY._ANIMDIST = 0; // reset animation distance
			MY._FIREMODE = 0;	// reset firemode
		}
		return;
	}      //==
	else // not firing
	{
		/////////////////////////////////////////////////////////////////////
		// Animations that can take place standing still (jumping, ducking, etc.)
		/////////////////////////////////////////////////////////////////////
   	// the jumping animation
		if(MY._MOVEMODE == _MODE_JUMPING)
		{
//opt. 			temp2 = 4*INT(((-MY._ADVANIM_TICK)&MASK_ANIM_JUMP_TICKS)>>6);// anim_jump_ticks
 			temp2 = INT(((-MY._ADVANIM_TICK)&MASK_ANIM_JUMP_TICKS)>>4);// anim_jump_ticks
			// calculate a percentage out of the animation time
			temp =  100 * MY._ANIMDIST / temp2;
			// set the frame from the percentage
			ent_frame(anim_jump_str,temp);
			// increment _ANIMDIST by elapsed time
			MY._ANIMDIST += TIME;
			// check to see if we finished jump animation
			if(MY._ANIMDIST > temp2)
			{
				MY._ANIMDIST = 0;
				MY._MOVEMODE = _MODE_WALKING;
			}
			return;
		}

   	// the ducking animation
		if(MY._MOVEMODE == _MODE_DUCKING)
		{
 		 	temp2 = (frc(-MY._ADVANIM_DIST)<<10);// walk_or_run
   		// you can only duck at walking speeds or below.
			if(my_dist >= temp2*TIME*movement_scale)	// to fast to duck?
			{
				MY._MOVEMODE = _MODE_WALKING; // catch the walking mode below this one
 			}
			else
			{ // ducking
 		 		temp2 = 4*INT(((-MY._ADVANIM_TICK)&MASK_ANIM_DUCK_TICKS));// anim_duck_ticks
				// calculate a percentage out of the animation time
				temp =  100 * MY._ANIMDIST / temp2;
				// set the frame from the percentage
				// -old - set_frame ME,anim_duck_str,temp;
				ent_frame(anim_duck_str,temp);
				// increment _ANIMDIST by elapsed time
				MY._ANIMDIST += TIME;
				// check to see if we finished ducking
				if(MY._ANIMDIST > temp2)
				{
					MY._ANIMDIST = 0;
					MY._MOVEMODE = _MODE_CRAWLING;
				}
				return;
			}
		}

		// the crawling animation
		if(MY._MOVEMODE == _MODE_CRAWLING)
		{
 		 	temp2 = (frc(-MY._ADVANIM_DIST)<<10);// walk_or_run
			// you can only crawl at walking speeds or below.
			if(my_dist >= temp2*TIME*movement_scale)	// to fast to crawl?
			{
				MY._MOVEMODE = _MODE_WALKING; // catch the walking mode below this one
 			}
			else
			{ // crawling
//opt. 		 		temp2 = 0.25*INT(((-MY._ADVANIM_DIST)&MASK_ANIM_CRAWL_DIST)>>5);// anim_crawl_dist
 		 		temp2 = (((-MY._ADVANIM_DIST)&MASK_ANIM_CRAWL_DIST)>>7);// anim_crawl_dist

 				// set the distance covered, in percent of the model width
				covered_dist = MY._WALKDIST + my_dist / (MY.MAX_X-MY.MIN_X);
 				// calculate the real cycle distance from the model size
				while(covered_dist > temp2)
				{
					covered_dist -= temp2;
				}

				if(force.X < 0)	// moving backwards?
				{
					temp = 100 - temp;
				}
				temp = 100 * covered_dist / temp2;
				//-old- set_cycle ME,anim_crawl_str,temp;
				ent_cycle(anim_crawl_str,temp);

				MY._WALKDIST = covered_dist;     // save for next 'frame' of animation
				return;
			}

		}

		// the swimming animation
		if(MY._MOVEMODE == _MODE_SWIMMING)
		{
//opt. 		 		temp2 = 0.25*INT(((-MY._ADVANIM_DIST)&MASK_ANIM_SWIM_DIST));// anim_swim_dist
 		 		temp2 = 0.25*(((-MY._ADVANIM_DIST)&MASK_ANIM_SWIM_DIST));// anim_swim_dist

 			// set the distance covered, in percent of the model width
			covered_dist = MY._WALKDIST + my_dist / (MY.MAX_X-MY.MIN_X);
 			// calculate the real cycle distance from the model size
			while(covered_dist > temp2)
			{
				covered_dist -= temp2;
			}

			if(force.X < 0)	// moving backwards?
			{
				temp = 100 - temp;
			}
			temp = 100 * covered_dist / temp2;
			// -old- set_cycle ME,anim_swim_str,temp;
			ent_cycle(anim_swim_str,temp);

			MY._WALKDIST = covered_dist;     // save for next 'frame' of animation
			return;
		}


		// the wading animation  (NOTE! uses same distance as crawling)
		if(MY._MOVEMODE == _MODE_WADING)
		{
//opt. 		 		temp2 = 0.25*INT(((-MY._ADVANIM_DIST)&MASK_ANIM_CRAWL_DIST)>>5);// anim_crawl_dist == anim_crawl_dist
 		 		temp2 = (((-MY._ADVANIM_DIST)&MASK_ANIM_CRAWL_DIST)>>7);// anim_crawl_dist == anim_crawl_dist

 			// set the distance covered, in percent of the model width
			covered_dist = MY._WALKDIST + my_dist / (MY.MAX_X-MY.MIN_X);
 			// calculate the real cycle distance from the model size
			while(covered_dist > temp2)
			{
				covered_dist -= temp2;
			}

			if(force.X < 0)	// moving backwards?
			{
				temp = 100 - temp;
			}

			temp = 100 * covered_dist / temp2;
			// -old- set_cycle ME,anim_wade_str,temp;
			ent_cycle(anim_wade_str,temp);

			MY._WALKDIST = covered_dist;     // save for next 'frame' of animation
			return;
		}

		// the standing still animation
		// NOTE: the must be *before* _MODE_WALKING but after any other mode
		//      that can animate while the player is not moving (swimming,
		//		  ducking, jumping, etc.)
		if((my_dist < 0.01) || (MY._MOVEMODE == _MODE_STILL))
		{
//opt. 			temp2 = 4*((FRC(-MY._ADVANIM_TICK))<<10);// anim_stand_ticks
 			temp2 = ((FRC(-MY._ADVANIM_TICK))<<12);// anim_stand_ticks

 			MY._ANIMDIST += TIME;
			// wrap animation time to a value between zero and anim_stand_ticks
			if(MY._ANIMDIST > temp2)
			{
				MY._ANIMDIST -= temp2;
			}
			// calculate a percentage out of the animation time
			temp =  100 * MY._ANIMDIST / temp2;
			// set the frame from the percentage
			// -old- set_cycle ME,anim_stand_str,temp;
			ent_cycle(anim_stand_str,temp);

			return;
 		}


		// walking animation
		if(MY._MOVEMODE == _MODE_WALKING)
		{
			// set the distance covered, in percent of the model width
			covered_dist = MY._WALKDIST + my_dist / (MY.MAX_X-MY.MIN_X);

 		 	temp2 = (frc(-MY._ADVANIM_DIST)<<10);// walk_or_run
			// decide whether to play the walk or run animation
			if(my_dist < temp2*TIME*movement_scale)	// Walking
			{
//opt. 		 		anim_dist = 0.25*INT(((-MY._ADVANIM_DIST)&MASK_ANIM_WALK_DIST)>>10);// anim_walk_dist
 		 		anim_dist = (((-MY._ADVANIM_DIST)&MASK_ANIM_WALK_DIST)>>12);// anim_walk_dist
				anim_str = anim_walk_str;
			}
			else
			{ // running
//opt. 		 		anim_dist = 0.25*INT(((-MY._ADVANIM_DIST)&MASK_ANIM_RUN_DIST)>>15);// anim_run_dist
 		 		anim_dist = (((-MY._ADVANIM_DIST)&MASK_ANIM_RUN_DIST)>>17);// anim_run_dist
				anim_str = anim_run_str;
			}

			// calculate the real cycle distance from the model size
			if(covered_dist > anim_dist)
			{
				covered_dist -= anim_dist;
			}


			temp = 100 * covered_dist / anim_dist;
			if(force.X < 0)	// moving backwards?
			{
				temp = 100 - temp;
			}

			ent_cycle(anim_str,temp);

			if (covered_dist < MY._WALKDIST)
			{
				_play_walksound();	// sound for right foot
			}
			if ((covered_dist > anim_dist*0.5) && (MY._WALKDIST < anim_dist*0.5))
			{
				_play_walksound();	// sound for left foot
			}
			MY._WALKDIST = covered_dist;
			return;
		}
		return;
		// END OF ADVANCED STYLE ANIMATIONS (frame names)
	}
} // END actor_adv_anim()


/////////////////////////////////////////////////////////////////////////
// Desc: Main action to animate a walking actor, depending on dist
//		  covered (my_dist)
//
//]- Mod Date: 5/9/00 @ 812 Doug Poston
//]-				Added swimming animation
//]- Mod Date: 5/10/00 @ 970 Doug Poston
//]-				Added jumping animation
//]- Mod Date: 5/11/00 @ 795 by Doug Poston
//]-				Added ducking and crawling animations
//]- Mod Date: 5/23/00 Doug Poston
//]- 			Added code to check for backwards motion (using force.X)
//]- Mod Date: 6/23/00 Doug Poston
//]- 			Added code for attack animations
//]- Mod Date: 6/27/00 Doug Poston
//]-				Modified attack animation code to only work for player animation
//]- Mod Date: 8/31/00 DCP
//]-				Modified walk_or_run var by movement_scale
//]- Mod Date: 11/8/00 DCP
//]-          Replaced set_frame with ent_frame
//]-          Replaced set_cycle with ent_cycle
//]- Mod Date: 06/11/01 DCP
//]-				Removed goto 'old_style_anim', made it its own function
//]- Mod Date: 07/10/01 DCP
//]-				Added check for *ADVANCED ANIMATION*
function actor_anim()
{
	// check for *ADVANCED ANIMATION* (frame names and entity tick/dist values)
	if(int(MY._WALKFRAMES) < 0) { actor_adv_anim(); return; }

	// decide whether it's a frame number (old) or frame name (new) animation
	if(frc(MY._WALKFRAMES) > 0) { actor_anim_old_style_anim(); return; }


	// START NEW STYLE ANIMATIONS (frame names)

	// Check to see if player is attacking
	if(( ME == PLAYER) && (MY._FIREMODE != 0))
	{
		// if you have more than one attacking animation, here's where you would test for it...
		// calculate a percentage out of the animation time
		temp =  100 * MY._ANIMDIST / anim_attack_ticks;
		// set the frame from the percentage
		// -old- set_frame ME,anim_attack_str,temp;
		ent_frame(anim_attack_str,temp);

		// increment _ANIMDIST by elapsed time
		MY._ANIMDIST += TIME;
		// check to see if we finished the attack animation
		if(MY._ANIMDIST > anim_attack_ticks)
		{
			MY._ANIMDIST = 0; // reset animation distance
			MY._FIREMODE = 0;	// reset firemode
		}
		return;
	}
	else // not firing
	{
		/////////////////////////////////////////////////////////////////////
		// Animations that can take place standing still (jumping, ducking, etc.)
		/////////////////////////////////////////////////////////////////////
   	// the jumping animation
		if(MY._MOVEMODE == _MODE_JUMPING)
		{
			// calculate a percentage out of the animation time
			temp =  100 * MY._ANIMDIST / anim_jump_ticks;
			// set the frame from the percentage
			// -old- set_frame ME,anim_jump_str,temp;
			ent_frame(anim_jump_str,temp);
			// increment _ANIMDIST by elapsed time
			MY._ANIMDIST += TIME;
			// check to see if we finished jump animation
			if(MY._ANIMDIST > anim_jump_ticks)
			{
				MY._ANIMDIST = 0;
				MY._MOVEMODE = _MODE_WALKING;
			}
			return;
		}

   	// the ducking animation
		if(MY._MOVEMODE == _MODE_DUCKING)
		{
   		// you can only duck at walking speeds or below.
			if(my_dist >= walk_or_run*TIME*movement_scale)	// to fast to duck?
			{
				MY._MOVEMODE = _MODE_WALKING; // catch the walking mode below this one
 			}
			else
			{ // ducking
				// calculate a percentage out of the animation time
				temp =  100 * MY._ANIMDIST / anim_duck_ticks;
				// set the frame from the percentage
				// -old - set_frame ME,anim_duck_str,temp;
				ent_frame(anim_duck_str,temp);
				// increment _ANIMDIST by elapsed time
				MY._ANIMDIST += TIME;
				// check to see if we finished ducking
				if(MY._ANIMDIST > anim_duck_ticks)
				{
					MY._ANIMDIST = 0;
					MY._MOVEMODE = _MODE_CRAWLING;
				}
				return;
			}
		}

		// the crawling animation
		if(MY._MOVEMODE == _MODE_CRAWLING)
		{

			// you can only crawl at walking speeds or below.
			if(my_dist >= walk_or_run*TIME*movement_scale)	// to fast to crawl?
			{
				MY._MOVEMODE = _MODE_WALKING; // catch the walking mode below this one
 			}
			else
			{ // crawling
 				// set the distance covered, in percent of the model width
				covered_dist = MY._WALKDIST + my_dist / (MY.MAX_X-MY.MIN_X);
 				// calculate the real cycle distance from the model size
				while(covered_dist > anim_crawl_dist)
				{
					covered_dist -= anim_crawl_dist;
				}

				if(force.X < 0)	// moving backwards?
				{
					temp = 100 - temp;
				}
				temp = 100 * covered_dist / anim_crawl_dist;
				//-old- set_cycle ME,anim_crawl_str,temp;
				ent_cycle(anim_crawl_str,temp);

				MY._WALKDIST = covered_dist;     // save for next 'frame' of animation
				return;
			}

		}

		// the swimming animation
		if(MY._MOVEMODE == _MODE_SWIMMING)
		{
 			// set the distance covered, in percent of the model width
			covered_dist = MY._WALKDIST + my_dist / (MY.MAX_X-MY.MIN_X);
 			// calculate the real cycle distance from the model size
			while(covered_dist > anim_swim_dist)
			{
				covered_dist -= anim_swim_dist;
			}

			if(force.X < 0)	// moving backwards?
			{
				temp = 100 - temp;
			}
			temp = 100 * covered_dist / anim_swim_dist;
			// -old- set_cycle ME,anim_swim_str,temp;
			ent_cycle(anim_swim_str,temp);

			MY._WALKDIST = covered_dist;     // save for next 'frame' of animation
			return;
		}


		// the wading animation
		if(MY._MOVEMODE == _MODE_WADING)
		{
 			// set the distance covered, in percent of the model width
			covered_dist = MY._WALKDIST + my_dist / (MY.MAX_X-MY.MIN_X);
 			// calculate the real cycle distance from the model size
			while(covered_dist > anim_wade_dist)
			{
				covered_dist -= anim_wade_dist;
			}

			if(force.X < 0)	// moving backwards?
			{
				temp = 100 - temp;
			}

			temp = 100 * covered_dist / anim_wade_dist;
			// -old- set_cycle ME,anim_wade_str,temp;
			ent_cycle(anim_wade_str,temp);

			MY._WALKDIST = covered_dist;     // save for next 'frame' of animation
			return;
		}

		// the standing still animation
		// NOTE: the must be *before* _MODE_WALKING but after any other mode
		//      that can animate while the player is not moving (swimming,
		//		  ducking, jumping, etc.)
		if((my_dist < 0.01) || (MY._MOVEMODE == _MODE_STILL))
		{
 			MY._ANIMDIST += TIME;
			// wrap animation time to a value between zero and anim_stand_ticks
			if(MY._ANIMDIST > anim_stand_ticks)
			{
				MY._ANIMDIST -= anim_stand_ticks;
			}
			// calculate a percentage out of the animation time
			temp =  100 * MY._ANIMDIST / anim_stand_ticks;
			// set the frame from the percentage
			// -old- set_cycle ME,anim_stand_str,temp;
			ent_cycle(anim_stand_str,temp);

			return;
 		}


		// walking animation
		if(MY._MOVEMODE == _MODE_WALKING)
		{
			// set the distance covered, in percent of the model width
			covered_dist = MY._WALKDIST + my_dist / (MY.MAX_X-MY.MIN_X);

			// decide whether to play the walk or run animation
			if(my_dist < walk_or_run*TIME*movement_scale)	// Walking
			{
				anim_dist = anim_walk_dist;
				anim_str = anim_walk_str;
			}
			else
			{ // running
				anim_dist = anim_run_dist;
				anim_str = anim_run_str;
			}

			// calculate the real cycle distance from the model size
			if(covered_dist > anim_dist)
			{
				covered_dist -= anim_dist;
			}


			temp = 100 * covered_dist / anim_dist;
			if(force.X < 0)	// moving backwards?
			{
				temp = 100 - temp;
			}

			ent_cycle(anim_str,temp);

			if (covered_dist < MY._WALKDIST)
			{
				_play_walksound();	// sound for right foot
			}
			if ((covered_dist > anim_dist*0.5) && (MY._WALKDIST < anim_dist*0.5))
			{
				_play_walksound();	// sound for left foot
			}
			MY._WALKDIST = covered_dist;
			return;
		}
		return;
		// END OF NEW STYLE ANIMATIONS (frame names)
	}

	/* ??? No longer needed ???
	if((MY._MOVEMODE == _MODE_STILL) || (my_dist < 0.01))
	{
		// if the entity has a standing animation, instead of just one frame,
		// place it here. Otherwise...
		MY.FRAME = 1;	// standing
		return;
	}
	*/
}


/////////////////////////////////////////////////////////////////////////
// Desc: Handle transitions between states
//
//]- Created: 06/11/01
//]-
//
// TODO!!! Test with multiple actors
function	actor_anim_transition(str_anim_target,trans_ticks)
{
	var	target_movemode;  			// target _MOVEMODE
	var	start_frame;					// starting frame

	target_movemode = MY._MOVEMODE;		// save the target movemode
	MY._MOVEMODE = _MODE_TRANSITION;    // set _MOVEMODE to transition

	// set up starting frame
	start_frame = int(MY.frame);	// take the current 'whole' frame
	my.frame = start_frame;

	// set up target frame (take the first frame of target animation)
	my.next_frame = ent_frame(str_anim_target,0);

	// animate between start and target frame
	my._ANIMDIST = 0;
	while(my._ANIMDIST < 1.00)
	{
		my.frame += time/trans_ticks;			// inc frame
		my._ANIMDIST += time/trans_ticks;	// inc counter


		wait(1);
	}

	// prevent overshoot...
	if(my.frame > start_frame+1)
	{	ent_frame(str_anim_target,0); }


	my._ANIMDIST = 0;    // start new cycle at start
	my._MOVEMODE = target_movemode; //
}


/*
function	actor_anim_transition(str_anim_target,trans_ticks)
{
//	ME = player;
//	wait(1);     // let calling function finish one loop

	MY._ANIMDIST = 0;	// internal counter, distance into animation

	// set the frame and next_frame values
	temp = MY.frame;
//--	ent_frame("swim",0);
	ent_frame(str_anim_target,0);
	MY.next_frame = MY.frame;
	MY.frame = temp;

	anim_trans_cycle = MY._MOVEMODE;
	MY._MOVEMODE = _MODE_TRANSITION;

	// do .25 sec transition (4 ticks)
	while(MY._ANIMDIST < 4)
	{
		MY.frame = int(MY.frame) + (MY._ANIMDIST / 4.0);

		MY._ANIMDIST += TIME;
		wait(1);
	}
	MY._ANIMDIST = 0;
 	MY._MOVEMODE = anim_trans_cycle;
}
*/

/////////////////////////////////////////////////////////////////////////
// Desc: Handle 'old' A4 style of animation
//			Called from "actor_anim()"
//
//]-	Created: 06/11/01 DCP
//]-
function actor_anim_old_style_anim()
{
	if(MY._MOVEMODE == _MODE_WALKING)
	{
		// decide whether to play the walk or run animation
		if((MY._RUNFRAMES <= 0) || (my_dist < walk_or_run*TIME*movement_scale))	// Walking
		{
			if(MY.FRAME < 2) { MY.FRAME = 2; }

			MY.FRAME += MY._WALKDIST*my_dist;

			// this is one of the expert exceptions where you can use WHILE without WAIT!
			while(MY.FRAME >= 2 + MY._WALKFRAMES)
			{
				// sound for right foot
				if(MY.__SOUND == ON) { _play_walksound(); MY.__SOUND = OFF; }
				// cycle the animation
				MY.FRAME -= MY._WALKFRAMES;
			}

			if(MY.FRAME > 1 + MY._WALKFRAMES*0.5) {
				// sound for left foot
				if(MY.__SOUND == OFF) { _play_walksound(); MY.__SOUND = ON; }
			}

			if(MY.FRAME > 1 + MY._WALKFRAMES)
			{
				MY.NEXT_FRAME = 2;	// inbetween to the first walking frame
			}
			else
			{
				MY.NEXT_FRAME = 0;	// inbetween to the real next frame
			}
			return;
		}
		else
		{	// Running
			if(MY.FRAME < 2 + MY._WALKFRAMES) { MY.FRAME = 2 + MY._WALKFRAMES; }

			MY.FRAME += MY._RUNDIST*my_dist;

			while(MY.FRAME >= 2 + MY._WALKFRAMES + MY._RUNFRAMES)
			{
				if(MY.__SOUND == ON) { _play_walksound(); MY.__SOUND = OFF; }
				MY.FRAME -= MY._RUNFRAMES;
			}

			if(MY.FRAME > 1 + MY._WALKFRAMES + MY._RUNFRAMES*0.5)
			{
				if(MY.__SOUND == OFF) { _play_walksound(); MY.__SOUND = ON; }
			}

			if(MY.FRAME > 1 + MY._WALKFRAMES + MY._RUNFRAMES)
			{
				MY.NEXT_FRAME = 2 + MY._WALKFRAMES;
			}
			else
			{
				MY.NEXT_FRAME = 0;
			}

			return;
		}
	}
}


/////////////////////////////////////////////////////////////////////////
// Desc: create a shadow below the entity
ACTION drop_shadow
{
IFDEF CAPS_FLARE;
	if(VIDEO_DEPTH >= 16)
	{
		create(SHADOWSPRITE,MY.POS,move_shadow);
	}
	else
	{
		create(SHADOWFLAT,MY.POS,move_shadow);
	}
IFELSE;
	create(SHADOWFLAT,MY.POS,move_shadow);
ENDIF;
}



/////////////////////////////////////////////////////////////////////////
//	Desc: function used to move shadow
//
//]- Mod Date: 05/29/00
//]- 			Added check for swimming or wading (no shadow)
//]- Mod Date: 7/30/00 JCL
//]-				Made shadow darker + adapted to floor slope
//]- Mod Date: 11/9/00 DCP
//]-				Replaced sonar with trace()
//]-	Mod Date: 08/16/01 DCP
//]-		Fix conform shadow to slope.
function move_shadow()
{
	MY.transparent = ON;
//	MY.flare = ON;
	MY.alpha = 60;
	MY.passable = ON;
	MY.oriented = ON;
//	MY.ambient = -100; // shadow should be totally black
	MY.unlit = ON;		 //(plus UNLIT flag in version 4.20)

	// scale the shadow so that it matches its master's (YOU) size
	MY.scale_x = (YOU.MAX_X - YOU.MIN_X)/(MY.MAX_X - MY.MIN_X);
	MY.scale_y = MY.scale_x * 0.8;
	MY.scale_z = 1.0;

	while(YOU != NULL)
	{
		if ((YOU.invisible == ON)
		|| (YOU._MOVEMODE == _MODE_SWIMMING)
		|| (YOU._MOVEMODE == _MODE_WADING))
		{
			MY.invisible = ON;
		}
		else
		{
			MY.invisible = OFF;
  			temp_ent = YOU;


			//-old-sonar temp_ent,500; // get height above the floor
			trace_mode = IGNORE_PASSENTS
			  	+ IGNORE_ME
			  	+ IGNORE_YOU
			  	+ IGNORE_MODELS;
			vec_set(vecFrom,YOU.X);
			vec_set(vecTo,vecFrom);
			vecTo.Z -= 500;
			result = trace(vecFrom,vecTo);

			YOU = temp_ent; // YOU (the entity itself) is changed by SONAR

			if(result > 0)
			{
				// place shadow 2 quants above the floor
				MY.z = YOU.z - RESULT + 2; //YOUR.min_z*/ + 2 - RESULT;
				MY.x = YOU.x;
				MY.y = YOU.y;
//--	 		 	MY.pan = YOU.pan;

				// adapt shadow orientation to floor slope
				if ((NORMAL.x != 0) || (NORMAL.y != 0))
				{ // we're on a slope
					// conform shadow to slope
					MY.PAN = 0;
					MY.tilt = - asin(NORMAL.x);
					MY.roll = - asin(NORMAL.y);
					temp.pan = YOU.PAN;
					temp.tilt = 90;
					temp.roll = 0;
					rotate(my,temp,nullvector);
 				}
				else
				{
					MY.pan = YOU.pan;
					MY.tilt = 90; // set it flat onto the floor
					MY.roll = 0;
				}
			}
			else
			{
				MY.INVISIBLE = ON;
			}
		}
		wait(1);
	} // end while(YOU != NULL)
	remove(ME);
}


/////////////////////////////////////////////////////////////////////////
// Desc: attaches an entity that has the same origin and the same frame cycles
//
function attach_entity()
{
   my.passable = on;
   while(you)	// prevent empty synoym error if parent entity was removed
   {
   	if(your.shadow == on) { my.shadow = on; }
   	if(you == player && person_3rd == 0)
		{
      	my.invisible = on;
   	}
		else
		{
      	my.invisible = off;
   	}
   	vec_set(my.x,you.x);
   	vec_set(my.pan,you.pan);
   	my.frame = you.frame;
   	my.next_frame = you.next_frame;

   	wait(1);
   }
	remove(my);
}


///////////////////////////////////////////////////////////////////////
// Desc: Shakes the player, used for hits and death
function player_shake()
{
	if(random(1) > 0.5)
	{
		MY.ROLL += 8;
		MY.TILT += 8;
		waitt(2);
		MY.TILT -= 5;
		waitt(2);
		MY.ROLL -= 8;
		MY.TILT -= 3;
	}
	else
	{
		MY.ROLL -= 8;
		MY.TILT += 8;
		waitt(2);
		MY.TILT -= 5;
		waitt(2);
		MY.ROLL += 8;
		MY.TILT -= 3;
	}
}