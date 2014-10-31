// The Blitzkrieg's abilities pack:
// rage_blitzkrieg - Become ubercharged, crit boosted, change rocket launchers
// rage_miniblitzkrieg - Identical to rage_blitzkrieg, but without ubercharge.

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
#include <updater>

#define BLITZKRIEG_SND "mvm/mvm_tank_end.wav"
#define MINIBLITZKRIEG_SND "mvm/mvm_tank_start.wav"
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
new Handle: crockethell;
new Handle: screwgravity;
new Handle: specialweapons;
new Handle: nomelee;
new Handle: withmelee;
new customweapons;
new combatstyle;
new weapondifficulty;
new voicelines;
new danmakuboss;
new BossTeam=_:TFTeam_Blue;
//new OtherTeam=_:TFTeam_Red;

#define PLUGIN_VERSION "1.76b"
#define UPDATE_URL "http://www.shadow93.info/tf2/tf2plugins/tf2danmaku/update.txt"

public OnMapStart()
{
	PrecacheSound(BLITZKRIEG_SND,true);
	PrecacheSound(MINIBLITZKRIEG_SND,true);
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
	HookEvent("teamplay_round_start", event_round_start);
	HookEvent("teamplay_round_win", event_round_end);
	HookEvent("player_death", event_player_death);
	PrintToServer("************************************************************************");
	PrintToServer("--------------------FREAK FORTRESS 2: THE BLITZKRIEG--------------------");
	PrintToServer("--------------------BETA 1.76 - BY SHADoW NiNE TR3S---------------------");
	PrintToServer("------------------------------------------------------------------------");
	PrintToServer("-if you encounter bugs or see errors in console relating to this plugin-");
	PrintToServer("-please post them in the Blitzkrieg's main thread which can be found at-");
	PrintToServer("----------https://forums.alliedmods.net/showthread.php?t=248320---------");
	PrintToServer("************************************************************************");
	if (LibraryExists("updater"))
    {
		Updater_AddPlugin(UPDATE_URL);
		PrintToServer("Checking for updates for TF2 Danmaku");
	}
}

public OnLibraryAdded(const String:name[])
{
    if (StrEqual(name, "updater"))
    {
        Updater_AddPlugin(UPDATE_URL);
    }
}

// Blitzkrieg's Rage & Death Effect //

