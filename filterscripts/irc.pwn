#include <a_samp>
#include <irc>
#include <sscanf2>
#include <dini>
#include <foreach>
#include <YSI\y_timers>

#define IRC_FILE "IRC_Config.ini"

#define BOT_MAIN_NICKNAME dini_Get(IRC_FILE, "IRC_NICKNAME")
#define BOT_ALTERNATE_NICKNAME dini_Get(IRC_FILE, "IRC_NICKNAME2")
#define BOT_REALNAME dini_Get(IRC_FILE, "IRC_REALNAME")
#define BOT_USERNAME dini_Get(IRC_FILE, "IRC_USERNAME")
#define IRC_SERVER dini_Get(IRC_FILE, "IRC_IP")
#define IRC_PORT dini_Int(IRC_FILE, "IRC_PORT")
#define IRC_PASSWORD dini_Get(IRC_FILE, "IRC_PASSWORD")
#define IRC_CHANNEL dini_Get(IRC_FILE, "IRC_CHANNEL")

#define		ADMINBLUE		0xB3D0FFAA

new groupID, BOT_ID, RunningCMD;

public OnFilterScriptInit()
{
	BOT_ID = IRC_Connect(IRC_SERVER, IRC_PORT, BOT_MAIN_NICKNAME, BOT_REALNAME, BOT_USERNAME, .serverpassword = IRC_PASSWORD);
	IRC_SetIntData(BOT_ID, E_IRC_CONNECT_DELAY, 5);
	
	groupID = IRC_CreateGroup();
	return 1;
}

public OnFilterScriptExit()
{
	IRC_Quit(BOT_ID, "Filterscript exiting");
	IRC_DestroyGroup(groupID);
	return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	return 0;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	return 0;
}

public OnPlayerEditObject(playerid, playerobject, objectid, response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ)
{
	return 0;
}

public OnPlayerEditAttachedObject(playerid, response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ)
{
	return 0;
}

public IRC_OnConnect(botid, ip[], port)
{
	IRC_JoinChannel(botid, IRC_CHANNEL);
	IRC_AddToGroup(groupID, botid);
	return 1;
}

public IRC_OnDisconnect(botid, ip[], port, reason[])
{
	IRC_RemoveFromGroup(groupID, botid);
	return 1;
}

public IRC_OnKickedFromChannel(botid, channel[], oppeduser[], oppedhost[], message[])
{
	IRC_JoinChannel(botid, channel);
	return 1;
}

public IRC_OnUserSay(botid, recipient[], user[], host[], message[])
{
	if(botid != BOT_ID)
		return 1;
		
	// if(IRC_IsVoice(botid, IRC_CHANNEL, user) != 1)
		// return 1;
		
	if(message[0] != '+' || (message[1] != 'a' &&  message[1] != 'A'))
		return 1;
		
	strdel(message, 0, 3);
		
	new string[128], splitpos = 110 - (7 + strlen(user));
	if(strlen(message) > splitpos)
	{
		new str1[100], str2[100], tmp[255];
		strcpy(tmp, message, sizeof(tmp));
		strsplit(tmp, str1, str2, splitpos);
		format(string, sizeof(string), "[IRC] {0062FF}%s{B3D0FF}: %s", user, str1);
		SendToAdmins(ADMINBLUE, string);
		format(string, sizeof(string), "[IRC] {0062FF}%s{B3D0FF}: %s", user, str2);
		SendToAdmins(ADMINBLUE, string);
	}
	else
	{
		format(string, sizeof(string), "[IRC] {0062FF}%s{B3D0FF}: %s", user, message);
		SendToAdmins(ADMINBLUE, string);
	}
	
	format(string, sizeof(string), "[IRC] %s: %s", user, message);
	OOCChatLog(string);
	return 1;
}

public IRC_OnUserJoinChannel(botid, channel[], user[], host[])
{
	new string[128];
	format(string, sizeof(string), "%s has connected to the IRC channel.", user);
	SendToAdmins(0xF6970CAA, string);
	return 1;
}

public IRC_OnUserDisconnect(botid, user[], host[], message[])
{
	new string[128];
	format(string, sizeof(string), "%s has disconnected from the IRC channel. (%s)", user, message);
	SendToAdmins(0xF6970CAA, string);
	return 1;
}

public IRC_OnReceiveNumeric(botid, numeric, message[])
{
	if (numeric >= 400 && numeric <= 599)
	{
		const ERR_NICKNAMEINUSE = 433;
		if (numeric == ERR_NICKNAMEINUSE)
		{
			if (botid == BOT_ID)
			{
				IRC_ChangeNick(botid, BOT_ALTERNATE_NICKNAME);
			}
		}
	}
	return 1;
}

