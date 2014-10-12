
#include <spihardware.h>

//CS3 = PC01 = RADIO_CS
generic configuration Sam4lSPI3C()
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
    SpiByte = HilSam4lSPIC.SpiByte[3];
    FastSpiByte = HilSam4lSPIC.FastSpiByte[3];
    HplSam4lSPIChannel = HilSam4lSPIC.HplSam4lSPIChannel[3];
    HplSam4lSPIControl = HilSam4lSPIC.HplSam4lSPIControl;
    HilSam4lSPIC.ResourceConfigure[3] = ResourceConfigure;
    HilSam4lSPIC.ChannelInit[3] = ChannelInit;
}