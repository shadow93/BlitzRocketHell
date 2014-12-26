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
//Handles
new Handle: crockethell;
//Other Stuff
new customweapons;
new combatstyle;
new weapondifficulty;
new voicelines;
new danmakuboss;
new blitzkriegrage;
new miniblitzkriegrage;
new startmode;
// So Blitzkrieg works properly independent of assigned team
new BossTeam;

// To prevent a rare weapon inheritance bug
new bool:barrage = false;

// Version Number
#define MAJOR_REVISION "1"
#define MINOR_REVISION "80"
#define DEV_REVISION "Beta"
#define BUILD_REVISION "(Stable)"
#define PLUGIN_VERSION MAJOR_REVISION..."."...MINOR_REVISION..." "...DEV_REVISION..." "...BUILD_REVISION

#if defined _updater_included
#define UPDATE_URL "http://www.shadow93.info/tf2/tf2plugins/tf2danmaku/update.txt"
#define DEBUG   // This will enable verbose logging. Useful for developers testing their updates. 
#endif

public OnMapStart()
{
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
	HookEvent("arena_round_start", OnRoundStart, EventHookMode_PostNoCopy);
	HookEvent("arena_win_panel", OnRoundEnd, EventHookMode_PostNoCopy);
	HookEvent("player_death", OnPlayerDeath);
	HookEvent("player_death", PreDeath, EventHookMode_Pre);
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
	if(IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client)!=BossTeam)
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
		if((owner=GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity"))<=MaxClients && owner>0 && GetClientTeam(owner)==BossTeam)
		{
			TF2_RemoveWearable(owner, entity);
		}
	}
	while((entity=FindEntityByClassname(entity, "tf_wearable_demoshield"))!=-1)
	{
		if((owner=GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity"))<=MaxClients && owner>0 && GetClientTeam(owner)==BossTeam)
		{
			TF2_RemoveWearable(owner, entity);
		}
	}
	while((entity=FindEntityByClassname(entity, "tf_powerup_bottle"))!=-1)
	{
		if((owner=GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity"))<=MaxClients && owner>0 && GetClientTeam(owner)==BossTeam)
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
				SpawnWeapon(client, "tf_weapon_knife", 1003, 109, 5, "2 ; 3 ; 138 ; 0.5 ; 39 ; 0.3 ; 267 ; 1 ; 391 ; 1.9 ; 401 ; 1.9 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6");
			else if(TF2_GetPlayerClass(client)==TFClass_Soldier)
				SpawnWeapon(client, "tf_weapon_knife", 416, 109, 5, "2 ; 3 ; 138 ; 0.5 ; 39 ; 0.3 ; 267 ; 1 ; 391 ; 1.9 ; 401 ; 1.9 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6");
			if(barrage==true)
				SetAmmo(client, TFWeaponSlot_Primary,blitzkriegrage);
			else
				SetAmmo(client, TFWeaponSlot_Primary,miniblitzkriegrage);
		}
	}	
}		

// This is the weapon configs for Blitzkrieg's starter weapons & switch upon rage or after Blitzkrieg ability wears off
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

// Blitzkrieg's much more powerful weapons whenever he loses a life. This is his weapon config
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

// Custom Weapon Stuff
CustomWeapons(client)
{
	new weapon;
	new index=-1;
	if(IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client)!=BossTeam)
	{
		// Soldier Rocket Launchers
		if(TF2_GetPlayerClass(client)==TFClass_Soldier)
		{
			weapon=GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
			index=GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
			switch(index)
			{
				case 127: // Direct Hit
				{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
					weapon=SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 5, 10, "103 ; 2 ; 114 ; 1 ; 100 ; 0.30 ; 2 ; 1.50 ; 15 ; 1 ; 179 ; 1 ; 488 ; 3 ; 621 ; 0.35 ; 643 ; 0.75 ; 644 ; 10");
					// 2: +50% Damage Bonus
					// 15: No Random Critical Hits
					// 100: -70% explosion radius
					// 103: +100% projectile speed
					// 114: minicrits airborne targets
					// 179: minicrits become crits
					// 488: Rocket Specialist
					// 621: Increased attack speed while blast jumping
					// 641: Clip Size increased on-kill
					// 275: Wearer NEVER takes fall damage
					PrintHintText(client, "While being healed by a medic, your damage is increased by 50%");

				}
				case 441: //Cow Mangler
				{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
					weapon=SpawnWeapon(client, "tf_weapon_particle_cannon", 441, 5, 10, "2 ; 1.5 ; 58 ; 2 ; 281 ; 1 ; 282 ; 1 ; 288 ; 1 ; 366 ; 5");
					// 2: +50% damage bonus
					// 58: +100% Self Damage Push Force
					// 281: No ammo needed
					// 282: Charged Shot on alt-fire
					// 288: Cannot be crit boosted
					// 366: On Hit: If enemy's belt is at or above eye level, stun them for 5 seconds
					PrintHintText(client, "A successful hit mid-air stuns Blitzkrieg for 5 seconds");
				}
				case 228, 1085: // Black Box, Festive Black Box
				{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
					weapon=SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 5, 10, "4 ; 1.5 ; 6 ; 0.25 ; 15 ; 1 ; 16 ; 5 ; 58 ; 3 ; 76 ; 3.50 ; 100 ; 0.5 ; 135 ; 0.60 ; 233 ; 1.50 ; 234 ; 1.30");
					// 4: +50% Clip Size
					// 6: +75% faster firing speed
					// 15: No Random Critical Hits
					// 16: +5 health
					// 58: +200% Self Damage Push Force
					// 76: +250% Max primary ammo on wearer
					// 100: -50% Blast Radius
					// 135: -40% blast damage from rocket jumps
					// 233: While a medic is healing you, this weapon's damage is increased by 50%
					// 234: While not being healed by a medic, your weapon switch time is 30% longer
					PrintHintText(client, "While being healed by a medic, your damage is increased by 50%");

				}
				case 730: //Beggar's Bazooka
				{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
					weapon=SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 5, 10, "135 ; 0.25 ; 58 ; 1.5 ; 2 ; 1.1 ; 4 ; 7.5 ; 6 ; 0 ; 76 ; 10 ; 97 ; 0.40 ; 411 ; 15 ; 413 ; 1 ; 417 ; 1");
					// 2: 10% Damage Bonus
					// 4: +650 Clip Size
					// 6: 85% Faster Firing Speed
					// 58: +50% self damage push force
					// 76: +1000% Max primary ammo on wearer
					// 135: -75% blast damage from rocket jumps
					// 597: 50% Faster reload speed
					// 411: 30 degrees random projectile deviation
					// 413: Hold Fire to load 30 rockets
					// 417: Overloading will misfire
					PrintHintText(client, "Unleash your OWN Danmaku! Careful as you can overload");

				}
				case 1104: // Air Strike
				{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
					weapon=SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 5, 10, "1 ; 0.90 ; 15 ; 1 ; 179 ; 1 ; 232 ; 10 ; 488 ; 3 ; 621 ; 0.35 ; 642 ; 1 ; 643 ; 0.75 ; 644 ; 10");
					// 2: +25% Damage Bonus
					// 15: No Random Critical Hits
					// 488: Rocket Specialist
					// 621: Increased attack speed while blast jumping
					// 641: Clip Size increased on-kill
					// 232: When the medic healing you is killed, you gain mini-crit boost for 10 seconds
					// 275: Wearer NEVER takes fall damage
					PrintHintText(client, "While being healed by a medic, your damage is increased by 50%");

				}
				default: // For other rocket launcher reskins
				{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
					weapon=SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 5, 10, "138 ; 0.70 ; 4 ; 2.0 ; 6 ; 0.25 ; 15 ; 1 ; 58 ; 4 ; 65 ; 1.30 ; 76 ; 6 ; 135 ; 0.30 ; 232 ; 10 ; 275 ; 1");
					// 1: -30% Damage Penalty
					// 4: +100% Clip Size
					// 6: +75% faster firing speed
					// 15: No Random Critical Hits
					// 58: +300% Self Damage Push Force
					// 65: +30% explosive damage vulnerability on wearer
					// 76: +500% Max primary ammo on wearer
					// 135: -70% blast damage from rocket jumps
					// 232: When the medic healing you is killed, you gain mini-crit boost for 10 seconds
					// 275: Wearer never takes fall damage
					PrintHintText(client, "When your healer is killed, you gain mini-crits for 10 seconds.");
				}
			}
		}
		// Panic Attack, Flare Guns & Buff Banners
		if(TF2_GetPlayerClass(client)==TFClass_Soldier||TF2_GetPlayerClass(client)==TFClass_Pyro||TF2_GetPlayerClass(client)==TFClass_Heavy||TF2_GetPlayerClass(client)==TFClass_Engineer)
		{
			if(TF2_GetPlayerClass(client)==TFClass_Soldier||TF2_GetPlayerClass(client)==TFClass_Pyro||TF2_GetPlayerClass(client)==TFClass_Heavy)
			{
				weapon=GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
			}
			if(TF2_GetPlayerClass(client)==TFClass_Engineer)
			{
				weapon=GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
			}
			index=GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
			switch(index)
			{
				case 39, 351, 740, 1081: // Flaregun, Detonator, Scorch Shot & Festive Flare Gun
				{
					weapon=GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
					weapon=SpawnWeapon(client, "tf_weapon_flaregun", 351, 5, 10, "1 ; 0.75 ; 25 ; 0.75 ; 65 ; 1.75 ; 207 ; 1.10 ; 144 ; 1 ; 58 ; 3.5 ; 20 ; 1 ; 22 ; 1 ; 551 ; 1 ; 15 ; 1");
					PrintHintText(client, "Detonator deals crits while players are on fire. Cannot randomly crit. -25% damage penalty.");
				}
				case 42, 863, 1002: // Sandvich, Robo-Sandvich & Festive Sandvich
				{
					weapon=GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
					weapon=SpawnWeapon(client, "tf_weapon_lunchbox", 42, 5, 10, "144 ; 4 ; 278 ; 0.5");
					PrintHintText(client, "+50% Faster Sandvich Regen Rate");
				}
				case 129, 1001: // Buff Banner
				{
					weapon=GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
					weapon=SpawnWeapon(client, "tf_weapon_buff_item", 129, 5, 10, "26 ; 50 ; 116 ; 1 ; 292 ; 51 ; 319 ; 2.50");
					PrintHintText(client, "+150% longer buff duration, +50 Max HP");
				}
				case 226: // Battalion's Backup
				{
					weapon=GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
					weapon=SpawnWeapon(client, "tf_weapon_buff_item", 226, 5, 10, "26 ; 50 ; 116 ; 2 ; 292 ; 51 ; 319 ; 2.50");
					PrintHintText(client, "+150% longer buff duration, +50 Max HP");
				}
				case 354: // Concheror
				{
					weapon=GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
					weapon=SpawnWeapon(client, "tf_weapon_buff_item", 354, 5, 10, "26 ; 50 ; 57 ; 3 ; 116 ; 3 ; 292 ; 51 ; 319 ; 2.50");
					PrintHintText(client, "+150% longer buff duration, +50 Max HP");
				}
				case 1153: // Panic Attack
				{
					if(TF2_GetPlayerClass(client)==TFClass_Soldier||TF2_GetPlayerClass(client)==TFClass_Pyro||TF2_GetPlayerClass(client)==TFClass_Heavy)
					{
						weapon=GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
						TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
						if(TF2_GetPlayerClass(client)==TFClass_Soldier)
							weapon=SpawnWeapon(client, "tf_weapon_shotgun_soldier", 1153, 5, 10, "97 ; 0.77 ; 107 ; 1.70 ; 128 ; 1 ; 232 ; 15 ; 394 ; 0.85 ; 414 ; 1 ; 651 ; 0.5 ; 708 ; 1 ; 709 ; 1 ; 710 ; 1 ; 711 ; 1");
						if(TF2_GetPlayerClass(client)==TFClass_Pyro)
							weapon=SpawnWeapon(client, "tf_weapon_shotgun_pyro", 1153, 5, 10, "97 ; 0.77 ; 107 ; 1.70 ; 128 ; 1 ; 232 ; 15 ; 394 ; 0.85 ; 414 ; 1 ; 651 ; 0.5 ; 708 ; 1 ; 709 ; 1 ; 710 ; 1 ; 711 ; 1");
						if(TF2_GetPlayerClass(client)==TFClass_Heavy)
							weapon=SpawnWeapon(client, "tf_weapon_shotgun_hwg", 1153, 5, 10, "97 ; 0.77 ; 107 ; 1.70 ; 128 ; 1 ; 232 ; 15 ; 394 ; 0.85 ; 414 ; 1 ; 651 ; 0.5 ; 708 ; 1 ; 709 ; 1 ; 710 ; 1 ; 711 ; 1");
					}
					if(TF2_GetPlayerClass(client)==TFClass_Engineer)
					{
						weapon=GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
						TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
						weapon=SpawnWeapon(client, "tf_weapon_shotgun_primary", 1153, 5, 10, "97 ; 0.77 ; 107 ; 1.70 ; 128 ; 1 ; 232 ; 15 ; 394 ; 0.85 ; 414 ; 1 ; 651 ; 0.5 ; 708 ; 1 ; 709 ; 1 ; 710 ; 1 ; 711 ; 1");
					}
					PrintHintText(client, "+75% faster move speed during panic. When a medic healing you is killed, you gain minicrits for 15 seconds.");
				}
			}
		}
	}
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


