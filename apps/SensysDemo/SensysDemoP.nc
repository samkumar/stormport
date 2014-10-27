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
#include <printf.h>

#define DATA_TX_PERIOD 5000L

module SensysDemoP
{
    uses
    {
        interface Boot;
        interface SplitControl as RadioControl;
        interface UDP as Sock;
        interface GeneralIO as Led;
        interface Timer<TMilli> as Timer;
        interface SplitControl as SensorControl;
        interface FlashAttr;
        interface RootControl;
    }
}
implementation
{
    struct sockaddr_in6 data_dest;


    bool shouldBeRoot()
    {
        uint8_t key [10];
        uint8_t val [65];
        uint8_t val_len;
        error_t e;

        e = call FlashAttr.getAttr(0, key, val, &val_len);
        return (e == SUCCESS && val_len == 1 && (val[0] == 1 || val[0] == '1'));
    }
    event void Boot.booted()
    {

        data_dest.sin6_port = htons(4410);;
        inet_pton6("fec0::1", &data_dest.sin6_addr);
        call Timer.startPeriodic(DATA_TX_PERIOD);
        call Sock.bind(4410);
        call Led.makeOutput();
        call Led.set();
        call SensorControl.start();

        if (shouldBeRoot())
        {
            printf("Node configured to be root\n");
            call RootControl.setRoot();
        }
        else
        {
            printf("Node is not DODAG root\n");
        }
        call RadioControl.start();

    }

    event void RadioControl.startDone(error_t e) {}
    event void RadioControl.stopDone(error_t e) {}
    event void SensorControl.startDone(error_t e) {}
    event void SensorControl.stopDone(error_t e) {}

    event void Sock.recvfrom(struct sockaddr_in6 *from, void *data,
                             uint16_t len, struct ip6_metadata *meta)
    {
        printf("Got data on sock\n");
    }


    event void Timer.fired()
    {

        call Led.toggle();



        //call Sock.sendto(&data_dest, &dat[0], 2);
    }
}
