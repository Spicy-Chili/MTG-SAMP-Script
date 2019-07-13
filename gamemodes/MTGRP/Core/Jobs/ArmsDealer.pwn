/*
#		MTG Arms Dealer
#		
#
#	By accessing this file, you agree to the following:
#		- You will never give the script or associated files to anybody who is not on the MTG SAMP development team
# 		- You will delete all development materials (script, databases, associated files, etc.) when you leave the MTG SAMP development team.
#
*/

#include <YSI\y_hooks>
#include <YSI\y_timers>

#define WEAPON_CREATE_COOLDOWN 	60
#define MATRUN_OBJECT			2040

#define TIER_LOW 		1
#define TIER_MID 		2
#define TIER_HIGH 		3

new Float:Matruns[15][3], MatObject[MAX_PLAYERS], MatrunTimer, MatrunRandPos = -1, PlacingMatDrop[2][MAX_PLAYERS];

enum GunData_
{
	G_NAME[32],
	G_WEAPONID,
	G_TIER,
	G_LEVEL,
	G_COST,
	G_VIP,
	G_USETOOLKIT,
}

new Guns[][GunData_] = 
{
	{"Katana", 8, TIER_LOW, 0, 5, 0, 1},
	{"Cane", 15, TIER_LOW, 0, 5, 0, 1},
	{"Pool Cue", 7, TIER_LOW, 0, 5, 0, 1},
	{"Baseball Bat", 5, TIER_LOW, 0, 5, 0, 1},
	{"Shovel", 6, TIER_LOW, 0, 5, 0, 1},
	{"Brass Knuckles", 1, TIER_LOW, 0, 5, 1, 1},
	{"9mm", 22, TIER_LOW, 1, 30, 0, 1},
	{"Silenced 9mm", 23, TIER_LOW, 2, 40, 0, 1},
	{"Pump Shotgun", 25, TIER_MID, 3, 50, 0, 0},
	{"Country Rifle", 33, TIER_MID, 4, 70, 1, 0},
	{"Desert Eagle", 24, TIER_MID, 4, 70, 0, 1},
	{"TEC9", 32, TIER_MID, 5, 80, 1, 1},
	{"MP5", 29, TIER_HIGH, 5, 80, 0, 0},
	{"UZI", 28, TIER_MID, 6, 90, 0, 0},
	{"AK47", 30, TIER_HIGH, 7, 120, 0, 0},
	{"Sawn-Off Shotgun", 26, TIER_HIGH, 7, 100, 1, 0},
	{"M4", 31, TIER_HIGH, 8, 180, 0, 0},
	{"Sniper", 34, TIER_HIGH, 9, 210, 0, 0},
	{"Combat Shotgun", 27, TIER_HIGH, 10, 250, 0, 0},
	{"Armour", -1, 0, 10, -1, 0, 0}
};

// -------- Commands --------

CMD:creategun(playerid)
{
	if(!PlayerHasJob(playerid, JOB_ARMSDEALER))
		return SendClientMessage(playerid, GREY, "You can't do that, you don't have the Arms Dealer job.");
		
	if(CantUseRightNow(playerid) || Player[playerid][IsAtEvent])
		return SendClientMessage(playerid, WHITE, "You can't do that right now.");
	
	if(Player[playerid][PrisonDuration] > 0 || Player[playerid][PrisonID] > 0)
		return SendClientMessage(playerid, -1, "You can't do that while in prison!");
	
	if(Player[playerid][CanMakeGun] == 0)
		return SendClientMessage(playerid, WHITE, "Wait until the job cooldown is done.");
		
	if(GetPlayerSpeed(playerid, 0) != 0)
		return SendClientMessage(playerid, WHITE, "You must be standing still to do that.");
		
	if(IsPlayerInAnyVehicle(playerid))
		return SendClientMessage(playerid, WHITE, "You can't do that in a vehicle.");
		
	new string[800];
	
	for(new i; i < sizeof(Guns); i++)
	{
		if(GetPlayerLevel(playerid) < Guns[i][G_LEVEL])
			continue;
	
		if(Player[playerid][VipRank] < 1 && Guns[i][G_VIP])
			continue;
	
		/*if(!strcmp("Armour", Guns[i][G_NAME], true))
		{
			format(string, sizeof(string), "%s{FFFFFF}%s (/createarmour)\n", string, Guns[i][G_NAME]);
			continue;
		}*/
	
		switch(Guns[i][G_TIER])
		{
			case 1: format(string, sizeof(string), "%s%s%s (%s street mats)\n", string, (Player[playerid][Materials][0] >= Guns[i][G_COST]) ? ("{0EAD1B}") : ("{B32222}"), Guns[i][G_NAME], IntToFormattedStr(Guns[i][G_COST]));
			case 2: format(string, sizeof(string), "%s%s%s (%s standard mats)\n", string, (Player[playerid][Materials][1] >= Guns[i][G_COST]) ? ("{0EAD1B}") : ("{B32222}"), Guns[i][G_NAME], IntToFormattedStr(Guns[i][G_COST]));
			case 3: format(string, sizeof(string), "%s%s%s (%s military mats)\n", string, (Player[playerid][Materials][2] >= Guns[i][G_COST]) ? ("{0EAD1B}") : ("{B32222}"), Guns[i][G_NAME], IntToFormattedStr(Guns[i][G_COST]));
		}
	}
	
	ShowPlayerDialog(playerid, 4355, DIALOG_STYLE_LIST, "Create a gun", string, "Create", "Close");
	return 1;
}

