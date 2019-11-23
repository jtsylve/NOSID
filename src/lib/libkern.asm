; kernel library and helpful macros

!src "../kernel/io.asm"
!src "../kernel/stack.asm"

; write a 16 bit value to an address
!macro write16 .address, .value {
    lda #<.value
    sta .address
    lda #>.value
    sta .address+1
}

; fill memory with a value
!macro memset .address, .value, .num {
    lda #.value

    !if .num > 255 {
        ldx #0
-
        !for i, 0, (.num / 256) - 1 {
            sta .address + i*256, x
        }

        inx
        bne -
    }

    !set mod = .num % 256
    !set modaddr = .address + .num - mod

    !if mod != 0 {
        ldx #mod
-       dex
        sta modaddr,x
        bne -
    }
}

; copy bytes in memory
!macro memcpy .dest, .src, .num {
    !if .num > 255 {
        ldx #0
-
        !for i, 0, (.num / 256) - 1 {
            lda .src  + i*256, x
            sta .dest + i*256, x
        }

        inx
        bne -
    }

    !set mod     = .num % 256
    !set modsrc  = .src + .num - mod
    !set moddest = .dest + .num - mod

    !if mod != 0 {
        ldx #mod
-       dex
        lda modsrc, x
        sta moddest, x
        txa
        bne -
    }
}

; push all register to stack
!macro save_regs {
    pha
    txa
    pha
    tya
    pha
}

; restore saved registers from stack
!macro restore_regs {
    pla
    tay
    pla
    tax
    pla
}

; yield to the scheduler, causing an early task switch
!macro yield {
    brk
    nop
}

; get a byte from the input device
!macro getc {
+   jsr INPUT       ; attempt to read a byte
    bcc done        ; if no errors then we're done
    cmp IO_NODATA   ; test if the device doesn't have data for us yet
    bne done        ; if any other error then we're done
    +yield          ; yield to the task scheduler
    jmp +           ; try again
done
}

; write a byte to the output device
!macro putc {
    jsr OUTPUT  ; write a byte
}

; writes a string to the output device
!macro puts .string {
    ldx #0          ; init counter
    beq +           ; skip
-   +putc           ; output character
    bcs done        ; bail on error
    inx
+   lda .string,x   ; read next character
    bne -           ; continue if non-zero
done
}