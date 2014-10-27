
#include <spihardware.h>

//CS = PC03 = FL_CS
generic configuration Sam4lSPI0C()
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
    SpiByte = HilSam4lSPIC.SpiByte[0];
    FastSpiByte = HilSam4lSPIC.FastSpiByte[0];
    HplSam4lSPIChannel = HilSam4lSPIC.HplSam4lSPIChannel[0];
    HplSam4lSPIControl = HilSam4lSPIC.HplSam4lSPIControl;
    HilSam4lSPIC.ResourceConfigure[0] = ResourceConfigure;
    HilSam4lSPIC.ChannelInit[0] = ChannelInit;
}