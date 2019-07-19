/*
#		MTG Toys/Accessories System
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

#define TOY_TYPE_HATS		0
#define TOY_TYPE_BANDANAS	1
#define TOY_TYPE_GLASSES	2
#define TOY_TYPE_WATCHES	3
#define TOY_TYPE_MISC		4
#define TOY_TYPE_POLICE		5

#define MAX_TOYS			20
// Toy arrays
enum ToyInfo
{
	tName[128],
	ModelID,
	Bone,
	tPrice,
	tVip,
};

stock IsVipToy(toyid)
{
	new query[128];
	mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT * FROM toys WHERE model = '%d'", toyid);
	new Cache:cache = mysql_query(MYSQL_MAIN, query), vip;
	if(cache_get_row_count() > 0)
	{
		vip = cache_get_field_content_int(0, "vip");
	}
	cache_delete(cache);
	if(vip)
		return 1;
	return 0;
}

stock GetToyType(toyid)
{
	new query[128];
	mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT * FROM toys WHERE model = '%d'", toyid);
	new Cache:cache = mysql_query(MYSQL_MAIN, query), count = cache_get_row_count(), type;
	
	if(count > 0)
	{
		type = cache_get_field_content_int(0, "type");
	}
	
	cache_delete(cache);
	
	if(count == 0)
		return -1;
	
	return type;
}

stock GetHighestToySlot(playerid)
{
	switch(Player[playerid][VipRank])
	{
		case 0: return 2;
		case 1: return 3;
		case 2: return 4;
		default: return 5;
	}
	return -1;
}

stock GetToyName(toyid)
{
	new name[128];
	switch(toyid)
	{
		case 19011: format(name, sizeof(name), "Swirly Glasses");
		case 19013: format(name, sizeof(name), "Eye ball Glasses");
		case 19014: format(name, sizeof(name), "Checkered Glasses");
		case 19016: format(name, sizeof(name), "X-Ray Glasses");
		case 19078: format(name, sizeof(name), "Parrot");
		default:
		{
			new query[128];
			mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT * FROM toys WHERE model = '%d'", toyid);
			new Cache:cache = mysql_query(MYSQL_MAIN, query);
			if(cache_get_row_count() > 0)
			{
				cache_get_field_content(0, "name", name);
			}
			cache_delete(cache);
		}
	}
	
	return name;
}
		
stock GetAvailableToySlot(playerid)
{
	new slot = -1;
	for(new i; i < MAX_TOYS; i ++)
	{
		if(PlayerToys[playerid][ToyModelID][i] < 1)
		{
			slot = i;
			break;
		}
	}
	
	/*
	if(slot > GetHighestToySlot(playerid))
		return -1;
	*/
	return slot;
}

stock MoveToyToSlot(playerid, slotfrom, slotto)
{
	PlayerToys[playerid][ToyIndex][slotto] = PlayerToys[playerid][ToyIndex][slotfrom];
	PlayerToys[playerid][ToyModelID][slotto] = PlayerToys[playerid][ToyModelID][slotfrom];
	PlayerToys[playerid][ToyXOffset][slotto] = PlayerToys[playerid][ToyXOffset][slotfrom];
	PlayerToys[playerid][ToyYOffset][slotto] = PlayerToys[playerid][ToyYOffset][slotfrom];
	PlayerToys[playerid][ToyZOffset][slotto] = PlayerToys[playerid][ToyZOffset][slotfrom];
	PlayerToys[playerid][ToyXRot][slotto] = PlayerToys[playerid][ToyXRot][slotfrom];
	PlayerToys[playerid][ToyYRot][slotto] = PlayerToys[playerid][ToyYRot][slotfrom];
	PlayerToys[playerid][ToyZRot][slotto] = PlayerToys[playerid][ToyZRot][slotfrom];
	PlayerToys[playerid][ToyXScale][slotto] = PlayerToys[playerid][ToyXScale][slotfrom];
	PlayerToys[playerid][ToyYScale][slotto] = PlayerToys[playerid][ToyYScale][slotfrom];
	PlayerToys[playerid][ToyZScale][slotto] = PlayerToys[playerid][ToyZScale][slotfrom];
	return 1;
}

stock DeleteToySlot(playerid, slot)
{
	if(PlayerToys[playerid][ToyIndex][slot] != -1)
		RemovePlayerAttachedObject(playerid, PlayerToys[playerid][ToyIndex][slot]);
		
	PlayerToys[playerid][ToyModelID][slot] = -1;
	PlayerToys[playerid][ToyIndex][slot] = -1;
	PlayerToys[playerid][ToyXOffset][slot] = 0;
	PlayerToys[playerid][ToyYOffset][slot] = 0;
	PlayerToys[playerid][ToyZOffset][slot] = 0;
	PlayerToys[playerid][ToyXRot][slot] = 0;
	PlayerToys[playerid][ToyYRot][slot] = 0;
	PlayerToys[playerid][ToyZRot][slot] = 0;
	PlayerToys[playerid][ToyXScale][slot] = 1.0;
	PlayerToys[playerid][ToyYScale][slot] = 1.0;
	PlayerToys[playerid][ToyZScale][slot] = 1.0;
	PlayerToys[playerid][ToyBone][slot] = 0;
	return 1;
}

stock GetToyBone(toyid)
{
	new bone = 0;
	switch(toyid)
	{
		case 19011: bone = 2;
		case 19013: bone = 2;
		case 19014: bone = 2;
		case 19016: bone = 2;
		case 19078: bone = 16;
		default:
		{
			new query[128];
			mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT * FROM toys WHERE model = '%d'", toyid);
			new Cache:cache = mysql_query(MYSQL_MAIN, query);
			if(cache_get_row_count() > 0)
			{
				bone = cache_get_field_content_int(0, "bone");
			}
			cache_delete(cache);
		}
	}
	return bone;
}

stock UpdatePlayerToys(playerid)
{
	for(new i; i < GetHighestToySlot(playerid) + 1; i++)
	{
		if(PlayerToys[playerid][ToyIndex][i] != -1)
		{
			RemovePlayerAttachedObject(playerid, PlayerToys[playerid][ToyIndex][i]);
			
			PlayerToys[playerid][ToyIndex][i] = GetEmptySlotAttachment(playerid);
			
			if(PlayerToys[playerid][ToyIndex][i] == -1)
				break;
				
			SetPlayerAttachedObject(playerid,PlayerToys[playerid][ToyIndex][i],PlayerToys[playerid][ToyModelID][i],PlayerToys[playerid][ToyBone][i],PlayerToys[playerid][ToyXOffset][i],PlayerToys[playerid][ToyYOffset][i],PlayerToys[playerid][ToyZOffset][i],PlayerToys[playerid][ToyXRot][i],PlayerToys[playerid][ToyYRot][i],PlayerToys[playerid][ToyZRot][i],PlayerToys[playerid][ToyXScale][i],PlayerToys[playerid][ToyYScale][i],PlayerToys[playerid][ToyZScale][i]);  
		}
	}
	
	return 1;
}

