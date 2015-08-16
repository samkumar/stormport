#include <usarthardware.h>

#define BL_PECS_RECV_BUF_LEN 128

module BlePECSP
{
    provides {
        interface Driver;
    }
    uses {
        interface HplSam4lUSART;
        interface UartControl;
        interface UartStream;
    }
}
implementation
{
    uint8_t receiveBuffer[BL_PECS_RECV_BUF_LEN];
    int head = 0;
    int tail = 0;
    int retrieved_from_buffer;
    
    uint8_t buffer[20];
    uint8_t sendBuffer[20];
    
    
    int32_t default_finished;
    int32_t* finished = &default_finished;
    
    simple_callback_t callback;
    
    int receive_pending = 0;
    int callback_pending = 0;

    async event void UartStream.sendDone(uint8_t* buf, uint16_t len, error_t error) {
        int i;
        if (error != SUCCESS) {
            printf("ERROR: string ");
            for (i = 0; i < len; i++) {
                printf("%c", buf[i]);
            }
            printf(" could not be send over bluetooth [error code %d]\n", error);
        }
    }
    
    async event void UartStream.receivedByte(uint8_t byte) {
        receiveBuffer[tail] = byte;
        tail = (tail + 1) % BL_PECS_RECV_BUF_LEN;
        if (tail == head) {
            printf("WARNING: Bluetooth buffer is full and was automatically cleared.\n");
        }
    }
    
    async event void UartStream.receiveDone(uint8_t* buf, uint16_t len, error_t error) {
        head = (head + len) % BL_PECS_RECV_BUF_LEN; // skip over these buffered data
        if (error != SUCCESS) {
            *finished = -1;
        } else {
            *finished = retrieved_from_buffer + len;
        }
        receive_pending = 0;
        callback_pending = 1;
    }
    
    
    command driver_callback_t Driver.peek_callback() {
        if (callback_pending) {
            return (driver_callback_t) &callback;
        }
        return NULL;
    }
    
    command void Driver.pop_callback() {
        callback_pending = 0;
    }
    
    async command syscall_rv_t Driver.syscall_ex(uint32_t number, uint32_t arg0, uint32_t arg1, uint32_t arg2, uint32_t* argx) {
        uint8_t* data;
        int i;
        switch (number & 0xFF) {
        case 0x00: // initialize
            printf("Initializing BlePECS\n");
        
            call HplSam4lUSART.enableUSARTPin(USART1_RX_PB04);
            call HplSam4lUSART.enableUSARTPin(USART1_TX_PB05);
            call HplSam4lUSART.initUART();
            call HplSam4lUSART.enableTX();
            call HplSam4lUSART.enableRX();
            
            call HplSam4lUSART.setUartBaudRate(9600);
            
            call UartControl.setDuplexMode(TOS_UART_DUPLEX);
            call UartControl.setSpeed(9600);
            
            call UartStream.enableReceiveInterrupt();
            break;
        case 0x02:
            data = (uint8_t*) arg0;
            if (arg1 > 20) {
                arg1 = 20;
            }
            for (i = 0; i < arg1; i++) {
                sendBuffer[i] = data[i];
            }
            call UartStream.send(sendBuffer, arg1);
            break;
        case 0x03:
            /** Receives from the UART for bluetooth. arg0 is the buffer to
            store into, arg1 is the length of the buffer, arg2 is a pointer
            to an int32_t. Once the message is fully received, the integer
            that arg2 points to will be set to the length of the received
            message, or -1 if there was an error receiving the message. argx[0]
            is a function pointer to a callback that will be invoked when the
            message is fully received. */
            if (callback_pending || receive_pending) {
                return -1;
            }
            callback.addr = argx[0];
            finished = (int32_t*) arg2;
            data = (uint8_t*) arg0;
            i = tail - head;
            if (i < 0) {
                i += BL_PECS_RECV_BUF_LEN;
            } // now i is the number of elements waiting on the queue
            if (i >= arg1) {
                for(i = 0; i < arg1; i++) {
                    data[i] = receiveBuffer[(head + i) % BL_PECS_RECV_BUF_LEN];
                }
                head = (head + arg1) % BL_PECS_RECV_BUF_LEN;
                *finished = arg1;
                callback_pending = 1;
            } else {
                arg1 -= i;
                retrieved_from_buffer = i;
                for (; head != tail; head = (head + 1) % BL_PECS_RECV_BUF_LEN) {
                    *(data++) = receiveBuffer[head];
                }
                receive_pending = 1;
                call UartStream.receive(data, arg1);
            }
            break;
        case 0x04: // clear the bluetooth buffer. Don't do this while a receive is taking place.
            tail = head;
            break;
        default:
            printf("PECS BLE Module does not support syscall %x\n", number);
            return -1;
        }
        return 0;
    }
}
