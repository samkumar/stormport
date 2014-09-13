/**
 * Copyright (c) 2014, The Regents of the University of California.
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
 * - Neither the name of the copyright holders nor the names of its
 *   contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
 * AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 * WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

/**
 * This is a low-level clock component controlling the different clock
 * systems.
 *
 * @author Michael Andersen <m.andersen@cs.berkeley.edu>
 */

#include <systickhardware.h>

module HplSam4lClockP
{
    provides
    {
        interface HplSam4Clock;
        interface Init;
    }
}

implementation
{

    command error_t Init.init()
    {
        SYSTICK->csr.bits.clksource = 1;
        SYSTICK->csr.bits.tickint = 0;
        SYSTICK->rvr = 0xFFFFFF;
        SYSTICK->csr.bits.enable = 1;
        return SUCCESS;
    }

    async command uint32_t HplSam4Clock.getSysTicks()
    {
        return SYSTICK->cvr;
    }

     /**
     * Select a 48Mhz clock from the PLL
     */
    async command error_t HplSam4Clock.slckPLL_48M()
    {

    }

    /**
     * Select the internal RC oscillator as slow clock source.
     */
    async command error_t HplSam4Clock.slckRCFAST_12M()
    {

    }

    /**
     * Returns the main clock speed in kHz.
     */
    async command uint32_t HplSam4Clock.getMainClockSpeed()
    {
        return 48000;
    }

    async command uint32_t HplSam4Clock.getSysTicksWrapVal()
    {
        return 0xFFFFFF;
    }
}
