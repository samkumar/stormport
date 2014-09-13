
module PlatformSerialP
{
    provides
    {
        interface StdControl;
        interface Init;
    }
    uses
    {
        interface UartControl;
    }
}
implementation
{
    command error_t Init.init()
    {
        call UartControl.setDuplexMode(TOS_UART_DUPLEX);
        call UartControl.setSpeed(115200);
        return SUCCESS;
    }
    command error_t StdControl.start()
    {
        call UartControl.setDuplexMode(TOS_UART_DUPLEX);
        return SUCCESS;
    }
    command error_t StdControl.stop()
    {
        call UartControl.setDuplexMode(TOS_UART_OFF);
        return SUCCESS;
    }


}
