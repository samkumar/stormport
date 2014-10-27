interface HplSam4lTWIM
{
    async command void init();
    async command error_t read (uint8_t flags, uint8_t addr, uint8_t *dst, uint8_t len);
    async command error_t write (uint8_t flags, uint8_t addr, uint8_t *src, uint8_t len);
    async event void writeDone(error_t stats, uint8_t *buf);
    async event void readDone(error_t stat, uint8_t *buf);
    async command void enablePins();
}