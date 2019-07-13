/*
#		MTG Actors System
#
#
#	By accessing this file, you agree to the following:
#		- You will never give the script or associated files to anybody who is not on the MTG SAMP development team
# 		- You will delete all development materials (script, databases, associated files, etc.) when you leave the MTG SAMP development team.
#
*/
#include <YSI\y_hooks>

#define MAX_DYNAMIC_ACTORS  500

enum ActorData
{
    ORM:ORM_ID,
    ActorSQL,
    ActorVW,
    Float: ActorX,
    Float: ActorY,
    Float: ActorZ,
    Float: ActorA,
    IsInvulnerable,
    ActorSkin,
    ActorAnimLib[30],
    ActorAnimName[30],
    ActorAnimLoop,
    ActorID
}
new Actors[MAX_ACTORS][ActorData];
new Iterator:Actor<MAX_ACTORS>;

static string[1024];

// ============= Commands =============
CMD:actorsmenu(playerid, params[])
{
    if(Player[playerid][AdminLevel] < 5)
	    return SendClientMessage(playerid, WHITE, "Only Admins Level 5+ Can Do This.");

    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	    return SendClientMessage(playerid, WHITE, "You need to be out of the vehicle.");

    ShowPlayerDialog(playerid, DIALOG_ACTOR_MENU_0, DIALOG_STYLE_LIST, "{CF4E23}Actors Menu", "Create Actor\nEdit Actor\nList Actors\nDelete Actor\nRespawn Actor(s)","Select", "Exit");
    return 1;
}

// ============= Callbacks =============

