configuration AllSocketsP
{
    provides interface RawSocket[uint8_t id];
    provides interface UDPSocket[uint8_t id];
    provides interface GRESocket;
    provides interface EthernetShieldConfig;
}
implementation
{
    components MainC;
    components HplSam4lIOC;
    components SocketSpiP;
    components GRESocketP;
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
    components new SocketP(2) as s2;
    components new SocketP(3) as s3;
    components new SocketP(4) as s4;
    components new SocketP(5) as s5;
    components new SocketP(6) as s6;
    components new SocketP(7) as s7;

    UDPSocket[0] = s0.UDPSocket;
    RawSocket[0] = s0.RawSocket;
    GRESocketP.RawSocket -> s0.RawSocket;
    GRESocket = GRESocketP;
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
    RawSocket[1] = s1.RawSocket;
    components new Timer32khzC() as SocketPTimer1;
    s1.SocketSpi -> SocketSpiP.SocketSpi;
    s1.Timer -> SocketPTimer1;
    s1.InitResource -> arbiter.Resource[unique(ETHERNETRESOURCE_ID)];
    s1.SendResource -> arbiter.Resource[unique(ETHERNETRESOURCE_ID)];
    s1.RecvResource -> arbiter.Resource[unique(ETHERNETRESOURCE_ID)];
    s1.ArbiterInfo -> arbiter.ArbiterInfo;
    s1.GpioInterrupt -> HplSam4lIOC.PB12IRQ;
    s1.IRQPin -> HplSam4lIOC.PB12;

    UDPSocket[2] = s2.UDPSocket;
    RawSocket[2] = s2.RawSocket;
    components new Timer32khzC() as SocketPTimer2;
    s2.SocketSpi -> SocketSpiP.SocketSpi;
    s2.Timer -> SocketPTimer2;
    s2.InitResource -> arbiter.Resource[unique(ETHERNETRESOURCE_ID)];
    s2.SendResource -> arbiter.Resource[unique(ETHERNETRESOURCE_ID)];
    s2.RecvResource -> arbiter.Resource[unique(ETHERNETRESOURCE_ID)];
    s2.ArbiterInfo -> arbiter.ArbiterInfo;
    s2.GpioInterrupt -> HplSam4lIOC.PB12IRQ;
    s2.IRQPin -> HplSam4lIOC.PB12;

    UDPSocket[3] = s3.UDPSocket;
    RawSocket[3] = s3.RawSocket;
    components new Timer32khzC() as SocketPTimer3;
    s3.SocketSpi -> SocketSpiP.SocketSpi;
    s3.Timer -> SocketPTimer3;
    s3.InitResource -> arbiter.Resource[unique(ETHERNETRESOURCE_ID)];
    s3.SendResource -> arbiter.Resource[unique(ETHERNETRESOURCE_ID)];
    s3.RecvResource -> arbiter.Resource[unique(ETHERNETRESOURCE_ID)];
    s3.ArbiterInfo -> arbiter.ArbiterInfo;
    s3.GpioInterrupt -> HplSam4lIOC.PB12IRQ;
    s3.IRQPin -> HplSam4lIOC.PB12;

    UDPSocket[4] = s4.UDPSocket;
    RawSocket[4] = s4.RawSocket;
    components new Timer32khzC() as SocketPTimer4;
    s4.SocketSpi -> SocketSpiP.SocketSpi;
    s4.Timer -> SocketPTimer4;
    s4.InitResource -> arbiter.Resource[unique(ETHERNETRESOURCE_ID)];
    s4.SendResource -> arbiter.Resource[unique(ETHERNETRESOURCE_ID)];
    s4.RecvResource -> arbiter.Resource[unique(ETHERNETRESOURCE_ID)];
    s4.ArbiterInfo -> arbiter.ArbiterInfo;
    s4.GpioInterrupt -> HplSam4lIOC.PB12IRQ;
    s4.IRQPin -> HplSam4lIOC.PB12;

    UDPSocket[5] = s5.UDPSocket;
    RawSocket[5] = s5.RawSocket;
    components new Timer32khzC() as SocketPTimer5;
    s5.SocketSpi -> SocketSpiP.SocketSpi;
    s5.Timer -> SocketPTimer5;
    s5.InitResource -> arbiter.Resource[unique(ETHERNETRESOURCE_ID)];
    s5.SendResource -> arbiter.Resource[unique(ETHERNETRESOURCE_ID)];
    s5.RecvResource -> arbiter.Resource[unique(ETHERNETRESOURCE_ID)];
    s5.ArbiterInfo -> arbiter.ArbiterInfo;
    s5.GpioInterrupt -> HplSam4lIOC.PB12IRQ;
    s5.IRQPin -> HplSam4lIOC.PB12;

    UDPSocket[6] = s6.UDPSocket;
    RawSocket[6] = s6.RawSocket;
    components new Timer32khzC() as SocketPTimer6;
    s6.SocketSpi -> SocketSpiP.SocketSpi;
    s6.Timer -> SocketPTimer6;
    s6.InitResource -> arbiter.Resource[unique(ETHERNETRESOURCE_ID)];
    s6.SendResource -> arbiter.Resource[unique(ETHERNETRESOURCE_ID)];
    s6.RecvResource -> arbiter.Resource[unique(ETHERNETRESOURCE_ID)];
    s6.ArbiterInfo -> arbiter.ArbiterInfo;
    s6.GpioInterrupt -> HplSam4lIOC.PB12IRQ;
    s6.IRQPin -> HplSam4lIOC.PB12;

    UDPSocket[7] = s7.UDPSocket;
    RawSocket[7] = s7.RawSocket;
    components new Timer32khzC() as SocketPTimer7;
    s7.SocketSpi -> SocketSpiP.SocketSpi;
    s7.Timer -> SocketPTimer7;
    s7.InitResource -> arbiter.Resource[unique(ETHERNETRESOURCE_ID)];
    s7.SendResource -> arbiter.Resource[unique(ETHERNETRESOURCE_ID)];
    s7.RecvResource -> arbiter.Resource[unique(ETHERNETRESOURCE_ID)];
    s7.ArbiterInfo -> arbiter.ArbiterInfo;
    s7.GpioInterrupt -> HplSam4lIOC.PB12IRQ;
    s7.IRQPin -> HplSam4lIOC.PB12;
}
