/*
#		MTG Saving Code
#		
#
#	By accessing this file, you agree to the following:
#		- You will never give the script or associated files to anybody who is not on the MTG SAMP development team
# 		- You will delete all development materials (script, databases, associated files, etc.) when you leave the MTG SAMP development team.
#
#
#
*/

#include <a_samp>
#include <zcmd>
#include <streamer>
#define MAX_INI_ENTRY_TEXT 160
//#define INI_MAX_WRITES 8
#include <YSI\y_ini>

#define RED 			0xAA3333AA
#define MAX_TOYS			20
/*### Just some random functions ###*/ 

//These make it a lot easier to write a single line into a file in commands such as /set 
stock INI_WriteIntEx(filename[], name[], value, tag[] = "")
{
	if(!fexist(filename))
		return 0;
		
	new INI:file = INI_Open(filename);
	if(strlen(tag) > 0)
		INI_SetTag(file, tag); 
	INI_WriteInt(file, name, value);
	INI_Close(file);
	return 1;
}

stock INI_WriteStringEx(filename[], name[], string[], tag[] = "")
{
	if(!fexist(filename))
		return 0;
		
	new INI:file = INI_Open(filename);
	if(strlen(tag) > 0)
		INI_SetTag(file, tag); 
	INI_WriteString(file, name, string);
	INI_Close(file);
	return 1;
}

stock INI_WriteFloatEx(filename[], name[], Float:value, tag[] = "")
{
	if(!fexist(filename))
		return 0;
		
	new INI:file = INI_Open(filename);
	if(strlen(tag) > 0)
		INI_SetTag(file, tag); 
	INI_WriteFloat(file, name, value); 
	INI_Close(file);
	return 1;
}

/*### Start of Job related functions ###*/
stock SaveJob(i, create = 0)
{
	if(create == 1)
		orm_insert(Jobs[i][ORM_ID]);
	else 
	{
		if(Jobs[i][ORM_ID] == ORM:0)
		{
			printf("[ORM ERROR] Attempt to save an orm_id of 0. (Job %d)", i);
			return 1;
		}
		orm_update(Jobs[i][ORM_ID]);
	}
	printf("[system] Job %d saved.", i);
	return 1;
}

stock SaveJobs()
{
	for(new i; i < MAX_JOBS; i ++)
	{
		SaveJob(i);
	}
	return 1;
}

forward LoadJob(i, tag[], name[], value[]);
public LoadJob(i, tag[], name[], value[])
{
	INI_String("JobName", Jobs[i][JobName], 255);
	INI_Float("JobJoinPosX", Jobs[i][JobJoinPosX]);
	INI_Float("JobJoinPosY", Jobs[i][JobJoinPosY]);
	INI_Float("JobJoinPosZ", Jobs[i][JobJoinPosZ]);
	INI_Int("JobJoinPosWorld", Jobs[i][JobJoinPosWorld]);
	INI_Int("JobJoinPosInterior", Jobs[i][JobJoinPosInterior]);
	
	INI_Float("JobMiscLocationOneX", Jobs[i][JobMiscLocationOneX]);
	INI_Float("JobMiscLocationOneY", Jobs[i][JobMiscLocationOneY]);
	INI_Float("JobMiscLocationOneZ", Jobs[i][JobMiscLocationOneZ]);
	INI_Int("JobMiscLocationOneWorld", Jobs[i][JobMiscLocationOneWorld]);
	INI_Int("JobMiscLocationOneInterior", Jobs[i][JobMiscLocationOneInterior]);
	INI_String("JobMiscLocationOneMessage", Jobs[i][JobMiscLocationOneMessage], 255);
	
	INI_Float("JobMiscLocationTwoX", Jobs[i][JobMiscLocationTwoX]);
	INI_Float("JobMiscLocationTwoY", Jobs[i][JobMiscLocationTwoY]);
	INI_Float("JobMiscLocationTwoZ", Jobs[i][JobMiscLocationTwoZ]);
	INI_Int("JobMiscLocationTwoWorld", Jobs[i][JobMiscLocationTwoWorld]);
	INI_Int("JobMiscLocationTwoInterior", Jobs[i][JobMiscLocationTwoInterior]);
	INI_String("JobMiscLocationTwoMessage", Jobs[i][JobMiscLocationTwoMessage], 255);
	
	INI_Int("JobType", Jobs[i][JobType]);
	INI_Int("JobCrimeLimit", Jobs[i][JobCrimeLimit]);
	return 1;
}

stock SetupJobORM(jobid)
{
	orm_addvar_int(Jobs[jobid][ORM_ID], Jobs[jobid][JobSQL], "JobSQL");
	orm_addvar_string(Jobs[jobid][ORM_ID], Jobs[jobid][JobName],  255, "JobName");
	orm_addvar_float(Jobs[jobid][ORM_ID], Jobs[jobid][JobJoinPosX], "JobJoinPosX");
	orm_addvar_float(Jobs[jobid][ORM_ID], Jobs[jobid][JobJoinPosY], "JobJoinPosY");
	orm_addvar_float(Jobs[jobid][ORM_ID], Jobs[jobid][JobJoinPosZ], "JobJoinPosZ");
	orm_addvar_int(Jobs[jobid][ORM_ID], Jobs[jobid][JobJoinPosWorld],  "JobJoinPosWorld");
	orm_addvar_int(Jobs[jobid][ORM_ID], Jobs[jobid][JobJoinPosInterior], "JobJoinPosInterior");
	orm_addvar_float(Jobs[jobid][ORM_ID], Jobs[jobid][JobMiscLocationOneX], "JobMiscLocationOneX");
	orm_addvar_float(Jobs[jobid][ORM_ID], Jobs[jobid][JobMiscLocationOneY], "JobMiscLocationOneY");
	orm_addvar_float(Jobs[jobid][ORM_ID], Jobs[jobid][JobMiscLocationOneZ], "JobMiscLocationOneZ");
	orm_addvar_int(Jobs[jobid][ORM_ID], Jobs[jobid][JobMiscLocationOneWorld], "JobMiscLocationOneWorld");
	orm_addvar_int(Jobs[jobid][ORM_ID], Jobs[jobid][JobMiscLocationOneInterior], "JobMiscLocationOneInterior");
	orm_addvar_string(Jobs[jobid][ORM_ID], Jobs[jobid][JobMiscLocationOneMessage], 255, "JobMiscLocationOneMessage");
	orm_addvar_float(Jobs[jobid][ORM_ID], Jobs[jobid][JobMiscLocationTwoX], "JobMiscLocationTwoX");
	orm_addvar_float(Jobs[jobid][ORM_ID], Jobs[jobid][JobMiscLocationTwoY], "JobMiscLocationTwoY");
	orm_addvar_float(Jobs[jobid][ORM_ID], Jobs[jobid][JobMiscLocationTwoZ], "JobMiscLocationTwoZ");
	orm_addvar_int(Jobs[jobid][ORM_ID], Jobs[jobid][JobMiscLocationTwoWorld], "JobMiscLocationTwoWorld");
	orm_addvar_int(Jobs[jobid][ORM_ID], Jobs[jobid][JobMiscLocationTwoInterior], "JobMiscLocationTwoInterior");
	orm_addvar_string(Jobs[jobid][ORM_ID], Jobs[jobid][JobMiscLocationTwoMessage], 255, "JobMiscLocationTwoMessage");
	orm_addvar_int(Jobs[jobid][ORM_ID], Jobs[jobid][JobType], "JobType");
	orm_addvar_int(Jobs[jobid][ORM_ID], Jobs[jobid][JobCrimeLimit], "JobCrimeLimit");
	return 1;
}

/*### End of Job related functions ###*/

	
/*### Start of Group related functions ###*/ 

stock SaveGroup(i, create = 0)
{
	if(create == 1)
		orm_insert(Groups[i][ORM_ID]);
	else 
	{
		if(Groups[i][ORM_ID] == ORM:0)
		{
			printf("[ORM ERROR] Attempted to save an orm id of 0. (Faction %d)", i);
			return 1;
		}
		
		orm_update(Groups[i][ORM_ID]);
	}
	
	printf("[system] Group %d saved.", i);
	return 1;
}