stock DeleteAndShiftPlayerToy(playerid, slot)
{
	switch(slot)
	{
		case 0:
		{
			DeleteToySlot(playerid, 0);
			MoveToyToSlot(playerid, 1, 0);
			MoveToyToSlot(playerid, 2, 1);
			MoveToyToSlot(playerid, 3, 2);
			MoveToyToSlot(playerid, 4, 3);
			MoveToyToSlot(playerid, 5, 4);
			MoveToyToSlot(playerid, 6, 5);
			MoveToyToSlot(playerid, 7, 6);
			MoveToyToSlot(playerid, 8, 7);
			MoveToyToSlot(playerid, 9, 8);
			MoveToyToSlot(playerid, 10, 9);
			MoveToyToSlot(playerid, 11, 10);
			MoveToyToSlot(playerid, 12, 11);
			MoveToyToSlot(playerid, 13, 12);
			MoveToyToSlot(playerid, 14, 13);
			MoveToyToSlot(playerid, 15, 14);
			MoveToyToSlot(playerid, 16, 15);
			MoveToyToSlot(playerid, 17, 16);
			MoveToyToSlot(playerid, 18, 17);
			MoveToyToSlot(playerid, 19, 18);
			DeleteToySlot(playerid, 19);
		}
		case 1:
		{
			DeleteToySlot(playerid, 1);
			MoveToyToSlot(playerid, 2, 1);
			MoveToyToSlot(playerid, 3, 2);
			MoveToyToSlot(playerid, 4, 3);
			MoveToyToSlot(playerid, 5, 4);
			MoveToyToSlot(playerid, 6, 5);
			MoveToyToSlot(playerid, 7, 6);
			MoveToyToSlot(playerid, 8, 7);
			MoveToyToSlot(playerid, 9, 8);
			MoveToyToSlot(playerid, 10, 9);
			MoveToyToSlot(playerid, 11, 10);
			MoveToyToSlot(playerid, 12, 11);
			MoveToyToSlot(playerid, 13, 12);
			MoveToyToSlot(playerid, 14, 13);
			MoveToyToSlot(playerid, 15, 14);
			MoveToyToSlot(playerid, 16, 15);
			MoveToyToSlot(playerid, 17, 16);
			MoveToyToSlot(playerid, 18, 17);
			MoveToyToSlot(playerid, 19, 18);
			DeleteToySlot(playerid, 19);
		}
		case 2:
		{
			DeleteToySlot(playerid, 2);
			MoveToyToSlot(playerid, 3, 2);
			MoveToyToSlot(playerid, 4, 3);
			MoveToyToSlot(playerid, 5, 4);
			MoveToyToSlot(playerid, 6, 5);
			MoveToyToSlot(playerid, 7, 6);
			MoveToyToSlot(playerid, 8, 7);
			MoveToyToSlot(playerid, 9, 8);
			MoveToyToSlot(playerid, 10, 9);
			MoveToyToSlot(playerid, 11, 10);
			MoveToyToSlot(playerid, 12, 11);
			MoveToyToSlot(playerid, 13, 12);
			MoveToyToSlot(playerid, 14, 13);
			MoveToyToSlot(playerid, 15, 14);
			MoveToyToSlot(playerid, 16, 15);
			MoveToyToSlot(playerid, 17, 16);
			MoveToyToSlot(playerid, 18, 17);
			MoveToyToSlot(playerid, 19, 18);
			DeleteToySlot(playerid, 19);
		}
		case 3:
		{
			DeleteToySlot(playerid, 3);
			MoveToyToSlot(playerid, 4, 3);
			MoveToyToSlot(playerid, 5, 4);
			MoveToyToSlot(playerid, 6, 5);
			MoveToyToSlot(playerid, 7, 6);
			MoveToyToSlot(playerid, 8, 7);
			MoveToyToSlot(playerid, 9, 8);
			MoveToyToSlot(playerid, 10, 9);
			MoveToyToSlot(playerid, 11, 10);
			MoveToyToSlot(playerid, 12, 11);
			MoveToyToSlot(playerid, 13, 12);
			MoveToyToSlot(playerid, 14, 13);
			MoveToyToSlot(playerid, 15, 14);
			MoveToyToSlot(playerid, 16, 15);
			MoveToyToSlot(playerid, 17, 16);
			MoveToyToSlot(playerid, 18, 17);
			MoveToyToSlot(playerid, 19, 18);
			DeleteToySlot(playerid, 19);
		}
		case 4:
		{
			DeleteToySlot(playerid, 4);
			MoveToyToSlot(playerid, 5, 4);
			MoveToyToSlot(playerid, 6, 5);
			MoveToyToSlot(playerid, 7, 6);
			MoveToyToSlot(playerid, 8, 7);
			MoveToyToSlot(playerid, 9, 8);
			MoveToyToSlot(playerid, 10, 9);
			MoveToyToSlot(playerid, 11, 10);
			MoveToyToSlot(playerid, 12, 11);
			MoveToyToSlot(playerid, 13, 12);
			MoveToyToSlot(playerid, 14, 13);
			MoveToyToSlot(playerid, 15, 14);
			MoveToyToSlot(playerid, 16, 15);
			MoveToyToSlot(playerid, 17, 16);
			MoveToyToSlot(playerid, 18, 17);
			MoveToyToSlot(playerid, 19, 18);
			DeleteToySlot(playerid, 19);
		}
		case 5:
		{
			DeleteToySlot(playerid, 5);
			MoveToyToSlot(playerid, 6, 5);
			MoveToyToSlot(playerid, 7, 6);
			MoveToyToSlot(playerid, 8, 7);
			MoveToyToSlot(playerid, 9, 8);
			MoveToyToSlot(playerid, 10, 9);
			MoveToyToSlot(playerid, 11, 10);
			MoveToyToSlot(playerid, 12, 11);
			MoveToyToSlot(playerid, 13, 12);
			MoveToyToSlot(playerid, 14, 13);
			MoveToyToSlot(playerid, 15, 14);
			MoveToyToSlot(playerid, 16, 15);
			MoveToyToSlot(playerid, 17, 16);
			MoveToyToSlot(playerid, 18, 17);
			MoveToyToSlot(playerid, 19, 18);
			DeleteToySlot(playerid, 19);
		}
		case 6:
		{
			DeleteToySlot(playerid, 6);
			MoveToyToSlot(playerid, 7, 6);
			MoveToyToSlot(playerid, 8, 7);
			MoveToyToSlot(playerid, 9, 8);
			MoveToyToSlot(playerid, 10, 9);
			MoveToyToSlot(playerid, 11, 10);
			MoveToyToSlot(playerid, 12, 11);
			MoveToyToSlot(playerid, 13, 12);
			MoveToyToSlot(playerid, 14, 13);
			MoveToyToSlot(playerid, 15, 14);
			MoveToyToSlot(playerid, 16, 15);
			MoveToyToSlot(playerid, 17, 16);
			MoveToyToSlot(playerid, 18, 17);
			MoveToyToSlot(playerid, 19, 18);
			DeleteToySlot(playerid, 19);
		}
		case 7:
		{
			DeleteToySlot(playerid, 7);
			MoveToyToSlot(playerid, 8, 7);
			MoveToyToSlot(playerid, 9, 8);
			MoveToyToSlot(playerid, 10, 9);
			MoveToyToSlot(playerid, 11, 10);
			MoveToyToSlot(playerid, 12, 11);
			MoveToyToSlot(playerid, 13, 12);
			MoveToyToSlot(playerid, 14, 13);
			MoveToyToSlot(playerid, 15, 14);
			MoveToyToSlot(playerid, 16, 15);
			MoveToyToSlot(playerid, 17, 16);
			MoveToyToSlot(playerid, 18, 17);
			MoveToyToSlot(playerid, 19, 18);
			DeleteToySlot(playerid, 19);
		}
		case 8:
		{
			DeleteToySlot(playerid, 8);
			MoveToyToSlot(playerid, 9, 8);
			MoveToyToSlot(playerid, 10, 9);
			MoveToyToSlot(playerid, 11, 10);
			MoveToyToSlot(playerid, 12, 11);
			MoveToyToSlot(playerid, 13, 12);
			MoveToyToSlot(playerid, 14, 13);
			MoveToyToSlot(playerid, 15, 14);
			MoveToyToSlot(playerid, 16, 15);
			MoveToyToSlot(playerid, 17, 16);
			MoveToyToSlot(playerid, 18, 17);
			MoveToyToSlot(playerid, 19, 18);
			DeleteToySlot(playerid, 19);
		}
		case 9:
		{
			DeleteToySlot(playerid, 9);
			MoveToyToSlot(playerid, 10, 9);
			MoveToyToSlot(playerid, 11, 10);
			MoveToyToSlot(playerid, 12, 11);
			MoveToyToSlot(playerid, 13, 12);
			MoveToyToSlot(playerid, 14, 13);
			MoveToyToSlot(playerid, 15, 14);
			MoveToyToSlot(playerid, 16, 15);
			MoveToyToSlot(playerid, 17, 16);
			MoveToyToSlot(playerid, 18, 17);
			MoveToyToSlot(playerid, 19, 18);
			DeleteToySlot(playerid, 19);
		}
		case 10:
		{
			DeleteToySlot(playerid, 10);
			MoveToyToSlot(playerid, 11, 10);
			MoveToyToSlot(playerid, 12, 11);
			MoveToyToSlot(playerid, 13, 12);
			MoveToyToSlot(playerid, 14, 13);
			MoveToyToSlot(playerid, 15, 14);
			MoveToyToSlot(playerid, 16, 15);
			MoveToyToSlot(playerid, 17, 16);
			MoveToyToSlot(playerid, 18, 17);
			MoveToyToSlot(playerid, 19, 18);
			DeleteToySlot(playerid, 19);
		}
		case 11:
		{
			DeleteToySlot(playerid, 11);
			MoveToyToSlot(playerid, 12, 11);
			MoveToyToSlot(playerid, 13, 12);
			MoveToyToSlot(playerid, 14, 13);
			MoveToyToSlot(playerid, 15, 14);
			MoveToyToSlot(playerid, 16, 15);
			MoveToyToSlot(playerid, 17, 16);
			MoveToyToSlot(playerid, 18, 17);
			MoveToyToSlot(playerid, 19, 18);
			DeleteToySlot(playerid, 19);
		}
		case 12:
		{
			DeleteToySlot(playerid, 12);
			MoveToyToSlot(playerid, 13, 12);
			MoveToyToSlot(playerid, 14, 13);
			MoveToyToSlot(playerid, 15, 14);
			MoveToyToSlot(playerid, 16, 15);
			MoveToyToSlot(playerid, 17, 16);
			MoveToyToSlot(playerid, 18, 17);
			MoveToyToSlot(playerid, 19, 18);
			DeleteToySlot(playerid, 19);
		}
		case 13:
		{
			DeleteToySlot(playerid, 13);
			MoveToyToSlot(playerid, 14, 13);
			MoveToyToSlot(playerid, 15, 14);
			MoveToyToSlot(playerid, 16, 15);
			MoveToyToSlot(playerid, 17, 16);
			MoveToyToSlot(playerid, 18, 17);
			MoveToyToSlot(playerid, 19, 18);
			DeleteToySlot(playerid, 19);
		}
		case 14:
		{
			DeleteToySlot(playerid, 14);
			MoveToyToSlot(playerid, 15, 14);
			MoveToyToSlot(playerid, 16, 15);
			MoveToyToSlot(playerid, 17, 16);
			MoveToyToSlot(playerid, 18, 17);
			MoveToyToSlot(playerid, 19, 18);
			DeleteToySlot(playerid, 19);
		}
		case 15:
		{
			DeleteToySlot(playerid, 15);
			MoveToyToSlot(playerid, 16, 15);
			MoveToyToSlot(playerid, 17, 16);
			MoveToyToSlot(playerid, 18, 17);
			MoveToyToSlot(playerid, 19, 18);
			DeleteToySlot(playerid, 19);
		}
		case 16:
		{
			DeleteToySlot(playerid, 16);
			MoveToyToSlot(playerid, 17, 16);
			MoveToyToSlot(playerid, 18, 17);
			MoveToyToSlot(playerid, 19, 18);
			DeleteToySlot(playerid, 19);
		}
		case 17:
		{
			DeleteToySlot(playerid, 17);
			MoveToyToSlot(playerid, 18, 17);
			MoveToyToSlot(playerid, 19, 18);
			DeleteToySlot(playerid, 19);
		}
		case 18:
		{
			DeleteToySlot(playerid, 18);
			MoveToyToSlot(playerid, 19, 18);
			DeleteToySlot(playerid, 19);
		}
		default: DeleteToySlot(playerid, 19);
	}
	SaveAllPlayerToys(playerid);
	return 1;
}
CMD:toyban(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 2)
		return 1;
		
	new id;
	if(sscanf(params, "u", id))
		return SendClientMessage(playerid, -1, "SYNTAX: /toyban [playerid]");
		
	new string[128];
	
	switch(Player[id][ToyBanned])
	{
		case 0:
		{
			format(string, sizeof(string), "You have banned %s from toys.", GetName(id));
			SendClientMessage(playerid, -1, string);
			format(string, sizeof(string), "%s has banned %s from toys.", GetName(playerid), GetName(id));
			AdminActionsLog(string);
			
			Player[id][ToyBanned] = 1;
			SendClientMessage(id, COLOR_RED, "You have been banned from toys by an admin.");
			
			for(new i; i < MAX_TOYS; i++)
			{
				if(PlayerToys[id][ToyIndex][i] != -1)
				{
					RemovePlayerAttachedObject(id, PlayerToys[playerid][ToyIndex][i]);
					PlayerToys[id][ToyIndex][i] = -1;
				}
			}
		}
		case 1:
		{
			format(string, sizeof(string), "You have unbanned %s from toys.", GetName(id));
			SendClientMessage(playerid, -1, string);
			format(string, sizeof(string), "%s has unbanned %s from toys.", GetName(playerid), GetName(id));
			AdminActionsLog(string);
			
			Player[id][ToyBanned] = 0;
			SendClientMessage(id, COLOR_GREEN, "You have been unbanned from toys by an admin.");
		}
	}
	return 1;
}

