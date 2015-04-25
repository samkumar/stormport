configuration AESDriverC
{
    provides interface Driver;
}
implementation
{
    components RealMainP;
    components UDPDriverP;
    components AESDriverP;
    components UdpP;
    components IPDispatchC;
    components HplSam4lAESAC as AES;
    AESDriverP.HplSam4lAESA -> AES;
    AESDriverP.Init <- RealMainP.SoftwareInit;
    Driver = AESDriverP.Driver;
}