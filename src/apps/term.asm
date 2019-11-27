; terminal
!to "term", cbm

!src "../lib/libkern.asm"

* = TERM

.term_start
    +puts .hello_world
    rts
   
.hello_world    !scr "Hello, World!", CS_CRLF, CS_EOS


!if * >= IVECTORS {
    !error "terminal too big"
}

