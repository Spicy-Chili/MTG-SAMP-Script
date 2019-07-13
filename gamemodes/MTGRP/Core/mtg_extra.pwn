/*
#		MTG Extra Code
#		
#
#	By accessing this file, you agree to the following:
#		- You will never give the script or associated files to anybody who is not on the MTG SAMP development team
# 		- You will delete all development materials (script, databases, associated files, etc.) when you leave the MTG SAMP development team.
#
#
#
*/

#include <a_samp>
#include <zcmd>
#include <streamer>

#define NICESKY 0xA65DDEFF

//Label Types
#define LABEL_TYPE_HOUSE			0
#define LABEL_TYPE_BIZ				1
#define LABEL_TYPE_FACTION			2
#define LABEL_TYPE_GANG				3
#define LABEL_TYPE_JOB				4
new Text3D:ArrestLocLabel, Text3D:TruckerSupplyPickupLabel, Text3D:TruckerFuelPickupLabel, Text3D:LSPDFrontDeskLabel, Text3D:VIPHnSLabel, Text3D:VIPLoungeLabel;

#define MAX_GROUPS 			20
#define MAX_HOUSES 			600
#define MAX_FURNI 			50
#define MAX_BUSINESSES 		200
#define MAX_JOBS 			20
#define MAX_PIZZA_POINTS 	40
#define MAX_BIZ_TRASH		4
#define MAX_GANGS			20

//JOB TYPES
#define 	JOB_ARMSDEALER		1
#define 	JOB_MECHANIC 		2
#define 	JOB_DETECTIVE		4
#define 	JOB_DELIVERER		5
#define 	JOB_LAWYER			7
#define 	JOB_FISHERMAN		8
#define 	JOB_CARJACKER		9
#define 	JOB_PIZZABOY		10
#define 	JOB_TRUCKER			11
#define 	JOB_GARBAGEMAN		12

//Party System
#define PARTY_TYPE_OPEN			0
#define PARTY_TYPE_INVITE		1
#define PARTY_TYPE_CLOSED		2
#define MAX_PLAYERS_IN_PARTY	10

#define INDICATOR_TYPE_OFF		0
#define INDICATOR_TYPE_LEFT		1
#define INDICATOR_TYPE_RIGHT	2
#define INDICATOR_TYPE_EMERG	3
#define INDICATOR_TYPE_SIRENS	4

#define MAX_SKINS				311

new House57SafeCode, MatSafeMaterials, MatSafeClosed;

enum PlayerStatistics
{
	pSQL_ID,
	ORM:pORM_ID,
    InterComSys,
	CreationTime[128],
	Password[161],
	pSalt[32],
	AdminLevel,
	HasVoted,
	MedicDuty,
	Float: LastX,
	NineOneOneStep,
	WeaponRefund,
	Float: LastY,
	InterviewPowers,
	FightBox,
	FightKungfu,
	FightKneehead,
	FightGrabkick,
	IsInAnimation,
	FightElbow,
	AnticheatWarns,
	Float: LastZ,
	ResetTimer,
	SpeedHacksWarn,
	HasRadio,
	PersonalRadio,
	LawyerReloadTime,
	Detecting,
	RPTutStep,
	TrackCooldown,
	PendingProposal,
	Harvesting,
	InRally,
	RallyCooldown,
	PendingDivorce,
	ToggledRadio,
	DetectiveCooldown,
	ACWarnTime,
	VipRank,
	VipTime,
	VipRenew,
	CarBeingCarried,
	CarPriceCarried,
	TieTimer,
	LastWorld,
	CollegeMedia,
	CollegeLaw,
	CollegeEng,
	CollegeMath,
	CollegeChem,
	ServerTut,
	WalkieTalkie,
	WalkieFrequency,
	ReportText[128],
	ReportTime,
	LastInterior,
	//Guarding,
	//GuardOffer,
	//GuardPrice,
	FindingCar,
	ActiveCrimeReport[128],
	IsHacker,
	LastSkin,
	Rope,
	Rags,
	Tied,
	SpeedHackWarnTime,
	HasJetpack,
	TiedTime,
	Float: LastHealth,
	Float: LastArmour,
	Float: InitArmour,
	LastLoginMinute,
	LastLoginHour,
	LastLoginDay,
	LastLoginMonth,
	HouseInterior,
	BusinessInterior,
	HouseExterior,
	PhoneN,
	Map,
	Calling,
	CallingTaxi,
	OnTaxiCall,
	ActiveReport,
	BeingCalled,
	CallConnectingTime,
	PlayingHours,
	BusinessExterior,
	ReportingPlayer,
	LastLoginYear,
	CarPriceBeingCarried,
	LastIP[32],
	House,
	House2,
	Banned,
	Muted,
	CellphoneConsole,
	Float: hExtX,
	Float: hExtY,
	Float: hExtZ,
	Float: hIntX,
	Float: hIntY,
	Float: hIntZ,
	hIntID,
	hExtID,
	hExtVW,
	HasSprayCans,
	Float: bExtX,
	Float: bExtY,
	Float: bExtZ,
	Float: bIntX,
	Float: bIntY,
	Float: bIntZ,
	bIntID,
	bExtID,
	InHouse,
	Money,
	CanUseNewbie,
	CanMute,
	WepSlot0,
	ToggedTester,
	SpotlightEffect,
	CarModDelay,
	WepSlot1,
	Job,
	Job2,
	Authenticated,
	InBusiness,
	InGarage,
	WepSlot2,
	WepSlot3,
	GotInCopCar,
	WepSlot4,
	BankMoney,
	WepSlot5,
	WepSlot6,
	CompleteRun,
	LoginAttempts,
	WepSlot7,
	WepSlot8,
	WepSlot9,
	WepSlot10,
	WepSlot11,
	AdminName[25],
	GangPayment,
	NormalName[25],
	Note[128],
	RemoteWarn,
	PhoneBook,
	TicketPrice,
	Ticketing,
	BeingTicketed,
	Blindfolded,
	AdminSkin,
	PendingBETAInvite,
	GivingSlot,
	Identity,
	Gagged,
	//ReportBanStatus,
	//AskBanStatus,
	CheckBalance,
	VipTokens,
	PreLoadedAnims,
	AchievementRank,
	PINAuth,
	PendingCarReceival,
	Accent[64],
	AttendingBackupCall,
	PINUnauthedTime,
	Timer:PINLoginTimer,
	SniperRecoilEffect,
	BeingSpyedOnBy,
	BeingDraggedBy,
	Tester,
	PortableRadio,
	LastKiller,
	RequestingBackup,
	FindingHouse,
	Age,
	AdminPIN,
	AFKStat,
	AFKKicked,
	HadSprunk,
	Gender,
	FailedHits,
	SupplyT,
	SupplyT2,
	SuccessfulHits,
	PrisonDuration,
	PlayerSkinSlot1,
	PlayerSkinSlot2,
	PlayerSkinSlot3,
	OnPhoneTime,
	CollectedFish,
	BankStatus,
	PrisonID,
	PrisonQuestionTimer,
	PrisonQuestionAnswering,
	PrisonQuestionAnswerTime,
	SpamCount,
	AdminDuty,
	PendingInvite,
	Cocaine,
	Pot,
	BaseballBatCount,
	nMuted,
	nMutedLevel,
	nMutedTime,
	vMuted,
	vMutedLevel,
	vMutedTime,
	KnifeCount,
	CopDuty,
	Contract[128],
	Contract2[128],
	AdminActions,
	MarriedTo[25],
	SecondsLoggedIn,
	AttemptingToHeal,
	ContractPrice,
	ModShop,
	AssigningHitTo,
	PlayerToAssasinate,
	BeingAssasinated,
	Tutorial,
	Tazed,
	Materials[3],
	Cuffed,
	InabilityToMatrun,
	InabilityToDropCar,
	HospitalTime,
	Hospitalized,
	MatrunInabilityDuration,
	TutorialStep,
	CriminalOffences,
	MaterialPackages,
	Checkpoint,
	Business,
	TearGasEffect,
	LastCarID,
	gexterior,
	gextid,
	Float: gextx,
	Float: gexty,
	Float: gextz,
	ginterior,
	gintid,
	Float: gintx,
	Float: ginty,
	Float: gintz,
	HandTazer,
	GunTazer,
	CanTaze,
	//Text:FuelTD,
	GunTime,
	CanMakeGun,
	CanDeliver,
	DeliverTime,
	CurrentFightStyle,
	AdminFrozen,
	Float:AdminFrozenHealth,
	PDBadge,
	BannedReason[128],
	BannedBy[25],
	TempbanLevel,
	TempbanTime,
	reportBan[2], // 0 - Timeleft, 1 - Amount of times report banned, 3 = warn. 
	askBan[2], //Same deal as above 
	RequestedBail,
	CaseCooldown,
	//LawyerWaiting,
	CasesWon,
	Attorney,
	BailTime,
	MatRunning,
	Cars[5], // Will equal the SQL ID
	TempKey, // Temp vehicle key, equal to SQL id.
	SpareKeys[5], //Used to track what keys are given and to who
	UnderCover, //For Hitmen
	GasCans, // Used for refill command
	GasFull, // Used for refill command
	VIPPass,
	VIPPassTime,
	PizzaSlices,
	Collisions,
	
