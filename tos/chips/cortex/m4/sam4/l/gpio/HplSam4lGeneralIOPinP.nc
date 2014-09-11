#include <gpiohardware.h>

generic module HplSam4lGeneralIOPinP(uint32_t address, uint8_t bit)
{
    provides
    {
        interface GeneralIO as IO;
    }
}
implementation
{
    async command bool IO.get()
	{
        //I think IO.get should return the value on the pin when driven,
        //not what we are driving it to. Email me if I am wrong.
        return ((gpio_port_t volatile *)(address))->pvr & (1<<bit) != 0;
	}

	async command void IO.set()
	{
        ((gpio_port_t volatile *)(address))->ovrs = 1<<bit;
	}

	async command void IO.clr()
	{
        ((gpio_port_t volatile *)(address))->ovrc = 1<<bit;
	}

	async command void IO.toggle()
	{
        ((gpio_port_t volatile *)(address))->ovrt = 1<<bit;
	}

	async command void IO.makeInput()
	{
        ((gpio_port_t volatile *)(address))->gpers = 1<<bit;
        ((gpio_port_t volatile *)(address))->oderc = 1<<bit;
    }

	async command void IO.makeOutput()
	{
        ((gpio_port_t volatile *)(address))->gpers = 1<<bit;
        ((gpio_port_t volatile *)(address))->oders = 1<<bit;
    }

	async command bool IO.isOutput()
	{
        return ((gpio_port_t volatile *)(address))->oder & (1<<bit) != 0;
	}

	async command bool IO.isInput()
	{
        return ((gpio_port_t volatile *)(address))->oder & (1<<bit) == 0;
	}
}