
#include <spihardware.h>

generic module HplSam4lSPIChannelP(uint8_t cs)
{
    provides
    {
        interface HplSam4lSPIChannel;
    }
    uses interface HplSam4lSPIControl;
}
implementation
{
    //CPOL = 0 : clk idle low, 1 : idle high
	//CPHA = 0 : data is captured on clk idle to active and changed on active to idle
	// 	 	 1 : data is changed on clk idle to active and captured on active to idle
	async command void HplSam4lSPIChannel.setMode(uint8_t cpol, uint8_t cpha)
	{
		//This is industry standard notation, so cpha is inverted for atmel.
		SPI->csr[id].bits.cpol = cpol;
		SPI->csr[id].bits.ncpha = !cpha;
	}
	async command void HplSam4lSPIChannel.setCSNAAT()
	{
		SPI->csr[id].bits.csnaat = 1;
	}
	async command void HplSam4lSPIChannel.clrCSNAAT()
	{
		SPI->csr[id].bits.csnaat = 0;
	}
	async command void HplSam4lSPIChannel.setCSAAT()
	{
		SPI->csr[id].bits.csaat = 1;
	}
	async command void HplSam4lSPIChannel.clrCSAAT()
	{
		SPI->csr[id].bits.csaat = 0;
	}
	async command void HplSam4lSPIChannel.setBitsPerTransfer(uint8_t bits)
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
	async command void HplSam4lSPIChannel.setClkDiv(uint8_t d)
	{
		if (d == 0) d = 1;
		SPI->csr[id].bits.scbr = d;
	}
	async command void HplSam4lSPIChannel.setDelayBetweenTransfers(uint8_t v)
	{
		SPI->csr[id].bits.dlybct = v;
	}
	async command void HplSam4lSPIChannel.setDelayBeforeClock(uint8_t v)
	{
		SPI->csr[id].bits.dlybs = v;
	}
	async command void HplSam4lSPIChannel.writeTXReg(uint16_t d, bool lastxfer)
	{
		spi_tdr_t w;
		w.bits.td = d;
		w.bits.ch = (~(1<<id)) & 0xF;
		w.bits.lastxfer = (uint32_t) lastxfer;
		SPI->tdr = w;
	}

}