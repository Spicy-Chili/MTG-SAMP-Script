/*
#		MTG Storage
#
#
#	By accessing this file, you agree to the following:
#		- You will never give the script or associated files to anybody who is not on the MTG SAMP development team
# 		- You will delete all development materials (script, databases, associated files, etc.) when you leave the MTG SAMP development team.
#
#
#
*/

/* Database Schema

Table : storage


container_id
container_type
item_type
item_amount //When dealing with weapons, item_amount should be the weapon id


*/

#define CONTAINER_TYPE_HOUSE    1
#define CONTAINER_TYPE_BIZ      2
#define CONTAINER_TYPE_VEH      3
#define CONTAINER_TYPE_FACTION  4
#define CONTAINER_TYPE_GANG     5
#define CONTAINER_TYPE_TENT 	6

#define ITEM_TYPE_NONE          0
#define ITEM_TYPE_CASH          1
#define ITEM_TYPE_POT           2
#define ITEM_TYPE_COCAINE       3
#define ITEM_TYPE_SPEED         4
#define ITEM_TYPE_POOR_MATS     5
#define ITEM_TYPE_GOOD_MATS     6
#define ITEM_TYPE_GREAT_MATS    7
#define ITEM_TYPE_WEAPON        8
#define ITEM_TYPE_GAS_CAN       9
#define ITEM_TYPE_POT_SEED		10
#define ITEM_TYPE_ARMOUR_POOR 	11
#define ITEM_TYPE_ARMOUR_STANDARD 	12
#define ITEM_TYPE_ARMOUR_MILITARY 	13
#define ITEM_TYPE_BOMB 14
#define ITEM_TYPE_TENT 15


static query[1024], string[1024];

/*CMD:addtostorage(playerid, params[])
{
  new container_id, container_type, item_type, item_amount;
  if(sscanf(params, "dddd", container_id, container_type, item_type, item_amount))
    return SendClientMessage(playerid, WHITE, "container_id, container_type, item_type, item_amount");

  AddToStorage(container_id, container_type, item_type, item_amount);
  SendClientMessage(playerid, WHITE, "Done");
  return 1;
}

CMD:removefromstorage(playerid, params[])
{
  new container_id, container_type, item_type, item_amount;
  if(sscanf(params, "dddd", container_id, container_type, item_type, item_amount))
    return SendClientMessage(playerid, WHITE, "container_id, container_type, item_type, item_amount");

  RemoveFromStorage(container_id, container_type, item_type, item_amount);
  SendClientMessage(playerid, WHITE, "Done");
  return 1;
}

CMD:weightcontainer(playerid, params[])
{
  new container_id, container_type;
  if(sscanf(params, "dd", container_id, container_type))
    return SendClientMessage(playerid, WHITE, "container_id, container_type");

  format(string, sizeof(string), "Result: %d", CalculateContainerWeight(container_id, container_type));
  SendClientMessage(playerid, WHITE, string);
  return 1;
}

CMD:weightitem(playerid, params[])
{
  new item_type, item_amount;
  if(sscanf(params, "dd", item_type, item_amount))
    return SendClientMessage(playerid, WHITE, "item_type, item_amount");

  format(string, sizeof(string), "Result: %d", GetItemWeight(item_type, item_amount));
  SendClientMessage(playerid, WHITE, string);
  return 1;
}

CMD:getstring(playerid, params[])
{
  new container_id, container_type;
  if(sscanf(params, "dd", container_id, container_type))
    return SendClientMessage(playerid, WHITE, "container_id, container_type");

  ShowPlayerDialog(playerid, 669, DIALOG_STYLE_LIST, "Container Test", GetStorageString(container_id, container_type), "Rickles", "Smells");
  return 1;
}*/

