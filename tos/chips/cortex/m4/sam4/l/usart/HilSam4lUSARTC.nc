#include <usarthardware.h>
configuration HilSam4lUSARTC
{
    provides
    {
        interface UartByte as usart0_UartByte;
        interface UartControl as usart0_UartControl;
        interface UartStream as usart0_UartStream;
        interface SpiByte as usart0_SpiByte;
        interface FastSpiByte as usart0_FastSpiByte;
        interface HplSam4lUSART as usart0_hpl;
        interface Resource as usart0_Resource[uint8_t id];

        interface UartByte as usart1_UartByte;
        interface UartControl as usart1_UartControl;
        interface UartStream as usart1_UartStream;
        interface SpiByte as usart1_SpiByte;
        interface FastSpiByte as usart1_FastSpiByte;
        interface HplSam4lUSART as usart1_hpl;
        interface Resource as usart1_Resource[uint8_t id];

        interface UartByte as usart2_UartByte;
        interface UartControl as usart2_UartControl;
        interface UartStream as usart2_UartStream;
        interface SpiByte as usart2_SpiByte;
        interface FastSpiByte as usart2_FastSpiByte;
        interface HplSam4lUSART as usart2_hpl;
        interface Resource as usart2_Resource[uint8_t id];

        interface UartByte as usart3_UartByte;
        interface UartControl as usart3_UartControl;
        interface UartStream as usart3_UartStream;
        interface SpiByte as usart3_SpiByte;
        interface FastSpiByte as usart3_FastSpiByte;
        interface HplSam4lUSART as usart3_hpl;
        interface Resource as usart3_Resource[uint8_t id];
    }
    uses
    {
        interface ResourceConfigure as usart0_ResourceConfigure[uint8_t id];
        interface ResourceConfigure as usart1_ResourceConfigure[uint8_t id];
        interface ResourceConfigure as usart2_ResourceConfigure[uint8_t id];
        interface ResourceConfigure as usart3_ResourceConfigure[uint8_t id];

        interface Init as usart0_Init;
        interface Init as usart1_Init;
        interface Init as usart2_Init;
        interface Init as usart3_Init;
    }
}
implementation
{
    components RealMainP;
    RealMainP.PlatformInit = usart0_Init;
    RealMainP.PlatformInit = usart1_Init;
    RealMainP.PlatformInit = usart2_Init;
    RealMainP.PlatformInit = usart3_Init;

    components new FcfsArbiterC(SAM4L_USART0) as arb0;
    components new FcfsArbiterC(SAM4L_USART1) as arb1;
    components new FcfsArbiterC(SAM4L_USART2) as arb2;
    components new FcfsArbiterC(SAM4L_USART3) as arb3;

    components new HplSam4lUSARTP(0x40024000, 0) as usart0;
    components new HplSam4lUSARTP(0x40028000, 1) as usart1;
    components new HplSam4lUSARTP(0x4002C000, 2) as usart2;
    components new HplSam4lUSARTP(0x40030000, 3) as usart3;

    usart0_hpl = usart0;
    usart1_hpl = usart1;
    usart2_hpl = usart2;
    usart3_hpl = usart3;

    components HplSam4lIOC, HplSam4lUSARTIRQP, McuSleepC;

  //  HplSam4lUSARTIRQP.usart0irq <- usart0;
  //  HplSam4lUSARTIRQP.usart1irq <- usart1;
   // HplSam4lUSARTIRQP.usart2irq <- usart2;
    //HplSam4lUSARTIRQP.usart3irq <- usart3;
    HplSam4lUSARTIRQP.usart0 -> usart0;
    HplSam4lUSARTIRQP.usart1 -> usart1;
    HplSam4lUSARTIRQP.usart2 -> usart2;
    HplSam4lUSARTIRQP.usart3 -> usart3;
    HplSam4lUSARTIRQP.IRQWrapper -> McuSleepC;

    //These are the storm platform defaults. This needs to be rewritten.
    //usart0.TX -> HplSam4lIOC.HplPB15;
    //usart0.RX -> HplSam4lIOC.HplPB14;
    //usart1.TX -> HplSam4lIOC.HplPB05;
    //usart1.RX -> HplSam4lIOC.HplPB04;
    //usart2.TX -> HplSam4lIOC.HplPC12;
    //usart2.RX -> HplSam4lIOC.HplPC11;
    //usart3.TX -> HplSam4lIOC.HplPB10;
    //usart3.RX -> HplSam4lIOC.HplPB09;

    components new HalSam4lUSARTP() as hal_usart0;
    components new HalSam4lUSARTP() as hal_usart1;
    components new HalSam4lUSARTP() as hal_usart2;
    components new HalSam4lUSARTP() as hal_usart3;

    hal_usart0.usart -> usart0;
    hal_usart1.usart -> usart1;
    hal_usart2.usart -> usart2;
    hal_usart3.usart -> usart3;

    components HplSam4lClockC;
    usart0.ClockCtl -> HplSam4lClockC.USART0Ctl;
    usart1.ClockCtl -> HplSam4lClockC.USART1Ctl;
    usart2.ClockCtl -> HplSam4lClockC.USART2Ctl;
    usart3.ClockCtl -> HplSam4lClockC.USART3Ctl;
    usart0.MainClock -> HplSam4lClockC;
    usart1.MainClock -> HplSam4lClockC;
    usart2.MainClock -> HplSam4lClockC;
    usart3.MainClock -> HplSam4lClockC;

    usart0_UartByte = hal_usart0;
    usart1_UartByte = hal_usart1;
    usart2_UartByte = hal_usart2;
    usart3_UartByte = hal_usart3;

    usart0_UartControl = hal_usart0;
    usart1_UartControl = hal_usart1;
    usart2_UartControl = hal_usart2;
    usart3_UartControl = hal_usart3;

    usart0_Resource = arb0;
    usart1_Resource = arb1;
    usart2_Resource = arb2;
    usart3_Resource = arb3;

    arb0.ResourceConfigure = usart0_ResourceConfigure;
    arb1.ResourceConfigure = usart1_ResourceConfigure;
    arb2.ResourceConfigure = usart2_ResourceConfigure;
    arb3.ResourceConfigure = usart3_ResourceConfigure;

    usart0_UartStream = hal_usart0;
    usart1_UartStream = hal_usart1;
    usart2_UartStream = hal_usart2;
    usart3_UartStream = hal_usart3;

    usart0_SpiByte = hal_usart0;
    usart1_SpiByte = hal_usart1;
    usart2_SpiByte = hal_usart2;
    usart3_SpiByte = hal_usart3;

    usart0_FastSpiByte = hal_usart0;
    usart1_FastSpiByte = hal_usart1;
    usart2_FastSpiByte = hal_usart2;
    usart3_FastSpiByte = hal_usart3;
}