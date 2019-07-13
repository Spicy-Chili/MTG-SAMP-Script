/*
#		MTG Anti-AFK
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

static AFKCount[MAX_PLAYERS];
static string[128];

// ============= Timers =============

ptask AFKTimer[1000](i)
{
	new Float:x, Float:y, Float:z;
	new Float:oldX, Float:oldY;
	oldX = Player[i][oldXPos];
	oldY = Player[i][oldYPos];
	
	GetPlayerPos(i, x, y, z);
	
	if(Player[i][Authenticated] == 1)
	{
	
		if(x == oldX && y == oldY)
		{
			AFKCount[i]++;
		}	
		else 
		{
			AFKCount[i] = 0;
		}
	}
	
	if(AFKCount[i] == 540) //540 seconds = 10 minutes
	{
		SendClientMessage(i, COLOR_LIGHTBLUE, "You will be AFK kicked in 60 seconds!");
	}
	
	if(AFKCount[i] == 600) //600 seconds = 10 minutes
	{
		if(Player[i][AdminDuty] >= 1 && Player[i][AdminLevel] >= 4)
		{
			Player[i][AFKStat] = 1;
			SendClientMessage(i, WHITE, "Your status has been changed to AFK.");
			format(string, sizeof(string), "%s has been set to 'AFK' (system deemed inactivity).", GetName(i));
			SendToAdmins(ADMINORANGE, string, 0);
			format(string, sizeof(string), "[AFK] %s has been set to 'AFK' (system deemed inactivity).", GetName(i));
			WarningLog(string);
		}
		else 
		{
			Player[i][AFKKicked] = 1;
			Player[i][SystemAfkKicks]++;
			SavePlayerData(i);
			format(string, sizeof(string), "Kick: %s has been kicked by System. Reason: \"AFK\"", GetName(i));
			SendToAdmins(RED, string, 0);
			format(string, sizeof(string), "%s has been kicked by System. Reason: \"AFK\"", GetName(i));
			AdminActionsLog(string);
			SendClientMessage(i, WHITE, "You have been kicked from the server. Reason: \"AFK\"");
			KickEx(i);
		}
	}
	
	Player[i][oldXPos] = x;
	Player[i][oldYPos] = y;
	
	return 1;
}

// ============= Callbacks =============

hook OnPlayerDisconnect(playerid, reason)
{
	AFKCount[playerid] = 0;
}