; virtual 16-bit ALU

VSTACKMAXREGS = 8
VSTACKBASE = $0100 - (VSTACKMAXREGS * 2)

; register aliases
R0 = 0
R1 = 1
R2 = 2
R3 = 3
R4 = 4
R5 = 5
R6 = 6
R7 = 7

; enter virtual 16-bit mode, and intialize R0
; R0 = Y:A
!macro venter {
    !set R0_low  = VSTACKBASE + (VSTACKMAXREGS * 2) - 2
    !set R0_high = VSTACKBASE + (VSTACKMAXREGS * 2) - 1

    sta R0_low
    tya
    sta R0_high
    ldx #R0_low
    ldy #R0_low
}

; enter virtual 16-bit mode, and intialize R0 with contents of memory
; R0 = *address
!macro venter .address {
    !set R0_low  = VSTACKBASE + (VSTACKMAXREGS * 2) - 2
    !set R0_high = VSTACKBASE + (VSTACKMAXREGS * 2) - 1

    lda <.address
    sta R0_low
    lda >.address
    sta R0_high
    ldx #R0_low
    ldy #R0_low
}

; enter virtual 16-bit mode, and intialize R0 with an immediate
; R0 = value
!macro venteri .value {
    !set R0_low  = VSTACKBASE + (VSTACKMAXREGS * 2) - 2
    !set R0_high = VSTACKBASE + (VSTACKMAXREGS * 2) - 1

    lda #<.value
    sta R0_low
    lda #>.value
    sta R0_high
    ldx #R0_low
    ldy #R0_low
}

; exit virtual 16-bit mode
; Y:A = RP
!macro vexit {
    lda VSTACKBASE+1, x
    tay
    lda VSTACKBASE, x
}

; exit virtual 16-bit mode
; *address = RP
!macro vexit .address {
    lda VSTACKBASE+1, x
    sta >.address
    lda VSTACKBASE, x
    sta <.address
}

; add a number of virtual registers to the vstack
!macro vpushregs .n {
    !if .n = 1 {
        ; 4 cycles
        dey
        dey
    } else {
        ; 8 cycles
        tya
        sec
        sbc #.n * 2
        tay
    }
}

; remove a number of virtual registers from the vstack
!macro vpopregs .n {
    !if .n = 1 {
        ; 4 cycles
        iny
        iny
    } else {
        ; 8 cycles
        tya
        clc
        adc #.n * 2
        tay
    }
}

; set the RP register to point to another register
!macro vsetrp .reg {
    clc
    tya
    adc #.reg * 2
    tax
}

; set the previous register
; RP = value
!macro vset .value {
    lda #<.value
    sta VSTACKBASE, x
    lda #>.value
    sta VSTACKBASE+1, x
}

; set a given register
; Rreg = value
!macro vset .reg, .value {
    +vsetrp .reg
    +vset   .value
}

; load the previous register with the contents of memory
; RP = *address
!macro vload .address {
    lda <.address
    sta VSTACKBASE, x
    lda >.address
    sta VSTACKBASE+1, x
}

; load a register with the contents of memory
; Rreg = address
!macro vload .reg, .address {
    +vsetrp .reg
    +vload  .address
}

; copy the contents from a register to the previous register
; RP = Rreg
!macro vcopy .reg {
    tya
    pha

    clc
    adc #.reg * 2
    tay

    lda VSTACKBASE, y
    sta VSTACKBASE, x
    lda VSTACKBASE+1, y
    sta VSTACKBASE+1, x

    pla
    tay
}

; copy the contents of a register to a destination register
; Rdest = Rreg
!macro vcopy .dest, .reg {
    +vsetrp .dest
    +vcopy  .reg
}

; push the previous register to the stack
!macro vpush {
    lda VSTACKBASE, x
    pha
    lda VSTACKBASE+1, x
    pha
}

; push the given register to the stack
!macro vpush .reg {
    +vsetrp .reg
    +vpush
}

; pop the value on the stack to the previous register
!macro vpop {
    pla
    lda VSTACKBASE+1, x
    pla
    lda VSTACKBASE, x
}

