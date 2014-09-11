/**
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
 * This is the main configuration for the low-layer clock module.
 * @author Michael Andersen
 */

configuration HplSam4lClockC
{
    provides
    {
        interface HplSam4Clock;

        interface HplSam4PeripheralClockCntl as OCDCtl;
        interface HplSam4PeripheralClockCntl as PDCA_HSBCtl;
        interface HplSam4PeripheralClockCntl as FLASHCALW_HSBCtl;
        interface HplSam4PeripheralClockCntl as FLASHCALWSRAMCtl;
        interface HplSam4PeripheralClockCntl as USBC_HSBCtl;
        interface HplSam4PeripheralClockCntl as CRCCU_HSBCtl;
        interface HplSam4PeripheralClockCntl as APBACtl;
        interface HplSam4PeripheralClockCntl as APBBCtl;
        interface HplSam4PeripheralClockCntl as APBCCtl;
        interface HplSam4PeripheralClockCntl as APBDCtl;
        interface HplSam4PeripheralClockCntl as AESACtl;
        interface HplSam4PeripheralClockCntl as IISCCtl;
        interface HplSam4PeripheralClockCntl as SPICtl;
        interface HplSam4PeripheralClockCntl as TC0Ctl;
        interface HplSam4PeripheralClockCntl as TC1Ctl;
        interface HplSam4PeripheralClockCntl as TWIM0Ctl;
        interface HplSam4PeripheralClockCntl as TWIS0Ctl;
        interface HplSam4PeripheralClockCntl as TWIM1Ctl;
        interface HplSam4PeripheralClockCntl as TWIS1Ctl;
        interface HplSam4PeripheralClockCntl as USART0Ctl;
        interface HplSam4PeripheralClockCntl as USART1Ctl;
        interface HplSam4PeripheralClockCntl as USART2Ctl;
        interface HplSam4PeripheralClockCntl as USART3Ctl;
        interface HplSam4PeripheralClockCntl as ADCIFECtl;
        interface HplSam4PeripheralClockCntl as DACCCtl;
        interface HplSam4PeripheralClockCntl as ACIFCCtl;
        interface HplSam4PeripheralClockCntl as GLOCCtl;
        interface HplSam4PeripheralClockCntl as ABDACBCtl;
        interface HplSam4PeripheralClockCntl as TRNGCtl;
        interface HplSam4PeripheralClockCntl as PARCCtl;
        interface HplSam4PeripheralClockCntl as CATBCtl;
        interface HplSam4PeripheralClockCntl as TWIM2Ctl;
        interface HplSam4PeripheralClockCntl as TWIM3Ctl;
        interface HplSam4PeripheralClockCntl as LCDCACtl;
        interface HplSam4PeripheralClockCntl as FLASHCALW_PBBCtl;
        interface HplSam4PeripheralClockCntl as HRAMC1Ctl;
        interface HplSam4PeripheralClockCntl as HMATRIXCtl;
        interface HplSam4PeripheralClockCntl as PDCA_PBBCtl;
        interface HplSam4PeripheralClockCntl as CRCCU_PBBCtl;
        interface HplSam4PeripheralClockCntl as USBC_PBBCtl;
        interface HplSam4PeripheralClockCntl as PEVCCtl;
        interface HplSam4PeripheralClockCntl as PMCtl;
        interface HplSam4PeripheralClockCntl as CHIPIDCtl;
        interface HplSam4PeripheralClockCntl as SCIFCtl;
        interface HplSam4PeripheralClockCntl as FREQMCtl;
        interface HplSam4PeripheralClockCntl as GPIOCtl;
        interface HplSam4PeripheralClockCntl as BPMCtl;
        interface HplSam4PeripheralClockCntl as BSCIFCtl;
        interface HplSam4PeripheralClockCntl as ASTCtl;
        interface HplSam4PeripheralClockCntl as WDTCtl;
        interface HplSam4PeripheralClockCntl as EICCtl;
        interface HplSam4PeripheralClockCntl as PICOUARTCtl;
    }
}
implementation
{


    components HplSam4lClockP,
               new HplSam4PeripheralClockP(0x20,  0) as CPU_OCD,
               new HplSam4PeripheralClockP(0x24,  0) as HSB_PDCA,
               new HplSam4PeripheralClockP(0x24,  1) as HSB_FLASHCALW,
               new HplSam4PeripheralClockP(0x24,  2) as HSB_FLASHCALWSRAM,
               new HplSam4PeripheralClockP(0x24,  3) as HSB_USBC,
               new HplSam4PeripheralClockP(0x24,  4) as HSB_CRCCU,
               new HplSam4PeripheralClockP(0x24,  5) as HSB_APBA,
               new HplSam4PeripheralClockP(0x24,  6) as HSB_APBB,
               new HplSam4PeripheralClockP(0x24,  7) as HSB_APBC,
               new HplSam4PeripheralClockP(0x24,  8) as HSB_APBD,
               new HplSam4PeripheralClockP(0x24,  9) as HSB_AESA,
               new HplSam4PeripheralClockP(0x28,  0) as PBA_IISC,
               new HplSam4PeripheralClockP(0x28,  1) as PBA_SPI,
               new HplSam4PeripheralClockP(0x28,  2) as PBA_TC0,
               new HplSam4PeripheralClockP(0x28,  3) as PBA_TC1,
               new HplSam4PeripheralClockP(0x28,  4) as PBA_TWIM0,
               new HplSam4PeripheralClockP(0x28,  5) as PBA_TWIS0,
               new HplSam4PeripheralClockP(0x28,  6) as PBA_TWIM1,
               new HplSam4PeripheralClockP(0x28,  7) as PBA_TWIS1,
               new HplSam4PeripheralClockP(0x28,  8) as PBA_USART0,
               new HplSam4PeripheralClockP(0x28,  9) as PBA_USART1,
               new HplSam4PeripheralClockP(0x28, 10) as PBA_USART2,
               new HplSam4PeripheralClockP(0x28, 11) as PBA_USART3,
               new HplSam4PeripheralClockP(0x28, 12) as PBA_ADCIFE,
               new HplSam4PeripheralClockP(0x28, 13) as PBA_DACC,
               new HplSam4PeripheralClockP(0x28, 14) as PBA_ACIFC,
               new HplSam4PeripheralClockP(0x28, 15) as PBA_GLOC,
               new HplSam4PeripheralClockP(0x28, 16) as PBA_ABDACB,
               new HplSam4PeripheralClockP(0x28, 17) as PBA_TRNG,
               new HplSam4PeripheralClockP(0x28, 18) as PBA_PARC,
               new HplSam4PeripheralClockP(0x28, 19) as PBA_CATB,
               //no 20
               new HplSam4PeripheralClockP(0x28, 21) as PBA_TWIM2,
               new HplSam4PeripheralClockP(0x28, 22) as PBA_TWIM3,
               new HplSam4PeripheralClockP(0x28, 23) as PBA_LCDCA,
               new HplSam4PeripheralClockP(0x2C,  0) as PBB_FLASHCALW,
               new HplSam4PeripheralClockP(0x2C,  1) as PBB_HRAMC1,
               new HplSam4PeripheralClockP(0x2C,  2) as PBB_HMATRIX,
               new HplSam4PeripheralClockP(0x2C,  3) as PBB_PDCA,
               new HplSam4PeripheralClockP(0x2C,  4) as PBB_CRCCU,
               new HplSam4PeripheralClockP(0x2C,  5) as PBB_USBC,
               new HplSam4PeripheralClockP(0x2C,  6) as PBB_PEVC,
               new HplSam4PeripheralClockP(0x30,  0) as PBC_PM,
               new HplSam4PeripheralClockP(0x30,  1) as PBC_CHIPID,
               new HplSam4PeripheralClockP(0x30,  2) as PBC_SCIF,
               new HplSam4PeripheralClockP(0x30,  3) as PBC_FREQM,
               new HplSam4PeripheralClockP(0x30,  4) as PBC_GPIO,
               new HplSam4PeripheralClockP(0x34,  0) as PBC_BPM,
               new HplSam4PeripheralClockP(0x34,  1) as PBC_BSCIF,
               new HplSam4PeripheralClockP(0x34,  2) as PBC_AST,
               new HplSam4PeripheralClockP(0x34,  3) as PBC_WDT,
               new HplSam4PeripheralClockP(0x34,  4) as PBC_EIC,
               new HplSam4PeripheralClockP(0x34,  5) as PBC_PICOUART;



    HplSam4Clock = HplSam4lClockP;
    components MainC;

    HplSam4lClockP.Init <- MainC.SoftwareInit;

    OCDCtl = CPU_OCD.Cntl;
    PDCA_HSBCtl = HSB_PDCA.Cntl;
    FLASHCALW_HSBCtl = HSB_FLASHCALW.Cntl;
    FLASHCALWSRAMCtl = HSB_FLASHCALWSRAM.Cntl;
    USBC_HSBCtl = HSB_USBC.Cntl;
    CRCCU_HSBCtl = HSB_CRCCU.Cntl;
    APBACtl = HSB_APBA.Cntl;
    APBBCtl = HSB_APBB.Cntl;
    APBCCtl = HSB_APBC.Cntl;
    APBDCtl = HSB_APBD.Cntl;
    AESACtl = HSB_AESA.Cntl;
    IISCCtl = PBA_IISC.Cntl;
    SPICtl = PBA_SPI.Cntl;
    TC0Ctl = PBA_TC0.Cntl;
    TC1Ctl = PBA_TC1.Cntl;
    TWIM0Ctl = PBA_TWIM0.Cntl;
    TWIS0Ctl = PBA_TWIS0.Cntl;
    TWIM1Ctl = PBA_TWIM1.Cntl;
    TWIS1Ctl = PBA_TWIS1.Cntl;
    USART0Ctl = PBA_USART0.Cntl;
    USART1Ctl = PBA_USART1.Cntl;
    USART2Ctl = PBA_USART2.Cntl;
    USART3Ctl = PBA_USART3.Cntl;
    ADCIFECtl = PBA_ADCIFE.Cntl;
    DACCCtl = PBA_DACC.Cntl;
    ACIFCCtl = PBA_ACIFC.Cntl;
    GLOCCtl = PBA_GLOC.Cntl;
    ABDACBCtl = PBA_ABDACB.Cntl;
    TRNGCtl = PBA_TRNG.Cntl;
    PARCCtl = PBA_PARC.Cntl;
    CATBCtl = PBA_CATB.Cntl;
    TWIM2Ctl = PBA_TWIM2.Cntl;
    TWIM3Ctl = PBA_TWIM3.Cntl;
    LCDCACtl = PBA_LCDCA.Cntl;
    FLASHCALW_PBBCtl = PBB_FLASHCALW.Cntl;
    HRAMC1Ctl = PBB_HRAMC1.Cntl;
    HMATRIXCtl = PBB_HMATRIX.Cntl;
    PDCA_PBBCtl = PBB_PDCA.Cntl;
    CRCCU_PBBCtl = PBB_CRCCU.Cntl;
    USBC_PBBCtl = PBB_USBC.Cntl;
    PEVCCtl = PBB_PEVC.Cntl;
    PMCtl = PBC_PM.Cntl;
    CHIPIDCtl = PBC_CHIPID.Cntl;
    SCIFCtl = PBC_SCIF.Cntl;
    FREQMCtl = PBC_FREQM.Cntl;
    GPIOCtl = PBC_GPIO.Cntl;
    BPMCtl = PBC_BPM.Cntl;
    BSCIFCtl = PBC_BSCIF.Cntl;
    ASTCtl = PBC_AST.Cntl;
    WDTCtl = PBC_WDT.Cntl;
    EICCtl = PBC_EIC.Cntl;
    PICOUARTCtl = PBC_PICOUART.Cntl;

    components McuSleepC;
    McuSleepC.HplSam4Clock -> HplSam4lClockP;
}
