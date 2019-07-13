/*
#		MTG Hotel System
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

#define HOTEL_VW					85000

#define MAX_HOTEL_ROOMS				160
#define MAX_HOTELS_PER_BIZ			16

#define MAX_HOTEL_STORAGE_SLOTS		7
#define HOTEL_POT					0
#define HOTEL_COCAINE				1
#define	HOTEL_SPEED					2
#define HOTEL_MATSLOW				3
#define HOTEL_MATSMID				4
#define HOTEL_MATSHIGH				5
#define HOTEL_WEAPON				6

#define MIN_PRICE					2500
#define MAX_PRICE					4000

#define RENT_TIME					604800 //7 Days
#define HOTEL_WARNING_TIME			172800 //2 days

enum hotelroom_
{
	hRoomID,
	hBizLink,
	hBizIndex,
	hOwner[MAX_PLAYER_NAME + 1],
	hStorage[MAX_HOTEL_STORAGE_SLOTS],
	hRentPrice,
	Float:hExtPos[3],
	Float:hIntPos[3],
	hExteriorVW,
	hExteriorInt,
	hInteriorVW,
	hInteriorInt,
	hLock,
	hTimeLeft,
	Text3D:hLabel,
	Text3D:hAdminLabel[MAX_PLAYERS],
	hIcon,
	hAutoClean,
};

new Hotels[MAX_HOTEL_ROOMS][hotelroom_];
new Iterator:Hotel<MAX_HOTEL_ROOMS>;
static string[128], bigString[1024];

#define DoesHotelRoomExist(%0)		Iter_Contains(Hotel, %0)
#define InsertHotelRoom(%0)			Iter_Add(Hotel, %0)

// ============= Callbacks =============

hook OnGameModeInit()
{
	//db_query(main_db, "CREATE TABLE IF NOT EXISTS 'HotelRooms' (hRoomID INTEGER, hBizLink INTEGER, hBizIndex INTEGER, hOwner VARCHAR, hPot INTEGER, hCocaine INTEGER, hSpeed INTEGER, hMats INTEGER, hWeapon1 INTEGER, hRentPrice INTEGER, hExtX FLOAT, hExtY FLOAT, hExtZ FLOAT, hIntX FLOAT, hIntY FLOAT, hIntZ FLOAT, hExteriorVW INTEGER, hExteriorInt INTEGER, hInteriorVW INTEGER, hInteriorInt INTEGER, hLock INTEGER, hTimeLeft BIGINT, hTimeStamp BIGINT, hTimeStampDate VARCHAR, hAutoClean INTEGER)");
	//LoadHotelRooms();
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case HOTEL_ROOM_EDIT:
		{
			if(!response)
				return 1;
				
			switch(listitem)
			{
				//Price
				case 0: ShowPlayerDialog(playerid, HOTEL_ROOM_PRICE, DIALOG_STYLE_INPUT, "Price Change", "What would you like to set the price of this hotel room to?\nIt must be between 2500 and 4000 dollars", "Okay", "Back");
				case 1: //Position
				{
					new Float:pPos[3], id = GetPVarInt(playerid, "EditingHotelRoomID");
					GetPlayerPos(playerid, pPos[0], pPos[1], pPos[2]);
					
					Hotels[id][hExtPos][0] = pPos[0];
					Hotels[id][hExtPos][1] = pPos[1];
					Hotels[id][hExtPos][2] = pPos[2];
					Hotels[id][hExteriorVW] = GetPlayerVirtualWorld(playerid);
					Hotels[id][hExteriorInt] = GetPlayerInterior(playerid);
					UpdateHotelIcon(id);
					SaveHotelRoom(id);
					format(string, sizeof(string), "You have moved hotel room %d.", Hotels[id][hBizIndex]);
					SendClientMessage(playerid, WHITE, string);
					DeletePVar(playerid, "EditingHotelRoomID");
				}
				case 2: //Interior
				{
					ShowPlayerDialog(playerid, HOTEL_ROOM_INTERIOR, DIALOG_STYLE_LIST, "Interior Change", "Small Hotel Room\nHotel Room with Kitchen\nVery Nice Hotel Room\nCustom", "Select", "Back"); 
				}
				case 3: //Auto clean
				{
					new id = GetPVarInt(playerid, "EditingHotelRoomID");
					DeletePVar(playerid, "EditingHotelRoomID");
					if(Hotels[id][hAutoClean] == 0)
						Hotels[id][hAutoClean] = 1;
					else Hotels[id][hAutoClean] = 0;
					format(string, sizeof(string), "%d", id);
					return cmd_aedithotelroom(playerid, string);
				}
			}
		}
		case HOTEL_ROOM_PRICE:
		{
			if(!response)
			{
				format(string, sizeof(string), "{FFFFFF}Rental Price: {009900}$%d{FFFFFF}\nPosition", Hotels[GetPVarInt(playerid, "EditingHotelRoomID")][hRentPrice]);
				return ShowPlayerDialog(playerid, HOTEL_ROOM_EDIT, DIALOG_STYLE_LIST, "Hotel Room Edit", string, "Okay", "Exit"); 
			}
			
			new id = GetPVarInt(playerid, "EditingHotelRoomID"), price = strval(inputtext);
			DeletePVar(playerid, "EditingHotelRoomID");
			
			if(price < MIN_PRICE || price > MAX_PRICE)
			{
				SendClientMessage(playerid, YELLOW, "The price must be between $2500 and $4000.");
				return ShowPlayerDialog(playerid, HOTEL_ROOM_PRICE, DIALOG_STYLE_INPUT, "Price Change", "What would you like to set the price of this hotel room to?\nIt must be between 2500 and 4000 dollars", "Okay", "Back");
			}
			
			Hotels[id][hRentPrice] = price;
			UpdateHotelIcon(id);
			SaveHotelRoom(id);
			format(string, sizeof(string), "You have changed the price of hotel room %d to $%d", Hotels[id][hBizIndex], Hotels[id][hRentPrice]);
			SendClientMessage(playerid, WHITE, string);
		}
		case HOTEL_ROOM_INTERIOR:
		{
			new id = GetPVarInt(playerid, "EditingHotelRoomID");
			DeletePVar(playerid, "EditingHotelRoomID");
			if(!response)
			{
				format(string, sizeof(string), "%d", id);
				return cmd_aedithotelroom(playerid, string);
			}
			
			switch(listitem)
			{
				case 0:
				{
					Hotels[id][hIntPos][0] = 2233.8645; 
					Hotels[id][hIntPos][1] = -1114.9443;
					Hotels[id][hIntPos][2] = 1050.8828;
					Hotels[id][hInteriorInt] = 5;
					format(string, sizeof(string), "You have set hotel room ID %d's interior to the small hotel room interior.", id);
					SendClientMessage(playerid, -1, string);
					SaveHotelRoom(id);
				}
				case 1:
				{
					Hotels[id][hIntPos][0] = 2282.8896; 
					Hotels[id][hIntPos][1] = -1140.2006;
					Hotels[id][hIntPos][2] = 1050.8984;
					Hotels[id][hInteriorInt] = 11;
					format(string, sizeof(string), "You have set hotel room ID %d's interior to the hotel room with kitchen interior.", id);
					SendClientMessage(playerid, -1, string);
					SaveHotelRoom(id);
				}
				case 2:
				{
					Hotels[id][hIntPos][0] = 2218.3843; 
					Hotels[id][hIntPos][1] = -1076.0389;
					Hotels[id][hIntPos][2] = 1050.4844;
					Hotels[id][hInteriorInt] = 1;
					format(string, sizeof(string), "You have set hotel room ID %d's interior to the very nice hotel room interior.", id);
					SendClientMessage(playerid, -1, string);
					SaveHotelRoom(id);
				}
				case 3:
				{
					new Float:pos[3];
					GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
					Hotels[id][hIntPos][0] =  pos[0]; 
					Hotels[id][hIntPos][1] =  pos[1];
					Hotels[id][hIntPos][2] =  pos[2];
					Hotels[id][hInteriorInt] = 0;
					format(string, sizeof(string), "You have set hotel room ID %d's interior to a custom interior.", id);
					SendClientMessage(playerid, -1, string);
					SaveHotelRoom(id);
				}
			}
		}	
		case HOTEL_ROOM_INSPECT:
		{
			if(!response)
				return 1;
			
			new id = GetPVarInt(playerid, "InspectingHotelRoomID");
			switch(listitem)
			{
				case 0:
				{
					if(Hotels[id][hStorage][HOTEL_POT] == 0)
						return 1;
						
					Player[playerid][Pot] += Hotels[id][hStorage][HOTEL_POT];
					
					format(string, sizeof(string), "%s has taken %d grams of pot from hotel room ID %d.", Player[playerid][NormalName], Hotels[id][hStorage][HOTEL_POT], id);
					StatLog(string);
					format(string, sizeof(string), "You have found %d grams of pot in the hotel room!", Hotels[id][hStorage][HOTEL_POT]);
					SendClientMessage(playerid, WHITE, string);
					Hotels[id][hStorage][HOTEL_POT] = 0;
				}
				case 1:
				{
					if(Hotels[id][hStorage][HOTEL_COCAINE] == 0)
						return 1;
						
					Player[playerid][Cocaine] += Hotels[id][hStorage][HOTEL_COCAINE];
					
					format(string, sizeof(string), "%s has taken %d grams of cocaine from hotel room ID %d.", Player[playerid][NormalName], Hotels[id][hStorage][HOTEL_COCAINE], id);
					StatLog(string);
					format(string, sizeof(string), "You have found %d grams of cocaine in the hotel room!", Hotels[id][hStorage][HOTEL_COCAINE]);
					SendClientMessage(playerid, WHITE, string);
					Hotels[id][hStorage][HOTEL_COCAINE] = 0;
				}
				case 2:
				{
					if(Hotels[id][hStorage][HOTEL_SPEED] == 0)
						return 1;
						
					Player[playerid][Speed] += Hotels[id][hStorage][HOTEL_SPEED];
					
					format(string, sizeof(string), "%s has taken %d grams of speed from hotel room ID %d.", Player[playerid][NormalName], Hotels[id][hStorage][HOTEL_SPEED], id);
					StatLog(string);
					format(string, sizeof(string), "You have found %d grams of speed in the hotel room!", Hotels[id][hStorage][HOTEL_SPEED]);
					SendClientMessage(playerid, WHITE, string);
					Hotels[id][hStorage][HOTEL_SPEED] = 0;
				}
				case 3:
				{
					if(Hotels[id][hStorage][HOTEL_MATSLOW] == 0)
						return 1;
						
					Player[playerid][Materials][0] += Hotels[id][hStorage][HOTEL_MATSLOW];
					
					format(string, sizeof(string), "%s has taken %d street grade materials from hotel room ID %d.", Player[playerid][NormalName], Hotels[id][hStorage][HOTEL_MATSLOW], id);
					StatLog(string);
					format(string, sizeof(string), "You have found %d street grade materials in the hotel room!", Hotels[id][hStorage][HOTEL_MATSLOW]);
					SendClientMessage(playerid, WHITE, string);
					Hotels[id][hStorage][HOTEL_MATSLOW] = 0;
				}
				case 4:
				{
					if(Hotels[id][hStorage][HOTEL_MATSMID] == 0)
						return 1;
						
					Player[playerid][Materials][1] += Hotels[id][hStorage][HOTEL_MATSMID];
					
					format(string, sizeof(string), "%s has taken %d standard grade materials from hotel room ID %d.", Player[playerid][NormalName], Hotels[id][hStorage][HOTEL_MATSMID], id);
					StatLog(string);
					format(string, sizeof(string), "You have found %d standard grade materials in the hotel room!", Hotels[id][hStorage][HOTEL_MATSMID]);
					SendClientMessage(playerid, WHITE, string);
					Hotels[id][hStorage][HOTEL_MATSMID] = 0;
				}
				case 5:
				{
					if(Hotels[id][hStorage][HOTEL_MATSHIGH] == 0)
						return 1;
						
					Player[playerid][Materials][2] += Hotels[id][hStorage][HOTEL_MATSHIGH];
					
					format(string, sizeof(string), "%s has taken %d military grade materials from hotel room ID %d.", Player[playerid][NormalName], Hotels[id][hStorage][HOTEL_MATSHIGH], id);
					StatLog(string);
					format(string, sizeof(string), "You have found %d military grade materials in the hotel room!", Hotels[id][hStorage][HOTEL_MATSHIGH]);
					SendClientMessage(playerid, WHITE, string);
					Hotels[id][hStorage][HOTEL_MATSHIGH] = 0;
				}
				case 6:
				{
					if(Hotels[id][hStorage][HOTEL_WEAPON] == 0)
						return 1;
						
					GivePlayerWeaponEx(playerid, Hotels[id][hStorage][HOTEL_WEAPON]);
					
					format(string, sizeof(string), "%s has taken a %s from hotel room ID %d.", Player[playerid][NormalName], weapons[Hotels[id][hStorage][HOTEL_WEAPON]], id);
					StatLog(string),
					format(string, sizeof(string), "You have found a %s in the hotel room!", weapons[Hotels[id][hStorage][HOTEL_WEAPON]]);
					SendClientMessage(playerid, WHITE, string);
					Hotels[id][hStorage][HOTEL_WEAPON] = 0;
				}
			}
			DeletePVar(playerid, "InspectingHotelRoomID");
		}
	}
	return 1;
}

// ============= Commands ==============

CMD:placehotelroom(playerid, params[])
{
	if(Businesses[Player[playerid][Business]][bType] != 19 || Player[playerid][AdminLevel] < 5)
		return 1;
	
	if(Businesses[Player[playerid][Business]][TotalHotelRooms] >= MAX_HOTELS_PER_BIZ)
		return SendClientMessage(playerid, -1, "Your hotel already has the maximum of hotel rooms.");
	
	Businesses[Player[playerid][Business]][TotalHotelRooms]++;
	
	new id = Iter_Free(Hotel), Float:pPos[3];
	GetPlayerPos(playerid, pPos[0], pPos[1], pPos[2]);
	
	Hotels[id][hRoomID] = id;
	Hotels[id][hBizLink] = Player[playerid][Business];
	Hotels[id][hBizIndex] = Businesses[Player[playerid][Business]][TotalHotelRooms];
	format(Hotels[id][hOwner], 25, "Nobody");
	Hotels[id][hRentPrice] = 2500;
	Hotels[id][hExtPos][0] = pPos[0];
	Hotels[id][hExtPos][1] = pPos[1];
	Hotels[id][hExtPos][2] = pPos[2];
	Hotels[id][hExteriorVW] = GetPlayerVirtualWorld(playerid);
	Hotels[id][hExteriorInt] = GetPlayerInterior(playerid);
	Hotels[id][hIntPos][0] = 2233.8645; 
	Hotels[id][hIntPos][1] = -1114.9443;
	Hotels[id][hIntPos][2] = 1050.8828;
	Hotels[id][hInteriorVW] = HOTEL_VW + id;
	Hotels[id][hInteriorInt] = 5;
	Hotels[id][hLock] = 1;
	InsertHotelRoom(id);
	SaveHotelRoom(id);
	SaveBusiness(Player[playerid][Business]);
	UpdateHotelIcon(id);
	
	format(string, sizeof(string), "You have placed hotel room ID %d (Interal ID: %d). Your new hotel room total is %d. Use /edithotelroom to change the price or interior.", Hotels[id][hBizIndex], id, Businesses[Player[playerid][Business]][TotalHotelRooms]);
	SendClientMessage(playerid, WHITE, string);
	return 1;
}

CMD:edithotelroom(playerid, params[])
{
	if(Businesses[Player[playerid][Business]][bType] != 19)
		return 1;
		
	new id, idx;
	if(sscanf(params, "d", idx))
		return SendClientMessage(playerid, -1, "SYNTAX: /edithotelroom [hotel room ID]");
	
	if(idx < 1 || idx > Businesses[Player[playerid][Business]][TotalHotelRooms])
		return SendClientMessage(playerid, -1, "Invalid hotel room ID.");
	
	id = GetHotelIDByBizIndex(Player[playerid][Business], idx);
	
	if(id == -1)
		return SendClientMessage(playerid, WHITE, "An error has occured.");
	
	SetPVarInt(playerid, "EditingHotelRoomID", id);
	format(string, sizeof(string), "{FFFFFF}Rental Price: {009900}$%d{FFFFFF}\nPosition", Hotels[id][hRentPrice]);
	ShowPlayerDialog(playerid, HOTEL_ROOM_EDIT, DIALOG_STYLE_LIST, "Hotel Room Edit", string, "Okay", "Exit"); 
	return 1;
}

CMD:listtenants(playerid, params[])
{
	new id = Player[playerid][InBusiness];
	
	if(Businesses[id][bType] != 19)
		return SendClientMessage(playerid, WHITE, "You need to be inside a hotel you own to do this.");
		
	if(!PlayerHasBusinessKey(playerid, id))
		return 1;
	
	SendClientMessage(playerid, WHITE, "--------------------------------------------------"); 	
	foreach(new h : Hotel)
	{
		if(Hotels[h][hBizLink] != id)
			continue;
			
		if(!strcmp(Hotels[h][hOwner], "Nobody", true))
			continue;
		
		if(Hotels[h][hTimeLeft] < gettime())
			Hotels[h][hTimeLeft] = 0;
		
		format(string, sizeof(string), "Hotel Room %d | Tenant: %s | Time left: %d days %d hours %d minutes | Status: %s", Hotels[h][hBizIndex], Hotels[h][hOwner], (Hotels[h][hTimeLeft] - gettime()) / 86400, ((Hotels[h][hTimeLeft] - gettime()) % 86400) / 3600, ((Hotels[h][hTimeLeft] - gettime()) % 3600) / 60, (Hotels[h][hTimeLeft] > gettime()) ? ("Clean") : ("Needs cleaning"));
		SendClientMessage(playerid, WHITE, string);
	}
	SendClientMessage(playerid, WHITE, "--------------------------------------------------"); 	
	return 1;
}

CMD:evicttenant(playerid, params[])
{
	new bid = Player[playerid][InBusiness];
	
	if(Businesses[bid][bType] != 19)
		return SendClientMessage(playerid, WHITE, "You need to be inside a hotel you own to do this.");
		
	if(!PlayerHasBusinessKey(playerid, bid))
		return 1;
		
	new idx, id;
	if(sscanf(params, "d", idx))
		return SendClientMessage(playerid, -1, "SYNTAX: /evicttenant [hotel room ID]");
		
	
	if(idx < 1 || idx > Businesses[bid][TotalHotelRooms])
		return SendClientMessage(playerid, -1, "Invalid hotel room ID.");
	
	id = GetHotelIDByBizIndex(bid, idx);
	
	if(id == -1)
		return SendClientMessage(playerid, WHITE, "An error has occured.");
		
	if(!strcmp(Hotels[id][hOwner], "Nobody", true))
		return SendClientMessage(playerid, YELLOW, "This hotel room is not occupied.");
		
	Hotels[id][hTimeLeft] = gettime() + 172800; //Two days
	
	new pID = GetPlayerID(Hotels[id][hOwner]);
	if(IsPlayerConnected(pID))
		SendClientMessage(pID, YELLOW, "You are being evicted from your hotel room. You have two days to gather your things.");
		
	format(string, sizeof(string), "You have evicted %s from hotel room #%d. Please allow them two days to gather their things.", Hotels[id][hOwner], Hotels[id][hBizIndex]);
	SendClientMessage(playerid, YELLOW, string);
	return 1;
}

CMD:inspectroom(playerid, params[])
{	
	if(Businesses[Player[playerid][Business]][bType] != 19)
		return SendClientMessage(playerid, WHITE, "You don't own a hotel business.");
		
	new idx, id;
	if(sscanf(params, "d", idx))
		return SendClientMessage(playerid, -1, "SYNTAX: /inspectroom [hotel room ID]");
	
	new bid = Player[playerid][Business];
	
	if(idx < 1 || idx > Businesses[bid][TotalHotelRooms])
		return SendClientMessage(playerid, -1, "Invalid hotel room ID.");
	
	id = GetHotelIDByBizIndex(bid, idx);
	
	if(id == -1)
		return SendClientMessage(playerid, WHITE, "An error has occured.");
	
	if(Hotels[id][hTimeLeft] > gettime())
		return SendClientMessage(playerid, YELLOW, "You cannot inspect this room at this time!");
		
	if(!IsPlayerInRangeOfPoint(playerid, 5, Hotels[id][hExtPos][0], Hotels[id][hExtPos][1], Hotels[id][hExtPos][2]))
		return SendClientMessage(playerid, YELLOW, "You aren't close enough to the room.");
		
	SetPVarInt(playerid, "InspectingHotelRoomID", id);
	format(string, sizeof(string), "Pot (%d)\nCocaine (%d)\nSpeed (%d)\nStreet Grade Materials (%d)\nStandard Grade Materials (%d)\nMilitary Grade Materials (%d)\nWeapon (%s)", Hotels[id][hStorage][HOTEL_POT], Hotels[id][hStorage][HOTEL_COCAINE], Hotels[id][hStorage][HOTEL_SPEED], Hotels[id][hStorage][HOTEL_MATSLOW], Hotels[id][hStorage][HOTEL_MATSMID], Hotels[id][hStorage][HOTEL_MATSHIGH], (Hotels[id][hStorage][HOTEL_WEAPON] > 0) ? (weapons[Hotels[id][hStorage][HOTEL_WEAPON]]) : ("Empty"));
	ShowPlayerDialog(playerid, HOTEL_ROOM_INSPECT, DIALOG_STYLE_LIST, "Room Contents", string, "Take", "Cancel");
	return 1;
}

CMD:cleanroom(playerid, params[])
{	
	if(Businesses[Player[playerid][Business]][bType] != 19)
		return SendClientMessage(playerid, WHITE, "You don't own a hotel business.");
	
	new idx, id;
	if(sscanf(params, "d", idx))
		return SendClientMessage(playerid, -1, "SYNTAX: /cleanroom [hotel room ID]");
	
	new bid = Player[playerid][Business];
	id = GetHotelIDByBizIndex(bid, idx);

	if(idx < 1 || idx > Businesses[bid][TotalHotelRooms])
		return SendClientMessage(playerid, -1, "Invalid hotel room ID.");

	if(id == -1)
		return SendClientMessage(playerid, WHITE, "An error has occured.");

	if(Hotels[id][hTimeLeft] > gettime())
		return SendClientMessage(playerid, YELLOW, "You cannot clean this room at this time!");
	
	if(!IsPlayerInRangeOfPoint(playerid, 5, Hotels[id][hExtPos][0], Hotels[id][hExtPos][1], Hotels[id][hExtPos][2]))
		return SendClientMessage(playerid, YELLOW, "You aren't close enough to the room.");
	
	CleanRoom(id, playerid);
	Businesses[bid][bSupplies] -= 70;
	Businesses[bid][BusinessTrashAmount] += 35;
	format(string, sizeof(string), "You have cleaned room #%d and thrown away its contents.", Hotels[id][hBizIndex]);
	SendClientMessage(playerid, -1, string);
	return 1;
}

CMD:rentroom(playerid, params[])
{
	/*new bid = Player[playerid][InBusiness];
	
	if(Businesses[bid][bType] != 19)
		return SendClientMessage(playerid, -1, "You must be inside a hotel to use this command."); */
	
	if(Player[playerid][Identity] == 0)
		return SendClientMessage(playerid, -1, "You must have valid identification to rent a room!"); 
	
	if(Player[playerid][HotelRoomID] != -1)
		return SendClientMessage(playerid, -1, "You already have a hotel room.");
	
	new id = GetClosestHotelRoom(playerid);
	
	if(id == -1)
		return SendClientMessage(playerid, WHITE, "You are not near any hotel rooms.");
	
	if(!IsPlayerInRangeOfPoint(playerid, 3, Hotels[id][hExtPos][0], Hotels[id][hExtPos][1], Hotels[id][hExtPos][2]))
		return SendClientMessage(playerid, -1, "You are not close enough to the hotel room.");
		
	if(strcmp(Hotels[id][hOwner], "Nobody", true))
		return SendClientMessage(playerid, -1, "This hotel room is occupied!");
	
	if(Player[playerid][Money] < Hotels[id][hRentPrice])
		return SendClientMessage(playerid, -1, "You can't afford this room!");
	
	if(Player[playerid][AdminDuty] > 0 || Player[playerid][UnderCover] > 0 || Player[playerid][Mask] == 1)
		format(Hotels[id][hOwner], 25, "%s", Player[playerid][NormalName]);
	else format(Hotels[id][hOwner], 25, "%s", GetName(playerid));
	
	new bid = Hotels[id][hBizLink];
	
	UpdateHotelIcon(id);
	Player[playerid][HotelRoomID] = id;
	Hotels[id][hTimeLeft] = gettime() + RENT_TIME;
