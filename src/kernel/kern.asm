; KERN is the main kernel binary
!to "kern", cbm


!src "../hardware.asm"
!src "../memmap.asm"

!src "../lib/libkern.asm"

!src "config.asm"

* = KERN

.kern_init
    ; disable VICII interrupts
    lda #0
    sta $D01A   ; interrupt mask register

    ; disable CIA timers
    lda #%01111111
    sta CIA1_ICR
    sta CIA2_ICR

    ; set up interrupt vectors
    +write16 VECTOR_CS, .kern_init
    +write16 VECTOR_IRQ, .irq_handler

    ; set heartbeat timer latch value
    +write16 CIA1_TA_LO, HEARTBEAT_IRQ_TIME

    ; enable heartbeat timer
    lda #%10000001
    sta CIA1_ICR
    lda #%00010001
    sta CIA1_CRA

    ; bank out I/O space
    lda #%100
    sta CPU_OUTR

    ; enable interrupts
    cli 

    ; TODO - start init task
    jmp *

.irq_handler
    +save_regs
    inc $D020 ; change border color (just for testing)

    lda CIA1_ICR    ; acknowledge interrupt
    +restore_regs
    rti