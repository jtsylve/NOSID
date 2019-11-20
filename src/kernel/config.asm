; KERNAL configuration parameters

; set the rate at which the kernel context switching will occur
HEARTBEAT_IRQ_TIME      = 20000 ; ~20ms

; enable the use of memory ranges 0xD000-0xE000 as RAM with the added cost of
; having to bank in/out I/O memory when needed
ENABLE_IO_BANKING