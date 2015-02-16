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
    components NrfBleP, HelenaServiceC;
    components new Sam4lUSART2C() as NrfSPI;
    components new SpiBleLocalCharC() as UUIDListedDevice;
    components new SpiBleLocalServiceC() as HelenaBleService;

    HelenaServiceC.UUIDListedDevice -> UUIDListedDevice;
    HelenaServiceC.BLE -> HelenaBleService;

    NrfBleP.SpiPacket -> NrfSPI.SpiPacket;
    NrfBleP.SpiHPL -> NrfSPI;
    NrfBleP.CS -> HplSam4lIOC.PC07;
    NrfBleP.IntPort -> HplSam4lIOC.PA17;
    NrfBleP.Int -> HplSam4lIOC.PA17IRQ;

    BLEDriverP.BlePeripheral -> NrfBleP;
    BLEDriverP.HelenaBleService -> HelenaServiceC;

    Driver = BLEDriverP.Driver;
    components new Timer32khzC();
    BLEDriverP.tmr -> Timer32khzC;
    BLEDriverP.Init <- RealMainP.SoftwareInit;
}