//	Businesses[bid][bVault] += Hotels[id][hRentPrice];
	AddToStorage(bid, CONTAINER_TYPE_BIZ, ITEM_TYPE_CASH, Hotels[id][hRentPrice]);
	Player[playerid][Money] -= Hotels[id][hRentPrice];
	format(string, sizeof(string), "You have rented hotel room #%d for one week.", Hotels[id][hBizIndex]);
	SendClientMessage(playerid, WHITE, string);
	format(string, sizeof(string), "[HotelRooms] %s has rented hotel room %d.", Player[playerid][NormalName], id);
	StatLog(string);
	
	SavePlayerData(playerid);
	SaveHotelRoom(id);
	return 1;
}

CMD:renewrent(playerid, params[])
{
	if(Player[playerid][HotelRoomID] == -1)
		return SendClientMessage(playerid, -1, "You do not have a hotel room.");
	
	if(Player[playerid][Identity] == 0)
		return SendClientMessage(playerid, -1, "You must have valid identification to rent a room!"); 
	
	new id = Player[playerid][HotelRoomID];
	
	if(Player[playerid][InBusiness] != Hotels[id][hBizLink])
		return SendClientMessage(playerid, -1, "You must be inside your hotel to renew your rent.");
	
	if((Hotels[id][hTimeLeft] - gettime()) > 172800)
		return SendClientMessage(playerid, YELLOW, "You must wait until there is less than 2 days remaining to renew your rent.");
		
	if(Player[playerid][Money] < Hotels[id][hRentPrice])
		return SendClientMessage(playerid, YELLOW, "You can't afford to renew your rent!");
	
	Player[playerid][HotelRoomWarning] = 0;
//	Businesses[Hotels[id][hBizLink]][bVault] += Hotels[id][hRentPrice];
	AddToStorage(Hotels[id][hBizLink], CONTAINER_TYPE_BIZ, ITEM_TYPE_CASH, Hotels[id][hRentPrice]);
	Player[playerid][Money] -= Hotels[id][hRentPrice];
	Hotels[id][hTimeLeft] = gettime() + RENT_TIME;
	SendClientMessage(playerid, -1, "You have renewed your hotel room for another week.");
	format(string, sizeof(string), "[HotelRooms] %s has rented hotel room %d.", Player[playerid][NormalName], id);
	StatLog(string);
	SavePlayerData(playerid);
	SaveHotelRoom(id);
	return 1;
}

