#include "printf.h"
module BreakMeAppP
{
    uses interface Boot;
    uses interface Timer<T32khz> as TimerA;
    uses interface Timer<T32khz> as TimerB;
#ifdef DEFINE_ALL_TIMERS
    uses interface Timer<T32khz> as TimerC;
    uses interface Timer<T32khz> as TimerD;
    uses interface Timer<T32khz> as TimerE;
    uses interface Timer<T32khz> as TimerF;
#endif
}
implementation
{
    void SVC_Handler() @C() @spontaneous() __attribute__(( naked )) {}
    bool run_process() @C() @spontaneous() { return TRUE; }

    task void nulltask()
    {
        printf("\n");
    }

    task void restartoneshot()
    {
        printf("restartoneshot\n");
        call TimerB.startOneShot(100);

        //call TimerE.startOneShot(1000);
        //call TimerF.startOneShot(1000);
    }

    event void Boot.booted()
    {
        printf("Booted!\n");

        call TimerA.startPeriodic(10);
        call TimerB.startOneShot(100);

        //call TimerC.startPeriodic(10);
        //call TimerD.startPeriodic(10);
        //call TimerE.startOneShot(200);
        //call TimerF.startOneShot(500);
    }

    event void TimerA.fired()
    {
        post nulltask();
    }

    event void TimerB.fired()
    {
        printf("Timer B fire\n");
        post restartoneshot();
    }


#ifdef DEFINE_ALL_TIMERS
    event void TimerC.fired()
    {
        printf("Timer C fire\n");
        post nulltask();
    }

    event void TimerD.fired()
    {
        printf("Timer D fire\n");
        post nulltask();
    }

    event void TimerE.fired()
    {
        printf("Timer E fire\n");
        post restartoneshot();
    }

    event void TimerF.fired()
    {
        printf("Timer F fire\n");
        post restartoneshot();
    }
#endif


}
