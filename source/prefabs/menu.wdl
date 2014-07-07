// Template file v5.203 (02/26/02)
////////////////////////////////////////////////////////////////////////
// File: menu.wdl
//		WDL prefabs for simple game menus
////////////////////////////////////////////////////////////////////////
//
//]- Mod Date: 10/31/00 DCP
//]-				Changed to 4.30 format
//]-
//]- Mod Date: 01/29/01 DCP
//]-				Removed "weapon_init". Overriding weapons.wdl code
//]-
//]- 02/10/01 (JCL) "weapon_init" back in place.
//]-          Otherwise all weapon-less games, like adeptus, won't start anymore.
//]-
//]- Mod Date: 05/16/01 DCP
//]-				Remove all 'BRANCH' commands (replace with <foo>(); return;)
//]-
//]- Mod Date: 06/21/01 DCP
//]-				Replaced all SYNONYMs with pointers
//
////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////

//define old_a52;

IFNDEF MENU_DEFS;
 SOUND  menu_click <click.wav>;	// menu select sound
 DEFINE menu_font standard_font;	// menu font
 BMAP button_low,<black.pcx>,0,0,64,10;// menu item background
 BMAP button_hi,<white.pcx>,0,0,64,10;	// menu selected item background
 BMAP yesno_back,<black.pcx>,0,0,64,24;// yes/no panel background
 BMAP yesno_low,<black.pcx>,0,0,28,10;	// yes/no button background
 BMAP yesno_hi,<white.pcx>,0,0,28,10;	// yes/no selected button background
 BMAP arrow,<arrow.tga>;// mouse pointer
 DEFINE YES_OFFS_X,2;	// offsets for yes/no buttons to panel
 DEFINE NO_OFFS_X,34;
 DEFINE YESNO_OFFS_Y,12;
ENDIF;	// MENU_DEFS

IFNDEF MENU_DEFS2;
 DEFINE CONSOLE_MODE_2;	// console line don't disappear after [ENTER]
 DEFINE INFO_NAME,"stat";
 DEFINE SAVE_NAME,"game";
ENDIF;

//////////////////////////////////////////////////////////
var menu_pos[2] = 10, 10;	// position of menu on screen
var menu_dist[2] = 4, 12;	// distance between buttons
var menu_offs[2] = 2,  1; 	// offset text to button below
var menu_max = 7; 			// max items per menu

var yesno_pos[2] = 10, 10; // position of yes/no panel
var yesno_offs[2] = 2,  2;	// offset text to panel

//////////////////////////////////////////////////////////
// Texts and messages appearing in the menu
STRING new_game_str,"New";
STRING load_game_str,"Load";
STRING save_game_str,"Save";
STRING quit_game_str,"Quit";
STRING options_str,"Options";
STRING help_str,"Help";
STRING resume_str,"Back";

STRING yes_str,"Yes";
STRING no_str," No";

STRING quit_yesno,"  Quit?";

STRING ok_str,"OK";
STRING wait_str,"Please wait...";
STRING save_error,"MALFUNCTION... can't save game";
STRING load_error,"MALFUNCTION... save before loading!";

STRING helptxt_str,
"ESC - Menu
F1  - Help
F2  - Quicksave
F3  - Quickload
F4  - Multiplayer message
F5  - Toggle resolution
F6  - Screenshot
F7  - Toggle person mode
F11 - Toggle gamma
F12 - Toggle sound/music
F10 - Exit";

//////////////////////////////////////////////////////////
// a lot of default strings, actions and pointers
// which are used for the items of the menu

var menu_cursor = 0;  // determines which item is selected

// strings for the names of the five games to save and load
STRING name1_str,"         ";
STRING name2_str,"         ";
STRING name3_str,"         ";
STRING name4_str,"         ";
STRING name5_str,"         ";

string* mystring;

// pointers to the actions to execute for each of the 7 menu items
action* menu_do1;
action* menu_do2;
action* menu_do3;
action* menu_do4;
action* menu_do5;
action* menu_do6;
action* menu_do7;

// pointers to save and restore any actions that were
// previously assigned to menu keys
action* old_menu_esc;
action* old_help_esc;
action* old_yesno_esc;
action* old_menu_enter;
action* old_yesno_enter;
action* old_cud;
action* old_cuu;
action* old_cul;
action* old_cur;
action* old_f1;

