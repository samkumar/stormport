
configuration PlatformLedC {
  provides {
    interface MultiLed;
    interface Led[uint8_t led_id];
  }
} implementation {

  components PlatformLedP;

  MultiLed = PlatformLedP;
  Led = PlatformLedP;

}