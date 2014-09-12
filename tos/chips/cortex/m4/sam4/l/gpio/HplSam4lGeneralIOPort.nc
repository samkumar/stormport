interface HplSam4lGeneralIOPort
{
    async command void enable();
    async command void disable();
    async command void enableIRQ(uint8_t pin);
    async command void disableIRQ(uint8_t pin);
}
