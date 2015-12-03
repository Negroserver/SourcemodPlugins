#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <clientprefs>
#include <scp>

#define VERSION "1.5"

public Plugin:myinfo =
{
	name = "Play Time Rating",
	author = "Hurp Durp",
	description = "Player time rating",
	version = VERSION,
	url = "http://negroserver.com"
}

new Handle:hDatabase;
new PlayTime[MAXPLAYERS+1];

/** Client Prefs **/
new bool:g_bClientPreferenceColorText[MAXPLAYERS+1];
new Handle:g_hClientCookie;

public OnPluginStart()
{
	CreateConVar("playrating_version", VERSION, "Playtime Rating Version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	
	RegConsoleCmd("sm_rate", Command_Rate, "", 0);
	
	g_hClientCookie = RegClientCookie("PTRChatText", "Playtime rank colored chat", CookieAccess_Private);
	
	LoadTranslations("common.phrases");
	
	/** Late Load **/
	for(new i = 1; i<=MaxClients ; i++)
	{
		if(0 < i <= MaxClients && IsClientConnected(i) && IsClientInGame(i))
		{
			new String:steamid[32];
			GetClientAuthString(i, steamid, sizeof(steamid));
	
			decl String:query[255];
			Format(query, sizeof(query), "SELECT SUM(duration) AS duration FROM `player_analytics` WHERE connect_date BETWEEN DATE_FORMAT(NOW() - INTERVAL 7 DAY, '%%Y-%%m-%%d') AND DATE_FORMAT(NOW(), '%%Y-%%m-%%d') AND auth='%s' AND DURATION IS NOT NULL", steamid);
			SQL_TQuery(hDatabase, T_HoursCheck, query, i);
		}
		
		if (!AreClientCookiesCached(i) || IsFakeClient(i))
		{
			continue;
		}
		
		OnClientCookiesCached(i);
	}
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	if(SQL_CheckConfig("player_analytics"))
		hDatabase = SQL_Connect("player_analytics", true, error, err_max);
	
	else
		hDatabase = SQL_Connect("default", true, error, err_max);
	
	if(hDatabase == INVALID_HANDLE)
		return APLRes_Failure;
	
	return APLRes_Success;
}

public OnClientCookiesCached(client)
{
	decl String:sValue[8];
	GetClientCookie(client, g_hClientCookie, sValue, sizeof(sValue));
	
	g_bClientPreferenceColorText[client] = (sValue[0] != '\0' && StringToInt(sValue));
}

public OnClientPostAdminFilter(client)
{
	if (!IsClientInGame(client))
		return;
	
	new String:steamid[32];
	GetClientAuthString(client, steamid, sizeof(steamid));
	
	decl String:query[255];
	Format(query, sizeof(query), "SELECT SUM(duration) AS duration FROM `player_analytics` WHERE connect_date BETWEEN DATE_FORMAT(NOW() - INTERVAL 7 DAY, '%%Y-%%m-%%d') AND DATE_FORMAT(NOW(), '%%Y-%%m-%%d') AND auth='%s' AND DURATION IS NOT NULL", steamid);
	SQL_TQuery(hDatabase, T_HoursCheck, query, client);
}

public T_HoursCheck(Handle:owner, Handle:hndl, const String:error[], any:client)
{	
	if (client == 0 || !IsClientInGame(client))
		return;
	
	if (hndl == INVALID_HANDLE)
		LogError("Query failed! %s", error);
	
	else
	{
		SQL_FetchRow(hndl);
		new time = SQL_FetchInt(hndl, 0);
		PlayTime[client] = time;
		
		if (time >= 54000)
		{
			AddUserFlags(client, Admin_Custom1);
			AddUserFlags(client, Admin_Custom2);
			AddUserFlags(client, Admin_Custom3);
		}
		else if (time >= 36000)
		{
			AddUserFlags(client, Admin_Custom1);
			AddUserFlags(client, Admin_Custom2);
		}
		else if (time >= 18000)
			AddUserFlags(client, Admin_Custom1);
	}
}

public Action:Command_Rate(client, args)
{
	new target;
	
	if (args > 0)
	{
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
		
		target = target_list[0];
	}
	else
		target = client;
	
	
	if(IsClientInGame(client))
	{
		new time = PlayTime[target];
		
		/** Draw a menu with information about the player **/
		new Handle:menu = CreateMenu(T_RatingPanelHandler);
		
		new String:name[MAX_NAME_LENGTH];
		GetClientName(target, name, sizeof(name));
		SetMenuTitle(menu, "Rating for %s", name);
		
		/** Get the playtime this week **/
		new timehour = RoundToFloor(float(time) / 60.0 / 60.0);
		new Float:timemin = float(time) / 60.0 - float(timehour) * 60.0;
		
		new String:menuline[80];
		Format(menuline, sizeof(menuline), "Playtime this week: %d hours %.0f mins", timehour, timemin);
		AddMenuItem(menu, "", menuline);
		
		/** Compute rating **/
		new Float:hourpercent = float(time) / 54000.0  * 100.0;
		
		if (time >= 54000)
			Format(menuline, sizeof(menuline), "Rating: ★★★★★\n    %.0f%%\n ", hourpercent);
		else if (time >= 45000)
			Format(menuline, sizeof(menuline), "Rating: ★★★★☆\n    %.0f%%\n ", hourpercent);
		else if (time >= 36000)
			Format(menuline, sizeof(menuline), "Rating: ★★★★\n    %.0f%%\n ", hourpercent);
		else if (time >= 27000)
			Format(menuline, sizeof(menuline), "Rating: ★★★☆\n    %.0f%%\n ", hourpercent);
		else if (time >= 18000)
			Format(menuline, sizeof(menuline), "Rating: ★★★\n    %.0f%%\n ", hourpercent);
		else if (time >= 13500)
			Format(menuline, sizeof(menuline), "Rating: ★★☆\n    %.0f%%\n ", hourpercent);
		else if (time >= 9000)
			Format(menuline, sizeof(menuline), "Rating: ★★\n    %.0f%%\n ", hourpercent);
		else if (time >= 6750)
			Format(menuline, sizeof(menuline), "Rating: ★☆\n    %.0f%%\n ", hourpercent);
		else if (time >= 4500)
			Format(menuline, sizeof(menuline), "Rating: ★\n    %.0f%%\n ", hourpercent);
		else
			Format(menuline, sizeof(menuline), "Rating: ☆\n    %.0f%%\n ", hourpercent);
		AddMenuItem(menu, "", menuline);
		
		AddMenuItem(menu, "", "Help");
		
		if (target == client)
			if (g_bClientPreferenceColorText[client])
				AddMenuItem(menu, "", "Enable Chat Message Color");
			else
				AddMenuItem(menu, "", "Disable Chat Message Color");
		
		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	}
	
	return Plugin_Handled;
}

public T_RatingPanelHandler(Handle:menu, MenuAction:action, client, param2)
{
	if (action == MenuAction_End)
		CloseHandle(menu);
	
	if (action == MenuAction_Select)
	{
		if (param2 == 2)
			HelpPanel(client, menu);
		
		else if (param2 == 3)
		{
			if (g_bClientPreferenceColorText[client])
			{
				SetClientCookie(client, g_hClientCookie, "0");
				g_bClientPreferenceColorText[client] = false;
			}
			else
			{
				SetClientCookie(client, g_hClientCookie, "1");
				g_bClientPreferenceColorText[client] = true;
			}
		}
	}
}

public Action:HelpPanel(client, Handle:menu)
{
	new Handle:hpanel = CreatePanel();
	DrawPanelText(hpanel, "\n Spending time on our servers unlocks commands that you can use.\n \n There are 3 milestones:\n   5 Hours\n   10 Hours\n   15 Hours\n \n For a list of the perks you receive, type !perks in chat.\n ");
	DrawPanelItem(hpanel, "Close");
	SendPanelToClient(hpanel, client, T_HelpPanelHandler, MENU_TIME_FOREVER);
}

public T_HelpPanelHandler(Handle:menu, MenuAction:action, client, param2)
{
}

public OnClientDisconnect(client)
{
	RemoveUserFlags(client, Admin_Custom1);
	RemoveUserFlags(client, Admin_Custom2);
	RemoveUserFlags(client, Admin_Custom3);
}

/** Chat Colors **/
public Action:OnChatMessage(&author, Handle:recipients, String:name[], String:message[])
{
	/*
	 ** 15h Color: #00FFFF (Light Blue)
	 ** 10h Color: #66FF00 (Light Green)
	 **  5h Color: #FFCCFF (Light Purple)
	*/
	
	new MaxMessageLength = MAXLENGTH_MESSAGE - strlen(name) - 5;
	
	if(PlayTime[author] >= 54000 && !g_bClientPreferenceColorText[author])
	{
		Format(message, MaxMessageLength, "\x07%s%s", "00FFFF", message);
	}
	else if(PlayTime[author] >= 36000 && !g_bClientPreferenceColorText[author])
	{
		Format(message, MaxMessageLength, "\x07%s%s", "66FF00", message);
	}
	else if(PlayTime[author] >= 18000 && !g_bClientPreferenceColorText[author])
	{
		Format(message, MaxMessageLength, "\x07%s%s", "FFCCFF", message);
	}
	
	//LogMessage("MessageFlags: %d", GetMessageFlags());
	/*
	if (GetMessageFlags() == 9)
	{
		new authorteam = GetClientTeam(author);
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && GetClientTeam(i) != authorteam)
				PushArrayCell(recipients, i);
		}
	}
	*/
	return Plugin_Changed;
}

stock bool:IsValidClient(client)
{
    if (client >= 0 || client > MaxClients || !IsClientConnected(client) || IsFakeClient(client))
        return false;
	
    return IsClientInGame(client);
}