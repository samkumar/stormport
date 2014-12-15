configuration EthernetClientAppC
{
}
implementation
{
  components MainC, EthernetClientC, HplSam4lIOC;
  components SocketP, SocketSpiP;
  components new Sam4lUSART0C();
  SocketSpiP.SpiPacket -> Sam4lUSART0C.SpiPacket;
  SocketSpiP.SpiHPL -> Sam4lUSART0C;
  SocketSpiP.EthernetSS -> HplSam4lIOC.PB11;

  components EthernetShieldConfigC;
  components new Timer32khzC() as EthernetShieldTimer;
  EthernetShieldConfigC.Timer -> EthernetShieldTimer;
  EthernetShieldConfigC.SocketSpi -> SocketSpiP.SocketSpi;

  EthernetClientC.Boot -> MainC;
  components SerialPrintfC;
  components new Timer32khzC();
  EthernetClientC.Timer -> Timer32khzC;

  components new Timer32khzC() as SocketPTimer;
  SocketP.SocketSpi -> SocketSpiP.SocketSpi;
  SocketP.Timer -> SocketPTimer;

  EthernetClientC.UDPSocket -> SocketP.UDPSocket;
  EthernetClientC.EthernetShieldConfig -> EthernetShieldConfigC;
}