CMD:lockhotelroom(playerid, params[])
{
	/*new bid = Player[playerid][InBusiness];
	
	if(Businesses[bid][bType] != 19)
		return SendClientMessage(playerid, -1, "You must be in a hotel to use this command."); */
	
	//if(!PlayerHasBusinessKey(playerid, bid) && Player[playerid][HotelRoomID] == -1)
		//return SendClientMessage(playerid, -1, "You don't have a key for any of the rooms in this hotel.");
	
	new id;
	if(Player[playerid][InHotelRoom] != -1)
	{
		id = Player[playerid][InHotelRoom];
		
		if(!IsPlayerInRangeOfPoint(playerid, 3, Hotels[id][hIntPos][0], Hotels[id][hIntPos][1], Hotels[id][hIntPos][2]))
			return SendClientMessage(playerid, -1, "You aren't close enough to the hotel room door to use the key.");
	}
	else
	{
		id = GetClosestHotelRoom(playerid);
		
		if(id == -1)
			return SendClientMessage(playerid, WHITE, "You aren't near any hotel rooms.");
		
		if(!IsPlayerInRangeOfPoint(playerid, 3, Hotels[id][hExtPos][0], Hotels[id][hExtPos][1], Hotels[id][hExtPos][2]))
			return SendClientMessage(playerid, -1, "You aren't close enough to the hotel room to use the key.");
	}
	
	if(id != Player[playerid][HotelRoomID] && !PlayerHasBusinessKey(playerid, Hotels[id][hBizLink]))
		return SendClientMessage(playerid, -1, "This isn't your hotel room!");
		
	switch(Hotels[id][hLock])
	{
		case 0:
		{
			Hotels[id][hLock] = 1;
			format(string, sizeof(string), "%s uses their hotel room pass to lock the door.", GetNameEx(playerid));
			NearByMessageEx(playerid, NICESKY, string, 10);
		}
		case 1:
		{
			Hotels[id][hLock] = 0;
			format(string, sizeof(string), "%s uses their hotel room pass to unlock the door.", GetNameEx(playerid));
			NearByMessageEx(playerid, NICESKY, string, 10);
		}
	}
	return 1;
}

