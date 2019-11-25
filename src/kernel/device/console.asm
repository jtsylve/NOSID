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

!macro console_activate .n {
    !if .n < 0 or .n > NUM_CONSOLES {
        !error "invalid console number"
    }

    !set crbits = %0100      ; character rom bits
    !set vbits  = %0111 + .n ; video bits

    lda #(vbits << 4) + crbits
    sta VICII_PTR
}

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

    +console_activate 1

    rts

CTOFFSET = OUTPUTP + 0 ; offset into the cursor table
CONSOLE1 = $02
CONSOLE2 = $04
CONSOLE3 = $05
CONSOLE4 = $06

; I/O output function
.dev_console_output
    ; check for control character
    ora #0                          ; change nothing, but set flags
    bmi dco_control                 ; printable characters have top bit clear

    ; add character to cursor position
    ldx CTOFFSET                    ; read cursor table offset from stack params
    sta (CONSOLE_CURSOR_TABLE, x)   ; store the character at the cursor address
 
    ; increment cursor
    inc CONSOLE_CURSOR_TABLE, x     ; increment the low byte of the cursor
    bne * + 4                       ; skip top byte if no overflow
    inc CONSOLE_CURSOR_TABLE+1, x   ; increment the high byte of the cursor
 
    ; set the cursor marker
    lda (CONSOLE_CURSOR_TABLE, x)   ; read the byte at the cursor
    ora #INVERTCHAR                 ; set the character to be inverted
    sta (CONSOLE_CURSOR_TABLE, x)   ; store the inverted character

dco_success
    clc                             ; no errors
    rts                             ; done

dco_control
    cmp #CS_EOS                     ; is this the end of string marker?
    bne dco_success                 ; all other control characters are ignored
    lda #IO_EOS                     ; mark end of stream
    sec                             ; flag error
    rts                             ; done