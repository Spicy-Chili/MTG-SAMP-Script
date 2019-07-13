/*
#		MTG Car Jacker
#		
#
#	By accessing this file, you agree to the following:
#		- You will never give the script or associated files to anybody who is not on the MTG SAMP development team
# 		- You will delete all development materials (script, databases, associated files, etc.) when you leave the MTG SAMP development team.
#
*/

#include <YSI\y_hooks>
#include <YSI\y_timers>

#define MAX_JACKERS				5
#define CAR_JACK_TIME_LIMIT		2700 //45 minutes to find the car
//60 seconds for testing purposes
#define CAR_JACK_TIMER			1800 //Look for car jackers every 30 minutes if nothing is active
#define CAR_JACK_CHECKPOINT		112233
#define CAR_JACK_MIN_HEALTH		950
#define CAR_JACK_SHIT_PAY		100
#define CAR_JACK_GOOD_PAY		1000

static CurrentCarID = INVALID_VEHICLE_ID, CarJackers[MAX_JACKERS] = {INVALID_PLAYER_ID, ...}, Timer:TimeLimitTimer, TimerCounter;
static string[255];
static Text:gTextDraws[3];
new DropCarStatus, CarJackStatus, Iterator:CarJackers<MAX_PLAYERS>;

static ColorNames[8][32] = 
{
	"Black", "White", "Sea Blue", "Red", "Green", "Pink", "Yellow", "Blue"
};

static Float:CarSpawns[][4] = 
{
	{437.419250, -1294.890014, 14.873908, 211.031112},
	{210.175384, -1420.988647, 12.965106, 133.967269},
	{564.779113, -1763.981933, 5.511161, 87.839698},
	{1664.430908, -2115.458984, 13.251757, 269.383331},
	{1747.636718, -2082.356933, 13.260695, 180.577636},
	{-258.548492, -2181.878417, 28.726518, 24.548704},
	{-118.211456, -229.545684, 1.127389, 359.044067},
	{93.211860, -190.973754, 1.189728, 179.912643},
	{1390.688476, 471.756713, 19.798223, 246.777038},
	{526.005065, -1382.679687, 15.748161, 14.973003},
	{1098.960449, -1328.474365, 12.994789, 1.441141},
	{1419.632446, -1351.783691, 13.269849, 359.965606},
	{1984.743652, -1275.016113, 23.525066, 0.530449},
	{768.197692, -1013.506958, 26.061267, 180.286331},
	{2104.845947, -1565.699584, 13.080395, 146.632690},
	{1747.596801, -1568.875122, 13.236689, 180.736221},
	{1261.091918, -2009.861816, 59.095119, 180.861877},
	{2802.740966, -1671.694946, 9.630113, 180.075576},
	{2779.871093, -2513.385498, 13.338971, 62.559738},
	{374.444488, -2036.609863, 7.453990, 180.791946},
	{2058.706298, -2152.370117, 13.380709, 88.782257},
	{2602.125732, -1063.983764, 69.330009, 3.090600},
	{2053.874511, -1106.074218, 24.154981, 270.142547},
	{700.403686, -1200.422851, 15.011377, 331.700897},
	{559.771301, -1358.059326, 14.912478, 101.018112},
	{973.172241, -1523.811523, 13.304323, 178.293457},
	{2174.306640, -115.278083, 2.981920, 71.938461},
	{1901.407836, 162.638427, 36.891864, 162.053085},
	{890.805297, -23.743972, 62.987266, 155.924240},
	{797.999694, -617.981689, 16.446876, 0.999774},
	{111.127128, -229.156997, 1.283407, 176.651824},
	{891.309631, -23.259151, 62.950569, 151.986022},
	{1288.336425, 204.729354, 19.599451, 147.397949},
	{2170.617675, -112.879936, 2.657015, 303.793518},
	{2363.050292, -653.006042, 127.615715, 275.336944},
	{1727.296386, -1007.679870, 23.635601, 165.978210},
	{-85.741218, -1585.216918, 2.318469, 245.598114},
	{-262.522430, -2192.414306, 28.609466, 114.791198},
	{1084.477294, -306.339904, 73.696937, 139.550949},
	{-43.570404, 110.311393, 2.818821, 344.971771},
	{-481.164276, -180.267852, 77.916114, 183.16221,},
	{-563.224792, -1040.098632, 23.746175, 237.851654},
	{1559.982177, -2319.000000, 13.151392, 91.999725},
	{2228.458984, -1169.800170, 25.320846, 91.851867},
	{2101.332275, -2064.643798, 13.131521, 182.863845},
	{591.134887, -1508.997192, 15.385898, 273.997985},
	{763.994445, -1015.002563, 23.850416, 180.000823},
	{1201.155029, -875.376342, 42.629192, 191.671188},
	{-1000.394775, -661.318603, 32.191806, 91.133399},
	{-1573.005981, -2729.008544, 48.156337, 143.999938}
};

