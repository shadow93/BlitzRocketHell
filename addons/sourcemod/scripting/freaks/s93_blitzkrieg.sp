// The Blitzkrieg's abilities pack:
// blitzkrieg_config - Configuration for his rounds.
// blitzkrieg_barrage - Become ubercharged, crit boosted, change rocket launchers.
// mini_blitzkrieg - Identical to rage_blitzkrieg, but without ubercharge.
//
// Special thanks to Wolvan for the necessary code for the revive markers.
// (code ported to avoid the need to depend on another plugin for this)
// https://forums.alliedmods.net/showthread.php?t=244208
//
// Special thanks to BBG_Theory, M76030, Ravensbro, and VoiDED for pointing out bugs
//

#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2items>
#include <tf2_stocks>
#include <freak_fortress_2>
#include <freak_fortress_2_subplugin>
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

new bool:barrage = false;
new bool:blitzisboss = false;

// Reanimators

new allowrevive;
new decaytime;
new bool:ChangeClass[MAXPLAYERS+1] = { false, ... };
new reviveCount[MAXPLAYERS+1] = { 0, ... };
new currentTeam[MAXPLAYERS+1] = {0, ... };
new respawnMarkers[MAXPLAYERS+1] = { INVALID_ENT_REFERENCE, ... };
new Handle: decayTimers[MAXPLAYERS+1] = { INVALID_HANDLE, ... };

// Version Number
#define MAJOR_REVISION "2"
#define MINOR_REVISION "0"
#define DEV_REVISION "Beta"
#define BUILD_REVISION "(Experimental)"
#define PLUGIN_VERSION MAJOR_REVISION..."."...MINOR_REVISION..." "...DEV_REVISION..." "...BUILD_REVISION

#if defined _updater_included
#define UPDATE_URL "http://www.shadow93.info/tf2/tf2plugins/tf2danmaku/update.txt"
#define DEBUG   // This will enable verbose logging. Useful for developers testing their updates. 
#endif

public OnMapStart()
{
	// ROUND EVENTS
	PrecacheSound(BLITZROUNDSTART,true);
	PrecacheSound(BLITZROUNDEND, true);
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
}


public Plugin:myinfo = {
	name = "Freak Fortress 2: The Blitzkrieg",
	author = "SHADoW NiNE TR3S",
	description="TF2 Danmaku BETA",
	version=PLUGIN_VERSION,
};

