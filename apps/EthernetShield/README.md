## TinyOS

At time of writing, we are using the `kernel0` branch of
(https://github.com/SoftwareDefinedBuildings/stormport)[https://github.com/SoftwareDefinedBuildings/stormport].
To install the toolchain, simply clone the git repository, switch branches, and then run the following commands
from the [README](https://github.com/SoftwareDefinedBuildings/stormport/tree/kernel0):

```bash
cd tools
./Bootstrap
./configure
make
sudo make install
```

## Mote

Use a Storm v2 mote with an attached Wiz5200 Seeed Studios Ethernet Shield. It
will need some wires connecting up the SPI as well as a small bit of solder for
the IRQ (interrupt request register). This is already done on the 5 shields we have.

## UDPEcho over IPv4 in TinyOS

Open up the EthernetShield application (stormport/apps/EthernetShield). The
purpose of the application is to generate UDP traffic and send to a single host
over IPv4. It is easiest to do this on a local area network (LAN) or by
directly connecting the mote to your computer.

### Setting up the mote

At time of writing, the mote does not do DHCP, so we will have to statically
address it. Inside the file `EthernetClientC.nc`, near the top, you will see lines
that look like this:

```c
uint32_t srcip = 10 << 24 | 4 << 16 | 10 << 8 | 135; // 10.4.10.135
uint32_t netmask = 255 << 24 | 255 << 16 | 255 << 8 | 0; // 255.255.255.0
uint32_t gateway = 10 << 24 | 4 << 16 | 10 << 8 | 1; // 10.4.10.1
uint8_t *mac = "\xde\xad\xbe\xef\xfe\xeb"; // de:ad:be:ef:fe:ed
```

* `srcip` is the desired IPv4 address of your mote. Ping this address on your local network to make sure it
   doesn't exist first. 
* `netmask` is specific to your LAN. You probably won't have to change it
* `gateway` is also specific to your LAN, but you probably will not have to change this either. Usually this is
  the IP address of your router
* `mac` is the MAC address of your mote. As long as no two motes have the same MAC, you should not run into
  any problems. derive MAC from the serial number todo

**Coming Soon: deriving the MAC address automatically from the Berkeley OID and the serial number of the mote "00:12:6D:02:SERHI:SERLOW"**

A bit further down in the file you will see a line like this

```c
uint32_t destip = 10 << 24 | 4 << 16 | 10 << 8 | 142; // 10.4.10.142
uint16_t destport = 7000;
```

This is the destination address of your packet. Change it to your computer and
then save the file. You can change the port if you want, but 7000 is a
reasonable default.

By default, the application will send UDP packets a bit faster than 2 per
second. You can change this rate by altering the amount of time the program
waits between sending packets. The number is inside the `event void
UDPSocket.sendPacketDone` function.  32000 is 1 second, 16000 is .5 seconds,
etc.

A current limitation of the system (at time of writing) is not being able to
queue up packets to be sent. Sending another packet (via `call
UDPSocket.sendPacket`) before the previous one has finished (via firing `event
void UDPSocket.sendPacketDone`) has undefined behavior.

### Setting up your computer

You will need a UDP socket listening on your computer. You can do this easily via netcat:

```bash
$ nc -u -l -p 7000 # -u = UDP, -l = listen, -p = source port
```

but sometimes this will prematurely close the connection. I like running a small Python UDP server:

```python
import socket
import binascii

UDP_IP = "0.0.0.0"
UDP_PORT = 7000

sock = socket.socket(socket.AF_INET, # Internet
        socket.SOCK_DGRAM) # UDP
sock.bind((UDP_IP, UDP_PORT))

i = 0 
while True:
  data, addr = sock.recvfrom(1024) # buffer size is 1024 bytes
  i += 1
  print "received message {0}: ".format(i),
  print ">>",binascii.hexlify(bytearray(data))
```

Save this as a file and run it while you flash the mote.

### Flashing the mote and testing

Connect the mote with the Ethernet shield attached and run (from inside
the EthernetShield application directory)

```bash
make storm install && sload tail
```

This will install the mote with the EthernetShield application and then
''tails'' (this means ''follow'') the serial output of the mote. The correct
output should look more or less like this:

```
[SLOADER] Attached
Initializing Spi to talk to Wiz5200
setting peripheral ID on DMA channel 0 to 18
setting peripheral ID on DMA channel 4 to 0
eth shield initialize start
Ethernet shield initialized!
Initialization done
ethernetclient c trying to send packet
Send a UDP packet to 0:0
Timeout on send
UDP send: FAIL!
sent a packet
ethernetclient c trying to send packet
Send a UDP packet to 168037006:7000
UDP send: Success!
sent a packet
ethernetclient c trying to send packet
Send a UDP packet to 168037006:7000
Timeout on send
UDP send: FAIL!
sent a packet
ethernetclient c trying to send packet
Send a UDP packet to 168037006:7000
UDP send: Success!
sent a packet
ethernetclient c trying to send packet
Send a UDP packet to 168037006:7000
UDP send: Success!
sent a packet
```

You will notice that the first few packets fail to send. This is because when
the mote connects to the network, no one initially knows how to route traffic
to it (that is, which MAC address is associated with its IP). To our knowledge,
the Wiz5200 does not respond to ARP queries (which is how this is usually
resolved), so the mote has to send traffic before traffic can be routed to it.

After those first few packets, you should see the word "hell" appear on your
listening socket, at roughly the rate the mote is sending.

## Tunnelling IPv6
