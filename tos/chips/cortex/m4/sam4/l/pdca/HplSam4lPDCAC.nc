#include <pdcahardware.h>
configuration HplSam4lPDCAC
{
    provides interface HplSam4lPDCA as DMAChannels [uint8_t id];
}
implementation
{
    components HplSam4lPDCAP, RealMainP, HplSam4lClockC;

    DMAChannels = HplSam4lPDCAP.DMAChannel;

    HplSam4lPDCAP.ClockCtl1 -> HplSam4lClockC.PDCA_HSBCtl;
    HplSam4lPDCAP.ClockCtl2 -> HplSam4lClockC.PDCA_PBBCtl;
    RealMainP.PlatformInit -> HplSam4lPDCAP.Init;
}