public OnPluginStart2()
{
	HookEvent("teamplay_round_start", OnSetupTime, EventHookMode_PostNoCopy);
	HookEvent("arena_round_start", OnRoundStart, EventHookMode_PostNoCopy);
	HookEvent("arena_win_panel", OnRoundEnd, EventHookMode_PostNoCopy);
	HookEvent("teamplay_broadcast_audio", OnAnnounce, EventHookMode_Pre);
	HookEvent("player_death", OnPlayerDeath);
	HookEvent("player_death", PreDeath, EventHookMode_Pre);
	HookEvent("player_spawn", OnPlayerRevive, EventHookMode_Pre);
	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_PostNoCopy);
	HookEvent("player_changeclass", OnChangeClass);
	RegConsoleCmd("ff2_hp", CheckLevel);
	RegConsoleCmd("ff2hp", CheckLevel);
	RegConsoleCmd("hale_hp", CheckLevel);
	RegConsoleCmd("halehp", CheckLevel);
	decl String:steamid[256];
	for (new i = 1; i <= MaxClients; i++) 
	{
		if (IsClientInGame(i)) 
		{
			currentTeam[i] = GetClientTeam(i);
			ChangeClass[i] = false;
			GetClientAuthString(i, steamid, sizeof(steamid));
		}
		reviveCount[i] = 0;
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

public Action:FF2_OnAbility2(index,const String:plugin_name[],const String:ability_name[],action)
{
	if (!strcmp(ability_name,"blitzkrieg_barrage")) 	// UBERCHARGE, KRITZKRIEG & CROCKET HELL
	{	
		if (FF2_GetRoundState()==1)
		{
			barrage=true;
			new Boss=GetClientOfUserId(FF2_GetBossUserId(index));
			TF2_AddCondition(Boss,TFCond_Ubercharged,FF2_GetAbilityArgumentFloat(index,this_plugin_name,ability_name,1,5.0)); // Ubercharge
			CreateTimer(FF2_GetAbilityArgumentFloat(index,this_plugin_name,ability_name,1,5.0),RemoveUber,index);
			TF2_AddCondition(Boss,TFCond_Kritzkrieged,FF2_GetAbilityArgumentFloat(index,this_plugin_name,ability_name,2,5.0)); // Kritzkrieg
			SetEntProp(Boss, Prop_Data, "m_takedamage", 0);
			//Switching Blitzkrieg's player class while retaining the same model to switch the voice responses/commands
			PlotTwist(Boss);
			crockethell = CreateTimer(FF2_GetAbilityArgumentFloat(index,this_plugin_name,ability_name,3),ItzBlitzkriegTime,index);
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
		else if (FF2_GetRoundState()==2)
		{
			return Plugin_Stop;
		}
	}
	else if (!strcmp(ability_name,"mini_blitzkrieg")) 	// KRITZKRIEG & CROCKET HELL
	{		
		if (FF2_GetRoundState()==1)
		{	
			new Boss=GetClientOfUserId(FF2_GetBossUserId(index));
			TF2_AddCondition(Boss,TFCond_Kritzkrieged,FF2_GetAbilityArgumentFloat(index,this_plugin_name,ability_name,1,5.0)); // Kritzkrieg
			PrintToServer("*mini_blitzkrieg*");
			TF2_RemoveWeaponSlot(Boss, TFWeaponSlot_Primary);
			//RAGE Voice lines depending on Blitzkrieg's current player class (Blitzkrieg is two classes in 1 - Medic / Soldier soul in the same body)
			if(TF2_GetPlayerClass(Boss)==TFClass_Medic)
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
			else if(TF2_GetPlayerClass(Boss)==TFClass_Soldier)
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
			// Weapon switch depending if Blitzkrieg Barrage is active or not
			if(barrage==true)
			{
				BlitzkriegBarrage(Boss);
				SetAmmo(Boss, TFWeaponSlot_Primary,miniblitzkriegrage);
			}
			else
			{
				RandomDanmaku(Boss);
				switch(combatstyle)
				{
					case 1:
						SetAmmo(Boss, TFWeaponSlot_Primary,999999);
					case 0:
						SetAmmo(Boss, TFWeaponSlot_Primary,miniblitzkriegrage);
				}
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
		else if (FF2_GetRoundState()==2)
		{
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}

ClassResponses(client)
{
	PrintToServer("ClassResponses(client)");
	if(IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client)!=FF2_GetBossTeam())
	{
		if(TF2_GetPlayerClass(client)==TFClass_Scout)
		{
			switch (GetRandomInt(0,1))
			{
				case 0:
					EmitSoundToAll(SCOUT_R1,client);
				case 1:
					EmitSoundToAll(SCOUT_R2,client);
			}
		}
		else if(TF2_GetPlayerClass(client)==TFClass_Soldier)
		{
			EmitSoundToAll(SOLLY_R1,client);
		}
		else if(TF2_GetPlayerClass(client)==TFClass_Pyro)
		{
			EmitSoundToAll(PYRO_R1,client);
		}
		else if(TF2_GetPlayerClass(client)==TFClass_DemoMan)
		{
			EmitSoundToAll(DEMO_R1,client);
		}
		else if(TF2_GetPlayerClass(client)==TFClass_Heavy)
		{
			switch (GetRandomInt(0,1))
			{
				case 0:
					EmitSoundToAll(HEAVY_R1,client);
				case 1:	
					EmitSoundToAll(HEAVY_R2,client);
			}
		}
		else if(TF2_GetPlayerClass(client)==TFClass_Engineer)
		{
			switch (GetRandomInt(0,1))
			{
				case 0:
					EmitSoundToAll(ENGY_R1,client);
				case 1:
					EmitSoundToAll(ENGY_R2,client);
			}
		}	
		else if(TF2_GetPlayerClass(client)==TFClass_Medic)
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
		else if(TF2_GetPlayerClass(client)==TFClass_Sniper)
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
		else if(TF2_GetPlayerClass(client)==TFClass_Spy)
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

// Switch Roles ability
PlotTwist(client)
{
	if(barrage==true)
	{
		if(TF2_GetPlayerClass(client)==TFClass_Medic)
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
		else if(TF2_GetPlayerClass(client)==TFClass_Soldier)
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
	{
		if((owner=GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity"))<=MaxClients && owner>0 && GetClientTeam(owner)==FF2_GetBossTeam())
		{
			TF2_RemoveWearable(owner, entity);
		}
	}
	while((entity=FindEntityByClassname(entity, "tf_wearable_demoshield"))!=-1)
	{
		if((owner=GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity"))<=MaxClients && owner>0 && GetClientTeam(owner)==FF2_GetBossTeam())
		{
			TF2_RemoveWearable(owner, entity);
		}
	}
	while((entity=FindEntityByClassname(entity, "tf_powerup_bottle"))!=-1)
	{
		if((owner=GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity"))<=MaxClients && owner>0 && GetClientTeam(owner)==FF2_GetBossTeam())
		{
			TF2_RemoveWearable(owner, entity);
		}
	}
	// Restoring Melee (if using hybrid style), otherwise, giving Blitzkrieg just the death effect rocket launchers.
	// Also restores his B.A.S.E. Jumper
	SpawnWeapon(client, "tf_weapon_parachute", 1101, 109, 5, "700 ; 1 ; 701 ; 99 ; 702 ; 99 ; 703 ; 99 ; 705 ; 1 ; 640 ; 1 ; 68 ; 12 ; 269 ; 1 ; 275 ; 1");
	if(barrage==true)
		BlitzkriegBarrage(client);
	else
		if(startmode==1)
			RandomDanmaku(client);
	switch(combatstyle)
	{
		case 1:
			SetAmmo(client, TFWeaponSlot_Primary,999999);
		case 0:
		{
			if(TF2_GetPlayerClass(client)==TFClass_Medic)
				SpawnWeapon(client, "tf_weapon_knife", 1003, 109, 5, "2 ; 3 ; 138 ; 0.75 ; 39 ; 0.3 ; 267 ; 1 ; 391 ; 1.9 ; 401 ; 1.9 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6");
			else if(TF2_GetPlayerClass(client)==TFClass_Soldier)
				SpawnWeapon(client, "tf_weapon_knife", 416, 109, 5, "2 ; 3 ; 138 ; 0.75 ; 39 ; 0.3 ; 267 ; 1 ; 391 ; 1.9 ; 401 ; 1.9 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6");
			if(barrage==true)
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
			}
		}
		case 8: // Rocket Launcher
		{
			switch(weapondifficulty)
			{
				case 1: // Easy
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 100, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1 ; 413 ; 1 ; 1 ; 0.06 ; 4 ; 11 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.25"));
				case 2: // Normal
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 101, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 1 ; 0.13 ; 4 ; 22 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.60"));
				case 3: // Intermediate
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 102, 5, "642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 1 ; 0.18 ; 4 ; 25 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.32"));
				case 4: // Difficult
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 103, 5, "413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6 ; 138 ; 0.18 ; 4 ; 24 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.65"));
				case 5: // Lunatic
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 104, 5, "413 ; 1 ; 72 ; 0.25 ; 208 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7 ; 138 ; 0.23 ; 4 ; 32 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.20"));
				case 6: // Insane
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 105, 5, "411 ; 20 ; 72 ; 0.45 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3 ; 138 ; 0.46 ; 4 ; 34 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.20"));
				case 7: // Godlike
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 106, 5, "411 ; 18 ; 72 ; 0.65 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5 ; 138 ; 0.66 ; 4 ; 42 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.50"));
				case 8: // Rocket Hell
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 107, 5, "411 ; 29 ; 72 ; 0.85 ; 208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4 ; 138 ; 0.86 ; 4 ; 44 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.80"));
				case 9: // Total Blitzkrieg
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 108, 5, "208 ; 1 ; 413 ; 1 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2 ; 138 ; 0.80 ; 4 ; 55 ; 6 ; 0.03 ; 97 ; 0.01 ; 103 ; 1.24 ; 411 ; 35"));
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
			}
		}
		case 8: // Rocket Launcher
		{
			switch(weapondifficulty)
			{
				case 1: // Easy
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 100, 5, "1 ; 0.10 ; 413 ; 1 ; 4 ; 25 ; 6 ; 0.03 ; 97 ; 0.01 ; 104 ; 0.50 ; 411 ; 35 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
				case 2: // Normal
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 101, 5, "1 ; 0.20 ; 413 ; 1 ; 4 ; 40 ; 6 ; 0.03 ; 97 ; 0.01 ; 411 ; 35 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
				case 3: // Intermediate
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 102, 5, "1 ; 0.25 ; 413 ; 1 ; 4 ; 45 ; 6 ; 0.03 ; 97 ; 0.01 ; 411 ; 35 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
				case 4: // Difficult
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 103, 5, "72 ; 0.25 ; 208 ; 1 ; 138 ; 0.30 ; 413 ; 1 ; 4 ; 55 ; 6 ; 0.03 ; 97 ; 0.01 ; 411 ; 35 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 3"));
				case 5: // Lunatic
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 104, 5, "72 ; 0.45 ; 208 ; 1 ; 138 ; 0.50 ; 413 ; 1 ; 4 ; 65 ; 6 ; 0.03 ; 97 ; 0.01 ; 411 ; 35 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
				case 6: // Insane
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 105, 5, "72 ; 0.65 ; 208 ; 1 ; 138 ; 0.60 ; 413 ; 1 ; 4 ; 65 ; 6 ; 0.06 ; 97 ; 0.01 ; 103 ; 1.14 ; 411 ; 35 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
				case 7: // Godlike
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 106, 5, "72 ; 0.85 ; 208 ; 1 ; 2 ; 1.10 ; 413 ; 1 ; 4 ; 75 ; 6 ; 0.04 ; 97 ; 0.01 ; 103 ; 1.24 ; 411 ; 35 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
				case 8: // Rocket Hell
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 107, 5, "208 ; 1 ; 2 ; 2.20 ; 413 ; 1 ; 4 ; 85 ; 6 ; 0.02 ; 97 ; 0.01 ; 103 ; 1.48 ; 411 ; 35 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2002; 2014 ; 4"));
				case 9: // Total Blitzkrieg
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 108, 5, "208 ; 1 ; 2 ; 3.20 ; 413 ; 1 ; 4 ; 95 ; 6 ; 0.00 ; 97 ; 0.00 ; 103 ; 2.48 ; 411 ; 35 ; 642 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
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
			}
		}
	}
}