CMD:hrdeposit(playerid, params[]) return cmd_hotelroomdeposit(playerid, params);
CMD:hotelroomdeposit(playerid, params[])
{
	if(Player[playerid][HotelRoomID] == -1)
		return SendClientMessage(playerid, -1, "You don't have a hotel room!");
		
	if(Player[playerid][InHotelRoom] != Player[playerid][HotelRoomID])
		return SendClientMessage(playerid, -1, "You must be inside your hotel room to use this command!");
		
	new amount, option[32];
	if(sscanf(params, "s[32]D(0)", option, amount))
	{
		SendClientMessage(playerid, WHITE, "SYNTAX: /hotelroomdeposit [option] [amount]");
		return SendClientMessage(playerid, GREY, "Options: pot, cocaine, speed, mats, weapon");
	}
	new id = Player[playerid][HotelRoomID];
	
	if(amount < 1 && strcmp(option, "weapon", true))
		return SendClientMessage(playerid, -1, "Invalid amount.");
	
	if(amount + GetHotelRoomTotalStorage(id) > 400)
		amount = 400 - GetHotelRoomTotalStorage(id);
	
	if(amount == 0 && strcmp(option, "weapon", true))
		return SendClientMessage(playerid, -1, "You can't store anymore in your hotel room.");
	
	if(!strcmp(option, "pot", true))
	{
		if(amount > Player[playerid][Pot])
			return SendClientMessage(playerid, -1, "You don't have that much pot.");
		
		Player[playerid][Pot] -= amount;
		Hotels[id][hStorage][HOTEL_POT] += amount;
		
		format(string, sizeof(string), "%s has stored %d grams of pot into their hotel room. (%d)", Player[playerid][NormalName], amount, id); 
		StatLog(string);
		format(string, sizeof(string), "You have succesfully stored %d grams of pot in your hotel room.", amount); 
		SendClientMessage(playerid, -1, string); 
		SavePlayerData(playerid);
		SaveHotelRoom(id);
	}
	else if(!strcmp(option, "cocaine", true))
	{
		if(amount > Player[playerid][Cocaine])
			return SendClientMessage(playerid, -1, "You don't have that much cocaine.");
		
		Player[playerid][Cocaine] -= amount;
		Hotels[id][hStorage][HOTEL_COCAINE] += amount;
		
		format(string, sizeof(string), "%s has stored %d grams of cocaine into their hotel room. (%d)", Player[playerid][NormalName], amount, id); 
		StatLog(string);
		format(string, sizeof(string), "You have succesfully stored %d grams of cocaine in your hotel room.", amount); 
		SendClientMessage(playerid, -1, string);
		SavePlayerData(playerid);
		SaveHotelRoom(id);
	}
	else if(!strcmp(option, "speed", true))
	{
		if(amount > Player[playerid][Speed])
			return SendClientMessage(playerid, -1, "You don't have that much cocaine.");
		
		Player[playerid][Speed] -= amount;
		Hotels[id][hStorage][HOTEL_SPEED] += amount;
		
		format(string, sizeof(string), "%s has stored %d grams of speed into their hotel room. (%d)", Player[playerid][NormalName], amount, id); 
		StatLog(string);
		format(string, sizeof(string), "You have succesfully stored %d grams of speed in your hotel room.", amount); 
		SendClientMessage(playerid, -1, string); 
		SavePlayerData(playerid);
		SaveHotelRoom(id);
	}
	else if(!strcmp(option, "streetmats", true))
	{
		if(amount > Player[playerid][Materials][0])
			return SendClientMessage(playerid, -1, "You don't have that much street grade materials.");
		
		Player[playerid][Materials][0] -= amount;
		Hotels[id][hStorage][HOTEL_MATSLOW] += amount;
		
		format(string, sizeof(string), "%s has stored %d street grade materials into their hotel room. (%d)", Player[playerid][NormalName], amount, id); 
		StatLog(string);
		format(string, sizeof(string), "You have succesfully stored %d street grade materials in your hotel room.", amount); 
		SendClientMessage(playerid, -1, string);
		SavePlayerData(playerid);
		SaveHotelRoom(id);
	}
	else if(!strcmp(option, "standardmats", true))
	{
		if(amount > Player[playerid][Materials][1])
			return SendClientMessage(playerid, -1, "You don't have that much standard grade materials.");
		
		Player[playerid][Materials][1] -= amount;
		Hotels[id][hStorage][HOTEL_MATSMID] += amount;
		
		format(string, sizeof(string), "%s has stored %d standard grade materials into their hotel room. (%d)", Player[playerid][NormalName], amount, id); 
		StatLog(string);
		format(string, sizeof(string), "You have succesfully stored %d standard grade materials in your hotel room.", amount); 
		SendClientMessage(playerid, -1, string);
		SavePlayerData(playerid);
		SaveHotelRoom(id);
	}
	else if(!strcmp(option, "militarymats", true))
	{
		if(amount > Player[playerid][Materials][2])
			return SendClientMessage(playerid, -1, "You don't have that much military grade materials.");
		
		Player[playerid][Materials][2] -= amount;
		Hotels[id][hStorage][HOTEL_MATSHIGH] += amount;
		
		format(string, sizeof(string), "%s has stored %d military grade materials into their hotel room. (%d)", Player[playerid][NormalName], amount, id); 
		StatLog(string);
		format(string, sizeof(string), "You have succesfully stored %d military grade materials in your hotel room.", amount); 
		SendClientMessage(playerid, -1, string);
		SavePlayerData(playerid);
		SaveHotelRoom(id);
	}
	else if(!strcmp(option, "weapon", true))
	{
		if(Hotels[id][hStorage][HOTEL_WEAPON] > 0)
			return SendClientMessage(playerid, -1, "You already have a weapon stored in your hotel room.");
		
		new wep = GetPlayerWeapon(playerid);
		
		Hotels[id][hStorage][HOTEL_WEAPON] = wep;
		AdjustWeapon(playerid, wep, 0);
		
		format(string, sizeof(string), "%s has stored a %s in their hotel room. (%d)", Player[playerid][NormalName], weapons[wep], id);
		StatLog(string);
		format(string, sizeof(string), "You have stored a %s in your hotel room.", weapons[wep]);
		SendClientMessage(playerid, -1, string);
		SavePlayerData(playerid);
		SaveHotelRoom(id);
	}
	else 
	{
		SendClientMessage(playerid, WHITE, "SYNTAX: /hotelroomdeposit [option] [amount]");
		return SendClientMessage(playerid, GREY, "Options: pot, cocaine, speed, mats, weapon");
	}
	return 1;
}

