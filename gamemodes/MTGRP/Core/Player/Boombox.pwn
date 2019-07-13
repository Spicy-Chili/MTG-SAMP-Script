/*
#		MTG Boomboxes
#		
#
#	By accessing this file, you agree to the following:
#		- You will never give the script or associated files to anybody who is not on the MTG SAMP development team
# 		- You will delete all development materials (script, databases, associated files, etc.) when you leave the MTG SAMP development team.
#
#
#
*/

#include <a_samp>
#include <zcmd>
#include <streamer>
#include <YSI\y_hooks>

static string[255];

enum Boombox_
{
	Float:Boombox_POS[4],
	Boombox_URL[255],
	Boombox_OWNER[25],
	Boombox_SETBY[25],
	Boombox_OBJECT,
	Boombox_OBJECT2,
	Boombox_INT,
	Boombox_VW,
	Boombox_TIMER,
	Boombox_HEALTH,
	Boombox_STATE,
	Boombox_AREA,
	// Text3D:Boombox_LABEL,
}
#define 	MAX_BOOMBOXES		50
#define 	BOOMBOX_RANGE		40
#define 	BOOMBOX_MODEL		2226
#define 	BOOMBOX_SMOKE		18716
#define 	BOOMBOX_MINUTES		30
new Iterator:Boomboxes<MAX_BOOMBOXES>;
#define 	AddBoombox(%0)		Iter_Add(Boomboxes, %0)
#define		RemoveBoombox(%0) 	Iter_Remove(Boomboxes, %0)
#define 	IsBoombox(%0)		Iter_Contains(Boomboxes, %0)
#define 	GetFreeBoomboxID() 	Iter_Free(Boomboxes)
#define 	BoomboxCount()		Iter_Count(Boomboxes)
#define 	ClearAllBoomboxes()	Iter_Clear(Boomboxes)
new Boomboxes[MAX_BOOMBOXES][Boombox_];

CMD:gotoboombox(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 3)
		return 1;
		
	new id = strval(params);
	if(!IsBoombox(id) || isnull(params) || !IsNumeric(params))
		return SendClientMessage(playerid, GREY, "SYNTAX: /gotoboombox [boomboxid]");
		
	SetPlayerPos(playerid, Boomboxes[id][Boombox_POS][0], Boomboxes[id][Boombox_POS][1], Boomboxes[id][Boombox_POS][2] + 1.0);
	SetPlayerInterior(playerid, Boomboxes[id][Boombox_INT]);
	SetPlayerVirtualWorld(playerid, Boomboxes[id][Boombox_VW]);
	
	format(string, sizeof(string), "You have teleported to boombox %d.", id);
	SendClientMessage(playerid, WHITE, string);
	return 1;
}

CMD:deleteboombox(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 3)
		return 1;
		
	new id = strval(params);
	if(!IsBoombox(id) || isnull(params) || !IsNumeric(params))
		return SendClientMessage(playerid, GREY, "SYNTAX: /deleteboombox [boomboxid]");
		
	DestroyBoombox(id);
	format(string, sizeof(string), "You have deleted boombox %d.", id);
	SendClientMessage(playerid, WHITE, string);
	return 1;
}

CMD:checkboombox(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 3)
		return 1;
		
	new id = strval(params);
	if(!IsBoombox(id) || isnull(params) || !IsNumeric(params))
		return SendClientMessage(playerid, GREY, "SYNTAX: /checkboombox [boomboxid]");
		
	new setby[25] = "Nobody";
	if(!isnull(Boomboxes[id][Boombox_SETBY]))
		strcpy(setby, Boomboxes[id][Boombox_SETBY], 25);
		
	format(string, sizeof(string), "Boombox %d was placed by %s and last station played was set by %s.", id, Boomboxes[id][Boombox_OWNER], Boomboxes[id][Boombox_SETBY]);
	SendClientMessage(playerid, WHITE, string);
	return 1;
}

