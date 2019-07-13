/*
#		MTG Camping System
#
#
#	By accessing this file, you agree to the following:
#		- You will never give the script or associated files to anybody who is not on the MTG SAMP development team
# 		- You will delete all development materials (script, databases, associated files, etc.) when you leave the MTG SAMP development team.
#
#	TODO
		-GetClosestTent
		-
#
*/
#include <YSI\y_hooks>


#define MAX_TENTS 100
enum TentData
{
	TentSQL,
	TentObject,
	Deployed,
	PlacedBy[25],
	Float:TentX,
	Float:TentY,
	Float:TentZ,
	Camo1,
	Camo2[12],
	Camo3[12],
	TentP1,
	TentP2,
	TentP3,
	TentP4,
	TentP5,
	TentP6,
	TentP7,
	TentP8,
	TentP9,
	TentP10,
	TentP11,
	TentP12,
	TentP13,
	TentP14,
};
new GlobalTents[MAX_TENTS][TentData];
new Iterator:Tent<MAX_TENTS>;
new TentStorageSize = 10;

stock GetFreeTentID() { return Iter_Free(Tent);}

stock HasPlayerPlacedTent(playerid)
{
	new id = -1;
	foreach(new i : Tent) 
	{
		if(!strcmp(GlobalTents[i][PlacedBy], GetName(playerid), true) && !isnull(GlobalTents[i][PlacedBy]))
		{
			id = i;
			break;
		}
	}
	return id;
}

