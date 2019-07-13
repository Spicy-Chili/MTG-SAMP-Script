/*
#		MTG Firework System
#		
#
#	By accessing this file, you agree to the following:
#		- You will never give the script or associated files to anybody who is not on the MTG SAMP development team
# 		- You will delete all development materials (script, databases, associated files, etc.) when you leave the MTG SAMP development team.
#
#
#
*/

#define MAX_FIREWORKS	70
#define MAX_PARTICLES	35

enum fireworkData
{
	fwObject[2],
	Float:fwPos[3],
	fwDelay,
	fwActive,
	fwHeight,
	fwAngle,
	fwColor[2], //0 = all, 1 = white, 2 = red, 3 = blue, 4 = green
	fwParticles[MAX_PARTICLES],
	fwIsAdminFirework,
};

new Fireworks[MAX_FIREWORKS][fireworkData];
new ActiveFwShow;

stock GetFireworkID()
{
	new id = INVALID_OBJECT_ID;
	for(new i; i < MAX_FIREWORKS; i++)
	{
		if(Fireworks[i][fwActive] == 0)
		{
			id = i;
			break;
		}
	}
	return id;
}

stock GetAdminFireworkCount()
{
	new count; 
	for(new i; i < MAX_FIREWORKS; i++)
	{
		if(Fireworks[i][fwActive] == 1 && Fireworks[i][fwIsAdminFirework] == 1)
			count++;
	}
	return count;
}

stock ResetFirework(i)
{
	Fireworks[i][fwActive] = 0;
	Fireworks[i][fwObject][0] = INVALID_OBJECT_ID;
	Fireworks[i][fwObject][1] = INVALID_OBJECT_ID;
	Fireworks[i][fwPos][0] = 0.0;
	Fireworks[i][fwPos][1] = 0.0;
	Fireworks[i][fwPos][2] = 0.0;
	Fireworks[i][fwDelay] = 100;
	Fireworks[i][fwHeight] = 25;
	Fireworks[i][fwAngle] = 0;
	Fireworks[i][fwColor][0] = 0;
	Fireworks[i][fwColor][1] = 0;
	Fireworks[i][fwIsAdminFirework] = 0;
	
	for(new p; p < MAX_PARTICLES; p++)
		Fireworks[i][fwParticles][p] = INVALID_OBJECT_ID;
		
	return 1;
}

stock GetFireworkColor(num)
{
	switch(num)
	{
		case 1: return 19281;
		case 2: return 19282;
		case 3: return 19283;
		case 4: return 19284;
	}
	return 1;
}

stock Float:RandomOffset()
{
	new Float:value; 
	new Float:offsets[] =
	{
		0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0
	};
	
	new rand = random(sizeof(offsets));
	value = offsets[rand];
	
	switch(random(2))
	{
		case 0: value = floatsub(value, (floatmul(value, 2.0)));
	}
	return Float:value;
}

forward FireworksTimer(id, step);
public FireworksTimer(id, step)
{
	switch(step)
	{
		case 0:
		{
			PlayNearbySound(Fireworks[id][fwPos][0], Fireworks[id][fwPos][1], Fireworks[id][fwPos][2], 1159);
			MoveObject(Fireworks[id][fwObject][0], Fireworks[id][fwPos][0], Fireworks[id][fwPos][1] + Fireworks[id][fwAngle], Fireworks[id][fwPos][2] + Fireworks[id][fwHeight], 15);
			
			new delay = 1600;
			if(Fireworks[id][fwHeight] > 25)
			{
				delay = (Fireworks[id][fwHeight] * 1600) / 25;
			}
			SetTimerEx("FireworksTimer", delay, false, "ii", id, 1);
		}
		case 1:
		{
			DestroyObject(Fireworks[id][fwObject][0]);
			DestroyObject(Fireworks[id][fwObject][1]);
			CreateExplosion(Fireworks[id][fwPos][0], Fireworks[id][fwPos][1] + Fireworks[id][fwAngle], Fireworks[id][fwPos][2] + Fireworks[id][fwHeight], 12, 1);

			for(new i; i < MAX_PARTICLES; i++)
			{
				new color;
				if(Fireworks[id][fwColor][0] == 0)
				{
					new rand = random(4);
					color = GetFireworkColor(rand + 1);
				}
				else if(Fireworks[id][fwColor][1] != 0)
				{
					switch(random(2))
					{
						case 0: color = GetFireworkColor(Fireworks[id][fwColor][0]);
						case 1: color = GetFireworkColor(Fireworks[id][fwColor][1]);
					}
				}
				else if(Fireworks[id][fwColor][1] == 0 && Fireworks[id][fwColor][0] != 0)
					color = GetFireworkColor(Fireworks[id][fwColor][0]);

				Fireworks[id][fwParticles][i] = CreateDynamicObject(color, Fireworks[id][fwPos][0], Fireworks[id][fwPos][1], Fireworks[id][fwPos][2] + Fireworks[id][fwHeight], 0.0, 0.0, 0.0, -1, -1, -1, 700, 700);
				MoveDynamicObject(Fireworks[id][fwParticles][i], Fireworks[id][fwPos][0] + RandomOffset(), (Fireworks[id][fwPos][1] + Fireworks[id][fwAngle]) + RandomOffset(), (Fireworks[id][fwPos][2] + Fireworks[id][fwHeight]) + RandomOffset(), 10);
			}
			
			SetTimerEx("FireworksTimer", 1500, false, "ii", id, 2);
		}
		case 2:
		{
			for(new i; i < MAX_PARTICLES; i++)
				DestroyDynamicObject(Fireworks[id][fwParticles][i]);
				
			ResetFirework(id);
			
			if(GetAdminFireworkCount() == 0)
				ActiveFwShow = 0;
		}
	}
	return 1;
}

