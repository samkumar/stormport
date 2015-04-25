#ifndef __MPU_HARDWARE_H__
#define __MPU_HARDWARE_H__

typedef union {
    uint32_t flat;
    struct {
        uint32_t enable         : 1;
        uint32_t size           : 5;
        uint32_t _reserved0     : 2;
        uint32_t subregiondis   : 8;

        uint32_t attr_b         : 1;
        uint32_t attr_c         : 1;
        uint32_t attr_s         : 1;
        uint32_t attr_tex       : 3;
        uint32_t _reserved1     : 2;

        uint32_t ap             : 3;
        uint32_t _reserved2     : 1;
        uint32_t xn             : 1;
        uint32_t _reserved3     : 3;
    } bits;
} mpu_rasr_t;

typedef union {
    uint32_t flat;
    struct {
        uint32_t region         : 4;
        uint32_t valid          : 1;
        uint32_t addr           : 27;
    } bits;
} mpu_rbar_t;

typedef union {
    uint32_t flat;
    struct {
        uint32_t enable         : 1;
        uint32_t hfnmiena       : 1;
        uint32_t privdefena     : 1;
        uint32_t _reserved0     : 29;
    } bits;
} mpu_ctrl_t;


mpu_ctrl_t volatile * const MPU_CTRL = (mpu_ctrl_t volatile *) 0xE000ED94;
mpu_rbar_t volatile * const MPU_RBAR = (mpu_rbar_t volatile *) 0xE000ED9C;
mpu_rasr_t volatile * const MPU_RASR = (mpu_rasr_t volatile *) 0xE000EDA0;
uint32_t volatile * const MPU_RNR = (uint32_t volatile *) 0xE000ED98;

#endif