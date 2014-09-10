
configuration HalSam4lASTC
{
    provides
    {
        interface Alarm<T32khz,uint32_t> as Alarm;
        interface LocalTime<T32khz> as LocalTime;
        interface Counter<T32khz,uint32_t> as Counter;
    }
}
implementation
{
    components MainC, HplSam4lBPMC, HplSam4lASTC, HplSam4lClockC, HplSam4lBSCIFC, HalSam4lASTP;

    HalSam4lASTP.ast -> HplSam4lASTC;
    HalSam4lASTP.bpm -> HplSam4lBPMC;
    HalSam4lASTP.bscif -> HplSam4lBSCIFC;
    HalSam4lASTP.ASTClockCtl -> HplSam4lClockC.ASTCtl;
    HalSam4lASTP.Init <- MainC;

    Alarm = HalSam4lASTP;
    LocalTime = HalSam4lASTP;
    Counter = HalSam4lASTP;

}