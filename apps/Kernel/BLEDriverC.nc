configuration BLEDriverC
{
    provides interface Driver;
}
implementation
{
    //BLE STUFF
    components HplSam4lIOC;
    components RealMainP;
    components BLEDriverP;
    components NrfBleP;
    components new Sam4lUSART2C() as NrfSPI;

    NrfBleP.SpiPacket -> NrfSPI.SpiPacket;
    NrfBleP.SpiHPL -> NrfSPI;
    NrfBleP.CS -> HplSam4lIOC.PC07;
    NrfBleP.IntPort -> HplSam4lIOC.PA17;
    NrfBleP.Int -> HplSam4lIOC.PA17IRQ;
    components new Timer32khzC() as bletmr;
    NrfBleP.tmr -> bletmr;

    BLEDriverP.BlePeripheral -> NrfBleP;

    Driver = BLEDriverP.Driver;
    components new Timer32khzC();
    BLEDriverP.tmr -> Timer32khzC;
    BLEDriverP.Init <- RealMainP.SoftwareInit;
    BLEDriverP.NrfBleService -> NrfBleP;
    BLEDriverP.BleLocalChar -> NrfBleP;
}