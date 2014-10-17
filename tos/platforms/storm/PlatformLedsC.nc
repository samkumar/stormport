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
  components NoGPIOP;
  Init = PlatformP.LedsInit;
  Led0 = NoGPIOP;
  Led1 = NoGPIOP;
  Led2 = NoGPIOP;

}