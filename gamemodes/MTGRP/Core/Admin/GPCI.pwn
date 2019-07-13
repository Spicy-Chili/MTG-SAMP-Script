/*
#		MTG House GPCI Bans
#		
#
#	By accessing this file, you agree to the following:
#		- You will never give the script or associated files to anybody who is not on the MTG SAMP development team
# 		- You will delete all development materials (script, databases, associated files, etc.) when you leave the MTG SAMP development team.
#
*/

#include <YSI\y_hooks>

static query[512];

hook OnPlayerConnect(playerid)
{
	new gpciStr[255];
	gpci(playerid, gpciStr, sizeof(gpciStr));
	
	mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT * FROM gpcibans WHERE GPCI = '%e'", gpciStr);
	new Cache:cache = mysql_query(MYSQL_MAIN, query);
	if(cache_get_row_count() != 0)
	{
		
		SendClientMessage(playerid, 0x94a6c6FF, "You are banned from this server.");
		
		new name[25], reason[128];
		cache_get_field_content(0, "PlayerName", name);
		cache_get_field_content(0, "BannedReason", reason);
		
		format(query, sizeof(query), "[WARNING] %s has attempted to connect while cookie banned. (%s, Reason: %s)", GetName(playerid), name, reason);
		SendToAdmins(ADMINORANGE, query, 0);
		WarningLog(query);
		
		cache_delete(cache);
		KickEx(playerid);
		return 1;
	}
	cache_delete(cache);

	return 1;
}

stock AddGPCIBan(playerid, bannedby[] = "None", banreason[] = "No Reason")
{
	new gpciStr[255];
	gpci(playerid, gpciStr, sizeof(gpciStr));
	
	mysql_format(MYSQL_MAIN, query, sizeof(query), "INSERT INTO gpcibans (PlayerSQL, PlayerName, GPCI, BannedBy, BannedReason) VALUES (%d, '%e', '%e', '%e', '%e')", Player[playerid][pSQL_ID], GetName(playerid), gpciStr, bannedby, banreason);
	mysql_query(MYSQL_MAIN, query);
	
	format(query, sizeof(query), "[GPCI Ban] %s (%s) has been GPCI banned by %s (Reason: %s)", GetName(playerid), gpciStr, bannedby, banreason);
	BanLog(query);
	
	return 1;
}

stock RemoveGPCIBan(PlayerName[], removedby) 
{
	mysql_format(MYSQL_MAIN, query, sizeof(query), "DELETE FROM gpcibans WHERE PlayerName = '%e'", PlayerName);
	mysql_query(MYSQL_MAIN, query);
	
	format(query, sizeof(query), "[GPCI Ban] %s has been GPCI unbanned by %s.", PlayerName, GetName(removedby));
	BanLog(query);
	return 1;
}
