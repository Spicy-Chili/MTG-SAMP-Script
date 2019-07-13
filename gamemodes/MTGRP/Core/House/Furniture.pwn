/*
#		MTG House Furniture System
#		
#
#	By accessing this file, you agree to the following:
#		- You will never give the script or associated files to anybody who is not on the MTG SAMP development team
# 		- You will delete all development materials (script, databases, associated files, etc.) when you leave the MTG SAMP development team.
#
*/

#include <YSI\y_hooks>
 
#define FURNI_HOUSE 5526
//					5527
#define FURNI_MAIN 5528
#define FURNI_MENU 5529
#define FURNI_SELECTHOUSE 5530
#define FURNI_EDIT	5531

//#define FURNI_DEBUG "smelly rickles"

static string[768];

enum HouseFurniData
{
	Float:FurniPosX[MAX_FURNI],
	Float:FurniPosY[MAX_FURNI],
	Float:FurniPosZ[MAX_FURNI],
	Float:FurniAngX[MAX_FURNI],
	Float:FurniAngY[MAX_FURNI],
	Float:FurniAngZ[MAX_FURNI],
	FurniObject[MAX_FURNI],
	FurniObjectID[MAX_FURNI],
	FurniSQL[MAX_FURNI],
}

new HouseFurniture[MAX_HOUSES][HouseFurniData];

hook OnGameModeInit()
{
	//db_query(main_db, "CREATE TABLE IF NOT EXISTS furniture (SQL INTEGER PRIMARY KEY AUTOINCREMENT, HouseID INTEGER, FurniObject INTEGER, FurniX FLOAT DEFAULT 0.0, FurniY FLOAT DEFAULT 0.0, FurniZ FLOAT DEFAULT 0.0, FurniRotX FLOAT, FurniRotY FLOAT, FurniRotZ FLOAT)");
}

