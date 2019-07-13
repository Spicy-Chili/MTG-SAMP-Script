/*
#		MTG Door/Gate System
#		
#
#	By accessing this file, you agree to the following:
#		- You will never give the script or associated files to anybody who is not on the MTG SAMP development team
# 		- You will delete all development materials (script, databases, associated files, etc.) when you leave the MTG SAMP development team.
#
*/
#include <YSI\y_hooks>

#define MAX_DOORGATES		1000

#define GATE_TYPE_GATE		1
#define GATE_TYPE_DOOR		2
#define GATE_TYPE_TOLL 		3
#define GATE_TYPE_CELL 		4

static string[128];
static query[1024];

enum _doorgates
{
	CreatedBy[25],
	Enabled,
	SQLID,
	ModelID,
	ObjectID,
	Type,
	Float:ClosePos[3],
	Float:CloseRot[3],
	Float:OpenPos[3],
	Float:OpenRot[3],
	InteriorID,
	dVW,
	
	BizLink,
	UseVIPKey,
	
	GroupLink,
	GangLink,
	GroupRank,
	
	HouseLink,
	UseKpp,
	
	VIPLevel,
	
	DoorGateLink,
	
	JobLink,
	
	OwnerOnly,
	Text3D:AdminLabel[MAX_PLAYERS],
	IsOpen,
	AutoClose,
	Float:dRange,
	Float:dSpeed,
	
	TollPrice,
	Text3D:TollLabel, 
};

new DoorGates[MAX_DOORGATES][_doorgates];
new Iterator:DoorGate<MAX_DOORGATES>;
new AllTollsLocked = 0;
// ============= Commands =============

CMD:door(playerid, params[])
{
	foreach(new i : DoorGate)
	{
		if(DoorGates[i][Type] == GATE_TYPE_GATE)
			continue;
			
		if(DoorGates[i][Enabled] == 0)
			continue;
		
		if(DoorGates[i][DoorGateLink] > 0)
			continue; 
		
		if(DoorGates[i][IsOpen] == 0 && !IsPlayerInRangeOfPoint(playerid, DoorGates[i][dRange], DoorGates[i][ClosePos][0], DoorGates[i][ClosePos][1], DoorGates[i][ClosePos][2]))
			continue;

		if(DoorGates[i][IsOpen] == 1 && !IsPlayerInRangeOfPoint(playerid, DoorGates[i][dRange], DoorGates[i][OpenPos][0], DoorGates[i][OpenPos][1], DoorGates[i][OpenPos][2]))
			continue;
			
		if(!IsValidDynamicObject(DoorGates[i][ObjectID]))
			continue;
		
		new BizPerm = HasBizPerm(i, playerid), HousePerm = HasHousePerm(i, playerid, params), FactionPerm = HasFactionPerm(i, playerid), GangPerm = HasGangPerm(i, playerid), JobPerm = HasJobPerm(i, playerid);
		
		if(BizPerm > 0 || HousePerm > 0 || FactionPerm > 0 || GangPerm > 0 || JobPerm > 0 || (DoorGates[i][VIPLevel] > 0 && Player[playerid][VipRank] >= DoorGates[i][VIPLevel]) || Player[playerid][AdminDuty] > 0)
		{
			if(DoorGates[i][IsOpen] == 1 && DoorGates[i][AutoClose] == 1)
				return SendClientMessage(playerid, WHITE, "Please wait until the door is finished closing.");
			
			if(DoorGates[i][IsOpen] == 0)
			{
				MoveDynamicObject(DoorGates[i][ObjectID], DoorGates[i][OpenPos][0], DoorGates[i][OpenPos][1], DoorGates[i][OpenPos][2], DoorGates[i][dSpeed], DoorGates[i][OpenRot][0], DoorGates[i][OpenRot][1], DoorGates[i][OpenRot][2]);
				format(string, sizeof(string), "* %s grabs the door handle and opens the door.", GetNameEx(playerid));
				NearByMessage(playerid, NICESKY, string);
				DoorGates[i][IsOpen] = 1;
				MoveLinkedDoorGates(i);
				if(DoorGates[i][AutoClose] == 1)
					defer CloseDoorGate(i);
				
			}
			else
			{
				MoveDynamicObject(DoorGates[i][ObjectID], DoorGates[i][ClosePos][0], DoorGates[i][ClosePos][1], DoorGates[i][ClosePos][2], DoorGates[i][dSpeed], DoorGates[i][CloseRot][0], DoorGates[i][CloseRot][1], DoorGates[i][CloseRot][2]);
				format(string, sizeof(string), "* %s reaches for the door and closes it.", GetNameEx(playerid));
				NearByMessage(playerid, NICESKY, string);
				MoveLinkedDoorGates(i);
				DoorGates[i][IsOpen] = 0;
			}
		}
		break;
	}
	return 1;
}

CMD:gate(playerid, params[])
{
	foreach(new i : DoorGate)
	{
		if(DoorGates[i][Type] == GATE_TYPE_DOOR)
			continue;
			
		if(DoorGates[i][Enabled] == 0)
			continue;
		
		if(DoorGates[i][DoorGateLink] > 0)
			continue; 
		
		if(DoorGates[i][IsOpen] == 0 && !IsPlayerInRangeOfPoint(playerid, DoorGates[i][dRange], DoorGates[i][ClosePos][0], DoorGates[i][ClosePos][1], DoorGates[i][ClosePos][2]))
			continue;

		if(DoorGates[i][IsOpen] == 1 && !IsPlayerInRangeOfPoint(playerid, DoorGates[i][dRange], DoorGates[i][OpenPos][0], DoorGates[i][OpenPos][1], DoorGates[i][OpenPos][2]))
			continue;

		if(!IsValidDynamicObject(DoorGates[i][ObjectID]))
			continue;
		
		new BizPerm = HasBizPerm(i, playerid), HousePerm = HasHousePerm(i, playerid, params), FactionPerm = HasFactionPerm(i, playerid), GangPerm = HasGangPerm(i, playerid), JobPerm = HasJobPerm(i, playerid);
		
		if(BizPerm > 0 || HousePerm > 0 || FactionPerm > 0 || GangPerm > 0 || JobPerm > 0 || (DoorGates[i][VIPLevel] > 0 && Player[playerid][VipRank] >= DoorGates[i][VIPLevel]) ||Player[playerid][AdminDuty] > 0)
		{
			if(DoorGates[i][IsOpen] == 1 && DoorGates[i][AutoClose] == 1)
				return SendClientMessage(playerid, WHITE, "Please wait until the gate is finished closing.");
			
			if(DoorGates[i][IsOpen] == 0)
			{
				MoveDynamicObject(DoorGates[i][ObjectID], DoorGates[i][OpenPos][0], DoorGates[i][OpenPos][1], DoorGates[i][OpenPos][2], DoorGates[i][dSpeed], DoorGates[i][OpenRot][0], DoorGates[i][OpenRot][1], DoorGates[i][OpenRot][2]);
				format(string, sizeof(string), "* %s uses their remote to open the gate.", GetNameEx(playerid));
				NearByMessage(playerid, NICESKY, string);
				DoorGates[i][IsOpen] = 1;
				MoveLinkedDoorGates(i);
				if(DoorGates[i][AutoClose] == 1)
					defer CloseDoorGate(i);
				
			}
			else
			{
				MoveDynamicObject(DoorGates[i][ObjectID], DoorGates[i][ClosePos][0], DoorGates[i][ClosePos][1], DoorGates[i][ClosePos][2], DoorGates[i][dSpeed], DoorGates[i][CloseRot][0], DoorGates[i][CloseRot][1], DoorGates[i][CloseRot][2]);
				format(string, sizeof(string), "* %s uses their remote to close the gate.", GetNameEx(playerid));
				NearByMessage(playerid, NICESKY, string);
				MoveLinkedDoorGates(i);
				DoorGates[i][IsOpen] = 0;
			}
		}
		break;
	}
	return 1;
}

