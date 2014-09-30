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

#ifndef ASTHARDWARE_H
#define ASTHARDWARE_H

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t en         : 1;
        uint32_t pclr       : 1;
        uint32_t cal        : 1;
        uint32_t reserved0  : 5;
        uint32_t ca0        : 1;
        uint32_t ca1        : 1;
        uint32_t reserved1  : 6;
        uint32_t psel       : 5;
        uint32_t reserved2  : 11;
    } __attribute__((__packed__)) bits;
} ast_cr_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t ovf        : 1;
        uint32_t reserved0  : 7;
        uint32_t alarm0     : 1;
        uint32_t reserved1  : 7;
        uint32_t per0       : 1;
        uint32_t reserved2  : 7;
        uint32_t busy       : 1;
        uint32_t ready      : 1;
        uint32_t reserved3  : 2;
        uint32_t clkbusy    : 1;
        uint32_t clkrdy     : 1;
        uint32_t reserved4  : 2;
    } __attribute__((__packed__)) bits;
} ast_sr_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t ovf        : 1;
        uint32_t reserved0  : 7;
        uint32_t alarm0     : 1;
        uint32_t reserved1  : 7;
        uint32_t per0       : 1;
        uint32_t reserved2  : 8;
        uint32_t ready      : 1;
        uint32_t reserved3  : 3;
        uint32_t clkrdy     : 1;
        uint32_t reserved4  : 2;
    } __attribute__((__packed__)) bits;
} ast_sr_write_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t ovf        : 1;
        uint32_t reserved0  : 7;
        uint32_t alarm0     : 1;
        uint32_t reserved1  : 7;
        uint32_t per0       : 1;
        uint32_t reserved2  : 15;
    } __attribute__((__packed__)) bits;
} ast_wer_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t cen        : 1;
        uint32_t reserved0  : 7;
        uint32_t cssel      : 3;
        uint32_t reserved1  : 21;
    } __attribute__((__packed__)) bits;
} ast_clock_t;

enum {
    CSSEL_RCSYS,
    CSSEL_OSC32,
    CSSEL_APB,
    CSSEL_GCLK2,
    CSSEL_CLK1K
};

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t exp        : 5;
        uint32_t add        : 1;
        uint32_t reserved0  : 2;
        uint32_t value      : 8;
        uint32_t reserved1  : 16;
    } __attribute__((__packed__)) bits;
} ast_dtr_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t ovf        : 1;
        uint32_t reserved0  : 7;
        uint32_t alarm0     : 1;
        uint32_t reserved1  : 7;
        uint32_t per0       : 1;
        uint32_t reserved2  : 15;
    } __attribute__((__packed__)) bits;
} ast_evx_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t sec        : 6;
        uint32_t min        : 6;
        uint32_t hour       : 5;
        uint32_t day        : 5;
        uint32_t month      : 4;
        uint32_t year       : 6;
    } __attribute__((__packed__)) bits;
} ast_calv_t;

typedef struct
{
    ast_cr_t        cr;
    uint32_t        cv;
    ast_sr_t        sr;
    ast_sr_write_t  scr;
    ast_sr_write_t  ier;
    ast_sr_write_t  idr;
    ast_sr_write_t  imr;
    ast_wer_t       wer;
    //0x20
    uint32_t        ar0;
    uint32_t        ar1;
    uint32_t        reserved0[2];
    uint32_t        pir0;
    uint32_t        pir1;
    uint32_t        reserved1[2];
    //0x40
    ast_clock_t     clock;
    ast_dtr_t       dtr;
    ast_evx_t       eve;
    ast_evx_t       evd;
    ast_evx_t       evm;
    ast_calv_t      calv;
    //we leave out parameter and version
} ast_t;

ast_t volatile * const AST = (ast_t volatile *) 0x400F0800;
#endif // ASTHARDWARE_H
