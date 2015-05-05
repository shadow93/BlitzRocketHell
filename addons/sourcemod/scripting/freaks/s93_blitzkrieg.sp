/* 
	ブリッツクリーグ
	
	SHADoW93's Project TF2Danmaku Presents:
	
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
			
		blitzkrieg_barrage
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
#undef REQUIRE_PLUGIN
#tryinclude <updater>
#tryinclude <revivemarkers>
#tryinclude <goomba>
#define REQUIRE_PLUGIN

// sarysa's code
#define MAX_CENTER_TEXT_LENGTH 256
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
new bool: LoomynartyMusic = false;

// back to shadow93's code
#define PLAYERDEATH "freak_fortress_2/s93dm/dm_playerdeath.mp3"
#define BLITZKRIEG_SND "mvm/mvm_tank_end.wav"
#define MINIBLITZKRIEG_SND "mvm/mvm_tank_start.wav"
#define OVER_9000	"saxton_hale/9000.wav"
#define L00MYNARTY "freak_fortress_2/s93dm/dm_l33t.mp3"
#define SM0K3W33D "freak_fortress_2/s93dm/dm_w33d.mp3"
#define BLITZROUNDSTART "freak_fortress_2/s93dm/eog_intro.mp3"
#define BLITZROUNDEND	"freak_fortress_2/s93dm/eog_outtro.mp3"

#if defined _updater_included
#define UPDATE_URL "http://www.shadow93.info/tf2/tf2plugins/tf2danmaku/update.txt"
#endif

// Bouncing Projectiles
#define	MAX_EDICT_BITS	11
#define	MAX_EDICTS		(1 << MAX_EDICT_BITS)
new rBounce[MAX_EDICTS], rMaxBounceCount[MAX_EDICTS], rMaxBounces = 0;

// Version Number
#define MAJOR_REVISION "2"
#define MINOR_REVISION "4"
#define PATCH_REVISION "1"
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
	description="Projectile Hell (TF2Danmaku)",
	version=PLUGIN_VERSION,
};


//Other Stuff
new customweapons;
new combatstyle;
new weapondifficulty;
new voicelines;
new dBoss;
new blitzkriegrage;
new miniblitzkriegrage;
new startmode;
new minlvl;
new maxlvl;
new lvlup;
new bool:bRdm = false;
new bool:barrage = false;
new bool:blitzisboss = false;
new bool:BlitzIsWinner = false;
new bool:hooksEnabled = false;

// Reanimators
new allowrevive;
new decaytime;
new reviveMarker[MAXPLAYERS+1];
new bool:ChangeClass[MAXPLAYERS+1] = { false, ... };
new currentTeam[MAXPLAYERS+1] = {0, ... };
new Float:Blitz_LastPlayerPos[MAX_PLAYERS_ARRAY][3];

// Integration Mode (Wolvan's revive markers plugin)
#if defined _revivemarkers_included_
new bool:IntegrationMode = false;
new Handle:cvarHaleVisibility, cvalHaleVisibility;
new Handle:cvarTeamRestrict, cvalTeamRestrict;
new Handle:cvarVisibility, cvalVisibility;
new Handle:cvarNoRestrict, cvalNoRestrict;
#endif

// many, many timer replacements
new Float:Blitz_EndCrocketHellAt;
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

// Blitz in Medic mode
static const String:BlitzMedic[][] = {
	"vo/medic_mvm_resurrect01.mp3",
	"vo/medic_mvm_resurrect02.mp3",
	"vo/medic_mvm_resurrect03.mp3"
};

static const String:BlitzMedicRage[][] = {
	"vo/medic_mvm_heal_shield02.mp3",
	"vo/medic_positivevocalization05.mp3",
	"vo/taunts/medic_taunts08.mp3"
};

// Blitz in Soldier mode
static const String:BlitzSoldier[][] = {
	"vo/soldier_mvm_resurrect03.mp3",
	"vo/soldier_mvm_resurrect05.mp3",
	"vo/soldier_mvm_resurrect06.mp3"
};

static const String:BlitzSoldierRage[][] = {
	"vo/taunts/soldier_taunts16.mp3",
	"vo/taunts/soldier_taunts05.mp3",
	"vo/taunts/soldier_taunts21.mp3"
};

// Level Up Enabled Indicator
static const String:BlitzCanLvlUp[][] = {
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

public Blitzkrieg_PrecacheSounds() // sarysa 2015-03-25, OnMapStart() NEVER worked for me with FF2 sub-plugins, so I set it up to do these precaches in two places.
{
	// ROUND EVENTS
	PrecacheSound(BLITZROUNDSTART,true);
	PrecacheSound(BLITZROUNDEND, true);
	PrecacheSound(OVER_9000, true);
	PrecacheSound(PLAYERDEATH, true);
	PrecacheSound(L00MYNARTY, true);
	PrecacheSound(SM0K3W33D, true);
	// RAGE GENERIC ALERTS
	PrecacheSound(BLITZKRIEG_SND,true);
	PrecacheSound(MINIBLITZKRIEG_SND,true);
	//When Blitzkrieg returns to his normal medic self
	for (new i = 0; i < sizeof(BlitzMedic); i++)
	{
		PrecacheSound(BlitzMedic[i], true);
	}
	for (new i = 0; i < sizeof(BlitzMedicRage); i++)
	{
		PrecacheSound(BlitzMedicRage[i], true);
	}
	//When the fallen Soldier's soul takes over
	for (new i = 0; i < sizeof(BlitzSoldier); i++)
	{
		PrecacheSound(BlitzSoldier[i], true);
	}
	for (new i = 0; i < sizeof(BlitzSoldierRage); i++)
	{
		PrecacheSound(BlitzSoldierRage[i], true);
	}
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
	for (new i = 0; i < sizeof(BlitzCanLvlUp); i++)
	{
		PrecacheSound(BlitzCanLvlUp[i], true);
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
	HookEvent("arena_round_start", OnRoundStart, EventHookMode_PostNoCopy);
	HookEvent("arena_win_panel", OnRoundEnd, EventHookMode_PostNoCopy);
	for (new i = 1; i <= MaxClients; i++) 
	{
		if (IsClientInGame(i)) 
		{
			currentTeam[i] = GetClientTeam(i);
			ChangeClass[i] = false;
		}
	}
	
	// sarysa 2015-03-25, this is the first place sounds get precached.
	// note that this sometimes precaches here will fail when the server is first started.
	// this is mainly a problem with old forks of FF2, like VSP and DISC-FF
	Blitzkrieg_PrecacheSounds();
	
	for (new clientIdx = 1; clientIdx < MAX_PLAYERS; clientIdx++)
		reviveMarker[clientIdx] = INVALID_ENTREF;
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
	#if defined _updater_included
    if(StrEqual(name, "updater"))
    {
		Updater_AddPlugin(UPDATE_URL);
    }
	#endif
	
	#if defined _revivemarkers_included_
	if(StrEqual(name, "revivemarkers"))
    {
		IntegrationMode = true;
	}
	#endif
}

public OnLibraryRemoved(const String: name[])
{
	#if defined _updater_included
	if(StrEqual(name, "updater"))
	{
		Updater_RemovePlugin();
	}
	#endif
	
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
		
	HookEvent("teamplay_broadcast_audio", OnAnnounce, EventHookMode_Pre);
	HookEvent("post_inventory_application", OnPlayerInventory, EventHookMode_PostNoCopy);
	HookEvent("player_death", OnPlayerDeath, EventHookMode_Pre);
	HookEvent("player_changeclass", OnChangeClass);
	AddCommandListener(CheckLevel, "ff2_hp");
	AddCommandListener(CheckLevel, "ff2hp");
	AddCommandListener(CheckLevel, "hale_hp");
	AddCommandListener(CheckLevel, "halehp");
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
		
	UnhookEvent("teamplay_broadcast_audio", OnAnnounce, EventHookMode_Pre);
	UnhookEvent("post_inventory_application", OnPlayerInventory, EventHookMode_PostNoCopy);
	UnhookEvent("player_death", OnPlayerDeath, EventHookMode_Pre);
	UnhookEvent("player_changeclass", OnChangeClass);
	RemoveCommandListener(CheckLevel, "ff2_hp");
	RemoveCommandListener(CheckLevel, "ff2hp");
	RemoveCommandListener(CheckLevel, "hale_hp");
	RemoveCommandListener(CheckLevel, "halehp");
	RemoveCommandListener(BlitzHelp, "ff2_classinfo");
	RemoveCommandListener(BlitzHelp, "ff2classinfo");
	RemoveCommandListener(BlitzHelp, "hale_classinfo");
	RemoveCommandListener(BlitzHelp, "haleclassinfo");
	RemoveCommandListener(BlitzHelp, "ff2help");
	RemoveCommandListener(BlitzHelp, "helpme");

	hooksEnabled = false;
}

public Action:OnRoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	// Here, we have a config for blitzkrieg's rounds //
	if (!FF2_IsFF2Enabled())
		return;
		
	RoundInProgress = true;
	BMO_ActiveThisRound = false;
	BWO_ActiveThisRound = false;
	weapondifficulty = 0;
	allowrevive = 0;
	barrage = false;
	bRdm = false;
	BMO_UpdateTimerHUDAt = FAR_FUTURE;
	BMO_RoundEndsAt = FAR_FUTURE;
	blitzisboss = false;
	Blitz_EndCrocketHellAt = FAR_FUTURE;
	Blitz_PostSetupAt = FAR_FUTURE;
	Blitz_AdminTauntAt = FAR_FUTURE;
	Blitz_RemoveUberAt = FAR_FUTURE;

	dBoss = GetClientOfUserId(FF2_GetBossUserId());
	if(dBoss>0)
	{
		if (FF2_HasAbility(0, this_plugin_name, "blitzkrieg_config"))
		{	
			// sarysa: load the strings first
			new bossIdx = 0; // yeah I hate literals. I guess this boss is not multi-boss friendly.
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
			bRdm = false;
			barrage = false;

			// sarysa 2015-03-25, this is the second place sounds get precached, as a precautionary measure.
			Blitzkrieg_PrecacheSounds();

			// Custom Weapon Handler System
			customweapons=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 3); // use custom weapons
			if(customweapons)
				Blitz_PostSetupAt = GetEngineTime() + 0.3;

			// Weapon Difficulty
			weapondifficulty=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 1, 2);
			if (difficultyOverride != -1)
				weapondifficulty = difficultyOverride;
			PrintToServer("difficulty will be %d", weapondifficulty);
			if(!weapondifficulty)
			{
				bRdm = true;
				minlvl=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 10, 2); // Minimum level to roll on random mode
				maxlvl=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 11, 5); // Max level to roll on random mode
				weapondifficulty=GetRandomInt(minlvl,maxlvl);
			}

			// Weapon Stuff
			combatstyle=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 2);
			miniblitzkriegrage=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 5, 180); // RAGE/Weaponswitch Ammo
			blitzkriegrage=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 6, 360); // Blitzkrieg Rampage Ammo
			startmode=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 7); // Start with launcher or no (with melee mode)
			switch(combatstyle)
			{
				case 1:
				{
					PrintHintText(dBoss, BS_CombatModeNoMelee);
					PlotTwist(dBoss);
				}
				case 0:
				{
					PrintHintText(dBoss, BS_CombatModeWithMelee);
					PlotTwist(dBoss);
				}
			}

			// Misc
			voicelines=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 4); // Voice Lines
			allowrevive=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 8); // Allow Reanimator
			decaytime=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 9); // Reanimator decay time
			lvlup=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 12); // Allow Blitzkrieg to change difficulty level on random mode?

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
	
				switch(allowrevive)
				{
					case -1, 0: CPrintToChatAll((allowrevive==-1 ? "{blue} You have unlimited revives" : "{red} Revive markers disabled"));
					default: SetReviveCount(allowrevive), CPrintToChatAll("{red} You can only be revived %i times", allowrevive);
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
				setDecayTime(decaytime);
			}
			#endif
			
			rMaxBounces = FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 14); // Projectile Bounce

			
			DisplayCurrentDifficulty(dBoss);
			if(lvlup)
				Blitz_AdminTauntAt = GetEngineTime() + 6.0;
		}
	}
	
	// sarysa's adaptation of otokiru teleport, done in a way that it'll work even if blitzkrieg isn't enabled this round
	SPT_ActiveThisRound = false;
	for (new clientIdx = 1; clientIdx < MAX_PLAYERS; clientIdx++)
	{
		SPT_CanUse[clientIdx] = false;
	
		if (!IsLivingPlayer(clientIdx))
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
			if (IsLivingPlayer(clientIdx))
				GetEntPropVector(clientIdx, Prop_Send, "m_vecOrigin", Blitz_LastPlayerPos[clientIdx]);
			Blitz_RemoveReviveMarkerAt[clientIdx] = FAR_FUTURE;
			Blitz_MoveReviveMarkerAt[clientIdx] = FAR_FUTURE;
			Blitz_ReverifyWeaponsAt[clientIdx] = FAR_FUTURE;
			Blitz_VerifyMedigunAt[clientIdx] = FAR_FUTURE;
			reviveMarker[clientIdx] = INVALID_ENTREF;
		}
	}
}

public Action:OnRoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	RoundInProgress = false;
	
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
		weapondifficulty = 0;
		allowrevive = 0;
		barrage = false;
		bRdm = false;
		blitzisboss = false;
		Blitz_RemoveHooks();
		
		if (GetEventInt(event, "winning_team") == FF2_GetBossTeam())
			BlitzIsWinner = true;
		else if (GetEventInt(event, "winning_team") == ((FF2_GetBossTeam()==_:TFTeam_Blue) ? (_:TFTeam_Red) : (_:TFTeam_Blue)))
			BlitzIsWinner = false;
		CreateTimer(5.0, RoundResultSound, _, TIMER_FLAG_NO_MAPCHANGE); // sarysa: kept this one around, but fixed param #4 to be the no mapchange flag
		
		// remove revive markers
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
	if (!RoundInProgress || strcmp(plugin_name, this_plugin_name) != 0)
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
		if (FF2_GetRoundState()==1)
		{
			barrage=true;
			BMO_CurrentIsBlizkrieg = true;
			TF2_AddCondition(Boss,TFCond_Ubercharged,FF2_GetAbilityArgumentFloat(boss,this_plugin_name,ability_name,1,5.0)); // Ubercharge
			Blitz_RemoveUberAt = GetEngineTime() + FF2_GetAbilityArgumentFloat(boss,this_plugin_name,ability_name,1,5.0);
			TF2_AddCondition(Boss,BLITZKRIEG_COND_CRIT,FF2_GetAbilityArgumentFloat(boss,this_plugin_name,ability_name,2,5.0)); // Kritzkrieg
			if(lvlup)
			{
				LoomynartyMusic = true;
				if(bRdm && lvlup==1)
					weapondifficulty=GetRandomInt(minlvl,maxlvl);
				else
				{
					// so sourcemod does switches differently. no break required. who'd have thought. - sarysa
					if ((BMO_Flags & BMO_FLAG_BLOCK_NOVELTY_DIFFICULTY) == 0)
					{
						switch(weapondifficulty)
						{
							case 9: weapondifficulty=420;
							case 420: weapondifficulty=777;
							case 777: weapondifficulty=999;
							case 999: weapondifficulty=1337;
							case 1337: weapondifficulty=9001;
							case 9001:
							{
								if(bRdm)
									weapondifficulty=minlvl;
								else
									weapondifficulty=FF2_GetAbilityArgument(boss,this_plugin_name,"blitzkrieg_config", 1, 2);
							}
							default: weapondifficulty=weapondifficulty+1;
						}
					}
					else
						weapondifficulty=weapondifficulty+1;
				}
				DisplayCurrentDifficulty(Boss);		
			}
			SetEntProp(Boss, Prop_Data, "m_takedamage", 0);
			//Switching Blitzkrieg's player class while retaining the same model to switch the voice responses/commands
			PlotTwist(Boss);
			Blitz_EndCrocketHellAt = GetEngineTime() + FF2_GetAbilityArgumentFloat(boss,this_plugin_name,ability_name,3);
			if(!combatstyle) // 2x strength if using mixed melee/rocket launcher
			{
				new Float:rDuration=FF2_GetAbilityArgumentFloat(boss,this_plugin_name,ability_name, 3);
				TF2_AddCondition(Boss, COND_RUNE_STRENGTH, rDuration);
			}
			//For the Class Reaction Voice Lines
			switch(voicelines)
			{
				case 1:
				{
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
	}
	else if (!strcmp(ability_name,"mini_blitzkrieg")) 	// KRITZKRIEG & CROCKET HELL
	{		
		if (FF2_GetRoundState()==1)
		{	
			if(!barrage)
				BMO_CurrentIsBlizkrieg = false;
			TF2_AddCondition(Boss,BLITZKRIEG_COND_CRIT,FF2_GetAbilityArgumentFloat(boss,this_plugin_name,ability_name,1,5.0)); // Kritzkrieg
			TF2_RemoveWeaponSlot(Boss, TFWeaponSlot_Primary);
			//RAGE Voice lines depending on Blitzkrieg's current player class (Blitzkrieg is two classes in 1 - Medic / Soldier soul in the same body)
			new String:IsRaging[PLATFORM_MAX_PATH];
			switch(TF2_GetPlayerClass(Boss))
			{
				case TFClass_Medic: // Medic
				{
					strcopy(IsRaging, PLATFORM_MAX_PATH, BlitzMedicRage[GetRandomInt(0, sizeof(BlitzMedicRage)-1)]);	
				}
				default: //case TFClass_Soldier: // Soldier
				{
					strcopy(IsRaging, PLATFORM_MAX_PATH, BlitzSoldierRage[GetRandomInt(0, sizeof(BlitzSoldierRage)-1)]);	
				}
			}
			if ((BMO_Flags & BMO_FLAG_NO_VOICE_MESSAGES) == 0)
				EmitSoundToAll(IsRaging, Boss);	
			// Weapon switch depending if Blitzkrieg Barrage is active or not
			RandomDanmaku(Boss, weapondifficulty);
			SetAmmo(Boss, TFWeaponSlot_Primary,(combatstyle == 1 ? 999999 : miniblitzkriegrage));
			
			switch(voicelines)
			{
				case 1:
				{
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
	}
	return Plugin_Continue;
}

ClassResponses(client)
{
	if ((BMO_Flags & BMO_FLAG_NO_CLASS_MESSAGES) != 0)
		return;

	if(IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client)!=FF2_GetBossTeam())
	{
		new String:Reaction[PLATFORM_MAX_PATH];
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

// Switch Roles ability
PlotTwist(client)
{
	if(barrage)
	{
		new String:StillAlive[PLATFORM_MAX_PATH];
		if ((BMO_Flags & BMO_FLAG_KEEP_PLAYER_CLASS) != 0)
			StillAlive = BlitzSoldier[GetRandomInt(0, sizeof(BlitzSoldier)-1)];
		else
		{
			switch(TF2_GetPlayerClass(client))
			{
				case TFClass_Medic: // Medic
				{
					TF2_SetPlayerClass(client, TFClass_Soldier);
					strcopy(StillAlive, PLATFORM_MAX_PATH, BlitzSoldier[GetRandomInt(0, sizeof(BlitzSoldier)-1)]);
				}
				case TFClass_Soldier: // Soldier
				{
					TF2_SetPlayerClass(client, TFClass_Medic);
					strcopy(StillAlive, PLATFORM_MAX_PATH, BlitzMedic[GetRandomInt(0, sizeof(BlitzMedic)-1)]);		
				}
			}
		}
		if ((BMO_Flags & BMO_FLAG_NO_VOICE_MESSAGES) == 0)
			EmitSoundToAll(StillAlive);	
	}
	else
	{
		if ((BMO_Flags & BMO_FLAG_KEEP_PLAYER_CLASS) == 0)
		{
			new RandomClass = GetRandomInt(0,1);
			TF2_SetPlayerClass(client, (RandomClass == 0 ? TFClass_Medic : TFClass_Soldier));
		}
	}
	if (BMO_Flags & BMO_FLAG_KEEP_MELEE)
	{
		TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
		TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
		TF2_RemoveWeaponSlot(client, TFWeaponSlot_PDA);
		TF2_RemoveWeaponSlot(client, TFWeaponSlot_Item1);
	}
	else
		TF2_RemoveAllWeapons(client);
	// ONLY FOR LEGACY REASONS, FF2 1.10.3 and newer doesn't actually need this to restore the boss model.
	if ((BMO_Flags & BMO_FLAG_KEEP_PLAYER_MODEL) == 0)
	{
		SetVariantString("models/freak_fortress_2/shadow93/dmedic/dmedic.mdl");
		AcceptEntityInput(client, "SetCustomModel");
		SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
	}
	// Removing all wearables
	new entity, owner;
	while((entity=FindEntityByClassname(entity, "tf_wearable"))!=-1)
		if((owner=GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity"))<=MaxClients && owner>0 && GetClientTeam(owner)==FF2_GetBossTeam())
			TF2_RemoveWearable(owner, entity);
	while((entity=FindEntityByClassname(entity, "tf_wearable_demoshield"))!=-1)
		if((owner=GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity"))<=MaxClients && owner>0 && GetClientTeam(owner)==FF2_GetBossTeam())
			TF2_RemoveWearable(owner, entity);
	while((entity=FindEntityByClassname(entity, "tf_powerup_bottle"))!=-1)
		if((owner=GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity"))<=MaxClients && owner>0 && GetClientTeam(owner)==FF2_GetBossTeam())
			TF2_RemoveWearable(owner, entity);

	if ((BMO_Flags & BMO_FLAG_NO_PARACHUTE) == 0)
		SpawnWeapon(client, "tf_weapon_parachute", 1101, 109, 5, "700 ; 1 ; 701 ; 99 ; 702 ; 99 ; 703 ; 99 ; 705 ; 1 ; 640 ; 1 ; 68 ; 12 ; 269 ; 1 ; 275 ; 1");

	if(barrage || startmode)
		RandomDanmaku(client, weapondifficulty);
	
	if(!combatstyle)
	{
		if ((BMO_Flags & BMO_FLAG_KEEP_MELEE) == 0)
		{
			switch(weapondifficulty)
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
	SetAmmo(client, TFWeaponSlot_Primary,(combatstyle==1 ? 999999 : (barrage == true ? blitzkriegrage : miniblitzkriegrage)));
	
}		

// Weaponswitch

RandomDanmaku(client, difficulty)
{		
	new index;
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

	new Float:RNGDamage, Float:RNGSpeed, Float:RNGSpread;
	new Handle:hItem = TF2Items_CreateItem(FORCE_GENERATION | OVERRIDE_CLASSNAME | OVERRIDE_ITEM_DEF | OVERRIDE_ITEM_LEVEL | OVERRIDE_ITEM_QUALITY | OVERRIDE_ATTRIBUTES);
	
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
			if(!barrage) 
				RNGDamage = GetRandomFloat(0.05, 0.10), RNGSpeed = GetRandomFloat(0.3, 0.4);
			else
				RNGDamage = GetRandomFloat(0.10, 0.15), RNGSpeed = GetRandomFloat(0.4, 0.5);
		}
		case 2: // Normal
		{
			if(!barrage)
				RNGDamage = GetRandomFloat(0.10, 0.15), RNGSpeed =	GetRandomFloat(0.3, 0.5);
			else 
				RNGDamage = GetRandomFloat(0.15, 0.25), RNGSpeed =	GetRandomFloat(0.5, 0.6);
		}
		case 3: // Intermediate
		{
			if(!barrage)
				RNGDamage = GetRandomFloat(0.15, 0.25), RNGSpeed = GetRandomFloat(0.4, 0.5);
			else
				RNGDamage = GetRandomFloat(0.25, 0.45), RNGSpeed = GetRandomFloat(0.55, 0.65);
		}
		case 4: // Difficult
		{
			if(!barrage)
				RNGDamage = GetRandomFloat(0.25, 0.45), RNGSpeed = GetRandomFloat(0.5, 0.6);
			else
				RNGDamage = GetRandomFloat(0.45, 0.65), RNGSpeed = GetRandomFloat(0.65, 0.75);
		}
		case 5: // Lunatic
		{
			if(!barrage)
				RNGDamage = GetRandomFloat(0.45, 0.65), RNGSpeed = GetRandomFloat(0.6, 0.7);
			else
				RNGDamage = GetRandomFloat(0.65, 0.85), RNGSpeed = GetRandomFloat(0.7, 0.8);
		}
		case 6: // Insane
		{
			if(!barrage)
				RNGDamage = GetRandomFloat(0.65, 0.85), RNGSpeed = GetRandomFloat(0.7, 0.8);
			else
				RNGDamage = GetRandomFloat(0.85, 1.05), RNGSpeed = GetRandomFloat(0.9, 1.1); 
		}
		case 7: // Godlike
		{
			if(!barrage)
				RNGDamage = GetRandomFloat(0.85, 1.05), RNGSpeed = GetRandomFloat(0.8, 0.9);
			else
				RNGDamage = GetRandomFloat(1.05, 1.5), RNGSpeed = GetRandomFloat(1.1, 1.5);
		}
		case 8: // Rocket Hell
		{
			if(!barrage)
				RNGDamage = GetRandomFloat(1.05, 1.25), RNGSpeed = GetRandomFloat(0.9, 1.1);
			else
				RNGDamage = GetRandomFloat(1.5, 2.0), RNGSpeed = GetRandomFloat(1.5, 2.0);
		}
		case 9: // Total Blitzkrieg
		{
			if(!barrage)
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
	
	if(!barrage)
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
		new Float:radius = 1.0;
		switch(weapondifficulty)
		{
			case 420: radius = 5.2;
			case 777: radius = 8.77;
			case 999: radius = 10.99;
			case 1337: radius = 14.37;
			case 9001: radius = 100.01;
			default: radius = (weapondifficulty == 1 ? 0.5 : ((float(weapondifficulty)-1)/float(weapondifficulty)));
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
	
	new iWeapon = TF2Items_GiveNamedItem(client, hItem);
	CloseHandle(hItem);
	EquipPlayerWeapon(client, iWeapon);
	SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", iWeapon);
}


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

// Custom Weaponset. I might eventually turn it into its own external config or something.
CheckWeapons(client)
{
	// special logic for meeeeeedic
	if (BMO_MedicType[client] != BMO_MEDIGUN_MEDIC && TF2_GetPlayerClass(client) == TFClass_Medic)
	{
		TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
		TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
		new weapon = SpawnWeapon(client, "tf_weapon_crossbow", BMO_CrossbowIdx, 5, 10, BMO_CrossbowArgs);
		if (IsValidEntity(weapon))
		{
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
			new offset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1);
			if (offset >= 0) // set reserve ammo to 38, sometimes it's over 100 coming from a syringe gun
				SetEntProp(client, Prop_Send, "m_iAmmo", 38, 4, offset);
		}
		
		// special message for class change
		if (BMO_MedicType[client] == BMO_NOT_A_MEDIC)
			CPrintToChat(client, BMO_MedicExploitAlert);
		
		return; // just leave. nothing else for us here.
	}

	new weapon=GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
	new index=-1;
	// Primary
	if (!BWO_CheckWeaponOverrides(client, weapon, TFWeaponSlot_Primary) && weapon && IsValidEdict(weapon))
	{
		index=GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		switch(index)
		{
			case 15, 41, 202, 298, 654, 793, 802, 850, 882, 891, 900, 909, 958, 967: // Miniguns
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon=SpawnWeapon(client, "tf_weapon_minigun", index, 5, 10, "375 ; 50");
				CPrintToChat(client, "Minigun:");
				CPrintToChat(client, "{blue}Generate Knockback rage by dealing damage. Use +attack3 when meter is full to use.");
			}
			case 18, 205, 237, 513, 658, 800, 809, 889, 898, 907, 916, 965, 974: // For other rocket launcher reskins
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon=SpawnWeapon(client, "tf_weapon_rocketlauncher", index, 5, 10, "1 ; 0.90 ; 4 ; 2.0 ; 6 ; 0.25 ; 15 ; 1 ; 58 ; 1.5 ; 76 ; 6 ; 135 ; 0.30 ; 232 ; 10 ; 275 ; 1");
				CPrintToChat(client, "Rocket Launcher:");
				CPrintToChat(client, "{blue}+100% Clip Size");
				CPrintToChat(client, "{blue}+75% Faster firing speed");
				CPrintToChat(client, "{blue}+50% self damage push force");
				CPrintToChat(client, "{blue}+500% max primary ammo on wearer");
				CPrintToChat(client, "{blue}-70% Blast Damage from rocket jumps");
				CPrintToChat(client, "{blue}When the medic healing you is killed, you gain mini-crit boost for 10 seconds");
				CPrintToChat(client, "{blue}Wearer never takes fall damage");
				CPrintToChat(client, "{red}-10% Damage Penalty");
				CPrintToChat(client, "{red}No Random Critical Hits");
			}
			case 21, 208, 40, 215, 659, 741, 798, 807, 887, 896, 905, 914, 963, 972, 1146, 30474: // flamethrowers minus phlog
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon=SpawnWeapon(client, "tf_weapon_flamethrower", index, 5, 10, "2 ; 2.0 ; 162 ; 2.0 ; 255 ; 2.5 ; 164 ; 3.0 ; 362 ; 1 ; 173 ; 1.75 ; 178 ; 0.3");
				CPrintToChat(client, "Flamethrower:");
				CPrintToChat(client, "{blue}+100% Damage Bonus");
				CPrintToChat(client, "{blue}+100% Flame Spread Area");
				CPrintToChat(client, "{blue}+150% Airblast Push Force");
				CPrintToChat(client, "{blue}+200% Flame Distance");
				CPrintToChat(client, "{blue}70% Faster Weapon Switch");
				CPrintToChat(client, "{blue}Always crits from behind");
				CPrintToChat(client, "{red}+75% ammo consumed per second");
			}
			case 19, 206, 1007: // Grenade Launcher, Festive Grenade Launcher
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon=SpawnWeapon(client, "tf_weapon_grenadelauncher", index, 5, 10, "2 ; 1.15 ; 4 ; 3 ; 6 ; 0.25 ; 97 ; 0.25 ; 76 ; 4.5 ; 470 ; 0.75");
				CPrintToChat(client, "Grenade Launcher:");
				CPrintToChat(client, "{blue}+15% Damage bonus");
				CPrintToChat(client, "{blue}+200% Clip Size");
				CPrintToChat(client, "{blue}+350% Max Primary Ammo");
				CPrintToChat(client, "{blue}+75% Faster Firing Speed");
				CPrintToChat(client, "{blue}+75% Faster Reload Time");
				CPrintToChat(client, "{red}-25% damage on contact with surfaces");
				
			}
			case 127: // Direct Hit
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon=SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", index, 5, 10, "103 ; 2 ; 114 ; 1 ; 100 ; 0.30 ; 2 ; 1.50 ; 15 ; 1 ; 179 ; 1 ; 488 ; 3 ; 621 ; 0.35 ; 643 ; 0.75 ; 644 ; 10");
				CPrintToChat(client, "Direct Hit:");
				CPrintToChat(client, "{blue}+50% Damage bonus");
				CPrintToChat(client, "{blue}+100% Projectile speed");
				CPrintToChat(client, "{blue}Increased Attack speed while blast jumping");
				CPrintToChat(client, "{blue}Rocket Specialist");
				CPrintToChat(client, "{blue}Clip size increased as you deal damage");
				CPrintToChat(client, "{blue}When the medic healing you is killed, you gain mini-crit boost for 10 seconds");
				CPrintToChat(client, "{blue}Wearer never takes fall damage");
				CPrintToChat(client, "{blue}Minicrits airborne targets");
				CPrintToChat(client, "{blue}Minicrits become crits");
				CPrintToChat(client, "{red}-70% Explosion radius");
				CPrintToChat(client, "{red}No Random Critical Hits");
			}
			case 228, 1085: // Black Box, Festive Black Box
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon=SpawnWeapon(client, "tf_weapon_rocketlauncher", index, 5, 10, "4 ; 1.5 ; 6 ; 0.25 ; 15 ; 1 ; 16 ; 5 ; 58 ; 3 ; 76 ; 3.50 ; 100 ; 0.5 ; 135 ; 0.60 ; 233 ; 1.50 ; 234 ; 1.30");
				CPrintToChat(client, "Black Box:");
				CPrintToChat(client, "{blue}+50% Clip Size");
				CPrintToChat(client, "{blue}On-Hit: +5 Health");
				CPrintToChat(client, "{blue}+75% Faster Firing Speed");
				CPrintToChat(client, "{blue}+200% Self Damage Push Force");
				CPrintToChat(client, "{blue}+250% Max Primary Ammo");
				CPrintToChat(client, "{blue}-40% Blast Damage from rocket jumps");
				CPrintToChat(client, "{blue}While a medic is healing you, this weapon's damage is increased by +50%");
				CPrintToChat(client, "{red}No Random Critical Hits");
				CPrintToChat(client, "{red}-50% Blast Radius");
				CPrintToChat(client, "{red}While not being healed by a medic, your weapon switch time is +30% longer");
			}
			case 308: // Loch & Load
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon=SpawnWeapon(client, "tf_weapon_grenadelauncher", index, 5, 10, "2 ; 1.75 ; 3 ; 0.5 ; 6 ; 0.25 ; 97 ; 0.25 ; 76 ; 3 ; 127 ; 2");
				CPrintToChat(client, "Loch-n-Load:");
				CPrintToChat(client, "{blue}+75% Damage bonus");
				CPrintToChat(client, "{red}-50% Clip Size");
				CPrintToChat(client, "{blue}+200% Max Primary Ammo");
				CPrintToChat(client, "{blue}+75% Faster Firing Speed");
				CPrintToChat(client, "{blue}+75% Faster Reload Time");
				CPrintToChat(client, "{red}Launched bombs shatter on surfaces");
			}
			case 312: // Brass Beast
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon=SpawnWeapon(client, "tf_weapon_minigun", index, 5, 10, "2 ; 1.2 ; 86 ; 1.5 ; 183 ; 0.4 ; 375 ; 50");
				CPrintToChat(client, "Brass Beast:");
				CPrintToChat(client, "{blue}+20% Damage Bonus");
				CPrintToChat(client, "{blue}Generate Knockback rage by dealing damage. Use +attack3 when meter is full to use");
				CPrintToChat(client, "{red}+50% Slower Spin-up Time");
				CPrintToChat(client, "{red}-60% Slower move speed while deployed");
			}
			case 414: // Liberty Launcher
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon=SpawnWeapon(client, "tf_weapon_rocketlauncher", index, 5, 10, "1 ; 0.75 ; 4 ; 1.75 ; 6 ; 0.4 ; 58 ; 3 ; 76 ; 3.50 ; 100 ; 0.85 ; 103 ; 2 ; 135 ; 0.50");
				CPrintToChat(client, "Liberty Launcher:");
				CPrintToChat(client, "{blue}+75% Clip Size");
				CPrintToChat(client, "{blue}+60% Faster Firing Speed");
				CPrintToChat(client, "{blue}+200% Self Damage Push Force");
				CPrintToChat(client, "{blue}+250% Max Primary Ammo");
				CPrintToChat(client, "{red}-25% Damage Penalty");
				CPrintToChat(client, "{red}-50% Blast Damage from rocket jumps");
				CPrintToChat(client, "{red}-15% Blast Radius");
			}
			case 424: // Tomislav
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon=SpawnWeapon(client, "tf_weapon_minigun", index, 5, 10, "5 ; 1.1 ; 87 ; 1.1 ; 238 ; 1 ; 375 ; 50");
				CPrintToChat(client, "Tomislav:");
				CPrintToChat(client, "{blue}+10% Damage Bonus.");
				CPrintToChat(client, "{blue}-10% Faster Spinup Time.");
				CPrintToChat(client, "{blue}No Barrel Spinup Sound");
				CPrintToChat(client, "{blue}Generate Knockback rage by dealing damage. Use +attack3 when meter is full to use");
				CPrintToChat(client, "{red}+20% Slower Firing Speed");
			}
			case 441: //Cow Mangler
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon=SpawnWeapon(client, "tf_weapon_particle_cannon", index, 5, 10, "2 ; 1.5 ; 58 ; 2 ; 281 ; 1 ; 282 ; 1 ; 288 ; 1 ; 366 ; 5");
				CPrintToChat(client, "Cow Mangler:");
				CPrintToChat(client, "{blue}+50% damage bonus");
				CPrintToChat(client, "{blue}+100% Self Damage Push Force");
				CPrintToChat(client, "{blue}No Ammo needed");
				CPrintToChat(client, "{blue}A successful hit mid-air stuns Blitzkrieg for 5 seconds");

			}
			case 730: //Beggar's Bazooka
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon=SpawnWeapon(client, "tf_weapon_rocketlauncher", index, 5, 10, "135 ; 0.25 ; 58 ; 1.5 ; 2 ; 1.1 ; 4 ; 7.5 ; 6 ; 0 ; 76 ; 10 ; 97 ; 0.25 ; 411 ; 15 ; 413 ; 1 ; 417 ; 1");
				CPrintToChat(client, "Beggar's Bazooka:");
				CPrintToChat(client, "{blue}+10% Damage Bonus");
				CPrintToChat(client, "{blue}+650% Clip Size");
				CPrintToChat(client, "{blue}+85% Faster Firing Speed");
				CPrintToChat(client, "{blue}+50% Self Damage Push Force");
				CPrintToChat(client, "{blue}+1000% Max Primary Ammo");
				CPrintToChat(client, "{blue}+75% Faster reload speed");
				CPrintToChat(client, "{blue}-75% Blast Damage from rocket jumps");
				CPrintToChat(client, "{blue}Hold Fire to load up to 30 Rockets");
				CPrintToChat(client, "{red}Overloading will Misfire");
				CPrintToChat(client, "{red}+30 Degrees Random Projectile Deviation");
			}
			case 811, 832: // Huo-Long Heater
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon=SpawnWeapon(client, "tf_weapon_minigun", index, 5, 10, "71 ; 1.25 ; 76 ; 2 ; 206 ; 1.25 ; 375 ; 50 ; 430 ; 1 ; 431 ; 5");
				CPrintToChat(client, "Huo-Long Heater:");
				CPrintToChat(client, "{blue}+10% Max Primary Ammo on-wearer");				
				CPrintToChat(client, "{blue}+25% Afterburn Damage Bonus");
				CPrintToChat(client, "{blue}Sustains a ring of flames while deployed");
				CPrintToChat(client, "{blue}Generate Knockback rage by dealing damage. Use +attack3 when meter is full to use");
				CPrintToChat(client, "{red}Uses +5 Ammo per second while deployed");
				CPrintToChat(client, "{red}+25% damage from melee sources while active");
			}
			case 996: // Loose Cannon
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon=SpawnWeapon(client, "tf_weapon_cannon", index, 5, 10, "2 ; 1.25 ; 4 ; 1.5 ; 6 ; 0.25 ; 97 ; 0.25 ; 76 ; 4 ; 466 ; 1 ; 467 ; 1 ; 470 ; 0.7");
				CPrintToChat(client, "Loose Cannon:");
				CPrintToChat(client, "{blue}+25% Damage bonus");
				CPrintToChat(client, "{blue}+50% Clip Size");
				CPrintToChat(client, "{blue}+300% Max Primary Ammo");
				CPrintToChat(client, "{blue}+75% Faster Firing Speed");
				CPrintToChat(client, "{blue}+75% Faster Reload Time");
				CPrintToChat(client, "{red}-30% damage on contact with surfaces");
				CPrintToChat(client, "{red}Cannonballs have a fuse time of 1 second; fuses can be primed to explode earlier by holding down the fire key.");
				CPrintToChat(client, "{red}Cannonballs do not explode on impact");
			}
			case 1104: // Air Strike
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon=SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", index, 5, 10, "1 ; 0.90 ; 15 ; 1 ; 179 ; 1 ; 232 ; 10 ; 488 ; 3 ; 621 ; 0.35 ; 642 ; 1 ; 643 ; 0.75 ; 644 ; 10");
				CPrintToChat(client, "Air Strike:");
				CPrintToChat(client, "{blue}Increased Attack speed while blast jumping");
				CPrintToChat(client, "{blue}Rocket Specialist");
				CPrintToChat(client, "{blue}Clip size increased as you deal damage");
				CPrintToChat(client, "{blue}When the medic healing you is killed, you gain mini-crit boost for 10 seconds");
				CPrintToChat(client, "{blue}Wearer never takes fall damage");
				CPrintToChat(client, "{red}-10% Damage Penalty");
				CPrintToChat(client, "{red}No Random Critical Hits");
			}
			case 1153: // Panic Attack
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon=SpawnWeapon(client, "tf_weapon_shotgun_primary", index, 5, 10, "61 ; 1.5 ; 63 ; 1.5 ; 65 ; 1.5 ; 97 ; 0.77 ; 107 ; 1.7 ; 128 ; 1 ; 179 ; 1 ; 232 ; 15 ; 394 ; 0.85 ; 651 ; 0.5 ; 708 ; 1 ; 709 ; 1 ; 710 ; 1 ; 711 ; 1");	
				CPrintToChat(client, "Panic Attack (while active):");
				CPrintToChat(client, "{blue}+75& Faster move speed");
				CPrintToChat(client, "{blue}+34% faster reload time");
				CPrintToChat(client, "{blue}When the medic healing you is killed, you gain mini crits for 15 seconds");
				CPrintToChat(client, "{blue}+50% blast, fire & crit damage vulnerability");
				CPrintToChat(client, "{blue}Hold fire to load up to 6 shells");
				CPrintToChat(client, "{blue}Fire rate increases as health decreases");
				CPrintToChat(client, "{red}Weapon spread increases as health decreases");
			}
			case 1151: // Iron Bomber
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon=SpawnWeapon(client, "tf_weapon_grenadelauncher", index, 5, 10, "2 ; 1.10 ; 4 ; 5 ; 6 ; 0.25 ; 97 ; 0.25 ; 76 ; 6 ; 671 ; 1 ; 684 ; 0.6");
				CPrintToChat(client, "Iron Bomber:");
				CPrintToChat(client, "{blue}+10% Damage bonus");
				CPrintToChat(client, "{blue}+400% Clip Size");
				CPrintToChat(client, "{blue}+500% Max Primary Ammo");
				CPrintToChat(client, "{blue}+75% Faster Firing Speed");
				CPrintToChat(client, "{blue}+75% Faster Reload Time");
				CPrintToChat(client, "{red}-40% damage on grenades that explode on timer");
				CPrintToChat(client, "{red}Grenades have very little bound and roll");
			}
		}
	}
	// Secondary
	weapon=GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if (!BWO_CheckWeaponOverrides(client, weapon, TFWeaponSlot_Secondary) && weapon && IsValidEdict(weapon))
	{
		index=GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		switch(index)
		{
			case 39, 351, 740, 1081: // Flaregun, Detonator, Scorch Shot & Festive Flare Gun
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				weapon=SpawnWeapon(client, "tf_weapon_flaregun", index, 5, 10, "25 ; 0.75 ; 65 ; 1.75 ; 207 ; 1.10 ; 144 ; 1 ; 58 ; 4.5 ; 20 ; 1 ; 22 ; 1 ; 551 ; 1 ; 15 ; 1");
				CPrintToChat(client, "Detonator:");
				CPrintToChat(client, "{blue}Crits vs Burning Players");
				CPrintToChat(client, "{blue}+450% self damage push force");
				CPrintToChat(client, "{red}No crits vs non-burning");
				CPrintToChat(client, "{red}No Random Critical Hits");
			}
			case 42, 863, 1002: // Sandvich, Robo-Sandvich & Festive Sandvich
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);					
				weapon=SpawnWeapon(client, "tf_weapon_lunchbox", index, 5, 10, "144 ; 4 ; 278 ; 0.5");
				CPrintToChat(client, "Sandvich:");
				CPrintToChat(client, "{blue}+50% Faster Regen Rate");
			}
			case 129, 1001: // Buff Banner
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				weapon=SpawnWeapon(client, "tf_weapon_buff_item", index, 5, 10, "26 ; 50 ; 116 ; 1 ; 292 ; 51 ; 319 ; 2.50");
				CPrintToChat(client, "Buff Banner:");
				CPrintToChat(client, "{blue}+150% longer buff duration");
				CPrintToChat(client, "{blue}+50% max health");
			}
			case 226: // Battalion's Backup
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				weapon=SpawnWeapon(client, "tf_weapon_buff_item", index, 5, 10, "26 ; 50 ; 116 ; 2 ; 292 ; 51 ; 319 ; 2.50");
				CPrintToChat(client, "Battalion's Backup:");
				CPrintToChat(client, "{blue}+150% longer buff duration");
				CPrintToChat(client, "{blue}+50% max health");
			}
			case 354: // Concheror
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				weapon=SpawnWeapon(client, "tf_weapon_buff_item", index, 5, 10, "26 ; 50 ; 57 ; 3 ; 116 ; 3 ; 292 ; 51 ; 319 ; 2.50");
				CPrintToChat(client, "Concheror:");
				CPrintToChat(client, "{blue}+150% longer buff duration");
				CPrintToChat(client, "{blue}+50% max health");
			}
			case 1153: // Panic Attack
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				switch(TF2_GetPlayerClass(client))
				{
					case TFClass_Soldier:
						weapon=SpawnWeapon(client, "tf_weapon_shotgun_soldier", index, 5, 10, "61 ; 1.5 ; 63 ; 1.5 ; 65 ; 1.5 ; 97 ; 0.77 ; 107 ; 1.7 ; 128 ; 1 ; 179 ; 1 ; 232 ; 15 ; 394 ; 0.85 ; 651 ; 0.5 ; 708 ; 1 ; 709 ; 1 ; 710 ; 1 ; 711 ; 1");
					case TFClass_Pyro:
						weapon=SpawnWeapon(client, "tf_weapon_shotgun_pyro", index, 5, 10, "61 ; 1.5 ; 63 ; 1.5 ; 65 ; 1.5 ; 97 ; 0.77 ; 107 ; 1.7 ; 128 ; 1 ; 179 ; 1 ; 232 ; 15 ; 394 ; 0.85 ; 651 ; 0.5 ; 708 ; 1 ; 709 ; 1 ; 710 ; 1 ; 711 ; 1");
					case TFClass_Heavy:
						weapon=SpawnWeapon(client, "tf_weapon_shotgun_hwg", index, 5, 10, "61 ; 1.5 ; 63 ; 1.5 ; 65 ; 1.5 ; 97 ; 0.77 ; 107 ; 1.7 ; 128 ; 1 ; 179 ; 1 ; 232 ; 15 ; 394 ; 0.85 ; 651 ; 0.5 ; 708 ; 1 ; 709 ; 1 ; 710 ; 1 ; 711 ; 1");
					default: // For Randomizer Compatibility
						weapon=SpawnWeapon(client, "tf_weapon_shotgun_soldier", index, 5, 10, "61 ; 1.5 ; 63 ; 1.5 ; 65 ; 1.5 ; 97 ; 0.77 ; 107 ; 1.7 ; 128 ; 1 ; 179 ; 1 ; 232 ; 15 ; 394 ; 0.85 ; 651 ; 0.5 ; 708 ; 1 ; 709 ; 1 ; 710 ; 1 ; 711 ; 1");
				}
				CPrintToChat(client, "Panic Attack (while active):");
				CPrintToChat(client, "{blue}+75& Faster move speed");
				CPrintToChat(client, "{blue}+34% faster reload time");
				CPrintToChat(client, "{blue}When the medic healing you is killed, you gain mini crits for 15 seconds");
				CPrintToChat(client, "{blue}+50% blast, fire & crit damage vulnerability");
				CPrintToChat(client, "{blue}Hold fire to load up to 6 shells");
				CPrintToChat(client, "{blue}Fire rate increases as health decreases");
				CPrintToChat(client, "{red}Weapon spread increases as health decreases");
			}
			case 29, 35, 211, 411, 663, 796, 805, 885, 894, 903, 912, 961, 970, 998:
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				SpawnWeapon(client, "tf_weapon_medigun", index, 5, 10, "499 ; 50.0 ; 10 ; 1.25 ; 178 ; 0.75 ; 144 ; 2.0 ; 11 ; 1.5 ; 482 ; 3 ; 493 ; 3");
				CPrintToChat(client, "Medigun:");
				CPrintToChat(client, "{blue}Use +attack3 (default middle mouse button) to deploy projectile shield");
				CPrintToChat(client, "{blue}Overheal Expert applied");
				CPrintToChat(client, "{blue}Healing Mastery applied");
				CPrintToChat(client, "{blue}+25% faster charge rate");
				CPrintToChat(client, "{blue}+25% faster weapon switch");
				CPrintToChat(client, "{blue}+50% overheal bonus");
				Blitz_VerifyMedigunAt[client] = GetEngineTime() + 3.0;
			}
		}
	}
	// Melee Weapons
	weapon=GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	if (!BWO_CheckWeaponOverrides(client, weapon, TFWeaponSlot_Melee) && weapon && IsValidEdict(weapon))
	{
		index=GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		switch(index)
		{
			case 44:
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
				SpawnWeapon(client, "tf_weapon_bat_wood", index, 5, 10, "38 ; 1 ; 125 ; -15 ; 278 ; 1.5 ; 279 ; 5.0");
				CPrintToChat(client, "Sandman:");	
				CPrintToChat(client, "{blue}+400% Max Misc Ammo");	
				CPrintToChat(client, "{blue}+50% Faster Recharge Rate");	
				CPrintToChat(client, "{blue}Alt-fire to launch baseball");			
				CPrintToChat(client, "{red}-15% Max Health");
				SetAmmo(client, TFWeaponSlot_Melee, 5);
			}
			
			// Temporarily disabled Wrap Assassin due to some issues regarding insta-killing Blitz.
			/*case 648:
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
				SpawnWeapon(client, "tf_weapon_bat_giftwrap", index, 5, 10, "1 , 0.3 ; 346 ; 1 ; 278 ; 1.5 ; 279 ; 5.0");
				CPrintToChat(client, "Wrap Assassin:");	
				CPrintToChat(client, "{blue}+400% Max Misc Ammo");	
				CPrintToChat(client, "{blue}+50% Faster Recharge Rate");	
				CPrintToChat(client, "{blue}Alt-fire to launch ornament");			
				CPrintToChat(client, "{red}-70% Damage Penalty");
				SetAmmo(client, TFWeaponSlot_Melee, 5);
			}*/
		}
	}
	// Build PDA
	weapon=GetPlayerWeaponSlot(client, 3);
	if(weapon && IsValidEdict(weapon))
	{
		index=GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		switch(index)
		{
			case 25, 737:
			{
				TF2_RemoveWeaponSlot(client, 3);
				SpawnWeapon(client, "tf_weapon_pda_engineer_build", index, 5, 10, "113 ; 10 ; 276 ; 1 ; 286 ; 2.25 ; 287 ; 1.25 ; 321 ; 0.70 ; 345 ; 4");
				CPrintToChat(client, "Construction PDA:");
				CPrintToChat(client, "{blue}Teleporters are bi-directional");
				CPrintToChat(client, "{blue}+10 Metal regenerated every 5 seconds");
				CPrintToChat(client, "{blue}+300% Dispenser range");
				CPrintToChat(client, "{blue}+30% Faster build speed");
				CPrintToChat(client, "{blue}+150% Building Health");
				CPrintToChat(client, "{blue}+25% Faster sentry firing speed");
				CPrintToChat(client, "{blue}+25% Sentry damage bonus");
			}
		}
	}
	if(TF2_GetPlayerClass(client) == TFClass_Scout || TF2_GetPlayerClass(client) == TFClass_Spy)
		TF2_AddCondition(client, TFCond:TFCond_CritCanteen, TFCondDuration_Infinite);
		
	// special logic for wearables and demo wearables
	if (BWO_ActiveThisRound) for (new pass = 0; pass <= 1; pass++)
	{
		static String:classname[MAX_ENTITY_CLASSNAME_LENGTH];
		if (pass == 0)
			classname = "tf_wearable";
		else
			classname = "tf_wearable_demoshield";
		
		new wearable = MAX_PLAYERS;
		while ((wearable = FindEntityByClassname(wearable, classname)) != -1)
		{
			if (client == GetEntPropEnt(wearable, Prop_Send, "m_hOwnerEntity"))
				if (BWO_CheckWeaponOverrides(client, wearable, -1))
					break; // easy way to avoid eating up all edicts. also, assuming each player only has stat-infused wearable.
		}
	}
}

