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
new Handle: decayTimers[MAXPLAYERS+1] = { INVALID_HANDLE, ... };
//Other Stuff
new bool:ChangeClass[MAXPLAYERS+1] = { false, ... };
new reviveCount[MAXPLAYERS+1] = { 0, ... };
new currentTeam[MAXPLAYERS+1] = {0, ... };
new respawnMarkers[MAXPLAYERS+1] = { INVALID_ENT_REFERENCE, ... };
new customweapons;
new combatstyle;
new weapondifficulty;
new voicelines;
new danmakuboss;
new blitzkriegrage;
new miniblitzkriegrage;
new allowrevive;
new decaytime;
new BossTeam=_:TFTeam_Blue;
//new OtherTeam=_:TFTeam_Red;

#define PLUGIN_VERSION "1.78"
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
	HookEvent("player_spawn", OnPlayerSpawn);
	HookEvent("player_changeclass", OnChangeClass);
	PrintToServer("************************************************************************");
	PrintToServer("--------------------FREAK FORTRESS 2: THE BLITZKRIEG--------------------");
	PrintToServer("-------------BETA 1.78 EXPERIMENTAL - BY SHADoW NiNE TR3S---------------");
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
			CreateTimer(FF2_GetAbilityArgumentFloat(index,this_plugin_name,ability_name,1,5.0),RemoveUber,index);
			TF2_AddCondition(Boss,TFCond_Kritzkrieged,FF2_GetAbilityArgumentFloat(index,this_plugin_name,ability_name,2,5.0)); // Kritzkrieg
			SetEntProp(Boss, Prop_Data, "m_takedamage", 0);
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
			// Removing unwanted weapons
			TF2_RemoveAllWeapons(Boss);
			// ONLY FOR LEGACY REASONS, FF2 1.10.3 and newer doesn't actually need this to restore the boss model.
			SetVariantString("models/freak_fortress_2/shadow93/dmedic/dmedic.mdl");
			AcceptEntityInput(Boss, "SetCustomModel");
			SetEntProp(Boss, Prop_Send, "m_bUseClassAnimations", 1);
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
			BlitzkriegBarrage(Boss);
			SpawnWeapon(Boss, "tf_weapon_parachute", 1101, 109, 5, "640 ; 1 ; 68 ; 12 ; 269 ; 1 ; 275 ; 1");
			if(combatstyle!=0)
			{
				crockethell = CreateTimer(FF2_GetAbilityArgumentFloat(index,this_plugin_name,ability_name,3),ItzBlitzkriegTime,index);
				SetAmmo(Boss, TFWeaponSlot_Primary,999999);
			}
			else
			{
				SpawnWeapon(Boss, "tf_weapon_knife", 1003, 109, 5, "2 ; 3 ; 138 ; 0.5 ; 39 ; 0.3 ; 68 ; 12 ; 391 ; 1.9 ; 401 ; 1.9 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6");
				SetAmmo(Boss, TFWeaponSlot_Primary,blitzkriegrage);
			}
			// If Gravity timer active, to extend timer
			if(screwgravity!=INVALID_HANDLE)
			{
				KillTimer(screwgravity);
				screwgravity=INVALID_HANDLE;
			}
			screwgravity = CreateTimer(FF2_GetAbilityArgumentFloat(index,this_plugin_name,ability_name,3),ScrewThisGravity,index);	
			SetEntityGravity(Boss, 0.05);
			//For the Class Reaction Voice Lines
			if (voicelines!=0)
			{
				decl i;
				for( i = 1; i <= MaxClients; i++ )
				{
					ClassResponses(i);
				}
			}
			else
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
			if(crockethell!=INVALID_HANDLE)
			{
				BlitzkriegBarrage(Boss);
				SetAmmo(Boss, TFWeaponSlot_Primary,blitzkriegrage);
				PrintToServer("*blitzkrieg*");
			}
			else
			{
				RandomDanmaku(Boss);
				if(combatstyle!=0)
				{
					SetAmmo(Boss, TFWeaponSlot_Primary,999999);
				}
				else
				{
					SetAmmo(Boss, TFWeaponSlot_Primary,miniblitzkriegrage);
				}
				PrintToServer("*mini blitzkrieg*");
			}
			// If Gravity timer active, to extend timer
			if(screwgravity!=INVALID_HANDLE)
			{
				KillTimer(screwgravity);
				screwgravity=INVALID_HANDLE;
			}
			screwgravity = CreateTimer(FF2_GetAbilityArgumentFloat(index,this_plugin_name,ability_name,3),ScrewThisGravity,index);	
			SetEntityGravity(Boss, 0.05);
			if (voicelines!=0)
			{
				decl i;
				for( i = 1; i <= MaxClients; i++ )
				{
					ClassResponses(i);
				}
			}
			else
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

public Action:OnPlayerSpawn(Handle:event, const String:name[], bool:dontbroadcast) 
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	RemoveReanimator(client);
}

public Action:OnChangeClass(Handle:event, const String:name[], bool:dontbroadcast) 
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	ChangeClass[client] = true;
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


// ESSENTIAL CODE ENDS