hook OnGameModeExit()
{
	SaveActors();
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
             case DIALOG_ACTOR_MENU_1:
             {
                   if(!response)
				   {
				        return ShowPlayerDialog(playerid, DIALOG_ACTOR_MENU_0, DIALOG_STYLE_LIST, "{CF4E23}Actors Menu", "Create Actor\nEdit Actor\nList Actors\nDelete Actor\nRespawn Actor(s)","Select", "Exit");
                   }
				   switch(listitem)
				   {
				        case 0: ShowPlayerDialog(playerid, DIALOG_ACTOR_POS, DIALOG_STYLE_INPUT, "{CF4E23}Edit Actor Position", "Please, type in the new coords X,Y,Z,A:\n","Ok", "Back");
				        case 1: ShowPlayerDialog(playerid, DIALOG_ACTOR_SKIN, DIALOG_STYLE_INPUT, "{CF4E23}Edit Actor Skin", "Please, type in the skin id you desire:\n", "Ok", "Back");
				        case 2: ShowPlayerDialog(playerid, DIALOG_ACTOR_VW, DIALOG_STYLE_INPUT, "{CF4E23}Edit Actor Virtual World", "Please, type in the virtual world you want:\n", "Ok", "Back");
				        case 3:	ShowPlayerDialog(playerid, DIALOG_ACTOR_INV, DIALOG_STYLE_INPUT, "{CF4E23}Edit Actor Invulnerability", "Please, type 1 if you want the actor to be invulerable\n        0 if you want the actor vulerable\n", "Ok", "Back");
				        case 4: ShowPlayerDialog(playerid, DIALOG_ACTOR_ANIMLIB, DIALOG_STYLE_INPUT, "{CF4E23}Edit Actor Animation Lib", "Please, insert the name of the library of the animation you want.\n", "Ok", "Back");
                        case 5: ShowPlayerDialog(playerid, DIALOG_ACTOR_ANIMNAME, DIALOG_STYLE_INPUT, "{CF4E23}Edit Actor Animation Name", "Please, insert the name of the animation you want.\n", "Ok", "Back");
				        case 6: ShowPlayerDialog(playerid, DIALOG_ACTOR_ANIMLOOP, DIALOG_STYLE_INPUT, "{CF4E23}Edit Actor Loop", "Please, type 1 if you want the animation to loop\n        0 if you do not want the animation to loop\n", "Ok", "Back");
						case 7: ShowPlayerDialog(playerid, DIALOG_ACTOR_MENU_0, DIALOG_STYLE_LIST, "{CF4E23}Actors Menu", "Create Actor\nEdit Actor\nList Actors\nDelete Actor\nRespawn Actor(s)","Select", "Exit");
				   }
		     }
			 case DIALOG_ACTOR_LIST:
			 {
				new actorid;
				strcpy(string, inputtext, sizeof(string));
				for(new i; i < strlen(string); i++)
				{
					if(string[i] == ')')
					{
						string[i] = '\0';
						actorid = strval(string);
						break;
					}
				}
				SetPlayerPos_Update(playerid, Actors[actorid][ActorX], Actors[actorid][ActorY], Actors[actorid][ActorZ] + 0.5);
				SetPlayerVirtualWorld(playerid, Actors[actorid][ActorVW]);
			 }
			 case DIALOG_ACTOR_MENU_0:
		     {
				if(!response)
					return 1;
					
				switch(listitem)
				{
					case 0:
					{	
						if(Iter_Free(Actor) == -1)
						  return SendClientMessage(playerid, WHITE, "There are no more actor IDs available.");
						
						new Float:pos[4];
						GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
						GetPlayerFacingAngle(playerid, pos[3]);
						
						new id = MTG_CreateActor(pos[0], pos[1], pos[2], pos[3], GetPlayerVirtualWorld(playerid), .create_orm = 1);
						
						format(string, sizeof(string), "You have created actor id %d. Use /actorsmenu to edit the actor.", id);
						SendClientMessage(playerid, WHITE, string);
					}
					case 1:
					{
						new count;
						foreach(new i : Actor)
						{
							if(IsPlayerInRangeOfPoint(playerid, 3.0, Actors[i][ActorX], Actors[i][ActorY], Actors[i][ActorZ]))
							{
								ShowActorDialog(playerid, i);
								format(string, sizeof(string), "You're now editing Actor ID %d.", i);
								SetPVarInt(playerid, "EDITING_ACTOR_ID", i);
								SendClientMessage(playerid, WHITE, string);
								count++;
								break;
							}
						}
						if(count == 0)
							return SendClientMessage(playerid, WHITE, "Please stand near the actor you are trying to edit.");
					}
					case 2:
					{
					   new anim[10];
					   string[0] = EOS;
					   foreach(new i : Actor)
					   {
							if(isnull(Actors[i][ActorAnimLib]))
							{
								  format(anim, sizeof(anim), "No");
							}
							else return format(anim, sizeof(anim), "Yes");
							
							if(Actors[i][ActorID] > 0)
							{
								 format(string, sizeof(string), "{FFFFFF}%s%d) {CF4E23}%f, %f, %f | {FFFFFF}Skin: {CF4E23}%d |{FFFFFF}Animation: {CF4E23}%s\n", string, i, Actors[i][ActorX], Actors[i][ActorY], Actors[i][ActorZ], Actors[i][ActorSkin], anim);
							}
					   }
					   if(strlen(string) < 1)
							return SendClientMessage(playerid, -1, "There are no actors to list.");
					   ShowPlayerDialog(playerid, DIALOG_ACTOR_LIST, DIALOG_STYLE_LIST, "{CF4E23}List Of Actors", string, "Go To", "Cancel");
					}
					case 3:
					{
						   foreach(new i : Actor)
						   {
								 if(IsPlayerInRangeOfPoint(playerid, 3.0, Actors[i][ActorX], Actors[i][ActorY], Actors[i][ActorZ]))
								 {
									  MTG_DestroyActor(i);
									  format(string, sizeof(string), "You have permantely deleted actor %d.", i);
									  SendClientMessage(playerid, WHITE, string);
									  
									  format(string, sizeof(string), "%s has permantely deleted actor %d.", GetName(playerid), i);
									  AdminActionsLog(string);
								 }
						   }
					}
					case 4:
					{
						ShowPlayerDialog(playerid, DIALOG_ACTOR_RESPAWN, DIALOG_STYLE_LIST, "{CF4E23}Respawn Actor(s)", "Respawn Nearest Actor\nRespawn All actors\nBack", "Select", "Cancel");
					}
				}
            }
            case DIALOG_ACTOR_RESPAWN:
            {
				 if(!response)
				 {
				      ShowPlayerDialog(playerid, DIALOG_ACTOR_MENU_0, DIALOG_STYLE_LIST, "{CF4E23}Actors Menu", "Create Actor\nEdit Actor\nList Actors\nDelete Actor\nRespawn Actor(s)","Select", "Exit");
                 }
                 switch(listitem)
				 {
					case 0:
					{
						foreach(new i : Actor)
						{
							if(IsPlayerInRangeOfPoint(playerid, 3.0, Actors[i][ActorX], Actors[i][ActorY], Actors[i][ActorZ]))
							{
								 RespawnActor(i);
								 format(string, sizeof(string), "ACTOR ID %d has been respawned.", i);
								 SendClientMessage(playerid, WHITE, string);
							}
						}
					}
					case 1:
					{
                          foreach(new i : Actor)
	                      {
							  RespawnActor(i);
	                      }
	                      SendClientMessage(playerid, WHITE, "All Actors have been respawned.");
					}
				 }
            }
            case DIALOG_ACTOR_POS:
			{
				new i = GetPVarInt(playerid, "EDITING_ACTOR_ID");
				if(!response)
					return ShowActorDialog(playerid, i);
				
				new Float:X,Float:Y,Float:Z,Float:A;
				
				if(sscanf(inputtext,"ffff",X,Y,Z,A)) 
					return ShowPlayerDialog(playerid, DIALOG_ACTOR_POS, DIALOG_STYLE_INPUT, "{CF4E23}Edit Actor Position", "Please, type in the new coords X,Y,Z,A:\n","Ok", "Back");

				Actors[i][ActorX] = X;
				Actors[i][ActorY] = Y;
				Actors[i][ActorZ] = Z;
				Actors[i][ActorA] = A;
				
				SaveActor(i);
				RespawnActor(i);
				
				ShowActorDialog(playerid, i);
			}
            case DIALOG_ACTOR_SKIN:
            {
				new i = GetPVarInt(playerid, "EDITING_ACTOR_ID");
				if(!response)
					return ShowActorDialog(playerid, i);

				new v = strval(inputtext);
				if(v < 0 && MAX_SKINS)
					return ShowPlayerDialog(playerid, DIALOG_ACTOR_SKIN, DIALOG_STYLE_INPUT, "{CF4E23}Edit Actor Skin", "Please, type in the skin id you desire:\n", "Ok", "Back"), SendClientMessage(playerid, WHITE, "Wrong Skin ID.");

				Actors[i][ActorSkin] = v;
				SaveActor(i);
				RespawnActor(i);
				
				ShowActorDialog(playerid, i);
            }
            case DIALOG_ACTOR_VW:
            {
				new i = GetPVarInt(playerid, "EDITING_ACTOR_ID");
				if(!response)
					return ShowActorDialog(playerid, i);
				
				new vw = strval(inputtext);
				
				Actors[i][ActorVW] = vw;
				SetActorVirtualWorld(i, vw);
				SaveActor(i, 0);
				RespawnActor(i);
				
				ShowActorDialog(playerid, i);
            }
            case DIALOG_ACTOR_INV:
            {
				new i = GetPVarInt(playerid, "EDITING_ACTOR_ID");
				if(!response)
					return ShowActorDialog(playerid, i);

				new inv = strval(inputtext);

				Actors[i][IsInvulnerable] = inv;
				SetActorInvulnerable(Actors[i][ActorID], inv);
				SaveActor(i);

				ShowActorDialog(playerid, i);
            }
            case DIALOG_ACTOR_ANIMLIB:
            {
				new i = GetPVarInt(playerid, "EDITING_ACTOR_ID");
				if(!response)
					return ShowActorDialog(playerid, i);

				if(strlen(inputtext) < 1)
					return  ShowPlayerDialog(playerid, DIALOG_ACTOR_ANIMLIB, DIALOG_STYLE_INPUT, "{CF4E23}Edit Actor Animation Lib", "Please, insert the name of the library of the animation you want.\n", "Ok", "Back");

				format(Actors[i][ActorAnimLib], 30, inputtext);
				SaveActor(i);
				RespawnActor(i);

				ShowActorDialog(playerid, i);
            }
			case DIALOG_ACTOR_ANIMNAME:
            {
				new i = GetPVarInt(playerid, "EDITING_ACTOR_ID");
				if(!response)
					return ShowActorDialog(playerid, i);

				if(strlen(inputtext) < 1)
					return  ShowPlayerDialog(playerid, DIALOG_ACTOR_ANIMNAME, DIALOG_STYLE_INPUT, "{CF4E23}Edit Actor Animation Name", "Please, insert the name of the animation you want.\n", "Ok", "Back");

				format(Actors[i][ActorAnimName], 30, inputtext);
				SaveActor(i);
				RespawnActor(i);

				ShowActorDialog(playerid, i);
            }
            case DIALOG_ACTOR_ANIMLOOP:
            {
				new i = GetPVarInt(playerid, "EDITING_ACTOR_ID");
				if(!response)
					return ShowActorDialog(playerid, i);
					
				new loop = strval(inputtext);
				Actors[i][ActorAnimLoop] = loop;
				SaveActor(i, 0);
				RespawnActor(i);

				ShowActorDialog(playerid, i);
            }
	}
	return 1;
}

