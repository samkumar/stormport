interface HplSam4lSPIChannel
{
	//CPOL = 0 : clk idle low, 1 : idle high
	//CPHA = 0 : data is captured on clk idle to active and changed on active to idle
	// 	 	 1 : data is changed on clk idle to active and captured on active to idle
	async command void setMode(uint8_t cpol, uint8_t cpha);

	async command void setCSNAAT();

	async command void clrCSNAAT();

	async command void setCSAAT();

	async command void clrCSAAT();

	async command void setBitsPerTransfer(uint8_t bits);

	async command void setClkDiv(uint8_t d);

	async command void setDelayBetweenTransfers(uint8_t v);

	async command void setDelayBeforeClock(uint8_t v);

	async command void writeTXReg(uint16_t d, bool lastxfer);

}