CMD:remotetoyban(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 2)
		return 1;
		
	new name[MAX_PLAYER_NAME];
	if(sscanf(params, "s[24]", name))
		return SendClientMessage(playerid, -1, "SYNTAX: /remotetoyban [name]");
		
	new string[128];
	
	if(!IsPlayerRegistered(name))
		return SendClientMessage(playerid, WHITE, "That player doesn't exist.");
	
	switch(GetRemoteIntValue(name, "ToyBanned"))
	{
		case 0:
		{
			mysql_format(MYSQL_MAIN, string, sizeof(string), "UPDATE playeraccounts SET ToyBanned = '1' WHERE NormalName = '%e", name);
			mysql_query(MYSQL_MAIN, string, false);
			
			format(string, sizeof(string), "You have banned %s from toys.", name);
			SendClientMessage(playerid, -1, string);
			format(string, sizeof(string), "%s has banned %s from toys.", GetName(playerid), name);
			AdminActionsLog(string);
		}
		case 1:
		{
			mysql_format(MYSQL_MAIN, string, sizeof(string), "UPDATE playeraccounts SET ToyBanned = '0' WHERE NormalName = '%e", name);
			mysql_query(MYSQL_MAIN, string, false);
			
			format(string, sizeof(string), "You have unbanned %s from toys.", name);
			SendClientMessage(playerid, -1, string);
			format(string, sizeof(string), "%s has unbanned %s from toys.", GetName(playerid), name);
			AdminActionsLog(string);
		}
	}
	return 1;
}

