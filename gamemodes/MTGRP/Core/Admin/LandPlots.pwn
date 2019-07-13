/*
#		MTG Land Plots
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
#include <YSI\y_iterate>
#include <YSI\y_hooks>

// defines
#define MAX_LAND 100
#define OBJECT_LAND_SIGN 19471

// dialogs
#define EDITLAND_MAIN 	5932
#define EDITLAND_OWNER 	5933
#define EDITLAND_PRICE 	5934

enum LandData
{
	LandSQL,
	LandOwner[25],
	LandArea,
	LandPrice,
	LandForSale,
	Float:LandX1,
	Float:LandY1,
	Float:LandX2,
	Float:LandY2,
	Float:LandSignX,
	Float:LandSignY,
	Float:LandSignZ,
	Float:LandSignA,
	LandSign,
	Text3D:LandText,
	
	Corner1Icon[MAX_PLAYERS],
	Corner2Icon[MAX_PLAYERS],
	Corner3Icon[MAX_PLAYERS],
	Corner4Icon[MAX_PLAYERS],
}

new Land[MAX_LAND][LandData];
new Iterator:Land<MAX_LAND>;

new Float:pos_[MAX_PLAYERS][8], icons_[MAX_PLAYERS], objects_[MAX_PLAYERS][4], DB:mtg_db;

// hook OnPlayerSpawn(playerid)
// {
	// for(new i; i < 9; i++)
	// {
		// pos_[playerid][i] = 0.00;
	// }
	
	// icons_[playerid] = 0;
	
	// SendClientMessage(playerid, -1, "Spawned LandPlots.pwn");
// }

hook OnGameModeInit()
{
	print("LandPlots.pwn OnGameModeInit() called.");

	mtg_db = db_open("MTG.db");

	// db_query(mtg_db, "CREATE TABLE IF NOT EXISTS land (sqlid INTEGER PRIMARY KEY AUTOINCREMENT, owner TEXT DEFAULT Nobody, x1 INTEGER DEFAULT 0.0, y1 FLOAT DEFAULT 0.0, x2 FLOAT DEFAULT 0.0, y2 FLOAT DEFAULT 0.0, signx FLOAT DEFAULT 0.0, signy FLOAT DEFAULT 0.0, signz FLOAT DEFAULT 0.0, signa FLOAT DEFAULT 0.0, forsale INTEGER DEFAULT 0, price INTEGER DEFAULT 0)");
	
	new DBResult:result, count, field[25], id = 1;
	result = db_query(mtg_db, "SELECT * FROM land");
	count = db_num_rows(result);
	printf("count = %d", count);
	
	while(count != 0)
	{
		db_get_field_assoc(result, "sqlid", field, 25);
		Land[id][LandSQL] = strval(field);
		
		db_get_field_assoc(result, "owner", Land[id][LandOwner], 25);
		
		db_get_field_assoc(result, "x1", field, 25);
		Land[id][LandX1] = floatstr(field);
		
		db_get_field_assoc(result, "y1", field, 25);
		Land[id][LandY1] = floatstr(field);
		
		db_get_field_assoc(result, "x2", field, 25);
		Land[id][LandX2] = floatstr(field);
		
		db_get_field_assoc(result, "y2", field, 25);
		Land[id][LandY2] = floatstr(field);
		
		db_get_field_assoc(result, "signx", field, 25);
		Land[id][LandSignX] = floatstr(field);
		
		db_get_field_assoc(result, "signy", field, 25);
		Land[id][LandSignY] = floatstr(field);
		
		db_get_field_assoc(result, "signz", field, 25);
		Land[id][LandSignZ] = floatstr(field);
		
		db_get_field_assoc(result, "signa", field, 25);
		Land[id][LandSignA] = floatstr(field);
		
		db_get_field_assoc(result, "forsale", field, 25);
		Land[id][LandForSale] = strval(field);
		
		db_get_field_assoc(result, "price", field, 25);
		Land[id][LandPrice] = strval(field);
		
		db_next_row(result);

		Land[id][LandArea] = CreateDynamicRectangle(Land[id][LandX1], Land[id][LandY1], Land[id][LandX2], Land[id][LandY2]);
		
		new string[128];
		
		format(string, sizeof(string), "%s", PrettyMoney(Land[id][LandPrice]));
		format(string, sizeof(string), "~ Land %d ~\nPrice: %s", id, (Land[id][LandPrice] < 1) ? ("Not for sale") : (string));
		Land[id][LandText] = CreateDynamic3DTextLabel(string, YELLOW, Land[id][LandSignX], Land[id][LandSignY], Land[id][LandSignZ], 10.0);
		if(Land[id][LandPrice] > 0)
			Land[id][LandSign] = CreateDynamicObject(OBJECT_LAND_SIGN, Land[id][LandSignX], Land[id][LandSignY], Land[id][LandSignZ], 0, 0, Land[id][LandSignA]);
			
		Add(id);
		
		count--;
		id++;
		printf("id %d sqlid %d owner %s x1 %f y1 %f x2 %f y2 %f signx %f signy %f signz %f signa %f forsale %d price %d", id, Land[id][LandSQL], Land[id][LandOwner], Land[id][LandX1], Land[id][LandY1], Land[id][LandX2], Land[id][LandY2], Land[id][LandSignX], Land[id][LandSignY], Land[id][LandSignZ], Land[id][LandSignA], Land[id][LandForSale], Land[id][LandPrice]);
	}
	
	db_free_result(result);
	
	printf("[LandPlots] Land loaded. Total: %d", id - 1);
}

static stock Add(id) return Iter_Add(Land, id);
static stock Remove(id) return Iter_Remove(Land, id);
static stock GetAvailableID() return Iter_Free(Land);
static stock DoesLandExist(id) return Iter_Contains(Land, id);

static stock IsPlayerInLand(playerid, id = -1)
{
	if(id > -1)
	{
		if(!DoesLandExist(id))
			return -1;
	
		if(IsPlayerInDynamicArea(playerid, Land[id][LandArea]))
			return 1;
	}
	else
	{
		foreach(new i : Land)
		{
			if(IsPlayerInDynamicArea(playerid, Land[i][LandArea]))
				return i;
		}
	}
	return -1;
}

CMD:buyland(playerid)
{
	if(Player[playerid][LandOwned])
		return SendClientMessage(playerid, -1, "You can only own one area of land.");
		
	new landid = IsPlayerInLand(playerid);
	
	if(landid == -1 || IsPlayerInRangeOfPoint(playerid, 3.0, Land[landid][LandSignX], Land[landid][LandSignY], Land[landid][LandSignZ]))
		return SendClientMessage(playerid, -1, "You must be standing at the for sale sign in an area of land for sale.");
		
	if(Land[landid][LandPrice] < 1)
		return SendClientMessage(playerid, -1, "This land is not for sale.");
		
	if(Player[playerid][Money] < Land[landid][LandPrice])
		return SendClientMessage(playerid, -1, "You do not have enough money with you to buy this land!");
		
	Player[playerid][Money] -= Land[landid][LandPrice];
	Player[playerid][LandOwned] = landid;
	format(Land[landid][LandOwner], 25, "%s", GetName(playerid));
	
	DestroyDynamic3DTextLabel(Land[landid][LandText]);
	DestroyDynamicObject(Land[landid][LandSign]);
	
	SendClientMessage(playerid, YELLOW, "You have successfully bought this area land!");

	return 1;
}

CMD:gotoland(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
		
	new id = strval(params);
	
	if(id < 0 || id > MAX_LAND - 1 || isnull(params) || !IsNumeric(params))
		return SendClientMessage(playerid, GREY, "SYNTAX: /gotoland [landid]");
		
	SetPlayerPos(playerid, Land[id][LandSignX], Land[id][LandSignY], Land[id][LandSignZ]);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerInterior(playerid, 0);
	
	new string[128];
	format(string, sizeof(string), "You have teleported to land %d.", id);
	SendClientMessage(playerid, -1, string);
	return 1;
}

CMD:createland(playerid, params[])// params - corner1, corner2, sign, complete
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
	
	new Float:x, Float:y, Float:z;
	// 19121
	if(!strcmp(params, "corner1", true))
	{
		GetPlayerPos(playerid, x, y, z);
		pos_[playerid][0] = x;
		pos_[playerid][1] = y;
		
		if(IsValidDynamicObject(objects_[playerid][0]))
			DestroyDynamicObject(objects_[playerid][0]);
		objects_[playerid][0] = CreateDynamicObject(19121, x, y, z, 0, 0, 0, .playerid = playerid);
		
		if(pos_[playerid][2] == 0.00 && pos_[playerid][3] == 0.00)
			SendClientMessage(playerid, -1, "Now set the position of corner2!");
		else
		{
			// if(IsValidDynamicObject(objects_[playerid][1]))
				// DestroyDynamicObject(objects_[playerid][1]);
			// objects_[playerid][1] = CreateDynamicObject(19121, pos_[playerid][2], pos_[playerid][3], z, 0, 0, 0, .playerid = playerid);
			
			if(IsValidDynamicObject(objects_[playerid][2]))
				DestroyDynamicObject(objects_[playerid][2]);
			objects_[playerid][2] = CreateDynamicObject(19121, pos_[playerid][0], pos_[playerid][3], z, 0, 0, 0, .playerid = playerid);
			
			if(IsValidDynamicObject(objects_[playerid][3]))
				DestroyDynamicObject(objects_[playerid][3]);
			objects_[playerid][3] = CreateDynamicObject(19121, pos_[playerid][2], pos_[playerid][1], z, 0, 0, 0, .playerid = playerid);
		
			SendClientMessage(playerid, -1, "If you have already set the position of corner2, now set the for sale sign position.");
		}
	}
	else if(!strcmp(params, "corner2", true))
	{
		GetPlayerPos(playerid, x, y, z);
		pos_[playerid][2] = x;
		pos_[playerid][3] = y;
		
		if(IsValidDynamicObject(objects_[playerid][1]))
			DestroyDynamicObject(objects_[playerid][1]);
		objects_[playerid][1] = CreateDynamicObject(19121, x, y, z, 0, 0, 0, .playerid = playerid);
		
		if(pos_[playerid][0] == 0.00 && pos_[playerid][1] == 0.00)
			SendClientMessage(playerid, -1, "Now set the position of corner1!");
		else
		{
			// if(IsValidDynamicObject(objects_[playerid][0]))
				// DestroyDynamicObject(objects_[playerid][0]);
			// objects_[playerid][0] = CreateDynamicObject(19121, pos_[playerid][2], pos_[playerid][3], z, 0, 0, 0, .playerid = playerid);
			
			if(IsValidDynamicObject(objects_[playerid][2]))
				DestroyDynamicObject(objects_[playerid][2]);
			objects_[playerid][2] = CreateDynamicObject(19121, pos_[playerid][0], pos_[playerid][3], z, 0, 0, 0, .playerid = playerid);
			
			if(IsValidDynamicObject(objects_[playerid][3]))
				DestroyDynamicObject(objects_[playerid][3]);
			objects_[playerid][3] = CreateDynamicObject(19121, pos_[playerid][2], pos_[playerid][1], z, 0, 0, 0, .playerid = playerid);
			
			SendClientMessage(playerid, -1, "If you have already set the position of corner1, now set the for sale sign position.");
		}
	}
	else if(!strcmp(params, "sign", true))
	{
		if(pos_[playerid][0] == 0.00 && pos_[playerid][1] == 0.00)
			return SendClientMessage(playerid, -1, "You need to set the position of corner1 before the for sale sign!");
			
		if(pos_[playerid][2] == 0.00 && pos_[playerid][3] == 0.00)
			return SendClientMessage(playerid, -1, "You need to set the position of corner2 before the for sale sign!");
		
		GetPlayerPos(playerid, x, y, z);
		
		if(pos_[playerid][0] > pos_[playerid][2])
		{
			if(x > pos_[playerid][0] || x < pos_[playerid][2])
				return SendClientMessage(playerid, GREY, "The for sale sign must be positioned inside of the land you area creating.");
				
			if(pos_[playerid][1] > pos_[playerid][3])
			{
				if(y > pos_[playerid][1] || y < pos_[playerid][3])
					return SendClientMessage(playerid, GREY, "The for sale sign must be positioned inside of the land you area creating.");
			}
			else
			{
				if(y < pos_[playerid][1] || y > pos_[playerid][3])
					return SendClientMessage(playerid, GREY, "The for sale sign must be positioned inside of the land you area creating.");
			}
		}
		else
		{
			if(x > pos_[playerid][2] || x < pos_[playerid][0])
				return SendClientMessage(playerid, GREY, "The for sale sign must be positioned inside of the land you area creating.");
		
			if(pos_[playerid][1] > pos_[playerid][3])
			{
				if(y > pos_[playerid][1] || y < pos_[playerid][3])
					return SendClientMessage(playerid, GREY, "The for sale sign must be positioned inside of the land you area creating.");
			}
			else
			{
				if(y < pos_[playerid][1] || y > pos_[playerid][3])
					return SendClientMessage(playerid, GREY, "The for sale sign must be positioned inside of the land you area creating.");
			}
		}
		
		pos_[playerid][4] = x;
		pos_[playerid][5] = y;
		pos_[playerid][6] = z;
		
		SendClientMessage(playerid, -1, "Great, you've set the position of the for sale sign! Now complete the land creation with \"/createland complete\"");
	}
	else if(!strcmp(params, "complete", true))
	{
		new id = GetAvailableID();
		
		if(id == -1)
			return SendClientMessage(playerid, -1, "No more land can be created at this time. Ask to raise land limit or delete another.");
			
		Land[id][LandX1] = pos_[playerid][0];
		Land[id][LandY1] = pos_[playerid][1];
		Land[id][LandX2] = pos_[playerid][2];
		Land[id][LandY2] = pos_[playerid][3];
		Land[id][LandSignX] = pos_[playerid][4];
		Land[id][LandSignY] = pos_[playerid][5];
		Land[id][LandSignZ] = pos_[playerid][6];
		Land[id][LandSignA] = pos_[playerid][7];
		
		pos_[playerid][0] = 0.00;
		pos_[playerid][1] = 0.00;
		pos_[playerid][2] = 0.00;
		pos_[playerid][3] = 0.00;
		pos_[playerid][4] = 0.00;
		pos_[playerid][5] = 0.00;
		pos_[playerid][6] = 0.00;
		pos_[playerid][7] = 0.00;
		
		DestroyDynamicObject(objects_[playerid][0]);
		DestroyDynamicObject(objects_[playerid][1]);
		DestroyDynamicObject(objects_[playerid][2]);
		DestroyDynamicObject(objects_[playerid][3]);
		
		format(Land[id][LandOwner], 25, "Nobody");
		Land[id][LandPrice] = -1;
		Land[id][LandForSale] = 0;
		
		Land[id][LandArea] = CreateDynamicRectangle(Land[id][LandX1], Land[id][LandY1], Land[id][LandX2], Land[id][LandY2]);
		
		Add(id);
		
		new string[255];
		
		format(string, sizeof(string), "~ Land %d ~\nPrice: %s", id, (Land[id][LandPrice] < 1) ? ("Not for sale") : (PrettyMoney(Land[id][LandPrice])));
		Land[id][LandText] = CreateDynamic3DTextLabel(string, YELLOW, Land[id][LandSignX], Land[id][LandSignY], Land[id][LandSignZ], 10.0);
		if(Land[id][LandPrice] > 0)
			Land[id][LandSign] = CreateDynamicObject(19471, Land[id][LandSignX], Land[id][LandSignY], Land[id][LandSignZ], 0.00, 0.00, Land[id][LandSignA]);
		
		format(string, sizeof(string), "You have created an area of land! It's ID is %d.", id);
		SendClientMessage(playerid, -1, string);
		
		new DBResult:result = db_query(mtg_db, "SELECT sqlid FROM land");
		Land[id][LandSQL] = db_num_rows(result) + 1;
		db_free_result(result);

		format(string, sizeof(string), "INSERT INTO `land` (sqlid, owner, x1, y1, x2, y2, signx, signy, signz, signa, forsale, price) VALUES ('%d', '%s', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%d', '%d')", Land[id][LandSQL], Land[id][LandOwner], Land[id][LandX1], Land[id][LandY1], Land[id][LandX2], Land[id][LandY2], Land[id][LandSignX], Land[id][LandSignY], Land[id][LandSignZ], Land[id][LandSignA], Land[id][LandForSale], Land[id][LandPrice]);
		db_query(mtg_db, string);
	}
	else
	{
		SendClientMessage(playerid, GREY, "SYNTAX: /createland [option]");
		SendClientMessage(playerid, GREY, "Option: corner1, corner2, sign, complete");
		return SendClientMessage(playerid, RED, "!! Set both corner positions, then the sign (where people will /buyland, then complete. !!");
	}
	return 1;
}

CMD:listland(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
		
	new string[128], val = strval(params);
	
	if(!IsNumeric(params) || isnull(params))
		val = -1;
	
	if(val != -1)
	{
		SendClientMessage(playerid, GREY, "---------------------------------------------------");
		format(string, sizeof(string), "Land %d || Owner: %s - Price: %s - For Sale: %s", val, Land[val][LandOwner], Land[val][LandPrice], Land[val][LandForSale]);
		SendClientMessage(playerid, -1, string);
		SendClientMessage(playerid, GREY, "---------------------------------------------------");
		return 1;
	}
	
	SendClientMessage(playerid, GREY, "-------------- CURRENT EXISTING LAND --------------");
	foreach(new i :Land)
	{
		if(!DoesLandExist(i))
			continue;
			
		format(string, sizeof(string), "Land %d || Owner: %s - Price: %s - For Sale: %s", i, Land[i][LandOwner], Land[i][LandPrice], Land[i][LandForSale]);
		SendClientMessage(playerid, -1, string);
	}
	SendClientMessage(playerid, GREY, "---------------------------------------------------");
	return 1;
}

CMD:landicons(playerid)
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
		
	if(icons_[playerid] == 0)
	{
		icons_[playerid] = 1;
		SendClientMessage(playerid, -1, "You toggled land icons on, they will turn green if you are within the land area.");
		
		foreach(new i : Land)
		{
			if(!DoesLandExist(i))
				continue;
				
			// CreateDynamicMapIcon(Float:x, Float:y, Float:z, type, color, worldid = -1, interiorid = -1, playerid = -1, Float:streamdistance = 100.0, style = MAPICON_LOCAL);
			Land[i][Corner1Icon][playerid] = CreateDynamicMapIcon(Land[i][LandX1], Land[i][LandY1], 0, 0, (IsPlayerInLand(playerid, i) >= 0) ? GREEN : RED, .playerid = playerid, .streamdistance = 5000.0);
			Land[i][Corner2Icon][playerid] = CreateDynamicMapIcon(Land[i][LandX2], Land[i][LandY2], 0, 0, (IsPlayerInLand(playerid, i) >= 0) ? GREEN : RED, .playerid = playerid, .streamdistance = 5000.0);
			Land[i][Corner3Icon][playerid] = CreateDynamicMapIcon(Land[i][LandX1], Land[i][LandY2], 0, 0, (IsPlayerInLand(playerid, i) >= 0) ? GREEN : RED, .playerid = playerid, .streamdistance = 5000.0);
			Land[i][Corner4Icon][playerid] = CreateDynamicMapIcon(Land[i][LandX2], Land[i][LandY1], 0, 0, (IsPlayerInLand(playerid, i) >= 0) ? GREEN : RED, .playerid = playerid, .streamdistance = 5000.0);
		}
	}
	else
	{
		icons_[playerid] = 0;
		SendClientMessage(playerid, -1, "You toggled land icons off.");
		
		foreach(new i : Land)
		{
			if(!DoesLandExist(i))
				continue;
				
			DestroyDynamicMapIcon(Land[i][Corner1Icon][playerid]);
			DestroyDynamicMapIcon(Land[i][Corner2Icon][playerid]);
			DestroyDynamicMapIcon(Land[i][Corner3Icon][playerid]);
			DestroyDynamicMapIcon(Land[i][Corner4Icon][playerid]);
		}
	}
	return 1;
}

CMD:editland(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;

	new id = strval(params);
	
	if(isnull(params))	
		id = IsPlayerInLand(playerid);
		
	if(!DoesLandExist(id))
		return SendClientMessage(playerid, -1, "There is no such land with that ID.");
		
	SetPVarInt(playerid, "EditLand_ID", id + 1);
	
	new string[128];
	format(string, sizeof(string), "Owner: %s\nPrice: %s\nFor Sale: %s\nSign Pos\n", Land[id][LandOwner], PrettyMoney(Land[id][LandPrice]), (Land[id][LandForSale]) ? ("Yes") : ("No"));
	
	ShowPlayerDialog(playerid, EDITLAND_MAIN, DIALOG_STYLE_LIST, "Edit Land", string, "Edit", "Close");
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case EDITLAND_MAIN:
		{
			new id = GetPVarInt(playerid, "EditLand_ID") - 1;
			if(!DoesLandExist(id))
				return SendClientMessage(playerid, -1, "The land you are/were editting no longer exists.");
		
			switch(listitem)
			{
				case 0: ShowPlayerDialog(playerid, EDITLAND_OWNER, DIALOG_STYLE_INPUT, "Edit Land Owner", "Change owner of land.\nPut \"REMOVE\" to remove land from current owner (CaSe SeNsItIvE)", "Change", "Close");
				case 1: ShowPlayerDialog(playerid, EDITLAND_PRICE, DIALOG_STYLE_INPUT, "Edit Land Price", "Enter the price you wish to set this land at.\n($0 will make it not for sale if unowned)", "Change", "Close");
				case 2: 
				{
					Land[id][LandForSale] = (Land[id][LandForSale] == 0) ? (1) : (0);
					if(Land[id][LandPrice] > 0)
					{
						if(Land[id][LandForSale])
							Land[id][LandSign] = CreateDynamicObject(OBJECT_LAND_SIGN, Land[id][LandSignX], Land[id][LandSignY], Land[id][LandSignZ], 0, 0, Land[id][LandSignA]);
					}
					else
					{
						if(IsValidDynamicObject(Land[id][LandSign]) && Land[id][LandForSale] == 0)
							DestroyDynamicObject(Land[id][LandSign]);
					}
				}
				case 3: 
				{	
					new Float:x, Float:y, Float:z, Float:a;
					GetPlayerPos(playerid, x, y, z);
					GetPlayerFacingAngle(playerid, a);
					
					SetDynamicObjectPos(Land[id][LandSign], x, y, z);
					SetDynamicObjectRot(Land[id][LandSign], 0, 0, a);
				}
			}
		}
		case EDITLAND_OWNER:
		{
			new id = GetPVarInt(playerid, "EditLand_ID") - 1;
			if(!DoesLandExist(id))
				return SendClientMessage(playerid, -1, "The land you are/were editting no longer exists.");
			
			new string[128];
			if(!strcmp(inputtext, "REMOVE", false))
			{
				format(string, sizeof(string), "You have removed land %d from %s.", id, Land[id][LandOwner]);
				SendClientMessage(playerid, -1, string);
				format(string, sizeof(string), "[Land] %s has removed land %d from %s.", Player[playerid][AdminName], id, Land[id][LandOwner]);
				AdminActionsLog(string);
				
				new ownerid = GetPlayerIDEx(Land[id][LandOwner]);
				if(IsPlayerConnected(ownerid))
				{
					Player[ownerid][LandOwned] = 0;
				}
				else
				{
					new tmpstr[128];
					format(tmpstr, sizeof(tmpstr), "Accounts/%s.ini", Land[id][LandOwner]);

					if(!fexist(tmpstr))
						return SendClientMessage(playerid, -1, "That account doesn't exist.");
				
					ResetTempPlayer(playerid); 
					INI_ParseFile(tmpstr, "LoadTempPlayerData", .bExtra = true, .extra = playerid, .bPassTag = true);
					YiniWriteDini_Int(playerid, tmpstr, "LandOwned", 0);
					ResetTempPlayer(playerid);
				}
				format(Land[id][LandOwner], 25, "Nobody");
			}
			else
			{
				new newid = GetPlayerIDEx(inputtext);
				if(IsPlayerConnected(newid))
				{
					Player[newid][LandOwned] = id;
				}
				else
				{
					new tmpstr[128];
					format(tmpstr, sizeof(tmpstr), "Accounts/%s.ini", inputtext);

					if(!fexist(tmpstr))
						return SendClientMessage(playerid, -1, "That account doesn't exist.");
				
					ResetTempPlayer(playerid); 
					INI_ParseFile(tmpstr, "LoadTempPlayerData", .bExtra = true, .extra = playerid, .bPassTag = true);
					YiniWriteDini_Int(playerid, tmpstr, "LandOwned", id);
					ResetTempPlayer(playerid);
				}
				format(Land[id][LandOwner], 25, inputtext);
				Land[id][LandForSale] = 0;
			}
		}
		case EDITLAND_PRICE:
		{
			new id = GetPVarInt(playerid, "EditLand_ID") - 1;
			if(!DoesLandExist(id))
				return SendClientMessage(playerid, -1, "The land you are/were editting no longer exists.");
			
			if(!IsNumeric(inputtext) || isnull(inputtext) || strval(inputtext) < 0)
				return ShowPlayerDialog(playerid, EDITLAND_PRICE, DIALOG_STYLE_INPUT, "Edit Land Price", "{FF0000}You can't have a negative price!\n{FFFFFF}Enter the price you wish to set this land at.\n($0 will make it not for sale if unowned)", "Change", "Close");
				
			new string[128];
			format(string, sizeof(string), "You have set the price of land %d to %s (was %s).", id, PrettyMoney(strval(inputtext)), PrettyMoney(Land[id][LandPrice]));
			SendClientMessage(playerid, -1, string);
			format(string, sizeof(string), "[Land] %s has set land %d price to %s (was %s).", Player[playerid][AdminName], id, strval(inputtext), Land[id][LandPrice]);
			AdminActionsLog(string);
			
			Land[id][LandPrice] = strval(inputtext);
		}
	}
	return 1;
}

ptask Refresh[5000](i)
{
	if(Player[i][AdminLevel] > 5 && icons_[i] == 1)
	{
		foreach(new l : Land)
		{
			if(IsPlayerInLand(i, l) >= 0)
			{
				if(IsValidDynamicMapIcon(Land[l][Corner1Icon][i]))
					DestroyDynamicMapIcon(Land[l][Corner1Icon][i]);
				Land[l][Corner1Icon][i] = CreateDynamicMapIcon(Land[l][LandX1], Land[l][LandY1], 0, 0, GREEN, .playerid = i, .streamdistance = 5000.0);
				
				if(IsValidDynamicMapIcon(Land[l][Corner2Icon][i]))
					DestroyDynamicMapIcon(Land[l][Corner2Icon][i]);
				Land[l][Corner2Icon][i] = CreateDynamicMapIcon(Land[l][LandX2], Land[l][LandY2], 0, 0, GREEN, .playerid = i, .streamdistance = 5000.0);
				
				if(IsValidDynamicMapIcon(Land[l][Corner3Icon][i]))
					DestroyDynamicMapIcon(Land[l][Corner3Icon][i]);
				Land[l][Corner3Icon][i] = CreateDynamicMapIcon(Land[l][LandX1], Land[l][LandY2], 0, 0, GREEN, .playerid = i, .streamdistance = 5000.0);
				
				if(IsValidDynamicMapIcon(Land[l][Corner4Icon][i]))
					DestroyDynamicMapIcon(Land[l][Corner4Icon][i]);
				Land[l][Corner4Icon][i] = CreateDynamicMapIcon(Land[l][LandX2], Land[l][LandY1], 0, 0, GREEN, .playerid = i, .streamdistance = 5000.0);
			}
			else
			{
				if(IsValidDynamicMapIcon(Land[l][Corner1Icon][i]))
					DestroyDynamicMapIcon(Land[l][Corner1Icon][i]);
				Land[l][Corner1Icon][i] = CreateDynamicMapIcon(Land[l][LandX1], Land[l][LandY1], 0, 0, RED, .playerid = i, .streamdistance = 5000.0);
				
				if(IsValidDynamicMapIcon(Land[l][Corner2Icon][i]))
					DestroyDynamicMapIcon(Land[l][Corner2Icon][i]);
				Land[l][Corner2Icon][i] = CreateDynamicMapIcon(Land[l][LandX2], Land[l][LandY2], 0, 0, RED, .playerid = i, .streamdistance = 5000.0);
				
				if(IsValidDynamicMapIcon(Land[l][Corner3Icon][i]))
					DestroyDynamicMapIcon(Land[l][Corner3Icon][i]);
				Land[l][Corner3Icon][i] = CreateDynamicMapIcon(Land[l][LandX1], Land[l][LandY2], 0, 0, RED, .playerid = i, .streamdistance = 5000.0);
				
				if(IsValidDynamicMapIcon(Land[l][Corner4Icon][i]))
					DestroyDynamicMapIcon(Land[l][Corner4Icon][i]);
				Land[l][Corner4Icon][i] = CreateDynamicMapIcon(Land[l][LandX2], Land[l][LandY1], 0, 0, RED, .playerid = i, .streamdistance = 5000.0);
			}
		}
	}
}

stock SaveLand(id)
{
	new string[256];
	format(string, sizeof(string), "UPDATE land SET owner = '%s', x1 = '%f', y1 = '%f', x2 = '%f', y2 = '%f', signx = '%f', signy = '%f', signz = '%f', signa = '%f', forsale = '%d', price = '%d' WHERE sqlid = '%d'", Land[id][LandOwner], Land[id][LandX1], Land[id][LandY1], Land[id][LandX2], Land[id][LandY2], Land[id][LandSignX], Land[id][LandSignY], Land[id][LandSignZ], Land[id][LandSignA], Land[id][LandForSale], Land[id][LandPrice], Land[id][LandSQL]);
	db_query(mtg_db, string);
	return 1;
}