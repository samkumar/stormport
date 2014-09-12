module HplSam4lSPIP
{
	provides
	{
	    interface HplSam4lSPIControl;
	}
	uses
	{
	    interface HplSam4PeripheralClockCntl as SPIClockCtl;
	}

}
implementation
{
	async command void HplSam4lSPIControl.reset()
	{
	    SPI->sr.bits.swrst = 1;
	}
	async command void HplSam4lSPIControl.enable()
	{
	    SPIClockCtl.enable();
	    SPI->mr.bits.ps = 1; //Use variable peripheral select
		SPI->mr.bits.mstr = 1; //Master mode
		SPI->mr.rxfifoen = 0; //Disable RX fifo
	    SPI->sr.bits.spien = 1;

	}
	async command void HplSam4lSPIControl.disable()
	{
	    SPI->sr.bits.spidis = 1;
	}
	async command uint16_t HplSam4lSPIControl.readRXReg()
	{
		return SPI->rdr;
	}
	async command void HplSam4lSPIControl.writeTXReg16E(uint16_t d, uint8_t ch, bool lastxfer)
	{
		spi_tdr_t w;
		w.bits.td = d;
		w.bits.ch = (~(1<<ch)) & 0xF;
		w.bits.lastxfer = (uint32_t) lastxfer;
		SPI->tdr = w;
	}
	async command bool HplSam4lSPIControl.isReceiveDataFull()
	{
		return SPI->sr.bits.rdf == 1;
	}
	async command bool HplSam4lSPIControl.isTransmitDataEmpty()
	{
		return SPI->sr.bits.tdre == 1;
	}
	async command bool HplSam4lSPIControl.isModeFault()
	{
		return SPI->sr.bits.modf == 1;
	}
	async command bool HplSam4lSPIControl.isOverflowError()
	{
		return SPI->sr.bits.ovres == 1;
	}
	async command bool HplSam4lSPIControl.isTXShifterEmpty()
	{
		return SPI->sr.bits.txempty == 1;
	}
	async command bool HplSam4lSPIControl.isUnderrunError()
	{
		return SPI->sr.bits.undes == 1;
	}
	async command bool HplSam4lSPIControl.isEnabled()
	{
		return SPI->sr.bits.spiens == 1;
	}
	async command void HplSam4lSPIControl.enableReceiveDataFullIRQ()
	{
		NVIC->iser.spi = 1;
		SPI->ier.bits.rdrf = 1;
	}
	async command bool HplSam4lSPIControl.isReceiveDataFullIRQEnabled()
	{
		return SPI->imr.bits.rdrf == 1;
	}
	async command void HplSam4lSPIControl.disableReceiveDataFullIRQ()
	{
		SPI->idr.bits.rdrf = 1;
	}
	async command void HplSam4lSPIControl.clearIRQ()
	{
		NVIC->icpr.spi = 1;
	}
	async command void HplSam4lSPIControl.enableTransmitDataEmptyIRQ()
	{
		NVIC->iser.spi = 1;
		SPI->ier.bits.tdre = 1;
	}
	async command void HplSam4lSPIControl.disableTransmitDataEmptyIRQ()
	{
		return SPI->idr.bits.tdre = 1;
	}
	async command void HplSam4lSPIControl.enableModeFaultIRQ()
	{
		NVIC->iser.spi = 1;
		SPI->ier.bits.modf = 1;
	}
	async command void HplSam4lSPIControl.disableModeFaultIRQ()
	{
		SPI->idr.bits.modf = 1;
	}
	async command void HplSam4lSPIControl.enableOverrunIRQ()
	{
		SPI->ier.bits.ovres = 1;
	}
	async command void HplSam4lSPIControl.disableDisableIRQ()
	{
		SPI->idr.bits.ovres = 1;
	}
	async command void HplSam4lSPIControl.enableTXShifterEmptyIRQ()
	{
		SPI->ier.bits.txempty = 1;
	}
	async command void HplSam4lSPIControl.disableTXShifterEmptyIRQ()
	{
		SPI->idr.bits.txempty = 1;
	}
	async command void HplSam4lSPIControl.setDelayBetweenChipSelects(uint8_t ticks)
	{
		SPI->mr.dlybcs = ticks;
	}
}