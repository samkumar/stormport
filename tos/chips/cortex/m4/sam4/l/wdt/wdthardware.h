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
 * - Neither the name of the copyright holder nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE
 * COPYRIGHT HOLDER OR ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef WDTHARDWARE_H
#define WDTHARDWARE_H

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t en         :1;
        uint32_t dar        :1;
        uint32_t mode       :1;
        uint32_t sfv        :1;
        uint32_t im         :1;
        uint32_t reserved0  :2;
        uint32_t fcd        :1;
        uint32_t psel       :5;
        uint32_t reserved1  :3;
        uint32_t cen        :1;
        uint32_t cssel      :1;
        uint32_t tban       :5;
        uint32_t reserved2  :1;
        uint32_t key        :8;
    } __attribute__((__packed__)) bits;
} wdt_ctrl_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t clr        :1;
        uint32_t reserved0  :23;
        uint32_t key        :8;
    } __attribute__((__packed__)) bits;
} wdt_clr_t;

wdt_ctrl_t volatile * const WDT_CTRL = (wdt_ctrl_t volatile *) 0x400F0C00;
wdt_clr_t volatile * const WDT_CLEAR = (wdt_clr_t volatile *) 0x400F0C04;

#define WDT_KEY_1  0x55
#define WDT_KEY_2  0xAA
#endif 