// Actions which are really performed if clicking one of the 7 menu items.
// The menu has to disappear before the action is executed
function _b1() { _menu_clear(); menu_do1(); }
function _b2() { _menu_clear(); menu_do2(); }
function _b3() { _menu_clear(); menu_do3(); }
function _b4() { _menu_clear(); menu_do4(); }
function _b5() { _menu_clear(); menu_do5(); }
function _b6() { _menu_clear(); menu_do6(); }
function _b7() { _menu_clear(); menu_do7(); }

function _buttonclick() { snd_play(menu_click,40,0); }

// Texts on the menu item buttons
TEXT menu_txt1 { LAYER 11; FONT menu_font; STRING empty_str; }
TEXT menu_txt2 { LAYER 11; FONT menu_font; STRING empty_str; }
TEXT menu_txt3 { LAYER 11; FONT menu_font; STRING empty_str; }
TEXT menu_txt4 { LAYER 11; FONT menu_font; STRING empty_str; }
TEXT menu_txt5 { LAYER 11; FONT menu_font; STRING empty_str; }
TEXT menu_txt6 { LAYER 11; FONT menu_font; STRING empty_str; }
TEXT menu_txt7 { LAYER 11; FONT menu_font; STRING empty_str; }

// The items of which the menu really consists.
// Each item is a panel with a single button.
PANEL menu_pan1
{
	LAYER 10; FLAGS REFRESH,TRANSPARENT;
	BUTTON 0,0,button_hi,button_low,button_hi,_b1,NULL,_buttonclick;
}
PANEL menu_pan2
{
	LAYER 10; FLAGS REFRESH,TRANSPARENT;
	BUTTON 0,0,button_hi,button_low,button_hi,_b2,NULL,_buttonclick;
}
PANEL menu_pan3
{
	LAYER 10; FLAGS REFRESH,TRANSPARENT;
	BUTTON 0,0,button_hi,button_low,button_hi,_b3,NULL,_buttonclick;
}
PANEL menu_pan4
{
	LAYER 10; FLAGS REFRESH,TRANSPARENT;
	BUTTON 0,0,button_hi,button_low,button_hi,_b4,NULL,_buttonclick;
}
PANEL menu_pan5
{
	LAYER 10; FLAGS REFRESH,TRANSPARENT;
	BUTTON 0,0,button_hi,button_low,button_hi,_b5,NULL,_buttonclick;
}
PANEL menu_pan6
{
	LAYER 10; FLAGS REFRESH,TRANSPARENT;
	BUTTON 0,0,button_hi,button_low,button_hi,_b6,NULL,_buttonclick;
}
PANEL menu_pan7
{
	LAYER 10; FLAGS REFRESH,TRANSPARENT;
	BUTTON 0,0,button_hi,button_low,button_hi,_b7,NULL,_buttonclick;
}

PANEL menu_select
{
	LAYER 10.5; BMAP button_hi; FLAGS REFRESH,TRANSPARENT;
}

/////////////////////////////////////////////////////////////////////
// This action initializes the menu
// This just makes all menu items - buttons and texts above - visible on screen.
function _menu_visible()
{
	if(menu_max >= 1)
	{
		menu_pan1.VISIBLE = ON;
		menu_txt1.VISIBLE = ON;
	}
	if(menu_max >= 2)
	{
		menu_pan2.VISIBLE = ON;
		menu_txt2.VISIBLE = ON;
	}
	if(menu_max >= 3)
	{
		menu_pan3.VISIBLE = ON;
		menu_txt3.VISIBLE = ON;
	}
	if(menu_max >= 4)
	{
		menu_pan4.VISIBLE = ON;
		menu_txt4.VISIBLE = ON;
	}
	if(menu_max >= 5)
	{
		menu_pan5.VISIBLE = ON;
		menu_txt5.VISIBLE = ON;
	}
	if(menu_max >= 6)
	{
		menu_pan6.VISIBLE = ON;
		menu_txt6.VISIBLE = ON;
	}
	if(menu_max >= 7)
	{
		menu_pan7.VISIBLE = ON;
		menu_txt7.VISIBLE = ON;
	}
	FREEZE_MODE = 1;	// when the menu is on screen, the game freezes
	menu_cursor = 1;	// place to first item
}


