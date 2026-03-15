<<<<<<< HEAD
#include <YSI\YSI_Coding\y_hooks>

hook OnGameModeInit()
{
    Login::CreatePublicTD();
    printf("[ TEXTDRAW ] TextDraw: Login carregada\n");
    DC::LoadCountTextDraws++;

    Baseboard::CreatePublicTD();
    printf("[ TEXTDRAW ] TextDraw: Rodape carregada\n");
    DC::LoadCountTextDraws++;

    Acessory::CreatePublicTD();
    printf("[ TEXTDRAW ] TextDraw: Editor de acessorios carregada\n");
    DC::LoadCountTextDraws++;

    Adm::CreatePublicTD();
    printf("[ TEXTDRAW ] TextDraw: Administracao carregada\n");
    DC::LoadCountTextDraws++;

    Veh::CreatePublicTD();
    printf("[ TEXTDRAW ] TextDraw: Velocimetro carregada\n");
    DC::LoadCountTextDraws++;

    Dealership::CreatePublicTD();
    printf("[ TEXTDRAW ] TextDraw: Concessionaria carregada\n");
    DC::LoadCountTextDraws++;

    Garage::CreatePublicTD();
    printf("[ TEXTDRAW ] TextDraw: Garagem carregada\n");
    DC::LoadCountTextDraws++;

    return 1;
}

hook OnGameModeExit()
{
    Login::DestroyPublicTD();
    Baseboard::DestroyPublicTD();
    Acessory::DestroyPublicTD();
    Adm::DestroyPublicTD();
    Veh::DestroyPublicTD();
    Dealership::DestroyPublicTD();
    Garage::DestroyPublicTD();

    return 1;
}
=======
#include <YSI\YSI_Coding\y_hooks>

hook OnGameModeInit()
{
    Login::CreatePublicTD();
    printf("[ TEXTDRAW ] TextDraw: Login carregada\n");
    DC::LoadCountTextDraws++;

    Baseboard::CreatePublicTD();
    printf("[ TEXTDRAW ] TextDraw: Rodape carregada\n");
    DC::LoadCountTextDraws++;

    Acessory::CreatePublicTD();
    printf("[ TEXTDRAW ] TextDraw: Editor de acessorios carregada\n");
    DC::LoadCountTextDraws++;

    Adm::CreatePublicTD();
    printf("[ TEXTDRAW ] TextDraw: Administracao carregada\n");
    DC::LoadCountTextDraws++;

    Veh::CreatePublicTD();
    printf("[ TEXTDRAW ] TextDraw: Velocimetro carregada\n");
    DC::LoadCountTextDraws++;

    Dealership::CreatePublicTD();
    printf("[ TEXTDRAW ] TextDraw: Concessionaria carregada\n");
    DC::LoadCountTextDraws++;

    Garage::CreatePublicTD();
    printf("[ TEXTDRAW ] TextDraw: Garagem carregada\n");
    DC::LoadCountTextDraws++;

    return 1;
}

hook OnGameModeExit()
{
    Login::DestroyPublicTD();
    Baseboard::DestroyPublicTD();
    Acessory::DestroyPublicTD();
    Adm::DestroyPublicTD();
    Veh::DestroyPublicTD();
    Dealership::DestroyPublicTD();
    Garage::DestroyPublicTD();

    return 1;
}
>>>>>>> a0ec1b3e12ea77b24794a551738f1565733ad433
