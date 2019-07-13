/*
#		MTG Animation System
#		
#
#	By accessing this file, you agree to the following:
#		- You will never give the script or associated files to anybody who is not on the MTG SAMP development team
# 		- You will delete all development materials (script, databases, associated files, etc.) when you leave the MTG SAMP development team.
#
#
#
*/

// #include "MTGRP\Core\mtg_extra.pwn"

#include <YSI\y_hooks>
#include <a_samp>
#include <sscanf2>
#include <zcmd>

#define MAX_ANIMATIONS 250
#define ANIM_FILE "Animations.list"
#define REQADMINLEVEL 4

new Text: AnimationTextDraw;

enum AnimData
{
	AnimCommand[64],
	AnimId,
	AnimLib[64],
	AnimName[64],
	AnimLoop,
	AnimLockX,
	AnimLockY,
	AnimFreeze,
	AnimAnimationValue
}
new Animations[MAX_ANIMATIONS][AnimData];

new animation_library[][] = 
{
	"AIRPORT", "Attractors", "BAR", "BASEBALL", "BD_FIRE", "BEACH", "benchpress", "BF_injection", "BIKED", "BIKEH", "BIKELEAP", "BIKES", "BIKEV",
	"BIKE_DBZ", "BLOWJOBZ", "BMX", "BOMBER", "BOX", "BSKTBALL", "BUDDY", "BUS", "CAMERA", "CAR", "CARRY", "CAR_CHAT", "CASINO", "CHAINSAW", "CHOPPA",
	"CLOTHES", "COACH", "COLT45", "COP_AMBIENT", "COP_DVBYZ", "CRACK", "CRIB", "DAM_JUMP", "DANCING", "DEALER", "DILDO", "DODGE", "DOZER", "DRIVEBYS",
	"FAT", "FIGHT_B", "FIGHT_C", "FIGHT_D", "FIGHT_E", "FINALE", "FINALE2", "FLAME", "Flowers", "FOOD", "Freeweights", "GANGS", "GHANDS", "GHETTO_DB",
	"goggles", "GRAFFITI", "GRAVEYARD", "GRENADE", "GYMNASIUM", "HAIRCUTS", "HEIST9", "INT_HOUSE", "INT_OFFICE", "INT_SHOP", "JST_BUISNESS", "KART",
	"KISSING", "KNIFE", "LAPDAN1", "LAPDAN2", "LAPDAN3", "LOWRIDER", "MD_CHASE", "MD_END", "MEDIC", "MISC", "MTB", "MUSCULAR", "NEVADA", "ON_LOOKERS",
	"OTB", "PARACHUTE", "PARK", "PAULNMAC", "ped", "PLAYER_DVBYS", "PLAYIDLES", "POLICE", "POOL", "POOR", "PYTHON", "QUAD", "QUAD_DBZ", "RAPPING",
	"RIFLE", "RIOT", "ROB_BANK", "ROCKET", "RUSTLER", "RYDER", "SCRATCHING", "SHAMAL", "SHOP", "SHOTGUN", "SILENCED", "SKATE", "SMOKING", "SNIPER",
	"SPRAYCAN", "STRIP", "SUNBATHE", "SWAT", "SWEET", "SWIM", "SWORD", "TANK", "TATTOOS", "TEC", "TRAIN", "TRUCK", "UZI", "VAN", "VENDING", "VORTEX",
	"WAYFARER", "WEAPONS", "WUZI", "SNM"
};