CMD:buytoys(playerid, params[])
{
	if(!IsPlayerInRangeOfPoint(playerid, 1.5, Businesses[Player[playerid][InBusiness]][bInteractX], Businesses[Player[playerid][InBusiness]][bInteractY], Businesses[Player[playerid][InBusiness]][bInteractZ]) && Player[playerid][InBusiness] != 0)
		return SendClientMessage(playerid, GREY, "You must stand near the interaction point to do this.");
		
	if(Businesses[Player[playerid][InBusiness]][bType] != 2)
		return SendClientMessage(playerid, -1, "You are not in a clothing store!");
	if(Player[playerid][ToyBanned] == 1)
		return SendClientMessage(playerid, COLOR_RED, "You are banned from toys!");
	if(Player[playerid][PlayingHours] < 10)
		return SendClientMessage(playerid, -1, "You need at least 10 playing hours to buy toys!");
	if(Businesses[Player[playerid][InBusiness]][bSupplies] < 10)
		return SendClientMessage(playerid, WHITE, "This store is out of supplies!");
		
	ShowPlayerDialog(playerid, BUY_TOYS, DIALOG_STYLE_LIST, "Choose a style.", "Hats\nBandanas\nGlasses\nWatches\nMisc", "Select", "Cancel");
	return 1;
}

CMD:unequiptoy(playerid, params[])
{
	if(!strcmp(params, "all", true))
	{
		for(new slot; slot < GetHighestToySlot(playerid) + 1 && Player[playerid][ToyCount] > 0; slot++)
		{
			if(PlayerToys[playerid][ToyModelID][slot] != -1)
			{	
				if(PlayerToys[playerid][ToyIndex][slot] == -1)
					continue;
	
				RemovePlayerAttachedObject(playerid, PlayerToys[playerid][ToyIndex][slot]);
				PlayerToys[playerid][ToyIndex][slot] = -1;
				SendClientMessage(playerid, -1, "You have detached your toy.");
				Player[playerid][ToyCount]--;
			}
		}
		SendClientMessage(playerid, -1, "You have deattached your first 6 toys.");
	}
	else
	{	
		new slot = strval(params);
		
		if(slot < 1 || slot > 20)
			return SendClientMessage(playerid, WHITE, "SYNTAX: /equiptoy [all/1-20]");
			
		slot --;	
		if(PlayerToys[playerid][ToyModelID][slot] != -1)
		{				
			if(PlayerToys[playerid][ToyIndex][slot] == -1)
				return SendClientMessage(playerid, WHITE, "You already have this toy deattached.");
			
			RemovePlayerAttachedObject(playerid, PlayerToys[playerid][ToyIndex][slot]);
			PlayerToys[playerid][ToyIndex][slot] = -1;
			SendClientMessage(playerid, -1, "You have detached your toy.");
			Player[playerid][ToyCount]--;
		}
		else return SendClientMessage(playerid, WHITE, "You don't have a toy in this slot.");
	}
	return 1;
}

CMD:equiptoy(playerid, params[])
{
	if(Player[playerid][ToyBanned] == 1)
		return SendClientMessage(playerid, COLOR_RED, "You are banned from toys!");
		
	if(Player[playerid][PrisonID] > 1)
		return SendClientMessage(playerid, WHITE, "Your toys will be given back to you upon your release.");
		
	if(!strcmp(params, "all", true))
	{
		for(new slot; slot < GetHighestToySlot(playerid) + 1; slot++)
		{
			new idx = GetEmptySlotAttachment(playerid);
			if(PlayerToys[playerid][ToyModelID][slot] != -1)
			{	
				if(idx == -1)
					continue;
				
				if(GetToyType(PlayerToys[playerid][ToyModelID][slot]) == TOY_TYPE_POLICE && Groups[Player[playerid][Group]][CommandTypes] != 1)
					continue;
					
				PlayerToys[playerid][ToyBone][slot] = GetToyBone(PlayerToys[playerid][ToyModelID][slot]);
				
				if(PlayerToys[playerid][ToyBone][slot] == 0)
				{
					continue;
				}
				
				if(PlayerToys[playerid][ToyIndex][slot] != -1)
					continue;
				
				PlayerToys[playerid][ToyIndex][slot] = idx;
				SetPlayerAttachedObject(playerid,idx,PlayerToys[playerid][ToyModelID][slot],PlayerToys[playerid][ToyBone][slot],PlayerToys[playerid][ToyXOffset][slot],PlayerToys[playerid][ToyYOffset][slot],PlayerToys[playerid][ToyZOffset][slot],PlayerToys[playerid][ToyXRot][slot],PlayerToys[playerid][ToyYRot][slot],PlayerToys[playerid][ToyZRot][slot],PlayerToys[playerid][ToyXScale][slot],PlayerToys[playerid][ToyYScale][slot],PlayerToys[playerid][ToyZScale][slot]);  
				Player[playerid][ToyCount] ++;
			}
		}
		SendClientMessage(playerid, -1, "You have attached your first 6 toys (if any are missing it may be due to invalid slots on your body or unable to equip).");
		SendClientMessage(playerid, -1, "Toys which are held in your hands are not equipped.");
	}
	else
	{	
		new idx = GetEmptySlotAttachment(playerid), slot = strval(params);
		
		if(slot < 1 || slot > 20)
			return SendClientMessage(playerid, WHITE, "SYNTAX: /equiptoy [all/1-20]");
			
		slot --;
		
		if(Player[playerid][ToyCount] == GetHighestToySlot(playerid) + 1)
				return SendClientMessage(playerid, -1, "You can't equip any more toys!");
			
		if(PlayerToys[playerid][ToyModelID][slot] != -1)
		{	
			if(idx == -1)
				return SendClientMessage(playerid, WHITE, "You can't wear this as you have no more slots to equip toys to.");
			
			if(GetToyType(PlayerToys[playerid][ToyModelID][slot]) == TOY_TYPE_POLICE && Groups[Player[playerid][Group]][CommandTypes] != 1)
				return SendClientMessage(playerid, WHITE, "You can't wear this as you are not an LEO.");
			
			if(PlayerToys[playerid][ToyIndex][slot] != -1)
				return SendClientMessage(playerid, WHITE, "You already have this toy attached.");
			
			PlayerToys[playerid][ToyBone][slot] = GetToyBone(PlayerToys[playerid][ToyModelID][slot]);
			
			if(PlayerToys[playerid][ToyBone][slot] == 0)
			{
				SetPVarInt(playerid, "ToySlot", slot);
				return ShowPlayerDialog(playerid, PLAYER_TOYS+2, DIALOG_STYLE_LIST, "Which hand would you like to attach this toy to?", "Left\nRight", "Select", "Cancel");
			}
			
			PlayerToys[playerid][ToyIndex][slot] = idx;
			SetPlayerAttachedObject(playerid,idx,PlayerToys[playerid][ToyModelID][slot],PlayerToys[playerid][ToyBone][slot],PlayerToys[playerid][ToyXOffset][slot],PlayerToys[playerid][ToyYOffset][slot],PlayerToys[playerid][ToyZOffset][slot],PlayerToys[playerid][ToyXRot][slot],PlayerToys[playerid][ToyYRot][slot],PlayerToys[playerid][ToyZRot][slot],PlayerToys[playerid][ToyXScale][slot],PlayerToys[playerid][ToyYScale][slot],PlayerToys[playerid][ToyZScale][slot]);  
			SendClientMessage(playerid, -1, "You have attached your toy.");
			Player[playerid][ToyCount]++;
		}
		else return SendClientMessage(playerid, WHITE, "You don't have a toy in this slot.");
	}
	return 1;
}

