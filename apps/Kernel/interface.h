
#ifndef __INTERFACE_H__
#define __INTERFACE_H__

#include <stdint.h>

/**
 * Get the version of the kernel on the system.
 *
 * The octets are MAJ.MINOR.SUBMINOR.BUILD.
 * @return The currently loaded kernel's version
 */

#define ABI_ID_GET_KERNEL_VERSION 1

/**
 *
 * Write to a file descriptor. The kernel should probably provide stdout (1) as the system default UART,
 * which may have some form of framing for process disambiguation. stderr (2) could probably the SWO TRACE
 * output. The flash chip interface might use this too.
 * @param     fd   The file descriptor number
 * @param[in] src  The buffer to read from
 * @param     size The number of bytes to write
 * @return The number of bytes written, or -1 if there was an error.
 */
#define ABI_ID_WRITE 2

/**
 *
 * Set a timeslice function that gets called every N ticks. 1 tick is
 * approx 61 microseconds
 * @param   ticks   The interval in ticks
 * @param   oneshot If 1, this will only occur once.
 * @param   cb      The callback to invoke
 */
//void request_timeslice(uint32_t ticks, uint8_t oneshot, void (*cb)())
//#define ABI_ID_REQUEST_TIMESLICE 3

/**
 *
 * Yield execution from payload to kernel (this is like exit())
 * @abi_id 3
 */
#define ABI_ID_YIELD 3

/**
 *
 * Read bytes from kernel
 * @param      fd   The file descriptor number
 * @param[out] dst  The buffer to write to
 * @param      size The number of bytes to read
 * @return The number of bytes read (which may be less than size), or -1 if there was an error.
 */
#define ABI_ID_READ 4

#endif