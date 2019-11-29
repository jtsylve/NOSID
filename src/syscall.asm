; system calls

SYS_YIELD = $00 ; yield to the task schedler
SYS_FORK  = $01 ; start a new task
SYS_KILL  = $02 ; kill a task

!macro syscall .n {
    lda #.n
    brk
    nop
}

; yield to the scheduler, causing an early task switch
!macro yield {
    +syscall SYS_YIELD
}

; fork input structure
FORK_EP    = $00 ; entry point of the code
FORK_IT    = $02 ; input  type
FORK_OT    = $03 ; output type
FORK_IP    = $04 ; input parameters
FORK_OP    = $06 ; output parameters
FORK_ID    = $08 ; task id (page number of backup stack)
_FORK_SIZE = $09 ; size of fork input structure

; start a new task
!macro fork_prep .ep, .it, .ot, .ip, .op, .id {
    +reserve_stack _FORK_SIZE

    inx

    lda #<.ep
    sta STACK+FORK_EP, x
    lda #>.ep
    sta STACK+FORK_EP+1, x
    lda #.it
    sta STACK+FORK_IT, x
    lda #.ot
    sta STACK+FORK_OT, x
    lda #<.ip
    sta STACK+FORK_IP, x
    lda #>.ip
    sta STACK+FORK_IP+1, x
    lda #<.op
    sta STACK+FORK_OP, x
    lda #>.op
    sta STACK+FORK_OP+1, x
    lda #.id
    sta STACK+FORK_ID, x
    ldy #>STACK
}

!macro fork .ep, .it, .ot, .ip, .op, .id {
    +fork_prep .ep, .it, .ot, .ip, .op, .id
    +syscall SYS_FORK
    +free_stack _FORK_SIZE
}

; kill a task
; TID stored in y
!macro kill {
    +syscall SYS_KILL
}
