generic module HalSam4lSPIChannelP()
{
    provides
    {
        interface SpiByte;
        interface FastSpiByte;
        //interface SpiPacket;
    }
    uses
    {
        interface HplSam4lSPIControl as ctl;
        interface HplSam4lSPIChannel as ch;
    }
}
implementation
{
    /**
	 * Starts a split-phase SPI data transfer with the given data.
	 * A splitRead/splitReadWrite command must follow this command even
	 * if the result is unimportant.
	 */
	async command void FastSpiByte.splitWrite(uint8_t data)
	{
	    while (!(call ctl.isTransmitDataEmpty()))
	    {
	        if (call ctl.isReceiveDataFull())
	        {
	            uint16_t dummy = call ctl.readRXReg();
	        }
	    }
	    call ch.writeTXReg(data, FALSE);
	}

	/**
	 * Finishes the split-phase SPI data transfer by waiting till
	 * the write command comletes and returning the received data.
	 */
	async command uint8_t FastSpiByte.splitRead()
	{
	    while (!call ctl.isReceiveDataFull());
	    return (uint8_t) call ctl.readRXReg();
	}

	/**
	 * This command first reads the SPI register and then writes
	 * there the new data, then returns.
	 */
	async command uint8_t FastSpiByte.splitReadWrite(uint8_t data)
	{
	    uint16_t rv;
	    while (!call ctl.isReceiveDataFull());
	    rv = call ctl.readRXReg();
	    call ch.writeTXReg(data, FALSE);
	    return rv;
	}

	/**
	 * This is the standard SpiByte.write command but a little
	 * faster as we should not need to adjust the power state there.
	 * (To be consistent, this command could have be named splitWriteRead).
	 */
	async command uint8_t FastSpiByte.write(uint8_t data)
	{
	    return call SpiByte.write(data);
	}

    /**
    * Synchronous transmit and receive (can be in interrupt context)
    * @param tx Byte to transmit
    * @param rx Received byte is stored here.
    */
    async command uint8_t SpiByte.write( uint8_t tx )
    {
        call ch.writeTXReg(tx, FALSE);
	    while (!call ctl.isReceiveDataFull());
	    return (uint8_t) call ctl.readRXReg();
    }
}
