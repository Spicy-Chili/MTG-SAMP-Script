// GeoIP script by Slice.

#include <a_samp>

#define MAX_COUNTRY_CODE  (3)
#define MAX_COUNTRY_NAME  (37)

enum e_COUNTRY_INFO
{
	e_szCountryCode[ MAX_COUNTRY_CODE char ],
	e_szCountryName[ MAX_COUNTRY_NAME char ]
};

enum
{
	GEOIP_STATE_NONE,
	GEOIP_STATE_RETRIEVING,
	GEOIP_STATE_RETRIEVED
};

#pragma pack 1

stock const
	g_aszCountryInfo[ ][ e_COUNTRY_INFO ] = {
		{ "XX", "Unknown" },
		{ "AU", "Australia" },
		{ "MY", "Malaysia" },
		{ "KR", "Kore" },
		{ "CN", "China" },
		{ "JP", "Japan" },
		{ "IN", "India" },
		{ "TW", "Taiwan" },
		{ "HK", "Hong Kong" },
		{ "TH", "Thailand" },
		{ "VN", "Vietnam" },
		{ "FR", "France" },
		{ "EU", "Europe" },
		{ "GB", "United Kingdom" },
		{ "IT", "Italy" },
		{ "AE", "United Arab Emirates" },
		{ "IL", "Israel" },
		{ "UA", "Ukraine" },
		{ "RU", "Russian Federation" },
		{ "SE", "Sweden" },
		{ "KZ", "Kazakhstan" },
		{ "PT", "Portugal" },
		{ "GR", "Greece" },
		{ "SA", "Saudi Arabia" },
		{ "DK", "Denmark" },
		{ "IR", "Ira" },
		{ "NO", "Norway" },
		{ "DE", "Germany" },
		{ "US", "United States" },
		{ "CA", "Canada" },
		{ "MX", "Mexico" },
		{ "BM", "Bermuda" },
		{ "PR", "Puerto Rico" },
		{ "VI", "Virgin Island" },
		{ "BO", "Bolivia" },
		{ "NL", "Netherlands" },
		{ "AP", "Asia/Pacific Region" },
		{ "NZ", "New Zealand" },
		{ "SG", "Singapore" },
		{ "ID", "Indonesia" },
		{ "NP", "Nepal" },
		{ "PH", "Philippines" },
		{ "PG", "Papua New Guinea" },
		{ "PK", "Pakistan" },
		{ "ES", "Spain" },
		{ "BS", "Bahamas" },
		{ "VC", "Saint Vincent and the Grenadines" },
		{ "CL", "Chile" },
		{ "NC", "New Caledonia" },
		{ "AR", "Argentina" },
		{ "DM", "Dominica" },
		{ "TK", "Tokelau" },
		{ "KH", "Cambodia" },
		{ "MO", "Macau" },
		{ "MV", "Maldives" },
		{ "AF", "Afghanistan" },
		{ "FJ", "Fiji" },
		{ "MN", "Mongolia" },
		{ "WF", "Wallis and Futuna" },
		{ "BD", "Bangladesh" },
		{ "IE", "Ireland" },
		{ "AN", "Netherlands Antilles" },
		{ "BE", "Belgium" },
		{ "BZ", "Belize" },
		{ "BR", "Brazil" },
		{ "CH", "Switzerland" },
		{ "ZA", "South Africa" },
		{ "EG", "Egypt" },
		{ "NG", "Nigeria" },
		{ "TZ", "Tanzani" },
		{ "ZM", "Zambia" },
		{ "SN", "Senegal" },
		{ "NA", "Namibia" },
		{ "CI", "Cote D'Ivoire" },
		{ "GH", "Ghana" },
		{ "SD", "Sudan" },
		{ "CM", "Cameroon" },
		{ "MW", "Malawi" },
		{ "AO", "Angola" },
		{ "KE", "Kenya" },
		{ "GA", "Gabon" },
		{ "ML", "Mali" },
		{ "BJ", "Benin" },
		{ "MG", "Madagascar" },
		{ "TD", "Chad" },
		{ "BW", "Botswana" },
		{ "LY", "Libyan Arab Jamahiriya" },
		{ "CV", "Cape Verde" },
		{ "RW", "Rwanda" },
		{ "MZ", "Mozambique" },
		{ "GM", "Gambia" },
		{ "LS", "Lesotho" },
		{ "MU", "Mauritius" },
		{ "CG", "Congo" },
		{ "UG", "Uganda" },
		{ "BF", "Burkina Faso" },
		{ "SL", "Sierra Leone" },
		{ "SO", "Somalia" },
		{ "ZW", "Zimbabwe" },
		{ "CD", "Cong" },
		{ "NE", "Niger" },
		{ "CF", "Central African Republic" },
		{ "SZ", "Swaziland" },
		{ "TG", "Togo" },
		{ "GN", "Guinea" },
		{ "LR", "Liberia" },
		{ "SC", "Seychelles" },
		{ "MA", "Morocco" },
		{ "DZ", "Algeria" },
		{ "MR", "Mauritania" },
		{ "DJ", "Djibouti" },
		{ "A2", "Satellite Provider" },
		{ "KM", "Comoros" },
		{ "RE", "Reunion" },
		{ "GQ", "Equatorial Guinea" },
		{ "TN", "Tunisia" },
		{ "TR", "Turkey" },
		{ "BG", "Bulgaria" },
		{ "MT", "Malta" },
		{ "CZ", "Czech Republic" },
		{ "RS", "Serbia" },
		{ "EE", "Estonia" },
		{ "CY", "Cyprus" },
		{ "LB", "Lebanon" },
		{ "PL", "Poland" },
		{ "LU", "Luxembourg" },
		{ "FI", "Finland" },
		{ "AT", "Austria" },
		{ "PS", "Palestinian Territor" },
		{ "AZ", "Azerbaijan" },
		{ "RO", "Romania" },
		{ "TJ", "Tajikistan" },
		{ "LV", "Latvia" },
		{ "BY", "Belarus" },
		{ "IS", "Iceland" },
		{ "HU", "Hungary" },
		{ "SK", "Slovakia" },
		{ "MK", "Macedonia" },
		{ "IQ", "Iraq" },
		{ "ME", "Montenegro" },
		{ "HR", "Croatia" },
		{ "JO", "Jordan" },
		{ "YE", "Yemen" },
		{ "BA", "Bosnia and Herzegovina" },
		{ "LT", "Lithuania" },
		{ "OM", "Oman" },
		{ "BH", "Bahrain" },
		{ "GE", "Georgia" },
		{ "SY", "Syrian Arab Republic" },
		{ "SI", "Slovenia" },
		{ "MD", "Moldov" },
		{ "AM", "Armenia" },
		{ "AL", "Albania" },
		{ "PA", "Panama" },
		{ "BN", "Brunei Darussalam" },
		{ "LK", "Sri Lanka" },
		{ "KW", "Kuwait" },
		{ "AX", "Aland Islands" },
		{ "AG", "Antigua and Barbuda" },
		{ "SM", "San Marino" },
		{ "FK", "Falkland Islands (Malvinas)" },
		{ "UZ", "Uzbekistan" },
		{ "MC", "Monaco" },
		{ "HT", "Haiti" },
		{ "GU", "Guam" },
		{ "JM", "Jamaica" },
		{ "UM", "United States Minor Outlying Islands" },
		{ "FM", "Micronesi" },
		{ "EC", "Ecuador" },
		{ "CO", "Colombia" },
		{ "PE", "Peru" },
		{ "KY", "Cayman Islands" },
		{ "HN", "Honduras" },
		{ "VG", "Virgin Island" },
		{ "NI", "Nicaragua" },
		{ "DO", "Dominican Republic" },
		{ "GD", "Grenada" },
		{ "GT", "Guatemala" },
		{ "CR", "Costa Rica" },
		{ "SV", "El Salvador" },
		{ "VE", "Venezuela" },
		{ "BB", "Barbados" },
		{ "TT", "Trinidad and Tobago" },
		{ "BV", "Bouvet Island" },
		{ "MH", "Marshall Islands" },
		{ "CK", "Cook Islands" },
		{ "GI", "Gibraltar" },
		{ "PY", "Paraguay" },
		{ "A1", "Anonymous Proxy" },
		{ "WS", "Samoa" },
		{ "KN", "Saint Kitts and Nevis" },
		{ "UY", "Uruguay" },
		{ "MP", "Northern Mariana Islands" },
		{ "PW", "Palau" },
		{ "QA", "Qatar" },
		{ "AS", "American Samoa" },
		{ "TC", "Turks and Caicos Islands" },
		{ "LC", "Saint Lucia" },
		{ "VA", "Holy See (Vatican City State)" },
		{ "LA", "Lao People's Democratic Republic" },
		{ "AW", "Aruba" },
		{ "GY", "Guyana" },
		{ "SR", "Suriname" },
		{ "IM", "Isle of Man" },
		{ "VU", "Vanuatu" },
		{ "KP", "Kore" },
		{ "AI", "Anguilla" },
		{ "MS", "Montserrat" },
		{ "PM", "Saint Pierre and Miquelon" },
		{ "GP", "Guadeloupe" },
		{ "MF", "Saint Martin" },
		{ "GG", "Guernsey" },
		{ "BI", "Burundi" },
		{ "TM", "Turkmenistan" },
		{ "KG", "Kyrgyzstan" },
		{ "MM", "Myanmar" },
		{ "BT", "Bhutan" },
		{ "LI", "Liechtenstein" },
		{ "FO", "Faroe Islands" },
		{ "ET", "Ethiopia" },
		{ "MQ", "Martinique" },
		{ "JE", "Jersey" },
		{ "AD", "Andorra" },
		{ "AQ", "Antarctica" },
		{ "IO", "British Indian Ocean Territory" },
		{ "ER", "Eritrea" },
		{ "GL", "Greenland" },
		{ "GW", "Guinea-Bissau" },
		{ "PF", "French Polynesia" },
		{ "CU", "Cuba" },
		{ "TO", "Tonga" },
		{ "TL", "Timor-Leste" },
		{ "ST", "Sao Tome and Principe" },
		{ "GF", "French Guiana" },
		{ "SB", "Solomon Islands" },
		{ "TV", "Tuvalu" },
		{ "KI", "Kiribati" },
		{ "NU", "Niue" },
		{ "NF", "Norfolk Island" },
		{ "NR", "Nauru" },
		{ "YT", "Mayotte" }
	}
