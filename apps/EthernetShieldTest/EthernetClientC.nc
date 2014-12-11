#include "printf.h"
#include <usarthardware.h>

module EthernetClientC
{
    uses interface Boot;
    uses interface HplSam4lUSART as SpiHPL;
    uses interface SpiPacket;
    uses interface GeneralIO as EthernetSS;
    uses interface GeneralIO as SDCardSS;
    uses interface Timer<T32khz> as Timer;
}
implementation
{

    enum
    {
        state_init,
        state_reset,
        state_check_presence2,
        state_check_presence,
        state_write,
        state_read,
        state_foo,
        state_bar
    } state;

    int write_idx;

    void check_presence();
    bool ssd;

    event void Boot.booted()
    {
        printf("Configuring SPI\n");

        call SDCardSS.makeOutput();
        call SDCardSS.set();
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

        state = state_init;
        call Timer.startOneShot(50000);


    }


    uint8_t _txbuf [260];
    uint8_t * const txbuf = &_txbuf[4];
    uint8_t _rxbuf [260];
    uint8_t * const rxbuf = &_rxbuf[4];
    //Caller should pre-populate txbuf with the data to be sent
    void writeEthAddress(uint16_t address, uint8_t len)
    {
        call EthernetSS.clr();
        ssd = 1;
        _txbuf[0] = (uint8_t) (address >> 8); //network byte order
        _txbuf[1] = (uint8_t) address;
        //Set top bit for write
        _txbuf[2] = 0x80; //Len MSB is null
        _txbuf[3] = len;
        call SpiPacket.send(_txbuf, _rxbuf, ((int)len) + 4);
    }
    void readEthAddress(uint16_t address, uint8_t len)
    {
        //some devices bork if dummy bytes are non-null
        uint16_t i;
        for (i = 0; i < len; i++)  _txbuf[4+i] = 0;
        call EthernetSS.clr();
        ssd = 1;
        _txbuf[0] = (uint8_t) (address >> 8); //network byte order
        _txbuf[1] = (uint8_t) address;
        _txbuf[2] = 0x00; //Clear top bit for read
        _txbuf[3] = len;
        call SpiPacket.send(_txbuf, _rxbuf, ((int)len) + 4);
    }

    task void switch_state()
    {
        if (ssd)
        {
            call EthernetSS.set();
            ssd = 0;
            call Timer.startOneShot(20);
            return;
        }
        switch(state)
        {
            case state_init:
                state = state_reset;
                txbuf[0] = 0x80;
                writeEthAddress(0x0000, 1);
                break;
            case state_reset:
                state = state_write;
                txbuf[0] = 0xde;
                txbuf[1] = 0xad;
                txbuf[2] = 0xbe;
                txbuf[3] = 0xef;
                txbuf[4] = 0xfe;
                txbuf[5] = 0xed;
                writeEthAddress(0x0009, 6);
                break;
            case state_write:
                state = state_check_presence;
                readEthAddress(0x0009, 6);
                break;
            case state_check_presence:
                state = state_check_presence2;
                readEthAddress(0x0009, 1);
                break;
            case state_check_presence2:
                if (*rxbuf != 0x03)
                    printf("ETHERNET SHIELD NOT DETECTED!! (Expected 0x03, got 0x%02x)\n",*rxbuf);
                else
                    printf("Ethernet shield detected (W5200)\n");
                //choose next state etc.
                break;
        }
    }
    event void Timer.fired()
    {
        post switch_state();
    }
    async event void SpiPacket.sendDone(uint8_t* txBuf, uint8_t* rxBuf, uint16_t len, error_t error)
    {
        //We don't want to do too much in IRQ context
        call Timer.startOneShot(20);

    }

}
