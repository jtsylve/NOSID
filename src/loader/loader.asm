; The purpose of the loader is to replace the standard C64 OS with NOSID
!to "loader.prg", cbm

!src "../hardware.asm"
!src "../memmap.asm"

; Commodore Basic bytecode to call SYS 2061 to call our assembly
* = LOADER      ; BASIC start address                         
!word LOADER+10 ; Next basic line 
!word $0001     ; BASIC line number
!byte $9E       ; SYS
!pet "2061"     ; 2061 == 0x080D (start of code)
!byte $00       ; EOC
!byte $00,$00   ; EOP

; C64 Kernel functions
CINIT   = $FF81
SETLFS  = $FFBA
SETNAM  = $FFBD
CLOSE   = $FFC3
CHROUT  = $FFD2
LOAD    = $FFD5

; Prints a string to the screen using C64 KERNAL API
!macro puts .string {
    ldx #0          ; init counter
    beq +           ; skip
-   jsr CHROUT      ; print character
    inx             
+   lda .string,x   ; read next character
    bne -           ; continue if non-zero
}

; Loads a file from disk to the specified address
!macro load .filename, .filename_len, .error {
    lda #.filename_len  ; filename length
    ldx #<.filename     ; filename
    ldy #>.filename
    jsr SETNAM          ; set filename

    lda #1              ; logical number
    ldx $BA             ; current device number
    ldy #1              ; secondary number
    jsr SETLFS          ; set logical file number

    lda #0              ; load at specified address
    jsr LOAD
    bcc +               ; jump if no error
    +puts .error        ; print error message
+
}

.loader
    sei ; disable interrupts

    jsr CINIT ; initialize VIC and clear screen

    ; set screen and border to black
    lda #BLACK
    sta VICII_EC    ; border color
    sta VICII_B0C   ; background color

    ; set text color to white
    lda #WHITE
    sta $0286   ; character color (C64 KERNAL)

    ; set upper/lowercase mode
    lda #%00010111
    sta VICII_PTR  ; VICII memory setup register

    ; print loading string
    +puts .loading_message

    ; load kernel code
    +load .kern_name, .kern_name_len, .load_error

    ; print init message
    +puts .init_message

    ; switch out basic and kernel roms
    lda %111
    sta CPU_DDR
    lda %101
    sta CPU_OUTR

    ; initialize the kernel
    jmp KERN

; DATA
.loading_message    !pet  "[+] Loading NOSID...", 13, 0
.init_message       !pet  "[+] Initializing kernel...", 13, 0
.load_error         !pet  "Can not load KERN", 13, 0
.load_init_error    !pet  "Can not load KERNINIT", 13, 0

.kern_name          !text "KERN" 
.kern_name_len = * - .kern_name
.kern_init_name     !text "KERNINIT" 
.kern_init_name_len = * - .kern_init_name