stock AddToStorage(container_id, container_type, item_type, item_amount)
{
  new Cache:cache;

  format(query, sizeof(query), "AddToStorage called container_id = %d, container_type = %d, item_type = %d, item_amount = %d", container_id, container_type, item_type, item_amount);
  StorageLog(query);

  mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT * FROM storage WHERE container_id = '%d' AND container_type = '%d' AND item_type = '%d'", container_id, container_type, item_type);
  cache = mysql_query(MYSQL_MAIN, query);

  if(!cache_get_row_count() || item_type == ITEM_TYPE_WEAPON)
  {
    mysql_format(MYSQL_MAIN, query, sizeof(query), "INSERT INTO storage (container_id, container_type, item_type, item_amount) VALUES (%d, %d, %d, %d)", container_id, container_type, item_type, item_amount);
    mysql_query(MYSQL_MAIN, query, false);
  }
  else
  {
    item_amount += cache_get_field_content_int(0, "item_amount");

    mysql_format(MYSQL_MAIN, query, sizeof(query), "UPDATE storage SET item_amount = '%d' WHERE container_id = '%d' AND container_type = '%d' AND item_type = '%d'", item_amount, container_id, container_type, item_type);
    mysql_query(MYSQL_MAIN, query, false);
  }
  cache_delete(cache);
  return 1;
}

stock RemoveFromStorage(container_id, container_type, item_type, item_amount)
{
  new Cache:cache;
  format(query, sizeof(query), "RemoveFromSTorage called container_id = %d, container_type = %d, item_type = %d, item_amount = %d", container_id, container_type, item_type, item_amount);
  StorageLog(query);

  if(item_type != ITEM_TYPE_WEAPON)
    mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT * FROM storage WHERE container_id = '%d' AND container_type = '%d' AND item_type = '%d'", container_id, container_type, item_type);
  else mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT * FROM storage WHERE container_id = '%d' AND container_type = '%d' AND item_type = '%d' AND item_amount = '%d'", container_id, container_type, item_type, item_amount);

  cache = mysql_query(MYSQL_MAIN, query);

  if(!cache_get_row_count())
  {
    StorageLog("Attempted to remove item that does not exist in the database.");
    return 0;
  }
  else
  {
    new new_item_amount = cache_get_field_content_int(0, "item_amount");
    new_item_amount -= item_amount;

    if(new_item_amount <= 0 || item_type == ITEM_TYPE_WEAPON)
    {
      if(item_type == ITEM_TYPE_WEAPON)
        mysql_format(MYSQL_MAIN, query, sizeof(query), "DELETE FROM storage WHERE container_id = '%d' AND container_type = '%d' AND item_type = '%d' AND item_amount = '%d' LIMIT 1", container_id, container_type, item_type, item_amount);
      else mysql_format(MYSQL_MAIN, query, sizeof(query), "DELETE FROM storage WHERE container_id = '%d' AND container_type = '%d' AND item_type = '%d'", container_id, container_type, item_type);

      mysql_query(MYSQL_MAIN, query, false);
    }
    else
    {
      mysql_format(MYSQL_MAIN, query, sizeof(query), "UPDATE storage SET item_amount = '%d' WHERE container_id = '%d' AND container_type = '%d' AND item_type = '%d'", new_item_amount, container_id, container_type, item_type);
      mysql_query(MYSQL_MAIN, query, false);
    }
  }
  cache_delete(cache);
  return 1;
}

stock IsItemInStorage(container_id, container_type, item_type, item_amount, return_db_value = 0)
{
  new Cache:cache, return_value = 0;
  if(item_type == ITEM_TYPE_WEAPON)
    mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT * FROM storage WHERE container_id = '%d' AND container_type = '%d' AND item_type = '%d' and item_amount = '%d'", container_id, container_type, item_type, item_amount);
  else mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT * FROM storage WHERE container_id = '%d' AND container_type = '%d' AND item_type = '%d'", container_id, container_type, item_type);

  cache = mysql_query(MYSQL_MAIN, query);

  if(cache_get_row_count() < 1)
  {
    cache_delete(cache);
    return return_value; //Nothing found in the database;
  }

  new db_item_amount = cache_get_field_content_int(0, "item_amount");
  if((item_amount > db_item_amount) && item_type != ITEM_TYPE_WEAPON) //If the amount in the database is less than the amount we are looking for, return the database value.
    return_value = db_item_amount;
  else return_value = item_amount;
	
  if(return_db_value == 1)
	return_value = db_item_amount;

  cache_delete(cache);
  return return_value;
}

