module AllSocketsC
{
    provides interface RawSocket[uint8_t id];
    provides interface UDPSocket[uint8_t id];
}
implementation
{

    components new SocketP(0) as s0;
    components new SocketP(1) as s1;
    components new SocketP(2) as s2;
    components new SocketP(3) as s3;
    components new SocketP(4) as s4;
    components new SocketP(5) as s5;
    components new SocketP(6) as s6;
    components new SocketP(7) as s7;

    RawSocket[0] = s0;
    RawSocket[1] = s1;
    RawSocket[2] = s2;
    RawSocket[3] = s3;
    RawSocket[4] = s4;
    RawSocket[5] = s5;
    RawSocket[6] = s6;
    RawSocket[7] = s7;

    UDPSocket[0] = s0;
    UDPSocket[1] = s1;
    UDPSocket[2] = s2;
    UDPSocket[3] = s3;
    UDPSocket[4] = s4;
    UDPSocket[5] = s5;
    UDPSocket[6] = s6;
    UDPSocket[7] = s7;


}