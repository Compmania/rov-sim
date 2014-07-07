// Template file v5.202 (02/20/02)
////////////////////////////////////////////////////////////////////////
// File: messages.wdl
//		WDL prefabs for displaying messages
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
IFNDEF MSG_DEFS;
 FONT standard_font,<ackfont.pcx>,6,9;

 DEFINE MSG_X,4;		// from left
 DEFINE MSG_Y,4;		// from above
 DEFINE BLINK_TICKS,6;	// msg blinking period
 DEFINE MSG_TICKS,64;	// msg appearing time
 DEFINE msg_font,standard_font;
 SOUND msg_sound,<msg.wav>;

 DEFINE PANEL_POSX,4;	// health panel from left
 DEFINE PANEL_POSY,-20;	// from below
 FONT digit_font,<digfont.pcx>,12,16;	// ammo/health font
ENDIF;

IFNDEF MSG_DEFS2;
 DEFINE SCROLL_X,4;		// scroll text from left
 DEFINE SCROLL_Y,4;		// from above
 DEFINE SCROLL_LINES,4;	// maximum 8;
ENDIF;

IFNDEF MSG_DEFS3;
 DEFINE HEALTHPANEL,game_panel;	// default health/ammo panel

 DEFINE touch_font,standard_font;
 DEFINE touch_sound,msg_sound;
ENDIF;

//////////////////////////////////////////////////////////////////////
var msg_counter = 0;
STRING empty_str[80];
STRING temp_str[80];

TEXT msg
{
	POS_X MSG_X;
	POS_Y MSG_Y;
	FONT	msg_font;
	STRING empty_str;
}

//////////////////////////////////////////////////////////////////////
// To display a message string for a given number of seconds, perform the instructions
// msg_show(string,time);

function msg_show(str,secs)
{
	exclusive_global;		// stop previous msg_show action
	play_sound(msg_sound,66);
	msg.string = str;
	msg.visible = on;
	waitt(secs*16);
	msg.string = empty_str;
	msg.visible = off;
}

// Desc: show message for 5 seconds
function show_message()
{
	msg_show(msg.string,5);
}

// The same, but message will blink
function msg_blink(str,secs)
{
//	ME = NULL;
	exclusive_global;
	play_sound(msg_sound,66);
	msg.string = str;
	msg_counter = secs*16;
	while(msg_counter > 0)
	{
		msg.visible = (msg.visible == off);
		waitt(BLINK_TICKS);
		msg_counter -= BLINK_TICKS;
	}
	msg.string = empty_str;
	msg.visible = off;
}

function blink_message()
{
	msg_blink(msg.string,5);
}

//////////////////////////////////////////////////////////////////////
// actions for scrolling messages
//////////////////////////////////////////////////////////////////////
STRING message_str,
 "                                                                    ";
TEXT enter_txt
{
	FONT	msg_font;
	STRING message_str;
}

TEXT scroll
{
	POS_X MSG_X;
	POS_Y MSG_Y;
	FONT	msg_font;
	STRINGS 8;
	STRING "                                                           ";
	STRING "                                                           ";
	STRING "                                                           ";
	STRING "                                                           ";
	STRING "                                                           ";
	STRING "                                                           ";
	STRING "                                                           ";
	STRING "                                                           ";
	INDEX SCROLL_LINES;
}

string* scroll_string;

// Desc: scroll message upwards while adding a line
// Mod Date: 14/03/01 JCL - str parameter added
function scroll_message(str)
{
	if (str) {
		str_cpy(scroll.STRING[SCROLL_LINES],str);
	}
	play_sound(msg_sound,66);
	scroll.VISIBLE = ON;
	temp = 1;
	while(temp <= SCROLL_LINES)
	{
	// scroll upwards by copying each string to the previous one
		str_cpy(scroll.STRING[temp-1],scroll.STRING[temp]);
		temp += 1;
	}
	// clear the last string
	str_cpy(scroll.STRING[SCROLL_LINES],empty_str);
}

string* message_syn = message_str;

// 14/03/01 JCL - display player name
// prompt for a message and send it to the other players
function enter_message()
{
	enter_txt.VISIBLE = ON;
	enter_txt.POS_X = scroll.POS_X;
	enter_txt.POS_Y = scroll.POS_Y + SCROLL_LINES * scroll.CHAR_Y;
	str_cpy(message_str,player_name);
	str_cat(message_str,": ");
	inkey(message_str);
	if(result == 13)
	{
 		send_string(message_str);
	}
	enter_txt.VISIBLE = OFF;
}

