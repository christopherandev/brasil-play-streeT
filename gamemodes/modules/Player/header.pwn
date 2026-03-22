#include <YSI\YSI_Coding\y_hooks>

#define MAX_PLAYER_ACESSORYS    (5)
#define MAX_STOCK_ACESSORYS     (8)
#define MAX_PLAYER_VEHICLES     (2)

#define INVALID_SLOTID          (-1)

enum (<<= 1)
{
    FLAG_PLAYER_LOGGED = 1,   
    FLAG_PLAYER_IS_PARDON,     
    FLAG_PLAYER_IN_REGISTER,  
    FLAG_PLAYER_IN_LOGIN,
    FLAG_PLAYER_SPECTATING,
    FLAG_PLAYER_IN_JAIL,
    FLAG_PLAYER_CHECKPOINT,
    FLAG_PLAYER_INJURED,
    FLAG_PLAYER_INVUNERABLE,
    FLAG_PLAYER_RESUSCITATION,
    FLAG_PLAYER_GENDER,
    FLAG_PLAYER_CLOCK
}

enum E_PLAYER 
{
    pyr::pass[BCRYPT_HASH_LENGTH],
    pyr::bitcoin,
    pyr::vipcoin,
    Float:pyr::money,
    Float:pyr::health,
    pyr::death_tick,
    pyr::skinid,
    pyr::score,
    pyr::flags,
    pyr::ocupped_vehicleid,
    Float:pyr::oX, Float:pyr::oY, Float:pyr::oZ, Float:pyr::oA,
    pyr::regionid,
    pyr::vehicleid,
    pyr::resuscitation_targetid,
    Text3D:pyr::nametag,
    Text3D:pyr::deathtag
}

new Player[MAX_PLAYERS][E_PLAYER];


/*                  PLAYER TIMERS                 */

enum E_PLAYER_TIMERS
{
    pyr::TIMER_LOGIN_KICK,
    pyr::TIMER_PAYDAY,
    pyr::TIMER_JAIL,
    pyr::TIMER_SPEEDOMETER,
    pyr::TIMER_INJURY,
    pyr::TIMER_RESUSCITATION,
    pyr::TIMER_TRAVEL,
    pyr::TIMER_DSP,
    
}

new pyr::Timer[MAX_PLAYERS][E_PLAYER_TIMERS];

forward Player::Kick(playerid, E_PLAYER_TIMERS:timerid, const msg[]);

new Text:Baseboard::PublicTD[13] = {INVALID_TEXT_DRAW, ...};
new PlayerText:Baseboard::PlayerTD[MAX_PLAYERS][5] = {{INVALID_PLAYER_TEXT_DRAW, ...}, ...};
new PlayerText:Travel::PlayerTD[MAX_PLAYERS][2] = {{INVALID_PLAYER_TEXT_DRAW, ...}, ...};

enum _:E_TD_BASEBOARD
{
    Text:TD_BASEBOARD_CLOCK = 4,
}

enum _:E_PTD_BASEBOARD
{
    PlayerText:PTD_BASEBOARD_CPF,
    PlayerText:PTD_BASEBOARD_PAYDAY,
    PlayerText:PTD_BASEBOARD_MONEY,
    PlayerText:PTD_BASEBOARD_LVL,
    PlayerText:PTD_BASEBOARD_BITCOIN,
}
