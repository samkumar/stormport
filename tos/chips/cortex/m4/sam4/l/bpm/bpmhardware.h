/*
 * Copyright (c) 2014, Regents of the University of California
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of copyright holder nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/**
 * @author Michael Andersen
 */

#ifndef BPMHARDWARE_H
#define BPMHARDWARE_H

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t psok       : 1;
        uint32_t reserved0  : 30;
        uint32_t ae         : 1;
    } __attribute__((__packed__)) bits;
} bpm_ixr_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t ps         : 2;
        uint32_t pscreq     : 1;
        uint32_t reserved0  : 5;
        uint32_t bkup       : 1;
        uint32_t ret        : 1;
        uint32_t reserved1  : 2;
        uint32_t sleep      : 2;
        uint32_t reserved2  : 2;
        uint32_t clk32s     : 1;
        uint32_t reserved3  : 7;
        uint32_t fastwkup   : 1;
        uint32_t reserved4  : 7;
    } __attribute__((__packed__)) bits;
} bpm_pmcon_t;

enum
{
    FASTWKUP_NORMAL,
    FASTWKUP_FAST
};

enum
{
    CK32S_OSCK32K,
    CK32S_RC32K
};

enum
{
    SLEEP_CPU_STOP,                     //The CPU clock is stopped
    SLEEP_CPU_AHB_STOP,                 //CPU and AHB are stopped
    SLEEP_CPU_AHB_PB_GCLK_STOP,         //The CPU, AHB, PB and GCLK clocks are stopped. Clock sources
                                        //(OSC, Fast RC Oscillators, PLL, DFLL) are still running.
    SLEEP_CPU_AHB_PB_GCLK_OSC_XLL_STOP  //The CPU, AHB, PB, GCLK clocks and clock sources (OSC, RCFast, PLL, DFLL)
                                        //are stopped. RCSYS is still running. RC32K or OSC32K are still running
                                        //if enabled.
};

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t eic        : 1;
        uint32_t ast        : 1;
        uint32_t wdt        : 1;
        uint32_t bod33      : 1;
        uint32_t bod18      : 1;
        uint32_t picouart   : 1;
        uint32_t reserved0  : 26;
    } __attribute__((__packed__)) bits;
} bpm_bkupwx_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t pb01      : 1;
        uint32_t pa06      : 1;
        uint32_t pa04      : 1;
        uint32_t pa05      : 1;
        uint32_t pa07      : 1;
        uint32_t pc03      : 1;
        uint32_t pc04      : 1;
        uint32_t pc05      : 1;
        uint32_t pc06      : 1;
        uint32_t reserved0 : 23;
    } __attribute__((__packed__)) bits;
} bpm_bkupmux_t;

typedef struct
{
    bpm_ixr_t       ier;
    bpm_ixr_t       idr;
    bpm_ixr_t       imr;
    bpm_ixr_t       isr;
    bpm_ixr_t       icr;
    bpm_ixr_t       sr;
    uint32_t        unlock;
    bpm_pmcon_t     pmcon;
    //0x20
    uint32_t        reserved0[2];
    bpm_bkupwx_t    bkupwcause;
    bpm_bkupwx_t    bkupwen;
    bpm_bkupmux_t   bkuppmux;
    uint32_t        ioret;
    //we leave out version
} bpm_t;

enum
{
    BPM_IER_OFFSET      = 0x0000,
    BPM_IDR_OFFSET      = 0x0004,
    BPM_ICR_OFFSET      = 0x0010,
    BPM_PMCON_OFFSET    = 0x001C,
    BPM_BKUPWEN_OFFSET  = 0x002C,
    BPM_BKUPPMUX_OFFSET = 0x0030,
    BPM_IORET_OFFSET    = 0x0034
};

enum
{
    BPM_UNLOCK_KEY      = 0xAA000000
};
bpm_t volatile * const BPM = (bpm_t volatile *) 0x400F0000;


#endif