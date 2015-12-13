/* 
	ブリッツクリーグ
	
	SHADoW93's Project BlitzRocketHell Presents:
	
	The Blitzkrieg - The original Rocket Hell FF2 Boss
	
	Some code snippets from EP, MasterOfTheXP, pheadxdll, & Wolvan
	Special thanks to BBG_Theory, M76030, Ravensbro, Transit of Venus, and VoiDED for pointing out bugs
	
	Many thanks to sarysa for many fixes, improvements and enhancements.
	
	How to configure his rounds:
	
		blitzkrieg_config
			arg1 - Difficulty Level
				0 - Always Random
				1 - Easy
				2 - Normal
				3 - Intermediate
				4 - Difficult
				5 - Lunatic
				6 - Insane
				7 - Godlike
				8 - Rocket Hell
				9 - Total Blitzkrieg
				420 - MLG Pro: Level W33D
				1337 - MLG Pro: Level L33T
				9001 - ITS OVER 9000!
				
			arg2 - Combat Style
				1 - Rocket Launcher Only
				0 - Rocket Launcher + Melee
				
			arg3 - Use Custom Weaponset?
				1 - Enable
				0 - Disable
				
			arg4 - Ability Activation notification
				1 - Voice Lines
				0 - Generic Sound
				
			arg5 - Ammo on RAGE (default 180)
			
			arg6 - Ammo on life loss (default 360)
			
			arg7 - Round Start Mode (if arg2 = 0)
				1 - Start with rocket launcher equipped
				0 - Start with only Melee
				
			arg8 - Allow Medics to revive players
				1 - Enable revive markers with a fixed # of revives
				0 - Disable revive markers
				-1 - Enable revive markers with no revive limit
				
			arg9 - Revive Marker Duration (default 30 seconds)
			
				arg10-arg11 only if arg1 is set to 0
			arg10 - What is the minimum level to select? (Default 2)
			arg11 - What is the maximum level to select? (Default 5)
			
			arg12 - Reroll a different difficulty level? (1 & 0 only function if on random mode, 2 will work independent of this setting)
				2 - Level Up
				1 - Reroll
				0 - Retain same level
				
			arg13 - RAGE on Kill? (default is no RAGE on kill)
			arg14 - Projectile bounce?
		
		mini_blitzkrieg
			arg0 - Ability Slot
			arg1 - Kritzkrieg Duration
			
		blitzkrieg_RageIsBarrage
			arg0 - Ability Slot
			arg1 - Ubercharge duration
			arg2 - Kritzkrieg Duration
			arg3 - Rampage duration (if arg1 = 1, will switch to normal rocket launchers)
				
		point_teleport
		
			slot (arg0) simply determines if normal rage (0) or death rage (-1) fills charges
			arg1 - activation key. 1 is left click, 2 is right click, 3 is reload, 4 is middle mouse
			arg2 - number of uses per rage.
			arg3 - max distance
			arg4 - hint text string
			arg5 - particle effect (old location)
			arg6 -  particle effect (old location)
			arg7 - war3source/blinkarrival.wav" //"buttons/blip1.wav" // sound to play on teleport
			arg8 - if this is 1, preserves momentum (same as otokiru version)
			arg9 - if this is 1, charges are added to your total (different from otokiru version)
			arg10 - if this is 1, your clip is emptied upon teleport. really this feature is _only_ for blitzkrieg. at high difficulties without this you'd get cheap(er) kills.
			arg11 - attack delay set on all weapons upon point teleport. again, mainly just for Blitzkrieg. won't do squat if he rages after.
		
		blitzkrieg_misc_overrides
			arg1 - rocket model override
			arg2 - rocket recolors, standard weapons
			arg3 - rocket recolors, total blitzkrieg
			arg4 - damage multiplier while crits are active. use this to reduce (or increase) crit damage, which is a 3.0 multiplier
			arg5 - damage multiplier while strength is active. use this to reduce (or increase) strength damage, which is a 2.0 multiplier
			arg6 - explosion radius modifiers based on difficulty level.
			arg7 - disable the sound that plays before the round start (and the outro sound). why do it here? it's easier.
		
			medic stuff -- excess medics will be stripped of their minigun but given a very powerful crossbow
			arg8 - max standard medics. it can either be a solid value (1-31) or a percentage (0.00001 to 0.99999...) [set to 0 to not use]
			arg9 - crossbow weapon index (305 = normal, 1079 = festive)
			arg10 - attributes
			arg11 - random selection notification
			arg12 -  medic limit notification
			arg13 - override for straight goomba damage, leave blank or set to zero to not use
			arg14 - override for HP factor goomba damage, leave blank or set to zero to not use
			arg15 - needed for medic limit
			arg16 - Round time limit (in seconds)
			
			arg19 - various flags, add them up for desired results
				0x0001: Never change the player model.
				0x0002: Never change the player class
				0x0004: Never change the melee weapon
				0x0008: Don't spawn a parachute.
				0x0010: Don't allow novelty difficulties.
				0x0020: Block random crits.
				0x0040: Ensure explosion radius modifiers stack properly with automatic ones. (direct hit 0.3, air strike 0.85)
				0x0080: No MVM alert sounds.
				0x0100: Disable the Blitzkrieg voice messages.
				0x0200: Disable the match begin Administrator messages.
				0x0400: Disable the match end Administrator messages.
				0x0800: Disable class reaction messages.
				0x1000: Disable goombas entirely.
				0x8000: VSP-specific workaround for the head collection problem. If you're not VSP, don't include this flag.

		blitzkrieg_map_difficulty_override
		
			note: since I'm making default difficulty level 1, arg2-arg9 will correspond with standard difficulty levels
			arg10-arg19 I'll use for spillover, since I limit each string to 512 characters
			to speed things up, PARTIAL NAME MATCHES ARE NOT ALLOWED! argument skips are allowed.
			arg1 - default difficulty for arg2-arg19
			arg2-arg19 - map names

		blitzkrieg_weapon_override0 - there can be up to 10 of these, from 0 to 9
		
			and args 1-18 will just be weapon index, weapon attributes, over and over
			allows for server specific weapon stat overrides
			what you see is very VSP specific, and not suitable for other servers.
			note that sequential breaks ARE allowed, so if you have 12 args and delete 7 and 8 later
			it won't break 9-12
			
			arg1 (and odd # args)	- index
			arg2 (and even # args)	- attributes
*/

#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2items>
#include <tf2_stocks>
#include <freak_fortress_2>
#include <freak_fortress_2_subplugin>
#include <morecolors>
#include <ff2_dynamic_defaults>
#undef REQUIRE_PLUGIN
#tryinclude <revivemarkers>
#tryinclude <goomba>
#define REQUIRE_PLUGIN

// sarysa's code
#define MAX_CENTER_TEXT_LENGTH 512
#define COND_RUNE_STRENGTH TFCond:90
#define BLITZKRIEG_COND_CRIT TFCond_HalloweenCritCandy // this one won't derp out for any reason, while medics can screw up Kritzkrieg
#define MAX_PLAYERS_ARRAY 36
#define MAX_ENTITY_CLASSNAME_LENGTH 48
#define MAX_EFFECT_NAME_LENGTH 48
#define MAX_SOUND_FILE_LENGTH 80
#define HEX_OR_DEC_STRING_LENGTH 12 // max -2 billion is 11 chars + null termination
#define MAX_MODEL_FILE_LENGTH 128
#define MAX_WEAPON_ARG_LENGTH 256
#define MAX_PLAYERS (MAX_PLAYERS_ARRAY < (MaxClients + 1) ? MAX_PLAYERS_ARRAY : (MaxClients + 1))
#define INVALID_ENTREF INVALID_ENT_REFERENCE
#define IsEmptyString(%1) (%1[0] == 0)
#define FAR_FUTURE 100000000.0
#define NOPE_AVI "vo/engineer_no01.mp3"
new bool:RoundInProgress = false;
new bool:PRINT_DEBUG_INFO = true;
new bool:PRINT_DEBUG_SPAM = false;

// back to shadow93's code
new timeExtension=0;
new startTime=0;
new maxWaves=0;
new playerCT=0;
#define BLITZSETUP "blitzkrieg_config"
new bool: LoomynartyMusic = false;
#define PLAYERDEATH "freak_fortress_2/s93dm/dm_playerdeath.mp3"
#define BLITZKRIEG_SND "mvm/mvm_tank_end.wav"
#define MINIBLITZKRIEG_SND "mvm/mvm_tank_start.wav"
#define OVER_9000	"saxton_hale/9000.wav"
#define L00MYNARTY "freak_fortress_2/s93dm/dm_l33t.mp3"
#define SM0K3W33D "freak_fortress_2/s93dm/dm_w33d.mp3"
#define RAVIOLIZ "freak_fortress_2/s93dm/dm_ravioli.mp3"
#define DONUTZ "freak_fortress_2/s93dm/dm_donut.mp3"

#define BLITZ_MEDIC "models/freak_fortress_2/shadow93/dmedic/d_medic.mdl"
#define BLITZ_SOLDIER "models/freak_fortress_2/shadow93/dmedic/d_soldier.mdl"
#define BLITZ_ROCKET "models/freak_fortress_2/shadow93/dmedic/rocket.mdl"

//#define BLITZ_BONUS ""

// Bouncing Projectiles
#define	MAX_EDICT_BITS	11
#define	MAX_EDICTS		(1 << MAX_EDICT_BITS)
new rBounce[MAX_EDICTS], rMaxBounceCount[MAX_EDICTS], rMaxBounces = 0;

// Version Number
#define MAJOR_REVISION "3"
#define MINOR_REVISION "2"
//#define PATCH_REVISION "0"
#define DEV_REVISION "Beta"
#define BUILD_REVISION "(Stable)"

#if !defined PATCH_REVISION
	#define PLUGIN_VERSION MAJOR_REVISION..."."...MINOR_REVISION..." "...DEV_REVISION..." "...BUILD_REVISION
#else
	#define PLUGIN_VERSION MAJOR_REVISION..."."...MINOR_REVISION..."."...PATCH_REVISION..." "...DEV_REVISION..." "...BUILD_REVISION
#endif

public Plugin:myinfo = {
	name = "Freak Fortress 2: The Blitzkrieg",
	author = "SHADoW NiNE TR3S, sarysa",
	description="Projectile Hell (BlitzRocketHell)",
	version=PLUGIN_VERSION,
};


//Other Stuff
new blitzBossIdx;
bool RNGesus=false;
new UseCustomWeapons;
new WeaponMode;
new DifficultyLevel;
new AlertMode;
new String:DifficultyLevelString[MAX_CENTER_TEXT_LENGTH];
new LifeLossRockets;
new RageRockets;
new RoundStartMode;
new MinDifficulty;
new MaxDifficulty;
new LevelUpgrade;
new bool:IsRandomDifficultyMode = false;
new bool:RageIsBarrage = false;
new bool:blitzisboss = false;
new bool:BossIsWinner = false;
new bool:hooksEnabled = false;
new rocketCount=0;
new bool:IsBlitzkrieg[MAXPLAYERS+1];

// Reanimators
new MaxClientRevives;
new ReviveMarkerDecayTime;
new clientRevives[MAXPLAYERS+1]=0;
new reviveMarker[MAXPLAYERS+1];
new bool:ChangeClass[MAXPLAYERS+1] = { false, ... };
new currentTeam[MAXPLAYERS+1] = {0, ... };
new Float:Blitz_LastPlayerPos[MAX_PLAYERS_ARRAY][3];

new Handle:ClientHUDS;
new Handle:BossHUDS;
new Handle:counterHUD;


// Integration Mode (Wolvan's revive markers plugin)
#if defined _revivemarkers_included_
new bool:IntegrationMode = false;
new Handle:cvarHaleVisibility, cvalHaleVisibility;
new Handle:cvarTeamRestrict, cvalTeamRestrict;
new Handle:cvarVisibility, cvalVisibility;
new Handle:cvarNoRestrict, cvalNoRestrict;
#endif

new String:BOuttro[PLATFORM_MAX_PATH];

// many, many timer replacements
new Float:Blitzkrieg_FindBlitzkriegAt;
new Float:Blitz_HUDSync;
new Float:Blitz_EndCrocketHellAt;
new Float:Blitz_WaveTick;
new Float:Blitz_PostSetupAt;
new Float:Blitz_AdminTauntAt;
new Float:Blitz_RemoveUberAt;
new Float:Blitz_ReverifyWeaponsAt[MAX_PLAYERS_ARRAY];
new Float:Blitz_VerifyMedigunAt[MAX_PLAYERS_ARRAY];
new Float:Blitz_RemoveReviveMarkerAt[MAX_PLAYERS_ARRAY];
new Float:Blitz_MoveReviveMarkerAt[MAX_PLAYERS_ARRAY];

/**
 * Blitzkrieg Misc Overrides
 */
#define BMO_STRING "blitzkrieg_misc_overrides"
#define MAX_ROCKET_TYPES 10 // types of launchers
#define MAX_ROCKET_LEVELS 15 // difficulty levels
#define ARRAY_IDX_NORMAL 0
#define ARRAY_IDX_BLITZKRIEG 1
#define BMO_MEDIGUN_MEDIC 0
#define BMO_CROSSBOW_MEDIC 1
#define BMO_NOT_A_MEDIC 2
#define BMO_FLAG_KEEP_PLAYER_MODEL 0x0001
#define BMO_FLAG_KEEP_PLAYER_CLASS 0x0002
#define BMO_FLAG_KEEP_MELEE 0x0004
#define BMO_FLAG_NO_PARACHUTE 0x0008
#define BMO_FLAG_BLOCK_NOVELTY_DIFFICULTY 0x0010
#define BMO_FLAG_NO_RANDOM_CRITS 0x0020
#define BMO_FLAG_STACK_RADIUS 0x0040
#define BMO_FLAG_NO_ALERT_SOUNDS 0x0080
#define BMO_FLAG_NO_VOICE_MESSAGES 0x0100
#define BMO_FLAG_NO_BEGIN_ADMIN_MESSAGES 0x0200
#define BMO_FLAG_NO_END_ADMIN_MESSAGES 0x0400
#define BMO_FLAG_NO_CLASS_MESSAGES 0x0800
#define BMO_FLAG_NO_GOOMBAS 0x1000
#define BMO_FLAG_NO_DEMOKNIGHT_FALL_DAMAGE 0x2000
#define BMO_FLAG_DISPLAY_TIMER_HUD 0x4000
#define BMO_FLAG_VSP_SWORD_WORKAROUND 0x8000
#define MAX_PENDING_ROCKETS 10
new bool:BMO_ActiveThisRound = false;
new bool:BMO_CurrentIsBlizkrieg;
new BMO_CurrentRocketType;
new BMO_PendingRocketEntRefs[MAX_PENDING_ROCKETS];
new BMO_MedicType[MAX_PLAYERS_ARRAY];
new Float:BMO_UpdateTimerHUDAt;
new Float:BMO_RoundEndsAt; // internal, based on arg16
new BMO_ModelOverrideIdx; // arg1
new BMO_Recolors[2][MAX_ROCKET_TYPES]; // arg2 and arg3
new Float:BMO_CritDamageMultiplier; // arg4
new Float:BMO_StrengthDamageMultiplier; // arg5
new Float:BMO_RocketRadius[MAX_ROCKET_LEVELS]; // arg6
new BMO_NoIntroOutroSounds; // arg7
new Float:BMO_MedicLimitPercent; // arg8
new BMO_NormalMedicLimit; // also arg8. IT'S A union! (ish)
new BMO_CrossbowIdx; // arg9
new String:BMO_CrossbowArgs[MAX_WEAPON_ARG_LENGTH]; // arg10
new String:BMO_CrossbowAlert[MAX_CENTER_TEXT_LENGTH]; // arg11
new String:BMO_MedicLimitAlert[MAX_CENTER_TEXT_LENGTH]; // arg12
new Float:BMO_FlatGoombaDamage; // arg13
new Float:BMO_GoombaDamageFactor; // arg14
new String:BMO_MedicExploitAlert[MAX_CENTER_TEXT_LENGTH]; // arg15
new BMO_Flags; // arg19

/**
 * Blitzkrieg Weapon Override
 */
#define BWO_PREFIX "blitzkrieg_weapon_override%d"
#define BWO_MAX_WEAPONS 90
new bool:BWO_ActiveThisRound;
new BWO_Count;
new BWO_WeaponIndexes[BWO_MAX_WEAPONS];
new String:BWO_WeaponArgs[BWO_MAX_WEAPONS][MAX_WEAPON_ARG_LENGTH]; // yup, this is a data hog.

/**
 * Blitzkrieg Map Difficulty Overrides (nothing needs to be stored for this, since it's just a map name check at round start)
 */
#define BMDO_STRING "blitzkrieg_map_difficulty_override"

/**
 * sarysa's Point Teleport: sarysa 2015-03-26
 * Fed up with otokiru teleport, here's completely different method that won't get you stuck.
 * Based on code I wrote for my eighth private pack for safe resizing.
 */
#define SPT_STRING "point_teleport"
#define SPT_CENTER_TEXT_INTERVAL 0.5
new bool:SPT_ActiveThisRound;
new bool:SPT_CanUse[MAX_PLAYERS_ARRAY];
new bool:SPT_KeyDown[MAX_PLAYERS_ARRAY];
new Float:SPT_NextCenterTextAt[MAX_PLAYERS_ARRAY];
new SPT_ChargesRemaining[MAX_PLAYERS_ARRAY]; // internal
new SPT_KeyToUse[MAX_PLAYERS_ARRAY]; // arg1, though it's immediately converted into an IN_BLAHBLAH flag
new SPT_NumSkills[MAX_PLAYERS_ARRAY]; // arg2
new Float:SPT_MaxDistance[MAX_PLAYERS_ARRAY]; // arg3
new String:SPT_CenterText[MAX_CENTER_TEXT_LENGTH]; // arg4
new String:SPT_OldLocationParticleEffect[MAX_EFFECT_NAME_LENGTH]; // arg5
new String:SPT_NewLocationParticleEffect[MAX_EFFECT_NAME_LENGTH]; // arg6
new String:SPT_UseSound[MAX_SOUND_FILE_LENGTH]; // arg7
new bool:SPT_PreserveMomentum[MAX_PLAYERS_ARRAY]; // arg8
new bool:SPT_AddCharges[MAX_PLAYERS_ARRAY]; // arg9
new bool:SPT_EmptyClipOnTeleport[MAX_PLAYERS_ARRAY]; // arg10
new Float:SPT_AttackDelayOnTeleport[MAX_PLAYERS_ARRAY]; // arg11
/**
 * Blitzkrieg Strings: sarysa 2015-03-25: strings moved into boss config, and preloaded
 */
#define BS_STRING "blitzkrieg_strings"
new String:BS_GoodLuck[MAX_CENTER_TEXT_LENGTH]; // arg1, string name: good_luck
new String:BS_CombatModeNoMelee[MAX_CENTER_TEXT_LENGTH]; // arg2, string name: combatmode_nomelee
new String:BS_CombatModeWithMelee[MAX_CENTER_TEXT_LENGTH]; // arg3, string name: combatmode_withmelee
new String:BS_BlitzInactive[MAX_CENTER_TEXT_LENGTH]; // arg4, string name: blitz_inactive
new String:BS_BlitzInactive2[MAX_CENTER_TEXT_LENGTH]; //arg5, string name: blitz_inactive2
new String:BS_BlitzDifficulty[MAX_CENTER_TEXT_LENGTH]; // arg6, string name: blitz_difficulty
new String:BS_BlitzDifficulty2[MAX_CENTER_TEXT_LENGTH]; // arg7, string name: blitz_difficulty2
new String:BS_HelpScout[MAX_CENTER_TEXT_LENGTH]; // arg8, string name: help_scout
new String:BS_HelpSoldier[MAX_CENTER_TEXT_LENGTH]; // arg9, string name: help_soldier
new String:BS_HelpPyro[MAX_CENTER_TEXT_LENGTH]; // arg10, string name: help_pyro
new String:BS_HelpDemo[MAX_CENTER_TEXT_LENGTH]; // arg11, string name: help_demo
new String:BS_HelpHeavy[MAX_CENTER_TEXT_LENGTH]; // arg12, string name: help_heavy
new String:BS_HelpEngie[MAX_CENTER_TEXT_LENGTH]; // arg13, string name: help_engy
new String:BS_HelpMedic[MAX_CENTER_TEXT_LENGTH]; // arg14, string name: help_medic
new String:BS_HelpSniper[MAX_CENTER_TEXT_LENGTH]; // arg15, string name: help_sniper
new String:BS_HelpSpy[MAX_CENTER_TEXT_LENGTH]; // arg16, string name: help_spy

/**
 * HUD Strings: SHADoW93 2015-06-11: NEW HUD
 */
 
#define BS_H_STRING "blitzkrieg_hud_strings"
new String:BHS_BossHud[MAX_CENTER_TEXT_LENGTH]; // arg1, HUD type: Boss
new String:BHS_ClientHUD[MAX_CENTER_TEXT_LENGTH]; // arg2-3, HUD type: Player
new String:BHS_Easy[MAX_CENTER_TEXT_LENGTH]; // arg4, Easy
new String:BHS_Normal[MAX_CENTER_TEXT_LENGTH]; // arg5, Normal
new String:BHS_Intermediate[MAX_CENTER_TEXT_LENGTH]; // arg6, Intermediate
new String:BHS_Difficult[MAX_CENTER_TEXT_LENGTH]; // arg7, Difficult
new String:BHS_Lunatic[MAX_CENTER_TEXT_LENGTH]; // arg8, Lunatic
new String:BHS_Insane[MAX_CENTER_TEXT_LENGTH]; // arg9, Insane
new String:BHS_Godlike[MAX_CENTER_TEXT_LENGTH]; // arg10, Godlike
new String:BHS_RocketHell[MAX_CENTER_TEXT_LENGTH]; // arg11, RocketHell
new String:BHS_TotalBlitzkrieg[MAX_CENTER_TEXT_LENGTH]; // arg12, TotalBlitzkrieg
new String:BHS_RNGDisplay[MAX_CENTER_TEXT_LENGTH]; // arg13, RNGLevel
new String:BHS_Counter[MAX_CENTER_TEXT_LENGTH]; // arg14, counter HUD
new String:BHS_Counter2[MAX_CENTER_TEXT_LENGTH]; // arg15, counter HUD

