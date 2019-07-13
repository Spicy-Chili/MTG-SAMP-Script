/*
#		MTG Groups - Gangs
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

#define GANG_VW			15000

#define MAX_GANGSAFE_STORAGE	7

#define MAX_RANKS				10
#define MAX_RANK_NAME			32

#define TOTAL_PERMISSIONS		19

#define GANGSAFE_MATSLOW	0
#define GANGSAFE_MATSMID	1
#define GANGSAFE_MATSHIGH	2
#define GANGSAFE_POT		3
#define GANGSAFE_COCAINE	4
#define GANGSAFE_SPEED		5
#define GANGSAFE_CASH		6

#define GANG_TYPE_NONE		0
#define GANG_TYPE_DEFAULT	1
#define GANG_TYPE_CASINO	2

#define GANG_HQLINK_TYPE_HOUSE		1
#define GANG_HQLINK_TYPE_BIZ		2

#define PERM_STRING_LENGTH	1024

static string[128];

enum gangs_
{
	// HQ Stuff
	GangSQL,
	Float:ExtPos[3],
	ExtVW,
	ExtIntID,
	Float:IntPos[3],
	IntVW,
	IntID,
	HQLockStatus,
	
	HQLinkID,
	HQLinkType,
	
	GangName[32],
	GangType,
	GangIcon,
	Text3D:GangLabel,
	GangHQRadio,
	GangHQRadioStation[128],
	MOTD[128],
	
	//Safe
	GangSafe[MAX_GANGSAFE_STORAGE],
	Float:GangSafePos[3],
	GangSafeInt,
	GangSafeVW,
	GangSafeIcon,
	Text3D:GangSafeLabel,
	
	//Chat
	GangChatDisabled,
	
};
new Gangs[MAX_GANGS][gangs_];
new Iterator:Gang<MAX_GANGS>;

enum ranks_
{
	RankName[MAX_RANK_NAME],
	RankPermissions[TOTAL_PERMISSIONS],
};
new GangRanks[MAX_GANGS][MAX_RANKS][ranks_];

// ============= Command Permissions =============

#define PERM_GCP				0
#define PERM_GCHANGERANK		1
#define PERM_GANGSAFEWITHDRAW	2
#define PERM_GANGSAFEDEPOSIT	3
#define PERM_GANGSAFEBALANCE	4
#define PERM_GANGSAFELOC		5
#define PERM_GRADIO				6
#define PERM_LOCKGANGHQ			7
#define PERM_GANGCHAT			8
#define PERM_TOGGLEGANGCHAT		9
#define PERM_GUNINVITE			10
#define PERM_GINVITE			11
#define PERM_VEHICLES			12
#define PERM_PARKCAR			13
#define PERM_MOTD				14
#define PERM_GANGIMPLIST		15
#define PERM_REMOTEUNINVITE		16
#define PERM_CREATEBOMBS 		17
#define PERM_CREATEFAKEDOCS		18

enum commands_
{
	CommandID,
	CommandDesc[64],
	CommandDefault,
};

new CommandDefaults[TOTAL_PERMISSIONS][commands_] = 
{
	{PERM_GCP, "Access this panel", 5},
	{PERM_GCHANGERANK, "Change a gang member's rank", 5},
	{PERM_GANGSAFEWITHDRAW, "Withdraw from the gang safe", 5},
	{PERM_GANGSAFEDEPOSIT, "Deposit into the gang safe", 1},
	{PERM_GANGSAFEBALANCE, "View the gang safe balance", 1},
	{PERM_GANGSAFELOC, "Move the gang safe location", 5},
	{PERM_GRADIO, "Use the gang radio", 2},
	{PERM_LOCKGANGHQ, "Lock the gang HQ", 5},
	{PERM_GANGCHAT, "Use the gang chat", 1},
	{PERM_TOGGLEGANGCHAT, "Toggle the gang chat on and off", 5},
	{PERM_GUNINVITE, "Remove players from the gang", 5},
	{PERM_GINVITE, "Invite players to the gang", 5},
	{PERM_VEHICLES, "Lock/unlock gang vehicles", 1},
	{PERM_PARKCAR, "Park a gang vehicle", 5},
	{PERM_MOTD, "Change the MOTD", 5},
	{PERM_GANGIMPLIST, "Unimpound vehicles from the impound", 5},
	{PERM_REMOTEUNINVITE, "Uninvite players from the faction remotely.", 6},
	{PERM_CREATEBOMBS, "Create bombs using /createbomb", 6},
	{PERM_CREATEFAKEDOCS, "Create fake IDs and registrations", 5}
};

// ============= Callbacks =============

/*hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsKeyJustDown(Player[playerid][EnterKey], newkeys, oldkeys) && !IsPlayerInAnyVehicle(playerid))
	{
		if(Player[playerid][InGangHQ] > 0)
		{
			new id = Player[playerid][InGangHQ];
			if(IsPlayerInRangeOfPoint(playerid, 5, Gangs[id][IntPos][0], Gangs[id][IntPos][1], Gangs[id][IntPos][2]))
			{
				if(Gangs[id][HQLockStatus] == 1)
					return SendClientMessage(playerid, WHITE, "The door is locked!");
				
				Player[playerid][InGangHQ] = 0;
				SetPlayerPos(playerid, Gangs[id][ExtPos][0], Gangs[id][ExtPos][1], Gangs[id][ExtPos][2]);
				SetPlayerVirtualWorld(playerid, Gangs[id][ExtVW]);
				SetPlayerInterior(playerid, Gangs[id][ExtIntID]);
				StopAudioStreamForPlayer(playerid);
			}
		}
		else 
		{
			foreach(new g : Gang)
			{
				if(IsPlayerInRangeOfPoint(playerid, 5, Gangs[g][ExtPos][0], Gangs[g][ExtPos][1], Gangs[g][ExtPos][2]))
				{
					if(Gangs[g][HQLockStatus] == 1)
						return SendClientMessage(playerid, WHITE, "The door is locked!");
					
					Player[playerid][InGangHQ] = g;
					SetPlayerPos(playerid, Gangs[g][IntPos][0], Gangs[g][IntPos][1], Gangs[g][IntPos][2]);
					SetPlayerVirtualWorld(playerid, Gangs[g][IntVW]);
					SetPlayerInterior(playerid, Gangs[g][IntID]);
					
					if(Gangs[g][GangHQRadio])
						PlayAudioStreamForPlayer(playerid, Gangs[g][GangHQRadioStation]);
					return 1;
				}
			}
		}
	}
	return 1;
}*/

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case GANG_HQ_RADIO:
		{
			if(!response)
				return 1;
				
			new radioid = -1;
			for(new i; i < MAX_RADIO_STATIONS; i++)
			{
				if(!strcmp(inputtext, RadioSettings[i][StationName], true))
				{
					radioid = i;
				}
			}
		
			if(radioid == -1)
				return SendClientMessage(playerid, -1, "Unable to find radioid station.");
		
			format(Gangs[Player[playerid][Gang]][GangHQRadioStation], 128, "%s", RadioSettings[radioid][URL]);
			foreach(Player, i)
			{
				if(Player[i][InGangHQ] == Player[playerid][Gang])
				{
					StopAudioStreamForPlayer(i);
					PlayAudioStreamForPlayer(i, Gangs[Player[playerid][Gang]][GangHQRadioStation]);
				}
			}
		}
		case GCP_MAIN:
		{
			if(!response)
				return 1;
				
			switch(listitem)
			{
				case 0:
				{
					format(string, sizeof(string), "{127C00}- %s's Gang Control Panel -\n{3D6666}Edit Ranks\n{3D6666}Total Members: {4DB84D}%d", Gangs[Player[playerid][Gang]][GangName], GetGangMemberCount(Player[playerid][Gang]));
					return ShowPlayerDialog(playerid, GCP_MAIN, DIALOG_STYLE_LIST, "Gang Control Panel", string, "Select", "Exit");
				}
				case 1:
				{
					new id = Player[playerid][Gang];
					new rankString[600];
					for(new i; i < MAX_RANKS; i++)
					{
						format(rankString, sizeof(rankString), "%s{3D6666}Rank %d {666666}| {4DB84D}%s\n", rankString, i + 1, GangRanks[id][i][RankName]);
					}
					ShowPlayerDialog(playerid, GCP_RANK_MAIN, DIALOG_STYLE_LIST, "Gang Control Panel - Edit Ranks", rankString, "Edit", "Exit");
				}
				case 2:
				{
					DisplayGangMembers(playerid, Player[playerid][Gang]);
				}
			}
		}
		case GCP_RANK_MAIN:
		{
			if(!response)
				return 1;
			
			if(listitem + 1 > Player[playerid][GangRank])
				return SendClientMessage(playerid, RED, "You can't edit a rank higher than your own.");
			
			SetPVarInt(playerid, "GCP_RANK_EDIT_ID", listitem);
			format(string, sizeof(string), "Gang Control Panel - Edit Ranks - Rank %d", listitem + 1);
			ShowPlayerDialog(playerid, GCP_RANK_EDIT_MENU, DIALOG_STYLE_LIST, string, "Edit Rank Name\nEdit Rank Permissions", "Select", "Back");
		}
		case GCP_RANK_EDIT_MENU:
		{
			if(!response)
			{
				DeletePVar(playerid, "GCP_RANK_EDIT_ID");
				new id = Player[playerid][Gang];
				new rankString[640];
				for(new i; i < MAX_RANKS; i++)
				{
					format(rankString, sizeof(rankString), "%s{3D6666}Rank %d {666666}| {4DB84D}%s\n", rankString, i + 1, GangRanks[id][i][RankName]);
				}
				return ShowPlayerDialog(playerid, GCP_RANK_MAIN, DIALOG_STYLE_LIST, "Gang Control Panel - Edit Ranks", rankString, "Edit", "Exit");
			}
			
			new rank = GetPVarInt(playerid, "GCP_RANK_EDIT_ID"), id = Player[playerid][Gang];
			switch(listitem)
			{
				case 0:
				{
					format(string, sizeof(string), "{FFFFFF}The current rank name for rank %d is {3D6666}%s{FFFFFF}.\nPlease enter what you would like to change it to.", rank + 1, GangRanks[id][rank][RankName]);
					return ShowPlayerDialog(playerid, GCP_RANK_EDIT_NAME, DIALOG_STYLE_INPUT, "Gang Control Panel - Edit Ranks - Rank Name", string, "Enter", "Cancel");
				}
				case 1:
				{
					new permString[PERM_STRING_LENGTH];
					for(new i; i < TOTAL_PERMISSIONS; i++)
					{
						format(permString, sizeof(permString), "%s{3D6666}%s: %s\n", permString, CommandDefaults[i][CommandDesc], (GangRanks[id][rank][RankPermissions][i] == 1) ? ("{33A10B}True") : ("{FF0000}False"));
					}
					ShowPlayerDialog(playerid, GCP_RANK_EDIT_PERMS, DIALOG_STYLE_LIST, "Gang Control Panel - Edit Ranks - Rank Permissions", permString, "Select", "Cancel");
				}
			}
		}
		case GCP_RANK_EDIT_NAME:
		{
			if(!response)
			{
				DeletePVar(playerid, "GCP_RANK_EDIT_ID");
				return 1;
			}
			new rank = GetPVarInt(playerid, "GCP_RANK_EDIT_ID"), id = Player[playerid][Gang];
			if(strlen(inputtext) < 1 || strlen(inputtext) >= MAX_RANK_NAME)
			{
				SendClientMessage(playerid, RED, "The rank name was either to long or to short.");
				format(string, sizeof(string), "{FFFFFF}The current rank name for rank %d is {3D6666}%s{FFFFFF}.\nPlease enter what you would like to change it to.", rank + 1, GangRanks[id][rank][RankName]);
				return ShowPlayerDialog(playerid, GCP_RANK_EDIT_NAME, DIALOG_STYLE_INPUT, "Gang Control Panel - Edit Ranks - Rank Name", string, "Enter", "Cancel");
			}
			
			DeletePVar(playerid, "GCP_RANK_EDIT_ID");
			format(GangRanks[id][rank][RankName], MAX_RANK_NAME, "%s", inputtext);
			format(string, sizeof(string), "You have changed rank %d's name to %s.", rank + 1, inputtext);
			SendClientMessage(playerid, WHITE, string);
			SaveGang(id);
			new rankString[640];
			for(new i; i < MAX_RANKS; i++)
			{
				format(rankString, sizeof(rankString), "%s{3D6666}Rank %d {666666}| {4DB84D}%s\n", rankString, i + 1, GangRanks[id][i][RankName]);
			}
			return ShowPlayerDialog(playerid, GCP_RANK_MAIN, DIALOG_STYLE_LIST, "Gang Control Panel - Edit Ranks", rankString, "Edit", "Exit");
		}
		case GCP_RANK_EDIT_PERMS:
		{
			if(!response)
			{
				DeletePVar(playerid, "GCP_RANK_EDIT_ID");
				return 1;
			}
			new rank = GetPVarInt(playerid, "GCP_RANK_EDIT_ID"), id = Player[playerid][Gang];
			
			if(GangRanks[id][rank][RankPermissions][listitem] == 1)
				GangRanks[id][rank][RankPermissions][listitem] = 0;
			else GangRanks[id][rank][RankPermissions][listitem] = 1;
			SaveGang(id);
			new permString[PERM_STRING_LENGTH];
			for(new i; i < TOTAL_PERMISSIONS; i++)
			{
				format(permString, sizeof(permString), "%s{3D6666}%s: %s\n", permString, CommandDefaults[i][CommandDesc], (GangRanks[id][rank][RankPermissions][i] == 1) ? ("{33A10B}True") : ("{FF0000}False"));
			}
			return ShowPlayerDialog(playerid, GCP_RANK_EDIT_PERMS, DIALOG_STYLE_LIST, "Gang Control Panel - Edit Ranks - Rank Permissions", permString, "Select", "Cancel");
		}
		case GANG_CALL_CAR:
		{
			if(!response)
				return 1;
				
			new sql = strval(CutBeforeLine(inputtext)), idx = GetVIndex(sql);
			if(sql == 0)
				return 1;
				
			new Float:vPos[3];
			GetVehiclePos(Veh[idx][Link], vPos[0], vPos[1], vPos[2]);
			SetPlayerCheckpoint(playerid, vPos[0], vPos[1], vPos[2], 10.0);
			Player[playerid][Checkpoint] = 1;
			Player[playerid][FindingCar] = 1;
			SendClientMessage(playerid, WHITE, "A checkpoint has been set.");
		}
	}
	return 1;
}

