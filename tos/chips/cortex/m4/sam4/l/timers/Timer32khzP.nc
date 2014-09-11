configuration Timer32khzP
{
    provides interface Timer<T32khz> as Timer32khz[uint8_t id];
}
implementation
{
    components HilTimer32khzC, MainC;
    MainC.SoftwareInit -> HilTimer32khzC;
    Timer32khz = HilTimer32khzC;
}