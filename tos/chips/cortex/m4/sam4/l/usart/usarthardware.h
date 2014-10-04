
#ifndef USARTHARDWARE_H
#define USARTHARDWARE_H

#define SAM4L_USART0 "HalSam4lUSARTC.USART0"
#define SAM4L_USART1 "HalSam4lUSARTC.USART1"
#define SAM4L_USART2 "HalSam4lUSARTC.USART2"
#define SAM4L_USART3 "HalSam4lUSARTC.USART3"

#define USARTPIN(PORT, NUMBER, PERIPHERAL) (((PORT) << 16) | ((NUMBER) << 8) | (PERIPHERAL))
typedef enum {
  USART0_CLK_PA04 = USARTPIN(0, 4,1), //B
  USART0_RX_PA05  = USARTPIN(0, 5,1),//B
  USART0_RTS_PA06 = USARTPIN(0, 6,1),//B
  USART0_TX_PA07  = USARTPIN(0, 7,1),//B
  USART0_RTS_PA08 = USARTPIN(0, 8,0),//A
  USART0_CTS_PA09 = USARTPIN(0, 9,0),//A
  USART0_CLK_PA10 = USARTPIN(0,10,0),//A
  USART0_RX_PA11  = USARTPIN(0,11,0),//A
  USART0_TX_PA12  = USARTPIN(0,12,0),//A
  USART1_RTS_PA13 = USARTPIN(0,13,0),//A
  USART1_CLK_PA14 = USARTPIN(0,14,0),//A
  USART1_RX_PA15  = USARTPIN(0,15,0),//A
  USART1_TX_PA16  = USARTPIN(0,16,0),//A
  USART2_RTS_PA17 = USARTPIN(0,17,0),//A
  USART2_CLK_PA18 = USARTPIN(0,18,0),//A
  USART2_RXD_PA19 = USARTPIN(0,19,0),//A
  USART2_TXD_PA20 = USARTPIN(0,20,0),//A
  USART1_CTS_PA21 = USARTPIN(0,21,1),//B
  USART2_CTS_PA22 = USARTPIN(0,22,1),//B
  USART2_RX_PA25  = USARTPIN(0,25,1),//B
  USART2_TX_PA26  = USARTPIN(0,26,1),//B
// USART3_RTS_PA27 = //E
// USART3_CTS_PA28 = //E
// USART3_CLK_PA29 = //E
// USART3_RX_PA30  = //E
// USART3_TX_PA31  = //E
  USART0_RX_PB00  = USARTPIN(1, 0,1),//B
  USART0_TX_PB01  = USARTPIN(1, 1,1),//B
  USART1_RTS_PB02 = USARTPIN(1, 2,1),//b
  USART1_CLK_PB03 = USARTPIN(1, 3,1),//b
  USART1_RX_PB04  = USARTPIN(1, 4,1),//b
  USART1_TX_PB05  = USARTPIN(1, 5,1),//b
  USART3_RTS_PB06 = USARTPIN(1, 6,0),//A
  USART3_CTS_PB07 = USARTPIN(1, 7,0),//A
  USART3_CLK_PB08 = USARTPIN(1, 8,0),//A
  USART3_RX_PB09  = USARTPIN(1, 9,0),//A
  USART3_TX_PB10  = USARTPIN(1,10,0),//A
  USART0_CTS_PB11 = USARTPIN(1,11,0),//A
  USART0_RTS_PB12 = USARTPIN(1,12,0),//A
  USART0_CLK_PB13 = USARTPIN(1,13,0),//A
  USART0_RX_PB14  = USARTPIN(1,14,0),//A
  USART0_TX_PB15  = USARTPIN(1,15,0),//A
  USART0_CLK_PC00 = USARTPIN(2, 0,1),//B
  USART0_RTS_PC01 = USARTPIN(2, 1,1),//B
  USART0_CTS_PC02 = USARTPIN(2, 2,1),//B
  USART0_RX_PC02  = USARTPIN(2, 2,2),//C
  USART0_TX_PC03  = USARTPIN(2, 3,2),//C
  USART2_RTS_PC07 = USARTPIN(2, 7,1),//B
  USART2_CLK_PC08 = USARTPIN(2, 8,1),//B
  USART2_CTS_PC08 = USARTPIN(2, 8,4),//E
  USART3_RX_PC09  = USARTPIN(2, 9,1),//B
  USART3_TX_PC10  = USARTPIN(2,10,1),//B
  USART2_RX_PC11  = USARTPIN(2,11,1),//B
  USART2_TX_PC12  = USARTPIN(2,12,1),//B
  USART3_RTS_PC13 = USARTPIN(2,13,1),//B
  USART3_CLK_PC14 = USARTPIN(2,14,1),//B
  USART1_RTS_PC24 = USARTPIN(2,24,0),//A
  USART1_CLK_PC25 = USARTPIN(2,25,0),//A
  USART1_RX_PC26  = USARTPIN(2,26,0),//A
  USART1_TX_PC27  = USARTPIN(2,27,0),//A
  USART3_RX_PC28  = USARTPIN(2,28,0),//A
  USART3_TX_PC29  = USARTPIN(2,29,0),//A
  USART3_RTS_PC30 = USARTPIN(2,30,0),//A
  USART3_CLK_PC31 = USARTPIN(2,31,0)//A
} usart_pin_t;
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

usart_t volatile * const USART0 = (usart_t volatile *) USART_BASE_ADDRESS + (USART_SIZE * 0);
usart_t volatile * const USART1 = (usart_t volatile *) USART_BASE_ADDRESS + (USART_SIZE * 1);
usart_t volatile * const USART2 = (usart_t volatile *) USART_BASE_ADDRESS + (USART_SIZE * 2);
usart_t volatile * const USART3 = (usart_t volatile *) USART_BASE_ADDRESS + (USART_SIZE * 3);

#endif