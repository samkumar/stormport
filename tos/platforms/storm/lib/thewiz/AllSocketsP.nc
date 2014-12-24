configuration AllSocketsP
{
    //provides interface RawSocket[uint8_t id];
    provides interface UDPSocket[uint8_t id];
    provides interface EthernetShieldConfig;
}
implementation
{
    components MainC;
    components HplSam4lIOC;
    components SocketSpiP;
    components new Sam4lUSART0C();
    components new Timer32khzC() as SocketSpiTimer;
    SocketSpiP.SpiPacket -> Sam4lUSART0C.SpiPacket;
    SocketSpiP.SpiHPL -> Sam4lUSART0C;
    SocketSpiP.EthernetSS -> HplSam4lIOC.PB11;
    SocketSpiP.Timer -> SocketSpiTimer;

    // is this the correct way to do this?
    MainC.SoftwareInit -> SocketSpiP;

    // arbiter
    components new FcfsArbiterC(ETHERNETRESOURCE_ID) as arbiter;
    components EthernetClientResourceConfigureP;
    arbiter.ResourceConfigure -> EthernetClientResourceConfigureP.ResourceConfigure;

    components EthernetShieldConfigC;
    components new Timer32khzC() as EthernetShieldTimer;
    EthernetShieldConfigC.Timer -> EthernetShieldTimer;
    EthernetShieldConfigC.SocketSpi -> SocketSpiP.SocketSpi;
    EthernetShieldConfigC.SpiResource -> arbiter.Resource[unique(ETHERNETRESOURCE_ID)];

    EthernetShieldConfig = EthernetShieldConfigC;

    components new SocketP(0) as s0;
    components new SocketP(1) as s1;
    //components new SocketP(2) as s2;
    //components new SocketP(3) as s3;
    //components new SocketP(4) as s4;
    //components new SocketP(5) as s5;
    //components new SocketP(6) as s6;
    //components new SocketP(7) as s7;

    //RawSocket[0] = s0.RawSocket;
    //RawSocket[1] = s1.RawSocket;
    //RawSocket[2] = s2.RawSocket;
    //RawSocket[3] = s3.RawSocket;
    //RawSocket[4] = s4.RawSocket;
    //RawSocket[5] = s5.RawSocket;
    //RawSocket[6] = s6.RawSocket;
    //RawSocket[7] = s7.RawSocket;

    UDPSocket[0] = s0.UDPSocket;
    components new Timer32khzC() as SocketPTimer0;
    s0.SocketSpi -> SocketSpiP.SocketSpi;
    s0.Timer -> SocketPTimer0;
    s0.InitResource -> arbiter.Resource[unique(ETHERNETRESOURCE_ID)];
    s0.SendResource -> arbiter.Resource[unique(ETHERNETRESOURCE_ID)];
    s0.RecvResource -> arbiter.Resource[unique(ETHERNETRESOURCE_ID)];
    s0.ArbiterInfo -> arbiter.ArbiterInfo;
    s0.GpioInterrupt -> HplSam4lIOC.PB12IRQ;
    s0.IRQPin -> HplSam4lIOC.PB12;

    UDPSocket[1] = s1.UDPSocket;
    components new Timer32khzC() as SocketPTimer1;
    s1.SocketSpi -> SocketSpiP.SocketSpi;
    s1.Timer -> SocketPTimer1;
    s1.InitResource -> arbiter.Resource[unique(ETHERNETRESOURCE_ID)];
    s1.SendResource -> arbiter.Resource[unique(ETHERNETRESOURCE_ID)];
    s1.RecvResource -> arbiter.Resource[unique(ETHERNETRESOURCE_ID)];
    s1.ArbiterInfo -> arbiter.ArbiterInfo;
    s1.GpioInterrupt -> HplSam4lIOC.PB12IRQ;
    s1.IRQPin -> HplSam4lIOC.PB12;
    //UDPSocket[2] = s2.UDPSocket;
    //UDPSocket[3] = s3.UDPSocket;
    //UDPSocket[4] = s4.UDPSocket;
    //UDPSocket[5] = s5.UDPSocket;
    //UDPSocket[6] = s6.UDPSocket;
    //UDPSocket[7] = s7.UDPSocket;


}