// ============= Callbacks =============

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case FURNI_MAIN:
        {
            if(!response)
                return 1;
			
			ResetString();
            new query[128];
			
			DeletePVar(playerid, "FurniPage");
			
			mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT * FROM furniturelist WHERE category = '%e'", inputtext);
			new Cache:cache = mysql_query(MYSQL_MAIN, query), count = cache_get_row_count(), idx, end;
			
			new price, vip, name[128];
			while(idx < count && end < 15)
			{
				cache_set_active(cache);
				
				price = cache_get_field_content_int(idx, "price"), vip = cache_get_field_content_int(idx, "vip");
				cache_get_field_content(idx, "name", name);
				
				format(string, sizeof(string), "%s%s | %s%s%s\n", string, name, (Player[playerid][Money] < price) ? ("{DB3232}") : ("{39A62B}"), PrettyMoney(price), (vip) ? (" | {EBCC1C}VIP") : (""));
				
				idx++;
				end++;
			}
			cache_delete(cache);
			
			if(idx < count)
				strcat(string, "Next\n");
				
			SetPVarString(playerid, "FurniCategory", inputtext);
			
            if(!strlen(string))
				format(string, sizeof(string), "An error has occured.");
			
            ShowPlayerDialog(playerid, FURNI_MENU, DIALOG_STYLE_LIST, "Furniture", string, "Select", "Cancel");
        }
        case FURNI_MENU:
        {
			if(!response)
				return 1;
			
			if(!strcmp(inputtext, "Next", true))
			{
				ResetString();
				
				SetPVarInt(playerid, "FurniPage", GetPVarInt(playerid, "FurniPage") + 1);
				
				new cat[128], query[128];
				GetPVarString(playerid, "FurniCategory", cat, 128);
				
				mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT * FROM furniturelist WHERE category = '%e'", cat);
				new Cache:cache = mysql_query(MYSQL_MAIN, query), count = cache_get_row_count(), idx = GetPVarInt(playerid, "FurniPage") * 15, end;
				
				new price, vip, name[128];
				while(idx < count && end < 15)
				{
					cache_set_active(cache);
					
					price = cache_get_field_content_int(idx, "price"), vip = cache_get_field_content_int(idx, "vip");
					cache_get_field_content(idx, "name", name);
					
					format(string, sizeof(string), "%s%s | %s%s%s\n", string, name, (Player[playerid][Money] < price) ? ("{DB3232}") : ("{39A62B}"), PrettyMoney(price), (vip) ? (" | {EBCC1C}VIP") : (""));
					
					idx++;
					end++;
				}
				cache_delete(cache);
				
				if(idx < count)
					strcat(string, "Next\n");
					
				if(GetPVarInt(playerid, "FurniPage") > 0)
					strcat(string, "Back\n");
				
				if(!strlen(string))
					format(string, sizeof(string), "An error has occured.");
				
				ShowPlayerDialog(playerid, FURNI_MENU, DIALOG_STYLE_LIST, "Furniture", string, "Select", "Cancel");
            }
			else if(!strcmp(inputtext, "Back", true))
			{
				ResetString();
				
				SetPVarInt(playerid, "FurniPage", GetPVarInt(playerid, "FurniPage") - 1);
				
				new cat[128], query[128];
				GetPVarString(playerid, "FurniCategory", cat, 128);
				
				mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT * FROM furniturelist WHERE category = '%e'", cat);
				new Cache:cache = mysql_query(MYSQL_MAIN, query), count = cache_get_row_count(), idx = GetPVarInt(playerid, "FurniPage") * 15, end;
				
				new price, vip, name[128];
				while(idx < count && end < 15)
				{
					cache_set_active(cache);
					
					price = cache_get_field_content_int(idx, "price"), vip = cache_get_field_content_int(idx, "vip");
					cache_get_field_content(idx, "name", name);
					
					format(string, sizeof(string), "%s%s | %s%s%s\n", string, name, (Player[playerid][Money] < price) ? ("{DB3232}") : ("{39A62B}"), PrettyMoney(price), (vip) ? (" | {EBCC1C}VIP") : (""));
					
					idx++;
					end++;
				}
				cache_delete(cache);
				
				if(idx < count)
					strcat(string, "Next\n");
					
				if(GetPVarInt(playerid, "FurniPage") > 0)
					strcat(string, "Back\n");
				
				if(!strlen(string))
					format(string, sizeof(string), "An error has occured.");
				
				ShowPlayerDialog(playerid, FURNI_MENU, DIALOG_STYLE_LIST, "Furniture", string, "Select", "Cancel");
			}
			else
			{
				new cat[128], query[128];
				GetPVarString(playerid, "FurniCategory", cat, 128);
				
				mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT * FROM furniturelist WHERE category = '%e'", cat);
				new Cache:cache = mysql_query(MYSQL_MAIN, query), row = GetPVarInt(playerid, "FurniPage") * 15 + listitem;
				
				new price = cache_get_field_content_int(row, "price"), vip = cache_get_field_content_int(row, "vip"), model = cache_get_field_content_int(row, "model"), name[128];
				cache_get_field_content(row, "name", name);
					
				if(Player[playerid][Money] < price)
					return SendClientMessage(playerid, -1, "You do not have enough money for this piece of furniture!");
				   
				if(vip > 0 && Player[playerid][VipRank] == 0)
					return SendClientMessage(playerid, -1, "You need to be a VIP to buy this piece of furniture!");
				   
				if(Player[playerid][House] == 0 && Player[playerid][House2] == 0)
					return SendClientMessage(playerid, -1, "You don't have a house to put the furniture in.");
			   
				new h;
				if(Player[playerid][House] == 0 && Player[playerid][House2] > 0)
					h = Player[playerid][House2];
				else if(Player[playerid][House] > 0 && Player[playerid][House2] == 0)
					h = Player[playerid][House];
				else if(Player[playerid][House] > 0 && Player[playerid][House2] > 0)
				{
					SetPVarInt(playerid, "FurniPrice", price);
					SetPVarInt(playerid, "FurniObject", model);
					return ShowPlayerDialog(playerid, FURNI_SELECTHOUSE, DIALOG_STYLE_LIST, "Furniture", "House 1\nHouse 2\n", "Select", "Cancel");
				}
				new idx = -1;
				idx = GetAvailableFurnitureSlot(h);
			   
				if(idx == -1)
					return SendClientMessage(playerid, -1, "You can't get any more furniture in your house.");
			
				format(string, sizeof(string), "You have purchased %s for %s.", name, PrettyMoney(price));
				SendClientMessage(playerid, -1, string);
				HouseFurniture[h][FurniObject][idx] = model;
				Player[playerid][Money] -= price;
				
				format(string, sizeof(string), "INSERT INTO furniture (HouseID, FurniObject) VALUES (%d, %d)", h, model);
				cache = mysql_query(MYSQL_MAIN, string);
				HouseFurniture[h][FurniSQL][idx] = cache_insert_id();
				cache_delete(cache);
			}
        }
        case FURNI_SELECTHOUSE:
        {
			if(!response)
				return 1;
				
            switch(listitem)
            {
                case 0:
                {
                    new idx = -1, h = Player[playerid][House];
                    
					idx = GetAvailableFurnitureSlot(h);
                
                    if(idx == -1)
                        return SendClientMessage(playerid, -1, "You can't get any more furniture in your house.");
					
					HouseFurniture[h][FurniObject][idx] = GetPVarInt(playerid, "FurniObject");
                    Player[playerid][Money] -= GetPVarInt(playerid, "FurniPrice");
					
					new Cache:cache;
					format(string, sizeof(string), "INSERT INTO furniture (HouseID, FurniObject) VALUES (%d, %d)", h, GetPVarInt(playerid, "FurniObject"));
					cache = mysql_query(MYSQL_MAIN, string);
					HouseFurniture[h][FurniSQL][idx] = cache_insert_id();
					cache_delete(cache);
                }
                case 1:
                {
                    new idx = -1, h = Player[playerid][House2];
					idx = GetAvailableFurnitureSlot(h);
                   
                    if(idx == -1)
                        return SendClientMessage(playerid, -1, "You can't get any more furniture in your house.");
                   
					HouseFurniture[h][FurniObject][idx] = GetPVarInt(playerid, "FurniObject");
                    Player[playerid][Money] -= GetPVarInt(playerid, "FurniPrice");
					new Cache:cache;
					format(string, sizeof(string), "INSERT INTO furniture (HouseID, FurniObject) VALUES (%d, %d)", h, GetPVarInt(playerid, "FurniObject"));
					cache = mysql_query(MYSQL_MAIN, string);
					HouseFurniture[h][FurniSQL][idx] = cache_insert_id();
					cache_delete(cache);
                }
            }
        }
		case FURNI_HOUSE:
		{
			if(!response)
				return 1;
				
			ResetString();
			new count, h = Player[playerid][InHouse];
			for(new i; i < MAX_FURNI; i++)
			{
				if(HouseFurniture[h][FurniObject][i] == 0)
					continue;
				
				if(strcmp(GetFurniCategory(HouseFurniture[h][FurniObject][i]), inputtext, true))
					continue;
					
				count++;
				if(count < 15)
					format(string, sizeof(string), "%s%s%d | %s\n", string, (IsValidDynamicObject(HouseFurniture[h][FurniObjectID][i])) ? ("{33A10B}") : ("{FF0000}"), i + 1, GetFurniName(HouseFurniture[h][FurniObject][i]));
				else
				{
					SetPVarInt(playerid, "StartingFurniID", i);
					SetPVarString(playerid, "FurniCategory", inputtext);
					format(string, sizeof(string), "%sNext Page", string);
					break;
				}
			}
			ShowPlayerDialog(playerid, FURNI_HOUSE + 1, DIALOG_STYLE_LIST, "Furniture", string, "Select", "Cancel");
		}
		case FURNI_HOUSE + 1:
		{
			if(!response)
				return 1;
			
			new h = Player[playerid][InHouse];
			
			if(!strcmp(inputtext, "Next Page", true))
			{
				ResetString();
				new count, cat[32];
				GetPVarString(playerid, "FurniCategory", cat, sizeof(cat));
				for(new i = GetPVarInt(playerid, "StartingFurniID"); i < MAX_FURNI; i++)
				{
					if(HouseFurniture[h][FurniObject][i] == 0)
						continue;
					
					if(strcmp(GetFurniCategory(HouseFurniture[h][FurniObject][i]), cat, true))
						continue;
					
					count++;
					if(count < 15)
						format(string, sizeof(string), "%s%s%d | %s\n", string, (IsValidDynamicObject(HouseFurniture[h][FurniObjectID][i])) ? ("{33A10B}") : ("{FF0000}"), i + 1, GetFurniName(HouseFurniture[h][FurniObject][i]));
					else
					{
						SetPVarInt(playerid, "StartingFurniID", i);
						format(string, sizeof(string), "%sNext Page", string);
						break;
					}
				}
				
				if(!strlen(string))
					format(string, sizeof(string), "No furniture to list.");
				
				ShowPlayerDialog(playerid, FURNI_HOUSE, DIALOG_STYLE_LIST, "Furniture", string, "Select", "Cancel");
				return 1;
			}
			
			format(string, sizeof(string), "%s", inputtext);
			new idx = strval(CutBeforeLine(string)) - 1;
			
			SetPVarInt(playerid, "FurniEditIDX", idx);
			
			if(IsValidDynamicObject(HouseFurniture[h][FurniObjectID][idx]))
				format(string, sizeof(string), "Store\nMove\nReset Position\nDelete");
			else format(string, sizeof(string), "Place\nReset Position\nDelete");
			ShowPlayerDialog(playerid, FURNI_EDIT, DIALOG_STYLE_LIST, "Choose an option", string, "Select", "Cancel");
		}
		case FURNI_EDIT:
		{
			if(!response)
				return 1;
				
			new idx = GetPVarInt(playerid, "FurniEditIDX");
			new h = Player[playerid][InHouse];
			
			if(!strcmp(inputtext, "Place", true))
			{
				//idx = GetAvailableFurnitureObjectSlot(h);
				
				//if(idx == -1)
					//return SendClientMessage(playerid, -1, "You don't have anymore room for furniture!");
				
				if(HouseFurniture[h][FurniPosX][idx] == 0.0 && HouseFurniture[h][FurniPosY][idx] == 0.0 && HouseFurniture[h][FurniPosZ][idx] == 0.0)
				{
					new Float:pPos[3];
					GetPlayerPos(playerid, pPos[0], pPos[1], pPos[2]);
					HouseFurniture[h][FurniPosX][idx] = pPos[0] + 1;
					HouseFurniture[h][FurniPosY][idx] = pPos[1] + 1;
					HouseFurniture[h][FurniPosZ][idx] = pPos[2] + 1;
				}
				
				HouseFurniture[h][FurniObjectID][idx] = CreateDynamicObject(HouseFurniture[h][FurniObject][idx], HouseFurniture[h][FurniPosX][idx], HouseFurniture[h][FurniPosY][idx], HouseFurniture[h][FurniPosZ][idx], HouseFurniture[h][FurniAngX][idx], HouseFurniture[h][FurniAngY][idx], HouseFurniture[h][FurniAngZ][idx], .worldid = GetPlayerVirtualWorld(playerid), .interiorid = -1);
				Streamer_Update(playerid);
				EditDynamicObject(playerid, HouseFurniture[h][FurniObjectID][idx]);
				SendClientMessage(playerid, YELLOW, "Warning: Don't exit your house while editing furniture.");
				SetPVarInt(playerid, "PlacingFurniture", 1);
				SetPVarInt(playerid, "FurniHouse", h);
			}
			else if(!strcmp(inputtext, "Store", true))
			{
				DestroyDynamicObject(HouseFurniture[h][FurniObjectID][idx]);
				HouseFurniture[h][FurniObjectID][idx] = INVALID_OBJECT_ID;
			}
			else if(!strcmp(inputtext, "Delete", true))
			{
				DeleteFurni(Player[playerid][InHouse], idx);
				SendClientMessage(playerid, -1, "You have deleted your furniture.");
			}
			else if(!strcmp(inputtext, "Move", true))
			{
				SetPVarInt(playerid, "PlacingFurniture", 1);
				SendClientMessage(playerid, YELLOW, "Warning: Don't exit your house while editing furniture.");
				EditDynamicObject(playerid, HouseFurniture[h][FurniObjectID][idx]);
			}
			else if(!strcmp(inputtext, "Reset Position", true))
			{	
				if(IsValidDynamicObject(HouseFurniture[h][FurniObjectID][idx]))
					DestroyDynamicObject(HouseFurniture[h][FurniObjectID][idx]);
				
				new Float:pPos[3];
				GetPlayerPos(playerid, pPos[0], pPos[1], pPos[2]);
				HouseFurniture[h][FurniPosX][idx] = pPos[0] + 1;
				HouseFurniture[h][FurniPosY][idx] = pPos[1] + 1;
				HouseFurniture[h][FurniPosZ][idx] = pPos[2] + 1;
				HouseFurniture[h][FurniObjectID][idx] = CreateDynamicObject(HouseFurniture[h][FurniObject][idx], HouseFurniture[h][FurniPosX][idx], HouseFurniture[h][FurniPosY][idx], HouseFurniture[h][FurniPosZ][idx], HouseFurniture[h][FurniAngX][idx], HouseFurniture[h][FurniAngY][idx], HouseFurniture[h][FurniAngZ][idx], .worldid = GetPlayerVirtualWorld(playerid), .interiorid = -1);
				Streamer_Update(playerid);
				EditDynamicObject(playerid, HouseFurniture[h][FurniObjectID][idx]);
				SendClientMessage(playerid, WHITE, "You have reset the furniture object's position.");
				SetPVarInt(playerid, "PlacingFurniture", 1);
				SetPVarInt(playerid, "FurniHouse", h);
			}
		}
	}
	return 1;
}

