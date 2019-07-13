/*
#		MTG Side-Doors
#		
#
#	By accessing this file, you agree to the following:
#		- You will never give the script or associated files to anybody who is not on the MTG SAMP development team
# 		- You will delete all development materials (script, databases, associated files, etc.) when you leave the MTG SAMP development team.
#
#
*/

// CREATE TABLE IF NOT EXISTS SideDoors (DoorID INT, IntX FLOAT, IntY FLOAT, IntZ FLOAT, IntVW INT, IntInt INT, ExtX FLOAT, ExtY FLOAT, ExtZ FLOAT, ExtVW INT, ExtInt INT, LinkType INT, BelongsTo VARCHAR(25), Code INT DEFAULT -1, DoorLock INT DEFAULT 1)

#define MAX_SIDEDOORS 		250
#define REQ_ADMIN 			3

#define SD_TYPE_HOUSE		1
#define SD_TYPE_BUSINESS	2
#define SD_TYPE_GROUP		3
#define SD_TYPE_GANG		4
#define SD_TYPE_PLAYER		5

#define SIDEDOOR_MAIN 			9233
#define SIDEDOOR_EDITVALUE 		9234

#include <YSI\y_hooks>

enum _SideDoors
{
	Float:SD_IntX,
	Float:SD_IntY,
	Float:SD_IntZ,
	SD_IntVW,
	SD_IntInt,
	Float:SD_ExtX,
	Float:SD_ExtY,
	Float:SD_ExtZ,
	SD_ExtVW,
	SD_ExtInt,
	SD_Lock,
	SD_LinkType,
	SD_BelongsTo[25],
	SD_Code,
	Text3D:SD_Label,
}

new SideDoor[MAX_SIDEDOORS][_SideDoors], PlayerSideDoor[MAX_PLAYERS][_SideDoors], empty[_SideDoors];
new Iterator:SideDoors<MAX_SIDEDOORS>;

// START HOOKS

hook OnPlayerConnect(playerid)
{
	PlayerSideDoor[playerid] = empty;
	return 1;
}
	
hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case SIDEDOOR_MAIN:
		{
			if(!response)
				return 1;
				
			new doorid = GetPVarInt(playerid, "SD_EDITING");
			switch(listitem)
			{
				case 0: //int
				{
					GetPlayerPos(playerid, PlayerSideDoor[playerid][SD_IntX], PlayerSideDoor[playerid][SD_IntY], PlayerSideDoor[playerid][SD_IntZ]);
					PlayerSideDoor[playerid][SD_IntVW] = GetPlayerVirtualWorld(playerid);
					PlayerSideDoor[playerid][SD_IntInt] = GetPlayerInterior(playerid);
					
					ShowPlayerDialog(playerid, SIDEDOOR_MAIN, DIALOG_STYLE_TABLIST, "Side Door Edit", SideDoorEditString(playerid, doorid), "Select", "Close");
				}
				case 1: //ext
				{
					GetPlayerPos(playerid, PlayerSideDoor[playerid][SD_ExtX], PlayerSideDoor[playerid][SD_ExtY], PlayerSideDoor[playerid][SD_ExtZ]);
					PlayerSideDoor[playerid][SD_ExtVW] = GetPlayerVirtualWorld(playerid);
					PlayerSideDoor[playerid][SD_ExtInt] = GetPlayerInterior(playerid);
					
					ShowPlayerDialog(playerid, SIDEDOOR_MAIN, DIALOG_STYLE_TABLIST, "Side Door Edit", SideDoorEditString(playerid, doorid), "Select", "Close");
				}
				case 2: //linktype
				{
					SetPVarInt(playerid, "SD_EDITVALUE", 1);
					ShowPlayerDialog(playerid, SIDEDOOR_EDITVALUE, DIALOG_STYLE_INPUT, "Side Door Edit", "Set the side doors link type ( 1 - 5 )", "Done", "Cancel");
				}
				case 3: //id / name
				{
					SetPVarInt(playerid, "SD_EDITVALUE", 2);
					ShowPlayerDialog(playerid, SIDEDOOR_EDITVALUE, DIALOG_STYLE_INPUT, "Side Door Edit", "Set the ID / name for the link type.", "Done", "Cancel");
				}
				case 4: //lock
				{
					SetPVarInt(playerid, "SD_EDITVALUE", 3);
					ShowPlayerDialog(playerid, SIDEDOOR_EDITVALUE, DIALOG_STYLE_INPUT, "Side Door Edit", "Set the side doors lock state ( 0 or 1 ).", "Done", "Cancel");
				}
				case 5: //code
				{
					SetPVarInt(playerid, "SD_EDITVALUE", 4);
					ShowPlayerDialog(playerid, SIDEDOOR_EDITVALUE, DIALOG_STYLE_INPUT, "Side Door Edit", "Set the side doors code ( -1 for to remove code ).", "Done", "Cancel");
				}
				case 6: //save
				{
					new label[20];
					
					SideDoor[doorid] = PlayerSideDoor[playerid];
					SaveDoor(doorid);
					
					format(label, sizeof(label), "Side Door %d", doorid);
					if(IsValidDynamic3DTextLabel(SideDoor[doorid][SD_Label]))
						DestroyDynamic3DTextLabel(SideDoor[doorid][SD_Label]);
					SideDoor[doorid][SD_Label] = CreateDynamic3DTextLabel(label, 0xF2B629AA, SideDoor[doorid][SD_ExtX], SideDoor[doorid][SD_ExtY], SideDoor[doorid][SD_ExtZ], 2.0, .worldid = SideDoor[doorid][SD_ExtVW], .interiorid = SideDoor[doorid][SD_ExtInt]);
					
					SendClientMessage(playerid, WHITE, "Side Door saved!");
					
					ShowPlayerDialog(playerid, SIDEDOOR_MAIN, DIALOG_STYLE_TABLIST, "Side Door Edit", SideDoorEditString(playerid, doorid), "Select", "Close");
				}
			}
		}
		case SIDEDOOR_EDITVALUE:
		{
			new doorid = GetPVarInt(playerid, "SD_EDITING");
			
			if(!response)
				return ShowPlayerDialog(playerid, SIDEDOOR_MAIN, DIALOG_STYLE_TABLIST, "Side Door Edit", SideDoorEditString(playerid, doorid), "Select", "Close");
			
			switch(GetPVarInt(playerid, "SD_EDITVALUE"))
			{
				case 1: //linktype
				{
					if(strval(inputtext) < 1 || strval(inputtext) > 5)
						return ShowPlayerDialog(playerid, SIDEDOOR_MAIN, DIALOG_STYLE_TABLIST, "Side Door Edit", SideDoorEditString(playerid, doorid), "Select", "Close"), SendClientMessage(playerid, GREY, "Error, invalid linktype. ( 1 - 5 )");
						
					PlayerSideDoor[playerid][SD_LinkType] = strval(inputtext);
					ShowPlayerDialog(playerid, SIDEDOOR_MAIN, DIALOG_STYLE_TABLIST, "Side Door Edit", SideDoorEditString(playerid, doorid), "Select", "Close");
				}
				case 2: //id / name
				{
					if(PlayerSideDoor[playerid][SD_LinkType] == SD_TYPE_PLAYER && !IsPlayerRegistered(inputtext))
						return ShowPlayerDialog(playerid, SIDEDOOR_MAIN, DIALOG_STYLE_TABLIST, "Side Door Edit", SideDoorEditString(playerid, doorid), "Select", "Close"), SendClientMessage(playerid, GREY, "Error, that player does not exist.");
						
					if(PlayerSideDoor[playerid][SD_LinkType] >= 1 && PlayerSideDoor[playerid][SD_LinkType] <= 4 && !IsNumeric(inputtext))
						return ShowPlayerDialog(playerid, SIDEDOOR_MAIN, DIALOG_STYLE_TABLIST, "Side Door Edit", SideDoorEditString(playerid, doorid), "Select", "Close"), SendClientMessage(playerid, GREY, "Error, invalid ID.");
						
					format(PlayerSideDoor[playerid][SD_BelongsTo], 25, inputtext);
					ShowPlayerDialog(playerid, SIDEDOOR_MAIN, DIALOG_STYLE_TABLIST, "Side Door Edit", SideDoorEditString(playerid, doorid), "Select", "Close");
				}
				case 3: //lock
				{
					if(strval(inputtext) < 0 || strval(inputtext) > 1)
						return ShowPlayerDialog(playerid, SIDEDOOR_MAIN, DIALOG_STYLE_TABLIST, "Side Door Edit", SideDoorEditString(playerid, doorid), "Select", "Close"), SendClientMessage(playerid, GREY, "Error, invalid lock state. ( 0 or 1 )");
						
					PlayerSideDoor[playerid][SD_Lock] = strval(inputtext);
					ShowPlayerDialog(playerid, SIDEDOOR_MAIN, DIALOG_STYLE_TABLIST, "Side Door Edit", SideDoorEditString(playerid, doorid), "Select", "Close");
				}
				case 4: //code
				{
					if((strval(inputtext) <= 999 || strval(inputtext) > 99999) && strval(inputtext) != -1)
						return ShowPlayerDialog(playerid, SIDEDOOR_MAIN, DIALOG_STYLE_TABLIST, "Side Door Edit", SideDoorEditString(playerid, doorid), "Select", "Close"), SendClientMessage(playerid, GREY, "Error, code is too short/long. ( 4 - 5 digits or -1 to remove )");
						
					PlayerSideDoor[playerid][SD_Code] = strval(inputtext);
					ShowPlayerDialog(playerid, SIDEDOOR_MAIN, DIALOG_STYLE_TABLIST, "Side Door Edit", SideDoorEditString(playerid, doorid), "Select", "Close");
				}
			}
		}
	}
	return 1;
}
	
hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{	
	if(IsKeyJustDown(Player[playerid][EnterKey], newkeys, oldkeys) && !IsPlayerInAnyVehicle(playerid))
	{
		foreach(new i : SideDoors)
		{
			if(IsPlayerInRangeOfPoint(playerid, 2.0, SideDoor[i][SD_IntX], SideDoor[i][SD_IntY], SideDoor[i][SD_IntZ]) && GetPlayerVirtualWorld(playerid) == SideDoor[i][SD_IntVW] && GetPlayerInterior(playerid) == SideDoor[i][SD_IntInt])
			{
				if(SideDoor[i][SD_Lock] && Player[playerid][AdminDuty] == 0)
					return SendClientMessage(playerid, WHITE, "Door is locked.");
					
				new id = strval(SideDoor[i][SD_BelongsTo]);
				switch(SideDoor[i][SD_LinkType])
				{
					case SD_TYPE_HOUSE: 
					{
						if(SideDoor[i][SD_ExtVW] == 55000 + id) 
							Player[playerid][InHouse] = id;
						else
	                    {
							Player[playerid][InHouse] = 0;
							StopAudioStreamForPlayer(playerid);
						}
								
					}
					case SD_TYPE_BUSINESS: 
					{
						if(SideDoor[i][SD_ExtVW] == 65000 + id) 
							Player[playerid][InBusiness] = id;
						else
	                    {
							Player[playerid][InBusiness] = 0;
							StopAudioStreamForPlayer(playerid);
						}
					}
					case SD_TYPE_GROUP: 
					{
						if(SideDoor[i][SD_ExtVW] == 45000 + id) 
							Player[playerid][InGroupHQ] = id;
						else
						{
							Player[playerid][InGroupHQ] = 0;
							StopAudioStreamForPlayer(playerid);
						}
					}
					case SD_TYPE_GANG: 
					{
						if(SideDoor[i][SD_ExtVW] == 15000 + id) 
							Player[playerid][InGangHQ] = id;
						else
						{
							Player[playerid][InGangHQ] = 0;
							StopAudioStreamForPlayer(playerid);
						}
					}
				}
					
				SetPlayerPos(playerid, SideDoor[i][SD_ExtX], SideDoor[i][SD_ExtY], SideDoor[i][SD_ExtZ]);
				SetPlayerVirtualWorld(playerid, SideDoor[i][SD_ExtVW] );
				SetPlayerInterior(playerid, SideDoor[i][SD_ExtInt]);
				return 1;
			}
			
			if(IsPlayerInRangeOfPoint(playerid, 2.0, SideDoor[i][SD_ExtX], SideDoor[i][SD_ExtY], SideDoor[i][SD_ExtZ]) && GetPlayerVirtualWorld(playerid) == SideDoor[i][SD_ExtVW] && GetPlayerInterior(playerid) == SideDoor[i][SD_ExtInt])
			{
				if(SideDoor[i][SD_Lock] && Player[playerid][AdminDuty] == 0)
					return SendClientMessage(playerid, WHITE, "Door is locked.");
					
				new id = strval(SideDoor[i][SD_BelongsTo]);
				switch(SideDoor[i][SD_LinkType])
				{
					case SD_TYPE_HOUSE: 
					{
						if(SideDoor[i][SD_IntVW] == 55000 + id) 
							Player[playerid][InHouse] = id;
						else
	                    {
							Player[playerid][InHouse] = 0;
							StopAudioStreamForPlayer(playerid);
						}
							
					}
					case SD_TYPE_BUSINESS: 
					{
						if(SideDoor[i][SD_IntVW] == 65000 + id) 
							Player[playerid][InBusiness] = id;
						else
	                    {
							Player[playerid][InBusiness] = 0;
							StopAudioStreamForPlayer(playerid);
						}
					}
					case SD_TYPE_GROUP: 
					{
						if(SideDoor[i][SD_IntVW] == 45000 + id) 
							Player[playerid][InGroupHQ] = id;
						else
						{
							Player[playerid][InGroupHQ] = 0;
							StopAudioStreamForPlayer(playerid);
						}
					}
					case SD_TYPE_GANG: 
					{
						if(SideDoor[i][SD_IntVW] == 15000 + id) 
							Player[playerid][InGangHQ] = id;
						else
						{
							Player[playerid][InGangHQ] = 0;
							StopAudioStreamForPlayer(playerid);
						}
					}
				}
					
				SetPlayerPos_Update(playerid, SideDoor[i][SD_IntX], SideDoor[i][SD_IntY], SideDoor[i][SD_IntZ]);
				SetPlayerVirtualWorld(playerid, SideDoor[i][SD_IntVW]);
				SetPlayerInterior(playerid, SideDoor[i][SD_IntInt]);
				return 1;
			}
		}
	}
	return 1;
}	
	
