generic module SocketP(uint8_t socket)
{
    uses interface SocketSpi;
    uses interface Timer<T32khz> as Timer;
    uses interface Resource as InitResource;
    uses interface Resource as SendResource;
    uses interface Resource as RecvResource;
    uses interface ArbiterInfo;
    uses interface GeneralIO as IRQPin;
    uses interface GpioInterrupt;

    provides interface UDPSocket;
    provides interface RawSocket;
}
implementation
{

    // ignores recv/send until this is set by the initialization finishing
    bool isinitialized = 0;

    // buffers for SPI
    uint8_t _txbuf [260];
    uint8_t * const txbuf = &_txbuf[4];
    uint8_t rxbuf [260];

    // local port for our socket
    uint16_t localport;

    // destination for sending
    uint16_t sendport;
    uint32_t sendipaddress;
    struct ip_iovec *senddata; // send data
    int senddata_len;

    // vars for receiving
    uint16_t recvsize = 0;
    uint16_t recvport;
    uint32_t recvipaddress;
    uint8_t recvheader [8];
    uint8_t recvbuf [256];
    uint16_t recvlen;

    // state machine vars
    SocketInitUDPState initUDPstate;
    SocketSendUDPState sendUDPstate;
    SocketRecvUDPState recvUDPstate = state_recv_init;

    // keep track of what kind of packet we are
    SocketType sockettype;
    SocketState goal_socketstate;
    uint8_t headerlength;

    // IP RAW vars
    uint8_t ipp; // ip protocol

    // send/recv buffer pointers
    uint16_t tx_ptr;
    uint16_t rx_ptr;

    uint16_t src_mask;
    uint16_t src_ptr;
    uint16_t readsize;
    uint16_t packetlen = 0;
    uint16_t amountleft;

    //uint8_t socket = 0;

    // state machine flags
    bool initializingUDP = 0;
    bool sendingUDP = 0;
    bool listeningUDP = 0;

    // predeclarations of state machine functions
    task void initUDP();
    task void sendUDP();
    task void recvUDP();

    task void enableListen();

    // Initialize this socket as a UDP socket with a local port of [lp]
    command void UDPSocket.initialize(uint16_t lp)
    {
        localport = lp;

        sockettype = SocketType_UDP;
        goal_socketstate = SocketState_UDP; // use this for writing
        headerlength = 8; // 8 byte header for UDP

        // have to init this stuff somewhere..
        TXBASE = TXBUF_BASE + TXBUF_SIZE * socket;
        RXBASE = RXBUF_BASE + RXBUF_SIZE * socket;

        // put state machine in initial state
        initUDPstate = state_init_readsockstate;

        // we call request here because we are waiting to acquire the resource
        // that is currently being used by the EthernetShield initialization
        call InitResource.request();
    }

    //TODO: protect these send* addresses so that they aren't overwritten by another send command
    command void UDPSocket.sendPacket(uint16_t destport, uint32_t destip, struct ip_iovec *data)
    {
        if (!isinitialized) {
            signal UDPSocket.sendPacketDone(FAIL);
            return;
        }
        printf("request to send a packet\n");
        sendport = destport;
        sendipaddress = destip;
        senddata = data;
        sendUDPstate = state_connect_write_dst_ipaddress;
        call SendResource.request();
    }

    /** RawSocket implementation **/
    command void RawSocket.initialize(uint8_t ipprotocol)
    {
        sockettype = SocketType_IPRAW;
        goal_socketstate = SocketState_IPRAW; // use this for writing
        headerlength = 6; // 6 byte header for IP RAW
        TXBASE = TXBUF_BASE + TXBUF_SIZE * socket;
        RXBASE = RXBUF_BASE + RXBUF_SIZE * socket;
        initUDPstate = state_init_readsockstate;
        call InitResource.request();
    }

    command void RawSocket.sendPacket(uint32_t destip, struct ip_iovec *data)
    {
        if (!isinitialized) {
            signal RawSocket.sendPacketDone(FAIL);
            return;
        }
        sendUDPstate = state_connect_write_dst_ipaddress;
        senddata = data;
        sendipaddress = destip;
        call SendResource.request();
    }

    event void Timer.fired()
    {
    }

    async event void GpioInterrupt.fired()
    {
        call GpioInterrupt.disable();
        post recvUDP();
    }

    event void SocketSpi.taskDone(error_t error, uint8_t *buf, uint8_t len)
    {
        // copy results into our rxbuffer
        memcpy(rxbuf, buf, len);

        // check which task we are doing and return to that state machine
        if (initializingUDP)
        {
            post initUDP();
        }
        else if (sendingUDP)
        {
            post sendUDP();
        }
        else if (listeningUDP)
        {
            post recvUDP();
        }
    }

    event void InitResource.granted()
    {
        printf("Start UDP initialization\n");
        initializingUDP = 1;
        post initUDP();
    }

    event void SendResource.granted()
    {
        printf("Send a UDP packet to %u:%d\n", sendipaddress, sendport);
        sendingUDP = 1;
        post sendUDP();
    }

    event void RecvResource.granted()
    {
        printf("Got Recv resource, listening for packets\n");
        listeningUDP = 1;
        call GpioInterrupt.disable();
        post recvUDP();
    }

    task void enableListen() // call this when exiting a state machine so we can still listen
    {
        atomic
        {
            call GpioInterrupt.enableFallingEdge();
            if (!(call IRQPin.get())) // check if low
            {
                call GpioInterrupt.disable();
                post recvUDP();
            }
        }
    }


    /** Initialization State Machine **/
    task void initUDP()
    {
        switch (initUDPstate)
        {
            case state_init_readsockstate:
                printf("Socket init: read socket state\n");
                switch(sockettype)
                {
                    case SocketType_UDP:
                        initUDPstate = state_init_write_protocol;
                        call SocketSpi.readRegister(0x4003 + socket * 0x100, rxbuf, 1);
                        break;
                    case SocketType_IPRAW: // write our IP protocol type
                        initUDPstate = state_init_ipraw_write_ipp;
                        txbuf[0] = ipp; // from RawSocket.initialize
                        call SocketSpi.writeRegister(0x4014 + socket * 0x100, _txbuf, 1);
                        break;
                }
                break;

            case state_init_ipraw_write_ipp: // read status register in ipraw
                initUDPstate = state_init_write_protocol;
                call SocketSpi.readRegister(0x4003 + socket * 0x100, rxbuf, 1);
                break;
            
            case state_init_write_protocol:
                printf("Socket init: write protocol type\n");
                if (*rxbuf == SocketState_CLOSED || *rxbuf == SocketState_FIN_WAIT || *rxbuf == SocketState_CLOSE_WAIT)
                {
                    // this means we can reuse the socket
                    switch (sockettype)
                    {
                        case SocketType_UDP:
                            initUDPstate = state_init_write_src_port;
                            txbuf[0] = SocketMode_UDP;
                            break;
                        case SocketType_IPRAW: //write IP RAW mode
                            initUDPstate = state_init_open_src_port; // skip writing srcport and ip
                            txbuf[0] = SocketMode_IPRAW;
                            break;
                    }
                    call SocketSpi.writeRegister(0x4000 + socket * 0x100, _txbuf, 1);
                    break;
                }
                else
                {
                    // socket can't be used
                    printf("UDP init: socket %d cannot be used\n", socket);
                    initUDPstate = state_init_fail;
                    post initUDP();
                    break;
                }
                break;

            case state_init_write_src_port:
                printf("UDP init: write src port \n");
                initUDPstate = state_init_open_src_port;
                // make srcport little endian
                txbuf[0] = (localport >> 8);
                txbuf[1] = localport & 0xff;
                call SocketSpi.writeRegister(0x4004 + socket * 0x100, _txbuf, 2);
                break;

            case state_init_open_src_port:
                printf("UDP init: open src port\n");
                initUDPstate = state_init_read_src_port_opened;
                txbuf[0] = SocketCommand_OPEN;
                call SocketSpi.writeRegister(0x4001 + socket * 0x100, _txbuf, 1);
                break;

            case state_init_read_src_port_opened:
                printf("UDP init: check if oport opened\n");
                initUDPstate = state_init_wait_src_port_opened;
                call SocketSpi.readRegister(0x4001 + socket * 0x100, rxbuf, 1);
                break;

            case state_init_wait_src_port_opened:
                if (!(*rxbuf)) // command has been read
                {
                    initUDPstate = state_init_success;
                    txbuf[0] = 0xFF;
                    call SocketSpi.writeRegister(0x0016, _txbuf, 1);
                    break;
                }
                else // it hasn't
                {
                    call SocketSpi.readRegister(0x4001 + socket * 0x100, rxbuf, 1);
                }
                break;

            case state_init_success:
                printf("UDP init: success!\n");
                initializingUDP = 0;
                if (sockettype == SocketType_UDP) signal UDPSocket.initializeDone(SUCCESS);
                else if (sockettype == SocketType_IPRAW) signal RawSocket.initializeDone(SUCCESS);
                isinitialized = 1;
                call InitResource.release();
                call GpioInterrupt.enableFallingEdge();
                call IRQPin.makeInput();
                break;
                
            case state_init_fail:
                printf("UDP init: YOU FAIL!\n");
                initializingUDP = 0;
                if (sockettype == SocketType_UDP) signal UDPSocket.initializeDone(FAIL);
                else if (sockettype == SocketType_IPRAW) signal RawSocket.initializeDone(FAIL);
                call InitResource.release();
                break;
        }
    }

    task void sendUDP()
    {
        switch(sendUDPstate)
        {
            case state_connect_write_dst_ipaddress:
                printf("UDP send: write dest address %u\n", sendipaddress);
                if (sockettype == SocketType_UDP) sendUDPstate = state_connect_write_dst_port;
                else if (sockettype == SocketType_IPRAW) sendUDPstate = state_connect_write_connect; // skip port for IP RAW
                txbuf[0] = sendipaddress >> 24;
                txbuf[1] = (sendipaddress >> 16) & 0xff;
                txbuf[2] = (sendipaddress >> 8) & 0xff;
                txbuf[3] = sendipaddress & 0xff;
                call SocketSpi.writeRegister(0x400C + socket * 0x100, _txbuf, 4);
                break;

            case state_connect_write_dst_port:
                printf("UDP send: write dest port %d\n", sendport);
                sendUDPstate = state_connect_write_connect;
                txbuf[0] = sendport >> 8;
                txbuf[1] = sendport & 0xff;
                call SocketSpi.writeRegister(0x4010 + socket * 0x100, _txbuf, 2);
                break;

            case state_connect_write_connect:
                printf("UDP send: create connection\n");
                sendUDPstate = state_connect_read_connect;
                txbuf[0] = SocketCommand_CONNECT;
                call SocketSpi.writeRegister(0x4001 + socket * 0x100, _txbuf, 1);
                break;

            case state_connect_read_connect:
                printf("UDP send: read connect status\n");
                sendUDPstate = state_connect_wait_connect;
                call SocketSpi.readRegister(0x4001 + socket * 0x100, rxbuf, 1);
                break;

            case state_connect_wait_connect:
                printf("UDP send: wait for establishment\n");
                if (!(*rxbuf)) // command was read
                {
                    sendUDPstate = state_connect_wait_established;
                    // read the status register to advance to next state
                    call SocketSpi.readRegister(0x4003 + socket * 0x100, rxbuf, 1);
                }
                else // command hasn't been actuated by chip
                {
                    // so we read it again
                    call SocketSpi.readRegister(0x4001 + socket * 0x100, rxbuf, 1);
                }
                break;

            case state_connect_wait_established:
                if (*rxbuf == goal_socketstate) // chip is ready to send
                {
                    printf("Socket send: established!\n");
                    sendUDPstate = state_writeudp_copytotxbuf; 
                    // read the tx write register for next state
                    call SocketSpi.readRegister(0x4024 + socket * 0x100, rxbuf, 2);
                }
                else // read again until we get the value
                {
                    call SocketSpi.readRegister(0x4003 + socket * 0x100, rxbuf, 1);
                }
                break;

            case state_writeudp_copytotxbuf:
                printf("UDP send: copy data to TX buffer\n");
                tx_ptr = ((uint16_t)rxbuf[0] << 8) | rxbuf[1];
                senddata_len = iov_len(senddata);
                iov_read(senddata, 0, senddata_len, txbuf);
                sendUDPstate = state_writeudp_advancetxwr;
                call SocketSpi.writeRegister(TXBASE + (tx_ptr & TXMASK), _txbuf, senddata_len);
                break;

            case state_writeudp_advancetxwr:
                printf("UDP send: advance tx_ptr buffer\n");
                tx_ptr += senddata_len;
                txbuf[0] = tx_ptr >> 8;
                txbuf[1] = tx_ptr & 0xff;
                sendUDPstate = state_writeudp_writesendcmd;
                call SocketSpi.writeRegister(0x4024 + socket * 0x100, _txbuf, 2);
                break;

            case state_writeudp_writesendcmd:
                printf("UDP send: write SEND command\n");
                txbuf[0] = SocketCommand_SEND;
                sendUDPstate = state_writeudp_waitsendcomplete;
                call GpioInterrupt.disable();
                call SocketSpi.writeRegister(0x4001 + socket * 0x100, _txbuf, 1);
                break;

            case state_writeudp_readsendcmd:
                sendUDPstate = state_writeudp_waitsendcomplete;
                // read the interrupt register
                call SocketSpi.readRegister(0x4002 + socket * 0x100, rxbuf, 2);
                break;

            case state_writeudp_waitsendcomplete:
                if (*rxbuf) printf("rxbuf interrupt: 0x%02x\n", *rxbuf);
                if (!(*rxbuf & SocketInterrupt_SEND_OK)) // didn't get positive confirmation yet
                {
                    if (*rxbuf & SocketInterrupt_TIMEOUT)
                    {
                        printf("Timeout on send\n");
                        sendUDPstate = state_writeudp_error;
                        txbuf[0] = SocketInterrupt_SEND_OK | SocketInterrupt_TIMEOUT;
                        call GpioInterrupt.disable(); // disable interrupts before we write
                        call SocketSpi.writeRegister(0x4002 + socket * 0x100, _txbuf, 1);
                        break;
                    }
                    else if (*rxbuf & SocketInterrupt_RECV) // recv flag got set
                    {
                        //TODO if we get here, figure out what to do
                        printf("Recv got set");
                        break;
                    }
                    else // read again
                    {
                        call SocketSpi.readRegister(0x4002 + socket * 0x100, rxbuf, 2);
                    }
                }
                else // it sent okay
                {
                    sendUDPstate = state_writeudp_finished;
                    txbuf[0] = SocketInterrupt_SEND_OK;
                    call GpioInterrupt.disable(); // disable interrupts before we write
                    call SocketSpi.writeRegister(0x4002 + socket * 0x100, _txbuf, 1);
                    break;
                }
                break;

            case state_writeudp_finished:
                printf("UDP send: Success!\n");
                sendingUDP = 0;
                if (sockettype == SocketType_UDP) signal UDPSocket.sendPacketDone(SUCCESS);
                else if (sockettype == SocketType_IPRAW) signal RawSocket.sendPacketDone(SUCCESS);
                call SendResource.release();
                post enableListen(); // reenables interrupts
                break;

            case state_writeudp_error:
                printf("UDP send: FAIL!\n");
                sendingUDP = 0;
                if (sockettype == SocketType_UDP) signal UDPSocket.sendPacketDone(FAIL);
                else if (sockettype == SocketType_IPRAW) signal RawSocket.sendPacketDone(FAIL);
                call SendResource.release();
                post enableListen(); // reenables interrupts
                break;

        }
    }

    task void recvUDP()
    {
        int i; // for for loops

        if (!(call RecvResource.isOwner()))
        {
            printf("recv request resource\n");
            call RecvResource.request();
            return;
        }

        switch(recvUDPstate)
        {
            // read IR2 register to see if our socket is triggered
            case state_recv_init:
                printf("UDP recv: read IR2 register for trigger\n");
                recvUDPstate = state_recv_check_socket;
                call SocketSpi.readRegister(0x0034, rxbuf, 1);
                break;

            case state_recv_check_socket:
                printf("UDP recv: check socket. rxbuf is 0x%02x\n", *rxbuf);
                if (*rxbuf & (1 << socket)) // mask for our socket number
                {
                    recvUDPstate = state_recv_clear_interrupt;
                    txbuf[0] = 0xFF;
                    call SocketSpi.writeRegister(0x4002 + socket * 0x100, _txbuf, 1);
                    // read incoming read register
                }
                else // we weren't triggered
                {
                    printf("No trigger\n");
                    recvUDPstate = state_recv_giveup;
                    post recvUDP(); // advance to that state, do not pass Go, do not collect $200
                }
                break;

            case state_recv_clear_interrupt:
                printf("UDP recv: clear interrupt bit\n");
                recvUDPstate = state_recv_read_incoming_size;
                call SocketSpi.readRegister(0x4026 + socket * 0x100, rxbuf, 2);
                break;

            case state_recv_read_incoming_size:
                recvsize = ((uint16_t)rxbuf[0] << 8) | rxbuf[1];
                printf("UDP recv: read size on incoming buffer is %d\n", recvsize);
                if (recvsize)
                {
                    recvUDPstate = state_recv_snrx_rd;
                    call SocketSpi.readRegister(0x4028 + socket * 0x100, rxbuf, 2);
                }
                else
                {
                    printf("No data for this socket, although it was triggered\n");
                    // if no data, then give up
                    recvUDPstate = state_recv_giveup;
                    post recvUDP();
                }
                break;

            case state_recv_snrx_rd:
                printf("UDP recv: read incoming data\n");
                rx_ptr = ((uint16_t)rxbuf[0] << 8) | rxbuf[1];
                printf("before rx_ptr: %d = 0x%02x\n", rx_ptr, rx_ptr);
                
                src_mask = rx_ptr & RXMASK; // mask to put it in the correct range
                src_ptr = RXBASE + src_mask; // add the offset to the base
                amountleft = RXBUF_SIZE - src_mask; // number of bytes left in buffer
                printf("src_mask: 0x%02x\n", src_mask);
                printf("src_ptr: 0x%02x\n", src_ptr);
                printf("RXBUF_SIZE 0x%02x\n", RXBUF_SIZE);
                printf("amountleft %d\n", amountleft);
                if (amountleft >= headerlength) // here, we have enough room to read the header
                {
                    // read 8 byte UDP header
                    printf("Read full header\n");
                    recvUDPstate = state_recv_read_full_header;
                    call SocketSpi.readRegister(src_ptr, rxbuf, headerlength);
                }
                else // don't have enough room for header!
                {
                    recvUDPstate = state_recv_assemble_header;
                    call SocketSpi.readRegister(src_ptr, rxbuf, amountleft); // should be 0 <= amountleft <= 7
                }
                break;

            // here, we couldn't read 8 bytes off of the header
            case state_recv_assemble_header:
                printf("UDP rcv: read what header we can: amountleft is %d\n", amountleft);
                memcpy(recvheader, rxbuf, amountleft); // read however much we can
                recvUDPstate = state_recv_finish_header;
                call SocketSpi.readRegister(RXBASE, rxbuf, headerlength - amountleft); // then read the rest
                break;

            case state_recv_finish_header:
                printf("UDP recv: finish reading header: left is %d\n", headerlength - amountleft);
                memcpy(recvheader+amountleft, rxbuf, headerlength - amountleft);
                recvUDPstate = state_recv_read_packet;
                post recvUDP();
                break;

            case state_recv_read_full_header:
                memcpy(recvheader, rxbuf, headerlength); // copy read header into our header struct
                printf("recvheader: 0x%02x\n", recvheader[4]);
                recvUDPstate = state_recv_read_packet;
                post recvUDP();
                break;

            case state_recv_read_packet:
                rx_ptr += headerlength; // advance rx_ptr bc we just read headerlength bytes
                src_mask = rx_ptr & RXMASK; // recalculate offset
                src_ptr = RXBASE + src_mask;
                printf("UDP recv: start reading packet\n");
                for (i=0;i<headerlength;i++)
                {
                    printf("header[%d] = 0x%02x\n", i, recvheader[i]);
                }
                printf("src_mask: 0x%02x\n", src_mask);
                printf("src_ptr: 0x%02x\n", src_ptr);

                // decode header
                recvipaddress = recvheader[3] | (recvheader[2] << 8) | (recvheader[1] << 16) | (recvheader[0] << 24);
                if (sockettype == SocketType_UDP)
                {
                    recvport = ((uint16_t)recvheader[4] << 8) | recvheader[5];
                    packetlen = ((uint16_t)recvheader[6] << 8) | recvheader[7];
                }
                else if (sockettype == SocketType_IPRAW)
                {
                    packetlen = ((uint16_t)recvheader[4] << 8) | recvheader[5];
                }

                printf("packet len is %d\n", packetlen);
                if ((src_mask + packetlen) > RXBUF_SIZE)
                {
                    readsize = RXBUF_SIZE - src_mask;
                    recvUDPstate = state_recv_read_morepacket;
                    printf("read this many first: %d\n", readsize);
                    //read readsize bytes from src_ptr into buffer
                    call SocketSpi.readRegister(src_ptr, rxbuf, readsize);
                }
                else // it all fits
                {
                    printf("read full packet\n");
                    readsize = 0;
                    recvUDPstate = state_recv_increment_snrx_rd;
                    call SocketSpi.readRegister(src_ptr, rxbuf, packetlen);
                }
                break;


            case state_recv_read_morepacket:
                printf("UDP recv: read more packet\n");
                recvUDPstate = state_recv_increment_snrx_rd;
                memcpy(recvbuf, rxbuf, readsize);
                call SocketSpi.readRegister(RXBASE, rxbuf, packetlen - readsize);
                break;

            case state_recv_increment_snrx_rd:
                printf("UDP recv: increment read pointer \n");
                recvUDPstate = state_recv_write_read;

                // copy packet contents into local buffer
                printf("packetlen is %d readsize is %d\n", packetlen, readsize);

                memcpy(recvbuf+readsize, rxbuf, packetlen - readsize);

                rx_ptr += packetlen;
                txbuf[0] = rx_ptr >> 8;
                txbuf[1] = rx_ptr & 0xff;
                printf("after rx_ptr: %d = 0x%02x\n", rx_ptr, rx_ptr);
                call SocketSpi.writeRegister(0x4028 + socket * 0x100, _txbuf, 2);
                break;

            case state_recv_write_read:
                printf("UDP recv: write RECV command\n");
                recvUDPstate = state_recv_read_read;
                txbuf[0] = SocketCommand_RECV;
                call SocketSpi.writeRegister(0x4001 + socket * 0x100, _txbuf, 1);
                break;

            case state_recv_read_read:
                recvUDPstate = state_recv_wait_write_read;
                call SocketSpi.readRegister(0x4001 + socket * 0x100, rxbuf, 1);
                break;

            case state_recv_wait_write_read:
                if (!(*rxbuf))
                {
                    recvUDPstate = state_recv_finished;
                    post recvUDP();
                }
                else // read again
                {
                    call SocketSpi.readRegister(0x4001 + socket * 0x100, rxbuf, 1);
                }
                break;

            case state_recv_finished:
                printf("UDP recv: Finished listening\n");
                listeningUDP = 0;
                recvUDPstate = state_recv_init;
                recvsize -= (packetlen + headerlength);
                call RecvResource.release();
                //call GpioInterrupt.enableFallingEdge();
                recvipaddress = recvheader[3] | (recvheader[2] << 8) | (recvheader[1] << 16) | (recvheader[0] << 24);
                recvport = ((uint16_t)recvheader[4] << 8) | recvheader[5];
                printf("recv size is now: %d\n", recvsize);
                for (i=0;i<headerlength;i++)
                {
                    printf("recvheader[%d] = 0x%02x\n", i, recvheader[i]);
                }

                if (sockettype == SocketType_UDP) signal UDPSocket.packetReceived(recvport, recvipaddress, recvbuf, packetlen);
                else if (sockettype == SocketType_IPRAW) signal RawSocket.packetReceived(recvbuf, packetlen);

                if (recvsize > 0)
                {
                    printf("mo packets. with size %d\n", recvsize);
                    post recvUDP();
                }
                else
                {
                    post enableListen();
                }
                break;

            case state_recv_giveup:
                printf("UDP recv: give up\n");
                listeningUDP = 0;
                recvUDPstate = state_recv_init;
                call RecvResource.release();
                call GpioInterrupt.enableFallingEdge();
                break;
        }
    }

    default event void UDPSocket.sendPacketDone(error_t error) {}
    default event void UDPSocket.initializeDone(error_t error) {}
    default event void UDPSocket.packetReceived(uint16_t srcport, uint32_t srcip, uint8_t *buf, uint16_t len) {}

    default event void RawSocket.sendPacketDone(error_t error) {}
    default event void RawSocket.initializeDone(error_t error) {}
    default event void RawSocket.packetReceived(uint8_t *buf, uint16_t len) {}
}
