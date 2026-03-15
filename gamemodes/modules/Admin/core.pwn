stock Adm::Exists(const name[], &E_ROLES_ADMIN:level = INVALID_ADM_ROLE_ID)
{
    if(DB::Exists(db_entity, "admins", "name = '%q'", name))
        return DB::GetDataInt(db_entity, "admins", "level", _:level, "name = '%q'", name);

    level = INVALID_ADM_ROLE_ID;
    return 0;
}

stock Adm::Set(const name[], const admin[], E_ROLES_ADMIN:level)
{
    new 
        E_ROLES_ADMIN:old_level
    ;
    
    if(Adm::Exists(name, old_level))
    {
        Adm::UpdateRole(name, admin, level, old_level);
        return 1;
    }

    else
    {
        if(!DB::Exists(db_entity, "players", "name = '%q'", name)) return 0;
        

        new 
            str_date[32],
            targetid = GetPlayerIDByName(name)
        ;
        GetISODate(str_date, 32, Server[srv::gmt]);

        new sucess = DB::Insert(db_entity, "admins", 
        "name, level, promoter, promote_date", 
        "'%q', %i, '%q', '%q'", name, _:level, admin, str_date);
        
        if(!sucess)
            return DC::Log(LOG_TYPE_ERR, 
            "[ ADMIN ] ERRO FATAL: **%s** tentou _setar_ **%s** como admin de cargo: *%s*, mas o banco de dados falhou", 
            admin, name, Adm::gRoleNames[level]);

        DC::Log(LOG_TYPE_WARN, "[ ADMIN ] O jogador **%s** tornou-se admin. Cargo: %s. Promotor: %s", name, Adm::gRoleNames[level], admin);
    
        if(targetid == INVALID_PLAYER_ID) return 1;
    
        SendClientMessage(targetid, -1, "{33ff33}[ ADM ] {ffffff}Parabens! Voce faz parte da {33ff33}STAFF BPS");
        
        SendClientMessage(targetid, -1, 
        "{ff9933}[ ADM ] {ffffff}Voce se tornou um {ff9933}admin! Cargo: {%06x}%s",  
        Adm::gColors[level], Adm::gRoleNames[level]);

        Adm::LoadData(targetid);
        return 1;
    }
}

stock Adm::UnSet(const name[], const admin[])
{
    new old_level;

    if(!Adm::Exists(name, old_level))
    {
        DC::Log(LOG_TYPE_ERR, "[ ADMIN ] **%s** tentou **_remover_** **%s** da equipe, mas este não existia no banco de dados", admin, name);
        return 0;
    }

    new 
        timestr[32],
        targetid = GetPlayerIDByName(name)
    ;
    
    GetISODate(timestr, 32, Server[srv::gmt]);

    new sucess = DB::Delete(db_entity, "admins", "name = '%q'", name);
    
    if(!sucess) 
        return DC::Log(LOG_TYPE_ERR, "[ ADMIN ] **%s** tentou **_remover_** o admin **%s**, mas o banco de dados falhou", admin, name);
    
    DC::Log(LOG_TYPE_WARN, "[ ADMIN ] **%s** foi **_expulso_** da equipe por **%s** com sucesso", name, admin);
    
    if(targetid == INVALID_PLAYER_ID) return 1;
    
    Adm::UnLoadData(targetid);

    SendClientMessage(targetid, -1, "{ff3333}[ ADM ] {ffffff}Você foi {ff3333}expulso {ffffff}da equipe!");

    return 1;
}

stock Adm::LoadData(playerid)
{
    new E_ROLES_ADMIN:level;

    if(!Adm::Exists(GetPlayerNameStr(playerid), level)) return 0;
    
    SetFlag(Admin[playerid][adm::flags], FLAG_IS_ADMIN);
    Admin[playerid][adm::lvl] = level;
    Admin[playerid][adm::spectateid] = INVALID_PLAYER_ID; 
    Admin[playerid][adm::vehicleid] = INVALID_VEHICLE_ID;

    return 1;   
}

stock Adm::UnLoadData(playerid)
{
    if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING) 
        Adm::UnSetWorkMode(playerid);

    Admin[playerid][adm::flags] = 0;
    Admin[playerid][adm::lvl] = INVALID_ADM_ROLE_ID;
    Admin[playerid][adm::spectateid] = INVALID_PLAYER_ID; 

    Veh::Respawn(Admin[playerid][adm::vehicleid]);
}