CMD:deleteallboombox(playerid)
{
	if(Player[playerid][AdminLevel] < 3)
		return 1;

	for(new b; b < MAX_BOOMBOXES; b++)
	{
		if(IsBoombox(b))
			DestroyBoombox(b);
	}
		
	SendClientMessage(playerid, WHITE, "You have deleted all placed boomboxes.");
	return 1;
}

CMD:placeboombox(playerid)
{
	if(Player[playerid][PlayingHours] < 10)
		return SendClientMessage(playerid, GREY, "Error placing boombox: You don't have 10+ playing hours!");

	if(IsPlayerInAnyVehicle(playerid))
		return SendClientMessage(playerid, GREY, "Error placing boombox: You cannot do this inside a vehicle!");

	if(GetPlayerSpeed(playerid, 0) != 0)
		return SendClientMessage(playerid, GREY, "Error placing boombox: You must be stop moving.");
		
	if(Player[playerid][HasBoombox] == 0)
		return SendClientMessage(playerid, GREY, "Error placing boombox: You don't have one.");
	
	if(Player[playerid][PrisonID] == 2)
		return SendClientMessage(playerid, GREY, "Error placing boombox: You cannot place a boombox while inside prison.");
		
	new boxid = GetFreeBoomboxID();
	if(boxid == -1)
		return SendClientMessage(playerid, GREY, "Error placing boombox: Maximum boomboxes exceeded.");
		
	foreach(new b : Boomboxes)
	{
		if(IsPlayerInDynamicArea(playerid, Boomboxes[b][Boombox_AREA]))
		{
			return SendClientMessage(playerid, GREY, "Error placing boombox: In range of another boombox");
		}
	}
	
	new Float:x, Float:y, Float:z, Float:a, vw = GetPlayerVirtualWorld(playerid), int = GetPlayerInterior(playerid);
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, a);
	
	Boomboxes[boxid][Boombox_POS][0] = x;
	Boomboxes[boxid][Boombox_POS][1] = y;
	Boomboxes[boxid][Boombox_POS][2] = z - 1.0;
	Boomboxes[boxid][Boombox_POS][3] = a + 180.0;
	Boomboxes[boxid][Boombox_INT] = int;
	Boomboxes[boxid][Boombox_VW] = vw;
	Boomboxes[boxid][Boombox_OBJECT] = CreateDynamicObject(BOOMBOX_MODEL, x, y, z - 1.0, 0.00, 0.00, a + 180.0, vw, int);
	strcpy(Boomboxes[boxid][Boombox_OWNER], GetName(playerid), 25);
	Boomboxes[boxid][Boombox_STATE] = 0;
	Boomboxes[boxid][Boombox_URL] = 0;
	Boomboxes[boxid][Boombox_SETBY] = 0;
	Boomboxes[boxid][Boombox_TIMER] = gettime() + (60 * BOOMBOX_MINUTES);
	Boomboxes[boxid][Boombox_HEALTH] = Player[playerid][HasBoombox];
	Boomboxes[boxid][Boombox_AREA] = CreateDynamicSphere(x, y, z, BOOMBOX_RANGE, vw, int);
	// format(string, sizeof(string), "Boombox\n{5B7AD9}State: {FFFFFF}%s {5B7AD9}Playing: {FFFFFF}%s\n{5B7AD9}Health: {FFFFFF}%d%% {5B7AD9}Time left: {FFFFFF}%d minute(s)", (Boomboxes[boxid][Boombox_STATE]) ? ("On") : ("Off"), (isnull(Boomboxes[boxid][Boombox_URL])) ? ("No") : ("Yes"), Boomboxes[boxid][Boombox_HEALTH], (Boomboxes[boxid][Boombox_TIMER] - gettime()) / 60);
	// Boomboxes[boxid][Boombox_LABEL] = CreateDynamic3DTextLabel(string, WHITE, x, y, z - 0.7, 3.0, .worldid = vw, .interiorid = int);
	
	if(Boomboxes[boxid][Boombox_HEALTH] <= 50)
	{
		Boomboxes[boxid][Boombox_OBJECT2] = CreateDynamicObject(BOOMBOX_SMOKE, x, y, z - 1.8, 0.00, 0.00, a + 180.0, vw, int);
	}
	
	foreach(Player, i)
		Streamer_Update(i);
		
	Player[playerid][HasBoombox] = 0;
	
	format(string, sizeof(string), "* %s has placed down a boombox.", GetNameEx(playerid));
	NearByMessage(playerid, NICESKY, string);
	return AddBoombox(boxid);
}

