#include <sourcemod>
#include <sdktools>
#include <tf2_stocks>
#include <smlib>
#include <tf2items>
#include <tNoUnlocksPls>

new const DEFIDX_ATOMIZER = 450;
new const DEFIDX_SANDMAN = 44;
new const DEFIDX_WRAPASSASSIN = 648
new const DEFIDX_DISIPLINARYACTION = 447;
new const DEFIDX_POWERJACK = 214;
new const DEFIDX_CABER = 307;
new const DEFIDX_GRU = 239;
new const DEFIDX_GUNSLINGER = 142;
new const DEFIDX_BASHER = 325;
new const DEFIDX_SWORD = 452;
new const DEFIDX_PHLOG = 594;
new const DEFIDX_EFFECT = 589;
new const DEFIDX_AMPUTATOR = 304;
new const DEFIDX_EYELANDER = 132;
new const DEFIDX_HHHH = 266;
new const DEFIDX_IRON = 482;
new const DEFIDX_RAINBLOWER = 741;

new bool:deathrun = false;
new bool:dodgeball = false;
new bool:szf = false;

public Plugin:myinfo =
{
	name = "Negroserver MultiMod Plugin",
	author = "Hurp Durp",
	description = "Blocks crap and execs configs",
	version = "1.0",
	url = "http://negroserver.com"
};

public OnPluginStart()
{
    HookEvent("post_inventory_application", OnPostInventoryApplication);
}

public OnMapStart()
{
	decl String:mapname[128];
	GetCurrentMap(mapname, sizeof(mapname));
  
	if (strncmp(mapname, "dr_", 3, false) == 0 || (strncmp(mapname, "deathrun_", 9, false) == 0) || (strncmp(mapname, "vsh_dr", 6, false) == 0))
	{
		ServerCommand("exec deathrun");
		deathrun = true;
		szf = false;
		dodgeball = false;
	}
	else if(strncmp(mapname, "tfdb_", 5, false) == 0 || strncmp(mapname, "dodgeball_", 10, false) == 0)
	{
		ServerCommand("exec dodgeball");
		deathrun = false;
		szf = false;
		dodgeball = true;
	}
	else if (strncmp(mapname, "szf_", 4, false) == 0)
	{
		ServerCommand("exec szf");
		deathrun = false;
		szf = true;
		dodgeball = false;
	}
	else if (strncmp(mapname, "zf_", 3, false) == 0)
	{
		ServerCommand("exec zf");
		deathrun = false;
		szf = false;
		dodgeball = false;
	}
	else if (strncmp(mapname, "ph_", 3, false) == 0 || strncmp(mapname, "prophunt_", 9, false) == 0 || strncmp(mapname, "arena_brawl", 11, false) == 0 || strncmp(mapname, "arena_concord", 13, false) == 0 || strncmp(mapname, "arena_desolation", 16, false) == 0 || strncmp(mapname, "arena_farm_feud", 15, false) == 0 || strncmp(mapname, "arena_harvest_v2", 16, false) == 0 || strncmp(mapname, "arena_ravage", 12, false) == 0 || strncmp(mapname, "arena_storm", 11, false) == 0)
	{
		ServerCommand("exec prophunt");
		deathrun = false;
		szf = false;
		dodgeball = false;
	}
	else if (strncmp(mapname, "arena_", 6, false) == 0 || strncmp(mapname, "koth_", 5, false) == 0)
	{
		ServerCommand("exec randomizer");
		deathrun = false;
		szf = false;
		dodgeball = false;
	}
}
	