public Action:FF2_OnAbility2(index,const String:plugin_name[],const String:ability_name[],action)
{
	if (!strcmp(ability_name,"rage_blitzkrieg")) 	// UBERCHARGE, KRITZKRIEG & CROCKET HELL
	{	
		if (FF2_GetRoundState()==1)
		{
			new Boss=GetClientOfUserId(FF2_GetBossUserId(index));
			TF2_AddCondition(Boss,TFCond_Ubercharged,FF2_GetAbilityArgumentFloat(index,this_plugin_name,ability_name,1,5.0)); // Ubercharge
			TF2_AddCondition(Boss,TFCond_Kritzkrieged,FF2_GetAbilityArgumentFloat(index,this_plugin_name,ability_name,2,5.0)); // Kritzkrieg
			new rockets=FF2_GetAbilityArgument(index,this_plugin_name,ability_name, 3, 360);	//Ammo
			SetEntProp(Boss, Prop_Data, "m_takedamage", 0);
			CreateTimer(FF2_GetAbilityArgumentFloat(index,this_plugin_name,ability_name,1,5.0),Rage_Timer_UnuseCharge,index);
			PrintToServer("Ability Activated: Blitzkrieg *rage_blitzkrieg*");
			SetEntityGravity(Boss, 0.05);
			TF2_RemoveWeaponSlot(Boss, TFWeaponSlot_Primary);
			BlitzkriegBarrage(Boss);
			SetAmmo(Boss, TFWeaponSlot_Primary,rockets);
			crockethell = CreateTimer(FF2_GetAbilityArgumentFloat(index,this_plugin_name,ability_name,4,30.0),ItzBlitzkriegTime,index);
			voicelines=FF2_GetAbilityArgument(index,this_plugin_name,ability_name, 5); // Voice Lines
			if (voicelines == 1)
			{
				CreateTimer(0.1, ClassResponses);
			}
			else if (voicelines == 0)
			{
				EmitSoundToAll(BLITZKRIEG_SND);
				EmitSoundToAll(BLITZKRIEG_SND);
			}	
		}
		else if (FF2_GetRoundState()==2)
		{
			return Plugin_Stop;
		}
	}
	else if (!strcmp(ability_name,"rage_miniblitzkrieg")) 	// KRITZKRIEG & CROCKET HELL
	{		
		if (FF2_GetRoundState()==1)
		{	
			new Boss=GetClientOfUserId(FF2_GetBossUserId(index));
			TF2_AddCondition(Boss,TFCond_Kritzkrieged,FF2_GetAbilityArgumentFloat(index,this_plugin_name,ability_name,1,5.0)); // Kritzkrieg
			PrintToServer("Ability Activated: Mini-Blitzkrieg *rage_miniblitzkrieg*");
			SetEntityGravity(Boss, 0.05);
			new crockets=FF2_GetAbilityArgument(index,this_plugin_name,ability_name, 2, 180);	//Ammo
			TF2_RemoveWeaponSlot(Boss, TFWeaponSlot_Primary);
			RandomDanmaku(Boss);
			if(combatstyle==0)
			{
				SetAmmo(Boss, TFWeaponSlot_Primary,crockets);
			}
			else if(combatstyle!=0)
			{
				SetAmmo(Boss, TFWeaponSlot_Primary,999999);
			}
			screwgravity = CreateTimer(FF2_GetAbilityArgumentFloat(index,this_plugin_name,ability_name,3,15.0),ScrewThisGravity,index);	
			voicelines=FF2_GetAbilityArgument(index,this_plugin_name,ability_name, 4); // Voice Lines
			if (voicelines == 1)
			{
				CreateTimer(0.1, ClassResponses);
			}
			else if (voicelines == 0)
			{
				EmitSoundToAll(MINIBLITZKRIEG_SND);
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


// This is the weapon configs for Blitzkrieg's starter weapons & switch upon rage or after Blitzkrieg ability wears off
RandomDanmaku(client)
{
	if (weapondifficulty==0) // Easy
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 100, 5, "275 ; 1 ;  1 ; 0.05 ; 413 ; 1 ; 4 ; 3.5 ; 6 ; 0.18 ; 97 ; 0.01 ; 100 ; 0.10 ; 104 ; 0.40 ; 137 ; 5 ; 37 ; 0 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 100, 5, "275 ; 1 ;  1 ; 0.06 ; 413 ; 1 ; 4 ; 4.5 ; 6 ; 0.16 ; 97 ; 0.01 ; 100 ; 0.15 ; 104 ; 0.35 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 100, 5, "275 ; 1 ;  1 ; 0.04 ; 413 ; 1 ; 4 ; 5 ; 6 ; 0.14 ; 97 ; 0.01 ; 100 ; 0.30 ; 104 ; 0.35 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 100, 5, "275 ; 1 ;  1 ; 0.06 ; 413 ; 1 ; 4 ; 6 ; 6 ; 0.12 ; 97 ; 0.01 ; 100 ; 0.45 ; 104 ; 0.30 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 100, 5, "275 ; 1 ;  1 ; 0.07 ; 413 ; 1 ; 4 ; 7.5 ; 6 ; 0.10 ; 97 ; 0.01 ; 100 ; 0.60 ; 104 ; 0.30 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 100, 5, "275 ; 1 ;  1 ; 0.04 ; 413 ; 1 ; 4 ; 8 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.25 ; 137 ; 5 ; 104 ; 0.50 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 100, 5, "275 ; 1 ;  1 ; 0.08 ; 413 ; 1 ; 4 ; 6.5 ; 6 ; 0.05 ; 97 ; 0.01 ; 100 ; 0.25 ; 137 ; 5 ; 104 ; 0.45 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 100, 5, "275 ; 1 ;  1 ; 0.07 ; 413 ; 1 ; 4 ; 8.5 ; 6 ; 0.15 ; 97 ; 0.01 ; 104 ; 0.29 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 100, 5, "275 ; 1 ;  1 ; 0.06 ; 413 ; 1 ; 4 ; 11 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.40 ; 137 ; 5 ; 104 ; 0.10 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 100, 5, "275 ; 1 ;  1 ; 0.04 ; 413 ; 1 ; 4 ; 6.5 ; 6 ; 0.20 ; 97 ; 0.01 ; 100 ; 0.35 ; 137 ; 5 ; 104 ; 0.05 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
		}
	}
	else if (weapondifficulty==1) // Normal
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 101, 5, "275 ; 1 ;  1 ; 0.10 ; 413 ; 1 ; 4 ; 7 ; 6 ; 0.18 ; 97 ; 0.01 ; 100 ; 0.10 ; 104 ; 0.42 ; 137 ; 5 ; 37 ; 0 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 101, 5, "275 ; 1 ;  1 ; 0.12 ; 413 ; 1 ; 4 ; 9 ; 6 ; 0.16 ; 97 ; 0.01 ; 100 ; 0.15 ; 104 ; 0.39 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 101, 5, "275 ; 1 ;  1 ; 0.08 ; 413 ; 1 ; 4 ; 10 ; 6 ; 0.14 ; 97 ; 0.01 ; 100 ; 0.30 ; 104 ; 0.36 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 101, 5, "275 ; 1 ;  1 ; 0.11 ; 413 ; 1 ; 4 ; 12 ; 6 ; 0.12 ; 97 ; 0.01 ; 100 ; 0.45 ; 104 ; 0.33 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 101, 5, "275 ; 1 ;  1 ; 0.14 ; 413 ; 1 ; 4 ; 15 ; 6 ; 0.10 ; 97 ; 0.01 ; 100 ; 0.60 ; 104 ; 0.30 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 101, 5, "275 ; 1 ;  1 ; 0.09 ; 413 ; 1 ; 4 ; 16 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.25 ; 137 ; 5 ; 104 ; 0.50 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 101, 5, "275 ; 1 ;  1 ; 0.17 ; 413 ; 1 ; 4 ; 13 ; 6 ; 0.05 ; 97 ; 0.01 ; 100 ; 0.25 ; 137 ; 5 ; 104 ; 0.45 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 101, 5, "275 ; 1 ;  1 ; 0.15 ; 413 ; 1 ; 4 ; 17 ; 6 ; 0.15 ; 97 ; 0.01 ; 104 ; 0.15 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 101, 5, "275 ; 1 ;  1 ; 0.13 ; 413 ; 1 ; 4 ; 22 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.40 ; 137 ; 5 ; 104 ; 0.10 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 101, 5, "275 ; 1 ;  1 ; 0.09 ; 413 ; 1 ; 4 ; 13 ; 6 ; 0.20 ; 97 ; 0.01 ; 100 ; 0.50 ; 137 ; 5 ; 104 ; 0.05 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
		}
	}
	else if (weapondifficulty==2) // Intermediate
	{
		switch (GetRandomInt(0,9))
		{
			case 0:	
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 102, 5, "275 ; 1 ; 1 ; 0.12 ; 413 ; 1 ; 4 ; 10 ; 6 ; 0.18 ; 97 ; 0.01 ; 100 ; 0.10 ; 104 ; 0.44 ; 137 ; 5 ; 37 ; 0 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 102, 5, "275 ; 1 ;  1 ; 0.14 ; 413 ; 1 ; 4 ; 14 ; 6 ; 0.16 ; 97 ; 0.01 ; 100 ; 0.15 ; 104 ; 0.41 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 102, 5, "275 ; 1 ;  1 ; 0.10 ; 413 ; 1 ; 4 ; 15 ; 6 ; 0.14 ; 97 ; 0.01 ; 100 ; 0.30 ; 104 ; 0.38 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 102, 5, "275 ; 1 ;  1 ; 0.13 ; 413 ; 1 ; 4 ; 17 ; 6 ; 0.12 ; 97 ; 0.01 ; 100 ; 0.45 ; 104 ; 0.35 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 102, 5, "275 ; 1 ;  1 ; 0.16 ; 413 ; 1 ; 4 ; 20 ; 6 ; 0.10 ; 97 ; 0.01 ; 100 ; 0.60 ; 104 ; 0.32 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 102, 5, "275 ; 1 ;  1 ; 0.11 ; 413 ; 1 ; 4 ; 22 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.25 ; 137 ; 5 ; 104 ; 0.52 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 102, 5, "275 ; 1 ;  1 ; 0.19 ; 413 ; 1 ; 4 ; 20 ; 6 ; 0.05 ; 97 ; 0.01 ; 100 ; 0.25 ; 137 ; 5 ; 104 ; 0.47 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 102, 5, "275 ; 1 ;  1 ; 0.17 ; 413 ; 1 ; 4 ; 20 ; 6 ; 0.15 ; 97 ; 0.01 ; 104 ; 0.17 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 102, 5, "275 ; 1 ;  1 ; 0.15 ; 413 ; 1 ; 4 ; 25 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.40 ; 137 ; 5 ; 104 ; 0.12 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 102, 5, "275 ; 1 ;  1 ; 0.11 ; 413 ; 1 ; 4 ; 15 ; 6 ; 0.20 ; 97 ; 0.01 ; 100 ; 0.50 ; 137 ; 5 ; 104 ; 0.07 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
		}
	}
	else if (weapondifficulty==3) // Difficult
	{
		switch (GetRandomInt(0,9))
		{	
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 103, 5, "275 ; 1 ; 1 ; 0.15 ; 413 ; 1 ; 4 ; 15 ; 6 ; 0.18 ; 97 ; 0.01 ; 100 ; 0.10 ; 104 ; 0.47 ; 137 ; 5 ; 37 ; 0 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 103, 5, "275 ; 1 ; 1 ; 0.17 ; 413 ; 1 ; 4 ; 17 ; 6 ; 0.16 ; 97 ; 0.01 ; 100 ; 0.15 ; 104 ; 0.44 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 103, 5, "275 ; 1 ;  1 ; 0.13 ; 413 ; 1 ; 4 ; 13 ; 6 ; 0.14 ; 97 ; 0.01 ; 100 ; 0.30 ; 104 ; 0.41 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 103, 5, "275 ; 1 ; 1 ; 0.16 ; 413 ; 1 ; 4 ; 17 ; 6 ; 0.12 ; 97 ; 0.01 ; 100 ; 0.45 ; 104 ; 0.38 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 103, 5, "275 ; 1 ; 1 ; 0.19 ; 413 ; 1 ; 4 ; 17 ; 6 ; 0.10 ; 97 ; 0.01 ; 100 ; 0.60 ; 104 ; 0.35 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 103, 5, "275 ; 1 ; 1 ; 0.14 ; 413 ; 1 ; 4 ; 18 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.25 ; 137 ; 5 ; 104 ; 0.55 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 103, 5, "275 ; 1 ; 1 ; 0.22 ; 413 ; 1 ; 4 ; 15 ; 6 ; 0.05 ; 97 ; 0.01 ; 100 ; 0.25 ; 137 ; 5 ; 104 ; 0.50 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 103, 5, "275 ; 1 ; 1 ; 0.20 ; 413 ; 1 ; 4 ; 19 ; 6 ; 0.15 ; 97 ; 0.01 ; 104 ; 0.17 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 103, 5, "275 ; 1 ; 1 ; 0.18 ; 413 ; 1 ; 4 ; 24 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.40 ; 137 ; 5 ; 104 ; 0.15 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 103, 5, "275 ; 1 ; 1 ; 0.15 ; 413 ; 1 ; 4 ; 15 ; 6 ; 0.20 ; 97 ; 0.01 ; 100 ; 0.50 ; 137 ; 5 ; 104 ; 0.10 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
		}
	}
	else if (weapondifficulty==4) // Lunatic
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 104, 5, "275 ; 1  ; 1 ; 0.20 ; 413 ; 1 ; 4 ; 17 ; 6 ; 0.18 ; 97 ; 0.01 ; 100 ; 0.10 ; 104 ; 0.52 ; 137 ; 5 ; 37 ; 0 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 104, 5, "275 ; 1  ; 1 ; 0.22 ; 413 ; 1 ; 4 ; 19 ; 6 ; 0.16 ; 97 ; 0.01 ; 100 ; 0.15 ; 104 ; 0.49 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 104, 5, "275 ; 1  ; 1 ; 0.18 ; 413 ; 1 ; 4 ; 20 ; 6 ; 0.14 ; 97 ; 0.01 ; 100 ; 0.30 ; 104 ; 0.46 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 104, 5, "275 ; 1  ; 1 ; 0.21 ; 413 ; 1 ; 4 ; 22 ; 6 ; 0.12 ; 97 ; 0.01 ; 100 ; 0.45 ; 104 ; 0.43 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 104, 5, "275 ; 1  ; 1 ; 0.24 ; 413 ; 1 ; 4 ; 25 ; 6 ; 0.10 ; 97 ; 0.01 ; 100 ; 0.60 ; 104 ; 0.40 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 104, 5, "275 ; 1  ; 1 ; 0.19 ; 413 ; 1 ; 4 ; 26 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.25 ; 137 ; 5 ; 104 ; 0.60 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 104, 5, "275 ; 1  ; 1 ; 0.27 ; 413 ; 1 ; 4 ; 23 ; 6 ; 0.05 ; 97 ; 0.01 ; 100 ; 0.25 ; 137 ; 5 ; 104 ; 0.55 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 104, 5, "275 ; 1  ; 1 ; 0.25 ; 413 ; 1 ; 4 ; 27 ; 6 ; 0.15 ; 97 ; 0.01 ; 104 ; 0.22 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 104, 5, "275 ; 1  ; 1 ; 0.23 ; 413 ; 1 ; 4 ; 32 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.40 ; 137 ; 5 ; 104 ; 0.20 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 104, 5, "275 ; 1  ; 1 ; 0.20 ; 413 ; 1 ; 4 ; 23 ; 6 ; 0.20 ; 97 ; 0.01 ; 100 ; 0.50 ; 137 ; 5 ; 104 ; 0.20 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
		}
	}
	else if (weapondifficulty==5) // YOU MUST BE DREAMING TO EVEN TRY THIS!
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 105, 5, "275 ; 1  ; 1 ; 0.40 ; 413 ; 1 ; 4 ; 29 ; 6 ; 0.18 ; 97 ; 0.01 ; 100 ; 0.10 ; 104 ; 0.74 ; 137 ; 5 ; 37 ; 0 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 105, 5, "275 ; 1  ; 1 ; 0.44 ; 413 ; 1 ; 4 ; 31 ; 6 ; 0.16 ; 97 ; 0.01 ; 100 ; 0.15 ; 104 ; 0.78 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 105, 5, "275 ; 1  ; 1 ; 0.36 ; 413 ; 1 ; 4 ; 22 ; 6 ; 0.14 ; 97 ; 0.01 ; 100 ; 0.30 ; 104 ; 0.72 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 105, 5, "275 ; 1  ; 1 ; 0.42 ; 413 ; 1 ; 4 ; 24 ; 6 ; 0.12 ; 97 ; 0.01 ; 100 ; 0.45 ; 104 ; 0.66 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 105, 5, "275 ; 1  ; 1 ; 0.48 ; 413 ; 1 ; 4 ; 27 ; 6 ; 0.10 ; 97 ; 0.01 ; 100 ; 0.60 ; 104 ; 0.60 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 105, 5, "275 ; 1  ; 1 ; 0.38 ; 413 ; 1 ; 4 ; 28 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.50 ; 137 ; 5 ; 104 ; 0.80 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 105, 5, "275 ; 1  ; 1 ; 0.54 ; 413 ; 1 ; 4 ; 25 ; 6 ; 0.05 ; 97 ; 0.01 ; 100 ; 0.50 ; 137 ; 5 ; 104 ; 0.80 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 105, 5, "275 ; 1  ; 1 ; 0.50 ; 413 ; 1 ; 4 ; 29 ; 6 ; 0.15 ; 97 ; 0.01 ; 104 ; 0.72 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 105, 5, "275 ; 1  ; 1 ; 0.46 ; 413 ; 1 ; 4 ; 34 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.70 ; 137 ; 5 ; 104 ; 0.20 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 105, 5, "275 ; 1  ; 1 ; 0.40 ; 413 ; 1 ; 4 ; 25 ; 6 ; 0.20 ; 97 ; 0.01 ; 100 ; 0.90 ; 137 ; 5 ; 104 ; 0.20 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
		}
	}
	else if (weapondifficulty==6) // I THINK YOU LOST IT ALREADY!
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 106, 5, "275 ; 1  ; 1 ; 0.60 ; 413 ; 1 ; 4 ; 27 ; 6 ; 0.18 ; 97 ; 0.01 ; 100 ; 0.10 ; 104 ; 0.94 ; 137 ; 5 ; 37 ; 0 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 106, 5, "275 ; 1  ; 1 ; 0.64 ; 413 ; 1 ; 4 ; 29 ; 6 ; 0.16 ; 97 ; 0.01 ; 100 ; 0.15 ; 104 ; 0.98 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 106, 5, "275 ; 1  ; 1 ; 0.56 ; 413 ; 1 ; 4 ; 30 ; 6 ; 0.14 ; 97 ; 0.01 ; 100 ; 0.30 ; 104 ; 0.92 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 106, 5, "275 ; 1  ; 1 ; 0.62 ; 413 ; 1 ; 4 ; 32 ; 6 ; 0.12 ; 97 ; 0.01 ; 100 ; 0.45 ; 104 ; 0.86 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 106, 5, "275 ; 1  ; 1 ; 0.68 ; 413 ; 1 ; 4 ; 35 ; 6 ; 0.10 ; 97 ; 0.01 ; 100 ; 0.60 ; 104 ; 0.80 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 106, 5, "275 ; 1  ; 1 ; 0.58 ; 413 ; 1 ; 4 ; 36 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.50 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 106, 5, "275 ; 1  ; 1 ; 0.74 ; 413 ; 1 ; 4 ; 33 ; 6 ; 0.05 ; 97 ; 0.01 ; 100 ; 0.50 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 106, 5, "275 ; 1  ; 1 ; 0.70 ; 413 ; 1 ; 4 ; 37 ; 6 ; 0.15 ; 97 ; 0.01 ; 104 ; 0.92 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 106, 5, "275 ; 1  ; 1 ; 0.66 ; 413 ; 1 ; 4 ; 42 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.70 ; 137 ; 5 ; 104 ; 0.50 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 106, 5, "275 ; 1  ; 1 ; 0.60 ; 413 ; 1 ; 4 ; 33 ; 6 ; 0.20 ; 97 ; 0.01 ; 100 ; 0.90 ; 137 ; 5 ; 104 ; 0.50 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
		}
	}
	else if (weapondifficulty==7) // WAKE UP!!!! PLEASE WAKE UP!!!
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 107, 5, "275 ; 1  ; 1 ; 0.80 ; 413 ; 1 ; 4 ; 39 ; 6 ; 0.18 ; 97 ; 0.01 ; 100 ; 0.10 ; 103 ; 1.14 ; 137 ; 5 ; 37 ; 0 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 107, 5, "275 ; 1  ; 1 ; 0.84 ; 413 ; 1 ; 4 ; 41 ; 6 ; 0.16 ; 97 ; 0.01 ; 100 ; 0.15 ; 103 ; 1.18 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 107, 5, "275 ; 1  ; 1 ; 0.76 ; 413 ; 1 ; 4 ; 32 ; 6 ; 0.14 ; 97 ; 0.01 ; 100 ; 0.30 ; 103 ; 1.12 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 107, 5, "275 ; 1  ; 1 ; 0.82 ; 413 ; 1 ; 4 ; 42 ; 6 ; 0.12 ; 97 ; 0.01 ; 100 ; 0.45 ; 103 ; 1.06 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 107, 5, "275 ; 1  ; 1 ; 0.88 ; 413 ; 1 ; 4 ; 47 ; 6 ; 0.10 ; 97 ; 0.01 ; 100 ; 0.60 ; 103 ; 1.05 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 107, 5, "275 ; 1  ; 1 ; 0.78 ; 413 ; 1 ; 4 ; 48 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.50 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 107, 5, "275 ; 1  ; 1 ; 0.94 ; 413 ; 1 ; 4 ; 13 ; 6 ; 0.05 ; 97 ; 0.01 ; 100 ; 0.50 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 107, 5, "275 ; 1  ; 1 ; 0.90 ; 413 ; 1 ; 4 ; 49 ; 6 ; 0.15 ; 97 ; 0.01 ; 103 ; 1.22 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 107, 5, "275 ; 1  ; 1 ; 0.86 ; 413 ; 1 ; 4 ; 44 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.70 ; 137 ; 5 ; 104 ; 0.80 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 107, 5, "275 ; 1  ; 1 ; 0.80 ; 413 ; 1 ; 4 ; 45 ; 6 ; 0.20 ; 97 ; 0.01 ; 100 ; 0.90 ; 137 ; 5 ; 104 ; 0.80 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
		}
	}
	else if (weapondifficulty==8) // ARE YOU SERIOUS?
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 108, 5, "275 ; 1  ; 2 ; 0.60 ; 413 ; 1 ; 4 ; 40 ; 6 ; 0.20 ; 97 ; 0.01 ; 100 ; 0.15 ; 137 ; 20 ; 411 ; 15 ; 37 ; 0 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 108, 5, "275 ; 1  ; 1 ; 0.75 ; 413 ; 1 ; 4 ; 45 ; 6 ; 0.17 ; 97 ; 0.01 ; 100 ; 0.30 ; 103 ; 1.35 ; 137 ; 20 ; 411 ; 13 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 108, 5, "275 ; 1  ; 1 ; 0.70 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.14 ; 97 ; 0.01 ; 100 ; 0.45 ; 103 ; 1.30 ; 137 ; 20 ; 411 ; 11 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 108, 5, "275 ; 1  ; 1 ; 0.75 ; 413 ; 1 ; 4 ; 55 ; 6 ; 0.11 ; 97 ; 0.01 ; 100 ; 0.60 ; 103 ; 1.20 ; 137 ; 20 ; 411 ; 8 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 108, 5, "275 ; 1  ; 1 ; 0.80 ; 413 ; 1 ; 4 ; 60 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.75 ; 103 ; 1.05 ; 137 ; 20 ; 411 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 108, 5, "275 ; 1  ; 1 ; 0.85 ; 413 ; 1 ; 4 ; 48 ; 6 ; 0.06 ; 97 ; 0.01 ; 103 ; 1.20 ; 100 ; 0.10 ; 137 ; 20 ; 411 ; 25 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 108, 5, "275 ; 1  ; 1 ; 0.85 ; 413 ; 1 ; 4 ; 40 ; 6 ; 0.05 ; 97 ; 0.01  ; 103 ; 1.05 ; 137 ; 20 ; 411 ; 20 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 108, 5, "275 ; 1  ; 1 ; 0.85 ; 413 ; 1 ; 4 ; 42 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.70 ; 103 ; 1.25 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 108, 5, "275 ; 1  ; 1 ; 0.80 ; 413 ; 1 ; 4 ; 55 ; 6 ; 0.03 ; 97 ; 0.01 ; 100 ; 0.20 ; 103 ; 1.24 ; 137 ; 20 ; 411 ; 35 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 108, 5, "275 ; 1  ; 1 ; 0.90 ; 413 ; 1 ; 4 ; 47 ; 6 ; 0.13 ; 97 ; 0.01 ; 100 ; 0.50 ; 103 ; 1.10 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
		}
	}
}