// This just lets all menu items disappear again
function _menu_hide()
{
	menu_pan1.VISIBLE = OFF;
	menu_txt1.VISIBLE = OFF;
	menu_pan2.VISIBLE = OFF;
	menu_txt2.VISIBLE = OFF;
	menu_pan3.VISIBLE = OFF;
	menu_txt3.VISIBLE = OFF;
	menu_pan4.VISIBLE = OFF;
	menu_txt4.VISIBLE = OFF;
	menu_pan5.VISIBLE = OFF;
	menu_txt5.VISIBLE = OFF;
	menu_pan6.VISIBLE = OFF;
	menu_txt6.VISIBLE = OFF;
	menu_pan7.VISIBLE = OFF;
	menu_txt7.VISIBLE = OFF;
	menu_select.VISIBLE = OFF;
}

// This quits the menu, restores old key actions, and continues the game
function _menu_clear()
{
	if(menu_cursor > 0)
	{
		_menu_hide();
		ON_ESC = old_menu_esc;
		ON_CUU = old_cuu;
		ON_CUD = old_cud;
		ON_ENTER = old_menu_enter;
		FREEZE_MODE = 0;
		menu_cursor = 0;
	}
}

// One item up
function _menu_up()
{
	menu_cursor -= 1;
	_menu_set();
}

// One item down
function _menu_down()
{
	menu_cursor += 1;
	_menu_set();
}

// Highlights the selected menu item, onto which the menu cursor is placed
function _menu_set()
{
	// cursor highlight has no effect in mouse mode
	if(MOUSE_MODE >= 1) { menu_select.VISIBLE = OFF; RETURN; }

	// restrict the menu cursor to valid values
	if(menu_cursor < 1) { menu_cursor = menu_max; }
	if(menu_cursor > menu_max) { menu_cursor = 1; }

	// set the highlight panel onto the selected item, and make it visible
	menu_select.POS_X = menu_pos.X + (menu_cursor-1) * menu_dist.X;
	menu_select.POS_Y = menu_pos.Y + (menu_cursor-1) * menu_dist.Y;
	menu_select.VISIBLE = ON;
	_buttonclick();
}

// Desc: exceutes the action of the selected menu item
function _menu_exec()
{
	// if alt or ctrl was pressed, don't execute the menu but the old action
	if(KEY_ALT || KEY_CTRL) { old_menu_enter(); return; }

	// now ececute the item action, dependent on the menu cursor position
	play_sound(menu_click,60);
	if(menu_cursor == 1) { _b1(); return; }
	if(menu_cursor == 2) { _b2(); return; }
	if(menu_cursor == 3) { _b3(); return; }
	if(menu_cursor == 4) { _b4(); return; }
	if(menu_cursor == 5) { _b5(); return; }
	if(menu_cursor == 6) { _b6(); return; }
	if(menu_cursor == 7) { _b7(); return; }
}

