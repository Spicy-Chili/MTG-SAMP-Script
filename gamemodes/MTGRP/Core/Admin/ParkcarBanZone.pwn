/*
#		MTG Parking Zone Bans
#		
#
#	By accessing this file, you agree to the following:
#		- You will never give the script or associated files to anybody who is not on the MTG SAMP development team
# 		- You will delete all development materials (script, databases, associated files, etc.) when you leave the MTG SAMP development team.
#
*/
#include <YSI\y_hooks>

#define MAX_PARKCAR_BAN_ZONES	10

static string[128];
new Float:ParkcarBanZonePos[MAX_PARKCAR_BAN_ZONES][3], ParkcarBanZone[MAX_PARKCAR_BAN_ZONES];

CMD:placeparkcarbanzone(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
		
	new id, Float:radius;
	if(sscanf(params, "df", id, radius))
		return SendClientMessage(playerid, WHITE, "SYNTAX: /placeparkcarbanzone [id] [radius]");
		
	if(id < 0 || id > MAX_PARKCAR_BAN_ZONES)
		return SendClientMessage(playerid, WHITE, "Valid IDs are between 0 and "#MAX_PARKCAR_BAN_ZONES);
	
	if(IsValidDynamicArea(ParkcarBanZone[id]))
		DestroyDynamicArea(ParkcarBanZone[id]);
		
	new Float:pos[3];
	GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	
	ParkcarBanZonePos[id][0] = pos[0];
	ParkcarBanZonePos[id][1] = pos[1];
	ParkcarBanZonePos[id][2] = radius;
	
	ParkcarBanZone[id] = CreateDynamicCircle(ParkcarBanZonePos[id][0], ParkcarBanZonePos[id][1], ParkcarBanZonePos[id][2]);
	
	format(string, sizeof(string), "You have placed a /parkcar ban zone at your current position with a radius of %f.", radius);
	SendClientMessage(playerid, WHITE, string);
	format(string, sizeof(string), "%s has moved /parkcar ban zone %d.", Player[playerid][AdminName], id);
	AdminActionsLog(string);
	SaveZone(id);
	return 1;
}

CMD:gotoparkcarbanzone(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 2)
		return 1;
		
	new id;
	if(sscanf(params, "d", id))
		return SendClientMessage(playerid, WHITE, "SYNTAX: /gotoparkcarbanzone [id]");
	
	if(ParkcarBanZonePos[id][0] == 0.0 && ParkcarBanZonePos[id][1] == 0.0 && ParkcarBanZonePos[id][2] == 0.0 || id < 0 || id > MAX_PARKCAR_BAN_ZONES)
		return SendClientMessage(playerid, WHITE, "That isn't a valid /parkcar ban zone.");
	
	SetPlayerPosFindZ(playerid, ParkcarBanZonePos[id][0], ParkcarBanZonePos[id][1], 500.0);
	SetPlayerPosFindZ(playerid, ParkcarBanZonePos[id][0], ParkcarBanZonePos[id][1], 500.0); //Gotta do it twice or they fall through the floor
	format(string, sizeof(string), "You have teleported to /parkcar ban zone %d.", id);
	SendClientMessage(playerid, WHITE, string);
	return 1;
}

CMD:listparkcarbanzones(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
	
	new count;
	SendClientMessage(playerid, WHITE, "----------------------------------------------------------");
	for(new i; i < MAX_PARKCAR_BAN_ZONES; i++)
	{
		if(IsValidDynamicArea(ParkcarBanZone[i]))
		{
			format(string, sizeof(string), "%d | X: %f | Y: %f | Radius: %f", i, ParkcarBanZonePos[i][0], ParkcarBanZonePos[i][1], ParkcarBanZonePos[i][2]);
			SendClientMessage(playerid, GREY, string);
			count++;
		}
	}
	if(count == 0)
		SendClientMessage(playerid, GREY, "No valid /parkcar ban zones found.");
	SendClientMessage(playerid, WHITE, "----------------------------------------------------------");
	return 1;
}

stock IsPlayerInParkcarBanZone(playerid)
{
	new valid = 0;
	for(new i; i < MAX_PARKCAR_BAN_ZONES; i++)
	{
		if(!IsValidDynamicArea(ParkcarBanZone[i]))
			continue;
			
		if(IsPlayerInDynamicArea(playerid, ParkcarBanZone[i]))
		{
			valid = 1;
			break;
		}
	}
	return valid;
}

static stock SaveZone(id)
{
	mysql_format(MYSQL_MAIN, string, sizeof(string), "SELECT * FROM parkbanzones WHERE id = '%d'", id);
	new Cache:cache = mysql_query(MYSQL_MAIN, string);
	
	if(cache_get_row_count() > 0)
	{
		mysql_format(MYSQL_MAIN, string, sizeof(string), "UPDATE parkbanzones SET X = '%f', Y = '%f', Radius = '%f' WHERE ID = '%d'", ParkcarBanZonePos[id][0], ParkcarBanZonePos[id][1], ParkcarBanZonePos[id][2], id);
		mysql_query(MYSQL_MAIN, string, false);
	}
	else 
	{
		mysql_format(MYSQL_MAIN, string, sizeof(string), "INSERT INTO parkbanzones (ID, X, Y, Radius) VALUES (%d, %f, %f, %f)", id, ParkcarBanZonePos[id][0], ParkcarBanZonePos[id][1], ParkcarBanZonePos[id][2]);
		mysql_query(MYSQL_MAIN, string, false);
	}
	cache_delete(cache);
	return 1;
}

stock LoadZones()
{
	new Cache:cache = mysql_query(MYSQL_MAIN, "SELECT * FROM parkbanzones");
	new count = cache_get_row_count(), id;
	while(id < count)
	{
		ParkcarBanZonePos[id][0] = cache_get_field_content_float(id, "X");
		ParkcarBanZonePos[id][1] = cache_get_field_content_float(id, "Y");
		ParkcarBanZonePos[id][2] = cache_get_field_content_float(id, "Radius");
		ParkcarBanZone[id] = CreateDynamicCircle(ParkcarBanZonePos[id][0], ParkcarBanZonePos[id][1], ParkcarBanZonePos[id][2]);
		id++;
	}
	printf("Loaded %d parkcar ban zones.", id);
	cache_delete(cache);
	return 1;
}