CMD:createarmour(playerid, params[])
{
	if(!PlayerHasJob(playerid, JOB_ARMSDEALER))
		return SendClientMessage(playerid, GREY, "You can't do that, you don't have the Arms Dealer job.");
		
	if(CantUseRightNow(playerid) || Player[playerid][IsAtEvent])
		return SendClientMessage(playerid, WHITE, "You can't do that right now.");
		
	if(Player[playerid][CanMakeGun] == 0)
		return SendClientMessage(playerid, WHITE, "Wait until the job cooldown is done.");
		
	if(GetPlayerSpeed(playerid, 0) != 0)
		return SendClientMessage(playerid, WHITE, "You must be standing still to do that.");
		
	if(IsPlayerInAnyVehicle(playerid))
		return SendClientMessage(playerid, WHITE, "You can't do that in a vehicle.");
		
	new idx = -1;
	for(new i; i < sizeof(Guns); i++)
	{
		if(!strcmp("Armour", Guns[i][G_NAME], true))
		{
			idx = i;
			break;
		}
	}
	
	if(idx == -1)
		return SendClientMessage(playerid, GREY, "You can't create armour!");
		
	if(GetPlayerLevel(playerid) < Guns[idx][G_LEVEL])
		return SendClientMessage(playerid, WHITE, "You can't do that, you're not the right level.");

	if(Player[playerid][VipRank] < 1 && Guns[idx][G_VIP])
		return SendClientMessage(playerid, WHITE, "You can't do that, you're not VIP.");
	
	new type[32];
	if(sscanf(params, "s[32]", type))
		return SendClientMessage(playerid, GREY, "SYNTAX: /createarmour [type (poor/standard/military)]");
	
	if(Player[playerid][HasArmour] > 0)
		return SendClientMessage(playerid, -1, "You already have a kevlar vest in your inventory.");
		
	new string[128];
	if(!strcmp(type, "poor", true))
	{
		if(Player[playerid][Materials][0] < 50)
			return SendClientMessage(playerid, GREY, "You can't create this, you need 50 street grade materials.");
			
		if((Houses[Player[playerid][InHouse]][Workbench] == 0 && Player[playerid][Toolkit] < 1) && (Businesses[Player[playerid][InBusiness]][bWorkbench] == 0 && Player[playerid][Toolkit] < 1))
			return SendClientMessage(playerid, GREY, "You need to be in a house/business with a workbench or have a toolkit to do create that!");
			
		Player[playerid][Materials][0] -= 50;
		Player[playerid][ArmsDealerXP] += 50;
		Player[playerid][HasArmour] = 100;
		format(string, sizeof(string), "* %s has created a kevlar vest.", GetNameEx(playerid));
		SendClientMessage(playerid, -1, "Your armour has been added to your inventory. You can /give to another player.");
		return NearByMessage(playerid, NICESKY, string);
	}
	else if(!strcmp(type, "standard", true))
	{
		if(Player[playerid][Materials][1] < 50)
			return SendClientMessage(playerid, GREY, "You can't create this, you need 50 standard grade materials.");
			
		if((Houses[Player[playerid][InHouse]][Workbench] == 0 && Player[playerid][Toolkit] < 1) && (Businesses[Player[playerid][InBusiness]][bWorkbench] == 0 && Player[playerid][Toolkit] < 1))
			return SendClientMessage(playerid, GREY, "You need to be in a house/business with a workbench or have a toolkit to do create that!");
			
		Player[playerid][Materials][1] -= 50;
		Player[playerid][ArmsDealerXP] += 100;
		Player[playerid][HasArmour] = 115;
		format(string, sizeof(string), "* %s has created a kevlar vest.", GetNameEx(playerid));
		SendClientMessage(playerid, -1, "Your armour has been added to your inventory. You can /give to another player.");
		return NearByMessage(playerid, NICESKY, string);
	}
	else if(!strcmp(type, "military", true))
	{
		if(Player[playerid][Materials][2] < 50)
			return SendClientMessage(playerid, GREY, "You can't create this, you need 50 military grade materials.");
			
		if(Houses[Player[playerid][InHouse]][Workbench] == 0 && Businesses[Player[playerid][InBusiness]][bWorkbench] == 0)
			return SendClientMessage(playerid, GREY, "You need to be in a house/business with a workbench!");
			
		if(!DoesGangExist(Player[playerid][Gang]))
			return SendClientMessage(playerid, WHITE, "Sorry, only members of official gangs can make \"great\" armour!");
			
		Player[playerid][Materials][2] -= 50;
		Player[playerid][ArmsDealerXP] += 150;
		Player[playerid][HasArmour] = 130;
		format(string, sizeof(string), "* %s has created a kevlar vest.", GetNameEx(playerid));
		SendClientMessage(playerid, -1, "Your armour has been added to your inventory. You can /give to another player.");
		return NearByMessage(playerid, NICESKY, string);
	}
	else
		SendClientMessage(playerid, GREY, "SYNTAX: /createarmour [type (poor/standard/military)]");
		
	return 1;
}	