// Events

public Action:OnRoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	// Here, we have a config for blitzkrieg's rounds //
	if (FF2_IsFF2Enabled())
	{
		danmakuboss = GetClientOfUserId(FF2_GetBossUserId(0));
		if (danmakuboss>0)
		{
			if (FF2_HasAbility(0, this_plugin_name, "blitzkrieg_config"))
			{	
				BossTeam = FF2_GetBossTeam();
				barrage=false;
				weapondifficulty=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 1, 2);
				combatstyle=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 2);
				customweapons=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 3); // use custom weapons
				voicelines=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 4); // Voice Lines
				miniblitzkriegrage=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 5); // RAGE/Weaponswitch Ammo
				blitzkriegrage=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 6); // Blitzkrieg Rampage Ammo
				startmode=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 7); // Start with launcher or no (with melee mode)
				switch(weapondifficulty)
				{
					case 0:
					{
						switch (GetRandomInt(0,8))
						{
						case 0:
							weapondifficulty=1, CPrintToChatAll("Blitzkrieg's Level: Easy");
						case 1:
							weapondifficulty=2, CPrintToChatAll("Blitzkrieg's Level: Normal");
						case 2:
							weapondifficulty=3, CPrintToChatAll("Blitzkrieg's Level: Intermediate");
						case 3:
							weapondifficulty=4, CPrintToChatAll("Blitzkrieg's Level: Difficult");
						case 4:
							weapondifficulty=5, CPrintToChatAll("Blitzkrieg's Level: Lunatic");
						case 5:
							weapondifficulty=6, CPrintToChatAll("Blitzkrieg's Level: Extreme");
						case 6:
							weapondifficulty=7, CPrintToChatAll("Blitzkrieg's Level: Godlike");
						case 7:
							weapondifficulty=8, CPrintToChatAll("Blitzkrieg's Level: Rocket Hell");
						case 8:
							weapondifficulty=9, CPrintToChatAll("Blitzkrieg's Level: Total Blitzkrieg");
						}
					}
					case 1:
						CPrintToChatAll("Blitzkrieg's Level: Easy");
					case 2:
						CPrintToChatAll("Blitzkrieg's Level: Normal");
					case 3:
						CPrintToChatAll("Blitzkrieg's Level: Intermediate");
					case 4:
						CPrintToChatAll("Blitzkrieg's Level: Difficult");
					case 5:
						CPrintToChatAll("Blitzkrieg's Level: Lunatic");
					case 6:
						CPrintToChatAll("Blitzrieg's Level: Extreme");
					case 7:
						CPrintToChatAll("Blitzkrieg's Level: Godlike");
					case 8:
						CPrintToChatAll("Blitzkrieg's Level: Rocket Hell");
					case 9:
						CPrintToChatAll("Blitzkrieg's Level: Total Blitzkrieg");
				}
				switch(combatstyle)
				{
					case 1:
					{
						PrintHintText(danmakuboss, "You must rely on your rockets to finish enemies off!");
						PlotTwist(danmakuboss);
					}
					case 0:
					{
						PrintHintText(danmakuboss, "Use your Ubersaw to finish off nearby enemies!");
						PlotTwist(danmakuboss);
					}
				}
				if(customweapons!=0)
				{
					for(new i = 1; i <= MaxClients; i++ )
					{
						CustomWeapons(i);
						if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i)!=BossTeam)
						{
							// Engineer Stuff
							if(TF2_GetPlayerClass(i)==TFClass_Engineer)
							{
								TF2_RemoveWeaponSlot(i, TFWeaponSlot_Grenade);
								SpawnWeapon(i, "tf_weapon_pda_engineer_build", 25, 5, 10, "276 ; 1");
								// 276: Bidirectional Teleporters
								PrintHintText(i, "Your teleporters are bi-directional");
							}
							// Medic Stuff
							if(TF2_GetPlayerClass(i)==TFClass_Medic)
							{
								TF2_RemoveWeaponSlot(i, TFWeaponSlot_Secondary);
								SpawnWeapon(i, "tf_weapon_medigun", 29, 5, 10, "499 ; 50.0 ; 10 ; 1.25 ; 178 ; 0.75 ; 144 ; 2.0 ; 11 ; 1.5 ; 482 ; 3 ; 493 ; 3");
								//499: Projectile Shield
								//10: +25% faster charge rate
								//178: +25% faster weapon switch
								//144: Quick-fix speed/jump effects
								//11: +50% overheal bonus
								//482: Overheal Expert
								//493: Healing Mastery
								PrintHintText(i, "Use +attack3 (default: middle mouse button) to deploy a projectile shield");
							}
						}
					}
				}			
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
			if(StrEqual(weapon, "tf_projectile_rocket", false))
			{
				SetEventString(event, "weapon", "spellbook_meteor");
				SetEventString(event, "weapon_logclassname", "spellbook_meteor");
			}
			else if(StrEqual(weapon, "airstrike", false))
			{
				SetEventString(event, "weapon", "spellbook_meteor");
				SetEventString(event, "weapon_logclassname", "spellbook_meteor");
			}
			else if(StrEqual(weapon, "liberty_launcher", false))
			{
				SetEventString(event, "weapon", "spellbook_meteor");
				SetEventString(event, "weapon_logclassname", "spellbook_meteor");
			}
			else if(StrEqual(weapon, "quake_rl", false))
			{
				SetEventString(event, "weapon", "spellbook_meteor");
				SetEventString(event, "weapon_logclassname", "spellbook_meteor");
			}
			else if(StrEqual(weapon, "blackbox", false))
			{
				SetEventString(event, "weapon", "spellbook_meteor");
				SetEventString(event, "weapon_logclassname", "spellbook_meteor");
			}
			else if(StrEqual(weapon, "dumpster_device", false))
			{
				SetEventString(event, "weapon", "spellbook_meteor");
				SetEventString(event, "weapon_logclassname", "spellbook_meteor");
			}
			else if(StrEqual(weapon, "rocketlauncher_directhit", false))
			{
				SetEventString(event, "weapon", "spellbook_meteor");
				SetEventString(event, "weapon_logclassname", "spellbook_meteor");
			}
			else if(StrEqual(weapon, "ubersaw", false))
			{
				SetEventString(event, "weapon", "taunt_medic");
				SetEventString(event, "weapon_logclassname", "taunt_medic");
			}
			else if(StrEqual(weapon, "flamethrower", false))
			{
				SetEventString(event, "weapon", "spellbook_meteor");
				SetEventString(event, "weapon_logclassname", "spellbook_meteor");
			}
		}
	}
}	

public Action:OnPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new attacker=GetClientOfUserId(GetEventInt(event, "attacker"));
	new client=GetClientOfUserId(GetEventInt(event, "userid"));
	new bossAttacker=FF2_GetBossIndex(attacker);

	if(!attacker || !client || attacker==client)
	{
		return Plugin_Continue;
	}

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
	if (IsValidClient(danmakuboss))
	{
		SetEntityGravity(danmakuboss, 1.0);
	}
	if (crockethell!=INVALID_HANDLE)
	{
		KillTimer(crockethell);
		crockethell = INVALID_HANDLE;
	}
	barrage=false;
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
	PrintToServer("ItzBlitzkriegTime(Handle:hTimer,any:index)");
	crockethell = INVALID_HANDLE;
}

public Action:RemoveUber(Handle:hTimer,any:index)
{
	new Boss=GetClientOfUserId(FF2_GetBossUserId(index));
	PrintToServer("Rage_Timer_UnuseCharge(Handle:hTimer,any:index)");
	SetEntProp(Boss, Prop_Data, "m_takedamage", 2);
	return Plugin_Continue;
}