#include <aesahardware.h>

module HplSam4lAESAP
{
    provides interface HplSam4lAESA;
    provides interface Init;
    uses interface HplSam4PeripheralClockCntl as ClockCtl;
}
implementation
{
    command error_t Init.init()
    {
        call ClockCtl.enable();
        //We might need to enable gclk4
        //SCIF base = 0x400E0800, off= 0x0084
        //oscsel=7 (cpu)
        //div=10?
        *((volatile uint32_t *) 0x400E0884) = 0x00000701;
        AESA->ctrl.bits.enable = 1;
        AESA->ctrl.bits.swrst = 1;
        AESA->ctrl.bits.enable = 1;

        AESA->mode.flat = 0;
        AESA->mode.bits.opmode = 1; //Cipher block chaining
    }
    typedef union
    {
        uint8_t u8 [4];
        uint32_t u32;
    } split_u32_t;

    command void HplSam4lAESA.SetKey(uint8_t* key)
    {
        split_u32_t buf;
        int i;
        for (i=0;i < 32; i++)
        {
            buf.u8[i&3] = key[i];
            if (i&3 == 3)
            {
                AESA->key[i>>2] = buf.u32;
            }
        }
    }
    void x_message(uint8_t *iv, uint16_t len, uint8_t *message, uint8_t *dest)
    {
        split_u32_t buf;
        int i, k;
        int ocount = 0;
        int icount = 0;
        char* out = dest;
        AESA->ctrl.bits.newmsg = 1;

        for (i=0;i < 16; i++)
        {
            buf.u8[i&3] = iv[i];
            if (i&3 == 3)
            {
                AESA->iv[i>>2] = buf.u32;
            }
        }
        AESA->databufptr.bits.idataw = 0;
        AESA->databufptr.bits.odataw = 0;

        i=0;
        while ( icount < len/4 || ocount < len/4 )
        {
            if (AESA->sr.bits.ibufrdy && icount < len/4)
            {
                buf.u8[0] = message[i++];
                buf.u8[1] = message[i++];
                buf.u8[2] = message[i++];
                buf.u8[3] = message[i++];
                AESA->idata = buf.u32;
                icount++;
            }
            if (AESA->sr.bits.odatardy && ocount < len/4)
            {
                buf.u32 = AESA->odata;
                *dest++ = buf.u8[0];
                *dest++ = buf.u8[1];
                *dest++ = buf.u8[2];
                *dest++ = buf.u8[3];
                ocount++;
            }
        }
    }
    command void HplSam4lAESA.DecryptMessage(uint8_t *iv, uint16_t len, uint8_t *message, uint8_t *dest)
    {
        AESA->mode.bits.encrypt = 0;
        x_message(iv, len, message, dest);
    }
    command void HplSam4lAESA.EncryptMessage(uint8_t *iv, uint16_t len, uint8_t *message, uint8_t *dest)
    {
        AESA->mode.bits.encrypt = 1;
        x_message(iv, len, message, dest);
    }
}