timer CloseDoorGate[5000](i)
{
	MoveDynamicObject(DoorGates[i][ObjectID], DoorGates[i][ClosePos][0], DoorGates[i][ClosePos][1], DoorGates[i][ClosePos][2], DoorGates[i][dSpeed], DoorGates[i][CloseRot][0], DoorGates[i][CloseRot][1], DoorGates[i][CloseRot][2]);
	DoorGates[i][IsOpen] = 0;
}

CMD:createdoor(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
		
	new Float:pos[3], Float:rot[3], modelid, int, vw;
	if(sscanf(params, "p<,>dF(0)F(0)F(0)F(0)F(0)F(0)D(-1)D(-1)", modelid, pos[0], pos[1], pos[2], rot[0], rot[1], rot[2], int, vw))
		return SendClientMessage(playerid, WHITE, "SYNTAX: /createdoor [modelid] <X> <Y> <Z> <RotX> <RotY> <RotZ> <int id> <virtual world>");
		
	if(pos[0] == 0.0 && pos[1] == 0.0 && pos[2] == 0.0)
	{
		GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
		pos[1] += 1;
	}
	
	new id = CreateDoorGate(GATE_TYPE_DOOR, modelid, pos[0], pos[1], pos[2], rot[0], rot[1], rot[2], int, vw, playerid);
	if(id == -1)
		return SendClientMessage(playerid, WHITE, "No more door slots available.");
	
	format(DoorGates[id][CreatedBy], 25, "%s", GetName(playerid));
	
	format(string, sizeof(string), "You have created door id %d. Use /editdoorgate to edit its settings.", id);
	SendClientMessage(playerid, WHITE, string);
	return 1;
}

CMD:creategate(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
		
	new Float:pos[3], Float:rot[3], modelid, int, vw;
	if(sscanf(params, "p<,>dF(0)F(0)F(0)F(0)F(0)F(0)D(-1)D(-1)", modelid, pos[0], pos[1], pos[2], rot[0], rot[1], rot[2], int, vw))
		return SendClientMessage(playerid, WHITE, "SYNTAX: /creategate [modelid] <X> <Y> <Z> <RotX> <RotY> <RotZ> <int id> <virtual world>");
		
	if(pos[0] == 0.0 && pos[1] == 0.0 && pos[2] == 0.0)
	{
		GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
		pos[1] += 1;
	}
	
	new id = CreateDoorGate(GATE_TYPE_GATE, modelid, pos[0], pos[1], pos[2], rot[0], rot[1], rot[2], int, vw, playerid);
	if(id == -1)
		return SendClientMessage(playerid, WHITE, "No more gate slots available.");
	
	format(DoorGates[id][CreatedBy], 25, "%s", GetName(playerid));
	
	format(string, sizeof(string), "You have created gate id %d. Use /editdoorgate to edit its settings.", id);
	SendClientMessage(playerid, WHITE, string);
	return 1;
}

CMD:editdoorgate(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
		
	new id;
	if(sscanf(params, "d", id))
		return SendClientMessage(playerid, WHITE, "SYNTAX: /editdoorgate [id]");
		
	if(!Iter_Contains(DoorGate, id) || id == 0)
		return SendClientMessage(playerid, WHITE, "Invalid ID.");
	
	SetPVarInt(playerid, "EDITING_DOORGATE_ID", id);
	ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
	return 1;
}

CMD:viewdoorgatelabels(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 2)
		return 1;
		
	switch(GetPVarInt(playerid, "ViewDoorGateLabels"))
	{
		case 0:
		{
			foreach(new i : DoorGate)
			{
				if(IsValidDynamic3DTextLabel(DoorGates[i][AdminLabel][playerid]))
					DestroyDynamic3DTextLabel(DoorGates[i][AdminLabel][playerid]);
					
				format(string, sizeof(string), "%s %d", (DoorGates[i][Type] == GATE_TYPE_GATE) ? ("Gate") : (DoorGates[i][Type] == GATE_TYPE_DOOR ? ("Door") : (DoorGates[i][Type] == GATE_TYPE_TOLL ? ("Toll") : ("Cell"))), i);
				DoorGates[i][AdminLabel][playerid] = CreateDynamic3DTextLabel(string, GREEN, DoorGates[i][ClosePos][0], DoorGates[i][ClosePos][1], DoorGates[i][ClosePos][2], 50, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, DoorGates[i][dVW], DoorGates[i][InteriorID], .playerid = playerid);
			}
			
			SetPVarInt(playerid, "ViewDoorGateLabels", 1);
			SendClientMessage(playerid, WHITE, "You can now see door/gate labels.");
		}
		case 1:
		{
			foreach(new i : DoorGate)
			{
				if(IsValidDynamic3DTextLabel(DoorGates[i][AdminLabel][playerid]))
					DestroyDynamic3DTextLabel(DoorGates[i][AdminLabel][playerid]);
			}
			
			DeletePVar(playerid, "ViewDoorGateLabels");
			SendClientMessage(playerid, WHITE, "You will no longer see door/gate labels.");
		}
	}
	return 1;
}

CMD:gotodoorgate(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 2)
		return 1;
		
	new id;
	if(sscanf(params, "d", id))
		return SendClientMessage(playerid, WHITE, "SYNTAX: /gotodoorgate [id]");
		
	if(!Iter_Contains(DoorGate, id) || id == 0)
		return SendClientMessage(playerid, WHITE, "Invalid ID.");
		
	SetPlayerPos(playerid, DoorGates[id][ClosePos][0], DoorGates[id][ClosePos][1], DoorGates[id][ClosePos][2]);
	SetPlayerVirtualWorld(playerid, (DoorGates[id][dVW] == -1) ? (0) : (DoorGates[id][dVW]));
	SetPlayerInterior(playerid, (DoorGates[id][InteriorID] == -1) ? (0) : (DoorGates[id][InteriorID]));
	format(string, sizeof(string), "You have teleported to door/gate %d.", id);
	SendClientMessage(playerid, WHITE, string);
	return 1;
}

CMD:paytoll(playerid, params[])
{
	foreach(new i : DoorGate)
	{
		if(DoorGates[i][Type] != GATE_TYPE_TOLL)
			continue;
		
		if(DoorGates[i][IsOpen] == 0 && !IsPlayerInRangeOfPoint(playerid, DoorGates[i][dRange], DoorGates[i][ClosePos][0], DoorGates[i][ClosePos][1], DoorGates[i][ClosePos][2]))
			continue;

		if(DoorGates[i][IsOpen] == 1 && !IsPlayerInRangeOfPoint(playerid, DoorGates[i][dRange], DoorGates[i][OpenPos][0], DoorGates[i][OpenPos][1], DoorGates[i][OpenPos][2]))
			continue;
			
		if(!IsValidDynamicObject(DoorGates[i][ObjectID]))
			continue;
		
		if(DoorGates[i][IsOpen] == 1 && DoorGates[i][AutoClose] == 1)
				return SendClientMessage(playerid, WHITE, "Please wait until the barrier is finished closing.");
		
		if(DoorGates[i][Enabled] == 0 && Groups[Player[playerid][Group]][CommandTypes] != 1)
		{
			SendClientMessage(playerid, WHITE, "This toll booth has been disabled by the Los Santos Police Department.");
			continue;
		}
		
		if(Groups[Player[playerid][Group]][CommandTypes] == 1)
		{
			if(DoorGates[i][IsOpen] == 0)
			{
				MoveDynamicObject(DoorGates[i][ObjectID], DoorGates[i][OpenPos][0], DoorGates[i][OpenPos][1], DoorGates[i][OpenPos][2], DoorGates[i][dSpeed], DoorGates[i][OpenRot][0], DoorGates[i][OpenRot][1], DoorGates[i][OpenRot][2]);
				DoorGates[i][IsOpen] = 1;
				MoveLinkedDoorGates(i);
				defer CloseDoorGate(i);			
			}
		}
		else
		{	
			if(Player[playerid][Money] < DoorGates[i][TollPrice])
			{
				 format(string, sizeof(string), "You need $%d to pay the toll.", DoorGates[i][TollPrice]);
				 return SendClientMessage(playerid, WHITE, string);
			}
		
			Player[playerid][Money] -= DoorGates[i][TollPrice];
			Groups[TaxGroup][SafeMoney] += DoorGates[i][TollPrice]; 
			MoveDynamicObject(DoorGates[i][ObjectID], DoorGates[i][OpenPos][0], DoorGates[i][OpenPos][1], DoorGates[i][OpenPos][2], DoorGates[i][dSpeed], DoorGates[i][OpenRot][0], DoorGates[i][OpenRot][1], DoorGates[i][OpenRot][2]);
			format(string, sizeof(string), "* %s hands the money to the toll attendant.", GetNameEx(playerid));
			NearByMessage(playerid, NICESKY, string);
			DoorGates[i][IsOpen] = 1;
			MoveLinkedDoorGates(i);
			defer CloseDoorGate(i);	
		}
		break;
	}
	return 1;
}

