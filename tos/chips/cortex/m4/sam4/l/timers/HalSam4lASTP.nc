#include "printf.h"
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
        //call ast.setPeriod(18);
        call ast.disablePeriodIRQ();
        call ast.clearAlarm();
        call ast.enable();
    }

    async event void ast.alarmFired()
    {
        signal Alarm.fired();
    }
    
    async event void ast.periodFired()
    {
        uint32_t cv = call ast.getCounterValue();
        uint32_t newval;
        if (cv > 0x7FFFFFFF) { // artificially overflow at 31 bits
            newval = cv - 0x80000000;
            call ast.setCounterValue(cv - 0x80000000);
            
            // What if we missed a timer?
            if (call ast.getAlarm() <= newval) {
                call ast.setAlarm(2 + call ast.getCounterValue());
            }
        }
        call ast.clearPeriod();
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
        /** t0 is a time in the past. The Alarm should fire dt ticks after t0. */
        
        volatile uint32_t t0_volatile = t0;
        volatile uint32_t dt_volatile = dt;
        volatile uint32_t n, t1, cv;
        call ast.disable();
        call ast.disableAlarmIRQ();
        call ast.clearAlarm();
        cv = call ast.getCounterValue();
        if (cv > (uint32_t) 0x7FFFFFFF) { // artificially overflow it at 31 bits.
            cv -= (uint32_t) 0x80000000;
            call ast.setCounterValue(cv);
        }
        n = cv << 1;
        
        // t1 is the time at which the Alarm should fire.
        // We are discarding bottom bit because the underlying timer is only 16 kHz, but the inputs are in 32 kHz ticks
        t1 = ((t0 >> 1) + (dt >> 1)) + ((t0 & 1) && (dt & 1)); // we bitshift first so there's no overflow possibility
        t0 >>= 1;
        
        /*
         * Now, t1 is the 16 kHz counter value when the Alarm should fire. It may be higher than 0x7FFFFFFF.
         * But, that's OK. It will fire on time, and then when the next alarm is started via this function,
         * Alarm will be artificially wrapped before it is compared to t0 and t1 of that function call.
         * Note that there is absolutely no possibility of overflow in computing t1 and t0, since we have
         * effectively gained a bit when converting from 32 kHz to 16 kHz.
         */
         
        if (t0 <= cv && cv < t1) {
            // Wait until t1.
            call ast.setAlarm(t1);
            call ast.enableAlarmIRQ();
            call ast.enable();
        } else {
            // We need to fire the alarm right away, since it has already expired.
            // t0 is in the past, so if cv < t0, then the counter has overflowed and it's still past t1.
            call ast.enable();
            signal Alarm.fired();
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
