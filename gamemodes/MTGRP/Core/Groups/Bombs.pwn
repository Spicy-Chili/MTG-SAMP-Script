/*
#		MTG Bombs
#		
#
#	By accessing this file, you agree to the following:
#		- You will never give the script or associated files to anybody who is not on the MTG SAMP development team
# 		- You will delete all development materials (script, databases, associated files, etc.) when you leave the MTG SAMP development team.
#
*/
#include <YSI\y_hooks>
#define MAX_BOMBS 20
#define DIALOG_LIST_BOMBS 17120
#define BOMB_TYPE 6
#define BOMB_RADIUS 20
#define BOMB_OBJECT 1654
enum BombData
{
	BombObject,
	Float:BombX,
	Float:BombY,
	Float:BombZ,
	BombTimer,
	BombOwner[25],
	BombVehSQLID,
	BombType, // 1 = ignition, 2 = timer, 3 = remote
};
new GlobalBomb[MAX_BOMBS][BombData];

// ============= Commands =============
CMD:createbomb(playerid, params[])
{
	if(!DoesGangExist(Player[playerid][Gang]))
		return SendClientMessage(playerid, GREY, "Only official gangs can create bombs.");
	
	if(!DoesPlayerHavePerms(playerid, PERM_CREATEBOMBS))
		return SendClientMessage(playerid, RED, "Permission denied.");
		
	if(!PlayerHasJob(playerid, JOB_ARMSDEALER))
		return SendClientMessage(playerid, GREY, "You can't do that, you don't have the Arms Dealer job.");
	
	if(GetPlayerLevel(playerid) < 10)
		return SendClientMessage(playerid, GREY, "You need level 10 arms dealer to create a bomb.");
		
	if(Houses[Player[playerid][InHouse]][Workbench] == 0)
		return SendClientMessage(playerid, GREY, "You need a workbench to create a bomb!");
	
	if(Player[playerid][Toolkit] == 0)
		return SendClientMessage(playerid, GREY, "You need a toolkit to create a bomb!");
	
	if(Player[playerid][Materials][0] < 500 || Player[playerid][Materials][1] < 500 || Player[playerid][Materials][2] < 500)
		return SendClientMessage(playerid, GREY, "You need 500 street, standard and military materials to create a bomb!");
	
	if(Player[playerid][Bomb] == 1)
		return SendClientMessage(playerid, -1, "You already have a bomb in your inventory.");
		
	Player[playerid][Materials][0] -= 500;
	Player[playerid][Materials][1] -= 500;
	Player[playerid][Materials][2] -= 500;
	Player[playerid][Bomb] = 1;
	Player[playerid][ArmsDealerXP] += 3000;
	new string[128];
	format(string, sizeof(string), "* %s crafts an explosive device on their workbench.", GetNameEx(playerid));
	NearByMessage(playerid, NICESKY, string);
	SendClientMessage(playerid, YELLOW, "You have created a bomb.");
	SendClientMessage(playerid, YELLOW, "Type /plantbomb to show the syntax and more information.");
	return 1;
}