hook OnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	if(GetPVarInt(playerid, "PlacingFurniture") == 1)
	{
		new Float:oldX, Float:oldY, Float:oldZ, Float:oldRX, Float:oldRY, Float:oldRZ;
		GetDynamicObjectPos(objectid, oldX, oldY, oldZ);
		GetDynamicObjectRot(objectid, oldRX, oldRY, oldRZ);
		
		new idx = -1, h = GetPVarInt(playerid, "FurniHouse");
		for(new i; i < MAX_FURNI; i++)
		{
			if(HouseFurniture[h][FurniObjectID][i] == objectid)
			{
				idx = i;
				break;
			}
		}
		
		if(idx == -1)
			return SendClientMessage(playerid, -1, "An unexpected error occured.");
			
		MoveDynamicObject(objectid, x, y, z, 10, rx, ry, rz);
		
		if(IsValidDynamic3DTextLabel(Player[playerid][FurniLabels][idx]) && GetPVarInt(playerid, "SeesFurniLabels") == 1)
		{
			DestroyDynamic3DTextLabel(Player[playerid][FurniLabels][idx]);
			format(string, sizeof(string), "Furni ID: %d", idx);
			Player[playerid][FurniLabels][idx] = CreateDynamic3DTextLabel(string, GREEN, x, y, z, 200, .playerid = playerid);
			Streamer_Update(playerid);
		}
		
		if(response == EDIT_RESPONSE_FINAL)
		{
			HouseFurniture[h][FurniPosX][idx] = x;
			HouseFurniture[h][FurniPosY][idx] = y;
			HouseFurniture[h][FurniPosZ][idx] = z;
			HouseFurniture[h][FurniAngX][idx] = rx;
			HouseFurniture[h][FurniAngY][idx] = ry;
			HouseFurniture[h][FurniAngZ][idx] = rz;
			SaveHouseFurni(h, idx);
			SendClientMessage(playerid, -1, "You have successfully placed your furniture.");
			DeletePVar(playerid, "PlacingFurniture");
		}
		
		if(response == EDIT_RESPONSE_CANCEL)
		{
			DeletePVar(playerid, "PlacingFurniture");
			SetDynamicObjectPos(objectid, oldX, oldY, oldZ);
			SetDynamicObjectRot(objectid, oldRX, oldRY, oldRZ);
		}
	}
	return 1;
}

