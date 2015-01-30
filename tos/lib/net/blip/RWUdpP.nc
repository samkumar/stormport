/*
 * RWUdp protocol implementation
 * Reliable, Windowless UDP Protocol
 *
 * This is NOT the RUDP protocol from 1999 IETF draft
 * (https://tools.ietf.org/html/draft-ietf-sigtran-reliable-udp-00).
 *
 * ### Introduction
 *
 * RWUDP is designed to be a middleground between the simplicity of implementation
 * of UDP and the reliable delivery of TCP. 1999 RUDP and 1984 RDP are both
 * windowed, which requires keeping track of more state on both the sending and
 * receiving side. Most reliable datagram protocols are focused around getting
 * more performance out of high-speed, high-bandwidth networks. With TCP, a lost
 * packet in a large window (without selective-ACK), can mean resending the whole
 * window, so most reliable UDP protocols evolved to get around that restriction.
 * Our focus is reliable delivery with a focus on simplicity of implementation
 * rather than high bandwidth.
 *
 * ### RWUDP Header
 *
 * RWUDP is built over UDP, so it uses the UDP header:
 *
 *                     +-----------------+
 *                     |    UDP Header   |
 *                     +-----------------+
 *                     |  RWUDP Header   |
 *                     +-----------------+
 *                     |    Datagram     |
 *                     |    contents     |
 *                     +-----------------+
 *
 *
 * The UDP header gives us the following for free:
 *
 *                 0            15            31
 *                 +---------------------------+
 *                 | Source Port |  Dest port  |
 *                 +-------------+-------------+
 *                 |   Length    |  Checksum   |
 *                 +-------------+-------------+
 *
 *
 * The RWUDP header includes the following fields:
 *
 *               0   1   2       15              31
 *               +---+---+--------+---------------+
 *               | S | A |        |               |
 *               | N | C | Unused | Connection ID |
 *               | D | K |  (0)   |               |
 *               +---+---+--------+---------------+
 *               |         Echo Tag               |
 *               +--------------------------------+
 *
 * SND (Send) and ACK (Acknowledgement) flags indicate the type of message. Only
 * one can be set at a time. SND is set to 1 by the sender, and ACK is set to 1 by
 * the receiver.
 *
 * The Connection ID is a random 16-bit number that is unique to the stream of
 * data. This is to help both the sender and receiver keep track of state specific
 * to a certain connection, even though UDP is inherently connectionless.
 *
 * The Echo Tag is a monotonically increasing number that is consistent for each
 * SND/ACK pair. Messages should be processed on the receiver in order of
 * increasing echo tag, and ACKs should be sent back in order that the messages
 * are processed. Because RWUDP is windowless, we can technically have as many
 * in-air messages as we want, assuming the receiver is able to cache and process
 * them, but it is safest to only send 1 datagram at a time.
 *
 * ### Sending
 *
 * A sender increases the echo tag by 1 for each successive message that is sent
 * to a single receiver. The Connection ID must remain the same for the duration
 * of this pseudo-connection. For each sent datagram with echo tag X, if the
 * sender does not receive an ACK from the recipient that contains echo tag X
 * within the allotted time window (Sender-Time-Out STO), then the sender should
 * resend the datagram with echo tag X. Consecutive execution order on the
 * receiving side is only guaranteed if the receiver gets the sender's datagrams
 * within the allotted time window (Receiver-Time-Out RTO). Sender's echo tags
 * for a connection should start at 1, but this is not necessary.
 *
 * ### Receiving
 *
 * The receiver should assume that if it receives multiple datagrams, then
 * messages with duplicate echo tags are wholly duplicate and that messages were
 * sent in order of increasing echo tag. The receiver should attempt to serve
 * messages with consecutive echo tags, but if the RTO is hit before it gets the
 * expected message, then it will serve the next available datagram (in order of
 * consecutive echo tags) until the missing message is received (if it ever
 * arrives).
 *
 * For example, if the server has received and processed message with echo tag 40,
 * and then receives a message with echo tag 42, then the RTO timer will be
 * started to wait for message with echo tag 41. Message 42 will not be processed
 * until either message 41 is received or the timeout is exceeded.
 *
 * @author Gabe Fierro <gtfierro@eecs.berkeley.edu>
 */

#include "blip_printf.h"
#include "rwudp.h"

#define maxecho(x, y) x > y ? x : y

module RWUdpP
{
    provides
    {
        interface UDP as RWUDP[uint8_t clnt];
    }

