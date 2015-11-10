module HalSam4lASTP
{
    provides
    {
        interface Init;
        interface Alarm<T32khz,uint32_t> as Alarm;
        interface LocalTime<T32khz> as LocalTime;
        interface Counter<T32khz,uint32_t> as Counter;
    }
    uses
    {
        interface Init as ASTInit;
        interface HplSam4lAST as ast;
        interface HplSam4lBPM as bpm;
        interface HplSam4PeripheralClockCntl as ASTClockCtl;
        interface HplSam4lBSCIF as bscif;
    }
}
implementation
{
    /* Stores whether or not an alarm is currently scheduled on the AST.
       We could omit this and read the Interrupt Mask Register, but I think
       this is much cleaner. */
       
    bool alarmScheduled;

    command error_t Init.init()
    {
        uint32_t cvraw;
        
        alarmScheduled = FALSE;
        call bscif.enableRC32K();
        call bpm.select32kInternal();
        call ASTClockCtl.enable();
        call ast.selectClk_32khz();
        //This unfortunately results in a 16khz clock.
        call ast.setPrescalarBit(0);
        call ast.disableAlarmIRQ();
        call ast.enableOverflowIRQ();
        call ast.enableAlarmWake();
        call ast.disablePeriodIRQ();
        call ast.clearAlarm();
        call ast.clearOverflowed();
        
        atomic {
            // keep the counter value between 0x80000000 and 0xFFFFFFFF
            cvraw = call ast.getCounterValue();
            call ast.setCounterValue(cvraw | (uint32_t) 0x80000000);
        }
        
        call ast.enable();
    }

    async event void ast.alarmFired()
    {
        atomic {
            call ast.clearAlarm();
            alarmScheduled = FALSE;
            signal Alarm.fired();
        }
    }

    default async event void Alarm.fired(){}

    async event void ast.overflowFired()
    {
        uint32_t cvnew;
        atomic {
            call ast.clearOverflowed();
            call ast.disable();
            cvnew = (call ast.getCounterValue()) | (uint32_t) 0x80000000;
            call ast.setCounterValue(cvnew);
            if (alarmScheduled && (cvnew >= call ast.getAlarm())) {
                alarmScheduled = FALSE;
                call ast.enable();
                signal Alarm.fired();
            } else {
                call ast.enable();
            }
            signal Counter.overflow();
        }
    }

    default async event void Counter.overflow(){}

    //Counter
    async command uint32_t Counter.get()
    {
        return call ast.getCounterValue() << 1;
    }
    async command bool Counter.isOverflowPending()
    {
        return call ast.overflowed();
    }
    async command void Counter.clearOverflow()
    {
        call ast.clearOverflowed();
    }

    //LocalTime
    async command uint32_t LocalTime.get()
    {
        return call ast.getCounterValue() << 1;
    }

    //Alarm
    async command void Alarm.start(uint32_t v)
    {
        call Alarm.startAt(call Alarm.getNow(), v);
    }
    async command void Alarm.stop()
    {
        call ast.disableAlarmIRQ();
    }
    async command bool Alarm.isRunning()
    {
        return call ast.isEnabled();
    }
    async command void Alarm.startAt(uint32_t t0, uint32_t dt)
    {
        /* IMPLEMENTATION DETAILS
         * The AST is a 16kHz clock that wraps at 32 bits. We want to provide the abstraction of a
         * 32 kHz clock that wraps at 32 bits, or equivalently a 16 kHz clock that wraps at 31 bits.
         * We can model the AST as two clocks:
         * 1) A short clock that operates at 16 kHz and wraps at 31 bits
         * 2) A long clock that operates at 16 kHz and wraps at 32 bits
         * The code below calculates the counter value on the AST on the long clock, and calls the
         * value cv. It converts t0 to a value on the short clock. Then it computes t1 = t0 + dt on
         * the long clock.
         */
        uint32_t rawcv, cv, t1, tickstowait, ticksuntiloverflow;
        atomic {
            call ast.disable();
            call ast.disableAlarmIRQ();
            
            t1 = (t0 >> 1) + (dt >> 1) + (t0 & dt & 1);
            t0 >>= 1;
            
            rawcv = call ast.getCounterValue();
            cv = rawcv & (uint32_t) 0x7FFFFFFF;
            if (t0 > cv) {
                cv |= (uint32_t) 0x80000000; // convert cv to the value on the long clock.
            }
            
            if (t1 <= cv) {
                alarmScheduled = FALSE;
                call ast.enable(); // don't enable IRQ
                signal Alarm.fired();
            } else {
                alarmScheduled = TRUE;
                // wait for t1 - cv ticks
                tickstowait = t1 - cv;
                ticksuntiloverflow = ((uint32_t) 0xFFFFFFFF) - rawcv;
                call ast.setCounterValue(rawcv); // Handle any after-tick changes in the Counter Value
                if (tickstowait <= ticksuntiloverflow) {
                    call ast.setAlarm(rawcv + tickstowait);
                } else {
                    call ast.setAlarm(((uint32_t) 0x7FFFFFFF) + tickstowait - ticksuntiloverflow);
                }
                call ast.enableAlarmIRQ();
                call ast.enable();
            }
        }
    }
    async command uint32_t Alarm.getNow()
    {
        return call ast.getCounterValue() << 1;
    }

    async command uint32_t Alarm.getAlarm()
    {
        return call ast.getAlarm() << 1;
    }
}
