; virtual console device

; validate console configuration
!if NUM_CONSOLES < 1 or NUM_CONSOLES > 4 {
    !error "invalid number of consoles"
}

CONSOLE_MEMSIZE = $400
BLANKCHAR       = $20
ROM_CHARSET     = $D800
CHARSET_SIZE    = $800

; initialize console
.dev_console_init 
    ; wipe console video memory
    +memset VIDEO, BLANKCHAR, NUM_CONSOLES * CONSOLE_MEMSIZE
    +memset COLOR_RAM, WHITE, COLOR_RAM_SIZE

    ; bank in character rom
    lda #%001
    sta CPU_OUTR

    ; copy ROM charset into RAM
    +memcpy CHARSET, ROM_CHARSET, CHARSET_SIZE

    ; bank out character rom and in I/O
    lda #%101
    sta CPU_OUTR

    ; set VIC memory bank
    lda CIA2_DDRA
    ora #%00000011
    sta CIA2_DDRA

    lda CIA2_PRA
    and #%11111100
    sta CIA2_PRA

    ; set character memory
    lda #%10000110
    sta VICII_PTR

    rts
