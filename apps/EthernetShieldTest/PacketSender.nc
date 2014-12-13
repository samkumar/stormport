#include "iovec.h"

interface PacketSender
{
  // send [len] bytes from buffer [buf]
  command void sendPacket(struct ip_iovec data);

  // called when the packet has finished sending
  event void sendPacketDone(error_t error);

  // called upon recipt of a packet over ethernet
  event void packetReceived(struct ip_iovec data);
}
