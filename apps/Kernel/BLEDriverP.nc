module BLEDriverP
{
    provides interface Driver;
    provides interface Init;
    uses interface BlePeripheral;
    uses interface BleLocalChar[uint8_t id];
    uses interface NrfBleService[uint8_t id];
    uses interface Timer<T32khz> as tmr;
}
implementation
{

    //The payload may configure characteristics and services before
    //the coprocessor is ready. This will configure those when the chip is
    //ok
    void configure_backlog()
    {

    }
    event void BleLocalChar.onWrite[uint8_t id](uint16_t len, uint8_t const *value) {}
    event void BleLocalChar.indicateConfirmed[uint8_t id](){}
    event void BleLocalChar.timeout[uint8_t id](){}
    command error_t Init.init()
    {
        printf("BLED init called\n");

        call tmr.startOneShot(32000);
    }
    // BLE PERIPHERAL
    event void BlePeripheral.ready()
    {
        call BlePeripheral.startAdvertising();
        //call HelenaBleService.configure();
        call NrfBleService.createService[0](0x2005);
        call NrfBleService.addCharacteristic[0](0x2003, 0);
        printf("Configured!\n");

    }

    event void BlePeripheral.connected()
    {
        printf("[[ BLE PERIPHERAL CONNECTED ]]\n");
    }

    event void BlePeripheral.disconnected()
    {
        printf("[[ BLE PERIPHERAL DISCONNECTED ]]\n");
        call BlePeripheral.startAdvertising();
    }

    event void BlePeripheral.advertisingTimeout()
    {
        call BlePeripheral.startAdvertising();
    }
    command driver_callback_t Driver.peek_callback()
    {
        return NULL;
    }
    command void Driver.pop_callback()
    {

    }

    async command syscall_rv_t Driver.syscall_ex(
        uint32_t number, uint32_t arg0,
        uint32_t arg1, uint32_t arg2,
        uint32_t *argx)
    {

    }

    event void tmr.fired()
    {
        call BlePeripheral.initialize();
       // call HelenaService.notify(0x55,0x6677);
    }
}