CMD:hrwithdraw(playerid, params[]) return cmd_hotelroomwithdraw(playerid, params);
CMD:hotelroomwithdraw(playerid, params[])
{
	if(Player[playerid][HotelRoomID] == -1)
		return SendClientMessage(playerid, -1, "You don't have a hotel room!");
		
	if(Player[playerid][InHotelRoom] != Player[playerid][HotelRoomID])
		return SendClientMessage(playerid, -1, "You must be inside your hotel room to use this command!");
		
	new amount, option[32];
	if(sscanf(params, "s[32]D(0)", option, amount))
	{
		SendClientMessage(playerid, WHITE, "SYNTAX: /hotelroomwithdraw [option] [amount]");
		return SendClientMessage(playerid, GREY, "Options: pot, cocaine, speed, mats, weapon");
	}
	new id = Player[playerid][HotelRoomID];
	
	if(amount < 1 && strcmp(option, "weapon", true))
		return SendClientMessage(playerid, -1, "Invalid amount.");
		
	if(!strcmp(option, "pot", true))
	{
		if(amount > Hotels[id][hStorage][HOTEL_POT])
			return SendClientMessage(playerid, -1, "You don't have that much pot stored.");
			
		Player[playerid][Pot] += amount;
		Hotels[id][hStorage][HOTEL_POT] -= amount;
		
		format(string, sizeof(string), "%s has taken %d grams of pot from their hotel room. (%d)", Player[playerid][NormalName], amount, id); 
		StatLog(string); 
		format(string, sizeof(string), "You have successfully withdrawn %d grams of pot from your hotel room.", amount);
		SendClientMessage(playerid, -1, string);
		SavePlayerData(playerid);
		SaveHotelRoom(id);
	}
	else if(!strcmp(option, "cocaine", true))
	{
		if(amount > Hotels[id][hStorage][HOTEL_COCAINE])
			return SendClientMessage(playerid, -1, "You don't have that much cocaine stored.");
			
		Player[playerid][Cocaine] += amount;
		Hotels[id][hStorage][HOTEL_COCAINE] -= amount;
		
		format(string, sizeof(string), "%s has taken %d grams of cocaine from their hotel room. (%d)", Player[playerid][NormalName], amount, id); 
		StatLog(string); 
		format(string, sizeof(string), "You have successfully withdrawn %d grams of cocaine from your hotel room.", amount);
		SendClientMessage(playerid, -1, string);
		SavePlayerData(playerid);
		SaveHotelRoom(id);
	}
	else if(!strcmp(option, "speed", true))
	{
		if(amount > Hotels[id][hStorage][HOTEL_SPEED])
			return SendClientMessage(playerid, -1, "You don't have that much speed stored.");
			
		Player[playerid][Speed] += amount;
		Hotels[id][hStorage][HOTEL_SPEED] -= amount;
		
		format(string, sizeof(string), "%s has taken %d grams of speed from their hotel room. (%d)", Player[playerid][NormalName], amount, id); 
		StatLog(string); 
		format(string, sizeof(string), "You have successfully withdrawn %d grams of speed from your hotel room.", amount);
		SendClientMessage(playerid, -1, string);
		SavePlayerData(playerid);
		SaveHotelRoom(id);
	}
	else if(!strcmp(option, "streetmats", true))
	{
		if(amount > Hotels[id][hStorage][HOTEL_MATSLOW])
			return SendClientMessage(playerid, -1, "You don't have that many street grade materials stored.");
			
		Player[playerid][Materials][0] += amount;
		Hotels[id][hStorage][HOTEL_MATSLOW] -= amount;
		
		format(string, sizeof(string), "%s has taken %d street grade materials from their hotel room. (%d)", Player[playerid][NormalName], amount, id); 
		StatLog(string); 
		format(string, sizeof(string), "You have successfully withdrawn %d street grade materials from your hotel room.", amount);
		SendClientMessage(playerid, -1, string);
		SavePlayerData(playerid);
		SaveHotelRoom(id);
	}	
	else if(!strcmp(option, "standardmats", true))
	{
		if(amount > Hotels[id][hStorage][HOTEL_MATSMID])
			return SendClientMessage(playerid, -1, "You don't have that many standard grade materials stored.");
			
		Player[playerid][Materials][1] += amount;
		Hotels[id][hStorage][HOTEL_MATSMID] -= amount;
		
		format(string, sizeof(string), "%s has taken %d standard grade materials from their hotel room. (%d)", Player[playerid][NormalName], amount, id); 
		StatLog(string); 
		format(string, sizeof(string), "You have successfully withdrawn %d standard grade materials from your hotel room.", amount);
		SendClientMessage(playerid, -1, string);
		SavePlayerData(playerid);
		SaveHotelRoom(id);
	}	
	else if(!strcmp(option, "militarymats", true))
	{
		if(amount > Hotels[id][hStorage][HOTEL_MATSHIGH])
			return SendClientMessage(playerid, -1, "You don't have that many military grade materials stored.");
			
		Player[playerid][Materials][2] += amount;
		Hotels[id][hStorage][HOTEL_MATSHIGH] -= amount;
		
		format(string, sizeof(string), "%s has taken %d military grade materials from their hotel room. (%d)", Player[playerid][NormalName], amount, id); 
		StatLog(string); 
		format(string, sizeof(string), "You have successfully withdrawn %d military grade materials from your hotel room.", amount);
		SendClientMessage(playerid, -1, string);
		SavePlayerData(playerid);
		SaveHotelRoom(id);
	}	
	else if(!strcmp(option, "weapon", true))
	{
		if(Hotels[id][hStorage][HOTEL_WEAPON] == 0)
			return SendClientMessage(playerid, -1, "You don't have a weapon stored.");
			
		GivePlayerWeaponEx(playerid, Hotels[id][hStorage][HOTEL_WEAPON]);
		
		format(string, sizeof(string), "%s has taken a %s from their hotel room. (%d)", Player[playerid][NormalName], weapons[Hotels[id][hStorage][HOTEL_WEAPON]], id);
		StatLog(string);
		format(string, sizeof(string), "You have taken a %s from your hotel room.", weapons[Hotels[id][hStorage][HOTEL_WEAPON]]);
		SendClientMessage(playerid, -1, string);
		Hotels[id][hStorage][HOTEL_WEAPON] = 0;
		SavePlayerData(playerid);
		SaveHotelRoom(id);
	}
	else
	{
		SendClientMessage(playerid, WHITE, "SYNTAX: /hotelroomwithdraw [option] [amount]");
		return SendClientMessage(playerid, GREY, "Options: pot, cocaine, speed, mats, weapon");
	}
	return 1;
}

