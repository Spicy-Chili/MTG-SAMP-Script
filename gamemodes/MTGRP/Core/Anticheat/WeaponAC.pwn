/*
#		MTG Weapon Anticheat
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

new WeaponsToDesync[] =
{
	WEAPON_GRENADE,
	WEAPON_MOLTOV,
	WEAPON_ROCKETLAUNCHER,
	WEAPON_SATCHEL,
	WEAPON_HEATSEEKER,
	WEAPON_FLAMETHROWER,
};

ptask AntiC[1000](i)
{
	if(Player[i][IsAtEvent] == 0 && IsPlayerSpawned(i) && Player[i][Tutorial] == 0 && GetPVarInt(i, "FRESH_SPAWNED_NEW_ACCOUNT") == 0)
	{
		if(GetPVarInt(i, "WEAPON_HACK_WARNING_COOLDOWN") > gettime())
			return 1;

		new w = GetPlayerWeapon(i);
		if(w == 0)
			return 1;

		if(!PlayerHasWeapon(i, w) && w != 38)
		{
			AdminWeaponWarning(i);
			ResetPlayerWeapons(i);
			GivePlayerSavedWeapons(i);
		}
		else if(!PlayerHasWeapon(i, w) && w == 38 || !PlayerHasWeapon(i, w) && w == 37 || !PlayerHasWeapon(i, w) && w == 36 || !PlayerHasWeapon(i, w) && w == 35)
		{
			AntiCheatBan(i);
		}
	}
	return 1;
}

// ============= Callback hooks =============

hook OnPlayerUpdate(playerid)
{
	if(!Player[playerid][AdminDuty] && Player[playerid][IsAtEvent] == 0)
	{
		new w = GetPlayerWeapon(playerid);
		if(w != 0)
		{
			for(new i; i < sizeof(WeaponsToDesync); i++)
			{
				if(WeaponsToDesync[i] == w)
					return 0;
			}
		}
	}
	return 1;
}

hook OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	switch(hitid)
	{
		case BULLET_HIT_TYPE_PLAYER:
		{
			if(Player[hitid][IsTabbed] > 2)
				return 0;

			if(!PlayerHasWeapon(playerid, weaponid) && Player[playerid][IsAtEvent] == 0)
			{
				return 0;
			}
		}
	}
	return 1;
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if((newstate == PLAYER_STATE_DRIVER && oldstate == PLAYER_STATE_ONFOOT) || (newstate == PLAYER_STATE_PASSENGER && oldstate == PLAYER_STATE_ONFOOT))
	{
		new modelid = GetVehicleModel(GetPlayerVehicleID(playerid));

		if(modelid == 598)
		{
			Player[playerid][GotInCopCar]++;
			ResetPlayerWeapons(playerid);
			GivePlayerSavedWeapons(playerid);
		}

		if(IsAHelicopter(GetPlayerVehicleID(playerid)))
		{
			SetPVarInt(playerid, "GotInHeli", GetPVarInt(playerid, "GotInHeli") + 1);
			ResetPlayerWeapons(playerid);
			GivePlayerSavedWeapons(playerid);
		}

	}

	if((newstate == PLAYER_STATE_ONFOOT && oldstate == PLAYER_STATE_DRIVER) || (newstate == PLAYER_STATE_ONFOOT && oldstate == PLAYER_STATE_PASSENGER))
	{
		if(Player[playerid][GotInCopCar] >= 1)
		{
			ResetPlayerWeapons(playerid);
			GivePlayerSavedWeapons(playerid);
			Player[playerid][GotInCopCar] = 0;
		}

		if(GetPVarInt(playerid, "GotInHeli") >= 1)
		{
			ResetPlayerWeapons(playerid);
			GivePlayerSavedWeapons(playerid);
			DeletePVar(playerid, "GotInHeli");
		}
	}
}
/*
hook OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid)
{
	new statex = GetPlayerState(issuerid), w = GetPlayerWeapon(issuerid);

	if(weaponid == WEAPON_VEHICLE)
		return 1;

	if(statex == PLAYER_STATE_DRIVER || statex == PLAYER_STATE_PASSENGER)
	{
		if(w == 0 || !PlayerHasWeapon(issuerid, weaponid))
		{
			AdminWeaponWarning(issuerid, weaponid);
			ResetPlayerWeapons(issuerid);
			GivePlayerSavedWeapons(issuerid);

			new Float:h, Float:a;
			GetPlayerHealth(playerid, h);
			GetPlayerArmour(playerid, a);
			SetPlayerHealth(playerid, h);
			SetPlayerArmour(playerid, a);
		}
	}
	return 1;
}*/

