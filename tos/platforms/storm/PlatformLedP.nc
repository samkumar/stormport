
module PlatformLedP {
  provides {
    interface MultiLed;
    interface Led[uint8_t led_id];
  }
} implementation {

  async command void Led.on[ uint8_t led_id ] ()
  {

  }

  async command void Led.off[ uint8_t led_id ] ()
  {

  }

  async command void Led.set[ uint8_t led_id ] (bool turn_on)
  {

  }

  async command void Led.toggle[ uint8_t led_id ] ()
  {

  }

  async command unsigned int MultiLed.get () { return 0;}

  async command void MultiLed.set (unsigned int val) {  }

  async command void MultiLed.on (unsigned int led_id) {  }

  async command void MultiLed.off (unsigned int led_id) {  }

  async command void MultiLed.setSingle (unsigned int led_id, bool turn_on) {  }

  async command void MultiLed.toggle (unsigned int led_id) {  }

}