#include "iovec.h"

interface PacketSender
{
  //command init(mode(UDP), macaddress, staticip, subnetmask, gatewayip)
  //command sendUDP(etc)
  //command sendIPRAW(etc)
  //etc
  //event void recvUDP, recvIPRAW
  // send [len] bytes from buffer [buf]
  command void sendPacket(struct ip_iovec data);

  // called when the packet has finished sending
  event void sendPacketDone(error_t error);

  // called upon recipt of a packet over ethernet
  event void packetReceived(uint8_t *buf, uint16_t len);
}
