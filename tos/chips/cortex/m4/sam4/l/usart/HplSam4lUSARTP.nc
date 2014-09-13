#include <usarthardware.h>
#include <nvichardware.h>
generic module HplSam4lUSARTP(uint32_t address, uint8_t peripheral, uint8_t usartnumber)
{
    provides
    {
        interface HplSam4lUSART_UART as uart;
    }
    uses
    {
        interface HplSam4PeripheralClockCntl as ClockCtl;
        interface HplSam4Clock as MainClock;
        interface HplSam4lGeneralIO as TX;
        interface HplSam4lGeneralIO as RX;

        interface HplSam4lUSART_UARTIRQ as irq;
    }
}
implementation
{
    #define USART ((volatile usart_t *)address)

    async command void uart.enableTX()
	{
	    call TX.selectPeripheral(peripheral);
		USART->cr.bits.txen = 1;

	}
	async command void uart.disableTX()
	{
		USART->cr.bits.txdis = 1;
	}
	async command void uart.resetTX()
	{
		USART->cr.bits.rsttx = 1;
	}
	async command void uart.enableRX()
	{
	    call RX.selectPeripheral(peripheral);
		USART->cr.bits.rxen = 1;
	}
	async command void uart.disableRX()
	{
		USART->cr.bits.rxdis = 1;
	}
	async command void uart.resetRX()
	{
		USART->cr.bits.rstrx = 1;
	}
	async command void uart.enableInverter()
	{
		USART->mr.bits.invdata = 1;
	}
	async command void uart.disableInverter()
	{
		USART->mr.bits.invdata = 0;
	}
	async command void uart.selectMSBF()
	{
		USART->mr.bits.msbf_cpol = 1;
	}
	async command void uart.selectLSBF()
	{
		//A typical uart uses this mode
		USART->mr.bits.msbf_cpol = 0;
	}
	async command void uart.selectEvenParity()
	{
		USART->mr.bits.par = 0;
	}
	async command void uart.selectOddParity()
	{
		USART->mr.bits.par = 1;
	}
	async command void uart.selectNoParity()
	{
		USART->mr.bits.par = 4;
	}
	async command void uart.init()
	{
	    volatile uint32_t x0 = (uint32_t) USART;
	    volatile uint32_t x1 = (uint32_t) (&(USART->mr));
	    volatile uint32_t y = 50;
	    call ClockCtl.enable();
		USART->mr.bits.chrl = 3;
		USART->mr.bits.usclks = 0; //use clk_usart.
		USART->mr.bits.mode = 0;
		USART->mr.bits.nbstop = 0;
		USART->mr.bits.par = 4;
		USART->ttgr = 4;
	}
	async command void uart.enableRXRdyIRQ()
	{
		USART->ier.bits.rxrdy = 1;
		NVIC->iser.flat[2] = 1 << (1+usartnumber);
	}
	async command void uart.disableRXRdyIRQ()
	{
		USART->idr.bits.rxrdy = 1;
	}
	async command bool uart.isRXRdyIRQEnabled()
	{
	    return USART->imr.bits.rxrdy == 1;
	}
	async command void uart.enableTXRdyIRQ()
	{
		USART->ier.bits.txrdy = 1;
		NVIC->iser.flat[2] = 1 << (1+usartnumber);
	}
	async command void uart.disableTXRdyIRQ()
	{
		USART->idr.bits.txrdy = 1;
	}
	async command bool uart.isTXRdyIRQEnabled()
	{
	    return USART->imr.bits.txrdy == 1;
	}
	async command uint8_t uart.readData()
	{
		return USART->rhr.bits.rxchr;
	}
	async command void uart.sendData(uint8_t d)
	{
		USART->thr.bits.txchr = d;
	}
	async command bool uart.isTXRdy()
	{
	    return USART->csr.bits.txrdy == 1;
	}
	async command bool uart.isRXRdy()
	{
	    return USART->csr.bits.rxrdy == 1;
	}
	async command void uart.setBaudRate(uint32_t b)
	{
		//cd = clk / 16*cd
		//   = gmclk*1000 / (16*b)
		//   = gmclk*625 / b*10
		uint32_t cd = (call MainClock.getMainClockSpeed())*625;
		cd /= (b*10);
		USART->brgr.bits.cd = cd;
	}
    async command uint32_t uart.getBaudRate()
    {
        uint32_t br = (call MainClock.getMainClockSpeed()) / (16 * (USART->brgr.bits.cd));
        return br;
    }
	async event void MainClock.mainClockChanged()
	{
	    //This is probably significant lol?
	}

	async event void irq.RXRdyFired()
	{
	    signal uart.RXRdyFired();
	}
	async event void irq.TXRdyFired()
	{
	    signal uart.TXRdyFired();
	}



}
