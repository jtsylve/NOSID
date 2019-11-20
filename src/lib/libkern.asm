; kernel library and helpful macros

!macro write16 .address, .value {
    lda #<.value
    sta .address
    lda #>.value
    sta .address+1
}

