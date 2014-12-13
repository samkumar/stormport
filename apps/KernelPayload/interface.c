
#include "interface.h"
#include <stdint.h>
#include <sys/stat.h>

get_proc_address_t      get_proc_address = (get_proc_address_t)(0x41001);
get_kernel_version_t    get_kernel_version;
write_t                 write;
request_timeslice_t     request_timeslice;

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
    return write(fd, buf, count);
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
    return -1;
}
void loadsyms()
{
    get_kernel_version  = get_proc_address(ABI_ID_GET_KERNEL_VERSION);
    write               = get_proc_address(ABI_ID_WRITE);
    request_timeslice   = get_proc_address(ABI_ID_REQUEST_TIMESLICE);
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

/* This function is intended to return! */
void _start()
{
    uint32_t *pSrc, *pDest;

    /* Move the relocate segment */
	pSrc = &_etext;
	pDest = &_srelocate;
	if (pSrc != pDest) for (; pDest < &_erelocate;) *pDest++ = *pSrc++;

	/* Clear the zero segment */
	for (pDest = &_szero; pDest < &_ezero;) *pDest++ = 0;

    /* load symbols */
    loadsyms();

    /* create a timeslice for the setup() function */
    request_timeslice(1, 1, setup);

    /* return back to the kernel */
    return;
}