CMD:locktoll(playerid, params[])
{
	if(Groups[Player[playerid][Group]][CommandTypes] != 1)
		return 1;
	if(Player[playerid][GroupRank] < 5)
		return 1;
	
	new id;
	if(sscanf(params, "d", id))
		return SendClientMessage(playerid, WHITE, "SYNTAX: /locktoll [id]");
		
	if(DoorGates[id][Type] != GATE_TYPE_TOLL)
		return SendClientMessage(playerid, WHITE, "This is not the ID of a toll booth.");
	
	if(DoorGates[id][Enabled] == 1)
	{
		DoorGates[id][Enabled] = 0;
		format(string, sizeof(string), "A toll booth (ID: %d) has been disabled by %s!", id, GetNameEx(playerid));
		GroupMessage(playerid, NICESKY, string);
	}
	else
	{
		DoorGates[id][Enabled] = 1;
		format(string, sizeof(string), "A toll booth (ID: %d) has been enabled by %s!", id, GetNameEx(playerid));
		GroupMessage(playerid, NICESKY, string);
	}
	return 1;
}

CMD:listtolls(playerid, params[])
{
	if(Groups[Player[playerid][Group]][CommandTypes] != 1)
		return 1;
	if(Player[playerid][GroupRank] < 5)
		return 1;
	
	new str[128], count = 1, location[MAX_ZONE_NAME];
	SendClientMessage(playerid, GREY, "----------------------");
	foreach(new i : DoorGate)
	{
		if(DoorGates[i][Type] == GATE_TYPE_TOLL)
		{
			Get2DPosZone(DoorGates[i][ClosePos][0], DoorGates[i][ClosePos][1], location, MAX_ZONE_NAME);
			format(str, sizeof(str), "Toll Booth %d | ID %d | Location: %s | Enabled: %s", count, i, location, (DoorGates[i][Enabled]) ? ("Yes") : ("No"));
			SendClientMessage(playerid, GREY, str);
			count++;
		}
	}
	SendClientMessage(playerid, GREY, "----------------------");
	return 1;
}

CMD:lockalltolls(playerid, params[])
{
    if(Groups[Player[playerid][Group]][CommandTypes] != 1)
        return 1;
		
    if(Player[playerid][GroupRank] < 5)
        return 1;
   
    new str[128];
    if(!AllTollsLocked)
    {
        foreach(new i : DoorGate)
        {
            if(DoorGates[i][Type] == GATE_TYPE_TOLL)
            {
                DoorGates[i][Enabled] = 0;
            }
        }
		AllTollsLocked = 1;
        format(str, sizeof(str), "All tolls have been locked by %s!", GetNameEx(playerid));
    }
    else
    {
        foreach(new i : DoorGate)
        {
            if(DoorGates[i][Type] == GATE_TYPE_TOLL)
            {
                DoorGates[i][Enabled] = 1;
            }
        }
		AllTollsLocked = 0;
        format(str, sizeof(str), "All tolls have been unlocked by %s!", GetNameEx(playerid));      
    }
    GroupMessage(playerid, NICESKY, str);
    return 1;
}

CMD:cell(playerid, params[])
{
	if(Groups[Player[playerid][Group]][CommandTypes] != 1)
		return 1;
		
	foreach(new i : DoorGate)
	{
		if(DoorGates[i][Type] != GATE_TYPE_CELL)
			continue;
			
		if(DoorGates[i][Enabled] == 0)
			continue;
		
		if(DoorGates[i][DoorGateLink] > 0)
			continue; 
		
		if(DoorGates[i][IsOpen] == 0 && !IsPlayerInRangeOfPoint(playerid, DoorGates[i][dRange], DoorGates[i][ClosePos][0], DoorGates[i][ClosePos][1], DoorGates[i][ClosePos][2]))
			continue;

		if(DoorGates[i][IsOpen] == 1 && !IsPlayerInRangeOfPoint(playerid, DoorGates[i][dRange], DoorGates[i][OpenPos][0], DoorGates[i][OpenPos][1], DoorGates[i][OpenPos][2]))
			continue;
			
		if(!IsValidDynamicObject(DoorGates[i][ObjectID]))
			continue;
		
		if(DoorGates[i][IsOpen] == 1 && DoorGates[i][AutoClose] == 1)
			return SendClientMessage(playerid, WHITE, "Please wait until the cell is finished closing.");
			
		if(DoorGates[i][IsOpen] == 0)
		{
			MoveDynamicObject(DoorGates[i][ObjectID], DoorGates[i][OpenPos][0], DoorGates[i][OpenPos][1], DoorGates[i][OpenPos][2], DoorGates[i][dSpeed], DoorGates[i][OpenRot][0], DoorGates[i][OpenRot][1], DoorGates[i][OpenRot][2]);
			format(string, sizeof(string), "* %s inserts their key into the cell and opens it.", GetNameEx(playerid));
			NearByMessage(playerid, NICESKY, string);
			DoorGates[i][IsOpen] = 1;
			MoveLinkedDoorGates(i);
			if(DoorGates[i][AutoClose] == 1)
				defer CloseDoorGate(i);
		}
		else
		{
			MoveDynamicObject(DoorGates[i][ObjectID], DoorGates[i][ClosePos][0], DoorGates[i][ClosePos][1], DoorGates[i][ClosePos][2], DoorGates[i][dSpeed], DoorGates[i][CloseRot][0], DoorGates[i][CloseRot][1], DoorGates[i][CloseRot][2]);
			format(string, sizeof(string), "* %s closes the cell door and locks it.", GetNameEx(playerid));
			NearByMessage(playerid, NICESKY, string);
			MoveLinkedDoorGates(i);
			DoorGates[i][IsOpen] = 0;
		}
		break;
	}
	return 1;
}
// ============= Callbacks =============

hook OnPlayerDisconnect(playerid, reason)
{
	if(Player[playerid][AdminLevel] >= 2)
	{
		foreach(new i : DoorGate)
		{
			if(IsValidDynamic3DTextLabel(DoorGates[i][AdminLabel][playerid]))
				DestroyDynamic3DTextLabel(DoorGates[i][AdminLabel][playerid]);
		}
	}
	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsKeyJustDown(KEY_SECONDARY_ATTACK, newkeys, oldkeys))
		cmd_door(playerid, "");
	return 1;
}

