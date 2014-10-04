module HplSam4lUSARTIRQP
{
    uses
    {
        interface HplSam4lUSART as usart0;
        interface HplSam4lUSART as usart1;
        interface HplSam4lUSART as usart2;
        interface HplSam4lUSART as usart3;
        interface FunctionWrapper as IRQWrapper;
    }
    provides
    {
        interface HplSam4lUSART_IRQ as usart0irq;
        interface HplSam4lUSART_IRQ as usart1irq;
        interface HplSam4lUSART_IRQ as usart2irq;
        interface HplSam4lUSART_IRQ as usart3irq;
    }
}
implementation
{
    void USART0_Handler() @C() @spontaneous()
    {
        call IRQWrapper.preamble();
        if (call usart0.isRXRdy() && call usart0irq.isRXRdyIRQEnabled())
        {
            signal usart0irq.RXRdyFired();
        }
        if (call usart0.isTXRdy() && call usart0irq.isTXRdyIRQEnabled())
        {
            signal usart0irq.TXRdyFired();
        }
        call IRQWrapper.postamble();
    }

    void USART1_Handler() @C() @spontaneous()
    {
        call IRQWrapper.preamble();
        if (call usart1.isRXRdy() && call usart1irq.isRXRdyIRQEnabled())
        {
            signal usart1irq.RXRdyFired();
        }
        if (call usart1.isTXRdy() && call usart1irq.isTXRdyIRQEnabled())
        {
            signal usart1irq.TXRdyFired();
        }
        call IRQWrapper.postamble();
    }

    void USART2_Handler() @C() @spontaneous()
    {
        call IRQWrapper.preamble();
        if (call usart2.isRXRdy() && call usart2irq.isRXRdyIRQEnabled())
        {
            signal usart2irq.RXRdyFired();
        }
        if (call usart2.isTXRdy() && call usart2irq.isTXRdyIRQEnabled())
        {
            signal usart2irq.TXRdyFired();
        }
        call IRQWrapper.postamble();
    }

    void USART3_Handler() @C() @spontaneous()
    {
        call IRQWrapper.preamble();
        if (call usart3.isRXRdy() && call usart3irq.isRXRdyIRQEnabled())
        {
            signal usart3irq.RXRdyFired();
        }
        if (call usart3.isTXRdy() && call usart3irq.isTXRdyIRQEnabled())
        {
            signal usart3irq.TXRdyFired();
        }
        call IRQWrapper.postamble();
    }

    void enableUSART0IRQ()
    {
		NVIC->iser.flat[2] = 1 << (1);
    }
    async command void usart0irq.enableTXRdyIRQ()
    {
        enableUSART0IRQ();
        USART0->ier.bits.txrdy = 1;
    }
	async command void usart0irq.disableTXRdyIRQ()
	{
	    USART0->idr.bits.txrdy = 1;
	}
	async command void usart0irq.enableRXRdyIRQ()
	{
        enableUSART0IRQ();
	    USART0->ier.bits.rxrdy = 1;
	}
	async command void usart0irq.disableRXRdyIRQ()
	{
	    USART0->idr.bits.rxrdy = 1;
	}
	async command bool usart0irq.isRXRdyIRQEnabled()
	{
	    return USART0->imr.bits.rxrdy == 1;
	}
	async command bool usart0irq.isTXRdyIRQEnabled()
	{
	    return USART0->imr.bits.txrdy == 1;
	}
	default async event void usart0irq.RXRdyFired(){}
	default async event void usart0irq.TXRdyFired(){}


	void enableUSART1IRQ()
    {
		NVIC->iser.flat[2] = 1 << (2);
    }
    async command void usart1irq.enableTXRdyIRQ()
    {
        enableUSART1IRQ();
        USART1->ier.bits.txrdy = 1;
    }
	async command void usart1irq.disableTXRdyIRQ()
	{
	    USART1->idr.bits.txrdy = 1;
	}
	async command void usart1irq.enableRXRdyIRQ()
	{
        enableUSART1IRQ();
	    USART1->ier.bits.rxrdy = 1;
	}
	async command void usart1irq.disableRXRdyIRQ()
	{
	    USART1->idr.bits.rxrdy = 1;
	}
	async command bool usart1irq.isRXRdyIRQEnabled()
	{
	    return USART1->imr.bits.rxrdy == 1;
	}
	async command bool usart1irq.isTXRdyIRQEnabled()
	{
	    return USART1->imr.bits.txrdy == 1;
	}
	default async event void usart1irq.RXRdyFired(){}
	default async event void usart1irq.TXRdyFired(){}

	void enableUSART2IRQ()
    {
		NVIC->iser.flat[2] = 1 << (3);
    }
    async command void usart2irq.enableTXRdyIRQ()
    {
        enableUSART2IRQ();
        USART2->ier.bits.txrdy = 1;
    }
	async command void usart2irq.disableTXRdyIRQ()
	{
	    USART2->idr.bits.txrdy = 1;
	}
	async command void usart2irq.enableRXRdyIRQ()
	{
        enableUSART2IRQ();
	    USART2->ier.bits.rxrdy = 1;
	}
	async command void usart2irq.disableRXRdyIRQ()
	{
	    USART2->idr.bits.rxrdy = 1;
	}
	async command bool usart2irq.isRXRdyIRQEnabled()
	{
	    return USART2->imr.bits.rxrdy == 1;
	}
	async command bool usart2irq.isTXRdyIRQEnabled()
	{
	    return USART2->imr.bits.txrdy == 1;
	}
	default async event void usart2irq.RXRdyFired(){}
	default async event void usart2irq.TXRdyFired(){}

	void enableUSART3IRQ()
    {
		NVIC->iser.flat[2] = 1 << (4);
    }
    async command void usart3irq.enableTXRdyIRQ()
    {
        enableUSART3IRQ();
        USART3->ier.bits.txrdy = 1;
    }
	async command void usart3irq.disableTXRdyIRQ()
	{
	    USART3->idr.bits.txrdy = 1;
	}
	async command void usart3irq.enableRXRdyIRQ()
	{
        enableUSART3IRQ();
	    USART3->ier.bits.rxrdy = 1;
	}
	async command void usart3irq.disableRXRdyIRQ()
	{
	    USART3->idr.bits.rxrdy = 1;
	}
	async command bool usart3irq.isRXRdyIRQEnabled()
	{
	    return USART3->imr.bits.rxrdy == 1;
	}
	async command bool usart3irq.isTXRdyIRQEnabled()
	{
	    return USART3->imr.bits.txrdy == 1;
	}
	default async event void usart3irq.RXRdyFired(){}
	default async event void usart3irq.TXRdyFired(){}
}