CMD:usearmour(playerid, params[])
{
	if(Player[playerid][HasArmour] < 1)
		return SendClientMessage(playerid, -1, "You don't have a kevlar vest.");
	
	if(Player[playerid][Tied] >= 1 || Player[playerid][IsAtEvent] >= 1 || Player[playerid][Tazed] >= 1 || Player[playerid][Cuffed] >= 1 || Player[playerid][AdminFrozen] >= 1)
		return SendClientMessage(playerid, WHITE, "You cannot do this at this time as you are in an event, cuffed, tazed or tied.");
	
	new string[128];
	if(Player[playerid][CannotArmour] > gettime())
	{
		format(string, sizeof(string), "You have recently taken damage and cannot do this for another %d seconds.", (Player[playerid][CannotArmour] - gettime()));
		return SendClientMessage(playerid, -1, string);
	}

	format(string, sizeof(string), "* %s puts on a kevlar vest.", GetNameEx(playerid));
	NearByMessage(playerid, NICESKY, string);
	SetPlayerArmour(playerid, Player[playerid][HasArmour]);
	format(string, sizeof(string), "Your armour has been set to %d.", Player[playerid][HasArmour]);
	SendClientMessage(playerid, -1, string);
	Player[playerid][HasArmour] = 0;
	return 1;
}
/*
CMD:acceptarmour(playerid)
{
	if(ArmourOffer[2][playerid] < gettime())
		return SendClientMessage(playerid, WHITE, "You don't have an active offer for armour.");
		
	new id = ArmourOffer[1][playerid];
	
	if(GetDistanceBetweenPlayers(playerid, id) > 6)
		return SendClientMessage(playerid, GREY, "You can't do that, you're not close enough to that person.");
		
	new string[128];
	switch(ArmourOffer[0][playerid])
	{
		case 1:
		{
			if(Player[id][Materials][0] < 50)
			{
				SendClientMessage(playerid, WHITE, "They can't create that anymore.");
				return SendClientMessage(id, WHITE, "You don't have enough materials to create the armour!");
			}
			
			Player[id][Materials][0] -= 50;
			Player[id][ArmsDealerXP] += 50;
			SetPlayerArmour(playerid, 100.0);
			
			format(string, sizeof(string), "* %s has given %s armour.", GetNameEx(id), GetNameEx(playerid));
			NearByMessage(playerid, NICESKY, string);
		}
		case 2:
		{
			if(Player[id][Materials][1] < 50)
			{
				SendClientMessage(playerid, WHITE, "They can't create that anymore.");
				return SendClientMessage(id, WHITE, "You don't have enough materials to create the armour!");
			}
			
			Player[id][Materials][1] -= 50;
			Player[id][ArmsDealerXP] += 100;
			SetPlayerArmour(playerid, 115.0);
			
			format(string, sizeof(string), "* %s has given %s armour.", GetNameEx(id), GetNameEx(playerid));
			NearByMessage(playerid, NICESKY, string);
		}
		case 3:
		{
			if(Player[id][Materials][2] < 50)
			{
				SendClientMessage(playerid, WHITE, "They can't create that anymore.");
				return SendClientMessage(id, WHITE, "You don't have enough materials to create the armour!");
			}
			
			Player[id][Materials][2] -= 50;
			Player[id][ArmsDealerXP] += 150;
			SetPlayerArmour(playerid, 130.0);
			
			format(string, sizeof(string), "* %s has given %s armour.", GetNameEx(id), GetNameEx(playerid));
			NearByMessage(playerid, NICESKY, string);
		}
	}
	
	ArmourOffer[0][playerid] = 0;
	ArmourOffer[1][playerid] = -1;
	ArmourOffer[2][playerid] = 0;
		
	return 1;
}
*/
CMD:getmats(playerid, params[])
{
	if(!PlayerHasJob(playerid, JOB_ARMSDEALER))
		return SendClientMessage(playerid, GREY, "You can't do that, you don't have the Arms Dealer job.");
		
	if(CantUseRightNow(playerid) || Player[playerid][IsAtEvent])
		return SendClientMessage(playerid, WHITE, "You can't do that right now.");
		
	if(IsPlayerInAnyVehicle(playerid))
		return SendClientMessage(playerid, WHITE, "You can't do that in a vehicle.");
	
	if(MatrunRandPos == -1)
		return SendClientMessage(playerid, GREY, "There are no matrun positions set - alert the admins.");
	
	if(Player[playerid][InabilityToMatrun] >= 1)
		return SendClientMessage(playerid, WHITE, "Please wait the reload time, that is 1 minute.");
	
	new jobid = PlayerHasJob(playerid, JOB_ARMSDEALER);	
	if(!IsPlayerInRangeOfPoint(playerid, 5, Jobs[jobid][JobMiscLocationOneX], Jobs[jobid][JobMiscLocationOneY], Jobs[jobid][JobMiscLocationOneZ]) || Jobs[jobid][JobMiscLocationOneWorld] != GetPlayerVirtualWorld(playerid))
		return SendClientMessage(playerid, -1, "You can't do that, you're not near the point to collect materials.");

	if(Player[playerid][Checkpoint] != 0)
		return SendClientMessage(playerid, WHITE, "You already have an active checkpoint.");

	if(Player[playerid][TruckStage])
		return SendClientMessage(playerid, -1, "You can't do that when you are on a trucker run.");
		
	if(MatSafeMaterials < ((Player[playerid][VipRank] > 1) ? (20) : (10)))
		return SendClientMessage(playerid, -1, "There isn't enough materials in there for you to grab!");
		
	ShowPlayerDialog(playerid, 4356, DIALOG_STYLE_LIST, "Material runs; select material type.", "Street grade\nStandard grade\nMilitary grade\n", "Select", "Close");
	return 1;
}

CMD:partygetmats(playerid, params[])
{
	if(Player[playerid][InPlayerParty] == INVALID_PLAYER_ID)
		return SendClientMessage(playerid, WHITE, "You are not in a party!");
	
	if(!PlayerHasJob(playerid, JOB_ARMSDEALER))
		return SendClientMessage(playerid, GREY, "You can't do that, you don't have the Arms Dealer job.");
		
	if(CantUseRightNow(playerid) || Player[playerid][IsAtEvent])
		return SendClientMessage(playerid, WHITE, "You can't do that right now.");
		
	if(IsPlayerInAnyVehicle(playerid))
		return SendClientMessage(playerid, WHITE, "You can't do that in a vehicle.");
	
	if(MatrunRandPos == -1)
		return SendClientMessage(playerid, GREY, "There are no matrun positions set - alert the admins.");
	
	if(Player[playerid][InabilityToMatrun] >= 1)
		return SendClientMessage(playerid, WHITE, "Please wait the reload time, that is 1 minute.");
	
	new jobid = PlayerHasJob(playerid, JOB_ARMSDEALER);	
	if(!IsPlayerInRangeOfPoint(playerid, 5, Jobs[jobid][JobMiscLocationOneX], Jobs[jobid][JobMiscLocationOneY], Jobs[jobid][JobMiscLocationOneZ]) || Jobs[jobid][JobMiscLocationOneWorld] != GetPlayerVirtualWorld(playerid))
		return SendClientMessage(playerid, -1, "You can't do that, you're not near the point to collect materials.");

	if(Player[playerid][Checkpoint] != 0)
		return SendClientMessage(playerid, WHITE, "You already have an active checkpoint.");

	if(Player[playerid][TruckStage])
		return SendClientMessage(playerid, -1, "You can't do that when you are on a trucker run.");
		
	if(MatSafeMaterials < ((Player[playerid][VipRank] > 1) ? (20) : (10)))
		return SendClientMessage(playerid, -1, "There isn't enough materials in there for you to grab!");
	
	SetPVarInt(playerid, "PARTY_GET_MATS", 1);
	ShowPlayerDialog(playerid, 4356, DIALOG_STYLE_LIST, "Material runs; select material type.", "Street grade\nStandard grade\nMilitary grade\n", "Select", "Close");
	return 1;
}

