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

/**
 * Sam4l specific PM registers
 * @author Michael Andersen <m.andersen@cs.berkeley.edu>
 */

#ifndef SAM4LPMHARDWARE_H
#define SAM4LPMHARDWARE_H

#define PM_UNLOCK_KEY 0xAA000000

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t mcsel : 3;
        uint32_t reserved0 : 29;
    } __attribute__((__packed__)) bits;
} pm_mcctrl_t;

enum {
    MCSEL_RCSYS,
    MCSCEL_OSC0,
    MCSEL_PLL,
    MCSEL_DFLL,
    MCSEL_RC80M,
    MCSEL_RCFAST,
    MCSEL_RC1M
};

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t cpusel     : 3;
        uint32_t reserved0  : 4;
        uint32_t cpudiv     : 1;
        uint32_t reserved1  : 24;
    } __attribute__((__packed__)) bits;
} pm_cpusel_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t pbsel      : 3;
        uint32_t reserved0  : 4;
        uint32_t pbdiv      : 1;
        uint32_t reserved1  : 24;
    } __attribute__((__packed__)) bits;
} pm_pbxsel_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t ocd        : 1;
        uint32_t reserved0  : 31;
    } __attribute__((__packed__)) bits;
} pm_cpumask_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t pdca            : 1;
        uint32_t flashcalw       : 1;
        uint32_t flashcalw_sram  : 1;
        uint32_t usbc            : 1;
        uint32_t crccu           : 1;
        uint32_t apba            : 1;
        uint32_t apbb            : 1;
        uint32_t apbc            : 1;
        uint32_t apbd            : 1;
        uint32_t aesa            : 1;
        uint32_t reserved0       : 22;
    } __attribute__((__packed__)) bits;
} pm_hsbmask_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t iisc        : 1;
        uint32_t spi         : 1;
        uint32_t tc0         : 1;
        uint32_t tc1         : 1;
        uint32_t twim0       : 1;
        uint32_t twis0       : 1;
        uint32_t twim1       : 1;
        uint32_t twis1       : 1;
        uint32_t usart0      : 1;
        uint32_t usart1      : 1;
        uint32_t usart2      : 1;
        uint32_t usart3      : 1;
        uint32_t adcife      : 1;
        uint32_t dacc        : 1;
        uint32_t acifc       : 1;
        uint32_t gloc        : 1;
        uint32_t abdacb      : 1;
        uint32_t trng        : 1;
        uint32_t parc        : 1;
        uint32_t catb        : 1;
        uint32_t reserved0   : 1;
        uint32_t twim2       : 1;
        uint32_t twim3       : 1;
        uint32_t lcdca       : 1;
        uint32_t reserved1   : 8;
    } __attribute__((__packed__)) bits;
} pm_pbamask_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t flashcalw  : 1;
        uint32_t hramc1     : 1;
        uint32_t hmatrix    : 1;
        uint32_t pdca       : 1;
        uint32_t crccu      : 1;
        uint32_t usbc       : 1;
        uint32_t pevc       : 1;
        uint32_t reserved0  : 25;
    } __attribute__((__packed__)) bits;
} pm_pbbmask_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t pm         : 1;
        uint32_t chipid     : 1;
        uint32_t scif       : 1;
        uint32_t freqm      : 1;
        uint32_t gpio       : 1;
        uint32_t reserved0  : 27;
    } __attribute__((__packed__)) bits;
} pm_pbcmask_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t bpm        : 1;
        uint32_t bscif      : 1;
        uint32_t ast        : 1;
        uint32_t wdt        : 1;
        uint32_t eic        : 1;
        uint32_t picouart   : 1;
        uint32_t reserved0  : 26;
    } __attribute__((__packed__)) bits;
} pm_pbdmask_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t mask       : 7;
        uint32_t reserved0  : 25;
    } __attribute__((__packed__)) bits;
} pm_pbadivmask_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t cfd       : 1;
        uint32_t reserved0 : 4;
        uint32_t ckrdy     : 1;
        uint32_t reserved1 : 2;
        uint32_t wake      : 1;
        uint32_t reserved2 : 22;
        uint32_t ae        : 1;
    } __attribute__((__packed__)) bits;
} pm_interrupt_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t rstpun         : 1;
        uint32_t catbrcmask     : 1;
        uint32_t acifcrcmask    : 1;
        uint32_t astrcmask      : 1;
        uint32_t twisorcmask    : 1;
        uint32_t twis1rcmask    : 1;
        uint32_t pevcrcmask     : 1;
        uint32_t adcifercmask   : 1;
        uint32_t vregrcmask     : 1;
        uint32_t fwbgref        : 1;
        uint32_t fwbod18        : 1;
        uint32_t reserved1      : 21;
    } __attribute__((__packed__)) bits;
} pm_ppcr_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t por        : 1;
        uint32_t bod        : 1;
        uint32_t ext        : 1;
        uint32_t wdt        : 1;
        uint32_t reserved0  : 2;
        uint32_t bkup       : 1;
        uint32_t reserved1  : 1;
        uint32_t ocdrst     : 1;
        uint32_t reserved2  : 1;
        uint32_t por33      : 1;
        uint32_t reserved3  : 2;
        uint32_t bod33      : 1;
        uint32_t reserved4  : 13;
    } __attribute__((__packed__)) bits;
} pm_rcause_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t twis0      : 1;
        uint32_t twis1      : 1;
        uint32_t usbc       : 1;
        uint32_t psok       : 1;
        uint32_t bod18irq   : 1;
        uint32_t bod33irq   : 1;
        uint32_t lcdca      : 1;
        uint32_t reserved0  : 9;
        uint32_t eic        : 1;
        uint32_t ast        : 1;
        uint32_t reserved1  : 14;
    } __attribute__((__packed__)) bits;
} pm_wcause_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t osc        : 1;
        uint32_t reserved0  : 7;
        uint32_t pll        : 1;
        uint32_t reserved1  : 7;
        uint32_t fastrcosc  : 5;
        uint32_t reserved2  : 3;
        uint32_t dfll       : 1;
        uint32_t reserved3  : 7;
    } __attribute__((__packed__)) bits;
} pm_fastsleep_t;

