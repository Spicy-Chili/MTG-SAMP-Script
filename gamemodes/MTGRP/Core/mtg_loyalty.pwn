/*
#		MTG Loyalty System
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

#define LOYALTY_SHOP_BRONZE_VIP		0
#define LOYALTY_SHOP_SILVER_VIP		1
#define LOYALTY_SHOP_GOLD_VIP		2
#define LOYALTY_SHOP_ARMOUR			3
#define LOYALTY_SHOP_STREET_MATS	4
#define LOYALTY_SHOP_STANDARD_MATS	5
#define LOYALTY_SHOP_MILITARY_MATS	6
#define LOYALTY_SHOP_SMALL_DRUG		7
#define LOYALTY_SHOP_MED_DRUG		8
#define LOYALTY_SHOP_LARGE_DRUG		9
#define LOYALTY_SHOP_HOLIDAY_TOY	10

#define MAX_LOYALTY_SHOP_ITEMS		11

#define LOYALTY_SHOP_ICON_MODEL		1314

#define LOYALTY_FILE_PATH			"Misc/LoyaltyShop.ini"

#define COLOR_LOYALTY				0xffaa00ff

#define LOYALTY_SHOP_MAIN				12312
#define LOYALTY_SHOP_HOLIDAY_TOY_BUY	12313

#define SMALL_INCENTIVE_TABLE		0
#define MEDIUM_INCENTIVE_TABLE		1
#define LARGE_INCENTIVE_TABLE		2


new	LoyaltyShopDisabled, 
	MinimumHoursForStreak,
	Float:LoyaltyShopPos[3],
	LoyaltyShopVW,
	LoyaltyShopIntID,
	LoyaltyShopItemPrices[MAX_LOYALTY_SHOP_ITEMS],
	LoyaltyMatsMin[3],
	LoyaltyDrugMin[3],
	LoyaltyShopIcon,
	Text3D:LoyaltyShopLabel;
	
static string[1024];

/*CMD:testcommand(playerid, params[])
{
	new test, value;
	if(sscanf(params, "dd", test, value))
		return SendClientMessage(playerid, WHITE, "wrong syntax.");
		
	switch(test)
	{
		case 0: Player[playerid][SecondsLoggedIn] = value;
		case 1: Player[playerid][LoyaltyPoints] = value;
		case 2: Player[playerid][LoyaltyStreak] = value;
		case 3: Player[playerid][LoyaltyDailyStreak] = value;
		case 4: Player[playerid][LoyaltyPendingVip] = value;
		case 5: Player[playerid][LoyaltyPendingVipHours] = value;
		case 6: Player[playerid][LoyaltyVipHoursLeft] = value;
		case 7: Player[playerid][LoyaltyPaycheckBoost] = value;
		case 8: Player[playerid][LoyaltyPaycheckBoostTimeLeft] = value;
		case 9: Player[playerid][LastLoyaltyDay] = value;
		case 10: Player[playerid][LastLoyaltyMonth] = value;
		case 11: Player[playerid][LastLoyaltyYear] = value;
	}
	
	return 1;
}*/

CMD:loyaltyinfo(playerid, params[])
{
	SendClientMessage(playerid, WHITE, "---------------------------------------------------------------------");
	
	new paychecksLeft;
	if(MinimumHoursForStreak - Player[playerid][LoyaltyDailyStreak] < 1)
		paychecksLeft = 0;
	else paychecksLeft = MinimumHoursForStreak - Player[playerid][LoyaltyDailyStreak];
	
	format(string, sizeof(string), "Current Streak: %d | Loyalty Points: %d | Paychecks Left Today: %d", Player[playerid][LoyaltyStreak], Player[playerid][LoyaltyPoints], paychecksLeft);
	SendClientMessage(playerid, GREY, string);
	if(Player[playerid][LoyaltyVipRank] > 0)
	{
		format(string, sizeof(string), "Loyalty Vip: %s | Hours Left: %d", Player[playerid][LoyaltyVipRank] == 1 ? ("Bronze") : (Player[playerid][LoyaltyVipRank] == 2 ? ("Silver") : ("Gold")), Player[playerid][LoyaltyVipHoursLeft]);
		SendClientMessage(playerid, GREY, string);
	}
	if(Player[playerid][LoyaltyPaycheckBoostTimeLeft] > 0)
	{
		format(string, sizeof(string), "Loyalty Paycheck Boost: %d percent | Hours Left: %d", Player[playerid][LoyaltyPaycheckBoost], Player[playerid][LoyaltyPaycheckBoostTimeLeft]);
		SendClientMessage(playerid, GREY, string);
	}
	
	new hour, seconds, minutes;
	gettime(hour, minutes, seconds);
	format(string, sizeof(string), "Time until loyalty day reset: %d hours, %d minutes", 24 - hour, 60 - minutes);
	SendClientMessage(playerid, GREY, string);
	SendClientMessage(playerid, WHITE, "---------------------------------------------------------------------");
	return 1;
}

