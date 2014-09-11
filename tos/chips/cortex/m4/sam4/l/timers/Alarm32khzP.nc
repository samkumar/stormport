configuration Alarm32khzP
{
    provides interface Alarm<T32khz, uint32_t> as Alarm32khz[uint8_t id];
}
implementation
{
    components HilAlarm32khzC, MainC;
    MainC.SoftwareInit -> HilAlarm32khzC;
    Alarm32khz = HilAlarm32khzC;
}