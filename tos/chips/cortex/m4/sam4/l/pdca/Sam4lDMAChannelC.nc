#include <pdcahardware.h>
generic configuration Sam4lDMAChannelC()
{
    provides interface HplSam4lPDCA;
}
implementation
{
    components HplSam4lPDCAC;

    enum { ChanID = unique(DMA_CHANNEL_UQ) };

    HplSam4lPDCA = HplSam4lPDCAC.DMAChannels[ChanID];

}