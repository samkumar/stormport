#include <Timer.h>

generic configuration Timer32khzC()
{
    provides interface Timer<T32khz>;
}
implementation
{
    components Timer32khzP;

    Timer = Timer32khzP.Timer32khz[unique(UQ_TIMER_32KHZ)];
}