// END HOOKS

// START FUNCTIONS

SideDoorsInit()
{
	new Cache:cache = mysql_query(MYSQL_MAIN, "SELECT * FROM sidedoors"), count = cache_get_row_count(), row, doorid;
	
	if(count == 0)
		return 1;
	
	while(row < count)
	{
		doorid = cache_get_field_content_int(row, "DoorID");
	
		Iter_Add(SideDoors, doorid);
		
		SideDoor[doorid][SD_IntX] = cache_get_field_content_float(row, "IntX");
		SideDoor[doorid][SD_IntY] = cache_get_field_content_float(row, "IntY");
		SideDoor[doorid][SD_IntZ] = cache_get_field_content_float(row, "IntZ");
		SideDoor[doorid][SD_IntVW] = cache_get_field_content_int(row, "IntVW");
		SideDoor[doorid][SD_IntInt] = cache_get_field_content_int(row, "IntInt");
		SideDoor[doorid][SD_ExtX] = cache_get_field_content_float(row, "ExtX");
		SideDoor[doorid][SD_ExtY] = cache_get_field_content_float(row, "ExtY");
		SideDoor[doorid][SD_ExtZ] = cache_get_field_content_float(row, "ExtZ");
		SideDoor[doorid][SD_ExtVW] = cache_get_field_content_int(row, "ExtVW");
		SideDoor[doorid][SD_ExtInt] = cache_get_field_content_int(row, "ExtInt");
		SideDoor[doorid][SD_Code] = cache_get_field_content_int(row, "Code");
		SideDoor[doorid][SD_Lock] = cache_get_field_content_int(row, "DoorLock");
		SideDoor[doorid][SD_LinkType] = cache_get_field_content_int(row, "LinkType");
		cache_get_field_content(row, "BelongsTo", SideDoor[doorid][SD_BelongsTo], 1, 25);
		
		new label[20];
		format(label, sizeof(label), "Door %d", doorid);
		SideDoor[doorid][SD_Label] = CreateDynamic3DTextLabel(label, 0xF2B629AA, SideDoor[doorid][SD_ExtX], SideDoor[doorid][SD_ExtY], SideDoor[doorid][SD_ExtZ], 2.0, .worldid = SideDoor[doorid][SD_ExtVW], .interiorid = SideDoor[doorid][SD_ExtInt]);
		
		row++;
	}
	cache_delete(cache);
	return 1;
}

static IsAdmin(playerid)
{
	if(Player[playerid][AdminLevel] > REQ_ADMIN)
		return 1;
	return 0;
}

