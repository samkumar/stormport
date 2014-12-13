module EthernetUdpWiz5200P
{
    provides interface PacketSender as UDPSender;
}
implementation
{
    command void UDPSender.sendPacket(struct ip_iovec data)
    {
    }

}
