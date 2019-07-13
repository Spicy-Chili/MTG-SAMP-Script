/*
 *
 *	MT-Gaming Interior Menu
 *	--	Version 1.01
 *
 */
#include <a_samp>
#include <zcmd>

#define DEBUG 				0x88AA62FF

#define MAIN 							000
#define HOUSES 							100
#define BUSINESSES		 				200
#define DEPARTMENTS						300
#define NOCATEGORY		 				400
#define WORLDLOCATIONS	 				500

enum InteriorInfo
{
	Name[32],
	Category[32],
	Type[32],
	Float:X,
	Float:Y,
	Float:Z,
	Interior,
};

new InteriorMenu[][InteriorInfo] = // {"Name", "Category", "Type", X, Y, Z, Int}
{
	//////////////////////////////////////////////////////////////////////////
	/*								HOUSES									*/
	//////////////////////////////////////////////////////////////////////////
	{"Denise's Bedroom", "Houses", "Girlfriends", 245.2307, 304.7632, 999.1484, 1},							//Girlfriends
	{"Helena's Barn", "Houses", "Girlfriends", 290.623, 309.0622, 999.1484, 3},
	{"Barbara's Lovenest", "Houses", "Girlfriends", 322.5014, 303.6906, 999.1484, 5},
	{"Katie's Lovenest", "Houses", "Girlfriends", 269.6405, 305.9512, 999.1484, 2},
	{"Michelle's Lovenest", "Houses", "Girlfriends", 306.1966, 307.819, 1003.3047, 4},
	{"Millie's Bedroom", "Houses", "Girlfriends", 344.9984, 307.1824, 999.1557, 6},
	
	{"Burglary House (1)", "Houses", "One Story", 225.5707, 1240.0643, 1082.1406, 2},						//One Story
	{"Burglary House (2)", "Houses", "One Story", 224.288, 1289.1907, 1082.1406, 1},
	{"Burglary House (3)", "Houses", "One Story", 295.1391, 1473.3719, 1080.2578, 15},
	{"Burglary House (4)", "Houses", "One Story", 22.861, 1404.9165, 1084.4297, 5},
	{"Burglary House (5)", "Houses", "One Story", -68.5145, 1353.8485, 1080.2109, 6},
	{"Burglary House (6)", "Houses", "One Story", -42.5267, 1408.23, 1084.4297, 8},
	{"Burglary House (7)", "Houses", "One Story", 260.7421, 1238.2261, 1084.2578, 9},
	{"Burglary House (8)", "Houses", "One Story", 447.0000, 1400.3000, 1084.3047, 2},
	{"Burglary House (9)", "Houses", "One Story", 261.1165, 1287.2197, 1080.2578, 4},
	{"Burglary House (10)", "Houses", "One Story", 327.8, 1479.7, 1085.0, 15},
	{"Burglary House (11)", "Houses", "One Story", 375.6, 1417.4, 1082.0, 15},
	{"Burglary House (12)", "Houses", "One Story", 384.6, 1471.5, 1081.0, 15},
	{"Safe House (1)", "Houses", "One Story", 2233.6919, -1112.8107, 1050.8828, 5},
	{"Safe House (2)", "Houses", "One Story", 2194.7900, -1204.3500, 1049.0234, 6},
	{"Safe House (3)", "Houses", "One Story", 2262.4797,-1138.5591,1050.63285, 10},
	{"Safe House (4)", "Houses", "One Story", 2333.0, -1075.0, 1049.0, 6},
	{"Safe House (5)", "Houses", "One Story", 2309.0, -1211.0, 1049.0, 6},
	{"Safe House (6)", "Houses", "One Story", 2237.6, -1079.0, 1049.0, 2},
	{"Verdant Bluff Safehouse", "Houses", "One Story", 2365.1089, -1133.0795, 1050.875, 8},
	{"Willowfield Safehouse", "Houses", "One Story", 2282.9099, -1138.2900, 1050.8984, 11},
	{"Camel Toe's Safehouse", "Houses", "One Story", 2216.1282, -1076.3052, 1050.4844, 1},
	{"Ryder's House", "Houses", "One Story", 2447.8704, -1704.4509, 1013.5078, 2},
	
	{"Burglary House (#1)", "Houses", "Two Story", 234.6087, 1187.8195, 1080.2578, 3},						//Two Story
	{"Burglary House (#2)", "Houses", "Two Story", 239.2819, 1114.1991, 1080.9922, 5},
	{"Burglary House (#3)", "Houses", "Two Story", 24.3769, 1341.1829, 1084.375, 10},
	{"Burglary House (#4)", "Houses", "Two Story", -262.1759, 1456.6158, 1084.36728, 4},
	{"Burglary House (#5)", "Houses", "Two Story", 140.3679, 1367.8837, 1083.8621, 5},
	{"Burglary House (#6)", "Houses", "Two Story", 234.2826, 1065.229, 1084.2101, 6},
	{"Burglary House (#7)", "Houses", "Two Story", -285.2511, 1471.197, 1084.375, 15},
	{"Burglary House (#8)", "Houses", "Two Story", 84.9244, 1324.2983, 1083.8594, 9},
	{"Burglary House (#9)", "Houses", "Two Story", 225.7, 1023.0, 1084.0, 7},
	{"CJ's House", "Houses", "Two Story", 2496.0549, -1695.1749, 1014.7422, 3},
	{"Safe House", "Houses", "Two Story", 2319.1272, -1023.9562, 1050.2109, 9},
	{"Woozie's Office", "Houses", "Two Story", -2159.122802,641.517517,1052.381713, 1}, 
	{"Unused Safehouse", "Houses", "Two Story", 2324.419921,-1145.568359,1050.710083, 12}, 
	
	{"Madd Dogg's Mansion", "Houses", "Big Leagues", 1267.8407, -776.9587, 1091.9063, 5},					//Mansions
	{"Big Smoke's Crack Palace", "Houses", "Big Leagues", 2536.5322, -1294.8425, 1044.125, 2},
	
	{"Burglary House (1) E", "Houses", "One Story (Empty)", 225.5707, 1240.0643, 1032.1406, 2},				//One Story (Empty)
	{"Burglary House (2) E", "Houses", "One Story (Empty)", 224.288, 1289.1907, 1032.1406, 1},
	{"Burglary House (3) E", "Houses", "One Story (Empty)", 295.1391, 1473.3719, 1030.2578, 15},
	{"Burglary House (4) E", "Houses", "One Story (Empty)", 22.861, 1404.9165, 1034.4297, 5},
	{"Burglary House (5) E", "Houses", "One Story (Empty)", -68.5145, 1353.8485, 1030.2109, 6},
	{"Burglary House (6) E", "Houses", "One Story (Empty)", -42.5267, 1408.23, 1034.4297, 8},
	{"Burglary House (7) E", "Houses", "One Story (Empty)", 260.7421, 1238.2261, 1034.2578, 9},
	{"Burglary House (8) E", "Houses", "One Story (Empty)", 447.0000, 1400.3000, 1034.3047, 2},
	{"Burglary House (9) E", "Houses", "One Story (Empty)", 261.1165, 1287.2197, 1030.2578, 4},
	{"Burglary House (10) E", "Houses", "One Story (Empty)", 327.8, 1479.7, 1035.0, 15},
	{"Burglary House (11) E", "Houses", "One Story (Empty)", 375.6, 1417.4, 1032.0, 15},
	{"Burglary House (12) E", "Houses", "One Story (Empty)", 384.6, 1471.5, 1031.0, 15},
	{"Safe House (1) E", "Houses", "One Story (Empty)", 2233.6919, -1112.8107, 1000.8828, 5},
	{"Safe House (2) E", "Houses", "One Story (Empty)", 2194.7900, -1204.3500, 999.0234, 6},
	{"Safe House (3) E", "Houses", "One Story (Empty)", 2262.4797,-1138.5591,1000.63285, 10},
	{"Safe House (4) E", "Houses", "One Story (Empty)", 2333.0, -1075.0, 999.0, 6},
	{"Safe House (5) E", "Houses", "One Story (Empty)", 2309.0, -1211.0, 999.0, 6},
	{"Safe House (6) E", "Houses", "One Story (Empty)", 2237.6, -1079.0, 1999.0, 2},
	{"Verdant Bluff Safehouse E", "Houses", "One Story (Empty)", 2365.1089, -1133.0795, 1000.875, 8},
	{"Willowfield Safehouse E", "Houses", "One Story (Empty)", 2282.9099, -1138.2900, 1000.8984, 11},
	{"Camel Toe's Safehouse E", "Houses", "One Story (Empty)", 2216.1282, -1076.3052, 1000.4844, 1},
	{"Ryder's House E", "Houses", "One Story (Empty)", 2447.8704, -1704.4509, 963.5078, 2},
	
	{"Burglary House (#1) E", "Houses", "Two Story (Empty)", 234.6087, 1187.8195, 1030.2578, 3},				//Two Story (Empty) 
	{"Burglary House (#2) E", "Houses", "Two Story (Empty)", 239.2819, 1114.1991, 1030.9922, 5},
	{"Burglary House (#3) E", "Houses", "Two Story (Empty)", 24.3769, 1341.1829, 1034.375, 10},
	{"Burglary House (#4) E", "Houses", "Two Story (Empty)", -262.1759, 1456.6158, 1034.36728, 4},
	{"Burglary House (#5) E", "Houses", "Two Story (Empty)", 140.3679, 1367.8837, 1033.8621, 5},
	{"Burglary House (#6) E", "Houses", "Two Story (Empty)", 234.2826, 1065.229, 1034.2101, 6},
	{"Burglary House (#7) E", "Houses", "Two Story (Empty)", -285.2511, 1471.197, 1034.375, 15},
	{"Burglary House (#8) E", "Houses", "Two Story (Empty)", 84.9244, 1324.2983, 1033.8594, 9},
	{"Burglary House (#9) E", "Houses", "Two Story (Empty)", 225.7, 1023.0, 1034.0, 7},
	{"CJ's House E", "Houses", "Two Story (Empty)", 2496.0549, -1695.1749, 964.7422, 3},
	{"Safe House E", "Houses", "Two Story (Empty)", 2319.1272, -1023.9562, 1000.2109, 9},
	{"Woozie's Office E", "Houses", "Two Story (Empty)", -2159.122802,641.517517,1002.381713, 1}, 
	{"Unused Safehouse E", "Houses", "Two Story (Empty)", 2324.419921,-1145.568359,1000.710083, 12}, 
	
	//////////////////////////////////////////////////////////////////////////
	/*								BUSINESSES								*/
	//////////////////////////////////////////////////////////////////////////
	{"24/7 (1)", "Businesses", "24/7's", -25.88, -185.87, 1003.55, 17},										//24/7's
	{"24/7 (2)", "Businesses", "24/7's", -6.09, -29.27, 1003.55, 10},
	{"24/7 (3)", "Businesses", "24/7's", -30.95, -89.61, 1003.55, 18},
	{"24/7 (4)", "Businesses", "24/7's", -25.13, -139.07, 1003.55, 16},
	{"24/7 (5)", "Businesses", "24/7's", -27.31, -29.28, 1003.55, 4},
	{"24/7 (6)", "Businesses", "24/7's", -26.69, -55.71, 1003.55, 6},
	
	{"Prolaps", "Businesses", "Clothing", 206.4627, -137.7076, 1003.0938, 3},								//Clothing
	{"Victim", "Businesses", "Clothing", 225.0306, -9.1838, 1002.218, 5},
	{"Suburban", "Businesses", "Clothing", 204.1174, -46.8047, 1001.8047, 1},
	{"Zip", "Businesses", "Clothing", 161.4048, -94.2416, 1001.8047, 18},
	{"Binco", "Businesses", "Clothing", 207.5219, -109.7448, 1005.1328, 15},
	{"Didier Sachs", "Businesses", "Clothing", 204.1658, -165.7678, 1000.5234, 14},
	{"Wardrobe", "Businesses", "Clothing", 256.9047, -41.6537, 1002.0234, 14},
	
	{"Barber Shop (1)", "Businesses", "Barber", 418.4666, -80.4595, 1001.8047, 3},							//Barber
	{"Barber Shop (2)", "Businesses", "Barber", 411.9707, -51.9217, 1001.8984, 12},
	{"Reece's Barber Shop", "Businesses", "Barber", 414.2987, -18.8044, 1001.8047, 2},
	
	{"Jay's Diner", "Businesses", "Restaurant & Club", 449.0172, -88.9894, 999.5547, 4},					//Restaurant & Club
	{"Brothel (1)", "Businesses", "Restaurant & Club", 974.0177, -9.5937, 1001.1484, 3},
	{"Brothel (2)", "Businesses", "Restaurant & Club", 961.9308, -51.9071, 1001.1172, 3},
	{"Brothel (3)", "Businesses", "Restaurant & Club", 744.5, 1437.0, 1103.0, 6},
	{"Big Spread Ranch", "Businesses", "Restaurant & Club", 1212.0762,-28.5799,1000.9531, 3},
	{"The Pig Pen", "Businesses", "Restaurant & Club", 1204.9326,-8.1650,1000.9219, 2},
	{"Dance Club", "Businesses", "Restaurant & Club", 490.2701,-18.4260,1000.6797, 17},
	{"10 Bottles Bar", "Businesses", "Restaurant & Club", 501.980987,-69.150199,998.757812, 11}, 
	{"Pleasure Domes", "Businesses", "Restaurant & Club", -2640.762939,1406.682006,906.460937, 3}, 
	{"Liberty Lounge", "Businesses", "Restaurant & Club", -794.806396,497.738037,1376.195312, 1},
	{"Lil' Probe Inn", "Businesses", "Restaurant & Club", -227.5703, 1401.5544, 27.7656, 18}, 
	
	{"Tattoo", "Businesses", "Shops", 748.4623, 1438.2378, 1102.9531, 6},									//Shops
	{"Burger Shot", "Businesses", "Shops", 365.4099, -73.6167, 1001.5078, 10},
	{"Well Stacked Pizza", "Businesses", "Shops", 372.3520, -131.6510, 1001.4922, 5},
	{"Cluckin Bell", "Businesses", "Shops", 365.7158, -9.8873, 1001.8516, 9},
	{"Rusty Donut's", "Businesses", "Shops", 378.026, -190.5155, 1000.6328, 17},
	{"Zero's", "Businesses", "Shops", -2240.1028, 136.973, 1035.4141, 6},
	{"Sex Shop", "Businesses", "Shops", -100.2674, -22.9376, 1000.7188, 3},
	
	{"Caligulas Casino", "Businesses", "Casinos", 2233.8032,1712.2303,1011.7632, 1},						//Casinos
	{"4 Dragons Casino", "Businesses", "Casinos", 2016.2699,1017.7790,996.8750, 10},
	{"Redsands Casino", "Businesses", "Casinos", 1132.9063,-9.7726,1000.6797, 12},
	{"Inside Track betting", "Businesses", "Casinos", 830.6016, 5.9404, 1004.1797, 3},
	{"Caligulas Roof", "Businesses", "Casinos", 2268.5156, 1647.7682, 1084.2344, 1},
	{"4 Dragons Janitor's Office", "Businesses", "Casinos", 1893.0731, 1017.8958, 31.8828, 10},
	
	{"Ammunation (1)", "Businesses", "Ammunations", 286.148987, -40.644398, 1001.569946, 1},				//Ammunations
	{"Ammunation (2)", "Businesses", "Ammunations", 286.800995, -82.547600, 1001.539978, 4},
	{"Ammunation (3)", "Businesses", "Ammunations", 296.919983, -108.071999, 1001.569946, 6},
	{"Ammunation (4)", "Businesses", "Ammunations", 314.820984, -141.431992, 999.661987, 7},
	{"Ammunation (5)", "Businesses", "Ammunations", 316.524994, -167.706985, 999.661987, 6},
	{"Booth Ammunation", "Businesses", "Ammunations", 302.292877, -143.139099, 1004.062500, 7},
	{"Range Ammunation", "Businesses", "Ammunations", 280.795104, -135.203353, 1004.062500, 7},

	{"Los Santos Gym", "Businesses", "Gyms", 772.1120, -3.8986, 1000.728, 5},						//Gyms
	{"San Fierro Gym", "Businesses", "Gyms", 771.8632,-40.5659,1000.6865, 6},
	{"Las Venturas Gym", "Businesses", "Gyms", 774.0681,-71.8559,1000.6484, 7},
	
	{"Blastin' Fools Records", "Businesses", "Other", 1037.8276, 0.397, 1001.2845, 3},						//Other
	{"Warehouse (1)", "Businesses", "Other", 1290.4106, 1.9512, 1001.0201, 18},
	{"Warehouse (2)", "Businesses", "Other", 1411.4434,-2.7966,1000.9238, 1},
	{"Warehouse (3)", "Businesses", "Other", 1059.5, 2087.6, 11.0, 0},
	{"Budget Inn Motel Room", "Businesses", "Other", 446.3247, 509.9662, 1001.4195, 12},
	{"Crack Den", "Businesses", "Other", 318.5645, 1118.2079, 1083.8828, 5},
	{"Meat Factory", "Businesses", "Other", 941.4977, 2144.3208, 1011.0234, 1},
	{"Bike School", "Businesses", "Other", 1494.8589, 1306.48, 1093.2953, 3},
	{"Driving School", "Businesses", "Other", -2031.1196, -115.8287, 1035.1719, 3},
	{"Atrium", "Businesses", "Other", 1710.433715,-1669.379272,20.225049, 18}, 
	{"Turning Tricks School", "Businesses", "Other", 1169.891113, 1360.425048, 10.921875, 0},
	{"Gas Station Interior", "Businesses", "Other", 487.72, 1137.93, 1083.44, 0},

	
	//////////////////////////////////////////////////////////////////////////
	/*								NO CATEGORY								*/
	//////////////////////////////////////////////////////////////////////////
	{"Loco Low Co", "No Category", "Mod Shops & Garages", 616.7820,-74.8151,997.6350, 2},					//Mod Shops & Garages
	{"Wheel Arch Angels", "No Category", "Mod Shops & Garages", 615.2851,-124.2390,997.6350, 3},
	{"Transfender", "No Category", "Mod Shops & Garages", 617.5380,-1.9900,1000.6829, 1},
	{"Doherty Garage", "No Category", "Mod Shops & Garages", -2041.2334, 178.3969, 28.8465, 1},
	
	{"Francis Ticket Sales Airport", "No Category", "Airports", -1827.147338,7.207418,1061.143554, 14},		//Airports
	{"Francis Baggage Claim Airport", "No Category", "Airports", -1855.568725,41.263156,1061.143554, 14},
	{"Andromada Cargo Hold", "No Category", "Airports", 315.856170,1024.496459,1949.797363, 9},
	{"Shamal Cabin", "No Category", "Airports", 2.384830,33.103397,1199.849976, 1},
	{"LS Airport Baggage Claim", "No Category", "Airports", -1870.80,59.81,1056.25, 14},
	{"Interernational Airport", "No Category", "Airports", -1830.81,16.83,1061.14, 14},
	{"Abounded AC Tower", "No Category", "Airports", 419.8936, 2537.1155, 10.0, 10},
	
	{"RC War Arena", "No Category", "Stadiums", -1079.99,1061.58,1343.04, 10},								//Stadiums
	{"Racing Stadium (1)", "No Category", "Stadiums", -1395.958,-208.197,1051.170, 7},
	{"Racing Stadium (2)", "No Category", "Stadiums", -1424.9319,-664.5869,1059.8585, 4},
	{"Bloodbowl Stadium", "No Category", "Stadiums", -1394.20,987.62,1023.96, 15},
	{"Kickstart Stadium", "No Category", "Stadiums", -1410.72,1591.16,1052.53, 14},
	{"Hyman Memorial Stadium", "No Category", "Stadiums", -1401.5,106.5,1033.0, 1},
	{"Sumo Stadium", "No Category", "Stadiums", -1397.0, 1246.0, 1040.0, 16},
	
	
	//////////////////////////////////////////////////////////////////////////
	/*								DEPARTMENTS								*/
	//////////////////////////////////////////////////////////////////////////
	{"Los Santos Police Department", "Departments", "Nothing", 246.6695, 65.8039, 1003.6406, 6},					//Departments
	{"San Fierro Police Department", "Departments", "Nothing", 246.40,110.84,1003.22, 10},
	{"Las Venturas Police Department", "Departments", "Nothing", 288.4723, 170.0647, 1007.1794, 3},
	{"Planning Department", "Departments", "Nothing", 386.5259, 173.6381, 1008.382, 3},
	
	
	//////////////////////////////////////////////////////////////////////////
	/*							WORLD LOCATIONS								*/
	//////////////////////////////////////////////////////////////////////////
	{"Market Stall (1)", "World Locations", "Nothing", 390.6189, -1754.6224, 8.2057, 0},							//World Locations
	{"Market Stall (2)", "World Locations", "Nothing", 398.1151, -1754.8677, 8.2150, 0},
	{"Market Stall (3)", "World Locations", "Nothing", 380.1665, -1886.9348, 7.8359, 0},
	{"Market Stall (4)", "World Locations", "Nothing", 383.4514, -1912.3203, 7.8359, 0},
	{"Market Stall (5)", "World Locations", "Nothing", 380.8439, -1922.2300, 7.8359, 0},
	{"Sweet's Garage", "World Locations", "Nothing", 2522.5, -1673.8, 15.0, 0},
	{"Liberty Courtyard", "World Locations", "Nothing", -805.29, 503.63, 1360.4, 1}
};