// ============= Commands =============

CMD:creategang(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;

	new option[32];
	if(sscanf(params, "s[32]", option)) 
		return SendClientMessage(playerid, WHITE, "SYNTAX: /creategang [Gang Name]");
	
	new id = GetAvailableGangID();

	if(id == -1)
		return SendClientMessage(playerid, WHITE, "No available gang ID's available.");
	
	if(id == 0)
		id ++;
	
	Iter_Add(Gang, id);

	format(Gangs[id][GangName], 128, option);
	Gangs[id][GangType] = GANG_TYPE_DEFAULT;
	
	format(string, sizeof(string), "You have created gang id %d (%s).", id, option);
	SendClientMessage(playerid, WHITE, string);
	
	new query[1024], Cache:cache;
	mysql_format(MYSQL_MAIN, query, sizeof(query), "INSERT INTO Gangs (GangName, GangType) VALUES ('%e', '%d')", Gangs[id][GangName], Gangs[id][GangType]);
	cache = mysql_query(MYSQL_MAIN, query);
	Gangs[id][GangSQL] = cache_insert_id();
	cache_delete(cache);
	
	for(new i; i < MAX_RANKS; i++)
	{
		format(GangRanks[id][i][RankName], MAX_RANK_NAME, "None");
		format(string, sizeof(string), "INSERT INTO GangRanks (GangSQL, Rank, RankName) VALUES(%d, %d, 'None')", Gangs[id][GangSQL], i + 1);
		mysql_query(MYSQL_MAIN, string, false);

		for(new p; p < TOTAL_PERMISSIONS; p++)
		{
			if(i + 1 >= CommandDefaults[p][CommandDefault])
			{
				GangRanks[id][i][RankPermissions][p] = 1;
			}
		}
	}
	SaveGang(id);
	return 1;
}

/*CMD:creategang(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
	
	new option[32];
	if(sscanf(params, "s[32]", option))
	{
		SendClientMessage(playerid, WHITE, "SYNTAX: /creategang [option]");
		return SendClientMessage(playerid, WHITE, "Option: exterior, interior, complete");
	}
	
	new Float:pPos[3], Int = GetPlayerInterior(playerid), vw = GetPlayerVirtualWorld(playerid);
	GetPlayerPos(playerid, pPos[0], pPos[1], pPos[2]);
	
	if(!strcmp(option, "exterior", true))
	{
		SetPVarFloat(playerid, "Gang_Create_ExtX", pPos[0]), SetPVarFloat(playerid, "Gang_Create_ExtY", pPos[1]), SetPVarFloat(playerid, "Gang_Create_ExtZ", pPos[2]);
		SetPVarInt(playerid, "Gang_Create_ExtInterior", Int), SetPVarInt(playerid, "Gang_Create_ExtVW", vw);
		SendClientMessage(playerid, WHITE, "You have set the exterior.");
	}
	else if(!strcmp(option, "interior", true))
	{
		SetPVarFloat(playerid, "Gang_Create_IntX", pPos[0]), SetPVarFloat(playerid, "Gang_Create_IntY", pPos[1]), SetPVarFloat(playerid, "Gang_Create_IntZ", pPos[2]);
		SetPVarInt(playerid, "Gang_Create_IntInterior", Int), SetPVarInt(playerid, "Gang_Create_IntVW", vw);
		SendClientMessage(playerid, WHITE, "You have set the interior.");
	}
	else if(!strcmp(option, "complete", true))
	{
		new id = GetAvailableGangID();
		
		if(id == -1)
			return SendClientMessage(playerid, WHITE, "No available gang ID's available.");
		
		if(id == 0)
			id ++;
		
		Iter_Add(Gang, id);

		Gangs[id][ExtPos][0] = GetPVarFloat(playerid, "Gang_Create_ExtX");
		Gangs[id][ExtPos][1] = GetPVarFloat(playerid, "Gang_Create_ExtY");
		Gangs[id][ExtPos][2] = GetPVarFloat(playerid, "Gang_Create_ExtZ");
		Gangs[id][ExtVW] = GetPVarInt(playerid, "Gang_Create_ExtVW");
		Gangs[id][ExtIntID] = GetPVarInt(playerid, "Gang_Create_ExtInterior");
		
		Gangs[id][IntPos][0] = GetPVarFloat(playerid, "Gang_Create_IntX");
		Gangs[id][IntPos][1] = GetPVarFloat(playerid, "Gang_Create_IntY");
		Gangs[id][IntPos][2] = GetPVarFloat(playerid, "Gang_Create_IntZ");
		Gangs[id][IntVW] = GANG_VW + id;
		Gangs[id][IntID] = GetPVarInt(playerid, "Gang_Create_IntInterior");
		
		format(Gangs[id][GangName], 128, "None");
		Gangs[id][GangType] = GANG_TYPE_DEFAULT;
		
		UpdateGang(id);

		SetPlayerPos(playerid, Gangs[id][ExtPos][0], Gangs[id][ExtPos][1], Gangs[id][ExtPos][2]);
		SetPlayerVirtualWorld(playerid, Gangs[id][ExtVW]);
		SetPlayerInterior(playerid, Gangs[id][ExtIntID]);
		
		format(string, sizeof(string), "You have created gang id %d.", id);
		SendClientMessage(playerid, WHITE, string);
		
		new query[1024], Cache:cache;
		mysql_format(MYSQL_MAIN, query, sizeof(query), "INSERT INTO Gangs (ExtPosX, ExtPosY, ExtPosZ, ExtIntID, ExtVW) VALUES (%f, %f, %f, %d, %d)", Gangs[id][ExtPos][0], Gangs[id][ExtPos][1], Gangs[id][ExtPos][2], Gangs[id][ExtIntID], Gangs[id][ExtVW]);
		cache = mysql_query(MYSQL_MAIN, query);
		Gangs[id][GangSQL] = cache_insert_id();
		cache_delete(cache);
		
		for(new i; i < MAX_RANKS; i++)
		{
			format(GangRanks[id][i][RankName], MAX_RANK_NAME, "None");
			format(string, sizeof(string), "INSERT INTO GangRanks (GangSQL, Rank, RankName) VALUES(%d, %d, 'None')", Gangs[id][GangSQL], i + 1);
			mysql_query(MYSQL_MAIN, string);
			
			for(new p; p < TOTAL_PERMISSIONS; p++)
			{
				if(i + 1 >= CommandDefaults[p][CommandDefault])
				{
					GangRanks[id][i][RankPermissions][p] = 1;
				}
			}
		}
		
		SaveGang(id);
	}	
	else
	{
		SendClientMessage(playerid, WHITE, "SYNTAX: /creategang [option]");
		return SendClientMessage(playerid, WHITE, "Option: exterior, interior, complete");
	}
	return 1;
}

CMD:movegang(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
		
	new id, option[32];
	if(sscanf(params, "ds[32]", id, option))
		return SendClientMessage(playerid, WHITE, "SYNTAX: /movegang [gang ID] [exterior / interior]");
		
	if(!DoesGangExist(id))
		return SendClientMessage(playerid, WHITE, "Invalid gang ID.");
	
	new Float:pPos[3];
	GetPlayerPos(playerid, pPos[0], pPos[1], pPos[2]);
	if(!strcmp(option, "exterior", true))
	{
		Gangs[id][ExtPos][0] = pPos[0];
		Gangs[id][ExtPos][1] = pPos[1];
		Gangs[id][ExtPos][2] = pPos[2];
		Gangs[id][ExtVW] = GetPlayerVirtualWorld(playerid);
		Gangs[id][ExtIntID] = GetPlayerInterior(playerid);
		UpdateGang(id);
		format(string, sizeof(string), "You have moved %s's (%d) exterior.", Gangs[id][GangName], id);
		SendClientMessage(playerid, WHITE, string);
	}
	else if(!strcmp(option, "interior", true))
	{
		Gangs[id][IntPos][0] = pPos[0];
		Gangs[id][IntPos][1] = pPos[1];
		Gangs[id][IntPos][2] = pPos[2];
		Gangs[id][IntID] = GetPlayerInterior(playerid);
		format(string, sizeof(string), "You have moved %s's (%d) interior.", Gangs[id][GangName], id);
		SendClientMessage(playerid, WHITE, string);
	}
	else return SendClientMessage(playerid, WHITE, "SYNTAX: /movegang [gang ID] [exterior / interior]");
	return 1;
}*/

CMD:setganglink(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
	
	new type, id, gid;
	if(sscanf(params, "ddd", gid, type, id))
		return SendClientMessage(playerid, WHITE, "SYNTAX: /setganglink [gang id] [1 - House | 2 - Business] [id]");
	
	if(!DoesGangExist(gid))
		return SendClientMessage(playerid, WHITE, "Invalid gang ID.");
	
	if(type < 1 || type > 2)
		return SendClientMessage(playerid, WHITE, "Valid types are 1 or 2.");
		
	if(type == 1 && id > MAX_HOUSES || type == 2 && id > MAX_BUSINESSES)
		return SendClientMessage(playerid, -1, "Invalid link ID");
	
	Gangs[gid][HQLinkType] = type;
	Gangs[gid][HQLinkID] = id;
	format(string, sizeof(string), "You have set gang %d's HQ to %s %d.", gid, (type == GANG_HQLINK_TYPE_HOUSE) ? ("House") : ("Business"), id);
	SendClientMessage(playerid, WHITE, string);
	format(string, sizeof(string), "%s has set gang %d's HQ to %s %d.", Player[playerid][AdminName], gid, (type == GANG_HQLINK_TYPE_HOUSE) ? ("House") : ("Business"), id);
	AdminActionsLog(string);
	SaveGang(gid);
	return 1;
}