stock CalculateContainerWeight(container_id, container_type)
{
  new weight = 0, Cache:cache;
  mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT * FROM storage WHERE container_id = %d AND container_type = %d", container_id, container_type);
  cache = mysql_query(MYSQL_MAIN, query);

  new idx, rows = cache_get_row_count();

  while(idx < rows)
  {
    new item_type, item_amount;
    item_type = cache_get_field_content_int(idx, "item_type");
    item_amount = cache_get_field_content_int(idx, "item_amount");
    weight += GetItemWeight(item_type, item_amount);
    idx ++;
  }
  cache_delete(cache);
  return weight;
}

stock AddItemToPlayer(playerid, item_type, item_amount)
{
	switch(item_type)
	{
		case ITEM_TYPE_CASH: Player[playerid][Money] += item_amount;
		case ITEM_TYPE_POT: Player[playerid][Pot] += item_amount;
		case ITEM_TYPE_COCAINE: Player[playerid][Cocaine] += item_amount;
		case ITEM_TYPE_SPEED: Player[playerid][Speed] += item_amount;
		case ITEM_TYPE_POOR_MATS: Player[playerid][Materials][0] += item_amount;
		case ITEM_TYPE_GOOD_MATS: Player[playerid][Materials][1] += item_amount;
		case ITEM_TYPE_GREAT_MATS: Player[playerid][Materials][2] += item_amount;
		case ITEM_TYPE_WEAPON: GivePlayerWeaponEx(playerid, item_amount);
		case ITEM_TYPE_GAS_CAN: Player[playerid][GasCans] = 1;
		case ITEM_TYPE_POT_SEED: Player[playerid][PotSeeds] += item_amount;
		case ITEM_TYPE_ARMOUR_POOR: Player[playerid][HasArmour] = 100;
		case ITEM_TYPE_ARMOUR_STANDARD: Player[playerid][HasArmour] = 115;
		case ITEM_TYPE_ARMOUR_MILITARY: Player[playerid][HasArmour] = 130;
		case ITEM_TYPE_BOMB: Player[playerid][Bomb] = 1;
		case ITEM_TYPE_TENT: Player[playerid][Tent] = 1;
	}
	return 1;
}

stock GetPlayerItemAmount(playerid, item_type)
{
    if(item_type == ITEM_TYPE_CASH)
       return  Player[playerid][Money];
    else if(item_type == ITEM_TYPE_POT)
       return  Player[playerid][Pot];
    else if(item_type == ITEM_TYPE_COCAINE)
       return  Player[playerid][Cocaine];
    else if(item_type == ITEM_TYPE_SPEED)
       return  Player[playerid][Speed];
    else if(item_type == ITEM_TYPE_POOR_MATS)
       return  Player[playerid][Materials][0];
    else if(item_type == ITEM_TYPE_GOOD_MATS)
       return  Player[playerid][Materials][1];
    else if(item_type == ITEM_TYPE_GREAT_MATS)
       return  Player[playerid][Materials][2];
    else if(item_type == ITEM_TYPE_GAS_CAN)
       return  Player[playerid][GasCans];
    else if(item_type == ITEM_TYPE_POT_SEED)
       return  Player[playerid][PotSeeds];
	else if(item_type == ITEM_TYPE_ARMOUR_POOR || item_type == ITEM_TYPE_ARMOUR_STANDARD || item_type == ITEM_TYPE_ARMOUR_MILITARY)
	   return  Player[playerid][HasArmour];
	else if(item_type == ITEM_TYPE_BOMB)
	   return Player[playerid][Bomb];
	else if(item_type == ITEM_TYPE_TENT)
	   return Player[playerid][Tent];
    return 0;
}


stock RemoveItemFromPlayer(playerid, item_type, item_amount)
{
	switch(item_type)
	{
		case ITEM_TYPE_CASH: Player[playerid][Money] -= item_amount;
		case ITEM_TYPE_POT: Player[playerid][Pot] -= item_amount;
		case ITEM_TYPE_COCAINE: Player[playerid][Cocaine] -= item_amount;
		case ITEM_TYPE_SPEED: Player[playerid][Speed] -= item_amount;
		case ITEM_TYPE_POOR_MATS: Player[playerid][Materials][0] -= item_amount;
		case ITEM_TYPE_GOOD_MATS: Player[playerid][Materials][1] -= item_amount;
		case ITEM_TYPE_GREAT_MATS: Player[playerid][Materials][2] -= item_amount;
		case ITEM_TYPE_WEAPON: AdjustWeapon(playerid, item_amount, 0);
		case ITEM_TYPE_GAS_CAN: Player[playerid][GasCans] = 0;
		case ITEM_TYPE_POT_SEED: Player[playerid][PotSeeds] -= item_amount;
		case ITEM_TYPE_ARMOUR_POOR: Player[playerid][HasArmour] = 0;
		case ITEM_TYPE_ARMOUR_STANDARD: Player[playerid][HasArmour] = 0;
		case ITEM_TYPE_ARMOUR_MILITARY: Player[playerid][HasArmour] = 0;
		case ITEM_TYPE_BOMB: Player[playerid][Bomb] = 0;
		case ITEM_TYPE_TENT: Player[playerid][Tent] = 0;
	}
	return 1;
}

