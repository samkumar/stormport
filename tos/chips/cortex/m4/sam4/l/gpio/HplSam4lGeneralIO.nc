interface HplSam4lGeneralIO
{
    async command void selectPeripheralA();
    async command void selectPeripheralB();
    async command void selectPeripheralC();
    async command void selectPeripheralD();
    async command bool getOVR();
    async command bool getPVR();
    async command void enablePullup();
    async command void disablePullup();
    async command void enablePulldown();
    async command void disablePulldown();
    async command void enableGlitchFilter();
    async command void disableGlitchFilter();
    async command void setHighDrive();
    async command void setLowDrive();
    async command void enableSlewControl();
    async command void disableSlewControl();
    async command void enableSchmittTrigger();
    async command void disableSchmittTrigger();
    async command void enablePeripheralEvent();
    async command void disablePeripheralEvent();
    async command void enableIRQ();
    async command void disableIRQ();
    async command void setIRQEdgeAny();
    async command void setIRQEdgeRising();
    async command void setIRQEdgeFalling();
    async command void clearIRQ();
}