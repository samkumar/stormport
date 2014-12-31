configuration TimerDriverC
{
    provides interface Driver;
}
implementation
{
    components RealMainP;
    components TimerDriverP;
    components HplSam4lClockC;
    TimerDriverP.ClockCntl -> HplSam4lClockC.TC0Ctl;
    TimerDriverP.Init <- RealMainP.SoftwareInit;
    Driver = TimerDriverP.Driver;
}