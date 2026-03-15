#include <YSI\YSI_Coding\y_hooks>

#if defined ON_DEBUG_MODE

hook OnPlayerConnect(playerid, classid)
{
    if(IsPlayerNPC(playerid)) return -1;

    SendClientMessage(playerid, -1, "{ff9933}[ ! ] Servidor em modo de DEBUG, \
    se o servidor está público nesse momento, avise um moderador imediatamente!");
    
    return 1;
}

hook OnPlayerRequestClass(playerid, classid)
{
    if(IsPlayerNPC(playerid)) return -1;
    
    Login::UnSetPlayer(playerid);

    return 1;
}

#else

hook OnPlayerConnect(playerid)
{
    if(IsPlayerNPC(playerid)) return -1;
    
    ClearChat(playerid, 20);

    Player::ClearData(playerid);

    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);

    /* VERIFICAR NOME - É ADEQUADO ?  */
    if(!IsValidNickName(name))
    {
        SendClientMessage(playerid, -1 , "{ff3333}[ KICK ] {ffffff}Seu nome de usuário e inválido!");
        Kick(playerid);
        return -1; // ENCERRA PROXÍMAS EXECUÇÕES DE hook OnPlayerConnect
    }

    /* VERIFICAR PUNIÇÃO - ESTÁ BANIDO ?  */
    if(!Punish::VerifyPlayer(playerid))
    {
        SendClientMessage(playerid, -1 , "{ff3333}[ KICK ] {ffffff}Você esta {ff3333}banido {ffffff}deste servidor!");
        Kick(playerid);
        return -1;
    }

    Login::SetPlayer(playerid);

    return 1;
}

#endif

hook OnPlayerDisconnect(playerid, reason)
{
    if(IsPlayerNPC(playerid)) return -1;

    if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_LOGGED)) 
    {
        Player::KillTimer(playerid, pyr::TIMER_LOGIN_KICK);
        return -1;
    }

    Player::KillTimer(playerid, pyr::TIMER_PAYDAY);

    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name);

    if(GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_SPECTATING)) 
    {
        TogglePlayerSpectating(playerid, false);
    }
    
    if(GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_IN_JAIL))
    {
        if(DB::Exists(db_entity, "punishments", "name = '%q' AND level = 1", name))
            Player::KillTimer(playerid, pyr::TIMER_JAIL);
    }
    
    if(IsPlayerInAnyVehicle(playerid))
        Player::KillTimer(playerid, pyr::TIMER_SPEEDOMETER);

    if(GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_RESUSCITATION))
    {
        Player::KillTimer(playerid, pyr::TIMER_RESUSCITATION);
        
        ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_RESUSCITATION);
        ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_INVUNERABLE);

        new targetid = Player[playerid][pyr::resuscitation_targetid];
        if(IsValidPlayer(targetid))
        {
            ResetFlag(Player[targetid][pyr::flags], FLAG_PLAYER_RESUSCITATION);
            Player[targetid][pyr::resuscitation_targetid] = INVALID_PLAYER_ID;
            TogglePlayerControllable(targetid, GetFlag(Player[targetid][pyr::flags], FLAG_PLAYER_INJURED) ? false : true);
            ClearAnimations(targetid, SYNC_ALL);

            if(GetFlag(Player[targetid][pyr::flags], FLAG_PLAYER_INJURED))
                ApplyAnimation(targetid, "SWAT", "gnstwall_injurd", 4.1, true, false, false, true, 0, SYNC_ALL);
        }
    }

    Login::HideTDForPlayer(playerid);
    Baseboard::HideTDForPlayer(playerid);
    Acessory::HideTDForPlayer(playerid);
    Adm::HideTDForPlayer(playerid);
    Veh::HideTDForPlayer(playerid);

    ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_INVUNERABLE);
    ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_LOGGED);
    ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_CHECKPOINT);
    
    new vehicleid = Player[playerid][pyr::vehicleid];

    if(IsValidVehicle(vehicleid))
    {
        if(Player[playerid][pyr::ocupped_vehicleid] == vehicleid)
            Player[playerid][pyr::ocupped_vehicleid] = INVALID_VEHICLE_ID;

        Veh::Save(vehicleid);
        Veh::Respawn(vehicleid);
    }
    else
    {
        vehicleid = Player[playerid][pyr::ocupped_vehicleid];

        if(IsValidVehicle(vehicleid))
        {
            Player[playerid][pyr::ocupped_vehicleid] = INVALID_VEHICLE_ID;
    
            Veh::Save(vehicleid);
            Veh::Respawn(vehicleid);
        }
    }
    
    DB::SetDataInt(db_entity, "players", "flags", Player[playerid][pyr::flags], "name = '%q'", GetPlayerNameStr(playerid));

    Player::ClearData(playerid);

    return 1;
}

