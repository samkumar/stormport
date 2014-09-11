interface HplSam4lSPIChannel
{
	//CPOL = 0 : clk idle low, 1 : idle high
	//CPHA = 0 : data is captured on clk idle to active and changed on active to idle
	// 	 	 1 : data is changed on clk idle to active and captured on active to idle
	async command void setMode(uint8_t cpol, uint8_t cpha)
	{
		//This is industry standard notation, so cpha is inverted for atmel.
		SPI->csr[id].bits.cpol = cpol;
		SPI->csr[id].bits.ncpha = !cpha;
	}
	async command void setCSNAAT()
	{
		SPI->csr[id].bits.csnaat = 1;
	}
	async command void clrCSNAAT()
	{
		SPI->csr[id].bits.csnaat = 0;
	}
	async command void setCSAAT()
	{
		SPI->csr[id].bits.csaat = 1;
	}
	async command void clrCSAAT()
	{
		SPI->csr[id].bits.csaat = 0;
	}
	async command void setBitsPerTransfer(uint8_t bits)
	{
		switch(bits)
		{
			case 4: SPI->csr[id].bits.bits = 9; break;
			case 5: SPI->csr[id].bits.bits = 10; break;
			case 6: SPI->csr[id].bits.bits = 11; break;
			case 7: SPI->csr[id].bits.bits = 12; break;
			case 8: SPI->csr[id].bits.bits = 0; break;
			case 9: SPI->csr[id].bits.bits = 1; break;
			case 10: SPI->csr[id].bits.bits = 2; break;
			case 11: SPI->csr[id].bits.bits = 3; break;
			case 12: SPI->csr[id].bits.bits = 4; break;
			case 13: SPI->csr[id].bits.bits = 5; break;
			case 4: SPI->csr[id].bits.bits = 6; break;
			case 4: SPI->csr[id].bits.bits = 7; break;
			case 4: SPI->csr[id].bits.bits = 8; break;
		}
	}
	async command void setClkDiv(uint8_t d)
	{
		if (d == 0) d = 1;
		SPI->csr[id].bits.scbr = d;
	}
	async command void setDelayBetweenTransfers(uint8_t v)
	{
		SPI->csr[id].bits.dlybct = v;
	}
	async command void setDelayBeforeClock(uint8_t v)
	{
		SPI->csr[id].bits.dlybs = v;
	}
	async command void writeTXReg(uint16_t d, bool lastxfer)
	{
		spi_tdr_t w;
		w.bits.td = d;
		w.bits.ch = (~(1<<id)) & 0xF;
		w.bits.lastxfer = (uint32_t) lastxfer;
		SPI->tdr = w;
	}
}

interface HplSam4lSPIConfig
{
	async command void reset();
	async command void enable();
	async command void disable();
	async command uint16_t readRXReg()
	{
		return SPI->rdr;
	}
	async command void writeTXReg16E(uint16_t d, uint8_t ch, bool lastxfer)
	{
		spi_tdr_t w;
		w.bits.td = d;
		w.bits.ch = (~(1<<ch)) & 0xF;
		w.bits.lastxfer = (uint32_t) lastxfer;
		SPI->tdr = w;
	}
	async command bool isReceiveDataFull()
	{
		return SPI->sr.bits.rdf == 1;
	}
	async command bool isTransmitDataEmpty()
	{
		return SPI->sr.bits.tdre == 1;
	}
	async command bool isModeFault()
	{
		return SPI->sr.bits.modf == 1;
	}
	async command bool isOverflowError()
	{
		return SPI->sr.bits.ovres == 1;
	}
	async command bool isTXShifterEmpty()
	{
		return SPI->sr.bits.txempty == 1;
	}
	async command bool isUnderrunError()
	{
		return SPI->sr.bits.undes == 1;
	}
	async command bool isEnabled()
	{
		return SPI->sr.bits.spiens == 1;
	}
	async command void enableReceiveDataFullIRQ()
	{
		NVIC->iser.spi = 1;
		SPI->ier.bits.rdrf = 1;
	}
	async command bool isReceiveDataFullIRQEnabled()
	{
		return SPI->imr.bits.rdrf == 1;
	}
	async command void disableReceiveDataFullIRQ()
	{
		SPI->idr.bits.rdrf = 1;
	}
	async command void clearIRQ()
	{
		NVIC->icpr.spi = 1;
	}
	async command void enableTransmitDataEmptyIRQ()
	{
		NVIC->iser.spi = 1;
		SPI->ier.bits.tdre = 1;
	}
	async command void disableTransmitDataEmptyIRQ()
	{
		return SPI->idr.bits.tdre = 1;
	}
	async command void enableModeFaultIRQ()
	{
		NVIC->iser.spi = 1;
		SPI->ier.bits.modf = 1;
	}
	async command void disableModeFaultIRQ()
	{
		SPI->idr.bits.modf = 1;
	}
	async command void enableOverrunIRQ()
	{
		SPI->ier.bits.ovres = 1;
	}
	async command void disableDisableIRQ()
	{
		SPI->idr.bits.ovres = 1;
	}
	async command void enableTXShifterEmptyIRQ()
	{
		SPI->ier.bits.txempty = 1;
	}
	async command void disableTXShifterEmptyIRQ()
	{
		SPI->idr.bits.txempty = 1;
	}
	async command void setDelayBetweenChipSelects(uint8_t ticks)
	{
		SPI->mr.dlybcs = ticks;
	}
	async command void init()
	{
		SPI->mr.bits.ps = 1; //Use variable peripheral select
		SPI->mr.bits.mstr = 1; //Master mode
		SPI->mr.rxfifoen = 0; //Disable RX fifo
	}
}