forward LoadGroup(i, tag[], name[], value[]);
public LoadGroup(i, tag[], name[], value[])
{
	INI_String("GroupName", Groups[i][GroupName], 255);
	INI_Int("CommandTypes", Groups[i][CommandTypes]);
	INI_String("RankName0", Groups[i][RankName0], 255);
	INI_String("RankName1", Groups[i][RankName1], 255);
	INI_String("RankName2", Groups[i][RankName2], 255);
	INI_String("RankName3", Groups[i][RankName3], 255);
	INI_String("RankName4", Groups[i][RankName4], 255);
	INI_String("RankName5", Groups[i][RankName5], 255);
	INI_String("RankName6", Groups[i][RankName6], 255);
	INI_String("RankName7", Groups[i][RankName7], 255);
	INI_String("RankName8", Groups[i][RankName8], 255);
	INI_String("RankName9", Groups[i][RankName9], 255);
	INI_String("RankName10", Groups[i][RankName10], 255);
	INI_Int("Skin0", Groups[i][Skin0]); 
	INI_Int("Skin1", Groups[i][Skin1]); 
	INI_Int("Skin2", Groups[i][Skin2]); 
	INI_Int("Skin3", Groups[i][Skin3]); 
	INI_Int("Skin4", Groups[i][Skin4]); 
	INI_Int("Skin5", Groups[i][Skin5]); 
	INI_Int("Skin6", Groups[i][Skin6]); 
	INI_Int("Skin7", Groups[i][Skin7]); 
	INI_Int("Skin8", Groups[i][Skin8]); 
	INI_Int("Skin9", Groups[i][Skin9]); 
	INI_Int("Skin10", Groups[i][Skin10]); 
	INI_Int("Skin11", Groups[i][Skin11]);
	INI_Int("Skin12", Groups[i][Skin12]); 
	INI_Int("HQInteriorID", Groups[i][HQInteriorID]);
	INI_Float("HQInteriorX", Groups[i][HQInteriorX]);
	INI_Float("HQInteriorY", Groups[i][HQInteriorY]);
	INI_Float("HQInteriorZ", Groups[i][HQInteriorZ]);
	INI_Int("HQExteriorID", Groups[i][HQExteriorID]);
	INI_Float("HQExteriorX", Groups[i][HQExteriorX]);
	INI_Float("HQExteriorY", Groups[i][HQExteriorY]);
	INI_Float("HQExteriorZ", Groups[i][HQExteriorZ]);
	INI_Float("SafeX", Groups[i][SafeX]);
	INI_Float("SafeY", Groups[i][SafeY]); 
	INI_Float("SafeZ", Groups[i][SafeZ]); 
	INI_Int("SafeInteriorID", Groups[i][SafeInteriorID]); 
	INI_Int("SafeMoney", Groups[i][SafeMoney]);
	INI_Int("HQLock", Groups[i][HQLock]);
	INI_Int("Pot", Groups[i][SavedPot]);
	INI_Int("Crack", Groups[i][SavedCrack]);
	INI_Int("DisbandMinute", Groups[i][DisbandMinute]);
	INI_Int("DisbandHour", Groups[i][DisbandHour]);
	INI_Int("DisbandDay", Groups[i][DisbandDay]);
	INI_Int("DisbandMonth", Groups[i][DisbandMonth]);
	INI_Int("DisbandYear", Groups[i][DisbandYear]);
	INI_Int("SafeWorld", Groups[i][SafeWorld]);
	INI_String("MOTD", Groups[i][MOTD], 255);
	INI_Int("Materials", Groups[i][SavedMats][0]);
	INI_Int("Materials1", Groups[i][SavedMats][1]);
	INI_Int("Materials2", Groups[i][SavedMats][2]);
	INI_Int("Speed", Groups[i][SavedSpeed]); 
	
	INI_Int("MemberCount", Groups[i][MemberCount]);
	
	INI_Float("HQExteriorX2", Groups[i][HQExterior2][0]);
	INI_Float("HQExteriorY2", Groups[i][HQExterior2][1]);
	INI_Float("HQExteriorZ2", Groups[i][HQExterior2][2]);
	INI_Float("HQInteriorX2", Groups[i][HQInterior2][0]);
	INI_Float("HQInteriorY2", Groups[i][HQInterior2][1]);
	INI_Float("HQInteriorZ2", Groups[i][HQInterior2][2]);
	INI_Int("HQExteriorID2", Groups[i][HQExteriorID2]);
	INI_Int("HQExteriorVW2", Groups[i][HQExteriorVW2]);
	INI_Int("HQInteriorID2", Groups[i][HQInteriorID2]);
	INI_Int("HQLock2", Groups[i][HQLock2]);
	
	if(Groups[i][CommandTypes] == 7)
	{
		INI_Int("Chips", Groups[i][Chips]);
		INI_Int("ChipsVW", Groups[i][ChipsVW]);
		INI_Int("ChipShopLock", Groups[i][ChipShopLock]);
		INI_Float("ChipPosX", Groups[i][ChipPos][0]);
		INI_Float("ChipPosY", Groups[i][ChipPos][1]);
		INI_Float("ChipPosZ", Groups[i][ChipPos][2]);
		
		for(new x; x < MAX_SLOTS; x++)
		{
			new tmpstr[32];
			format(tmpstr, sizeof(tmpstr), "slotsUsed%d", x);
			INI_Int(tmpstr, Groups[i][slotsUsed][x]); 
			
			format(tmpstr, sizeof(tmpstr), "slotsX%d", x);
			INI_Float(tmpstr, Groups[i][slotsX][x]); 
			
			format(tmpstr, sizeof(tmpstr), "slotsY%d", x);
			INI_Float(tmpstr, Groups[i][slotsY][x]); 
			
			format(tmpstr, sizeof(tmpstr), "slotsZ%d", x);
			INI_Float(tmpstr, Groups[i][slotsZ][x]); 
		}
		
		for(new x; x < 6; x++)
		{
			new tmpstr[32];
			format(tmpstr, sizeof(tmpstr), "SlotPrizes%d", x);
			INI_Int(tmpstr, Groups[i][SlotPrizes][x]); 
		}
	}
	return 1;
}

stock SetupFactionORM(id)
{
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][GroupSQL], "FactionSQL");
	orm_addvar_string(Groups[id][ORM_ID], Groups[id][GroupName], 255, "GroupName");
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][CommandTypes], "CommandTypes");
	orm_addvar_string(Groups[id][ORM_ID], Groups[id][RankName0], 255, "RankName0");
	orm_addvar_string(Groups[id][ORM_ID], Groups[id][RankName1], 255, "RankName1");
	orm_addvar_string(Groups[id][ORM_ID], Groups[id][RankName2], 255, "RankName2");
	orm_addvar_string(Groups[id][ORM_ID], Groups[id][RankName3], 255, "RankName3");
	orm_addvar_string(Groups[id][ORM_ID], Groups[id][RankName4], 255, "RankName4");
	orm_addvar_string(Groups[id][ORM_ID], Groups[id][RankName5], 255, "RankName5");
	orm_addvar_string(Groups[id][ORM_ID], Groups[id][RankName6], 255, "RankName6");
	orm_addvar_string(Groups[id][ORM_ID], Groups[id][RankName7], 255, "RankName7");
	orm_addvar_string(Groups[id][ORM_ID], Groups[id][RankName8], 255, "RankName8");
	orm_addvar_string(Groups[id][ORM_ID], Groups[id][RankName9], 255, "RankName9");
	orm_addvar_string(Groups[id][ORM_ID], Groups[id][RankName10], 255, "RankName10");
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][Skin0], "Skin0"); 
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][Skin1], "Skin1"); 
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][Skin2], "Skin2"); 
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][Skin3], "Skin3"); 
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][Skin4], "Skin4"); 
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][Skin5], "Skin5"); 
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][Skin6], "Skin6"); 
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][Skin7], "Skin7"); 
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][Skin8], "Skin8"); 
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][Skin9], "Skin9"); 
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][Skin10], "Skin10"); 
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][Skin11], "Skin11");
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][Skin12], "Skin12"); 
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][HQInteriorID], "HQInteriorID");
	orm_addvar_float(Groups[id][ORM_ID], Groups[id][HQInteriorX], "HQInteriorX");
	orm_addvar_float(Groups[id][ORM_ID], Groups[id][HQInteriorY], "HQInteriorY");
	orm_addvar_float(Groups[id][ORM_ID], Groups[id][HQInteriorZ], "HQInteriorZ");
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][HQExteriorID], "HQExteriorID");
	orm_addvar_float(Groups[id][ORM_ID], Groups[id][HQExteriorX], "HQExteriorX");
	orm_addvar_float(Groups[id][ORM_ID], Groups[id][HQExteriorY], "HQExteriorY");
	orm_addvar_float(Groups[id][ORM_ID], Groups[id][HQExteriorZ], "HQExteriorZ");
	orm_addvar_float(Groups[id][ORM_ID], Groups[id][SafeX], "SafeX");
	orm_addvar_float(Groups[id][ORM_ID], Groups[id][SafeY], "SafeY"); 
	orm_addvar_float(Groups[id][ORM_ID], Groups[id][SafeZ], "SafeZ"); 
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][SafeInteriorID], "SafeInteriorID"); 
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][SafeMoney], "SafeMoney");
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][HQLock], "HQLock");
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][SavedPot], "Pot");
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][SavedCrack], "Crack");
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][DisbandMinute], "DisbandMinute");
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][DisbandHour], "DisbandHour");
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][DisbandDay], "DisbandDay");
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][DisbandMonth], "DisbandMonth");
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][DisbandYear], "DisbandYear");
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][SafeWorld], "SafeWorld");
	orm_addvar_string(Groups[id][ORM_ID], Groups[id][MOTD], 255, "MOTD");
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][SavedMats][0], "Materials");
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][SavedMats][1], "Materials1");
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][SavedMats][2], "Materials2");
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][SavedSpeed], "Speed"); 
	orm_addvar_float(Groups[id][ORM_ID], Groups[id][HQExterior2][0], "HQExteriorX2");
	orm_addvar_float(Groups[id][ORM_ID], Groups[id][HQExterior2][1], "HQExteriorY2");
	orm_addvar_float(Groups[id][ORM_ID], Groups[id][HQExterior2][2], "HQExteriorZ2");
	orm_addvar_float(Groups[id][ORM_ID], Groups[id][HQInterior2][0], "HQInteriorX2");
	orm_addvar_float(Groups[id][ORM_ID], Groups[id][HQInterior2][1], "HQInteriorY2");
	orm_addvar_float(Groups[id][ORM_ID], Groups[id][HQInterior2][2], "HQInteriorZ2");
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][HQExteriorID2], "HQExteriorID2");
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][HQExteriorVW2], "HQExteriorVW2");
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][HQInteriorID2], "HQInteriorID2");
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][HQLock2], "HQLock2");
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][PayForFuel], "PayForFuel");
	return 1;
}

stock SetupCasinoORM(id)
{
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][Chips], "Chips");
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][ChipsVW], "ChipsVW");
	orm_addvar_int(Groups[id][ORM_ID], Groups[id][ChipShopLock], "ChipShopLock");
	orm_addvar_float(Groups[id][ORM_ID], Groups[id][ChipPos][0], "ChipPosX");
	orm_addvar_float(Groups[id][ORM_ID], Groups[id][ChipPos][1], "ChipPosY");
	orm_addvar_float(Groups[id][ORM_ID], Groups[id][ChipPos][2], "ChipPosZ");
	for(new x; x < MAX_SLOTS; x++)
	{
		new tmpstr[32];
		format(tmpstr, sizeof(tmpstr), "slotsUsed%d", x);
		orm_addvar_int(Groups[id][ORM_ID], Groups[id][slotsUsed][x], tmpstr); 
		
		format(tmpstr, sizeof(tmpstr), "slotsX%d", x);
		orm_addvar_float(Groups[id][ORM_ID], Groups[id][slotsX][x], tmpstr); 
		
		format(tmpstr, sizeof(tmpstr), "slotsY%d", x);
		orm_addvar_float(Groups[id][ORM_ID], Groups[id][slotsY][x], tmpstr); 
		
		format(tmpstr, sizeof(tmpstr), "slotsZ%d", x);
		orm_addvar_float(Groups[id][ORM_ID], Groups[id][slotsZ][x], tmpstr); 
	}
	for(new x; x < 6; x++)
	{
		new tmpstr[32];
		format(tmpstr, sizeof(tmpstr), "SlotPrizes%d", x);
		orm_addvar_int(Groups[id][ORM_ID], Groups[id][SlotPrizes][x], tmpstr); 
	}
	return 1;
}

