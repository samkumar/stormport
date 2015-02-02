#ifndef TWIMHARDWARE_H
#define TWIMHARDWARE_H

    enum {
        FLAG_DOSTART = 0x01,
        FLAG_DORSTART = 0x01,
        FLAG_ACKLAST = 0x02,
        FLAG_DOSTOP = 0x04
    };

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t men       : 1;
        uint32_t mdis      : 1;
        uint32_t reserved0 : 2;
        uint32_t smen      : 1;
        uint32_t smdis      : 1;
        uint32_t reserved1 : 1;
        uint32_t swrst     : 1;
        uint32_t stop      : 1;
        uint32_t reserved2 : 23;
    } __attribute__((__packed__)) bits;
} twim_cr_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t low       : 8;
        uint32_t high      : 8;
        uint32_t stasto    : 8;
        uint32_t data      : 4;
        uint32_t exp       : 3;
        uint32_t reserved0 : 1;
    } __attribute__((__packed__)) bits;
} twim_xcwgr_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t tlows      : 8;
        uint32_t tlowm      : 8;
        uint32_t thmax      : 8;
        uint32_t reserved0  : 4;
        uint32_t exp        : 4;
    } __attribute__((__packed__)) bits;
} twim_smbtr_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t read      : 1;
        uint32_t sadr      : 10;
        uint32_t tenbit    : 1;
        uint32_t repsame   : 1;
        uint32_t start     : 1;
        uint32_t stop      : 1;
        uint32_t valid     : 1;
        uint32_t nbytes    : 8;
        uint32_t pecen     : 1;
        uint32_t acklast   : 1;
        uint32_t hs        : 1;
        uint32_t reserved0 : 1;
        uint32_t hsmcode   : 3;
        uint32_t reserved1 : 1;
    } __attribute__((__packed__)) bits;
} twim_cmdr_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t rxrdy      : 1;
        uint32_t txrdy      : 1;
        uint32_t crdy       : 1;
        uint32_t ccomp      : 1;
        uint32_t idle       : 1;
        uint32_t busfree    : 1;
        uint32_t reserved0  : 2;
        uint32_t anak       : 1;
        uint32_t dnak       : 1;
        uint32_t arblst     : 1;
        uint32_t reserved1  : 1;
        uint32_t tout       : 1;
        uint32_t pecerr     : 1;
        uint32_t stop       : 1;
        uint32_t reserved2  : 1;
        uint32_t menb       : 1;
        uint32_t hsmcack    : 1;
        uint32_t reserved3  : 14;
    } __attribute__((__packed__)) bits;
} twim_sr_t;


#if 0
#define TWIMPIN(PORT, NUMBER, PERIPHERAL) (((PORT) << 16) | ((NUMBER) << 8) | (PERIPHERAL))
typedef enum {
  TWIM2_DAT_PA21 = //E
  TWIM2_DAT_PA22 = //E
  TWIM0_DAT_PA23 = //A
  TWIM0_CLK_PA24 = //A
  TWIM1_DAT_PB00 = //A
  TWIM1_CLK_PB01 = //A
  TWIM3_DAT_PB14 = //C
  TWIM3_CLK_PB15 = //C
#endif

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t rxrdy      : 1;
        uint32_t txrdy      : 1;
        uint32_t crdy       : 1;
        uint32_t ccomp      : 1;
        uint32_t idle       : 1;
        uint32_t busfree    : 1;
        uint32_t reserved0  : 2;
        uint32_t anak       : 1;
        uint32_t dnak       : 1;
        uint32_t arblst     : 1;
        uint32_t reserved1  : 1;
        uint32_t tout       : 1;
        uint32_t pecerr     : 1;
        uint32_t stop       : 1;
        uint32_t reserved2  : 2;
        uint32_t hsmcack    : 1;
        uint32_t reserved3  : 14;
    } __attribute__((__packed__)) bits;
} twim_ixr_t;


typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t reserved0  : 3;
        uint32_t ccomp      : 1;
        uint32_t reserved1  : 4;
        uint32_t anak       : 1;
        uint32_t dnak       : 1;
        uint32_t arblst     : 1;
        uint32_t reserved2  : 1;
        uint32_t tout       : 1;
        uint32_t pecerr     : 1;
        uint32_t stop       : 1;
        uint32_t reserved3  : 2;
        uint32_t hsmcack    : 1;
        uint32_t reserved4  : 14;
    } __attribute__((__packed__)) bits;
} twim_scr_t;


typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t dadrivel   : 3;
        uint32_t reserved0  : 5;
        uint32_t daslew     : 2;
        uint32_t reserved1  : 6;
        uint32_t cldrivel   : 3;
        uint32_t reserved2  : 5;
        uint32_t clslew     : 2;
        uint32_t reserved3  : 2;
        uint32_t filter     : 2;
        uint32_t reserved4  : 2;
    } __attribute__((__packed__)) bits;
} twim_srr_t;

typedef struct
{
    twim_cr_t       cr;
    twim_xcwgr_t    cwgr;
    twim_smbtr_t    smbtr;
    twim_cmdr_t     cmdr;
    //0x10
    twim_cmdr_t     ncmdr;
    uint32_t        rhr;
    uint32_t        thr;
    twim_sr_t       sr;
    //0x20
    twim_ixr_t      ier;
    twim_ixr_t      idr;
    twim_ixr_t      imr;
    twim_scr_t      scr;
    //0x30
    uint32_t        pr;
    uint32_t        vr;
    twim_xcwgr_t    hscwgr;
    twim_srr_t      srr;
    //0x40
    twim_srr_t      hssrr;
} __attribute__((__packed__)) twim_t;

twim_t volatile * const TWIM0 = (twim_t volatile *) (0x40018000);
twim_t volatile * const TWIM1 = (twim_t volatile *) (0x4001C000);
twim_t volatile * const TWIM2 = (twim_t volatile *) (0x40078000);
twim_t volatile * const TWIM3 = (twim_t volatile *) (0x4007C000);

twim_t volatile * TWIMx [] = {
    (twim_t volatile *) (0x40018000),
    (twim_t volatile *) (0x4001C000),
    (twim_t volatile *) (0x40078000),
    (twim_t volatile *) (0x4007C000)
};

#endif