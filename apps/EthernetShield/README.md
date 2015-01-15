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

## UDP Traffic over IPv4 in TinyOS

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
to it (that is, which MAC address is associated with its IP). Sending this initial
traffic is optional in a production setting, because the Wiz5200 chip should respond
to ARP queries.

After those first few packets, you should see the word "hell" appear on your
listening socket, at roughly the rate the mote is sending.

## Tunnelling IPv6

One of the advantages of using the Firestorm+Wiz5200 Shield combination is that
it becomes easy to tunnel IPv6 traffic, which could be used (for example) for
having motes send readings directly to a server on a different IPv6 subnet,
without the need for special software (like PPPRouter) running on the computer connected
to the border router.

### Configuring the mote

We will be using the Kernel application from the `stormport` repository. You can find it in `stormport/apps/Kernel`.
Adjust the Makefile to have the following line(s) uncommented:

```make
PFLAGS += -DWITH_WIZ
PFLAGS += -DBLIP_STFU # optional, but helps reduce verbose output from the BLIP stack
```

As with the UDP traffic application above, we will need to configure our mote to send IPv4 traffic.
Inside the `EthernetP.nc` file in the `Kernel` application directory, you will find lines looking something like this:

```c
uint32_t srcip   = 10  << 24 | 4   << 16 | 10  << 8 | 135; // 10.4.10.135
uint32_t netmask = 255 << 24 | 255 << 16 | 255 << 8 | 0  ; // 255.255.255.0
uint32_t gateway = 10  << 24 | 4   << 16 | 10  << 8 | 1  ; // 10.4.10.135
uint8_t *mac = "\xde\xad\xbe\xef\xfe\xef";
```

* `srcip` is the desired IPv4 address of your mote. Ping this address on your local network to make sure it
   doesn't exist first. 
* `netmask` is specific to your LAN. You probably won't have to change it
* `gateway` is also specific to your LAN, but you probably will not have to change this either. Usually this is
  the IP address of your router
* `mac` is the MAC address of your mote. As long as no two motes have the same MAC, you should not run into
  any problems. derive MAC from the serial number todo

A couple of lines above will be a line like

```c
destip = 0x0a040a83 // or 10 << 24 | 4 << 16 | 10 << 8 | 142 = 10.4.10.142
```

which will be the computer that is plugged into the ethernet cable attached to the shield on top of the mote.

Inside `event void Boot.booted()`, there is a periodic timer that you should
uncomment that will generate traffic on the mote

```c
call Timer.startPeriodic(32000);
```

We aren't done with the mote yet, though.

### Configuring IPv6 tunnel on the host

On the "host", which is the computer plugged into the ethernet cable on the
mote, we need to set up a tunnel that can accept IPv6 traffic. These
instructions work on Ubuntu 14.04 (with some leeway in versions). For other
platforms, try searching for instructions on how to set up a 6in4 tunnel for
IPv6 encapsulation.

#### Delete old tunnels

Before we continue, make sure you do not have old tunnels still configured. Run
`ifconfig` in a terminal and look for interfaces named `storm-pm4` and `storm-pm6`.
If they exist, then you may have a preexisting tunnel. If you want to start
fresh, delete these on the storm.pm site (instructions forthcoming) and delete
them locally. To delete locally, run

```bash
sudo ip tunnel del storm-pm4
sudo ip tunnel del storm-pm6
```

#### Setup new tunnels

