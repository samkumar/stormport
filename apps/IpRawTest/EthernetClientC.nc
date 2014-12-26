#include "printf.h"
#include <lib6lowpan/iovec.h>
#include <usarthardware.h>
#include "ethernetshield.h"

module EthernetClientC
{
    uses interface Boot;
    uses interface Timer<T32khz> as Timer;
    uses interface RawSocket;
    uses interface EthernetShieldConfig;
}
implementation
{
    event void Boot.booted()
    {
        uint32_t srcip = 10 << 24 | 4 << 16 | 10 << 8 | 143;
        uint32_t netmask = 255 << 24 | 255 << 16 | 255 << 8 | 0;
        uint32_t gateway = 10 << 24 | 4 << 16 | 10 << 8 | 1;
        //uint32_t srcip = 192 << 24 | 168 << 16 | 1 << 8 | 177;
        //uint32_t gateway = 192 << 24 | 168 << 16 | 1 << 8 | 1;
        uint8_t *mac = "\xde\xad\xbe\xef\xfe\xed";

        call EthernetShieldConfig.initialize(srcip, netmask, gateway, mac);

        call RawSocket.initialize(0x2F); // 0x2F == 47 == GRE protocol
    }

    event void RawSocket.initializeDone(error_t error)
    {
        printf("Initialization done\n");
        if (!error)
        {
            call Timer.startOneShot(50000);
        }
    }

    event void RawSocket.sendPacketDone(error_t error)
    {
        printf("sent a packet\n");
        // send another packet when we finish
        call Timer.startOneShot(50000);
    }

    event void RawSocket.packetReceived(uint8_t *buf, uint16_t len)
    {
        int i;
        printf("received packet udp\n");
        printf("Length %d\n", len);
        printf("Data:");
        for (i=0;i<len;i++)
        {
            printf("%02x", buf[i]);
        }
        printf("\n");
    }

    event void Timer.fired()
    {
        // send a packet out
        uint8_t packet [12];
        uint32_t destip;
        struct ip_iovec out;

        packet[0] = 0x0a;
        packet[1] = 0x04;
        packet[2] = 0x0a;
        packet[3] = 0x8e;
        packet[4] = 0x0;
        packet[5] = 0x06;
        packet[6] = 0xa;
        packet[7] = 0xa;
        packet[8] = 0xa;
        packet[9] = 0xa;
        packet[10] = 0xa;
        packet[11] = 0xa;

        out.iov_base = packet;
        out.iov_len = 12;
        out.iov_next = NULL;

        destip = packet[3] | (packet[2] << 8) | (packet[1] << 16) | (packet[0] << 24);

        printf("ethernetclient c trying to send packet\n");
        call RawSocket.sendPacket(destip, out);
    }
}