CMD:checkgang(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 2)
		return 1;
		
	new id; 
	if(sscanf(params, "ds[32]", id))
		return SendClientMessage(playerid, WHITE, "SYNTAX: /checkgang [gang ID]");
		
	if(!DoesGangExist(id))
		return SendClientMessage(playerid, WHITE, "Invalid gang ID.");
		
	SendClientMessage(playerid, GREY, "--------------------------------------------------------------------------------------");
	format(string, sizeof(string), "Gang: %s (%d) | Gang Type: %d | HQ Link: %s %d | Total Members: %d", Gangs[id][GangName], id, Gangs[id][GangType], (Gangs[id][HQLinkType] == GANG_HQLINK_TYPE_HOUSE) ? ("House") : ("Business"), Gangs[id][HQLinkID], GetGangMemberCount(id));
	SendClientMessage(playerid, WHITE, string);
	format(string, sizeof(string), "Cash: %s | Pot: %d | Cocaine: %d | Speed: %d", PrettyMoney(Gangs[id][GangSafe][GANGSAFE_CASH]), Gangs[id][GangSafe][GANGSAFE_POT], Gangs[id][GangSafe][GANGSAFE_COCAINE], Gangs[id][GangSafe][GANGSAFE_SPEED]);
	SendClientMessage(playerid, WHITE, string);
	format(string, sizeof(string), "Street Grade Materials: %d | Standard Grade Materials: %d | Military Grade Materials: %d", Gangs[id][GangSafe][GANGSAFE_MATSLOW], Gangs[id][GangSafe][GANGSAFE_MATSMID], Gangs[id][GangSafe][GANGSAFE_MATSHIGH]);
	SendClientMessage(playerid, WHITE, string);
	SendClientMessage(playerid, GREY, "--------------------------------------------------------------------------------------");
	return 1;
}

CMD:gotogang(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 2)
		return 1;
		
	new id;
	if(sscanf(params, "d", id))
		return SendClientMessage(playerid, WHITE, "SYNTAX: /gotogang [gang ID]");
		
	if(!DoesGangExist(id))
		return SendClientMessage(playerid, WHITE, "Invalid gang ID.");
	
	if(Gangs[id][HQLinkID] == 0)
		return SendClientMessage(playerid, WHITE, "This gang is not linked to a house or business.");
	
	if(Gangs[id][HQLinkType] == GANG_HQLINK_TYPE_HOUSE)
	{
		SetPlayerPos_Update(playerid, Houses[Gangs[id][HQLinkID]][hExteriorX], Houses[Gangs[id][HQLinkID]][hExteriorY], Houses[Gangs[id][HQLinkID]][hExteriorZ]);
		SetPlayerVirtualWorld(playerid, Houses[Gangs[id][HQLinkID]][hExteriorVW]);
		SetPlayerInterior(playerid, Houses[Gangs[id][HQLinkID]][hExteriorID]);
	}
	else
	{
		SetPlayerPos_Update(playerid, Businesses[Gangs[id][HQLinkID]][bExteriorX], Businesses[Gangs[id][HQLinkID]][bExteriorY], Businesses[Gangs[id][HQLinkID]][bExteriorZ]);
		SetPlayerVirtualWorld(playerid, 0);
		SetPlayerInterior(playerid, Businesses[Gangs[id][HQLinkID]][bExteriorID]);
	}
	format(string, sizeof(string), "You have teleported to gang %d's headquarters.", id);
	SendClientMessage(playerid, WHITE, string);
	return 1;
}

CMD:gmakeleader(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
		
	new gang, id;
	if(sscanf(params, "ud", id, gang))
		return SendClientMessage(playerid, WHITE, "SYNTAX: /gmakeleader [playerid] [gang ID]");
		
	if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, WHITE, "Invalid player id.");
		
	if(!DoesGangExist(gang))
		return SendClientMessage(playerid, WHITE, "Invalid gang ID.");
		
	Player[id][Gang] = gang;
	Player[id][GangRank] = 10;
	format(string, sizeof(string), "%s has made you the leader of %s. (%d)", Player[playerid][AdminName], Gangs[gang][GangName], gang);
	SendClientMessage(id, WHITE, string);
	format(string, sizeof(string), "You have made %s the leader of %s. (%d)", GetName(id), Gangs[gang][GangName], gang);
	SendClientMessage(playerid, WHITE, string);
	format(string, sizeof(string), "%s has made %s the leader of %s. (%d)", Player[playerid][AdminName], GetName(id), Gangs[gang][GangName], gang);
	StatLog(string);
	return 1;
}

CMD:gangname(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
		
	new id, name[32];
	if(sscanf(params, "ds[32]", id, name))
		return SendClientMessage(playerid, WHITE, "SYNTAX: /gangname [gang id] [name]");
		
	if(!DoesGangExist(id))
		return SendClientMessage(playerid, WHITE, "Invalid gang id.");
		
	if(strlen(name) < 3 || strlen(name) > 32)
		return SendClientMessage(playerid, WHITE, "Gang names must be between 3 and 32 characters.");
		
	if(strfind(name, "{", true) != -1)
		return SendClientMessage(playerid, WHITE, "Color codes cannot be used in the gang name.");
	
	format(string, sizeof(string), "You have changed gang %s's (%d) name to %s.", Gangs[id][GangName], id, name);
	SendClientMessage(playerid, WHITE, string);
	format(string, sizeof(string), "%s has changed gang ID %d's name to %s. (was %s)", Player[playerid][AdminName], id, name, Gangs[id][GangName]);
	AdminActionsLog(string);
	format(Gangs[id][GangName], 128, "%s", name);
	UpdateGang(id);
	UpdateGangSafe(id);
	SaveGang(id);
	return 1;
}

CMD:gangtype(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
		
	new id, type;
	if(sscanf(params, "dd", id, type))
	{
		SendClientMessage(playerid, WHITE, "SYNTAX: /gangtype [gang id] [type]");
		return SendClientMessage(playerid, WHITE, "Types: 0 - None | 1 - Default");
	}
	
	if(!DoesGangExist(id))
		return SendClientMessage(playerid, WHITE, "Invalid gang id.");
		
	
	format(string, sizeof(string), "You have changed gang %s's (%d) type to %d.", Gangs[id][GangName], id, type);
	SendClientMessage(playerid, WHITE, string);
	format(string, sizeof(string), "%s has changed gang %s's (%d) type to %d.", Player[playerid][AdminName], Gangs[id][GangName], id, type);
	AdminActionsLog(string);
	Gangs[id][GangType] = type;
	SaveGang(id);
	return 1;
}

CMD:listgangs(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 2)
		return 1;
		
	mysql_tquery(MYSQL_MAIN, "SELECT Gang, count(*) as MemberCount FROM playeraccounts WHERE Gang > 0 GROUP BY Gang", "OnGangListQueyFinish", "d", playerid);
	return 1;
}

forward OnGangListQueyFinish(playerid);
public OnGangListQueyFinish(playerid)
{
	SendClientMessage(playerid, WHITE, "---------------------------------------------------------");
	new rows = cache_get_row_count();
	new GangMembers[MAX_GANGS];
	for(new i; i < rows; i++)
	{
		new sql = cache_get_field_content_int(i, "Gang");
		if(sql == i)
			GangMembers[sql] = cache_get_field_content_int(i, "MemberCount");		
	}
	
	foreach(new g : Gang)
	{
		format(string, sizeof(string), "%d | %s | Type: %d | Members: %d", g, Gangs[g][GangName], Gangs[g][GangType], GangMembers[g]);
		SendClientMessage(playerid, GREY, string);
	}
	SendClientMessage(playerid, WHITE, "---------------------------------------------------------");
	return 1;
}

CMD:listgang(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 2)
		return 1;
	
	new id;
	if(sscanf(params, "d", id))
		return SendClientMessage(playerid, WHITE, "SYNTAX: /listgang [gang ID]");
		
	if(!DoesGangExist(id))
		return SendClientMessage(playerid, WHITE, "Invalid gang id.");
		
	DisplayGangMembers(playerid, id, 1);
	return 1;
}

CMD:respawngangcars(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 4)
		return 1;
		
	new id;
	if(sscanf(params, "d", id))
		return SendClientMessage(playerid, WHITE, "SYNTAX: /respawngangcars [gang ID]");
		
	if(!DoesGangExist(id))
		return SendClientMessage(playerid, WHITE, "Invalid gang id.");
	
	for(new i; i < MAX_VEHICLES; i++)
	{

		if(Veh[i][GangLink] == id && IsSQLVehicleSpawned(Veh[i][SQLID]) && IsVehicleEmpty(Veh[i][Link]) == 0)
		{
			DespawnVehicleSQL(Veh[i][SQLID]);
			SpawnVehicleSQL(Veh[i][SQLID]);
		}
	}
	SendClientMessage(playerid, -1, "All unoccupied Gang vehicles respawned");
	return 1;
}

CMD:ginvite(playerid, params[])
{
	if(Gangs[Player[playerid][Gang]][GangType] == GANG_TYPE_NONE)
		return 1;
	
	if(!DoesPlayerHavePerms(playerid, PERM_GINVITE))
		return SendClientMessage(playerid, RED, "Permission denied.");
	
	new id;
	if(sscanf(params, "u", id))
		return SendClientMessage(playerid, WHITE, "SYNTAX: /ginvite [playerid]");
	
	if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, WHITE, "Invalid player id.");
	
	SetPVarInt(id, "Pending_GangInvite", Player[playerid][Gang]);
	SetPVarInt(id, "Pending_GangInvite_Player", playerid);
	
	format(string, sizeof(string), "%s has invited you to join %s. Type \'/ganginvite\' to respond.", GetName(playerid), Gangs[Player[playerid][Gang]][GangName]);
	SendClientMessage(id, WHITE, string);
	format(string, sizeof(string), "You have invited %s to join your gang. Please wait for them to respond to the invite.", GetName(id));
	SendClientMessage(playerid, WHITE, string);
	return 1;
}

CMD:guninvite(playerid, params[])
{
	if(Gangs[Player[playerid][Gang]][GangType] == GANG_TYPE_NONE)
		return 1;
	
	if(!DoesPlayerHavePerms(playerid, PERM_GUNINVITE))
		return SendClientMessage(playerid, RED, "Permission denied.");
		
	new id;
	if(sscanf(params, "u", id))
		return SendClientMessage(playerid, WHITE, "SYNTAX: /guninvite [playerid]");
		
	if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, WHITE, "That player isn't connected.");
	
	if(Player[id][Gang] != Player[playerid][Gang])
		return SendClientMessage(playerid, WHITE, "That player isn't in your gang.");
	
	if(Player[id][GangRank] > Player[playerid][GangRank])
		return SendClientMessage(playerid, WHITE, "You can't uninvite a higher ranked member.");
	
	format(string, sizeof(string), "%s has left the gang. (uninvited by %s)", GetName(id), GetName(playerid));
	SendToGang(Player[playerid][Gang], ANNOUNCEMENT, string);
	format(string, sizeof(string), "You have been uninvited from %s by %s.", Gangs[Player[playerid][Gang]][GangName], GetName(playerid));
	SendClientMessage(id, WHITE, string);
	format(string, sizeof(string), "You have uninvited %s from %s.", GetName(id), Gangs[Player[playerid][Gang]][GangName]);
	SendClientMessage(playerid, WHITE, string);
	format(string, sizeof(string), "[GANGS] %s (%d) has uninvited %s from %s. (%d)", GetName(playerid), Player[playerid][GangRank], GetName(id), Gangs[Player[playerid][Gang]][GangName], Player[playerid][Gang]);
	StatLog(string);
	
	Player[id][Gang] = 0;
	Player[id][GangRank] = 0;
	return 1;
}