public OnPostInventoryApplication(Handle:hEvent, const String:szName[], bool:bDontBroadcast)
{
	if (deathrun)
	{
		new client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
		new weaponMelee = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
		
		TF2_RemoveWeaponSlot(client, 0);
		TF2_RemoveWeaponSlot(client, 1);
		TF2_RemoveWeaponSlot(client, 3);
		TF2_RemoveWeaponSlot(client, 4);
		
		if (weaponMelee != INVALID_ENT_REFERENCE && GetEntProp(weaponMelee, Prop_Send, "m_iItemDefinitionIndex") == DEFIDX_ATOMIZER)
		{
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
			GiveReplacementItem(client, DEFIDX_ATOMIZER);
			ChangePlayerWeaponSlot(client, 2);
			return;
		}
		
		else if (weaponMelee != INVALID_ENT_REFERENCE && GetEntProp(weaponMelee, Prop_Send, "m_iItemDefinitionIndex") == DEFIDX_SANDMAN)
		{
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
			GiveReplacementItem(client, DEFIDX_SANDMAN);
			ChangePlayerWeaponSlot(client, 2);
			return;
		}
		
		else if (weaponMelee != INVALID_ENT_REFERENCE && GetEntProp(weaponMelee, Prop_Send, "m_iItemDefinitionIndex") == DEFIDX_BASHER)
		{
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
			GiveReplacementItem(client, DEFIDX_BASHER);
			ChangePlayerWeaponSlot(client, 2);
			return;
		}
		
		else if (weaponMelee != INVALID_ENT_REFERENCE && GetEntProp(weaponMelee, Prop_Send, "m_iItemDefinitionIndex") == DEFIDX_SWORD)
		{
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
			GiveReplacementItem(client, DEFIDX_SWORD);
			ChangePlayerWeaponSlot(client, 2);
			return;
		}
		
		else if (weaponMelee != INVALID_ENT_REFERENCE && GetEntProp(weaponMelee, Prop_Send, "m_iItemDefinitionIndex") == DEFIDX_WRAPASSASSIN)
		{
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
			GiveReplacementItem(client, DEFIDX_WRAPASSASSIN);
			ChangePlayerWeaponSlot(client, 2);
			return;
		}
		
		else if (weaponMelee != INVALID_ENT_REFERENCE && GetEntProp(weaponMelee, Prop_Send, "m_iItemDefinitionIndex") == DEFIDX_DISIPLINARYACTION)
		{
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
			GiveReplacementItem(client, DEFIDX_DISIPLINARYACTION);
			ChangePlayerWeaponSlot(client, 2);
			return;
		}
		
		else if (weaponMelee != INVALID_ENT_REFERENCE && GetEntProp(weaponMelee, Prop_Send, "m_iItemDefinitionIndex") == DEFIDX_POWERJACK)
		{
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
			GiveReplacementItem(client, DEFIDX_POWERJACK);
			ChangePlayerWeaponSlot(client, 2);
			return;
		}
		
		else if (weaponMelee != INVALID_ENT_REFERENCE && GetEntProp(weaponMelee, Prop_Send, "m_iItemDefinitionIndex") == DEFIDX_CABER)
		{
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
			GiveReplacementItem(client, DEFIDX_CABER);
			ChangePlayerWeaponSlot(client, 2);
			return;
		}
		
		else if (weaponMelee != INVALID_ENT_REFERENCE && GetEntProp(weaponMelee, Prop_Send, "m_iItemDefinitionIndex") == DEFIDX_GRU)
		{
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
			GiveReplacementItem(client, DEFIDX_GRU);
			ChangePlayerWeaponSlot(client, 2);
			return;
		}
		
		else if (weaponMelee != INVALID_ENT_REFERENCE && GetEntProp(weaponMelee, Prop_Send, "m_iItemDefinitionIndex") == DEFIDX_EFFECT)
		{
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
			GiveReplacementItem(client, DEFIDX_EFFECT);
			ChangePlayerWeaponSlot(client, 2);
			return;
		}
		
		ChangePlayerWeaponSlot(client, 2);
	}
	
	else if (szf)
	{
		new client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
		new weaponMelee = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);

		if (weaponMelee != INVALID_ENT_REFERENCE && GetEntProp(weaponMelee, Prop_Send, "m_iItemDefinitionIndex") == DEFIDX_GUNSLINGER)
		{
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
			GiveReplacementItem(client, DEFIDX_GUNSLINGER);
			ChangePlayerWeaponSlot(client, 2);
			return;
		}
		
		else if (weaponMelee != INVALID_ENT_REFERENCE && GetEntProp(weaponMelee, Prop_Send, "m_iItemDefinitionIndex") == DEFIDX_POWERJACK)
		{
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
			GiveReplacementItem(client, DEFIDX_POWERJACK);
			ChangePlayerWeaponSlot(client, 2);
			return;
		}
		
		else if (weaponMelee != INVALID_ENT_REFERENCE && GetEntProp(weaponMelee, Prop_Send, "m_iItemDefinitionIndex") == DEFIDX_AMPUTATOR)
		{
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
			GiveReplacementItem(client, DEFIDX_AMPUTATOR);
			ChangePlayerWeaponSlot(client, 2);
			return;
		}
		
		else if (weaponMelee != INVALID_ENT_REFERENCE && GetEntProp(weaponMelee, Prop_Send, "m_iItemDefinitionIndex") == DEFIDX_EFFECT)
		{
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
			GiveReplacementItem(client, DEFIDX_EFFECT);
			ChangePlayerWeaponSlot(client, 2);
			return;
		}
		
		else if (weaponMelee != INVALID_ENT_REFERENCE && GetEntProp(weaponMelee, Prop_Send, "m_iItemDefinitionIndex") == DEFIDX_EYELANDER)
		{
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
			GiveReplacementItem(client, DEFIDX_EYELANDER);
			ChangePlayerWeaponSlot(client, 2);
			return;
		}
		
		else if (weaponMelee != INVALID_ENT_REFERENCE && GetEntProp(weaponMelee, Prop_Send, "m_iItemDefinitionIndex") == DEFIDX_HHHH)
		{
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
			GiveReplacementItem(client, DEFIDX_HHHH);
			ChangePlayerWeaponSlot(client, 2);
			return;
		}
		
		else if (weaponMelee != INVALID_ENT_REFERENCE && GetEntProp(weaponMelee, Prop_Send, "m_iItemDefinitionIndex") == DEFIDX_IRON)
		{
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
			GiveReplacementItem(client, DEFIDX_IRON);
			ChangePlayerWeaponSlot(client, 2);
			return;
		}
		
		new ent = -1;
		while ((ent = FindEntityByClassname(ent, "tf_wearable_demoshield")) != -1)
		{
			AcceptEntityInput(ent, "kill");
		}
	}
	
	else if (dodgeball)
	{
		new client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
		new weaponPrimary = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);

		if (weaponPrimary != INVALID_ENT_REFERENCE && GetEntProp(weaponPrimary, Prop_Send, "m_iItemDefinitionIndex") == DEFIDX_PHLOG)
		{
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
			GiveReplacementItem(client, DEFIDX_PHLOG);
			ChangePlayerWeaponSlot(client, 0);
			return;
		}
		
		else if (weaponPrimary != INVALID_ENT_REFERENCE && GetEntProp(weaponPrimary, Prop_Send, "m_iItemDefinitionIndex") == DEFIDX_RAINBLOWER)
		{
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
			GiveReplacementItem(client, DEFIDX_RAINBLOWER);
			ChangePlayerWeaponSlot(client, 0);
			return;
		}
	}
}

