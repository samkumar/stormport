
#include <gpiohardware.h>
#include <nvichardware.h>

module HplSam4lGeneralIOPortP
{
    provides
    {
        interface HplSam4lGeneralIOPort as PortA;
        interface ByteIRQ as PortA_IRQ [uint8_t i];
        interface HplSam4lGeneralIOPort as PortB;
        interface ByteIRQ as PortB_IRQ [uint8_t i];
        interface HplSam4lGeneralIOPort as PortC;
        interface ByteIRQ as PortC_IRQ [uint8_t i];
    }
    uses
    {
        interface HplSam4PeripheralClockCntl as GPIOClock;
        interface FunctionWrapper as IRQWrapper;
    }
}
implementation
{


    uint8_t enabled = 0;
    async command void PortA.enable()
    {
        call GPIOClock.enable();
        enabled |= 1;
    }
    async command void PortA.disable()
    {
        enabled &= ~1;
        if (enabled == 0)
        {
            call GPIOClock.disable();
        }
    }
    async command void PortB.enable()
    {
        call GPIOClock.enable();
        enabled |= 2;
    }
    async command void PortB.disable()
    {
        enabled &= ~2;
        if (enabled == 0)
        {
            call GPIOClock.disable();
        }
    }
    async command void PortC.enable()
    {
        call GPIOClock.enable();
        enabled |= 4;
    }
    async command void PortC.disable()
    {
        enabled &= ~4;
        if (enabled == 0)
        {
            call GPIOClock.disable();
        }
    }
    async command void PortA.enableIRQ(uint8_t bit)
    {
        NVIC->iser.flat[0] = 1 << (25 + (bit>>3));
        GPIO_PORT_A->iers = 1 << bit;
    }
    async command void PortA.disableIRQ(uint8_t bit)
    {
        GPIO_PORT_A->ierc = 1 << bit;
        if (GPIO_PORT_A->ier & (0xFF << (bit>>3)) == 0)
        {
            NVIC->icer.flat[0] = 1 << (25 + (bit>>3));
        }
    }
    async command void PortB.enableIRQ(uint8_t bit)
    {
        //port b crosses a word boundary
        uint8_t byte = bit >> 3;
        switch (byte)
        {
            case 0: NVIC->iser.bits.gpio4 = 1; break;
            case 1: NVIC->iser.bits.gpio5 = 1; break;
            case 2: NVIC->iser.bits.gpio6 = 1; break;
            case 3: NVIC->iser.bits.gpio7 = 1; break;
        }
        GPIO_PORT_B->iers = 1 << bit;
    }
    async command void PortB.disableIRQ(uint8_t bit)
    {
        uint8_t byte = bit >> 3;
        GPIO_PORT_B->ierc = 1 << bit;
        if (GPIO_PORT_B->ier & (0xFF << byte) == 0)
        {
            switch (byte)
            {
                case 0: NVIC->icer.bits.gpio4 = 1; break;
                case 1: NVIC->icer.bits.gpio5 = 1; break;
                case 2: NVIC->icer.bits.gpio6 = 1; break;
                case 3: NVIC->icer.bits.gpio7 = 1; break;
            }
        }
    }
    async command void PortC.enableIRQ(uint8_t bit)
    {
        NVIC->iser.flat[1] = 1 << (1 + (bit>>3));
        GPIO_PORT_C->iers = 1 << bit;
    }
    async command void PortC.disableIRQ(uint8_t bit)
    {
        GPIO_PORT_C->ierc = 1 << bit;
        if (GPIO_PORT_C->ier & (0xFF << (bit>>3)) == 0)
        {
            NVIC->icer.flat[1] = 1 << (1 + (bit>>3));
        }
    }

    default async event void PortA_IRQ.fired[uint8_t i](){}
    default async event void PortB_IRQ.fired[uint8_t i](){}
    default async event void PortC_IRQ.fired[uint8_t i](){}

    void GPIO_0_Handler() @C() @spontaneous()
    {
        call IRQWrapper.preamble();
        signal PortA_IRQ.fired[0]();
        call IRQWrapper.postamble();
    }

    void GPIO_1_Handler() @C() @spontaneous()
    {
        call IRQWrapper.preamble();
        signal PortA_IRQ.fired[1]();
        call IRQWrapper.postamble();
    }

    void GPIO_2_Handler() @C() @spontaneous()
    {
        call IRQWrapper.preamble();
        signal PortA_IRQ.fired[2]();
        call IRQWrapper.postamble();
    }

    void GPIO_3_Handler() @C() @spontaneous()
    {
        call IRQWrapper.preamble();
        signal PortA_IRQ.fired[3]();
        call IRQWrapper.postamble();
    }

    void GPIO_4_Handler() @C() @spontaneous()
    {
        call IRQWrapper.preamble();
        signal PortB_IRQ.fired[0]();
        call IRQWrapper.postamble();
    }

    void GPIO_5_Handler() @C() @spontaneous()
    {
        call IRQWrapper.preamble();
        signal PortB_IRQ.fired[1]();
        call IRQWrapper.postamble();
    }

    void GPIO_6_Handler() @C() @spontaneous()
    {
        call IRQWrapper.preamble();
        signal PortB_IRQ.fired[2]();
        call IRQWrapper.postamble();
    }

    void GPIO_7_Handler() @C() @spontaneous()
    {
        call IRQWrapper.preamble();
        signal PortB_IRQ.fired[3]();
        call IRQWrapper.postamble();
    }

    void GPIO_8_Handler() @C() @spontaneous()
    {
        call IRQWrapper.preamble();
        signal PortC_IRQ.fired[0]();
        call IRQWrapper.postamble();
    }

    void GPIO_9_Handler() @C() @spontaneous()
    {
        call IRQWrapper.preamble();
        signal PortC_IRQ.fired[1]();
        call IRQWrapper.postamble();
    }

    void GPIO_10_Handler() @C() @spontaneous()
    {
        call IRQWrapper.preamble();
        signal PortC_IRQ.fired[2]();
        call IRQWrapper.postamble();
    }

    void GPIO_11_Handler() @C() @spontaneous()
    {
        call IRQWrapper.preamble();
        signal PortC_IRQ.fired[3]();
        call IRQWrapper.postamble();
    }

}