hook OnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	if(GetPVarInt(playerid, "EDITING_DOORGATE") == 1)
	{
		new id = -1;
		foreach(new dg : DoorGate)
		{
			if(DoorGates[dg][ObjectID] == objectid)
			{
				id = dg;
				break;
			}
		}
		
		if(id == -1)
			return SendClientMessage(playerid, WHITE, "[Error] Couldn't find object id.");
		
		new Float:oldX, Float:oldY, Float:oldZ, Float:oldRX, Float:oldRY, Float:oldRZ;
		GetDynamicObjectPos(objectid, oldX, oldY, oldZ);
		GetDynamicObjectRot(objectid, oldRX, oldRY, oldRZ);
		
		if(response == EDIT_RESPONSE_FINAL)
		{
			switch(GetPVarInt(playerid, "EDIT_DOORGATE_POS"))
			{
				case 1:
				{
					DoorGates[id][ClosePos][0] = x;
					DoorGates[id][ClosePos][1] = y;
					DoorGates[id][ClosePos][2] = z;
					DoorGates[id][CloseRot][0] = rx;
					DoorGates[id][CloseRot][1] = ry;
					DoorGates[id][CloseRot][2] = rz;
					SaveDoorGate(id);
					SendClientMessage(playerid, WHITE, "Successfully edited door/gate close position.");
				}
				case 2:
				{
					DoorGates[id][OpenPos][0] = x;
					DoorGates[id][OpenPos][1] = y;
					DoorGates[id][OpenPos][2] = z;
					DoorGates[id][OpenRot][0] = rx;
					DoorGates[id][OpenRot][1] = ry;
					DoorGates[id][OpenRot][2] = rz;
					SaveDoorGate(id);
					SetDynamicObjectPos(DoorGates[id][ObjectID], DoorGates[id][ClosePos][0], DoorGates[id][ClosePos][1], DoorGates[id][ClosePos][2]);
					SetDynamicObjectRot(DoorGates[id][ObjectID], DoorGates[id][CloseRot][0], DoorGates[id][CloseRot][1], DoorGates[id][CloseRot][2]);
					SendClientMessage(playerid, WHITE, "Successfully edited door/gate close position.");
				}
			}
		
		}
		else if(response == EDIT_RESPONSE_CANCEL)
		{
			DeletePVar(playerid, "EDITING_DOORGATE");
			SetDynamicObjectPos(objectid, oldX, oldY, oldZ);
			SetDynamicObjectRot(objectid, oldRX, oldRY, oldRZ);
		}
	}
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DIALOG_EDIT_DOORGATE:
		{
			if(!response)
				return 1;
			
			new id = GetPVarInt(playerid, "EDITING_DOORGATE_ID");
			
			switch(listitem)
			{
				case 0:
				{
					if(DoorGates[id][Enabled] == 1)
						DoorGates[id][Enabled] = 0;
					else DoorGates[id][Enabled] = 1;
					SaveDoorGate(id);
					ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
				}
				case 1: ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE_MODEL, DIALOG_STYLE_INPUT, "Edit Door/Gate - Model ID", "Enter the model ID you wish to use.", "Accept", "Back");
				case 2:
				{
					if(DoorGates[id][Type] == GATE_TYPE_GATE)
						DoorGates[id][Type] = GATE_TYPE_DOOR;
					else if(DoorGates[id][Type] == GATE_TYPE_DOOR)
					{
						DoorGates[id][Type] = GATE_TYPE_TOLL;
						new str[128];
						format(str, sizeof(str), "Toll Booth (Cost: $%d)\n(( /paytoll ))", DoorGates[id][TollPrice]);
						DoorGates[id][TollLabel] = CreateDynamic3DTextLabel(str, GREEN, DoorGates[id][ClosePos][0], DoorGates[id][ClosePos][1], DoorGates[id][ClosePos][2], 10, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, DoorGates[id][dVW], -1, -1, 100);

					}
					else if(DoorGates[id][Type] == GATE_TYPE_TOLL)
					{
						DoorGates[id][Type] = GATE_TYPE_CELL;
						DestroyDynamic3DTextLabel(DoorGates[id][TollLabel]);
					}
					else if(DoorGates[id][Type] == GATE_TYPE_CELL)
						DoorGates[id][Type] = GATE_TYPE_GATE;
					SaveDoorGate(id);
					ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
				}
				case 3:	SetPVarInt(playerid, "EDIT_DOORGATE_POS", 1), ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE_POS,  DIALOG_STYLE_LIST, "Edit Door/Gate - Close Positon", "Enter Exact Position\nEnter Exact Rotation\nEdit using GUI", "Select", "Back");
				case 4:	SetPVarInt(playerid, "EDIT_DOORGATE_POS", 2), ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE_POS,  DIALOG_STYLE_LIST, "Edit Door/Gate - Open Positon", "Enter Exact Position\nEnter Exact Rotation\nEdit using GUI", "Select", "Back");
				case 5:	ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE_INT, DIALOG_STYLE_INPUT, "Edit Door/Gate - Interior ID", "Enter the desired interior ID.", "Accept", "Back");
				case 6: ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE_VW, DIALOG_STYLE_INPUT, "Edit Door/Gate - Virtual World", "Enter the desired virtual world.", "Accept", "Back");
				case 7: ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE_BIZ, DIALOG_STYLE_INPUT, "Edit Door/Gate - Biz Link", "Enter the desired business ID to link.", "Accept", "Back");
				case 8:
				{
					if(DoorGates[id][UseVIPKey] == 1)
						DoorGates[id][UseVIPKey] = 0;
					else DoorGates[id][UseVIPKey] = 1;
					SaveDoorGate(id);
					ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
				}
				case 9: ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE_HOUSE, DIALOG_STYLE_INPUT, "Edit Door/Gate - House Link", "Enter the desired house ID to link.", "Accept", "Back");
				case 10:
				{
					if(DoorGates[id][UseKpp] == 1)
						DoorGates[id][UseKpp] = 0;
					else DoorGates[id][UseKpp] = 1;
					SaveDoorGate(id);
					ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
				}
				case 11:
				{
					if(DoorGates[id][OwnerOnly] == 1) 
						DoorGates[id][OwnerOnly] = 0;
					else DoorGates[id][OwnerOnly] = 1;
					SaveDoorGate(id);
					ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
				}
				case 12: ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE_FACTION, DIALOG_STYLE_INPUT, "Edit Door/Gate - Faction Link", "Enter the desired faction ID to link.", "Accept", "Back");
				case 13: ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE_GANG, DIALOG_STYLE_INPUT, "Edit Door/Gate - Gang Link", "Enter the desired gang ID to link.", "Accept", "Back");
				case 14: ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE_RANK, DIALOG_STYLE_INPUT, "Edit Door/Gate - Required Rank", "Enter the required Faction/Gang rank.", "Accept", "Back");
				case 15: ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE_VIP, DIALOG_STYLE_INPUT, "Edit Door/Gate - VIP Level", "Enter the required VIP level.", "Accept", "Back");
				case 16: ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE_LINK, DIALOG_STYLE_INPUT, "Edit Door/Gate - Door/Gate Link", "Enter the desired link ID\nNote: This will disable this door/gate and make it open when the link opens.", "Accept", "Back");
				case 17:
				{
					if(DoorGates[id][AutoClose] == 1)
						DoorGates[id][AutoClose] = 0;
					else DoorGates[id][AutoClose] = 1;
					SaveDoorGate(id);
					ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
				}
				case 18: ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE_JOB, DIALOG_STYLE_INPUT, "Edit Door/Gate - Job Link", "Enter the desired job ID to link.", "Accept", "Back");
				case 19: ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE_RANGE, DIALOG_STYLE_INPUT, "Edit Door/Gate - Range", "Enter the desired range.", "Accept", "Back");
				case 20: ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE_SPEED, DIALOG_STYLE_INPUT, "Edit Door/Gate - Speed", "Enter the desired speed.", "Accept", "Back");
				case 21: 
				{
					if(DoorGates[id][Type] != GATE_TYPE_TOLL)
						return SendClientMessage(playerid, WHITE, "Only tolls can have their prices edited.");
					if(Player[playerid][AdminLevel] < 5)
						return SendClientMessage(playerid, WHITE, "Only level 5+ admins can change the toll prices.");
					ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE_TOLLPRICE, DIALOG_STYLE_INPUT, "Edit Toll Price", "Enter the desired price.", "Accept", "Back");
				}
				case 22: 
				{
					format(string, sizeof(string), "You have deleted doorgate id %d. (SQLID: %d)", id, DoorGates[id][SQLID]);
					SendClientMessage(playerid, WHITE, string);
					format(string, sizeof(string), "%s has deleted doorgate id %d. (SQLID: %d)", Player[playerid][AdminName], id, DoorGates[id][SQLID]);
					AdminActionsLog(string);
					DeleteDoorGate(id);
				}
			}
		}
		case DIALOG_EDIT_DOORGATE_MODEL:
		{
			new model = strval(inputtext), id = GetPVarInt(playerid, "EDITING_DOORGATE_ID");
			if(!response)
				return ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");

			if(model < 1)
			{
				SendClientMessage(playerid, RED, "Invalid model id.");
				return ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
			}
		
			DoorGates[id][ModelID] = model;
			UpdateDoorGateObject(id);
			SendClientMessage(playerid, WHITE, "You have successfully changed the model ID.");
			SaveDoorGate(id);
			return ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
		}
		case DIALOG_EDIT_DOORGATE_POS:
		{
			new id = GetPVarInt(playerid, "EDITING_DOORGATE_ID");
			if(!response)
				return ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
			
			switch(listitem)
			{
				case 0: SetPVarInt(playerid, "EDITING_DOORGATE_POS_POS_OR_ROT", 1), ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE_POS+1, DIALOG_STYLE_INPUT, "Edit Door/Gate - Position", "Enter the desired position in the following formated: X Y Z", "Accept", "Cancel");
				case 1: SetPVarInt(playerid, "EDITING_DOORGATE_POS_POS_OR_ROT", 2), ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE_POS+1, DIALOG_STYLE_INPUT, "Edit Door/Gate - Position", "Enter the desired rotation in the following formated: X Y Z", "Accept", "Cancel");
				case 2: SetPVarInt(playerid, "EDITING_DOORGATE", 1), EditDynamicObject(playerid, DoorGates[id][ObjectID]);
			}
		}
		case DIALOG_EDIT_DOORGATE_POS + 1:
		{
			if(!response)
				return 1;
			
			new id = GetPVarInt(playerid, "EDITING_DOORGATE_ID");
			
			new Float:x, Float:y, Float:z;
			if(sscanf(inputtext, "p<,>fff", x, y, z))
			{
				SendClientMessage(playerid, RED, "Invalid coordinates given.");
				return ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
			}
			
			switch(GetPVarInt(playerid, "EDIT_DOORGATE_POS"))
			{
				case 1: //Close
				{
					if(GetPVarInt(playerid, "EDITING_DOORGATE_POS_POS_OR_ROT") == 1)
					{
						DoorGates[id][ClosePos][0] = x;
						DoorGates[id][ClosePos][1] = y;
						DoorGates[id][ClosePos][2] = z;
					}
					else 
					{
						DoorGates[id][CloseRot][0] = x;
						DoorGates[id][CloseRot][1] = y;
						DoorGates[id][CloseRot][2] = z;
					}
					SetDynamicObjectPos(DoorGates[id][ObjectID], DoorGates[id][ClosePos][0], DoorGates[id][ClosePos][1], DoorGates[id][ClosePos][2]);
					SetDynamicObjectRot(DoorGates[id][ObjectID], DoorGates[id][CloseRot][0], DoorGates[id][CloseRot][1], DoorGates[id][CloseRot][2]);
				}
				case 2: //Open
				{
					if(GetPVarInt(playerid, "EDITING_DOORGATE_POS_POS_OR_ROT") == 1)
					{
						DoorGates[id][OpenPos][0] = x;
						DoorGates[id][OpenPos][1] = y;
						DoorGates[id][OpenPos][2] = z;
					}
					else 
					{
						DoorGates[id][OpenRot][0] = x;
						DoorGates[id][OpenRot][1] = y;
						DoorGates[id][OpenRot][2] = z;
					}
				}
			}
			SendClientMessage(playerid, WHITE, "You have successfully edited the position/rotation.");
			SaveDoorGate(id);
			return ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
		}
		case DIALOG_EDIT_DOORGATE_INT:
		{
			new int = strval(inputtext), id = GetPVarInt(playerid, "EDITING_DOORGATE_ID");
			
			if(int < 0)
			{
				SendClientMessage(playerid, RED, "Invalid interior id.");
				return ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
			}
			
			DoorGates[id][InteriorID] = int;
			UpdateDoorGateObject(id);
			format(string, sizeof(string), "You have successfully changed the interior ID to %d.", int);
			SendClientMessage(playerid, WHITE, string);
			SaveDoorGate(id);
			return ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
		}
		case DIALOG_EDIT_DOORGATE_VW:
		{
			new vw = strval(inputtext), id = GetPVarInt(playerid, "EDITING_DOORGATE_ID");
			
			if(vw < 0)
			{
				SendClientMessage(playerid, RED, "Invalid virtual world.");
				return ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
			}
			
			DoorGates[id][dVW] = vw;
			UpdateDoorGateObject(id);
			format(string, sizeof(string), "You have successfully changed the virtual world to %d.", vw);
			SendClientMessage(playerid, WHITE, string);
			SaveDoorGate(id);
			return ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
		}
		case DIALOG_EDIT_DOORGATE_BIZ:
		{
			new bid = strval(inputtext), id = GetPVarInt(playerid, "EDITING_DOORGATE_ID");
			
			if(bid < 0 || bid > MAX_BUSINESSES)
			{
				SendClientMessage(playerid, RED, "Invalid business id.");
				return ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
			}
			
			DoorGates[id][BizLink] = bid;
			format(string, sizeof(string), "You have successfully changed the business link to %d.", bid);
			SendClientMessage(playerid, WHITE, string);
			SaveDoorGate(id);
			return ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
		}	
		case DIALOG_EDIT_DOORGATE_HOUSE:
		{
			new hid = strval(inputtext), id = GetPVarInt(playerid, "EDITING_DOORGATE_ID");
			
			if(hid < 0 || hid > MAX_HOUSES)
			{
				SendClientMessage(playerid, RED, "Invalid house id.");
				return ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
			}
			
			DoorGates[id][HouseLink] = hid;
			format(string, sizeof(string), "You have successfully changed the house link to %d.", hid);
			SendClientMessage(playerid, WHITE, string);
			SaveDoorGate(id);
			return ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
		}
		case DIALOG_EDIT_DOORGATE_FACTION:
		{
			new fid = strval(inputtext), id = GetPVarInt(playerid, "EDITING_DOORGATE_ID");
			
			if(fid < 0 || fid > MAX_GROUPS)
			{
				SendClientMessage(playerid, RED, "Invalid faction id.");
				return ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
			}
			
			DoorGates[id][GroupLink] = fid;
			format(string, sizeof(string), "You have successfully changed the faction link to %d.", fid);
			SendClientMessage(playerid, WHITE, string);
			SaveDoorGate(id);
			return ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
		}
		case DIALOG_EDIT_DOORGATE_GANG:
		{
			new gid = strval(inputtext), id = GetPVarInt(playerid, "EDITING_DOORGATE_ID");
			
			if(gid < 0 || !DoesGangExist(gid))
			{
				SendClientMessage(playerid, RED, "Invalid gang id.");
				return ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
			}
			
			DoorGates[id][GangLink] = gid;
			format(string, sizeof(string), "You have successfully changed the gang link to %d.", gid);
			SendClientMessage(playerid, WHITE, string);
			SaveDoorGate(id);
			return ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
		}
		case DIALOG_EDIT_DOORGATE_RANK:
		{
			new rank = strval(inputtext), id = GetPVarInt(playerid, "EDITING_DOORGATE_ID");
			
			if(rank < 0 || rank > 10)
			{
				SendClientMessage(playerid, RED, "Invalid rank.");
				return ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
			}
			
			DoorGates[id][GroupRank] = rank;
			format(string, sizeof(string), "You have successfully changed the required rank to %d.", rank);
			SendClientMessage(playerid, WHITE, string);
			SaveDoorGate(id);
			return ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
		}
		case DIALOG_EDIT_DOORGATE_VIP:
		{
			new vip = strval(inputtext), id = GetPVarInt(playerid, "EDITING_DOORGATE_ID");
			
			if(vip < 0)
			{
				SendClientMessage(playerid, RED, "Invalid vip level.");
				return ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
			}
			
			DoorGates[id][VIPLevel] = vip;
			format(string, sizeof(string), "You have successfully changed the required vip level to %d.", vip);
			SendClientMessage(playerid, WHITE, string);
			SaveDoorGate(id);
			return ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
		}
		case DIALOG_EDIT_DOORGATE_LINK:
		{
			new link = strval(inputtext), id = GetPVarInt(playerid, "EDITING_DOORGATE_ID");
			if(link < 0 || (!Iter_Contains(DoorGate, link) && link != 0))
			{
				SendClientMessage(playerid, RED, "Invalid door/gate link ID.");
				return ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
			}
			
			DoorGates[id][DoorGateLink] = link;
			format(string, sizeof(string), "You have successfully changed the door/gate link to ID %d.", link);
			SendClientMessage(playerid, WHITE, string);
			SaveDoorGate(id);
			return ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
		}
		case DIALOG_EDIT_DOORGATE_JOB:
		{
			new job = strval(inputtext), id = GetPVarInt(playerid, "EDITING_DOORGATE_ID");
			if(job < 0 || job > MAX_JOBS)
			{
				SendClientMessage(playerid, RED, "Invalid door/gate job ID.");
				return ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
			}
			
			DoorGates[id][JobLink] = job;
			format(string, sizeof(string), "You have successfully changed the door/gate job to ID %d.", job);
			SendClientMessage(playerid, WHITE, string);
			SaveDoorGate(id);
			return ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
		}
		case DIALOG_EDIT_DOORGATE_RANGE:
		{
			new Float:range = floatstr(inputtext), id = GetPVarInt(playerid, "EDITING_DOORGATE_ID");
			if(range < 0.0)
			{
				SendClientMessage(playerid, RED, "Invalid door/gate range.");
				return ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
			}
			
			DoorGates[id][dRange] = range;
			format(string, sizeof(string), "You have successfully changed the door/gate range to %f.", range);
			SendClientMessage(playerid, WHITE, string);
			SaveDoorGate(id);
			return ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
		}
		case DIALOG_EDIT_DOORGATE_SPEED:
		{
			new Float:speed = floatstr(inputtext), id = GetPVarInt(playerid, "EDITING_DOORGATE_ID");
			if(speed < 0.0)
			{
				SendClientMessage(playerid, RED, "Invalid door/gate speed.");
				return ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
			}
			
			DoorGates[id][dSpeed] = speed;
			format(string, sizeof(string), "You have successfully changed the door/gate speed to %f.", speed);
			SendClientMessage(playerid, WHITE, string);
			SaveDoorGate(id);
			return ShowPlayerDialog(playerid, DIALOG_EDIT_DOORGATE, DIALOG_STYLE_LIST, "Edit Door/Gate", EditDoorGateString(id), "Select", "Cancel");
		}
		case DIALOG_EDIT_DOORGATE_TOLLPRICE:
		{
			new price = strval(inputtext), id = GetPVarInt(playerid, "EDITING_DOORGATE_ID");
			if(price < 0)
				return SendClientMessage(playerid, WHITE, "You can't set a value of below 0.");
			DoorGates[id][TollPrice] = price;
			format(string, sizeof(string), "You have successfully changed the toll price of ID: %d to $%d.", id, price);
			SendClientMessage(playerid, WHITE, string);
			new str[128];
			format(str, sizeof(str), "Toll Booth (Cost: $%d)\n(( /paytoll ))", DoorGates[id][TollPrice]);
			UpdateDynamic3DTextLabelText(DoorGates[id][TollLabel], GREEN, str);
			SaveDoorGate(id);
		}
	}
	return 1;
}

