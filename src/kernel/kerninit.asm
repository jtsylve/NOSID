; KERNINIT is temporary code to initialize the kernel for operations
!to "kerninit", cbm

!src "../memmap.asm"

* = KERNINIT

; Change the screen color just so we know everything's working
lda #1
sta $d020

jmp *