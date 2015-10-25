configuration ScrufflesC
{
    provides interface Scruffles;
    provides interface StdControl;
}
implementation
{
    components ScrufflesP;
    Scruffles = ScrufflesP;
    StdControl = ScrufflesP;
    components HplSam4lClockC;
    ScrufflesP.WDTClockCtl -> HplSam4lClockC.WDTCtl;
}