// ============= Functions =============

stock CreateDoorGate(type, modelid, Float:closeX, Float:closeY, Float:closeZ, Float:closeRotX, Float:closeRotY, Float:closeRotZ, IntID = -1, vw = -1, playerid = INVALID_PLAYER_ID)
{
	new id = Iter_Free(DoorGate);
	
	if(id == 0)
		Iter_Add(DoorGate, 0), id = Iter_Free(DoorGate);
	
	if(id == -1)
		return id;
		
	DoorGates[id][Type] = type;
	DoorGates[id][ModelID] = modelid;
	DoorGates[id][ClosePos][0] = closeX;
	DoorGates[id][ClosePos][1] = closeY;
	DoorGates[id][ClosePos][2] = closeZ;
	DoorGates[id][CloseRot][0] = closeRotX;
	DoorGates[id][CloseRot][1] = closeRotY;
	DoorGates[id][CloseRot][2] = closeRotZ;
	DoorGates[id][OpenPos][0] = closeX;
	DoorGates[id][OpenPos][1] = closeY;
	DoorGates[id][OpenPos][2] = closeZ;
	DoorGates[id][OpenRot][0] = closeRotX;
	DoorGates[id][OpenRot][1] = closeRotY;
	DoorGates[id][OpenRot][2] = closeRotZ;
	DoorGates[id][InteriorID] = IntID;
	DoorGates[id][dVW] = vw;
	
	if(type == GATE_TYPE_GATE)
		DoorGates[id][dRange] = 30.0;
	else DoorGates[id][dRange] = 3.0;
	DoorGates[id][dSpeed] = 2.0;
	DoorGates[id][ObjectID] = CreateDynamicObject(DoorGates[id][ModelID], DoorGates[id][ClosePos][0], DoorGates[id][ClosePos][1], DoorGates[id][ClosePos][2], DoorGates[id][CloseRot][0], DoorGates[id][CloseRot][1], DoorGates[id][CloseRot][2], DoorGates[id][dVW], DoorGates[id][InteriorID]);
	Iter_Add(DoorGate, id);
	new Cache:cache;
	mysql_format(MYSQL_MAIN, query, sizeof(query), "INSERT INTO DoorGates (ModelID, CreatedBy) VALUES ('%d', '%e')", DoorGates[id][ModelID], GetName(playerid));
	cache = mysql_query(MYSQL_MAIN, query);
	DoorGates[id][SQLID] = cache_insert_id();
	cache_delete(cache);
	SaveDoorGate(id);
	return id;
}

