
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
        m_saddr = 0x37;
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
        /* the LocalIeeeEui is big endian */
        /* however, Ieee 802.15.4 addresses are little endian */
        for (i = 0; i < 8; i++) {
          tmp = addr.data[i];
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