stock GetMaterialsForParty(partyid, mattype, skipid)
{
	foreach(Player, i)
	{
		if(i == skipid)
			continue;
			
		if(Player[i][InPlayerParty] != partyid)
			continue; 
		
		if(!PlayerHasJob(i, JOB_ARMSDEALER))
		{
			SendClientMessage(i, GREY, "You were unable to receive mats with the party as you dont have the arms dealer job.");
			continue;
		}
		
		if(CantUseRightNow(i) || Player[i][IsAtEvent])
		{
			SendClientMessage(i, WHITE, "You are not able to receive mats with the party.");
			continue;
		}
		
		if(IsPlayerInAnyVehicle(i))
		{
			SendClientMessage(i, WHITE, "You were unable to receive mats with the party as you are in a vehicle.");
			continue;
		}
		
		if(MatrunRandPos == -1)
		{
			SendClientMessage(i, GREY, "There are no matrun positions set - alert the admins.");
			continue;
		}
		
		if(Player[i][InabilityToMatrun] >= 1)
		{	
			SendClientMessage(i, WHITE, "You must wait 1 minute before getting anymore party mats.");
			continue;
		}
		new jobid = PlayerHasJob(i, JOB_ARMSDEALER);	
		if(!IsPlayerInRangeOfPoint(i, 5, Jobs[jobid][JobMiscLocationOneX], Jobs[jobid][JobMiscLocationOneY], Jobs[jobid][JobMiscLocationOneZ]) || Jobs[jobid][JobMiscLocationOneWorld] != GetPlayerVirtualWorld(i))
		{
			SendClientMessage(i, -1, "You couldnt get party mats because you are not near the getmats point.");
			continue;
		}
		
		if(Player[i][Checkpoint] != 0)
		{
			SendClientMessage(i, WHITE, "You couldn't get party mats because you have a checkpoint.");
			continue;
		}

		if(Player[i][TruckStage])
		{
			SendClientMessage(i, -1, "You can't get party mats while on a trucker run.");
			continue;
		}
			
		if(MatSafeMaterials < ((Player[i][VipRank] > 1) ? (20) : (10)))
		{
			SendClientMessage(i, -1, "You cant get party mats because there isn't enough mats in there for you to grab!");
			continue;
		}
		
		switch(mattype)
		{
			case 0: 
			{
				if(Player[i][Money] < ((Player[i][VipRank] > 1) ? (200) : (100)))
				{
					SendClientMessage(i, WHITE, (Player[i][VipRank] > 1) ? ("You need $200 to collect materials.") : ("You need $100 to collect materials."));
					continue;
				}
				
				Player[i][Checkpoint] = 1;
				Player[i][Money] -= (Player[i][VipRank] > 1) ? (200) : (100);
				MatSafeMaterials -= (Player[i][VipRank] > 1) ? (20) : (10);
				Player[i][CompleteRun] = 1;
				Player[i][MatRunning] = 1;
				new string[128];
				format(string, sizeof(string), "[MATRUN] %s has paid $%d for a street material package (%d mats)", GetName(i), (Player[i][VipRank] > 1) ? (200) : (100), (Player[i][VipRank] > 1) ? (20) : (10));
				StatLog(string);
			}
			case 1: 
			{
				if(Player[i][Money] < ((Player[i][VipRank] > 1) ? (400) : (200)))
				{
					SendClientMessage(i, WHITE, (Player[i][VipRank] > 1) ? ("You need $400 to collect materials.") : ("You need $200 to collect materials."));
					continue;
				}
					
				Player[i][Checkpoint] = 1;
				Player[i][Money] -= (Player[i][VipRank] > 1) ? (400) : (200);
				MatSafeMaterials -= (Player[i][VipRank] > 1) ? (20) : (10);
				Player[i][CompleteRun] = 1;
				Player[i][MatRunning] = 2;
				new string[128];
				format(string, sizeof(string), "[MATRUN] %s has paid $%d for a standard material package (%d mats)", GetName(i), (Player[i][VipRank] > 1) ? (400) : (200), (Player[i][VipRank] > 1) ? (20) : (10));
				StatLog(string);
			}
			case 2: 
			{
				if(Player[i][Money] < ((Player[i][VipRank] > 1) ? (600) : (300)))
				{
					SendClientMessage(i, WHITE, (Player[i][VipRank] > 1) ? ("You need $600 to collect materials.") : ("You need $300 to collect materials."));
					continue;
				}
				
				Player[i][Checkpoint] = 1;
				Player[i][Money] -= (Player[i][VipRank] > 1) ? (600) : (300);
				MatSafeMaterials -= (Player[i][VipRank] > 1) ? (20) : (10);
				Player[i][CompleteRun] = 1;
				Player[i][MatRunning] = 3;
				new string[128];
				format(string, sizeof(string), "[MATRUN] %s has paid $%d for a military material package (%d mats)", GetName(i), (Player[i][VipRank] > 1) ? (600) : (300), (Player[i][VipRank] > 1) ? (20) : (10));
				StatLog(string);
			}
		}
		
		if(MatSafeMaterials <= 200 && MatSafeClosed == 1)
		{
			MatSafeClosed = 0;
		}
		
		dini_IntSet("Assets.ini", "MatSafeClosed", MatSafeClosed);
		dini_IntSet("Assets.ini", "MatSafeMaterials", MatSafeMaterials);
		
		if(Player[i][VipRank] > 1)
		{
			SendClientMessage(i, WHITE, "[P] Your party grabbed 20 material packages for you! Deliver them to the red marker!");
			SendClientMessage(i, YELLOW, "+10 material packages due to Silver+ VIP.");
		}
		else
		{
			SendClientMessage(i, WHITE, "[P] Your party grabbed 10 material packages for you! Deliver them to the red marker!");
			SendClientMessage(i, GREY, "Silver+ VIP will allow you to collect more materials per run!");
		}
		
		new matrunpos = Player[Player[i][InPlayerParty]][PartyMatsLoc];
		new randx = floatround(Matruns[matrunpos][0]) + RandomEx(-100, 100);
		new randy = floatround(Matruns[matrunpos][1]) + RandomEx(-100, 100);
		SetPlayerRaceCheckpoint(i, 0, randx, randy, Matruns[matrunpos][2] + 5, Matruns[matrunpos][0], Matruns[matrunpos][1], Matruns[matrunpos][2], 10.0);
		
		new string[128];
		Get2DPosZone(Matruns[matrunpos][0], Matruns[matrunpos][1], string, MAX_ZONE_NAME);
		
		switch(random(3))
		{
			case 0: format(string, sizeof(string), "Man says: Hey %s, head to %s and find the package. Bring it back here when you find it, I can unlock it.", (Player[i][Gender] == 1) ? ("dude") : ("girl"), string);
			case 1: format(string, sizeof(string), "Man says: Hey %s, go to %s and get a package. It's around there somewhere. I'll open it for you.", (Player[i][Gender] == 1) ? ("dude") : ("girl"), string);
			case 2: format(string, sizeof(string), "Man says: Go look around %s, there should be a package nearby. Bring it back here when you find it.", string);
		}
		SendClientMessage(i, WHITE, string);
		
		if(IsValidPlayerObject(i, MatObject[i]))
			DestroyPlayerObject(i, MatObject[i]);
		MatObject[i] = CreatePlayerObject(i, MATRUN_OBJECT, Matruns[matrunpos][0], Matruns[matrunpos][1], Matruns[matrunpos][2], 0.00, 0.00, random(360));
		SetPVarInt(i, "MATRUNPOS", matrunpos);
	}
	return 1;
}

