#include <stdlib.h>
#include <stdio.h>
#include "interface.h"

volatile uint32_t foobar;
void main()
{
    char inarray [80];
    while(1)
    {
        foobar = 1;
      //  foobar = _read(0, &inarray[0], 10);
       // inarray[foobar] = 0;
        //_write(10, (uint8_t*) 20, 30);
        fgets(inarray, 78, stdin);
        printf("got line '%s'", inarray);
        foobar = 2;
    }
}