// ============= Commands =============

CMD:furnitureids(playerid, params[])
{
	if(Player[playerid][InHouse] != Player[playerid][House] && Player[playerid][InHouse] != Player[playerid][House2])
		return SendClientMessage(playerid, -1, "You must be inside a house you own to see furniture IDs.");
	
	new h = Player[playerid][InHouse];
	
	switch(GetPVarInt(playerid, "SeesFurniLabels"))
	{
		case 0:
		{
			for(new i; i < MAX_FURNI; i++)
			{
				if(IsValidDynamicObject(HouseFurniture[h][FurniObjectID][i]))
				{
					format(string, sizeof(string), "Furni ID: %d", i);
					Player[playerid][FurniLabels][i] = CreateDynamic3DTextLabel(string, GREEN, HouseFurniture[h][FurniPosX], HouseFurniture[h][FurniPosY], HouseFurniture[h][FurniPosZ], 200, .playerid = playerid);
				}
			}
			Streamer_Update(playerid);
			SetPVarInt(playerid, "SeesFurniLabels", 1);
		}
		case 1:
		{
			for(new i; i < MAX_FURNI; i++)
			{
				if(IsValidDynamic3DTextLabel(Player[playerid][FurniLabels][i]))
					DestroyDynamic3DTextLabel(Player[playerid][FurniLabels][i]);
			}
			Streamer_Update(playerid);
			DeletePVar(playerid, "SeesFurniLabels");
		}
	}	
	return 1;
}

