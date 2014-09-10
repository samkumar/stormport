#include <bpmhardware.h>

interface HplSam4lBPM
{
    async command void setSleepMode0();
    async command void setSleepMode1();
    async command void setSleepMode2();
    async command void setSleepMode3();
    async command void setDeepSleepRetention();
    async command void setDeepSleepBackup();
    async command void disableDeepSleep();
    async command void setPS(uint8_t ps);

    async command void select32kExternal();
    async command void select32kInternal();
}