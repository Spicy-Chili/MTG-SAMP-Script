/*
#		MTG CLEO Slap
#		
#
#	By accessing this file, you agree to the following:
#		- You will never give the script or associated files to anybody who is not on the MTG SAMP development team
# 		- You will delete all development materials (script, databases, associated files, etc.) when you leave the MTG SAMP development team.
#
#
#
*/

ptask AntiCleoSlap[750](i)
{
	new Float:newX, Float:newY, Float:newZ;
	GetPlayerVelocity(i, newX, newY, newZ);
	new string[128];
	
	if(((newX - Player[i][oldXVel]) >= 2.0 || (newY - Player[i][oldYVel] >= 2.0) || (newZ - Player[i][oldZVel] >= 2.0) || ((newX - Player[i][oldXVel]) < -2.0) || ((newY - Player[i][oldYVel]) < -2.0) || ((newZ - Player[i][oldZVel]) < -2.0)) && !IsPlayerInAnyVehicle(i))
	{
		new Float:pPosX, Float:pPosY, Float:pPosZ;
		#pragma unused pPosZ
		GetPlayerPos(i, pPosX, pPosY, pPosZ);
		SetPlayerVelocity(i, 0.0, 0.0, 0.0);
		SetPlayerPosFindZ(i, pPosX, pPosY, 100);
		SetPlayerPosFindZ(i, pPosX, pPosY, 100);
		SendClientMessage(i, ADMINORANGE, "You have been detected as flying/slapped by a hacker. You have been placed at your last position.");
		
		format(string, sizeof(string), "[AC] %s was thrown into the air or is air-break hacking.", GetName(i));
		SendToAdmins(ADMINORANGE, string, 1);
	}
	
	Player[i][oldXVel] = newX;
	Player[i][oldYVel] = newY;
	Player[i][oldZVel] = newZ;
	return 1;
}