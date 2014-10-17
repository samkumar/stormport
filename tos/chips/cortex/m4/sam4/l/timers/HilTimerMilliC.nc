#include <sam4ltimer.h>
configuration HilTimerMilliC
{
    provides
    {
        interface Init;
        interface Timer<TMilli> as TimerMilli [uint8_t id];
        interface LocalTime<TMilli>;
        interface Alarm<TMilli, uint32_t> as AlarmMilli32 [uint8_t id];
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
    components new VirtualizeAlarmC(TMilli, uint32_t, uniqueCount(UQ_ALARM_MILLI));

    Init = NoInitC;
    TransformAlarmCounterC.CounterFrom -> HalSam4lASTC.Counter;
    TransformAlarmCounterC.AlarmFrom -> Alarm32khzC;
    CounterToLocalTimeC.Counter -> TransformAlarmCounterC.Counter;

    VirtualizeAlarmC.AlarmFrom -> TransformAlarmCounterC.Alarm;

    AlarmToTimerC.Alarm -> VirtualizeAlarmC.Alarm[unique(UQ_ALARM_MILLI)];
    AlarmMilli32 = VirtualizeAlarmC.Alarm;

    VirtualizeTimerC.TimerFrom -> AlarmToTimerC.Timer;

    TimerMilli = VirtualizeTimerC.Timer;
    LocalTime = CounterToLocalTimeC.LocalTime;


}