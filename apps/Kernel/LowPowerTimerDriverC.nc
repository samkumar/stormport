configuration LowPowerTimerDriverC
{
    provides interface Driver;
}
implementation
{
    components new Alarm32khzC() as valarm;
    components LowPowerTimerDriverP;

    LowPowerTimerDriverP.Alarm -> valarm;
    Driver = LowPowerTimerDriverP.Driver;
}

