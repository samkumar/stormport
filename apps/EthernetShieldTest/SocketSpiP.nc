#include "printf.h"

// handles SPI communication
module SocketSpiP
{
    uses interface HplSam4lUSART as SpiHPL;
    uses interface SpiPacket;
    uses interface GeneralIO as EthernetSS;

    provides interface SocketSpi;
}
implementation
{
    bool ssd;
    uint8_t _rxbuf [260];

    //TODO: need to figure out how to wire this to boot or init for platform?
    // initializes SPI
    void init()
    {
        printf("Initializing Spi to talk to Wiz5200\n");
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

        //TODO: initialize internal state

    }

    // initialize
    // write to W5200 register
    command void SocketSpi.writeRegister(uint8_t reg_addr, uint8_t *buf, uint8_t len)
    {
        call EthernetSS.clr();
        ssd = 1;
        buf[0] = (uint8_t) (reg_addr >> 8); //network byte order
        buf[1] = (uint8_t) reg_addr;
        //Set top bit for write
        buf[2] = 0x80; //Len MSB is null
        buf[3] = len;
        // should copy contents of buf into the transmission buffer
        call SpiPacket.send(buf, _rxbuf, ((int)len) + 4);
    }

    // read from W5200 register
    command void SocketSpi.readRegister(uint8_t reg_addr, uint8_t *buf, uint8_t len)
    {
        uint16_t i;
        for (i = 0; i < len; i++)  buf[4+i] = 0;
        call EthernetSS.clr();
        ssd = 1;
        buf[0] = (uint8_t) (reg_addr >> 8); //network byte order
        buf[1] = (uint8_t) reg_addr;
        buf[2] = 0x00; //Clear top bit for read
        buf[3] = len;
        call SpiPacket.send(buf, _rxbuf, ((int)len) + 4);
    }


    async event void SpiPacket.sendDone(uint8_t* txBuf, uint8_t* rxBuf, uint16_t len, error_t error)
    {
        // finished sending spipacket
        signal SocketSpi.taskDone(error, rxBuf, len);
    }
}