// Blitzkrieg's much more powerful weapons whenever he loses a life. This is his weapon config
BlitzkriegBarrage(client)
{
	if (weapondifficulty==0) // Easy
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 100, 5, "275 ; 1  ; 1 ; 0.05 ; 413 ; 1 ; 4 ; 5 ; 6 ; 0.20 ; 97 ; 0.01 ; 100 ; 0.15 ; 104 ; 0.40 ; 137 ; 20 ; 411 ; 15 ; 37 ; 0 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 100, 5, "275 ; 1  ; 1 ; 0.10 ; 413 ; 1 ; 4 ; 10 ; 6 ; 0.17 ; 97 ; 0.01 ; 100 ; 0.30 ; 104 ; 0.35 ; 137 ; 20 ; 411 ; 13 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 100, 5, "275 ; 1  ; 1 ; 0.15 ; 413 ; 1 ; 4 ; 15 ; 6 ; 0.14 ; 97 ; 0.01 ; 100 ; 0.45 ; 104 ; 0.30 ; 137 ; 20 ; 411 ; 11 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 100, 5, "275 ; 1  ; 1 ; 0.07 ; 413 ; 1 ; 4 ; 20 ; 6 ; 0.11 ; 97 ; 0.01 ; 100 ; 0.60 ; 104 ; 0.25 ; 137 ; 20 ; 411 ; 8 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 100, 5, "275 ; 1  ; 1 ; 0.12 ; 413 ; 1 ; 4 ; 25 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.75 ; 104 ; 0.20 ; 137 ; 20 ; 411 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 100, 5, "275 ; 1  ; 1 ; 0.07 ; 413 ; 1 ; 4 ; 23 ; 6 ; 0.06 ; 97 ; 0.01 ; 100 ; 0.10 ; 104 ; 0.50 ; 137 ; 20 ; 411 ; 25 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 100, 5, "275 ; 1  ; 1 ; 0.13 ; 413 ; 1 ; 4 ; 15 ; 6 ; 0.05 ; 97 ; 0.01  ; 104 ; 0.35 ; 137 ; 20 ; 411 ; 20 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 100, 5, "275 ; 1  ; 1 ; 0.15 ; 413 ; 1 ; 4 ; 17 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.70 ; 104 ; 0.45 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 100, 5, "275 ; 1  ; 1 ; 0.10 ; 413 ; 1 ; 4 ; 25 ; 6 ; 0.03 ; 97 ; 0.01 ; 100 ; 0.20 ; 137 ; 20 ; 104 ; 0.50 ; 411 ; 35 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 100, 5, "275 ; 1  ; 1 ; 0.17 ; 413 ; 1 ; 4 ; 23 ; 6 ; 0.13 ; 97 ; 0.01 ; 100 ; 0.50 ; 104 ; 0.40 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
		}
	}
	else if (weapondifficulty==1) // Normal
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 101, 5, "275 ; 1  ; 1 ; 0.10 ; 413 ; 1 ; 4 ; 15 ; 6 ; 0.20 ; 97 ; 0.01 ; 100 ; 0.15 ; 104 ; 0.90 ; 137 ; 20 ; 411 ; 15 ; 37 ; 0 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 101, 5, "275 ; 1  ; 1 ; 0.15 ; 413 ; 1 ; 4 ; 20 ; 6 ; 0.17 ; 97 ; 0.01 ; 100 ; 0.30 ; 104 ; 0.75 ; 137 ; 20 ; 411 ; 13 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 101, 5, "275 ; 1  ; 1 ; 0.20 ; 413 ; 1 ; 4 ; 25 ; 6 ; 0.14 ; 97 ; 0.01 ; 100 ; 0.45 ; 104 ; 0.60 ; 137 ; 20 ; 411 ; 11 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 101, 5, "275 ; 1  ; 1 ; 0.25 ; 413 ; 1 ; 4 ; 30 ; 6 ; 0.11 ; 97 ; 0.01 ; 100 ; 0.60 ; 104 ; 0.40 ; 137 ; 20 ; 411 ; 8 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 101, 5, "275 ; 1  ; 1 ; 0.30 ; 413 ; 1 ; 4 ; 35 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.75 ; 104 ; 0.25 ; 137 ; 20 ; 411 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 101, 5, "275 ; 1  ; 1 ; 0.15 ; 413 ; 1 ; 4 ; 34 ; 6 ; 0.06 ; 97 ; 0.01 ; 100 ; 0.10 ; 137 ; 20 ; 411 ; 25 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 101, 5, "275 ; 1  ; 1 ; 0.20 ; 413 ; 1 ; 4 ; 25 ; 6 ; 0.05 ; 97 ; 0.01  ; 104 ; 0.45 ; 137 ; 20 ; 411 ; 20 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 101, 5, "275 ; 1  ; 1 ; 0.25 ; 413 ; 1 ; 4 ; 27 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.70 ; 104 ; 0.95 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 101, 5, "275 ; 1  ; 1 ; 0.20 ; 413 ; 1 ; 4 ; 40 ; 6 ; 0.03 ; 97 ; 0.01 ; 100 ; 0.20 ; 137 ; 20 ; 411 ; 35 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 101, 5, "275 ; 1  ; 1 ; 0.30 ; 413 ; 1 ; 4 ; 33 ; 6 ; 0.13 ; 97 ; 0.01 ; 100 ; 0.50 ; 104 ; 0.50 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
		}
	}
	else if (weapondifficulty==2) // Intermediate
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 102, 5, "275 ; 1  ; 1 ; 0.15 ; 413 ; 1 ; 4 ; 20 ; 6 ; 0.20 ; 97 ; 0.01 ; 100 ; 0.15 ; 104 ; 0.90 ; 137 ; 20 ; 411 ; 15 ; 37 ; 0 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 102, 5, "275 ; 1  ; 1 ; 0.20 ; 413 ; 1 ; 4 ; 25 ; 6 ; 0.17 ; 97 ; 0.01 ; 100 ; 0.30 ; 104 ; 0.75 ; 137 ; 20 ; 411 ; 13 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 102, 5, "275 ; 1  ; 1 ; 0.25 ; 413 ; 1 ; 4 ; 30 ; 6 ; 0.14 ; 97 ; 0.01 ; 100 ; 0.45 ; 104 ; 0.60 ; 137 ; 20 ; 411 ; 11 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 102, 5, "275 ; 1  ; 1 ; 0.30 ; 413 ; 1 ; 4 ; 35 ; 6 ; 0.11 ; 97 ; 0.01 ; 100 ; 0.60 ; 104 ; 0.40 ; 137 ; 20 ; 411 ; 8 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 102, 5, "275 ; 1  ; 1 ; 0.35 ; 413 ; 1 ; 4 ; 49 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.75 ; 104 ; 0.25 ; 137 ; 20 ; 411 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 102, 5, "275 ; 1  ; 1 ; 0.20 ; 413 ; 1 ; 4 ; 45 ; 6 ; 0.06 ; 97 ; 0.01 ; 100 ; 0.10 ; 137 ; 20 ; 411 ; 25 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 102, 5, "275 ; 1  ; 1 ; 0.25 ; 413 ; 1 ; 4 ; 40 ; 6 ; 0.05 ; 97 ; 0.01  ; 104 ; 0.45 ; 137 ; 20 ; 411 ; 20 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 102, 5, "275 ; 1  ; 1 ; 0.30 ; 413 ; 1 ; 4 ; 32 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.70 ; 104 ; 0.95 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 102, 5, "275 ; 1  ; 1 ; 0.25 ; 413 ; 1 ; 4 ; 45 ; 6 ; 0.03 ; 97 ; 0.01 ; 100 ; 0.20 ; 137 ; 20 ; 411 ; 35 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 102, 5, "275 ; 1  ; 1 ; 0.32 ; 413 ; 1 ; 4 ; 37 ; 6 ; 0.13 ; 97 ; 0.01 ; 100 ; 0.50 ; 104 ; 0.50 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
		}
	}
	else if (weapondifficulty==3) // Difficult
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 103, 5, "275 ; 1  ; 1 ; 0.20 ; 413 ; 1 ; 4 ; 25 ; 6 ; 0.20 ; 97 ; 0.01 ; 100 ; 0.15 ; 137 ; 20 ; 411 ; 15 ; 37 ; 0 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 103, 5, "275 ; 1  ; 1 ; 0.25 ; 413 ; 1 ; 4 ; 30 ; 6 ; 0.17 ; 97 ; 0.01 ; 100 ; 0.30 ; 104 ; 0.85 ; 137 ; 20 ; 411 ; 13 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 103, 5, "275 ; 1  ; 1 ; 0.30 ; 413 ; 1 ; 4 ; 35 ; 6 ; 0.14 ; 97 ; 0.01 ; 100 ; 0.45 ; 104 ; 0.70 ; 137 ; 20 ; 411 ; 11 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 103, 5, "275 ; 1  ; 1 ; 0.35 ; 413 ; 1 ; 4 ; 40 ; 6 ; 0.11 ; 97 ; 0.01 ; 100 ; 0.60 ; 104 ; 0.50 ; 137 ; 20 ; 411 ; 8 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 103, 5, "275 ; 1  ; 1 ; 0.40 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.75 ; 104 ; 0.35 ; 137 ; 20 ; 411 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 103, 5, "275 ; 1  ; 1 ; 0.25 ; 413 ; 1 ; 4 ; 48 ; 6 ; 0.06 ; 97 ; 0.01 ; 100 ; 0.10 ; 137 ; 20 ; 411 ; 25 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 103, 5, "275 ; 1  ; 1 ; 0.30 ; 413 ; 1 ; 4 ; 40 ; 6 ; 0.05 ; 97 ; 0.01  ; 104 ; 0.55 ; 137 ; 20 ; 411 ; 20 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 103, 5, "275 ; 1  ; 1 ; 0.35 ; 413 ; 1 ; 4 ; 42 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.70 ; 104 ; 0.95 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 103, 5, "275 ; 1  ; 1 ; 0.30 ; 413 ; 1 ; 4 ; 55 ; 6 ; 0.03 ; 97 ; 0.01 ; 100 ; 0.20 ; 137 ; 20 ; 411 ; 35 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 103, 5, "275 ; 1  ; 1 ; 0.40 ; 413 ; 1 ; 4 ; 47 ; 6 ; 0.13 ; 97 ; 0.01 ; 100 ; 0.50 ; 104 ; 0.60 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
		}
	}
	else if (weapondifficulty==4) // Lunatic
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 104, 5, "275 ; 1  ; 1 ; 0.30 ; 413 ; 1 ; 4 ; 30 ; 6 ; 0.20 ; 97 ; 0.01 ; 100 ; 0.15 ; 137 ; 20 ; 411 ; 15 ; 37 ; 0 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 104, 5, "275 ; 1  ; 1 ; 0.35 ; 413 ; 1 ; 4 ; 35 ; 6 ; 0.17 ; 97 ; 0.01 ; 100 ; 0.30 ; 103 ; 1.15 ; 137 ; 20 ; 411 ; 13 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 104, 5, "275 ; 1  ; 1 ; 0.40 ; 413 ; 1 ; 4 ; 40 ; 6 ; 0.14 ; 97 ; 0.01 ; 100 ; 0.45 ; 137 ; 20 ; 411 ; 11 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 104, 5, "275 ; 1  ; 1 ; 0.45 ; 413 ; 1 ; 4 ; 45 ; 6 ; 0.11 ; 97 ; 0.01 ; 100 ; 0.60 ; 104 ; 0.80 ; 137 ; 20 ; 411 ; 8 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 104, 5, "275 ; 1  ; 1 ; 0.50 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.75 ; 104 ; 0.65 ; 137 ; 20 ; 411 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 104, 5, "275 ; 1  ; 1 ; 0.45 ; 413 ; 1 ; 4 ; 58 ; 6 ; 0.06 ; 97 ; 0.01 ; 100 ; 0.10 ; 137 ; 20 ; 411 ; 25 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 104, 5, "275 ; 1  ; 1 ; 0.45 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.05 ; 97 ; 0.01  ; 104 ; 0.65 ; 137 ; 20 ; 411 ; 20 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 104, 5, "275 ; 1  ; 1 ; 0.55 ; 413 ; 1 ; 4 ; 52 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.70 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 104, 5, "275 ; 1  ; 1 ; 0.50 ; 413 ; 1 ; 4 ; 65 ; 6 ; 0.03 ; 97 ; 0.01 ; 100 ; 0.20 ; 137 ; 20 ; 411 ; 35 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 104, 5, "275 ; 1  ; 1 ; 0.60 ; 413 ; 1 ; 4 ; 57 ; 6 ; 0.13 ; 97 ; 0.01 ; 100 ; 0.50 ; 104 ; 0.70 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
		}
	}
	else if (weapondifficulty==5) // YOU MUST BE DREAMING TO EVEN TRY THIS!
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 105, 5, "275 ; 1  ; 1 ; 0.40 ; 413 ; 1 ; 4 ; 35 ; 6 ; 0.20 ; 97 ; 0.01 ; 100 ; 0.15 ; 137 ; 20 ; 411 ; 15 ; 37 ; 0 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 105, 5, "275 ; 1  ; 1 ; 0.55 ; 413 ; 1 ; 4 ; 40 ; 6 ; 0.17 ; 97 ; 0.01 ; 100 ; 0.30 ; 103 ; 1.25 ; 137 ; 20 ; 411 ; 13 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 105, 5, "275 ; 1  ; 1 ; 0.50 ; 413 ; 1 ; 4 ; 45 ; 6 ; 0.14 ; 97 ; 0.01 ; 100 ; 0.45 ; 103 ; 1.10 ; 137 ; 20 ; 411 ; 11 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 105, 5, "275 ; 1  ; 1 ; 0.55 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.11 ; 97 ; 0.01 ; 100 ; 0.60 ; 103 ; 1.10 ; 137 ; 20 ; 411 ; 8 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 105, 5, "275 ; 1  ; 1 ; 0.60 ; 413 ; 1 ; 4 ; 55 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.75 ; 104 ; 0.85 ; 137 ; 20 ; 411 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 105, 5, "275 ; 1  ; 1 ; 0.55 ; 413 ; 1 ; 4 ; 68 ; 6 ; 0.06 ; 97 ; 0.01 ; 103 ; 1.10 ; 100 ; 0.10 ; 137 ; 20 ; 411 ; 25 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 105, 5, "275 ; 1  ; 1 ; 0.55 ; 413 ; 1 ; 4 ; 60 ; 6 ; 0.05 ; 97 ; 0.01  ; 104 ; 0.85 ; 137 ; 20 ; 411 ; 20 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 105, 5, "275 ; 1  ; 1 ; 0.65 ; 413 ; 1 ; 4 ; 62 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.70 ; 103 ; 1.15 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 105, 5, "275 ; 1  ; 1 ; 0.60 ; 413 ; 1 ; 4 ; 65 ; 6 ; 0.03 ; 97 ; 0.01 ; 100 ; 0.20 ; 103 ; 1.14 ; 137 ; 20 ; 411 ; 35 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 105, 5, "275 ; 1  ; 1 ; 0.70 ; 413 ; 1 ; 4 ; 67 ; 6 ; 0.13 ; 97 ; 0.01 ; 100 ; 0.50 ; 104 ; 0.90 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
		}
	}
	else if (weapondifficulty==6) // I THINK YOU LOST IT ALREADY!
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 106, 5, "275 ; 1  ; 1 ; 0.60 ; 413 ; 1 ; 4 ; 40 ; 6 ; 0.20 ; 97 ; 0.01 ; 100 ; 0.15 ; 137 ; 20 ; 411 ; 15 ; 37 ; 0 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 106, 5, "275 ; 1  ; 1 ; 0.75 ; 413 ; 1 ; 4 ; 45 ; 6 ; 0.17 ; 97 ; 0.01 ; 100 ; 0.30 ; 103 ; 1.35 ; 137 ; 20 ; 411 ; 13 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 106, 5, "275 ; 1  ; 1 ; 0.70 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.14 ; 97 ; 0.01 ; 100 ; 0.45 ; 103 ; 1.30 ; 137 ; 20 ; 411 ; 11 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 106, 5, "275 ; 1  ; 1 ; 0.75 ; 413 ; 1 ; 4 ; 55 ; 6 ; 0.11 ; 97 ; 0.01 ; 100 ; 0.60 ; 103 ; 1.20 ; 137 ; 20 ; 411 ; 8 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 106, 5, "275 ; 1  ; 1 ; 0.80 ; 413 ; 1 ; 4 ; 60 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.75 ; 103 ; 1.05 ; 137 ; 20 ; 411 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 106, 5, "275 ; 1  ; 1 ; 0.85 ; 413 ; 1 ; 4 ; 78 ; 6 ; 0.06 ; 97 ; 0.01 ; 103 ; 1.20 ; 100 ; 0.10 ; 137 ; 20 ; 411 ; 25 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 106, 5, "275 ; 1  ; 1 ; 0.85 ; 413 ; 1 ; 4 ; 70 ; 6 ; 0.05 ; 97 ; 0.01  ; 103 ; 1.05 ; 137 ; 20 ; 411 ; 20 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 106, 5, "275 ; 1  ; 1 ; 0.85 ; 413 ; 1 ; 4 ; 72 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.70 ; 103 ; 1.25 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 106, 5, "275 ; 1  ; 1 ; 0.80 ; 413 ; 1 ; 4 ; 75 ; 6 ; 0.03 ; 97 ; 0.01 ; 100 ; 0.20 ; 103 ; 1.24 ; 137 ; 20 ; 411 ; 35 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 106, 5, "275 ; 1  ; 1 ; 0.90 ; 413 ; 1 ; 4 ; 77 ; 6 ; 0.13 ; 97 ; 0.01 ; 100 ; 0.50 ; 103 ; 1.10 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
		}
	}
	else if (weapondifficulty==7) // WAKE UP!!!! PLEASE WAKE UP!!!
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 107, 5, "275 ; 1  ; 1 ; 0.90 ; 413 ; 1 ; 4 ; 45 ; 6 ; 0.20 ; 97 ; 0.01 ; 100 ; 0.15 ; 137 ; 20 ; 411 ; 15 ; 37 ; 0 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 107, 5, "275 ; 1  ; 1 ; 0.95 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.17 ; 97 ; 0.01 ; 100 ; 0.30 ; 103 ; 1.65 ; 137 ; 20 ; 411 ; 13 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 107, 5, "275 ; 1  ; 1 ; 0.90 ; 413 ; 1 ; 4 ; 55 ; 6 ; 0.14 ; 97 ; 0.01 ; 100 ; 0.45 ; 103 ; 1.60 ; 137 ; 20 ; 411 ; 11 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 107, 5, "275 ; 1  ; 1 ; 0.95 ; 413 ; 1 ; 4 ; 60 ; 6 ; 0.11 ; 97 ; 0.01 ; 100 ; 0.60 ; 103 ; 1.50 ; 137 ; 20 ; 411 ; 8 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 107, 5, "275 ; 1  ; 2 ; 1.10 ; 413 ; 1 ; 4 ; 65 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.75 ; 103 ; 1.40 ; 137 ; 20 ; 411 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 107, 5, "275 ; 1  ; 2 ; 1.15 ; 413 ; 1 ; 4 ; 88 ; 6 ; 0.06 ; 97 ; 0.01 ; 103 ; 1.50 ; 100 ; 0.10 ; 137 ; 20 ; 411 ; 25 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 107, 5, "275 ; 1  ; 2 ; 1.25 ; 413 ; 1 ; 4 ; 80 ; 6 ; 0.05 ; 97 ; 0.01  ; 103 ; 1.60 ; 137 ; 20 ; 411 ; 20 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 107, 5, "275 ; 1  ; 2 ; 1.05 ; 413 ; 1 ; 4 ; 82 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.70 ; 103 ; 1.50 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 107, 5, "275 ; 1  ; 2 ; 1.20 ; 413 ; 1 ; 4 ; 85 ; 6 ; 0.03 ; 97 ; 0.01 ; 100 ; 0.20 ; 103 ; 1.48 ; 137 ; 20 ; 411 ; 35 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 107, 5, "275 ; 1  ; 2 ; 1.30 ; 413 ; 1 ; 4 ; 87 ; 6 ; 0.13 ; 97 ; 0.01 ; 100 ; 0.50 ; 103 ; 1.70 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
		}
	}
	else if (weapondifficulty==8) // ARE YOU SERIOUS? 
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 108, 5, "275 ; 1  ; 2 ; 1.90 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.20 ; 97 ; 0.01 ; 100 ; 0.15 ; 137 ; 20 ; 411 ; 15 ; 37 ; 0 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 108, 5, "275 ; 1  ; 2 ; 1.95 ; 413 ; 1 ; 4 ; 55 ; 6 ; 0.17 ; 97 ; 0.01 ; 100 ; 0.30 ; 103 ; 2.65 ; 137 ; 20 ; 411 ; 13 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 108, 5, "275 ; 1  ; 2 ; 1.90 ; 413 ; 1 ; 4 ; 60 ; 6 ; 0.14 ; 97 ; 0.01 ; 100 ; 0.45 ; 103 ; 2.60 ; 137 ; 20 ; 411 ; 11 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 108, 5, "275 ; 1  ; 2 ; 1.95 ; 413 ; 1 ; 4 ; 65 ; 6 ; 0.11 ; 97 ; 0.01 ; 100 ; 0.60 ; 103 ; 2.50 ; 137 ; 20 ; 411 ; 8 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 108, 5, "275 ; 1  ; 2 ; 2.10 ; 413 ; 1 ; 4 ; 70 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.75 ; 103 ; 2.40 ; 137 ; 20 ; 411 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 108, 5, "275 ; 1  ; 2 ; 2.15 ; 413 ; 1 ; 4 ; 98 ; 6 ; 0.06 ; 97 ; 0.01 ; 103 ; 2.50 ; 100 ; 0.10 ; 137 ; 20 ; 411 ; 25 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 108, 5, "275 ; 1  ; 2 ; 2.25 ; 413 ; 1 ; 4 ; 90 ; 6 ; 0.05 ; 97 ; 0.01  ; 103 ; 2.60 ; 137 ; 20 ; 411 ; 20 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 108, 5, "275 ; 1  ; 2 ; 2.05 ; 413 ; 1 ; 4 ; 92 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.70 ; 103 ; 2.50 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 108, 5, "275 ; 1  ; 2 ; 2.20 ; 413 ; 1 ; 4 ; 95 ; 6 ; 0.03 ; 97 ; 0.01 ; 100 ; 0.20 ; 103 ; 2.48 ; 137 ; 20 ; 411 ; 35 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 108, 5, "275 ; 1  ; 2 ; 2.30 ; 413 ; 1 ; 4 ; 97 ; 6 ; 0.13 ; 97 ; 0.01 ; 100 ; 0.50 ; 103 ; 2.70 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
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