stock DeleteDoorGate(id)
{
	Iter_Remove(DoorGate, id);
	mysql_format(MYSQL_MAIN, query, sizeof(query), "UPDATE DoorGates SET Deleted = '1' WHERE SQLID = '%d'", DoorGates[id][SQLID]);
	mysql_query(MYSQL_MAIN, query, false);
	
	DestroyDynamicObject(DoorGates[id][ObjectID]);
	
	foreach(Player, i)
	{
		if(IsValidDynamic3DTextLabel(DoorGates[id][AdminLabel][i]))
			DestroyDynamic3DTextLabel(DoorGates[id][AdminLabel][i]);
	}
	
	if(DoorGates[id][Type] == GATE_TYPE_GATE)
	{
		DestroyDynamic3DTextLabel(DoorGates[id][TollLabel]);
	}
	
	DoorGates[id][Type] = 0;
	DoorGates[id][ModelID] = 0;
	DoorGates[id][ClosePos][0] = 0.0;
	DoorGates[id][ClosePos][1] = 0.0;
	DoorGates[id][ClosePos][2] = 0.0;
	DoorGates[id][CloseRot][0] = 0.0;
	DoorGates[id][CloseRot][1] = 0.0;
	DoorGates[id][CloseRot][2] = 0.0;
	DoorGates[id][OpenPos][0] = 0.0;
	DoorGates[id][OpenPos][1] = 0.0;
	DoorGates[id][OpenPos][2] = 0.0;
	DoorGates[id][OpenRot][0] = 0.0;
	DoorGates[id][OpenRot][1] = 0.0;
	DoorGates[id][OpenRot][2] = 0.0;
	DoorGates[id][InteriorID] = 0;
	DoorGates[id][dVW] = 0;
	return 1;
}