;

enum
{
	COUNTRY_XX, // Unknown
	COUNTRY_AU, // Australia
	COUNTRY_MY, // Malaysia
	COUNTRY_KR, // Kore
	COUNTRY_CN, // China
	COUNTRY_JP, // Japan
	COUNTRY_IN, // India
	COUNTRY_TW, // Taiwan
	COUNTRY_HK, // Hong Kong
	COUNTRY_TH, // Thailand
	COUNTRY_VN, // Vietnam
	COUNTRY_FR, // France
	COUNTRY_EU, // Europe
	COUNTRY_GB, // United Kingdom
	COUNTRY_IT, // Italy
	COUNTRY_AE, // United Arab Emirates
	COUNTRY_IL, // Israel
	COUNTRY_UA, // Ukraine
	COUNTRY_RU, // Russian Federation
	COUNTRY_SE, // Sweden
	COUNTRY_KZ, // Kazakhstan
	COUNTRY_PT, // Portugal
	COUNTRY_GR, // Greece
	COUNTRY_SA, // Saudi Arabia
	COUNTRY_DK, // Denmark
	COUNTRY_IR, // Ira
	COUNTRY_NO, // Norway
	COUNTRY_DE, // Germany
	COUNTRY_US, // United States
	COUNTRY_CA, // Canada
	COUNTRY_MX, // Mexico
	COUNTRY_BM, // Bermuda
	COUNTRY_PR, // Puerto Rico
	COUNTRY_VI, // Virgin Island
	COUNTRY_BO, // Bolivia
	COUNTRY_NL, // Netherlands
	COUNTRY_AP, // Asia/Pacific Region
	COUNTRY_NZ, // New Zealand
	COUNTRY_SG, // Singapore
	COUNTRY_ID, // Indonesia
	COUNTRY_NP, // Nepal
	COUNTRY_PH, // Philippines
	COUNTRY_PG, // Papua New Guinea
	COUNTRY_PK, // Pakistan
	COUNTRY_ES, // Spain
	COUNTRY_BS, // Bahamas
	COUNTRY_VC, // Saint Vincent and the Grenadines
	COUNTRY_CL, // Chile
	COUNTRY_NC, // New Caledonia
	COUNTRY_AR, // Argentina
	COUNTRY_DM, // Dominica
	COUNTRY_TK, // Tokelau
	COUNTRY_KH, // Cambodia
	COUNTRY_MO, // Macau
	COUNTRY_MV, // Maldives
	COUNTRY_AF, // Afghanistan
	COUNTRY_FJ, // Fiji
	COUNTRY_MN, // Mongolia
	COUNTRY_WF, // Wallis and Futuna
	COUNTRY_BD, // Bangladesh
	COUNTRY_IE, // Ireland
	COUNTRY_AN, // Netherlands Antilles
	COUNTRY_BE, // Belgium
	COUNTRY_BZ, // Belize
	COUNTRY_BR, // Brazil
	COUNTRY_CH, // Switzerland
	COUNTRY_ZA, // South Africa
	COUNTRY_EG, // Egypt
	COUNTRY_NG, // Nigeria
	COUNTRY_TZ, // Tanzani
	COUNTRY_ZM, // Zambia
	COUNTRY_SN, // Senegal
	COUNTRY_NA, // Namibia
	COUNTRY_CI, // Cote D'Ivoire
	COUNTRY_GH, // Ghana
	COUNTRY_SD, // Sudan
	COUNTRY_CM, // Cameroon
	COUNTRY_MW, // Malawi
	COUNTRY_AO, // Angola
	COUNTRY_KE, // Kenya
	COUNTRY_GA, // Gabon
	COUNTRY_ML, // Mali
	COUNTRY_BJ, // Benin
	COUNTRY_MG, // Madagascar
	COUNTRY_TD, // Chad
	COUNTRY_BW, // Botswana
	COUNTRY_LY, // Libyan Arab Jamahiriya
	COUNTRY_CV, // Cape Verde
	COUNTRY_RW, // Rwanda
	COUNTRY_MZ, // Mozambique
	COUNTRY_GM, // Gambia
	COUNTRY_LS, // Lesotho
	COUNTRY_MU, // Mauritius
	COUNTRY_CG, // Congo
	COUNTRY_UG, // Uganda
	COUNTRY_BF, // Burkina Faso
	COUNTRY_SL, // Sierra Leone
	COUNTRY_SO, // Somalia
	COUNTRY_ZW, // Zimbabwe
	COUNTRY_CD, // Cong
	COUNTRY_NE, // Niger
	COUNTRY_CF, // Central African Republic
	COUNTRY_SZ, // Swaziland
	COUNTRY_TG, // Togo
	COUNTRY_GN, // Guinea
	COUNTRY_LR, // Liberia
	COUNTRY_SC, // Seychelles
	COUNTRY_MA, // Morocco
	COUNTRY_DZ, // Algeria
	COUNTRY_MR, // Mauritania
	COUNTRY_DJ, // Djibouti
	COUNTRY_A2, // Satellite Provider
	COUNTRY_KM, // Comoros
	COUNTRY_RE, // Reunion
	COUNTRY_GQ, // Equatorial Guinea
	COUNTRY_TN, // Tunisia
	COUNTRY_TR, // Turkey
	COUNTRY_BG, // Bulgaria
	COUNTRY_MT, // Malta
	COUNTRY_CZ, // Czech Republic
	COUNTRY_RS, // Serbia
	COUNTRY_EE, // Estonia
	COUNTRY_CY, // Cyprus
	COUNTRY_LB, // Lebanon
	COUNTRY_PL, // Poland
	COUNTRY_LU, // Luxembourg
	COUNTRY_FI, // Finland
	COUNTRY_AT, // Austria
	COUNTRY_PS, // Palestinian Territor
	COUNTRY_AZ, // Azerbaijan
	COUNTRY_RO, // Romania
	COUNTRY_TJ, // Tajikistan
	COUNTRY_LV, // Latvia
	COUNTRY_BY, // Belarus
	COUNTRY_IS, // Iceland
	COUNTRY_HU, // Hungary
	COUNTRY_SK, // Slovakia
	COUNTRY_MK, // Macedonia
	COUNTRY_IQ, // Iraq
	COUNTRY_ME, // Montenegro
	COUNTRY_HR, // Croatia
	COUNTRY_JO, // Jordan
	COUNTRY_YE, // Yemen
	COUNTRY_BA, // Bosnia and Herzegovina
	COUNTRY_LT, // Lithuania
	COUNTRY_OM, // Oman
	COUNTRY_BH, // Bahrain
	COUNTRY_GE, // Georgia
	COUNTRY_SY, // Syrian Arab Republic
	COUNTRY_SI, // Slovenia
	COUNTRY_MD, // Moldov
	COUNTRY_AM, // Armenia
	COUNTRY_AL, // Albania
	COUNTRY_PA, // Panama
	COUNTRY_BN, // Brunei Darussalam
	COUNTRY_LK, // Sri Lanka
	COUNTRY_KW, // Kuwait
	COUNTRY_AX, // Aland Islands
	COUNTRY_AG, // Antigua and Barbuda
	COUNTRY_SM, // San Marino
	COUNTRY_FK, // Falkland Islands (Malvinas)
	COUNTRY_UZ, // Uzbekistan
	COUNTRY_MC, // Monaco
	COUNTRY_HT, // Haiti
	COUNTRY_GU, // Guam
	COUNTRY_JM, // Jamaica
	COUNTRY_UM, // United States Minor Outlying Islands
	COUNTRY_FM, // Micronesi
	COUNTRY_EC, // Ecuador
	COUNTRY_CO, // Colombia
	COUNTRY_PE, // Peru
	COUNTRY_KY, // Cayman Islands
	COUNTRY_HN, // Honduras
	COUNTRY_VG, // Virgin Island
	COUNTRY_NI, // Nicaragua
	COUNTRY_DO, // Dominican Republic
	COUNTRY_GD, // Grenada
	COUNTRY_GT, // Guatemala
	COUNTRY_CR, // Costa Rica
	COUNTRY_SV, // El Salvador
	COUNTRY_VE, // Venezuela
	COUNTRY_BB, // Barbados
	COUNTRY_TT, // Trinidad and Tobago
	COUNTRY_BV, // Bouvet Island
	COUNTRY_MH, // Marshall Islands
	COUNTRY_CK, // Cook Islands
	COUNTRY_GI, // Gibraltar
	COUNTRY_PY, // Paraguay
	COUNTRY_A1, // Anonymous Proxy
	COUNTRY_WS, // Samoa
	COUNTRY_KN, // Saint Kitts and Nevis
	COUNTRY_UY, // Uruguay
	COUNTRY_MP, // Northern Mariana Islands
	COUNTRY_PW, // Palau
	COUNTRY_QA, // Qatar
	COUNTRY_AS, // American Samoa
	COUNTRY_TC, // Turks and Caicos Islands
	COUNTRY_LC, // Saint Lucia
	COUNTRY_VA, // Holy See (Vatican City State)
	COUNTRY_LA, // Lao People's Democratic Republic
	COUNTRY_AW, // Aruba
	COUNTRY_GY, // Guyana
	COUNTRY_SR, // Suriname
	COUNTRY_IM, // Isle of Man
	COUNTRY_VU, // Vanuatu
	COUNTRY_KP, // Kore
	COUNTRY_AI, // Anguilla
	COUNTRY_MS, // Montserrat
	COUNTRY_PM, // Saint Pierre and Miquelon
	COUNTRY_GP, // Guadeloupe
	COUNTRY_MF, // Saint Martin
	COUNTRY_GG, // Guernsey
	COUNTRY_BI, // Burundi
	COUNTRY_TM, // Turkmenistan
	COUNTRY_KG, // Kyrgyzstan
	COUNTRY_MM, // Myanmar
	COUNTRY_BT, // Bhutan
	COUNTRY_LI, // Liechtenstein
	COUNTRY_FO, // Faroe Islands
	COUNTRY_ET, // Ethiopia
	COUNTRY_MQ, // Martinique
	COUNTRY_JE, // Jersey
	COUNTRY_AD, // Andorra
	COUNTRY_AQ, // Antarctica
	COUNTRY_IO, // British Indian Ocean Territory
	COUNTRY_ER, // Eritrea
	COUNTRY_GL, // Greenland
	COUNTRY_GW, // Guinea-Bissau
	COUNTRY_PF, // French Polynesia
	COUNTRY_CU, // Cuba
	COUNTRY_TO, // Tonga
	COUNTRY_TL, // Timor-Leste
	COUNTRY_ST, // Sao Tome and Principe
	COUNTRY_GF, // French Guiana
	COUNTRY_SB, // Solomon Islands
	COUNTRY_TV, // Tuvalu
	COUNTRY_KI, // Kiribati
	COUNTRY_NU, // Niue
	COUNTRY_NF, // Norfolk Island
	COUNTRY_NR, // Nauru
	COUNTRY_YT  // Mayotte
};

