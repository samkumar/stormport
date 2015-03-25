configuration StormSysInfoC
{
    provides interface Driver;
}
implementation
{
    components StormSysInfoP;
    components LocalIeeeEui64P;
    components McuSleepC;
    StormSysInfoP.LockLevel -> McuSleepC;
    StormSysInfoP.LocalIeeeEui64 -> LocalIeeeEui64P;
    Driver = StormSysInfoP;
}