CMD:hrbalance(playerid, params[]) return cmd_hotelroombalance(playerid, params);
CMD:hotelroombalance(playerid, params[])
{
	if(Player[playerid][HotelRoomID] == -1)
		return SendClientMessage(playerid, -1, "You don't have a hotel room!");
		
	if(Player[playerid][InHotelRoom] != Player[playerid][HotelRoomID])
		return SendClientMessage(playerid, -1, "You must be inside your hotel room to use this command!");
		
	new id = Player[playerid][HotelRoomID];
	
	SendClientMessage(playerid, WHITE, "---------------------------------------------------------------------"); 
	SendClientMessage(playerid, WHITE, "Hotel Room Balance");
	format(string, sizeof(string), "Pot: %d | Cocaine: %d | Speed: %d | Street Grade Materials: %d | Standard Grade Materials: %d | Military Grade Materials: %d | Weapon: %s", Hotels[id][hStorage][HOTEL_POT], Hotels[id][hStorage][HOTEL_COCAINE], Hotels[id][hStorage][HOTEL_SPEED], Hotels[id][hStorage][HOTEL_MATSLOW], Hotels[id][hStorage][HOTEL_MATSMID], Hotels[id][hStorage][HOTEL_MATSHIGH], (Hotels[id][hStorage][HOTEL_WEAPON] > 0) ? (weapons[Hotels[id][hStorage][HOTEL_WEAPON]]) : ("None"));
	SendClientMessage(playerid, GREY, string);
	SendClientMessage(playerid, WHITE, "---------------------------------------------------------------------"); 
	return 1;
}

CMD:hotelinfo(playerid, params[])
{
	if(Player[playerid][HotelRoomID] == -1)
		return SendClientMessage(playerid, -1, "You don't have a hotel room!");
	new id = Player[playerid][HotelRoomID];
	
	format(string, sizeof(string), "---------------------- %s Hotel Room #%d ----------------------", Businesses[Hotels[id][hBizLink]][bName], Hotels[id][hBizIndex]);
	SendClientMessage(playerid, WHITE, string);
	format(string, sizeof(string), "Time Left: %d days %d hours %d minutes", (Hotels[id][hTimeLeft] - gettime()) / 86400, ((Hotels[id][hTimeLeft] - gettime()) % 86400) / 3600, ((Hotels[id][hTimeLeft] - gettime()) % 3600) / 60);
	SendClientMessage(playerid, GREY, string);
	format(string, sizeof(string), "Rent Price: %d", Hotels[id][hRentPrice]);
	SendClientMessage(playerid, GREY, string);
	SendClientMessage(playerid, WHITE, "---------------------------------------------------");
	return 1;
}

CMD:abandonhotelroom(playerid, params[])
{
	if(Player[playerid][HotelRoomID] == -1)
		return SendClientMessage(playerid, -1, "You don't have a hotel room!");
	
	new confirm[8];
	if(sscanf(params, "s[8]", confirm) || strcmp(params, "confirm", true))
		return SendClientMessage(playerid, RED, "Are you sure you wish to abandon your hotel room? You will not receive a refund. Type \"/abandonhotelroom confirm\" if you are sure."); 
	
	new id = Player[playerid][HotelRoomID];
	Player[playerid][HotelRoomID] = -1;
	CleanRoom(id);
	SendClientMessage(playerid, WHITE, "You have abandoned your hotel room.");
	format(string, sizeof(string), "%s has abandoned their hotel room. (%d)", Player[playerid][NormalName], id);
	StatLog(string);
	return 1;
}
	
// ============= Admin Commands ==============

CMD:checkhotelroom(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 2)
		return 1;
	
	new id;
	if(sscanf(params, "d", id))
		return SendClientMessage(playerid, -1, "SYNTAX: /checkhotelroom [Internal ID]");
	
	if(id < 0)
		return SendClientMessage(playerid, -1, "Invalid internal ID. (Less than 0)");
	
	if(!DoesHotelRoomExist(id))
		return SendClientMessage(playerid, -1, "Invalid internal ID. (Doesn't exist)");
		
	SendClientMessage(playerid, WHITE, "----------------------------------------------------------------------------");
	format(string, sizeof(string), "Hotel Room Internal ID: %d | Business ID: %d | Business Index: %d | Autoclean: %s", id, Hotels[id][hBizLink], Hotels[id][hBizIndex], (Hotels[id][hAutoClean] == 0) ? ("False") : ("True"));
	SendClientMessage(playerid, GREY, string);
	format(string, sizeof(string), "Owner: %s | Timeleft: %d days, %d hours, %d minutes | Price: %d", Hotels[id][hOwner], (Hotels[id][hTimeLeft] - gettime())/ 86400, ((Hotels[id][hTimeLeft] - gettime()) % 86400) / 3600, ((Hotels[id][hTimeLeft] - gettime()) % 3600) / 60, Hotels[id][hRentPrice]);
	SendClientMessage(playerid, GREY, string);
	format(string, sizeof(string), "Pot: %d | Cocaine: %d | Speed: %d | Street Grade Materials: %d | Standard Grade Materials: %d | Military Grade Materials: %d | Weapon: %s", Hotels[id][hStorage][HOTEL_POT], Hotels[id][hStorage][HOTEL_COCAINE], Hotels[id][hStorage][HOTEL_SPEED], Hotels[id][hStorage][HOTEL_MATSLOW], Hotels[id][hStorage][HOTEL_MATSMID], Hotels[id][hStorage][HOTEL_MATSHIGH], (Hotels[id][hStorage][HOTEL_WEAPON] > 0) ? (weapons[Hotels[id][hStorage][HOTEL_WEAPON]]) : ("None"));
	SendClientMessage(playerid, GREY, string);
	SendClientMessage(playerid, WHITE, "----------------------------------------------------------------------------");
	return 1;
}

CMD:aedithotelroom(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
	
	new id;
	if(sscanf(params, "d", id))
		return SendClientMessage(playerid, -1, "SYNTAX: /aedithotelroom [Internal ID]");
	
	if(id < 0)
		return SendClientMessage(playerid, -1, "Invalid internal ID. (Less than 0)");
	
	if(!DoesHotelRoomExist(id))
		return SendClientMessage(playerid, -1, "Invalid internal ID. (Doesn't exist)");
	
	SetPVarInt(playerid, "EditingHotelRoomID", id);
	format(string, sizeof(string), "{FFFFFF}Rental Price: {009900}$%d{FFFFFF}\nPosition\nInterior\nAutoClean: %s", Hotels[id][hRentPrice], (Hotels[id][hAutoClean] == 0) ? ("False") : ("True"));
	ShowPlayerDialog(playerid, HOTEL_ROOM_EDIT, DIALOG_STYLE_LIST, "Hotel Room Edit", string, "Okay", "Exit"); 
	return 1;
}

CMD:sethotelroom(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 3)
		return 1;
		
	new pid, id;
	if(sscanf(params, "ud", pid, id))
		return SendClientMessage(playerid, -1, "SYNTAX: /sethotelroom [playerid] [Internal ID] (Use -1 to remove a hotel room)");
		
	if(!IsPlayerConnected(pid))
		return SendClientMessage(playerid, -1, "That player isn't connected.");
		
	if(id < -1)
		return SendClientMessage(playerid, -1, "Invalid internal ID. (Less than -1)");
		
	if(id == -1)
	{
		if(Player[pid][HotelRoomID] == -1)
			return SendClientMessage(playerid, -1, "That player doesn't have a hotel room.");
		
		CleanRoom(Player[pid][HotelRoomID]);
		format(string, sizeof(string), "You have removed %s's hotel room.", Player[pid][NormalName]);
		SendClientMessage(playerid, -1, string);
		format(string, sizeof(string), "%s has removed %s's hotel room. (%d)", Player[playerid][AdminName], Player[pid][NormalName], Player[pid][HotelRoomID]);
		StatLog(string);
		Player[pid][HotelRoomID] = -1;
	}
	else 
	{
		if(!DoesHotelRoomExist(id))
			return SendClientMessage(playerid, -1, "Invalid internal ID. (Does not exist)");
		
		if(Player[pid][HotelRoomID] != -1)
			return SendClientMessage(playerid, -1, "That player already has a hotel room.");
			
		Player[pid][HotelRoomID] = id;
		format(Hotels[id][hOwner], 25, "%s", Player[pid][NormalName]);
		Hotels[id][hTimeLeft] = gettime() + RENT_TIME;
		
		format(string, sizeof(string), "%s has set %s's hotel room to %d.", Player[playerid][AdminName], Player[pid][NormalName], id);
		StatLog(string);
		format(string, sizeof(string), "You have set %s's hotel room to %d.", Player[pid][NormalName], id);
		SendClientMessage(playerid, -1, string);
	}
	return 1;
}

