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
    }
}
implementation
{
    //This will be replaced by a port level abstraction layer soon
    components
    new HplSam4lGeneralIOPinP(GPIO_PORT0_ADDRESS,  0) as PA00P,
    new HplSam4lGeneralIOPinP(GPIO_PORT0_ADDRESS,  1) as PA01P,
    new HplSam4lGeneralIOPinP(GPIO_PORT0_ADDRESS,  2) as PA02P,
    new HplSam4lGeneralIOPinP(GPIO_PORT0_ADDRESS,  3) as PA03P,
    new HplSam4lGeneralIOPinP(GPIO_PORT0_ADDRESS,  4) as PA04P,
    new HplSam4lGeneralIOPinP(GPIO_PORT0_ADDRESS,  5) as PA05P,
    new HplSam4lGeneralIOPinP(GPIO_PORT0_ADDRESS,  6) as PA06P,
    new HplSam4lGeneralIOPinP(GPIO_PORT0_ADDRESS,  7) as PA07P,
    new HplSam4lGeneralIOPinP(GPIO_PORT0_ADDRESS,  8) as PA08P,
    new HplSam4lGeneralIOPinP(GPIO_PORT0_ADDRESS,  9) as PA09P,
    new HplSam4lGeneralIOPinP(GPIO_PORT0_ADDRESS, 10) as PA10P,
    new HplSam4lGeneralIOPinP(GPIO_PORT0_ADDRESS, 11) as PA11P,
    new HplSam4lGeneralIOPinP(GPIO_PORT0_ADDRESS, 12) as PA12P,
    new HplSam4lGeneralIOPinP(GPIO_PORT0_ADDRESS, 13) as PA13P,
    new HplSam4lGeneralIOPinP(GPIO_PORT0_ADDRESS, 14) as PA14P,
    new HplSam4lGeneralIOPinP(GPIO_PORT0_ADDRESS, 15) as PA15P,
    new HplSam4lGeneralIOPinP(GPIO_PORT0_ADDRESS, 16) as PA16P,
    new HplSam4lGeneralIOPinP(GPIO_PORT0_ADDRESS, 17) as PA17P,
    new HplSam4lGeneralIOPinP(GPIO_PORT0_ADDRESS, 18) as PA18P,
    new HplSam4lGeneralIOPinP(GPIO_PORT0_ADDRESS, 19) as PA19P,
    new HplSam4lGeneralIOPinP(GPIO_PORT0_ADDRESS, 20) as PA20P,
    new HplSam4lGeneralIOPinP(GPIO_PORT0_ADDRESS, 21) as PA21P,
    new HplSam4lGeneralIOPinP(GPIO_PORT0_ADDRESS, 22) as PA22P,
    new HplSam4lGeneralIOPinP(GPIO_PORT0_ADDRESS, 23) as PA23P,
    new HplSam4lGeneralIOPinP(GPIO_PORT0_ADDRESS, 24) as PA24P,
    new HplSam4lGeneralIOPinP(GPIO_PORT0_ADDRESS, 25) as PA25P,
    new HplSam4lGeneralIOPinP(GPIO_PORT0_ADDRESS, 26) as PA26P,

    new HplSam4lGeneralIOPinP(GPIO_PORT1_ADDRESS,  0) as PB00P,
    new HplSam4lGeneralIOPinP(GPIO_PORT1_ADDRESS,  1) as PB01P,
    new HplSam4lGeneralIOPinP(GPIO_PORT1_ADDRESS,  2) as PB02P,
    new HplSam4lGeneralIOPinP(GPIO_PORT1_ADDRESS,  3) as PB03P,
    new HplSam4lGeneralIOPinP(GPIO_PORT1_ADDRESS,  4) as PB04P,
    new HplSam4lGeneralIOPinP(GPIO_PORT1_ADDRESS,  5) as PB05P,
    new HplSam4lGeneralIOPinP(GPIO_PORT1_ADDRESS,  6) as PB06P,
    new HplSam4lGeneralIOPinP(GPIO_PORT1_ADDRESS,  7) as PB07P,
    new HplSam4lGeneralIOPinP(GPIO_PORT1_ADDRESS,  8) as PB08P,
    new HplSam4lGeneralIOPinP(GPIO_PORT1_ADDRESS,  9) as PB09P,
    new HplSam4lGeneralIOPinP(GPIO_PORT1_ADDRESS, 10) as PB10P,
    new HplSam4lGeneralIOPinP(GPIO_PORT1_ADDRESS, 11) as PB11P,
    new HplSam4lGeneralIOPinP(GPIO_PORT1_ADDRESS, 12) as PB12P,
    new HplSam4lGeneralIOPinP(GPIO_PORT1_ADDRESS, 13) as PB13P,
    new HplSam4lGeneralIOPinP(GPIO_PORT1_ADDRESS, 14) as PB14P,
    new HplSam4lGeneralIOPinP(GPIO_PORT1_ADDRESS, 15) as PB15P,

    new HplSam4lGeneralIOPinP(GPIO_PORT2_ADDRESS,  0) as PC00P,
    new HplSam4lGeneralIOPinP(GPIO_PORT2_ADDRESS,  1) as PC01P,
    new HplSam4lGeneralIOPinP(GPIO_PORT2_ADDRESS,  2) as PC02P,
    new HplSam4lGeneralIOPinP(GPIO_PORT2_ADDRESS,  3) as PC03P,
    new HplSam4lGeneralIOPinP(GPIO_PORT2_ADDRESS,  4) as PC04P,
    new HplSam4lGeneralIOPinP(GPIO_PORT2_ADDRESS,  5) as PC05P,
    new HplSam4lGeneralIOPinP(GPIO_PORT2_ADDRESS,  6) as PC06P,
    new HplSam4lGeneralIOPinP(GPIO_PORT2_ADDRESS,  7) as PC07P,
    new HplSam4lGeneralIOPinP(GPIO_PORT2_ADDRESS,  8) as PC08P,
    new HplSam4lGeneralIOPinP(GPIO_PORT2_ADDRESS,  9) as PC09P,
    new HplSam4lGeneralIOPinP(GPIO_PORT2_ADDRESS, 10) as PC10P,
    new HplSam4lGeneralIOPinP(GPIO_PORT2_ADDRESS, 11) as PC11P,
    new HplSam4lGeneralIOPinP(GPIO_PORT2_ADDRESS, 12) as PC12P,
    new HplSam4lGeneralIOPinP(GPIO_PORT2_ADDRESS, 13) as PC13P,
    new HplSam4lGeneralIOPinP(GPIO_PORT2_ADDRESS, 14) as PC14P,
    new HplSam4lGeneralIOPinP(GPIO_PORT2_ADDRESS, 15) as PC15P,
    new HplSam4lGeneralIOPinP(GPIO_PORT2_ADDRESS, 16) as PC16P,
    new HplSam4lGeneralIOPinP(GPIO_PORT2_ADDRESS, 17) as PC17P,
    new HplSam4lGeneralIOPinP(GPIO_PORT2_ADDRESS, 18) as PC18P,
    new HplSam4lGeneralIOPinP(GPIO_PORT2_ADDRESS, 19) as PC19P,
    new HplSam4lGeneralIOPinP(GPIO_PORT2_ADDRESS, 20) as PC20P,
    new HplSam4lGeneralIOPinP(GPIO_PORT2_ADDRESS, 21) as PC21P,
    new HplSam4lGeneralIOPinP(GPIO_PORT2_ADDRESS, 22) as PC22P,
    new HplSam4lGeneralIOPinP(GPIO_PORT2_ADDRESS, 23) as PC23P,
    new HplSam4lGeneralIOPinP(GPIO_PORT2_ADDRESS, 24) as PC24P,
    new HplSam4lGeneralIOPinP(GPIO_PORT2_ADDRESS, 25) as PC25P,
    new HplSam4lGeneralIOPinP(GPIO_PORT2_ADDRESS, 26) as PC26P,
    new HplSam4lGeneralIOPinP(GPIO_PORT2_ADDRESS, 27) as PC27P,
    new HplSam4lGeneralIOPinP(GPIO_PORT2_ADDRESS, 28) as PC28P,
    new HplSam4lGeneralIOPinP(GPIO_PORT2_ADDRESS, 29) as PC29P,
    new HplSam4lGeneralIOPinP(GPIO_PORT2_ADDRESS, 30) as PC30P,
    new HplSam4lGeneralIOPinP(GPIO_PORT2_ADDRESS, 31) as PC31P;

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

}