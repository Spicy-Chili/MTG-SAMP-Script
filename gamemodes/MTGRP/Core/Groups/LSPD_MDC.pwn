/*
#		MTG LSPD MDC
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

static string[640];

#define MDC_MAIN					20501
#define MDC_ANNOUCEMENTS			20502
#define MDC_PRISM_MAIN				20503
#define MDC_PRISM_PERSON			20504
#define MDC_PRISM_VEHICLE			20505
#define MDC_PRISM_RESULTS			20506
#define MDC_PRISM_TICKET			20507
//									20508
//									20509
//									20510
//									20511
//									20512
#define MDC_BOLO_MAIN				20513
#define MDC_BOLO_CREATE				20515
//									20516
#define MDC_BOLO_LIST				20517
#define MDC_BOLO_VIEW				20518
//									20519
#define	MDC_DISPATCH_MAIN			20520
//									20521
#define MDC_HC_MAIN					20522
//									20523
//									20524
#define MDC_ACCESS_DENIED			20525
#define MDC_PRISM_TRACK				20526
#define MDC_IMPOUND					20527
//									20528
#define MDC_LIGHTS_MAIN				20530
#define MDC_LIGHTS_SPEED			20531
#define MDC_911_CENTER				20532
#define MDC_911_VIEW				20533
#define MDC_LOADING_LOOKUP			20534

#define MAX_BOLOS	20
enum bolo_
{
	bool:boloIsBeingEdited,
	bool:boloIsActive,
	boloString[128],
	boloPriority,
	boloCreationDate[64],
	boloCreatedBy[MAX_PLAYER_NAME],
};
new Bolo[MAX_BOLOS][bolo_];

new mdcAnnoucement[640];
new Timer:TrackingVehicles[MAX_PLAYERS];
new VehicleIcon[MAX_PLAYERS][MAX_VEHICLES];

#define MAX_911_STORED		5

enum calls_
{
	Call_Location[MAX_ZONE_NAME],
	Call_Text[128],
	Call_PlacedByName[25],
	Call_Number,
};
static Calls[MAX_911_STORED][calls_], last911SlotUsed = -1;

// ============= Commands =============

CMD:mdc(playerid, params[])
{
	if(Groups[Player[playerid][Group]][CommandTypes] != 1)
		return 1;

	if(!IsPlayerInAnyVehicle(playerid))
		return SendClientMessage(playerid, -1, "You must be inside a cruiser to use this command!");

	new veh = GetPlayerVehicleID(playerid);
	new sql = GetVSQLID(veh), idx = GetVIndex(sql);

	if(Groups[Veh[idx][Group]][CommandTypes] != 1)
		return SendClientMessage(playerid, -1, "You must be inside a cruiser to use this command!");

	format(string, sizeof(string), "* %s flips open their MDC and logs in.", GetNameEx(playerid));
	NearByMessage(playerid, NICESKY, string);
	ShowMDCDialog(playerid, MDC_MAIN);
	return 1;
}

// ============= Callbacks =============

hook OnGameModeInit()
{
	for(new i; i < MAX_BOLOS; i++)
	{
		format(Bolo[i][boloString], 128, "None");
		Bolo[i][boloPriority] = 1;
	}
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case MDC_MAIN:
		{
			if(!response)
			{
				format(string, sizeof(string), "* %s logs out of their MDC and closes it.", GetNameEx(playerid));
				NearByMessage(playerid, NICESKY, string);
				return 1;
			}

			switch(listitem)
			{
				case 0: ShowMDCDialog(playerid, MDC_MAIN);
				case 1: ShowMDCDialog(playerid, MDC_ANNOUCEMENTS);
				case 2: ShowMDCDialog(playerid, MDC_PRISM_MAIN);
				case 3: ShowMDCDialog(playerid, MDC_BOLO_MAIN);
				case 4: ShowMDCDialog(playerid, MDC_911_CENTER);
				case 5:
				{
					if(Player[playerid][GroupRank] >= 4)
						ShowMDCDialog(playerid, MDC_DISPATCH_MAIN);
					else
						ShowMDCDialog(playerid, MDC_ACCESS_DENIED);
				}
				case 6:
				{
					if(Player[playerid][GroupRank] >= 7)
						ShowMDCDialog(playerid, MDC_HC_MAIN);
					else
						ShowMDCDialog(playerid, MDC_ACCESS_DENIED);
				}
				case 7: ShowMDCDialog(playerid, MDC_LIGHTS_MAIN);
			}
		}
		case MDC_ACCESS_DENIED, MDC_ANNOUCEMENTS:
		{
			if(!response)
			{
				format(string, sizeof(string), "* %s logs out of their MDC and closes it.", GetNameEx(playerid));
				NearByMessage(playerid, NICESKY, string);
				return 1;
			}
			ShowMDCDialog(playerid, MDC_MAIN);
		}
		case MDC_PRISM_MAIN:
		{
			if(!response)
				return ShowMDCDialog(playerid, MDC_MAIN);

			switch(listitem)
			{
				case 0:	ShowMDCDialog(playerid, MDC_PRISM_PERSON);
				case 1: ShowMDCDialog(playerid, MDC_PRISM_VEHICLE);
				case 2: ShowMDCDialog(playerid, MDC_PRISM_TRACK);
			}
		}
		case MDC_PRISM_VEHICLE:
		{
			if(!response)
				return ShowMDCDialog(playerid, MDC_PRISM_MAIN);

			if(strlen(inputtext) < 1)
			{
				SendClientMessage(playerid, YELLOW, "Invalid search parameters!");
				return ShowMDCDialog(playerid, MDC_PRISM_VEHICLE);
			}

			mysql_format(MYSQL_MAIN, string, sizeof(string), "SELECT sqlid FROM vehicles WHERE plate = '%e'", inputtext);
			mysql_tquery(MYSQL_MAIN, string, "OnPrismVehicleLookup", "d", playerid);
			ShowMDCDialog(playerid, MDC_LOADING_LOOKUP);
		}
		case MDC_PRISM_PERSON:
		{
			if(!response)
				return ShowMDCDialog(playerid, MDC_PRISM_MAIN);

			if(strlen(inputtext) < 1)
			{
				SendClientMessage(playerid, YELLOW, "Invalid search parameters!");
				return ShowMDCDialog(playerid, MDC_PRISM_PERSON);
			}

			new count;
			for(new t = 0, j = strlen(inputtext); t != j; t++)
			{
				if(inputtext[t] == ' ' && count == 0)
				{
					count++;
					inputtext[t] = '_';
				}
			}

			new id = -1;
			foreach(Player, i)
			{
				if(strcmp(inputtext, Player[i][NormalName], true) == 0)
				{
					id = i;
					break;
				}
			}
			
			if(id != -1)
			{
				new DMVRecords[128], sql, idx;
				for(new i; i < 5; i++)
				{
					sql = Player[id][Cars][i], idx = GetVIndex(sql);
					if(sql < 1)
						continue;

					if(Veh[idx][Registered])
					{
						format(DMVRecords, sizeof(DMVRecords), "%s%s | %s\n", DMVRecords,  vNames[Veh[idx][Model] - 400], Veh[idx][Plate]);
					}
				}
				if(isnull(DMVRecords))
					format(DMVRecords, sizeof(DMVRecords), "No DMV record found.");

				format(string, sizeof(string), "Lookup Results: \n\nName:          %s\nAge:            %d\nGender:        %s", inputtext, Player[id][Age], (Player[id][Gender] == 1) ? ("Male") : ("Female"));

				new house1[5], house2[5];
				if(Player[id][House] > 0 && Houses[Player[id][House]][hFakeOwner] < 1)
					format(house1, 5, "%s", IntToFormattedStr(Player[id][House]));
				else
					format(house1, 5, "None");
				
				if(Player[id][House2] > 0 && Houses[Player[id][House2]][hFakeOwner] < 1)
					format(house2, 5, "%s", IntToFormattedStr(Player[id][House2]));
				else
					format(house2, 5, "None");
					
				format(string, sizeof(string), "%s\nHouses:         %s , %s\nBusiness:      %s\nLicensed:       %s (%s)", string, house1, house2, (Player[id][Business] > 0) ? (IntToFormattedStr(Player[id][Business])) : ("None"), (Player[id][CarLicense] > 0) ? ("Yes") : ("No"), (Player[id][LicenseSuspended] > 0) ? ("Suspended") : ("Active"));

				format(string, sizeof(string), "%s\nLicense Strikes:          %d\nCriminal Record:          %d\n\nDMV Records:\n%s", string,(GetPlayerStrikes(Player[id][NormalName], 0) + GetPlayerStrikes(Player[id][NormalName], 1)), Player[id][CriminalOffences], DMVRecords);

				if(GetPlayerNumCrimes(Player[id][NormalName], 1) > 0)
					format(string, sizeof(string), "%s\n{AA3333}WANTED", string);
				SetPVarString(playerid, "MDC_Ticket_Name", Player[id][NormalName]);
			}
			else
			{
				format(string, sizeof(string), "No results found.((Player offline))");
				SetPVarInt(playerid, "CIVILIAN_LOOKUP_FAILED", 1);
				return ShowPlayerDialog(playerid, MDC_PRISM_RESULTS, DIALOG_STYLE_MSGBOX, "LSPD - PRISM - Civilian Lookup - Results", string, "Back", "");
			}
			ShowPlayerDialog(playerid, MDC_PRISM_RESULTS, DIALOG_STYLE_MSGBOX, "LSPD - PRISM - Civilian Lookup - Results", string, "Issue Ticket", "Back");
		}
		case MDC_PRISM_TRACK:
		{
			new number = strval(inputtext);

			if(number < 1 || !IsExistingPhoneNumber(number) || strval(GetPhoneInfo(number, "status")) == 0)
				return SendClientMessage(playerid, -1, "System cannot locate that number.");

			new id = GetPlayerIDEx(GetPhoneInfo(number, "owner"));

			if(!IsPlayerConnectedEx(id) || Player[id][AdminDuty] > 0 || Player[id][PrisonDuration] > 0 || Player[id][PrisonID] > 0)// || Spectator[id][SpecSpectatingPlayer] != -1 || Spectator[id][SpecSpectatingVehicle] != -1)
				return SendClientMessage(playerid, -1, "System cannot locate that number.");

			if(Player[playerid][TrackCooldown] > gettime())
			{
				format(string, sizeof(string), "You must wait %d seconds before you can track another number.", Player[playerid][TrackCooldown] - gettime());
				return SendClientMessage(playerid, WHITE, string);
			}

			if(Player[playerid][Checkpoint] > 0)
				return SendClientMessage(playerid, WHITE, "You already have an existing checkpoint. Reach it first.");

			new world = GetPlayerVirtualWorld(id);

			if(world > 0)
			{
				if(world == VipLoungeVW)
					SetPlayerCheckpoint(playerid, VipLounge[0], VipLounge[1], VipLounge[2], 6.0);
				else if(Player[id][InBusiness] != 0)
					SetPlayerCheckpoint(playerid, Businesses[Player[id][InBusiness]][bExteriorX], Businesses[Player[id][InBusiness]][bExteriorY], Businesses[Player[id][InBusiness]][bExteriorZ], 6.0);
				else if(Player[id][InHouse] != 0)
					SetPlayerCheckpoint(playerid, Houses[Player[id][InHouse]][hExteriorX], Houses[Player[id][InHouse]][hExteriorY], Houses[Player[id][InHouse]][hExteriorZ], 6.0);
				else if(Player[id][InGroupHQ] != 0)
					SetPlayerCheckpoint(playerid, Groups[Player[id][InGroupHQ]][HQExteriorX], Groups[Player[id][InGroupHQ]][HQExteriorY], Groups[Player[id][InGroupHQ]][HQExteriorZ], 6.0);
				else
					return SendClientMessage(playerid, -1, "Unable to locate the targets current building.");
				SendClientMessage(playerid, WHITE, "A checkpoint has been set, the phone was traced inside the marked building.");
			}
			else
			{
				new Float:pPos[3];
				GetPlayerPos(id, pPos[0], pPos[1], pPos[2]);
				SetPlayerCheckpoint(playerid, pPos[0], pPos[1], pPos[2], 6.0);
				SendClientMessage(playerid, WHITE, "A checkpoint has been set, the phone was traced in at the marked area.");
			}

			if(Groups[Player[playerid][Group]][CommandTypes] != 2)
				Player[playerid][BankMoney] -= 150;

			format(string, sizeof(string), "[Track] %s has tracked %s. (%d) (Tracked through the MDC)", Player[playerid][NormalName], Player[id][NormalName], number);
			CommandsLog(string);
			Player[playerid][TrackCooldown] = gettime() + 60;
			Player[playerid][Checkpoint] = 1;
			Player[playerid][Detecting] = 1;
		}
		case MDC_PRISM_RESULTS:
		{
			if(GetPVarInt(playerid, "CIVILIAN_LOOKUP_FAILED") == 1 || (GetPVarInt(playerid, "MDC_PRISM_Vehicle") == 1 && response == 0))
			{
				DeletePVar(playerid, "CIVILIAN_LOOKUP_FAILED");
				DeletePVar(playerid, "MDC_PRISM_Vehicle");
				return ShowPlayerDialog(playerid, MDC_PRISM_MAIN, DIALOG_STYLE_LIST, "LSPD - Prism Lookup", "{FFFFFF}Civilian Lookup\nVehicle Lookup\niSpy Phone Tracking", "Select", "Back");
			}
			else if(GetPVarInt(playerid, "MDC_PRISM_Vehicle") == 1 && response == 1)
			{
				DeletePVar(playerid, "MDC_PRISM_Vehicle");
				format(string, sizeof(string), "* %s logs out of their MDC and closes it.", GetNameEx(playerid));
				NearByMessage(playerid, NICESKY, string);
				return 1;
			}
		
			if(GetPVarInt(playerid, "MDC_PRISM_Vehicle") == 0 && response == 1)
				return ShowMDCDialog(playerid, MDC_PRISM_TICKET);
			
			if(GetPVarInt(playerid, "MDC_PRISM_Vehicle") == 0 && response == 0)
				return ShowPlayerDialog(playerid, MDC_PRISM_MAIN, DIALOG_STYLE_LIST, "LSPD - Prism Lookup", "{FFFFFF}Civilian Lookup\nVehicle Lookup\niSpy Phone Tracking", "Select", "Back");
		}
		case MDC_PRISM_TICKET:
		{
			if(!response)
			{
				format(string, sizeof(string), "* %s logs out of their MDC and closes it.", GetNameEx(playerid));
				NearByMessage(playerid, NICESKY, string);
				return 1;
			}

			switch(listitem)
			{
				case 0: ShowMDCDialog(playerid, MDC_PRISM_TICKET + 1);
				case 1:	ShowMDCDialog(playerid, MDC_PRISM_TICKET + 2);
				case 2: ShowMDCDialog(playerid, MDC_PRISM_TICKET + 3);
				case 3: ShowMDCDialog(playerid, MDC_PRISM_TICKET + 4);
				case 4:
				{
					new query[255], offence[64], offender[MAX_PLAYER_NAME], second, minute, hour, day, month, year, time[64];
					gettime(hour, minute, second);
					getdate(year, month, day);
					format(time, sizeof(time), "%d/%d/%d at %02d:%02d:%02d", month, day, year, (hour + 4 >= 24) ? ((hour + 4) - 24) : (hour + 4), minute, second);
					GetPVarString(playerid, "MDC_Ticket_Offense", offence, sizeof(offence));
					GetPVarString(playerid, "MDC_Ticket_Name", offender, sizeof(offender));
					SetPVarString(playerid, "MDC_Ticket_Time", time);
					
					if(strlen(offence) < 1)
						return SendClientMessage(playerid, -1, "You must enter an offence!");

					if(!IsPlayerRegistered(offender))
						return SendClientMessage(playerid, -1, "That account doesn't exist.");

					if(GetPVarInt(playerid, "MDC_Ticket_Amount") < 1)
						return SendClientMessage(playerid, -1, "You must enter a fine amount.");
						
					if(GetPVarInt(playerid, "MDC_Ticket_Amount") > 10000)
						return SendClientMessage(playerid, -1, "The maximum ticket price is $10000.");

					mysql_format(MYSQL_MAIN, query, sizeof(query), "INSERT INTO PoliceTickets (offense, offenderName, officerName, ticketAmount, timeGiven, strikesIssued, Active, StrikesExpired) VALUES (\'%e\', \'%e\', \'%e\', \'%d\', \'%e\', \'%d\', \'%d\', \'0\')", offence, offender, Player[playerid][NormalName], GetPVarInt(playerid, "MDC_Ticket_Amount"), time, GetPVarInt(playerid, "MDC_Ticket_Strikes"), 1);
					mysql_query(MYSQL_MAIN, query, false);

					SendClientMessage(playerid, WHITE, "----------------------------------------------------------------------------");
					SendClientMessage(playerid, GREY, "Database entry added!");
					SendClientMessage(playerid, GREY, query);
					SendClientMessage(playerid, GREY, "Details:");
					format(query, sizeof(query), "Time: %s | Name: %s", time, offender);
					SendClientMessage(playerid, GREY, query);
					format(query, sizeof(query), "Offences: %s | Amount: %s | Strikes Issued: %d", offence, PrettyMoney(GetPVarInt(playerid, "MDC_Ticket_Amount")), GetPVarInt(playerid, "MDC_Ticket_Strikes"));
					SendClientMessage(playerid, GREY, query);
					SendClientMessage(playerid, WHITE, "----------------------------------------------------------------------------");
					format(query, sizeof(query), "[TICKET] %s has been added to the ticket database by %s for $%d.", offender, Player[playerid][NormalName], GetPVarInt(playerid, "MDC_Ticket_Amount"));
					MoneyLog(query);
					format(query, sizeof(query), "* %s grabs a receipt for a ticket from the MDC.", GetNameEx(playerid));
					NearByMessage(playerid, NICESKY, query);
					SetPVarInt(playerid, "MDCTicket", 1);

					new pid = GetPlayerID(offender);
					if(pid != INVALID_PLAYER_ID) {
						if(GetPlayerStrikes(offender) >= 10 && Player[pid][LicenseSuspended] == 0)
							ShowMDCDialog(playerid, MDC_PRISM_TICKET + 5);
						else DeletePVar(playerid, "MDC_Ticket_Name");
					}
					else
					{
						if(IsPlayerRegistered(offender)) {
							new suspended = GetRemoteIntValue(offender, "LicenseSuspended");
							if(GetPlayerStrikes(offender) >= 5 && suspended == 0)
								ShowMDCDialog(playerid, MDC_PRISM_TICKET + 5);
							else DeletePVar(playerid, "MDC_Ticket_Name");
						}
					}

				//	DeletePVar(playerid, "MDC_Ticket_Amount");
				//	DeletePVar(playerid, "MDC_Ticket_Strikes");
				//	DeletePVar(playerid, "MDC_Ticket_Offense");
				}
			}
		}
		case MDC_PRISM_TICKET + 1:
		{
			new count;
			for(new t = 0, j = strlen(inputtext); t != j; t++)
			{
				if(inputtext[t] == ' ' && count == 0)
				{
					count++;
					inputtext[t] = '_';
				}
			}

			if(!response)
			{
				return ShowMDCDialog(playerid, MDC_PRISM_TICKET);
			}

			new name[MAX_PLAYER_NAME], offense[64];
			GetPVarString(playerid, "MDC_Ticket_Offense", offense, sizeof(offense));
			GetPVarString(playerid, "MDC_Ticket_Name", name, sizeof(name));
			format(name, sizeof(name), "%s", inputtext);
			new pID = GetPlayerID(name);

			if(!IsPlayerConnected(pID))
			{
				if(!IsPlayerRegistered(name))
					return SendClientMessage(playerid, -1, "((That account name doesn't exist!))");

				SendClientMessage(playerid, RED, "((That player isn't online!))");
				return ShowMDCDialog(playerid, MDC_PRISM_TICKET);
			}

			SetPVarString(playerid, "MDC_Ticket_Name", name);
			ShowMDCDialog(playerid, MDC_PRISM_TICKET);
		}
		case MDC_PRISM_TICKET + 2:
		{
			if(!response)
				return ShowMDCDialog(playerid, MDC_PRISM_TICKET);


			SetPVarString(playerid, "MDC_Ticket_Offense", inputtext);
			ShowMDCDialog(playerid, MDC_PRISM_TICKET);
		}
		case MDC_PRISM_TICKET + 3:
		{
			if(!response)
				return ShowMDCDialog(playerid, MDC_PRISM_TICKET);

			new amount = strval(inputtext);
			if(amount < 0)
			{
				SendClientMessage(playerid, YELLOW, "You can't ticket for a negative amount!");
				return ShowMDCDialog(playerid, MDC_PRISM_TICKET);
			}

			SetPVarInt(playerid, "MDC_Ticket_Amount", amount);
			ShowMDCDialog(playerid, MDC_PRISM_TICKET);
		}
		case MDC_PRISM_TICKET + 4:
		{
			if(!response)
				return ShowMDCDialog(playerid, MDC_PRISM_TICKET);

			new amount = strval(inputtext);
			if(amount < 0)
			{
				SendClientMessage(playerid, YELLOW, "You can't give a negative amount of strikes.");
				return ShowMDCDialog(playerid, MDC_PRISM_TICKET);
			}

			SetPVarInt(playerid, "MDC_Ticket_Strikes", amount);
			ShowMDCDialog(playerid, MDC_PRISM_TICKET);
		}
		case MDC_PRISM_TICKET + 5:
		{
			if(!response)
				return 1;

			new offender[MAX_PLAYER_NAME], pid;
			GetPVarString(playerid, "MDC_Ticket_Name", offender, sizeof(offender));
			pid = GetPlayerID(offender);
			if(pid != INVALID_PLAYER_ID)
			{
				Player[pid][LicenseSuspended] = gettime() + 604800;
			}
			else
			{
				new query[255];
				mysql_format(MYSQL_MAIN, query, sizeof(query), "UPDATE playeraccounts SET LicenseSuspended = '%d' WHERE NormalName = '%e'", gettime() + 604800, offender);
				mysql_query(MYSQL_MAIN, query, false);
			}

			format(string, sizeof(string), "You have suspended %s license for one week!", offender);
			SendClientMessage(playerid, -1, string);
			format(string, sizeof(string), "[TICKET]%s has suspended %s license for one week.", Player[playerid][NormalName], offender);
			StatLog(string);
			ShowMDCDialog(playerid, MDC_MAIN);
		}
		case MDC_BOLO_MAIN:
		{
			if(!response)
				return ShowMDCDialog(playerid, MDC_MAIN);

			switch(listitem)
			{
				case 0: ShowMDCDialog(playerid, MDC_BOLO_LIST);
				case 1:
				{
					new id = GetUnusedBolo();
					if(id == -1)
					{
						SendClientMessage(playerid, YELLOW, "You can't create anymore BOLOs!");
						return ShowMDCDialog(playerid, MDC_BOLO_MAIN);
					}
					Bolo[id][boloIsBeingEdited] = true;
					SetPVarInt(playerid, "MDC_Bolo_Create", id);
					return ShowMDCDialog(playerid, MDC_BOLO_CREATE);
				}
				case 2:
				{
					SetPVarInt(playerid, "MDC_Bolo_Remove", 1);
					return ShowMDCDialog(playerid, MDC_BOLO_LIST);
				}
			}
		}
		case MDC_BOLO_CREATE:
		{
			new id = GetPVarInt(playerid, "MDC_Bolo_Create");
			if(!response)
			{
				Bolo[id][boloString][0] = EOS;
				Bolo[id][boloPriority] = 1;
				Bolo[id][boloIsBeingEdited] = false;
				return ShowMDCDialog(playerid, MDC_BOLO_MAIN);
			}

			switch(listitem)
			{
				case 0: ShowMDCDialog(playerid, MDC_BOLO_CREATE + 1);
				case 1:
				{
					if(Bolo[id][boloPriority] == 1)
						Bolo[id][boloPriority] = 2;
					else if(Bolo[id][boloPriority] == 2)
						Bolo[id][boloPriority] = 3;
					else if(Bolo[id][boloPriority] == 3)
						Bolo[id][boloPriority] = 1;
					return ShowMDCDialog(playerid, MDC_BOLO_CREATE);
				}
				case 2:
				{
					Bolo[id][boloIsActive] = true;
					Bolo[id][boloIsBeingEdited] = false;
					format(Bolo[id][boloCreationDate], 64, "[%s]", GetDate());
					format(Bolo[id][boloCreatedBy], MAX_PLAYER_NAME, "%s", Player[playerid][NormalName]);
					SendClientMessage(playerid, YELLOW, "You have successfully create a BOLO.");
					ShowMDCDialog(playerid, MDC_BOLO_MAIN);
				}
			}
		}
		case MDC_BOLO_CREATE + 1:
		{
			new id = GetPVarInt(playerid, "MDC_Bolo_Create");
			if(!response)
				return ShowMDCDialog(playerid, MDC_BOLO_CREATE);

			if(isnull(inputtext))
			{
				SendClientMessage(playerid, YELLOW, "Invalid message.");
				return ShowMDCDialog(playerid, MDC_BOLO_CREATE);
			}

			format(Bolo[id][boloString], 128, "%s", inputtext);
			ShowMDCDialog(playerid, MDC_BOLO_CREATE);
		}
		case MDC_BOLO_LIST:
		{
			if(!response)
				return ShowMDCDialog(playerid, MDC_BOLO_MAIN);

			new input[32];
			format(input, sizeof(input), "%s", inputtext);
			new id = strval(CutBeforeLine(input));
			SetPVarInt(playerid, "MDC_Bolo_View", id);
			if(GetPVarInt(playerid, "MDC_Bolo_Remove") == 1)
			{
				DeletePVar(playerid, "MDC_Bolo_Remove");
				return ShowMDCDialog(playerid, MDC_BOLO_VIEW + 1);
			}
			else ShowMDCDialog(playerid, MDC_BOLO_VIEW);
		}
		case MDC_BOLO_VIEW:
		{
			if(!response)
			{
				format(string, sizeof(string), "* %s logs out of their MDC and closes it.", GetNameEx(playerid));
				NearByMessage(playerid, NICESKY, string);
				return 1;
			}
			ShowMDCDialog(playerid, MDC_BOLO_LIST);
		}
		case MDC_BOLO_VIEW + 1:
		{
			if(!response)
				return ShowMDCDialog(playerid, MDC_BOLO_LIST);

			new id = GetPVarInt(playerid, "MDC_Bolo_View");
			if(Player[playerid][GroupRank] < 4 && strcmp(Player[playerid][NormalName], Bolo[id][boloCreatedBy], true))
			{
				SendClientMessage(playerid, YELLOW, "This BOLO wasn't placed by you.");
				DeletePVar(playerid, "MDC_Bolo_View");
				DeletePVar(playerid, "MDC_Bolo_Remove");
				return ShowMDCDialog(playerid, MDC_MAIN);
			}
			
			Bolo[id][boloIsActive] = false;
			Bolo[id][boloPriority] = 1;
			Bolo[id][boloString][0] = EOS;

			DeletePVar(playerid, "MDC_Bolo_View");
			DeletePVar(playerid, "MDC_Bolo_Remove");
			format(string, sizeof(string), "You have removed BOLO #%d.", id);
			SendClientMessage(playerid, YELLOW, string);
			return ShowMDCDialog(playerid, MDC_BOLO_MAIN);
		}
		case MDC_DISPATCH_MAIN:
		{
			if(!response)
				return ShowMDCDialog(playerid, MDC_MAIN);

			switch(listitem)
			{
				case 0:	ShowMDCDialog(playerid, MDC_DISPATCH_MAIN + 1);
				case 1:
				{
					if(GetPVarInt(playerid, "TrackingLSPDVehicles") == 1)
					{
						SendClientMessage(playerid, YELLOW, "LSPD Vehicle GPS locations will no longer be on your map.");
						SetPVarInt(playerid, "TrackingLSPDVehicles", 0);
						stop TrackingVehicles[playerid];

						for(new i; i < MAX_VEHICLES; i++)
						{
							if(IsValidDynamicMapIcon(VehicleIcon[playerid][i]))
								DestroyDynamicMapIcon(VehicleIcon[playerid][i]);
						}

					}
					else
					{
						SendClientMessage(playerid, YELLOW, "LSPD Vehicle GPS locations will now be on your map.");
						SetPVarInt(playerid, "TrackingLSPDVehicles", 1);
						TrackingVehicles[playerid] = repeat TrackLSPDVehicles(playerid);
					}

					return ShowMDCDialog(playerid, MDC_DISPATCH_MAIN);
				}
			}
		}
		case MDC_DISPATCH_MAIN + 1:
		{
			if(!response)
				return ShowMDCDialog(playerid, MDC_DISPATCH_MAIN);

			if(isnull(inputtext))
			{
				SendClientMessage(playerid, YELLOW, "Invalid entry.");
				return ShowMDCDialog(playerid, MDC_DISPATCH_MAIN);
			}
			new Cache:cache, idx, sqlid;
			mysql_format(MYSQL_MAIN, string, sizeof(string), "SELECT sqlid FROM vehicles WHERE plate = '%e'", inputtext);
			cache = mysql_query(MYSQL_MAIN, string);

			if(cache_get_row_count() < 1)
			{
				SendClientMessage(playerid, YELLOW, "The GPS could not find that vehicle.");
				return ShowMDCDialog(playerid, MDC_DISPATCH_MAIN);
			}
			else
			{
				sqlid = cache_get_field_content_int(0, "sqlid");
				cache_delete(cache);

				idx = GetVIndex(sqlid);

				if(Veh[idx][Group] != Player[playerid][Group])
				{
					SendClientMessage(playerid, YELLOW, "The GPS could not find that vehicle.");
					return ShowMDCDialog(playerid, MDC_DISPATCH_MAIN);
				}

				new Float:pos[3];
				GetVehiclePos(Veh[idx][Link], pos[0], pos[1], pos[2]);
				SetPlayerCheckpoint(playerid, pos[0], pos[1], pos[2], 10);
				Player[playerid][Checkpoint] = 17000;
				SendClientMessage(playerid, YELLOW, "A GPS checkpoint has been placed at that vehicle's location.");
				return ShowMDCDialog(playerid, MDC_DISPATCH_MAIN);
			}
		}
		case MDC_HC_MAIN:
		{
			if(!response)
				return ShowMDCDialog(playerid, MDC_MAIN);

			switch(listitem)
			{
				case 0: ShowMDCDialog(playerid, MDC_HC_MAIN + 1);
				case 1: ShowMDCDialog(playerid, MDC_IMPOUND);
			}
		}
		case MDC_HC_MAIN + 1:
		{
			if(!response)
				return ShowMDCDialog(playerid, MDC_HC_MAIN);

			switch(listitem)
			{
				case 0: ShowMDCDialog(playerid, MDC_HC_MAIN + 2);
				case 1:
				{
					SetPVarInt(playerid, "MDC_HC_Append", 1);
					ShowMDCDialog(playerid, MDC_HC_MAIN + 2);
				}
				case 2:
				{
					mdcAnnoucement[0] = EOS;
					SendClientMessage(playerid, YELLOW, "You have deleted the MDC annoucement.");
					ShowMDCDialog(playerid, MDC_HC_MAIN);
				}
			}
		}
		case MDC_HC_MAIN + 2:
		{
			if(!response)
				return ShowMDCDialog(playerid, MDC_HC_MAIN + 1);

			if(isnull(inputtext))
			{
				SendClientMessage(playerid, YELLOW, "Invalid entry!");
				return ShowMDCDialog(playerid, MDC_HC_MAIN + 1);
			}

			if(GetPVarInt(playerid, "MDC_HC_Append") == 1)
			{
				format(mdcAnnoucement, sizeof(mdcAnnoucement), "%s %s", mdcAnnoucement, inputtext);
				SendClientMessage(playerid, YELLOW, "You have successfully added onto the current annoucement.");
				ShowMDCDialog(playerid, MDC_HC_MAIN + 1);
			}
			else
			{
				format(mdcAnnoucement, sizeof(mdcAnnoucement), "%s", inputtext);
				SendClientMessage(playerid, YELLOW, "You have successfully overwritten the MDC annoucement with a new one.");
				ShowMDCDialog(playerid, MDC_HC_MAIN + 1);
			}
		}
		case MDC_IMPOUND:
		{
			if(!response)
				return ShowMDCDialog(playerid, MDC_HC_MAIN), DeletePVar(playerid, "MDC_IMPOUND_PAGE");

			if(!strcmp(inputtext, "Next", true))
			{
				SetPVarInt(playerid, "MDC_IMPOUND_PAGE", GetPVarInt(playerid, "MDC_IMPOUND_PAGE") + 1);
				ShowMDCDialog(playerid, MDC_IMPOUND);
			}
			else if(!strcmp(inputtext, "Back", true))
			{
				SetPVarInt(playerid, "MDC_IMPOUND_PAGE", GetPVarInt(playerid, "MDC_IMPOUND_PAGE") - 1);
				ShowMDCDialog(playerid, MDC_IMPOUND);
			}
			else
			{
				new page = GetPVarInt(playerid, "MDC_IMPOUND_PAGE"), row = (listitem + (page * 9));

				new Cache:cache = mysql_query(MYSQL_MAIN, "SELECT * FROM vehicles WHERE impounded = '1'");

				new sqlid = cache_get_field_content_int(row, "sqlid");

				SetPVarInt(playerid, "MDC_IMPOUND_SQLIDVIEW", sqlid);
				DeletePVar(playerid, "MDC_IMPOUND_PAGE");
				cache_delete(cache);
				ShowMDCDialog(playerid, MDC_IMPOUND + 1);
			}
		}
		case MDC_IMPOUND + 1:
		{
			if(!response)
				return ShowMDCDialog(playerid, MDC_HC_MAIN), DeletePVar(playerid, "MDC_IMPOUND_SQLIDVIEW");

			new sqlid = GetPVarInt(playerid, "MDC_IMPOUND_SQLIDVIEW"), query[128];
			mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT * FROM vehicles WHERE sqlid = '%d'", sqlid);
			new Cache:cache = mysql_query(MYSQL_MAIN, query);

			if(cache_get_row_count() == 0)
				return SendClientMessage(playerid, -1, "An error occured: Could not find vehicle in database."), ShowMDCDialog(playerid, MDC_HC_MAIN);

			new imp_count = cache_get_field_content_int(0, "impoundcount");
			new imped = cache_get_field_content_int(0, "impounded");
			cache_delete(cache);

			if(!imped)
				return SendClientMessage(playerid, WHITE, "An error occurred: That vehicle is no longer impounded."), ShowMDCDialog(playerid, MDC_HC_MAIN);

			if(imp_count < 3)
				return SendClientMessage(playerid, WHITE, "You cannot crush this vehicle as it has not met the requirements (3 total impounds)"), ShowMDCDialog(playerid, MDC_HC_MAIN);

			ShowMDCDialog(playerid, MDC_IMPOUND + 2);
		}
		case MDC_IMPOUND + 2:
		{
			if(!response)
				return ShowMDCDialog(playerid, MDC_HC_MAIN), DeletePVar(playerid, "MDC_IMPOUND_SQLIDVIEW");

			if(Groups[Player[playerid][Group]][CommandTypes] != 1 || Player[playerid][GroupRank] < 7)
				return SendClientMessage(playerid, WHITE, "You can't do this as you're not in the LSPD or not high enough rank."), DeletePVar(playerid, "MDC_IMPOUND_SQLIDVIEW");

			if(strcmp(inputtext, "CoNfIrM", false))
				return SendClientMessage(playerid, WHITE, "You did not type it with the correct uppercase and lowercase letters."), DeletePVar(playerid, "MDC_IMPOUND_SQLIDVIEW");

			new sqlid = GetPVarInt(playerid, "MDC_IMPOUND_SQLIDVIEW");
			new idx = GetVIndex(sqlid);
			if(idx != -1)
			{
				new id = GetPlayerIDEx(Veh[idx][Owner]);
				if(IsSQLVehicleSpawned(Veh[idx][SQLID]))
					DespawnVehicleSQL(Veh[idx][SQLID]);

				if(id != INVALID_PLAYER_ID)
				{
					for(new i; i < 5; i++)
					{
						if(Player[id][Cars][i] == Veh[idx][SQLID])
						{
							Player[id][Cars][i] = 0;
							break;
						}
					}
				}

				ResetVCell(idx);
			}

			mysql_format(MYSQL_MAIN, string, sizeof(string), "DELETE FROM vehicles WHERE sqlid = '%d'", sqlid);
			mysql_query(MYSQL_MAIN, string, false);

			format(string, sizeof(string), "[CAR] %s has deleted the car with SQLID %d via impound crush.", Player[playerid][NormalName], sqlid);
			StatLog(string);

			format(string, sizeof(string), "WARNING: %s has deleted vehicle SQLID %d via impound crush!", Player[playerid][NormalName], sqlid);
			SendToAdmins(ADMINORANGE, string, 0);
			WarningLog(string);
			SendClientMessage(playerid, WHITE, "You have crushed the vehicle!");
			DeletePVar(playerid, "MDC_IMPOUND_SQLIDVIEW");
		}
		case MDC_LIGHTS_MAIN:
		{
			if(!response)
				return ShowMDCDialog(playerid, MDC_MAIN);

			switch(listitem)
			{
				case 0:
				{
					new veh = GetPlayerVehicleID(playerid);
					new sql = GetVSQLID(veh), idx = GetVIndex(sql);

					new engine, lights, alarm, doors, bonnet, boot, panels, tires, objective;
					GetVehicleParamsEx(veh, engine, lights, alarm, doors, bonnet, boot, objective);

					if(Veh[idx][IndicatorType] == INDICATOR_TYPE_OFF)
					{
						if(lights == 0)
							SetVehicleParamsEx(veh, engine, 1, alarm, doors, bonnet, boot, objective);

						if(Veh[idx][IndicatorSpeed] == 0)
							Veh[idx][IndicatorSpeed] = 250;

						stop Veh[idx][IndicatorTimer];
						UpdateVehicleDamageStatus(veh, panels, doors, encode_lights(1, 0, 0, 0), tires);
						Veh[idx][IndicatorStep] = 1;
						Veh[idx][IndicatorType] = INDICATOR_TYPE_SIRENS;
						Veh[idx][IndicatorTimer] = repeat Veh_IndicatorLights[Veh[idx][IndicatorSpeed]](veh);
						SendClientMessage(playerid, WHITE, "You have enabled the vehicle's emergency lights.");
					}
					else
					{
						stop Veh[idx][IndicatorTimer];
						Veh[idx][IndicatorType] = INDICATOR_TYPE_OFF;
						GetVehicleDamageStatus(veh, panels, doors, lights, tires);
						UpdateVehicleDamageStatus(veh, panels, doors, encode_lights(0, 0, 0, 0), tires);
						SendClientMessage(playerid, WHITE, "You have disabled the vehicles emergency lights.");
					}
				}
				case 1:
				{
					new veh = GetPlayerVehicleID(playerid);
					new sql = GetVSQLID(veh), idx = GetVIndex(sql);

					switch(Veh[idx][AutoIndicatorsDisabled])
					{
						case 0:
						{
							SendClientMessage(playerid, WHITE, "You have disabled this vehicle's automatic emergency lights.");
							Veh[idx][AutoIndicatorsDisabled] = 1;
						}
						case 1:
						{
							SendClientMessage(playerid, WHITE, "You have enabled this vehicle's automatic emergency lights.");
							Veh[idx][AutoIndicatorsDisabled] = 0;
						}
					}
				}
				case 2: ShowMDCDialog(playerid, MDC_LIGHTS_SPEED);
			}
		}
		case MDC_LIGHTS_SPEED:
		{
			if(!response)
				return ShowMDCDialog(playerid, MDC_LIGHTS_MAIN);

			new veh = GetPlayerVehicleID(playerid);
			new sql = GetVSQLID(veh), idx = GetVIndex(sql);

			switch(listitem)
			{
				case 0:
				{
					Veh[idx][IndicatorSpeed] = 150;
					if(Veh[idx][IndicatorType] != INDICATOR_TYPE_OFF)
					{
						stop Veh[idx][IndicatorTimer];
						Veh[idx][IndicatorTimer] = repeat Veh_IndicatorLights[Veh[idx][IndicatorSpeed]](veh);
					}
					SendClientMessage(playerid, WHITE, "You have set this vehicle's indicator speed to super fast.");
				}
				case 1:
				{
					Veh[idx][IndicatorSpeed] = 250;
					if(Veh[idx][IndicatorType] != INDICATOR_TYPE_OFF)
					{
						stop Veh[idx][IndicatorTimer];
						Veh[idx][IndicatorTimer] = repeat Veh_IndicatorLights[Veh[idx][IndicatorSpeed]](veh);
					}
					SendClientMessage(playerid, WHITE, "You have set this vehicle's indicator speed to fast.");
				}
				case 2:
				{
					Veh[idx][IndicatorSpeed] = 500;
					if(Veh[idx][IndicatorType] != INDICATOR_TYPE_OFF)
					{
						stop Veh[idx][IndicatorTimer];
						Veh[idx][IndicatorTimer] = repeat Veh_IndicatorLights[Veh[idx][IndicatorSpeed]](veh);
					}
					SendClientMessage(playerid, WHITE, "You have set this vehicle's indicator speed to slow.");
				}
			}
		}
		case MDC_911_CENTER:
		{
			if(!response)
				return ShowMDCDialog(playerid, MDC_MAIN);
				
			if(!strcmp(inputtext, "No 911 calls found...", true))
				return ShowMDCDialog(playerid, MDC_MAIN);
			
			new slot = listitem;
			format(string, sizeof(string), "{FFFFFF}911 Call Information\n\nPlaced by:\t%s (%d)\nLocation:\t%s\n\nInformation:\n%s", Calls[slot][Call_PlacedByName], Calls[slot][Call_Number], Calls[slot][Call_Location], Calls[slot][Call_Text]);
			ShowPlayerDialog(playerid, MDC_911_VIEW, DIALOG_STYLE_MSGBOX, "LSPD - 911 Call Center - View 911 Call Info", string, "Back", "");
		}
		case MDC_911_VIEW:	return ShowMDCDialog(playerid, MDC_911_CENTER);
		case MDC_LOADING_LOOKUP: return ShowMDCDialog(playerid, MDC_LOADING_LOOKUP);
	}
	return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	for(new i; i < MAX_VEHICLES; i++)
	{
		if(IsValidDynamicMapIcon(VehicleIcon[playerid][i]))
			DestroyDynamicMapIcon(VehicleIcon[playerid][i]);
	}
	stop TrackingVehicles[playerid];
	return 1;
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_ONFOOT)
	{
		if(GetPVarInt(playerid, "TrackingLSPDVehicles") == 1)
		{
			for(new i; i < MAX_VEHICLES; i++)
			{
				if(IsValidDynamicMapIcon(VehicleIcon[playerid][i]))
					DestroyDynamicMapIcon(VehicleIcon[playerid][i]);
			}
			SetPVarInt(playerid, "TrackingLSPDVehicles", 0);
			stop TrackingVehicles[playerid];
		}
	}
	return 1;
}

hook OnPlayerEnterCheckpoint(playerid)
{
	if(Player[playerid][Checkpoint] == 17000)
	{
		DisablePlayerCheckpoint(playerid);
		Player[playerid][Checkpoint] = 0;
	}
	return 1;
}

// ============= Functions / Timers =============

timer TrackLSPDVehicles[5000](pid)
{
	new Float:pos[3];

	for(new i; i < MAX_VEHICLES; i++)
	{
		if(IsValidVehicle(i))
		{
			if(Veh[i][Group] == Player[pid][Group])
			{
				if(IsValidDynamicMapIcon(VehicleIcon[pid][i]))
					DestroyDynamicMapIcon(VehicleIcon[pid][i]);

				GetVehiclePos(Veh[i][Link], pos[0], pos[1], pos[2]);
				VehicleIcon[pid][i] = CreateDynamicMapIcon(pos[0], pos[1], pos[2], 55, WHITE, -1, -1, pid, 5000);
			}
		}
	}
	return 1;
}

stock ShowMDCDialog(playerid, dialogid)
{
	switch(dialogid)
	{
		case MDC_MAIN: ShowPlayerDialog(playerid, MDC_MAIN, DIALOG_STYLE_LIST, "Los Santos Police Department - MDC", "{1229FA}-Los Santos Police Deparment - Mobile Database Computer-\n{FFFFFF}Latest Announcement\nPrism Lookup\nBOLO Center\n911 Center\nDispatch Center\nHigh Command Center\nVehicle Light Controls", "Select", "Log Out");
		case MDC_ACCESS_DENIED: ShowPlayerDialog(playerid, MDC_ACCESS_DENIED, DIALOG_STYLE_MSGBOX, "LSPD - Access Denied", "{F81414}ACCESS DENIED\n {FFFFFF}You do not have access to this section of the Los Santos Police Deparment Mobile Database.", "Go back", "Log out");
		case MDC_ANNOUCEMENTS:
		{
			if(isnull(mdcAnnoucement) )
			{
				SendClientMessage(playerid, YELLOW, "There is no annoucement at this time.");
				return ShowMDCDialog(playerid, MDC_MAIN);
			}
			ShowPlayerDialog(playerid, MDC_ANNOUCEMENTS, DIALOG_STYLE_MSGBOX, "LSPD - Latest Annoucement", AddNewLines(mdcAnnoucement), "Go back", "Log out");
		}
		case MDC_PRISM_MAIN: ShowPlayerDialog(playerid, MDC_PRISM_MAIN, DIALOG_STYLE_LIST, "LSPD - Prism Lookup", "{FFFFFF}Civilian Lookup\nVehicle Lookup\niSpy Phone Tracking", "Select", "Back");
		case MDC_PRISM_PERSON: ShowPlayerDialog(playerid, MDC_PRISM_PERSON, DIALOG_STYLE_INPUT, "LSPD - PRISM - Civilian Lookup", "{FFFFFF}Enter the name you wish to lookup.", "Enter", "Back");
		case MDC_PRISM_VEHICLE: ShowPlayerDialog(playerid, MDC_PRISM_VEHICLE, DIALOG_STYLE_INPUT, "LSPD - PRISM - Vehicle Lookup", "{FFFFFF}Enter the license plate you wish to lookup.", "Enter", "Back");
		case MDC_PRISM_TRACK: ShowPlayerDialog(playerid, MDC_PRISM_TRACK, DIALOG_STYLE_INPUT, "LSPD - PRISM - iSpy Phone Tracking", "{FFFFFF}Enter the phone number you wish to track.", "Enter", "Back");
		case MDC_PRISM_TICKET:
		{
			new name[25], offense[32];
			GetPVarString(playerid, "MDC_Ticket_Offense", offense, sizeof(offense));
			GetPVarString(playerid, "MDC_Ticket_Name", name, sizeof(name));
			format(string, sizeof(string), "{FFFFFF}Offender: %s\nTicket Reason: %s\nAmount: %s\nStrikes: %d\nDone", name, offense, PrettyMoney(GetPVarInt(playerid, "MDC_Ticket_Amount")), GetPVarInt(playerid, "MDC_Ticket_Strikes"));
			ShowPlayerDialog(playerid, MDC_PRISM_TICKET, DIALOG_STYLE_LIST, "LSPD - PRISM - Civilian Lookup - Issue Ticket", string, "Select", "Log out");
		}
		case MDC_PRISM_TICKET + 1: ShowPlayerDialog(playerid, MDC_PRISM_TICKET + 1, DIALOG_STYLE_INPUT, "Offender Name", "{FFFFFF}Enter the name of the offender.", "Accept", "Back");
		case MDC_PRISM_TICKET + 2: ShowPlayerDialog(playerid, MDC_PRISM_TICKET + 2, DIALOG_STYLE_INPUT, "Offense", "{FFFFFF}Enter the traffic offense commited.", "Accept", "Back");
		case MDC_PRISM_TICKET + 3: ShowPlayerDialog(playerid, MDC_PRISM_TICKET + 3, DIALOG_STYLE_INPUT, "Amount", "{FFFFFF}Enter the amount of the ticket.", "Accept", "Back");
		case MDC_PRISM_TICKET + 4: ShowPlayerDialog(playerid, MDC_PRISM_TICKET + 4, DIALOG_STYLE_INPUT, "Strikes to issue.", "{FFFFFF}Enter the amount of strikes to issue.", "Accept", "Back");
		case MDC_PRISM_TICKET + 5: ShowPlayerDialog(playerid, MDC_PRISM_TICKET + 5, DIALOG_STYLE_MSGBOX, "Suspend License?", "{FFFFFF}This player now has 5 strikes or more. Would you like to suspend their license for one week?", "Yes", "No");
		case MDC_BOLO_MAIN:ShowPlayerDialog(playerid, MDC_BOLO_MAIN, DIALOG_STYLE_LIST, "LSPD - BOLO Center", "{FFFFFF}Active BOLOs\nCreate BOLO\nRemove BOLO", "Select", "Back");
		case MDC_BOLO_CREATE:
		{
			new id = GetPVarInt(playerid, "MDC_Bolo_Create");
			format(string, sizeof(string), "Main Text: %s\nPriority: %s\nDone", CutString(Bolo[id][boloString]), BoloPriorityString(id));
			ShowPlayerDialog(playerid, MDC_BOLO_CREATE, DIALOG_STYLE_LIST, 	"LSPD - BOLO Center - Create BOLO", string, "Select", "Back");
		}
		case MDC_BOLO_CREATE + 1: ShowPlayerDialog(playerid, MDC_BOLO_CREATE + 1, DIALOG_STYLE_INPUT, "LSPD - BOLO Center - Create BOLO", "{FFFFFF}Enter the main text of the BOLO. Use \'~n~\' to insert a new line.", "Done", "Back");
		case MDC_BOLO_LIST:
		{
			string[0] = EOS;
			for(new i; i < MAX_BOLOS; i++)
			{
				if(Bolo[i][boloIsActive] == true && Bolo[i][boloPriority] == 3)
				{
					format(string, sizeof(string), "%s{F90703}%d | %s{FFFFFF}\n", string, i, CutString(Bolo[i][boloString]));
				}
			}
			for(new i; i < MAX_BOLOS; i++)
			{
				if(Bolo[i][boloIsActive] == true && Bolo[i][boloPriority] == 2)
				{
					format(string, sizeof(string), "%s{DBF706}%d | %s{FFFFFF}\n", string, i, CutString(Bolo[i][boloString]));
				}
			}
			for(new i; i < MAX_BOLOS; i++)
			{
				if(Bolo[i][boloIsActive] == true && Bolo[i][boloPriority] == 1)
				{
					format(string, sizeof(string), "%s{06F726}%d | %s{FFFFFF}\n", string, i, CutString(Bolo[i][boloString]));
				}
			}
			if(isnull(string))
				format(string, sizeof(string), "No active BOLOs at this time.");
			ShowPlayerDialog(playerid, MDC_BOLO_LIST, DIALOG_STYLE_LIST, "LSPD - BOLO Center - Active BOLOs", string, "View", "Go back");
		}
		case MDC_BOLO_VIEW:
		{
			new id = GetPVarInt(playerid, "MDC_Bolo_View");
			format(string, sizeof(string), "{FFFFFF}Priority: %s\nCreated: %s\nCreated by: %s\n%s", BoloPriorityString(id), Bolo[id][boloCreationDate], Bolo[id][boloCreatedBy], AddNewLines(Bolo[id][boloString]));
			ShowPlayerDialog(playerid, MDC_BOLO_VIEW, DIALOG_STYLE_MSGBOX, "LSPD - BOLO Center - View BOLO", string, "Go back", "Logout");
		}
		case MDC_BOLO_VIEW + 1:
		{
			new id = GetPVarInt(playerid, "MDC_Bolo_View");
			format(string, sizeof(string), "{FFFFFF}Priority: %s\nCreated: %s\nCreated by: %s\n%s", BoloPriorityString(id), Bolo[id][boloCreationDate], Bolo[id][boloCreatedBy], AddNewLines(Bolo[id][boloString]));
			ShowPlayerDialog(playerid, MDC_BOLO_VIEW + 1, DIALOG_STYLE_MSGBOX, "LSPD - BOLO Center - View BOLO", string, "Remove", "Back");
		}
		case MDC_DISPATCH_MAIN: ShowPlayerDialog(playerid, MDC_DISPATCH_MAIN, DIALOG_STYLE_LIST, "LSPD - Dispatch Center", "{FFFFFF}Locate LSPD Vehicle by Plate\nView all Vehicle Locations", "Select", "Back");
		case MDC_DISPATCH_MAIN + 1: ShowPlayerDialog(playerid, MDC_DISPATCH_MAIN + 1, DIALOG_STYLE_INPUT, "LSPD - Dispatch Center - Locate LSPD Vehicle", "{FFFFFF}Enter the license plate of the LSPD Vehicle:", "Enter", "Back");
		case MDC_HC_MAIN: ShowPlayerDialog(playerid, MDC_HC_MAIN, DIALOG_STYLE_LIST, "LSPD - High Command Center", "{FFFFFF}Edit Annoucement\nImpounded Vehicles", "Select", "Back");
		case MDC_HC_MAIN + 1: ShowPlayerDialog(playerid, MDC_HC_MAIN + 1, DIALOG_STYLE_LIST, "LSPD - High Command Center", "{FFFFFF}Overwrite Annoucement\nAppend to current\nDelete Annoucement", "Select", "Back");
		case MDC_HC_MAIN + 2: ShowPlayerDialog(playerid, MDC_HC_MAIN + 2, DIALOG_STYLE_INPUT, "LSPD - High Command Center - Edit Annoucement", "{FFFFFF}Please enter the text you wish to enter below. Use \'~n~\' to insert a new line.", "Enter", "Back");
		case MDC_IMPOUND:
		{
			new Cache:cache = mysql_query(MYSQL_MAIN, "SELECT * FROM vehicles WHERE impounded = '1'"), count = cache_get_row_count();
			new page = GetPVarInt(playerid, "MDC_IMPOUND_PAGE"), row = page * 9, imp_string[1000], exit_loop;
			while(row < count && !exit_loop)
			{
				new model = cache_get_field_content_int(row, "model");
				new imp_count = cache_get_field_content_int(row, "impoundcount");
				new owner[25];
				cache_get_field_content(row, "owner", owner);
				mysql_format(MYSQL_MAIN, string, sizeof(string), "SELECT * FROM playeraccounts WHERE NormalName = '%e'", owner);
				new Cache:data = mysql_query(MYSQL_MAIN, string);
				new PlayerBanned = cache_get_field_content_int(0, "Banned");
				cache_delete(data);
				cache_set_active(cache);
				if(PlayerBanned < 1)
				{
				   switch(imp_count)
				   {
						case 1: format(imp_string, sizeof(imp_string), "%s{FFE224}%s (%s)\n", imp_string, vNames[model - 400], owner);
						case 2: format(imp_string, sizeof(imp_string), "%s{FF8800}%s (%s)\n", imp_string, vNames[model - 400], owner);
						default: format(imp_string, sizeof(imp_string), "%s{FF1E00}%s (%s)\n", imp_string, vNames[model - 400], owner);
				   }
				}

				if(row >= (9 + (page * 9)) - 1)
				{
					// if(page >= 1)
						// format(imp_string, sizeof(imp_string), "%s{FFFFFF}Next\nBack\n", imp_string);
					// else
					format(imp_string, sizeof(imp_string), "%s{FFFFFF}Next\n", imp_string);
					exit_loop = 1;
				}

				row++;
			}
			cache_delete(cache);

			if(page > 0)
				format(imp_string, sizeof(imp_string), "%s{FFFFFF}Back\n", imp_string);

			ShowPlayerDialog(playerid, MDC_IMPOUND, DIALOG_STYLE_LIST, "LSPD - High Command Center - Impound", imp_string, "Check", "Main Menu");
		}
		case MDC_IMPOUND + 1:
		{
			new query[128];
			mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT * FROM vehicles WHERE sqlid = '%d'", GetPVarInt(playerid, "MDC_IMPOUND_SQLIDVIEW"));
			new Cache:cache = mysql_query(MYSQL_MAIN, query);

			if(cache_get_row_count() == 0)
				return SendClientMessage(playerid, WHITE, "An error occurred: Could not find vehicle in database.");

			new model = cache_get_field_content_int(0, "model");
			new registered = cache_get_field_content_int(0, "registered");
			new imp_count = cache_get_field_content_int(0, "impoundcount");
			new owner[25], time[64], plate[42];
			cache_get_field_content(0, "owner", owner);
			cache_get_field_content(0, "impoundtime", time);
			cache_get_field_content(0, "plate", plate);
			cache_delete(cache);

			format(string, sizeof(string), "{FFFFFF}Vehicle:			%s\nOwner:			%s\nRegistered:		%s\nNumber plate:		%s\nTotal impounds:	%d\nImpounded:		%s", vNames[model - 400], owner, (registered) ? ("Yes") : ("No"), plate, imp_count, time);

			ShowPlayerDialog(playerid, MDC_IMPOUND + 1, DIALOG_STYLE_MSGBOX, "LSPD - High Command Center - Impound", string, "Crush", "Main Menu");
		}
		case MDC_IMPOUND + 2:
		{
			ShowPlayerDialog(playerid, MDC_IMPOUND + 2, DIALOG_STYLE_INPUT, "LSPD - High Command Center - Impound", "Are you sure you want to crush this vehicle???\nEnter \"CoNfIrM\" to proceed (This is case sensitive)", "Continue", "Main Menu");
		}
		case MDC_LIGHTS_MAIN: ShowPlayerDialog(playerid, MDC_LIGHTS_MAIN, DIALOG_STYLE_LIST, "LSPD - Vehicle Lights Control", "Toggle Emergency Lights\nDisable Automatic Enabling\nChoose Flash Speed", "Enter", "Go back");
		case MDC_LIGHTS_SPEED: ShowPlayerDialog(playerid, MDC_LIGHTS_SPEED, DIALOG_STYLE_LIST, "LSPD - Vehicle Lights Control - Choose Speed", "Super Fast\nFast\nSlow", "Select", "Go back");
		case MDC_911_CENTER:
		{
			string[0] = EOS;
			for(new i; i < MAX_911_STORED; i++) 
			{
				if(!isnull(Calls[i][Call_Text]))
					format(string, sizeof(string), "%s%s | %s\n", string, Calls[i][Call_Location], CutString(Calls[i][Call_Text]));
			}
			if(isnull(string))
				format(string, sizeof(string), "No 911 calls found...");
			ShowPlayerDialog(playerid, MDC_911_CENTER, DIALOG_STYLE_LIST, "LSPD - 911 Center - Last 5 Calls", string, "More Info", "Back");
		}
		case MDC_LOADING_LOOKUP: ShowPlayerDialog(playerid, MDC_LOADING_LOOKUP, DIALOG_STYLE_MSGBOX, "LSPD - MDC - PRISM - Vehicle Lookup - Loading Results", "LOADING PRISM RESULTS PLEASE WAIT......", "Okay", "");
	}
	return 1;
}

stock BoloPriorityString(id)
{
	new priority[32];
	if(Bolo[id][boloPriority] == 1)
		format(priority, sizeof(priority), "{06F726}Normal{FFFFFF}");
	else if(Bolo[id][boloPriority] == 2)
		format(priority, sizeof(priority), "{DBF706}Elevated{FFFFFF}");
	else if(Bolo[id][boloPriority] == 3)
		format(priority, sizeof(priority), "{F90703}High{FFFFFF}");
	else format(priority, sizeof(priority), "{06F726}Normal{FFFFFF}");
	return priority;
}

stock CutString(string1[])
{
	new count, newstring[128];
	format(newstring, sizeof(newstring), "%s", string1);
	for(new i = 0; '\0' != newstring[i]; i++)
	{
		count++;
		if(count == 25)
		{
			newstring[i] = '.';
			newstring[i + 1] = '.';
			newstring[i + 2] = '.';
			newstring[i + 3] = EOS;
			break;
		}
	}
	return newstring;
}

stock GetUnusedBolo()
{
	new id = -1;
	for(new i; i < MAX_BOLOS; i++)
	{
		if(Bolo[i][boloIsActive] == false && Bolo[i][boloIsBeingEdited] == false)
		{
			id = i;
			break;
		}
	}
	return id;
}

stock AddNewLines(string1[])
{
	new newstring[670];
	str_replace("\n", "~n~", string1, newstring, true);
	return newstring;
}

stock Store911Call(location[], placedby[], text[], number)
{
	new slot = last911SlotUsed + 1;
	if(slot >= MAX_911_STORED)
		slot = 0;
		
	Calls[slot][Call_Location][0] = EOS;
	Calls[slot][Call_Text][0] = EOS;
	Calls[slot][Call_PlacedByName][0] = EOS;
	
	strcat(Calls[slot][Call_Location], location, MAX_ZONE_NAME);
	strcat(Calls[slot][Call_Text], text, 128);
	strcat(Calls[slot][Call_PlacedByName], placedby, 25);
	Calls[slot][Call_Number] = number;
	last911SlotUsed = slot;
	return 1;
}

//Credits to some guy on the SAMP forums
stock str_replace (newstr [], oldstr [], srcstr [], deststr [], bool: ignorecase = false, size = sizeof (deststr))
{
    new
        newlen = strlen (newstr),
        oldlen = strlen (oldstr),
        srclen = strlen (srcstr),
        idx,
        rep;

    for (new i = 0; i < srclen; ++i)
    {
        if ((i + oldlen) <= srclen)
        {
            if (!strcmp (srcstr [i], oldstr, ignorecase, oldlen))
            {
                deststr [idx] = '\0';
                strcat (deststr, newstr, size);
                ++rep;
                idx += newlen;
                i += oldlen - 1;
            }
            else
            {
                if (idx < (size - 1))
                    deststr [idx++] = srcstr [i];
                else
                    return rep;
            }
        }
        else
        {
            if (idx < (size - 1))
                deststr [idx++] = srcstr [i];
            else
                return rep;
        }
    }
    deststr [idx] = '\0';
    return rep;
}

// ------------------------- MYSQL Threads ------------------------------ //

forward OnPrismVehicleLookup(playerid);
public OnPrismVehicleLookup(playerid)
{
	ShowPlayerDialog( playerid, -1, 0, "", "", "", "" );
	
	if(cache_get_row_count() < 1)
	{
		format(string, sizeof(string), "No results found.");
	}
	else
	{
		new sqlid, idx = -1;
		sqlid = cache_get_field_content_int(0, "sqlid");

		idx = GetVIndex(sqlid);
		
		if(idx == -1)
			return SendClientMessage(playerid, RED, "Prism lookup failed. ((Owner offline))");
			
		if(sqlid == 0)
			return SendClientMessage(playerid, RED, "Prism lookup failed.");
		
		if(!strcmp(Veh[idx][Owner], "unowned", true))
		{
			format(string, sizeof(string), "Vehicle Owner:         Unavailable((Unowned))\nModel:          %s\nLicense Plate:          %s\nRegistration Status:          Not registered", vNames[Veh[idx][Model] - 400], Veh[idx][Plate]);
		}

		new pid = GetPlayerIDEx(Veh[idx][Owner]);

		if(IsPlayerConnected(pid) || IsPlayerConnected(GetPlayerID(Veh[idx][Owner])))
		{
			new rego = -1;

			if(Veh[idx][Registered])
				rego = 1;
			else
				rego = 0;

			switch(rego)
			{
				case 0: format(string, sizeof(string), "Vehicle Owner:         Unavailable\nModel:          Information Unavailable\nLicense Plate:          %s\nRegistration Status:          Not registered", Veh[idx][Plate]);
				case 1: format(string, sizeof(string), "Vehicle Owner:        %s\nModel:          %s\nLicense Plate:          %s\nRegistration Status:          Registered", Player[pid][NormalName], vNames[Veh[idx][Model] - 400], Veh[idx][Plate]);
			}
		}
		else
		{
			format(string, sizeof(string), "No results found. ((Owner offline))");
		}
	}
	SetPVarInt(playerid, "MDC_PRISM_Vehicle", 1);
	ShowPlayerDialog(playerid, MDC_PRISM_RESULTS, DIALOG_STYLE_MSGBOX, "LSPD - PRISM - Vehicle Lookup - Results",string,  "Logout", "Go back");
	
	return 1;
}