// Events

public Action:event_round_start(Handle:event, const String:name[], bool:dontBroadcast)
{
	// Here, we have a config for blitzkrieg's rounds //
	if (FF2_IsFF2Enabled())
	{
		danmakuboss = GetClientOfUserId(FF2_GetBossUserId(0));
		if (danmakuboss>0)
		{
			if (FF2_HasAbility(0, this_plugin_name, "blitzkrieg_config"))
			{	
				weapondifficulty=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 1, 1);
				combatstyle=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 2);
				customweapons=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 3); // use custom weapons
				if(combatstyle!=0)
				{	
					nomelee = CreateTimer(11.0, DanmakuOnly);
				}
				else if(combatstyle==0)
				{
					withmelee = CreateTimer(11.0, DanmakuMelee);
				}
				if(customweapons == 1)
				{
					CreateTimer(0.1, BlitzCustomWeapons);
					specialweapons = CreateTimer(11.0, BlitzCustomWeapons);
				}
				else if(customweapons == 0)
				{
					PrintToServer("Custom weapons are disabled. Set arg3 to 1 to enable them");
				}
			}
			else
				CreateTimer(0.1, StopAll);
		}
	}
}

public Action:event_player_death(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(GetEventInt(event, "death_flags") & TF_DEATHFLAG_DEADRINGER)
	{
		return Plugin_Continue;
	}
	return Plugin_Continue;
}