CMD:launchfireworks(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
		
	if(isnull(params) || strcmp(params, "confirm", true))
	{
		SendClientMessage(playerid, -1, "Are you sure you wish to start the show? This will launch all fireworks and prevent the placement of more until the show is over.");
		SendClientMessage(playerid, -1, "Type /launchfireworks confirm if you are sure.");
		return 1;
	}
	
	if(ActiveFwShow != 0)
		return SendClientMessage(playerid, -1, "There is currently a show already going.");
	
	for(new i; i < MAX_FIREWORKS; i++)
	{
		if(Fireworks[i][fwIsAdminFirework] == 1)
			SetTimerEx("FireworksTimer", Fireworks[i][fwDelay], false, "ii", i, 0);
	}
	ActiveFwShow = 1;
	
	SendClientMessage(playerid, -1, "You have started the firework show.");
	return 1;
}

CMD:showstatus(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
		
	new string[128];
	
	SendClientMessage(playerid, WHITE, "--------------------------------------------------------------------");
	format(string, sizeof(string), "The firework show is currently %s.", (ActiveFwShow == 0) ? ("Inactive") : ("Active"));
	SendClientMessage(playerid, -1, string);
	format(string, sizeof(string), "There are currently %d unlaunched admin fireworks.", GetAdminFireworkCount());
	SendClientMessage(playerid, -1, string);
	SendClientMessage(playerid, WHITE, "--------------------------------------------------------------------");
	return 1;
}

CMD:deletefirework(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
		
	if(isnull(params) || !isnumeric(params))
		return SendClientMessage(playerid, -1, "SYNTAX: /deletefirework [id]");
		
	new id = strval(params);
	
	if(id < 0 || id > MAX_FIREWORKS)
		return SendClientMessage(playerid, -1, "IDs are between 0 and 50.");
		
	if(ActiveFwShow != 0)
		return SendClientMessage(playerid, -1, "You can't delete fireworks once the show has started.");
			
	new string[128];
	
	DestroyObject(Fireworks[id][fwObject][0]);
	DestroyObject(Fireworks[id][fwObject][1]);
	ResetFirework(id);
	format(string, sizeof(string), "You have deleted firework %d.", id);
	SendClientMessage(playerid, -1, string);
	return 1;
}

