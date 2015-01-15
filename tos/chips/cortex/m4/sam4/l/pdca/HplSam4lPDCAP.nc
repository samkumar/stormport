#include <pdcahardware.h>
#include <nvichardware.h>

module HplSam4lPDCAP
{
    provides interface HplSam4lPDCA as DMAChannel [uint8_t id];
    provides interface Init;
    uses interface HplSam4PeripheralClockCntl as ClockCtl1;
    uses interface HplSam4PeripheralClockCntl as ClockCtl2;
}
implementation
{
    command error_t Init.init()
    {
        call ClockCtl1.enable();
        call ClockCtl2.enable();
    }
    async command void DMAChannel.setPeripheral[uint8_t id] (uint8_t peripheral)
    {
        PDCA->ch[id].psr = peripheral;
    }
    async command void DMAChannel.setWordSize[uint8_t id] (uint8_t wordsize)
    {
        PDCA->ch[id].mr.bits.size = wordsize;
    }
    async command void DMAChannel.setRingBuffered[uint8_t id] (bool v)
    {
        PDCA->ch[id].mr.bits.ring = v;
    }
    async command error_t DMAChannel.setAddressCountReload[uint8_t id] (uint32_t mar, uint16_t tc)
    {
        atomic
        {
            if (!PDCA->ch[id].isr.bits.rcz == 1)
                return EBUSY;

            PDCA->ch[id].marr = mar;
            PDCA->ch[id].tcrr = tc;
            return SUCCESS;
        }
    }
    async command bool DMAChannel.realoadable[uint8_t id]()
    {
        return PDCA->ch[id].isr.bits.rcz == 1;
    }
    async command bool DMAChannel.transferBusy[uint8_t id]()
    {
        return PDCA->ch[id].isr.bits.trc != 1;
    }
    async command void DMAChannel.enableTransfer[uint8_t id]()
    {
        PDCA->ch[id].cr.bits.ten = 1;
    }
    async command void DMAChannel.disableTransfer[uint8_t id]()
    {
        PDCA->ch[id].cr.bits.tdis = 1;
    }
    async command void DMAChannel.enableTransferErrorIRQ[uint8_t id]()
    {
        NVIC->iser.flat[0] = 1<<(1+id);
        PDCA->ch[id].ier.bits.terr = 1;
    }
    async command void DMAChannel.disableTransferErrorIRQ[uint8_t id]()
    {
        PDCA->ch[id].idr.bits.terr = 1;
    }
    async command void DMAChannel.enableReloadableIRQ[uint8_t id]()
    {
        NVIC->iser.flat[0] = 1<<(1+id);
        PDCA->ch[id].ier.bits.rcz = 1;
    }
    async command void DMAChannel.disableReloadableIRQ[uint8_t id]()
    {
        PDCA->ch[id].idr.bits.rcz = 1;
    }
    async command void DMAChannel.enableTransfersCompleteIRQ[uint8_t id]()
    {
        NVIC->iser.flat[0] = 1<<(1+id);
        PDCA->ch[id].ier.bits.trc = 1;
    }
    async command void DMAChannel.disableTransfersCompleteIRQ[uint8_t id]()
    {
        PDCA->ch[id].idr.bits.trc = 1;
    }

    default async event void DMAChannel.reloadableFired[uint8_t id]() {}
    default async event void DMAChannel.transfersCompleteFired[uint8_t id]() {}
    default async event void DMAChannel.transferErrorFired[uint8_t id]() {}

#define PDCA_X_HANDLER(x) \
    void PDCA_##x##_Handler() @C() @spontaneous()                                   \
    {                                                                               \
        pdca_ixr_t masked;                                                          \
        masked.flat = (PDCA->ch[x].isr.flat & PDCA->ch[x].imr.flat);                \
        if (masked.bits.rcz)                                                        \
            signal DMAChannel.reloadableFired[x]();                                 \
        if (masked.bits.trc)                                                        \
            signal DMAChannel.transfersCompleteFired[x]();                          \
        if (masked.bits.terr)                                                       \
            signal DMAChannel.transferErrorFired[x]();                              \
    }

    PDCA_X_HANDLER(0)
    PDCA_X_HANDLER(1)
    PDCA_X_HANDLER(2)
    PDCA_X_HANDLER(3)
    PDCA_X_HANDLER(4)
    PDCA_X_HANDLER(5)
    PDCA_X_HANDLER(6)
    PDCA_X_HANDLER(7)
    PDCA_X_HANDLER(8)
    PDCA_X_HANDLER(9)
    PDCA_X_HANDLER(10)
    PDCA_X_HANDLER(11)

}
