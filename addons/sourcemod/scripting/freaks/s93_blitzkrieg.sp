/* 

	SHADoW93's Project TF2Danmaku Presents:
	
	The Blitzkrieg - The original Rocket Hell FF2 Boss
	
	Some code snippets from EP, MasterOfTheXP, pheadxdll, & Wolvan
	Special thanks to BBG_Theory, M76030, Ravensbro, Transit of Venus, and VoiDED for pointing out bugs
	
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
				1 - Enable revive markers
				0 - Disable revive markers
				
			arg9 - Revive Marker Duration (default 30 seconds)
			
				arg10-arg11 only if arg1 is set to 0
			arg10 - What is the minimum level to select? (Default 2)
			arg11 - What is the maximum level to select? (Default 5)
			
			arg12 - Reroll a different difficulty level? (1 & 0 only function if on random mode, 2 will work independent of this setting)
				2 - Level Up
				1 - Reroll
				0 - Retain same level
				
			arg13 - RAGE on Kill? (default is no RAGE on kill)
		
		mini_blitzkrieg
			arg0 - Ability Slot
			arg1 - Kritzkrieg Duration
			
		blitzkrieg_barrage
			arg0 - Ability Slot
			arg1 - Ubercharge duration
			arg2 - Kritzkrieg Duration
			arg3 - Rampage duration (if arg1 = 1, will switch to normal rocket launchers)
			
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
#define MB 3
#define ME 2048
#undef REQUIRE_PLUGIN
#tryinclude <updater>

#define BLITZKRIEG_SND "mvm/mvm_tank_end.wav"
#define MINIBLITZKRIEG_SND "mvm/mvm_tank_start.wav"

#define SWITCHMEDA	"vo/medic_mvm_resurrect01.wav"
#define SWITCHSOLA	"vo/soldier_mvm_resurrect03.wav"
#define SWITCHMEDB	"vo/medic_mvm_resurrect02.wav"
#define SWITCHSOLB	"vo/soldier_mvm_resurrect05.wav"
#define SWITCHMEDC	"vo/medic_mvm_resurrect03.wav"
#define SWITCHSOLC	"vo/soldier_mvm_resurrect06.wav"

#define MEDICRAGEA	"vo/medic_mvm_heal_shield02.wav"
#define MEDICRAGEB	"vo/medic_positivevocalization05.wav"
#define MEDICRAGEC	"vo/taunts/medic_taunts08.wav"

#define SOLDIERRAGEA	"vo/taunts/soldier_taunts16.wav"
#define SOLDIERRAGEB	"vo/taunts/soldier_taunts05.wav"
#define SOLDIERRAGEC	"vo/taunts/soldier_taunts21.wav"

#define OVER_9000	"saxton_hale/9000.wav"

#define SCOUT_R1 "vo/Scout_sf13_magic_reac03.wav"
#define SCOUT_R2 "vo/Scout_sf13_magic_reac07.wav"
#define SOLLY_R1 "vo/Soldier_sf13_magic_reac03.wav"
#define PYRO_R1 "vo/Pyro_autodejectedtie01.wav"
#define DEMO_R1	"vo/Demoman_sf13_magic_reac05.wav"
#define HEAVY_R1 "vo/Heavy_sf13_magic_reac01.wav"
#define HEAVY_R2 "vo/Heavy_sf13_magic_reac03.wav"
#define ENGY_R1 "vo/Engineer_sf13_magic_reac01.wav"
#define ENGY_R2 "vo/Engineer_sf13_magic_reac02.wav"
#define MEDIC_R1 "vo/Medic_sf13_magic_reac01.wav"
#define MEDIC_R2 "vo/Medic_sf13_magic_reac02.wav"
#define MEDIC_R3 "vo/Medic_sf13_magic_reac03.wav"
#define MEDIC_R4 "vo/Medic_sf13_magic_reac04.wav"
#define MEDIC_R5 "vo/Medic_sf13_magic_reac07.wav"
#define SNIPER_R1 "vo/Sniper_sf13_magic_reac01.wav"
#define SNIPER_R2 "vo/Sniper_sf13_magic_reac02.wav"
#define SNIPER_R3 "vo/Sniper_sf13_magic_reac04.wav"
#define SPY_R1 "vo/Spy_sf13_magic_reac01.wav"
#define SPY_R2 "vo/Spy_sf13_magic_reac02.wav"
#define SPY_R3 "vo/Spy_sf13_magic_reac03.wav"
#define SPY_R4 "vo/Spy_sf13_magic_reac04.wav"
#define SPY_R5 "vo/Spy_sf13_magic_reac05.wav"
#define SPY_R6 "vo/Spy_sf13_magic_reac06.wav"

#define BLITZROUNDSTART "freak_fortress_2/s93dm/eog_intro.mp3"
#define BLITZROUNDEND	"freak_fortress_2/s93dm/eog_outtro.mp3"

// Manning up
static const String:BlitzCanLvlUp[][] = {
	"vo/mvm_mann_up_mode01.wav",
	"vo/mvm_mann_up_mode02.wav",
	"vo/mvm_mann_up_mode03.wav",
	"vo/mvm_mann_up_mode04.wav",
	"vo/mvm_mann_up_mode05.wav",
	"vo/mvm_mann_up_mode06.wav",
	"vo/mvm_mann_up_mode07.wav",
	"vo/mvm_mann_up_mode08.wav",
	"vo/mvm_mann_up_mode09.wav",
	"vo/mvm_mann_up_mode10.wav",
	"vo/mvm_mann_up_mode11.wav",
	"vo/mvm_mann_up_mode12.wav",
	"vo/mvm_mann_up_mode13.wav",
	"vo/mvm_mann_up_mode14.wav",
	"vo/mvm_mann_up_mode15.wav"
};

static const String:BlitzIsDefeated[][] = {
	"vo/mvm_manned_up01.wav",
	"vo/mvm_manned_up02.wav",
	"vo/mvm_manned_up03.wav"
};

static const String:BlitzIsVictorious[][] = {
	"vo/mvm_game_over_loss01.wav",
	"vo/mvm_game_over_loss02.wav",
	"vo/mvm_game_over_loss03.wav",
	"vo/mvm_game_over_loss04.wav",
	"vo/mvm_game_over_loss05.wav",
	"vo/mvm_game_over_loss06.wav",
	"vo/mvm_game_over_loss07.wav",
	"vo/mvm_game_over_loss08.wav",
	"vo/mvm_game_over_loss09.wav",
	"vo/mvm_game_over_loss10.wav",
	"vo/mvm_game_over_loss11.wav"
};

//Handles
new Handle: crockethell;
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

// Reanimators

new allowrevive;
new decaytime;
new reviveMarker[MAXPLAYERS+1];
new bool:ChangeClass[MAXPLAYERS+1] = { false, ... };
new currentTeam[MAXPLAYERS+1] = {0, ... };
new Handle: decayTimers[MAXPLAYERS+1] = { INVALID_HANDLE, ... };

// Version Number
#define MAJOR_REVISION "2"
#define MINOR_REVISION "2"
#define DEV_REVISION "Beta"
#define BUILD_REVISION "(Experimental)"
#define PLUGIN_VERSION MAJOR_REVISION..."."...MINOR_REVISION..." "...DEV_REVISION..." "...BUILD_REVISION

#if defined _updater_included
#define UPDATE_URL "http://www.shadow93.info/tf2/tf2plugins/tf2danmaku/update.txt"
#endif

public OnMapStart()
{
	// ROUND EVENTS
	PrecacheSound(BLITZROUNDSTART,true);
	PrecacheSound(BLITZROUNDEND, true);
	PrecacheSound(OVER_9000, true);
	// RAGE GENERIC ALERTS
	PrecacheSound(BLITZKRIEG_SND,true);
	PrecacheSound(MINIBLITZKRIEG_SND,true);
	//When Blitzkrieg returns to his normal medic self
	PrecacheSound(SWITCHMEDA,true);
	PrecacheSound(SWITCHMEDB,true);
	PrecacheSound(SWITCHMEDC,true);
	PrecacheSound(MEDICRAGEA,true);
	PrecacheSound(MEDICRAGEB,true);
	PrecacheSound(MEDICRAGEC,true);
	//When the fallen Soldier's soul takes over
	PrecacheSound(SWITCHSOLA,true);
	PrecacheSound(SWITCHSOLB,true);
	PrecacheSound(SWITCHSOLC,true);
	PrecacheSound(SOLDIERRAGEA,true);
	PrecacheSound(SOLDIERRAGEB,true);
	PrecacheSound(SOLDIERRAGEC,true);
	//Class Voice Reaction Lines
	PrecacheSound(SCOUT_R1,true);
	PrecacheSound(SCOUT_R2,true);
	PrecacheSound(SOLLY_R1,true);
	PrecacheSound(PYRO_R1,true);
	PrecacheSound(DEMO_R1,true);
	PrecacheSound(HEAVY_R1,true);
	PrecacheSound(HEAVY_R2,true);
	PrecacheSound(ENGY_R1,true);
	PrecacheSound(ENGY_R2,true);
	PrecacheSound(MEDIC_R1,true);
	PrecacheSound(MEDIC_R2,true);
	PrecacheSound(MEDIC_R3,true);
	PrecacheSound(MEDIC_R4,true);
	PrecacheSound(MEDIC_R5,true);
	PrecacheSound(SNIPER_R1,true);
	PrecacheSound(SNIPER_R2,true);
	PrecacheSound(SNIPER_R3,true);
	PrecacheSound(SPY_R1,true);
	PrecacheSound(SPY_R2,true);	
	PrecacheSound(SPY_R3,true);
	PrecacheSound(SPY_R4,true);
	PrecacheSound(SPY_R5,true);
	PrecacheSound(SPY_R6,true);
	LoadTranslations("ff2_blitzkrieg.phrases");
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


public Plugin:myinfo = {
	name = "Freak Fortress 2: The Blitzkrieg",
	author = "SHADoW NiNE TR3S",
	description="Projectile Hell (TF2Danmaku) BETA",
	version=PLUGIN_VERSION,
};

public OnPluginStart2()
{
	HookEvent("arena_round_start", OnRoundStart, EventHookMode_PostNoCopy);
	HookEvent("arena_win_panel", OnRoundEnd, EventHookMode_PostNoCopy);
	HookEvent("teamplay_broadcast_audio", OnAnnounce, EventHookMode_Pre);
	HookEvent("post_inventory_application", OnPlayerInventory, EventHookMode_PostNoCopy);
	HookEvent("player_death", OnPlayerDeath, EventHookMode_Pre);
	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Pre);
	HookEvent("player_changeclass", OnChangeClass);
	RegConsoleCmd("ff2_hp", CheckLevel);
	RegConsoleCmd("ff2hp", CheckLevel);
	RegConsoleCmd("hale_hp", CheckLevel);
	RegConsoleCmd("halehp", CheckLevel);
	RegConsoleCmd("ff2_classinfo", BlitzHelp);
	RegConsoleCmd("ff2classinfo", BlitzHelp);
	RegConsoleCmd("hale_classinfo", BlitzHelp);
	RegConsoleCmd("haleclassinfo",	BlitzHelp);
	RegConsoleCmd("ff2help", BlitzHelp);
	RegConsoleCmd("helpme",	BlitzHelp);
	decl String:steamid[256];
	for (new i = 1; i <= MaxClients; i++) 
	{
		if (IsClientInGame(i)) 
		{
			currentTeam[i] = GetClientTeam(i);
			ChangeClass[i] = false;
			GetClientAuthString(i, steamid, sizeof(steamid));
		}
	}
	#if defined _updater_included
	if (LibraryExists("updater"))
    {
		Updater_AddPlugin(UPDATE_URL);
	}
	#endif
}

public OnLibraryAdded(const String:name[])
{
	#if defined _updater_included
    if (StrEqual(name, "updater"))
    {
        Updater_AddPlugin(UPDATE_URL);
    }
	#endif
}

public OnLibraryRemoved(const String:name[])
{
	#if defined _updater_included
	if(StrEqual(name, "updater"))
	{
		Updater_RemovePlugin();
	}
	#endif
}

// Blitzkrieg's Rage & Death Effect //

public Action:FF2_OnAbility2(boss,const String:plugin_name[],const String:ability_name[],action)
{
	new Boss=GetClientOfUserId(FF2_GetBossUserId(boss));
	if (!strcmp(ability_name,"blitzkrieg_barrage")) 	// UBERCHARGE, KRITZKRIEG & CROCKET HELL
	{	
		if (FF2_GetRoundState()==1)
		{
			barrage=true;
			TF2_AddCondition(Boss,TFCond_Ubercharged,FF2_GetAbilityArgumentFloat(boss,this_plugin_name,ability_name,1,5.0)); // Ubercharge
			CreateTimer(FF2_GetAbilityArgumentFloat(boss,this_plugin_name,ability_name,1,5.0),RemoveUber,boss);
			TF2_AddCondition(Boss,TFCond_Kritzkrieged,FF2_GetAbilityArgumentFloat(boss,this_plugin_name,ability_name,2,5.0)); // Kritzkrieg
			if(lvlup)
			{
				if(bRdm && lvlup==1)
					weapondifficulty=GetRandomInt(minlvl,maxlvl);
				else
				{
					switch(weapondifficulty)
					{
						case 9:
							weapondifficulty=420;
						case 420:
							weapondifficulty=1337;
						case 1337:
							weapondifficulty=9001;
						case 9001:
						{
							if(bRdm)
								weapondifficulty=minlvl;
							else
								weapondifficulty=FF2_GetAbilityArgument(boss,this_plugin_name,"blitzkrieg_config", 1, 2);
						}
						default:
							weapondifficulty=weapondifficulty+1;
					}
				}
				DisplayCurrentDifficulty(Boss);		
			}
			SetEntProp(Boss, Prop_Data, "m_takedamage", 0);
			//Switching Blitzkrieg's player class while retaining the same model to switch the voice responses/commands
			PlotTwist(Boss);
			crockethell = CreateTimer(FF2_GetAbilityArgumentFloat(boss,this_plugin_name,ability_name,3),ItzBlitzkriegTime,boss);
			if(!combatstyle) // 2x strength if using mixed melee/rocket launcher
			{
				new Float:rDuration=FF2_GetAbilityArgumentFloat(boss,this_plugin_name,ability_name, 3);
				TF2_AddCondition(Boss, TFCond_RuneStrength, rDuration);
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
					EmitSoundToAll(BLITZKRIEG_SND);
			}
		}
	}
	else if (!strcmp(ability_name,"mini_blitzkrieg")) 	// KRITZKRIEG & CROCKET HELL
	{		
		if (FF2_GetRoundState()==1)
		{	
			TF2_AddCondition(Boss,TFCond_Kritzkrieged,FF2_GetAbilityArgumentFloat(boss,this_plugin_name,ability_name,1,5.0)); // Kritzkrieg
			TF2_RemoveWeaponSlot(Boss, TFWeaponSlot_Primary);
			//RAGE Voice lines depending on Blitzkrieg's current player class (Blitzkrieg is two classes in 1 - Medic / Soldier soul in the same body)
			switch(TF2_GetPlayerClass(Boss))
			{
				case TFClass_Medic: // Medic
				{
					switch (GetRandomInt(0,2))	
					{
						case 0:
							EmitSoundToAll(MEDICRAGEA, Boss);
						case 1:
							EmitSoundToAll(MEDICRAGEB, Boss);
						case 2:
							EmitSoundToAll(MEDICRAGEC, Boss);
					}
				}
				case TFClass_Soldier: // Soldier
				{
					switch (GetRandomInt(0,2))	
					{
						case 0:
							EmitSoundToAll(SOLDIERRAGEA, Boss);
						case 1:
							EmitSoundToAll(SOLDIERRAGEB, Boss);
						case 2:
							EmitSoundToAll(SOLDIERRAGEC, Boss);
					}				
				}
			}
			// Weapon switch depending if Blitzkrieg Barrage is active or not
			if(barrage)
				BlitzkriegBarrage(Boss);
			else
				RandomDanmaku(Boss);
			switch(combatstyle)
			{
				case 1:
					SetAmmo(Boss, TFWeaponSlot_Primary,999999);
				case 0:
					SetAmmo(Boss, TFWeaponSlot_Primary,blitzkriegrage);
			}
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
					EmitSoundToAll(MINIBLITZKRIEG_SND);
			}
		}
	}
	return Plugin_Continue;
}

ClassResponses(client)
{
	if(IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client)!=FF2_GetBossTeam())
	{
		switch(TF2_GetPlayerClass(client))
		{
			case TFClass_Scout: // Scout
			{
				switch (GetRandomInt(0,1))
				{
					case 0:
						EmitSoundToAll(SCOUT_R1,client);
					case 1:
						EmitSoundToAll(SCOUT_R2,client);
				}
			}
			case TFClass_Soldier: // Soldier
				EmitSoundToAll(SOLLY_R1,client);
			case TFClass_Pyro: // Pyro
				EmitSoundToAll(PYRO_R1,client);
			case TFClass_DemoMan: // DemoMan
				EmitSoundToAll(DEMO_R1,client);
			case TFClass_Heavy: // Heavy
			{
				switch (GetRandomInt(0,1))
				{
					case 0:
						EmitSoundToAll(HEAVY_R1,client);
					case 1:	
						EmitSoundToAll(HEAVY_R2,client);
				}
			}
			case TFClass_Engineer: // Engineer
			{
				switch (GetRandomInt(0,1))
				{
					case 0:
						EmitSoundToAll(ENGY_R1,client);
					case 1:
						EmitSoundToAll(ENGY_R2,client);
				}
			}	
			case TFClass_Medic: // Medic
			{
				switch (GetRandomInt(0,4))
				{
					case 0:
						EmitSoundToAll(MEDIC_R1,client);
					case 1:
						EmitSoundToAll(MEDIC_R2,client);
					case 2:
						EmitSoundToAll(MEDIC_R3,client);
					case 3:
						EmitSoundToAll(MEDIC_R4,client);
					case 4:
						EmitSoundToAll(MEDIC_R5,client);
				}
			}
			case TFClass_Sniper: // Sniper
			{
				switch (GetRandomInt(0,2))
				{
					case 0:
						EmitSoundToAll(SNIPER_R1,client);
					case 1:
						EmitSoundToAll(SNIPER_R2,client);
					case 2:
						EmitSoundToAll(SNIPER_R3,client);
				}
			}
			case TFClass_Spy: // Spy
			{
				switch (GetRandomInt(0,4))
				{
					case 0:
						EmitSoundToAll(SPY_R1,client);
					case 1:
						EmitSoundToAll(SPY_R2,client);
					case 2:
						EmitSoundToAll(SPY_R3,client);
					case 3:
						EmitSoundToAll(SPY_R4,client);
					case 4:
						EmitSoundToAll(SPY_R5,client);
					case 5:
						EmitSoundToAll(SPY_R6,client);
				}
			}
		}
	}
}

// Switch Roles ability
PlotTwist(client)
{
	if(barrage)
	{
		switch(TF2_GetPlayerClass(client))
		{
			case TFClass_Medic: // Medic
			{
				TF2_SetPlayerClass(client, TFClass_Soldier);
				switch (GetRandomInt(0,2))	
				{
					case 0:
						EmitSoundToAll(SWITCHSOLA);
					case 1:
						EmitSoundToAll(SWITCHSOLB);
					case 2:
						EmitSoundToAll(SWITCHSOLC);
				}
			}
			case TFClass_Soldier: // Soldier
			{
				TF2_SetPlayerClass(client, TFClass_Medic);
				switch (GetRandomInt(0,2))	
				{
					case 0:
						EmitSoundToAll(SWITCHMEDA);
					case 1:
						EmitSoundToAll(SWITCHMEDB);
					case 2:
						EmitSoundToAll(SWITCHMEDC);
				}				
			}
		}
	}
	else
	{
		switch (GetRandomInt(0,1))	
		{
			case 0:
				TF2_SetPlayerClass(client, TFClass_Medic);
			case 1:
				TF2_SetPlayerClass(client, TFClass_Soldier);
		}
	}
	TF2_RemoveAllWeapons(client);
	// ONLY FOR LEGACY REASONS, FF2 1.10.3 and newer doesn't actually need this to restore the boss model.
	SetVariantString("models/freak_fortress_2/shadow93/dmedic/dmedic.mdl");
	AcceptEntityInput(client, "SetCustomModel");
	SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
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
	// Restoring Melee (if using hybrid style), otherwise, giving Blitzkrieg just the death effect rocket launchers.
	// Also restores his B.A.S.E. Jumper
	SpawnWeapon(client, "tf_weapon_parachute", 1101, 109, 5, "700 ; 1 ; 701 ; 99 ; 702 ; 99 ; 703 ; 99 ; 705 ; 1 ; 640 ; 1 ; 68 ; 12 ; 269 ; 1 ; 275 ; 1");
	if(barrage)
		BlitzkriegBarrage(client);
	else
		if(startmode)
			RandomDanmaku(client);
	switch(combatstyle)
	{
		case 1:
			SetAmmo(client, TFWeaponSlot_Primary,999999);
		case 0:
		{
			switch(TF2_GetPlayerClass(client))
			{
				case 5: // Medic
				{
					switch(weapondifficulty)
					{
						case 420:
							SpawnWeapon(client, "tf_weapon_knife", 1003, 109, 5, "2 ; 5.2 ; 137 ; 5.2 ; 267 ; 1 ; 391 ; 5.2 ; 401 ; 5.2 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 4");						
						case 1337:
							SpawnWeapon(client, "tf_weapon_knife", 1003, 109, 5, "2 ; 14.37 ; 137 ; 5.2 ; 267 ; 1 ; 391 ; 14.37 ; 401 ; 5.2 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 5");						
						case 9001:
							SpawnWeapon(client, "tf_weapon_knife", 1003, 109, 5, "2 ; 100 ; 137 ; 14.37 ; 267 ; 1 ; 391 ; 100 ; 401 ; 14.37 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 5");						
						default:
							SpawnWeapon(client, "tf_weapon_knife", 1003, 109, 5, "2 ; 3.1 ; 138 ; 0.75 ; 39 ; 0.3 ; 267 ; 1 ; 391 ; 1.9 ; 401 ; 1.9 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6");
					}
				}
				case 3: // Soldier
				{
					switch(weapondifficulty)
					{
						case 420:
							SpawnWeapon(client, "tf_weapon_knife", 416, 109, 5, "2 ; 14.37 ; 137 ; 14.37 ; 267 ; 1 ; 391 ; 14.37 ; 401 ; 14.37 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 4");						
						case 1337:
							SpawnWeapon(client, "tf_weapon_knife", 416, 109, 5, "2 ; 5.2 ; 137 ; 5.2 ; 267 ; 1 ; 391 ; 5.2 ; 401 ; 5.2 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 5");
						case 9001:
							SpawnWeapon(client, "tf_weapon_knife", 416, 109, 5, "2 ; 100 ; 137 ; 100 ; 267 ; 1 ; 391 ; 100 ; 401 ; 100 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 5");
						default:
							SpawnWeapon(client, "tf_weapon_knife", 416, 109, 5, "2 ; 3.1 ; 138 ; 0.75 ; 39 ; 0.3 ; 267 ; 1 ; 391 ; 1.9 ; 401 ; 1.9 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6");
					}
				}
			}
			if(barrage)
				SetAmmo(client, TFWeaponSlot_Primary,blitzkriegrage);
			else
				SetAmmo(client, TFWeaponSlot_Primary,miniblitzkriegrage);
		}
	}	
}		

// Client Actions

// Weaponswitch (from start, expired timer, or mini_blitzkrieg
RandomDanmaku(client)
{
	switch (GetRandomInt(0,9))
	{
		case 0: // Liberty Launcher
		{
			switch(weapondifficulty)
			{
				case 1: // Easy
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 100, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1 ; 413 ; 1 ; 1 ; 0.05 ; 4 ; 6 ; 6 ; 0.18 ; 97 ; 0.01 ; 104 ; 0.40"));
				case 2: // Normal
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 101, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 1 ; 0.10 ; 4 ; 7 ; 6 ; 0.18 ; 97 ; 0.01 ; 104 ; 0.42"));
				case 3:	// Intermediate
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 102, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 1 ; 0.13 ; 4 ; 10 ; 6 ; 0.18 ; 97 ; 0.01 ; 104 ; 0.44"));
				case 4: // Difficult
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 103, 5, "413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6 ; 138 ; 0.15 ; 4 ; 15 ; 6 ; 0.18 ; 97 ; 0.01 ; 104 ; 0.47"));
				case 5: // Lunatic
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 104, 5, "413 ; 1 ; 72 ; 0.25 ; 208 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7 ; 138 ; 0.20 ; 4 ; 17 ; 6 ; 0.18 ; 97 ; 0.01 ; 104 ; 0.52"));
				case 6: // Insane
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 105, 5, "411 ; 25 ; 72 ; 0.45 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3 ; 138 ; 0.40 ; 4 ; 29 ; 6 ; 0.18 ; 97 ; 0.01 ; 104 ; 0.74"));
				case 7: // Godlike
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 106, 5, "411 ; 2 ; 72 ; 0.65 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5 ; 138 ; 0.60 ; 4 ; 27 ; 6 ; 0.18 ; 97 ; 0.01 ; 104 ; 0.94"));
				case 8: // Rocket Hell																 
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 107, 5, "411 ; 5 ; 72 ; 0.85 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4 ; 138 ; 0.80 ; 4 ; 39 ; 6 ; 0.18 ; 97 ; 0.01 ; 103 ; 1.14"));
				case 9: // Total Blitzkrieg
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 108, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2 ; 138 ; 0.60 ; 4 ; 40 ; 6 ; 0.20 ; 97 ; 0.01 ; 411 ; 15"));
				case 420: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 420, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2 ; 103 ; 5.20 ; 2 ; 5.20 ; 4 ; 40 ; 6 ; 0 ; 97 ; 0 ; 411 ; 15"));
				case 1337: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 1337, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2 ; 103 ; 14.37 ; 2 ; 14.37 ; 4 ; 40 ; 6 ; 0 ; 97 ; 0 ; 411 ; 15"));
				case 9001: // ITS OVER 9000!
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 9001, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 5 ; 103 ; 100 ; 2 ; 100 ; 4 ; 40 ; 6 ; 0 ; 97 ; 0 ; 411 ; 15"));

			}
		}
		case 1: // Beggar's Bazooka
		{
			switch(weapondifficulty)
			{
				case 1: // Easy
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 100, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1 ; 413 ; 1 ; 1 ; 0.06 ; 4 ; 9 ; 6 ; 0.16 ; 97 ; 0.01 ; 104 ; 0.35"));			
				case 2: // Normal
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 101, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 1 ; 0.12 ; 4 ; 9 ; 6 ; 0.16 ; 97 ; 0.01 ; 104 ; 0.39"));
				case 3: // Intermediate
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 102, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 1 ; 0.15 ; 4 ; 14 ; 6 ; 0.16 ; 97 ; 0.01 ; 104 ; 0.41"));
				case 4: // Difficult
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 103, 5, "413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6 ; 138 ; 0.17 ; 4 ; 17 ; 6 ; 0.16 ; 97 ; 0.01 ; 104 ; 0.44"));
				case 5: // Lunatic
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 104, 5, "413 ; 1 ; 72 ; 0.25 ; 208 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7 ; 138 ; 0.22 ; 4 ; 19 ; 6 ; 0.16 ; 97 ; 0.01 ; 104 ; 0.49"));
				case 6: // Insane
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 105, 5, "411 ; 2.5 ; 72 ; 0.45 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3 ; 138 ; 0.44 ; 4 ; 31 ; 6 ; 0.16 ; 97 ; 0.01 ; 104 ; 0.78"));
				case 7: // Godlike
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 106, 5, "411 ; 4 ; 72 ; 0.65 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5 ; 138 ; 0.64 ; 4 ; 29 ; 6 ; 0.16 ; 97 ; 0.01 ; 104 ; 0.98"));
				case 8: // Rocket Hell
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 107, 5, "411 ; 8 ; 72 ; 0.85 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4 ; 138 ; 0.84 ; 4 ; 41 ; 6 ; 0.16 ; 97 ; 0.01 ; 103 ; 1.18"));
				case 9: // Total Blitzkrieg
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 108, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2 ; 138 ; 0.75 ; 4 ; 45 ; 6 ; 0.17 ; 97 ; 0.01 ; 103 ; 1.35 ; 411 ; 13"));
				case 420: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 420, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 4 ; 103 ; 5.20 ; 2 ; 5.20 ; 4 ; 40 ; 6 ; 0 ; 97 ; 0 ; 411 ; 15"));
				case 1337: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 1337, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 5 ; 103 ; 14.37 ; 2 ; 14.37 ; 4 ; 40 ; 6 ; 0 ; 97 ; 0 ; 411 ; 15"));
				case 9001: // ITS OVER 9000!
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 9001, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 5 ; 103 ; 100 ; 2 ; 100 ; 4 ; 40 ; 6 ; 0 ; 97 ; 0 ; 411 ; 15"));
	
			}
		}
		case 2: // The Original
		{
			switch(weapondifficulty)
			{
				case 1: // Easy
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 100, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1 ; 413 ; 1 ; 1 ; 0.04 ; 4 ; 10 ; 6 ; 0.14 ; 97 ; 0.01 ; 104 ; 0.35"));
				case 2: // Normal
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 101, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 1 ; 0.08 ; 4 ; 10 ; 6 ; 0.14 ; 97 ; 0.01 ; 104 ; 0.36"));
				case 3: // Intermediate
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 102, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 1 ; 0.12 ; 4 ; 15 ; 6 ; 0.14 ; 97 ; 0.01 ; 104 ; 0.38"));
				case 4: // Difficult
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 103, 5, "413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6 ; 138 ; 0.13 ; 4 ; 13 ; 6 ; 0.14 ; 97 ; 0.01 ; 104 ; 0.41"));
				case 5: // Lunatic
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 104, 5, "413 ; 1 ; 72 ; 0.25 ; 208 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7 ; 138 ; 0.18 ; 4 ; 20 ; 6 ; 0.14 ; 97 ; 0.01 ; 104 ; 0.46"));
				case 6: // Insane
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 105, 5, "411 ; 5 ; 72 ; 0.45 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3 ; 138 ; 0.36 ; 4 ; 22 ; 6 ; 0.14 ; 97 ; 0.01 ; 104 ; 0.72"));
				case 7: // Godlike
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 106, 5, "411 ; 6 ; 72 ; 0.65 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5 ; 138 ; 0.56 ; 4 ; 30 ; 6 ; 0.14 ; 97 ; 0.01 ; 104 ; 0.92"));
				case 8: // Rocket Hell
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 107, 5, "411 ; 11 ; 72 ; 0.85 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4 ; 138 ; 0.76 ; 4 ; 32 ; 6 ; 0.14 ; 97 ; 0.01 ; 103 ; 1.12"));
				case 9: // Total Blitzkrieg
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 108, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2 ; 138 ; 0.70 ; 4 ; 50 ; 6 ; 0.14 ; 97 ; 0.01 ; 103 ; 1.30 ; 411 ; 11"));
				case 420: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 420, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 4 ; 103 ; 5.20 ; 2 ; 5.20 ; 4 ; 40 ; 6 ; 0 ; 97 ; 0 ; 411 ; 15"));
				case 1337: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 1337, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 5 ; 103 ; 14.37 ; 2 ; 14.37 ; 4 ; 40 ; 6 ; 0 ; 97 ; 0 ; 411 ; 15"));
				case 9001: // ITS OVER 9000!
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 9001, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 5 ; 103 ; 100 ; 2 ; 100 ; 4 ; 40 ; 6 ; 0 ; 97 ; 0 ; 411 ; 15"));

			}
		}
		case 3: // Festive Black Box
		{
			switch(weapondifficulty)
			{
				case 1: // Easy
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 100, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1 ; 413 ; 1 ; 1 ; 0.06 ; 4 ; 12 ; 6 ; 0.12 ; 97 ; 0.01 ; 104 ; 0.40"));
				case 2: // Normal
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 101, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 1 ; 0.11 ; 4 ; 12 ; 6 ; 0.12 ; 97 ; 0.01 ; 104 ; 0.33"));
				case 3: // Intermediate
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 102, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 1 ; 0.16 ; 4 ; 17 ; 6 ; 0.12 ; 97 ; 0.01 ; 104 ; 0.35"));
				case 4: // Difficult
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 103, 5, "413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6 ; 138 ; 0.16 ; 4 ; 17 ; 6 ; 0.12 ; 97 ; 0.01 ; 104 ; 0.38"));
				case 5: // Lunatic
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 104, 5, "413 ; 1 ; 72 ; 0.25 ; 208 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7 ; 138 ; 0.21 ; 4 ; 22 ; 6 ; 0.12 ; 97 ; 0.01 ; 104 ; 0.43"));
				case 6: // Insane
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 105, 5, "411 ; 7.5 ; 72 ; 0.45 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3 ; 138 ; 0.42 ; 4 ; 24 ; 6 ; 0.12 ; 97 ; 0.01 ; 104 ; 0.66"));
				case 7: // Godlike
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 106, 5, "411 ; 8 ; 72 ; 0.65 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5 ; 138 ; 0.62 ; 4 ; 32 ; 6 ; 0.12 ; 97 ; 0.01 ; 104 ; 0.86"));
				case 8: // Rocket Hell
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 107, 5, "411 ; 14 ; 72 ; 0.85 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4 ; 138 ; 0.82 ; 4 ; 42 ; 6 ; 0.12 ; 97 ; 0.01 ; 103 ; 1.06"));
				case 9: // Total Blitzkrieg
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 108, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2 ; 138 ; 0.75 ; 4 ; 55 ; 6 ; 0.11 ; 97 ; 0.01 ; 103 ; 1.20 ; 411 ; 8"));
				case 420: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 420, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 4 ; 103 ; 5.20 ; 2 ; 5.20 ; 4 ; 40 ; 6 ; 0 ; 97 ; 0 ; 411 ; 15"));
				case 1337: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 1337, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 5 ; 103 ; 14.37 ; 2 ; 14.37 ; 4 ; 40 ; 6 ; 0 ; 97 ; 0 ; 411 ; 15"));
				case 9001: // ITS OVER 9000!
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 9001, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 5 ; 103 ; 100 ; 2 ; 100 ; 4 ; 40 ; 6 ; 0 ; 97 ; 0 ; 411 ; 15"));

			}
		}
		case 4: // Festive Rocket Launcher
		{
			switch(weapondifficulty)
			{
				case 1: // Easy
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 100, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1 ; 413 ; 1 ; 1 ; 0.07 ; 4 ; 11 ; 6 ; 0.10 ; 97 ; 0.01 ; 104 ; 0.20"));
				case 2: // Normal
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 101, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 1 ; 0.14 ; 4 ; 15 ; 6 ; 0.10 ; 97 ; 0.01 ; 104 ; 0.30"));
				case 3: // Intermediate
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 102, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 1 ; 0.19 ; 4 ; 20 ; 6 ; 0.10 ; 97 ; 0.01 ; 104 ; 0.32"));
				case 4: // Difficult
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 103, 5, "413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6 ; 138 ; 0.19 ; 4 ; 17 ; 6 ; 0.10 ; 97 ; 0.01 ; 104 ; 0.35"));
				case 5: // Lunatic
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 104, 5, "413 ; 1 ; 72 ; 0.25 ; 208 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7 ; 138 ; 0.24 ; 4 ; 25 ; 6 ; 0.10 ; 97 ; 0.01 ; 104 ; 0.40"));
				case 6: // Insane
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 105, 5, "411 ; 10 ; 72 ; 0.45 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3 ; 138 ; 0.48 ; 4 ; 27 ; 6 ; 0.10 ; 97 ; 0.01 ; 104 ; 0.60"));
				case 7: // Godlike
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 106, 5, "411 ; 10 ; 72 ; 0.65 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5 ; 138 ; 0.68 ; 4 ; 35 ; 6 ; 0.10 ; 97 ; 0.01 ; 104 ; 0.80"));
				case 8: // Rocket Hell
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 107, 5, "411 ; 17 ; 72 ; 0.85 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4 ; 138 ; 0.88 ; 4 ; 47 ; 6 ; 0.10 ; 97 ; 0.01 ; 103 ; 1.05"));
				case 9: // Total Blitzkrieg
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 108, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2 ; 138 ; 0.80 ; 4 ; 60 ; 6 ; 0.08 ; 97 ; 0.01 ; 103 ; 1.05 ; 411 ; 5"));
				case 420: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 420, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 4 ; 103 ; 5.20 ; 2 ; 5.20 ; 4 ; 40 ; 6 ; 0 ; 97 ; 0 ; 411 ; 15"));
				case 1337: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 1337, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 5 ; 103 ; 14.37 ; 2 ; 14.37 ; 4 ; 40 ; 6 ; 0 ; 97 ; 0 ; 411 ; 15"));
				case 9001: // ITS OVER 9000!
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 9001, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 5 ; 103 ; 100 ; 2 ; 100 ; 4 ; 40 ; 6 ; 0 ; 97 ; 0 ; 411 ; 15"));

			}
		}
		case 5: // Air Strike
		{
			switch(weapondifficulty)
			{
				case 1: // Easy
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 100, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1 ; 413 ; 1 ; 1 ; 0.04 ; 413 ; 1 ; 4 ; 8 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.50"));
				case 2: // Normal
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 101, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 1 ; 0.09 ; 4 ; 16 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.35"));
				case 3: // Intermediate
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 102, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 1 ; 0.15 ; 4 ; 22 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.52"));
				case 4: // Difficult
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 103, 5, "413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6 ; 138 ; 0.14 ; 4 ; 18 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.55"));
				case 5: // Lunatic
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 104, 5, "413 ; 1 ; 72 ; 0.25 ; 208 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7 ; 138 ; 0.19 ; 4 ; 26 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.60"));
				case 6: // Insane
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 105, 5, "411 ; 12.5 ; 72 ; 0.45 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3 ; 138 ; 0.38 ; 4 ; 28 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.80"));
				case 7: // Godlike
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 106, 5, "411 ; 12 ; 72 ; 0.65 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5 ; 138 ; 0.58 ; 4 ; 36 ; 6 ; 0.08 ; 97 ; 0.01"));
				case 8: // Rocket Hell
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 107, 5, "411 ; 20 ; 72 ; 0.85 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4 ; 138 ; 0.78 ; 4 ; 48 ; 6 ; 0.08 ; 97 ; 0.01"));
				case 9: // Total Blitzkrieg
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 108, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2 ; 138 ; 0.85 ; 4 ; 48 ; 6 ; 0.06 ; 97 ; 0.01 ; 103 ; 1.20 ; 411 ; 25"));
				case 420: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 420, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 4 ; 103 ; 5.20 ; 2 ; 5.20 ; 4 ; 40 ; 6 ; 0 ; 97 ; 0 ; 411 ; 15"));
				case 1337: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 1337, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 5 ; 103 ; 14.37 ; 2 ; 14.37 ; 4 ; 40 ; 6 ; 0 ; 97 ; 0 ; 411 ; 15"));
				case 9001: // ITS OVER 9000!
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 9001, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 5 ; 103 ; 100 ; 2 ; 100 ; 4 ; 40 ; 6 ; 0 ; 97 ; 0 ; 411 ; 15"));

				}
		}
		case 6: // Direct Hit
		{
			switch(weapondifficulty)
			{
				case 1: // Easy
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 100, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1 ; 413 ; 1 ; 1 ; 0.08 ; 4 ; 8 ; 6 ; 0.05 ; 97 ; 0.01 ; 104 ; 0.45"));
				case 2: // Normal
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 101, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 1 ; 0.17 ; 4 ; 13 ; 6 ; 0.05 ; 97 ; 0.01 ; 104 ; 0.45"));
				case 3: // Intermediate
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 102, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 1 ; 0.22 ; 4 ; 20 ; 6 ; 0.05 ; 97 ; 0.01 ; 104 ; 0.47"));
				case 4: // Difficult
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 103, 5, "413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6 ; 138 ; 0.22 ; 4 ; 15 ; 6 ; 0.05 ; 97 ; 0.01 ; 104 ; 0.75"));
				case 5: // Lunatic
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 104, 5, "413 ; 1 ; 72 ; 0.25 ; 208 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7 ; 138 ; 0.27 ; 4 ; 23 ; 6 ; 0.05 ; 97 ; 0.01 ; 104 ; 0.55"));
				case 6: // Insane
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 105, 5, "411 ; 15 ; 72 ; 0.45 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3 ; 138 ; 0.54 ; 413 ; 1 ; 4 ; 25 ; 6 ; 0.05 ; 97 ; 0.01 ; 104 ; 0.80"));
				case 7: // Godlike
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 106, 5, "411 ; 14 ; 72 ; 0.65 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5 ; 138 ; 0.74 ; 4 ; 33 ; 6 ; 0.05 ; 97 ; 0.01"));
				case 8: // Rocket Hell
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 107, 5, "411 ; 23 ; 72 ; 0.85 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4 ; 138 ; 0.94 ; 4 ; 13 ; 6 ; 0.05 ; 97 ; 0.01"));
				case 9: // Total Blitzkrieg
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 108, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2 ; 138 ; 0.85 ; 4 ; 40 ; 6 ; 0.05 ; 97 ; 0.01 ; 103 ; 1.05 ; 411 ; 20"));
				case 420: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 420, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 4 ; 103 ; 5.20 ; 2 ; 5.20 ; 4 ; 40 ; 6 ; 0 ; 97 ; 0 ; 411 ; 15"));
				case 1337: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 1337, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 5 ; 103 ; 14.37 ; 2 ; 14.37 ; 4 ; 40 ; 6 ; 0 ; 97 ; 0 ; 411 ; 15"));
				case 9001: // ITS OVER 9000!
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 9001, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 5 ; 103 ; 100 ; 2 ; 100 ; 4 ; 40 ; 6 ; 0 ; 97 ; 0 ; 411 ; 15"));
			}
		}
		case 7: // Black Box
		{
			switch(weapondifficulty)
			{
				case 1: // Easy
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 100, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1 ; 413 ; 1 ; 1 ; 0.07 ; 4 ; 8.5 ; 6 ; 0.15 ; 97 ; 0.01 ; 104 ; 0.29"));
				case 2: // Normal
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 101, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 1 ; 0.15 ; 4 ; 17 ; 6 ; 0.15 ; 97 ; 0.01 ; 104 ; 0.25"));
				case 3: // Intermediate
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 102, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 1 ; 0.2 ; 4 ; 20 ; 6 ; 0.15 ; 97 ; 0.01 ; 104 ; 0.37"));
				case 4: // Difficult
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 103, 5, "413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6 ; 138 ; 0.20 ; 4 ; 19 ; 6 ; 0.15 ; 97 ; 0.01 ; 104 ; 0.47"));
				case 5: // Lunatic
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 104, 5, "413 ; 1 ; 72 ; 0.25 ; 208 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7 ; 138 ; 0.25 ; 4 ; 27 ; 6 ; 0.15 ; 97 ; 0.01 ; 104 ; 0.22"));
				case 6: // Insane
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 105, 5, "411 ; 17.5 ; 72 ; 0.45 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3 ; 138 ; 0.50 ; 4 ; 29 ; 6 ; 0.15 ; 97 ; 0.01 ; 104 ; 0.72"));
				case 7: // Godlike
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 106, 5, "411 ; 16 ; 72 ; 0.65 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5 ; 138 ; 0.70 ; 4 ; 37 ; 6 ; 0.15 ; 97 ; 0.01 ; 104 ; 0.92"));
				case 8: // Rocket Hell
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 107, 5, "411 ; 26 ; 72 ; 0.85 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4 ; 138 ; 0.90 ; 4 ; 49 ; 6 ; 0.15 ; 97 ; 0.01 ; 103 ; 1.22"));
				case 9: // Total Blitzkrieg
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 108, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2 ; 138 ; 0.85 ; 4 ; 42 ; 6 ; 0.08 ; 97 ; 0.01 ; 103 ; 1.25 ; 411 ; 30"));
				case 420: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 420, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 4 ; 103 ; 5.20 ; 2 ; 5.20 ; 4 ; 40 ; 6 ; 0 ; 97 ; 0 ; 411 ; 15"));
				case 1337: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 1337, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 5 ; 103 ; 14.37 ; 2 ; 14.37 ; 4 ; 40 ; 6 ; 0 ; 97 ; 0 ; 411 ; 15"));
				case 9001: // ITS OVER 9000!
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 9001, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 5 ; 103 ; 100 ; 2 ; 100 ; 4 ; 40 ; 6 ; 0 ; 97 ; 0 ; 411 ; 15"));

				}
		}
		case 8: // Rocket Launcher
		{
			switch(weapondifficulty)
			{
				case 1: // Easy
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 100, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1 ; 413 ; 1 ; 1 ; 0.06 ; 4 ; 11 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.25"));
				case 2: // Normal
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 101, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 1 ; 0.13 ; 4 ; 22 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.60"));
				case 3: // Intermediate
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 102, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 1 ; 0.18 ; 4 ; 25 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.32"));
				case 4: // Difficult
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 103, 5, "413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6 ; 138 ; 0.18 ; 4 ; 24 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.65"));
				case 5: // Lunatic
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 104, 5, "413 ; 1 ; 72 ; 0.25 ; 208 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7 ; 138 ; 0.23 ; 4 ; 32 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.20"));
				case 6: // Insane
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 105, 5, "411 ; 20 ; 72 ; 0.45 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3 ; 138 ; 0.46 ; 4 ; 34 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.20"));
				case 7: // Godlike
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 106, 5, "411 ; 18 ; 72 ; 0.65 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5 ; 138 ; 0.66 ; 4 ; 42 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.50"));
				case 8: // Rocket Hell
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 107, 5, "411 ; 29 ; 72 ; 0.85 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4 ; 138 ; 0.86 ; 4 ; 44 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.80"));
				case 9: // Total Blitzkrieg
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 108, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2 ; 138 ; 0.80 ; 4 ; 55 ; 6 ; 0.03 ; 97 ; 0.01 ; 103 ; 1.24 ; 411 ; 35"));
				case 420: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 420, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 4 ; 103 ; 5.20 ; 2 ; 5.20 ; 4 ; 40 ; 6 ; 0 ; 97 ; 0 ; 411 ; 15"));
				case 1337: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 1337, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 5 ; 103 ; 14.37 ; 2 ; 14.37 ; 4 ; 40 ; 6 ; 0 ; 97 ; 0 ; 411 ; 15"));
				case 9001: // ITS OVER 9000!
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 9001, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 5 ; 103 ; 100 ; 2 ; 100 ; 4 ; 40 ; 6 ; 0 ; 97 ; 0 ; 411 ; 15"));

				}
		}
		case 9: // Gold Botkiller Rocket Launcher Mk.II
		{
			switch(weapondifficulty)
			{
				case 1: // Easy
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 100, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1 ; 413 ; 1 ; 1 ; 0.04 ; 4 ; 6.5 ; 6 ; 0.20 ; 97 ; 0.01 ; 104 ; 0.30"));
				case 2: // Normal
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 101, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 1 ; 0.09 ; 4 ; 13 ; 6 ; 0.20 ; 97 ; 0.01 ; 104 ; 0.45"));
				case 3: // Intemediate
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 102, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 1 ; 0.14 ; 4 ; 15 ; 6 ; 0.20 ; 97 ; 0.01 ; 104 ; 0.37"));
				case 4: // Difficult
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 103, 5, "413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6 ; 138 ; 0.15 ; 4 ; 15 ; 6 ; 0.20 ; 97 ; 0.01 ; 104 ; 0.70"));
				case 5: // Lunatic
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 104, 5, "413 ; 1 ; 72 ; 0.25 ; 208 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7 ; 138 ; 0.20 ; 4 ; 23 ; 6 ; 0.20 ; 97 ; 0.01 ; 104 ; 0.20"));
				case 6: // Insane
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 105, 5, "411 ; 22.5 ; 72 ; 0.45 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3 ; 138 ; 0.40 ; 4 ; 25 ; 6 ; 0.20 ; 97 ; 0.01 ; 104 ; 0.20"));
				case 7: // Godlike
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 106, 5, "411 ; 20 ; 72 ; 0.65 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5 ; 138 ; 0.60 ; 4 ; 33 ; 6 ; 0.20 ; 97 ; 0.01 ; 104 ; 0.50"));
				case 8: // Rocket Hell
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 107, 5, "411 ; 32 ; 72 ; 0.85 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4 ; 138 ; 0.80 ; 4 ; 45 ; 6 ; 0.20 ; 97 ; 0.01 ; 104 ; 0.80"));
				case 9: // Total Blitzkrieg
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 108, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2 ; 138 ; 0.90 ; 4 ; 47 ; 6 ; 0.13 ; 97 ; 0.01 ; 103 ; 1.10 ; 411 ; 30"));	
				case 420: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 420, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 4 ; 103 ; 5.20 ; 2 ; 5.20 ; 4 ; 40 ; 6 ; 0 ; 97 ; 0 ; 411 ; 15"));
				case 1337: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 973, 1337, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 5 ; 103 ; 14.37 ; 2 ; 14.37 ; 4 ; 40 ; 6 ; 0 ; 97 ; 0 ; 411 ; 15"));
				case 9001: // ITS OVER 9000!
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 973, 9001, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 5 ; 103 ; 100 ; 2 ; 100 ; 4 ; 40 ; 6 ; 0 ; 97 ; 0 ; 411 ; 15"));
			}
		}
	}
}

// Deadlier Versions (blitzkrieg_barrage)
BlitzkriegBarrage(client)
{
	switch (GetRandomInt(0,9))
	{
		case 0: // Liberty Launcher
		{
			switch(weapondifficulty)
			{
				case 1: // Easy
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 100, 5, "1 ; 0.05 ; 413 ; 1 ; 4 ; 5 ; 6 ; 0.20 ; 97 ; 0.01 ; 104 ; 0.40 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
				case 2:	// Normal
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 101, 5, "1 ; 0.10 ; 413 ; 1 ; 4 ; 15 ; 6 ; 0.20 ; 97 ; 0.01 ; 104 ; 0.90 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
				case 3:	// Intermediate
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 102, 5, "1 ; 0.15 ; 413 ; 1 ; 4 ; 20 ; 6 ; 0.20 ; 97 ; 0.01 ; 104 ; 0.90 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
				case 4: // Difficult
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 103, 5, "72 ; 0.25 ; 208 ; 1 ; 138 ; 0.20 ; 413 ; 1 ; 4 ; 25 ; 6 ; 0.18 ; 97 ; 0.01 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
				case 5: // Lunatic
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 104, 5, "72 ; 0.45 ; 208 ; 1 ; 138 ; 0.30 ; 413 ; 1 ; 4 ; 30 ; 6 ; 0.10 ; 97 ; 0.01 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
				case 6: // Insane
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 105, 5, "72 ; 0.65 ; 208 ; 1 ; 138 ; 0.40 ; 413 ; 1 ; 4 ; 35 ; 6 ; 0.06 ; 97 ; 0.01 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 3"));
				case 7: // Godlike
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 106, 5, "72 ; 0.85 ; 208 ; 1 ; 138 ; 0.90 ; 413 ; 1 ; 4 ; 40 ; 6 ; 0.01 ; 97 ; 0.01 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
				case 8: // Rocket Hell
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 107, 5, "208 ; 1 ; 2 ; 1.90 ; 413 ; 1 ; 4 ; 45 ; 6 ; 0.02 ; 97 ; 0.01 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
				case 9: // Total Blitzkrieg
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 108, 5, "208 ; 1 ; 2 ; 2.90 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.00 ; 97 ; 0.00 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
				case 420: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 420, 5, "208 ; 1 ; 2 ; 5.2 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.00 ; 72 ; 5.2 ; 73 ; 5.2 ; 97 ; 0.00 ; 103 ; 5.2 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
				case 1337: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 1337, 5, "208 ; 1 ; 2 ; 14.37 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.00 ; 72 ; 14.37 ; 73 ; 14.37 ; 97 ; 0.00 ; 103 ; 14.37 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
				}
		}
		case 1: // Beggar's Bazooka
		{
			switch(weapondifficulty)
			{
				case 1: // Easy
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 100, 5, "1 ; 0.10 ; 413 ; 1 ; 4 ; 10 ; 6 ; 0.17 ; 97 ; 0.01 ; 104 ; 0.35 ; 411 ; 13 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
				case 2:	// Normal
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 101, 5, "1 ; 0.15 ; 413 ; 1 ; 4 ; 20 ; 6 ; 0.17 ; 97 ; 0.01 ; 104 ; 0.75 ; 411 ; 13 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
				case 3:	// Intermediate
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 102, 5, "1 ; 0.20 ; 413 ; 1 ; 4 ; 25 ; 6 ; 0.17 ; 97 ; 0.01 ; 104 ; 0.75 ; 411 ; 13 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
				case 4: // Difficult
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 103, 5, "72 ; 0.25 ; 208 ; 1 ; 138 ; 0.25 ; 413 ; 1 ; 4 ; 30 ; 6 ; 0.15 ; 97 ; 0.01 ; 104 ; 0.85 ; 411 ; 13 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
				case 5: // Lunatic
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 104, 5, "72 ; 0.45 ; 208 ; 1 ; 138 ; 0.35 ; 413 ; 1 ; 4 ; 35 ; 6 ; 0.07 ; 97 ; 0.01 ; 103 ; 1.15 ; 411 ; 13 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
				case 6: // Insane
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 105, 5, "72 ; 0.65 ; 208 ; 1 ; 138 ; 0.55 ; 413 ; 1 ; 4 ; 40 ; 6 ; 0.06 ; 97 ; 0.01 ; 103 ; 1.25 ; 411 ; 13 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
				case 7: // Godlike
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 106, 5, "72 ; 0.85 ; 208 ; 1 ; 413 ; 1 ; 4 ; 45 ; 6 ; 0.07 ; 97 ; 0.01 ; 103 ; 1.35 ; 411 ; 13 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
				case 8: // Rocket Hell
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 107, 5, "208 ; 1 ; 2 ; 1.95 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.02 ; 97 ; 0.01 ; 103 ; 1.65 ; 411 ; 13 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
				case 9: // Total Blitzkrieg
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 108, 5, "208 ; 1 ; 2 ; 2.95 ; 413 ; 1 ; 4 ; 55 ; 6 ; 0.00 ; 97 ; 0.00 ; 103 ; 2.65 ; 411 ; 13 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
				case 420: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 420, 5, "208 ; 1 ; 2 ; 5.2 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.00 ; 72 ; 5.2 ; 73 ; 5.2 ; 97 ; 0.00 ; 103 ; 5.2 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
				case 1337: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 1337, 5, "208 ; 1 ; 2 ; 14.37 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.00 ; 72 ; 14.37 ; 73 ; 14.37 ; 97 ; 0.00 ; 103 ; 14.37 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
				case 9001: // ITS OVER 9000
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 9001, 5, "208 ; 1 ; 2 ; 100 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.00 ; 72 ; 100 ; 73 ; 100 ; 97 ; 0.00 ; 103 ; 100 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));

			}
		}
		case 2: // The Original
		{
			switch(weapondifficulty)
			{
				case 1: // Easy
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 100, 5, "1 ; 0.15 ; 413 ; 1 ; 4 ; 15 ; 6 ; 0.14 ; 97 ; 0.01 ; 104 ; 0.30 ; 411 ; 11 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
				case 2:	// Normal
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 101, 5, "1 ; 0.20 ; 413 ; 1 ; 4 ; 25 ; 6 ; 0.14 ; 97 ; 0.01 ; 104 ; 0.60 ; 411 ; 11 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
				case 3:	// Intermediate
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 102, 5, "1 ; 0.25 ; 413 ; 1 ; 4 ; 30 ; 6 ; 0.14 ; 97 ; 0.01 ; 104 ; 0.60 ; 411 ; 11 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
				case 4: // Difficult
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 103, 5, "72 ; 0.25 ; 208 ; 1 ; 138 ; 0.30 ; 413 ; 1 ; 4 ; 35 ; 6 ; 0.12 ; 97 ; 0.01 ; 104 ; 0.70 ; 411 ; 11 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
				case 5: // Lunatic
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 104, 5, "72 ; 0.45 ; 208 ; 1 ; 138 ; 0.40 ; 413 ; 1 ; 4 ; 40 ; 6 ; 0.04 ; 97 ; 0.01 ; 411 ; 11 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
				case 6: // Insane
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 105, 5, "72 ; 0.65 ; 208 ; 1 ; 138 ; 0.50 ; 413 ; 1 ; 4 ; 45 ; 6 ; 0.06 ; 97 ; 0.01 ; 103 ; 1.10 ; 411 ; 11 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
				case 7: // Godlike
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 106, 5, "72 ; 0.85 ; 208 ; 1 ; 138 ; 0.90 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.04 ; 97 ; 0.01 ; 103 ; 1.30 ; 411 ; 11 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
				case 8: // Rocket Hell
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 107, 5, "208 ; 1 ; 2 ; 1.90 ; 413 ; 1 ; 4 ; 55 ; 6 ; 0.02 ; 97 ; 0.01 ; 103 ; 1.60 ; 411 ; 11 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
				case 9: // Total Blitzkrieg
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 108, 5, "208 ; 1 ; 2 ; 2.90 ; 413 ; 1 ; 4 ; 60 ; 6 ; 0.00 ; 97 ; 0.00 ; 103 ; 2.60 ; 411 ; 11 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
				case 420: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 420, 5, "208 ; 1 ; 2 ; 5.2 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.00 ; 72 ; 5.2 ; 73 ; 5.2 ; 97 ; 0.00 ; 103 ; 5.2 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
				case 1337: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 1337, 5, "208 ; 1 ; 2 ; 14.37 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.00 ; 72 ; 14.37 ; 73 ; 14.37 ; 97 ; 0.00 ; 103 ; 14.37 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
				case 9001: // ITS OVER 9000
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 9001, 5, "208 ; 1 ; 2 ; 100 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.00 ; 72 ; 100 ; 73 ; 100 ; 97 ; 0.00 ; 103 ; 100 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));

			}
		}
		case 3: // Festive Black Box
		{
			switch(weapondifficulty)
			{
				case 1: // Easy
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 100, 5, "1 ; 0.07 ; 413 ; 1 ; 4 ; 20 ; 6 ; 0.11 ; 97 ; 0.01 ; 104 ; 0.25 ; 411 ; 8 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
				case 2: // Normal
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 101, 5, "1 ; 0.25 ; 413 ; 1 ; 4 ; 30 ; 6 ; 0.11 ; 97 ; 0.01 ; 104 ; 0.40 ; 411 ; 8 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
				case 3: // Intermediate
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 102, 5, "1 ; 0.30 ; 413 ; 1 ; 4 ; 35 ; 6 ; 0.11 ; 97 ; 0.01 ; 104 ; 0.40 ; 411 ; 8 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
				case 4: // Difficult
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 103, 5, "72 ; 0.25 ; 208 ; 1 ; 138 ; 0.35 ; 413 ; 1 ; 4 ; 40 ; 6 ; 0.10 ; 97 ; 0.01 ; 104 ; 0.50 ; 411 ; 8 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
				case 5: // Lunatic
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 104, 5, "72 ; 0.45 ; 208 ; 1 ; 138 ; 0.45 ; 413 ; 1 ; 4 ; 45 ; 6 ; 0.01 ; 97 ; 0.01 ; 104 ; 0.80 ; 411 ; 8 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
				case 6: // Insane
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 105, 5, "72 ; 0.65 ; 208 ; 1 ; 138 ; 0.55 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.06 ; 97 ; 0.01 ; 103 ; 1.10 ; 411 ; 8 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
				case 7: // Godlike
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 106, 5, "72 ; 0.85 ; 208 ; 1 ; 138 ; 0.95 ; 413 ; 1 ; 4 ; 55 ; 6 ; 0.04 ; 97 ; 0.01 ; 103 ; 1.20 ; 411 ; 8 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
				case 8: // Rocket Hell
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 107, 5, "208 ; 1 ; 2 ; 1.95 ; 413 ; 1 ; 4 ; 60 ; 6 ; 0.02 ; 97 ; 0.01 ; 103 ; 1.50 ; 411 ; 8 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
				case 9: // Total Blitzkrieg
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 108, 5, "208 ; 1 ; 2 ; 2.95 ; 413 ; 1 ; 4 ; 65 ; 6 ; 0.00 ; 97 ; 0.00 ; 103 ; 2.50 ; 411 ; 8 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
				case 420: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 420, 5, "208 ; 1 ; 2 ; 5.2 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.00 ; 72 ; 5.2 ; 73 ; 5.2 ; 97 ; 0.00 ; 103 ; 5.2 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
				case 1337: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 1337, 5, "208 ; 1 ; 2 ; 14.37 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.00 ; 72 ; 14.37 ; 73 ; 14.37 ; 97 ; 0.00 ; 103 ; 14.37 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
				case 9001: // ITS OVER 9000
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 9001, 5, "208 ; 1 ; 2 ; 100 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.00 ; 72 ; 100 ; 73 ; 100 ; 97 ; 0.00 ; 103 ; 100 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));

			}
		}
		case 4: // Festive Rocket Launcher
		{
			switch(weapondifficulty)
			{
				case 1: // Easy
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 100, 5, "1 ; 0.12 ; 413 ; 1 ; 4 ; 25 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.20 ; 411 ; 5 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
				case 2: // Normal
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 101, 5, "1 ; 0.30 ; 413 ; 1 ; 4 ; 35 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.25 ; 411 ; 5 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
				case 3: // Intermediate
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 102, 5, "1 ; 0.35 ; 413 ; 1 ; 4 ; 49 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.25 ; 411 ; 5 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
				case 4: // Difficult
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 103, 5, "72 ; 0.25 ; 208 ; 1 ; 138 ; 0.40 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.35 ; 411 ; 5 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
				case 5: // Lunatic
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 104, 5, "72 ; 0.45 ; 208 ; 1 ; 138 ; 0.50 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.65 ; 411 ; 5 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
				case 6: // Insane
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 105, 5, "72 ; 0.65 ; 208 ; 1 ; 138 ; 0.60 ; 413 ; 1 ; 4 ; 55 ; 6 ; 0.06 ; 97 ; 0.01 ; 104 ; 0.85 ; 411 ; 5 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
				case 7: // Godlike
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 106, 5, "72 ; 0.85 ; 208 ; 1 ; 413 ; 1 ; 4 ; 60 ; 6 ; 0.04 ; 97 ; 0.01 ; 103 ; 1.05 ; 411 ; 5 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));			
				case 8: // Rocket Hell
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 107, 5, "208 ; 1 ; 2 ; 2.10 ; 413 ; 1 ; 4 ; 65 ; 6 ; 0.02 ; 97 ; 0.01 ; 103 ; 1.40 ; 411 ; 5 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
				case 9: // Total Blitzkrieg
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 108, 5, "208 ; 1 ; 2 ; 2.10 ; 413 ; 1 ; 4 ; 70 ; 6 ; 0.00 ; 97 ; 0.00 ; 103 ; 2.40 ; 411 ; 5 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
				case 420: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 420, 5, "208 ; 1 ; 2 ; 5.2 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.00 ; 72 ; 5.2 ; 73 ; 5.2 ; 97 ; 0.00 ; 103 ; 5.2 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
				case 1337: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 1337, 5, "208 ; 1 ; 2 ; 14.37 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.00 ; 72 ; 14.37 ; 73 ; 14.37 ; 97 ; 0.00 ; 103 ; 14.37 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
				case 9001: // ITS OVER 9000
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 9001, 5, "208 ; 1 ; 2 ; 100 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.00 ; 72 ; 100 ; 73 ; 100 ; 97 ; 0.00 ; 103 ; 100 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));

			}
		}
		case 5: // Air Strike
		{
			switch(weapondifficulty)
			{
				case 1: // Easy
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 100, 5, "1 ; 0.07 ; 413 ; 1 ; 4 ; 23 ; 6 ; 0.06 ; 97 ; 0.01 ; 104 ; 0.50 ; 411 ; 25 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
				case 2: // Normal
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 101, 5, "1 ; 0.15 ; 413 ; 1 ; 4 ; 34 ; 6 ; 0.06 ; 97 ; 0.01 ; 411 ; 25 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
				case 3: // Intermediate
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 102, 5, "1 ; 0.20 ; 413 ; 1 ; 4 ; 45 ; 6 ; 0.06 ; 97 ; 0.01 ; 411 ; 25 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
				case 4: // Difficult
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 103, 5, "72 ; 0.25 ; 208 ; 1 ; 138 ; 0.25 ; 413 ; 1 ; 4 ; 48 ; 6 ; 0.06 ; 97 ; 0.01 ; 411 ; 25 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
				case 5: // Lunatic
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 104, 5, "72 ; 0.45 ; 208 ; 1 ; 138 ; 0.45 ; 413 ; 1 ; 4 ; 58 ; 6 ; 0.06 ; 97 ; 0.01 ; 411 ; 25 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
				case 6: // Insane
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 105, 5, "72 ; 0.65 ; 208 ; 1 ; 138 ; 0.55 ; 413 ; 1 ; 4 ; 68 ; 6 ; 0.06 ; 97 ; 0.01 ; 103 ; 1.10 ; 411 ; 25 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
				case 7: // Godlike
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 106, 5, "72 ; 0.85 ; 208 ; 1 ; 2 ; 1.15 ; 413 ; 1 ; 4 ; 78 ; 6 ; 0.04 ; 97 ; 0.01 ; 103 ; 1.20 ; 411 ; 25 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
				case 8: // Rocket Hell
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 107, 5, "208 ; 1 ; 2 ; 2.15 ; 413 ; 1 ; 4 ; 88 ; 6 ; 0.02 ; 97 ; 0.01 ; 103 ; 1.50 ; 411 ; 25 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
				case 9: // Total Blitzkrieg
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 108, 5, "208 ; 1 ; 2 ; 3.15 ; 413 ; 1 ; 4 ; 98 ; 6 ; 0.00 ; 97 ; 0.00 ; 103 ; 2.50 ; 411 ; 25 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
				case 420: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 420, 5, "208 ; 1 ; 2 ; 5.2 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.00 ; 72 ; 5.2 ; 73 ; 5.2 ; 97 ; 0.00 ; 103 ; 5.2 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
				case 1337: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 1337, 5, "208 ; 1 ; 2 ; 14.37 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.00 ; 72 ; 14.37 ; 73 ; 14.37 ; 97 ; 0.00 ; 103 ; 14.37 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
				case 9001: // ITS OVER 9000
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 9001, 5, "208 ; 1 ; 2 ; 100 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.00 ; 72 ; 100 ; 73 ; 100 ; 97 ; 0.00 ; 103 ; 100 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));

			}
		}
		case 6: // Direct Hit
		{
			switch(weapondifficulty)
			{
				case 1: // Easy
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 100, 5, "1 ; 0.13 ; 413 ; 1 ; 4 ; 15 ; 6 ; 0.05 ; 97 ; 0.01 ; 104 ; 0.35 ; 411 ; 20 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
				case 2: // Normal
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 101, 5, "1 ; 0.20 ; 413 ; 1 ; 4 ; 25 ; 6 ; 0.05 ; 97 ; 0.01 ; 104 ; 0.45 ; 411 ; 20 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
				case 3: // Intermediate
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 102, 5, "1 ; 0.25 ; 413 ; 1 ; 4 ; 40 ; 6 ; 0.05 ; 97 ; 0.01 ; 104 ; 0.45 ; 411 ; 20 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
				case 4: // Difficult
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 103, 5, "72 ; 0.25 ; 208 ; 1 ; 138 ; 0.30 ; 413 ; 1 ; 4 ; 40 ; 6 ; 0.05 ; 97 ; 0.01 ; 104 ; 0.55 ; 411 ; 20 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
				case 5: // Lunatic
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 104, 5, "72 ; 0.45 ; 208 ; 1 ; 138 ; 0.45 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.05 ; 97 ; 0.01 ; 104 ; 0.65 ; 411 ; 20 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
				case 6: // Insane
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 105, 5, "72 ; 0.65 ; 208 ; 1 ; 138 ; 0.55 ; 413 ; 1 ; 4 ; 60 ; 6 ; 0.06 ; 97 ; 0.01 ; 104 ; 0.85 ; 411 ; 20 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
				case 7: // Godlike
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 106, 5, "72 ; 0.85 ; 208 ; 1 ; 2 ; 1.15 ; 413 ; 1 ; 4 ; 70 ; 6 ; 0.04 ; 97 ; 0.01 ; 103 ; 1.05 ; 411 ; 20 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
				case 8: // Rocket Hell
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 107, 5, "208 ; 1 ; 2 ; 2.25 ; 413 ; 1 ; 4 ; 80 ; 6 ; 0.02 ; 97 ; 0.01 ; 103 ; 1.60 ; 411 ; 20 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
				case 9: // Total Blitzkrieg
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 108, 5, "208 ; 1 ; 2 ; 3.25 ; 413 ; 1 ; 4 ; 90 ; 6 ; 0.00 ; 97 ; 0.00 ; 103 ; 2.60 ; 411 ; 20 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
				case 420: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 420, 5, "208 ; 1 ; 2 ; 5.2 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.00 ; 72 ; 5.2 ; 73 ; 5.2 ; 97 ; 0.00 ; 103 ; 5.2 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
				case 1337: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 1337, 5, "208 ; 1 ; 2 ; 14.37 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.00 ; 72 ; 14.37 ; 73 ; 14.37 ; 97 ; 0.00 ; 103 ; 14.37 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
				case 9001: // ITS OVER 9000
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 9001, 5, "208 ; 1 ; 2 ; 100 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.00 ; 72 ; 100 ; 73 ; 100 ; 97 ; 0.00 ; 103 ; 100 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));

			}
		}
		case 7: // Black Box
		{
			switch(weapondifficulty)
			{
				case 1: // Easy
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 100, 5, "1 ; 0.15 ; 413 ; 1 ; 4 ; 17 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.45 ; 411 ; 30 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
				case 2: // Normal
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 101, 5, "1 ; 0.25 ; 413 ; 1 ; 4 ; 27 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.95 ; 411 ; 30 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
				case 3: // Intermediate
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 102, 5, "1 ; 0.30 ; 413 ; 1 ; 4 ; 32 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.95 ; 411 ; 30 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
				case 4: // Difficult
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 103, 5, "72 ; 0.25 ; 208 ; 1 ; 138 ; 0.35 ; 413 ; 1 ; 4 ; 42 ; 6 ; 0.05 ; 97 ; 0.01 ; 104 ; 0.95 ; 411 ; 30 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
				case 5: // Lunatic
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 104, 5, "72 ; 0.45 ; 208 ; 1 ; 138 ; 0.55 ; 413 ; 1 ; 4 ; 52 ; 6 ; 0.08 ; 97 ; 0.01 ; 411 ; 30 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
				case 6: // Insane
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 105, 5, "72 ; 0.65 ; 208 ; 1 ; 138 ; 0.65 ; 413 ; 1 ; 4 ; 62 ; 6 ; 0.06 ; 97 ; 0.01 ; 103 ; 1.15 ; 411 ; 30 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
				case 7: // Godlike
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 106, 5, "72 ; 0.85 ; 208 ; 1 ; 2 ; 1.15 ; 413 ; 1 ; 4 ; 72 ; 6 ; 0.04 ; 97 ; 0.01 ; 103 ; 1.25 ; 411 ; 30 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
				case 8: // Rocket Hell
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 107, 5, "208 ; 1 ; 2 ; 2.05 ; 413 ; 1 ; 4 ; 82 ; 6 ; 0.02 ; 97 ; 0.01 ; 103 ; 1.50 ; 411 ; 30 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
				case 9: // Total Blitzkrieg
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 108, 5, "208 ; 1 ; 2 ; 3.05 ; 413 ; 1 ; 4 ; 92 ; 6 ; 0.00 ; 97 ; 0.00 ; 103 ; 2.50 ; 411 ; 30 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
				case 420: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 420, 5, "208 ; 1 ; 2 ; 5.2 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.00 ; 72 ; 5.2 ; 73 ; 5.2 ; 97 ; 0.00 ; 103 ; 5.2 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
				case 1337: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 1337, 5, "208 ; 1 ; 2 ; 14.37 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.00 ; 72 ; 14.37 ; 73 ; 14.37 ; 97 ; 0.00 ; 103 ; 14.37 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
				case 9001: // ITS OVER 9000
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 9001, 5, "208 ; 1 ; 2 ; 100 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.00 ; 72 ; 100 ; 73 ; 100 ; 97 ; 0.00 ; 103 ; 100 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));

			}
		}
		case 8: // Rocket Launcher
		{
			switch(weapondifficulty)
			{
				case 1: // Easy
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 100, 5, "1 ; 0.10 ; 413 ; 1 ; 4 ; 25 ; 6 ; 0.03 ; 97 ; 0.01 ; 104 ; 0.50 ; 411 ; 35 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
				case 2: // Normal
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 101, 5, "1 ; 0.20 ; 413 ; 1 ; 4 ; 40 ; 6 ; 0.03 ; 97 ; 0.01 ; 411 ; 35 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
				case 3: // Intermediate
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 102, 5, "1 ; 0.25 ; 413 ; 1 ; 4 ; 45 ; 6 ; 0.03 ; 97 ; 0.01 ; 411 ; 35 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
				case 4: // Difficult
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 103, 5, "72 ; 0.25 ; 208 ; 1 ; 138 ; 0.30 ; 413 ; 1 ; 4 ; 55 ; 6 ; 0.03 ; 97 ; 0.01 ; 411 ; 35 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 3"));
				case 5: // Lunatic
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 104, 5, "72 ; 0.45 ; 208 ; 1 ; 138 ; 0.50 ; 413 ; 1 ; 4 ; 65 ; 6 ; 0.03 ; 97 ; 0.01 ; 411 ; 35 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
				case 6: // Insane
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 105, 5, "72 ; 0.65 ; 208 ; 1 ; 138 ; 0.60 ; 413 ; 1 ; 4 ; 65 ; 6 ; 0.06 ; 97 ; 0.01 ; 103 ; 1.14 ; 411 ; 35 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
				case 7: // Godlike
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 106, 5, "72 ; 0.85 ; 208 ; 1 ; 2 ; 1.10 ; 413 ; 1 ; 4 ; 75 ; 6 ; 0.04 ; 97 ; 0.01 ; 103 ; 1.24 ; 411 ; 35 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
				case 8: // Rocket Hell
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 107, 5, "208 ; 1 ; 2 ; 2.20 ; 413 ; 1 ; 4 ; 85 ; 6 ; 0.02 ; 97 ; 0.01 ; 103 ; 1.48 ; 411 ; 35 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2002; 2014 ; 4"));
				case 9: // Total Blitzkrieg
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 108, 5, "208 ; 1 ; 2 ; 3.20 ; 413 ; 1 ; 4 ; 95 ; 6 ; 0.00 ; 97 ; 0.00 ; 103 ; 2.48 ; 411 ; 35 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
				case 420: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 420, 5, "208 ; 1 ; 2 ; 5.2 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.00 ; 72 ; 5.2 ; 73 ; 5.2 ; 97 ; 0.00 ; 103 ; 5.2 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
				case 1337: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 1337, 5, "208 ; 1 ; 2 ; 14.37 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.00 ; 72 ; 14.37 ; 73 ; 14.37 ; 97 ; 0.00 ; 103 ; 14.37 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
				case 9001: // ITS OVER 9000
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 9001, 5, "208 ; 1 ; 2 ; 100 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.00 ; 72 ; 100 ; 73 ; 100 ; 97 ; 0.00 ; 103 ; 100 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));

				}
		}
		case 9: // Gold Botkiller Rocket Launcher Mk.II
		{
			switch(weapondifficulty)
			{
				case 1: // Easy
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 100, 5, "1 ; 0.17 ; 413 ; 1 ; 4 ; 23 ; 6 ; 0.13 ; 97 ; 0.01 ; 104 ; 0.40 ; 411 ; 30 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
				case 2: // Normal
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 101, 5, "1 ; 0.30 ; 413 ; 1 ; 4 ; 33 ; 6 ; 0.13 ; 97 ; 0.01 ; 104 ; 0.50 ; 411 ; 30 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
				case 3: // Intermediate
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 102, 5, "1 ; 0.32 ; 413 ; 1 ; 4 ; 37 ; 6 ; 0.13 ; 97 ; 0.01 ; 104 ; 0.50 ; 411 ; 30 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
				case 4: // Difficult
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 103, 5, "72 ; 0.25 ; 208 ; 1 ; 138 ; 0.40 ; 413 ; 1 ; 4 ; 47 ; 6 ; 0.07 ; 97 ; 0.01 ; 104 ; 0.60 ; 411 ; 30 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 3"));	
				case 5: // Lunatic
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 104, 5, "72 ; 0.45 ; 208 ; 1 ; 138 ; 0.60 ; 413 ; 1 ; 4 ; 57 ; 6 ; 0.03 ; 97 ; 0.01 ; 104 ; 0.70 ; 411 ; 30 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
				case 6: // Insane
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 105, 5, "72 ; 0.65 ; 208 ; 1 ; 138 ; 0.70 ; 413 ; 1 ; 4 ; 67 ; 6 ; 0.06 ; 97 ; 0.01 ; 104 ; 0.90 ; 411 ; 30 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
				case 7: // Godlike
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 106, 5, "72 ; 0.85 ; 208 ; 1 ; 2 ; 1.20 ; 413 ; 1 ; 4 ; 77 ; 6 ; 0.04 ; 97 ; 0.01 ; 103 ; 1.10 ; 411 ; 30 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
				case 8: // Rocket Hell
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 107, 5, "208 ; 1 ; 2 ; 2.30 ; 413 ; 1 ; 4 ; 87 ; 6 ; 0.02 ; 97 ; 0.01 ; 103 ; 1.70 ; 411 ; 30 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
				case 9: // Total Blitzkrieg
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 108, 5, "208 ; 1 ; 2 ; 3.30 ; 413 ; 1 ; 4 ; 97 ; 6 ; 0.00 ; 97 ; 0.00 ; 103 ; 2.70 ; 411 ; 30 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
				case 420: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 420, 5, "208 ; 1 ; 2 ; 5.2 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.00 ; 72 ; 5.2 ; 73 ; 5.2 ; 97 ; 0.00 ; 103 ; 5.2 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
				case 1337: // MLG PRO
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 1337, 5, "208 ; 1 ; 2 ; 14.37 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.00 ; 72 ; 14.37 ; 73 ; 14.37 ; 97 ; 0.00 ; 103 ; 14.37 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
				case 9001: // ITS OVER 9000
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 9001, 5, "208 ; 1 ; 2 ; 100 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.00 ; 72 ; 100 ; 73 ; 100 ; 97 ; 0.00 ; 103 ; 100 ; 411 ; 15 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
			}
		}
	}
}

// Custom Weaponset. I might eventually turn it into its own external config or something.
CheckWeapons(client)
{
	new weapon=GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
	new index=-1;
	// Primary
	if(weapon && IsValidEdict(weapon))
	{
		index=GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		switch(index)
		{
			case 15, 41, 202, 298, 654, 793, 802, 850, 882, 891, 900, 909, 958, 967: // Miniguns
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon=SpawnWeapon(client, "tf_weapon_minigun", 15, 5, 10, "375 ; 50");
				CPrintToChat(client, "Minigun:");
				CPrintToChat(client, "{blue}Generate Knockback rage by dealing damage. Use +attack3 when meter is full to use.");
			}
			case 18, 205, 237, 513, 658, 800, 809, 889, 898, 907, 916, 965, 974: // For other rocket launcher reskins
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon=SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 5, 10, "138 ; 0.70 ; 4 ; 2.0 ; 6 ; 0.25 ; 15 ; 1 ; 58 ; 4 ; 65 ; 1.30 ; 76 ; 6 ; 135 ; 0.30 ; 232 ; 10 ; 275 ; 1");
				CPrintToChat(client, "Rocket Launcher:");
				CPrintToChat(client, "{blue}+100& Clip Size");
				CPrintToChat(client, "{blue}+75% Faster firing speed");
				CPrintToChat(client, "{blue}+300% self damage push force");
				CPrintToChat(client, "{blue}+500% max primary ammo on wearer");
				CPrintToChat(client, "{blue}-70% Blast Damage from rocket jumps");
				CPrintToChat(client, "{blue}When the medic healing you is killed, you gain mini-crit boost for 10 seconds");
				CPrintToChat(client, "{blue}Wearer never takes fall damage");
				CPrintToChat(client, "{red}-30% Damage Penalty");
				CPrintToChat(client, "{red}-30% explosive damage vulnerability on wearer");
				CPrintToChat(client, "{red}No Random Critical Hits");
			}
			case 19, 206, 1007: // Grenade Launcher, Festive Grenade Launcher
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon=SpawnWeapon(client, "tf_weapon_grenadelauncher", 19, 5, 10, "2 ; 1.15 ; 4 ; 3 ; 6 ; 0.25 ; 97 ; 0.25 ; 76 ; 4.5 ; 470 ; 0.75");
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
				weapon=SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 5, 10, "103 ; 2 ; 114 ; 1 ; 100 ; 0.30 ; 2 ; 1.50 ; 15 ; 1 ; 179 ; 1 ; 488 ; 3 ; 621 ; 0.35 ; 643 ; 0.75 ; 644 ; 10");
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
				weapon=SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 5, 10, "4 ; 1.5 ; 6 ; 0.25 ; 15 ; 1 ; 16 ; 5 ; 58 ; 3 ; 76 ; 3.50 ; 100 ; 0.5 ; 135 ; 0.60 ; 233 ; 1.50 ; 234 ; 1.30");
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
				weapon=SpawnWeapon(client, "tf_weapon_grenadelauncher", 308, 5, 10, "2 ; 1.75 ; 3 ; 0.5 ; 6 ; 0.25 ; 97 ; 0.25 ; 76 ; 3 ; 127 ; 2");
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
				weapon=SpawnWeapon(client, "tf_weapon_minigun", 312, 5, 10, "2 ; 1.2 ; 86 ; 1.5 ; 183 ; 0.4 ; 375 ; 50");
				CPrintToChat(client, "Brass Beast:");
				CPrintToChat(client, "{blue}+20% Damage Bonus");
				CPrintToChat(client, "{blue}Generate Knockback rage by dealing damage. Use +attack3 when meter is full to use");
				CPrintToChat(client, "{red}+50% Slower Spin-up Time");
				CPrintToChat(client, "{red}-60% Slower move speed while deployed");
			}
			case 414: // Liberty Launcher
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon=SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 5, 10, "1 ; 0.75 ; 4 ; 1.75 ; 6 ; 0.4 ; 58 ; 3 ; 76 ; 3.50 ; 100 ; 0.85 ; 103 ; 2 ; 135 ; 0.50");
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
				weapon=SpawnWeapon(client, "tf_weapon_minigun", 424, 5, 10, "5 ; 1.1 ; 87 ; 1.1 ; 238 ; 1 ; 375 ; 50");
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
				weapon=SpawnWeapon(client, "tf_weapon_particle_cannon", 441, 5, 10, "2 ; 1.5 ; 58 ; 2 ; 281 ; 1 ; 282 ; 1 ; 288 ; 1 ; 366 ; 5");
				CPrintToChat(client, "Cow Mangler:");
				CPrintToChat(client, "{blue}+50% damage bonus");
				CPrintToChat(client, "{blue}+100% Self Damage Push Force");
				CPrintToChat(client, "{blue}No Ammo needed");
				CPrintToChat(client, "{blue}A successful hit mid-air stuns Blitzkrieg for 5 seconds");

			}
			case 730: //Beggar's Bazooka
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon=SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 5, 10, "135 ; 0.25 ; 58 ; 1.5 ; 2 ; 1.1 ; 4 ; 7.5 ; 6 ; 0 ; 76 ; 10 ; 97 ; 0.25 ; 411 ; 15 ; 413 ; 1 ; 417 ; 1");
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
				weapon=SpawnWeapon(client, "tf_weapon_minigun", 811, 5, 10, "71 ; 1.25 ; 76 ; 2 ; 206 ; 1.25 ; 375 ; 50 ; 430 ; 1 ; 431 ; 5");
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
				weapon=SpawnWeapon(client, "tf_weapon_cannon", 996, 5, 10, "2 ; 1.25 ; 4 ; 1.5 ; 6 ; 0.25 ; 97 ; 0.25 ; 76 ; 4 ; 466 ; 1 ; 467 ; 1 ; 470 ; 0.7");
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
				weapon=SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 5, 10, "1 ; 0.90 ; 15 ; 1 ; 179 ; 1 ; 232 ; 10 ; 488 ; 3 ; 621 ; 0.35 ; 642 ; 1 ; 643 ; 0.75 ; 644 ; 10");
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
				weapon=SpawnWeapon(client, "tf_weapon_shotgun_primary", 1153, 5, 10, "61 ; 1.5 ; 63 ; 1.5 ; 65 ; 1.5 ; 97 ; 0.77 ; 107 ; 1.7 ; 128 ; 1 ; 179 ; 1 ; 232 ; 15 ; 394 ; 0.85 ; 651 ; 0.5 ; 708 ; 1 ; 709 ; 1 ; 710 ; 1 ; 711 ; 1");	
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
				weapon=SpawnWeapon(client, "tf_weapon_grenadelauncher", 1151, 5, 10, "2 ; 1.10 ; 4 ; 5 ; 6 ; 0.25 ; 97 ; 0.25 ; 76 ; 6 ; 671 ; 1 ; 684 ; 0.6");
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
	if(weapon && IsValidEdict(weapon))
	{
		index=GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		switch(index)
		{
			case 39, 351, 740, 1081: // Flaregun, Detonator, Scorch Shot & Festive Flare Gun
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				weapon=SpawnWeapon(client, "tf_weapon_flaregun", 351, 5, 10, "25 ; 0.75 ; 65 ; 1.75 ; 207 ; 1.10 ; 144 ; 1 ; 58 ; 4.5 ; 20 ; 1 ; 22 ; 1 ; 551 ; 1 ; 15 ; 1");
				CPrintToChat(client, "Detonator:");
				CPrintToChat(client, "{blue}Crits vs Burning Players");
				CPrintToChat(client, "{blue}+450% self damage push force");
				CPrintToChat(client, "{red}No crits vs non-burning");
				CPrintToChat(client, "{red}No Random Critical Hits");
			}
			case 42, 863, 1002: // Sandvich, Robo-Sandvich & Festive Sandvich
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);					
				weapon=SpawnWeapon(client, "tf_weapon_lunchbox", 42, 5, 10, "144 ; 4 ; 278 ; 0.5");
				CPrintToChat(client, "Sandvich:");
				CPrintToChat(client, "{blue}+50% Faster Regen Rate");
			}
			case 129, 1001: // Buff Banner
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				weapon=SpawnWeapon(client, "tf_weapon_buff_item", 129, 5, 10, "26 ; 50 ; 116 ; 1 ; 292 ; 51 ; 319 ; 2.50");
				CPrintToChat(client, "Buff Banner:");
				CPrintToChat(client, "{blue}+150% longer buff duration");
				CPrintToChat(client, "{blue}+50% max health");
			}
			case 226: // Battalion's Backup
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				weapon=SpawnWeapon(client, "tf_weapon_buff_item", 226, 5, 10, "26 ; 50 ; 116 ; 2 ; 292 ; 51 ; 319 ; 2.50");
				CPrintToChat(client, "Battalion's Backup:");
				CPrintToChat(client, "{blue}+150% longer buff duration");
				CPrintToChat(client, "{blue}+50% max health");
			}
			case 354: // Concheror
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				weapon=SpawnWeapon(client, "tf_weapon_buff_item", 354, 5, 10, "26 ; 50 ; 57 ; 3 ; 116 ; 3 ; 292 ; 51 ; 319 ; 2.50");
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
						weapon=SpawnWeapon(client, "tf_weapon_shotgun_soldier", 1153, 5, 10, "61 ; 1.5 ; 63 ; 1.5 ; 65 ; 1.5 ; 97 ; 0.77 ; 107 ; 1.7 ; 128 ; 1 ; 179 ; 1 ; 232 ; 15 ; 394 ; 0.85 ; 651 ; 0.5 ; 708 ; 1 ; 709 ; 1 ; 710 ; 1 ; 711 ; 1");
					case TFClass_Pyro:
						weapon=SpawnWeapon(client, "tf_weapon_shotgun_pyro", 1153, 5, 10, "61 ; 1.5 ; 63 ; 1.5 ; 65 ; 1.5 ; 97 ; 0.77 ; 107 ; 1.7 ; 128 ; 1 ; 179 ; 1 ; 232 ; 15 ; 394 ; 0.85 ; 651 ; 0.5 ; 708 ; 1 ; 709 ; 1 ; 710 ; 1 ; 711 ; 1");
					case TFClass_Heavy:
						weapon=SpawnWeapon(client, "tf_weapon_shotgun_hwg", 1153, 5, 10, "61 ; 1.5 ; 63 ; 1.5 ; 65 ; 1.5 ; 97 ; 0.77 ; 107 ; 1.7 ; 128 ; 1 ; 179 ; 1 ; 232 ; 15 ; 394 ; 0.85 ; 651 ; 0.5 ; 708 ; 1 ; 709 ; 1 ; 710 ; 1 ; 711 ; 1");
					default: // For Randomizer Compatibility
						weapon=SpawnWeapon(client, "tf_weapon_shotgun_soldier", 1153, 5, 10, "61 ; 1.5 ; 63 ; 1.5 ; 65 ; 1.5 ; 97 ; 0.77 ; 107 ; 1.7 ; 128 ; 1 ; 179 ; 1 ; 232 ; 15 ; 394 ; 0.85 ; 651 ; 0.5 ; 708 ; 1 ; 709 ; 1 ; 710 ; 1 ; 711 ; 1");
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
				SpawnWeapon(client, "tf_weapon_medigun", 29, 5, 10, "499 ; 50.0 ; 10 ; 1.25 ; 178 ; 0.75 ; 144 ; 2.0 ; 11 ; 1.5 ; 482 ; 3 ; 493 ; 3");
				CPrintToChat(client, "Medigun:");
				CPrintToChat(client, "{blue}Use +attack3 (default middle mouse button) to deploy projectile shield");
				CPrintToChat(client, "{blue}Overheal Expert applied");
				CPrintToChat(client, "{blue}Healing Mastery applied");
				CPrintToChat(client, "{blue}+25% faster charge rate");
				CPrintToChat(client, "{blue}+25% faster weapon switch");
				CPrintToChat(client, "{blue}+50% overheal bonus");
			}
		}
	}
	// Melee Weapons
	weapon=GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	if(weapon && IsValidEdict(weapon))
	{
		index=GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		switch(index)
		{
			case 44:
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
				SpawnWeapon(client, "tf_weapon_bat_wood", 44, 5, 10, "38 ; 1 ; 125 ; -15 ; 249 ; 1.5 ; 279 ; 5");
				CPrintToChat(client, "Sandman:");	
				CPrintToChat(client, "{blue}+400% Max Misc Ammo");	
				CPrintToChat(client, "{blue}+50% Faster Recharge Rate");	
				CPrintToChat(client, "{blue}Alt-fire to launch baseball");			
				CPrintToChat(client, "{red}-15% Max Health");
				SetAmmo(client, TFWeaponSlot_Melee, 5);
			}
			
			case 648:
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
				SpawnWeapon(client, "tf_weapon_bat_giftwrap", 648, 5, 10, "1 , 0.3 ; 346 ; 1 ; 249 ; 1.5 ; 279 ; 5");
				CPrintToChat(client, "Wrap Assassin:");	
				CPrintToChat(client, "{blue}+400% Max Misc Ammo");	
				CPrintToChat(client, "{blue}+50% Faster Recharge Rate");	
				CPrintToChat(client, "{blue}Alt-fire to launch ornament");			
				CPrintToChat(client, "{red}-70% Damage Penalty");
				SetAmmo(client, TFWeaponSlot_Melee, 5);
			}
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
				SpawnWeapon(client, "tf_weapon_pda_engineer_build", 25, 5, 10, "113 ; 10 ; 276 ; 1 ; 286 ; 2.25 ; 287 ; 1.25 ; 321 ; 0.70 ; 345 ; 4");
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
			Format(text, sizeof(text), "%t", "help_scout");
		}
		case TFClass_Soldier:
		{
			Format(text, sizeof(text), "%t", "help_soldier");
		}
		case TFClass_Pyro:
		{
			Format(text, sizeof(text), "%t", "help_pyro");
		}
		case TFClass_DemoMan:
		{
			Format(text, sizeof(text), "%t", "help_demo");
		}
		case TFClass_Heavy:
		{
			Format(text, sizeof(text), "%t", "help_heavy");
		}
		case TFClass_Engineer:
		{
			Format(text, sizeof(text), "%t", "help_engy");
		}
		case TFClass_Medic:
		{
			Format(text, sizeof(text), "%t", "help_medic");
		}
		case TFClass_Sniper:
		{
			Format(text, sizeof(text), "%t", "help_sniper");
		}
		case TFClass_Spy:
		{
			Format(text, sizeof(text), "%t", "help_spy");
		}
	}
	new Handle:panel=CreatePanel();
	SetPanelTitle(panel, text);
	DrawPanelItem(panel, "Exit");
	SendPanelToClient(panel, client, HintPanelH, 20);
	CloseHandle(panel);
}

public HintPanelH(Handle:menu, MenuAction:action, client, selection)
{
	if(IsValidClient(client) && (action==MenuAction_Select || (action==MenuAction_Cancel && selection==MenuCancel_Exit)))
	{
		CPrintToChat(client, "%t", "good_luck");
	}
}


// ESSENTIAL CODE TO GET THE REANIMATOR WORKING
stock DropReanimator(client) 
{
	new clientTeam = GetClientTeam(client);
	reviveMarker[client] = CreateEntityByName("entity_revive_marker");
	if (reviveMarker[client] != -1)
	{
		SetEntPropEnt(reviveMarker[client], Prop_Send, "m_hOwner", client); // client index 
		SetEntProp(reviveMarker[client], Prop_Send, "m_nSolidType", 2); 
		SetEntProp(reviveMarker[client], Prop_Send, "m_usSolidFlags", 8); 
		SetEntProp(reviveMarker[client], Prop_Send, "m_fEffects", 16); 	
		SetEntProp(reviveMarker[client], Prop_Send, "m_iTeamNum", clientTeam); // client team 
		SetEntProp(reviveMarker[client], Prop_Send, "m_CollisionGroup", 1); 
		SetEntProp(reviveMarker[client], Prop_Send, "m_bSimulatedEveryTick", 1); 
		SetEntProp(reviveMarker[client], Prop_Send, "m_nBody", _:TF2_GetPlayerClass(client) - 1); 
		SetEntProp(reviveMarker[client], Prop_Send, "m_nSequence", 1); 
		SetEntPropFloat(reviveMarker[client], Prop_Send, "m_flPlaybackRate", 1.0);  
		SetEntProp(reviveMarker[client], Prop_Data, "m_iInitialTeamNum", clientTeam);
		SetEntDataEnt2(client, FindSendPropInfo("CTFPlayer", "m_nForcedSkin")+4, reviveMarker[client]);
		if(GetClientTeam(client) == 3)
			SetEntityRenderColor(reviveMarker[client], 0, 0, 255); // make the BLU Revive Marker distinguishable from the red one
		DispatchSpawn(reviveMarker[client]);
		CreateTimer(0.1, MoveMarker, GetClientUserId(client));
		if(decayTimers[client] == INVALID_HANDLE) 
		{
			decayTimers[client] = CreateTimer(float(decaytime), TimeBeforeRemoval, GetClientUserId(client));
		}
	} 
}

public Action:MoveMarker(Handle:timer, any:userid) 
{
	new client = GetClientOfUserId(userid);
	new Float:position[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", position);
	TeleportEntity(reviveMarker[client], position, NULL_VECTOR, NULL_VECTOR);
}

stock RemoveReanimator(client)
{
	currentTeam[client] = GetClientTeam(client);
	ChangeClass[client] = false;
	if (IsValidMarker(reviveMarker[client])) 
	{
		AcceptEntityInput(reviveMarker[client], "Kill");
	} 
	if (decayTimers[client] != INVALID_HANDLE) 
	{
		KillTimer(decayTimers[client]);
		decayTimers[client] = INVALID_HANDLE;
	}
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
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new boss = FF2_GetBossIndex(client);
	if (client < 1 || !IsValidEdict(client)) 
		return Plugin_Handled;
	if (boss != -1)
	{
		CreateTimer(0.2, CheckAbility, client);
		if(blitzisboss)
		{
			RemoveReanimator(client);
		}
	}
	return Plugin_Continue;
}

public Action:CheckAbility(Handle:hTimer, any: client)
{
	new boss=GetClientOfUserId(FF2_GetBossUserId(client));
	new b0ss=FF2_GetBossIndex(client);
	if(FF2_HasAbility(b0ss, this_plugin_name, "blitzkrieg_config"))
	{
		blitzisboss = true;
		bRdm = false;
		barrage = false;

		// Intro BGM
		EmitSoundToAll(BLITZROUNDSTART);
		
		// Custom Weapons
		customweapons=FF2_GetAbilityArgument(boss,this_plugin_name,"blitzkrieg_config", 3); // use custom weapons
		if(customweapons)
		{
			for(new i = 1; i <= MaxClients; i++ )
			{
				if(IsValidClient(i) && GetClientTeam(i) != FF2_GetBossTeam())
					TF2_RegeneratePlayer(i);
			}
		}
		
	}
}

public Action:OnPlayerInventory(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(blitzisboss)
	{
		if(customweapons)
		{
			if(IsClientInGame(client) && IsValidClient(client) && GetClientTeam(client)!=FF2_GetBossTeam())
			{		
				CheckWeapons(client);
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

public Action:TimeBeforeRemoval(Handle:timer, any:userid) 
{
	new client = GetClientOfUserId(userid);
	if(!IsValidMarker(reviveMarker[client]) || !IsClientInGame(client)) 
		return Plugin_Handled;
	RemoveReanimator(client);
	if(decayTimers[client] != INVALID_HANDLE)
	{
		KillTimer(decayTimers[client]);
		decayTimers[client] = INVALID_HANDLE;
	}
	return Plugin_Continue;
}

public OnClientDisconnect(client) 
{
	if(blitzisboss)
	{
		if(allowrevive)
		{
			RemoveReanimator(client);
		}
		currentTeam[client] = 0;
		ChangeClass[client] = false;
	}
 }

// Notification System:

public Action:CheckLevel(client, args)
{
	if(blitzisboss)
	{
		DisplayCurrentDifficulty(client);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:BlitzHelp(client, args)
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
		case 1:
			bDiff="Easy";
		case 2:
			bDiff="Normal";
		case 3:
			bDiff="Intermediate";
		case 4:
			bDiff="Difficult";
		case 5:
			bDiff="Lunatic";
		case 6:
			bDiff="Insane";
		case 7:
			bDiff="Godlike";
		case 8:
			bDiff="Rocket Hell";
		case 9:
			bDiff="Total Blitzkrieg";
		case 420:
			bDiff="MLG Pro - Level 420";
		case 1337:
			bDiff="MLG Pro - Level 1337";
		case 9001:
		{
			bDiff="OVER 9000!";
			EmitSoundToAll(OVER_9000);
			EmitSoundToAll(OVER_9000);
		}
	}
	switch(weapondifficulty)
	{
		case 0:
		{
			Format(msg, sizeof(msg), "%t", "blitz_inactive");
			CPrintToChatAll("%t", "blitz_inactive2");
		}
		default:
		{
			Format(msg, sizeof(msg), "%t", "blitz_difficulty", spcl, bDiff);
			CPrintToChatAll("%t", "blitz_difficulty2", spcl, bDiff);
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
    CreateTimer(2.5, KillGameText, iEntity);
}

public Action:KillGameText(Handle:hTimer, any:iEntity) 
{
    if ((iEntity > 0) && IsValidEntity(iEntity))
		AcceptEntityInput(iEntity, "kill"); 
    return Plugin_Stop;
}



// Stocks

stock SpawnWeapon(client,String:name[],index,level,qual,String:att[])
{
	new Handle:hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	TF2Items_SetClassname(hWeapon, name);
	TF2Items_SetItemIndex(hWeapon, index);
	TF2Items_SetLevel(hWeapon, level);
	TF2Items_SetQuality(hWeapon, qual);
	new String:atts[32][32];
	new count = ExplodeString(att, " ; ", atts, 32, 32);
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
	EquipPlayerWeapon(client, entity);
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
			EmitSoundToAll(BLITZROUNDEND);
			// Block sound from being played
			return Plugin_Handled;
		}
		return Plugin_Continue;
	}
	return Plugin_Continue;
}

public Action:OnRoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	// Here, we have a config for blitzkrieg's rounds //
	if (FF2_IsFF2Enabled())
	{
		dBoss = GetClientOfUserId(FF2_GetBossUserId());
		if(dBoss>0)
		{
			if (FF2_HasAbility(0, this_plugin_name, "blitzkrieg_config"))
			{	
				// Double Checking
				if(!blitzisboss || bRdm || barrage)
				{
					blitzisboss = true;
					bRdm = false;
					barrage = false;
				}
			
				// Custom Weapon Handler System
				if(!customweapons)
				{
					customweapons=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 3); // use custom weapons
					if(customweapons)
					{
						for(new i = 1; i <= MaxClients; i++ )
						{
							if(IsValidClient(i) && GetClientTeam(i) != FF2_GetBossTeam())
								TF2_RegeneratePlayer(i);
						}
					}
				}
			
				// Weapon Difficulty
				weapondifficulty=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 1, 2);
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
						PrintHintText(dBoss, "%t", "combatmode_nomelee");
						PlotTwist(dBoss);
					}
					case 0:
					{
						PrintHintText(dBoss, "%t", "combatmode_withmelee");
						PlotTwist(dBoss);
					}
				}

				// Misc
				voicelines=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 4); // Voice Lines
				allowrevive=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 8); // Allow Reanimator
				decaytime=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 9); // Reanimator decay time
				lvlup=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 12); // Allow Blitzkrieg to change difficulty level on random mode?
		
				DisplayCurrentDifficulty(dBoss);
				if(lvlup)
				{
					CreateTimer(6.0, WhatWereYouThinking);
				}
			}
		}
	}
}

public OnPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new attacker=GetClientOfUserId(GetEventInt(event, "attacker"));
	new client=GetClientOfUserId(GetEventInt(event, "userid"));
	new String:weapon[50];
	GetEventString(event, "weapon", weapon, sizeof(weapon));
	new aBoss=FF2_GetBossIndex(attacker);
	new vBoss=FF2_GetBossIndex(client);
	if(aBoss!=-1 || vBoss!=-1)
	{
		if(FF2_HasAbility(aBoss, this_plugin_name, "blitzkrieg_config"))
		{
			if((attacker!=client || attacker==client) && (GetClientTeam(client)!=FF2_GetBossTeam()))
			{
				if(allowrevive)
					DropReanimator(client);
			}
			
			if(StrEqual(weapon, "tf_projectile_rocket", false)||StrEqual(weapon, "airstrike", false)||StrEqual(weapon, "liberty_launcher", false)||StrEqual(weapon, "quake_rl", false)||StrEqual(weapon, "blackbox", false)||StrEqual(weapon, "dumpster_device", false)||StrEqual(weapon, "rocketlauncher_directhit", false)||StrEqual(weapon, "flamethrower", false))
			{
				SetEventString(event, "weapon", "firedeath");
			}
			
			else if(StrEqual(weapon, "ubersaw", false)||StrEqual(weapon, "market_gardener", false))
			{
				SetEventString(event, "weapon", "saw_kill");
			}

			new Float:rageonkill = FF2_GetAbilityArgumentFloat(aBoss,this_plugin_name,"blitzkrieg_config",13,0.0);
			new Float:bRage = FF2_GetBossCharge(aBoss,0);
			
			if(rageonkill)
			{
				if(100.0 - bRage < rageonkill) // We don't want RAGE to exceed more than 100%
					FF2_SetBossCharge(aBoss, 0, bRage + (100.0 - bRage));
				else if (100.0 - bRage > rageonkill)
					FF2_SetBossCharge(aBoss, 0, bRage+rageonkill);
			}
			
			if(GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon")==GetPlayerWeaponSlot(attacker, TFWeaponSlot_Primary))
			{
				if(combatstyle)
				{	
					TF2_RemoveWeaponSlot(attacker, TFWeaponSlot_Primary);
					if(barrage)
					{
						BlitzkriegBarrage(attacker);
						SetAmmo(attacker, TFWeaponSlot_Primary, blitzkriegrage);
					}
					else
					{
						RandomDanmaku(attacker);
						SetAmmo(attacker, TFWeaponSlot_Primary,999999);
					}		
				}	
			}
		}
		if(FF2_HasAbility(vBoss, this_plugin_name, "blitzkrieg_config"))
		{	
			if(attacker!=vBoss || attacker==vBoss)
			{
				CreateTimer(0.2, ResetBools, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
}	

public Action:OnRoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(blitzisboss)
	{
		if (GetEventInt(event, "winning_team") == FF2_GetBossTeam())
			BlitzIsWinner = true;
		else
			BlitzIsWinner = false;
		CreateTimer(5.0, RoundResultSound, TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(0.2, ResetBools, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action:ResetBools(Handle:hTimer, any:userid)
{
	for(new client = 1; client <= MaxClients; client++ )
	{
		if (crockethell!=INVALID_HANDLE)
		{
			CloseHandle(crockethell);
			crockethell = INVALID_HANDLE;
		}
		weapondifficulty = 0;
		allowrevive = 0;
		barrage = false;
		bRdm = false;
		blitzisboss = false;
		if(!blitzisboss)
			CPrintToChatAll("{blue}Blitzisboss = {red}false");
		else
			CPrintToChatAll("{blue}Blitzisboss = {green}true");
		CreateTimer(0.2, TimeBeforeRemoval, client);
	}
}

public Action: WhatWereYouThinking(Handle:hTimer, any:userid)
{
	new String:BlitzAlert[PLATFORM_MAX_PATH];
	strcopy(BlitzAlert, PLATFORM_MAX_PATH, BlitzCanLvlUp[GetRandomInt(0, sizeof(BlitzCanLvlUp)-1)]);
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

public Action:ItzBlitzkriegTime(Handle:hTimer,any:index)
{
	if(combatstyle)
	{
		new Boss=GetClientOfUserId(FF2_GetBossUserId(index));
		TF2_RemoveWeaponSlot(Boss, TFWeaponSlot_Primary);
		RandomDanmaku(Boss);	
		SetAmmo(Boss, TFWeaponSlot_Primary,999999);
	}
	barrage=false;
	crockethell = INVALID_HANDLE;
}

public Action:RemoveUber(Handle:hTimer,any:index)
{
	new Boss=GetClientOfUserId(FF2_GetBossUserId(index));
	SetEntProp(Boss, Prop_Data, "m_takedamage", 2);
	return Plugin_Continue;
}