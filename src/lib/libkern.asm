; kernel library and helpful macros

!macro write16 .address, .value {
    lda #<.value
    sta .address
    lda #>.value
    sta .address+1
}

!macro save_regs {
    pha
    txa
    pha
    tya
    pha
}

!macro restore_regs {
    pla
    tay
    pla
    tax
    pla
}