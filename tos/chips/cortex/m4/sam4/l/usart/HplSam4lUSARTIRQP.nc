module HplSam4lUSARTIRQP
{
    uses
    {
        interface HplSam4lUSART_UART as usart0;
        interface HplSam4lUSART_UART as usart1;
        interface HplSam4lUSART_UART as usart2;
        interface HplSam4lUSART_UART as usart3;
        interface FunctionWrapper as IRQWrapper;
    }
    provides
    {
        interface HplSam4lUSART_UARTIRQ as usart0irq;
        interface HplSam4lUSART_UARTIRQ as usart1irq;
        interface HplSam4lUSART_UARTIRQ as usart2irq;
        interface HplSam4lUSART_UARTIRQ as usart3irq;
    }
}
implementation
{
    void USART0_Handler() @C() @spontaneous()
    {
        call IRQWrapper.preamble();
        if (call usart0.isRXRdy() && call usart0.isRXRdyIRQEnabled())
        {
            signal usart0.RXRdyFired();
        }
        if (call usart0.isTXRdy() && call usart0.isTXRdyIRQEnabled())
        {
            signal usart0.TXRdyFired();
        }
        call IRQWrapper.postamble();
    }

    void USART1_Handler() @C() @spontaneous()
    {
        call IRQWrapper.preamble();
        if (call usart1.isRXRdy() && call usart1.isRXRdyIRQEnabled())
        {
            signal usart1.RXRdyFired();
        }
        if (call usart1.isTXRdy() && call usart1.isTXRdyIRQEnabled())
        {
            signal usart1.TXRdyFired();
        }
        call IRQWrapper.postamble();
    }

    void USART2_Handler() @C() @spontaneous()
    {
        call IRQWrapper.preamble();
        if (call usart2.isRXRdy() && call usart2.isRXRdyIRQEnabled())
        {
            signal usart2.RXRdyFired();
        }
        if (call usart2.isTXRdy() && call usart2.isTXRdyIRQEnabled())
        {
            signal usart2.TXRdyFired();
        }
        call IRQWrapper.postamble();
    }

    void USART3_Handler() @C() @spontaneous()
    {
        volatile uint8_t xa, xb, xc, xd;
        xa = call usart3.isRXRdy();
        xb = call usart3.isRXRdyIRQEnabled();
        xc = call usart3.isTXRdy();
        xd = call usart3.isTXRdyIRQEnabled();

        call IRQWrapper.preamble();
        if (call usart3.isRXRdy() && call usart3.isRXRdyIRQEnabled())
        {
            signal usart3irq.RXRdyFired();
        }
        if (call usart3.isTXRdy() && call usart3.isTXRdyIRQEnabled())
        {
            signal usart3irq.TXRdyFired();
        }
        call IRQWrapper.postamble();
    }

    async event void usart0.RXRdyFired(){}
    async event void usart1.RXRdyFired(){}
    async event void usart2.RXRdyFired(){}
    async event void usart3.RXRdyFired(){}
    async event void usart0.TXRdyFired(){}
    async event void usart1.TXRdyFired(){}
    async event void usart2.TXRdyFired(){}
    async event void usart3.TXRdyFired(){}

}