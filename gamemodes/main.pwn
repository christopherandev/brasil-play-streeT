#define MAX_PLAYERS     (50)
#define MAX_NPCS        (2)

#define CGEN_MEMORY     20000

#define ON_DEBUG_MODE

#include <open.mp>
#include <sscanf2>
#include <streamer>
#include <samp_bcrypt>
#include <PawnPlus>
#include <discord-connector>
#include <requests>

#include <YSI/YSI_Data/y_iterate>
#include <YSI/YSI_Coding/y_va>
#include <YSI/YSI_Coding/y_inline>
#include <YSI/YSI_Extra/y_inline_timers>
#include <YSI/YSI_Visual/y_commands>
#include <YSI/YSI_Visual/y_dialog>
#include <YSI/YSI_Coding/y_hooks>

#include "./gamemodes/modules/__globals/headers.pwn"
#include "./gamemodes/modules/__globals/cores.pwn"
#include "./gamemodes/modules/__globals/handles.pwn"
#include "./gamemodes/modules/__globals/commands.pwn"

#define TIKTOK_BRIDGE_ENDPOINT     "http://127.0.0.1:3001"
#define TIKTOK_BRIDGE_POLL_PATH    "/events"
#define TIKTOK_BRIDGE_HEALTH_PATH  "/health"
#define TIKTOK_BRIDGE_POLL_MS      (1000)

static RequestsClient:g_tiktokBridge = RequestsClient:-1;
static bool:g_tiktokBridgeReady = false;
static Request:g_tiktokBridgeActiveRequest = Request:-1;

forward TikTokBridgePoll();
forward OnTikTokBridgeHealth(Request:id, E_HTTP_STATUS:status, Node:node);
forward OnTikTokBridgeEvents(Request:id, E_HTTP_STATUS:status, Node:node);

stock bool:TikTokBridge_IsReady()
{
    return IsValidRequestsClient(g_tiktokBridge) && g_tiktokBridgeReady;
}

stock TikTokBridge_Init()
{
    g_tiktokBridge = RequestsClient(TIKTOK_BRIDGE_ENDPOINT);

    if(!IsValidRequestsClient(g_tiktokBridge))
    {
        printf("[ TIKTOK ] Falha ao criar RequestsClient para %s", TIKTOK_BRIDGE_ENDPOINT);
        return 0;
    }

    printf("[ TIKTOK ] RequestsClient conectado em %s", TIKTOK_BRIDGE_ENDPOINT);

    new const Request:healthRequest = RequestJSON(g_tiktokBridge, TIKTOK_BRIDGE_HEALTH_PATH, HTTP_METHOD_GET, "OnTikTokBridgeHealth");
    if(!IsValidRequest(healthRequest))
    {
        printf("[ TIKTOK ] Falha ao enviar requisicao de healthcheck");
        return 0;
    }

    return 1;
}

stock TikTokBridge_PollStart()
{
    SetTimer("TikTokBridgePoll", TIKTOK_BRIDGE_POLL_MS, true);
    printf("[ TIKTOK ] Poll de eventos iniciado a cada %dms", TIKTOK_BRIDGE_POLL_MS);
    return 1;
}

public TikTokBridgePoll()
{
    if(!TikTokBridge_IsReady()) return 1;
    if(IsValidRequest(g_tiktokBridgeActiveRequest)) return 1;

    g_tiktokBridgeActiveRequest = RequestJSON(g_tiktokBridge, TIKTOK_BRIDGE_POLL_PATH, HTTP_METHOD_GET, "OnTikTokBridgeEvents");

    if(!IsValidRequest(g_tiktokBridgeActiveRequest))
    {
        printf("[ TIKTOK ] Falha ao solicitar fila de eventos");
        g_tiktokBridgeActiveRequest = Request:-1;
    }

    return 1;
}

