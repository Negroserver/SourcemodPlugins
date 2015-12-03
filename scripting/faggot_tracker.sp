#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "1.3"

public Plugin:myinfo = {
	name		= "Faggot Tracker",
	author		= "Hurp Durp",
	description	= "Tracks players",
	version		= PLUGIN_VERSION,
	url			= "http://www.negroserver.com"
};

new Handle:hDatabase;

public OnPluginStart()
{
	CreateConVar("sm_faggot_tracker_version", PLUGIN_VERSION, "Faggot Tracker", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	
	RegConsoleCmd("sm_faggot", Command_Faggot, "", 0);
	LoadTranslations("common.phrases");
	
	HookEvent("player_changename", OnNameChange);
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	if(SQL_CheckConfig("name_tracker"))
		hDatabase = SQL_Connect("name_tracker", true, error, err_max);
	
	else
		hDatabase = SQL_Connect("default", true, error, err_max);
	
	if(hDatabase == INVALID_HANDLE)
		return APLRes_Failure;
	
	SQL_TQuery(hDatabase, OnTableCreated, "CREATE TABLE IF NOT EXISTS `name_tracker` (id int(11) NOT NULL AUTO_INCREMENT, tracker_id varchar(32), tracker_name varchar(32), tracker_date varchar(32), PRIMARY KEY (id)) ENGINE=InnoDB  DEFAULT CHARSET=utf8");
	return APLRes_Success;
}

public OnTableCreated(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(hndl == INVALID_HANDLE)
		SetFailState("Unable to create table. %s", error);
}

public Action:Command_Faggot(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_faggot <#userid|name>");
		return Plugin_Handled;
	}
	
	// Get Target
	decl String:arg[MAX_NAME_LENGTH];
	GetCmdArg(1, arg, sizeof(arg));

	decl String:target_name[MAX_TARGET_LENGTH];
	decl target_list[MAXPLAYERS], bool:tn_is_ml;

	if ((ProcessTargetString(
		arg,
		client,
		target_list,
		MAXPLAYERS,
		COMMAND_FILTER_NO_IMMUNITY|COMMAND_FILTER_NO_BOTS|COMMAND_FILTER_NO_MULTI,
		target_name,
		sizeof(target_name),
		tn_is_ml)) <= 0)
	{
		ReplyToCommand(client, "[SM] Player not found");
		return Plugin_Handled;
	}
	
	new target = target_list[0];
	
	// Find Steam ID
	new String:steamId[32];
	GetClientAuthString(target, steamId, sizeof(steamId));
	
	if (!IsClientInGame(target) || IsFakeClient(target))
	{
		PrintToChat(client,"[SM] Player not found");
		return Plugin_Handled;
	}
	
	// Reply to command
	new ReplySource:source = GetCmdReplySource();
	if(source == SM_REPLY_TO_CONSOLE)
		ReplyToCommand(client, "[SM] See menu for output");

	decl String:query[255];
	Format(query, sizeof(query), "SELECT tracker_name, tracker_date FROM name_tracker WHERE tracker_id = '%s' ORDER BY 'id' DESC", steamId);
	
	new uid = GetClientUserId(client);
	SQL_TQuery(hDatabase, T_NamePanel, query, uid);
	
	ShowActivity2(client, "[SM] ","Used faggot tracker on %s", target_name);
	LogAction(client, target, "%L used faggot tracker on %L", client, target);
	
	return Plugin_Handled;
}

