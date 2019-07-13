/*
#		MTG Drug Supply Drops
#		
#
#	By accessing this file, you agree to the following:
#		- You will never give the script or associated files to anybody who is not on the MTG SAMP development team
# 		- You will delete all development materials (script, databases, associated files, etc.) when you leave the MTG SAMP development team.
#
*/
#include <YSI\y_hooks>

#define DRUG_SUPPLY_DATA_FILE	"Misc/DrugSupplyData.ini"
#define DRUG_SUPPLY_POS_DATA_FILE	"Misc/DrugSupplyPositions.ini"

#define DRUG_SUPPLY_MODEL_ID	1421

#define TOTAL_DRUG_TYPES		3
#define DRUG_SUPPLY_POT			0
#define DRUG_SUPPLY_COCAINE		1
#define DRUG_SUPPLY_SPEED		2

#define MAX_DRUG_SUPPLY_LOCATIONS	20

#define MAX_DRUG_AMOUNT			1000
#define MIN_DRUG_AMOUNT			250

#define MAX_DAYS_UNTIL_NEXT		3
#define MIN_DAYS_UNTIL_NEXT		1

static dObjectID, Text3D:dTextLabel, dType, dAmount, dIsActive = -1, string[255];
new dTimeUntilNextDrop;

enum drugsupply_
{
	Float:dPos[3],
	Float:dRot[3],
};

new DrugSupplyPositions[MAX_DRUG_SUPPLY_LOCATIONS][drugsupply_];

// ============= Callbacks ==============

hook OnGameModeInit()
{
	if(!fexist(DRUG_SUPPLY_DATA_FILE))
	{
		dini_Create(DRUG_SUPPLY_DATA_FILE);
		dini_IntSet(DRUG_SUPPLY_DATA_FILE, "dIsActive", -1);
	}
	
	dIsActive = dini_Int(DRUG_SUPPLY_DATA_FILE, "dIsActive");
	dType = dini_Int(DRUG_SUPPLY_DATA_FILE, "dType");
	dAmount = dini_Int(DRUG_SUPPLY_DATA_FILE, "dAmount");
	dTimeUntilNextDrop = dini_Int(DRUG_SUPPLY_DATA_FILE, "dTimeUntilNextDrop");
	
	LoadDrugSupplyPositions();
	
	if(dIsActive == -1)
	{
		if(dTimeUntilNextDrop == 0)
		{
			dTimeUntilNextDrop = 10 * 86400 + gettime();
			defer DrugSupplyDrop[10 * 86400 * 1000]();
		}
		else if(dTimeUntilNextDrop > 0)
		{
			defer DrugSupplyDrop[(dTimeUntilNextDrop - gettime()) * 1000]();
		}
		else
		{
			defer DrugSupplyDrop[1000]();
		}
	}
	else 
	{
		dObjectID = CreateDynamicObject(DRUG_SUPPLY_MODEL_ID, DrugSupplyPositions[dIsActive][dPos][0], DrugSupplyPositions[dIsActive][dPos][1], DrugSupplyPositions[dIsActive][dPos][2], DrugSupplyPositions[dIsActive][dRot][0], DrugSupplyPositions[dIsActive][dRot][1], DrugSupplyPositions[dIsActive][dRot][2]);
		dTextLabel = CreateDynamic3DTextLabel("Drug Supply Drop\n/collectdrugs", GREEN, DrugSupplyPositions[dIsActive][dPos][0], DrugSupplyPositions[dIsActive][dPos][1], DrugSupplyPositions[dIsActive][dPos][2] + 2, 10);
	}
	return 1;
}

hook OnGameModeExit()
{
	SaveDrugSupplyData();
	return 1;
}

// ============= Timers ==============

