/*
#		MTG Hunger System
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

#define HUNGER_EFFECT_TIME 5
#define HUNGER_EFFECT_ZERO_PERCENT 100

new PlayerBar:Hunger[MAX_PLAYERS] = {INVALID_PLAYER_BAR_ID, ...}, DisplayingHunger[MAX_PLAYERS];

hook OnPlayerConnect(playerid)
{
	Hunger[playerid] = CreatePlayerProgressBar(playerid, 548.5, 35.0, _, _, 0xED6F15FF, 100.0);
	DisplayingHunger[playerid] = 0;
	DisplayHunger(playerid);
}

hook OnPlayerSpawn(playerid)
{
	if(DisplayingHunger[playerid])
	{
		SetPlayerProgressBarValue(playerid, Hunger[playerid], Player[playerid][HungerLevel]);
		UpdatePlayerProgressBar(playerid, Hunger[playerid]);
		RefreshHunger(playerid);
	}
}

ptask HungerUpdate[432000](playerid) // 432000ms = 7.2 minutes. (7.2m x 60s = 432s x 1000ms = 432000ms)
{
	if(!IsHungerEnabledForPlayer(playerid) || Player[playerid][AdminDuty])
		return 1;
		
	if(Player[playerid][HungerLevel] > 0)
		Player[playerid][HungerLevel]--;
	else
		Player[playerid][HungerLevel] = 0;
	
	if(Player[playerid][HungerLevel] >= 0)
		SetPlayerProgressBarValue(playerid, Hunger[playerid], Player[playerid][HungerLevel]);
	else
		SetPlayerProgressBarValue(playerid, Hunger[playerid], 0);
		
	if(DisplayingHunger[playerid])
		UpdatePlayerProgressBar(playerid, Hunger[playerid]);
	
	if(Player[playerid][HungerLevel] == 50 || Player[playerid][HungerLevel] == 40)
	{
		new string[128];
		format(string, sizeof(string), "* %s's stomach quietly rumbles.", GetNameEx(playerid));
		NearByMessage(playerid, NICESKY, string);
		
		if(Player[playerid][HungerLevel] == 50)
			SendClientMessage(playerid, -1, "You're starting to get hungry and your stomach is rumbling. Consider getting something to eat and drink.");
		else
			SendClientMessage(playerid, -1, "You're feeling hungry and your stomach is rumbling. Consider finding something to eat and drink.");
	}
	else if(Player[playerid][HungerLevel] == 25 || Player[playerid][HungerLevel] == 10)
	{
		new string[128];
		format(string, sizeof(string), "* %s's stomach rumbles violently.", GetNameEx(playerid));
		NearByMessage(playerid, NICESKY, string);
		
		if(Player[playerid][HungerLevel] == 25)
		{
			SendClientMessage(playerid, -1, "You're beginning to feel weak and need something to eat. Find some food to regain strength!");
			Player[playerid][HungerEffect] = HUNGER_EFFECT_TIME + random(15);
			SetPlayerDrunkLevel(playerid, 7000);
		}
		else
		{
			SendClientMessage(playerid, -1, "You're continuing to feel weaker and weaker and are losing strength. Find some food quickly to regain your strength!");
			Player[playerid][HungerEffect] = HUNGER_EFFECT_TIME * 20 + random(10) * 10;
			SetPlayerDrunkLevel(playerid, 10000);
		}
	}
	else if(Player[playerid][HungerLevel] > 10 && Player[playerid][HungerLevel] < 25)
	{
		Player[playerid][HungerEffect] = HUNGER_EFFECT_TIME + random(15);
		SetPlayerDrunkLevel(playerid, 7000);
	}
	else if(Player[playerid][HungerLevel] > 0 && Player[playerid][HungerLevel] < 10)
	{
		Player[playerid][HungerEffect] = HUNGER_EFFECT_TIME * 20 + random(10) * 10;
		SetPlayerDrunkLevel(playerid, 10000);
	}
	else if(Player[playerid][HungerLevel] == 0 && Player[playerid][HungerEffect] != HUNGER_EFFECT_ZERO_PERCENT)
	{
		new string[128];
		format(string, sizeof(string), "* %s's stomach rumbles violently and their skin is noticeably more pale.", GetNameEx(playerid));
		NearByMessage(playerid, NICESKY, string);
		
		SendClientMessage(playerid, -1, "You're skin is becoming pale and you're becoming very weak and sick. You need to eat something very quickly.");
			
		Player[playerid][HungerEffect] = HUNGER_EFFECT_ZERO_PERCENT;
		SetPlayerDrunkLevel(playerid, 20000);
		DeletePVar(playerid, "HungerDrunk");
	}
	return 1;
}

ptask OneSecondUpdate[1000](playerid)
{
	if(!IsPlayerSpawned(playerid) || !IsHungerEnabledForPlayer(playerid) || Player[playerid][AdminDuty])
		return 1;

	if(Player[playerid][HungerEffect] > 0 && Player[playerid][HungerEffect] != HUNGER_EFFECT_ZERO_PERCENT)
	{
		Player[playerid][HungerEffect]--;
		if(Player[playerid][HungerEffect] == 0)
		{
			SetPlayerDrunkLevel(playerid, 0);
		}
	}
	
	new drunktime = GetPVarInt(playerid, "HungerDrunk");
	if(Player[playerid][HungerEffect] == HUNGER_EFFECT_ZERO_PERCENT && drunktime == 0)
	{
		SetPlayerDrunkLevel(playerid, 20000);
		
		SetPVarInt(playerid, "HungerDrunk", gettime() + 60);
		
		if(!IsPlayerInAnyVehicle(playerid))
			ApplyAnimation(playerid, "FOOD", "EAT_Vomit_P", 4.1, 0, 1, 1, 0, 0, 1);
			
		new string[128];
		format(string, sizeof(string), "* %s begins to vomit onto the floor%s.", GetNameEx(playerid), (IsPlayerInAnyVehicle(playerid) && !IsAnyBike(GetPlayerVehicleID(playerid))) ? (" of the vehicle") : (""));
		NearByMessage(playerid, NICESKY, string);
		
		SendClientMessage(playerid, -1, "You're sick and need to eat.");
			
		SetPVarInt(playerid, "HungerSickTimer", gettime() + ((7 * 60) + (random(10) * 60)));
	}
	
	if(drunktime < gettime() && drunktime != 0)
	{
		SetPlayerDrunkLevel(playerid, 20000);
		SetPVarInt(playerid, "HungerDrunk", gettime() + 60);
	}
	
	if(Player[playerid][HungerLevel] == 0 && GetPVarInt(playerid, "HungerLoseHealthTimer") == 0)
		SetPVarInt(playerid, "HungerLoseHealthTimer", gettime() + 120);
	
	new Float:health;
	GetPlayerHealth(playerid, health);
	if(health > 30 && Player[playerid][HungerLevel] == 0 && GetPVarInt(playerid, "HungerLoseHealthTimer") < gettime() && GetPVarInt(playerid, "HungerLoseHealthTimer") != 0)
	{
		if(health - 5 < 30)
			health = 30;
		else
			health = health - 5;
		SetPlayerHealth(playerid, health);
		
		SetPVarInt(playerid, "HungerLoseHealthTimer", gettime() + 120);
	}
	
	new vomit = GetPVarInt(playerid, "HungerSickTimer");
	if(vomit < gettime() && vomit != 0)
	{
		if(!IsPlayerInAnyVehicle(playerid))
			ApplyAnimation(playerid, "FOOD", "EAT_Vomit_P", 4.1, 0, 1, 1, 0, 0, 1);
			
		new string[128];
		format(string, sizeof(string), "* %s begins to vomit onto the floor%s.", GetNameEx(playerid), (IsPlayerInAnyVehicle(playerid) && !IsAnyBike(GetPlayerVehicleID(playerid))) ? (" of the vehicle") : (""));
		NearByMessage(playerid, NICESKY, string);
		
		SendClientMessage(playerid, -1, "You're sick and need to eat.");
			
		vomit = gettime() + ((7 * 60) + (random(10) * 60)); //This is just some random time i came up with lol
		SetPVarInt(playerid, "HungerSickTimer", vomit);
	}
	return 1;
}

stock AddHunger(playerid, amount)
{
	if(!IsHungerEnabledForPlayer(playerid) || Player[playerid][AdminDuty])
		return 1;

	if(amount + Player[playerid][HungerLevel] > 100)
		Player[playerid][HungerLevel] = 100;
	else
		Player[playerid][HungerLevel] += amount;
	
	if(Player[playerid][HungerLevel] < 0)
		Player[playerid][HungerLevel] = 0;
	
	RefreshHunger(playerid);
	
	if(Player[playerid][HungerLevel] >= 0)
		SetPlayerProgressBarValue(playerid, Hunger[playerid], Player[playerid][HungerLevel]);
	else
		SetPlayerProgressBarValue(playerid, Hunger[playerid], 0);
		
	if(DisplayingHunger[playerid])
		UpdatePlayerProgressBar(playerid, Hunger[playerid]);
	return 1;
}

stock RefreshHunger(playerid)
{
	if(Player[playerid][HungerLevel] > 50)
	{
		SetPlayerDrunkLevel(playerid, 0);
		Player[playerid][HungerEffect] = 0;
	}
	
	if(Player[playerid][HungerLevel] > 10 && Player[playerid][HungerLevel] <= 25)
	{
		SetPlayerDrunkLevel(playerid, 7000);
		Player[playerid][HungerEffect] = HUNGER_EFFECT_TIME + random(15);
	}
	
	if(Player[playerid][HungerLevel] > 0 && Player[playerid][HungerLevel] <= 10)
	{
		Player[playerid][HungerEffect] = HUNGER_EFFECT_TIME * 20 + random(10) * 10;
		SetPlayerDrunkLevel(playerid, 10000);
	}

	if(Player[playerid][HungerLevel] == 0)
	{
		Player[playerid][HungerEffect] = HUNGER_EFFECT_ZERO_PERCENT;
		SetPlayerDrunkLevel(playerid, 20000);
	}
	
	if(Player[playerid][HungerLevel] > 30)
		DeletePVar(playerid, "HungerSickTimer");
		
	if(Player[playerid][HungerLevel] > 0)
		DeletePVar(playerid, "HungerLoseHealthTimer");
		
	if(Player[playerid][HungerEffect] != HUNGER_EFFECT_ZERO_PERCENT)
		DeletePVar(playerid, "HungerDrunk");
	return 1;
}

stock IsHungerEnabledForPlayer(playerid)
{
	if(Player[playerid][HungerEnabled] || Player[playerid][PlayingHours] > 25)
		return 1;
	return 0;
}

stock DisplayHunger(playerid)
{
	if(DisplayingHunger[playerid])
		HidePlayerProgressBar(playerid, Hunger[playerid]), DisplayingHunger[playerid] = 0;
	else
		ShowPlayerProgressBar(playerid, Hunger[playerid]), DisplayingHunger[playerid] = 1;
	return 1;
}

CMD:enablehunger(playerid, params[])
{
	if(IsHungerEnabledForPlayer(playerid))
		return SendClientMessage(playerid, WHITE, "You already have hunger enabled.");
		
	if(isnull(params) || strcmp(params, "confirm", true))
		return SendClientMessage(playerid, WHITE, "Are you sure you wish to enable hunger? This cannot be undone. Type if \'/enablehunger confirm\' if you are sure.");
		
	Player[playerid][HungerEnabled] = 1;
	Player[playerid][HungerLevel] = 100;
	
	SetPlayerProgressBarValue(playerid, Hunger[playerid], Player[playerid][HungerLevel]);
	UpdatePlayerProgressBar(playerid, Hunger[playerid]);
	RefreshHunger(playerid);
				
	SendClientMessage(playerid, GREY, "---------------------------------------------------------------------------------");
	SendClientMessage(playerid, WHITE, "Hunger is now enabled for your character. Every 7.2 minutes you will lose 1 percent of your hunger.");
	SendClientMessage(playerid, WHITE, "To regain hunger, you need to eat food. Go to any restaurant and buy food to raise your hunger bar.");
	SendClientMessage(playerid, WHITE, "You can go to the hospital and get medical kits to heal wounds and such.");
	SendClientMessage(playerid, GREY, "---------------------------------------------------------------------------------");
	return 1;
}

CMD:buymedkit(playerid)
{
	if(!IsPlayerInRangeOfPoint(playerid, 1.5, Businesses[Player[playerid][InBusiness]][bInteractX], Businesses[Player[playerid][InBusiness]][bInteractY], Businesses[Player[playerid][InBusiness]][bInteractZ]) && Player[playerid][InBusiness] != 0)
		return SendClientMessage(playerid, GREY, "You must stand near the interaction point to do this.");
		
	new id = Player[playerid][InBusiness];
	if(Businesses[id][bType] != 17)
		return SendClientMessage(playerid, -1, "You must be in a hospital to buy a med kit.");
		
	if(Businesses[id][bProductPrice1] == 0)
		return SendClientMessage(playerid, -1, "You cannot do that reight now.");
		
	if(Player[playerid][Money] < Businesses[id][bProductPrice1])
	{
		new string[128];
		format(string, sizeof(string), "You do not have enough money with you right now to buy this. A Med Kit costs %d.", Businesses[id][bProductPrice1]);
		return SendClientMessage(playerid, WHITE, string);
	}
	
	Player[playerid][Money] -= Businesses[id][bProductPrice1];
	SetPlayerHealth(playerid, 100);
	return SendClientMessage(playerid, WHITE, "You have bought a med kit and used it to heal your body.");
}