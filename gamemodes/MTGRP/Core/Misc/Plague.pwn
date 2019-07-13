/*
#		MTG Plague
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

static string[128];
new PlayerText:BlackoutTD[MAX_PLAYERS];

#define MTG_PLAGUE

#define PLAGUE_FIRST_NOTICE				1800	//30 minutes
#define PLAGUE_SECOND_NOTICE			9000 	//2.5 hours

#define PLAGUE_COUGH_MIN				18000 	//5 hours 
#define PLAGUE_COUGH_INTERVAL			1800 	//30 minutes
#define PLAGUE_COUGH_CHANCE				25 		//25 percent

#define PLAGUE_BLACKOUT_MIN				36000	//10 hours
#define PLAGUE_BLACKOUT_INTERVAL		3600	//1 hour
#define PLAGUE_BLACKOUT_CHANCE			15		//15 percent

#define PLAGUE_PUKE_MIN					86400	//24 hours
#define PLAGUE_PUKE_INTERVAL			21600	//6 hours
#define PLAGUE_PUKE_CHANCE				7		//7 percent

#define PLAGUE_SPEECH_MIN				36000 * 3 	//30 hours
#define PLAGUE_SPEECH_MAX_CHANCE		60			//60 percent max
#define MAX_WORDS_MOVED					10			//10 words per sentence max

#define GASMASK_OBJECT_ID				19472

// ============= Callbacks =============

hook OnPlayerConnect(playerid)
{
	BlackoutTD[playerid] = CreatePlayerTextDraw(playerid, -20.000000, 2.000000, "_");
	PlayerTextDrawUseBox(playerid, BlackoutTD[playerid], 1);
	PlayerTextDrawBoxColor(playerid, BlackoutTD[playerid], 0x00000000);
	PlayerTextDrawTextSize(playerid, BlackoutTD[playerid], 660.000000, 22.000000);
	PlayerTextDrawAlignment(playerid, BlackoutTD[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, BlackoutTD[playerid], 0x000000FF);
	PlayerTextDrawFont(playerid, BlackoutTD[playerid], 3);
	PlayerTextDrawLetterSize(playerid, BlackoutTD[playerid] ,1.000000, 52.200000);
	PlayerTextDrawColor(playerid, BlackoutTD[playerid], 0x000000FF);
	PlayerTextDrawSetOutline(playerid, BlackoutTD[playerid], 1);
	PlayerTextDrawSetProportional(playerid, BlackoutTD[playerid], 1);
	PlayerTextDrawSetShadow(playerid, BlackoutTD[playerid], 1);
	return 1;
}

// ============= Timers =============

ptask PlagueTimer[1000](i)
{
	if(Player[i][Infected] == 1)
	{
		Player[i][VirusCount] ++;
		
		if(Player[i][VirusCount] == PLAGUE_FIRST_NOTICE)
			SendClientMessage(i, LSFMD_PEACH, "You are feeling noticeably hotter than usual and are sweating more than normal. I wonder what could be wrong?");
		
		if(Player[i][VirusCount] == PLAGUE_SECOND_NOTICE)
			SendClientMessage(i, LSFMD_PEACH, "Your throat is beginning to become scratchy. Maybe you should purchase some cough drops.");
		
		if(Player[i][VirusCount] % PLAGUE_COUGH_INTERVAL == 0 && Player[i][VirusCount] >= PLAGUE_COUGH_MIN) //Every 30 minutes
		{
			if(random(100) < PLAGUE_COUGH_CHANCE)
			{
				if(Player[i][WearingGasMask] == 0)
				{
					format(string, sizeof(string), "* %s coughs violently into the air.", GetNameEx(i));
					InfectNearbyPlayers(i);
				}
				else 
				{
					format(string, sizeof(string), "* %s coughs violently into their gas mask.", GetNameEx(i));
					if(random(100) == 0) 
						InfectNearbyPlayers(i);
				}
				ApplyAnimation(i, "ped", "gas_cwr", 4.1, 0, 0, 0, 0, 0, 0);
				NearByMessage(i, NICESKY, string);
			}
		}
		
		if(Player[i][VirusCount] % PLAGUE_BLACKOUT_INTERVAL == 0 && Player[i][VirusCount] >= PLAGUE_BLACKOUT_MIN)
		{
			if(random(100) < PLAGUE_BLACKOUT_CHANCE)
			{
				SendClientMessage(i, LSFMD_PEACH, "You begin to feel woozy and start to lose your balance.");
				PlayerTextDrawShow(i, BlackoutTD[i]);
				SetPlayerDrunkLevel(i, 2500);
				Player[i][Blackout] = repeat BlackoutTimer(i);
			}
		}
		
		if(Player[i][VirusCount] % PLAGUE_PUKE_INTERVAL == 0 && Player[i][VirusCount] >= PLAGUE_PUKE_MIN)
		{
			if(random(100) < PLAGUE_PUKE_CHANCE)
			{
				if(!IsPlayerInAnyVehicle(i))
					ApplyAnimation(i, "FOOD", "EAT_Vomit_P", 4.1, 0, 1, 1, 0, 0, 1);
				
				InfectNearbyPlayers(i);
				format(string, sizeof(string), "* %s begins to vomit onto the floor%s.", GetNameEx(i), (IsPlayerInAnyVehicle(i) && !IsAnyBike(GetPlayerVehicleID(i))) ? (" of the vehicle") : (""));
				NearByMessage(i, NICESKY, string);
				AddHunger(i, -25);
			}
		}
	}
	return 1;
}

timer BlackoutTimer[1000](i)
{
	Player[i][BlackoutCount]++;
	SetBlackoutTDTransparency(i);
	SetPlayerDrunkLevel(i, GetPlayerDrunkLevel(i) + 500);
	
	if(Player[i][BlackoutCount] == 10)
	{
		if(!IsPlayerInAnyVehicle(i))
		{
			format(string, sizeof(string), "* %s passes out and collapses to the ground.", GetNameEx(i));
			ApplyAnimation(i, "PED", "KO_shot_front", 4.1, 0, 1, 1, 1, 0, 1);
		}
		else format(string, sizeof(string), "* %s passes out and falls to the side.", GetNameEx(i));
		NearByMessage(i, NICESKY, string);
		
		Player[i][BlackoutCount] = 0;
		stop Player[i][Blackout];
		
		Player[i][PassedOut] = 1;
		Player[i][PassedOutTimer] = repeat PlayerPassedOutTimer(i);
	}
	return 1;
}

timer PlayerPassedOutTimer[1000](i)
{
	Player[i][PassedOut]++;
	
	if(Player[i][PassedOut] >= 5)
	{
		PlayerTextDrawHide(i, BlackoutTD[i]);
		switch(Player[i][PassedOut])
		{
			case 5: PlayerTextDrawBoxColor(i, BlackoutTD[i],  0x000000BB);
			case 6: PlayerTextDrawBoxColor(i, BlackoutTD[i],  0x00000080);
			case 7:	PlayerTextDrawBoxColor(i, BlackoutTD[i],  0x00000070);
			case 8: PlayerTextDrawBoxColor(i, BlackoutTD[i],  0x00000060);
			case 9:	PlayerTextDrawBoxColor(i, BlackoutTD[i],  0x00000050);
			case 10: PlayerTextDrawBoxColor(i, BlackoutTD[i],  0x00000040);
			case 11: PlayerTextDrawBoxColor(i, BlackoutTD[i],  0x00000030);
			case 12: PlayerTextDrawBoxColor(i, BlackoutTD[i],  0x00000020);
			case 13: PlayerTextDrawBoxColor(i, BlackoutTD[i],  0x00000010);
			case 14: 
			{
				format(string, sizeof(string), "* %s regains conciousness and picks themselves up.", GetNameEx(i));
				NearByMessage(i, NICESKY, string);
				
				SetPlayerDrunkLevel(i, 0);
				ClearAnimations(i);
				PlayerTextDrawHide(i, BlackoutTD[i]);
				
				stop Player[i][PassedOutTimer];
				Player[i][PassedOut] = 0;
			}
		}
		if(Player[i][PassedOut] < 14)
			PlayerTextDrawShow(i, BlackoutTD[i]);
	}
	return 1;
}

// ============= Commands ==============

new GasMasksEnabled = 0;
CMD:enablegasmasks(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 8)
		return 1;
	
	if(GasMasksEnabled)
	{
		SendClientMessage(playerid, -1, "Disabled. /givegasmask no longer works.");
		GasMasksEnabled = 0;
	}
	else
	{
		SendClientMessage(playerid, -1, "Enabled. /givegasmask now works for PD R7+.");
		GasMasksEnabled = 1;
	}
	return 1;
}
CMD:givegasmask(playerid, params[])
{
	if(Groups[Player[playerid][Group]][CommandTypes] != 1)
		return 1;
	
	if(Player[playerid][GroupRank] < 7)
		return 1;
	
	if(!GasMasksEnabled)
		return 1;
	
	new id;
	if(sscanf(params, "u", id))
		return SendClientMessage(playerid, -1, "SYNTAX: /givegasmask [playerid]");
		
	if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, -1, "That player isn't connected.");
		
	if(Player[id][HasGasMask] > 0)
		return SendClientMessage(playerid, -1, "That player already has a gas mask.");
		
	Player[id][HasGasMask] = 1;
	
	format(string, sizeof(string), "* %s hands %s a gas mask.", GetNameEx(playerid), GetNameEx(id));
	NearByMessage(playerid, NICESKY, string);
	format(string, sizeof(string), "You have given %s a gas mask.", GetName(id));
	SendClientMessage(playerid, WHITE, string);
	format(string, sizeof(string), "%s has given you a gas mask.", GetName(playerid));
	SendClientMessage(id, WHITE, string);
	return 1;
}

CMD:togglegasmask(playerid, params[])
{
	if(Player[playerid][HasGasMask] == 0)
		return SendClientMessage(playerid, WHITE, "You don't have a gas mask!");
		
	switch(Player[playerid][WearingGasMask])
	{
		case 0:
		{
			new slot = GetEmptySlotAttachment(playerid);
			if(slot == -1)
				return SendClientMessage(playerid, WHITE, "You don't have anymore attachment slots! Take off a toy to free one up.");
			
			if(Player[playerid][GasMaskOffsets][6] == 0.0 && Player[playerid][GasMaskOffsets][7] == 0.0 && Player[playerid][GasMaskOffsets][8] == 0.0)
			{
				Player[playerid][GasMaskOffsets][6] = 1.0;
				Player[playerid][GasMaskOffsets][7] = 1.0;
				Player[playerid][GasMaskOffsets][8] = 1.0;
			
			}
			
			SetPlayerAttachedObject(playerid, slot, GASMASK_OBJECT_ID, 18, Player[playerid][GasMaskOffsets][0], Player[playerid][GasMaskOffsets][1], Player[playerid][GasMaskOffsets][2], Player[playerid][GasMaskOffsets][3], Player[playerid][GasMaskOffsets][4], Player[playerid][GasMaskOffsets][5], Player[playerid][GasMaskOffsets][6], Player[playerid][GasMaskOffsets][7], Player[playerid][GasMaskOffsets][8]);
			Player[playerid][WearingGasMask] = slot + 1;
			format(string, sizeof(string), "* %s pulls a gas mask over their face.", GetNameEx(playerid));
			NearByMessage(playerid, NICESKY, string);
			SendClientMessage(playerid, YELLOW, "[TIP] Use /editgasmask to edit the mask.");
		}
		default:
		{
			RemovePlayerAttachedObject(playerid, Player[playerid][WearingGasMask] - 1);
			Player[playerid][WearingGasMask] = 0;
			format(string, sizeof(string), "* %s removes the gas mask from their face.", GetNameEx(playerid));
			NearByMessage(playerid, NICESKY, string);
		}
	}
	return 1;
}

CMD:editgasmask(playerid, params[])
{	
	if(Player[playerid][WearingGasMask] == 0)
		return SendClientMessage(playerid, WHITE, "You aren't wearing a gas mask!");
		
	SetPVarInt(playerid, "EditingGasMask", 1);
	EditAttachedObject(playerid, Player[playerid][WearingGasMask] - 1);
	SendClientMessage(playerid, WHITE, "You are now editing your gas mask.");
	return 1;
}

CMD:viruscheck(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 8)
		return 1;
	
	new id, amount = 0;
	if(sscanf(params, "u", id))
	{
		foreach(Player, i)
		{
			if(Player[i][Infected] == 1)
				amount++;
		}
		SendClientMessage(playerid, GREY, "SYNTAX: /viruscheck [playerid]");
		format(string, sizeof(string), "Total infected online: %d", amount);
		SendClientMessage(playerid, GREY, string);
		return 1;
	}
	if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, -1, "That player isn't connected.");
	
	format(string, sizeof(string), "Infected: %d | Virus Count: %d", Player[id][Infected], Player[id][VirusCount]);
	SendClientMessage(playerid, WHITE, string);
	return 1;
}
hook OnPlayerEditAttachedObject(playerid, response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ)
{
	if(GetPVarInt(playerid, "EditingGasMask") == 1)
	{
		if(response)
		{
			Player[playerid][GasMaskOffsets][0] = fOffsetX;
			Player[playerid][GasMaskOffsets][1] = fOffsetY;
			Player[playerid][GasMaskOffsets][2] = fOffsetZ;
			Player[playerid][GasMaskOffsets][3] = fRotX;
			Player[playerid][GasMaskOffsets][4] = fRotY;
			Player[playerid][GasMaskOffsets][5] = fRotZ;
			Player[playerid][GasMaskOffsets][6] = fScaleX;
			Player[playerid][GasMaskOffsets][7] = fScaleY;
			Player[playerid][GasMaskOffsets][8] = fScaleZ;
			DeletePVar(playerid, "EditingGasMask");
			SendClientMessage(playerid, WHITE, "You have edited your gas mask.");
		}
	}
	return 1;
}

CMD:setinfected(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 8)
		return 1;
		
	new id, infected;
	if(sscanf(params, "ud", id, infected))
		return SendClientMessage(playerid, WHITE, "SYNTAX: /setinfected [playerid] [0 or 1]");
	
	if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, -1, "That player isn't connected.");
		
	if(infected != 0 && infected != 1)
		return SendClientMessage(playerid, -1, "Infected must be 0 or 1.");
		
	Player[id][Infected] = infected;
	format(string, sizeof(string), "You have set %s's infected to %d.", GetName(id), infected);
	SendClientMessage(playerid, WHITE, string);
	return 1;
}

CMD:setviruscount(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 8)
		return 1;
		
	new id, count;
	if(sscanf(params, "ud", id, count))
		return SendClientMessage(playerid, WHITE, "SYNTAX: /setviruscount [playerid] [count]");
	
	if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, -1, "That player isn't connected.");
		
	if(count < 0)
		return SendClientMessage(playerid, -1, "Virus count cant be negative.");
		
	Player[id][VirusCount] = count;
	format(string, sizeof(string), "You have set %s's virus count to %d.", GetName(id), count);
	SendClientMessage(playerid, WHITE, string);
	return 1;
}

// ============= Functions =============

stock SetBlackoutTDTransparency(playerid)
{
	PlayerTextDrawHide(playerid, BlackoutTD[playerid]);
	switch(Player[playerid][BlackoutCount])
	{
		case 0: PlayerTextDrawBoxColor(playerid, BlackoutTD[playerid],  0x00000000);
		case 1: PlayerTextDrawBoxColor(playerid, BlackoutTD[playerid],  0x00000010);
		case 2: PlayerTextDrawBoxColor(playerid, BlackoutTD[playerid],  0x00000020);
		case 3: PlayerTextDrawBoxColor(playerid, BlackoutTD[playerid],  0x00000030);
		case 4: PlayerTextDrawBoxColor(playerid, BlackoutTD[playerid],  0x00000040);
		case 5: PlayerTextDrawBoxColor(playerid, BlackoutTD[playerid],  0x00000050);
		case 6: PlayerTextDrawBoxColor(playerid, BlackoutTD[playerid],  0x00000060);
		case 7: PlayerTextDrawBoxColor(playerid, BlackoutTD[playerid],  0x00000070);
		case 8: PlayerTextDrawBoxColor(playerid, BlackoutTD[playerid],  0x00000080);
		case 9: PlayerTextDrawBoxColor(playerid, BlackoutTD[playerid],  0x000000BB);
		case 10: PlayerTextDrawBoxColor(playerid, BlackoutTD[playerid],  0x000000FF);
	}
	PlayerTextDrawShow(playerid, BlackoutTD[playerid]);
	return 1;
}

stock InfectNearbyPlayers(playerid)
{
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	foreach(Player, i)
	{
		if(GetPlayerDistanceFromPoint(i, x, y, z) <= 10)
		{
			if(Player[i][WearingGasMask] == 0)
			{
				switch(random(100))
				{
					case 0..19:
					{
						if(Player[i][Infected] == 0)
							Player[i][Infected] = 1;
						else Player[i][VirusCount] += 100;
					}
				}
			}
			else 
			{
				switch(random(100))
				{
					case 0: 
					{
						if(Player[i][Infected] == 0)
							Player[i][Infected] = 1;
						else Player[i][VirusCount] += 100;
					}
				}
			}
		}
	}
	return 1;
}

stock MixUpSentence(string1[], vCount, size = sizeof(string1))
{
	if(isnull(string1))
		format(string1, size, "empty");
	
	new newstring[128];
	format(newstring, sizeof(newstring), "%s", string1);
	
	new moved, word[128], moving, rand;
	
	rand = vCount / 1000;
	if(rand > PLAGUE_SPEECH_MAX_CHANCE)
		rand = PLAGUE_SPEECH_MAX_CHANCE;
	
	for(new i = 0; newstring[i] != '\0'; i++)
	{
		if(newstring[i] == ' ')
		{
			if(moving == 0)
			{
				if(random(100) < rand && moved < MAX_WORDS_MOVED)
				{
					new next = NextSpace(newstring, i + 1);
					if(next == -1)
						break;
						
					strmid(word, newstring, i, next);
					strdel(newstring, i, next);
					moving = 1;
				}
			}
			else
			{
				strins(newstring, word, i, size);
				moving = 0;
				word[0] = EOS;
				moved++;
			}
		}
	}
	return newstring;
}

stock NextSpace(string1[], idx)
{
	new next = -1;
	for(new i = idx; string1[i] != '\0'; i++)
	{
		if(string1[i] == ' ')
		{
			next = i;
			break;
		}
	}
	return next;
}