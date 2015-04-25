module AESDriverP
{
    provides interface Driver;
    provides interface Init;
    uses interface HplSam4lAESA;
    uses interface Init as hplinit;
}
implementation
{
    command error_t Init.init()
    {
        //call hplinit.init();
    }

    command driver_callback_t Driver.peek_callback()
    {
        return NULL;
    }
    command void Driver.pop_callback()
    {
        return;
    }

    async command syscall_rv_t Driver.syscall_ex(
        uint32_t number, uint32_t arg0,
        uint32_t arg1, uint32_t arg2,
        uint32_t *argx)
    {
        switch(number & 0xFF)
        {
            case 0x01: //encrypt(iv(16), mlen, message, dest)
                call HplSam4lAESA.EncryptMessage((char*)arg0, arg1, (char*)arg2, (char*) argx[0]);
                return 0;
            case 0x02: //decrypt(iv(16), mlen, message, dest)
                call HplSam4lAESA.DecryptMessage((char*)arg0, arg1, (char*)arg2, (char*) argx[0]);
                return 0;
            case 0x03: //setkey(key(32))
                call HplSam4lAESA.SetKey((char*)arg0);
                return 0;
            break;

        }
    }
}