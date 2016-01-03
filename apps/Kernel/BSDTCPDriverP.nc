#include <bsdtcp/syserrno.h>
#include "driver.h"

// Number of active sockets and number of passive sockets must be the same
#define NUMSOCKETS 2

module BSDTCPDriverP {
    provides interface Driver;
    provides interface Init;
    uses interface BSDTCPActiveSocket[uint8_t aclient];
    uses interface BSDTCPPassiveSocket[uint8_t pclient];
} implementation {
    #include <bsdtcp/socket.h>
    #include <bsdtcp/tcp.h>
    #include <bsdtcp/tcp_fsm.h>
    
    typedef struct {
        tcp_lite_callback_t connectDone;
        tcp_lite_callback_t sendReady;
        tcp_lite_callback_t recvReady;
        tcp_lite_callback_t connectionLost;
        uint8_t readycbs;
    } active_socket_t;
    
    typedef struct {
        int acceptinginto;
        tcp_full_callback_t acceptDone;
        uint8_t readycbs;
    } passive_socket_t;
    
    /* Bitmasks that record which sockets are currently allocated. */
    norace uint32_t activemask;
    norace uint32_t passivemask;
    
    /* Socket structures. */
    norace active_socket_t activesockets[NUMSOCKETS];
    norace passive_socket_t passivesockets[NUMSOCKETS];
    
    /* For remembering the callback. */
    norace bool passive;
    norace uint8_t socket_idx;
    norace uint8_t cb_type;
    
    void clear_activesocket(int i) {
        activesockets[i].connectDone.addr = 0;
        activesockets[i].connectDone.type = CONNECT_DONE;
        activesockets[i].sendReady.addr = 0;
        activesockets[i].sendReady.type = SEND_READY;
        activesockets[i].recvReady.addr = 0;
        activesockets[i].recvReady.type = RECV_READY;
        activesockets[i].connectionLost.addr = 0;
        activesockets[i].connectionLost.type = CONNECTION_LOST;
    }
    
    void clear_passivesocket(int i) {
        passivesockets[i].acceptinginto = -1;
        passivesockets[i].acceptDone.addr = 0;
        passivesockets[i].acceptDone.type = ACCEPT_DONE;
    }
    
    command error_t Init.init() {
        int i;
        activemask = 0;
        passivemask = 0;
        for (i = 0; i < NUMSOCKETS; i++) {
            clear_activesocket(i);
            activesockets[i].readycbs = 0;
            clear_passivesocket(i);
            passivesockets[i].readycbs = 0;
        }
        passive = FALSE;
        socket_idx = 0;
        cb_type = CONNECT_DONE;
    }
    
    /* Increments *CBT, and returns TRUE if it wrapped. */
    bool next_cb_type(uint8_t* cbt) {
        switch (*cbt) {
        case CONNECT_DONE:
            *cbt = SEND_READY;
            return FALSE;
        case SEND_READY:
            *cbt = RECV_READY;
            return FALSE;
        case RECV_READY:
            *cbt = CONNECTION_LOST;
            return FALSE;
        case CONNECTION_LOST:
            *cbt = ACCEPT_DONE;
            return FALSE;
        case ACCEPT_DONE:
            *cbt = CONNECT_DONE;
            return TRUE;
        default:
            return FALSE;
        }
    }
    
    tcp_lite_callback_t* get_callback(uint8_t sock_idx, uint8_t cbt) {
        switch (cbt) {
        case CONNECT_DONE:
            return &activesockets[sock_idx].connectDone;
        case SEND_READY:
            return &activesockets[sock_idx].sendReady;
        case RECV_READY:
            return &activesockets[sock_idx].recvReady;
        case CONNECTION_LOST:
            return &activesockets[sock_idx].connectionLost;
        case ACCEPT_DONE:
            return (tcp_lite_callback_t*) &passivesockets[sock_idx].acceptDone;
        default:
            return NULL;
        }
    }
    
    command driver_callback_t Driver.peek_callback() {
        uint8_t start_idx = socket_idx;
        uint8_t start_cb_type = cb_type;
        tcp_lite_callback_t* toconsider;
        do {
            if ((IS_PASSIVE_CB(cb_type) && (passivesockets[socket_idx].readycbs & cb_type)) ||
                (!IS_PASSIVE_CB(cb_type) && (activesockets[socket_idx].readycbs & cb_type))) {
                toconsider = get_callback(socket_idx, cb_type);
                if (toconsider->addr != 0) {
                    return (driver_callback_t) toconsider;
                }
            }
            if (next_cb_type(&cb_type)) {
                socket_idx = (socket_idx + 1) % NUMSOCKETS;
            }
        } while (socket_idx != start_idx && cb_type != start_cb_type);
        return NULL;
    }
    
    command void Driver.pop_callback() {
        if (IS_PASSIVE_CB(cb_type)) {
            passivesockets[socket_idx].readycbs &= ~cb_type;
        } else {
            activesockets[socket_idx].readycbs &= ~cb_type;
        }
    }
    
    event void BSDTCPPassiveSocket.acceptDone[uint8_t pi](struct sockaddr_in6* addr, int asockid) {
        passivesockets[pi].acceptDone.arg0 = (uint8_t) passivesockets[pi].acceptinginto;
        memcpy(&passivesockets[pi].acceptDone.src_address, &addr->sin6_addr, sizeof(struct in6_addr));
        passivesockets[pi].acceptDone.src_port = ntohs(addr->sin6_port);
        passivesockets[pi].readycbs |= ACCEPT_DONE;
        passivesockets[pi].acceptinginto = -1;
        printf("Accepted connection!\n");
    }
    
    event void BSDTCPActiveSocket.connectDone[uint8_t ai](struct sockaddr_in6* addr) {
        activesockets[ai].readycbs |= CONNECT_DONE;
        printf("Connection done!\n");
    }
    
    event void BSDTCPActiveSocket.receiveReady[uint8_t ai]() {
        activesockets[ai].readycbs |= RECV_READY;
        printf("Receive ready!\n");
    }
    
    event void BSDTCPActiveSocket.sendReady[uint8_t ai]() {
        activesockets[ai].readycbs |= SEND_READY;
        printf("Send ready!\n");
    }
    
    event void BSDTCPActiveSocket.connectionLost[uint8_t ai](uint8_t how) {
        activesockets[ai].connectionLost.arg0 = how;
        activesockets[ai].readycbs |= CONNECTION_LOST;
        printf("Connection lost!\n");
    }
    
    default command error_t BSDTCPPassiveSocket.bind[uint8_t pundef](uint16_t port) {
        return EBADF;
    }
    
    default command error_t BSDTCPPassiveSocket.listenaccept[uint8_t pundef] (int activesockid) {
        return EBADF;
    }
    
    default command error_t BSDTCPPassiveSocket.close[uint8_t pundef] () {
        return EBADF;
    }
    
    default command error_t BSDTCPActiveSocket.bind[uint8_t aundef](uint16_t port) {
        return EBADF;
    }
    
    default command int BSDTCPPassiveSocket.getID[uint8_t pundef]() {
        return -1; // BE CAREFUL
    }
    
    default command int BSDTCPActiveSocket.getID[uint8_t aundef]() {
        return -1; // BE CAREFUL
    }
    
    default command int BSDTCPActiveSocket.getState[uint8_t aundef]() {
        return 0; // BE CAREFUL
    }
    
    default command error_t BSDTCPActiveSocket.connect[uint8_t aundef](struct sockaddr_in6* addr) {
        return EBADF;
    }
    
    default command error_t BSDTCPActiveSocket.send[uint8_t aundef](uint8_t* data, uint32_t length, int moretocome, size_t* bytessent) {
        return EBADF;
    }
    
    default command error_t BSDTCPActiveSocket.receive[uint8_t aundef](uint8_t* buffer, uint32_t length, size_t* bytessent) {
        return EBADF;
    }
    
    default command error_t BSDTCPActiveSocket.shutdown[uint8_t aundef](bool reads, bool writes) {
        return EBADF;
    }
    
    default command error_t BSDTCPActiveSocket.abort[uint8_t aundef]() {
        return EBADF;
    }
    
    int alloc_fd(uint32_t* mask, bool (*isvalid)(int) ) {
        int i;
        for (i = 0; i < NUMSOCKETS; i++) {
            if (!(*mask & (1 << i)) && isvalid(i)) {
                *mask |= (1 << i);
                return i;
            }
        }
        return -1;
    }
    
    bool always_true(int pi) {
        return TRUE;
    }
    
    int alloc_pfd() {
        int pfd = alloc_fd(&passivemask, always_true);
        if (pfd != -1) {
            passivesockets[pfd].readycbs = 0;
        }
        return pfd + NUMSOCKETS;
    }
    
    bool active_isclosed(int ai) {
        return TCPS_CLOSED == call BSDTCPActiveSocket.getState[ai]();
    }
    
    bool active_istimewait(int ai) {
        return TCPS_TIME_WAIT == call BSDTCPActiveSocket.getState[ai]();
    }
    
    int alloc_afd() {
        int afd;
        // First, try to get a socket that's closed.
        afd = alloc_fd(&activemask, active_isclosed);
        if (afd == -1) {
            // If that failed, try to get a socket in TIME-WAIT, and end the TIME-WAIT early.
            afd = alloc_fd(&activemask, active_istimewait);
            call BSDTCPActiveSocket.abort[afd]();
        }
        if (afd != -1) {
            activesockets[afd].readycbs = 0;
        }
        return afd;
    }
    
    void dealloc_fd(uint32_t fd, uint32_t* mask) {
        *mask &= ~(1 << fd);
    }
    
    void dealloc_afd(int afd) {
        dealloc_fd((uint32_t) afd, &activemask);
        clear_activesocket(afd);
    }
    
    void dealloc_pfd(int pfd) {
        dealloc_fd((uint32_t) pfd, &passivemask);
        clear_passivesocket(pfd);
    }
    
    inline int check_fd(uint32_t fd, uint32_t* mask) {
        return (*mask & (1 << fd));
    }
    
    int decode_fd(uint32_t rawfd, bool* passive) {
        if (rawfd >= NUMSOCKETS) {
            *passive = TRUE;
            rawfd -= NUMSOCKETS;
            if (!check_fd(rawfd, &passivemask)) {
                return -1;
            }
        } else {
            *passive = FALSE;
            if (!check_fd(rawfd, &activemask)) {
                return -1;
            }
        }
        return (int) rawfd;
    }
    
    async command syscall_rv_t Driver.syscall_ex(uint32_t number, uint32_t arg0, uint32_t arg1, uint32_t arg2, uint32_t* argx) {
        struct sockaddr_in6 addr;
        bool passive;
        uint8_t* buffer;
        int fd;
        int afd;
        size_t length;
        uint32_t svc_id;
        tcp_lite_callback_t* tostore;
        syscall_rv_t rv = (syscall_rv_t) EBADF;
        fd = decode_fd(arg0, &passive); // most syscalls need this info
        svc_id = number & 0xFF;
        switch (svc_id) {
            case 0x00: // passivesocket()
                rv = (syscall_rv_t) alloc_pfd();
                break;
            case 0x01: // activesocket()
                rv = (syscall_rv_t) alloc_afd();
                break;
            case 0x02: // bind(fd, lport)
                if (fd < 0) {
                    break;
                }
                if (passive) {
                    rv = (syscall_rv_t) call BSDTCPPassiveSocket.bind[fd]((uint16_t) arg1);
                    printf("Bound passive socket to port %d\n", arg1);
                } else {
                    rv = (syscall_rv_t) call BSDTCPActiveSocket.bind[fd]((uint16_t) arg1);
                    printf("Bound active socket to port %d\n", arg1);
                }
                break;
            case 0x03: // connect(fd, faddr, fport)
                if (fd < 0 || passive) {
                    break;
                }
                if (arg2 > 0xFFFF) {
                    rv = (syscall_rv_t) EINVAL;
                    break;
                }
                inet_pton6((char*) arg1, &addr.sin6_addr);
                addr.sin6_port = htons((uint16_t) arg2);
                rv = (syscall_rv_t) call BSDTCPActiveSocket.connect[fd](&addr);
                break;
            case 0x04: // listenaccept(fd)
                if (fd < 0 || !passive) {
                    break;
                }
                afd = alloc_afd();
                if (afd == -1) {
                    rv = (syscall_rv_t) ENFILE;
                    break;
                }
                passivesockets[fd].acceptinginto = afd;
                rv = (syscall_rv_t) call BSDTCPPassiveSocket.listenaccept[fd](call BSDTCPActiveSocket.getID[afd]());
                printf("Accepting into socket %d\n", afd);
                break;
            case 0x05: // send(fd, buffer, length, numbytes)
                if (fd < 0 || passive) {
                    break;
                }
                buffer = (uint8_t*) arg1;
                length = (size_t) arg2;
                rv = (syscall_rv_t) call BSDTCPActiveSocket.send[fd](buffer, length, 0, (size_t*) argx[0]);
                break;
            case 0x06: // receive(fd, buffer, length, numbytes)
                if (fd < 0 || passive) {
                    break;
                }
                buffer = (uint8_t*) arg1;
                length = (size_t) arg2;
                rv = (syscall_rv_t) call BSDTCPActiveSocket.receive[fd](buffer, length, (size_t*) argx[0]);
                break;
            case 0x07: // shutdown(fd, how)
                if (fd < 0 || passive) {
                    break;
                }
                rv = (syscall_rv_t) call BSDTCPActiveSocket.shutdown[fd]((arg1 == SHUT_RD) || (arg1 == SHUT_RDWR),
                                                                         (arg1 == SHUT_WR) || (arg1 == SHUT_RDWR));
                break;
            case 0x08: // close(fd)
                if (fd < 0) {
                    break;
                }
                if (passive) {
                    rv = (syscall_rv_t) call BSDTCPPassiveSocket.close[fd]();
                    dealloc_pfd(fd);
                    if (passivesockets[fd].acceptinginto != -1) {
                        dealloc_afd(passivesockets[fd].acceptinginto);
                        passivesockets[fd].acceptinginto = -1;
                    }
                } else {
                    rv = (syscall_rv_t) call BSDTCPActiveSocket.shutdown[fd](TRUE, TRUE);
                    dealloc_afd(fd);
                }
                break;
            case 0x09: // abort(fd)
                if (fd < 0 || passive) {
                    break;
                }
                rv = (syscall_rv_t) call BSDTCPActiveSocket.abort[fd]();
                break;
            case 0x0a: // set_connectDone_cb(fd, cb, r)
                if (fd < 0 || passive) {
                    break;
                }
                tostore = &activesockets[fd].connectDone;
                goto setcb;
            case 0x0b: // set_sendReady_cb(fd, cb, r)
                if (fd < 0 || passive) {
                    break;
                }
                tostore = &activesockets[fd].sendReady;
                goto setcb;
            case 0x0c: // set_recvReady_cb(fd, cb, r)
                if (fd < 0 || passive) {
                    break;
                }
                tostore = &activesockets[fd].recvReady;
                goto setcb;
            case 0x0d: // set_connectionLost_cb(fd, cb, r)
                if (fd < 0 || passive) {
                    break;
                }
                tostore = &activesockets[fd].connectionLost;
                goto setcb;
            case 0x0e: // set_acceptDone_cb(fd, cb, r)
                if (fd < 0 || !passive) {
                    break;
                }
                tostore = (tcp_lite_callback_t*) &passivesockets[fd].acceptDone;
            setcb:
                tostore->addr = arg1;
                tostore->r = (void*) arg2;
                rv = 0;
                break;
            default:
                printf("Doing nothing\n");
                break;
        }
        return rv;
    }
}