timer DrugSupplyDrop[1000]()
{
	if(dIsActive == -1)
	{
		new pos = random(MAX_DRUG_SUPPLY_LOCATIONS);
		if(DrugSupplyPositions[pos][dPos][0] == 0.0 && DrugSupplyPositions[pos][dPos][1] == 0.0 && DrugSupplyPositions[pos][dPos][2] == 0.0)
		{
			defer DrugSupplyDrop[1000]();
			return 1;
		}
		
		new lastPickup = dini_Int(DRUG_SUPPLY_DATA_FILE, "dLastPickup");
		if((gettime() - lastPickup) < (3 * 24 * 60 * 60)) //3 days
		{
			ResetDrugSupply();
			return 1;
		}
		
		dTextLabel = CreateDynamic3DTextLabel("Drug Supply Drop\n/collectdrugs", GREEN, DrugSupplyPositions[pos][dPos][0], DrugSupplyPositions[pos][dPos][1], DrugSupplyPositions[pos][dPos][2] + 2, 10);
		dObjectID = CreateDynamicObject(DRUG_SUPPLY_MODEL_ID, DrugSupplyPositions[pos][dPos][0], DrugSupplyPositions[pos][dPos][1], DrugSupplyPositions[pos][dPos][2], DrugSupplyPositions[pos][dRot][0], DrugSupplyPositions[pos][dRot][1], DrugSupplyPositions[pos][dRot][2]);
		dType = random(TOTAL_DRUG_TYPES);
		dAmount = RandomEx(MIN_DRUG_AMOUNT, MAX_DRUG_AMOUNT);
		dIsActive = pos;
		
		new DrugSupplyMole[][] = 
		{
			"Did you hear that?! Sounded like one of Smoov's cargo planes dropping another crate of drugs somewhere!",
			"A little birdie told me that Smoov has dropped off another shipment of drugs somewhere in San Andreas...", 
			"Holy crap Smoov's crate of drugs almost landed right on top of me!",
			"Smoov just called me and told me to tell you that another shipment of drugs has been dropped off somewhere in San Andreas!", 
			"It's raining drugs!! Smoov has dropped another crate of drugs somewhere in San Andreas!", 
			"It's a bird! It's a plane! Nope it's just Smoov dropping drugs on the people of San Andreas!", 
			"Don't you love waking up to the sight of a crate filled with drugs outside your window... Damn it Smoov!", 
			"Smoov sure loves raining drugs down on the people of San Andreas. Better go get them before the LSPD does!" };
			
		Mole(DrugSupplyMole[random(sizeof(DrugSupplyMole))]);
		
		format(string, sizeof(string), "[Drugs] A drug supply crate has spawned at location %d. (Type: %s, Amount: %d)", dIsActive, (dType == 0) ? ("Pot") : ((dType == 1) ? ("Cocaine") : ("Speed")), dAmount);
		SendToAdmins(ADMINORANGE, string, 0);
		ICChatLog(string);
	}
	return 1;
}

timer ResetDrugSupply[60 * 2 * 1000]() //2 minutes
{
	if(IsValidDynamicObject(dObjectID))
		DestroyDynamicObject(dObjectID);
	dTimeUntilNextDrop = RandomEx(MIN_DAYS_UNTIL_NEXT, MAX_DAYS_UNTIL_NEXT) * 86400 + gettime();
	SaveDrugSupplyData();
	defer DrugSupplyDrop[(dTimeUntilNextDrop - gettime()) * 1000]();
	return 1;
}

// ============= Commands ==============

CMD:resetdrugtimer(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
	return 1;

	format(string, sizeof(string), "%s has reset the drug drop timer.", Player[playerid][AdminName]);
	SendToAdmins(ADMINORANGE, string, 1);

	SendClientMessage(playerid, WHITE, "You have reset the drug drop timer.");
	ResetDrugSupply();
	return 1;
}
        


CMD:editdrugsupplyposition(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
		
	new id;
	if(sscanf(params, "d", id))
		return SendClientMessage(playerid, WHITE, "SYNTAX: /editdrugsupplyposition [0 - 19]");
		
	if(id < 0 || id > 19)
		return SendClientMessage(playerid, WHITE, "Invalid id.");
	
	if(id == dIsActive)
		return SendClientMessage(playerid, WHITE, "You can't edit the active supply drop.");
	
	new Float:pPos[3];
	GetPlayerPos(playerid, pPos[0], pPos[1], pPos[2]);
	new object = CreateDynamicObject(DRUG_SUPPLY_MODEL_ID, pPos[0], pPos[1] + 2, pPos[2], 0.0, 0.0, 0.0);
	EditDynamicObject(playerid, object);

	SetPVarInt(playerid, "DS_OBJECT__ID", object);
	SetPVarInt(playerid, "DS_OBJECT_SLOT", id);
	SetPVarInt(playerid, "DS_EDITING_OBJECT", 1);
	return 1;
}

CMD:gotodrugsupplyposition(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 2)
		return 1;
		
	new id;
	if(sscanf(params, "d", id))
	{
		SendClientMessage(playerid, WHITE, "SYNTAX: /gotodrugsupplyposition [0 - 19]");
		format(string, sizeof(string), "The current active drug supply is id %d.", dIsActive);
		SendClientMessage(playerid, WHITE, string);
		return 1;
	}
	
	if(id < 0 || id > 19)
		return SendClientMessage(playerid, WHITE, "Invalid id.");
	
	SetPlayerPos(playerid, DrugSupplyPositions[id][dPos][0], DrugSupplyPositions[id][dPos][1] + 2, DrugSupplyPositions[id][dPos][2] + 1);
	format(string, sizeof(string), "You have teleported to drug supply position %d.", id);
	SendClientMessage(playerid, WHITE, string);
	return 1;
}

