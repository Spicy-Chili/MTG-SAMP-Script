/*
#		MTG MySQL
#		
#
#	By accessing this file, you agree to the following:
#		- You will never give the script or associated files to anybody who is not on the MTG SAMP development team
# 		- You will delete all development materials (script, databases, associated files, etc.) when you leave the MTG SAMP development team.
#
#
#
*/

#define THREAD_EDIT_HOUSE_KEY				1
#define THREAD_CONTRACT_PLAYER_CHECK		2
#define THREAD_CONTRACT_PLAYER_UPDATE		3
#define THREAD_CHANGE_PASSWORD				4
#define THREAD_PLAYER_NOTE					5
#define THREAD_REMOTE_AW					6
#define THREAD_FACTION_REMOTE_UNINVITE		7
#define THREAD_REMOTE_FINE					8
#define THREAD_REMOTE_PRISON				9
#define THREAD_REMOTE_SET_GENDER			10
#define THREAD_REMOTE_SET					11
#define THREAD_REMOTE_BAN					12
#define THREAD_REMOTE_WARN					13
#define THREAD_REMOTE_WARN_BAN				14
#define THREAD_UNBAN						15
#define THREAD_ASELLHOUSE					16
#define THREAD_ASELLBUSINESS				17
#define THREAD_REMOTE_WIRETRANSFER			18
#define THREAD_REMOTE_VIP_LEVEL				19
#define THREAD_REMOTE_TEMPBAN				20
#define THREAD_REMOTE_CHANGE_ADMINLEVEL		21
#define THREAD_REMOTE_CHANGE_FACTION_RANK	22
#define THREAD_RESET_PIN					23
#define THREAD_REMOTE_FINE_TOKENS			24
#define THREAD_REMOTE_FINE_BANK				25
#define THREAD_REMOTE_AVOID					26
#define THREAD_REMOTE_RESET_WARN			27
#define THREAD_REMOTE_RESET_WARNS			28
#define THREAD_REMOTESET_HOTELROOM			29
#define THREAD_RESET_PASSWORD				30
#define THREAD_EDIT_BUSINESS_KEY 			31

forward IsPlayerRegistered(name[]);