CMD:plantbomb(playerid, params[])
{
	if(Player[playerid][Bomb] != 1)
		return 1;
	
	if(!DoesGangExist(Player[playerid][Gang]))
		return SendClientMessage(playerid, GREY, "Only members of official gangs can plant bombs.");
		
	new option[30], vehicle[30], time;
	if(sscanf(params, "s[30]s[30]D(0)", option, vehicle, time))
 	{
		SendClientMessage(playerid, YELLOW, "SYNTAX: /plantbomb [option] [vehicle? yes or no] <time in minutes>");
		SendClientMessage(playerid, YELLOW, "Options: ignition, timer, remote");
		SendClientMessage(playerid, YELLOW, "Ignition: Vehicle bomb that detonates when the vehicle's engine turns on.");
		SendClientMessage(playerid, YELLOW, "Timer: Timed bomb that detonates when the time is up. (Max 60 mins)");
		SendClientMessage(playerid, YELLOW, "Remote: Remote bomb that detonates when you call the number 666.");
		return 1;
	}
	
	new slot = NewBombSlot();
	if(slot == -1)
		return SendClientMessage(playerid, -1, "Maximum amount of bombs have been placed already.");
	
	for(new i; i < MAX_BOMBS; i++)
	{
		if(!strcmp(GlobalBomb[i][BombOwner], GetName(playerid), true))
			return SendClientMessage(playerid, YELLOW, "You can only place one bomb at a time.");
	}
	
	new veh, sql, string[128], idx, Float:Pos[3];
	if(!strcmp(option, "ignition", true))
	{
		if(!strcmp(vehicle, "no", true))
			return SendClientMessage(playerid, YELLOW, "An ignition bomb can only be set up for a vehicle.");
	
		veh = NearestVehicle(playerid);
		GetVehiclePos(veh, Pos[0], Pos[1], Pos[2]);
		if(!IsPlayerInRangeOfPoint(playerid, 3, Pos[0], Pos[1], Pos[2]))
			return SendClientMessage(playerid, YELLOW, "You need to be next to a vehicle to plant an ignition bomb.");
	
		Player[playerid][Bomb] = 0;
		format(string, sizeof(string), "* %s places a package underneath the vehicle and fiddles with some wires.", GetNameEx(playerid));
		NearByMessage(playerid, NICESKY, string);
		SendClientMessage(playerid, YELLOW, "You have placed a bomb under the vehicle and attached it to the engine.");
		SendClientMessage(playerid, YELLOW, "The bomb will detonate when the engine is turned on."); 
		ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 3.1, 0, 0, 0, 0, 0, 1);
		
		sql = GetVSQLID(veh);
		idx = GetVIndex(sql);
		format(string, sizeof(string), "[BOMB] %s has placed a bomb on %s's vehicle (SQLID: %d)", GetName(playerid), Veh[idx][Owner], sql);
		SendToAdmins(ADMINORANGE, string, 0);
		CommandsLog(string);
		
		GlobalBomb[slot][BombVehSQLID] = sql;
		GlobalBomb[slot][BombTimer] = -1;
		format(GlobalBomb[slot][BombOwner], 25, "%s", GetName(playerid));	
		GlobalBomb[slot][BombType] = 1;
	}
	else if(!strcmp(option, "timer", true))
	{
		if(time < 1 || time > 60)
			return SendClientMessage(playerid, YELLOW, "Invalid time, must be a maximum of 60 minutes.");
			
		if(!strcmp(vehicle, "no", true))
		{
			GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
			GlobalBomb[slot][BombObject] = CreateDynamicObject(BOMB_OBJECT, Pos[0], Pos[1], Pos[2], 0.0, 0.0, 0.0, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));
			EditDynamicObject(playerid, GlobalBomb[slot][BombObject]);
			SetPVarInt(playerid, "EditingBomb", 1);
			SetPVarInt(playerid, "BombTimer", time);
			Player[playerid][Bomb] = 0;
			SetPVarInt(playerid, "BombSlot", slot);
		}
		else
		{
			veh = NearestVehicle(playerid);
			GetVehiclePos(veh, Pos[0], Pos[1], Pos[2]);
			if(!IsPlayerInRangeOfPoint(playerid, 3, Pos[0], Pos[1], Pos[2]))
				return SendClientMessage(playerid, YELLOW, "You are not standing next to a vehicle.");
			
			Player[playerid][Bomb] = 0;
			format(string, sizeof(string), "* %s places a package with a digital clock attached underneath the vehicle.", GetNameEx(playerid));
			NearByMessage(playerid, NICESKY, string);
			SendClientMessage(playerid, YELLOW, "You have placed a timed bomb under the vehicle.");
			format(string, sizeof(string), "The bomb will detonate in %d minutes.", time);
			SendClientMessage(playerid, YELLOW, string);
			ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 3.1, 0, 0, 0, 0, 0, 1);
			
			//stuff to handle bomb detonating... OneSecondPublic...
			sql = GetVSQLID(veh);
			idx = GetVIndex(sql);
			format(string, sizeof(string), "[BOMB] %s has placed a bomb on %s's vehicle (SQLID: %d)", GetName(playerid), Veh[idx][Owner], sql);
			SendToAdmins(ADMINORANGE, string, 0);
			CommandsLog(string);
			
			GlobalBomb[slot][BombVehSQLID] = sql;
			GlobalBomb[slot][BombTimer] = time;
			format(GlobalBomb[slot][BombOwner], 25, "%s", GetName(playerid));
			GlobalBomb[slot][BombType] = 2;
		}
	}
	else if(!strcmp(option, "remote", true))
	{
		if(!strcmp(vehicle, "no", true))
		{
			GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
			GlobalBomb[slot][BombObject] = CreateDynamicObject(BOMB_OBJECT, Pos[0], Pos[1], Pos[2], 0.0, 0.0, 0.0, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));
			EditDynamicObject(playerid, GlobalBomb[slot][BombObject]);
			SetPVarInt(playerid, "EditingBomb", 1);
			Player[playerid][Bomb] = 0;
			SetPVarInt(playerid, "BombSlot", slot);
		}
		else
		{
			veh = NearestVehicle(playerid);
			GetVehiclePos(veh, Pos[0], Pos[1], Pos[2]);
			if(!IsPlayerInRangeOfPoint(playerid, 3, Pos[0], Pos[1], Pos[2]))
				return SendClientMessage(playerid, YELLOW, "You are not standing next to a vehicle.");
			
			Player[playerid][Bomb] = 0;
			format(string, sizeof(string), "* %s places a package underneath the vehicle.", GetNameEx(playerid));
			NearByMessage(playerid, NICESKY, string);
			SendClientMessage(playerid, YELLOW, "You have placed a remote bomb under the vehicle.");
			format(string, sizeof(string), "The bomb will detonate when you call the number 666.", time);
			SendClientMessage(playerid, YELLOW, string);
			ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 3.1, 0, 0, 0, 0, 0, 1);
			
			sql = GetVSQLID(veh);
			idx = GetVIndex(sql);
			format(string, sizeof(string), "[BOMB] %s has placed a bomb on %s's vehicle (SQLID: %d)", GetName(playerid), Veh[idx][Owner], sql);
			SendToAdmins(ADMINORANGE, string, 0);
			CommandsLog(string);			
			
			GlobalBomb[slot][BombVehSQLID] = sql;
			GlobalBomb[slot][BombTimer] = -1;
			format(GlobalBomb[slot][BombOwner], 25, "%s", GetName(playerid));
			GlobalBomb[slot][BombType] = 3;
		}
	}
	else
		return SendClientMessage(playerid, YELLOW, "Invalid option.");
		
	return 1;
}

