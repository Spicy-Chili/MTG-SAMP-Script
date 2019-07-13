/*
#		MTG Garage System
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
#include <YSI\y_iterate>

static string[128];

#define GARAGE_TYPE_HOUSE	1
#define GARAGE_TYPE_BIZ		2
#define GARAGE_TYPE_GROUP	3
#define GARAGE_TYPE_GANG	4

#define MAX_GARAGES			250

#define GARAGE_FOLDER		"scriptfiles/Garages"

enum garage_
{
	Float:ExtPos[3],
	Float:ExtAngle,
	Float:pExtPos[3],
	ExtVW,
	ExtIntID,
	
	Float:IntPos[3],
	Float:IntAngle,
	Float:pIntPos[3],
	IntVW,
	IntIntID,
	
	GarageType,
	GarageLinkID,
	
	GarageLock,
	
	GarageMaxVehicles,
	GarageVehicles,
	
	Text3D:GarageLabel[2],
};

new Garages[MAX_GARAGES][garage_];
new Iterator:Garage<MAX_GARAGES>;

// ============= Callbacks =============

hook OnGameModeInit()
{
	if(!dir_exists(GARAGE_FOLDER))
		dir_create(GARAGE_FOLDER);
	LoadGarages();
}

hook OnGameModeExit()
{
	SaveGarages();
}

// ============= Commands =============

CMD:creategarage(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;

	new Float:x, Float:y, Float:z, Float:ang;
	
	if(isnull(params))
	{
		SendClientMessage(playerid, WHITE, "SYNTAX: /creategarage [option]");
		return SendClientMessage(playerid, GREY, "Options: Interior (Don't use for default interior), Exterior, Complete");
	}
	
	if(!strcmp(params, "Exterior", true))
	{
		GetPlayerPos(playerid, x, y, z), SetPVarFloat(playerid, "extX", x), SetPVarFloat(playerid, "extY", y), SetPVarFloat(playerid, "extZ", z), GetPlayerFacingAngle(playerid, ang), SetPVarFloat(playerid, "extAngle", ang);
		SetPVarInt(playerid, "extVW", GetPlayerVirtualWorld(playerid)), SetPVarInt(playerid, "extIntID", GetPlayerInterior(playerid));
		format(string, sizeof(string), "You have set the exterior. (X: %f, Y: %f, Z: %f, VW: %d, Int: %d)", x, y, z, GetPVarInt(playerid, "extVW"), GetPVarInt(playerid, "extIntID"));
		SendClientMessage(playerid, -1, string);
	}
	else if(!strcmp(params, "Interior", true))
	{
		GetPlayerPos(playerid, x, y, z), SetPVarFloat(playerid, "intX", x), SetPVarFloat(playerid, "intY", y), SetPVarFloat(playerid, "intZ", z), GetPlayerFacingAngle(playerid, ang), SetPVarFloat(playerid, "intAngle", ang);
		SetPVarInt(playerid, "intVW", GetPlayerVirtualWorld(playerid)), SetPVarInt(playerid, "intIntID", GetPlayerInterior(playerid));
		format(string, sizeof(string), "You have set the interior. (X: %f, Y: %f, Z: %f, Angle: %f, VW: %d, Int: %d)", x, y, z, GetPVarInt(playerid, "intVW"), GetPVarInt(playerid, "intIntID"));
		SendClientMessage(playerid, -1, string);
	}
	else if(!strcmp(params, "Complete", true))
	{
		new Float:extX, Float:extY, Float:extZ, Float:extAng, extVW, extIntID;
		new Float:intX, Float:intY, Float:intZ, Float:intAng, intVW, intIntID;
		extX = GetPVarFloat(playerid, "extX"), extY = GetPVarFloat(playerid, "extY"), extZ = GetPVarFloat(playerid, "extZ"), extVW = GetPVarInt(playerid, "extVW"), extIntID = GetPVarInt(playerid, "extIntID"), extAng = GetPVarFloat(playerid, "extAngle");
		intX = GetPVarFloat(playerid, "intX"), intY = GetPVarFloat(playerid, "intY"), intZ = GetPVarFloat(playerid, "intZ"), intVW = GetPVarInt(playerid, "intVW"), intIntID = GetPVarInt(playerid, "intIntID"), intAng = GetPVarFloat(playerid, "intAngle");
		
		if(extX == 0.0 && extY == 0.0 && extZ == 0.0)
			return SendClientMessage(playerid, -1, "You forgot to set the exterior.");
		
		new id = GetAvailableID();
		
		if(id == -1)
			return SendClientMessage(playerid, -1, "There are no available garage IDs.");
		
		Garages[id][ExtPos][0] = extX;
		Garages[id][ExtPos][1] = extY;
		Garages[id][ExtPos][2] = extZ;
		Garages[id][ExtAngle] = extAng;
		Garages[id][pExtPos][0] = extX;
		Garages[id][pExtPos][1] = extY;
		Garages[id][pExtPos][2] = extZ;
		Garages[id][ExtVW] = extVW;
		Garages[id][ExtIntID] = extIntID;
		
		if(intX == 0.0 && intY == 0.0 && intZ == 0.0)
		{
			Garages[id][IntPos][0] = 2525.0;
			Garages[id][IntPos][1] = -1673.881;
			Garages[id][IntPos][2] = 14.86;
			Garages[id][IntAngle] = 270.0;
			Garages[id][pIntPos][0] = 2525.0;
			Garages[id][pIntPos][1] = -1673.881;
			Garages[id][pIntPos][2] = 14.86;
		}
		else
		{
			Garages[id][IntPos][0] = intX;
			Garages[id][IntPos][1] = intY;
			Garages[id][IntPos][2] = intZ;
			Garages[id][IntAngle] = intAng;
			Garages[id][pIntPos][0] = intX;
			Garages[id][pIntPos][1] = intY;
			Garages[id][pIntPos][2] = intZ;
		}
		Garages[id][IntVW] = intVW;
		Garages[id][IntIntID] = intIntID;
		
		UpdateGarageText(id);
		
		Iter_Add(Garage, id);
		SaveGarage(id);
		format(string, sizeof(string), "You have created garage ID %d. Make sure to link it to something use /linkgarage!", id);
		SendClientMessage(playerid, -1, string);
		SendClientMessage(playerid, GREEN, "Also, don't forget to set the player entrance using /editgarage!");
		format(string, sizeof(string), "%s has created a garage. (%d)", Player[playerid][AdminName], id);
		AdminActionsLog(string);
		
		DeletePVar(playerid, "extX"), DeletePVar(playerid, "extY"), DeletePVar(playerid, "extZ"), DeletePVar(playerid, "extVW"), DeletePVar(playerid, "extIntID");
		DeletePVar(playerid, "intX"), DeletePVar(playerid, "intY"), DeletePVar(playerid, "intZ"), DeletePVar(playerid, "intVW"), DeletePVar(playerid, "intIntID");
		
	}
	else 
	{
		SendClientMessage(playerid, WHITE, "SYNTAX: /creategarage [option]");
		return SendClientMessage(playerid, GREY, "Options: Interior (Don't set to use default interior), Exterior, Complete");
	}
	return 1;
}

CMD:linkgarage(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
		
	new gID, type, linkID;
	if(sscanf(params, "ddd", gID, type, linkID))
	{
		SendClientMessage(playerid, -1, "SYNTAX: /linkgarage [garage id] [link type] [link id]");
		return SendClientMessage(playerid, -1, "Types: 1 - House | 2 - Business | 3 - Group | 4 - Gang");
	}
	
	if(type < 1 || type > 4)
		return SendClientMessage(playerid, -1, "The type must be between 1 and 3.");
		
	if(linkID < 0)
		return SendClientMessage(playerid, -1, "Invalid link ID");
		
	if(type == 1 && linkID > MAX_HOUSES || type == 2 && linkID > MAX_BUSINESSES || type == 3 && linkID > MAX_GROUPS || type == 4 && linkID > MAX_GANGS)
		return SendClientMessage(playerid, -1, "Invalid link ID");
	
	if(!DoesGarageExist(gID))
		return SendClientMessage(playerid, -1, "Invalid garage ID.");
	
	switch(type)
	{
		case GARAGE_TYPE_HOUSE:	Garages[gID][IntVW] = (55000 + linkID);
		case GARAGE_TYPE_BIZ: Garages[gID][IntVW] = (65000 + linkID);
		case GARAGE_TYPE_GROUP: Garages[gID][IntVW] = (45000 + linkID);
		case GARAGE_TYPE_GANG: Garages[gID][IntVW] = (15000 + linkID);
	}
	
	Garages[gID][GarageType] = type;
	Garages[gID][GarageLinkID] = linkID;
	format(string, sizeof(string), "You have linked garage ID %d's link to %s ID %d.", gID, GetTypeName(Garages[gID][GarageType]), linkID);
	SendClientMessage(playerid, -1, string);
	format(string, sizeof(string), "%s has linked garage ID %d to %s ID %d.", Player[playerid][AdminName], gID, GetTypeName(Garages[gID][GarageType]), linkID);
	AdminActionsLog(string);
	return 1;
}

CMD:editgarage(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
	
	new id, option[32], value;
	if(sscanf(params, "ds[32]D()", id, option, value))
	{
		SendClientMessage(playerid, -1, "SYNTAX: /editgarage [garage id] [option] <value>");
		return SendClientMessage(playerid, -1, "Options: ext, int, playerExt, playerInt, MaxCars");
	}
	
	if(!DoesGarageExist(id))
		return SendClientMessage(playerid, -1, "That garage doesn't exist.");
	
	new Float:pPos[3], Float:Ang, VW, Int;
	GetPlayerPos(playerid, pPos[0], pPos[1], pPos[2]);
	VW = GetPlayerVirtualWorld(playerid);
	Int = GetPlayerInterior(playerid);
	GetPlayerFacingAngle(playerid, Ang);
	
	if(!strcmp(option, "ext", true))
	{
		Garages[id][ExtPos][0] = pPos[0];
		Garages[id][ExtPos][1] = pPos[1];
		Garages[id][ExtPos][2] = pPos[2];
		Garages[id][ExtAngle] = Ang;
		Garages[id][ExtVW] = VW;
		Garages[id][ExtIntID] = Int;
		format(string, sizeof(string), "You have set the exterior. (X: %f, Y: %f, Z: %f, VW: %d, Int: %d)", pPos[0], pPos[1], pPos[2], VW, Int);
		SendClientMessage(playerid, -1, string);
		
		UpdateGarageText(id);
		SaveGarage(id);
	}
	else if(!strcmp(option, "int", true))
	{
		Garages[id][IntPos][0] = pPos[0];
		Garages[id][IntPos][1] = pPos[1];
		Garages[id][IntPos][2] = pPos[2];
		Garages[id][IntAngle] = Ang;
		//Garages[id][IntVW] = VW;
		Garages[id][IntIntID] = Int;
		format(string, sizeof(string), "You have set the interior. (X: %f, Y: %f, Z: %f, VW: %d, Int: %d)", pPos[0], pPos[1], pPos[2], VW, Int);
		SendClientMessage(playerid, -1, string);
		SaveGarage(id);
	}
	else if(!strcmp(option, "playerExt", true))
	{
		Garages[id][pExtPos][0] = pPos[0];
		Garages[id][pExtPos][1] = pPos[1];
		Garages[id][pExtPos][2] = pPos[2];
		format(string, sizeof(string), "You have set the player exterior. (X: %f, Y: %f, Z: %f, VW: %d, Int: %d)", pPos[0], pPos[1], pPos[2], VW, Int);
		SendClientMessage(playerid, -1, string);
		
		UpdateGarageText(id);
		SaveGarage(id);
	}
	else if(!strcmp(option, "playerInt", true))
	{
		Garages[id][pIntPos][0] = pPos[0];
		Garages[id][pIntPos][1] = pPos[1];
		Garages[id][pIntPos][2] = pPos[2];
		format(string, sizeof(string), "You have set the player interior. (X: %f, Y: %f, Z: %f, VW: %d, Int: %d)", pPos[0], pPos[1], pPos[2], VW, Int);
		SendClientMessage(playerid, -1, string);
		SaveGarage(id);
	}
	else if(!strcmp(option, "maxcars", true)) 
	{
		if(value < 0)
			return 1;
			
		Garages[id][GarageMaxVehicles] = value;
		format(string, sizeof(string), "You have set the max garages in garage %d to %d.", id, value);
		SendClientMessage(playerid, -1, string);
		SaveGarage(id);
	}
	else
	{
		SendClientMessage(playerid, -1, "Invald option.");
		SendClientMessage(playerid, -1, "Options: ext, int, playerExt, playerInt, MaxCars");
	}
	return 1;
}

CMD:checkgarage(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 2)
		return 1;
		
	new id;
	if(sscanf(params, "d", id))
		return SendClientMessage(playerid, -1, "SYNTAX: /checkgarage [garage id]");
	
	if(!DoesGarageExist(id))
		return SendClientMessage(playerid, -1, "Invalid garage ID.");
		
	SendClientMessage(playerid, WHITE, "------------------------------------------------------------------");
	format(string, sizeof(string), "Garage ID: %d | Link Type: %s | Link ID: %d", id, GetTypeName(Garages[id][GarageType]), Garages[id][GarageLinkID]);
	SendClientMessage(playerid, GREY, string);
	format(string, sizeof(string), "Lock Status: %s | Max Vehicles: %d | Current Vehicle Count: %d", (Garages[id][GarageLock] == 1) ? ("Locked") : ("Unlocked"), Garages[id][GarageMaxVehicles], GetGarageVehicleCount(id));
	SendClientMessage(playerid, GREY, string);
	SendClientMessage(playerid, WHITE, "------------------------------------------------------------------");
	return 1;
}

CMD:gotogarage(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 2)
		return 1;
		
	new id, option[32];
	if(sscanf(params, "ds[32]", id, option))
		return SendClientMessage(playerid, -1, "SYNTAX: /gotogarage [garage id] [veh/player]");
	
	if(!DoesGarageExist(id))
		return SendClientMessage(playerid, -1, "Invalid garage ID.");
		
	if(!strcmp(option, "veh", true))
	{
		SetPlayerPos(playerid, Garages[id][ExtPos][0], Garages[id][ExtPos][1], Garages[id][ExtPos][2]);
		SetPlayerInterior(playerid, Garages[id][ExtIntID]);
		SetPlayerVirtualWorld(playerid, Garages[id][ExtVW]);
		format(string, sizeof(string), "You have teleported to the vehicle entrance of garage %d.", id);
		SendClientMessage(playerid, -1, string);
	}
	else if(!strcmp(option, "player", true))
	{
		SetPlayerPos(playerid, Garages[id][pExtPos][0], Garages[id][pExtPos][1], Garages[id][pExtPos][2]);
		SetPlayerInterior(playerid, Garages[id][ExtIntID]);
		SetPlayerVirtualWorld(playerid, Garages[id][ExtVW]);
		format(string, sizeof(string), "You have teleported to the player entrance of garage %d.", id);
		SendClientMessage(playerid, -1, string);
	}
	else return SendClientMessage(playerid, -1, "SYNTAX: /checkgarage [garage id] [veh/player]");
	return 1;
}

CMD:entergarage(playerid, params[])
{
	new id = GetClosestGarage(playerid);
	if(!DoesGarageExist(id))
		return SendClientMessage(playerid, -1, "That garage does not appear to exist.");
	
	if(Garages[id][GarageLock] == 1)
		return SendClientMessage(playerid, -1, "The garage door is locked.");
	
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(IsAHelicopter(GetPlayerVehicleID(playerid)))
			return SendClientMessage(playerid, -1, "You can't store that in here.");
		
		if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
			return SendClientMessage(playerid, -1, "You must be the driver to store the vehicle.");
		
		if(IsPlayerInRangeOfPoint(playerid, 10, Garages[id][ExtPos][0], Garages[id][ExtPos][1], Garages[id][ExtPos][2]))
		{
			if(GetGarageVehicleCount(id) >= Garages[id][GarageMaxVehicles])
				return SendClientMessage(playerid, -1, "This garage cannot fit any more cars.");
				
			new v = GetPlayerVehicleID(playerid);	
			SetVehiclePos(v, Garages[id][IntPos][0], Garages[id][IntPos][1], Garages[id][IntPos][2]);
			SetVehicleVirtualWorld(v, Garages[id][IntVW]);
			SetVehicleZAngle(v, Garages[id][IntAngle]);
			LinkVehicleToInterior(v, Garages[id][IntIntID]);
			foreach(Player, i)
			{
				if(GetPlayerVehicleID(i) == v || GetPlayerSurfingVehicleID(i) == v)
				{
					SetPlayerVirtualWorld(i, Garages[id][IntVW]);
					SetPlayerInterior(i, Garages[id][IntIntID]);
					Player[i][InGarage] = id;
					
					switch(Garages[id][GarageType])
					{
						case GARAGE_TYPE_HOUSE:	Player[i][InHouse] = Garages[id][GarageLinkID];
						case GARAGE_TYPE_BIZ: Player[i][InBusiness] = Garages[id][GarageLinkID];
						case GARAGE_TYPE_GROUP: Player[i][InGroupHQ] = Garages[id][GarageLinkID];
						case GARAGE_TYPE_GANG: Player[i][InGangHQ] = Garages[id][GarageLinkID];
					}
				}
			}
			format(string, sizeof(string), "* %s drives the vehicle into the garage.", GetNameEx(playerid));
			NearByMessage(playerid, NICESKY, string);
			
			//Garages[id][GarageVehicles]++;
		}
		else return SendClientMessage(playerid, -1, "You are not near the garage door.");
	}
	else
	{
		if(IsPlayerInRangeOfPoint(playerid, 3, Garages[id][pExtPos][0], Garages[id][pExtPos][1], Garages[id][pExtPos][2]))
		{
			SetPlayerPos_Update(playerid, Garages[id][pIntPos][0], Garages[id][pIntPos][1], Garages[id][pIntPos][2]);
			SetPlayerVirtualWorld(playerid, Garages[id][IntVW]);
			SetPlayerInterior(playerid, Garages[id][IntIntID]);
			Player[playerid][InGarage] = id;
			format(string, sizeof(string), "* %s walks inside of the garage.", GetNameEx(playerid));
			NearByMessage(playerid, NICESKY, string);
			
			switch(Garages[id][GarageType])
			{
				case GARAGE_TYPE_HOUSE:	Player[playerid][InHouse] = Garages[id][GarageLinkID];
				case GARAGE_TYPE_BIZ: Player[playerid][InBusiness] = Garages[id][GarageLinkID];
				case GARAGE_TYPE_GROUP: Player[playerid][InGroupHQ] = Garages[id][GarageLinkID];
				case GARAGE_TYPE_GANG: Player[playerid][InGangHQ] = Garages[id][GarageLinkID];
			}
			
		}
		else return SendClientMessage(playerid, -1, "You are not near a garage door.");
	}	
	return 1;
}

CMD:exitgarage(playerid, params[])
{
	new id = Player[playerid][InGarage];
	
	if(id == -1)
		return SendClientMessage(playerid, -1, "You are not inside a garage.");
	
	if(Garages[id][GarageLock] == 1)
		return SendClientMessage(playerid, -1, "The garage door is locked.");
	
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
			return SendClientMessage(playerid, -1, "You must be the driver to remove the vehicle.");
		
		if(IsPlayerInRangeOfPoint(playerid, 5, Garages[id][IntPos][0], Garages[id][IntPos][1], Garages[id][IntPos][2]))
		{
			new v = GetPlayerVehicleID(playerid);	
			SetVehiclePos(v, Garages[id][ExtPos][0], Garages[id][ExtPos][1], Garages[id][ExtPos][2]);
			SetVehicleVirtualWorld(v, Garages[id][ExtVW]);
			SetVehicleZAngle(v, Garages[id][ExtAngle]);
			LinkVehicleToInterior(v, Garages[id][ExtIntID]);
			foreach(Player, i)
			{
				if(GetPlayerVehicleID(i) == v || GetPlayerSurfingVehicleID(i) == v)
				{
					SetPlayerVirtualWorld(i, Garages[id][ExtVW]);
					SetPlayerInterior(i, Garages[id][ExtIntID]);
					Player[i][InGarage] = -1;
					
					switch(Garages[id][GarageType])
					{
						case GARAGE_TYPE_HOUSE:	Player[i][InHouse] = 0;
						case GARAGE_TYPE_BIZ: Player[i][InBusiness] = 0;
						case GARAGE_TYPE_GROUP: Player[i][InGroupHQ] = 0;
						case GARAGE_TYPE_GANG: Player[i][InGangHQ] = 0;
					}
				}
			}
			format(string, sizeof(string), "* %s drives the vehicle out of the garage.", GetNameEx(playerid));
			NearByMessage(playerid, NICESKY, string);
			
			//Garages[id][GarageVehicles] --;
		}
		else return SendClientMessage(playerid, -1, "You aren't near the garage exit.");
	}
	else 
	{
		if(IsPlayerInRangeOfPoint(playerid, 3, Garages[id][pIntPos][0], Garages[id][pIntPos][1], Garages[id][pIntPos][2]))
		{
			SetPlayerPos_Update(playerid, Garages[id][pExtPos][0], Garages[id][pExtPos][1], Garages[id][pExtPos][2]);
			SetPlayerVirtualWorld(playerid, Garages[id][ExtVW]);
			SetPlayerInterior(playerid, Garages[id][ExtIntID]);
			Player[playerid][InGarage] = -1;
			format(string, sizeof(string), "* %s walks outside of the garage.", GetNameEx(playerid));
			NearByMessage(playerid, NICESKY, string);
			
			switch(Garages[id][GarageType])
			{
				case GARAGE_TYPE_HOUSE:	Player[playerid][InHouse] = 0;
				case GARAGE_TYPE_BIZ: Player[playerid][InBusiness] = 0;
				case GARAGE_TYPE_GROUP: Player[playerid][InGroupHQ] = 0;
				case GARAGE_TYPE_GANG: Player[playerid][InGangHQ] = 0;
			}
			
		}
		else return SendClientMessage(playerid, -1, "You are not near the garage exit.");
	}
	return 1;
}

CMD:lockgarage(playerid, params[])
{
	new id;
	if(Player[playerid][InGarage] == -1)
		id = GetClosestGarage(playerid);
	else id = Player[playerid][InGarage];
	
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(!IsPlayerInRangeOfPoint(playerid, 10, Garages[id][pExtPos][0], Garages[id][pExtPos][1], Garages[id][pExtPos][2]) && !IsPlayerInRangeOfPoint(playerid, 3, Garages[id][pIntPos][0], Garages[id][pIntPos][1], Garages[id][pIntPos][2]))
			return SendClientMessage(playerid, WHITE, "Your garage clicker is out of range of the door.");
	}
	else if(!IsPlayerInRangeOfPoint(playerid, 6, Garages[id][pExtPos][0], Garages[id][pExtPos][1], Garages[id][pExtPos][2]) && !IsPlayerInRangeOfPoint(playerid, 3, Garages[id][pIntPos][0], Garages[id][pIntPos][1], Garages[id][pIntPos][2]))
		return SendClientMessage(playerid, WHITE, "You aren't close enough to the garage or the personnel door.");
	
	if(!CanPlayerLockGarage(playerid, id))
		return SendClientMessage(playerid, -1, "You don't have the keys to this garage.");
	
	switch(Garages[id][GarageLock])
	{
		case 0:
		{
			if(!IsPlayerInAnyVehicle(playerid))
				format(string, sizeof(string), "* %s uses their key to lock the garage.", GetNameEx(playerid));
			else format(string, sizeof(string), "* %s uses their garage clicker to lock the garage.", GetNameEx(playerid));
			NearByMessage(playerid, NICESKY, string);
			Garages[id][GarageLock] = 1;
			UpdateGarageText(id);
		}
		case 1:
		{
			if(!IsPlayerInAnyVehicle(playerid))
				format(string, sizeof(string), "* %s uses their key to unlock the garage.", GetNameEx(playerid));
			else format(string, sizeof(string), "* %s uses their garage clicker to unlock the garage.", GetNameEx(playerid));
			NearByMessage(playerid, NICESKY, string);
			Garages[id][GarageLock] = 0;
			UpdateGarageText(id);
		}
	}
	return 1;
}

// ============= Stock Functions =============

static stock GetGarageVehicleCount(id)
{
	new count;
	for(new i; i < MAX_VEHICLES; i++)
	{
		if(GetVehicleVirtualWorld(i) == Garages[id][IntVW])
			count++;
	}
	return count;
}

stock UpdateGarageText(id)
{
	if(IsValidDynamic3DTextLabel(Garages[id][GarageLabel][0]))
		DestroyDynamic3DTextLabel(Garages[id][GarageLabel][0]);
	if(IsValidDynamic3DTextLabel(Garages[id][GarageLabel][1]))
		DestroyDynamic3DTextLabel(Garages[id][GarageLabel][1]);
	
	format(string, sizeof(string), "Garage %d\nVehicle Entrance\n%s", id, GetLockText(id));
	Garages[id][GarageLabel][0] = CreateDynamic3DTextLabel(string, GREEN, Garages[id][ExtPos][0], Garages[id][ExtPos][1], Garages[id][ExtPos][2], 10, .worldid = Garages[id][ExtVW], .interiorid = Garages[id][ExtIntID], .streamdistance = 15);
	format(string, sizeof(string), "Garage %d\nPersonnel Entrance\n%s", id, GetLockText(id));
	Garages[id][GarageLabel][1] = CreateDynamic3DTextLabel(string, GREEN, Garages[id][pExtPos][0], Garages[id][pExtPos][1], Garages[id][pExtPos][2], 10, .worldid = Garages[id][ExtVW], .interiorid = Garages[id][ExtIntID], .streamdistance = 15);
	
	return 1;
}

stock UpdatePlayerInGarage(playerid)
{
	foreach(new g : Garage)
	{
		switch(Garages[g][GarageType])
		{
			case GARAGE_TYPE_HOUSE:
			{
				if(Player[playerid][InHouse] == Garages[g][GarageLinkID])
				{
					Player[playerid][InGarage] = g;
					break;
				}
				else 
					Player[playerid][InGarage] = -1;
			}
			case GARAGE_TYPE_BIZ:
			{
				if(Player[playerid][InBusiness] == Garages[g][GarageLinkID])
				{
					Player[playerid][InGarage] = g;
					break;
				}
				else 
					Player[playerid][InGarage] = -1;
			}
			case GARAGE_TYPE_GROUP:
			{
				if(Player[playerid][InGroupHQ] == Garages[g][GarageLinkID])
				{
					Player[playerid][InGarage] = g;
					break;
				}
				else 
					Player[playerid][InGarage] = -1;
			}
			case GARAGE_TYPE_GANG:
			{
				if(Player[playerid][InGangHQ] == Garages[g][GarageLinkID])
				{
					Player[playerid][InGarage] = g;
					break;
				}
				else 
					Player[playerid][InGarage] = -1;
			}
		}
	}
	return 1;
}

static stock GetLockText(garageid)
{
	new name[10];
	format(name, sizeof(name), "%s", (Garages[garageid][GarageLock] == 1) ? ("Locked") : ("Unlocked"));
	return name;
}

static stock CanPlayerLockGarage(playerid, id)
{
	switch(Garages[id][GarageType])
	{
		case GARAGE_TYPE_HOUSE:
		{
			return PlayerHasHouseKey(playerid, Garages[id][GarageLinkID]);
		}
		case GARAGE_TYPE_BIZ:
		{
			return PlayerHasBusinessKey(playerid, Garages[id][GarageLinkID]);
		}
		case GARAGE_TYPE_GROUP:
		{
			if(Player[playerid][Group] == Garages[id][GarageLinkID])
				return 1;
		}
		case GARAGE_TYPE_GANG:
		{
			if(Player[playerid][Gang] == Garages[id][GarageLinkID])
				return 1;
		}
	}
	return 0;
}

static stock GetClosestGarage(playerid)
{
	new Float:dist, id = -1;
	foreach(new g : Garage)
	{
		if(id == -1 || dist > GetPlayerDistanceFromPoint(playerid, Garages[g][ExtPos][0], Garages[g][ExtPos][1], Garages[g][ExtPos][2]))
		{
			id = g;
			dist = GetPlayerDistanceFromPoint(playerid, Garages[g][ExtPos][0], Garages[g][ExtPos][1], Garages[g][ExtPos][2]);
		}
	}
	return id;
}

static stock GetAvailableID()
{
	return Iter_Free(Garage);
}

static stock DoesGarageExist(id)
{
	return Iter_Contains(Garage, id);
}

static stock GetTypeName(type)
{
	new name[32];
	switch(type)
	{
		case 1: format(name, sizeof(name), "House");
		case 2: format(name, sizeof(name), "Business");
		case 3: format(name, sizeof(name), "Group");
		case 4: format(name, sizeof(name), "Gang");
	}
	return name;
}

static stock SaveGarages()
{
	foreach(new g : Garage)
	{
		SaveGarage(g);
	}
	return 1;
}

static stock LoadGarages()
{
	for(new i; i < MAX_GARAGES; i++)
	{
		format(string, sizeof(string), "Garages/Garage_%d.ini", i);
		INI_ParseFile(string, "LoadGarage", .bExtra = true, .extra = i, .bPassTag = true);
		
		if(fexist(string))
		{
			if(Garages[i][ExtPos][0] != 0.0 && Garages[i][ExtPos][1] != 0.0 && Garages[i][ExtPos][2] != 0.0)
			{
				UpdateGarageText(i);
				Iter_Add(Garage, i);
				printf("[system] Loaded Garage %d.", i);
			}
		}
	}
	return 1;
}

static stock SaveGarage(id)
{
	format(string, sizeof(string), "Garages/Garage_%d.ini", id);
	new INI:file = INI_Open(string);
	INI_WriteFloat(file, "Ext_X", Garages[id][ExtPos][0]);
	INI_WriteFloat(file, "Ext_Y", Garages[id][ExtPos][1]);
	INI_WriteFloat(file, "Ext_Z", Garages[id][ExtPos][2]);
	INI_WriteFloat(file, "Ext_Player_X", Garages[id][pExtPos][0]);
	INI_WriteFloat(file, "Ext_Player_Y", Garages[id][pExtPos][1]);
	INI_WriteFloat(file, "Ext_Player_Z", Garages[id][pExtPos][2]);
	INI_WriteFloat(file, "Ext_Angle", Garages[id][ExtAngle]);
	INI_WriteInt(file, "Ext_VW", Garages[id][ExtVW]);
	INI_WriteInt(file, "Ext_IntID", Garages[id][ExtIntID]);
	INI_WriteFloat(file, "Int_X", Garages[id][IntPos][0]);
	INI_WriteFloat(file, "Int_Y", Garages[id][IntPos][1]);
	INI_WriteFloat(file, "Int_Z", Garages[id][IntPos][2]);
	INI_WriteFloat(file, "Int_Player_X", Garages[id][pIntPos][0]);
	INI_WriteFloat(file, "Int_Player_Y", Garages[id][pIntPos][1]);
	INI_WriteFloat(file, "Int_Player_Z", Garages[id][pIntPos][2]);
	INI_WriteFloat(file, "Int_Angle", Garages[id][IntAngle]);
	INI_WriteInt(file, "Int_VW", Garages[id][IntVW]);
	INI_WriteInt(file, "Int_IntID", Garages[id][IntIntID]);
	INI_WriteInt(file, "GarageType", Garages[id][GarageType]);
	INI_WriteInt(file, "GarageLinkID", Garages[id][GarageLinkID]);
	INI_WriteInt(file, "GarageLock", Garages[id][GarageLock]);
	INI_WriteInt(file, "GarageMaxVehicles", Garages[id][GarageMaxVehicles]);
	INI_WriteInt(file, "GarageVehicles", Garages[id][GarageVehicles]);
	INI_Close(file);
	printf("[system] Garage %d saved.", id);
	return 1;
}

forward LoadGarage(id, tag[], name[], value[]);
public LoadGarage(id, tag[], name[], value[])
{
	INI_Float("Ext_X", Garages[id][ExtPos][0]);
	INI_Float("Ext_Y", Garages[id][ExtPos][1]);
	INI_Float("Ext_Z", Garages[id][ExtPos][2]);
	INI_Float("Ext_Player_X", Garages[id][pExtPos][0]);
	INI_Float( "Ext_Player_Y", Garages[id][pExtPos][1]);
	INI_Float("Ext_Player_Z", Garages[id][pExtPos][2]);
	INI_Float("Ext_Angle", Garages[id][ExtAngle]);
	INI_Int("Ext_VW", Garages[id][ExtVW]);
	INI_Int("Ext_IntID", Garages[id][ExtIntID]);
	INI_Float("Int_X", Garages[id][IntPos][0]);
	INI_Float("Int_Y", Garages[id][IntPos][1]);
	INI_Float("Int_Z", Garages[id][IntPos][2]);
	INI_Float("Int_Player_X", Garages[id][pIntPos][0]);
	INI_Float("Int_Player_Y", Garages[id][pIntPos][1]);
	INI_Float("Int_Player_Z", Garages[id][pIntPos][2]);
	INI_Float("Int_Angle", Garages[id][IntAngle]);
	INI_Int("Int_VW", Garages[id][IntVW]);
	INI_Int("Int_IntID", Garages[id][IntIntID]);
	INI_Int("GarageType", Garages[id][GarageType]);
	INI_Int("GarageLinkID", Garages[id][GarageLinkID]);
	INI_Int("GarageLock", Garages[id][GarageLock]);
	INI_Int("GarageMaxVehicles", Garages[id][GarageMaxVehicles]);
	INI_Int("GarageVehicles", Garages[id][GarageVehicles]);
	return 1;
}