hook OnPlayerLogin(playerid)
{
    ApplyAnimation(playerid, "ped", "null", 0.0, false, false, false, false, 0); 
    ApplyAnimation(playerid, "DANCING", "null", 0.0, false, false, false, false, 0); 
    ApplyAnimation(playerid, "CRACK", "null", 0.0, false, false, false, false, 0); 
    ApplyAnimation(playerid, "SWAT", "null", 0.0, false, false, false, false, 0); 
    ApplyAnimation(playerid, "KNIFE", "null", 0.0, false, false, false, false, 0); 
    ApplyAnimation(playerid, "MEDIC", "null", 0.0, false, false, false, false, 0);
    ApplyAnimation(playerid, "SHOP", "null", 0.0, false, false, false, false, 0);
    ApplyAnimation(playerid, "COP_AMBIENT", "null", 0.0, false, false, false, false, 0);

    Player[playerid][pyr::health] = 100.0;

    Player::SetNameTag(playerid);

    Baseboard::ShowTDForPlayer(playerid);

    GameTextForPlayer(playerid, "~g~~h~~h~Bem Vindo", 2000, 3);

    if(GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_IN_JAIL))
    {
        new time;
        DB::GetDataInt(db_entity, "punishments", "left_tstamp", time, "name = '%q' AND level = 1", GetPlayerNameStr(playerid));
        Punish::SendPlayerToJail(playerid, time);
        SendClientMessage(playerid, -1, "{ff3399}[ PUNICAO ADM ] {ffffff}Voce ainda precisa cumprir sua pena aqui na ilha!");

        return -1;
    }

    if(GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_IS_PARDON))
    {
        SendClientMessage(playerid, -1, "{33ff33}[ BPS ] {ffffff}Você foi {33ff33}perdoado \
            {ffffff}do seu banimento. Esperamos {33ff33}bom {ffffff}comportamento de agora em diante!");
        ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_IS_PARDON);
    }

    Player::Spawn(playerid);

    
    SetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_CLOCK);

    return 1;
}

hook OnPlayerSpawn(playerid)
{    
    if(IsPlayerNPC(playerid)) return -1;

    if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_LOGGED)) 
    {
        SendClientMessage(playerid, -1, "{ff3333}[ KICK ] {ffffff}Um erro desconhecido aconteceu! Voce spawnou sem estar logado!");
        Kick(playerid);
        return -1;
    }

    if(GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_IN_JAIL)) return -1;

    if(GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_SPECTATING))
    {
        ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_SPECTATING);
        SetPlayerWeather(playerid, Server[srv::g_weatherid]);
        SetPlayerHealth(playerid, Player[playerid][pyr::health]);
    }

    if(GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_INJURED))
    {
        Player[playerid][pyr::health] = 50.0;
        SetPlayerHealth(playerid, 50.0);
        ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_INJURED);
        ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_INVUNERABLE);
        ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_RESUSCITATION);
        Player[playerid][pyr::resuscitation_targetid] = INVALID_PLAYER_ID;
        
        Travel::ShowTDForPlayer(playerid, 
        "A emergencia chegou e~n~Voce foi para o hospital...",
        1182.2079 + RandomFloatMinMax(-2.0, 2.0), 
        -1323.2695 + RandomFloatMinMax(-2.0, 2.0), 13.5798, 270.0);      
    }

    return 1;
}

hook OnPlayerEnterCheckpoint(playerid)
{
    if(!GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_CHECKPOINT)) return 1;
    
    ResetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_CHECKPOINT);
    DisablePlayerCheckpoint(playerid);
    SendClientMessage(playerid, -1, "{33ff33}[ GPS ] {ffffff}Você chegou ao seu destino!");
    PlayerPlaySound(playerid, 1058, 0.0, 0.0, 0.0); 
    
    return 1;
}

hook OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA:areaid)
{
    if(!IsValidPlayer(playerid)) return 1;

    new regionid = GetRegionByArea(areaid);
    if(regionid == INVALID_REGION_ID) return 1;

    Player::AddToRegion(playerid, regionid);
    
    if(IsPlayerInAnyVehicle(playerid))
    {
        new vehicleid = GetPlayerVehicleID(playerid);
        if(vehicleid == INVALID_VEHICLE_ID) return 1;

        Veh::AddToRegion(vehicleid, regionid);
    }

    return 1;
}

hook OnPlayerLeaveDynamicArea(playerid, STREAMER_TAG_AREA:areaid)
{
    if(!IsValidPlayer(playerid)) return 1;
    
    new regionid = GetRegionByArea(areaid);
    if(regionid == INVALID_REGION_ID) return 1;

    Player::RemoveFromRegion(playerid);
    
    if(IsPlayerInAnyVehicle(playerid))
    {
        new vehicleid = GetPlayerVehicleID(playerid);
        if(vehicleid == INVALID_VEHICLE_ID)  return 1;

        Veh::RemoveFromRegion(vehicleid);
    }

    return 1;
}

