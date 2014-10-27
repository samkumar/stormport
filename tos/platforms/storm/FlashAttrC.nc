configuration FlashAttrC
{
    provides interface FlashAttr;
}
implementation
{
    components HplSam4lIOC, new Sam4lSPI0C(), FlashAttrP;

    FlashAttrP.Resource -> Sam4lSPI0C;
    FlashAttrP.CS -> HplSam4lIOC.PC03;
    FlashAttrP.FastSpiByte -> Sam4lSPI0C;
    FlashAttr = FlashAttrP;
    FlashAttrP.HplSam4lSPIChannel -> Sam4lSPI0C;

}