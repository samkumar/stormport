configuration I2CDriverC
{
    provides interface Driver;
}
implementation
{
    components RealMainP;
    components I2CDriverP;
    components HplSam4lTWIMP;

    components HplSam4lClockC;
    components new Sam4lDMAChannelC() as dmac1;
    components new Sam4lDMAChannelC() as dmac2;
    HplSam4lTWIMP.ClockCtl[1] -> HplSam4lClockC.TWIM1Ctl;
    HplSam4lTWIMP.ClockCtl[2] -> HplSam4lClockC.TWIM2Ctl;
    HplSam4lTWIMP.dmac[1] -> dmac1;
    HplSam4lTWIMP.dmac[2] -> dmac2;
    I2CDriverP.Init <- RealMainP.SoftwareInit;
    I2CDriverP.HplSam4lTWIM -> HplSam4lTWIMP.TWIM;
    Driver = I2CDriverP.Driver;
}