CMD:toys(playerid, params[])
{
	if(Player[playerid][ToyBanned] == 1)
		return SendClientMessage(playerid, COLOR_RED, "You are banned from toys!");
	
	if(Player[playerid][PrisonID] > 1)
		return SendClientMessage(playerid, WHITE, "Your toys will be given back to you upon your release.");
		
	new string[1000];
	for(new i; i <  MAX_TOYS; i++)
	{
		if(PlayerToys[playerid][ToyModelID][i] != -1 && strlen(GetToyName(PlayerToys[playerid][ToyModelID][i])) > 0 )
		{
			format(string, sizeof(string), "%s%d | %s%s\n", string, i + 1, (PlayerToys[playerid][ToyIndex][i] == -1) ? ("{FF0000}") : ("{33A10B}"), GetToyName(PlayerToys[playerid][ToyModelID][i]));
		}
	}
	
	if(strlen(string) < 1)
		format(string, sizeof(string), "You don't have any toys!");
	
	ShowPlayerDialog(playerid, PLAYER_TOYS, DIALOG_STYLE_LIST, "Toy Menu", string, "Select", "Cancel");
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	//% exploit fix
	for(new i = 0, j = strlen(inputtext); i != j; i++)
	{
		if(inputtext[i] == '%')
			inputtext[i] = ' ';
	}
	
	switch(dialogid)
	{
		case BUY_TOYS:
		{
			if(!response)
				return 1;
			
			new query[128];
			mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT * FROM toys WHERE type = '%d'", listitem);
			new Cache:cache = mysql_query(MYSQL_MAIN, query), count = cache_get_row_count(), idx;
			
			if(count == 0)
			{
				cache_delete(cache);
				return SendClientMessage(playerid, GREY, "There seems to be no toys of that type!");
			}
			
			SetPVarInt(playerid, "ToyList", listitem + 1);
			new name[128], string[350];
			while(idx < count)
			{
				cache_set_active(cache);
			
				cache_get_field_content(idx, "name", name);
				format(string, sizeof(string), "%s%s%s ($%d)\n", string, (cache_get_field_content_int(idx, "vip")) ? ("{F7DD31}") : ("{FFFFFF}"), name, cache_get_field_content_int(idx, "price"));
				
				idx++;
				
				if(idx == 10)
				{
					format(string, sizeof(string), "%s\nNext Page", string);
					SetPVarInt(playerid, "PLAYER_TOY_PAGE_SQL", cache_get_field_content_int(idx-1, "sqlid"));
					break;
				}
				
			}
			cache_delete(cache);
			ShowPlayerDialog(playerid, LIST_TOYS, DIALOG_STYLE_LIST, "Toys", string, "Purchase", "Cancel");
		}
		case LIST_TOYS:
		{
			if(!response)
				return 1;
			
			if(!strcmp(inputtext, "Next Page", true))
			{
				new query[128];
				mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT * FROM toys WHERE type = '%d' AND sqlid > '%d'", GetPVarInt(playerid, "ToyList") - 1, GetPVarInt(playerid, "PLAYER_TOY_PAGE_SQL"));
				new Cache:cache = mysql_query(MYSQL_MAIN, query), count = cache_get_row_count(), idx;
				
				if(count == 0)
				{
					cache_delete(cache);
					return SendClientMessage(playerid, GREY, "There seems to be no toys of that type!");
				}

				new name[128], string[350];
				while(idx < count)
				{
					cache_set_active(cache);
				
					cache_get_field_content(idx, "name", name);
					format(string, sizeof(string), "%s%s%s ($%d)\n", string, (cache_get_field_content_int(idx, "vip")) ? ("{F7DD31}") : ("{FFFFFF}"), name, cache_get_field_content_int(idx, "price"));
					
					idx++;
					
					if(idx == 10)
					{
						format(string, sizeof(string), "%s\nNext Page", string);
						SetPVarInt(playerid, "PLAYER_TOY_PAGE_SQL", cache_get_field_content_int(idx-1, "sqlid"));
						break;
					}
					
				}
				cache_delete(cache);
				ShowPlayerDialog(playerid, LIST_TOYS, DIALOG_STYLE_LIST, "Toys", string, "Purchase", "Cancel");
				return 1;
			}
			
			new choice[32], string[128], query[128], type = GetPVarInt(playerid, "ToyList") - 1;
			
			if(type != TOY_TYPE_POLICE)
				format(choice, sizeof(choice), "%s", CutBeforePara(inputtext));
			else strcat(choice, inputtext);
			
			mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT * FROM toys WHERE type = '%d' AND name = '%e'", type, choice);
			new Cache:cache = mysql_query(MYSQL_MAIN, query);
			
			new name[128], price = cache_get_field_content_int(0, "price"), vip = cache_get_field_content_int(0, "vip"), model = cache_get_field_content_int(0, "model");
			cache_get_field_content(0, "name", name);
			cache_delete(cache);
			
			new slot = GetAvailableToySlot(playerid);
			
			if(slot == -1)
				return SendClientMessage(playerid, -1, "You don't have any available toy slots!");
			if(type != TOY_TYPE_POLICE)
			{
				if(Player[playerid][Money] < price)
					return SendClientMessage(playerid, -1, "You can't afford that!");

				if(vip && Player[playerid][VipRank] == 0)
					return SendClientMessage(playerid, -1, "You need VIP to use the toy.");
					
				Player[playerid][Money] -= price;
//				Businesses[Player[playerid][InBusiness]][bVault] += price;
				AddToStorage(Player[playerid][InBusiness], CONTAINER_TYPE_BIZ, ITEM_TYPE_CASH, price);
				Businesses[Player[playerid][InBusiness]][bSupplies] -= 10;
				PlayerToys[playerid][ToyModelID][slot] = model;
				PlayerToys[playerid][ToyXScale][slot] = 1.0;
				PlayerToys[playerid][ToyYScale][slot] = 1.0;
				PlayerToys[playerid][ToyZScale][slot] = 1.0;
				format(string, sizeof(string), "You have purchased %s for %s.", name, PrettyMoney(price));
				
				SavePlayerToy(playerid, slot);
				SendClientMessage(playerid, WHITE, string);
			}
			else
			{
				PlayerToys[playerid][ToyModelID][slot] = model;
				PlayerToys[playerid][ToyXScale][slot] = 1.0;
				PlayerToys[playerid][ToyYScale][slot] = 1.0;
				PlayerToys[playerid][ToyZScale][slot] = 1.0;
				SavePlayerToy(playerid, slot);
				format(string, sizeof(string), "You grab the %s.", name);
				SendClientMessage(playerid, WHITE, string);
			}
		}
		case PLAYER_TOYS:
		{
			if(!response)
				return 1;
			
			if(!strcmp(inputtext, "You don't have any toys!", true))
				return 1;
			
			new slot = strval(CutBeforeLine(inputtext));
			slot -= 1;
			
			new string[128];
			format(string, sizeof(string), "%s\nEdit\nDelete", (PlayerToys[playerid][ToyIndex][slot] == -1) ? ("Attach") : ("Detach"));
			
			SetPVarInt(playerid, "ToySlot", slot);
			ShowPlayerDialog(playerid, PLAYER_TOYS+1, DIALOG_STYLE_LIST, "What would you like to do with this toy?", string, "Okay", "Cancel");
		}		
		case PLAYER_TOYS+1:
		{
			if(!response)
				return 1;
				
			new slot = GetPVarInt(playerid, "ToySlot"), idx = GetEmptySlotAttachment(playerid);
			DeletePVar(playerid, "ToySlot");
			
				
			switch(listitem)
			{
				case 0:
				{
					if(PlayerToys[playerid][ToyIndex][slot] == -1)
					{	
						if(idx == -1)
							return SendClientMessage(playerid, -1, "You don't have any more slots for an attachment!");
							
						if(Player[playerid][ToyCount] == GetHighestToySlot(playerid) + 1)
							return SendClientMessage(playerid, -1, "You can't equip any more toys!");
						
						if(GetToyType(PlayerToys[playerid][ToyModelID][slot]) == TOY_TYPE_POLICE && Groups[Player[playerid][Group]][CommandTypes] != 1)
							return SendClientMessage(playerid, -1, "You must be an LEO to use this toy.");
							
						PlayerToys[playerid][ToyBone][slot] = GetToyBone(PlayerToys[playerid][ToyModelID][slot]);
						
						if(PlayerToys[playerid][ToyBone][slot] == 0)
						{
							SetPVarInt(playerid, "ToySlot", slot);
							return ShowPlayerDialog(playerid, PLAYER_TOYS+2, DIALOG_STYLE_LIST, "Which hand would you like to attach this toy to?", "Left\nRight", "Select", "Cancel");
						}
						
						PlayerToys[playerid][ToyIndex][slot] = idx;
						SetPlayerAttachedObject(playerid,idx,PlayerToys[playerid][ToyModelID][slot],PlayerToys[playerid][ToyBone][slot],PlayerToys[playerid][ToyXOffset][slot],PlayerToys[playerid][ToyYOffset][slot],PlayerToys[playerid][ToyZOffset][slot],PlayerToys[playerid][ToyXRot][slot],PlayerToys[playerid][ToyYRot][slot],PlayerToys[playerid][ToyZRot][slot],PlayerToys[playerid][ToyXScale][slot],PlayerToys[playerid][ToyYScale][slot],PlayerToys[playerid][ToyZScale][slot]);  
						SendClientMessage(playerid, -1, "You have attached your toy.");
						Player[playerid][ToyCount]++;
					}
					else
					{
						RemovePlayerAttachedObject(playerid, PlayerToys[playerid][ToyIndex][slot]);
						PlayerToys[playerid][ToyIndex][slot] = -1;
						SendClientMessage(playerid, -1, "You have detached your toy.");
						Player[playerid][ToyCount]--;
					}
				}
				case 1:
				{
					if(PlayerToys[playerid][ToyIndex][slot] == -1)
						return SendClientMessage(playerid, -1, "The toy must be attached for you to edit it.");
					SetPVarInt(playerid, "EditingToy", 1);
					EditAttachedObject(playerid, PlayerToys[playerid][ToyIndex][slot]);
				}
				case 2:
				{
					DeleteAndShiftPlayerToy(playerid, slot);
				}
			}
		}
		case PLAYER_TOYS+2:
		{
			if(!response)
				return 1;
			
			new slot = GetPVarInt(playerid, "ToySlot"), idx = GetEmptySlotAttachment(playerid);
			
			if(idx == -1)
				return SendClientMessage(playerid, -1, "You don't have any more slots for an attachment!");
			
			switch(listitem)
			{
				case 0: 
				{
					PlayerToys[playerid][ToyBone][slot] = 5;
					PlayerToys[playerid][ToyIndex][slot] = idx;
					SetPlayerAttachedObject(playerid,idx,PlayerToys[playerid][ToyModelID][slot],PlayerToys[playerid][ToyBone][slot],PlayerToys[playerid][ToyXOffset][slot],PlayerToys[playerid][ToyYOffset][slot],PlayerToys[playerid][ToyZOffset][slot],PlayerToys[playerid][ToyXRot][slot],PlayerToys[playerid][ToyYRot][slot],PlayerToys[playerid][ToyZRot][slot],PlayerToys[playerid][ToyXScale][slot],PlayerToys[playerid][ToyYScale][slot],PlayerToys[playerid][ToyZScale][slot]);    
					DeletePVar(playerid, "ToySlot");
					SendClientMessage(playerid, -1, "You have attached your toy to your left hand.");
				}
				default:
				{
					PlayerToys[playerid][ToyBone][slot] = 6;
					PlayerToys[playerid][ToyIndex][slot] = idx;
					SetPlayerAttachedObject(playerid,idx,PlayerToys[playerid][ToyModelID][slot],PlayerToys[playerid][ToyBone][slot],PlayerToys[playerid][ToyXOffset][slot],PlayerToys[playerid][ToyYOffset][slot],PlayerToys[playerid][ToyZOffset][slot],PlayerToys[playerid][ToyXRot][slot],PlayerToys[playerid][ToyYRot][slot],PlayerToys[playerid][ToyZRot][slot],PlayerToys[playerid][ToyXScale][slot],PlayerToys[playerid][ToyYScale][slot],PlayerToys[playerid][ToyZScale][slot]);    
					DeletePVar(playerid, "ToySlot");
					SendClientMessage(playerid, -1, "You have attached your toy to your right hand.");
				}
			}
			Player[playerid][ToyCount]++;
		}
		case GIVE_TOY:
		{
			if(!response)
				return 1;
			
			new id, pslot, str[128];
			
			if(!IsPlayerConnected(GetPVarInt(playerid, "GIVE_TOY")))
			{
				DeletePVar(playerid, "GIVE_TOY");
				return SendClientMessage(playerid, -1, "The player you are trying to give a toy to is no longer connected.");
			}
			else
			{
				id = GetPVarInt(playerid, "GIVE_TOY");
				DeletePVar(playerid, "GIVE_TOY");
			}
					
			pslot = listitem;			
				
			if(PlayerToys[playerid][ToyIndex][pslot] != -1)
				return SendClientMessage(playerid, WHITE, "You cannot give a toy that you have equipped.");
						
			if(IsVipToy(PlayerToys[playerid][ToyModelID][pslot]) && Player[id][VipRank] < 1)
				return SendClientMessage(playerid, -1, "You cannot give VIP toys to non-VIPs.");
								
			if(GetToyType(PlayerToys[playerid][ToyModelID][pslot]) == TOY_TYPE_POLICE && Groups[Player[id][Group]][CommandTypes] != 1)
				return SendClientMessage(playerid, -1, "You cannot give an LSPD toy to somebody who isn't in the LSPD.");
							
			new slot = GetAvailableToySlot(id);
			if(slot == -1)
				return SendClientMessage(playerid, -1, "This player does not have any toy slots available.");
			
			format(str, sizeof(str), "You have given a toy (%s) to %s.", GetToyName(PlayerToys[playerid][ToyModelID][pslot]), GetNameEx(id));
			SendClientMessage(playerid, -1, str);
			format(str, sizeof(str), "You have been given a toy (%s) by %s.", GetToyName(PlayerToys[playerid][ToyModelID][pslot]), GetNameEx(playerid));
			SendClientMessage(id, -1, str);
			format(str, sizeof(str), "* %s has given a toy to %s", GetNameEx(playerid), GetNameEx(id));
			NearByMessage(playerid, NICESKY, str);
			format(str, sizeof(str), "[TOY] %s has given toy %d to %s", GetNameEx(playerid), PlayerToys[playerid][ToyModelID][pslot], GetNameEx(id));
			CommandsLog(str);
			
			PlayerToys[id][ToyModelID][slot] = PlayerToys[playerid][ToyModelID][pslot];
			PlayerToys[id][ToyXOffset][slot] = PlayerToys[playerid][ToyXOffset][pslot];
			PlayerToys[id][ToyYOffset][slot] = PlayerToys[playerid][ToyYOffset][pslot];
			PlayerToys[id][ToyZOffset][slot] = PlayerToys[playerid][ToyZOffset][pslot];
			PlayerToys[id][ToyXRot][slot] = PlayerToys[playerid][ToyXRot][pslot];
			PlayerToys[id][ToyYRot][slot] = PlayerToys[playerid][ToyYRot][pslot];
			PlayerToys[id][ToyZRot][slot] = PlayerToys[playerid][ToyZRot][pslot];
			PlayerToys[id][ToyXScale][slot] = PlayerToys[playerid][ToyXScale][pslot];
			PlayerToys[id][ToyYScale][slot] = PlayerToys[playerid][ToyYScale][pslot];
			PlayerToys[id][ToyZScale][slot] = PlayerToys[playerid][ToyZScale][pslot];
			
			DeleteAndShiftPlayerToy(playerid, pslot);
			
			SavePlayerToy(playerid, pslot);
			SavePlayerToy(id, slot);
		}
	}
	return 1;
}