// ============= Stocks =============

stock AdjustWeapon(playerid, weapon, value)
{
	switch(weapon)
	{
		case 0, 1:
		{
			Player[playerid][WepSlot0] = value;
		}
		case 2, 3, 4, 5, 6, 7, 8, 9:
		{
			Player[playerid][WepSlot1] = value;
		}
		case 22, 23, 24:
		{
			Player[playerid][WepSlot2] = value;
		}
		case 25, 26, 27:
		{
			Player[playerid][WepSlot3] = value;
		}
		case 28, 29, 32:
		{
			Player[playerid][WepSlot4] = value;
		}
		case 30, 31:
		{
			Player[playerid][WepSlot5] = value;
		}
		case 33, 34:
		{
			Player[playerid][WepSlot6] = value;
		}
		case 35, 36, 37, 38:
		{
			Player[playerid][WepSlot7] = value;
		}
		case 16, 17, 18, 39:
		{
			Player[playerid][WepSlot8] = value;
		}
		case 41, 42, 43:
		{
			Player[playerid][WepSlot9] = value;
		}
		case 10, 11, 12, 13, 14, 15:
		{
			Player[playerid][WepSlot10] = value;
		}
		case 44, 45, 46:
		{
			Player[playerid][WepSlot11] = value;
		}
	}

	SetPVarInt(playerid, "WEAPON_HACK_WARNING_COOLDOWN", gettime() + 3);
	DetachWeaponFromPlayer(playerid, weapon);
	ResetPlayerWeapons(playerid);
	GivePlayerSavedWeapons(playerid);
	return 1;
}

stock PlayerHasWeaponInSlot(playerid, slot)
{
	switch(slot)
	{
		case 0: if(Player[playerid][WepSlot0] != 0) return 1;
		case 1: if(Player[playerid][WepSlot1] != 0) return 1;
		case 2: if(Player[playerid][WepSlot2] != 0) return 1;
		case 3: if(Player[playerid][WepSlot3] != 0) return 1;
		case 4: if(Player[playerid][WepSlot4] != 0) return 1;
		case 5: if(Player[playerid][WepSlot5] != 0) return 1;
		case 6: if(Player[playerid][WepSlot6] != 0) return 1;
		case 7: if(Player[playerid][WepSlot7] != 0) return 1;
		case 8: if(Player[playerid][WepSlot8] != 0) return 1;
		case 9: if(Player[playerid][WepSlot9] != 0) return 1;
		case 10: if(Player[playerid][WepSlot10] != 0) return 1;
		case 11: if(Player[playerid][WepSlot11] != 0) return 1;
	}
	return 0;
}

stock PlayerHasWeapon(playerid, weapon)
{
	if(weapon == 0)
		return 1;

	switch(weapon)
	{
		case 1:
		{
			if(Player[playerid][WepSlot0] == weapon)
				return 1;
		}
		case 2, 3, 4, 5, 6, 7, 8, 9:
		{
			if(Player[playerid][WepSlot1] == weapon)
				return 1;
		}
		case 22, 23, 24:
		{
			if(Player[playerid][WepSlot2] == weapon)
				return 1;
		}
		case 25, 26, 27:
		{
			if(Player[playerid][WepSlot3] == weapon)
				return 1;
		}
		case 28, 29, 32:
		{
			if(Player[playerid][WepSlot4] == weapon)
				return 1;
		}
		case 30, 31:
		{
			if(Player[playerid][WepSlot5] == weapon)
				return 1;
		}
		case 33, 34:
		{
			if(Player[playerid][WepSlot6] == weapon)
				return 1;
		}
		case 35, 36, 37, 38:
		{
			if(Player[playerid][WepSlot7] == weapon)
				return 1;
		}
		case 16, 17, 18, 39:
		{
			if(Player[playerid][WepSlot8] == weapon)
				return 1;
		}
		case 41, 42, 43:
		{
			if(Player[playerid][WepSlot9] == weapon)
				return 1;
		}
		case 10, 11, 12, 13, 14, 15:
		{
			if(Player[playerid][WepSlot10] == weapon)
				return 1;
		}
		case 44, 45, 46:
		{
			if(Player[playerid][WepSlot11] == weapon)
				return 1;
		}
	}
	return 0;
}
