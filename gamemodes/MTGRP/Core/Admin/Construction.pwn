/*
#		MTG In-game Mapping System
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

#define MAX_CONSTRUCTION_OBJECTS  75
enum constMapping
{
	objectID, 
	modelID, 
	Float:posX,
	Float:posY,
	Float:posZ,
	Float:rotX,
	Float:rotY,
	Float:rotZ, 
	creatorName[MAX_PLAYER_NAME],
	lastEditor[MAX_PLAYER_NAME],
	Text3D:idLabel[MAX_PLAYERS], 
};
new Construction[MAX_CONSTRUCTION_OBJECTS][constMapping]; 

hook OnPlayerConnect(playerid)
{
	for(new i; i < MAX_CONSTRUCTION_OBJECTS; i++)
	{
		if(IsValidDynamic3DTextLabel(Construction[i][idLabel][playerid]))
			DestroyDynamic3DTextLabel(Construction[i][idLabel][playerid]);
	}	
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	//% exploit fix
	for(new i = 0, j = strlen(inputtext); i != j; i++)
	{
		if(inputtext[i] == '%')
			inputtext[i] = ' ';
	}
	
	switch(dialogid)
	{
		case CONST_OBJECTID:
		{
			if(!response)
				return 1;
				
			ShowPlayerDialog(playerid, CONST_OBJECTID+1, DIALOG_STYLE_INPUT, "Enter a model ID!", "If you wish to spawn this object ID enter a model ID for it", "Enter", "Cancel");
		}
		case CONST_OBJECTID+1:
		{
			if(!response)
				return 1;
				
			new modelid = strval(inputtext), idx = GetPVarInt(playerid, "obIDX"), Float:pPos[3], id = -1;
			GetPlayerPos(playerid, pPos[0], pPos[1], pPos[2]);
			
			for(new i; i < MAX_CONSTRUCTION_OBJECTS; i++) {
				if(i == idx) {
					id = i;
					break;
				}
			}
			
			if(id == -1)
				return SendClientMessage(playerid, -1, "An unexpected error has occured at line 17474. Contact a developer."); 
			
			format(Construction[id][lastEditor], MAX_PLAYER_NAME, "%s", GetName(playerid));
			Construction[id][modelID] = modelid; 
			Construction[id][posX] = pPos[0];
			Construction[id][posY] = pPos[1];
			Construction[id][posZ] = pPos[2];
			Construction[id][rotX] = 0;
			Construction[id][rotY] = 0;
			Construction[id][rotZ] = 0;
			
			Construction[id][objectID] = CreateDynamicObject(Construction[id][modelID], Construction[id][posX], Construction[id][posY], Construction[id][posZ], Construction[id][rotX], Construction[id][rotY], Construction[id][rotZ]); 
			SetPVarInt(playerid, "EditingConstruction", 1);
			EditDynamicObject(playerid, Construction[id][objectID]);
		}
	}
	return 1;
}

//forward OnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz);
hook OnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	if(GetPVarInt(playerid, "EditingConstruction") == 1)
	{
		new idx = -1;  
		for(new i; i < MAX_CONSTRUCTION_OBJECTS; i++) {
			if(Construction[i][objectID] == objectid) {
				idx = i;
				break;
			}
		}
		
		if(idx == -1)
			return SendClientMessage(playerid, -1, "An unexpected error has occured at line 61833. Contact a developer."); 
		
		new Float:oldPos[3], Float:oldRot[3]; 
		GetDynamicObjectPos(objectid, oldPos[0], oldPos[1], oldPos[2]);
		GetDynamicObjectRot(objectid, oldRot[0], oldRot[1], oldRot[2]);
		
		if(!IsValidDynamicObject(objectid))
			return 1;
			
		MoveDynamicObject(objectid, x, y, z, 10, rx, ry, rz);
		
		if(IsValidDynamic3DTextLabel(Construction[idx][idLabel]) && GetPVarInt(playerid, "seesIDs") == 1)
		{
			new string[128]; 
			DestroyDynamic3DTextLabel(Construction[idx][idLabel]);
			format(string, sizeof(string), "ID: %d", idx); 
			Construction[idx][idLabel][playerid] = CreateDynamic3DTextLabel(string, GREEN, x, y, z, 200, .playerid = playerid);
			Streamer_Update(playerid);
		}
		
		if(response == EDIT_RESPONSE_FINAL)
		{
			Construction[idx][posX] = x;
			Construction[idx][posY] = y;
			Construction[idx][posZ] = z;
			Construction[idx][rotX] = rx;
			Construction[idx][rotY] = ry; 
			Construction[idx][rotZ] = rz;
			format(Construction[idx][lastEditor], MAX_PLAYER_NAME, GetName(playerid));
			SendClientMessage(playerid, -1, "You have successfully edited the object."); 
			
			if(IsValidDynamic3DTextLabel(Construction[idx][idLabel]) && GetPVarInt(playerid, "seesIDs") == 1)
			{
				new string[128]; 
				DestroyDynamic3DTextLabel(Construction[idx][idLabel]);
				format(string, sizeof(string), "ID: %d", idx); 
				Construction[idx][idLabel][playerid] = CreateDynamic3DTextLabel(string, GREEN, x, y, z, 200, .playerid = playerid);
			}
			DeletePVar(playerid, "EditingConstruction");
			return SaveConstObject(idx);
		}
		
		if(response == EDIT_RESPONSE_CANCEL)
		{
			DeletePVar(playerid, "EditingConstruction");
			SetDynamicObjectPos(objectid, oldPos[0], oldPos[1], oldPos[2]);
			SetDynamicObjectRot(objectid, oldRot[0], oldRot[1], oldRot[2]);
		}
	}
	return 1;
}

CMD:editobject(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
		
	if(isnull(params))
		return SendClientMessage(playerid, -1, "SYNTAX: /editobject [ID]");
	
	new objectid, index = strval(params); 
	for(new i; i < MAX_CONSTRUCTION_OBJECTS; i++) {
		if(i == index) {
			objectid = Construction[i][objectID];
			break;
		}
	}

	if(objectid == INVALID_OBJECT_ID)
	{
		SetPVarInt(playerid, "obIDX", index);
		return ShowPlayerDialog(playerid, CONST_OBJECTID, DIALOG_STYLE_MSGBOX, "That object isn't spawned!", "This object ID isn't spawned, would you like to spawn it?", "Yes", "No"); 
	}
	SetPVarInt(playerid, "EditingConstruction", 1);
	EditDynamicObject(playerid, objectid);
	return 1;
}

CMD:deleteobject(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
		
	if(isnull(params))
		return SendClientMessage(playerid, -1, "SYNTAX: /deleteobject [ID]"); 
	
	new idx = strval(params), string[128]; 
	
	new objectid; 
	for(new i; i < MAX_CONSTRUCTION_OBJECTS; i++) {
		if(i == idx) {
			objectid = Construction[i][objectID];
			break;
		}
	}
	
	foreach(Player, i) {
		if(IsValidDynamic3DTextLabel(Construction[idx][idLabel][i]))
			DestroyDynamic3DTextLabel(Construction[idx][idLabel][i]); 
	}
	
	Construction[idx][modelID] = 0;
	Construction[idx][posX] = 0;
	Construction[idx][posY] = 0;
	Construction[idx][posZ] = 0;
	Construction[idx][rotX] = 0;
	Construction[idx][rotY] = 0;
	Construction[idx][rotZ] = 0;
	format(Construction[idx][lastEditor], MAX_PLAYER_NAME, GetName(playerid));
	DestroyDynamicObject(objectid);
	Construction[idx][objectID] = INVALID_OBJECT_ID; 
	Streamer_Update(playerid);
	SaveConstObject(idx);
	format(string, sizeof(string), "You have deleted object ID: %d", idx);
	SendClientMessage(playerid, -1, string);
	format(string, sizeof(string), "%s has deleted road work object ID: %d", Player[playerid][AdminName], idx);
	AdminActionsLog(string); 
	return 1;
}

CMD:createobject(playerid, params[])
{	
	if(Player[playerid][AdminLevel] < 5)
		return 1;
	
	if(isnull(params))
		return SendClientMessage(playerid, -1, "SYNTAX: /createobject [object id]");
	
	new idx = -1;
	
	for(new i; i < MAX_CONSTRUCTION_OBJECTS; i++) {
		if(!IsValidDynamicObject(Construction[i][objectID])) {
			idx = i;
			break;
		}
	}
	
	if(idx == -1)
		return SendClientMessage(playerid, -1, "The maximum amount of objects have already been created. Use /deleteobject to destroy one."); 
	
	new string[128];
	format(string, sizeof(string), "You have created object %d with the modelid of %d.", idx, strval(params));
	SendClientMessage(playerid, -1, string);
	
	new Float:pos[3];
	GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	createConstObject(GetName(playerid), strval(params), pos[0], pos[1], pos[2], idx);
	return 1;
}

CMD:viewobjectids(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
		
	if(GetPVarInt(playerid, "seesSQLS") == 1)
	{
		new string[128];
		for(new i; i < MAX_CONSTRUCTION_OBJECTS; i++)
		{
			format(string, sizeof(string), "ID: %d", i);
			if(IsValidDynamicObject(Construction[i][objectID]))
				Construction[i][idLabel][playerid] = CreateDynamic3DTextLabel(string, GREEN, Construction[i][posX], Construction[i][posY], Construction[i][posZ], 200, .playerid = playerid);
		}
		SetPVarInt(playerid, "seesSQLS", 2); 
		SendClientMessage(playerid, -1, "You will now see object ID labels.");
	}
	else
	{
		for(new i; i < MAX_CONSTRUCTION_OBJECTS; i++)
		{
			if(IsValidDynamic3DTextLabel(Construction[i][idLabel][playerid]))
				DestroyDynamic3DTextLabel(Construction[i][idLabel][playerid]);
		}
		SetPVarInt(playerid, "seesSQLS", 1); 
		SendClientMessage(playerid, -1, "You will no longer see object ID labels.");
	}
	return 1;
}

CMD:gotoobject(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
		
	new idx = strval(params);
	if(isnull(params) || !IsNumeric(params) || idx < 0 || idx > MAX_CONSTRUCTION_OBJECTS - 1)
		return SendClientMessage(playerid, -1, "SYNTAX: /gotoobject [objectid]");
		
	if(!IsValidDynamicObject(Construction[idx][objectID]))
		return SendClientMessage(playerid, -1, "That object does not exist.");
		
	SetPlayerPos_Update(playerid, Construction[idx][posX], Construction[idx][posY], Construction[idx][posZ]);
	
	new string[128];
	format(string, sizeof(string), "You have teleported to object ID %d which was placed by %s.", idx, Construction[idx][creatorName]);
	SendClientMessage(playerid, -1, string);
	return 1;
}

stock createConstObject(creator[], modelid, Float:x, Float:y, Float:z, idx)
{
	for(new i; i < MAX_CONSTRUCTION_OBJECTS; i++)	{
			if(i == idx)	{
				if(IsValidDynamicObject(Construction[i][objectID]))
					return print("[RoadWorksError] An unexpected error occured while creating an object. The ID chosen is already taken. (Line 62010)");
		}
	}
		
	format(Construction[idx][creatorName], MAX_PLAYER_NAME, "%s", creator);
	Construction[idx][modelID] = modelid; 
	Construction[idx][posX] = x;
	Construction[idx][posY] = y;
	Construction[idx][posZ] = z;
	Construction[idx][rotX] = 0;
	Construction[idx][rotY] = 0;
	Construction[idx][rotZ] = 0;
	
	SaveConstObject(idx);
	Construction[idx][objectID] = CreateDynamicObject(Construction[idx][modelID], Construction[idx][posX], Construction[idx][posY], Construction[idx][posZ], Construction[idx][rotX], Construction[idx][rotY], Construction[idx][rotZ]);
	return 1;
}

stock loadConstObjects()
{
	new path[64], file[64], string[128]; 
	format(file, sizeof(file), "Misc/RoadWorksMapping.djson"); 
		
	if(!fexist(file))
		return dini_Create(file);
	
	for(new i; i < MAX_CONSTRUCTION_OBJECTS; i++) {
		
		format(path, sizeof(path), "Objects/Object%d", i); 
		
		format(string, sizeof(string), "%s/ModelID", path);
		Construction[i][modelID] = djInt(file, string); 
		
		format(string, sizeof(string), "%s/Position/X", path);
		Construction[i][posX] = djFloat(file, string); 
		
		format(string, sizeof(string), "%s/Position/Y", path);
		Construction[i][posY] = djFloat(file, string);
		
		format(string, sizeof(string), "%s/Position/Z", path);
		Construction[i][posZ] = djFloat(file, string);
		
		format(string, sizeof(string), "%s/Rotation/X", path);
		Construction[i][rotX] = djFloat(file, string); 
		
		format(string, sizeof(string), "%s/Rotation/Y", path);
		Construction[i][rotY] = djFloat(file, string); 
		
		format(string, sizeof(string), "%s/Rotation/Z", path);
		Construction[i][rotZ] = djFloat(file, string); 
		
		format(string, sizeof(string), "%s/LastEditor", path);
		format(Construction[i][lastEditor], MAX_PLAYER_NAME, dj(file, string));
	
		format(string, sizeof(string), "%s/Creator", path);
		format(Construction[i][creatorName], MAX_PLAYER_NAME, dj(file, string));
		
		if(Construction[i][modelID] != 0)
			Construction[i][objectID] = CreateDynamicObject(Construction[i][modelID], Construction[i][posX], Construction[i][posY], Construction[i][posZ], Construction[i][rotX], Construction[i][rotY], Construction[i][rotZ]);
		else Construction[i][objectID] = INVALID_OBJECT_ID;
	}
	return 1;
}

stock SaveConstObject(idx)
{	
	new count = 0; 
	for(new i; i < MAX_CONSTRUCTION_OBJECTS; i++)	{
		if(i == idx)	{
			count++; 
			break;
		}
	}
	
	if(count != 1)
		return printf("[RoadWorksError] An unexpected error has occured. (Tried to save object that doesn't exist or tried to save more than one object! Count = %d)  ", count); 
	
	new path[64], file[64], string[128]; 
	format(file, sizeof(file), "Misc/RoadWorksMapping.djson"); 
	format(path, sizeof(path), "Objects/Object%d", idx); 
	
	djStyled(true);
	djAutocommit(false);
	format(string, sizeof(string), "%s/ModelID", path);
	djSetInt(file, string, Construction[idx][modelID]); 
	format(string, sizeof(string), "%s/Position/X", path);
	djSetFloat(file, string, Construction[idx][posX]);
	format(string, sizeof(string), "%s/Position/Y", path);
	djSetFloat(file, string, Construction[idx][posY]);
	format(string, sizeof(string), "%s/Position/Z", path);
	djSetFloat(file, string, Construction[idx][posZ]); 
	format(string, sizeof(string), "%s/Rotation/X", path);
	djSetFloat(file, string, Construction[idx][rotX]);
	format(string, sizeof(string), "%s/Rotation/Y", path);
	djSetFloat(file, string, Construction[idx][rotY]);
	format(string, sizeof(string), "%s/Rotation/Z", path);
	djSetFloat(file, string, Construction[idx][rotZ]);
	format(string, sizeof(string), "%s/LastEditor", path);
	djSet(file, string, Construction[idx][lastEditor]); 
	format(string, sizeof(string), "%s/Creator", path);
	djSet(file, string, Construction[idx][creatorName]); 
	djCommit(file);
	djAutocommit(true); 
	
	return 1;
}
