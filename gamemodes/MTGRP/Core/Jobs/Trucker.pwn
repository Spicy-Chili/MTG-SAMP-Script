/*
#		MTG Trucker
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

#define 		TRUCKER_NAME			"Jeremy Rigger"
#define 		TRUCKER_NUMBER			"343"
#define 		MAX_WORKERS				2

new Float:TruckerPickup[6], TruckerPickups[2], DelivererSupplies, Workers[MAX_WORKERS] = -1, EmptyGasStations;

hook OnPlayerConnect(playerid)
{
	for(new i; i < MAX_WORKERS; i++)
		if(Workers[i] == playerid)
			Workers[i] = -1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	for(new i; i < MAX_WORKERS; i++)
		if(Workers[i] == playerid)
			Workers[i] = -1;
	
	if(Player[playerid][TruckDelivery] == 2)
	{
		Player[playerid][TruckPenalty] = 1;
	}
}

ptask TruckerUpdate[30 * 1000](playerid) // Wil probably make this 30 seconds.
{
	if(GetPVarInt(playerid, "BeenAsked_Trucker") - gettime() <= 0 && GetPVarInt(playerid, "BeenAsked_Trucker") != 0)
	{
		new string[128];
		format(string, sizeof(string), "Hello??? %s? Have you got a new number? Whatever, I will find somebody else!", GetFirstName(playerid));
		MessageFromBoss(playerid, string);
		DeletePVar(playerid, "BeenAsked_Trucker");
		SetPVarInt(playerid, "DontAsk_Trucker", gettime() + (5 * 60));

		ResetTruckerVariables(playerid);
	}

	if(GetPVarInt(playerid, "TruckerTimer") - gettime() <= 0 && GetPVarInt(playerid, "TruckerTimer") != 0)
	{
		MessageFromBoss(playerid, "What the hell are you doing!? You gonna do your job or what?");
		DeletePVar(playerid, "TruckerTimer");

		ResetTruckerVariables(playerid);

		if(IsPlayerInAnyVehicle(playerid))
		{
			new veh = GetPlayerVehicleID(playerid), sql = GetVSQLID(veh), idx = GetVIndex(sql);
			if(Jobs[Veh[idx][Job]][JobType] == JOB_TRUCKER)
			{
				if(GetVehicleTrailer(veh))
					SetVehicleToRespawn(GetVehicleTrailer(veh));
				SetVehicleToRespawn(veh);
			}
		}
	}

	if(GetFreeWorkerID() != -1 && random(10) == 5)
	{
		new supplies = 0, acceptingfuel = 0;
		foreach(Player, i)
		{
			if(Player[i][TruckDelivery] == 1)
				supplies = 1;
		}

		if(DelivererSupplies > 9700)
			supplies = 1;

		for(new i; i < MAX_BUSINESSES; i++)
		{
			if(Businesses[i][bType] != 16)
				continue;

			if(GetStoredAmountOf(Businesses[i][bStorage], "Money") > 5000)
				acceptingfuel = 1;
		}

		if(acceptingfuel == 1 || supplies == 0)
			GetWorker(playerid);
	}
}

stock GetFreeWorkerID()
{
	for(new i; i < MAX_WORKERS; i++)
	{
		if(Workers[i] == -1)
		{
			return i;
		}
	}
	return -1;
}

stock TruckerBossReply(playerid, message[])
{
	if(!PlayerHasJob(playerid, JOB_TRUCKER))
		return 1;

	new string[128];
	if(GetPVarInt(playerid, "BeenAsked_Trucker") - gettime() > 0)
	{
		if(strfind(message, "yes", true, 0) != -1 || strfind(message, "yep", true, 0) != -1 || strfind(message, "yea", true, 0) != -1 || strfind(message, "yer", true, 0) != -1 || strfind(message, "im not busy", true, 0) != -1 || strfind(message, "im available", true, 0) != -1 || strfind(message, "sure", true, 0) != -1)
		{
			DeletePVar(playerid, "BeenAsked_Trucker");

			new run; // 1 = supplies, 2 = fuel
			foreach(Player, i)
			{
				if(Player[i][TruckDelivery] != 0)
				{
					run = Player[i][TruckDelivery];
					break;
				}
			}

			if(DelivererSupplies <= 9700 && run != 1)
				Player[playerid][TruckDelivery] = 1;

			if(Player[playerid][TruckDelivery] == 0)
			{
				for(new i = 1; i < MAX_BUSINESSES; i++)
				{
					if(Businesses[i][bType] != 16)
						continue;

					if(GetStoredAmountOf(Businesses[i][bStorage], "Money") > 2000)
						Player[playerid][TruckDelivery] = 2;
				}
			}


			switch(Player[playerid][TruckDelivery])
			{
				case 1:	format(string, sizeof(string), "SMS from %s: Oh, great! Head to the depot and grab a truck. I need you to get supplies for RS Haul.", GetContactName(Player[playerid][PhoneN], strval(TRUCKER_NUMBER)));
				case 2:	format(string, sizeof(string), "SMS from %s: Oh, great! Head to the depot and grab a truck. I need you to get fuel for one of the gas stations.", GetContactName(Player[playerid][PhoneN], strval(TRUCKER_NUMBER)));
				default:
				{
					for(new i; i < MAX_WORKERS; i++)
					{
						if(Workers[i] == playerid)
							Workers[i] = -1;
					}

					format(string, sizeof(string), "SMS from %s: Wait, hold on.. Seems I don't need you any more, haha!! Sorry %s, next time. :)", GetContactName(Player[playerid][PhoneN], strval(TRUCKER_NUMBER)));
					SendClientMessage(playerid, PHONE, string);
					PlayerPlaySound(playerid, 21000, 0.00, 0.00, 0.00);
					//SetPVarInt(playerid, "DontAsk_Trucker", gettime() + (5 * 60));
					return 1;
				}
			}

			SetPVarInt(playerid, "TruckerTimer", gettime() + (15 * 60));
			Player[playerid][TruckStage] = 1;

			PlayerPlaySound(playerid, 21000, 0.00, 0.00, 0.00);
			SendClientMessage(playerid, PHONE, string);
			format(string, sizeof(string), "SMS from %s: You've got 15 minutes to get the work done so get on it! Thanks champ.", GetContactName(Player[playerid][PhoneN], strval(TRUCKER_NUMBER)));
			SendClientMessage(playerid, PHONE, string);
			return 1;
		}
		else if(strfind(message, "no", true, 0) != -1 || strfind(message, "im busy", true, 0) != -1 || strfind(message, "i cant", true, 0) != -1 || strfind(message, "nah", true, 0) != -1)
		{
			for(new i; i < MAX_WORKERS; i++)
			{
				if(Workers[i] == playerid)
					Workers[i] = -1;
			}

			DeletePVar(playerid, "BeenAsked_Trucker");
			SetPVarInt(playerid, "DontAsk_Trucker", gettime() + (5 * 60));

			PlayerPlaySound(playerid, 21000, 0.00, 0.00, 0.00);
			format(string, sizeof(string), "SMS from %s: Bloody hell, %s! Fine, I will get somebody else to do the job!!", GetContactName(Player[playerid][PhoneN], strval(TRUCKER_NUMBER)), GetFirstName(playerid));
			SendClientMessage(playerid, PHONE, string);
			return 1;
		}
		else
		{
			PlayerPlaySound(playerid, 21000, 0.00, 0.00, 0.00);
			format(string, sizeof(string), "SMS from %s: Just give me a yes or a no, I hate reading my phone!!", GetContactName(Player[playerid][PhoneN], strval(TRUCKER_NUMBER)), GetFirstName(playerid));
			SendClientMessage(playerid, PHONE, string);
			return 1;
		}
	}

	PlayerPlaySound(playerid, 21000, 0.00, 0.00, 0.00);
	format(string, sizeof(string), "SMS from %s: Don't send me messages unless I ask you for something, %s!!", GetContactName(Player[playerid][PhoneN], strval(TRUCKER_NUMBER)), GetFirstName(playerid));
	SendClientMessage(playerid, PHONE, string);
	return 1;
}

stock GetWorker(playerid)
{
	if(!PlayerHasJob(playerid, JOB_TRUCKER))
		return 1;

	if(Player[playerid][AdminDuty])
		return 1;

	if(Player[playerid][PhoneN] == -1)
		return 1;

	if(strval(GetPhoneInfo(Player[playerid][PhoneN], "status")) == 0)
		return 1;

	if(Player[playerid][TruckDelivery] > 0)
		return 1;

	if(GetPVarInt(playerid, "BeenAsked_Trucker") - gettime() > 0)
		return 1;

	if(GetPVarInt(playerid, "DontAsk_Trucker") - gettime() > 0)
		return 1;

	SetPVarInt(playerid, "BeenAsked_Trucker", gettime() + 60);

	new string[128], rand = random(4);
	switch(rand)
	{
		case 0: format(string, sizeof(string), "SMS from %s: Oi, %s, I need you to do some work! Are you available at the moment?", GetContactName(Player[playerid][PhoneN], strval(TRUCKER_NUMBER)), GetFirstName(playerid));
		case 1: format(string, sizeof(string), "SMS from %s: Hey mate, are you available?? I've got some work you can do.", GetContactName(Player[playerid][PhoneN], strval(TRUCKER_NUMBER)));
		case 2: format(string, sizeof(string), "SMS from %s: Oi, you free? I need you to do some work for me if you are.", GetContactName(Player[playerid][PhoneN], strval(TRUCKER_NUMBER)));
		case 3: format(string, sizeof(string), "SMS from %s: %s, can you do some work for me please mate.", GetContactName(Player[playerid][PhoneN], strval(TRUCKER_NUMBER)), GetFirstName(playerid));
		default: format(string, sizeof(string), "SMS from %s: Oi, %s, I need you to do some work! Are you available at the moment?", GetContactName(Player[playerid][PhoneN], strval(TRUCKER_NUMBER)), GetFirstName(playerid));
	}
	SendClientMessage(playerid, PHONE, string);
	PlayerPlaySound(playerid, 21000, 0.00, 0.00, 0.00);

	new id = GetFreeWorkerID();
	if(id != -1)
		Workers[id] = playerid;

	return 1;
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER && oldstate == PLAYER_STATE_ONFOOT)
	{
		new VehID = GetPlayerVehicleID(playerid), sql = GetVSQLID(VehID), idx = GetVIndex(sql);
		if(sql != 0 && Jobs[Veh[idx][Job]][JobType] == JOB_TRUCKER && Player[playerid][AdminDuty] == 0 && Player[playerid][TruckStage] == 1)
		{
			switch(Player[playerid][TruckDelivery])
			{
				case 1: SetPlayerCheckpoint(playerid, TruckerPickup[0], TruckerPickup[1], TruckerPickup[2], 10.0);
				case 2: SetPlayerCheckpoint(playerid, TruckerPickup[3], TruckerPickup[4], TruckerPickup[5], 10.0);
			}
		}
	}
	return 1;
}

// CMD:startdelivery(playerid, params[])
// {
	// if(Jobs[Player[playerid][Job]][JobType] != JOB_TRUCKER && Jobs[Player[playerid][Job2]][JobType] != JOB_TRUCKER)
		// return SendClientMessage(playerid, -1, "You do not have the trucker job.");

	// new job = (Jobs[Player[playerid][Job]][JobType] == JOB_TRUCKER) ? (Player[playerid][Job]) : (Player[playerid][Job2]);
	// if(!IsPlayerInRangeOfPoint(playerid, 5.0, Jobs[job][JobMiscLocationOneX], Jobs[job][JobMiscLocationOneY], Jobs[job][JobMiscLocationOneZ]) || GetPlayerVirtualWorld(playerid) != 0)
		// return SendClientMessage(playerid, -1, "You are not in range of the point to start a delivery.");

	// if(Player[playerid][LicenseSuspended] > 0)
		// return SendClientMessage(playerid, -1, "Your license is currently suspended! You may not do a trucker delivery until your license is cleared.");

	// if(Player[playerid][TruckDelivery] > 0)
		// return SendClientMessage(playerid, -1, "You are already on a delivery.");

	// ShowPlayerDialog(playerid, TRUCKER_DELIVERPOINT, DIALOG_STYLE_LIST, "Choose what you want to deliver", "{FFFFFF}Supplies\nFuel", "Select", "Cancel");
	// return 1;
// }

CMD:finishdelivery(playerid)
{
	if(!PlayerHasJob(playerid, JOB_TRUCKER))
		return SendClientMessage(playerid, -1, "You do not have the trucker job.");

	new job = (Jobs[Player[playerid][Job]][JobType] == JOB_TRUCKER) ? (Player[playerid][Job]) : (Player[playerid][Job2]);
	if(!IsPlayerInRangeOfPoint(playerid, 5.0, Jobs[job][JobMiscLocationTwoX], Jobs[job][JobMiscLocationTwoY], Jobs[job][JobMiscLocationTwoZ]) || GetPlayerVirtualWorld(playerid) != 0)
		return SendClientMessage(playerid, -1, "You are not in range of the point to finish a delivery.");

	if(Player[playerid][TruckDelivery] == 0)
		return SendClientMessage(playerid, -1, "You are not on a delivery.");

	if(!IsPlayerInAnyVehicle(playerid))
		return SendClientMessage(playerid, -1, "You must be in your truck to complete your delivery.");

	new vehicleid = GetPlayerVehicleID(playerid), sql = GetVSQLID(vehicleid), idx = GetVIndex(sql), trailerid = GetVehicleTrailer(vehicleid);
	if(sql == 0 || Jobs[Veh[idx][Job]][JobType] != JOB_TRUCKER || sql != Player[playerid][TruckSQLID])
		return SendClientMessage(playerid, -1, "You must be in your truck to complete your delivery.");

	if(trailerid == 0)
		return SendClientMessage(playerid, -1, "You must bring the trailer here aswell to get your pay.");

	if(trailerid == 435 && Player[playerid][TruckDelivery] != 1)
		return SendClientMessage(playerid, -1, "You must return the trailer you used before we can pay you.");
	else if(trailerid == 584 && Player[playerid][TruckDelivery] != 2)
		return SendClientMessage(playerid, -1, "You must return the trailer you used before we can pay you.");

	new Float:vhealth, string[128];
	GetVehicleHealth(vehicleid, vhealth);
	if(vhealth < 980)
	{
		format(string, sizeof(string), "Ah shit, %s! You've damaged the bloody truck. Your pay will instead be used for repairs..", GetFirstName(playerid));
		MessageFromBoss(playerid, string);
		return ResetTruckerVariables(playerid), SetVehicleToRespawn(vehicleid), SetVehicleToRespawn(trailerid);
	}

	if(Player[playerid][TruckStage] != 3)
		return SendClientMessage(playerid, -1, "You have not delivered any fuel or supplies yet!");

	switch(Player[playerid][TruckDelivery])
	{
		case 1:
		{
			SendClientMessage(playerid, -1, "You have collected your payment for delivering the supplies.");
			Player[playerid][Money] += 2000;
			DelivererSupplies += Player[playerid][TruckSupplies];

			SavePlayerData(playerid);
			ResetTruckerVariables(playerid);

			format(string, sizeof(string), "SMS from %s: Thanks for doing that, %s.", GetContactName(Player[playerid][PhoneN], strval(TRUCKER_NUMBER)), GetFirstName(playerid));
			SendClientMessage(playerid, PHONE, string);
			PlayerPlaySound(playerid, 21000, 0.00, 0.00, 0.00);
			Player[playerid][TotalTruckRuns]++;

			SetPVarInt(playerid, "DontAsk_Trucker", gettime() + (5 * 60));

			SetVehicleToRespawn(vehicleid);
			SetVehicleToRespawn(trailerid);
		}
		case 2:
		{
			new biz = Player[playerid][TruckBiz];
			if(Businesses[biz][bType] != 16)
				return SendClientMessage(playerid, -1, "Something happened, brah! You delivered to a business that ain't a gas station! Report to admin/dev.");

			new dis = GetPVarInt(playerid, "GasStationDistance"), payment, penalty;
			if(dis == 1)
			{
				payment = 1000;
//				Businesses[biz][bVault] -= 1000;
				RemoveFromStorage(biz, CONTAINER_TYPE_BIZ, ITEM_TYPE_CASH, 1000);
			}
			else if(dis == 2)
			{
				payment = 1500;
//				Businesses[biz][bVault] -= 1500;
				RemoveFromStorage(biz, CONTAINER_TYPE_BIZ, ITEM_TYPE_CASH, 1500);
			}
			else if(dis == 3)
			{
				payment = 2000;
//				Businesses[biz][bVault] -= 2000;
				RemoveFromStorage(biz, CONTAINER_TYPE_BIZ, ITEM_TYPE_CASH, 2000);
			}
			else
				SendClientMessage(playerid, -1, "Error: Something went wrong, create a bug report. Sorry about that.");
			
			if(Player[playerid][TruckPenalty] == 1)
			{
				penalty = payment / 10;
				payment = payment - penalty;
				Player[playerid][Money] += payment;
				Player[playerid][TruckPenalty] = 0;
				SendClientMessage(playerid, -1, "Your collected payment has been docked by 10 percent for cancelling a previous run.");
			}
			else
			{
				Player[playerid][Money] += payment;
				SendClientMessage(playerid, -1, "You have collected your payment for the delivering supplies.");
			}

			SavePlayerData(playerid);
			ResetTruckerVariables(playerid);

			format(string, sizeof(string), "SMS from %s: Thanks for doing that, %s.", GetContactName(Player[playerid][PhoneN], strval(TRUCKER_NUMBER)), GetFirstName(playerid));
			SendClientMessage(playerid, PHONE, string);
			PlayerPlaySound(playerid, 21000, 0.00, 0.00, 0.00);
			Player[playerid][TotalTruckRuns]++;

			SetPVarInt(playerid, "DontAsk_Trucker", gettime() + (5 * 60));

			SetVehicleToRespawn(vehicleid);
			SetVehicleToRespawn(trailerid);
		}
		default: return SendClientMessage(playerid, -1, "Something is bugged, brah! Report it to an admin/dev.");
	}
	DeletePVar(playerid, "TruckerTimer");
	return 1;
}

CMD:quitdelivery(playerid)
{
	if(!PlayerHasJob(playerid, JOB_TRUCKER))
		return SendClientMessage(playerid, -1, "You do not have the trucker job.");

	if(Player[playerid][TruckDelivery] == 0)
		return SendClientMessage(playerid, -1, "You are not on a delivery.");

	SendClientMessage(playerid, -1, "You have cancelled your delivery.");
	ResetTruckerVariables(playerid);
	if(IsPlayerInAnyVehicle(playerid))
	{
		new vehicleid = GetPlayerVehicleID(playerid), sql = GetVSQLID(vehicleid), idx = GetVIndex(sql);

		if(sql == 0)
			return 1;

		new trailerid = GetVehicleTrailer(vehicleid);

		if(Jobs[Veh[idx][Job]][JobType] == JOB_TRUCKER)
			SetVehicleToRespawn(vehicleid);

		if(trailerid != 0)
			SetVehicleToRespawn(trailerid);
	}

	if(Player[playerid][TruckDelivery] == 2)
	{
		Player[playerid][TruckPenalty] = 1;
		MessageFromBoss(playerid, "You're kidding me? I'm gonna have to dock your next pay because of this!");
	}
	else
		MessageFromBoss(playerid, "Pathetic effort mate, I hope there is a bloody good reason for not completing your work!");

	DeletePVar(playerid, "TruckerTimer");
	SetPVarInt(playerid, "DontAsk_Trucker", gettime() + (5 * 60));
	return 1;
}

stock ResetTruckerVariables(playerid)
{
	Player[playerid][TruckSupplies] = 0;
	Player[playerid][TruckDelivery] = 0;
	Player[playerid][TruckLoadTimer] = Timer:-1;
	Player[playerid][TruckUnloadTimer] = Timer:-1;
	Player[playerid][TruckBiz] = 0;
	Player[playerid][TruckStage] = 0;
	Player[playerid][TruckSQLID] = 0;
	Player[playerid][SuppliesDelivered] = 0;
	Player[playerid][SuppliesLoaded] = 0;

	for(new i; i < MAX_WORKERS; i++)
	{
		if(Workers[i] == playerid)
			Workers[i] = -1;
	}
	DeletePVar(playerid, "TruckerTimer");
	DeletePVar(playerid, "BeenAsked_Trucker");
	return 1;
}

CMD:findsupplypickup(playerid, params[])
{
	if(!PlayerHasJob(playerid, JOB_TRUCKER))
		return SendClientMessage(playerid, -1, "You do not have the trucker job.");

	if(Player[playerid][TruckDelivery] != 1)
		return SendClientMessage(playerid, -1, "You must be delivering supplies to use this command.");

	if(Player[playerid][Checkpoint])
		return SendClientMessage(playerid, -1, "You already have a checkpoint.");

	Player[playerid][Checkpoint] = 1;
	Player[playerid][TruckStage] = 1;
	SendClientMessage(playerid, -1, "A checkpoint has been placed at the location where you pickup supplies to deliver.");
	SetPlayerCheckpoint(playerid, TruckerPickup[0], TruckerPickup[1], TruckerPickup[2], 3.0);
	Player[playerid][Checkpoint] = 1;
	return 1;
}

CMD:findgaspickup(playerid, params[])
{
	if(!PlayerHasJob(playerid, JOB_TRUCKER))
		return SendClientMessage(playerid, -1, "You do not have the trucker job.");

	if(Player[playerid][TruckDelivery] != 2)
		return SendClientMessage(playerid, -1, "You must be delivering gas to use this command.");

	if(Player[playerid][Checkpoint])
		return SendClientMessage(playerid, -1, "You already have a checkpoint.");

	Player[playerid][Checkpoint] = 1;
	Player[playerid][TruckStage] = 1;
	SendClientMessage(playerid, -1, "A checkpoint has been placed at the location where you pickup gas to deliver.");
	SetPlayerCheckpoint(playerid, TruckerPickup[3], TruckerPickup[4], TruckerPickup[5], 3.0);
	Player[playerid][Checkpoint] = 1;
	return 1;
}

CMD:loadtruck(playerid)
{
	if(!PlayerHasJob(playerid, JOB_TRUCKER))
		return SendClientMessage(playerid, -1, "You do not have the trucker job.");

	if(Player[playerid][TruckDelivery] == 0)
		return SendClientMessage(playerid, -1, "You have not started a delivery.");

	if(Player[playerid][SuppliesLoaded] != 0)
		return SendClientMessage(playerid, -1, "You have already loaded the truck.");

	if(!IsPlayerInAnyVehicle(playerid))
		return SendClientMessage(playerid, -1, "You must be in a vehicle to do this.");

	new sql = GetVSQLID(GetPlayerVehicleID(playerid)), idx = GetVIndex(sql);
	new job = (Jobs[Player[playerid][Job]][JobType] == JOB_TRUCKER) ? (Player[playerid][Job]) : (Player[playerid][Job2]);
	if(sql == 0 || Veh[idx][Job] != job)
		return SendClientMessage(playerid, -1, "You must be in a vehicle assigned to the trucker job.");

	new engine, other[6];
	GetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, other[0], other[1], other[2], other[3], other[4], other[5]);
	if(engine == 1)
		return SendClientMessage(playerid, -1, "Your engine must be off to fill up the truck.");

	switch(Player[playerid][TruckDelivery])
	{
		case 1:
		{
			if(!IsPlayerInRangeOfPoint(playerid, 7.0, TruckerPickup[0], TruckerPickup[1], TruckerPickup[2]))
				return SendClientMessage(playerid, -1, "You are not close enough to the point pick up your supplies to deliver.");

			new trailerid = GetVehicleTrailer(GetPlayerVehicleID(playerid));
			if(GetVehicleModel(trailerid) != 435)
				return SendClientMessage(playerid, -1, "You do not have the supply trailer attached to the vehicle.");
		}
		case 2:
		{
			if(!IsPlayerInRangeOfPoint(playerid, 7.0, TruckerPickup[3], TruckerPickup[4], TruckerPickup[5]))
				return SendClientMessage(playerid, -1, "You are not close enough to the point pick up your gas to deliver.");

			new trailerid = GetVehicleTrailer(GetPlayerVehicleID(playerid));
			if(GetVehicleModel(trailerid) != 584)
				return SendClientMessage(playerid, -1, "You do not have the gas trailer attached to the vehicle.");
		}
		default: return SendClientMessage(playerid, -1, "You have not started a delivery.");
	}
	Player[playerid][TruckLoadTimer] = defer LoadTruck(playerid);
	Player[playerid][TruckSQLID] = sql;
	Player[playerid][SuppliesLoaded] = 1;
	SendClientMessage(playerid, -1, "Please wait 20 seconds while your truck is being loaded.");
	return 1;
}

CMD:deliver(playerid)
{
	if(!PlayerHasJob(playerid, JOB_TRUCKER))
		return SendClientMessage(playerid, -1, "You do not have the trucker job.");

	if(Player[playerid][TruckDelivery] == 0)
		return SendClientMessage(playerid, -1, "You are not on a trucker delivery.");

	if(Player[playerid][TruckSupplies] == 0)
		return SendClientMessage(playerid, -1, "You have no supplies to deliver.");

	if(Player[playerid][SuppliesDelivered] != 0)
		return SendClientMessage(playerid, -1, "You have already delivered the supplies.");

	if(!IsPlayerInAnyVehicle(playerid))
		return SendClientMessage(playerid, -1, "You must be in your truck to deliver.");

	new sql = GetVSQLID(GetPlayerVehicleID(playerid)), idx = GetVIndex(sql);
	if(sql == 0)
		return SendClientMessage(playerid, -1, "Vehicle is not saved.");

	if(Jobs[Veh[idx][Job]][JobType] != JOB_TRUCKER || !IsATruck(Veh[idx][Link]))
		return SendClientMessage(playerid, -1, "You must be in a truck assigned to teh trucker job.");

	if(sql != Player[playerid][TruckSQLID])
		return SendClientMessage(playerid, -1, "You must be in the truck you loaded.");

	new engine, other[6];
	GetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, other[0], other[1], other[2], other[3], other[4], other[5]);
	if(engine == 1)
		return SendClientMessage(playerid, -1, "Your engine must be off to unload up the truck.");

	new job, Float:vhealth;
	GetVehicleHealth(GetPlayerVehicleID(playerid), vhealth);
	switch(Player[playerid][TruckDelivery])
	{
		case 1:
		{
			for(new i = 1; i < MAX_JOBS; i++)
			{
				if(Jobs[i][JobType] != JOB_DELIVERER)
					continue;

				job = i;
				break;
			}

			if(!IsPlayerInRangeOfPoint(playerid, 10.0, Jobs[job][JobMiscLocationTwoX], Jobs[job][JobMiscLocationTwoY], Jobs[job][JobMiscLocationTwoZ]))
				return SendClientMessage(playerid, -1, "You are not in range of the point to deliver your supplies.");

			if(vhealth < 980)
				return SendClientMessage(playerid, -1, "It appears your supplies have been damaged during your drive here, return the truck and start again.");

			if(DelivererSupplies + Player[playerid][TruckSupplies] > 10000)
				return SendClientMessage(playerid, -1, "RS Haul is no longer accepting orders.");

			Player[playerid][TruckUnloadTimer] = defer UnloadTruck(playerid);
			Player[playerid][SuppliesDelivered] = 1;
			SendClientMessage(playerid, -1, "Please wait 20 seconds while your truck is unloaded.");
		}
		case 2:
		{
			if(vhealth < 980)
				return SendClientMessage(playerid, -1, "It appears your supplies have been damaged during your drive here, return the truck and start again.");
			
			new biz = Player[playerid][TruckBiz];

			if(!IsPlayerInRangeOfPoint(playerid, 10.0, Businesses[biz][FuelPointX], Businesses[biz][FuelPointY], Businesses[biz][FuelPointZ]))
				return SendClientMessage(playerid, -1, "You need to deliver at the gas station you were assigned.");

			if(GetStoredAmountOf(Businesses[biz][bStorage], "Money") < 5000)
			{
				SendClientMessage(playerid, -1, "This gas station can no longer accept your order.");
				new RandomGas[15], count = 0;
				for(new b = 1; b < MAX_BUSINESSES; b++)
				{
					if(Businesses[b][bType] != 16)
						continue;

					if(GetStoredAmountOf(Businesses[b][bStorage], "Money") < 4000)
						continue;
					
					RandomGas[count] = b;
					count++;
				}
				if(count > 0)
				{
					new id = RandomGas[random(count)];
					SetPlayerCheckpoint(playerid, Businesses[id][FuelPointX], Businesses[id][FuelPointY], Businesses[id][FuelPointZ], 10.0);
					SendClientMessage(playerid, -1, "You have been assigned another gas station, head to that one instead!");
					Player[playerid][TruckBiz] = id;
				}
				else
				{
					job = (Jobs[Player[playerid][Job]][JobType] == JOB_TRUCKER) ? (Player[playerid][Job]) : (Player[playerid][Job2]);
					SetPlayerCheckpoint(playerid, Jobs[job][JobMiscLocationTwoX], Jobs[job][JobMiscLocationTwoY], Jobs[job][JobMiscLocationTwoZ], 10.0);
					Player[playerid][TruckStage] = 4;
					Player[playerid][TruckLoadTimer] = Timer:-1;
					return SendClientMessage(playerid, -1, "No gas stations are requesting any deliveries, head back to the depot to return the truck.");
				}
				return 1;
			}

			Player[playerid][TruckUnloadTimer] = defer UnloadTruck(playerid);
			Player[playerid][SuppliesDelivered] = 1;
			SendClientMessage(playerid, -1, "Please wait 20 seconds while your truck is unloaded.");
			
			new Float:x, Float:y, Float:z;
			GetPlayerPos(playerid, x, y, z);
			if(GetDistanceBetweenPoints(TruckerPickup[3], TruckerPickup[4], TruckerPickup[5], x, y, z) < 2100)
				SetPVarInt(playerid, "GasStationDistance", 1);
			else if(GetDistanceBetweenPoints(TruckerPickup[3], TruckerPickup[4], TruckerPickup[5], x, y, z) < 3600)
				SetPVarInt(playerid, "GasStationDistance", 2);
			else
				SetPVarInt(playerid, "GasStationDistance", 3);
		}
		default: return SendClientMessage(playerid, -1, "It appears you are not currently doing a delivery.");
	}
	return 1;
}

CMD:refillgasstation(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 6)
		return 1;

	new id, amount;
	if(sscanf(params, "dd", id, amount))
		return SendClientMessage(playerid, GREY, "SYNTAX: /refillgasstation [businessid] [amount]");

	if(id < 1 || id > MAX_BUSINESSES)
		return SendClientMessage(playerid, -1, "Invalid businesses id.");

	if(amount < 0 || amount > 25000)
		return SendClientMessage(playerid, -1, "Invalid amount.");

	if(Businesses[id][bType] != 16)
		return SendClientMessage(playerid, -1, "The business must be a gas station.");

	Businesses[id][GasVolume] = amount;
	new string[128];
	format(string, sizeof(string), "You have refilled business %d's gas station.", id);
	SendClientMessage(playerid, -1, string);
	return 1;
}

CMD:refilldeliverersupplies(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 6)
		return 1;

	new amount;
	if(sscanf(params, "d", amount))
		return SendClientMessage(playerid, -1, "/refilldeliverersupplies [amount]");

	if(amount < 0 || amount > 10000)
		return SendClientMessage(playerid, -1, "Invalid amount.");

	DelivererSupplies = amount;
	dini_IntSet("Assets.ini", "DelivererSupplies", amount);
	SendClientMessage(playerid, -1, "You have refilled the deliverer supplies to 10,000.");
	return 1;
}

CMD:checkdeliverersupplies(playerid)
{
	if(Player[playerid][AdminLevel] < 6)
		return 1;

	new string[128];
	format(string, sizeof(string), "There is %s deliverer supplies out of 10,000.", IntToFormattedStr(DelivererSupplies));
	SendClientMessage(playerid, -1, string);
	return 1;
}

CMD:checkorders(playerid)
{
	if(!PlayerHasJob(playerid, JOB_TRUCKER) && !Player[playerid][AdminDuty])
		return SendClientMessage(playerid, -1, "You do not have the trucker job.");

	new string[128];
	if(DelivererSupplies <= 9700)
	{
		format(string, sizeof(string), "%sRS Haul - %d/10000 supplies.", string, DelivererSupplies);
	}

	if(strlen(string) == 0)
		return SendClientMessage(playerid, -1, "There are currently no orders.");

	ShowPlayerDialog(playerid, 15934, DIALOG_STYLE_LIST, "Order list for deliveries", string, "Close", "");
	return 1;
}

CMD:refillpoint(playerid)
{
	if(Player[playerid][Business] == 0)
		return SendClientMessage(playerid, -1, "You need a gas station business to use this.");

	if(Businesses[Player[playerid][Business]][bType] != 16)
		return SendClientMessage(playerid, -1, "You need a gas station business to use this.");

	new biz = Player[playerid][Business];
	GetPlayerPos(playerid, Businesses[biz][FuelPointX], Businesses[biz][FuelPointY], Businesses[biz][FuelPointZ]);
	SendClientMessage(playerid, -1, "You have re-located your fuel refill point.");
	return 1;
}

stock MessageFromBoss(playerid, message[])
{
	if(Player[playerid][PhoneN] == -1 || strval(GetPhoneInfo(Player[playerid][PhoneN], "status")) == 0)
		return 1;

	new string[128];
	format(string, sizeof(string), "SMS from %s: %s", GetContactName(Player[playerid][PhoneN], strval(TRUCKER_NUMBER)), message);
	SendClientMessage(playerid, PHONE, string);
	PlayerPlaySound(playerid, 21000, 0.00, 0.00, 0.00);
	return 1;
}

CMD:truckdebug(playerid, params[])
{               
	if(Player[playerid][AdminLevel] < 2)
		return 1;
 
	if(!strcmp(params, "workers", true))
	{
		new string[255];
		for(new i; i < MAX_WORKERS; i++)
		{
			format(string, sizeof(string), "%sWorker %d: %s (%d) ", string, i + 1, GetName(Workers[i]), Workers[i]);
		}
		SendClientMessage(playerid, -1, string);
	}
	else
		SendClientMessage(playerid, -1, "/truckdebug workers");
	return 1;
}

CMD:emptygasstations(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 8)
		return 1;
		
	if(EmptyGasStations)
	{
		SendClientMessage(playerid, -1, "All gas stations have been enabled again, players can refuel.");
		EmptyGasStations = 0;
	}
	else
	{
		SendClientMessage(playerid, -1, "All gas stations will no longer have fuel, players cannot refuel.");
		EmptyGasStations = 1;
	}
	return 1;
}


timer LoadTruck[20000](playerid)
{
	if(Jobs[Player[playerid][Job]][JobType] != JOB_TRUCKER && Jobs[Player[playerid][Job2]][JobType] != JOB_TRUCKER)
		return SendClientMessage(playerid, -1, "It appears you are no longer a trucker so will not collect fuel/supplies.");

	switch(Player[playerid][TruckDelivery])
	{
		case 1:
		{
			Player[playerid][TruckSupplies] = 600;
			SendClientMessage(playerid, -1, "Your trailer has been filled. Take these supplies to the RS Haul warehouse. (( Use /deliver ))");

			new job;
			for(new j = 1; j < MAX_JOBS; j++)
			{
				if(Jobs[j][JobType] != JOB_DELIVERER)
					continue;

				job = j;
				break;
			}
			SetPlayerCheckpoint(playerid, Jobs[job][JobMiscLocationTwoX], Jobs[job][JobMiscLocationTwoY], Jobs[job][JobMiscLocationTwoZ], 3.0);
			Player[playerid][Checkpoint] = 1;
		}
		case 2:
		{
			Player[playerid][TruckSupplies] = 500;

			new RandomGas[15], count = 0;
			for(new b = 1; b < MAX_BUSINESSES; b++)
			{
				if(Businesses[b][bType] != 16)
					continue;

				if(IsItemInStorage(b, CONTAINER_TYPE_BIZ, ITEM_TYPE_CASH, 4000))
					continue;
				
				RandomGas[count] = b;
				count++;
			}
			if(count > 0)
			{
				new id = RandomGas[random(count)];
				SetPlayerCheckpoint(playerid, Businesses[id][FuelPointX], Businesses[id][FuelPointY], Businesses[id][FuelPointZ], 10.0);
				SendClientMessage(playerid, -1, "Your trailer has been filled. Now deliver it to your assigned gas station. (( Use /deliver ))");
				Player[playerid][TruckBiz] = id;
			}
			else
			{
				new job = (Jobs[Player[playerid][Job]][JobType] == JOB_TRUCKER) ? (Player[playerid][Job]) : (Player[playerid][Job2]);
				SetPlayerCheckpoint(playerid, Jobs[job][JobMiscLocationTwoX], Jobs[job][JobMiscLocationTwoY], Jobs[job][JobMiscLocationTwoZ], 10.0);
				Player[playerid][TruckStage] = 4;
				Player[playerid][TruckLoadTimer] = Timer:-1;
				return SendClientMessage(playerid, -1, "No gas stations are requesting any deliveries, head back to the depot to return the truck.");
			}
		}
		default: return SendClientMessage(playerid, -1, "You have not started a delivery.");
	}
	
	Player[playerid][TruckLoadTimer] = Timer:-1;
	Player[playerid][TruckStage] = 2;
	return 1;
}

timer UnloadTruck[20000](playerid)
{
	if(Jobs[Player[playerid][Job]][JobType] != JOB_TRUCKER && Jobs[Player[playerid][Job2]][JobType] != JOB_TRUCKER)
		return SendClientMessage(playerid, -1, "It appears you are no longer a trucker so you will not collect fuel/supplies.");

	SendClientMessage(playerid, -1, "Return back to the trucking depot to collect your pay. (type \"/finishdelivery\" in the checkpoint)");
	new job = (Jobs[Player[playerid][Job]][JobType] == JOB_TRUCKER) ? (Player[playerid][Job]) : (Player[playerid][Job2]);
	SetPlayerCheckpoint(playerid, Jobs[job][JobMiscLocationTwoX], Jobs[job][JobMiscLocationTwoY], Jobs[job][JobMiscLocationTwoZ], 10.0);
	Player[playerid][Checkpoint] = 1;
	Player[playerid][TruckUnloadTimer] = Timer:-1;
	Player[playerid][TruckStage] = 3;
	return 1;
}