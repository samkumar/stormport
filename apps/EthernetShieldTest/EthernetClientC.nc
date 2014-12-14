#include "printf.h"
#include <usarthardware.h>

module EthernetClientC
{
    uses interface Boot;
    uses interface Timer<T32khz> as Timer;
    uses interface UDPSocket;
}
implementation
{
    event void Boot.booted()
    {
         call UDPSocket.initialize();
    }

    event void UDPSocket.sendPacketDone(error_t error)
    {
        printf("sent a packet\n");
    }

    event void UDPSocket.packetReceived(uint16_t srcport, uint32_t srcip, uint8_t *buf, uint16_t len)
    {
    }

    event void Timer.fired()
    {
    }
}