CMD:ganginvite(playerid, params[])
{
	if(Player[playerid][Gang] > 0)
		return SendClientMessage(playerid, WHITE, "You are already apart of a gang.");
	
	new id = GetPVarInt(playerid, "Pending_GangInvite");
	if(id < 1)
		return SendClientMessage(playerid, WHITE, "You don't have a pending gang invite.");
		
	new response[7];
	if(sscanf(params, "s[7]", response))
		return SendClientMessage(playerid, WHITE, "SYNTAX: /ganginvite [accept / deny]");
	new pid = GetPVarInt(playerid, "Pending_GangInvite_Player");
	if(!strcmp(response, "accept", true))
	{
		Player[playerid][Gang] = id;
		Player[playerid][GangRank] = 1;
		DeletePVar(playerid, "Pending_GangInvite");
		DeletePVar(playerid, "Pending_GangInvite_Player");
		
		
		format(string, sizeof(string), "%s has accepted an invitation to gang %s. (%d) (Invited by %s)", GetName(playerid), Gangs[id][GangName], id, GetName(pid));
		StatLog(string);
		format(string, sizeof(string), "%s has accepted your gang invite.", GetName(playerid));
		SendClientMessage(pid, WHITE, string);
		format(string, sizeof(string), "%s has joined your gang. (Invited by %s)", GetName(playerid), GetName(pid));
		SendToGang(id, ANNOUNCEMENT, string);
		format(string, sizeof(string), "You have joined %s.", Gangs[id][GangName]);
		SendClientMessage(playerid, WHITE, string);
	}
	else if(!strcmp(response, "deny", true))
	{
		DeletePVar(playerid, "Pending_GangInvite");
		DeletePVar(playerid, "Pending_GangInvite_Player");
		
		format(string, sizeof(string), "You have denied %s's invitation to join %s.", GetName(pid), Gangs[id][GangName]);
		SendClientMessage(playerid, WHITE, string);
		format(string, sizeof(string), "%s has denied your invitation.", GetName(playerid));
		SendClientMessage(pid, WHITE, string);
	}
	else return SendClientMessage(playerid, WHITE, "SYNTAX: /ganginvite [accept / deny]");
	return 1;
}

CMD:quitgang(playerid, params[])
{
	if(Player[playerid][Gang] == 0)
		return SendClientMessage(playerid, WHITE, "You aren't in a gang.");
		
	if(isnull(params) || strcmp(params, "confirm", true))
		return SendClientMessage(playerid, WHITE, "Are you sure you want to quit your gang? Type \'/quitgang confirm\' if you are sure.");
		
	format(string, sizeof(string), "%s has left the gang. (quit)", GetName(playerid));
	SendToGang(Player[playerid][Gang], ANNOUNCEMENT, string);
	format(string, sizeof(string), "You have left %s.", Gangs[Player[playerid][Gang]][GangName]);
	SendClientMessage(playerid, WHITE, string);
	format(string, sizeof(string), "[GANGS] %s has left %s. (%d)", GetName(playerid), Gangs[Player[playerid][Gang]][GangName], Player[playerid][Gang]);
	StatLog(string);
	
	Player[playerid][Gang] = 0;
	Player[playerid][GangRank] = 0;
	SavePlayerData(playerid);
	
	return 1;
}

CMD:togglegangchat(playerid, params[])
{
	if(Gangs[Player[playerid][Gang]][GangType] == GANG_TYPE_NONE)
		return 1;
	
	if(!DoesPlayerHavePerms(playerid, PERM_TOGGLEGANGCHAT))
		return SendClientMessage(playerid, RED, "Permission denied.");
	
	if(Gangs[Player[playerid][Gang]][GangType] == GANG_TYPE_NONE)
		return 1;
	
	new id = Player[playerid][Gang];
	switch(Gangs[id][GangChatDisabled])
	{
		case 0:
		{
			Gangs[id][GangChatDisabled] = 1;
			SendClientMessage(playerid, WHITE, "You have disabled your gang chat.");
			SendToGang(id, ANNOUNCEMENT, "The gang chat has been disabled.");
		}
		case 1:
		{
			Gangs[id][GangChatDisabled] = 0;
			SendClientMessage(playerid, WHITE, "You have enabled your gang chat.");
			SendToGang(id, ANNOUNCEMENT, "The gang chat has been enabled.");
		}
	}
	return 1;
}

CMD:g(playerid, params[]){
	if(GetPVarInt(playerid, "ShortCMDS") == 0)
		return cmd_gang(playerid, params);
	return SendClientMessage(playerid, -1, "ShortCMDS are disabled, you must use /gang");
}

CMD:gang(playerid, params[])
{	
	if(Player[playerid][Group] > 0 && Player[playerid][Gang] == 0)
		return SendClientMessage(playerid, WHITE, "This command is only for gangs. Use /(f)action instead.");
	
	if(!DoesPlayerHavePerms(playerid, PERM_GANGCHAT))
		return SendClientMessage(playerid, RED, "Permission denied.");
		
	if(Gangs[Player[playerid][Gang]][GangType] == GANG_TYPE_NONE)
		return 1;
	
	if(Gangs[Player[playerid][Gang]][GangChatDisabled] == 1)
		return SendClientMessage(playerid, WHITE, "The gang chat is disabled.");
	
	new message[128];
	if(sscanf(params, "s[128]", message))
		return SendClientMessage(playerid, WHITE, "SYNTAX: /gang [message]");
	
	new name[MAX_PLAYER_NAME];
	if(Player[playerid][AdminDuty] > 0)
		format(name, sizeof(name), "%s", GetName(playerid));
	else
		format(name, sizeof(name), "%s", Player[playerid][NormalName]);
		
	format(string, sizeof(string), "[G] %s (%d) {BDF38B}%s{E7FFD1}: %s", GetPlayersGangRankName(playerid), Player[playerid][GangRank], name, message);
	SendToGang(Player[playerid][Gang], GROUP_CHAT, string);
	format(string, sizeof(string), "[Gang] [%d] (%d) %s: %s", Player[playerid][Gang], Player[playerid][GangRank], name, message);
	GroupChatLog(string);
	return 1;
}

CMD:lockganghq(playerid, params[])
{
	if(Gangs[Player[playerid][Gang]][GangType] == GANG_TYPE_NONE)
		return 1;
	
	if(!DoesPlayerHavePerms(playerid, PERM_LOCKGANGHQ))
		return SendClientMessage(playerid, RED, "Permission denied.");
		
	new id = Player[playerid][Gang];
	
	if(Gangs[id][HQLinkType] == 0)
		return SendClientMessage(playerid, WHITE, "Your gang doesn't have a HQ.");
		
	new link = Gangs[id][HQLinkID], type = Gangs[id][HQLinkType];
	
	switch(type)
	{
		case GANG_HQLINK_TYPE_HOUSE:
		{
			if(!IsPlayerInRangeOfPoint(playerid, 5, Houses[link][hInteriorX], Houses[link][hInteriorY], Houses[link][hInteriorZ]) && !IsPlayerInRangeOfPoint(playerid, 5, Houses[link][hExteriorX], Houses[link][hExteriorY], Houses[link][hExteriorZ]))
				return SendClientMessage(playerid, WHITE, "You are not near the door!");
			
			switch(Houses[link][LockStatus])
			{
				case 0:
				{
					Houses[link][LockStatus] = 1;
					format(string, sizeof(string), "%s takes their keys from their pocket and locks the house.", GetNameEx(playerid));
					return NearByMessage(playerid, NICESKY, string);
				}
				default:
				{
					Houses[link][LockStatus] = 0;
					format(string, sizeof(string), "%s takes their keys from their pocket and unlocks the house.", GetNameEx(playerid));
					return NearByMessage(playerid, NICESKY, string);
				}
			}
		}
		case GANG_HQLINK_TYPE_BIZ:
		{
			if(!IsPlayerInRangeOfPoint(playerid, 5.0, Businesses[link][bExteriorX], Businesses[link][bExteriorY], Businesses[link][bExteriorZ]) && !IsPlayerInRangeOfPoint(playerid, 5.0, Businesses[link][bInteriorX], Businesses[link][bInteriorY], Businesses[link][bInteriorZ]))
				return SendClientMessage(playerid, WHITE, "You are not near the door!");
			
			if(Businesses[link][bLockStatus] == 1)
			{
				Businesses[link][bLockStatus] = 0;
				format(string, sizeof(string), "* %s uses their key to unlock the business.", GetNameEx(playerid));
				NearByMessage(playerid, NICESKY, string);
			}
			else
			{
				Businesses[link][bLockStatus] = 1;
				format(string, sizeof(string), "* %s uses their key to lock the business.", GetNameEx(playerid));
				NearByMessage(playerid, NICESKY, string);
			}
		}
		default: return SendClientMessage(playerid, WHITE, "Invalid HQ link type.");
	}
	
	/*if(!IsPlayerInRangeOfPoint(playerid, 5, Gangs[id][ExtPos][0], Gangs[id][ExtPos][1], Gangs[id][ExtPos][2]) && !IsPlayerInRangeOfPoint(playerid, 5, Gangs[id][IntPos][0], Gangs[id][IntPos][1], Gangs[id][IntPos][2]))
		return SendClientMessage(playerid, WHITE, "You must be at the door to use this command.");
		
	switch(Gangs[id][HQLockStatus])
	{
		case 0:
		{
			Gangs[id][HQLockStatus] = 1;
			format(string, sizeof(string), "* %s uses their keys to lock the doors of the building.", GetNameEx(playerid));
			NearByMessage(playerid, NICESKY, string); 
			SendClientMessage(playerid, WHITE, "You have locked your HQ.");
		}
		case 1:
		{
			Gangs[id][HQLockStatus] = 0;
			format(string, sizeof(string), "* %s uses their keys to unlock the doors of the building.", GetNameEx(playerid));
			NearByMessage(playerid, NICESKY, string); 
			SendClientMessage(playerid, WHITE, "You have locked your HQ.");
		}
	}*/
	return 1;
}

/*
CMD:gradio(playerid, params[])
{
	if(Gangs[Player[playerid][Gang]][GangType] == GANG_TYPE_NONE)
		return 1;
	
	if(!DoesPlayerHavePerms(playerid, PERM_GRADIO))
		return SendClientMessage(playerid, RED, "Permission denied.");
	
	if(Player[playerid][InGangHQ] != Player[playerid][Gang])
		return SendClientMessage(playerid, WHITE, "You must be inside your Gang HQ to use this command.");
	
	if(isnull(params))
	{
		SendClientMessage(playerid, WHITE, "SYNTAX: /gradio [option]");
		return SendClientMessage(playerid, WHITE, "Options: toggle, station, tune");
	}
	new id = Player[playerid][Gang];
	if(!strcmp(params, "toggle", true))
	{
		switch(Gangs[id][GangHQRadio])
		{
			case 0:
			{
				format(string, sizeof(string), "* %s has turned on the radio.", GetNameEx(playerid));
				NearByMessage(playerid, NICESKY, string);
				Gangs[id][GangHQRadio] = 1;
			}
			default:
			{
				format(string, sizeof(string), "* %s has turned off the radio.", GetNameEx(playerid));
				NearByMessage(playerid, NICESKY, string);
				Gangs[id][GangHQRadio] = 0;
				
				foreach(Player, i)
				{
					if(Player[i][InGangHQ] == id)
						StopAudioStreamForPlayer(i);
				}
			}
		}
		
	}
	else if(!strcmp(params, "station", true))
	{
		new radioString[255];
		if(Gangs[id][GangHQRadio] == 0)
			return SendClientMessage(playerid, WHITE, "The radio is turned off!");
			
		for(new i; i < MAX_RADIO_STATIONS; i++)
		{
			if(RadioSettings[i][Available] > 0)
			{
				format(radioString, sizeof(radioString), "%s%s\n", radioString, RadioSettings[i][StationName]);
			}
		}
		ShowPlayerDialog(playerid, GANG_HQ_RADIO, DIALOG_STYLE_LIST, "Gang Radio", radioString, "Select", "Exit");
	}
	else if(!strcmp(params, "tune", true))
	{
		if(Gangs[id][GangHQRadio] == 0)
			return SendClientMessage(playerid, WHITE, "The radio is turned off!");

		if(Player[playerid][VipRank] < 1)
			return SendClientMessage(playerid, -1, "Tuning your gang radio is a VIP perk!");
			
		ShowPlayerDialog(playerid, B_RADIO_TUNE, DIALOG_STYLE_INPUT, "Gang Radio Station", "Enter the URL for the radio stream.", "Select", "Close");
	}
	else 
	{
		SendClientMessage(playerid, WHITE, "SYNTAX: /gradio [option]");
		return SendClientMessage(playerid, WHITE, "Options: toggle, station, tune");
	}
	return 1;
}
*/

