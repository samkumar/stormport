
configuration HplSam4lASTC
{
    provides interface HplSam4lAST;
}
implementation
{
    components HplSam4lASTP, McuSleepC;
    HplSam4lAST = HplSam4lASTP;
    HplSam4lASTP.AlarmWrapper -> McuSleepC;
    HplSam4lASTP.OverflowWrapper -> McuSleepC;
}