// Custom Weaponset. I might redo this section as a while statement unless it messes up if i do it as while statements.
PrimaryWeapons(client)
{
	new weapon=GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
	new index=-1;
	if(weapon && IsValidEdict(weapon))
	{
		index=GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		switch(index)
		{
			case 127: // Direct Hit
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon=SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 5, 10, "103 ; 2 ; 114 ; 1 ; 100 ; 0.30 ; 2 ; 1.50 ; 15 ; 1 ; 179 ; 1 ; 488 ; 3 ; 621 ; 0.35 ; 643 ; 0.75 ; 644 ; 10");
				PrintToChat(client, "Direct Hit:");
				PrintToChat(client, "+50% Damage bonus");
				PrintToChat(client, "+100% Projectile speed");
				PrintToChat(client, "Increased Attack speed while blast jumping");
				PrintToChat(client, "Rocket Specialist");
				PrintToChat(client, "Clip size increased as you deal damage");
				PrintToChat(client, "When the medic healing you is killed, you gain mini-crit boost for 10 seconds");
				PrintToChat(client, "Wearer never takes fall damage");
				PrintToChat(client, "Minicrits airborne targets");
				PrintToChat(client, "Minicrits become crits");
				PrintToChat(client, "-70% Explosion radius");
				PrintToChat(client, "No Random Critical Hits");
			}
			case 441: //Cow Mangler
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon=SpawnWeapon(client, "tf_weapon_particle_cannon", 441, 5, 10, "2 ; 1.5 ; 58 ; 2 ; 281 ; 1 ; 282 ; 1 ; 288 ; 1 ; 366 ; 5");
				PrintToChat(client, "Cow Mangler:");
				PrintToChat(client, "+50% damage bonus");
				PrintToChat(client, "+100% Self Damage Push Force");
				PrintToChat(client, "No Ammo needed");
				PrintToChat(client, "A successful hit mid-air stuns Blitzkrieg for 5 seconds");

			}
			case 228, 1085: // Black Box, Festive Black Box
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon=SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 5, 10, "4 ; 1.5 ; 6 ; 0.25 ; 15 ; 1 ; 16 ; 5 ; 58 ; 3 ; 76 ; 3.50 ; 100 ; 0.5 ; 135 ; 0.60 ; 233 ; 1.50 ; 234 ; 1.30");
				PrintToChat(client, "Black Box:");
				PrintToChat(client, "+50% Clip Size");
				PrintToChat(client, "On-Hit: +5 Health");
				PrintToChat(client, "+75% Faster Firing Speed");
				PrintToChat(client, "+200% Self Damage Push Force");
				PrintToChat(client, "+250% Max Primary Ammo");
				PrintToChat(client, "-40% Blast Damage from rocket jumps");
				PrintToChat(client, "While a medic is healing you, this weapon's damage is increased by +50%");
				PrintToChat(client, "No Random Critical Hits");
				PrintToChat(client, "-50% Blast Radius");
				PrintToChat(client, "While not being healed by a medic, your weapon switch time is +30% longer");
			}
			case 414: // Liberty Launcher
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon=SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 5, 10, "1 ; 0.75 ; 4 ; 1.75 ; 6 ; 0.4 ; 58 ; 3 ; 76 ; 3.50 ; 100 ; 0.85 ; 103 ; 2 ; 135 ; 0.50");
				PrintToChat(client, "Liberty Launcher:");
				PrintToChat(client, "-25% Damage Penalty");
				PrintToChat(client, "+75% Clip Size");
				PrintToChat(client, "+60% Faster Firing Speed");
				PrintToChat(client, "+200% Self Damage Push Force");
				PrintToChat(client, "+250% Max Primary Ammo");
				PrintToChat(client, "-50% Blast Damage from rocket jumps");
				PrintToChat(client, "-15% Blast Radius");
			}
			case 730: //Beggar's Bazooka
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon=SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 5, 10, "135 ; 0.25 ; 58 ; 1.5 ; 2 ; 1.1 ; 4 ; 7.5 ; 6 ; 0 ; 76 ; 10 ; 97 ; 0.40 ; 411 ; 15 ; 413 ; 1 ; 417 ; 1");
				PrintToChat(client, "Beggar's Bazooka:");
				PrintToChat(client, "+10% Damage Bonus");
				PrintToChat(client, "+650% Clip Size");
				PrintToChat(client, "+85% Faster Firing Speed");
				PrintToChat(client, "+50% Self Damage Push Force");
				PrintToChat(client, "+1000% Max Primary Ammo");
				PrintToChat(client, "+50% Faster reload speed");
				PrintToChat(client, "-75% Blast Damage from rocket jumps");
				PrintToChat(client, "+30 Degrees Random Projectile Deviation");
				PrintToChat(client, "Hold Fire to load up to 30 Rockets");
				PrintToChat(client, "Overloading will Misfire");
			}
			case 1104: // Air Strike
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon=SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 5, 10, "1 ; 0.90 ; 15 ; 1 ; 179 ; 1 ; 232 ; 10 ; 488 ; 3 ; 621 ; 0.35 ; 642 ; 1 ; 643 ; 0.75 ; 644 ; 10");
				PrintToChat(client, "Air Strike:");
				PrintToChat(client, "Increased Attack speed while blast jumping");
				PrintToChat(client, "Rocket Specialist");
				PrintToChat(client, "Clip size increased as you deal damage");
				PrintToChat(client, "When the medic healing you is killed, you gain mini-crit boost for 10 seconds");
				PrintToChat(client, "Wearer never takes fall damage");
				PrintToChat(client, "-10% Damage Penalty");
				PrintToChat(client, "No Random Critical Hits");
			}
			case 18, 205, 237, 513, 658, 800, 809, 889, 898, 907, 916, 965, 974: // For other rocket launcher reskins
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon=SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 5, 10, "138 ; 0.70 ; 4 ; 2.0 ; 6 ; 0.25 ; 15 ; 1 ; 58 ; 4 ; 65 ; 1.30 ; 76 ; 6 ; 135 ; 0.30 ; 232 ; 10 ; 275 ; 1");
				PrintToChat(client, "Rocket Launcher:");
				PrintToChat(client, "+100& Clip Size");
				PrintToChat(client, "+75% Faster firing speed");
				PrintToChat(client, "+300% self damage push force");
				PrintToChat(client, "+500% max primary ammo on wearer");
				PrintToChat(client, "-70% Blast Damage from rocket jumps");
				PrintToChat(client, "When the medic healing you is killed, you gain mini-crit boost for 10 seconds");
				PrintToChat(client, "Wearer never takes fall damage");
				PrintToChat(client, "-30% Damage Penalty");
				PrintToChat(client, "-30% explosive damage vulnerability on wearer");
				PrintToChat(client, "No Random Critical Hits");
			}
			case 1153: // Panic Attack
			{
				if(TF2_GetPlayerClass(client)==TFClass_Engineer)
				{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
					weapon=SpawnWeapon(client, "tf_weapon_shotgun_primary", 1153, 5, 10, "61 ; 1.5 ; 63 ; 1.5 ; 65 ; 1.5 ; 97 ; 0.77 ; 107 ; 1.7 ; 128 ; 1 ; 179 ; 1 ; 232 ; 15 ; 394 ; 0.85 ; 651 ; 0.5 ; 708 ; 1 ; 709 ; 1 ; 710 ; 1 ; 711 ; 1");	
					PrintToChat(client, "Panic Attack (while active):");
					PrintToChat(client, "+75& Faster move speed");
					PrintToChat(client, "+34% faster reload time");
					PrintToChat(client, "When the medic healing you is killed, you gain mini crits for 15 seconds");
					PrintToChat(client, "+50% blast, fire & crit damage vulnerability");
					PrintToChat(client, "Hold fire to load up to 6 shells");
					PrintToChat(client, "Fire rate increases as health decreases");
					PrintToChat(client, "Weapon spread increases as health decreases");
				}
			}
		}
	}
}