CMD:gangsafelocation(playerid, params[])
{
	if(Gangs[Player[playerid][Gang]][GangType] == GANG_TYPE_NONE)
		return 1;
	
	if(!DoesPlayerHavePerms(playerid, PERM_GANGSAFELOC))
		return SendClientMessage(playerid, RED, "Permission denied.");
	
	new Float:pPos[3], vw = GetPlayerVirtualWorld(playerid), Int = GetPlayerInterior(playerid), id = Player[playerid][Gang];
	
	if(vw == 0)
		return SendClientMessage(playerid, WHITE, "You can't place your safe outside.");
	
	GetPlayerPos(playerid, pPos[0], pPos[1], pPos[2]);
	Gangs[id][GangSafePos][0] = pPos[0];
	Gangs[id][GangSafePos][1] = pPos[1];
	Gangs[id][GangSafePos][2] = pPos[2];
	Gangs[id][GangSafeInt] = Int;
	Gangs[id][GangSafeVW] = vw;
	UpdateGangSafe(id);
	SaveGang(id);
	SendClientMessage(playerid, WHITE, "You have moved your gang safe.");
	return 1;
}

CMD:gangsafebalance(playerid, params[])
{
	if(Gangs[Player[playerid][Gang]][GangType] == GANG_TYPE_NONE)
		return 1;
	
	if(!DoesPlayerHavePerms(playerid, PERM_GANGSAFEBALANCE))
		return SendClientMessage(playerid, RED, "Permission denied.");

	new id = Player[playerid][Gang];
	
	if(!IsPlayerInRangeOfPoint(playerid, 5, Gangs[id][GangSafePos][0], Gangs[id][GangSafePos][1], Gangs[id][GangSafePos][2]) || GetPlayerVirtualWorld(playerid) != Gangs[id][GangSafeVW] || GetPlayerInterior(playerid) != Gangs[id][GangSafeInt])
		return SendClientMessage(playerid, WHITE, "You aren't at your gang safe location!");
	
	SendClientMessage(playerid, WHITE, "---------------------------------------------");
	format(string, sizeof(string), "%s's Safe Balance", Gangs[id][GangName]);
	SendClientMessage(playerid, GREY, string);
	format(string, sizeof(string), "Money: %s | Pot: %d | Cocaine: %d | Speed: %d", PrettyMoney(Gangs[id][GangSafe][GANGSAFE_CASH]), Gangs[id][GangSafe][GANGSAFE_POT], Gangs[id][GangSafe][GANGSAFE_COCAINE], Gangs[id][GangSafe][GANGSAFE_SPEED]);
	SendClientMessage(playerid, GREY, string);
	format(string, sizeof(string), " Street Grade Mats: %d | Standard Grade Mats: %d | Military Grade Mats: %d", Gangs[id][GangSafe][GANGSAFE_MATSLOW], Gangs[id][GangSafe][GANGSAFE_MATSMID], Gangs[id][GangSafe][GANGSAFE_MATSHIGH]);
	SendClientMessage(playerid, GREY, string);
	SendClientMessage(playerid, WHITE, "---------------------------------------------");
	return 1;
}

CMD:gangsafedeposit(playerid, params[])
{
	if(Gangs[Player[playerid][Gang]][GangType] == GANG_TYPE_NONE)
		return 1;
	
	if(!DoesPlayerHavePerms(playerid, PERM_GANGSAFEDEPOSIT))
		return SendClientMessage(playerid, RED, "Permission denied.");
	
	new amount, option[32];
	if(sscanf(params, "s[32]d", option, amount))
	{
		SendClientMessage(playerid, WHITE, "SYNTAX: /gangsafedeposit [option] [amount]");
		return SendClientMessage(playerid, WHITE, "Options: Money, streetmats, standardmats, militarymats, Pot, Cocaine, Speed");
	}
	
	if(amount < 1)
		return SendClientMessage(playerid, WHITE, "Invalid amount.");
	
	new id = Player[playerid][Gang];
	
	if(!IsPlayerInRangeOfPoint(playerid, 5, Gangs[id][GangSafePos][0], Gangs[id][GangSafePos][1], Gangs[id][GangSafePos][2]) || GetPlayerVirtualWorld(playerid) != Gangs[id][GangSafeVW] || GetPlayerInterior(playerid) != Gangs[id][GangSafeInt])
		return SendClientMessage(playerid, WHITE, "You aren't at your gang safe location!");
	
	if(!strcmp(option, "money", true))
	{
		if(Player[playerid][Money] < amount)
			return SendClientMessage(playerid, WHITE, "You don't have that much on you.");
			
		format(string, sizeof(string), "%s has deposited %s into their gang safe. (Old Balance: %s | New Balance: %s) (Gang: %d)", GetName(playerid), PrettyMoney(amount), PrettyMoney(Gangs[id][GangSafe][GANGSAFE_CASH]), PrettyMoney(Gangs[id][GangSafe][GANGSAFE_CASH] + amount), id);
		MoneyLog(string);
		format(string, sizeof(string), "You have deposited %s into your gang safe.", PrettyMoney(amount));
		SendClientMessage(playerid, WHITE, string);
		Gangs[id][GangSafe][GANGSAFE_CASH] += amount;
		Player[playerid][Money] -= amount;
		SaveGang(id);
	}
	else if(!strcmp(option, "streetmats", true))
	{
		if(Player[playerid][Materials][0] < amount)
			return SendClientMessage(playerid, WHITE, "You don't have that much on you.");
			
		format(string, sizeof(string), "%s has deposited %d street grade mats into their gang safe. (Old Balance: %d | New Balance: %d) (Gang: %d)", GetName(playerid), amount, Gangs[id][GangSafe][GANGSAFE_MATSLOW], Gangs[id][GangSafe][GANGSAFE_MATSLOW] + amount, id);
		StatLog(string);
		format(string, sizeof(string), "You have deposited %d street grade mats into your gang safe.", amount);
		SendClientMessage(playerid, WHITE, string);
		Gangs[id][GangSafe][GANGSAFE_MATSLOW] += amount;
		Player[playerid][Materials][0] -= amount;
		SaveGang(id);
		SavePlayerData(playerid);
	}
	else if(!strcmp(option, "standardmats", true))
	{
		if(Player[playerid][Materials][1] < amount)
			return SendClientMessage(playerid, WHITE, "You don't have that much on you.");
			
		format(string, sizeof(string), "%s has deposited %d standard grade mats into their gang safe. (Old Balance: %d | New Balance: %d) (Gang: %d)", GetName(playerid), amount, Gangs[id][GangSafe][GANGSAFE_MATSMID], Gangs[id][GangSafe][GANGSAFE_MATSMID] + amount, id);
		StatLog(string);
		format(string, sizeof(string), "You have deposited %d standard grade mats into your gang safe.", amount);
		SendClientMessage(playerid, WHITE, string);
		Gangs[id][GangSafe][GANGSAFE_MATSMID] += amount;
		Player[playerid][Materials][1] -= amount;
		SaveGang(id);
		SavePlayerData(playerid);
	}
	else if(!strcmp(option, "militarymats", true))
	{
		if(Player[playerid][Materials][2] < amount)
			return SendClientMessage(playerid, WHITE, "You don't have that much on you.");
			
		format(string, sizeof(string), "%s has deposited %d military grade mats into their gang safe. (Old Balance: %d | New Balance: %d) (Gang: %d)", GetName(playerid), amount, Gangs[id][GangSafe][GANGSAFE_MATSHIGH], Gangs[id][GangSafe][GANGSAFE_MATSHIGH] + amount, id);
		StatLog(string);
		format(string, sizeof(string), "You have deposited %d military grade mats into your gang safe.", amount);
		SendClientMessage(playerid, WHITE, string);
		Gangs[id][GangSafe][GANGSAFE_MATSHIGH] += amount;
		Player[playerid][Materials][2] -= amount;
		SaveGang(id);
		SavePlayerData(playerid);
	}
	else if(!strcmp(option, "pot", true))
	{
		if(Player[playerid][Pot] < amount)
			return SendClientMessage(playerid, WHITE, "You don't have that much on you.");
			
		format(string, sizeof(string), "%s has deposited %d grams of pot into their gang safe. (Old Balance: %d | New Balance: %d) (Gang: %d)", GetName(playerid), amount, Gangs[id][GangSafe][GANGSAFE_POT], Gangs[id][GangSafe][GANGSAFE_POT] + amount, id);
		StatLog(string);
		format(string, sizeof(string), "You have deposited %d grams of pot into your gang safe.", amount);
		SendClientMessage(playerid, WHITE, string);
		Gangs[id][GangSafe][GANGSAFE_POT] += amount;
		Player[playerid][Pot] -= amount;
		SaveGang(id);
	}
	else if(!strcmp(option, "cocaine", true))
	{
		if(Player[playerid][Cocaine] < amount)
			return SendClientMessage(playerid, WHITE, "You don't have that much on you.");
			
		format(string, sizeof(string), "%s has deposited %d grams of cocaine into their gang safe. (Old Balance: %d | New Balance: %d) (Gang: %d)", GetName(playerid), amount, Gangs[id][GangSafe][GANGSAFE_COCAINE], Gangs[id][GangSafe][GANGSAFE_COCAINE] + amount, id);
		StatLog(string);
		format(string, sizeof(string), "You have deposited %d grams of cocaine into your gang safe.", amount);
		SendClientMessage(playerid, WHITE, string);
		Gangs[id][GangSafe][GANGSAFE_COCAINE] += amount;
		Player[playerid][Cocaine] -= amount;
		SaveGang(id);
	}
	else if(!strcmp(option, "speed", true))
	{
		if(Player[playerid][Speed] < amount)
			return SendClientMessage(playerid, WHITE, "You don't have that much on you.");
			
		format(string, sizeof(string), "%s has deposited %d grams of speed into their gang safe. (Old Balance: %d | New Balance: %d) (Gang: %d)", GetName(playerid), amount, Gangs[id][GangSafe][GANGSAFE_SPEED], Gangs[id][GangSafe][GANGSAFE_SPEED] + amount, id);
		StatLog(string);
		format(string, sizeof(string), "You have deposited %d grams of speed into your gang safe.", amount);
		SendClientMessage(playerid, WHITE, string);
		Gangs[id][GangSafe][GANGSAFE_SPEED] += amount;
		Player[playerid][Speed] -= amount;
		SaveGang(id);
	}
	else
	{
		SendClientMessage(playerid, WHITE, "SYNTAX: /gangsafedeposit [option] [amount]");
		return SendClientMessage(playerid, WHITE, "Options: Money, streetmats, standardmats, militarymats, Pot, Cocaine, Speed");
	}
	return 1;
}

