#include <lib6lowpan/iovec.h>

interface RawSocket
{
    // use this socket for IPRAW
    command void initialize();

    event void initializeDone(error_t error);

    command void sendPacket(struct ip_iovec data);

    // called when the packet has finished sending
    event void sendPacketDone(error_t error);

    // called upon recipt of a packet over ethernet
    event void packetReceived(uint8_t *buf, uint16_t len);
}
