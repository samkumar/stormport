
#ifndef SYSTICKHARDWARE_H
#define SYSTICKHARDWARE_H

//This comes from the cortex-m4 gug section 4.4.1, not atmel.

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t enable     : 1;
        uint32_t tickint    : 1;
        uint32_t clksource  : 1;
        uint32_t reserved0  : 13;
        uint32_t countflag  : 1;
        uint32_t reserved1  : 15;
    } __attribute__((__packed__)) bits;
} systick_csr_t;

typedef struct
{
    systick_csr_t   csr;
    uint32_t        rvr;
    uint32_t        cvr;
    //don't care about calibration
} systick_t;

systick_t volatile * const SYSTICK = (systick_t volatile *) 0xE000E010;

#endif