stock GetClosestTent(playerid, &Float:distanceTo)
{
	new tentid = -1, Float:dist = -1;
	foreach(new i : Tent)
	{
		if(GlobalTents[i][Deployed] == 1)
		{
			if(tentid == -1 || dist > GetPlayerDistanceFromPoint(playerid, GlobalTents[i][TentX], GlobalTents[i][TentY], GlobalTents[i][TentZ]))
			{
				tentid = i;
				dist = GetPlayerDistanceFromPoint(playerid, GlobalTents[i][TentX], GlobalTents[i][TentY], GlobalTents[i][TentZ]);
				distanceTo = dist;
			}
		}
	}
	return tentid;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DIALOG_TENT_COLOR:
		{
			if(!response)
				return 1;
				
			switch(listitem)
			{
				case 0: // Woodland
				{
					SetPVarInt(playerid, "Camo1", 19101);
					SetPVarString(playerid, "Camo2", "armyhelmets");
					SetPVarString(playerid, "Camo3", "armyhelmet1");
				}
				case 1: // Desert
				{
					if(Player[playerid][VipRank] < 1)
						return SendClientMessage(playerid, YELLOW, "Only VIPs can use this camo!");
						
					SetPVarInt(playerid, "Camo1", 3095);
					SetPVarString(playerid, "Camo2", "a51jdrx");
					SetPVarString(playerid, "Camo3", "sam_camo");
				}
				case 2: // Jungle
				{
					if(Player[playerid][VipRank] < 1)
						return SendClientMessage(playerid, YELLOW, "Only VIPs can use this camo!");
						
					SetPVarInt(playerid, "Camo1", 19102);
					SetPVarString(playerid, "Camo2", "armyhelmets");
					SetPVarString(playerid, "Camo3", "armyhelmet2");
				}
				case 3: // Pink
				{
					if(Player[playerid][VipRank] < 1)
						return SendClientMessage(playerid, YELLOW, "Only VIPs can use this camo!");
						
					SetPVarInt(playerid, "Camo1", 19112);
					SetPVarString(playerid, "Camo2", "armyhelmets");
					SetPVarString(playerid, "Camo3", "armyhelmet7");
				}
			}
			
			new Float:pos[3], slot = GetFreeTentID();
			if(slot == -1)
				return SendClientMessage(playerid, WHITE, "The maximum amount of tents has been placed. You are unable to place another one at this time.");
			
			GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
			
			GlobalTents[slot][TentObject] = CreateDynamicObject(2613, pos[0], pos[1], pos[2], 0.00000, 90.00000, 0.00000);
			SetDynamicObjectMaterial(GlobalTents[slot][TentObject], 0, 19374, "all_walls", "mirror01", 0);
			
			GlobalTents[slot][Camo1] = GetPVarInt(playerid, "Camo1");
			GetPVarString(playerid, "Camo2", GlobalTents[slot][Camo2], 12);
			GetPVarString(playerid, "Camo3", GlobalTents[slot][Camo3], 12);
			DeletePVar(playerid, "Camo1");
			DeletePVar(playerid, "Camo2");
			DeletePVar(playerid, "Camo3");
			
			GlobalTents[slot][TentX] = pos[0];
			GlobalTents[slot][TentY] = pos[1];
			GlobalTents[slot][TentZ] = pos[2];
			
			CreateTent(slot);
			EditDynamicObject(playerid, GlobalTents[slot][TentObject]);
			UpdateTentPosition(slot, pos[0], pos[1], pos[2]);
			
			SetPVarInt(playerid, "TentSlot", slot);
			SetPVarInt(playerid, "MovingTent", GlobalTents[slot][TentObject]);
			SetPVarFloat(playerid, "TentX", pos[0]);
			SetPVarFloat(playerid, "TentY", pos[1]);
			SetPVarFloat(playerid, "TentZ", pos[2]);
			SendClientMessage(playerid, WHITE, "You are now editing your tent. Place it how you wish!");
			Player[playerid][Tent] = 0;
		}
		case DIALOG_TENT_ADMIN:
		{
			if(!response)
				return 1;
			
			new tentid = strval(CutBeforeLine(inputtext));
			SetPlayerPos_Update(playerid, GlobalTents[tentid][TentX], GlobalTents[tentid][TentY], GlobalTents[tentid][TentZ]);
		}
		case DIALOG_TENT_TAKE:
		{
			if(!response)
				return 1;

			new item_type, string[128], item_name[32], tentid = GetPVarInt(playerid, "tentid");
			format(item_name, sizeof(item_name), "%s", ParseItemNameFromString(inputtext));
			item_type = GetItemTypeFromName(item_name);

			if(item_type != ITEM_TYPE_WEAPON)
			{
				SetPVarInt(playerid, "ITEM_TYPE", item_type);
				ShowPlayerDialog(playerid, DIALOG_TENT_TAKE+1, DIALOG_STYLE_INPUT, "Tent Storage", "How much would you like to take?", "Accept", "Cancel");
				return 1;
			}
			else
			{

				new weapid = 0;
				for(new i = 1; i < 47; i ++)
				{
					if(!strcmp(weapons[i], item_name, true) && strlen(weapons[i]) > 0)
					{
						weapid = i;
						break;
					}
				}

				if(weapid == 0)
					return SendClientMessage(playerid, WHITE, "Weapon ID not found. Make a bug report");

				if(PlayerHasWeaponInSlot(playerid, GetWeaponType(weapid)))
					return SendClientMessage(playerid, WHITE, "You already have a weapon in this slot. Store it or get rid of it first.");

				if(!IsItemInStorage(GlobalTents[tentid][TentSQL], CONTAINER_TYPE_TENT, ITEM_TYPE_WEAPON, weapid))
					return SendClientMessage(playerid, WHITE, IntToFormattedStr(IsItemInStorage(GlobalTents[tentid][TentSQL], CONTAINER_TYPE_TENT, ITEM_TYPE_WEAPON, weapid)));

				RemoveFromStorage(GlobalTents[tentid][TentSQL], CONTAINER_TYPE_TENT, ITEM_TYPE_WEAPON, weapid);
				AddItemToPlayer(playerid, ITEM_TYPE_WEAPON, weapid);

				format(string, sizeof(string), "* %s has taken a weapon from the tent.", GetNameEx(playerid));
		      	NearByMessage(playerid, NICESKY, string);
				format(string, sizeof(string), "[TENT] %s has taken %s (%d) from tent id %d.", GetName(playerid), weapons[weapid], weapid, GlobalTents[tentid][TentSQL]);
				StatLog(string);
				SavePlayerData(playerid);
			}
			return 1;
		}
		case DIALOG_TENT_TAKE+1:
		{
			new item_amount = strval(inputtext), item_type = GetPVarInt(playerid, "ITEM_TYPE"), tentid = GetPVarInt(playerid, "tentid");
			DeletePVar(playerid, "tentid");

			if(item_amount < 1)
				return SendClientMessage(playerid, WHITE, "Invalid amount entered.");

			new db_item_amount = IsItemInStorage(GlobalTents[tentid][TentSQL], CONTAINER_TYPE_TENT, item_type, item_amount);

			if(db_item_amount == 0)
				return SendClientMessage(playerid, WHITE, "That item is no longer in storage.");

			if(item_amount > db_item_amount)
				item_amount = db_item_amount;

			new string[128];
			RemoveFromStorage(GlobalTents[tentid][TentSQL], CONTAINER_TYPE_TENT, item_type, item_amount);
			AddItemToPlayer(playerid, item_type, item_amount);

			format(string, sizeof(string), "* %s has taken some %s from the tent.", GetNameEx(playerid), strtolower(GetItemName(item_type)));
			NearByMessage(playerid, NICESKY, string);
			format(string, sizeof(string), "You have taken %d %s from the tent.", item_amount, strtolower(GetItemName(item_type)));
			SendClientMessage(playerid, WHITE, string);
			format(string, sizeof(string), "[TENT] %s has taken %d %s from tent %d.", GetName(playerid), item_amount, GetItemName(item_type), GlobalTents[tentid][TentSQL]);
			StatLog(string);
			SavePlayerData(playerid);
		}
	}
	return 1;
}

