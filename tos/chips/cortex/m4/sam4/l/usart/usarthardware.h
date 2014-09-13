
#ifndef USARTHARDWARE_H
#define USARTHARDWARE_H

#define SAM4L_USART0 "HalSam4lUSARTC.USART0"
#define SAM4L_USART1 "HalSam4lUSARTC.USART0"
#define SAM4L_USART2 "HalSam4lUSARTC.USART0"
#define SAM4L_USART3 "HalSam4lUSARTC.USART0"

enum {
  TOS_UART_1200   = 1200,
  TOS_UART_1800   = 1800,
  TOS_UART_2400   = 2400,
  TOS_UART_4800   = 4800,
  TOS_UART_9600   = 9600,
  TOS_UART_19200  = 19200,
  TOS_UART_38400  = 38400,
  TOS_UART_57600  = 57600,
  TOS_UART_76800  = 76800,
  TOS_UART_115200 = 115200,
  TOS_UART_230400 = 230400,
  TOS_UART_750000 = 750000,
  TOS_UART_1500000 = 1500000,
  TOS_UART_3000000 = 3000000
};

enum {
  TOS_UART_OFF,
  TOS_UART_RONLY,
  TOS_UART_TONLY,
  TOS_UART_DUPLEX
};

enum {
  TOS_UART_PARITY_NONE,
  TOS_UART_PARITY_EVEN,
  TOS_UART_PARITY_ODD
};

typedef uint32_t uart_speed_t;
typedef uint8_t uart_parity_t;
typedef uint8_t uart_duplex_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t reserved0  : 2;
        uint32_t rstrx      : 1;
        uint32_t rsttx      : 1;
        uint32_t rxen       : 1;
        uint32_t rxdis      : 1;
        uint32_t txen       : 1;
        uint32_t txdis      : 1;
        uint32_t rststa     : 1;
        uint32_t sttbrk     : 1;
        uint32_t stpbrk     : 1;
        uint32_t sttto      : 1;
        uint32_t senda      : 1;
        uint32_t rstit      : 1;
        uint32_t rstnack    : 1;
        uint32_t retto      : 1;
        uint32_t dtren      : 1;
        uint32_t dtrdis     : 1;
        uint32_t rtsen_fcs  : 1;
        uint32_t rtsdis_rcs : 1;
        uint32_t linabt     : 1;
        uint32_t linwkup    : 1;
        uint32_t reserved2  : 10;
    } __attribute__((__packed__)) bits;
} usart_cr_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t mode           : 4;
        uint32_t usclks         : 2;
        uint32_t chrl           : 2;
        uint32_t sync_cpha      : 1;
        uint32_t par            : 3;
        uint32_t nbstop         : 2;
        uint32_t chmode         : 2;
        uint32_t msbf_cpol      : 1;
        uint32_t mode9          : 1;
        uint32_t clko           : 1;
        uint32_t over           : 1;
        uint32_t inack          : 1;
        uint32_t dsnack         : 1;
        uint32_t var_sync       : 1;
        uint32_t invdata        : 1;
        uint32_t max_iteration  : 3;
        uint32_t reserved0      : 1;
        uint32_t filter         : 1;
        uint32_t man            : 1;
        uint32_t modsync        : 1;
        uint32_t onebit         : 1;
    } __attribute__((__packed__)) bits;
} usart_mr_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t rxrdy      : 1;
        uint32_t txrdy      : 1;
        uint32_t rxbrk      : 1;
        uint32_t reserved0  : 2;
        uint32_t ovre       : 1;
        uint32_t frame      : 1;
        uint32_t pare       : 1;
        uint32_t timeout    : 1;
        uint32_t txempty    : 1;
        uint32_t iter_unre  : 1;
        uint32_t reserved1  : 1;
        uint32_t rxbuff     : 1;
        uint32_t nack_linbk : 1;
        uint32_t linid      : 1;
        uint32_t lintc      : 1;
        uint32_t riic       : 1;
        uint32_t dsric      : 1;
        uint32_t dcdic      : 1;
        uint32_t ctsic      : 1;
        uint32_t mane       : 1;
        uint32_t reserved2  : 3;
        uint32_t manea      : 1;
        uint32_t linbe      : 1;
        uint32_t linisfe    : 1;
        uint32_t linipe     : 1;
        uint32_t lince      : 1;
        uint32_t linsnre    : 1;
        uint32_t linste     : 1;
        uint32_t linhte     : 1;
    } __attribute__((__packed__)) bits;
} usart_ixr_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t rxrdy      : 1;
        uint32_t txrdy      : 1;
        uint32_t rxbrk      : 1;
        uint32_t reserved0  : 2;
        uint32_t ovre       : 1;
        uint32_t frame      : 1;
        uint32_t pare       : 1;
        uint32_t timeout    : 1;
        uint32_t txempty    : 1;
        uint32_t iter_unre  : 1;
        uint32_t reserved1  : 1;
        uint32_t rxbuff     : 1;
        uint32_t nack_linbk : 1;
        uint32_t linid      : 1;
        uint32_t lintc      : 1;
        uint32_t riic       : 1;
        uint32_t dsric      : 1;
        uint32_t dcdic      : 1;
        uint32_t ctsic      : 1;
        uint32_t ri         : 1;
        uint32_t dsr        : 1;
        uint32_t dcd        : 1;
        uint32_t cts_linbls : 1;
        uint32_t manerr     : 1;
        uint32_t linbe      : 1;
        uint32_t linisfe    : 1;
        uint32_t linipe     : 1;
        uint32_t lince      : 1;
        uint32_t linsnre    : 1;
        uint32_t linste     : 1;
        uint32_t linhte     : 1;
    } __attribute__((__packed__)) bits;
} usart_csr_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t rxchr      : 9;
        uint32_t reserved0  : 6;
        uint32_t rxsynh     : 1;
        uint32_t reserved1  : 16;
    } __attribute__((__packed__)) bits;
} usart_rhr_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t txchr      : 9;
        uint32_t reserved0  : 6;
        uint32_t txsynh     : 1;
        uint32_t reserved1  : 16;
    } __attribute__((__packed__)) bits;
} usart_thr_t;

