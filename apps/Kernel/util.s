.cpu cortex-m4
.syntax unified
.thumb
.text

  /*; Exported functions*/
  .globl __bootstrap_payload
  .globl __context_switch
  .globl __inject_function

.thumb_func
/* r0 is payload base address */
__bootstrap_payload:
    /* Get the payload to tell us the start2 address and stack address */
    push {lr}
    blx r0
    pop {lr}
    /* Load the first stack frame */
    movw r2, #0      /* xPSR */
    movt r2, #0x100
    stmdb r1!,  {r0, r2}  /* PC, xPSR */
    stmdb r1!, {r2, r3, r12, lr} /* LR is a dummy */
    stmdb r1!, {r2, r3} /* dummies */
    msr psp, r1
    bx lr

.thumb_func
__eject_function:
/* we return here in process mode when the callback completes */
    svc #0x81 /* eject() */
    /* we don't return from that ISR because magic */
    
.thumb_func
/* inject the function r3 with arguments r0, r1, r2 into the process */
__inject_function:
    push {r5,r6,r7}
    mrs r7, psp /* use r7 as process sp */
    /* push fake ISR frame */
    movw r5, #0
    movt r5, #0x100 /* xPSR */
    stmdb r7!, {r0, r5} /* PC, xPSR */
    ldr  r6, =__eject_function
    stmdb r7!, {r1, r2, r3, r4, r5, r6} /* r0:=r1, .. r12:=r5, lr:=__eject_function */
    msr psp, r7
    pop {r5,r6,r7}
    bx lr
        
    
.thumb_func
__context_switch:
    cbnz r0, to_master
to_slave:
    mov r1, #0x2
    msr CONTROL, r1
    movw LR, #0xFFFD
    movt LR, #0xFFFF
    bx lr
to_master:
    mov r1, #0x0
    msr CONTROL, r1
    movw LR, #0xFFF9
    movt LR, #0xFFFF
    bx lr