hook OnPlayerEditAttachedObject(playerid, response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ)
{
	if(GetPVarInt(playerid, "WepEditSlot") < 1)
	{
		new slot = -1;
		for(new i; i < MAX_TOYS; i++)
		{
			if(PlayerToys[playerid][ToyIndex][i] == index)
			{
				slot = i;
				break;
			}
		}
			
		if(slot == -1)
			return SendClientMessage(playerid, -1, "An unexpected error occured while editing your toy.");
		
		if(response)
		{
			if(fOffsetX > 0.7 || fOffsetY > 0.7 || fOffsetZ > 0.7)
			{
				SetPlayerAttachedObject(playerid,index,PlayerToys[playerid][ToyModelID][slot],PlayerToys[playerid][ToyBone][slot],PlayerToys[playerid][ToyXOffset][slot],PlayerToys[playerid][ToyYOffset][slot],PlayerToys[playerid][ToyZOffset][slot],PlayerToys[playerid][ToyXRot][slot],PlayerToys[playerid][ToyYRot][slot],PlayerToys[playerid][ToyZRot][slot],PlayerToys[playerid][ToyXScale][slot],PlayerToys[playerid][ToyYScale][slot],PlayerToys[playerid][ToyZScale][slot]);  
				SendClientMessage(playerid, -1, "You have moved the object to far from the original position!");
				return 1;
			}
			
			if(fScaleX > 1.5 || fScaleY > 1.5 || fScaleZ > 1.5)
			{
				SetPlayerAttachedObject(playerid,index,PlayerToys[playerid][ToyModelID][slot],PlayerToys[playerid][ToyBone][slot],PlayerToys[playerid][ToyXOffset][slot],PlayerToys[playerid][ToyYOffset][slot],PlayerToys[playerid][ToyZOffset][slot],PlayerToys[playerid][ToyXRot][slot],PlayerToys[playerid][ToyYRot][slot],PlayerToys[playerid][ToyZRot][slot],PlayerToys[playerid][ToyXScale][slot],PlayerToys[playerid][ToyYScale][slot],PlayerToys[playerid][ToyZScale][slot]);  
				SendClientMessage(playerid, -1, "You have scaled the object further than allowed!");
				return 1;
			}
			
			PlayerToys[playerid][ToyXOffset][slot] = fOffsetX;
			PlayerToys[playerid][ToyYOffset][slot] = fOffsetY;
			PlayerToys[playerid][ToyZOffset][slot] = fOffsetZ;
			PlayerToys[playerid][ToyXRot][slot] = fRotX;
			PlayerToys[playerid][ToyYRot][slot] = fRotY;
			PlayerToys[playerid][ToyZRot][slot] = fRotZ;
			PlayerToys[playerid][ToyXScale][slot] = fScaleX;
			PlayerToys[playerid][ToyYScale][slot] = fScaleY;
			PlayerToys[playerid][ToyZScale][slot] = fScaleZ;
			SavePlayerToy(playerid, slot);
			SendClientMessage(playerid, -1, "You have successfully edited your toy and saved the changes.");
		}
		else
		{
			SetPlayerAttachedObject(playerid,index,PlayerToys[playerid][ToyModelID][slot],PlayerToys[playerid][ToyBone][slot],PlayerToys[playerid][ToyXOffset][slot],PlayerToys[playerid][ToyYOffset][slot],PlayerToys[playerid][ToyZOffset][slot],PlayerToys[playerid][ToyXRot][slot],PlayerToys[playerid][ToyYRot][slot],PlayerToys[playerid][ToyZRot][slot],PlayerToys[playerid][ToyXScale][slot],PlayerToys[playerid][ToyYScale][slot],PlayerToys[playerid][ToyZScale][slot]);  
			SendClientMessage(playerid, -1, "The changes to your toy were not saved.");
		}
	}
	return 1;
}