stock Adm::UpdateRole(const name[], const admin[], E_ROLES_ADMIN:level, E_ROLES_ADMIN:old_level)
{
    new str_date[32];

    GetISODate(str_date, 32, Server[srv::gmt]);

    new sucess = DB::Update(db_entity, 
    "admins", 
    "level = %i, promoter = '%q', promote_date = '%q' WHERE name = '%q'", 
    _:level, admin, str_date, name);

    if(!sucess)
        return DC::Log(LOG_TYPE_ERR, "[ ADMIN ] **%s** tentou **_atualizar_** o cargo admin de **%s**, mas o banco de dados falhou", admin, name);
    
    new targetid = GetPlayerIDByName(name);

    if(old_level <= level)
    {
        DC::Log(LOG_TYPE_WARN, 
        "[ ADMIN ] **%s** foi **_promovido_** por **%s**. Novo Cargo: *%s*", 
        name, admin, Adm::gRoleNames[level]);

        if(targetid == INVALID_PLAYER_ID) return 1;
        
        SetFlag(Admin[targetid][adm::flags], FLAG_IS_ADMIN);
        Admin[targetid][adm::lvl] = level;

        SendClientMessage(targetid, -1, 
        "{33ff33}[ ADM ] {ffffff}Voce foi {33ff33}provido {ffffff}para {%06x}%s",
        Adm::gColors[level], Adm::gRoleNames[level]);

        return 1;
   }
    
    else
    {
        DC::Log(LOG_TYPE_WARN, 
        "[ ADMIN ] **%s** foi **_rebaixado_** por **%s**. Novo Cargo: *%s*", 
        name, admin, Adm::gRoleNames[level]);
        
        if(targetid == INVALID_PLAYER_ID) return 1;
        
        SetFlag(Admin[targetid][adm::flags], FLAG_IS_ADMIN);
        Admin[targetid][adm::lvl] = level;

        SendClientMessage(targetid, -1, 
        "{ff3333}[ ADM ] {ffffff}Voce foi {ff3333}rebaixado {ffffff}para {%06x}%s",
        Adm::gColors[level], Adm::gRoleNames[level]);

        return 1;
    }
}

stock Adm::SetWorkMode(playerid)
{
    new 
        E_ROLES_ADMIN:level = Admin[playerid][adm::lvl], 
        name[MAX_PLAYER_NAME],
        str[128]
    ;
  
    /* 
    
    /tv
    
    Admin[playerid][adm::spectateid] = Adm::GetNextSpectateID(playerid, -1, 1);

    if(Admin[playerid][adm::spectateid] == INVALID_PLAYER_ID) return 0;

    SetFlag(Admin[playerid][adm::flags], FLAG_ADM_WORKING);
 
    TogglePlayerSpectating(playerid, true);

    Baseboard::HideTDForPlayer(playerid);
    Adm::ShowTDForPlayer(playerid);

    Adm::SpectatePlayer(playerid, Admin[playerid][adm::spectateid]);
    
    */

    SetFlag(Admin[playerid][adm::flags], FLAG_ADM_WORKING);
    SetPlayerSkin(playerid, 217);

    GetPlayerName(playerid, name);

    Adm::SendMsgToAllTagged(-1, 
    "{ffff33}[ ADM CHAT ] {%06x}%s {ffff33}entrou {ffffff}no modo de trabalho", 
    Adm::gColors[level], name);

    format(str, 128, 
    "{%06x}[ %s ] {ffffff}%s [ {%06x}%d {ffffff}]", 
    Adm::gColors[level], Adm::gRoleNames[level], name, Adm::gColors[level], playerid);
    
    UpdateDynamic3DTextLabelText(Player[playerid][pyr::nametag], -1, str);

    Lists::AddElement(AdminList, playerid);
    return 1;
}

stock Adm::UnSetWorkMode(playerid)
{
    new 
        E_ROLES_ADMIN:level = Admin[playerid][adm::lvl], 
        name[MAX_PLAYER_NAME],
        str[128]
    ;
  
    GetPlayerName(playerid, name);
    SetPlayerSkin(playerid, Player[playerid][pyr::skinid]);

    ResetFlag(Admin[playerid][adm::flags], FLAG_ADM_WORKING);

    /*

    tvoff

    Admin[playerid][adm::spectateid] = INVALID_PLAYER_ID;

    TogglePlayerSpectating(playerid, false);

    Adm::HideTDForPlayer(playerid);
    Baseboard::ShowTDForPlayer(playerid);
    
    */

    Adm::SendMsgToAllTagged(-1, 
    "{ffff33}[ ADM AVISO ] {%06x}%s {ffff33}saiu {ffffff}no modo de trabalho", 
    Adm::gColors[level], name);  

    format(str, 128, "%s {99ff99}[ {ffffff}%d {99ff99}]", name, playerid);
    
    UpdateDynamic3DTextLabelText(Player[playerid][pyr::nametag], -1, str);

    Lists::RemoveElement(AdminList, playerid);
    
    return 1;
}

stock Adm::SendMsgToAllTagged(color, const msg[], GLOBAL_TAG_TYPES:...)
{
    new format_msg[144];
    va_format(format_msg, 144, msg, ___(2));
    
    for(new i = 0; i < list_size(AdminList); i++)
        SendClientMessage(list_get(AdminList, i), color, format_msg);
    
    return 1;
}