task CarJackerTimer[CAR_JACK_TIMER * 1000]()
{
	if(CarJackStatus == 1)
		return 1;
		
	if(CurrentCarID != INVALID_VEHICLE_ID)
		return 1;
	
	new model = RandomCarModel(), city[32], color = RandomColor(), randomSpawn = random(sizeof(CarSpawns));
	format(city, sizeof(city), "%s", ReturnRandomCity());
	
	CurrentCarID = CreateVehicle(model, CarSpawns[randomSpawn][0], CarSpawns[randomSpawn][1], CarSpawns[randomSpawn][2], CarSpawns[randomSpawn][3], color, color, -1);
	TextDrawSetPreviewModel(gTextDraws[2], model);
	TextDrawSetPreviewVehCol(gTextDraws[2], color, color);

	switch(random(5))
	{
		case 0: format(string, sizeof(string), "SMS from Unknown: Hey I got this rich prick from %s, he really wants a %s %s.", city, ColorNames[color], vNames[model - 400]);
		case 1: format(string, sizeof(string), "SMS from Unknown: This guy from %s is really grinding my ass about finding a %s %s.", city, ColorNames[color], vNames[model - 400]);
		case 2: format(string, sizeof(string), "SMS from Unknown: Listen I need a %s %s or this big mobster from %s is gunna kill me.", ColorNames[color], vNames[model - 400], city);
		case 3: format(string, sizeof(string), "SMS from Unknown: Some guy from %s is willing to pay big bucks for a %s %s.", city, ColorNames[color], vNames[model - 400]);
		case 4: format(string, sizeof(string), "SMS from Unknown: My friend from %s really wants a %s %s.", city, ColorNames[color], vNames[model - 400]);
	}
	
	new MAX_CAR_JACKERS = 5;
	
	new totalPicked, PickedPlayers[5] , totalPoolSize = Iter_Count(CarJackers);
	
	for(new i; i < 5; i++)
		PickedPlayers[i] = INVALID_PLAYER_ID;
	
	if(totalPoolSize < MAX_CAR_JACKERS)
		MAX_CAR_JACKERS = totalPoolSize;
		
	if(totalPoolSize > 0)
	{
		while(totalPicked < MAX_CAR_JACKERS)
		{
			if(Iter_Count(CarJackers) < MAX_CAR_JACKERS)
				MAX_CAR_JACKERS = Iter_Count(CarJackers);
			
			if(totalPicked >= MAX_CAR_JACKERS)
				break;
			
			PickedPlayers[totalPicked] = Iter_Random(CarJackers);
			Iter_Remove(CarJackers, PickedPlayers[totalPicked]);
			totalPicked++;
		}
	}

	for(new i; i < sizeof(PickedPlayers); i++)
	{
		if(PickedPlayers[i] == INVALID_PLAYER_ID || !IsPlayerConnected(PickedPlayers[i]))
			continue;
		
		SetPVarInt(CarJackers[i], "CarJacker", 1);
		SendClientMessage(CarJackers[i], PHONE, string);
		SendClientMessage(CarJackers[i], PHONE, "SMS from Unknown: Find one for me, bring it to me undamaged, and I'll give you plenty of cash. I've attached a pic of one.");
		TextDrawToggle(CarJackers[i], 1);
		
		Iter_Add(CarJackers, PickedPlayers[i]);
	}
	
	TimeLimitTimer = repeat CarJackerTimeLimit();
	
	return 1;
}