	JobCooldown,

	TaxiDuty,
	MechDuty,
	TaxiOccupants[2],
	TaxiFare,
	TaxiCar,
	
	IsAtEvent,
	eventKills,
	TotalEventKills,
	eventTeam, 
	InDerby, 
	eventDeaths, 
	
	//
	nTag[32],

	//Random Ranks
	Developer,
	Mapper,

	//
	Dice,

	Walk[72],

	//name tags test
	Text3D:StatisticsTag,

	//Vehicle Interior
	currentVehInteriorType, // Will represent the vehicle interior type you're in , 0 = NONE.
	currentVehInteriorVW, // Cords will be based on the type

	//Medic Related
	MDuty, // Medic Duty
	EMSCalled, // 0 Being not called, 1 being called (For the patient), 2 accepted
	EMSAccepted, // default will be -1, set to that in Reset
	MyMedic, //The ID of the medic who accepted (Unused)

	//Insurance
	HealthInsurance, // 0 none, 1 saints, 2 general
	HealthInsuranceTime, // Time, UNIX timestamp
	//endof Medic

	OnPayphone,
	CallingPayphone,
	CallConnecting,

	NosBottle, //Mechanic related
	HydroKit,
	EngineParts,

	//Fishing related
	FishAttempts,
	FishAgainAntiSpam,
	CantFish,
	FishingRod,
	FishingBait,
	TotalBass,
	TotalCod,
	TotalSalmon,
	TotalMackerel,
	TotalTuna,
	TotalCarp,
	TotalHerring,
	TotalMarlin,
	TotalMako,
	TotalCrab,
	TotalKraken,
	
	//Delivery related
	Supplies,

	Workbench, //Arms Dealer related
	Toolkit,

	PendingContract[25],
	PendingPrice,
	PendingReason[255],
	PendingReason2[255],

	Tickets, //Cop Tickets (/ticket)
	Race,
	PartyBussin,
	PartyBusTimer,
	PartyBusVehicle,

	PizzaRun,
	Float:PizzaDist,
	PizzaCooldown,
	PizzaCP,
	PizzaPay,
	PizzaTimeCheck,
	CantDeliverPizza,
	PlayerText:PizzaTimer,

	HeadDesc[128],
	BodyDesc[128],
	ClothingDesc[128],
	AccessoryDesc[128],
	MapTP,
	HouseKey,
	
	CasinoChips, //Casino related
	PlayingSlots,
	ReqChipCount,
	
	FavoriteStation[255],
	FavoriteStationSet,
	
	EditTruckerTest,
	DoingTruckerTest,
	TruckingTestCP,
	TruckLicense,
	TruckerTestCooldown,
	
	EditDMVTest,
	CarLicense,
	DoingDMVTest,
	DrivingTestCP,
	
	CreatingRally,
	RallyEditCP,
	RallyCP,
	EnterKey,
	
	//Hotel Related	
	HotelRoomID,
	HotelRoomWarning,
	InHotelRoom,
	
	OffDutyWarns,
	Float:FishPos[3],
	JoinGroupCD,

	SuppliesDelivered,
        SuppliesLoaded,
	TruckDelivery,
	TruckSupplies,
	Timer:TruckLoadTimer,
	Timer:TruckUnloadTimer,
	TruckBiz,
	TruckStage,
	TruckSQLID,
	TruckPenalty,
	
	BusinessKey,
	VehicleRadio,
	BeerCases,
	ModStatus,
	
	HolsteredWeapon[MAX_PLAYER_ATTACHED_OBJECTS],
	LastWeapon,
	SystemAfkKicks,
	AdminAfkKicks,
	
	//MDC
	boloString[50],
	
	PotTimer,
	CocaineTimer,

	//Garbage Man
	GarbageStep,
	GarbageFreeze,
	GarbageCooldown,
	LoadingTrash,
	Timer:GarbageTimer,
	GarbagePay,
	
	IsTabbed,
	PrisonReason[128],
	AdminNote1[128],
	AdminNote2[128],
	AdminNote3[128],
	PickingBillboard,
	SkillCooldown, 
	WantedLevel, 
	LicenseSuspended, 
	YiniStatus, 
	FightStyle, 
	HideWeapons,
	Speed,
	SpeedTimer,
	GrowLight,
	PotSeeds,
	AdminRadio,
	Text3D:PizzaPointLabel[MAX_PIZZA_POINTS],
	SpeakerPhone,
	ToyBanned,
	LandOwned,
	
