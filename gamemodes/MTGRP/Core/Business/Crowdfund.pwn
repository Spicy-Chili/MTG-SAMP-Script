/*
#		MTG Crowdfunding Business
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

#define MAX_PROJECTS_PER_PAGE	10

#define MIN_PROJECT_CONTRIBUTION_AMOUNT	100

#define MIN_PROJECT_GOAL				100000
#define MAX_PROJECT_GOAL				1000000000

#define MAX_PROJECT_TIME				1209600//2 weeks

static string[128], ViewingSQLIDs[MAX_PLAYERS][MAX_PROJECTS_PER_PAGE];

enum createproject_
{
	ProjectName[32],
	ProjectGoal,
	ProjectDesc[512],
};

static PlayerEditProject[MAX_PLAYERS][createproject_];

CMD:viewprojects(playerid, params[])
{
	if(Businesses[Player[playerid][InBusiness]][bType] != 25)
		return SendClientMessage(playerid, WHITE, "You must be inside a crowdfunding business to use this command.");
	
	if(!IsPlayerInRangeOfPoint(playerid, 1.5, Businesses[Player[playerid][InBusiness]][bInteractX], Businesses[Player[playerid][InBusiness]][bInteractY], Businesses[Player[playerid][InBusiness]][bInteractZ]) && Player[playerid][InBusiness] != 0)
		return SendClientMessage(playerid, GREY, "You must stand near the interaction point to do this.");
	
	if(CantUseRightNow(playerid) == 1)
			return SendClientMessage(playerid, -1, "You can't do that right now, you're incapacitated!");
	
	FetchActiveProjects(playerid);
	return 1;
}

CMD:createproject(playerid, params[])
{
	if(Businesses[Player[playerid][InBusiness]][bType] != 25)
		return SendClientMessage(playerid, WHITE, "You must be inside a crowdfunding business to use this command.");
	
	if(!IsPlayerInRangeOfPoint(playerid, 1.5, Businesses[Player[playerid][InBusiness]][bInteractX], Businesses[Player[playerid][InBusiness]][bInteractY], Businesses[Player[playerid][InBusiness]][bInteractZ]) && Player[playerid][InBusiness] != 0)
		return SendClientMessage(playerid, GREY, "You must stand near the interaction point to do this.");
	
	if(CantUseRightNow(playerid) == 1)
			return SendClientMessage(playerid, -1, "You can't do that right now, you're incapacitated!");
			
	if(DoesPlayerHaveActiveProject(playerid))
		return SendClientMessage(playerid, WHITE, "You may only have one active project at a time.");
		
	if(Player[playerid][Mask] == 1)
		return SendClientMessage(playerid, -1, "Remove your mask before using this command.");
		
	ShowPlayerCreateProjectDialog(playerid);
	return 1;
}

CMD:manageprojects(playerid, params[])
{
	if(Businesses[Player[playerid][InBusiness]][bType] != 25)
		return SendClientMessage(playerid, WHITE, "You must be inside a crowdfunding business to use this command.");
	
	if(!IsPlayerInRangeOfPoint(playerid, 1.5, Businesses[Player[playerid][InBusiness]][bInteractX], Businesses[Player[playerid][InBusiness]][bInteractY], Businesses[Player[playerid][InBusiness]][bInteractZ]) && Player[playerid][InBusiness] != 0)
		return SendClientMessage(playerid, GREY, "You must stand near the interaction point to do this.");
	
	if(CantUseRightNow(playerid) == 1)
			return SendClientMessage(playerid, -1, "You can't do that right now, you're incapacitated!");
	
	if(Player[playerid][Mask] == 1)
		return SendClientMessage(playerid, -1, "Remove your mask before using this command.");
	
	new query[128];
	mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT * FROM crowdfundmain WHERE ProjectOwnerName = '%e'", GetName(playerid));
	new Cache:cache = mysql_query(MYSQL_MAIN, query), idx, count;
	count = cache_get_row_count();
	
	if(count == 0)
	{
		SendClientMessage(playerid, WHITE, "You have no available projects to manage.");
		cache_delete(cache);
		return 1;
	}
	
	new bigString[512], projectName[32], isActive;
	while(idx != count)
	{
		cache_get_field_content(idx, "ProjectName", projectName);
		isActive = cache_get_field_content_int(idx, "ProjectActive");
		format(bigString, sizeof(bigString), "%s%s | %s\n", bigString, projectName, (isActive == 0) ? ("Finished") : ("Active"));
		idx++;
	}
	
	if(isnull(bigString))
		format(bigString, sizeof(bigString), "No projects found.");
	
	ShowPlayerDialog(playerid, DIALOG_CROWDFUND_MANAGE, DIALOG_STYLE_LIST, "Go Fund Yourself - Manage Projects", bigString, "View", "Cancel");
	return 1;
}

hook OnPlayerConnect(playerid)
{
	PlayerEditProject[playerid][ProjectName][0] = EOS;
	PlayerEditProject[playerid][ProjectGoal] = 0;
	PlayerEditProject[playerid][ProjectDesc][0] = EOS;
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DIALOG_CROWDFUND_MAIN:
		{	
			if(!response)
			{
				ResetViewingSQLIDs(playerid);
				return 1;
			}
			
			if(!strcmp(inputtext, "Next Page", true))
				return FetchActiveProjects(playerid, GetPVarInt(playerid, "CROWDFUND_PAGE_START_INDEX"));
			
			new sqlid = ViewingSQLIDs[playerid][listitem];
			mysql_format(MYSQL_MAIN, string, sizeof(string), "SELECT * FROM crowdfundmain WHERE ProjectSQLID = '%d'", sqlid);
			
			new Cache:cache = mysql_query(MYSQL_MAIN, string);
			new bigString[1024],	projectOwner[MAX_PLAYER_NAME+1], 
									projectName[129], 
									projectDeadline,
									projectDeadlineString[32],
									projectDescription[512],
									projectGoal, 
									projectRaised,
									projectBackers;
			
			cache_get_field_content(0, "ProjectName", projectName);
			cache_get_field_content(0, "ProjectOwnerName", projectOwner);
			cache_get_field_content(0, "ProjectDescription", projectDescription);
			projectDeadline = cache_get_field_content_int(0, "ProjectDeadline");
			projectGoal = cache_get_field_content_int(0, "ProjectGoal");
			projectRaised = GetProjectTotalRaised(sqlid);
			projectBackers = GetProjectBackersAmount(sqlid);
			projectDeadline -= gettime();
			
			if(projectDeadline < 0)
				projectDeadline = 0;
			
			format(projectDeadlineString, sizeof(projectDeadlineString), "%d days, %d hours, %d minutes left", projectDeadline / 86400, (projectDeadline % 86400) / 3600, (projectDeadline % 3600) / 60);
			cache_delete(cache);
			new charCount;
			for(new i; i < sizeof(projectDescription); i++)
			{
				charCount ++;
				if(charCount >= 64)
				{
					if(' ' == projectDescription[i])
					{
						strins(projectDescription, "\n", i);
						charCount = 0;
					}
				}
			}
			
			SetPVarInt(playerid, "VIEWING_PROJECT_SQLID", sqlid);
			format(bigString, sizeof(bigString), "{CECECE} %s\nCreated by: {FFFFFF}%s\n\n{CECECE}%d {FFFFFF}backers\n%s%s {CECECE}pledged of {33A10B}%s {CECECE}goal\n%s\n\n{a9c4e4}About this project:\n{FFFFFF}%s", projectName, projectOwner, projectBackers, (projectRaised >= projectGoal) ? ("{33A10B}") : ("{FF0000}"), PrettyMoney(projectRaised), PrettyMoney(projectGoal), projectDeadlineString, projectDescription);
			ShowPlayerDialog(playerid, DIALOG_CROWDFUND_VIEW, DIALOG_STYLE_MSGBOX, "Go Fund Yourself - Active Project View", bigString, "Contribute", "Back");
		}
		case DIALOG_CROWDFUND_VIEW:
		{
			if(!response)
				return FetchActiveProjects(playerid, GetPVarInt(playerid, "CROWDFUND_PAGE_START_INDEX"));

			format(string, sizeof(string), "{FFFFFF}How much would you like to contribute?\nBank Balance: {33A10B}%s", PrettyMoney(Player[playerid][BankMoney]));
			ShowPlayerDialog(playerid, DIALOG_CROWDFUND_CONTRIBUTE, DIALOG_STYLE_INPUT, "Go Fund Yourself - Contribute", string, "Accept", "Cancel");
		}
		case DIALOG_CROWDFUND_CONTRIBUTE:
		{
			if(!response)
				return 1;
			
			if(Player[playerid][PlayingHours] < 2)
				return SendClientMessage(playerid, WHITE, "You need at least 2 playing hours to donate to a campaign.");
			
			new amount = strval(inputtext);
			
			if(amount < MIN_PROJECT_CONTRIBUTION_AMOUNT)
				return SendClientMessage(playerid, WHITE, "You must contribute at least $"#MIN_PROJECT_CONTRIBUTION_AMOUNT".");
			
			if(amount > Player[playerid][BankMoney])
				return SendClientMessage(playerid, WHITE, "You don't have enough money in your bank.");
			
			new sqlid = GetPVarInt(playerid, "VIEWING_PROJECT_SQLID");
			
			Player[playerid][BankMoney] -= amount;
			SavePlayerData(playerid);
			
			format(string, sizeof(string), "[CROWDFUND] %s has donated %s to %s.", GetName(playerid), PrettyMoney(amount), GetProjectName(sqlid));
			StatLog(string);
			format(string, sizeof(string), "You donated {33A10B}%s{FFFFFF} to %s.", PrettyMoney(amount), GetProjectName(sqlid));
			InsertProjectDonation(playerid, sqlid, amount);
			SendClientMessage(playerid, WHITE, string);
			SendClientMessage(playerid, WHITE, "If the project fails to meet its goal you will be refunded the donation.");
			
			//Moneyfarming Check
			if(Player[playerid][PlayingHours] < 5 && Player[playerid][AdminLevel] < 1)
			{
				format(string, sizeof(string), "WARNING: %s may possibly be money-farming, they've donated %s to project #%d.", GetName(playerid), PrettyMoney(amount), sqlid);
				SendToAdmins(ADMINORANGE, string, 0);
				WarningLog(string);
			}
		}
		case DIALOG_CROWDFUND_CREATE:
		{
			if(!response)
				return 1;
			
			switch(listitem)
			{	
				//Project Name
				case 0: ShowPlayerDialog(playerid, DIALOG_CROWDFUND_NAME, DIALOG_STYLE_INPUT, "Go Fund Yourself - Choose a name", "{FFFFFF}What would you like your project to be called?", "Accept", "Back");
				//Project Goal
				case 1:	ShowPlayerDialog(playerid, DIALOG_CROWDFUND_GOAL, DIALOG_STYLE_INPUT, "Go Fund Yourself - Choose a goal", "{FFFFFF}How much do you wish to raise?\nNote: If you do not raise this amount you will not receive any money.", "Accept", "Back");
				//Project Desc
				case 2:	ShowPlayerDialog(playerid, DIALOG_CROWDFUND_DESC, DIALOG_STYLE_LIST, "Go Fund Yourself - Description", "View Description\nNew Description\nAppend to Current Description", "Select", "Back");
				//Create project
				case 3:
				{
					if(isnull(PlayerEditProject[playerid][ProjectName]) || strlen(PlayerEditProject[playerid][ProjectName]) > 32)
					{
						SendClientMessage(playerid, RED, "That project name is either to short or to long.");
						return ShowPlayerCreateProjectDialog(playerid);
					}
					
					if(PlayerEditProject[playerid][ProjectGoal] < MIN_PROJECT_GOAL || PlayerEditProject[playerid][ProjectGoal] > MAX_PROJECT_GOAL)
					{
						SendClientMessage(playerid, RED, "The project goal must be between "#MIN_PROJECT_GOAL" and "#MAX_PROJECT_GOAL".");
						return ShowPlayerCreateProjectDialog(playerid);
					}
					
					if(isnull(PlayerEditProject[playerid][ProjectDesc]))
					{
						SendClientMessage(playerid, RED, "Your project description is blank!");
						return ShowPlayerCreateProjectDialog(playerid);
					}
					
					new query[1024];
					mysql_format(MYSQL_MAIN, query, sizeof(query), "INSERT INTO crowdfundmain (ProjectOwnerName, ProjectName, ProjectDescription, ProjectGoal, ProjectDeadline, ProjectActive) VALUES ('%e', '%e', '%e', '%d', '%d', '1')", GetName(playerid), PlayerEditProject[playerid][ProjectName], PlayerEditProject[playerid][ProjectDesc], PlayerEditProject[playerid][ProjectGoal], gettime() + MAX_PROJECT_TIME);
					mysql_tquery(MYSQL_MAIN, query, "OnProjectInsert", "d", playerid);
				}
			}
		}
		case DIALOG_CROWDFUND_NAME:
		{
			if(!response)
				return ShowPlayerCreateProjectDialog(playerid);
				
			if(isnull(inputtext) || strlen(inputtext) > 32)
			{
				SendClientMessage(playerid, RED, "That project name is either to short or to long.");
				return ShowPlayerCreateProjectDialog(playerid);
			}
			
			
			format(PlayerEditProject[playerid][ProjectName], 32, "%s", inputtext);
			return ShowPlayerCreateProjectDialog(playerid);
		}
		case DIALOG_CROWDFUND_GOAL:
		{
			if(!response)
				return ShowPlayerCreateProjectDialog(playerid);
			
			new goal = strval(inputtext);
			if(goal < MIN_PROJECT_GOAL || goal > MAX_PROJECT_GOAL)
			{
				SendClientMessage(playerid, RED, "The project goal must be between "#MIN_PROJECT_GOAL" and "#MAX_PROJECT_GOAL".");
				return ShowPlayerCreateProjectDialog(playerid);
			}
			
			PlayerEditProject[playerid][ProjectGoal] = goal;
			return ShowPlayerCreateProjectDialog(playerid);
		}
		case DIALOG_CROWDFUND_DESC:
		{
			if(!response)
				return ShowPlayerCreateProjectDialog(playerid);
				
			switch(listitem)
			{
				case 0:	
				{
					new bigString[548];
					format(bigString, sizeof(bigString), "{CECECE}Current Description:\n{FFFFFF}%s", PlayerEditProject[playerid][ProjectDesc]);
					
					new charCount;
					for(new i; i < sizeof(bigString); i++)
					{
						charCount ++;
						if(charCount >= 64)
						{
							if(' ' == bigString[i])
							{
								strins(bigString, "\n", i);
								charCount = 0;
							}
						}
					}
					
					ShowPlayerDialog(playerid, DIALOG_CROWDFUND_DESC+1, DIALOG_STYLE_MSGBOX, "Go Fund Yourself - View Project Description", bigString, "Back", "");
				}
				case 1: ShowPlayerDialog(playerid, DIALOG_CROWDFUND_DESC+2, DIALOG_STYLE_INPUT, "Go Fund Yourself - New Description", "{FFFFFF}Please enter the desired description.\nPlease note this will overwrite anything you have so far.", "Accept", "Back");
				case 2: ShowPlayerDialog(playerid, DIALOG_CROWDFUND_DESC+3, DIALOG_STYLE_INPUT, "Go Fund Yourself - Add To Description", "{FFFFFF}Please enter the desired addition.\nThis will be added to the end of your current description.", "Accept", "Back");
			}
		}
		case DIALOG_CROWDFUND_DESC+1: ShowPlayerDialog(playerid, DIALOG_CROWDFUND_DESC, DIALOG_STYLE_LIST, "Go Fund Yourself - Description", "View Description\nNew Description\nAppend to Current Description", "Select", "Back");
		case DIALOG_CROWDFUND_DESC+2:
		{
			if(!response)
				return ShowPlayerDialog(playerid, DIALOG_CROWDFUND_DESC, DIALOG_STYLE_LIST, "Go Fund Yourself - Description", "View Description\nNew Description\nAppend to Current Description", "Select", "Back");
			
			if(isnull(inputtext))
			{
				SendClientMessage(playerid, RED, "Invalid input.");
				return ShowPlayerDialog(playerid, DIALOG_CROWDFUND_DESC+2, DIALOG_STYLE_INPUT, "Go Fund Yourself - New Description", "Please enter the desired description.\nPlease note this will overwrite anything you have so far.", "Accept", "Back");
			}
			
			format(PlayerEditProject[playerid][ProjectDesc], 512, "%s", inputtext);
			SendClientMessage(playerid, WHITE, "You have changed your project description.");
			return ShowPlayerDialog(playerid, DIALOG_CROWDFUND_DESC, DIALOG_STYLE_LIST, "Go Fund Yourself - Description", "View Description\nNew Description\nAppend to Current Description", "Select", "Back");
		}
		case DIALOG_CROWDFUND_DESC+3:
		{
			if(!response)
				ShowPlayerDialog(playerid, DIALOG_CROWDFUND_DESC, DIALOG_STYLE_LIST, "Go Fund Yourself - Description", "View Description\nNew Description\nAppend to Current Description", "Select", "Back");
		
			if(isnull(inputtext))
			{
				SendClientMessage(playerid, RED, "Invalid input.");
				return ShowPlayerDialog(playerid, DIALOG_CROWDFUND_DESC+2, DIALOG_STYLE_INPUT, "Go Fund Yourself - New Description", "Please enter the desired description.\nPlease note this will overwrite anything you have so far.", "Accept", "Back");
			}
			
			strcat(PlayerEditProject[playerid][ProjectDesc], " ", 512);
			strcat(PlayerEditProject[playerid][ProjectDesc], inputtext, 512);
			SendClientMessage(playerid, WHITE, "You have added onto your project description.");
			return ShowPlayerDialog(playerid, DIALOG_CROWDFUND_DESC, DIALOG_STYLE_LIST, "Go Fund Yourself - Description", "View Description\nNew Description\nAppend to Current Description", "Select", "Back");
		}
		case DIALOG_CROWDFUND_MANAGE:
		{
			if(!response)
				return 1;
				
			new projectName[32];
			format(projectName, sizeof(projectName), "%s", CutBeforeLine(inputtext));
			
			new query[128], Cache:cache, sqlid;
			mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT ProjectSQLID FROM crowdfundmain WHERE ProjectName = '%e' AND ProjectOwnerName = '%e'", projectName, GetName(playerid));
			cache = mysql_query(MYSQL_MAIN, query);
			sqlid = cache_get_field_content_int(0, "ProjectSQLID");
			cache_delete(cache);
			
			mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT * FROM crowdfunddonators WHERE ProjectSQLID = '%d'", sqlid);
			cache = mysql_query(MYSQL_MAIN, query);
			
			new bigString[2048], rows = cache_get_row_count(), idx, name[25], amount;
			
			while(idx < rows)
			{
				cache_get_field_content(idx, "DonatorName", name);
				amount = cache_get_field_content_int(idx, "DonationAmount");
				format(bigString, sizeof(bigString), "%s%s - %s\n", bigString, name, PrettyMoney(amount));
				idx++;
			}
			
			if(isnull(bigString))
				format(bigString, sizeof(bigString), "No donators found.");
		
			ShowPlayerDialog(playerid, DIALOG_CROWDFUND_DONATORS, DIALOG_STYLE_LIST, "Go Fund Yourself - View Donators", bigString, "Close", "");
		}
		case DIALOG_CROWDFUND_DONATORS:
		{
			return 1;
		}
	}
	
	return 0;
}

forward OnProjectInsert(playerid);
public OnProjectInsert(playerid)
{
	new sqlid = cache_insert_id();
	
	PlayerEditProject[playerid][ProjectName][0] = EOS;
	PlayerEditProject[playerid][ProjectGoal] = 0;
	PlayerEditProject[playerid][ProjectDesc][0] = EOS;
	
	format(string, sizeof(string), "Your project has been successfully created with project ID %d.", sqlid);
	SendClientMessage(playerid, WHITE, string);
}

forward OnActiveProjectsFetched(playerid);
public OnActiveProjectsFetched(playerid)
{
	new count, bigString[2048], sqlid, projectOwner[MAX_PLAYER_NAME+1], projectName[129], projectDeadline, projectDeadlineString[32], projectGoal, projectRaised, Cache:cache = cache_save(), index, row_count = cache_get_row_count();
	
	strcat(bigString,  "{33A10B}Project Name\t{33A10B}Project Creator\t{33A10B}Deadline\t{33A10B}Total Raised\n");
	while(count != MAX_PROJECTS_PER_PAGE && index < row_count)
	{
		cache_set_active(cache);
		sqlid = cache_get_field_content_int(index, "ProjectSQLID");
		if(sqlid == 0)
			break;
		
		cache_get_field_content(index, "ProjectName", projectName);
		cache_get_field_content(index, "ProjectOwnerName", projectOwner);
		projectDeadline = cache_get_field_content_int(index, "ProjectDeadline");
		projectGoal = cache_get_field_content_int(index, "ProjectGoal");
		projectRaised = GetProjectTotalRaised(sqlid);
		projectDeadline -= gettime();
		
		if(projectDeadline < 0)
			projectDeadline = 0;
		
		format(projectDeadlineString, sizeof(projectDeadlineString), "%d days, %d hours", projectDeadline / 86400, (projectDeadline % 86400) / 3600);
		format(bigString, sizeof(bigString), "{FFFFFF}%s%s\t%s\t%s\t%s%s/{FFFFFF}%s\n", bigString, projectName, projectOwner, projectDeadlineString, (projectRaised >= projectGoal) ? ("{33A10B}") : ("{FF0000}"), PrettyMoney(projectRaised), PrettyMoney(projectGoal));
		ViewingSQLIDs[playerid][count] = sqlid;
		
		count++;
		index++;
		if(count == 10)
		{
			SetPVarInt(playerid, "CROWDFUND_PAGE_START_INDEX", sqlid);
			strcat(bigString, "Next Page");
		}	
	}
	
	if(isnull(bigString))
		format(bigString, sizeof(bigString), "No active projects found.");
	
	ShowPlayerDialog(playerid, DIALOG_CROWDFUND_MAIN, DIALOG_STYLE_TABLIST_HEADERS, "Go Fund Yourself - Active Projects", bigString, "View", "Exit");
	return 1;
}

stock CrowdfundProjectCheck()
{
	new Cache:cache, rows, sqlid, timeleft, idx, query[1024];
	cache = mysql_query(MYSQL_MAIN, "SELECT * FROM crowdfundmain WHERE ProjectActive = '1'");
	rows = cache_get_row_count();
	while(idx < rows)
	{
		new name[MAX_PLAYER_NAME+1];
		
		cache_set_active(cache);
		timeleft = cache_get_field_content_int(idx, "ProjectDeadline");
		if(timeleft < gettime())
		{
			new goal, totaldonations, projectName[32];
			sqlid = cache_get_field_content_int(idx, "ProjectSQLID");
			goal = cache_get_field_content_int(idx, "ProjectGoal");
			cache_get_field_content(idx, "ProjectName", projectName);
			cache_get_field_content(idx, "ProjectOwnerName", name);
			totaldonations = GetProjectTotalRaised(sqlid);
			
			cache_set_active(cache);
			
			new pid = -1; 
			pid = GetPlayerID(name);

			if(totaldonations >= goal)
			{
				if(pid != INVALID_PLAYER_ID)
				{
					Player[pid][BankMoney] += (totaldonations - ((totaldonations * 5) / 100));
					format(string, sizeof(string), "Congratulations, your project has reached its goal and earned %s!", PrettyMoney(totaldonations));
					SendClientMessage(pid, GREEN, string);
					SendClientMessage(pid, GREEN, " A 5%% processing fee was automatically deducted.");
					SavePlayerData(pid);
				}
				else
				{
					new bank;
					bank = GetRemoteIntValue(name, "BankMoney");
					bank += (totaldonations - ((totaldonations * 5) / 100));
					format(string, sizeof(string), "Congratulations, your project has reached its goal while you were offline and earned %s!", PrettyMoney(totaldonations));
					mysql_format(MYSQL_MAIN, query, sizeof(query), "UPDATE playeraccounts SET BankMoney = '%d', Note = '%e' WHERE NormalName = '%e'", bank, string, name);
					mysql_query(MYSQL_MAIN, query, false);
				}
				
				format(string, sizeof(string), "[CROWDFUND] %s has received %s from their project %d (%s).", name, PrettyMoney((totaldonations - ((totaldonations * 5) / 100))), sqlid, projectName);
				StatLog(string);
				mysql_format(MYSQL_MAIN, query, sizeof(query), "UPDATE crowdfunddonators SET DonationActive = '0', DonationCharged = '1' WHERE ProjectSQLID = '%d'", sqlid);
				mysql_query(MYSQL_MAIN, query, false);
			}
			else
			{
				if(pid != INVALID_PLAYER_ID)
				{
					SendClientMessage(pid, RED, "Your Go Fund Yourself project failed to meet its goal. The donations have been refunded. Better luck next time!");
				}
				else
				{
					mysql_format(MYSQL_MAIN, query, sizeof(query), "UPDATE playeraccounts SET Note = 'Your Go Fund Yourself project failed to meet its goal. The donations have been refunded. Better luck next time!' WHERE NormalName = '%e'", name);
				}
				
				//Refund time
				
				new Cache:donators, totalDonators, donatorIndex;
				mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT * FROM crowdfunddonators WHERE ProjectSQLID = '%d'", sqlid);
				donators = mysql_query(MYSQL_MAIN, query);
				cache_set_active(donators);
				totalDonators = cache_get_row_count();
				
				while(donatorIndex < totalDonators)
				{
					new donatorName[MAX_PLAYER_NAME+1], donationAmount, donatorBank;
					
					cache_set_active(donators);
					cache_get_field_content(donatorIndex, "DonatorName", donatorName), pid = GetPlayerID(donatorName);
					donationAmount = cache_get_field_content_int(donatorIndex, "DonationAmount");
					
					if(pid != INVALID_PLAYER_ID)
					{
						Player[pid][BankMoney] += donationAmount;
						format(string, sizeof(string), "[CROWDFUND] %s has been refunded their donation of %s for project %d.", donatorName, PrettyMoney(donationAmount), sqlid);
						StatLog(string);
						format(string, sizeof(string), "The project %s failed to meet its goal. You have been refunded your donation of %s.", projectName, PrettyMoney(donationAmount));
						SendClientMessage(pid, GREEN, string);
						SavePlayerData(pid);
					}
					else
					{
						donatorBank = GetRemoteIntValue(donatorName, "BankMoney");
						donatorBank += donationAmount;
						
						format(string, sizeof(string), "[CROWDFUND] %s has been refunded their donation of %s for project %d.", donatorName, PrettyMoney(donationAmount), sqlid);
						StatLog(string);
						format(string, sizeof(string), "%s failed to meet its goal. You have been refunded your donation of %s.", projectName, PrettyMoney(donationAmount));
						mysql_format(MYSQL_MAIN, query, sizeof(query), "UPDATE playeraccounts SET BankMoney = '%d', Note = '%e' WHERE NormalName = '%e'", donatorBank, string, donatorName);
						mysql_query(MYSQL_MAIN, query, false);
					}
					donatorIndex++;
				}
				cache_delete(donators);
				mysql_format(MYSQL_MAIN, query, sizeof(query), "UPDATE crowdfunddonators SET DonationCharged = '0', DonationActive = '0' WHERE ProjectSQLID = '%d'", sqlid);
				mysql_query(MYSQL_MAIN, query, false);
			}
			
			//Set project as inactive 
			mysql_format(MYSQL_MAIN, query, sizeof(query), "UPDATE crowdfundmain SET ProjectActive = '0' WHERE ProjectSQLID = '%d'", sqlid);
			mysql_query(MYSQL_MAIN, query, false);
		}
		idx++;
	}
	cache_delete(cache);
	return 1;
}

static ShowPlayerCreateProjectDialog(playerid)
{
	format(string, sizeof(string),  "Project Name:\t%s\nProject Goal:\t%s\nProject Description\nPublish Project", PlayerEditProject[playerid][ProjectName], PrettyMoney(PlayerEditProject[playerid][ProjectGoal]));
	ShowPlayerDialog(playerid, DIALOG_CROWDFUND_CREATE, DIALOG_STYLE_LIST, "Go Fund Yourself - Project Creation", string, "Edit", "Cancel");
	return 1;
}

static FetchActiveProjects(playerid, index = 0)
{
	new query[255];
	mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT * FROM crowdfundmain WHERE ProjectActive = '1' AND ProjectSQLID > '%d'", index);
	mysql_tquery(MYSQL_MAIN, query, "OnActiveProjectsFetched", "d", playerid);
	return 1;
}

static ResetViewingSQLIDs(playerid)
{
	for(new i; i < MAX_PROJECTS_PER_PAGE; i++)
		ViewingSQLIDs[playerid][i] = 0;
	return 1;
}

static InsertProjectDonation(playerid, sqlid, amount)
{
	new bigString[512];
	mysql_format(MYSQL_MAIN, bigString, sizeof(bigString), "INSERT INTO crowdfunddonators (ProjectSQLID, DonatorName, DonationAmount, DonationCharged, DonationActive) VALUES ('%d', '%e', '%d', '0', '1')", sqlid, GetName(playerid), amount);
	mysql_query(MYSQL_MAIN, bigString, false);
	return 1;
}

static GetProjectTotalRaised(sql)
{
	new raised = 0, Cache:cache, rows, i;
	
	mysql_format(MYSQL_MAIN, string, sizeof(string), "SELECT * FROM crowdfunddonators WHERE ProjectSQLID = '%d' AND DonationActive = '1'", sql);
	cache = mysql_query(MYSQL_MAIN, string);
	
	rows = cache_get_row_count();
	while(i < rows)
	{
		raised += cache_get_field_content_int(i, "DonationAmount");
		i++;
	}
	cache_delete(cache);
	
	return raised;
}

static GetProjectName(sqlid)
{
	new name[32], Cache:cache;
	mysql_format(MYSQL_MAIN, string, sizeof(string), "SELECT ProjectName FROM crowdfundmain WHERE ProjectSQLID = '%d'", sqlid);
	cache = mysql_query(MYSQL_MAIN, string);
	if(cache_get_row_count())
		cache_get_field_content(0, "ProjectName", name);
	cache_delete(cache);
	return name;
}

static DoesPlayerHaveActiveProject(playerid)
{
	new Cache:cache, rows = 0;
	mysql_format(MYSQL_MAIN, string, sizeof(string), "SELECT * FROM crowdfundmain WHERE ProjectOwnerName = '%e' AND ProjectActive = '1'", GetName(playerid));
	cache = mysql_query(MYSQL_MAIN, string);
	rows = cache_get_row_count();
	cache_delete(cache);
	return rows;
}

static GetProjectBackersAmount(sql)
{
	new Cache:cache, rows;
	mysql_format(MYSQL_MAIN, string, sizeof(string), "SELECT * FROM crowdfunddonators WHERE ProjectSQLID = '%d' AND DonationActive = '1'", sql);
	cache = mysql_query(MYSQL_MAIN, string);
	rows = cache_get_row_count();
	cache_delete(cache);
	return rows;
}