timer CarJackerTimeLimit[1000]()
{
	TimerCounter++;
	if(TimerCounter >= CAR_JACK_TIME_LIMIT)
	{
		for(new i; i < MAX_JACKERS; i++)
		{
			if(GetPlayerVehicleID(CarJackers[i]) == CurrentCarID)
				return 1;
			
			if(IsPlayerConnected(CarJackers[i]) && GetPVarInt(CarJackers[i], "CarJacker") == 1)
			{
				DeletePVar(CarJackers[i], "CarJacker");
				TextDrawToggle(CarJackers[i], 0);
				SendClientMessage(CarJackers[i], PHONE, "SMS from Unknown: Don't bother looking for that car anymore, someone else brought me one.");
				CarJackers[i] = INVALID_PLAYER_ID;
				DestroyVehicle(CurrentCarID);
				CurrentCarID = INVALID_VEHICLE_ID;
				TimerCounter = 0;
			}
		}
		stop TimeLimitTimer;
	}
	return 1;
}

hook OnGameModeInit()
{
	gTextDraws[0] = TextDrawCreate(145.500000, 196.388885, "usebox");
	TextDrawLetterSize(gTextDraws[0], 0.000000, 10.677160);
	TextDrawTextSize(gTextDraws[0], 33.000000, 0.000000);
	TextDrawAlignment(gTextDraws[0], 1);
	TextDrawColor(gTextDraws[0], -2139062017);
	TextDrawUseBox(gTextDraws[0], true);
	TextDrawBoxColor(gTextDraws[0], -1);
	TextDrawSetShadow(gTextDraws[0], 0);
	TextDrawSetOutline(gTextDraws[0], 0);
	TextDrawFont(gTextDraws[0], 0);

	gTextDraws[1] = TextDrawCreate(108.500000, 275.155593, "Dismiss");
	TextDrawLetterSize(gTextDraws[1], 0.214500, 0.996443);
	TextDrawTextSize(gTextDraws[1], 135.000000, -8.711112);
	TextDrawAlignment(gTextDraws[1], 1);
	TextDrawColor(gTextDraws[1], -16776961);
	TextDrawUseBox(gTextDraws[1], true);
	TextDrawBoxColor(gTextDraws[1], 0xCECECEFF);
	TextDrawSetShadow(gTextDraws[1], 0);
	TextDrawSetOutline(gTextDraws[1], 1);
	TextDrawBackgroundColor(gTextDraws[1], 51);
	TextDrawFont(gTextDraws[1], 1);
	TextDrawSetProportional(gTextDraws[1], 1);
	TextDrawSetSelectable(gTextDraws[1], true);
	
	gTextDraws[2] = TextDrawCreate(39.000000, 200.000000, "New Textdraw");
	TextDrawBackgroundColor(gTextDraws[2], 255);
	TextDrawFont(gTextDraws[2], 5);
	TextDrawLetterSize(gTextDraws[2], 0.500000, 1.000000);
	TextDrawColor(gTextDraws[2], -1);
	TextDrawSetOutline(gTextDraws[2], 0);
	TextDrawSetProportional(gTextDraws[2], 1);
	TextDrawSetShadow(gTextDraws[2], 1);
	TextDrawUseBox(gTextDraws[2], 1);
	TextDrawBoxColor(gTextDraws[2], -1);
	TextDrawTextSize(gTextDraws[2], 100.000000, 90.000000);
	TextDrawSetPreviewModel(gTextDraws[2], 411);
	TextDrawSetPreviewRot(gTextDraws[2], -16.000000, 0.000000, -55.000000, 1.000000);
	TextDrawSetSelectable(gTextDraws[2], 0);

	return 1;
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if(vehicleid == CurrentCarID)
	{
		if(GetPVarInt(playerid, "CarJacker") == 0)
			return ClearAnimations(playerid);
	
	}
	return 1;
}	

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER && oldstate == PLAYER_STATE_ONFOOT)
	{
		if(GetPlayerVehicleID(playerid) == CurrentCarID)
		{			
			SendClientMessage(playerid, PHONE, "SMS from Unknown: Hey you found the car I need! Take it to the docks and we will ship it outta here. ((/delivercar))");
		}
	}
	return 1;
}