SecondaryWeapons(client)
{
	new weapon=GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	new index=-1;
	if(weapon && IsValidEdict(weapon))
	{
		index=GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		switch(index)
		{
			case 39, 351, 740, 1081: // Flaregun, Detonator, Scorch Shot & Festive Flare Gun
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				weapon=SpawnWeapon(client, "tf_weapon_flaregun", 351, 5, 10, "1 ; 0.75 ; 25 ; 0.75 ; 65 ; 1.75 ; 207 ; 1.10 ; 144 ; 1 ; 58 ; 4.5 ; 20 ; 1 ; 22 ; 1 ; 551 ; 1 ; 15 ; 1");
				PrintHintText(client, "Detonator deals crits vs burning players. No random crits. -25% damage penalty.");
				PrintToChat(client, "Detonator:");
				PrintToChat(client, "Crits vs Burning Players");
				PrintToChat(client, "+450% self damage push force");
				PrintToChat(client, "-25% damage penalty");
				PrintToChat(client, "No crits vs non-burning");
				PrintToChat(client, "No Random Critical Hits");
			}
			case 42, 863, 1002: // Sandvich, Robo-Sandvich & Festive Sandvich
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);					
				weapon=SpawnWeapon(client, "tf_weapon_lunchbox", 42, 5, 10, "144 ; 4 ; 278 ; 0.5");
				PrintToChat(client, "Sandvich:");
				PrintToChat(client, "+50% Faster Regen Rate");
			}
			case 129, 1001: // Buff Banner
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				weapon=SpawnWeapon(client, "tf_weapon_buff_item", 129, 5, 10, "26 ; 50 ; 116 ; 1 ; 292 ; 51 ; 319 ; 2.50");
				PrintHintText(client, "+150% longer buff duration, +50 Max HP");
				PrintToChat(client, "Buff Banner:");
				PrintToChat(client, "+150% longer buff duration");
				PrintToChat(client, "+50% max health");
			}
			case 226: // Battalion's Backup
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				weapon=SpawnWeapon(client, "tf_weapon_buff_item", 226, 5, 10, "26 ; 50 ; 116 ; 2 ; 292 ; 51 ; 319 ; 2.50");
				PrintToChat(client, "Battalion's Backup:");
				PrintToChat(client, "+150% longer buff duration");
				PrintToChat(client, "+50% max health");
			}
			case 354: // Concheror
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				weapon=SpawnWeapon(client, "tf_weapon_buff_item", 354, 5, 10, "26 ; 50 ; 57 ; 3 ; 116 ; 3 ; 292 ; 51 ; 319 ; 2.50");
				PrintToChat(client, "Concheror:");
				PrintToChat(client, "+150% longer buff duration");
				PrintToChat(client, "+50% max health");
			}
			case 1153: // Panic Attack
			{
				if(TF2_GetPlayerClass(client)==TFClass_Soldier||TF2_GetPlayerClass(client)==TFClass_Pyro||TF2_GetPlayerClass(client)==TFClass_Heavy)
				{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
					if(TF2_GetPlayerClass(client)==TFClass_Soldier)
						weapon=SpawnWeapon(client, "tf_weapon_shotgun_soldier", 1153, 5, 10, "61 ; 1.5 ; 63 ; 1.5 ; 65 ; 1.5 ; 97 ; 0.77 ; 107 ; 1.7 ; 128 ; 1 ; 179 ; 1 ; 232 ; 15 ; 394 ; 0.85 ; 651 ; 0.5 ; 708 ; 1 ; 709 ; 1 ; 710 ; 1 ; 711 ; 1");
					if(TF2_GetPlayerClass(client)==TFClass_Pyro)
						weapon=SpawnWeapon(client, "tf_weapon_shotgun_pyro", 1153, 5, 10, "61 ; 1.5 ; 63 ; 1.5 ; 65 ; 1.5 ; 97 ; 0.77 ; 107 ; 1.7 ; 128 ; 1 ; 179 ; 1 ; 232 ; 15 ; 394 ; 0.85 ; 651 ; 0.5 ; 708 ; 1 ; 709 ; 1 ; 710 ; 1 ; 711 ; 1");
					if(TF2_GetPlayerClass(client)==TFClass_Heavy)
						weapon=SpawnWeapon(client, "tf_weapon_shotgun_hwg", 1153, 5, 10, "61 ; 1.5 ; 63 ; 1.5 ; 65 ; 1.5 ; 97 ; 0.77 ; 107 ; 1.7 ; 128 ; 1 ; 179 ; 1 ; 232 ; 15 ; 394 ; 0.85 ; 651 ; 0.5 ; 708 ; 1 ; 709 ; 1 ; 710 ; 1 ; 711 ; 1");
					PrintToChat(client, "Panic Attack (while active):");
					PrintToChat(client, "+75& Faster move speed");
					PrintToChat(client, "+34% faster reload time");
					PrintToChat(client, "When the medic healing you is killed, you gain mini crits for 15 seconds");
					PrintToChat(client, "+50% blast, fire & crit damage vulnerability");
					PrintToChat(client, "Hold fire to load up to 6 shells");
					PrintToChat(client, "Fire rate increases as health decreases");
					PrintToChat(client, "Weapon spread increases as health decreases");
				}
			}
			case 29, 35, 211, 411, 663, 796, 805, 885, 894, 903, 912, 961, 970, 998:
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				SpawnWeapon(client, "tf_weapon_medigun", 29, 5, 10, "499 ; 50.0 ; 10 ; 1.25 ; 178 ; 0.75 ; 144 ; 2.0 ; 11 ; 1.5 ; 482 ; 3 ; 493 ; 3");
				PrintToChat(client, "Medigun:");
				PrintToChat(client, "Use +attack3 (default middle mouse button) to deploy projectile shield");
				PrintToChat(client, "Overheal Expert applied");
				PrintToChat(client, "Healing Mastery applied");
				PrintToChat(client, "+25% faster charge rate");
				PrintToChat(client, "+25% faster weapon switch");
				PrintToChat(client, "+50% overheal bonus");
			}
		}
	}
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