CMD:takeboombox(playerid)
{
	if(Player[playerid][PlayingHours] < 10)
		return SendClientMessage(playerid, GREY, "Error taking boombox: You don't have 10+ playing hours!");

	if(IsPlayerInAnyVehicle(playerid))
		return SendClientMessage(playerid, GREY, "Error taking boombox: You cannot do this inside a vehicle!");
	
	if(Player[playerid][HasBoombox])
		return SendClientMessage(playerid, GREY, "Error taking boombox: You already have one.");

	new boxid = GetClosestBoombox(playerid, 3.0);
	
	if(boxid == -1)
		return SendClientMessage(playerid, GREY, "Error taking boombox: You are not near any boomboxes.");
	
	foreach(Player, i)
	{
		if(IsPlayerInDynamicArea(i, Boomboxes[boxid][Boombox_AREA]))
		{
			if(GetPVarInt(i, "PlayingBoombox"))
			{
				StopAudioStreamForPlayer(i);
				DeletePVar(i, "PlayingBoombox");
			}
		}
	}
	
	format(string, sizeof(string), "* %s has picked up a boombox.", GetNameEx(playerid));
	NearByMessage(playerid, NICESKY, string);

	Player[playerid][HasBoombox] = Boomboxes[boxid][Boombox_HEALTH];
	PlayerPlayNearbySoundEx(playerid, 6402, 7);
	DestroyBoombox(boxid);
	return 1;
}

CMD:fixboombox(playerid)
{
	if(!Player[playerid][Toolkit])
		return SendClientMessage(playerid, GREY, "Error fixing boombox: You need a toolkit.");

	if(IsPlayerInAnyVehicle(playerid))
		return SendClientMessage(playerid, GREY, "Error fixing boombox: You cannot do this inside a vehicle!");
		
	if(random(100) == 99)
	{
		Player[playerid][Toolkit] = 0;
		format(string, sizeof(string), "* %s broke their toolkit while fixing the boombox.", GetNameEx(playerid));
		return NearByMessage(playerid, NICESKY, string);
	}
		
	foreach(new b : Boomboxes)
	{
		if(IsPlayerInDynamicArea(playerid, Boomboxes[b][Boombox_AREA]) && IsPlayerInRangeOfPoint(playerid, 3.0, Boomboxes[b][Boombox_POS][0], Boomboxes[b][Boombox_POS][1], Boomboxes[b][Boombox_POS][2]))
		{
			Boomboxes[b][Boombox_HEALTH] = 100;
			
			if(IsValidDynamicObject(Boomboxes[b][Boombox_OBJECT2]))
				DestroyDynamicObject(Boomboxes[b][Boombox_OBJECT2]);
			
			format(string, sizeof(string), "* %s has fixed the boombox.", GetNameEx(playerid));
			NearByMessage(playerid, NICESKY, string);
			
			// format(string, sizeof(string), "Boombox\n{5B7AD9}State: {FFFFFF}%s {5B7AD9}Playing: {FFFFFF}%s\n{5B7AD9}Health: {FFFFFF}%d%% {5B7AD9}Time left: {FFFFFF}%d minute(s)", (Boomboxes[b][Boombox_STATE]) ? ("On") : ("Off"), (isnull(Boomboxes[b][Boombox_URL])) ? ("No") : ("Yes"), Boomboxes[b][Boombox_HEALTH], (Boomboxes[b][Boombox_TIMER] - gettime()) / 60);
			// UpdateDynamic3DTextLabelText(Boomboxes[b][Boombox_LABEL], WHITE, string);
			PlayerPlayNearbySoundEx(playerid, 6003, 7);
			break;
		}
	}
	return 1;
}

