/*
#		MTG Hotwire
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

#define MAX_HOTWIRE_TD	16
#define MAX_HOTWIRE_PTD	9

#define HOTWIRE_TIME_LEFT		0
#define HOTWIRE_NUM_COMPLETE	1
#define HOTWIRE_SEQ_1			2
#define HOTWIRE_SEQ_2			3
#define HOTWIRE_SEQ_3			4
#define HOTWIRE_CHOICE_1		5
#define HOTWIRE_CHOICE_2		6
#define HOTWIRE_CHOICE_3		7
#define HOTWIRE_CHOICE_4		8

#define HOTWIRE_DEFAULT_TIME	6
#define HOTWIRE_DEFAULT_PUZZLES	5

new Text:HotwireTD[MAX_HOTWIRE_TD];
new PlayerText:PlayerTDs[MAX_PLAYERS][MAX_HOTWIRE_PTD], Timer:HotwireTimer[MAX_PLAYERS];

stock HideHotwireTextdraws(playerid)
{
	for(new td; td < MAX_HOTWIRE_TD; td++)
		TextDrawHideForPlayer(playerid, HotwireTD[td]);
	for(new td; td < MAX_HOTWIRE_PTD; td++)
		PlayerTextDrawHide(playerid, PlayerTDs[playerid][td]);
}

static PuzzleSequences[][][128] = 
{
	{"LD_BEAT:up", "LD_BEAT:down", "LD_BEAT:right", "LD_BEAT:left"},
	{"LD_BEAT:down", "LD_BEAT:up", "LD_BEAT:down", "LD_BEAT:up"},
	{"LD_BEAT:up", "LD_BEAT:down", "LD_BEAT:up", "LD_BEAT:down"},
	{"LD_BEAT:left", "LD_BEAT:right", "LD_BEAT:left", "LD_BEAT:right"},
	{"LD_BEAT:right", "LD_BEAT:left", "LD_BEAT:right", "LD_BEAT:left"},
	{"LD_BEAT:up", "LD_BEAT:right", "LD_BEAT:up", "LD_BEAT:right"},
	{"LD_BEAT:up", "LD_BEAT:left", "LD_BEAT:up", "LD_BEAT:left"},
	{"LD_BEAT:down", "LD_BEAT:right", "LD_BEAT:down", "LD_BEAT:right"},
	{"LD_BEAT:down", "LD_BEAT:left", "LD_BEAT:down", "LD_BEAT:left"},
	{"LD_BEAT:down", "LD_BEAT:up", "LD_BEAT:right", "LD_BEAT:left"},
	{"LD_BEAT:up", "LD_BEAT:up", "LD_BEAT:right", "LD_BEAT:right"},
	{"LD_BEAT:down", "LD_BEAT:down", "LD_BEAT:left", "LD_BEAT:left"},
	{"LD_BEAT:up", "LD_BEAT:upr", "LD_BEAT:right", "LD_BEAT:downr"},
	{"LD_BEAT:downr", "LD_BEAT:down", "LD_BEAT:downl", "LD_BEAT:left"},
	{"LD_BEAT:downr", "LD_BEAT:downl", "LD_BEAT:upl", "LD_BEAT:upr"},
	{"LD_BEAT:upl", "LD_BEAT:upr", "LD_BEAT:downr", "LD_BEAT:downl"},
	{"LD_BEAT:upl", "LD_BEAT:upl", "LD_BEAT:upr", "LD_BEAT:upr"},
	{"LD_BEAT:upr", "LD_BEAT:upr", "LD_BEAT:upl", "LD_BEAT:upl"},
	{"LD_BEAT:upl", "LD_BEAT:upl", "LD_BEAT:downl", "LD_BEAT:downl"},
	{"LD_BEAT:upr", "LD_BEAT:upr", "LD_BEAT:downr", "LD_BEAT:downr"}
};

CMD:hotwire(playerid, params[])
{
	if(GetPVarInt(playerid, "hotwireCD") > gettime())
		return SendClientMessage(playerid, -1, "You can't do that right now");

	if(!IsPlayerInAnyVehicle(playerid))
		return SendClientMessage(playerid, -1, "You're not in a vehicle");

	if(Player[playerid][Tied] >= 1 || Player[playerid][Cuffed] >= 1 || Player[playerid][Tazed] == 1 || Player[playerid][AdminFrozen] == 1)
	    return SendClientMessage(playerid, -1, "You can't do this as you're cuffed, tazed or tied!");

	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
		return SendClientMessage(playerid, -1, "You must be the driver of a vehicle to use this command");

	new sql = GetNearestCarSQL(playerid), idx = GetVIndex(sql);

	if(sql == 0)
		return SendClientMessage(playerid, -1, "That vehicle isn't saved in the database");
	
	if(IsABike(Veh[idx][Link]))
		return SendClientMessage(playerid, -1, "You can't hotwire a bike!"); 
	
	new engine, lights, alarm, doors, boot ,bonnet, objective;
	GetVehicleParamsEx(Veh[idx][Link], engine, lights, alarm, doors, boot ,bonnet, objective);

	if(Veh[idx][Fuel] < 1 && Player[playerid][AdminDuty] == 0)
		return SendClientMessage(playerid, -1, "The vehicle has no fuel!");

	if(Veh[idx][damageState] == 1)
		return SendClientMessage(playerid, -1, "The vehicle requires a fix before it can be started");

	if(engine == 1)
		return SendClientMessage(playerid, -1, "No point in hotwiring a started vehicle");
	
	if(sql != 0 && Groups[Veh[idx][Group]][CommandTypes] == 8 && (Player[playerid][DoingDMVTest] > 0 || Player[playerid][DoingTruckerTest] > 0))
		StartTest(playerid);
	
	if(_:Player[playerid][TruckLoadTimer] > -1 || _:Player[playerid][TruckUnloadTimer] > -1)
		return SendClientMessage(playerid, -1, "Don't even think about cheating, mate.");
	
	if(GetPVarInt(playerid, "HOTWIRE_COOLDOWN") > gettime())
		return SendClientMessage(playerid, WHITE, "You can't do this right now!");
	
	PlayerTextDrawSetString(playerid, PlayerTDs[playerid][HOTWIRE_TIME_LEFT], IntToFormattedStr(HOTWIRE_DEFAULT_TIME));
	PlayerTextDrawSetString(playerid, PlayerTDs[playerid][HOTWIRE_NUM_COMPLETE], "0/5");
	SetupRandomPuzzle(playerid);
	
	for(new i; i < MAX_HOTWIRE_TD; i++)
		TextDrawShowForPlayer(playerid, HotwireTD[i]);
	for(new i; i < MAX_HOTWIRE_PTD	; i++)
		PlayerTextDrawShow(playerid, PlayerTDs[playerid][i]);
	
	SelectTextDraw(playerid, 0x21DD00FF);
	Player[playerid][HotwireTimeLeft] = HOTWIRE_DEFAULT_TIME + (Player[playerid][CarJackerXP] / 30);
	HotwireTimer[playerid] = repeat HotwirePlayerTimer(playerid);
	return 1;
}

timer HotwirePlayerTimer[1000](playerid)
{
	Player[playerid][HotwireTimeLeft] --;
	if(Player[playerid][HotwireTimeLeft] == 0)
	{
		new engine, lights, alarm, doors, bonnet, boot, objective, string[128], vehicle = GetPlayerVehicleID(playerid);
		GetVehicleParamsEx(vehicle, engine, lights, alarm, doors, bonnet, boot, objective);
		
		SetVehicleParamsEx(vehicle, engine, 1, 1, doors, boot, bonnet, objective);
		SetPVarInt(playerid, "VehicleAlarm", vehicle);
		SetPVarInt(playerid, "VehicleAlarmTime", gettime() + 15);
		
		new Float:hp;
		GetPlayerHealth(playerid, hp);
		SetPlayerHealth(playerid, hp - 1);
		
		format(string, sizeof(string), "* %s fails to hotwire the vehicle and causes the alarm to go off.", GetNameEx(playerid));
		NearByMessage(playerid, NICESKY, string);
		
		stop HotwireTimer[playerid];
		
		HideHotwireTextdraws(playerid);
		SetPVarInt(playerid, "HOTWIRE_COOLDOWN", gettime() + 15);
		Player[playerid][HotwirePuzzlesSolved] = 0;
		Player[playerid][HotwireAnsLoc] = PlayerText:0;
		CancelSelectTextDraw(playerid);
	}
	else 
	{
		PlayerTextDrawSetString(playerid, PlayerTDs[playerid][HOTWIRE_TIME_LEFT], IntToFormattedStr(Player[playerid][HotwireTimeLeft]));
	}
	return 1;	
}

stock SetupRandomPuzzle(playerid)
{
	new randSeq = random(sizeof(PuzzleSequences)), randAnsLoc = 5 + random(3), string[32];
	Player[playerid][HotwireAnsLoc] = PlayerTDs[playerid][randAnsLoc];
	PlayerTextDrawSetString(playerid, PlayerTDs[playerid][HOTWIRE_SEQ_1], PuzzleSequences[randSeq][0]);
	PlayerTextDrawSetString(playerid, PlayerTDs[playerid][HOTWIRE_SEQ_2], PuzzleSequences[randSeq][1]);
	PlayerTextDrawSetString(playerid, PlayerTDs[playerid][HOTWIRE_SEQ_3], PuzzleSequences[randSeq][2]);
	
	new count;
	while(count < 4)
	{
		format(string, sizeof(string), GetRandomTextdraw());
		if(strcmp(PuzzleSequences[randSeq][3], string, true))
		{
			PlayerTextDrawSetString(playerid, PlayerTDs[playerid][5 + count], string);
			count ++;
		}
	}

	PlayerTextDrawSetString(playerid, PlayerTDs[playerid][randAnsLoc], PuzzleSequences[randSeq][3]);
	return 1;
}

stock GetRandomTextdraw()
{
	new text[32];
	switch(random(123))
	{
		case 0: text = "LD_BEAT:up";
		case 1:	text = "LD_BEAT:down";
		case 2: text = "LD_BEAT:right";
		case 3: text = "LD_BEAT:left";
		case 4: text = "LD_BEAT:upr";
		case 5: text = "LD_BEAT:upl";
		case 6: text = "LD_BEAT:downr";
		case 7: text = "LD_BEAT:downl";
	}
	return text;
}

hook OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(Player[playerid][HotwireTimeLeft] > 0)
	{
		new string[128];
		if(playertextid == Player[playerid][HotwireAnsLoc])
		{
			Player[playerid][HotwirePuzzlesSolved] ++;
			
			if(Player[playerid][HotwirePuzzlesSolved] < HOTWIRE_DEFAULT_PUZZLES)
			{
				PlayerTextDrawSetString(playerid, PlayerTDs[playerid][HOTWIRE_TIME_LEFT], "5");
				format(string, sizeof(string), "%d/%d", Player[playerid][HotwirePuzzlesSolved], HOTWIRE_DEFAULT_PUZZLES);
				PlayerTextDrawSetString(playerid, PlayerTDs[playerid][HOTWIRE_NUM_COMPLETE], string);
				SetupRandomPuzzle(playerid);
				string[0] = EOS;
				Player[playerid][HotwireTimeLeft] = HOTWIRE_DEFAULT_TIME + (Player[playerid][CarJackerXP] / 30);
				
				switch(Player[playerid][HotwirePuzzlesSolved])
				{
					case 1: format(string, sizeof(string), "* %s opens the compartment underneath the steering wheel.", GetNameEx(playerid));
					case 2: format(string, sizeof(string), "* %s pulls out a group of wires and examines them.", GetNameEx(playerid));
					case 3: format(string, sizeof(string), "* %s picks out two wires and cuts them, exposing the copper wire.", GetNameEx(playerid));
					case 4: format(string, sizeof(string), "* %s brings the two copper wires together allowing them to touch.", GetNameEx(playerid));
				}
				if(!isnull(string))
					SetPlayerChatBubble(playerid, string, NICESKY, 20, 7000);
			}
			else
			{
				new engine, lights, alarm, doors, bonnet, boot, objective, vehicle = GetPlayerVehicleID(playerid);
				GetVehicleParamsEx(vehicle, engine, lights, alarm, doors, bonnet, boot, objective);
				
				stop HotwireTimer[playerid];
				
				Player[playerid][HotwireTimeLeft] = 0;
				for(new i; i < MAX_HOTWIRE_TD; i++)
					TextDrawHideForPlayer(playerid, HotwireTD[i]);
				for(new i; i < MAX_HOTWIRE_PTD	; i++)
					PlayerTextDrawHide(playerid, PlayerTDs[playerid][i]);
				SetPVarInt(playerid, "HOTWIRE_COOLDOWN", gettime() + 15);
				Player[playerid][HotwirePuzzlesSolved] = 0;
				Player[playerid][HotwireAnsLoc] = PlayerText:0;
				CancelSelectTextDraw(playerid);
				format(string, sizeof(string), "* %s successfully tweaks with the vehicles wires and the engine starts.", GetNameEx(playerid));
				NearByMessage(playerid, NICESKY, string);
				SetVehicleParamsEx(vehicle, 1, 1, alarm, doors, boot, bonnet, objective);
			}
			return 1;
		}
		else
		{
			new engine, lights, alarm, doors, bonnet, boot, objective, vehicle = GetPlayerVehicleID(playerid);
			GetVehicleParamsEx(vehicle, engine, lights, alarm, doors, bonnet, boot, objective);
			
			SetVehicleParamsEx(vehicle, engine, 1, 1, doors, boot, bonnet, objective);
			SetPVarInt(playerid, "VehicleAlarm", vehicle);
			SetPVarInt(playerid, "VehicleAlarmTime", gettime() + 15);
			
			new Float:hp;
			GetPlayerHealth(playerid, hp);
			SetPlayerHealth(playerid, hp - 1);
			
			format(string, sizeof(string), "* %s fails to hotwire the vehicle and causes the alarm to go off.", GetNameEx(playerid));
			NearByMessage(playerid, NICESKY, string);
			
			stop HotwireTimer[playerid];
			Player[playerid][HotwireTimeLeft] = 0;
			
			for(new i; i < MAX_HOTWIRE_TD; i++)
				TextDrawHideForPlayer(playerid, HotwireTD[i]);
			for(new i; i < MAX_HOTWIRE_PTD	; i++)
				PlayerTextDrawHide(playerid, PlayerTDs[playerid][i]);
			SetPVarInt(playerid, "HOTWIRE_COOLDOWN", gettime() + 15);
			CancelSelectTextDraw(playerid);
			Player[playerid][HotwirePuzzlesSolved] = 0;
			Player[playerid][HotwireAnsLoc] = PlayerText:0;
			return 1;
		}
	}
	return 0;
}

hook OnPlayerConnect(playerid)
{
	PlayerTDs[playerid][HOTWIRE_TIME_LEFT] = CreatePlayerTextDraw(playerid, 212.000015, 185.836975, IntToFormattedStr(HOTWIRE_DEFAULT_TIME));
	PlayerTextDrawLetterSize(playerid, PlayerTDs[playerid][HOTWIRE_TIME_LEFT], 0.659331, 3.922964);
	PlayerTextDrawAlignment(playerid, PlayerTDs[playerid][HOTWIRE_TIME_LEFT], 1);
	PlayerTextDrawColor(playerid, PlayerTDs[playerid][HOTWIRE_TIME_LEFT], 8388863);
	PlayerTextDrawSetShadow(playerid, PlayerTDs[playerid][HOTWIRE_TIME_LEFT], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTDs[playerid][HOTWIRE_TIME_LEFT], 0);
	PlayerTextDrawBackgroundColor(playerid, PlayerTDs[playerid][HOTWIRE_TIME_LEFT], 51);
	PlayerTextDrawFont(playerid, PlayerTDs[playerid][HOTWIRE_TIME_LEFT], 1);
	PlayerTextDrawSetProportional(playerid, PlayerTDs[playerid][HOTWIRE_TIME_LEFT], 1);

	PlayerTDs[playerid][HOTWIRE_NUM_COMPLETE] = CreatePlayerTextDraw(playerid, 419.666748, 188.325958, "1/5");
	PlayerTextDrawLetterSize(playerid, PlayerTDs[playerid][HOTWIRE_NUM_COMPLETE], 0.613331, 2.906666);
	PlayerTextDrawAlignment(playerid, PlayerTDs[playerid][HOTWIRE_NUM_COMPLETE], 1);
	PlayerTextDrawColor(playerid, PlayerTDs[playerid][HOTWIRE_NUM_COMPLETE], -16776961);
	PlayerTextDrawSetShadow(playerid, PlayerTDs[playerid][HOTWIRE_NUM_COMPLETE], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTDs[playerid][HOTWIRE_NUM_COMPLETE], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTDs[playerid][HOTWIRE_NUM_COMPLETE], 51);
	PlayerTextDrawFont(playerid, PlayerTDs[playerid][HOTWIRE_NUM_COMPLETE], 1);
	PlayerTextDrawSetProportional(playerid, PlayerTDs[playerid][HOTWIRE_NUM_COMPLETE], 1);

	PlayerTDs[playerid][HOTWIRE_SEQ_1] = CreatePlayerTextDraw(playerid, 250.00000, 243.50000, "LD_BEAT:up");
	PlayerTextDrawLetterSize(playerid, PlayerTDs[playerid][HOTWIRE_SEQ_1], -0.042998, -0.663703);
	PlayerTextDrawTextSize(playerid, PlayerTDs[playerid][HOTWIRE_SEQ_1], 25, 25);
	PlayerTextDrawAlignment(playerid, PlayerTDs[playerid][HOTWIRE_SEQ_1], 1);
	PlayerTextDrawColor(playerid, PlayerTDs[playerid][HOTWIRE_SEQ_1], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTDs[playerid][HOTWIRE_SEQ_1], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTDs[playerid][HOTWIRE_SEQ_1], 0);
	PlayerTextDrawFont(playerid, PlayerTDs[playerid][HOTWIRE_SEQ_1], 4);

	PlayerTDs[playerid][HOTWIRE_SEQ_2] = CreatePlayerTextDraw(playerid, 290.000, 243.50000, "LD_BEAT:upr");
	PlayerTextDrawLetterSize(playerid, PlayerTDs[playerid][HOTWIRE_SEQ_2], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PlayerTDs[playerid][HOTWIRE_SEQ_2], 25, 25);
	PlayerTextDrawAlignment(playerid, PlayerTDs[playerid][HOTWIRE_SEQ_2], 1);
	PlayerTextDrawColor(playerid, PlayerTDs[playerid][HOTWIRE_SEQ_2], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTDs[playerid][HOTWIRE_SEQ_2], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTDs[playerid][HOTWIRE_SEQ_2], 0);
	PlayerTextDrawFont(playerid, PlayerTDs[playerid][HOTWIRE_SEQ_2], 4);

	PlayerTDs[playerid][HOTWIRE_SEQ_3] = CreatePlayerTextDraw(playerid, 330.0000, 243.50000, "LD_BEAT:right");
	PlayerTextDrawLetterSize(playerid, PlayerTDs[playerid][HOTWIRE_SEQ_3], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PlayerTDs[playerid][HOTWIRE_SEQ_3], 25, 25);
	PlayerTextDrawAlignment(playerid, PlayerTDs[playerid][HOTWIRE_SEQ_3], 1);
	PlayerTextDrawColor(playerid, PlayerTDs[playerid][HOTWIRE_SEQ_3], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTDs[playerid][HOTWIRE_SEQ_3], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTDs[playerid][HOTWIRE_SEQ_3], 0);
	PlayerTextDrawFont(playerid, PlayerTDs[playerid][HOTWIRE_SEQ_3], 4);
	
	PlayerTDs[playerid][HOTWIRE_CHOICE_1] = CreatePlayerTextDraw(playerid, 250.000000, 315.00000, "LD_BEAT:downr");
	PlayerTextDrawLetterSize(playerid, PlayerTDs[playerid][HOTWIRE_CHOICE_1],  0.500, 1.20);
	PlayerTextDrawTextSize(playerid, PlayerTDs[playerid][HOTWIRE_CHOICE_1], 25, 25);
	PlayerTextDrawColor(playerid, PlayerTDs[playerid][HOTWIRE_CHOICE_1], -1);
	PlayerTextDrawFont(playerid, PlayerTDs[playerid][HOTWIRE_CHOICE_1], 4);
	PlayerTextDrawSetSelectable(playerid, PlayerTDs[playerid][HOTWIRE_CHOICE_1], 1);

	PlayerTDs[playerid][HOTWIRE_CHOICE_2] = CreatePlayerTextDraw(playerid, 290.000000, 315.00000, "LD_BEAT:left");
	PlayerTextDrawLetterSize(playerid, PlayerTDs[playerid][HOTWIRE_CHOICE_2],  0.500, 1.20);
	PlayerTextDrawTextSize(playerid, PlayerTDs[playerid][HOTWIRE_CHOICE_2], 25, 25);
	PlayerTextDrawColor(playerid, PlayerTDs[playerid][HOTWIRE_CHOICE_2], -1);
	PlayerTextDrawFont(playerid, PlayerTDs[playerid][HOTWIRE_CHOICE_2], 4);
	PlayerTextDrawSetSelectable(playerid, PlayerTDs[playerid][HOTWIRE_CHOICE_2], 1);

	PlayerTDs[playerid][HOTWIRE_CHOICE_3] = CreatePlayerTextDraw(playerid, 330.00000, 315.00000, "LD_BEAT:right");
	PlayerTextDrawLetterSize(playerid, PlayerTDs[playerid][HOTWIRE_CHOICE_3],  0.5000, 1.20);
	PlayerTextDrawTextSize(playerid, PlayerTDs[playerid][HOTWIRE_CHOICE_3], 25, 25);
	PlayerTextDrawColor(playerid, PlayerTDs[playerid][HOTWIRE_CHOICE_3], -1);
	PlayerTextDrawFont(playerid, PlayerTDs[playerid][HOTWIRE_CHOICE_3], 4);
	PlayerTextDrawSetSelectable(playerid, PlayerTDs[playerid][HOTWIRE_CHOICE_3], 1);

	PlayerTDs[playerid][HOTWIRE_CHOICE_4] = CreatePlayerTextDraw(playerid, 370.000000, 315.00000, "LD_BEAT:upr");
	PlayerTextDrawLetterSize(playerid, PlayerTDs[playerid][HOTWIRE_CHOICE_4], 0.500, 1.20);
	PlayerTextDrawTextSize(playerid, PlayerTDs[playerid][HOTWIRE_CHOICE_4], 25, 25);
	PlayerTextDrawColor(playerid, PlayerTDs[playerid][HOTWIRE_CHOICE_4], -1);
	PlayerTextDrawFont(playerid, PlayerTDs[playerid][HOTWIRE_CHOICE_4], 4);
	PlayerTextDrawSetSelectable(playerid, PlayerTDs[playerid][HOTWIRE_CHOICE_4], 1);
	
	return 1;
}

hook OnGameModeInit()
{
	HotwireTD[0] = TextDrawCreate(186.000122, 344.296386, "LD_BEAT:chit");
	TextDrawLetterSize(HotwireTD[0], -0.167666, -0.958221);
	TextDrawTextSize(HotwireTD[0], 23.229999, 23.229688);
	TextDrawAlignment(HotwireTD[0], 1);
	TextDrawColor(HotwireTD[0], 255);
	TextDrawSetShadow(HotwireTD[0], 0);
	TextDrawSetOutline(HotwireTD[0], 0);
	TextDrawBackgroundColor(HotwireTD[0], 255);
	TextDrawFont(HotwireTD[0], 4);

	HotwireTD[1] = TextDrawCreate(193.999954, 153.066650, "LD_SPAC:white");
	TextDrawLetterSize(HotwireTD[1], 0.000000, 0.000000);
	TextDrawTextSize(HotwireTD[1], 277.333343, 206.577758);
	TextDrawAlignment(HotwireTD[1], 1);
	TextDrawColor(HotwireTD[1], 255);
	TextDrawSetShadow(HotwireTD[1], 0);
	TextDrawSetOutline(HotwireTD[1], 0);
	TextDrawFont(HotwireTD[1], 4);

	HotwireTD[2] = TextDrawCreate(196.000045, 363.792510, "LD_SPAC:white");
	TextDrawLetterSize(HotwireTD[2], 0.000000, 0.000000);
	TextDrawTextSize(HotwireTD[2], 275.000061, -12.029641);
	TextDrawAlignment(HotwireTD[2], 1);
	TextDrawColor(HotwireTD[2], 255);
	TextDrawSetShadow(HotwireTD[2], 0);
	TextDrawSetOutline(HotwireTD[2], 0);
	TextDrawFont(HotwireTD[2], 4);

	HotwireTD[3] = TextDrawCreate(196.000015, 355.081573, "LD_SPAC:white");
	TextDrawLetterSize(HotwireTD[3], 0.000000, 0.000000);
	TextDrawTextSize(HotwireTD[3], -6.333323, -200.355712);
	TextDrawAlignment(HotwireTD[3], 1);
	TextDrawColor(HotwireTD[3], 255);
	TextDrawSetShadow(HotwireTD[3], 0);
	TextDrawSetOutline(HotwireTD[3], 0);
	TextDrawFont(HotwireTD[3], 4);

	HotwireTD[4] = TextDrawCreate(459.962860, 345.125885, "LD_BEAT:chit");
	TextDrawLetterSize(HotwireTD[4], 0.000000, 0.000000);
	TextDrawTextSize(HotwireTD[4], 18.228992, 21.985218);
	TextDrawAlignment(HotwireTD[4], 1);
	TextDrawColor(HotwireTD[4], 255);
	TextDrawSetShadow(HotwireTD[4], 0);
	TextDrawSetOutline(HotwireTD[4], 0);
	TextDrawFont(HotwireTD[4], 4);

	HotwireTD[5] = TextDrawCreate(475.333343, 153.481460, "LD_SPAC:white");
	TextDrawLetterSize(HotwireTD[5], 0.000000, 0.000000);
	TextDrawTextSize(HotwireTD[5], -7.333375, 203.259307);
	TextDrawAlignment(HotwireTD[5], 1);
	TextDrawColor(HotwireTD[5], 255);
	TextDrawSetShadow(HotwireTD[5], 0);
	TextDrawSetOutline(HotwireTD[5], 0);
	TextDrawFont(HotwireTD[5], 4);

	HotwireTD[6] = TextDrawCreate(186.333282, 143.525970, "LD_BEAT:chit");
	TextDrawLetterSize(HotwireTD[6], 0.000000, 0.000000);
	TextDrawTextSize(HotwireTD[6], 20.229003, 22.814815);
	TextDrawAlignment(HotwireTD[6], 1);
	TextDrawColor(HotwireTD[6], 255);
	TextDrawSetShadow(HotwireTD[6], 0);
	TextDrawSetOutline(HotwireTD[6], 0);
	TextDrawFont(HotwireTD[6], 4);

	HotwireTD[7] = TextDrawCreate(195.666671, 147.259262, "LD_SPAC:white");
	TextDrawLetterSize(HotwireTD[7], 0.000000, 0.000000);
	TextDrawTextSize(HotwireTD[7], 273.000122, 53.511108);
	TextDrawAlignment(HotwireTD[7], 1);
	TextDrawColor(HotwireTD[7], 255);
	TextDrawSetShadow(HotwireTD[7], 0);
	TextDrawSetOutline(HotwireTD[7], 0);
	TextDrawFont(HotwireTD[7], 4);

	HotwireTD[8] = TextDrawCreate(456.666809, 143.525894, "LD_BEAT:chit");
	TextDrawLetterSize(HotwireTD[8], 0.000000, 0.000000);
	TextDrawTextSize(HotwireTD[8], 22.333311, 22.400009);
	TextDrawAlignment(HotwireTD[8], 1);
	TextDrawColor(HotwireTD[8], 255);
	TextDrawSetShadow(HotwireTD[8], 0);
	TextDrawSetOutline(HotwireTD[8], 0);
	TextDrawFont(HotwireTD[8], 4);

	HotwireTD[9] = TextDrawCreate(233.333267, 153.896347, "hotwire challenge");
	TextDrawLetterSize(HotwireTD[9], 0.449999, 1.600000);
	TextDrawAlignment(HotwireTD[9], 1);
	TextDrawColor(HotwireTD[9], -1);
	TextDrawSetShadow(HotwireTD[9], 0);
	TextDrawSetOutline(HotwireTD[9], 1);
	TextDrawBackgroundColor(HotwireTD[9], 51);
	TextDrawFont(HotwireTD[9], 2);
	TextDrawSetProportional(HotwireTD[9], 1);

	HotwireTD[10] = TextDrawCreate(128.333328, 179.199905, "I");
	TextDrawLetterSize(HotwireTD[10], 32.000000, 0.400000);
	TextDrawTextSize(HotwireTD[10], 49.666656, 53.925918);
	TextDrawAlignment(HotwireTD[10], 1);
	TextDrawColor(HotwireTD[10], -1);
	TextDrawSetShadow(HotwireTD[10], 0);
	TextDrawSetOutline(HotwireTD[10], 0);
	TextDrawFont(HotwireTD[10], 1);

	HotwireTD[11] = TextDrawCreate(195.666656, 223.170333, "seconds left");
	TextDrawLetterSize(HotwireTD[11], 0.210998, 1.106369);
	TextDrawAlignment(HotwireTD[11], 1);
	TextDrawColor(HotwireTD[11], 8388863);
	TextDrawSetShadow(HotwireTD[11], 0);
	TextDrawSetOutline(HotwireTD[11], 1);
	TextDrawBackgroundColor(HotwireTD[11], 51);
	TextDrawFont(HotwireTD[11], 3);
	TextDrawSetProportional(HotwireTD[11], 1);

	HotwireTD[12] = TextDrawCreate(401.000000, 219.851882, "puzzles complete");
	TextDrawLetterSize(HotwireTD[12], 0.217999, 1.077332);
	TextDrawAlignment(HotwireTD[12], 1);
	TextDrawColor(HotwireTD[12], -16776961);
	TextDrawSetShadow(HotwireTD[12], 0);
	TextDrawSetOutline(HotwireTD[12], 1);
	TextDrawBackgroundColor(HotwireTD[12], 51);
	TextDrawFont(HotwireTD[12], 3);
	TextDrawSetProportional(HotwireTD[12], 1);

	HotwireTD[13] = TextDrawCreate(370.0000, 243.50000, "{");
	TextDrawLetterSize(HotwireTD[13], 0.858666, 3.877332);
	TextDrawAlignment(HotwireTD[13], 1);
	TextDrawColor(HotwireTD[13], -1);
	TextDrawSetShadow(HotwireTD[13], 0);
	TextDrawSetOutline(HotwireTD[13], 0);
	TextDrawBackgroundColor(HotwireTD[13], 51);
	TextDrawFont(HotwireTD[13], 1);
	TextDrawSetProportional(HotwireTD[13], 1);

	HotwireTD[14] = TextDrawCreate(265.333374, 222.340835, "What's next?");
	TextDrawLetterSize(HotwireTD[14], 0.497999, 1.857185);
	TextDrawAlignment(HotwireTD[14], 1);
	TextDrawColor(HotwireTD[14], -2139094785);
	TextDrawSetShadow(HotwireTD[14], 0);
	TextDrawSetOutline(HotwireTD[14], 1);
	TextDrawBackgroundColor(HotwireTD[14], 51);
	TextDrawFont(HotwireTD[14], 3);
	TextDrawSetProportional(HotwireTD[14], 1);

	HotwireTD[15] = TextDrawCreate(167.666641, 297.007415, "I");
	TextDrawLetterSize(HotwireTD[15], 25.000000, 0.300000);
	TextDrawAlignment(HotwireTD[15], 1);
	TextDrawColor(HotwireTD[15], -1);
	TextDrawSetShadow(HotwireTD[15], 0);
	TextDrawSetOutline(HotwireTD[15], 1);
	TextDrawBackgroundColor(HotwireTD[15], 51);
	TextDrawFont(HotwireTD[15], 1);
	TextDrawSetProportional(HotwireTD[15], 1);
	return 1;
}
