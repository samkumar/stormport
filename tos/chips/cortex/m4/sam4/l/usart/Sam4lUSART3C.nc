#include <usarthardware.h>
generic configuration Sam4lUSART3C()
{
    provides
    {
        interface Resource;
        interface UartByte;
        interface UartControl;
        interface UartStream;
        interface SpiByte;
        interface FastSpiByte;
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
        USART3_ID = unique(SAM4L_USART3)
    };

    components HilSam4lUSARTC;
    Resource = HilSam4lUSARTC.usart3_Resource[USART3_ID];
    HplSam4lUSART = HilSam4lUSARTC.usart3_hpl;
    UartByte = HilSam4lUSARTC.usart3_UartByte;
    UartControl = HilSam4lUSARTC.usart3_UartControl;
    UartStream = HilSam4lUSARTC.usart3_UartStream;
    SpiByte = HilSam4lUSARTC.usart3_SpiByte;
    FastSpiByte = HilSam4lUSARTC.usart3_FastSpiByte;
    HilSam4lUSARTC.usart3_ResourceConfigure[USART3_ID] = ResourceConfigure;
    HilSam4lUSARTC.usart3_Init = UsartInit;
}