function menu_show()
{
	_yesno_hide();	// if a yesno panel was active, hide it

	// First, set all button panels to their correct positions
	menu_pan1.POS_X = menu_pos.X;
	menu_pan1.POS_Y = menu_pos.Y;
	menu_txt1.POS_X = menu_pos.X + menu_offs.X;
	menu_txt1.POS_Y = menu_pos.Y + menu_offs.Y;
	menu_pan2.POS_X = menu_pan1.POS_X + menu_dist.X;
	menu_pan2.POS_Y = menu_pan1.POS_Y + menu_dist.Y;
	menu_txt2.POS_X = menu_txt1.POS_X + menu_dist.X;
	menu_txt2.POS_Y = menu_txt1.POS_Y + menu_dist.Y;
	menu_pan3.POS_X = menu_pan2.POS_X + menu_dist.X;
	menu_pan3.POS_Y = menu_pan2.POS_Y + menu_dist.Y;
	menu_txt3.POS_X = menu_txt2.POS_X + menu_dist.X;
	menu_txt3.POS_Y = menu_txt2.POS_Y + menu_dist.Y;
	menu_pan4.POS_X = menu_pan3.POS_X + menu_dist.X;
	menu_pan4.POS_Y = menu_pan3.POS_Y + menu_dist.Y;
	menu_txt4.POS_X = menu_txt3.POS_X + menu_dist.X;
	menu_txt4.POS_Y = menu_txt3.POS_Y + menu_dist.Y;
	menu_pan5.POS_X = menu_pan4.POS_X + menu_dist.X;
	menu_pan5.POS_Y = menu_pan4.POS_Y + menu_dist.Y;
	menu_txt5.POS_X = menu_txt4.POS_X + menu_dist.X;
	menu_txt5.POS_Y = menu_txt4.POS_Y + menu_dist.Y;
	menu_pan6.POS_X = menu_pan5.POS_X + menu_dist.X;
	menu_pan6.POS_Y = menu_pan5.POS_Y + menu_dist.Y;
	menu_txt6.POS_X = menu_txt5.POS_X + menu_dist.X;
	menu_txt6.POS_Y = menu_txt5.POS_Y + menu_dist.Y;
	menu_pan7.POS_X = menu_pan6.POS_X + menu_dist.X;
	menu_pan7.POS_Y = menu_pan6.POS_Y + menu_dist.Y;
	menu_txt7.POS_X = menu_txt6.POS_X + menu_dist.X;
	menu_txt7.POS_Y = menu_txt6.POS_Y + menu_dist.Y;

	// Now save the old actions of ESC, Cursor, ENTER keys into pointers
	// and assign them them new actions required for the menu
	old_menu_esc = ON_ESC;
	ON_ESC = _menu_clear;	// now ESC clears the menu
	old_cuu = ON_CUU;
	on_cuu = _menu_up;		// CUU moves the selection cursor up
	old_cud = ON_CUD;
	on_cud = _menu_down;	// CUD moves it down
	old_menu_enter = ON_ENTER;
	ON_ENTER = _menu_exec;// and ENTER ececutes the selected item

	// and now place the menu cursor to the first item, and make the
	// whole menu visible.
	_menu_visible();
	_menu_set();	// highlight first item
}

///////////////////////////////////////////////////////////////////////
// Yes/No Panel stuff
var yesno_active = 0;

// For saving and restoring the old key actions
action* old_y;
action* old_z;
action* old_n;

// Action to execute if YES is clicked on
action* yesno_do;
function _yes_exec() { _yesno_clear(); yesno_do(); }

// The yes/no panel consists of 2 buttons, not surprisingly
PANEL yesno_pan
{
	LAYER 12; BMAP yesno_back; FLAGS TRANSPARENT,REFRESH;
	BUTTON YES_OFFS_X,YESNO_OFFS_Y,yesno_hi,yesno_low,yesno_hi,
		_yes_exec,NULL,_buttonclick;
	BUTTON NO_OFFS_X,YESNO_OFFS_Y,yesno_hi,yesno_low,yesno_hi,
		_yesno_clear,NULL,_buttonclick;
}

// Texts of the panel and the two buttons
TEXT yesno_txt { LAYER 13; FONT menu_font; STRING empty_str; }
TEXT yes_txt { LAYER 13; FONT menu_font; STRING yes_str; }
TEXT no_txt { LAYER 13; FONT menu_font; STRING no_str; }

///////////////////////////////////////////////////////////////////////
// Initialzes the yesno panel
function yesno_show()
{
	_menu_clear();		// in case menu was switched on before
	_yesno_clear();	// remove last yesno

	// set the position of yesno panels and text
	yesno_pan.POS_X = yesno_pos.X;
	yesno_pan.POS_Y = yesno_pos.Y;
	yesno_txt.POS_X = yesno_pan.POS_X + yesno_offs.X;
	yesno_txt.POS_Y = yesno_pan.POS_Y + yesno_offs.Y;
	yes_txt.POS_X = yesno_txt.POS_X + YES_OFFS_X;
	yes_txt.POS_Y = yesno_txt.POS_Y + YESNO_OFFS_Y;
	no_txt.POS_X = yesno_txt.POS_X + NO_OFFS_X;
	no_txt.POS_Y = yes_txt.POS_Y;

	// let everything appear on screen
	yesno_pan.VISIBLE = ON;
	yesno_txt.VISIBLE = ON;
	yes_txt.VISIBLE = ON;
	no_txt.VISIBLE = ON;

	// Save the old key actions, and set the reqired panel actions
	old_yesno_esc = ON_ESC;
	ON_ESC = _yesno_clear;
	old_n = ON_N;
	ON_N = _yesno_clear;
	old_yesno_enter = ON_ENTER;
	ON_ENTER = _yes_exec;
	old_y = ON_Y;
	ON_Y = _yes_exec;
	old_z = ON_Z;		// for German keyboard...
	ON_Z = _yes_exec;

	yesno_active = 1;
	FREEZE_MODE = 1;		// freeze game
}

