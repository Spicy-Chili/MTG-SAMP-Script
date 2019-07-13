/*
#		MTG Easter Code
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

#define MAX_EGGS	300

#define TYPE_POT			1
#define TYPE_COCAINE		2
#define TYPE_SPEED			3
#define TYPE_STREETMATS		4
#define TYPE_WEAPONS		5
#define TYPE_PRADIO			6
#define TYPE_ROPE			7
#define TYPE_RAGS			8
#define TYPE_WORKBENCH		9
#define TYPE_MONEY			10
#define TYPE_TOOLKIT		11
#define TYPE_ENGINEPARTS	12
#define TYPE_ARMOUR			13
#define TYPE_SHIT			14
#define TYPE_STANDARDMATS	15
#define TYPE_MILITARYMATS	16

#define TOTAL_TYPES		16

#define EGGS_FILE_PATH	"Misc/EasterEggs.txt"

enum egg_ 
{
	eObjectID,
	Float:ePos[3],
	Float:eRot[3],
	eVW,
	eIntID,
	ePrizeType,
	ePrizeValue,
};

new Eggs[MAX_EGGS][egg_];

static string[128];
static TopEggCount, TopEggName[MAX_PLAYER_NAME + 1];

CMD:stashegg(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 2)
		return 1;
	
	new type, value;
	if(sscanf(params, "dd", type, value)) 
	{
		SendClientMessage(playerid, -1, "SYNTAX: /stashegg [type #] [amount]");
		SendClientMessage(playerid, -1, "Types: 1 - Pot | 2 - Cocaine | 3 - Speed | 4 - StreetMats | 5 - Weapon | 6 - Personal Radio");
		SendClientMessage(playerid, -1, "7 - Rope | 8 - Rags | 9 - Workbench | 10 - Money | 11 - Toolkit | 12 - Engine parts");
		return SendClientMessage(playerid, -1, "13 - Armour | 14 - Shit (Random crap item like a shoe, tire, etc) | 15 - StandardMats | 16 - MilitaryMars");
	}
	
	if(type < 1 || type > TOTAL_TYPES) 
		return SendClientMessage(playerid, -1, "Type should be between 1 and "#TOTAL_TYPES);
	
	new eID = GetAvailableEggID();
	if(eID == -1)
		return SendClientMessage(playerid, -1, "No more egg slots available.");
	
	if(value < 0 || value > 100000000)
		return SendClientMessage(playerid, -1, "Value must always be greater than 0 or less than 100000000.");
	
	if(type == 5)
	{
		if(value < 1 || value > 47)
			return SendClientMessage(playerid, -1, "Invalid weapon id.");
	}
	
	if(type == 9 || type == 6 || type == 11 || type == 13)
	{
		if(value > 1)
			return SendClientMessage(playerid, -1, "Value must be 1 for this type.");
	}
	
	new Float:pPos[3], Int, VW;
	GetPlayerPos(playerid, pPos[0], pPos[1], pPos[2]);
	Int = GetPlayerInterior(playerid);
	VW = GetPlayerVirtualWorld(playerid);
	
	Eggs[eID][ePrizeType] = type;
	Eggs[eID][ePrizeValue] = value;
	CreateEgg(eID, pPos[0], pPos[1], pPos[2], Int, VW);
	
	format(string, sizeof(string), "You have created egg ID %d. Use /eggmove to move it or /eggdelete to remove it.", eID);
	SendClientMessage(playerid, -1, string);
	format(string, sizeof(string), "%s has created an egg (%d) with type %d and value %d.", Player[playerid][AdminName], eID, type, value);
	AdminActionsLog(string);
	
	return 1;
}

CMD:eggmove(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 2)
		return 1;
		
	new id; 
	if(sscanf(params, "d", id))
		return SendClientMessage(playerid, -1, "SYNTAX: /eggmove [egg id]");
	
	if(!IsValidEgg(id))
		return SendClientMessage(playerid, -1, "Invalid egg ID.");
		
	EditDynamicObject(playerid, Eggs[id][eObjectID]);
	SetPVarInt(playerid, "MovingEgg", 1);
	format(string, sizeof(string), "You are now editing egg id %d.", id);
	SendClientMessage(playerid, -1, string);
	
	return 1;
}

CMD:eggdelete(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 2)
		return 1;
		
	new id; 
	if(sscanf(params, "d", id))
		return SendClientMessage(playerid, -1, "SYNTAX: /eggdelete [egg id]");
	
	if(!IsValidEgg(id))
		return SendClientMessage(playerid, -1, "Invalid egg ID.");
		
	DestroyDynamicObject(Eggs[id][eObjectID]);
	format(string, sizeof(string), "You deleted egg ID %d.", id);
	SendClientMessage(playerid, -1, string);
	format(string, sizeof(string), "%s has deleted egg ID %d.", Player[playerid][AdminName], id);
	AdminActionsLog(string);
	return 1;
}

CMD:closestegg(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 2)
		return 1;
		
	format(string, sizeof(string), "The closest egg to you is ID %d.", GetClosestEgg(playerid));
	SendClientMessage(playerid, -1, string);
	return 1;
}

CMD:eggsleft(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 2)
		return 1;
	
	new count = 0;
	for(new i; i < MAX_EGGS; i++)
	{
		if(IsValidDynamicObject(Eggs[i][eObjectID]))
			count ++;
	}
	
	format(string, sizeof(string), "There are %d eggs left.", count);
	SendClientMessage(playerid, -1, string);
	return 1;
}

CMD:collectegg(playerid, params[])
{
	new id = GetClosestEgg(playerid);
	
	if(!IsPlayerInRangeOfPoint(playerid, 3.0, Eggs[id][ePos][0], Eggs[id][ePos][1], Eggs[id][ePos][2]))
		return SendClientMessage(playerid, -1, "You aren't near any easter eggs.");
	
	if(!IsValidEgg(id))
		return SendClientMessage(playerid, -1, "That easter egg isn't valid.");
		
	GivePrize(playerid, Eggs[id][ePrizeType], Eggs[id][ePrizeValue]);
	DestroyDynamicObject(Eggs[id][eObjectID]);
	
	if(Player[playerid][EggsCollected] > TopEggCount)
	{
		TopEggCount = Player[playerid][EggsCollected];
		format(TopEggName, MAX_PLAYER_NAME + 1, "%s", GetName(playerid));
	}
	
	return 1;
}

CMD:topegg(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 2)
		return 1;
		
	format(string, sizeof(string), "The top egg is %s who has collected %d eggs.", TopEggName, TopEggCount);
	SendClientMessage(playerid, -1, string);
	return 1;
}

CMD:eggsave(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 6)
		return 1;
		
	SaveEggs();
	SendClientMessage(playerid, -1, "You have saved all the easter eggs.");
	return 1;
}

CMD:egghelp(playerid, params[])
{
	SendClientMessage(playerid, -1, "/collectegg");
	if(Player[playerid][AdminLevel] >= 2)
	{
		SendClientMessage(playerid, -1, "/stashegg, /eggmove, /eggdelete, /closestegg, /eggsleft, /topegg");
	}
	if(Player[playerid][AdminLevel] >= 6)
		SendClientMessage(playerid, -1, "/eggsave");
	return 1;
}


hook OnGameModeInit()
{
	LoadEggs();
}

hook OnGameModeExit()
{
	SaveEggs();
}

hook OnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{	
	if(GetPVarInt(playerid, "MovingEgg") == 1)
	{
	
		new idx = -1;
		for(new i; i < MAX_EGGS; i++)
		{
			if(objectid == Eggs[i][eObjectID])
			{
				idx = i;
				break;
			}
		}

		if(idx == -1)
			return SendClientMessage(playerid, -1, "Something went wrong while editing the egg.");
		
		new Float:oldPos[3], Float:oldRot[3]; 
		GetDynamicObjectPos(objectid, oldPos[0], oldPos[1], oldPos[2]);
		GetDynamicObjectRot(objectid, oldRot[0], oldRot[1], oldRot[2]);
		
		if(!IsValidDynamicObject(objectid))
			return 1;
			
		MoveDynamicObject(objectid, x, y, z, 10, rx, ry, rz);
		
		if(response == EDIT_RESPONSE_FINAL)
		{
			Eggs[idx][ePos][0] = x;
			Eggs[idx][ePos][1] = y;
			Eggs[idx][ePos][2] = z;
			Eggs[idx][eRot][0] = rx;
			Eggs[idx][eRot][1] = ry;
			Eggs[idx][eRot][2] = rz;
			SendClientMessage(playerid, -1, "You have moved the egg.");
		}
		else if(response == EDIT_RESPONSE_CANCEL)
		{
			SetDynamicObjectPos(objectid, oldPos[0], oldPos[1], oldPos[2]);
			SetDynamicObjectRot(objectid, oldRot[0], oldRot[1], oldRot[2]);
		}
		
	}
	return 1;
}

stock CreateEgg(id, Float:x, Float:y, Float:z, intID, VW) 
{
	Eggs[id][eObjectID] = CreateDynamicObject(RandomEggObject(), x, y, z, Eggs[id][eRot][0], Eggs[id][eRot][1], Eggs[id][eRot][2], VW, intID);
	Eggs[id][ePos][0] = x;
	Eggs[id][ePos][1] = y;
	Eggs[id][ePos][2] = z;
	Eggs[id][eIntID] = intID;
	Eggs[id][eVW] = VW;
	return 1;
}

stock GetAvailableEggID() 
{
	new id = -1;
	for(new i; i < MAX_EGGS; i++) 
	{
		if(!IsValidDynamicObject(Eggs[i][eObjectID]))
		{
			id = i;
			break;
		}
	}
	return id;
}

stock RandomEggObject() 
{
	switch(random(2))
	{
		case 0: return 19344;
		default: return 19345;
	}
	return 1;
}

stock IsValidEgg(id) 
{
	if(id < 0 || id > MAX_EGGS)
		return false;
		
	return IsValidDynamicObject(Eggs[id][eObjectID]);
}

stock GetClosestEgg(playerid)
{
	new Float:dist, id = -1;
	for(new i; i < MAX_EGGS; i++)
	{
		if(IsValidDynamicObject(Eggs[i][eObjectID]))
		{
			if(id == -1 || dist > GetPlayerDistanceFromPoint(playerid, Eggs[i][ePos][0], Eggs[i][ePos][1], Eggs[i][ePos][2]))
			{
				dist = GetPlayerDistanceFromPoint(playerid, Eggs[i][ePos][0], Eggs[i][ePos][1], Eggs[i][ePos][2]);
				id = i;
			}
		}
	}
	return id;
	
}

stock GivePrize(playerid, prize, value)
{
	switch(prize)
	{
		case TYPE_POT:
		{
			Player[playerid][Pot] += value;
			format(string, sizeof(string), "%s has collected %d grams of pot from an egg.", GetName(playerid), value);
			StatLog(string);
			format(string, sizeof(string), "You collected %d grams of pot!", value);
		}
		case TYPE_COCAINE:
		{
			Player[playerid][Cocaine] += value;
			format(string, sizeof(string), "%s has collected %d grams of cocaine from an egg.", GetName(playerid), value);
			StatLog(string);
			format(string, sizeof(string), "You collected %d grams of cocaine!", value);
		}
		case TYPE_SPEED:
		{
			Player[playerid][Speed] += value;
			format(string, sizeof(string), "%s has collected %d grams of speed from an egg.", GetName(playerid), value);
			StatLog(string);
			format(string, sizeof(string), "You collected %d grams of speed!", value);
		}
		case TYPE_STREETMATS:
		{
			Player[playerid][Materials][0] += value;
			format(string, sizeof(string), "%s has collected %d street materials from an egg.", GetName(playerid), value);
			StatLog(string);
			format(string, sizeof(string), "You collected %d street materials!", value);
		}
		case TYPE_STANDARDMATS:
		{
			Player[playerid][Materials][1] += value;
			format(string, sizeof(string), "%s has collected %d standard materials from an egg.", GetName(playerid), value);
			StatLog(string);
			format(string, sizeof(string), "You collected %d standard materials!", value);
		}
		case TYPE_MILITARYMATS:
		{
			Player[playerid][Materials][2] += value;
			format(string, sizeof(string), "%s has collected %d military materials from an egg.", GetName(playerid), value);
			StatLog(string);
			format(string, sizeof(string), "You collected %d military materials!", value);
		}
		case TYPE_WEAPONS:
		{
			GivePlayerWeaponEx(playerid, value);
			format(string, sizeof(string), "%s has collected a %s from an egg.", GetName(playerid), GetWeaponNameEx(value));
			StatLog(string);
			format(string, sizeof(string), "You collected a %s!", GetWeaponNameEx(value));
		}
		case TYPE_PRADIO:
		{
			if(Player[playerid][PersonalRadio] > 0)
				return GivePrize(playerid, TYPE_SHIT, 1);
				
			Player[playerid][PersonalRadio] = 1;
			format(string, sizeof(string), "%s has collected a personal radio from an egg.", GetName(playerid));
			StatLog(string);
			format(string, sizeof(string), "You collected a personal radio.");
		}
		case TYPE_ROPE:
		{
			Player[playerid][Rope] += value;
			format(string, sizeof(string), "%s has collected %d rope from an egg.", GetName(playerid), value);
			StatLog(string);
			format(string, sizeof(string), "You collected %d rope.", value);
		}
		case TYPE_RAGS:
		{
			Player[playerid][Rags] += value;
			format(string, sizeof(string), "%s has collected %d ragsom an egg.", GetName(playerid), value);
			StatLog(string);
			format(string, sizeof(string), "You collected %d rags.", value);
		}
		case TYPE_WORKBENCH:
		{
			if(Player[playerid][Workbench] > 0)
				return GivePrize(playerid, TYPE_SHIT, 1);
				
			Player[playerid][Workbench] = 1;
			format(string, sizeof(string), "%s has collected a workbench from an egg.", GetName(playerid));
			StatLog(string);
			format(string, sizeof(string), "You collected a workbench.");
		}
		case TYPE_MONEY:
		{
			Player[playerid][Money] += value;
			format(string, sizeof(string), "%s has collected %s from an egg.", PrettyMoney(value));
			StatLog(string);
			format(string, sizeof(string), "You collected %s.", PrettyMoney(value));
		}
		case TYPE_TOOLKIT:
		{
			if(Player[playerid][Toolkit] > 0)
				return GivePrize(playerid, TYPE_SHIT, 1);
				
			Player[playerid][Toolkit] = 1;
			format(string, sizeof(string), "%s has collected a toolkit from an egg.", GetName(playerid));
			StatLog(string);
			format(string, sizeof(string), "You collected a toolkit.");
		}
		case TYPE_ENGINEPARTS:
		{
			if(Player[playerid][EngineParts] >= 5)
				return GivePrize(playerid, TYPE_SHIT, 1);
				
			if(Player[playerid][EngineParts] + value > 5)
				value = 5 - Player[playerid][EngineParts];
				
			Player[playerid][EngineParts] += value;
			format(string, sizeof(string), "%s has collected %d engine parts from an egg.", GetName(playerid), value);
			StatLog(string);
			format(string, sizeof(string), "You have collected %d engine parts.", value);
		}
		case TYPE_ARMOUR:
		{
			new Float:pArmour;
			GetPlayerArmour(playerid, pArmour);
			if(pArmour + value > 100)
				value = floatround(100 - pArmour);
			
			if(value <= 0)
				return GivePrize(playerid, TYPE_SHIT, 1);
			
			SetPlayerArmour(playerid, pArmour + value);
			format(string, sizeof(string), "%s has collected %d armour points from an egg.", GetName(playerid), value);
			StatLog(string);
			format(string, sizeof(string), "You have collected %d armour points!", value);
			
		}
		case TYPE_SHIT:
		{
			switch(random(15))
			{
				case 0: format(string, sizeof(string), "Looks like all you got was a used tire, sucks to be you.");
				case 1: format(string, sizeof(string), "You have collected a shoe! I wonder where the other one is...");
				case 2: format(string, sizeof(string), "You got a brown paper bag that smells pretty bad.");
				case 3: format(string, sizeof(string), "You found a VHS tape labeled \"Johnny D XXX Tape\" ");
				case 4: format(string, sizeof(string), "Confetti flies out of the egg when you open it but there does not seem to be a prize.");
				case 5: format(string, sizeof(string), "Your prize is half of a bass fish.");
				case 6: format(string, sizeof(string), "You found a shiny level 35 pikachu pokemon card in the easter egg.");
				case 7: format(string, sizeof(string), "You found a DVD for season 1 of \"The Jersey Shore\"");
				case 8: format(string, sizeof(string), "You found a dinosaur egg in the easter egg, eww!");
				case 9: format(string, sizeof(string), "You found a Willy Wonka chocolate bar but it seems to be half eaten already.");
				case 10: format(string, sizeof(string), "You found a chicken egg with a ChenCo brand sticker on it and it appears to be broken, how odd.");
				case 11: format(string, sizeof(string), "You found a remastered bluray copy of \"Full Metal Jacket\".");
				case 12: format(string, sizeof(string), "You found a Gucci shower cap.");
				case 13: format(string, sizeof(string), "You found a trippy pair of tie dye underwear.");
				case 14: format(string, sizeof(string), "You found a playgirl magazine with Cosmo Kramer on the cover.");
			}
		}
	}
	
	Player[playerid][EggsCollected]++;
	SendClientMessage(playerid, LSFMD_COLOR, string);
	
	return 1;
}

stock SaveEggs()
{
	if(fexist(EGGS_FILE_PATH))
	{
		fremove(EGGS_FILE_PATH);
	}
	new count = 0;
	new File:file = fopen(EGGS_FILE_PATH, io_write);
	if(file)
	{
		for(new i; i < MAX_EGGS; i ++)
		{
			if(!IsValidDynamicObject(Eggs[i][eObjectID]))
				continue;
				
			format(string, sizeof(string), "%f %f %f %f %f %f %d %d %d %d\r\n", Eggs[i][ePos][0], Eggs[i][ePos][1], Eggs[i][ePos][2], Eggs[i][eRot][0], Eggs[i][eRot][1], Eggs[i][eRot][2], Eggs[i][eVW], Eggs[i][eIntID], Eggs[i][ePrizeType], Eggs[i][ePrizeValue]);
			fwrite(file, string);
			count++;
		}
	}
	dini_IntSet("Assets.ini", "TopEggCount", TopEggCount);
	dini_Set("Assets.ini", "TopEggName", TopEggName);
	printf("[Easter Eggs] Saved %d easter eggs.", count);
	fclose(file);
	return 1;
}	

stock LoadEggs() 
{
	if(!fexist(EGGS_FILE_PATH))
		dini_Create(EGGS_FILE_PATH);
	
	new count;
	new File:file = fopen(EGGS_FILE_PATH, io_read), i, string2[128];
	while(fread(file, string2))
	{
		i = GetAvailableEggID();
		if(i == -1)
			break;
		
		sscanf(string2, "ffffffdddd", Eggs[i][ePos][0], Eggs[i][ePos][1], Eggs[i][ePos][2], Eggs[i][eRot][0], Eggs[i][eRot][1], Eggs[i][eRot][2], Eggs[i][eVW], Eggs[i][eIntID], Eggs[i][ePrizeType], Eggs[i][ePrizeValue]);
		CreateEgg(i, Eggs[i][ePos][0], Eggs[i][ePos][1], Eggs[i][ePos][2], Eggs[i][eIntID], Eggs[i][eVW]);
		count++;
	}
	format(TopEggName, MAX_PLAYER_NAME + 1, "%s", dini_Get("Assets.ini", "TopEggName"));
	TopEggCount = dini_Int("Assets.ini", "TopEggCount");
	printf("[Easter Eggs] Loaded %d easter eggs.", count);
	fclose(file);
	return 1;
}