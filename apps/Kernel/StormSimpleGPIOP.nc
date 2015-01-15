#include "driver.h"
#include <stdint.h>
module StormSimpleGPIOP
{
    provides interface Driver;
    uses
    {
        interface HplSam4lGeneralIOPort as PortA;
        interface HplSam4lGeneralIOPort as PortB;
        interface HplSam4lGeneralIOPort as PortC;
        interface ByteIRQ as PortA_IRQ [uint8_t id];
        interface ByteIRQ as PortB_IRQ [uint8_t id];
        interface ByteIRQ as PortC_IRQ [uint8_t id];
    }
}
implementation
{
    command driver_callback_t Driver.peek_callback()
    {
        return NULL;
    }
    command void Driver.pop_callback()
    {

    }
    async event void PortA_IRQ.fired[uint8_t id](){}
    async event void PortB_IRQ.fired[uint8_t id](){}
    async event void PortC_IRQ.fired[uint8_t id](){}

    async command syscall_rv_t Driver.syscall_ex(
        uint32_t number, uint32_t arg0, 
        uint32_t arg1, uint32_t arg2, 
        uint32_t *argx)
    {
        //printf("gpio_syscall_ex %d - %d %d\n",number, arg0, arg1);
        switch(number & 0xFF)
        {
            case 0x01: //set_mode(dir, pinspec)
            {
                uint32_t base_addr = 0x400E1000;
                uint8_t port = arg1 >> 8;
                uint32_t pinmask = 1 << (arg1 & 0xFF);
                if (port > 3)
                    return (uint32_t) - 1;

                if (arg0 == 0) //set 0utput
                {
                    *((uint32_t*)(base_addr + (0x200*port) + 0x004)) = pinmask; //enable GPIO 
                    *((uint32_t*)(base_addr + (0x200*port) + 0x044)) = pinmask; //enable driver 
                    *((uint32_t*)(base_addr + (0x200*port) + 0x168)) = pinmask; //disable ST
                    *((uint32_t*)(base_addr + (0x200*port) + 0x078)) = pinmask; //PUERC
                    *((uint32_t*)(base_addr + (0x200*port) + 0x088)) = pinmask; //PDERC
                    return 0;
                } else if (arg0 == 1) //set 1nput
                {
                    *((uint32_t*)(base_addr + (0x200*port) + 0x004)) = pinmask; //enable GPIO 
                    *((uint32_t*)(base_addr + (0x200*port) + 0x048)) = pinmask; //disable driver 
                    *((uint32_t*)(base_addr + (0x200*port) + 0x164)) = pinmask; //enable ST
                    *((uint32_t*)(base_addr + (0x200*port) + 0x078)) = pinmask; //PUERC
                    *((uint32_t*)(base_addr + (0x200*port) + 0x088)) = pinmask; //PDERC
                    return 0;
                } else if (arg0 == 2) //set peripheral
                {
                    *((uint32_t*)(base_addr + (0x200*port) + 0x008)) = pinmask; //disable GPIO 
                    *((uint32_t*)(base_addr + (0x200*port) + 0x048)) = pinmask; //disable driver 
                    *((uint32_t*)(base_addr + (0x200*port) + 0x168)) = pinmask; //disable ST
                    *((uint32_t*)(base_addr + (0x200*port) + 0x078)) = pinmask; //PUERC
                    *((uint32_t*)(base_addr + (0x200*port) + 0x088)) = pinmask; //PDERC
                    return 0;
                }
                return (uint32_t) -1;
            }
            case 0x02: //set(value, pinspec)
            {
                uint32_t base_addr = 0x400E1000;
                uint8_t port = arg1 >> 8;
                uint32_t pinmask = 1 << (arg1 & 0xFF);
                if (port > 3)
                    return (uint32_t) - 1;

                if (arg0 == 0)
                {
                    *((uint32_t*)(base_addr + (0x200*port) + 0x058)) = pinmask; //OVRC
                    return 0;
                }
                else if (arg0 == 1)
                {
                    *((uint32_t*)(base_addr + (0x200*port) + 0x054)) = pinmask; //OVRS
                    return 0;
                }
                else if (arg0 == 2)
                {
                    *((uint32_t*)(base_addr + (0x200*port) + 0x05c)) = pinmask; //OVRT
                    return 0;
                }
                return (uint32_t) -1;
            }
            case 0x03: //get(pinspec)
            {
                uint32_t base_addr = 0x400E1000;
                uint8_t port = arg0 >> 8;
                if (port > 3)
                    return (uint32_t) - 1;
                return (*((uint32_t*)(base_addr + (0x200*port) + 0x060)) >> (arg0 & 0xFF)) & 1;          
            }
            case 0x04: //set_pull(dir, pinspec) 0=off, 1=up, 2=down, 3=keeper
            {
                uint32_t base_addr = 0x400E1000;
                uint8_t port = arg1 >> 8;
                uint32_t pinmask = 1 << (arg1 & 0xFF);
                if (port > 3)
                    return (uint32_t) -1;

                if (arg0 == 0)
                {
                    *((uint32_t*)(base_addr + (0x200*port) + 0x078)) = pinmask; //PUERC
                    *((uint32_t*)(base_addr + (0x200*port) + 0x088)) = pinmask; //PDERC
                    return 0;
                }
                else if (arg0 == 1)
                {
                    *((uint32_t*)(base_addr + (0x200*port) + 0x074)) = pinmask; //PUERS
                    *((uint32_t*)(base_addr + (0x200*port) + 0x088)) = pinmask; //PDERC
                    return 0;
                }
                else if (arg0 == 2)
                {
                    *((uint32_t*)(base_addr + (0x200*port) + 0x078)) = pinmask; //PUERC
                    *((uint32_t*)(base_addr + (0x200*port) + 0x084)) = pinmask; //PDERS
                    return 0;
                }
                else if (arg0 == 3)
                {
                    *((uint32_t*)(base_addr + (0x200*port) + 0x074)) = pinmask; //PUERS
                    *((uint32_t*)(base_addr + (0x200*port) + 0x084)) = pinmask; //PDERS
                    return 0;
                }
                else
                {
                    return (uint32_t) -1;
                }
            }
            default:
                return (uint32_t) -1;
        }
    }
}