stock IsANumber(string[])
{
	for (new i = 0, j = strlen(string); i < j; i++)
		if (string[i] > '9' || string[i] < '0')
			return 0;
	return 1;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
	if(success) return 1;
	
	new command[128], val, spacefound;
	
	strdel(cmdtext, 0, 1);
	format(command, sizeof(command), cmdtext);
	
	for(new i; i < MAX_ANIMATIONS; i++)
	{
		for(new s; s < strlen(cmdtext); s++)
		{
			if(cmdtext[s] == ' ' && !spacefound)
			{
				command[s] = '\0';
				strdel(cmdtext, 0, s + 1);
				if(IsANumber(cmdtext))
					val = strval(cmdtext);
				
				spacefound = 1;
			}
		}
		
		if(spacefound == 0)
			format(command, 128, cmdtext);
		
		new count;
		for(new x; x < MAX_ANIMATIONS; x++)
		{
			if(!strcmp(command, Animations[x][AnimCommand], true) && !isnull(command) && !isnull(Animations[x][AnimCommand]))
			{
				count++;
			}
		}
		
		if(count == 0)
			return 1;
		
		if((val == 0 && count > 1) || (val > CountAnims(command) && count != 1))
		{
			new string[128];
			format(string, sizeof(string), "SYNTAX: /%s 1 - %d", command, count);
			return SendClientMessage(playerid, GREY, string);
		}
		
		if(val == 0)
			val = 1;
		
		if(!strcmp(command, Animations[i][AnimCommand], true) && val == Animations[i][AnimId])
		{
			if(CantUseRightNow(playerid))
				return SendClientMessage(playerid, -1, "You can't use this animation as you're cuffed, tazed, tied or dying");

			if(Player[playerid][IsAtEvent] >= 1)
				return SendClientMessage(playerid, WHITE, "You're unable to do that at this time.");

			if(GetPlayerSpeed(playerid, 0) != 0)
				return SendClientMessage(playerid, -1, "You must be standing still to do this.");

			if(GetPlayerVehicleID(playerid) != 0)
				return SendClientMessage(playerid, -1, "You cannot do this animation while in a vehicle.");

			if(GetPlayerState(playerid) != 1)
				return SendClientMessage(playerid, -1, "You have to be on foot to do this animation!");
				
			ApplyAnimationEx(playerid, Animations[i][AnimLib], Animations[i][AnimName], 4.1, Animations[i][AnimLoop], Animations[i][AnimLockX], Animations[i][AnimLockY], Animations[i][AnimFreeze], 1, 1);
			Player[playerid][IsInAnimation] = Animations[i][AnimAnimationValue];
			return 1;
		}
	}
	return 1;
}

hook OnGameModeInit()
{
	// Animation
	AnimationTextDraw = TextDrawCreate(610.0, 400.0, "~r~~k~~PED_SPRINT~ ~w~ to stop the animation.");
	TextDrawUseBox(AnimationTextDraw, 0);
	TextDrawFont(AnimationTextDraw, 2);
	TextDrawSetShadow(AnimationTextDraw, 0);
	TextDrawSetOutline(AnimationTextDraw, 1);
	TextDrawBackgroundColor(AnimationTextDraw, 0x000000FF);
	TextDrawColor(AnimationTextDraw, 0xFFFFFFFF);
	TextDrawAlignment(AnimationTextDraw, 3);
	
	for(new i; i < MAX_ANIMATIONS; i++)
	{
		format(Animations[i][AnimCommand], 64, "NOT_A_COMMAND");
	}
	
	LoadAnimations();

	return 1;
}

stock CountAnims(anim[])
{
	new count;
	for(new i; i < MAX_ANIMATIONS; i++)
		if(!strcmp(anim, Animations[i][AnimCommand], true))
			count++;
	
	return count;
}

stock SaveAnimations()
{
	fremove(ANIM_FILE);
	new File:AnimFile = fopen(ANIM_FILE, io_readwrite), string[128];
	for(new i; i < MAX_ANIMATIONS; i++)
	{
		if(strcmp(Animations[i][AnimCommand], "NOT_A_COMMAND", true))
		{
			format(string, sizeof(string), "%s %d %s %s %d %d %d %d %d\n", Animations[i][AnimCommand], Animations[i][AnimId], Animations[i][AnimLib], Animations[i][AnimName], Animations[i][AnimLoop], Animations[i][AnimLockX], Animations[i][AnimLockY], Animations[i][AnimFreeze], Animations[i][AnimAnimationValue]);
			fwrite(AnimFile, string);
		}
	}
	fclose(AnimFile);
	return 1;
}

stock LoadAnimations()
{	
	new File:AnimFile = fopen(ANIM_FILE, io_readwrite), string[128], i;
	while(fread(AnimFile, string))
	{
		if(i >= MAX_ANIMATIONS)
			break;
			
		sscanf(string, "s[64]ds[64]s[64]ddddd", Animations[i][AnimCommand], Animations[i][AnimId], Animations[i][AnimLib], Animations[i][AnimName], Animations[i][AnimLoop], Animations[i][AnimLockX], Animations[i][AnimLockY], Animations[i][AnimFreeze], Animations[i][AnimAnimationValue]);
			
		i++;
	}
	fclose(AnimFile);
	print("[system] Animations have been loaded.");
}

