#include <lib6lowpan/iovec.h>

module DummyPacketSenderP
{
    provides interface PacketSender;
}
implementation
{
    // send [len] bytes from buffer [buf]
    command void PacketSender.sendPacket(struct ip_iovec *dat)
    {
        printf("DUMMY SEND PACKET\n");
        signal PacketSender.sendPacketDone(SUCCESS);
    }

  /*  // called when the packet has finished sending
    event void PacketSender.sendPacketDone(error_t error)
    {

    }


    event void PacketSender.packetReceived(uint8_t *buf, uint16_t len)
    {

    }*/
}