CMD:givetoy(playerid, params[])
{
	new id;
	if(sscanf(params, "u", id))
		return SendClientMessage(playerid, -1, "SYNTAX: /givetoy [playerid]");
		
	if(Player[playerid][PlayingHours] < 20)
		return SendClientMessage(playerid, -1, "You need at least 20 playing hours to give toys.");
		
	new slot = GetAvailableToySlot(id);
	if(slot == -1)
		return SendClientMessage(playerid, -1, "This player does not have any toy slots available.");
		
	if(Player[id][PlayingHours] < 20)
		return SendClientMessage(playerid, -1, "This player needs at least 20 playing hours to receive toys.");
	
	if(Player[id][ToyBanned] == 1)
		return SendClientMessage(playerid, -1, "This player is banned from using toys.");
		
	new string[1000];
	SetPVarInt(playerid, "GIVE_TOY", id);
	
	for(new i; i < MAX_TOYS; i++)
	{
		if(PlayerToys[playerid][ToyModelID][i] != -1 && strlen(GetToyName(PlayerToys[playerid][ToyModelID][i])) > 0)
		{
			format(string, sizeof(string), "%s%d | %s%s\n", string, i + 1, (PlayerToys[playerid][ToyIndex][i] == -1) ? ("{FF0000}") : ("{33A10B}"), GetToyName(PlayerToys[playerid][ToyModelID][i]));
		}
	}
	
	if(strlen(string) < 1)
		format(string, sizeof(string), "You don't have any toys!");
	
	ShowPlayerDialog(playerid, GIVE_TOY, DIALOG_STYLE_LIST, "What toy would you like to give?", string, "Select", "Cancel");
	
	return 1;
}