stock TikTokBridge_ProcessEvent(Node:eventNode)
{
    new eventType[24], uniqueId[64], nickname[64], message[192], giftName[64], repeatCount;
    JsonGetString(eventNode, "type", eventType);
    JsonGetString(eventNode, "id", uniqueId);
    JsonGetString(eventNode, "nickname", nickname);
    JsonGetString(eventNode, "message", message);
    JsonGetString(eventNode, "giftName", giftName);
    JsonGetInt(eventNode, "repeatCount", repeatCount);

    if(!strcmp(eventType, "chat"))
    {
        printf("[ TIKTOK CHAT ] #%s | %s: %s", uniqueId, nickname, message);
    }
    else if(!strcmp(eventType, "gift"))
    {
        if(repeatCount < 1) repeatCount = 1;
        printf("[ TIKTOK GIFT ] #%s | %s enviou %s x%d", uniqueId, nickname, giftName, repeatCount);
    }
    else
    {
        printf("[ TIKTOK EVENT ] #%s | tipo=%s | usuario=%s", uniqueId, eventType, nickname);
    }

    return 1;
}

public OnTikTokBridgeHealth(Request:id, E_HTTP_STATUS:status, Node:node)
{
    if(status != HTTP_STATUS_OK)
    {
        printf("[ TIKTOK ] Healthcheck retornou status HTTP %d", _:status);
        return 1;
    }

    new bool:ok;
    JsonGetBool(node, "ok", ok);
    if(!ok)
    {
        printf("[ TIKTOK ] Bridge respondeu healthcheck com erro logico");
        return 1;
    }

    g_tiktokBridgeReady = true;
    printf("[ TIKTOK ] Bridge online e pronta para receber eventos");
    return 1;
}

public OnTikTokBridgeEvents(Request:id, E_HTTP_STATUS:status, Node:node)
{
    g_tiktokBridgeActiveRequest = Request:-1;

    if(status != HTTP_STATUS_OK)
    {
        printf("[ TIKTOK ] /events retornou status HTTP %d", _:status);
        return 1;
    }

    new Node:eventsArray;
    if(!JsonGetArray(node, "events", eventsArray)) return 1;

    new length;
    JsonArrayLength(eventsArray, length);

    for(new i = 0; i < length; i++)
    {
        new Node:eventNode;
        if(!JsonArrayObject(eventsArray, i, eventNode))
        {
            TikTokBridge_ProcessEvent(eventNode);
        }
    }

    return 1;
}

public OnRequestFailure(Request:id, errorCode, errorMessage[], len)
{
    if(id == g_tiktokBridgeActiveRequest)
    {
        g_tiktokBridgeActiveRequest = Request:-1;
    }

    printf("[ TIKTOK ] OnRequestFailure: request=%d code=%d msg=%s", _:id, errorCode, errorMessage);
    return 1;
}

main()
{
    pp_use_funcidx(true);
}

public pp_on_error(source[], message[], error_level:level, &retval)
{
    printf("[ PawnPlus ] %s | nivel: %d | %s", source, _:level, message);
    return 0;
}

public OnGameModeExit()
{
	if(DB_Close(db_entity)) db_entity = DB:0;

    printf("[ DATABASE ] Conexao com o banco de dados de ENTIDADES encerrada com sucesso!\n");

    if(DB_Close(db_stock)) db_stock = DB:0;

    printf("[ DATABASE ] Conexao com o banco de dados de ESTOQUES encerrada com suceso!\n");

    new count;

    for(new regionid = 0; regionid < REGION_COUNT; regionid++)
    {
        if(linked_list_valid(veh::Region[regionid])) linked_list_delete(veh::Region[regionid]);
        if(linked_list_valid(pyr::Region[regionid])) linked_list_delete(pyr::Region[regionid]);

        count++;
    }

    list_delete(AdminList);
    printf("[ LISTAS ] Lista de Admins deletada com sucesso!\n");

    printf("[  AREAS  ] %d areas globais foram destruídas com sucesso\n", count);
    printf("[ REGIONS ] %d regioes de jogadores foram deletadas com sucesso\n", count);
    printf("[ REGIONS ] %d regioes de veículos foram deletadas com sucesso\n", count);

    DestroyAllDynamic3DTextLabels();
    DestroyAllDynamicPickups();
    DestroyAllDynamicObjects();
    DestroyAllDynamicAreas();

    return 1;
}

