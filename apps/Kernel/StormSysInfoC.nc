configuration StormSysInfoC
{
    provides interface Driver;
}
implementation
{
    components StormSysInfoP;
    components LocalIeeeEui64P;
    StormSysInfoP.LocalIeeeEui64 -> LocalIeeeEui64P;
    Driver = StormSysInfoP;
}
