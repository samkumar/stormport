configuration UDPDriverC
{
    provides interface Driver;
}
implementation
{
    components RealMainP;
    components UDPDriverP;
    components UdpP;
    UDPDriverP.Init <- RealMainP.SoftwareInit;
    UDPDriverP.UDP -> UdpP.UDP;
    Driver = UDPDriverP.Driver;
}