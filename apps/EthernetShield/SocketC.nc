#include "ethernetshield.h"

generic configuration SocketC ()
{
    //provides interface RawSocket;
    provides interface UDPSocket;
}
implementation
{
    components AllSocketsP;
    enum {
        sock_id = unique(SOCKET_ID)
    };
    //RawSocket = AllSocketsP[sock_id];
    UDPSocket = AllSocketsP.UDPSocket[sock_id];
}
