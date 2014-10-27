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

#ifndef PDCAHARDWARE_H
#define PDCAHARDWARE_H

enum {MAX_DMA_CHANNELS = 16};

#define DMA_CHANNEL_UQ "Sam4lDMAChannels"

enum
{
    // Peripheral ID definitions for the SAM4L
    SAM4L_PID_USART0_RX    = ( 0),
    SAM4L_PID_USART1_RX    = ( 1),
    SAM4L_PID_USART2_RX    = ( 2),
    SAM4L_PID_USART3_RX    = ( 3),
    SAM4L_PID_SPI_RX       = ( 4),
    SAM4L_PID_TWIM0_RX     = ( 5),
    SAM4L_PID_TWIM1_RX     = ( 6),
    SAM4L_PID_TWIM2_RX     = ( 7),
    SAM4L_PID_TWIM3_RX     = ( 8),
    SAM4L_PID_TWIS0_RX     = ( 9),
    SAM4L_PID_TWIS1_RX     = (10),
    SAM4L_PID_ADCIFE_RX    = (11),
    SAM4L_PID_CATB_RX      = (12),
    //There is no PID 13,
    SAM4L_PID_IISC_RX_CH0  = (14),
    SAM4L_PID_IISC_RX_CH1  = (15),
    SAM4L_PID_PARC_RX      = (16),
    SAM4L_PID_AESA_RX      = (17),
    SAM4L_PID_USART0_TX    = (18),
    SAM4L_PID_USART1_TX    = (19),
    SAM4L_PID_USART2_TX    = (20),
    SAM4L_PID_USART3_TX    = (21),
    SAM4L_PID_SPI_TX       = (22),
    SAM4L_PID_TWIM0_TX     = (23),
    SAM4L_PID_TWIM1_TX     = (24),
    SAM4L_PID_TWIM2_TX     = (25),
    SAM4L_PID_TWIM3_TX     = (26),
    SAM4L_PID_TWIS0_TX     = (27),
    SAM4L_PID_TWIS1_TX     = (28),
    SAM4L_PID_ADCIFE       = (29),
    SAM4L_PID_CATB         = (30),
    SAM4L_PID_ABDACB_SDR0  = (31),
    SAM4L_PID_ABDACB_SDR1  = (32),
    SAM4L_PID_IISC_TX_CH0  = (33),
    SAM4L_PID_IISC_TX_CH1  = (34),
    SAM4L_PID_DACC_TX      = (35),
    SAM4L_PID_AESA_TX      = (36),
    SAM4L_PID_LCDCA_ACMDR  = (37),
    SAM4L_PID_LCDCA_ABMDR  = (38)
};

enum
{
    PDCA_SIZE_BYTE,
    PDCA_SIZE_HALFWORD,
    PDCA_SIZE_WORD
};

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t ten        : 1;
        uint32_t tdis       : 1;
        uint32_t reserved0  : 6;
        uint32_t eclr       : 1;
        uint32_t reserved1  : 23;
    } __attribute__((__packed__)) bits;
} pdca_cr_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t size        : 2;
        uint32_t etrig       : 1;
        uint32_t ring        : 1;
        uint32_t reserved1   : 28;
    } __attribute__((__packed__)) bits;
} pdca_mr_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t rcz         : 1;
        uint32_t trc         : 1;
        uint32_t terr        : 1;
        uint32_t reserved1   : 29;
    } __attribute__((__packed__)) bits;
} pdca_ixr_t;

typedef struct
{
    uint32_t        mar;
    uint32_t        psr;
    uint32_t        tcr;
    uint32_t        marr;
    uint32_t        tcrr;
    pdca_cr_t       cr;
    pdca_mr_t       mr;
    uint32_t        sr;
    ///0x20
    pdca_ixr_t      ier;
    pdca_ixr_t      idr;
    pdca_ixr_t      imr;
    pdca_ixr_t      isr;
    uint32_t        reserved[4];
    //leaving out version
} __attribute__((__packed__)) pdca_channel_t;

typedef struct
{
    pdca_channel_t ch [MAX_DMA_CHANNELS];
} __attribute__((__packed__)) pdca_t;

pdca_t volatile * const PDCA = (pdca_t volatile *) 0x400A2000;

#endif // PDCAHARDWARE_H