CMD:loyaltyshop(playerid, params[])
{
	if(!IsPlayerInRangeOfPoint(playerid, 5.0, LoyaltyShopPos[0], LoyaltyShopPos[1], LoyaltyShopPos[2]))
		return SendClientMessage(playerid, WHITE, "You must be at the loyalty shop to use this command!");
	
	if(GetPlayerVirtualWorld(playerid) != LoyaltyShopVW || GetPlayerInterior(playerid) != LoyaltyShopIntID)
		return SendClientMessage(playerid, WHITE, "You must be at the loyalty shop to use this command!");
	
	format(string, sizeof(string), "Item\tPoints Cost\nBronze VIP (6 hours)\t%d\nSilver VIP (6 hours)\t%d\nGold VIP (6 hours)\t%d", LoyaltyShopItemPrices[LOYALTY_SHOP_BRONZE_VIP], LoyaltyShopItemPrices[LOYALTY_SHOP_SILVER_VIP], LoyaltyShopItemPrices[LOYALTY_SHOP_GOLD_VIP]);
	format(string, sizeof(string), "%s\nArmour Vest\t%d\nStreet Mats Pack\t%d\nStandard Mats Pack\t%d\nMilitary Mats Pack\t%d", string, LoyaltyShopItemPrices[LOYALTY_SHOP_ARMOUR], LoyaltyShopItemPrices[LOYALTY_SHOP_STREET_MATS], LoyaltyShopItemPrices[LOYALTY_SHOP_STANDARD_MATS], LoyaltyShopItemPrices[LOYALTY_SHOP_MILITARY_MATS]);
	format(string, sizeof(string), "%s\nSmall Drug Pack\t%d\nMedium Drug Pack\t%d\nLarge Drug Pack\t%d\nHoliday Toy\t%d", string, LoyaltyShopItemPrices[LOYALTY_SHOP_SMALL_DRUG], LoyaltyShopItemPrices[LOYALTY_SHOP_MED_DRUG], LoyaltyShopItemPrices[LOYALTY_SHOP_LARGE_DRUG], LoyaltyShopItemPrices[LOYALTY_SHOP_HOLIDAY_TOY]);
	ShowPlayerDialog(playerid, LOYALTY_SHOP_MAIN, DIALOG_STYLE_TABLIST_HEADERS, "MTG Loyalty Shop", string, "Purchase", "Cancel");
	return 1;
}

CMD:editloyaltyshopprices(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
		
	new item, price;
	if(sscanf(params, "dd", item, price))
	{
		SendClientMessage(playerid, WHITE, "SYNTAX: /editloyaltyshopprices [item] [price]");
		SendClientMessage(playerid, GREY, "ITEMS: 0 - Bronze VIP | 1 - Silver VIP | 2 - Gold VIP | 3 - Armour Vest | 4 - Street Mats | 5 - Standard Mats");
		return SendClientMessage(playerid, GREY, "6 - Military Mats | 7 - Small Drug | 8 - Med Drug | 9 - Large Drug | 10 - Holiday Toy");
	}
	
	if(item < 0 || item > (MAX_LOYALTY_SHOP_ITEMS - 1))
		return SendClientMessage(playerid, WHITE, "Invalid item ID.");
	
	if(price < 1)
		return SendClientMessage(playerid, WHITE, "Invalid price.");
	
	LoyaltyShopItemPrices[item] = price;
	SaveLoyaltyShop();
	format(string, sizeof(string), "You have changed the price of item %d to %d points.", item, price);
	SendClientMessage(playerid, WHITE, string);
	format(string, sizeof(string), "%s has changed the price of item %d to %d.", GetName(playerid), item, price);
	LoyaltyLog(string);
	return 1;
}

CMD:editloyaltyrewards(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
		
	new reward, minimum;
	if(sscanf(params, "dd", reward, minimum))
	{
		SendClientMessage(playerid, WHITE, "SYNTAX: /editloyaltyrewards [reward] [new minimum]");
		format(string, sizeof(string), "REWARDS: 0 - Street Mats (%d) | 1 - Standard Mats (%d) | 2 - Military Mats (%d)", LoyaltyMatsMin[0], LoyaltyMatsMin[1], LoyaltyMatsMin[2]);
		SendClientMessage(playerid, GREY, string);
		format(string, sizeof(string), "3 - Small Drugs (%d) | 4 - Medium Drugs (%d) | 5 - Large Drugs (%d)", LoyaltyDrugMin[0], LoyaltyDrugMin[1], LoyaltyDrugMin[2]);
		SendClientMessage(playerid, GREY, string);
		return SendClientMessage(playerid, GREY, "NOTE: Rewards range from minimum to minimum x 4");
	}
	
	if(minimum < 1)
		return SendClientMessage(playerid, WHITE, "Invalid minimum.");
		
	if(reward < 0 || reward > 5)
		return SendClientMessage(playerid, WHITE, "Invalid reward type.");
		
	if(reward < 3)
	{
		LoyaltyMatsMin[reward] = minimum;
	}
	else 
	{
		LoyaltyDrugMin[reward - 3] = minimum;
	}
	SaveLoyaltyShop();
	format(string, sizeof(string), "You have set the minimum of reward %d to %d. New max is %d.", reward, minimum, minimum * 4);
	SendClientMessage(playerid, WHITE, string);
	format(string, sizeof(string), "%s has set the minimum of reward %d to %d. New max is %d.", GetName(playerid), reward, minimum, minimum * 4);
	LoyaltyLog(string);
	return 1;
}

