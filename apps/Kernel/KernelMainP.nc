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
//fptr, rptr, arg0, arg1
extern void __inject_function(void*, void*, uint32_t, uint32_t);

module KernelMainP
{
    uses
    {
        interface Boot;
        interface SplitControl as RadioControl;
        interface UDP as Dmesg;
        interface FlashAttr;
        interface Timer<T32khz> as Timer;
        interface UartStream;
    }
}
implementation
{
    enum {
        procstate_init,
        procstate_runnable,
        procstate_wait_stdin,
        procstate_wait_event,
        procstate_flush_event
    } procstate = procstate_init;

    #define STDIN_SIZE 128
    #define STDOUT_SIZE 256

    uint8_t process_stdin_ringbuffer [STDIN_SIZE];
    uint8_t process_stdout_ringbuffer [STDOUT_SIZE];
    uint32_t *process_syscall_rv;
    uint32_t *syscall_args;

    uint16_t norace stdin_rptr = 0;
    uint16_t norace stdin_wptr = 0;
    uint16_t norace stdout_rptr = 0;
    uint16_t norace stdout_wptr = 0;

    //----
    // Various state flags for callbacks
    //----
    cb_u32_t  cb_read_f_ptr = NULL;
    void     *cb_read_r_ptr;
    uint32_t  cb_read_len;
    uint8_t  *cb_read_buf;

    inline void stdout_enqueue(uint8_t c)
    {
        if (((stdout_wptr + 1) & (STDOUT_SIZE-1)) == stdout_rptr)
            return; //full

        process_stdout_ringbuffer[stdout_wptr] = c;
        stdout_wptr = (stdout_wptr + 1) & (STDOUT_SIZE - 1);
    }
    inline int stdout_dequeue()
    {
        int rv;
        if (stdout_rptr == stdout_wptr) return -1;
        rv = process_stdout_ringbuffer[stdout_rptr];
        stdout_rptr = (stdout_rptr + 1) & (STDOUT_SIZE - 1);
        return rv;
    }
    inline void stdin_enqueue(uint8_t c)
    {
        atomic
        {
            if (((stdin_wptr + 1) & (STDIN_SIZE-1)) == stdin_rptr)
                return; //full

            process_stdin_ringbuffer[stdin_wptr] = c;
            stdin_wptr = (stdin_wptr + 1) & (STDIN_SIZE - 1);
        }
    }
    inline int stdin_dequeue()
    {
        atomic
        {
            int rv;
            if (stdin_rptr == stdin_wptr) return -1;
            rv = process_stdin_ringbuffer[stdin_rptr];
            stdin_rptr = (stdin_rptr + 1) & (STDIN_SIZE - 1);
            return rv;
        }
    }
    struct sockaddr_in6 route_dest;
    task void launch_payload();
    event void Boot.booted() {
        call RadioControl.start();
        call UartStream.enableReceiveInterrupt();
        printf("Booting kernel %d.%d.%d.%d (%s)\n",VER_MAJOR, VER_MINOR, VER_SUBMINOR, VER_BUILD, GITCOMMIT);

        route_dest.sin6_port = htons(7);
        inet_pton6("2001:470:4899:a::3", &route_dest.sin6_addr);

        call Dmesg.bind(514);

        post launch_payload();
        //call Timer.startPeriodic(32000);
    }

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
        __bootstrap_payload(addr);
        printf("Payload stack generated\n");
        procstate = procstate_runnable;
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

    event void Timer.fired()
    {
        printf("alive\n");
    }
    task void flush_process_stdout()
    {
        error_t e;
        uint16_t eptr;
        if (stdout_wptr == stdout_rptr)
            return; //Empty
        if (stdout_wptr < stdout_rptr) //Can't do write across ringbuffer wrap
        {
            eptr = STDOUT_SIZE;
        }
        else
        {
            eptr = stdout_wptr;
        }
        storm_write(process_stdout_ringbuffer + stdout_rptr, eptr - stdout_rptr);
        stdout_rptr = eptr & (STDOUT_SIZE - 1);
    }
    async event void UartStream.sendDone(uint8_t* buf, uint16_t len, error_t error )
    {
        post flush_process_stdout();
    }
    async event void UartStream.receivedByte(uint8_t byte)
    {
        stdin_enqueue(byte);
    }
    async event void UartStream.receiveDone( uint8_t* buf, uint16_t len, error_t error ) {}

    uint32_t kabi_get_kernel_version()
    {
        return (VER_MAJOR << 24) | (VER_MINOR << 16) | (VER_SUBMINOR << 8) | (VER_BUILD);
    }
    int32_t kabi_write(uint32_t fd, uint8_t const *src, uint32_t size)
    {
        if (fd == 1)
        {
            int i;
            for (i = 0; i < size; i++)
            {
                stdout_enqueue(src[i]);
            }
            post flush_process_stdout();
            return size;
        }
        return -1;
    }
    int32_t kabi_read(uint32_t fd, uint8_t *dst, uint32_t size)
    {
        int c;
        uint32_t i;
        for (i = 0; i < size; i++)
        {
            c = stdin_dequeue();
            if (c < 0) return i;
            dst[i] = (uint8_t) c;
        }
    }
    int32_t kabi_request_timeslice(uint32_t ticks, uint8_t oneshot, void (*callback)())
    {

    }

    // return TRUE if the process has more to do
    // FALSE if it is ok to go to sleep
    bool run_process() @C() @spontaneous()
    {
        uint32_t tmp;

        switch(procstate)
        {
            case procstate_runnable:
                //printf("[SCH:R]\n");
                __syscall(KABI_RESUME_PROCESS);
                return TRUE;
            case procstate_wait_stdin:
                if (stdin_rptr != stdin_wptr)
                {
                    printf("[SCH:I]\n");
                    tmp = kabi_read(syscall_args[0], &((uint8_t*)(syscall_args[1]))[0], syscall_args[2]);
                    printf("rd:%d\n",tmp);
                    *process_syscall_rv = tmp;
                    procstate = procstate_runnable;
                    __syscall(KABI_RESUME_PROCESS);
                    return TRUE;
                }
                return FALSE;
            case procstate_wait_event:
            case procstate_flush_event:
                //Check for special static callbacks - like read_async
                if (cb_read_buf != NULL && (stdin_rptr != stdin_wptr))
                {
                    printf("vptr = %08x\n",cb_read_r_ptr);
                    tmp = kabi_read(0, cb_read_buf, cb_read_len);
                    cb_read_buf = NULL;
                    __inject_function(cb_read_f_ptr, cb_read_r_ptr, tmp, 0);
                    procstate = procstate_runnable;
                    __syscall(KABI_RESUME_PROCESS);
                    return TRUE;
                }
                //if there was an event, we would process it and return, bypassing this if statement.
                if (procstate == procstate_flush_event) { //If/when event queue is empty, flush_event becomes runnable, wait_event doesn't exit on empty queue, only on an event.
                    procstate = procstate_runnable;
                    return TRUE;
                }
                return FALSE;
            default:
                //printf("[SCH:W]\n");
                return FALSE;
        }
    }

    #define RET_KERNEL 1
    #define RET_USER 0
    //8 for the ISR frame, 8 for the syscall frame
    #define STACKED 16

    uint32_t sv_call_handler_main(uint32_t *svc_args)
    {
        unsigned int svc_number;
        int32_t tmp;
        svc_number = ((char *)svc_args[6])[-2];
        process_syscall_rv = &svc_args[0];
        syscall_args = &svc_args[0];

        //printf("svc number: %d %08x %08x %08x\n", svc_number, svc_args[0], svc_args[1], svc_args[2]);
        switch(svc_number)
        {
            case KABI_RESUME_PROCESS:
                return RET_USER;
            case ABI_ID_GET_KERNEL_VERSION:
                *process_syscall_rv = kabi_get_kernel_version();
                procstate = procstate_runnable;
                return RET_KERNEL;
            case ABI_ID_WRITE:
                *process_syscall_rv = (uint32_t) kabi_write(syscall_args[0], (uint8_t*)(syscall_args[1]), syscall_args[2]);
                procstate = procstate_runnable;
                return RET_KERNEL;
            case ABI_ID_YIELD:
                procstate = procstate_runnable;
                return RET_KERNEL;
            case ABI_ID_READ:
                tmp = kabi_read(syscall_args[0], &((uint8_t*)(syscall_args[1]))[0], syscall_args[2]);
                if (tmp == 0)
                {
                    procstate = procstate_wait_stdin;
                } else {
                    *process_syscall_rv = tmp;
                    procstate = procstate_runnable;
                }
                return RET_KERNEL;
            case ABI_ID_READ_ASYNC:
                if (syscall_args[0] != 0)
                {
                    *process_syscall_rv = -9; //-EBADF
                    procstate = procstate_runnable;
                    return RET_KERNEL;
                }
                if (cb_read_buf != NULL)
                {
                    *process_syscall_rv = -EBUSY;
                    procstate = procstate_runnable;
                    return RET_KERNEL;
                }
                cb_read_buf = (uint8_t*) syscall_args[1]; //Check bounds on this
                cb_read_len = syscall_args[2];
                cb_read_f_ptr = (cb_u32_t) syscall_args[3];
                cb_read_r_ptr = (void*) syscall_args[STACKED + 0];
                procstate = procstate_runnable;
                return RET_KERNEL;
            case ABI_ID_RUN_CALLBACK:
                procstate = procstate_flush_event;
                return RET_KERNEL;
            case ABI_ID_WAIT_CALLBACK:
                procstate = procstate_wait_event;
                return RET_KERNEL;
            case KABI_EJECT:
                asm volatile(
                    "mrs r0, psp\n\t"
                    "add r0, r0, 32\n\t"
                    "msr psp, r0"
                     : : : "r0"
                );
                procstate = procstate_runnable;
                return RET_KERNEL;
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