CMD:buyfurni(playerid)
{
	if(!IsPlayerInRangeOfPoint(playerid, 1.5, Businesses[Player[playerid][InBusiness]][bInteractX], Businesses[Player[playerid][InBusiness]][bInteractY], Businesses[Player[playerid][InBusiness]][bInteractZ]) && Player[playerid][InBusiness] != 0)
		return SendClientMessage(playerid, GREY, "You must stand near the interaction point to do this.");
	
	if(Businesses[Player[playerid][InBusiness]][bType] != 22)
		return SendClientMessage(playerid, -1, "You must be in a furniture store to buy furniture.");
	
	ResetString();
	
	new Cache:cache = mysql_query(MYSQL_MAIN, "SELECT * FROM furniturelist GROUP BY category"), count = cache_get_row_count(), idx;
	
	if(count == 0)
	{
		cache_delete(cache);
		return SendClientMessage(playerid, WHITE, "There seems to be no furniture listed in our database!");
	}
	
	new cat[128];
	while(idx < count)
	{
		cache_set_active(cache);
		
		cache_get_field_content(idx, "category", cat);
		format(string, sizeof(string), "%s%s\n", string, cat);
		
		idx++;
	}
	cache_delete(cache);
	
	ShowPlayerDialog(playerid, FURNI_MAIN, DIALOG_STYLE_LIST, "Furniture", string, "Select", "Cancel");
	return 1;
}