hook OnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	if(GetPVarInt(playerid, "MovingTent") == objectid && objectid != 0)
	{
		new Float: startpos[3];
	    
		startpos[0] = GetPVarFloat(playerid, "TentX");
	    startpos[1] = GetPVarFloat(playerid, "TentY");
	    startpos[2] = GetPVarFloat(playerid, "TentZ");
		DeletePVar(playerid, "TentX");
		DeletePVar(playerid, "TentY");
		DeletePVar(playerid, "TentZ");
		UpdateTentPosition(GetPVarInt(playerid, "TentSlot"), x, y, z);
		
		if(GetDistanceBetweenPoints(startpos[0], startpos[1], startpos[2], x, y, z) > 10 && startpos[0] != 0.0)
		{
			DestroyTent(GetPVarInt(playerid, "MovingTent"));
			DeletePVar(playerid, "MovingTent");
			DeletePVar(playerid, "Camo1");
			DeletePVar(playerid, "Camo2");
			DeletePVar(playerid, "Camo3");
			DeletePVar(playerid, "TentSlot");
			return SendClientMessage(playerid, -1, "You have moved the tent too far away from you.");
		}
		
		switch(response)
	    {
			case EDIT_RESPONSE_CANCEL:
			{
				DestroyTent(GetPVarInt(playerid, "MovingTent"));
				DeletePVar(playerid, "MovingTent");
				DeletePVar(playerid, "Camo1");
				DeletePVar(playerid, "Camo2");
				DeletePVar(playerid, "Camo3");
				DeletePVar(playerid, "TentSlot");
				return SendClientMessage(playerid, -1, "You have cancelled placing the tent.");
			}
	        case EDIT_RESPONSE_FINAL:
	        {
				new slot = GetPVarInt(playerid, "TentSlot");
				DeletePVar(playerid, "TentSlot");
				
				GlobalTents[slot][TentX] = x;
				GlobalTents[slot][TentY] = y;
				GlobalTents[slot][TentZ] = z;
				format(GlobalTents[slot][PlacedBy], 25, "%s", GetName(playerid));
				DeletePVar(playerid, "MovingTent");
				SetDynamicObjectPos(objectid, x, y, z);
				SetDynamicObjectRot(objectid, rx, ry, rz);
				
				DestroyDynamicObject(GlobalTents[slot][TentObject]);
				UpdateTentPosition(slot);
				SaveTent(slot);
				
				new string[128];
				format(string, sizeof(string), "* %s deploys their tent.", GetNameEx(playerid));
				NearByMessage(playerid, NICESKY, string);				
	        }
	    }
	}
	return 1;
}