//=============stocks====================

stock ShowActorDialog(playerid, id)
{
	format(string, sizeof(string), "Actor Position: {CF4E23}[%f , %f , %f , %f]\nActor Model: {CF4E23}%d\nActor VW: {CF4E23}%d\nIsInvulnerable: {CF4E23}%d\nActor AnimLib: {CF4E23}%s\nActor AnimName: {CF4E23}%s\nActor AnimLoop: {CF4E23}%d\n", Actors[id][ActorX], Actors[id][ActorY], Actors[id][ActorZ], Actors[id][ActorA], Actors[id][ActorSkin],  Actors[id][ActorVW], Actors[id][IsInvulnerable], Actors[id][ActorAnimLib], Actors[id][ActorAnimName], Actors[id][ActorAnimLoop]);
	return ShowPlayerDialog(playerid, DIALOG_ACTOR_MENU_1, DIALOG_STYLE_LIST, "{CF4E23}Edit Actor", string, "Edit", "Back");
}

stock RespawnActor(i)
{
	if(IsValidActor(Actors[i][ActorID]))
		DestroyActor(Actors[i][ActorID]);
	
    Actors[i][ActorID] = CreateActor(Actors[i][ActorSkin], Actors[i][ActorX], Actors[i][ActorY], Actors[i][ActorZ], Actors[i][ActorA]);
    SetActorVirtualWorld(Actors[i][ActorID], Actors[i][ActorVW]);
    ClearActorAnimations(Actors[i][ActorID]);
    SetActorInvulnerable(Actors[i][ActorID], Actors[i][IsInvulnerable]);
    ApplyActorAnimation(Actors[i][ActorID], Actors[i][ActorAnimLib], Actors[i][ActorAnimName], 4.1, Actors[i][ActorAnimLoop], 0, 0, 0, 0);
	return 1;
}

