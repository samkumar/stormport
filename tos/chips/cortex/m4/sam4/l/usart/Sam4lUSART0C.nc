#include <usarthardware.h>
generic configuration Sam4lUSART0C()
{
    provides
    {
        interface Resource;
        interface UartByte;
        interface UartControl;
        interface UartStream;
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
        USART0_ID = unique(SAM4L_USART0)
    };

    components HilSam4lUSARTC;
    Resource = HilSam4lUSARTC.usart0_Resource[USART0_ID];
    UartByte = HilSam4lUSARTC.usart0_UartByte;
    UartControl = HilSam4lUSARTC.usart0_UartControl;
    UartStream = HilSam4lUSARTC.usart0_UartStream;
    HilSam4lUSARTC.usart0_ResourceConfigure[USART0_ID] = ResourceConfigure;
    HilSam4lUSARTC.usart0_Init = UsartInit;
}