CMD:deploytent(playerid, params[])
{	
	if(Player[playerid][PlayingHours] < 20 && Player[playerid][VipRank] < 1)
		return SendClientMessage(playerid, -1, "You need at least 20 playing hours to place a tent!");
	
	if(GetPlayerInterior(playerid) != 0)
		return SendClientMessage(playerid, -1, "You can only place a tent in interior 0.");

	if(GetPlayerVirtualWorld(playerid) != 0)
		return SendClientMessage(playerid, -1, "You can only place a tent in virtual world 0.");
	
	if(Player[playerid][Tent] < 1)
		return SendClientMessage(playerid, -1, "You don't have a tent to deploy!");
		
	if(Player[playerid][Tied] >= 1 || Player[playerid][Cuffed] >= 1 || Player[playerid][Tazed] == 1 || Player[playerid][AdminFrozen] == 1)
		return SendClientMessage(playerid, -1, "You can't do that right now, you're incapacitated!");
	
	if(Player[playerid][TentBan] == 1)
		return SendClientMessage(playerid, -1, "You are banned from using /deploytent.");
		
	if(HasPlayerPlacedTent(playerid) != -1)
		return SendClientMessage(playerid, WHITE, "You have already placed a tent.");
	
	ShowPlayerDialog(playerid, DIALOG_TENT_COLOR, DIALOG_STYLE_LIST, "Select a tent color", "Woodland Camo\nDesert Camo [VIP]\nJungle Camo [VIP]\nPink Camo [VIP]", "Select", "Cancel");
	return 1;
}

CMD:removetent(playerid, params[])
{
	if(Player[playerid][Tied] >= 1 || Player[playerid][Cuffed] >= 1 || Player[playerid][Tazed] == 1 || Player[playerid][AdminFrozen] == 1)
		return SendClientMessage(playerid, -1, "You can't do that right now, you're incapacitated!");
		
	if(Player[playerid][TentBan] == 1)
		return SendClientMessage(playerid, -1, "You are banned from using /removetent.");
		
	new Float:dist, tentid = GetClosestTent(playerid, dist);
	
	if(dist > 5 || tentid == -1)
		return SendClientMessage(playerid, -1, "You are not in range of a tent to take it.");
		
	if(strfind(GetStorageString(GlobalTents[tentid][TentSQL], CONTAINER_TYPE_TENT), "Nothing", true) == -1)
		return SendClientMessage(playerid, -1, "Remove all the items inside the tent before removing the tent.");
	
	DestroyTent(tentid);
	SendClientMessage(playerid, -1, "You have picked up a tent.");
	Player[playerid][Tent] = 1;
	new string[128];
	format(string, sizeof(string), "* %s packs up a tent.", GetNameEx(playerid));
	NearByMessage(playerid, NICESKY, string);
	
	return 1;
}