forward OnQueryFinish(thread, playerid, extra, extraString[], extraString2[]);
public OnQueryFinish(thread, playerid, extra, extraString[], extraString2[])
{
	new string[128], query[1024];
	switch(thread)
	{
		case THREAD_EDIT_HOUSE_KEY:
		{
			format(string, sizeof(string), "You have successfully changed %s's house key to %d.", extraString, extra);
			SendClientMessage(playerid, WHITE, string);
		}
		case THREAD_CONTRACT_PLAYER_CHECK:
		{
			if(!cache_get_row_count())
				return SendClientMessage(playerid, WHITE, "An error occured while placing your contract.");
			
			cache_get_field_content(0, "Contract", string);
			
			if(strcmp(string, "None", true) && strcmp(string, "", true))
				return SendClientMessage(playerid, WHITE, "You can't place that right now.");
			
			new reason[255];
			format(reason, sizeof(reason), "%s (from %s)", Player[playerid][PendingReason], GetName(playerid));
			
			mysql_format(MYSQL_MAIN, query, sizeof(query), "UPDATE playeraccounts SET Contract = '%e', Contract2 = '%e', ContractPrice = '%d' WHERE NormalName = '%e'", reason,  Player[playerid][PendingReason2], Player[playerid][PendingPrice], Player[playerid][PendingContract]);
			mysql_tquery(MYSQL_MAIN, query, "OnQueryFinish", "dddss", THREAD_CONTRACT_PLAYER_UPDATE, playerid, Player[playerid][PendingPrice], Player[playerid][PendingContract], "");
		}
		case THREAD_CONTRACT_PLAYER_UPDATE:
		{
			format(string, sizeof(string), "You have placed a contract on %s for %s. ((user is offline))", Player[playerid][PendingContract], PrettyMoney(Player[playerid][PendingPrice]));
			SendClientMessage(playerid, WHITE, string);
			
			format(string, sizeof(string), "[CONTRACT] %s has placed a contract on %s for %s.", GetName(playerid), Player[playerid][PendingContract], PrettyMoney(Player[playerid][PendingPrice]));
			StatLog(string);

			format(string, sizeof(string), "%s has requested a hit on %s for %s.", GetName(playerid), Player[playerid][PendingContract], PrettyMoney(Player[playerid][PendingPrice]));
			foreach(Player, i)
			{
				if(Groups[Player[i][Group]][CommandTypes] == 2)
					SendClientMessage(i, ANNOUNCEMENT, string);
			}

			Player[playerid][Money] -= Player[playerid][PendingPrice];
			Player[playerid][PendingPrice] = 5000;
			format(Player[playerid][PendingContract], 255, "Nobody");
			format(Player[playerid][PendingReason], 255, "Nothing");
			format(Player[playerid][PendingReason2], 255, "Nothing");
		}
		case THREAD_CHANGE_PASSWORD:
		{
			format(string, sizeof(string), "You have changed %s's password to %s.", extraString, extraString2);
			SendClientMessage(playerid, WHITE, string);
		}
		case THREAD_PLAYER_NOTE:
		{			
			format(string, sizeof(string), "%s has set %s's offline note to %s.", GetName(playerid), extraString, extraString2);
			AdminActionsLog(string);
			
			format(string, sizeof(string), "You have set %s's note to %s.", extraString, extraString2);
			SendClientMessage(playerid, WHITE, string);
		}
		case THREAD_REMOTE_AW:
		{
			format(string, sizeof(string), "%s has been remote warped to newbie spawn by %s.", extraString, GetName(playerid));
			AdminActionsLog(string);
			
			format(string, sizeof(string), "You have remote admin-warped %s to newbie spawn.", extraString);
			SendClientMessage(playerid, WHITE, string); 
		}
		case THREAD_FACTION_REMOTE_UNINVITE:
		{
			format(string, sizeof(string), "%s has left the group (remotely un-invited)", extraString);
			GroupMessage(playerid, ANNOUNCEMENT, string);
			format(string, sizeof(string), "[GROUP] %s (%d) has remoteuninvited %s from %s.", GetName(playerid), Player[playerid][GroupRank], extraString, Groups[Player[playerid][Group]][GroupName]);
			StatLog(string);
		}
		case THREAD_REMOTE_FINE:
		{
			format(string, sizeof(string), "Fine: %s has been remotefined $%s by %s. Defined reason: \"%s\".", extraString, IntToFormattedStr(extra), Player[playerid][AdminName], extraString2);
			SendToAdmins(ADMINORANGE, string, 0);
			AdminActionsLog(string);
			Player[playerid][AdminActions]++;
			format(string, sizeof(string), "You have successfully fined %s for $%s because of %s.", extraString, IntToFormattedStr(extra), extraString2);
			SendClientMessage(playerid, WHITE, string);
		}
		case THREAD_REMOTE_PRISON:
		{	
			if(extra == 0)
			{
				format(string, sizeof(string), "%s has been remotely released from prison by %s. Define reason: \"%s\".", extraString, Player[playerid][AdminName], extraString2);
				SendToAdmins(ADMINORANGE, string, 0);
				AdminActionsLog(string);
				format(string, sizeof(string), "You have successfully remotely released %s from prison because of \"%s\".", extraString, extraString2);
				SendClientMessage(playerid, WHITE, string);
			}
			else
			{
				format(string, sizeof(string), "%s has been remoteprisoned by %s for %d minutes. Defined reason: \"%s\".", extraString, Player[playerid][AdminName], extra, extraString2);
				SendToAdmins(ADMINORANGE, string, 0);
				AdminActionsLog(string);
				format(string, sizeof(string), "You have successfully remoteprisoned %s for %d minutes because of \"%s\".", extraString, extra, extraString2);
				SendClientMessage(playerid, WHITE, string);
			}
			Player[playerid][AdminActions]++;
		}
		case THREAD_REMOTE_SET_GENDER:
		{
			format(string, sizeof(string), "%s has remotely set %s gender to %s.", Player[playerid][AdminName], extraString, (extra == 1) ? ("Male") : ("Female"));
			AdminActionsLog(string);
			format(string, sizeof(string), "%s has remotely set %s gender to %s (was %s).", Player[playerid][AdminName], extraString, (extra == 1) ? ("Male") : ("Female"), extraString2);
			StatLog(string);
			format(string, sizeof(string), "You have remotely set %s gender to %s.", extraString, (extra == 1) ? ("Male") : ("Female"));
			SendClientMessage(playerid, WHITE, string);
		}
		case THREAD_REMOTE_SET:
		{
			format(string, sizeof(string), "%s has remotely set %s's %s to %d (was %d).", Player[playerid][AdminName], extraString, extraString2, extra, GetPVarInt(playerid, "THREAD_REMOTE_SET_OLD_VALUE"));
			StatLog(string);
			format(string, sizeof(string), "You have remotely set %s %s to %d.", extraString, extraString2, extra);
			SendClientMessage(playerid, WHITE, string);
			DeletePVar(playerid, "THREAD_REMOTE_SET_OLD_VALUE");
		}
		case THREAD_REMOTE_BAN:
		{
			new IP[21];
			format(IP, sizeof(IP), GetRemoteStringValue(extraString, "LastIP"));
			format(string, sizeof(string), "%s | %s | Banned for \"%s\" | %s", extraString, IP, extraString2, Player[playerid][AdminName]);
			BanLog(string);
			
			Player[playerid][AdminActions]++;
			format(string, sizeof(string), "Ban: %s has remotebanned %s. Defined reason: \"%s\".", Player[playerid][AdminName], extraString, extraString2);
			AdminActionsLog(string);
			SendToAdmins(ADMINORANGE, string, 0);
			LogLastBan(extraString, IP);
			
			format(string, sizeof(string), "You have successfully remotebanned %s for \"%s\".", extraString, extraString2);
			SendClientMessage(playerid, WHITE, string);
		}
		case THREAD_REMOTE_WARN:
		{
			InsertWarnIntoHistory(playerid, GetRemoteIntValue(extraString, "SQLID"), extraString, extraString2, GetRemoteIntValue(extraString, "TempbanLevel"));
			switch(extra)
			{
				case 1:
				{
					format(string, sizeof(string), "%s has remotewarned %s for \"%s\". This is their first warning.", Player[playerid][AdminName], extraString, extraString2);
					SendToAdmins(ADMINORANGE, string, 0);
					format(string, sizeof(string), "%s has remotewarned %s for \"%s\". This is their first warning.", Player[playerid][AdminName], extraString, extraString2);
					AdminActionsLog(string);
					format(string, sizeof(string), "You have successfully warned %s for \"%s\". This is their first warning.", extraString, extraString2);
					SendClientMessage(playerid, WHITE, string);
					
				}
				case 2:
				{
					format(string, sizeof(string), "%s has remotewarned %s for \"%s\". This is their second warning.", Player[playerid][AdminName], extraString, extraString2);
					SendToAdmins(ADMINORANGE, string, 0);
					format(string, sizeof(string), "%s has remotewarned %s for \"%s\". This is their second warning.", Player[playerid][AdminName], extraString, extraString2);
					AdminActionsLog(string);
					format(string, sizeof(string), "You have successfully warned %s for \"%s\". This is their second warning.", extraString, extraString2);
					SendClientMessage(playerid, WHITE, string);
				}
				case 3:
				{
					format(string, sizeof(string), "%s has remotewarned %s for \"%s\". This is their third warning.", Player[playerid][AdminName], extraString, extraString2);
					SendToAdmins(ADMINORANGE, string, 0);
					format(string, sizeof(string), "%s has remotewarned %s for \"%s\". This is their third warning.", Player[playerid][AdminName], extraString, extraString2);
					AdminActionsLog(string);
					format(string, sizeof(string), "You have successfully warned %s for \"%s\". This is their third warning.", extraString, extraString2);
					SendClientMessage(playerid, WHITE, string);
					
					new IP[21];
					format(IP, sizeof(IP), GetRemoteStringValue(extraString, "LastIP"));
					new tempban = GetRemoteIntValue(extraString, "TempbanLevel");
					tempban ++;

					if(tempban < 3)
					{
						format(string, sizeof(string), "%s | %s | Third warning (\"%s\") (Tempban #%d) | %s", extraString, IP, extraString2, tempban, Player[playerid][AdminName]);
						BanLog(string);
						format(string, sizeof(string), "Ban: %s has been tempbanned by %s. Defined reason: Third warning (\"%s\") (Tempban #%d)", extraString, Player[playerid][AdminName], extraString2, tempban);
						SendToAdmins(ADMINORANGE, string, 0);
						format(string, sizeof(string), "%s has been tempbanned by %s. Defined reason: Third warning (\"%s\") (Tempban #%d)", extraString, Player[playerid][AdminName], extraString2, tempban);
						AdminActionsLog(string);
						
						format(string, sizeof(string), "Third warning (%s) (Tempban #%d)", extraString2, tempban);
						mysql_format(MYSQL_MAIN, query, sizeof(query), "UPDATE playeraccounts SET Banned = '3', TempbanTime = '%d', BannedReason = '%e', BannedBy = '%e', TempbanLevel = '%d' WHERE NormalName = '%e'", (gettime() + (259200 * tempban)), string, Player[playerid][AdminName], tempban, extraString);
						mysql_tquery(MYSQL_MAIN, query, "OnQueryFinish", "dddss", THREAD_REMOTE_WARN_BAN, playerid, 3, extraString, extraString2);
					}
					else
					{
						format(string, sizeof(string), "%s | %s | Third warning (\"%s\") (Tempban #%d) | %s", extraString, IP, extraString2, tempban, Player[playerid][AdminName]);
						BanLog(string);
						format(string, sizeof(string), "Ban: %s has been banned by %s. Defined reason: Third warning (\"%s\") (Tempban #%d)", extraString, Player[playerid][AdminName], extraString2, tempban);
						SendToAdmins(ADMINORANGE, string, 0);
						format(string, sizeof(string), "%s has been banned by %s. Defined reason: Third warning (\"%s\") (Tempban #%d)", extraString, Player[playerid][AdminName], extraString2, tempban);
						AdminActionsLog(string);
						
						format(string, sizeof(string), "Third warning (%s) (Tempban #%d)", extraString2, tempban);
						mysql_format(MYSQL_MAIN, query, sizeof(query), "UPDATE playeraccounts SET Banned = '1', BannedReason = '%e', BannedBy = '%e', TempbanLevel = '%d' WHERE NormalName = '%e'", string, Player[playerid][AdminName], tempban, extraString);
						mysql_tquery(MYSQL_MAIN, query, "OnQueryFinish", "dddss", THREAD_REMOTE_WARN_BAN, playerid, 1, extraString, extraString2);			
					}
				}
			}
			Player[playerid][AdminActions]++;
		}
		case THREAD_REMOTE_WARN_BAN:
		{
			switch(extra)
			{
				case 3: 
				{
					format(string, sizeof(string), "You have successfully tempbanned %s for %s.", extraString, extraString2);
				}
				default: format(string, sizeof(string), "You have successfully banned %s for %s.", extraString, extraString2);
			}
			Player[playerid][AdminActions]++;
			SendClientMessage(playerid, WHITE, string);
		}
		case THREAD_UNBAN:
		{
			format(string, sizeof(string), "WARNING: %s has unbanned %s.", Player[playerid][AdminName], extraString);
			SendToAdmins(ADMINORANGE, string, 0);
			format(string, sizeof(string), "%s | Player unbanned | %s", extraString, Player[playerid][AdminName]);
			UnbanLog(string);
			format(string, sizeof(string), "Unban: %s has unbanned %s.", Player[playerid][AdminName], extraString);
			AdminActionsLog(string);
			format(string, sizeof(string), "You have successfully unbanned %s.", extraString);
			SendClientMessage(playerid, WHITE, string);
			Player[playerid][AdminActions]++;
		}
		case THREAD_ASELLHOUSE:
		{
			format(string, sizeof(string), "Successfully set House%d to 0 for player %s.", extra, extraString);
			SendClientMessage(playerid, WHITE, string);
		}
		case THREAD_ASELLBUSINESS:
		{
			format(string, sizeof(string), "Successfully set business to 0 for player %s.", extraString);
			SendClientMessage(playerid, WHITE, string);
		}
		case THREAD_REMOTE_WIRETRANSFER:
		{
			format(string, sizeof(string), "WARNING: %s has remotewiretransferred $%s to %s.", GetName(playerid), IntToFormattedStr(extra), extraString);
			SendToAdmins(ADMINORANGE, string, 0);
			WarningLog(string);
			format(string, sizeof(string), "[WIRETRANSFER] %s has remotewiretransferred $%s ($%s) to %s ($%s).", GetName(playerid), IntToFormattedStr(extra), IntToFormattedStr(Groups[Player[playerid][Group]][SafeMoney] - extra), extraString, IntToFormattedStr(GetRemoteIntValue(extraString, "BankMoney") + extra));
			MoneyLog(string);
			format(string, sizeof(string), "You have remotewiretransferred $%s to %s.", IntToFormattedStr(extra), extraString);
			SendClientMessage(playerid, WHITE, string);
		}
		case THREAD_REMOTE_VIP_LEVEL:
		{
			format(string, sizeof(string), "%s has remotely set %s VIP rank to %d.", Player[playerid][AdminName], extraString, extra);
			AdminActionsLog(string);
			format(string, sizeof(string), "You have successfully remotely set %s VIP rank to %d.", extraString, extra);
			SendClientMessage(playerid, WHITE, string);
		}
		case THREAD_REMOTE_TEMPBAN:
		{
			format(string, sizeof(string), "%s | %s | Tempbanned for %d days for \"%s\" | %s", extraString, GetRemoteStringValue(extraString, "LastIP"), extra, extraString2, Player[playerid][AdminName]);
			BanLog(string);
			format(string, sizeof(string), "Tempban: %s  has remotetempbanned %s for %d days. Defined reason: \"%s\".", Player[playerid][AdminName], extraString, extra, extraString2);
			AdminActionsLog(string);
			format(string, sizeof(string), "Tempban: %s has remotetempbanned %s for %d days. Defined reason: \"%s\".", Player[playerid][AdminName], extraString, extra, extraString2);
			SendToAdmins(ADMINORANGE, string, 0);
			LogLastBan(extraString, GetRemoteStringValue(extraString, "LastIP"));
			
			Player[playerid][AdminActions]++;
		}
		case THREAD_REMOTE_CHANGE_ADMINLEVEL:
		{
			format(string, sizeof(string), "[ADMIN] %s has demoted %s to level %d.", Player[playerid][AdminName], extraString, extra);
			StatLog(string);
			format(string, sizeof(string), "%s has demoted %s to level %d.", Player[playerid][AdminName], extraString, extra);
			AdminActionsLog(string);			
			format(string, sizeof(string), "%s has demoted %s to level %d.", Player[playerid][AdminName], extraString, extra);
			SendToAdmins(ADMINORANGE, string, 0);
			format(string, sizeof(string), "You have demoted %s to level %d.", extraString, extra);
			SendClientMessage(playerid, WHITE, string);
		}
		case THREAD_REMOTE_CHANGE_FACTION_RANK:
		{
			format(string, sizeof(string), "You have successfully remotely set %s's group rank to %d.", extraString, extra);
			SendClientMessage(playerid, WHITE, string);
		}
		case THREAD_RESET_PIN:
		{
			format(string, sizeof(string), "You have reset %s's admin PIN.", extraString);
			SendClientMessage(playerid, -1, string);
		}
		case THREAD_REMOTE_FINE_TOKENS:
		{
			format(string, sizeof(string), "%s has remotefined %s %d tokens: %s", Player[playerid][AdminName], extraString, extra, extraString2);
			SendToAdmins(ADMINORANGE, string, 0);
			format(string, sizeof(string), "[FINE] %s has remotefined %s %d tokens: %s", Player[playerid][AdminName], extraString, extra, extraString2);
			AdminActionsLog(string);
			Player[playerid][AdminActions]++;
		}
		case THREAD_REMOTE_FINE_BANK:
		{
			format(string, sizeof(string), "Fine: %s's bank has been remotefined %s by %s. Defined reason: \"%s\".", extraString, PrettyMoney(extra), Player[playerid][AdminName], extraString2);
			SendToAdmins(ADMINORANGE, string, 0);
			format(string, sizeof(string), "[FINE] %s has remotefined %s's bank %d. Reason: %s", Player[playerid][AdminName], extraString, extra, extraString2);
			AdminActionsLog(string);
			Player[playerid][AdminActions]++;
		}
		case THREAD_REMOTE_AVOID:
		{
			format(string, sizeof(string), "You have warned, fined, and prisoned %s for \"%s\". Their inventory has been reset of essentials.", extraString, extraString2);
			SendClientMessage(playerid, -1, string);
		}
		case THREAD_REMOTE_RESET_WARN:
		{
			switch(extra)
			{
				case 1:
				{
					format(string, sizeof(string), "Warning: %s has reset %s's first warning.", Player[playerid][AdminName], extraString);
					AdminActionsLog(string);
					format(string, sizeof(string), "You have remotely reset %s first warning", extraString);
					SendClientMessage(playerid, -1, string);
				}
				case 2:
				{
					format(string, sizeof(string), "Warning: %s has reset %s's second warning.", Player[playerid][AdminName], extraString);
					AdminActionsLog(string);
					format(string, sizeof(string), "You have remotely reset %s second warning", extraString);
					SendClientMessage(playerid, -1, string);
				}
			}
		}
		case THREAD_REMOTE_RESET_WARNS:
		{
			format(string, sizeof(string), "Warning: %s has remotely reset %s's warnings.", Player[playerid][AdminName], extraString);
			AdminActionsLog(string);
			format(string, sizeof(string), "You have remotely reset %s's warns.", extraString);
			SendClientMessage(playerid, -1, string);
		}
		case THREAD_REMOTESET_HOTELROOM:
		{
			if(extra == -1)
			{
				format(string, sizeof(string), "%s has removed %s's hotel room. (was %d)", Player[playerid][AdminName], extraString, GetPVarInt(playerid, "THREAD_REMOTESET_HOTELROOM_OLDID"));
				StatLog(string);
				format(string, sizeof(string), "You have removed %s's hotel room.", extraString);
				SendClientMessage(playerid, -1, string);
			}
			else
			{
				format(string, sizeof(string), "%s has set %s's hotel room to %d.", Player[playerid][AdminName], extraString, extra);
				StatLog(string);
				format(string, sizeof(string), "You have set %s's hotel room to %d.", extraString, extra);
				SendClientMessage(playerid, -1, string);
			}
		}
		case THREAD_RESET_PASSWORD:
		{
			format(string, sizeof(string), "%s has reset %s's password.", Player[playerid][AdminName], extraString);
			AdminActionsLog(string);
			format(string, sizeof(string), "You have reset %s's password to %s.", extraString, extraString2);
			SendClientMessage(playerid, WHITE, string);
		}
		case THREAD_EDIT_BUSINESS_KEY:
		{
			format(string, sizeof(string), "* %s has given %s a key.", GetNameEx(playerid), GetNameEx(extra));
			NearByMessage(playerid, NICESKY, string);
			format(string, sizeof(string), "You have been given a key to business %d by %s.", Player[extra][BusinessKey], GetNameEx(playerid));
			SendClientMessage(extra, -1, string);
			format(string, sizeof(string), "You have given %s a key to your business.", GetNameEx(extra));
			SendClientMessage(playerid, -1, string);
			SaveBusiness(Player[extra][BusinessKey]);
		}
	}
	return 1;
}

