configuration ScrufflesDriverC
{
    provides interface Driver;
}
implementation
{
    components ScrufflesC;
    components ScrufflesDriverP;
    components RealMainP;

    Driver = ScrufflesDriverP.Driver;
    ScrufflesDriverP.Init <- RealMainP.SoftwareInit;
    ScrufflesDriverP.StdControl -> ScrufflesC;
    ScrufflesDriverP.Scruffles -> ScrufflesC;
}
