#include "ethernetshield.h"

configuration EthernetClientAppC
{
}
implementation
{
  components MainC;
  components EthernetClientC;
  components EthernetShieldConfigC;
  components GRESocketP;
  components new SocketC() as MySocket;

  EthernetClientC.Boot -> MainC;
  components SerialPrintfC;
  components new Timer32khzC();
  EthernetClientC.Timer -> Timer32khzC;

  GRESocketP.RawSocket -> MySocket.RawSocket;
  EthernetClientC.GRESocket -> GRESocketP;
  EthernetClientC.EthernetShieldConfig -> EthernetShieldConfigC;
}
