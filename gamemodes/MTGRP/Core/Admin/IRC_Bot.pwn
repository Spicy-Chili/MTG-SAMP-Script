/*
#		MTG IRC channel bot
#		
#
#	By accessing this file, you agree to the following:
#		- You will never give the script or associated files to anybody who is not on the MTG SAMP development team
# 		- You will delete all development materials (script, databases, associated files, etc.) when you leave the MTG SAMP development team.
#
*/

#include <irc>
#include <YSI\y_hooks>
#include <YSI\y_timers>

new IRC_BOT, IRC_IP[32], IRC_PORT, IRC_NICKNAME[32], IRC_REALNAME[32], IRC_USERNAME[32], IRC_CHANNEL[32], CONNECT, Pinging = 0, RunningCMD = 0;

#define IRC_FILE "IRC_Config.ini"

hook OnGameModeInit()
{
	if(!fexist(IRC_FILE))
	{
		return print("[IRC] IRC Bot config has not been set up! The IRC bot will not connect.");
	}
	
	format(IRC_IP, sizeof(IRC_IP), "%s", dini_Get(IRC_FILE, "IRC_IP"));
	format(IRC_NICKNAME, sizeof(IRC_NICKNAME), "%s", dini_Get(IRC_FILE, "IRC_NICKNAME"));
	format(IRC_REALNAME, sizeof(IRC_REALNAME), "%s", dini_Get(IRC_FILE, "IRC_REALNAME"));
	format(IRC_USERNAME, sizeof(IRC_USERNAME), "%s", dini_Get(IRC_FILE, "IRC_USERNAME"));
	format(IRC_CHANNEL, sizeof(IRC_CHANNEL), "%s", dini_Get(IRC_FILE, "IRC_CHANNEL"));
	IRC_PORT = dini_Int(IRC_FILE, "IRC_PORT");
	CONNECT = dini_Int(IRC_FILE, "CONNECT");
	
	if(CONNECT == 1)
	{	
		IRC_BOT = IRC_Connect(IRC_IP, IRC_PORT, IRC_NICKNAME, IRC_REALNAME, IRC_USERNAME);
		// IRC_BOT = IRC_Connect("irc.freenode.net", 6667, "IN-GAME", "SAMP ADMIN", "SAMP IRC BOT");
		IRC_SetIntData(IRC_BOT, E_IRC_CONNECT_DELAY, 20);
		IRC_SetIntData(IRC_BOT, E_IRC_RESPAWN, 1);
	}
	return 1;
}

hook OnGameModeExit()
{
	if(IRC_BOT != 0)
		IRC_Quit(IRC_BOT, "Server went down.");
	return 1;
}

public IRC_OnUserSay(botid, recipient[], user[], host[], message[])
{
	if(botid != IRC_BOT)
		return 1;
		
	if(IRC_IsVoice(botid, IRC_CHANNEL, user) != 1)
		return 1;
		
	if(message[0] != '+' || message[1] != 'a')
		return 1;
		
	strdel(message, 0, 2);
		
	new string[128];
	format(string, sizeof(string), "[IRC] {0062FF}%s{B3D0FF}: %s", user, message);
	SendToAdmins(ADMINBLUE, string, 0);
	format(string, sizeof(string), "[IRC] %s: %s", user, message);
	OOCChatLog(string);
	return 1;
}

public IRC_OnConnectAttemptFail(botid, ip[], port, reason[])
{
	printf("[IRC] IRC_BOT(%d) failed to connect to %s:%d for reason \"%s\".", botid, ip, port, reason);
	return 1;
}

public IRC_OnConnect(botid, ip[], port)
{
	IRC_JoinChannel(botid, IRC_CHANNEL);
	return 1;
}

IRCCMD:listonline(botid, channel[], user[], host[], params[])
{
	if(botid != IRC_BOT)
		return 1;

	if(IRC_IsVoice(botid, IRC_CHANNEL, user) != 1)
		return 1;
		
	if(RunningCMD)
		return 1;
		
	RunningCMD = 1;
	defer CommandTimer();
	IRC_Say(botid, IRC_CHANNEL, "------------- ONLINE ADMINS -------------");
	foreach(Player, i)
	{
		if(Player[i][AdminLevel] == 0)
			continue;
			
		IRC_Say(botid, IRC_CHANNEL, Player[i][AdminName]);
	}
	IRC_Say(botid, IRC_CHANNEL, "--------------------------------------------------");

	return 1;
}

IRCCMD:searchip(botid, channel[], user[], host[], params[])
{
	if(botid != IRC_BOT)
		return 1;

	if(IRC_IsVoice(botid, IRC_CHANNEL, user) != 1)
		return 1;
		
	if(RunningCMD)
		return 1;
		
	new query[128], Cache:cache, count, idx, field[32], field2[32];
	mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT * FROM connections WHERE ip LIKE '%e%%'", params);
	cache = mysql_query(MYSQL_MAIN, query);
	count = cache_get_row_count();
	
	RunningCMD = 1;
	defer CommandTimer();
	IRC_Say(botid, IRC_CHANNEL, "------------------------------------------------------------");
	format(query, sizeof(query), "The following names have connected on an IP starting with %s:", params);
	IRC_Say(botid, IRC_CHANNEL, query);
	
	if(count == 0)
	{
		IRC_Say(botid, IRC_CHANNEL, "Nobody found.");
		IRC_Say(botid, IRC_CHANNEL, "------------------------------------------------------------");
		cache_delete(cache);
		return 1;
	}
	
	new field3[32];
	while(idx < count)
	{
		cache_get_field_content(idx, "name", field);
		cache_get_field_content(idx, "date", field2);
		cache_get_field_content(idx, "ip", field3);
		format(query, sizeof(query), "Name: %s - Connected on %s last: %s", field, field3, field2);
		IRC_Say(botid, IRC_CHANNEL, query);
		idx ++;
	}
	
	IRC_Say(botid, IRC_CHANNEL, "------------------------------------------------------------");
	cache_delete(cache);
		
	return 1;
}

IRCCMD:a(botid, channel[], user[], host[], params[])
{
	if(botid != IRC_BOT)
		return 1;

	if(IRC_IsVoice(botid, IRC_CHANNEL, user) != 1)
		return 1;
		
	if(RunningCMD)
		return 1;
		
	new string[128];
	format(string, sizeof(string), "[IRC] {0062FF}%s{B3D0FF}: %s", user, params);
	SendToAdmins(ADMINBLUE, string, 0);
	format(string, sizeof(string), "[IRC] %s: %s", user, params);
	OOCChatLog(string);
	return 1;
}

timer CommandTimer[10000]()
{
	return RunningCMD = 0;
}

task PingCheck[600 * 1000]()
{
	IRC_SendRaw(IRC_BOT, "Ping!");
	Pinging = 1;
	return 1;
}

public IRC_OnReceiveRaw(botid, message[])
{
	if(Pinging == 0)
		return 1;
		
	IRC_SendRaw(IRC_BOT, "Pong!");
	Pinging = 0;
	
	return 1;
}