stock InitMySQL()
{
	if(!fexist("MySQLConfig.ini"))
		dini_Create("MySQLConfig.ini");
	
	format(MYSQL_IP, sizeof(MYSQL_IP), "%s", dini_Get("MySQLConfig.ini", "MYSQL_IP"));
	format(MYSQL_USERNAME, sizeof(MYSQL_USERNAME), "%s", dini_Get("MySQLConfig.ini", "MYSQL_USERNAME"));
	format(MYSQL_DATABASE_NAME, sizeof(MYSQL_DATABASE_NAME), "%s", dini_Get("MySQLConfig.ini", "MYSQL_DATABASE_NAME"));
	format(MYSQL_PASSWORD, sizeof(MYSQL_PASSWORD), "%s", dini_Get("MySQLConfig.ini", "MYSQL_PASSWORD"));
	
	MYSQL_MAIN = mysql_connect(MYSQL_IP, MYSQL_USERNAME, MYSQL_DATABASE_NAME, MYSQL_PASSWORD);
	
	if(mysql_errno(MYSQL_MAIN) != 0)
	{
		print("\a[MySQL] Could not connect to MySQL database! Emergency Shutdown initiated!!\r\n");
		EmergencyShutdown = 1;
		SendRconCommand("exit");
	}
	else 
	{
		print("[MySQL] Connection to MySQL established.\r\n");
		// CreatePlayerTables();
	}
	return 1;
}

