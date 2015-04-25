
#include "mpu_hardware.h"

module HplCortexM4MPUP
{
    provides interface HplCortexM4MPU;
}
implementation
{
    async command void HplCortexM4MPU.disableMPU()
    {
        mpu_ctrl_t cmd;
        cmd.bits.enable = 0;
        cmd.bits.hfnmiena = 0;
        cmd.bits.privdefena = 1;
        //int write is atomic
        MPU_CTRL->flat = cmd.flat;
    }
    async command void HplCortexM4MPU.enableMPU()
    {
        volatile uint32_t *shcsr = (volatile uint32_t *) 0xE000ED24;
        mpu_ctrl_t cmd;
        cmd.bits.enable = 1;
        cmd.bits.hfnmiena = 0;
        cmd.bits.privdefena = 1;

        atomic {
            *shcsr |= (1<<16); //enable memmanage fault
        }
        //int write is atomic
        MPU_CTRL->flat = cmd.flat;
    }
    async command void HplCortexM4MPU.configRegion(uint8_t num, uint32_t address, uint8_t logsize, uint8_t subreg, bool peripheral, bool protected)
    {
        mpu_rasr_t rasr;
        mpu_rbar_t rbar;
        rasr.bits.xn = 0;
        rasr.bits.ap = protected ? 0b010 : 0b011;
        rasr.bits.attr_tex = 0b000;
        rasr.bits.attr_b = peripheral ? 1 : 0;
        rasr.bits.attr_c = 0;//peripheral ? 0 : 1;
        rasr.bits.attr_s = 1;
        rasr.bits.size = logsize -1;
        rasr.bits.subregiondis = subreg;
        rasr.bits.enable = 1;
        rbar.bits.addr = address >> 5;
        rbar.bits.region = num;
        rbar.bits.valid = 1;
        atomic
        {
            //We are only using mpu to control payload, and we are not the payload
            //so we don't need to worry about behaviour in between writes of the two
            //config words
            *MPU_RNR = num;
            MPU_RBAR->flat = rbar.flat;
            MPU_RASR->flat = rasr.flat;
        }
    }

    void MemManage_Handler() @C() @spontaneous()
    {
        uint32_t addr = *((volatile uint32_t *) (0xE000ED34));
        printf("Segmentation fault\n");
        printf("MMFSR 0x%02x\n", *((volatile uint8_t *) (0xE000ED28)));
        printf("ADDR 0x%04x%04x\n", (addr>>16)&0xFFFF, addr&0xFFFF);
        while(1);
    }
}