static SaveDoor(doorid, create = 0)
{
	new query[350];
	if(create)
	{
		mysql_format(MYSQL_MAIN, query, sizeof(query), "INSERT INTO sidedoors (DoorID, IntX, IntY, IntZ, IntVW, IntInt, ExtX, ExtY, ExtZ, ExtVW, ExtInt, LinkType, BelongsTo)");
		mysql_format(MYSQL_MAIN, query, sizeof(query), "%s VALUES ('%d', '%f', '%f', '%f', '%d', '%d', '%f', '%f', '%f', '%d', '%d', '%d', '%e')", query, doorid, SideDoor[doorid][SD_IntX], SideDoor[doorid][SD_IntY], SideDoor[doorid][SD_IntZ], SideDoor[doorid][SD_IntVW], \
		SideDoor[doorid][SD_IntInt], SideDoor[doorid][SD_ExtX], SideDoor[doorid][SD_ExtY], SideDoor[doorid][SD_ExtZ], SideDoor[doorid][SD_ExtVW], SideDoor[doorid][SD_ExtInt],  SideDoor[doorid][SD_LinkType],  SideDoor[doorid][SD_BelongsTo]);
		mysql_query(MYSQL_MAIN, query, false);
	}
	else
	{
		mysql_format(MYSQL_MAIN, query, sizeof(query), "UPDATE sidedoors SET IntX = '%f', IntY = '%f', IntZ = '%f', IntVW = '%d', IntInt = '%d', ExtX = '%f', ExtY = '%f', ExtZ = '%f', ExtVW = '%d', ExtInt = '%d', ", SideDoor[doorid][SD_IntX], SideDoor[doorid][SD_IntY], SideDoor[doorid][SD_IntZ], \
		SideDoor[doorid][SD_IntVW], SideDoor[doorid][SD_IntInt], SideDoor[doorid][SD_ExtX], SideDoor[doorid][SD_ExtY], SideDoor[doorid][SD_ExtZ], SideDoor[doorid][SD_ExtVW], SideDoor[doorid][SD_ExtInt]);
		mysql_format(MYSQL_MAIN, query, sizeof(query), "%sCode = '%d', DoorLock = '%d', LinkType = '%d', BelongsTo = '%e' WHERE DoorID = '%d'", query, SideDoor[doorid][SD_Code], SideDoor[doorid][SD_Lock], SideDoor[doorid][SD_LinkType], SideDoor[doorid][SD_BelongsTo], doorid);
		mysql_query(MYSQL_MAIN, query, false);
	}
	return 1;
}

static DoorAccess(playerid, doorid, code = -1)
{
	if(Iter_Contains(SideDoors, doorid) == 0)
		return 0;
		
	if(SideDoor[doorid][SD_Code] != -1 && code == SideDoor[doorid][SD_Code])
		return 1;
	
	switch(SideDoor[doorid][SD_LinkType])
	{
		case SD_TYPE_HOUSE:
		{
			if(PlayerHasHouseKey(playerid, strval(SideDoor[doorid][SD_BelongsTo])))
				return 1;
		}
		case SD_TYPE_BUSINESS:
		{
			if(PlayerHasBusinessKey(playerid, strval(SideDoor[doorid][SD_BelongsTo])))
				return 1;
		}
		case SD_TYPE_GROUP:
		{
			if(Player[playerid][Group] == strval(SideDoor[doorid][SD_BelongsTo]))
				return 1;
		}
		case SD_TYPE_GANG:
		{
			if(Player[playerid][Gang] == strval(SideDoor[doorid][SD_BelongsTo]))
				return 1;
		}
		case SD_TYPE_PLAYER:
		{
			if(!strcmp(Player[playerid][NormalName], SideDoor[doorid][SD_BelongsTo], true))
				return 1;
		}
	}
	return 0;
}

static GetNearestDoor(playerid)
{
	foreach(new i : SideDoors)
	{
		if((IsPlayerInRangeOfPoint(playerid, 2.0, SideDoor[i][SD_IntX], SideDoor[i][SD_IntY], SideDoor[i][SD_IntZ]) && GetPlayerVirtualWorld(playerid) == SideDoor[i][SD_IntVW] && GetPlayerInterior(playerid) == SideDoor[i][SD_IntInt]) || (IsPlayerInRangeOfPoint(playerid, 2.0, SideDoor[i][SD_ExtX], SideDoor[i][SD_ExtY], SideDoor[i][SD_ExtZ]) && GetPlayerVirtualWorld(playerid) == SideDoor[i][SD_ExtVW] && GetPlayerInterior(playerid) == SideDoor[i][SD_ExtInt]))
		{
			return i;
		}
	}
	return -1;
}

