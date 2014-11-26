// The Blitzkrieg's abilities pack:
// blitzkrieg_config - Configuration for his rounds.
// blitzkrieg_barrage - Become ubercharged, crit boosted, change rocket launchers.
// mini_blitzkrieg - Identical to rage_blitzkrieg, but without ubercharge.

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
new Handle: screwgravity;
//Other Stuff
new customweapons;
new combatstyle;
new weapondifficulty;
new voicelines;
new danmakuboss;
new blitzkriegrage;
new miniblitzkriegrage;
new blitzgrav;
new BossTeam=_:TFTeam_Blue;
//new OtherTeam=_:TFTeam_Red;

#define PLUGIN_VERSION "1.77.2"
#define UPDATE_URL "http://www.shadow93.info/tf2/tf2plugins/tf2danmaku/update.txt"

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
	PrintToServer("************************************************************************");
	PrintToServer("--------------------FREAK FORTRESS 2: THE BLITZKRIEG--------------------");
	PrintToServer("------------BETA 1.77.2 EXPERIMENTAL - BY SHADoW NiNE TR3S---------------");
	PrintToServer("------------------------------------------------------------------------");
	PrintToServer("-if you encounter bugs or see errors in console relating to this plugin-");
	PrintToServer("-please post them in Blitzkrieg's Github Repository which can be found--");
	PrintToServer("------at https://github.com/shadow93/tf2danmaku/tree/experimental-------");
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
	if (!strcmp(ability_name,"blitzkrieg_barrage")) 	// UBERCHARGE, KRITZKRIEG & CROCKET HELL
	{	
		if (FF2_GetRoundState()==1)
		{
			new Boss=GetClientOfUserId(FF2_GetBossUserId(index));
			TF2_AddCondition(Boss,TFCond_Ubercharged,FF2_GetAbilityArgumentFloat(index,this_plugin_name,ability_name,1,5.0)); // Ubercharge
			CreateTimer(FF2_GetAbilityArgumentFloat(index,this_plugin_name,ability_name,1,5.0),Rage_Timer_UnuseCharge,index);
			TF2_AddCondition(Boss,TFCond_Kritzkrieged,FF2_GetAbilityArgumentFloat(index,this_plugin_name,ability_name,2,5.0)); // Kritzkrieg
			crockethell = CreateTimer(FF2_GetAbilityArgumentFloat(index,this_plugin_name,ability_name,3),ItzBlitzkriegTime,index);
			SetEntProp(Boss, Prop_Data, "m_takedamage", 0);
			SetEntityGravity(Boss, float(blitzgrav));
			//Switching Blitzkrieg's player class while retaining the same model to switch the voice responses/commands
			if(TF2_GetPlayerClass(Boss)==TFClass_Medic)
			{
				TF2_SetPlayerClass(Boss, TFClass_Soldier);
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
			else if(TF2_GetPlayerClass(Boss)==TFClass_Soldier)
			{
				TF2_SetPlayerClass(Boss, TFClass_Medic);
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
			//Removing unwanted weapons
			TF2_RemoveAllWeapons(Boss);
			//ONLY FOR LEGACY REASONS, FF2 1.10.3 and newer doesn't actually need this to restore the boss model.
			SetVariantString("models/freak_fortress_2/shadow93/dmedic/dmedic.mdl");
			AcceptEntityInput(Boss, "SetCustomModel");
			//Removing all wearables
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
			//Restoring Melee (if using hybrid style), otherwise, giving Blitzkrieg the death effect rocket launchers.
			if(combatstyle==0)
			{
				SpawnWeapon(Boss, "tf_weapon_knife", 1003, 102, 5, "275 ; 1 ; 2 ; 3 ; 1 ; 0.5 ; 39 ; 0.3 ; 68 ; 12 ; 391 ; 1.9 ; 401 ; 1.9 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6");
				BlitzkriegBarrage(Boss);
				SetAmmo(Boss, TFWeaponSlot_Primary,blitzkriegrage);
			}
			else if(combatstyle!=0)
			{
				BlitzkriegBarrage(Boss);
				SetAmmo(Boss, TFWeaponSlot_Primary,blitzkriegrage);
			}
			//For the Class Reaction Voice Lines
			if (voicelines!=0)
			{
				decl i;
				for( i = 1; i <= MaxClients; i++ )
				{
					ClassResponses(i);
				}
			}
			else if (voicelines==0)
			{
				EmitSoundToAll(BLITZKRIEG_SND);
			}	
			//Development Purposes
			PrintToServer("*blitzkrieg_barrage*");
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
			screwgravity = CreateTimer(FF2_GetAbilityArgumentFloat(index,this_plugin_name,ability_name,2),ScrewThisGravity,index);	
			PrintToServer("*mini_blitzkrieg*");
			SetEntityGravity(Boss, float(blitzgrav));
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
			if(crockethell!=INVALID_HANDLE)
			{
				BlitzkriegBarrage(Boss);
				SetAmmo(Boss, TFWeaponSlot_Primary,blitzkriegrage);
				PrintToServer("*blitzkrieg*");
			}
			else
			{
				RandomDanmaku(Boss);
				if(combatstyle==0)
				{
					SetAmmo(Boss, TFWeaponSlot_Primary,miniblitzkriegrage);
				}
				else if(combatstyle!=0)
				{
					SetAmmo(Boss, TFWeaponSlot_Primary,999999);
				}
				PrintToServer("*mini blitzkrieg*");
			}
			if (voicelines!=0)
			{
				decl i;
				for( i = 1; i <= MaxClients; i++ )
				{
					ClassResponses(i);
				}
			}
			else if (voicelines==0)
			{
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

DropReanimator(client)
{
	new reanimator=CreateEntityByName("entity_revive_marker"); // The Entity name for the Reanimator
	SetEntPropEnt(reanimator, Prop_Send, "m_hOwner", client); // client index
	SetEntProp(reanimator, Prop_Send, "m_nSolidType", 2);
	SetEntProp(reanimator, Prop_Send, "m_usSolidFlags", 8);
	SetEntProp(reanimator, Prop_Send, "m_fEffects", 16);
	SetEntProp(reanimator, Prop_Send, "m_iTeamNum", 2); // client team
	SetEntProp(reanimator, Prop_Send, "m_CollisionGroup", 1);
	SetEntProp(reanimator, Prop_Send, "m_bSimulatedEveryTick", 1);
	SetEntProp(reanimator, Prop_Send, "m_nBody", 6);
	SetEntProp(reanimator, Prop_Send, "m_nSequence", 1);
	SetEntPropFloat(reanimator, Prop_Send, "m_flPlaybackRate", 1.0);
	DispatchSpawn(reanimator);
	PrintToServer("DropReanimator(client)");
}

// This is the weapon configs for Blitzkrieg's starter weapons & switch upon rage or after Blitzkrieg ability wears off
RandomDanmaku(client)
{
	if (weapondifficulty==0) // Easy
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 100, 5, "275 ; 1 ;  1 ; 0.05 ; 413 ; 1 ; 4 ; 3.5 ; 6 ; 0.18 ; 97 ; 0.01 ; 100 ; 0.10 ; 104 ; 0.40 ; 137 ; 5 ; 37 ; 0 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 100, 5, "275 ; 1 ;  1 ; 0.06 ; 413 ; 1 ; 4 ; 4.5 ; 6 ; 0.16 ; 97 ; 0.01 ; 100 ; 0.15 ; 104 ; 0.35 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 100, 5, "275 ; 1 ;  1 ; 0.04 ; 413 ; 1 ; 4 ; 5 ; 6 ; 0.14 ; 97 ; 0.01 ; 100 ; 0.30 ; 104 ; 0.35 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 100, 5, "275 ; 1 ;  1 ; 0.06 ; 413 ; 1 ; 4 ; 6 ; 6 ; 0.12 ; 97 ; 0.01 ; 100 ; 0.45 ; 104 ; 0.30 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 100, 5, "275 ; 1 ;  1 ; 0.07 ; 413 ; 1 ; 4 ; 7.5 ; 6 ; 0.10 ; 97 ; 0.01 ; 100 ; 0.60 ; 104 ; 0.30 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 100, 5, "275 ; 1 ;  1 ; 0.04 ; 413 ; 1 ; 4 ; 8 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.25 ; 137 ; 5 ; 104 ; 0.50 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 100, 5, "275 ; 1 ;  1 ; 0.08 ; 413 ; 1 ; 4 ; 6.5 ; 6 ; 0.05 ; 97 ; 0.01 ; 100 ; 0.25 ; 137 ; 5 ; 104 ; 0.45 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 100, 5, "275 ; 1 ;  1 ; 0.07 ; 413 ; 1 ; 4 ; 8.5 ; 6 ; 0.15 ; 97 ; 0.01 ; 104 ; 0.29 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 100, 5, "275 ; 1 ;  1 ; 0.06 ; 413 ; 1 ; 4 ; 11 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.40 ; 137 ; 5 ; 104 ; 0.10 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 100, 5, "275 ; 1 ;  1 ; 0.04 ; 413 ; 1 ; 4 ; 6.5 ; 6 ; 0.20 ; 97 ; 0.01 ; 100 ; 0.35 ; 137 ; 5 ; 104 ; 0.05 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
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
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 103, 5, "275 ; 1 ; 1 ; 0.15 ; 413 ; 1 ; 4 ; 15 ; 6 ; 0.18 ; 97 ; 0.01 ; 100 ; 0.10 ; 104 ; 0.47 ; 137 ; 5 ; 37 ; 0 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 103, 5, "275 ; 1 ; 1 ; 0.17 ; 413 ; 1 ; 4 ; 17 ; 6 ; 0.16 ; 97 ; 0.01 ; 100 ; 0.15 ; 104 ; 0.44 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 103, 5, "275 ; 1 ;  1 ; 0.13 ; 413 ; 1 ; 4 ; 13 ; 6 ; 0.14 ; 97 ; 0.01 ; 100 ; 0.30 ; 104 ; 0.41 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 103, 5, "275 ; 1 ; 1 ; 0.16 ; 413 ; 1 ; 4 ; 17 ; 6 ; 0.12 ; 97 ; 0.01 ; 100 ; 0.45 ; 104 ; 0.38 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 103, 5, "275 ; 1 ; 1 ; 0.19 ; 413 ; 1 ; 4 ; 17 ; 6 ; 0.10 ; 97 ; 0.01 ; 100 ; 0.60 ; 104 ; 0.35 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 103, 5, "275 ; 1 ; 1 ; 0.14 ; 413 ; 1 ; 4 ; 18 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.25 ; 137 ; 5 ; 104 ; 0.55 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 103, 5, "275 ; 1 ; 1 ; 0.22 ; 413 ; 1 ; 4 ; 15 ; 6 ; 0.05 ; 97 ; 0.01 ; 100 ; 0.25 ; 137 ; 5 ; 104 ; 0.50 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 103, 5, "275 ; 1 ; 1 ; 0.20 ; 413 ; 1 ; 4 ; 19 ; 6 ; 0.15 ; 97 ; 0.01 ; 104 ; 0.17 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 103, 5, "275 ; 1 ; 1 ; 0.18 ; 413 ; 1 ; 4 ; 24 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.40 ; 137 ; 5 ; 104 ; 0.15 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 103, 5, "275 ; 1 ; 1 ; 0.15 ; 413 ; 1 ; 4 ; 15 ; 6 ; 0.20 ; 97 ; 0.01 ; 100 ; 0.50 ; 137 ; 5 ; 104 ; 0.10 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
		}
	}
	else if (weapondifficulty==4) // Lunatic
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 104, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.20 ; 413 ; 1 ; 4 ; 17 ; 6 ; 0.18 ; 97 ; 0.01 ; 100 ; 0.10 ; 104 ; 0.52 ; 137 ; 5 ; 37 ; 0 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 104, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.22 ; 413 ; 1 ; 4 ; 19 ; 6 ; 0.16 ; 97 ; 0.01 ; 100 ; 0.15 ; 104 ; 0.49 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 104, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.18 ; 413 ; 1 ; 4 ; 20 ; 6 ; 0.14 ; 97 ; 0.01 ; 100 ; 0.30 ; 104 ; 0.46 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 104, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.21 ; 413 ; 1 ; 4 ; 22 ; 6 ; 0.12 ; 97 ; 0.01 ; 100 ; 0.45 ; 104 ; 0.43 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 104, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.24 ; 413 ; 1 ; 4 ; 25 ; 6 ; 0.10 ; 97 ; 0.01 ; 100 ; 0.60 ; 104 ; 0.40 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 104, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.19 ; 413 ; 1 ; 4 ; 26 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.25 ; 137 ; 5 ; 104 ; 0.60 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 104, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.27 ; 413 ; 1 ; 4 ; 23 ; 6 ; 0.05 ; 97 ; 0.01 ; 100 ; 0.25 ; 137 ; 5 ; 104 ; 0.55 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 104, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.25 ; 413 ; 1 ; 4 ; 27 ; 6 ; 0.15 ; 97 ; 0.01 ; 104 ; 0.22 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 104, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.23 ; 413 ; 1 ; 4 ; 32 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.40 ; 137 ; 5 ; 104 ; 0.20 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 104, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.20 ; 413 ; 1 ; 4 ; 23 ; 6 ; 0.20 ; 97 ; 0.01 ; 100 ; 0.50 ; 137 ; 5 ; 104 ; 0.20 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
		}
	}
	else if (weapondifficulty==5) // YOU MUST BE DREAMING TO EVEN TRY THIS!
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 105, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.40 ; 413 ; 1 ; 4 ; 29 ; 6 ; 0.18 ; 97 ; 0.01 ; 100 ; 0.10 ; 104 ; 0.74 ; 137 ; 5 ; 37 ; 0 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 105, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.44 ; 413 ; 1 ; 4 ; 31 ; 6 ; 0.16 ; 97 ; 0.01 ; 100 ; 0.15 ; 104 ; 0.78 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 105, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.36 ; 413 ; 1 ; 4 ; 22 ; 6 ; 0.14 ; 97 ; 0.01 ; 100 ; 0.30 ; 104 ; 0.72 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 105, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.42 ; 413 ; 1 ; 4 ; 24 ; 6 ; 0.12 ; 97 ; 0.01 ; 100 ; 0.45 ; 104 ; 0.66 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 105, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.48 ; 413 ; 1 ; 4 ; 27 ; 6 ; 0.10 ; 97 ; 0.01 ; 100 ; 0.60 ; 104 ; 0.60 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 105, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.38 ; 413 ; 1 ; 4 ; 28 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.50 ; 137 ; 5 ; 104 ; 0.80 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 105, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.54 ; 413 ; 1 ; 4 ; 25 ; 6 ; 0.05 ; 97 ; 0.01 ; 100 ; 0.50 ; 137 ; 5 ; 104 ; 0.80 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 105, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.50 ; 413 ; 1 ; 4 ; 29 ; 6 ; 0.15 ; 97 ; 0.01 ; 104 ; 0.72 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 105, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.46 ; 413 ; 1 ; 4 ; 34 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.70 ; 137 ; 5 ; 104 ; 0.20 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 105, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.40 ; 413 ; 1 ; 4 ; 25 ; 6 ; 0.20 ; 97 ; 0.01 ; 100 ; 0.90 ; 137 ; 5 ; 104 ; 0.20 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
		}
	}
	else if (weapondifficulty==6) // I THINK YOU LOST IT ALREADY!
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 106, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.60 ; 413 ; 1 ; 4 ; 27 ; 6 ; 0.18 ; 97 ; 0.01 ; 100 ; 0.10 ; 104 ; 0.94 ; 137 ; 5 ; 37 ; 0 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 106, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.64 ; 413 ; 1 ; 4 ; 29 ; 6 ; 0.16 ; 97 ; 0.01 ; 100 ; 0.15 ; 104 ; 0.98 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 106, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.56 ; 413 ; 1 ; 4 ; 30 ; 6 ; 0.14 ; 97 ; 0.01 ; 100 ; 0.30 ; 104 ; 0.92 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 106, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.62 ; 413 ; 1 ; 4 ; 32 ; 6 ; 0.12 ; 97 ; 0.01 ; 100 ; 0.45 ; 104 ; 0.86 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 106, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.68 ; 413 ; 1 ; 4 ; 35 ; 6 ; 0.10 ; 97 ; 0.01 ; 100 ; 0.60 ; 104 ; 0.80 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 106, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.58 ; 413 ; 1 ; 4 ; 36 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.50 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 106, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.74 ; 413 ; 1 ; 4 ; 33 ; 6 ; 0.05 ; 97 ; 0.01 ; 100 ; 0.50 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 106, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.70 ; 413 ; 1 ; 4 ; 37 ; 6 ; 0.15 ; 97 ; 0.01 ; 104 ; 0.92 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 106, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.66 ; 413 ; 1 ; 4 ; 42 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.70 ; 137 ; 5 ; 104 ; 0.50 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 106, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.60 ; 413 ; 1 ; 4 ; 33 ; 6 ; 0.20 ; 97 ; 0.01 ; 100 ; 0.90 ; 137 ; 5 ; 104 ; 0.50 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
		}
	}
	else if (weapondifficulty==7) // WAKE UP!!!! PLEASE WAKE UP!!!
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 107, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.80 ; 413 ; 1 ; 4 ; 39 ; 6 ; 0.18 ; 97 ; 0.01 ; 100 ; 0.10 ; 103 ; 1.14 ; 137 ; 5 ; 37 ; 0 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 107, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.84 ; 413 ; 1 ; 4 ; 41 ; 6 ; 0.16 ; 97 ; 0.01 ; 100 ; 0.15 ; 103 ; 1.18 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 107, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.76 ; 413 ; 1 ; 4 ; 32 ; 6 ; 0.14 ; 97 ; 0.01 ; 100 ; 0.30 ; 103 ; 1.12 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 107, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.82 ; 413 ; 1 ; 4 ; 42 ; 6 ; 0.12 ; 97 ; 0.01 ; 100 ; 0.45 ; 103 ; 1.06 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 107, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.88 ; 413 ; 1 ; 4 ; 47 ; 6 ; 0.10 ; 97 ; 0.01 ; 100 ; 0.60 ; 103 ; 1.05 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 107, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.78 ; 413 ; 1 ; 4 ; 48 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.50 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 107, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.94 ; 413 ; 1 ; 4 ; 13 ; 6 ; 0.05 ; 97 ; 0.01 ; 100 ; 0.50 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 107, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.90 ; 413 ; 1 ; 4 ; 49 ; 6 ; 0.15 ; 97 ; 0.01 ; 103 ; 1.22 ; 137 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 107, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.86 ; 413 ; 1 ; 4 ; 44 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.70 ; 137 ; 5 ; 104 ; 0.80 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 107, 5, "275 ; 1  ; 1 ; 0.80 ; 413 ; 1 ; 4 ; 45 ; 6 ; 0.20 ; 97 ; 0.01 ; 100 ; 0.90 ; 137 ; 5 ; 104 ; 0.80 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
		}
	}
	else if (weapondifficulty==8) // ARE YOU SERIOUS?
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 108, 5, "208 ; 1 ; 275 ; 1  ; 2 ; 0.60 ; 413 ; 1 ; 4 ; 40 ; 6 ; 0.20 ; 97 ; 0.01 ; 100 ; 0.15 ; 137 ; 20 ; 411 ; 15 ; 37 ; 0 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 108, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.75 ; 413 ; 1 ; 4 ; 45 ; 6 ; 0.17 ; 97 ; 0.01 ; 100 ; 0.30 ; 103 ; 1.35 ; 137 ; 20 ; 411 ; 13 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 108, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.70 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.14 ; 97 ; 0.01 ; 100 ; 0.45 ; 103 ; 1.30 ; 137 ; 20 ; 411 ; 11 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 108, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.75 ; 413 ; 1 ; 4 ; 55 ; 6 ; 0.11 ; 97 ; 0.01 ; 100 ; 0.60 ; 103 ; 1.20 ; 137 ; 20 ; 411 ; 8 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 108, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.80 ; 413 ; 1 ; 4 ; 60 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.75 ; 103 ; 1.05 ; 137 ; 20 ; 411 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 108, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.85 ; 413 ; 1 ; 4 ; 48 ; 6 ; 0.06 ; 97 ; 0.01 ; 103 ; 1.20 ; 100 ; 0.10 ; 137 ; 20 ; 411 ; 25 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 108, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.85 ; 413 ; 1 ; 4 ; 40 ; 6 ; 0.05 ; 97 ; 0.01  ; 103 ; 1.05 ; 137 ; 20 ; 411 ; 20 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 108, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.85 ; 413 ; 1 ; 4 ; 42 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.70 ; 103 ; 1.25 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 108, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.80 ; 413 ; 1 ; 4 ; 55 ; 6 ; 0.03 ; 97 ; 0.01 ; 100 ; 0.20 ; 103 ; 1.24 ; 137 ; 20 ; 411 ; 35 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 108, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.90 ; 413 ; 1 ; 4 ; 47 ; 6 ; 0.13 ; 97 ; 0.01 ; 100 ; 0.50 ; 103 ; 1.10 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
		}
	}
	PrintToServer("RandomDanmaku(client)");
}

