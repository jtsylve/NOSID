; stack layout and handling

STACK = $0100 ; stack is always at page 1

; there is a cursor for each vconsole
CONSOLE_CURSOR_TABLE    = $02
MONITOR_CURSOR          = CONSOLE_CURSOR_TABLE + $00
CON1_CURSOR             = CONSOLE_CURSOR_TABLE + $02
CON2_CURSOR             = CONSOLE_CURSOR_TABLE + $04
CON3_CURSOR             = CONSOLE_CURSOR_TABLE + $06
CON4_CURSOR             = CONSOLE_CURSOR_TABLE + $08

; the base of the stack for every task always contains the following
EXIT    = STACK + $F6  ; pointer to exit function
OUTPUTP = STACK + $F8  ; output parameters
OUTPUT  = STACK + $FA  ; output function pointer
INPUTP  = STACK + $FC  ; input parameters
INPUT   = STACK + $FE  ; input function pointer