typedef union
{
    uint32_t flat;
    struct
    {
        uint32_t cd         : 16;
        uint32_t fp         : 3;
        uint32_t reserved0  : 13;
    } __attribute__((__packed__)) bits;
} usart_brgr_t;

enum
{
    USART_MODE_NORMAL,
    USART_MODE_RS486,
    USART_MODE_HARDWARE_HANDSHAKE,
    USART_MODE_MODEM,
    USART_MODE_ISO7816_T0,
    USART_MODE_ISO7816_T1,
    USART_MODE_IRDA,
    USART_MODE_LIN_MASTER,
    USART_MODE_LIN_SLAVE,
    USART_MODE_SPI_MASTER,
    USART_MODE_SPI_SLAVE
};

typedef struct
{
    usart_cr_t      cr;
    usart_mr_t      mr;
    usart_ixr_t     ier;
    usart_ixr_t     idr;
    usart_ixr_t     imr;
    usart_csr_t     csr;
    usart_rhr_t     rhr;
    usart_thr_t     thr;
    //0x20
    usart_brgr_t    brgr;
    uint32_t        rtor;
    uint32_t        ttgr;
    uint32_t        reserved0[5];
    //0x40
    uint32_t        fidi;
    uint32_t        ner;
    uint32_t        reserved1;
    uint32_t        ifr;
    uint32_t        man;
    uint32_t        linmr;
    uint32_t        linir;
    uint32_t        linbr;
} usart_t;

enum
{
    USART_SIZE         = 0x4000,
    USART_BASE_ADDRESS = 0x40024000
};

#endif