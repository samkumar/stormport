
configuration HilTimer32khzC
{
    provides
    {
        interface Init;
        interface Timer<T32khz> as Timer32khz [uint8_t num];
        interface LocalTime<T32khz>;
    }
}
implementation
{
    components new VirtualizeTimerC(T32khz, uniqueCount(UQ_TIMER_32KHZ)) as VirtTimer;
    components new AlarmToTimerC(T32khz) as AlarmToTimer;
    components new Alarm32khzC() as Alarm;
    components HalSam4lASTP;

    Init = HalSam4lASTP;
    Timer32khz = VirtTimer.Timer;
    LocalTime = HalSam4lASTP;

    VirtTimer.TimerFrom -> AlarmToTimer.Timer;
    AlarmToTimer.Alarm -> Alarm;
}