stock ReloadAnimations()
{
	for(new i; i < MAX_ANIMATIONS; i++)
	{
		for(new x; x < sizeof(Animations); x++)
		{
			Animations[i][AnimData:x] = 0;
		}
			
		format(Animations[i][AnimCommand], 64, "NOT_A_COMMAND");
	}

	new File:AnimFile = fopen(ANIM_FILE, io_readwrite), string[128], i;
	while(fread(AnimFile, string))
	{
		if(i >= MAX_ANIMATIONS)
			break;
			
		sscanf(string, "s[64]ds[128]s[128]ddddd", Animations[i][AnimCommand], Animations[i][AnimId], Animations[i][AnimLib], Animations[i][AnimName], Animations[i][AnimLoop], Animations[i][AnimLockX], Animations[i][AnimLockY], Animations[i][AnimFreeze], Animations[i][AnimAnimationValue]);
			
		i++;
	}
	fclose(AnimFile);
	return print("[system] Animations have been reloaded.");
}

stock FreeAnimSlot()
{
	new id = -1;
	for(new i; i < MAX_ANIMATIONS; i++)
	{
		if(strcmp(Animations[i][AnimCommand], "NOT_A_COMMAND", true))
			continue;
			
		id = i;
	}
	return id;
}

CMD:addanim(playerid, params[])
{
	if(Player[playerid][AdminLevel] < REQADMINLEVEL)
		return 1;
		
	new cmd[64], animlib[64], animname[64], loop, lockx, locky, freeze, confirm[8], value = 1;
	if(sscanf(params, "s[64]s[64]s[64]ddddS(ddd)[8]D(1)", cmd, animlib, animname, loop, lockx, locky, freeze, confirm, value))
		return SendClientMessage(playerid, GREY, "SYNTAX: /addanim [command] [animlib] [animname] [loop] [lockx] [locky] [freeze]");
		
	if(loop != 0 && loop != 1)
		return SendClientMessage(playerid, -1, "Loop must be 0 or 1.");
		
	if(lockx != 0 && lockx != 1)
		return SendClientMessage(playerid, -1, "Lockx must be 0 or 1.");
		
	if(locky != 0 && locky != 1)
		return SendClientMessage(playerid, -1, "Locky must be 0 or 1.");
		
	if(freeze != 0 && freeze != 1)
		return SendClientMessage(playerid, -1, "Freeze must be 0 or 1.");
		
	new string[128];
	if(!strcmp(confirm, "confirm", true))
	{
		new idx = FreeAnimSlot(), good_anim;
		if(idx == -1)
			return SendClientMessage(playerid, -1, "There are no more available slots for a new animation.");
			
		for(new i; i < sizeof(animation_library); i++)
		{
			if(!strcmp(animlib, animation_library[i], true))
			{
				good_anim = 1;
			}
		}
		
		if(!good_anim)
			return SendClientMessage(playerid, -1, "Invalid animlib (Find them at http://wiki.sa-mp.com/wiki/Animations)");
		
		for(new i; i < MAX_ANIMATIONS; i++)
		{
			if(isnull(Animations[i][AnimLib]) || isnull(Animations[i][AnimName]))
				continue;
			
			if(!strcmp(animlib, Animations[i][AnimLib], true) && !strcmp(animname, Animations[i][AnimName], true))
			{
				format(string, sizeof(string), "That animation already exists with \"/%s %d\".", Animations[i][AnimCommand], Animations[i][AnimId]);
				return SendClientMessage(playerid, -1, string);
			}
		}
		
		new id = 1;
		for(new i; i < MAX_ANIMATIONS; i++)
		{
			if(isnull(cmd) || isnull(Animations[i][AnimCommand]))
				continue;
		
			if(!strcmp(Animations[i][AnimCommand], cmd, true))
				id++;
		}
		
		format(Animations[idx][AnimCommand], 64, cmd);
		format(Animations[idx][AnimLib], 64, animlib);
		format(Animations[idx][AnimName], 64, animname);
		Animations[idx][AnimLoop] = loop;
		Animations[idx][AnimId] = id;
		Animations[idx][AnimLockX] = lockx;
		Animations[idx][AnimLockY] = locky;
		Animations[idx][AnimFreeze] = freeze;
		Animations[idx][AnimAnimationValue] = value;
		
		SaveAnimations();

		new count;
		for(new i; i < MAX_ANIMATIONS; i++)
		{
			if(i == idx)
				continue;
				
			if(!strcmp(cmd, Animations[i][AnimCommand], true))
				count++;
		}
		
		if(id == 1 && count == 0)
		{
			format(string, sizeof(string), "You have added a new animation! Use \"/%s\".", cmd);
			SendClientMessage(playerid, -1, string);
			format(string, sizeof(string), "%s has added a new animation! Use \"/%s\".", GetName(playerid), cmd);
			SendToAdmins(ADMINORANGE, string, 1);
			format(string, sizeof(string), "%s has added a new animation! \"/%s\". (params = %s)", GetName(playerid), cmd, params);
			AdminActionsLog(string);
		}
		else
		{
			format(string, sizeof(string), "You have added a new animation! Use \"/%s %d\".", cmd, id);
			SendClientMessage(playerid, -1, string);
			format(string, sizeof(string), "%s has added a new animation! Use \"/%s %d\".", GetName(playerid), cmd, id);
			SendToAdmins(ADMINORANGE, string, 1);
			format(string, sizeof(string), "%s has added a new animation! \"/%s %d\". (params = %s)", GetName(playerid), cmd, id, params);
			AdminActionsLog(string);
		}
		
		ReloadAnimations();
	}
	else
	{
		new good_anim;
		for(new i; i < sizeof(animation_library); i++)
		{
			if(!strcmp(animlib, animation_library[i], true))
			{
				good_anim = 1;
			}
		}
		
		if(good_anim)
			ApplyAnimationEx(playerid, animlib, animname, 4.1, loop, lockx, locky, freeze, 1, 1);
	
		format(string, sizeof(string), "Are you sure? Please type \"/addanim %s confirm\" to confirm the addition of the animation.", params);
		return SendClientMessage(playerid, YELLOW, string);
	}	
	return 1;
}

