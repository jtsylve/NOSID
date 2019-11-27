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

; cursor struct
C_PTR   = $00 ; pointer to the cursor memory
C_ROW   = $02 ; number of rows remaining
C_COL   = $03 ; number of columns remaining
_C_SIZE = $04 ; size of the struct

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
        !set dest = CONSOLE_CURSOR_TABLE + (i * _C_SIZE)

        ; populate table
        lda #<cp
        sta dest+C_PTR
        lda #>cp
        sta dest+C_PTR+1
        lda #CONSOLE_ROWS
        sta dest+C_ROW
        lda #CONSOLE_COLS
        sta dest+C_COL

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

    +console_activate 1

    rts

CTOFFSET = OUTPUTP + 0 ; offset into the cursor table
CONSOLE1 = CON1_CURSOR - CONSOLE_CURSOR_TABLE
CONSOLE2 = CON2_CURSOR - CONSOLE_CURSOR_TABLE
CONSOLE3 = CON3_CURSOR - CONSOLE_CURSOR_TABLE
CONSOLE4 = CON4_CURSOR - CONSOLE_CURSOR_TABLE

; I/O output function
.dev_console_output
    ldx CTOFFSET                    ; read cursor table offset from stack params

    ; check for control character
    ora #0                          ; change nothing, but set flags
    bmi dco_control                 ; printable characters have top bit clear

    ; add character to cursor position
    sta (CONSOLE_CURSOR_TABLE, x)   ; store the character at the cursor address
 
    ; increment cursor
    inc CONSOLE_CURSOR_TABLE+C_PTR, x     ; increment the low byte
    bne * + 4                             ; skip top byte if no overflow
    inc CONSOLE_CURSOR_TABLE+C_PTR+1, x   ; increment the high byte

    ; decrement number of columns left
    dec CONSOLE_CURSOR_TABLE+C_COL, x
    bne dco_success

dco_next_row
    ; decrement number of rows left
    dec CONSOLE_CURSOR_TABLE+C_ROW, x
    bne dco_0

    ; we are in the last row, so we need to not change the row number
    lda #1
    sta CONSOLE_CURSOR_TABLE+C_ROW, x

    ; and scroll the console
    jsr .dev_console_scroll

dco_0
    ; since this is a new row we start from the first column
    lda #CONSOLE_COLS
    sta CONSOLE_CURSOR_TABLE+C_COL, x

dco_success
    jsr .dev_console_invert         ; invert cursor
    clc                             ; no errors
    rts                             ; done

dco_control
    ; check against supported control characters
    cmp #CS_CRLF
    beq dco_crlf
    cmp #CS_EOS
    bne dco_success                 ; all other control characters are ignored

; handle end of stream character
dco_eos
    lda #IO_EOS                     ; mark end of stream
    sec                             ; flag error
    rts                             ; done

; handle crlf character
dco_crlf
    jsr .dev_console_invert            ; reinvert current cursor
    ; add the remaining number of columns to the pointer
    clc
    lda CONSOLE_CURSOR_TABLE+C_COL, x 
    adc CONSOLE_CURSOR_TABLE+C_PTR, x
    sta CONSOLE_CURSOR_TABLE+C_PTR, x
    bcc * + 4
    inc CONSOLE_CURSOR_TABLE+C_PTR+1, x
    jmp dco_next_row

.dev_console_invert
    ; set the cursor marker
    lda (CONSOLE_CURSOR_TABLE, x)   ; read the byte at the cursor
    eor #INVERTCHAR                 ; set the character to be inverted
    sta (CONSOLE_CURSOR_TABLE, x)   ; store the inverted character
    rts

.dev_console_scroll
    ; self modifying code to set loop addresses
    lda CONSOLE_CURSOR_TABLE+C_PTR+1, x
    and #%11111100
    +disable_task_switching
    sta dcs_copy+2
    sta dcs_copy+5

    ; set cursor to start of end of line
    ora #%00000011
    sta CONSOLE_CURSOR_TABLE+C_PTR+1, x
    sta dcs_wipe+2
    lda #$C0
    sta CONSOLE_CURSOR_TABLE+C_PTR, x

    ; move 1 KiB of memory up 40 bytes
    txa
    pha
    ldx #4
dcs_copy_256   
    ldy #$00
dcs_copy
    lda $0028, y ; high byte is modified
    sta $0000, y ; high byte is modified
    iny
    bne dcs_copy
    inc dcs_copy+2
    inc dcs_copy+5
    dex
    bne dcs_copy_256
    pla
    tax

    ; wipe last column
    ldy #CONSOLE_COLS
    lda #BLANKCHAR
dcs_wipe
    sta $00C0, y ; high byte is modified
    dey
    bne dcs_wipe
    +enable_task_switching
    rts