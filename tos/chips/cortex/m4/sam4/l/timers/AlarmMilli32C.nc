
#include <sam4ltimer.h>

generic configuration AlarmMilli32C ()
{
    provides interface Alarm<TMilli, uint32_t>;
}
implementation
{
    components AlarmMilli32P;
    Alarm = AlarmMilli32P.AlarmMilli32[unique(UQ_ALARM_MILLI)];
}