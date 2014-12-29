#ifndef __TC_H__
#define __TC_H__

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t clken      : 1;
        uint32_t clkdis     : 1;
        uint32_t swtrg      : 1;
        uint32_t reserved0  : 29;
    } __attribute__((__packed__)) bits;
} tc_ccr_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t tcclks     : 3;
        uint32_t clki       : 1;
        uint32_t burst      : 2;
        uint32_t ldbstop    : 1;
        uint32_t ldbdis     : 1;
        uint32_t etrgedg    : 2;
        uint32_t abetrg     : 1;
        uint32_t reserved0  : 3;
        uint32_t cpctrg     : 1;
        uint32_t wave       : 1;
        uint32_t ldra       : 2;
        uint32_t ldrb       : 2;
        uint32_t reserved1  : 12;
    } __attribute__((__packed__)) bits;
} tc_cmr_capture_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t tcclks     : 3;
        uint32_t clki       : 1;
        uint32_t burst      : 2;
        uint32_t cpcstop    : 1;
        uint32_t cpcdis     : 1;
        uint32_t eevtedg    : 2;
        uint32_t eevt       : 2;
        uint32_t enetrg     : 1;
        uint32_t wavsel     : 2;
        uint32_t wave       : 1;
        uint32_t acpa       : 2;
        uint32_t acpc       : 2;
        uint32_t aeevt      : 2;
        uint32_t aswtrg     : 2;
        uint32_t bcpb       : 2;
        uint32_t bcpc       : 2;
        uint32_t beevt      : 2;
        uint32_t bswtrg     : 2;
    } __attribute__((__packed__)) bits;
} tc_cmr_wave_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t covfs      : 1;
        uint32_t lovrs      : 1;
        uint32_t cpas       : 1;
        uint32_t cpbs       : 1;
        uint32_t cpcs       : 1;
        uint32_t ldras      : 1;
        uint32_t ldrbs      : 1;
        uint32_t etrgs      : 1;
        uint32_t reserved0  : 8;
        uint32_t clksta     : 1;
        uint32_t mtioa      : 1;
        uint32_t mtiob      : 1;
        uint32_t reserved1  : 13;
    } __attribute__((__packed__)) bits;
} tc_sr_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t covfs      : 1;
        uint32_t lovrs      : 1;
        uint32_t cpas       : 1;
        uint32_t cpbs       : 1;
        uint32_t cpcs       : 1;
        uint32_t ldras      : 1;
        uint32_t ldrbs      : 1;
        uint32_t etrgs      : 1;
        uint32_t reserved0  : 24;
    } __attribute__((__packed__)) bits;
} tc_isr_t;

typedef struct
{
    tc_ccr_t    ccr0;
    union
    {
        tc_cmr_capture_t cap;
        tc_cmr_wave_t    wav;
    } cmr0;
    uint32_t smmr0;
    uint32_t reserved0;
    uint32_t cv0;
    uint32_t ra0;
    uint32_t rb0;
    uint32_t rc0;
    //0x20
    tc_sr_t     sr0;
    tc_isr_t    ier0;
    tc_isr_t    idr0;
    tc_isr_t    imr0;
    //other channels
} tc00_t;

tc00_t volatile * const TC00 = (tc00_t volatile *) 0x40010000;
#endif