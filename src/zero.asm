; zero page

; there is a cursor struct for each vconsole
CONSOLE_CURSOR_TABLE    = $02

; each cursor struct takes up 4 bytes
MONITOR_CURSOR          = CONSOLE_CURSOR_TABLE + $00
CON1_CURSOR             = CONSOLE_CURSOR_TABLE + $04
CON2_CURSOR             = CONSOLE_CURSOR_TABLE + $08
CON3_CURSOR             = CONSOLE_CURSOR_TABLE + $0C
CON4_CURSOR             = CONSOLE_CURSOR_TABLE + $10
