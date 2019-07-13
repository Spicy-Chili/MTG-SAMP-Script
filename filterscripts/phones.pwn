#include <a_samp>
#include <a_mysql>
#include <dini>

main(){}

new MYSQL_MAIN, MYSQL_IP[32], MYSQL_USERNAME[32], MYSQL_DATABASE_NAME[32], MYSQL_PASSWORD[32];
stock InitMySQL()
{
	if(!fexist("MySQLConfig.ini"))
		dini_Create("MySQLConfig.ini");
	
	format(MYSQL_IP, sizeof(MYSQL_IP), "%s", dini_Get("MySQLConfig.ini", "MYSQL_IP"));
	format(MYSQL_USERNAME, sizeof(MYSQL_USERNAME), "%s", dini_Get("MySQLConfig.ini", "MYSQL_USERNAME"));
	format(MYSQL_DATABASE_NAME, sizeof(MYSQL_DATABASE_NAME), "%s", dini_Get("MySQLConfig.ini", "MYSQL_DATABASE_NAME"));
	format(MYSQL_PASSWORD, sizeof(MYSQL_PASSWORD), "%s", dini_Get("MySQLConfig.ini", "MYSQL_PASSWORD"));
	
	MYSQL_MAIN = mysql_connect(MYSQL_IP, MYSQL_USERNAME, MYSQL_DATABASE_NAME, MYSQL_PASSWORD);
	
	if(mysql_errno(MYSQL_MAIN) != 0)
	{
		print("\a[MySQL] Could not connect to MySQL database! Emergency Shutdown initiated!!\r\n");
		SendRconCommand("exit");
	}
	else 
	{
		print("[MySQL] Connection to MySQL established.\r\n");
		// CreatePlayerTables();
	}
	return 1;
}

public OnGameModeInit()
{
	InitMySQL();
	new query[128];
	mysql_format(MYSQL_MAIN, query, sizeof(query), "SELECT normalname, phonen FROM playeraccounts WHERE phonen > 0");
	new Cache:cache = mysql_query(MYSQL_MAIN, query), count = cache_get_row_count(), idx;
	
	if(count == 0)
	{
		return cache_delete(cache);
	}
	
	while(idx < count)
	{
		cache_set_active(cache);
		
		new name[25], number = cache_get_field_content_int(idx, "phonen");
		cache_get_field_content(idx, "normalname", name);
		mysql_format(MYSQL_MAIN, query, sizeof(query), "INSERT INTO phones (owner, number) VALUES ('%e', '%d')", name, number);
		mysql_query(MYSQL_MAIN, query);
		
		idx++;
	}
	cache_delete(cache);
	return 1;
}