// Blitzkrieg's much more powerful weapons whenever he loses a life. This is his weapon config
BlitzkriegBarrage(client)
{
	if (weapondifficulty==0) // Easy
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 100, 5, "275 ; 1  ; 1 ; 0.05 ; 413 ; 1 ; 4 ; 5 ; 6 ; 0.20 ; 97 ; 0.01 ; 100 ; 0.15 ; 104 ; 0.40 ; 137 ; 20 ; 411 ; 15 ; 37 ; 0 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 100, 5, "275 ; 1  ; 1 ; 0.10 ; 413 ; 1 ; 4 ; 10 ; 6 ; 0.17 ; 97 ; 0.01 ; 100 ; 0.30 ; 104 ; 0.35 ; 137 ; 20 ; 411 ; 13 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 100, 5, "275 ; 1  ; 1 ; 0.15 ; 413 ; 1 ; 4 ; 15 ; 6 ; 0.14 ; 97 ; 0.01 ; 100 ; 0.45 ; 104 ; 0.30 ; 137 ; 20 ; 411 ; 11 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 100, 5, "275 ; 1  ; 1 ; 0.07 ; 413 ; 1 ; 4 ; 20 ; 6 ; 0.11 ; 97 ; 0.01 ; 100 ; 0.60 ; 104 ; 0.25 ; 137 ; 20 ; 411 ; 8 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 100, 5, "275 ; 1  ; 1 ; 0.12 ; 413 ; 1 ; 4 ; 25 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.75 ; 104 ; 0.20 ; 137 ; 20 ; 411 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 100, 5, "275 ; 1  ; 1 ; 0.07 ; 413 ; 1 ; 4 ; 23 ; 6 ; 0.06 ; 97 ; 0.01 ; 100 ; 0.10 ; 104 ; 0.50 ; 137 ; 20 ; 411 ; 25 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 100, 5, "275 ; 1  ; 1 ; 0.13 ; 413 ; 1 ; 4 ; 15 ; 6 ; 0.05 ; 97 ; 0.01  ; 104 ; 0.35 ; 137 ; 20 ; 411 ; 20 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 100, 5, "275 ; 1  ; 1 ; 0.15 ; 413 ; 1 ; 4 ; 17 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.70 ; 104 ; 0.45 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 100, 5, "275 ; 1  ; 1 ; 0.10 ; 413 ; 1 ; 4 ; 25 ; 6 ; 0.03 ; 97 ; 0.01 ; 100 ; 0.20 ; 137 ; 20 ; 104 ; 0.50 ; 411 ; 35 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 100, 5, "275 ; 1  ; 1 ; 0.17 ; 413 ; 1 ; 4 ; 23 ; 6 ; 0.13 ; 97 ; 0.01 ; 100 ; 0.50 ; 104 ; 0.40 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
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
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 103, 5, "275 ; 1  ; 1 ; 0.20 ; 413 ; 1 ; 4 ; 25 ; 6 ; 0.18 ; 97 ; 0.01 ; 100 ; 0.15 ; 137 ; 20 ; 411 ; 15 ; 37 ; 0 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 103, 5, "275 ; 1  ; 1 ; 0.25 ; 413 ; 1 ; 4 ; 30 ; 6 ; 0.15 ; 97 ; 0.01 ; 100 ; 0.30 ; 104 ; 0.85 ; 137 ; 20 ; 411 ; 13 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 103, 5, "275 ; 1  ; 1 ; 0.30 ; 413 ; 1 ; 4 ; 35 ; 6 ; 0.12 ; 97 ; 0.01 ; 100 ; 0.45 ; 104 ; 0.70 ; 137 ; 20 ; 411 ; 11 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 103, 5, "275 ; 1  ; 1 ; 0.35 ; 413 ; 1 ; 4 ; 40 ; 6 ; 0.10 ; 97 ; 0.01 ; 100 ; 0.60 ; 104 ; 0.50 ; 137 ; 20 ; 411 ; 8 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 103, 5, "275 ; 1  ; 1 ; 0.40 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.75 ; 104 ; 0.35 ; 137 ; 20 ; 411 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 103, 5, "275 ; 1  ; 1 ; 0.25 ; 413 ; 1 ; 4 ; 48 ; 6 ; 0.06 ; 97 ; 0.01 ; 100 ; 0.10 ; 137 ; 20 ; 411 ; 25 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 103, 5, "275 ; 1  ; 1 ; 0.30 ; 413 ; 1 ; 4 ; 40 ; 6 ; 0.05 ; 97 ; 0.01  ; 104 ; 0.55 ; 137 ; 20 ; 411 ; 20 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 103, 5, "275 ; 1  ; 1 ; 0.35 ; 413 ; 1 ; 4 ; 42 ; 6 ; 0.05 ; 97 ; 0.01 ; 100 ; 0.70 ; 104 ; 0.95 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 103, 5, "275 ; 1  ; 1 ; 0.30 ; 413 ; 1 ; 4 ; 55 ; 6 ; 0.03 ; 97 ; 0.01 ; 100 ; 0.20 ; 137 ; 20 ; 411 ; 35 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2003 ; 2014 ; 3"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 103, 5, "275 ; 1  ; 1 ; 0.40 ; 413 ; 1 ; 4 ; 47 ; 6 ; 0.07 ; 97 ; 0.01 ; 100 ; 0.50 ; 104 ; 0.60 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2003 ; 2014 ; 3"));
		}
	}
	else if (weapondifficulty==4) // Lunatic
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 104, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.30 ; 413 ; 1 ; 4 ; 30 ; 6 ; 0.10 ; 97 ; 0.01 ; 100 ; 0.15 ; 137 ; 20 ; 411 ; 15 ; 37 ; 0 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 104, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.35 ; 413 ; 1 ; 4 ; 35 ; 6 ; 0.07 ; 97 ; 0.01 ; 100 ; 0.30 ; 103 ; 1.15 ; 137 ; 20 ; 411 ; 13 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 104, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.40 ; 413 ; 1 ; 4 ; 40 ; 6 ; 0.04 ; 97 ; 0.01 ; 100 ; 0.45 ; 137 ; 20 ; 411 ; 11 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 104, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.45 ; 413 ; 1 ; 4 ; 45 ; 6 ; 0.01 ; 97 ; 0.01 ; 100 ; 0.60 ; 104 ; 0.80 ; 137 ; 20 ; 411 ; 8 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 104, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.50 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.75 ; 104 ; 0.65 ; 137 ; 20 ; 411 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 104, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.45 ; 413 ; 1 ; 4 ; 58 ; 6 ; 0.06 ; 97 ; 0.01 ; 100 ; 0.10 ; 137 ; 20 ; 411 ; 25 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 104, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.45 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.05 ; 97 ; 0.01  ; 104 ; 0.65 ; 137 ; 20 ; 411 ; 20 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 104, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.55 ; 413 ; 1 ; 4 ; 52 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.70 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 104, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.50 ; 413 ; 1 ; 4 ; 65 ; 6 ; 0.03 ; 97 ; 0.01 ; 100 ; 0.20 ; 137 ; 20 ; 411 ; 35 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 104, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.60 ; 413 ; 1 ; 4 ; 57 ; 6 ; 0.03 ; 97 ; 0.01 ; 100 ; 0.50 ; 104 ; 0.70 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
		}
	}
	else if (weapondifficulty==5) // YOU MUST BE DREAMING TO EVEN TRY THIS!
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 105, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.40 ; 413 ; 1 ; 4 ; 35 ; 6 ; 0.06 ; 97 ; 0.01 ; 100 ; 0.15 ; 137 ; 20 ; 411 ; 15 ; 37 ; 0 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 3"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 105, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.55 ; 413 ; 1 ; 4 ; 40 ; 6 ; 0.06 ; 97 ; 0.01 ; 100 ; 0.30 ; 103 ; 1.25 ; 137 ; 20 ; 411 ; 13 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 105, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.50 ; 413 ; 1 ; 4 ; 45 ; 6 ; 0.06 ; 97 ; 0.01 ; 100 ; 0.45 ; 103 ; 1.10 ; 137 ; 20 ; 411 ; 11 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 105, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.55 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.06 ; 97 ; 0.01 ; 100 ; 0.60 ; 103 ; 1.10 ; 137 ; 20 ; 411 ; 8 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 105, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.60 ; 413 ; 1 ; 4 ; 55 ; 6 ; 0.06 ; 97 ; 0.01 ; 100 ; 0.75 ; 104 ; 0.85 ; 137 ; 20 ; 411 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 105, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.55 ; 413 ; 1 ; 4 ; 68 ; 6 ; 0.06 ; 97 ; 0.01 ; 103 ; 1.10 ; 100 ; 0.10 ; 137 ; 20 ; 411 ; 25 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 105, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.55 ; 413 ; 1 ; 4 ; 60 ; 6 ; 0.06 ; 97 ; 0.01  ; 104 ; 0.85 ; 137 ; 20 ; 411 ; 20 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 105, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.65 ; 413 ; 1 ; 4 ; 62 ; 6 ; 0.06 ; 97 ; 0.01 ; 100 ; 0.70 ; 103 ; 1.15 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 105, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.60 ; 413 ; 1 ; 4 ; 65 ; 6 ; 0.06 ; 97 ; 0.01 ; 100 ; 0.20 ; 103 ; 1.14 ; 137 ; 20 ; 411 ; 35 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 105, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.70 ; 413 ; 1 ; 4 ; 67 ; 6 ; 0.06 ; 97 ; 0.01 ; 100 ; 0.50 ; 104 ; 0.90 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
		}
	}
	else if (weapondifficulty==6) // I THINK YOU LOST IT ALREADY!
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 106, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.60 ; 413 ; 1 ; 4 ; 40 ; 6 ; 0.01 ; 97 ; 0.01 ; 100 ; 0.15 ; 137 ; 20 ; 411 ; 15 ; 37 ; 0 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 106, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.75 ; 413 ; 1 ; 4 ; 45 ; 6 ; 0.07 ; 97 ; 0.01 ; 100 ; 0.30 ; 103 ; 1.35 ; 137 ; 20 ; 411 ; 13 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 106, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.70 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.04 ; 97 ; 0.01 ; 100 ; 0.45 ; 103 ; 1.30 ; 137 ; 20 ; 411 ; 11 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 106, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.75 ; 413 ; 1 ; 4 ; 55 ; 6 ; 0.04 ; 97 ; 0.01 ; 100 ; 0.60 ; 103 ; 1.20 ; 137 ; 20 ; 411 ; 8 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 106, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.80 ; 413 ; 1 ; 4 ; 60 ; 6 ; 0.04 ; 97 ; 0.01 ; 100 ; 0.75 ; 103 ; 1.05 ; 137 ; 20 ; 411 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 106, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.85 ; 413 ; 1 ; 4 ; 78 ; 6 ; 0.04 ; 97 ; 0.01 ; 103 ; 1.20 ; 100 ; 0.10 ; 137 ; 20 ; 411 ; 25 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 106, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.85 ; 413 ; 1 ; 4 ; 70 ; 6 ; 0.04 ; 97 ; 0.01  ; 103 ; 1.05 ; 137 ; 20 ; 411 ; 20 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 106, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.85 ; 413 ; 1 ; 4 ; 72 ; 6 ; 0.04 ; 97 ; 0.01 ; 100 ; 0.70 ; 103 ; 1.25 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 106, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.80 ; 413 ; 1 ; 4 ; 75 ; 6 ; 0.04 ; 97 ; 0.01 ; 100 ; 0.20 ; 103 ; 1.24 ; 137 ; 20 ; 411 ; 35 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 106, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.90 ; 413 ; 1 ; 4 ; 77 ; 6 ; 0.04 ; 97 ; 0.01 ; 100 ; 0.50 ; 103 ; 1.10 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
		}
	}
	else if (weapondifficulty==7) // WAKE UP!!!! PLEASE WAKE UP!!!
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 107, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.90 ; 413 ; 1 ; 4 ; 45 ; 6 ; 0.02 ; 97 ; 0.01 ; 100 ; 0.15 ; 137 ; 20 ; 411 ; 15 ; 37 ; 0 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 107, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.95 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.02 ; 97 ; 0.01 ; 100 ; 0.30 ; 103 ; 1.65 ; 137 ; 20 ; 411 ; 13 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 107, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.90 ; 413 ; 1 ; 4 ; 55 ; 6 ; 0.02 ; 97 ; 0.01 ; 100 ; 0.45 ; 103 ; 1.60 ; 137 ; 20 ; 411 ; 11 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 107, 5, "208 ; 1 ; 275 ; 1  ; 1 ; 0.95 ; 413 ; 1 ; 4 ; 60 ; 6 ; 0.02 ; 97 ; 0.01 ; 100 ; 0.60 ; 103 ; 1.50 ; 137 ; 20 ; 411 ; 8 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 107, 5, "208 ; 1 ; 275 ; 1  ; 2 ; 1.10 ; 413 ; 1 ; 4 ; 65 ; 6 ; 0.02 ; 97 ; 0.01 ; 100 ; 0.75 ; 103 ; 1.40 ; 137 ; 20 ; 411 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 107, 5, "208 ; 1 ; 275 ; 1  ; 2 ; 1.15 ; 413 ; 1 ; 4 ; 88 ; 6 ; 0.02 ; 97 ; 0.01 ; 103 ; 1.50 ; 100 ; 0.10 ; 137 ; 20 ; 411 ; 25 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 107, 5, "208 ; 1 ; 275 ; 1  ; 2 ; 1.25 ; 413 ; 1 ; 4 ; 80 ; 6 ; 0.02 ; 97 ; 0.01  ; 103 ; 1.60 ; 137 ; 20 ; 411 ; 20 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 107, 5, "208 ; 1 ; 275 ; 1  ; 2 ; 1.05 ; 413 ; 1 ; 4 ; 82 ; 6 ; 0.02 ; 97 ; 0.01 ; 100 ; 0.70 ; 103 ; 1.50 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 107, 5, "208 ; 1 ; 275 ; 1  ; 2 ; 1.20 ; 413 ; 1 ; 4 ; 85 ; 6 ; 0.02 ; 97 ; 0.01 ; 100 ; 0.20 ; 103 ; 1.48 ; 137 ; 20 ; 411 ; 35 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2002; 2014 ; 4"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 107, 5, "208 ; 1 ; 275 ; 1  ; 2 ; 1.30 ; 413 ; 1 ; 4 ; 87 ; 6 ; 0.02 ; 97 ; 0.01 ; 100 ; 0.50 ; 103 ; 1.70 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
		}
	}
	else if (weapondifficulty==8) // ARE YOU SERIOUS? 
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 108, 5, "208 ; 1 ; 275 ; 1  ; 2 ; 1.90 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.00 ; 97 ; 0.00 ; 100 ; 0.15 ; 137 ; 20 ; 411 ; 15 ; 37 ; 0 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 108, 5, "208 ; 1 ; 275 ; 1  ; 2 ; 1.95 ; 413 ; 1 ; 4 ; 55 ; 6 ; 0.00 ; 97 ; 0.00 ; 100 ; 0.30 ; 103 ; 2.65 ; 137 ; 20 ; 411 ; 13 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 108, 5, "208 ; 1 ; 275 ; 1  ; 2 ; 1.90 ; 413 ; 1 ; 4 ; 60 ; 6 ; 0.00 ; 97 ; 0.00 ; 100 ; 0.45 ; 103 ; 2.60 ; 137 ; 20 ; 411 ; 11 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 108, 5, "208 ; 1 ; 275 ; 1  ; 2 ; 1.95 ; 413 ; 1 ; 4 ; 65 ; 6 ; 0.00 ; 97 ; 0.00 ; 100 ; 0.60 ; 103 ; 2.50 ; 137 ; 20 ; 411 ; 8 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 108, 5, "208 ; 1 ; 275 ; 1  ; 2 ; 2.10 ; 413 ; 1 ; 4 ; 70 ; 6 ; 0.00 ; 97 ; 0.00 ; 100 ; 0.75 ; 103 ; 2.40 ; 137 ; 20 ; 411 ; 5 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 108, 5, "208 ; 1 ; 275 ; 1  ; 2 ; 2.15 ; 413 ; 1 ; 4 ; 98 ; 6 ; 0.00 ; 97 ; 0.00 ; 103 ; 2.50 ; 100 ; 0.10 ; 137 ; 20 ; 411 ; 25 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 108, 5, "208 ; 1 ; 275 ; 1  ; 2 ; 2.25 ; 413 ; 1 ; 4 ; 90 ; 6 ; 0.00 ; 97 ; 0.00  ; 103 ; 2.60 ; 137 ; 20 ; 411 ; 20 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 108, 5, "208 ; 1 ; 275 ; 1  ; 2 ; 2.05 ; 413 ; 1 ; 4 ; 92 ; 6 ; 0.00 ; 97 ; 0.00 ; 100 ; 0.70 ; 103 ; 2.50 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 108, 5, "208 ; 1 ; 275 ; 1  ; 2 ; 2.20 ; 413 ; 1 ; 4 ; 95 ; 6 ; 0.00 ; 97 ; 0.00 ; 100 ; 0.20 ; 103 ; 2.48 ; 137 ; 20 ; 411 ; 35 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 108, 5, "208 ; 1 ; 275 ; 1  ; 2 ; 2.30 ; 413 ; 1 ; 4 ; 97 ; 6 ; 0.00 ; 97 ; 0.00 ; 100 ; 0.50 ; 103 ; 2.70 ; 137 ; 20 ; 411 ; 30 ; 37 ; 0 ;  2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
		}
	}
	PrintToServer("BlitzkriegBarrage(client)");
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
				weapondifficulty=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 1, 1);
				combatstyle=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 2);
				customweapons=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 3); // use custom weapons
				voicelines=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 4); // Voice Lines
				miniblitzkriegrage=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 5); // RAGE/Weaponswitch Ammo
				blitzkriegrage=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 6); // Blitzkrieg Rampage Ammo
				blitzgrav=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 7); // Blitzkrieg Rampage Ammo
				if(combatstyle!=0)
				{	
					TF2_RemoveWeaponSlot(danmakuboss, TFWeaponSlot_Melee);
					PrintHintText(danmakuboss, "Mode is Pure Danmaku, meaning you must rely on your rocket launcher's Danmaku to defeat the other team");
					TF2_RemoveWeaponSlot(danmakuboss, TFWeaponSlot_Primary);
					RandomDanmaku(danmakuboss);
					SetAmmo(danmakuboss, TFWeaponSlot_Primary,999999);
				}
				else if(combatstyle==0)
				{
					PrintHintText(danmakuboss, "Mode is Mixed Combat. Your Ubersaw can Backstab");
					TF2_RemoveWeaponSlot(danmakuboss, TFWeaponSlot_Primary);
					RandomDanmaku(danmakuboss);
					SetAmmo(danmakuboss, TFWeaponSlot_Primary, miniblitzkriegrage);
				}
				if(customweapons == 0)
				{
					PrintToServer("Custom weapons are disabled. Set arg3 to 1 to enable them");
				}
			}
			else
				CreateTimer(2.5, StopAll);
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
					if(crockethell!=INVALID_HANDLE)
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
			DropReanimator(client);
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
	CreateTimer(2.0, StopAll);
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
	return Plugin_Stop;
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
	PrintToServer("ItzBlitzkriegTime(Handle:hTimer,any:index)");
	crockethell = INVALID_HANDLE;
}