CMD:gangsafewithdraw(playerid, params[])
{
	if(Gangs[Player[playerid][Gang]][GangType] == GANG_TYPE_NONE)
		return 1;
	
	if(!DoesPlayerHavePerms(playerid, PERM_GANGSAFEWITHDRAW))
		return SendClientMessage(playerid, RED, "Permission denied.");
	
	new amount, option[32];
	if(sscanf(params, "s[32]d", option, amount))
	{
		SendClientMessage(playerid, WHITE, "SYNTAX: /gangsafewithdraw [option] [amount]");
		return SendClientMessage(playerid, WHITE, "Options: Money, streetmats, standardmats, militarymats, Pot, Cocaine, Speed");
	}
	
	if(amount < 1)
		return SendClientMessage(playerid, WHITE, "Invalid amount.");
	
	new id = Player[playerid][Gang];
	
	if(!IsPlayerInRangeOfPoint(playerid, 5, Gangs[id][GangSafePos][0], Gangs[id][GangSafePos][1], Gangs[id][GangSafePos][2]) || GetPlayerVirtualWorld(playerid) != Gangs[id][GangSafeVW] || GetPlayerInterior(playerid) != Gangs[id][GangSafeInt])
		return SendClientMessage(playerid, WHITE, "You aren't at your gang safe location!");
	
	if(!strcmp(option, "money", true))
	{
		if(Gangs[id][GangSafe][GANGSAFE_CASH] < amount)
			return SendClientMessage(playerid, WHITE, "The gang safe doesn't not have that much money!");
			
		format(string, sizeof(string), "%s has withdrawn %s from their gang safe. (Old balance: %s | New Balance: %s) (Gang: %d)", GetName(playerid), PrettyMoney(amount), PrettyMoney(Gangs[id][GangSafe][GANGSAFE_CASH]), PrettyMoney(Gangs[id][GangSafe][GANGSAFE_CASH] - amount), id);
		MoneyLog(string);
		format(string, sizeof(string), "You have withdrawn %s from your gang safe.", PrettyMoney(amount));
		SendClientMessage(playerid, WHITE, string);
		Gangs[id][GangSafe][GANGSAFE_CASH] -= amount;
		Player[playerid][Money] += amount;
		SaveGang(id);
	}
	else if(!strcmp(option, "streetmats", true))
	{
		if(Gangs[id][GangSafe][GANGSAFE_MATSLOW] < amount)
			return SendClientMessage(playerid, WHITE, "The gang safe doesn't not have that many street grade materials!");
			
		format(string, sizeof(string), "%s has withdrawn %d street grade mats from their gang safe. (Old balance: %d | New Balance: %d) (Gang: %d)", GetName(playerid), amount, Gangs[id][GangSafe][GANGSAFE_MATSLOW], Gangs[id][GangSafe][GANGSAFE_MATSLOW] - amount, id);
		StatLog(string);
		format(string, sizeof(string), "You have withdrawn %d street grade mats from your gang safe.", amount);
		SendClientMessage(playerid, WHITE, string);
		Gangs[id][GangSafe][GANGSAFE_MATSLOW] -= amount;
		Player[playerid][Materials][0] += amount;
		SaveGang(id);
		SavePlayerData(playerid);
	}
	else if(!strcmp(option, "standardmats", true))
	{
		if(Gangs[id][GangSafe][GANGSAFE_MATSMID] < amount)
			return SendClientMessage(playerid, WHITE, "The gang safe doesn't not have that many standard grade materials!");
			
		format(string, sizeof(string), "%s has withdrawn %d standard grade mats from their gang safe. (Old balance: %d | New Balance: %d) (Gang: %d)", GetName(playerid), amount, Gangs[id][GangSafe][GANGSAFE_MATSMID], Gangs[id][GangSafe][GANGSAFE_MATSMID] - amount, id);
		StatLog(string);
		format(string, sizeof(string), "You have withdrawn %d standard grade mats from your gang safe.", amount);
		SendClientMessage(playerid, WHITE, string);
		Gangs[id][GangSafe][GANGSAFE_MATSMID] -= amount;
		Player[playerid][Materials][1] += amount;
		SaveGang(id);
		SavePlayerData(playerid);
	}
	else if(!strcmp(option, "militarymats", true))
	{
		if(Gangs[id][GangSafe][GANGSAFE_MATSHIGH] < amount)
			return SendClientMessage(playerid, WHITE, "The gang safe doesn't not have that many military grade materials!");
			
		format(string, sizeof(string), "%s has withdrawn %d military grade mats from their gang safe. (Old balance: %d | New Balance: %d) (Gang: %d)", GetName(playerid), amount, Gangs[id][GangSafe][GANGSAFE_MATSHIGH], Gangs[id][GangSafe][GANGSAFE_MATSHIGH] - amount, id);
		StatLog(string);
		format(string, sizeof(string), "You have withdrawn %d military grade mats from your gang safe.", amount);
		SendClientMessage(playerid, WHITE, string);
		Gangs[id][GangSafe][GANGSAFE_MATSHIGH] -= amount;
		Player[playerid][Materials][2] += amount;
		SaveGang(id);
		SavePlayerData(playerid);
	}
	else if(!strcmp(option, "pot", true))
	{
		if(Gangs[id][GangSafe][GANGSAFE_POT] < amount)
			return SendClientMessage(playerid, WHITE, "The gang safe doesn't not have that much pot!");
			
		format(string, sizeof(string), "%s has withdrawn %d grams of pot from their gang safe. (Old balance: %d | New Balance: %d) (Gang: %d)", GetName(playerid), amount, Gangs[id][GangSafe][GANGSAFE_POT], Gangs[id][GangSafe][GANGSAFE_POT] - amount, id);
		StatLog(string);
		format(string, sizeof(string), "You have withdrawn %d grams of pot from your gang safe.", amount);
		SendClientMessage(playerid, WHITE, string);
		Gangs[id][GangSafe][GANGSAFE_POT] -= amount;
		Player[playerid][Pot] += amount;
		SaveGang(id);
	}
	else if(!strcmp(option, "cocaine", true))
	{
		if(Gangs[id][GangSafe][GANGSAFE_COCAINE] < amount)
			return SendClientMessage(playerid, WHITE, "The gang safe doesn't not have that much cocaine!");
			
		format(string, sizeof(string), "%s has withdrawn %d grams of cocaine from their gang safe. (Old balance: %d | New Balance: %d) (Gang: %d)", GetName(playerid), amount, Gangs[id][GangSafe][GANGSAFE_COCAINE], Gangs[id][GangSafe][GANGSAFE_COCAINE] - amount, id);
		StatLog(string);
		format(string, sizeof(string), "You have withdrawn %d grams of cocaine from your gang safe.", amount);
		SendClientMessage(playerid, WHITE, string);
		Gangs[id][GangSafe][GANGSAFE_COCAINE] -= amount;
		Player[playerid][Cocaine] += amount;
		SaveGang(id);
	}
	else if(!strcmp(option, "speed", true))
	{
		if(Gangs[id][GangSafe][GANGSAFE_SPEED] < amount)
			return SendClientMessage(playerid, WHITE, "The gang safe doesn't not have that much speed!");
			
		format(string, sizeof(string), "%s has withdrawn %d grams of speed from their gang safe. (Old balance: %d | New Balance: %d) (Gang: %d)", GetName(playerid), amount, Gangs[id][GangSafe][GANGSAFE_SPEED], Gangs[id][GangSafe][GANGSAFE_SPEED] - amount, id);
		StatLog(string);
		format(string, sizeof(string), "You have withdrawn %d grams of speed from your gang safe.", amount);
		SendClientMessage(playerid, WHITE, string);
		Gangs[id][GangSafe][GANGSAFE_SPEED] -= amount;
		Player[playerid][Speed] += amount;
		SaveGang(id);
	}
	else 
	{
		SendClientMessage(playerid, WHITE, "SYNTAX: /gangsafewithdraw [option] [amount]");
		return SendClientMessage(playerid, WHITE, "Options: Money, streetmats, standardmats, militarymats, Pot, Cocaine, Speed");
	}
	return 1;
}

CMD:gchangerank(playerid, params[])
{
	if(Gangs[Player[playerid][Gang]][GangType] == GANG_TYPE_NONE)
		return 1;
	
	if(!DoesPlayerHavePerms(playerid, PERM_GCHANGERANK))
		return SendClientMessage(playerid, RED, "Permission denied.");
		
	new id, rank;
	if(sscanf(params, "ud", id, rank))
		return SendClientMessage(playerid, WHITE, "SYNTAX: /gchangerank [playerid] [rank]");
		
	if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, WHITE, "That player isn't connected.");
	
	if(Player[id][Gang] != Player[playerid][Gang])
		return SendClientMessage(playerid, WHITE, "That player isn't in your gang!");
	
	if(Player[id][GangRank] >= Player[playerid][GangRank])
		return SendClientMessage(playerid, WHITE, "You can only change the rank of a lower ranked gang member.");
	
	if(rank >= Player[playerid][GangRank])
		return SendClientMessage(playerid, WHITE, "You can only change the rank to one lower than yours.");
		
	if(rank < 1 || rank > 10)
		return SendClientMessage(playerid, WHITE, "Valid ranks are between 1 and 10.");
		
	format(string, sizeof(string), "[GANGS] %s has changed %s's gang rank to %d. (was %d)", GetName(playerid), GetName(id), rank, Player[id][GangRank]);
	StatLog(string);
	format(string, sizeof(string), "Your rank was changed from %d to %d by %s.", Player[id][GangRank], rank, GetName(playerid));
	SendClientMessage(id, WHITE, string);
	format(string, sizeof(string), "You have changed %s's rank to %d. (was %d)", GetName(id), rank, Player[id][GangRank]);
	SendClientMessage(playerid, WHITE, string);
	Player[id][GangRank] = rank;
	return 1;
}

CMD:gcp(playerid, params[]) {return cmd_gangcontrolpanel(playerid, params);}
CMD:gangcontrolpanel(playerid, params[])
{
	if(Gangs[Player[playerid][Gang]][GangType] == GANG_TYPE_NONE)
		return 1;
		
	if(!DoesPlayerHavePerms(playerid, PERM_GCP))
		return SendClientMessage(playerid, RED, "Permission denied.");
	
	format(string, sizeof(string), "{127C00}- %s's Gang Control Panel -\n{3D6666}Edit Ranks\n{3D6666}Total Members: {FFFFFF}%d", Gangs[Player[playerid][Gang]][GangName], GetGangMemberCount(Player[playerid][Gang]));
	ShowPlayerDialog(playerid, GCP_MAIN, DIALOG_STYLE_LIST, "Gang Control Panel", string, "Select", "Exit");
	return 1;
}

CMD:listmygang(playerid, params[])
{
	if(Gangs[Player[playerid][Gang]][GangType] == GANG_TYPE_NONE)
		return 1;
	
	SendClientMessage(playerid, GREY, "------------------------------------------------------------");
	format(string, sizeof(string), "Gang %s's -- Online Members", Gangs[Player[playerid][Gang]][GangName]);
	SendClientMessage(playerid, WHITE, string);
	SendClientMessage(playerid, GREY, "------------------------------------------------------------");
	foreach(Player, i)
	{
		if(Player[i][Gang] == Player[playerid][Gang])
		{
			format(string, sizeof(string), "%s %s | Rank: %d", GetPlayersGangRankName(i), Player[i][NormalName], Player[i][GangRank]);
			SendClientMessage(playerid, GREY, string);
		}
	}
	SendClientMessage(playerid, GREY, "------------------------------------------------------------");
	return 1;
}

CMD:gangcallcar(playerid, params[])
{
	if(Gangs[Player[playerid][Gang]][GangType] == GANG_TYPE_NONE)
		return 1;
	
	new vehString[1024];
	for(new i; i < MAX_VEHICLES; i++)
	{
		new idx = GetVIndex(Veh[i][SQLID]);

		if(idx == -1)
			continue;

		if(Veh[idx][GangLink] != Player[playerid][Gang])
			continue;

		if(Veh[idx][impounded] == 1)
			continue;

		if(Veh[idx][spawnState] == 0)
			continue;

		format(vehString, sizeof(vehString), "%s%d | [ %s ] %s\n", vehString, Veh[idx][SQLID], vNames[Veh[idx][Model] - 400], Veh[idx][VName]);
	}

	ShowPlayerDialog(playerid, GANG_CALL_CAR, DIALOG_STYLE_LIST, "Track Gang Vehicle", vehString, "Find", "Cancel");
	return 1;
}

CMD:gangmotd(playerid, params[])
{
	if(Gangs[Player[playerid][Gang]][GangType] == GANG_TYPE_NONE)
		return 1;
		
	if(!DoesPlayerHavePerms(playerid, PERM_MOTD) || isnull(params))
	{
		format(string, sizeof(string), "Gang MOTD: %s", Gangs[Player[playerid][Gang]][MOTD]);
		return SendClientMessage(playerid, ANNOUNCEMENT, string);
	}
	else 
	{
		format(Gangs[Player[playerid][Gang]][MOTD], 128, "%s", params);
		format(string, sizeof(string), "You have changed your Gang MOTD to %s.", Gangs[Player[playerid][Gang]][MOTD]);
		SendClientMessage(playerid, WHITE, string);
		format(string, sizeof(string), "The Gang MOTD has been changed to: %s. (by %s)", Gangs[Player[playerid][Gang]][MOTD], GetName(playerid));
		SendToGang(Player[playerid][Gang], ANNOUNCEMENT, string);
	}
	return 1;
}

