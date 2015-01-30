#ifndef _RWUDP_H_
#define _RWUDP_H_

#define RWUDP_SEND_QUEUE_SIZE 10
struct rwudp_packet {
    // RWUDP header
    struct rwudp_hdr hdr;
    // the rest of the packet contents to send
    struct ip_iovec  *packet;
    // destiantion address
    struct sockaddr_in6 dest;
    // client identifier for TOS generics
    uint8_t clnt;
};
#endif
