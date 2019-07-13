// GeoIP script by Slice.

#include <a_samp>
#include <a_http>

#define HTTP_INDEX_OFFSET (10000)

enum
{
	GEOIP_STATE_NONE,
	GEOIP_STATE_RETRIEVING,
	GEOIP_STATE_RETRIEVED
};

new
	g_cPlayerGeoipState[ MAX_PLAYERS char ] = { GEOIP_STATE_RETRIEVING, ... },
	g_cPlayerCountryIndex[ MAX_PLAYERS char ]
;

public OnFilterScriptInit( )
{
	printf( "GeoIP script by Slice loaded." );
}

public OnFilterScriptExit( )
{
	printf( "GeoIP script by Slice unloaded." );
}

public OnPlayerConnect( playerid )
{
	static
		s_szIP[ 16 ],
		s_szURL[ ] = "spelsajten.net/geoip.php?ip=255.255.255.255"
	;
	
	g_cPlayerGeoipState{ playerid } = GEOIP_STATE_RETRIEVING;
	
	GetPlayerIp( playerid, s_szIP, sizeof( s_szIP ) );
	
	s_szURL[ 0 ] = EOS;
	
	strcat( s_szURL, "spelsajten.net/geoip.php?ip=" );
	strcat( s_szURL, s_szIP );
	
	HTTP( HTTP_INDEX_OFFSET + playerid, HTTP_GET, s_szURL, "", "OnGeoipResponse" );
}

public OnPlayerDisconnect( playerid )
{
	SetTimerEx( "ResetGeoipState", 0, false, "i", playerid );
}

forward ResetGeoipState( iPlayer );
public  ResetGeoipState( iPlayer )
{
	g_cPlayerGeoipState{ iPlayer } = GEOIP_STATE_NONE;
}

forward OnGeoipResponse( iIndex, iResponseCode, const szData[ ] );
public  OnGeoipResponse( iIndex, iResponseCode, const szData[ ] )
{
	if ( HTTP_INDEX_OFFSET <= iIndex <= HTTP_INDEX_OFFSET + MAX_PLAYERS )
	{
		new
			iPlayer = iIndex - HTTP_INDEX_OFFSET,
			iCountryIndex = strval( szData )
		;
		
		if ( !( 0 <= iCountryIndex <= 240 ) )
			iCountryIndex = 0;
		
		g_cPlayerCountryIndex{ iPlayer } = iCountryIndex;
		g_cPlayerGeoipState{ iPlayer } = GEOIP_STATE_RETRIEVED;
		
		CallRemoteFunction( "OnGeoipUpdate", "i", iPlayer );
	}
}

forward GetPlayerCountryIndex( iPlayer );
public  GetPlayerCountryIndex( iPlayer )
{
	if ( g_cPlayerGeoipState{ iPlayer } == GEOIP_STATE_RETRIEVED )
		return g_cPlayerCountryIndex{ iPlayer };
	
	return 0;
}