// let the yesno panel disappear
function _yesno_hide()
{
	yesno_pan.VISIBLE = OFF;
	yesno_txt.VISIBLE = OFF;
	yes_txt.VISIBLE = OFF;
	no_txt.VISIBLE = OFF;
}

// exit the yesno panel
function _yesno_clear()
{
	if (yesno_active)
	{
		_yesno_hide();
		FREEZE_MODE = 0;		// unfreeze game
		// restore old key actions
		ON_ESC = old_yesno_esc;
		ON_N = old_n;
		ON_ENTER = old_yesno_enter;
		ON_Y = old_y;
		ON_Z = old_z;
		yesno_active = 0;
	}
}

///////////////////////////////////////////////////////////////////////
// Options sliders stuff
DEFINE SLIDER_LEN,70;

BMAP slider_map = <white.pcx>,0,0,10,10;
BMAP slider_bar = <black.pcx>,0,0,SLIDER_LEN,2;

var bar_val1 = SLIDER_LEN;
var bar_val2 = SLIDER_LEN;
var bar_val3 = SLIDER_LEN;
var slider_soundvol = 80;// 0, 100;
var slider_musicvol = 50;//, 0, 100;
var slider_resolution = 3;//, 1, 8;

PANEL option_pan
{
	LAYER 10;	FLAGS REFRESH;
	HBAR 4,8,SLIDER_LEN,slider_bar,1,bar_val1;	// just to draw a black line
	HSLIDER 4,4,SLIDER_LEN,slider_map,0,100,slider_soundvol;

	HBAR 4,28,SLIDER_LEN,slider_bar,1,bar_val2;
	HSLIDER 4,24,SLIDER_LEN,slider_map,0,100,slider_musicvol;

	HBAR 4,48,SLIDER_LEN,slider_bar,1,bar_val3;
	HSLIDER 4,44,SLIDER_LEN,slider_map,1,8,slider_resolution;
}

STRING optionsound_str,"-  volume  +";
STRING optionmusic_str,"-  music   +";
STRING optionres_str,  "-  video   +";


// move the cursor one slider up
function _slider_up()
{
	if(MOUSE_MODE != 0) { RETURN; }
	_buttonclick();
	menu_cursor -= 1;
	if(menu_cursor < 1) { menu_cursor = 3; }
}

// move the cursor one slider down
function _slider_down()
{
	if(MOUSE_MODE != 0) { RETURN; }
	_buttonclick();
	menu_cursor += 1;
	if(menu_cursor > 3) { menu_cursor = 1; }
}

// move selected slider to right
function _slider_right()
{
	if(MOUSE_MODE != 0) { RETURN; }
	_buttonclick();
	if(menu_cursor == 1)
	{
		slider_soundvol += 10;
		if(slider_soundvol > 100) { slider_soundvol = 100; }
	}
	if(menu_cursor == 2)
	{
		slider_musicvol += 10;
		if(slider_musicvol > 100) { slider_musicvol = 100; }
	}
	if(menu_cursor == 3)
	{
		slider_resolution += 1;
		if(slider_resolution > 8) { slider_resolution = 8; }
	}
}

// move selected slider to left
function _slider_left()
{
	if(MOUSE_MODE != 0) { RETURN; }
	_buttonclick();
	if(menu_cursor == 1)
	{
		slider_soundvol -= 10;
		if(slider_soundvol < 0) { slider_soundvol = 0; }
	}
	if(menu_cursor == 2) {
		slider_musicvol -= 10;
		if(slider_musicvol < 0) { slider_musicvol = 0; }
	}
	if(menu_cursor == 3)
	{
		slider_resolution -= 1;
		if(slider_resolution < 1) { slider_resolution = 1; }
	}
}