CMD:removeanim(playerid, params[])
{
	if(Player[playerid][AdminLevel] < REQADMINLEVEL)
		return 1;
		
	new command[128], cmdid;
	
	if(sscanf(params, "s[128]D(0)", command, cmdid))
		return SendClientMessage(playerid, GREY, "SYNTAX: /removeanim [command] ([command id])");
	
	new count, string[128];
	if(cmdid == 0)
	{
		for(new i; i < MAX_ANIMATIONS; i++)
		{
			if(!strcmp(Animations[i][AnimCommand], command, true))
				count++;
		}
		
		if(count == 0)
			return SendClientMessage(playerid, -1, "There is no such animation.");
	}
	
	if(count == 1)
		cmdid = 1;
	else if(count > 1 && cmdid == 0)
	{
		format(string, sizeof(string), "Please specify which command you want to delete. (/%s 1 - %d)", command, count);
		return SendClientMessage(playerid, -1, string);
	}
	
	new deleted;
	for(new i; i < MAX_ANIMATIONS; i++)
	{
		if(isnull(command) || isnull(Animations[i][AnimCommand]))
			continue;
	
		if(!strcmp(Animations[i][AnimCommand], command, true) && cmdid == Animations[i][AnimId])
		{
			format(Animations[i][AnimCommand], 128, "NOT_A_COMMAND");
			Animations[i][AnimLib] = 0;
			Animations[i][AnimName] = 0;
			Animations[i][AnimLoop] = 0;
			Animations[i][AnimId] = 0;
			Animations[i][AnimLockX] = 0;
			Animations[i][AnimLockY] = 0;
			Animations[i][AnimFreeze] = 0;
			Animations[i][AnimAnimationValue] = 0;
			
			SaveAnimations();
			ReloadAnimations();
			deleted = 1;
			break;
		}
	}
	
	if(deleted == 0)
		return SendClientMessage(playerid, -1, "There is no such animation.");
	
	new id = cmdid + 1, moreanims;
	for(new i; i < MAX_ANIMATIONS; i++)
	{
		if(isnull(command) || isnull(Animations[i][AnimCommand]))
			continue;
			
		if(!strcmp(Animations[i][AnimCommand], command, true) && id == Animations[i][AnimId])
		{
			Animations[i][AnimId]--;
			id++;
			moreanims = 1;
		}
	}
	
	SaveAnimations();
	
	if(moreanims)
	{
		format(string, sizeof(string), "You have deleted the animation \"/%s %d\".", command, cmdid);
		SendClientMessage(playerid, -1, string);
		format(string, sizeof(string), "%s has deleted the animation \"/%s %d\".", GetName(playerid), command, cmdid);
		SendToAdmins(ADMINORANGE, string, 1);
		AdminActionsLog(string);
	}
	else
	{
		format(string, sizeof(string), "You have deleted the animation \"/%s\".", command);
		SendClientMessage(playerid, -1, string);
		format(string, sizeof(string), "%s has deleted the animation \"/%s\".", GetName(playerid), command);
		SendToAdmins(ADMINORANGE, string, 1);
		AdminActionsLog(string);
	}
		
	return 1;
}

