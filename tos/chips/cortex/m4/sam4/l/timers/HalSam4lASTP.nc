
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
    uint32_t alarmRunning;

    command error_t Init.init()
    {
        alarmRunning = FALSE;
        call bscif.enableRC32K();
        call bpm.select32kInternal();
        call ASTClockCtl.enable();
        call ast.selectClk_32khz();
        //This unfortunately results in a 16khz clock.
        call ast.setPrescalarBit(0);
        call ast.disableAlarmIRQ();
        call ast.disableOverflowIRQ();
        call ast.enableAlarmWake();
        call ast.disablePeriodIRQ();
        call ast.clearAlarm();
        call ast.enable();
    }

    async event void ast.alarmFired()
    {
        signal Alarm.fired();
    }

    default async event void Alarm.fired(){}

    async event void ast.overflowFired()
    {
        signal Counter.overflow();
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
        uint32_t cv, t1;
        call ast.disable();
        call ast.disableAlarmIRQ();
        call ast.clearAlarm();
        cv = call ast.getCounterValue();
        
        atomic {
            if (cv > (uint32_t) 0x7FFFFFFF) { // artificially overflow at 31 bits
                cv &= (uint32_t) 0x7FFFFFFF;
                call ast.setCounterValue(cv);
            }
        }
        
        // t1 is the counter value at which the timer should fire, on the 16 kHz timer
        t1 = (t0 >> 1) + (dt >> 1) + (t0 & dt & 1);
        
        // t0 is the 16 kHz counter corresponding to the base time
        t0 >>= 1;
         
        if (cv < t0) {
            // t0 is guaranteed to be in the past, so if cv < t0, then that's because counter has overflowed
            t1 &= (uint32_t) 0x7FFFFFFF;
        }
        
        /*
         * Now, t1 is the 16 kHz counter value when the Alarm should fire. It may be higher than 0x7FFFFFFF.
         * But, that's OK, because it's correct relative to cv. It will fire on time, and then when the next
         * alarm is started via this function, cv will be artificially wrapped before it is compared to t0
         * and t1 of that function call.
         *
         * Note that there is absolutely no possibility of overflow in computing t1; since t1 represents a
         * 16 kHz count and t0 and dt represent 32 kHz counts, their sum will not overflow t1. However, since
         * t1 is computed as an offset from t0, it must be wrapped if cv wrapped, so that it is correct
         * relative to cv (not necessarily relative to t0).
         */
        
        if (cv < t0 || cv >= t1) {
            // We need to fire the alarm right away, since it has already expired.
            call ast.enable();
            signal Alarm.fired();
        } else {
            // Wait until t1.
            call ast.setAlarm(t1);
            call ast.enableAlarmIRQ();
            call ast.enable();
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
