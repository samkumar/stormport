interface UDPSocket
{
  // Srcport is little endian
  command void initialize(uint16_t srcport);

  // Destport is in little endian, destip is in big endian (network byte order).
  command void sendPacket(uint16_t destport, uint32_t destip, struct ip_iovec data);

  // called when the packet has finished sending
  event void sendPacketDone(error_t error);

  // called upon recipt of a udp packet over ethernet
  // Srcport is in little endian, srcip is in big endian (network byte order).
  event void packetReceived(uint16_t srcport, uint32_t srcip, uint8_t *buf, uint16_t len);
}