CMD:tentstore(playerid, params[])
{
	new Float:dist, tentid = GetClosestTent(playerid, dist);
	
	if(dist > 5)
		return SendClientMessage(playerid, WHITE, "You are not close enough to a tent.");
	
	if(GetPVarInt(playerid, "StoreTimer") > gettime())
		return 1;

	new item_name[32], item_amount, item_type, PlayerItemAmount;
	if(sscanf(params, "s[32]d", item_name, item_amount))
	{
		SendClientMessage(playerid, GREY, "SYNTAX: /tentstore [item] [amount]");
		return SendClientMessage(playerid, GREY, "Types: money, speed, cocaine, pot, weapon, streetmats, standardmats, militarymats, potseeds");
	}

	if(item_amount < 1)
		return SendClientMessage(playerid, WHITE, "Invalid item amount.");

	item_type = GetItemTypeFromName(item_name);
	if(item_type == ITEM_TYPE_NONE)
	{
		return SendClientMessage(playerid, WHITE, "Invalid item name.");
	}

	if(item_type != ITEM_TYPE_WEAPON)
	{
		PlayerItemAmount = GetPlayerItemAmount(playerid, item_type);
		if( PlayerItemAmount < item_amount)
			return SendClientMessage(playerid, WHITE, "You don't have that amount on you.");
	}

	SetPVarInt(playerid, "StoreTimer", gettime() + 3);
	if(item_type == ITEM_TYPE_WEAPON)
	{
		item_amount = GetPlayerWeapon(playerid);
		if(!PlayerHasWeapon(playerid, item_amount))
			return 1;
		if(item_amount == 0 || item_amount == 46)
			return SendClientMessage(playerid, WHITE, "You can't store that weapon.");
	}

	if((CalculateContainerWeight(GlobalTents[tentid][TentSQL], CONTAINER_TYPE_TENT) + GetItemWeight(item_type, item_amount)) > TentStorageSize)
		return SendClientMessage(playerid, -1, "There isn't enough room in this tent to store that.");

	AddToStorage(GlobalTents[tentid][TentSQL], CONTAINER_TYPE_TENT, item_type, item_amount);
	RemoveItemFromPlayer(playerid, item_type, item_amount);
	
	new string[128];
	if(item_type == ITEM_TYPE_WEAPON)
		format(string, sizeof(string), "* %s has stored a weapon in the tent.", GetNameEx(playerid));
	else format(string, sizeof(string), "* %s has stored some %s in the tent.", GetNameEx(playerid), strtolower(GetItemName(item_type)));
	NearByMessage(playerid, NICESKY, string);

	if(item_type == ITEM_TYPE_WEAPON)
		format(string, sizeof(string), "You have stored a %s in the tent.", GetWeaponNameEx(item_amount));
	else format(string, sizeof(string), "You have stored %d %s in the tent.", item_amount, strtolower(GetItemName(item_type)));
	SendClientMessage(playerid, WHITE, string);

	if(item_type == ITEM_TYPE_WEAPON)
		format(string, sizeof(string), "[TENT] %s has stored a %s (%d) in tent id %d.", GetName(playerid), GetWeaponNameEx(item_amount), item_amount, GlobalTents[tentid][TentSQL]);
	else format(string, sizeof(string), "[TENT] %s has stored %s (%d) in tent id %d. (New Inv Amount: %d)", GetName(playerid), GetItemName(item_type), item_amount, GlobalTents[tentid][TentSQL], GetPlayerItemAmount(playerid, item_type));
	StatLog(string);
	StorageLog(string);		
	return 1;
}

CMD:tenttake(playerid, params[])
{
	new Float:dist, tentid = GetClosestTent(playerid, dist);
	
	if(dist > 5)
		return SendClientMessage(playerid, WHITE, "You are not close enough to a tent.");
		
	new string[64];
	format(string, sizeof(string), "Tent Storage (%d/%d)", CalculateContainerWeight(GlobalTents[tentid][TentSQL], CONTAINER_TYPE_TENT), TentStorageSize);
	ShowPlayerDialog(playerid, DIALOG_TENT_TAKE, DIALOG_STYLE_LIST, string, GetStorageString(GlobalTents[tentid][TentSQL], CONTAINER_TYPE_TENT), "Take", "Exit");
	SetPVarInt(playerid, "tentid", tentid);
	return 1;
}

CMD:listtents(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 2)
		return 1;
	
	new string[500];
	foreach(new i : Tent)
	{
		if(GlobalTents[i][Deployed] == 1)
			format(string, sizeof(string), "%s%d | Owner: %s", string, i, GlobalTents[i][PlacedBy]);
	}
	ShowPlayerDialog(playerid, DIALOG_TENT_ADMIN, DIALOG_STYLE_LIST, "List of tents", string, "Teleport", "Cancel");
	return 1;
}

