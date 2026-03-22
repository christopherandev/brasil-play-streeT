#define INVALID_OWNER_ID (-1)
#define INVALID_PAINTJOB_ID (-1)

enum (<<= 1)
{
    FLAG_VEH_BROKED = 1,
    FLAG_VEH_OUT_OFFUEL,
}

enum (<<= 1)
{
    FLAG_PARAM_ENGINE = 1,
    FLAG_PARAM_LIGHTS,
    FLAG_PARAM_ALARM,
    FLAG_PARAM_DOORS,
    FLAG_PARAM_BONNET,
    FLAG_PARAM_BOOT,
    FLAG_PARAM_OBJECTIVE,
}

enum OWNER_TYPES
{
    OWNER_TYPE_SERVER,
    OWNER_TYPE_PLAYER,
    OWNER_TYPE_COMPANY,
    OWNER_TYPE_ADMIN,
    OWNER_TYPE_ORG,
    INVALID_OWNER_TYPE
}

enum E_PLAYER_VEHICLE
{
    pyr::tick_gas_notify,
}

enum E_VEH_TIMERS
{
    veh::TIMER_EMPTY_RESPAWN
}

enum E_VEHICLES
{
    veh::dbid,
    veh::owner_name[32], 
    veh::slotid,
    veh::regionid,
    veh::ownerid, 
    OWNER_TYPES:veh::owner_type,
    veh::modelid,
    veh::flags, veh::params,
    Float:veh::fuel, Float:veh::health,
    Float:veh::pX, Float:veh::pY, Float:veh::pZ, Float:veh::pA,
    veh::color1, veh::color2,
    veh::paintjobid,
    veh::interiorid, veh::worldid,

    veh::o_speed, Float:veh::o_accel, Float:veh::oX, Float:veh::oY, Float:veh::oZ,
    
    veh::tick,
    STREAMER_TAG_3D_TEXT_LABEL:veh::labelid
}


new veh::Player[MAX_PLAYERS][E_PLAYER_VEHICLE];
new Vehicle[MAX_VEHICLES][E_VEHICLES];
new veh::Timer[MAX_VEHICLES][E_VEH_TIMERS];

forward OnSpeedOMeterUpdate(playerid);
forward Float:Veh::GetVehicleFuelUsed(Float:speed, Float:accel, Float:dt);
forward OnVehicleFuelChange(vehicleid, Float:new_fuel, Float:old_fuel);
forward OnVehicleCreate(vehicleid, modelid, regionid, Float:x, Float:y, Float:z);
forward OnVehicleRespawn(vehicleid);
forward OnVehicleBroke(vehicleid, driverid);
forward OnVehicleEmptyTimeout(vehicleid, forplayerid);

#define FUEL_PRICE_PER_LITER (6.28)
#define ARMOUR_PRICE_PER_HP  (6.0)

new Text:Veh::PublicTD[11] = {INVALID_TEXT_DRAW, ...};
new PlayerText:Veh::PlayerTD[MAX_PLAYERS][18] = {{INVALID_PLAYER_TEXT_DRAW, ...}, ...};
new Text:Garage::PublicTD[12] = {INVALID_TEXT_DRAW, ...};
new PlayerText:Garage::PlayerTD[MAX_PLAYERS][7] = {{INVALID_PLAYER_TEXT_DRAW, ...}, ...};

enum _:E_PTD_VEH
{
    PlayerText:PTD_VEH_BAR_FUEL,
    PlayerText:PTD_VEH_TXT_SPEED,
    PlayerText:PTD_VEH_BAR_HEALTH,
    PlayerText:PTD_VEH_BAR_ARMOUR,
    PlayerText:PTD_VEH_FIRST_DOT = 4,
    PlayerText:PTD_VEH_LAST_DOT = 16,
    PlayerText:PTD_VEH_TXT_NAME = 17,
}

enum _:E_TD_GRG
{
    Text:TD_GRG_BTN_PREV = 9,
    Text:TD_GRG_BTN_NEXT = 10,
}

enum _:E_PTD_GRG
{
    PlayerText:PTD_GRG_TXT_NAME,
    PlayerText:PTD_GRG_BAR_HEALTH,
    PlayerText:PTD_GRG_BAR_FUEL,
    PlayerText:PTD_GRG_BAR_ARMOUR,
    PlayerText:PTD_GRG_TXT_PAGE,
    PlayerText:PTD_GRG_SPR_COLOR1,
    PlayerText:PTD_GRG_SPR_COLOR2,
}
