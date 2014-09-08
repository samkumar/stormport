/**
 * Copyright (c) 2014 The Regents of the University of California.
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
 * @author Michael Andersen <m.andersen@cs.berkeley.edu>
 */

#if 0
#include "sam3spmchardware.h"
#include "sam3ssupchardware.h"
#include "sam3eefchardware.h"
#include "sam4wdtchardware.h"
#include "sam3matrixhardware.h"
#endif

module MoteClockP
{
    provides 
    {
        interface Init;
    }
    uses
    {
        interface HplSam4Clock;
    }
}

implementation
{

    command error_t Init.init(){
    /*
        wdtc_mr_t mr = WDTC->mr;
        eefc_fmr_t fmr = EEFC0->fmr;

        // Set 2 WS for Embedded Flash Access
        fmr.bits.fws = 3;
        EEFC0->fmr = fmr;

        // Disable Watchdog
        mr.bits.wddis = 1;
        WDTC->mr = mr;

        // Select external slow clock
        //call HplSam3Clock.slckExternalOsc();
        call HplSam4Clock.slckRCOsc();

        // Initialize main oscillator
        call HplSam4Clock.mckInit48();
        //call HplSam4Clock.mckInit12RC();

        SetDefaultMaster(1);
*/
        return SUCCESS;

    }

    /**
     * informs us when the main clock changes
     */
    async event void HplSam4Clock.mainClockChanged() {}

}

