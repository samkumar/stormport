/*
 * Copyright (c) 2010 University of Utah.
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
 * This file is copied/adapted from the sam3s tinyos port
 * @author Michael Andersen
 * @author Thomas Schmid
 */

#ifndef SAM4L_HARDWARE_H
#define SAM4L_HARDWARE_H

#include <cortexm4hardware.h>

// Peripheral ID definitions for the SAM4L
//  Defined in AT91 ARM Cortex-M3 based Microcontrollers, SAM3S Series, Preliminary, p. 34
#define SAM4L_PID_USART0_RX     ( 0)
#define SAM4L_PID_USART1_RX     ( 1)
#define SAM4L_PID_USART2_RX     ( 2)
#define SAM4L_PID_USART3_RX     ( 3)
#define SAM4L_PID_SPI_RX        ( 4)
#define SAM4L_PID_TWIM0_RX      ( 5)
#define SAM4L_PID_TWIM1_RX      ( 6)
#define SAM4L_PID_TWIM2_RX      ( 7)
#define SAM4L_PID_TWIM3_RX      ( 8)
#define SAM4L_PID_TWIS0_RX      ( 9)
#define SAM4L_PID_TWIS1_RX      (10)
#define SAM4L_PID_ADCIFE_RX     (11)
#define SAM4L_PID_CATB_RX       (12)
//There is no PID 13
#define SAM4L_PID_IISC_RX_CH0   (14)
#define SAM4L_PID_IISC_RX_CH1   (15)
#define SAM4L_PID_PARC_RX       (16)
#define SAM4L_PID_AESA_RX       (17)
#define SAM4L_PID_USART0_TX     (18)
#define SAM4L_PID_USART1_TX     (19)
#define SAM4L_PID_USART2_TX     (20)
#define SAM4L_PID_USART3_TX     (21)
#define SAM4L_PID_SPI_TX        (22)
#define SAM4L_PID_TWIM0_TX      (23)
#define SAM4L_PID_TWIM1_TX      (24)
#define SAM4L_PID_TWIM2_TX      (25)
#define SAM4L_PID_TWIM3_TX      (26)
#define SAM4L_PID_TWIS0_TX      (27)
#define SAM4L_PID_TWIS1_TX      (28)
#define SAM4L_PID_ADCIFE        (29)
#define SAM4L_PID_CATB          (30)
#define SAM4L_PID_ABDACB_SDR0   (31)
#define SAM4L_PID_ABDACB_SDR1   (32)
#define SAM4L_PID_IISC_TX_CH0   (33)
#define SAM4L_PID_IISC_TX_CH1   (34)
#define SAM4L_PID_DACC_TX       (35)
#define SAM4L_PID_AESA_TX       (36)
#define SAM4L_PID_LCDCA_ACMDR   (37)
#define SAM4L_PID_LCDCA_ABMDR   (38)

#if 0
/*
 XTAG: not sure why we need this, can't the GPIO interface do this?
*/
    #define SAM3S_PERIPHERALA (0x400e0e00)
    #define SAM3S_PERIPHERALB (0x400e1000)
    #define SAM3S_PERIPHERALC (0x400e1200)

    #define TOSH_ASSIGN_PIN(name, port, bit) \
    static inline void TOSH_SET_##name##_PIN() \
      {*((volatile uint32_t *) (SAM3S_PERIPHERAL##port + 0x030)) = (1 << bit);} \
    static inline void TOSH_CLR_##name##_PIN() \
      {*((volatile uint32_t *) (SAM3S_PERIPHERAL##port + 0x034)) = (1 << bit);} \
    static inline int TOSH_READ_##name##_PIN() \
      { \
        /* Read bit from Output Status Register */ \
        uint32_t currentport = *((volatile uint32_t *) (SAM3S_PERIPHERAL##port + 0x018)); \
        uint32_t currentpin = (currentport & (1 << bit)) >> bit; \
        bool isInput = ((currentpin & 1) == 0); \
        if (isInput == 1) { \
                /* Read bit from Pin Data Status Register */ \
                currentport = *((volatile uint32_t *) (SAM3S_PERIPHERAL##port + 0x03c)); \
                currentpin = (currentport & (1 << bit)) >> bit; \
                return ((currentpin & 1) == 1); \
        } else { \
                /* Read bit from Output Data Status Register */ \
                currentport = *((volatile uint32_t *) (SAM3S_PERIPHERAL##port + 0x038)); \
                currentpin = (currentport & (1 << bit)) >> bit; \
                return ((currentpin & 1) == 1); \
        } \
      } \
    static inline void TOSH_MAKE_##name##_OUTPUT() \
      {*((volatile uint32_t *) (SAM3S_PERIPHERAL##port + 0x010)) = (1 << bit);} \
    static inline void TOSH_MAKE_##name##_INPUT() \
      {*((volatile uint32_t *) (SAM3S_PERIPHERAL##port + 0x014)) = (1 << bit);}

    #define TOSH_ASSIGN_OUTPUT_ONLY_PIN(name, port, bit) \
    static inline void TOSH_SET_##name##_PIN() \
      {*((volatile uint32_t *) (SAM3S_PERIPHERAL##port + 0x030)) = (1 << bit);} \
    static inline void TOSH_CLR_##name##_PIN() \
      {*((volatile uint32_t *) (SAM3S_PERIPHERAL##port + 0x034)) = (1 << bit);} \
    static inline void TOSH_MAKE_##name##_OUTPUT() \
      {*((volatile uint32_t *) (SAM3S_PERIPHERAL##port + 0x010)) = (1 << bit);} \

    #define TOSH_ALIAS_OUTPUT_ONLY_PIN(alias, connector)\
    static inline void TOSH_SET_##alias##_PIN() {TOSH_SET_##connector##_PIN();} \
    static inline void TOSH_CLR_##alias##_PIN() {TOSH_CLR_##connector##_PIN();} \
    static inline void TOSH_MAKE_##alias##_OUTPUT() {} \

    #define TOSH_ALIAS_PIN(alias, connector) \
    static inline void TOSH_SET_##alias##_PIN() {TOSH_SET_##connector##_PIN();} \
    static inline void TOSH_CLR_##alias##_PIN() {TOSH_CLR_##connector##_PIN();} \
    static inline char TOSH_READ_##alias##_PIN() {return TOSH_READ_##connector##_PIN();} \
    static inline void TOSH_MAKE_##alias##_OUTPUT() {TOSH_MAKE_##connector##_OUTPUT();} \
#endif
#endif // SAM4L_HARDWARE_H
