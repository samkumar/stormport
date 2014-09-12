configuration HplSam4lSPIC
{
    provides
    {
        interface HplSam4lSPIChannel as ch0;
        interface HplSam4lSPIChannel as ch1;
        interface HplSam4lSPIChannel as ch2;
        interface HplSam4lSPIChannel as ch3;
        interface HplSam4lSPIControl as ctl;
    }
}
implementation
{

}