// ESSENTIAL CODE TO GET THE REANIMATOR WORKING

public bool:DropReanimator(client) 
{
	PrintToServer("DropReanimator(client)");
	// spawn the Revive Marker
	new clientTeam = GetClientTeam(client);
	new reviveMarker = CreateEntityByName("entity_revive_marker");
	if (reviveMarker != -1)
	{
		SetEntPropEnt(reviveMarker, Prop_Send, "m_hOwner", client); // client index 
		SetEntProp(reviveMarker, Prop_Send, "m_nSolidType", 2); 
		SetEntProp(reviveMarker, Prop_Send, "m_usSolidFlags", 8); 
		SetEntProp(reviveMarker, Prop_Send, "m_fEffects", 16); 
		SetEntProp(reviveMarker, Prop_Send, "m_iTeamNum", clientTeam); // client team 
		SetEntProp(reviveMarker, Prop_Send, "m_CollisionGroup", 1); 
		SetEntProp(reviveMarker, Prop_Send, "m_bSimulatedEveryTick", 1);
		SetEntDataEnt2(client, FindSendPropInfo("CTFPlayer", "m_nForcedSkin")+4, reviveMarker);
		SetEntProp(reviveMarker, Prop_Send, "m_nBody", _:TF2_GetPlayerClass(client) - 1); // character hologram that is shown
		SetEntProp(reviveMarker, Prop_Send, "m_nSequence", 1); 
		SetEntPropFloat(reviveMarker, Prop_Send, "m_flPlaybackRate", 1.0);
		SetEntProp(reviveMarker, Prop_Data, "m_iInitialTeamNum", clientTeam);
		// call Forward
		new Action:result = Plugin_Continue;
		Call_PushCell(client);
		Call_PushCell(reviveMarker);
		Call_Finish(result);
		
		if (result == Plugin_Handled) {
			return false;
		} else if (result == Plugin_Stop) {
			AcceptEntityInput(reviveMarker, "Kill");
			return false;
		}
		DispatchSpawn(reviveMarker);
		respawnMarkers[client] = EntIndexToEntRef(reviveMarker);
		if(decayTimers[client] == INVALID_HANDLE) 
		{
			decayTimers[client] = CreateTimer(float(decaytime), TimeBeforeRemoval, GetClientUserId(client));
		}
		CreateTimer(0.1, TransmitMarker, GetClientUserId(client));
		return true;
	} 
	else 
	{
		return false;
	}
}