CMD:takebox(playerid)
{
	if(!PlayerHasJob(playerid, JOB_ARMSDEALER))
		return SendClientMessage(playerid, GREY, "You can't do that, you don't have the Arms Dealer job.");
		
	if(CantUseRightNow(playerid) || Player[playerid][IsAtEvent])
		return SendClientMessage(playerid, WHITE, "You can't do that right now.");
		
	if(IsPlayerInAnyVehicle(playerid))
		return SendClientMessage(playerid, WHITE, "You can't do that in a vehicle.");
	
	if(Player[playerid][MatRunning] == 0)
		return SendClientMessage(playerid, WHITE, "You can't do that, you're not matrunning.");
		
	if(!IsValidPlayerObject(playerid, MatObject[playerid]))
		return SendClientMessage(playerid, WHITE, "You can't do that as you've already picked up the box!");
	
	if(Player[playerid][CompleteRun] < 50 && Player[playerid][CompleteRun] != 0)
	{
		new string[128];
		if(gettime() > GetPVarInt(playerid, "MatrunSpamCooldown"))
		{
			format(string, sizeof(string), "WARNING: %s has reached the mat-run checkpoint in %d seconds (less than 50).", GetName(playerid), Player[playerid][CompleteRun]);
			SendToAdmins(ADMINORANGE, string, 1);
			WarningLog(string);
			Player[playerid][CompleteRun] = 1;
		}
	}
	
	new Float:x, Float:y, Float:z;
	GetPlayerObjectPos(playerid, MatObject[playerid], x, y, z);
	if(IsPlayerInRangeOfPoint(playerid, 2.0, x, y, z))
	{
		//Once a player at least 1 player in the party picks up the mats then no one can do /getmats to get the same location
		if(Player[playerid][InPlayerParty] != INVALID_PLAYER_ID && Player[Player[playerid][InPlayerParty]][PartyMatsLoc] != -1)
			Player[Player[playerid][InPlayerParty]][PartyMatsLoc] = -1;
		SetPVarInt(playerid, "MATRUNPOS", -1);
		DestroyPlayerObject(playerid, MatObject[playerid]);
		ApplyAnimation(playerid, "carry", "liftup", 4.0, 0, 0, 0, 0, 0, 1);
		SendClientMessage(playerid, WHITE, "Head back to the checkpoint and the man will open the box and give you your materials.");
		new job = PlayerHasJob(playerid, JOB_ARMSDEALER);
		DisablePlayerRaceCheckpoint(playerid);
		DisablePlayerCheckpoint(playerid);
		SetPlayerCheckpoint(playerid, Jobs[job][JobMiscLocationOneX], Jobs[job][JobMiscLocationOneY], Jobs[job][JobMiscLocationOneZ], 5.0);
		Player[playerid][Checkpoint] = 1;
	}
	return 1;
}

CMD:movematdrop(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;

	if(isnull(params) || !IsNumeric(params) || strval(params) < 1 || strval(params) > 15)
		return SendClientMessage(playerid, GREY, "SYNTAX: /movematdrop [1 - 15]");

	PlacingMatDrop[0][playerid] = CreateDynamicObject(MATRUN_OBJECT, GetPlayerX(playerid), GetPlayerY(playerid), GetPlayerZ(playerid), 0.00, 0.00, 0.00, .playerid = playerid);
	Streamer_Update(playerid);
	EditDynamicObject(playerid, PlacingMatDrop[0][playerid]);
	PlacingMatDrop[1][playerid] = strval(params);
	return 1;
}

CMD:gotomatdrop(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 2)
		return 1;

	if(isnull(params) || !IsNumeric(params) || strval(params) < 1 || strval(params) > 15)
		return SendClientMessage(playerid, GREY, "SYNTAX: /gotomatdrop [1 - 15]");

	new id = strval(params) - 1;
		
	SetPlayerPos(playerid, Matruns[id][0], Matruns[id][1], Matruns[id][2]);
	return 1;
}

CMD:resetmatdrop(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;

	if(isnull(params) || !IsNumeric(params) || strval(params) < 1 || strval(params) > 15)
		return SendClientMessage(playerid, GREY, "SYNTAX: /resetmatdrop [1 - 15]");

	new temp[32], id = strval(params) - 1;
	
	Matruns[id][0] = 0.00;
	Matruns[id][1] = 0.00;
	Matruns[id][2] = 0.00;
	
	format(temp, sizeof(temp), "MatDropX%d", id);
	dini_FloatSet("Assets.ini", temp, Matruns[id][0]);
	format(temp, sizeof(temp), "MatDropY%d", id);
	dini_FloatSet("Assets.ini", temp, Matruns[id][1]);
	format(temp, sizeof(temp), "MatDropZ%d", id);
	dini_FloatSet("Assets.ini", temp, Matruns[id][2]);
	return 1;
}

// -------- Stocks --------

stock GetPlayerLevel(playerid)
{
	switch(Player[playerid][ArmsDealerXP])
	{
		case 0 .. 249: return 0;
		case 250 .. 1749: return 1;
		case 1750 .. 3749: return 2;
		case 3750 .. 6249: return 3;
		case 6250 .. 11249: return 4;
		case 11250 .. 16249: return 5;
		case 16250 .. 23749: return 6;
		case 23750 .. 31249: return 7;
		case 31250 .. 43749: return 8;
		case 43750 .. 57499: return 9;
		default: return 10;
	}
	return 0;
}