public IRC_OnReceiveRaw(botid, message[])
{
	new File:file;
	if (!fexist("irc_log.txt"))
	{
		file = fopen("irc_log.txt", io_write);
	}
	else
	{
		file = fopen("irc_log.txt", io_append);
	}
	if (file)
	{
		fwrite(file, message);
		fwrite(file, "\r\n");
		fclose(file);
	}
	return 1;
}

stock SendToAdmins(colour, string[])
{
	foreach(Player, i)
	{
		if(GetPVarInt(i, "AdminLevel") < 1)
			continue;
			
		SendClientMessage(i, colour, string);
	}
	return 1;
}

stock OOCChatLog(string[])
{
	new entry[255], year, month, day, hour, minute, second;
	gettime(hour, minute, second);
	getdate(year, month, day);
	format(entry, sizeof(entry), "[%d/%d/%d %02d:%02d:%02d] -- %s\r\n", month, day, year, hour, minute, second, string);
	new File:hFile;
	hFile = fopen("Logs/OOCChat.log", io_append);
	
	//if(!hFile)
	//	return printEx("*** OOCChatLog failed to open file.");
	
	fwrite(hFile, entry);
	fclose(hFile);
	return 1;
}

stock strsplit(source[], string1[], string2[], split_pos, maxlength = sizeof(source))
{
	new found_space;
	strmid(string1, source, 0, split_pos, maxlength);
	for(new i = strlen(string1); i > 0; i--)
	{
		if(string1[i] == ' ')
		{
			found_space = 1;
			string1[i] = '\0';
			split_pos = i+1; //split_pos is now at the position of the space (' ') where string1 was cut at.
			break;
		}
	}
	if(!found_space)
	{
		string1[90] = '\0';
		split_pos = 90;
	}
	strmid(string2, source, split_pos, strlen(source), maxlength);
	return 1;
}

forward IRC_Message(string[]);
public IRC_Message(string[])
{
	return IRC_GroupSay(groupID, IRC_CHANNEL, string);
}

forward IRC_PrivateMessage(user[], string[]);
public IRC_PrivateMessage(user[], string[])
{
	return IRC_GroupSay(groupID, user, string);
}

IRCCMD:listonline(botid, channel[], user[], host[], params[])
{
	if(botid != BOT_ID)
		return 1;

	// if(IRC_IsVoice(botid, IRC_CHANNEL, user) != 1)
		// return 1;
		
	if(RunningCMD)
		return 1;
		
	RunningCMD = 1;
	defer CommandTimer();
	IRC_GroupSay(groupID, IRC_CHANNEL, "------------- ONLINE ADMINS -------------");
	new string[128], playercount;
	foreach(Player, i)
	{
		playercount++;
		if(GetPVarInt(i, "AdminLevel") == 0)
			continue;
			
		new name[25];
		GetPVarString(i, "AdminName", name, 25);
		
		format(string, sizeof(string), "03%s (%d) %s admin duty / %s mod duty", name, GetPVarInt(i, "AdminLevel"), (GetPVarInt(i, "AdminDuty") > 0) ? ("on") : ("off"), (GetPVarInt(i, "AdminLevel") == 1 || GetPVarInt(i, "AdminLevel") == 2 || GetPVarInt(i, "ModStatus") > 0) ? ("on") : ("off"));
		
		IRC_GroupSay(groupID, IRC_CHANNEL, string);
	}
	format(string, sizeof(string), "PLAYERS ONLINE: %d", playercount);
	IRC_GroupSay(groupID, IRC_CHANNEL, string);
	IRC_GroupSay(groupID, IRC_CHANNEL, "--------------------------------------------------");

	return 1;
}

IRCCMD:lockcreation(botid, channel[], user[], host[], params[])
{
	if(botid != BOT_ID)
		return 1;
		
	if(CallRemoteFunction("PlayerCreationStatus", "") == 1)
		return IRC_GroupSay(groupID, IRC_CHANNEL, "04Player creation is already disabled!");
	
	CallRemoteFunction("TogglePlayerCreation", "d", 1);
	SendToAdmins(-1, "Player creation is now disabled!! (locked via IRC)");
	IRC_GroupSay(groupID, IRC_CHANNEL, "04Player creation is now disabled!");
	return 1;
}

