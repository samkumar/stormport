
module BusyWaitMicroP
{
    provides interface BusyWait<TMicro, uint16_t>;
    uses interface HplSam4Clock;
}
implementation
{
    async command void BusyWait.wait(uint16_t m)
    {
        volatile uint32_t then = call HplSam4Clock.getSysTicks();
        volatile uint32_t req_ticks = m;
        volatile int32_t tgt;
        volatile int32_t delta = 0;
        //multiply required microseconds by number of ticks per ms
        req_ticks *= call HplSam4Clock.getMainClockSpeed();
        //but we want ticks per microsecond
        req_ticks /= 1000;
        tgt = (int32_t)then - req_ticks;
        if (then < (call HplSam4Clock.getSysTicksWrapVal() >> 1))
        {
            delta = call HplSam4Clock.getSysTicksWrapVal() >> 1;
        }
        tgt += delta;
        while ( ((call HplSam4Clock.getSysTicks() + delta)%(call HplSam4Clock.getSysTicksWrapVal())) > tgt);
    }

    async event void HplSam4Clock.mainClockChanged() {}
}