
generic module HplSam4lGeneralIOP(uint32_t address, uint8_t bit)
{
    provides
    {
        interface HplSam4lGeneralIO;
        interface GeneralIO as IO;
        interface GpioInterrupt as IRQ;
    }
    uses
    {
        interface HplSam4lGeneralIOPort;
        interface ByteIRQ;
    }

}
implementation
{
    #define PORT ((gpio_port_t volatile *)(address))
    enum {
        MASK = (1<<bit)
    };

    async command bool IO.get()
	{
        //I think IO.get should return the value on the pin when driven,
        //not what we are driving it to. Email me if I am wrong.
        return (PORT->pvr & MASK) != 0;
	}

	async command void IO.set()
	{
        PORT->ovrs = MASK;
	}

	async command void IO.clr()
	{
        PORT->ovrc = MASK;
	}

	async command void IO.toggle()
	{
        PORT->ovrt = MASK;
	}

	async command void IO.makeInput()
	{
        PORT->gpers = MASK;
        PORT->oderc = MASK;
        PORT->sters = MASK;
    }

	async command void IO.makeOutput()
	{
        PORT->gpers = MASK;
        PORT->oders = MASK;
        PORT->sterc = MASK;
    }

	async command bool IO.isOutput()
	{
        return (PORT->oder & MASK) != 0;
	}

	async command bool IO.isInput()
	{
        return (PORT->oder & MASK) == 0;
	}

    async command void HplSam4lGeneralIO.selectPeripheralA()
    {
        PORT->pmr0c = MASK;
        PORT->pmr1c = MASK;
        PORT->pmr2c = MASK;
        PORT->gperc = MASK;
    }
    async command void HplSam4lGeneralIO.selectPeripheralB()
    {
        PORT->pmr0s = MASK;
        PORT->pmr1c = MASK;
        PORT->pmr2c = MASK;
        PORT->gperc = MASK;
    }
    async command void HplSam4lGeneralIO.selectPeripheralC()
    {
        PORT->pmr0c = MASK;
        PORT->pmr1s = MASK;
        PORT->pmr2c = MASK;
        PORT->gperc = MASK;
    }
    async command void HplSam4lGeneralIO.selectPeripheralD()
    {
        PORT->pmr0s = MASK;
        PORT->pmr1s = MASK;
        PORT->pmr2c = MASK;
        PORT->gperc = MASK;
    }
    async command void HplSam4lGeneralIO.selectPeripheral(uint8_t i)
    {
        switch(i)
        {
            case 0: call HplSam4lGeneralIO.selectPeripheralA(); return;
            case 1: call HplSam4lGeneralIO.selectPeripheralB(); return;
            case 2: call HplSam4lGeneralIO.selectPeripheralC(); return;
            case 3: call HplSam4lGeneralIO.selectPeripheralD(); return;
        }
    }
    async command bool HplSam4lGeneralIO.getOVR()
    {
        return (PORT->ovr & MASK) != 0;
    }
    async command bool HplSam4lGeneralIO.getPVR()
    {
        return (PORT->pvr & MASK) != 0;
    }
    async command void HplSam4lGeneralIO.enablePullup()
    {
        PORT->puers = MASK;
    }
    async command void HplSam4lGeneralIO.disablePullup()
    {
        PORT->puerc = MASK;
    }
    async command void HplSam4lGeneralIO.enablePulldown()
    {
        PORT->pders = MASK;
    }
    async command void HplSam4lGeneralIO.disablePulldown()
    {
        PORT->pderc = MASK;
    }
    async command void HplSam4lGeneralIO.enableGlitchFilter()
    {
        PORT->gfers = MASK;
    }
    async command void HplSam4lGeneralIO.disableGlitchFilter()
    {
        PORT->gferc = MASK;
    }
    //As far as I can tell from the datasheet, only the LSB
    //is significant
    async command void HplSam4lGeneralIO.setHighDrive()
    {
        PORT->odcr0s = MASK;
        PORT->odcr1s = MASK;
    }
    async command void HplSam4lGeneralIO.setLowDrive()
    {
        PORT->odcr0c = MASK;
        PORT->odcr1c = MASK;
    }
    async command void HplSam4lGeneralIO.enableSlewControl()
    {
        PORT->osrr0s = MASK;
    }
    async command void HplSam4lGeneralIO.disableSlewControl()
    {
        PORT->osrr0c = MASK;
    }
    async command void HplSam4lGeneralIO.enableSchmittTrigger()
    {
        PORT->sters = MASK;
    }
    async command void HplSam4lGeneralIO.disableSchmittTrigger()
    {
        PORT->sterc = MASK;
    }
    async command void HplSam4lGeneralIO.enablePeripheralEvent()
    {
        PORT->evers = MASK;
    }
    async command void HplSam4lGeneralIO.disablePeripheralEvent()
    {
        PORT->everc = MASK;
    }
    async command void HplSam4lGeneralIO.enableIRQ()
    {
        call HplSam4lGeneralIOPort.enableIRQ(bit);
    }
    async command void HplSam4lGeneralIO.disableIRQ()
    {
        call HplSam4lGeneralIOPort.disableIRQ(bit);
    }
    async command void HplSam4lGeneralIO.setIRQEdgeAny()
    {
        PORT->imr0c = MASK;
        PORT->imr1c = MASK;
    }
    async command void HplSam4lGeneralIO.setIRQEdgeRising()
    {
        PORT->imr0s = MASK;
        PORT->imr1c = MASK;
    }
    async command void HplSam4lGeneralIO.setIRQEdgeFalling()
    {
        PORT->imr0c = MASK;
        PORT->imr1s = MASK;
    }
    async command void HplSam4lGeneralIO.clearIRQ()
    {
        PORT->ifrc = MASK;
    }
    async command error_t IRQ.enableRisingEdge()
    {
        PORT->imr0s = MASK;
        PORT->imr1c = MASK;
        call HplSam4lGeneralIOPort.enableIRQ(bit);
        return SUCCESS;
    }
    async command error_t IRQ.enableFallingEdge()
    {
        PORT->imr0c = MASK;
        PORT->imr1s = MASK;
        call HplSam4lGeneralIOPort.enableIRQ(bit);
        return SUCCESS;
    }
    async command error_t IRQ.disable()
    {
        call HplSam4lGeneralIOPort.disableIRQ(bit);
        return SUCCESS;
    }

    default async event void IRQ.fired(){}

    async event void ByteIRQ.fired()
    {
        if (PORT->ifr & PORT->ier & MASK)
        {
            PORT->ifrc = MASK;
            signal IRQ.fired();
        }
    }


}