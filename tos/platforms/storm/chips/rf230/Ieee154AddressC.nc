
configuration Ieee154AddressC {
  provides interface Ieee154Address;

} implementation {
  components Ieee154AddressP;
  components MainC;
  components LocalIeeeEui64C;

  Ieee154AddressP.LocalIeeeEui64 -> LocalIeeeEui64C;
  Ieee154Address = Ieee154AddressP;

  MainC.SoftwareInit -> Ieee154AddressP;

}