stock GetStorageString(container_id, container_type)
{
	new Cache:cache;
	mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT * FROM storage WHERE container_id = '%d' AND container_type = '%d'", container_id, container_type);
	cache = mysql_query(MYSQL_MAIN, query);

	new idx, rows = cache_get_row_count(), weapon_amounts[47];
	string[0] = EOS;
	while(idx < rows)
	{
		new item_type, item_amount;
		item_type = cache_get_field_content_int(idx, "item_type");
		item_amount = cache_get_field_content_int(idx, "item_amount");

		if(item_type != ITEM_TYPE_WEAPON)
		{
			format(string, sizeof(string), "%s%s - %s\n", string, IntToFormattedStr(item_amount), GetItemName(item_type));
		}
		else
		{
			weapon_amounts[item_amount]++;
		}

		idx ++;
	}

	for(new i; i < sizeof(weapon_amounts); i++)
	{
		if(weapon_amounts[i] > 0)
		{
			format(string, sizeof(string), "%s%s - %s\n", string, IntToFormattedStr(weapon_amounts[i]), weapons[i]);
		}
	}

	if(isnull(string))
		format(string, sizeof(string), "Nothing found in storage.");

	cache_delete(cache);
	return string;
}

stock GetContainerTypeName(container_type)
{
	new name[25];
	switch(container_type)
	{
		case CONTAINER_TYPE_HOUSE: format(name, sizeof(name), "House");
		case CONTAINER_TYPE_BIZ: format(name, sizeof(name), "Business");
		case CONTAINER_TYPE_VEH: format(name, sizeof(name), "Vehicle");
		case CONTAINER_TYPE_FACTION: format(name, sizeof(name), "Faction");
		case CONTAINER_TYPE_GANG: format(name, sizeof(name), "Gang");
	}
	return name;
}

stock GetItemName(item_type)
{
	new name[25];
	switch(item_type)
	{
		case ITEM_TYPE_CASH: format(name, sizeof(name), "Money");
		case ITEM_TYPE_POT: format(name, sizeof(name), "Pot");
		case ITEM_TYPE_COCAINE: format(name, sizeof(name), "Cocaine");
		case ITEM_TYPE_SPEED: format(name, sizeof(name), "Speed");
		case ITEM_TYPE_POOR_MATS: format(name, sizeof(name), "Street Grade Materials");
		case ITEM_TYPE_GOOD_MATS: format(name, sizeof(name), "Standard Grade Materials");
		case ITEM_TYPE_GREAT_MATS: format(name, sizeof(name), "Military Grade Materials");
		case ITEM_TYPE_WEAPON: format(name, sizeof(name), "Weapon");
		case ITEM_TYPE_GAS_CAN: format(name, sizeof(name), "GasCan");
		case ITEM_TYPE_POT_SEED: format(name, sizeof(name), "PotSeeds");
		case ITEM_TYPE_ARMOUR_POOR: format(name, sizeof(name), "Poor Kevlar");
		case ITEM_TYPE_ARMOUR_STANDARD: format(name, sizeof(name), "Standard Kevlar");
		case ITEM_TYPE_ARMOUR_MILITARY: format(name, sizeof(name), "Military Kevlar");
		case ITEM_TYPE_BOMB: format(name, sizeof(name), "Bomb");
		case ITEM_TYPE_TENT: format(name, sizeof(name), "Tent");
	}
	return name;
}

