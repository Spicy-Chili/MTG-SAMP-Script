/*
#		MTG PRISON
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

#define MAX_CELLS 16
#define MAX_SOLITARY_CELLS 4
#define MAX_PRISON_ACTORS 3
#define MAX_LITTER 12
#define LITTER_OBJECT 2672
#define PRISON_VW 45001

enum CellsInfo
{
	Occupied,
	PrisonerAmount,
	Float:Cx,
	Float:Cy,
	Float:Cz,
}

enum SolitaryInfo
{
	Occupied,
	OccupiedBy[MAX_PLAYER_NAME],
	Svw,
	Float:Sx,
	Float:Sy,
	Float:Sz,
}

enum LitterInfo
{
	ObjectID,
	Float:Lx,
	Float:Ly,
	Float:Lz,
}

new Cells[MAX_CELLS][CellsInfo] =
{
	{0,0,-450.7959,-542.2560,-65.4093},
	{0,0,-451.1347,-537.5056,-65.4093}, 
	{0,0,-450.8373,-533.0023,-65.4093},
	{0,0,-451.1189,-528.0253,-65.4093},
	{0,0,-450.5529,-542.1763,-68.9141},
	{0,0,-450.7412,-537.6923,-68.9141},
	{0,0,-451.2729,-532.8062,-68.9141},
	{0,0,-450.6236,-528.3161,-68.9141},
	{0,0,-455.6537,-528.2107,-65.4093},
	{0,0,-455.6977,-532.7650,-65.4093},
	{0,0,-455.9810,-537.3647,-65.4093},
	{0,0,-455.6460,-542.2319,-65.4093},
	{0,0,-456.1800,-527.9918,-68.9141},
	{0,0,-455.9466,-532.6933,-68.9141},
	{0,0,-455.8220,-537.4188,-68.9141},
	{0,0,-455.8444,-542.3056,-68.9141}
};

new LitterObjects[MAX_LITTER][LitterInfo] =
{
	{0,-602.3857,-545.7969,24.8041},
	{0,-581.3939,-551.7991,24.8041},
	{0,-550.1244,-514.2651,24.8041},
	{0,-563.8134,-537.6166,24.8041},
	{0,-462.3897,-503.5602,-69.6187},
	{0,-445.2787,-517.8243,-69.6187}, 
	{0,-447.6326,-526.5469,-69.6187},
	{0,-576.6140,-544.8541,24.8041},
	{0,-463.2637,-533.5878,-69.6187},
	{0,-468.0414,-514.4035,-69.6187},
	{0,-442.7991,-524.8099,-69.6187},
	{0,-469.7445,-502.4761,-69.6187}
};

new Solitary[MAX_SOLITARY_CELLS][SolitaryInfo] =
{
	{0,"",45002,-450.8701,-499.6483,-68.9141},
	{0,"",45003,-450.4854,-495.3702,-68.9141},
	{0,"",45004,-450.5961,-491.4702,-68.9137},
	{0,"",45005,-450.6216,-487.2357,-68.9137}
};

new PrisonActors[MAX_PRISON_ACTORS];
new PrisonItemPrice[14]; // 0 - 5 illegal items bought with $$$ , 6 - 8 legal bought with tickets, 9 - 11 illegal bought with cigarettes, 12-13 prison job payment (tickets)
new Text3D:PrisonLabels[11];
new PrisonLockdown, PrisonPaycheck, TicketLimit;
// ============= Commands =============

CMD:leaveprison(playerid, params[])
{
	if(Player[playerid][PrisonID] == 1)
		return SendClientMessage(playerid, WHITE, "You are in admin jail, not IC prison, read the rules at www.mt-gaming.com.");
	
	if(Player[playerid][PrisonLifer] == 1)
		return SendClientMessage(playerid, RED, "You are in prison for life and are unable to leave.");
	
	if(Player[playerid][PrisonID] == 0)
		return 1;
	
	if(Player[playerid][PrisonDuration] > 0)
		return SendClientMessage(playerid, WHITE, "You haven't finished your sentence!");
	
	if(!IsPlayerInRangeOfPoint(playerid, 5, -440.9868,-543.6298,-68.9137) && !IsPlayerInRangeOfPoint(playerid, 5, -465.7999,-543.5829,-68.9145))
		return SendClientMessage(playerid, WHITE, "You can only leave the prison at the blue doors in either cell block.");
		
	if(GetPVarInt(playerid, "prisonjob") > 0)
		return SendClientMessage(playerid, -1, "You need to leave your job first, type /endprisonjob.");
	
	SendClientMessage(playerid, WHITE, "You have left the San Andreas Correctional Facility, any prison items you had have been taken.");
	Player[playerid][PrisonTickets] = 0;
	Player[playerid][PrisonDice] = 0;
	Player[playerid][PrisonScrewdriver] = 0;
	Player[playerid][PrisonShank] = 0;
	Player[playerid][PrisonRazor] = 0;
	Player[playerid][Cigarettes] = 0;
	Player[playerid][PrisonLighter] = 0;
	Player[playerid][PrisonID] = 0;	
	Player[playerid][PrisonLitter] = 0;
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerPos_Update(playerid, -501.2555,-519.9586,25.5234);
	SetPlayerFacingAngle(playerid, 270.9771);
	
	new cell = GetPVarInt(playerid, "Cell_Number");
	CellChanged(cell);
	DeletePVar(playerid, "Cell_Number");
	DeletePVar(playerid, "Prison_Message_Sent");
	DeletePVar(playerid, "Solitary_Number");
	return 1;
}
CMD:sendtosolitary(playerid, params[])
{
	if(Groups[Player[playerid][Group]][CommandTypes] != 1)
		return 1;
	
	new id, string [128], reason[128], time;
	if(sscanf(params, "uds", id, time, reason))
		return SendClientMessage(playerid, GREY, "Syntax: /sendtosolitary [playerid] [time (1 - 30 minutes)] [reason]");
	
	if(time > 30)
		return SendClientMessage(playerid, WHITE, "The maximum time for solitary is 30 minutes.");
	
	if(!IsPlayerInRangeOfPoint(playerid, 3, -450.8078,-499.6194,-68.9141) && !IsPlayerInRangeOfPoint(playerid, 3, -450.9152,-495.7140,-68.9141) && !IsPlayerInRangeOfPoint(playerid, 3, -450.8437,-491.3300,-68.9137) && !IsPlayerInRangeOfPoint(playerid, 3, -450.3752,-488.0075,-68.9137))
		return SendClientMessage(playerid, WHITE, "You're not close enough to a solitary cell door.");

	if(Player[id][PrisonID] != 2)
		return SendClientMessage(playerid, -1, "You can only send prisoners to solitary confinement.");
		
	if(GetDistanceBetweenPlayers(playerid, id)  > 3)
		return SendClientMessage(playerid, WHITE, "You're not close enough to the prisoner.");
	
	if(Player[id][Cuffed] >= 1)
		return SendClientMessage(playerid, WHITE, "Uncuff the prisoner first!");
		
	if(IsSolitaryFull())
		return SendClientMessage(playerid, WHITE, "There is no more rooms available!");
		
	Player[id][SolitaryDuration] = MinutesToSeconds(time);
	
	format(string, sizeof(string), "%s has sent %s to solitary confinement for %d minutes. Reason: %s", GetNameEx(playerid), GetNameEx(id), time, reason);
	GroupMessage(playerid, ANNOUNCEMENT, string, 1);
	
	format(string, sizeof(string), "You have been sent to solitary confinement for %d minutes by %s.", time, GetNameEx(playerid));
	SendClientMessage(id, WHITE, string);
	SendClientMessage(id, WHITE, "You will be automatically released from solitary when your time is up.");
	FindSolitaryForPlayer(id);
	return 1;
}

CMD:talktoguard(playerid, params[])
{
	if(!IsPlayerInRangeOfPoint(playerid, 3, -497.9132,-561.3230,25.5234))
		return 1;
	
	if(Player[playerid][Gang] == 0)
	{
		SendClientMessage(playerid, WHITE, "[American Accent] Prison Guard says: Leave me alone.");
		return SendClientMessage(playerid, GREY, "Only members of official gangs can talk to this guard.");
	}
	
	if(gettime() < Player[playerid][SmuggleCooldown])
	{
		SendClientMessage(playerid, WHITE, "[American Accent] Prison Guard says: Come back later.");
		return SendClientMessage(playerid, GREY, "You must wait the 30 minute cooldown before trying smuggle another item into the prison.");
	}
	
	switch(random(5))
	{
		case 0: SendClientMessage(playerid, WHITE, "[American Accent] Prison Guard says: What can I do for you?");
		case 1: SendClientMessage(playerid, WHITE, "[American Accent] Prison Guard says: What do you want?");
		case 2: SendClientMessage(playerid, WHITE, "[American Accent] Prison Guard says: Yes?");
		case 3: SendClientMessage(playerid, WHITE, "[American Accent] Prison Guard says: Shh, keep your voice down!");
		case 4: SendClientMessage(playerid, WHITE, "[American Accent] Prison Guard says: I can help you out, for a price.");
	}
	
	new string[128];
	format(string, sizeof(string), "Cocaine ($%d each)\nPot ($%d each)\nSpeed ($%d each)\nScrewdriver ($%d)\nShank ($%d)\nRazor ($%d)", PrisonItemPrice[0], PrisonItemPrice[1], PrisonItemPrice[2], PrisonItemPrice[3], PrisonItemPrice[4], PrisonItemPrice[5]);
	SendClientMessage(playerid, GREY, "Please NOTE: If either you or the recipient logs off before the item reaches them then it will be lost! No refunds!"); 
	ShowPlayerDialog(playerid, DIALOG_PRISON_ILLEGAL_ITEMS, DIALOG_STYLE_LIST, "Select an item to smuggle inside", string, "Select", "Cancel");
	return 1; 
}

CMD:searchtrash(playerid, params[])
{
	if(Player[playerid][PrisonID] != 2)
		return 1;
	
	if(!IsPlayerInRangeOfPoint(playerid, 2, -566.77960, -513.81287, 25.07370))
		return 1;
	
	new string[128];
	format(string, sizeof(string), "* %s takes a look inside the trash.", GetNameEx(playerid));
	NearByMessage(playerid, NICESKY, string);
	
	if(GetPVarInt(playerid, "Smuggle_Success") != 1)
		return SendClientMessage(playerid, WHITE, "You find nothing.");
		
	new sender = GetPVarInt(playerid, "Smuggle_Friend"), item = GetPVarInt(sender, "Item_To_Smuggle"), amount = GetPVarInt(sender, "Drug_Smuggle_Amount");
	
	switch(item)
	{
		case 0:
		{
			Player[playerid][Cocaine] += amount;
			format(string, sizeof(string), "You have found %d grams of cocaine!", amount);
			SendClientMessage(playerid, WHITE, string);
		}
		case 1:
		{
			Player[playerid][Pot] += amount;
			format(string, sizeof(string), "You have found %d grams of pot!", amount);
			SendClientMessage(playerid, WHITE, string);
		}
		case 2:
		{
			Player[playerid][Speed] += amount;
			format(string, sizeof(string), "You have found %d pills of speed!", amount);
			SendClientMessage(playerid, WHITE, string);
		}
		case 3:
		{
			Player[playerid][PrisonScrewdriver] = 1;
			SendClientMessage(playerid, WHITE, "You have found a screwdriver!");
		}
		case 4:
		{
			Player[playerid][PrisonShank] = 1;
			SendClientMessage(playerid, WHITE, "You have found a shank!");
		}
		case 5:
		{
			Player[playerid][PrisonRazor] = 1;
			SendClientMessage(playerid, WHITE, "You have found a razor!");
		}
	}
	
	DeletePVar(playerid, "Smuggle_Friend");
	DeletePVar(sender, "Smuggle_Friend");
	DeletePVar(playerid, "Smuggle_Success");
	DeletePVar(sender, "Drug_Smuggle_Amount");
	DeletePVar(sender, "Item_To_Smuggle");
	return 1;
}

CMD:buyitems(playerid, params[])
{
	if(Player[playerid][PrisonID] != 2)
		return 1;
	
	new string[128];
	if(IsPlayerInRangeOfPoint(playerid, 4, -455.8994,-520.2752,-68.9145))
	{
		format(string, sizeof(string), "Food (%d tickets)\nCigarettes (%d tickets each)\nDice (%d tickets)\nMedkit (10 tickets)", PrisonItemPrice[6], PrisonItemPrice[7], PrisonItemPrice[8]);
		ShowPlayerDialog(playerid, DIALOG_PRISON_BUY_ITEMS, DIALOG_STYLE_LIST, "Select an item to purchase", string, "Buy", "Cancel");
	}
	else if(IsPlayerInRangeOfPoint(playerid, 4, -462.2357,-523.6448,-68.9145))
	{
		if(gettime() < Player[playerid][PrisonBuyItemCooldown])
		{
			SendClientMessage(playerid, WHITE, "[American Accent] Prison Guard says: Go away.");
			return SendClientMessage(playerid, GREY, "You must wait the 30 minute cooldown before purchasing another illegal item from this guard.");
		}
		
		switch(random(5))
		{
			case 0: SendClientMessage(playerid, WHITE, "[American Accent] Prison Guard says: Shh, keep this between the two of us.");
			case 1: SendClientMessage(playerid, WHITE, "[American Accent] Prison Guard says: I can give you a good deal.");
			case 2: SendClientMessage(playerid, WHITE, "[American Accent] Prison Guard says: Don't tell my boss about this.");
			case 3: SendClientMessage(playerid, WHITE, "[American Accent] Prison Guard says: If this leads back to me I'll take you down with me.");
			case 4: SendClientMessage(playerid, WHITE, "[American Accent] Prison Guard says: Can I interest you in something not so legal?");
		}
		format(string, sizeof(string), "Screwdriver (%d cigs)\nRazor (%d cigs)\nLighter (%d cigs)", PrisonItemPrice[9], PrisonItemPrice[10], PrisonItemPrice[11]);
		ShowPlayerDialog(playerid, DIALOG_PRISON_BUY_ITEMS_ILLEGAL, DIALOG_STYLE_LIST, "Select an item to purchase", string, "Buy", "Cancel");
	}
	else SendClientMessage(playerid, WHITE, "You're not close enough to the guard.");
	return 1;
}
CMD:prisonmenu(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
	
	new string[128];
	format(string, sizeof(string), "Prison Prices\nPrison Job Settings\nRespawn Guard NPCs\nPrison Paycheck (%d)", PrisonPaycheck);
	ShowPlayerDialog(playerid, DIALOG_PRISON_ADMIN_MAIN, DIALOG_STYLE_LIST, "Prison Admin Menu", string, "Select", "Cancel");
	return 1;
}
CMD:lightcig(playerid, params[])
{
	if(Player[playerid][Cigarettes] < 1)
		return SendClientMessage(playerid, WHITE, "You don't have any cigarettes.");
	
	if(Player[playerid][PrisonLighter] < 1)
		return SendClientMessage(playerid, WHITE, "You don't have a lighter.");
	
	if(random(25) == 9)
	{
		SendClientMessage(playerid, -1, "Your lighter has broken. Buy another one from the cafeteria.");
		Player[playerid][PrisonLighter] = 0;
	}
	Player[playerid][Cigarettes]--;
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_SMOKE_CIGGY);
	new string[128];
	format(string, sizeof(string), "* %s lights a cigarette.", GetNameEx(playerid));
	NearByMessage(playerid, NICESKY, string);
	return 1;
}
CMD:lightcigarette(playerid, params[])
	return cmd_lightcig(playerid, params);

CMD:controlpanel(playerid, params[])
{
	if(Groups[Player[playerid][Group]][CommandTypes] != 1)
		return SendClientMessage(playerid, -1, "Only the LSPD can use this command.");
		
	if(!IsPlayerInRangeOfPoint(playerid, 3, -474.6639,-505.0270,-65.2356))
		return SendClientMessage(playerid, -1, "You are not close enough to the control panel.");
		
	new string[128];
	format(string, sizeof(string), "* %s uses the control panel.", GetNameEx(playerid));
	NearByMessage(playerid, NICESKY, string);
	
	format(string, sizeof(string), "Cells\nSolitary\n%s", (PrisonLockdown) ? ("{33A10B}REVERT LOCKDOWN{FFFFFF}") : ("{FF0000}LOCKDOWN{FFFFFF}"));
	ShowPlayerDialog(playerid, DIALOG_PRISON_CONTROLPANEL_1, DIALOG_STYLE_LIST, "{00BBFF}Correctional Facility Control Panel", string, "Select", "Cancel");
	return 1;
}

CMD:pickuptrash(playerid, params[])
{
	if(Player[playerid][PrisonID] != 2)
		return SendClientMessage(playerid, -1, "Only prisoners can use this command.");
		
	if(!IsPlayerInRangeOfPoint(playerid, 3, -468.9137,-523.9198,-68.9145))
		return SendClientMessage(playerid, WHITE, "You are not close enough to the /pickuptrash point.");
	
	if(Groups[Player[playerid][Group]][CommandTypes] == 1)
		return 1;
		
	if(GetPVarInt(playerid, "prisonjob") != 1)
		return SendClientMessage(playerid, WHITE, "You don't have the trash job.");
		
	new string[128];
	format(string, sizeof(string), "* %s picks up a garbage bag.", GetNameEx(playerid));
	NearByMessage(playerid, NICESKY, string);
	
	SetPlayerAttachedObject(playerid, 9, 1264, 6, 0.254387, -0.020239, 0.000000, 0.000000, -76.382606, -83.699974, 1.000000, 1.000000, 1.000000);
	SendClientMessage(playerid, -1, "Take the trash outside to the dumpster and type /dumptrash.");
	return 1;
}

CMD:dumptrash(playerid, params[])
{
	if(Player[playerid][PrisonID] != 2)
		return SendClientMessage(playerid, -1, "Only prisoners can use this command.");
		
	if(GetPVarInt(playerid, "prisonjob") != 1)
		return SendClientMessage(playerid, -1, "Only prisoners with the trash job can use this command.");
	
	if(!IsPlayerAttachedObjectSlotUsed(playerid, 9))
		return SendClientMessage(playerid, -1, "You don't have any trash to dump.");
	
	if(!IsPlayerInRangeOfPoint(playerid, 3, -597.7469,-533.1406,25.5234))
		return SendClientMessage(playerid, -1, "You are not close enough to the dumpsters.");
		
	new string[128];
	format(string, sizeof(string), "* %s places their trash in the dumpster.", GetNameEx(playerid));
	NearByMessage(playerid, NICESKY, string);
		
	new counter = GetPVarInt(playerid, "jobcounter");
	counter++;
	SetPVarInt(playerid, "jobcounter", counter);
	format(string, sizeof(string), "You have taken %d bags to the dumpster. (Type /endprisonjob to receive your tickets if you want to finish!)", counter);
	SendClientMessage(playerid, -1, string);
	RemovePlayerAttachedObject(playerid, 9);
	
	new tickets = counter * PrisonItemPrice[12];
	if(tickets > TicketLimit)
	{
		Player[playerid][PrisonJobCooldown] = gettime() + 1800;
		SendClientMessage(playerid, RED, "You have earned enough tickets from jobs for now, you can do more in 30 minutes.");
		return cmd_endprisonjob(playerid, params);
	}
	return 1;
}

CMD:endprisonjob(playerid, params[])
{
	if(GetPVarInt(playerid, "prisonjob") < 1)
		return SendClientMessage(playerid, WHITE, "You don't have a prison job.");
		
	new payment, string[128], counter = GetPVarInt(playerid, "jobcounter");
	DeletePVar(playerid, "jobcounter");
	if(GetPVarInt(playerid, "prisonjob") == 1)
	{
		payment = counter * PrisonItemPrice[12];
		format(string, sizeof(string), "You have earned %d tickets for taking out %d trash bags.", payment, counter);
		SendClientMessage(playerid, -1, string);
		Player[playerid][PrisonTickets]+= payment;
		RemovePlayerAttachedObject(playerid, 9);
	}
	else if(GetPVarInt(playerid, "prisonjob") == 2)
	{
		payment = counter * PrisonItemPrice[13];
		format(string, sizeof(string), "You have earned %d tickets for cleaning up %d pieces of litter.", payment, counter);
		SendClientMessage(playerid, -1, string);
		Player[playerid][PrisonTickets]+= payment;
		Player[playerid][PrisonLitter] = 0;
	}
	DeletePVar(playerid, "prisonjob");
	return 1;
}

CMD:cleanup(playerid, params[])
{
	if(Player[playerid][PrisonID] != 2)
		return SendClientMessage(playerid, -1, "Only prisoners can use this command.");
		
	if(GetPVarInt(playerid, "prisonjob") != 2)
		return SendClientMessage(playerid, WHITE, "You don't have the litter job.");
	
	if(Player[playerid][PrisonLitter] == 1)
		return SendClientMessage(playerid, -1, "You can only hold one piece of litter at a time!");
		
	for(new i; i < MAX_LITTER; i++)
	{
		if(IsPlayerInRangeOfPoint(playerid, 1, LitterObjects[i][Lx], LitterObjects[i][Ly], LitterObjects[i][Lz]) && IsValidDynamicObject(LitterObjects[i][ObjectID]))
		{
			new string[128], counter = GetPVarInt(playerid, "jobcounter");
			counter++;
			SetPVarInt(playerid, "jobcounter", counter);
			format(string, sizeof(string), "* %s cleans up the litter from the floor.", GetNameEx(playerid));
			NearByMessage(playerid, NICESKY, string);
			DestroyDynamicObject(LitterObjects[i][ObjectID]);
			ApplyAnimation(playerid,"SWEET","Sweet_injuredloop", 4.0, 0, 0, 0, 0, 5000);
			SendClientMessage(playerid, -1, "Take this litter to the garbage in the cafeteria and type /droplitter.");
			Player[playerid][PrisonLitter] = 1;
			break;
		}
	}
	return 1;
}
CMD:droplitter(playerid, params[])
{
	if(Player[playerid][PrisonID] != 2)
		return SendClientMessage(playerid, -1, "Only prisoners can use this command.");
		
	if(GetPVarInt(playerid, "prisonjob") != 2)
		return SendClientMessage(playerid, -1, "You don't have the litter job.");
		
	if(Player[playerid][PrisonLitter] != 1)
		return SendClientMessage(playerid, -1, "You're not carrying any litter.");
	
	if(!IsPlayerInRangeOfPoint(playerid, 2, -469.3300,-524.2974,-68.9145))
		return SendClientMessage(playerid, -1, "You're not close enough to the garbage.");
		
	new string[128];
	format(string, sizeof(string), "* %s dumps some litter into the garbage.", GetNameEx(playerid));
	NearByMessage(playerid, NICESKY, string);
	Player[playerid][PrisonLitter] = 0;
	
	new tickets, counter = GetPVarInt(playerid, "jobcounter");
	tickets = counter * PrisonItemPrice[13];
	if(tickets > TicketLimit)
	{
		Player[playerid][PrisonJobCooldown] = gettime() + 1800;
		SendClientMessage(playerid, RED, "You have earned enough tickets from jobs for now, you can do more in 30 minutes.");
		return cmd_endprisonjob(playerid, params);
	}
	return 1;
}
CMD:getjob(playerid, params[])
{
	if(Player[playerid][PrisonID] != 2)
		return SendClientMessage(playerid, -1, "Only prisoners can get a prison job.");
		
	if(!IsPlayerInRangeOfPoint(playerid, 3, -472.1534, -522.3404, -68.5037))
		return SendClientMessage(playerid, WHITE, "You are not close enough to the board to get a job slip.");
		
	if(GetPVarInt(playerid, "prisonjob") > 0)
		return SendClientMessage(playerid, WHITE, "You already have a prison job. Type /endprisonjob first.");
		
	if(gettime() < Player[playerid][PrisonJobCooldown])
		return SendClientMessage(playerid, -1, "Wait until your cooldown has finished before getting another prison job. (/time)");
	
	ShowPlayerDialog(playerid, DIALOG_PRISON_GETJOB, DIALOG_STYLE_LIST, "Prison Jobs", "Trash Job\nLitter Job", "Choose", "Cancel");
	return 1;
}

CMD:lifeinprison(playerid, params[])
{
	if(isnull(params) || strcmp(params, "confirm", true))
		return SendClientMessage(playerid, RED, "Are you sure you would like to be in prison for life? Type \"/lifeinprison confirm\" to confirm");

	ShowPlayerDialog(playerid, DIALOG_LIFE_IN_PRISON, DIALOG_STYLE_MSGBOX, "Life In Prison", "You are about to place your character in the Correctional Facility for life.\nThis command can never be undone, even by an admin.\nDo you understand that you can never leave prison?", "Yes", "No");
	return 1;
}

// ============= Callbacks =============

hook OnGameModeInit()
{
	LoadPrisonActorsIcons();
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DIALOG_PRISON_ILLEGAL_ITEMS:
		{
			if(!response)
					return 1;
					
			switch(listitem)
			{
				case 0:
				{
					SetPVarInt(playerid, "Item_To_Smuggle", 0);
					ShowPlayerDialog(playerid, DIALOG_PRISON_ILLEGAL_ITEMS_DRUGS, DIALOG_STYLE_INPUT, "Smuggle Item", "Enter an amount (Max 10)", "Select", "Cancel");
				}
				case 1:
				{
					SetPVarInt(playerid, "Item_To_Smuggle", 1);
					ShowPlayerDialog(playerid, DIALOG_PRISON_ILLEGAL_ITEMS_DRUGS, DIALOG_STYLE_INPUT, "Smuggle Item", "Enter an amount (Max 10)", "Select", "Cancel");
				}
				case 2:
				{
					SetPVarInt(playerid, "Item_To_Smuggle", 2);
					ShowPlayerDialog(playerid, DIALOG_PRISON_ILLEGAL_ITEMS_DRUGS, DIALOG_STYLE_INPUT, "Smuggle Item", "Enter an amount (Max 10)", "Select", "Cancel");
				}
				case 3:
				{
					if(Player[playerid][Money] < PrisonItemPrice[3])
						return SendClientMessage(playerid, -1, "You can't afford this.");
						
					SetPVarInt(playerid, "Item_To_Smuggle", 3);
					ShowPlayerDialog(playerid, DIALOG_PRISON_ILLEGAL_ITEMS_RECEIVER, DIALOG_STYLE_INPUT, "Smuggle Item", "Enter the name of the prisoner.", "Send", "Cancel");
				}
				case 4:
				{
					if(Player[playerid][Money] < PrisonItemPrice[4])
						return SendClientMessage(playerid, -1, "You can't afford this.");
						
					SetPVarInt(playerid, "Item_To_Smuggle", 4);
					ShowPlayerDialog(playerid, DIALOG_PRISON_ILLEGAL_ITEMS_RECEIVER, DIALOG_STYLE_INPUT, "Smuggle Item", "Enter the name of the prisoner.", "Send", "Cancel");
				}
				case 5:
				{
					if(Player[playerid][Money] < PrisonItemPrice[5])
						return SendClientMessage(playerid, -1, "You can't afford this.");
						
					SetPVarInt(playerid, "Item_To_Smuggle", 5);
					ShowPlayerDialog(playerid, DIALOG_PRISON_ILLEGAL_ITEMS_RECEIVER, DIALOG_STYLE_INPUT, "Smuggle Item", "Enter the name of the prisoner.", "Send", "Cancel");
				}	
			}
		}
		case DIALOG_PRISON_ILLEGAL_ITEMS_DRUGS:
		{
			if(!response)
					return 1;
					
			new amount = strval(inputtext);
			if(amount > 10 || amount < 1)
				return ShowPlayerDialog(playerid, DIALOG_PRISON_ILLEGAL_ITEMS_DRUGS, DIALOG_STYLE_INPUT, "Smuggle Item", "Enter an amount (Max 10)", "Select", "Cancel");
			
			if(Player[playerid][Money] < amount*PrisonItemPrice[GetPVarInt(playerid, "Item_To_Smuggle")])
				return SendClientMessage(playerid, WHITE, "You cannot afford this.");
			
			switch(GetPVarInt(playerid, "Item_To_Smuggle"))
			{
				case 0:
				{
					if(Player[playerid][Cocaine] < amount)
						return SendClientMessage(playerid, -1, "You don't have this much cocaine on you.");
				}
				case 1:
				{
					if(Player[playerid][Pot] < amount)
						return SendClientMessage(playerid, -1, "You don't have this much pot on you.");
				}
				case 2:
				{
					if(Player[playerid][Speed] < amount)
						return SendClientMessage(playerid, -1, "You don't have this much speed on you.");
				}
			}
			SetPVarInt(playerid, "Drug_Smuggle_Amount", amount);
			ShowPlayerDialog(playerid, DIALOG_PRISON_ILLEGAL_ITEMS_RECEIVER, DIALOG_STYLE_INPUT, "Smuggle Item", "Enter the name of the prisoner.", "Send", "Cancel");
		}
		case DIALOG_PRISON_ILLEGAL_ITEMS_RECEIVER:
		{
			if(!response)
				return 1;
			
			if(!IsPlayerConnectedEx(GetPlayerID(inputtext)))
			{
				SendClientMessage(playerid, WHITE, "Invalid character name or not connected to the server.");
				return ShowPlayerDialog(playerid, DIALOG_PRISON_ILLEGAL_ITEMS_RECEIVER, DIALOG_STYLE_INPUT, "Smuggle Item", "Enter the name of the prisoner.", "Send", "Cancel");
			}
			
			new id = GetPlayerID(inputtext), item = GetPVarInt(playerid, "Item_To_Smuggle"), amount = GetPVarInt(playerid, "Drug_Smuggle_Amount");
			SetPVarInt(id, "Smuggle_Friend", playerid);
			SetPVarInt(playerid, "Smuggle_Friend", id);
			
			if(Player[id][PrisonID] != 2)
				return SendClientMessage(playerid, WHITE, "[American Accent] Prison Guard says: I don't know anybody who goes by that name.");
			
			if(Player[id][SolitaryDuration] > 0)
				return SendClientMessage(playerid, WHITE, "[American Accent] Prison Guard says: That one is in solitary confinement, I won't be able to get anything to them.");
			
			switch(item)
			{
				case 0: 
				{
					Player[playerid][Cocaine] -= amount;
					Player[playerid][Money] -= amount*PrisonItemPrice[0];
				}
				case 1:
				{
					Player[playerid][Pot] -= amount;
					Player[playerid][Money] -= amount*PrisonItemPrice[1];
				}
				case 2: 
				{
					Player[playerid][Speed] -= amount;
					Player[playerid][Money] -= amount*PrisonItemPrice[2];
				}
				case 3: Player[playerid][Money] -= PrisonItemPrice[3];
				case 4: Player[playerid][Money] -= PrisonItemPrice[4];
				case 5: Player[playerid][Money] -= PrisonItemPrice[5];
			} 
			
			defer SmuggleItemToPrisoner(id);
			switch(random(4))
			{
				case 0: SendClientMessage(playerid, WHITE, "[American Accent] Prison Guard says: I'll get it to your friend, now get out of here.");
				case 1: SendClientMessage(playerid, WHITE, "[American Accent] Prison Guard says: I'll get it done, don't worry.");
				case 2: SendClientMessage(playerid, WHITE, "[American Accent] Prison Guard says: I'll take care of it.");
				case 3: SendClientMessage(playerid, WHITE, "[American Accent] Prison Guard says: Leave it with me, I'll make sure it reaches your person.");
			}
			Player[playerid][SmuggleCooldown] = gettime() + 1800;
		}
		case DIALOG_PRISON_ADMIN_MAIN:
		{
			if(!response)
				return 1;
			
			switch(listitem)
			{
				case 0:
				{
					new string[256];
					format(string, sizeof(string), "Cocaine ($%d each)\nPot ($%d each)\nSpeed ($%d each)\nScrewdriver ($%d)\nShank ($%d)\nRazor ($%d)\nFood (%d tickets)\nCigarettes (%d tickets)\nDice (%d tickets)\nScrewdriver (%d cigs)\nRazor (%d cigs)\nLighter (%d cigs)", PrisonItemPrice[0], PrisonItemPrice[1], PrisonItemPrice[2], PrisonItemPrice[3], PrisonItemPrice[4], PrisonItemPrice[5], PrisonItemPrice[6], PrisonItemPrice[7], PrisonItemPrice[8], PrisonItemPrice[9], PrisonItemPrice[10], PrisonItemPrice[11]);
					ShowPlayerDialog(playerid, DIALOG_PRISON_ADMIN_SETPRICE, DIALOG_STYLE_LIST, "Select an item to change the price of", string, "Select", "Cancel");
				}
				case 1:
				{
					ShowPlayerDialog(playerid, DIALOG_PRISON_ADMIN_JOBMAIN, DIALOG_STYLE_LIST, "Job Settings", "Job Payments\nTicket limit before 30 min cooldown", "Select", "Cancel");
				}
				case 2:
				{
					for(new i; i < MAX_PRISON_ACTORS; i++)
						DestroyActor(PrisonActors[i]);
					
					PrisonActors[0] = CreateActor(71,-497.9132,-561.3230,25.5234,268.4156);	
					PrisonActors[1] = CreateActor(71,-462.5025,-520.7004,-68.9145,91.4353); 
					PrisonActors[2] = CreateActor(71,-455.8994,-520.2752,-68.9145, 0.7243); 
					SetActorVirtualWorld(PrisonActors[1], PRISON_VW);
					SetActorVirtualWorld(PrisonActors[2], PRISON_VW);
					SendClientMessage(playerid, -1, "All prison guards have been respawned.");
				}
				case 3:
				{
					ShowPlayerDialog(playerid, DIALOG_PRISON_ADMIN_PAYCHECK, DIALOG_STYLE_INPUT, "Prison Paycheck", "New ticket paycheck amount", "Select", "Cancel");
				}
			}
		}
		case DIALOG_PRISON_ADMIN_JOBMAIN:
		{
			switch(listitem)
			{
				case 0:
				{
					new string[128];
					format(string, sizeof(string), "Trash job payment (%d tickets)\nLitter job payment (%d tickets)", PrisonItemPrice[12], PrisonItemPrice[13]);
					ShowPlayerDialog(playerid, DIALOG_PRISON_ADMIN_JOBPAY, DIALOG_STYLE_LIST, "Select a job", string, "Select", "Cancel");
				}
				case 1:
				{
					SendClientMessage(playerid, -1, "Prisoners can earn a certain amount of tickets from jobs before they have to wait a 30 minute cooldown.");
					new string[128];
					format(string, sizeof(string), "The current ticket limit before cooldown is triggered is: %d", TicketLimit);
					SendClientMessage(playerid, -1, string);
					ShowPlayerDialog(playerid, DIALOG_PRISON_ADMIN_TICKETLIMIT, DIALOG_STYLE_INPUT, "Prison Ticket Limit", "Enter new max tickets before cooldown", "Select", "Cancel");
				}
			}
		}
		case DIALOG_PRISON_ADMIN_TICKETLIMIT:
		{
			if(!response)
				return 1;
			
			new str[128], amount = strval(inputtext);
			if(amount < 1 || amount > 99999)
				return SendClientMessage(playerid, -1, "Invalid amount");
			
			format(str, sizeof(str), "You have changed the max tickets able to be earned before triggering 30 min cooldown to %d (was %d)", amount, TicketLimit);
			SendClientMessage(playerid, -1, str);
			format(str, sizeof(str), "This means a prisoner can earn %d tickets before they have to wait their 30 minute job cooldown.", amount);
			SendClientMessage(playerid, -1, str);
			TicketLimit = amount;
			dini_IntSet("Assets.ini", "TicketLimit", TicketLimit);
		}
		case DIALOG_PRISON_ADMIN_PAYCHECK:
		{
			if(!response)
				return 1;
				
			new str[128], paycheck = strval(inputtext);
			if(paycheck < 1 || paycheck > 99999)
				return SendClientMessage(playerid, -1, "Invalid amount");
			
			format(str, sizeof(str), "You have changed the prison paycheck to %d tickets (was %d)", paycheck, PrisonPaycheck);
			SendClientMessage(playerid, -1, str);
			PrisonPaycheck = paycheck;			
			dini_IntSet("Assets.ini", "PrisonPaycheck", PrisonPaycheck);
		}
		case DIALOG_PRISON_ADMIN_JOBPAY:
		{
			if(!response)
				return 1;
			
			SetPVarInt(playerid, "Prison_Item_SetPrice", listitem);
			ShowPlayerDialog(playerid, DIALOG_PRISON_ADMIN_JOBPAY_2, DIALOG_STYLE_INPUT, "Job Payment Change", "Enter new payment", "Select", "Cancel"); 
		
		}
		case DIALOG_PRISON_ADMIN_JOBPAY_2:
		{
			if(!response)
				return 1;
			
			new string[128], payment = strval(inputtext), job = GetPVarInt(playerid, "Prison_Item_SetPrice");
			DeletePVar(playerid, "Prison_Item_SetPrice");
			if(payment < 1 || payment > 99999)
				return SendClientMessage(playerid, -1, "Invalid amount");
				
			if(job == 0)
			{
				format(string, sizeof(string), "You have changed the payment of the trash job to %d tickets per trash (was %d)", payment, PrisonItemPrice[12]);
				SendClientMessage(playerid, -1, string);
				SendClientMessage(playerid, -1, "NOTE: The ticket payment is per trash dumped. E.g. if the player dumped 5 trash, it is 5 multipled by ticket payment.");
				PrisonItemPrice[12] = payment;
				dini_IntSet("Assets.ini", "PrisonItemPrice12", PrisonItemPrice[12]);
			}
			else
			{
				format(string, sizeof(string), "You have changed the payment of the litter job to %d tickets per litter cleaned (was %d)", payment, PrisonItemPrice[13]);
				SendClientMessage(playerid, -1, string);
				SendClientMessage(playerid, -1, "NOTE: The ticket payment is per litter cleaned. E.g. if the player cleans 5 litter, it is 5 multipled by ticket payment.");
				PrisonItemPrice[13] = payment;
				dini_IntSet("Assets.ini", "PrisonItemPrice13", PrisonItemPrice[13]);
			}
		}
		case DIALOG_PRISON_ADMIN_SETPRICE:
		{
			if(!response)
				return 1;
				
			SetPVarInt(playerid, "Prison_Item_SetPrice", listitem);
			ShowPlayerDialog(playerid, DIALOG_PRISON_ADMIN_SETPRICE_2, DIALOG_STYLE_INPUT, "Prison Admin Prices Menu", "Enter new price", "Select", "Cancel");
		}
		case DIALOG_PRISON_ADMIN_SETPRICE_2:
		{
			if(!response)
				return 1;
				
			new item = GetPVarInt(playerid, "Prison_Item_SetPrice"), string[128], newprice = strval(inputtext);
			DeletePVar(playerid, "Prison_Item_SetPrice");
			if(newprice < 1 || newprice > 99999)
				return SendClientMessage(playerid, -1, "Invalid amount.");	
			format(string, sizeof(string), "You have changed the price for this item to %d (was %d)", newprice, PrisonItemPrice[item]);
			SendClientMessage(playerid, -1, string);
			PrisonItemPrice[item] = newprice;
			
			new str[128];
			
			switch(item)
			{
				case 0: str = "PrisonItemPrice0";
				case 1: str = "PrisonItemPrice1";
				case 2: str = "PrisonItemPrice2";
				case 3: str = "PrisonItemPrice3";
				case 4: str = "PrisonItemPrice4";
				case 5: str = "PrisonItemPrice5";
				case 6: str = "PrisonItemPrice6";
				case 7: str = "PrisonItemPrice7";
				case 8: str = "PrisonItemPrice8";
				case 9: str = "PrisonItemPrice9";
				case 10: str = "PrisonItemPrice10";
				case 11: str = "PrisonItemPrice11";
				case 12: str = "PrisonItemPrice12";
				case 13: str = "PrisonItemPrice13";
			}
			
			dini_IntSet("Assets.ini", str, PrisonItemPrice[item]);
		}
		case DIALOG_PRISON_BUY_ITEMS:
		{
			if(!response)
				return 1;
				
			switch(listitem)
			{
				case 0:
				{
					if(Player[playerid][PrisonTickets] < PrisonItemPrice[6])
						return SendClientMessage(playerid, WHITE, "You don't have enough tickets to buy food!");
					
					Player[playerid][PrisonTickets] -= PrisonItemPrice[6];
					
					AddHunger(playerid, 30);

					new Float:health;
					GetPlayerHealth(playerid, health);
					health = floatround(health, floatround_ceil);
					if(health > 20 && health < 100)
					{
						if(health + 15 > 100)
							SetPlayerHealth(playerid, 100);
						else
							SetPlayerHealth(playerid, health + 15);
					}
					SendClientMessage(playerid, WHITE, "You have purchased some food with your tickets.");
				}
				case 1:
				{
					if(Player[playerid][PrisonTickets] == 0)
						return SendClientMessage(playerid, WHITE, "You don't have any tickets.");
			
					ShowPlayerDialog(playerid, DIALOG_PRISON_BUY_ITEMS_2, DIALOG_STYLE_INPUT, "Buy an item", "How many do you want? Max 30", "Select", "Cancel");
				}
				case 2:
				{
					if(Player[playerid][PrisonDice] > 0)
						return SendClientMessage(playerid, WHITE, "You already have dice.");
					
					if(Player[playerid][PrisonTickets] < PrisonItemPrice[8])
						return SendClientMessage(playerid, WHITE, "You don't have enough tickets to purchase dice.");
					
					Player[playerid][PrisonTickets] -= PrisonItemPrice[8];
					Player[playerid][PrisonDice] = 1;
					
					SendClientMessage(playerid, WHITE, "You have purchased some dice. You can now use /dice in prison.");
				}
				case 3:
				{
					if(Player[playerid][PrisonTickets] < 10)
						return SendClientMessage(playerid, WHITE, "You don't have enough tickets to purchase a medkit.");
					
					Player[playerid][PrisonTickets] -= 10;
					SetPlayerHealth(playerid, 100);
				}
			}
		}
		case DIALOG_PRISON_BUY_ITEMS_2:
		{
			if(!response)
				return 1;
				
			new amount = strval(inputtext), price, string[128];
			if(amount < 1 || amount > 30)
				return SendClientMessage(playerid, WHITE, "Invalid amount");
			
			price = amount * PrisonItemPrice[7];
			
			if(Player[playerid][PrisonTickets] < price)
				return SendClientMessage(playerid, WHITE, "You don't have enough tickets!");
			
			Player[playerid][PrisonTickets] -= price;
			Player[playerid][Cigarettes] += amount;
			format(string, sizeof(string), "You have purchased %d cigarettes for %d tickets.", amount, price);
			SendClientMessage(playerid, WHITE, string);
			SendClientMessage(playerid, WHITE, "Use /lightcig to smoke the cigarette if you have a lighter.");
		}
		case DIALOG_PRISON_BUY_ITEMS_ILLEGAL:
		{
			if(!response)
				return 1;
				
			switch(listitem)
			{
				case 0: 
				{
					if(Player[playerid][Cigarettes] < PrisonItemPrice[9])
						return SendClientMessage(playerid, WHITE, "You don't have enough cigarettes to purchase a screwdriver.");
						
					if(Player[playerid][PrisonScrewdriver] > 0)
						return SendClientMessage(playerid, WHITE, "You already have a screwdriver.");
					
					Player[playerid][Cigarettes] -= PrisonItemPrice[9];
					Player[playerid][PrisonScrewdriver] = 1;
					
					new string[128];
					format(string, sizeof(string), "You have purchased a screwdriver for %d cigarettes.", PrisonItemPrice[9]);
					SendClientMessage(playerid, WHITE, string);
				}
				case 1:
				{
					if(Player[playerid][Cigarettes] < PrisonItemPrice[10])
						return SendClientMessage(playerid, WHITE, "You don't have enough cigarettes to purchase a razor.");
						
					if(Player[playerid][PrisonRazor] > 0)
						return SendClientMessage(playerid, WHITE, "You already have a razor.");
					
					Player[playerid][Cigarettes] -= PrisonItemPrice[10];
					Player[playerid][PrisonRazor] = 1;
					
					new string[128];
					format(string, sizeof(string), "You have purchased a razor for %d cigarettes.", PrisonItemPrice[10]);
					SendClientMessage(playerid, WHITE, string);
				}
				case 2:
				{
					if(Player[playerid][Cigarettes] < PrisonItemPrice[11])
						return SendClientMessage(playerid, WHITE, "You don't have enough cigarettes to purchase a lighter.");
						
					if(Player[playerid][PrisonLighter] > 0)
						return SendClientMessage(playerid, WHITE, "You already have a lighter.");
					
					Player[playerid][Cigarettes] -= PrisonItemPrice[11];
					Player[playerid][PrisonLighter] = 1;
					
					new string[128];
					format(string, sizeof(string), "You have purchased a lighter for %d cigarettes.", PrisonItemPrice[11]);
					SendClientMessage(playerid, WHITE, string);
					SendClientMessage(playerid, WHITE, "You can now light cigarettes using /lightcig");
				}
			}
			Player[playerid][PrisonBuyItemCooldown] = gettime() + 1800;
		}
		case DIALOG_PRISON_CONTROLPANEL_1:
		{
			if(!response)
				return 1;
			
			switch(listitem)
			{
				case 0:
				{
					new str[1000], count = 1;
					foreach(new i : DoorGate)
					{
						if(DoorGates[i][Type] == GATE_TYPE_CELL)
						{
							format(str, sizeof(str), "%s%d | Cell %d | Status: %s\n", str, i, count, (DoorGates[i][IsOpen]) ? ("{33A10B}Open{FFFFFF}") : ("{FF0000}Closed{FFFFFF}"));
							count++;
						}
					}
					
					ShowPlayerDialog(playerid, DIALOG_PRISON_CONTROLPANEL_2, DIALOG_STYLE_LIST, "{00BBFF}Correctional Facility Control Panel", str, "Select", "Cancel");
				}
				case 1:
				{		
					new string[500], count = 1;
					for(new i; i < MAX_SOLITARY_CELLS; i++)
					{
						format(string, sizeof(string), "%s%d | Solitary Cell %d | Occupied: %s\n", string, i, count, (Solitary[i][Occupied]) ? ("{FF0000}Yes{FFFFFF}") : ("{33A10B}No{FFFFFF}"));
						count++;
					}
					ShowPlayerDialog(playerid, DIALOG_PRISON_CONTROLPANEL_3, DIALOG_STYLE_LIST, "{00BBFF}Correctional Facility Control Panel", string, "Select", "Cancel");
				}
				case 2:
				{
					if(Player[playerid][GroupRank] < 5)
						return SendClientMessage(playerid, -1, "Error! You are not authorized to do this.");
					
					new string[128]; 
					if(PrisonLockdown == 0)
					{
						format(string, sizeof(string), "%s has initiated lockdown. All cells and doors have been locked in the prison.", GetNameEx(playerid));
						GroupMessage(playerid, ANNOUNCEMENT, string, 1);
						PrisonLockdown = 1;
						foreach(new i : DoorGate)
						{
							if(DoorGates[i][Type] != GATE_TYPE_CELL)
								continue;
							
							MoveDynamicObject(DoorGates[i][ObjectID], DoorGates[i][ClosePos][0], DoorGates[i][ClosePos][1], DoorGates[i][ClosePos][2], DoorGates[i][dSpeed], DoorGates[i][CloseRot][0], DoorGates[i][CloseRot][1], DoorGates[i][CloseRot][2]);
							MoveLinkedDoorGates(i);
							DoorGates[i][IsOpen] = 0;
						}
						foreach(Player, i)
						{
							if(!IsPlayerInRangeOfPoint(i, 60, -457.2030,-518.6462,-68.9141) && !IsPlayerInRangeOfPoint(i, 80, -573.6481,-536.0297,25.5234))
								continue;

							PlayerPlaySound(i, 6001, 0, 0, 0);
							defer EndAlarm(i);
						}
					}
					else
					{
						format(string, sizeof(string), "%s has lifted the lockdown. All cells and doors have been unlocked in the prison.", GetNameEx(playerid));
						GroupMessage(playerid, ANNOUNCEMENT, string, 1);
						PrisonLockdown = 0;
						foreach(new i : DoorGate)
						{
							if(DoorGates[i][Type] != GATE_TYPE_CELL)
								continue;
							
							MoveDynamicObject(DoorGates[i][ObjectID], DoorGates[i][OpenPos][0], DoorGates[i][OpenPos][1], DoorGates[i][OpenPos][2], DoorGates[i][dSpeed], DoorGates[i][OpenRot][0], DoorGates[i][OpenRot][1], DoorGates[i][OpenRot][2]);
							DoorGates[i][IsOpen] = 1;
							MoveLinkedDoorGates(i);
						}
					}
				}
			}
		}
		case DIALOG_PRISON_CONTROLPANEL_2:
		{
			if(!response)
				return 1;
					
			new id, str[1000], count = 1;
			id = strval(CutBeforeLine(inputtext));
			
			if(DoorGates[id][IsOpen] == 0)
			{
				MoveDynamicObject(DoorGates[id][ObjectID], DoorGates[id][OpenPos][0], DoorGates[id][OpenPos][1], DoorGates[id][OpenPos][2], DoorGates[id][dSpeed], DoorGates[id][OpenRot][0], DoorGates[id][OpenRot][1], DoorGates[id][OpenRot][2]);
				DoorGates[id][IsOpen] = 1;
				MoveLinkedDoorGates(id);
			}
			else
			{
				MoveDynamicObject(DoorGates[id][ObjectID], DoorGates[id][ClosePos][0], DoorGates[id][ClosePos][1], DoorGates[id][ClosePos][2], DoorGates[id][dSpeed], DoorGates[id][CloseRot][0], DoorGates[id][CloseRot][1], DoorGates[id][CloseRot][2]);
				MoveLinkedDoorGates(id);
				DoorGates[id][IsOpen] = 0;
			}
				
			foreach(new i : DoorGate)
			{
				if(DoorGates[i][Type] == GATE_TYPE_CELL)
				{
					format(str, sizeof(str), "%s%d | Cell %d | Status: %s\n", str, i, count, (DoorGates[i][IsOpen]) ? ("{33A10B}Open{FFFFFF}") : ("{FF0000}Closed{FFFFFF}"));
					count++;
				}
			}
			ShowPlayerDialog(playerid, DIALOG_PRISON_CONTROLPANEL_2, DIALOG_STYLE_LIST, "{00BBFF}Correctional Facility Control Panel", str, "Select", "Cancel");
		}
		case DIALOG_PRISON_CONTROLPANEL_3:
		{
			if(!response)
			{
				new str[128];
				format(str, sizeof(str), "Cells\nSolitary\n%s", (PrisonLockdown) ? ("{33A10B}REVERT LOCKDOWN{FFFFFF}") : ("{FF0000}LOCKDOWN{FFFFFF}"));
				return ShowPlayerDialog(playerid, DIALOG_PRISON_CONTROLPANEL_1, DIALOG_STYLE_LIST, "{00BBFF}Correctional Facility Control Panel", str, "Select", "Cancel");
			}
			
			new id, string[500];
			id = strval(CutBeforeLine(inputtext));
			if(Solitary[id][Occupied] == 0)
			{
				SendClientMessage(playerid, -1, "This solitary cell isn't occupied.");
				new count = 1;
				for(new i; i < MAX_SOLITARY_CELLS; i++)
				{
					format(string, sizeof(string), "%s%d | Solitary Cell %d | Occupied: %s\n", string, i, count, (Solitary[i][Occupied]) ? ("{FF0000}Yes{FFFFFF}") : ("{33A10B}No{FFFFFF}"));
					count++;
				}
				return ShowPlayerDialog(playerid, DIALOG_PRISON_CONTROLPANEL_3, DIALOG_STYLE_LIST, "{00BBFF}Correctional Facility Control Panel", string, "Select", "Cancel");
			}
			SetPVarInt(playerid, "SolitaryCell", id);
			SetPVarInt(playerid, "Solitary_Release_ID", GetPlayerID(Solitary[id][OccupiedBy]));
			format(string, sizeof(string), "Occupied by: %s", Solitary[id][OccupiedBy]);
			ShowPlayerDialog(playerid, DIALOG_PRISON_CONTROLPANEL_4, DIALOG_STYLE_MSGBOX, "{00BBFF}Correctional Facility Control Panel", string, "Release", "Cancel");
		}
		case DIALOG_PRISON_CONTROLPANEL_4:
		{
			if(!response)
			{
				DeletePVar(playerid, "Solitary_Release_ID");
				DeletePVar(playerid, "SolitaryCell");
				return 1;
			}
			
			if(Player[playerid][GroupRank] < 5)
				return SendClientMessage(playerid, -1, "Error! You are not authorized to release prisoners from solitary.");
			
			new string[128], id = GetPVarInt(playerid, "Solitary_Release_ID"), cell = GetPVarInt(playerid, "SolitaryCell");
			DeletePVar(playerid, "Solitary_Release_ID");
			DeletePVar(playerid, "SolitaryCell");
			Solitary[cell][Occupied] = 0;
			format(string, sizeof(string), "You have been released early from solitary confinement by %s.", GetNameEx(playerid));
			SendClientMessage(id, WHITE, string);
			format(string, sizeof(string), "You have released %s from solitary confinement.", GetNameEx(id));
			SendClientMessage(playerid, WHITE, string);
			Player[id][SolitaryDuration] = -1;
			SetPlayerVirtualWorld(id, PRISON_VW);
			new r = random(MAX_SOLITARY_CELLS);
			SetPlayerPos_Update(id, Solitary[r][Sx], Solitary[r][Sy], Solitary[r][Sz]);
			DeletePVar(id, "Solitary_Number");
		}
		case DIALOG_PRISON_GETJOB:
		{
			if(!response)
				return 1;
			
			switch(listitem)
			{
				case 0:
				{
					if(GetPVarInt(playerid, "prisonjob") > 0)
						return SendClientMessage(playerid, WHITE, "You already have a prison job. Type /endprisonjob first.");
					
					new string[128];
					format(string, sizeof(string), "* %s tears off a job slip from the wall.", GetNameEx(playerid));
					NearByMessage(playerid, NICESKY, string);
					
					SendClientMessage(playerid, WHITE, "Type /pickuptrash and take the trash outside to the dumpster.");
					SendClientMessage(playerid, GREY, "You will gain tickets from this job which can be used to purchase items in prison.");
					SendClientMessage(playerid, GREY, "Prison jobs do not replace your normal jobs. Type /endprisonjob to stop and redeem your tickets earned.");
					
					SetPVarInt(playerid, "prisonjob", 1);
					SetPVarInt(playerid, "jobcounter", 0);
				}
				case 1:
				{
					if(GetPVarInt(playerid, "prisonjob") > 0)
						return SendClientMessage(playerid, WHITE, "You already have a prison job. Type /endprisonjob first.");
					
					new string[128];
					format(string, sizeof(string), "* %s tears off a job slip from the wall.", GetNameEx(playerid));
					NearByMessage(playerid, NICESKY, string);
					
					SendClientMessage(playerid, WHITE, "Find litter throughout the prison and clean it up (/cleanup).");
					SendClientMessage(playerid, GREY, "You will gain tickets from this job which can be used to purchase items in prison.");
					SendClientMessage(playerid, GREY, "Prison jobs do not replace your normal jobs. Type /endprisonjob to stop and redeem your tickets earned.");
					
					SetPVarInt(playerid, "prisonjob", 2);
					SetPVarInt(playerid, "jobcounter", 0);
				}
			}
		}
		case DIALOG_LIFE_IN_PRISON:
		{
			if(!response)
				return 1;
				
			ShowPlayerDialog(playerid, DIALOG_LIFE_IN_PRISON+1, DIALOG_STYLE_PASSWORD, "Life In Prison", "Please enter your password to confirm that you are okay with\nimprisoning your character for life.", "Confirm", "Cancel");
		}
		case DIALOG_LIFE_IN_PRISON+1:
		{
			if(!response)
				return 1;
			
			new pass[512], buff[162];
			strcat(pass, inputtext, sizeof(pass));
			strcat(pass, Player[playerid][pSalt], sizeof(pass));
			WP_Hash(buff, sizeof(buff), pass);

			if(!strcmp(buff, Player[playerid][Password], true))
			{
				SetPlayerToggle(playerid, TOGGLE_WALKIE, true);
				Player[playerid][PrisonID] = 2;
				ResetPlayerWeaponsEx(playerid);
				FindCellForPlayer(playerid);
				Player[playerid][SolitaryDuration] = -1;
				Player[playerid][PrisonLifer] = 1;
				SetPlayerArmour(playerid, 0);
				SetPlayerInterior(playerid, 0);
				SetPlayerWeather(playerid, 0);
				SavePlayerData(playerid);
				
				new string[128];
				SendClientMessage(playerid, WHITE, "You have been sent to prison for life, enjoy!");
				format(string, sizeof(string), "%s has sent themselves to prison for life.", GetName(playerid));
				NearByMessage(playerid, ANNOUNCEMENT, string);
				StatLog(string);
			}
			else SendClientMessage(playerid, RED, "You entered the wrong password!!!");
			return 1;
		}
	}
	return 1;
}


// ============= Functions / Timers =============

timer SmuggleItemToPrisoner[300000](id)
{
	if(!IsPlayerConnectedEx(id))
		return 1;
	
	new i = GetPVarInt(id, "Smuggle_Friend");
	
	if(!IsPlayerConnectedEx(i))
		return 1;
		
	switch(random(3))
	{
		case 0:
		{
			if(Player[i][PhoneN] != -1)
			{
				SendClientMessage(i, PHONE, "SMS from Unknown (BLOCKED): Hey! Sorry to say this but I lost what you gave me! Sorry pal :)");
				PlayerPlaySound(i, 21000, 0.00, 0.00, 0.00);
			}
			DeletePVar(i, "Smuggle_Friend");
			DeletePVar(id, "Smuggle_Friend");
			DeletePVar(i, "Drug_Smuggle_Amount");
			DeletePVar(i, "Item_To_Smuggle");
		}
		case 1:
		{
			if(Player[i][PhoneN] != -1)
			{
				SendClientMessage(i, PHONE, "SMS from Unknown (BLOCKED): I almost got in deep shit for trying to smuggle your items! I had to tell them everything, sorry!");
				PlayerPlaySound(i, 21000, 0.00, 0.00, 0.00);
			}	
				
			new query[255], string[128], second, minute, hour, day, month, year;
			gettime(hour, minute, second);
			getdate(year, month, day);
			format(string, sizeof(string), "%d/%d/%d at %02d:%02d:%02d", month, day, year, (hour + 4 >= 24) ? ((hour + 4) - 24) : (hour + 4), minute, second);
			mysql_format(MYSQL_MAIN, query, sizeof(query), "INSERT INTO PoliceCrimes (Crime, criminalName, arrestingOfficer, timeGiven, Active) VALUES ('Smuggling Contraband', \'%e\', 'PRISON', \'%e\', \'1\')", GetName(i), string);
			mysql_query(MYSQL_MAIN, query, false);

			if(!IsSolitaryFull())
			{
				SendClientMessage(id, RED, "Somebody has been caught trying to smuggle items to you!");	
				SendClientMessage(id, RED, "You have been sent to solitary confinement for 10 minutes!");
				SendClientMessage(id, WHITE, "You will be automatically released from solitary when your time is up.");
				Player[id][SolitaryDuration] = 600;
				FindSolitaryForPlayer(id);
			}
				
			DeletePVar(i, "Smuggle_Friend");
			DeletePVar(id, "Smuggle_Friend");
			DeletePVar(i, "Drug_Smuggle_Amount");
			DeletePVar(i, "Item_To_Smuggle");
		}
		case 2:
		{
			SetPVarInt(id, "Smuggle_Success", 1);
			SendClientMessage(id, WHITE, "It looks like one of the guards just put something in the trash can.");
		}
	}
	return 1;
}

timer EndAlarm[22000](i)
{
	PlayerPlaySound(i, 6003, 0, 0, 999);
	return 1;
}
task SpawnLitterObject[300000]()
{
	new spawned = 0, rand, counter, vw;
	while(spawned == 0)
	{
		rand = random(MAX_LITTER);
		if(!IsValidDynamicObject(LitterObjects[rand][ObjectID]))
		{
			if(rand < 4 || rand == 7)
				vw = 0;
			else
				vw = PRISON_VW;
				
			LitterObjects[rand][ObjectID] = CreateDynamicObject(LITTER_OBJECT, LitterObjects[rand][Lx], LitterObjects[rand][Ly], LitterObjects[rand][Lz], 0, 0, 0, vw);
			spawned = 1;
		}
		counter++;
		if(counter == MAX_LITTER)
			spawned = 1;
	}
}

stock IsPrisonFull()
{
	new AmountOccupied;
	for(new i; i < MAX_CELLS; i++)
	{
		if(Cells[i][Occupied] == 1)
			AmountOccupied++;
	}
	if(AmountOccupied == MAX_CELLS)
		return 1;
	else
		return 0;
}

stock FindCellForPlayer(id)
{
	for(new i; i < MAX_CELLS; i++)
	{
		if(IsPrisonFull())
		{
			new rand = random(MAX_CELLS);
			SetPlayerPos_Update(id, Cells[rand][Cx], Cells[rand][Cy], Cells[rand][Cz]);
			Cells[i][PrisonerAmount]++;
			SetPVarInt(id, "Solitary_Number", -1);
			break;
		}
		if(Cells[i][Occupied] == 1)
			continue;
					
		SetPlayerPos_Update(id, Cells[i][Cx], Cells[i][Cy], Cells[i][Cz]);
		SetPVarInt(id, "Cell_Number", i);
		Cells[i][PrisonerAmount]++;
		Cells[i][Occupied] = 1;
		SetPVarInt(id, "Solitary_Number", -1);
		break;
	}
	SetPlayerVirtualWorld(id, PRISON_VW);
	return 1;
}
stock CellChanged(cell)
{
	Cells[cell][PrisonerAmount]--;
	if(Cells[cell][PrisonerAmount] < 1)
		Cells[cell][Occupied] = 0;
	else
		Cells[cell][Occupied] = 1;
	return 1;
}

stock IsSolitaryFull()
{
	new AmountOccupied;
	for(new i; i < MAX_SOLITARY_CELLS; i++)
	{
		if(Solitary[i][Occupied] == 1)
			AmountOccupied++;
	}
	if(AmountOccupied == MAX_SOLITARY_CELLS)
		return 1;
	else
		return 0;
}

stock FindSolitaryForPlayer(id)
{
	for(new i; i < MAX_SOLITARY_CELLS; i++)
	{
		if(IsSolitaryFull())
		{
			SetPlayerPos_Update(id, -468.7192,-514.4734,-68.9141); // default spawn
			SetPlayerVirtualWorld(id, PRISON_VW);
			break;
		}
		
		if(Solitary[i][Occupied] == 1)
			continue;
					
		SetPlayerPos_Update(id, -461.6455,-474.2492,-63.0137);
		SetPVarInt(id, "Solitary_Number", i);
		Solitary[i][Occupied] = 1;
		Solitary[i][OccupiedBy] = GetName(id);
		new virtualworld = 45000 + id + random(20);
		SetPlayerVirtualWorld(id, virtualworld);
		break;
	}
	return 1;
}

stock LoadPrisonActorsIcons()
{
	PrisonActors[0] = CreateActor(71,-497.9132,-561.3230,25.5234,268.4156);	// Corrupt Outside Guard
	PrisonActors[1] = CreateActor(71,-462.5025,-520.7004,-68.9145,91.4353); // Corrupt Inside Guard
	PrisonActors[2] = CreateActor(71,-455.8994,-520.2752,-68.9145, 0.7243); // Legal Inside Guard
	SetActorVirtualWorld(PrisonActors[1], PRISON_VW);
	SetActorVirtualWorld(PrisonActors[2], PRISON_VW);

	CreateDynamicPickup(1239, 23, -505.8200,-523.3130,26.1042, 0, 0, -1, 150.0);
	CreateDynamicPickup(1239, 23, -534.7742,-546.0823,25.5234, 0, 0, -1, 150.0);
	CreateDynamicPickup(1239, 23, -598.3393,-511.7646,25.5234, 0, 0, -1, 150.0); 
	CreateDynamicPickup(1239, 23, -484.3624,-510.2009,-68.9141, PRISON_VW, 0, -1, 150.0);
	CreateDynamicPickup(1239, 23, -466.5263,-502.5333,-68.9145, PRISON_VW, 0, -1, 150.0); 
	CreateDynamicPickup(1239, 23, -473.0233,-502.2969,-68.9145, PRISON_VW, 0, -1, 150.0); 

	PrisonLabels[0] = CreateDynamic3DTextLabel("/talktoguard", YELLOW, -497.9132,-561.3230,25.5234, 5, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0);
	PrisonLabels[1] = CreateDynamic3DTextLabel("/leaveprison", ORANGE, -440.9868,-543.6298,-68.9137, 10, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, PRISON_VW);
	PrisonLabels[2] = CreateDynamic3DTextLabel("/leaveprison", ORANGE, -465.7999,-543.5829,-68.9145, 10, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, PRISON_VW);
	PrisonLabels[3] = CreateDynamic3DTextLabel("/searchtrash", YELLOW, -566.77960, -513.81287, 25.07370, 3, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0);
	PrisonLabels[4] = CreateDynamic3DTextLabel("/buyitems", YELLOW, -455.8994,-520.2752,-68.9145, 3, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, PRISON_VW); // legal
	PrisonLabels[5] = CreateDynamic3DTextLabel("/buyitems", YELLOW, -462.5025,-520.7004,-68.9145, 3, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, PRISON_VW); // illegal
	PrisonLabels[6] = CreateDynamic3DTextLabel("/controlpanel", COLOR_LIGHTBLUE, -474.6639,-505.0270,-65.2356, 6, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, PRISON_VW);
	PrisonLabels[7] = CreateDynamic3DTextLabel("/dumptrash", YELLOW, -597.7469,-533.1406,25.5234, 7, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0);
	PrisonLabels[8] = CreateDynamic3DTextLabel("/pickuptrash\n/droplitter", YELLOW, -468.9137,-523.9198,-68.9145, 5, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, PRISON_VW);
	PrisonLabels[9] = CreateDynamic3DTextLabel("/getjob", YELLOW, -471.9034, -522.3404, -68.5037, 3, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, PRISON_VW);
	PrisonLabels[10] = CreateDynamic3DTextLabel("San Andreas Correctional Facility", GREEN, -505.8200,-523.3130,26.5042, 10, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0);
	return 1;
}