function server_event(str)
{
	if (event_type == event_join)
	{
		str_cpy(temp_str,str);
		str_cat(temp_str," joined");
		scroll_message(temp_str);
		return;
	}
	if (event_type == event_leave)
	{
		str_cpy(temp_str,str);
		str_cat(temp_str," left");
		scroll_message(temp_str);
		return;
	}
	if ((event_type == event_string) && (str == message_syn)) // pointers can be compared directly
	{
// server received message -> send it to all clients
 		send_string(message_syn);
		return;
	}
}

// client received message -> display it
function client_event(str)
{
	if ((event_type == event_string) && (str == message_syn))
	{
		scroll_message(message_syn);
		str_cpy(message_syn,empty_str);
		return;
	}
}

//////////////////////////////////////////////////////////////////////
// actions for ammo and health panels
//////////////////////////////////////////////////////////////////////
var show_ammo = 0;
var show_health = 0;
var show_armor = 0;
var ammo_number = 0;
var ammo1 = 0;
var ammo2 = 0;
var ammo3 = 0;
var ammo4 = 0;
var ammo5 = 0;
var ammo6 = 0;
var ammo7 = 0;

PANEL game_panel
{
	POS_X		PANEL_POSX;
	DIGITS	0,0,3,digit_font,1,show_ammo;
	DIGITS	40,0,3,digit_font,1,show_health;
	DIGITS	80,0,3,digit_font,1,show_armor;
	FLAGS		TRANSPARENT,REFRESH;
}

//////////////////////////////////////////////////////////////////////

// Desc: show player panel (ammo and heath)
//
// Mod:  05/01/01 DCP
//		Added ammo5, ammo6, & ammo7
function show_panels()
{
	HEALTHPANEL.VISIBLE = ON;
	while(1)
	{	// forever
		HEALTHPANEL.POS_Y = SCREEN_SIZE.Y + PANEL_POSY;
		if(ammo_number == 0) { show_ammo = 0; }
		if(ammo_number == 1) { show_ammo = ammo1; }
		if(ammo_number == 2) { show_ammo = ammo2; }
		if(ammo_number == 3) { show_ammo = ammo3; }
		if(ammo_number == 4) { show_ammo = ammo4; }
		if(ammo_number == 5) { show_ammo = ammo5; }
		if(ammo_number == 6) { show_ammo = ammo6; }
		if(ammo_number == 7) { show_ammo = ammo7; }
		if(player != NULL)
		{
			show_health = player._HEALTH;
			show_armor = player._ARMOR;
		}
		wait(1);
	}
}

//////////////////////////////////////////////////////////////////////
// Stuff for displaying object titles if the mouse touches them
TEXT touch_txt
{
	FONT	touch_font;
	STRING empty_str;
	FLAGS CENTER_X,CENTER_Y;
}

// Desc: display a touch text at mouse position
function _show_touch()
{
	if(MY.STRING1 != NULL)
	{
		play_sound(touch_sound,33);
		touch_txt.VISIBLE = ON;
		touch_txt.STRING = MY.STRING1;
		touch_txt.POS_X = MOUSE_POS.X;
		touch_txt.POS_Y = MOUSE_POS.Y;
		MY.ENABLE_RELEASE = ON;

	//	WHILE (touch_text.VISIBLE == ON)	// move text with mouse
	//	{
	//		touch_text.POSX = MOUSE_X;
	//		touch_text.POSY = MOUSE_Y;
	//		wait(1);
	//	}
	}
}

// Desc: hide touch text if it still displayed my string
function _hide_touch()
{
	if(touch_txt.STRING == MY.STRING1)
	{
		touch_txt.VISIBLE = OFF;
	}
}

// Desc: call this from a event action to operate the touch text
function handle_touch()
{
	if(EVENT_TYPE == EVENT_TOUCH) { _show_touch(); return; }
	if(EVENT_TYPE == EVENT_RELEASE) { _hide_touch(); return; }
}

//////////////////////////////////////////////////////////////////////
ON_SERVER = server_event;
ON_CLIENT = client_event;

ON_F4 = enter_message;