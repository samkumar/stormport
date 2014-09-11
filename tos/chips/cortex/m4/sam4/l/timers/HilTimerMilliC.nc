
configuration HilTimerMilliC
{
    provides
    {
        interface Init;
        interface Timer<TMilli> as TimerMilli [uint8_t id];
        interface LocalTime<TMilli>;
    }
}
implementation
{
    components new Alarm32khzC(),
               HalSam4lASTC,
               new TransformAlarmCounterC(TMilli, uint32_t, T32khz, uint32_t, 5, uint32_t),
               new AlarmToTimerC(TMilli),
               new CounterToLocalTimeC(TMilli),
               new VirtualizeTimerC(TMilli, uniqueCount(UQ_TIMER_MILLI)),
               NoInitC;

    Init = NoInitC;
    TransformAlarmCounterC.CounterFrom -> HalSam4lASTC.Counter;
    TransformAlarmCounterC.AlarmFrom -> Alarm32khzC;
    CounterToLocalTimeC.Counter -> TransformAlarmCounterC.Counter;
    AlarmToTimerC.Alarm -> TransformAlarmCounterC.Alarm;
    VirtualizeTimerC.TimerFrom -> AlarmToTimerC.Timer;

    TimerMilli = VirtualizeTimerC.Timer;
    LocalTime = CounterToLocalTimeC.LocalTime;


}