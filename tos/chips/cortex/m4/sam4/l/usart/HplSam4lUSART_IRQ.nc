interface HplSam4lUSART_IRQ
{
    async event void RXRdyFired();
    async event void TXRdyFired();

    async command void enableTXRdyIRQ();
	async command void disableTXRdyIRQ();
	async command void enableRXRdyIRQ();
	async command void disableRXRdyIRQ();

	async command bool isRXRdyIRQEnabled();
	async command bool isTXRdyIRQEnabled();
}