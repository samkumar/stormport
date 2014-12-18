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
    uses interface GeneralIO as IRQPin;
    uses interface GpioInterrupt;

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
        state_connect_write_connect,
        state_connect_wait_connect,
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

    typedef enum
    {
        state_recv_init,
        state_recv_read_incoming_size,
        state_recv_check_socket,
        state_recv_getsize,
        state_recv_giveup,
        state_recv_snrx_rd,
        state_recv_increment_snrx_rd,
        state_recv_write_read,
        state_recv_wait_write_read,
        state_recv_finished
    } SocketRecvUDPState;

    // our own tx buffer
    uint8_t _txbuf [260];
    uint8_t * const txbuf = &_txbuf[4];
    uint8_t rxbuf [260];

    // for the initialization state machine
    SocketSendUDPState state = state_connect_init;
    SocketRecvUDPState rstateudp = state_recv_init;

    SocketType sockettype;

    // local srcport is 1024 by default
    uint16_t srcport = 7000;

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

    const uint16_t RXBUF_BASE = 0xC000;
    const uint16_t RXBUF_SIZE = 2048;
    const uint16_t RXMASK = 0x07FF;
    uint16_t RXBASE;

    // use for read/write into send/recv buffer
    uint16_t ptr;
    uint16_t snrx_rd_ptr;

    uint8_t recvbuf [256];
    uint16_t recvsize = 0;
    uint16_t recvport;
    uint32_t recvip;
    uint8_t *recvdata;
    uint16_t recvlen;

    // have we started connecting?
    bool startconnect = 0;

    bool isinitialized = 0;
    bool initializingUDP = 0;
    bool sendingUDP = 0;
    bool listeningUDP = 0;
    bool receiving = 0;

    bool didsend = 0;

    // initialize the socket
    task void init()
    {
        if (isinitialized)
        {
            return;
        }


        TXBASE = TXBUF_BASE + TXBUF_SIZE * socket;
        RXBASE = RXBUF_BASE + RXBUF_SIZE * socket;

        switch(state)
        {
        // find an available socket to use
        case state_connect_init:
            printf("UDP init socket 0x%02x\n", *rxbuf);
            if (startconnect & (*rxbuf == SocketState_CLOSED || *rxbuf == SocketState_FIN_WAIT || *rxbuf == SocketState_CLOSE_WAIT))
            {
                state = state_connect_write_protocol;
                post init(); // go to next state
                break;
            }
            // read the state of the socket
            call SocketSpi.readRegister(0x4000 + socket * 0x100 + 0x0003, rxbuf, 1);

            // run the above check after we've read once
            if (!startconnect) startconnect = 1;
            break;

        // configure which mode of socket (UDP, TCP, etc)
        case state_connect_write_protocol:
            printf("UDP init write protocol\n");
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
            printf("UDP init write src port\n");
            state = state_connect_open_src_port;
            // write the src port in little-endian
            txbuf[0] = (srcport >> 8);
            txbuf[1] = srcport & 0xff;
            call SocketSpi.writeRegister(0x4000 + socket * 0x100 + 0x0004, _txbuf, 2);
            //srcport++; // increment for next time?
            break;

        // after choosing srcport, wait for it to be opened
        case state_connect_open_src_port:
            printf("UDP init open src port\n");
            state = state_connect_wait_src_port_opened;
            txbuf[0] = SocketCommand_OPEN;
            call SocketSpi.writeRegister(0x4000 + socket * 0x100 + 0x0001, _txbuf, 1);
            break;

        // after writing the command to OPEN srcport, wait until it is successful
        // this will loop until the condition is met
        case state_connect_wait_src_port_opened:
            printf("UDP init wait src port opened\n");
            call SocketSpi.readRegister(0x4000 + socket * 0x100 + 0x0001, rxbuf, 1);
            printf("opened? 0x%02x\n", *rxbuf);
            if (!(*rxbuf)) // if 0, then it went through
            {
                isinitialized = 1;
                initializingUDP = 0;
                printf("Release SPI resource\n");
                call SpiResource.release();
                signal UDPSocket.initializeDone(SUCCESS);
            }
            break;

        }
    }

    // opens a socket to a destination
    task void sendUDPPacket()
    {
        int i;
        int data_length = 0;
        switch(state)
        {

        // write our destination address to the correct register
        case state_connect_write_dst_ipaddress:
            printf("send UDP: write dest address %u\n", destip);
            state = state_connect_write_dst_port;
            txbuf[0] = destip >> (3 * 8);
            txbuf[1] = (destip >> (2 * 8)) & 0x00ff;
            txbuf[2] = (destip >> (1 * 8)) & 0x00ff;
            txbuf[3] = (destip >> (0 * 8)) & 0x00ff;
            call SocketSpi.writeRegister(0x4000 + socket * 0x100 + 0x000C, _txbuf, 4);
            break;

        // write the destination port to the register
        case state_connect_write_dst_port:
            printf("send UDP: write dest port %d\n", destport);
            state = state_connect_write_connect;
            // little endian
            txbuf[0] = (destport >> 8);
            txbuf[1] = destport & 0xff;
            call SocketSpi.writeRegister(0x4000 + socket * 0x100 + 0x0010, _txbuf, 2);
            break;

        // tell the chip to connect to destination
        case state_connect_write_connect:
            printf("send UDP: create connection\n");
            state = state_connect_wait_connect;
            txbuf[0] = SocketCommand_CONNECT;
            call SocketSpi.writeRegister(0x4000 + socket * 0x100 + 0x0001, _txbuf, 1);
            break;

        // wait for command to be read
        case state_connect_wait_connect:
            printf("send UDP: wait for connect command sent\n");
            call SocketSpi.readRegister(0x4000 + socket * 0x100 + 0x0001, rxbuf, 1);
            if (didsend && !(*rxbuf))
            {
                printf("sent\n");
                state = state_connect_wait_established;
                didsend = 0;
            }
            didsend = 1;
            break;

        // wait until the connection is established.
        // For UDP we want the state to be SocketState_UDP
        case state_connect_wait_established:
            printf("send UDP: wait until established\n");
            call SocketSpi.readRegister(0x4000 + socket * 0x100 + 0x0003, rxbuf, 1);
            printf("result: 0x%02x 0x%02x 0x%02x\n", *rxbuf, *rxbuf, SocketState_UDP);
            if (*rxbuf == SocketState_UDP)
            {
                //finished
                state = state_writeudp_readtxwr;
            }
            break;

        case state_writeudp_readtxwr:
            printf("send UDP:read TX write register\n");
            call SocketSpi.readRegister(0x4000 + socket * 0x100 + 0x0024, rxbuf, 2);
            //ptr = ((uint16_t)rxbuf[0] << 8) | rxbuf[1];
            // placeholder for doign stuff w/ ptr later
            state = state_writeudp_copytotxbuf;
            break;

        case state_writeudp_copytotxbuf:
            printf("send UDP: copy payload to TX buffer\n");
            data_length = iov_len(&data);
            //TODO offset is 0 for now; assume we can fit it all in the send buffer. need to bounds check
            iov_read(&data, 0, data_length, txbuf);
            call SocketSpi.writeRegister(TXBASE + (ptr & TXMASK), _txbuf, data_length);
            state = state_writeudp_advancetxwr;
            break;

        case state_writeudp_advancetxwr:
            printf("send UDP: advance TX write register by length %d\n", iov_len(&data));
            data_length = iov_len(&data);
            ptr += data_length;
            txbuf[0] = (ptr >> 8);
            txbuf[1] = ptr & 0xff;
            call SocketSpi.writeRegister(0x4000 + socket * 0x100 + 0x0024, _txbuf, 2);
            state = state_writeudp_writesendcmd;
            break;

        case state_writeudp_writesendcmd:
            printf("send UDP: write SEND command\n");
            txbuf[0] = SocketCommand_SEND;
            call SocketSpi.writeRegister(0x4000 + socket * 0x100 + 0x0001, _txbuf, 1);
            state = state_writeudp_waitsendcomplete;
            break;

        case state_writeudp_waitsendcomplete:
            printf("send UDP: wait SEND complete\n");
            call SocketSpi.readRegister(0x4000 + socket * 0x100 + 0x0001, rxbuf, 1);
            if (!(*rxbuf))
            {
                // finished writing SEND
                state = state_writeudp_waitsendinterrupt;
            }
            break;

        case state_writeudp_waitsendinterrupt:
            //printf("send UDP: wait for SEND interrupt\n");
            call SocketSpi.readRegister(0x4000 + socket * 0x100 + 0x0002, rxbuf, 2);
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
            printf("send UDP: clear send bit\n");
            txbuf[0] = 0x10; //SEND_OK -- clear interrupt bit
            call SocketSpi.writeRegister(0x4000 + socket * 0x100 + 0x0002, _txbuf, 1);
            state = state_writeudp_finished;
            break;

        case state_writeudp_cleartimeout:
            printf("send UDP: clear timeout bit\n");
            txbuf[0] = 0x10 | 0x08; //SEND_OK | TIMEOUT -- clear interrupt bit
            call SocketSpi.writeRegister(0x4000 + socket * 0x100 + 0x0002, _txbuf, 1);
            state = state_writeudp_error; // timedout on send
            break;

        case state_writeudp_finished:
            printf("Finished packet. Releasing SPI\n");
            sendingUDP = 0;
            listeningUDP = 0;
            recvsize = 0;
            //rxbuf[0] = 0;
            //rxbuf[1] = 0;
            //rstateudp = state_recv_init;
            signal UDPSocket.sendPacketDone(SUCCESS);
            call Timer.startOneShot(100);
            call SpiResource.release();
            printf("sudp finish: %d %d %d\n", initializingUDP, sendingUDP, listeningUDP);
            break;

        case state_writeudp_error:
            printf("Packet timeout. Releasing SPI\n");
            sendingUDP = 0;
            listeningUDP = 0;
            recvsize = 0;
            //rxbuf[0] = 0;
            //rxbuf[1] = 0;
            //rstateudp = state_recv_init;
            signal UDPSocket.sendPacketDone(FAIL);
            call Timer.startOneShot(100);
            call SpiResource.release();
            printf("sudp fail: %d %d %d\n", initializingUDP, sendingUDP, listeningUDP);
            break;
        }
    }

    task void recvUDPPacket()
    {
        int i;

        if (!(call SpiResource.isOwner()))
        {
            call SpiResource.request();
            return;
        }
        listeningUDP = 1;

        switch(rstateudp)
        {
            // read IR2 register to see if our socket is triggered
            case state_recv_init:
                rstateudp = state_recv_check_socket;
                call SocketSpi.readRegister(0x0034, rxbuf, 1);
                break;

            case state_recv_check_socket:
                if (*rxbuf & (1 << socket)) // mask for our socket number
                {
                    rstateudp = state_recv_read_incoming_size;
                    // read incoming read register
                    call SocketSpi.readRegister(0x4000 + socket * 0x100  + 0x0026, rxbuf, 2);
                }
                else
                {
                    rstateudp = state_recv_giveup;
                    post recvUDPPacket();
                }
                break;
                
            // check socket interrupt register for incoming data
            case state_recv_read_incoming_size:
                // in rxbuf is our most recent value of the interrupt buffer
                recvsize = ((uint16_t)rxbuf[0] << 8) | rxbuf[1];
                if (recvsize)
                {
                    printf("rxbuf[0] = 0x%02x\n", rxbuf[0]);
                    printf("rxbuf[1] = 0x%02x\n", rxbuf[1]);
                    printf("got rx size? 0x%02x\n", recvsize);
                    rstateudp = state_recv_snrx_rd;
                    // read register for next state
                    call SocketSpi.readRegister(0x4000 + socket * 0x100 + 0x0028, rxbuf, 2);
                    break;
                }
                else
                {
                    rstateudp = state_recv_giveup;
                    post recvUDPPacket();
                }
                break;

            case state_recv_snrx_rd:
                printf("state_recv_snrx_rd\n");
                rstateudp = state_recv_increment_snrx_rd;
                printf("before snrx: %d\n", snrx_rd_ptr);
                snrx_rd_ptr = ((uint16_t)rxbuf[0] << 8) | rxbuf[1];
                printf("read into rxbuf: %d bytes from 0x%02x\n", recvsize, RXBASE + (snrx_rd_ptr & RXMASK));
                call SocketSpi.readRegister(RXBASE + (snrx_rd_ptr & RXMASK), rxbuf, recvsize);
                break;

            case state_recv_increment_snrx_rd:
                printf("state_recv_increment_snrx_rd with size %d\n", recvsize);
                rstateudp = state_recv_write_read;

                memcpy(recvbuf, rxbuf, recvsize);
                recvport = ((uint16_t)recvbuf[4] << 8) | recvbuf[5];
                printf("From port %d\n", recvport);
                snrx_rd_ptr += recvsize;
                printf("after snrx: %d\n", snrx_rd_ptr);
                txbuf[0] = (snrx_rd_ptr >> 8);
                txbuf[1] = snrx_rd_ptr & 0xff;
                call SocketSpi.writeRegister(0x4000 + socket * 0x100 + 0x0028, _txbuf, 2);
                break;

            case state_recv_write_read:
                printf("state_recv_write_read\n");
                rstateudp = state_recv_wait_write_read;
                txbuf[0] = SocketCommand_RECV;
                rxbuf[0] = 1; // make sure we check at least once below
                call SocketSpi.writeRegister(0x4000 + socket * 0x100 + 0x0001, _txbuf, 1);
                break;

            case state_recv_wait_write_read:
                call SocketSpi.readRegister(0x4000 + socket * 0x100 + 0x0001, rxbuf, 1);
                if (!(*rxbuf))
                {
                    rstateudp = state_recv_finished;
                }
                break;
                

            case state_recv_finished:
                printf("Finished listening\n");
                recvip = recvbuf[3] | (recvbuf[2] << 8) | (recvbuf[1] << 16) | (recvbuf[0] << 24);
                recvport = ((uint16_t)recvbuf[4] << 8) | recvbuf[5];
                recvlen = (recvbuf[6] << 8) | recvbuf[7];
                recvdata = &recvbuf[8];
                rstateudp = state_recv_init;
                recvsize = 0;
                listeningUDP = 0;
                signal UDPSocket.packetReceived(recvport, recvip, recvdata, recvlen);
                //call Timer.startOneShot(1000); // go back to 'main' timer loop
                call SpiResource.release();
                call GpioInterrupt.enableFallingEdge();
                printf("recv finish: %d %d %d\n", initializingUDP, sendingUDP, listeningUDP);
                break;

            case state_recv_giveup: // no data or some error happened
                listeningUDP = 0;
                recvsize = 0;
                rstateudp = state_recv_init;
                call SpiResource.release();
                call GpioInterrupt.enableFallingEdge();
                //call Timer.startOneShot(100);
                if (initializingUDP + sendingUDP + listeningUDP)
                {
                    printf("recv giveup: %d %d %d\n", initializingUDP, sendingUDP, listeningUDP);
                }
                break;
        }
    }

    command void UDPSocket.initialize(uint16_t lp)
    {
        srcport = lp;
        printf("Initializing local UDP socket with port %u\n", srcport);
        sockettype = SocketType_UDP;
        initializingUDP = 1;
        printf("udp socket call resource %d\n", call SpiResource.request());
    }


    command void UDPSocket.sendPacket(uint16_t dp, uint32_t di, struct ip_iovec d)
    {
        destport = dp;
        destip = di;
        data = d;
        state = state_connect_write_dst_ipaddress;
        printf("send to %u:%d\n", destip, destport);
        sendingUDP = 1;
        listeningUDP = 0;
        call SpiResource.request();
    }

    event void Timer.fired()
    {
        if (initializingUDP)
        {
            sendingUDP = 0;
            listeningUDP = 0;
            post init();
        }
        else if (sendingUDP) // sending UDP packet
        {
            initializingUDP = 0;
            listeningUDP = 0;
            post sendUDPPacket();
        }
        else if (listeningUDP)
        {
            initializingUDP = 0;
            sendingUDP = 0;
            post recvUDPPacket();
        }
        else // if not doing anything else, go back to listening
        {
            // atomically check after enabling falling edge that
            // we didn't already miss the trigger. If we did, 
            // trigger the read check manually
            printf(".");
            atomic
            {
                call GpioInterrupt.enableFallingEdge();
                if (!(call IRQPin.get())) // check if low
                {
                    call GpioInterrupt.disable();
                    listeningUDP = 1;
                    rstateudp = state_recv_init;
                    post recvUDPPacket();
                }
            }
        }
    }

    // fired when we possibly get some incoming data
    async event void GpioInterrupt.fired()
    {
        call GpioInterrupt.disable();
        post recvUDPPacket();
    }

    // signal that write or read is done
    event void SocketSpi.taskDone(error_t error, uint8_t *buf, uint8_t len)
    {

        memcpy(rxbuf, buf, len);

        if (!(call SpiResource.isOwner()))
        {
            //printf("tried, but is not owner\n");
            return;
        }
        call Timer.startOneShot(20);
    }

    default event void UDPSocket.sendPacketDone(error_t error) {}
    default event void UDPSocket.packetReceived(uint16_t srcport, uint32_t srcip, uint8_t *buf, uint16_t len) {}

    event void SpiResource.granted()
    {
        if (initializingUDP)
        {
            post init();
        }
        else if (sendingUDP) // sending UDP packet
        {
            post sendUDPPacket();
        }
        else if (listeningUDP)
        {
            post recvUDPPacket();
        }
        //else
        //{
        //    listeningUDP = 1;
        //    rstateudp = state_recv_init;
        //    post recvUDPPacket();
        //}
    }
}