IRCCMD:unlockcreation(botid, channel[], user[], host[], params[])
{
	if(botid != BOT_ID)
		return 1;
		
	if(CallRemoteFunction("PlayerCreationStatus", "") == 0)
		return IRC_GroupSay(groupID, IRC_CHANNEL, "03Player creation is already enabled!");
	
	CallRemoteFunction("TogglePlayerCreation", "d", 0);
	SendToAdmins(-1, "Player creation is now enabled!! (unlocked via IRC)");
	IRC_GroupSay(groupID, IRC_CHANNEL, "03Player creation is now enabled!");
	return 1;
}

IRCCMD:searchip(botid, channel[], user[], host[], params[])
{
	if(botid != BOT_ID)
		return 1;

	// if(IRC_IsVoice(botid, IRC_CHANNEL, user) != 1)
		// return 1;
		
	if(RunningCMD)
		return 1;
	
	RunningCMD = 1;
	defer CommandTimer();
		
	new query[128];
	IRC_GroupSay(groupID, IRC_CHANNEL, "------------------------------------------------------------");
	format(query, sizeof(query), "The following names have connected on an IP starting with %s:", params);
	IRC_GroupSay(groupID, IRC_CHANNEL, query);
	
	CallRemoteFunction("IRC_SearchIP", "s", params);
	
	IRC_GroupSay(groupID, IRC_CHANNEL, "------------------------------------------------------------");
	return 1;
}

IRCCMD:searchname(botid, channel[], user[], host[], params[])
{
	if(botid != BOT_ID)
		return 1;

	// if(IRC_IsVoice(botid, IRC_CHANNEL, user) != 1)
		// return 1;
		
	if(RunningCMD)
		return 1;
	
	if(!CallRemoteFunction("IsPlayerRegistered", "s", params))
		return IRC_GroupSay(groupID, IRC_CHANNEL, "No such player name.");
	
	RunningCMD = 1;
	defer CommandTimer();
		
	new query[128];
	IRC_GroupSay(groupID, IRC_CHANNEL, "------------------------------------------------------------");
	format(query, sizeof(query), "%s has connected on the following IP's:", params);
	IRC_GroupSay(groupID, IRC_CHANNEL, query);
	
	CallRemoteFunction("IRC_SearchName", "s", params);
	
	IRC_GroupSay(groupID, IRC_CHANNEL, "------------------------------------------------------------");
	return 1;
}

IRCCMD:a(botid, channel[], user[], host[], params[])
{
	if(botid != BOT_ID)
		return 1;

	// if(IRC_IsVoice(botid, IRC_CHANNEL, user) != 1)
		// return 1;
		
	if(RunningCMD)
		return 1;
		
	new string[128], splitpos = 110 - (7 + strlen(user));
	if(strlen(params) > splitpos)
	{
		new str1[100], str2[100], tmp[255];
		strcpy(tmp, params, sizeof(tmp));
		strsplit(tmp, str1, str2, splitpos);
		format(string, sizeof(string), "[IRC] {0062FF}%s{B3D0FF}: %s", user, str1);
		SendToAdmins(ADMINBLUE, string);
		format(string, sizeof(string), "[IRC] {0062FF}%s{B3D0FF}: %s", user, str2);
		SendToAdmins(ADMINBLUE, string);
	}
	else
	{
		format(string, sizeof(string), "[IRC] {0062FF}%s{B3D0FF}: %s", user, params);
		SendToAdmins(ADMINBLUE, string);
	}
	
	format(string, sizeof(string), "[IRC] %s: %s", user, params);
	OOCChatLog(string);
	return 1;
}

IRCCMD:rotatelogs(botid, channel[], user[], host[], params[])
{
	if(botid != BOT_ID)
		return 1;

	if(RunningCMD)
		return 1;
	
	CallRemoteFunction("RotateLogsRemote", "");
	
	new string[128];
	format(string, sizeof(string), "[IRC] %s has rotated the logs.", user);
	SendToAdmins(0xFF8080FF, string); //0xFF8080FF = LIGHTRED
	IRC_GroupSay(groupID, IRC_CHANNEL, "The logs have been rotated.");
	return 1;
}

IRCCMD:pcreate(botid, channel[], user[], host[], params[])
{
	if(botid != BOT_ID)
		return 1;
		
	if(RunningCMD)
		return 1;
	
	if(isnull(params))
		return IRC_PrivateMessage(user, "Invalid name (Empty)");
		
	if(strlen(params) > 24)
		return IRC_PrivateMessage(user, "Invalid name (Too long)");
	
	CallRemoteFunction("IRC_AccountCreate", "ss", user, params);
	return 1;
}

timer CommandTimer[10000]()
{
	return RunningCMD = 0;
}