/*stock CreatePlayerTables()
{
	new query[2024];
	
	format(query, sizeof(query), "CREATE TABLE IF NOT EXISTS playercontacts (RowID INTEGER AUTO_INCREMENT PRIMARY KEY, PlayerSQLID INTEGER, ");
	for(new i; i < MAX_CONTACTS; i++)
	{
		if(i != MAX_CONTACTS - 1)
			format(query, sizeof(query), "%sContact%d VARCHAR(128), ", query, i + 1);
		else format(query, sizeof(query), "%sContact%d VARCHAR(128));", query, i + 1);
	}
	mysql_query(MYSQL_MAIN, query);
	
	return 1;
}*/

public IsPlayerRegistered(name[])
{
	new string[128], bool:valid;
	mysql_format(MYSQL_MAIN, string, sizeof(string), "SELECT SQLID FROM playeraccounts WHERE NormalName = '%e'", name);
	new Cache:data = mysql_query(MYSQL_MAIN, string);
	
	if(cache_get_row_count() > 0)
		valid = true;
	else valid = false;
	
	cache_delete(data);
	return valid;
}

stock DoesBusinessExist(id)
{
	new string[128], bool:valid;
	mysql_format(MYSQL_MAIN, string, sizeof(string), "SELECT BusinessSQL FROM businesses WHERE BusinessSQL = '%d'", id);
	new Cache:data = mysql_query(MYSQL_MAIN, string);
	
	if(cache_get_row_count() > 0)
		valid = true;
	else valid = false;
	
	cache_delete(data);
	return valid;
}