// Level Up Enabled Indicator
static const String:BlitzCanLevelUpgrade[][] = {
	"vo/mvm_mann_up_mode01.mp3",
	"vo/mvm_mann_up_mode02.mp3",
	"vo/mvm_mann_up_mode03.mp3",
	"vo/mvm_mann_up_mode04.mp3",
	"vo/mvm_mann_up_mode05.mp3",
	"vo/mvm_mann_up_mode06.mp3",
	"vo/mvm_mann_up_mode07.mp3",
	"vo/mvm_mann_up_mode08.mp3",
	"vo/mvm_mann_up_mode09.mp3",
	"vo/mvm_mann_up_mode10.mp3",
	"vo/mvm_mann_up_mode11.mp3",
	"vo/mvm_mann_up_mode12.mp3",
	"vo/mvm_mann_up_mode13.mp3",
	"vo/mvm_mann_up_mode14.mp3",
	"vo/mvm_mann_up_mode15.mp3"
};

// Round Result
static const String:BlitzIsDefeated[][] = {
	"vo/mvm_manned_up01.mp3",
	"vo/mvm_manned_up02.mp3",
	"vo/mvm_manned_up03.mp3"
};

static const String:BlitzIsVictorious[][] = {
	"vo/mvm_game_over_loss01.mp3",
	"vo/mvm_game_over_loss02.mp3",
	"vo/mvm_game_over_loss03.mp3",
	"vo/mvm_game_over_loss04.mp3",
	"vo/mvm_game_over_loss05.mp3",
	"vo/mvm_game_over_loss06.mp3",
	"vo/mvm_game_over_loss07.mp3",
	"vo/mvm_game_over_loss08.mp3",
	"vo/mvm_game_over_loss09.mp3",
	"vo/mvm_game_over_loss10.mp3",
	"vo/mvm_game_over_loss11.mp3"
};

// Class Reaction Lines
static const String:ScoutReact[][] = {
	"vo/scout_sf13_magic_reac03.mp3",
	"vo/scout_sf13_magic_reac07.mp3",
	"vo/scout_sf12_badmagic04.mp3"
};

static const String:SoldierReact[][] = {
	"vo/soldier_sf13_magic_reac03.mp3",
	"vo/soldier_sf12_badmagic07.mp3",
	"vo/soldier_sf12_badmagic13.mp3"
};

static const String:PyroReact[][] = {
	"vo/pyro_autodejectedtie01.mp3",
	"vo/pyro_painsevere02.mp3",
	"vo/pyro_painsevere04.mp3"
};

static const String:DemoReact[][] = {
	"vo/demoman_sf13_magic_reac05.mp3",
	"vo/demoman_sf13_bosses02.mp3",
	"vo/demoman_sf13_bosses03.mp3",
	"vo/demoman_sf13_bosses04.mp3",
	"vo/demoman_sf13_bosses05.mp3",
	"vo/demoman_sf13_bosses06.mp3"
};

static const String:HeavyReact[][] = {
	"vo/heavy_sf13_magic_reac01.mp3",
	"vo/heavy_sf13_magic_reac03.mp3",
	"vo/heavy_cartgoingbackoffense02.mp3",
	"vo/heavy_negativevocalization02.mp3",
	"vo/heavy_negativevocalization06.mp3"
};

static const String:EngyReact[][] = {
	"vo/engineer_sf13_magic_reac01.mp3",
	"vo/engineer_sf13_magic_reac02.mp3",
	"vo/engineer_specialcompleted04.mp3",
	"vo/engineer_painsevere05.mp3",
	"vo/engineer_negativevocalization12.mp3"
};

static const String:MedicReact[][] = {
	"vo/medic_sf13_magic_reac01.mp3",
	"vo/medic_sf13_magic_reac02.mp3",
	"vo/medic_sf13_magic_reac03.mp3",
	"vo/medic_sf13_magic_reac04.mp3",
	"vo/medic_sf13_magic_reac07.mp3"
};

static const String:SniperReact[][] = {
	"vo/sniper_sf13_magic_reac01.mp3",
	"vo/sniper_sf13_magic_reac02.mp3",
	"vo/sniper_sf13_magic_reac04.mp3"
};

static const String:SpyReact[][] = {
	"vo/Spy_sf13_magic_reac01.mp3",
	"vo/Spy_sf13_magic_reac02.mp3",
	"vo/Spy_sf13_magic_reac03.mp3",
	"vo/Spy_sf13_magic_reac04.mp3",
	"vo/Spy_sf13_magic_reac05.mp3",
	"vo/Spy_sf13_magic_reac06.mp3"
};

public Blitzkrieg_PrecacheModels()
{
	PrecacheModel(BLITZ_ROCKET, true);
	PrecacheModel(BLITZ_MEDIC, true);
	PrecacheModel(BLITZ_SOLDIER, true);
}

public Blitzkrieg_PrecacheSounds() // sarysa 2015-03-25, OnMapStart() NEVER worked for me with FF2 sub-plugins, so I set it up to do these precaches in two places.
{
	// ROUND EVENTS
	PrecacheSound(OVER_9000, true);
	PrecacheSound(PLAYERDEATH, true);
	PrecacheSound(L00MYNARTY, true);
	PrecacheSound(SM0K3W33D, true);
	PrecacheSound(RAVIOLIZ, true);
	PrecacheSound(DONUTZ, true);

	// RAGE GENERIC ALERTS
	PrecacheSound(BLITZKRIEG_SND,true);
	PrecacheSound(MINIBLITZKRIEG_SND,true);
	
	//Class Voice Reaction Lines
	for (new i = 0; i < sizeof(ScoutReact); i++)
	{
		PrecacheSound(ScoutReact[i], true);
	}
	for (new i = 0; i < sizeof(SoldierReact); i++)
	{
		PrecacheSound(SoldierReact[i], true);
	}
	for (new i = 0; i < sizeof(PyroReact); i++)
	{
		PrecacheSound(PyroReact[i], true);
	}
	for (new i = 0; i < sizeof(DemoReact); i++)
	{
		PrecacheSound(DemoReact[i], true);
	}
	for (new i = 0; i < sizeof(HeavyReact); i++)
	{
		PrecacheSound(HeavyReact[i], true);
	}
	for (new i = 0; i < sizeof(EngyReact); i++)
	{
		PrecacheSound(EngyReact[i], true);
	}
	for (new i = 0; i < sizeof(MedicReact); i++)
	{
		PrecacheSound(MedicReact[i], true);
	}
	for (new i = 0; i < sizeof(SniperReact); i++)
	{
		PrecacheSound(SniperReact[i], true);
	}
	for (new i = 0; i < sizeof(SpyReact); i++)
	{
		PrecacheSound(SpyReact[i], true);
	}
	// Manning Up & Round Result Lines
	for (new i = 0; i < sizeof(BlitzCanLevelUpgrade); i++)
	{
		PrecacheSound(BlitzCanLevelUpgrade[i], true);
	}
	for (new i = 0; i < sizeof(BlitzIsDefeated); i++)
	{
		PrecacheSound(BlitzIsDefeated[i], true);
	}
	for (new i = 0; i < sizeof(BlitzIsVictorious); i++)
	{
		PrecacheSound(BlitzIsVictorious[i], true);
	}
}

public OnPluginStart2()
{
	// almost every hook here was moved out, to only activate when it's Blitzkrieg's turn.
	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Pre);
	HookEvent("teamplay_round_start", Event_TeamplayRoundStart, EventHookMode_PostNoCopy);
	HookEvent("arena_round_start", OnRoundStart, EventHookMode_PostNoCopy);
	HookEvent("arena_win_panel", OnRoundEnd, EventHookMode_PostNoCopy);
	for (new i = 1; i <= MaxClients; i++) 
	{
		if (IsValidClient(i)) 
		{
			currentTeam[i] = GetClientTeam(i);
			ChangeClass[i] = false;
		}
	}
	BossHUDS=CreateHudSynchronizer();
	ClientHUDS=CreateHudSynchronizer();
	counterHUD=CreateHudSynchronizer();
	// sarysa 2015-03-25, this is the first place sounds get precached.
	// note that this sometimes precaches here will fail when the server is first started.
	// this is mainly a problem with old forks of FF2, like VSP and DISC-FF
	Blitzkrieg_PrecacheSounds();
	Blitzkrieg_PrecacheModels();
		
	if(FF2_GetRoundState()==1)
	{
		Blitzkrieg_HookAbilities();
	}

	LoadTranslations("dmedic.phrases");
	
	for (new clientIdx = 1; clientIdx < MAX_PLAYERS; clientIdx++)
		reviveMarker[clientIdx] = INVALID_ENTREF;
}

public void Event_TeamplayRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	Blitzkrieg_FindBlitzkriegAt=GetEngineTime()+0.6;
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	#if defined _revivemarkers_included_
	MarkNativeAsOptional("SpawnRMarker");
	MarkNativeAsOptional("DespawnRMarker");
	MarkNativeAsOptional("SetReviveCount");
	MarkNativeAsOptional("setDecayTime");
	#endif
}

public OnLibraryAdded(const String: name[])
{
	#if defined _revivemarkers_included_
	if(StrEqual(name, "revivemarkers"))
    {
		IntegrationMode = true;
	}
	#endif
}

public OnLibraryRemoved(const String: name[])
{
	#if defined _revivemarkers_included_
	if (StrEqual(name, "revivemarkers"))
    {
		IntegrationMode = false;
	}
	#endif
}

public Blitz_AddHooks()
{
	if (hooksEnabled)
		return;
	HookEvent("player_hurt", OnPlayerHurt, EventHookMode_Pre);
	HookEvent("teamplay_broadcast_audio", OnAnnounce, EventHookMode_Pre);
	HookEvent("player_death", OnPlayerDeath, EventHookMode_Pre);
	HookEvent("player_changeclass", OnChangeClass);
	HookEvent("object_deflected", OnDeflectObject);
	AddCommandListener(BlitzHelp, "ff2_classinfo");
	AddCommandListener(BlitzHelp, "ff2classinfo");
	AddCommandListener(BlitzHelp, "hale_classinfo");
	AddCommandListener(BlitzHelp, "haleclassinfo");
	AddCommandListener(BlitzHelp, "ff2help");
	AddCommandListener(BlitzHelp, "helpme");

	hooksEnabled = true;
}

public Blitz_RemoveHooks()
{
	if (!hooksEnabled)
		return;
	UnhookEvent("player_hurt", OnPlayerHurt, EventHookMode_Pre);	
	UnhookEvent("teamplay_broadcast_audio", OnAnnounce, EventHookMode_Pre);
	UnhookEvent("player_death", OnPlayerDeath, EventHookMode_Pre);
	UnhookEvent("player_changeclass", OnChangeClass);
	UnhookEvent("object_deflected", OnDeflectObject);
	RemoveCommandListener(BlitzHelp, "ff2_classinfo");
	RemoveCommandListener(BlitzHelp, "ff2classinfo");
	RemoveCommandListener(BlitzHelp, "hale_classinfo");
	RemoveCommandListener(BlitzHelp, "haleclassinfo");
	RemoveCommandListener(BlitzHelp, "ff2help");
	RemoveCommandListener(BlitzHelp, "helpme");

	hooksEnabled = false;
}

public Action:OnDeflectObject(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(!IsBoss(client) && IsValidClient(client, true))
	{
		static deflected[MAXPLAYERS+1]=0;
		static deflect;
		deflect+=deflected[client];
		if(deflect>=5)
		{
			// Give them +1 points & +1 queue point for survival
			new Handle:hPoints=CreateEvent("player_escort_score", true);
			SetEventInt(hPoints, "player", client);
			SetEventInt(hPoints, "points", GetEventInt(hPoints, "points")+1);
			FireEvent(hPoints);
					
			new pts=1;
			FF2_SetQueuePoints(client, FF2_GetQueuePoints(client)+pts);
			CPrintToChat(client, "{olive}[FF2]{default} You have earned %i queue points for deflecting %i times", pts, deflected[client]);
			deflect-=deflected[client];
		}
		deflected[client]++;
	}
	
}
public Action:OnRoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	Blitzkrieg_HookAbilities();
}