// This is the weapon configs for Blitzkrieg's starter weapons & switch upon rage or after Blitzkrieg ability wears off
RandomDanmaku(client)
{
	if (weapondifficulty==1) // Easy
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 100, 5, "2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1 ; 413 ; 1 ; 1 ; 0.05 ; 4 ; 3.5 ; 6 ; 0.18 ; 97 ; 0.01 ; 100 ; 0.10 ; 104 ; 0.40"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 100, 5, "2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1 ; 413 ; 1 ; 1 ; 0.06 ; 4 ; 4.5 ; 6 ; 0.16 ; 97 ; 0.01 ; 100 ; 0.15 ; 104 ; 0.35"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 100, 5, "2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1 ; 413 ; 1 ; 1 ; 0.04 ; 4 ; 5 ; 6 ; 0.14 ; 97 ; 0.01 ; 100 ; 0.30 ; 104 ; 0.35"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 100, 5, "2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1 ; 413 ; 1 ; 1 ; 0.06 ; 4 ; 6 ; 6 ; 0.12 ; 97 ; 0.01 ; 100 ; 0.45 ; 104 ; 0.30"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 100, 5, "2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1 ; 413 ; 1 ; 1 ; 0.07 ; 4 ; 7.5 ; 6 ; 0.10 ; 97 ; 0.01 ; 100 ; 0.60 ; 104 ; 0.30"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 100, 5, "2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1 ; 413 ; 1 ; 1 ; 0.04 ; 413 ; 1 ; 4 ; 8 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.25 ; 104 ; 0.50"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 100, 5, "2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1 ; 413 ; 1 ; 1 ; 0.08 ; 4 ; 6.5 ; 6 ; 0.05 ; 97 ; 0.01 ; 100 ; 0.25 ; 104 ; 0.45"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 100, 5, "2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1 ; 413 ; 1 ; 1 ; 0.07 ; 4 ; 8.5 ; 6 ; 0.15 ; 97 ; 0.01 ; 104 ; 0.29"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 100, 5, "2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1 ; 413 ; 1 ; 1 ; 0.06 ; 4 ; 11 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.40 ; 104 ; 0.10"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 100, 5, "2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1 ; 413 ; 1 ; 1 ; 0.04 ; 4 ; 6.5 ; 6 ; 0.20 ; 97 ; 0.01 ; 100 ; 0.35 ; 104 ; 0.05"));
		}
	}
	else if (weapondifficulty==2) // Normal
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 101, 5, "2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 137 ; 2 ; 1 ; 0.10 ; 4 ; 7 ; 6 ; 0.18 ; 97 ; 0.01 ; 104 ; 0.42"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 101, 5, "2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 137 ; 2 ; 1 ; 0.12 ; 4 ; 9 ; 6 ; 0.16 ; 97 ; 0.01 ; 104 ; 0.39"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 101, 5, "2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 137 ; 2 ; 1 ; 0.08 ; 4 ; 10 ; 6 ; 0.14 ; 97 ; 0.01 ; 104 ; 0.36"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 101, 5, "2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 137 ; 2 ; 1 ; 0.11 ; 4 ; 12 ; 6 ; 0.12 ; 97 ; 0.01 ; 104 ; 0.33"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 101, 5, "2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 137 ; 2 ; 1 ; 0.14 ; 4 ; 15 ; 6 ; 0.10 ; 97 ; 0.01 ; 104 ; 0.30"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 101, 5, "2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 137 ; 2 ; 1 ; 0.09 ; 4 ; 16 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.35"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 101, 5, "2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 137 ; 2 ; 1 ; 0.17 ; 4 ; 13 ; 6 ; 0.05 ; 97 ; 0.01 ; 104 ; 0.45"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 101, 5, "2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 137 ; 2 ; 1 ; 0.15 ; 4 ; 17 ; 6 ; 0.15 ; 97 ; 0.01 ; 104 ; 0.25"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 101, 5, "2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 137 ; 2 ; 1 ; 0.13 ; 4 ; 22 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.60"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 101, 5, "2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 137 ; 2 ; 1 ; 0.09 ; 4 ; 13 ; 6 ; 0.20 ; 97 ; 0.01 ; 104 ; 0.45"));
		}
	}
	else if (weapondifficulty==3) // Intermediate
	{
		switch (GetRandomInt(0,9))
		{
			case 0:	
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 102, 5, "2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 1 ; 0.13 ; 4 ; 10 ; 6 ; 0.18 ; 97 ; 0.01 ; 104 ; 0.44"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 102, 5, "2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 1 ; 0.15 ; 4 ; 14 ; 6 ; 0.16 ; 97 ; 0.01 ; 104 ; 0.41"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 102, 5, "2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 1 ; 0.12 ; 4 ; 15 ; 6 ; 0.14 ; 97 ; 0.01 ; 104 ; 0.38"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 102, 5, "2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 1 ; 0.16 ; 4 ; 17 ; 6 ; 0.12 ; 97 ; 0.01 ; 104 ; 0.35"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 102, 5, "2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 1 ; 0.19 ; 4 ; 20 ; 6 ; 0.10 ; 97 ; 0.01 ; 104 ; 0.32"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 102, 5, "2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 1 ; 0.15 ; 4 ; 22 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.52"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 102, 5, "2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 1 ; 0.22 ; 4 ; 20 ; 6 ; 0.05 ; 97 ; 0.01 ; 104 ; 0.47"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 102, 5, "2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 1 ; 0.2 ; 4 ; 20 ; 6 ; 0.15 ; 97 ; 0.01 ; 104 ; 0.37"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 102, 5, "2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 1 ; 0.18 ; 4 ; 25 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.32"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 102, 5, "2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6 ; 413 ; 1 ; 1 ; 0.14 ; 4 ; 15 ; 6 ; 0.20 ; 97 ; 0.01 ; 104 ; 0.37"));
		}
	}
	else if (weapondifficulty==4) // Difficult
	{
		switch (GetRandomInt(0,9))
		{	
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 103, 5, "413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6 ; 138 ; 0.15 ; 4 ; 15 ; 6 ; 0.18 ; 97 ; 0.01 ; 104 ; 0.47"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 103, 5, "413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6 ; 138 ; 0.17 ; 4 ; 17 ; 6 ; 0.16 ; 97 ; 0.01 ; 104 ; 0.44"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 103, 5, "413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6 ; 138 ; 0.13 ; 4 ; 13 ; 6 ; 0.14 ; 97 ; 0.01 ; 104 ; 0.41"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 103, 5, "413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6 ; 138 ; 0.16 ; 4 ; 17 ; 6 ; 0.12 ; 97 ; 0.01 ; 104 ; 0.38"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 103, 5, "413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6 ; 138 ; 0.19 ; 4 ; 17 ; 6 ; 0.10 ; 97 ; 0.01 ; 104 ; 0.35"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 103, 5, "413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6 ; 138 ; 0.14 ; 4 ; 18 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.55"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 103, 5, "413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6 ; 138 ; 0.22 ; 4 ; 15 ; 6 ; 0.05 ; 97 ; 0.01 ; 104 ; 0.75"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 103, 5, "413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6 ; 138 ; 0.20 ; 4 ; 19 ; 6 ; 0.15 ; 97 ; 0.01 ; 104 ; 0.47"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 103, 5, "413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6 ; 138 ; 0.18 ; 4 ; 24 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.65"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 103, 5, "413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6 ; 138 ; 0.15 ; 4 ; 15 ; 6 ; 0.20 ; 97 ; 0.01 ; 104 ; 0.70"));
		}
	}
	else if (weapondifficulty==5) // Lunatic
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 104, 5, "72 ; 0.25 ; 208 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7 ; 138 ; 0.20 ; 4 ; 17 ; 6 ; 0.18 ; 97 ; 0.01 ; 104 ; 0.52"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 104, 5, "72 ; 0.25 ; 208 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7 ; 138 ; 0.22 ; 4 ; 19 ; 6 ; 0.16 ; 97 ; 0.01 ; 104 ; 0.49"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 104, 5, "72 ; 0.25 ; 208 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7 ; 138 ; 0.18 ; 4 ; 20 ; 6 ; 0.14 ; 97 ; 0.01 ; 104 ; 0.46"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 104, 5, "72 ; 0.25 ; 208 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7 ; 138 ; 0.21 ; 4 ; 22 ; 6 ; 0.12 ; 97 ; 0.01 ; 104 ; 0.43"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 104, 5, "72 ; 0.25 ; 208 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7 ; 138 ; 0.24 ; 4 ; 25 ; 6 ; 0.10 ; 97 ; 0.01 ; 104 ; 0.40"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 104, 5, "72 ; 0.25 ; 208 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7 ; 138 ; 0.19 ; 4 ; 26 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.60"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 104, 5, "72 ; 0.25 ; 208 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7 ; 138 ; 0.27 ; 4 ; 23 ; 6 ; 0.05 ; 97 ; 0.01 ; 104 ; 0.55"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 104, 5, "72 ; 0.25 ; 208 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7 ; 138 ; 0.25 ; 4 ; 27 ; 6 ; 0.15 ; 97 ; 0.01 ; 104 ; 0.22"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 104, 5, "72 ; 0.25 ; 208 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7 ; 138 ; 0.23 ; 4 ; 32 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.20"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 104, 5, "72 ; 0.25 ; 208 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7 ; 138 ; 0.20 ; 4 ; 23 ; 6 ; 0.20 ; 97 ; 0.01 ; 104 ; 0.20"));
		}
	}
	else if (weapondifficulty==6) // YOU MUST BE DREAMING TO EVEN TRY THIS!
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 105, 5, "411 ; 25 ; 72 ; 0.45 ; 208 ; 1 ; 413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3 ; 138 ; 0.40 ; 4 ; 29 ; 6 ; 0.18 ; 97 ; 0.01 ; 104 ; 0.74"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 105, 5, "411 ; 2.5 ; 72 ; 0.45 ; 208 ; 1 ; 413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3 ; 138 ; 0.44 ; 4 ; 31 ; 6 ; 0.16 ; 97 ; 0.01 ; 104 ; 0.78"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 105, 5, "411 ; 5 ; 72 ; 0.45 ; 208 ; 1 ; 413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3 ; 138 ; 0.36 ; 4 ; 22 ; 6 ; 0.14 ; 97 ; 0.01 ; 104 ; 0.72"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 105, 5, "411 ; 7.5 ; 72 ; 0.45 ; 208 ; 1 ; 413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3 ; 138 ; 0.42 ; 4 ; 24 ; 6 ; 0.12 ; 97 ; 0.01 ; 104 ; 0.66"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 105, 5, "411 ; 10 ; 72 ; 0.45 ; 208 ; 1 ; 413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3 ; 138 ; 0.48 ; 4 ; 27 ; 6 ; 0.10 ; 97 ; 0.01 ; 104 ; 0.60"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 105, 5, "411 ; 12.5 ; 72 ; 0.45 ; 208 ; 1 ; 413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3 ; 138 ; 0.38 ; 4 ; 28 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.80"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 105, 5, "411 ; 15 ;72 ; 0.45 ; 208 ; 1 ; 413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3 ; 138 ; 0.54 ; 413 ; 1 ; 4 ; 25 ; 6 ; 0.05 ; 97 ; 0.01 ; 100 ; 0.50 ; 137 ; 5 ; 104 ; 0.80"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 105, 5, "411 ; 17.5 ; 72 ; 0.45 ; 208 ; 1 ; 413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3 ; 138 ; 0.50 ; 4 ; 29 ; 6 ; 0.15 ; 97 ; 0.01 ; 104 ; 0.72"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 105, 5, "411 ; 20 ; 72 ; 0.45 ; 208 ; 1 ; 413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3 ; 138 ; 0.46 ; 4 ; 34 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.20"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 105, 5, "411 ; 22.5 ; 72 ; 0.45 ; 208 ; 1 ; 413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3 ; 138 ; 0.40 ; 4 ; 25 ; 6 ; 0.20 ; 97 ; 0.01 ; 104 ; 0.20"));
		}
	}
	else if (weapondifficulty==7) // I THINK YOU LOST IT ALREADY!
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 106, 5, "411 ; 2 ; 72 ; 0.65 ; 208 ; 1 ; 413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5 ; 138 ; 0.60 ; 4 ; 27 ; 6 ; 0.18 ; 97 ; 0.01 ; 104 ; 0.94"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 106, 5, "411 ; 4 ; 72 ; 0.65 ; 208 ; 1 ; 413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5 ; 138 ; 0.64 ; 4 ; 29 ; 6 ; 0.16 ; 97 ; 0.01 ; 104 ; 0.98"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 106, 5, "411 ; 6 ; 72 ; 0.65 ; 208 ; 1 ; 413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5 ; 138 ; 0.56 ; 4 ; 30 ; 6 ; 0.14 ; 97 ; 0.01 ; 104 ; 0.92"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 106, 5, "411 ; 8 ; 72 ; 0.65 ; 208 ; 1 ; 413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5 ; 138 ; 0.62 ; 4 ; 32 ; 6 ; 0.12 ; 97 ; 0.01 ; 104 ; 0.86"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 106, 5, "411 ; 10 ; 72 ; 0.65 ; 208 ; 1 ; 413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5 ; 138 ; 0.68 ; 4 ; 35 ; 6 ; 0.10 ; 97 ; 0.01 ; 104 ; 0.80"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 106, 5, "411 ; 12 ; 72 ; 0.65 ; 208 ; 1 ; 413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5 ; 138 ; 0.58 ; 4 ; 36 ; 6 ; 0.08 ; 97 ; 0.01"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 106, 5, "411 ; 14 ; 72 ; 0.65 ; 208 ; 1 ; 413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5 ; 138 ; 0.74 ; 4 ; 33 ; 6 ; 0.05 ; 97 ; 0.01"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 106, 5, "411 ; 16 ; 72 ; 0.65 ; 208 ; 1 ; 413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5 ; 138 ; 0.70 ; 4 ; 37 ; 6 ; 0.15 ; 97 ; 0.01 ; 104 ; 0.92"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 106, 5, "411 ; 18 ; 72 ; 0.65 ; 208 ; 1 ; 413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5 ; 138 ; 0.66 ; 4 ; 42 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.50"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 106, 5, "411 ; 20 ; 72 ; 0.65 ; 208 ; 1 ; 413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5 ; 138 ; 0.60 ; 4 ; 33 ; 6 ; 0.20 ; 97 ; 0.01 ; 104 ; 0.50"));
		}
	}
	else if (weapondifficulty==8) // WAKE UP!!!! PLEASE WAKE UP!!!
	{
		switch (GetRandomInt(0,9))
		{
			case 0:																			 
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 107, 5, "411 ; 5 ; 72 ; 0.85 ; 208 ; 1 ; 413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4 ; 138 ; 0.80 ; 4 ; 39 ; 6 ; 0.18 ; 97 ; 0.01 ; 103 ; 1.14"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 107, 5, "411 ; 8 ; 72 ; 0.85 ; 208 ; 1 ; 413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4 ; 138 ; 0.84 ; 4 ; 41 ; 6 ; 0.16 ; 97 ; 0.01 ; 103 ; 1.18"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 107, 5, "411 ; 11 ; 72 ; 0.85 ; 208 ; 1 ; 413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4 ; 138 ; 0.76 ; 4 ; 32 ; 6 ; 0.14 ; 97 ; 0.01 ; 103 ; 1.12"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 107, 5, "411 ; 14 ; 72 ; 0.85 ; 208 ; 1 ; 413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4 ; 138 ; 0.82 ; 4 ; 42 ; 6 ; 0.12 ; 97 ; 0.01 ; 103 ; 1.06"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 107, 5, "411 ; 17 ; 72 ; 0.85 ; 208 ; 1 ; 413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4 ; 138 ; 0.88 ; 4 ; 47 ; 6 ; 0.10 ; 97 ; 0.01 ; 103 ; 1.05"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 107, 5, "411 ; 20 ; 72 ; 0.85 ; 208 ; 1 ; 413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4 ; 138 ; 0.78 ; 4 ; 48 ; 6 ; 0.08 ; 97 ; 0.01"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 107, 5, "411 ; 23 ; 72 ; 0.85 ; 208 ; 1 ; 413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4 ; 138 ; 0.94 ; 4 ; 13 ; 6 ; 0.05 ; 97 ; 0.01"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 107, 5, "411 ; 26 ; 72 ; 0.85 ; 208 ; 1 ; 413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4 ; 138 ; 0.90 ; 4 ; 49 ; 6 ; 0.15 ; 97 ; 0.01 ; 103 ; 1.22"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 107, 5, "411 ; 29 ; 72 ; 0.85 ; 208 ; 1 ; 413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4 ; 138 ; 0.86 ; 4 ; 44 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.80"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 107, 5, "411 ; 32 ; 72 ; 0.85 ; 208 ; 1 ; 413 ; 1 ; 137 ; 5 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4 ; 138 ; 0.80 ; 4 ; 45 ; 6 ; 0.20 ; 97 ; 0.01 ; 104 ; 0.80"));
		}
	}
	else if (weapondifficulty==9) // ARE YOU SERIOUS?
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 108, 5, "208 ; 1 ; 413 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2 ; 137 ; 20 ; 138 ; 0.60 ; 4 ; 40 ; 6 ; 0.20 ; 97 ; 0.01 ; 411 ; 15"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 108, 5, "208 ; 1 ; 413 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2 ; 137 ; 20 ; 138 ; 0.75 ; 4 ; 45 ; 6 ; 0.17 ; 97 ; 0.01 ; 103 ; 1.35 ; 411 ; 13"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 108, 5, "208 ; 1 ; 413 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2 ; 137 ; 20 ; 138 ; 0.70 ; 4 ; 50 ; 6 ; 0.14 ; 97 ; 0.01 ; 103 ; 1.30 ; 411 ; 11"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 108, 5, "208 ; 1 ; 413 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2 ; 137 ; 20 ; 138 ; 0.75 ; 4 ; 55 ; 6 ; 0.11 ; 97 ; 0.01 ; 103 ; 1.20 ; 411 ; 8"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 108, 5, "208 ; 1 ; 413 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2 ; 137 ; 20 ; 138 ; 0.80 ; 4 ; 60 ; 6 ; 0.08 ; 97 ; 0.01 ; 103 ; 1.05 ; 411 ; 5"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 108, 5, "208 ; 1 ; 413 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2 ; 137 ; 20 ; 138 ; 0.85 ; 4 ; 48 ; 6 ; 0.06 ; 97 ; 0.01 ; 103 ; 1.20 ; 411 ; 25"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 108, 5, "208 ; 1 ; 413 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2 ; 137 ; 20 ; 138 ; 0.85 ; 4 ; 40 ; 6 ; 0.05 ; 97 ; 0.01 ; 103 ; 1.05 ; 411 ; 20"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 108, 5, "208 ; 1 ; 413 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2 ; 137 ; 20 ; 138 ; 0.85 ; 4 ; 42 ; 6 ; 0.08 ; 97 ; 0.01 ; 103 ; 1.25 ; 411 ; 30"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 108, 5, "208 ; 1 ; 413 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2 ; 137 ; 20 ; 138 ; 0.80 ; 4 ; 55 ; 6 ; 0.03 ; 97 ; 0.01 ; 103 ; 1.24 ; 411 ; 35"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 108, 5, "208 ; 1 ; 413 ; 1 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2 ; 137 ; 20 ; 138 ; 0.90 ; 4 ; 47 ; 6 ; 0.13 ; 97 ; 0.01 ; 103 ; 1.10 ; 411 ; 30"));
		}
	}
	PrintToServer("RandomDanmaku(client)");
}