/*### End of Group related functions ###*/
	
/*### Start of Housing related functions ###*/ 
stock SaveHouse(i, create = 0)
{
	if(create == 1)
		orm_insert(Houses[i][ORM_ID]);
	else 
	{
		if(Houses[i][ORM_ID] == ORM:0)
		{
			printf("[ORM ERROR] Attempted to save an orm id of 0. (House %d)", i);
			return 1;
		}
		
		orm_update(Houses[i][ORM_ID]);
	}
	
	//for(new f; f < MAX_FURNI; f++)
		//SaveHouseFurni(i, f);
	
	printf("[system] House %d saved.", i);
	return 1;
}

forward LoadHouse(houseid, tag[], name[], value[]);
public LoadHouse(houseid, tag[], name[], value[])
{
	INI_Int("InteriorID", Houses[houseid][hInteriorID]);
	INI_Float("InteriorX", Houses[houseid][hInteriorX]);
	INI_Float("InteriorY", Houses[houseid][hInteriorY]);
	INI_Float("InteriorZ", Houses[houseid][hInteriorZ]);
	
	INI_Int("HousePrice", Houses[houseid][HousePrice]);
	
	INI_Int("ExteriorID", Houses[houseid][hExteriorID]);
	INI_Float("ExteriorX", Houses[houseid][hExteriorX]);
	INI_Float("ExteriorY", Houses[houseid][hExteriorY]);
	INI_Float("ExteriorZ", Houses[houseid][hExteriorZ]);
	INI_Int("RadioInstalled", Houses[houseid][RadioInstalled]);
	INI_String("Owner", Houses[houseid][hOwner], 255); 
	INI_Int("LockStatus", Houses[houseid][LockStatus]);
	
	INI_Int("VaultMoney", Houses[houseid][VaultMoney]);
	INI_Int("HouseCocaine", Houses[houseid][HouseCocaine]);
	INI_Int("HousePot", Houses[houseid][HousePot]);
	INI_Int("HouseMaterials", Houses[houseid][HouseMaterials][0]);
	INI_Int("HouseMaterials1", Houses[houseid][HouseMaterials][1]);
	INI_Int("HouseMaterials2", Houses[houseid][HouseMaterials][2]);
	INI_Int("WeaponSlot1", Houses[houseid][Weapons][0]); 
	INI_Int("WeaponSlot2", Houses[houseid][Weapons][1]); 
	INI_Int("WeaponSlot3", Houses[houseid][Weapons][2]); 
	INI_Int("WeaponSlot4", Houses[houseid][Weapons][3]); 
	INI_Int("WeaponSlot5", Houses[houseid][Weapons][4]); 
	
	INI_String("HouseStorage", Houses[houseid][HouseStorage], 500); 
	INI_Int("HouseStorageSize", Houses[houseid][HouseStorageSize]);

	INI_Int("Workbench", Houses[houseid][Workbench]);
	INI_Int("Beers", Houses[houseid][hBeers]);
	INI_Int("Pizzas", Houses[houseid][hPizzas]);
	
	INI_Int("PotGrow1", Houses[houseid][PotGrow][0]);
	INI_Int("PotTime1", Houses[houseid][PotTime][0]);
	INI_Int("PotGrow2", Houses[houseid][PotGrow][1]);
	INI_Int("PotTime2", Houses[houseid][PotTime][1]); 
	
	INI_Int("GrowLightInstalled", Houses[houseid][GrowLightInstalled]); 
	
	INI_String("KeyHolder1", Houses[houseid][KeyHolder1], 24);
	INI_String("KeyHolder2", Houses[houseid][KeyHolder2], 24);
	
	INI_Int("Keypad", Houses[houseid][Keypad]);
	INI_Int("ExteriorVW", Houses[houseid][hExteriorVW]);
	INI_Int("HouseType", Houses[houseid][HouseType]);
	return 1;
}

stock SetupHouseORM(houseid)
{
	orm_addvar_int(Houses[houseid][ORM_ID], Houses[houseid][HouseSQL], "HouseSQL");
	orm_addvar_int(Houses[houseid][ORM_ID], Houses[houseid][hInteriorID], "InteriorID");
	orm_addvar_float(Houses[houseid][ORM_ID], Houses[houseid][hInteriorX], "InteriorX");
	orm_addvar_float(Houses[houseid][ORM_ID], Houses[houseid][hInteriorY], "InteriorY");
	orm_addvar_float(Houses[houseid][ORM_ID], Houses[houseid][hInteriorZ], "InteriorZ");
	orm_addvar_int(Houses[houseid][ORM_ID], Houses[houseid][HousePrice], "HousePrice");
	orm_addvar_int(Houses[houseid][ORM_ID], Houses[houseid][hExteriorID], "ExteriorID");
	orm_addvar_float(Houses[houseid][ORM_ID], Houses[houseid][hExteriorX], "ExteriorX");
	orm_addvar_float(Houses[houseid][ORM_ID], Houses[houseid][hExteriorY], "ExteriorY");
	orm_addvar_float(Houses[houseid][ORM_ID], Houses[houseid][hExteriorZ], "ExteriorZ");
	orm_addvar_int(Houses[houseid][ORM_ID], Houses[houseid][RadioInstalled], "RadioInstalled");
	orm_addvar_string(Houses[houseid][ORM_ID], Houses[houseid][hOwner], 255, "Owner"); 
	orm_addvar_int(Houses[houseid][ORM_ID], Houses[houseid][LockStatus], "LockStatus");
	orm_addvar_string(Houses[houseid][ORM_ID], Houses[houseid][HouseStorage], 500, "HouseStorage"); 
	orm_addvar_int(Houses[houseid][ORM_ID], Houses[houseid][HouseStorageSize], "HouseStorageSize");
	orm_addvar_int(Houses[houseid][ORM_ID], Houses[houseid][HouseStorageBase], "HouseStorageBase");
	orm_addvar_int(Houses[houseid][ORM_ID], Houses[houseid][HouseStorageExtra], "HouseStorageExtra");
	orm_addvar_int(Houses[houseid][ORM_ID], Houses[houseid][Workbench], "Workbench");
	orm_addvar_int(Houses[houseid][ORM_ID], Houses[houseid][hBeers], "Beers");
	orm_addvar_int(Houses[houseid][ORM_ID], Houses[houseid][hPizzas], "Pizzas");
	orm_addvar_int(Houses[houseid][ORM_ID], Houses[houseid][PotGrow][0], "PotGrow1");
	orm_addvar_int(Houses[houseid][ORM_ID], Houses[houseid][PotTime][0], "PotTime1");
	orm_addvar_int(Houses[houseid][ORM_ID], Houses[houseid][PotGrow][1], "PotGrow2");
	orm_addvar_int(Houses[houseid][ORM_ID], Houses[houseid][PotTime][1], "PotTime2");
	orm_addvar_int(Houses[houseid][ORM_ID], Houses[houseid][GrowLightInstalled], "GrowLightInstalled"); 
	orm_addvar_string(Houses[houseid][ORM_ID], Houses[houseid][KeyHolder1], 24, "KeyHolder1");
	orm_addvar_string(Houses[houseid][ORM_ID], Houses[houseid][KeyHolder2], 24, "KeyHolder2");
	orm_addvar_int(Houses[houseid][ORM_ID], Houses[houseid][Keypad], "Keypad");
	orm_addvar_int(Houses[houseid][ORM_ID], Houses[houseid][hExteriorVW], "ExteriorVW");
	orm_addvar_int(Houses[houseid][ORM_ID], Houses[houseid][HouseType], "HouseType");
	orm_addvar_int(Houses[houseid][ORM_ID], Houses[houseid][VentUpgrade], "VentUpgrade");
	orm_addvar_int(Houses[houseid][ORM_ID], Houses[houseid][hFakeOwner], "hFakeOwner");
	return 1;
}

/*### End of Housing related functions ###*/ 

/* ### Start of business related functions ###*/

stock SaveBusiness(i, create = 0)
{
	if(create == 1)
		orm_insert(Businesses[i][ORM_ID]);
	else 
	{
		if(Businesses[i][ORM_ID] == ORM:0)
		{
			printf("[ORM ERROR] Attempted to save an orm id of 0.(Business %d)", i);
			return 1;
		}
		orm_update(Businesses[i][ORM_ID]);
	}
	printf("[system] Business %d saved.", i);
	
	return 1;
}