CMD:boombox(playerid, params[])
{
	if(Player[playerid][PlayingHours] < 10)
		return SendClientMessage(playerid, GREY, "Error using boombox: You don't have 10+ playing hours!");

	if(IsPlayerInAnyVehicle(playerid))
		return SendClientMessage(playerid, GREY, "Error using boombox: You cannot do this inside a vehicle!");
		
	if(Player[playerid][PrisonDuration] > 0 || Player[playerid][PrisonID] > 0)
		return SendClientMessage(playerid, GREY, "Error using boombox: You can't do that while in prison!");
		
	new boxid = GetClosestBoombox(playerid, 3.0);

	if(boxid == -1)
		return SendClientMessage(playerid, GREY, "Error using boombox: You are not close enough to one.");
	
	#define boombox_option(%0) !strcmp(params, %0, true)
	
	if(boombox_option("station"))
	{
		if(Boomboxes[boxid][Boombox_STATE] == 0)
			return SendClientMessage(playerid, GREY, "Error using boombox: It's not turned on.");
			
		new end[255];
		for(new i; i < MAX_RADIO_STATIONS; i++)
		{
			if(RadioSettings[i][Available] > 0)
			{
				format(string, sizeof(string), "%s\n", RadioSettings[i][StationName]);
				strcat(end, string);
			}
		}
		ShowPlayerDialog(playerid, BOOMBOX_STATION, DIALOG_STYLE_LIST, "Boombox Stations", end, "Select", "Close");
	}
	else if(boombox_option("tune"))
	{
		if(Boomboxes[boxid][Boombox_STATE] == 0)
			return SendClientMessage(playerid, GREY, "Error using boombox: It's not turned on.");

		if(Player[playerid][VipRank] < 1)
			return SendClientMessage(playerid, -1, "Tuning your radio is a VIP perk!");
			
		ShowPlayerDialog(playerid, BOOMBOX_TUNE, DIALOG_STYLE_INPUT, "Boombox Stations", "Enter the URL for the radio stream.", "Select", "Close");
	}
	else if(boombox_option("toggle"))
	{
		Boomboxes[boxid][Boombox_STATE] = (Boomboxes[boxid][Boombox_STATE]) ? (0) : (1);
		
		format(string, sizeof(string), "* %s has turned %s the boombox.", GetNameEx(playerid), (Boomboxes[boxid][Boombox_STATE]) ? ("on") : ("off"));
		NearByMessage(playerid, NICESKY, string);
		
		// format(string, sizeof(string), "Boombox\n{5B7AD9}State: {FFFFFF}%s {5B7AD9}Playing: {FFFFFF}%s\n{5B7AD9}Health: {FFFFFF}%d%% {5B7AD9}Time left: {FFFFFF}%d minute(s)", (Boomboxes[boxid][Boombox_STATE]) ? ("On") : ("Off"), (isnull(Boomboxes[boxid][Boombox_URL])) ? ("No") : ("Yes"), Boomboxes[boxid][Boombox_HEALTH], (Boomboxes[boxid][Boombox_TIMER] - gettime()) / 60);
		// UpdateDynamic3DTextLabelText(Boomboxes[boxid][Boombox_LABEL], WHITE, string);
		
		Boomboxes[boxid][Boombox_URL] = 0;
		
		if(!Boomboxes[boxid][Boombox_STATE])
		{
			foreach(Player, i)
			{
				if(IsPlayerInDynamicArea(i, Boomboxes[boxid][Boombox_AREA]) && GetPVarInt(playerid, "PlayingBoombox"))
				{
					StopAudioStreamForPlayer(i);
					DeletePVar(playerid, "PlayingBoombox");
				}
			}
		}
	}
	else
		SendClientMessage(playerid, GREY, "SYNTAX: /boombox [toggle/station/tune]");
	return 1;
}

stock GetClosestBoombox(playerid, Float:range = 5.0)
{
	foreach(new b : Boomboxes)
	{
		if(IsPlayerInRangeOfPoint(playerid, range, Boomboxes[b][Boombox_POS][0], Boomboxes[b][Boombox_POS][1], Boomboxes[b][Boombox_POS][2]))
			return b;
	}
	return -1;
}

