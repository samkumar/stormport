configuration FireStormSensorsC
{
    provides
    {
        interface FSAccelerometer;
        interface FSIlluminance;
        interface SplitControl;
    }
}
implementation
{
    components RealMainP, HplSam4lIOC, FireStormSensorsP;
    components new TimerMilliC() as Timer;

    components new SoftwareI2CPacketC(10);
    SoftwareI2CPacketC.SDA -> HplSam4lIOC.PB01;
    SoftwareI2CPacketC.SCL -> HplSam4lIOC.PB00;

    components BusyWaitMicroC;
    SoftwareI2CPacketC.BusyWait -> BusyWaitMicroC;

    FireStormSensorsP.I2CPacket -> SoftwareI2CPacketC;

    FireStormSensorsP.Timer -> Timer;
    FireStormSensorsP.ENSEN -> HplSam4lIOC.PC19;

    FSAccelerometer = FireStormSensorsP;
    FSIlluminance = FireStormSensorsP;
    SplitControl = FireStormSensorsP;

}