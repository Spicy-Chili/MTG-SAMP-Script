/*
#		MTG Toggles
#
#
#	By accessing this file, you agree to the following:
#		- You will never give the script or associated files to anybody who is not on the MTG SAMP development team
# 		- You will delete all development materials (script, databases, associated files, etc.) when you leave the MTG SAMP development team.
#
#
#
*/
#include <YSI\y_hooks>

#define MAX_TOGGLES		19

#define TOGGLE_NEWBIE			0
#define TOGGLE_VIP				1
#define TOGGLE_SPEEDO			2
#define TOGGLE_BIZ_TIPS			3
#define TOGGLE_NEWS				4
#define TOGGLE_SAM_RADIO		5
#define TOGGLE_VEH_NAMES		6
#define TOGGLE_3D_LABELS		7 
#define TOGGLE_NAME_TAGS		8 
#define TOGGLE_INT_FREEZE		9
#define TOGGLE_EXIT_HELP		10
#define TOGGLE_WALKIE			11 
#define TOGGLE_RADIO			12 
#define TOGGLE_PMS				13
#define TOGGLE_QUIZ				14
#define TOGGLE_HUNGER_BAR		15 
#define TOGGLE_HEALTH_BAR		16
#define TOGGLE_FUEL_BAR			17
#define TOGGLE_ANIMATION_TEXT	18

forward bool:GetPlayerToggle(playerid, toggle_id);

new bool:PlayerToggles[MAX_PLAYERS][MAX_TOGGLES];

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DIALOG_TOGGLES:
		{
			if(!response) return DeletePVar(playerid, "LAST_TOGGLE_ID"), DeletePVar(playerid, "LAST_TOGGLE_START_ID");
			
			listitem += GetPVarInt(playerid, "LAST_TOGGLE_START_ID");
			
			if(!strcmp(inputtext, "Next Page", true))
				return ShowTogglesDialog(playerid, GetPVarInt(playerid, "LAST_TOGGLE_ID"));
			
			if(listitem == TOGGLE_WALKIE && (Player[playerid][PrisonDuration] > 0 || Player[playerid][PrisonID] > 0))
				return SendClientMessage(playerid, WHITE, "You can't toggle your walkie in prison.");
			
			if(GetPlayerToggle(playerid, listitem) == true)
				SetPlayerToggle(playerid, listitem, false);
			else SetPlayerToggle(playerid, listitem, true);
		
			new string[128];
			format(string, sizeof(string), "You have toggled %s %s.", GetToggleName(listitem), (GetPlayerToggle(playerid, listitem) == true) ? ("{FF0000}off") : ("{33A10B}on"));
			SendClientMessage(playerid, WHITE, string);
			LoadToggleSettings(playerid, listitem);
			SavePlayerToggles(playerid);
			return ShowTogglesDialog(playerid, GetPVarInt(playerid, "LAST_TOGGLE_START_ID"));
		}
	}
	return 1;
}

CMD:toggles(playerid, params[])
{
	ShowTogglesDialog(playerid);
	return 1;
}

CMD:quicktoggle(playerid, params[])
{
	if(isnull(params))
		return SendClientMessage(playerid, WHITE, "SYNTAX: /quicktoggle [toggle name]");
	
	new toggle_id = -1;
	for(new i; i < MAX_TOGGLES; i++)
	{
		if(!strcmp(params, GetToggleName(i), true))
		{
			toggle_id = i;
			break;
		}
	}
	
	if(toggle_id == -1)
		return SendClientMessage(playerid, WHITE, "No toggle found by that name...");
	
	if(toggle_id == TOGGLE_WALKIE && (Player[playerid][PrisonDuration] > 0 || Player[playerid][PrisonID] > 0))
		return SendClientMessage(playerid, WHITE, "You can't toggle your walkie in prison.");
	
	if(GetPlayerToggle(playerid, toggle_id) == true)
		SetPlayerToggle(playerid, toggle_id, false);
	else SetPlayerToggle(playerid, toggle_id, true);

	new string[128];
	format(string, sizeof(string), "You have toggled %s %s.", GetToggleName(toggle_id), (GetPlayerToggle(playerid, toggle_id) == true) ? ("{FF0000}off") : ("{33A10B}on"));
	SendClientMessage(playerid, WHITE, string);
	LoadToggleSettings(playerid, toggle_id);
	SavePlayerToggles(playerid);
	return 1;
}