public T_NamePanel(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = GetClientOfUserId(data);
	
	if (client == 0)
		return;
	
	if (hndl == INVALID_HANDLE)
		LogError("Query failed! %s", error);
	
	else
	{
		if(IsClientInGame(client))
		{
			new Handle:menu = CreateMenu(T_NamePanelHandler);
			new String:tname[32];
			new String:tdate[32];
			new String:clientname[32];
			
			while(SQL_FetchRow(hndl))
			{
				SQL_FetchString(hndl, 0, tname, sizeof(tname));
				SQL_FetchString(hndl, 1, tdate, sizeof(tdate));
				
				new String:menuline[80];
				Format(menuline, sizeof(menuline), "%s\n    Changed on %s", tname, tdate);
				AddMenuItem(menu, "", menuline);
				
				if(!SQL_MoreRows(hndl))
					SQL_FetchString(hndl, 0, clientname, sizeof(clientname));
			}
			
			SetMenuTitle(menu, "Aliases for %s:", clientname);
			SetMenuPagination(menu, 5);
			SetMenuExitButton(menu, true);
			DisplayMenu(menu, client, MENU_TIME_FOREVER);
		}
	}
}

public T_NamePanelHandler(Handle:menu, MenuAction:action, client, param2)
{
	if (action == MenuAction_End)
		CloseHandle(menu);
}

public OnClientAuthorized(client, const String:sid[])
{
	if(IsFakeClient(client))
		return;
	
	CheckName(sid, client);
}

public Action:OnNameChange(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (!IsClientInGame(client) || IsFakeClient(client))
		return Plugin_Continue;
	
	// Get steamid
	decl String:sid[32];
	GetClientAuthString(client, sid, sizeof(sid));
	
	decl String:newname[32];
	GetEventString(event, "newname", newname, sizeof(newname));
	
	AddNameChanged(sid, newname);
	
	return Plugin_Continue;
}

AddName(userid)
{
	new client = GetClientOfUserId(userid);
	
	if (!client)
		return;
	
	// Get name
	decl String:name[32];
	GetClientName(client, name, sizeof(name));
	
	// Format name for database
	decl String:buff[65];
	SQL_EscapeString(hDatabase, name, buff, sizeof(buff));

	// Get steamid
	decl String:sid[32];
	GetClientAuthString(client, sid, sizeof(sid));
	
	decl String:date[64];
	FormatTime(date, sizeof(date), "%Y-%m-%d");
	
	decl String:query[255];
	Format(query, sizeof(query), "INSERT INTO `name_tracker` SET tracker_id = '%s', tracker_name = '%s', tracker_date = '%s'", sid, buff, date);
	SQL_TQuery(hDatabase, OnRowInserted, "SET NAMES 'utf8'");
	SQL_TQuery(hDatabase, OnRowInserted, query);
}

AddNameChanged(String:sid[], String:name[])
{	
	decl String:date[64];
	FormatTime(date, sizeof(date), "%Y-%m-%d");
	
	// Format name for database
	decl String:buff[65];
	SQL_EscapeString(hDatabase, name, buff, sizeof(buff));
	
	decl String:query[255];
	Format(query, sizeof(query), "INSERT INTO `name_tracker` SET tracker_id = '%s', tracker_name = '%s', tracker_date = '%s'", sid, buff, date);
	SQL_TQuery(hDatabase, OnRowInserted, "SET NAMES 'utf8'");
	SQL_TQuery(hDatabase, OnRowInserted, query);
}

CheckName(const String:sid[], client)
{
	decl String:query[255];
	new uid = GetClientUserId(client);
	
	Format(query, sizeof(query), "SELECT tracker_name FROM name_tracker WHERE tracker_id = '%s' ORDER BY 'id' DESC LIMIT 1", sid);
	SQL_TQuery(hDatabase, T_CheckName, query, uid);
}
 
public T_CheckName(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = GetClientOfUserId(data);
	
	if (hndl == INVALID_HANDLE)
		LogError("Query failed! %s", error);
	
	else if (IsClientConnected(client) && IsClientInGame(client))
	{
		decl String:name[32];
		GetClientName(client, name, sizeof(name));
	
		decl String:buff[65];
		SQL_EscapeString(hDatabase, name, buff, sizeof(buff));
		
		decl String:oldname[40];
		SQL_FetchString(hndl, 0, oldname, sizeof(oldname));
		
		if (!StrEqual(buff, oldname))
			AddName(data);
	}
}

public OnRowInserted(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(hndl == INVALID_HANDLE)
	{
		LogError("Unable to insert row %s", error);
		return;
	}
}