
configuration HplSam4lBPMC
{
    provides interface HplSam4lBPM;
}
implementation
{
    components HplSam4lBPMP;
    HplSam4lBPM = HplSam4lBPMP;
}