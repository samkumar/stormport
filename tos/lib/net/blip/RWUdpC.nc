configuration RWUdpC
{
    provides interface UDP[uint8_t clnt];
}
implementation
{
    components RWUdpP, UdpC;
    UDP = RWUdpP.RWUDP;
    RWUdpP.UDP -> UdpC;

    components new Timer32khzC();
    RWUdpP.ResendTimer -> Timer32khzC;
}
