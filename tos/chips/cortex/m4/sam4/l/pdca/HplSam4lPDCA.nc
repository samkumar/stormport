interface HplSam4lPDCA
{
    async command void setPeripheral (uint8_t peripheral);
    async command void setWordSize (uint8_t wordsize);
    async command void setRingBuffered (bool v);
    async command error_t setAddressCountReload(uint32_t mar, uint16_t tc);
    async command bool realoadable();
    async command bool transferBusy();
    async command void enableTransfer();
    async command void disableTransfer();
    async command void enableTransferErrorIRQ();
    async command void disableTransferErrorIRQ();
    async command void enableReloadableIRQ();
    async command void disableReloadableIRQ();
    async command void enableTransfersCompleteIRQ();
    async command void disableTransfersCompleteIRQ();
    async event void reloadableFired();
    async event void transfersCompleteFired();
    async event void transferErrorFired();
}