	Refilling,
	Timer:RefuelTimer,
	
	HungerLevel,
	HungerEffect,
	HungerEnabled,
	IsSprinting,
	HasBoombox,
	
	SleepCooldown,
	IsSleeping,
	
	//Holiday Things
	
	//Chrismas stuff
	TotalSSDeposits,
	LastDepositHours, //Playing hour number
	LastRedeemHours, //Playing hour number
	
	//Halloween
	KilledByJason,
	GainedHalloweenPrize,
	ClaimedHalloweenPrize,
	InHalloweenMaze,
	
	//Easter
	EggsCollected,
	
	//4th of July
	GokartLapsDone,
	GokartPrizeReceived,
	pFireworks,
	PlayerGokart,
	
	Text3D:FurniLabels[MAX_FURNI],
	
	Warning1[128],
	Warning2[128],
	Warning3[128],

	LastDeathReason,
	
	FirstSpawn,
	
	//Group Related
	InGroupHQ,
	Group,
	GroupRank,	
	
	Gang,
	GangRank,
	InGangHQ,

	//Job Stat Tracking
	Tracks,
	ArmsDealerXP, 
	TotalFished,
	Deliveries,
	PizzaDelivers,
	TotalCarsDropped,
	CarJackerXP,
	
	TotalGunsMade,
	TotalGarbageRuns,
	TotalTruckRuns,
	TotalToolkitsBroken,
	TotalFishingRodsBroken,
	TotalDeaths,
	TotalKrakensCaught,
	TotalCarsFixed,
	TotalMatRuns, 
	
	//Hotwiring
	HotwireTimeLeft,
	PlayerText:HotwireAnsLoc,
	HotwirePuzzlesSolved,
	
	//Party System
	PlayerParty,
	PlayerPartyType,
	PartyTotalMemberCount,
	PartyPendingInvite,
	PartyMatsLoc,
	
	InPlayerParty,
	
	//Lottery
	LottoTicket,
	

	//LSPD Sirens
	SirenKit,
	
	AutoParkCar,
	
	//Prison Vars
	SolitaryDuration,
	PrisonTickets,
	PrisonScrewdriver,
	PrisonShank,
	PrisonRazor,
	Cigarettes,
	PrisonDice,
	PrisonLighter,
	PrisonLitter,
	SmuggleCooldown,
	PrisonBuyItemCooldown,
	PrisonLifer,
	PrisonJobCooldown,

	ropes[4],

	//Loyalty Program
	LoyaltyPoints,
	LoyaltyStreak,
	LoyaltyDailyStreak,
	LoyaltyDailyStreakDay,
	LoyaltyPendingVip,
	LoyaltyPendingVipHours,
	LoyaltyVipRank,
	LoyaltyVipHoursLeft,
	LoyaltyPaycheckBoost,
	LoyaltyPaycheckBoostTimeLeft,
	LastLoyaltyDay,
	LastLoyaltyMonth,
	LastLoyaltyYear,
	LoyaltyRewards[256],
	
	Tent,
	TentBan,
	
	Headphones,
	
	Note1[256],
	Note2[256],
	Note3[256],
	Notepad,
	MaskShowTag[10],
	Mask,
	MaskID,
	MaskBan,

	Loan,
	LoanNotPaid,
	LoanTime,
	CannotLoanTime,
	FakeIDString[256],
	FakeLicense[256],
	
	CannotBail,
	ToyCount,

	//Anti-CLEO Slapping
	Float:oldXVel,
	Float:oldYVel,
	Float:oldZVel,
	
	//Anti-AFK
	Float:oldXPos,
	Float:oldYPos,
	
	//Anti-FakeShot
	LastShotTime,
	FakeShotDetected,

	HasArmour,
	CannotArmour,

	Float:Wep3Pos[6],
	Float:Wep5Pos[6],
	Float:Wep6Pos[6],
	EditedWeapon[3],
	
	//Plague
	Infected,
	VirusCount,
	HasGasMask,
	WearingGasMask,
	Float:GasMaskOffsets[9],
	Timer:Blackout,
	BlackoutCount,
	Timer:PassedOutTimer,
	PassedOut,
	
	Ventillation,

	Bomb,
	GunLicense,
	//Viewing House Timer
	Timer:ViewingHouseTimer,
	
	LoyaltyNTag,
	
//	Timer:BeingDraggedTimer,
	PhoneGPS,
};

new Player[MAX_PLAYERS][PlayerStatistics];
new TempPlayer[MAX_PLAYERS][PlayerStatistics]; 
#define MAX_TOYS			20
enum PlayerToyData
{
	ToySQLID[MAX_TOYS],
	ToyIndex[MAX_TOYS],
	ToyBone[MAX_TOYS],
	ToyModelID[MAX_TOYS],
	Float:ToyXOffset[MAX_TOYS],
	Float:ToyYOffset[MAX_TOYS],
	Float:ToyZOffset[MAX_TOYS],
	Float:ToyXRot[MAX_TOYS],
	Float:ToyYRot[MAX_TOYS],
	Float:ToyZRot[MAX_TOYS],
	Float:ToyXScale[MAX_TOYS],
	Float:ToyYScale[MAX_TOYS],
	Float:ToyZScale[MAX_TOYS],
};
new PlayerToys[MAX_PLAYERS][PlayerToyData];

enum HouseData
{
	ORM:ORM_ID,
	HouseSQL,
	hInteriorID,
	Float: hInteriorX,
	Float: hInteriorY,
	Float: hInteriorZ,
	HousePrice,
	hExteriorID,
	hExteriorVW,
	Float: hExteriorX,
	Float: hExteriorY,
	Float: hExteriorZ,
	HouseCocaine,
	HousePot,
	HouseMaterials[3],
	HouseSpeed,
	Weapons[5],
	VaultMoney,
	HouseStorage[500],
	HouseStorageSize,
	HouseStorageBase,
	HouseStorageExtra,
	HPickupID,
	hOwner[255],
	LockStatus,
	Keypad,
	RadioURL[100],
	Radio,
	RadioInstalled,
	Workbench,
	hBeers,
	hPizzas,
	KeyHolder1[24],
	KeyHolder2[24],
	PotGrow[2],
	PotTime[2],
	GrowLightInstalled,
	HouseType,
	Text3D:hLabel,
	VentUpgrade,
	hFakeOwner,
};
new Houses[MAX_HOUSES][HouseData];