public Action:event_round_end(Handle:event, const String:name[], bool:dontBroadcast)
{
	new attacker=GetClientOfUserId(GetEventInt(event, "attacker"));
	new bossAttacker=FF2_GetBossIndex(attacker);
	SetEntityGravity(bossAttacker, 1.0);
	CreateTimer(0.1, StopAll);
	return Plugin_Continue;
}


// Timers
public Action:StopAll(Handle:hTimer,any:index)
{
	if (screwgravity!=INVALID_HANDLE)
		{
			KillTimer(screwgravity);
			screwgravity = INVALID_HANDLE;
		}
	else if (crockethell!=INVALID_HANDLE)
		{
			KillTimer(crockethell);
			crockethell = INVALID_HANDLE;
		}
	else if (specialweapons!=INVALID_HANDLE)
		{
			KillTimer(specialweapons);
			specialweapons = INVALID_HANDLE;
		}
	else if (nomelee!=INVALID_HANDLE)
		{
			KillTimer(nomelee);
			nomelee = INVALID_HANDLE;
		}
	else if (withmelee!=INVALID_HANDLE)
		{
			KillTimer(withmelee);
			withmelee = INVALID_HANDLE;
		}
	return Plugin_Stop;
}

public Action:ClassResponses(Handle:hTimer,any:index)
{
	decl i;
	for( i = 1; i <= MaxClients; i++ )
	{
		if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i)!=BossTeam)
		{
			if(TF2_GetPlayerClass(i)==TFClass_Scout)
			{
				switch (GetRandomInt(0,1))
				{
					case 0:
						EmitSoundToAll(SCOUT_R1,i);
					case 1:
						EmitSoundToAll(SCOUT_R2,i);
				}
			}
			else if(TF2_GetPlayerClass(i)==TFClass_Soldier)
			{
				EmitSoundToAll(SOLLY_R1,i);
			}
			else if(TF2_GetPlayerClass(i)==TFClass_Pyro)
			{
				EmitSoundToAll(PYRO_R1,i);
			}
			else if(TF2_GetPlayerClass(i)==TFClass_DemoMan)
			{
				EmitSoundToAll(DEMO_R1,i);
			}
			else if(TF2_GetPlayerClass(i)==TFClass_Heavy)
			{
				switch (GetRandomInt(0,1))
				{
					case 0:
						EmitSoundToAll(HEAVY_R1,i);
					case 1:	
						EmitSoundToAll(HEAVY_R2,i);
				}
			}
			else if(TF2_GetPlayerClass(i)==TFClass_Engineer)
			{
				switch (GetRandomInt(0,1))
				{
					case 0:
						EmitSoundToAll(ENGY_R1,i);
					case 1:
						EmitSoundToAll(ENGY_R2,i);
				}
			}
			else if(TF2_GetPlayerClass(i)==TFClass_Medic)
			{
				switch (GetRandomInt(0,4))
				{
					case 0:
						EmitSoundToAll(MEDIC_R1,i);
					case 1:
						EmitSoundToAll(MEDIC_R2,i);
					case 2:
						EmitSoundToAll(MEDIC_R3,i);
					case 3:
						EmitSoundToAll(MEDIC_R4,i);
					case 4:
						EmitSoundToAll(MEDIC_R5,i);
				}
			}	
			else if(TF2_GetPlayerClass(i)==TFClass_Sniper)
			{
				switch (GetRandomInt(0,2))
				{
					case 0:
						EmitSoundToAll(SNIPER_R1,i);
					case 1:
						EmitSoundToAll(SNIPER_R2,i);
					case 2:
						EmitSoundToAll(SNIPER_R3,i);
				}
			}	
			else if(TF2_GetPlayerClass(i)==TFClass_Spy)
			{
				switch (GetRandomInt(0,4))
				{
					case 0:
						EmitSoundToAll(SPY_R1,i);
					case 1:
						EmitSoundToAll(SPY_R2,i);
					case 2:
						EmitSoundToAll(SPY_R3,i);
					case 3:
						EmitSoundToAll(SPY_R4,i);
					case 4:
						EmitSoundToAll(SPY_R5,i);
					case 5:
						EmitSoundToAll(SPY_R6,i);
				}						
			}
		}
	}
}

