#include <IPDispatch.h>
#include <lib6lowpan/lib6lowpan.h>
#include <lib6lowpan/ip.h>
#include <lib6lowpan/ip.h>
#include "version.h"

module EthernetP
{
    uses
    {
        interface SplitControl as IPControl;
        interface ForwardingTable;
        interface RootControl;

        interface PacketSender;
    }
    provides
    {
        interface IPForward;
    }
}
implementation
{
    void *ipf_data;
    bool busy;

    event void IPControl.startDone (error_t error) {
        printf("Added default route to forwarding table\n");
        call ForwardingTable.addRoute(NULL, 0, NULL, ROUTE_IFACE_ETH0);
        busy = FALSE;
    }
    event void IPControl.stopDone (error_t error) {}



    command error_t IPForward.send(struct in6_addr *next_hop,
                                 struct ip6_packet *msg,
                                 void *data) {
        struct ip_iovec hvec;
        if (busy) return EBUSY;

        hvec.iov_base = (uint8_t*) &msg->ip6_hdr;
        hvec.iov_len = sizeof(struct ip6_hdr);
        hvec.iov_next = msg->ip6_data;
        ipf_data = data;
        call PacketSender.sendPacket(&hvec);

        return SUCCESS;
    }

    event void PacketSender.sendPacketDone(error_t error)
    {
    }

    event void PacketSender.packetReceived(uint8_t *buf, uint16_t len)
    {
        struct ip6_hdr *iph = (struct ip6_hdr *)buf;
        void *payload = (iph + 1);
        signal IPForward.recv(iph, payload, NULL);
    }

}