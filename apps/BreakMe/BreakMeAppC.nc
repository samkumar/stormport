configuration BreakMeAppC
{}
implementation
{
    components MainC;
    components new Timer32khzC() as TimerA;
    components new Timer32khzC() as TimerB;
#ifdef DEFINE_ALL_TIMERS
    components new Timer32khzC() as TimerC;
    components new Timer32khzC() as TimerD;
    components new Timer32khzC() as TimerE;
    components new Timer32khzC() as TimerF;
#endif

    components SerialPrintfC;

    components BreakMeAppP;
    BreakMeAppP.Boot -> MainC;
    BreakMeAppP.TimerA -> TimerA;
    BreakMeAppP.TimerB -> TimerB;
#ifdef DEFINE_ALL_TIMERS
    BreakMeAppP.TimerC -> TimerC;
    BreakMeAppP.TimerD -> TimerD;
    BreakMeAppP.TimerE -> TimerE;
    BreakMeAppP.TimerF -> TimerF;
#endif
}