CMD:remotesethotelroom(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 3)
		return 1;
		
	new name[MAX_PLAYER_NAME + 1], id;
	if(sscanf(params, "s[25]d", name, id))
		return SendClientMessage(playerid, -1, "SYNTAX: /remotesethotelroom [name] [Internal ID] (Use -1 to remove a hotel room.)");
		
	if(id < -1)
		return SendClientMessage(playerid, -1, "Invalid internal ID. (Less than -1)");
	
	if(!IsPlayerRegistered(name))
		return SendClientMessage(playerid, WHITE, "That player doesn't exist.");
	
	new oldroom = GetRemoteIntValue(name, "HotelRoomID");
	if(id == -1)
	{
		if(oldroom == -1)
			return SendClientMessage(playerid, -1, "That player doesn't have a hotel room to remove.");
			
		CleanRoom(oldroom);
		
		SetPVarInt(playerid, "THREAD_REMOTESET_HOTELROOM_OLDID", oldroom);
		mysql_format(MYSQL_MAIN, string, sizeof(string), "UPDATE playeraccounts SET HotelRoomID = '-1' WHERE NormalName = '%e'", name);
		mysql_tquery(MYSQL_MAIN, string, "OnQueryFinish", "dddss", THREAD_REMOTESET_HOTELROOM, playerid, id, name, "");
	}
	else 
	{
		if(!DoesHotelRoomExist(id))
			return SendClientMessage(playerid, -1, "Invalid internal ID. (Does not exist)");
		
		if(oldroom != -1)
			return SendClientMessage(playerid, -1, "That player already has a hotel room.");
			
		format(Hotels[id][hOwner], 25, "%s", name);
		Hotels[id][hTimeLeft] = gettime() + RENT_TIME;
		UpdateHotelIcon(id);
		
		mysql_format(MYSQL_MAIN, string, sizeof(string), "UPDATE playeraccounts SET HotelRoomID = '%d' WHERE NormalName = '%e'", id, name);
		mysql_tquery(MYSQL_MAIN, string, "OnQueryFinish", "dddss", THREAD_REMOTESET_HOTELROOM, playerid, id, name, "");
	}
	return 1;
}

// ============= Functions ==============

stock UpdateHotelIcon(id)
{
	if(!DoesHotelRoomExist(id))
		return 1;
	
	if(IsValidDynamic3DTextLabel(Hotels[id][hLabel]))
		DestroyDynamic3DTextLabel(Hotels[id][hLabel]);
	if(IsValidDynamicPickup(Hotels[id][hIcon]))
		DestroyDynamicPickup(Hotels[id][hIcon]);
	
	if(strcmp(Hotels[id][hOwner], "Nobody", true))
	{
		format(string, sizeof(string), "Hotel Room %d", Hotels[id][hBizIndex]);
		Hotels[id][hIcon] = CreateDynamicPickup(1272, 1, Hotels[id][hExtPos][0], Hotels[id][hExtPos][1], Hotels[id][hExtPos][2], Hotels[id][hExteriorVW], Hotels[id][hExteriorInt]);  
	}
	else 
	{
		format(string, sizeof(string), "Hotel Room %d\nAvailable to rent for %s\n((/rentroom))", Hotels[id][hBizIndex], PrettyMoney(Hotels[id][hRentPrice]));
		Hotels[id][hIcon] = CreateDynamicPickup(1273, 1, Hotels[id][hExtPos][0], Hotels[id][hExtPos][1], Hotels[id][hExtPos][2], Hotels[id][hExteriorVW], Hotels[id][hExteriorInt]);  
	}
	
	Hotels[id][hLabel] = CreateDynamic3DTextLabel(string, 0x21DD00FF, Hotels[id][hExtPos][0], Hotels[id][hExtPos][1], Hotels[id][hExtPos][2] + 0.5, 25, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, Hotels[id][hExteriorVW], Hotels[id][hExteriorInt]); 
	
	foreach(Player, i)
	{
		if(Player[i][AdminLevel] >= 1)
			UpdateInternalHotelRoomIDIcons(i);
	}
	return 1;
}

stock UpdateInternalHotelRoomIDIcons(playerid)
{
	foreach(new h : Hotel)
	{
		if(IsValidDynamic3DTextLabel(Hotels[h][hAdminLabel][playerid]))
			DestroyDynamic3DTextLabel(Hotels[h][hAdminLabel][playerid]);
		
		format(string, sizeof(string), "Internal ID: %d", h);
		Hotels[h][hAdminLabel][playerid] = CreateDynamic3DTextLabel(string, RED, Hotels[h][hExtPos][0], Hotels[h][hExtPos][1], Hotels[h][hExtPos][2] + 1, 25, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, Hotels[h][hExteriorVW], Hotels[h][hExteriorInt], .playerid = playerid); 
	}
	return 1;
}

stock DestroyInternalHotelRoomIDIcons(i)
{
	foreach(new h : Hotel)
	{
		if(IsValidDynamic3DTextLabel(Hotels[h][hAdminLabel][i]))
			DestroyDynamic3DTextLabel(Hotels[h][hAdminLabel][i]);
	}
	return 1;
}

stock SaveHotelRoom(id)
{
	new Cache:cache;
	format(string, sizeof(string), "SELECT * FROM HotelRooms WHERE hRoomID = '%d'", id);
	cache = mysql_query(MYSQL_MAIN, string);
	if(cache_get_row_count() == 0)
	{
		format(string, sizeof(string), "INSERT INTO HotelRooms (hRoomID) VALUES (%d)", id);
		mysql_query(MYSQL_MAIN, string, false);
	}
	cache_delete(cache);
	
	mysql_format(MYSQL_MAIN, bigString, sizeof(bigString), "UPDATE HotelRooms SET hBizLink = '%d', hBizIndex = '%d', hOwner = '%e', hPot = '%d', hCocaine = '%d', hSpeed = '%d', hMats = '%d', hMats1 = '%d', hMats2 = '%d', ", \
	Hotels[id][hBizLink], Hotels[id][hBizIndex], Hotels[id][hOwner], Hotels[id][hStorage][HOTEL_POT], Hotels[id][hStorage][HOTEL_COCAINE], Hotels[id][hStorage][HOTEL_SPEED], Hotels[id][hStorage][HOTEL_MATSLOW], Hotels[id][hStorage][HOTEL_MATSMID], Hotels[id][hStorage][HOTEL_MATSHIGH]);
	
	mysql_format(MYSQL_MAIN, bigString, sizeof(bigString), "%shWeapon1 = '%d', hRentPrice = '%d', hExtX = '%f', hExtY = '%f', hExtZ = '%f', hExteriorVW = '%d', ", \
	bigString, Hotels[id][hStorage][HOTEL_WEAPON], Hotels[id][hRentPrice], Hotels[id][hExtPos][0], Hotels[id][hExtPos][1], Hotels[id][hExtPos][2], Hotels[id][hExteriorVW]);
	
	mysql_format(MYSQL_MAIN, bigString, sizeof(bigString), "%shExteriorInt = '%d', hIntX = '%f', hIntY = '%f', hIntZ = '%f', hInteriorVW = '%d', hInteriorInt = '%d', hLock = '%d', hTimeLeft = '%d', hAutoClean = '%d' WHERE hRoomID = '%d'", \
	bigString, Hotels[id][hExteriorInt], Hotels[id][hIntPos][0], Hotels[id][hIntPos][1], Hotels[id][hIntPos][2], Hotels[id][hInteriorVW], Hotels[id][hInteriorInt], Hotels[id][hLock], Hotels[id][hTimeLeft], Hotels[id][hAutoClean], Hotels[id][hRoomID]);
	
	mysql_query(MYSQL_MAIN, bigString, false);
	return 1;
}

