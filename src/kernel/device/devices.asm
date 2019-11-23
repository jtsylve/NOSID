; device handling

!src "device/console.asm"
!src "device/null.asm"

.device_init:
    jsr .dev_console_init
    rts