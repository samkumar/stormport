interface SocketSpi
{
    // writes data at *buf with length len to register at address reg_addr
    command void writeRegister(uint16_t reg_addr, uint8_t *buf, uint8_t len);

    // reads len bytes from register at address reg_addr
    // it will use the first 4 bytes of *buf to send the read command, which is why we pass it
    command void readRegister(uint16_t reg_addr, uint8_t *buf, uint8_t len);

    // signaled when write or read is finished. If the command was read,
    // then the results will be stored at *buf with length len
    event void taskDone(error_t, uint8_t *buf, uint8_t len);
}
