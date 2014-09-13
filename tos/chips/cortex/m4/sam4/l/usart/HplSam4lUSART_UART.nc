interface HplSam4lUSART_UART
{
	async command void enableTX();
	async command void disableTX();
	async command void resetTX();
	async command void enableRX();
	async command void disableRX();
	async command void resetRX();
	async command void enableInverter();
	async command void disableInverter();
	async command void selectMSBF();
	async command void selectLSBF();
	async command void selectEvenParity();
	async command void selectOddParity();
	async command void selectNoParity();
	async command void init();
	async command void enableRXRdyIRQ();
	async command void disableRXRdyIRQ();
	async command bool isRXRdyIRQEnabled();
	async command void enableTXRdyIRQ();
	async command void disableTXRdyIRQ();
	async command bool isTXRdyIRQEnabled();
	async command uint8_t readData();
	async command void sendData(uint8_t d);
	async command void setBaudRate(uint32_t b);
	async command uint32_t getBaudRate();
	async command bool isTXRdy();
	async command bool isRXRdy();

	async event void RXRdyFired();
	async event void TXRdyFired();
}