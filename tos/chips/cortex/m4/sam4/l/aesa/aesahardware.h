#ifndef AESAHARDWARE_H
#define AESAHARDWARE_H

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t enable     : 1;
        uint32_t dkeygen    : 1;
        uint32_t newmsg     : 1;
        uint32_t _reserved0 : 5;
        uint32_t swrst      : 1;
        uint32_t _reserved1 : 23;
    } __attribute__((__packed__)) bits;
} aesa_ctrl_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t encrypt    : 1;
        uint32_t _reserved0 : 2;
        uint32_t dma        : 1;
        uint32_t opmode     : 3;
        uint32_t _reserved1 : 1;
        uint32_t cfbs       : 3;
        uint32_t _reserved2 : 5;
        uint32_t ctype      : 4;
        uint32_t _reserved3 : 12;
    } __attribute__((__packed__)) bits;
} aesa_mode_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t idataw     : 2;
        uint32_t _reserved0 : 2;
        uint32_t odataw     : 2;
        uint32_t _reserved1 : 26;
    } __attribute__((__packed__)) bits;
} aesa_databufptr_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t odatardy   : 1;
        uint32_t _reserved0 : 15;
        uint32_t ibufrdy    : 1;
        uint32_t _reserved1 : 15;
    } __attribute__((__packed__)) bits;
} aesa_sr_ixr_t;

typedef struct
{
    aesa_ctrl_t         ctrl;
    aesa_mode_t         mode;
    aesa_databufptr_t   databufptr;
    aesa_sr_ixr_t       sr;

    aesa_sr_ixr_t       ier;
    aesa_sr_ixr_t       idr;
    aesa_sr_ixr_t       imr;
    uint32_t            _reserved0;

    uint32_t [8]        key;
    uint32_t [4]        iv;

    uint32_t            idata;
    uint32_t [3]        _reserved1;

    uint32_t            odata;
    uint32_t [3]        _reserved2;

    uint32_t            drngseed;
} aesa_t;

aesa_t volatile * const AESA = (aesa_t volatile *) 0x400B0000;

#endif