CMD:moveloyaltyshop(playerid, parmas[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
	
	new Float:pos[3];
	GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	
	if(IsValidDynamicPickup(LoyaltyShopIcon))
		DestroyDynamicPickup(LoyaltyShopIcon);
		
	if(IsValidDynamic3DTextLabel(LoyaltyShopLabel))
		DestroyDynamic3DTextLabel(LoyaltyShopLabel);
		
	LoyaltyShopPos[0] = pos[0];
	LoyaltyShopPos[1] = pos[1];
	LoyaltyShopPos[2] = pos[2];
	LoyaltyShopVW = GetPlayerVirtualWorld(playerid);
	LoyaltyShopIntID = GetPlayerInterior(playerid);
	SaveLoyaltyShop();
	LoyaltyShopIcon = CreateDynamicPickup(LOYALTY_SHOP_ICON_MODEL, 23, LoyaltyShopPos[0], LoyaltyShopPos[1], LoyaltyShopPos[2], LoyaltyShopVW, LoyaltyShopIntID, -1, 150.0);
	LoyaltyShopLabel = CreateDynamic3DTextLabel("MTG Loyalty Shop\n/loyaltyshop", COLOR_LOYALTY, LoyaltyShopPos[0], LoyaltyShopPos[1], LoyaltyShopPos[2], 20, .worldid = LoyaltyShopVW, .interiorid = LoyaltyShopIntID);
	SendClientMessage(playerid, WHITE, "You have moved the loyalty shop.");
	return 1;
}

CMD:loyaltyredeem(playerid, params[])
{
	if(!IsPlayerInRangeOfPoint(playerid, 5.0, LoyaltyShopPos[0], LoyaltyShopPos[1], LoyaltyShopPos[2]))
		return SendClientMessage(playerid, WHITE, "You must be at the loyalty shop to use this command!");
	
	if(GetPlayerVirtualWorld(playerid) != LoyaltyShopVW || GetPlayerInterior(playerid) != LoyaltyShopIntID)
		return SendClientMessage(playerid, WHITE, "You must be at the loyalty shop to use this command!");
		
	if(strlen(Player[playerid][LoyaltyRewards]) < 3)
		return SendClientMessage(playerid, WHITE, "You have nothing to redeem!");
		
	new item[20], x, amount[5], finish;
	while(finish != 1)
	{
		format(item, 20, "%s", CutBeforeLine(Player[playerid][LoyaltyRewards]));
		if(strfind(item, "pot", true) > 1)
		{
			x = strfind(item, "pot", true);
			strmid(amount, item, 0, x-1); 
			Player[playerid][Pot] += strval(amount);
			format(string, sizeof(string), "You have received %s pot!", amount);
		}
		else if(strfind(item, "cocaine", true) > 1)
		{
			x = strfind(item, "cocaine", true);
			strmid(amount, item, 0, x-1); 
			Player[playerid][Cocaine] += strval(amount);
			format(string, sizeof(string), "You have received %s cocaine!", amount);
		}
		else if(strfind(item, "speed", true) > 1)
		{
			x = strfind(item, "speed", true);
			strmid(amount, item, 0, x-1); 
			Player[playerid][Speed] += strval(amount);
			format(string, sizeof(string), "You have received %s speed!", amount);
		}
		else if(strfind(item, "strm", true) > 1)
		{
			x = strfind(item, "strm", true);
			strmid(amount, item, 0, x-1); 
			Player[playerid][Materials][0] += strval(amount);
			format(string, sizeof(string), "You have received %s street materials!", amount);
		}
		else if(strfind(item, "stam", true) > 1)
		{
			x = strfind(item, "stam", true);
			strmid(amount, item, 0, x-1); 
			Player[playerid][Materials][1] += strval(amount);
			format(string, sizeof(string), "You have received %s standard materials!", amount);
		}
		else if(strfind(item, "milm", true) > 1)
		{
			x = strfind(item, "milm", true);
			strmid(amount, item, 0, x-1); 
			Player[playerid][Materials][2] += strval(amount);
			format(string, sizeof(string), "You have received %s military materials!", amount);
		}
		SendClientMessage(playerid, COLOR_LOYALTY, string);
		x = strlen(item);
		strdel(Player[playerid][LoyaltyRewards], 0, x+2);
		if(strlen(Player[playerid][LoyaltyRewards]) < 3)
		{
			finish = 1;
			format(Player[playerid][LoyaltyRewards], 256, "");
		}
	}
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case LOYALTY_SHOP_MAIN:
		{
			if(!response)
				return 1;
				
			switch(listitem)
			{
				case 0:
				{
					if(Player[playerid][VipRank] > 0)
						return SendClientMessage(playerid, WHITE, "You can't purchase this with an active VIP subscription.");
					
					if(Player[playerid][LoyaltyPoints] < LoyaltyShopItemPrices[LOYALTY_SHOP_BRONZE_VIP])
						return SendClientMessage(playerid, WHITE, "You don't have enough loyalty points to purchase this!");
					
					if(Player[playerid][LoyaltyVipRank] != 0 && Player[playerid][LoyaltyVipRank] != 1)
						return SendClientMessage(playerid, WHITE, "You can't purchase Bronze VIP while you have another loyalty vip rank active.");
					
					Player[playerid][LoyaltyPoints] -= LoyaltyShopItemPrices[LOYALTY_SHOP_BRONZE_VIP];
					Player[playerid][LoyaltyPendingVip] = 1;
					Player[playerid][LoyaltyPendingVipHours] += 6;
					SendClientMessage(playerid, WHITE, "You have purchased 6 playing hours of Bronze VIP! It will activate at your next paycheck.");
					
					format(string, sizeof(string), "%s has purchased 6 playing hours of Bronze VIP.", GetName(playerid));
					LoyaltyLog(string);
				}
				case 1:
				{	
					if(Player[playerid][VipRank] > 0)
						return SendClientMessage(playerid, WHITE, "You can't purchase this with an active VIP subscription.");
						
					if(Player[playerid][LoyaltyPoints] < LoyaltyShopItemPrices[LOYALTY_SHOP_SILVER_VIP])
						return SendClientMessage(playerid, WHITE, "You don't have enough loyalty points to purchase this!");
						
					if(Player[playerid][LoyaltyVipRank] != 0 && Player[playerid][LoyaltyVipRank] != 2)
						return SendClientMessage(playerid, WHITE, "You can't purchase Silver VIP while you have another loyalty vip rank active.");
					
					Player[playerid][LoyaltyPoints] -= LoyaltyShopItemPrices[LOYALTY_SHOP_SILVER_VIP];
					Player[playerid][LoyaltyPendingVip] = 2;
					Player[playerid][LoyaltyPendingVipHours] += 6;
					SendClientMessage(playerid, WHITE, "You have purchased 6 playing hours of Silver VIP! It will activate at your next paycheck.");
					
					format(string, sizeof(string), "%s has purchased 6 playing hours of Silver VIP.", GetName(playerid));
					LoyaltyLog(string);
				}
				case 2:
				{
					if(Player[playerid][VipRank] > 0)
						return SendClientMessage(playerid, WHITE, "You can't purchase this with an active VIP subscription.");
						
					if(Player[playerid][LoyaltyPoints] < LoyaltyShopItemPrices[LOYALTY_SHOP_GOLD_VIP])
						return SendClientMessage(playerid, WHITE, "You don't have enough loyalty points to purchase this!");
						
					if(Player[playerid][LoyaltyVipRank] != 0 && Player[playerid][LoyaltyVipRank] != 3)
						return SendClientMessage(playerid, WHITE, "You can't purchase Gold VIP while you have another loyalty vip rank active.");
					
					Player[playerid][LoyaltyPoints] -= LoyaltyShopItemPrices[LOYALTY_SHOP_GOLD_VIP];
					Player[playerid][LoyaltyPendingVip] = 3;
					Player[playerid][LoyaltyPendingVipHours] += 6;
					SendClientMessage(playerid, WHITE, "You have purchased 6 playing hours of Gold VIP! It will activate at your next paycheck.");
					
					format(string, sizeof(string), "%s has purchased 6 playing hours of Gold VIP.", GetName(playerid));
					LoyaltyLog(string);
				}
				case 3:
				{
					if(Player[playerid][LoyaltyPoints] < LoyaltyShopItemPrices[LOYALTY_SHOP_ARMOUR])
						return SendClientMessage(playerid, WHITE, "You don't have enough loyalty points to purchase this!");
					
					new Float:armour;
					GetPlayerArmour(playerid, armour);
					
					if(armour > 0)
						return SendClientMessage(playerid, WHITE, "You can't purchase an armour vest until you remove your current one.");
					
					Player[playerid][LoyaltyPoints] -= LoyaltyShopItemPrices[LOYALTY_SHOP_ARMOUR];
					SetPlayerArmour(playerid, 100);
					SendClientMessage(playerid, WHITE, "You have purchased full armour.");
					format(string, sizeof(string), "%s has purchased full armour.", GetName(playerid));
					LoyaltyLog(string);
					
					return 1;
				}
				case 4:
				{
					if(Player[playerid][LoyaltyPoints] < LoyaltyShopItemPrices[LOYALTY_SHOP_STREET_MATS])
						return SendClientMessage(playerid, WHITE, "You don't have enough loyalty points to purchase this!");
						
					Player[playerid][LoyaltyPoints] -= LoyaltyShopItemPrices[LOYALTY_SHOP_STREET_MATS];
					GiveRandomLoyaltyReward(playerid, LOYALTY_SHOP_STREET_MATS);
					format(string, sizeof(string), "%s has purchased a street mats pack.", GetName(playerid));
					LoyaltyLog(string);
					return 1;
				}	
				case 5:
				{
					if(Player[playerid][LoyaltyPoints] < LoyaltyShopItemPrices[LOYALTY_SHOP_STANDARD_MATS])
						return SendClientMessage(playerid, WHITE, "You don't have enough loyalty points to purchase this!");
						
					Player[playerid][LoyaltyPoints] -= LoyaltyShopItemPrices[LOYALTY_SHOP_STANDARD_MATS];
					GiveRandomLoyaltyReward(playerid, LOYALTY_SHOP_STANDARD_MATS);
					format(string, sizeof(string), "%s has purchased a standard mats pack.", GetName(playerid));
					LoyaltyLog(string);
				}
				case 6:
				{
					if(Player[playerid][LoyaltyPoints] < LoyaltyShopItemPrices[LOYALTY_SHOP_MILITARY_MATS])
						return SendClientMessage(playerid, WHITE, "You don't have enough loyalty points to purchase this!");
						
					Player[playerid][LoyaltyPoints] -= LoyaltyShopItemPrices[LOYALTY_SHOP_MILITARY_MATS];
					GiveRandomLoyaltyReward(playerid, LOYALTY_SHOP_MILITARY_MATS);
					format(string, sizeof(string), "%s has purchased a military mats pack.", GetName(playerid));
					LoyaltyLog(string);
				}
				case 7:
				{
					if(Player[playerid][LoyaltyPoints] < LoyaltyShopItemPrices[LOYALTY_SHOP_SMALL_DRUG])
						return SendClientMessage(playerid, WHITE, "You don't have enough loyalty points to purchase this!");
						
					Player[playerid][LoyaltyPoints] -= LoyaltyShopItemPrices[LOYALTY_SHOP_SMALL_DRUG];
					GiveRandomLoyaltyReward(playerid, LOYALTY_SHOP_SMALL_DRUG);
					format(string, sizeof(string), "%s has purchased a small drugs pack.", GetName(playerid));
					LoyaltyLog(string);
				}
				case 8:
				{
					if(Player[playerid][LoyaltyPoints] < LoyaltyShopItemPrices[LOYALTY_SHOP_MED_DRUG])
						return SendClientMessage(playerid, WHITE, "You don't have enough loyalty points to purchase this!");
						
					Player[playerid][LoyaltyPoints] -= LoyaltyShopItemPrices[LOYALTY_SHOP_MED_DRUG];
					GiveRandomLoyaltyReward(playerid, LOYALTY_SHOP_MED_DRUG);
					format(string, sizeof(string), "%s has purchased a medium drugs pack.", GetName(playerid));
					LoyaltyLog(string);
				}
				case 9:
				{
					if(Player[playerid][LoyaltyPoints] < LoyaltyShopItemPrices[LOYALTY_SHOP_LARGE_DRUG])
						return SendClientMessage(playerid, WHITE, "You don't have enough loyalty points to purchase this!");
						
					Player[playerid][LoyaltyPoints] -= LoyaltyShopItemPrices[LOYALTY_SHOP_LARGE_DRUG];
					GiveRandomLoyaltyReward(playerid, LOYALTY_SHOP_LARGE_DRUG);
					format(string, sizeof(string), "%s has purchased a large drugs pack.", GetName(playerid));
					LoyaltyLog(string);
				}
				case 10:
				{
					if(Player[playerid][LoyaltyPoints] < LoyaltyShopItemPrices[LOYALTY_SHOP_HOLIDAY_TOY])
						return SendClientMessage(playerid, WHITE, "You don't have enough loyalty points to purchase this!");
					
					ShowPlayerDialog(playerid, LOYALTY_SHOP_HOLIDAY_TOY_BUY, DIALOG_STYLE_LIST, "MTG Loyalty Shop - Holiday Toys", "Swirly Glasses\nEye Ball Glasses\nCheckered Glasses\nX-Ray Glasses\nParrot", "Purchase", "Cancel");
				}
			}
		}
		case LOYALTY_SHOP_HOLIDAY_TOY_BUY:
		{
			if(!response)
				return 1;
				
			new slot = GetAvailableToySlot(playerid);			
			if(slot == -1)
				return SendClientMessage(playerid, -1, "You don't have any available toy slots!");
				
			new toyid;
			switch(listitem)
			{
				case 0: toyid = 19011;
				case 1: toyid = 19013;
				case 2: toyid = 19014;
				case 3: toyid = 19016;
				case 4: toyid = 19078;
			}
			PlayerToys[playerid][ToyModelID][slot] = toyid;
			Player[playerid][LoyaltyPoints] -= LoyaltyShopItemPrices[LOYALTY_SHOP_HOLIDAY_TOY];
			SendClientMessage(playerid, WHITE, "You have purchased an exclusive holiday toy!");
			format(string, sizeof(string), "%s has purchased a holiday toy.", GetName(playerid));
			LoyaltyLog(string);
		}
	}
	return 1;
}