stock Arms_GetRandomMatrun()
{
	new exists = 0;
	for(new i; i < sizeof(Matruns); i++)
	{
		if(Matruns[i][0] != 0)
			exists = 1;
	}

	if(exists == 0)
		return -1;
	
	new rand = random(sizeof(Matruns));
	if(Matruns[rand][0] == 0)
		return Arms_GetRandomMatrun();

	return rand;
}

// -------- Callbacks --------

hook OnPlayerEditDynamicObject(playerid, objectid, response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ)
{
	if(PlacingMatDrop[1][playerid] == 0)
		return 1;
		
	switch(response)
	{
		case EDIT_RESPONSE_CANCEL:
		{
			DestroyDynamicObject(PlacingMatDrop[0][playerid]);
			PlacingMatDrop[1][playerid] = 0;
			return SendClientMessage(playerid, -1, "You have cancelled moving the matdrop position.");
		}
		case EDIT_RESPONSE_FINAL:
		{
			new id = PlacingMatDrop[1][playerid] - 1, temp[32];
			Matruns[id][0] = fX;
			Matruns[id][1] = fY;
			Matruns[id][2] = fZ;
			format(temp, sizeof(temp), "MatDropX%d", id);
			dini_FloatSet("Assets.ini", temp, Matruns[id][0]);
			format(temp, sizeof(temp), "MatDropY%d", id);
			dini_FloatSet("Assets.ini", temp, Matruns[id][1]);
			format(temp, sizeof(temp), "MatDropZ%d", id);
			dini_FloatSet("Assets.ini", temp, Matruns[id][2]);
			
			new string[128];
			format(string, sizeof(string), "You have relocated matrun pos %d.", id + 1);
			SendClientMessage(playerid, YELLOW, string);
			format(string, sizeof(string), "[MATRUN] %s has relocated matrun pos %d.", Player[playerid][AdminName], id + 1);
			AdminActionsLog(string);
		
			DestroyDynamicObject(PlacingMatDrop[0][playerid]);
			PlacingMatDrop[1][playerid] = 0;
		}
	}
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case 4355:
		{
			if(!response)
				return 1;
				
			if(!PlayerHasJob(playerid, JOB_ARMSDEALER))
				return SendClientMessage(playerid, GREY, "You can't do that, you don't have the Arms Dealer job.");
			
			if(IsPlayerInAnyVehicle(playerid))
				return SendClientMessage(playerid, WHITE, "You can't do that in a vehicle.");
		
			for(new i; i < sizeof(Guns); i++)
			{
				if(strcmp(Guns[i][G_NAME], CutBeforePara(inputtext), true))
					continue;
					
				if(Player[playerid][VipRank] < 1 && Guns[i][G_VIP])
					SendClientMessage(playerid, GREY, "You need VIP to create that weapon.");
					
				if((Houses[Player[playerid][InHouse]][Workbench] == 0 && Guns[i][G_USETOOLKIT] == 0) && (Businesses[Player[playerid][InBusiness]][bWorkbench] == 0 && Guns[i][G_USETOOLKIT] == 0))
						return SendClientMessage(playerid, GREY, "You need a workbench to create that!");
				
				if(Guns[i][G_USETOOLKIT] == 1 && Player[playerid][Toolkit] < 1 && Houses[Player[playerid][InHouse]][Workbench] == 0 && Businesses[Player[playerid][InBusiness]][bWorkbench] == 0)
						return SendClientMessage(playerid, GREY, "You need a toolkit or workbench to create that!");
						
				if(GetPlayerLevel(playerid) < Guns[i][G_LEVEL])
					return SendClientMessage(playerid, GREY, "You don't have the right level to create that.");
					
				if(!DoesGangExist(Player[playerid][Gang]) && Guns[i][G_LEVEL] >= 8)
					return SendClientMessage(playerid, GREY, "Sorry, only members of official gangs can make that weapon.");
					
				new mats = -1;
				switch(Guns[i][G_TIER])
				{
					case 1: mats = Player[playerid][Materials][0];
					case 2: mats = Player[playerid][Materials][1];
					case 3: mats = Player[playerid][Materials][2];
				}
				
				if(mats == -1)
					return SendClientMessage(playerid, GREY, "An error occurred, report this problem to a developer. (INVALID G_TIER)");
				
				if(mats < Guns[i][G_COST])
					return SendClientMessage(playerid, GREY, "You don't have enough materials for this weapon.");
					
				new string[128];
				GivePlayerWeaponEx(playerid, Guns[i][G_WEAPONID]);
				
				switch(Guns[i][G_TIER])
				{
					case 1: Player[playerid][Materials][0]-= Guns[i][G_COST];
					case 2: Player[playerid][Materials][1]-= Guns[i][G_COST];
					case 3: Player[playerid][Materials][2]-= Guns[i][G_COST];
				}
				
				new old_lvl = GetPlayerLevel(playerid);
				
				Player[playerid][ArmsDealerXP] += Guns[i][G_COST] * Guns[i][G_TIER];
				format(string, sizeof(string), "You have created a %s. Type /giveweapon [playerid] to pass the weapon on.", Guns[i][G_NAME]);
				SendClientMessage(playerid, WHITE, string);
				format(string, sizeof(string), "* %s has created a %s from their materials.", GetNameEx(playerid), Guns[i][G_NAME]);
				NearByMessage(playerid, NICESKY, string);
				Player[playerid][GunTime] = gettime() + WEAPON_CREATE_COOLDOWN;
				Player[playerid][CanMakeGun] = 0;
				Player[playerid][TotalGunsMade] ++;
				
				
				if(GetPlayerLevel(playerid) > old_lvl)
				{
					format(string, sizeof(string), "You have leveled up in Arms Dealer! You are now level %d.", GetPlayerLevel(playerid));
					SendClientMessage(playerid, YELLOW, "======================================================================================");
					SendClientMessage(playerid, YELLOW, string);
					SendClientMessage(playerid, YELLOW, "======================================================================================");
					JobLog(playerid, "Arms dealer", GetPlayerLevel(playerid), old_lvl);
				}
				return 1;
			}
			return SendClientMessage(playerid, RED, "ERROR: Could not find selected weapon in system. Report this bug.");
		}
		case 4356:
		{
			if(!response)
				return 1;
		
			if(!PlayerHasJob(playerid, JOB_ARMSDEALER))
				return SendClientMessage(playerid, GREY, "You can't do that, you don't have the Arms Dealer job.");
				
			switch(listitem)
			{
				case 0: 
				{
					if(Player[playerid][Money] < ((Player[playerid][VipRank] > 1) ? (200) : (100)))
						return SendClientMessage(playerid, WHITE, (Player[playerid][VipRank] > 1) ? ("You need $200 to collect materials.") : ("You need $100 to collect materials."));
						
					Player[playerid][Checkpoint] = 1;
					Player[playerid][Money] -= (Player[playerid][VipRank] > 1) ? (200) : (100);
					MatSafeMaterials -= (Player[playerid][VipRank] > 1) ? (20) : (10);
					Player[playerid][CompleteRun] = 1;
					Player[playerid][MatRunning] = 1;
					new string[128];
					format(string, sizeof(string), "[MATRUN] %s has paid $%d for a street material package (%d mats)", GetName(playerid), (Player[playerid][VipRank] > 1) ? (200) : (100), (Player[playerid][VipRank] > 1) ? (20) : (10));
					StatLog(string);
				}
				case 1: 
				{
					if(Player[playerid][Money] < ((Player[playerid][VipRank] > 1) ? (400) : (200)))
						return SendClientMessage(playerid, WHITE, (Player[playerid][VipRank] > 1) ? ("You need $400 to collect materials.") : ("You need $200 to collect materials."));
						
					Player[playerid][Checkpoint] = 1;
					Player[playerid][Money] -= (Player[playerid][VipRank] > 1) ? (400) : (200);
					MatSafeMaterials -= (Player[playerid][VipRank] > 1) ? (20) : (10);
					Player[playerid][CompleteRun] = 1;
					Player[playerid][MatRunning] = 2;
					new string[128];
					format(string, sizeof(string), "[MATRUN] %s has paid $%d for a standard material package (%d mats)", GetName(playerid), (Player[playerid][VipRank] > 1) ? (400) : (200), (Player[playerid][VipRank] > 1) ? (20) : (10));
					StatLog(string);
				}
				case 2: 
				{
					if(Player[playerid][Money] < ((Player[playerid][VipRank] > 1) ? (600) : (300)))
						return SendClientMessage(playerid, WHITE, (Player[playerid][VipRank] > 1) ? ("You need $600 to collect materials.") : ("You need $300 to collect materials."));
						
					Player[playerid][Checkpoint] = 1;
					Player[playerid][Money] -= (Player[playerid][VipRank] > 1) ? (600) : (300);
					MatSafeMaterials -= (Player[playerid][VipRank] > 1) ? (20) : (10);
					Player[playerid][CompleteRun] = 1;
					Player[playerid][MatRunning] = 3;
					new string[128];
					format(string, sizeof(string), "[MATRUN] %s has paid $%d for a military material package (%d mats)", GetName(playerid), (Player[playerid][VipRank] > 1) ? (600) : (300), (Player[playerid][VipRank] > 1) ? (20) : (10));
					StatLog(string);
				}
			}
			
			if(MatSafeMaterials <= 200 && MatSafeClosed == 1)
			{
				MatSafeClosed = 0;
			}
			
			dini_IntSet("Assets.ini", "MatSafeClosed", MatSafeClosed);
			dini_IntSet("Assets.ini", "MatSafeMaterials", MatSafeMaterials);
			
			if(Player[playerid][VipRank] > 1)
			{
				SendClientMessage(playerid, WHITE, "You have collected 20 material packages. Deliver them to the red marker!");
				SendClientMessage(playerid, YELLOW, "+10 material packages due to Silver+ VIP.");
			}
			else
			{
				SendClientMessage(playerid, WHITE, "You have collected 10 material packages. Deliver them to the red marker!");
				SendClientMessage(playerid, GREY, "Silver+ VIP will allow you to collect more materials per run!");
			}
			
			new matrunpos = MatrunRandPos;
			//If you dont get mats when someone does /partygetmats then you can do /getmats to get the same location
			if(Player[playerid][InPlayerParty] != INVALID_PLAYER_ID && !GetPVarInt(playerid, "PARTY_GET_MATS"))
			{
				if(Player[Player[playerid][InPlayerParty]][PartyMatsLoc] != -1)
					matrunpos = Player[Player[playerid][InPlayerParty]][PartyMatsLoc];
				SendClientMessage(playerid, GREEN, "[P] You have been given the same location as the rest of your party!");
			}
			
			new randx = floatround(Matruns[matrunpos][0]) + RandomEx(-100, 100);
			new randy = floatround(Matruns[matrunpos][1]) + RandomEx(-100, 100);
			SetPlayerRaceCheckpoint(playerid, 0, randx, randy, Matruns[matrunpos][2] + 5, Matruns[matrunpos][0], Matruns[matrunpos][1], Matruns[matrunpos][2], 10.0);
			
			new string[128];			
			Get2DPosZone(Matruns[matrunpos][0], Matruns[matrunpos][1], string, MAX_ZONE_NAME);
			
			switch(random(3))
			{
				case 0: format(string, sizeof(string), "Man says: Hey man, head to %s and find the package. Bring it back here when you find it, I can unlock it.", string);
				case 1: format(string, sizeof(string), "Man says: Hey %s, go to %s and get a package. It's around there somewhere. I'll open it for you.", (Player[playerid][Gender] == 1) ? ("dude") : ("girl"), string);
				case 2: format(string, sizeof(string), "Man says: Go look around %s, there should be a package nearby. Bring it back here when you find it.", string);
			}
			SendClientMessage(playerid, WHITE, string);
			
			if(IsValidPlayerObject(playerid, MatObject[playerid]))
				DestroyPlayerObject(playerid, MatObject[playerid]);
			MatObject[playerid] = CreatePlayerObject(playerid, MATRUN_OBJECT, Matruns[matrunpos][0], Matruns[matrunpos][1], Matruns[matrunpos][2], 0.00, 0.00, random(360));
			SetPVarInt(playerid, "MATRUNPOS", matrunpos);
			if(GetPVarInt(playerid, "PARTY_GET_MATS") == 1)
			{
				Player[Player[playerid][InPlayerParty]][PartyMatsLoc] = MatrunRandPos;
				GetMaterialsForParty(Player[playerid][InPlayerParty], listitem, playerid);
				DeletePVar(playerid, "PARTY_GET_MATS");
			}
			
		}
	}
	return 1;
}

