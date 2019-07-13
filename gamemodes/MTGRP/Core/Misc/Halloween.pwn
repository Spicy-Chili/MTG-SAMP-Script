/*
#		MTG Halloween
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

#define JASON_SOUND_URL 	"http://samp.mt-gaming.com/SAMPSounds/SpookyJason.ogg"
#define MAZE_SOUND_URL 		"http://samp.mt-gaming.com/SAMPSounds/SpookyMaze.mp3"

new Timer:pJasonTimer[MAX_PLAYERS];
new Timer:MazeTimer[MAX_PLAYERS];
new JasonMask[MAX_PLAYERS];
new FinishArea;

// ============= Commands =============

CMD:jasoncheck(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 2)
		return 1;
		
	new id;
	if(sscanf(params, "u", id))
		return SendClientMessage(playerid, WHITE, "SYNTAX: /jasoncheck [id]");
		
	if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, WHITE, "That player isn't connected.");
		
	if(Player[id][KilledByJason])
		SendClientMessage(playerid, WHITE, "This player has been killed by jason.");
	else SendClientMessage(playerid, WHITE, "This player has not been killed by jason.");
	return 1;
}

CMD:jason(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 2)
		return 1;
	
	if(Player[playerid][AdminDuty])
		return SendClientMessage(playerid, WHITE, "You can't do this while on admin duty.");
	
	switch(GetPVarInt(playerid, "JASON_MODE"))
	{
		case 0:
		{
			new name[25];
			format(name, sizeof(name), "Jason_%d", playerid);
			
			new slot = GetEmptySlotAttachment(playerid);
			if(slot != -1)
			{
				JasonMask[playerid] = slot;
				SetPlayerAttachedObject(playerid, slot, 19037, 2, 0.095998, 0.006999, -0.008999, 0.000000, 86.299972, 96.399978, 1.000000, 1.195999, 1.057999);
			}
			
			SetPVarInt(playerid, "JASON_MODE", 1);
			SetPlayerNameEx(playerid, name);
			GivePlayerWeaponEx(playerid, WEAPON_CHAINSAW);
			SetPlayerColor(playerid, WHITE);
			SetPlayerHealth(playerid, 500000);
			Player[playerid][LastSkin] = GetPlayerSkin(playerid);
			SetPlayerSkin(playerid, 50);
			pJasonTimer[playerid] = repeat JasonTimer(playerid);
			SendClientMessage(playerid, WHITE, "You are now on Jason duty. Happy killing!");
		}
		case 1:
		{
			DeletePVar(playerid, "JASON_MODE");
			if(Player[playerid][AdminDuty])
			{
				SetPlayerNameEx(playerid, Player[playerid][AdminName]);
			}
			else 
			{
				SetPlayerHealth(playerid, 100);
				SetPlayerNameEx(playerid, Player[playerid][NormalName]);
			}
			RemovePlayerAttachedObject(playerid, JasonMask[playerid]);
			AdjustWeapon(playerid, WEAPON_CHAINSAW, 0);
			SetPlayerSkin(playerid, Player[playerid][LastSkin]);
			stop pJasonTimer[playerid];
			UpdatePlayerNameColour(playerid);
			SendClientMessage(playerid, WHITE, "You are now back to your normal self.");
		}
	}
	return 1;
}

CMD:trickortreat(playerid, params[])
{
	if(Player[playerid][InHalloweenMaze] == 1)
		return SendClientMessage(playerid, WHITE, "You are already inside the maze!");
	
	if(Player[playerid][Cuffed] >= 1 || Player[playerid][HospitalTime] >= 1 || Player[playerid][Tied] >= 1 || Player[playerid][Tazed] >= 1)
		return SendClientMessage(playerid, WHITE, "You can't do this right now.");
	
	new string[128];
	
	MazeTimer[playerid] = repeat MazeMusicTimer(playerid);
	Player[playerid][InHalloweenMaze] = 1;
	PlayAudioStreamForPlayer(playerid, MAZE_SOUND_URL);
	SetPlayerVirtualWorld(playerid, playerid);
	format(string, sizeof(string), "%s has entered the halloween maze! (/trickortreat)", GetName(playerid));
	NearByMessage(playerid, ANNOUNCEMENT, string);
	SendClientMessage(playerid, WHITE, "You have entered the maze. Use /exitmaze to give up!");
	SetPlayerPos_Update(playerid, -2826.2583, -1534.0724, 111.5000);
	SavePlayerPos(playerid);
	return 1;
}

CMD:exitmaze(playerid, params[])
{
	if(Player[playerid][InHalloweenMaze] == 0)
		return SendClientMessage(playerid, WHITE, "You are not inside the halloween maze.");
	
	stop MazeTimer[playerid];
	Player[playerid][InHalloweenMaze] = 0;
	SetPlayerInterior(playerid, GetPVarInt(playerid, "lastInt")-1);
	SetPlayerVirtualWorld(playerid, GetPVarInt(playerid, "lastVW")-1);
	SetPlayerPos_Update(playerid, GetPVarFloat(playerid, "lastX"), GetPVarFloat(playerid, "lastY"), GetPVarFloat(playerid, "lastZ"));
	StopAudioStreamForPlayer(playerid);
	SendClientMessage(playerid, WHITE, "You have exited the maze.");
	return 1;
}

CMD:bus(playerid, params[])
{
	if(!IsPlayerInRangeOfPoint(playerid, 5.0, -2191.4473, -2272.2432, 30.6250))
		return SendClientMessage(playerid, WHITE, "You aren't at the bus station!");
	
	new string[128];
	SetPlayerInterior(playerid, 0);
	format(string, sizeof(string), "* %s hops on the bus to Los Santos.", GetNameEx(playerid));
	NearByMessage(playerid, NICESKY, string);
	SetPlayerPos_Update(playerid, 810.1581, -1335.1005, 13.5469);
	SendClientMessage(playerid, NICESKY, "* You hop on the bus and it takes you to Market Station.");
	return 1;
}

// ============= Timers =============

timer JasonTimer[1000](playerid)
{
	new Float:pPos[3];
	GetPlayerPos(playerid, pPos[0], pPos[1], pPos[2]);
	foreach(Player, i)
	{
		if(i == playerid)
			continue;
			
		new Float:range = GetPlayerDistanceFromPoint(i, pPos[0], pPos[1], pPos[2]);
		if(range <= 50 && (GetPVarInt(i, "PLAYED_JASON_MUSIC") - gettime() <= 0))
		{
			SetPVarInt(i, "HEARS_JASON_MUSIC", 1);
			SetPVarInt(i, "PLAYED_JASON_MUSIC", (gettime() + (3 * 60)));
			PlayAudioStreamForPlayer(i, JASON_SOUND_URL);
		}
		
		if(GetPVarInt(i, "HEARS_JASON_MUSIC") == 1 && range > 50)
		{
			DeletePVar(i, "HEARS_JASON_MUSIC");
			StopAudioStreamForPlayer(i);
		}
	}
	return 1;
}

timer MazeMusicTimer[240000](playerid)
{
	if(Player[playerid][InHalloweenMaze] == 0)
	{
		stop MazeTimer[playerid];
		return 1;
	}
	PlayAudioStreamForPlayer(playerid, MAZE_SOUND_URL);
	return 1;
}

timer MazeExitTimer[1500](playerid)
{
	if(Player[playerid][GainedHalloweenPrize] == 0)
	{	
		SendClientMessage(playerid, NICESKY, "* You pass out from the fall and wake up at the local hospital. You notice there is something in your pocket that wasnt there before. (/toys)");
		Player[playerid][GainedHalloweenPrize]++;
		GiveHalloweenPrize(playerid);
	}	
	else SendClientMessage(playerid, NICESKY, "* You pass out from the fall and wake up at the local hospital.");
	Player[playerid][InHalloweenMaze] = 0;
	SetPlayerVirtualWorld(playerid, 0);
	StopAudioStreamForPlayer(playerid);
	SetPlayerPos_Update(playerid, -2199.9937, -2312.0791, 30.6250);
	return 1;
}

timer SetHallowenAnimation[1000](playerid)
{
	ApplyAnimationEx(playerid, "crack", "crckdeth2", 4.1, 1, 0, 0, 1, 1, 1);
	return 1;
}

CMD:claimhalloweenprize(playerid, params[])
{
	if(Player[playerid][ClaimedHalloweenPrize] == 1)
		return SendClientMessage(playerid, WHITE, "You already claimed the halloween prize.");
		
	GiveHalloweenPrize(playerid);
	return 1;
}

// ============= Functions =============

stock GiveHalloweenPrize(playerid)
{
	new slot = GetAvailableToySlot(playerid), toymodel;	
	if(slot == -1)
	{
		SendClientMessage(playerid, GREEN, "You do not have enough toy slots for the halloween prize!");
		SendClientMessage(playerid, GREEN, "Make room for the toy and do /claimhalloweenprize to receive the toy!");
		return 1;
	}
	
	switch(random(5))
	{
		case 0: toymodel = 19011;
		case 1: toymodel = 19013;
		case 2: toymodel = 19016;
		case 3, 4:	toymodel = 19014;
	}
	
	Player[playerid][ClaimedHalloweenPrize] = 1;
	PlayerToys[playerid][ToyModelID][slot] = toymodel;
	SendClientMessage(playerid, GREEN, "You won a special toy item for completing the maze!");
	return 1;
}

// ============= Callbacks =============

hook OnPlayerDeath(playerid, killerid, reason)
{
	if(GetPVarInt(playerid, "HIT_BY_JASON") > 0)
		DeletePVar(playerid, "HIT_BY_JASON");
}

hook OnPlayerEnterDynamicArea(playerid, areaid)
{
	if(areaid == FinishArea && Player[playerid][InHalloweenMaze] == 1)
	{
		defer MazeExitTimer(playerid);
	}
	return 1;
}

hook OnGameModeInit()
{
	FinishArea = CreateDynamicRectangle(-2766.9175, -1526.1588, -2758.2900, -1523.6622);
	
	CreateDynamic3DTextLabel("Bus Station\nType /bus for a free ride!", GREEN, -2191.4473, -2272.2432, 30.6250, 40, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0);
	CreateDynamicPickup(1318, 1, -2191.4473, -2272.2432, 30.6250);
	
	//Bus stop
	CreateDynamicObject(1257, -2191.39136, -2271.19946, 30.83815,   0.00000, 0.00000, 51.48001);
	
	new retexture;
	//Cabin
	retexture = CreateDynamicObject(19355, -2816.15356, -1524.22498, 139.76151,   0.00000, 90.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 9919, "grnwht_sfe", "vic01_LA");
	retexture = CreateDynamicObject(19355, -2816.13550, -1515.09033, 141.41150,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 6385, "rodeot01_law2", "vic01_LA");
	retexture = CreateDynamicObject(19355, -2819.36621, -1529.29089, 139.76151,   0.00000, 90.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 9919, "grnwht_sfe", "vic01_LA");
	retexture = CreateDynamicObject(19355, -2819.36621, -1529.29089, 143.18150,   0.00000, 90.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 6385, "rodeot01_law2", "vic01_LA");
	retexture = CreateDynamicObject(16304, -2817.49536, -1604.03833, 138.61209,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3694, "ryderholes", "ryder_mud");
	//retexture = CreateDynamicObject(19431, -2811.05078, -1524.03125, 141.34340,   0.00000, 0.00000, 0.00000);
	//SetDynamicObjectMaterial(retexture,  0, 12937, "sw_oldshack", "sw_barndoor1");
	retexture = CreateDynamicObject(19431, -2821.24023, -1518.66040, 141.34340,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture,  0, 12937, "sw_oldshack", "sw_barndoor1");
	retexture = CreateDynamicObject(19474, -2816.17969, -1524.28125, 140.24271,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture,  0, 12937, "sw_oldshack", "sw_woodflloorsplat");
	SetDynamicObjectMaterial(retexture,  1, 12937, "sw_oldshack", "sw_woodflloorsplat");
	SetDynamicObjectMaterial(retexture,  2, 12937, "sw_oldshack", "sw_woodflloorsplat");
	CreateDynamicObject(3524, -2818.77368, -1549.07166, 137.25690,   359.95001, 0.00000, 135.00000);
	CreateDynamicObject(2590, -2843.80835, -1559.29102, 141.54131,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2908, -2843.80835, -1559.32312, 141.59140,   270.00000, 90.00000, 180.00000);
	CreateDynamicObject(3265, -2836.10840, -1559.49097, 139.81480,   260.00000, 80.00000, 150.00000);
	CreateDynamicObject(12961, -2830.78833, -1520.75244, 138.53230,   0.00000, 3.00000, 180.00000);
	CreateDynamicObject(2907, -2830.40503, -1511.87219, 138.38460,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2906, -2831.24170, -1511.84741, 138.53230,   0.00000, 0.00000, 225.00000);
	CreateDynamicObject(2096, -2809.11841, -1530.10095, 139.83971,   0.00000, 0.00000, 135.00000);
	CreateDynamicObject(357, -2808.71753, -1530.60681, 140.09331,   0.00000, 240.00000, 320.00000);
	CreateDynamicObject(2590, -2820.30371, -1528.67834, 143.95290,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(3092, -2811.61328, -1528.65625, 141.18520,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(3092, -2818.34497, -1515.89746, 141.18520,   0.00000, 0.00000, -0.30000);
	CreateDynamicObject(2590, -2818.34814, -1516.03540, 143.80290,   0.00000, 0.00000, 315.00000);
	CreateDynamicObject(1771, -2816.05981, -1529.71704, 140.34190,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(936, -2813.90088, -1515.77478, 140.31310,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(936, -2812.00073, -1518.47485, 140.31310,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(341, -2814.66553, -1515.91943, 141.04030,   0.00000, 35.00000, 0.00000);
	CreateDynamicObject(2906, -2813.31201, -1516.03113, 140.78700,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(335, -2812.07080, -1518.05713, 140.76340,   90.00000, 90.00000, 0.00000);
	CreateDynamicObject(335, -2812.27075, -1518.85706, 140.76340,   90.00000, 90.00000, 1690.00000);
	CreateDynamicObject(2905, -2811.76489, -1518.96143, 140.84711,   0.00000, 0.00000, 20.00000);
	CreateDynamicObject(2906, -2812.02319, -1518.34949, 140.83710,   0.00000, 0.00000, 60.00000);
	CreateDynamicObject(2907, -2816.30005, -1524.70007, 140.80901,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2908, -2816.18652, -1525.46704, 140.80901,   0.00000, 0.00000, -0.12000);
	CreateDynamicObject(2906, -2816.71973, -1524.53320, 140.80901,   0.00000, 0.00000, 10.00000);
	CreateDynamicObject(2905, -2816.54492, -1523.58313, 140.80901,   0.00000, 0.00000, 20.00000);
	CreateDynamicObject(2906, -2815.81958, -1524.63318, 140.80901,   0.00000, 0.00000, 340.00000);
	CreateDynamicObject(2905, -2815.94482, -1523.58313, 140.80901,   0.00000, 0.00000, 340.00000);
	CreateDynamicObject(2803, -2820.03345, -1530.19812, 140.34160,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2805, -2820.41895, -1528.65063, 141.04311,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2590, -2811.75586, -1528.66931, 143.80290,   0.00000, 0.00000, 225.00000);
	CreateDynamicObject(2806, -2819.03906, -1530.40002, 139.84331,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2804, -2819.96826, -1529.25098, 139.84380,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(19036, -2815.62329, -1525.33521, 140.83000,   0.00000, 315.00000, 0.00000);
	CreateDynamicObject(3264, -2770.82788, -1610.00000, 140.41830,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3265, -2770.94336, -1600.00000, 140.43700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3262, -2771.13062, -1630.00000, 140.45039,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3263, -2770.66919, -1620.00000, 140.44600,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3265, -2774.94336, -1660.00000, 140.43700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3264, -2776.82788, -1670.00000, 140.41830,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3263, -2778.16919, -1680.00000, 140.44600,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3262, -2780.13062, -1690.00000, 140.45039,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3524, -2806.92065, -1558.37122, 137.93089,   359.95001, 0.00000, 45.00000);
	CreateDynamicObject(785, -2803.50781, -1641.82813, 139.47656,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3524, -2821.70752, -1565.80090, 138.01089,   359.95001, 0.00000, 0.00000);
	CreateDynamicObject(3524, -2817.79224, -1582.34155, 138.04089,   359.95999, 0.00000, 45.00000);
	CreateDynamicObject(2590, -2815.30835, -1559.29102, 141.54129,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2908, -2815.30322, -1559.35315, 141.59140,   270.00000, 90.00000, 180.00000);
	CreateDynamicObject(2590, -2827.80835, -1559.29102, 141.54131,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2908, -2827.80322, -1559.32312, 141.59140,   270.00000, 90.00000, 180.00000);
	CreateDynamicObject(2590, -2799.30835, -1559.29102, 141.54131,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2908, -2799.30322, -1559.35315, 141.59140,   270.00000, 90.00000, 180.00000);
	CreateDynamicObject(846, -2770.31665, -1638.73718, 140.90950,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(848, -2778.17285, -1638.86365, 142.00819,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2905, -2808.75586, -1573.58765, 140.41380,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2228, -2816.53882, -1603.29626, 141.22659,   0.00000, 25.00000, 0.00000);
	CreateDynamicObject(3092, -2817.24805, -1602.16138, 140.38870,   90.00000, 90.00000, 90.00000);
	CreateDynamicObject(3092, -2819.14795, -1603.26135, 140.47870,   100.00000, 0.00000, 45.00000);
	CreateDynamicObject(2906, -2817.37354, -1603.62659, 141.16769,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(2908, -2817.72705, -1605.09094, 140.71010,   350.00000, 0.00000, 0.00000);
	CreateDynamicObject(3524, -2835.06445, -1582.12244, 138.17090,   359.95999, 0.00000, 45.00000);
	CreateDynamicObject(1463, -2809.41748, -1515.87952, 140.15430,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2906, -2793.91699, -1566.71252, 140.29671,   0.00000, 0.00000, 75.00000);
	CreateDynamicObject(2905, -2828.12524, -1619.97742, 140.56790,   0.00000, 0.00000, 100.00000);
	CreateDynamicObject(2907, -2839.71362, -1596.65747, 140.41510,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2908, -2849.71387, -1555.52991, 139.51241,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2908, -2830.13550, -1525.60095, 138.09523,   -35.04000, -2.34000, -32.82000);
	CreateDynamicObject(2906, -2827.70996, -1518.82458, 138.17734,   43.37999, -65.82000, 29.64000);


	//Maze
	retexture = CreateObject(18981, -2779.87964, -1524.28125, 110.00000,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(retexture, 0, 18250, "cw_junkbuildcs_t", "Was_scrpyd_shack");
	retexture = CreateObject(18981, -2797.17969, -1524.28125, 105.83400,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(retexture, 0, 18250, "cw_junkbuildcs_t", "Was_scrpyd_shack");
	retexture = CreateObject(18981, -2820.22974, -1524.28125, 110.00000,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(retexture, 0, 18250, "cw_junkbuildcs_t", "Was_scrpyd_shack");
	retexture = CreateObject(18981, -2779.92969, -1524.28125, 114.48000,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(retexture, 0, 18250, "cw_junkbuildcs_t", "Was_scrpyd_shack");
	retexture = CreateObject(18981, -2797.17969, -1524.28125, 114.48200,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(retexture, 0, 18250, "cw_junkbuildcs_t", "Was_scrpyd_shack");
	retexture = CreateObject(18981, -2820.17969, -1524.28125, 114.48000,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(retexture, 0, 18250, "cw_junkbuildcs_t", "Was_scrpyd_shack");
	retexture = CreateDynamicObject(19450, -2828.58936, -1524.28125, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2812.24731, -1530.49084, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2813.85742, -1521.58435, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2813.74731, -1526.49084, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2814.74731, -1530.49084, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2815.74731, -1529.39087, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19358, -2815.74927, -1523.10840, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19358, -2823.13721, -1535.96021, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19358, -2818.32935, -1520.41431, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19358, -2817.42920, -1517.38623, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19358, -2815.82935, -1515.51428, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2814.23560, -1516.68567, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2807.77002, -1540.39270, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19358, -2809.26953, -1533.80103, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19358, -2809.45361, -1532.24500, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19358, -2810.76953, -1535.05103, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2804.48999, -1536.68481, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2804.48999, -1511.87500, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2816.97412, -1535.38281, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2814.11011, -1536.68481, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2814.11011, -1511.87500, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2818.89185, -1530.65491, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2819.89185, -1518.24146, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2823.72998, -1511.87500, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2823.72998, -1536.68481, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2828.58936, -1514.65125, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2828.58936, -1533.91125, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2817.54736, -1529.39087, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19358, -2809.44995, -1526.05164, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2820.47998, -1513.51428, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19358, -2816.87939, -1518.76428, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2804.48999, -1536.68481, 108.73740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2804.48999, -1511.87500, 108.73740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2807.77002, -1530.77478, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2794.86011, -1536.68481, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2794.86011, -1536.68481, 108.73740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2794.86011, -1511.87500, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2807.77002, -1516.17712, 105.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2806.48999, -1516.17712, 105.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2807.77002, -1525.80811, 105.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2807.77002, -1535.43408, 105.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2804.48999, -1536.68481, 105.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2794.86011, -1536.68481, 105.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2792.33838, -1535.43408, 105.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2792.33838, -1525.80811, 105.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2792.33838, -1516.17712, 105.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2794.86011, -1511.87500, 105.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2804.48999, -1511.87500, 105.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2794.86011, -1511.87500, 108.73740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2800.95264, -1529.28271, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2800.95264, -1529.28271, 108.73740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2800.95264, -1519.65271, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2800.95264, -1519.65271, 108.73740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(14416, -2808.38232, -1515.02002, 107.29630,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2806.48999, -1516.17712, 108.73740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2806.48999, -1516.17712, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2809.12988, -1516.67712, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2792.33838, -1532.33313, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2792.33838, -1516.30908, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19431, -2819.17798, -1523.14807, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2782.60010, -1528.82910, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19358, -2810.72339, -1532.23499, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2785.62598, -1535.37854, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2780.60010, -1523.01306, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19388, -2767.36279, -1524.91113, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19431, -2772.50537, -1519.72766, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19388, -2820.58350, -1524.62634, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19388, -2823.79346, -1524.62634, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19388, -2825.37354, -1526.20618, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19388, -2823.79346, -1521.38623, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19388, -2825.37354, -1523.00623, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19388, -2825.37354, -1519.79419, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19388, -2825.37354, -1515.03223, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19388, -2826.89160, -1513.51428, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19431, -2825.37158, -1517.40820, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19388, -2823.79346, -1517.38623, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19388, -2826.89160, -1517.38623, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19388, -2822.26343, -1519.79419, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19388, -2822.26343, -1523.00623, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19431, -2822.26343, -1517.40820, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19388, -2822.26343, -1515.03223, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19388, -2820.61353, -1517.38623, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19388, -2826.89160, -1521.38623, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19388, -2826.89160, -1524.62634, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19388, -2823.79346, -1527.78625, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19388, -2823.13721, -1532.78296, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19450, -2828.49707, -1531.10034, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19388, -2822.08228, -1531.10034, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19431, -2819.68359, -1531.10034, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19388, -2820.58350, -1527.78625, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19388, -2822.26343, -1526.20618, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19388, -2826.89160, -1527.78625, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19388, -2825.37354, -1529.41626, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19358, -2817.37939, -1524.62634, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19358, -2810.72998, -1527.03564, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19358, -2809.32007, -1528.38562, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19358, -2810.72998, -1529.73560, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19358, -2809.32007, -1531.08557, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19358, -2812.24731, -1524.60559, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19358, -2810.64282, -1522.84473, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19358, -2808.94995, -1524.36157, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19450, -2789.12598, -1524.31982, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19450, -2785.23999, -1536.68481, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19450, -2775.60986, -1536.68481, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19450, -2785.23999, -1511.87500, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19450, -2775.60986, -1511.87500, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19450, -2790.83838, -1529.87854, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19450, -2790.83838, -1518.43909, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19450, -2789.12598, -1535.87854, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19450, -2787.33838, -1529.87854, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19450, -2772.98999, -1528.82910, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19450, -2780.89673, -1530.64856, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19450, -2774.98999, -1533.70911, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19358, -2776.09399, -1532.16492, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19358, -2777.43994, -1534.49695, 112.23740,   0.00000, 0.00000, 120.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19358, -2780.39038, -1535.28857, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19358, -2783.06909, -1534.17871, 112.23740,   0.00000, 0.00000, 45.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19358, -2782.78638, -1532.47595, 112.23740,   0.00000, 0.00000, 110.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19358, -2779.83057, -1532.47644, 112.23740,   0.00000, 0.00000, 70.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19450, -2780.60010, -1521.01306, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19450, -2780.60010, -1519.01306, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19450, -2780.60010, -1517.01306, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19450, -2780.60010, -1515.01306, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19450, -2780.60010, -1513.51306, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19450, -2773.98999, -1523.92529, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19450, -2770.88135, -1512.66455, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19358, -2774.19531, -1519.01306, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19450, -2780.60010, -1525.01306, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19450, -2780.60010, -1527.01306, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19450, -2787.33838, -1516.87854, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19450, -2789.12598, -1513.31982, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19450, -2770.97021, -1515.01306, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19431, -2792.33838, -1526.71460, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19388, -2792.33838, -1524.31982, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19431, -2792.33838, -1521.92456, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19358, -2774.19531, -1517.01306, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19358, -2774.19531, -1513.51306, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19358, -2774.19531, -1523.01306, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19358, -2774.19531, -1527.01306, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19431, -2782.14648, -1526.97839, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19431, -2777.09521, -1525.03906, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19431, -2784.21265, -1522.88892, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19431, -2776.17773, -1521.05273, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19431, -2781.88916, -1518.94568, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19431, -2774.59448, -1516.98303, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19450, -2770.88135, -1522.29907, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19358, -2767.36279, -1528.12305, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19450, -2768.48779, -1529.82910, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19450, -2769.28247, -1522.29907, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19358, -2767.59302, -1527.03125, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19450, -2767.36279, -1518.49329, 112.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19450, -2807.77002, -1516.17712, 108.73740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19450, -2807.77002, -1525.80811, 108.73740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture =	CreateDynamicObject(19450, -2807.77002, -1535.43408, 108.73740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2792.33838, -1535.43408, 108.73740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2792.33838, -1525.80811, 108.73740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2792.33838, -1516.17712, 108.73740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19431, -2774.10278, -1529.82910, 112.23740,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2800.95264, -1519.65271, 105.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(19450, -2800.95264, -1529.28271, 105.23740,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12991, "sw_shack2", "sw_woodflloor");
	retexture = CreateDynamicObject(1492, -2825.37061, -1523.74304, 110.48780,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12937, "sw_oldshack", "sw_woodflloorsplat");
	SetDynamicObjectMaterial(retexture, 1, 12937, "sw_oldshack", "sw_woodflloorsplat");
	retexture = CreateDynamicObject(1492, -2825.31079, -1515.78137, 110.49780,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12937, "sw_oldshack", "sw_woodflloorsplat");
	SetDynamicObjectMaterial(retexture, 1, 12937, "sw_oldshack", "sw_woodflloorsplat");
	retexture = CreateDynamicObject(1492, -2822.23999, -1515.77710, 110.49780,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12937, "sw_oldshack", "sw_woodflloorsplat");
	SetDynamicObjectMaterial(retexture, 1, 12937, "sw_oldshack", "sw_woodflloorsplat");
	retexture = CreateDynamicObject(1492, -2821.37378, -1524.64722, 110.49780,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12937, "sw_oldshack", "sw_woodflloorsplat");
	SetDynamicObjectMaterial(retexture, 1, 12937, "sw_oldshack", "sw_woodflloorsplat");
	retexture = CreateDynamicObject(1492, -2824.57300, -1521.36926, 110.48780,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12937, "sw_oldshack", "sw_woodflloorsplat");
	SetDynamicObjectMaterial(retexture, 1, 12937, "sw_oldshack", "sw_woodflloorsplat");
	retexture = CreateDynamicObject(1492, -2824.57300, -1524.61926, 110.48780,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12937, "sw_oldshack", "sw_woodflloorsplat");
	SetDynamicObjectMaterial(retexture, 1, 12937, "sw_oldshack", "sw_woodflloorsplat");
	retexture = CreateDynamicObject(1492, -2824.57300, -1527.77246, 110.48780,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12937, "sw_oldshack", "sw_woodflloorsplat");
	SetDynamicObjectMaterial(retexture, 1, 12937, "sw_oldshack", "sw_woodflloorsplat");
	retexture = CreateDynamicObject(1492, -2827.67041, -1524.62952, 110.48780,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12937, "sw_oldshack", "sw_woodflloorsplat");
	SetDynamicObjectMaterial(retexture, 1, 12937, "sw_oldshack", "sw_woodflloorsplat");
	retexture = CreateDynamicObject(1492, -2827.67041, -1521.38953, 110.48780,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12937, "sw_oldshack", "sw_woodflloorsplat");
	SetDynamicObjectMaterial(retexture, 1, 12937, "sw_oldshack", "sw_woodflloorsplat");
	retexture = CreateDynamicObject(1492, -2827.67041, -1513.50952, 110.48780,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12937, "sw_oldshack", "sw_woodflloorsplat");
	SetDynamicObjectMaterial(retexture, 1, 12937, "sw_oldshack", "sw_woodflloorsplat");
	retexture = CreateDynamicObject(1492, -2827.67041, -1517.37952, 110.48780,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12937, "sw_oldshack", "sw_woodflloorsplat");
	SetDynamicObjectMaterial(retexture, 1, 12937, "sw_oldshack", "sw_woodflloorsplat");
	retexture = CreateDynamicObject(1492, -2825.36621, -1530.16064, 110.48780,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12937, "sw_oldshack", "sw_woodflloorsplat");
	SetDynamicObjectMaterial(retexture, 1, 12937, "sw_oldshack", "sw_woodflloorsplat");
	retexture = CreateDynamicObject(1532, -2822.23999, -1526.94287, 110.49170,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12937, "sw_oldshack", "sw_woodflloorsplat");
	SetDynamicObjectMaterial(retexture, 1, 12937, "sw_oldshack", "sw_woodflloorsplat");
	SetDynamicObjectMaterial(retexture, 2, 12937, "sw_oldshack", "sw_woodflloorsplat");
	retexture = CreateDynamicObject(1532, -2822.23999, -1523.74304, 110.49770,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12937, "sw_oldshack", "sw_woodflloorsplat");
	SetDynamicObjectMaterial(retexture, 1, 12937, "sw_oldshack", "sw_woodflloorsplat");
	SetDynamicObjectMaterial(retexture, 2, 12937, "sw_oldshack", "sw_woodflloorsplat");
	retexture = CreateDynamicObject(1532, -2822.23999, -1520.53320, 110.49770,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12937, "sw_oldshack", "sw_woodflloorsplat");
	SetDynamicObjectMaterial(retexture, 1, 12937, "sw_oldshack", "sw_woodflloorsplat");
	SetDynamicObjectMaterial(retexture, 2, 12937, "sw_oldshack", "sw_woodflloorsplat");
	retexture = CreateDynamicObject(1532, -2825.37134, -1520.53760, 110.49770,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12937, "sw_oldshack", "sw_woodflloorsplat");
	SetDynamicObjectMaterial(retexture, 1, 12937, "sw_oldshack", "sw_woodflloorsplat");
	SetDynamicObjectMaterial(retexture, 2, 12937, "sw_oldshack", "sw_woodflloorsplat");
	retexture = CreateDynamicObject(1532, -2821.37378, -1527.77246, 110.49770,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12937, "sw_oldshack", "sw_woodflloorsplat");
	SetDynamicObjectMaterial(retexture, 1, 12937, "sw_oldshack", "sw_woodflloorsplat");
	SetDynamicObjectMaterial(retexture, 2, 12937, "sw_oldshack", "sw_woodflloorsplat");
	retexture = CreateDynamicObject(1532, -2824.56689, -1517.38940, 110.47970,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12937, "sw_oldshack", "sw_woodflloorsplat");
	SetDynamicObjectMaterial(retexture, 1, 12937, "sw_oldshack", "sw_woodflloorsplat");
	SetDynamicObjectMaterial(retexture, 2, 12937, "sw_oldshack", "sw_woodflloorsplat");
	retexture = CreateDynamicObject(1532, -2827.66919, -1527.77246, 110.49770,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 12937, "sw_oldshack", "sw_woodflloorsplat");
	SetDynamicObjectMaterial(retexture, 1, 12937, "sw_oldshack", "sw_woodflloorsplat");
	SetDynamicObjectMaterial(retexture, 2, 12937, "sw_oldshack", "sw_woodflloorsplat");
	retexture = CreateDynamicObject(1532, -2825.36011, -1526.94287, 110.49170,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 12937, "sw_oldshack", "sw_woodflloorsplat");
	SetDynamicObjectMaterial(retexture, 1, 12937, "sw_oldshack", "sw_woodflloorsplat");
	SetDynamicObjectMaterial(retexture, 2, 12937, "sw_oldshack", "sw_woodflloorsplat");
	retexture = CreateDynamicObject(19355, -2794.18140, -1524.31982, 110.40000,   0.00000, 90.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3178, "counthousmisc", "shackwood01");
	retexture = CreateDynamicObject(19428, -2794.33740, -1535.81482, 111.00000,   0.00000, 90.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3178, "counthousmisc", "shackwood01");
	retexture = CreateDynamicObject(19428, -2794.33740, -1532.81482, 111.00000,   0.00000, 90.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3178, "counthousmisc", "shackwood01");
	retexture = CreateDynamicObject(19428, -2799.33740, -1535.81482, 111.00000,   0.00000, 90.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3178, "counthousmisc", "shackwood01");
	retexture = CreateDynamicObject(19428, -2798.33740, -1531.81482, 111.00000,   0.00000, 90.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 3178, "counthousmisc", "shackwood01");
	retexture = CreateDynamicObject(19428, -2798.33740, -1526.81482, 111.00000,   0.00000, 90.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 3178, "counthousmisc", "shackwood01");
	retexture = CreateDynamicObject(19428, -2798.33740, -1521.81482, 111.00000,   0.00000, 90.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 3178, "counthousmisc", "shackwood01");
	retexture = CreateDynamicObject(19428, -2798.33740, -1516.81482, 111.00000,   0.00000, 90.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 3178, "counthousmisc", "shackwood01");
	retexture = CreateDynamicObject(19428, -2794.33740, -1515.81482, 111.00000,   0.00000, 90.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3178, "counthousmisc", "shackwood01");
	retexture = CreateDynamicObject(19428, -2794.33740, -1512.81482, 111.00000,   0.00000, 90.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3178, "counthousmisc", "shackwood01");
	retexture = CreateDynamicObject(19428, -2799.33740, -1512.81482, 111.00000,   0.00000, 90.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3178, "counthousmisc", "shackwood01");
	retexture = CreateDynamicObject(19428, -2804.03735, -1513.81482, 111.00000,   0.00000, 90.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 3178, "counthousmisc", "shackwood01");
	retexture = CreateDynamicObject(19428, -2803.03735, -1518.81482, 111.00000,   0.00000, 90.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 3178, "counthousmisc", "shackwood01");
	retexture = CreateDynamicObject(19355, -2804.03735, -1524.01978, 111.00000,   0.00000, 90.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3178, "counthousmisc", "shackwood01");
	retexture = CreateDynamicObject(19428, -2804.03735, -1534.81482, 111.00000,   0.00000, 90.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 3178, "counthousmisc", "shackwood01");
	retexture = CreateDynamicObject(19428, -2803.03735, -1529.31482, 111.00000,   0.00000, 90.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 3178, "counthousmisc", "shackwood01");
	retexture = CreateDynamicObject(19428, -2806.03735, -1529.31482, 111.00000,   0.00000, 90.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3178, "counthousmisc", "shackwood01");
	//finish box
	retexture = CreateDynamicObject(19377, -2767.35352, -1524.33557, 105.25540,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3178, "counthousmisc", "shackwood01", 0xFF000000);
	retexture = CreateDynamicObject(19377, -2762.73364, -1524.33557, 104.68541,   0.00000, 90.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3178, "counthousmisc", "shackwood01", 0xFF000000);
	retexture = CreateDynamicObject(19377, -2762.53369, -1526.59558, 110.02540,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 3178, "counthousmisc", "shackwood01", 0xFF000000);
	retexture = CreateDynamicObject(19377, -2762.53369, -1523.22559, 110.02540,   0.00000, 0.00000, 90.00000);
	SetDynamicObjectMaterial(retexture, 0, 3178, "counthousmisc", "shackwood01", 0xFF000000);
	retexture = CreateDynamicObject(19377, -2762.73364, -1524.33557, 114.10014,   0.00000, 90.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3178, "counthousmisc", "shackwood01", 0xFF000000);
	retexture = CreateDynamicObject(19377, -2757.85352, -1524.33557, 110.02540,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3178, "counthousmisc", "shackwood01", 0xFF000000);
	//body parts and stuff
	CreateDynamicObject(2806, -2784.27832, -1535.93054, 110.58820,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2804, -2775.89038, -1535.79163, 110.54710,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2907, -2769.85352, -1516.60352, 110.64630,   0.00000, 0.00000, 30.00000);
	CreateDynamicObject(2905, -2779.41748, -1529.85107, 110.56630,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(2906, -2791.56152, -1527.85803, 110.56100,   0.00000, 0.00000, 70.00000);
	CreateDynamicObject(2908, -2789.98120, -1524.69824, 110.56740,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2806, -2791.65771, -1535.81421, 110.58820,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2905, -2788.03467, -1535.23254, 110.56630,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(2804, -2777.05664, -1518.13525, 110.54710,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2908, -2772.93750, -1522.35229, 110.56740,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2905, -2791.63965, -1520.99133, 110.56630,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(2906, -2772.00757, -1512.75964, 110.56100,   0.00000, 0.00000, 70.00000);
	CreateDynamicObject(2905, -2773.10693, -1523.55774, 110.56630,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(2804, -2776.28149, -1524.35742, 110.54710,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2806, -2780.84375, -1526.19568, 110.58820,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2804, -2773.16382, -1525.97656, 110.54710,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2803, -2782.48608, -1533.39648, 110.98000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2905, -2783.90552, -1528.39294, 110.56630,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(3092, -2774.51538, -1529.35217, 111.45310,   20.00000, 0.00000, 270.00000);
	CreateDynamicObject(2804, -2776.87378, -1528.00940, 110.54710,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2908, -2776.87036, -1521.52307, 110.56740,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2905, -2783.04810, -1524.10876, 110.56630,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(2907, -2790.17896, -1514.78467, 110.64630,   0.00000, 0.00000, 30.00000);
	CreateDynamicObject(2907, -2773.92603, -1514.31152, 110.64630,   0.00000, 0.00000, 30.00000);
	CreateDynamicObject(2905, -2785.04858, -1516.38391, 110.56630,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(2906, -2788.58179, -1519.04700, 110.56100,   0.00000, 0.00000, 70.00000);
	CreateDynamicObject(2908, -2776.23413, -1516.16602, 110.56740,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2905, -2780.05176, -1512.36304, 110.56630,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(2906, -2783.17505, -1517.94800, 110.56100,   0.00000, 0.00000, 70.00000);
	CreateDynamicObject(2906, -2789.50684, -1530.39807, 110.56100,   0.00000, 0.00000, 70.00000);
	CreateDynamicObject(2806, -2785.44312, -1520.41699, 110.58820,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3092, -2802.40430, -1527.03735, 106.39900,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(3092, -2794.91748, -1517.64575, 106.39900,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(2906, -2803.74170, -1530.34094, 106.39900,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2905, -2795.09131, -1514.25684, 106.39900,   0.00000, 0.00000, 10.00000);
	CreateDynamicObject(2907, -2806.06567, -1534.94507, 106.39900,   0.00000, 0.00000, 200.00000);
	CreateDynamicObject(2908, -2806.65771, -1528.82397, 106.39900,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2905, -2803.00244, -1530.20581, 106.39900,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2906, -2804.27930, -1523.25415, 106.39900,   0.00000, 0.00000, 15.00000);
	CreateDynamicObject(2905, -2799.55542, -1518.17126, 106.39900,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(2907, -2794.45581, -1522.78381, 106.39900,   0.00000, 0.00000, 220.00000);
	CreateDynamicObject(2907, -2802.53784, -1531.95715, 106.39900,   0.00000, 0.00000, 200.00000);
	CreateDynamicObject(2905, -2802.44775, -1524.23962, 106.39900,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2908, -2798.67212, -1514.08179, 106.39900,   0.00000, 0.00000, 20.00000);
	CreateDynamicObject(2906, -2804.02734, -1516.43494, 106.39900,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2906, -2796.90845, -1512.46155, 106.39900,   0.00000, 0.00000, 115.00000);
	CreateDynamicObject(2905, -2805.44897, -1521.06274, 106.39900,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(2905, -2802.78467, -1518.08496, 106.39900,   0.00000, 0.00000, 10.00000);
	CreateDynamicObject(2908, -2805.06250, -1518.69873, 106.39900,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2907, -2803.50806, -1520.84326, 106.39900,   0.00000, 0.00000, 200.00000);
	CreateDynamicObject(2907, -2795.14771, -1534.04663, 106.39900,   0.00000, 0.00000, 200.00000);
	CreateDynamicObject(2908, -2792.60400, -1528.95569, 106.39900,   0.00000, 0.00000, 100.00000);
	CreateDynamicObject(2908, -2798.69482, -1522.00159, 106.39900,   0.00000, 0.00000, 40.00000);
	CreateDynamicObject(2905, -2795.27124, -1520.31592, 106.39900,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2906, -2804.57935, -1525.67444, 106.39900,   0.00000, 0.00000, 35.00000);
	CreateDynamicObject(2906, -2798.63745, -1526.16724, 106.39900,   0.00000, 0.00000, 70.00000);
	CreateDynamicObject(2906, -2794.51831, -1530.63196, 106.39900,   0.00000, 0.00000, 35.00000);
	CreateDynamicObject(2906, -2797.73413, -1519.87329, 106.39900,   0.00000, 0.00000, 115.00000);
	CreateDynamicObject(2907, -2797.52393, -1529.16357, 106.39900,   0.00000, 0.00000, 100.00000);
	CreateDynamicObject(2908, -2798.02710, -1533.25000, 106.39900,   0.00000, 0.00000, 100.00000);
	CreateDynamicObject(2906, -2794.27783, -1524.25146, 106.39900,   0.00000, 0.00000, 20.00000);

	return 1;
}
