#include "driver.h"
#include <stdint.h>
module StubDriverP
{
    provides interface Driver[uint32_t id];
}
implementation
{
    command callback_t Driver.peek_callback[uint32_t id]()
    {
        return NULL;
    }
    command void Driver.pop_callback[uint32_t id]()
    {

    }
    command void Driver.init[uint32_t id]()
    {

    }

    async command syscall_rv_t Driver.syscall_ex[uint32_t id](
        uint32_t number, uint32_t arg0, 
        uint32_t arg1, uint32_t arg2, 
        uint32_t *argx)
    {
        return 0;
    }
}