stock UpdateDoorGateObject(id)
{
	if(IsValidDynamicObject(DoorGates[id][ObjectID]))
		DestroyDynamicObject(DoorGates[id][ObjectID]);
	DoorGates[id][ObjectID] = CreateDynamicObject(DoorGates[id][ModelID], DoorGates[id][ClosePos][0], DoorGates[id][ClosePos][1], DoorGates[id][ClosePos][2], DoorGates[id][CloseRot][0], DoorGates[id][CloseRot][1], DoorGates[id][CloseRot][2], DoorGates[id][dVW], DoorGates[id][InteriorID]);
	return 1;		
}

//Red {FF0000}
//Green {33A10B}

stock EditDoorGateString(id)
{
	new EditString[512];
	format(EditString, sizeof(EditString), "{FFFFFF}Status: %s\n", (DoorGates[id][Enabled] == 1) ? ("{33A10B}Enabled{FFFFFF}") : ("{FF0000}Disabled{FFFFFF}"));
	format(EditString, sizeof(EditString), "%sModelID: %d\n", EditString, DoorGates[id][ModelID]);
	format(EditString, sizeof(EditString), "%sType: %s\n", EditString, (DoorGates[id][Type] == GATE_TYPE_GATE) ? ("Gate") : (DoorGates[id][Type] == GATE_TYPE_DOOR ? ("Door") : (DoorGates[id][Type] == GATE_TYPE_TOLL ? ("Toll") : ("Cell"))));
	format(EditString, sizeof(EditString), "%sClose Position\nOpen Position\n", EditString);
	format(EditString, sizeof(EditString), "%sInterior ID: %d\n", EditString, DoorGates[id][InteriorID]);
	format(EditString, sizeof(EditString), "%sVirtual World: %d\n", EditString, DoorGates[id][dVW]);
	format(EditString, sizeof(EditString), "%sBiz Link: %d\n", EditString, DoorGates[id][BizLink]);
	format(EditString, sizeof(EditString), "%sUse VIP Key: %s\n", EditString, (DoorGates[id][UseVIPKey] == 1) ? ("{33A10B}Yes{FFFFFF}") : ("{FF0000}No{FFFFFF}"));
	format(EditString, sizeof(EditString), "%sHouse Link: %d\n", EditString, DoorGates[id][HouseLink]);
	format(EditString, sizeof(EditString), "%sUse KPP: %s\n", EditString, (DoorGates[id][UseKpp] == 1) ? ("{33A10B}Yes{FFFFFF}") : ("{FF0000}No{FFFFFF}"));
	format(EditString, sizeof(EditString), "%sOwner Only: %s\n", EditString, (DoorGates[id][OwnerOnly] == 1) ? ("{33A10B}Yes{FFFFFF}") : ("{FF0000}No{FFFFFF}"));
	format(EditString, sizeof(EditString), "%sFaction Link: %d\n", EditString, DoorGates[id][GroupLink]);
	format(EditString, sizeof(EditString), "%sGang Link:%d\n", EditString, DoorGates[id][GangLink]);
	format(EditString, sizeof(EditString), "%sRequired Rank: %d\n", EditString, DoorGates[id][GroupRank]);
	format(EditString, sizeof(EditString), "%sRequired VIP Level: %d\n", EditString, DoorGates[id][VIPLevel]);
	format(EditString, sizeof(EditString), "%sDoor/Gate Link: %d\n", EditString, DoorGates[id][DoorGateLink]);
	format(EditString, sizeof(EditString), "%sAuto-Close: %s\n", EditString, (DoorGates[id][AutoClose] == 1) ? ("{33A10B}Yes{FFFFFF}") : ("{FF0000}No{FFFFFF}"));
	format(EditString, sizeof(EditString), "%sJob Link: %d\n", EditString, DoorGates[id][JobLink]);
	format(EditString, sizeof(EditString), "%sRange: %f\n", EditString, DoorGates[id][dRange]);
	format(EditString, sizeof(EditString), "%sSpeed: %f\n", EditString, DoorGates[id][dSpeed]);
	format(EditString, sizeof(EditString), "%sToll Price: %d\n", EditString, DoorGates[id][TollPrice]);
	format(EditString, sizeof(EditString), "%s{FF0000}Delete{FFFFFF}\n", EditString);
	format(EditString, sizeof(EditString), "%sCreated by: %s\n", EditString, DoorGates[id][CreatedBy]);
	return EditString;
}

stock HasBizPerm(id, playerid)
{
	if(DoorGates[id][BizLink] > 0)
	{
		if(DoorGates[id][UseVIPKey] == 1 && Player[playerid][VIPPass] == DoorGates[id][BizLink])
			return 1;
			
		if(DoorGates[id][OwnerOnly] == 0 && PlayerHasBusinessKey(playerid, DoorGates[id][BizLink]))
			return 1;
			
		if(DoorGates[id][OwnerOnly] == 1 && Player[playerid][Business] == DoorGates[id][BizLink])
			return 1;
	}
	return 0;
}

stock HasHousePerm(id, playerid, kpp[])
{
	if(DoorGates[id][HouseLink] > 0)
	{
		if(Houses[DoorGates[id][HouseLink]][Keypad] > 0 && strval(kpp) == Houses[DoorGates[id][HouseLink]][Keypad] && DoorGates[id][UseKpp] == 1)
			return 1;
		
		if(DoorGates[id][OwnerOnly] == 0 && PlayerHasHouseKey(playerid, DoorGates[id][HouseLink]))
			return 1;
			
		if(DoorGates[id][OwnerOnly] == 1 && (Player[playerid][House] == DoorGates[id][HouseLink] || Player[playerid][House2] == DoorGates[id][HouseLink]))
			return 1;
	}
	return 0;
}

stock HasFactionPerm(id, playerid)
{
	if(DoorGates[id][GroupLink] > 0)
	{
		if(DoorGates[id][GroupLink] == Player[playerid][Group] && Player[playerid][GroupRank] >= DoorGates[id][GroupRank])
			return 1;
		
	}
	return 0;
}

stock HasGangPerm(id, playerid)
{
	if(DoorGates[id][GangLink] > 0)
	{
		if(DoorGates[id][GangLink] == Player[playerid][Gang] && Player[playerid][GangRank] >= DoorGates[id][GroupRank])
			return 1;
		
	}
	return 0;
}

stock HasJobPerm(id, playerid)
{
	if(DoorGates[id][JobLink] > 0)
	{
		if(DoorGates[id][JobLink] == Player[playerid][Job] || DoorGates[id][JobLink] == Player[playerid][Job2])
			return 1;
	}
	return 0;
}