stock GiveOutLoyaltyReward(playerid)
{
	new streak = Player[playerid][LoyaltyStreak];
	
	if(streak < 31)
	{
		switch(streak)
		{
			case 3, 6, 9, 12, 18, 21, 24, 27: 
			{
				new bonus = 1000 + (500 * (streak / 3));
				Player[playerid][BankMoney] += bonus;
				format(string, sizeof(string), "[LOYALTY] You have gained a bonus of %s to your paycheck for your loyalty streak!", PrettyMoney(bonus));
				SendClientMessage(playerid, COLOR_LOYALTY, string);
			}
			case 5, 10, 15, 20, 25, 30:
			{
				Player[playerid][LoyaltyPoints] += 5;
				SendClientMessage(playerid, COLOR_LOYALTY, "[LOYALTY] You have gained 5 Loyalty points for your continued loyalty streak.");
			}
			default: IncentiveTableRoll(playerid, SMALL_INCENTIVE_TABLE);
		}
	}
	else if(streak >= 31 && streak < 61)
	{
		switch(streak)
		{
			case 33, 36, 39, 42, 45, 48, 51, 54, 57:
			{
				new bonus = 5000 + (750 * ((streak - 30) / 3));
				Player[playerid][BankMoney] += bonus;
				format(string, sizeof(string), "[LOYALTY] You have gained a bonus of %s to your paycheck for your loyalty streak!", PrettyMoney(bonus));
				SendClientMessage(playerid, COLOR_LOYALTY, string);
			}
			case 40, 50, 60:
			{
				Player[playerid][LoyaltyPoints] += 15;
				SendClientMessage(playerid, COLOR_LOYALTY, "[LOYALTY] You have gained 15 Loyalty points for your continued loyalty streak.");
			}
			default: IncentiveTableRoll(playerid, SMALL_INCENTIVE_TABLE, 1);
		}
	}
	else if(streak >= 61)
	{
		if(streak % 10 == 0)
		{
			Player[playerid][LoyaltyPoints] += 20;
			SendClientMessage(playerid, COLOR_LOYALTY, "[LOYALTY] You have gained 20 Loyalty points for your continued loyalty streak.");
		}
		else if(streak % 3 == 0)
		{
			new bonus = 12500;
			Player[playerid][BankMoney] += bonus;
			format(string, sizeof(string), "[LOYALTY] You have gained a bonus of %s to your paycheck for your loyalty streak!", PrettyMoney(bonus));
			SendClientMessage(playerid, COLOR_LOYALTY, string);
		}
		else
		{
			IncentiveTableRoll(playerid, SMALL_INCENTIVE_TABLE, 2);
		}
	}
	return 1;
}

