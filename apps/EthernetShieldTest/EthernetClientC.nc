#include "printf.h"
#include <lib6lowpan/iovec.h>
#include <usarthardware.h>

module EthernetClientC
{
    uses interface Boot;
    uses interface Timer<T32khz> as Timer;
    uses interface UDPSocket;
    uses interface EthernetShieldConfig;
}
implementation
{
    event void Boot.booted()
    {
         uint32_t srcip = 192 << 24 | 168 << 16 | 1 << 8 | 177;
         uint32_t netmask = 255 << 24 | 255 << 16 | 255 << 8 | 0;
         uint32_t gateway = 192 << 24 | 168 << 16 | 1 << 8 | 1;
         uint8_t *mac = "\xde\xad\xbe\xef\xfe\xed";
         call EthernetShieldConfig.initialize(srcip, netmask, gateway, mac);
         call UDPSocket.initialize();
         call Timer.startOneShot(5000);
    }

    event void UDPSocket.sendPacketDone(error_t error)
    {
        printf("sent a packet\n");
        // send another packet when we finish
        call Timer.startOneShot(5000);
    }

    event void UDPSocket.packetReceived(uint16_t srcport, uint32_t srcip, uint8_t *buf, uint16_t len)
    {
    }

    event void Timer.fired()
    {
        // send a packet out
        struct ip_iovec out;
        char* hello = "\x68\x65\x6c\x6c\x6f\n";
        uint32_t destip = 192 << 24 | 168 << 16 | 1 << 8 | 178;
        uint16_t destport = 7000;
        out.iov_base = hello;
        out.iov_len = 6;
        out.iov_next = NULL;
        call UDPSocket.sendPacket(destport, destip, out);
    }
}
