configuration UDPDriverC
{
    provides interface Driver;
}
implementation
{
    components RealMainP;
    components UDPDriverP;
    components UdpP;
    components IPDispatchC;
    UDPDriverP.Init <- RealMainP.SoftwareInit;
    UDPDriverP.UDP -> UdpP.UDP;
    UDPDriverP.ip_stats -> IPDispatchC;
    UDPDriverP.retry_stats -> IPDispatchC;
    UDPDriverP.udp_stats -> UdpP;
    Driver = UDPDriverP.Driver;
}