stock SaveLoyaltyShop()
{
	if(!fexist(LOYALTY_FILE_PATH))
		dini_Create(LOYALTY_FILE_PATH);
	
	dini_IntSet(LOYALTY_FILE_PATH, "LoyaltyShopDisabled", LoyaltyShopDisabled);
	dini_IntSet(LOYALTY_FILE_PATH, "MinimumHoursForStreak", MinimumHoursForStreak);
	dini_FloatSet(LOYALTY_FILE_PATH, "LoyaltyShopPos_X", LoyaltyShopPos[0]);
	dini_FloatSet(LOYALTY_FILE_PATH, "LoyaltyShopPos_Y", LoyaltyShopPos[1]);
	dini_FloatSet(LOYALTY_FILE_PATH, "LoyaltyShopPos_Z", LoyaltyShopPos[2]);
	dini_IntSet(LOYALTY_FILE_PATH, "LoyaltyShopVW", LoyaltyShopVW);
	dini_IntSet(LOYALTY_FILE_PATH, "LoyaltyShopIntID", LoyaltyShopIntID);
	
	dini_IntSet(LOYALTY_FILE_PATH, "LoyaltyMatMinStreet", LoyaltyMatsMin[0]);
	dini_IntSet(LOYALTY_FILE_PATH, "LoyaltyMatMinStandard", LoyaltyMatsMin[1]);
	dini_IntSet(LOYALTY_FILE_PATH, "LoyaltyMatMinMilitary", LoyaltyMatsMin[2]);
	dini_IntSet(LOYALTY_FILE_PATH, "LoyaltyDrugMinSmall", LoyaltyDrugMin[0]);
	dini_IntSet(LOYALTY_FILE_PATH, "LoyaltyDrugMinMed", LoyaltyDrugMin[1]);
	dini_IntSet(LOYALTY_FILE_PATH, "LoyaltyDrugMinLarge", LoyaltyDrugMin[2]);
	
	for(new i; i < MAX_LOYALTY_SHOP_ITEMS; i++)
	{
		format(string, sizeof(string), "LoyaltyShopItemPrice_%d", i);
		dini_IntSet(LOYALTY_FILE_PATH, string, LoyaltyShopItemPrices[i]);
	}
	
	return 1;
}