hook OnPlayerStateChange(playerid, PLAYER_STATE:newstate, PLAYER_STATE:oldstate)
{
    if(IsPlayerNPC(playerid)) return -1;

    printf("STATE: %d OLD: %d", newstate, oldstate);

    if(newstate == PLAYER_STATE_DRIVER)
    {
        new vehicleid = GetPlayerVehicleID(playerid);
        
        if(!IsValidVehicle(vehicleid)) return 1; 

        if(!Player::HasVehiclePermission(playerid, vehicleid))
        {
            SetVehicleParamsForPlayer(vehicleid, playerid, .doors = 1);
            RemovePlayerFromVehicle(playerid);
            return 1;
        }

        if(GetFlag(Vehicle[vehicleid][veh::flags], FLAG_VEH_BROKED))
            return SendClientMessage(playerid, -1, "{ff9933}[ VEH ] {ffffff}Este veículo está {ff9933}quebrado! {ffffff}Chame um mecânico");
        
        if(GetFlag(Vehicle[vehicleid][veh::flags], FLAG_VEH_OUT_OFFUEL))
            return SendClientMessage(playerid, -1, "{ff9933}[ VEH ] {ffffff}Este veículo está {ff9933}sem gasolina! {ffffff}Chame um mecânico");

        if(!(Vehicle[vehicleid][veh::params] & FLAG_PARAM_ENGINE))
        {
            SendClientMessage(playerid, -1, "{ffff99}[ VEH ] {ffffff}Aperte {ffff99}'Y' {ffffff}ou digite {ffff99}/motor {ffffff}para ligar o motor.");
        }
         
        Player[playerid][pyr::ocupped_vehicleid] = vehicleid;

        CallLocalFunction("OnVehicleOcupped", "ii", vehicleid, playerid);
        CallLocalFunction("OnDriverEnterVehicle", "ii", playerid, vehicleid);

        if(!Model_IsManual(GetVehicleModel(vehicleid))) return 1;

        Baseboard::HideTDForPlayer(playerid);
        Veh::ShowTDForPlayer(playerid);

        new vehname[64];
        GetVehicleNameByModel(GetVehicleModel(vehicleid), vehname);
        
        Veh::UpdateTDForPlayer(playerid, PTD_VEH_TXT_NAME, "Veiculo: ~g~~h~~h~%s", vehname);
        Veh::UpdateHealth(playerid, vehicleid, Vehicle[vehicleid][veh::health]);
        Veh::UpdateFuel(playerid, vehicleid, Vehicle[vehicleid][veh::fuel]); 

        Player::CreateTimer(playerid, pyr::TIMER_SPEEDOMETER, "OnSpeedOMeterUpdate", 75, true, "i", playerid);
    }

    if(oldstate == PLAYER_STATE_DRIVER)
    {
        Veh::HideTDForPlayer(playerid);
        Baseboard::ShowTDForPlayer(playerid);
        Player::KillTimer(playerid, pyr::TIMER_SPEEDOMETER);

        CallLocalFunction("OnDriverExitVehicle", "i", playerid);   

        new vehicleid = Player[playerid][pyr::ocupped_vehicleid];
        
        if(!IsValidVehicle(vehicleid)) return 1; 

        CallLocalFunction("OnVehicleDesocupped", "ii", vehicleid, playerid);
    }

    if(newstate == PLAYER_STATE_SPECTATING)
    {
        Lists::AddElement(pyr::gSpectables, playerid);
    }

    if(oldstate == PLAYER_STATE_SPECTATING)
    {
        Lists::RemoveElement(pyr::gSpectables, playerid);
        CallLocalFunction("OnSpectatorListUpdate", "ii", playerid, _:newstate);
    }

    return 1;
}

hook OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys)
{
    if(IsPlayerNPC(playerid)) return -1;

    if((newkeys & KEY_YES) && !(oldkeys & KEY_YES))
    {
        new vehicleid = GetPlayerVehicleID(playerid);

        if(IsValidVehicle(vehicleid))
        {
            if(!Player::HasVehiclePermission(playerid, vehicleid)) return 1;
            Veh::ToggleParams(playerid, vehicleid, FLAG_PARAM_ENGINE);
        }

        return 1;
    }

    if((newkeys & KEY_SECONDARY_ATTACK) && !(oldkeys & KEY_SECONDARY_ATTACK))
    {
        if(Player::HandleResuscitationAction(playerid)) return 1;
        
        if(Shop::HandleCommands(playerid)) return 1;
    }

    return 1;
}

public Player::Kick(playerid, E_PLAYER_TIMERS:timerid, const msg[]) 
{    
    Player::KillTimer(playerid, timerid);
    
    if(IsPlayerConnected(playerid))
    {
        StopAudioStreamForPlayer(playerid);
        SendClientMessage(playerid, -1, "{ff3333}[ KICK ] {ffffff}%s", msg);
        Kick(playerid);
    }
    
    return 1; 
}
