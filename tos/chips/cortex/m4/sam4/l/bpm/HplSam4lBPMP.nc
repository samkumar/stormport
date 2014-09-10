
#include <bpmhardware.h>

module HplSam4lBPMP
{
    provides interface HplSam4lBPM;
}
implementation
{
    async command void HplSam4lBPM.setSleepMode0()
    {
        BPM->unlock = BPM_UNLOCK_KEY | BPM_PMCON_OFFSET;
        BPM->pmcon.bits.sleep = 0;
    }
    async command void HplSam4lBPM.setSleepMode1()
    {
        BPM->unlock = BPM_UNLOCK_KEY | BPM_PMCON_OFFSET;
        BPM->pmcon.bits.sleep = 1;
    }
    async command void HplSam4lBPM.setSleepMode2()
    {
        BPM->unlock = BPM_UNLOCK_KEY | BPM_PMCON_OFFSET;
        BPM->pmcon.bits.sleep = 2;
    }
    async command void HplSam4lBPM.setSleepMode3()
    {
        BPM->unlock = BPM_UNLOCK_KEY | BPM_PMCON_OFFSET;
        BPM->pmcon.bits.sleep = 3;
    }
    //XTAG we also need to map the SCR/SCB SLEEPDEEP bit
    async command void HplSam4lBPM.setDeepSleepRetention()
    {
        bpm_pmcon_t shadow = BPM->pmcon;
        shadow.bits.ret = 1;
        shadow.bits.bkup = 0;
        BPM->unlock = BPM_UNLOCK_KEY | BPM_PMCON_OFFSET;
        BPM->pmcon = shadow;
    }
    async command void HplSam4lBPM.setDeepSleepBackup()
    {

    }
    async command void HplSam4lBPM.disableDeepSleep()
    {

    }
    async command void HplSam4lBPM.setPS(uint8_t ps)
    {

    }

    async command void HplSam4lBPM.select32kExternal()
    {
        BPM->unlock = BPM_UNLOCK_KEY | BPM_PMCON_OFFSET;
        BPM->pmcon.bits.clk32s = CK32S_OSCK32K;

    }
    async command void HplSam4lBPM.select32kInternal()
    {
        BPM->unlock = BPM_UNLOCK_KEY | BPM_PMCON_OFFSET;
        BPM->pmcon.bits.clk32s = CK32S_RC32K;
    }
}