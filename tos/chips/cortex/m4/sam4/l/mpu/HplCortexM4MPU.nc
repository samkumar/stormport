interface HplCortexM4MPU {
    async command void disableMPU();
    async command void enableMPU();
    async command void configRegion(uint8_t num, uint32_t address, uint8_t logsize, uint8_t subreg, bool peripheral, bool protected);
}