public Action:ScrewThisGravity(Handle:hTimer,any:index)
{
	new Boss=GetClientOfUserId(FF2_GetBossUserId(index));
	SetEntityGravity(Boss, 1.0);
	PrintToServer("ScrewThisGravity(Handle:hTimer,any:index)");
	screwgravity = INVALID_HANDLE;
	
}

public Action:Rage_Timer_UnuseCharge(Handle:hTimer,any:index)
{
	new Boss=GetClientOfUserId(FF2_GetBossUserId(index));
	PrintToServer("Rage_Timer_UnuseCharge(Handle:hTimer,any:index)");
	SetEntProp(Boss, Prop_Data, "m_takedamage", 2);
	return Plugin_Continue;
}

// TF2items

public Action:TF2Items_OnGiveNamedItem(client, String:classname[], iItemDefinitionIndex, &Handle:item)
{
	switch(iItemDefinitionIndex)
	{
		case 25, 737:  //Build PDA
		{
			new Handle:itemOverride=PrepareItemHandle(item, _, _, "276 ; 1 ; 345 ; 2.5");
				// 276: Bidirectional Teleporters
				// 345: Dispenser Radius Increased
			if(itemOverride!=INVALID_HANDLE)
			{
				item=itemOverride;
				return Plugin_Changed;
			}
		}
		case 211, 663, 796, 805, 885, 894, 903, 912, 961, 970:  //Renamed/Strange, Festive, Silver Botkiller, Gold Botkiller, Rusty Botkiller, Bloody Botkiller, Carbonado Botkiller, Diamond Botkiller Mk.II, Silver Botkiller Mk.II, and Gold Botkiller Mk.II Mediguns
		{
			new Handle:itemOverride=PrepareItemHandle(item, _, _, "499 ; 50.0 ; 10 ; 1.25 ; 178 ; 0.75 ; 144 ; 2.0 ; 11 ; 2.0");
				//499: Projectile Shield
				//10: +25% faster charge rate
				//178: +25% faster weapon switch
				//144: Quick-fix speed/jump effects
				//11: +50% overheal bonus
			if(itemOverride!=INVALID_HANDLE)
			{
				item=itemOverride;
				return Plugin_Changed;
			}
		}
		case 129, 226, 354, 1001:  //Battalion's Backup, Buff Banner, Concheror, Festive Buff Banner
		{
			new Handle:itemOverride=PrepareItemHandle(item, _, _, "140 ; 10.0 ; 319 ; 2.5");
				// 319: 150% longer duration
			if(itemOverride!=INVALID_HANDLE)
			{
				item=itemOverride;
				return Plugin_Changed;
			}
		}
		case 44, 648, 812, 833:  //Sandman, Wrap Assassin, Flying Guillotine
		{
			new Handle:itemOverride=PrepareItemHandle(item, _, _, "279 ; 10.0");
				// 279: 9 more misc ammo.
			if(itemOverride!=INVALID_HANDLE)
			{
				item=itemOverride;
				return Plugin_Changed;
			}
		}
		case 18, 205, 414, 513, 658, 800, 809, 889, 898, 907, 916, 965, 974:  //All Soldier Rocket Launchers except Black Box, Beggar's Bazooka, Cow Mangler, Festive Black Box & Air Strike
		{
			new Handle:itemOverride=PrepareItemHandle(item, _, _, "1 ; 0.70 ; 4 ; 2.5 ; 6 ; 0.25 ; 15 ; 1 ; 58 ; 5 ; 65 ; 1.20 ; 76 ; 2 ; 181 ; 1 ; 232 ; 20 ; 275 ; 1 ; 421 ; 1");
			if(itemOverride!=INVALID_HANDLE)
			{
				// 1: -30% Damage Penalty
				// 4: +150% Clip Size
				// 6: +75% faster firing speed
				// 15: No Random Critical Hits
				// 58: +400% Self Damage Push Force
				// 65: +20% explosive damage vulnerability on wearer
				// 76: +100% Max primary ammo on wearer
				// 181: No self inflicted blast damage taken
				// 232: When the medic healing you is killed, you gain mini-crit boost for 20 seconds
				// 275: Wearer never takes fall damage
				// 421: No primary ammo from dispensers
				item=itemOverride;
				return Plugin_Changed;
			}
		}
		case 228, 1085: //Black Box, Festive Black Box
		{
			new Handle:itemOverride=PrepareItemHandle(item, _, _, "4 ; 1.5 ; 6 ; 0.25 ; 15 ; 1 ; 26 ; 100 ; 58 ; 5 ; 65 ; 2.25 ; 76 ; 2 ; 100 ; 0.5 ; 181 ; 1 ; 233 ; 1.50 ; 234 ; 1.25 ; ");
			if(itemOverride!=INVALID_HANDLE)
				// +50% Clip Size
				// +75% faster firing speed
				// 15: No Random Critical Hits
				// 26: +100 Max Health
				// 58: +400% Self Damage Push Force
				// 65: +125% explosive damage vulnerability on wearer
				// 76: +100% Max primary ammo on wearer
				// 100: -50% Blast Radius
				// 181: No self inflicted blast damage taken
				// 233: While a medic is healing you, this weapon's damage is increased by 50%
				// 234: While not being healed by a medic, your weapon switch time is 25% longer
			{
				item=itemOverride;
				return Plugin_Changed;
			}
		}
		case 441: //Cow Mangler
		{
			new Handle:itemOverride=PrepareItemHandle(item, _, _, "58 ; 5 ; 181 ; 1 ; 288 ; 0 ; 366 ; 5");
			if(itemOverride!=INVALID_HANDLE)
				// 58: +400% Self Damage Push Force
				// 181: No self inflicted blast damage taken
				// 288: Repealing "cannot be crit boosted"
				// 266: On Hit: If enemy's belt is at or above eye level, stun them for 5 seconds
			{
				item=itemOverride;
				return Plugin_Changed;
			}
		}
		case 730: //Beggar's Bazooka
		{
			new Handle:itemOverride=PrepareItemHandle(item, _, _, "2 ; 1.1 ; 4 ; 10 ; 6 ; 0.15 ; 76 ; 10 ; 97 ; 0.50 ; 411 ; 30 ; 421 ; 0");
			if(itemOverride!=INVALID_HANDLE)
				// 2: 10% Damage Bonus
				// 4: +1000 Clip Size
				// 6: 85% Faster Firing Speed
				// 76: +1000% Max primary ammo on wearer
				// 597: 50% Faster reload speed
				// 411: 30 degrees random projectile deviation
				// 421: Repealing "no ammo from dispensers"
			{
				item=itemOverride;
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue;
}

stock Handle:PrepareItemHandle(Handle:item, String:name[]="", index=-1, const String:att[]="", bool:dontPreserve=false)
{
	static Handle:weapon;
	new addattribs;

	new String:weaponAttribsArray[32][32];
	new attribCount=ExplodeString(att, ";", weaponAttribsArray, 32, 32);

	if(attribCount % 2)
	{
		--attribCount;
	}

	new flags=OVERRIDE_ATTRIBUTES;
	if(!dontPreserve)
	{
		flags|=PRESERVE_ATTRIBUTES;
	}

	if(weapon==INVALID_HANDLE)
	{
		weapon=TF2Items_CreateItem(flags);
	}
	else
	{
		TF2Items_SetFlags(weapon, flags);
	}
	//new Handle:weapon=TF2Items_CreateItem(flags);  //INVALID_HANDLE;  Going to uncomment this since this is what Randomizer does

	if(item!=INVALID_HANDLE)
	{
		addattribs=TF2Items_GetNumAttributes(item);
		if(addattribs>0)
		{
			for(new i; i<2*addattribs; i+=2)
			{
				new bool:dontAdd=false;
				new attribIndex=TF2Items_GetAttributeId(item, i);
				for(new z; z<attribCount+i; z+=2)
				{
					if(StringToInt(weaponAttribsArray[z])==attribIndex)
					{
						dontAdd=true;
						break;
					}
				}

				if(!dontAdd)
				{
					IntToString(attribIndex, weaponAttribsArray[i+attribCount], 32);
					FloatToString(TF2Items_GetAttributeValue(item, i), weaponAttribsArray[i+1+attribCount], 32);
				}
			}
			attribCount+=2*addattribs;
		}

		if(weapon!=item)  //FlaminSarge: Item might be equal to weapon, so closing item's handle would also close weapon's
		{
			CloseHandle(item);  //probably returns false but whatever (rswallen-apparently not)
		}
	}

	if(name[0]!='\0')
	{
		flags|=OVERRIDE_CLASSNAME;
		TF2Items_SetClassname(weapon, name);
	}

	if(index!=-1)
	{
		flags|=OVERRIDE_ITEM_DEF;
		TF2Items_SetItemIndex(weapon, index);
	}

	if(attribCount>0)
	{
		TF2Items_SetNumAttributes(weapon, attribCount/2);
		new i2;
		for(new i; i<attribCount && i2<16; i+=2)
		{
			new attrib=StringToInt(weaponAttribsArray[i]);
			if(!attrib)
			{
				LogError("Bad weapon attribute passed: %s ; %s", weaponAttribsArray[i], weaponAttribsArray[i+1]);
				CloseHandle(weapon);
				return INVALID_HANDLE;
			}

			TF2Items_SetAttribute(weapon, i2, StringToInt(weaponAttribsArray[i]), StringToFloat(weaponAttribsArray[i+1]));
			i2++;
		}
	}
	else
	{
		TF2Items_SetNumAttributes(weapon, 0);
	}
	TF2Items_SetFlags(weapon, flags);
	return weapon;
}