public Blitzkrieg_HookAbilities()
{
	// Here, we have a config for blitzkrieg's rounds //
	if (!FF2_IsFF2Enabled())
		return;
		
	rocketCount=0;
	RoundInProgress = true;
	BMO_ActiveThisRound = false;
	BWO_ActiveThisRound = false;
	DifficultyLevel = 0;
	MaxClientRevives = 0;
	RageIsBarrage = false;
	IsRandomDifficultyMode = false;
	BMO_UpdateTimerHUDAt = FAR_FUTURE;
	BMO_RoundEndsAt = FAR_FUTURE;
	blitzisboss = false;
	Blitz_WaveTick = FAR_FUTURE;
	Blitz_EndCrocketHellAt = FAR_FUTURE;
	Blitz_PostSetupAt = FAR_FUTURE;
	Blitz_AdminTauntAt = FAR_FUTURE;
	Blitz_RemoveUberAt = FAR_FUTURE;
	Blitz_HUDSync = FAR_FUTURE;
	
	for(new clientIdx=1;clientIdx<=MaxClients;clientIdx++)
	{
		if(!IsValidClient(clientIdx, false))
			continue;
			
		IsBlitzkrieg[clientIdx]=false;
		
		new bossIdx = FF2_GetBossIndex(clientIdx);
		if(bossIdx>=0)
		{
			if (FF2_HasAbility(bossIdx, this_plugin_name, BLITZSETUP))
			{	
				IsBlitzkrieg[clientIdx]=true;
				blitzBossIdx=bossIdx;
				// sarysa: load the strings first
				if (FF2_HasAbility(bossIdx, this_plugin_name, BS_STRING))
				{
					ReadCenterText(bossIdx, BS_STRING, 1, BS_GoodLuck);
					ReadCenterText(bossIdx, BS_STRING, 2, BS_CombatModeNoMelee);
					ReadCenterText(bossIdx, BS_STRING, 3, BS_CombatModeWithMelee);
					ReadCenterText(bossIdx, BS_STRING, 4, BS_BlitzInactive);
					ReadCenterText(bossIdx, BS_STRING, 5, BS_BlitzInactive2);
					ReadCenterText(bossIdx, BS_STRING, 6, BS_BlitzDifficulty);
					ReadCenterText(bossIdx, BS_STRING, 7, BS_BlitzDifficulty2);
					ReadCenterText(bossIdx, BS_STRING, 8, BS_HelpScout);
					ReadCenterText(bossIdx, BS_STRING, 9, BS_HelpSoldier);
					ReadCenterText(bossIdx, BS_STRING, 10, BS_HelpPyro);
					ReadCenterText(bossIdx, BS_STRING, 11, BS_HelpDemo);
					ReadCenterText(bossIdx, BS_STRING, 12, BS_HelpHeavy);
					ReadCenterText(bossIdx, BS_STRING, 13, BS_HelpEngie);
					ReadCenterText(bossIdx, BS_STRING, 14, BS_HelpMedic);
					ReadCenterText(bossIdx, BS_STRING, 15, BS_HelpSniper);
					ReadCenterText(bossIdx, BS_STRING, 16, BS_HelpSpy);
				}			
			
				// sarysa: misc overrides
				if (FF2_HasAbility(bossIdx, this_plugin_name, BMO_STRING))
				{
					BMO_ActiveThisRound = true;
					BMO_CurrentIsBlizkrieg = false;
					BMO_ModelOverrideIdx = ReadModelToInt(bossIdx, BMO_STRING, 1);
				
					for (new i = 2; i <= 3; i++)
					{
						static String:colorStr[(HEX_OR_DEC_STRING_LENGTH + 1) * MAX_ROCKET_TYPES];
						static String:colorStrs[MAX_ROCKET_TYPES][HEX_OR_DEC_STRING_LENGTH];
						FF2_GetAbilityArgumentString(bossIdx, this_plugin_name, BMO_STRING, i, colorStr, sizeof(colorStr));
						new count = ExplodeString(colorStr, ";", colorStrs, MAX_ROCKET_TYPES, HEX_OR_DEC_STRING_LENGTH);
						if (count != MAX_ROCKET_TYPES)
						{
							PrintToServer("[s93_blitzkrieg_sf] Colors not formatted correctly. Will not override colors: %s", colorStr);
							for (new j = 0; j < MAX_ROCKET_TYPES; j++)
								BMO_Recolors[i-2][j] = 0xffffff;
						}

						for (new j = 0; j < MAX_ROCKET_TYPES; j++)
							BMO_Recolors[i-2][j] = ReadHexOrDecInt(colorStrs[j]);
					}
					BMO_CritDamageMultiplier = FF2_GetAbilityArgumentFloat(bossIdx, this_plugin_name, BMO_STRING, 4);
					BMO_StrengthDamageMultiplier = FF2_GetAbilityArgumentFloat(bossIdx, this_plugin_name, BMO_STRING, 5);
					static String:radiusStr[MAX_ROCKET_LEVELS * 10];
					static String:radiusStrs[MAX_ROCKET_LEVELS][10];
					FF2_GetAbilityArgumentString(bossIdx, this_plugin_name, BMO_STRING, 6, radiusStr, sizeof(radiusStr));
					BMO_NoIntroOutroSounds = FF2_GetAbilityArgument(bossIdx, this_plugin_name, BMO_STRING, 7);
					ExplodeString(radiusStr, ";", radiusStrs, MAX_ROCKET_LEVELS, 10);
					for (new i = 0; i < MAX_ROCKET_LEVELS; i++)
					{
						BMO_RocketRadius[i] = StringToFloat(radiusStrs[i]);
						if (BMO_RocketRadius[i] <= 0.0)
							BMO_RocketRadius[i] = 1.0;
					}

					// meeeeeedic
					BMO_MedicLimitPercent = FF2_GetAbilityArgumentFloat(bossIdx, this_plugin_name, BMO_STRING, 8);
					if (BMO_MedicLimitPercent >= 1.0)
					{
						BMO_MedicLimitPercent = 0.0;
						BMO_NormalMedicLimit = FF2_GetAbilityArgument(bossIdx, this_plugin_name, BMO_STRING, 8);
					}
					BMO_CrossbowIdx = FF2_GetAbilityArgument(bossIdx, this_plugin_name, BMO_STRING, 9, 305);
					FF2_GetAbilityArgumentString(bossIdx, this_plugin_name, BMO_STRING, 10, BMO_CrossbowArgs, MAX_WEAPON_ARG_LENGTH);
					ReadCenterText(bossIdx, BMO_STRING, 11, BMO_CrossbowAlert);
					ReadCenterText(bossIdx, BMO_STRING, 12, BMO_MedicLimitAlert);
					BMO_FlatGoombaDamage = FF2_GetAbilityArgumentFloat(bossIdx, this_plugin_name, BMO_STRING, 13);
					BMO_GoombaDamageFactor = FF2_GetAbilityArgumentFloat(bossIdx, this_plugin_name, BMO_STRING, 14);
					ReadCenterText(bossIdx, BMO_STRING, 15, BMO_MedicExploitAlert);
					new Float:roundLimit = FF2_GetAbilityArgumentFloat(bossIdx, this_plugin_name, BMO_STRING, 16);
					if (roundLimit > 0.0)
					{
						BMO_RoundEndsAt = GetEngineTime() + roundLimit;
						BMO_UpdateTimerHUDAt = GetEngineTime();
					}

					BMO_Flags = ReadHexOrDecString(bossIdx, BMO_STRING, 19);

					// initialize the array
					for (new i = 0; i < MAX_PENDING_ROCKETS; i++)
						BMO_PendingRocketEntRefs[i] = INVALID_ENTREF;
				}
				if (BMO_CritDamageMultiplier <= 0.0)
					BMO_CritDamageMultiplier = 1.0;
				if (BMO_StrengthDamageMultiplier <= 0.0)
					BMO_StrengthDamageMultiplier = 1.0;

				// sarysa: map difficulty overrides
				new difficultyOverride = -1;
				if (FF2_HasAbility(bossIdx, this_plugin_name, BMDO_STRING))
				{
					// get this map's name
					static String:mapName[PLATFORM_MAX_PATH];
					GetCurrentMap(mapName, PLATFORM_MAX_PATH);

					// get difficulty values
					static String:difficultyStr[18 * 5];
					static String:difficultyStrs[18][5];
					FF2_GetAbilityArgumentString(bossIdx, this_plugin_name, BMDO_STRING, 1, difficultyStr, sizeof(difficultyStr));
					ExplodeString(difficultyStr, ";", difficultyStrs, 18, 5);
					for (new i = 2; i <= 18; i++)
					{
						if (!IsEmptyString(difficultyStrs[i-2]))
						{
							static String:mapList[512];
							FF2_GetAbilityArgumentString(bossIdx, this_plugin_name, BMDO_STRING, i, mapList, sizeof(mapList));
							if (!IsEmptyString(mapList) && StrContains(mapList, mapName, false) >= 0)
							{
								difficultyOverride = StringToInt(difficultyStrs[i-2]);
								if ((difficultyOverride < 0 || difficultyOverride > 9) && (difficultyOverride != 420 && difficultyOverride != 9001 && difficultyOverride != 1337))
								{
									PrintToChatAll("ERROR: Bad difficulty override %s for map %s.\nWill use default difficulty.\nNotify your server admin!", difficultyStrs[i-2], mapName);
									difficultyOverride = -1;
								}
								break;
							}
						}
					}
				}

				// sarysa, blitzkrieg weapon overrides
				BWO_Count = 0;
				for (new abilityIdx = 0; abilityIdx < 10; abilityIdx++)
				{
					static String:abilityName[60];
					Format(abilityName, sizeof(abilityName), BWO_PREFIX, abilityIdx);
					if (FF2_HasAbility(bossIdx, this_plugin_name, abilityName))
					{
						new weaponIdx = 0;
						for (new argIdx = 1; argIdx <= 18; argIdx++)
						{
							if (argIdx % 2 == 1)
								weaponIdx = FF2_GetAbilityArgument(bossIdx, this_plugin_name, abilityName, argIdx);
							else
							{
								if (weaponIdx <= 0)
									continue; // allow sequential breaks, i.e. if one is hastily moved
								FF2_GetAbilityArgumentString(bossIdx, this_plugin_name, abilityName, argIdx, BWO_WeaponArgs[BWO_Count], MAX_WEAPON_ARG_LENGTH);
								BWO_WeaponIndexes[BWO_Count] = weaponIdx;
								if (PRINT_DEBUG_INFO)
									PrintToServer("[Blitzkrieg] (%d) Adding weapon override %d with stats %s", BWO_Count, weaponIdx, BWO_WeaponArgs[BWO_Count]);

								BWO_Count++;
							}
						}
					}
				}
				if (BWO_Count > 0)
					BWO_ActiveThisRound = true;
				PrintToServer("[Blitzkrieg] %d weapon overrides this round.", BWO_Count);
			
				// finally getting back to Shadow's code
				blitzisboss = true;
				Blitz_AddHooks();
				IsRandomDifficultyMode = false;
				RageIsBarrage = false;

				// sarysa 2015-03-25, this is the second place sounds get precached, as a precautionary measure.
				Blitzkrieg_PrecacheSounds();
				Blitzkrieg_PrecacheModels();
				
				Blitz_HUDSync=GetEngineTime()+0.3;
				
				// Custom Weapon Handler System
				UseCustomWeapons=FF2_GetAbilityArgument(bossIdx,this_plugin_name,BLITZSETUP, 3); // use custom weapons
				if(UseCustomWeapons)
					Blitz_PostSetupAt = GetEngineTime() + 0.3;

				// Weapon Difficulty
				DifficultyLevel=FF2_GetAbilityArgument(bossIdx,this_plugin_name,BLITZSETUP, 1, 2);
				if (difficultyOverride != -1)
					DifficultyLevel = difficultyOverride;
				PrintToServer("difficulty will be %d", DifficultyLevel);
				
				MinDifficulty=FF2_GetAbilityArgument(bossIdx,this_plugin_name,BLITZSETUP, 10, 2); // Minimum level to roll on random mode
				MaxDifficulty=FF2_GetAbilityArgument(bossIdx,this_plugin_name,BLITZSETUP, 11, 5); // Max level to roll on random mode
				
				if(!DifficultyLevel)
				{
					IsRandomDifficultyMode = true;
					DifficultyLevel=GetRandomInt(MinDifficulty,MaxDifficulty);
				}

				// Weapon Stuff
				WeaponMode=FF2_GetAbilityArgument(bossIdx,this_plugin_name,BLITZSETUP, 2);
				RageRockets=FF2_GetAbilityArgument(bossIdx,this_plugin_name,BLITZSETUP, 5, 180); // RAGE/Weaponswitch Ammo
				LifeLossRockets=FF2_GetAbilityArgument(bossIdx,this_plugin_name,BLITZSETUP, 6, 360); // Blitzkrieg Rampage Ammo
				RoundStartMode=FF2_GetAbilityArgument(bossIdx,this_plugin_name,BLITZSETUP, 7); // Start with launcher or no (with melee mode)
			
				SetHudTextParams(-1.0, 0.67, 5.0, 255, 255, 255, 255);
				switch(WeaponMode)
				{
					case 1:
					{
						FF2_ShowHudText(clientIdx, -1, BS_CombatModeNoMelee);
						PlotTwist(clientIdx);
						Blitz_WaveTick=GetEngineTime()+1.0;
						
						// Disable FF2's countdown timer and use Blitzkrieg's own
						playerCT=GetConVarInt(FindConVar("ff2_countdown_players"));
						if(playerCT)
						{
							SetConVarInt(FindConVar("ff2_countdown_players"),0);
						}
					}
					case 0:
					{
						FF2_ShowHudText(clientIdx, -1, BS_CombatModeWithMelee);
						PlotTwist(clientIdx);
					}
				}

				// Misc
				AlertMode=FF2_GetAbilityArgument(bossIdx,this_plugin_name,BLITZSETUP, 4); // Voice Lines
				MaxClientRevives=FF2_GetAbilityArgument(bossIdx,this_plugin_name,BLITZSETUP, 8); // Allow Reanimator
				ReviveMarkerDecayTime=FF2_GetAbilityArgument(bossIdx,this_plugin_name,BLITZSETUP, 9); // Reanimator decay time
				LevelUpgrade=FF2_GetAbilityArgument(bossIdx,this_plugin_name,BLITZSETUP, 12); // Allow Blitzkrieg to change difficulty level on random mode?

				#if defined _revivemarkers_included_
				if(IntegrationMode)
				{
					// Convars for Wolvan's revive markers plugin
					cvarHaleVisibility = FindConVar("revivemarkers_show_markers_for_hale");
					cvalHaleVisibility = GetConVarInt(cvarHaleVisibility);
					cvarTeamRestrict = FindConVar("revivemarkers_drop_for_one_team");
					cvalTeamRestrict = GetConVarInt(cvarTeamRestrict);
					cvarVisibility = FindConVar("revivemarkers_visible_for_medics");
					cvalVisibility = GetConVarInt(cvarVisibility);
					cvarNoRestrict = FindConVar("revivemarkers_admin_only");
					cvalNoRestrict = GetConVarInt(cvarNoRestrict);
	
					switch(MaxClientRevives)
					{
						case -1, 0: CPrintToChatAll((MaxClientRevives==-1 ? "{blue} You have unlimited revives" : "{red} Revive markers disabled"));
						default: SetReviveCount(MaxClientRevives), CPrintToChatAll("{red} You can only be revived %i times", MaxClientRevives);
					}
						
					switch(cvalVisibility)
					{
						case 1: SetConVarInt(cvarVisibility, 0);
					}
				
					switch(cvalHaleVisibility)
					{
						case 0: SetConVarInt(cvarHaleVisibility, 1);
					}
						
					switch(cvalNoRestrict)
					{
						case 1: SetConVarInt(cvarNoRestrict, 0);
					}
								
					switch(FF2_GetBossTeam())
					{ 
						case 2: if(cvalTeamRestrict != 2) SetConVarInt(cvarTeamRestrict, 2);
						case 3: if(cvalTeamRestrict != 1) SetConVarInt(cvarTeamRestrict, 1);
					}
					setDecayTime(ReviveMarkerDecayTime);
				}
				#endif
			
				if(FF2_HasAbility(bossIdx, this_plugin_name, BS_H_STRING))
				{
					ReadCenterText(bossIdx, BS_H_STRING, 1, BHS_BossHud);				
					ReadCenterText(bossIdx, BS_H_STRING, MaxClientRevives>0 ? 2 : 3, BHS_ClientHUD);
					ReadCenterText(bossIdx, BS_H_STRING, 4, BHS_Easy);				
					ReadCenterText(bossIdx, BS_H_STRING, 5, BHS_Normal);								
					ReadCenterText(bossIdx, BS_H_STRING, 6, BHS_Intermediate);
					ReadCenterText(bossIdx, BS_H_STRING, 7, BHS_Difficult);	
					ReadCenterText(bossIdx, BS_H_STRING, 8, BHS_Lunatic);	
					ReadCenterText(bossIdx, BS_H_STRING, 9, BHS_Insane);	
					ReadCenterText(bossIdx, BS_H_STRING, 10, BHS_Godlike);	
					ReadCenterText(bossIdx, BS_H_STRING, 11, BHS_RocketHell);	
					ReadCenterText(bossIdx, BS_H_STRING, 12, BHS_TotalBlitzkrieg);	
					ReadCenterText(bossIdx, BS_H_STRING, 13, BHS_RNGDisplay);
					ReadCenterText(bossIdx, BS_H_STRING, 14, BHS_Counter);		
					ReadCenterText(bossIdx, BS_H_STRING, 15, BHS_Counter2);		
				}
			
				RefreshDifficulty(DifficultyLevel);
			
				rMaxBounces = FF2_GetAbilityArgument(bossIdx,this_plugin_name,BLITZSETUP, 14); // Projectile Bounce
				timeExtension = FF2_GetAbilityArgument(bossIdx, this_plugin_name, BLITZSETUP, 15);
				startTime = FF2_GetAbilityArgument(bossIdx, this_plugin_name, BLITZSETUP, 16, 60);
				maxWaves = FF2_GetAbilityArgument(bossIdx, this_plugin_name, BLITZSETUP, 17);
				RNGesus = bool:FF2_GetAbilityArgument(bossIdx, this_plugin_name, BLITZSETUP, 18);
				
				
				if(LevelUpgrade)
					Blitz_AdminTauntAt = GetEngineTime() + 6.0;
			}
		}
	}
	
	// sarysa's adaptation of otokiru teleport, done in a way that it'll work even if blitzkrieg isn't enabled this round
	SPT_ActiveThisRound = false;
	for (new clientIdx = 1; clientIdx < MAX_PLAYERS; clientIdx++)
	{
		SPT_CanUse[clientIdx] = false;
	
		if (!IsValidClient(clientIdx, true))
			continue;
			
		new bossIdx = FF2_GetBossIndex(clientIdx);
		if (bossIdx < 0)
			continue;
			
		if ((SPT_CanUse[clientIdx] = FF2_HasAbility(bossIdx, this_plugin_name, SPT_STRING)) == true)
		{
			SPT_ActiveThisRound = true;
			SPT_NextCenterTextAt[clientIdx] = GetEngineTime() + 1.0;
			SPT_ChargesRemaining[clientIdx] = 0;

			new keyId = FF2_GetAbilityArgument(bossIdx, this_plugin_name, SPT_STRING, 1);
			if (keyId == 1)
				SPT_KeyToUse[clientIdx] = IN_ATTACK;
			else if (keyId == 2)
				SPT_KeyToUse[clientIdx] = IN_ATTACK2;
			else if (keyId == 3)
				SPT_KeyToUse[clientIdx] = IN_RELOAD;
			else if (keyId == 4)
				SPT_KeyToUse[clientIdx] = IN_ATTACK3;
			else
			{
				SPT_KeyToUse[clientIdx] = IN_RELOAD;
				PrintHintText(clientIdx, "Invalid key specified for point teleport. Using RELOAD.\nNotify your admin!");
			}
			SPT_NumSkills[clientIdx] = FF2_GetAbilityArgument(bossIdx, this_plugin_name, SPT_STRING, 2);
			SPT_MaxDistance[clientIdx] = FF2_GetAbilityArgumentFloat(bossIdx, this_plugin_name, SPT_STRING, 3);
			ReadCenterText(bossIdx, SPT_STRING, 4, SPT_CenterText);
			FF2_GetAbilityArgumentString(bossIdx, this_plugin_name, SPT_STRING, 5, SPT_OldLocationParticleEffect, MAX_EFFECT_NAME_LENGTH);
			FF2_GetAbilityArgumentString(bossIdx, this_plugin_name, SPT_STRING, 6, SPT_NewLocationParticleEffect, MAX_EFFECT_NAME_LENGTH);
			ReadSound(bossIdx, SPT_STRING, 7, SPT_UseSound);
			SPT_PreserveMomentum[clientIdx] = FF2_GetAbilityArgument(bossIdx, this_plugin_name, SPT_STRING, 8) == 1;
			SPT_AddCharges[clientIdx] = FF2_GetAbilityArgument(bossIdx, this_plugin_name, SPT_STRING, 9) == 1;
			SPT_EmptyClipOnTeleport[clientIdx] = FF2_GetAbilityArgument(bossIdx, this_plugin_name, SPT_STRING, 10) == 1;
			SPT_AttackDelayOnTeleport[clientIdx] = FF2_GetAbilityArgumentFloat(bossIdx, this_plugin_name, SPT_STRING, 11);
			
			SPT_KeyDown[clientIdx] = (GetClientButtons(clientIdx) & SPT_KeyToUse[clientIdx]) != 0;
			
			PrecacheSound(NOPE_AVI);
		}
		
	}

	// hook damage for BMO
	if (BMO_ActiveThisRound)
	{
		for (new clientIdx = 1; clientIdx < MAX_PLAYERS; clientIdx++)
		{
			BMO_MedicType[clientIdx] = BMO_MEDIGUN_MEDIC;
			if (IsClientInGame(clientIdx))
				SDKHook(clientIdx, SDKHook_OnTakeDamage, BMO_OnTakeDamage);
		}
	}
	
	// stuff for Blitzkrieg main
	if (blitzisboss)
	{
		for (new clientIdx = 1; clientIdx < MAX_PLAYERS; clientIdx++)
		{
			// gotta initialize this, in case someone ducks until they die (lol)
			if (IsValidClient(clientIdx, true))
				GetEntPropVector(clientIdx, Prop_Send, "m_vecOrigin", Blitz_LastPlayerPos[clientIdx]);
			Blitz_RemoveReviveMarkerAt[clientIdx] = FAR_FUTURE;
			Blitz_MoveReviveMarkerAt[clientIdx] = FAR_FUTURE;
			Blitz_ReverifyWeaponsAt[clientIdx] = FAR_FUTURE;
			Blitz_VerifyMedigunAt[clientIdx] = FAR_FUTURE;
			reviveMarker[clientIdx] = INVALID_ENTREF;
		}
	}
}