forward LoadBusiness(businessid, tag[], name[], value[]);
public LoadBusiness(businessid, tag[], name[], value[])
{
	INI_Float("ExteriorX", Businesses[businessid][bExteriorX]);
	INI_Float("ExteriorY", Businesses[businessid][bExteriorY]);
	INI_Float("ExteriorZ", Businesses[businessid][bExteriorZ]); 
	INI_Int("ExteriorID", Businesses[businessid][bExteriorID]);
	
	INI_Float("InteriorX", Businesses[businessid][bInteriorX]);
	INI_Float("InteriorY", Businesses[businessid][bInteriorY]);
	INI_Float("InteriorZ", Businesses[businessid][bInteriorZ]); 
	INI_Int("InteriorID", Businesses[businessid][bInteriorID]);
	INI_Float("InteractX", Businesses[businessid][bInteractX]);
	INI_Float("InteractY", Businesses[businessid][bInteractY]);
	INI_Float("InteractZ", Businesses[businessid][bInteractZ]); 
	INI_Int("Type", Businesses[businessid][bType]);
	INI_Int("Vault", Businesses[businessid][bVault]);
	INI_Int("Price", Businesses[businessid][bPrice]);
	INI_String("Owner", Businesses[businessid][bOwner], 255);

	INI_Int("LockStatus", Businesses[businessid][bLockStatus]); 
	
	INI_String("Name", Businesses[businessid][bName], 255); 
	
	INI_Int("Supplies", Businesses[businessid][bSupplies]); 
	INI_Int("MaxSupplies", Businesses[businessid][bMaxSupplies]); 
	INI_Int("ProductPrice1", Businesses[businessid][bProductPrice1]); 
	INI_Int("ProductPrice2", Businesses[businessid][bProductPrice2]);
	INI_Int("ProductPrice3", Businesses[businessid][bProductPrice3]);
	INI_Int("ProductPrice4", Businesses[businessid][bProductPrice4]);
	INI_Int("ProductPrice5", Businesses[businessid][bProductPrice5]);
	INI_Int("ProductPrice6", Businesses[businessid][bProductPrice6]);
	INI_Int("ProductPrice7", Businesses[businessid][bProductPrice7]);
	INI_Int("ProductPrice8", Businesses[businessid][bProductPrice8]);
	INI_Int("ProductPrice9", Businesses[businessid][bProductPrice9]);
	INI_Int("ProductPrice10", Businesses[businessid][bProductPrice10]);
	INI_Int("ProductPrice11", Businesses[businessid][bProductPrice11]);
	INI_Int("ProductPrice12", Businesses[businessid][bProductPrice12]);
	INI_Int("ProductPrice13", Businesses[businessid][bProductPrice13]);
	INI_Int("ProductPrice14", Businesses[businessid][bProductPrice14]);
	INI_Int("ProductPrice15", Businesses[businessid][bProductPrice15]); 
	INI_Int("SupplyStatus", Businesses[businessid][bSupplyStatus]); 

	INI_Int("RadioInstalled", Businesses[businessid][RadioInstalled]); 
	
	INI_Int("SupplyPrice", Businesses[businessid][bSupplyPrice]); 
	
	INI_String("FoodName1", Businesses[businessid][bFoodName1], 32); 
	INI_String("FoodName2", Businesses[businessid][bFoodName2], 32); 
	INI_String("FoodName3", Businesses[businessid][bFoodName3], 32); 
	INI_String("FoodName4", Businesses[businessid][bFoodName4], 32); 
	
	INI_Int("TotalHotelRooms", Businesses[businessid][TotalHotelRooms]); 
	
	INI_Float("SafeX", Businesses[businessid][bSafeX]); 
	INI_Float("SafeY", Businesses[businessid][bSafeY]); 
	INI_Float("SafeZ", Businesses[businessid][bSafeZ]);  
	
	INI_Int("LinkedGroup", Businesses[businessid][bLinkedGroup]);
	INI_Int("Materials", Businesses[businessid][bMaterials][0]);
	INI_Int("Materials1", Businesses[businessid][bMaterials][1]);
	INI_Int("Materials2", Businesses[businessid][bMaterials][2]);
	INI_Int("Cocaine", Businesses[businessid][bCocaine]);
	INI_Int("Pot", Businesses[businessid][bPot]);
	INI_Int("Speed", Businesses[businessid][bSpeed]); 
	
	INI_String("bKeyOwner1", Businesses[businessid][bKeyOwner1], 25);
	INI_String("bKeyOwner2", Businesses[businessid][bKeyOwner2], 25); 
	
	for(new i; i < MAX_PUMPS; i++)
	{
		new tmp[32];
		format(tmp, sizeof(tmp), "GasPump%d", i);
		INI_Int(tmp, Businesses[businessid][GasPump][i]);
		format(tmp, sizeof(tmp), "GasX%d", i);
		INI_Float(tmp, Businesses[businessid][GasX][i]); 
		format(tmp, sizeof(tmp), "GasY%d", i);
		INI_Float(tmp, Businesses[businessid][GasY][i]);
		format(tmp, sizeof(tmp), "GasZ%d", i);
		INI_Float(tmp, Businesses[businessid][GasZ][i]);
	}
	
	INI_Int("GasVolume", Businesses[businessid][GasVolume]); 
	INI_Float("FuelPointX", Businesses[businessid][FuelPointX]); 
	INI_Float("FuelPointY", Businesses[businessid][FuelPointY]); 
	INI_Float("FuelPointZ", Businesses[businessid][FuelPointZ]);
	INI_Int("Weapon0", Businesses[businessid][Weapons][0]);
	INI_Int("Weapon1", Businesses[businessid][Weapons][1]);
	
	INI_Float("TrashX", Businesses[businessid][BusinessTrashPos][0]);
	INI_Float("TrashY", Businesses[businessid][BusinessTrashPos][1]);
	INI_Float("TrashZ", Businesses[businessid][BusinessTrashPos][2]);
	INI_Float("TrashRotX", Businesses[businessid][BusinessTrashRot][0]);
	INI_Float("TrashRotY", Businesses[businessid][BusinessTrashRot][1]);
	INI_Float("TrashRotZ", Businesses[businessid][BusinessTrashRot][2]);
	INI_Int("TrashAmount", Businesses[businessid][BusinessTrashAmount]);
	INI_Int("TrashStatus", Businesses[businessid][BusinessTrashStatus]);
	
	return 1;
}

stock SetupBusinessORM(bid)
{
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][BusinessSQL], "BusinessSQL");
	orm_addvar_float(Businesses[bid][ORM_ID], Businesses[bid][bExteriorX], "ExteriorX");
	orm_addvar_float(Businesses[bid][ORM_ID], Businesses[bid][bExteriorY], "ExteriorY");
	orm_addvar_float(Businesses[bid][ORM_ID], Businesses[bid][bExteriorZ], "ExteriorZ"); 
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bExteriorID], "ExteriorID");
	orm_addvar_float(Businesses[bid][ORM_ID], Businesses[bid][bInteriorX], "InteriorX");
	orm_addvar_float(Businesses[bid][ORM_ID], Businesses[bid][bInteriorY], "InteriorY");
	orm_addvar_float(Businesses[bid][ORM_ID], Businesses[bid][bInteriorZ], "InteriorZ"); 
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bInteriorID], "InteriorID");
	orm_addvar_float(Businesses[bid][ORM_ID], Businesses[bid][bInteractX], "InteractX");
	orm_addvar_float(Businesses[bid][ORM_ID], Businesses[bid][bInteractY], "InteractY");
	orm_addvar_float(Businesses[bid][ORM_ID], Businesses[bid][bInteractZ], "InteractZ"); 
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bType], "Type");
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bVault], "Vault");
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bPrice], "Price");
	orm_addvar_string(Businesses[bid][ORM_ID], Businesses[bid][bOwner], 255, "Owner");
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bLockStatus], "LockStatus"); 
	orm_addvar_string(Businesses[bid][ORM_ID], Businesses[bid][bName], 255, "Name"); 
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bSupplies], "Supplies"); 
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bMaxSupplies], "MaxSupplies"); 
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bProductPrice1], "ProductPrice1"); 
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bProductPrice2], "ProductPrice2");
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bProductPrice3], "ProductPrice3");
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bProductPrice4], "ProductPrice4");
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bProductPrice5], "ProductPrice5");
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bProductPrice6], "ProductPrice6");
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bProductPrice7], "ProductPrice7");
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bProductPrice8], "ProductPrice8");
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bProductPrice9], "ProductPrice9");
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bProductPrice10], "ProductPrice10");
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bProductPrice11], "ProductPrice11");
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bProductPrice12], "ProductPrice12");
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bProductPrice13], "ProductPrice13");
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bProductPrice14], "ProductPrice14");
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bProductPrice15], "ProductPrice15"); 
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bSupplyStatus], "SupplyStatus");
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][RadioInstalled], "RadioInstalled"); 
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bSupplyPrice], "SupplyPrice"); 
	orm_addvar_string(Businesses[bid][ORM_ID], Businesses[bid][bFoodName1], 32, "FoodName1"); 
	orm_addvar_string(Businesses[bid][ORM_ID], Businesses[bid][bFoodName2], 32, "FoodName2"); 
	orm_addvar_string(Businesses[bid][ORM_ID], Businesses[bid][bFoodName3], 32, "FoodName3"); 
	orm_addvar_string(Businesses[bid][ORM_ID], Businesses[bid][bFoodName4], 32, "FoodName4"); 
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][TotalHotelRooms], "TotalHotelRooms"); 
	orm_addvar_float(Businesses[bid][ORM_ID], Businesses[bid][bSafeX], "SafeX"); 
	orm_addvar_float(Businesses[bid][ORM_ID], Businesses[bid][bSafeY], "SafeY"); 
	orm_addvar_float(Businesses[bid][ORM_ID], Businesses[bid][bSafeZ], "SafeZ");  
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bLinkedGroup], "LinkedGroup");
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bMaterials][0], "Materials");
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bMaterials][1], "Materials1");
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bMaterials][2], "Materials2");
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bCocaine], "Cocaine");
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bPot], "Pot");
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bSpeed], "Speed");
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bArmour][0], "Armour0"); 
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bArmour][1], "Armour1"); 
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bArmour][2], "Armour2"); 		
	orm_addvar_string(Businesses[bid][ORM_ID], Businesses[bid][bKeyOwner1], 25, "bKeyOwner1");
	orm_addvar_string(Businesses[bid][ORM_ID], Businesses[bid][bKeyOwner2], 25, "bKeyOwner2"); 
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][InterComInstalled], "InterComInstalled");
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bStorage], "Storage"); 
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][bWorkbench], "Workbench"); 
	for(new i; i < MAX_PUMPS; i++)
	{
		new tmp[32];
		format(tmp, sizeof(tmp), "GasPump%d", i);
		orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][GasPump][i], tmp);
		format(tmp, sizeof(tmp), "GasX%d", i);
		orm_addvar_float(Businesses[bid][ORM_ID], Businesses[bid][GasX][i], tmp); 
		format(tmp, sizeof(tmp), "GasY%d", i);
		orm_addvar_float(Businesses[bid][ORM_ID], Businesses[bid][GasY][i], tmp);
		format(tmp, sizeof(tmp), "GasZ%d", i);
		orm_addvar_float(Businesses[bid][ORM_ID], Businesses[bid][GasZ][i], tmp);
	}
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][GasVolume], "GasVolume"); 
	orm_addvar_float(Businesses[bid][ORM_ID], Businesses[bid][FuelPointX], "FuelPointX"); 
	orm_addvar_float(Businesses[bid][ORM_ID], Businesses[bid][FuelPointY], "FuelPointY"); 
	orm_addvar_float(Businesses[bid][ORM_ID], Businesses[bid][FuelPointZ], "FuelPointZ");
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][Weapons][0], "Weapon0");
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][Weapons][1], "Weapon1");
	orm_addvar_float(Businesses[bid][ORM_ID], Businesses[bid][BusinessTrashPos][0], "TrashX");
	orm_addvar_float(Businesses[bid][ORM_ID], Businesses[bid][BusinessTrashPos][1], "TrashY");
	orm_addvar_float(Businesses[bid][ORM_ID], Businesses[bid][BusinessTrashPos][2], "TrashZ");
	orm_addvar_float(Businesses[bid][ORM_ID], Businesses[bid][BusinessTrashRot][0], "TrashRotX");
	orm_addvar_float(Businesses[bid][ORM_ID], Businesses[bid][BusinessTrashRot][1], "TrashRotY");
	orm_addvar_float(Businesses[bid][ORM_ID], Businesses[bid][BusinessTrashRot][2], "TrashRotZ");
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][BusinessTrashAmount], "TrashAmount");
	orm_addvar_int(Businesses[bid][ORM_ID], Businesses[bid][BusinessTrashStatus], "TrashStatus");
	return 1;
}

