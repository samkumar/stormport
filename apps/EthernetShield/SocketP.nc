module SocketP
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
}
implementation
{
    // buffers for SPI
    uint8_t _txbuf [260];
    uint8_t * const txbuf = &_txbuf[4];
    uint8_t rxbuf [260];

    // local port for our socket
    uint16_t localport;

    // destination for sending
    uint16_t sendport;
    uint32_t sendipaddress;
    struct ip_iovec senddata; // send data
    int senddata_len;

    // state machine vars
    SocketInitUDPState initUDPstate;
    SocketSendUDPState sendUDPstate;

    // send/recv buffer pointers
    uint16_t tx_ptr;

    uint8_t socket = 0;

    // state machine flags
    bool initializingUDP = 0;
    bool sendingUDP = 0;

    // predeclarations of state machine functions
    task void initUDP();
    task void sendUDP();

    // Initialize this socket as a UDP socket with a local port of [lp]
    command void UDPSocket.initialize(uint16_t lp)
    {
        localport = lp;

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
    command void UDPSocket.sendPacket(uint16_t destport, uint32_t destip, struct ip_iovec data)
    {
        sendport = destport;
        sendipaddress = destip;
        senddata = data;
        sendUDPstate = state_connect_write_dst_ipaddress;
        call SendResource.request();
    }

    event void Timer.fired()
    {
    }

    async event void GpioInterrupt.fired()
    {
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
    }

    /** Initialization State Machine **/
    task void initUDP()
    {
        switch (initUDPstate)
        {
            case state_init_readsockstate:
                printf("UDP init: read socket state\n");
                initUDPstate = state_init_write_protocol;
                call SocketSpi.readRegister(0x4003 + socket * 0x100, rxbuf, 1);
                break;
            
            case state_init_write_protocol:
                printf("UDP init: write protocol UDP\n");
                if (*rxbuf == SocketState_CLOSED || *rxbuf == SocketState_FIN_WAIT || *rxbuf == SocketState_CLOSE_WAIT)
                {
                    // this means we can reuse the socket
                    initUDPstate = state_init_write_src_port;
                    txbuf[0] = SocketMode_UDP;
                    call SocketSpi.writeRegister(0x4000 + socket * 0x100, _txbuf, 1);
                    break;
                }
                else
                {
                    // socket can't be used
                    //TODO: goto fail case
                    signal UDPSocket.initializeDone(FAIL);
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
                    post initUDP(); // no spi command here, so we just repost to advance state
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
                signal UDPSocket.initializeDone(SUCCESS);
                call InitResource.release();
                break;
                
            case state_init_fail:
                printf("UDP init: YOU FAIL!\n");
                initializingUDP = 0;
                signal UDPSocket.initializeDone(FAIL);
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
                sendUDPstate = state_connect_write_dst_port;
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
                if (*rxbuf == SocketState_UDP) // chip is ready to send
                {
                    printf("UDP send: established!\n");
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
                senddata_len = iov_len(&senddata);
                iov_read(&senddata, 0, senddata_len, txbuf);
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
                call SocketSpi.writeRegister(0x4001 + socket * 0x100, _txbuf, 1);
                break;

            case state_writeudp_readsendcmd:
                sendUDPstate = state_writeudp_waitsendcomplete;
                // read the interrupt register
                call SocketSpi.readRegister(0x4002 + socket * 0x100, rxbuf, 2);
                break;

            case state_writeudp_waitsendcomplete:
                if (!(*rxbuf & SocketInterrupt_SEND_OK)) // didn't get positive confirmation yet
                {
                    if (*rxbuf & SocketInterrupt_TIMEOUT)
                    {
                        printf("Timeout on send\n");
                        sendUDPstate = state_writeudp_error;
                        txbuf[0] = SocketInterrupt_SEND_OK | SocketInterrupt_TIMEOUT;
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
                    call SocketSpi.writeRegister(0x4002 + socket * 0x100, _txbuf, 1);
                    break;
                }
                break;

            case state_writeudp_finished:
                printf("UDP send: Success!\n");
                sendingUDP = 0;
                signal UDPSocket.sendPacketDone(SUCCESS);
                call SendResource.release();
                break;

            case state_writeudp_error:
                printf("UDP send: FAIL!\n");
                sendingUDP = 0;
                signal UDPSocket.sendPacketDone(FAIL);
                call SendResource.release();
                break;

        }
    }

    default event void UDPSocket.sendPacketDone(error_t error) {}
    default event void UDPSocket.packetReceived(uint16_t srcport, uint32_t srcip, uint8_t *buf, uint16_t len) {}
}
