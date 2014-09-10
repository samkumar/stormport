
configuration HplSam4lBSCIFC
{
    provides interface HplSam4lBSCIF;
}
implementation
{
    components HplSam4lBSCIFP;
    HplSam4lBSCIF = HplSam4lBSCIFP;
}