/*
 * Copyright (c) 2011 Lulea University of Technology
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the copyright holders nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/**
 * Storm specific wiring of the HplRF230C configuration.
 *
 * @author Michael Andersen
 * @author Henrik Makitaavola <henrik.makitaavola@gmail.com>
 */
 
#include <RadioConfig.h>

configuration HplRF230C
{
  provides
  {
    interface GeneralIO as SELN;
    interface Resource as SpiResource;
    interface FastSpiByte;

    interface GeneralIO as SLP_TR;
    interface GeneralIO as RSTN;

    interface GpioCapture as IRQ;
    interface Alarm<TRadio, uint32_t> as Alarm;
    interface LocalTime<TRadio> as LocalTimeRadio;
  }
}
implementation
{
  components HplRF230P;
  IRQ = HplRF230P.IRQ;

  components HplSam4lIOC as IOs;
  components new Sam4lSPI3C();
  SpiResource = Sam4lSPI3C;
  FastSpiByte = Sam4lSPI3C;

  HplRF230P.PortIRQ -> IOs.PA20;

  SLP_TR = IOs.PC14;
  RSTN = IOs.PC15;
  SELN = IOs.PC01;

  HplRF230P.GIRQ -> IOs.PA20IRQ;

  components new Alarm32khzC();
  HplRF230P.Alarm -> Alarm32khzC;
  Alarm = Alarm32khzC;

  components PlatformP;
  PlatformP.RadioInit -> HplRF230P.PlatformInit;
    
  components HalSam4lASTC;
  LocalTimeRadio = HalSam4lASTC.LocalTime;
}