static SideDoorEditString(playerid, doorid)
{
	new string[200];
	
	new intchanged[50], extchanged[50];
	if(PlayerSideDoor[playerid][SD_IntX] == SideDoor[doorid][SD_IntX] && PlayerSideDoor[playerid][SD_IntY] == SideDoor[doorid][SD_IntY] && PlayerSideDoor[playerid][SD_IntZ] == SideDoor[doorid][SD_IntZ])
		format(intchanged, sizeof(intchanged), "Interior\tNOT CHANGED\t");
	else
		format(intchanged, sizeof(intchanged), "Interior\t{E83838}CHANGED{FFFFFF}\t");
		
	if(PlayerSideDoor[playerid][SD_ExtX] == SideDoor[doorid][SD_ExtX] && PlayerSideDoor[playerid][SD_ExtY] == SideDoor[doorid][SD_ExtY] && PlayerSideDoor[playerid][SD_ExtZ] == SideDoor[doorid][SD_ExtZ])
		format(extchanged, sizeof(extchanged), "Exterior\tNOT CHANGED\t");
	else
		format(extchanged, sizeof(extchanged), "Exterior\t{E83838}CHANGED{FFFFFF}\t");
		
	new linktype[16], plinktype[16];
	switch(SideDoor[doorid][SD_LinkType])
	{
		case SD_TYPE_HOUSE: format(linktype, sizeof(linktype), "House");
		case SD_TYPE_BUSINESS: format(linktype, sizeof(linktype), "Business");
		case SD_TYPE_GROUP: format(linktype, sizeof(linktype), "Group");
		case SD_TYPE_GANG: format(linktype, sizeof(linktype), "Gang");
	 	case SD_TYPE_PLAYER: format(linktype, sizeof(linktype), "Player");
		default: format(linktype, sizeof(linktype), "{FF0000}UNKNOWN{FFFFFF}");
	}
	switch(PlayerSideDoor[playerid][SD_LinkType])
	{
		case SD_TYPE_HOUSE: format(plinktype, sizeof(plinktype), "House");
		case SD_TYPE_BUSINESS: format(plinktype, sizeof(plinktype), "Business");
		case SD_TYPE_GROUP: format(plinktype, sizeof(plinktype), "Group");
		case SD_TYPE_GANG: format(plinktype, sizeof(plinktype), "Gang");
	 	case SD_TYPE_PLAYER: format(plinktype, sizeof(plinktype), "Player");
		default: format(plinktype, sizeof(plinktype), "{FF0000}UNKNOWN{FFFFFF}");
	}
	
	format(string, sizeof(string), "{FFFFFF}%s\n%s\nLink type\t%s\t%s%s\n", intchanged, extchanged, linktype, (SideDoor[doorid][SD_LinkType] == PlayerSideDoor[playerid][SD_LinkType]) ? ("{31CC3E}") : ("{E83838}"), plinktype);
	format(string, sizeof(string), "%sID / Name\t%s\t%s%s\n", string, SideDoor[doorid][SD_BelongsTo], (!strcmp(PlayerSideDoor[playerid][SD_BelongsTo], SideDoor[doorid][SD_BelongsTo], true)) ? ("{31CC3E}") : ("{E83838}"), PlayerSideDoor[playerid][SD_BelongsTo]);
	format(string, sizeof(string), "%sLock\t%d\t%s%d\n", string, SideDoor[doorid][SD_Lock], (PlayerSideDoor[playerid][SD_Lock] == SideDoor[doorid][SD_Lock]) ? ("{31CC3E}") : ("{E83838}"), PlayerSideDoor[playerid][SD_Lock]);
	format(string, sizeof(string), "%sCode\t%d\t%s%d\n{E3CF3B}SAVE", string, SideDoor[doorid][SD_Code], (PlayerSideDoor[playerid][SD_Code] == SideDoor[doorid][SD_Code]) ? ("{31CC3E}") : ("{E83838}"), PlayerSideDoor[playerid][SD_Code]);
	
	return string;
}	

// END FUNCTIONS

// START COMMANDS

