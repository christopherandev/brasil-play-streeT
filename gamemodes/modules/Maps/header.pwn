#define MAX_REMOVE_BUILDING (1000)

enum E_REMOVE_BUILDS
{
	map::modelid,
	Float:map::pX,
	Float:map::pY,
	Float:map::pZ,
	Float:map::range,
}

new RemovedBuilding[MAX_REMOVE_BUILDING][E_REMOVE_BUILDS];