stock MTG_DestroyActor(id)
{
	DestroyActor(Actors[id][ActorID]);
	orm_delete(Actors[id][ORM_ID]);
	orm_destroy(Actors[id][ORM_ID]);
	Iter_Remove(Actor, id);
	return 1;
}

stock MTG_CreateActor(Float:x, Float:y, Float:z, Float:a, vw, skin = 0, is_invulnerable = 0, anim_lib[] = "", anim_name[] = "", anim_loop = 0, create_orm = 0, id = -1)
{
	if(id == -1)
		id = Iter_Free(Actor);
	
	if(id == -1)
		return id;
		
	Actors[id][ActorX] = x;
	Actors[id][ActorY] = y;
	Actors[id][ActorZ] = z;
	Actors[id][ActorA] = a;
	Actors[id][ActorVW] = vw;
	Actors[id][ActorSkin] = skin;
	Actors[id][IsInvulnerable] = is_invulnerable;
	format(Actors[id][ActorAnimLib], 30, anim_lib);
	format(Actors[id][ActorAnimName], 30, anim_name);
	Actors[id][ActorAnimLoop] = anim_loop;
	
	Actors[id][ActorID] = CreateActor(skin, x, y, z, a);
	SetActorVirtualWorld(Actors[id][ActorID], vw);
	SetActorInvulnerable(Actors[id][ActorID], Actors[id][IsInvulnerable]);
	
	if(!isnull(anim_lib))
		 ApplyActorAnimation(Actors[id][ActorID], Actors[id][ActorAnimLib], Actors[id][ActorAnimName], 4.1, Actors[id][ActorAnimLoop], 0, 0, 0, 0);
	
	if(create_orm == 1)
	{
		Actors[id][ORM_ID] = orm_create("actors");
		SetupActorORM(id);
		orm_setkey(Actors[id][ORM_ID], "ActorSQL");
	}
	
	Iter_Add(Actor, id);
	SaveActor(id, create_orm);
	return id;
}