public Action:ItzBlitzkriegTime(Handle:hTimer,any:index)
{
	new Boss=GetClientOfUserId(FF2_GetBossUserId(index));
	TF2_RemoveWeaponSlot(Boss, TFWeaponSlot_Primary);
	RandomDanmaku(Boss);	
	if(combatstyle==0)
	{
		SetAmmo(Boss, TFWeaponSlot_Primary,360);
	}
	else if(combatstyle!=0)
	{
		SetAmmo(Boss, TFWeaponSlot_Primary,999999);
	}
	SetEntityGravity(Boss, 1.0);
	PrintToServer("Rampage time expired. He should be getting one of the 10 normal rocket launchers he gains on-rage.");
	crockethell = INVALID_HANDLE;
}

public Action:ScrewThisGravity(Handle:hTimer,any:index)
{
	new Boss=GetClientOfUserId(FF2_GetBossUserId(index));
	SetEntityGravity(Boss, 1.0);
	PrintToServer("Gravity reset. His gravity should be restored to normal by now.");
	screwgravity = INVALID_HANDLE;
	
}

public Action:Rage_Timer_UnuseCharge(Handle:hTimer,any:index)
{
	new Boss=GetClientOfUserId(FF2_GetBossUserId(index));
	PrintToServer("Ubercharge Reset");
	SetEntProp(Boss, Prop_Data, "m_takedamage", 2);
	return Plugin_Continue;
}

