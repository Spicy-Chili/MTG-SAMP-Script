/*
#		MTG Yellow Pages
#		
#
#	By accessing this file, you agree to the following:
#		- You will never give the script or associated files to anybody who is not on the MTG SAMP development team
# 		- You will delete all development materials (script, databases, associated files, etc.) when you leave the MTG SAMP development team.
#
#
#
#	Database table: yellowpages
#	Database fields: sqlid INT, title VARCHAR(64), name VARHCAR(25), endtime INT, phone INT, category INT
#	Categories: Mechanic (0), Taxi Driver (1), Vehicle Related (2), Other (3)
#	
#	
*/

#include <YSI\y_hooks>

#define			MAX_ADS				35
#define			YP_CATEGORIES		4

#define YP_MAIN 17732
#define YP_CATEGORY 17733
#define YP_ADD 17734
#define YP_ADD2 17735
#define YP_ADD3 17736
#define YP_REMOVE 17737

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case YP_MAIN:
		{
			if(!response)
				return ShowPlayerDialog(playerid, 2489, DIALOG_STYLE_LIST, "Phone Menu - Applications", "Advertisements\nYellow Pages\nuTrack\nBlockOff\nGPS", "Select", "Cancel");
				
			if(!strcmp(inputtext, "Remove own advertisement", true))
			{
				new string[128];
				for(new i; i < YP_CATEGORIES; i++)
				{
					format(string, sizeof(string), "%s%s%s\n", string, (DoesNumberHaveAd(Player[playerid][PhoneN], i) > 0) ? ("{3BD140}") : ("{F05151}"), GetCategoryNameByID(i));
				}
				
				return ShowPlayerDialog(playerid, YP_REMOVE, DIALOG_STYLE_LIST, "Applications - Yellow Pages - Remove advertisement", string, "Remove", "Back");
			}
			
			DisplayCategory(playerid, listitem);
		}
		case YP_CATEGORY:
		{
			if(!response)
				return ShowYP_MAIN(playerid);
				
			if(!strcmp(inputtext, "Vacant", true))
			{
				return ShowPlayerDialog(playerid, YP_ADD, DIALOG_STYLE_LIST, GetCategoryTitle(GetPVarInt(playerid, "YP_Category")), "1 week / $1,000\n2 weeks / $1,900\n3 weeks / $2,800\n4 weeks / $3,700", "Select", "Back");
			}
			else if(!strcmp(inputtext, "Next", true))
			{
				return DisplayCategory(playerid, GetPVarInt(playerid, "YP_Page") + 1);
			}
			else if(!strcmp(inputtext, "Back", true))
			{
				return DisplayCategory(playerid, GetPVarInt(playerid, "YP_Page") - 1);
			}
			
			new number[32];
			format(number, sizeof(number), "%d", strval(CutAfterLine(inputtext)));
			cmd_call(playerid, number);
		}
		case YP_ADD:
		{
			if(!response)
				return DisplayCategory(playerid, GetPVarInt(playerid, "YP_Category"));
			
			SetPVarInt(playerid, "YP_AdvertTime", (listitem + 1) * 7);
			SetPVarInt(playerid, "YP_AdvertCost", ((listitem + 1) * 1000) - (listitem * 100));
			new res[255], cost = GetPVarInt(playerid, "YP_AdvertCost"), days = GetPVarInt(playerid, "YP_AdvertTime");
			
			format(res, sizeof(res), "{FFFFFF}This will cost {FFF194}%s{FFFFFF} to place your name and number into the yellow pages.\nIt will be up for {FFF194}%d{FFFFFF} days before it is removed.\nPayment for this will come straight from your bank account.\nDo you want to continue?", PrettyMoney(cost), days);
			return ShowPlayerDialog(playerid, YP_ADD2, DIALOG_STYLE_MSGBOX, GetCategoryTitle(GetPVarInt(playerid, "YP_Category")), res, "Yes", "No");
		}
		case YP_ADD2:
		{
			if(!response)
				return DisplayCategory(playerid, GetPVarInt(playerid, "YP_Category"));
			
			return ShowPlayerDialog(playerid, YP_ADD3, DIALOG_STYLE_INPUT, GetCategoryTitle(GetPVarInt(playerid, "YP_Category")), "Enter the title for your advertisement in the Yellow Pages.\nEnter something like your name or business name.", "Done", "Back");
		}
		case YP_ADD3:
		{
			if(!response)
				return DisplayCategory(playerid, GetPVarInt(playerid, "YP_Category"));
				
			if(Player[playerid][PhoneN] == -1)
			{
				SendClientMessage(playerid, -1, "You don't have a phone.");
				return DisplayCategory(playerid, GetPVarInt(playerid, "YP_Category"));
			}
				
			if(Player[playerid][BankMoney] < GetPVarInt(playerid, "YP_AdvertCost"))
			{
				SendClientMessage(playerid, -1, "You don't have enough money to do this.");
				return DisplayCategory(playerid, GetPVarInt(playerid, "YP_Category"));
			}
			
			if(DoesNumberHaveAd(Player[playerid][PhoneN], GetPVarInt(playerid, "YP_Category")))
			{
				SendClientMessage(playerid, -1, "You already have an ad in that category.");
				return DisplayCategory(playerid, GetPVarInt(playerid, "YP_Category"));
			}
			
			if(isnull(inputtext) || strlen(inputtext) > 63)
			{
				SendClientMessage(playerid, WHITE, "The title is too long or too short.");
				return ShowPlayerDialog(playerid, YP_ADD3, DIALOG_STYLE_INPUT, GetCategoryTitle(GetPVarInt(playerid, "YP_Category")), "Enter the title for your advertisement in the Yellow Pages.\nEnter something like your name or business name.", "Done", "Back");
			}
			
			for(new i ; i < strlen(inputtext); i++)
			{
				if(inputtext[i] == '|')
				{
					SendClientMessage(playerid, WHITE, "You cannot use the '|' character.");
					return ShowPlayerDialog(playerid, YP_ADD3, DIALOG_STYLE_INPUT, GetCategoryTitle(GetPVarInt(playerid, "YP_Category")), "Enter the title for your advertisement in the Yellow Pages.\nEnter something like your name or business name.", "Done", "Back");
				}
			}
			
			new category = GetPVarInt(playerid, "YP_Category"), time = gettime() + GetPVarInt(playerid, "YP_AdvertTime") * 86400;
			
			new query[255];
			mysql_format(MYSQL_MAIN, query, sizeof(query), "INSERT INTO yellowpages (title, name, endtime, category, phone) VALUES ('%e', '%e', '%d', '%d', '%d')", inputtext, Player[playerid][NormalName], time, category, Player[playerid][PhoneN]);
			mysql_query(MYSQL_MAIN, query, false);
			
			new string[128], string2[128];
			if(Player[playerid][Gender] == 1)
			{
				format(string, sizeof(string), "SMS from The Bank of LS: Mr %s, the transaction for your advertisement in the yellow pages has been complete ..", GetNameEx(playerid));
				format(string2, sizeof(string2), "SMS from The Bank of LS: .. and funds have been taken from your account.", GetNameEx(playerid));
			}
			else
			{
				format(string, sizeof(string), "SMS from The Bank of LS: Mrs %s, the transaction for your advertisement in the yellow pages has been complete ..", GetNameEx(playerid));
				format(string2, sizeof(string2), "SMS from The Bank of LS: .. and funds have been taken from your account.", GetNameEx(playerid));
			}
			
			SendClientMessage(playerid, PHONE, string);
			SendClientMessage(playerid, PHONE, string2);
			
			Player[playerid][BankMoney] -= GetPVarInt(playerid, "YP_AdvertCost");
			
			SendClientMessage(playerid, -1, "You have successfully placed your ad in the yellow pages.");
			DeletePVar(playerid, "YP_AdvertTime");
			DeletePVar(playerid, "YP_AdvertCost");
			DeletePVar(playerid, "YP_Category");
		}
		case YP_REMOVE:
		{
			if(!response)
				return ShowYP_MAIN(playerid);
				
			new string[128];
			if(!DoesNumberHaveAd(Player[playerid][PhoneN], listitem))
			{
				for(new i; i < YP_CATEGORIES; i++)
				{
					format(string, sizeof(string), "%s%s%s\n", string, (DoesNumberHaveAd(Player[playerid][PhoneN], i) > 0) ? ("{3BD140}") : ("{F05151}"), GetCategoryNameByID(i));
				}
				
				SendClientMessage(playerid, WHITE, "You don't have an ad in this category.");
				return ShowPlayerDialog(playerid, YP_REMOVE, DIALOG_STYLE_LIST, "Applications - Yellow Pages - Remove advertisement", string, "Remove", "Back");
			}
			
			mysql_format(MYSQL_MAIN, string, sizeof(string), "DELETE FROM yellowpages WHERE name = '%e' AND category = '%d'", Player[playerid][NormalName], listitem);
			mysql_query(MYSQL_MAIN, string, false);
			
			format(string, sizeof(string), "You have successfully removed your advertisement from the %s category in the Yellow Pages.", GetCategoryNameByID(listitem));
			return SendClientMessage(playerid, WHITE, string);
		}
	}
	return 1;
}

