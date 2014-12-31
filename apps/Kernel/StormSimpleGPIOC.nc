configuration StormSimpleGPIOC
{
    provides interface Driver;
}
implementation
{
    components StormSimpleGPIOP;
    components HplSam4lGeneralIOPortP;
    StormSimpleGPIOP.PortA_IRQ -> HplSam4lGeneralIOPortP.PortA_IRQ;
    StormSimpleGPIOP.PortB_IRQ -> HplSam4lGeneralIOPortP.PortB_IRQ;
    StormSimpleGPIOP.PortC_IRQ -> HplSam4lGeneralIOPortP.PortC_IRQ;
    StormSimpleGPIOP.PortA -> HplSam4lGeneralIOPortP.PortA;
    StormSimpleGPIOP.PortB -> HplSam4lGeneralIOPortP.PortB;
    StormSimpleGPIOP.PortC -> HplSam4lGeneralIOPortP.PortC;
    Driver = StormSimpleGPIOP;
}