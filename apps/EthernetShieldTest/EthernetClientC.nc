#include "printf.h"
#include <lib6lowpan/iovec.h>
#include <usarthardware.h>
#include "ethernetshield.h"

module EthernetClientC
{
    uses interface Boot;
    uses interface Timer<T32khz> as Timer;
    uses interface UDPSocket;
    uses interface EthernetShieldConfig;

    uses interface ArbiterInfo;
}
implementation
{
    event void Boot.booted()
    {
        uint32_t srcip = 192 << 24 | 168 << 16 | 1 << 8 | 177;
        uint32_t netmask = 255 << 24 | 255 << 16 | 255 << 8 | 0;
        uint32_t gateway = 192 << 24 | 168 << 16 | 1 << 8 | 1;
        uint8_t *mac = "\xde\xad\xbe\xef\xfe\xed";

        //printf("user %d\n", call ArbiterInfo.userId());

        call EthernetShieldConfig.initialize(srcip, netmask, gateway, mac);

        call UDPSocket.initialize(7000);
    }

    event void UDPSocket.initializeDone(error_t error)
    {
        printf("Initialization done\n");
        if (!error)
        {
            call Timer.startOneShot(100000);
        }
    }

    event void UDPSocket.sendPacketDone(error_t error)
    {
        printf("sent a packet\n");
        // send another packet when we finish
        call Timer.startOneShot(500000);
    }

    event void UDPSocket.packetReceived(uint16_t srcport, uint32_t srcip, uint8_t *buf, uint16_t len)
    {
        int i;
        printf("received packet udp\n");
        printf("From ip %d\n", srcip);
        printf("From port %d\n", srcport);
        printf("Length %d\n", len);
        printf("Data:");
        for (i=0;i<len;i++)
        {
            printf("%02x", buf[i]);
            //printf("%c", buf[i]);
        }
        printf("\n");
    }

    event void Timer.fired()
    {
        // send a packet out
        struct ip_iovec out;
        char* hello = "\x68\x65\x6c\x6c\x6f";
        uint32_t destip = 192 << 24 | 168 << 16 | 1 << 8 | 178;
        uint16_t destport = 7000;
        out.iov_base = hello;
        out.iov_len = 5;
        out.iov_next = NULL;
        //printf("ethernetclient c trying to send packet\n");
        call UDPSocket.sendPacket(destport, destip, out);
    }
}