#define MAX_SLOTS 10
enum GroupData
{
	ORM:ORM_ID,
	GroupSQL,
	GroupName[255],
	CommandTypes,
	RankName0[255],
	RankName1[255],
	RankName2[255],
	RankName3[255],
	RankName4[255],
	RankName5[255],
	RankName6[255],
	RankName7[255],
	RankName8[255],
	RankName9[255],
	RankName10[255],
	Skin0,
	SavedCrack,
	SavedPot,
	Skin1,
	Skin2,
	Skin3,
	Skin4,
	Skin5,
	Skin6,
	Skin7,
	Skin8,
	Skin9,
	Skin10,
	Skin11,
	Skin12,
	HQInteriorID,
	Float: HQInteriorX,
	ChatDisabled,
	Float: HQInteriorY,
	Float: HQInteriorZ,
	HQExteriorID,
	Float: HQExteriorX,
	Float: HQExteriorY,
	Float: HQExteriorZ,
	Float: HQExterior2[3],
	HQExteriorID2,
	HQExteriorVW2,
	Float: HQInterior2[3],
	HQInteriorID2,
	HQPickup2,
	HQMapIcon2,
	HQLock2,
	Float: SafeX,
	Float: SafeY,
	Float: SafeZ,
	SafeInteriorID,
	SafeWorld,
	SafeMoney,
	DisbandHour,
	DisbandMinute,
	DisbandDay,
	DisbandMonth,
	MOTD[255],
	DisbandYear,
	SafePickupID,
	HQPickupID,
	HQLock,
	SavedMats[3],
	SavedSpeed,
	MemberCount,
	FeeCooldown,
	MaxMembers,
	
	//Casino related
	slotsUsed[MAX_SLOTS],
	Float:slotsX[MAX_SLOTS],
	Float:slotsY[MAX_SLOTS],
	Float:slotsZ[MAX_SLOTS],
	Text3D:slots3D[MAX_SLOTS],
	Float:ChipPos[3],
	ChipsPickup,
	ChipsVW,
	ChipShopLock,
	Chips,
	SlotPrizes[6],
	mapIcon,
	Text3D:fLabel,
	Text3D:fLabel2,
	Text3D:fSafeLabel,
	Text3D:ChipexLabel,
	
	PayForFuel,
};
new Groups[MAX_GROUPS][GroupData];

#define MAX_PUMPS 2
enum BusinessData
{
	ORM:ORM_ID,
	BusinessSQL,
	Float: bExteriorX,
	Float: bExteriorY,
	Float: bExteriorZ,
	bExteriorID,
	Float: bInteriorX,
	Float: bInteriorY,
	Float: bInteriorZ,
	bInteriorID,
	Float: bInteractX,
	Float: bInteractY,
	Float: bInteractZ,
	bInteractCP,
	bType,
	bVault,
	bPrice,
	bProductPrice1,
	bProductPrice2,
	bProductPrice3,
	bProductPrice4,
	bProductPrice5,
	bProductPrice6,
	bProductPrice7,
	SupplyStatus,
	bProductPrice8,
	bProductPrice9,
	bProductPrice10,
	bProductPrice11,
	bProductPrice12,
	bProductPrice13,
	bProductPrice14,
	bProductPrice15,
	bSupplies,
	bMaxSupplies,
	bOwner[255],
	bSupplyStatus,
	bLockStatus,
	bPickupID,
	bName[255],
	//Gas
	Float:GasX[MAX_PUMPS],
	Float:GasY[MAX_PUMPS],
	Float:GasZ[MAX_PUMPS],
	GasVolume,
	//GasPrice,
	GasPump[MAX_PUMPS],
	Text3D:GasText[MAX_PUMPS],
	RadioInstalled,
	InterComInstalled,
	Radio,
	RadioURL[100],
 	bSupplyPrice,
	bFoodName1[32],
	bFoodName2[32],
	bFoodName3[32],
	bFoodName4[32],
	TotalHotelRooms, 
	Float:FuelPointX,
	Float:FuelPointY,
	Float:FuelPointZ,
	
	bLinkedGroup,
	bSafePickup,
	Float:bSafeX,
	Float:bSafeY,
	Float:bSafeZ,
	bMaterials[3],
	bCocaine,
	bPot,
	bSpeed,
	bArmour[3],
	
	bKeyOwner1[25],
	bKeyOwner2[25],
	mapIcon,
	Weapons[2],
	bStorage,
	
	Float:BusinessTrashPos[3],
	Float:BusinessTrashRot[3],
	BusinessTrashCurrentPlayer,
	BusinessTrashAmount,
	BusinessTrashBinObject,
	BusinessTrashObjects[MAX_BIZ_TRASH],
	BusinessTrashStatus,
	Text3D:bLabel,
	bWorkbench,
};
new Businesses[MAX_BUSINESSES][BusinessData];

enum Vehicle_Data
{
	SQLID,
	Link,
	Model,
	Color1,
	Color2,
	Float:vX,
	Float:vY,
	Float:vZ,
	Float:vAngle,
	vInt,
	vVWorld,
	Respawn,
	Mod0,
	Mod1,
	Mod2,
	Mod3,
	Mod4,
	Mod5,
	Mod6,
	Mod7,
	Mod8,
	Mod9,
	Mod10,
	Mod11,
	Mod12,
	Mod13,
	
	//Group Stuff
	Group,
	GangLink,
	
	Job,
	Owner[24],
	LastDriver[24], 
	Fuel,
	// Weapons[3],
	VName[50],
	PaintJob,
	Plate[32],
	VIP,
	Float:vHealth,
	lockState,
	spawnState,
	damageState,
	windowState,
	radioState, // 0 off, 1 on
	radioUrl[100],
	impounded,
	ImpoundCount,
	ImpoundTime[64],
	Hood,
	Trunk,
	//Bomb,
	//windowStatus, // up / down
	attachedInteriorType, // For interiors you can enter (0 = none)
	attachedInteriorLock, // 0 = unlocked
	intCap, // max 6 for enf
	RadioInstalled,
	Registered,
	TrunkContents[255],
	
	//Indicator Lights
	IndicatorType,
	IndicatorSpeed,
	Timer:IndicatorTimer,
	IndicatorStep,
	AutoIndicatorsDisabled,
	
	//Siren Info
	SirenType,
	SirenObjectID[2],
	
	GunRack[2],
}
new Veh[MAX_VEHICLES][Vehicle_Data];
new VehicleEdit[MAX_PLAYERS][Vehicle_Data];

