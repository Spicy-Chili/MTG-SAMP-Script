/*
#		MTG Admin Spawned Vehicles
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

new Iterator:AdminSpawned<MAX_VEHICLES>;
static string[128];
#define AddToAdminSpawned(%0)			Iter_Add(AdminSpawned, %0)
#define RemoveFromAdminSpawned(%0) 		Iter_Remove(AdminSpawned, %0)
#define IsAdminSpawned(%0)				Iter_Contains(AdminSpawned, %0)
#define AdminSpawnedCount()				Iter_Count(AdminSpawned)
#define ResetAdminSpawned()				Iter_Clear(AdminSpawned)

// ============= Callbacks =============

hook OnVehicleDeath(vehicleid, killerid)
{
	if(IsAdminSpawned(vehicleid))
	{
		DestroyVehicle(vehicleid);
		RemoveFromAdminSpawned(vehicleid);
	}
	return 1;
}

hook OnVehicleSpawn(vehicleid) //This is only called on respawn which shouldn't happen for admin spawned vehicles.
{
	if(IsAdminSpawned(vehicleid))
	{
		DestroyVehicle(vehicleid);
		RemoveFromAdminSpawned(vehicleid);
	}
	return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	if(Player[playerid][AdminLevel] >= 4)
	{
		if(AdminSpawnedCount() > 0 && GetOnlineAdmins(4) == 0)
		{
			foreach(new v : AdminSpawned)
			{
				DestroyVehicle(v);
			}
			ResetAdminSpawned();
		}
	}
	return 1;
}

// ============= Commands =============

CMD:spawncar(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 4)
		return 1;
		
	new model;
	if(sscanf(params, "d", model))
		return SendClientMessage(playerid, WHITE, "SYNTAX: /spawncar [model id]");
		
	if(model < 400 || model > 611)
	{
		SendClientMessage(playerid, WHITE, "Valid car IDs start from 400, ending at 611.");
		return 1;
	}
	
	new carid, Float:pPos[3];
	GetPlayerPos(playerid, pPos[0], pPos[1], pPos[2]);
	
	carid = CreateVehicle(model, pPos[0], pPos[1] + 3, pPos[2], 0, -1, -1, -1);
	SetVehicleParamsEx(carid, 1, 1, 0, 0, 0, 0, 0);
	LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
	SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid));
	SetVehicleNumberPlate(carid, "AdminSpawned");
	
	if(IsPlayerInAnyVehicle(playerid))
		RemovePlayerFromVehicle(playerid);
		
	PutPlayerInVehicle(playerid, carid, 0);
	
	AddToAdminSpawned(carid);
	
	format(string, sizeof(string), "You have spawned model ID %d. If you wish to save this, type /savevehicle.", model);
	SendClientMessage(playerid, WHITE, string);
	
	if(Player[playerid][PartyBussin] > 0)
	{
		KillTimer(Player[playerid][PartyBusTimer]);
		SendClientMessage(playerid, -1, "You have disabled party bus.");
		Player[playerid][PartyBussin] = 0;
	}
	
	return 1;
}

CMD:sc(playerid, params[]) return cmd_spawncar(playerid, params);

CMD:despawncar(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 4)
		return 1;
		
	if(!IsPlayerInAnyVehicle(playerid))
		return SendClientMessage(playerid, WHITE, "You must be in a vehicle to use this command.");
	
	new carid = GetPlayerVehicleID(playerid), sql = GetVSQLID(carid);
	
	if(sql != 0)
		return SendClientMessage(playerid, RED, "DON'T DESPAWN SAVED CARS!");
		
	if(!IsAdminSpawned(carid))
		return SendClientMessage(playerid, WHITE, "This isn't an admin spawned car.");
		
	RemoveFromAdminSpawned(carid);
	DestroyVehicle(carid);
	
	SendClientMessage(playerid, WHITE, "Vehicle de-spawned.");
	format(string, sizeof(string), "%s has de-spawned a vehicle.");
	AdminActionsLog(string);
	return 1;
}

CMD:destroyvehicles(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 4)
		return 1;
		
	foreach(new v : AdminSpawned)
	{
		DestroyVehicle(v);
	}
	ResetAdminSpawned();
	SendClientMessage(playerid, WHITE, "You have destroyed all admin spawned vehicles.");
	return 1;
}	