; kernel library and helpful macros

!src "../cs.asm"
!src "../io.asm"
!src "../stack.asm"
!src "../zero.asm"

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

; indirect function call
!macro ijsr .address {
    tax             ; preserve A

    ; push the last byte of the jmp instruction to the stack.
    ; when the function returns this will be the IP popped
    lda #>+ - 1
    pha
    lda #<+ - 1
    pha

    txa             ; restore A
    jmp (.address)  ; indirect jump to function
+
}

; get a byte from the input device
!macro getc {
+   +ijsr INPUT     ; call the function at the task's input pointer
    bcc -           ; if no errors then we're done
    cmp IO_NODATA   ; test if the device doesn't have data for us yet
    bne -           ; if any other error then we're done
    +yield          ; yield to the task scheduler
    jmp +           ; try again
-
}

; write a byte to the output device
!macro putc {
    +ijsr OUTPUT    ; call the function at the task's output pointer
}

; writes a string to the output device
!macro puts .string {
    ldx #0          ; init counter
    beq +           ; skip
-   +putc           ; output character
    pla             ; pull counter value from stack
    bcs * + 12      ; bail on error
    tax             ; restore counter
    inx             ; increment counter
+   txa             ; preserve counter
    pha             ; push counter value to stack
    lda .string,x   ; read next character
    jmp -
}

!macro console_activate .n {
    !if .n < 0 or .n > NUM_CONSOLES {
        !error "invalid console number"
    }

    !set crbits = %0100      ; character rom bits
    !set vbits  = %0111 + .n ; video bits

    lda #(vbits << 4) + crbits
    sta VICII_PTR
}