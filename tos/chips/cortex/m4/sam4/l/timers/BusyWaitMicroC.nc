
configuration BusyWaitMicroC
{
    provides interface BusyWait<TMicro, uint16_t>;
}
implementation
{
    components BusyWaitMicroP, HplSam4lClockC;
    BusyWait = BusyWaitMicroP;
    BusyWaitMicroP.HplSam4Clock -> HplSam4lClockC;
}