CMD:listbombs(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 2)
		return 1;
	
	new string[1000], type[30];
	for(new i; i < MAX_BOMBS; i++)
	{
		if(GlobalBomb[i][BombType] > 0)
		{
			if(GlobalBomb[i][BombTimer] > 0)
				format(type, 30, "Timer");
			else
				format(type, 30, "Ignition/remote");

			format(string, sizeof(string), "%s%d | %s bomb | %s | VSQL: %d | Time left: %d", string, i, type, GlobalBomb[i][BombOwner], GlobalBomb[i][BombVehSQLID], GlobalBomb[i][BombTimer]);
		}
	}
	ShowPlayerDialog(playerid, DIALOG_LIST_BOMBS, DIALOG_STYLE_LIST, "Active bombs", string, "Teleport", "Back");
	return 1;
}

CMD:removebomb(playerid, params[])
{
	new string[128];
	for(new i; i < MAX_BOMBS; i++)
	{
		if(GlobalBomb[i][BombVehSQLID] > 0)
		{
			new Float:Pos[3], idx;
			idx = GetVIndex(GlobalBomb[i][BombVehSQLID]);
			GetVehiclePos(Veh[idx][Link], Pos[0], Pos[1], Pos[2]);
			if(IsPlayerInRangeOfPoint(playerid, 5, Pos[0], Pos[1], Pos[2]))
			{
				if(!strcmp(GlobalBomb[i][BombOwner], GetName(playerid), true) || Player[playerid][AdminDuty] > 0)
				{
					if(Player[playerid][AdminDuty] < 1)
					{
						format(string, sizeof(string), "* %s has picked up a package from under a vehicle.", GetNameEx(playerid));
						NearByMessage(playerid, NICESKY, string);
						SendClientMessage(playerid, YELLOW, "Bomb added to your inventory. Type /plantbomb to plant it again.");
						Player[playerid][Bomb] = 1;
					}
					else
					{
						SendClientMessage(playerid, -1, "Bomb removed.");
					}
					ResetBomb(i);
				}
			}
		}
		else
		{
			if(IsPlayerInRangeOfPoint(playerid, 5, GlobalBomb[i][BombX], GlobalBomb[i][BombY], GlobalBomb[i][BombZ]))
			{
				if(!strcmp(GlobalBomb[i][BombOwner], GetName(playerid), true) || Player[playerid][AdminDuty] > 0)
				{
					if(Player[playerid][AdminDuty] < 1)
					{
						format(string, sizeof(string), "* %s has picked up a package.", GetNameEx(playerid));
						NearByMessage(playerid, NICESKY, string);
						SendClientMessage(playerid, YELLOW, "Bomb added to your inventory. Type /plantbomb to plant it again.");
						Player[playerid][Bomb] = 1;
					}
					else
					{
						SendClientMessage(playerid, -1, "Bomb removed.");
					}
					ResetBomb(i);
				}
			}
		}
	}
	
	return 1;
}
// ============= Callbacks =============

