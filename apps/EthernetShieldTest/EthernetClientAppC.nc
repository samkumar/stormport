configuration EthernetClientAppC
{
}
implementation
{
  components MainC, EthernetClientC, HplSam4lIOC;
  components EthernetUdpWiz5200P;
  components SocketP, SocketSpiP;


  //SPI stuff
  components new Sam4lUSART0C();
  EthernetClientC.SpiPacket -> Sam4lUSART0C.SpiPacket;
  EthernetClientC.SpiHPL -> Sam4lUSART0C;
  EthernetClientC.EthernetSS -> HplSam4lIOC.PB11;
  EthernetClientC.SDCardSS -> HplSam4lIOC.PC09;

  EthernetClientC.Boot -> MainC;
  components SerialPrintfC;
  components new Timer32khzC();
  EthernetClientC.Timer -> Timer32khzC;

  // packet stuff
  components new Timer32khzC() as SocketPTimer;
  SocketP.SocketSpi -> SocketSpiP.SocketSpi;
  SocketP.Timer -> SocketPTimer;
  SocketSpiP.SpiPacket -> Sam4lUSART0C.SpiPacket;
  SocketSpiP.SpiHPL -> Sam4lUSART0C;
  SocketSpiP.EthernetSS -> HplSam4lIOC.PB11;
  EthernetClientC.UDPSender -> EthernetUdpWiz5200P.UDPSender;
}