// Blitzkrieg's much more powerful weapons whenever he loses a life. This is his weapon config
BlitzkriegBarrage(client)
{
	if (weapondifficulty==1) // Easy
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 100, 5, "1 ; 0.05 ; 413 ; 1 ; 4 ; 5 ; 6 ; 0.20 ; 97 ; 0.01 ; 100 ; 0.15 ; 104 ; 0.40 ; 137 ; 20 ; 411 ; 15 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 100, 5, "1 ; 0.10 ; 413 ; 1 ; 4 ; 10 ; 6 ; 0.17 ; 97 ; 0.01 ; 100 ; 0.30 ; 104 ; 0.35 ; 137 ; 20 ; 411 ; 13 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 100, 5, "1 ; 0.15 ; 413 ; 1 ; 4 ; 15 ; 6 ; 0.14 ; 97 ; 0.01 ; 100 ; 0.45 ; 104 ; 0.30 ; 137 ; 20 ; 411 ; 11 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 100, 5, "1 ; 0.07 ; 413 ; 1 ; 4 ; 20 ; 6 ; 0.11 ; 97 ; 0.01 ; 100 ; 0.60 ; 104 ; 0.25 ; 137 ; 20 ; 411 ; 8 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 100, 5, "1 ; 0.12 ; 413 ; 1 ; 4 ; 25 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.75 ; 104 ; 0.20 ; 137 ; 20 ; 411 ; 5 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 100, 5, "1 ; 0.07 ; 413 ; 1 ; 4 ; 23 ; 6 ; 0.06 ; 97 ; 0.01 ; 100 ; 0.10 ; 104 ; 0.50 ; 137 ; 20 ; 411 ; 25 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 100, 5, "1 ; 0.13 ; 413 ; 1 ; 4 ; 15 ; 6 ; 0.05 ; 97 ; 0.01 ; 104 ; 0.35 ; 137 ; 20 ; 411 ; 20 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 100, 5, "1 ; 0.15 ; 413 ; 1 ; 4 ; 17 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.70 ; 104 ; 0.45 ; 137 ; 20 ; 411 ; 30 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 100, 5, "1 ; 0.10 ; 413 ; 1 ; 4 ; 25 ; 6 ; 0.03 ; 97 ; 0.01 ; 100 ; 0.20 ; 137 ; 20 ; 104 ; 0.50 ; 411 ; 35 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 100, 5, "1 ; 0.17 ; 413 ; 1 ; 4 ; 23 ; 6 ; 0.13 ; 97 ; 0.01 ; 100 ; 0.50 ; 104 ; 0.40 ; 137 ; 20 ; 411 ; 30 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 1"));
		}
	}
	else if (weapondifficulty==2) // Normal
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 101, 5, "1 ; 0.10 ; 413 ; 1 ; 4 ; 15 ; 6 ; 0.20 ; 97 ; 0.01 ; 100 ; 0.15 ; 104 ; 0.90 ; 137 ; 20 ; 411 ; 15 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 101, 5, "1 ; 0.15 ; 413 ; 1 ; 4 ; 20 ; 6 ; 0.17 ; 97 ; 0.01 ; 100 ; 0.30 ; 104 ; 0.75 ; 137 ; 20 ; 411 ; 13 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 101, 5, "1 ; 0.20 ; 413 ; 1 ; 4 ; 25 ; 6 ; 0.14 ; 97 ; 0.01 ; 100 ; 0.45 ; 104 ; 0.60 ; 137 ; 20 ; 411 ; 11 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 101, 5, "1 ; 0.25 ; 413 ; 1 ; 4 ; 30 ; 6 ; 0.11 ; 97 ; 0.01 ; 100 ; 0.60 ; 104 ; 0.40 ; 137 ; 20 ; 411 ; 8 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 101, 5, "1 ; 0.30 ; 413 ; 1 ; 4 ; 35 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.75 ; 104 ; 0.25 ; 137 ; 20 ; 411 ; 5 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 101, 5, "1 ; 0.15 ; 413 ; 1 ; 4 ; 34 ; 6 ; 0.06 ; 97 ; 0.01 ; 100 ; 0.10 ; 137 ; 20 ; 411 ; 25 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 101, 5, "1 ; 0.20 ; 413 ; 1 ; 4 ; 25 ; 6 ; 0.05 ; 97 ; 0.01 ; 104 ; 0.45 ; 137 ; 20 ; 411 ; 20 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 101, 5, "1 ; 0.25 ; 413 ; 1 ; 4 ; 27 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.70 ; 104 ; 0.95 ; 137 ; 20 ; 411 ; 30 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 101, 5, "1 ; 0.20 ; 413 ; 1 ; 4 ; 40 ; 6 ; 0.03 ; 97 ; 0.01 ; 100 ; 0.20 ; 137 ; 20 ; 411 ; 35 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 101, 5, "1 ; 0.30 ; 413 ; 1 ; 4 ; 33 ; 6 ; 0.13 ; 97 ; 0.01 ; 100 ; 0.50 ; 104 ; 0.50 ; 137 ; 20 ; 411 ; 30 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
		}
	}
	else if (weapondifficulty==3) // Intermediate
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 102, 5, "1 ; 0.15 ; 413 ; 1 ; 4 ; 20 ; 6 ; 0.20 ; 97 ; 0.01 ; 100 ; 0.15 ; 104 ; 0.90 ; 137 ; 20 ; 411 ; 15 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 102, 5, "1 ; 0.20 ; 413 ; 1 ; 4 ; 25 ; 6 ; 0.17 ; 97 ; 0.01 ; 100 ; 0.30 ; 104 ; 0.75 ; 137 ; 20 ; 411 ; 13 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 102, 5, "1 ; 0.25 ; 413 ; 1 ; 4 ; 30 ; 6 ; 0.14 ; 97 ; 0.01 ; 100 ; 0.45 ; 104 ; 0.60 ; 137 ; 20 ; 411 ; 11 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 102, 5, "1 ; 0.30 ; 413 ; 1 ; 4 ; 35 ; 6 ; 0.11 ; 97 ; 0.01 ; 100 ; 0.60 ; 104 ; 0.40 ; 137 ; 20 ; 411 ; 8 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 102, 5, "1 ; 0.35 ; 413 ; 1 ; 4 ; 49 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.75 ; 104 ; 0.25 ; 137 ; 20 ; 411 ; 5 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 102, 5, "1 ; 0.20 ; 413 ; 1 ; 4 ; 45 ; 6 ; 0.06 ; 97 ; 0.01 ; 100 ; 0.10 ; 137 ; 20 ; 411 ; 25 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 102, 5, "1 ; 0.25 ; 413 ; 1 ; 4 ; 40 ; 6 ; 0.05 ; 97 ; 0.01 ; 104 ; 0.45 ; 137 ; 20 ; 411 ; 20 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 102, 5, "1 ; 0.30 ; 413 ; 1 ; 4 ; 32 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.70 ; 104 ; 0.95 ; 137 ; 20 ; 411 ; 30 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 102, 5, "1 ; 0.25 ; 413 ; 1 ; 4 ; 45 ; 6 ; 0.03 ; 97 ; 0.01 ; 100 ; 0.20 ; 137 ; 20 ; 411 ; 35 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 102, 5, "1 ; 0.32 ; 413 ; 1 ; 4 ; 37 ; 6 ; 0.13 ; 97 ; 0.01 ; 100 ; 0.50 ; 104 ; 0.50 ; 137 ; 20 ; 411 ; 30 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 6"));
		}
	}
	else if (weapondifficulty==4) // Difficult
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 103, 5, "72 ; 0.25 ; 208 ; 1 ; 138 ; 0.20 ; 413 ; 1 ; 4 ; 25 ; 6 ; 0.18 ; 97 ; 0.01 ; 137 ; 20 ; 411 ; 15 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 103, 5, "72 ; 0.25 ; 208 ; 1 ; 138 ; 0.25 ; 413 ; 1 ; 4 ; 30 ; 6 ; 0.15 ; 97 ; 0.01 ; 104 ; 0.85 ; 137 ; 20 ; 411 ; 13 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 103, 5, "72 ; 0.25 ; 208 ; 1 ; 138 ; 0.30 ; 413 ; 1 ; 4 ; 35 ; 6 ; 0.12 ; 97 ; 0.01 ; 104 ; 0.70 ; 137 ; 20 ; 411 ; 11 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 103, 5, "72 ; 0.25 ; 208 ; 1 ; 138 ; 0.35 ; 413 ; 1 ; 4 ; 40 ; 6 ; 0.10 ; 97 ; 0.01 ; 104 ; 0.50 ; 137 ; 20 ; 411 ; 8 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 103, 5, "72 ; 0.25 ; 208 ; 1 ; 138 ; 0.40 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.08 ; 97 ; 0.01 ; 104 ; 0.35 ; 137 ; 20 ; 411 ; 5 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 103, 5, "72 ; 0.25 ; 208 ; 1 ; 138 ; 0.25 ; 413 ; 1 ; 4 ; 48 ; 6 ; 0.06 ; 97 ; 0.01 ; 137 ; 20 ; 411 ; 25 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 103, 5, "72 ; 0.25 ; 208 ; 1 ; 138 ; 0.30 ; 413 ; 1 ; 4 ; 40 ; 6 ; 0.05 ; 97 ; 0.01 ; 104 ; 0.55 ; 137 ; 20 ; 411 ; 20 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 103, 5, "72 ; 0.25 ; 208 ; 1 ; 138 ; 0.35 ; 413 ; 1 ; 4 ; 42 ; 6 ; 0.05 ; 97 ; 0.01 ; 104 ; 0.95 ; 137 ; 20 ; 411 ; 30 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 6"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 103, 5, "72 ; 0.25 ; 208 ; 1 ; 138 ; 0.30 ; 413 ; 1 ; 4 ; 55 ; 6 ; 0.03 ; 97 ; 0.01 ; 137 ; 20 ; 411 ; 35 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 3"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 103, 5, "72 ; 0.25 ; 208 ; 1 ; 138 ; 0.40 ; 413 ; 1 ; 4 ; 47 ; 6 ; 0.07 ; 97 ; 0.01 ; 104 ; 0.60 ; 137 ; 20 ; 411 ; 30 ; 2025 ; 3 ; 2013 ; 2003 ; 2014 ; 3"));
		}
	}
	else if (weapondifficulty==5) // Lunatic
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 104, 5, "72 ; 0.45 ; 208 ; 1 ; 138 ; 0.30 ; 413 ; 1 ; 4 ; 30 ; 6 ; 0.10 ; 97 ; 0.01 ; 100 ; 0.15 ; 137 ; 20 ; 411 ; 15 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 104, 5, "72 ; 0.45 ; 208 ; 1 ; 138 ; 0.35 ; 413 ; 1 ; 4 ; 35 ; 6 ; 0.07 ; 97 ; 0.01 ; 100 ; 0.30 ; 103 ; 1.15 ; 137 ; 20 ; 411 ; 13 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 104, 5, "72 ; 0.45 ; 208 ; 1 ; 138 ; 0.40 ; 413 ; 1 ; 4 ; 40 ; 6 ; 0.04 ; 97 ; 0.01 ; 100 ; 0.45 ; 137 ; 20 ; 411 ; 11 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 104, 5, "72 ; 0.45 ; 208 ; 1 ; 138 ; 0.45 ; 413 ; 1 ; 4 ; 45 ; 6 ; 0.01 ; 97 ; 0.01 ; 100 ; 0.60 ; 104 ; 0.80 ; 137 ; 20 ; 411 ; 8 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 104, 5, "72 ; 0.45 ; 208 ; 1 ; 138 ; 0.50 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.75 ; 104 ; 0.65 ; 137 ; 20 ; 411 ; 5 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 104, 5, "72 ; 0.45 ; 208 ; 1 ; 138 ; 0.45 ; 413 ; 1 ; 4 ; 58 ; 6 ; 0.06 ; 97 ; 0.01 ; 100 ; 0.10 ; 137 ; 20 ; 411 ; 25 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 104, 5, "72 ; 0.45 ; 208 ; 1 ; 138 ; 0.45 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.05 ; 97 ; 0.01 ; 104 ; 0.65 ; 137 ; 20 ; 411 ; 20 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 104, 5, "72 ; 0.45 ; 208 ; 1 ; 138 ; 0.55 ; 413 ; 1 ; 4 ; 52 ; 6 ; 0.08 ; 97 ; 0.01 ; 100 ; 0.70 ; 137 ; 20 ; 411 ; 30 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 104, 5, "72 ; 0.45 ; 208 ; 1 ; 138 ; 0.50 ; 413 ; 1 ; 4 ; 65 ; 6 ; 0.03 ; 97 ; 0.01 ; 100 ; 0.20 ; 137 ; 20 ; 411 ; 35 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 104, 5, "72 ; 0.45 ; 208 ; 1 ; 138 ; 0.60 ; 413 ; 1 ; 4 ; 57 ; 6 ; 0.03 ; 97 ; 0.01 ; 100 ; 0.50 ; 104 ; 0.70 ; 137 ; 20 ; 411 ; 30 ; 2025 ; 3 ; 2013 ; 2008 ; 2014 ; 7"));
		}
	}
	else if (weapondifficulty==6) // YOU MUST BE DREAMING TO EVEN TRY THIS!
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 105, 5, "72 ; 0.65 ; 208 ; 1 ; 138 ; 0.40 ; 413 ; 1 ; 4 ; 35 ; 6 ; 0.06 ; 97 ; 0.01 ; 100 ; 0.15 ; 137 ; 20 ; 411 ; 15 ; 2025 ; 3 ; 2013 ; 2007 ; 2014 ; 3"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 105, 5, "72 ; 0.65 ; 208 ; 1 ; 138 ; 0.55 ; 413 ; 1 ; 4 ; 40 ; 6 ; 0.06 ; 97 ; 0.01 ; 100 ; 0.30 ; 103 ; 1.25 ; 137 ; 20 ; 411 ; 13 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 105, 5, "72 ; 0.65 ; 208 ; 1 ; 138 ; 0.50 ; 413 ; 1 ; 4 ; 45 ; 6 ; 0.06 ; 97 ; 0.01 ; 100 ; 0.45 ; 103 ; 1.10 ; 137 ; 20 ; 411 ; 11 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 105, 5, "72 ; 0.65 ; 208 ; 1 ; 138 ; 0.55 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.06 ; 97 ; 0.01 ; 100 ; 0.60 ; 103 ; 1.10 ; 137 ; 20 ; 411 ; 8 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 105, 5, "72 ; 0.65 ; 208 ; 1 ; 138 ; 0.60 ; 413 ; 1 ; 4 ; 55 ; 6 ; 0.06 ; 97 ; 0.01 ; 100 ; 0.75 ; 104 ; 0.85 ; 137 ; 20 ; 411 ; 5 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 105, 5, "72 ; 0.65 ; 208 ; 1 ; 138 ; 0.55 ; 413 ; 1 ; 4 ; 68 ; 6 ; 0.06 ; 97 ; 0.01 ; 103 ; 1.10 ; 100 ; 0.10 ; 137 ; 20 ; 411 ; 25 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 105, 5, "72 ; 0.65 ; 208 ; 1 ; 138 ; 0.55 ; 413 ; 1 ; 4 ; 60 ; 6 ; 0.06 ; 97 ; 0.01 ; 104 ; 0.85 ; 137 ; 20 ; 411 ; 20 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 105, 5, "72 ; 0.65 ; 208 ; 1 ; 138 ; 0.65 ; 413 ; 1 ; 4 ; 62 ; 6 ; 0.06 ; 97 ; 0.01 ; 100 ; 0.70 ; 103 ; 1.15 ; 137 ; 20 ; 411 ; 30 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 105, 5, "72 ; 0.65 ; 208 ; 1 ; 138 ; 0.60 ; 413 ; 1 ; 4 ; 65 ; 6 ; 0.06 ; 97 ; 0.01 ; 100 ; 0.20 ; 103 ; 1.14 ; 137 ; 20 ; 411 ; 35 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 105, 5, "72 ; 0.65 ; 208 ; 1 ; 138 ; 0.70 ; 413 ; 1 ; 4 ; 67 ; 6 ; 0.06 ; 97 ; 0.01 ; 100 ; 0.50 ; 104 ; 0.90 ; 137 ; 20 ; 411 ; 30 ; 2025 ; 3 ; 2013 ; 2006 ; 2014 ; 3"));
		}
	}
	else if (weapondifficulty==7) // I THINK YOU LOST IT ALREADY!
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 106, 5, "72 ; 0.85 ; 208 ; 1 ; 138 ; 0.90 ; 413 ; 1 ; 4 ; 40 ; 6 ; 0.01 ; 97 ; 0.01 ; 100 ; 0.15 ; 137 ; 20 ; 411 ; 15 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 106, 5, "72 ; 0.85 ; 208 ; 1 ; 413 ; 1 ; 4 ; 45 ; 6 ; 0.07 ; 97 ; 0.01 ; 100 ; 0.30 ; 103 ; 1.35 ; 137 ; 20 ; 411 ; 13 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 106, 5, "72 ; 0.85 ; 208 ; 1 ; 138 ; 0.90 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.04 ; 97 ; 0.01 ; 100 ; 0.45 ; 103 ; 1.30 ; 137 ; 20 ; 411 ; 11 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 106, 5, "72 ; 0.85 ; 208 ; 1 ; 138 ; 0.95 ; 413 ; 1 ; 4 ; 55 ; 6 ; 0.04 ; 97 ; 0.01 ; 100 ; 0.60 ; 103 ; 1.20 ; 137 ; 20 ; 411 ; 8 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 106, 5, "72 ; 0.85 ; 208 ; 1 ; 413 ; 1 ; 4 ; 60 ; 6 ; 0.04 ; 97 ; 0.01 ; 100 ; 0.75 ; 103 ; 1.05 ; 137 ; 20 ; 411 ; 5 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 106, 5, "72 ; 0.85 ; 208 ; 1 ; 2 ; 1.15 ; 413 ; 1 ; 4 ; 78 ; 6 ; 0.04 ; 97 ; 0.01 ; 103 ; 1.20 ; 100 ; 0.10 ; 137 ; 20 ; 411 ; 25 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 106, 5, "72 ; 0.85 ; 208 ; 1 ; 2 ; 1.15 ; 413 ; 1 ; 4 ; 70 ; 6 ; 0.04 ; 97 ; 0.01 ; 103 ; 1.05 ; 137 ; 20 ; 411 ; 20 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 106, 5, "72 ; 0.85 ; 208 ; 1 ; 2 ; 1.15 ; 413 ; 1 ; 4 ; 72 ; 6 ; 0.04 ; 97 ; 0.01 ; 100 ; 0.70 ; 103 ; 1.25 ; 137 ; 20 ; 411 ; 30 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 106, 5, "72 ; 0.85 ; 208 ; 1 ; 2 ; 1.10 ; 413 ; 1 ; 4 ; 75 ; 6 ; 0.04 ; 97 ; 0.01 ; 100 ; 0.20 ; 103 ; 1.24 ; 137 ; 20 ; 411 ; 35 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 106, 5, "72 ; 0.85 ; 208 ; 1 ; 2 ; 1.20 ; 413 ; 1 ; 4 ; 77 ; 6 ; 0.04 ; 97 ; 0.01 ; 100 ; 0.50 ; 103 ; 1.10 ; 137 ; 20 ; 411 ; 30 ; 2025 ; 3 ; 2013 ; 2005 ; 2014 ; 5"));
		}
	}
	else if (weapondifficulty==8) // WAKE UP!!!! PLEASE WAKE UP!!!
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 107, 5, "208 ; 1 ; 2 ; 1.90 ; 413 ; 1 ; 4 ; 45 ; 6 ; 0.02 ; 97 ; 0.01 ; 100 ; 0.15 ; 137 ; 20 ; 411 ; 15 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 107, 5, "208 ; 1 ; 2 ; 1.95 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.02 ; 97 ; 0.01 ; 100 ; 0.30 ; 103 ; 1.65 ; 137 ; 20 ; 411 ; 13 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 107, 5, "208 ; 1 ; 2 ; 1.90 ; 413 ; 1 ; 4 ; 55 ; 6 ; 0.02 ; 97 ; 0.01 ; 100 ; 0.45 ; 103 ; 1.60 ; 137 ; 20 ; 411 ; 11 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 107, 5, "208 ; 1 ; 2 ; 1.95 ; 413 ; 1 ; 4 ; 60 ; 6 ; 0.02 ; 97 ; 0.01 ; 100 ; 0.60 ; 103 ; 1.50 ; 137 ; 20 ; 411 ; 8 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 107, 5, "208 ; 1 ; 2 ; 2.10 ; 413 ; 1 ; 4 ; 65 ; 6 ; 0.02 ; 97 ; 0.01 ; 100 ; 0.75 ; 103 ; 1.40 ; 137 ; 20 ; 411 ; 5 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 107, 5, "208 ; 1 ; 2 ; 2.15 ; 413 ; 1 ; 4 ; 88 ; 6 ; 0.02 ; 97 ; 0.01 ; 103 ; 1.50 ; 100 ; 0.10 ; 137 ; 20 ; 411 ; 25 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 107, 5, "208 ; 1 ; 2 ; 2.25 ; 413 ; 1 ; 4 ; 80 ; 6 ; 0.02 ; 97 ; 0.01 ; 103 ; 1.60 ; 137 ; 20 ; 411 ; 20 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 107, 5, "208 ; 1 ; 2 ; 2.05 ; 413 ; 1 ; 4 ; 82 ; 6 ; 0.02 ; 97 ; 0.01 ; 100 ; 0.70 ; 103 ; 1.50 ; 137 ; 20 ; 411 ; 30 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 107, 5, "208 ; 1 ; 2 ; 2.20 ; 413 ; 1 ; 4 ; 85 ; 6 ; 0.02 ; 97 ; 0.01 ; 100 ; 0.20 ; 103 ; 1.48 ; 137 ; 20 ; 411 ; 35 ; 2025 ; 3 ; 2013 ; 2002; 2014 ; 4"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 107, 5, "208 ; 1 ; 2 ; 2.30 ; 413 ; 1 ; 4 ; 87 ; 6 ; 0.02 ; 97 ; 0.01 ; 100 ; 0.50 ; 103 ; 1.70 ; 137 ; 20 ; 411 ; 30 ; 2025 ; 3 ; 2013 ; 2002 ; 2014 ; 4"));
		}
	}
	else if (weapondifficulty==9) // ARE YOU SERIOUS? 
	{
		switch (GetRandomInt(0,9))
		{
			case 0:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 414, 108, 5, "208 ; 1 ; 2 ; 2.90 ; 413 ; 1 ; 4 ; 50 ; 6 ; 0.00 ; 97 ; 0.00 ; 100 ; 0.15 ; 137 ; 20 ; 411 ; 15 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
			case 1:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 108, 5, "208 ; 1 ; 2 ; 2.95 ; 413 ; 1 ; 4 ; 55 ; 6 ; 0.00 ; 97 ; 0.00 ; 100 ; 0.30 ; 103 ; 2.65 ; 137 ; 20 ; 411 ; 13 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
			case 2:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 513, 108, 5, "208 ; 1 ; 2 ; 2.90 ; 413 ; 1 ; 4 ; 60 ; 6 ; 0.00 ; 97 ; 0.00 ; 100 ; 0.45 ; 103 ; 2.60 ; 137 ; 20 ; 411 ; 11 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
			case 3:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 1085, 108, 5, "208 ; 1 ; 2 ; 2.95 ; 413 ; 1 ; 4 ; 65 ; 6 ; 0.00 ; 97 ; 0.00 ; 100 ; 0.60 ; 103 ; 2.50 ; 137 ; 20 ; 411 ; 8 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
			case 4:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 658, 108, 5, "208 ; 1 ; 2 ; 2.10 ; 413 ; 1 ; 4 ; 70 ; 6 ; 0.00 ; 97 ; 0.00 ; 100 ; 0.75 ; 103 ; 2.40 ; 137 ; 20 ; 411 ; 5 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
			case 5:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 108, 5, "208 ; 1 ; 2 ; 3.15 ; 413 ; 1 ; 4 ; 98 ; 6 ; 0.00 ; 97 ; 0.00 ; 103 ; 2.50 ; 100 ; 0.10 ; 137 ; 20 ; 411 ; 25 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
			case 6:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 108, 5, "208 ; 1 ; 2 ; 3.25 ; 413 ; 1 ; 4 ; 90 ; 6 ; 0.00 ; 97 ; 0.00 ; 103 ; 2.60 ; 137 ; 20 ; 411 ; 20 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
			case 7:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 108, 5, "208 ; 1 ; 2 ; 3.05 ; 413 ; 1 ; 4 ; 92 ; 6 ; 0.00 ; 97 ; 0.00 ; 100 ; 0.70 ; 103 ; 2.50 ; 137 ; 20 ; 411 ; 30 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
			case 8:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 108, 5, "208 ; 1 ; 2 ; 3.20 ; 413 ; 1 ; 4 ; 95 ; 6 ; 0.00 ; 97 ; 0.00 ; 100 ; 0.20 ; 103 ; 2.48 ; 137 ; 20 ; 411 ; 35 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
			case 9:
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_rocketlauncher", 974, 108, 5, "208 ; 1 ; 2 ; 3.30 ; 413 ; 1 ; 4 ; 97 ; 6 ; 0.00 ; 97 ; 0.00 ; 100 ; 0.50 ; 103 ; 2.70 ; 137 ; 20 ; 411 ; 30 ; 2025 ; 3 ; 2013 ; 2004 ; 2014 ; 2"));
		}
	}
	PrintToServer("BlitzkriegBarrage(client)");
}

