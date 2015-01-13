
#include <gpiohardware.h>
#include <twimhardware.h>

//This isn't a real HPL. It reads like the kind of code that is written in a rush before a demo.
//oh wait. it is.

module HplSam4lTWIMP
{
    provides
    {
        interface HplSam4lTWIM as TWIM [uint8_t id];
    }
    uses
    {
        interface HplSam4PeripheralClockCntl as ClockCtl [uint8_t id];
        interface HplSam4lPDCA as dmac [uint8_t id];
    }
}
implementation
{
    //Having this in RAM simplifies generated code

    enum { STATE_IDLE, STATE_BUSYTX, STATE_BUSYRX };

    norace uint32_t state[4];
    uint8_t *buffers [4];

    default async command void dmac.setPeripheral [uint8_t id] (uint8_t x) {printf("default ivk\n");}
    default async command void ClockCtl.enable [uint8_t id] () {printf("default ivk\n");}
    default async command void dmac.setWordSize [uint8_t id] (uint8_t ws) {printf("default ivk\n");}
    default async command void dmac.enableTransfer [uint8_t id] () {printf("default ivk\n");}
    default async command void dmac.disableTransfersCompleteIRQ [uint8_t id] () {printf("default ivk\n");}
    default async command void dmac.enableTransfersCompleteIRQ [uint8_t id] () {printf("default ivk\n");}
    default async command error_t dmac.setAddressCountReload [uint8_t id] (uint32_t mar, uint16_t tc){printf("default ivk\n");return EBUSY;}
    default async command bool dmac.transferBusy [uint8_t id] () {printf("default impl\n");return 1;}
    async command void TWIM.enablePins [uint8_t id] ()
    {

        switch(id)
        {
            case 0:
                GPIO_PORT_A->gperc = (0b11 << 23); //PA23 dat, PA24 clk
                GPIO_PORT_A->pmr0c = (0b11 << 23); //Peripheral A
                GPIO_PORT_A->pmr1c = (0b11 << 23);
                GPIO_PORT_A->pmr2c = (0b11 << 23);
                //GPIO_PORT_A->sterc = (0b11 << 23);
                break;
            case 1:
                printf("enabling pins for 1\n");
                GPIO_PORT_B->pmr0c = (0b11 << 0); //Peripheral A
                GPIO_PORT_B->pmr1c = (0b11 << 0);
                GPIO_PORT_B->pmr2c = (0b11 << 0);
                GPIO_PORT_B->gperc = (0b11 << 0); //PB00 dat, PB00 clk
                //GPIO_PORT_B->sterc = (0b11 << 0);
                break;
            case 2:
                GPIO_PORT_A->gperc = (0b11 << 21); //PA21 dat, PA22 clk
                GPIO_PORT_A->pmr0c = (0b11 << 21); //Peripheral E
                GPIO_PORT_A->pmr1c = (0b11 << 21);
                GPIO_PORT_A->pmr2s = (0b11 << 21);
                GPIO_PORT_A->sterc = (0b11 << 21);
                break;
            case 3:
                GPIO_PORT_B->gperc = (0b11 << 14); //PA21 dat, PA22 clk
                GPIO_PORT_B->pmr0c = (0b11 << 14); //Peripheral C
                GPIO_PORT_B->pmr1s = (0b11 << 14);
                GPIO_PORT_B->pmr2c = (0b11 << 14);
                GPIO_PORT_B->sterc = (0b11 << 14);
                break;
        }
    }

    async command void TWIM.init [uint8_t id] ()
    {
        call TWIM.enablePins[id]();
        call ClockCtl.enable[id]();
        TWIMx[id]->cr.flat = 1<<0; //men
        TWIMx[id]->cr.flat = 1<<7; //swrst
        TWIMx[id]->cr.flat = 1<<1; //mdis

        /*TWIMx[id]->cr.bits.swrst = 1;
        TWIMx[id]->cr.bits.men = 1;
        TWIMx[id]->cr.bits.swrst = 1;
        TWIMx[id]->cr.bits.smdis = 1;
        TWIMx[id]->cr.bits.men = 1;*/
        TWIMx[id]->cwgr.bits.exp = 7;
        TWIMx[id]->cwgr.bits.low = 100;
        TWIMx[id]->cwgr.bits.high = 100;
        TWIMx[id]->cwgr.bits.stasto = 200;
        TWIMx[id]->cwgr.bits.data = 10;
        TWIMx[id]->srr.bits.filter = 2;
        TWIMx[id]->srr.bits.dadrivel = 7;
        TWIMx[id]->srr.bits.cldrivel = 7;

        TWIMx[id]->scr.flat = 0xFFFFFFFF;
       // call dmac.setPeripheral[id](SAM4L_PID_TWIM0_TX + id);
       // call dmac.setWordSize[id](PDCA_SIZE_BYTE);
       // call dmac.enableTransfer[id]();
        //call dmac.enableTransfersCompleteIRQ[id]();
        state[id] = STATE_IDLE;
    }

    async command error_t TWIM.read [uint8_t id] (uint8_t flags, uint8_t addr, uint8_t *dst, uint8_t len)
    {
        twim_cmdr_t v;
        if (call dmac.transferBusy[id]())
            return EBUSY;

        v.bits.read = 1;
        v.bits.sadr = addr;
        v.bits.tenbit = 0;
        v.bits.start = (flags & FLAG_DOSTART) != 0;
        v.bits.stop = (flags & FLAG_DOSTOP) != 0;
        v.bits.pecen = 0;
        v.bits.nbytes = len;
        v.bits.acklast = (flags & FLAG_ACKLAST) != 0;
        v.bits.hs = 0;
        buffers[id] = dst;
        state[id] = STATE_BUSYRX;
        call dmac.setPeripheral[id](SAM4L_PID_TWIM0_RX + id);
        TWIMx[id]->ncmdr = v;
        atomic
        {
            call dmac.setAddressCountReload[id]((uint32_t)dst, len);
            call dmac.enableTransfersCompleteIRQ[id]();
        }
        return SUCCESS;
    }



    async event void dmac.reloadableFired[uint8_t id](){}
    async event void dmac.transferErrorFired[uint8_t id](){}
    async event void dmac.transfersCompleteFired[uint8_t id]()
    {
        if (state[id] == STATE_BUSYTX)
        {
            signal TWIM.writeDone[id](SUCCESS, buffers[id]);
        }
        else if (state[id] == STATE_BUSYRX)
        {
            signal TWIM.readDone[id](SUCCESS, buffers[id]);
        }
        call dmac.disableTransfersCompleteIRQ[id]();
    }

    default async event void TWIM.readDone [uint8_t id] (error_t stat, uint8_t* buf) {}
    default async event void TWIM.writeDone [uint8_t id] (error_t stat, uint8_t* buf) {}

    async command error_t TWIM.write [uint8_t id] (uint8_t flags, uint8_t addr, uint8_t *src, uint8_t len)
    {
        twim_cmdr_t v;
        int i;
        int wtf;

        TWIMx[id]->cr.flat = 1<<0; //men
        TWIMx[id]->cr.flat = 1<<7; //swrst
        TWIMx[id]->cr.flat = 1<<1; //mdis

        printf ("attempting address %02x", addr);
        v.flat = 0;
        v.bits.read = 0;
        v.bits.sadr = addr>>1;
        v.bits.tenbit = 0;
        v.bits.start = (flags & FLAG_DOSTART) != 0;
        v.bits.stop = (flags & FLAG_DOSTOP) != 0;
        v.bits.pecen = 0;
        v.bits.nbytes = len;
        v.bits.acklast = (flags & FLAG_ACKLAST) != 0;
        v.bits.hs = 0;
        v.bits.valid = 1;
        TWIMx[id]->cmdr.flat = v.flat;
        TWIMx[id]->cr.flat = 1<<0; //men
        for (i = 0; i < len; i++ )
        {
            printf("Starting character %d\n",i);
            printf("valid is %d\n", TWIMx[id]->cmdr.bits.valid);
            while(!TWIMx[id]->sr.bits.txrdy)
            {
                if(TWIMx[id]->sr.bits.anak) printf("ANAK\n");
                if(TWIMx[id]->sr.bits.dnak) printf("DNAK\n");
                if(TWIMx[id]->sr.bits.menb == 0) printf("zMENB\n");
                if(TWIMx[id]->cmdr.bits.nbytes == 0) printf("zNBYTES\n");
                if(TWIMx[id]->sr.bits.pecerr == 1) printf("PECERR\n");
                if(TWIMx[id]->sr.bits.rxrdy == 1){

                    wtf = TWIMx[id]->rhr;
                    printf("RXRDY 0x%02x\n", wtf);
                }

            }
            TWIMx[id]->thr = src[i];
            if (TWIMx[id]->sr.bits.txrdy)
            {
                printf("Immediately ready :(\n");
            }
            printf("Transmitted character %d\n",i);
        }
        printf("lvalid is %d\n", TWIMx[id]->cmdr.bits.valid);
        printf("reg is %x \n", *((uint32_t *)(0x4001C00C)));
        return SUCCESS;

        /*
        twim_cmdr_t v;

        if (call dmac.transferBusy[id]())
        {
            printf ("dmac says no go\n");

            return EBUSY;
        }

        printf("no transfer, proceeding\n");
        v.bits.read = 0;
        v.bits.sadr = addr;
        v.bits.tenbit = 0;
        v.bits.start = (flags & FLAG_DOSTART) != 0;
        v.bits.stop = (flags & FLAG_DOSTOP) != 0;
        v.bits.pecen = 0;
        v.bits.nbytes = len;
        v.bits.acklast = (flags & FLAG_ACKLAST) != 0;
        v.bits.hs = 0;
        buffers[id] = src;
        state[id] = STATE_BUSYTX;
        call dmac.setPeripheral[id](SAM4L_PID_TWIM0_TX + id);
        TWIMx[id]->ncmdr = v;
        atomic
        {
            call dmac.setAddressCountReload[id]((uint32_t)(&src[0]), len);
            call dmac.enableTransfersCompleteIRQ[id]();
        }
        return SUCCESS;*/
    }
}