CMD:editanim(playerid, params[])
{
	if(Player[playerid][AdminLevel] < REQADMINLEVEL)
		return 1;
		
	new cmd[64], cmdid, loop, lockx, locky, freeze;
	if(sscanf(params, "s[64]ddddd", cmd, cmdid, loop, lockx, locky, freeze))
		return SendClientMessage(playerid, GREY, "SYNTAX: /editanim [command] [commandid] [loop] [lockx] [locky] [freeze]");
		
	for(new i; i < MAX_ANIMATIONS; i++)
	{
		if(!strcmp(cmd, Animations[i][AnimCommand], true) && cmdid == Animations[i][AnimId])
		{
			Animations[i][AnimLoop] = loop;
			Animations[i][AnimLockX] = lockx;
			Animations[i][AnimLockY] = locky;
			Animations[i][AnimFreeze] = freeze;
			
			new string[128];
			format(string, sizeof(string), "You have editted the \"%s %d\" command.", cmd, cmdid);
			SendClientMessage(playerid, -1, string);
			
			SaveAnimations();
			
			return 1;
		}
	}
		
	return 1;
}

CMD:reloadanimations(playerid)
{
	if(Player[playerid][AdminLevel] < REQADMINLEVEL)
		return 1;
		
	return ReloadAnimations();
}

stock CantUseRightNow(playerid) // Checks if frozen, cuffed, tied, tazed, bleeding and sleeping
{
	if(Player[playerid][AdminFrozen] > 0 || Player[playerid][Tied] > 0 || Player[playerid][Cuffed] > 0 || Player[playerid][Tazed] > 0 || GetPVarInt(playerid, "BleedingOutTime") > 0 || Player[playerid][PassedOut] > 0 || Player[playerid][IsSleeping] > 0)

		return 1;

	return 0;
}

stock ApplyAnimationEx(playerid, animlib[], animname[], Float:fS, opt1, opt2, opt3, opt4, opt5, forcesync = 0)
{
	if(IsPlayerInAnyVehicle(playerid))
	{
		SendClientMessage(playerid, WHITE, "You can't use animations whilst in a vehicle.");
	}
	else
	{
		if(opt1 == 1)
		{
			if(Player[playerid][PlayingHours] < 100 && GetPlayerToggle(playerid, TOGGLE_ANIMATION_TEXT) == false)
				TextDrawShowForPlayer(playerid, AnimationTextDraw);
			Player[playerid][IsInAnimation] = 1;
			ApplyAnimation(playerid, animlib, animname, fS, opt1, opt2, opt3, opt4, opt5, forcesync);
		}
		else
		{
			ApplyAnimation(playerid, animlib, animname, fS, opt1, opt2, opt3, opt4, opt5, forcesync);
		}
	}
	return 1;
}

StopLoopingAnimation(playerid)
{
	ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0, 1);
}

PreloadAnimLib(playerid, animlib[])
{
	ApplyAnimation(playerid,animlib,"null", 0.0, 0, 0, 0, 0, 0, 1);
}

CMD:testanim(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 2)
		return 1;
	
	new anim[2][128], loop;
	if(sscanf(params, "s[128]s[128]D(0)", anim[0], anim[1], loop))
		return SendClientMessage(playerid, GREY, "SYNTAX: /testanim [animlib] [animname] ([loop])");
	
	new good_anim;
	for(new i; i < sizeof(animation_library); i++)
	{
		
		
		if(!strcmp(anim[0], animation_library[i], true))
		{
			good_anim = 1;
		}
	}
	
	if(!good_anim)
		return SendClientMessage(playerid, -1, "Invalid animlib."); //Won't crash the player.
	
	if(loop < 0 || loop > 1)
		return SendClientMessage(playerid, -1, "LOOP MUST BE 0 OR 1!!!");
	
	Player[playerid][IsInAnimation] = 1;
	ApplyAnimation(playerid, anim[0], anim[1], 3.1, loop, 1, 1, 1, 1, 1);
	return 1;
}