#pragma pack 0

forward OnGeoipUpdate( playerid );

stock GetPlayerCountryName( iPlayer )
{
	new
		iCountryIndex = CallRemoteFunction( "GetPlayerCountryIndex", "i", iPlayer ),
		szCountryName[ MAX_COUNTRY_NAME ]
	;
	
	strunpack( szCountryName, g_aszCountryInfo[ iCountryIndex ][ e_szCountryName ] );
	
	return szCountryName;
}

stock bool:GetPlayerCountryNameEx( iPlayer, szCountryName[ ], iSize = sizeof( szCountryName ) )
{
	new
		iCountryIndex = CallRemoteFunction( "GetPlayerCountryIndex", "i", iPlayer )
	;
	
	strunpack( szCountryName, g_aszCountryInfo[ iCountryIndex ][ e_szCountryName ], iSize );
	
	return ( iCountryIndex == 0 ) ? ( false ) : ( true );
}

stock GetPlayerCountryCode( iPlayer )
{
	new
		iCountryIndex = CallRemoteFunction( "GetPlayerCountryIndex", "i", iPlayer ),
		szCountryCode[ MAX_COUNTRY_CODE ]
	;
	
	strunpack( szCountryCode, g_aszCountryInfo[ iCountryIndex ][ e_szCountryCode ] );
	
	return szCountryCode;
}

stock bool:GetPlayerCountryCodeEx( iPlayer, szCountryCode[ ], iSize = sizeof( szCountryCode ) )
{
	new
		iCountryIndex = CallRemoteFunction( "GetPlayerCountryIndex", "i", iPlayer )
	;
	
	strunpack( szCountryCode, g_aszCountryInfo[ iCountryIndex ][ e_szCountryCode ], iSize );
	
	return ( iCountryIndex == 0 ) ? ( false ) : ( true );
}

#define GetPlayerCountryIndex(%0) CallRemoteFunction( "GetPlayerCountryIndex", "i", ( %0 ) )