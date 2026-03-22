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