public GiveReplacementItem(client, iItemDefinitionIndex)
{
	new iSlot = tNUP_GetWeaponSlotByIDI(iItemDefinitionIndex);
	new String:sWeaponClassName[128];
	if(tNUP_GetDefaultWeaponForClass(TF2_GetPlayerClass(client), iSlot, sWeaponClassName, sizeof(sWeaponClassName))) {
		new iOverrideIDI = tNUP_GetDefaultIDIForClass(TF2_GetPlayerClass(client), iSlot);

		new Handle:hItem = TF2Items_CreateItem(OVERRIDE_CLASSNAME | OVERRIDE_ITEM_DEF | OVERRIDE_ITEM_LEVEL | OVERRIDE_ITEM_QUALITY | OVERRIDE_ATTRIBUTES);
		TF2Items_SetClassname(hItem, sWeaponClassName);
		TF2Items_SetItemIndex(hItem, iOverrideIDI);
		TF2Items_SetLevel(hItem, 1);
		TF2Items_SetQuality(hItem, 6);
		TF2Items_SetNumAttributes(hItem, 0);

		new iWeapon = TF2Items_GiveNamedItem(client, hItem);
		CloseHandle(hItem);

		EquipPlayerWeapon(client, iWeapon);
	}
}

stock ChangePlayerWeaponSlot(iClient, iSlot)
{
	new iWeapon = GetPlayerWeaponSlot(iClient, iSlot);
	if (iWeapon > MaxClients)
	{
		SetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon", iWeapon);
	}
}  