hook OnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	if(GetPVarInt(playerid, "EditingBomb") == 1)
	{
		switch(response)
		{
			case EDIT_RESPONSE_CANCEL:
			{
				DeletePVar(playerid, "EditingBomb");
				DeletePVar(playerid, "BombTimer");
				DestroyDynamicObject(objectid);
				SendClientMessage(playerid, YELLOW, "Bomb plant cancelled.");
			}
			case EDIT_RESPONSE_FINAL:
			{
				new string[128];
				new slot = GetPVarInt(playerid, "BombSlot");
				if(GetPVarInt(playerid, "BombTimer") > 0)
				{
					new time = GetPVarInt(playerid, "BombTimer");
					DeletePVar(playerid, "BombTimer");
					DeletePVar(playerid, "EditingBomb");
					format(string, sizeof(string), "* %s places a package onto the ground with a digital clock attached.", GetNameEx(playerid));
					NearByMessage(playerid, NICESKY, string);
					SendClientMessage(playerid, YELLOW, "You have placed a timed bomb onto the ground.");
					format(string, sizeof(string), "The bomb will detonate in %d minutes.", time);
					SendClientMessage(playerid, YELLOW, string);
					format(string, sizeof(string), "[BOMB] %s has placed a timer bomb.", GetName(playerid));
					GlobalBomb[slot][BombTimer] = time;
					GlobalBomb[slot][BombType] = 2;
				}
				else
				{
					DeletePVar(playerid, "EditingBomb");
					format(string, sizeof(string), "* %s places a package onto the ground.", GetNameEx(playerid));
					NearByMessage(playerid, NICESKY, string);
					SendClientMessage(playerid, YELLOW, "You have placed a remote bomb onto the ground.");
					SendClientMessage(playerid, YELLOW, "The bomb will detonate when you call the number 666.");
					format(string, sizeof(string), "[BOMB] %s has placed a remote bomb.", GetName(playerid));
					GlobalBomb[slot][BombTimer] = -1;
					GlobalBomb[slot][BombType] = 3;
				}
				GlobalBomb[slot][BombVehSQLID] = 0;
				GlobalBomb[slot][BombX] = x;
				GlobalBomb[slot][BombY] = y;
				GlobalBomb[slot][BombZ] = z;
				format(GlobalBomb[slot][BombOwner], 25, "%s", GetName(playerid));
				SendToAdmins(ADMINORANGE, string, 0);
				CommandsLog(string);
				ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 3.1, 0, 0, 0, 0, 0, 1);
				SetDynamicObjectPos(objectid, x, y, z);
				SetDynamicObjectRot(objectid, rx, ry, rz);
				Player[playerid][Bomb] = 0;
			}
		}
	}
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DIALOG_LIST_BOMBS:
		{
			if(!response)
				return 1;
				
			new bid = strval(CutBeforeLine(inputtext));
			if(GlobalBomb[bid][BombVehSQLID] < 1)
			{
				SetPlayerPos_Update(playerid, GlobalBomb[bid][BombX], GlobalBomb[bid][BombY], GlobalBomb[bid][BombZ]);
			}
			else
			{
				new Float:Pos[3], idx;
				idx = GetVIndex(GlobalBomb[bid][BombVehSQLID]);
				GetVehiclePos(Veh[idx][Link], Pos[0], Pos[1], Pos[2]);
				SetPlayerPos_Update(playerid, Pos[0], Pos[1], Pos[2]);
			}
		}
	}
	return 1;
}

// ============= Functions =============

stock ResetBomb(i)
{
	if(IsValidDynamicObject(GlobalBomb[i][BombObject]))
		DestroyDynamicObject(GlobalBomb[i][BombObject]);
	GlobalBomb[i][BombObject] = 0;
	GlobalBomb[i][BombX] = 0;
	GlobalBomb[i][BombY] = 0;
	GlobalBomb[i][BombZ] = 0;
	GlobalBomb[i][BombTimer] = -1;
	format(GlobalBomb[i][BombOwner], 25, "Nobody");
	GlobalBomb[i][BombVehSQLID] = -1;
	GlobalBomb[i][BombType] = 0;
	return 1;
}

stock NewBombSlot()
{
	new slot = -1;
	for(new i; i < MAX_BOMBS; i++)
	{
		if(GlobalBomb[i][BombType] == 0)
		{
			slot = i;
			break;
		}
	}
	return slot;
}

