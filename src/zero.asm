; zero page

; there is a cursor struct for each vconsole
CONSOLE_CURSOR_TABLE       = $02
_CONSOLE_CURSOR_TABLE_SIZE = $14

; each cursor struct takes up 4 bytes
MONITOR_CURSOR          = CONSOLE_CURSOR_TABLE + $00
CON1_CURSOR             = CONSOLE_CURSOR_TABLE + $04
CON2_CURSOR             = CONSOLE_CURSOR_TABLE + $08
CON3_CURSOR             = CONSOLE_CURSOR_TABLE + $0C
CON4_CURSOR             = CONSOLE_CURSOR_TABLE + $10

; task scheduling
TASK_DATA       = CONSOLE_CURSOR_TABLE + _CONSOLE_CURSOR_TABLE_SIZE
_TASK_DATA_SIZE = $02

TASK_PTR  = TASK_DATA + $00 ; pointer used by task subsystem for indirect access