stock ShowYP_MAIN(playerid)
{
	new string[128];
	for(new i; i < YP_CATEGORIES; i++)
	{
		format(string, sizeof(string), "%s%s\n", string, GetCategoryNameByID(i));
	}
	strcat(string, "Remove own advertisement");
	return ShowPlayerDialog(playerid, YP_MAIN, DIALOG_STYLE_LIST, "Applications - Yellow Pages", string, "Select", "Back");
}

stock GetCategoryNameByID(id)
{
	new name[64] = "Unknown Category";
	switch(id)
	{
		case 0: format(name, sizeof(name), "Mechanic");
		case 1: format(name, sizeof(name), "Taxi Driver");
		case 2: format(name, sizeof(name), "Vehicle Related");
		case 3: format(name, sizeof(name), "Other");
	}
	return name;
}

stock GetCategoryIDByName(name[])
{
	if(!strcmp(name, "Mechanic", true))
		return 0;
	else if(!strcmp(name, "Taxi Driver", true))
		return 1;
	else if(!strcmp(name, "Vehicle Related", true))
		return 2;
	else if(!strcmp(name, "Other", true))
		return 3;
	return -1;
}

stock DoesNumberHaveAd(number, category)
{
	new query[128];
	mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT sqlid FROM yellowpages WHERE phone = '%d' AND category = '%d'", number, category);
	new Cache:cache = mysql_query(MYSQL_MAIN, query), sqlid = cache_get_field_content_int(0, "sqlid");
	cache_delete(cache);
	return sqlid;
}

