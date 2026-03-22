#include <YSI\YSI_Coding\y_hooks>

hook OnGameModeInit()
{
    DC::LoadCountMaps += LoadMap("ammunation.txt");
    DC::LoadCountMaps += LoadMap("apartamento.txt");
    DC::LoadCountMaps += LoadMap("arena.txt");
    DC::LoadCountMaps += LoadMap("binco.txt");
    DC::LoadCountMaps += LoadMap("garagem.txt");
    DC::LoadCountMaps += LoadMap("hospital.txt");
    DC::LoadCountMaps += LoadMap("lojinha.txt");
    DC::LoadCountMaps += LoadMap("loterica_caixa.txt");
    DC::LoadCountMaps += LoadMap("nubank.txt");
    DC::LoadCountMaps += LoadMap("org_ext_groove.txt");
    DC::LoadCountMaps += LoadMap("org_ext_mec.txt");
    DC::LoadCountMaps += LoadMap("org_ext_pcc.txt");
    DC::LoadCountMaps += LoadMap("org_ext_prf.txt");
    DC::LoadCountMaps += LoadMap("org_ext_triad.txt");
    DC::LoadCountMaps += LoadMap("org_int_groove.txt");
    DC::LoadCountMaps += LoadMap("prefeitura.txt");
    DC::LoadCountMaps += LoadMap("praca_hospital.txt");
    DC::LoadCountMaps += LoadMap("praca_prefeitura.txt");
    DC::LoadCountMaps += LoadMap("spawn.txt");

    return 1;
}

hook OnPlayerConnect(playerid)
{
    if(IsPlayerNPC(playerid)) return 1;
    RemoveAllBuildings(playerid);
    return 1;
}

stock LoadMap(const file_name[])
{
    new path[64];
    format(path, sizeof(path), "maps/%s", file_name);

    if(!fexist(path)) 
    {
        printf("[ MAP ] Arquivo %s nao encontrado\n", file_name);
        return 0;
    }

    new File:handle = fopen(path, io_read);

    if(handle) 
    {
        new line[256], dest[256], tmpobjid;
        
        while(fread(handle, line)) 
        {
            if(line[0] == '\r' || line[0] == '\0' || line[0] == '/') continue;

            strmid(dest, line, 0, strfind(line, "("), sizeof(dest));

            switch(YHash(dest))
            {
                case _H<CreateDynamicObject>:
                {
                    strmid(dest, line, strfind(line, "(") + 1, strfind(line, ");"), sizeof(dest));

                    new modelid, worldid, interiorid, playerid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, Float:streamdistance, Float:drawdistance;
                    
                    if(sscanf(dest, "p<,>iffffffiiiff", modelid, x, y, z, rx, ry, rz, worldid, interiorid, playerid, streamdistance, drawdistance))
                    {
                        printf("[ MAP ] Erro ao carregar função CreateDynamicObject de %s\n", file_name);
                        return 0;
                    }

                    tmpobjid = CreateDynamicObject(modelid, x, y, z, rx, ry, rz, worldid, interiorid, playerid, streamdistance, drawdistance);
                }

                case _H<SetDynamicObjectMaterial>:
                {
                    strmid(dest, line, strfind(line, "(") + 1, strfind(line, ");"), sizeof(dest));

                    new materialindex, modelid, txdname[32], texturename[32], materialcolor;

					if(sscanf(dest, "p<,>{s[32]}iis[32]s[32]h", materialindex, modelid, txdname, texturename, materialcolor))
					{
                        printf("[ MAP ] Erro ao carregar função SetDynamicObjectMaterial de %s\n", file_name);
                        return 0;
                    }

                    strmid(txdname, txdname, 1, strlen(txdname) - 1, sizeof(txdname));
                    strmid(texturename, texturename, 1, strlen(texturename) - 1, sizeof(texturename));
                    
                    SetDynamicObjectMaterial(tmpobjid, materialindex, modelid, txdname, texturename, materialcolor);
                }

                case _H<SetDynamicObjectMaterialText>:
                {
                    strmid(dest, line, strfind(line, "(") + 1, strfind(line, ");"), sizeof(dest));

                    new materialindex, text[144], materialsize, fontface[16], fontsize, bold, fontcolor, backcolor, textalignment;
                    
                    if(sscanf(dest, "p<,>{s[32]}is[144]is[16]iihhi", materialindex, text, materialsize, fontface, fontsize, bold, fontcolor, backcolor, textalignment))
					{    
                        printf("[ MAP ] Erro ao carregar função SetDynamicObjectMaterialText de %s\n", file_name);
                        return 0;
                    }
                    strmid(text, text, 1, strlen(text) - 1, sizeof(text));
                    strmid(fontface, fontface, 1, strlen(fontface) - 1, sizeof(fontface));
                    
                    SetDynamicObjectMaterialText(tmpobjid, materialindex, text, materialsize, fontface, fontsize, bold, fontcolor, backcolor, textalignment);
                }

                case _H<RemoveBuildingForPlayer>:
                {
                    strmid(dest, line, strfind(line, "(") + 1, strfind(line, ");"), sizeof(dest));
                    
                    new modelid, Float:x, Float:y, Float:z, Float:range;

                    if(sscanf(dest, "p<,>{s[32]}iffff", modelid, x, y, z, range))
                    {
                        printf("[ MAP ] Erro ao carregar função RemoveBuildingForPlayer de %s\n", file_name);
                        return 0;
                    }

                    AddRemoveBuilding(modelid, x, y, z, range);
                }

                default:
                {
                    printf("[ MAP ] Erro ao carregar Mapa %s, função inexistente encontrada: %s\n", file_name, line);
                    return 0;
                }
            }
        }

        fclose(handle);

        return 1;
    }

    printf("[ MAP ] Nao foi possivel abrir o arquivo %s\n", file_name);

    return 0;
}

stock AddRemoveBuilding(modelid, Float:x, Float:y, Float:z, Float:range)
{
	for(new i = 0; i < MAX_REMOVE_BUILDING; i++)
	{
	    if(!RemovedBuilding[i][map::modelid])
	    {
	        RemovedBuilding[i][map::modelid] = modelid;
	        RemovedBuilding[i][map::pX] = x;
	        RemovedBuilding[i][map::pY] = y;
	        RemovedBuilding[i][map::pZ] = z;
	        RemovedBuilding[i][map::range] = range;
			return 1;
	    }
	}

	return 0;
}

stock RemoveAllBuildings(playerid)
{
	for(new i = 0; i < MAX_REMOVE_BUILDING; i++)
	{
	    if(!RemovedBuilding[i][map::modelid]) break;

        RemoveBuildingForPlayer(playerid, 
        RemovedBuilding[i][map::modelid], 
        RemovedBuilding[i][map::pX], RemovedBuilding[i][map::pY], RemovedBuilding[i][map::pZ], 
        RemovedBuilding[i][map::range]);

        printf("Destruido: %d %f %f %f %f", RemovedBuilding[i][map::modelid], 
        RemovedBuilding[i][map::pX], RemovedBuilding[i][map::pY], RemovedBuilding[i][map::pZ], 
        RemovedBuilding[i][map::range]);
	}

    return 1;
}