hook OnGameModeInit()
{
    TikTokBridge_Init();
    TikTokBridge_PollStart();
    return continue();
}

hook function TogglePlayerSpectating(playerid, bool:toggle)
{
    if(toggle)
    {
        SetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_SPECTATING);
    }

    return continue(playerid, bool:toggle);
}

hook function SendClientMessage(playerid, colour, const msg[], GLOBAL_TAG_TYPES:...)
{
    new fixed_msg[144];
    va_format(fixed_msg, 144, msg, ___(3));
    RemoveGraphicAccent(fixed_msg);
    return continue(playerid, colour, fixed_msg);
}

hook function SendClientMessageToAll(colour, const msg[], GLOBAL_TAG_TYPES:...)
{
    new fixed_msg[144];
    va_format(fixed_msg, 144, msg, ___(2));
    RemoveGraphicAccent(fixed_msg);
    return continue(colour, fixed_msg);
}

public e_COMMAND_ERRORS:OnPlayerCommandReceived(playerid, cmdtext[], e_COMMAND_ERRORS:success)
{
    if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_LOGGED)) 
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ERRO ] {ffffff}Você precisa logar para usar comandos");
        return COMMAND_SILENT;
    }

    switch(success)
    {
        case COMMAND_UNDEFINED:
        {
            SendClientMessage(playerid, -1, "{ff3333}[ CMD ] {ffffff}O comando \'%s\' nao existe", cmdtext); 
            return COMMAND_SILENT;            
        }    
    }

    return success;
}

public OnPlayerText(playerid, text[])
{
    if(isnull(text)) return 0;

    if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_LOGGED))
    {
        SendClientMessage(playerid, -1, "{ff3333}[ SEGURANCA ] {ffffff}Chat bloqueado durante login/registro. Use apenas o dialog para senha.");
        return 0;
    }

    if(!strcmp(lgn::Player[playerid][lgn::input], text))
    {
        SendClientMessage(playerid, -1, "{ff3333}[ OPA! ] {ffffff}Nao compartilhe {ff3333}sua senha {ffffff}com ninguem, {ff3333}nem mesmo com admins!");
        return 0;
    }

    if(GetFlag(Admin[playerid][adm::flags], FLAG_ADM_WORKING))
    {      
        Adm::SendMsgToAllTagged(0xFFFF33AA, 
        "[ ADM CHAT ] {%06x}%s {ffffff}: {ffff33}%s", 
        Adm::gColors[Admin[playerid][adm::lvl]], GetPlayerNameStr(playerid), text);  
        return 0;      
    }   

    new Float:pX, Float:pY, Float:pZ;
    GetPlayerPos(playerid, pX, pY, pZ);

    SendMessageToNearPlayer(pX, pY, pZ, "{FFFF99}[ L ] {ffffff}%s {FFFF99}[ %d ] diz: {ffffff}%s", GetPlayerNameStr(playerid), playerid, text);
    
    if(IsPlayerControllable(playerid))
        ApplyAnimation(playerid, "GANGS", "prtial_gngtlkA", 4.1, false, false, false, false, 1500);

    return 0;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
    if(Admin[playerid][adm::lvl] < ROLE_ADM_MANAGER) return 1;
    
    SetPlayerPos(playerid, fX, fY, fZ);

    return 1;
}

stock SendMessageToNearPlayer(Float:pX, Float:pY, Float:pZ, const msg[], GLOBAL_TAG_TYPES:...)
{
    new count, near_players[MAX_PLAYERS];
    
    count = Player::GetPlayersIntoRange(pX, pY, pZ, 70.0, near_players);

    new formated_msg[144];
    va_format(formated_msg, 144, msg, ___(4));

    for(new i = 0; i < count; i++)
    {   
        new playerid = near_players[i];

        if(playerid == INVALID_PLAYER_ID) continue;
        
        SendClientMessage(playerid, -1, formated_msg); 
    }

    return 1;
}