CMD:createsidedoor(playerid, params[]) return cmd_createsd(playerid, params);
CMD:createsd(playerid, params[])
{
	if(!IsAdmin(playerid))
		return 1;
		
	new set[10], linktype, idname[25];
	if(sscanf(params, "s[10]D(-1)S(-1)[25]", set, linktype, idname))
	{
		SendClientMessage(playerid, GREY, "SYNTAX: /creates(ide)d(oor) [interior/exterior/complete] ([linktype] [id/name])");
		return SendClientMessage(playerid, GREY, "Linktypes: House - 1, Business - 2, Group - 3, Gang - 4, Player - 5");
	}
	
	if(!strcmp(set, "interior", true))
	{
		PlayerSideDoor[playerid][SD_IntVW] = GetPlayerVirtualWorld(playerid), PlayerSideDoor[playerid][SD_IntInt] = GetPlayerInterior(playerid);
		GetPlayerPos(playerid, PlayerSideDoor[playerid][SD_IntX], PlayerSideDoor[playerid][SD_IntY], PlayerSideDoor[playerid][SD_IntZ]);
		
		SendClientMessage(playerid, WHITE, "You've set the coordinates for the interior.");
	}
	else if(!strcmp(set, "exterior", true))
	{
		PlayerSideDoor[playerid][SD_ExtVW] = GetPlayerVirtualWorld(playerid), PlayerSideDoor[playerid][SD_ExtInt] = GetPlayerInterior(playerid);
		GetPlayerPos(playerid, PlayerSideDoor[playerid][SD_ExtX], PlayerSideDoor[playerid][SD_ExtY], PlayerSideDoor[playerid][SD_ExtZ]);
		
		SendClientMessage(playerid, WHITE, "You've set the coordinates for the exterior.");
	}
	else if(!strcmp(set, "complete", true))
	{
		if(linktype == -1 || strval(idname) == -1)
			return SendClientMessage(playerid, GREY, "Error, invalid linktype or id/name.");
		
		if(linktype < 1 || linktype > 5)
			return SendClientMessage(playerid, GREY, "Error, invalid linktype. (1  - 5)");
		
		if(!IsPlayerRegistered(idname) && linktype == SD_TYPE_PLAYER)
			return SendClientMessage(playerid, GREY, "Error, that player is not registered.");
			
		format(PlayerSideDoor[playerid][SD_BelongsTo], 25, idname);
		PlayerSideDoor[playerid][SD_LinkType] = linktype;
		PlayerSideDoor[playerid][SD_Lock] = 1;
		PlayerSideDoor[playerid][SD_Code] = -1;
		
		new freeid = Iter_Free(SideDoors);
		if(freeid == -1)
			return SendClientMessage(playerid, GREY, "Error, no more valid slots. Remove unwanted sidedoors or increase MAX_SIDEDOORS in the script.");
			
		Iter_Add(SideDoors, freeid);
		SideDoor[freeid] = PlayerSideDoor[playerid];
		new label[20];
		format(label, sizeof(label), "Door %d", freeid);
		SideDoor[freeid][SD_Label] = CreateDynamic3DTextLabel(label, 0xF2B629AA, SideDoor[freeid][SD_ExtX], SideDoor[freeid][SD_ExtY], SideDoor[freeid][SD_ExtZ], 2.0, .worldid = SideDoor[freeid][SD_ExtVW], .interiorid = SideDoor[freeid][SD_ExtInt]);
		SaveDoor(freeid, 1);
		Streamer_Update(playerid);
		
		SetPlayerPos(playerid, SideDoor[freeid][SD_ExtX], SideDoor[freeid][SD_ExtY], SideDoor[freeid][SD_ExtZ]);
		SetPlayerVirtualWorld(playerid, SideDoor[freeid][SD_ExtVW]);
		SetPlayerInterior(playerid, SideDoor[freeid][SD_ExtInt]);
		SendClientMessage(playerid, WHITE, "Side door created!");
	}
	else
	{
		SendClientMessage(playerid, GREY, "SYNTAX: /creates(ide)d(oor) [interior/exterior/complete] ([linktype] [id/name])");
		return SendClientMessage(playerid, GREY, "Linktypes: House - 1, Business - 2, Group - 3, Gang - 4, Player - 5");
	}
	return 1;
}

CMD:locksidedoor(playerid, params[]) return cmd_locksd(playerid, params);
CMD:locksd(playerid, params[])
{
	new doorid = GetNearestDoor(playerid), can_use = 0;
	
	if(doorid == -1)
		return SendClientMessage(playerid, GREY, "Error, you are not near any doors.");
	
	if(isnull(params))
		can_use = DoorAccess(playerid, doorid);
	else
		can_use = DoorAccess(playerid, doorid, strval(params));
		
	if(!can_use)
		return SendClientMessage(playerid, WHITE, "You do not have access to this door.");
		
	SideDoor[doorid][SD_Lock] = !SideDoor[doorid][SD_Lock];
	SaveDoor(doorid);
		
	new string[128];
	format(string, sizeof(string), "* %s has %s the door.", GetNameEx(playerid), (SideDoor[doorid][SD_Lock]) ? ("locked") : ("unlocked"));
	NearByMessage(playerid, NICESKY, string);
	return 1;
}

