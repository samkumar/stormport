#include <usarthardware.h>
generic configuration Sam4lUSART1C()
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
        USART1_ID = unique(SAM4L_USART1)
    };

    components HilSam4lUSARTC;
    Resource = HilSam4lUSARTC.usart1_Resource[USART1_ID];
    HplSam4lUSART = HilSam4lUSARTC.usart1_hpl;
    UartByte = HilSam4lUSARTC.usart1_UartByte;
    UartControl = HilSam4lUSARTC.usart1_UartControl;
    UartStream = HilSam4lUSARTC.usart1_UartStream;
    SpiByte = HilSam4lUSARTC.usart1_SpiByte;
    FastSpiByte = HilSam4lUSARTC.usart1_FastSpiByte;
    SpiPacket = HilSam4lUSARTC.usart1_SpiPacket;
    HilSam4lUSARTC.usart1_ResourceConfigure[USART1_ID] = ResourceConfigure;
    HilSam4lUSARTC.usart1_Init = UsartInit;
}