public bool:RemoveReanimator(client)
	{
	// call Forward
	new Action:result = Plugin_Continue;
	Call_PushCell(client);
	Call_PushCell(respawnMarkers[client]);
	Call_Finish(result);
	
	if (result == Plugin_Handled || result == Plugin_Stop) {
		return false;
	}
	
	if(!IsClientInGame(client)) {
		return false;
	}
	
	// set team and class change variable
	currentTeam[client] = GetClientTeam(client);
	ChangeClass[client] = false;
	
	
	// kill Revive Marker if it exists
	if (IsValidMarker(respawnMarkers[client])) {
		if(GetEntProp(respawnMarkers[client],Prop_Send,"m_iHealth") >= GetEntProp(respawnMarkers[client],Prop_Send,"m_iMaxHealth")) {
			reviveCount[client]++;
		}
		AcceptEntityInput(respawnMarkers[client], "Kill");
		respawnMarkers[client] = INVALID_ENT_REFERENCE;
	} 
	else 
	{
		return false;
	}
	
	// kill Decay Timer when it exists
	if (decayTimers[client] != INVALID_HANDLE) 
	{
		KillTimer(decayTimers[client]);
		decayTimers[client] = INVALID_HANDLE;
	}
	return true;
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

public Action:OnPlayerRevive(Handle:event, const String:name[], bool:dontbroadcast) 
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(blitzisboss==true)
	{
		RemoveReanimator(client);
	}
	else
		return Plugin_Stop;
	return Plugin_Continue;
}

public Action:OnPlayerSpawn(Handle:event, const String:name[], bool:dontbroadcast) 
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(blitzisboss==true)
	{
		CreateTimer(0.1, CheckItems, client);
	}
	else
		return Plugin_Stop;
	return Plugin_Continue;
}

public Action:OnChangeClass(Handle:event, const String:name[], bool:dontbroadcast) 
{
	if(blitzisboss==true)
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		ChangeClass[client] = true;
		CreateTimer(0.1, CheckItems, client);
	}
	else
		return Plugin_Stop;
	return Plugin_Continue;
}

