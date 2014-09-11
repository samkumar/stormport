
#include <sam4ltimer.h>

generic configuration Alarm32khzC ()
{
    provides interface Alarm<T32khz, uint32_t>;
}
implementation
{
    components Alarm32khzP;
    Alarm = Alarm32khzP.Alarm32khz[unique(UQ_ALARM_T32KHZ)];
}