stock Adm::HasPermission(playerid, E_ROLES_ADMIN:level, need_work = true)
{    
    if(!GetFlag(Admin[playerid][adm::flags], FLAG_IS_ADMIN))
    {
        SendClientMessage(playerid,  -1, "{ff3333}[ CMD ] {ffffff}Esse comando não existe!");
        return 0;
    }

    if((Admin[playerid][adm::lvl]) < level)
    {
        SendClientMessage(playerid,  -1, "{ff3333}[ ADM ] {ffffff}Voce nao tem cargo de admin suficiente para isso!");
        return 0;
    }   

    if(!GetFlag(Admin[playerid][adm::flags], FLAG_ADM_WORKING) && need_work)
    {
        if((Admin[playerid][adm::lvl]) >= ROLE_ADM_CEO) return 1;
        
        SendClientMessage(playerid,  -1, "{ff3333}[ ADM ] {ffffff}Voce precisar estar em modo de trabalho: Use: {ff3333}/aw!");
        return 0;
    }

    return 1;
}

stock Adm::ValidTargetID(playerid, targetid, bool:can_equal = false, bool:sendmsg = true)
{
    if(!IsValidPlayer(targetid)) 
    {
        if(sendmsg)
            SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}O jogador {ff3333}não está online!");
        return 0;
    }

    if(!can_equal && (playerid == targetid))
    {
        if(sendmsg)
            SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}Você não poder aplicar essa ação em {ff3333}si mesmo!");
        return 0;        
    }

    if((Admin[playerid][adm::lvl] <= Admin[targetid][adm::lvl]))
    {
        if((can_equal && (playerid == targetid))) return 1;
        
        if(sendmsg)
            SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}Voce nao poder aplicar essa ação ao seu {ff3333}colega/subordinado!");
        return 0;        
    }   

    return 1;     
}

stock Adm::IsValidTargetName(playerid, const name[], const target_name[])
{
    new E_ROLES_ADMIN:player_lvl, E_ROLES_ADMIN:target_lvl;

    Adm::Exists(name, player_lvl);
    Adm::Exists(target_name, target_lvl);

    if(!isnull(name) && !strcmp(name, target_name))
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}Voce nao poder aplicar essa acao em voce mesmo!");
        return 0;
    }

    if(player_lvl <= target_lvl)
    {
        SendClientMessage(playerid, -1, "{ff3333}[ ADM ] {ffffff}Voce nao poder aplicar essa acao ao seu {ff3333}colega/subordinado!");
        return 0;        
    }

    return 1;
}

stock Adm::CreateLocation(playerid, const name[], const category[], const admin[])
{
    if(DB::Exists(db_stock, "locations", "name = '%q' AND category = '%q'", name, category))
    {
        SendClientMessage(playerid, -1, "{ff3333}[ GPS ] {ffffff}Esse o nome '%s', já existe na categoria \"%s\"", name, category);
        return 1;
    }

    new Float:pX, Float:pY, Float:pZ;
    GetPlayerPos(playerid, pX, pY, pZ);

    DB::Insert(db_stock, "locations", "name, category, creator, pX, pY, pZ", "'%q', '%q', '%q', %f, %f, %f", 
    name, category, admin, pX, pY, pZ);

    DC::Log(LOG_TYPE_WARN, "[ GPS ] O Admin **%s** criou uma nova localização: name: **%s** categoria: **%s**", admin, name, category);

    return 1;
}

stock Adm::IsValidSpectateID(playerid, targetid)
{
    if((Admin[playerid][adm::lvl] <= Admin[targetid][adm::lvl])) return 0;

    return (!GetFlag(Player[targetid][pyr::flags], FLAG_PLAYER_SPECTATING));
}

stock Adm::IsSpectating(playerid)
    return (GetFlag(Player[playerid][pyr::flags], FLAG_PLAYER_SPECTATING) && GetFlag(Admin[playerid][adm::flags], FLAG_ADM_WORKING));

stock Adm::SpectatePlayer(playerid, targetid)
{
    if(IsPlayerInAnyVehicle(targetid))
        PlayerSpectateVehicle(playerid, targetid);
    else
        PlayerSpectatePlayer(playerid, targetid);

    SetPlayerInterior(playerid, GetPlayerInterior(targetid));
    SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(targetid));

    Adm::UpdateTextDraw(playerid, targetid);

    return 1;
}

stock Adm::GetNextSpectateID(playerid, currentid, dir)
{
    if(!list_valid(pyr::gSpectables)) return INVALID_PLAYER_ID;

    new len = list_size(pyr::gSpectables);
    
    if(len == 0) return INVALID_PLAYER_ID;

    if(currentid < 0 || currentid >= len) currentid = (dir == 1) ? -1 : len;

    new checked = 0, idx = currentid;

    while(checked < len)
    {
        idx += dir;

        if(idx >= len)      idx = 0;
        else if(idx < 0)    idx = len - 1;

        new targetid = list_get(pyr::gSpectables, idx);

        if(targetid == playerid)
        {
            checked++;
            continue;
        }

        if(Adm::IsValidSpectateID(playerid, targetid)) return targetid;

        checked++;
    }

    return INVALID_PLAYER_ID;
}