CMD:placefirework(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
	
	if(ActiveFwShow != 0)
		return SendClientMessage(playerid, -1, "There is currently an active firework show, wait until it is over or use /changefwstate to force it.");
		
	new delay, height, angle, color[2], amount;
	
	if(sscanf(params, "ddddD(0)D(1)", delay, height, angle, color[0], color[1], amount))
	{
		SendClientMessage(playerid, WHITE, "SYNTAX: /placefirework [delay] [height] [angle] [color1] <color2> <amount>");
		SendClientMessage(playerid, -1, "Delay: Delay in milliseconds from typing /launchfireworks. The minimum is 100 milliseconds (1/10th second)");
		SendClientMessage(playerid, -1, "Height: The height the firework will explode. The minimum is 25 and the limit is 60.");
		SendClientMessage(playerid, -1, "Angle: The angle at which it will launch. Must be between 0 and 20 degrees.");
		SendClientMessage(playerid, -1, "Color: 0 = all, 1 = white, 2 = red, 3 = green, 4 = blue. Second color is optional.");
		SendClientMessage(playerid, -1, "Amount: Spawns given amount in direction you are facing");
		return 1;
	}
	
	if(delay < 100)
		delay = 100;
		
	if(height < 25 || height > 60)
		return SendClientMessage(playerid, -1, "The height must be between 25 and 60.");
	
	if(angle < -20 || angle > 20)
		return SendClientMessage(playerid, -1, "The angle must be between -20 and 20. (0 = none, 1 = angle left, 2 = angle right)");
	
	if(color[0] < 0 || color[0] > 4)
		return SendClientMessage(playerid, -1, "The color must be between 0 and 4. ( 0 = all, 1 = white, 2 = red, 3 = green, 4 = blue )");
		
	if(color[1] < 1 || color[1] > 4)
		return SendClientMessage(playerid, -1, "The second color must be between 1 and 4 and won't work if the first color is 0.");
		
	if(amount < 1)
		amount = 1;
		
	if(amount > 20)
		amount = 20;
	
	for(new i; i < amount; i++)
	{
		/*new id = GetFireworkID();

		if(id == INVALID_OBJECT_ID)
			return SendClientMessage(playerid, -1, "There are no more firework slots available.");


		GetPlayerPos(playerid, Fireworks[id][fwPos][0], Fireworks[id][fwPos][1], Fireworks[id][fwPos][2]);	
		GetXYInFrontOfPlayer(playerid, Fireworks[id][fwPos][0], Fireworks[id][fwPos][1], i * 3);	
		Fireworks[id][fwActive] = 1;
		Fireworks[id][fwObject][0] = CreateObject(365, Fireworks[id][fwPos][0], Fireworks[id][fwPos][1], Fireworks[id][fwPos][2] - 1.0, 0.0, 180.00, 500);
		Fireworks[id][fwObject][1] = CreateObject(18687, Fireworks[id][fwPos][0], Fireworks[id][fwPos][1], Fireworks[id][fwPos][2] - 1.0, -90.0, 0, 500);
		AttachObjectToObject(Fireworks[id][fwObject][1], Fireworks[id][fwObject][0], 0.05 , 1.7, 0.0, 90.0, 0.0, 0.0, 1);
		Fireworks[id][fwDelay] = delay;
		Fireworks[id][fwHeight] = height;
		Fireworks[id][fwAngle] = angle;
		Fireworks[id][fwColor][0] = color[0];
		Fireworks[id][fwColor][1] = color[1];*/
		CreateFirework(playerid, delay, height, angle, color[0], color[1], i * 3, 1);
	}
	
	new string[128];
	format(string, sizeof(string), "You have created %d fireworks. Use /launchfireworks once the show is completely done.", amount);
	SendClientMessage(playerid, -1, string);
	return 1;
}

CMD:changefwstate(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
		
	if(ActiveFwShow != 0)
	{
		for(new i; i < MAX_FIREWORKS; i++)
		{
			if(!IsValidObject(Fireworks[i][fwObject][0]) && !IsValidObject(Fireworks[i][fwObject][1]))
				continue;
				
			DestroyObject(Fireworks[i][fwObject][0]);
			DestroyObject(Fireworks[i][fwObject][1]);
			for(new k; k < MAX_PARTICLES; k++)
				DestroyDynamicObject(Fireworks[i][fwParticles][k]);
			ResetFirework(i);
		}
		SendClientMessage(playerid, -1, "You have forced the firework show to be inactive.");
		ActiveFwShow = 0;
	}
	else
	{
		SendClientMessage(playerid, -1, "You have forced the firework show to be active.");
		ActiveFwShow = 1;
	}
	return 1;
}
stock CreateFirework(playerid, delay, height, angle, color1, color2, offset = 0, isAdmins = 0)
{
	new id = GetFireworkID();

	if(id == INVALID_OBJECT_ID)
		return SendClientMessage(playerid, -1, "There are no more firework slots available.");

	GetPlayerPos(playerid, Fireworks[id][fwPos][0], Fireworks[id][fwPos][1], Fireworks[id][fwPos][2]);	
	GetXYInFrontOfPlayer(playerid, Fireworks[id][fwPos][0], Fireworks[id][fwPos][1], offset);	
	Fireworks[id][fwActive] = 1;
	Fireworks[id][fwObject][0] = CreateObject(365, Fireworks[id][fwPos][0], Fireworks[id][fwPos][1], Fireworks[id][fwPos][2] - 1.0, 0.0, 180.00, 500);
	Fireworks[id][fwObject][1] = CreateObject(18687, Fireworks[id][fwPos][0], Fireworks[id][fwPos][1], Fireworks[id][fwPos][2] - 1.0, -90.0, 0, 500);
	AttachObjectToObject(Fireworks[id][fwObject][1], Fireworks[id][fwObject][0], 0.05 , 1.7, 0.0, 90.0, 0.0, 0.0, 1);
	Fireworks[id][fwDelay] = delay;
	Fireworks[id][fwHeight] = height;
	Fireworks[id][fwAngle] = angle;
	Fireworks[id][fwColor][0] = color1;
	Fireworks[id][fwColor][1] = color2;
	Fireworks[id][fwIsAdminFirework] = isAdmins;
	return id;
}