#ifndef __DRIVER_H__
#define __DRIVER_H__

//TODO

typedef void* driver_callback_t;


typedef struct
{
    uint32_t addr;
    void *r;
} simple_callback_t;

typedef struct
{
    uint32_t addr;
    void *r;
    uint8_t* buffer;
    uint32_t buflen;
    uint8_t src_address [16];
    uint32_t port;
    uint8_t lqi;
    uint8_t rssi;
} __attribute__((__packed__)) udp_callback_t;

typedef struct
{
    uint32_t addr;
    void *r;
    uint32_t status;
} i2c_callback_t;

typedef struct
{
    uint32_t addr;
    void *r;
    uint32_t arg0;
    uint32_t arg1;
} ble_callback_t;

typedef uint32_t syscall_rv_t;
/*
typedef callback_t* pcallback_t @combine("cbcombine");

pcallback_t cbcombine(pcallback_t a, pcallback_t b)
{
    if (a != NULL) return a; return b;
}

typedef uint32_t syscall_rv_t @combine("rvcombine");
syscall_rv_t rvcombine(syscall_rv_t a, syscall_rv_t b)
{
    return a | b;
}
*/

#endif
