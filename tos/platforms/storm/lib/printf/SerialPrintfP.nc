
#include "printf.h"

module SerialPrintfP
{
    provides interface Init;
    uses interface UartByte;
}
implementation
{

    /*
     * The Minimal snprintf() implementation
     *
     * Copyright (c) 2013,2014 Michal Ludvig <michal@logix.cz>
     * All rights reserved.
     *
     * Redistribution and use in source and binary forms, with or without
     * modification, are permitted provided that the following conditions are met:
     *     * Redistributions of source code must retain the above copyright
     *       notice, this list of conditions and the following disclaimer.
     *     * Redistributions in binary form must reproduce the above copyright
     *       notice, this list of conditions and the following disclaimer in the
     *       documentation and/or other materials provided with the distribution.
     *     * Neither the name of the auhor nor the names of its contributors
     *       may be used to endorse or promote products derived from this software
     *       without specific prior written permission.
     *
     * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
     * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
     * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
     * DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
     * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
     * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
     * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
     * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
     * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
     * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
     *
     * ----
     *
     * This is a minimal snprintf() implementation optimised
     * for embedded systems with a very limited program memory.
     * mini_snprintf() doesn't support _all_ the formatting
     * the glibc does but on the other hand is a lot smaller.
     * Here are some numbers from my STM32 project (.bin file size):
     *      no snprintf():      10768 bytes
     *      mini snprintf():    11420 bytes     (+  652 bytes)
     *      glibc snprintf():   34860 bytes     (+24092 bytes)
     * Wasting nearly 24kB of memory just for snprintf() on
     * a chip with 32kB flash is crazy. Use mini_snprintf() instead.
     *
     */

    #include <string.h>
    #include <stdarg.h>

    unsigned int mini_strlen(const char *s)
    {
        unsigned int len = 0;
        while (s[len] != '\0') len++;
        return len;
    }

    unsigned int  mini_itoa(int value, unsigned int radix, unsigned int uppercase,
         char *buffer, unsigned int zero_pad)
    {
        char	*pbuffer = buffer;
        int	negative = 0;
        unsigned int	i, len;

        /* No support for unusual radixes. */
        if (radix > 16)
            return 0;

        if (value < 0) {
            negative = 1;
            value = -value;
        }

        /* This builds the string back to front ... */
        do {
            int digit = value % radix;
            *(pbuffer++) = (digit < 10 ? '0' + digit : (uppercase ? 'A' : 'a') + digit - 10);
            value /= radix;
        } while (value > 0);

        for (i = (pbuffer - buffer); i < zero_pad; i++)
            *(pbuffer++) = '0';

        if (negative)
            *(pbuffer++) = '-';

        *(pbuffer) = '\0';

        /* ... now we reverse it (could do it recursively but will
         * conserve the stack space) */
        len = (pbuffer - buffer);
        for (i = 0; i < len / 2; i++) {
            char j = buffer[i];
            buffer[i] = buffer[len-i-1];
            buffer[len-i-1] = j;
        }

        return len;
    }

    int _puts(char *s, unsigned int len, unsigned int buffer_len, char* pbuffer, char* buffer)
    {
        unsigned int i;

        if (buffer_len - (pbuffer - buffer) - 1 < len)
            len = buffer_len - (pbuffer - buffer) - 1;

        /* Copy to buffer */
        for (i = 0; i < len; i++)
            *(pbuffer++) = s[i];
        *(pbuffer) = '\0';

        return len;
    }

    int _putc(char ch, unsigned int buffer_len, char* pbuffer, char* buffer)
    {
        if ((unsigned int)((pbuffer - buffer) + 1) >= buffer_len)
            return 0;
        *(pbuffer++) = ch;
        *(pbuffer) = '\0';
        return 1;
    }

    int storm_vsnprintf(char *buffer, unsigned int buffer_len, const char *fmt, va_list va) @C() @spontaneous()
    {
        char *pbuffer = buffer;
        char bf[24];
        char ch;

        while ((ch=*(fmt++))) {
            if ((unsigned int)((pbuffer - buffer) + 1) >= buffer_len)
                break;
            if (ch!='%')
            {
                if (!((unsigned int)((pbuffer - buffer) + 1) >= buffer_len))
                {
                    *(pbuffer++) = ch;
                    *(pbuffer) = '\0';
                }
            }
            else {
                char zero_pad = 0;
                char *ptr;
                unsigned int len;

                ch=*(fmt++);

                /* Zero padding requested */
                if (ch=='0') {
                    ch=*(fmt++);
                    if (ch == '\0')
                        goto end;
                    if (ch >= '0' && ch <= '9')
                        zero_pad = ch - '0';
                    ch=*(fmt++);
                }

                switch (ch) {
                    case 0:
                        goto end;

                    case 'u':
                    case 'd':
                    case 'i':
                         len = mini_itoa(va_arg(va, unsigned int), 10, 0, bf, zero_pad);
                         {
                            unsigned int i;

                            if (buffer_len - (pbuffer - buffer) - 1 < len)
                                len = buffer_len - (pbuffer - buffer) - 1;

                            /* Copy to buffer */
                            for (i = 0; i < len; i++)
                                *(pbuffer++) = bf[i];
                            *(pbuffer) = '\0';
                        }
                        break;
                    case 'p':
                    case 'P':
                        *(pbuffer++) = '0';
                        *(pbuffer++) = 'x';
                        zero_pad = 8;
                    case 'x':
                    case 'X':
                        len = mini_itoa(va_arg(va, unsigned int), 16, (ch=='X'), bf, zero_pad);
                        {
                            unsigned int i;

                            if (buffer_len - (pbuffer - buffer) - 1 < len)
                                len = buffer_len - (pbuffer - buffer) - 1;

                            /* Copy to buffer */
                            for (i = 0; i < len; i++)
                                *(pbuffer++) = bf[i];
                            *(pbuffer) = '\0';
                        }
                        break;

                    case 'c' :
                        {
                            if (!((unsigned int)((pbuffer - buffer) + 1) >= buffer_len))
                            {
                                *(pbuffer++) = (char)(va_arg(va, int));
                                *(pbuffer) = '\0';
                            }
                        }
                        break;

                    case 's' :
                        ptr = va_arg(va, char*);
                        {
                            unsigned int i, len;
                            len = mini_strlen(ptr);

                            if (buffer_len - (pbuffer - buffer) - 1 < len)
                                len = buffer_len - (pbuffer - buffer) - 1;

                            /* Copy to buffer */
                            for (i = 0; i < len; i++)
                                *(pbuffer++) = ptr[i];
                            *(pbuffer) = '\0';
                        }
                        break;

                    default:
                        {
                            if (!((unsigned int)((pbuffer - buffer) + 1) >= buffer_len))
                            {
                                *(pbuffer++) = (char)(va_arg(va, int));
                                *(pbuffer) = '\0';
                            }
                        }
                        break;
                }
            }
        }
    end:
        return pbuffer - buffer;
    }


    int storm_snprintf(char* buffer, unsigned int buffer_len, const char *fmt, ...) @C() @spontaneous()
    {
        int ret;
        va_list va;
        va_start(va, fmt);
        ret = storm_vsnprintf(buffer, buffer_len, fmt, va);
        va_end(va);

        return ret;
    }

    uint8_t storm_printf_buffer [1024];

    int storm_printf(const char* fmt, ...) @C() @spontaneous()
    {
        int ret;
        uint32_t i;
        va_list va;
        va_start(va, fmt);
        ret = storm_vsnprintf(storm_printf_buffer, 256, fmt, va);
        va_end(va);

        for (i=0;i<ret;i++)
        {
            call UartByte.send(storm_printf_buffer[i]);
        }

        return ret;
    }

    int storm_write(uint8_t const *buf, int len) @C() @spontaneous()
    {
        int ret;
        for(ret = 0; ret < len; ret++)
        {
            call UartByte.send(*buf);
            buf++;
        }
        return ret;
    }
    int storm_read(uint8_t *buf, int len) @C() @spontaneous()
    {
        int ret;
        for(ret = 0; ret < len; ret++)
        {
            error_t rv;
            rv = call UartByte.receive(buf + ret, 200);
            if (rv != SUCCESS)
                return ret;
            buf++;
        }
        return ret;
    }
    command error_t Init.init()
    {
        return SUCCESS;
    }

    static uint32_t volatile * const stim0_32 = ((volatile uint32_t*) 0xE0000000);
    static uint8_t volatile * const stim0_8 = ((volatile uint8_t*)    0xE0000000);

    static uint32_t volatile * const stim1_32 = ((volatile uint32_t*)  0xE0000004);
    static uint16_t volatile * const stim1_16 = ((volatile uint16_t*)  0xE0000004);
    static uint8_t volatile * const stim1_8 = ((volatile uint8_t*)     0xE0000004);

    //These functions write to the ITM, so are much faster than printf, for
    //hotpath debugging
    void storm_trace(const char* s) @C() @spontaneous()
    {
        while(*s != 0)
        {
            while( *stim0_32 == 0 );
            *stim0_8 = *s;
            s++;
        }
    }
    void storm_trace8(uint8_t v) @C() @spontaneous()
    {
        while( *stim1_32 == 0 );
        *stim1_8 = v;
    }
    void storm_trace16(uint16_t v) @C() @spontaneous()
    {
        while( *stim1_32 == 0 );
        *stim1_16 = v;
    }
    void storm_trace32(uint32_t v) @C() @spontaneous()
    {
        while( *stim1_32 == 0 );
        *stim1_32 = v;
    }

}
