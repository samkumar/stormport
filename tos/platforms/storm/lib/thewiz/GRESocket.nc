#include <lib6lowpan/iovec.h>

interface GRESocket
{
    command void initialize();
    event void initializeDone(error_t error);

    command void sendPacket(struct ip_iovec data);
    event void sendPacketDone(error_t error);

    event void packetReceived(uint8_t *buf, uint16_t len);
}
