#include <stdlib.h>
#include <stdio.h>
#include "interface.h"

void timeout(void* r)
{
    printf("timeout r=%08x\n", (uint32_t)r);
}

int32_t __attribute__((naked)) k_syscall_ex_ri32_u32_u32_cb_vptr(uint32_t id, uint32_t arg0, uint32_t arg1, cb_t cb, void *r)
{
    __syscall_body(ABI_ID_SYSCALL_EX);
}
uint32_t __attribute__((naked)) k_syscall_ex_ru32(uint32_t id)
{
    __syscall_body(ABI_ID_SYSCALL_EX);
}
#define timer_set(ticks,periodic, callback, r) k_syscall_ex_ri32_u32_u32_cb_vptr(0x201, (ticks), (periodic), (callback),(r))
#define timer_getnow() k_syscall_ex_ru32(0x202)

int main()
{
    int rv;
    printf("We booted\n");
    rv = timer_set(1000000,1,timeout,(void*)0x505152);
    printf("RV was %d\n",rv);
    while(1)
    {
        uint32_t n = timer_getnow();
        printf("now: %d\n", n);
        k_run_callback();
    }
}
