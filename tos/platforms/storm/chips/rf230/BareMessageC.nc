configuration BareMessageC
{
  provides
  {
    interface BareSend;
    interface BareReceive;
    interface Packet as BarePacket;
    interface PacketLink;
    interface LowPowerListening;
    interface SplitControl as RadioControl;
  }
}
implementation
{
  components RF230RadioC;

  BareSend = RF230RadioC;
  BareReceive = RF230RadioC;
  BarePacket = RF230RadioC.BarePacket;
  PacketLink = RF230RadioC;
  LowPowerListening = RF230RadioC;
  RadioControl = RF230RadioC.SplitControl;
}