stock MoveLinkedDoorGates(id)
{
	foreach(new i : DoorGate)
	{
		if(DoorGates[i][Enabled] == 0)
			continue;
			
		if(DoorGates[i][DoorGateLink] == id)
		{
			if(DoorGates[i][IsOpen] == 0)
			{
				MoveDynamicObject(DoorGates[i][ObjectID], DoorGates[i][OpenPos][0], DoorGates[i][OpenPos][1], DoorGates[i][OpenPos][2], 2.0, DoorGates[i][OpenRot][0], DoorGates[i][OpenRot][1], DoorGates[i][OpenRot][2]);
				DoorGates[i][IsOpen] = 1;
				
				if(DoorGates[i][AutoClose] == 1)
					defer CloseDoorGate(i);
			}
			else
			{
				MoveDynamicObject(DoorGates[i][ObjectID], DoorGates[i][ClosePos][0], DoorGates[i][ClosePos][1], DoorGates[i][ClosePos][2], 2.0, DoorGates[i][CloseRot][0], DoorGates[i][CloseRot][1], DoorGates[i][CloseRot][2]);
				DoorGates[i][IsOpen] = 0;
			}
		}
	}
	return 1;
}

stock SaveDoorGate(id)
{
	mysql_format(MYSQL_MAIN, query, sizeof(query), "UPDATE DoorGates SET Enabled = '%d', ModelID = '%d', Type = '%d', ClosePosX = '%f', ClosePosY = '%f', ClosePosZ = '%f', CloseRotX = '%f', CloseRotY = '%f', CloseRotZ = '%f'", \
	DoorGates[id][Enabled], DoorGates[id][ModelID], DoorGates[id][Type], DoorGates[id][ClosePos][0], DoorGates[id][ClosePos][1], DoorGates[id][ClosePos][2], DoorGates[id][CloseRot][0], DoorGates[id][CloseRot][1], DoorGates[id][CloseRot][2]);
	
	mysql_format(MYSQL_MAIN, query, sizeof(query), "%s, OpenPosX = '%f', OpenPosY = '%f', OpenPosZ = '%f', OpenRotX = '%f', OpenRotY = '%f', OpenRotZ = '%f'", \
	query, DoorGates[id][OpenPos][0], DoorGates[id][OpenPos][1], DoorGates[id][OpenPos][2], DoorGates[id][OpenRot][0], DoorGates[id][OpenRot][1], DoorGates[id][OpenRot][2]);
	
	mysql_format(MYSQL_MAIN, query, sizeof(query), "%s, InteriorID = '%d', VW = '%d', BizLink = '%d', UseVIPKey = '%d', GroupLink = '%d', GangLink = '%d', GroupRank = '%d', HouseLink = '%d', UseKpp = '%d', VIPLevel = '%d'",\
	query, DoorGates[id][InteriorID], DoorGates[id][dVW], DoorGates[id][BizLink], DoorGates[id][UseVIPKey], DoorGates[id][GroupLink], DoorGates[id][GangLink], DoorGates[id][GroupRank], DoorGates[id][HouseLink], DoorGates[id][UseKpp], DoorGates[id][VIPLevel]);
	
	mysql_format(MYSQL_MAIN, query, sizeof(query), "%s, DoorGateLink = '%d', AutoClose = '%d', OwnerOnly = '%d', JobLink = '%d', dRange = '%f', Speed = '%f', TollPrice = '%d' WHERE SQLID = '%d'", \
	query, DoorGates[id][DoorGateLink], DoorGates[id][AutoClose], DoorGates[id][OwnerOnly], DoorGates[id][JobLink], DoorGates[id][dRange], DoorGates[id][dSpeed], DoorGates[id][TollPrice], DoorGates[id][SQLID]);
	
	mysql_query(MYSQL_MAIN, query, false);
	return 1;
}

stock LoadDoorGates()
{
	new Cache:cache = mysql_query(MYSQL_MAIN, "SELECT * FROM DoorGates");
	new count = cache_get_row_count(), row, id = 1;
	while(row < count)
	{
		if(cache_get_field_content_int(row, "Deleted") == 1)
		{
			row ++;
			continue;
		}
		
		DoorGates[id][Enabled] = cache_get_field_content_int(row, "Enabled");
		DoorGates[id][ModelID] = cache_get_field_content_int(row, "ModelID");
		DoorGates[id][Type] = cache_get_field_content_int(row, "Type");
		DoorGates[id][ClosePos][0] = cache_get_field_content_float(row, "ClosePosX");
		DoorGates[id][ClosePos][1] = cache_get_field_content_float(row, "ClosePosY");
		DoorGates[id][ClosePos][2] = cache_get_field_content_float(row, "ClosePosZ");
		DoorGates[id][CloseRot][0] = cache_get_field_content_float(row, "CloseRotX");
		DoorGates[id][CloseRot][1] = cache_get_field_content_float(row, "CloseRotY");
		DoorGates[id][CloseRot][2] = cache_get_field_content_float(row, "CloseRotZ");
		DoorGates[id][OpenPos][0] = cache_get_field_content_float(row, "OpenPosX");
		DoorGates[id][OpenPos][1] = cache_get_field_content_float(row, "OpenPosY");
		DoorGates[id][OpenPos][2] = cache_get_field_content_float(row, "OpenPosZ");
		DoorGates[id][OpenRot][0] = cache_get_field_content_float(row, "OpenRotX");
		DoorGates[id][OpenRot][1] = cache_get_field_content_float(row, "OpenRotY");
		DoorGates[id][OpenRot][2] = cache_get_field_content_float(row, "OpenRotZ");
		DoorGates[id][InteriorID] = cache_get_field_content_int(row, "InteriorID");
		DoorGates[id][dVW] = cache_get_field_content_int(row, "VW");
		DoorGates[id][BizLink] = cache_get_field_content_int(row, "BizLink");
		DoorGates[id][UseVIPKey] = cache_get_field_content_int(row, "UseVIPKey");
		DoorGates[id][GroupLink] = cache_get_field_content_int(row, "GroupLink");
		DoorGates[id][GangLink] = cache_get_field_content_int(row, "GangLink");
		DoorGates[id][GroupRank] = cache_get_field_content_int(row, "GroupRank");
		DoorGates[id][HouseLink] = cache_get_field_content_int(row, "HouseLink");
		DoorGates[id][UseKpp] = cache_get_field_content_int(row, "UseKpp");
		DoorGates[id][VIPLevel] = cache_get_field_content_int(row, "VIPLevel");
		DoorGates[id][DoorGateLink] = cache_get_field_content_int(row, "DoorGateLink");
		DoorGates[id][AutoClose] = cache_get_field_content_int(row, "AutoClose");
		DoorGates[id][OwnerOnly] = cache_get_field_content_int(row, "OwnerOnly");
		DoorGates[id][SQLID] = cache_get_field_content_int(row, "SQLID");
		DoorGates[id][JobLink] = cache_get_field_content_int(row, "JobLink");
		DoorGates[id][dRange] = cache_get_field_content_float(row, "dRange");
		DoorGates[id][dSpeed] = cache_get_field_content_float(row, "Speed");
		DoorGates[id][TollPrice] = cache_get_field_content_int(row, "TollPrice");
		cache_get_field_content(row, "CreatedBy", DoorGates[id][CreatedBy], 1, 25);
		
		if(DoorGates[id][Type] == GATE_TYPE_TOLL)
		{
			new str[128];
			format(str, sizeof(str), "Toll Booth (Cost: $%d)\n(( /paytoll ))", DoorGates[id][TollPrice]);
			DoorGates[id][TollLabel] = CreateDynamic3DTextLabel(str, GREEN, DoorGates[id][ClosePos][0], DoorGates[id][ClosePos][1], DoorGates[id][ClosePos][2], 10, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, DoorGates[id][dVW], -1, -1, 100);
		}
		Iter_Add(DoorGate, id);
		UpdateDoorGateObject(id);
		
		id ++;
		row ++;
	}
	
	cache_delete(cache);
	printf("Loaded %d doors and gates. (out of %d rows)", row, count);
	return 1;
}