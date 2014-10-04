#include <usarthardware.h>
interface HplSam4lUSART
{
    async command void initUART();
    async command void initSPIMaster();

    async command void enableUSARTPin(usart_pin_t pin);

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

    async command void forceChipSelect();
    async command void releaseChipSelect();
    async command void setSPIMode(uint8_t cpol, uint8_t cpha);

	async command uint8_t readData();
	async command void sendData(uint8_t d);
	async command void setUartBaudRate(uint32_t b);
	async command void setSPIBaudRate(uint32_t b);
	async command uint32_t getUartBaudRate();
	async command uint32_t getSPIBaudRate();
	async command bool isTXRdy();
	async command bool isRXRdy();

}