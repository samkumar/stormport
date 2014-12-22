#ifndef __ETHERNETSHIELD_H__
#define __ETHERNETSHIELD_H__

#define SOCKET_ID "EthernetShield.SocketID"
#define ETHERNETRESOURCE_ID "EthernetResource.Id"

typedef enum
{
    SocketType_UDP,
    SocketType_TCP,
    SocketType_IPRAW,
    SocketType_GRE
} SocketType;

// socket states
typedef enum
{
    SocketState_CLOSED      = 0x00,
    SocketState_INIT        = 0x13,
    SocketState_LISTEN      = 0x14,
    SocketState_SYNSENT     = 0x15,
    SocketState_SYNRECV     = 0x16,
    SocketState_ESTABLISHED = 0x17,
    SocketState_FIN_WAIT    = 0x18,
    SocketState_CLOSING     = 0x1A,
    SocketState_TIME_WAIT   = 0x1B,
    SocketState_CLOSE_WAIT  = 0x1C,
    SocketState_LAST_ACK    = 0x1D,
    SocketState_UDP         = 0x22,
    SocketState_IPRAW       = 0x32,
    SocketState_MACRAW      = 0x42,
    SocketState_PPPOE       = 0x5F
} SocketState;

typedef enum
{
    SocketInterrupt_SEND_OK = 0x10,
    SocketInterrupt_TIMEOUT = 0x08,
    SocketInterrupt_RECV    = 0x04,
    SocketInterrupt_DISON   = 0x02,
    SocketInterrupt_CON     = 0x01
} SocketInterrupt;

// socket modes
typedef enum
{
    SocketMode_CLOSE  = 0x00,
    SocketMode_TCP    = 0x01,
    SocketMode_UDP    = 0x02,
    SocketMode_IPRAW  = 0x03,
    SocketMode_MACRAW = 0x04,
    SocketMode_PPPOE  = 0x05
} SocketMode;

// socket commands
typedef enum
{
    SocketCommand_OPEN      = 0x01,
    SocketCommand_LISTEN    = 0x02,
    SocketCommand_CONNECT   = 0x04,
    SocketCommand_DISCON    = 0x08,
    SocketCommand_CLOSE     = 0x10,
    SocketCommand_SEND      = 0x20,
    SocketCommand_SEND_MAC  = 0x21,
    SocketCommand_SEND_KEEP = 0x22,
    SocketCommand_RECV      = 0x40
} SocketCommand;

typedef enum
{
    state_init_readsockstate,
    state_init_write_protocol,
    state_init_write_src_port,
    state_init_open_src_port,
    state_init_read_src_port_opened,
    state_init_wait_src_port_opened,
    state_init_success,
    state_init_fail
} SocketInitUDPState;

typedef enum
{
    state_connect_write_dst_ipaddress,
    state_connect_write_dst_port,
    state_connect_write_connect,
    state_connect_read_connect,
    state_connect_wait_connect,
    state_connect_connect_dst,
    state_connect_wait_connect_dst,
    state_connect_wait_established,
    state_writeudp_copytotxbuf,
    state_writeudp_advancetxwr,
    state_writeudp_writesendcmd,
    state_writeudp_readsendcmd,
    state_writeudp_waitsendcomplete,
    state_writeudp_waitsendinterrupt,
    state_writeudp_clearsend,
    state_writeudp_cleartimeout,
    state_writeudp_finished,
    state_writeudp_error
} SocketSendUDPState;

typedef enum
{
    state_recv_init,
    state_recv_clear_interrupt,
    state_recv_read_incoming_size,
    state_recv_check_socket,
    state_recv_getsize,
    state_recv_giveup,
    state_recv_snrx_rd,
    state_recv_assemble_header,
    state_recv_finish_header,
    state_recv_read_packet,
    state_recv_read_morepacket,
    state_recv_increment_snrx_rd,
    state_recv_write_read,
    state_recv_read_read,
    state_recv_wait_write_read,
    state_recv_finished
} SocketRecvUDPState;

const uint16_t TXBUF_BASE = 0x8000;
const uint16_t TXBUF_SIZE = 2048;
const uint16_t TXMASK = 0x07FF;
uint16_t TXBASE;

const uint16_t RXBUF_BASE = 0xC000;
const uint16_t RXBUF_SIZE = 2048;
const uint16_t RXMASK = 0x07FF;
uint16_t RXBASE;


#endif