stock DoesHouseExist(id)
{
	new string[128], bool:valid;
	mysql_format(MYSQL_MAIN, string, sizeof(string), "SELECT HouseSQL FROM houses WHERE HouseSQL = '%d'", id);
	new Cache:data = mysql_query(MYSQL_MAIN, string);
	
	if(cache_get_row_count() > 0)
		valid = true;
	else valid = false;
	
	cache_delete(data);
	return valid;
}

stock DoesFactionExist(id)
{
	new string[128], bool:valid;
	mysql_format(MYSQL_MAIN, string, sizeof(string), "SELECT FactionSQL FROM factions WHERE FactionSQL = '%d'", id);
	new Cache:data = mysql_query(MYSQL_MAIN, string);
	
	if(cache_get_row_count() > 0)
		valid = true;
	else valid = false;
	
	cache_delete(data);
	return valid;
}

stock DoesJobExist(id)
{
	new string[128], bool:valid;
	mysql_format(MYSQL_MAIN, string, sizeof(string), "SELECT JobSQL FROM jobs WHERE JobSQL = '%d'", id);
	new Cache:data = mysql_query(MYSQL_MAIN, string);
	
	if(cache_get_row_count() > 0)
		valid = true;
	else valid = false;
	
	cache_delete(data);
	return valid;
}