stock GetCategoryTitle(category)
{
	new cat_title[64];
	format(cat_title, sizeof(cat_title), "Yellow Pages - %s", GetCategoryNameByID(category));
	return cat_title;
}

stock DisplayCategory(playerid, category, page = 0)
{
	new result[1024], query[128];
	mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT * FROM yellowpages WHERE category = '%d'", category);
	new Cache:cache = mysql_query(MYSQL_MAIN, query), count = cache_get_row_count(), row = page * 10, full, title[64];
	
	if(count < MAX_ADS && page == 0)
		result = "Vacant\n";
	
	while(row < count && full < 10)
	{
		cache_set_active(cache);
		cache_get_field_content(row, "title", title);
		format(result, sizeof(result), "%s%s | %d\n", result, title, cache_get_field_content_int(row, "phone"));
	
		full ++;
		row ++;
	}
	
	if(row < count)
		strcat(result, "Next\n");
	
	if(row > 10)
		strcat(result, "Back\n");
	
	if(strlen(result) == 0)
		return SendClientMessage(playerid, RED, "(( There are vacant spots and nobody is online in that category ))");
	
	SetPVarInt(playerid, "YP_Category", category);
	SetPVarInt(playerid, "YP_Page", page);
	return ShowPlayerDialog(playerid, YP_CATEGORY, DIALOG_STYLE_LIST, GetCategoryTitle(category), result, "Select", "Back");
}

stock CleanYellowPages()
{
	new query[128];
	mysql_format(MYSQL_MAIN, query, sizeof(query), "DELETE FROM yellowpages WHERE endtime < %d", gettime());
	mysql_query(MYSQL_MAIN, query, false);
	return 1;
}