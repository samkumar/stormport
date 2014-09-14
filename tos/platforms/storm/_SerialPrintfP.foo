#include <stdio.h>
#include <stdarg.h>
#include <sys/types.h>
#include <sys/stat.h>

module SerialPrintfP
{
    uses interface UartStream;
    uses interface UartByte;
}
implementation
{
    async event void UartStream.receiveDone( uint8_t* buf, uint16_t len, error_t error ){}
    async event void UartStream.sendDone( uint8_t* buf, uint16_t len, error_t error ){}
    async event void UartStream.receivedByte( uint8_t byte ){}
    caddr_t _sbrk(int incr) @C() @spontaneous()
    {
        return 0;
    }

    int link(char *old, char *n) @C() @spontaneous()
    {
        return -1;
    }

    int _close(int file) @C() @spontaneous()
    {
        return -1;
    }

    int _read (int *f) @C() @spontaneous()
    {
        return 0;
    }

    int _fstat(int file, struct stat *st) @C() @spontaneous()
    { 
        st->st_mode = S_IFCHR;

        return 0;
    }

    int _isatty(int file) @C() @spontaneous()
    {
        return 1;
    }

    int _lseek(int file, int ptr, int dir) @C() @spontaneous()
    {
        return 0;
    }

    int _write(int fd, const void *buf, uint32_t count) @C() @spontaneous()
    {
        while(call UartStream.send((uint8_t*) buf, (uint16_t) count) == FAIL);
    }

    int lowlevel_putc(int c) @C() @spontaneous()
    {
        call UartByte.send(c);
    }
}
