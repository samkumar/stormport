
#include <spihardware.h>

generic configuration Sam4lSPI1C()
{
    provides
    {
        interface Resource;
        interface SpiByte;
        interface FastSpiByte;
        interface HplSam4lSPIChannel;
        interface HplSam4lSPIControl;
    }
    uses
    {
        interface ResourceConfigure;
        interface Init as ChannelInit;
    }
}
implementation
{
    enum
    {
        SPI_ID = unique(SAM4_SPI_BUS)
    };

    components HilSam4lSPIC;
    Resource = HilSam4lSPIC.Resource[SPI_ID];
    SpiByte = HilSam4lSPIC.SpiByte[1];
    FastSpiByte = HilSam4lSPIC.FastSpiByte[1];
    HplSam4lSPIChannel = HilSam4lSPIC.HplSam4lSPIChannel[1];
    HplSam4lSPIControl = HilSam4lSPIC.HplSam4lSPIControl;
    HilSam4lSPIC.ResourceConfigure[1] = ResourceConfigure;
    HilSam4lSPIC.ChannelInit[1] = ChannelInit;
}