stock GetRemoteAdminLevel(name[])
{
	if(!IsPlayerRegistered(name))
		return -1;
	return GetRemoteIntValue(name, "AdminLevel");
}

stock GetRemoteIntValue(name[], field[])
{		
	new value, string[128];
	mysql_format(MYSQL_MAIN, string, sizeof(string), "SELECT %s FROM playeraccounts WHERE NormalName = '%e'", field, name);
	new Cache:data = mysql_query(MYSQL_MAIN, string);
	value = cache_get_field_content_int(0, field);
	cache_delete(data);
	return value;
}

stock GetRemoteStringValue(name[], field[])
{
	new value[128], string[128];
	mysql_format(MYSQL_MAIN, string, sizeof(string), "SELECT %s FROM playeraccounts WHERE NormalName = '%e'", field, name);
	new Cache:data = mysql_query(MYSQL_MAIN, string);
	cache_get_field_content(0, field, value);
	cache_delete(data);
	return value;
}

stock IsValidColumn(table[], column[])
{
	new query[255], bool:valid;
	mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = '%e' AND TABLE_NAME = '%e' AND COLUMN_NAME = '%e'", MYSQL_DATABASE_NAME, table, column);
	new Cache:data = mysql_query(MYSQL_MAIN, query);
	if(cache_get_row_count() > 0)
		valid = true;
	else valid = false;
	cache_delete(data);
	return valid;
}

public OnQueryError(errorid, error[], callback[], query[], connectionHandle)
{
	switch(errorid)
	{
		case ER_SYNTAX_ERROR:
		{
			printf("[MySQL] There was a problem in the syntax of the following query: %s (Error: %s | Callback: %s | Connection: %d)", query, error, callback, connectionHandle); 
		}
		default: printf("[MySQL] MySQL has encountered an error. (Error ID: %d | Error: %s | Callback: %s | Connection: %d | Query: %s)", errorid, error, callback, connectionHandle, query);
	}
	
	new servername[128];
	GetServerVarAsString("hostname", servername, 128);
	if(!strcmp(servername, "[ENG] MT-Gaming Test Roleplay Server", true))
	{
		new errorString[512];
		format(errorString, sizeof(errorString), "MySQL Error Detected!\nQuery: %s\nError: %s\nCallback: %s\nConnection:%d", query, error, callback, connectionHandle);
		foreach(Player, i)
		{
			if(Player[i][AdminLevel] > 1)
				ShowPlayerDialog(i, 445599, DIALOG_STYLE_MSGBOX, "MySQL Error", errorString, "Ok", "");
		}
	}
	return 1;
}	