stock ConvertPlayerToys()
{
	printf("***** STARTING MIGRATION OF TOY DATABASE *****");

	new query[255];
	mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT * FROM playertoys");
	new Cache:cache = mysql_query(MYSQL_MAIN, query);
	
	new rows = cache_get_row_count(), current_row = 0;
	
	while(current_row < rows)
	{
		new Float:X, Float:Y, Float:Z, Float:RotX, Float:RotY, Float:RotZ, Float:ScaleX, Float:ScaleY, Float:ScaleZ, Toy_ModelID, BoneNum, PlayerSQL;
		
		PlayerSQL = cache_get_field_content_int(current_row, "PlayerSQLID");
		
		for(new i; i < MAX_TOYS; i++)
		{
			new field[24];
			
			format(field, sizeof(field), "ToyModelID%d", i);
			Toy_ModelID = cache_get_field_content_int(current_row, field);
			
			format(field, sizeof(field), "ToyXOffset%d", i);
			X = cache_get_field_content_float(current_row, field);
			
			format(field, sizeof(field), "ToyYOffset%d", i);
			Y = cache_get_field_content_float(current_row, field);
			
			format(field, sizeof(field), "ToyZOffset%d", i);
			Z = cache_get_field_content_float(current_row, field);
			
			format(field, sizeof(field), "ToyXRot%d", i);
			RotX = cache_get_field_content_float(current_row, field);
			
			format(field, sizeof(field), "ToyYRot%d", i);
			RotY = cache_get_field_content_float(current_row, field);
			
			format(field, sizeof(field), "ToyZRot%d", i);
			RotZ = cache_get_field_content_float(current_row, field);
			
			format(field, sizeof(field), "ToyXScale%d", i);
			ScaleX = cache_get_field_content_float(current_row, field);
			
			format(field, sizeof(field), "ToyYScale%d", i);
			ScaleY = cache_get_field_content_float(current_row, field);
			
			format(field, sizeof(field), "ToyZScale%d", i);
			ScaleZ = cache_get_field_content_float(current_row, field);
			
			format(field, sizeof(field), "ToyBone%d", i);
			BoneNum = cache_get_field_content_int(current_row, field);
			
			
			mysql_format(MYSQL_MAIN, query, sizeof(query), "INSERT INTO player_toys (PlayerSQLID, ToyX, ToyY, ToyZ, ToyRotX, ToyRotY, ToyRotZ, ToyScaleX, ToyScaleY, ToyScaleZ, ToyModel, ToyBone) VALUES (%d, %f, %f, %f, %f, %f, %f, %f, %f, %f, %d, %d)",\
			PlayerSQL, X, Y, Z, RotX, RotY, RotZ, ScaleX, ScaleY, ScaleZ, Toy_ModelID, BoneNum);
			mysql_query(MYSQL_MAIN, query, false);

		}
		
		printf("Migrated toys for player SQLID %d", PlayerSQL);
		current_row ++;
	}

	cache_delete(cache);
	printf ("***** MIGRATION OF TOY DATABASE FINISHED*****");
	return 1;
}

stock SavePlayerToy(playerid, slot)
{
	new query[255];
	mysql_format(MYSQL_MAIN, query, sizeof(query), "UPDATE player_toys SET ToyModel = '%d', ToyX = '%f', ToyY = '%f', ToyZ = '%f', ToyRotX = '%f', ToyRotY = '%f', ToyRotZ = '%f'",\
	PlayerToys[playerid][ToyModelID][slot], PlayerToys[playerid][ToyXOffset][slot], PlayerToys[playerid][ToyYOffset][slot], PlayerToys[playerid][ToyZOffset][slot], PlayerToys[playerid][ToyXRot][slot], PlayerToys[playerid][ToyYRot][slot], PlayerToys[playerid][ToyZRot][slot]);
	
	
	mysql_format(MYSQL_MAIN, query, sizeof(query), "%s, ToyScaleX = '%f', ToyScaleY = '%f', ToyScaleZ = '%f', ToyBone = '%d' WHERE ToySQLID = '%d'", query, PlayerToys[playerid][ToyXScale][slot], PlayerToys[playerid][ToyYScale][slot], PlayerToys[playerid][ToyZScale][slot], PlayerToys[playerid][ToyBone][slot], PlayerToys[playerid][ToySQLID][slot]);
	
	mysql_query(MYSQL_MAIN, query, false);
	return 1;
}

stock LoadPlayerToys(playerid)
{
	new query[64];
	mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT * FROM player_toys WHERE PlayerSQLID = '%d'", Player[playerid][pSQL_ID]);
	mysql_tquery(MYSQL_MAIN, query, "OnToysLoad", "d", playerid);
	return 1;
}

forward OnToysLoad(playerid);
public OnToysLoad(playerid)
{
	new rows = cache_get_row_count(), current_row = 0;
	
	while(current_row < rows && current_row < MAX_TOYS)
	{
		PlayerToys[playerid][ToySQLID][current_row] = cache_get_field_content_int(current_row, "ToySQLID");
		PlayerToys[playerid][ToyModelID][current_row] = cache_get_field_content_int(current_row, "ToyModel");
		PlayerToys[playerid][ToyBone][current_row] = cache_get_field_content_int(current_row, "ToyBone");
		
		PlayerToys[playerid][ToyXOffset][current_row] = cache_get_field_content_float(current_row, "ToyX");
		PlayerToys[playerid][ToyYOffset][current_row] = cache_get_field_content_float(current_row, "ToyY");
		PlayerToys[playerid][ToyZOffset][current_row] = cache_get_field_content_float(current_row, "ToyZ");
		
		PlayerToys[playerid][ToyXRot][current_row] = cache_get_field_content_float(current_row, "ToyRotX");
		PlayerToys[playerid][ToyYRot][current_row] = cache_get_field_content_float(current_row, "ToyRotY");
		PlayerToys[playerid][ToyZRot][current_row] = cache_get_field_content_float(current_row, "ToyRotX");
		
		PlayerToys[playerid][ToyXScale][current_row] = cache_get_field_content_float(current_row, "ToyScaleX");
		PlayerToys[playerid][ToyYScale][current_row] = cache_get_field_content_float(current_row, "ToyScaleY");
		PlayerToys[playerid][ToyZScale][current_row] = cache_get_field_content_float(current_row, "ToyScaleX");
		
		current_row++;
	}
	
	return 1;
}

stock CreatePlayerToys(playerid)
{
	new query[128];
	for(new i; i < MAX_TOYS; i++)
	{
		mysql_format(MYSQL_MAIN, query, sizeof(query), "INSERT INTO player_toys (PlayerSQLID) VALUES (%d)", Player[playerid][pSQL_ID]);
		mysql_query(MYSQL_MAIN, query, false);
	}
	return 1;
}

stock SaveAllPlayerToys(playerid)
{
	for(new i; i < MAX_TOYS; i++)
	{
		SavePlayerToy(playerid, i);
	}
	return 1;
}
