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
        ieee_eui64_t address;
        switch(number & 0xFF)
        {
        case 0x01: // get node_id
            address = call LocalIeeeEui64.getId();
            return address.data[7] | address.data[6] << 8;
        //case 0x02: // get MAC
        //    address = call LocalIeeeEui64.getId();
        //    return address.data[0] << 40 | address.data[1] << 32 | address[2] << 24 | address[3] << 16 | address[1] << 8 | address[0];
        default:
            return (uint32_t) -1;
        }
    }
}
