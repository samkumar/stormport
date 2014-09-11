/*
 * Copyright (c) 2014, Regents of the University of California
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * - Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the
 * distribution.
 * - Neither the name of copyright holder nor the names of
 * its contributors may be used to endorse or promote products derived
 * from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
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

#ifndef SPIHARDWARE_H //check
#define SPIHARDWARE_H

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t spien      : 1;
        uint32_t spidis     : 1;
        uint32_t reserved0  : 5;
        uint32_t swrst      : 1;
        uint32_t flushfifo  : 1;
        uint32_t reserved1  : 15;
        uint32_t lastxfer   : 1;
        uint32_t reserved2  : 7;
    } __attribute__((__packed__)) bits;
} spi_cr_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t mstr       : 1;
        uint32_t ps         : 1;
        uint32_t pcsdec     : 1;
        uint32_t reserved0  : 1;
        uint32_t modfdis    : 1;
        uint32_t reserved1  : 1;
        uint32_t rxfifoen   : 1;
        uint32_t llb        : 1;
        uint32_t reserved2  : 8;
        uint32_t pcs        : 4;
        uint32_t reserved3  : 4;
        uint32_t dlybcs     : 8;
    } __attribute__((__packed__)) bits;
} spi_mr_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t td         : 16;
        uint32_t pcs        : 4;
        uint32_t reserved0  : 4;
        uint32_t lastxfer   : 1;
        uint32_t reserved1  : 7;
    } __attribute__((__packed__)) bits;
} spi_tdr_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t rdrf       : 1;
        uint32_t tdre       : 1;
        uint32_t modf       : 1;
        uint32_t ovres      : 1;
        uint32_t reserved0  : 4;
        uint32_t nssr       : 1;
        uint32_t txempty    : 1;
        uint32_t undes      : 1;
        uint32_t reserved1  : 5;
        uint32_t spiens     : 1;
        uint32_t reserved2  : 15;
    } __attribute__((__packed__)) bits;
} spi_sr_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t rdrf       : 1;
        uint32_t tdre       : 1;
        uint32_t modf       : 1;
        uint32_t ovres      : 1;
        uint32_t reserved0  : 4;
        uint32_t nssr       : 1;
        uint32_t txempty    : 1;
        uint32_t undes      : 1;
        uint32_t reserved1  : 21;
    } __attribute__((__packed__)) bits;
} spi_ier_write_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t cpol   : 1;
        uint32_t ncpha  : 1;
        uint32_t csnaat : 1;
        uint32_t csaat  : 1;
        uint32_t bits   : 4;
        uint32_t scbr   : 8;
        uint32_t dlybs  : 8;
        uint32_t dlybct : 8;
    } __attribute__((__packed__)) bits;
} spi_csrx_write_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t spiwpen    : 1;
        uint32_t reserved0  : 7;
        uint32_t spiwpkey   : 24;
    } __attribute__((__packed__)) bits;
} spi_wpcr_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t spiwpvs    : 3;
        uint32_t reserved0  : 5;
        uint32_t spiwpvsrc  : 8;
        uint32_t reserved1  : 16;
    } __attribute__((__packed__)) bits;
} spi_wpsr_t;


typedef struct
{
    spi_cr_t cr;
    spi_mr_t mr;
    uint32_t rdr;
    spi_tdr_t tdr;
    spi_sr_t sr;
    spi_ier_write_t ier;
    spi_ier_write_t idr;
    spi_ier_write_t imr;
    //0x20
    uint32_t reserved0[4];
    spi_csr0_write_t csr0;
    spi_csr0_write_t csr1;
    spi_csr0_write_t csr2;
    spi_csr0_write_t csr3;
    //0x40
    uint32_t reserved1[41];
    spi_wpcr_t wpcr;
    spi_wpsr_t wpsr
    //we leave out parameter and version
} spi_t;


spi_t volatile * const SPI = (spi_t volatile *) 0x40008000;
#endif // SPIHARDWARE_H