stock GetItemTypeFromName(name[])
{
	if(!strcmp(name, "Money", true))
		return ITEM_TYPE_CASH;
	else if(!strcmp(name, "Pot", true))
		return ITEM_TYPE_POT;
	else if(!strcmp(name, "Cocaine", true))
		return ITEM_TYPE_COCAINE;
	else if(!strcmp(name, "Speed", true))
		return ITEM_TYPE_SPEED;
	else if(!strcmp(name, "Street Grade Materials", true) || !strcmp(name, "streetmats", true))
		return ITEM_TYPE_POOR_MATS;
	else if(!strcmp(name, "Standard Grade Materials", true) || !strcmp(name, "standardmats", true))
		return ITEM_TYPE_GOOD_MATS;
	else if(!strcmp(name, "Military Grade Materials", true) || !strcmp(name, "militarymats", true))
		return ITEM_TYPE_GREAT_MATS;
	else if(!strcmp(name, "Weapon", true))
		return ITEM_TYPE_WEAPON;
	else if(!strcmp(name, "GasCan", true))
		return ITEM_TYPE_GAS_CAN;
	else if(!strcmp(name, "PotSeeds", true)) 
		return ITEM_TYPE_POT_SEED;
	else if(IsWeapon(name))
		return ITEM_TYPE_WEAPON;
	else if(!strcmp(name, "Poor Kevlar", true) || !strcmp(name, "poorkevlar", true))
		return ITEM_TYPE_ARMOUR_POOR;
	else if(!strcmp(name, "Standard Kevlar", true) || !strcmp(name, "standardkevlar", true))
		return ITEM_TYPE_ARMOUR_STANDARD;
	else if(!strcmp(name, "Military Kevlar", true) || !strcmp(name, "militarykevlar", true))
		return ITEM_TYPE_ARMOUR_MILITARY;
	else if(!strcmp(name, "Bomb", true))
		return ITEM_TYPE_BOMB;
	else if(!strcmp(name, "tent", true))
		return ITEM_TYPE_TENT;
	return ITEM_TYPE_NONE;
}

static stock IsWeapon(input[])
{
	for(new i; i < 47; i++)
	{
		if(!strcmp(input, weapons[i]))
		{
			return 1;
		}
	}
	return 0;
}

stock GetItemWeight(item_type, item_amount)
{
    new weight;
    switch(item_type)
    {
      case ITEM_TYPE_CASH:
      {
        weight += item_amount / 20000;
        if(item_amount % 20000 > 0)
          weight ++;
      }
      case ITEM_TYPE_POT, ITEM_TYPE_COCAINE, ITEM_TYPE_SPEED, ITEM_TYPE_POOR_MATS, ITEM_TYPE_GOOD_MATS, ITEM_TYPE_GREAT_MATS, ITEM_TYPE_POT_SEED:
      {
        weight += item_amount / 30;
        if(item_amount % 30 > 0)
          weight ++;
      }
      case ITEM_TYPE_WEAPON: return wepsize[item_amount];
      case ITEM_TYPE_GAS_CAN: weight = item_amount;
	  case ITEM_TYPE_ARMOUR_POOR: weight = item_amount;
	  case ITEM_TYPE_ARMOUR_STANDARD: weight = item_amount;
	  case ITEM_TYPE_ARMOUR_MILITARY: weight = item_amount;
	  case ITEM_TYPE_BOMB: weight = 3 * item_amount;
	  case ITEM_TYPE_TENT: weight = 3 * item_amount;
    }
    return weight;
}

stock ParseItemNameFromString(input[])
{
  new item_type_string[32], input_string[128];
  format(input_string, sizeof(input_string), "%s", input);
  for(new i = 0; input_string[i] != '\0'; i++)
  {
      if('-' == input_string[i])
      {
        strmid(item_type_string, input_string, i + 2, strlen(input_string));
        break;
      }
  }
  return item_type_string;
}

