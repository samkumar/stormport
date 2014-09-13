interface HplSam4lUSART_UARTIRQ
{
    async event void RXRdyFired();
    async event void TXRdyFired();
}