#include <stdlib.h>
#include <stdio.h>
#include "interface.h"

char inarray [80];
void on_read(void* r, int32_t len)
{
    printf("on_read called len=%d, buf='%s', r=%08x\n", len, inarray, (uint32_t)r);
}
int main()
{
    int rv;
    printf("We booted\n");
    rv = k_read_async(0, inarray, 50, on_read, (void*)0x505152);
    while(1)
    {
        k_run_callback();
    }
}
