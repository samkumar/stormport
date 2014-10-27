interface FSAccelerometer
{
    async command uint16_t getAccelX();
    async command uint16_t getAccelY();
    async command uint16_t getAccelZ();
    async command uint16_t getMagnX();
    async command uint16_t getMagnY();
    async command uint16_t getMagnZ();
}