function options_hide()
{
	if(slider_resolution != VIDEO_MODE)
	{
		SWITCH_VIDEO slider_resolution,0,0;
		slider_resolution = VIDEO_MODE;
		_show_resolution();
	}
	FREEZE_MODE = 0;
	option_pan.VISIBLE = OFF;
	menu_txt1.VISIBLE = OFF;
	menu_txt2.VISIBLE = OFF;
	menu_txt3.VISIBLE = OFF;
	ON_ESC = old_menu_esc;
	ON_CUU = old_cuu;
	ON_CUD = old_cud;
	ON_CUL = old_cul;
	ON_CUR = old_cur;
}

// Yet to do: modularize a slider panel
function game_options()
{
	EXCLUSIVE_GLOBAL;
	FREEZE_MODE = 1;
	option_pan.POS_X = menu_pos.X;
	option_pan.POS_Y = menu_pos.Y;
	menu_txt1.POS_X = menu_pos.X + 2;
	menu_txt1.POS_Y = menu_pos.Y + 15;
	menu_txt2.POS_X = menu_txt1.POS_X;
	menu_txt2.POS_Y = menu_txt1.POS_Y + 20;
	menu_txt3.POS_X = menu_txt2.POS_X;
	menu_txt3.POS_Y = menu_txt2.POS_Y + 20;
	option_pan.VISIBLE = ON;
	menu_txt1.VISIBLE = ON;
	menu_txt2.VISIBLE = ON;
	menu_txt3.VISIBLE = ON;
	menu_txt1.STRING = optionsound_str;
	menu_txt2.STRING = optionmusic_str;
	menu_txt3.STRING = optionres_str;
	old_menu_esc = ON_ESC;
	ON_ESC = options_hide;
	old_cuu = ON_CUU;
	ON_CUU = _slider_up;
	old_cud = ON_CUD;
	ON_CUD = _slider_down;
	old_cul = ON_CUL;
	ON_CUL = _slider_left;
	old_cur = ON_CUR;
	ON_CUR = _slider_right;

	menu_cursor = 1;
	slider_soundvol = SOUND_VOL;
	slider_musicvol = MIDI_VOL;
	slider_resolution = VIDEO_MODE;

	while(option_pan.VISIBLE == ON)
	{
		if(MOUSE_MODE == 0)
		{
			if(menu_cursor == 1)
			{
				if(bar_val1 == 0)
				{
					bar_val1 = SLIDER_LEN;
				}
				else
				{
					bar_val1 = 0;
				}
				bar_val2 = SLIDER_LEN;
				bar_val3 = SLIDER_LEN;
			}
			if(menu_cursor == 2)
			{
				if(bar_val2 == 0)
				{
					bar_val2 = SLIDER_LEN;
				}
				else
				{
					bar_val2 = 0;
				}
				bar_val1 = SLIDER_LEN;
				bar_val3 = SLIDER_LEN;
			}
			if(menu_cursor == 3)
			{
				if(bar_val3 == 0)
				{
					bar_val3 = SLIDER_LEN;
				}
				else
				{
					bar_val3 = 0;
				}
				bar_val2 = SLIDER_LEN;
				bar_val1 = SLIDER_LEN;
			}
		}
		else
		{
		 	bar_val1 = SLIDER_LEN;
		 	bar_val2 = SLIDER_LEN;
		 	bar_val3 = SLIDER_LEN;
		}
		SOUND_VOL = slider_soundvol;
		MIDI_VOL = slider_musicvol;
		wait(1);
	}
}

///////////////////////////////////////////////////////////////////////
// save/load stuff
var slot	= 0; 	// number of last score
function _menu_save1() { slot = 1; mystring = name1_str; _game_save(); }
function _menu_save2() { slot = 2; mystring = name2_str; _game_save(); }
function _menu_save3() { slot = 3; mystring = name3_str; _game_save(); }
function _menu_save4() { slot = 4; mystring = name4_str; _game_save(); }
function _menu_save5() { slot = 5; mystring = name5_str; _game_save(); }

