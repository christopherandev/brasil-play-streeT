<<<<<<< HEAD
stock GetRegionFromXY(Float:x, Float:y)
{
    if(x < WORLD_MIN || x > WORLD_MAX || y < WORLD_MIN || y > WORLD_MAX) return INVALID_REGION_ID;

    new col = floatround((x - WORLD_MIN) / REGION_SIZE, floatround_floor);
    new row = floatround((y - WORLD_MIN) / REGION_SIZE, floatround_floor);

    if(col >= REGION_GRID_SIZE) col = REGION_GRID_SIZE - 1;
    if(row >= REGION_GRID_SIZE) row = REGION_GRID_SIZE - 1;

    return (row * REGION_GRID_SIZE) + col;
}

stock GetRegionByArea(STREAMER_TAG_AREA:areaid)
{
    for(new regionid = 0; regionid < REGION_COUNT; regionid++)
        if(Areas[regionid] == areaid)
            return regionid;

    return INVALID_REGION_ID;
}

stock GetRegionCellX(regionid)
    return (regionid % REGION_GRID_SIZE);

stock GetRegionCellY(regionid)
    return (regionid / REGION_GRID_SIZE);

stock Lists::HasElement(List:list, AnyTag:element)
    return (list_find(list, element) != -1);

stock Lists::AddElement(&List:list, GLOBAL_TAG_TYPES:element)
{
    if(!list_valid(list) || Lists::HasElement(list, element)) 
    {
        //DISCORD_LOG
        return 0;
    }

    list_add(list, element);
    
    return 1;
}

stock Lists::RemoveElement(&List:list, AnyTag:element)
{
    if(!list_valid(list) || !Lists::HasElement(list, element)) 
    {
        //DISCORD_LOG
        return 0;
    }

    new idx = list_find(list, element);

    list_remove(list, idx);

    return 1;
}
=======
stock GetRegionFromXY(Float:x, Float:y)
{
    if(x < WORLD_MIN || x > WORLD_MAX || y < WORLD_MIN || y > WORLD_MAX) return INVALID_REGION_ID;

    new col = floatround((x - WORLD_MIN) / REGION_SIZE, floatround_floor);
    new row = floatround((y - WORLD_MIN) / REGION_SIZE, floatround_floor);

    if(col >= REGION_GRID_SIZE) col = REGION_GRID_SIZE - 1;
    if(row >= REGION_GRID_SIZE) row = REGION_GRID_SIZE - 1;

    return (row * REGION_GRID_SIZE) + col;
}

stock GetRegionByArea(STREAMER_TAG_AREA:areaid)
{
    for(new regionid = 0; regionid < REGION_COUNT; regionid++)
        if(Areas[regionid] == areaid)
            return regionid;

    return INVALID_REGION_ID;
}

stock GetRegionCellX(regionid)
    return (regionid % REGION_GRID_SIZE);

stock GetRegionCellY(regionid)
    return (regionid / REGION_GRID_SIZE);

stock Lists::HasElement(List:list, AnyTag:element)
    return (list_find(list, element) != -1);

stock Lists::AddElement(&List:list, GLOBAL_TAG_TYPES:element)
{
    if(!list_valid(list) || Lists::HasElement(list, element)) 
    {
        //DISCORD_LOG
        return 0;
    }

    list_add(list, element);
    
    return 1;
}

stock Lists::RemoveElement(&List:list, AnyTag:element)
{
    if(!list_valid(list) || !Lists::HasElement(list, element)) 
    {
        //DISCORD_LOG
        return 0;
    }

    new idx = list_find(list, element);

    list_remove(list, idx);

    return 1;
}
>>>>>>> a0ec1b3e12ea77b24794a551738f1565733ad433