stock LoadLoyaltyShop()
{
	if(!fexist(LOYALTY_FILE_PATH))
	{
		dini_Create(LOYALTY_FILE_PATH);
		
		LoyaltyShopDisabled = 0;
		MinimumHoursForStreak = 3;
		LoyaltyShopItemPrices[LOYALTY_SHOP_BRONZE_VIP] = 15;
		LoyaltyShopItemPrices[LOYALTY_SHOP_SILVER_VIP] = 25;
		LoyaltyShopItemPrices[LOYALTY_SHOP_GOLD_VIP] = 35;
		LoyaltyShopItemPrices[LOYALTY_SHOP_ARMOUR] = 15;
		LoyaltyShopItemPrices[LOYALTY_SHOP_STREET_MATS] = 5;
		LoyaltyShopItemPrices[LOYALTY_SHOP_STANDARD_MATS] = 10;
		LoyaltyShopItemPrices[LOYALTY_SHOP_MILITARY_MATS] = 15;
		LoyaltyShopItemPrices[LOYALTY_SHOP_SMALL_DRUG] = 10;
		LoyaltyShopItemPrices[LOYALTY_SHOP_MED_DRUG] = 20;
		LoyaltyShopItemPrices[LOYALTY_SHOP_LARGE_DRUG] = 30;
		LoyaltyShopItemPrices[LOYALTY_SHOP_HOLIDAY_TOY] = 15; 
		
		LoyaltyMatsMin[0] = 200;
		LoyaltyMatsMin[1] = 200;
		LoyaltyMatsMin[2] = 200;
		LoyaltyDrugMin[0] = 25;
		LoyaltyDrugMin[1] = 50;
		LoyaltyDrugMin[2] = 75;
		
		SaveLoyaltyShop();
		return 1;
	}

	LoyaltyShopDisabled = dini_Int(LOYALTY_FILE_PATH, "LoyaltyShopDisabled");
	MinimumHoursForStreak = dini_Int(LOYALTY_FILE_PATH, "MinimumHoursForStreak");
	LoyaltyShopPos[0] = dini_Float(LOYALTY_FILE_PATH, "LoyaltyShopPos_X");
	LoyaltyShopPos[1] = dini_Float(LOYALTY_FILE_PATH, "LoyaltyShopPos_Y");
	LoyaltyShopPos[2] = dini_Float(LOYALTY_FILE_PATH, "LoyaltyShopPos_Z");
	LoyaltyShopVW = dini_Int(LOYALTY_FILE_PATH, "LoyaltyShopVW");
	LoyaltyShopIntID = dini_Int(LOYALTY_FILE_PATH, "LoyaltyShopIntID");
	LoyaltyMatsMin[0] = dini_Int(LOYALTY_FILE_PATH, "LoyaltyMatMinStreet");
	LoyaltyMatsMin[1] = dini_Int(LOYALTY_FILE_PATH, "LoyaltyMatMinStandard");
	LoyaltyMatsMin[2] = dini_Int(LOYALTY_FILE_PATH, "LoyaltyMatMinMilitary");
	LoyaltyDrugMin[0] = dini_Int(LOYALTY_FILE_PATH, "LoyaltyDrugMinSmall");
	LoyaltyDrugMin[1] = dini_Int(LOYALTY_FILE_PATH, "LoyaltyDrugMinMed");
	LoyaltyDrugMin[2] = dini_Int(LOYALTY_FILE_PATH, "LoyaltyDrugMinLarge");
	
	for(new i; i < MAX_LOYALTY_SHOP_ITEMS; i++)
	{
		format(string, sizeof(string), "LoyaltyShopItemPrice_%d", i);
		LoyaltyShopItemPrices[i] = dini_Int(LOYALTY_FILE_PATH, string);
	}
	
	LoyaltyShopIcon = CreateDynamicPickup(LOYALTY_SHOP_ICON_MODEL, 23, LoyaltyShopPos[0], LoyaltyShopPos[1], LoyaltyShopPos[2], LoyaltyShopVW, LoyaltyShopIntID, -1, 150.0);
	LoyaltyShopLabel = CreateDynamic3DTextLabel("MTG Loyalty Shop\n/loyaltyshop", COLOR_LOYALTY, LoyaltyShopPos[0], LoyaltyShopPos[1], LoyaltyShopPos[2], 20, .worldid = LoyaltyShopVW, .interiorid = LoyaltyShopIntID);
	return 1;
}

