interface HplSam4lPDCA
{
    async command error_t setAddressCount(uint32_t mar, uint16_t tc);
    async command error_t setAddressCountReload(uint32_t mar, uint16_t tc);
    async command void initiateTransfer();
    async command void enableTransferErrorIRQ();
    async command void disableTransferErrorIRQ();
    async command void enableReloadableIRQ();
    async command void disableReloadableIRQ();
    async command void enableTransfersCompleteIRQ();
    async command void disableTransfersCompleteIRQ();
}