/*
stock SaveHotelRoom(businessid, hotelroomid, create = 0)
{
	if(Businesses[businessid][bType] == 19) 
	{
		new string[128]; 
		new idx = businessid; 
		new hrID = hotelroomid; 
		format(string, sizeof(string), "Businesses/HotelRooms/B%i_HotelRoom_%i.ini", idx, hrID);
		
		if(!fexist(string) && create == 0)
			return 1;
			
		new INI:file = INI_Open(string); 
		INI_WriteFloat(file, "HotelRoomExtPosX", hRoom[idx][hrID][hrExtPos][0]);
		INI_WriteFloat(file, "HotelRoomExtPosY", hRoom[idx][hrID][hrExtPos][1]);
		INI_WriteFloat(file, "HotelRoomExtPosZ", hRoom[idx][hrID][hrExtPos][2]); 
		INI_WriteInt(file, "HotelRoomExtVW", hRoom[idx][hrID][hrExtVW]); 
		
		INI_WriteFloat(file, "HotelRoomIntPosX", hRoom[idx][hrID][hrIntPos][0]);
		INI_WriteFloat(file, "HotelRoomIntPosY", hRoom[idx][hrID][hrIntPos][1]);
		INI_WriteFloat(file, "HotelRoomIntPosZ", hRoom[idx][hrID][hrIntPos][2]); 
		INI_WriteInt(file, "HotelRoomIntID", 	hRoom[idx][hrID][hrIntID]);
		INI_WriteInt(file, "HotelRoomIntVW", hRoom[idx][hrID][hrIntVW]); 
		
		INI_WriteString(file, "HotelRoomOwner", hRoom[idx][hrID][hrOwner]); 
		INI_WriteInt(file, "HotelRoomPot", hRoom[idx][hrID][hrPot]);
		INI_WriteInt(file, "HotelRoomCocaine", hRoom[idx][hrID][hrCocaine]); 
		INI_WriteInt(file, "HotelRoomMaterials", hRoom[idx][hrID][hrMaterials]); 
		INI_WriteInt(file, "HotelRoomWeapon", hRoom[idx][hrID][hrWeapon]);
		INI_WriteInt(file, "HotelRoomSpeed", hRoom[idx][hrID][hrSpeed]); 
		
		INI_WriteInt(file, "HotelRoomLockStatus", hRoom[idx][hrID][hrLockStatus]);
		INI_WriteInt(file, "HotelRoomRentPrice", hRoom[idx][hrID][hrRentPrice]); 
		INI_Close(file); 
		printf("[system] Business ID: %i Hotel Room %i Saved.", businessid, hotelroomid); 
		
	}
	return 1;
}

stock DiniLoadHotelRoom(businessid, hotelroomid)
{
	if(Businesses[businessid][bType] == 19) 
	{
		new string[128]; 
		new idx = businessid; 
		new hrID = hotelroomid; 
		format(string, sizeof(string), "Businesses/HotelRooms/B%i_HotelRoom_%i.ini", idx, hrID);
		
		if(fexist(string))
		{
			hRoom[idx][hrID][hrExtPos][0] = dini_Float(string, "HotelRoomExtPosX"); 
			hRoom[idx][hrID][hrExtPos][1] = dini_Float(string, "HotelRoomExtPosY");
			hRoom[idx][hrID][hrExtPos][2] = dini_Float(string, "HotelRoomExtPosZ");
			hRoom[idx][hrID][hrExtVW] = dini_Int(string, "HotelRoomExtVW"); 
			
			hRoom[idx][hrID][hrIntPos][0] = dini_Float(string, "HotelRoomIntPosX"); 
			hRoom[idx][hrID][hrIntPos][1] = dini_Float(string, "HotelRoomIntPosY"); 
			hRoom[idx][hrID][hrIntPos][2] = dini_Float(string, "HotelRoomIntPosZ"); 
			hRoom[idx][hrID][hrIntID] = dini_Int(string, "HotelRoomIntID");
			hRoom[idx][hrID][hrIntVW] = dini_Int(string, "HotelRoomIntVW"); 
			
			format(hRoom[idx][hrID][hrOwner], 24, "%s", dini_Get(string, "HotelRoomOwner")); 
			
			hRoom[idx][hrID][hrPot] = dini_Int(string, "HotelRoomPot"); 
			hRoom[idx][hrID][hrCocaine] = dini_Int(string, "HotelRoomCocaine"); 
			hRoom[idx][hrID][hrMaterials] = dini_Int(string, "HotelRoomMaterials"); 
			hRoom[idx][hrID][hrWeapon] = dini_Int(string, "HotelRoomWeapon");  
			
			hRoom[idx][hrID][hrLockStatus] = dini_Int(string, "HotelRoomLockStatus"); 
			hRoom[idx][hrID][hrRentPrice] = dini_Int(string, "HotelRoomRentPrice"); 
			
			if(!strcmp("Nobody", hRoom[idx][hrID][hrOwner], true))
			{
				hRoom[idx][hrID][hrIcon] = CreateDynamicPickup(1273, 1, hRoom[idx][hrID][hrExtPos][0], hRoom[idx][hrID][hrExtPos][1], hRoom[idx][hrID][hrExtPos][2], hRoom[idx][hrID][hrExtVW], Businesses[businessid][bInteriorID]);  
				hRoom[idx][hrID][hrLockStatus] = 0; 
			}
			else
			{
				hRoom[idx][hrID][hrIcon] = CreateDynamicPickup(1272, 1, hRoom[idx][hrID][hrExtPos][0], hRoom[idx][hrID][hrExtPos][1], hRoom[idx][hrID][hrExtPos][2], hRoom[idx][hrID][hrExtVW], Businesses[businessid][bInteriorID]);  
				
			}
			printf("[system] Business ID: %d Hotel Room %d Loaded!", businessid, hotelroomid);
		}
	}
	return 1;
}
new tempBID;
stock InitHotelRooms()
{
	for(new b; b < MAX_BUSINESSES; b++)
	{	
		if(Businesses[b][bType] != 19)
			continue; 
		
		tempBID = b;
		for(new i = 1; i < MAX_HOTEL_ROOMS; i ++)
		{
			new string[128]; 
			format(string, sizeof(string), "Businesses/HotelRooms/B%i_HotelRoom_%i.ini", b, i);
			INI_ParseFile(string, "LoadHotelRoom", .bExtra = true, .extra = i, .bPassTag = true);	
			
			if(!strcmp("Nobody", hRoom[b][i][hrOwner], true))
			{
				hRoom[b][i][hrIcon] = CreateDynamicPickup(1273, 1, hRoom[b][i][hrExtPos][0], hRoom[b][i][hrExtPos][1], hRoom[b][i][hrExtPos][2], hRoom[b][i][hrExtVW], Businesses[b][bInteriorID]);  
				hRoom[b][i][hrLockStatus] = 0; 
				format(string, sizeof(string), "Hotel Room %d\nAvailable to rent for %s\n((/rentroom))", i, PrettyMoney(hRoom[b][i][hrRentPrice]));
				hRoom[b][i][hrLabel] = CreateDynamic3DTextLabel(string, 0x21DD00FF, hRoom[b][i][hrExtPos][0], hRoom[b][i][hrExtPos][1], hRoom[b][i][hrExtPos][2] + 0.5, 25, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0 ,hRoom[b][i][hrExtVW], Businesses[b][bInteriorID]); 
			}
			else
			{
				hRoom[b][i][hrIcon] = CreateDynamicPickup(1272, 1, hRoom[b][i][hrExtPos][0], hRoom[b][i][hrExtPos][1], hRoom[b][i][hrExtPos][2], hRoom[b][i][hrExtVW], Businesses[b][bInteriorID]);  
				format(string, sizeof(string), "Hotel Room %d\nOwner: %s", i, hRoom[b][i][hrOwner]);
				hRoom[b][i][hrLabel] = CreateDynamic3DTextLabel(string, 0x21DD00FF, hRoom[b][i][hrExtPos][0], hRoom[b][i][hrExtPos][1], hRoom[b][i][hrExtPos][2] + 0.5, 25, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0 ,hRoom[b][i][hrExtVW], Businesses[b][bInteriorID]); 
			}

			printf("[system] Business ID: %d Hotel Room %d Loaded!", b, i);
		}
	}
	return 1;
}

forward LoadHotelRoom(hotelroomID, tag[], name[], value[]); 
public LoadHotelRoom(hotelroomID, tag[], name[], value[])
{
	new idx = tempBID , hrID = hotelroomID; 
	
	INI_Float("HotelRoomExtPosX", hRoom[idx][hrID][hrExtPos][0]);
	INI_Float("HotelRoomExtPosY", hRoom[idx][hrID][hrExtPos][1]);
	INI_Float("HotelRoomExtPosZ", hRoom[idx][hrID][hrExtPos][2]);
	INI_Int("HotelRoomExtVW", hRoom[idx][hrID][hrExtVW]);
	
	INI_Float("HotelRoomIntPosX", hRoom[idx][hrID][hrIntPos][0]); 
	INI_Float("HotelRoomIntPosY", hRoom[idx][hrID][hrIntPos][1]); 
	INI_Float("HotelRoomIntPosZ", hRoom[idx][hrID][hrIntPos][2]); 
	INI_Int("HotelRoomIntID", hRoom[idx][hrID][hrIntID]);
	INI_Int("HotelRoomIntVW", hRoom[idx][hrID][hrIntVW]);
	
	INI_String("HotelRoomOwner", hRoom[idx][hrID][hrOwner], 24); 
	
	INI_Int("HotelRoomPot", hRoom[idx][hrID][hrPot]);
	INI_Int("HotelRoomCocaine", hRoom[idx][hrID][hrCocaine]);
	INI_Int("HotelRoomMaterials", hRoom[idx][hrID][hrMaterials]);
	INI_Int("HotelRoomWeapon", hRoom[idx][hrID][hrWeapon]);
	INI_Int("HotelRoomSpeed", hRoom[idx][hrID][hrSpeed]); 
	
	INI_Int("HotelRoomLockStatus", hRoom[idx][hrID][hrLockStatus]);
	INI_Int("HotelRoomRentPrice", hRoom[idx][hrID][hrRentPrice]);
	return 1;
}*/
/* ### End of Business Saving/Loading Functions ###*/


