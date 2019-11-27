; task management

; initialize the task subsystem and start the initial process
.task_init
    +fork_prep .dummy_task, IT_NULL, OT_CONSOLE, 0, CONSOLE1, $C0
    
; initialize and start a task
; task struct is in Y:X
.task_start
    ; save the task struct in the start pointer
    txa
    sta TASK_START_PTR
    tya
    sta TASK_START_PTR+1

    ; store the EP right above the stack
    ldy #FORK_EP
    lda (TASK_START_PTR), y
    sta INIT_TASK_SP-1
    ldy #FORK_EP+1
    lda (TASK_START_PTR), y
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

    ; set console output
    ldy #FORK_OP
    lda (TASK_START_PTR), y
    sta CTOFFSET
    lda #<.dev_console_output
    sta OUTPUT
    lda #>.dev_console_output
    sta OUTPUT+1
    
ti_done
    ldx #INIT_TASK_SP
    txs
    cli
    jmp (INIT_TASK_SP-1)

; terminate a task
.task_exit
    sei
    jmp .task_init

.task_kill
    rts

; switch tasks
.task_switch
    rts

.dummy_task
    +puts .hello_world
    rts
   

.hello_world !scr "Hello, World!", CS_CRLF, CS_EOS