hook  OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == gTextDraws[1])
	{
		TextDrawToggle(playerid, 0);
	}
	return 1;
}

hook OnPlayerEnterCheckpoint(playerid)
{
	if(Player[playerid][Checkpoint] == CAR_JACK_CHECKPOINT && GetPVarInt(playerid, "CarJacker") == 1)
	{
		new vID = GetPlayerVehicleID(playerid);
		if(vID != CurrentCarID)
			return SendClientMessage(playerid, PHONE, "SMS from Unknown: That ain't the car I'm looking for, get it outta here you idiot.");
			
		new Float:vehHealth;
		GetVehicleHealth(vID, vehHealth);
		
		if(vehHealth < CAR_JACK_MIN_HEALTH)
		{
			Player[playerid][Money] += CAR_JACK_SHIT_PAY;
			SendClientMessage(playerid, PHONE, "SMS from Unknown: Way to bring the car to me beat to shit! I'm barely going to make a profit after I fix it!!");
		}
		else
		{
			Player[playerid][Money] += CAR_JACK_GOOD_PAY;
			Player[playerid][CarJackerXP] ++;
			SendClientMessage(playerid, PHONE, "SMS from Unknown: I'm going to make a boat load of cash off this! Thanks for bringing it to me in good condition.");
		}
		DisablePlayerCheckpoint(playerid);
		SavePlayerData(playerid);
		DestroyVehicle(CurrentCarID);
		CurrentCarID = INVALID_VEHICLE_ID;
		TimerCounter = 0;
		
		
		for(new i; i < MAX_JACKERS; i++)
		{			
			if(IsPlayerConnected(CarJackers[i]) && GetPVarInt(CarJackers[i], "CarJacker") == 1 && CarJackers[i] != playerid)
				SendClientMessage(CarJackers[i], PHONE, "SMS from Unknown: Don't bother looking for that car anymore, someone else brought it to me.");
			
			DeletePVar(CarJackers[i], "CarJacker");
			TextDrawToggle(CarJackers[i], 0);
			CarJackers[i] = INVALID_PLAYER_ID;
		}
		
		stop TimeLimitTimer;
	}
	return 1;
}

CMD:delivercar(playerid, params[])
{
	if(GetPVarInt(playerid, "CarJacker") == 0 || (Jobs[Player[playerid][Job]][JobType] != JOB_CARJACKER && Jobs[Player[playerid][Job2]][JobType] != JOB_CARJACKER))
		return SendClientMessage(playerid, WHITE, "You can't do this.");
		
	new carID = GetPlayerVehicleID(playerid);
	if(carID != CurrentCarID)
		return SendClientMessage(playerid, WHITE, "This isn't the car you need to deliver!");
	
	new jobID = -1;
	if(Jobs[Player[playerid][Job]][JobType] == JOB_CARJACKER)
		jobID = Player[playerid][Job];
	else if(Jobs[Player[playerid][Job2]][JobType] == JOB_CARJACKER)
		jobID = Player[playerid][Job2];
	
	if(Player[playerid][Checkpoint] != 0)
		return SendClientMessage(playerid, WHITE, "You already have an active checkpoint, use /kc first.");
	
	if(jobID == -1)
		return SendClientMessage(playerid, WHITE, "You are no longer a car jacker and cannot deliver the car!");
	
	Player[playerid][Checkpoint] = CAR_JACK_CHECKPOINT;
	SetPlayerCheckpoint(playerid, Jobs[jobID][JobMiscLocationOneX], Jobs[jobID][JobMiscLocationOneY], Jobs[jobID][JobMiscLocationOneZ], 10.0);
	SendClientMessage(playerid, WHITE, "Deliver the car to the red checkpoint for your payment!");
	return 1;
}

