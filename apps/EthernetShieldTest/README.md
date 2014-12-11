## Using Arduino Ethernet Shield w/ Firestorm + TinyOS

Using Seeed Ethernet Shield v2.0

W5200 is the ethernet chip

Pin usage on Arduino:
D4: SD card chip select
D10: W5200 Chip select
D11: SPI MOSI
D12: SPI MISO
D13: SPI SCK

Once I know how to talk to the digital pins from the firestorm, I can talk to the SPI bus on the ethernet shield,
and then emulate the behavior in the arduino ethernet library in order to speak ethernet from the firestorm.

### Initializing

* initialize SPI interface (but don't set the RTS pin)
* reset the chip by writing the byte 1<<7 to the Mode Register on the chip SPI, address 0x0000
* set the modes on the sockets. On the W5200, `MAX_SOCK_NUM` is 8, on W5100, `MAX_SOCK_NUM` is 4:
    ```cpp
    // for W5200
    for (int i=0; i<MAX_SOCK_NUM; i++) {
        // 0x4n1F is tx memory size
        write((0x4000 + i * 0x100 + 0x001F), 2);
        // 0x4n1e is rx memory size
        write((0x4000 + i * 0x100 + 0x001E), 2);
        // not sure what writing "2" does though
    }
    // for W5100
    // write 0x55 to the Transmit Memory size register at 0x001B
    writeTMSR(0x55);
    // write 0x55 to the Receive Memory size register at 0x001A
    writeRMSR(0x55);

    // w5200:
    // TXBUF_BASE 0x8000
    // RXBUF_BASE 0xC000
    // w5100:
    // TXBUF_BASE 0x4000
    // RXBUF_BASE 0x6000

    // for BOTH
    uint16_t SBASE[MAX_SOCK_NUM]; // Tx buffer base address
    uint16_t RBASE[MAX_SOCK_NUM]; // Rx buffer base address
    for (int i=0; i<MAX_SOCK_NUM; i++) {
      SBASE[i] = TXBUF_BASE + SSIZE * i;
      RBASE[i] = RXBUF_BASE + RSIZE * i;
    }
    ```
* set MAC address
    This is done by writing the MAC address (`0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED` by default) to
    the Source Hardware Address Register (SHAR), which is 6 bytes 0x0009 - 0x000E on the SPI for the chip
* set IP address
    Write the IP address to SIPR (Source IP Address Register), which is 4 bytes at 0x000F - 0x00012
* set gateway IP
    Write the gateway ip to GAR = Gateway IP Address Register, 4 bytes at 0x0001 - 0x0004
* set subnet mask
    Write subnet maks to SUBR = Subnet Mask Register 0x0005 - 0x0008, 4 bytes at 0x0005 - 0x0008
