#include <usarthardware.h>
generic module HalSam4lUSARTP()
{
    provides
    {
        interface UartByte;
        interface UartControl;
        interface UartStream;
    }
    uses
    {
        interface HplSam4lUSART_UART as uart;
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
        while (! call uart.isTXRdy());
        call uart.sendData(byte);
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
        if (call uart.isRXRdy())
        {
            *byte = call uart.readData();
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
        tmp /= call uart.getBaudRate();
        tgt -= tmp;
        while ((call sysclock.getSysTicks() + delta) > tgt)
        {
            if (call uart.isRXRdy())
            {
                *byte = call uart.readData();
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
        call uart.setBaudRate((uint32_t)speed);
        return SUCCESS;
    }

    /**
    * Returns the current UART speed.
    */
    async command uart_speed_t UartControl.speed()
    {
        return (uart_speed_t) call uart.getBaudRate();
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
                call uart.disableRX();
                call uart.disableTX();
                break;
            case TOS_UART_RONLY:
                call uart.init();
                call uart.disableTX();
                call uart.enableRX();
                break;
            case TOS_UART_TONLY:
                call uart.init();
                call uart.enableTX();
                call uart.disableRX();
                break;
            case TOS_UART_DUPLEX:
                call uart.init();
                call uart.enableTX();
                call uart.enableRX();
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
                call uart.selectNoParity();
                break;
            case TOS_UART_PARITY_EVEN:
                call uart.selectEvenParity();
                break;
            case TOS_UART_PARITY_ODD:
                call uart.selectOddParity();
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
        call uart.enableTXRdyIRQ();
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
        call uart.enableRXRdyIRQ();
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

    async event void uart.RXRdyFired()
    {
        uint8_t data = call uart.readData();
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

    async event void uart.TXRdyFired()
    {
        if (tx_buf == NULL)
        {
            call uart.disableTXRdyIRQ();
            return;
        }
        atomic
        {

            call uart.sendData(tx_buf[tx_ptr++]);
            if (tx_ptr == tx_len)
            {
                uint8_t * bufcpy;
                bufcpy = tx_buf;
                tx_buf = NULL;
                call uart.disableTXRdyIRQ();
                signal UartStream.sendDone(bufcpy, tx_ptr, SUCCESS);
            }
        }
    }


}