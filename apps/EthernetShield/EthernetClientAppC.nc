#include "ethernetshield.h"

configuration EthernetClientAppC
{
}
implementation
{
  components MainC;
  components EthernetClientC;
  components EthernetShieldConfigC;
  components new SocketC() as MySocket;

  EthernetClientC.Boot -> MainC;
  components SerialPrintfC;
  components new Timer32khzC();
  EthernetClientC.Timer -> Timer32khzC;

  EthernetClientC.UDPSocket -> MySocket.UDPSocket;
  EthernetClientC.EthernetShieldConfig -> EthernetShieldConfigC;
}
