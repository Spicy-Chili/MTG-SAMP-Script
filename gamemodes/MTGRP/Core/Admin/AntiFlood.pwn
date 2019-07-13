/*
#		MTG Anti-Flood System (Bot attacks, Max connections per IP)
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

#define MAX_CONNECTIONS			5
#define AUTO_BAN_TIME			500 //Time in milliseconds between connects that will trigger an auto-ban warning
#define MAX_TIME_WARNINGS		3	//Max amount of times an IP can trigger a warning before being banned

static string[64];

hook OnPlayerConnect(playerid)
{
	new ip[32];
	GetPlayerIp(playerid, ip, sizeof(ip));
	
	if(IsPlayerNPC(playerid))
	{
		//Anti NPC Bot flood attack
		if(strcmp(ip, "127.0.0.1", true)) 
		{
			format(string, sizeof(string), "banip %s", ip);
			SendRconCommand(string);
		}
	}
	
	new tick_count = GetTickCount();
	new interval = GetTickCountDifference(GetLastConnectionTime(ip), tick_count);
	
	if(interval < AUTO_BAN_TIME) //Anti-Flood attack
	{
		IncrementWarning(ip);
		
		if(GetWarningCount(ip) > MAX_TIME_WARNINGS)
		{
			format(string, sizeof(string), "banip %s", ip);
			SendRconCommand(string);
			format(string, sizeof(string), "[Anti-Flood] %s has been banned for flooding.", ip);
			BanLog(string);
		}
	}
	else ResetWarnings(ip);
	
	if(GetIPConnections(ip) > MAX_CONNECTIONS)
	{
		SendClientMessage(playerid, -1, "Your IP has reached the maximum allowed connections.");
		KickEx(playerid);
	}
	
	SetLastConnectionTime(ip, tick_count);
	return 1;
}	

stock abs(int)
{
        if(int < 0)
                return -int;
 
        return int;
}
 
stock intdiffabs(tick1, tick2)
{
        if(tick1 > tick2)
                return abs(tick1 - tick2);
 
        else
                return abs(tick2 - tick1);
}
 
stock GetTickCountDifference(a, b)
{
        if ((a < 0) && (b > 0))
        {
 
                new dist;
 
                dist = intdiffabs(a, b);
 
                if(dist > 2147483647)
                        return intdiffabs(a - 2147483647, b - 2147483647);
 
                else
                        return dist;
        }
 
        return intdiffabs(a, b);
}

static stock GetIPConnections(ip[])
{
	new pIP[16], count;
	foreach(Player, i)
	{
		GetPlayerIp(i, pIP, sizeof(pIP));
		if(!strcmp(pIP, ip, true))
			count++;
	}
	return count;
}

static stock ResetWarnings(ip[])
{
	format(string, sizeof(string), "%sWarnings", ip);
	DeleteSVar(string);
	return 1;
}

static stock IncrementWarning(ip[])
{
	format(string, sizeof(string), "%sWarnings", ip);
	SetSVarInt(string, GetWarningCount(ip) + 1);
	return 1;
}

static stock GetWarningCount(ip[]) 
{
	format(string, sizeof(string), "%sWarnings", ip);
	return GetSVarInt(string);
}

static stock SetLastConnectionTime(ip[], time) //Set an IP's last connection time
{
	format(string, sizeof(string), "%sTime", ip);
	SetSVarInt(string, time);
	return 1;
}

static stock GetLastConnectionTime(ip[]) //Get an IP's last connection time
{
	format(string, sizeof(string), "%sTime", ip);
	return GetSVarInt(string);
}