configuration UDPDriverC
{
    provides interface Driver;
}
implementation
{
    components RealMainP;
    components UDPDriverP;
    //components UdpP;
    components RWUdpP;
    UDPDriverP.Init <- RealMainP.SoftwareInit;
    //UDPDriverP.UDP -> UdpP.UDP;
    UDPDriverP.UDP -> RWUdpP.RWUDP;
    Driver = UDPDriverP.Driver;
}
