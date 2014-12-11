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

#include "blip_printf.h"

#define REPORT_PERIOD 60L

module KernelMainP
{
    uses
    {
        interface Boot;
        interface SplitControl as RadioControl;
        interface UDP as Dmesg;
    }
}
implementation
{
    //struct sockaddr_in6 route_dest;

    event void Boot.booted() {
        call RadioControl.start();

        /*#ifdef REPORT_DEST
        route_dest.sin6_port = htons(7);
        inet_pton6("fe80::4", &route_dest.sin6_addr);
        call StatusTimer.startOneShot(call Random.rand16() % (1024 * REPORT_PERIOD));
        #endif*/

        call Dmesg.bind(514);
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

    void* get_proc_address(uint32_t identifier) @C() @spontaneous() __attribute__((section(".kernelabi")))
    {
        return (void*)5;
    }
}