stock SaveHotelRooms()
{
	foreach(new h : Hotel)
	{
		SaveHotelRoom(h);
	}
	return 1;
}

stock LoadHotelRooms()
{
	
	format(string, sizeof(string), "SELECT * FROM HotelRooms");
	new Cache:cache = mysql_query(MYSQL_MAIN, string), count, row;
	count = cache_get_row_count();
	
	while(row < count)
	{
		Hotels[row][hRoomID] = cache_get_field_content_int(row, "hRoomID");
		Hotels[row][hBizLink] = cache_get_field_content_int(row, "hBizLink");
		Hotels[row][hBizIndex] = cache_get_field_content_int(row, "hBizIndex");
		cache_get_field_content(row, "hOwner", Hotels[row][hOwner], 1, 25);
		Hotels[row][hStorage][HOTEL_POT] = cache_get_field_content_int(row, "hPot");
		Hotels[row][hStorage][HOTEL_COCAINE] = cache_get_field_content_int(row, "hCocaine");
		Hotels[row][hStorage][HOTEL_SPEED] = cache_get_field_content_int(row, "hSpeed");
		Hotels[row][hStorage][HOTEL_MATSLOW] = cache_get_field_content_int(row, "hMats");
		Hotels[row][hStorage][HOTEL_MATSMID] = cache_get_field_content_int(row, "hMats1");
		Hotels[row][hStorage][HOTEL_MATSHIGH] = cache_get_field_content_int(row, "hMats2");
		Hotels[row][hStorage][HOTEL_WEAPON] = cache_get_field_content_int(row, "hWeapon1");
		Hotels[row][hRentPrice] = cache_get_field_content_int(row, "hRentPrice");
		Hotels[row][hExtPos][0] = cache_get_field_content_float(row, "hExtX");
		Hotels[row][hExtPos][1] = cache_get_field_content_float(row, "hExtY");
		Hotels[row][hExtPos][2] = cache_get_field_content_float(row, "hExtZ");
		Hotels[row][hExteriorVW] = cache_get_field_content_int(row, "hExteriorVW");
		Hotels[row][hExteriorInt] = cache_get_field_content_int(row, "hExteriorInt");
		Hotels[row][hIntPos][0] = cache_get_field_content_float(row, "hIntX");
		Hotels[row][hIntPos][1] = cache_get_field_content_float(row, "hIntY");
		Hotels[row][hIntPos][2] = cache_get_field_content_float(row, "hIntZ");
		Hotels[row][hInteriorVW] = cache_get_field_content_int(row, "hInteriorVW");
		Hotels[row][hInteriorInt] = cache_get_field_content_int(row, "hInteriorInt");
		Hotels[row][hLock] = cache_get_field_content_int(row, "hLock");
		Hotels[row][hTimeLeft] = cache_get_field_content_int(row, "hTimeLeft");
		Hotels[row][hAutoClean] = cache_get_field_content_int(row, "hAutoClean");
		
		InsertHotelRoom(row);
		UpdateHotelIcon(row);
		printf("Loaded Hotel Room %d", row);
		row++;
		
	}
	cache_delete(cache);
	printf("Loaded %d hotel rooms.", count);
	
	return 1;
}

stock GetHotelIDByBizIndex(bid, idx)
{
	new id = -1;
	foreach(new h : Hotel)
	{
		if(Hotels[h][hBizLink] == bid && Hotels[h][hBizIndex] == idx)
		{
			id = h;
			break;
		}
	}
	return id;
}

stock GetClosestHotelRoom(playerid)
{
	new id = -1, Float:dist, vw = GetPlayerVirtualWorld(playerid), int = GetPlayerInterior(playerid);
	foreach(new h : Hotel)
	{
		if(vw != Hotels[h][hExteriorVW] || int != Hotels[h][hExteriorInt])
			continue;
			
		if(id == -1 || dist > GetPlayerDistanceFromPoint(playerid, Hotels[h][hExtPos][0], Hotels[h][hExtPos][1], Hotels[h][hExtPos][2]))
		{
			id = h;
			dist = GetPlayerDistanceFromPoint(playerid, Hotels[h][hExtPos][0], Hotels[h][hExtPos][1], Hotels[h][hExtPos][2]);
		}
	}
	return id;

}

stock CleanRoom(id, playerid = INVALID_PLAYER_ID)
{
	format(Hotels[id][hOwner], 25, "Nobody");
	Hotels[id][hTimeLeft] = 0;
	Hotels[id][hLock] = 1;
	UpdateHotelIcon(id);
	
	if(playerid != INVALID_PLAYER_ID)
	{
		format(string, sizeof(string), "[HotelRooms] %s has cleaned hotel room %d. (Pot: %d, Cocaine: %d, Speed: %d, Street Mats: %d, Standard Mats: %d, Military Mats: %d, Weapon: %d)", Player[playerid][NormalName], id, Hotels[id][hStorage][HOTEL_POT], Hotels[id][hStorage][HOTEL_COCAINE], Hotels[id][hStorage][HOTEL_SPEED], Hotels[id][hStorage][HOTEL_MATSLOW], Hotels[id][hStorage][HOTEL_MATSMID], Hotels[id][hStorage][HOTEL_MATSHIGH], Hotels[id][hStorage][HOTEL_WEAPON]);
		StatLog(string);
	}
	else 
	{
		format(string, sizeof(string), "[HotelRooms] The system has cleaned hotel room %d. (Pot: %d, Cocaine: %d, Speed: %d, Street Mats: %d, Standard Mats: %d, Military Mats: %d, Weapon: %d)", id, Hotels[id][hStorage][HOTEL_POT], Hotels[id][hStorage][HOTEL_COCAINE], Hotels[id][hStorage][HOTEL_SPEED], Hotels[id][hStorage][HOTEL_MATSLOW], Hotels[id][hStorage][HOTEL_MATSMID], Hotels[id][hStorage][HOTEL_MATSHIGH], Hotels[id][hStorage][HOTEL_WEAPON]);
		StatLog(string);
	}
	Hotels[id][hStorage][HOTEL_POT] = 0;
	Hotels[id][hStorage][HOTEL_COCAINE] = 0;
	Hotels[id][hStorage][HOTEL_SPEED] = 0;
	Hotels[id][hStorage][HOTEL_MATSLOW] = 0;
	Hotels[id][hStorage][HOTEL_MATSMID] = 0;
	Hotels[id][hStorage][HOTEL_MATSHIGH] = 0;
	Hotels[id][hStorage][HOTEL_WEAPON] = 0;
	SaveHotelRoom(id);
	return 1;
}

stock GetHotelRoomTotalStorage(id)
{
	return Hotels[id][hStorage][HOTEL_POT] + Hotels[id][hStorage][HOTEL_COCAINE] + Hotels[id][hStorage][HOTEL_SPEED] + Hotels[id][hStorage][HOTEL_MATSLOW] + Hotels[id][hStorage][HOTEL_MATSMID] + Hotels[id][hStorage][HOTEL_MATSHIGH];
}

CMD:setbusinesstotalhotels(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
		
	new amount, id;
	if(sscanf(params, "dd", id, amount))
		return SendClientMessage(playerid, GREY, "SYNTAX: /setbusinesstotalhotels [businessid] [amount]");

	if(!DoesBusinessExist(id))
		return SendClientMessage(playerid, WHITE, "Invalid business id!");
		
	if(amount > MAX_HOTELS_PER_BIZ || amount < 0)
		return SendClientMessage(playerid, WHITE, "Invalid amount.");
		
	format(string, sizeof(string), "You have changed the total hotel rooms to %d (was %d).", amount, Businesses[id][TotalHotelRooms]);
	Businesses[id][TotalHotelRooms] = amount;
	SaveBusiness(id);
	
	/*
	format(string, sizeof(string), "Businesses/Business_%d.ini", id);
	if(fexist(string))
	{
		Businesses[id][TotalHotelRooms] = amount;
		format(string, sizeof(string), "You have set business %d (%s)'s total hotel rooms to %d.", id, Businesses[id][bName], amount);
		SendClientMessage(playerid, WHITE, string);
		SaveBusiness(id);
	}
	else
	{
		SendClientMessage(playerid, WHITE, "Invalid business ID.");
	}
	*/
	return 1;
}