/*
#		MTG Fair & 4th of July
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

#define FIREWORK_ACTOR_X			369.9246
#define FIREWORK_ACTOR_Y			-1879.8983
#define FIREWORK_ACTOR_Z			2.6174
#define FIREWORK_ACTOR_A			177.1160
#define FIREWORK_ACTOR_SLOT			0
#define FIREWORK_ACTOR_SKIN			28

#define KART_SPAWN 					251.6150, -1783.3813, 3.8437, 86.6082

#define FIREWORK_PRICE				750

#define MAX_FIREWORKS_PER_PLAYER	5

#define MAX_FAIR_ACTORS				10

#define MAX_PLAYERS_IN_TRACK		10

#define PARROT_OBJECT_ID			19078

new FairActors[MAX_FAIR_ACTORS];
static string[128];

new Float:GoKartCheckpoints[8][3] = 
{
	{221.6082, -1787.0974, 3.8438}, 
	{184.8992, -1792.1621, 3.8439}, 
	{190.0145, -1810.9688, 3.8419}, 
	{218.1337, -1802.9103, 3.8422}, 
	{224.8023, -1825.4434, 3.8417}, 
	{237.0515, -1806.5916, 3.8418}, 
	{269.7646, -1822.3263, 3.8417}, 
	{256.4743, -1792.5540, 3.8439} 
};

hook OnGameModeInit()
{
	FairActors[FIREWORK_ACTOR_SLOT] = CreateActor(FIREWORK_ACTOR_SKIN, FIREWORK_ACTOR_X, FIREWORK_ACTOR_Y, FIREWORK_ACTOR_Z, FIREWORK_ACTOR_A);
	
	//Food stands
	FairActors[1] = CreateActor(168, 354.8415, -1824.2217, 4.3031, 92.0102);
	FairActors[2] = CreateActor(209, 353.5862, -1819.4490, 4.3031, 127.5043);
	FairActors[3] = CreateActor(155, 336.1296, -1839.5862, 4.3031, 90.7802);
	FairActors[4] = CreateActor(205, 338.9300, -1839.6270, 4.3031, 269.9852);
	//Lifeguards
	FairActors[5] = CreateActor(251, 339.8390, -1872.1521, 4.0363, 88.3375);
	FairActors[6] = CreateActor(97, 336.7706, -1875.6503, 4.0363, 189.4320);
	ApplyActorAnimation(FairActors[5], "gangs", "leanIN", 4.1, 0, 1, 1, 1, 0);
	ApplyActorAnimation(FairActors[6], "ped", "DRIVE_BOAT", 4.1, 0, 1, 1, 1, 0);
	
	//Firework Vendor
	CreateDynamic3DTextLabel("Firework Vendor\n/buyfirework", BLUE, FIREWORK_ACTOR_X, FIREWORK_ACTOR_Y, FIREWORK_ACTOR_Z, 15, _, _, 1, 0, 0, _, 20);
	
	//Go-kart Track
	FairActors[7] = CreateActor(50, 265.9225, -1781.0068, 4.5600, 277.1342);
	ApplyActorAnimation(FairActors[7], "cop_ambient", "Coplook_loop", 4.1, 0, 1, 1, 1, 0);
	CreateDynamic3DTextLabel("Go-kart Track Operator\n/entertrack\n/claimprize", BLUE, 265.9225, -1781.0068, 4.5600, 45, _, _, 1, 0, 0, _, 50);
	
	return 1;
}

//Gokart Track

/*CMD:entertrack(playerid, params[])
{
	if(!IsPlayerInRangeOfPoint(playerid, 5.0, 265.9225, -1781.0068, 4.5600))
		return SendClientMessage(playerid, WHITE, "You aren't near the go-kart track operator.");
	
	if(GetPlayersInTrack() >= MAX_PLAYERS_IN_TRACK)
		return SendClientMessage(playerid, WHITE, "Operator says: Sorry man, the track is currently full. Wait until someone gets out.");
	
	SetPVarInt(playerid, "InGoKartTrack", 1);
	Player[playerid][PlayerGokart] = CreateVehicle(571, KART_SPAWN, RandomEx(128, 255), RandomEx(128, 255), 60);
	PutPlayerInVehicle(playerid, Player[playerid][PlayerGokart], 0);
	SetPlayerCheckpoint(playerid, GoKartCheckpoints[0][0], GoKartCheckpoints[0][1], GoKartCheckpoints[0][2], 6);
	SetVehicleParamsEx(Player[playerid][PlayerGokart], 1, 1, 0, 0, 0, 0, 0);
	SendClientMessage(playerid, WHITE, "Operator says: Have fun! If you do enough laps I might have something for ya.");
	SendClientMessage(playerid, WHITE, "If you wish to leave the track use /leavetrack.");
	return 1;
}*/