stock IncentiveTableRoll(playerid, table = SMALL_INCENTIVE_TABLE, special_roll = 0)
{
	switch(table)
	{
		case SMALL_INCENTIVE_TABLE:
		{
			new roll = random(100);
			switch(roll)
			{
				case 0..39:
				{
					if(special_roll == 1 && roll < 18) //After 30 days add 18% of hitting medium
						IncentiveTableRoll(playerid, MEDIUM_INCENTIVE_TABLE, 0);
					else if(special_roll == 2 && roll < 30)
						IncentiveTableRoll(playerid, MEDIUM_INCENTIVE_TABLE, 1); //After 60 days add 30% chance of hitting medium and chance at large table
					else
					{
						Player[playerid][BankMoney] += 2500;
						SendClientMessage(playerid, COLOR_LOYALTY, "[LOYALTY] You have been given $2500 for your continued loyalty streak!");
						
						format(string, sizeof(string), "%s has been awarded $2500.", GetName(playerid));
						LoyaltyLog(string);
					}						
				}
				case 40..59: GiveRandomLoyaltyReward(playerid, LOYALTY_SHOP_STREET_MATS);
				case 60..79: GiveRandomLoyaltyReward(playerid, LOYALTY_SHOP_SMALL_DRUG);
				case 80..99:
				{
					Player[playerid][LoyaltyPaycheckBoost] = 15;
					Player[playerid][LoyaltyPaycheckBoostTimeLeft] += 2;
					
					SendClientMessage(playerid, COLOR_LOYALTY, "[LOYALTY] You have been awarded a 15%% paycheck boost for 2 hours for your loyalty streak!");
					format(string, sizeof(string), "%s has been awarded a 15%% paycheck boost for two hours.", GetName(playerid));
					LoyaltyLog(string);
				}
			}
		}
		case MEDIUM_INCENTIVE_TABLE:
		{
			new roll = random(100);
			switch(roll)
			{
				case 0..39:
				{
					if(special_roll == 1 && roll < 33) //After 60 days add 33% chance of large table
						IncentiveTableRoll(playerid, LARGE_INCENTIVE_TABLE, 0);
					else
					{
						Player[playerid][BankMoney] += 5000;
						SendClientMessage(playerid, COLOR_LOYALTY, "[LOYALTY] You have been given $5000 for your continued loyalty streak!");
						
						format(string, sizeof(string), "%s has been awarded $5000.", GetName(playerid));
						LoyaltyLog(string);
					}						
				}
				case 40..59: GiveRandomLoyaltyReward(playerid, LOYALTY_SHOP_STANDARD_MATS);
				case 60..79: GiveRandomLoyaltyReward(playerid, LOYALTY_SHOP_MED_DRUG);
				case 80..99:
				{
					Player[playerid][LoyaltyPaycheckBoost] = 20;
					Player[playerid][LoyaltyPaycheckBoostTimeLeft] += 2;
					
					SendClientMessage(playerid, COLOR_LOYALTY, "[LOYALTY] You have been awarded a 20%% paycheck boost for 2 hours for your loyalty streak!");
					format(string, sizeof(string), "%s has been awarded a 20%% paycheck boost for two hours.", GetName(playerid));
					LoyaltyLog(string);
				}
			}
		}
		case LARGE_INCENTIVE_TABLE:
		{
			new roll = random(100);
			switch(roll)
			{
				case 0..39:
				{
					Player[playerid][BankMoney] += 7500;
					SendClientMessage(playerid, COLOR_LOYALTY, "[LOYALTY] You have been given $7500 for your continued loyalty streak!");
					
					format(string, sizeof(string), "%s has been awarded $7500.", GetName(playerid));
					LoyaltyLog(string);
				}
				case 40..59: GiveRandomLoyaltyReward(playerid, LOYALTY_SHOP_MILITARY_MATS);
				case 60..79: GiveRandomLoyaltyReward(playerid, LOYALTY_SHOP_LARGE_DRUG);
				case 80..99:
				{
					Player[playerid][LoyaltyPaycheckBoost] = 25;
					Player[playerid][LoyaltyPaycheckBoostTimeLeft] += 2;
					
					SendClientMessage(playerid, COLOR_LOYALTY, "[LOYALTY] You have been awarded a 25%% paycheck boost for 2 hours for your loyalty streak!");
					format(string, sizeof(string), "%s has been awarded a 25%% paycheck boost for two hours.", GetName(playerid));
					LoyaltyLog(string);
				}
			}
		}
	}
	return 1;
}

