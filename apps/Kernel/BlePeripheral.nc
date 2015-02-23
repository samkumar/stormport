//Header Files
//

interface BlePeripheral
{
  command void initialize();

  command error_t startAdvertising(uint8_t *data, uint8_t len);

  command error_t stopAdvertising(void);

  /*Interface reset or ready for first time. */
  event void ready();

  /*Connection established. */
  event void connected();

  /*Disconnected from peer. */
  event void disconnected();

  /*Timeout expired.*/
  event void advertisingTimeout(); 
}
