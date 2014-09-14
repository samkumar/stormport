/**
 * @author Michael Andersen
 */
configuration SerialPrintfC
{

}
implementation
{
    components SerialPrintfP;
    components PlatformSerialC;

    SerialPrintfP.UartStream -> PlatformSerialC;
    SerialPrintfP.UartByte -> PlatformSerialC;
}