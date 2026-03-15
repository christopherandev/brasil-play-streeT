#include <YSI\YSI_Coding\y_hooks>

hook OnGameModeInit()
{
    AdminList = list_new();
    printf("[ LISTA ] Lista de Admins criada com sucesso!\n");

    return 1;
}

hook OnPlayerLogin(playerid)
{
    Adm::LoadData(playerid);
    return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
    Adm::UnLoadData(playerid);    
    return 1;
}

public OnSpectatorListUpdate(spectatorid, reason)
{
    if(!list_valid(pyr::gSpectables)) return 0;

    for(new i = 0; i < list_size(AdminList); i++)
    {
        if(Admin[i][adm::spectateid] == spectatorid)
        {
            SendClientMessage(i, -1, 
            "{ffff33}[ ADM ] {ffffff}O jogador {ffffff}[ {ffff33}ID: %d {ffffff}] {ffff33}%s", 
            spectatorid, reason != 9 ? "Saiu do mundo!" :  "Se desconectou!");
            
            Admin[i][adm::spectateid] = Adm::GetNextSpectateID(i, 0, 1);
            
            if(Admin[i][adm::spectateid] != INVALID_PLAYER_ID) 
                Adm::SpectatePlayer(i, Admin[i][adm::spectateid]);
            else
            {
                Command_ReProcess(i, "tvoff", false);
                SendClientMessage(i, -1, "{ff3333}[ TV ] {ffffff}Nenhum jogador online para entrar em modo de espectador!"); 
            }
        }
    }

    return 1;
}
