#include "ethernetshield.h"

generic configuration SocketC ()
{
    provides interface RawSocket;
    provides interface UDPSocket;
    provides interface GRESocket;
}
implementation
{
    components AllSocketsP;
    enum {
        sock_id = unique(SOCKET_ID)
    };
    RawSocket = AllSocketsP.RawSocket[sock_id];
    UDPSocket = AllSocketsP.UDPSocket[sock_id];
    GRESocket = AllSocketsP.GRESocket;
}
