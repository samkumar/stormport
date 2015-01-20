#include "driver.h"
#include <stdint.h>

module StormSysInfoP
{
    provides interface Driver;
    uses interface LocalIeeeEui64;
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
            memcpy((uint8_t*)arg0, address.data, 8);
            return 0;
        default:
            return (uint32_t) -1;
        }
    }
}
