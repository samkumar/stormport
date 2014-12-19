#include "ethernetshield.h"

generic module SocketC ()
{
    provides interface RawSocket;
    provides interface UDPSocket;
}
implementation
{
    components AllSocketsP;
    enum {
        sock_id = unique(SOCKET_ID)
    };
    RawSocket = AllSocketsP[sock_id];
    UDPSocket = AllSocketsP[sock_id];
}