CMD:editfurni(playerid, params[])
{
	if(Player[playerid][InHouse] == 0)
		return SendClientMessage(playerid, -1, "You must be inside a house you own to place furniture.");
	
	if(!PlayerHasHouseKey(playerid, Player[playerid][InHouse]) && Player[playerid][InHouse] != GetPVarInt(playerid, "INTERIOR_DESIGN_HOUSEID"))
		return SendClientMessage(playerid, -1, "You must be inside a house you own to place furniture.");
	
	new h = Player[playerid][InHouse];
	
	ResetString();
	new cat[32];
	for(new i; i < MAX_FURNI; i++)
	{
		if(HouseFurniture[h][FurniObject][i] == 0)
			continue;
		/*count++;
		if(count < 15)
			format(string, sizeof(string), "%s%d | %s\n", string, i + 1, GetFurniName(HouseFurniture[h][FurniObject][i]));
		else
		{
			SetPVarInt(playerid, "StartingFurniID", i);
			format(string, sizeof(string), "%sNext Page", string);
			break;
		}*/
		cat[0] = EOS;
		strcat(cat, GetFurniCategory(HouseFurniture[h][FurniObject][i]));
		if(strfind(string, cat, true) != -1)
			continue;
		
		format(string, sizeof(string), "%s%s\n", string, cat);
    }
	
	if(strlen(string) < 1)
		format(string, sizeof(string), "You don't have any furniture!");
	
    ShowPlayerDialog(playerid, FURNI_HOUSE, DIALOG_STYLE_LIST, "Furniture", string, "Select", "Cancel");
	return 1;
}

