/*
#		MTG Garbage Job
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

static string[128];

#define MAX_TRASH_POINTS 50
new trashPay;
new Float:trashPos[MAX_TRASH_POINTS][3];
//new trashCooldown[MAX_TRASH_POINTS];

#define TRASH_BIZ	1
#define TRASH_CITY	2

// ============= Callbacks =============

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if(!ispassenger)
	{
		new sql = GetVSQLID(vehicleid), idx = GetVIndex(sql);
		if(sql != 0)
		{
			if(Jobs[Veh[idx][Job]][JobType] == 12)
			{
				if(Player[playerid][Job] != Veh[idx][Job] && Player[playerid][Job2] != Veh[idx][Job])
				{
					ClearAnimations(playerid);
					return SendClientMessage(playerid, WHITE, "You don't have the garbage man job!");
				}
				
				if(Player[playerid][GarbageStep] == 0)
				{
					if(Player[playerid][Checkpoint] > 0) {
						ClearAnimations(playerid);
						return SendClientMessage(playerid, -1, "You already have a checkpoint! Do /kc first!");
					}
					
					if(Player[playerid][TruckStage] > 0) {
						ClearAnimations(playerid);
						return SendClientMessage(playerid, -1, "You are on a trucker run! You must do /quitdelivery first");
					}
					
					if(Player[playerid][GarbageCooldown] > gettime()) {
						ClearAnimations(playerid);
						return SendClientMessage(playerid, -1, "You need to wait the cooldown before doing this again.");
					}
					
					if(Player[playerid][LicenseSuspended] > 0) { 
						ClearAnimations(playerid);
						return SendClientMessage(playerid, -1, "Your license is currently suspended. You may not collect trash until your license is cleared."); 
					}
						
					if(trashPay == 0) {
						ClearAnimations(playerid);
						return SendClientMessage(playerid, -1, "Unable to start job. (Pay set to 0)"); 
					}
					
					new id = randomTrashPos(playerid);
					
					if(id == -1)
					{
						ClearAnimations(playerid);
						return SendClientMessage(playerid, WHITE, "There is no trash that needs to be picked up!");
					}
					
					SetPVarInt(playerid, "garbageSQL", sql); 
					Player[playerid][GarbagePay] = 0;
					Player[playerid][Checkpoint] = 1337;
					Player[playerid][GarbageStep] = 1;
					Player[playerid][GarbageTimer] = repeat PlayerGarbageTimer(playerid);
					SetPVarInt(playerid, "trashID", id); 
					
					new type = GetPVarInt(playerid, "TrashType");
					switch(type)
					{
						case TRASH_BIZ:	SetPlayerCheckpoint(playerid, Businesses[id][BusinessTrashPos][0], Businesses[id][BusinessTrashPos][1],Businesses[id][BusinessTrashPos][2], 10);
						case TRASH_CITY: SetPlayerCheckpoint(playerid, trashPos[id][0], trashPos[id][1], trashPos[id][2], 10);
					}
					
					SendClientMessage(playerid, -1, "Head to your first stop!");
				}
			}
		}
	}
	return 1;
}

hook OnPlayerEnterCheckpoint(playerid)
{
	if(Player[playerid][Checkpoint] == 1337 && Player[playerid][GarbageStep] > 0)
	{
		if(IsPlayerInAnyVehicle(playerid))
		{
			new sql = GetVSQLID(GetPlayerVehicleID(playerid));
			
			if(GetPVarInt(playerid, "garbageSQL") != sql && Player[playerid][LoadingTrash] == 0)
				return SendClientMessage(playerid, -1, "You must enter the checkpoint in the same garbage truck you started with!");
		}
		if(Player[playerid][GarbageStep] < 6)
		{
			if(Player[playerid][LoadingTrash] == 0)
			{
				new veh = GetPlayerVehicleID(playerid), sql = GetVSQLID(veh), idx = GetVIndex(sql);
				
				if(idx != 1) {
					if(Veh[idx][Fuel] < 40)
						Veh[idx][Fuel] += 10; 
				}
					
				SendClientMessage(playerid, -1, "Step out of the truck and enter /loadtrash behind the truck!"); 
				Player[playerid][LoadingTrash] = 1; 
			}
		}
		else if(Player[playerid][GarbageStep] == 6)
		{
			new sql = GetVSQLID(GetPlayerVehicleID(playerid)), idx = GetVIndex(sql);
			
			if(Jobs[Veh[idx][Job]][JobType] != 12)
				return SendClientMessage(playerid, -1, "You must be in a garbage truck to do this!");
			
			TogglePlayerControllable(playerid, false);
			Player[playerid][GarbageFreeze] = 1; 
			SendClientMessage(playerid, -1, "Please wait while the trash is dumped from the truck."); 
		}
		else if(Player[playerid][GarbageStep] == 7)
		{
			new sql = GetVSQLID(GetPlayerVehicleID(playerid)), idx = GetVIndex(sql);
			
			if(Jobs[Veh[idx][Job]][JobType] != 12)
				return SendClientMessage(playerid, -1, "You must be in a garbage truck to do this!");
			
			new Float:vH;
			GetVehicleHealth(Veh[idx][Link], vH);
			if(vH < 980)
			{
				cmd_endtrash(playerid, "");
				return SendClientMessage(playerid, -1, "Your vehicle has taken to much damage during your run and you recieve no pay!"); 
			}
			
			format(string, sizeof(string), "You have finished your garbage pickups and earned %s!", PrettyMoney(Player[playerid][GarbagePay]));
			SendClientMessage(playerid, -1, string);
			Player[playerid][Checkpoint] = 0;
			Player[playerid][Money] += Player[playerid][GarbagePay];
			Player[playerid][GarbageStep] = 0;
			Player[playerid][GarbageCooldown] = gettime() + 3600;
			Player[playerid][GarbagePay] = 0;
			Player[playerid][TotalGarbageRuns] ++;
			stop Player[playerid][GarbageTimer];
			DisablePlayerCheckpoint(playerid);
			SetVehicleToRespawn(Veh[idx][Link]);
			SavePlayerData(playerid);
		}
	}
	return 1;
}

hook OnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	if(GetPVarInt(playerid, "EditingTrashBin") == 1)
	{
		new Float:oldX, Float:oldY, Float:oldZ, Float:oldRX, Float:oldRY, Float:oldRZ;
		GetDynamicObjectPos(objectid, oldX, oldY, oldZ);
		GetDynamicObjectRot(objectid, oldRX, oldRY, oldRZ);
		
		MoveDynamicObject(objectid, x, y, z, 10, rx, ry, rz);
		
		if(response == EDIT_RESPONSE_FINAL)
		{
			new id = Player[playerid][Business];
			Businesses[id][BusinessTrashPos][0] = x;
			Businesses[id][BusinessTrashPos][1] = y;
			Businesses[id][BusinessTrashPos][2] = z;
			Businesses[id][BusinessTrashRot][0] = rx;
			Businesses[id][BusinessTrashRot][1] = ry;
			Businesses[id][BusinessTrashRot][2] = rz;
			
			if(IsValidDynamicObject(Businesses[id][BusinessTrashObjects][0]))
			{
				SetDynamicObjectPos(Businesses[id][BusinessTrashObjects][0], Businesses[id][BusinessTrashPos][0] - 0.14307, Businesses[id][BusinessTrashPos][1] - 1.57276, Businesses[id][BusinessTrashPos][2] - 0.6406);
				SetDynamicObjectRot(Businesses[id][BusinessTrashObjects][0], Businesses[id][BusinessTrashRot][0], Businesses[id][BusinessTrashRot][1], Businesses[id][BusinessTrashRot][2]);
			}
			
			if(IsValidDynamicObject(Businesses[id][BusinessTrashObjects][1]))
			{
				SetDynamicObjectPos(Businesses[id][BusinessTrashObjects][1], Businesses[id][BusinessTrashPos][0] + 1.6665, Businesses[id][BusinessTrashPos][1] - 0.19825, Businesses[id][BusinessTrashPos][2] - 0.163);
				SetDynamicObjectRot(Businesses[id][BusinessTrashObjects][1], Businesses[id][BusinessTrashRot][0], Businesses[id][BusinessTrashRot][1], Businesses[id][BusinessTrashRot][2] + 90.0);
			}
			
			if(IsValidDynamicObject(Businesses[id][BusinessTrashObjects][2]))
			{
				SetDynamicObjectPos(Businesses[id][BusinessTrashObjects][2], Businesses[id][BusinessTrashPos][0] - 1.3971, Businesses[id][BusinessTrashPos][1] - 0.12159, Businesses[id][BusinessTrashPos][2] - 0.3852);
				SetDynamicObjectRot(Businesses[id][BusinessTrashObjects][2], Businesses[id][BusinessTrashRot][0], Businesses[id][BusinessTrashRot][1], Businesses[id][BusinessTrashRot][2] + 44.0);
			}
			
			if(IsValidDynamicObject(Businesses[id][BusinessTrashObjects][3]))
			{
				SetDynamicObjectPos(Businesses[id][BusinessTrashObjects][3], Businesses[id][BusinessTrashPos][0] - 0.04773, Businesses[id][BusinessTrashPos][1] - 2.70459, Businesses[id][BusinessTrashPos][2] - 0.3702);
				SetDynamicObjectRot(Businesses[id][BusinessTrashObjects][3], Businesses[id][BusinessTrashRot][0], Businesses[id][BusinessTrashRot][1], Businesses[id][BusinessTrashRot][2]);
			}

			DeletePVar(playerid, "EditingTrashBin");
			SaveBusiness(id);
			SendClientMessage(playerid, WHITE, "You have moved your trash bin.");
		}
			
		if(response == EDIT_RESPONSE_CANCEL)
		{
			DeletePVar(playerid, "EditingTrashBin");
			SetDynamicObjectPos(objectid, oldX, oldY, oldZ);
			SetDynamicObjectRot(objectid, oldRX, oldRY, oldRZ);
		}
	}
	return 1;
}

forward OnBusinessTrashChange(id, oldamount, newamount);
public OnBusinessTrashChange(id, oldamount, newamount)
{
	if(oldamount > newamount)
	{
		if(newamount <= 950)
			DestroyDynamicObject(Businesses[id][BusinessTrashObjects][3]);
		if(newamount <= 700)
			DestroyDynamicObject(Businesses[id][BusinessTrashObjects][2]);
		if(newamount <= 450)
			DestroyDynamicObject(Businesses[id][BusinessTrashObjects][1]);
		if(newamount <= 200)
			DestroyDynamicObject(Businesses[id][BusinessTrashObjects][0]);
	}
	else if(newamount > oldamount)
	{
		if(newamount > 200)
		{
			if(!IsValidDynamicObject(Businesses[id][BusinessTrashObjects][0]))
				Businesses[id][BusinessTrashObjects][0] = CreateDynamicObject(2676, Businesses[id][BusinessTrashPos][0] - 0.14307, Businesses[id][BusinessTrashPos][1] - 1.57276, Businesses[id][BusinessTrashPos][2] - 0.6406, Businesses[id][BusinessTrashRot][0], Businesses[id][BusinessTrashRot][1], Businesses[id][BusinessTrashRot][2], .interiorid = Businesses[id][bExteriorID]);
		}
		if(newamount > 450)
		{
			if(!IsValidDynamicObject(Businesses[id][BusinessTrashObjects][1]))	
				Businesses[id][BusinessTrashObjects][1] = CreateDynamicObject(1450, Businesses[id][BusinessTrashPos][0] + 1.6665, Businesses[id][BusinessTrashPos][1] - 0.19825, Businesses[id][BusinessTrashPos][2] - 0.163, Businesses[id][BusinessTrashRot][0], Businesses[id][BusinessTrashRot][1], Businesses[id][BusinessTrashRot][2] + 90.0, .interiorid = Businesses[id][bExteriorID]);
		}
		if(newamount > 700)
		{
			if(!IsValidDynamicObject(Businesses[id][BusinessTrashObjects][2]))	
				Businesses[id][BusinessTrashObjects][2] = CreateDynamicObject(1264, Businesses[id][BusinessTrashPos][0] - 1.3971, Businesses[id][BusinessTrashPos][1] - 0.12159, Businesses[id][BusinessTrashPos][2] - 0.3852, Businesses[id][BusinessTrashRot][0], Businesses[id][BusinessTrashRot][1], Businesses[id][BusinessTrashRot][2] + 44.0, .interiorid = Businesses[id][bExteriorID]);
		}
		if(newamount > 950)
		{
			if(!IsValidDynamicObject(Businesses[id][BusinessTrashObjects][3]))
				Businesses[id][BusinessTrashObjects][3] = CreateDynamicObject(18862, Businesses[id][BusinessTrashPos][0] - 0.04773, Businesses[id][BusinessTrashPos][1] - 2.70459, Businesses[id][BusinessTrashPos][2] - 0.3702, Businesses[id][BusinessTrashRot][0], Businesses[id][BusinessTrashRot][1], Businesses[id][BusinessTrashRot][2], .interiorid = Businesses[id][bExteriorID]);
		}
	}
	return 1;
}

// ============= Timers =============

timer PlayerGarbageTimer[1000](i)
{
	if(Player[i][GarbageStep] > 0 && Player[i][GarbageFreeze] > 0)
	{
		if(Jobs[Player[i][Job]][JobType] != 12 && Jobs[Player[i][Job2]][JobType] != 12)
		{
			Player[i][Checkpoint] = 0;
			Player[i][GarbageStep] = 0;
			stop Player[i][GarbageTimer];
			DisablePlayerCheckpoint(i);
			new veh = GetPlayerVehicleID(i), sql = GetVSQLID(veh), idx = GetVIndex(sql);
			if(Jobs[Veh[idx][Job]][JobType] == 12)
				SetVehicleToRespawn(Veh[idx][Link]);
			return SendClientMessage(i, -1, "You don't have the garbage man job anymore!"); 
		}
		
		Player[i][GarbageFreeze] ++;
		if(Player[i][GarbageFreeze] == 11)
		{
			if(Player[i][GarbageStep] < 5)
			{
				TogglePlayerControllable(i, true);
				Player[i][GarbageStep] ++;
				Player[i][LoadingTrash] = 0; 
				new id = GetPVarInt(i, "trashID"), type = GetPVarInt(i, "TrashType");
				
				switch(type)
				{
					case TRASH_CITY:
					{
						
						if(Groups[TaxGroup][SafeMoney] < (trashPay / 5))
							SendClientMessage(i, -1, "The city was unable to pay for the trash pickup.");
						else 
						{
							Player[i][GarbagePay] += (trashPay / 5);
							Groups[TaxGroup][SafeMoney] -= (trashPay / 5);
						}
					}
					case TRASH_BIZ:
					{
						if(IsItemInStorage(id, CONTAINER_TYPE_BIZ, ITEM_TYPE_CASH, 0, 1) < (trashPay / 5))
						{
							SendClientMessage(i, -1, "The business was unable to pay for the pickup.");
						}
						else 
						{
//							Businesses[id][bVault] -= (trashPay / 5);
							RemoveFromStorage(id, CONTAINER_TYPE_BIZ, ITEM_TYPE_CASH, (trashPay / 5));
							RemoveTrash(id, 400);
							Player[i][GarbagePay] += (trashPay / 5);
						}
					}
				}
				
				id = randomTrashPos(i);
				if(id == -1)
				{
					new jid; 
					if(Jobs[Player[i][Job]][JobType] == 12)
						jid = Player[i][Job];
					else if(Jobs[Player[i][Job2]][JobType] == 12)
						jid = Player[i][Job2]; 
					else
					{
						Player[i][Checkpoint] = 0;
						Player[i][GarbageStep] = 0;
						stop Player[i][GarbageTimer];
						DisablePlayerCheckpoint(i);
						DeletePVar(i, "trashID"); 
						DeletePVar(i, "TrashType");
						new veh = GetPlayerVehicleID(i), sql = GetVSQLID(veh), idx = GetVIndex(sql);
						
						if(sql == 0)
							return SendClientMessage(i, -1, "This vehicle isn't saved!"); 
						
						if(Jobs[Veh[idx][Job]][JobType] == 12)
							SetVehicleToRespawn(Veh[idx][Link]);
						return SendClientMessage(i, -1, "You don't have the garbage man job anymore!"); 
					}
					
					SendClientMessage(i, -1, "There is no trash available to be picked up at this time, head back to the depot for your pay."); 
					Player[i][LoadingTrash] = 0; 
					Player[i][GarbageStep] = 6;
					SetPlayerCheckpoint(i, Jobs[jid][JobMiscLocationTwoX], Jobs[jid][JobMiscLocationTwoY], Jobs[jid][JobMiscLocationTwoZ], 10);
				}
				else
				{
					if(GetPVarInt(i, "TrashType") == TRASH_BIZ)
						Businesses[GetPVarInt(i, "trashID")][BusinessTrashCurrentPlayer] = INVALID_PLAYER_ID;
					
					SetPVarInt(i, "trashID", id); 
					type = GetPVarInt(i, "TrashType");
					new location[MAX_ZONE_NAME];
					switch(type)
					{
						case TRASH_BIZ:
						{
							SetPlayerCheckpoint(i, Businesses[id][BusinessTrashPos][0], Businesses[id][BusinessTrashPos][1],Businesses[id][BusinessTrashPos][2], 10);
							Get2DPosZone(Businesses[id][BusinessTrashPos][0], Businesses[id][BusinessTrashPos][1], location, MAX_ZONE_NAME);
						}
						case TRASH_CITY: 
						{
							SetPlayerCheckpoint(i, trashPos[id][0], trashPos[id][1], trashPos[id][2], 10);
							Get2DPosZone(trashPos[id][0], trashPos[id][1], location, MAX_ZONE_NAME);
						}
					}
					
					SendClientMessage(i, -1, "The garbage truck is finished crushing the trash!");
					format(string, sizeof(string), "Head to %s for your next pickup.", location);
					SendClientMessage(i, YELLOW, string);
				}
			}
			else if(Player[i][GarbageStep] == 5)
			{
				TogglePlayerControllable(i, true);
				
				new id; 
				if(Jobs[Player[i][Job]][JobType] == 12)
					id = Player[i][Job];
				else if(Jobs[Player[i][Job2]][JobType] == 12)
					id = Player[i][Job2]; 
				else
				{
					Player[i][Checkpoint] = 0;
					Player[i][GarbageStep] = 0;
					stop Player[i][GarbageTimer];
					DisablePlayerCheckpoint(i);
					DeletePVar(i, "trashID"); 
					DeletePVar(i, "TrashType");
					new veh = GetPlayerVehicleID(i), sql = GetVSQLID(veh), idx = GetVIndex(sql);
					
					if(sql == 0)
						return SendClientMessage(i, -1, "This vehicle isn't saved!"); 
					
					if(Jobs[Veh[idx][Job]][JobType] == 12)
						SetVehicleToRespawn(Veh[idx][Link]);
					return SendClientMessage(i, -1, "You don't have the garbage man job anymore!"); 
				}
				
				new bid = GetPVarInt(i, "trashID"), type = GetPVarInt(i, "TrashType");
				switch(type)
				{
					case TRASH_CITY:
					{
						
						if(Groups[TaxGroup][SafeMoney] < (trashPay / 5))
							SendClientMessage(i, -1, "The city was unable to pay for the trash pickup.");
						else 
						{
							Player[i][GarbagePay] += (trashPay / 5);
							Groups[TaxGroup][SafeMoney] -= (trashPay / 5);
						}
					}
					case TRASH_BIZ:
					{
						if(IsItemInStorage(bid, CONTAINER_TYPE_BIZ, ITEM_TYPE_CASH, 0, 1) < (trashPay / 5))
						{
							SendClientMessage(i, -1, "The business was unable to pay for the pickup.");
						}
						else 
						{
//							Businesses[bid][bVault] -= (trashPay / 5);
							RemoveFromStorage(bid, CONTAINER_TYPE_BIZ, ITEM_TYPE_CASH, (trashPay / 5));
							RemoveTrash(bid, 400);
							Player[i][GarbagePay] += (trashPay / 5);
						}
					}
				}
				Player[i][LoadingTrash] = 0; 
				Player[i][GarbageStep] = 6;
				SetPlayerCheckpoint(i, Jobs[id][JobMiscLocationTwoX], Jobs[id][JobMiscLocationTwoY], Jobs[id][JobMiscLocationTwoZ], 10);
				SendClientMessage(i, -1, "You are done picking up the trash. Return to the dump to unload it."); 
			}	
			else if(Player[i][GarbageStep] == 6)
			{
				new id; 
				if(Jobs[Player[i][Job]][JobType] == 12)
					id = Player[i][Job];
				else if(Jobs[Player[i][Job2]][JobType] == 12)
					id = Player[i][Job2]; 
				else
				{
					Player[i][Checkpoint] = 0;
					Player[i][GarbageStep] = 0;
					stop Player[i][GarbageTimer];
					DisablePlayerCheckpoint(i);
					DeletePVar(i, "trashID"); 
					DeletePVar(i, "TrashType");
					new veh = GetPlayerVehicleID(i), sql = GetVSQLID(veh), idx = GetVIndex(sql);
					
					if(sql == 0)
						return SendClientMessage(i, -1, "This vehicle isn't saved!"); 
					
					if(Jobs[Veh[idx][Job]][JobType] == 12)
						SetVehicleToRespawn(Veh[idx][Link]);
					return SendClientMessage(i, -1, "You don't have the garbage man job anymore!"); 
				}
				
				TogglePlayerControllable(i, true);
				Player[i][GarbageStep] = 7;
				
				DisablePlayerCheckpoint(i);
				SetPlayerCheckpoint(i, Jobs[id][JobMiscLocationOneX], Jobs[id][JobMiscLocationOneY], Jobs[id][JobMiscLocationOneZ], 10);
				SendClientMessage(i, -1, "You are done dumping the trash. Head back to the depot for your payment.");
			}
		}
	}
	return 1;
}

// ============= Commands =============

CMD:loadtrash(playerid, params[])
{
	if(Jobs[Player[playerid][Job]][JobType] != 12 && Jobs[Player[playerid][Job2]][JobType] != 12)
		return SendClientMessage(playerid, -1, "You do not have the garbage man job.");
		
	if(Player[playerid][GarbageStep] == 0)
		return SendClientMessage(playerid, -1, "You aren't currently doing a garbage run!");
		
	if(Player[playerid][LoadingTrash] == 0)
		return SendClientMessage(playerid, -1, "You do not need to load the trash right now!"); 
	
	new veh = NearestVehicle(playerid), sql = GetVSQLID(veh), idx = GetVIndex(sql); 
	
	if(sql == 0)
		return SendClientMessage(playerid, -1, "This vehicle isn't saved!");
	
	if(Jobs[Veh[idx][Job]][JobType] != 12)
		return SendClientMessage(playerid, -1, "You aren't close enough to a garbage truck!"); 
		
	if(sql != GetPVarInt(playerid, "garbageSQL"))
		return SendClientMessage(playerid, -1, "This isn't the garbage truck you started in!"); 
		
	if(!IsVehicleFacingPlayer(veh, playerid, true))
		return SendClientMessage(playerid, -1, "You must be at the back of the garbage truck to load the trash!");
	
	new id = GetPVarInt(playerid, "trashID"), type = GetPVarInt(playerid, "TrashType");
	if(type == TRASH_CITY)
	{
		if(!IsPlayerInRangeOfPoint(playerid, 10, trashPos[id][0], trashPos[id][1], trashPos[id][2]))
			return SendClientMessage(playerid, -1, "You aren't close enough to the trash to do this!"); 
	}
	else if(type == TRASH_BIZ)
	{
		if(!IsPlayerInRangeOfPoint(playerid, 10, Businesses[id][BusinessTrashPos][0], Businesses[id][BusinessTrashPos][1], Businesses[id][BusinessTrashPos][2]))
			return SendClientMessage(playerid, -1, "You aren't close enough to the trash to do this!!"); 
	}
	
	DisablePlayerCheckpoint(playerid); 
	format(string, sizeof(string), "* %s throws the trash into the back of the truck and hits a button.", GetNameEx(playerid)); 
	NearByMessage(playerid, NICESKY, string); 
	SendClientMessage(playerid, -1, "Please wait while the garbage truck crushes the garbage."); 
	TogglePlayerControllable(playerid, false); 
	Player[playerid][GarbageFreeze] = 1;
	return 1;
}
	
CMD:endtrash(playerid, params[])
{
	if(Jobs[Player[playerid][Job]][JobType] != 12 && Jobs[Player[playerid][Job2]][JobType] != 12)
		return SendClientMessage(playerid, -1, "You do not have the garbage man job.");
		
	if(Player[playerid][GarbageStep] == 0)
		return SendClientMessage(playerid, -1, "You aren't currently doing a garbage run!");
	
	if(GetPVarInt(playerid, "TrashType") == TRASH_BIZ)
		Businesses[GetPVarInt(playerid, "trashID")][BusinessTrashCurrentPlayer] = INVALID_PLAYER_ID;
	
	Player[playerid][Checkpoint] = 0;
	Player[playerid][GarbageStep] = 0;
	Player[playerid][GarbageCooldown] = gettime() + 3600;
	stop Player[playerid][GarbageTimer];
	DisablePlayerCheckpoint(playerid);
	
	new sql, idx, veh;
	if(IsPlayerInAnyVehicle(playerid))
	{
		veh = GetPlayerVehicleID(playerid);
		sql = GetVSQLID(veh);
		idx = GetVIndex(sql);
	} 
	else 
	{
		sql = GetPVarInt(playerid, "garbageSQL");
		idx = GetVIndex(sql);
	}
	
	if(sql == 0)
		return 1;
		
	if(idx == -1)
		return 1;
	
	if(Jobs[Veh[idx][Job]][JobType] == 12)
		SetVehicleToRespawn(Veh[idx][Link]);
	SendClientMessage(playerid, -1, "You have ended your garbage run!"); 
	return 1;
}

CMD:changegarbagepay(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 6)
		return 1;
		
	if(isnull(params) || !IsNumeric(params) || strval(params) < 0)
		return SendClientMessage(playerid, -1, "SYNTAX: /changegarbagepay [number]");
		
	format(string, sizeof(string), "You have set the garbage man job pay to %s.", PrettyMoney(strval(params)));
	SendClientMessage(playerid, -1, string);
	format(string, sizeof(string), "%s has set the garbage man job pay to %s.", Player[playerid][AdminName], PrettyMoney(strval(params)));
	AdminActionsLog(string); 
	trashPay = strval(params);
	dini_IntSet("Assets.ini", "GarbagePay", trashPay);
	return 1;
}

CMD:changetrashpos(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 6)
		return 1;
		
	if(isnull(params) || !IsNumeric(params) || strval(params) < 0 || strval(params) > MAX_TRASH_POINTS)
		return SendClientMessage(playerid, -1, "SYNTAX: /changetrashpos [number]");
		
	new Float:pPos[3], id = strval(params);
	GetPlayerPos(playerid, pPos[0], pPos[1], pPos[2]);
	trashPos[id][0] = pPos[0];
	trashPos[id][1] = pPos[1];
	trashPos[id][2] = pPos[2];
	
	format(string, sizeof(string), "TrashPoint%dX", id);
	dini_FloatSet("Misc/TrashPoints.ini", string, trashPos[id][0]);
	
	format(string, sizeof(string), "TrashPoint%dY", id);
	dini_FloatSet("Misc/TrashPoints.ini", string, trashPos[id][1]);
	
	format(string, sizeof(string), "TrashPoint%dZ", id);
	dini_FloatSet("Misc/TrashPoints.ini", string, trashPos[id][2]);
	
	format(string, sizeof(string), "You have succesfully changed the position of trash point %d.", id);
	SendClientMessage(playerid, -1, string);
	return 1;
}

CMD:movetrashcan(playerid, params[])
{
	if(Player[playerid][Business] == 0)
		return SendClientMessage(playerid, -1, "You must own a business to use this command.");
		
	new Float:pPos[3], bID = Player[playerid][Business];
	GetPlayerPos(playerid, pPos[0], pPos[1], pPos[2]);
	
	if(GetPlayerDistanceFromPoint(playerid, Businesses[bID][bExteriorX], Businesses[bID][bExteriorY], Businesses[bID][bExteriorZ]) > 40.0)
		return SendClientMessage(playerid, -1, "You must be near your business to place your trash bin down.");

	if(IsValidDynamicObject(Businesses[bID][BusinessTrashBinObject]))
		DestroyDynamicObject(Businesses[bID][BusinessTrashBinObject]);
	
	Businesses[bID][BusinessTrashPos][0] = pPos[0];
	Businesses[bID][BusinessTrashPos][1] = pPos[1] + 1;
	Businesses[bID][BusinessTrashPos][2] = pPos[2];
	Businesses[bID][BusinessTrashBinObject] = CreateDynamicObject(910, Businesses[bID][BusinessTrashPos][0], Businesses[bID][BusinessTrashPos][1], Businesses[bID][BusinessTrashPos][2], 0.0, 0.0, 0.0, -1, Businesses[bID][bExteriorID]);
	SendClientMessage(playerid, -1, "You have moved your trash bin.");
	format(string, sizeof(string), "%s has moved business ID %d's trash bin.", bID);
	StatLog(string);
	return 1;
}

CMD:edittrashcan(playerid, params[])
{
	if(Player[playerid][Business] == 0)
		return SendClientMessage(playerid, -1, "You must own a business to use this command.");
		
	new id = Player[playerid][Business];
	if(GetPlayerDistanceFromPoint(playerid, Businesses[id][BusinessTrashPos][0], Businesses[id][BusinessTrashPos][1], Businesses[id][BusinessTrashPos][2]) > 10)
		return SendClientMessage(playerid, -1, "You are not near your business' trash bin.");
		
	if(!IsValidDynamicObject(Businesses[id][BusinessTrashBinObject]))
		return SendClientMessage(playerid, -1, "You need to place your trash bin first with /movetrashcan.");
		
	EditDynamicObject(playerid, Businesses[id][BusinessTrashBinObject]);
	SetPVarInt(playerid, "EditingTrashBin", 1);
	return 1;
}

CMD:setbusinesstrash(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
	
	new id, amount;
	if(sscanf(params, "dd", id, amount))
		return SendClientMessage(playerid, -1, "SYNTAX: /setbusinesstrash [business id] [amount]");
		
	if(DoesBusinessExist(id))
	{
		OnBusinessTrashChange(id, Businesses[id][BusinessTrashAmount], amount);
		Businesses[id][BusinessTrashAmount] = amount;
		format(string, sizeof(string), "You have set business %d (%s)'s trash to %d.", id, Businesses[id][bName], amount);
		SendClientMessage(playerid, WHITE, string);
		SaveBusiness(id);
	}
	else
	{
		SendClientMessage(playerid, WHITE, "Invalid business ID.");
	}
	return 1;
}

// ============= Functions =============

stock LoadTrashPoints()
{
	if(!fexist("Misc/TrashPoints.ini"))
		dini_Create("Misc/TrashPoints.ini");
	
	for(new i; i < MAX_TRASH_POINTS; i++)
	{
		format(string, sizeof(string), "TrashPoint%dX", i);
		trashPos[i][0] = dini_Float("Misc/TrashPoints.ini", string);
		
		format(string, sizeof(string), "TrashPoint%dY", i);
		trashPos[i][1] = dini_Float("Misc/TrashPoints.ini", string);
		
		format(string, sizeof(string), "TrashPoint%dZ", i);
		trashPos[i][2] = dini_Float("Misc/TrashPoints.ini", string);
	}
	print("Trash points loaded!");
	return 1;
}

stock randomTrashPos(playerid)
{	
	new id = -1, found;
	
	for(new i; i < MAX_BUSINESSES; i++)
	{
		if(Businesses[i][BusinessTrashPos][0] == 0.00 && Businesses[i][BusinessTrashPos][1] == 0.00 && Businesses[i][BusinessTrashPos][2] == 0.00)
			continue;
		
		if(IsPlayerInRangeOfPoint(playerid, 10.0, Businesses[i][BusinessTrashPos][0], Businesses[i][BusinessTrashPos][1], Businesses[i][BusinessTrashPos][2]))
			continue;
		
		if(Businesses[i][BusinessTrashStatus] == 1)
			continue;
		
		if(Businesses[i][BusinessTrashAmount] < 400)
			continue; 
			
		if(IsItemInStorage(i, CONTAINER_TYPE_BIZ, ITEM_TYPE_CASH, 0, 1) < (trashPay / 5))
			continue;
		
		if(Businesses[i][BusinessTrashCurrentPlayer] != INVALID_PLAYER_ID && IsPlayerConnected(Businesses[i][BusinessTrashCurrentPlayer]) && Player[Businesses[i][BusinessTrashCurrentPlayer]][GarbageStep] > 0)
			continue;
		
		id = i;
		Businesses[id][BusinessTrashCurrentPlayer] = playerid;
		SetPVarInt(playerid, "TrashType", TRASH_BIZ);
		found = 1;
		break;
	}
	
	/*if(found == 0)
	{
		for(new i; i < MAX_TRASH_POINTS; i++)
		{
			if(trashPos[i][0] == 0.00 && trashPos[i][1] == 0.00 && trashPos[i][2] == 0.00)
				continue;
				
			if(trashCooldown[i] > gettime())
				continue;
		
			if(IsPlayerInRangeOfPoint(playerid, 10, trashPos[i][0], trashPos[i][1], trashPos[i][2]))
				continue; 
				
			id = i;
			trashCooldown[id] = gettime() + 1800;
			SetPVarInt(playerid, "TrashType", TRASH_CITY);
			found = 1;
			break;
		}
	}*/
	
	if(found == 0)
	{
		id = -1;
		Player[playerid][GarbageCooldown] = gettime() + 300;
		return -1;
	}
	
	return id;
}

stock GenerateTrash(bid, amount)
{
	OnBusinessTrashChange(bid, Businesses[bid][BusinessTrashAmount], Businesses[bid][BusinessTrashAmount] + amount);
	Businesses[bid][BusinessTrashAmount] += amount;
	return 1;
}

stock RemoveTrash(bid, amount)
{
	OnBusinessTrashChange(bid, Businesses[bid][BusinessTrashAmount], Businesses[bid][BusinessTrashAmount] - amount);
	Businesses[bid][BusinessTrashAmount] -= amount;
}