static ShowTogglesDialog(playerid, start = 0)
{
	new string[384], count;
	SetPVarInt(playerid, "LAST_TOGGLE_START_ID", start);
	for(new i = start; i < MAX_TOGGLES; i ++)
	{
		new toggle_status = GetPlayerToggle(playerid, i);
		format(string, sizeof(string), "%s%s: %s\n", string, GetToggleName(i), (toggle_status == 1) ? ("{FF0000}OFF") : ("{33A10B}ON"));
		
		count++;
		if(count == 10 && i + 1 < MAX_TOGGLES)
		{
			format(string, sizeof(string), "%sNext Page", string);
			SetPVarInt(playerid, "LAST_TOGGLE_ID", i + 1);
			break;
		}
	}
	
	return ShowPlayerDialog(playerid, DIALOG_TOGGLES, DIALOG_STYLE_LIST, "Player Toggles", string, "Toggle", "Cancel");
}

stock SetPlayerToggle(playerid, toggle_id, bool:toggle) 
{
	PlayerToggles[playerid][toggle_id] = toggle;
	return 1;
}
public bool:GetPlayerToggle(playerid, toggle_id) {return PlayerToggles[playerid][toggle_id];}

stock GetToggleName(toggle_id)
{
	new name[32];
	switch(toggle_id)
	{
		case TOGGLE_NEWBIE: name = "Newbie Chat";
		case TOGGLE_VIP: name = "VIP Chat";
		case TOGGLE_SPEEDO: name = "Speedometer";
		case TOGGLE_BIZ_TIPS: name = "Business Tips";
		case TOGGLE_NEWS: name = "LSNN News Messages";
		case TOGGLE_SAM_RADIO: name = "LSNN Radio Messages";
		case TOGGLE_VEH_NAMES: name = "Vehicle Names";
		case TOGGLE_3D_LABELS: name = "3D Text Labels";
		case TOGGLE_NAME_TAGS: name = "Nametags";
		case TOGGLE_INT_FREEZE: name = "Enter/Exit Freeze";
		case TOGGLE_EXIT_HELP: name = "Exit Help Text";
		case TOGGLE_WALKIE: name = "Walkie Talkie";
		case TOGGLE_RADIO: name = "Faction Radio";
		case TOGGLE_PMS: name = "Private Messages";
		case TOGGLE_QUIZ: name = "Admin Quiz Game";
		case TOGGLE_HUNGER_BAR: name = "Hunger Bar";
		case TOGGLE_HEALTH_BAR: name = "Health Bar";
		case TOGGLE_FUEL_BAR: name = "Fuel Bar";
		case TOGGLE_ANIMATION_TEXT: name = "Animation Text";
		default: name = "Invalid Toggle";
	}
	return name;
}

