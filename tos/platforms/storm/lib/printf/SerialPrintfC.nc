configuration SerialPrintfC
{

}
implementation
{
    components PlatformSerialC, SerialPrintfP, RealMainP;
    SerialPrintfP.Init <- RealMainP.PlatformInit;
    SerialPrintfP.UartByte -> PlatformSerialC;
}