public OnFilterScriptInit()
{
	print("\n\t\tInterior Menu for MT-Gaming loaded!\n");
	return 1;
}

public OnFilterScriptExit()
{
	print("\n\t\tInterior Menu for MT-Gaming unloaded!\n");
	return 1;
}

CMD:intmenu(playerid, params[])
{
	if(GetPVarInt(playerid, "AdminLevel") < 2)
		return 1;
		
	// new string[300], cat[32] = "null";
	// for(new i; i < sizeof(InteriorMenu); i++)
	// {
		// if(strcmp(cat, InteriorMenu[i][Category], true))
		// {
			// format(cat, sizeof(cat), InteriorMenu[i][Category]);
			// format(string, sizeof(string), "%s%s\n", string, InteriorMenu[i][Category]);
		// }
	// }
	// "Houses\nBusinesses\nDepartments\nNo Category\nWorld locations\n"
	// return ShowPlayerDialog(playerid, MAIN, DIALOG_STYLE_LIST, "Interior Menu", string, "Select", "Close");
	return ShowPlayerDialog(playerid, MAIN, DIALOG_STYLE_LIST, "Interior Menu", "Houses\nBusinesses\nDepartments\nNo Category\nWorld locations\n", "Select", "Close");
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case MAIN:
		{
			switch(listitem)
			{
				case 0:
				{
					if(response)
					{
						new string[300], type[32] = "null", cat[32] = "Houses";
						for(new i; i < sizeof(InteriorMenu); i++)
						{
							if(!strcmp(cat, InteriorMenu[i][Category], true))
							{
								if(strcmp(type, InteriorMenu[i][Type], true))
								{
									format(type, sizeof(type), InteriorMenu[i][Type]);
									format(string, sizeof(string), "%s%s\n", string, InteriorMenu[i][Type]);
								}
							}
						}
						ShowPlayerDialog(playerid, HOUSES, DIALOG_STYLE_LIST, "Interior Menu - Houses", string, "Select", "Back");
					}
				}
				case 1:
				{
					if(response)
					{
						new string[300], type[32] = "null", cat[32] = "Businesses";
						for(new i; i < sizeof(InteriorMenu); i++)
						{
							if(!strcmp(cat, InteriorMenu[i][Category], true))
							{
								if(strcmp(type, InteriorMenu[i][Type], true))
								{
									format(type, sizeof(type), InteriorMenu[i][Type]);
									format(string, sizeof(string), "%s%s\n", string, InteriorMenu[i][Type]);
								}
							}
						}
						ShowPlayerDialog(playerid, BUSINESSES, DIALOG_STYLE_LIST, "Interior Menu - Businesses", string, "Select", "Back");
					}
				}
				case 2:
				{
					if(response)
					{
						new string[300], cat[32] = "Departments";
						for(new i; i < sizeof(InteriorMenu); i++)
						{
							if(!strcmp(cat, InteriorMenu[i][Category], true))
							{
								format(cat, sizeof(cat), InteriorMenu[i][Category]);
								format(string, sizeof(string), "%s%s\n", string, InteriorMenu[i][Name]);
							}
						}
						ShowPlayerDialog(playerid, DEPARTMENTS, DIALOG_STYLE_LIST, "Interior Menu - Departments", string, "Select", "Back");
					}
				}
				case 3:
				{
					if(response)
					{
						new string[300], type[32] = "null", cat[32] = "No Category";
						for(new i; i < sizeof(InteriorMenu); i++)
						{
							if(!strcmp(cat, InteriorMenu[i][Category], true))
							{
								if(strcmp(type, InteriorMenu[i][Type], true))
								{
									format(type, sizeof(type), InteriorMenu[i][Type]);
									format(string, sizeof(string), "%s%s\n", string, InteriorMenu[i][Type]);
								}
							}
						}
						ShowPlayerDialog(playerid, NOCATEGORY, DIALOG_STYLE_LIST, "Interior Menu - No Category", string, "Select", "Back");
					}
				}
				case 4:
				{
					if(response)
					{
						new string[300], cat[32] = "World Locations";
						for(new i; i < sizeof(InteriorMenu); i++)
						{
							if(strcmp(cat, InteriorMenu[i][Category], true))
								continue;
								
							format(cat, sizeof(cat), InteriorMenu[i][Category]);
							format(string, sizeof(string), "%s%s\n", string, InteriorMenu[i][Name]);
						}
						ShowPlayerDialog(playerid, DEPARTMENTS, DIALOG_STYLE_LIST, "Interior Menu - World Locations", string, "Select", "Back");
					}
				}
			}
		}
		case HOUSES:
		{
			if(response)
			{
				new string[500];
				for(new i; i < sizeof(InteriorMenu); i++)
				{
					if(strcmp(InteriorMenu[i][Type], inputtext, true))
						continue;
						
					format(string, sizeof(string), "%s%s\n", string, InteriorMenu[i][Name]);
				}
				new string2[128];
				format(string2, sizeof(string2), "Interior Menu - Houses - %s", inputtext);
				ShowPlayerDialog(playerid, HOUSES+1, DIALOG_STYLE_LIST, string2, string, "Select", "Back");
			}
			else
			{
				ShowPlayerDialog(playerid, MAIN, DIALOG_STYLE_LIST, "Interior Menu", "Houses\nBusinesses\nDepartments\nNo Category\nWorld locations\n", "Select", "Close");
			}
		}
		case HOUSES+1:
		{
			if(response)
			{
				for(new i; i < sizeof(InteriorMenu); i++)
				{
					if(!strcmp(InteriorMenu[i][Name], inputtext))
					{
						SetPlayerPos(playerid, InteriorMenu[i][X], InteriorMenu[i][Y], InteriorMenu[i][Z]);
						SetPlayerInterior(playerid, InteriorMenu[i][Interior]);
						
						new str[128];
						format(str, sizeof(str), "You have teleported to %s. [X: %0.2f | Y: %0.2f | Z: %0.2f | Int: %d]", InteriorMenu[i][Name], InteriorMenu[i][X], InteriorMenu[i][Y], InteriorMenu[i][Z], InteriorMenu[i][Interior]);
						return SendClientMessage(playerid, DEBUG, str);
					}
				}
			}
			else
			{
				new string[300], type[32] = "null", cat[32] = "Houses";
				for(new i; i < sizeof(InteriorMenu); i++)
				{
					if(!strcmp(cat, InteriorMenu[i][Category], true))
					{
						if(strcmp(type, InteriorMenu[i][Type], true))
						{
							format(type, sizeof(type), InteriorMenu[i][Type]);
							format(string, sizeof(string), "%s%s\n", string, InteriorMenu[i][Type]);
						}
					}
				}
				ShowPlayerDialog(playerid, HOUSES, DIALOG_STYLE_LIST, "Interior Menu - Houses", string, "Select", "Back");
			}
		}
		case BUSINESSES:
		{
			if(response)
			{
				new string[300];
				for(new i; i < sizeof(InteriorMenu); i++)
				{
					if(strcmp(InteriorMenu[i][Type], inputtext, true))
						continue;
						
					format(string, sizeof(string), "%s%s\n", string, InteriorMenu[i][Name]);
				}
				new string2[128];
				format(string2, sizeof(string2), "Interior Menu - Businesses - %s", inputtext);
				ShowPlayerDialog(playerid, BUSINESSES+1, DIALOG_STYLE_LIST, string2, string, "Select", "Back");
			}
			else
			{
				ShowPlayerDialog(playerid, MAIN, DIALOG_STYLE_LIST, "Interior Menu", "Houses\nBusinesses\nDepartments\nNo Category\nWorld locations\n", "Select", "Close");
			}
		}
		case BUSINESSES+1:
		{
			if(response)
			{
				for(new i; i < sizeof(InteriorMenu); i++)
				{
					if(!strcmp(InteriorMenu[i][Name], inputtext))
					{
						SetPlayerPos(playerid, InteriorMenu[i][X], InteriorMenu[i][Y], InteriorMenu[i][Z]);
						SetPlayerInterior(playerid, InteriorMenu[i][Interior]);
						
						new str[128];
						format(str, sizeof(str), "You have teleported to %s. [X: %0.2f | Y: %0.2f | Z: %0.2f | Int: %d]", InteriorMenu[i][Name], InteriorMenu[i][X], InteriorMenu[i][Y], InteriorMenu[i][Z], InteriorMenu[i][Interior]);
						return SendClientMessage(playerid, DEBUG, str);
					}
				}
			}
			else
			{
				new string[300], type[32] = "null", cat[32] = "Businesses";
				for(new i; i < sizeof(InteriorMenu); i++)
				{
					if(!strcmp(cat, InteriorMenu[i][Category], true))
					{
						if(strcmp(type, InteriorMenu[i][Type], true))
						{
							format(type, sizeof(type), InteriorMenu[i][Type]);
							format(string, sizeof(string), "%s%s\n", string, InteriorMenu[i][Type]);
						}
					}
				}
				ShowPlayerDialog(playerid, BUSINESSES, DIALOG_STYLE_LIST, "Interior Menu - Businesses", string, "Select", "Back");
			}
		}
		case DEPARTMENTS:
		{
			if(response)
			{
				for(new i; i < sizeof(InteriorMenu); i++)
				{
					if(!strcmp(InteriorMenu[i][Name], inputtext))
					{
						SetPlayerPos(playerid, InteriorMenu[i][X], InteriorMenu[i][Y], InteriorMenu[i][Z]);
						SetPlayerInterior(playerid, InteriorMenu[i][Interior]);
						
						new str[128];
						format(str, sizeof(str), "You have teleported to %s. [X: %0.2f | Y: %0.2f | Z: %0.2f | Int: %d]", InteriorMenu[i][Name], InteriorMenu[i][X], InteriorMenu[i][Y], InteriorMenu[i][Z], InteriorMenu[i][Interior]);
						return SendClientMessage(playerid, DEBUG, str);
					}
				}
			}
			else
			{
				ShowPlayerDialog(playerid, MAIN, DIALOG_STYLE_LIST, "Interior Menu", "Houses\nBusinesses\nDepartments\nNo Category\nWorld locations\n", "Select", "Close");
			}
		}
		case NOCATEGORY:
		{
			if(response)
			{
				new string[300];
				for(new i; i < sizeof(InteriorMenu); i++)
				{
					if(strcmp(InteriorMenu[i][Type], inputtext, true))
						continue;
						
					format(string, sizeof(string), "%s%s\n", string, InteriorMenu[i][Name]);
				}
				new string2[128];
				format(string2, sizeof(string2), "Interior Menu - No Category - %s", inputtext);
				ShowPlayerDialog(playerid, NOCATEGORY+1, DIALOG_STYLE_LIST, string2, string, "Select", "Back");
			}
			else
			{
				ShowPlayerDialog(playerid, MAIN, DIALOG_STYLE_LIST, "Interior Menu", "Houses\nBusinesses\nDepartments\nNo Category\nWorld locations\n", "Select", "Close");
			}
		}
		case NOCATEGORY+1:
		{
			if(response)
			{
				for(new i; i < sizeof(InteriorMenu); i++)
				{
					if(!strcmp(InteriorMenu[i][Name], inputtext))
					{
						SetPlayerPos(playerid, InteriorMenu[i][X], InteriorMenu[i][Y], InteriorMenu[i][Z]);
						SetPlayerInterior(playerid, InteriorMenu[i][Interior]);
						
						new str[128];
						format(str, sizeof(str), "You have teleported to %s. [X: %0.2f | Y: %0.2f | Z: %0.2f | Int: %d]", InteriorMenu[i][Name], InteriorMenu[i][X], InteriorMenu[i][Y], InteriorMenu[i][Z], InteriorMenu[i][Interior]);
						return SendClientMessage(playerid, DEBUG, str);
					}
				}
			}
			else
			{
				new string[300], type[32] = "null", cat[32] = "No Category";
				for(new i; i < sizeof(InteriorMenu); i++)
				{
					if(!strcmp(cat, InteriorMenu[i][Category], true))
					{
						if(strcmp(type, InteriorMenu[i][Type], true))
						{
							format(type, sizeof(type), InteriorMenu[i][Type]);
							format(string, sizeof(string), "%s%s\n", string, InteriorMenu[i][Type]);
						}
					}
				}
				ShowPlayerDialog(playerid, NOCATEGORY, DIALOG_STYLE_LIST, "Interior Menu - No Category", string, "Select", "Back");
			}
		}
		case WORLDLOCATIONS:
		{
			if(response)
			{
				for(new i; i < sizeof(InteriorMenu); i++)
				{
					if(!strcmp(InteriorMenu[i][Name], inputtext))
					{
						SetPlayerPos(playerid, InteriorMenu[i][X], InteriorMenu[i][Y], InteriorMenu[i][Z]);
						SetPlayerInterior(playerid, InteriorMenu[i][Interior]);
						
						new str[128];
						format(str, sizeof(str), "You have teleported to %s. [X: %0.2f | Y: %0.2f | Z: %0.2f | Int: %d]", InteriorMenu[i][Name], InteriorMenu[i][X], InteriorMenu[i][Y], InteriorMenu[i][Z], InteriorMenu[i][Interior]);
						return SendClientMessage(playerid, DEBUG, str);
					}
				}
			}
			else
			{
				ShowPlayerDialog(playerid, MAIN, DIALOG_STYLE_LIST, "Interior Menu", "Houses\nBusinesses\nDepartments\nNo Category\nWorld locations\n", "Select", "Close");
			}
		}
	}
	return 0;
}