CMD:tentban(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 2)
		return 1;
	new id;
	if(sscanf(params, "u", id))
		return SendClientMessage(playerid, -1, "SYNTAX: /tentban [playerid]");
		
	new string[128];
	switch(Player[id][TentBan])
	{
		case 0:
		{
			format(string, sizeof(string), "You have banned %s from placing/picking up tents.", GetName(id));
			SendClientMessage(playerid, -1, string);
			format(string, sizeof(string), "%s has banned %s from placing/picking up tents.", GetName(playerid), GetName(id));
			AdminActionsLog(string);
			
			Player[id][TentBan] = 1;
			SendClientMessage(id, COLOR_RED, "You have been banned from placing/picking up tents by an admin.");
			
		}
		case 1:
		{
			format(string, sizeof(string), "You have unbanned %s from placing/picking up tents.", GetName(id));
			SendClientMessage(playerid, -1, string);
			format(string, sizeof(string), "%s has unbanned %s from placing/picking up tents.", GetName(playerid), GetName(id));
			AdminActionsLog(string);
			
			Player[id][TentBan] = 0;
			SendClientMessage(id, COLOR_GREEN, "You have been unbanned from placing/picking up tents by an admin.");
		}
	}
	return 1;
}

stock CreateTent(slot)
{
	new retexture, Float:x = GlobalTents[slot][TentX], Float:y = GlobalTents[slot][TentY], Float:z = GlobalTents[slot][TentZ];
	
	Iter_Add(Tent, slot);
	
	GlobalTents[slot][Deployed] = 1;
	
	retexture = CreateDynamicObject(2395, x + 1.70617, y - 0.92676, z + 0.2785, -210.00000, 0.00000, 180.00000);
	SetDynamicObjectMaterial(retexture, 0, GlobalTents[slot][Camo1], GlobalTents[slot][Camo2], GlobalTents[slot][Camo3], 0);
	GlobalTents[slot][TentP1] = retexture;

	retexture = CreateDynamicObject(2395, x - 1.04993, y - 0.79248, z + 0.3545, 210.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(retexture, 0, GlobalTents[slot][Camo1], GlobalTents[slot][Camo2], GlobalTents[slot][Camo3], 0);
	GlobalTents[slot][TentP2] = retexture;
				
	retexture = CreateDynamicObject(2395, x - 1.0459, y - 0.84839, z + 0.2785, -210.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(retexture, 0, GlobalTents[slot][Camo1], GlobalTents[slot][Camo2], GlobalTents[slot][Camo3], 0);
	GlobalTents[slot][TentP3] = retexture;

	retexture = CreateDynamicObject(2395, x + 1.7041, y - 0.98071, z + 0.3545, 210.00000, 0.00000, 180.00000);
    SetDynamicObjectMaterial(retexture, 0, GlobalTents[slot][Camo1], GlobalTents[slot][Camo2], GlobalTents[slot][Camo3], 0);
	GlobalTents[slot][TentP4] = retexture;

	retexture = CreateDynamicObject(2395, x - 1.04663, y + 0.48413, z - 2.1195, 90.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(retexture, 0, GlobalTents[slot][Camo1], GlobalTents[slot][Camo2], GlobalTents[slot][Camo3], 0);
	GlobalTents[slot][TentP5] = retexture;

	retexture = CreateDynamicObject(2395, x - 1.04798, y - 2.25854, z - 1.9655, 270.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(retexture, 0, GlobalTents[slot][Camo1], GlobalTents[slot][Camo2], GlobalTents[slot][Camo3], 0);
	GlobalTents[slot][TentP6] = retexture;

    GlobalTents[slot][TentP7] = CreateDynamicObject(19087, x - 1.51441, y - 0.88623, z + 0.4248, 0.00000, 0.00000, 0.00000);
	GlobalTents[slot][TentP8] =  CreateDynamicObject(19087, x + 2.1676, y - 0.88623, z + 0.4248,  0.00000, 0.00000, 0.00000);
    GlobalTents[slot][TentP9] = CreateDynamicObject(19087, x + 0.92761, y - 0.85034, z + 0.3348,  0.00000, 90.00000, 0.00000);
    GlobalTents[slot][TentP10] = CreateDynamicObject(19087, x + 0.95568, y - 0.88623, z + 0.3348,  0.00000, 90.00000, 0.00000);
    GlobalTents[slot][TentP11] = CreateDynamicObject(19087, x + 0.92761, y - 0.92431, z + 0.3348,   0.00000, 90.00000, 0.00000);
    GlobalTents[slot][TentP12] = CreateDynamicObject(19087, x + 2.1676, y - 0.92431, z + 0.3348,   0.00000, 90.00000, 0.00000);
    GlobalTents[slot][TentP13] = CreateDynamicObject(19087, x + 2.15966, y - 0.88623, z + 0.3348,   0.00000, 90.00000, 0.00000);
	GlobalTents[slot][TentP14] = CreateDynamicObject(19087, x + 2.1676, y - 0.85034, z + 0.3348,  0.00000, 90.00000, 0.00000);		
	
	SaveTent(slot);
	return 1;
}

stock UpdateTentPosition(slot, Float:x = 0.0, Float:y = 0.0, Float:z = 0.0)
{
	if(x == 0.0 && y == 0.0 && z == 0.0)
	{
		x = GlobalTents[slot][TentX];
		y = GlobalTents[slot][TentY];
		z = GlobalTents[slot][TentZ];
	}
	
	MoveDynamicObject(GlobalTents[slot][TentP1], x + 1.70617, y - 0.92676, z + 0.2785, 5.0);
	MoveDynamicObject(GlobalTents[slot][TentP2], x - 1.04993, y - 0.79248, z + 0.3545, 5.0);
	MoveDynamicObject(GlobalTents[slot][TentP3], x - 1.0459, y - 0.84839, z + 0.2785, 5.0);
	MoveDynamicObject(GlobalTents[slot][TentP4], x + 1.7041, y - 0.98071, z + 0.3545, 5.0);
	MoveDynamicObject(GlobalTents[slot][TentP5], x - 1.04663, y + 0.48413, z - 2.1195, 5.0);
	MoveDynamicObject(GlobalTents[slot][TentP6], x - 1.04798, y - 2.25854, z - 1.9655, 5.0);
	MoveDynamicObject(GlobalTents[slot][TentP7], x - 1.51441, y - 0.88623, z + 0.4248, 5.0);
	MoveDynamicObject(GlobalTents[slot][TentP8], x + 2.1676, y - 0.88623, z + 0.4248, 5.0);
	MoveDynamicObject(GlobalTents[slot][TentP9], x + 0.92761, y - 0.85034, z + 0.3348, 5.0);
	MoveDynamicObject(GlobalTents[slot][TentP10], x + 0.95568, y - 0.88623, z + 0.3348, 5.0);
	MoveDynamicObject(GlobalTents[slot][TentP11], x + 0.92761, y - 0.92431, z + 0.3348, 5.0);
	MoveDynamicObject(GlobalTents[slot][TentP12], x + 2.1676, y - 0.92431, z + 0.3348, 5.0);
	MoveDynamicObject(GlobalTents[slot][TentP13], x + 2.15966, y - 0.88623, z + 0.3348, 5.0);
	MoveDynamicObject(GlobalTents[slot][TentP14], x + 2.1676, y - 0.85034, z + 0.3348, 5.0);
	return 1;
}

stock DestroyTent(slot)
{
	DestroyDynamicObject(GlobalTents[slot][TentP1]);
	DestroyDynamicObject(GlobalTents[slot][TentP2]);
	DestroyDynamicObject(GlobalTents[slot][TentP3]);
	DestroyDynamicObject(GlobalTents[slot][TentP4]);
	DestroyDynamicObject(GlobalTents[slot][TentP5]);
	DestroyDynamicObject(GlobalTents[slot][TentP6]);
	DestroyDynamicObject(GlobalTents[slot][TentP7]);
	DestroyDynamicObject(GlobalTents[slot][TentP8]);
	DestroyDynamicObject(GlobalTents[slot][TentP9]);
	DestroyDynamicObject(GlobalTents[slot][TentP10]);
	DestroyDynamicObject(GlobalTents[slot][TentP11]);
	DestroyDynamicObject(GlobalTents[slot][TentP12]);
	DestroyDynamicObject(GlobalTents[slot][TentP13]);
	DestroyDynamicObject(GlobalTents[slot][TentP14]);	
	DestroyDynamicObject(GlobalTents[slot][TentObject]);
	GlobalTents[slot][TentObject] = INVALID_OBJECT_ID;
	format(GlobalTents[slot][PlacedBy], 25, "");
	GlobalTents[slot][Deployed] = 0;
	
	Iter_Remove(Tent, slot);
	
	SaveTent(slot);
	return 1;
}


stock LoadTents()
{

	new Cache:cache = mysql_query(MYSQL_MAIN, "SELECT * FROM Tents");
	new count = cache_get_row_count(), row, id = 0, created = 0;
	while(row < count)
	{
		GlobalTents[id][TentSQL] = cache_get_field_content_int(row, "TentSQL");
		GlobalTents[id][TentX] = cache_get_field_content_float(row, "TentX");
		GlobalTents[id][TentY] = cache_get_field_content_float(row, "TentY");
		GlobalTents[id][TentZ] = cache_get_field_content_float(row, "TentZ");
		GlobalTents[id][Camo1] = cache_get_field_content_int(row, "Camo1");
		cache_get_field_content(row, "Camo2", GlobalTents[id][Camo2], 1, 12);
		cache_get_field_content(row, "Camo3", GlobalTents[id][Camo3], 1, 12);
		cache_get_field_content(row, "PlacedBy", GlobalTents[id][PlacedBy], 1, 25);

		if(!isnull(GlobalTents[id][PlacedBy]))
		{
			CreateTent(id);
			Iter_Add(Tent, id);
			created++;
		}
		
		id ++;
		row ++;
		
		if(row > MAX_TENTS)
			break;
	}
	
	cache_delete(cache);
	printf("Found %d tents. (Created %d)", count, created);
	return 1;
}

stock SaveTent(id)
{
	new query[1024], Cache:cache;
	
	//Check if tent exists
	mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT * FROM Tents WHERE TentSQL = %d", GlobalTents[id][TentSQL]);
	cache = mysql_query(MYSQL_MAIN, query);
	
	//If row exists, update information else create the row.
	if(cache_get_row_count() > 0)
	{
		mysql_format(MYSQL_MAIN, query, sizeof(query), "UPDATE Tents SET PlacedBy = '%e', TentX = '%f', TentY = '%f', TentZ = '%f', Camo1 = '%d', Camo2 = '%e', Camo3 = '%e' WHERE TentSQL= '%d'", \
		GlobalTents[id][PlacedBy], GlobalTents[id][TentX], GlobalTents[id][TentY], GlobalTents[id][TentZ], GlobalTents[id][Camo1], GlobalTents[id][Camo2], GlobalTents[id][Camo3], GlobalTents[id][TentSQL]);
		mysql_query(MYSQL_MAIN, query, false);
	}
	else 
	{
		cache_delete(cache);
		mysql_format(MYSQL_MAIN, query, sizeof(query), "INSERT INTO Tents (PlacedBy, TentX, TentY, TentZ, Camo1, Camo2, Camo3) VALUES ('%e', '%f', '%f', '%f', '%d', '%e', '%e')", \
		GlobalTents[id][PlacedBy], GlobalTents[id][TentX], GlobalTents[id][TentY], GlobalTents[id][TentZ], GlobalTents[id][Camo1], GlobalTents[id][Camo2], GlobalTents[id][Camo3]);
		cache = mysql_query(MYSQL_MAIN, query);
		
		GlobalTents[id][TentSQL] = cache_insert_id();
		cache_delete(cache);
	}
	
	return 1;
}