CMD:collectdrugs(playerid, params[])
{
	if(dIsActive == -1)
		return SendClientMessage(playerid, WHITE, "You are not near the drug supply crate!");
		
	if(!IsPlayerInRangeOfPoint(playerid, 5.0, DrugSupplyPositions[dIsActive][dPos][0], DrugSupplyPositions[dIsActive][dPos][1], DrugSupplyPositions[dIsActive][dPos][2]))
		return SendClientMessage(playerid, WHITE, "You are not near the drug supply crate!");
	
	if(dAmount == 0)
		return SendClientMessage(playerid, WHITE, "It seems someone else has already taken all the drugs.");
	
	switch(dType)
	{
		case DRUG_SUPPLY_POT:		Player[playerid][Pot] += dAmount;
		case DRUG_SUPPLY_COCAINE:	Player[playerid][Cocaine] += dAmount;
		case DRUG_SUPPLY_SPEED:		Player[playerid][Speed] += dAmount;
	}
	
	format(string, sizeof(string), "You collected %d grams of %s from the crate.", dAmount, (dType == 0) ? ("Pot") : ((dType == 1) ? ("Cocaine") : ("Speed")));
	SendClientMessage(playerid, WHITE, string);
	format(string, sizeof(string), "[Drugs] %s has taken %d grams of %s from the drug supply crate.", GetName(playerid), dAmount, (dType == 0) ? ("Pot") : ((dType == 1) ? ("Cocaine") : ("Speed")));
	StatLog(string);
	
	dini_IntSet(DRUG_SUPPLY_DATA_FILE, "dLastPickup", gettime());
	
	DestroyDynamic3DTextLabel(dTextLabel);
	dIsActive = -1;
	dAmount = 0;
	dType = -1;
	defer ResetDrugSupply();
	return 1;
}

CMD:activedrugdrop(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 2)
		return 1;
	
	if(dIsActive == -1)
		return SendClientMessage(playerid, -1, "There is no active drug drop.");
	else
		return SendClientMessage(playerid, -1, "There is an active drug drop.");
}

// ============= Functions ==============

static stock LoadDrugSupplyPositions()
{	
	if(!fexist(DRUG_SUPPLY_POS_DATA_FILE))
		return dini_Create(DRUG_SUPPLY_POS_DATA_FILE);
	
	new File:file = fopen(DRUG_SUPPLY_POS_DATA_FILE, io_read), tmp;
	while(fread(file, string))
	{
		sscanf(string, "ffffff", DrugSupplyPositions[tmp][dPos][0], DrugSupplyPositions[tmp][dPos][1], DrugSupplyPositions[tmp][dPos][2], DrugSupplyPositions[tmp][dRot][0], DrugSupplyPositions[tmp][dRot][1], DrugSupplyPositions[tmp][dRot][2]);
		tmp++;
	}
	fclose(file);
	return 1;
}

stock SaveDrugSupplyPositions()
{
	if(!fexist(DRUG_SUPPLY_POS_DATA_FILE))
		return dini_Create(DRUG_SUPPLY_POS_DATA_FILE);
		
	new File:file = fopen(DRUG_SUPPLY_POS_DATA_FILE, io_write);
	for(new i; i < MAX_DRUG_SUPPLY_LOCATIONS; i++)
	{
		format(string, sizeof(string), "%f %f %f %f %f %f\r\n", DrugSupplyPositions[i][dPos][0], DrugSupplyPositions[i][dPos][1], DrugSupplyPositions[i][dPos][2], DrugSupplyPositions[i][dRot][0], DrugSupplyPositions[i][dRot][1], DrugSupplyPositions[i][dRot][2]);
		fwrite(file, string);
	}
	fclose(file);
	return 1;
}

stock SaveDrugSupplyData()
{
	if(!fexist(DRUG_SUPPLY_DATA_FILE))
		dini_Create(DRUG_SUPPLY_DATA_FILE);
	
	dini_IntSet(DRUG_SUPPLY_DATA_FILE, "dIsActive", dIsActive);
	dini_IntSet(DRUG_SUPPLY_DATA_FILE, "dType", dType);
	dini_IntSet(DRUG_SUPPLY_DATA_FILE, "dAmount", dAmount);
	dini_IntSet(DRUG_SUPPLY_DATA_FILE, "dTimeUntilNextDrop", dTimeUntilNextDrop);
	SaveDrugSupplyPositions();
	return 1;
}