CMD:interiordesign(playerid, params[])
{
	if(Player[playerid][InHouse] == 0)
		return 1;
	
	if(!PlayerHasHouseKey(playerid, Player[playerid][InHouse]))
		return SendClientMessage(playerid, WHITE, "You must be inside a house you own to use this command.");
	
	new pid;
	if(sscanf(params, "u", pid))
		return SendClientMessage(playerid, WHITE, "SYNTAX: /interiordesign [playerid]");
		
	if(!IsPlayerConnected(pid))
		return SendClientMessage(playerid, WHITE, "That player isn't connected.");
	new hID = GetPVarInt(pid, "INTERIOR_DESIGN_HOUSEID");
	
	if(hID != 0 && hID != Player[playerid][InHouse])
		return SendClientMessage(playerid, WHITE, "That player is currently designing another house.");
		
	if(hID == 0)
	{
		SetPVarInt(pid, "INTERIOR_DESIGN_HOUSEID", Player[playerid][InHouse]);
		format(string, sizeof(string), "You are now allowing %s to edit your furniture.", GetName(pid));
		SendClientMessage(playerid, WHITE, string);
		format(string, sizeof(string), "You are now allowed to edit %s's house furniture in house %d.", GetName(playerid), Player[playerid][InHouse]);
		SendClientMessage(pid, WHITE, string);
	}
	else 
	{
		DeletePVar(pid, "INTERIOR_DESIGN_HOUSEID");
		format(string, sizeof(string), "You have revoked %s's permission to edit your house furniture.", GetName(pid));
		SendClientMessage(playerid, WHITE, string);
		format(string, sizeof(string), "%s has revoked your permission to edit furninture their house.", GetName(playerid));
		SendClientMessage(pid, WHITE, string);
	}
	return 1;
}
// ============= Functions =============

stock SaveHouseFurni(h, idx)
{
	if(HouseFurniture[h][FurniObject][idx] != 0)
	{
		format(string, sizeof(string), "UPDATE furniture SET FurniObject = '%d', FurniX = '%f', FurniY = '%f', FurniZ = '%f', FurniRotX = '%f', FurniRotY = '%f', FurniRotZ = '%f' WHERE SQLID = '%d'", \
		HouseFurniture[h][FurniObject][idx], HouseFurniture[h][FurniPosX][idx], HouseFurniture[h][FurniPosY][idx], HouseFurniture[h][FurniPosZ][idx],HouseFurniture[h][FurniAngX][idx], HouseFurniture[h][FurniAngY][idx], HouseFurniture[h][FurniAngZ][idx], HouseFurniture[h][FurniSQL][idx]);
		mysql_query(MYSQL_MAIN, string, false);
	}
	return 1;
}