public Action:TransmitMarker(Handle:timer, any:userid) {
	new client = GetClientOfUserId(userid);
	if(!IsValidMarker(respawnMarkers[client]) || !IsClientInGame(client)) {
		return;
	}
	// get position to teleport the Marker to
	new Float:position[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", position);
	TeleportEntity(respawnMarkers[client], position, NULL_VECTOR, NULL_VECTOR);
}

public Action:TimeBeforeRemoval(Handle:timer, any:userid) {
	
	new client = GetClientOfUserId(userid);
	
	if(!IsValidMarker(respawnMarkers[client]) || !IsClientInGame(client)) {
		return;
	}
	
	// call Forward
	new Action:result = Plugin_Continue;
	Call_PushCell(client);
	Call_PushCell(respawnMarkers[client]);
	Call_Finish(result);
	
	if (result == Plugin_Handled || result == Plugin_Stop) {
		return;
	}
	
	RemoveReanimator(client);
	if(decayTimers[client] != INVALID_HANDLE) {
		KillTimer(decayTimers[client]);
		decayTimers[client] = INVALID_HANDLE;
	}
}

public OnClientDisconnect(client) 
{
	// remove the marker
	RemoveReanimator(client);
	
	// reset storage array values
	currentTeam[client] = 0;
	ChangeClass[client] = false;
	reviveCount[client] = 0;
 }

// Notification System:

public Action:CheckLevel(client, args)
{
	if(blitzisboss==true)
	{
		DisplayCurrentDifficulty(client);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:PostSetup(Handle:hTimer, any:userid)
{
	// Because the previous method was acting up and not giving the weapons as its supposed to.
	for(new client = 1; client <= MaxClients; client++ )
	{
		if(customweapons!=0)
			if(IsClientInGame(client) && IsPlayerAlive(client) && IsValidClient(client) && GetClientTeam(client)!=FF2_GetBossTeam())
			{		
				PrimaryWeapons(client);
				SecondaryWeapons(client);
				if(TF2_GetPlayerClass(client)==TFClass_Engineer)
				{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Grenade);
					SpawnWeapon(client, "tf_weapon_pda_engineer_build", 25, 5, 10, "113 ; 10 ; 276 ; 1 ; 286 ; 2.25 ; 287 ; 1.25 ; 321 ; 0.70 ; 345 ; 4");
					PrintToChat(client, "Construction PDA:");
					PrintToChat(client, "Teleporters are bi-directional");
					PrintToChat(client, "+10 Metal regenerated every 5 seconds");
					PrintToChat(client, "+300% Dispenser range");
					PrintToChat(client, "+30% Faster build speed");
					PrintToChat(client, "+150% Building Health");
					PrintToChat(client, "+25% Faster sentry firing speed");
					PrintToChat(client, "+25% Sentry damage bonus");
				}
			}
	}
}

DisplayCurrentDifficulty(client)
{
	decl String:msg[1024];
	switch(weapondifficulty)
	{
		case 1:
		{
			Format(msg, sizeof(msg), "Blitzkrieg's Current Difficulty Level: Easy");
			CPrintToChatAll("[FF2] The Blitzkrieg's Difficulty: Easy");
			PrintHintText(client,"Difficulty: Easy");
		}
		case 2:
		{
			Format(msg, sizeof(msg), "Blitzkrieg's Current Difficulty Level: Normal");
			CPrintToChatAll("[FF2] Blitzkrieg's Difficulty: Normal");
			PrintHintText(client,"Difficulty: Normal");
		}
		case 3:
		{
			Format(msg, sizeof(msg), "Blitzkrieg's Current Difficulty Level: Intermediate");
			CPrintToChatAll("[FF2] The Blitzkrieg's Difficulty: Intermediate");
			PrintHintText(client,"Difficulty: Intermediate");
		}
		case 4:
		{
			Format(msg, sizeof(msg), "Blitzkrieg's Current Difficulty Level: Difficult");
			CPrintToChatAll("[FF2] The Blitzkrieg's Difficulty: Difficult");
			PrintHintText(client,"Difficulty: Difficult");
		}
		case 5:
		{
			Format(msg, sizeof(msg), "Blitzkrieg's Current Difficulty Level: Lunatic");
			PrintHintText(client,"Difficulty: Lunatic");
		}
		case 6:
		{
			Format(msg, sizeof(msg), "Blitzkrieg's Current Difficulty Level: Insane");
			CPrintToChatAll("[FF2] The Blitzkrieg's Difficulty: Insane");
			PrintHintText(client,"Difficulty: Insane");
		}
		case 7:
		{
			Format(msg, sizeof(msg), "Blitzkrieg's Current Difficulty Level: Godlike");
			CPrintToChatAll("[FF2] The Blitzkrieg's Difficulty: Godlike");
			PrintHintText(client,"Difficulty: Godlike");
		}
		case 8:
		{
			Format(msg, sizeof(msg), "Blitzkrieg's Current Difficulty Level: Rocket Hell");
			CPrintToChatAll("[FF2] The Blitzkrieg's Difficulty: Rocket Hell");
			PrintHintText(client,"Difficulty: Rocket Hell");
		}
		case 9:
		{
			Format(msg, sizeof(msg), "Blitzkrieg's Current Difficulty Level: Total Blitzkrieg");
			CPrintToChatAll("[FF2] The Blitzkrieg's Difficulty: Total Blitzkrieg");
			PrintHintText(client,"Difficulty: Total Blitzkrieg");
		}
		default:
		{
			Format(msg, sizeof(msg), "Please wait until round has started to check difficulty!");
			CPrintToChatAll("[FF2] The Blitzkrieg: Please wait until round has started!");
			PrintHintText(client,"Please wait until round has started to check difficulty!");
		}
	}
	ShowGameText(msg);
}

ShowGameText(const String:strMessage[]) 
{
    new iEntity = CreateEntityByName("game_text_tf");
    DispatchKeyValue(iEntity,"message", strMessage);
    DispatchKeyValue(iEntity,"display_to_team", "0");
    DispatchKeyValue(iEntity,"icon", "firedeath");
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
	if (IsClientSourceTV(client) || IsClientReplay(client)) return false;
	return true;
}

public Action:CheckItems(Handle:hTimer, any:client)
{
	if(IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client)!=FF2_GetBossTeam())
	{
		PrimaryWeapons(client);
		SecondaryWeapons(client);
		if(TF2_GetPlayerClass(client)==TFClass_Engineer)
		{
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Grenade);
			SpawnWeapon(client, "tf_weapon_pda_engineer_build", 25, 5, 10, "113 ; 10 ; 276 ; 1 ; 286 ; 2.25 ; 287 ; 1.25 ; 321 ; 0.70 ; 345 ; 4");
			PrintToChat(client, "Construction PDA:");
			PrintToChat(client, "Teleporters are bi-directional");
			PrintToChat(client, "+10 Metal regenerated every 5 seconds");
			PrintToChat(client, "+300% Dispenser range");
			PrintToChat(client, "+30% Faster build speed");
			PrintToChat(client, "+150% Building Health");
			PrintToChat(client, "+25% Faster sentry firing speed");
			PrintToChat(client, "+25% Sentry damage bonus");
		}
	}
}

// Events

public Action:OnSetupTime(Handle:event, const String:name[], bool:dontBroadcast)
{
	// Events During Setup Time
	if (FF2_IsFF2Enabled())
	{
		dBoss=GetClientOfUserId(FF2_GetBossUserId());
		if (dBoss>0)
		{
			if (FF2_HasAbility(0, this_plugin_name, "blitzkrieg_config"))
			{	
				CreateTimer(0.5,GetSetup,dBoss);
			}
			else
				return Plugin_Handled;
		}
		return Plugin_Continue;
	}
	return Plugin_Continue;
}

