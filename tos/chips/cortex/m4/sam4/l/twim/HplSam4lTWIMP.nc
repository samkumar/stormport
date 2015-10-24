
#include <gpiohardware.h>
#include <twimhardware.h>
#include <nvichardware.h>

//This isn't a real HPL. It reads like the kind of code that is written in a rush before a demo.
//oh wait. it is.

//And then I resurrected it for a class under equal time constraints... oh the humanity...

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
        interface FunctionWrapper as IRQWrapper;
    }
}
implementation
{
    //Having this in RAM simplifies generated code

    enum { STATE_IDLE, STATE_BUSYTX, STATE_BUSYRX };

    enum { STATUS_OK=0, STATUS_DNAK=1, STATUS_ANAK=2, STATUS_ERR=3, STATUS_ARBLST=4 };
    norace uint32_t state[4];
    uint8_t *buffers [4];
    uint8_t nstop [4];
    default async command void dmac.setPeripheral [uint8_t id] (uint8_t x) {printf("default ivk0\n");}
    default async command void ClockCtl.enable [uint8_t id] () {printf("default ivk1\n");}
    default async command void dmac.setWordSize [uint8_t id] (uint8_t ws) {printf("default ivk2\n");}
    default async command void dmac.enableTransfer [uint8_t id] () {printf("default ivk3\n");}
    default async command void dmac.disableTransfersCompleteIRQ [uint8_t id] () {printf("default ivk4\n");}
    default async command void dmac.disableTransferErrorIRQ [uint8_t id] () {printf("default ivk5\n");}
    default async command void dmac.disableTransfer [uint8_t id] () {printf("default ivk6\n");}
    default async command void dmac.enableTransfersCompleteIRQ [uint8_t id] () {printf("default ivk7\n");}
    default async command void dmac.enableTransferErrorIRQ [uint8_t id] () {printf("default ivk8\n");}
    default async command error_t dmac.setAddressCountReload [uint8_t id] (uint32_t mar, uint16_t tc){printf("default ivk9\n");return EBUSY;}
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
                //GPIO_PORT_A->sterc = (0b11 << 21);
                break;
            case 3:
                GPIO_PORT_B->gperc = (0b11 << 14); //PA21 dat, PA22 clk
                GPIO_PORT_B->pmr0c = (0b11 << 14); //Peripheral C
                GPIO_PORT_B->pmr1s = (0b11 << 14);
                GPIO_PORT_B->pmr2c = (0b11 << 14);
                //GPIO_PORT_B->sterc = (0b11 << 14);
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

        TWIMx[id]->cwgr.bits.exp = 3;
        TWIMx[id]->cwgr.bits.low = 10;
        TWIMx[id]->cwgr.bits.high = 10;
        TWIMx[id]->cwgr.bits.stasto = 10;
        TWIMx[id]->cwgr.bits.data = 4;
        TWIMx[id]->srr.bits.filter = 2;
        TWIMx[id]->srr.bits.dadrivel = 7;
        TWIMx[id]->srr.bits.cldrivel = 7;

        TWIMx[id]->scr.flat = 0xFFFFFFFF;
        call dmac.setPeripheral[id](SAM4L_PID_TWIM0_TX + id);
        call dmac.setWordSize[id](PDCA_SIZE_BYTE);
        //call dmac.enableTransfer[id]();
        //call dmac.enableTransfersCompleteIRQ[id]();
        state[id] = STATE_IDLE;
        TWIMx[id]->idr.flat = 0xFFFFFFFF; //ARBLST, DNAK, ANAK
        switch(id)
        {
            case 0:
                NVIC->iser.bits.twim0 = 1;
                break;
            case 1:
                NVIC->iser.bits.twim1 = 1;
                break;
            case 2:
                NVIC->iser.bits.twim2 = 1;
                break;
            case 3:
                NVIC->iser.bits.twim3 = 1;
                break;
        }
    }

    async command error_t TWIM.read [uint8_t id] (uint8_t flags, uint8_t addr, uint8_t *dst, uint8_t len)
    {
        twim_cmdr_t v;
        int i;

        if (call dmac.transferBusy[id]())
        {
            printf ("dmac says no go\n");
            return EBUSY;
        }
       // TWIMx[id]->cr.flat = 1<<0; //men
      //  TWIMx[id]->cr.flat = 1<<7; //swrst
      //  TWIMx[id]->cr.flat = 1<<1; //mdis
        v.flat = 0;
        v.bits.read = 1;
        v.bits.sadr = addr>>1;
        v.bits.tenbit = 0;
        v.bits.start = (flags & FLAG_DOSTART) != 0;
        v.bits.stop = (flags & FLAG_DOSTOP) != 0;
        nstop[id] = (flags & FLAG_DOSTOP) == 0;
        v.bits.pecen = 0;
        v.bits.nbytes = len;
        v.bits.acklast = (flags & FLAG_ACKLAST) != 0;
        v.bits.hs = 0;
        v.bits.valid = 1;
        buffers[id] = dst;
        state[id] = STATE_BUSYRX;
        call dmac.setPeripheral[id](SAM4L_PID_TWIM0_RX + id);
        TWIMx[id]->ncmdr.flat = v.flat;
        TWIMx[id]->cr.flat = 1<<0; //men
        TWIMx[id]->scr.flat = 0xFFFFFFFF;
        atomic
        {
            TWIMx[id]->ier.flat = 0x710; //ARBLST, DNAK, ANAK, CRDY
            call dmac.setAddressCountReload[id]((uint32_t)(&dst[0]), len);
            call dmac.enableTransfersCompleteIRQ[id]();
            call dmac.enableTransferErrorIRQ[id]();
        }
        call dmac.enableTransfer[id]();
        return SUCCESS;
    }





    void dispatch_status(int id, int status)
    {
        call dmac.disableTransfer[id]();
        call dmac.disableTransfersCompleteIRQ[id]();
        call dmac.disableTransferErrorIRQ[id]();
        TWIMx[id]->idr.flat = 0x710; //ARBLST, DNAK, ANAK
        //printf("ds %d %d\n",status, id);
        if (status != 0)
        {
            //printf("sreset\n");
            TWIMx[id]->cr.bits.swrst = 1;
        }
        TWIMx[id]->scr.flat = 0xFFFFFFFF;
        if (state[id] == STATE_BUSYTX)
        {
            signal TWIM.writeDone[id](status, buffers[id]);
        }
        else if (state[id] == STATE_BUSYRX)
        {
            signal TWIM.readDone[id](status, buffers[id]);
        }
    }
    async event void dmac.transfersCompleteFired[uint8_t id]()
    {
        atomic
        {
          call dmac.disableTransfer[id]();
          call dmac.disableTransfersCompleteIRQ[id]();
          call dmac.disableTransferErrorIRQ[id]();
          if (!nstop[id]) return;
          TWIMx[id]->idr.flat = 0x710; //ARBLST, DNAK, ANAK
        }
        while(!(TWIMx[id]->sr.bits.txrdy || TWIMx[id]->sr.bits.idle));
        if (TWIMx[id]->sr.bits.dnak) dispatch_status(id, STATUS_DNAK);
        else if (TWIMx[id]->sr.bits.anak) dispatch_status(id, STATUS_ANAK);
        else if (TWIMx[id]->sr.bits.arblst) dispatch_status(id, STATUS_ARBLST);
        else
        {
          dispatch_status(id, STATUS_OK);
        }
    }
    async event void dmac.reloadableFired[uint8_t id]()
    {
        printf("dmac reloadable\n");
    }
    async event void dmac.transferErrorFired[uint8_t id]()
    {
        dispatch_status(id, STATUS_ERR);
    }
    default async event void TWIM.readDone [uint8_t id] (int stat, uint8_t* buf) {}
    default async event void TWIM.writeDone [uint8_t id] (int stat, uint8_t* buf) {}

    async command error_t TWIM.write [uint8_t id] (uint8_t flags, uint8_t addr, uint8_t *src, uint8_t len)
    {
        twim_cmdr_t v;
        int i;

        if (call dmac.transferBusy[id]())
        {
            printf ("dmac says no go\n");
            return EBUSY;
        }

        //printf( "attempting addr %02x on port %d\n", addr, id);

       // TWIMx[id]->cr.flat = 1<<0; //men
       // TWIMx[id]->cr.flat = 1<<7; //swrst
       // TWIMx[id]->cr.flat = 1<<1; //mdis
        v.flat = 0;
        v.bits.read = 0;
        v.bits.sadr = addr>>1;
        v.bits.tenbit = 0;
        v.bits.start = (flags & FLAG_DOSTART) != 0;
        v.bits.stop = (flags & FLAG_DOSTOP) != 0;
        nstop[id] = (flags & FLAG_DOSTOP) == 0;
        v.bits.pecen = 0;
        v.bits.nbytes = len;
        v.bits.acklast = (flags & FLAG_ACKLAST) != 0;
        v.bits.hs = 0;
        v.bits.valid = 1;
        buffers[id] = src;
        state[id] = STATE_BUSYTX;
        call dmac.setPeripheral[id](SAM4L_PID_TWIM0_TX + id);
        TWIMx[id]->ncmdr.flat = v.flat;
        TWIMx[id]->cr.flat = 1<<0; //men
        TWIMx[id]->scr.flat = 0xFFFFFFFF;
        atomic
        {
            TWIMx[id]->ier.flat = 0x710; //ARBLST, DNAK, ANAK, IDLE
            call dmac.setAddressCountReload[id]((uint32_t)(&src[0]), len);
            call dmac.enableTransfersCompleteIRQ[id]();
            call dmac.enableTransferErrorIRQ[id]();
        }
        call dmac.enableTransfer[id]();
        return SUCCESS;
    }

    void TWIM0_Handler(void) @C() @spontaneous()
    {
        call IRQWrapper.preamble();
        if (TWIMx[0]->sr.bits.dnak) dispatch_status(0, STATUS_DNAK);
        else if (TWIMx[0]->sr.bits.anak) dispatch_status(0, STATUS_ANAK);
        else if (TWIMx[0]->sr.bits.arblst) dispatch_status(0, STATUS_ARBLST);
        else if (TWIMx[0]->sr.bits.idle) dispatch_status(0, STATUS_OK);
        else
        {
            printf("STRANGE TWIM0 HANDLER\n");
        }
        call IRQWrapper.postamble();
    }
    void TWIM1_Handler(void) @C() @spontaneous()
    {
        call IRQWrapper.preamble();
        if (TWIMx[1]->sr.bits.dnak) dispatch_status(1, STATUS_DNAK);
        else if (TWIMx[1]->sr.bits.anak) dispatch_status(1, STATUS_ANAK);
        else if (TWIMx[1]->sr.bits.arblst) dispatch_status(1, STATUS_ARBLST);
        else if (TWIMx[1]->sr.bits.idle) dispatch_status(1, STATUS_OK);
        else
        {
            printf("STRANGE TWIM1 HANDLER\n");
        }
        call IRQWrapper.postamble();
    }
    void TWIM2_Handler(void) @C() @spontaneous()
    {
        call IRQWrapper.preamble();
        if (TWIMx[2]->sr.bits.dnak) dispatch_status(2, STATUS_DNAK);
        else if (TWIMx[2]->sr.bits.anak) dispatch_status(2, STATUS_ANAK);
        else if (TWIMx[2]->sr.bits.arblst) dispatch_status(2, STATUS_ARBLST);
        else if (TWIMx[2]->sr.bits.idle) dispatch_status(2, STATUS_OK);
        else
        {
            printf("STRANGE TWIM2 HANDLER %d\n", TWIMx[2]->sr.flat);
        }
        call IRQWrapper.postamble();
    }
    void TWIM3_Handler(void) @C() @spontaneous()
    {
        call IRQWrapper.preamble();
        if (TWIMx[3]->sr.bits.dnak) dispatch_status(3, STATUS_DNAK);
        else if (TWIMx[3]->sr.bits.anak) dispatch_status(3, STATUS_ANAK);
        else if (TWIMx[3]->sr.bits.arblst) dispatch_status(3, STATUS_ARBLST);
        else if (TWIMx[3]->sr.bits.idle) dispatch_status(3, STATUS_OK);
        else
        {
            printf("STRANGE TWIM3 HANDLER\n");
        }
        call IRQWrapper.postamble();
    }
}