stock LoadHouseFurni(h)
{
	new Cache:cache, count;
	format(string, sizeof(string), "SELECT * FROM furniture WHERE HouseID = '%d'", h);
	cache = mysql_query(MYSQL_MAIN, string);
	count = cache_get_row_count();
	
	new idx;
	if(count > 0)
	{
		for(new i; i < count; i++)
		{
			idx = GetAvailableFurnitureSlot(h);
			
			if(idx == -1 || i > MAX_FURNI)
				break;
			
			HouseFurniture[h][FurniObject][idx] = cache_get_field_content_int(i, "FurniObject");
			HouseFurniture[h][FurniPosX][idx] = cache_get_field_content_float(i, "FurniX");
			HouseFurniture[h][FurniPosY][idx] = cache_get_field_content_float(i, "FurniY");
			HouseFurniture[h][FurniPosZ][idx] = cache_get_field_content_float(i, "FurniZ");
			HouseFurniture[h][FurniAngX][idx] = cache_get_field_content_float(i, "FurniRotX");
			HouseFurniture[h][FurniAngY][idx] = cache_get_field_content_float(i, "FurniRotY");
			HouseFurniture[h][FurniAngZ][idx] = cache_get_field_content_float(i, "FurniRotZ");
			HouseFurniture[h][FurniSQL][idx] = cache_get_field_content_int(i, "SQLID");
			
			if(HouseFurniture[h][FurniPosX][idx] != 0.0 && HouseFurniture[h][FurniPosY][idx] != 0.0 && HouseFurniture[h][FurniPosZ][idx] != 0.0)
				HouseFurniture[h][FurniObjectID][idx] = CreateDynamicObject(HouseFurniture[h][FurniObject][idx], HouseFurniture[h][FurniPosX][idx], HouseFurniture[h][FurniPosY][idx], HouseFurniture[h][FurniPosZ][idx], HouseFurniture[h][FurniAngX][idx], HouseFurniture[h][FurniAngY][idx], HouseFurniture[h][FurniAngZ][idx], .worldid = 55000 + h, .interiorid = -1);
			
		}
	}
	cache_delete(cache);
	if(count > 0)
		printf("[system] Loaded %d pieces of furniture for house %d.", count, h);
	return 1;
}

stock DeleteFurni(houseid, idx) // So we can adjust everything so there is no empty places in the array
{
	
	if(IsValidDynamicObject(HouseFurniture[houseid][FurniObjectID][idx]))
		DestroyDynamicObject(HouseFurniture[houseid][FurniObjectID][idx]);
	
	HouseFurniture[houseid][FurniObjectID][idx] = INVALID_OBJECT_ID;
	HouseFurniture[houseid][FurniObject][idx] = 0;
	HouseFurniture[houseid][FurniPosX] = 0.0;
	HouseFurniture[houseid][FurniPosY] = 0.0;
	HouseFurniture[houseid][FurniPosZ] = 0.0;
	format(string, sizeof(string), "DELETE FROM furniture WHERE SQLID = '%d'", HouseFurniture[houseid][FurniSQL][idx]);
	mysql_query(MYSQL_MAIN, string, false);
	return 1;
}

stock GetAvailableFurnitureSlot(houseid) //For storing object id as in the 19038 in CreateObject(19038...
{
	new idx = -1;
	for(new i; i < MAX_FURNI; i++)
	{
		if(HouseFurniture[houseid][FurniObject][i] == 0)
		{
			idx = i;
			break;
		}
	}
	return idx;
}

stock GetAvailableFurnitureObjectSlot(houseid) //For actual object as in what CreateObject... returns
{
	new idx = -1;
	for(new i; i < MAX_FURNI; i++)
	{
		if(HouseFurniture[houseid][FurniObjectID][i] == INVALID_OBJECT_ID || HouseFurniture[houseid][FurniObjectID][i] == 0)
		{
			idx = i;
			break;
		}
	}
	return idx;
}

stock GetFurniName(objectid)
{
	new query[128];
	mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT name FROM furniturelist WHERE model = '%d'", objectid);
	new Cache:cache = mysql_query(MYSQL_MAIN, query);
	
	new name[64];
	cache_get_field_content(0, "name", name);
	cache_delete(cache);
	return name;
}

stock GetFurniCategory(objectid)
{
	new query[128];
	mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT category FROM furniturelist WHERE model = '%d'", objectid);
	new Cache:cache = mysql_query(MYSQL_MAIN, query);
	
	new category[64];
	cache_get_field_content(0, "category", category);
	cache_delete(cache);
	return category;
}

static stock ResetString()
{
	string[0] = '\0';
	return 1;
}