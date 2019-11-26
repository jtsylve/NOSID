; task management

; initialize the task subsystem and start the initial process
.task_init
    ldx #CONSOLE1
    lda #<.dummy_task
    ldy #>.dummy_task
    
; initialize and start a task
; entry point is in Y:A
.task_start
    ; store the EP right above the stack
    sta INIT_TASK_SP-1
    tya
    sta INIT_TASK_SP

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
    ldx #INIT_TASK_SP
    txs
    cli
    jmp (INIT_TASK_SP-1)

.task_exit
    jmp *

.dummy_task
    +puts .hello_world
    rts
   

.hello_world !scr "Hello, World!", CS_CRLF, CS_EOS