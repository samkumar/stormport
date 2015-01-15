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
        interface EthernetShieldConfig;
        interface RawSocket;
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
    uint32_t destip;

    event void IPControl.startDone (error_t error) {
        printf("Ethernet set as default route\n");
        call ForwardingTable.addRoute(NULL, 0, NULL, ROUTE_IFACE_ETH0);

        busy = FALSE;
        destip = 0x0a040a32; //10.4.10.50
        //destip = 0x0a040a8e; //10.4.10.150
        //destip = 0x0a040a87; // 10.4.10.135
        //destip = 0x364365f1; //54.67.101.241
        {
            uint32_t srcip   = 10  << 24 | 4   << 16 | 10  << 8 | 146;
            uint32_t netmask = 255 << 24 | 255 << 16 | 255 << 8 | 0  ;
            uint32_t gateway = 10  << 24 | 4   << 16 | 10  << 8 | 1  ;
            uint8_t *mac = "\xde\xad\xbe\xef\xfe\xec";

            call EthernetShieldConfig.initialize(srcip, netmask, gateway, mac);
        }
        call RootControl.setRoot();
        call RawSocket.initialize(41);
        call RootControl.setRoot();
    }
    event void RawSocket.initializeDone(error_t error) {

    }
    event void IPControl.stopDone (error_t error) {}



    command error_t IPForward.send(struct in6_addr *next_hop,
                                 struct ip6_packet *msg,
                                 void *data) {
        struct ip_iovec hvec;
        if (busy) return EBUSY;
        busy=TRUE;
        hvec.iov_base = (uint8_t*) &msg->ip6_hdr;
        hvec.iov_len = sizeof(struct ip6_hdr);
        hvec.iov_next = msg->ip6_data;
        ipf_data = data;
        call RawSocket.sendPacket(destip, &hvec);

        return SUCCESS;
    }

    event void RawSocket.sendPacketDone(error_t error)
    {
        busy = FALSE;
    }

    event void RawSocket.packetReceived(uint8_t *buf, uint16_t len)
    {
        struct ip6_hdr *iph = (struct ip6_hdr *)buf;
        void *payload = (iph + 1);
        signal IPForward.recv(iph, payload, NULL);
    }

}
