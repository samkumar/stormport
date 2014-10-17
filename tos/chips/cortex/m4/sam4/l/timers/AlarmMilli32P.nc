#include <sam4ltimer.h>
configuration AlarmMilli32P
{
    provides interface Alarm<TMilli, uint32_t> as AlarmMilli32[uint8_t id];
}
implementation
{
    components HilTimerMilliC, MainC;
    MainC.SoftwareInit -> HilTimerMilliC;
    AlarmMilli32 = HilTimerMilliC.AlarmMilli32;
}