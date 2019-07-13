/*
#		MTG LSPD Sirens
#		
#
#	By accessing this file, you agree to the following:
#		- You will never give the script or associated files to anybody who is not on the MTG SAMP development team
# 		- You will delete all development materials (script, databases, associated files, etc.) when you leave the MTG SAMP development team.
#
#
#
*/

/*
static Lightbar_Offsets[][] = 
{
	{541, } //Bullet
	{415, } //Cheetah
	{468, } //Sanchez
	{525, } //Tow truck
	{560, } //Sultan
	{566, } //Tahoma
	{402, } //Buffalo
	{482, } //Burrito
}

static WindowLight_Offsets[][] = 

*/


//Tow truck lights (only visible at night?) 19803
//police light 18646
//police lights 19419
//police lights 19420
//19797	PoliceVisorStrobe1
//police lightbar 19620/s 


#define POLICE_LIGHT_TYPE_LIGHTBAR		1
#define POLICE_LIGHT_TYPE_ROOF			2
#define POLICE_LIGHT_TYPE_WINDSHIELD	3


CMD:installsirens(playerid, params[])
{
	if(Groups[Player[playerid][Group]][CommandTypes] != 1)
		return 1;
		
	if(Player[playerid][GroupRank] < 5)
		return SendClientMessage(playerid, WHITE, "You dont have access to this command.");
	
	if(Player[playerid][SirenKit] == 0)
		return SendClientMessage(playerid, WHITE, "You dont have a siren kit to install.");
	
	if(!IsPlayerInRangeOfCar(playerid, 5))
        return SendClientMessage(playerid, -1, "You're not near a vehicle!");

	new sql = GetNearestCarSQL(playerid), idx = GetVIndex(sql);
	
	if(sql == 0 || idx == -1)
		return SendClientMessage(playerid, WHITE, "An unexpected error has occured.");
	
	if(!HasVehicleAccess(playerid, sql))
		return SendClientMessage(playerid, WHITE, "You dont have access to this vehicle.");
		
	new model = GetVehicleModel(Veh[idx][Link]);
	if(!IsValidSirenVehicle(model))
		return SendClientMessage(playerid, WHITE, "You can't attach sirens to this vehicle.");
	
	if(Veh[idx][SirenType] != 0)
		return SendClientMessage(playerid, WHITE, "This vehicle is already equiped with a siren, uninstall it to install a different one.");
	
	if(!IsPlayerInRangeOfPoint(playerid, 10, Veh[idx][vX], Veh[idx][vY], Veh[idx][vZ]))
		return SendClientMessage(playerid, WHITE, "You must be near the vehicle's spawn to use this command as it will respawn the car.");
	
	if(Player[playerid][Toolkit] == 0)
		return SendClientMessage(playerid, WHITE, "You need a toolkit to install a siren.");
	
	Veh[idx][SirenType] = Player[playerid][SirenKit];
	Player[playerid][SirenKit] = 0;
	
	DespawnVehicleSQL(sql);
	SpawnVehicleSQL(sql);
	
	if(Veh[idx][SirenType] == POLICE_LIGHT_TYPE_LIGHTBAR)
	{
		AttachSirensToVehicle(Veh[idx][Link], POLICE_LIGHT_TYPE_LIGHTBAR);
	}
	
	new string[128];
	format(string, sizeof(string), "* %s has added a siren kit to the vehicle.", GetNameEx(playerid));
	NearByMessage(playerid, NICESKY, string);
	PlayerPlayNearbySound(playerid, 1133);
	return 1;
}

CMD:uninstallsirens(playerid, params[])
{
	if(Groups[Player[playerid][Group]][CommandTypes] != 1)
		return 1;
		
	if(Player[playerid][GroupRank] < 5)
		return SendClientMessage(playerid, WHITE, "You dont have access to this command.");
		
	if(!IsPlayerInRangeOfCar(playerid, 5))
        return SendClientMessage(playerid, -1, "You're not near a vehicle!");

	new sql = GetNearestCarSQL(playerid), idx = GetVIndex(sql);
	
	if(sql == 0 || idx == -1)
		return SendClientMessage(playerid, WHITE, "An unexpected error has occured.");
	
	if(!HasVehicleAccess(playerid, sql))
		return SendClientMessage(playerid, WHITE, "You dont have access to this vehicle.");
		
	if(Veh[idx][SirenType] == 0)
		return SendClientMessage(playerid, WHITE, "This vehicle doesn't have a siren you can uninstall");
	
	if(!IsPlayerInRangeOfPoint(playerid, 10, Veh[idx][vX], Veh[idx][vY], Veh[idx][vZ]))
		return SendClientMessage(playerid, WHITE, "You must be near the vehicle's spawn to use this command as it will respawn the car.");
	
	if(Player[playerid][Toolkit] == 0)
		return SendClientMessage(playerid, WHITE, "You need a toolkit to uninstall a siren.");
	
	Veh[idx][SirenType] = 0;
	
	DespawnVehicleSQL(sql);
	SpawnVehicleSQL(sql);
	
	if(IsValidDynamicObject(Veh[idx][SirenObjectID][0]))
		DestroyDynamicObject(Veh[idx][SirenObjectID][0]);
	if(IsValidDynamicObject(Veh[idx][SirenObjectID][1]))
		DestroyDynamicObject(Veh[idx][SirenObjectID][1]);
	
	new string[128];
	format(string, sizeof(string), "* %s has removed the siren kit from the vehicle.", GetNameEx(playerid));
	NearByMessage(playerid, NICESKY, string);
	PlayerPlayNearbySound(playerid, 1133);
	return 1;
}

