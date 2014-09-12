interface HplSam4lUSART_UART
{
	async command void enableTX()
	{
		USART->cr.bits.txen = 1;
	}
	async command void disableTX()
	{
		USART->cr.bits.txdis = 1;
	}
	async command void resetRX()
	{
		USART->cr.bits.rstrx = 1;
	}
	async command void enableRX()
	{
		USART->cr.bits.rxen = 1;
	}
	async command void disableRX()
	{
		USART->cr.bits.rxdis = 1;
	}
	async command void resetRX()
	{
		USART->cr.bits.rstrx = 1;
	}
	async command void enableInverter()
	{
		USART->mr.bits.invdata = 1;
	}
	async command void disableInverter()
	{
		USART->mr.bits.invdata = 0;
	}
	async command void selectMSBF()
	{
		USART->mr.bits.msbf_cpol = 1;
	}
	async command void selectLSBF()
	{
		//A typical uart uses this mode
		USART->mr.bits.msbf_cpol = 0;
	}
	async command void selectEvenParity()
	{
		USART->mr.bits.par = 0;
	}
	async command void selectOddParity()
	{
		USART->mr.bits.par = 1;
	}
	async command void selectNoParity()
	{
		USART->mr.bits.par = 4;
	}
	async command void init()
	{
		USART->mr.bits.chrl = 3;
		USART->mr.bits.usclks = 0; //use clk_usart.
		USART->mr.bits.mode = 0;
	}
	async command void enableRXRdyIRQ()
	{
		USART->ier.bits.rxrdy = 1;
	}
	async command void disableRXRdyIRQ()
	{
		USART->idr.bits.rxrdy = 1;
	}
	async command void enableTXRdyIRQ()
	{
		USART->ier.bits.txrdy = 1;
	}
	async command void disableTXRdyIRQ()
	{
		USART->idr.bits.txrdy = 1;
	}
	async command uint8_t readData()
	{
		return USART->rhr.bits.rxchr;
	}
	async command void sendData(uint8_t d)
	{
		USART->thr.bits.txchr = d;
	}
	async command void setBaudRate(uint32_t b)
	{
		//cd = clk / 16*cd
		//   = gmclk*1000 / (16*b)
		//   = gmclk*625 / b*10
		uint32_t cd = (call ClockCtl.getMainClockSpeed())*625;
		cd /= (b*10);
		USART->brgr.bits.cd = cd;
	}
}
interface HplSam4lUSART_SPI
{
	
}