hook OnGameModeInit()
{
	new temp[32];
	for(new i; i < sizeof(Matruns); i++)
	{
		format(temp, sizeof(temp), "MatDropX%d", i);
		Matruns[i][0] = dini_Float("Assets.ini", temp);
		format(temp, sizeof(temp), "MatDropY%d", i);
		Matruns[i][1] = dini_Float("Assets.ini", temp);
		format(temp, sizeof(temp), "MatDropZ%d", i);
		Matruns[i][2] = dini_Float("Assets.ini", temp);
	}
	return 1;
}

hook OnPlayerDisconnect(playerid)
{
	if(IsValidPlayerObject(playerid, MatObject[playerid]))
		DestroyPlayerObject(playerid, MatObject[playerid]);
		
	PlacingMatDrop[1][playerid] = 0;
	if(IsValidDynamicObject(PlacingMatDrop[0][playerid]))
		DestroyDynamicObject(PlacingMatDrop[0][playerid]);
	return 1;
}

hook OnPlayerEnterCheckpoint(playerid)
{
	if(Player[playerid][MatRunning] == 0)
		 return 1;
		
	new job = PlayerHasJob(playerid, JOB_ARMSDEALER);
	if(!IsPlayerInRangeOfPoint(playerid, 5.0, Jobs[job][JobMiscLocationOneX], Jobs[job][JobMiscLocationOneY], Jobs[job][JobMiscLocationOneZ]))
		return 1;
	
	if(Player[playerid][CompleteRun] < 50 && Player[playerid][CompleteRun] != 0)
	{
		new string[128];
		if(gettime() > GetPVarInt(playerid, "MatrunSpamCooldown"))
		{
			format(string, sizeof(string), "WARNING: %s has reached the mat-run checkpoint in %d seconds (less than 50).", GetName(playerid), Player[playerid][CompleteRun]);
			SendToAdmins(ADMINORANGE, string, 1);
			WarningLog(string);
			Player[playerid][CompleteRun] = 0;
		}
	}
	
	new string[128];
	switch(Player[playerid][MatRunning])
	{
		case 1:
		{
			Player[playerid][Materials][0] += (Player[playerid][VipRank] > 1) ? (20) : (10);
			format(string, sizeof(string), "The man unlocks the box and gives you %d street grade materials.", (Player[playerid][VipRank] > 1) ? (20) : (10));
			new str[128];
			format(str, sizeof(str), "[MATRUN] %s has received %d street grade materials (previously had %d street mats)", GetName(playerid), (Player[playerid][VipRank] > 1) ? (20) : (10), Player[playerid][Materials][0]);
			StatLog(str);
		}
		case 2:
		{
			Player[playerid][Materials][1] += (Player[playerid][VipRank] > 1) ? (20) : (10);
			format(string, sizeof(string), "The man unlocks the box and gives you %d standard grade materials.", (Player[playerid][VipRank] > 1) ? (20) : (10));
			new str[128];
			format(str, sizeof(str), "[MATRUN] %s has received %d standard grade materials (previously had %d standard mats)", GetName(playerid), (Player[playerid][VipRank] > 1) ? (20) : (10), Player[playerid][Materials][1]);
			StatLog(str);
		}
		case 3:
		{
			Player[playerid][Materials][2] += (Player[playerid][VipRank] > 1) ? (20) : (10);
			format(string, sizeof(string), "The man unlocks the box and gives you %d military grade materials.", (Player[playerid][VipRank] > 1) ? (20) : (10));
			new str[128];
			format(str, sizeof(str), "[MATRUN] %s has received %d military grade materials (previously had %d military mats)", GetName(playerid), (Player[playerid][VipRank] > 1) ? (20) : (10), Player[playerid][Materials][2]);
			StatLog(str);
		}
	}
	
	SendClientMessage(playerid, WHITE, string);
	
	Player[playerid][Checkpoint] = 0;
	Player[playerid][MatRunning] = 0;
	Player[playerid][CompleteRun] = 0;
	Player[playerid][TotalMatRuns] ++;
	DisablePlayerCheckpoint(playerid);
	DisablePlayerRaceCheckpoint(playerid);
	if(IsValidPlayerObject(playerid, MatObject[playerid]))
		DestroyPlayerObject(playerid, MatObject[playerid]);
	return 1;
}

