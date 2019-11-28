; KERNAL configuration parameters

; set the rate at which the kernel context switching will occur
HEARTBEAT_IRQ_TIME = 20000 ; ~20ms

; set the number of virtual consoles (up to 4) at the cost of 1 KiB of RAM each
NUM_CONSOLES = 4

; maximum number of running tasks
MAX_TASKS = 32