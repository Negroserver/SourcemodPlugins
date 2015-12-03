#pragma semicolon 1
#include <sourcemod>

#define PLUGIN_VERSION "1.3" //v2

public Plugin:myinfo = {
	name		= "Killstreak Enabler",
	author		= "Hurp Durp",
	description	= "",
	version		= PLUGIN_VERSION,
	url			= "http://www.negroserver.com"
};

new bool:IsEnabled[MAXPLAYERS+1];

public OnPluginStart()
{
	RegConsoleCmd("sm_ks", Cmd_KS);
	RegConsoleCmd("sm_kson", Cmd_KS);
	RegConsoleCmd("sm_ksoff", Cmd_KS);
	RegAdminCmd("sm_ks_admin", Cmd_KS_Admin, ADMFLAG_ROOT, "Toggle killstreak for a player");
	RegAdminCmd("sm_kson_admin", Cmd_KS_Admin, ADMFLAG_ROOT, "Enable killstreak for a player");
	RegAdminCmd("sm_ksoff_admin", Cmd_KS_Admin, ADMFLAG_ROOT, "Disable killstreak for a player");
	RegAdminCmd("sm_setstreak", Cmd_SetStreak, ADMFLAG_ROOT, "Set killstreak ammount for a player");
	
	HookEvent("player_spawn", OnPlayerSpawn);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
	
	LoadTranslations("common.phrases");
}

public Action:Cmd_KS(client, args)
{
	if (args > 0)
	{
		decl String:admincmd[64];
		GetCmdArgString(admincmd, 64);
		Format(admincmd, 64, "sm_ks_admin %s", admincmd);
		FakeClientCommand(client, admincmd);
		return Plugin_Handled;
	}
	
	if (IsEnabled[client])
	{
		SetEntProp(client, Prop_Send, "m_nStreaks", 0);
		IsEnabled[client] = false;
		ReplyToCommand(client, "[SM] Killstreak effects disabled");
	} else {
		SetEntProp(client, Prop_Send, "m_nStreaks", 10);
		IsEnabled[client] = true;
		ReplyToCommand(client, "[SM] Killstreak effects enabled");
	}
	
	return Plugin_Handled;
}

public Action:Cmd_KS_Admin(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_ks <#userid|name> <1/0>");
		return Plugin_Handled;
	}
	
	decl String:arg[65];
	GetCmdArg(1, arg, sizeof(arg));
	
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
	
	if (args < 2)
	{
		for (new i = 0; i < target_count; i++)
		{
			if (IsEnabled[target_list[i]])
			{
				SetEntProp(target_list[i], Prop_Send, "m_nStreaks", 0);
				IsEnabled[target_list[i]] = false;
			}
			else
			{
				SetEntProp(target_list[i], Prop_Send, "m_nStreaks", 10);
				IsEnabled[target_list[i]] = true;
			}
			
			LogAction(client, target_list[i], "%L Toggled killstreaks for %L", client, target_list[i]);
		}
		
		ShowActivity2(client, "[SM] ", "Toggled killstreaks for %s", target_name);
	}
	else
	{
		decl String:arg2[68];
		GetCmdArg(2, arg2, sizeof(arg2));
		new temp = StringToInt(arg2, 10);
		for (new i = 0; i < target_count; i++)
		{
			if (temp < 1)
			{
				SetEntProp(target_list[i], Prop_Send, "m_nStreaks", 0);
				IsEnabled[target_list[i]] = false;
				LogAction(client, target_list[i], "%L Disabled killstreaks for %L", client, target_list[i]);
			}
			else
			{
				SetEntProp(target_list[i], Prop_Send, "m_nStreaks", 10);
				IsEnabled[target_list[i]] = true;
				LogAction(client, target_list[i], "%L Enabled killstreaks for %L", client, target_list[i]);
			}
		}
		if (temp < 1)
			ShowActivity2(client, "[SM] ", "Disabled killstreaks for %s", target_name);
		else
			ShowActivity2(client, "[SM] ", "Enabled killstreaks for %s", target_name);
	}
	
	return Plugin_Handled;
}

public Action:Cmd_SetStreak(client, args)
{
	if (args < 2)
	{
		ReplyToCommand(client, "[SM] Usage: sm_setstreak <#userid|name> <ammount>");
		return Plugin_Handled;
	}
	
	decl String:numstr[65];
	decl String:arg[65];
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, numstr, sizeof(numstr));
	new ksnum = StringToInt(numstr);
	
	if(ksnum < 0)
	{
		ReplyToCommand(client, "[SM] Value must be greater than 0");
		return Plugin_Handled;
	}
	
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
		SetEntProp(target_list[i], Prop_Send, "m_nStreaks", ksnum);
		LogAction(client, target_list[i], "%L Set killstreak ammount for %L to %d", client, target_list[i], ksnum);
	}
	
	ShowActivity2(client, "[SM] ", "Set killstreak ammount for %s to %d", target_name, ksnum);
	
	return Plugin_Handled;
}

public OnPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event,"userid"));
	if (client == 0 || IsFakeClient(client))
		return;
	
	if (IsEnabled[client])
		SetEntProp(client, Prop_Send, "m_nStreaks", 10);
}

public Action:Event_PlayerDeath(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event,"userid"));
	
	if (IsEnabled[client])
		SetEventInt(event, "kill_streak_victim", 0);
	
	return Plugin_Continue;
}

public OnClientDisconnect(client)
{
	IsEnabled[client] = false;
}