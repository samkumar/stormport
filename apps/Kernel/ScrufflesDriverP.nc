#include "driver.h"
module ScrufflesDriverP
{
    provides interface Driver;
    provides interface Init;
    uses interface Scruffles;
    uses interface StdControl;
}
implementation
{
    command error_t Init.init()
    {
    #ifdef ENABLE_SCRUFFLES
        call StdControl.start();
    #endif
        return SUCCESS;
    }
    async command syscall_rv_t Driver.syscall_ex(
        uint32_t number, uint32_t arg0,
        uint32_t arg1, uint32_t arg2,
        uint32_t *argx)
    {
        switch(number & 0xFF)
        {
                       //      ar0   arg1    arg2     arx[0], argx[1]   argx[2]
            case 0x01: //kick watchdog
            {
            #ifdef ENABLE_SCRUFFLES
                call Scruffles.kick();
            #endif
                return 0;
            }
        }
    }

    command driver_callback_t Driver.peek_callback()
    {
        return NULL;
    }
    command void Driver.pop_callback()
    {
    }
}