public Action:DanmakuMelee(Handle:hTimer,any:index)
{
	new Boss=GetClientOfUserId(FF2_GetBossUserId(index));
	PrintHintText(Boss, "Mode is Mixed Combat. Your Ubersaw can Backstab");
	TF2_RemoveWeaponSlot(Boss, TFWeaponSlot_Primary);
	RandomDanmaku(Boss);
	SetAmmo(Boss, TFWeaponSlot_Primary,360);
	withmelee = INVALID_HANDLE;
}

public Action:DanmakuOnly(Handle:hTimer,any:index)
{
	new Boss=GetClientOfUserId(FF2_GetBossUserId(index));
	TF2_RemoveWeaponSlot(Boss, TFWeaponSlot_Melee);
	PrintHintText(Boss, "Mode is Pure Danmaku, meaning you must rely on your rocket launcher's Danmaku to defeat the other team");
	TF2_RemoveWeaponSlot(Boss, TFWeaponSlot_Primary);
	RandomDanmaku(Boss);
	SetAmmo(Boss, TFWeaponSlot_Primary,999999);
	nomelee = INVALID_HANDLE;
}

public Action:BlitzCustomWeapons(Handle:hTimer,any:index)
{
	decl i;
	for( i = 1; i <= MaxClients; i++ )
	if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i)!=BossTeam)
	{	
		if(TF2_GetPlayerClass(i)==TFClass_Soldier)
		{	
			TF2_RemoveWeaponSlot(i, TFWeaponSlot_Primary);
			SpawnWeapon(i, "tf_weapon_rocketlauncher", 18, 5, 10, "112 ; 5 ; 1 ; 0.70 ; 4 ; 2.5 ; 6 ; 0.25 ; 15 ; 1 ; 58 ; 5 ; 65 ; 1.20 ; 76 ; 2 ; 181 ; 1 ; 230 ; 10 ; 275 ; 1 ; 421 ; 1");
			SetAmmo(i, TFWeaponSlot_Primary,100);
			PrintHintText(i,"You have gained an upgraded rocket launcher.");
		}
		if(TF2_GetPlayerClass(i)==TFClass_Engineer)
		{
			TF2_RemoveWeaponSlot(i, TFWeaponSlot_Grenade);
			SpawnWeapon(i, "tf_weapon_pda_engineer_build", 25, 10, 10, "276 ; 1");
			PrintHintText(i,"Teleporters are bi-directional teleporters.");
		}
		if(TF2_GetPlayerClass(i)==TFClass_Medic)
		{
			TF2_RemoveWeaponSlot(i, TFWeaponSlot_Secondary);
			SpawnWeapon(i, "tf_weapon_medigun", 29, 5, 10, "499 ; 50.0 ; 10 ; 1.25 ; 178 ; 0.75 ; 144 ; 2.0 ; 11 ; 2.0");
			PrintHintText(i,"Your Medigun is equipped with a projectile shield. Use +attack3 to activate it");
		}
	}
	specialweapons = INVALID_HANDLE;
}