; pop the value on the stack to the given register
!macro vpop .reg {
    +vsetrp .reg
    +vpop
}

; increment the previous value
; RP = RP + 1
!macro vinc {
    inc VSTACKBASE, x
    bne +
    inc VSTACKBASE+1, x
+
}

; increment a given register
; Rreg = Rreg + 1
!macro vinc .reg {
    +vsetrp .reg
    +vinc
}

; decrement the previous register
; RP = RP - 1
!macro vdec {
    lda VSTACKBASE, x
    bne +
    dec VSTACKBASE+1, x
+   dec VSTACKBASE, x
}

; decrement a gien register
; Rreg = Rreg - 1
!macro vdec .reg {
    +vsetrp .reg
    +vdec
}

; add an immediate value to previous register
; RP = RP + value
!macro vaddi .value {
    clc
    lda VSTACKBASE, x
    adc #<.value
    sta VSTACKBASE, x
    !if .value < 256 and .value >= 0 {
        ; 8 cycles
        bcc +
        inc VSTACKBASE+1, x
+
    } else {
        ; 10 cycles
        lda VSTACKBASE+1, x
        adc #>.value
        sta VSTACKBASE+1, x
    }
}

; add an immediate value to a given register
; Rreg = Rreg + 1
!macro vaddi .reg, .value {
    +vsetrp .reg
    +vaddi  .value
}

; add an immediate value to a given register and store result in destination {
; Rdest = Rreg + value
!macro vaddi .dest, .reg, .value {
    +vsetrp .dest
    +vcopy  .reg
    +vaddi  .value
}

; add register to previous register
; RP = RP + Rreg
!macro vadd .reg {
    tya
    pha

    clc
    adc #.reg * 2
    tay

    lda VSTACKBASE, x
    adc VSTACKBASE, y
    sta VSTACKBASE, x
    lda VSTACKBASE+1, x
    adc VSTACKBASE+1, y
    sta VSTACKBASE+1, x

    pla
    tay
}

; add register to a destination register
; Rlhs = Rlhs + Rrhs
!macro vadd .lhs, .rhs {
    +vsetrp .lhs
    +vadd   .rhs
}

; add two registers and store result in destination
; Rdest = Rlhs + Rrhs
!macro vadd .dest, .lhs, .rhs {
    +vcopy  .dest, .lhs
    +vadd   .rhs
}

; subtracts a value from the previous register
; RP = RP - value
!macro vsubi .value {
    sec
    lda VSTACKBASE, x
    sbc #<.value
    sta VSTACKBASE, x

    !if .value < 256 and .value >= 0 {
        ; 8 cycles
        bcs +
        dec VSTACKBASE+1, x
+
    } else {
        ; 10 cycles
        lda VSTACKBASE+1, x
        sbc #>.value
        sta VSTACKBASE+1, x
    }
}

; subtracts a value from a given register
; Rreg = Rreg - value
!macro vsubi .reg, .value {
    +vsetrp .reg
    +vsubi  .value
}

; subtracts a value from a given register and stores it in destination
; Rdest = Rreg - value
!macro vsubi .dest, .reg, .value {
    +vcopy  .dest, .reg
    +vsubi  .value
}

; subtracts a register from the previous register
; RP = RP - Rreg
!macro vsub .reg {
    tya
    pha

    clc
    adc #.reg * 2
    tay

    sec
    lda VSTACKBASE, x
    sbc VSTACKBASE, y
    sta VSTACKBASE, x
    lda VSTACKBASE+1, x
    sbc VSTACKBASE+1, y
    sta VSTACKBASE+1, x

    pla
    tay 
}

; subtracts a register from another register
; Rlhs = Rlhs - Rrhs
!macro vsub .lhs, .rhs {
    +vsetrp .lhs
    +vsub   .rhs
}

; subtracts a register from another register and stores in destination
; Rdest = Rlhs - Rrhs
!macro vsub .dest, .lhs, .rhs {
    +vcopy  .dest, .lhs
    +vsub   .rhs
}
