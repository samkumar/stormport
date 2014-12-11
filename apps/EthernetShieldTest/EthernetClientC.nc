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
        state_bar,
        state_write_ipaddress,
        state_write_gatewayip,
        state_write_subnetmask,
        state_initialize_sockets_tx,
        state_initialize_sockets_rx,
        state_finished
    } state;

    int write_idx = 0; // use this to loop writes (see state_initialize_sockets_{tx,rx})

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

    const uint16_t TXBUF_SIZE = 2048;
    const uint16_t RXBUF_SIZE = 2048;
    const uint16_t TXBUF_BASE = 0x8000;
    const uint16_t RXBUF_BASE = 0xC000;

    uint16_t TXBASE[8];
    uint16_t RXBASE[8];

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
        uint8_t idx;

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
                writeEthAddress(0x0000, 1); // Reset the chip by writing RST to the mode register
                break;
            case state_reset:
                state = state_write_ipaddress;
                // the following 6 bytes are the MAC address
                // DE:AD:BE:EF:FE:ED
                txbuf[0] = 0xde;
                txbuf[1] = 0xad;
                txbuf[2] = 0xbe;
                txbuf[3] = 0xef;
                txbuf[4] = 0xfe;
                txbuf[5] = 0xed;
                writeEthAddress(0x0009, 6);
                printf("Wrote MAC address\n");
                break;
            case state_write_ipaddress:
                // the following 4 bytes are the IP address of the Ethernet shield
                // SIBR: 192.168.1.177
                txbuf[0] = 0xc0;
                txbuf[1] = 0xa8;
                txbuf[2] = 0x01;
                txbuf[3] = 0xb1;
                writeEthAddress(0x000F, 4);
                printf("Wrote IP address\n");
                state = state_write_gatewayip;
                break;
            case state_write_gatewayip:
                // the following 4 bytes are the gateway IP address GAR: 192.168.1.1
                txbuf[0] = 0xc0;
                txbuf[1] = 0xa8;
                txbuf[2] = 0x01;
                txbuf[3] = 0x01;
                writeEthAddress(0x0001, 4);
                printf("Wrote gateway ip\n");
                state = state_write_subnetmask;
                break;
            case state_write_subnetmask:
                // following 4 bytes are the subnetmask SUBR: 255.255.255.0
                txbuf[0] = 0xff;
                txbuf[1] = 0xff;
                txbuf[2] = 0xff;
                txbuf[3] = 0x00;
                writeEthAddress(0x0005, 4);
                printf("Wrote subnet mask\n");
                state = state_initialize_sockets_tx;
                break;
            case state_initialize_sockets_tx:
                // writes 0x2 to each of 0x4n1F where n = 0..7 for W5200
                txbuf[0] = 0x2;
                writeEthAddress(0x4000 + write_idx * 0x100 + 0x001F, 1);
                write_idx += 1;
                if (write_idx == 8) { // means we are done
                    write_idx = 0;
                    state = state_initialize_sockets_rx;
                    printf("Initialized TX sockets\n");
                }
                break;
            case state_initialize_sockets_rx:
                // writes 0x2 to each of 0x4n1F where n = 0..7 for W5200
                txbuf[0] = 0x2;
                writeEthAddress(0x4000 + write_idx * 0x100 + 0x001E, 1);
                write_idx += 1;
                if (write_idx == 8) { // means we are done
                    write_idx = 0;
                    state = state_finished;
                    printf("Initialized RX sockets\n");
                }
                break;
            case state_finished:
                for (idx=0; idx<8; idx++) {
                    TXBASE[idx] = TXBUF_BASE + TXBUF_SIZE * idx;
                    RXBASE[idx] = RXBUF_BASE + RXBUF_SIZE * idx;
                }
                printf("Finished initialization\n");
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