static LoadToggleSettings(playerid, toggle)
{
	switch(toggle)
	{
		case TOGGLE_3D_LABELS:
		{
			if(GetPlayerToggle(playerid, TOGGLE_3D_LABELS) == false)
			{
				new UpperBound = Streamer_GetUpperBound(STREAMER_TYPE_3D_TEXT_LABEL);
				for(new i; i < UpperBound; i++)
				{
					new string[64];
					format(string, sizeof(string), "PlayerLabel_%d", i);
					if(GetSVarInt(string) != 0)
						continue;
					
					if(IsValidDynamic3DTextLabel(Text3D:i))
						Streamer_AppendArrayData(STREAMER_TYPE_3D_TEXT_LABEL, i, E_STREAMER_PLAYER_ID, playerid);
				}
			}
			else
			{
				new UpperBound = Streamer_GetUpperBound(STREAMER_TYPE_3D_TEXT_LABEL);
				for(new i; i < UpperBound; i++)
				{	
					new string[64];
					format(string, sizeof(string), "PlayerLabel_%d", i);
					if(GetSVarInt(string) != 0)
						continue;
					
					if(IsValidDynamic3DTextLabel(Text3D:i))
						Streamer_RemoveArrayData(STREAMER_TYPE_3D_TEXT_LABEL, i, E_STREAMER_PLAYER_ID, playerid);
				}
			}
		}
		case TOGGLE_NAME_TAGS:
		{
			if(GetPlayerToggle(playerid, TOGGLE_NAME_TAGS) == false)
			{
				foreach(Player, i)
				{
					if(Player[i][Mask] < 1)
						ShowPlayerNameTagForPlayer(playerid, i, 1);
				}
			}
			else
			{
				foreach(Player, i)
				{
					if(Player[i][Mask] < 1)
						ShowPlayerNameTagForPlayer(playerid, i, 0);
				}
			}
		}
		case TOGGLE_HUNGER_BAR: DisplayHunger(playerid);
		case TOGGLE_HEALTH_BAR: 
		{
			if(GetPlayerToggle(playerid, TOGGLE_HEALTH_BAR) == false)
			{
				DeletePVar(playerid, "TOGGLED_HEALTH_BAR");
				SetHealthBarVisible(playerid, true);
			}
			else 
			{
				SetHealthBarVisible(playerid, false);
				SetPVarInt(playerid, "TOGGLED_HEALTH_BAR", 1);
			}
		}
		case TOGGLE_FUEL_BAR:
		{	
			if(GetPlayerToggle(playerid, TOGGLE_FUEL_BAR) == false)
			{
				if(IsPlayerInAnyVehicle(playerid))
				{
					vFuel[playerid] = CreatePlayerProgressBar(playerid, 548.5, 26.0, _, _, 0x00FF00FF, 100.0);
					ShowPlayerProgressBar(playerid, vFuel[playerid]);
				}
			}
			else 
			{
				if(vFuel[playerid] != INVALID_PLAYER_BAR_ID)
				{
					DestroyPlayerProgressBar(playerid, vFuel[playerid]);
					vFuel[playerid] = INVALID_PLAYER_BAR_ID;
				}
			}
		}
	}
	return 1;
}

stock SavePlayerToggles(playerid)
{
	new toggle_string[(MAX_TOGGLES * 2) + 1];
	
	for(new i; i < MAX_TOGGLES; i ++)
	{	
		new toggle = (GetPlayerToggle(playerid, i) == true) ? (1) : (0);
		format(toggle_string, sizeof(toggle_string), "%s%d ", toggle_string, toggle);
	}
	
	new query[128];
	mysql_format(MYSQL_MAIN, query, sizeof(query), "UPDATE playeraccounts SET player_toggles = '%e' WHERE SQLID = '%d'", toggle_string, Player[playerid][pSQL_ID]);
	mysql_query(MYSQL_MAIN, query, false);
	return 1;
}

stock LoadPlayerToggles(playerid)
{
	inline OnTogglesLoad() 
	{
		new toggle_string[(MAX_TOGGLES * 2) + 1];
		cache_get_field_content(0, "player_toggles", toggle_string);
		
		new toggle_array[MAX_TOGGLES];
		sscanf(toggle_string, "a<i>["#MAX_TOGGLES"]", toggle_array);
		
		for(new i; i < MAX_TOGGLES; i++)
		{
			SetPlayerToggle(playerid, i, false);
			
			if(toggle_array[i] == 1)
			{
				SetPlayerToggle(playerid, i, true);
				LoadToggleSettings(playerid, i);
			}
		}
		
		SendClientMessage(playerid, WHITE, "Your toggle settings have been loaded.");
	}
	
	new query[128];
	mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT player_toggles FROM playeraccounts WHERE SQLID = '%d'", Player[playerid][pSQL_ID]);
	mysql_tquery_inline(MYSQL_MAIN, query, using inline OnTogglesLoad, "");
	return 1;
}