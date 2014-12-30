TROUBLE IN TIMER PARADISE
        ...or...
HOW I LEARNED TO START WORRYING AND STOP LOVING TIMERS
an essay exhaustively researched by Gabe



TimerA is a periodic timer; when fired, it posts a task that does nothing.
TimerB is a one shot timer; when fired, it posts a task that restarts the oneshot timer for TimerB

With just these 2 timers, it appears to work fine.

BUT..

If DEFINE_ALL_TIMERS is included in the Makefile, then 4 more timer components
are wired up (note, however, that these timers are never used/called). In this case,
then timerB does not appear to fire more than 3-4 times. TimerA stops as well.

If we uncomment the timers and play around with the oneshot timers, then we can observe
a case where only the oneshot timer with the lowest wait time fires after being triggered from Boot
and from restartoneshot().
