#include "driver.h"
module SPIDriverP
{
    provides interface Driver;
    provides interface Init;
    uses interface HplSam4lUSART as SpiHPL;
    uses interface SpiPacket;
    uses interface GeneralIO as CS;
}
implementation
{
    uint8_t spi_busy = 0;
    uint8_t callback_pending = 0;
    simple_callback_t callback;

    command error_t Init.init()
    {
        spi_busy = 0;
        callback_pending = 0;
        return SUCCESS;
    }
    async command syscall_rv_t Driver.syscall_ex(
        uint32_t number, uint32_t arg0,
        uint32_t arg1, uint32_t arg2,
        uint32_t *argx)
    {
        switch(number & 0xFF)
        {
                       //      ar0   arg1    arg2     arx[0], argx[1]   argx[2]
            case 0x01: //set_CS (0/1)
            {
                call CS.makeOutput();
                if (arg0) {
                    call CS.set();
                } else {
                    call CS.clr();
                }
                return 0;
            }
            case 0x02: //init (mode, baudrate)
            {
                call SpiHPL.enableUSARTPin(USART0_RX_PB14);
                call SpiHPL.enableUSARTPin(USART0_TX_PB15);
                call SpiHPL.enableUSARTPin(USART0_CLK_PB13);
                call SpiHPL.initSPIMaster();
                call SpiHPL.setSPIMode((arg0>>1)&1,arg0&1);
                call SpiHPL.setSPIBaudRate(arg1);
                call SpiHPL.enableTX();
                call SpiHPL.enableRX();

                call CS.makeOutput();
                call CS.set();
                return 0;
            }
            case 0x03: //write (sendbuf, rxbuf, len, cb_addr, r)
            {
                if (spi_busy) return 1;
                spi_busy = 1;
                callback.addr = argx[0];
                callback.r = (void*) argx[1];
                call SpiPacket.send((uint8_t*) arg0, (uint8_t*) arg1, arg2);
                return 0;
            }
            break;
        }
    }
    async event void SpiPacket.sendDone(uint8_t* txBuf, uint8_t* rxBuf,
                                      uint16_t len, error_t error) {
        callback_pending = 1;
    }
    command driver_callback_t Driver.peek_callback()
    {
        if (callback_pending) {
            return (driver_callback_t)&callback;
        }
        return NULL;
    }
    command void Driver.pop_callback()
    {
        callback_pending = 0;
        spi_busy = 0;
    }
}