enum JobData
{
	ORM:ORM_ID,
	JobSQL,
	JobName[255],
	Float: JobJoinPosX,
	Float: JobJoinPosY,
	Float: JobJoinPosZ,
	JobJoinPosWorld,
	JobJoinPosPickupID,
	JobJoinPosInterior,
	Float: JobMiscLocationOneX,
	Float: JobMiscLocationOneY,
	Float: JobMiscLocationOneZ,
	JobMiscLocationOneWorld,
	JobMiscLocationOnePickupID,
	JobMiscLocationOneInterior,
	Float: JobMiscLocationTwoX,
	Float: JobMiscLocationTwoY,
	Float: JobMiscLocationTwoZ,
	JobMiscLocationTwoWorld,
	JobMiscLocationTwoPickupID,
	JobMiscLocationTwoInterior,
	JobMiscLocationOneMessage[255],
	JobMiscLocationTwoMessage[255],
	JobType,
	JobCrimeLimit, 
	Text3D:jLabel,
	Text3D:Loc1Label,
	Text3D:Loc2Label,
};
new Jobs[MAX_JOBS][JobData];

#define MAX_BILLBOARDS 36
enum BillboardData
{
	Object,
	Creator[25],
	AdText[128],
	Checkpoint[MAX_PLAYERS],
	TimeLeft,
	BackgroundColour,
	TextColour,
}
new Billboards[MAX_BILLBOARDS][BillboardData];


enum SpecData
{
	Float: SpecPlayerX,
	Float: SpecPlayerY,
	Float: SpecPlayerZ,
	SpecPlayerInterior,
	Float: SpecPlayerAngle,
	SpecPlayerWorld,
	SpecSpectatingPlayer,
	SpecSpectatingState,
	SpecSpectatingVehicle,
};
new Spectator[MAX_PLAYERS][SpecData];

new Float:BillboardObjects[][7] =
{
	{7911.0, 1431.48, 2446.59, 27.26,   0.00, 0.00, 104.98},
	{7907.0, 1729.81, 2488.37, 27.26,   0.00, 0.00, 285.00},
	{7912.0, 1386.16, 2381.15, 31.16,   0.00, 0.00, 0.00},
	{7900.0, 1808.25, 2349.20, 27.15,   0.00, 0.00, 0.00},
	{7902.0, 1809.75, 2162.03, 31.88,   0.00, 0.00, 104.99},
	{7903.0, 1805.57, 2065.60, 31.88,   0.00, 0.00, -75.00},
	{7909.0, 1785.60, 1979.20, 25.27,   0.00, 0.00, 0.00},
	{7910.0, 1785.60, 1791.85, 25.27,   0.00, 0.00, 0.00},
	{8330.0, 1787.55, 1476.59, 25.98,   0.00, 0.00, 0.00},
	{8331.0, 1771.84, 1210.63, 28.53,   0.00, 0.00, 0.00},
	{8332.0, 1787.74, 1077.29, 25.98,   0.00, 0.00, 0.00},
	{8293.0, 1775.75, 887.63, 29.81,   0.00, 0.00, 0.00},
	{8310.0, 1624.79, 818.96, 27.31,   0.00, 0.00, 0.00},
	{8329.0, 1274.16, 844.86, 28.83,   0.00, 0.00, 0.00},
	{8292.0, 1076.90, 793.67, 30.01,   0.00, 0.00, 0.00},
	{8328.0, 1203.42, 882.96, 29.08,   0.00, 0.00, 0.00},
	{8327.0, 1242.08, 1087.66, 27.59,   0.00, 0.00, 0.00},
	{7914.0, 1108.45, 2075.27, 31.16,   0.00, 0.00, 90.00},
	{7915.0, 1005.16, 2178.40, 31.16,   0.00, 0.00, 0.00},
	{7913.0, 1261.08, 2076.16, 31.16,   0.00, 0.00, 90.00},
	{9189.0, 1551.28, 2184.59, 31.88,   0.00, 0.00, 104.99},
	{7901.0, 1715.68, 2282.52, 31.16,   0.00, 0.00, 0.00},
	{7300.0, 2189.30, 2514.77, 29.65,   0.00, 0.00, 0.00},
	{7908.0, 1990.84, 2557.73, 27.26,   0.00, 0.00, 285.00},
	{7906.0, 1852.72, 2495.72, 27.26,   0.00, 0.00, 104.96},
	{7301.0, 2616.80, 2535.66, 26.40,   0.00, 0.00, 0.00},
	{7302.0, 2736.67, 2160.30, 27.41,   0.00, 0.00, 0.00},
	{7303.0, 2697.72, 1862.33, 27.41,   0.00, 0.00, 180.12},
	{9191.0, 2730.98, 1616.82, 27.21,   0.00, 0.00, 180.00},
	{9190.0, 2707.32, 1501.45, 27.21,   0.00, 0.00, 0.00},
	{9189.0, 2754.63, 1460.72, 24.69,   0.00, 0.00, 150.00},
	{9187.0, 2755.28, 1398.02, 27.60,   0.00, 0.00, 104.90},
	{9188.0, 2730.03, 1386.05, 27.21,   0.00, 0.00, 180.00},
	{9186.0, 2710.51, 957.52, 30.08,   0.00, 0.00, 195.00},
	{9185.0, 2435.07, 819.09, 27.79,   0.00, 0.00, 104.94},
	{9184.0, 2097.45, 900.77, 31.75,   0.00, 0.00, 330.00}
};

//#define MAX_HOTEL_ROOMS		17
/*enum hrStats
{
	hrOwner[24],
	hrPot,
	hrCocaine,
	hrMaterials,
	hrWeapon, 
	hrLockStatus, 
	hrIcon,
	hrRentPrice,
	Float:hrExtPos[3], // 0 - X Pos, 1 - Y Pos, 2 - Z Pos
	hrExtVW,
	Float:hrIntPos[3], // 0 - X Pos, 1 - Y Pos, 2 - Z Pos
	hrIntID,
	hrIntVW, 
	hrSpeed, 
	Text3D:hrLabel,
}; */
//new hRoom[MAX_BUSINESSES][MAX_HOTEL_ROOMS][hrStats];

/* RADIO */
#define MAX_RADIO_STATIONS 10
enum RadioOptions
{
	Available, //If the station can be streamed with cradio/hradio/bradio (1 = yes)
	StationName[128], //Name of the station
	URL[255], //URL of the station
}
new RadioSettings[MAX_RADIO_STATIONS][RadioOptions];
/* RADIO */