/* ### Start of Player Saving/Loading Functions ###*/ 

stock SetupORM(playerid)
{
	new ORM:ormid = Player[playerid][pORM_ID];
	
	orm_addvar_string(ormid, Player[playerid][CreationTime], 128, "CreationTime");
	orm_addvar_int(ormid, Player[playerid][AdminLevel], "AdminLevel");
	orm_addvar_int(ormid, Player[playerid][HasVoted], "HasVoted");
	orm_addvar_float(ormid, Player[playerid][LastX], "LastX");
	orm_addvar_float(ormid, Player[playerid][LastY], "LastY");
	orm_addvar_float(ormid, Player[playerid][LastZ], "LastZ");
	orm_addvar_int(ormid, Player[playerid][LastWorld], "LastWorld");
	orm_addvar_int(ormid, Player[playerid][LastInterior], "LastInterior");
	orm_addvar_int(ormid, Player[playerid][LastSkin], "LastSkin");
	orm_addvar_float(ormid, Player[playerid][LastHealth], "LastHealth");
	orm_addvar_float(ormid, Player[playerid][LastArmour], "LastArmour");
	orm_addvar_int(ormid, Player[playerid][LastLoginMinute], "LastLoginMinute");
	orm_addvar_int(ormid, Player[playerid][LastLoginHour], "LastLoginHour");
	orm_addvar_int(ormid, Player[playerid][LastLoginDay], "LastLoginDay");
	orm_addvar_int(ormid, Player[playerid][LastLoginMonth], "LastLoginMonth");
	orm_addvar_int(ormid, Player[playerid][LastLoginYear], "LastLoginYear");
	orm_addvar_string(ormid, Player[playerid][LastIP], 32, "LastIP");
	orm_addvar_int(ormid, Player[playerid][Group], "Group");
	orm_addvar_int(ormid, Player[playerid][GroupRank], "GroupRank");
	orm_addvar_int(ormid, Player[playerid][Gang], "Gang");
	orm_addvar_int(ormid, Player[playerid][GangRank], "GangRank");
	orm_addvar_int(ormid, Player[playerid][House], "House");
	orm_addvar_int(ormid, Player[playerid][House2], "House2");
	orm_addvar_int(ormid, Player[playerid][Banned], "Banned");
	orm_addvar_int(ormid, Player[playerid][Muted], "Muted");
	orm_addvar_int(ormid, Player[playerid][Money], "Money");
	orm_addvar_int(ormid, Player[playerid][WepSlot0], "WepSlot0");
	orm_addvar_int(ormid, Player[playerid][WepSlot1], "WepSlot1");
	orm_addvar_int(ormid, Player[playerid][WepSlot2], "WepSlot2");
	orm_addvar_int(ormid, Player[playerid][WepSlot3], "WepSlot3");
	orm_addvar_int(ormid, Player[playerid][WepSlot4], "WepSlot4");
	orm_addvar_int(ormid, Player[playerid][WepSlot5], "WepSlot5");
	orm_addvar_int(ormid, Player[playerid][WepSlot6], "WepSlot6");
	orm_addvar_int(ormid, Player[playerid][WepSlot7], "WepSlot7");
	orm_addvar_int(ormid, Player[playerid][WepSlot8], "WepSlot8");
	orm_addvar_int(ormid, Player[playerid][WepSlot9], "WepSlot9");
	orm_addvar_int(ormid, Player[playerid][WepSlot10], "WepSlot10");
	orm_addvar_int(ormid, Player[playerid][WepSlot11], "WepSlot11");
	orm_addvar_string(ormid, Player[playerid][Warning1], 255, "Warning1");
	orm_addvar_string(ormid, Player[playerid][Warning2], 255, "Warning2");
	orm_addvar_string(ormid, Player[playerid][Warning3], 255, "Warning3");
	orm_addvar_int(ormid, Player[playerid][Identity], "Identity");
	orm_addvar_int(ormid, Player[playerid][Age], "Age");
	orm_addvar_int(ormid, Player[playerid][ContractPrice], "ContractPrice");
	orm_addvar_string(ormid, Player[playerid][Contract], 128, "Contract");
	orm_addvar_string(ormid, Player[playerid][Contract2], 128, "Contract2");
	orm_addvar_int(ormid, Player[playerid][PrisonDuration], "PrisonDuration");
	orm_addvar_int(ormid, Player[playerid][PrisonID], "PrisonID");
	orm_addvar_int(ormid, Player[playerid][Tutorial], "Tutorial");
	orm_addvar_int(ormid, Player[playerid][Hospitalized], "Hospitalized");
	orm_addvar_int(ormid, Player[playerid][Gender], "Gender");
	orm_addvar_int(ormid, Player[playerid][Job], "Job");
	orm_addvar_int(ormid, Player[playerid][Job2], "Job2");
	orm_addvar_int(ormid, Player[playerid][Materials][0], "Materials");
	orm_addvar_int(ormid, Player[playerid][Materials][1], "Materials1");
	orm_addvar_int(ormid, Player[playerid][Materials][2], "Materials2");
	orm_addvar_int(ormid, Player[playerid][AdminActions], "AdminActions");
	orm_addvar_int(ormid, Player[playerid][SecondsLoggedIn], "SecondsLoggedIn");
	orm_addvar_int(ormid, Player[playerid][BankMoney], "BankMoney");
	orm_addvar_int(ormid, Player[playerid][Cocaine], "Cocaine");
	orm_addvar_int(ormid, Player[playerid][Pot], "Pot");
	orm_addvar_int(ormid, Player[playerid][nMuted], "nMuted");
	orm_addvar_int(ormid, Player[playerid][nMutedLevel], "nMutedLevel");
	orm_addvar_int(ormid, Player[playerid][nMutedTime], "nMutedTime");
	orm_addvar_int(ormid, Player[playerid][vMuted], "vMuted");
	orm_addvar_int(ormid, Player[playerid][vMutedLevel], "vMutedLevel");
	orm_addvar_int(ormid, Player[playerid][vMutedTime], "vMutedTime");
	orm_addvar_int(ormid, Player[playerid][Business], "Business");
	orm_addvar_int(ormid, Player[playerid][PhoneN], "PhoneN");
	orm_addvar_int(ormid, Player[playerid][PlayingHours], "PlayingHours");
	orm_addvar_int(ormid, Player[playerid][InabilityToMatrun], "InabilityToMatrun");
	orm_addvar_int(ormid, Player[playerid][InabilityToDropCar], "InabilityToDropCar");
	orm_addvar_int(ormid, Player[playerid][FishAttempts], "FishAttempts");
	orm_addvar_int(ormid, Player[playerid][CollectedFish], "CollectedFish");
	orm_addvar_int(ormid, Player[playerid][Rope], "Rope");
	orm_addvar_int(ormid, Player[playerid][Rags], "Rags");
	orm_addvar_int(ormid, Player[playerid][FailedHits], "FailedHits");
	orm_addvar_int(ormid, Player[playerid][SuccessfulHits], "SuccessfulHits");
	orm_addvar_int(ormid, Player[playerid][PersonalRadio], "PersonalRadio");
	orm_addvar_int(ormid, Player[playerid][ArmsDealerXP], "ArmsDealerXP");
	orm_addvar_string(ormid, Player[playerid][MarriedTo], 25, "MarriedTo");
	orm_addvar_int(ormid, Player[playerid][FightBox], "FightBox");
	orm_addvar_int(ormid, Player[playerid][FightKungfu], "FightKungfu");
	orm_addvar_int(ormid, Player[playerid][FightGrabkick], "FightGrabkick");
	orm_addvar_int(ormid, Player[playerid][FightKneehead], "FightKneehead");
	orm_addvar_int(ormid, Player[playerid][FightElbow], "FightElbow");
	orm_addvar_int(ormid, Player[playerid][VipRank], "VipRank");
	orm_addvar_int(ormid, Player[playerid][VipTime], "VipTime");
	orm_addvar_int(ormid, Player[playerid][VipRenew], "VipRenew");
	orm_addvar_int(ormid, Player[playerid][WalkieTalkie], "WalkieTalkie");
	orm_addvar_int(ormid, Player[playerid][BankStatus], "BankStatus");
	orm_addvar_int(ormid, Player[playerid][PlayerSkinSlot1], "PlayerSkinSlot1");
	orm_addvar_int(ormid, Player[playerid][PlayerSkinSlot2], "PlayerSkinSlot2");
	orm_addvar_int(ormid, Player[playerid][PlayerSkinSlot3], "PlayerSkinSlot3");
	orm_addvar_int(ormid, Player[playerid][AdminPIN], "AdminPIN");
	orm_addvar_string(ormid, Player[playerid][AdminName], 25, "AdminName");
	//orm_addvar_string(ormid, Player[playerid][NormalName], 25, "NormalName");
	orm_addvar_int(ormid, Player[playerid][Accent], "Accent");
	orm_addvar_int(ormid, Player[playerid][WalkieFrequency], "WalkieFrequency");
	orm_addvar_string(ormid, Player[playerid][Note], 128, "Note");
	orm_addvar_int(ormid, Player[playerid][VipTokens], "VipTokens");
	orm_addvar_int(ormid, Player[playerid][Tester], "Tester");
	orm_addvar_int(ormid, Player[playerid][CheckBalance], "CheckBalance");
	orm_addvar_int(ormid, Player[playerid][reportBan][0], "ReportBanTime");
	orm_addvar_int(ormid, Player[playerid][reportBan][1], "ReportBanLevel");
	orm_addvar_int(ormid, Player[playerid][askBan][0], "AskBanTime");
	orm_addvar_int(ormid, Player[playerid][askBan][1], "AskBanLevel");
	orm_addvar_int(ormid, Player[playerid][AdminDuty], "AdminDuty");
	orm_addvar_int(ormid, Player[playerid][CurrentFightStyle], "CurrentFightStyle");
	orm_addvar_int(ormid, Player[playerid][PDBadge], "PDBadge");
	orm_addvar_string(ormid, Player[playerid][BannedBy], 25, "BannedBy");
	orm_addvar_string(ormid, Player[playerid][BannedReason], 128, "BannedReason");
	orm_addvar_int(ormid, Player[playerid][TempbanTime], "TempbanTime");
	orm_addvar_int(ormid, Player[playerid][TempbanLevel], "TempbanLevel");
	orm_addvar_int(ormid, Player[playerid][DeliverTime], "DeliverTime");
	orm_addvar_int(ormid, Player[playerid][GasCans], "GasCans");
	orm_addvar_string(ormid, Player[playerid][nTag], 32, "nTag");
	orm_addvar_int(ormid, Player[playerid][Developer], "Developer");
	orm_addvar_int(ormid, Player[playerid][Mapper], "Mapper");
	orm_addvar_string(ormid, Player[playerid][Walk], 72, "Walk");
	orm_addvar_int(ormid, Player[playerid][InHouse], "InHouse");
	orm_addvar_int(ormid, Player[playerid][JobCooldown], "JobCooldown");
	orm_addvar_int(ormid, Player[playerid][CanMakeGun], "CanMakeGun");
	orm_addvar_int(ormid, Player[playerid][Deliveries], "Deliveries");
	orm_addvar_int(ormid, Player[playerid][GasFull], "GasFull");
	orm_addvar_int(ormid, Player[playerid][CantFish], "CantFish");
	orm_addvar_int(ormid, Player[playerid][FishAgainAntiSpam], "FishAgainAntiSpam");
	orm_addvar_int(ormid, Player[playerid][Workbench], "Workbench");
	orm_addvar_int(ormid, Player[playerid][Toolkit], "Toolkit");
	orm_addvar_int(ormid, Player[playerid][SkillCooldown], "SkillCooldown");
	orm_addvar_int(ormid, Player[playerid][NosBottle], "NosBottle");
	orm_addvar_int(ormid, Player[playerid][HydroKit], "HydroKit");
	orm_addvar_int(ormid, Player[playerid][EngineParts], "EngineParts");
	orm_addvar_string(ormid, Player[playerid][HeadDesc], 128, "HeadDesc");
	orm_addvar_string(ormid, Player[playerid][BodyDesc], 128, "BodyDesc");
	orm_addvar_string(ormid, Player[playerid][ClothingDesc], 128, "ClothingDesc");
	orm_addvar_string(ormid, Player[playerid][AccessoryDesc], 128, "AccessoryDesc");
	orm_addvar_int(ormid, Player[playerid][TotalFished], "TotalFished");
	orm_addvar_int(ormid, Player[playerid][FishingRod], "FishingRod");
	orm_addvar_int(ormid, Player[playerid][FishingBait], "FishingBait");
	orm_addvar_int(ormid, Player[playerid][TotalBass], "TotalBass");
	orm_addvar_int(ormid, Player[playerid][TotalCod], "TotalCod");
	orm_addvar_int(ormid, Player[playerid][TotalSalmon], "TotalSalmon");
	orm_addvar_int(ormid, Player[playerid][TotalMackerel], "TotalMackerel");
	orm_addvar_int(ormid, Player[playerid][TotalTuna], "TotalTuna");
	orm_addvar_int(ormid, Player[playerid][TotalCarp], "TotalCarp");
	orm_addvar_int(ormid, Player[playerid][TotalHerring], "TotalHerring");
	orm_addvar_int(ormid, Player[playerid][TotalMarlin], "TotalMarlin");
	orm_addvar_int(ormid, Player[playerid][TotalMako], "TotalMako");
	orm_addvar_int(ormid, Player[playerid][TotalCrab], "TotalCrab");
	orm_addvar_int(ormid, Player[playerid][TotalKraken], "TotalKraken");
	orm_addvar_int(ormid, Player[playerid][Tickets], "Tickets");
	orm_addvar_int(ormid, Player[playerid][Race], "Race");
	orm_addvar_int(ormid, Player[playerid][AFKKicked], "AFKKicked");
	orm_addvar_int(ormid, Player[playerid][PizzaDelivers], "PizzaDelivers");
	orm_addvar_int(ormid, Player[playerid][PizzaCooldown], "PizzaCooldown");
	orm_addvar_int(ormid, Player[playerid][CantDeliverPizza], "CantDeliverPizza");
	orm_addvar_int(ormid, Player[playerid][HouseKey], "HouseKey");
	orm_addvar_int(ormid, Player[playerid][CasinoChips], "CasinoChips");
	orm_addvar_int(ormid, Player[playerid][FavoriteStationSet], "FavoriteStationSet");
	orm_addvar_string(ormid, Player[playerid][FavoriteStation], 255, "FavoriteStation");
	orm_addvar_int(ormid, Player[playerid][HotelRoomID], "HotelRoomID");
	orm_addvar_int(ormid, Player[playerid][HotelRoomWarning], "HotelRoomWarning");
	orm_addvar_int(ormid, Player[playerid][CarLicense], "CarLicense");
	orm_addvar_int(ormid, Player[playerid][TruckLicense], "TruckLicense");
	orm_addvar_int(ormid, Player[playerid][EnterKey], "EnterKey");
	orm_addvar_int(ormid, Player[playerid][TruckerTestCooldown], "TruckerTestCooldown");
	orm_addvar_int(ormid, Player[playerid][SystemAfkKicks], "SystemAfkKicks");
	orm_addvar_int(ormid, Player[playerid][AdminAfkKicks], "AdminAfkKicks");
	orm_addvar_int(ormid, Player[playerid][BeerCases], "BeerCases");
	orm_addvar_int(ormid, Player[playerid][BusinessKey], "BusinessKey");
	orm_addvar_int(ormid, Player[playerid][VehicleRadio], "VehicleRadio");
	orm_addvar_int(ormid, Player[playerid][GarbageCooldown], "GarbageCooldown");
	orm_addvar_int(ormid, Player[playerid][PotTimer], "PotTimer");
	orm_addvar_int(ormid, Player[playerid][CocaineTimer], "CocaineTimer");
	orm_addvar_string(ormid, Player[playerid][PrisonReason], 128, "PrisonReason");
	orm_addvar_string(ormid, Player[playerid][AdminNote1], 128, "AdminNote1");
	orm_addvar_string(ormid, Player[playerid][AdminNote2], 128, "AdminNote2");
	orm_addvar_string(ormid, Player[playerid][AdminNote3], 128, "AdminNote3");
	orm_addvar_int(ormid, Player[playerid][LicenseSuspended], "LicenseSuspended");
	orm_addvar_int(ormid, Player[playerid][Speed], "Speed");
	orm_addvar_int(ormid, Player[playerid][SpeedTimer], "SpeedTimer");
	orm_addvar_int(ormid, Player[playerid][PotSeeds], "PotSeeds");
	orm_addvar_int(ormid, Player[playerid][GrowLight], "GrowLight");
	orm_addvar_int(ormid, Player[playerid][ToyBanned], "ToyBanned");
	orm_addvar_int(ormid, Player[playerid][TotalSSDeposits], "TotalSSDeposits");
	orm_addvar_int(ormid, Player[playerid][LastDepositHours], "LastDepositHours");
	orm_addvar_int(ormid, Player[playerid][LastRedeemHours], "LastRedeemHours");
	orm_addvar_int(ormid, Player[playerid][EggsCollected], "EggsCollected");
	orm_addvar_int(ormid, Player[playerid][HungerLevel], "HungerLevel");
	orm_addvar_int(ormid, Player[playerid][HungerEnabled], "HungerEnabled");
	orm_addvar_int(ormid, Player[playerid][HungerEffect], "HungerEffect");
	orm_addvar_int(ormid, Player[playerid][HasBoombox], "HasBoombox");
	orm_addvar_int(ormid, Player[playerid][InGarage], "InGarage");
	orm_addvar_int(ormid, Player[playerid][AdminSkin], "AdminSkin");
	orm_addvar_int(ormid, Player[playerid][HasSprayCans], "HasSprayCans");
	orm_addvar_int(ormid, Player[playerid][RemoteWarn], "RemoteWarn");
	orm_addvar_int(ormid, Player[playerid][TotalGunsMade], "TotalGunsMade");
	orm_addvar_int(ormid, Player[playerid][TotalCarsDropped], "TotalCarsDropped");
	orm_addvar_int(ormid, Player[playerid][TotalGarbageRuns], "TotalGarbageRuns");
	orm_addvar_int(ormid, Player[playerid][TotalTruckRuns], "TotalTruckRuns");
	orm_addvar_int(ormid, Player[playerid][TotalFishingRodsBroken], "TotalFishingRodsBroken");
	orm_addvar_int(ormid, Player[playerid][TotalDeaths], "TotalDeaths");
	orm_addvar_int(ormid, Player[playerid][TotalKrakensCaught], "TotalKrakensCaught");
	orm_addvar_int(ormid, Player[playerid][TotalToolkitsBroken], "TotalToolkitsBroken");
	orm_addvar_int(ormid, Player[playerid][TotalCarsFixed], "TotalCarsFixed");
	orm_addvar_int(ormid, Player[playerid][TotalMatRuns], "TotalMatRuns");
	orm_addvar_int(ormid, Player[playerid][FightStyle], "FightStyle");
	orm_addvar_int(ormid, Player[playerid][KilledByJason], "KilledByJason");
	orm_addvar_int(ormid, Player[playerid][GainedHalloweenPrize], "GainedHalloweenPrize");
	orm_addvar_int(ormid, Player[playerid][ClaimedHalloweenPrize], "ClaimedHalloweenPrize");
	orm_addvar_int(ormid, Player[playerid][PizzaSlices], "PizzaSlices");
	orm_addvar_int(ormid, Player[playerid][CarJackerXP], "CarJackerXP");
	orm_addvar_int(ormid, Player[playerid][GokartLapsDone], "GokartLapsDone");
	orm_addvar_int(ormid, Player[playerid][GokartPrizeReceived], "GokartPrizeReceived");
	orm_addvar_int(ormid, Player[playerid][pFireworks], "pFireworks");
	orm_addvar_int(ormid, Player[playerid][LottoTicket], "LottoTicket");
	orm_addvar_int(ormid, Player[playerid][SirenKit], "SirenKit");
	orm_addvar_int(ormid, Player[playerid][AutoParkCar], "AutoParkCar");
	orm_addvar_int(ormid, Player[playerid][SolitaryDuration], "SolitaryDuration");
	orm_addvar_int(ormid, Player[playerid][PrisonTickets], "PrisonTickets");
	orm_addvar_int(ormid, Player[playerid][PrisonScrewdriver], "PrisonScrewdriver");
	orm_addvar_int(ormid, Player[playerid][PrisonShank], "PrisonShank");
	orm_addvar_int(ormid, Player[playerid][PrisonRazor], "PrisonRazor");
	orm_addvar_int(ormid, Player[playerid][Cigarettes], "Cigarettes");
	orm_addvar_int(ormid, Player[playerid][PrisonDice], "PrisonDice");
	orm_addvar_int(ormid, Player[playerid][PrisonLighter], "PrisonLighter");
	orm_addvar_int(ormid, Player[playerid][SmuggleCooldown], "SmuggleCooldown");
	orm_addvar_int(ormid, Player[playerid][PrisonBuyItemCooldown], "PrisonBuyItemCooldown");
	orm_addvar_int(ormid, Player[playerid][PrisonLifer], "PrisonLifer");
	orm_addvar_int(ormid, Player[playerid][PrisonJobCooldown], "PrisonJobCooldown");
	orm_addvar_int(ormid, Player[playerid][InterComSys], "InterComSys");
	orm_addvar_int(ormid, Player[playerid][LoyaltyPoints], "LoyaltyPoints");
	orm_addvar_int(ormid, Player[playerid][LoyaltyStreak], "LoyaltyStreak");
	orm_addvar_int(ormid, Player[playerid][LoyaltyDailyStreak], "LoyaltyDailyStreak");
	orm_addvar_int(ormid, Player[playerid][LoyaltyPendingVip], "LoyaltyPendingVip");
	orm_addvar_int(ormid, Player[playerid][LoyaltyPendingVipHours], "LoyaltyPendingVipHours");
	orm_addvar_int(ormid, Player[playerid][LoyaltyVipRank], "LoyaltyVipRank");
	orm_addvar_int(ormid, Player[playerid][LoyaltyVipHoursLeft], "LoyaltyVipHoursLeft");
	orm_addvar_int(ormid, Player[playerid][LoyaltyPaycheckBoost], "LoyaltyPaycheckBoost");
	orm_addvar_int(ormid, Player[playerid][LoyaltyPaycheckBoostTimeLeft], "LoyaltyPaycheckBoostTimeLeft");
	orm_addvar_int(ormid, Player[playerid][LastLoyaltyDay], "LastLoyaltyDay");
	orm_addvar_int(ormid, Player[playerid][LastLoyaltyMonth], "LastLoyaltyMonth");
	orm_addvar_int(ormid, Player[playerid][LastLoyaltyYear], "LastLoyaltyYear");
	orm_addvar_int(ormid, Player[playerid][LoyaltyDailyStreakDay], "LoyaltyDailyStreakDay");
	orm_addvar_string(ormid, Player[playerid][LoyaltyRewards], 256, "LoyaltyRewards");
	orm_addvar_int(ormid, Player[playerid][Tent], "Tent");
	orm_addvar_int(ormid, Player[playerid][TentBan], "TentBan");

	orm_addvar_string(ormid, Player[playerid][Note1], 256, "Note1");
	orm_addvar_string(ormid, Player[playerid][Note2], 256, "Note2");
	orm_addvar_string(ormid, Player[playerid][Note3], 256, "Note3");
	orm_addvar_int(ormid, Player[playerid][Notepad], "Notepad");

	orm_addvar_int(ormid, Player[playerid][MaskBan], "MaskBan");
	orm_addvar_string(ormid, Player[playerid][FakeIDString], 256, "FakeIDString");
	orm_addvar_string(ormid, Player[playerid][FakeLicense], 256, "FakeLicense");
	orm_addvar_int(ormid, Player[playerid][TruckPenalty], "TruckPenalty");
	
	orm_addvar_int(ormid, Player[playerid][Loan], "Loan");
	orm_addvar_int(ormid, Player[playerid][LoanNotPaid], "LoanNotPaid");
	orm_addvar_int(ormid, Player[playerid][LoanTime], "LoanTime");
	orm_addvar_int(ormid, Player[playerid][CannotLoanTime], "CannotLoanTime");
	orm_addvar_int(ormid, Player[playerid][CannotBail], "CannotBail");
	orm_addvar_int(ormid, Player[playerid][HasArmour], "HasArmour");

	orm_addvar_float(ormid, Player[playerid][Wep3Pos][0], "Wep3Pos0");
	orm_addvar_float(ormid, Player[playerid][Wep3Pos][1], "Wep3Pos1");
	orm_addvar_float(ormid, Player[playerid][Wep3Pos][2], "Wep3Pos2");
	orm_addvar_float(ormid, Player[playerid][Wep3Pos][3], "Wep3Pos3");
	orm_addvar_float(ormid, Player[playerid][Wep3Pos][4], "Wep3Pos4");
	orm_addvar_float(ormid, Player[playerid][Wep3Pos][5], "Wep3Pos5");
	
	orm_addvar_float(ormid, Player[playerid][Wep5Pos][0], "Wep5Pos0");
	orm_addvar_float(ormid, Player[playerid][Wep5Pos][1], "Wep5Pos1");
	orm_addvar_float(ormid, Player[playerid][Wep5Pos][2], "Wep5Pos2");
	orm_addvar_float(ormid, Player[playerid][Wep5Pos][3], "Wep5Pos3");
	orm_addvar_float(ormid, Player[playerid][Wep5Pos][4], "Wep5Pos4");
	orm_addvar_float(ormid, Player[playerid][Wep5Pos][5], "Wep5Pos5");
	
	orm_addvar_float(ormid, Player[playerid][Wep6Pos][0], "Wep6Pos0");
	orm_addvar_float(ormid, Player[playerid][Wep6Pos][1], "Wep6Pos1");
	orm_addvar_float(ormid, Player[playerid][Wep6Pos][2], "Wep6Pos2");
	orm_addvar_float(ormid, Player[playerid][Wep6Pos][3], "Wep6Pos3");
	orm_addvar_float(ormid, Player[playerid][Wep6Pos][4], "Wep6Pos4");
	orm_addvar_float(ormid, Player[playerid][Wep6Pos][5], "Wep6Pos5");
	
	orm_addvar_int(ormid, Player[playerid][EditedWeapon][0], "EditedWeapon0");
	orm_addvar_int(ormid, Player[playerid][EditedWeapon][1], "EditedWeapon1");
	orm_addvar_int(ormid, Player[playerid][EditedWeapon][2], "EditedWeapon2");
	
	orm_addvar_int(ormid, Player[playerid][Infected], "Infected");
	orm_addvar_int(ormid, Player[playerid][VirusCount], "VirusCount");
	orm_addvar_int(ormid, Player[playerid][HasGasMask], "HasGasMask");
	orm_addvar_float(ormid, Player[playerid][GasMaskOffsets][0], "GasMaskX");
	orm_addvar_float(ormid, Player[playerid][GasMaskOffsets][1], "GasMaskY");
	orm_addvar_float(ormid, Player[playerid][GasMaskOffsets][2], "GasMaskZ");
	orm_addvar_float(ormid, Player[playerid][GasMaskOffsets][3], "GasMaskRotX");
	orm_addvar_float(ormid, Player[playerid][GasMaskOffsets][4], "GasMaskRotY");
	orm_addvar_float(ormid, Player[playerid][GasMaskOffsets][5], "GasMaskRotZ");
	orm_addvar_float(ormid, Player[playerid][GasMaskOffsets][6], "GasMaskScaleX");
	orm_addvar_float(ormid, Player[playerid][GasMaskOffsets][7], "GasMaskScaleY");
	orm_addvar_float(ormid, Player[playerid][GasMaskOffsets][8], "GasMaskScaleZ");
	
	orm_addvar_int(ormid, Player[playerid][Ventillation], "Ventillation");
	orm_addvar_int(ormid, Player[playerid][Bomb], "Bomb");
	orm_addvar_int(ormid, Player[playerid][GunLicense], "GunLicense");
	orm_addvar_int(ormid, Player[playerid][LoyaltyNTag], "LoyaltyNTag");
	return 1;
}

/*### End of Player Data Saving/Loading Functions ###*/ 
