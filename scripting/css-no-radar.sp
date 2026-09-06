#include <sourcemod>
#pragma newdecls required

public Plugin myinfo = {
    name = "CSS Hide Radar",
    author = "Eric Zhang",
    description = "Hides the radar in CSS. Portions from the unfinished CSSDM port to SourcePawn.",
    version = "1.0",
    url = "https://ericaftereric.top"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
    char game[128];
    GetGameFolderName(game, sizeof(game));
    if (!StrEqual(game, "cstrike", false)) {
        strcopy(error, err_max, "This plugin only works on Counter-Strike: Source");
        return APLRes_SilentFailure;
    }
    return APLRes_Success;
}

public void OnPluginStart() {
    HookEvent("player_blind", Event_PlayerBlind);
    HookEvent("player_spawn", Event_PlayerSpawn);
}

public void Event_PlayerBlind(Event event, const char[] name, bool dontBroadcast) {
    int userid = event.GetInt("userid");
    int client = GetClientOfUserId(userid);

    if (client > 0 && IsClientInGame(client) && !IsClientObserver(client)) {
        float duration = GetEntPropFloat(client, Prop_Send, "m_flFlashDuration");
        CreateTimer(duration, Timer_FlashEnd, userid, TIMER_FLAG_NO_MAPCHANGE);
    }
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
    int userid = event.GetInt("userid");
    // delay a bit before we hide the radar
    CreateTimer(0.1, Timer_FlashEnd, userid, TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_FlashEnd(Handle timer, int userid) {
    int client = GetClientOfUserId(userid);

    if (client > 0 && IsClientInGame(client) && !IsClientObserver(client)) {
        HideRadar(client);
    }
    return Plugin_Continue;
}

void HideRadar(int client) {
    SetEntPropFloat(client, Prop_Send, "m_flFlashDuration", 3600.0);
    SetEntPropFloat(client, Prop_Send, "m_flFlashMaxAlpha", 0.5);
}