stock AttachSirensToVehicle(vehicleid, type, slot = 0, sirenstate = 0)
{
	new Float:offsets[6], Float:vPos[3];
	GetVehiclePos(vehicleid, vPos[0], vPos[1], vPos[2]);
	GetLightOffsets(GetVehicleModel(vehicleid), type, offsets[0], offsets[1], offsets[2], offsets[3], offsets[4], offsets[5]);
	
	if(offsets[0] == 0.0 && offsets[1] == 0.0 && offsets[2] == 0.0 && offsets[3] == 0.0 && offsets[4] == 0.0 && offsets[5] == 0.0)
		return 1;
	
	new sql = GetVSQLID(vehicleid), idx = GetVIndex(sql);
	
	if(IsValidDynamicObject(Veh[idx][SirenObjectID][slot]))
		DestroyDynamicObject(Veh[idx][SirenObjectID][slot]);
			
	Veh[idx][SirenObjectID][slot] = CreateDynamicObject(GetSirenModelType(type) - sirenstate, vPos[0], vPos[1], vPos[2], 0.0, 0.0, 0.0, -1, -1, -1, 200, 50);
	AttachDynamicObjectToVehicle(Veh[idx][SirenObjectID][slot], Veh[idx][Link], offsets[0], offsets[1], offsets[2], offsets[3], offsets[4], offsets[5]);
	return 1;
}

stock IsValidSirenVehicle(modelid)
{
	switch(modelid)
	{
		case 541, 415, 468, 525, 560, 566, 402, 482, 579: return 1;
	}
	return 0;
}

stock GetSirenModelType(type)
{
	switch(type)
	{
		case POLICE_LIGHT_TYPE_LIGHTBAR: return 19420;
		case POLICE_LIGHT_TYPE_WINDSHIELD: return 19797;
		case POLICE_LIGHT_TYPE_ROOF: return 18646;
	}
	return 1;
}

stock GetLightOffsets(modelid, type, &Float:x, &Float:y, &Float:z, &Float:rx, &Float:ry, &Float:rz)
{
	
	switch(modelid)
	{
		case 402: //Buffalo
		{
			switch(type)
			{
				case POLICE_LIGHT_TYPE_LIGHTBAR: y = -0.22, z = 0.776, rz = 180;
				case POLICE_LIGHT_TYPE_WINDSHIELD: y = -0.055, z = 0.62, rz = 180;
				case POLICE_LIGHT_TYPE_ROOF: x = -0.59, y = -0.26, z = 0.80;
			}
		}
		case 415: //Cheetah
		{
			switch(type)
			{
				case POLICE_LIGHT_TYPE_LIGHTBAR: y = -0.015, z = 0.576, rz = 180;
				case POLICE_LIGHT_TYPE_WINDSHIELD: y = 0.17, z = 0.45, rz = 180;
				case POLICE_LIGHT_TYPE_ROOF: x = -0.4, y = -0.1, z = 0.63;
			}
		}
		case 468: //Sanchez
		{
			switch(type)
			{
				case POLICE_LIGHT_TYPE_WINDSHIELD: y = 0.41, z = 0.579999, rx = -20.1, ry = -1.005000, rz = 180;
				case POLICE_LIGHT_TYPE_ROOF: y = 0.32, z = 0.33, rx = -20.1, ry = -1.005, rz = 180;
			}
		}
		case 482: //Burrito
		{
			switch(type)
			{
				case POLICE_LIGHT_TYPE_LIGHTBAR: y = 1.016499, z = 0.921, rz = 180;
				case POLICE_LIGHT_TYPE_WINDSHIELD: y = 1.2, z = 0.68, rz = 180;
				case POLICE_LIGHT_TYPE_ROOF: x = -0.56, y = 0.97, z = 0.96, rz = 180;
			}
		}
		case 541: //Bullet
		{
			switch(type)
			{
				case POLICE_LIGHT_TYPE_LIGHTBAR: y = 0.085, z = 0.636, rz = 180;
				case POLICE_LIGHT_TYPE_WINDSHIELD: y = 0.36, z = 0.5, rz = 180;
				case POLICE_LIGHT_TYPE_ROOF: x = 0.4, y = 0.0, z = 0.68;
			}
		}
		case 560: //Sultan
		{
			switch(type)
			{
				case POLICE_LIGHT_TYPE_LIGHTBAR: y =  0.3, z = 0.826, rz = 180;
				case POLICE_LIGHT_TYPE_WINDSHIELD: y = 0.56, z = 0.65, rz = 180;
				case POLICE_LIGHT_TYPE_ROOF: x = -0.5, y = 0.26, z = 0.87, rz = 180;
			}
		}
		case 566: //Tahoma
		{
			switch(type)
			{
				case POLICE_LIGHT_TYPE_LIGHTBAR: y = 0.22, z = 0.866, rz = 180;
				case POLICE_LIGHT_TYPE_WINDSHIELD: y = 0.46, z = 0.67, rz = 180;
				case POLICE_LIGHT_TYPE_ROOF: x = -0.71, y = 0.22, z = 0.88, rz = 180;
			}
		}
		case 579: //Huntley
		{
			switch(type)
			{
				case POLICE_LIGHT_TYPE_ROOF: x = -0.6, y = 0.15, z = 1.27, rz = 180;
			}
		}
	}
}