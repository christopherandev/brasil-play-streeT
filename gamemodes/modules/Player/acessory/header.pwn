
#define INVALID_SLOTID      (-1)

#define MAX_ACS_OFFSET_POS  (0.5)
#define MAX_ACS_OFFSET_ANG  (180.0)
#define MAX_ACS_OFFSET_SCL  (1.0)

#define MAX_ACS_POS         (0.8)
#define MIN_ACS_POS         (-0.8)
#define MAX_ACS_ANG         (360)
#define MIN_ACS_ANG         (0.0)
#define MAX_ACS_SCL         (1.5)
#define MIN_ACS_SCL         (0.2)

/*                  PLAYER ACESSORYS                 */

enum _:AXIS_TYPE
{
    AXIS_TYPE_NONE = -1,
    AXIS_TYPE_X,
    AXIS_TYPE_Y,
    AXIS_TYPE_Z,
}

enum _:MEASUREMENT_TYPE
{
    MEA_TYPE_POSITION,
    MEA_TYPE_ANGLE,
    MEA_TYPE_SCALE,
}

enum E_PLAYER_ACESSORY
{
    acs::modelid,
    acs::slotid,
    acs::boneid,
    Float:acs::pX, Float:acs::pY, Float:acs::pZ,
    Float:acs::rX, Float:acs::rY, Float:acs::rZ,
    Float:acs::sX, Float:acs::sY, Float:acs::sZ,
    acs::color1, acs::color2,

    acs::flags,
    acs::camid,
    Float:acs::pOffset, Float:acs::aOffset, Float:acs::sOffset,
    acs::pAxis, acs::aAxis, acs::sAxis
}

enum (<<= 1)
{    
    FLAG_EDITING_ACS = 1, 
}

new acs::Player[MAX_PLAYERS][E_PLAYER_ACESSORY];

forward Response_ACC_MENU(playerid, dialogid, response, listitem, string:inputtext[]);
forward Response_ACC_OPTIONS(playerid, dialogid, response, listitem, string:inputtext[]);
forward Response_ACC_BONE(playerid, dialogid, response, listitem, string:inputtext[]);
forward Response_ACC_LOJA(playerid, dialogid, response, listitem, string:inputtext[]);

new gBoneName[][32] = 
{
    {"INVALID_BONE"}, {"Coluna"}, {"Cabeca"}, {"Braco esquerdo"}, {"Braco direito"}, {"Mao esquerda"},
    {"Mao direita"}, {"Coxa esquerda"}, {"Coxa direita"}, {"Pe esquerdo"}, {"Pe direito"},
    {"Panturrilha direita"}, {"Panturrilha esquerda"}, {"Antebraco esquerdo"}, {"Antebraco direito"},
    {"Ombro esquerdo"}, {"Ombro direito"}, {"Pescoco"}, {"Maxilar"}
};

new gAxisName[][8] = {{"Eixo X"}, {"Eixo Y"}, {"Eixo Z"} };

new Float:Acessory::gCamOffset[][6] =
{
    {-1.135681, -0.403320, -0.345319, -0.997536, -0.020563, -0.067073},
    {-0.621765, -0.896484, -0.333306, -0.791430, -0.594250, -0.143192},
    {-0.793701,  0.915649, -0.333306, -0.342547,  0.938410, -0.045233},
    {-0.182189,  0.689453, -0.651344, -0.021868,  0.999473, -0.023974},
    {0.585815,   0.147705, -0.651344,  0.997276, -0.069751, -0.023974},
    {-0.658447, -0.146484, -0.658907, -0.997040,  0.061724, -0.045835},
    {0.698608,  -0.394287, -0.243360,  0.818994, -0.560657, -0.122108},
    {-0.922302,  0.370361, -0.261321, -0.809996,  0.571164, -0.132956},
    {1.242004,   0.485839,  0.416791,  0.997580, -0.015914, -0.067674},
    {-1.132934, -0.138549,  0.432420, -0.997250,  0.062141, -0.040371},
    {0.200012,  -1.198120,  0.417545, -0.101406, -0.992897, -0.062217},
    {0.461608,  -0.244140,  0.708893,  0.669668, -0.550676, -0.498296},
    {-0.700195,  0.053222,  0.711026, -0.958514,  0.242879, -0.149198},
    {0.631713,   0.252441,  0.760899,  0.986556,  0.033236, -0.160004}
};

new Text:Acessory::PublicTD[21] = {INVALID_TEXT_DRAW, ...};
new PlayerText:Acessory::PlayerTD[MAX_PLAYERS][14] = {{INVALID_PLAYER_TEXT_DRAW, ...}, ...};

enum _:E_TD_ACESSORY
{
    Text:TD_ACS_OFFSET_POS_MINUS = 3,
    Text:TD_ACS_OFFSET_ANG_MINUS = 4,
    Text:TD_ACS_OFFSET_SCL_MINUS = 5,
    Text:TD_ACS_OFFSET_POS_PLUS = 6,
    Text:TD_ACS_OFFSET_ANG_PLUS = 7,
    Text:TD_ACS_OFFSET_SCL_PLUS = 8,
    Text:TD_ACS_SAVE_BTN = 9,
    Text:TD_ACS_CHANGE_VIEW_BTN = 10,
    Text:TD_ACS_EXIT_BTN = 11,
    Text:TD_ACS_OFFSET_POS_BTN = 14,
    Text:TD_ACS_OFFSET_ANG_BTN = 15,
    Text:TD_ACS_OFFSET_SCL_BTN = 16,
}

enum _:E_PTD_ACESSORY
{
    PlayerText:PTD_ACS_MODEL_1,
    PlayerText:PTD_ACS_MODEL_2,
    PlayerText:PTD_ACS_MODEL_3,
    PlayerText:PTD_ACS_MODEL_4,
    PlayerText:PTD_ACS_MODEL_5,
    PlayerText:PTD_ACS_OFFSET_POS,
    PlayerText:PTD_ACS_OFFSET_ANG,
    PlayerText:PTD_ACS_OFFSET_SCL,
    PlayerText:PTD_ACS_POS_AXIS_BTN,
    PlayerText:PTD_ACS_ANG_AXIS_BTN,
    PlayerText:PTD_ACS_SCL_AXIS_BTN,
    PlayerText:PTD_ACS_POS_AXIS,
    PlayerText:PTD_ACS_ANG_AXIS,
    PlayerText:PTD_ACS_SCL_AXIS,
}