function _menu_save()
{
	menu_txt1.STRING = name1_str;
	menu_txt2.STRING = name2_str;
	menu_txt3.STRING = name3_str;
	menu_txt4.STRING = name4_str;
	menu_txt5.STRING = name5_str;
	menu_txt6.STRING = resume_str;

	menu_do1 = _menu_save1;
	menu_do2 = _menu_save2;
	menu_do3 = _menu_save3;
	menu_do4 = _menu_save4;
	menu_do5 = _menu_save5;
	menu_do6 = _menu_clear;

	menu_max = 6;
	menu_show();
}


function load_status()
{
	wait(2);	// don't override previous LOAD etc.
ifdef old_a52;
	LOAD_INFO INFO_NAME,0;
ifelse;
	game_load(app_name,0);
endif;
}

function _game_save()
{
	_menu_visible();	// was hidden before
	INKEY	mystring;
	if(RESULT != 13) { _menu_clear(); return; }
	_menu_clear();

	save_status();			// save global skills & strings
	ON_LOAD = load_status;	// to automatically reload them

//	msg.STRING = wait_str;
//	show_message();

	save(SAVE_NAME,slot);	// save game

	if(RESULT < 0)
	{		// Error?
		msg.STRING = save_error;
	}
	else
	{
		msg.STRING = ok_str;
	}
	show_message();
}


// after re-loading a game, reload all global parameters
function save_status()
{
ifdef old_a52;
	save_info(INFO_NAME,0);
ifelse;
	game_save(app_name,0,SV_INFO+SV_STRINGS+SV_BMAPS);
endif;
}

///////////////////////////////////////////////////////////////////////
function help_hide()
{
	FREEZE_MODE = 0;
	msg.VISIBLE = OFF;
	ON_ESC = old_help_esc;
	ON_F1 = old_f1;
}

function game_help()
{
	FREEZE_MODE = 1;
	msg.STRING = helptxt_str;
	msg.VISIBLE = ON;
	old_help_esc = ON_ESC;
	ON_ESC = help_hide;
	old_f1 = ON_F1;
	ON_F1 = help_hide;
}

///////////////////////////////////////////////////////////////////////
// menu actions for a standard game

function _menu_load1() { slot = 1; _game_load(); }
function _menu_load2() { slot = 2; _game_load(); }
function _menu_load3() { slot = 3; _game_load(); }
function _menu_load4() { slot = 4; _game_load(); }
function _menu_load5() { slot = 5; _game_load(); }

function _menu_load()
{
	menu_txt1.STRING = name1_str;
	menu_txt2.STRING = name2_str;
	menu_txt3.STRING = name3_str;
	menu_txt4.STRING = name4_str;
	menu_txt5.STRING = name5_str;
	menu_txt6.STRING = resume_str;

	menu_do1 = _menu_load1;
	menu_do2 = _menu_load2;
	menu_do3 = _menu_load3;
	menu_do4 = _menu_load4;
	menu_do5 = _menu_load5;
	menu_do6 = _menu_clear;

	menu_max = 6;
	menu_show();
}

function game_exit()
{
	save_status();			// save global skills & strings
	EXIT	"3D GameStudio (c) conitec 2002\n";
}

function exit_yesno()
{
	yesno_txt.STRING = quit_yesno;
	yesno_do = game_exit;
	yesno_show();
}

// Desc: default action, to be replaced by a game-adapted action
function game_init()
{
	key_init();
	weapon_init();
	main();
}

// dummy actions, if weapons.wdl or doors.wdl are not included
function weapon_init() { return; }
function key_init() { return; }

function menu_main()
{
	menu_txt1.STRING = new_game_str;
	menu_txt2.STRING = load_game_str;
	menu_txt3.STRING = save_game_str;
	menu_txt4.STRING = quit_game_str;
	menu_txt5.STRING = options_str;
	menu_txt6.STRING = help_str;
	menu_txt7.STRING = resume_str;

	menu_do1 = game_init;	// normally an action which resets all
	menu_do2 = _menu_load;
	menu_do3 = _menu_save;
	menu_do4 = exit_yesno;
	menu_do5 = game_options;
	menu_do6 = game_help;
	menu_do7 = _menu_clear;

	menu_max = 7;
	menu_show();
}

VAR_INFO _entry = 0;

