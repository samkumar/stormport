#include <sam4ltimer.h>

configuration HilAlarm32khzC
{
    provides
    {
        interface Init;
        interface Alarm<T32khz, uint32_t> as Alarm32khz [uint8_t id];
    }
}
implementation
{
    components HalSam4lASTC;
    components new VirtualizeAlarmC(T32khz, uint32_t, uniqueCount(UQ_ALARM_T32KHZ));

    Init = HalSam4lASTC;
    Alarm32khz = VirtualizeAlarmC.Alarm;
    VirtualizeAlarmC.AlarmFrom -> HalSam4lASTC;
}