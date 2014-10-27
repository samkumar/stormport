
module LocalIeeeEui64P {
  provides {
    interface LocalIeeeEui64;
    interface Init;
  }
  uses interface FlashAttr;
}

implementation {
  ieee_eui64_t eui = {{0x00}};

  bool have_id = FALSE;
  uint16_t serial;


  task void loadSerial()
  {
        error_t e;
        uint8_t dat [10];
        uint8_t key [10];
        uint8_t val [65];
        uint8_t val_len;

        e = call FlashAttr.getAttr(0, key, val, &val_len);
        if (e != SUCCESS || val_len != 2)
        {
            printf("Could not load serial, using 0xBEEF\n");
            serial = 0xBEEF;
        }
        else
        {
            serial = val[0];
            serial = (serial << 8) + val[1];
            printf("SERIAL NUMBER 0x%04x\n", serial);
        }
  }
  command error_t Init.init() {
    post loadSerial();
  }
  command ieee_eui64_t LocalIeeeEui64.getId () {
    uint8_t buf[6] = {0};
    error_t e;

    if (!have_id) {

       eui.data[7] = (serial) & 0xFF;
       eui.data[6] = (serial >> 8) & 0xFF;
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