function game_entry()
{	// mark the score to re-enter the game (yet to do)
	if(_entry == 0)
	{
		_entry = 1;
	}
}


///////////////////////////////////////////////////////////////////////
function _game_load()
{
	msg.STRING = wait_str;
	show_message();
	wait(1);				// to display wait message before loading

	load(SAVE_NAME,slot);
	msg.STRING = load_error;	// failed!
	show_message();
}

///////////////////////////////////////////////////////////////////////////////////
// Desc: switches the mouse on and off
function mouse_toggle()
{
	MOUSE_MODE += 2;
	if(MOUSE_MODE > 2)
	{	// was it already on?
		MOUSE_MODE = 0;		// mouse off
	}
	else
	{
		mouse_on();
	}
}

// Desc: switches the mouse on
function mouse_on()
{
	menu_select.VISIBLE = OFF;	// menu now handled by mouse
	MOUSE_MAP = arrow;
	while(MOUSE_MODE > 0)
	{
		MOUSE_POS.X = POINTER.X;
		MOUSE_POS.Y = POINTER.Y;
		wait(1); 		      // now move it over the screen
	}
}

// Desc: switches the mouse off
function mouse_off()
{
	MOUSE_MODE = 0;
}

//var MOUSE_SPOT[2] = 5,5;

////////////////////////////////////////////////////////////////////////////
// For debugging purposes, use the EXECUTE instruction
// to type in WDL instructions during gameplay, like at a console.
// You can examine skill values through "TO_STRING look,skill;"

STRING exec_buffer[128];
STRING look "         "; // to see skills via TO_STRING;

TEXT console_txt
{
	POS_X 4;
	LAYER	10;
	FONT 	standard_font;
	STRINGS 3;
IFDEF CONSOLE_MODE_2;
	STRING "Enter instructions below, abort with [ESC]:";
IFELSE;
	STRING "Enter instructions below:";
ENDIF;
	STRING exec_buffer;
	STRING look;
}

function console()
{
	if(console_txt.VISIBLE == ON) { RETURN; }	//already running
	console_txt.POS_Y = SCREEN_SIZE.Y - 60;
	console_txt.VISIBLE = ON;
	while(console_txt.VISIBLE == ON)
	{
		INKEY	exec_buffer;
		if(RESULT == 13)
		{
			EXECUTE exec_buffer;
IFDEF CONSOLE_MODE_2;
		}
		else
		{
			console_txt.VISIBLE = OFF;
		}
IFelse;
		}
		console_txt.VISIBLE = OFF;
ENDIF;
	}
}

// Implementing a scrolling console, instead of a 1-line one,
// is left as an exercise to the reader...

//////////////////////////////////////////////////////////////
// screen resolution display
//////////////////////////////////////////////////////////////////////
STRING resolution_str,"                              ";
STRING screen_str,"Video ";
STRING x_str,"x";

// Mod Date: 11/1/00 DCP
//		Replaced to_string, add_string, and set_string with
//	str_for_num, str_cat, and str_cpy
function _show_resolution()
{
	// compose the resolution string from strings and numbers
	str_cpy(resolution_str,screen_str);

	// now it reads "Video "
	str_for_num(temp_str,SCREEN_SIZE.X);
	str_cat(resolution_str,temp_str);
	// now it reads "Video hhhh" (hhhh is the hor resolution)
	str_cat(resolution_str,x_str);
	// now it reads "Video hhhhx"
	str_for_num(temp_str,SCREEN_SIZE.Y);
	str_cat(resolution_str,temp_str);
	// now it reads "Video hhhhxvvvv"
	str_cat(resolution_str,x_str);
	// now it reads "Video hhhhxvvvvx"
	str_for_num(temp_str,VIDEO_DEPTH);
	str_cat(resolution_str,temp_str);
	// and now it reads "Video hhhhxvvvvxdd"

	msg.STRING = resolution_str;
	show_message();
}

function game_resolution()
{
	_toggle_video();
	_show_resolution();
}

//////////////////////////////////////////////////////////////////////
// Default key assignements to control the game
ON_ESC menu_main;
ON_F1	 game_help;
ON_F5	 game_resolution;
ON_F10 exit_yesno;
ON_TAB console;

ON_MOUSE_RIGHT	mouse_toggle;