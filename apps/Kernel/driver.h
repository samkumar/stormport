#ifndef __DRIVER_H__
#define __DRIVER_H__

//TODO
typedef struct
{
    uint32_t addr;
    void* r;
} callback_t;

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


#endif