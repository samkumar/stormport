#include "tinyos_ble.h"
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

    uint8_t new_svc_handle = 0;
    uint8_t new_char_handle = 0;
    uint8_t device_online = 0;

    uint32_t connection_callback = 0;
    void* connection_r;
    uint32_t ready_callback = 0;
    void* ready_r;

    uint32_t write_callbacks[MAX_CHARS];
    void* write_rs[MAX_CHARS];

    event void BleLocalChar.indicateConfirmed[uint8_t id](){}
    event void BleLocalChar.timeout[uint8_t id](){}

    #define CBSIZE 16
    ble_callback_t cb_queue[CBSIZE];
    uint8_t cb_bufs[CBSIZE][24];
    int widx, ridx;


    command error_t Init.init()
    {
        int i;
        for (i=0;i<MAX_CHARS;i++) write_callbacks[i] = 0;
        widx = 0;
        ridx = 0;
        printf("BLED init called\n");

        call tmr.startOneShot(32000);
    }
    //Invoke the ready callback
    void push_ready_callback()
    {
        atomic
        {
            //We are assuming the buffer cannot be full at this time
            int nextw = (widx+1)&(CBSIZE-1);
            cb_queue[widx].addr = ready_callback;
            cb_queue[widx].r = ready_r;
            cb_queue[widx].arg0 = 0;
            cb_queue[widx].arg1 = 0;
            widx = nextw;
        }
    }
    // BLE PERIPHERAL
    event void BlePeripheral.ready()
    {
        device_online = 1;
        if (ready_callback != 0) //otherwise it will be called later
        {
            call BlePeripheral.startAdvertising();
            push_ready_callback();
        }

        //call HelenaBleService.configure();
        //call NrfBleService.createService[0](0x2005);
        //call NrfBleService.addCharacteristic[0](0x2003, 0);
        printf("BLE Ready!\n");

    }

    event void BlePeripheral.connected()
    {
        printf("[[ BLE PERIPHERAL CONNECTED ]]\n");
        if (connection_callback != 0)
        {
            int nextw = (widx+1)&(CBSIZE-1);
            if (nextw != ridx)
            {
                cb_queue[widx].addr = connection_callback;
                cb_queue[widx].r = connection_r;
                cb_queue[widx].arg0 = 1;
                cb_queue[widx].arg1 = 0;
                widx = nextw;
            }
        }
    }

    event void BleLocalChar.onWrite[uint8_t id](uint16_t len, uint8_t const *value)
    {
        if (len > 24) len = 24;
        atomic
        {
            int nextw = (widx+1)&(CBSIZE-1);
            if (write_callbacks[id] != 0 && nextw != ridx)
            {
                memcpy(cb_bufs[widx], value, len);
                cb_queue[widx].addr = write_callbacks[id];
                cb_queue[widx].r = write_rs[id];
                cb_queue[widx].arg0 = len;
                cb_queue[widx].arg1 = (uint32_t) (cb_bufs[widx]);
                widx = nextw;
            }
        }
    }
    event void BlePeripheral.disconnected()
    {
        printf("[[ BLE PERIPHERAL DISCONNECTED ]]\n");
        call BlePeripheral.startAdvertising();
        if (connection_callback != 0)
        {
            int nextw = (widx+1)&(CBSIZE-1);
            if (nextw != ridx)
            {
                cb_queue[widx].addr = connection_callback;
                cb_queue[widx].r = connection_r;
                cb_queue[widx].arg0 = 0;
                cb_queue[widx].arg1 = 0;
                widx = nextw;
            }
        }
    }

    event void BlePeripheral.advertisingTimeout()
    {
        call BlePeripheral.startAdvertising();
    }
    command driver_callback_t Driver.peek_callback()
    {
        if (ridx == widx)
        {
            return NULL;
        }
        return &cb_queue[ridx];
    }
    command void Driver.pop_callback()
    {
        int newridx = (ridx + 1) & (CBSIZE-1);
        ridx = newridx;
    }

    syscall_rv_t add_svc(uint16_t uuid)
    {
        if (new_svc_handle < MAX_SERVICES)
        {
            uint8_t svc_handle = new_svc_handle;
            new_svc_handle++;
            call NrfBleService.createService[svc_handle](uuid);
            return svc_handle;
        }
        else
        {
            return -1;
        }
    }
    syscall_rv_t add_char(uint8_t svc_handle, uint16_t uuid, uint32_t write_callback, void* write_r)
    {
        if (svc_handle < new_svc_handle && new_char_handle < MAX_CHARS)
        {
            uint8_t char_handle = new_char_handle;
            new_char_handle++;
            call NrfBleService.addCharacteristic[svc_handle](uuid, char_handle);
            write_callbacks[char_handle] = write_callback;
            write_rs[char_handle] = write_r;
            return char_handle;
        }
        else
        {
            return -1;
        }

    }

    async command syscall_rv_t Driver.syscall_ex(
        uint32_t number, uint32_t arg0,
        uint32_t arg1, uint32_t arg2,
        uint32_t *argx)
    {
        switch(number & 0xFF)
        {
            case 0x01: //Enable bluetooth(ready_callback, ready_r, connection_callback, connection_r) cb(uint8_t) 1=connected, 0=disconnected
            {
                ready_callback = arg0;
                ready_r = (void*) arg1;
                connection_callback = arg2;
                connection_r = (void*)argx[0];
                if (device_online)
                {
                    call BlePeripheral.startAdvertising();
                    push_ready_callback();
                }
                return 0;
            }
            case 0x02: //AddService(uuid) -> handle
            {
                return add_svc(arg0);
            }
            case 0x03: //Add characteristic(svc_handle, uuid, write_callback, write_r);
            {
                return add_char(arg0, arg1, arg2, (void*) argx[0]);
            }
            case 0x04: //Notify (char_handle, uint8_t len, char* data)
            {
                if (device_online && arg0 < new_char_handle && arg1 < 24)
                {
                    call BleLocalChar.notify[arg0](arg1, (uint8_t*)arg2);
                    return 0;
                }
                else
                {
                    return -1;
                }
            }
        }
    }

    event void tmr.fired()
    {
        call BlePeripheral.initialize();
       // call HelenaService.notify(0x55,0x6677);
    }
}