CMD:leavetrack(playerid, params[])
{
	if(GetPVarInt(playerid, "InGoKartTrack") == 0)
		return SendClientMessage(playerid, WHITE, "You aren't in the go-kart track.");
	
	DestroyVehicle(Player[playerid][PlayerGokart]);
	DeletePVar(playerid, "InGoKartTrack");
	SetPlayerPos(playerid, 270.8087, -1780.4852, 4.5600);
	DisablePlayerCheckpoint(playerid);
	SendClientMessage(playerid, WHITE, "Operator: See ya later, homie.");
	return 1;
}

CMD:claimprize(playerid, params[])
{
	if(!IsPlayerInRangeOfPoint(playerid, 5.0, 265.9225, -1781.0068, 4.5600))
		return SendClientMessage(playerid, WHITE, "You aren't near the go-kart track operator.");
	
	if(Player[playerid][GokartPrizeReceived] == 1 || Player[playerid][GokartLapsDone] < 20)
		return SendClientMessage(playerid, WHITE, "You are unable to claim a prize at this time.");
		
	GiveGokartPrize(playerid);
	return 1;
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_ONFOOT && oldstate == PLAYER_STATE_DRIVER && GetPVarInt(playerid, "InGoKartTrack") == 1)
	{
		cmd_leavetrack(playerid, "");
		return 1;
	}
	return 1;
}

hook OnVehicleDeath(vehicleid, killerid)
{
	foreach(Player, i)
	{
		if(vehicleid == Player[i][PlayerGokart])
		{
			if(GetPVarInt(i, "InGoKartTrack") == 1)
				cmd_leavetrack(i, "");
			else 
				DestroyVehicle(Player[i][PlayerGokart]);
		}
	}
	return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	if(IsValidVehicle(Player[playerid][PlayerGokart]))
		DestroyVehicle(Player[playerid][PlayerGokart]);
	return 1;
}

hook OnPlayerEnterCheckpoint(playerid)
{
	if(GetPVarInt(playerid, "InGoKartTrack") == 1)
	{
		new step = GetPVarInt(playerid, "GoKartTrackStep") + 1;
		
		if(step == 8)
		{
			step = 0;
			Player[playerid][GokartLapsDone]++;
			
			if(Player[playerid][GokartLapsDone] == 5 || Player[playerid][GokartLapsDone] == 10 || Player[playerid][GokartLapsDone] == 15)
			{
				format(string, sizeof(string), "Operator says: Nice homie! You've done %d laps. Here is something for the effort.", Player[playerid][GokartLapsDone]);
				SendClientMessage(playerid, WHITE, string);
				SendClientMessage(playerid, WHITE, "The operator has given you a firework.");
				Player[playerid][pFireworks] ++;
			}
			
			SetVehicleHealth(Player[playerid][PlayerGokart], 1000);
			
			if(Player[playerid][GokartLapsDone] == 20)
			{
				format(string, sizeof(string), "Operator says: Nice homie! You've done %d laps. Here is something extra special for the effort.", Player[playerid][GokartLapsDone]);
				SendClientMessage(playerid, WHITE, string);
				GiveGokartPrize(playerid);
			}
		}
		
		SetPVarInt(playerid, "GoKartTrackStep", step);
		SetPlayerCheckpoint(playerid, GoKartCheckpoints[step][0], GoKartCheckpoints[step][1], GoKartCheckpoints[step][2], 6);
	}
	return 1;
}

