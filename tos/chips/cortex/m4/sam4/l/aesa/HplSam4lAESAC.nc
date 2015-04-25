configuration HplSam4lAESAC
{
    provides interface HplSam4lAESA;
}
implementation
{
    components HplSam4lAESAP;
    components HplSam4lClockC;
    components RealMainP;
    HplSam4lAESAP.ClockCtl -> HplSam4lClockC.AESACtl;
    HplSam4lAESAP.Init <- RealMainP.SoftwareInit;
    HplSam4lAESA = HplSam4lAESAP.HplSam4lAESA;
}