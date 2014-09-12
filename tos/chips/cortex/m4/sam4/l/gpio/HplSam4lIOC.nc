#include <gpiohardware.h>

configuration HplSam4lIOC
{
    provides
    {
        interface GeneralIO as PA00;
        interface GeneralIO as PA01;
        interface GeneralIO as PA02;
        interface GeneralIO as PA03;
        interface GeneralIO as PA04;
        interface GeneralIO as PA05;
        interface GeneralIO as PA06;
        interface GeneralIO as PA07;
        interface GeneralIO as PA08;
        interface GeneralIO as PA09;
        interface GeneralIO as PA10;
        interface GeneralIO as PA11;
        interface GeneralIO as PA12;
        interface GeneralIO as PA13;
        interface GeneralIO as PA14;
        interface GeneralIO as PA15;
        interface GeneralIO as PA16;
        interface GeneralIO as PA17;
        interface GeneralIO as PA18;
        interface GeneralIO as PA19;
        interface GeneralIO as PA20;
        interface GeneralIO as PA21;
        interface GeneralIO as PA22;
        interface GeneralIO as PA23;
        interface GeneralIO as PA24;
        interface GeneralIO as PA25;
        interface GeneralIO as PA26;
        //No more PA's
        interface GeneralIO as PB00;
        interface GeneralIO as PB01;
        interface GeneralIO as PB02;
        interface GeneralIO as PB03;
        interface GeneralIO as PB04;
        interface GeneralIO as PB05;
        interface GeneralIO as PB06;
        interface GeneralIO as PB07;
        interface GeneralIO as PB08;
        interface GeneralIO as PB09;
        interface GeneralIO as PB10;
        interface GeneralIO as PB11;
        interface GeneralIO as PB12;
        interface GeneralIO as PB13;
        interface GeneralIO as PB14;
        interface GeneralIO as PB15;
        //No more PB's
        interface GeneralIO as PC00;
        interface GeneralIO as PC01;
        interface GeneralIO as PC02;
        interface GeneralIO as PC03;
        interface GeneralIO as PC04;
        interface GeneralIO as PC05;
        interface GeneralIO as PC06;
        interface GeneralIO as PC07;
        interface GeneralIO as PC08;
        interface GeneralIO as PC09;
        interface GeneralIO as PC10;
        interface GeneralIO as PC11;
        interface GeneralIO as PC12;
        interface GeneralIO as PC13;
        interface GeneralIO as PC14;
        interface GeneralIO as PC15;
        interface GeneralIO as PC16;
        interface GeneralIO as PC17;
        interface GeneralIO as PC18;
        interface GeneralIO as PC19;
        interface GeneralIO as PC20;
        interface GeneralIO as PC21;
        interface GeneralIO as PC22;
        interface GeneralIO as PC23;
        interface GeneralIO as PC24;
        interface GeneralIO as PC25;
        interface GeneralIO as PC26;
        interface GeneralIO as PC27;
        interface GeneralIO as PC28;
        interface GeneralIO as PC29;
        interface GeneralIO as PC30;
        interface GeneralIO as PC31;

        interface GpioInterrupt as PA00IRQ;
        interface GpioInterrupt as PA01IRQ;
        interface GpioInterrupt as PA02IRQ;
        interface GpioInterrupt as PA03IRQ;
        interface GpioInterrupt as PA04IRQ;
        interface GpioInterrupt as PA05IRQ;
        interface GpioInterrupt as PA06IRQ;
        interface GpioInterrupt as PA07IRQ;
        interface GpioInterrupt as PA08IRQ;
        interface GpioInterrupt as PA09IRQ;
        interface GpioInterrupt as PA10IRQ;
        interface GpioInterrupt as PA11IRQ;
        interface GpioInterrupt as PA12IRQ;
        interface GpioInterrupt as PA13IRQ;
        interface GpioInterrupt as PA14IRQ;
        interface GpioInterrupt as PA15IRQ;
        interface GpioInterrupt as PA16IRQ;
        interface GpioInterrupt as PA17IRQ;
        interface GpioInterrupt as PA18IRQ;
        interface GpioInterrupt as PA19IRQ;
        interface GpioInterrupt as PA20IRQ;
        interface GpioInterrupt as PA21IRQ;
        interface GpioInterrupt as PA22IRQ;
        interface GpioInterrupt as PA23IRQ;
        interface GpioInterrupt as PA24IRQ;
        interface GpioInterrupt as PA25IRQ;
        interface GpioInterrupt as PA26IRQ;
        interface GpioInterrupt as PB00IRQ;
        interface GpioInterrupt as PB01IRQ;
        interface GpioInterrupt as PB02IRQ;
        interface GpioInterrupt as PB03IRQ;
        interface GpioInterrupt as PB04IRQ;
        interface GpioInterrupt as PB05IRQ;
        interface GpioInterrupt as PB06IRQ;
        interface GpioInterrupt as PB07IRQ;
        interface GpioInterrupt as PB08IRQ;
        interface GpioInterrupt as PB09IRQ;
        interface GpioInterrupt as PB10IRQ;
        interface GpioInterrupt as PB11IRQ;
        interface GpioInterrupt as PB12IRQ;
        interface GpioInterrupt as PB13IRQ;
        interface GpioInterrupt as PB14IRQ;
        interface GpioInterrupt as PB15IRQ;
        interface GpioInterrupt as PC00IRQ;
        interface GpioInterrupt as PC01IRQ;
        interface GpioInterrupt as PC02IRQ;
        interface GpioInterrupt as PC03IRQ;
        interface GpioInterrupt as PC04IRQ;
        interface GpioInterrupt as PC05IRQ;
        interface GpioInterrupt as PC06IRQ;
        interface GpioInterrupt as PC07IRQ;
        interface GpioInterrupt as PC08IRQ;
        interface GpioInterrupt as PC09IRQ;
        interface GpioInterrupt as PC10IRQ;
        interface GpioInterrupt as PC11IRQ;
        interface GpioInterrupt as PC12IRQ;
        interface GpioInterrupt as PC13IRQ;
        interface GpioInterrupt as PC14IRQ;
        interface GpioInterrupt as PC15IRQ;
        interface GpioInterrupt as PC16IRQ;
        interface GpioInterrupt as PC17IRQ;
        interface GpioInterrupt as PC18IRQ;
        interface GpioInterrupt as PC19IRQ;
        interface GpioInterrupt as PC20IRQ;
        interface GpioInterrupt as PC21IRQ;
        interface GpioInterrupt as PC22IRQ;
        interface GpioInterrupt as PC23IRQ;
        interface GpioInterrupt as PC24IRQ;
        interface GpioInterrupt as PC25IRQ;
        interface GpioInterrupt as PC26IRQ;
        interface GpioInterrupt as PC27IRQ;
        interface GpioInterrupt as PC28IRQ;
        interface GpioInterrupt as PC29IRQ;
        interface GpioInterrupt as PC30IRQ;
        interface GpioInterrupt as PC31IRQ;

        interface HplSam4lGeneralIO as HplPA00;
        interface HplSam4lGeneralIO as HplPA01;
        interface HplSam4lGeneralIO as HplPA02;
        interface HplSam4lGeneralIO as HplPA03;
        interface HplSam4lGeneralIO as HplPA04;
        interface HplSam4lGeneralIO as HplPA05;
        interface HplSam4lGeneralIO as HplPA06;
        interface HplSam4lGeneralIO as HplPA07;
        interface HplSam4lGeneralIO as HplPA08;
        interface HplSam4lGeneralIO as HplPA09;
        interface HplSam4lGeneralIO as HplPA10;
        interface HplSam4lGeneralIO as HplPA11;
        interface HplSam4lGeneralIO as HplPA12;
        interface HplSam4lGeneralIO as HplPA13;
        interface HplSam4lGeneralIO as HplPA14;
        interface HplSam4lGeneralIO as HplPA15;
        interface HplSam4lGeneralIO as HplPA16;
        interface HplSam4lGeneralIO as HplPA17;
        interface HplSam4lGeneralIO as HplPA18;
        interface HplSam4lGeneralIO as HplPA19;
        interface HplSam4lGeneralIO as HplPA20;
        interface HplSam4lGeneralIO as HplPA21;
        interface HplSam4lGeneralIO as HplPA22;
        interface HplSam4lGeneralIO as HplPA23;
        interface HplSam4lGeneralIO as HplPA24;
        interface HplSam4lGeneralIO as HplPA25;
        interface HplSam4lGeneralIO as HplPA26;
        interface HplSam4lGeneralIO as HplPB00;
        interface HplSam4lGeneralIO as HplPB01;
        interface HplSam4lGeneralIO as HplPB02;
        interface HplSam4lGeneralIO as HplPB03;
        interface HplSam4lGeneralIO as HplPB04;
        interface HplSam4lGeneralIO as HplPB05;
        interface HplSam4lGeneralIO as HplPB06;
        interface HplSam4lGeneralIO as HplPB07;
        interface HplSam4lGeneralIO as HplPB08;
        interface HplSam4lGeneralIO as HplPB09;
        interface HplSam4lGeneralIO as HplPB10;
        interface HplSam4lGeneralIO as HplPB11;
        interface HplSam4lGeneralIO as HplPB12;
        interface HplSam4lGeneralIO as HplPB13;
        interface HplSam4lGeneralIO as HplPB14;
        interface HplSam4lGeneralIO as HplPB15;
        interface HplSam4lGeneralIO as HplPC00;
        interface HplSam4lGeneralIO as HplPC01;
        interface HplSam4lGeneralIO as HplPC02;
        interface HplSam4lGeneralIO as HplPC03;
        interface HplSam4lGeneralIO as HplPC04;
        interface HplSam4lGeneralIO as HplPC05;
        interface HplSam4lGeneralIO as HplPC06;
        interface HplSam4lGeneralIO as HplPC07;
        interface HplSam4lGeneralIO as HplPC08;
        interface HplSam4lGeneralIO as HplPC09;
        interface HplSam4lGeneralIO as HplPC10;
        interface HplSam4lGeneralIO as HplPC11;
        interface HplSam4lGeneralIO as HplPC12;
        interface HplSam4lGeneralIO as HplPC13;
        interface HplSam4lGeneralIO as HplPC14;
        interface HplSam4lGeneralIO as HplPC15;
        interface HplSam4lGeneralIO as HplPC16;
        interface HplSam4lGeneralIO as HplPC17;
        interface HplSam4lGeneralIO as HplPC18;
        interface HplSam4lGeneralIO as HplPC19;
        interface HplSam4lGeneralIO as HplPC20;
        interface HplSam4lGeneralIO as HplPC21;
        interface HplSam4lGeneralIO as HplPC22;
        interface HplSam4lGeneralIO as HplPC23;
        interface HplSam4lGeneralIO as HplPC24;
        interface HplSam4lGeneralIO as HplPC25;
        interface HplSam4lGeneralIO as HplPC26;
        interface HplSam4lGeneralIO as HplPC27;
        interface HplSam4lGeneralIO as HplPC28;
        interface HplSam4lGeneralIO as HplPC29;
        interface HplSam4lGeneralIO as HplPC30;
        interface HplSam4lGeneralIO as HplPC31;
    }
}
implementation
{
    //This will be replaced by a port level abstraction layer soon
    components
    new HplSam4lGeneralIOP(GPIO_PORT0_ADDRESS,  0) as PA00P,
    new HplSam4lGeneralIOP(GPIO_PORT0_ADDRESS,  1) as PA01P,
    new HplSam4lGeneralIOP(GPIO_PORT0_ADDRESS,  2) as PA02P,
    new HplSam4lGeneralIOP(GPIO_PORT0_ADDRESS,  3) as PA03P,
    new HplSam4lGeneralIOP(GPIO_PORT0_ADDRESS,  4) as PA04P,
    new HplSam4lGeneralIOP(GPIO_PORT0_ADDRESS,  5) as PA05P,
    new HplSam4lGeneralIOP(GPIO_PORT0_ADDRESS,  6) as PA06P,
    new HplSam4lGeneralIOP(GPIO_PORT0_ADDRESS,  7) as PA07P,
    new HplSam4lGeneralIOP(GPIO_PORT0_ADDRESS,  8) as PA08P,
    new HplSam4lGeneralIOP(GPIO_PORT0_ADDRESS,  9) as PA09P,
    new HplSam4lGeneralIOP(GPIO_PORT0_ADDRESS, 10) as PA10P,
    new HplSam4lGeneralIOP(GPIO_PORT0_ADDRESS, 11) as PA11P,
    new HplSam4lGeneralIOP(GPIO_PORT0_ADDRESS, 12) as PA12P,
    new HplSam4lGeneralIOP(GPIO_PORT0_ADDRESS, 13) as PA13P,
    new HplSam4lGeneralIOP(GPIO_PORT0_ADDRESS, 14) as PA14P,
    new HplSam4lGeneralIOP(GPIO_PORT0_ADDRESS, 15) as PA15P,
    new HplSam4lGeneralIOP(GPIO_PORT0_ADDRESS, 16) as PA16P,
    new HplSam4lGeneralIOP(GPIO_PORT0_ADDRESS, 17) as PA17P,
    new HplSam4lGeneralIOP(GPIO_PORT0_ADDRESS, 18) as PA18P,
    new HplSam4lGeneralIOP(GPIO_PORT0_ADDRESS, 19) as PA19P,
    new HplSam4lGeneralIOP(GPIO_PORT0_ADDRESS, 20) as PA20P,
    new HplSam4lGeneralIOP(GPIO_PORT0_ADDRESS, 21) as PA21P,
    new HplSam4lGeneralIOP(GPIO_PORT0_ADDRESS, 22) as PA22P,
    new HplSam4lGeneralIOP(GPIO_PORT0_ADDRESS, 23) as PA23P,
    new HplSam4lGeneralIOP(GPIO_PORT0_ADDRESS, 24) as PA24P,
    new HplSam4lGeneralIOP(GPIO_PORT0_ADDRESS, 25) as PA25P,
    new HplSam4lGeneralIOP(GPIO_PORT0_ADDRESS, 26) as PA26P,

    new HplSam4lGeneralIOP(GPIO_PORT1_ADDRESS,  0) as PB00P,
    new HplSam4lGeneralIOP(GPIO_PORT1_ADDRESS,  1) as PB01P,
    new HplSam4lGeneralIOP(GPIO_PORT1_ADDRESS,  2) as PB02P,
    new HplSam4lGeneralIOP(GPIO_PORT1_ADDRESS,  3) as PB03P,
    new HplSam4lGeneralIOP(GPIO_PORT1_ADDRESS,  4) as PB04P,
    new HplSam4lGeneralIOP(GPIO_PORT1_ADDRESS,  5) as PB05P,
    new HplSam4lGeneralIOP(GPIO_PORT1_ADDRESS,  6) as PB06P,
    new HplSam4lGeneralIOP(GPIO_PORT1_ADDRESS,  7) as PB07P,
    new HplSam4lGeneralIOP(GPIO_PORT1_ADDRESS,  8) as PB08P,
    new HplSam4lGeneralIOP(GPIO_PORT1_ADDRESS,  9) as PB09P,
    new HplSam4lGeneralIOP(GPIO_PORT1_ADDRESS, 10) as PB10P,
    new HplSam4lGeneralIOP(GPIO_PORT1_ADDRESS, 11) as PB11P,
    new HplSam4lGeneralIOP(GPIO_PORT1_ADDRESS, 12) as PB12P,
    new HplSam4lGeneralIOP(GPIO_PORT1_ADDRESS, 13) as PB13P,
    new HplSam4lGeneralIOP(GPIO_PORT1_ADDRESS, 14) as PB14P,
    new HplSam4lGeneralIOP(GPIO_PORT1_ADDRESS, 15) as PB15P,

    new HplSam4lGeneralIOP(GPIO_PORT2_ADDRESS,  0) as PC00P,
    new HplSam4lGeneralIOP(GPIO_PORT2_ADDRESS,  1) as PC01P,
    new HplSam4lGeneralIOP(GPIO_PORT2_ADDRESS,  2) as PC02P,
    new HplSam4lGeneralIOP(GPIO_PORT2_ADDRESS,  3) as PC03P,
    new HplSam4lGeneralIOP(GPIO_PORT2_ADDRESS,  4) as PC04P,
    new HplSam4lGeneralIOP(GPIO_PORT2_ADDRESS,  5) as PC05P,
    new HplSam4lGeneralIOP(GPIO_PORT2_ADDRESS,  6) as PC06P,
    new HplSam4lGeneralIOP(GPIO_PORT2_ADDRESS,  7) as PC07P,
    new HplSam4lGeneralIOP(GPIO_PORT2_ADDRESS,  8) as PC08P,
    new HplSam4lGeneralIOP(GPIO_PORT2_ADDRESS,  9) as PC09P,
    new HplSam4lGeneralIOP(GPIO_PORT2_ADDRESS, 10) as PC10P,
    new HplSam4lGeneralIOP(GPIO_PORT2_ADDRESS, 11) as PC11P,
    new HplSam4lGeneralIOP(GPIO_PORT2_ADDRESS, 12) as PC12P,
    new HplSam4lGeneralIOP(GPIO_PORT2_ADDRESS, 13) as PC13P,
    new HplSam4lGeneralIOP(GPIO_PORT2_ADDRESS, 14) as PC14P,
    new HplSam4lGeneralIOP(GPIO_PORT2_ADDRESS, 15) as PC15P,
    new HplSam4lGeneralIOP(GPIO_PORT2_ADDRESS, 16) as PC16P,
    new HplSam4lGeneralIOP(GPIO_PORT2_ADDRESS, 17) as PC17P,
    new HplSam4lGeneralIOP(GPIO_PORT2_ADDRESS, 18) as PC18P,
    new HplSam4lGeneralIOP(GPIO_PORT2_ADDRESS, 19) as PC19P,
    new HplSam4lGeneralIOP(GPIO_PORT2_ADDRESS, 20) as PC20P,
    new HplSam4lGeneralIOP(GPIO_PORT2_ADDRESS, 21) as PC21P,
    new HplSam4lGeneralIOP(GPIO_PORT2_ADDRESS, 22) as PC22P,
    new HplSam4lGeneralIOP(GPIO_PORT2_ADDRESS, 23) as PC23P,
    new HplSam4lGeneralIOP(GPIO_PORT2_ADDRESS, 24) as PC24P,
    new HplSam4lGeneralIOP(GPIO_PORT2_ADDRESS, 25) as PC25P,
    new HplSam4lGeneralIOP(GPIO_PORT2_ADDRESS, 26) as PC26P,
    new HplSam4lGeneralIOP(GPIO_PORT2_ADDRESS, 27) as PC27P,
    new HplSam4lGeneralIOP(GPIO_PORT2_ADDRESS, 28) as PC28P,
    new HplSam4lGeneralIOP(GPIO_PORT2_ADDRESS, 29) as PC29P,
    new HplSam4lGeneralIOP(GPIO_PORT2_ADDRESS, 30) as PC30P,
    new HplSam4lGeneralIOP(GPIO_PORT2_ADDRESS, 31) as PC31P;

    PA00 = PA00P;
    PA01 = PA01P;
    PA02 = PA02P;
    PA03 = PA03P;
    PA04 = PA04P;
    PA05 = PA05P;
    PA06 = PA06P;
    PA07 = PA07P;
    PA08 = PA08P;
    PA09 = PA09P;
    PA10 = PA10P;
    PA11 = PA11P;
    PA12 = PA12P;
    PA13 = PA13P;
    PA14 = PA14P;
    PA15 = PA15P;
    PA16 = PA16P;
    PA17 = PA17P;
    PA18 = PA18P;
    PA19 = PA19P;
    PA20 = PA20P;
    PA21 = PA21P;
    PA22 = PA22P;
    PA23 = PA23P;
    PA24 = PA24P;
    PA25 = PA25P;
    PA26 = PA26P;
    PB00 = PB00P;
    PB01 = PB01P;
    PB02 = PB02P;
    PB03 = PB03P;
    PB04 = PB04P;
    PB05 = PB05P;
    PB06 = PB06P;
    PB07 = PB07P;
    PB08 = PB08P;
    PB09 = PB09P;
    PB10 = PB10P;
    PB11 = PB11P;
    PB12 = PB12P;
    PB13 = PB13P;
    PB14 = PB14P;
    PB15 = PB15P;
    PC00 = PC00P;
    PC01 = PC01P;
    PC02 = PC02P;
    PC03 = PC03P;
    PC04 = PC04P;
    PC05 = PC05P;
    PC06 = PC06P;
    PC07 = PC07P;
    PC08 = PC08P;
    PC09 = PC09P;
    PC10 = PC10P;
    PC11 = PC11P;
    PC12 = PC12P;
    PC13 = PC13P;
    PC14 = PC14P;
    PC15 = PC15P;
    PC16 = PC16P;
    PC17 = PC17P;
    PC18 = PC18P;
    PC19 = PC19P;
    PC20 = PC20P;
    PC21 = PC21P;
    PC22 = PC22P;
    PC23 = PC23P;
    PC24 = PC24P;
    PC25 = PC25P;
    PC26 = PC26P;
    PC27 = PC27P;
    PC28 = PC28P;
    PC29 = PC29P;
    PC30 = PC30P;
    PC31 = PC31P;

    PA00IRQ = PA00P;
    PA01IRQ = PA01P;
    PA02IRQ = PA02P;
    PA03IRQ = PA03P;
    PA04IRQ = PA04P;
    PA05IRQ = PA05P;
    PA06IRQ = PA06P;
    PA07IRQ = PA07P;
    PA08IRQ = PA08P;
    PA09IRQ = PA09P;
    PA10IRQ = PA10P;
    PA11IRQ = PA11P;
    PA12IRQ = PA12P;
    PA13IRQ = PA13P;
    PA14IRQ = PA14P;
    PA15IRQ = PA15P;
    PA16IRQ = PA16P;
    PA17IRQ = PA17P;
    PA18IRQ = PA18P;
    PA19IRQ = PA19P;
    PA20IRQ = PA20P;
    PA21IRQ = PA21P;
    PA22IRQ = PA22P;
    PA23IRQ = PA23P;
    PA24IRQ = PA24P;
    PA25IRQ = PA25P;
    PA26IRQ = PA26P;
    PB00IRQ = PB00P;
    PB01IRQ = PB01P;
    PB02IRQ = PB02P;
    PB03IRQ = PB03P;
    PB04IRQ = PB04P;
    PB05IRQ = PB05P;
    PB06IRQ = PB06P;
    PB07IRQ = PB07P;
    PB08IRQ = PB08P;
    PB09IRQ = PB09P;
    PB10IRQ = PB10P;
    PB11IRQ = PB11P;
    PB12IRQ = PB12P;
    PB13IRQ = PB13P;
    PB14IRQ = PB14P;
    PB15IRQ = PB15P;
    PC00IRQ = PC00P;
    PC01IRQ = PC01P;
    PC02IRQ = PC02P;
    PC03IRQ = PC03P;
    PC04IRQ = PC04P;
    PC05IRQ = PC05P;
    PC06IRQ = PC06P;
    PC07IRQ = PC07P;
    PC08IRQ = PC08P;
    PC09IRQ = PC09P;
    PC10IRQ = PC10P;
    PC11IRQ = PC11P;
    PC12IRQ = PC12P;
    PC13IRQ = PC13P;
    PC14IRQ = PC14P;
    PC15IRQ = PC15P;
    PC16IRQ = PC16P;
    PC17IRQ = PC17P;
    PC18IRQ = PC18P;
    PC19IRQ = PC19P;
    PC20IRQ = PC20P;
    PC21IRQ = PC21P;
    PC22IRQ = PC22P;
    PC23IRQ = PC23P;
    PC24IRQ = PC24P;
    PC25IRQ = PC25P;
    PC26IRQ = PC26P;
    PC27IRQ = PC27P;
    PC28IRQ = PC28P;
    PC29IRQ = PC29P;
    PC30IRQ = PC30P;
    PC31IRQ = PC31P;

    HplPA00 = PA00P;
    HplPA01 = PA01P;
    HplPA02 = PA02P;
    HplPA03 = PA03P;
    HplPA04 = PA04P;
    HplPA05 = PA05P;
    HplPA06 = PA06P;
    HplPA07 = PA07P;
    HplPA08 = PA08P;
    HplPA09 = PA09P;
    HplPA10 = PA10P;
    HplPA11 = PA11P;
    HplPA12 = PA12P;
    HplPA13 = PA13P;
    HplPA14 = PA14P;
    HplPA15 = PA15P;
    HplPA16 = PA16P;
    HplPA17 = PA17P;
    HplPA18 = PA18P;
    HplPA19 = PA19P;
    HplPA20 = PA20P;
    HplPA21 = PA21P;
    HplPA22 = PA22P;
    HplPA23 = PA23P;
    HplPA24 = PA24P;
    HplPA25 = PA25P;
    HplPA26 = PA26P;
    HplPB00 = PB00P;
    HplPB01 = PB01P;
    HplPB02 = PB02P;
    HplPB03 = PB03P;
    HplPB04 = PB04P;
    HplPB05 = PB05P;
    HplPB06 = PB06P;
    HplPB07 = PB07P;
    HplPB08 = PB08P;
    HplPB09 = PB09P;
    HplPB10 = PB10P;
    HplPB11 = PB11P;
    HplPB12 = PB12P;
    HplPB13 = PB13P;
    HplPB14 = PB14P;
    HplPB15 = PB15P;
    HplPC00 = PC00P;
    HplPC01 = PC01P;
    HplPC02 = PC02P;
    HplPC03 = PC03P;
    HplPC04 = PC04P;
    HplPC05 = PC05P;
    HplPC06 = PC06P;
    HplPC07 = PC07P;
    HplPC08 = PC08P;
    HplPC09 = PC09P;
    HplPC10 = PC10P;
    HplPC11 = PC11P;
    HplPC12 = PC12P;
    HplPC13 = PC13P;
    HplPC14 = PC14P;
    HplPC15 = PC15P;
    HplPC16 = PC16P;
    HplPC17 = PC17P;
    HplPC18 = PC18P;
    HplPC19 = PC19P;
    HplPC20 = PC20P;
    HplPC21 = PC21P;
    HplPC22 = PC22P;
    HplPC23 = PC23P;
    HplPC24 = PC24P;
    HplPC25 = PC25P;
    HplPC26 = PC26P;
    HplPC27 = PC27P;
    HplPC28 = PC28P;
    HplPC29 = PC29P;
    HplPC30 = PC30P;
    HplPC31 = PC31P;

    components HplSam4lGeneralIOPortP, HplSam4lClockC, McuSleepC;
    HplSam4lGeneralIOPortP.GPIOClock -> HplSam4lClockC.GPIOCtl;
    HplSam4lGeneralIOPortP.IRQWrapper -> McuSleepC;

    PA00P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortA;
    PA01P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortA;
    PA02P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortA;
    PA03P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortA;
    PA04P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortA;
    PA05P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortA;
    PA06P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortA;
    PA07P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortA;
    PA08P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortA;
    PA09P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortA;
    PA10P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortA;
    PA11P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortA;
    PA12P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortA;
    PA13P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortA;
    PA14P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortA;
    PA15P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortA;
    PA16P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortA;
    PA17P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortA;
    PA18P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortA;
    PA19P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortA;
    PA20P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortA;
    PA21P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortA;
    PA22P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortA;
    PA23P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortA;
    PA24P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortA;
    PA25P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortA;
    PA26P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortA;
    PB00P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortB;
    PB01P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortB;
    PB02P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortB;
    PB03P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortB;
    PB04P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortB;
    PB05P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortB;
    PB06P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortB;
    PB07P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortB;
    PB08P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortB;
    PB09P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortB;
    PB10P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortB;
    PB11P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortB;
    PB12P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortB;
    PB13P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortB;
    PB14P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortB;
    PB15P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortB;
    PC00P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortC;
    PC01P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortC;
    PC02P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortC;
    PC03P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortC;
    PC04P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortC;
    PC05P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortC;
    PC06P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortC;
    PC07P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortC;
    PC08P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortC;
    PC09P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortC;
    PC10P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortC;
    PC11P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortC;
    PC12P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortC;
    PC13P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortC;
    PC14P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortC;
    PC15P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortC;
    PC16P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortC;
    PC17P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortC;
    PC18P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortC;
    PC19P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortC;
    PC20P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortC;
    PC21P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortC;
    PC22P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortC;
    PC23P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortC;
    PC24P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortC;
    PC25P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortC;
    PC26P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortC;
    PC27P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortC;
    PC28P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortC;
    PC29P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortC;
    PC30P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortC;
    PC31P.HplSam4lGeneralIOPort -> HplSam4lGeneralIOPortP.PortC;

    PA00P.ByteIRQ -> HplSam4lGeneralIOPortP.PortA_IRQ[0];
    PA01P.ByteIRQ -> HplSam4lGeneralIOPortP.PortA_IRQ[0];
    PA02P.ByteIRQ -> HplSam4lGeneralIOPortP.PortA_IRQ[0];
    PA03P.ByteIRQ -> HplSam4lGeneralIOPortP.PortA_IRQ[0];
    PA04P.ByteIRQ -> HplSam4lGeneralIOPortP.PortA_IRQ[0];
    PA05P.ByteIRQ -> HplSam4lGeneralIOPortP.PortA_IRQ[0];
    PA06P.ByteIRQ -> HplSam4lGeneralIOPortP.PortA_IRQ[0];
    PA07P.ByteIRQ -> HplSam4lGeneralIOPortP.PortA_IRQ[0];

    PA08P.ByteIRQ -> HplSam4lGeneralIOPortP.PortA_IRQ[1];
    PA09P.ByteIRQ -> HplSam4lGeneralIOPortP.PortA_IRQ[1];
    PA10P.ByteIRQ -> HplSam4lGeneralIOPortP.PortA_IRQ[1];
    PA11P.ByteIRQ -> HplSam4lGeneralIOPortP.PortA_IRQ[1];
    PA12P.ByteIRQ -> HplSam4lGeneralIOPortP.PortA_IRQ[1];
    PA13P.ByteIRQ -> HplSam4lGeneralIOPortP.PortA_IRQ[1];
    PA14P.ByteIRQ -> HplSam4lGeneralIOPortP.PortA_IRQ[1];
    PA15P.ByteIRQ -> HplSam4lGeneralIOPortP.PortA_IRQ[1];

    PA16P.ByteIRQ -> HplSam4lGeneralIOPortP.PortA_IRQ[2];
    PA17P.ByteIRQ -> HplSam4lGeneralIOPortP.PortA_IRQ[2];
    PA18P.ByteIRQ -> HplSam4lGeneralIOPortP.PortA_IRQ[2];
    PA19P.ByteIRQ -> HplSam4lGeneralIOPortP.PortA_IRQ[2];
    PA20P.ByteIRQ -> HplSam4lGeneralIOPortP.PortA_IRQ[2];
    PA21P.ByteIRQ -> HplSam4lGeneralIOPortP.PortA_IRQ[2];
    PA22P.ByteIRQ -> HplSam4lGeneralIOPortP.PortA_IRQ[2];
    PA23P.ByteIRQ -> HplSam4lGeneralIOPortP.PortA_IRQ[2];

    PA24P.ByteIRQ -> HplSam4lGeneralIOPortP.PortA_IRQ[3];
    PA25P.ByteIRQ -> HplSam4lGeneralIOPortP.PortA_IRQ[3];
    PA26P.ByteIRQ -> HplSam4lGeneralIOPortP.PortA_IRQ[3];

    PB00P.ByteIRQ -> HplSam4lGeneralIOPortP.PortB_IRQ[0];
    PB01P.ByteIRQ -> HplSam4lGeneralIOPortP.PortB_IRQ[0];
    PB02P.ByteIRQ -> HplSam4lGeneralIOPortP.PortB_IRQ[0];
    PB03P.ByteIRQ -> HplSam4lGeneralIOPortP.PortB_IRQ[0];
    PB04P.ByteIRQ -> HplSam4lGeneralIOPortP.PortB_IRQ[0];
    PB05P.ByteIRQ -> HplSam4lGeneralIOPortP.PortB_IRQ[0];
    PB06P.ByteIRQ -> HplSam4lGeneralIOPortP.PortB_IRQ[0];
    PB07P.ByteIRQ -> HplSam4lGeneralIOPortP.PortB_IRQ[0];

    PB08P.ByteIRQ -> HplSam4lGeneralIOPortP.PortB_IRQ[1];
    PB09P.ByteIRQ -> HplSam4lGeneralIOPortP.PortB_IRQ[1];
    PB10P.ByteIRQ -> HplSam4lGeneralIOPortP.PortB_IRQ[1];
    PB11P.ByteIRQ -> HplSam4lGeneralIOPortP.PortB_IRQ[1];
    PB12P.ByteIRQ -> HplSam4lGeneralIOPortP.PortB_IRQ[1];
    PB13P.ByteIRQ -> HplSam4lGeneralIOPortP.PortB_IRQ[1];
    PB14P.ByteIRQ -> HplSam4lGeneralIOPortP.PortB_IRQ[1];
    PB15P.ByteIRQ -> HplSam4lGeneralIOPortP.PortB_IRQ[1];

    PC00P.ByteIRQ -> HplSam4lGeneralIOPortP.PortC_IRQ[0];
    PC01P.ByteIRQ -> HplSam4lGeneralIOPortP.PortC_IRQ[0];
    PC02P.ByteIRQ -> HplSam4lGeneralIOPortP.PortC_IRQ[0];
    PC03P.ByteIRQ -> HplSam4lGeneralIOPortP.PortC_IRQ[0];
    PC04P.ByteIRQ -> HplSam4lGeneralIOPortP.PortC_IRQ[0];
    PC05P.ByteIRQ -> HplSam4lGeneralIOPortP.PortC_IRQ[0];
    PC06P.ByteIRQ -> HplSam4lGeneralIOPortP.PortC_IRQ[0];
    PC07P.ByteIRQ -> HplSam4lGeneralIOPortP.PortC_IRQ[0];

    PC08P.ByteIRQ -> HplSam4lGeneralIOPortP.PortC_IRQ[1];
    PC09P.ByteIRQ -> HplSam4lGeneralIOPortP.PortC_IRQ[1];
    PC10P.ByteIRQ -> HplSam4lGeneralIOPortP.PortC_IRQ[1];
    PC11P.ByteIRQ -> HplSam4lGeneralIOPortP.PortC_IRQ[1];
    PC12P.ByteIRQ -> HplSam4lGeneralIOPortP.PortC_IRQ[1];
    PC13P.ByteIRQ -> HplSam4lGeneralIOPortP.PortC_IRQ[1];
    PC14P.ByteIRQ -> HplSam4lGeneralIOPortP.PortC_IRQ[1];
    PC15P.ByteIRQ -> HplSam4lGeneralIOPortP.PortC_IRQ[1];

    PC16P.ByteIRQ -> HplSam4lGeneralIOPortP.PortC_IRQ[2];
    PC17P.ByteIRQ -> HplSam4lGeneralIOPortP.PortC_IRQ[2];
    PC18P.ByteIRQ -> HplSam4lGeneralIOPortP.PortC_IRQ[2];
    PC19P.ByteIRQ -> HplSam4lGeneralIOPortP.PortC_IRQ[2];
    PC20P.ByteIRQ -> HplSam4lGeneralIOPortP.PortC_IRQ[2];
    PC21P.ByteIRQ -> HplSam4lGeneralIOPortP.PortC_IRQ[2];
    PC22P.ByteIRQ -> HplSam4lGeneralIOPortP.PortC_IRQ[2];
    PC23P.ByteIRQ -> HplSam4lGeneralIOPortP.PortC_IRQ[2];

    PC24P.ByteIRQ -> HplSam4lGeneralIOPortP.PortC_IRQ[3];
    PC25P.ByteIRQ -> HplSam4lGeneralIOPortP.PortC_IRQ[3];
    PC26P.ByteIRQ -> HplSam4lGeneralIOPortP.PortC_IRQ[3];
    PC27P.ByteIRQ -> HplSam4lGeneralIOPortP.PortC_IRQ[3];
    PC28P.ByteIRQ -> HplSam4lGeneralIOPortP.PortC_IRQ[3];
    PC29P.ByteIRQ -> HplSam4lGeneralIOPortP.PortC_IRQ[3];
    PC30P.ByteIRQ -> HplSam4lGeneralIOPortP.PortC_IRQ[3];
    PC31P.ByteIRQ -> HplSam4lGeneralIOPortP.PortC_IRQ[3];
}