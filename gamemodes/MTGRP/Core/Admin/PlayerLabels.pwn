/*
#		MTG Player Labels
#		
#
#	By accessing this file, you agree to the following:
#		- You will never give the script or associated files to anybody who is not on the MTG SAMP development team
# 		- You will delete all development materials (script, databases, associated files, etc.) when you leave the MTG SAMP development team.
#
*/

#define PLAYER_LABEL_COLOR				0x20B2AAFF

static Text3D:PlayerLabel[MAX_PLAYERS], string[512];

CMD:pl(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 2)
		return 1;
		
	switch(GetPVarInt(playerid, "PLAYER_LABELS_TOGGLE"))
	{
		case 0:
		{
			SetPVarInt(playerid, "PLAYER_LABELS_TOGGLE", 1);
			foreach(Player, i)
				Streamer_AppendArrayData(STREAMER_TYPE_3D_TEXT_LABEL, PlayerLabel[i], E_STREAMER_PLAYER_ID, playerid);
			SendClientMessage(playerid, WHITE, "You can now see player labels.");
		}
		case 1:
		{
			DeletePVar(playerid, "PLAYER_LABELS_TOGGLE");
			foreach(Player, i)
				Streamer_RemoveArrayData(STREAMER_TYPE_3D_TEXT_LABEL, PlayerLabel[i], E_STREAMER_PLAYER_ID, playerid);
			SendClientMessage(playerid, WHITE, "You can no longer see player labels.");
		}
	}
	return 1;
}

ptask UpdatePlayerLabels[1000](playerid)
{
	foreach(Player, i)
	{
		if(GetPVarInt(i, "PLAYER_LABELS_TOGGLE") == 1)
		{
			UpdatePlayersLabel(playerid);
			break;
		}
	}
	return 1;
}

static stock UpdatePlayersLabel(playerid)
{
	new Float:health, Float:armour, Float:pPos[3];
	GetPlayerHealth(playerid, health);
	GetPlayerArmour(playerid, armour);
	GetPlayerPos(playerid, pPos[0], pPos[1], pPos[2]);
	
	format(string, sizeof(string), "[id: %d, Health: %.2f, Armour: %.2f, Ping: %d]\n", playerid, health, armour, GetPlayerPing(playerid));
	format(string, sizeof(string), "%sHours: %d, Skin: %d (%s), Money: %s, Weapon: %d (%s)\n", string, Player[playerid][PlayingHours], GetPlayerSkin(playerid), (GetPlayerSkin(playerid) == Player[playerid][LastSkin]) ? ("Valid") : ("Invalid"), PrettyMoney(Player[playerid][Money]), GetPlayerWeapon(playerid), (PlayerHasWeapon(playerid, GetPlayerWeapon(playerid)) ? ("Valid") : ("Invalid")));
	format(string, sizeof(string), "%sInt: %d, VW: %d, Pos: %.3f, %.3f, %.3f", string, GetPlayerInterior(playerid), GetPlayerVirtualWorld(playerid), pPos[0], pPos[1], pPos[2]);
	
	if(IsValidDynamic3DTextLabel(PlayerLabel[playerid]))
	{
		UpdateDynamic3DTextLabelText(PlayerLabel[playerid], PLAYER_LABEL_COLOR, string);
		Streamer_SetIntData(STREAMER_TYPE_3D_TEXT_LABEL, PlayerLabel[playerid], E_STREAMER_WORLD_ID, GetPlayerVirtualWorld(playerid));
		Streamer_SetIntData(STREAMER_TYPE_3D_TEXT_LABEL, PlayerLabel[playerid], E_STREAMER_INTERIOR_ID, GetPlayerInterior(playerid));
	}
	else
	{
		PlayerLabel[playerid] = CreateDynamic3DTextLabel(string, PLAYER_LABEL_COLOR, 0.0, 0.0, -0.5, 70, playerid, _, _, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), playerid, 100);
		format(string, sizeof(string), "PlayerLabel_%d", _:PlayerLabel[playerid]);
		SetSVarInt(string, 1);
		Streamer_RemoveArrayData(STREAMER_TYPE_3D_TEXT_LABEL, PlayerLabel[playerid], E_STREAMER_PLAYER_ID, playerid);
	}
	return 1;
}

hook OnPlayerConnect(playerid)
{
	UpdatePlayersLabel(playerid);
	return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	if(IsValidDynamic3DTextLabel(PlayerLabel[playerid]))
	{
		format(string, sizeof(string), "PlayerLabel_%d", _:PlayerLabel[playerid]);
		DeleteSVar(string);
		DestroyDynamic3DTextLabel(PlayerLabel[playerid]);
	}
	
	if(GetPVarInt(playerid, "PLAYER_LABELS_TOGGLE") == 1)
	{
		foreach(Player, i)
			Streamer_RemoveArrayData(STREAMER_TYPE_3D_TEXT_LABEL, PlayerLabel[i], E_STREAMER_PLAYER_ID, playerid);
	}
	
	return 1;
}