new vNames[212][] =
{
	"Landstalker", "Bravura", "Buffalo", "Linerunner", "Perenniel", "Sentinel", "Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus",
	"Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam", "Esperanto", "Taxi", "Washington", "Bobcat", "Mr Whoopee", "BF Injection",
	"Hunter", "Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie",
	"Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral", "Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder",
	"Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair", "Berkley's RC Van", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider",
	"Glendale", "Oceanic", "Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR 350", "Walton", "Regina",
	"Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick", "News Chopper", "Rancher", "FBI Rancher", "Virgo", "Greenwood",
	"Jetmax", "Hotring", "Sandking", "Blista Compact", "Police Maverick", "Boxville", "Benson", "Mesa", "RC Goblin", "Hotring Racer A", "Hotring Racer B",
	"Bloodring Banger", "Rancher", "Super GT", "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropdust", "Stunt", "Tanker", "RoadTrain",
	"Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra", "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Tow Truck", "Fortune", "Cadrona", "FBI Truck",
	"Willard", "Forklift", "Tractor", "Combine", "Feltzer", "Remington", "Slamvan", "Blade", "Freight", "Streak", "Vortex", "Vincent", "Bullet", "Clover",
	"Sadler", "Firetruck", "Hustler", "Intruder", "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada", "Yosemite", "Windsor", "Monster A",
	"Monster B", "Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito", "Freight", "Trailer",
	"Kart", "Mower", "Duneride", "Sweeper", "Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400", "Newsvan", "Tug", "Trailer A", "Emperor",
	"Wayfarer", "Euros", "Hotdog", "Club", "Trailer B", "Trailer C", "Andromada", "Dodo", "RC Cam", "Launch", "Police Car (LSPD)", "Police Car (SFPD)",
	"Police Car (LVPD)", "Police Ranger", "Picador", "S.W.A.T. Van", "Alpha", "Phoenix", "Glendale", "Sadler", "Luggage Trailer A", "Luggage Trailer B",
	"Stair Trailer", "Boxville", "Farm Plow", "Utility Trailer"};

new FishingZones[][] =
{
	"Verona Beach", "Santa Maria Beach", "Los Santos",
	"Flint County", "Verdant Bluffs", "Ocean Docks",
	"Playa del Seville", "East Beach", "Red County",
	"The Mako Span", "Las Venturas", "San Fierro",
	"Fallow Bridge", "Tierra Robada", "Sherman Reservoir",
	"Kincaid Bridge", "Garver Bridge", "Esplanade East",
	"Esplanade North", "San Fierro Bay", "Bayside",
	"Gant Bridge", "Palisades", "Ocean Flats",
	"Foster Valley", "Shady Creeks", "San Andreas"};

new WeaponNames[47][] =
{
	"0 - Fists", "1 - Brass Knuckles", "2 - Golf Club", "3 - Nite Stick", "4 - Knife", "5 - Baseball Bat", "6 - Shovel", "7 - Pool Cue", "8 - Katana", "9 - Chainsaw", "10 - Purple Dildo", "11 - Small White Vibrator", "12 - Large White Vibrator", "13 - Silver Vibrator",
	"14 - Flowers", "15 - Cane", "16 - Grenade", "17 - Tear Gas", "18 - Molotov Cocktail", "19 - Jetpack", "20 - Nothing", "21 - Nothing", "22 - Colt 45 (9mm)", "23 - Silenced Pistol", "24 - Desert Eagle", "25 - Pump Action Shotgun", "26 - Sawn-off Shotgun", "27 - SPAS-12 (Combat Shotgun",
	"28 - Micro SMG", "29 - MP5", "30 - AK47", "31 - M4A1", "32 - Tec-9", "33 - Country Rifle", "34 - Sniper Rifle", "35 - Rocket Launcher", "36 - HS Rocket Launcher", "37 - Flamethrower", "38 - Minigun", "39 - Satchel Charge", "40 - Detonator", "41 - Spraycan", "42 - Fire Extinguisher",
	"43 - Camera", "44 - Nightvision Goggles", "45 - Thermal Goggles", "46 - Parachute"};

new weapons[47][] =
{
	"Fists", "Brass Knuckles", "Golf Club", "Nite Stick", "Knife", "Baseball Bat", "Shovel", "Pool Cue", "Katana", "Chainsaw", "Purple Dildo", "Small White Vibrator", "Large White Vibrator", "Silver Vibrator",
	"Flowers", "Cane", "Grenade", "Tear Gas", "Molotov Cocktail", "Nothing", "Nothing", "Nothing", "Colt 45", "Silenced Pistol", "Desert Eagle", "Pump Action Shotgun", "Sawn-off Shotgun", "Combat Shotgun",
	"Micro SMG", "MP5", "AK47", "M4A1", "Tec-9", "Country Rifle", "Sniper Rifle", "Rocket Launcher", "HS Rocket Launcher", "Flamethrower", "Minigun", "Satchel Charge", "Detonator", "Spraycan", "Fire Extinguisher",
	"Camera", "Nightvision Goggles", "Thermal Goggles", "Parachute"};

