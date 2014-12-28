#ifndef __DRIVER_H__
#define __DRIVER_H__

//TODO
typedef void* callback_t @combine("cbcombine");

callback_t cbcombine(callback_t a, callback_t b)
{
    if (a != NULL) return a; return b;
}

typedef uint32_t syscall_rv_t @combine("rvcombine");
syscall_rv_t rvcombine(syscall_rv_t a, syscall_rv_t b)
{
    return a | b;
}


#endif