#include <usarthardware.h>
#include <nvichardware.h>
#include <pdcahardware.h>

generic module HplSam4lUSARTP(uint32_t address, uint8_t usartnumber)
{
    provides
    {
        interface HplSam4lUSART as usart;
    }
    uses
    {
        interface HplSam4PeripheralClockCntl as ClockCtl;
        interface HplSam4Clock as MainClock;
        interface HplSam4lPDCA as tx_dmac;
        interface HplSam4lPDCA as rx_dmac;
    }
}
implementation
{
    #define USART ((volatile usart_t *)address)

    async command void usart.enableUSARTPin(usart_pin_t pin)
    {
        //Vodoo incantation :-p
        //           GPIO BASE       PORT SIZE        REG      VALUE               PIN NUMBER
        *(uint32_t volatile*)(0x400E1000 + (pin >> 16)*0x200 + 0x008) = (1              << ((pin >> 8)&0xFF)); //GPERC
        *(uint32_t volatile*)(0x400E1000 + (pin >> 16)*0x200 + 0x014) = ((pin & 1)      << ((pin >> 8)&0xFF)); //PMR0S
        *(uint32_t volatile*)(0x400E1000 + (pin >> 16)*0x200 + 0x018) = (((pin & 1)^1)  << ((pin >> 8)&0xFF)); //PMR0C
        *(uint32_t volatile*)(0x400E1000 + (pin >> 16)*0x200 + 0x024) = ((pin & 2)      << ((pin >> 8)&0xFF)); //PMR1S
        *(uint32_t volatile*)(0x400E1000 + (pin >> 16)*0x200 + 0x028) = (((pin & 2)^2)  << ((pin >> 8)&0xFF)); //PMR1C
        *(uint32_t volatile*)(0x400E1000 + (pin >> 16)*0x200 + 0x034) = ((pin & 4)      << ((pin >> 8)&0xFF)); //PMR2S
        *(uint32_t volatile*)(0x400E1000 + (pin >> 16)*0x200 + 0x038) = (((pin & 4)^4)  << ((pin >> 8)&0xFF)); //PMR2C
    }
    async command void usart.enableTX()
	{
		USART->cr.bits.txen = 1;
	}
	async command void usart.disableTX()
	{
		USART->cr.bits.txdis = 1;
	}
	async command void usart.resetTX()
	{
		USART->cr.bits.rsttx = 1;
	}
	async command void usart.enableRX()
	{
		USART->cr.bits.rxen = 1;
	}
	async command void usart.disableRX()
	{
		USART->cr.bits.rxdis = 1;
	}
	async command void usart.resetRX()
	{
		USART->cr.bits.rstrx = 1;
	}
	async command void usart.enableInverter()
	{
		USART->mr.bits.invdata = 1;
	}
	async command void usart.disableInverter()
	{
		USART->mr.bits.invdata = 0;
	}
	async command void usart.selectMSBF()
	{
		USART->mr.bits.msbf_cpol = 1;
	}
	async command void usart.selectLSBF()
	{
		//A typical usart uses this mode
		USART->mr.bits.msbf_cpol = 0;
	}
	async command void usart.selectEvenParity()
	{
		USART->mr.bits.par = 0;
	}
	async command void usart.selectOddParity()
	{
		USART->mr.bits.par = 1;
	}
	async command void usart.selectNoParity()
	{
		USART->mr.bits.par = 4;
	}
	async command void usart.initUART()
	{
	    call ClockCtl.enable();
		USART->mr.bits.chrl = 3; //8 bits
		USART->mr.bits.usclks = 0; //use clk_usart.
		USART->mr.bits.mode = 0; //UART
		USART->mr.bits.nbstop = 0; //1 stop
		USART->mr.bits.par = 4; //No parity
		USART->ttgr = 4; //Space between bytes: 4 bits
	}
	async command void usart.initSPIMaster()
	{
	    call ClockCtl.enable();
	    USART->mr.bits.chrl = 3; //8 bits
	    USART->mr.bits.usclks = 0; //use clk_usart.
		USART->mr.bits.mode = 0b1110; //SPI Master
		USART->mr.bits.clko = 1;
		USART->ttgr = 4;
		call tx_dmac.setWordSize(PDCA_SIZE_BYTE);
		call tx_dmac.setRingBuffered(0);
		call rx_dmac.setWordSize(PDCA_SIZE_BYTE);
		call rx_dmac.setRingBuffered(0);
		call tx_dmac.setPeripheral(SAM4L_PID_USART0_TX + usartnumber);
		call rx_dmac.setPeripheral(SAM4L_PID_USART0_RX + usartnumber);
	}
	async command uint8_t usart.readData()
	{
		return USART->rhr.bits.rxchr;
	}
	async command void usart.sendData(uint8_t d)
	{
		USART->thr.bits.txchr = d;
	}
	async command bool usart.isTXRdy()
	{
	    return USART->csr.bits.txrdy == 1;
	}
	async command bool usart.isRXRdy()
	{
	    return USART->csr.bits.rxrdy == 1;
	}
	async command void usart.setUartBaudRate(uint32_t b)
	{
		//cd = clk / 16*baud
		//   = gmclk*1000 / (16*b)
		//   = gmclk*625 / b*10
		uint32_t cd = (call MainClock.getMainClockSpeed())*625;
		cd /= (b*10);
		USART->brgr.bits.cd = cd;
	}
	async command void usart.setSPIBaudRate(uint32_t b)
	{
		//cd = clk / baud
		//   = gmclk*1000 / b
		uint32_t cd = (call MainClock.getMainClockSpeed())*1000;
		cd /= b;
		USART->brgr.bits.cd = cd;
	}
    async command uint32_t usart.getUartBaudRate()
    {
        uint32_t br = (call MainClock.getMainClockSpeed()*1000) / (16 * (USART->brgr.bits.cd));
        return br;
    }
    async command uint32_t usart.getSPIBaudRate()
    {
        uint32_t br = (call MainClock.getMainClockSpeed()*1000) / (USART->brgr.bits.cd);
        return br;
    }
	async event void MainClock.mainClockChanged()
	{
	    //This is probably significant lol?
	}

    async command void usart.forceChipSelect()
    {
        USART->cr.bits.rtsen_fcs = 1;
    }
    async command void usart.releaseChipSelect()
    {
        USART->cr.bits.rtsdis_rcs = 1;
    }
    async command void usart.setSPIMode(uint8_t cpol, uint8_t cpha)
    {
        USART->mr.bits.msbf_cpol = (cpol != 0);
        //ATMEL's definition of CPHA is different from everyone else, so we invert it.
        //Don't hate, appreciate.
        USART->mr.bits.sync_cpha = (cpha == 0);
    }
    async event void tx_dmac.transfersCompleteFired(){}
    async event void tx_dmac.reloadableFired() {}
    async event void tx_dmac.transferErrorFired() {}
    async event void rx_dmac.transfersCompleteFired(){}
    async event void rx_dmac.reloadableFired() {}
    async event void rx_dmac.transferErrorFired() {}
}