CMD:sidedoorcode(playerid, params[]) return cmd_sdcode(playerid, params);
CMD:sdcode(playerid, params[])
{
	new doorid = GetNearestDoor(playerid);
	
	if(doorid == -1)
		return SendClientMessage(playerid, GREY, "Error, you are not near any doors.");
	
	if(!DoorAccess(playerid, doorid))
		return SendClientMessage(playerid, GREY, "Error, you don't have access to this door.");
	
	if(isnull(params) || (!IsNumeric(params) && strval(params) != -1))
		return SendClientMessage(playerid, GREY, "SYNTAX: /s(ide)d(oor)code [code]");
		
	if((strval(params) <= 999 || strval(params) > 99999) && strval(params) != -1)
		return SendClientMessage(playerid, GREY, "The code can only be 4 or 5 digits long.");
		
	SideDoor[doorid][SD_Code] = strval(params);
	SendClientMessage(playerid, WHITE, "You successfully changed the doors code. (NOTE: You can remove the code by setting it to -1)");
	SaveDoor(doorid);
	return 1;
}

CMD:editsidedoor(playerid, params[]) return cmd_editsd(playerid, params);
CMD:editsd(playerid, params[])
{
	if(!IsAdmin(playerid))
		return 1;
		
	if(isnull(params))
		return SendClientMessage(playerid, GREY, "SYNTAX: /edits(ide)d(oor) [doorid]");
		
	new doorid = strval(params);
	if(Iter_Contains(SideDoors, doorid) == 0)
		return SendClientMessage(playerid, GREY, "Error, that door does not exist.");
	
	PlayerSideDoor[playerid] = SideDoor[doorid];
	SetPVarInt(playerid, "SD_EDITING", doorid);
	ShowPlayerDialog(playerid, SIDEDOOR_MAIN, DIALOG_STYLE_TABLIST, "Side Door Edit", SideDoorEditString(playerid, doorid), "Select", "Close");
	
	return 1;
}

CMD:gotosidedoor(playerid, params[]) return cmd_gotosd(playerid, params);
CMD:gotosd(playerid, params[])
{
	if(!IsAdmin(playerid))
		return 1;
		
	if(isnull(params))
		return SendClientMessage(playerid, GREY, "SYNTAX: /gotos(ide)d(oor) [doorid]");
		
	new doorid = strval(params);
	if(Iter_Contains(SideDoors, doorid) == 0)
		return SendClientMessage(playerid, GREY, "Error, that door does not exist.");
		
	SetPlayerPos(playerid, SideDoor[doorid][SD_ExtX], SideDoor[doorid][SD_ExtY], SideDoor[doorid][SD_ExtZ]);
	SetPlayerVirtualWorld(playerid, SideDoor[doorid][SD_ExtVW]);
	SetPlayerInterior(playerid, SideDoor[doorid][SD_ExtInt]);
	return 1;
}
CMD:deletesidedoor(playerid, params[]) return cmd_deletesd(playerid, params);
CMD:deletesd(playerid, params[])
{
	if(!IsAdmin(playerid))
		return 1;
	
	if(isnull(params) || !IsNumeric(params))
		return SendClientMessage(playerid, GREY, "SYNTAX: /deletes(ide)d(oor) [doorid]");
	
	new doorid = strval(params);
	
	if(Iter_Contains(SideDoors, doorid) == 0)
		return SendClientMessage(playerid, GREY, "Error, door does not exist.");
	
	if(IsValidDynamic3DTextLabel(SideDoor[doorid][SD_Label]))
		DestroyDynamic3DTextLabel(SideDoor[doorid][SD_Label]);
		
	SideDoor[doorid] = empty;
						
	new string[45];

	mysql_format(MYSQL_MAIN, string, sizeof(string), "DELETE FROM sidedoors WHERE DoorID = %d", doorid);
	mysql_query(MYSQL_MAIN, string, false);
						
	format(string, sizeof(string), "You have deleted side door %d!", doorid);
	SendClientMessage(playerid, WHITE, string);
	return 1;
}

CMD:helpsidedoor(playerid) return cmd_sdhelp(playerid);
CMD:helpsd(playerid) return cmd_sdhelp(playerid);
CMD:sidedoorhelp(playerid) return cmd_sdhelp(playerid);
CMD:sdhelp(playerid)
{
	SendClientMessage(playerid, WHITE, "");
	SendClientMessage(playerid, WHITE, "----------------- Side Door Commands -----------------");
	SendClientMessage(playerid, WHITE, "/locksidedoor /sidedoorcode");
	if(IsAdmin(playerid))
		SendClientMessage(playerid, WHITE, "/createsidedoor /editsidedoor /gotosidedoor /deletesidedoor");
	SendClientMessage(playerid, WHITE, "------------------------------------------------------");
	SendClientMessage(playerid, WHITE, "");
	return 1;
}
// END COMMANDS
