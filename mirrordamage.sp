#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>

#define VERSION "1.3"

public Plugin:myinfo = {
	name = "Mirror Damage",
	author = "Hurp Durp",
	description = "",
	version = VERSION,
	url = "www.negroserver.com"
};

new bool:PlayerEnabled[MAXPLAYERS+1];
new bool:PlayerEnabledGod[MAXPLAYERS+1];
new Handle:cvar_Multiplier;

public OnPluginStart()
{
	CreateConVar("sm_mirrordamage_version", VERSION, "Mirror Damage Version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	cvar_Multiplier = CreateConVar("sm_mirrordamage_multiplier", "0.8", "Damage multiplier", FCVAR_PLUGIN, true, 0.1);
	
	RegAdminCmd("sm_mirrordamage", MirrorDamage, ADMFLAG_ROOT, "Mirror a player\'s damage");
	RegAdminCmd("sm_mirror_god", MirrorGod, ADMFLAG_ROOT, "Mirror all damage against a player");
	
	for(new i = 1; i <= MaxClients; i++)
	{
		if(ValidClient(i))
			SDKHook(i, SDKHook_OnTakeDamage, OnTakeDamage);
	}
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action:MirrorDamage(client, args)
{
	if (args < 2)
	{
		ReplyToCommand(client, "[SM] Usage: sm_mirrordamage <#userid|name> <1/0>");
		return Plugin_Handled;
	}
	decl String:arg[65];
	decl String:numstr[65];
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, numstr, sizeof(numstr));
	new enabled = StringToInt(numstr);
	
	decl String:target_name[MAX_TARGET_LENGTH];
	decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;
	
	if ((target_count = ProcessTargetString(
			arg,
			client,
			target_list,
			MAXPLAYERS,
			0,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToCommand(client, "[SM] Player not found");
		return Plugin_Handled;
	}
	
	for (new i = 0; i < target_count; i++)
	{
		if (enabled)
		{
			PlayerEnabled[target_list[i]] = true;
			LogAction(client, target_list[i], "%L Enabled mirror damage on %L", client, target_list[i]);
		}
		else
		{
			PlayerEnabled[target_list[i]] = false;
			LogAction(client, target_list[i], "%L Disabled mirror damage on %L", client, target_list[i]);
		}
	}
	
	if (enabled)
		ShowActivity2(client, "[SM] ","Enabled mirror damage on %s", target_name);
	else
		ShowActivity2(client, "[SM] ","Disabled mirror damage on %s", target_name);
	
	return Plugin_Handled;
}

public Action:MirrorGod(client, args)
{
	if (args < 2)
	{
		ReplyToCommand(client, "[SM] Usage: sm_mirrordamage_god <#userid|name> <1/0>");
		return Plugin_Handled;
	}
	decl String:arg[65];
	decl String:numstr[65];
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, numstr, sizeof(numstr));
	new enabled = StringToInt(numstr);
	
	decl String:target_name[MAX_TARGET_LENGTH];
	decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;
	
	if ((target_count = ProcessTargetString(
			arg,
			client,
			target_list,
			MAXPLAYERS,
			0,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToCommand(client, "[SM] Player not found");
		return Plugin_Handled;
	}
	
	for (new i = 0; i < target_count; i++)
	{
		if (enabled)
		{
			PlayerEnabledGod[target_list[i]] = true;
			LogAction(client, target_list[i], "%L Mirrored all damage against %L", client, target_list[i]);
		}
		else
		{
			PlayerEnabledGod[target_list[i]] = false;
			LogAction(client, target_list[i], "%L Disabled mirror damage on %L", client, target_list[i]);
		}
	}
	
	if (enabled)
		ShowActivity2(client, "[SM] ","Mirrored all damage against %s", target_name);
	else
		ShowActivity2(client, "[SM] ","Disabled mirror damage on %s", target_name);
	
	return Plugin_Handled;
}

public Action:OnTakeDamage(client, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3], damagecustom)
{
	if(!ValidClient(client) || !ValidClient(attacker) || client == attacker)
		return Plugin_Continue;

	if(PlayerEnabled[attacker] || PlayerEnabledGod[client])
	{	
		new wep;
		
		if(inflictor > 0 && inflictor <= MaxClients)
			wep = client;
		else
			wep = inflictor;
		/*
		new Float:dmgForceMirror[3];
		
		new Float:attackerPos[3];
		GetClientAbsOrigin(client, attackerPos);
		
		SubtractVectors(damageForce, damagePosition, dmgForceMirror);
		AddVectors(dmgForceMirror, attackerPos, dmgForceMirror);
		*/
		
		SDKHooks_TakeDamage(attacker,
							inflictor,
							attacker,
							damage * GetConVarFloat(cvar_Multiplier),
							DMG_PREVENT_PHYSICS_FORCE,
							weapon,
							damageForce,
							damagePosition);
		
		/* Handle mantreads damage */
		if (damagecustom == TF_CUSTOM_BOOTS_STOMP)
			damage = 0.0;
		
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public OnClientDisconnect(client)
{
	PlayerEnabled[client] = false;
	PlayerEnabledGod[client] = false;
}

stock ValidClient(client)
{
	if(0 < client <= MaxClients && IsClientConnected(client) && IsClientInGame(client))
		return true;
	else
		return false;
}