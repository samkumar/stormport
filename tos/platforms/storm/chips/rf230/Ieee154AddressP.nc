
#ifndef LONG_ADDR_SUFFIX
#define LONG_ADDR_SUFFIX 0xDEAD
#endif

module Ieee154AddressP
{
  provides
  {
    interface Init;
    interface Ieee154Address;
  }
}
implementation
{
    ieee154_saddr_t m_saddr;
    ieee154_panid_t m_panid;

    command error_t Init.init() {
        m_saddr = TOS_NODE_ID;
        m_panid = TOS_AM_GROUP;
        return SUCCESS;
    }

    command ieee154_panid_t Ieee154Address.getPanId()
    {
        return m_panid;
    }
    command ieee154_saddr_t Ieee154Address.getShortAddr()
    {
        return m_saddr;
    }
    command ieee154_laddr_t Ieee154Address.getExtAddr()
    {
        ieee154_laddr_t addr;
        int i;
        uint8_t tmp;
       //addr.data[0] = (LONG_ADDR_SUFFIX) & 0xFF;
       //addr.data[1] = (LONG_ADDR_SUFFIX >> 8) & 0xFF;
       //addr.data[2] = 0x00;
       //addr.data[3] = 0x00;
       //addr.data[4] = 0x02; //Storm B.02
       //addr.data[5] = 0x6D; //Berkeley's OUI
       //addr.data[6] = 0x12;
       //addr.data[7] = 0x00;
       //addr.data[7] ^= 0x02; //for the u bit
        for (i = 0; i < 8; i++)
        {
            addr.data[i] = 0x55;
        }
        addr.data[7] = 0x57;
        return addr;
    }

    command error_t Ieee154Address.setShortAddr(ieee154_saddr_t addr) {
        m_saddr = addr;
        signal Ieee154Address.changed();
        return SUCCESS;
    }
}
