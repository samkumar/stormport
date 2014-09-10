
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
        uint32_t n, t1;
        call ast.disable();
        call ast.disableAlarmIRQ();
        call ast.clearAlarm();
        n = call Alarm.getNow();
        //We are discarding bottom bit later in shift.
        t0 &= ~1;
        t1 = (t0 + dt) & ~1;

        if ( (t0 <= n && n < t1) ||
             (t1 < n && n <= t0) )
        {//now is between the two events
            if (t1 < t0)
            {
                call ast.enable();
                signal Alarm.fired();
            }
            else
            {
                call ast.setAlarm(t1 >> 1);
                call ast.enableAlarmIRQ();
                call ast.enable();
            }
        }
        else
        {
            if (t0 <= t1)
            {
                call ast.enable();
                signal Alarm.fired();
            }
            else
            {
                call ast.setAlarm(t1 >> 1);
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