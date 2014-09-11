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
 * @author Gabe Fierro
 */

#ifndef PEVCHARDWARE_H
#define PEVCHARDWARE_H

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t evmx       : 6;
        uint32_t reserved0  : 2;
        uint32_t smx        : 1;
        uint32_t reserved1  : 23;
    } __attribute__((__packed__)) bits;
} pevc_chmx_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t en         : 1;
        uint32_t reserved0  : 15;
        uint32_t igfr       : 1;
        uint32_t igff       : 1;
        uint32_t igfon      : 1;
        uint32_t reserved1  : 13;
    } __attribute__((__packed__)) bits;
} pevc_evs_t;

typedef struct
{
    uint32_t        chsr;
    uint32_t        cher;
    uint32_t        chdr;
    uint32_t        reserved0;
    uint32_t        sev;
    uint32_t        busy;
    uint32_t        reserved1[2];
    //0x20
    uint32_t        trier;
    uint32_t        tridr;
    uint32_t        trimr;
    uint32_t        reserved2;
    uint32_t        trsr;
    uint32_t        trscr;
    uint32_t        reserved3[2];
    //0x40
    uint32_t        ovier;
    uint32_t        ovidr;
    uint32_t        ovimr;
    uint32_t        reserved4;
    uint32_t        ovsr;
    uint32_t        ovscr;
    uint32_t        reserved5[42];
    //0x100
    pevc_chmx_t     chmx[32];
    uint32_t        reserved6[32];
    //0x200
    pevc_evs0_t     evs[64];
    //0x300
    uint32_t        igfdr;
    //leave out parameter version
} pevc_t;