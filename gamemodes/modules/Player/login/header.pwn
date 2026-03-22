new Text:Login::PublicTD[7] = {INVALID_TEXT_DRAW, ...};
new PlayerText:Login::PlayerTD[MAX_PLAYERS][3] = {{INVALID_PLAYER_TEXT_DRAW, ...}, ...};

enum _:E_TD_LOGIN
{
    Text:TD_LOGIN_SEL = 5,
}

enum _:E_PTD_LOGIN
{
    PlayerText:PTD_LOGIN_TITLE,
    PlayerText:PTD_LOGIN_NAME,
    PlayerText:PTD_LOGIN_PASS,
}
