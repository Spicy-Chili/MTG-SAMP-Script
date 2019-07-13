/*
#		MTG Christmas Code
#		
#
#	By accessing this file, you agree to the following:
#		- You will never give the script or associated files to anybody who is not on the MTG SAMP development team
# 		- You will delete all development materials (script, databases, associated files, etc.) when you leave the MTG SAMP development team.
#
#		**Make sure to put "#define	MTG_CHRISTMAS"	at the top of the main script for this to work.**
#		
*/

#if defined MTG_CHRISTMAS

#include <YSI\y_hooks>
#include <YSI\y_timers>

#define SSFilePath				"Misc/SecretSanta.ini"
#define MTG_CHRISTMAS_AUDIO		"http://samp.mt-gaming.com/SAMPSounds/MTG_Christmas.wav"

#define	SSPosX					1128.4082
#define SSPosY					-1488.6576
#define SSPosZ					22.7690
#define SSDepositCooldown		5 //How many playing hours between deposits
#define SSRedeemCooldown		10 //How many playing hours between withdraws
#define MinHours				25 //How many playing hours you need to participate 

#define MinCash					500 //Minimum amounts to deposit
#define MinPot					25
#define MinCocaine				25
#define MinSpeed				25
#define MinMats					20

new Text3D:SecretSantaLabel;
new SecretSantaCash, SecretSantaCocaine, SecretSantaMats[3], SecretSantaPot, SecretSantaSpeed;

task SantaUpdate[7200]() //Called every 2 hours this should update the text label automatically on christmas
{
	new year, month, day;
	new second, minute, hour;
	getdate(year, month, day);
	gettime(hour, minute, second);
	
	if(hour < 4 && day == 25)
		UpdateDynamic3DTextLabelText(SecretSantaLabel, GREEN, "{FF0000}Secret Santa Location!\n{00FF00}Type /secretsantaredeem to get a present!");
	
	return 1;
}

hook OnPlayerConnect(playerid)
{
	RemoveBuildingForPlayer(playerid, 712, 1471.4063, -1666.1797, 22.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 712, 1480.6094, -1666.1797, 22.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 712, 1488.2266, -1666.1797, 22.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 1290, 1349.9922, -1380.0703, 18.2891, 0.25);
	RemoveBuildingForPlayer(playerid, 716, 1350.1172, -1380.3516, 13.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 716, 1350.1172, -1343.2578, 13.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 716, 1350.1172, -1331.6563, 13.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 716, 1350.1172, -1293.5625, 13.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 792, 1128.7344, -1518.4922, 15.2109, 0.25);
	return 1;
}

