; virtual console device

; validate console configuration
!if NUM_CONSOLES < 1 or NUM_CONSOLES > 4 {
    !error "invalid number of consoles"
}

CONSOLE_MEMSIZE = $400
BLANKCHAR       = $20
INVERTCHAR      = $80
ROM_CHARSET     = $D800
CHARSET_SIZE    = $800

; initialize console
.dev_console_init 
    ; bank in character rom
    lda #%001
    sta CPU_OUTR

    ; copy ROM charset into RAM
    +memcpy CHARSET, ROM_CHARSET, CHARSET_SIZE

    ; wipe console video memory
    +memset VIDEO, BLANKCHAR, (NUM_CONSOLES + 1) * CONSOLE_MEMSIZE

    ; initalize cursors
    !for i, 0, NUM_CONSOLES {
        !set cp   = VIDEO + (CONSOLE_MEMSIZE * i)
        !set dest = CONSOLE_CURSOR_TABLE + (i * 2)

        ; populate table
        lda #<cp
        sta dest
        lda #>cp
        sta dest+1

        ; set marker
        lda #BLANKCHAR | INVERTCHAR
        sta cp
    }

    ; bank out character rom and in I/O
    lda #%101
    sta CPU_OUTR

    ; set color RAM
    +memset COLOR_RAM, WHITE, COLOR_RAM_SIZE

    ; set VIC memory bank
    lda CIA2_DDRA
    ora #%00000011
    sta CIA2_DDRA

    lda CIA2_PRA
    and #%11111100
    sta CIA2_PRA

    ; set video and character memory offsets for console #1
    lda #%10000100
    sta VICII_PTR

    rts
