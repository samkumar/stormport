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

### Client Connecting

Connects to an IP and port (no DNS resolution, at least yet).

`SnSR` refers to the status of each socket on the W5200 chip.

Status register is `SnSR`, where n is 0..7, at address 0x4n03 (need to check)

* loop through each of the sockets and check the Status. If it is `CLOSED`,
  `FIN_WAIT` or `CLOSE_WAIT`, then we can use it
* open a clientside socket using W5200 sock num, protocol (TCP, UDP, etc) and sourceport.
    * Sourceport (`_srcport`) seems to be arbitrary
    * supports TCP, UDP, IPRAW, MACRAW, PPPOE
    * write `protocol | 0` to socket mode register `SnMR` at 0x4n00
    * write the sourceport to `SnPORT` at 0x4n04 (or 0x4n05? there are two)
    * write the `Sock_OPEN` command to socket command register `SnCR` at 0x4n01
      and wait for it to complete. The arduino code does this by running
      `while(readSnCR(sock_num))`
* once we have the socket object, we *connect* do a dest port and dest ip
    * check that the dest ip isn't 0xffffffff or 0x00000000
    * write dest address to `SnDIPR` at 0x4n0C to 0x4nOF
    * write dest port to `SnDPORT` at 0x4n10, 0x4n11
    * send a `Sock_CONNECT` to the socket command register `SnCR` at 0x4n01
      and wait for it to complete
* the socket state at `SnSR` should be `ESTABLISHED`. We return when it becomes `CLOSED`
    
