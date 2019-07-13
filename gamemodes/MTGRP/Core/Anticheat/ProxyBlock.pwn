/*
#		MTG Proxy Block
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

forward IPCheck(playerid, response_code, data[]);

static string[128];

// ============= Callbacks =============

hook OnPlayerConnect(playerid)
{
	new IP[16];
	GetPlayerIp(playerid, IP, sizeof(IP));
	
	if(strcmp(IP, "127.0.0.1", true))
	{
		format(string, sizeof(string), "www.shroomery.org/ythan/proxycheck.php?ip=%s", IP);
		HTTP(playerid, HTTP_GET, string, "", "IPCheck");
	}
}


public IPCheck(playerid, response_code, data[])
{
	if(response_code == 200)
	{
		if(!strcmp(data, "Y", true))
		{
			new IP[16];
			GetPlayerIp(playerid, IP, sizeof(IP));
			SendClientMessage(playerid, RED, "Proxy connections are not allowed on MTG.");
			KickEx(playerid);
			
			format(string, sizeof(string), "banip %s", IP);
			SendRconCommand(string);
			format(string, sizeof(string), "%s | IP Banned (Proxy) | Proxy Blocker", IP);
			BanLog(string);
			format(string, sizeof(string), "Ban: Proxy Blocker has banned IP %s.", IP);
			AdminActionsLog(string);
		}
	}
}