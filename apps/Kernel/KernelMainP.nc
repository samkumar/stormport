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

#define REPORT_PERIOD 60L

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
        uint32_t addr;
        call FlashAttr.getAttr(1, key, val, &val_len);
        if (val_len != 4)
        {
            printf("Did not find expected payload entry point");
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
        ((void (*)()) addr)();




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
    void (*rt_callback) ();
    int32_t kabi_request_timeslice(uint32_t ticks, uint8_t oneshot, void (*callback)())
    {
        rt_callback = callback;
        call Timer.startOneShot(1000);
    }
    event void Timer.fired()
    {
        rt_callback();
        post selftest();
    }
    extern void* proc_table [];
    void* get_proc_address(uint32_t abi_id) @C() @spontaneous() __attribute__((section(".kernelabi")))
    {
        if (abi_id < 4)
            return proc_table[abi_id];
        return NULL;
    }
    void* proc_table [] = {
        get_proc_address,           //0
        kabi_get_kernel_version,    //1
        kabi_write,                 //2
        kabi_request_timeslice      //3
    };

}
