/*
#		MTG Parking Admin Help
#		
#
#	By accessing this file, you agree to the following:
#		- You will never give the script or associated files to anybody who is not on the MTG SAMP development team
# 		- You will delete all development materials (script, databases, associated files, etc.) when you leave the MTG SAMP development team.
#
*/

enum admincommands_
{
	ahLevel,
	ahCategory[32],
	ahCommand[32]
};

new AdminCommands[][admincommands_] = 
{
	{1, "Moderator", "/a"},
	{1, "Moderator", "/askban"},
	{1, "Moderator", "/maccept"},
	{1, "Moderator", "/mlist"},
	{1, "Moderator", "/mtrash"},
	{1, "Moderator", "/nmute"},
	{1, "Moderator", "/vmute"},
	{1, "Moderator", "/setpin"},
	
	{2, "General", "/adminduty"},
	{2, "General", "/adminnote"},
	{2, "General", "/announce"},
	{2, "General", "/as"},
	{2, "General", "/award"},
	{2, "General", "/clearnote"},
	{2, "General", "/eventwinner"},
	{2, "General", "/notetoplayer"},
	{2, "General", "/highestz"},
	{2, "General", "/searchnumber"},
	{2, "General", "/searchloc"},
	{2, "General", "/status"},
	{2, "General", "/togwarnings"},
	{2, "General", "/vsearch"},
	
	{2, "Vehicles", "/closestcar"},
	{2, "Vehicles", "/lastcar"},
	{2, "Vehicles", "/getcar"},
	
	{2, "Checking", "/check"},
	{2, "Checking", "/checkbusiness"},
	{2, "Checking", "/checkgang"},
	{2, "Checking", "/checkgroup"},
	{2, "Checking", "/checkhouse"},
	{2, "Checking", "/checkhotelroom"},
	{2, "Checking", "/checkstash"},
	{2, "Checking", "/checkvehicle"},
	{2, "Checking", "/checkwalkie"},
	{2, "Checking", "/checkweapons"},
	
	{2, "Chat", "/togglenewbie"},
	{2, "Chat", "/togglevip"},
	
	{2, "Spectating", "/spec"},
	{2, "Spectating", "/specoff"},
	{2, "Spectating", "/specveh"},
	
	{2, "Reports", "/reports"}
	{2, "Reports", "/acceptreport"},
	{2, "Reports", "/trash"}

	{2, "Teleporting", "/agotobusiness"},
	{2, "Teleporting", "/agotogroup"},
	{2, "Teleporting", "/agotohouse"},
	{2, "Teleporting", "/agotojob"},
	{2, "Teleporting", "/aw"},
	{2, "Teleporting", "/back"},
	{2, "Teleporting", "/go"},
	{2, "Teleporting", "/goto"},
	{2, "Teleporting", "/gotogang"},
	{2, "Teleporting", "/gotopayphone"},
	{2, "Teleporting", "/tp"},
	{2, "Teleporting", "/get"},
	{2, "Teleporting", "/remoteaw"},
	{2, "Teleporting", "/sendback"},
	{2, "Teleporting", "/tphere"},
	
}