typedef struct
{
    pm_mcctrl_t      mcctrl;
    pm_cpusel_t      cpusel;
    uint32_t         reserved0[1];
    pm_pbxsel_t      pbasel;
    pm_pbxsel_t      pbbsel;
    pm_pbxsel_t      pbcsel;
    pm_pbxsel_t      pbdsel;
    uint32_t         reserved1[1];
    //0x020
    pm_cpumask_t     cpumask;
    pm_hsbmask_t     hsbmask;
    pm_pbamask_t     pbamask;
    pm_pbbmask_t     pbbmask;
    pm_pbcmask_t     pbcmask;
    pm_pbdmask_t     pbdmask;
    uint32_t         reserved2[2];
    //0x040
    pm_pbadivmask_t  pbadivmask;
    uint32_t         reserved3[4];
    uint32_t         cfdctrl;
    uint32_t         unlock;
    uint32_t         reserved4[1];
    //0x60
    uint32_t         reserved5[24];
    //0xC0
    pm_interrupt_t   ier;
    pm_interrupt_t   idr;
    pm_interrupt_t   imr;
    pm_interrupt_t   isr;
    pm_interrupt_t   icr;
    pm_interrupt_t   sr;
    uint32_t         reserved6[2];
    //0xe0
    uint32_t         reserved7[32];
    //0x160
    pm_ppcr_t        ppcr;
    uint32_t         reserved8[7];
    //0x180
    pm_rcause_t      rcause;
    pm_wcause_t      wcause;
    uint32_t         awen;
    uint32_t         protctrl;
    uint32_t         reserved9[1];
    pm_fastsleep_t   fastsleep;
    uint32_t         reserved10[2];
    //0x200
    //We leave out version and config
} pm_t;

pm_t volatile * const PM = (pm_t volatile *) 0x400E0000;

//XTAG TODO the rest of the registers
/*
    CFDCTRL
    AWEN
    CONFIG
    VERSION
*/

#endif //SAM4LPMHARDWARE_H


