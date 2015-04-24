configuration SPIDriverC
{
    provides interface Driver;
}
implementation
{
    components HplSam4lIOC;
    components new Sam4lUSART0C() as SPI;
    components SPIDriverP;
    components RealMainP;

    SPIDriverP.SpiPacket -> SPI.SpiPacket;
    SPIDriverP.SpiHPL -> SPI;
    SPIDriverP.CS -> HplSam4lIOC.PB12;

    Driver = SPIDriverP.Driver;
    SPIDriverP.Init <- RealMainP.SoftwareInit;
}