stock SaveActors()
{
    foreach(new i : Actor)
	{
		SaveActor(i);
	}
	return 1;
}

forward OnActorsLoad();
public OnActorsLoad()
{
	new total_rows = cache_num_rows();
	for(new r; r < total_rows; r++)
	{
		Actors[r][ORM_ID] = orm_create("actors");
		SetupActorORM(r);
		
		orm_setkey(Actors[r][ORM_ID], "ActorSQL");
		orm_apply_cache(Actors[r][ORM_ID], r);
        
		MTG_CreateActor(Actors[r][ActorX], Actors[r][ActorY], Actors[r][ActorZ], Actors[r][ActorA], Actors[r][ActorVW], Actors[r][ActorSkin], Actors[r][IsInvulnerable], Actors[r][ActorAnimLib], Actors[r][ActorAnimName], Actors[r][ActorAnimLoop], .id = r);
	}
	return 1;
}

stock InitActors()
{
	mysql_tquery(MYSQL_MAIN, "SELECT * FROM actors", "OnActorsLoad", "");
	return 1;
}

stock SetupActorORM(actorid)
{
	orm_addvar_int(Actors[actorid][ORM_ID], Actors[actorid][ActorSQL], "ActorSQL");
	orm_addvar_float(Actors[actorid][ORM_ID], Actors[actorid][ActorX], "ActorX");
	orm_addvar_float(Actors[actorid][ORM_ID], Actors[actorid][ActorY], "ActorY");
	orm_addvar_float(Actors[actorid][ORM_ID], Actors[actorid][ActorZ], "ActorZ");
	orm_addvar_float(Actors[actorid][ORM_ID], Actors[actorid][ActorA], "ActorA");
	orm_addvar_int(Actors[actorid][ORM_ID], Actors[actorid][ActorVW], "ActorVW");
	orm_addvar_int(Actors[actorid][ORM_ID], Actors[actorid][ActorSkin], "ActorSkin");
	orm_addvar_int(Actors[actorid][ORM_ID], Actors[actorid][IsInvulnerable], "IsInvulnerable");
	orm_addvar_int(Actors[actorid][ORM_ID], Actors[actorid][ActorAnimLoop], "ActorAnimLoop");
	orm_addvar_string(Actors[actorid][ORM_ID], Actors[actorid][ActorAnimLib], 256, "ActorAnimLib");
	orm_addvar_string(Actors[actorid][ORM_ID], Actors[actorid][ActorAnimName], 256, "ActorAnimName");
	return 1;
}


stock SaveActor(i, create = 0)
{
	if(create == 1)
		orm_insert(Actors[i][ORM_ID]);
	else 
	{
		if(Actors[i][ORM_ID] == 0)
		{
			printf("[ORM ERROR] Attempted to save an orm_id of zero. (Actor %d)", i);
			return 1;
		}
		
		orm_update(Actors[i][ORM_ID]);
	}

	printf("[system] Actor %d saved.", i);
	return 1;
}

