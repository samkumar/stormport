
#ifndef GPIOHARDWARE_H
#define GPIOHARDWARE_H

typedef struct
{
    uint32_t    gper;
    uint32_t    gpers;
    uint32_t    gperc;
    uint32_t    gpert;
    uint32_t    pmr0;
    uint32_t    pmr0s;
    uint32_t    pmr0c;
    uint32_t    pmr0t;
    //0x20
    uint32_t    pmr1;
    uint32_t    pmr1s;
    uint32_t    pmr1c;
    uint32_t    pmr1t;
    uint32_t    pmr2;
    uint32_t    pmr2s;
    uint32_t    pmr2c;
    uint32_t    pmr2t;
    //0x40
    uint32_t    oder;
    uint32_t    oders;
    uint32_t    oderc;
    uint32_t    odert;
    uint32_t    ovr;
    uint32_t    ovrs;
    uint32_t    ovrc;
    uint32_t    ovrt;
    //0x60
    uint32_t    pvr;
    uint32_t    reserved0[3];
    uint32_t    puer;
    uint32_t    puers;
    uint32_t    puerc;
    uint32_t    puert;
    //0x80
    uint32_t    pder;
    uint32_t    pders;
    uint32_t    pderc;
    uint32_t    pdert;
    uint32_t    ier;
    uint32_t    iers;
    uint32_t    ierc;
    uint32_t    iert;
    //0xA0
    uint32_t    imr0;
    uint32_t    imr0s;
    uint32_t    imr0c;
    uint32_t    imr0t;
    uint32_t    imr1;
    uint32_t    imr1s;
    uint32_t    imr1c;
    uint32_t    imr1t;
    //0xC0
    uint32_t    gfer;
    uint32_t    gfers;
    uint32_t    gferc;
    uint32_t    gfert;
    uint32_t    ifr;
    uint32_t    reserved1;
    uint32_t    ifrc;
    uint32_t    reserved2;
    //0x100
    uint32_t    odcr0;
    uint32_t    odcr0s;
    uint32_t    odcr0c;
    uint32_t    odcr0t;
    uint32_t    odcr1;
    uint32_t    odcr1s;
    uint32_t    odcr1c;
    uint32_t    odcr1t;
    //0x120
    uint32_t    reserved3[4];
    uint32_t    osrr0;
    uint32_t    osrr0s;
    uint32_t    osrr0c;
    uint32_t    osrr0t;
    //0x140
    uint32_t    reserved4[8];
    //0x160
    uint32_t    ster;
    uint32_t    sters;
    uint32_t    sterc;
    uint32_t    stert;
    uint32_t    reserved5[4];
    //0x180
    uint32_t    ever;
    uint32_t    evers;
    uint32_t    everc;
    uint32_t    evert;
    uint32_t    reserved6[112];
    //0x200 end
} gpio_port_t;

enum {
    GPIO_PORT0_ADDRESS = 0x400E1000,
    GPIO_PORT1_ADDRESS = 0x400E1200,
    GPIO_PORT2_ADDRESS = 0x400E1400
};

gpio_port_t volatile * const gpio_port_a = (gpio_port_t volatile *) 0x400E1000;
gpio_port_t volatile * const gpio_port_b = (gpio_port_t volatile *) 0x400E1200;
gpio_port_t volatile * const gpio_port_c = (gpio_port_t volatile *) 0x400E1400;
#endif