static stock GiveGokartPrize(playerid)
{
	new slot = GetAvailableToySlot(playerid);	
	if(slot == -1)
	{
		SendClientMessage(playerid, WHITE, "You don't have enough toy slots available to receive the parrot toy.");
		SendClientMessage(playerid, WHITE, "Delete one toy and do /claimprize at the operator to receive it.");
		return 1;
	}
	
	Player[playerid][GokartPrizeReceived] = 1;
	PlayerToys[playerid][ToyModelID][slot] = PARROT_OBJECT_ID;
	SavePlayerData(playerid);
	SendClientMessage(playerid, GREEN, "You won a special toy item for completing 20 laps of the go-kart track!");
	return 1;
}

static stock GetPlayersInTrack()
{
	new count;
	foreach(Player, i)
	{
		if(GetPVarInt(i, "InGoKartTrack") == 1)
			count++;
	}
	return count;
}	

//Fireworks

CMD:buyfirework(playerid, params[])
{
	if(!IsPlayerInRangeOfPoint(playerid, 5.0, FIREWORK_ACTOR_X, FIREWORK_ACTOR_Y, FIREWORK_ACTOR_Z))
		return SendClientMessage(playerid, WHITE, "Who are you trying to buy fireworks from? You are not near the firework vendor.");
	
	if(Player[playerid][Money] < FIREWORK_PRICE)
	{
		format(string, sizeof(string), "Vendor whispers: Yo man, you trying to scam me? I need at least %s or no deal.", PrettyMoney(FIREWORK_PRICE));
		return SendClientMessage(playerid, WHITE, string);
	}
	
	if(Player[playerid][pFireworks] >= MAX_FIREWORKS_PER_PLAYER)
	{
		format(string, sizeof(string), "Vendor whispers: You got plenty of fireworks already man. You trying to get arrested?", PrettyMoney(FIREWORK_PRICE));
		return SendClientMessage(playerid, WHITE, string);
	}
	
	Player[playerid][pFireworks] ++;
	Player[playerid][Money] -= FIREWORK_PRICE;
	SendClientMessage(playerid, WHITE, "Vendor whispers: Here you go man. You didn't get this from me, alright?");
	format(string, sizeof(string), "[FIREWORKS] %s has purchased a firework.", GetName(playerid));
	StatLog(string);
	return 1;
}

CMD:launchfirework(playerid, params[])
{
	if(Player[playerid][pFireworks] < 1)
		return SendClientMessage(playerid, WHITE, "You don't have any fireworks to launch.");
		
	if(CantUseRightNow(playerid))
		return SendClientMessage(playerid, WHITE, "You can't launch a firework right now you nutjob.");
		
	if(GetPlayerVirtualWorld(playerid) != 0)
		return SendClientMessage(playerid, WHITE, "There is no way you can launch this inside. (Or outside of virtual world 0)");
	
	Player[playerid][pFireworks] --;
	new id = CreateFirework(playerid, 3000, RandomEx(25, 45), random(15), random(4), random(4) + 1);
	
	switch(random(100))
	{
		case 0:
		{
			DestroyObject(Fireworks[id][fwObject][0]);
			DestroyObject(Fireworks[id][fwObject][1]);
			CreateExplosion(Fireworks[id][fwPos][0], Fireworks[id][fwPos][1] + Fireworks[id][fwAngle], Fireworks[id][fwPos][2] + Fireworks[id][fwHeight], 12, 0.5);
			ResetFirework(id);
		}
		default:
		{
			SetTimerEx("FireworksTimer", 3000, false, "ii", id, 0);
		}
	}
	return 1;
}