public HealPlayer(clientIdx)
{
	// damnit valve, why is max health so useless.
	// gotta go with the hack fix instead
	new maxHealth = GetEntProp(clientIdx, Prop_Data, "m_iMaxHealth");
	maxHealth += 100;
	SetEntProp(clientIdx, Prop_Send, "m_iHealth", maxHealth);
	SetEntProp(clientIdx, Prop_Data, "m_iHealth", maxHealth);
}

// Teleport Event
Teleport_Me(client)
{
	decl Float:pos_2[3];
	decl target;
	new teleportme;
	new bool:AlivePlayers;
	for(new ii=1;ii<=MaxClients;ii++)
	if(IsValidEdict(ii) && IsClientInGame(ii) && IsPlayerAlive(ii) && GetClientTeam(ii)!=FF2_GetBossTeam())
	{
		AlivePlayers=true;
		break;
	}
	do
	{
		teleportme++;
		target=GetRandomInt(1,MaxClients);
		if (teleportme==100)
			return;
	}
	while (AlivePlayers && (!IsValidEdict(target) || (target==client) || !IsPlayerAlive(target)));
	
	if (IsValidEdict(target))
	{
		GetEntPropVector(target, Prop_Data, "m_vecOrigin", pos_2);
		GetEntPropVector(target, Prop_Send, "m_vecOrigin", pos_2);
		if (GetEntProp(target, Prop_Send, "m_bDucked"))
		{
			decl Float:collisionvec[3];
			collisionvec[0] = 24.0;
			collisionvec[1] = 24.0;
			collisionvec[2] = 62.0;
			SetEntPropVector(client, Prop_Send, "m_vecMaxs", collisionvec);
			SetEntProp(client, Prop_Send, "m_bDucked", 1);
			SetEntityFlags(client, FL_DUCKING);
		}
		TeleportEntity(client, pos_2, NULL_VECTOR, NULL_VECTOR);
	}
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
	
	// sarysa - another feature of my fork, mainly because I can't have intrusive command additions in my submission.
	//new Handle:panel=CreatePanel();
	//SetPanelTitle(panel, text);
	//DrawPanelItem(panel, "Exit");
	//SendPanelToClient(panel, client, HintPanelH, 20);
	//CloseHandle(panel);
	
	CPrintToChat(client, text);
}