    uses
    {
        interface UDP[uint8_t clnt];
        interface Timer<T32khz> as SendTimer;
        interface Queue<struct rwudp_packet *> as SendQueue;
        interface Pool<struct rwudp_packet> as PacketPool;
    }
}
implementation
{
    // protocol state variables
    uint16_t echo = 1;
    uint16_t lastacked = 0;
    uint8_t  connectionid = 0xeb;

    // last unacked packet
    struct ip_iovec *unacked_iov;

    // bind our RWUDP socket to a port. This calls UDP.bind() on the underlying
    // UDP socket
    command error_t RWUDP.bind[uint8_t clnt](uint16_t port)
    {
        printf("Binding RWUDP to UDP port %d\n", port);
        call SendTimer.startPeriodic(32000); // TODO: change this?
        return call UDP.bind[clnt](port);
    }

    // sends the packet at the head of SendQueue
    task void dosend()
    {
        struct rwudp_packet *packet = call SendQueue.head();
        struct ip_iovec v[1];
        error_t rc;
        if (call SendQueue.size() == 0)
        {   
            printf("size was 0\n");
            return;
        }

        printf("Sending client %i\n", packet->clnt);
        printf_in6addr(&packet->dest.sin6_addr);
        printf("\n");
        printf("address of payload %d\n", (uint32_t)packet->packet);

        v[0].iov_base = (uint8_t *)&packet->hdr;
        v[0].iov_len = sizeof(struct rwudp_hdr);
        v[0].iov_next = packet->packet;
        rc = call UDP.sendtov[packet->clnt](&packet->dest, &v[0]);
        printf("error_t %d\n", rc);
    }

    // send data @payload with length @len to @dest
    command error_t RWUDP.sendto[uint8_t clnt](struct sockaddr_in6 *dest,
                                               void *payload, uint16_t len)
    {
        struct ip_iovec v[1];
        v[0].iov_base = payload;
        v[0].iov_len = len;
        v[0].iov_next = NULL;
        return call RWUDP.sendtov[clnt](dest, &v[0]);
    }

    // send data in @iov to @dest
    // returns FAIL if the packet is already queued
    // returns SUCCESS if the packet was successfully queued to be sent
    command error_t RWUDP.sendtov[uint8_t clnt](struct sockaddr_in6 *dest,
                                                struct ip_iovec *iov)
    {
        struct ip_iovec   v[1];
        struct rwudp_packet *pkt = call PacketPool.get();
        int i;

        printf("Doign RWUDP sendtov\n");

        // check if this packet is already queued
        for (i=0; i<call SendQueue.size(); i++)
        {
            pkt = call SendQueue.element(i);
            // echo tag is already in queue
            if (pkt->hdr.echo == echo)
            {
                printf("Echo %d is already queued\n", echo);
                return FAIL; 
            }
        }

        // clear all the bits in our struct
        memclr((uint8_t *)&pkt->hdr, sizeof(struct rwudp_hdr));
        // set the SEND flag (for now)
        // TODO: decide whether to SEND or ACK
        pkt->hdr.flags = RWUDP_SND;
        pkt->hdr.connid = connectionid;
        pkt->hdr.echo = echo;

        //TODO: copy these fields?
        printf("tov address of payload %d\n", (uint32_t)iov);
        pkt->packet = iov;
        memcpy(&pkt->dest, dest, sizeof(struct sockaddr_in6)); // copy destination
        pkt->clnt = clnt;

        printf("Enqueuing echo %d for client %i\n", pkt->hdr.echo, clnt);

        return call SendQueue.enqueue(pkt);
    }

    // when the timer fires, send whatever's at the top of the queue
    event void SendTimer.fired()
    {
        printf("attempting send from timer\n");
        post dosend();
    }

    // signaled when we receive a datagram on the underlying UDP socket
    event void UDP.recvfrom[uint8_t clnt](struct sockaddr_in6 *src,
                                          void *payload, uint16_t len,
                                          struct ip6_metadata *meta)
    {
        // parse rwudp header
        struct rwudp_hdr    *rwudph = (struct rwudp_hdr *)payload;

        printf("Got a UDP packet from");
        printf_in6addr(&src->sin6_addr);
        printf("\n");
        printf("SEND: %i, ACK: %i, connid: %i, echotag: %i\n", rwudph->flags & RWUDP_SND, rwudph->flags & RWUDP_ACK, rwudph->connid, rwudph->echo);

        // If we receive an ACK, then update the lastacked echo tag
        // to be the max of the lastacked tag and the freshly received echo tag.
        // This will make sure that we stay consistent with what packet we need
        // to send next and avoid resending duplicates that are already ACKd.
        if ((rwudph->flags & RWUDP_ACK) == RWUDP_ACK)
        {
            // update the last ACKd echo tag
            lastacked = maxecho(rwudph->echo, lastacked);
        }
        else
        {
            printf("Flags: %d, ack %d\n", rwudph->flags, RWUDP_ACK);
        }

        // signal the layer above us that we received a packet and strip the rwudp header off the paylaod
        signal RWUDP.recvfrom[clnt](src, (void *)(rwudph + 1), len - sizeof(struct rwudp_hdr), meta);
    }
}