public Action:GetSetup(Handle:hTimer, any:userid)
{
	new Boss=GetClientOfUserId(FF2_GetBossUserId(userid));
	blitzisboss = true;
	barrage = false;
	customweapons=FF2_GetAbilityArgument(Boss,this_plugin_name,"blitzkrieg_config", 3); // use custom weapons
	EmitSoundToAll(BLITZROUNDSTART);
}

public Action:OnAnnounce(Handle:event, const String:name[], bool:dontBroadcast) // Thanks pheadxdll
{
	if(blitzisboss==true)
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
		switch(FF2_GetBossUserId())
		{
			case 0:
				CPrintToChatAll("[FF2] index = 0");
			case 1:
				CPrintToChatAll("[FF2] index = 1");
			case 2:
				CPrintToChatAll("[FF2] index = 2");
			case 3:
				CPrintToChatAll("[FF2] index = 3");
			case 4:
				CPrintToChatAll("[FF2] index = 4");
			case 5:
				CPrintToChatAll("[FF2] index = 5");
			case 6:
				CPrintToChatAll("[FF2] index = 6");
			case 7:
				CPrintToChatAll("[FF2] index = 7");
			case 8:
				CPrintToChatAll("[FF2] index = 8");
			case 9:
				CPrintToChatAll("[FF2] index = 9");
		}
		if(dBoss>0)
		{
			if (FF2_HasAbility(0, this_plugin_name, "blitzkrieg_config"))
			{	
				if(blitzisboss==false)
					blitzisboss = true;
				if(barrage==true)
					barrage = false;
				weapondifficulty=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 1, 2);
				combatstyle=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 2);
				if(customweapons==0) // Just to double check
					customweapons=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 3); // use custom weapons (failsafe)
				voicelines=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 4); // Voice Lines
				miniblitzkriegrage=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 5); // RAGE/Weaponswitch Ammo
				blitzkriegrage=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 6); // Blitzkrieg Rampage Ammo
				startmode=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 7); // Start with launcher or no (with melee mode)
				allowrevive=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 8); // Allow Reanimator
				decaytime=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 9); // Reanimator decay time
				if(weapondifficulty==0)
					weapondifficulty=GetRandomInt(1,9);
				switch(combatstyle)
				{
					case 1:
					{
						PrintHintText(dBoss, "You must rely on your rockets to finish enemies off!");
						PlotTwist(dBoss);
					}
					case 0:
					{
						PrintHintText(dBoss, "Use your melee weapon to finish off nearby enemies!");
						PlotTwist(dBoss);
					}
				}
				if(customweapons!=0)
					CreateTimer(0.1, PostSetup);
				DisplayCurrentDifficulty(dBoss);
			}
		}
	}
}

public PreDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new attacker=GetClientOfUserId(GetEventInt(event, "attacker"));
	new String:weapon[50];
	GetEventString(event, "weapon", weapon, sizeof(weapon));
	new bossAttacker=FF2_GetBossIndex(attacker);
	if(bossAttacker!=-1)
	{
		if(FF2_HasAbility(bossAttacker, this_plugin_name, "blitzkrieg_config"))
		{
			if(StrEqual(weapon, "tf_projectile_rocket", false)||StrEqual(weapon, "airstrike", false)||StrEqual(weapon, "liberty_launcher", false)||StrEqual(weapon, "quake_rl", false)||StrEqual(weapon, "blackbox", false)||StrEqual(weapon, "dumpster_device", false)||StrEqual(weapon, "rocketlauncher_directhit", false)||StrEqual(weapon, "flamethrower", false))
			{
				SetEventString(event, "weapon", "firedeath");
			}
			else if(StrEqual(weapon, "ubersaw", false)||StrEqual(weapon, "market_gardener", false))
			{
				SetEventString(event, "weapon", "saw_kill");
			}
		}
	}
}	

public Action:OnPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new attacker=GetClientOfUserId(GetEventInt(event, "attacker"));
	new client=GetClientOfUserId(GetEventInt(event, "userid"));
	new bossAttacker=FF2_GetBossIndex(attacker);
	if(blitzisboss==true)
		if(attacker!=client && (GetClientTeam(client)!=FF2_GetBossTeam()) || attacker==client && (GetClientTeam(client)!=FF2_GetBossTeam()))
			if(allowrevive!=0)
				DropReanimator(client);
	if(bossAttacker!=-1)
	{
		if(FF2_HasAbility(bossAttacker, this_plugin_name, "blitzkrieg_config"))
		{
			if(GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon")==GetPlayerWeaponSlot(attacker, TFWeaponSlot_Primary))
			{
				if(combatstyle!=0)
				{	
					TF2_RemoveWeaponSlot(attacker, TFWeaponSlot_Primary);
					if(barrage==true)
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
	}
	return Plugin_Continue;
}

public Action:OnRoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (crockethell!=INVALID_HANDLE)
	{
		CloseHandle(crockethell);
		crockethell = INVALID_HANDLE;
	}
	weapondifficulty=0;
	barrage=false;
	blitzisboss=false;
}

public Action:FF2_OnTriggerHurt(userid,triggerhurt,&Float:damage)
{
	if(FF2_HasAbility(userid, this_plugin_name, "blitzkrieg_config"))
	{
		new Boss=GetClientOfUserId(FF2_GetBossUserId(userid));
		FF2_SetBossCharge(Boss, 0, 25.0);
		Teleport_Me(Boss);
		TF2_StunPlayer(Boss, 4.0, 0.0, TF_STUNFLAGS_LOSERSTATE, Boss);
	}
	return Plugin_Continue;
}

public Action:ItzBlitzkriegTime(Handle:hTimer,any:index)
{
	if(combatstyle!=0)
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