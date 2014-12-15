/*
 * the state machien will setup src port and src address during init.
 * on each sendUDP(dstport, dstaddress, iovec), we do the further init on the chip
 * for sending to that destination (iovec is what we write)
 */
module SocketP
{
    uses interface SocketSpi;
    uses interface Timer<T32khz> as Timer;
    uses interface Resource as SpiResource;
    uses interface ArbiterInfo;
    //provides interface RawSocket;
    provides interface UDPSocket;
}
implementation
{
    typedef enum
    {
        SocketType_UDP,
        SocketType_TCP,
        SocketType_IPRAW,
        SocketType_GRE
    } SocketType;

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
        state_writeudp_readtxwr,
        state_writeudp_copytotxbuf,
        state_writeudp_advancetxwr,
        state_writeudp_writesendcmd,
        state_writeudp_waitsendcomplete,
        state_writeudp_waitsendinterrupt,
        state_writeudp_clearsend,
        state_writeudp_cleartimeout,
        state_writeudp_finished,
        state_writeudp_error
    } SocketSendUDPState;

    // our own tx buffer
    uint8_t _txbuf [260];
    uint8_t * const txbuf = &_txbuf[4];
    uint8_t _rxbuf [260];
    uint8_t * const rxbuf = &_rxbuf[4];

    // for the initialization state machine
    SocketSendUDPState state = state_connect_init;

    SocketType sockettype;

    // local srcport is 1024 by default
    uint16_t srcport = 1024;

    uint16_t destport;
    uint32_t destip;
    struct ip_iovec data;

    // our socket index
    //TODO: this will become a generic parameter
    uint8_t socket = 0;

    const uint16_t TXBUF_BASE = 0x8000;
    const uint16_t TXBUF_SIZE = 2048;
    const uint16_t TXMASK = 0x07FF;
    uint16_t TXBASE;

    // use for read/write into send/recv buffer
    uint16_t ptr;

    // have we started connecting?
    bool startconnect = 0;

    bool isinitialized = 0;

    // initialize the socket
    task void init()
    {
        if (isinitialized)
        {
            return;
        }


        TXBASE = TXBUF_BASE + TXBUF_SIZE * socket;

        printf("udp init state %d\n", state);
        switch(state)
        {
        // find an available socket to use
        case state_connect_init:
            if (startconnect & (*rxbuf == SocketState_CLOSED || *rxbuf == SocketState_FIN_WAIT || *rxbuf == SocketState_CLOSE_WAIT))
            {
                state = state_connect_write_protocol;
                post init(); // go to next state
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
            switch(sockettype)
            {
                case SocketType_UDP:
                case SocketType_GRE:
                    txbuf[0] = SocketMode_UDP;
                    break;
                case SocketType_TCP:
                    txbuf[0] = SocketMode_TCP;
                    break;
                case SocketType_IPRAW:
                    txbuf[0] = SocketMode_IPRAW;
                    break;
            }
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
                isinitialized = 1; // prevent anyone from calling this again
            }
            break;

        }
    }

    // opens a socket to a destination
    task void sendUDPPacket()
    {
        int data_length = 0;
        switch(state)
        {

        // write our destination address to the correct register
        case state_connect_write_dst_ipaddress:
            state = state_connect_write_dst_port;
            txbuf[0] = destip >> (3 * 8);
            txbuf[1] = destip >> (2 * 8);
            txbuf[2] = destip >> (1 * 8);
            txbuf[3] = destip >> (0 * 8);
            call SocketSpi.writeRegister(0x4000 + socket * 0x100 + 0x000C, _txbuf, 4);
            break;

        // write the destination port to the register
        case state_connect_write_dst_port:
            state = state_connect_wait_established;
            // little endian
            txbuf[0] = (destport >> 8);
            txbuf[1] = destport & 0xff;
            call SocketSpi.writeRegister(0x4000 + socket + 0x100 + 0x0010, _txbuf, 2);
            break;

        // wait until the connection is established.
        // For UDP we want the state to be SocketState_UDP
        case state_connect_wait_established:
            call SocketSpi.readRegister(0x4000 + socket * 0x100 + 0x0003, _rxbuf, 1);
            if (*rxbuf == SocketState_UDP)
            {
                //finished
                state = state_writeudp_readtxwr;
            }
            break;

        case state_writeudp_readtxwr:
            call SocketSpi.readRegister(0x4000 + socket * 0x100 + 0x0024, _rxbuf, 2);
            //ptr = ((uint16_t)_rxbuf[0] << 8) | rxbuf[1];
            // placeholder for doign stuff w/ ptr later
            state = state_writeudp_copytotxbuf;
            break;

        case state_writeudp_copytotxbuf:
            data_length = iov_len(&data);
            //TODO offset is 0 for now; assume we can fit it all in the send buffer. need to bounds check
            iov_read(&data, 0, data_length, txbuf);
            call SocketSpi.writeRegister(TXBASE + (ptr & TXMASK), _txbuf, data_length);
            state = state_writeudp_advancetxwr;
            break;

        case state_writeudp_advancetxwr:
            data_length = iov_len(&data);
            ptr += data_length;
            txbuf[0] = (ptr >> 8);
            txbuf[1] = ptr & 0xff;
            call SocketSpi.writeRegister(0x4000 + socket * 0x100 + 0x0024, _txbuf, 2);
            state = state_writeudp_writesendcmd;
            break;

        case state_writeudp_writesendcmd:
            txbuf[0] = SocketCommand_SEND;
            call SocketSpi.writeRegister(0x4000 + socket * 0x100 + 0x0001, _txbuf, 1);
            state = state_writeudp_waitsendcomplete;
            break;

        case state_writeudp_waitsendcomplete:
            call SocketSpi.readRegister(0x4000 + socket * 0x100 + 0x0001, _rxbuf, 1);
            if (!(*rxbuf))
            {
                // finished writing SEND
                state = state_writeudp_waitsendinterrupt;
            }
            break;

        case state_writeudp_waitsendinterrupt:
            call SocketSpi.readRegister(0x4000 + socket * 0x100 + 0x0002, _rxbuf, 2);
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
            txbuf[0] = 0x10; //SEND_OK -- clear interrupt bit
            call SocketSpi.writeRegister(0x4000 + socket * 0x100 + 0x0002, _txbuf, 1);
            state = state_writeudp_finished;
            break;

        case state_writeudp_cleartimeout:
            txbuf[0] = 0x10 | 0x08; //SEND_OK | TIMEOUT -- clear interrupt bit
            call SocketSpi.writeRegister(0x4000 + socket * 0x100 + 0x0002, _txbuf, 1);
            state = state_writeudp_error; // timedout on send
            break;

        case state_writeudp_finished:
            signal UDPSocket.sendPacketDone(SUCCESS);
            break;

        case state_writeudp_error:
            signal UDPSocket.sendPacketDone(FAIL);
            break;
        }
    }

    command void UDPSocket.initialize()
    {
        sockettype = SocketType_UDP;
        printf("init is owner? %d\n", call SpiResource.isOwner());
        printf("udp socket request %d %d\n", call SpiResource.request(), EBUSY);
        //call Timer.startOneShot(10000);
    }

    command void UDPSocket.sendPacket(uint16_t destport, uint32_t destip, struct ip_iovec data)
    {
        destport = destport;
        destip = destip;
        data = data;
        state = state_connect_write_dst_ipaddress;
        post sendUDPPacket();
    }

    event void Timer.fired()
    {
        printf("udp timer fired\n");
        printf("is owner? %d\n", call SpiResource.isOwner());
        printf("udp socket request %d %d\n", call SpiResource.request(), EBUSY);
        if (!(call SpiResource.isOwner()))
        {
            return;
        }
        post init();
    }

    // signal that write or read is done
    event void SocketSpi.taskDone(error_t error, uint8_t *buf, uint8_t len)
    {
        printf("is owner? %d\n", call SpiResource.isOwner());
        if (!(call SpiResource.isOwner()))
        {
            printf("tried, but is not owner\n");
            return;
        }
        call Timer.startOneShot(20);
    }

    default event void UDPSocket.sendPacketDone(error_t error) {}
    default event void UDPSocket.packetReceived(uint16_t srcport, uint32_t srcip, uint8_t *buf, uint16_t len) {}

    event void SpiResource.granted()
    {
        printf("granted should see once: %d\n", call SpiResource.isOwner());
        post init();
    }
}