public HintPanelH(Handle:menu, MenuAction:action, client, selection)
{
	if(IsValidClient(client) && (action==MenuAction_Select || (action==MenuAction_Cancel && selection==MenuCancel_Exit)))
	{
		CPrintToChat(client, BS_GoodLuck);
	}
}


// ESSENTIAL CODE TO GET THE REANIMATOR WORKING
stock DropReanimator(client) 
{
	new clientTeam = GetClientTeam(client);
	new marker = CreateEntityByName("entity_revive_marker");
	if (marker != -1)
	{
		SetEntPropEnt(marker, Prop_Send, "m_hOwner", client); // client index 
		SetEntProp(marker, Prop_Send, "m_nSolidType", 2); 
		SetEntProp(marker, Prop_Send, "m_usSolidFlags", 8); 
		SetEntProp(marker, Prop_Send, "m_fEffects", 16); 	
		SetEntProp(marker, Prop_Send, "m_iTeamNum", clientTeam); // client team 
		SetEntProp(marker, Prop_Send, "m_CollisionGroup", 1); 
		SetEntProp(marker, Prop_Send, "m_bSimulatedEveryTick", 1); 
		SetEntProp(marker, Prop_Send, "m_nBody", _:TF2_GetPlayerClass(client) - 1); 
		SetEntProp(marker, Prop_Send, "m_nSequence", 1); 
		SetEntPropFloat(marker, Prop_Send, "m_flPlaybackRate", 1.0);  
		SetEntProp(marker, Prop_Data, "m_iInitialTeamNum", clientTeam);
		SetEntDataEnt2(client, FindSendPropInfo("CTFPlayer", "m_nForcedSkin")+4, marker);
		if(GetClientTeam(client) == 3)
			SetEntityRenderColor(marker, 0, 0, 255); // make the BLU Revive Marker distinguishable from the red one
		DispatchSpawn(marker);
		reviveMarker[client] = EntIndexToEntRef(marker);
		Blitz_MoveReviveMarkerAt[client] = GetEngineTime() + 0.01;
		Blitz_RemoveReviveMarkerAt[client] = GetEngineTime() + decaytime;
		
		if (PRINT_DEBUG_SPAM)
			PrintToServer("[%d] Marker created at %f", client, GetEngineTime());
	} 
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

stock RemoveReanimator(client)
{
	if (reviveMarker[client] != INVALID_ENTREF && reviveMarker[client] != 0) // second call needed due to slim possibility of it being uninitialized, thus the world
	{
		currentTeam[client] = GetClientTeam(client);
		ChangeClass[client] = false;
		new marker = EntRefToEntIndex(reviveMarker[client]);
		if (IsValidEntity(marker) && marker >= MAX_PLAYERS)
			AcceptEntityInput(marker, "Kill");
		
		if (PRINT_DEBUG_SPAM)
			PrintToServer("[%d] Marker destroyed at %f", client, GetEngineTime());
	}
	Blitz_RemoveReviveMarkerAt[client] = FAR_FUTURE;
	Blitz_MoveReviveMarkerAt[client] = FAR_FUTURE;
	reviveMarker[client] = INVALID_ENTREF;
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
	CreateTimer(0.5, CheckAbility, userid, TIMER_FLAG_NO_MAPCHANGE);
	if(blitzisboss && allowrevive != 0)
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
		
		if (RoundInProgress)
			Blitz_ReverifyWeaponsAt[clientIdx] = GetEngineTime() + 0.5; // setting this high so VSP's weapon swapper can go first
	}
	return Plugin_Continue;
}

