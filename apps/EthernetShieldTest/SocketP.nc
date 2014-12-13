module SocketP
{
    // needs SPI interface
    //
    // initialize (UDP, TCP, etc)
    // send(*buf, len)
    //
    uses interface SocketSpi;
    uses interface Timer<T32khz> as Timer;
}
implementation
{
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

    typedef enum
    {
        // initialization states
        state_reset,
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
        state_connect_wait_established
    } SocketInitState;

    // our own tx buffer
    uint8_t _txbuf [260];
    uint8_t * const txbuf = &_txbuf[4];
    uint8_t _rxbuf [260];
    uint8_t * const rxbuf = &_rxbuf[4];

    // for the initialization state machine
    SocketInitState state = state_reset;

    // default chose UDP
    //TODO: compile option?
    SocketMode socketmode = SocketMode_UDP;

    // local srcport is 1024 by default
    uint16_t srcport = 1024;

    // our socket index
    //TODO: this will become a generic parameter
    uint8_t socket = 0;

    // are we finished initializing the wiz5200?
    bool initialized = 0;

    // have we started connecting?
    bool startconnect = 0;

    //TODO: wire this to be called after SPI initialization during platform start
    // initialize the socket
    task void init()
    {
        switch(state)
        {
        // Reset the chip by writing RST to the mode register
        case state_reset:
            state = state_write_ipaddress;
            txbuf[0] = 0x80;
            call SocketSpi.writeRegister(0x0000, _txbuf, 1);
            break;

        // Write which address we are
        //TODO: this should come from DHCP or something set at compile time
        case state_write_ipaddress:
            state = state_write_gatewayip;
            // SIBR: 192.168.1.177 src address
            txbuf[0] = 0xc0;
            txbuf[1] = 0xa8;
            txbuf[2] = 0x01;
            txbuf[3] = 0xb1;
            call SocketSpi.writeRegister(0x000F, _txbuf, 4);
            break;

        // Write the gateway ip
        case state_write_gatewayip:
            // GAR: 192.168.1.1
            state = state_write_subnetmask;
            txbuf[0] = 0xc0;
            txbuf[1] = 0xa8;
            txbuf[2] = 0x01;
            txbuf[3] = 0x01;
            call SocketSpi.writeRegister(0x0001, _txbuf, 4);
            break;

        // Write the subnet mask
        case state_write_subnetmask:
            // SUBR: 255.255.255.0
            state = state_initialize_sockets_tx;
            txbuf[0] = 0xff;
            txbuf[1] = 0xff;
            txbuf[2] = 0xff;
            txbuf[3] = 0x00;
            call SocketSpi.writeRegister(0x0005, _txbuf, 4);
            break;

        // Initialize the socket with its tx buffersize, as determined by the Wiz5200 chip
        case state_initialize_sockets_tx:
            state = state_initialize_sockets_rx;
            txbuf[0] = 0x02;
            call SocketSpi.writeRegister(0x4000 + socket * 0x100 + 0x001F, _txbuf, 1);
            break;

        // Initialize the sockets with their rx buffersize, as determined by the Wiz5200 chip
        case state_initialize_sockets_rx:
            state = state_initialize_txwr_txrd;
            txbuf[0] = 0x02;
            call SocketSpi.writeRegister(0x4000 + socket * 0x100 + 0x001E, _txbuf, 1);
            break;

        // Clears the TX read and write pointers for the buffer
        case state_initialize_txwr_txrd:
            txbuf[0] = 0x0;
            txbuf[1] = 0x0;
            txbuf[2] = 0x0;
            txbuf[3] = 0x0;
            call SocketSpi.writeRegister(0x4000 + socket * 0x100 + 0x0022, _txbuf, 4);
            initialized = 1;

        }
    }

    // opens a socket to a destination
    task void openConnection()
    {
        switch(state)
        {

        // find an available socket to use
        case state_connect_init:
            if (startconnect & (*rxbuf == SocketState_CLOSED || *rxbuf == SocketState_FIN_WAIT || *rxbuf == SocketState_CLOSE_WAIT))
            {
                state = state_connect_write_protocol;
                post openConnection(); // go to next state
                break;
            }
            // read the state of the socket
            call SocketSpi.readRegister(0x4000 + socket * 0x100 + 0x0003, _rxbuf, 1);

            // run the above check after we've read once
            if (!startconnect) startconnect = 1;
            break;

        // configure which mode of socket (UDP, TCP, etc)
        case state_connect_write_protocol:
            state = state_connect_write_src_port;
            txbuf[0] = socketmode;
            call SocketSpi.writeRegister(0x4000 + socket * 0x100, _txbuf, 1);
            break;

        // write the local src port
        case state_connect_write_src_port:
            state = state_connect_open_src_port;
            // write the src port in little-endian
            txbuf[0] = (srcport >> 8);
            txbuf[1] = srcport & 0xff;
            call SocketSpi.writeRegister(0x4000 + socket * 0x100 + 0x0004, _txbuf, 2);
            //srcport++; // increment for next time?
            break;

        // after choosing srcport, wait for it to be opened
        case state_connect_open_src_port:
            state = state_connect_wait_src_port_opened;
            txbuf[0] = SocketCommand_OPEN;
            call SocketSpi.writeRegister(0x4000 + socket * 0x100 + 0x0001, _txbuf, 1);
            break;

        // after writing the command to OPEN srcport, wait until it is successful
        // this will loop until the condition is met
        case state_connect_wait_src_port_opened:
            call SocketSpi.readRegister(0x4000 + socket * 0x100 + 0x0001, _rxbuf, 1);
            if (!(*rxbuf)) // if 0, then it went through
            {
                state = state_connect_write_dst_ipaddress;
            }
            break;

        // write our destination address to the correct register
        //TODO: have this come from compile flag?
        case state_connect_write_dst_ipaddress:
            state = state_connect_write_dst_port;
            // 192.168.1.178
            txbuf[0] = 0xc0;
            txbuf[1] = 0xa8;
            txbuf[2] = 0x01;
            txbuf[3] = 0xb2;
            call SocketSpi.writeRegister(0x4000 + socket * 0x100 + 0x000C, _txbuf, 4);
            break;
        
        // write the destination port to the register
        //TODO: have this come from compile flag
        case state_connect_write_dst_port:
            state = state_connect_wait_established;
            // port 7000
            // little endian
            txbuf[0] = (7000 >> 8);
            txbuf[1] = 7000 & 0xff;
            call SocketSpi.writeRegister(0x4000 + socket + 0x100 + 0x0010, _txbuf, 2);
            break;

        // wait until the connection is established.
        // For UDP we want the state to be SocketState_UDP
        //TODO: handle TCP here
        case state_connect_wait_established:
            call SocketSpi.readRegister(0x4000 + socket * 0x100 + 0x0003, _rxbuf, 1);
            if (*rxbuf == SocketState_UDP)
            {
                //finished
            }
            break;
        }
    }

    event void Timer.fired()
    {
        post init();
    }

    // signal that write or read is done
    event void SocketSpi.taskDone(error_t error, uint8_t *buf, uint8_t len)
    {
        call Timer.startOneShot(20);
    }
}
