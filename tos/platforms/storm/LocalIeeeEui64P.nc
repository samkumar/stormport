
#ifndef LONG_ADDR_SUFFIX
#define LONG_ADDR_SUFFIX 0xDEAD
#endif

module LocalIeeeEui64P {
  provides {
    interface LocalIeeeEui64;
  }

}

implementation {
  ieee_eui64_t eui = {{0x00}};

  bool have_id = FALSE;

  command ieee_eui64_t LocalIeeeEui64.getId () {
    uint8_t buf[6] = {0};
    error_t e;

    if (!have_id) {
       eui.data[7] = (LONG_ADDR_SUFFIX) & 0xFF;
       eui.data[6] = (LONG_ADDR_SUFFIX >> 8) & 0xFF;
       eui.data[5] = 0x00;
       eui.data[4] = 0x00;
       eui.data[3] = 0x02; //Storm B.02
       eui.data[2] = 0x6D; //Berkeley's OUI
       eui.data[1] = 0x12;
       eui.data[0] = 0x00;
        have_id = TRUE;
      }
    return eui;
  }
}