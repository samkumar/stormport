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
    // socket modes
    typedef enum
    {
        SocketMode_CLOSE  = 0x00,
        SocketMode_TCP    = 0x01,
        SocketMode_UDP    = 0x02,
        SocketMode_IPRAW  = 0x03,
        SocketMode_MACRAW = 0x04,
        SocketMode_PPPOE  = 0x05
    } SocketMode;

    // socket states
    typedef enum
    {
        SocketState_CLOSED      = 0x00,
        SocketState_INIT        = 0x13,
        SocketState_LISTEN      = 0x14,
        SocketState_SYNSENT     = 0x15,
        SocketState_SYNRECV     = 0x16,
        SocketState_ESTABLISHED = 0x17,
        SocketState_FIN_WAIT    = 0x18,
        SocketState_CLOSING     = 0x1A,
        SocketState_TIME_WAIT   = 0x1B,
        SocketState_CLOSE_WAIT  = 0x1C,
        SocketState_LAST_ACK    = 0x1D,
        SocketState_UDP         = 0x22,
        SocketState_IPRAW       = 0x32,
        SocketState_MACRAW      = 0x42,
        SocketState_PPPOE       = 0x5F
    } SocketState;

    // socket commands
    typedef enum
    {
        SocketCommand_OPEN      = 0x01,
        SocketCommand_LISTEN    = 0x02,
        SocketCommand_CONNECT   = 0x04,
        SocketCommand_DISCON    = 0x08,
        SocketCommand_CLOSE     = 0x10,
        SocketCommand_SEND      = 0x20,
        SocketCommand_SEND_MAC  = 0x21,
        SocketCommand_SEND_KEEP = 0x22,
        SocketCommand_RECV      = 0x40
    } SocketCommand;

    // this enum governs which state the whole process is in
    enum
    {
        state_initialize,
        state_connect,
        state_writeUDP
    } processstate;

    enum
    {
        state_init,
        state_reset,
        state_write,
        state_read,
        state_foo,
        state_bar,
        state_write_ipaddress,
        state_write_gatewayip,
        state_write_subnetmask,
        state_initialize_sockets_tx,
        state_initialize_sockets_rx,
        state_initialize_txwr_txrd,
        state_finished_init,

        // state_connect states
        state_connect_init,
        state_connect_write_protocol,
        state_connect_write_src_port,
        state_connect_open_src_port,
        state_connect_wait_src_port_opened,
        state_connect_write_dst_ipaddress,
        state_connect_write_dst_port,
        state_connect_connect_dst,
        state_connect_wait_connect_dst,
        state_connect_wait_established,

        // writing UDP data
        state_writeudp_readtxwr,
        state_writeudp_copytotxbuf,
        state_writeudp_advancetxwr,
        state_writeudp_writesendcmd,
        state_writeudp_waitsendinterrupt,
        state_writeudp_clearsend,
        state_writeudp_cleartimeout,
        state_writeudp_waitsendcomplete,
        state_writeudp_sleep
    } state;

    int write_idx = 0; // use this to loop writes (see state_initialize_sockets_{tx,rx})
    int8_t socket_idx = -1;
    uint8_t socket;
    uint16_t ptr;
    uint16_t data_offset = 0;

    uint16_t srcport = 1024; // default connect from src port 1024
    uint16_t dstport = 7000; // default connect to dest port 7000

    // connect to UDP for testing
    SocketMode socketmode = SocketMode_UDP;

    void check_presence();
    bool ssd;
    int tryonce = 100;

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
        processstate = state_initialize;
        call Timer.startOneShot(50000);


    }

    const uint16_t TXBUF_SIZE = 2048;
    const uint16_t RXBUF_SIZE = 2048;
    const uint16_t TXBUF_BASE = 0x8000;
    const uint16_t RXBUF_BASE = 0xC000;
    const uint16_t TXMASK = 0x07FF;
    const uint16_t RXMASK = 0x07FF;

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
                    state = state_initialize_txwr_txrd;
                    printf("Initialized RX sockets\n");
                }
                break;
            case state_initialize_txwr_txrd:
                txbuf[0] = 0x0;
                txbuf[1] = 0x0;
                txbuf[2] = 0x0;
                txbuf[3] = 0x0;
                writeEthAddress(0x4000 + 0x0022, 4); //TODO: do this for each socket
                state = state_finished_init;
                break;
            case state_finished_init:
                for (idx=0; idx<8; idx++) {
                    TXBASE[idx] = TXBUF_BASE + TXBUF_SIZE * idx;
                    RXBASE[idx] = RXBUF_BASE + RXBUF_SIZE * idx;
                }
                // change process state
                processstate = state_connect;
                state = state_connect_init;
                printf("Finished initialization\n");
                call Timer.startOneShot(20); // use to advance the timer
                break;
            default:
                printf("ILLEGAL STATE in init process: %d\n", (int)state);
                break;
        }
    }

    task void connect()
    {
        uint16_t idx;
        if (ssd)
        {
            call EthernetSS.set();
            ssd = 0;
            call Timer.startOneShot(20);
            return;
        }

        switch(state)
        {
            case state_connect_init:
                if ((socket_idx > -1) && (*rxbuf == SocketState_CLOSED || *rxbuf == SocketState_FIN_WAIT || *rxbuf == SocketState_CLOSE_WAIT))
                {
                    socket = socket_idx;
                    state = state_connect_write_protocol;
                    printf("Chose socket %d\n", socket);
                    post connect();
                    break;
                }
                socket_idx += 1;
                // check each of the available to sockets to see if we can use it
                readEthAddress(0x4000 + socket_idx * 0x100 + 0x0003, 1);

                if (socket_idx == 8) //couldn't find an open socket
                {
                    printf("No open socket found\n");
                }
                break;

            case state_connect_write_protocol:
                // write our chosen protocol to the correct socket mode register
                txbuf[0] = socketmode | 0;
                writeEthAddress(0x4000 + socket * 0x100, 1); // write to SnMR
                printf("Wrote protocol %d to socket %d\n", (int)socketmode, socket);
                state = state_connect_write_src_port;
                break;

            case state_connect_write_src_port:
                // write the source port to SnPORT
                txbuf[0] = (srcport >> 8);
                txbuf[1] = srcport & 0xff;
                writeEthAddress(0x4000 + socket * 0x100 + 0x0004, 2); // write to SnPORT
                printf("Wrote srcport %d to SnPORT\n", (int)srcport);
                state = state_connect_open_src_port;
                break;

            case state_connect_open_src_port:
                // open the port
                txbuf[0] = SocketCommand_OPEN;
                writeEthAddress(0x4000 + socket * 0x100 + 0x0001, 1); // write to SnCR
                printf("Wrote OPEN to SnCR\n");
                state = state_connect_wait_src_port_opened;
                break;

            case state_connect_wait_src_port_opened:
                readEthAddress(0x4000 + socket * 0x100 + 0x0001, 1);
                if (*rxbuf) {
                    printf("Waiting for srcport to open: 0x%02x\n", *rxbuf);
                } else {
                    //continue
                    printf("opened srcport\n");
                    state = state_connect_write_dst_ipaddress;
                }
                break;

            case state_connect_write_dst_ipaddress:
                // 192.168.1.178
                txbuf[0] = 0xc0;
                txbuf[1] = 0xa8;
                txbuf[2] = 0x01;
                txbuf[3] = 0xb2;
                writeEthAddress(0x4000 + socket * 0x100 + 0x000C, 4); // write to SnDIPR
                printf("Write dst address to SnDIPR\n");
                state = state_connect_write_dst_port;
                break;

            case state_connect_write_dst_port:
                // port 7000
                txbuf[0] = (dstport >> 8);
                txbuf[1] = dstport & 0xff;
                writeEthAddress(0x4000 + socket * 0x100 + 0x0010, 2);
                printf("Write dst port to SnDPORT\n");
                state = state_connect_wait_established;
                break;

            case state_connect_wait_established:
                readEthAddress(0x4000 + socket * 0x100 + 0x0003, 1);
                if (*rxbuf == SocketState_UDP) {
                    printf("status is 0x%02x\n", *rxbuf);
                    processstate = state_writeUDP;
                    state = state_writeudp_readtxwr;
                } else {
                    printf("status is 0x%02x\n", *rxbuf);
                }
                break;

        }
    }

    task void writeUDP()
    {

        uint16_t offset;
        switch(state)
        {
            // read where we are in the circular tx buffer
            case state_writeudp_readtxwr:
                readEthAddress(0x4000 + socket * 0x100 + 0x0024, 2);
                // "user should read upper byte first and lower byte later to get proper value"
                //ptr = ((uint16_t)rxbuf[0] << 8) | rxbuf[1];
                printf("reading out ptr from TX_WR: %u\n", ptr);
                state = state_writeudp_copytotxbuf;
                break;

            // copy the dat we want to write to the tx buffer
            case state_writeudp_copytotxbuf:
                txbuf[0] = 0x68;
                txbuf[1] = 0x65;
                txbuf[2] = 0x6c;
                txbuf[3] = 0x6c;
                txbuf[4] = 0x6f;
                writeEthAddress(TXBASE[socket] + (ptr & TXMASK), 5);
                state = state_writeudp_advancetxwr;
                printf("Writing 5 bytes of 'hello' to TXBASE[socket]\n");
                break;

            // advance the circular tx buffer by how much we wrote
            case state_writeudp_advancetxwr:
                ptr += 5; // here, 5 is the number of bytes we wrote in state_writeudp_copytotxbuf
                txbuf[0] = (ptr >> 8);
                txbuf[1] = ptr & 0xff;
                printf("reading out ptr after write from TX_WR: %u\n", ptr);
                writeEthAddress(0x4000 + socket * 0x100 + 0x0024, 2);
                state = state_writeudp_writesendcmd;
                break;

            // tell the W5200 chip to send data in tx buf
            case state_writeudp_writesendcmd:
                txbuf[0] = SocketCommand_SEND;
                writeEthAddress(0x4000 + socket * 0x100 + 0x0001, 1);
                printf("Sending SEND command\n");
                state = state_writeudp_waitsendcomplete;
                break;

            // wait until the chip has sent data
            case state_writeudp_waitsendcomplete:
                readEthAddress(0x4000 + socket * 0x100 + 0x0001, 1);
                if (*rxbuf) {
                    printf("Waiting for SEND to complete\n");
                } else {
                    //continue
                    printf("SEND completed\n");
                    state = state_writeudp_waitsendinterrupt;
                }
                break;

            // wait for an interrupt so we can tell what happened
            case state_writeudp_waitsendinterrupt:
                // read interrupt register
                readEthAddress(0x4000 + socket * 0x100 + 0x0002, 1);
                if (*rxbuf) printf("interrupt register is 0x%02x\n", *rxbuf);
                if ((*rxbuf & 0x10) != 0x10 ) { // true if SEND_OK has not completed
                    if (*rxbuf & 0x08) { // true if TIMEOUT
                        printf("timeout on send\n");
                        state = state_writeudp_cleartimeout; // clear timeout bit
                    }
                } else {
                    state = state_writeudp_clearsend;
                }
                break;

            case state_writeudp_clearsend:
                printf("success send msg\n");
                txbuf[0] = 0x10; //SEND_OK -- clear the interrupt bit
                writeEthAddress(0x4000 + socket * 0x100 + 0x0002, 1);
                state = state_writeudp_sleep;
                break;

            case state_writeudp_cleartimeout:
                printf("timeout\n");
                txbuf[0] = 0x10 | 0x08; //SEND_OK | TIMEOUT -- clear the interrupt bit
                writeEthAddress(0x4000 + socket * 0x100 + 0x0002, 1);
                //state = state_writeudp_writesendcmd; // go back
                state = state_writeudp_readtxwr;
                break;

            case state_writeudp_sleep:
                //state = state_writeudp_writesendcmd;
                state = state_writeudp_readtxwr;
                call Timer.startOneShot(50000);
                break;

        }
    }

    event void Timer.fired()
    {
        switch(processstate)
        {
        case state_initialize:
            post switch_state();
            break;
        case state_connect:
            post connect();
            break;
        case state_writeUDP:
            post writeUDP();
            break;
        }
    }
    async event void SpiPacket.sendDone(uint8_t* txBuf, uint8_t* rxBuf, uint16_t len, error_t error)
    {
        //We don't want to do too much in IRQ context
        call Timer.startOneShot(20);

    }

}