stock GiveRandomLoyaltyReward(playerid, reward_type)
{
	new Float:totalMult;
	switch(random(100))
	{
		case 0..19: totalMult = 1;
		case 20..44: totalMult = 1.2;
		case 45..69: totalMult = 1.3;
		case 70..79: totalMult = 1.5;
		case 80..89: totalMult = 1.6;
		case 90..93: totalMult = 1.7;
		case 94..96: totalMult = 1.8;
		case 97..98: totalMult = 1.9;
		case 99: totalMult = 2.0;
	}
	
	switch(random(100))
	{
		case 0..19: totalMult *= 1;
		case 20..44: totalMult *= 1.2;
		case 45..69: totalMult *= 1.3;
		case 70..79: totalMult *= 1.5;
		case 80..89: totalMult *= 1.6;
		case 90..93: totalMult *= 1.7;
		case 94..96: totalMult *= 1.8;
		case 97..98: totalMult *= 1.9;
		case 99: totalMult *= 2.0;
	}
	
	switch(reward_type)
	{
		case LOYALTY_SHOP_STREET_MATS: //Minimum $5000, max $20000
		{
			new amount = floatround(float(LoyaltyMatsMin[0]) * totalMult, floatround_round);
			format(Player[playerid][LoyaltyRewards], 256, "%s%d strm |", Player[playerid][LoyaltyRewards], amount);
			format(string, sizeof(string), "[LOYALTY] You have gained %d street materials to redeem! (/loyaltyredeem)", amount);
			SendClientMessage(playerid, COLOR_LOYALTY, string);
			
			format(string, sizeof(string), "[LOYALTY] %s has gained %d street grade materials.", GetName(playerid), amount);
			LoyaltyLog(string);
			StatLog(string);
		}
		case LOYALTY_SHOP_STANDARD_MATS: //Minimum $10k, max $40000
		{
			new amount = floatround(float(LoyaltyMatsMin[1]) * totalMult, floatround_round);
			format(Player[playerid][LoyaltyRewards], 256, "%s%d stam |", Player[playerid][LoyaltyRewards], amount);
			format(string, sizeof(string), "[LOYALTY] You have gained %d standard materials to redeem! (/loyaltyredeem)", amount);
			SendClientMessage(playerid, COLOR_LOYALTY, string);
			
			format(string, sizeof(string), "[LOYALTY] %s has gained %d standard grade materials.", GetName(playerid), amount);
			LoyaltyLog(string);
			StatLog(string);
		}
		case LOYALTY_SHOP_MILITARY_MATS: //Min $15000, max $60,000
		{
			new amount = floatround(float(LoyaltyMatsMin[2]) * totalMult, floatround_round);
			format(Player[playerid][LoyaltyRewards], 256, "%s%d milm |", Player[playerid][LoyaltyRewards], amount);
			format(string, sizeof(string), "[LOYALTY] You have gained %d military materials to redeem! (/loyaltyredeem)", amount);
			SendClientMessage(playerid, COLOR_LOYALTY, string);
			
			format(string, sizeof(string), "[LOYALTY] %s has gained %d military grade materials.", GetName(playerid), amount);
			LoyaltyLog(string);
			StatLog(string);
		}
		case LOYALTY_SHOP_SMALL_DRUG:
		{
			new amount = floatround(float(LoyaltyDrugMin[0]) * totalMult, floatround_round);
			
			switch(random(3))
			{
				case 0:
				{
					format(Player[playerid][LoyaltyRewards], 256, "%s%d pot |", Player[playerid][LoyaltyRewards], amount);
					format(string, sizeof(string), "[LOYALTY] You have gained %d pot to redeem! (/loyaltyredeem)", amount);
					SendClientMessage(playerid, COLOR_LOYALTY, string);
					
					format(string, sizeof(string), "[LOYALTY] %s has gained %d pot.", GetName(playerid), amount);
					LoyaltyLog(string);
					StatLog(string);
				}
				case 1:
				{
					format(Player[playerid][LoyaltyRewards], 256, "%s%d speed |", Player[playerid][LoyaltyRewards], amount);
					format(string, sizeof(string), "[LOYALTY] You have gained %d speed to redeem! (/loyaltyredeem)", amount);
					SendClientMessage(playerid, COLOR_LOYALTY, string);
					
					format(string, sizeof(string), "[LOYALTY] %s has gained %d speed.", GetName(playerid), amount);
					LoyaltyLog(string);
					StatLog(string);
				}
				case 2:
				{
					format(Player[playerid][LoyaltyRewards], 256, "%s%d cocaine |", Player[playerid][LoyaltyRewards], amount);
					format(string, sizeof(string), "[LOYALTY] You have gained %d cocaine to redeem! (/loyaltyredeem)", amount);
					SendClientMessage(playerid, COLOR_LOYALTY, string);
					
					format(string, sizeof(string), "[LOYALTY] %s has gained %d cocaine.", GetName(playerid), amount);
					LoyaltyLog(string);
					StatLog(string);
				}
			}
		}
		case LOYALTY_SHOP_MED_DRUG:
		{
			new amount = floatround(float(LoyaltyDrugMin[1]) * totalMult, floatround_round);
			
			switch(random(3))
			{
				case 0:
				{
					format(Player[playerid][LoyaltyRewards], 256, "%s%d pot |", Player[playerid][LoyaltyRewards], amount);
					format(string, sizeof(string), "[LOYALTY] You have gained %d pot to redeem! (/loyaltyredeem)", amount);
					SendClientMessage(playerid, COLOR_LOYALTY, string);
					
					format(string, sizeof(string), "[LOYALTY] %s has gained %d pot.", GetName(playerid), amount);
					LoyaltyLog(string);
					StatLog(string);
				}
				case 1:
				{
					format(Player[playerid][LoyaltyRewards], 256, "%s%d speed |", Player[playerid][LoyaltyRewards], amount);
					format(string, sizeof(string), "[LOYALTY] You have gained %d speed to redeem! (/loyaltyredeem)", amount);
					SendClientMessage(playerid, COLOR_LOYALTY, string);
					
					format(string, sizeof(string), "[LOYALTY] %s has gained %d speed.", GetName(playerid), amount);
					LoyaltyLog(string);
					StatLog(string);
				}
				case 2:
				{
					format(Player[playerid][LoyaltyRewards], 256, "%s%d cocaine |", Player[playerid][LoyaltyRewards], amount);
					format(string, sizeof(string), "[LOYALTY] You have gained %d cocaine to redeem! (/loyaltyredeem)", amount);
					SendClientMessage(playerid, COLOR_LOYALTY, string);
					
					format(string, sizeof(string), "[LOYALTY] %s has gained %d cocaine.", GetName(playerid), amount);
					LoyaltyLog(string);
					StatLog(string);
				}
			}
		}
		case LOYALTY_SHOP_LARGE_DRUG:
		{
			new amount = floatround(float(LoyaltyDrugMin[2]) * totalMult, floatround_round);
			
			switch(random(3))
			{
				case 0:
				{
					format(Player[playerid][LoyaltyRewards], 256, "%s%d pot |", Player[playerid][LoyaltyRewards], amount);
					format(string, sizeof(string), "[LOYALTY] You have gained %d pot to redeem! (/loyaltyredeem)", amount);
					SendClientMessage(playerid, COLOR_LOYALTY, string);
					
					format(string, sizeof(string), "[LOYALTY] %s has gained %d pot.", GetName(playerid), amount);
					LoyaltyLog(string);
					StatLog(string);
				}
				case 1:
				{
					format(Player[playerid][LoyaltyRewards], 256, "%s%d speed |", Player[playerid][LoyaltyRewards], amount);
					format(string, sizeof(string), "[LOYALTY] You have gained %d speed to redeem! (/loyaltyredeem)", amount);
					SendClientMessage(playerid, COLOR_LOYALTY, string);
					
					format(string, sizeof(string), "[LOYALTY] %s has gained %d speed.", GetName(playerid), amount);
					LoyaltyLog(string);
					StatLog(string);
				}
				case 2:
				{
					format(Player[playerid][LoyaltyRewards], 256, "%s%d cocaine |", Player[playerid][LoyaltyRewards], amount);
					format(string, sizeof(string), "[LOYALTY] You have gained %d cocaine to redeem! (/loyaltyredeem)", amount);
					SendClientMessage(playerid, COLOR_LOYALTY, string);
					
					format(string, sizeof(string), "[LOYALTY] %s has gained %d cocaine.", GetName(playerid), amount);
					LoyaltyLog(string);
					StatLog(string);
				}
			}
		}
	}
	return 1;
}
