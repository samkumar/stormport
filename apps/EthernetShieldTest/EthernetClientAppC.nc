configuration EthernetClientAppC
{
}
implementation
{
  components MainC, EthernetClientC, HplSam4lIOC;
  components SocketP, SocketSpiP;

  EthernetClientC.Boot -> MainC;
  components SerialPrintfC;
  components new Timer32khzC();
  EthernetClientC.Timer -> Timer32khzC;

  // packet stuff
  components new Timer32khzC() as SocketPTimer;
  components new Sam4lUSART0C();
  SocketP.SocketSpi -> SocketSpiP.SocketSpi;
  SocketP.Timer -> SocketPTimer;
  SocketSpiP.SpiPacket -> Sam4lUSART0C.SpiPacket;
  SocketSpiP.SpiHPL -> Sam4lUSART0C;
  SocketSpiP.EthernetSS -> HplSam4lIOC.PB11;
  EthernetClientC.UDPSocket -> SocketP.UDPSocket;
}