public Action:CheckAbility(Handle:hTimer, any:userid) // Now we actually check for abilities
{
	new clientIdx=GetClientOfUserId(userid);
	new bossIdx=FF2_GetBossIndex(clientIdx);
	if(FF2_HasAbility(bossIdx, this_plugin_name, "blitzkrieg_config"))
	{
		blitzisboss = true;
		Blitz_AddHooks();
		bRdm = false;
		barrage = false;

		// Intro BGM
		if (!(FF2_HasAbility(bossIdx, this_plugin_name, BMO_STRING) && (BMO_NoIntroOutroSounds = FF2_GetAbilityArgument(bossIdx, this_plugin_name, BMO_STRING, 7)) != 0))
			EmitSoundToAll(BLITZROUNDSTART);
		
		// sarysa - the custom weapons code here never executed. it also made no sense. so I've removed it.
	}
}

public Action:OnPlayerInventory(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(blitzisboss)
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		if(customweapons)
		{
			if(IsLivingPlayer(client) && GetClientTeam(client)!=FF2_GetBossTeam())
			{		
				//CheckWeapons(client);
				PlayerHelpPanel(client);
			}
		}
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
		if(allowrevive!=0)
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

// Notification System:

public Action:CheckLevel(client, const String:command[], argc)
{
	if(blitzisboss)
	{
		DisplayCurrentDifficulty(client);
		return Plugin_Handled;
	}
	return Plugin_Continue;
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

DisplayCurrentDifficulty(client)
{
	new String:msg[1024], String:spcl[768], String:bDiff[100];
	new d_Boss=GetClientOfUserId(FF2_GetBossUserId(client));
	FF2_GetBossSpecial(d_Boss, spcl, sizeof(spcl));
	switch(weapondifficulty)
	{	
		case 0: bDiff="BAKA!!!!!";
		case 1: bDiff="Easy";
		case 2: bDiff="Normal";
		case 3: bDiff="Intermediate";
		case 4: bDiff="Difficult";
		case 5: bDiff="Lunatic";
		case 6: bDiff="Insane";
		case 7: bDiff="Godlike";
		case 8: bDiff="Rocket Hell";
		case 9: bDiff="Total Blitzkrieg";
		case 420: 
		{
			bDiff="SMOKE W33D ERRYDAY!";
			EmitSoundToAll(SM0K3W33D);
			EmitSoundToAll(SM0K3W33D);
		}
		case 777: bDiff="RAVIOLI RAVIOLI";
		case 999: bDiff="D0NUT ST33L";
		case 1337: 
		{
			bDiff="LOOMYNARTY";
			if(LoomynartyMusic)
			{
				EmitSoundToAll(L00MYNARTY);
				EmitSoundToAll(L00MYNARTY);
				LoomynartyMusic = false;
			}
		}
		case 9001:
		{
			bDiff="OVER 9000!";
			EmitSoundToAll(OVER_9000);
			EmitSoundToAll(OVER_9000);
		}
		default: Format(bDiff, sizeof(bDiff), "RNG Level %i", weapondifficulty);
	}
	switch(weapondifficulty)
	{
		case 0:
		{
			msg = BS_BlitzInactive;
			CPrintToChatAll(BS_BlitzInactive2);
		}
		default:
		{
			Format(msg, sizeof(msg), BS_BlitzDifficulty, spcl, bDiff);
			CPrintToChatAll(BS_BlitzDifficulty2, spcl, bDiff);
		}
	}
	ShowGameText(msg);
}

ShowGameText(const String:strMessage[]) 
{
    new iEntity = CreateEntityByName("game_text_tf");
    DispatchKeyValue(iEntity,"message", strMessage);
    DispatchKeyValue(iEntity,"display_to_team", "0");
    DispatchKeyValue(iEntity,"icon", "ico_notify_on_fire");
    DispatchKeyValue(iEntity,"targetname", "game_text1");
    DispatchKeyValue(iEntity,"background", "0");
    DispatchSpawn(iEntity);
    AcceptEntityInput(iEntity, "Display", iEntity, iEntity);
    CreateTimer(2.5, KillGameText, EntIndexToEntRef(iEntity), TIMER_FLAG_NO_MAPCHANGE);
}

public Action:KillGameText(Handle:hTimer, any:iEntityRef) 
{
	new iEntity = EntRefToEntIndex(iEntityRef);
	if ((iEntity > 0) && IsValidEntity(iEntity))
		AcceptEntityInput(iEntity, "kill"); 
	return Plugin_Stop;
}



// Stocks
stock SpawnRocketLauncher(client,String:name[],index,level,qual,String:att[])
{
	return SpawnWeapon(client, name, index, level, qual, att, true);
}

stock SpawnWeapon(client,String:name[],index,level,qual,String:att[], bool:isRocketLauncher = false)
{
	new Handle:hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	TF2Items_SetClassname(hWeapon, name);
	TF2Items_SetItemIndex(hWeapon, index);
	TF2Items_SetLevel(hWeapon, level);
	TF2Items_SetQuality(hWeapon, qual);
	new String:atts[32][32];
	new count = ExplodeString(att, " ; ", atts, 32, 32);
	
	// additions for rocket launchers
	if (BMO_ActiveThisRound && isRocketLauncher)
	{
		// add rocket radius mod
		if (count <= 30)
		{
			new Float:radius = 1.0;
			if(weapondifficulty >= 1 && weapondifficulty <= 11)
				radius = BMO_RocketRadius[weapondifficulty-1];
			else if(weapondifficulty >=12  && weapondifficulty <= 420)
				radius = BMO_RocketRadius[10];
			else if(weapondifficulty >=421  && weapondifficulty <= 777)
				radius = BMO_RocketRadius[11];
			else if(weapondifficulty >=778  && weapondifficulty <= 999)
				radius = BMO_RocketRadius[12];
			else if(weapondifficulty >=1000  && weapondifficulty <= 1337)
				radius = BMO_RocketRadius[13];
			else if(weapondifficulty >=1338  && weapondifficulty <= 9001)
				radius = BMO_RocketRadius[14];
			
			if (BMO_Flags & BMO_FLAG_STACK_RADIUS)
			{
				if (StrContains(name, "directhit") >= 0)
					radius *= 0.3;
				else if (StrContains(name, "airstrike") >= 0)
					radius *= 0.85;
			}
			
			if (radius != 1.0)
			{
				atts[count] = (radius > 1.0 ? "99" : "100");
				Format(atts[count+1], 32, "%f", radius);
				count += 2;
			}
		}
	}
	
	if (count > 0)
	{
		TF2Items_SetNumAttributes(hWeapon, count/2);
		new i2 = 0;
		for (new i = 0; i < count; i+=2)
		{
			TF2Items_SetAttribute(hWeapon, i2, StringToInt(atts[i]), StringToFloat(atts[i+1]));
			i2++;
		}
	}
	else
		TF2Items_SetNumAttributes(hWeapon, 0);
	if (hWeapon==INVALID_HANDLE)
		return -1;
	new entity = TF2Items_GiveNamedItem(client, hWeapon);
	CloseHandle(hWeapon);
	
	if (StrContains(name, "tf_wearable") != 0)
		EquipPlayerWeapon(client, entity);
	else
		Wearable_EquipWearable(client, entity);
	return entity;
}

stock SetAmmo(client, slot, ammo)
{
	new weapon = GetPlayerWeaponSlot(client, slot);
	if (IsValidEntity(weapon))
	{
		new iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		new iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		SetEntData(client, iAmmoTable+iOffset, ammo, 4, true);
	}
}

stock bool:IsValidClient(client)
{
	if (client <= 0 || client > MaxClients) return false;
	if (!IsClientInGame(client)) return false;
	if (!IsClientConnected(client)) return false;
	if (IsClientSourceTV(client) || IsClientReplay(client)) return false;
	return true;
}

public Action:OnAnnounce(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(blitzisboss)
	{
		new String:strAudio[40];
		GetEventString(event, "sound", strAudio, sizeof(strAudio));
		if(strncmp(strAudio, "Game.Your", 9) == 0 || strcmp(strAudio, "Game.Stalemate") == 0)
		{
			if (!BMO_NoIntroOutroSounds)
				EmitSoundToAll(BLITZROUNDEND);
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
	if (customweapons && IsLivingPlayer(dBoss) && BMO_ActiveThisRound && (BMO_NormalMedicLimit > 0 || BMO_MedicLimitPercent > 0.0))
	{
		new count = 0;
		new totalPlayerCount = 0;
		static bool:isMedigunMedic[MAX_PLAYERS_ARRAY];
		for (new clientIdx = 1; clientIdx < MAX_PLAYERS; clientIdx++)
		{
			isMedigunMedic[clientIdx] = false;
			BMO_MedicType[clientIdx] = BMO_NOT_A_MEDIC;
			if (!IsLivingPlayer(clientIdx) || GetClientTeam(clientIdx) == GetClientTeam(dBoss))
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
		if(blitzisboss && customweapons)
		{
			if(IsLivingPlayer(client) && GetClientTeam(client)!=FF2_GetBossTeam())
			{
				//TF2_RegeneratePlayer(client);
				CheckWeapons(client);
				HealPlayer(client);
				if(!IsFakeClient(client))
					PlayerHelpPanel(client);
			}
		}
	}
}

public OnPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	// ensure we should be doing any of this at all
	if (!blitzisboss || !IsLivingPlayer(dBoss))
		return;

	new attacker=GetClientOfUserId(GetEventInt(event, "attacker"));
	new victim=GetClientOfUserId(GetEventInt(event, "userid"));
	if (victim == dBoss)
		return; // sarysa, fix an error when the hale loses
		
	if ((GetEventInt(event, "death_flags") & TF_DEATHFLAG_DEADRINGER) != 0)
		return; // sarysa, fix an error where dead ringer drops a revive marker
		
	new String:weapon[50];
	GetEventString(event, "weapon", weapon, sizeof(weapon));
	
	new bossIdx = 0;

	// allow revive for victim regardless of cause of death
	if (allowrevive!=0 && FF2_GetBossIndex(victim) == -1)
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
	if (attacker == dBoss)
	{
		if (StrEqual(weapon, "tf_projectile_rocket", false)||StrEqual(weapon, "airstrike", false)||StrEqual(weapon, "liberty_launcher", false)||StrEqual(weapon, "quake_rl", false)||StrEqual(weapon, "blackbox", false)||StrEqual(weapon, "dumpster_device", false)||StrEqual(weapon, "rocketlauncher_directhit", false)||StrEqual(weapon, "flamethrower", false))
			SetEventString(event, "weapon", "firedeath");
		else
			SetEventString(event, "weapon", "saw_kill");

		new Float:rageonkill = FF2_GetAbilityArgumentFloat(bossIdx,this_plugin_name,"blitzkrieg_config",13,0.0);
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
			if(combatstyle)
			{	
				TF2_RemoveWeaponSlot(attacker, TFWeaponSlot_Primary);
				RandomDanmaku(attacker, weapondifficulty);
				SetAmmo(attacker, TFWeaponSlot_Primary, (barrage == true ? blitzkriegrage : 999999));
			}		
		}
	}
}	


DropReviveMarker(client)
{
	switch(allowrevive)
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
			static revivecount[MAXPLAYERS+1] = 0;
			if(revivecount[client] >= allowrevive)
			{
				PrintHintText(client, "You have exceeded the amount of times you can be revived");
				revivecount[client] = 0;
			}
			else
			{
				DropReanimator(client);
				revivecount[client]++;
				PrintHintText(client, "You have used %i of %i revive marker drops", revivecount[client], allowrevive);
			}
		}
	}
}


public WhatWereYouThinking()
{
	new String:BlitzAlert[PLATFORM_MAX_PATH];
	strcopy(BlitzAlert, PLATFORM_MAX_PATH, BlitzCanLvlUp[GetRandomInt(0, sizeof(BlitzCanLvlUp)-1)]);
	if ((BMO_Flags & BMO_FLAG_NO_BEGIN_ADMIN_MESSAGES) == 0)
		EmitSoundToAll(BlitzAlert);
}

public Action:RoundResultSound(Handle:hTimer, any:userid)
{
	new String:BlitzRoundResult[PLATFORM_MAX_PATH];
	if (BlitzIsWinner)
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
	BlitzIsWinner = false;
}

public Action:FF2_OnTriggerHurt(userid,triggerhurt,&Float:damage)
{
	if(FF2_HasAbility(userid, this_plugin_name, "blitzkrieg_config"))
	{
		new Boss=GetClientOfUserId(FF2_GetBossUserId(userid));
		new Float:bRage = FF2_GetBossCharge(Boss,0);
		if(bRage<100)
			FF2_SetBossCharge(Boss, 0, bRage+25.0);
		Teleport_Me(Boss);
		TF2_StunPlayer(Boss, 4.0, 0.0, TF_STUNFLAGS_LOSERSTATE, Boss);
	}
	return Plugin_Continue;
}

public ItzBlitzkriegTime(Boss)
{
	if(combatstyle)
	{
		TF2_RemoveWeaponSlot(Boss, TFWeaponSlot_Primary);
		RandomDanmaku(Boss, weapondifficulty);	
		SetAmmo(Boss, TFWeaponSlot_Primary,999999);
	}
	barrage=false;
}

public RemoveUber(Boss)
{
	SetEntProp(Boss, Prop_Data, "m_takedamage", 2);
	TF2_AddCondition(Boss, TFCond_UberchargeFading, 3.0);
}

/**
 * Blitzkrieg Main Code Appends
 */
public Blitz_Tick(Float:curTime)
{
	if (curTime >= Blitz_EndCrocketHellAt)
	{
		ItzBlitzkriegTime(dBoss);
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
		RemoveUber(dBoss);
		Blitz_RemoveUberAt = FAR_FUTURE;
	}
	
	for (new clientIdx = 1; clientIdx < MAX_PLAYERS; clientIdx++)
	{
		if (curTime >= Blitz_MoveReviveMarkerAt[clientIdx])
			MoveMarker(clientIdx); // will also reset the timer

		if (curTime >= Blitz_RemoveReviveMarkerAt[clientIdx])
			RemoveReanimator(clientIdx); // will also reset the timer
		else if (Blitz_RemoveReviveMarkerAt[clientIdx] != FAR_FUTURE)
		{
			if (!IsLivingPlayer(dBoss) || GetClientTeam(clientIdx) == GetClientTeam(dBoss) || GetClientTeam(clientIdx) < 2)
				RemoveReanimator(clientIdx);
			else if (reviveMarker[clientIdx] == INVALID_ENTREF) // something weird happened
				DropReanimator(clientIdx);
		}
			
		// everything below requires the player to be alive
		if (!IsLivingPlayer(clientIdx))
			continue;
		
		if ((GetEntityFlags(clientIdx) & FL_DUCKING) == 0)
			GetEntPropVector(clientIdx, Prop_Send, "m_vecOrigin", Blitz_LastPlayerPos[clientIdx]);
			
		if (curTime >= Blitz_ReverifyWeaponsAt[clientIdx])
		{
			Blitz_ReverifyWeaponsAt[clientIdx] = FAR_FUTURE;
			//TF2_RegeneratePlayer(clientIdx);
			CheckWeapons(clientIdx);
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
		if (IsLivingPlayer(attacker) && TF2_GetPlayerClass(attacker) == TFClass_DemoMan)
		{
			if (IsValidEntity(weapon) && IsInstanceOf(weapon, "tf_weapon_sword"))
				IncrementHeadCount(attacker);
		}
	}

	if (IsLivingPlayer(attacker) && attacker == dBoss)
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
			if (owner == dBoss)
			{
				if (BMO_ModelOverrideIdx != -1)
					SetEntProp(rocket, Prop_Send, "m_nModelIndex", BMO_ModelOverrideIdx);
					
				// try teleporting it just a little and maybe the trail won't follow
				// failed, but I may as well log my attempts. also, can't PreThink and Think was worse.
				//static Float:rocketPos[3];
				//GetEntPropVector(rocket, Prop_Send, "m_vecOrigin", rocketPos);
				//rocketPos[2] += 0.01;
				//TeleportEntity(rocket, rocketPos, NULL_VECTOR, NULL_VECTOR);
					
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
	
	if (curTime >= BMO_RoundEndsAt && IsLivingPlayer(dBoss))
	{
		ForcePlayerSuicide(dBoss);
	}
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
		
		rBounce[entity] = 0;
		if(rMaxBounces == -1)
			rMaxBounces = GetRandomInt(0,15); // RNG :3
		rMaxBounceCount[entity] = rMaxBounces;
		SDKHook(entity, SDKHook_StartTouch, OnStartTouch);
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
	if (IsLivingPlayer(entity) && GetClientTeam(entity) != GetClientTeam(SPT_Player))
		return true;
	else if (IsLivingPlayer(entity))
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
	if (!IsLivingPlayer(clientIdx) || !SPT_CanUse[clientIdx])
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
	if (BMO_ActiveThisRound)
		BMO_OnEntityCreated(entity, classname);
}

/**
 * sarysa's stocks below
 */
stock ReadCenterText(bossIdx, const String:ability_name[], argInt, String:centerText[MAX_CENTER_TEXT_LENGTH])
{
	FF2_GetAbilityArgumentString(bossIdx, this_plugin_name, ability_name, argInt, centerText, MAX_CENTER_TEXT_LENGTH);
	ReplaceString(centerText, MAX_CENTER_TEXT_LENGTH, "\\n", "\n");
}

stock ReadSound(bossIdx, const String:ability_name[], argInt, String:soundFile[MAX_SOUND_FILE_LENGTH])
{
	FF2_GetAbilityArgumentString(bossIdx, this_plugin_name, ability_name, argInt, soundFile, MAX_SOUND_FILE_LENGTH);
	if (strlen(soundFile) > 3)
		PrecacheSound(soundFile);
}

stock bool:IsLivingPlayer(clientIdx)
{
	if (clientIdx <= 0 || clientIdx >= MAX_PLAYERS)
		return false;
		
	return IsClientInGame(clientIdx) && IsPlayerAlive(clientIdx);
}

stock ParticleEffectAt(Float:position[3], String:effectName[], Float:duration = 0.1)
{
	if (IsEmptyString(effectName))
		return -1; // nothing to display
		
	new particle = CreateEntityByName("info_particle_system");
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

public Action:RemoveEntity(Handle:timer, any:entid)
{
	new entity = EntRefToEntIndex(entid);
	if (IsValidEdict(entity) && entity > MaxClients)
		AcceptEntityInput(entity, "Kill");
}

stock ReadHexOrDecInt(String:hexOrDecString[HEX_OR_DEC_STRING_LENGTH])
{
	if (StrContains(hexOrDecString, "0x") == 0)
	{
		new result = 0;
		for (new i = 2; i < 10 && hexOrDecString[i] != 0; i++)
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

stock ReadHexOrDecString(bossIdx, const String:ability_name[], argIdx)
{
	static String:hexOrDecString[HEX_OR_DEC_STRING_LENGTH];
	FF2_GetAbilityArgumentString(bossIdx, this_plugin_name, ability_name, argIdx, hexOrDecString, HEX_OR_DEC_STRING_LENGTH);
	return ReadHexOrDecInt(hexOrDecString);
}

stock ReadModelToInt(bossIdx, const String:ability_name[], argInt)
{
	static String:modelFile[MAX_MODEL_FILE_LENGTH];
	FF2_GetAbilityArgumentString(bossIdx, this_plugin_name, ability_name, argInt, modelFile, MAX_MODEL_FILE_LENGTH);
	if (strlen(modelFile) > 3)
		return PrecacheModel(modelFile);
	return -1;
}

stock GetA(c) { return abs(c>>24); }
stock GetR(c) { return abs((c>>16)&0xff); }
stock GetG(c) { return abs((c>>8 )&0xff); }
stock GetB(c) { return abs((c    )&0xff); }

stock abs(x)
{
	return x < 0 ? -x : x;
}

stock Float:fabs(Float:x)
{
	return x < 0 ? -x : x;
}

stock min(n1, n2)
{
	return n1 < n2 ? n1 : n2;
}

stock Float:fmin(Float:n1, Float:n2)
{
	return n1 < n2 ? n1 : n2;
}

stock max(n1, n2)
{
	return n1 > n2 ? n1 : n2;
}

stock Float:fmax(Float:n1, Float:n2)
{
	return n1 > n2 ? n1 : n2;
}

stock constrainDistance(const Float:startPoint[], Float:endPoint[], Float:distance, Float:maxDistance)
{
	new Float:constrainFactor = maxDistance / distance;
	endPoint[0] = ((endPoint[0] - startPoint[0]) * constrainFactor) + startPoint[0];
	endPoint[1] = ((endPoint[1] - startPoint[1]) * constrainFactor) + startPoint[1];
	endPoint[2] = ((endPoint[2] - startPoint[2]) * constrainFactor) + startPoint[2];
}

stock Nope(clientIdx)
{
	EmitSoundToClient(clientIdx, NOPE_AVI);
}

stock bool:IsInstanceOf(entity, const String:desiredClassname[])
{
	static String:classname[MAX_ENTITY_CLASSNAME_LENGTH];
	GetEntityClassname(entity, classname, MAX_ENTITY_CLASSNAME_LENGTH);
	return strcmp(classname, desiredClassname) == 0;
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
	if (IsLivingPlayer(entity))
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

/**
 * Stuff from FF2 retooled for VSP
 */
new Handle:S93SF_equipWearable = INVALID_HANDLE;
stock Wearable_EquipWearable(client, wearable)
{
	if(S93SF_equipWearable==INVALID_HANDLE)
	{
		new Handle:config=LoadGameConfigFile("equipwearable");
		if(config==INVALID_HANDLE)
		{
			LogError("[FF2] EquipWearable gamedata could not be found; make sure /gamedata/equipwearable.txt exists.");
			return;
		}

		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(config, SDKConf_Virtual, "EquipWearable");
		CloseHandle(config);
		PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
		if((S93SF_equipWearable=EndPrepSDKCall())==INVALID_HANDLE)
		{
			LogError("[FF2] Couldn't load SDK function (CTFPlayer::EquipWearable). SDK call failed.");
			return;
		}
	}
	SDKCall(S93SF_equipWearable, client, wearable);
} 

new Handle:S93SF_isWearable = INVALID_HANDLE;
stock Wearable_IsWearable(wearable)
{
	if(S93SF_isWearable==INVALID_HANDLE)	
	{
		new Handle:config=LoadGameConfigFile("equipwearable");
		if(config==INVALID_HANDLE)
		{
			LogError("[FF2] EquipWearable gamedata could not be found; make sure /gamedata/equipwearable.txt exists.");
			return false;
		}

		StartPrepSDKCall(SDKCall_Entity);
		PrepSDKCall_SetFromConf(config, SDKConf_Virtual, "IsWearable");
		CloseHandle(config);
		PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
		if((S93SF_isWearable=EndPrepSDKCall())==INVALID_HANDLE)
		{
			LogError("[FF2] Couldn't load SDK function (CTFPlayer::IsWearable). SDK call failed.");
			return false;
		}
	}
	return SDKCall(S93SF_isWearable, wearable);
}

stock IncrementHeadCount(client)
{
	if(!TF2_IsPlayerInCondition(client, TFCond_DemoBuff))
	{
		TF2_AddCondition(client, TFCond_DemoBuff, -1.0);
	}
	new decapitations=GetEntProp(client, Prop_Send, "m_iDecapitations");
	SetEntProp(client, Prop_Send, "m_iDecapitations", decapitations+1);
	new health=GetClientHealth(client);
	SetEntProp(client, Prop_Data, "m_iHealth", health+15);
	SetEntProp(client, Prop_Send, "m_iHealth", health+15);
	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.01);
}

public Action:OnStartTouch(entity, other)
{
	if (other > 0 && other <= MaxClients)
		return Plugin_Continue;
	if(!blitzisboss)
		return Plugin_Continue;
	if(FF2_GetBossIndex(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity")) == -1)
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
	if (RoundInProgress && customweapons && IsValidEntity(weapon) && FF2_GetBossIndex(client)==-1)
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

	if (FF2_GetBossIndex(client)==-1) ClientCommand(client, "playgamesound \"%s\"", "player\\taunt_clip_spin.wav");

	RequestFrame(Timer_NoAttacking, EntIndexToEntRef(weapon));
	// CreateTimer(0.0, Timer_NoAttacking, EntIndexToEntRef(weapon), TIMER_FLAG_NO_MAPCHANGE);
}

stock SetNextAttack(weapon, Float:duration = 0.0)
{
	if (weapon <= MaxClients) return;
	if (!IsValidEntity(weapon)) return;
	new Float:next = GetGameTime() + duration;
	SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", next);
	SetEntPropFloat(weapon, Prop_Send, "m_flNextSecondaryAttack", next);
}

public bool:TraceRayDontHitSelf(entity, mask, any:data)
{
	return (entity != data);
}

public Timer_NoAttacking(any:ref) // Action: Handle:timer, 
{
	new weapon = EntRefToEntIndex(ref);
	SetNextAttack(weapon, 1.56);
}
