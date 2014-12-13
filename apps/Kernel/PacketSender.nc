interface PacketSender
{
    // send [len] bytes from buffer [buf]
    command void sendPacket(struct ip_iovec *data);

    // called when the packet has finished sending
    event void sendPacketDone(error_t error);

    // called upon recipt of a packet over ethernet
    // It should start with a 20 byte IPv6 header
    event void packetReceived(uint8_t *buf, uint16_t len);
}