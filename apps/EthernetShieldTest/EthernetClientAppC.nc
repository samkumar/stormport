configuration EthernetClientAppC
{
}
implementation
{
  components MainC, EthernetClientC, HplSam4lIOC;
  components SerialPrintfC;

  //SPI stuff
  components new Sam4lUSART2C();
  EthernetClientC.SpiPacket -> Sam4lUSART2C.SpiPacket;
  EthernetClientC.SpiHPL -> Sam4lUSART2C;
}