CMD:remoteguninvite(playerid, params[])
{
	if(Gangs[Player[playerid][Gang]][GangType] == GANG_TYPE_NONE)
		return 1;
	
	if(!DoesPlayerHavePerms(playerid, PERM_REMOTEUNINVITE))
		return SendClientMessage(playerid, RED, "Permission denied.");
		
	
	new name[MAX_PLAYER_NAME + 1];
	if(sscanf(params, "s[25]", name))
		return SendClientMessage(playerid, WHITE, "SYNTAX: /remoteguninvite [player name]");
		
	if(!IsPlayerRegistered(name))
		return SendClientMessage(playerid, WHITE, "This player doesn't exist.");
	
	new gang, gangrank, query[255];
	mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT Gang, GangRank FROM playeraccounts WHERE NormalName = '%e'", name);
	new Cache:data = mysql_query(MYSQL_MAIN, query);
	
	if(!cache_get_row_count())
	{
		cache_delete(data);
		return SendClientMessage(playerid, WHITE, "An error occured while uninviting that player.");
	}
	
	gang = cache_get_field_content_int(0, "Gang");
	gangrank = cache_get_field_content_int(0, "GangRank");
	cache_delete(data);
	
	if(gang != Player[playerid][Gang])
		return SendClientMessage(playerid, WHITE, "This player isn't in your gang.");
		
	if(gangrank > Player[playerid][GangRank])
		return SendClientMessage(playerid, WHITE, "You can't uninvite a higher rank.");

	mysql_format(MYSQL_MAIN, query, sizeof(query), "UPDATE playeraccounts SET `Gang` = '0', GangRank = '0' WHERE NormalName = '%e'", name);
	mysql_query(MYSQL_MAIN, query, false);
	
	format(string, sizeof(string), "%s has left the gang. (remotely uninvited by %s)", name, GetName(playerid));
	SendToGang(Player[playerid][Gang], ANNOUNCEMENT, string);
	format(string, sizeof(string), "You have uninvited %s from %s.", name, Gangs[Player[playerid][Gang]][GangName]);
	SendClientMessage(playerid, WHITE, string);
	format(string, sizeof(string), "[GANGS] %s (%d) has remotely uninvited %s from %s. (%d)", GetName(playerid), Player[playerid][GangRank], name, Gangs[Player[playerid][Gang]][GangName], Player[playerid][Gang]);
	StatLog(string);
	return 1;
}

CMD:disbandgang(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 6)
		return 1;
	
	new gang;
	if(sscanf(params, "d", gang))
		return SendClientMessage(playerid, WHITE, "SYNTAX: /disbandgang [gang id]");
		
	if(!DoesGangExist(gang))
		return SendClientMessage(playerid, WHITE, "Invalid gang ID.");
	
	foreach(Player, i)
	{
		if(Player[i][Gang] == gang)
		{
			Player[i][Gang] = 0;
			Player[i][GangRank] = 0;
			SendClientMessage(i, RED, "Your gang has been disbanded by an admin.");
		}
	}
	
	mysql_format(MYSQL_MAIN, string, sizeof(string), "UPDATE playeraccounts SET Gang = 0, GangRank = 0 WHERE Gang = %d", gang);
	mysql_query(MYSQL_MAIN, string, false);
	
	for(new i; i < MAX_VEHICLES; i++)
	{
		if(IsValidVehicle(i))
		{
			if(Veh[i][GangLink] == gang)
			{
				Veh[i][GangLink] = 0;
				SaveVehicle(i);
			}
		}
	}
	
	format(Gangs[gang][GangName], 32, "Disbanded (%s)", Player[playerid][AdminName]);
	Gangs[gang][GangType] = GANG_TYPE_NONE;
	Gangs[gang][GangSafe][GANGSAFE_MATSLOW] = 0;
	Gangs[gang][GangSafe][GANGSAFE_MATSMID] = 0;
	Gangs[gang][GangSafe][GANGSAFE_MATSHIGH] = 0;
	Gangs[gang][GangSafe][GANGSAFE_COCAINE] = 0;
	Gangs[gang][GangSafe][GANGSAFE_SPEED] = 0;
	Gangs[gang][GangSafe][GANGSAFE_POT] = 0;
	Gangs[gang][GangSafe][GANGSAFE_CASH] = 0;
	Gangs[gang][HQLinkID] = 0;
	Gangs[gang][HQLinkType] = 0;
	SaveGang(gang);
	
	
	format(string, sizeof(string), "You have disbanded gang id %d.", gang);
	SendClientMessage(playerid, WHITE, string);
	format(string, sizeof(string), "%s has disbaned gang id %d.", Player[playerid][AdminLevel], gang);
	SendToAdmins(RED, string, 0);
	AdminActionsLog(string);
	return 1;
}

// ============= Stock Functions =============

stock SaveGang(id)
{
	if(!DoesGangExist(id))
		return printf("[GangError] Tried to save a gang that doesn't exist. (ID: %d)", id);
	
	SaveRanks(id);
	
	new query[1024];
	/*mysql_format(MYSQL_MAIN, query, sizeof(query), "UPDATE Gangs SET ExtPosX = '%f', ExtPosY = '%f', ExtPosZ = '%f', ExtIntID = '%d', ExtVW = '%d', IntPosX = '%f', IntPosY = '%f', IntPosZ = '%f'", \
	Gangs[id][ExtPos][0], Gangs[id][ExtPos][1], Gangs[id][ExtPos][2], Gangs[id][ExtIntID], Gangs[id][ExtVW], Gangs[id][IntPos][0], Gangs[id][IntPos][1], Gangs[id][IntPos][2]);
	
	mysql_format(MYSQL_MAIN, query, sizeof(query), "%s, IntID = '%d', IntVW = '%d', HQLockStatus = '%d', ", \
	query, Gangs[id][IntID], Gangs[id][IntVW], Gangs[id][HQLockStatus], Gangs[id][GangName], Gangs[id][GangType], Gangs[id][GangSafe][GANGSAFE_MATSLOW], Gangs[id][GangSafe][GANGSAFE_MATSMID], Gangs[id][GangSafe][GANGSAFE_MATSHIGH], Gangs[id][GangSafe][GANGSAFE_COCAINE]);
	*/
	
	mysql_format(MYSQL_MAIN, query, sizeof(query), "UPDATE Gangs SET GangName = '%e', GangType = '%d', GangMats = '%d', GangMats1 = '%d', GangMats2 = '%d', GangCocaine = '%d'", \
	Gangs[id][GangName], Gangs[id][GangType], Gangs[id][GangSafe][GANGSAFE_MATSLOW], Gangs[id][GangSafe][GANGSAFE_MATSMID], Gangs[id][GangSafe][GANGSAFE_MATSHIGH], Gangs[id][GangSafe][GANGSAFE_COCAINE]);
	
	mysql_format(MYSQL_MAIN, query, sizeof(query), "%s, GangSpeed = '%d', GangPot = '%d', GangCash = '%d', GangSafeX = '%f', HQLinkID = '%d', HQLinkType = '%d'", \
	query, Gangs[id][GangSafe][GANGSAFE_SPEED], Gangs[id][GangSafe][GANGSAFE_POT], Gangs[id][GangSafe][GANGSAFE_CASH], Gangs[id][GangSafePos][0], Gangs[id][HQLinkID], Gangs[id][HQLinkType]);
	
	mysql_format(MYSQL_MAIN, query, sizeof(query), "%s, GangSafeY = '%f', GangSafeZ = '%f', GangSafeInt = '%d', GangSafeVW = '%d', MOTD = '%e' WHERE GangSQL = '%d'", \
	query, Gangs[id][GangSafePos][1], Gangs[id][GangSafePos][2], Gangs[id][GangSafeInt], Gangs[id][GangSafeVW], Gangs[id][MOTD], Gangs[id][GangSQL]);
	
	mysql_query(MYSQL_MAIN, query, false);
	printf("Saved gang %d.", id);
	return 1;
}

stock SaveRanks(id)
{
	if(!DoesGangExist(id))
		return printf("[GangError] Tried to save ranks for a gang that doesn't exist. (ID: %d)", id);
	new query[1024];
	for(new i; i < MAX_RANKS; i++)
	{
		mysql_format(MYSQL_MAIN, query, sizeof(query), "UPDATE GangRanks SET RankName = '%e', PERM_GCP = '%d', PERM_GCHANGERANK = '%d'", \
		GangRanks[id][i][RankName], GangRanks[id][i][RankPermissions][PERM_GCP], GangRanks[id][i][RankPermissions][PERM_GCHANGERANK]);
		
		mysql_format(MYSQL_MAIN, query, sizeof(query), "%s, PERM_GANGSAFEWITHDRAW = '%d', PERM_GANGSAFEDEPOSIT = '%d', PERM_GANGSAFEBALANCE = '%d', PERM_GANGSAFELOC = '%d'", \
		query, GangRanks[id][i][RankPermissions][PERM_GANGSAFEWITHDRAW], GangRanks[id][i][RankPermissions][PERM_GANGSAFEDEPOSIT], GangRanks[id][i][RankPermissions][PERM_GANGSAFEBALANCE], GangRanks[id][i][RankPermissions][PERM_GANGSAFELOC]);
		
		mysql_format(MYSQL_MAIN, query, sizeof(query), "%s, PERM_GRADIO = '%d', PERM_LOCKGANGHQ = '%d', PERM_GANGCHAT = '%d', PERM_TOGGLEGANGCHAT = '%d'", \
		query, GangRanks[id][i][RankPermissions][PERM_GRADIO], GangRanks[id][i][RankPermissions][PERM_LOCKGANGHQ], GangRanks[id][i][RankPermissions][PERM_GANGCHAT], GangRanks[id][i][RankPermissions][PERM_TOGGLEGANGCHAT]);
		
		mysql_format(MYSQL_MAIN, query, sizeof(query), "%s, PERM_GUNINVITE = '%d', PERM_GINVITE = '%d' , PERM_VEHICLES = '%d', PERM_PARKCAR = '%d', PERM_MOTD = '%d'", \
		query, GangRanks[id][i][RankPermissions][PERM_GUNINVITE], GangRanks[id][i][RankPermissions][PERM_GINVITE], GangRanks[id][i][RankPermissions][PERM_VEHICLES], GangRanks[id][i][RankPermissions][PERM_PARKCAR], GangRanks[id][i][RankPermissions][PERM_MOTD]);
		
		mysql_format(MYSQL_MAIN, query, sizeof(query), "%s, PERM_GANGIMPLIST = '%d', PERM_REMOTEUNINVITE = '%d', PERM_CREATEBOMBS = '%d', PERM_CREATEFAKEDOCS = '%d' WHERE GangSQL = '%d' AND Rank = '%d'", \
		query, GangRanks[id][i][RankPermissions][PERM_GANGIMPLIST], GangRanks[id][i][RankPermissions][PERM_REMOTEUNINVITE], GangRanks[id][i][RankPermissions][PERM_CREATEBOMBS], GangRanks[id][i][RankPermissions][PERM_CREATEFAKEDOCS], Gangs[id][GangSQL], i + 1);
		
		mysql_query(MYSQL_MAIN, query, false);
		printf("Saved Gang %d's rank %d.", id, i + 1);
	}
	return 1;
}

