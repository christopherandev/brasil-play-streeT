<<<<<<< HEAD
enum(<<= 1)
{
    FLAG_NPC_EXIST = 1,
}

enum E_NPC
{
    npc::id,
    npc::flags,
    STREAMER_TAG_3D_TEXT_LABEL:npc::nametag
}

enum E_NPC_NAME
{
    NPC_LETICIA,
    NPC_ROGERIO
}

#define NPC_INVALID (E_NPC_NAME:0)

=======
enum(<<= 1)
{
    FLAG_NPC_EXIST = 1,
}

enum E_NPC
{
    npc::id,
    npc::flags,
    STREAMER_TAG_3D_TEXT_LABEL:npc::nametag
}

enum E_NPC_NAME
{
    NPC_LETICIA,
    NPC_ROGERIO
}

#define NPC_INVALID (E_NPC_NAME:0)

>>>>>>> a0ec1b3e12ea77b24794a551738f1565733ad433
new NPC[MAX_NPCS][E_NPC];