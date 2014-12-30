#include "printf.h"
module BreakMeAppP
{
    uses interface Boot;
    uses interface Alarm<T32khz,uint32_t> as Alarm;
}
implementation
{
    void SVC_Handler() @C() @spontaneous() __attribute__(( naked )) {}
    bool run_process() @C() @spontaneous() { return FALSE; }

    task void nulltask()
    {
        printf("a");
    }

    event void Boot.booted()
    {
        printf("Booted!\n");

        call Alarm.start(10);
    }

    async event void Alarm.fired()
    {
        post nulltask();
    }

}