CMD:togpicture(playerid, params[])
{
	if(GetPVarInt(playerid, "CarJacker") == 0 || (Jobs[Player[playerid][Job]][JobType] != JOB_CARJACKER && Jobs[Player[playerid][Job2]][JobType] != JOB_CARJACKER))
		return SendClientMessage(playerid, WHITE, "You can't do this.");
		
	switch(GetPVarInt(playerid, "CARJACKER_TextDrawToggle"))
	{
		case 0: TextDrawToggle(playerid, 1);
		case 1:	TextDrawToggle(playerid, 0);
	}
	SendClientMessage(playerid, WHITE, "You have toggled the attachment picture.");
	return 1;
}

CMD:toggledropcar(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 6)
		return 1;
		
	new option[8];
	if(sscanf(params, "s[8]", option))
		return SendClientMessage(playerid, WHITE, "SYNTAX: /toggledropcar [public/job]");
	
	if(!strcmp(option, "public", true))
	{
		switch(DropCarStatus)
		{
			case 0:
			{
				DropCarStatus = 1;
				format(string, sizeof(string), "%s has turned off /dropcar.", GetName(playerid));
				SendToAdmins(ADMINORANGE, string, 0);
				dini_IntSet("Assets.ini", "DropCarStatus", 1);
			}
			case 1:
			{
				DropCarStatus = 0;
				format(string, sizeof(string), "%s has turned on /dropcar.", GetName(playerid));
				SendToAdmins(ADMINORANGE, string, 0);
				dini_IntSet("Assets.ini", "DropCarStatus", 0);
			}
		}
	}
	else if(!strcmp(option, "job", true))
	{
		switch(CarJackStatus)
		{
			case 0:
			{
				CarJackStatus = 1;
				format(string, sizeof(string), "%s has turned off the car jacker job.", GetName(playerid));
				SendToAdmins(ADMINORANGE, string, 0);
				dini_IntSet("Assets.ini", "CarJackStatus", 1);
			}
			case 1:
			{
				CarJackStatus = 0;
				format(string, sizeof(string), "%s has turned on the car jacker job.", GetName(playerid));
				SendToAdmins(ADMINORANGE, string, 0);
				dini_IntSet("Assets.ini", "CarJackStatus", 0);
			}
		}
	}
	else return SendClientMessage(playerid, WHITE, "SYNTAX: /toggledropcar [public/job]");
	return 1;
}

static stock TextDrawToggle(playerid, toggle)
{
	switch(toggle)
	{
		case 0:
		{
			for(new i; i < 3; i++)
				TextDrawHideForPlayer(playerid, gTextDraws[i]);
		}	
		case 1:
		{
			for(new i; i < 3; i++)
				TextDrawShowForPlayer(playerid, gTextDraws[i]);
		}
	}
	SetPVarInt(playerid, "CARJACKER_TextDrawToggle", toggle);
	return 1;
}

static stock RandomColor()
{
	return random(8);
}

static stock TotalCarJackers()
{
	new count;
	foreach(Player, i)
	{
		if(Jobs[Player[i][Job]][JobType] == JOB_CARJACKER || Jobs[Player[i][Job2]][JobType] == JOB_CARJACKER)
			count++;
	}
	return count;
}

static stock ReturnRandomCity()
{
	new city[32];
	switch(random(8))
	{
		case 0: city = "Vice City";
		case 1:	city = "Liberty City";
		case 2: city = "Alderney City";
		case 3: city = "Carcer City";
		case 4: city = "Cottonmouth";
		case 5: city = "Bullworth";
		case 6: city = "Capital City";
		case 7: city = "Ludendorff";
	}
	return city;
}

static stock RandomCarModel()
{
	switch(random(15))
	{
		case 0: return 411;
		case 1: return 415;
		case 2: return 429;
		case 3: return 451;
		case 4: return 477;
		case 5: return 506;
		case 6: return 545;
		case 7: return 555;
		case 8: return 559;
		case 9: return 560;
		case 10: return 562;
		case 11: return 579;
		case 12: return 580;
		case 13: return 602;
		case 14: return 603;
	}
	return 411;
}

stock GetCarJackerCarID()
{
	return CurrentCarID;
}
