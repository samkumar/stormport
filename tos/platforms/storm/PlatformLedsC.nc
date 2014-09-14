configuration PlatformLedsC
{
    provides interface GeneralIO as Led0;
    provides interface GeneralIO as Led1;
    provides interface GeneralIO as Led2;
    uses interface Init;
}
implementation
{
  components HplSam4lIOC;
  components PlatformP;

  Init = PlatformP.LedsInit;

  Led0 = HplSam4lIOC.PA16;
  Led1 = HplSam4lIOC.PA13;
  Led2 = HplSam4lIOC.PA11;

}