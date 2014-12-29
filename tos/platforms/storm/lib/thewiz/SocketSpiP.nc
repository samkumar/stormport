#include "printf.h"

// handles SPI communication
module SocketSpiP
{
    uses interface HplSam4lUSART as SpiHPL;
    uses interface SpiPacket;
    uses interface GeneralIO as EthernetSS;
    uses interface Timer<T32khz>;

    provides interface SocketSpi;
    provides interface Init;
}
implementation
{
    bool ssd;
    uint8_t _rxbuf [260];
    uint8_t txbuf[260];
    volatile norace uint8_t len;

    // initializes SPI
    command error_t Init.init()
    {
#ifndef BLIP_STFU
        printf("Initializing Spi to talk to Wiz5200\n");
#endif
        call EthernetSS.makeOutput();
        call EthernetSS.set();
        call SpiHPL.enableUSARTPin(USART0_CLK_PB13);
        call SpiHPL.enableUSARTPin(USART0_RX_PB14);
        call SpiHPL.enableUSARTPin(USART0_TX_PB15);
        call SpiHPL.initSPIMaster();
        call SpiHPL.setSPIMode(0,0);
        call SpiHPL.setSPIBaudRate(20000);
        call SpiHPL.enableTX();
        call SpiHPL.enableRX();
    }

    // initialize
    // write to W5200 register
    command void SocketSpi.writeRegister(uint16_t reg_addr, uint8_t *buf, uint8_t _len)
    {
        call EthernetSS.clr();
        ssd = 1;
        buf[0] = (uint8_t) (reg_addr >> 8); //network byte order
        buf[1] = (uint8_t) reg_addr;
        //Set top bit for write
        buf[2] = 0x80; //Len MSB is null
        buf[3] = _len;
        len = _len+4;
        // should copy contents of buf into the transmission buffer
        call SpiPacket.send(buf, _rxbuf, ((int)_len) + 4);
    }

    // read from W5200 register
    command void SocketSpi.readRegister(uint16_t reg_addr, uint8_t *buf, uint8_t _len)
    {
        uint16_t i;
        for (i = 0; i < 256; i++)  txbuf[4+i] = 0;
        call EthernetSS.clr();
        ssd = 1;
        txbuf[0] = (uint8_t) (reg_addr >> 8); //network byte order
        txbuf[1] = (uint8_t) reg_addr;
        txbuf[2] = 0x00; //Clear top bit for read
        txbuf[3] = _len;
        len = _len+4;
        call SpiPacket.send(txbuf, _rxbuf, ((int)_len) + 4);
    }

    event void Timer.fired()
    {
        call EthernetSS.set();
        signal SocketSpi.taskDone(SUCCESS, &_rxbuf[4], len-4);
    }

    void task startTimerOneShot()
    {
        call Timer.startOneShot(1);
    }


    async event void SpiPacket.sendDone(uint8_t* txBuf, uint8_t* rxBuf, uint16_t _len, error_t error)
    {
        // finished sending spipacket
        post startTimerOneShot();
    }
}
