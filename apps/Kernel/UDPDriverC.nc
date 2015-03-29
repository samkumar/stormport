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
    components RPLRoutingC;
    UDPDriverP.Init <- RealMainP.SoftwareInit;
    UDPDriverP.UDP -> UdpP.UDP;
    UDPDriverP.ip_stats -> IPDispatchC;
    UDPDriverP.retry_stats -> IPDispatchC;
    UDPDriverP.rpl_dio_dis_stats -> RPLRoutingC.RplStatisticsDIODIS;
    UDPDriverP.rpl_dao_stats -> RPLRoutingC.RplStatisticsDAO;
    UDPDriverP.udp_stats -> UdpP;
    Driver = UDPDriverP.Driver;
}