stock DestroyBoombox(boxid)
{
	if(!IsBoombox(boxid))
		return 1;
		
	foreach(Player, i)
	{
		if(IsPlayerInDynamicArea(i, Boomboxes[boxid][Boombox_AREA]) && GetPVarInt(i, "PlayingBoombox"))
		{
			StopAudioStreamForPlayer(i);
			DeletePVar(i, "PlayingBoombox");
		}
	}
		
	Boomboxes[boxid][Boombox_POS][0] = 0.00;
	Boomboxes[boxid][Boombox_POS][1] = 0.00;
	Boomboxes[boxid][Boombox_POS][2] = 0.00;
	Boomboxes[boxid][Boombox_POS][3] = 0.00;
	Boomboxes[boxid][Boombox_INT] = 0;
	Boomboxes[boxid][Boombox_VW] = 0;
	if(IsValidDynamicObject(Boomboxes[boxid][Boombox_OBJECT]))
		DestroyDynamicObject(Boomboxes[boxid][Boombox_OBJECT]);
	if(IsValidDynamicObject(Boomboxes[boxid][Boombox_OBJECT2]))
		DestroyDynamicObject(Boomboxes[boxid][Boombox_OBJECT2]);
	Boomboxes[boxid][Boombox_OWNER] = 0;
	Boomboxes[boxid][Boombox_URL] = 0;
	Boomboxes[boxid][Boombox_SETBY] = 0;
	Boomboxes[boxid][Boombox_STATE] = 0;
	Boomboxes[boxid][Boombox_TIMER] = 0;
	Boomboxes[boxid][Boombox_HEALTH] = 0;
	if(IsValidDynamicArea(Boomboxes[boxid][Boombox_AREA]))
		DestroyDynamicArea(Boomboxes[boxid][Boombox_AREA]);
	// if(IsValidDynamic3DTextLabel(Boomboxes[boxid][Boombox_LABEL]))
		// DestroyDynamic3DTextLabel(Boomboxes[boxid][Boombox_LABEL]);
	return RemoveBoombox(boxid);
}

stock PlayBoombox(playerid, b)
{	
	if(!IsBoombox(b))
		return 1;
		
	SetPVarInt(playerid, "PlayingBoombox", 1);
	PlayAudioStreamForPlayer(playerid, Boomboxes[b][Boombox_URL], Boomboxes[b][Boombox_POS][0], Boomboxes[b][Boombox_POS][1], Boomboxes[b][Boombox_POS][2], BOOMBOX_RANGE, 1);
	return 1;
}

task BoomboxUpdate[60000]()
{
	for(new b; b < MAX_BOOMBOXES; b++)
	{
		if(IsBoombox(b))
		{
			if(Boomboxes[b][Boombox_TIMER] > 0 && Boomboxes[b][Boombox_TIMER] < gettime())
			{
				foreach(Player, i)
				{
					if(IsPlayerInDynamicArea(i, Boomboxes[b][Boombox_AREA]))
					{
						StopAudioStreamForPlayer(i);
						DeletePVar(i, "PlayingBoombox");
					}
				}
				DestroyBoombox(b);
				continue;
			}
			
			// format(string, sizeof(string), "Boombox\n{5B7AD9}State: {FFFFFF}%s {5B7AD9}Playing: {FFFFFF}%s\n{5B7AD9}Health: {FFFFFF}%d%% {5B7AD9}Time left: {FFFFFF}%d minute(s)", (Boomboxes[b][Boombox_STATE]) ? ("On") : ("Off"), (isnull(Boomboxes[b][Boombox_URL])) ? ("No") : ("Yes"), Boomboxes[b][Boombox_HEALTH], (Boomboxes[b][Boombox_TIMER] - gettime()) / 60);
			// UpdateDynamic3DTextLabelText(Boomboxes[b][Boombox_LABEL], WHITE, string);
		}
	}
	return 1;
}

