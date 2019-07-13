/*
#		MTG Account Whitelist
#		
#
#	By accessing this file, you agree to the following:
#		- You will never give the script or associated files to anybody who is not on the MTG SAMP development team
# 		- You will delete all development materials (script, databases, associated files, etc.) when you leave the MTG SAMP development team.
#
#
#
*/

static string[255];

#define ACCOUNT_CREATION_STRING	"*** Your account is not approved for creation. Please visit {FF1EBB}\'register.mt-gaming.com\' {F6970C}***"

CMD:pcreate(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 4)
		return 1;
		
	new name[25];
	if(sscanf(params, "s[25]", name))
		return SendClientMessage(playerid, WHITE, "SYNTAX: /pcreate [name]");
		
	if(IsPlayerRegistered(name))
		return SendClientMessage(playerid, WHITE, "That player name already exists!");
		
	if(IsAccountApproved(name))
		return SendClientMessage(playerid, WHITE, "That player name is already approved for creation!");
		
	new creationPin[9];
	randomStringNoZero(creationPin, 8);
	strtolower(creationPin);
	
	mysql_format(MYSQL_MAIN, string, sizeof(string), "INSERT INTO account_whitelist (AccountName, CreationPin) VALUES ('%e', '%e')", name, creationPin);
	mysql_query(MYSQL_MAIN, string, false);
	
	format(string, sizeof(string), "You have approved \'%s\' for account creation. Their pin is \'%s\'", name, creationPin);
	SendClientMessage(playerid, WHITE, string);
	format(string, sizeof(string), "%s has approved \'%s\' with creation pin \'%s\'", GetName(playerid), name, creationPin);
	AdminActionsLog(string);
	return 1;
}

stock IsAccountApproved(name[])
{
	mysql_format(MYSQL_MAIN, string, sizeof(string), "SELECT * FROM account_whitelist WHERE AccountName = '%e'", name);
	new Cache:cache = mysql_query(MYSQL_MAIN, string);
	new count = cache_get_row_count();
	cache_delete(cache);
	
	if(count)
		return 1;
	return 0;
}

forward IRC_AccountCreate(user[], name[]);
public IRC_AccountCreate(user[], name[])
{
		
	if(IsPlayerRegistered(name))
		return CallRemoteFunction("IRC_PrivateMessage", "ss", user, "That player name already exists!");
		
	if(IsAccountApproved(name))
		return CallRemoteFunction("IRC_PrivateMessage", "ss", user, "That player name is already approved for creation!");
		
	new creationPin[9];
	randomStringNoZero(creationPin, 8);
	strtolower(creationPin);
	
	mysql_format(MYSQL_MAIN, string, sizeof(string), "INSERT INTO account_whitelist (AccountName, CreationPin) VALUES ('%e', '%e')", name, creationPin);
	mysql_query(MYSQL_MAIN, string, false);
	
	format(string, sizeof(string), "You have approved \'%s\' for account creation. Their pin is \'%s\'", name, creationPin);
	CallRemoteFunction("IRC_PrivateMessage", "ss", user, string);
	format(string, sizeof(string), "%s (IRC) has approved \'%s\' with creation pin \'%s\'", user, name, creationPin);
	AdminActionsLog(string);
	return 1;
}