#include <stdint.h>
#include "driver.h"
interface Driver
{
    async command syscall_rv_t syscall_ex(uint32_t number, uint32_t arg0, uint32_t arg1, uint32_t arg2, uint32_t *argx);
    command pcallback_t peek_callback();
    command void pop_callback();
}
