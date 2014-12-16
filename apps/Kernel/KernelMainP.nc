/*
 * Copyright (c) 2008-2010 The Regents of the University  of California.
 * All rights reserved."
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
 *
 */

#include <IPDispatch.h>
#include <lib6lowpan/lib6lowpan.h>
#include <lib6lowpan/ip.h>
#include <lib6lowpan/ip.h>
#include "version.h"
#include "blip_printf.h"
#include "interface.h"

#define REPORT_PERIOD 60L
extern void __bootstrap_payload(uint32_t base_addr);
#define __syscall(code) asm volatile (\
    "push {r4-r11,lr}\n\t"\
    "svc %[immediate]\n\t"\
    "pop {r4-r11,lr}"::[immediate] "I" (code):"memory")

module KernelMainP
{
    uses
    {
        interface Boot;
        interface SplitControl as RadioControl;
        interface UDP as Dmesg;
        interface FlashAttr;
        interface Timer<T32khz> as Timer;
    }
}
implementation
{
    struct sockaddr_in6 route_dest;
    task void launch_payload();
    event void Boot.booted() {
        call RadioControl.start();
        printf("Booting kernel %d.%d.%d.%d (%s)\n",VER_MAJOR, VER_MINOR, VER_SUBMINOR, VER_BUILD, GITCOMMIT);

        route_dest.sin6_port = htons(7);
        inet_pton6("2001:470:4899:a::3", &route_dest.sin6_addr);

        call Dmesg.bind(514);

        post launch_payload();

    }

    task void selftest()
    {
        uint8_t f [11];
        strcpy(f, "hello");
        call Dmesg.sendto(&route_dest, &f[0], 5);
    }
    bool payload_running = FALSE;
    task void launch_payload()
    {
        uint8_t key [10];
        uint8_t val [65];
        uint8_t val_len;
        error_t rv;
        uint32_t addr;
        rv = call FlashAttr.getAttr(1, key, val, &val_len);
        if (rv != SUCCESS)
        {
            printf("Could not get flash attr\n");
        }
        if (val_len != 4)
        {
            printf("Did not find expected payload entry point: %d", val_len);
            return;
        }
        addr = val[0] + ((uint32_t)val[1] << 8) + ((uint32_t)val[2] << 16) + ((uint32_t)val[3] << 24);
        if (addr < 0x50000)
        {
            printf("Did not find expected payload entry point");
            return;
        }
        printf("Found payload start at 0x%04x\n", addr);
        payload_running = TRUE;
        __bootstrap_payload(addr);
        printf("Payload stack generated\n");
        __syscall(1);
        printf("after le jump");
    }
    event void RadioControl.startDone(error_t e)
    {
    }

    event void RadioControl.stopDone(error_t e)
    {

    }

    event void Dmesg.recvfrom(struct sockaddr_in6 *from, void *data,
                             uint16_t len, struct ip6_metadata *meta)
    {
        printf("Got traffic on dmesg port\n");
    }



    uint32_t kabi_get_kernel_version()
    {
        return (VER_MAJOR << 24) | (VER_MINOR << 16) | (VER_SUBMINOR << 8) | (VER_BUILD);
    }
    int32_t kabi_write(uint32_t fd, uint8_t const *src, uint32_t size)
    {
        switch(fd)
        {
            case 1:
                return storm_write(src, size);
            default:
                return -1;
        }

    }
    int32_t kabi_read(uint32_t fd, uint8_t *dst, uint32_t size)
    {
        switch(fd)
        {
            case 0:
                return storm_read(dst, size);
            default:
                return -1;
        }
    }
    int32_t kabi_request_timeslice(uint32_t ticks, uint8_t oneshot, void (*callback)())
    {

    }
    event void Timer.fired()
    {

    }

    #define RET_KERNEL 1
    #define RET_USER 0

    uint32_t sv_call_handler_main(unsigned int *svc_args)
    {
        unsigned int svc_number;
        int32_t *r_i32, *r_u32;
        /*
         * We can extract the SVC number from the SVC instruction. svc_args[6]
         * points to the program counter (the code executed just before the svc
         * call). We need to add an offset of -2 to get to the upper byte of
         * the SVC instruction (the immediate value).
         */
        svc_number = ((char *)svc_args[6])[-2];
        r_i32 = (int32_t *) &svc_args[0];
        r_u32 = (uint32_t *) &svc_args[0];

        //printf("svc number: %d\n", svc_number);
        switch(svc_number)
        {
            case ABI_ID_GET_KERNEL_VERSION:
                *r_u32 = kabi_get_kernel_version();
                return RET_USER;
            case ABI_ID_WRITE:
                *r_i32 = kabi_write(svc_args[0], (uint8_t*)(svc_args[1]), svc_args[2]);
                return RET_USER;
            case ABI_ID_YIELD:
                return RET_KERNEL;
            case ABI_ID_READ:
                *r_i32 = kabi_read(svc_args[0], (uint8_t*)(svc_args[1]), svc_args[2]);
                return RET_USER;
            default:
                printf("bad svc number\n");
                //switch
                break;
        }
    }

    void SVC_Handler() @C() @spontaneous() __attribute__(( naked ))
    {
        /*
         * Get the pointer to the stack frame which was saved before the SVC
         * call and use it as first parameter for the C-function (r0)
         * All relevant registers (r0 to r3, r12 (scratch register), r14 or lr
         * (link register), r15 or pc (programm counter) and xPSR (program
         * status register) are saved by hardware.
         */
        asm volatile(
            "tst lr, #4\t\n" /* Check EXC_RETURN[2] */
            "ite eq\t\n"
            "mrseq r0, msp\t\n"
            "mrsne r0, psp\t\n"
            "bl %[sv_call_handler_main]\t\n"
            "b __context_switch\t\n"
            : /* no output */
            : [sv_call_handler_main] "i" (sv_call_handler_main)
            : "r0" /* clobber */
        );
    }

}
