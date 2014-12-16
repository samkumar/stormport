.cpu cortex-m4
.syntax unified
.thumb
.text

  /*; Exported functions*/
  .globl __bootstrap_payload
  .globl __context_switch


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