hook OnPlayerEnterDynamicArea(playerid, areaid)
{
	foreach(new b : Boomboxes)
	{
		if(areaid == Boomboxes[b][Boombox_AREA])
		{
			if(!isnull(Boomboxes[b][Boombox_URL]) && Boomboxes[b][Boombox_STATE] && !IsPlayerInAnyVehicle(playerid))
			{
				PlayBoombox(playerid, b);
			}
		}
	}
	return 1;
}

hook OnPlayerLeaveDynamicArea(playerid, areaid)
{
	foreach(new b : Boomboxes)
	{
		if(areaid == Boomboxes[b][Boombox_AREA])
		{
			if(GetPVarInt(playerid, "PlayingBoombox") && Boomboxes[b][Boombox_STATE] && !IsPlayerInAnyVehicle(playerid))
			{
				StopAudioStreamForPlayer(playerid);
				DeletePVar(playerid, "PlayingBoombox");
			}
		}
	}
	return 1;
}

hook OnPlayerShootDynamicObject(playerid, weaponid, objectid, Float:x, Float:y, Float:z)
{
	foreach(new b : Boomboxes)
	{
		if(Boomboxes[b][Boombox_OBJECT] == objectid)
		{
			if(Player[playerid][PlayingHours] < 10)
				return 1;
		
			Boomboxes[b][Boombox_HEALTH] -= 5;
			// format(string, sizeof(string), "Boombox\n{5B7AD9}State: {FFFFFF}%s {5B7AD9}Playing: {FFFFFF}%s\n{5B7AD9}Health: {FFFFFF}%d%% {5B7AD9}Time left: {FFFFFF}%d minute(s)", (Boomboxes[b][Boombox_STATE]) ? ("On") : ("Off"), (isnull(Boomboxes[b][Boombox_URL])) ? ("No") : ("Yes"), Boomboxes[b][Boombox_HEALTH], (Boomboxes[b][Boombox_TIMER] - gettime()) / 60);
			// UpdateDynamic3DTextLabelText(Boomboxes[b][Boombox_LABEL], WHITE, string);
			if(Boomboxes[b][Boombox_HEALTH] == 50)
			{
				foreach(Player, i)
					Streamer_Update(i);
				Boomboxes[b][Boombox_OBJECT2] = CreateDynamicObject(BOOMBOX_SMOKE, Boomboxes[b][Boombox_POS][0], Boomboxes[b][Boombox_POS][1], Boomboxes[b][Boombox_POS][2] - 0.8, 0.00, 0.00, Boomboxes[b][Boombox_POS][3], Boomboxes[b][Boombox_VW], Boomboxes[b][Boombox_INT]);
			}
			if(Boomboxes[b][Boombox_HEALTH] < 1)
			{
				foreach(Player, i)
				{
					if(IsPlayerInDynamicArea(i, Boomboxes[b][Boombox_AREA]))
					{
						if(IsPlayerInRangeOfPoint(i, 7.0, Boomboxes[b][Boombox_POS][0], Boomboxes[b][Boombox_POS][1], Boomboxes[b][Boombox_POS][2]))
						{
							SendClientMessage(i, NICESKY, "* A boombox nearby falls to pieces.");
						}
						
						if(GetPVarInt(i, "PlayingBoombox"))
						{
							StopAudioStreamForPlayer(i);
							DeletePVar(i, "PlayingBoombox");
						}
					}
				}
				PlayerPlayNearbySoundEx(playerid, 6402, 7);
				return DestroyBoombox(b);
			}
		}
	}
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(!response)
		return 1;

	if(dialogid == BOOMBOX_TUNE)
	{
		new boxid = GetClosestBoombox(playerid, 3.0);
		
		if(boxid == -1)
			return SendClientMessage(playerid, GREY, "Error using boombox: It appears you are no longer nearby a boombox.");
		
		strcpy(Boomboxes[boxid][Boombox_URL], inputtext, 255);
		
		foreach(Player, i)
		{
			if(IsPlayerInDynamicArea(i, Boomboxes[boxid][Boombox_AREA]) && !IsPlayerInAnyVehicle(i))
			{
				StopAudioStreamForPlayer(i);
				PlayBoombox(i, boxid);
			}
		}
			
		strcpy(Boomboxes[boxid][Boombox_SETBY], GetName(playerid), 25);
			
		// format(string, sizeof(string), "Boombox\n{5B7AD9}State: {FFFFFF}%s {5B7AD9}Playing: {FFFFFF}%s\n{5B7AD9}Health: {FFFFFF}%d%% {5B7AD9}Time left: {FFFFFF}%d minute(s)", (Boomboxes[boxid][Boombox_STATE]) ? ("On") : ("Off"), (isnull(Boomboxes[boxid][Boombox_URL])) ? ("No") : ("Yes"), Boomboxes[boxid][Boombox_HEALTH], (Boomboxes[boxid][Boombox_TIMER] - gettime()) / 60);
		// UpdateDynamic3DTextLabelText(Boomboxes[boxid][Boombox_LABEL], WHITE, string);
		
		format(string, sizeof(string), "* %s tunes the boomboxes station.", GetNameEx(playerid));
		NearByMessage(playerid, NICESKY, string);
	}
	else if(dialogid == BOOMBOX_STATION)
	{
		new boxid = GetClosestBoombox(playerid, 3.0);
		
		if(boxid == -1)
			return SendClientMessage(playerid, GREY, "Error using boombox: It appears you are no longer nearby a boombox.");
		
		new radioid = -1;
		for(new i; i < MAX_RADIO_STATIONS; i++)
		{
			if(!strcmp(inputtext, RadioSettings[i][StationName], true))
			{
				radioid = i;
			}
		}

		if(radioid == -1)
			return SendClientMessage(playerid, GREY, "Error changing station: Cannot find radio station.");

		strcpy(Boomboxes[boxid][Boombox_URL], RadioSettings[radioid][URL], 255);
		
		foreach(Player, i)
		{
			if(IsPlayerInDynamicArea(i, Boomboxes[boxid][Boombox_AREA]) && !IsPlayerInAnyVehicle(i))
			{
				StopAudioStreamForPlayer(i);
				PlayBoombox(i, boxid);
			}
		}

		strcpy(Boomboxes[boxid][Boombox_SETBY], GetName(playerid), 25);
			
		// format(string, sizeof(string), "Boombox\n{5B7AD9}State: {FFFFFF}%s {5B7AD9}Playing: {FFFFFF}%s\n{5B7AD9}Health: {FFFFFF}%d%% {5B7AD9}Time left: {FFFFFF}%d minute(s)", (Boomboxes[boxid][Boombox_STATE]) ? ("On") : ("Off"), (isnull(Boomboxes[boxid][Boombox_URL])) ? ("No") : ("Yes"), Boomboxes[boxid][Boombox_HEALTH], (Boomboxes[boxid][Boombox_TIMER] - gettime()) / 60);
		// UpdateDynamic3DTextLabelText(Boomboxes[boxid][Boombox_LABEL], WHITE, string);
		
		format(string, sizeof(string), "* %s changes the boombox station to '%s'.", GetNameEx(playerid), RadioSettings[radioid][StationName]);
		NearByMessage(playerid, NICESKY, string);
	}
	return 1;
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_ONFOOT && (oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER))
	{
		foreach(new b : Boomboxes)
		{
			if(IsPlayerInDynamicArea(playerid, Boomboxes[b][Boombox_AREA]))
			{
				if(!isnull(Boomboxes[b][Boombox_URL]) && Boomboxes[b][Boombox_STATE] == 1 && GetPVarInt(playerid, "PlayingBoombox") != 1 && !IsPlayerInAnyVehicle(playerid))
				{
					SetPVarInt(playerid, "PlayingBoombox", 1);
					return PlayBoombox(playerid, b);
				}
			}
		}
	}
	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
	{
		if(GetPVarInt(playerid, "PlayingBoombox"))
		{
			StopAudioStreamForPlayer(playerid);
			DeletePVar(playerid, "PlayingBoombox");
		}
	}
	return 1;
}