First, go to the [Storm Pervasive Mesh](http://storm.pm/) site to setup an
external tunnel. You can only have one tunnel per public IP, so if you are
behind a NAT (that is, if you are on a LAN or do not have a public IP address),
then you will need to coordinate with other people on the same network as you.

Click "Register new tunnel" on the left and click "Yeah of course". It should
create a simple script under "Automatic configuration script" that will do the
heavy lifting for you. Copy the script, which should look something like

```bash
# (no, this isn't a working tunnel)
curl -v http://storm.pm/u/f4b75490-9c28-11e4-9c90-0cc47a0f7eea?ip=auto
 curl -v http://storm.pm/c/nix/f4b75490-9c28-11e4-9c90-0cc47a0f7eea | sudo bash
```

and paste it into your terminal before hitting "enter". If you're smart and want to check the commands
that you just blindly copy-pasted into being run as root on your computer, simply run

```bash
curl -v http://storm.pm/c/nix/f4b75490-9c28-11e4-9c90-0cc47a0f7eea 
```

Run `ifconfig`, and you should see the 2 interfaces `storm-pm4` and `storm-pm6`.
Make note of the global scope address under `storm-pm6`. Example is below; we're
looking at `2001:470:4885:1:a`.

```
storm-pm6 Link encap:IPv6-in-IPv4  
          inet6 addr: 2001:470:4885:1:a::/127 Scope:Global
          inet6 addr: fe80::8020:25d1/64 Scope:Link
          inet6 addr: fe80::a04:a8e/64 Scope:Link
          inet6 addr: fe80::ac11:2a01/64 Scope:Link
          etc...
```

If you run `sudo ip -6 route`, you should see the routes from your new tunnel appear:

```
2001:470:4885:1:9::/127 dev storm-pm6  proto kernel  metric 256
fe80::/64 dev storm-pm6  proto kernel  metric 256
fe80::/64 dev storm-pm4  proto kernel  metric 256
default dev storm-pm6  metric 1024 
```

Try pinging Google via your new IPv6 connection using `ping6 google.com`. It
might take a few minutes for this to work because traffic has to flow in both
directions on the tunnel before it will work, but before long you should see
your pings going through.

Congratulations! You now have a globally routable IPv6 address.

Going back to the Kernel application, open up `KernelMainP.nc` and look for the
line inside `event void Boot.booted()` that looks like 

```
inet_pton6("2001:470:4885:1:c::", &route_dest.sin6_addr);
```

and change the address inside to be your globally routable IPv6 address, e.g.

```
inet_pton6("2001:470:4885:1:a::", &route_dest.sin6_addr);
```

Now, we need a local tunnel so that the host computer can understand the
IPv6 traffic being forwarded by the mote.

Put the following lines in a text file with the following provisions:

* `gre-mote` can be anything you want, as long as it doesn't conflict with any of
  the other interface names listed by `ifconfig -a`
* `10.4.10.135` should be the IPv4 address of the mote that you configured above
* `2001:470:4885:a::5/48`: The last `5` doesn't have to be a `5`

```bash
ip tunnel add gre-mote sit remote 10.4.10.135
ip link set gre-mote up
ip addr add 2001:470:4885:a::5/48 dev gre-mote
ip route add 2001:470:4885:a::/64 dev gre-mote
```

Make the file executable and then run it as root:

```bash
chmod a+x tunnel.sh # tunnel.sh is the name of our file
sudo ./tunnel.sh
```

#### Listening on the host

For our sample application, we are sending IPv6 traffic to our host computer
(that's what uncommenting the periodic timer does up above). On our host computer
we can either listen via netcat:

```
nc -6 -u -l -p 7000 # -6 is IPv6
```

but this will terminate after 1 message. We can adjust the Python UDP server above to handle
IPv6 traffic:

```python
import socket
import binascii

UDP_IP = "::"
UDP_PORT = 7000

sock = socket.socket(socket.AF_INET6,
    socket.SOCK_DGRAM)
sock.bind((UDP_IP, UDP_PORT))

i = 0
while True:
    data, addr = sock.recvfrom(1024) # buffer size is 1024 bytes
    i += 1
    print "received message {0}: ".format(i),
    print binascii.hexlify(bytearray(data))
```

Save this as a file and run it while you flash the mote.

#### Flashing the mote and testing

Build the application and flash the mote:

```bash
make storm install && sload tail
```

You should now see traffic appearing on your host socket! The application uses
port 7000 by default.

We can also ping the mote over IPv6. To get the globally routable IPv6 address of the mote,
look up its serial number. This will either be printed on the back, or you can retrieve it by running

```bash
sload gattr
```

and looking for a line like

```
serial => fe eb
```

In this case, our hex serial number is `fe:eb`. So, our IPv6 address is thus
`2001:470:4885:a:212:6d02::feeb`.

If you do not have a serial number, you can add one:

```
sload sattr -x 0 serial feeb # feeb is your serial
```

but if you already have a serial number, please do not change it.

Running `ping6 2001:470:4885:a:212:6d02::feeb` should give us some responses
from the mote. If you don't, then open up Wireshark and start looking at the
traffic.

#### Other motes

To get other motes to send traffic to your host, have them set the destination
address of the packets to be your host's global IP, which in our example is
`2001:470:4885:1:a::`.