// Custom Weapon Stuff
CustomWeapons(client)
{
	SetEntityRenderColor(client, 255, 255, 255, 255);
	new weapon=GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
	new index=-1;
	if(IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client)!=BossTeam)
	{
		// Soldier Stuff
		if(TF2_GetPlayerClass(client)==TFClass_Soldier)
		{
			weapon=GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
			index=GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
			switch(index)
			{
				case 441: //Cow Mangler
				{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
					weapon=SpawnWeapon(client, "tf_weapon_particle_cannon", 441, 5, 10, "2 ; 1.50 ; 58 ; 2 ; 281 ; 1 ; 282 ; 1 ; 288 ; 1 ; 366 ; 5");
					// 2: +50% damage bonus
					// 58: +100% Self Damage Push Force
					// 281: No ammo needed
					// 282: Charged Shot on alt-fire
					// 288: Cannot be crit boosted
					// 366: On Hit: If enemy's belt is at or above eye level, stun them for 5 seconds
					PrintHintText(client, "A successful hit mid-air stuns Blitzkrieg for 5 seconds");
				}
				case 730: //Beggar's Bazooka
				{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
					weapon=SpawnWeapon(client, "tf_weapon_rocketlauncher", 730, 5, 10, "2 ; 1.1 ; 4 ; 7.5 ; 6 ; 0.15 ; 76 ; 10 ; 97 ; 0.50 ; 411 ; 30 ; 413 ; 1 ; 417 ; 1");
					// 2: 10% Damage Bonus
					// 4: +650 Clip Size
					// 6: 85% Faster Firing Speed
					// 76: +1000% Max primary ammo on wearer
					// 597: 50% Faster reload speed
					// 411: 30 degrees random projectile deviation
					// 413: Hold Fire to load 30 rockets
					// 417: Overloading will misfire
					PrintHintText(client, "Unleash your OWN Danmaku! Careful as you can overload");

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
				case 1104: // Air Strike
				{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
					weapon=SpawnWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 5, 10, "1 ; 0.90 ; 15 ; 1 ; 179 ; 1 ; 232 ; 10 ; 488 ; 150 ; 621 ; 1 ; 644 ; 1");
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
		// Engineer Stuff
		if(TF2_GetPlayerClass(client)==TFClass_Engineer)
		{
			weapon=GetPlayerWeaponSlot(client, TFWeaponSlot_PDA);
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_PDA);
			weapon=SpawnWeapon(client, "tf_weapon_engineer_build", 25, 5, 10, "276 ; 1 ; 345 ; 2.5");
				// 276: Bidirectional Teleporters
				// 345: Dispenser Radius Increased
			PrintHintText(client, "Your dispenser radius was increased by 150%. Your teleporters are bi-directional");
		}
		// Medic Stuff
		if(TF2_GetPlayerClass(client)==TFClass_Medic)
		{
			weapon=GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
			weapon=SpawnWeapon(client, "tf_weapon_medigun", 29, 5, 10, "499 ; 50.0 ; 10 ; 1.25 ; 178 ; 0.75 ; 144 ; 2.0 ; 11 ; 1.5 ; 482 ; 150 ; 493 ; 150");
				//499: Projectile Shield
				//10: +25% faster charge rate
				//178: +25% faster weapon switch
				//144: Quick-fix speed/jump effects
				//11: +50% overheal bonus
				//482: Overheal Expert
				//493: Healing Mastery
			SetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel", 0.50);
			PrintHintText(client, "Use +attack3 (default: middle mouse button) to deploy a projectile shield");

		}
	}
	PrintToServer("*Custom Weapons Active (customweapons==1)*");
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
				weapondifficulty=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 1, 2);
				combatstyle=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 2);
				customweapons=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 3); // use custom weapons
				voicelines=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 4); // Voice Lines
				miniblitzkriegrage=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 5); // RAGE/Weaponswitch Ammo
				blitzkriegrage=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 6); // Blitzkrieg Rampage Ammo
				allowrevive=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 7); // Allow players to be revived?
				decaytime=FF2_GetAbilityArgument(0,this_plugin_name,"blitzkrieg_config", 8); // Timer before reanimator expires
				if(weapondifficulty==1)
				{
					CPrintToChatAll("Level 1: Easy");
				}
				else if(weapondifficulty==2)
				{
					CPrintToChatAll("Level 2: Normal");
				}
				else if(weapondifficulty==3)
				{
					CPrintToChatAll("Level 3: Intermediate");
				}
				else if(weapondifficulty==4)
				{
					CPrintToChatAll("Level 4: Difficult");
				}
				else if(weapondifficulty==5)
				{
					CPrintToChatAll("Level 5: Lunatic");
				}
				else if(weapondifficulty==6)
				{
					CPrintToChatAll("Level 6: Extreme");
				}
				else if(weapondifficulty==7)
				{
					CPrintToChatAll("Level 7: Godlike");
				}
				else if(weapondifficulty==8)
				{
					CPrintToChatAll("Level 8: Rocket Hell");
				}
				else if(weapondifficulty==9)
				{
					CPrintToChatAll("Level 9: Total Blitzkrieg");
				}
				else if(weapondifficulty==0)
				{
					switch (GetRandomInt(0,8))
					{
						case 0:
							weapondifficulty=1, CPrintToChatAll("Level 1: Easy");
						case 1:
							weapondifficulty=2, CPrintToChatAll("Level 2: Normal");
						case 2:
							weapondifficulty=3, CPrintToChatAll("Level 3: Intermediate");
						case 3:
							weapondifficulty=4, CPrintToChatAll("Level 4: Difficult");
						case 4:
							weapondifficulty=5, CPrintToChatAll("Level 5: Lunatic");
						case 5:
							weapondifficulty=6, CPrintToChatAll("Level 6: Extreme");
						case 6:
							weapondifficulty=7, CPrintToChatAll("Level 7: Godlike");
						case 7:
							weapondifficulty=8, CPrintToChatAll("Level 8: Rocket Hell");
						case 8:
							weapondifficulty=9, CPrintToChatAll("Level 9: Total Blitzkrieg");
					}
				}
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
				if(customweapons!=0)
				{
					decl i;
					for( i = 1; i <= MaxClients; i++ )
					{
						CustomWeapons(i);
					}
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
			if(allowrevive!=0)
			{
				DropReanimator(client);
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
	for (new i = 1; i <= MaxClients; i++) 
	{
		RemoveReanimator(i);
	}
	if (screwgravity!=INVALID_HANDLE)
	{
		KillTimer(screwgravity);
		screwgravity = INVALID_HANDLE;
	}
	if (crockethell!=INVALID_HANDLE)
	{
		KillTimer(crockethell);
		crockethell = INVALID_HANDLE;
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
	if (crockethell!=INVALID_HANDLE)
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
	SetAmmo(Boss, TFWeaponSlot_Primary,999999);
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

public Action:RemoveUber(Handle:hTimer,any:index)
{
	new Boss=GetClientOfUserId(FF2_GetBossUserId(index));
	PrintToServer("Rage_Timer_UnuseCharge(Handle:hTimer,any:index)");
	SetEntProp(Boss, Prop_Data, "m_takedamage", 2);
	return Plugin_Continue;
}