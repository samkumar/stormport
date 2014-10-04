
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
        interface HplSam4lUSART;
    }
}
implementation
{
    command error_t Init.init()
    {
        //The default platform serial pins are PB10 and PB09
        call HplSam4lUSART.enableUSARTPin(USART3_TX_PB10);
        call HplSam4lUSART.enableUSARTPin(USART3_RX_PB09);

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
