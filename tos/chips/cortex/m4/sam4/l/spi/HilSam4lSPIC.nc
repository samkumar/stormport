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
 * Adapted from sam3 port
 * @author Michael Andersen
 * @author Thomas Schmid
 * @author Kevin Klues
 */

#include <spihardware.h>

configuration HilSam4lSpiC
{
    provides
    {
        interface Resource[uint8_t];
        interface SpiByte[uint8_t];
        interface FastSpiByte[uint8_t];
        interface HplSam4lSPIChannel[uint8_t];
        interface HplSam4lSPIControl;
    }
    uses {
        interface ResourceConfigure[uint8_t];
    }
}
implementation
{
    components RealMainP;
    RealMainP.PlatformInit -> HplSam4SPIP.Init;

    components new FcfsArbiterC(SAM4_SPI_BUS) as ArbiterC;
    Resource = ArbiterC;
    ArbiterC.ResourceConfigure -> ResourceConfigure;

    components new HplSam4lSPIChannelP(0) as ch0,
               new HplSam4lSPIChannelP(1) as ch1,
               new HplSam4lSPIChannelP(2) as ch2,
               new HplSam4lSPIChannelP(3) as ch3;

    HplSam4lSPIChannel[0] = ch0;
    HplSam4lSPIChannel[1] = ch1;
    HplSam4lSPIChannel[2] = ch2;
    HplSam4lSPIChannel[3] = ch3;

    components HplSam4lIOC;

    components new HplSam4lSPIP;
    HplSam4lSPIP.MOSI = HplSam4lIOC.HplPC05;
    HplSam4lSPIP.MISO = HplSam4lIOC.HplPC04;
    HplSam4lSPIP.CS0 = HplSam4lIOC.HplPC03;
    HplSam4lSPIP.CS1 = HplSam4lIOC.HplPC02;
    HplSam4lSPIP.CS2 = HplSam4lIOC.HplPC00;
    HplSam4lSPIP.CS3 = HplSam4lIOC.HplPC01;

    components new HalSam4lSPIChannelP() as halCH0,
               new HalSam4lSPIChannelP() as halCH1,
               new HalSam4lSPIChannelP() as halCH2,
               new HalSam4lSPIChannelP() as halCH3;

    halCH0 -> ch0;
    halCH1 -> ch1;
    halCH2 -> ch2;
    halCH3 -> ch3;
    
    SpiByte[0] -> halCH0;
    SpiByte[1] -> halCH1;
    SpiByte[2] -> halCH2;
    SpiByte[3] -> halCH3;

    FastSpiByte[0] -> halCH0;
    FastSpiByte[1] -> halCH1;
    FastSpiByte[2] -> halCH2;
    FastSpiByte[3] -> halCH3;

}