stock DetonateIgnitionBomb(sql, vehid)
{
	for(new i; i < MAX_BOMBS; i++)
	{
		if(sql == GlobalBomb[i][BombVehSQLID] && GlobalBomb[i][BombType] == 1)
		{
			new Float:Pos[3], string[128];
			GetVehiclePos(vehid, Pos[0], Pos[1], Pos[2]);
			CreateExplosion(Pos[0], Pos[1], Pos[2], BOMB_TYPE, BOMB_RADIUS);
			SetVehicleHealth(vehid, -5);
			BombKillZone(Pos[0], Pos[1], Pos[2]);
			format(string, sizeof(string), "[BOMB] %s's bomb has detonated.", GlobalBomb[i][BombOwner]);
			SendToAdmins(ADMINORANGE, string, 0);
			ResetBomb(i);
		}
	}
	return 1;
}

stock DetonateRemoteBomb(playerid)
{
	new string[128];
	for(new i; i < MAX_BOMBS; i++)
	{
		if(!strcmp(GlobalBomb[i][BombOwner], GetName(playerid), true))
		{
			if(GlobalBomb[i][BombType] == 3)
			{
				if(GlobalBomb[i][BombVehSQLID] < 1)
				{
					CreateExplosion(GlobalBomb[i][BombX], GlobalBomb[i][BombY], GlobalBomb[i][BombZ], BOMB_TYPE, BOMB_RADIUS);
					BombKillZone(GlobalBomb[i][BombX], GlobalBomb[i][BombY], GlobalBomb[i][BombZ]);
				}
				else
				{
					if(!IsSQLVehicleSpawned(GlobalBomb[i][BombVehSQLID]))
						return SendClientMessage(playerid, -1, "That vehicle isn't spawned in right now.");
						
					new Float:Pos[3], idx;
					idx = GetVIndex(GlobalBomb[i][BombVehSQLID]);
					GetVehiclePos(Veh[idx][Link], Pos[0], Pos[1], Pos[2]);
					CreateExplosion(Pos[0], Pos[1], Pos[2], BOMB_TYPE, BOMB_RADIUS);
					SetVehicleHealth(Veh[idx][Link], -5);
					BombKillZone(Pos[0], Pos[1], Pos[2]);
				}
				format(string, sizeof(string), "[BOMB] %s's bomb has detonated.", GetName(playerid));
				SendToAdmins(ADMINORANGE, string, 0);
				ResetBomb(i);
				return SendClientMessage(playerid, YELLOW, "** BEEP BEEP **");
			}
		}
	}
	return SendClientMessage(playerid, YELLOW, "The number you are trying to reach is currently unavailable.");
}

stock TimerBomb()
{
	new string[128];
	for(new i; i < MAX_BOMBS; i++)
	{
		if(GlobalBomb[i][BombTimer] > 0 && GlobalBomb[i][BombType] == 2)
		{
			if(GlobalBomb[i][BombVehSQLID] > 0 && !IsSQLVehicleSpawned(GlobalBomb[i][BombVehSQLID]))
				return 1;
				
			GlobalBomb[i][BombTimer]--;
			if(GlobalBomb[i][BombTimer] == 0)
			{
				if(GlobalBomb[i][BombVehSQLID] < 1)
				{
					CreateExplosion(GlobalBomb[i][BombX], GlobalBomb[i][BombY], GlobalBomb[i][BombZ], BOMB_TYPE, BOMB_RADIUS);
					BombKillZone(GlobalBomb[i][BombX], GlobalBomb[i][BombY], GlobalBomb[i][BombZ]);
				}
				else
				{
					new Float:Pos[3], idx;
					idx = GetVIndex(GlobalBomb[i][BombVehSQLID]);
					GetVehiclePos(Veh[idx][Link], Pos[0], Pos[1], Pos[2]);
					CreateExplosion(Pos[0], Pos[1], Pos[2], BOMB_TYPE, BOMB_RADIUS);
					SetVehicleHealth(Veh[idx][Link], -5);
					BombKillZone(Pos[0], Pos[1], Pos[2]);
				}
				format(string, sizeof(string), "[BOMB] %s's bomb has detonated.", GlobalBomb[i][BombOwner]);
				SendToAdmins(ADMINORANGE, string, 0);
				ResetBomb(i);
			}
		}
	}
	return 1;
}

stock BombKillZone(Float:x, Float:y, Float:z)
{
	foreach(Player, i)
	{
		if(IsPlayerInRangeOfPoint(i, 5, x, y, z))
			SetPlayerHealth(i, 0);
	}
	return 1;
}
hook OnGameModeInit()
{
	for(new i; i < MAX_BOMBS; i++)
	{
		ResetBomb(i);
	}
	return 1;
}