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

 //Not all the registers are cleanly mapped here yet, as many of them are
 //not being used.
#ifndef BSCIFHARDWARE_H
#define BSCIFHARDWARE_H
typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t osc32rdy       : 1;
        uint32_t rc32krdy       : 1;
        uint32_t rc32klock      : 1;
        uint32_t rc32krefe      : 1;
        uint32_t rc32sat        : 1;
        uint32_t rc32det        : 1;
        uint32_t bod18det       : 1;
        uint32_t bod33synrdy    : 1;
        uint32_t bod18synrdy    : 1;
        uint32_t sswrdy         : 1;
        uint32_t vregok         : 1;
        uint32_t rc1mrdy        : 1;
        uint32_t lpbgrdy        : 1;
        uint32_t reserved0      : 19;
    } __attribute__((__packed__)) bits;
} bscif_pclksr_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t en         : 1;
        uint32_t tcen       : 1;
        uint32_t en32k      : 1;
        uint32_t en1k       : 1;
        uint32_t mode       : 1;
        uint32_t ref        : 1;
        uint32_t reserved0  : 1;
        uint32_t fcd        : 1;
        uint32_t reserved1  : 24;
    } __attribute__((__packed__)) bits;
} bscif_rc32kcr_t;

typedef struct
{
    uint32_t            ier;
    uint32_t            idr;
    uint32_t            imr;
    uint32_t            isr;
    uint32_t            icr;
    bscif_pclksr_t      pclksr;
    uint32_t            unlock;
    uint32_t            cscr;
    //0x20
    uint32_t            oscctrl32;
    bscif_rc32kcr_t     rc32kcr;
    uint32_t            rc32ktune;
    uint32_t            bod33ctrl;
    uint32_t            bod33level;
    uint32_t            bod33sampling;
    uint32_t            bod18ctrl;
    uint32_t            bod18level;
    //0x40
    uint32_t            bod18sampling;
    uint32_t            vregcr;
    uint32_t            reserved0[4];
    uint32_t            rc1mcr;
    uint32_t            reserved1[1];
    //0x60
    uint32_t            bgctrl;
    uint32_t            bgsr;
    uint32_t            reserved2[4];
    uint32_t            br[4];
} bscif_t;

enum {
    BSCIF_UNLOCK_KEY = 0xAA000000
};

enum {
    BSCIF_RC32KCR_OFFSET = 0x24
};

bscif_t volatile * const BSCIF = (bscif_t volatile *) 0x400F0400;

#endif