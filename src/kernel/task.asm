; task management

; initialize and start a task
; entry point is in Y:A
.task_init
    ; decrement the EP
    ora #0
    bne * + 3
    dey
    sec
    sbc #1

    ; store the EP to the stack
    sta INIT_EP
    tya
    sta INIT_EP+1

    ; store the task exit function to the stack
    ; this will be called when the EP function returns
    lda #<.task_exit-1
    sta EXITP
    lda #>.task_exit
    sta EXITP+1

    ; TODO - allocate a new page for the task and store the number as the TID

    ; set input as null
    lda #<.dev_null_input
    sta INPUT
    lda #>.dev_null_input
    sta INPUT+1
    
    ; check to see if we're using an output
    txa
    beq ti_null_output

    ; set console output
    sta CTOFFSET
    lda #<.dev_console_output
    sta OUTPUT
    lda #>.dev_console_output
    sta OUTPUT+1
    jmp ti_done

ti_null_output
    ; set null output
    lda #<.dev_null_output
    sta OUTPUT
    lda #>.dev_null_output
    sta OUTPUT+1
    
ti_done
    ldx #$F1
    txs
    cli
    rts

.task_exit
    jmp *

.dummy_task
    +puts .hello_world
    rts
   

.hello_world !scr "Hello, World!", CS_EOS