/*
Queries needed to setup database

//Player Accounts

CREATE TABLE IF NOT EXISTS playeraccounts ( 
SQLID INTEGER AUTO_INCREMENT, 
CreationTime VARCHAR(128),
Password VARCHAR(161), 
pSalt VARCHAR(32),
AdminLevel INTEGER, 
HasVoted INTEGER, 
LastX FLOAT, 
LastY FLOAT, 
LastZ FLOAT, 
LastWorld INTEGER, 
LastInterior INTEGER, 
LastSkin INTEGER, 
LastHealth FLOAT, 
LastArmour FLOAT, 
LastLoginMinute INTEGER, 
LastLoginHour INTEGER, 
LastLoginDay INTEGER, 
LastLoginMonth INTEGER, 
LastLoginYear INTEGER, 
LastIP VARCHAR(32), 
Group INTEGER, 
GroupRank INTEGER, 
Gang INTEGER,
GangRank INTEGER,
House INTEGER,
House2 INTEGER,
Banned INTEGER,
Muted INTEGER,
Money INTEGER,
WepSlot0 INTEGER,
WepSlot1 INTEGER,
WepSlot2 INTEGER,
WepSlot3 INTEGER,
WepSlot4 INTEGER,
WepSlot5 INTEGER,
WepSlot6 INTEGER,
WepSlot7 INTEGER,
WepSlot8 INTEGER,
WepSlot9 INTEGER,
WepSlot10 INTEGER,
WepSlot11 INTEGER,
Warning1 VARCHAR(128),
Warning2 VARCHAR(128),
Warning3 VARCHAR(128),
Identity INTEGER,
Age INTEGER,
ContractPrice INTEGER,
Contract VARCHAR(128),
Contract2 VARCHAR(128),
PrisonDuration INTEGER,
PrisonID INTEGER,
Tutorial INTEGER,
Hospitalized INTEGER,
Gender INTEGER,
Job INTEGER,
Job2 INTEGER,
Materials INTEGER,
AdminActions INTEGER,
SecondsLoggedIn INTEGER,
BankMoney INTEGER,
Cocaine INTEGER,
Pot INTEGER,
nMuted INTEGER,
nMutedLevel INTEGER,
nMutedTime INTEGER,
vMuted INTEGER,
vMutedLevel INTEGER,
vMutedTime INTEGER,
Business INTEGER,
PhoneN INTEGER,
PlayingHours INTEGER,
InabilityToMatrun INTEGER,
InabilityToDropCar INTEGER,
FishAttempts INTEGER,
CollectedFish INTEGER,
Rope INTEGER,
Rags INTEGER,
FailedHits INTEGER,
SuccessfulHits INTEGER,
PersonalRadio INTEGER,
ArmsDealerXP INTEGER,
MarriedTo VARCHAR(25),
FightBox INTEGER,
FightKungfu INTEGER,
FightGrabkick INTEGER,
FightKneehead INTEGER,
FightElbow INTEGER,
VipRank INTEGER,
VipTime INTEGER,
VipRenew INTEGER,
WalkieTalkie INTEGER,
BankStatus INTEGER,
PlayerSkinSlot1 INTEGER,
PlayerSkinSlot2 INTEGER,
PlayerSkinSlot3 INTEGER,
AdminPIN INTEGER,
AdminName VARCHAR(25),
NormalName VARCHAR(25),
Accent INTEGER,
WalkieFrequency INTEGER,
Note VARCHAR(128),
VipTokens INTEGER,
HasAdApp INTEGER,
HasPagesApp INTEGER,
Tester INTEGER,
CheckBalance INTEGER,
ReportBanTime INTEGER,
ReportBanLevel INTEGER,
AskBanTime INTEGER,
AskBanLevel INTEGER,
AdminDuty INTEGER,
CurrentFightStyle INTEGER,
PDBadge INTEGER,
BannedReason VARCHAR(128),
BannedBy VARCHAR(25),
TempbanTime INTEGER,
TempbanLevel INTEGER,
DeliverTime INTEGER,
GasCans INTEGER,
Speedo INTEGER,
nTag INTEGER,
Developer INTEGER,
Mapper INTEGER,
Walk VARCHAR(72),
InHouse INTEGER,
JobCooldown INTEGER,
CanMakeGun INTEGER,
Deliveries INTEGER,
GasFull INTEGER,
CantFish INTEGER,
FishAgainAntiSpam INTEGER,
Workbench INTEGER,
Toolkit INTEGER,
SkillCooldown INTEGER,
NosBottle INTEGER,
HydroKit INTEGER,
EngineParts INTEGER,
HeadDesc VARCHAR(128),
BodyDesc VARCHAR(128),
ClothingDesc VARCHAR(128),
AccessoryDesc VARCHAR(128),
TotalFished INTEGER,
FishingRod INTEGER,
FishingBait INTEGER,
TotalBass INTEGER,
TotalCod INTEGER,
TotalSalmon INTEGER,
TotalMackerel INTEGER,
TotalTuna INTEGER,
TotalCarp INTEGER,
TotalHerring INTEGER,
TotalMarlin INTEGER,
TotalMako INTEGER,
TotalCrab INTEGER,
TotalKraken INTEGER,
Tickets INTEGER,
Race INTEGER,
AFKKicked INTEGER,
PizzaDelivers INTEGER,
PizzaCooldown INTEGER,
CantDeliverPizza INTEGER,
HouseKey INTEGER,
CasinoChips INTEGER,
FavoriteStationSet INTEGER,
FavoriteStation VARCHAR(255),
HotelRoomID INTEGER,
HotelRoomWarning INTEGER,
CarLicense INTEGER,
TruckLicense INTEGER,
EnterKey INTEGER,
TruckerTestCooldown INTEGER,
SystemAfkKicks INTEGER,
AdminAfkKicks INTEGER,
TogVNames INTEGER,
BeerCases INTEGER,
BusinessKey INTEGER,
VehicleRadio INTEGER,
GarbageCooldown INTEGER,
PotTimer INTEGER,
CocaineTimer INTEGER,
PrisonReason VARCHAR(128),
AdminNote1 VARCHAR(128),
AdminNote2 VARCHAR(128),
AdminNote3 VARCHAR(128),
LicenseSuspended INTEGER,
Speed INTEGER,
SpeedTimer INTEGER,
PotSeeds INTEGER,
GrowLight INTEGER,
ToyBanned INTEGER,
Ringtone INTEGER,
TotalSSDeposits INTEGER,
LastDepositHours INTEGER,	
LastRedeemHours INTEGER,
HasTrackApp INTEGER,
EggsCollected INTEGER,
HungerLevel INTEGER,
HungerEnabled INTEGER,
HungerEffect INTEGER,
HasBoombox INTEGER,
TotalTruckRuns INTEGER,
Warning1Record VARCHAR(128),
Warning2Record VARCHAR(128),
Warning3Record VARCHAR(128),
Warning4Record VARCHAR(128),
Warning5Record VARCHAR(128),
Warning6Record VARCHAR(128),
InGarage INTEGER,
HasSprayCans INTEGER,
AdminSkin INTEGER,
RemoteWarn INTEGER,
TotalGunsMade INTEGER,
TotalCarsDropped INTEGER,
TotalGarbageRuns INTEGER,
TotalFishingRodsBroken INTEGER,
TotalDeaths INTEGER,
TotalKrakensCaught INTEGER,
TotalToolkitsBroken INTEGER,
TotalCarsFixed INTEGER,
TotalMatRuns INTEGER,
PRIMARY KEY(SQLID));

//Toys

CREATE TABLE IF NOT EXISTS playertoys (
RowID INTEGER AUTO_INCREMENT PRIMARY KEY,
PlayerSQLID INTEGER,
ToyModelID0 INTEGER,
ToyXOffset0 FLOAT,
ToyYOffset0 FLOAT,
ToyZOffset0 FLOAT,
ToyXRot0 FLOAT,
ToyYRot0 FLOAT,
ToyZRot0 FLOAT,
ToyXScale0 FLOAT,
ToyYScale0 FLOAT,
ToyZScale0 FLOAT,
ToyBone0 INTEGER,
ToyModelID1 INTEGER,
ToyXOffset1 FLOAT,
ToyYOffset1 FLOAT,
ToyZOffset1 FLOAT,
ToyXRot1 FLOAT,
ToyYRot1 FLOAT,
ToyZRot1 FLOAT,
ToyXScale1 FLOAT,
ToyYScale1 FLOAT,
ToyZScale1 FLOAT,
ToyBone1 INTEGER,
ToyModelID2 INTEGER,
ToyXOffset2 FLOAT,
ToyYOffset2 FLOAT,
ToyZOffset2 FLOAT,
ToyXRot2 FLOAT,
ToyYRot2 FLOAT,
ToyZRot2 FLOAT,
ToyXScale2 FLOAT,
ToyYScale2 FLOAT,
ToyZScale2 FLOAT,
ToyBone2 INTEGER,
ToyModelID3 INTEGER,
ToyXOffset3 FLOAT,
ToyYOffset3 FLOAT,
ToyZOffset3 FLOAT,
ToyXRot3 FLOAT,
ToyYRot3 FLOAT,
ToyZRot3 FLOAT,
ToyXScale3 FLOAT,
ToyYScale3 FLOAT,
ToyZScale3 FLOAT,
ToyBone3 INTEGER,
ToyModelID4 INTEGER,
ToyXOffset4 FLOAT,
ToyYOffset4 FLOAT,
ToyZOffset4 FLOAT,
ToyXRot4 FLOAT,
ToyYRot4 FLOAT,
ToyZRot4 FLOAT,
ToyXScale4 FLOAT,
ToyYScale4 FLOAT,
ToyZScale4 FLOAT,
ToyBone4 INTEGER,
ToyModelID5 INTEGER,
ToyXOffset5 FLOAT,
ToyYOffset5 FLOAT,
ToyZOffset5 FLOAT,
ToyXRot5 FLOAT,
ToyYRot5 FLOAT,
ToyZRot5 FLOAT,
ToyXScale5 FLOAT,
ToyYScale5 FLOAT,
ToyZScale5 FLOAT,
ToyBone5 INTEGER);

*/