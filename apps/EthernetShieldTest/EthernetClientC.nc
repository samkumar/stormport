#include "printf.h"
#include <usarthardware.h>

module EthernetClientC
{
    uses interface Boot;
    uses interface HplSam4lUSART as SpiHPL;
    uses interface SpiPacket;
}
implementation
{
    event void Boot.booted()
    {
        printf("Configuring SPI\n");
        /*
         we aren't going to "enable RTS" pin, because it has to go
         low when we want to send/receive. So, when we want to send,
         we are going to treat it like we would an LED, call .clear().
         When we get a sendDone, we are going to call .set() in order
         to raise the SS
        */
        //call SpiHPL.enableUSARTPin(USART0_RTS_PA08);
        call SpiHPL.enableUSARTPin(USART0_CLK_PA10);
        call SpiHPL.enableUSARTPin(USART0_RX_PA11);
        call SpiHPL.enableUSARTPin(USART0_TX_PA12);
        call SpiHPL.initSPIMaster();
        call SpiHPL.setSPIMode(0,0);
        call SpiHPL.setSPIBaudRate(20000);
        call SpiHPL.enableTX();
        call SpiHPL.enableRX();
    }

    async event void SpiPacket.sendDone(uint8_t* txBuf, uint8_t* rxBuf, uint16_t len, error_t error)
    {
      printf("got: '%s'",rxBuf);
    }

}