stock ConvertOldStorage(container_id, container_type)
{
	switch(container_type)
	{		
	  case CONTAINER_TYPE_HOUSE:
	  {
		new contents[500], temp[64];
		strcpy(contents, Houses[container_id][HouseStorage], 500);

		while(!isnull(contents))
		{
			if(strlen(contents) < 2)
				break;
			
			for(new i; i < strlen(contents); i++)
			{
				if(contents[i] == '|')
				{
					strmid(temp, contents, 0, i);
					strdel(contents, 0, (i + 1 > strlen(contents)) ? (i) : (i + 1));

					new item_amount, item_type_name[32], item_type;
					if(sscanf(temp, "ds[32]", item_amount, item_type_name))
						printf("Failed sscanf parse. %s", temp);

					item_type = GetItemTypeFromName(item_type_name);
					if(item_type == ITEM_TYPE_WEAPON)
					{
						new weapid;
						for(new w = 1; w < 47; w ++)
						{
							if(!strcmp(weapons[w], item_type_name, true) && strlen(weapons[w]) > 0)
							{
								weapid = w;
								break;
							}
						}

						if(item_amount > 1)
						{
							for(new k = 0; k < item_amount; k++)
							{
								AddToStorage(container_id, container_type, item_type, weapid);
							}
						}
						else AddToStorage(container_id, container_type, item_type, weapid);
					}
					else
						AddToStorage(container_id, container_type, item_type, item_amount);
					break;
				}
			}
		}
	  }
	  case CONTAINER_TYPE_BIZ:
	  {
		if(Businesses[container_id][bVault] > 0)
			AddToStorage(container_id, CONTAINER_TYPE_BIZ, ITEM_TYPE_CASH, Businesses[container_id][bVault]);
		
		if(Businesses[container_id][bMaterials][0] > 0)
			AddToStorage(container_id, CONTAINER_TYPE_BIZ, ITEM_TYPE_POOR_MATS, Businesses[container_id][bMaterials][0]);
		
		if(Businesses[container_id][bMaterials][1] > 0)
			AddToStorage(container_id, CONTAINER_TYPE_BIZ, ITEM_TYPE_GOOD_MATS, Businesses[container_id][bMaterials][1]);
		
		if(Businesses[container_id][bMaterials][2] > 0)
			AddToStorage(container_id, CONTAINER_TYPE_BIZ, ITEM_TYPE_GREAT_MATS, Businesses[container_id][bMaterials][2]);
		
		if(Businesses[container_id][bCocaine] > 0)
			AddToStorage(container_id, CONTAINER_TYPE_BIZ, ITEM_TYPE_COCAINE, Businesses[container_id][bCocaine]);
			
		if(Businesses[container_id][bPot] > 0)
			AddToStorage(container_id, CONTAINER_TYPE_BIZ, ITEM_TYPE_POT, Businesses[container_id][bPot]);
		
		if(Businesses[container_id][bSpeed] > 0)
			AddToStorage(container_id, CONTAINER_TYPE_BIZ, ITEM_TYPE_SPEED, Businesses[container_id][bSpeed]);
		
		if(Businesses[container_id][Weapons][0] > 0)
			AddToStorage(container_id, CONTAINER_TYPE_BIZ, ITEM_TYPE_WEAPON, Businesses[container_id][Weapons][0]);
		
		if(Businesses[container_id][Weapons][1] > 0)
			AddToStorage(container_id, CONTAINER_TYPE_BIZ, ITEM_TYPE_WEAPON, Businesses[container_id][Weapons][1]);
		
		if(Businesses[container_id][bArmour][0] > 0)
			AddToStorage(container_id, CONTAINER_TYPE_BIZ, ITEM_TYPE_ARMOUR_POOR, 1);
		
		if(Businesses[container_id][bArmour][1] > 0)
			AddToStorage(container_id, CONTAINER_TYPE_BIZ, ITEM_TYPE_ARMOUR_STANDARD, 1);
		
		if(Businesses[container_id][bArmour][2] > 0)
			AddToStorage(container_id, CONTAINER_TYPE_BIZ, ITEM_TYPE_ARMOUR_MILITARY, 1);
		
		Businesses[container_id][bVault] = 0;
		Businesses[container_id][bMaterials][0] = 0;
		Businesses[container_id][bMaterials][1] = 0;
		Businesses[container_id][bMaterials][2] = 0;
		Businesses[container_id][bCocaine] = 0;
		Businesses[container_id][bPot] = 0;
		Businesses[container_id][bSpeed] = 0;
		Businesses[container_id][Weapons][0] = 0;
		Businesses[container_id][Weapons][1] = 0;
		Businesses[container_id][bArmour][0] = 0;
		Businesses[container_id][bArmour][1] = 0;
		Businesses[container_id][bArmour][2] = 0;
	  }
	}
	return 1;
}
