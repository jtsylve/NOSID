; task management

; terminate a task
.task_exit
    ldy TASKID
    lda #0
    sta TASKID
    +kill

; kill a task
.task_kill
    jsr .task_list_remove
    bmi .task_init ; if we have no more running processes reinit
    rts

; initialize the task subsystem and start the initial process
.task_init
    +fork_prep TERM, IT_NULL, OT_CONSOLE, 0, CONSOLE1, >TERM_TS
    
; initialize and start a task
; task struct is in Y:X
.task_start
    ; save the task struct in the start pointer
    txa
    sta TASK_PTR
    tya
    sta TASK_PTR+1

    ; store the EP right above the stack
    ldy #FORK_EP
    lda (TASK_PTR), y
    sta INIT_TASK_SP-1
    ldy #FORK_EP+1
    lda (TASK_PTR), y
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
    lda (TASK_PTR), y
    sta CTOFFSET
    lda #<.dev_console_output
    sta OUTPUT
    lda #>.dev_console_output
    sta OUTPUT+1

    ldy #FORK_ID
    lda (TASK_PTR), y
    sta TASKID
    tay
    jsr .task_list_add
    
ti_done
    ldx #INIT_TASK_SP
    txs

    +restart_irq_timer

    cli
    jmp (INIT_TASK_SP-1)

; switch the current task out
.task_switch_out
    ; store the task page to the indirect pointer
    lda TASKID
    beq tso_done
    sta TASK_PTR+1
    lda #0
    sta TASK_PTR

    ; copy stack pointer to top of task page
    tsx
    txa
    ldy #0
    sta (TASK_PTR), y

    ; copy stack to task page (minus the return address)
    tay
    iny
    iny
tso_copy_stack
    lda STACK, y
    sta (TASK_PTR), y
    iny
    bne tso_copy_stack
tso_done
    rts

; switch a new task in
.task_switch_in
    ; locate the next task page and write it to the indirect pointer
    lda #0
    sta TASK_PTR
    jsr .task_list_find
    sta TASK_PTR+1

    ; read stack pointer from top of task page
    ldy #0
    lda (TASK_PTR), y
    tay

    ; override return address with the one from this function
    tsx
    lda STACK+1,x
    iny
    sta (TASK_PTR), y
    lda STACK+2,x
    iny
    sta (TASK_PTR), y
    dey
    dey

    ; set the stack pointer
    tya
    tax
    txs

    ; copy the saved stack from the task page
tsi_copy_stack
    lda (TASK_PTR), y
    sta STACK, y
    iny
    bne tsi_copy_stack
    rts

.task_nrunning !byte $FF ; number of running tasks - 1
.task_marker   !byte MAX_TASKS-1 ; pointer to the next task to be executed
.task_list     !for 1, 0, MAX_TASKS { !byte $00 }

; find next task
.task_list_find
    ldx .task_marker
    dex
    bpl tlf_search
tlf_0
    ldx #MAX_TASKS-1

tlf_search
    lda .task_list, x
    bne tlf_found
    dex
    bpl tlf_search
    bmi tlf_0

tlf_found
    pha
    txa
    sta .task_marker
    pla
    rts


; add a task to the running list
; TID stored in y
.task_list_add
    ldx #MAX_TASKS-1
tla_search
    lda .task_list, x
    beq tla_found
    dex
    bpl tla_search

    ; TODO: handle running out of tasks
    !byte $02 ; crash

tla_found
    tya
    sta .task_list, x
    txa
    inc .task_nrunning
    rts

; remove a task to the running list
; TID stored in y
.task_list_remove
    tya
    sta tlr_search + 4

    ldx #MAX_TASKS-1
tlr_search
    lda .task_list, x
    cmp #00
    beq tlr_found
    dex
    bpl tlr_search

    ; TODO: handle task not found
    !byte $02 ; crash

tlr_found
    lda #00
    sta .task_list, x
    dec .task_nrunning
    rts
