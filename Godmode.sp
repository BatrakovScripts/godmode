#include <sourcemod>
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//*
//*                 AntiSpawnKill
//*                 Status: beta
//*					Автор релиза Alexander_Mirny
//*
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 
ConVar on;
 
static TimerOn[MAXPLAYERS];
static bool:TimerClosed[MAXPLAYERS];
static bool:AFK[MAXPLAYERS];
Handle SpawnTimer[MAXPLAYERS];
Handle AntiSpawnTimer[MAXPLAYERS];
 
 
public OnPluginStart()
{
	on = CreateConVar("god_spawn", "1", "Активация плагина (1 - Включен, 0 - Выключен)", FCVAR_NOTIFY);
	if(GetConVarInt(on) == 1)
	{
		HookEvent("player_first_spawn", OnPlayerFirstSpawn, EventHookMode_Pre);
		HookEvent("player_spawn", OnPlayerSpawn);
		HookEvent("player_disconnect", OnPlayerDisconnect, EventHookMode_Post);
		CreateTimer (3.0 , SecServ,_, TIMER_REPEAT)
	}	
}

public Action SecServ(Handle timer)
{
	for (new i = 1; i <= GetMaxClients(); i++)
	{
		if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2)
		{
			if(IsClientConnected(i))
			{
				if(TimerClosed[i] == true)
				{
					if(TimerOn[i])
					{
						TimerOn[i]--;
						PrintHintText(i, "AntiSpawnKill: %d", TimerOn[i]);
	 
					}
					if(TimerOn[i] == 0)
					{
						TimerClosed[i] = false;
						AFK[i] = false;
						SetEntProp(i, Prop_Data, "m_takedamage", 2, 1);
						PrintToChat(i,"\x05[AntiSpawnKill] \x04Отключен.");	
					}
				}
			}
		}
	}
}
	
public OnMapStart()
{
	for (new i = 1; i <= GetMaxClients(); i++)
	{
		AFK[i] = true;
	}
}

public OnPlayerDisconnect(Handle:hEvent, const String:sEventName[], bool:bDontBroadcast) 
{
	new client  = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if (!client) return;
	AFK[client] = false;	
}
public OnPlayerFirstSpawn(Handle:hEvent, const String:sEventName[], bool:bDontBroadcast) AFK[GetEventInt(hEvent, "userid")] = true;
//
public OnPlayerSpawn(Handle:hEvent, const String:sEventName[], bool:bDontBroadcast) 
{
	new client  = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if (IsClientConnected(client))
	{
		if (IsClientInGame(client))
		{
			if (!IsFakeClient(client))
			{	
				if(AFK[client] == true)
				{
					SpawnTimer[client] = CreateTimer(0.3, Spawn, client, TIMER_FLAG_NO_MAPCHANGE);
				}
			}
		}
	}
}

public Action:Spawn(Handle Timer, any:client)
{
	if(SpawnTimer[client])
	{	
		KillTimer(SpawnTimer[client]);
		SpawnTimer[client] = null;
	}
	AntiSpawnTimer[client] = CreateTimer(10.0, AntiSpawnKill, client, TIMER_FLAG_NO_MAPCHANGE);
}

public Action:AntiSpawnKill(Handle Timer, any:client)
{
	if(IsValidEntity(client))
	{
		if(AntiSpawnTimer[client])
		{ 
			KillTimer(AntiSpawnTimer[client]);
			AntiSpawnTimer[client] = null;
			TimerOn[client] = 10;
			TimerClosed[client] = true;
			SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
			PrintToChat(client,"\x05[AntiSpawnKill] \x04Защита включена, вас не убить 10 секунд."); return Plugin_Continue;
		}
	}
	return Plugin_Continue;
}		