task Arms_OneSecondGlobal[1000]()
{
	MatrunTimer++;
	if(MatrunTimer >= 15)
	{
		MatrunTimer = 0;
		MatrunRandPos = Arms_GetRandomMatrun();
	}
	return 1;
}

ptask Arms_OneSecondPlayer[1000](playerid)
{	
	if(Player[playerid][MatRunning] > 0 && !IsValidPlayerObject(playerid, MatObject[playerid]) && GetPVarInt(playerid, "MATRUNPOS") != -1)
	{
		new matrunpos = GetPVarInt(playerid, "MATRUNPOS");
		MatObject[playerid] = CreatePlayerObject(playerid, MATRUN_OBJECT, Matruns[matrunpos][0], Matruns[matrunpos][1], Matruns[matrunpos][2], 0.00, 0.00, random(360));
	}
	return 1;
}

ptask Arms_CheckpointUpdater[1000 * 60](playerid)
{
	if(Player[playerid][MatRunning] > 0 && IsValidPlayerObject(playerid, MatObject[playerid]))
	{
		new Float:x, Float:y, Float:z;
		GetPlayerObjectPos(playerid, MatObject[playerid], x, y, z);
		new randx = floatround(x) + RandomEx(-100, 100);
		new randy = floatround(y) + RandomEx(-100, 100);
		SetPlayerRaceCheckpoint(playerid, 0, randx, randy, z + 10, x, y, z, 10.0);
		Player[playerid][Checkpoint] = 1;
	}
	else if(Player[playerid][MatRunning] == 0 && IsValidPlayerObject(playerid, MatObject[playerid]))
	{
		DestroyPlayerObject(playerid, MatObject[playerid]);
	}
}
