interface HplSam4lSPIControl
{
	async command void reset();
	async command void enable();
	async command void disable();
	async command uint16_t readRXReg();
	async command void writeTXReg16E(uint16_t d, uint8_t ch, bool lastxfer);
	async command bool isReceiveDataFull();
	async command bool isTransmitDataEmpty();
	async command bool isModeFault();
	async command bool isOverflowError();
	async command bool isTXShifterEmpty();
	async command bool isUnderrunError();
	async command bool isEnabled();
	async command void enableReceiveDataFullIRQ();
	async command bool isReceiveDataFullIRQEnabled();
	async command void disableReceiveDataFullIRQ();
	async command void clearIRQ();
	async command void enableTransmitDataEmptyIRQ();
	async command void disableTransmitDataEmptyIRQ();
	async command void enableModeFaultIRQ();
	async command void disableModeFaultIRQ();
	async command void enableOverrunIRQ();
	async command void disableDisableIRQ();
	async command void enableTXShifterEmptyIRQ();
	async command void disableTXShifterEmptyIRQ();
	async command void setDelayBetweenChipSelects(uint8_t ticks);
}