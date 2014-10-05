#include <usarthardware.h>
generic configuration Sam4lUSART2C()
{
    provides
    {
        interface Resource;
        interface UartByte;
        interface UartControl;
        interface UartStream;
        interface SpiByte;
        interface FastSpiByte;
        interface SpiPacket;
        interface HplSam4lUSART;
    }
    uses
    {
        interface ResourceConfigure;
        interface Init as UsartInit;
    }
}
implementation
{
    enum
    {
        USART2_ID = unique(SAM4L_USART2)
    };

    components HilSam4lUSARTC;
    Resource = HilSam4lUSARTC.usart2_Resource[USART2_ID];
    HplSam4lUSART = HilSam4lUSARTC.usart2_hpl;
    UartByte = HilSam4lUSARTC.usart2_UartByte;
    UartControl = HilSam4lUSARTC.usart2_UartControl;
    UartStream = HilSam4lUSARTC.usart2_UartStream;
    SpiByte = HilSam4lUSARTC.usart2_SpiByte;
    FastSpiByte = HilSam4lUSARTC.usart2_FastSpiByte;
    SpiPacket = HilSam4lUSARTC.usart2_SpiPacket;
    HilSam4lUSARTC.usart2_ResourceConfigure[USART2_ID] = ResourceConfigure;
    HilSam4lUSARTC.usart2_Init = UsartInit;
}