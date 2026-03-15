<<<<<<< HEAD
#define MAX_COMPY_GAS (1)

enum E_COMPY_GAS
{
    Float:gas::pX[2], 
    Float:gas::pY[2], 
    Float:gas::pZ[2],
    STREAMER_TAG_PICKUP:gas::pickup[2],
    STREAMER_TAG_3D_TEXT_LABEL:gas::label[2],
}

=======
#define MAX_COMPY_GAS (1)

enum E_COMPY_GAS
{
    Float:gas::pX[2], 
    Float:gas::pY[2], 
    Float:gas::pZ[2],
    STREAMER_TAG_PICKUP:gas::pickup[2],
    STREAMER_TAG_3D_TEXT_LABEL:gas::label[2],
}

>>>>>>> a0ec1b3e12ea77b24794a551738f1565733ad433
new Compy::Gas[MAX_COMPY_GAS][E_MAP_GAS];