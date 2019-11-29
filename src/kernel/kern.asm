; KERN is the main kernel binary
!to "kern", cbm

!src "../lib/libkern.asm"

!src "config.asm"

* = KERN

!macro restart_irq_timer {
    ; restart heartbeat timer
    lda #%00010001
    sta CIA1_CRA

    lda CIA1_ICR    ; acknowldege interrupts (in case one fired during irq)
}

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

    lda CIA1_ICR        ; check/acknowledge interrupt
    bne irq_switch_task ; if non zero this the timer fired and we switch tasks

    ; handle syscalls here
    tsx
    lda SAVED_REG_A, x
    beq irq_switch_task ; yield
    cmp #SYS_FORK
    beq irq_sys_fork
    cmp #SYS_KILL
    beq irq_sys_kill
    bne irq_done        ; unkown syscall

irq_sys_fork
    jsr .task_switch_out
    tsx
    lda SAVED_REG_Y, x
    tay
    lda SAVED_REG_X, x
    tax
    jmp .task_start

irq_sys_kill
    lda SAVED_REG_Y, x
    tay
    jsr .task_kill

irq_switch_task
    jsr .task_switch_out
    jsr .task_switch_in

irq_done
    +restart_irq_timer

    +restore_regs   ; restore registers
    rti

.nmi_handler
    rti


!if * >= TERM_TS {
    !error "kernel too big"
}