CMD:dance(playerid, params[])
{
	if(CantUseRightNow(playerid))
	    return SendClientMessage(playerid, -1, "You can't use this animation as you're cuffed, tazed, tied or dying");

	if(Player[playerid][IsAtEvent] >= 1)
		return SendClientMessage(playerid, WHITE, "You're unable to do that at this time.");

	if(GetPlayerSpeed(playerid, 0) != 0)
		return SendClientMessage(playerid, -1, "You must be standing still to do this.");

	if(GetPlayerVehicleID(playerid) != 0)
		return SendClientMessage(playerid, -1, "You cannot do this animation while in a vehicle.");

	if(GetPlayerState(playerid) != 1)
	    return SendClientMessage(playerid, -1, "You have to be on foot to do this animation!");

	Player[playerid][IsInAnimation] = 1;
	if(Player[playerid][PlayingHours] < 100 && GetPlayerToggle(playerid, TOGGLE_ANIMATION_TEXT) == false)
		TextDrawShowForPlayer(playerid, AnimationTextDraw);
		
	new id = strval(params);
	switch(id)
	{
		case 1: SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DANCE1);
		case 2: SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DANCE2);
		case 3: SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DANCE3);
		case 4: SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DANCE4);
		default: SendClientMessage(playerid, COLOR_GREY, "SYNTAX: /dance [1 - 4]");
	}
	return 1;
}

CMD:handsup(playerid)
{
	if(CantUseRightNow(playerid))
	    return SendClientMessage(playerid, -1, "You can't use this animation as you're cuffed, tazed, tied or dying");

	if(Player[playerid][IsAtEvent] >= 1)
		return SendClientMessage(playerid, WHITE, "You're unable to do that at this time.");

	if(GetPlayerSpeed(playerid, 0) != 0)
		return SendClientMessage(playerid, -1, "You must be standing still to do this.");

	if(GetPlayerVehicleID(playerid) != 0)
		return SendClientMessage(playerid, -1, "You cannot do this animation while in a vehicle.");

	if(GetPlayerState(playerid) != 1)
	    return SendClientMessage(playerid, -1, "You have to be on foot to do this animation!");

	Player[playerid][IsInAnimation] = 1;
	if(Player[playerid][PlayingHours] < 100 && GetPlayerToggle(playerid, TOGGLE_ANIMATION_TEXT) == false)
		TextDrawShowForPlayer(playerid, AnimationTextDraw);
		
	return SetPlayerSpecialAction(playerid, SPECIAL_ACTION_HANDSUP);
}

CMD:walk(playerid)
{
	if(CantUseRightNow(playerid))
	    return SendClientMessage(playerid, -1, "You can't use this animation as you're cuffed, tazed, tied or dying");

	if(Player[playerid][IsAtEvent] >= 1)
		return SendClientMessage(playerid, WHITE, "You're unable to do that at this time.");

	if(GetPlayerSpeed(playerid, 0) != 0)
		return SendClientMessage(playerid, -1, "You must be standing still to do this.");

	if(GetPlayerVehicleID(playerid) != 0)
		return SendClientMessage(playerid, -1, "You cannot do this animation while in a vehicle.");

	if(GetPlayerState(playerid) != 1)
	    return SendClientMessage(playerid, -1, "You have to be on foot to do this animation!");

	Player[playerid][IsInAnimation] = 1;
	if(Player[playerid][PlayingHours] < 100 && GetPlayerToggle(playerid, TOGGLE_ANIMATION_TEXT) == false)
		TextDrawShowForPlayer(playerid, AnimationTextDraw);
		
	if(!isnull(Player[playerid][Walk]))
		ApplyAnimation(playerid, "PED", Player[playerid][Walk], 4.0, 1, 1, 1, 1, 1, 1);
	else
		ApplyAnimation(playerid, "PED", "WALK_player", 4.0, 1, 1, 1, 1, 1, 1);
		
	Player[playerid][IsInAnimation] = 2;
	return 1;
}