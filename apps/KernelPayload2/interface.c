
#include "interface.h"
#include <stdint.h>
#include <sys/stat.h>


volatile uint32_t foobar;
uint32_t __attribute__((noinline)) k_get_kernel_version()
{
    __syscall(ABI_ID_GET_KERNEL_VERSION);
}
int32_t __attribute__((noinline)) k_write(uint32_t fd, uint8_t const *src, uint32_t size)
{
    __syscall(ABI_ID_WRITE);
}
void __attribute__((noinline)) k_yield()
{
    __syscall(ABI_ID_YIELD);
}
int32_t __attribute__((noinline)) k_read(uint32_t fd, uint8_t *dst, uint32_t size)
{
    __syscall(ABI_ID_READ);
}

extern void* __ram_end__;
void* _sbrk(uint32_t increment)
{
    if (increment == 0)
    {
        return &__ram_end__;
    }
    else
    {
        return (void*) -1;
    }
}
int _isatty(int fd)
{
    if (fd == 1)
    {
        return 1;
    }
    return 0;
}
int _write(int fd, const void *buf, uint32_t count)
{
    k_write(fd, buf, count);
    return count;
}
int _close(int fd)
{
    return -1;
}
int _fstat(int fd, struct stat *buf)
{
    return -1;
}
int _lseek(int fd, uint32_t offset, int whence)
{
    return -1;
}
int _read(int fd, void *buf, uint32_t count)
{
    uint32_t got = 0;
    while(got < count) {
        got += k_read(fd, buf + got, count - got);
    }
    return got;
}


// Symbols defined in the linker file
extern uint32_t _sfixed;
extern uint32_t _efixed;
extern uint32_t _etext;
extern uint32_t _srelocate;
extern uint32_t _erelocate;
extern uint32_t _szero;
extern uint32_t _ezero;
extern uint32_t _sstack;
extern uint32_t _estack;
extern void (*_init)();

//Main function
extern void setup();

extern void main();

void __attribute__(( naked )) _start()
{
    asm volatile("ldr r0, =_start2\n\t"
                 "ldr r1, =_estack\n\t"
                 "bx lr" : : : "r0", "r1" );
}

/* This function is not intended to return! */
void _start2()
{
    //asm volatile(" LDR sp, =_estack");
    uint32_t *pSrc, *pDest;

    /* Move the relocate segment */
	pSrc = &_etext;
	pDest = &_srelocate;
	if (pSrc != pDest) for (; pDest < &_erelocate;) *pDest++ = *pSrc++;

	/* Clear the zero segment */
	for (pDest = &_szero; pDest < &_ezero;) *pDest++ = 0;

    main();
    /* load symbols */
    //loadsyms();

    /* create a timeslice for the setup() function */
    //request_timeslice(1, 1, setup);

    /* return back to the kernel */

    return;
}