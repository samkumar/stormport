
#include <bscifhardware.h>

module HplSam4lBSCIFP
{
    provides interface HplSam4lBSCIF;
}
implementation
{
    async command void HplSam4lBSCIF.enableRC32K()
    {
        bscif_rc32kcr_t tmp = BSCIF->rc32kcr;
        tmp.bits.en = 1;
        tmp.bits.tcen = 1;
        tmp.bits.en32k = 1;
        BSCIF->unlock = BSCIF_UNLOCK_KEY | BSCIF_RC32KCR_OFFSET;
        BSCIF->rc32kcr = tmp;
    }
}