new VehicleNames[212][] =
{
	"400 - Landstalker",   "401 - Bravura",   "402 - Buffalo",   "403 - Linerunner",   "404 - Perenniel",   "405 - Sentinel",   "406 - Dumper",   "407 - Firetruck",   "408 - Trashmaster",   "409 - Stretch",
	"410 - Manana",   "411 - Infernus",   "412 - Voodoo",   "413 - Pony",   "414 - Mule",   "415 - Cheetah",   "416 - Ambulance",   "417 - Leviathan",   "418 - Moonbeam",   "419 - Esperanto",   "420 - Taxi",
	"421 - Washington",   "422 - Bobcat",   "423 - Mr Whoopee",   "424 - BF Injection",   "425 - Hunter",   "426 - Premier",   "427 - Enforcer",   "428 - Securicar",   "429 - Banshee",   "430 - Predator",
	"431 - Bus",   "432 - Rhino",   "433 - Barracks",   "434 - Hotknife",   "435 - Trailer",   "436 - Previon",   "437 - Coach",   "438 - Cabbie",   "439 - Stallion",   "440 - Rumpo",   "441 - RC Bandit",	"442 - Romero",
	"443 - Packer",   "444 - Monster",   "445- Admiral",   "446 - Squalo",   "447 - Seasparrow",   "448 - Pizzaboy",   "449 - Tram",   "450 - Trailer",   "451 - Turismo",   "452 - Speeder",   "453 - Reefer",   "454 - Tropic",   "455 - Flatbed",
	"456 - Yankee",   "457 - Caddy",   "458 - Solair",   "459 - Berkley's RC Van",   "460 - Skimmer",   "461 - PCJ-600",   "462 - Faggio",   "463 - Freeway",   "464 - RC Baron",   "465 - RC Raider",
	"466 - Glendale",   "467 - Oceanic",   "468 - Sanchez",   "469 - Sparrow",   "470 - Patriot",   "471 - Quad",   "472 - Coastguard",   "473 - Dinghy",   "474 - Hermes",   "475 - Sabre",   "476 - Rustler",
	"477 - ZR 350",   "478 - Walton",   "479 - Regina",   "480 - Comet",   "481 - BMX",   "482 - Burrito",   "483 - Camper",   "484 - Marquis",   "485 - Baggage",   "486 - Dozer",   "487 - Maverick",   "488 - News Chopper",
	"489 - Rancher",   "490 - FBI Rancher",   "491 - Virgo",   "492 - Greenwood",   "493 - Jetmax",   "494 - Hotring",   "495 - Sandking",   "496 - Blista Compact",   "497 - Police Maverick",
	"498 - Boxville",   "499 - Benson",   "500 - Mesa",   "501 - RC Goblin",   "502 - Hotring Racer",   "503 - Hotring Racer",   "504 - Bloodring Banger",   "505 - Rancher",   "506 - Super GT",
	"507 - Elegant",   "508 - Journey",   "509 - Bike",   "510 - Mountain Bike",   "511 - Beagle",   "512 - Cropdust",   "513 - Stunt",   "514 - Tanker",   "515 - RoadTrain",   "516 - Nebula",   "517 - Majestic",
	"518 - Buccaneer",   "519 - Shamal",   "520 - Hydra",   "521 - FCR-900",   "522 - NRG-500",   "523 - HPV1000",   "524 - Cement Truck",   "525 - Tow Truck",   "526 - Fortune",   "527 - Cadrona",   "528 - FBI Truck",
	"529 - Willard",   "530 - Forklift",   "531 - Tractor",   "532 - Combine",   "533 - Feltzer",   "534 - Remington",   "535 - Slamvan",   "536 - Blade",   "537 - Freight",   "538 - Streak",   "539 - Vortex",   "540 - Vincent",
	"541 - Bullet",   "542 - Clover",   "543 - Sadler",   "544 - Firetruck",   "545 - Hustler",   "546 - Intruder",   "547 - Primo",   "548 - Cargobob",   "549 - Tampa",   "550 - Sunrise",   "551 - Merit",   "552 - Utility",
	"553 - Nevada",   "554 - Yosemite",   "555 - Windsor",   "556 - Monster",   "557 - Monster",   "558 - Uranus",   "559 - Jester",   "560 - Sultan",   "561 - Stratum",   "562 - Elegy",   "563 - Raindance",   "564 - RC Tiger",
	"565 - Flash",   "566 - Tahoma",   "567 - Savanna",   "568 - Bandito",   "569 - Freight",   "570 - Trailer",   "571 - Kart",   "572 - Mower",   "573 - Duneride",   "574 - Sweeper",   "575 - Broadway",
	"576 - Tornado",   "577 - AT-400",   "578 - DFT-30",   "579 - Huntley",   "580 - Stafford",   "581 - BF-400",   "582 - Newsvan",   "583 - Tug",   "584 - Trailer",   "585 - Emperor",   "586 - Wayfarer",
	"587 - Euros",   "588 - Hotdog",   "589 - Club",   "590 - Trailer",   "591 - Trailer",   "592 - Andromada",   "593 - Dodo",   "594 - RC Cam",   "595 - Launch",   "596 - Police Car (LSPD)",   "597 - Police Car (SFPD)",
	"598 - Police Car (LVPD)",   "599 - Police Ranger",   "600 - Picador",   "601 - S.W.A.T. Van",   "602 - Alpha",   "603 - Phoenix",   "604 - Glendale",   "605 - Sadler",   "606 - Luggage Trailer A",
	"607 - Luggage Trailer B",   "608 - Stair Trailer",   "609 - Boxville",   "610 - Farm Plow",   "611 - Utility Trailer"};

