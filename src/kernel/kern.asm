; KERN is the main kernel binary
!to "kern", cbm


!src "../hardware.asm"
!src "../memmap.asm"

!src "../lib/libkern.asm"

!src "config.asm"

* = KERN

; kernel intialization function
; THIS MUST ALWAYS BE AT KERN!
.kern_init
    ; disable VICII interrupts
    lda #0
    sta VICII_IE ; interrupt mask register

    ; disable CIA timers
    lda #%01111111
    sta CIA1_ICR
    sta CIA2_ICR

    ; set up interrupt vectors
    +write16 VECTOR_CS, .kern_init
    +write16 VECTOR_IRQ, .irq_handler
    +write16 VECTOR_NMI, .nmi_handler

    ; set heartbeat timer latch value
    +write16 CIA1_TA_LO, HEARTBEAT_IRQ_TIME

    ; enable heartbeat timer IRQ
    lda #%10000001
    sta CIA1_ICR

    ; start heartbeat timer
    lda #%00010001
    sta CIA1_CRA

    ; set kernel stack pointer
    ldx #INIT_KERN_SP
    txs

    ; initialize subsystems
    jmp .kern_init_subsystems

!src "task.asm"
!src "device/devices.asm"

.kern_init_subsystems
    jsr .device_init
    jmp .task_init

.irq_handler
    +save_regs      ; backup registers

    lda CIA1_ICR    ; acknowledge interrupt

    ; inc VICII_EC    ; change border color (just for testing)

    ; restart heartbeat timer
    lda #%00010001
    sta CIA1_CRA

    +restore_regs   ; restore registers
    rti

.nmi_handler
    rti