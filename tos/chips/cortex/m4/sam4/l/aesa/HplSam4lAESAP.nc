#include <aesahardware.h>

module HplSam4lAESAP
{
    provides interface HplSam4lAESA;
    provides interface Init;
    uses interface HplSam4PeripheralClockCntrl as ClockCtl;
}
implementation
{
    command void Init.init()
    {
        call ClockCtl.enable();
        AESA->ctrl.bits.enable = 1;
        AESA->ctrl.bits.swrst = 1;
        AESA->mode.flat = 0;
        AESA->mode.bits.opmode = 1; //Cipher block chaining
    }
    typedef union
    {
        uint8_t u8 [4];
        uint32_t u32;
    } split_u32_t;

    command void HplSam4lAESA.DecryptMessage(uint32_t iv[4], uint16_t len, uint8_t *message, uint8_t *dest)
    {
        split_u32_t buf;
        int i;
        AESA->ctrl.bits.newmsg = 1;

        AESA->databufptr.bits.idataw = 0;
        for (i=0;i<len;i++)
        {
            buf.u8[i&3] = message[i];
            if (i&3 == 3)
            {
                AESA->databufptr.bits.idataw = (i+1)>>2;
            }
            if (i&15 == 15)
            {

            }
        }
    }
    event void DecryptionDone();
}