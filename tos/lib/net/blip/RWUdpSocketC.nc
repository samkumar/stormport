generic configuration RWUdpSocketC()
{
    provides interface UDP as RWUDP;
}
implementation
{
    components RWUdpC;
    RWUDP = RWUdpC.UDP[unique("UDP_CLIENT")];
}
