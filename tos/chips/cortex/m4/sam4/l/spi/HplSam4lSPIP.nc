module HplSam4lSPIP
{
	provides
	{
	    interface HplSam4lSPIControl;
	    interface Init;
	}
	uses
	{
	    interface HplSam4PeripheralClockCntl as SPIClockCtl;
	    interface HplSam4lGeneralIO as MOSI;
	    interface HplSam4lGeneralIO as MISO;
	    interface HplSam4lGeneralIO as SCLK;
	    interface HplSam4lGeneralIO as CS0;
	    interface HplSam4lGeneralIO as CS1;
	    interface HplSam4lGeneralIO as CS2;
	    interface HplSam4lGeneralIO as CS3;
	    interface GeneralIO as GPCS0;
	    interface GeneralIO as GPCS1;
	    interface GeneralIO as GPCS2;
	    interface GeneralIO as GPCS3;
	    interface Init as CH0Init;
	    interface Init as CH1Init;
	    interface Init as CH2Init;
	    interface Init as CH3Init;
	}

}
implementation
{
	async command void HplSam4lSPIControl.reset()
	{
	    SPI->cr.bits.swrst = 1;
	}
    command error_t Init.init()
	{
	    call HplSam4lSPIControl.enable();
	    call CH0Init.init();
	    call CH1Init.init();
	    call CH2Init.init();
	    call CH3Init.init();
	    call GPCS0.makeOutput();
	    call GPCS3.makeOutput();
	    call GPCS0.set();
	    call GPCS3.set();
	    return SUCCESS;
	}
	async command void HplSam4lSPIControl.enable()
	{
	    call SPIClockCtl.enable();
	    SPI->mr.bits.ps = 1; //Use variable peripheral select
		SPI->mr.bits.mstr = 1; //Master mode
		SPI->mr.bits.rxfifoen = 0; //Disable RX fifo
		SPI->mr.bits.modfdis = 1; //Disable mode fault
	    SPI->cr.bits.spien = 1;
        SPI->csr[0].bits.scbr = 8;
        SPI->csr[1].bits.scbr = 8;
        SPI->csr[2].bits.scbr = 8;
        SPI->csr[3].bits.scbr = 8;
        SPI->csr[3].bits.ncpha = 1;
        //My nomenclature on storm is a little messed up
        //CS2 on the pinout is actually CS1 internally
        //CS1 on the pinout is actually CS2 internally
        //radio is CS3
        //flash is CS0
        //Also TinyOS does not currently seem compatible with the auto-cs methods

	    call MOSI.selectPeripheralA();
	    call MISO.selectPeripheralA();
	    call SCLK.selectPeripheralA();
	    //CS0.selectPeripheralA();
	    //CS1.selectPeripheralA();
	    //CS2.selectPeripheralA();
	    //CS3.selectPeripheralA();

	}
	default command error_t CH0Init.init(){return SUCCESS;}
	default command error_t CH1Init.init(){return SUCCESS;}
	default command error_t CH2Init.init(){return SUCCESS;}
	default command error_t CH3Init.init(){return SUCCESS;}
	async command void HplSam4lSPIControl.disable()
	{
	    SPI->cr.bits.spidis = 1;
	}
	async command uint16_t HplSam4lSPIControl.readRXReg()
	{
		return SPI->rdr;
	}
	async command void HplSam4lSPIControl.writeTXReg16E(uint16_t d, uint8_t ch, bool lastxfer)
	{
		spi_tdr_t w;
		w.bits.td = d;
		w.bits.pcs = (~(1<<ch)) & 0xF;
		w.bits.lastxfer = (uint32_t) lastxfer;
		SPI->tdr = w;
	}
	async command bool HplSam4lSPIControl.isReceiveDataFull()
	{
		return SPI->sr.bits.rdrf == 1;
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
		NVIC->iser.bits.spi = 1;
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
		NVIC->icpr.bits.spi = 1;
	}
	async command void HplSam4lSPIControl.enableTransmitDataEmptyIRQ()
	{
		NVIC->iser.bits.spi = 1;
		SPI->ier.bits.tdre = 1;
	}
	async command void HplSam4lSPIControl.disableTransmitDataEmptyIRQ()
	{
		SPI->idr.bits.tdre = 1;
	}
	async command void HplSam4lSPIControl.enableModeFaultIRQ()
	{
		NVIC->iser.bits.spi = 1;
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
		SPI->mr.bits.dlybcs = ticks;
	}
}