hook OnGameModeInit()
{
	print("MTG Chrismas scripting initiated!");
	if(!IsChristmas()) //In case the server restarts on christmas for whatever reason
		SecretSantaLabel = CreateDynamic3DTextLabel("{FF0000}Secret Santa Location!\n{00FF00}Type /secretsantadeposit to deposit!", GREEN, SSPosX, SSPosY, SSPosZ, 250);
	else SecretSantaLabel = CreateDynamic3DTextLabel("{FF0000}Secret Santa Location!\n{00FF00}Type /secretsantaredeem to get a present!", GREEN, SSPosX, SSPosY, SSPosZ, 250);

	LoadSecretSanta();

	new retexture;
	CreateDynamicObject(19076, 1128.89, -1447.97, 14.29,   0.00, 0.00, 0.00);
	CreateDynamicObject(19054, 1130.94, -1446.26, 15.44,   0.00, 0.00, -32.00);
	CreateDynamicObject(19058, 1130.19, -1447.51, 15.53,   0.00, 0.00, 0.00);
	CreateDynamicObject(19055, 1129.49, -1445.81, 15.53,   0.00, 0.00, 8.00);
	CreateDynamicObject(19056, 1128.08, -1445.53, 15.56,   0.00, 0.00, -10.00);
	CreateDynamicObject(19057, 1126.94, -1446.47, 15.56,   0.00, 0.00, -135.00);
	CreateDynamicObject(19054, 1126.71, -1449.08, 15.44,   0.00, 0.00, -32.00);
	CreateDynamicObject(19055, 1130.63, -1449.36, 15.53,   0.00, 0.00, 8.00);
	CreateDynamicObject(19056, 1127.60, -1447.90, 15.56,   0.00, 0.00, -10.00);
	CreateDynamicObject(19054, 1129.10, -1449.69, 15.44,   0.00, 0.00, 62.00);
	CreateDynamicObject(19057, 1127.79, -1450.47, 15.56,   0.00, 0.00, -135.00);
	CreateDynamicObject(18648, 1154.08, -1432.05, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1149.67, -1432.05, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1151.88, -1432.05, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1147.46, -1432.05, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1145.11, -1432.03, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1142.81, -1432.03, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1140.45, -1432.03, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1138.16, -1432.03, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1135.80, -1432.03, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1133.52, -1432.03, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1131.15, -1432.03, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1128.85, -1432.03, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1126.49, -1432.03, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1124.19, -1432.01, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1121.83, -1432.01, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1119.54, -1431.99, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1117.18, -1431.99, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1114.88, -1431.99, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1112.53, -1431.99, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1110.23, -1431.97, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1107.87, -1431.95, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1105.57, -1431.95, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1103.22, -1431.95, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1103.37, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1105.57, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1107.87, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1110.23, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1112.53, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1114.88, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1117.18, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1119.54, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1121.83, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1124.19, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1126.49, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1128.85, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1131.15, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1133.52, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1135.80, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1138.16, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1140.45, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1142.81, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1145.11, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1147.46, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1149.67, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1151.88, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1154.08, -1423.43, 20.32,   0.00, 0.00, 90.00);
	retexture = CreateDynamicObject(19376, 1128.99, -1447.99, 14.79,   0.00, 90.00, 0.00);
	SetDynamicObjectMaterial(retexture, 0, 3187, "cxref_quarrytest", "gs_wood2", 0xFFFFFFFF);
	CreateDynamicObject(7654, 1148.61, -1455.80, 21.61,   0.00, 0.00, 0.00);
	CreateDynamicObject(19076, 1129.00, -1489.58, 21.28,   0.00, 0.00, 0.00);
	CreateDynamicObject(19076, 1129.29, -1455.80, 13.78,   0.00, 0.00, 0.00);
	CreateDynamicObject(19076, 1129.29, -1439.84, 13.78,   0.00, 0.00, 0.00);
	CreateDynamicObject(7654, 1148.61, -1439.75, 21.61,   0.00, 0.00, 0.00);
	CreateDynamicObject(19076, 1129.29, -1516.54, 13.78,   0.00, 0.00, 0.00);
	CreateDynamicObject(7654, 1147.84, -1513.30, 21.61,   0.00, 0.00, 40.00);
	CreateDynamicObject(7654, 1110.03, -1514.20, 21.61,   0.00, 0.00, -40.00);
	CreateDynamicObject(19057, 1126.95, -1489.97, 22.10,   0.00, 0.00, 0.00);
	CreateDynamicObject(19058, 1127.45, -1488.40, 22.19,   0.00, 0.00, -33.00);
	CreateDynamicObject(19054, 1129.33, -1488.45, 22.38,   0.00, 0.00, 16.00);
	CreateDynamicObject(19055, 1130.38, -1489.73, 22.10,   0.00, 0.00, 0.00);
	CreateDynamicObject(19056, 1128.91, -1491.26, 22.05,   0.00, 0.00, -14.00);
	CreateDynamicObject(1256, 1128.42, -1447.78, 15.44,   0.00, 0.00, 0.00);
	CreateDynamicObject(1256, 1129.32, -1447.76, 15.44,   0.00, 0.00, 180.00);
	CreateDynamicObject(18648, 1154.08, -1432.05, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1149.67, -1432.05, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1151.88, -1432.05, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1147.46, -1432.05, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1145.11, -1432.03, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1142.81, -1432.03, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1140.45, -1432.03, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1138.16, -1432.03, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1135.80, -1432.03, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1133.52, -1432.03, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1131.15, -1432.03, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1128.85, -1432.03, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1126.49, -1432.03, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1124.19, -1432.01, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1121.83, -1432.01, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1119.54, -1431.99, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1117.18, -1431.99, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1114.88, -1431.99, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1112.53, -1431.99, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1110.23, -1431.97, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1107.87, -1431.95, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1105.57, -1431.95, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1103.22, -1431.95, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1103.37, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1105.57, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1107.87, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1110.23, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1112.53, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1114.88, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1117.18, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1119.54, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1121.83, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1124.19, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1126.49, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1128.85, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1131.15, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1133.52, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1135.80, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1138.16, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1140.45, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1142.81, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1145.11, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1147.46, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1149.67, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18647, 1151.88, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(18648, 1154.08, -1423.43, 20.32,   0.00, 0.00, 90.00);
	CreateDynamicObject(19315, 1118.87, -1489.05, 22.18,   0.00, 0.00, 0.00);
	CreateDynamicObject(19356, 1116.18, -1489.54, 22.89,   0.00, 90.00, 90.00);
	CreateDynamicObject(1408, 1115.03, -1487.85, 23.52,   20.00, 0.00, 180.00);
	CreateDynamicObject(7655, 1105.05, -1482.97, 25.54,   0.00, 0.00, 0.00);
	CreateDynamicObject(1568, 1124.33, -1482.98, 21.65,   0.00, 0.00, 0.00);
	CreateDynamicObject(1568, 1133.92, -1482.98, 21.65,   0.00, 0.00, 0.00);
	CreateDynamicObject(7655, 1153.17, -1482.97, 25.54,   0.00, 0.00, 0.00);
	CreateDynamicObject(1568, 1133.92, -1495.72, 21.65,   0.00, 0.00, 0.00);
	CreateDynamicObject(1568, 1124.33, -1495.72, 21.65,   0.00, 0.00, 0.00);
	CreateDynamicObject(7655, 1153.17, -1495.72, 25.54,   0.00, 0.00, 0.00);
	CreateDynamicObject(7655, 1105.05, -1497.04, 25.54,   0.00, 0.00, 4.00);
	CreateDynamicObject(7655, 1084.86, -1493.01, 26.33,   0.00, 0.00, 86.00);
	CreateDynamicObject(968, 1110.62, -1491.44, 21.81,   90.00, 0.00, 90.00);
	CreateDynamicObject(19356, 1113.86, -1489.54, 22.90,   0.00, 90.00, 90.00);
	CreateDynamicObject(19356, 1110.79, -1489.54, 23.48,   22.00, 90.00, 90.00);
	CreateDynamicObject(968, 1110.62, -1487.61, 21.81,   90.00, 0.00, 90.00);
	CreateDynamicObject(1408, 1115.03, -1491.28, 23.52,   20.00, 0.00, 0.00);
	CreateDynamicObject(1319, 1116.72, -1491.20, 22.34,   -20.00, 0.00, 0.00);
	CreateDynamicObject(1319, 1116.72, -1487.77, 22.34,   20.00, 0.00, 0.00);
	CreateDynamicObject(1319, 1112.72, -1491.20, 22.34,   -20.00, 0.00, 0.00);
	CreateDynamicObject(1319, 1112.72, -1487.77, 22.34,   20.00, 0.00, 0.00);
	CreateDynamicObject(1319, 1118.27, -1489.51, 22.84,   0.00, 90.00, 0.00);
	CreateDynamicObject(1319, 1119.35, -1489.51, 22.84,   0.00, 90.00, 0.00);
	CreateDynamicObject(1319, 1120.42, -1489.51, 22.84,   0.00, 90.00, 0.00);
	CreateDynamicObject(1319, 1121.50, -1489.51, 22.84,   0.00, 90.00, 0.00);
	CreateDynamicObject(1319, 1122.57, -1489.51, 22.84,   0.00, 90.00, 0.00);
	CreateDynamicObject(19315, 1118.87, -1489.99, 22.18,   0.00, 0.00, 0.00);
	CreateDynamicObject(19315, 1120.01, -1489.05, 22.18,   0.00, 0.00, 0.00);
	CreateDynamicObject(19315, 1121.05, -1489.05, 22.18,   0.00, 0.00, 0.00);
	CreateDynamicObject(19315, 1122.09, -1489.05, 22.18,   0.00, 0.00, 0.00);
	CreateDynamicObject(19315, 1123.13, -1489.05, 22.18,   0.00, 0.00, 0.00);
	CreateDynamicObject(19315, 1120.01, -1489.99, 22.18,   0.00, 0.00, 0.00);
	CreateDynamicObject(19315, 1121.05, -1489.99, 22.18,   0.00, 0.00, 0.00);
	CreateDynamicObject(19315, 1122.09, -1489.99, 22.18,   0.00, 0.00, 0.00);
	CreateDynamicObject(19315, 1123.13, -1489.99, 22.18,   0.00, 0.00, 0.00);
	CreateDynamicObject(2808, 1116.26, -1489.51, 23.53,   0.00, 0.00, -90.00);
	CreateDynamicObject(19058, 1114.74, -1490.07, 23.54,   0.00, 0.00, -33.00);
	CreateDynamicObject(19057, 1113.12, -1490.02, 23.56,   0.00, 0.00, 0.00);
	CreateDynamicObject(19056, 1113.94, -1488.77, 23.61,   0.00, 0.00, -14.00);
	CreateDynamicObject(19054, 1111.88, -1489.80, 23.84,   22.00, 0.00, 90.00);
	//ammunation road stuff
	CreateDynamicObject(7655, 1350.23, -1364.05, 17.72,   0.00, 0.00, 90.00);
	CreateDynamicObject(7655, 1350.23, -1312.55, 17.72,   0.00, 0.00, 90.00);
	CreateDynamicObject(19076, 1349.95, -1292.80, 11.80,   0.00, 0.00, 0.00);
	CreateDynamicObject(19076, 1350.13, -1332.41, 11.80,   0.00, 0.00, 90.00);
	CreateDynamicObject(19076, 1350.14, -1343.74, 11.80,   0.00, 0.00, 90.00);
	CreateDynamicObject(19076, 1350.27, -1383.82, 11.80,   0.00, 0.00, 0.00);
	//all saints tree
	CreateDynamicObject(19076, 1184.42, -1332.79, 12.24,   0.00, 0.00, 90.00);
	CreateDynamicObject(19057, 1184.96, -1331.61, 12.59,   0.00, 0.00, 0.00);
	CreateDynamicObject(19056, 1185.83, -1333.24, 13.09,   0.00, 0.00, -28.00);
	CreateDynamicObject(19058, 1184.55, -1334.83, 12.78,   0.00, 0.00, -6.00);
	CreateDynamicObject(19054, 1183.07, -1331.81, 13.00,   0.00, 0.00, 0.00);
	//pershing square tree
	CreateDynamicObject(19076, 1478.66, -1664.61, 13.09,   0.00, 0.00, 0.00);
	//LS Mall - Dylan
	retexture = CreateDynamicObject(1946, 1157.37427, -1414.75061, 13.67200,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(1946, 1157.37427, -1414.75061, 13.07200,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(1946, 1157.37427, -1414.75061, 13.32200,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(1946, 1160.37427, -1413.75061, 13.57200,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(1946, 1160.37427, -1413.75061, 12.97200,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(1946, 1160.37427, -1413.75061, 13.22200,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(16305, 1159.37427, -1418.17139, 14.01868,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(1946, 1084.17480, -1417.91516, 13.67200,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(1946, 1073.22949, -1430.46252, 12.82200,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(1946, 1084.17480, -1417.91516, 13.32200,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(1946, 1084.17480, -1417.91516, 13.07200,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(1946, 1073.22949, -1430.46252, 13.07200,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(1946, 1073.22949, -1430.46252, 13.42200,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(16305, 1085.43018, -1422.64453, 14.20050,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(16305, 1078.31470, -1432.88306, 14.14650,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	CreateDynamicObject(19352, 1084.21484, -1417.89514, 13.85900,   0.00000, 15.00000, 0.00000);
	CreateDynamicObject(1932, 1084.17480, -1417.76526, 13.64390,   90.00000, 0.00000, 180.00000);
	CreateDynamicObject(19350, 1084.18079, -1417.70520, 13.57520,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19351, 1073.03601, -1430.43347, 13.31520,   270.00000, 0.00000, 0.00000);
	CreateDynamicObject(1932, 1073.09949, -1430.43250, 13.39390,   90.00000, 0.00000, 270.00000);
	CreateDynamicObject(1930, 1073.14954, -1430.36255, 13.47210,   0.00000, 90.00000, 180.00000);
	CreateDynamicObject(1930, 1073.14954, -1430.46252, 13.47210,   0.00000, 90.00000, 180.00000);
	CreateDynamicObject(1940, 1084.22485, -1417.81519, 13.71710,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(1940, 1084.15479, -1417.81519, 13.71710,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(18946, 1073.21948, -1430.45654, 13.65040,   350.00000, 270.00000, 90.00000);
	CreateDynamicObject(19352, 1157.42432, -1414.74060, 13.85900,   0.00000, 15.00000, 0.00000);
	CreateDynamicObject(1932, 1157.37427, -1414.59753, 13.64390,   90.00000, 0.00000, 180.00000);
	CreateDynamicObject(19350, 1157.37427, -1414.53601, 13.57520,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19351, 1160.37427, -1413.53601, 13.47520,   270.00000, 0.00000, 90.00000);
	CreateDynamicObject(1932, 1160.37427, -1413.59753, 13.54390,   90.00000, 0.00000, 180.00000);
	CreateDynamicObject(18962, 1160.36426, -1413.76257, 13.80440,   0.00000, 270.00000, 0.00000);
	CreateDynamicObject(1930, 1160.32434, -1413.67273, 13.62210,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(1930, 1160.46436, -1413.66467, 13.62210,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(1940, 1157.46826, -1414.65747, 13.71710,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(1940, 1157.32825, -1414.65747, 13.71710,   0.00000, 90.00000, 90.00000);
	//LSPD 
	retexture = CreateDynamicObject(19447, 1543.35205, -1710.65002, 12.89500,   0.00000, 90.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(19447, 1543.35205, -1705.00000, 12.89500,   0.00000, 90.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(19447, 1541.19202, -1710.65002, 12.89750,   0.00000, 90.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(19447, 1541.19202, -1705.00000, 12.90250,   0.00000, 90.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(19428, 1547.77161, -1694.57886, 12.83750,   0.00000, 90.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(19428, 1545.66760, -1694.57886, 12.84050,   0.00000, 90.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(19447, 1547.77161, -1689.34875, 12.84250,   0.00000, 90.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(19447, 1545.83765, -1660.84875, 12.83750,   0.00000, 90.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(19428, 1543.11206, -1650.04590, 12.90000,   0.00000, 90.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(19428, 1547.59155, -1665.67078, 12.83750,   0.00000, 90.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(19428, 1545.83765, -1665.67078, 12.84050,   0.00000, 90.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(19447, 1545.66760, -1689.34875, 12.83750,   0.00000, 90.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(19447, 1541.43201, -1646.03076, 12.90250,   0.00000, 90.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(19447, 1547.59155, -1660.84875, 12.84250,   0.00000, 90.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(19447, 1541.43201, -1641.15076, 12.89750,   0.00000, 90.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(19428, 1543.11865, -1637.13525, 12.89500,   0.00000, 90.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(1946, 1541.45313, -1707.14063, 13.65890,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(1946, 1541.45313, -1707.14063, 13.05890,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(1946, 1541.45313, -1707.14063, 13.30890,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(1946, 1544.79749, -1661.03125, 13.65890,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(1946, 1544.79749, -1661.03125, 13.30890,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(1946, 1544.79749, -1661.03125, 13.05890,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(1946, 1541.45313, -1644.36548, 13.65890,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(1946, 1541.45313, -1644.36548, 13.30890,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(1946, 1541.45313, -1644.36548, 13.05890,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(1946, 1544.79749, -1689.98438, 13.65890,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(1946, 1544.79749, -1689.98438, 13.30890,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	retexture = CreateDynamicObject(1946, 1544.79749, -1689.98438, 13.05890,   0.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(retexture, 0, 3916, "libertyhi4", "mp_snow");
	CreateDynamicObject(1932, 1544.63794, -1689.98438, 13.65890,   0.00000, 90.00000, 180.00000);
	CreateDynamicObject(1933, 1544.70874, -1690.03442, 13.70890,   0.00000, 90.00000, 180.00000);
	CreateDynamicObject(1933, 1544.70874, -1689.93445, 13.70890,   0.00000, 90.00000, 180.00000);
	CreateDynamicObject(19099, 1544.79749, -1689.98438, 13.90170,   0.00000, 270.00000, 90.00000);
	CreateDynamicObject(19351, 1544.60596, -1689.99438, 13.57140,   270.00000, 0.00000, 0.00000);
	CreateDynamicObject(19099, 1544.79749, -1661.03125, 13.90170,   0.00000, 270.00000, 90.00000);
	CreateDynamicObject(1933, 1544.70874, -1660.98132, 13.70890,   0.00000, 90.00000, 180.00000);
	CreateDynamicObject(1933, 1544.70874, -1661.08130, 13.70890,   0.00000, 90.00000, 180.00000);
	CreateDynamicObject(1932, 1544.63794, -1661.03125, 13.65890,   0.00000, 90.00000, 180.00000);
	CreateDynamicObject(19351, 1544.60596, -1661.05127, 13.57140,   270.00000, 0.00000, 0.00000);
	CreateDynamicObject(1933, 1541.36316, -1644.31555, 13.70890,   0.00000, 90.00000, 180.00000);
	CreateDynamicObject(1933, 1541.36316, -1644.41553, 13.70890,   0.00000, 90.00000, 180.00000);
	CreateDynamicObject(1932, 1541.30322, -1644.36548, 13.65890,   0.00000, 90.00000, 180.00000);
	CreateDynamicObject(19350, 1541.26343, -1644.37549, 13.59810,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19521, 1541.42310, -1644.36548, 13.89260,   340.00000, 270.00000, 90.00000);
	CreateDynamicObject(19521, 1541.42310, -1707.14063, 13.89260,   340.00000, 270.00000, 90.00000);
	CreateDynamicObject(1933, 1541.36316, -1707.09058, 13.70890,   0.00000, 90.00000, 180.00000);
	CreateDynamicObject(1933, 1541.36316, -1707.19055, 13.70890,   0.00000, 90.00000, 180.00000);
	CreateDynamicObject(1932, 1541.30322, -1707.14063, 13.65890,   0.00000, 90.00000, 180.00000);
	CreateDynamicObject(19350, 1541.26343, -1707.15454, 13.59810,   90.00000, 0.00000, 0.00000);
	
	return 1;
}

hook OnGameModeExit()
{
	SaveSecretSanta();
	return 1;
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{	
	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
	{
		if(GetPVarInt(playerid, "SantaHat"))
		{
			print("SantaHat on when getting in car..");
			defer WearSantaHat(playerid);
		}
	}
	return 1;
}

timer WearSantaHat[750](playerid)
{
	new idx = GetPVarInt(playerid, "SantaHatIDX");
	SetPlayerAttachedObject(playerid, idx, 19065, 2, 0.120000, 0.040000, -0.003500, 0, 100, 100, 1.4, 1.4, 1.4);	
}

static stock SaveSecretSanta()
{
	if(!fexist(SSFilePath))
		dini_Create(SSFilePath);
		
	dini_IntSet(SSFilePath, "SSCash", SecretSantaCash);
	dini_IntSet(SSFilePath, "SSMats", SecretSantaMats[0]);
	dini_IntSet(SSFilePath, "SSMats1", SecretSantaMats[1]);
	dini_IntSet(SSFilePath, "SSMats2", SecretSantaMats[2]);
	dini_IntSet(SSFilePath, "SSCocaine", SecretSantaCocaine);
	dini_IntSet(SSFilePath, "SSPot", SecretSantaPot);
	dini_IntSet(SSFilePath, "SSSpeed", SecretSantaSpeed);
	printf("[CHRISTMAS] Secret santa saved.");
	return 1;
}

static stock LoadSecretSanta()
{
	if(!fexist(SSFilePath))
		dini_Create(SSFilePath);
	
	SecretSantaCash = dini_Int(SSFilePath, "SSCash");
	SecretSantaMats[0] = dini_Int(SSFilePath, "SSMats");
	SecretSantaMats[1] = dini_Int(SSFilePath, "SSMats1");
	SecretSantaMats[2] = dini_Int(SSFilePath, "SSMats2");
	SecretSantaCocaine = dini_Int(SSFilePath, "SSCocaine");
	SecretSantaPot = dini_Int(SSFilePath, "SSPot");
	SecretSantaSpeed = dini_Int(SSFilePath, "SSSpeed");
	printf("[CHRISTMAS] Secret santa loaded.");
	return 1;
}

static stock IsChristmas()
{
	new month, day, year;
	getdate(year, month, day);
	
	if(month == 12)
	{
		switch(day)
		{
			case 25..30: return 1;
		}
	}
	else if(month == 1) //Sarge wanted this to last until new years
	{
		switch(day)
		{
			case 1: return 1;
		}
	}
	
	return 0;
}

static stock HoursSinceLastDeposit(playerid)
	return Player[playerid][PlayingHours] - Player[playerid][LastDepositHours];

static stock HoursSinceLastRedeem(playerid)
	return Player[playerid][PlayingHours] - Player[playerid][LastRedeemHours];

CMD:secretsantaredeem(playerid, params[])
{
	if(Player[playerid][PlayingHours] < MinHours)
		return SendClientMessage(playerid, -1, "You need "#MinHours" playing hours to participate in secret santa!");
	
	if(HoursSinceLastRedeem(playerid) < SSRedeemCooldown)
		return SendClientMessage(playerid, -1, "You must wait at least "#SSRedeemCooldown" hours between withdrawing.");
	
	if(!IsPlayerInRangeOfPoint(playerid, 10, SSPosX, SSPosY, SSPosZ))
		return SendClientMessage(playerid, -1, "You are not near the secret santa location!");
	
	if(Player[playerid][TotalSSDeposits] < 1)
		return SendClientMessage(playerid, -1, "You must have deposited something at least once to redeem a prize!");
	
	if(!IsChristmas())
		return SendClientMessage(playerid, -1, "You can only redeem on Christmas!!");
	
	new string[128], prize = 0;
	switch(random(100))
	{
		case 0..19: //Money
		{
			switch(random(100))
			{ 
				case 1..9: prize = 500; //10 percent
				case 10..19: prize = 1000; //10 percent
				case 20..29: prize = 1500; //10 percent
				case 30..44: prize = 2000;	//14 percent
				case 45..54: prize = 2500; //10 percent
				case 55..74: prize = 3000; //20 percent
				
				case 80..86: prize = 8000; //7 percent
				case 87..91: prize = 8500; // 5 percent
				case 92..95: prize = 9000; // 4 percent
				case 96..98: prize = 9500; // 3 percent
				case 0, 99: prize = 10000; // 2 percent
				default: prize = 5000; // 6 percent
			}
			
			if(prize == 0)
				prize = 3000; // Just in-case
				
			if(prize > SecretSantaCash)
				prize = SecretSantaCash;
			
			if(prize == 0)
				return SendClientMessage(playerid, -1, "We have run out of the prize you won! You can try again without having to wait!");
			
			Player[playerid][Money] += prize;
			SecretSantaCash -= prize;
			format(string, sizeof(string), "Congratulations! You have won %s from the secret santa! You can redeem another prize in %d hours!", PrettyMoney(prize), SSRedeemCooldown);
			SendClientMessage(playerid, -1, string);
			format(string, sizeof(string), "[SecretSanta] %s has won %s.", GetName(playerid), PrettyMoney(prize));
			StatLog(string);
			Player[playerid][LastRedeemHours] = Player[playerid][PlayingHours];
		}
		case 20..39: //Pot
		{
			switch(random(100))
			{ 
				case 0..9: prize = 5; //10 percent
				case 10..19: prize = 10; //10 percent
				case 20..29: prize = 15; //10 percent
				case 30..44: prize = 20;	//14 percent
				case 45..54: prize = 25; //10 percent
				case 55..74: prize = 30; //20 percent
				
				case 80..86: prize = 80; //7 percent
				case 87..91: prize = 85; // 5 percent
				case 92..95: prize = 90; // 4 percent
				case 96..98: prize = 95; // 3 percent
				case 99: prize = 100; // 1 percent
				default: prize = 50; // 6 percent
			}
			
			if(prize == 0)
				prize = 30; 
				
			if(prize > SecretSantaPot)
				prize = SecretSantaPot;
				
			if(prize == 0)
				return SendClientMessage(playerid, -1, "We have run out of the prize you won! You can try again without having to wait!");
				
			Player[playerid][Pot] += prize;
			SecretSantaPot -= prize;
			
			format(string, sizeof(string), "Congratulations! You have won %d grams of weed from the secret santa! You can redeem another prize in %d hours!", prize, SSRedeemCooldown);
			SendClientMessage(playerid, -1, string);
			format(string, sizeof(string), "[SecretSanta] %s has won %d grams of weed.", GetName(playerid), prize);
			StatLog(string);
			Player[playerid][LastRedeemHours] = Player[playerid][PlayingHours];
		}
		case 40..59: //Speed
		{
			switch(random(100))
			{ 
				case 0..9: prize = 5; //10 percent
				case 10..19: prize = 10; //10 percent
				case 20..29: prize = 15; //10 percent
				case 30..44: prize = 20;	//14 percent
				case 45..54: prize = 25; //10 percent
				case 55..74: prize = 30; //20 percent
				
				case 80..86: prize = 80; //7 percent
				case 87..91: prize = 85; // 5 percent
				case 92..95: prize = 90; // 4 percent
				case 96..98: prize = 95; // 3 percent
				case 99: prize = 100; // 1 percent
				default: prize = 50; // 6 percent
			}
			
			if(prize == 0)
				prize = 30; 
				
			if(prize > SecretSantaSpeed)
				prize = SecretSantaSpeed;
			
			if(prize == 0)
				return SendClientMessage(playerid, -1, "We have run out of the prize you won! You can try again without having to wait!");
			
			Player[playerid][Speed] += prize;
			SecretSantaSpeed -= prize;
			
			format(string, sizeof(string), "Congratulations! You have won %d grams of speed from the secret santa! You can redeem another prize in %d hours!", prize, SSRedeemCooldown);
			SendClientMessage(playerid, -1, string);
			format(string, sizeof(string), "[SecretSanta] %s has won %d grams of speed.", GetName(playerid), prize);
			StatLog(string);
			Player[playerid][LastRedeemHours] = Player[playerid][PlayingHours];
		}
		case 60..79: //Cocaine
		{
			switch(random(100))
			{ 
				case 0..9: prize = 5; //10 percent
				case 10..19: prize = 10; //10 percent
				case 20..29: prize = 15; //10 percent
				case 30..44: prize = 20;	//14 percent
				case 45..54: prize = 25; //10 percent
				case 55..74: prize = 30; //20 percent
				
				case 80..86: prize = 80; //7 percent
				case 87..91: prize = 85; // 5 percent
				case 92..95: prize = 90; // 4 percent
				case 96..98: prize = 95; // 3 percent
				case 99: prize = 100; // 1 percent
				default: prize = 50; // 6 percent
			}
			
			if(prize == 0)
				prize = 30; 
				
			if(prize > SecretSantaCocaine)
				prize = SecretSantaCocaine;
			
			if(prize == 0)
				return SendClientMessage(playerid, -1, "We have run out of the prize you won! You can try again without having to wait!");
			
			Player[playerid][Cocaine] += prize;
			SecretSantaCocaine -= prize;
			
			format(string, sizeof(string), "Congratulations! You have won %d grams of cocaine from the secret santa! You can redeem another prize in %d hours!", prize, SSRedeemCooldown);
			SendClientMessage(playerid, -1, string);
			format(string, sizeof(string), "[SecretSanta] %s has won %d grams of cocaine.", GetName(playerid), prize);
			StatLog(string);
			Player[playerid][LastRedeemHours] = Player[playerid][PlayingHours];
		}
		case 80..99: //Mats
		{
			switch(random(100))
			{ 
				case 0..9: prize = 50; //10 percent
				case 10..19: prize = 100; //10 percent
				case 20..29: prize = 150; //10 percent
				case 30..44: prize = 200;	//14 percent
				case 45..54: prize = 250; //10 percent
				case 55..74: prize = 300; //20 percent
				
				case 80..86: prize = 800; //7 percent
				case 87..91: prize = 850; // 5 percent
				case 92..95: prize = 900; // 4 percent
				case 96..98: prize = 950; // 3 percent
				case 99: prize = 1000; // 1 percent
				default: prize = 500; // 6 percent
			}
			
			new mat_grade = random(3);
			
			if(prize == 0)
				prize = 300; 
				
			if(prize > SecretSantaMats[mat_grade])
				prize = SecretSantaMats[mat_grade];
				
			if(prize == 0)
				return SendClientMessage(playerid, -1, "We have run out of the prize you won! You can try again without having to wait!");
				
			Player[playerid][Materials][mat_grade] += prize;
			SecretSantaMats[mat_grade] -= prize;
			switch(mat_grade)
			{
				case 0: format(string, sizeof(string), "Congratulations! You have won %d street mats from the secret santa! You can redeem another prize in %d hours!", prize, SSRedeemCooldown);
				case 1: format(string, sizeof(string), "Congratulations! You have won %d standard mats from the secret santa! You can redeem another prize in %d hours!", prize, SSRedeemCooldown);
				case 2: format(string, sizeof(string), "Congratulations! You have won %d military mats from the secret santa! You can redeem another prize in %d hours!", prize, SSRedeemCooldown);
			}
			SendClientMessage(playerid, -1, string);
			switch(mat_grade)
			{
				case 0: format(string, sizeof(string), "[SecretSanta] %s has won %d street mats.", GetName(playerid), prize);
				case 1: format(string, sizeof(string), "[SecretSanta] %s has won %d standard mats.", GetName(playerid), prize);
				case 2: format(string, sizeof(string), "[SecretSanta] %s has won %d military mats.", GetName(playerid), prize);
			}
			StatLog(string);
			Player[playerid][LastRedeemHours] = Player[playerid][PlayingHours];
		}
	}
	return 1;
}

CMD:secretsantadeposit(playerid, params[])
{
	if(Player[playerid][PlayingHours] < MinHours)
		return SendClientMessage(playerid, -1, "You need "#MinHours" playing hours to participate in secret santa!");
		
	if(HoursSinceLastDeposit(playerid) < SSDepositCooldown)
		return SendClientMessage(playerid, -1, "You must wait at least "#SSDepositCooldown" hours between deposits.");
		
	if(!IsPlayerInRangeOfPoint(playerid, 10, SSPosX, SSPosY, SSPosZ))
		return SendClientMessage(playerid, -1, "You are not near the secret santa location!");
	
	new string[128], option[32], amount;
	
	if(sscanf(params, "s[32]d", option, amount))
	{
		SendClientMessage(playerid, -1, "SYNTAX: /secretsantadeposit [option] [amount]");
		return SendClientMessage(playerid, -1, "Options: Money, Pot, Speed, Cocaine, streetmats, standardmats, militarymats");
	}
	
	if(amount < 1)
		return SendClientMessage(playerid, -1, "You can't deposit nothing or a negative amount!");
	
	if(!strcmp(option, "Money", true))
	{
		if(amount < MinCash)
			return SendClientMessage(playerid, -1, "You need to deposit at least $"#MinCash);
			
		if(Player[playerid][Money] < amount)
			return SendClientMessage(playerid, -1, "You don't have that much money!");
		
		SecretSantaCash += amount;
		Player[playerid][Money] -= amount;
		Player[playerid][TotalSSDeposits] ++;
		Player[playerid][LastDepositHours] = Player[playerid][PlayingHours];
		format(string, sizeof(string), "You have deposited %s into the secret santa pot!", PrettyMoney(amount));
		SendClientMessage(playerid, -1, string);
		SendClientMessage(playerid, -1, "Remember you can deposit something every 5 playing hours!!!");
		format(string, sizeof(string), "[SecretSanta] %s has deposited %s into the pot. (Pot = %s)", GetName(playerid), PrettyMoney(amount), PrettyMoney(SecretSantaCash));
		StatLog(string);
	}
	else if(!strcmp(option, "pot", true))
	{
		if(amount < MinPot)
			return SendClientMessage(playerid, -1, "You need to deposit at least "#MinCash" pot.");
			
		if(Player[playerid][Pot] < amount)
			return SendClientMessage(playerid, -1, "You don't have that much pot!");
		
		SecretSantaPot += amount;
		Player[playerid][Pot] -= amount;
		Player[playerid][TotalSSDeposits] ++;
		Player[playerid][LastDepositHours] = Player[playerid][PlayingHours];
		format(string, sizeof(string), "You have deposited %d grams of weed into the secret santa pot!", amount);
		SendClientMessage(playerid, -1, string);
		SendClientMessage(playerid, -1, "Remember you can deposit something every 5 playing hours!!!");
		format(string, sizeof(string), "[SecretSanta] %s has deposited %s grams of weed into the pot. (Pot = %d grams)", GetName(playerid), amount, SecretSantaPot );
		StatLog(string);
	}
	else if(!strcmp(option, "speed", true))
	{
		if(amount < MinSpeed)
			return SendClientMessage(playerid, -1, "You need to deposit at least "#MinSpeed" speed.");
			
		if(Player[playerid][Speed] < amount)
			return SendClientMessage(playerid, -1, "You don't have that much speed!");
			
		SecretSantaSpeed += amount;
		Player[playerid][Speed] -= amount;
		Player[playerid][TotalSSDeposits] ++;
		Player[playerid][LastDepositHours] = Player[playerid][PlayingHours];
		format(string, sizeof(string), "You have deposited %d grams of speed into the secret santa pot!", amount);
		SendClientMessage(playerid, -1, string);
		SendClientMessage(playerid, -1, "Remember you can deposit something every 5 playing hours!!!");
		format(string, sizeof(string), "[SecretSanta] %s has deposited %s grams of speed into the pot. (Pot = %d grams)", GetName(playerid), amount, SecretSantaSpeed);
		StatLog(string);
	}
	else if(!strcmp(option, "cocaine", true))
	{
		if(amount < MinCocaine)
			return SendClientMessage(playerid, -1, "You need to deposit at least "#MinCocaine" cocaine.");
			
		if(Player[playerid][Cocaine] < amount)
			return SendClientMessage(playerid, -1, "You don't have that much cocaine!");
			
		SecretSantaCocaine += amount;
		Player[playerid][Cocaine] -= amount;
		Player[playerid][TotalSSDeposits] ++;
		Player[playerid][LastDepositHours] = Player[playerid][PlayingHours];
		format(string, sizeof(string), "You have deposited %d grams of cocaine into the secret santa pot!", amount);
		SendClientMessage(playerid, -1, string);
		SendClientMessage(playerid, -1, "Remember you can deposit something every 5 playing hours!!!");
		format(string, sizeof(string), "[SecretSanta] %s has deposited %s grams of cocaine into the pot. (Pot = %d grams)", GetName(playerid), amount, SecretSantaCocaine);
		StatLog(string);
	}
	else if(!strcmp(option, "StreetMats", true))
	{
		if(amount < MinMats)
			return SendClientMessage(playerid, -1, "You need to deposit at least "#MinMats" mats.");
			
		if(Player[playerid][Materials][0] < amount)
			return SendClientMessage(playerid, -1, "You don't have that many mats!");
			
		SecretSantaMats[0] += amount;
		Player[playerid][Materials][0] -= amount;
		Player[playerid][TotalSSDeposits] ++;
		Player[playerid][LastDepositHours] = Player[playerid][PlayingHours];
		format(string, sizeof(string), "You have deposited %d street mats into the secret santa pot!", amount);
		SendClientMessage(playerid, -1, string);
		SendClientMessage(playerid, -1, "Remember you can deposit something every 5 playing hours!!!");
		format(string, sizeof(string), "[SecretSanta] %s has deposited %s street mats into the pot. (Pot = %d mats)", GetName(playerid), amount, SecretSantaMats[0]);
		StatLog(string);
	}
	else if(!strcmp(option, "StandardMats", true))
	{
		if(amount < MinMats)
			return SendClientMessage(playerid, -1, "You need to deposit at least "#MinMats" mats.");
			
		if(Player[playerid][Materials][1] < amount)
			return SendClientMessage(playerid, -1, "You don't have that many mats!");
			
		SecretSantaMats[1] += amount;
		Player[playerid][Materials][1] -= amount;
		Player[playerid][TotalSSDeposits] ++;
		Player[playerid][LastDepositHours] = Player[playerid][PlayingHours];
		format(string, sizeof(string), "You have deposited %d street mats into the secret santa pot!", amount);
		SendClientMessage(playerid, -1, string);
		SendClientMessage(playerid, -1, "Remember you can deposit something every 5 playing hours!!!");
		format(string, sizeof(string), "[SecretSanta] %s has deposited %s standard mats into the pot. (Pot = %d mats)", GetName(playerid), amount, SecretSantaMats[1]);
		StatLog(string);
	}
	else if(!strcmp(option, "MilitaryMats", true))
	{
		if(amount < MinMats)
			return SendClientMessage(playerid, -1, "You need to deposit at least "#MinMats" mats.");
			
		if(Player[playerid][Materials][2] < amount)
			return SendClientMessage(playerid, -1, "You don't have that many mats!");
			
		SecretSantaMats[2] += amount;
		Player[playerid][Materials][2] -= amount;
		Player[playerid][TotalSSDeposits] ++;
		Player[playerid][LastDepositHours] = Player[playerid][PlayingHours];
		format(string, sizeof(string), "You have deposited %d street mats into the secret santa pot!", amount);
		SendClientMessage(playerid, -1, string);
		SendClientMessage(playerid, -1, "Remember you can deposit something every 5 playing hours!!!");
		format(string, sizeof(string), "[SecretSanta] %s has deposited %s military mats into the pot. (Pot = %d mats)", GetName(playerid), amount, SecretSantaMats[2]);
		StatLog(string);
	}
	else return SendClientMessage(playerid, -1, "Invalid option!");
	
	return 1;
}

CMD:checksecretsanta(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 2)
		return 1;
		
	new string[128];
	SendClientMessage(playerid, -1, "-------------------------------------------------------------");
	format(string, sizeof(string), "Money: %s", PrettyMoney(SecretSantaCash));
	SendClientMessage(playerid, -1, string);
	format(string, sizeof(string), "Street Materials: %d", SecretSantaMats[0]);
	SendClientMessage(playerid, -1, string);
	format(string, sizeof(string), "Standard Materials: %d", SecretSantaMats[1]);
	SendClientMessage(playerid, -1, string);
	format(string, sizeof(string), "Military Materials: %d", SecretSantaMats[2]);
	SendClientMessage(playerid, -1, string);
	format(string, sizeof(string), "Pot: %d", SecretSantaPot);
	SendClientMessage(playerid, -1, string);
	format(string, sizeof(string), "Cocaine: %d", SecretSantaCocaine);
	SendClientMessage(playerid, -1, string);
	format(string, sizeof(string), "Speed: %d", SecretSantaSpeed);
	SendClientMessage(playerid, -1, string);
	SendClientMessage(playerid, -1, "-------------------------------------------------------------");
	return 1;
}	

CMD:setsecretsanta(playerid, params[])
{
	if(Player[playerid][AdminLevel] < 5)
		return 1;
		
	new string[128], option[32], amount;
	
	if(sscanf(params, "s[32]d", option, amount))
	{
		SendClientMessage(playerid, -1, "SYNTAX: /setsecretsanta [option] [amount]");
		return SendClientMessage(playerid, -1, "Options: Money, Pot, Speed, Cocaine, StreetMats, StandardMats, MilitaryMats");
	}
	
	if(amount < 0)
		return SendClientMessage(playerid, -1, "Invalid amount.");
	
	if(!strcmp(option, "Money", true))
	{
		SecretSantaCash = amount;
		format(string, sizeof(string), "You have set the secret santa cash to %s.", PrettyMoney(amount));
		SendClientMessage(playerid, -1, string);
		format(string, sizeof(string), "[SecretSanta] %s has set the santa cash to %s.", Player[playerid][AdminName], PrettyMoney(amount));
		StatLog(string);
	}
	else if(!strcmp(option, "Pot", true))
	{
		SecretSantaPot = amount;
		format(string, sizeof(string), "You have set the secret santa pot to %d.", amount);
		SendClientMessage(playerid, -1, string);
		format(string, sizeof(string), "[SecretSanta] %s has set the santa pot to %d.", Player[playerid][AdminName], amount);
		StatLog(string);
	}
	else if(!strcmp(option, "Speed", true))
	{
		SecretSantaSpeed = amount;
		format(string, sizeof(string), "You have set the secret santa Speed to %d.", amount);
		SendClientMessage(playerid, -1, string);
		format(string, sizeof(string), "[SecretSanta] %s has set the santa Speed to %d.", Player[playerid][AdminName], amount);
		StatLog(string);
	}
	else if(!strcmp(option, "Cocaine", true))
	{
		SecretSantaCocaine = amount;
		format(string, sizeof(string), "You have set the secret santa Cocaine to %d.", amount);
		SendClientMessage(playerid, -1, string);
		format(string, sizeof(string), "[SecretSanta] %s has set the santa Cocaine to %d.", Player[playerid][AdminName], amount);
		StatLog(string);
	}
	else if(!strcmp(option, "StreetMats", true))
	{
		SecretSantaMats[0] = amount;
		format(string, sizeof(string), "You have set the secret santa street mats to %d.", amount);
		SendClientMessage(playerid, -1, string);
		format(string, sizeof(string), "[SecretSanta] %s has set the santa street mats to %d.", Player[playerid][AdminName], amount);
		StatLog(string);
	}
	else if(!strcmp(option, "StandardMats", true))
	{
		SecretSantaMats[1] = amount;
		format(string, sizeof(string), "You have set the secret santa standard mats to %d.", amount);
		SendClientMessage(playerid, -1, string);
		format(string, sizeof(string), "[SecretSanta] %s has set the santa standard mats to %d.", Player[playerid][AdminName], amount);
		StatLog(string);
	}
	else if(!strcmp(option, "militaryMats", true))
	{
		SecretSantaMats[2] = amount;
		format(string, sizeof(string), "You have set the secret santa military mats to %d.", amount);
		SendClientMessage(playerid, -1, string);
		format(string, sizeof(string), "[SecretSanta] %s has set the santa military mats to %d.", Player[playerid][AdminName], amount);
		StatLog(string);
	}
	else return SendClientMessage(playerid, -1, "Invalid option!");
	
	return 1;
}

CMD:santahat(playerid, params[])
{
	if(Player[playerid][VipRank] < 1)
		return 1;
	
	switch(GetPVarInt(playerid, "SantaHat"))
	{
		case 0:
		{
			new idx = GetEmptySlotAttachment(playerid);
			if(idx == -1)
				return SendClientMessage(playerid, -1, "You don't have any more slots for an attachment!");
			SetPlayerAttachedObject(playerid, idx, 19065, 2, 0.120000, 0.040000, -0.003500, 0, 100, 100, 1.4, 1.4, 1.4);
			SetPVarInt(playerid, "SantaHatIDX", idx);
			SetPVarInt(playerid, "SantaHat", 1);
			SendClientMessage(playerid, -1, "You are now wearing a santa hat!");
		}
		default:
		{
			RemovePlayerAttachedObject(playerid, GetPVarInt(playerid, "SantaHatIDX"));
			DeletePVar(playerid, "SantaHatIDX");
			DeletePVar(playerid, "SantaHat");
			SendClientMessage(playerid, -1, "You are no longer wearing a santa hat!");
		}
	}
	return 1;
}

#endif 