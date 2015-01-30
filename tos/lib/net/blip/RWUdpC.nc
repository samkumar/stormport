#include "rwudp.h"

configuration RWUdpC
{
    provides interface UDP[uint8_t clnt];
}
implementation
{
    components RWUdpP, UdpC;
    UDP = RWUdpP.RWUDP;
    RWUdpP.UDP -> UdpC;

    components new Timer32khzC();
    RWUdpP.SendTimer -> Timer32khzC;

    components new QueueC(struct rwudp_packet *, RWUDP_SEND_QUEUE_SIZE);
    RWUdpP.SendQueue -> QueueC.Queue;

    components new PoolC(struct rwudp_packet, RWUDP_SEND_QUEUE_SIZE);
    RWUdpP.PacketPool -> PoolC.Pool;
}