stock LoadRanks(id)
{
	if(!DoesGangExist(id))
		return printf("[GangError] Tried to load ranks for a gang that doesn't exist. (ID: %d)", id);
	
	new row, count, Cache:cache;
	mysql_format(MYSQL_MAIN, string, sizeof(string), "SELECT * FROM GangRanks WHERE GangSQL = '%d'", Gangs[id][GangSQL]);
	cache = mysql_query(MYSQL_MAIN, string);
	
	if(!cache_is_valid(cache))
		return printf("[GangError] Failed to load ranks for gang %d. (SQL: %d)", id, Gangs[id][GangSQL]);
	
	count = cache_get_row_count();
		
	while(row < count)
	{
		cache_get_field_content(row, "RankName", GangRanks[id][row][RankName], 1, MAX_RANK_NAME);
		GangRanks[id][row][RankPermissions][PERM_GCP] = cache_get_field_content_int(row, "PERM_GCP");
		GangRanks[id][row][RankPermissions][PERM_GCHANGERANK] = cache_get_field_content_int(row, "PERM_GCHANGERANK");
		GangRanks[id][row][RankPermissions][PERM_GANGSAFEWITHDRAW] = cache_get_field_content_int(row, "PERM_GANGSAFEWITHDRAW");
		GangRanks[id][row][RankPermissions][PERM_GANGSAFEDEPOSIT] = cache_get_field_content_int(row, "PERM_GANGSAFEDEPOSIT");
		GangRanks[id][row][RankPermissions][PERM_GANGSAFEBALANCE] = cache_get_field_content_int(row, "PERM_GANGSAFEBALANCE");
		GangRanks[id][row][RankPermissions][PERM_GANGSAFELOC] = cache_get_field_content_int(row, "PERM_GANGSAFELOC");
		GangRanks[id][row][RankPermissions][PERM_GRADIO] = cache_get_field_content_int(row, "PERM_GRADIO");
		GangRanks[id][row][RankPermissions][PERM_LOCKGANGHQ] = cache_get_field_content_int(row, "PERM_LOCKGANGHQ");
		GangRanks[id][row][RankPermissions][PERM_GANGCHAT] = cache_get_field_content_int(row, "PERM_GANGCHAT");
		GangRanks[id][row][RankPermissions][PERM_TOGGLEGANGCHAT] = cache_get_field_content_int(row, "PERM_TOGGLEGANGCHAT");
		GangRanks[id][row][RankPermissions][PERM_GUNINVITE] = cache_get_field_content_int(row, "PERM_GUNINVITE");
		GangRanks[id][row][RankPermissions][PERM_GINVITE] = cache_get_field_content_int(row, "PERM_GINVITE");
		GangRanks[id][row][RankPermissions][PERM_VEHICLES] = cache_get_field_content_int(row, "PERM_VEHICLES");
		GangRanks[id][row][RankPermissions][PERM_PARKCAR] = cache_get_field_content_int(row, "PERM_PARKCAR");
		GangRanks[id][row][RankPermissions][PERM_MOTD] = cache_get_field_content_int(row, "PERM_MOTD");
		GangRanks[id][row][RankPermissions][PERM_GANGIMPLIST] = cache_get_field_content_int(row, "PERM_GANGIMPLIST");
		GangRanks[id][row][RankPermissions][PERM_REMOTEUNINVITE] = cache_get_field_content_int(row, "PERM_REMOTEUNINVITE");
		GangRanks[id][row][RankPermissions][PERM_CREATEBOMBS] = cache_get_field_content_int(row, "PERM_CREATEBOMBS");
		GangRanks[id][row][RankPermissions][PERM_CREATEFAKEDOCS] = cache_get_field_content_int(row, "PERM_CREATEFAKEDOCS");
		row++;
	}
	printf("Loaded %d ranks for gang %d.", count, id);
	cache_delete(cache);
	return 1;
}

stock LoadGangs()
{	
	Iter_Add(Gang, 0);
	new Cache:cache = mysql_query(MYSQL_MAIN, "SELECT * FROM Gangs");
	new count = cache_get_row_count(), row, id;
	
	while(row < count)
	{
		if(!cache_is_valid(cache))
			return printf("[GangError] Cache became invalid before attempting to load row %d.", row);
		
		id = GetAvailableGangID();
		if(id == 0)
			id++;

		Gangs[id][GangSQL] = cache_get_field_content_int(row, "GangSQL");
		
		/*Gangs[id][ExtPos][0] = cache_get_field_content_float(row, "ExtPosX");
		Gangs[id][ExtPos][1] = cache_get_field_content_float(row, "ExtPosY");
		Gangs[id][ExtPos][2] = cache_get_field_content_float(row, "ExtPosZ");
		Gangs[id][ExtIntID] = cache_get_field_content_int(row, "ExtIntID");
		Gangs[id][ExtVW] = cache_get_field_content_int(row, "ExtVW");
		Gangs[id][IntPos][0] = cache_get_field_content_float(row, "IntPosX");
		Gangs[id][IntPos][1] = cache_get_field_content_float(row, "IntPosY");
		Gangs[id][IntPos][2] = cache_get_field_content_float(row, "IntPosZ");
		Gangs[id][IntID] = cache_get_field_content_int(row, "IntID");
		Gangs[id][IntVW] = cache_get_field_content_int(row, "IntVW");
		Gangs[id][HQLockStatus] = cache_get_field_content_int(row, "HQLockStatus");*/	
		
		Gangs[id][HQLinkID] = cache_get_field_content_int(row, "HQLinkID");
		Gangs[id][HQLinkType] = cache_get_field_content_int(row, "HQLinkType");
		cache_get_field_content(row, "GangName", Gangs[id][GangName], 1, 32);
		Gangs[id][GangType] = cache_get_field_content_int(row, "GangType");
		Gangs[id][GangSafe][GANGSAFE_MATSLOW] = cache_get_field_content_int(row, "GangMats");
		Gangs[id][GangSafe][GANGSAFE_MATSMID] = cache_get_field_content_int(row, "GangMats1");
		Gangs[id][GangSafe][GANGSAFE_MATSHIGH] = cache_get_field_content_int(row, "GangMats2");
		Gangs[id][GangSafe][GANGSAFE_COCAINE] = cache_get_field_content_int(row, "GangCocaine");
		Gangs[id][GangSafe][GANGSAFE_POT] = cache_get_field_content_int(row, "GangPot");
		Gangs[id][GangSafe][GANGSAFE_SPEED] = cache_get_field_content_int(row, "GangSpeed");
		Gangs[id][GangSafe][GANGSAFE_CASH] = cache_get_field_content_int(row, "GangCash");
		Gangs[id][GangSafePos][0] = cache_get_field_content_float(row, "GangSafeX");
		Gangs[id][GangSafePos][1] = cache_get_field_content_float(row, "GangSafeY");
		Gangs[id][GangSafePos][2] = cache_get_field_content_float(row, "GangSafeZ");
		Gangs[id][GangSafeInt] = cache_get_field_content_int(row, "GangSafeInt");
		Gangs[id][GangSafeVW] = cache_get_field_content_int(row, "GangSafeVW");
		cache_get_field_content(row, "MOTD", Gangs[id][MOTD], 1, 128);
		
		Iter_Add(Gang, id);
		
		//Ranks
		LoadRanks(id);

		//UpdateGang(id);
		UpdateGangSafe(id);
		
		cache_set_active(cache);
		row ++;
	}
	
	cache_delete(cache);
	Iter_Remove(Gang, 0);
	printf("[system] Loaded %d gangs. (out of %d rows counted)", row, count);
	return 1;
}

stock GetAvailableGangID() 
{
	new id;
	Iter_Add(Gang, 0);
	id = Iter_Free(Gang);
	Iter_Remove(Gang, 0);
	return id;
}
stock DoesGangExist(id) {return Iter_Contains(Gang, id);}

stock UpdateGang(id)
{
	if(!DoesGangExist(id))
	{
		return printf("[GangError] Tried to update a gang that doesn't exist. (ID: %d)", id);
	}
	
	if(IsValidDynamic3DTextLabel(Gangs[id][GangLabel]))
		DestroyDynamic3DTextLabel(Gangs[id][GangLabel]);
	if(IsValidDynamicPickup(Gangs[id][GangIcon]))
		DestroyDynamicPickup(Gangs[id][GangIcon]);

	format(string, sizeof(string), "%s's HQ", Gangs[id][GangName]);
	Gangs[id][GangLabel] = CreateDynamic3DTextLabel(string, GREEN, Gangs[id][ExtPos][0], Gangs[id][ExtPos][1], Gangs[id][ExtPos][2] + 0.5, 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, Gangs[id][ExtVW], Gangs[id][ExtIntID]);
	Gangs[id][GangIcon] = CreateDynamicPickup(1239, 1, Gangs[id][ExtPos][0], Gangs[id][ExtPos][1], Gangs[id][ExtPos][2], Gangs[id][ExtVW], Gangs[id][ExtIntID]);
	
	return 1;
}

stock UpdateGangSafe(id)
{
	if(!DoesGangExist(id))
		return printf("[GangError] Tried to update the safe of a gang that doesn't exist.");
		
	if(IsValidDynamic3DTextLabel(Gangs[id][GangSafeLabel]))
		DestroyDynamic3DTextLabel(Gangs[id][GangSafeLabel]);
	if(IsValidDynamicPickup(Gangs[id][GangSafeIcon]))
		DestroyDynamicPickup(Gangs[id][GangSafeIcon]);
		
	format(string, sizeof(string), "%s's Safe", Gangs[id][GangName]);
	Gangs[id][GangSafeLabel] = CreateDynamic3DTextLabel(string, GREEN, Gangs[id][GangSafePos][0], Gangs[id][GangSafePos][1], Gangs[id][GangSafePos][2] + 0.5, 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, Gangs[id][GangSafeVW], Gangs[id][GangSafeInt]);
	Gangs[id][GangSafeIcon] = CreateDynamicPickup(1239, 1, Gangs[id][GangSafePos][0], Gangs[id][GangSafePos][1], Gangs[id][GangSafePos][2], Gangs[id][GangSafeVW], Gangs[id][GangSafeInt]);
	return 1;
}

stock SendToGang(id, color, message[])
{
	foreach(Player, i)
	{
		if(Player[i][Gang] == id)
		{
			SendClientMessage(i, color, message);
		}
	}
	return 1;
}

stock GetPlayersGangRankName(playerid)
{
	new name[MAX_RANK_NAME];
	new rank = Player[playerid][GangRank] - 1;
	if(rank < 0)
		rank = 0;
	format(name, sizeof(name), GangRanks[Player[playerid][Gang]][rank][RankName]);
	return name;
}

stock GetGangMemberCount(id)
{
	if(!DoesGangExist(id))
		return printf("[GangError] Attempted to get member count of nonexistant gang.");
		
	mysql_format(MYSQL_MAIN, string, sizeof(string), "SELECT * FROM playeraccounts WHERE Gang = '%d'", Gangs[id][GangSQL]);
	new Cache:cache = mysql_query(MYSQL_MAIN, string), rows = cache_get_row_count();
	cache_delete(cache);
	return rows;
}

stock DoesPlayerHavePerms(playerid, perm)
{
	if(Player[playerid][GangRank] == 0)
		return SendClientMessage(playerid, RED, "DONT USE COMMANDS WHILE RANK 0 ADMINS.");
	
	return GangRanks[ Player[playerid][Gang] ][ Player[playerid][GangRank] - 1 ][ RankPermissions ][ perm ];
}

stock DisplayGangMembers(playerid, gang, showonlinestatus = 0)
{
	new query[128];
	mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT NormalName, GangRank FROM playeraccounts WHERE Gang = '%d'", gang);
	new Cache:cache = mysql_query(MYSQL_MAIN, query), rows = cache_get_row_count(), name[24];
	
	SendClientMessage(playerid, WHITE, "---------------------------------------------------------------------");
	
	for(new i = 0; i < rows; i++)
	{
		cache_get_field_content(i, "NormalName", name);
		
		if(showonlinestatus == 1)
			format(string, sizeof(string), "%s - %d (%s)", name, cache_get_field_content_int(i, "GangRank"), (GetPlayerID(name) == INVALID_PLAYER_ID) ? ("OFFLINE") : ("ONLINE"));
		else format(string, sizeof(string), "%s - %d", name, cache_get_field_content_int(i, "GangRank"));
		
		SendClientMessage(playerid, GREY, string);
	}
	
	cache_delete(cache);
	
	SendClientMessage(playerid, WHITE, "---------------------------------------------------------------------");
	return 1;
}