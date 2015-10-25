#include <IPDispatch.h>
#include <lib6lowpan/lib6lowpan.h>
#include <lib6lowpan/ip.h>
#include <lib6lowpan/ip.h>
#include "version.h"

#define makeIPV4(a,b,c,d) a << 24 | b << 16 | c << 8 | d
#define printIPV4(addr) printf("%d.%d.%d.%d", (0xff & (addr >> 24)), (0xff & (addr>>16)), (0xff & (addr>>8)), (0xff & addr))

module EthernetP
{
    uses
    {
        interface SplitControl as IPControl;
        interface ForwardingTable;
        interface RootControl;
        interface EthernetShieldConfig;
        interface RawSocket;
        interface FlashAttr;
        interface LocalIeeeEui64;
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
    error_t e;

    struct sockaddr_in6 route_dest_154;
    ieee_eui64_t address;
    uint8_t mac [6];
    uint32_t destip;
    uint32_t srcip;
    uint32_t netmask;
    uint32_t gateway;

    // for reading from flash
    uint8_t key [10];
    char val [65];
    uint8_t val_len;

    // flash values will be:
    // IPv6 prefix for the mesh
    // 2: meshpfx => 2001:470:1234:2::
    // IPv4 address of remote tunnel
    // 3: remtun => 10.4.10.33
    // IPv4 address of local tunnel
    // 4: loctun => 10.4.10.31
    // IPv4 local netmask
    // 5: locmask => 255.255.255.0
    // IPv4 local gateway
    // 6: locgate => 10.4.10.1
    task void init() {
        e = call FlashAttr.getAttr(2, key, val, &val_len);
        if (e != SUCCESS)
        {
            printf("error? %d length %d\n", e, EBUSY);
        }
        // load into the route_dest_154
        inet_pton6(val, &route_dest_154.sin6_addr);
        // sets up routing IN6_PREFIX to the 15.4 interface,
        // with a default route to forward over the ethernet shield
        call ForwardingTable.addRoute(NULL, 0, NULL, ROUTE_IFACE_ETH0);
        call ForwardingTable.addRoute((uint8_t*) &route_dest_154.sin6_addr, 64, NULL, ROUTE_IFACE_154);

#ifndef BLIP_STFU
        printf("\033[33;1m[[Border Router Configuration]]\n");
        printf("Loaded mesh prefix from config: ");
        printf_in6addr(&route_dest_154.sin6_addr);
        printf("\n\033[0m");
#endif

        // fetch the mac address from the node id and berkeley OID
        {
            int i;
            address = call LocalIeeeEui64.getId(); // This is how we autogenerate the MAC address from the serial number -- GTF
            mac[0] = address.data[0];
            mac[1] = address.data[1];
            mac[2] = address.data[2];
            mac[3] = address.data[3];
            mac[4] = address.data[6];
            mac[5] = address.data[7];
        }

        // load remote tunnel address
        e = call FlashAttr.getAttr(3, key, val, &val_len);
        destip = makeIPV4(val[0], val[1], val[2], val[3]);
#ifndef BLIP_STFU
        printf("\033[33;1mRemote tunnel address: ");
        printIPV4(destip);
        printf("\n\033[0m");
#endif

        // load local tunnel address
        e = call FlashAttr.getAttr(4, key, val, &val_len);
        srcip = makeIPV4(val[0], val[1], val[2], val[3]);
#ifndef BLIP_STFU
        printf("\033[33;1mLocal tunnel address: ");
        printIPV4(srcip);
        printf("\n\033[0m");
#endif

        // load local netmask
        e = call FlashAttr.getAttr(5, key, val, &val_len);
        netmask = makeIPV4(val[0], val[1], val[2], val[3]);
#ifndef BLIP_STFU
        printf("\033[33;1mLocal tunnel netmask: ");
        printIPV4(netmask);
        printf("\n\033[0m");
#endif

        // load local gateway address
        e = call FlashAttr.getAttr(6, key, val, &val_len);
        gateway = makeIPV4(val[0], val[1], val[2], val[3]);
#ifndef BLIP_STFU
        printf("\033[33;1mLocal gateway address: ");
        printIPV4(gateway);
        printf("\n\033[0m");
#endif

        call EthernetShieldConfig.initialize(srcip, netmask, gateway, mac);

        // release busy
        busy = FALSE;

        call RootControl.setRoot();
        call RawSocket.initialize(41);
        call RootControl.setRoot();
    }

    event void IPControl.startDone (error_t error) {
        post init();
    }

    event void RawSocket.initializeDone(error_t error) {}

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
