configuration BlePECSC
{
    provides interface Driver;
}
implementation
{
    components HplSam4lIOC;
    components BlePECSP;
    components new Sam4lUSART1C();
    
    Driver = BlePECSP.Driver;
    
    BlePECSP.UartControl -> Sam4lUSART1C.UartControl;
    
    BlePECSP.UartStream -> Sam4lUSART1C.UartStream;
    BlePECSP.HplSam4lUSART -> Sam4lUSART1C.HplSam4lUSART;
}
