; terminal
!to "term", cbm

!src "../lib/libkern.asm"

* = TERM

.term_start
    +puts sp1
    +fork .task1, IT_NULL, OT_CONSOLE, 0, CONSOLE1, $C0
    +puts sp2
    +fork .task2, IT_NULL, OT_CONSOLE, 0, CONSOLE1, $C1
    +puts goodbye
    rts

.task1
    +puts task1
    +yield
    jmp .task1

.task2
    +puts task2
    +yield
    jmp .task2

goodbye !scr "goodbye", CS_CRLF, CS_EOS
sp1 !scr "Spawning Task 1!", CS_CRLF, CS_EOS
sp2 !scr "Spawning Task 2!", CS_CRLF, CS_EOS
task1 !scr "Task 1!", CS_CRLF, CS_EOS
task2 !scr "Task 2!", CS_CRLF, CS_EOS


!if * >= IVECTORS {
    !error "terminal too big"
}

