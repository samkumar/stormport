module GRESocketP
{
    uses interface RawSocket;

    provides interface GRESocket;
}
implementation
{
    command void GRESocket.initialize()
    {
        call RawSocket.initialize(0x2F); // 0x2F == 47 == GRE protocol
    }

    event void RawSocket.initializeDone(error_t error)
    {
        signal GRESocket.initializeDone(error);
    }

    /**
     * GRE Packet Header
     * Bits 0-3: Checksum, _, Key, Sequence (1 if exists) -- we will probably just set these all to 0
     * Bits 4-12: reserved0 (set to 0)
     * Bits 13-15: GRE version (set to 0)
     * Bits 16-31: ether protocol type of encapsulated payload (ipv4 is 0x0800, ipv6 is 0x86dd)
     * if any bits 0-3 were set, we'd have more fields here, else we just start the packet
     */
    command void GRESocket.sendPacket(uint32_t destip, struct ip_iovec *data)
    {
        // add the GRE packet header
        struct ip_iovec greh;
        uint32_t header = 0xDD860000; // all bits are 0 except for protocol type
        int i;

        greh.iov_len = 4;
        greh.iov_base = (uint8_t*) &header;
        greh.iov_next = data;

        call RawSocket.sendPacket(destip, &greh);
    }

    event void RawSocket.sendPacketDone(error_t error)
    {
        signal GRESocket.sendPacketDone(error);
    }

    event void RawSocket.packetReceived(uint8_t *buf, uint16_t len)
    {
        signal GRESocket.packetReceived(buf, len);
    }
}
