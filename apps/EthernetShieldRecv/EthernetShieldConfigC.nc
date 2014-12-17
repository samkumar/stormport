module EthernetShieldConfigC
{
    uses interface SocketSpi;
    uses interface Timer<T32khz> as Timer;
    uses interface Resource as SpiResource;
    provides interface EthernetShieldConfig;
}
implementation
{
    typedef enum
    {
        // initialization states
        state_reset,
        state_write_ipaddress,
        state_write_gatewayip,
        state_write_subnetmask,
        state_write_mac,
        state_initialize_sockets_tx,
        state_initialize_sockets_rx,
        state_initialize_txwr_txrd,
        state_initialize_finished
    } SocketInitState;

    SocketInitState state = state_reset;

    uint8_t socket = 0;
    uint32_t src_ip, netmask, gateway;
    uint8_t *mac;

    // our own tx buffer
    uint8_t _txbuf [10];
    uint8_t * const txbuf = &_txbuf[4];

    // loop index
    int i = 0;

    task void init();

    command void EthernetShieldConfig.initialize(uint32_t si, uint32_t nm, uint32_t gw, uint8_t *m)
    {
        src_ip = si;
        netmask = nm;
        gateway = gw;
        mac = m;
        printf("eth shield config immediate request spi: %d %d\n", call SpiResource.immediateRequest(), SUCCESS);
        post init();
    }

    task void init()
    {
        printf("current state %d\n", state);
        switch(state)
        {
        case state_reset:
            printf("state reset\n");
            state = state_write_ipaddress;
            txbuf[0] = 0x80;
            call SocketSpi.writeRegister(0x0000, _txbuf, 1);
            break;

        // Write which address we are
        case state_write_ipaddress:
            printf("state_write_ipaddress\n");
            state = state_write_gatewayip;
            txbuf[0] = src_ip >> (3 * 8);
            txbuf[1] = (src_ip >> (2 * 8)) & 0x00ff;
            txbuf[2] = (src_ip >> (1 * 8)) & 0x00ff;
            txbuf[3] = (src_ip >> (0 * 8)) & 0x00ff;
            call SocketSpi.writeRegister(0x000F, _txbuf, 4);
            break;

        // Write the gateway ip
        case state_write_gatewayip:
            state = state_write_subnetmask;
            txbuf[0] = gateway >> (3 * 8);
            txbuf[1] = (gateway >> (2 * 8)) & 0x00ff;
            txbuf[2] = (gateway >> (1 * 8)) & 0x00ff;
            txbuf[3] = (gateway >> (0 * 8)) & 0x00ff;
            call SocketSpi.writeRegister(0x0001, _txbuf, 4);
            break;

        // Write the subnet mask
        case state_write_subnetmask:
            state = state_write_mac;
            txbuf[0] = netmask >> (3 * 8);
            txbuf[1] = (netmask >> (2 * 8)) & 0x00ff;
            txbuf[2] = (netmask >> (1 * 8)) & 0x00ff;
            txbuf[3] = (netmask >> (0 * 8)) & 0x00ff;
            call SocketSpi.writeRegister(0x0005, _txbuf, 4);
            break;

        case state_write_mac:
            state = state_initialize_sockets_tx;
            for (i=0; i < 6; i++)
            {
                txbuf[i] = mac[i];
            }
            call SocketSpi.writeRegister(0x0009, _txbuf, 6);
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
            // now finished
            state = state_initialize_finished;
            break;

        // termination case
        case state_initialize_finished:
            printf("Ethernet shield initialized!\n");
            printf("released: %d\n", call SpiResource.release());
            printf("ami owner %d\n", call SpiResource.isOwner());
            break;
        }
    }

    event void Timer.fired()
    {
        post init();
    }
    
    event void SocketSpi.taskDone(error_t error, uint8_t *buf, uint8_t len)
    {
        if (!(call SpiResource.isOwner()))
        {
            return;
        }
        call Timer.startOneShot(20);
    }

    event void SpiResource.granted()
    {
        printf("granted shoudl not see\n");
    }

}