public NullRockets()
{
	new ent = -1, owner;
	while ((ent = FindEntityByClassname(ent, "tf_projectile_rocket")) != -1)
	{
		if((owner=GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity"))<=MaxClients && owner>0 && FF2_GetBossIndex(owner)>=0)
		{
			AcceptEntityInput(ent, "Kill");
		}
	}
}

public Action:OnRoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	RoundInProgress = false;
	rocketCount=0;
	// unhook damage for bmo
	if (BMO_ActiveThisRound)
	{
		BMO_ActiveThisRound = false; // no cleanup required for anything here
		for (new clientIdx = 1; clientIdx < MAX_PLAYERS; clientIdx++)
		{
			BMO_MedicType[clientIdx] = BMO_MEDIGUN_MEDIC; // reset this
			if (IsClientInGame(clientIdx))
				SDKUnhook(clientIdx, SDKHook_OnTakeDamage, BMO_OnTakeDamage);
				
		}
	}
	
	BWO_ActiveThisRound = false;

	if(blitzisboss)
	{
		if(playerCT)
		{
			SetConVarInt(FindConVar("ff2_countdown_players"),playerCT);
		}
	
		DifficultyLevel = 0;
		MaxClientRevives = 0;
		RageIsBarrage = false;
		IsRandomDifficultyMode = false;
		blitzisboss = false;
		Blitz_RemoveHooks();
		for(new client=1;client<=MaxClients;client++)
		{
			if(!IsValidClient(client))
				continue;
			IsBlitzkrieg[client]=false;
		}
		if (GetEventInt(event, "winning_team") == FF2_GetBossTeam())
			BossIsWinner = true;
		else if (GetEventInt(event, "winning_team") == ((FF2_GetBossTeam()==_:TFTeam_Blue) ? (_:TFTeam_Red) : (_:TFTeam_Blue)))
			BossIsWinner = false;
		CreateTimer(5.0, RoundResultSound, _, TIMER_FLAG_NO_MAPCHANGE); // sarysa: kept this one around, but fixed param #4 to be the no mapchange flag
		
		// remove revive markers & clean up HUD
		for (new clientIdx = 1; clientIdx < MAX_PLAYERS; clientIdx++)
		{
			if (!IsClientInGame(clientIdx) || Blitz_RemoveReviveMarkerAt[clientIdx] == FAR_FUTURE)
				continue;
			
			RemoveReanimator(clientIdx);
		}
		
		#if defined _revivemarkers_included_
		if(IntegrationMode)
		{
			SetConVarInt(cvarHaleVisibility, cvalHaleVisibility);
			SetConVarInt(cvarVisibility, cvalVisibility);
			SetConVarInt(cvarNoRestrict, cvalNoRestrict);
			SetConVarInt(cvarTeamRestrict, cvalTeamRestrict);
		}
		#endif
		
	}
}

// Blitzkrieg's Rage & Death Effect //

public Action:FF2_OnAbility2(boss,const String:plugin_name[],const String:ability_name[],action)
{
	// sarysa 2015-03-25, putting this here before the variables with the exact same name sans one capital letter
	// which, btw, is extremely confusing to read...
	if (!RoundInProgress || strcmp(plugin_name, this_plugin_name) != 0 || FF2_GetRoundState()!=1)
		return Plugin_Continue; // no end of round glitches, please.
	if (!strcmp(ability_name, SPT_STRING))
	{
		Rage_sarysaPointTeleport(boss);
		return Plugin_Continue;
	}

	// back to shadow93's code
	new Boss=GetClientOfUserId(FF2_GetBossUserId(boss));
	if (!strcmp(ability_name,"blitzkrieg_barrage")) 	// UBERCHARGE, KRITZKRIEG & CROCKET HELL
	{	
		if(WeaponMode && GetRandomFloat(0.00,1.0)<=0.05 && RNGesus) // baka?
		{
			NullRockets();
			ForcePlayerSuicide(Boss);
			return Plugin_Continue;
		}
		
		RageIsBarrage=true;
		BMO_CurrentIsBlizkrieg = true;
			
		if(WeaponMode)
		{
			NullRockets();
		}
			
		if(TF2_IsPlayerInCondition(Boss, TFCond_Dazed))
		{
			TF2_RemoveCondition(Boss, TFCond_Dazed);
		}
			
		TF2_AddCondition(Boss,TFCond_Ubercharged,FF2_GetAbilityArgumentFloat(boss,this_plugin_name,ability_name,1,5.0)); // Ubercharge
		Blitz_RemoveUberAt = GetEngineTime() + FF2_GetAbilityArgumentFloat(boss,this_plugin_name,ability_name,1,5.0);
		TF2_AddCondition(Boss,BLITZKRIEG_COND_CRIT,FF2_GetAbilityArgumentFloat(boss,this_plugin_name,ability_name,2,5.0)); // Kritzkrieg
		if(LevelUpgrade)
		{
			LoomynartyMusic = true;
			if(LevelUpgrade==1)
				DifficultyLevel=GetRandomInt(MinDifficulty,MaxDifficulty);
			else
			{
				// so sourcemod does switches differently. no break required. who'd have thought. - sarysa
				if ((BMO_Flags & BMO_FLAG_BLOCK_NOVELTY_DIFFICULTY) == 0)
				{
					switch(DifficultyLevel)
					{
						case 9: DifficultyLevel=420;
						case 420: DifficultyLevel=777;
						case 777: DifficultyLevel=999;
						case 999: DifficultyLevel=1337;
						case 1337: DifficultyLevel=9001;
						case 9001:
						{
							if(IsRandomDifficultyMode)
								DifficultyLevel=MinDifficulty;
							else
								DifficultyLevel=FF2_GetAbilityArgument(boss,this_plugin_name,BLITZSETUP, 1, 2);
						}
						default: DifficultyLevel=DifficultyLevel+1;
					}
				}
				else
					DifficultyLevel=DifficultyLevel+1;
			}
			RefreshDifficulty(DifficultyLevel);	
		}
		SetEntProp(Boss, Prop_Data, "m_takedamage", 0);
		//Switching Blitzkrieg's player class while retaining the same model to switch the voice responses/commands
		PlotTwist(Boss);
		Blitz_EndCrocketHellAt = GetEngineTime() + FF2_GetAbilityArgumentFloat(boss,this_plugin_name,ability_name,3);
		if(!WeaponMode) // 2x strength if using mixed melee/rocket launcher
		{
			new Float:rDuration=FF2_GetAbilityArgumentFloat(boss,this_plugin_name,ability_name, 3);
			TF2_AddCondition(Boss, COND_RUNE_STRENGTH, rDuration);
		}
		//For the Class Reaction Voice Lines
		switch(AlertMode)
		{
			case 1:
			{
				if ((BMO_Flags & BMO_FLAG_NO_CLASS_MESSAGES) != 0)
					return Plugin_Continue;
				for(new i = 1; i <= MaxClients; i++ )
				{
					ClassResponses(i);
				}
			}
			case 0:
				if ((BMO_Flags & BMO_FLAG_NO_ALERT_SOUNDS) == 0)
					EmitSoundToAll(BLITZKRIEG_SND);
		}
	}
	
	else if (!strcmp(ability_name,"mini_blitzkrieg")) 	// KRITZKRIEG & CROCKET HELL
	{		
		if(!RageIsBarrage)
		{
			BMO_CurrentIsBlizkrieg = false;
		}
		
		if(WeaponMode)
		{
			NullRockets();
		}
			
		if(TF2_IsPlayerInCondition(Boss, TFCond_Dazed))
		{
			TF2_RemoveCondition(Boss, TFCond_Dazed);
		}
			
		TF2_AddCondition(Boss,BLITZKRIEG_COND_CRIT,FF2_GetAbilityArgumentFloat(boss,this_plugin_name,ability_name,1,5.0)); // Kritzkrieg
		TF2_RemoveWeaponSlot(Boss, TFWeaponSlot_Primary);
		//RAGE Voice lines depending on Blitzkrieg's current player class (Blitzkrieg is two classes in 1 - Medic / Soldier soul in the same body)
		if(!(BMO_Flags & BMO_FLAG_NO_VOICE_MESSAGES))
		{
			new String:sound[PLATFORM_MAX_PATH];
			switch(TF2_GetPlayerClass(Boss))
			{
				case TFClass_Medic: // Medic
				{
					if(FF2_RandomSound("sound_blitz_medicrage", sound, sizeof(sound), boss))
					{
						EmitSoundToAll(sound, Boss);
						EmitSoundToAll(sound, Boss);
					}		
				}
				case TFClass_Soldier: // Soldier
				{
					if(FF2_RandomSound("sound_blitz_soldierrage", sound, sizeof(sound), boss))
					{
						EmitSoundToAll(sound, Boss);
						EmitSoundToAll(sound, Boss);
					}	
				}
			}
		}
		// Weapon switch depending if Blitzkrieg RageIsBarrage is active or not
		RandomDanmaku(Boss, DifficultyLevel);
		SetAmmo(Boss, TFWeaponSlot_Primary,(WeaponMode == 1 ? 999999 : RageRockets));
		
		switch(AlertMode)
		{
			case 1:
			{
				if ((BMO_Flags & BMO_FLAG_NO_CLASS_MESSAGES) != 0)
					return Plugin_Continue;
				for(new i = 1; i <= MaxClients; i++ )
				{
					ClassResponses(i);
				}
			}
			case 0:
				if ((BMO_Flags & BMO_FLAG_NO_ALERT_SOUNDS) == 0)
					EmitSoundToAll(MINIBLITZKRIEG_SND);
		}
	}
	return Plugin_Continue;
}

// Switch Roles ability
PlotTwist(client)
{
	if(RageIsBarrage)
	{
		new boss=FF2_GetBossIndex(client);
		if(!(BMO_Flags & BMO_FLAG_KEEP_PLAYER_CLASS) || !(BMO_Flags & BMO_FLAG_NO_VOICE_MESSAGES))
		{
			new String:sound[PLATFORM_MAX_PATH];
			switch(TF2_GetPlayerClass(client))
			{
				case TFClass_Medic: // Medic
				{
					if(!(BMO_Flags & BMO_FLAG_KEEP_PLAYER_CLASS))
						TF2_SetPlayerClass(client, TFClass_Soldier, _, false);
					if(boss>=0 && FF2_RandomSound("sound_blitz_soldiermode", sound, sizeof(sound), boss) && !(BMO_Flags & BMO_FLAG_NO_VOICE_MESSAGES))
					{
						EmitSoundToAll(sound);
						EmitSoundToAll(sound);
					}
				}
				case TFClass_Soldier: // Soldier
				{
					if(!(BMO_Flags & BMO_FLAG_KEEP_PLAYER_CLASS))
						TF2_SetPlayerClass(client, TFClass_Medic, _, false);
					if(boss>=0 && FF2_RandomSound("sound_blitz_medicmode", sound, sizeof(sound), boss) && !(BMO_Flags & BMO_FLAG_NO_VOICE_MESSAGES))
					{
						EmitSoundToAll(sound);
						EmitSoundToAll(sound);
					}	
				}
			}
		}
	}
	else
	{
		if (!(BMO_Flags & BMO_FLAG_KEEP_PLAYER_CLASS))
		{
			new RandomClass = GetRandomInt(0,1);
			TF2_SetPlayerClass(client, (RandomClass == 0 ? TFClass_Medic : TFClass_Soldier), _, false);
		}
	}
	
	if (BMO_Flags & BMO_FLAG_KEEP_MELEE)
	{
		for(new slot=0;slot<=5;slot++)
		{
			if(slot != TFWeaponSlot_Melee)
			{
				TF2_RemoveWeaponSlot(client, slot);
			}
		}
	}
	else
	{
		TF2_RemoveAllWeapons(client);
	}
	
	// ONLY FOR LEGACY REASONS, FF2 1.10.3 and newer doesn't actually need this to restore the boss model.
	if ((BMO_Flags & BMO_FLAG_KEEP_PLAYER_MODEL) == 0)
	{
		SetVariantString(TF2_GetPlayerClass(client)==TFClass_Medic ? BLITZ_MEDIC : BLITZ_SOLDIER);
		AcceptEntityInput(client, "SetCustomModel");
		SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
	}
	// Removing all wearables
	new entity, owner;
	while((entity=FindEntityByClassname(entity, "tf_wearable"))!=-1)
		if((owner=GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity"))<=MaxClients && owner>0 && IsBlitzkrieg[owner])
			TF2_RemoveWearable(owner, entity);
	while((entity=FindEntityByClassname(entity, "tf_wearable_demoshield"))!=-1)
		if((owner=GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity"))<=MaxClients && owner>0 && IsBlitzkrieg[owner])
			TF2_RemoveWearable(owner, entity);
	while((entity=FindEntityByClassname(entity, "tf_powerup_bottle"))!=-1)
		if((owner=GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity"))<=MaxClients && owner>0 && IsBlitzkrieg[owner])
			TF2_RemoveWearable(owner, entity);

	if (!(BMO_Flags & BMO_FLAG_NO_PARACHUTE))
		SpawnWeapon(client, "tf_weapon_parachute", 1101, 109, 5, "700 ; 1 ; 701 ; 99 ; 702 ; 99 ; 703 ; 99 ; 705 ; 1 ; 640 ; 1 ; 68 ; 12 ; 269 ; 1 ; 275 ; 1");

	if(RageIsBarrage || RoundStartMode)
		RandomDanmaku(client, DifficultyLevel);
	
	if(!WeaponMode)
	{
		if (!(BMO_Flags & BMO_FLAG_KEEP_MELEE))
		{
			switch(DifficultyLevel)
			{
				case 420: SpawnWeapon(client, "tf_weapon_knife", (TF2_GetPlayerClass(client) == TFClass_Medic ? 1003 : 416), 109, 5, "2 ; 5.2 ; 137 ; 5.2 ; 267 ; 1 ; 391 ; 5.2 ; 401 ; 5.2 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 4");						
				case 777: SpawnWeapon(client, "tf_weapon_knife", (TF2_GetPlayerClass(client) == TFClass_Medic ? 1003 : 416), 109, 5, "2 ; 8.77 ; 137 ; 8.77 ; 267 ; 1 ; 391 ; 8.77 ; 401 ; 8.77 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 5");						
				case 999: SpawnWeapon(client, "tf_weapon_knife", (TF2_GetPlayerClass(client) == TFClass_Medic ? 1003 : 416), 109, 5, "2 ; 10.99 ; 137 ; 10.99 ; 267 ; 1 ; 391 ; 10.99 ; 401 ; 10.99 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 5");						
				case 1337: SpawnWeapon(client, "tf_weapon_knife", (TF2_GetPlayerClass(client) == TFClass_Medic ? 1003 : 416), 109, 5, "2 ; 14.37 ; 137 ; 14.37 ; 267 ; 1 ; 391 ; 14.37 ; 401 ; 14.37 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 5");						
				case 9001: SpawnWeapon(client, "tf_weapon_knife", (TF2_GetPlayerClass(client) == TFClass_Medic ? 1003 : 416), 109, 5, "2 ; 100 ; 137 ; 100 ; 267 ; 1 ; 391 ; 100 ; 401 ; 100 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 5");						
				default: SpawnWeapon(client, "tf_weapon_knife", (TF2_GetPlayerClass(client) == TFClass_Medic ? 1003 : 416), 109, 5, "2 ; 3.1 ; 138 ; 0.75 ; 39 ; 0.3 ; 267 ; 1 ; 391 ; 1.9 ; 401 ; 1.9 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6");
			}
		}
	}
	SetAmmo(client, TFWeaponSlot_Primary,(WeaponMode==1 ? 999999 : (RageIsBarrage == true ? LifeLossRockets : RageRockets)));
}		

// Weaponswitch

bool:BWO_CheckWeaponOverrides(clientIdx, weapon, slot)
{
	if (!BWO_ActiveThisRound || !IsValidEntity(weapon))
		return false;
	
	new weaponIdx = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
	for (new i = 0; i < BWO_Count; i++)
	{
		if (weaponIdx == BWO_WeaponIndexes[i])
		{
			static String:classname[MAX_ENTITY_CLASSNAME_LENGTH];
			GetEntityClassname(weapon, classname, sizeof(classname));
			if (slot == -1)
			{
				TF2_RemoveWearable(clientIdx, weapon);
				if (IsValidEntity(weapon))
					AcceptEntityInput(weapon, "kill"); // I'm not 100% confident this actually gets done automatically.
			}
			else
				TF2_RemoveWeaponSlot(clientIdx, slot);
				
			if (BMO_Flags & BMO_FLAG_VSP_SWORD_WORKAROUND)
			{
				// I don't have the time or resources to figure out this problem gracefully
				// so I need to switch weapon indices while keeping player's desired stats
				if (weaponIdx == 404 || weaponIdx == 172) // persian, skullcutter
					weaponIdx = 1082; // festive eyelander
			}
			weapon = SpawnWeapon(clientIdx, classname, weaponIdx, 5, 10, BWO_WeaponArgs[i]);
			if (PRINT_DEBUG_INFO)
				PrintToServer("[Blitzkrieg] [i=%d] Swapped out %d's weapon (%d)", i, clientIdx, BWO_WeaponIndexes[i]);
			return true;
		}
		else if (PRINT_DEBUG_SPAM)
			PrintToServer("[Blitzkrieg] [i=%d] Weapon didn't match. Wanted %d got %d", i, BWO_WeaponIndexes[i], weaponIdx);
	}
	
	return false;
}


// Help Panel

PlayerHelpPanel(client)
{
	new String:text[5120];
	new TFClassType:class=TF2_GetPlayerClass(client);
	SetGlobalTransTarget(client);
	switch(class)
	{
		case TFClass_Scout:
		{
			text = BS_HelpScout;
		}
		case TFClass_Soldier:
		{
			text = BS_HelpSoldier;
		}
		case TFClass_Pyro:
		{
			text = BS_HelpPyro;
		}
		case TFClass_DemoMan:
		{
			text = BS_HelpDemo;
		}
		case TFClass_Heavy:
		{
			text = BS_HelpHeavy;
		}
		case TFClass_Engineer:
		{
			text = BS_HelpEngie;
		}
		case TFClass_Medic:
		{
			text = BS_HelpMedic;
		}
		case TFClass_Sniper:
		{
			text = BS_HelpSniper;
		}
		case TFClass_Spy:
		{
			text = BS_HelpSpy;
		}
	}
	CPrintToChat(client, text);
}

public MoveMarker(client)
{
	Blitz_MoveReviveMarkerAt[client] = FAR_FUTURE;
	if (reviveMarker[client] == INVALID_ENTREF)
		return;
		
	new marker = EntRefToEntIndex(reviveMarker[client]);
	if (!IsValidEntity(marker))
	{
		reviveMarker[client] = INVALID_ENTREF;
		Blitz_RemoveReviveMarkerAt[client] = FAR_FUTURE;
		return;
	}
	
	if (!IsClientInGame(client))
	{
		AcceptEntityInput(marker, "kill");
		reviveMarker[client] = INVALID_ENTREF;
		Blitz_RemoveReviveMarkerAt[client] = FAR_FUTURE;
		return;
	}

	// must offset by 20, otherwise they can fall through the world
	static Float:spawnPos[3];
	spawnPos[0] = Blitz_LastPlayerPos[client][0];
	spawnPos[1] = Blitz_LastPlayerPos[client][1];
	spawnPos[2] = Blitz_LastPlayerPos[client][2] + 20.0;
	TeleportEntity(marker, spawnPos, NULL_VECTOR, NULL_VECTOR);
		
	if (PRINT_DEBUG_SPAM)
		PrintToServer("[%d] Marker moved at %f", client, GetEngineTime());
}

public bool:IsValidMarker(marker) 
{
	if (IsValidEntity(marker)) 
	{
		decl String:buffer[128];
		GetEntityClassname(marker, buffer, sizeof(buffer));
		if (strcmp(buffer,"entity_revive_marker",false) == 0)
		{
			return true;
		}
	}
	return false;
}

public Action:OnPlayerSpawn(Handle:event, const String:name[], bool:dontbroadcast) 
{
	// this whole sequence was very very broken. sarysa fixed it.
	// mixup of userid, bossIdx, and clientIdx is why
	
	new userid = GetEventInt(event, "userid");
	new clientIdx = GetClientOfUserId(userid);
	
	if(blitzisboss && MaxClientRevives != 0)
	{
		#if defined _revivemarkers_included_
		{
			if(IntegrationMode)
				DespawnRMarker(clientIdx);
			else
				RemoveReanimator(clientIdx);
		}
		#else
			RemoveReanimator(clientIdx);
		#endif

		clientRevives[clientIdx]++;
	}
	
	if(RoundInProgress && blitzisboss && MaxClientRevives != 0)
	{
		Blitz_ReverifyWeaponsAt[clientIdx] = GetEngineTime() + 0.5; // setting this high so VSP's weapon swapper can go first
	}
	
	return Plugin_Continue;
}

public Action:OnChangeClass(Handle:event, const String:name[], bool:dontbroadcast) 
{
	if(blitzisboss)
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		ChangeClass[client] = true;
	}
	return Plugin_Continue;
}

public OnClientDisconnect(client) 
{
	if(blitzisboss)
	{
		if(MaxClientRevives!=0)
		{
			#if defined _revivemarkers_included_
			{
				if(IntegrationMode)
					DespawnRMarker(client);
				else	
					RemoveReanimator(client);
			}
			#else
				RemoveReanimator(client);
			#endif
		}
		currentTeam[client] = 0;
		ChangeClass[client] = false;
	}
 }

public Action:BlitzHelp(client, const String:command[], argc)
{
	if(blitzisboss)
	{
		PlayerHelpPanel(client);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:OnAnnounce(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(blitzisboss)
	{
		new String:strAudio[40];
		GetEventString(event, "sound", strAudio, sizeof(strAudio));
		if(strncmp(strAudio, "Game.Your", 9) == 0 || strcmp(strAudio, "Game.Stalemate") == 0)
		{
			if (!BMO_NoIntroOutroSounds && BOuttro[0]!='\0')
				EmitSoundToAll(BOuttro);
			// Block sound from being played
			return Plugin_Handled;
		}
		return Plugin_Continue;
	}
	return Plugin_Continue;
}

public PostSetup()
{
	// first, lets find our randomly selected medics
	if (UseCustomWeapons && BMO_ActiveThisRound && (BMO_NormalMedicLimit > 0 || BMO_MedicLimitPercent > 0.0))
	{
		new count = 0;
		new totalPlayerCount = 0;
		static bool:isMedigunMedic[MAX_PLAYERS_ARRAY];
		for (new clientIdx = 1; clientIdx < MAX_PLAYERS; clientIdx++)
		{
			isMedigunMedic[clientIdx] = false;
			BMO_MedicType[clientIdx] = BMO_NOT_A_MEDIC;
			if (!IsValidClient(clientIdx, true) || GetClientTeam(clientIdx) == FF2_GetBossTeam())
				continue;
			
			totalPlayerCount++;
			if (TF2_GetPlayerClass(clientIdx) != TFClass_Medic)
				continue;
				
			new weapon = GetPlayerWeaponSlot(clientIdx, TFWeaponSlot_Secondary);
			if (!IsValidEntity(weapon))
			{
				// this can actually happen on VSP. switch them to a crossbow
				BMO_MedicType[clientIdx] = BMO_CROSSBOW_MEDIC;
				continue;
			}
			
			if (IsInstanceOf(weapon, "tf_weapon_medigun"))
			{
				BMO_MedicType[clientIdx] = BMO_MEDIGUN_MEDIC;
				isMedigunMedic[clientIdx] = true;
				count++;
			}
			// else...it's a randomizer server I guess? shadow93, have fun deciding what happens here :p
		}
		
		if (BMO_MedicLimitPercent > 0.0)
			BMO_NormalMedicLimit = max(1, RoundFloat(BMO_MedicLimitPercent * totalPlayerCount));
		
		if (!IsEmptyString(BMO_MedicLimitAlert))
			CPrintToChatAll(BMO_MedicLimitAlert, BMO_NormalMedicLimit);
		
		// time to randomly select people?
		while (count > BMO_NormalMedicLimit)
		{
			new rand = GetRandomInt(0, count - 1);
			for (new clientIdx = 1; clientIdx < MAX_PLAYERS; clientIdx++)
			{
				if (isMedigunMedic[clientIdx])
				{
					if (rand == 0)
					{
						isMedigunMedic[clientIdx] = false;
						BMO_MedicType[clientIdx] = BMO_CROSSBOW_MEDIC;
						count--;
						if (!IsEmptyString(BMO_CrossbowAlert))
							CPrintToChat(clientIdx, BMO_CrossbowAlert);
						break;
					}
					else
						rand--;
				}
			}
		}
	}
	
	// Apparently this is still needed.
	for(new client = 1; client <= MaxClients; client++ )
	{
		if(blitzisboss && UseCustomWeapons)
		{
			if(IsValidClient(client, true) && GetClientTeam(client)!=FF2_GetBossTeam())
			{
				//TF2_RegeneratePlayer(client);
				CheckWeapons(client, true);
				HealPlayer(client);
				if(!IsFakeClient(client))
					PlayerHelpPanel(client);
			}
		}
	}
}

public Action:OnPlayerHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	new attacker=GetClientOfUserId(GetEventInt(event, "attacker"));	
	if(!IsValidClient(attacker))
	{
		return Plugin_Continue;
	}
	
	if(IsBoss(attacker))
	{
		return Plugin_Continue;
	}
	
	new damage=GetEventInt(event, "damageamount");
	new weapon=GetPlayerWeaponSlot(attacker, TFWeaponSlot_Primary);
	if(IsValidEntity(weapon) && GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex")==127)  //Workaround for Direct Hit
	{
		static DHDamage;
		DHDamage+=damage;
		if(DHDamage>=200)
		{
			SetEntProp(attacker, Prop_Send, "m_iDecapitations", GetEntProp(attacker, Prop_Send, "m_iDecapitations")+1);
			DHDamage-=200;
		}
	}
	return Plugin_Continue;
}

public Action:OnPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	// ensure we should be doing any of this at all
	if (!blitzisboss)
		return;

	new attacker=GetClientOfUserId(GetEventInt(event, "attacker"));
	new victim=GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsBlitzkrieg[victim])
		return; // sarysa, fix an error when the hale loses
		
	if ((GetEventInt(event, "death_flags") & TF_DEATHFLAG_DEADRINGER) != 0)
		return; // sarysa, fix an error where dead ringer drops a revive marker
		
	new String:weapon[50];
	GetEventString(event, "weapon", weapon, sizeof(weapon));
	
	new bossIdx = 0;

	// allow revive for victim regardless of cause of death
	if (MaxClientRevives!=0 && !IsBoss(victim))
	{
		EmitSoundToClient(victim, PLAYERDEATH);
		#if defined _revivemarkers_included_
		if(IntegrationMode)
			SpawnRMarker(victim);
		else	
			DropReviveMarker(victim);
		#else
			DropReviveMarker(victim);
		#endif
	}
	if (IsBlitzkrieg[attacker])
	{
		if (StrEqual(weapon, "tf_projectile_rocket", false)||StrEqual(weapon, "airstrike", false)||StrEqual(weapon, "liberty_launcher", false)||StrEqual(weapon, "quake_rl", false)||StrEqual(weapon, "blackbox", false)||StrEqual(weapon, "dumpster_device", false)||StrEqual(weapon, "rocketlauncher_directhit", false)||StrEqual(weapon, "flamethrower", false))
			SetEventString(event, "weapon", "firedeath");
		else
			SetEventString(event, "weapon", "saw_kill");

		new Float:rageonkill = FF2_GetAbilityArgumentFloat(bossIdx,this_plugin_name,BLITZSETUP,13,0.0);
		new Float:bRage = FF2_GetBossCharge(bossIdx,0);

		if(rageonkill)
		{
			if(100.0 - bRage < rageonkill) // We don't want RAGE to exceed more than 100%
				FF2_SetBossCharge(bossIdx, 0, bRage + (100.0 - bRage));
			else if (100.0 - bRage > rageonkill)
				FF2_SetBossCharge(bossIdx, 0, bRage+rageonkill);
		}

		if (GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon") == GetPlayerWeaponSlot(attacker, TFWeaponSlot_Primary))
		{
			if(WeaponMode)
			{	
				TF2_RemoveWeaponSlot(attacker, TFWeaponSlot_Primary);
				RandomDanmaku(attacker, DifficultyLevel);
				SetAmmo(attacker, TFWeaponSlot_Primary, (RageIsBarrage == true ? LifeLossRockets : 999999));
			}		
		}
	}
}	


public WhatWereYouThinking()
{
	new String:BlitzAlert[PLATFORM_MAX_PATH];
	strcopy(BlitzAlert, PLATFORM_MAX_PATH, BlitzCanLevelUpgrade[GetRandomInt(0, sizeof(BlitzCanLevelUpgrade)-1)]);
	if ((BMO_Flags & BMO_FLAG_NO_BEGIN_ADMIN_MESSAGES) == 0)
		EmitSoundToAll(BlitzAlert);
}

public Action:RoundResultSound(Handle:hTimer, any:userid)
{
	new String:BlitzRoundResult[PLATFORM_MAX_PATH];
	if (BossIsWinner)
		strcopy(BlitzRoundResult, PLATFORM_MAX_PATH, BlitzIsVictorious[GetRandomInt(0, sizeof(BlitzIsVictorious)-1)]);
	else
		strcopy(BlitzRoundResult, PLATFORM_MAX_PATH, BlitzIsDefeated[GetRandomInt(0, sizeof(BlitzIsDefeated)-1)]);	
	for(new i = 1; i <= MaxClients; i++ )
	{
		if(IsClientInGame(i) && IsClientConnected(i) && GetClientTeam(i) != FF2_GetBossTeam())
		{
			if ((BMO_Flags & BMO_FLAG_NO_END_ADMIN_MESSAGES) == 0)
				EmitSoundToClient(i, BlitzRoundResult);	
		}
	}
	BossIsWinner = false;
}

public ItzBlitzkriegTime(Boss)
{
	if(WeaponMode)
	{
		TF2_RemoveWeaponSlot(Boss, TFWeaponSlot_Primary);
		RandomDanmaku(Boss, DifficultyLevel);	
		SetAmmo(Boss, TFWeaponSlot_Primary,999999);
	}
	RageIsBarrage=false;
}

public RemoveUber(Boss)
{
	SetEntProp(Boss, Prop_Data, "m_takedamage", 2);
	TF2_AddCondition(Boss, TFCond_UberchargeFading, 3.0);
}

/**
 * Blitzkrieg Main Code Appends
 */
 
public Blitz_HUDSyncTick(Float:curTime)
{
	if(curTime>=Blitzkrieg_FindBlitzkriegAt)
	{
		if(FF2_GetRoundState()>0)
		{
			Blitzkrieg_FindBlitzkriegAt=FAR_FUTURE;
			return;
		}
		for(new clientIdx=1;clientIdx<=MaxClients;clientIdx++)
		{
			if(!IsValidClient(clientIdx))
				continue;
			new bossIdx=FF2_GetBossIndex(clientIdx);
			if(bossIdx>=0 && FF2_HasAbility(bossIdx, this_plugin_name, "blitzkrieg_config"))
			{
				blitzisboss = true;
				Blitz_AddHooks();
				IsRandomDifficultyMode = false;
				RageIsBarrage = false;

				// Intro BGM
				if(!(FF2_HasAbility(bossIdx, this_plugin_name, BMO_STRING) && (BMO_NoIntroOutroSounds = FF2_GetAbilityArgument(bossIdx, this_plugin_name, BMO_STRING, 7)) != 0))
				{
					char sound[PLATFORM_MAX_PATH];
				
					if(FF2_RandomSound("sound_intromusic", sound, sizeof(sound), bossIdx))
					{
						EmitSoundToAll(sound);
					}	
					if(FF2_RandomSound("sound_outtromusic", sound, sizeof(sound), bossIdx) && !(FF2_HasAbility(bossIdx, this_plugin_name, BMO_STRING) && (BMO_NoIntroOutroSounds = FF2_GetAbilityArgument(bossIdx, this_plugin_name, BMO_STRING, 7)) != 0))
					{
						BOuttro=sound;
					}
				}
			}
		}
		Blitzkrieg_FindBlitzkriegAt=FAR_FUTURE;
	}
	
	if (curTime >= Blitz_HUDSync)
	{
		if(FF2_GetRoundState()!=1)
		{
			Blitz_HUDSync=FAR_FUTURE;
			return;
		}
		
		new String:BossHUDTxt[MAX_CENTER_TEXT_LENGTH];
		new String:ClientHudTxt[MAX_CENTER_TEXT_LENGTH];
		for(new clientIdx=1;clientIdx<=MaxClients;clientIdx++)
		{
			if (IsValidClient(clientIdx) && !(GetClientButtons(clientIdx) & IN_SCORE))
			{
				if(IsBoss(clientIdx))
				{
					SetHudTextParams(-1.0, 0.73, 0.4, 255, 255, 255, 255);
					Format(BossHUDTxt, sizeof(BossHUDTxt), BHS_BossHud, DifficultyLevelString);
					FF2_ShowSyncHudText(clientIdx, BossHUDS, BossHUDTxt);
				}
			
				if(IsPlayerAlive(clientIdx) && GetClientTeam(clientIdx)!=FF2_GetBossTeam())
				{
					SetHudTextParams(-1.0, 0.75, 0.4, 255, 255, 255, 255);
					if(MaxClientRevives>0)
					{
						Format(ClientHudTxt, sizeof(ClientHudTxt), BHS_ClientHUD, DifficultyLevelString, clientRevives[clientIdx], MaxClientRevives);
					}
					else
					{
						Format(ClientHudTxt, sizeof(ClientHudTxt), BHS_ClientHUD, DifficultyLevelString);				
					}
					FF2_ShowSyncHudText(clientIdx, ClientHUDS, ClientHudTxt);			
				}
			
				if(!IsPlayerAlive(clientIdx))
				{
					new observerIdx=GetEntPropEnt(clientIdx, Prop_Send, "m_hObserverTarget");
					SetHudTextParams(-1.0, 0.85, 0.4, 255, 255, 255, 255);	
					if(IsValidClient(observerIdx) && !IsBoss(observerIdx) && observerIdx!=clientIdx)
					{
						FF2_ShowSyncHudText(clientIdx, ClientHUDS, "Revives: %i - %N's Revives: %i", clientRevives[clientIdx], observerIdx, clientRevives[observerIdx]);
					}	
					else
					{
						FF2_ShowSyncHudText(clientIdx, ClientHUDS, "Revives: %i", clientRevives[clientIdx]);
					}
					continue;	
				}
			}
		}
		Blitz_HUDSync+=0.2;
	}
	
	if(curTime>=Blitz_WaveTick)
	{
		static wavesDone=0;
		static BlitzCount=0;
		if(!BlitzCount && !wavesDone)
		{
			BlitzCount+=startTime;
			wavesDone++;
		}
		
		static BlitzTimePassed=0;
		if(FF2_GetRoundState()!=1)
		{	
			wavesDone=0;
			BlitzCount=startTime;
			BlitzTimePassed=0;
			Blitz_WaveTick=FAR_FUTURE;
			return;
		}
	
		for(new clientIdx=1;clientIdx<=MaxClients;clientIdx++)
		{
			if(!IsValidClient(clientIdx))
				continue;
			
			new String:waveTime[6];
			if(BlitzCount/60>9)
			{
				IntToString(BlitzCount/60, waveTime, sizeof(waveTime));
			}	
			else
			{
				Format(waveTime, sizeof(waveTime), "0%i", BlitzCount/60);
			}
	
			if(BlitzCount%60>9)
			{
				Format(waveTime, sizeof(waveTime), "%s:%i", waveTime, BlitzCount%60);
			}	
			else
			{
				Format(waveTime, sizeof(waveTime), "%s:0%i", waveTime, BlitzCount%60);
			}
			
			new String:countdown[MAX_CENTER_TEXT_LENGTH];
			SetHudTextParams(-1.0, 0.25, 1.1, BlitzCount<=30 ? 255 : 0, BlitzCount>10 ? 255 : 0, 0, 255);
			
			if(maxWaves>0)
			{
				Format(countdown,sizeof(countdown), BHS_Counter2, wavesDone, maxWaves, waveTime);
			}
			else
			{
				Format(countdown,sizeof(countdown), BHS_Counter, wavesDone, waveTime);			
			}
			
			ShowSyncHudText(clientIdx, counterHUD, countdown);	
		
			if(!BlitzCount)
			{
				if(IsBlitzkrieg[clientIdx])
				{
					ItzBlitzkriegTime(clientIdx);
				}
				if(IsPlayerAlive(clientIdx) && !IsBoss(clientIdx))
				{
					// Give them survival points based on number of rockets
					new Handle:hPoints=CreateEvent("player_escort_score", true);
					SetEventInt(hPoints, "player", clientIdx);
					SetEventInt(hPoints, "points", rocketCount);
					FireEvent(hPoints);
						
					new qPoints=FF2_GetQueuePoints(clientIdx)+(BlitzTimePassed/4);
					FF2_SetQueuePoints(clientIdx, qPoints);
					CPrintToChat(clientIdx, "{olive}[FF2]{default} You have earned %i queue points for surviving a wave of %i rockets for %i seconds", qPoints, rocketCount, BlitzTimePassed);
						
					TF2_RegeneratePlayer(clientIdx);
					CheckWeapons(clientIdx, false);
					HealPlayer(clientIdx);
				}
			}
		}
	
		if(BlitzCount<=10)
		{
			char sound[PLATFORM_MAX_PATH];
			switch(BlitzCount)
			{
				case 0: // Give ammo & reset timer
				{
					NullRockets();
					if(FF2_RandomSound("sound_blitz_countdown_reset", sound, sizeof(sound), blitzBossIdx))
					{
						EmitSoundToAll(sound);
					}
					rocketCount=0;
					
					if(maxWaves>0 && wavesDone>=maxWaves)
					{
						ForceTeamWin(0);
						wavesDone=0;
						BlitzCount=startTime;
						BlitzTimePassed=0;
						Blitz_WaveTick=FAR_FUTURE;
						return;
					}
					
					wavesDone++;
					BlitzCount=BlitzTimePassed+timeExtension;
					BlitzTimePassed=0;
					Blitz_WaveTick+=1.0;
					
					return;
				}
				case 10,9,8,7,6,5,4,3,2,1:
				{
					if(FF2_RandomSound("sound_blitz_countdown_tick", sound, sizeof(sound), blitzBossIdx))
					{
						EmitSoundToAll(sound);
					}
				}
			}				
		}
		BlitzCount--;
		BlitzTimePassed++;
		Blitz_WaveTick+=1.0;
	}
}
public Blitz_Tick(Float:curTime)
{
	if (curTime >= Blitz_EndCrocketHellAt)
	{
		for(new clientIdx=1;clientIdx<=MaxClients;clientIdx++)
		{
			if(!IsValidClient(clientIdx, true))
				continue;
			if(!IsBlitzkrieg[clientIdx])
				continue;
				
			ItzBlitzkriegTime(clientIdx);
		}
		Blitz_EndCrocketHellAt = FAR_FUTURE;
	}
	
	if (curTime >= Blitz_PostSetupAt)
	{
		PostSetup();
		Blitz_PostSetupAt = FAR_FUTURE;
	}
	
	if (curTime >= Blitz_AdminTauntAt)
	{
		WhatWereYouThinking();
		Blitz_AdminTauntAt = FAR_FUTURE;
	}
	
	if (curTime >= Blitz_RemoveUberAt)
	{
		for(new clientIdx=1;clientIdx<=MaxClients;clientIdx++)
		{
			if(!IsValidClient(clientIdx, true))
				continue;
			if(!IsBlitzkrieg[clientIdx])
				continue;
				
			RemoveUber(clientIdx);
		}
		Blitz_RemoveUberAt = FAR_FUTURE;
	}
	
	for (new clientIdx = 1; clientIdx < MAX_PLAYERS; clientIdx++)
	{
		if (curTime >= Blitz_MoveReviveMarkerAt[clientIdx])
			MoveMarker(clientIdx); // will also reset the timer

		if (curTime >= Blitz_RemoveReviveMarkerAt[clientIdx])
		{	
			RemoveReanimator(clientIdx); // will also reset the timer
		}
		else if (Blitz_RemoveReviveMarkerAt[clientIdx] != FAR_FUTURE)
		{
			if (IsBlitzkrieg[clientIdx] && !IsValidClient(clientIdx, true) || GetClientTeam(clientIdx) == FF2_GetBossTeam() || GetClientTeam(clientIdx) < 2)
			{
				RemoveReanimator(clientIdx);
			}
			else if (reviveMarker[clientIdx] == INVALID_ENTREF) // something weird happened
				DropReanimator(clientIdx);
		}
			
		// everything below requires the player to be alive
		if (!IsValidClient(clientIdx, true))
			continue;
		
		if ((GetEntityFlags(clientIdx) & FL_DUCKING) == 0)
			GetEntPropVector(clientIdx, Prop_Send, "m_vecOrigin", Blitz_LastPlayerPos[clientIdx]);
			
		if (curTime >= Blitz_ReverifyWeaponsAt[clientIdx])
		{
			Blitz_ReverifyWeaponsAt[clientIdx] = FAR_FUTURE;
			//TF2_RegeneratePlayer(clientIdx);
			PlayerHelpPanel(clientIdx);
			CheckWeapons(clientIdx, true);
			HealPlayer(clientIdx);
		}

		if (curTime >= Blitz_VerifyMedigunAt[clientIdx])
		{
			Blitz_VerifyMedigunAt[clientIdx] = FAR_FUTURE;
			new medigun = GetPlayerWeaponSlot(clientIdx, TFWeaponSlot_Secondary);
			if (IsValidEntity(medigun) && IsInstanceOf(medigun, "tf_weapon_medigun"))
			{
				new Float:charge = GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel");
				if (charge < 0.4)
					SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", charge + 0.4);
			}
		}
	}
}

/**
 * Blitzkrieg Misc Overrides
 */
public Action:OnStomp(attacker, victim, &Float:damageMultiplier, &Float:damageBonus, &Float:JumpPower)
{
	// disable goombas entirely in a water arena
	if (BMO_ActiveThisRound && RoundInProgress)
	{
		if (BMO_Flags & BMO_FLAG_NO_GOOMBAS)
			return Plugin_Handled;
			
		if (BMO_FlatGoombaDamage != 0.0 || BMO_GoombaDamageFactor != 0.0)
		{
			damageBonus = BMO_FlatGoombaDamage;
			damageMultiplier = BMO_GoombaDamageFactor;
			return Plugin_Changed;
		}
	}
		
	return Plugin_Continue;
}
 
public Action:BMO_OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3], damagecustom)
{
	if (TF2_GetPlayerClass(victim) == TFClass_DemoMan)
	{
		if (BMO_Flags & BMO_FLAG_NO_DEMOKNIGHT_FALL_DAMAGE)
		{
			if (attacker == 0 && inflictor == 0 && (damagetype & DMG_FALL) != 0)
			{
				new shield = GetPlayerWeaponSlot(victim, TFWeaponSlot_Secondary);
				
				// no stickybomb launcher = must be a demoknight. shields don't appear in weapon slot.
				if (!IsValidEntity(shield))
					return Plugin_Handled; // cancel fall damage
			}
		}
	}

	if (BMO_Flags & BMO_FLAG_VSP_SWORD_WORKAROUND)
	{
		if (IsValidClient(attacker, true) && TF2_GetPlayerClass(attacker) == TFClass_DemoMan)
		{
			if (IsValidEntity(weapon) && IsInstanceOf(weapon, "tf_weapon_sword"))
				IncrementHeadCount(attacker);
		}
	}

	if (IsValidClient(attacker, true) && IsBlitzkrieg[attacker])
	{
		new Float:oldDamage = damage;
		if (TF2_IsPlayerInCondition(attacker, COND_RUNE_STRENGTH))
			damage *= BMO_StrengthDamageMultiplier;
		if (damagetype & DMG_CRIT)
			damage *= BMO_CritDamageMultiplier;
			
		if (damage != oldDamage)
			return Plugin_Changed;
	}
	
	return Plugin_Continue;
}
 
public BMO_Tick(Float:curTime)
{
	for (new i = 0; i < MAX_PENDING_ROCKETS; i++)
	{
		if (BMO_PendingRocketEntRefs[i] == INVALID_ENTREF)
			break;

		new rocket = EntRefToEntIndex(BMO_PendingRocketEntRefs[i]);
		if (IsValidEntity(rocket))
		{
			new owner = GetEntPropEnt(rocket, Prop_Send, "m_hOwnerEntity");
			if (IsBlitzkrieg[owner])
			{
				if (BMO_ModelOverrideIdx != -1)
					SetEntProp(rocket, Prop_Send, "m_nModelIndex", BMO_ModelOverrideIdx);
				
				// try teleporting it just a little and maybe the trail won't follow
				// failed, but I may as well log my attempts. also, can't PreThink and Think was worse.
				static Float:rocketPos[3];
				GetEntPropVector(rocket, Prop_Send, "m_vecOrigin", rocketPos);
				rocketPos[2] += 0.01;
				TeleportEntity(rocket, rocketPos, NULL_VECTOR, NULL_VECTOR);
				
				// recolor
				new color = BMO_Recolors[(BMO_CurrentIsBlizkrieg ? ARRAY_IDX_BLITZKRIEG : ARRAY_IDX_NORMAL)][BMO_CurrentRocketType];
				if (color != 0x000000 && color != 0xffffff)
				{
					SetEntityRenderMode(rocket, RENDER_TRANSCOLOR);
					SetEntityRenderColor(rocket, GetR(color), GetG(color), GetB(color), 255);
				}
				
				// remove crit from rocket if no random crits set
				if (BMO_Flags & BMO_FLAG_NO_RANDOM_CRITS)
				{
					if (!TF2_IsPlayerInCondition(owner, BLITZKRIEG_COND_CRIT))
						SetEntProp(rocket, Prop_Send, "m_bCritical", 0);
				}
			}
		}

		BMO_PendingRocketEntRefs[i] = INVALID_ENTREF;
	}
	
	if (BMO_Flags & BMO_FLAG_DISPLAY_TIMER_HUD)
	{
		if (curTime >= BMO_UpdateTimerHUDAt && BMO_RoundEndsAt > curTime)
		{
			new seconds = RoundFloat(BMO_RoundEndsAt - curTime);
			new minutes = seconds / 60;
			seconds %= 60;
		
			for (new clientIdx = 1; clientIdx < MAX_PLAYERS; clientIdx++)
			{
				if (IsClientInGame(clientIdx) && GetClientTeam(clientIdx) >= 2)
				{
					SetHudTextParams(0.03, 0.018, 0.15, 255, 255, 255, 192);
					if (seconds < 10)
						ShowHudText(clientIdx, -1, "%d:0%d", minutes, seconds);
					else
						ShowHudText(clientIdx, -1, "%d:%d", minutes, seconds);
				}
			}
			
			BMO_UpdateTimerHUDAt = curTime + 0.1;
		}
	}
	
	if (curTime >= BMO_RoundEndsAt)
	{
		ForceTeamWin(0);
	}
}

ForceTeamWin(team)
{
	new entity=FindEntityByClassname(-1, "team_control_point_master");
	if(entity==-1)
	{
		entity=CreateEntityByName("team_control_point_master");
		DispatchSpawn(entity);
		AcceptEntityInput(entity, "Enable");
	}
	SetVariantInt(team);
	AcceptEntityInput(entity, "SetWinner");
}

public BMO_OnEntityCreated(entity, const String:classname[])
{
	if (!strcmp(classname, "tf_projectile_rocket"))
	{
		for (new i = 0; i < MAX_PENDING_ROCKETS; i++)
		{
			if (BMO_PendingRocketEntRefs[i] == INVALID_ENTREF)
			{
				BMO_PendingRocketEntRefs[i] = EntIndexToEntRef(entity);
				break;
			}
		}
	}
}

/**
 * sarysa's point teleport replacement
 *
 * Written now because I'm fed up with the bugs with otokiru's.
 */
new SPT_Player;
public bool:SPT_TracePlayersAndBuildings(entity, contentsMask)
{
	if (IsValidClient(entity, true) && GetClientTeam(entity) != GetClientTeam(SPT_Player))
		return true;
	else if (IsValidClient(entity, true))
		return false;
		
	return IsValidEntity(entity);
}

public bool:SPT_TraceWallsOnly(entity, contentsMask)
{
	return false;
}
 
public bool:SPT_TryTeleport(clientIdx)
{
	new Float:sizeMultiplier = GetEntPropFloat(clientIdx, Prop_Send, "m_flModelScale");
	static Float:startPos[3];
	static Float:endPos[3];
	static Float:testPos[3];
	static Float:eyeAngles[3];
	GetClientEyePosition(clientIdx, startPos);
	GetClientEyeAngles(clientIdx, eyeAngles);
	SPT_Player = clientIdx;
	TR_TraceRayFilter(startPos, eyeAngles, MASK_PLAYERSOLID, RayType_Infinite, SPT_TracePlayersAndBuildings);
	TR_GetEndPosition(endPos);
	
	// don't even try if the distance is less than 82
	new Float:distance = GetVectorDistance(startPos, endPos);
	if (distance < 82.0)
	{
		Nope(clientIdx);
		return false;
	}
		
	if (distance > SPT_MaxDistance[clientIdx])
		constrainDistance(startPos, endPos, distance, SPT_MaxDistance[clientIdx]);
	else // shave just a tiny bit off the end position so our point isn't directly on top of a wall
		constrainDistance(startPos, endPos, distance, distance - 1.0);
	
	// now for the tests. I go 1 extra on the standard mins/maxs on purpose.
	new bool:found = false;
	for (new x = 0; x < 3; x++)
	{
		if (found)
			break;
	
		new Float:xOffset;
		if (x == 0)
			xOffset = 0.0;
		else if (x == 1)
			xOffset = 12.5 * sizeMultiplier;
		else
			xOffset = 25.0 * sizeMultiplier;
		
		if (endPos[0] < startPos[0])
			testPos[0] = endPos[0] + xOffset;
		else if (endPos[0] > startPos[0])
			testPos[0] = endPos[0] - xOffset;
		else if (xOffset != 0.0)
			break; // super rare but not impossible, no sense wasting on unnecessary tests
	
		for (new y = 0; y < 3; y++)
		{
			if (found)
				break;

			new Float:yOffset;
			if (y == 0)
				yOffset = 0.0;
			else if (y == 1)
				yOffset = 12.5 * sizeMultiplier;
			else
				yOffset = 25.0 * sizeMultiplier;

			if (endPos[1] < startPos[1])
				testPos[1] = endPos[1] + yOffset;
			else if (endPos[1] > startPos[1])
				testPos[1] = endPos[1] - yOffset;
			else if (yOffset != 0.0)
				break; // super rare but not impossible, no sense wasting on unnecessary tests
		
			for (new z = 0; z < 3; z++)
			{
				if (found)
					break;

				new Float:zOffset;
				if (z == 0)
					zOffset = 0.0;
				else if (z == 1)
					zOffset = 41.5 * sizeMultiplier;
				else
					zOffset = 83.0 * sizeMultiplier;

				if (endPos[2] < startPos[2])
					testPos[2] = endPos[2] + zOffset;
				else if (endPos[2] > startPos[2])
					testPos[2] = endPos[2] - zOffset;
				else if (zOffset != 0.0)
					break; // super rare but not impossible, no sense wasting on unnecessary tests

				// before we test this position, ensure it has line of sight from the point our player looked from
				// this ensures the player can't teleport through walls
				static Float:tmpPos[3];
				TR_TraceRayFilter(endPos, testPos, MASK_PLAYERSOLID, RayType_EndPoint, SPT_TraceWallsOnly);
				TR_GetEndPosition(tmpPos);
				if (testPos[0] != tmpPos[0] || testPos[1] != tmpPos[1] || testPos[2] != tmpPos[2])
					continue;
				
				// now we do our very expensive test. thankfully there's only 27 of these calls, worst case scenario.
				if (PRINT_DEBUG_SPAM)
					PrintToServer("testing %f, %f, %f", testPos[0], testPos[1], testPos[2]);
				found = IsSpotSafe(clientIdx, testPos, sizeMultiplier);
			}
		}
	}
	
	if (!found)
	{
		Nope(clientIdx);
		return false;
	}
		
	if (SPT_PreserveMomentum[clientIdx])
		TeleportEntity(clientIdx, testPos, NULL_VECTOR, NULL_VECTOR);
	else
		TeleportEntity(clientIdx, testPos, NULL_VECTOR, Float:{0.0, 0.0, 0.0});
		
	// particles and sound
	if (strlen(SPT_UseSound) > 3)
	{
		EmitSoundToAll(SPT_UseSound);
		EmitSoundToAll(SPT_UseSound);
	}
	
	if (!IsEmptyString(SPT_OldLocationParticleEffect))
		ParticleEffectAt(startPos, SPT_OldLocationParticleEffect);
	if (!IsEmptyString(SPT_NewLocationParticleEffect))
		ParticleEffectAt(testPos, SPT_NewLocationParticleEffect);
		
	// empty clip?
	if (SPT_EmptyClipOnTeleport[clientIdx])
	{
		new weapon = GetEntPropEnt(clientIdx, Prop_Send, "m_hActiveWeapon");
		if (IsValidEntity(weapon))
		{
			SetEntProp(weapon, Prop_Send, "m_iClip1", 0);
			SetEntProp(weapon, Prop_Send, "m_iClip2", 0);
		}
	}
	
	// attack delay?
	if (SPT_AttackDelayOnTeleport[clientIdx] > 0.0)
	{
		for (new i = 0; i <= 2; i++)
		{
			new weapon = GetPlayerWeaponSlot(clientIdx, i);
			if (IsValidEntity(weapon))
				SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + SPT_AttackDelayOnTeleport[clientIdx]);
		}
	}
		
	return true;
}

public Rage_sarysaPointTeleport(bossIdx)
{
	new clientIdx = GetClientOfUserId(FF2_GetBossUserId(bossIdx));
	if (!IsValidClient(clientIdx, true) || !SPT_CanUse[clientIdx])
		return;
	
	if (SPT_AddCharges[clientIdx])
		SPT_ChargesRemaining[clientIdx] += SPT_NumSkills[clientIdx];
	else
		SPT_ChargesRemaining[clientIdx] = SPT_NumSkills[clientIdx];
}

/**
 * OnGameFrame(), OnPlayerRunCmd(), with special guest star OnEntityCreated()
 */
public OnGameFrame()
{
	Blitz_HUDSyncTick(GetEngineTime());
	
	if (!RoundInProgress)
		return;
		
	if (BMO_ActiveThisRound)
		BMO_Tick(GetEngineTime());
		
	if (blitzisboss)
		Blitz_Tick(GetEngineTime());
}

public Action:OnPlayerRunCmd(clientIdx, &buttons, &impulse, Float:vel[3], Float:angles[3], &weaponIdx)
{
	if (!RoundInProgress)
		return Plugin_Continue;
		
	if (SPT_ActiveThisRound && SPT_CanUse[clientIdx])
	{
		new Float:curTime = GetEngineTime();
	
		new bool:countChanged = false;
		new bool:keyDown = (buttons & SPT_KeyToUse[clientIdx]) != 0;
		if (keyDown && !SPT_KeyDown[clientIdx])
		{
			if (SPT_ChargesRemaining[clientIdx] > 0 && SPT_TryTeleport(clientIdx))
			{
				SPT_ChargesRemaining[clientIdx]--;
				countChanged = true;
			}
		}
		SPT_KeyDown[clientIdx] = keyDown;
		
		// HUD message (center text, same as original)
		if (countChanged || curTime >= SPT_NextCenterTextAt[clientIdx])
		{
			if (SPT_ChargesRemaining[clientIdx] > 0)
				PrintHintText(clientIdx, SPT_CenterText, SPT_ChargesRemaining[clientIdx]);
			else if (countChanged)
				PrintHintText(clientIdx, ""); // clear the outdated message
				
			SPT_NextCenterTextAt[clientIdx] = curTime + SPT_CENTER_TEXT_INTERVAL;
		}
	}
	
	return Plugin_Continue;
}

public OnEntityCreated(entity, const String:classname[])
{
	if(WeaponMode)
	{
		if (!strcmp(classname, "tf_projectile_rocket"))
		{
			SDKHook(entity, SDKHook_Spawn, Hook_OnRocketSpawn);
		}
	}
	if (BMO_ActiveThisRound)
	{
		BMO_OnEntityCreated(entity, classname);
	}
	
	Blitz_SetRocketBounce(entity, classname);
}

public Hook_OnRocketSpawn(entity)
{
	new owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
	if(owner > 0 && owner <= MaxClients && IsBoss(owner))
	{	
		rocketCount++;
	}
}

public Blitz_SetRocketBounce(entity, const String: classname[])
{
	if(!blitzisboss)
		return;
		
	if (!strcmp(classname, "tf_projectile_rocket"))
	{
		rBounce[entity] = 0;
		if(rMaxBounces == -1)
			rMaxBounces = GetRandomInt(0,15); // RNG :3
		rMaxBounceCount[entity] = rMaxBounces;
		SDKHook(entity, SDKHook_StartTouch, OnStartTouch);
	}
}

public Action:RemoveEntity(Handle:timer, any:entid)
{
	new entity = EntRefToEntIndex(entid);
	if (IsValidEdict(entity) && entity > MaxClients)
		AcceptEntityInput(entity, "Kill");
}


/**
 * The below is sarysa's safe location code (which I also use for resizing)
 *
 * Making it public now since I really hate the bugs with Otokiru teleport.
 */
new bool:ResizeTraceFailed;
new ResizeMyTeam;
public bool:Resize_TracePlayersAndBuildings(entity, contentsMask)
{
	if (IsValidClient(entity,true))
	{
		if (GetClientTeam(entity) != ResizeMyTeam)
		{
			ResizeTraceFailed = true;
			if (PRINT_DEBUG_SPAM)
				PrintToServer("[sarysamods8] Player %d stopped trace.", entity);
		}
	}
	else if (IsValidEntity(entity))
	{
		static String:classname[MAX_ENTITY_CLASSNAME_LENGTH];
		GetEntityClassname(entity, classname, sizeof(classname));
		if ((strcmp(classname, "obj_sentrygun") == 0) || (strcmp(classname, "obj_dispenser") == 0) || (strcmp(classname, "obj_teleporter") == 0)
			|| (strcmp(classname, "prop_dynamic") == 0) || (strcmp(classname, "func_physbox") == 0) || (strcmp(classname, "func_breakable") == 0))
		{
			ResizeTraceFailed = true;
			if (PRINT_DEBUG_SPAM)
				PrintToServer("[sarysamods8] %s %d stopped trace.", classname, entity);
		}
		else
		{
			if (PRINT_DEBUG_SPAM)
				PrintToServer("[sarysamods8] Neutral entity %d/%s crossed by trace.", entity, classname);
		}
	}
	else
	{
		if (PRINT_DEBUG_SPAM)
			PrintToServer("[sarysamods8] Trace picked up Santa Claus, I guess? entity=%d", entity);
	}

	return false;
}

bool:Resize_OneTrace(const Float:startPos[3], const Float:endPos[3])
{
	static Float:result[3];
	TR_TraceRayFilter(startPos, endPos, MASK_PLAYERSOLID, RayType_EndPoint, Resize_TracePlayersAndBuildings);
	if (ResizeTraceFailed)
	{
		if (PRINT_DEBUG_SPAM)
			PrintToServer("[sarysamods8] Could not resize player. Players are in the way. Offsets: %f, %f, %f", startPos[0] - endPos[0], startPos[1] - endPos[1], startPos[2] - endPos[2]);
		return false;
	}
	TR_GetEndPosition(result);
	if (endPos[0] != result[0] || endPos[1] != result[1] || endPos[2] != result[2])
	{
		if (PRINT_DEBUG_SPAM)
			PrintToServer("[sarysamods8] Could not resize player. Hit a wall. Offsets: %f, %f, %f", startPos[0] - endPos[0], startPos[1] - endPos[1], startPos[2] - endPos[2]);
		return false;
	}
	
	return true;
}

// the purpose of this method is to first trace outward, upward, and then back in.
bool:Resize_TestResizeOffset(const Float:bossOrigin[3], Float:xOffset, Float:yOffset, Float:zOffset)
{
	static Float:tmpOrigin[3];
	tmpOrigin[0] = bossOrigin[0];
	tmpOrigin[1] = bossOrigin[1];
	tmpOrigin[2] = bossOrigin[2];
	static Float:targetOrigin[3];
	targetOrigin[0] = bossOrigin[0] + xOffset;
	targetOrigin[1] = bossOrigin[1] + yOffset;
	targetOrigin[2] = bossOrigin[2];
	
	if (!(xOffset == 0.0 && yOffset == 0.0))
		if (!Resize_OneTrace(tmpOrigin, targetOrigin))
			return false;
		
	tmpOrigin[0] = targetOrigin[0];
	tmpOrigin[1] = targetOrigin[1];
	tmpOrigin[2] = targetOrigin[2] + zOffset;

	if (!Resize_OneTrace(targetOrigin, tmpOrigin))
		return false;
		
	targetOrigin[0] = bossOrigin[0];
	targetOrigin[1] = bossOrigin[1];
	targetOrigin[2] = bossOrigin[2] + zOffset;
		
	if (!(xOffset == 0.0 && yOffset == 0.0))
		if (!Resize_OneTrace(tmpOrigin, targetOrigin))
			return false;
		
	return true;
}

bool:Resize_TestSquare(const Float:bossOrigin[3], Float:xmin, Float:xmax, Float:ymin, Float:ymax, Float:zOffset)
{
	static Float:pointA[3];
	static Float:pointB[3];
	for (new phase = 0; phase <= 7; phase++)
	{
		// going counterclockwise
		if (phase == 0)
		{
			pointA[0] = bossOrigin[0] + 0.0;
			pointA[1] = bossOrigin[1] + ymax;
			pointB[0] = bossOrigin[0] + xmax;
			pointB[1] = bossOrigin[1] + ymax;
		}
		else if (phase == 1)
		{
			pointA[0] = bossOrigin[0] + xmax;
			pointA[1] = bossOrigin[1] + ymax;
			pointB[0] = bossOrigin[0] + xmax;
			pointB[1] = bossOrigin[1] + 0.0;
		}
		else if (phase == 2)
		{
			pointA[0] = bossOrigin[0] + xmax;
			pointA[1] = bossOrigin[1] + 0.0;
			pointB[0] = bossOrigin[0] + xmax;
			pointB[1] = bossOrigin[1] + ymin;
		}
		else if (phase == 3)
		{
			pointA[0] = bossOrigin[0] + xmax;
			pointA[1] = bossOrigin[1] + ymin;
			pointB[0] = bossOrigin[0] + 0.0;
			pointB[1] = bossOrigin[1] + ymin;
		}
		else if (phase == 4)
		{
			pointA[0] = bossOrigin[0] + 0.0;
			pointA[1] = bossOrigin[1] + ymin;
			pointB[0] = bossOrigin[0] + xmin;
			pointB[1] = bossOrigin[1] + ymin;
		}
		else if (phase == 5)
		{
			pointA[0] = bossOrigin[0] + xmin;
			pointA[1] = bossOrigin[1] + ymin;
			pointB[0] = bossOrigin[0] + xmin;
			pointB[1] = bossOrigin[1] + 0.0;
		}
		else if (phase == 6)
		{
			pointA[0] = bossOrigin[0] + xmin;
			pointA[1] = bossOrigin[1] + 0.0;
			pointB[0] = bossOrigin[0] + xmin;
			pointB[1] = bossOrigin[1] + ymax;
		}
		else if (phase == 7)
		{
			pointA[0] = bossOrigin[0] + xmin;
			pointA[1] = bossOrigin[1] + ymax;
			pointB[0] = bossOrigin[0] + 0.0;
			pointB[1] = bossOrigin[1] + ymax;
		}

		for (new shouldZ = 0; shouldZ <= 1; shouldZ++)
		{
			pointA[2] = pointB[2] = shouldZ == 0 ? bossOrigin[2] : (bossOrigin[2] + zOffset);
			if (!Resize_OneTrace(pointA, pointB))
				return false;
		}
	}
		
	return true;
}

public bool:IsSpotSafe(clientIdx, Float:playerPos[3], Float:sizeMultiplier)
{
	ResizeTraceFailed = false;
	ResizeMyTeam = GetClientTeam(clientIdx);
	static Float:mins[3];
	static Float:maxs[3];
	mins[0] = -24.0 * sizeMultiplier;
	mins[1] = -24.0 * sizeMultiplier;
	mins[2] = 0.0;
	maxs[0] = 24.0 * sizeMultiplier;
	maxs[1] = 24.0 * sizeMultiplier;
	maxs[2] = 82.0 * sizeMultiplier;

	// the eight 45 degree angles and center, which only checks the z offset
	if (!Resize_TestResizeOffset(playerPos, mins[0], mins[1], maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, mins[0], 0.0, maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, mins[0], maxs[1], maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, 0.0, mins[1], maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, 0.0, 0.0, maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, 0.0, maxs[1], maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, maxs[0], mins[1], maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, maxs[0], 0.0, maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, maxs[0], maxs[1], maxs[2])) return false;

	// 22.5 angles as well, for paranoia sake
	if (!Resize_TestResizeOffset(playerPos, mins[0], mins[1] * 0.5, maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, mins[0], maxs[1] * 0.5, maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, maxs[0], mins[1] * 0.5, maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, maxs[0], maxs[1] * 0.5, maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, mins[0] * 0.5, mins[1], maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, maxs[0] * 0.5, mins[1], maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, mins[0] * 0.5, maxs[1], maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, maxs[0] * 0.5, maxs[1], maxs[2])) return false;

	// four square tests
	if (!Resize_TestSquare(playerPos, mins[0], maxs[0], mins[1], maxs[1], maxs[2])) return false;
	if (!Resize_TestSquare(playerPos, mins[0] * 0.75, maxs[0] * 0.75, mins[1] * 0.75, maxs[1] * 0.75, maxs[2])) return false;
	if (!Resize_TestSquare(playerPos, mins[0] * 0.5, maxs[0] * 0.5, mins[1] * 0.5, maxs[1] * 0.5, maxs[2])) return false;
	if (!Resize_TestSquare(playerPos, mins[0] * 0.25, maxs[0] * 0.25, mins[1] * 0.25, maxs[1] * 0.25, maxs[2])) return false;
	
	return true;
}

public Action:OnStartTouch(entity, other)
{
	if (other > 0 && other <= MaxClients)
		return Plugin_Continue;
	if(!blitzisboss)
		return Plugin_Continue;
	if(!IsBoss(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity")))
		return Plugin_Continue;
	if (rBounce[entity] >= rMaxBounceCount[entity])
		return Plugin_Continue;
	SDKHook(entity, SDKHook_Touch, OnTouch);
	return Plugin_Handled;
}

public Action:OnTouch(entity, other)
{
	decl Float:vOrigin[3];
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", vOrigin);
	
	decl Float:vAngles[3];
	GetEntPropVector(entity, Prop_Data, "m_angRotation", vAngles);
	
	decl Float:vVelocity[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", vVelocity);
	
	new Handle:trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TEF_ExcludeEntity, entity);
	
	if(!TR_DidHit(trace))
	{
		CloseHandle(trace);
		return Plugin_Continue;
	}
	
	decl Float:vNormal[3];
	TR_GetPlaneNormal(trace, vNormal);

	CloseHandle(trace);
	
	new Float:dotProduct = GetVectorDotProduct(vNormal, vVelocity);
	
	ScaleVector(vNormal, dotProduct);
	ScaleVector(vNormal, 2.0);
	
	decl Float:vBounceVec[3];
	SubtractVectors(vVelocity, vNormal, vBounceVec);
	
	decl Float:vNewAngles[3];
	GetVectorAngles(vBounceVec, vNewAngles);
	
	TeleportEntity(entity, NULL_VECTOR, vNewAngles, vBounceVec);

	rBounce[entity]++;
	
	SDKUnhook(entity, SDKHook_Touch, OnTouch);
	return Plugin_Handled;
}

public bool:TEF_ExcludeEntity(entity, contentsMask, any:data)
{
	return (entity != data);
}

public Action:TF2_CalcIsAttackCritical(client, weapon, String:weaponname[], &bool:result)
{
	if (RoundInProgress && UseCustomWeapons && IsValidEntity(weapon) && !IsBoss(client))
	{
		if (!StrContains(weaponname, "tf_weapon_club"))
		{
			SickleClimbWalls(client, weapon);
		}
	}
	return Plugin_Continue;
}

public SickleClimbWalls(client, weapon)	 //Credit to Mecha the Slag
{
	if (!IsValidClient(client) || (GetClientHealth(client)<=15) )return;

	new String:classname[64];
	new Float:vecClientEyePos[3];
	new Float:vecClientEyeAng[3];
	GetClientEyePosition(client, vecClientEyePos);   // Get the position of the player's eyes
	GetClientEyeAngles(client, vecClientEyeAng);	   // Get the angle the player is looking

	//Check for colliding entities
	TR_TraceRayFilter(vecClientEyePos, vecClientEyeAng, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitSelf, client);

	if (!TR_DidHit(INVALID_HANDLE)) return;

	new TRIndex = TR_GetEntityIndex(INVALID_HANDLE);
	GetEdictClassname(TRIndex, classname, sizeof(classname));
	if (!StrEqual(classname, "worldspawn")) return;

	new Float:fNormal[3];
	TR_GetPlaneNormal(INVALID_HANDLE, fNormal);
	GetVectorAngles(fNormal, fNormal);

	if (fNormal[0] >= 30.0 && fNormal[0] <= 330.0) return;
	if (fNormal[0] <= -30.0) return;

	new Float:pos[3];
	TR_GetEndPosition(pos);
	new Float:distance = GetVectorDistance(vecClientEyePos, pos);

	if (distance >= 100.0) return;

	new Float:fVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);

	fVelocity[2] = 600.0;

	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity);

	SDKHooks_TakeDamage(client, client, client, 15.0, DMG_CLUB, GetPlayerWeaponSlot(client, TFWeaponSlot_Melee));

	if (!IsBoss(client)) ClientCommand(client, "playgamesound \"%s\"", "player\\taunt_clip_spin.wav");
	
	if(!IsValidEntity(weapon) || (weapon <= MaxClients))
		return;
		
	SetNextAttack(weapon, 1.56);
}

public bool:TraceRayDontHitSelf(entity, mask, any:data)
{
	return (entity != data);
}

/***************************************************************************************************************
 *                                      STOCKS USED THROUGHOUT THIS SUBPLUGIN                                  *
 ***************************************************************************************************************/
#pragma newdecls required

// To be used in a future update....
/*stock int FindBloodRider()
{
	bool found=false;
	int brIdx=0, client=0;
	for(int clientIdx=1;clientIdx<=MaxClients;clientIdx++)
	{
		if(found) break;
		if(!IsValidClient(clientIdx, false)) continue;
		int bossIdx=FF2_GetBossIndex(clientIdx);
		if(bossIdx==-1)	continue;
		if(FF2_HasAbility(bossIdx, "M7_bloodrider", "bloodrider_config"))
		{
			brIdx=GetClientOfUserId(FF2_GetBossUserId(bossIdx));
			if(IsValidClient(brIdx))
			{
				client=brIdx;
				found=true;
			}
		}
	}
	return client;
}*/

stock void ClassResponses(int client)
{
	if(IsValidClient(client, true) && GetClientTeam(client)!=FF2_GetBossTeam())
	{
		char Reaction[PLATFORM_MAX_PATH];
		switch(TF2_GetPlayerClass(client))
		{
			case TFClass_Scout: // Scout
			{
				strcopy(Reaction, PLATFORM_MAX_PATH, ScoutReact[GetRandomInt(0, sizeof(ScoutReact)-1)]);
				EmitSoundToAll(Reaction, client);
			}
			case TFClass_Soldier: // Soldier
			{
				strcopy(Reaction, PLATFORM_MAX_PATH, SoldierReact[GetRandomInt(0, sizeof(SoldierReact)-1)]);
				EmitSoundToAll(Reaction, client);
			}
			case TFClass_Pyro: // Pyro
			{
				strcopy(Reaction, PLATFORM_MAX_PATH, PyroReact[GetRandomInt(0, sizeof(PyroReact)-1)]);
				EmitSoundToAll(Reaction, client);
			}
			case TFClass_DemoMan: // DemoMan
			{
				strcopy(Reaction, PLATFORM_MAX_PATH, DemoReact[GetRandomInt(0, sizeof(DemoReact)-1)]);
				EmitSoundToAll(Reaction, client);
			}
			case TFClass_Heavy: // Heavy
			{
				strcopy(Reaction, PLATFORM_MAX_PATH, HeavyReact[GetRandomInt(0, sizeof(HeavyReact)-1)]);
				EmitSoundToAll(Reaction, client);
			}
			case TFClass_Engineer: // Engineer
			{
				strcopy(Reaction, PLATFORM_MAX_PATH, EngyReact[GetRandomInt(0, sizeof(EngyReact)-1)]);
				EmitSoundToAll(Reaction, client);
			}	
			case TFClass_Medic: // Medic
			{
				strcopy(Reaction, PLATFORM_MAX_PATH, MedicReact[GetRandomInt(0, sizeof(MedicReact)-1)]);
				EmitSoundToAll(Reaction, client);
			}
			case TFClass_Sniper: // Sniper
			{
				strcopy(Reaction, PLATFORM_MAX_PATH, SniperReact[GetRandomInt(0, sizeof(SniperReact)-1)]);
				EmitSoundToAll(Reaction, client);
			}
			case TFClass_Spy: // Spy
			{
				strcopy(Reaction, PLATFORM_MAX_PATH, SpyReact[GetRandomInt(0, sizeof(SpyReact)-1)]);
				EmitSoundToAll(Reaction, client);
			}
		}
	}
}

stock void PrintWeaponInfo(int client, char[] info, bool showInfo)
{
	if(showInfo)
	{
		CPrintToChat(client, info);
	}
}

stock void DropReanimator(int client) 
{
	int clientTeam = GetClientTeam(client);
	int marker = CreateEntityByName("entity_revive_marker");
	if (marker != -1)
	{
		SetEntPropEnt(marker, Prop_Send, "m_hOwner", client); // client index 
		SetEntProp(marker, Prop_Send, "m_nSolidType", 2); 
		SetEntProp(marker, Prop_Send, "m_usSolidFlags", 8); 
		SetEntProp(marker, Prop_Send, "m_fEffects", 16); 	
		SetEntProp(marker, Prop_Send, "m_iTeamNum", clientTeam); // client team 
		SetEntProp(marker, Prop_Send, "m_CollisionGroup", 1); 
		SetEntProp(marker, Prop_Send, "m_bSimulatedEveryTick", 1); 
		SetEntProp(marker, Prop_Send, "m_nBody", (view_as<int>(TF2_GetPlayerClass(client))) - 1); 
		SetEntProp(marker, Prop_Send, "m_nSequence", 1); 
		SetEntPropFloat(marker, Prop_Send, "m_flPlaybackRate", 1.0);  
		SetEntProp(marker, Prop_Data, "m_iInitialTeamNum", clientTeam);
		SetEntDataEnt2(client, FindSendPropInfo("CTFPlayer", "m_nForcedSkin")+4, marker);
		if(GetClientTeam(client) == 3)
			SetEntityRenderColor(marker, 0, 0, 255); // make the BLU Revive Marker distinguishable from the red one
		DispatchSpawn(marker);
		reviveMarker[client] = EntIndexToEntRef(marker);
		Blitz_MoveReviveMarkerAt[client] = GetEngineTime() + 0.01;
		Blitz_RemoveReviveMarkerAt[client] = GetEngineTime() + ReviveMarkerDecayTime;
		
		if (PRINT_DEBUG_SPAM)
			PrintToServer("[%d] Marker created at %f", client, GetEngineTime());
	} 
}

stock void RemoveReanimator(int client)
{
	if (reviveMarker[client] != INVALID_ENTREF && reviveMarker[client] != 0) // second call needed due to slim possibility of it being uninitialized, thus the world
	{
		currentTeam[client] = GetClientTeam(client);
		ChangeClass[client] = false;
		int marker = EntRefToEntIndex(reviveMarker[client]);
		if (IsValidEntity(marker) && marker >= MAX_PLAYERS)
			AcceptEntityInput(marker, "Kill");
		
		if (PRINT_DEBUG_SPAM)
			PrintToServer("[%d] Marker destroyed at %f", client, GetEngineTime());
	}
	Blitz_RemoveReviveMarkerAt[client] = FAR_FUTURE;
	Blitz_MoveReviveMarkerAt[client] = FAR_FUTURE;
	reviveMarker[client] = INVALID_ENTREF;
}

stock void DropReviveMarker(int client)
{
	switch(MaxClientRevives)
	{	
		case -1: // Unlimited revives
		{
			DropReanimator(client);	
		}
						
		case 0: // Revive Markers Disabled
		{
			// Noop
		}
							
		default: // Has a limit of number of times player can be revived
		{
			static int revivecount[MAXPLAYERS+1] = 0;
			if(revivecount[client] >= MaxClientRevives)
			{
			
				SetHudTextParams(-1.0, 0.67, 5.0, 255, 0, 0, 255);
				FF2_ShowHudText(client, -1, "You have exceeded the amount of times you can be revived");
				revivecount[client] = 0;
			}
			else
			{
				DropReanimator(client);
				revivecount[client]++;
			}
		}
	}
}

stock bool IsInstanceOf(int entity, const char[] desiredClassname)
{
	static char classname[MAX_ENTITY_CLASSNAME_LENGTH];
	GetEntityClassname(entity, classname, MAX_ENTITY_CLASSNAME_LENGTH);
	return strcmp(classname, desiredClassname) == 0;
}

stock int ReadHexOrDecInt(char[] hexOrDecString)
{
	if (StrContains(hexOrDecString, "0x") == 0)
	{
		int result = 0;
		for (int i = 2; i < 10 && hexOrDecString[i] != 0; i++)
		{
			result = result<<4;
				
			if (hexOrDecString[i] >= '0' && hexOrDecString[i] <= '9')
				result += hexOrDecString[i] - '0';
			else if (hexOrDecString[i] >= 'a' && hexOrDecString[i] <= 'f')
				result += hexOrDecString[i] - 'a' + 10;
			else if (hexOrDecString[i] >= 'A' && hexOrDecString[i] <= 'F')
				result += hexOrDecString[i] - 'A' + 10;
		}
		return result;
	}
	else
		return StringToInt(hexOrDecString);
}

stock int ReadHexOrDecString(int bossIdx, const char[] ability_name, int argIdx)
{
	static char hexOrDecString[HEX_OR_DEC_STRING_LENGTH];
	FF2_GetAbilityArgumentString(bossIdx, this_plugin_name, ability_name, argIdx, hexOrDecString, HEX_OR_DEC_STRING_LENGTH);
	return ReadHexOrDecInt(hexOrDecString);
}

stock int ReadModelToInt(int bossIdx, const char[] ability_name, int argInt)
{
	static char modelFile[MAX_MODEL_FILE_LENGTH];
	FF2_GetAbilityArgumentString(bossIdx, this_plugin_name, ability_name, argInt, modelFile, MAX_MODEL_FILE_LENGTH);
	
	if(modelFile[0]=='\0' && FileExists(BLITZ_ROCKET, true))
	{
		modelFile=BLITZ_ROCKET;
	}
	
	if (strlen(modelFile) > 3)
		return PrecacheModel(modelFile);
	return -1;
}

stock int GetA(int c) { return abs(c>>24); }
stock int GetR(int c) { return abs((c>>16)&0xff); }
stock int GetG(int c) { return abs((c>>8 )&0xff); }
stock int GetB(int c) { return abs((c    )&0xff); }

stock int abs(int x)
{
	return x < 0 ? -x : x;
}

stock float fabs(float x)
{
	return x < 0 ? -x : x;
}

stock int min(int n1, int n2)
{
	return n1 < n2 ? n1 : n2;
}

stock float fmin(float n1, float n2)
{
	return n1 < n2 ? n1 : n2;
}

stock int max(int n1, int n2)
{
	return n1 > n2 ? n1 : n2;
}

stock float fmax(float n1, float n2)
{
	return n1 > n2 ? n1 : n2;
}

stock void constrainDistance(const float[] startPoint, float[] endPoint, float distance, float maxDistance)
{
	float constrainFactor = maxDistance / distance;
	endPoint[0] = ((endPoint[0] - startPoint[0]) * constrainFactor) + startPoint[0];
	endPoint[1] = ((endPoint[1] - startPoint[1]) * constrainFactor) + startPoint[1];
	endPoint[2] = ((endPoint[2] - startPoint[2]) * constrainFactor) + startPoint[2];
}

stock void Nope(int clientIdx)
{
	EmitSoundToClient(clientIdx, NOPE_AVI);
}


stock void ReadCenterText(int bossIdx, const char[] ability_name, int argInt, char[] centerText)
{
	FF2_GetAbilityArgumentString(bossIdx, this_plugin_name, ability_name, argInt, centerText, MAX_CENTER_TEXT_LENGTH);
	ReplaceString(centerText, MAX_CENTER_TEXT_LENGTH, "\\n", "\n");
}

stock void ReadSound(int bossIdx, const char[] ability_name, int argInt, char[] soundFile)
{
	FF2_GetAbilityArgumentString(bossIdx, this_plugin_name, ability_name, argInt, soundFile, MAX_SOUND_FILE_LENGTH);
	if (strlen(soundFile) > 3)
		PrecacheSound(soundFile);
}

stock bool IsValidClient(int clientIdx, bool aliveOnly=false)
{
	if (clientIdx<=0 || clientIdx>=MAX_PLAYERS || clientIdx>MaxClients) return false;
	if(aliveOnly) return IsClientInGame(clientIdx) && IsPlayerAlive(clientIdx);
	return IsClientInGame(clientIdx);
}

stock int ParticleEffectAt(float position[3], char[] effectName, float duration = 0.1)
{
	if (IsEmptyString(effectName))
		return -1; // nothing to display
		
	int particle = CreateEntityByName("info_particle_system");
	if (particle != -1)
	{
		TeleportEntity(particle, position, NULL_VECTOR, NULL_VECTOR);
		DispatchKeyValue(particle, "targetname", "tf2particle");
		DispatchKeyValue(particle, "effect_name", effectName);
		DispatchSpawn(particle);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		if (duration > 0.0)
			CreateTimer(duration, RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
	}
	return particle;
}

Handle Blitz_EquipWearable = null;
stock int Wearable_EquipWearable(int client, int wearable)
{
	if(Blitz_EquipWearable==null)
	{
		Handle config=LoadGameConfigFile("equipwearable");
		if(config==null)
		{
			LogError("[FF2] EquipWearable gamedata could not be found; make sure /gamedata/equipwearable.txt exists.");
			return;
		}

		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(config, SDKConf_Virtual, "EquipWearable");
		CloseHandle(config);
		PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
		if((Blitz_EquipWearable=EndPrepSDKCall())==null)
		{
			LogError("[FF2] Couldn't load SDK function (CTFPlayer::EquipWearable). SDK call failed.");
			return;
		}
	}
	SDKCall(Blitz_EquipWearable, client, wearable);
} 

Handle Blitz_IsWearable = null;
stock bool Wearable_IsWearable(int wearable)
{
	if(Blitz_IsWearable==null)	
	{
		Handle config=LoadGameConfigFile("equipwearable");
		if(config==null)
		{
			LogError("[FF2] EquipWearable gamedata could not be found; make sure /gamedata/equipwearable.txt exists.");
			return false;
		}

		StartPrepSDKCall(SDKCall_Entity);
		PrepSDKCall_SetFromConf(config, SDKConf_Virtual, "IsWearable");
		CloseHandle(config);
		PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
		if((Blitz_IsWearable=EndPrepSDKCall())==null)
		{
			LogError("[FF2] Couldn't load SDK function (CTFPlayer::IsWearable). SDK call failed.");
			return false;
		}
	}
	return SDKCall(Blitz_IsWearable, wearable);
}

stock void IncrementHeadCount(int client)
{
	if(!TF2_IsPlayerInCondition(client, TFCond_DemoBuff))
	{
		TF2_AddCondition(client, TFCond_DemoBuff, -1.0);
	}
	int decapitations=GetEntProp(client, Prop_Send, "m_iDecapitations");
	SetEntProp(client, Prop_Send, "m_iDecapitations", decapitations+1);
	int health=GetClientHealth(client);
	SetEntityHealth(client, health+15);
	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.01);
}

stock void SetNextAttack(int weapon, float duration = 0.0)
{
	if (weapon <= MaxClients) return;
	if (!IsValidEntity(weapon)) return;
	float next = GetGameTime() + duration;
	SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", next);
	SetEntPropFloat(weapon, Prop_Send, "m_flNextSecondaryAttack", next);
}
 
stock void RefreshDifficulty(int level)
{
	switch(level)
	{	
		case 1: DifficultyLevelString=BHS_Easy;
		case 2: DifficultyLevelString=BHS_Normal;
		case 3: DifficultyLevelString=BHS_Intermediate;
		case 4: DifficultyLevelString=BHS_Difficult;
		case 5: DifficultyLevelString=BHS_Lunatic;
		case 6: DifficultyLevelString=BHS_Insane;
		case 7: DifficultyLevelString=BHS_Godlike;
		case 8: DifficultyLevelString=BHS_RocketHell;
		case 9: DifficultyLevelString=BHS_TotalBlitzkrieg;
		case 420: 
		{
			DifficultyLevelString="SMOKE W33D ERRYDAY!";
			EmitSoundToAll(SM0K3W33D);
			EmitSoundToAll(SM0K3W33D);
		}
		case 777: 
		{
			DifficultyLevelString="RAVIOLI RAVIOLI";
			EmitSoundToAll(RAVIOLIZ);
			EmitSoundToAll(RAVIOLIZ);
		}
		case 999: 
		{
			DifficultyLevelString="D0NUT ST33L";
			EmitSoundToAll(DONUTZ);
			EmitSoundToAll(DONUTZ);
		}
		case 1337: 
		{
			DifficultyLevelString="LOOMYNARTY";
			if(LoomynartyMusic)
			{
				EmitSoundToAll(L00MYNARTY);
				EmitSoundToAll(L00MYNARTY);
				LoomynartyMusic = false;
			}
		}
		case 9001:
		{
			DifficultyLevelString="OVER 9000!";
			EmitSoundToAll(OVER_9000);
			EmitSoundToAll(OVER_9000);
		}
		default: Format(DifficultyLevelString, sizeof(DifficultyLevelString), BHS_RNGDisplay, level);
	}
}

stock int SpawnWeapon(int client,char[] name, int index, int level, int qual, char[] att)
{
	Handle hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	TF2Items_SetClassname(hWeapon, name);
	TF2Items_SetItemIndex(hWeapon, index);
	TF2Items_SetLevel(hWeapon, level);
	TF2Items_SetQuality(hWeapon, qual);
	char atts[32][32];
	int count = ExplodeString(att, " ; ", atts, 32, 32);
	
	if (count > 0)
	{
		TF2Items_SetNumAttributes(hWeapon, count/2);
		int i2 = 0;
		for (int i = 0; i < count; i+=2)
		{
			TF2Items_SetAttribute(hWeapon, i2, StringToInt(atts[i]), StringToFloat(atts[i+1]));
			i2++;
		}
	}
	else
		TF2Items_SetNumAttributes(hWeapon, 0);
	if (hWeapon==INVALID_HANDLE)
		return -1;
	int entity = TF2Items_GiveNamedItem(client, hWeapon);
	delete hWeapon;
	
	if (StrContains(name, "tf_wearable") != 0)
		EquipPlayerWeapon(client, entity);
	else
		Wearable_EquipWearable(client, entity);
	return entity;
}

stock void SetAmmo(int client, int slot, int ammo)
{
	int weapon = GetPlayerWeaponSlot(client, slot);
	if (IsValidEntity(weapon))
	{
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		SetEntData(client, iAmmoTable+iOffset, ammo, 4, true);
	}
}

stock bool IsBoss(int client)
{
	if(FF2_GetBossIndex(client)==-1) return false;
	return true;
}

/***************************************************************************************************************
 * DEVELOPER INTERFACES - USE REFLECTION TO CALL THESE FUNCTIONS - SEE blitzkrieg.inc FOR A LIST OF INTERFACES *
 ***************************************************************************************************************/
 
public int RandomDanmaku(int client, int difficulty)
{		
	int index;
	BMO_CurrentRocketType = GetRandomInt(0,9);
	
	switch(BMO_CurrentRocketType)
	{
		case 0: index = 18;
		case 1:	index = 127;
		case 2: index = 228;
		case 3:	index = 414;
		case 4: index = 513;
		case 5:	index = 658;
		case 6: index = 730;
		case 7: index = 1085;
		case 8: index = 1104;
		case 9: index = 974;
	}

	float RNGDamage, RNGSpeed, RNGSpread;
	Handle hItem = TF2Items_CreateItem(FORCE_GENERATION | OVERRIDE_CLASSNAME | OVERRIDE_ITEM_DEF | OVERRIDE_ITEM_LEVEL | OVERRIDE_ITEM_QUALITY | OVERRIDE_ATTRIBUTES);
	
	switch(index)
	{
		case 127: TF2Items_SetClassname(hItem, "tf_weapon_rocketlauncher_directhit");
		case 1104: TF2Items_SetClassname(hItem, "tf_weapon_rocketlauncher_airstrike");
		default: TF2Items_SetClassname(hItem, "tf_weapon_rocketlauncher");
	}
	
	TF2Items_SetItemIndex(hItem, index);
	TF2Items_SetLevel(hItem, difficulty);
	TF2Items_SetQuality(hItem, 5);
	
	switch(difficulty)
	{
		case 1: // Easy
		{
			if(!RageIsBarrage) 
				RNGDamage = GetRandomFloat(0.05, 0.10), RNGSpeed = GetRandomFloat(0.3, 0.4);
			else
				RNGDamage = GetRandomFloat(0.10, 0.15), RNGSpeed = GetRandomFloat(0.4, 0.5);
		}
		case 2: // Normal
		{
			if(!RageIsBarrage)
				RNGDamage = GetRandomFloat(0.10, 0.15), RNGSpeed =	GetRandomFloat(0.3, 0.5);
			else 
				RNGDamage = GetRandomFloat(0.15, 0.25), RNGSpeed =	GetRandomFloat(0.5, 0.6);
		}
		case 3: // Intermediate
		{
			if(!RageIsBarrage)
				RNGDamage = GetRandomFloat(0.15, 0.25), RNGSpeed = GetRandomFloat(0.4, 0.5);
			else
				RNGDamage = GetRandomFloat(0.25, 0.45), RNGSpeed = GetRandomFloat(0.55, 0.65);
		}
		case 4: // Difficult
		{
			if(!RageIsBarrage)
				RNGDamage = GetRandomFloat(0.25, 0.45), RNGSpeed = GetRandomFloat(0.5, 0.6);
			else
				RNGDamage = GetRandomFloat(0.45, 0.65), RNGSpeed = GetRandomFloat(0.65, 0.75);
		}
		case 5: // Lunatic
		{
			if(!RageIsBarrage)
				RNGDamage = GetRandomFloat(0.45, 0.65), RNGSpeed = GetRandomFloat(0.6, 0.7);
			else
				RNGDamage = GetRandomFloat(0.65, 0.85), RNGSpeed = GetRandomFloat(0.7, 0.8);
		}
		case 6: // Insane
		{
			if(!RageIsBarrage)
				RNGDamage = GetRandomFloat(0.65, 0.85), RNGSpeed = GetRandomFloat(0.7, 0.8);
			else
				RNGDamage = GetRandomFloat(0.85, 1.05), RNGSpeed = GetRandomFloat(0.9, 1.1); 
		}
		case 7: // Godlike
		{
			if(!RageIsBarrage)
				RNGDamage = GetRandomFloat(0.85, 1.05), RNGSpeed = GetRandomFloat(0.8, 0.9);
			else
				RNGDamage = GetRandomFloat(1.05, 1.5), RNGSpeed = GetRandomFloat(1.1, 1.5);
		}
		case 8: // Rocket Hell
		{
			if(!RageIsBarrage)
				RNGDamage = GetRandomFloat(1.05, 1.25), RNGSpeed = GetRandomFloat(0.9, 1.1);
			else
				RNGDamage = GetRandomFloat(1.5, 2.0), RNGSpeed = GetRandomFloat(1.5, 2.0);
		}
		case 9: // Total Blitzkrieg
		{
			if(!RageIsBarrage)
				RNGDamage = GetRandomFloat(1.25, 1.50), RNGSpeed = GetRandomFloat(1.1, 1.3); // Total Blitzkrieg
			else
				RNGDamage = GetRandomFloat(2.0, 3.0), RNGSpeed = GetRandomFloat(2.0, 3.0);
		}
		case 420: RNGDamage = 5.20, RNGSpeed = 5.20; // MLG Pro W33D
		case 1337: RNGDamage = 14.37, RNGSpeed = 14.37; // MLG Pro L33T
		case 777: RNGDamage = 8.77, RNGSpeed = 8.77; // RAVIOLI RAVIOLI
		case 999: RNGDamage = 10.99, RNGSpeed = 10.99; // D0NUT ST33L
		case 9001: RNGDamage = 100.01, RNGSpeed = 100.01; // OVER 9000
		default: RNGDamage = (float(difficulty))/GetRandomFloat(2.0,6.0), RNGSpeed = (float(difficulty))/GetRandomFloat(2.0,6.0); // Pure RNG
		}
	
	if(!RageIsBarrage)
	{
		switch(difficulty) // Spread
		{
			case 6: RNGSpread = GetRandomFloat(1.0, 5.0); // Insane
			case 7: RNGSpread = GetRandomFloat(5.0, 10.0); // Godlike
			case 8: RNGSpread = GetRandomFloat(10.0, 20.0); // Rocket Hell
			case 9: RNGSpread = GetRandomFloat(20.0, 30.0); // Total Blitzkrieg
			case 420, 777, 999, 1337, 9001: RNGSpread = GetRandomFloat(30.0, 60.0); // Novelty Levels
		}
	}
	else
	{
		switch(difficulty) // Spread
		{
			case 1,2,3,4: RNGSpread = GetRandomFloat(10.0, 20.0); // Easy - Difficult
			case 5,6,7,8: RNGSpread = GetRandomFloat(20.0, 30.0); // Lunatic - Rocket Hell
			case 9: RNGSpread = GetRandomFloat(30.0, 50.0); // Total Blitzkrieg
			case 420, 777, 999, 1337, 9001: RNGSpread = GetRandomFloat(30.0, 60.0); // Novelty Levels
		}
	}
	
	TF2Items_SetAttribute(hItem, 1, 97, 0.0); // Reload Speed
	TF2Items_SetAttribute(hItem, 2, 642, 1.0); // Mini-Projectiles
	TF2Items_SetAttribute(hItem, 3, 413, 1.0); // Press & Hold to reload
	TF2Items_SetAttribute(hItem, 4, 2025, 3.0); //Is Pro Killstreak
	TF2Items_SetAttribute(hItem, 5, 2013, GetRandomFloat(2002.0, 2008.0)); // Killstreaker
	TF2Items_SetAttribute(hItem, 6, 2014, GetRandomFloat(1.0, 7.0)); // Sheen
	TF2Items_SetAttribute(hItem, 7, 4, GetRandomFloat(10.0, 60.0)); // Clip Size
	TF2Items_SetAttribute(hItem, 8, 6, GetRandomFloat(0.0, 0.3)); // Fire rate bonus
	TF2Items_SetAttribute(hItem, 9, 37, 0.0); // Cannot pick up ammo
	TF2Items_SetAttribute(hItem, 10, (RNGDamage >= 1.0 ? 2 : 1), RNGDamage); // Damage Bonus/Penalty
	TF2Items_SetAttribute(hItem, 11, (RNGSpeed >= 1.0 ? 103 : 104), RNGSpeed); // Speed Bonus/Penalty
	TF2Items_SetAttribute(hItem, 12, (RNGSpread > 0 ? 411 : 269), (RNGSpread > 0 ? RNGSpread : 1.0)); // Spread/See Enemy Health
		
	if (BMO_ActiveThisRound)
	{
		float radius = 1.0;
		switch(DifficultyLevel)
		{
			case 420: radius = 5.2;
			case 777: radius = 8.77;
			case 999: radius = 10.99;
			case 1337: radius = 14.37;
			case 9001: radius = 100.01;
			default: radius = (DifficultyLevel == 1 ? 0.5 : ((float(DifficultyLevel)-1)/float(DifficultyLevel)));
		}
		if (BMO_Flags & BMO_FLAG_STACK_RADIUS)
		{
			if (index == 127)
				radius *= 0.3;
			else if (index == 1104)
				radius *= 0.85;
		}
		TF2Items_SetAttribute(hItem, 13, (radius >= 1.0 ? 99 : 100), radius); // Burn Players
	}
	
	if(difficulty >=5) 
		TF2Items_SetAttribute(hItem, 14, 208, 1.0); // Burn Players
	TF2Items_SetNumAttributes(hItem, (difficulty >= 5 ? 15 : 14));
	
	int iWeapon = TF2Items_GiveNamedItem(client, hItem);
	CloseHandle(hItem);
	EquipPlayerWeapon(client, iWeapon);
	SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", iWeapon);
	return iWeapon;
}
 
 public int GetWeaponDifficulty()
 {
	return DifficultyLevel;
 }
 
 public void SetWeaponDifficulty(int difficulty)
 {
	DifficultyLevel=difficulty;
	RefreshDifficulty(DifficultyLevel);
 }
 
public void HealPlayer(int clientIdx)
{
	// damnit valve, why is max health so useless.
	// gotta go with the hack fix instead
	int maxHealth = GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_iMaxHealth", _, clientIdx);
	maxHealth += 100;
	SetEntityHealth(clientIdx, maxHealth);
}
 
public void CheckWeapons(int client, bool weaponInfo)
{
	// special logic for meeeeeedic
	if(BMO_MedicType[client]!=BMO_MEDIGUN_MEDIC && TF2_GetPlayerClass(client)==TFClass_Medic)
	{
		TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
		TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
		int weapon = SpawnWeapon(client, "tf_weapon_crossbow", BMO_CrossbowIdx, 5, 10, BMO_CrossbowArgs);
		if (IsValidEntity(weapon))
		{
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
			int offset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1);
			if (offset >= 0) // set reserve ammo to 38, sometimes it's over 100 coming from a syringe gun
				SetEntProp(client, Prop_Send, "m_iAmmo", 38, 4, offset);
		}
		
		// special message for class change
		if (BMO_MedicType[client] == BMO_NOT_A_MEDIC)
			CPrintToChat(client, BMO_MedicExploitAlert);
		
		return; // just leave. nothing else for us here.
	}
	
	char classname[64];
	int weapon, index=-1;
	for(int slot=0;slot<=5;slot++)
	{
		weapon=GetPlayerWeaponSlot(client, slot);
		if(!BWO_CheckWeaponOverrides(client, weapon, slot) && weapon && IsValidEdict(weapon))
		{
			GetEdictClassname(weapon, classname, sizeof(classname));
			index=GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		
			/*********************************************************************************************************************************************
			* Because Gun Mettle introduced a lot of stock reskins, we now check the weapon classname and ensure they're not a unique weapon index type.*
			*********************************************************************************************************************************************/
		
			if(!StrContains(classname, "tf_weapon_rocketlauncher") && (index!=127 || index!=228 || index!=414 || index!=441 || index!=730 || index!=1085 || index!=1104)) // Rocket Launcher
			{
				TF2_RemoveWeaponSlot(client, slot);
				weapon=SpawnWeapon(client, classname, index, 5, 10, "1 ; 0.90 ; 4 ; 2.0 ; 6 ; 0.25 ; 15 ; 1 ; 58 ; 1.5 ; 76 ; 6 ; 135 ; 0.30 ; 232 ; 10 ; 275 ; 1");
				if(weaponInfo)
				{
					CPrintToChat(client, "%t", "rocket_launcher");
				}
			}
		
			if(!StrContains(classname, "tf_weapon_flamethrower") && index!=594) // Flamethrowers minus phlog
			{
				TF2_RemoveWeaponSlot(client, slot);
				weapon=SpawnWeapon(client, classname, index, 5, 10, "2 ; 2.0 ; 162 ; 2.0 ; 255 ; 2.5 ; 164 ; 3.0 ; 362 ; 1 ; 173 ; 1.75 ; 178 ; 0.3");
					
				if(weaponInfo)
				{
					CPrintToChat(client, "%t", "flamethrower");
				}
			}
		
			if(!StrContains(classname, "tf_weapon_grenadelauncher") && (index!=308 || index!=996 ||index!=1151)) // Grenade Launcher
			{
				TF2_RemoveWeaponSlot(client, slot);
				weapon=SpawnWeapon(client, classname, index, 5, 10, "2 ; 1.15 ; 4 ; 3 ; 6 ; 0.25 ; 97 ; 0.25 ; 76 ; 4.5 ; 470 ; 0.75");
				
				if(weaponInfo)
				{
					CPrintToChat(client, "%t", "grenade_launcher");
				}
			}
		
			if(!StrContains(classname, "tf_weapon_minigun") && (index!=312 || index!=424 || index!=811 || index!=832)) // Miniguns
			{
				TF2_RemoveWeaponSlot(client, slot);
				weapon=SpawnWeapon(client, classname, index, 5, 10, "375 ; 50");
			
				if(weaponInfo)
				{
					CPrintToChat(client, "%t", "minigun");
				}
			}
		
			if(!StrContains(classname, "tf_weapon_flaregun")) // Flareguns
			{	
				TF2_RemoveWeaponSlot(client, slot);
				weapon=SpawnWeapon(client, classname, index, 5, 10, "25 ; 0.75 ; 65 ; 1.75 ; 207 ; 1.10 ; 144 ; 1 ; 58 ; 4.5 ; 20 ; 1 ; 22 ; 1 ; 551 ; 1 ; 15 ; 1");
			
				if(weaponInfo)
				{
					CPrintToChat(client, "%t", "flaregun");
				}
			}
			
			if(!StrContains(classname, "tf_weapon_medigun")) // Medigun
			{
				TF2_RemoveWeaponSlot(client, slot);
				SpawnWeapon(client, classname, index, 5, 10, "499 ; 50.0 ; 10 ; 1.25 ; 178 ; 0.75 ; 144 ; 2.0 ; 11 ; 1.5 ; 482 ; 3 ; 493 ; 3");
			
				if(weaponInfo)
				{
					CPrintToChat(client, "%t", "medigun");
				}
				Blitz_VerifyMedigunAt[client] = GetEngineTime() + 3.0;
			}
		
			if(!StrContains(classname, "tf_weapon_pda_engineer_build")) // Build PDA
			{
				TF2_RemoveWeaponSlot(client, slot);
				SpawnWeapon(client, classname, index, 5, 10, "113 ; 10 ; 276 ; 1 ; 286 ; 2.25 ; 287 ; 1.25 ; 321 ; 0.70 ; 345 ; 4");
				
				if(weaponInfo)
				{
					CPrintToChat(client, "%t", "build_pda");
				}
			}
		
			switch(index) // "Unique" weapon types and variants
			{
	
				case 42, 863, 1002: // Sandvich, Robo-Sandvich & Festive Sandvich
				{
					TF2_RemoveWeaponSlot(client, slot);					
					weapon=SpawnWeapon(client, classname, index, 5, 10, "144 ; 4 ; 278 ; 0.5");
				
					if(weaponInfo)
					{
						CPrintToChat(client, "%t", "sandvich");
					}
				}
				case 44:
				{
					TF2_RemoveWeaponSlot(client, slot);
					SpawnWeapon(client, classname, index, 5, 10, "38 ; 1 ; 125 ; -15 ; 278 ; 1.5 ; 279 ; 5.0");
				
					if(weaponInfo)
					{
						CPrintToChat(client, "%t", "sandman");
					}
					SetAmmo(client, TFWeaponSlot_Melee, 5);
				}
				case 127: // Direct Hit
				{
					TF2_RemoveWeaponSlot(client, slot);
					weapon=SpawnWeapon(client, classname, index, 5, 10, "103 ; 2 ; 114 ; 1 ; 100 ; 0.30 ; 2 ; 1.50 ; 15 ; 1 ; 179 ; 1 ; 488 ; 3 ; 621 ; 0.35 ; 643 ; 0.75 ; 644 ; 10");
				
					if(weaponInfo)
					{
						CPrintToChat(client, "%t", "direct_hit");
					}				
				}
			
				case 129, 1001: // Buff Banner
				{
					TF2_RemoveWeaponSlot(client, slot);
					weapon=SpawnWeapon(client, classname, index, 5, 10, "26 ; 50 ; 116 ; 1 ; 292 ; 51 ; 319 ; 2.50");
				
					if(weaponInfo)
					{
						CPrintToChat(client, "%t", "buff_banner");
					}
				}
				case 226: // Battalion's Backup
				{
					TF2_RemoveWeaponSlot(client, slot);
					weapon=SpawnWeapon(client, classname, index, 5, 10, "26 ; 50 ; 116 ; 2 ; 292 ; 51 ; 319 ; 2.50");
				
					if(weaponInfo)
					{
						CPrintToChat(client, "%t", "battalions_backup");
					}
				}
				case 228, 1085: // Black Box, Festive Black Box
				{
					TF2_RemoveWeaponSlot(client, slot);
					weapon=SpawnWeapon(client, classname, index, 5, 10, "4 ; 1.5 ; 6 ; 0.25 ; 15 ; 1 ; 16 ; 5 ; 58 ; 3 ; 76 ; 3.50 ; 100 ; 0.5 ; 135 ; 0.60 ; 233 ; 1.50 ; 234 ; 1.30");
					
					if(weaponInfo)
					{
						CPrintToChat(client, "%t", "black_box");
					}
				}
				case 308: // Loch & Load
				{
					TF2_RemoveWeaponSlot(client, slot);
					weapon=SpawnWeapon(client, classname, index, 5, 10, "2 ; 1.75 ; 3 ; 0.75 ; 6 ; 0.25 ; 97 ; 0.25 ; 76 ; 3 ; 127 ; 2");
				
					if(weaponInfo)
					{
						CPrintToChat(client, "%t", "loch_n_load");
					}
				}
				case 312: // Brass Beast
				{
					TF2_RemoveWeaponSlot(client, slot);
					weapon=SpawnWeapon(client, classname, index, 5, 10, "2 ; 1.2 ; 86 ; 1.5 ; 183 ; 0.4 ; 375 ; 50");
				
					if(weaponInfo)
					{
						CPrintToChat(client, "%t", "brass_beast");
					}
				}
				case 354: // Concheror
				{
					TF2_RemoveWeaponSlot(client, slot);
					weapon=SpawnWeapon(client, classname, index, 5, 10, "26 ; 50 ; 57 ; 3 ; 116 ; 3 ; 292 ; 51 ; 319 ; 2.50");
				
					if(weaponInfo)
					{
						CPrintToChat(client, "%t", "concheror");
					}
				}
				case 414: // Liberty Launcher
				{
					TF2_RemoveWeaponSlot(client, slot);
					weapon=SpawnWeapon(client, classname, index, 5, 10, "1 ; 0.75 ; 4 ; 2.5 ; 6 ; 0.4 ; 58 ; 3 ; 76 ; 3.50 ; 100 ; 0.85 ; 103 ; 2 ; 135 ; 0.50");
				
					if(weaponInfo)
					{
						CPrintToChat(client, "%t", "liberty_launcher");
					}
				}
				case 424: // Tomislav
				{
					TF2_RemoveWeaponSlot(client, slot);
					weapon=SpawnWeapon(client, classname, index, 5, 10, "5 ; 1.1 ; 87 ; 1.1 ; 238 ; 1 ; 375 ; 50");
				
					if(weaponInfo)
					{
						CPrintToChat(client, "%t", "tomislav");
					}
				}
				case 441: //Cow Mangler
				{
					TF2_RemoveWeaponSlot(client, slot);
					weapon=SpawnWeapon(client, classname, index, 5, 10, "2 ; 1.5 ; 58 ; 2 ; 281 ; 1 ; 282 ; 1 ; 288 ; 1 ; 366 ; 5");
				
					if(weaponInfo)
					{
						CPrintToChat(client, "%t", "cow_mangler");
					}
				}
				// Temporarily disabled Wrap Assassin due to some issues regarding insta-killing Blitz.
				/*case 648:
				{
					TF2_RemoveWeaponSlot(client, slot);
					SpawnWeapon(client, classname, index, 5, 10, "1 , 0.3 ; 346 ; 1 ; 278 ; 1.5 ; 279 ; 5.0");
				
					if(weaponInfo)
					{
						CPrintToChat(client, "%t", "wrap_assassin");
					}
					SetAmmo(client, TFWeaponSlot_Melee, 5);
				}*/
				case 730: //Beggar's Bazooka
				{
					TF2_RemoveWeaponSlot(client, slot);
					weapon=SpawnWeapon(client, classname, index, 5, 10, "135 ; 0.25 ; 58 ; 1.5 ; 2 ; 1.1 ; 4 ; 7.5 ; 6 ; 0 ; 76 ; 10 ; 97 ; 0.25 ; 411 ; 15 ; 413 ; 1 ; 417 ; 1");
				
					if(weaponInfo)
					{
						CPrintToChat(client, "%t", "beggars_bazooka");
					}
				}
				case 811, 832: // Huo-Long Heater
				{
					TF2_RemoveWeaponSlot(client, slot);
					weapon=SpawnWeapon(client, classname, index, 5, 10, "71 ; 1.25 ; 76 ; 2 ; 206 ; 1.25 ; 375 ; 50 ; 430 ; 1 ; 431 ; 5");
					
					if(weaponInfo)
					{
						CPrintToChat(client, "%t", "huo_long_heater");
					}
				}
				case 996: // Loose Cannon
				{
					TF2_RemoveWeaponSlot(client, slot);
					weapon=SpawnWeapon(client, classname, index, 5, 10, "2 ; 1.25 ; 4 ; 1.5 ; 6 ; 0.25 ; 97 ; 0.25 ; 76 ; 4 ; 466 ; 1 ; 467 ; 1 ; 470 ; 0.7");
					
					if(weaponInfo)
					{
						CPrintToChat(client, "%t", "loose_cannon");
					}
				}
				case 1104: // Air Strike
				{
					TF2_RemoveWeaponSlot(client, slot);
					weapon=SpawnWeapon(client, classname, index, 5, 10, "1 ; 0.90 ; 15 ; 1 ; 179 ; 1 ; 232 ; 10 ; 488 ; 3 ; 621 ; 0.35 ; 642 ; 1 ; 643 ; 0.75 ; 644 ; 10");
				
					if(weaponInfo)
					{
						CPrintToChat(client, "%t", "air_strike");
					}
				}
				case 1153: // Panic Attack
				{
					TF2_RemoveWeaponSlot(client, slot);
					weapon=SpawnWeapon(client, classname, index, 5, 10, "61 ; 1.5 ; 63 ; 1.5 ; 65 ; 1.5 ; 97 ; 0.77 ; 107 ; 1.7 ; 128 ; 1 ; 179 ; 1 ; 232 ; 15 ; 394 ; 0.85 ; 651 ; 0.5 ; 708 ; 1 ; 709 ; 1 ; 710 ; 1 ; 711 ; 1");	
				
					if(weaponInfo)
					{
						CPrintToChat(client, "%t", "panic_attack");
					}
				}
				case 1151: // Iron Bomber
				{
					TF2_RemoveWeaponSlot(client, slot);
					weapon=SpawnWeapon(client, classname, index, 5, 10, "2 ; 1.10 ; 4 ; 5 ; 6 ; 0.25 ; 97 ; 0.25 ; 76 ; 6 ; 671 ; 1 ; 684 ; 0.6");
				
					if(weaponInfo)
					{
						CPrintToChat(client, "%t", "iron_bomber");
					}
				}
			}
		}
	}
	
	// Buff scouts and spies
	if(TF2_GetPlayerClass(client) == TFClass_Scout || TF2_GetPlayerClass(client) == TFClass_Spy)
		TF2_AddCondition(client, TFCond_CritCanteen, TFCondDuration_Infinite);
		
	// special logic for wearables and demo wearables
	if (BWO_ActiveThisRound) for (int pass = 0; pass <= 1; pass++)
	{
		static char classname2[MAX_ENTITY_CLASSNAME_LENGTH];
		if (pass == 0)
			classname2 = "tf_wearable";
		else
			classname2 = "tf_wearable_demoshield";
		
		int wearable = MAX_PLAYERS;
		while ((wearable = FindEntityByClassname(wearable, classname2)) != -1)
		{
			if (client == GetEntPropEnt(wearable, Prop_Send, "m_hOwnerEntity"))
				if (BWO_CheckWeaponOverrides(client, wearable, -1))
					break; // easy way to avoid eating up all edicts. also, assuming each player only has stat-infused wearable.
		}
	}
}

#define SDHELL "super_danmaku_hell"
#define BLDRSETUP "bloodrider_config"

public void SuperDanmakuHell(int client, int boss)
{
	int bldrIdx[MAXPLAYERS+1]=-1;
	int blitzIdx[MAXPLAYERS+1]=-1;
	char proj[32], projs[32][32];
	FF2_GetAbilityArgumentString(boss, this_plugin_name, SDHELL, 1, proj, sizeof(proj));
	
	float pos[3], pos2[3], distance;
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
	float dist=FF2_GetAbilityArgumentFloat(boss,this_plugin_name,SDHELL, 2, FF2_GetRageDist(boss, this_plugin_name, SDHELL));	//range
	
	int bossIdx;
	for(int player=1;player<=MaxClients;player++)
	{
		if(!IsValidClient(player, true))
			continue;
		bossIdx=FF2_GetBossIndex(player);
		if(bossIdx>=0)
		{
			if(FF2_HasAbility(bossIdx, this_plugin_name, BLITZSETUP))
			{
				blitzIdx[player]=bossIdx;
			}
			if(FF2_HasAbility(bossIdx, this_plugin_name, BLDRSETUP))
			{
				bldrIdx[player]=bossIdx;
			}		
		}
	}
	
	if(boss>=0 && (blitzIdx[client]==boss || bldrIdx[client]==boss))
	{
		int companionIdx;
		for(int companion=1;companion<=MaxClients;companion++)
		{
			if(IsValidClient(companionIdx, true))
				break;
				
			if(!IsValidClient(companion, true))
				continue;
	
			bossIdx=FF2_GetBossIndex(companion);
			if(bossIdx<0 || blitzIdx[companion]==blitzIdx[client] || bldrIdx[companion]==bldrIdx[client]) // Skip over the main boss and non-bosses
				continue;
			
			GetEntPropVector(companion, Prop_Send, "m_vecOrigin", pos2);
			distance=GetVectorDistance(pos, pos2);
			if (distance<dist && (bldrIdx[companion]==bossIdx || blitzIdx[companion]==bossIdx))
			{
				companionIdx=companion;
			}				
		}
		
		if(!(GetEntityFlags(client) & FL_ONGROUND) && !(GetEntityFlags(companionIdx) & FL_ONGROUND))
		{
			return;
		}
		
		SetEntityMoveType(client, MOVETYPE_NONE);
		SetEntityMoveType(companionIdx, MOVETYPE_NONE);
		CreateTimer(FF2_GetAbilityArgumentFloat(boss, this_plugin_name, SDHELL, 3), Timer_YouCanWalk, client);
		CreateTimer(FF2_GetAbilityArgumentFloat(boss, this_plugin_name, SDHELL, 3), Timer_YouCanWalk, companionIdx);
		
		RageIsBarrage=true;
		int rocketLauncher=RandomDanmaku(blitzIdx[client]==boss ? client : companionIdx, 9);
		RageIsBarrage=false;
		int grenadeLauncher=0; // Need grenade launcher stats here with 413 ; 1 attribute in place.
	
		SetAmmo(blitzIdx[client]==boss ? client : companionIdx, rocketLauncher,0);
		SetAmmo(bldrIdx[client]==boss ? client : companionIdx, grenadeLauncher,0);	
	
		if(rocketLauncher && IsValidEntity(rocketLauncher) && grenadeLauncher && IsValidEntity(grenadeLauncher))
		{
			int projct = ExplodeString(proj, " ; ", projs, sizeof(projs), sizeof(projs));
			if (projct > 0)
			{
				for (int i = 0; i < projct; i+=2)
				{
					SetEntProp(rocketLauncher, Prop_Send, "m_iClip1", StringToInt(projs[i]));
					SetEntProp(grenadeLauncher, Prop_Send, "m_iClip1", StringToInt(projs[i+1]));
				}
			}
		}
	}
}

public Action Timer_YouCanWalk(Handle timer, any client)
{
	if(!IsValidClient(client, true))
		return Plugin_Stop;
	SetEntityMoveType(client, MOVETYPE_WALK);
	return Plugin_Continue;
}