new legalmods[48][22] =
{
	{400, 1024,1021,1020,1019,1018,1013,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
	{401, 1145,1144,1143,1142,1020,1019,1017,1013,1007,1006,1005,1004,1003,1001,0000,0000,0000,0000},
	{404, 1021,1020,1019,1017,1016,1013,1007,1002,1000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
	{405, 1023,1021,1020,1019,1018,1014,1001,1000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
	{410, 1024,1023,1021,1020,1019,1017,1013,1007,1003,1001,0000,0000,0000,0000,0000,0000,0000,0000},
	{415, 1023,1019,1018,1017,1007,1003,1001,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
	{418, 1021,1020,1016,1006,1002,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
	{420, 1021,1019,1005,1004,1003,1001,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
	{421, 1023,1021,1020,1019,1018,1016,1014,1000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
	{422, 1021,1020,1019,1017,1013,1007,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
	{426, 1021,1019,1006,1005,1004,1003,1001,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
	{436, 1022,1021,1020,1019,1017,1013,1007,1006,1003,1001,0000,0000,0000,0000,0000,0000,0000,0000},
	{439, 1145,1144,1143,1142,1023,1017,1013,1007,1003,1001,0000,0000,0000,0000,0000,0000,0000,0000},
	{477, 1021,1020,1019,1018,1017,1007,1006,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
	{478, 1024,1022,1021,1020,1013,1012,1005,1004,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
	{489, 1024,1020,1019,1018,1016,1013,1006,1005,1004,1002,1000,0000,0000,0000,0000,0000,0000,0000},
	{491, 1145,1144,1143,1142,1023,1021,1020,1019,1018,1017,1014,1007,1003,0000,0000,0000,0000,0000},
	{492, 1016,1006,1005,1004,1000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
	{496, 1143,1142,1023,1020,1019,1017,1011,1007,1006,1003,1002,1001,0000,0000,0000,0000,0000,0000},
	{500, 1024,1021,1020,1019,1013,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
	{516, 1021,1020,1019,1018,1017,1016,1015,1007,1004,1002,1000,0000,0000,0000,0000,0000,0000,0000},
	{517, 1145,1144,1143,1142,1023,1020,1019,1018,1017,1016,1007,1003,1002,0000,0000,0000,0000,0000},
	{518, 1145,1144,1143,1142,1023,1020,1018,1017,1013,1007,1006,1005,1003,1001,0000,0000,0000,0000},
	{527, 1021,1020,1018,1017,1015,1014,1007,1001,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
	{529, 1023,1020,1019,1018,1017,1012,1011,1007,1006,1003,1001,0000,0000,0000,0000,0000,0000,0000},
	{534, 1185,1180,1179,1178,1127,1126,1125,1124,1123,1122,1106,1101,1100,0000,0000,0000,0000,0000},
	{535, 1121,1120,1119,1118,1117,1116,1115,1114,1113,1110,1109,0000,0000,0000,0000,0000,0000,0000},
	{536, 1184,1183,1182,1181,1128,1108,1107,1105,1104,1103,0000,0000,0000,0000,0000,0000,0000,0000},
	{540, 1145,1144,1143,1142,1024,1023,1020,1019,1018,1017,1007,1006,1004,1001,0000,0000,0000,0000},
	{542, 1145,1144,1021,1020,1019,1018,1015,1014,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
	{546, 1145,1144,1143,1142,1024,1023,1019,1018,1017,1007,1006,1004,1002,1001,0000,0000,0000,0000},
	{547, 1143,1142,1021,1020,1019,1018,1016,1003,1000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
	{549, 1145,1144,1143,1142,1023,1020,1019,1018,1017,1012,1011,1007,1003,1001,0000,0000,0000,0000},
	{550, 1145,1144,1143,1142,1023,1020,1019,1018,1006,1005,1004,1003,1001,0000,0000,0000,0000,0000},
	{551, 1023,1021,1020,1019,1018,1016,1006,1005,1003,1002,0000,0000,0000,0000,0000,0000,0000,0000},
	{558, 1168,1167,1166,1165,1164,1163,1095,1094,1093,1092,1091,1090,1089,1088,0000,0000,0000,0000},
	{559, 1173,1162,1161,1160,1159,1158,1072,1071,1070,1069,1068,1067,1066,1065,0000,0000,0000,0000},
	{560, 1170,1169,1141,1140,1139,1138,1033,1032,1031,1030,1029,1028,1027,1026,0000,0000,0000,0000},
	{561, 1157,1156,1155,1154,1064,1063,1062,1061,1060,1059,1058,1057,1056,1055,1031,1030,1027,1026},
	{562, 1172,1171,1149,1148,1147,1146,1041,1040,1039,1038,1037,1036,1035,1034,0000,0000,0000,0000},
	{565, 1153,1152,1151,1150,1054,1053,1052,1051,1050,1049,1048,1047,1046,1045,0000,0000,0000,0000},
	{567, 1189,1188,1187,1186,1133,1132,1131,1130,1129,1102,0000,0000,0000,0000,0000,0000,0000,0000},
	{575, 1177,1176,1175,1174,1099,1044,1043,1042,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
	{576, 1193,1192,1191,1190,1137,1136,1135,1134,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
	{580, 1023,1020,1018,1017,1007,1006,1001,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000,0000},
	{589, 1145,1144,1024,1020,1018,1017,1016,1013,1007,1006,1005,1004,1000,0000,0000,0000,0000,0000},
	{600, 1022,1020,1018,1017,1013,1007,1006,1005,1004,0000,0000,0000,0000,0000,0000,0000,0000,0000},
	{603, 1145,1144,1143,1142,1024,1023,1020,1019,1018,1017,1007,1006,1001,0000,0000,0000,0000,0000}
};

new wepsize[47] =
{
	0, 1, 1, 1,	1, 1, 1, 1,	1, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 2, 1, 3, 1, 2, 3, 3,	1, 2, 3, 5,	6, 5, 8, 1,	1, 1, 1, 1, 0, 0, 1
};

stock GetName(playerid)
{
	new Name[MAX_PLAYER_NAME];

	if(IsPlayerConnected(playerid))
	{
		GetPlayerName(playerid, Name, sizeof(Name));
	}
	else
	{
		Name = "Disconnected/Nothing";
	}

	return Name;
}

stock GetPlayerIDEx(name[]){
	foreach(Player, i)
	{
		if(!strcmp(Player[i][NormalName], name, true))
			return i;
	}
	return INVALID_PLAYER_ID;
}

stock GetPlayersID(name[])
{
	new id = GetPlayerID(name);
	if(id != INVALID_PLAYER_ID)
	{
		return id;
	}
	else
	{
		id = GetPlayerIDEx(name);
		if(id != INVALID_PLAYER_ID)
		{
			return id;
		}
		else
		{
			return INVALID_PLAYER_ID;
		}
	}
}

stock GetPlayerX(playerid)
{
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	return floatround(x);
}

stock GetPlayerY(playerid)
{
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	return floatround(y);
}

stock GetPlayerZ(playerid)
{
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	return floatround(z);
}

stock GetArmour(playerid)
{
	new Float:armour;
	GetPlayerArmour(playerid, armour);
	return floatround(armour);
}

stock GetHealth(playerid)
{
	new Float:health;
	GetPlayerHealth(playerid, health);
	return floatround(health);
}

forward KickTimer(playerid);
public KickTimer(playerid) 
{
	DeletePVar(playerid, "Kicked");
	Kick(playerid);
}
	
stock KickEx(playerid)
{
	SetTimerEx("KickTimer", 50, 0, "d", playerid);
	return 1;
}
forward PlayerHasHouseKey(playerid, houseid);
public PlayerHasHouseKey(playerid, houseid)
{
	if(Player[playerid][House] == houseid || Player[playerid][House2] == houseid || Player[playerid][HouseKey] == houseid)
		return 1;
	return 0;
}

forward PlayerHasBusinessKey(playerid, businessid);
public PlayerHasBusinessKey(playerid, businessid)
{
	if(Player[playerid][Business] == businessid || Player[playerid][BusinessKey] == businessid)
		return 1;
	return 0;
}

forward GetPlayerVIP(i);
public GetPlayerVIP(i)	{return Player[i][VipRank];}

forward GetPlayerGroup(i);
public GetPlayerGroup(i) {return Player[i][Group];}

forward GetPlayerGroupRank(i);
public GetPlayerGroupRank(i) {return Player[i][GroupRank];}

forward GetPlayerGang(i);
public GetPlayerGang(i) {return Player[i][Gang];}

forward GetPlayerGangRank(i);
public GetPlayerGangRank(i) {return Player[i][GangRank];}

forward GetGroupType(g);
public GetGroupType(g) {return Groups[g][CommandTypes];}

forward GetPlayerJob(i, job);
public GetPlayerJob(i, job) {return (job == 1) ? (Player[i][Job]) : (Player[i][Job2]);}

forward GetPlayerAdminDuty(i);
public GetPlayerAdminDuty(i) {return Player[i][AdminDuty];}

forward GetJobType(j);
public GetJobType(j) {return Jobs[j][JobType];}

forward GetHouseKeypadCode(h);
public GetHouseKeypadCode(h) {return Houses[h][Keypad];}

forward GetPlayerVIPPass(i);
public GetPlayerVIPPass(i) {return Player[i][VIPPass];}

forward GetPlayerBusiness(i);
public GetPlayerBusiness(i) {return Player[i][Business];}

forward GetPlayerBusinessKey(i);
public GetPlayerBusinessKey(i) {return Player[i][BusinessKey];}

forward GetPlayerInHQ(i);
public GetPlayerInHQ(i)	{return Player[i][InGroupHQ];}

forward GetPlayerInHouse(i);
public GetPlayerInHouse(i) {return Player[i][InHouse];}

forward GetPlayerInBusiness(i);
public GetPlayerInBusiness(i) {return Player[i][InBusiness];}

forward SetPlayerInBusiness(i, value);
public SetPlayerInBusiness(i, value)
{
	Player[i][InBusiness] = value;
}

forward GetHouse57SafeCode();
public GetHouse57SafeCode() {return House57SafeCode;}

forward SetHouse57SafeCode(set);
public SetHouse57SafeCode(set) {return House57SafeCode = set;}
