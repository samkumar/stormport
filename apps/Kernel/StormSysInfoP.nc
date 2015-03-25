#include "driver.h"
#include <stdint.h>

module StormSysInfoP
{
    provides interface Driver;
    uses interface LocalIeeeEui64;
    uses interface LockLevel;
}
implementation
{
    command driver_callback_t Driver.peek_callback()
    {
        return NULL;
    }

    command void Driver.pop_callback() {}

    async command syscall_rv_t Driver.syscall_ex(
        uint32_t number, uint32_t arg0, 
        uint32_t arg1, uint32_t arg2, 
        uint32_t *argx)
    {
        ieee_eui64_t address = call LocalIeeeEui64.getId();
        struct in6_addr addr;
        int i;
        switch(number & 0xFF)
        {
        case 0x01: // get node_id
            return address.data[7] | address.data[6] << 8;
        case 0x02: // get MAC
            ((uint8_t*)arg0)[0] = address.data[0];
            ((uint8_t*)arg0)[1] = address.data[1];
            ((uint8_t*)arg0)[2] = address.data[2];
            ((uint8_t*)arg0)[3] = address.data[3];
            ((uint8_t*)arg0)[4] = address.data[6];
            ((uint8_t*)arg0)[5] = address.data[7];
            return 0;
        case 0x03: // get IP address
            inet_pton6(IN6_PREFIX, &addr);
            for (i=0;i<8;i++)
            {
                ((uint8_t*)arg0)[i] = addr.in6_u.u6_addr8[i];
            }
            for (i=8;i<16;i++)
            {
                ((uint8_t*)arg0)[i] = address.data[i-8];
            }
            return 0;
        case 0x04: // reset
        {
            //This is a little ugly, but its prettier than including the whole CMSIS
            //trust me on that.
            uint32_t prigrp = *((volatile uint32_t*)(0xE000ED0C)) & (3<<7);
            asm("dsb");
            *((volatile uint32_t*)(0xE000ED0C)) = 0x05FA0000 | prigrp | 4;
            asm("dsb");
            return 0;
        }
        case 0x05: //setpowerlock(i)
        {
            call LockLevel.setLockLevel(arg0);
            return 0;
        }
        default:
            return (uint32_t) -1;
        }
    }
}
