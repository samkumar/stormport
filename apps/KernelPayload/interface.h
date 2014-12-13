
#ifndef __INTERFACE_H__
#define __INTERFACE_H__

#include <stdint.h>

/**
 * If there are ABI symbols that need runtime resolution, this function can be used to get the address
 * of other functions in the ABI. This needs discussion, as we need to decide if it is possible to have
 * symbols at fixed addresses (without tons of padding when linking).
 * @param abi_id The function to resolve
 * @return A pointer to the function
 */
//void* get_proc_address(uint32_t abi_id);
typedef void* (*get_proc_address_t)(uint32_t);
extern get_proc_address_t get_proc_address;


/**
 * Get the version of the kernel on the system.
 *
 * The octets are MAJ.MINOR.SUBMINOR.BUILD.
 * @abi_id 1
 * @return The currently loaded kernel's version
 */
//uint32_t get_kernel_version();
typedef uint32_t(*get_kernel_version_t)();
extern get_kernel_version_t get_kernel_version;
#define ABI_ID_GET_KERNEL_VERSION 1

/**
 *
 * Write to a file descriptor. The kernel should probably provide stdout (1) as the system default UART,
 * which may have some form of framing for process disambiguation. stderr (2) could probably the SWO TRACE
 * output. The flash chip interface might use this too.
 * @abi_id 2
 * @param     fd   The file descriptor number
 * @param[in] src  The buffer to read from
 * @param     size The number of bytes to write
 * @return The number of bytes written, or -1 if there was an error.
 */
//int32_t write(uint32_t fd, uint8_t const *src, uint32_t size);
typedef int32_t (*write_t)(uint32_t,uint8_t const *, uint32_t);
extern write_t write;
#define ABI_ID_WRITE 2

/**
 *
 * Set a timeslice function that gets called every N ticks. 1 tick is
 * approx 61 microseconds
 * @abi_id 3
 * @param   ticks   The interval in ticks
 * @param   oneshot If 1, this will only occur once.
 * @param   cb      The callback to invoke
 */
//void request_timeslice(uint32_t ticks, uint8_t oneshot, void (*cb)())
typedef void (*request_timeslice_t)(uint32_t, uint8_t, void (*)());
#define ABI_ID_REQUEST_TIMESLICE 3

#endif