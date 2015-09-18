


module LowPowerTimerDriverP
{
    provides interface Driver;
    uses interface Alarm<T32khz, uint32_t>  as Alarm;
}
implementation
{

    typedef struct
    {
        uint32_t addr;
        void* r;
    } callback_t;

    #define FLAG_ALLOCATED  1
    #define FLAG_PENDING    2
    #define FLAG_PERIODIC   4
    typedef struct
    {
        uint32_t origin; //set by filler
        uint32_t duration; //set by filler
        callback_t cb; //set by filler
        uint8_t flags; //set by get_tentry
    } tentry_t;

    #define BUFSIZE 64
    #define NONE 0xFFFF
    #define CBQUEUESIZE 32
    tentry_t norace timer_buffer [BUFSIZE];
    callback_t callback_queue [CBQUEUESIZE];
    uint16_t allocidx;
    uint16_t cb_widx;
    uint16_t cb_ridx;
    uint64_t norace volatile upper64;
    task void update_queues();
    inline uint32_t getNow()
    {
        return call Alarm.getNow();
    }

    void enqueue_cb(uint16_t idx)
    {
        if (((cb_widx + 1) & (CBQUEUESIZE - 1)) == cb_ridx)
            return; //drop
        callback_queue[cb_widx] = timer_buffer[idx].cb;
        cb_widx = (cb_widx+1) & (CBQUEUESIZE-1);
    }
    /*
     * Get a timer entry out of the buffer
     */
    uint16_t get_tentry()
    {
        uint16_t curidx = (allocidx + 1) & (BUFSIZE-1);
        while (curidx != allocidx)
        {
            if (timer_buffer[curidx].flags == 0)
            {
                timer_buffer[curidx].flags = FLAG_ALLOCATED;
                return curidx;
            }
            curidx = (curidx + 1) & (BUFSIZE -1);
        }
        return NONE;
    }



    void dispatchCallbacks(uint32_t now)
    {
        int num;
        for (num=0; num<BUFSIZE; num++)
        {
            tentry_t *t = &timer_buffer[num];
            if ((t->flags & 3) == 1)
            {
                uint32_t elapsed = now - t->origin;
                int32_t remaining = t->duration - elapsed;
                if (remaining < 0)
                {
                    enqueue_cb(num);
                    if (t->flags & FLAG_PERIODIC)
                    {
                        t->origin += t->duration;
                    }
                    else
                    {
                        t->flags = 0; //dealloc
                    }
                }
            }
        }
        post update_queues();
    }
    task void update_queues()
    {
        uint32_t now;
        uint32_t nxt;
        int32_t min_remaining = (1UL << 31) - 1;
        bool min_remaining_isset = FALSE;
        uint16_t num;
        now = getNow();
        for (num=0; num<BUFSIZE; num++)
        {
            tentry_t *t = &timer_buffer[num];
            if ((t->flags & 3) == 1)
            {
                uint32_t elapsed = now - t->origin;
                int32_t remaining = t->duration - elapsed;
                if (remaining < min_remaining)
                {
                    min_remaining = remaining;
                    min_remaining_isset = TRUE;
                }
            }
        }
        if (min_remaining < 0)
        {
            dispatchCallbacks(now);
        }
        else
        {
            call Alarm.startAt(now, min_remaining);
        }
    }
    command driver_callback_t Driver.peek_callback()
    {
        if (cb_ridx == cb_widx) return NULL;
        return &callback_queue[cb_ridx];
    }
    command void Driver.pop_callback()
    {
        cb_ridx = (cb_ridx + 1) & (CBQUEUESIZE - 1);
    }
    async command syscall_rv_t Driver.syscall_ex(
        uint32_t number, uint32_t arg0,
        uint32_t arg1, uint32_t arg2,
        uint32_t *argx)
    {
        switch(number & 0xFF)
        {
            case 0x01: //set_abs_timer(ticks, periodic, cb, void *r) -> int32_t id or -1 if error
            {
                uint16_t idx = get_tentry();
                tentry_t *t;
                if (idx == NONE)
                {
                    return (uint32_t) -1;
                }
                t = &timer_buffer[idx];
                t->origin = getNow();
                t->duration = arg0;
                if (arg1)
                    t->flags |= FLAG_PERIODIC;
                t->cb.addr = arg2;
                t->cb.r = (void*)argx[0];
                post update_queues();
                return idx;
            }
            case 0x02: //get_now() -> uint32_t now
            {
                return getNow();
            }
            case 0x03: //get_now_s16() ->uint32_t now(>>16)
            {
                return (uint32_t) (upper64);
            }
            case 0x04: //get_now_s48() ->uint32_t now(>>16)
            {
                return (uint32_t) (upper64>>32);
            }
            case 0x05: //cancel(id) ->int32 0 for ok -1 for fail
            {
                if (arg0 > BUFSIZE) return (uint32_t)-1;
                if (timer_buffer[arg0].flags == 0) return (uint32_t) -1;
                timer_buffer[arg0].flags = 0;
                return 0;
            }
            default:
                return (uint32_t) -1;
        }
    }

    async event void Alarm.fired()
    {
        post update_queues();
    }

}
