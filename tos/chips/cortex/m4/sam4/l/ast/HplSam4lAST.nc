#include <asthardware.h>

interface HplSam4lAST
{
	async command void enable()
	{
		AST->cr.en = 1;
	}

	async command void disable()
	{
		AST->cr.en = 0;
	}

	async command void setPrescalarBit(uint8_t bit)
	{
		AST->cr.psel = bit;
	}

	async command uint32_t getCounterValue()
	{
		return AST->cv;
	}

	async command void setCounterValue(uint32_t val)
	{
		AST->cv = val;
	}

	async command bool overflowed()
	{
		return AST->sr.ovf == 1;
	}

	async command void clearOverflowed()
	{
		AST->scr.ovf = 1;
	}

	async command bool alarm()
	{
		return AST->sr.alarm0 == 1;
	}

	async command void clearAlarm()
	{
		AST->scr.alarm0 = 1;
	}

	async command bool busy()
	{
		return AST->sr.busy == 1;
	}

	async command bool clkrdy()
	{
		return AST->sr.clkrdy == 1;
	}

	async command void clearClkrdy()
	{
		AST->scr.clkrdy = 1;
	}

	async command bool clkbusy()
	{
		return AST->sr.clkbusy == 1;
	}

	async command void enableOverflowIRQ()
	{
		AST->ier.ovf = 1;
	}

	async command void disableOverflowIRQ()
	{
		AST->idr.ovf = 1;
	}

	async command void enableAlarmIRQ()
	{
		AST->ier.alarm = 1;
	}

	async command void disableAlarmIRQ()
	{
		AST->idr.alarm = 1;
	}

	async command void enablePeriodIRQ()
	{
		AST->ier.per0 = 1;
	}

	async command void disablePeriodIRQ()
	{
		AST->idr.per0 = 1;
	}

	async command void enableOverflowWake()
	{
		AST->wen.ovf = 1;
	}

	async command void disableOverflowWake()
	{
		AST->wen.ovf = 0;
	}

	async command void enableAlarmWake()
	{
		AST->wen.alarm0 = 1;
	}

	async command void disableAlarmWake()
	{
		AST->wen.alarm0 = 0;
	}

	async command void enablePeriodWake()
	{
		AST->wen.per0 = 1;
	}

	async command void disablePeriodWake()
	{
		AST->wen.per0 = 0;
	}

	async command void setAlarm(uint32_t val)
	{
		AST->ar0 = val;
	}

	async command uint32_t getAlarm()
	{
		return AST->ar0;
	}

	async command void setPeriod(uint8_t val)
	{
		AST->per0 = val;
	}

	async command uint8_t getPeriod()
	{
		return AST->per0;
	}

	async command void selectClk_RCSYS()
	{
		//We have to wait for the clock to be changeable
		while(AST->sr.clkbusy == 1);
		AST->clock.bits.cen = 0;
		while(AST->sr.clkbusy == 1);
		AST->clock.bits.cssel = CSSEL_RCSYS;
		while(AST->sr.clkbusy == 1);
		AST->clock.bits.cen = 1;
		while(AST->sr.clkbusy == 1);
	}

	async command void selectClk_32khz()
	{
		//We have to wait for the clock to be changeable
		while(AST->sr.clkbusy == 1);
		AST->clock.bits.cen = 0;
		while(AST->sr.clkbusy == 1);
		AST->clock.bits.cssel = CSSEL_OSC32;
		while(AST->sr.clkbusy == 1);
		AST->clock.bits.cen = 1;
		while(AST->sr.clkbusy == 1);
	}

	async command void selectClk_APB()
	{
		//We have to wait for the clock to be changeable
		while(AST->sr.clkbusy == 1);
		AST->clock.bits.cen = 0;
		while(AST->sr.clkbusy == 1);
		AST->clock.bits.cssel = CSSEL_APB;
		while(AST->sr.clkbusy == 1);
		AST->clock.bits.cen = 1;
		while(AST->sr.clkbusy == 1);
	}

	async command void selectClk_GCLK2()
	{
		//We have to wait for the clock to be changeable
		while(AST->sr.clkbusy == 1);
		AST->clock.bits.cen = 0;
		while(AST->sr.clkbusy == 1);
		AST->clock.bits.cssel = CSSEL_GCLK2;
		while(AST->sr.clkbusy == 1);
		AST->clock.bits.cen = 1;
		while(AST->sr.clkbusy == 1);
	}

	async command void selectClk_1K()
	{
		//We have to wait for the clock to be changeable
		while(AST->sr.clkbusy == 1);
		AST->clock.bits.cen = 0;
		while(AST->sr.clkbusy == 1);
		AST->clock.bits.cssel = CSSEL_CLK1K;
		while(AST->sr.clkbusy == 1);
		AST->clock.bits.cen = 1;
		while(AST->sr.clkbusy == 1);
	}

}