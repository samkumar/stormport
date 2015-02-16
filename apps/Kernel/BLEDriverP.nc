module BLEDriverP
{
    provides interface Driver;
    provides interface Init;
    uses interface BlePeripheral;
    uses interface BleLocalService as HelenaBleService;
    uses interface HelenaService;
    uses interface Timer<T32khz> as tmr;
}
implementation
{

    command error_t Init.init()
    {
        printf("BLED init called\n");
        call tmr.startOneShot(32000);
    }
    // BLE PERIPHERAL
    event void BlePeripheral.ready()
    {
        call HelenaBleService.configure();
        printf("Configured!\n");
        call BlePeripheral.startAdvertising();
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
        printf("timer fired, init BLE\n");
        call BlePeripheral.initialize();
    }
}