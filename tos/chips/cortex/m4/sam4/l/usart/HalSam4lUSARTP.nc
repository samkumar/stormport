#include <usarthardware.h>
generic module HalSam4lUSARTP()
{
    provides
    {
        interface UartByte;
        interface UartControl;
        interface UartStream;
        interface SpiByte;
        interface FastSpiByte;
    }
    uses
    {
        interface HplSam4lUSART as usart;
        interface HplSam4lUSART_IRQ as usart_irq;
        interface HplSam4Clock as sysclock;
    }
}
implementation
{
    uint8_t norace *tx_buf = NULL;
    uint16_t norace tx_len;
    uint16_t norace tx_ptr;

    uint8_t norace *rx_buf = NULL;
    uint16_t norace rx_len;
    uint16_t norace rx_ptr;

    bool forwardRXIRQ = FALSE;

    async event void sysclock.mainClockChanged()
    {
        //probably important.
    }
    /**
    * Send a single uart byte. The call blocks until it is ready to
    * accept another byte for sending.
    *
    * @param byte The byte to send.
    * @return SUCCESS if byte was sent, FAIL otherwise.
    */
    async command error_t UartByte.send( uint8_t byte )
    {
        while (! call usart.isTXRdy());
        call usart.sendData(byte);
    }

    /**
    * Receive a single uart byte. The call blocks until a byte is
    * received.
    *
    * @param 'uint8_t* ONE byte' Where to place received byte.
    * @param timeout How long in byte times to wait.
    * @return SUCCESS if a byte was received, FAIL if timed out.
    */
    async command error_t UartByte.receive( uint8_t* byte, uint8_t timeout )
    {
        int32_t tgt, tmp, delta = 0;
        if (call usart.isRXRdy())
        {
            *byte = call usart.readData();
            return SUCCESS;
        }
        tgt = call sysclock.getSysTicks();
        if (tgt < (call sysclock.getSysTicks()>>1))
        {
            delta = call sysclock.getSysTicksWrapVal() >> 1;
        }
        tgt += delta;
        //timeout (ticks) = (ticks/sec) * bits / (bits/sec)
        tmp = call sysclock.getMainClockSpeed() * timeout * 8;
        tmp /= call usart.getUartBaudRate();
        tgt -= tmp;
        while ((call sysclock.getSysTicks() + delta) > tgt)
        {
            if (call usart.isRXRdy())
            {
                *byte = call usart.readData();
                return SUCCESS;
            }
        }
        return FAIL;
    }

    /** Set the UART speed for both reception and transmission.
    * This command should be called only when both reception
    * and transmission are disabled, either through a power interface
    * or setDuplexMode(). The parameter is a constant of the
    * form TOS_UART_XX, where XX is the speed, such as
    * TOS_UART_57600. Different platforms support different speeds.
    * A compilation error on the constant indicates the platform
    * does not support that speed.
    *
    *  @param speed The UART speed to change to.
    */
    async command error_t UartControl.setSpeed(uart_speed_t speed)
    {
        call usart.setUartBaudRate((uint32_t)speed);
        return SUCCESS;
    }

    /**
    * Returns the current UART speed.
    */
    async command uart_speed_t UartControl.speed()
    {
        return (uart_speed_t) call usart.getUartBaudRate();
    }

    /**
    * Set the duplex mode of the UART. Valid modes are
    * TOS_UART_OFF, TOS_UART_RONLY, TOS_UART_TONLY, and
    * TOS_UART_DUPLEX. Some platforms may support only
    * a subset of these modes: trying to use an unsupported
    * mode is a compile-time error. The duplex mode setting
    * affects what kinds of interrupts the UART will issue.
    *
    *  @param duplex The duplex mode to change to.
    */
    async command error_t UartControl.setDuplexMode(uart_duplex_t duplex)
    {
        switch (duplex)
        {
            case TOS_UART_OFF:
                call usart.disableRX();
                call usart.disableTX();
                break;
            case TOS_UART_RONLY:
                call usart.initUART();
                call usart.disableTX();
                call usart.enableRX();
                break;
            case TOS_UART_TONLY:
                call usart.initUART();
                call usart.enableTX();
                call usart.disableRX();
                break;
            case TOS_UART_DUPLEX:
                call usart.initUART();
                call usart.enableTX();
                call usart.enableRX();
                break;
        }
        return SUCCESS;
    }

    /**
    * Return the current duplex mode.
    */
    async command uart_duplex_t UartControl.duplexMode()
    {
        //meh
        return TOS_UART_DUPLEX;
    }

    /**
    * Set whether UART bytes have even parity bits, odd
    * parity bits, or no parity bits. This command should
    * only be called when both the receive and transmit paths
    * are disabled, either through a power control interface
    * or setDuplexMode. Valid parity settings are
    * TOS_UART_PARITY_NONE, TOS_UART_PARITY_EVEN,
    * and TOS_UART_PARITY_ODD.
    *
    *  @param parity The parity mode to change to.
    */

    async command error_t UartControl.setParity(uart_parity_t parity)
    {
        switch(parity)
        {
            case TOS_UART_PARITY_NONE:
                call usart.selectNoParity();
                break;
            case TOS_UART_PARITY_EVEN:
                call usart.selectEvenParity();
                break;
            case TOS_UART_PARITY_ODD:
                call usart.selectOddParity();
                break;
        }
        return SUCCESS;
    }

    /**
    * Return the current parity mode.
    */
    async command uart_parity_t UartControl.parity()
    {
        //meh
        return TOS_UART_PARITY_NONE;
    }

    /**
    * Enable stop bits. This command should only be called
    * when both the receive and transmits paths are disabled,
    * either through a power control interface or setDuplexMode.
    */
    async command error_t UartControl.setStop()
    {
        return SUCCESS;
    }

    /**
    * Disable stop bits. This command should only be called
    * when both the receive and transmits paths are disabled,
    * either through a power control interface or setDuplexMode.
    */
    async command error_t UartControl.setNoStop()
    {
        return SUCCESS;
    }

    /**
    * Returns whether stop bits are enabled.
    */
    async command bool UartControl.stopBits()
    {
        return FALSE;
    }



    /**
    * Begin transmission of a UART stream. If SUCCESS is returned,
    * <code>sendDone</code> will be signalled when transmission is
    * complete.
    *
    * @param 'uint8_t* COUNT(len) buf' Buffer for bytes to send.
    * @param len Number of bytes to send.
    * @return SUCCESS if request was accepted, FAIL otherwise.
    */
    async command error_t UartStream.send( uint8_t* buf, uint16_t len )
    {
        if (tx_buf != NULL)
        {
            return FAIL;
        }
        tx_buf = buf;
        tx_len = len;
        tx_ptr = 0;
        call usart_irq.enableTXRdyIRQ();
    }

    /**
    * Signal completion of sending a stream.
    *
    * @param 'uint8_t* COUNT(len) buf' Bytes sent.
    * @param len Number of bytes sent.
    * @param error SUCCESS if the transmission was successful, FAIL otherwise.
    */
    //async event void sendDone( uint8_t* buf, uint16_t len, error_t error );

    /**
    * Enable the receive byte interrupt. The <code>receive</code> event
    * is signalled each time a byte is received.
    *
    * @return SUCCESS if interrupt was enabled, FAIL otherwise.
    */
    async command error_t UartStream.enableReceiveInterrupt()
    {
        forwardRXIRQ = TRUE;
        call usart_irq.enableRXRdyIRQ();
    }


    /**
    * Disable the receive byte interrupt.
    *
    * @return SUCCESS if interrupt was disabled, FAIL otherwise.
    */
    async command error_t UartStream.disableReceiveInterrupt()
    {
        forwardRXIRQ = FALSE;
    }

    /**
    * Begin reception of a UART stream. If SUCCESS is returned,
    * <code>receiveDone</code> will be signalled when reception is
    * complete.
    *
    * @param 'uint8_t* COUNT(len) buf' Buffer for received bytes.
    * @param len Number of bytes to receive.
    * @return SUCCESS if request was accepted, FAIL otherwise.
    */
    async command error_t UartStream.receive( uint8_t* buf, uint16_t len )
    {
        if (rx_buf != NULL)
        {
            return FAIL;
        }
        rx_buf = buf;
        rx_len = len;
        rx_ptr = 0;

    }

    async event void usart_irq.RXRdyFired()
    {
        uint8_t data = call usart.readData();
        if (forwardRXIRQ)
        {
            signal UartStream.receivedByte(data);
        }
        if (rx_buf != NULL)
        {
            rx_buf[rx_ptr++] = data;
            if (rx_ptr == rx_len)
            {
                uint8_t *bufcpy = rx_buf;
                uint8_t rx_ptr_cpy = rx_ptr;
                rx_buf = NULL;

                signal UartStream.receiveDone(bufcpy, rx_ptr_cpy, SUCCESS);
            }
        }
    }

    default async event void UartStream.sendDone( uint8_t* buf, uint16_t len, error_t error ){}
    default async event void UartStream.receiveDone( uint8_t* buf, uint16_t len, error_t error ){}
    default async event void UartStream.receivedByte( uint8_t byte ){}

    async event void usart_irq.TXRdyFired()
    {
        if (tx_buf == NULL)
        {
            call usart_irq.disableTXRdyIRQ();
            return;
        }
        atomic
        {

            call usart.sendData(tx_buf[tx_ptr++]);
            if (tx_ptr == tx_len)
            {
                uint8_t * bufcpy;
                bufcpy = tx_buf;
                tx_buf = NULL;
                call usart_irq.disableTXRdyIRQ();
                signal UartStream.sendDone(bufcpy, tx_ptr, SUCCESS);
            }
        }
    }

    /**
	 * Starts a split-phase SPI data transfer with the given data.
	 * A splitRead/splitReadWrite command must follow this command even
	 * if the result is unimportant.
	 */
	async command void FastSpiByte.splitWrite(uint8_t data)
	{
	    while (!call usart.isTXRdy());
        call usart.sendData(data);
	}

	/**
	 * Finishes the split-phase SPI data transfer by waiting till
	 * the write command comletes and returning the received data.
	 */
	async command uint8_t FastSpiByte.splitRead()
	{
	    while (!call usart.isRXRdy());
	    return call usart.readData();
	}

	/**
	 * This command first reads the SPI register and then writes
	 * there the new data, then returns.
	 */
	async command uint8_t FastSpiByte.splitReadWrite(uint8_t data)
	{
	    uint8_t rv;
	    while (!call usart.isRXRdy());
	    rv = call usart.readData();
	    while (!call usart.isTXRdy());
        call usart.sendData(data);
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
        while (!call usart.isTXRdy());
        call usart.sendData(tx);
        while (!call usart.isRXRdy());
        return call usart.readData();
    }

}