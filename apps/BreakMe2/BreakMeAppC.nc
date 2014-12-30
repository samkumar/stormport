configuration BreakMeAppC
{}
implementation
{
    components MainC;

    components SerialPrintfC;

    components HalSam4lASTC;

    components BreakMeAppP;
    BreakMeAppP.Boot -> MainC;
    BreakMeAppP.Alarm -> HalSam4lASTC;
}
