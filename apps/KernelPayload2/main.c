#include <stdlib.h>
#include <stdio.h>
#include "interface.h"

volatile uint32_t foobar;
void main()
{
    while(1)
    {
        foobar = 1;
        //_write(10, (uint8_t*) 20, 30);
        printf("Hello world\n");
        foobar = 2;
    }
}

